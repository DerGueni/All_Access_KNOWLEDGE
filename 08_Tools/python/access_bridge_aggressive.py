"""
Access Bridge - ULTRA-AGGRESSIVE Dialog-Behandlung
Schließt ALLE Dialoge automatisch - keine Ausnahmen!
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
import ctypes


class AggressiveDialogKiller(threading.Thread):
    """
    ULTRA-AGGRESSIVE Dialog-Killer
    Schließt JEDEN Dialog sofort - keine Titel-Prüfung!
    """
    
    def __init__(self, access_hwnd=None):
        super().__init__(daemon=True)
        self.running = True
        self.dialogs_killed = []
        self.access_hwnd = access_hwnd
        self.check_interval = 0.1  # 100ms - sehr schnell!
        
        print("⚡ ULTRA-AGGRESSIVE Dialog-Killer aktiv!")
        print("   → Schließt ALLE Dialoge automatisch")
        print("   → Check-Intervall: 100ms")
    
    def run(self):
        """Läuft mit hoher Frequenz"""
        while self.running:
            try:
                self._kill_all_dialogs()
                time.sleep(self.check_interval)
            except:
                pass
    
    def stop(self):
        self.running = False
    
    def _kill_all_dialogs(self):
        """Findet und schließt ALLE Dialoge"""
        def enum_callback(hwnd, _):
            try:
                # Ist das Fenster sichtbar?
                if not win32gui.IsWindowVisible(hwnd):
                    return True
                
                # Hole Fenster-Info
                class_name = win32gui.GetClassName(hwnd)
                window_text = win32gui.GetWindowText(hwnd)
                
                # AGGRESSIVE FILTER: Schließe alles was aussieht wie ein Dialog
                is_dialog = False
                
                # 1. Klassennamen die IMMER Dialoge sind
                dialog_classes = [
                    '#32770',  # Standard Windows Dialog
                    'ThunderRT6FormDC',  # VBA Forms
                    'bosa_sdm_',  # Office Dialog
                ]
                
                for dialog_class in dialog_classes:
                    if dialog_class in class_name:
                        is_dialog = True
                        break
                
                # 2. Fenster-Style prüfen
                if not is_dialog:
                    try:
                        style = win32gui.GetWindowLong(hwnd, win32con.GWL_STYLE)
                        ex_style = win32gui.GetWindowLong(hwnd, win32con.GWL_EXSTYLE)
                        
                        # Dialog-Eigenschaften
                        has_dialog_frame = (style & win32con.WS_DLGFRAME) != 0
                        is_popup = (style & win32con.WS_POPUP) != 0
                        is_modal = (ex_style & win32con.WS_EX_DLGMODALFRAME) != 0
                        
                        if has_dialog_frame or is_popup or is_modal:
                            is_dialog = True
                    except:
                        pass
                
                # 3. Titel-basierte Erkennung (BACKUP)
                if not is_dialog and window_text:
                    dialog_keywords = [
                        'Microsoft', 'Visual Basic', 'Access', 'Fehler', 'Error',
                        'Warnung', 'Warning', 'Kompilieren', 'Compile'
                    ]
                    
                    for keyword in dialog_keywords:
                        if keyword.lower() in window_text.lower():
                            is_dialog = True
                            break
                
                # DIALOG GEFUNDEN → SCHLIESSEN!
                if is_dialog:
                    self._close_dialog(hwnd, window_text, class_name)
                
            except:
                pass
            
            return True
        
        win32gui.EnumWindows(enum_callback, None)
    
    def _close_dialog(self, hwnd, title, class_name):
        """Schließt einen Dialog mit ALLEN Mitteln"""
        try:
            killed = False
            method = None
            
            # METHODE 1: Button klicken (bevorzugt)
            def find_and_click_button(child_hwnd, _):
                nonlocal killed, method
                if killed:
                    return False
                
                try:
                    btn_text = win32gui.GetWindowText(child_hwnd)
                    btn_class = win32gui.GetClassName(child_hwnd)
                    
                    # Ist es ein Button?
                    if 'button' in btn_class.lower():
                        # Priorität: OK > Ja > Hilfe > Abbrechen
                        if btn_text.lower() in ['ok', 'ja', 'yes', 'hilfe', 'help']:
                            win32api.SendMessage(child_hwnd, win32con.BM_CLICK, 0, 0)
                            killed = True
                            method = f"Button '{btn_text}' geklickt"
                            return False
                except:
                    pass
                
                return True
            
            # Suche Buttons
            win32gui.EnumChildWindows(hwnd, find_and_click_button, None)
            
            if not killed:
                # METHODE 2: WM_CLOSE senden
                try:
                    win32api.SendMessage(hwnd, win32con.WM_CLOSE, 0, 0)
                    killed = True
                    method = "WM_CLOSE gesendet"
                except:
                    pass
            
            if not killed:
                # METHODE 3: ESC-Taste
                try:
                    win32api.keybd_event(0x1B, 0, 0, 0)
                    win32api.keybd_event(0x1B, 0, win32con.KEYEVENTF_KEYUP, 0)
                    killed = True
                    method = "ESC gesendet"
                except:
                    pass
            
            if not killed:
                # METHODE 4: Alt+F4
                try:
                    win32gui.SetForegroundWindow(hwnd)
                    win32api.keybd_event(win32con.VK_MENU, 0, 0, 0)
                    win32api.keybd_event(win32con.VK_F4, 0, 0, 0)
                    win32api.keybd_event(win32con.VK_F4, 0, win32con.KEYEVENTF_KEYUP, 0)
                    win32api.keybd_event(win32con.VK_MENU, 0, win32con.KEYEVENTF_KEYUP, 0)
                    killed = True
                    method = "Alt+F4 gesendet"
                except:
                    pass
            
            # Logging
            if killed:
                log_entry = {
                    'time': time.strftime('%H:%M:%S'),
                    'title': title if title else f'[{class_name}]',
                    'method': method
                }
                self.dialogs_killed.append(log_entry)
                print(f"  💀 Dialog geschlossen: {log_entry['title']} → {method}")
        
        except:
            pass
    
    def get_stats(self):
        return {
            'total_killed': len(self.dialogs_killed),
            'recent': self.dialogs_killed[-10:]
        }


class AccessBridge:
    """
    Access Bridge mit ULTRA-AGGRESSIVER Dialog-Behandlung
    """
    
    def __init__(self, db_path: str = None, auto_connect: bool = True, config_path: str = None):
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
        
        # AGGRESSIVER Dialog-Killer
        self.dialog_killer = None
        
        if auto_connect:
            self.connect()
    
    def connect(self):
        """Stellt Verbindung her"""
        try:
            # 1. COM-Verbindung
            self._connect_com()
            
            # 2. Access-Warnungen deaktivieren
            self._disable_all_warnings()
            
            # 3. AGGRESSIVEN Dialog-Killer starten
            self.dialog_killer = AggressiveDialogKiller()
            self.dialog_killer.start()
            
            # 4. ODBC-Verbindung
            self._connect_odbc()
            
            self.is_connected = True
            print(f"✓ Vollautomatisch verbunden")
            
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
                    self.access_app.Visible = False
                    self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                    print("  ✓ COM: Neue Access-Instanz erstellt")
            else:
                self.access_app = win32com.client.Dispatch("Access.Application")
                self.access_app.Visible = False
                self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                print("  ✓ COM: Access-Instanz erstellt")
            
            self.db = self.access_app.CurrentDb()
            
        except Exception as e:
            raise
    
    def _disable_all_warnings(self):
        """Deaktiviert alle Access-Warnungen"""
        try:
            self.access_app.DoCmd.SetWarnings(False)
            
            try:
                self.access_app.SetOption("Confirm Record Changes", False)
                self.access_app.SetOption("Confirm Document Deletions", False) 
                self.access_app.SetOption("Confirm Action Queries", False)
                print("  ✓ Alle Access-Warnungen deaktiviert")
            except:
                pass
            
        except Exception as e:
            pass
    
    def _connect_odbc(self):
        """ODBC-Verbindung"""
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
                pass
        
        try:
            conn_str = (
                r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                f'DBQ={self.frontend_path};'
            )
            self.conn_odbc_frontend = pyodbc.connect(conn_str)
            print(f"  ✓ ODBC: Frontend verbunden")
        except Exception as e:
            self.is_frontend_locked = True
            
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
            # Dialog-Killer stoppen
            if self.dialog_killer:
                self.dialog_killer.stop()
                
                # Stats ausgeben
                stats = self.dialog_killer.get_stats()
                if stats['total_killed'] > 0:
                    print(f"\n💀 Dialog-Killer Report: {stats['total_killed']} Dialoge geschlossen")
                    for d in stats['recent']:
                        print(f"  • {d['time']} - {d['title']}: {d['method']}")
            
            # ODBC trennen
            if self.conn_odbc_backend:
                self.conn_odbc_backend.close()
                self.conn_odbc_backend = None
            
            if self.conn_odbc_frontend:
                self.conn_odbc_frontend.close()
                self.conn_odbc_frontend = None
            
            # COM trennen
            if self.access_app and not self.use_running_instance:
                try:
                    self.access_app.DoCmd.SetWarnings(True)
                except:
                    pass
                
                self.access_app.CloseCurrentDatabase()
                self.access_app.Quit()
                self.access_app = None
            
            pythoncom.CoUninitialize()
            self.is_connected = False
            
            print("✓ Verbindung getrennt")
            
        except Exception as e:
            print(f"Warnung beim Trennen: {e}")
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()
    
    # Vereinfachte Methoden für Test
    def execute_sql(self, sql: str, params: tuple = None, fetch: bool = True) -> Optional[List]:
        """Führt SQL aus"""
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
            if not fetch:
                conn.rollback()
            raise RuntimeError(f"SQL-Fehler: {e}")


if __name__ == "__main__":
    print("="*60)
    print("Access Bridge - ULTRA-AGGRESSIVE")
    print("Schließt ALLE Dialoge automatisch!")
    print("="*60)
    
    with AccessBridge() as bridge:
        print("\n✓ Bridge aktiv - Dialog-Killer läuft")
        print("  Warte 5 Sekunden...")
        time.sleep(5)
