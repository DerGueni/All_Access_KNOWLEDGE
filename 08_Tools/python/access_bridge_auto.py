"""
Access Bridge - VOLLAUTOMATISCH
Automatische Behandlung aller Dialoge, Pop-ups und Fehlermeldungen
"""

import win32com.client
import pythoncom
import pyodbc
import os
import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
import time
import threading
import win32gui
import win32con
import win32api


class DialogWatchdog(threading.Thread):
    """
    Background-Thread zur automatischen Dialog-Behandlung
    Schließt alle störenden Pop-ups automatisch
    """
    
    def __init__(self):
        super().__init__(daemon=True)
        self.running = True
        self.dialogs_handled = []
        
        # Dialog-Titel die automatisch behandelt werden
        self.auto_close_titles = [
            "Microsoft Access",
            "Microsoft Visual Basic",  # VBA-Fehler KRITISCH!
            "Visual Basic",
            "Warnung",
            "Fehler",
            "Kompilieren",  # VBA-Compile-Fehler
            "Speichern",
            "Sicherheit",
            "Bestätigung",
            "Hinweis",
            "Information",
            "Achtung",
            "Laufzeitfehler",
            "Debugger"
        ]
        
        # Buttons die automatisch geklickt werden (in Prioritätsreihenfolge)
        self.auto_click_buttons = [
            "Ja",           # Speichern? → Ja
            "OK",           # Bestätigung → OK  
            "Schließen",    # Dialog schließen
            "Hilfe",        # VBA-Fehler: Hilfe wegklicken
            "Ignorieren",   # Fehler ignorieren
            "Weiter",       # Fortfahren
            "Überspringen", # Überspringen
            "Abbrechen"     # Nur als letzter Ausweg
        ]
    
    def run(self):
        """Läuft kontinuierlich im Hintergrund"""
        while self.running:
            try:
                self._check_and_close_dialogs()
                time.sleep(0.5)  # Check alle 500ms
            except:
                pass
    
    def stop(self):
        """Stoppt den Watchdog"""
        self.running = False
    
    def _check_and_close_dialogs(self):
        """Sucht und schließt automatisch Dialoge"""
        def enum_callback(hwnd, _):
            if win32gui.IsWindowVisible(hwnd):
                window_text = win32gui.GetWindowText(hwnd)
                
                # Prüfe ob Dialog automatisch behandelt werden soll
                for title in self.auto_close_titles:
                    if title.lower() in window_text.lower():
                        self._handle_dialog(hwnd, window_text)
                        return True
                
                # EXTRA: Auch ohne Titel-Match - wenn es ein Modal-Dialog ist
                if self._is_modal_dialog(hwnd):
                    self._handle_dialog(hwnd, window_text if window_text else "Unbekannter Dialog")
                    
            return True
        
        win32gui.EnumWindows(enum_callback, None)
    
    def _is_modal_dialog(self, hwnd):
        """Prüft ob Fenster ein modaler Dialog ist"""
        try:
            style = win32gui.GetWindowLong(hwnd, win32con.GWL_STYLE)
            ex_style = win32gui.GetWindowLong(hwnd, win32con.GWL_EXSTYLE)
            
            # Modal-Dialog-Eigenschaften
            is_dialog = (style & win32con.WS_DLGFRAME) or (style & win32con.DS_MODALFRAME)
            is_popup = style & win32con.WS_POPUP
            is_tool_window = ex_style & win32con.WS_EX_TOOLWINDOW
            
            return (is_dialog or is_popup) and not is_tool_window
        except:
            return False
    
    def _handle_dialog(self, hwnd, window_text):
        """Behandelt einen Dialog automatisch"""
        try:
            # Logge Dialog
            dialog_info = {
                'time': time.strftime('%H:%M:%S'),
                'title': window_text,
                'action': None
            }
            
            # Suche Button zum Klicken
            button_clicked = False
            
            def enum_child_callback(child_hwnd, _):
                nonlocal button_clicked
                if button_clicked:
                    return False
                    
                button_text = win32gui.GetWindowText(child_hwnd)
                
                # Prüfe ob es ein Button ist den wir klicken wollen
                for auto_button in self.auto_click_buttons:
                    if auto_button.lower() == button_text.lower():
                        # Button klicken!
                        win32api.PostMessage(child_hwnd, win32con.BM_CLICK, 0, 0)
                        dialog_info['action'] = f"Button '{auto_button}' geklickt"
                        button_clicked = True
                        return False
                
                return True
            
            # Durchsuche Child-Windows (Buttons)
            win32gui.EnumChildWindows(hwnd, enum_child_callback, None)
            
            # Falls kein Button gefunden: Dialog schließen mit ESC
            if not button_clicked:
                win32api.keybd_event(0x1B, 0, 0, 0)  # ESC drücken
                win32api.keybd_event(0x1B, 0, win32con.KEYEVENTF_KEYUP, 0)
                dialog_info['action'] = 'ESC gesendet'
            
            # Logge Aktion
            self.dialogs_handled.append(dialog_info)
            print(f"  🤖 Dialog auto-behandelt: {dialog_info['title']} → {dialog_info['action']}")
            
        except Exception as e:
            pass  # Stumm weitermachen
    
    def get_handled_dialogs(self):
        """Gibt Liste behandelter Dialoge zurück"""
        return self.dialogs_handled.copy()


