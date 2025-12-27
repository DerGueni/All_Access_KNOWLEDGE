"""
Access Bridge - ENHANCED für parallele Frontend-Nutzung
Unterstützt: Laufende Access-Instanz + Backend-Datenbank für Datenoperationen
"""

import win32com.client
import pythoncom
import pyodbc
import os
import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
import time


class AccessBridge:
    """
    Hauptklasse für Access-Interaktion
    NEU: Unterstützt laufende Access-Instanz + Backend für Daten
    """
    
    def __init__(self, db_path: str = None, auto_connect: bool = True, config_path: str = None):
        """
        Initialisiert die Access Bridge
        
        Args:
            db_path: Pfad zur Access-Datenbank (optional, nutzt config.json)
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
        
        if auto_connect:
            self.connect()
    
    def connect(self):
        """Stellt Verbindung her - intelligent mit Fallback"""
        try:
            # 1. COM-Verbindung zu Access (Frontend für Forms/VBA)
            self._connect_com()
            
            # 2. ODBC-Verbindung (Backend bevorzugt wenn Frontend gesperrt)
            self._connect_odbc()
            
            self.is_connected = True
            print(f"✓ Verbunden")
            if self.is_frontend_locked:
                print("  ℹ Frontend ist geöffnet - nutze Backend für Datenoperationen")
            
        except Exception as e:
            raise ConnectionError(f"Verbindung fehlgeschlagen: {e}")
    
    def _connect_com(self):
        """COM-Verbindung zu Access (laufend oder neu)"""
        try:
            pythoncom.CoInitialize()
            
            if self.use_running_instance:
                try:
                    # Versuche laufende Access-Instanz zu nutzen
                    self.access_app = win32com.client.GetObject(Class="Access.Application")
                    print("  ✓ COM: Laufende Access-Instanz gefunden")
                    
                    # Prüfe ob richtige DB offen ist
                    if self.access_app.CurrentDb():
                        current_db = self.access_app.CurrentProject.FullName
                        if os.path.normpath(current_db) != os.path.normpath(self.frontend_path):
                            print(f"  ⚠ Andere DB ist offen: {current_db}")
                    
                except:
                    # Keine laufende Instanz - neue erstellen
                    self.access_app = win32com.client.Dispatch("Access.Application")
                    self.access_app.Visible = self.config['bridge'].get('access_visible', False)
                    self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                    print("  ✓ COM: Neue Access-Instanz erstellt")
            else:
                # Immer neue Instanz
                self.access_app = win32com.client.Dispatch("Access.Application")
                self.access_app.Visible = self.config['bridge'].get('access_visible', False)
                self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                print("  ✓ COM: Access-Instanz erstellt")
            
            self.db = self.access_app.CurrentDb()
            
        except Exception as e:
            print(f"  ⚠ COM-Fehler: {e}")
            raise
    
    def _connect_odbc(self):
        """ODBC-Verbindung (Backend bevorzugt)"""
        # Versuche zuerst Backend
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
        
        # Fallback: Frontend (wenn nicht gesperrt)
        try:
            conn_str = (
                r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                f'DBQ={self.frontend_path};'
            )
            self.conn_odbc_frontend = pyodbc.connect(conn_str)
            print(f"  ✓ ODBC: Frontend verbunden")
        except Exception as e:
            # Frontend ist gesperrt
            self.is_frontend_locked = True
            
            # Backend MUSS verfügbar sein
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
                    raise ConnectionError(f"Frontend gesperrt und Backend nicht gefunden: {self.backend_path}")
    
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
            # ODBC trennen
            if self.conn_odbc_backend:
                self.conn_odbc_backend.close()
                self.conn_odbc_backend = None
            
            if self.conn_odbc_frontend:
                self.conn_odbc_frontend.close()
                self.conn_odbc_frontend = None
            
            # COM nur trennen wenn WIR die Instanz erstellt haben
            if self.access_app and not self.use_running_instance:
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
    
    # ==================== TABELLEN-OPERATIONEN ====================
    
    def execute_sql(self, sql: str, params: tuple = None, fetch: bool = True) -> Optional[List]:
        """Führt SQL-Query aus"""
        conn = self._get_odbc_conn()
        cursor = conn.cursor()
        try:
            if params:
                cursor.execute(sql, params)
            else:
                cursor.execute(sql)
            
            if fetch:
                columns = [column[0] for column in cursor.description]
                results = []
                for row in cursor.fetchall():
                    results.append(dict(zip(columns, row)))
                return results
            else:
                conn.commit()
                return None
                
        except Exception as e:
            conn.rollback()
            raise RuntimeError(f"SQL-Fehler: {e}\nQuery: {sql}")
        finally:
            cursor.close()
    
    def get_table_data(self, table_name: str, where: str = None, limit: int = None) -> List[Dict]:
        """Liest Daten aus Tabelle"""
        sql = f"SELECT "
        if limit:
            sql += f"TOP {limit} "
        sql += f"* FROM [{table_name}]"
        
        if where:
            sql += f" WHERE {where}"
        
        return self.execute_sql(sql)
    
    def insert_record(self, table_name: str, data: Dict) -> None:
        """Fügt Datensatz in Tabelle ein"""
        fields = ", ".join([f"[{k}]" for k in data.keys()])
        placeholders = ", ".join(["?" for _ in data])
        sql = f"INSERT INTO [{table_name}] ({fields}) VALUES ({placeholders})"
        
        self.execute_sql(sql, tuple(data.values()), fetch=False)
    
    def update_record(self, table_name: str, data: Dict, where: str) -> None:
        """Aktualisiert Datensatz"""
        set_clause = ", ".join([f"[{k}] = ?" for k in data.keys()])
        sql = f"UPDATE [{table_name}] SET {set_clause} WHERE {where}"
        
        self.execute_sql(sql, tuple(data.values()), fetch=False)
    
    def delete_record(self, table_name: str, where: str) -> None:
        """Löscht Datensatz(e)"""
        sql = f"DELETE FROM [{table_name}] WHERE {where}"
        self.execute_sql(sql, fetch=False)
    
    # ==================== FORMULAR-OPERATIONEN ====================
    # (Funktionieren auch mit laufender Access-Instanz!)
    
    def open_form(self, form_name: str, view: int = 0, where: str = None, 
                  data_mode: int = 1, window_mode: int = 0) -> None:
        """Öffnet ein Formular"""
        try:
            self.access_app.DoCmd.OpenForm(form_name, view, "", where, data_mode, window_mode)
            print(f"✓ Formular '{form_name}' geöffnet")
        except Exception as e:
            raise RuntimeError(f"Fehler beim Öffnen: {e}")
    
    def close_form(self, form_name: str, save: int = 1) -> None:
        """Schließt ein Formular"""
        try:
            self.access_app.DoCmd.Close(2, form_name, save)
            print(f"✓ Formular '{form_name}' geschlossen")
        except Exception as e:
            raise RuntimeError(f"Fehler beim Schließen: {e}")
    
    def get_form_control_value(self, form_name: str, control_name: str) -> Any:
        """Liest Wert eines Formular-Steuerelements"""
        try:
            form = self.access_app.Forms(form_name)
            return form.Controls(control_name).Value
        except Exception as e:
            raise RuntimeError(f"Fehler beim Lesen: {e}")
    
    def set_form_control_value(self, form_name: str, control_name: str, value: Any) -> None:
        """Setzt Wert eines Formular-Steuerelements"""
        try:
            form = self.access_app.Forms(form_name)
            form.Controls(control_name).Value = value
            print(f"✓ Wert gesetzt: {control_name} = {value}")
        except Exception as e:
            raise RuntimeError(f"Fehler beim Setzen: {e}")
    
    # ==================== VBA-OPERATIONEN ====================
    
    def run_vba_function(self, function_name: str, *args) -> Any:
        """Führt VBA-Funktion aus"""
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
    
    # ==================== REPORT-OPERATIONEN ====================
    
    def export_report_pdf(self, report_name: str, output_path: str, where: str = None) -> None:
        """Exportiert Report als PDF"""
        try:
            self.access_app.DoCmd.OpenReport(report_name, 0, "", where, 1)
            self.access_app.DoCmd.OutputTo(3, report_name, "PDF Format (*.pdf)", output_path, False)
            self.access_app.DoCmd.Close(3, report_name, 2)
            print(f"✓ PDF erstellt: {output_path}")
        except Exception as e:
            raise RuntimeError(f"PDF-Export fehlgeschlagen: {e}")
    
    # ==================== DATENBANK-INFO ====================
    
    def list_tables(self) -> List[str]:
        """Listet alle Tabellen auf"""
        conn = self._get_odbc_conn()
        cursor = conn.cursor()
        tables = []
        for row in cursor.tables(tableType='TABLE'):
            table_name = row.table_name
            if not table_name.startswith('MSys') and not table_name.startswith('~'):
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
            'reports_count': len(self.list_reports())
        }
        return info
    
    # ==================== UTILITY ====================
    
    def backup_database(self, backup_path: str) -> None:
        """Erstellt Backup der Datenbank"""
        import shutil
        
        # Backend sichern wenn verfügbar
        if os.path.exists(self.backend_path):
            backend_backup = backup_path.replace('.accdb', '_backend.accdb')
            shutil.copy2(self.backend_path, backend_backup)
            print(f"✓ Backend-Backup: {backend_backup}")
        
        # Frontend sichern (wenn nicht gesperrt)
        if not self.is_frontend_locked:
            shutil.copy2(self.frontend_path, backup_path)
            print(f"✓ Frontend-Backup: {backup_path}")
        else:
            print("  ℹ Frontend gesperrt - nicht gesichert")


if __name__ == "__main__":
    print("Access Bridge - ENHANCED Version")
    print("Unterstützt parallele Frontend-Nutzung!")
    
    with AccessBridge() as bridge:
        info = bridge.get_database_info()
        print("\n=== Status ===")
        for key, value in info.items():
            print(f"{key}: {value}")