class AccessBridgeAuto:
    """
    Vollautomatische Access Bridge
    - Automatische Dialog-Behandlung
    - Vollzugriff ohne Sicherheitsabfragen
    - Keine manuelle Interaktion nötig
    """
    
    def __init__(self, db_path: str = None, auto_connect: bool = True, config_path: str = None):
        """
        Initialisiert die vollautomatische Access Bridge
        
        Args:
            db_path: Pfad zur Access-Datenbank (optional)
            auto_connect: Automatisch verbinden
            config_path: Pfad zu config.json (optional)
        """
        # Config laden
        if not config_path:
            config_path = Path(__file__).parent / "config.json"
        
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        # Datenbankpfade
        if db_path:
            self.frontend_path = os.path.abspath(db_path)
        else:
            self.frontend_path = self.config['database']['frontend_path']
        
        self.backend_path = self.config['database']['backend_path']
        
        # Bridge-Optionen
        self.use_running_instance = self.config['bridge'].get('use_running_instance', True)
        self.prefer_backend_for_data = self.config['bridge'].get('prefer_backend_for_data', True)
        
        # Verbindungsobjekte
        self.access_app = None
        self.db = None
        self.conn_odbc_frontend = None
        self.conn_odbc_backend = None
        self.is_connected = False
        self.is_frontend_locked = False
        
        # Dialog-Watchdog starten
        self.watchdog = DialogWatchdog()
        self.watchdog.start()
        print("✓ Dialog-Watchdog gestartet (automatische Pop-up Behandlung aktiv)")
        
        if auto_connect:
            self.connect()
    
    def connect(self):
        """Stellt Verbindung her mit vollautomatischer Konfiguration"""
        try:
            # 1. COM-Verbindung zu Access
            self._connect_com()
            
            # 2. Access-Sicherheitseinstellungen DEAKTIVIEREN
            self._disable_all_warnings()
            
            # 3. ODBC-Verbindung
            self._connect_odbc()
            
            self.is_connected = True
            print(f"✓ Vollautomatisch verbunden (ALLE Warnungen deaktiviert)")
            if self.is_frontend_locked:
                print("  ℹ Frontend geöffnet - nutze Backend für Daten")
            
        except Exception as e:
            raise ConnectionError(f"Verbindung fehlgeschlagen: {e}")
    
    def _connect_com(self):
        """COM-Verbindung zu Access"""
        try:
            pythoncom.CoInitialize()
            
            if self.use_running_instance:
                try:
                    self.access_app = win32com.client.GetObject(Class="Access.Application")
                    print("  ✓ COM: Laufende Access-Instanz gefunden")
                except:
                    self.access_app = win32com.client.Dispatch("Access.Application")
                    self.access_app.Visible = False  # Immer unsichtbar für Automation
                    self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                    print("  ✓ COM: Neue Access-Instanz erstellt")
            else:
                self.access_app = win32com.client.Dispatch("Access.Application")
                self.access_app.Visible = False
                self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                print("  ✓ COM: Access-Instanz erstellt")
            
            self.db = self.access_app.CurrentDb()
            
        except Exception as e:
            print(f"  ⚠ COM-Fehler: {e}")
            raise
    
    def _disable_all_warnings(self):
        """
        Deaktiviert ALLE Access-Warnungen und Sicherheitsabfragen
        Vollautomatischer Modus ohne Benutzereingriffe
        """
        try:
            # Application-Optionen setzen
            self.access_app.DoCmd.SetWarnings(False)  # Keine Warnungen
            
            # Weitere Application-Einstellungen
            try:
                # Confirmations deaktivieren
                self.access_app.SetOption("Confirm Record Changes", False)
                self.access_app.SetOption("Confirm Document Deletions", False) 
                self.access_app.SetOption("Confirm Action Queries", False)
                
                # Auto-Saves aktivieren
                self.access_app.SetOption("Auto Compact", False)  # Keine Compacting-Dialoge
                
                print("  ✓ Alle Access-Warnungen deaktiviert")
            except:
                print("  ℹ Einige Optionen nicht verfügbar (ältere Access-Version?)")
            
        except Exception as e:
            print(f"  ⚠ Warnung beim Deaktivieren von Dialogen: {e}")
    
    def _connect_odbc(self):
        """ODBC-Verbindung (Backend bevorzugt)"""
        # Backend zuerst versuchen
        if self.prefer_backend_for_data and os.path.exists(self.backend_path):
            try:
                conn_str = (
                    r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                    f'DBQ={self.backend_path};'
                )
                self.conn_odbc_backend = pyodbc.connect(conn_str)
                print(f"  ✓ ODBC: Backend verbunden")
                return
            except Exception as e:
                print(f"  ⚠ Backend-Verbindung fehlgeschlagen: {e}")
        
        # Fallback: Frontend
        try:
            conn_str = (
                r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                f'DBQ={self.frontend_path};'
            )
            self.conn_odbc_frontend = pyodbc.connect(conn_str)
            print(f"  ✓ ODBC: Frontend verbunden")
        except Exception as e:
            self.is_frontend_locked = True
            
            if not self.conn_odbc_backend:
                if os.path.exists(self.backend_path):
                    try:
                        conn_str = (
                            r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                            f'DBQ={self.backend_path};'
                        )
                        self.conn_odbc_backend = pyodbc.connect(conn_str)
                        print(f"  ✓ ODBC: Backend verbunden (Fallback)")
                    except Exception as be:
                        raise ConnectionError(f"Frontend gesperrt und Backend nicht verfügbar: {be}")
                else:
                    raise ConnectionError(f"Frontend gesperrt und Backend nicht gefunden")
    
    def _get_odbc_conn(self):
        """Gibt aktive ODBC-Verbindung zurück"""
        if self.conn_odbc_backend:
            return self.conn_odbc_backend
        elif self.conn_odbc_frontend:
            return self.conn_odbc_frontend
        else:
            raise ConnectionError("Keine ODBC-Verbindung verfügbar")
    
    def disconnect(self):
        """Trennt alle Verbindungen"""
        try:
            # Watchdog stoppen
            self.watchdog.stop()
            
            # ODBC trennen
            if self.conn_odbc_backend:
                self.conn_odbc_backend.close()
                self.conn_odbc_backend = None
            
            if self.conn_odbc_frontend:
                self.conn_odbc_frontend.close()
                self.conn_odbc_frontend = None
            
            # COM nur trennen wenn WIR die Instanz erstellt haben
            if self.access_app and not self.use_running_instance:
                # Warnungen wieder aktivieren vor dem Schließen
                try:
                    self.access_app.DoCmd.SetWarnings(True)
                except:
                    pass
                
                self.access_app.CloseCurrentDatabase()
                self.access_app.Quit()
                self.access_app = None
            
            pythoncom.CoUninitialize()
            self.is_connected = False
            
            # Dialog-Report ausgeben
            handled = self.watchdog.get_handled_dialogs()
            if handled:
                print(f"\n📊 Watchdog-Report: {len(handled)} Dialoge automatisch behandelt")
                for d in handled[-5:]:  # Zeige letzte 5
                    print(f"  • {d['time']} - {d['title']}: {d['action']}")
            
            print("✓ Verbindung getrennt")
            
        except Exception as e:
            print(f"Warnung beim Trennen: {e}")
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()
    
    # ==================== SICHERE SQL-OPERATIONEN ====================
    
    def execute_sql(self, sql: str, params: tuple = None, fetch: bool = True, 
                    auto_retry: bool = True, max_retries: int = 3) -> Optional[List]:
        """
        Führt SQL-Query aus mit automatischen Wiederholungen
        
        Args:
            sql: SQL-Statement
            params: Parameter für Prepared Statement
            fetch: Ergebnisse zurückgeben
            auto_retry: Bei Fehler automatisch wiederholen
            max_retries: Maximale Wiederholungen
        """
        retry_count = 0
        last_error = None
        
        while retry_count <= (max_retries if auto_retry else 0):
            try:
                conn = self._get_odbc_conn()
                cursor = conn.cursor()
                
                if params:
                    cursor.execute(sql, params)
                else:
                    cursor.execute(sql)
                
                if fetch:
                    columns = [column[0] for column in cursor.description]
                    results = []
                    for row in cursor.fetchall():
                        results.append(dict(zip(columns, row)))
                    cursor.close()
                    return results
                else:
                    conn.commit()
                    cursor.close()
                    return None
                    
            except Exception as e:
                last_error = e
                retry_count += 1
                
                if retry_count <= max_retries:
                    print(f"  ⚠ SQL-Fehler (Versuch {retry_count}/{max_retries}): {str(e)[:100]}")
                    time.sleep(0.5)  # Kurz warten vor Wiederholung
                    continue
                else:
                    # Alle Versuche fehlgeschlagen
                    conn.rollback()
                    raise RuntimeError(f"SQL-Fehler nach {max_retries} Versuchen: {e}\nQuery: {sql}")
    
    def get_table_data(self, table_name: str, where: str = None, 
                       limit: int = None, order_by: str = None) -> List[Dict]:
        """Liest Daten aus Tabelle"""
        sql = f"SELECT "
        if limit:
            sql += f"TOP {limit} "
        sql += f"* FROM [{table_name}]"
        
        if where:
            sql += f" WHERE {where}"
        
        if order_by:
            sql += f" ORDER BY {order_by}"
        
        return self.execute_sql(sql)
    
    def insert_record(self, table_name: str, data: Dict, 
                     return_id: bool = False) -> Optional[int]:
        """
        Fügt Datensatz ein
        
        Args:
            table_name: Tabellenname
            data: Daten als Dict
            return_id: Gibt neue ID zurück (bei AutoWert-Feld)
        """
        fields = ", ".join([f"[{k}]" for k in data.keys()])
        placeholders = ", ".join(["?" for _ in data])
        sql = f"INSERT INTO [{table_name}] ({fields}) VALUES ({placeholders})"
        
        self.execute_sql(sql, tuple(data.values()), fetch=False)
        
        if return_id:
            result = self.execute_sql(f"SELECT @@IDENTITY AS NewID")
            return result[0]['NewID'] if result else None
        
        return None
    
    def update_record(self, table_name: str, data: Dict, where: str, 
                     safe_mode: bool = True) -> int:
        """
        Aktualisiert Datensatz(e)
        
        Args:
            table_name: Tabellenname
            data: Neue Daten als Dict
            where: WHERE-Bedingung
            safe_mode: Verhindert Update ohne WHERE
        """
        if safe_mode and not where:
            raise ValueError("UPDATE ohne WHERE ist im Safe-Mode nicht erlaubt!")
        
        set_clause = ", ".join([f"[{k}] = ?" for k in data.keys()])
        sql = f"UPDATE [{table_name}] SET {set_clause}"
        
        if where:
            sql += f" WHERE {where}"
        
        self.execute_sql(sql, tuple(data.values()), fetch=False)
        
        # Anzahl betroffener Datensätze zurückgeben
        result = self.execute_sql("SELECT @@ROWCOUNT AS Affected")
        return result[0]['Affected'] if result else 0
    
    def delete_record(self, table_name: str, where: str, 
                     safe_mode: bool = True) -> int:
        """
        Löscht Datensatz(e)
        
        Args:
            table_name: Tabellenname
            where: WHERE-Bedingung
            safe_mode: Verhindert DELETE ohne WHERE
        """
        if safe_mode and not where:
            raise ValueError("DELETE ohne WHERE ist im Safe-Mode nicht erlaubt!")
        
        sql = f"DELETE FROM [{table_name}]"
        
        if where:
            sql += f" WHERE {where}"
        
        self.execute_sql(sql, fetch=False)
        
        # Anzahl betroffener Datensätze zurückgeben
        result = self.execute_sql("SELECT @@ROWCOUNT AS Affected")
        return result[0]['Affected'] if result else 0
    
    # ==================== FORMULAR-OPERATIONEN ====================
    
    def open_form(self, form_name: str, view: int = 0, where: str = None, 
                  data_mode: int = 1, window_mode: int = 0, wait: float = 0.5) -> None:
        """
        Öffnet ein Formular
        
        Args:
            wait: Wartezeit nach dem Öffnen (für Formular-Events)
        """
        try:
            self.access_app.DoCmd.OpenForm(form_name, view, "", where, data_mode, window_mode)
            time.sleep(wait)  # Kurz warten damit Events abgearbeitet werden
            print(f"✓ Formular '{form_name}' geöffnet")
        except Exception as e:
            raise RuntimeError(f"Fehler beim Öffnen: {e}")
    
    def close_form(self, form_name: str, save: int = 1, force: bool = True) -> None:
        """
        Schließt ein Formular
        
        Args:
            save: 0=ohne Speichern, 1=mit Prompt, 2=immer speichern
            force: Bei Fehler trotzdem versuchen zu schließen
        """
        try:
            self.access_app.DoCmd.Close(2, form_name, save)
            print(f"✓ Formular '{form_name}' geschlossen")
        except Exception as e:
            if force:
                # Formular notfalls mit SendKeys schließen
                try:
                    self.access_app.DoCmd.SelectObject(2, form_name, True)
                    win32api.keybd_event(win32con.VK_MENU, 0, 0, 0)  # ALT
                    win32api.keybd_event(ord('F'), 0, 0, 0)  # F
                    win32api.keybd_event(ord('S'), 0, 0, 0)  # S (Schließen)
                    win32api.keybd_event(ord('F'), 0, win32con.KEYEVENTF_KEYUP, 0)
                    win32api.keybd_event(win32con.VK_MENU, 0, win32con.KEYEVENTF_KEYUP, 0)
                    print(f"✓ Formular '{form_name}' zwangsweise geschlossen")
                except:
                    raise RuntimeError(f"Fehler beim Schließen: {e}")
            else:
                raise RuntimeError(f"Fehler beim Schließen: {e}")
    
    def get_form_control_value(self, form_name: str, control_name: str) -> Any:
        """Liest Wert eines Formular-Steuerelements"""
        try:
            form = self.access_app.Forms(form_name)
            return form.Controls(control_name).Value
        except Exception as e:
            raise RuntimeError(f"Fehler beim Lesen: {e}")
    
    def set_form_control_value(self, form_name: str, control_name: str, 
                               value: Any, wait: float = 0.2) -> None:
        """
        Setzt Wert eines Formular-Steuerelements
        
        Args:
            wait: Wartezeit nach dem Setzen (für Events)
        """
        try:
            form = self.access_app.Forms(form_name)
            form.Controls(control_name).Value = value
            time.sleep(wait)  # Events abwarten
            print(f"✓ Wert gesetzt: {control_name} = {value}")
        except Exception as e:
            raise RuntimeError(f"Fehler beim Setzen: {e}")
    
    # ==================== VBA-OPERATIONEN ====================
    
    def run_vba_function(self, function_name: str, *args, timeout: float = 30.0) -> Any:
        """
        Führt VBA-Funktion aus mit Timeout
        
        Args:
            timeout: Max. Wartezeit in Sekunden
        """
        try:
            result = self.access_app.Run(function_name, *args)
            print(f"✓ VBA-Funktion '{function_name}' ausgeführt")
            return result
        except Exception as e:
            raise RuntimeError(f"VBA-Fehler: {e}")
    
    def run_vba_sub(self, sub_name: str, *args) -> None:
        """Führt VBA-Sub aus"""
        try:
            self.access_app.Run(sub_name, *args)
            print(f"✓ VBA-Sub '{sub_name}' ausgeführt")
        except Exception as e:
            raise RuntimeError(f"VBA-Fehler: {e}")
    
    # ==================== DATENBANK-INFO ====================
    
    def list_tables(self, include_system: bool = False) -> List[str]:
        """Listet alle Tabellen auf"""
        conn = self._get_odbc_conn()
        cursor = conn.cursor()
        tables = []
        for row in cursor.tables(tableType='TABLE'):
            table_name = row.table_name
            if include_system or (not table_name.startswith('MSys') and not table_name.startswith('~')):
                tables.append(table_name)
        cursor.close()
        return sorted(tables)
    
    def list_forms(self) -> List[str]:
        """Listet alle Formulare auf"""
        forms = []
        for obj in self.access_app.CurrentProject.AllForms:
            forms.append(obj.Name)
        return sorted(forms)
    
    def list_reports(self) -> List[str]:
        """Listet alle Reports auf"""
        reports = []
        for obj in self.access_app.CurrentProject.AllReports:
            reports.append(obj.Name)
        return sorted(reports)
    
    def get_database_info(self) -> Dict:
        """Gibt Datenbank-Informationen zurück"""
        info = {
            'frontend_path': self.frontend_path,
            'backend_path': self.backend_path if self.conn_odbc_backend else None,
            'frontend_locked': self.is_frontend_locked,
            'using_backend_for_data': self.conn_odbc_backend is not None,
            'tables_count': len(self.list_tables()),
            'forms_count': len(self.list_forms()),
            'reports_count': len(self.list_reports()),
            'watchdog_active': self.watchdog.running,
            'dialogs_handled': len(self.watchdog.get_handled_dialogs())
        }
        return info


# Alias für einfachere Verwendung
AccessBridge = AccessBridgeAuto


if __name__ == "__main__":
    print("=" * 60)
    print("Access Bridge - VOLLAUTOMATISCH")
    print("Automatische Dialog-Behandlung aktiv!")
    print("=" * 60)
    
    with AccessBridge() as bridge:
        info = bridge.get_database_info()
        print("\n=== Datenbank-Status ===")
        for key, value in info.items():
            print(f"{key}: {value}")
        
        print("\n✓ Alle Operationen laufen vollautomatisch!")
        print("✓ Keine manuelle Interaktion nötig!")
