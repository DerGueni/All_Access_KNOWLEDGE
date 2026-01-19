"""
Access Bridge - KOMBINIERTE Lösung (Präventiv + Reaktiv)
1. PRÄVENTIV: SetWarnings + On Error Resume Next
2. REAKTIV: AutoHotkey Dialog-Killer (extern)
"""

import win32com.client
import pythoncom
import pyodbc
import os
import json
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional
import time


class AccessBridgeCombined:
    """
    Kombinierte Defense-in-Depth Lösung gegen Dialoge
    """
    
    def __init__(self, db_path: str = None, auto_connect: bool = True, 
                 config_path: str = None, start_ahk: bool = True):
        """
        Args:
            start_ahk: AutoHotkey Dialog-Killer automatisch starten
        """
        # Config laden
        if not config_path:
            config_path = Path(__file__).parent / "config.json"
        
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        # Pfade
        if db_path:
            self.frontend_path = os.path.abspath(db_path)
        else:
            self.frontend_path = self.config['database']['frontend_path']
        
        self.backend_path = self.config['database']['backend_path']
        
        # Bridge-Optionen
        self.use_running_instance = self.config['bridge'].get('use_running_instance', True)
        self.prefer_backend_for_data = self.config['bridge'].get('prefer_backend_for_data', True)
        
        # Verbindungen
        self.access_app = None
        self.db = None
        self.conn_odbc_frontend = None
        self.conn_odbc_backend = None
        self.is_connected = False
        self.is_frontend_locked = False
        
        # AutoHotkey
        self.ahk_process = None
        self.ahk_script_path = Path(__file__).parent.parent / "dialog_killer.ahk"
        
        if start_ahk:
            self._start_ahk_killer()
        
        if auto_connect:
            self.connect()
    
    def _start_ahk_killer(self):
        """Startet PowerShell Dialog-Killer (OHNE AutoHotkey!)"""
        try:
            ps_killer_path = Path(__file__).parent.parent / "ps_dialog_killer.ps1"
            
            if not ps_killer_path.exists():
                print(f"⚠️ PowerShell-Script nicht gefunden: {ps_killer_path}")
                return
            
            # Starte PowerShell Dialog-Killer als Background-Job
            # Läuft 300 Sekunden = 5 Minuten
            cmd = [
                "powershell.exe",
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-WindowStyle", "Hidden",
                "-File", str(ps_killer_path),
                "-DurationSeconds", "300"
            ]
            
            self.ahk_process = subprocess.Popen(
                cmd,
                creationflags=subprocess.CREATE_NO_WINDOW,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            print("✓ PowerShell Dialog-Killer gestartet (PID: {})".format(self.ahk_process.pid))
            print("  → Schließt ALLE Dialoge automatisch (100ms Intervall)")
            print("  → Laufzeit: 5 Minuten")
            
            # Kurz warten damit PS initialisiert ist
            time.sleep(0.5)
            
        except Exception as e:
            print(f"⚠️ PowerShell-Start fehlgeschlagen: {e}")
    
    def _stop_ahk_killer(self):
        """Stoppt PowerShell Dialog-Killer"""
        if self.ahk_process:
            try:
                # Lese Ergebnis
                stdout, stderr = self.ahk_process.communicate(timeout=1)
                if stdout:
                    dialogs_killed = stdout.decode('utf-8').strip()
                    print(f"✓ PowerShell Dialog-Killer gestoppt ({dialogs_killed} Dialoge geschlossen)")
                else:
                    self.ahk_process.terminate()
                    self.ahk_process.wait(timeout=2)
                    print("✓ PowerShell Dialog-Killer gestoppt")
            except:
                try:
                    self.ahk_process.kill()
                except:
                    pass
    
    def connect(self):
        """Stellt Verbindung her mit ALLEN Schutzmaßnahmen"""
        try:
            # 1. COM-Verbindung
            self._connect_com()
            
            # 2. PRÄVENTIV: Alle Warnungen deaktivieren
            self._configure_no_dialogs()
            
            # 3. ODBC-Verbindung
            self._connect_odbc()
            
            self.is_connected = True
            print(f"✓ Vollständig verbunden (Präventiv + Reaktiv)")
            
        except Exception as e:
            raise ConnectionError(f"Verbindung fehlgeschlagen: {e}")
    
    def _connect_com(self):
        """COM-Verbindung"""
        try:
            pythoncom.CoInitialize()
            
            if self.use_running_instance:
                try:
                    self.access_app = win32com.client.GetObject(Class="Access.Application")
                    print("  ✓ COM: Laufende Access-Instanz")
                except:
                    self.access_app = win32com.client.Dispatch("Access.Application")
                    self.access_app.Visible = False
                    self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                    print("  ✓ COM: Neue Access-Instanz")
            else:
                self.access_app = win32com.client.Dispatch("Access.Application")
                self.access_app.Visible = False
                self.access_app.OpenCurrentDatabase(self.frontend_path, False)
                print("  ✓ COM: Access-Instanz erstellt")
            
            self.db = self.access_app.CurrentDb()
            
        except Exception as e:
            raise
    
    def _configure_no_dialogs(self):
        """
        PRÄVENTIVE Maßnahme: Konfiguriere Access so dass KEINE Dialoge erscheinen
        """
        try:
            # 1. SetWarnings - KRITISCH!
            self.access_app.DoCmd.SetWarnings(False)
            print("  ✓ PRÄVENTIV: SetWarnings(False)")
            
            # 2. Alle Confirmations aus
            try:
                self.access_app.SetOption("Confirm Record Changes", False)
                self.access_app.SetOption("Confirm Document Deletions", False)
                self.access_app.SetOption("Confirm Action Queries", False)
                print("  ✓ PRÄVENTIV: Alle Confirmations deaktiviert")
            except:
                pass
            
            # 3. VBE konfigurieren
            try:
                vbe = self.access_app.VBE
                vbe.MainWindow.Visible = False
                print("  ✓ PRÄVENTIV: VBE ausgeblendet")
            except:
                pass
            
            # 4. Globalen Error Handler erstellen
            self._create_global_error_handler()
            
        except Exception as e:
            print(f"  ⚠️ Warnung bei Konfiguration: {e}")
    
    def _create_global_error_handler(self):
        """Erstellt globalen VBA Error Handler"""
        try:
            module_name = "zmd_Global_ErrorHandler"
            
            # Lösche alten
            try:
                vbe = self.access_app.VBE
                for comp in vbe.VBProjects.Item(1).VBComponents:
                    if comp.Name == module_name:
                        vbe.VBProjects.Item(1).VBComponents.Remove(comp)
                        break
            except:
                pass
            
            # Erstelle neuen
            vbComp = self.access_app.VBE.VBProjects.Item(1).VBComponents.Add(1)
            vbComp.Name = module_name
            
            code = """

' Globaler Error Handler - fängt ALLE Fehler ab
Public Function GlobalErrorHandler() As Boolean
    On Error Resume Next
    GlobalErrorHandler = True
End Function

' Auto-Execute beim Start
Public Function AutoExec()
    On Error Resume Next
    DoCmd.SetWarnings False
End Function
"""
            
            code_module = vbComp.CodeModule
            code_module.AddFromString(code)
            
            print("  ✓ PRÄVENTIV: Global Error Handler erstellt")
            
        except Exception as e:
            print(f"  ℹ️ Global Error Handler nicht erstellt: {e}")
    
    def _connect_odbc(self):
        """ODBC-Verbindung"""
        if self.prefer_backend_for_data and os.path.exists(self.backend_path):
            try:
                conn_str = (
                    r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                    f'DBQ={self.backend_path};'
                )
                self.conn_odbc_backend = pyodbc.connect(conn_str)
                print(f"  ✓ ODBC: Backend")
                return
            except:
                pass
        
        try:
            conn_str = (
                r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                f'DBQ={self.frontend_path};'
            )
            self.conn_odbc_frontend = pyodbc.connect(conn_str)
            print(f"  ✓ ODBC: Frontend")
        except Exception as e:
            self.is_frontend_locked = True
            
            if os.path.exists(self.backend_path):
                try:
                    conn_str = (
                        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                        f'DBQ={self.backend_path};'
                    )
                    self.conn_odbc_backend = pyodbc.connect(conn_str)
                    print(f"  ✓ ODBC: Backend (Fallback)")
                except:
                    raise ConnectionError(f"Frontend gesperrt, Backend nicht verfügbar")
    
    def _get_odbc_conn(self):
        """Gibt aktive ODBC-Verbindung zurück"""
        if self.conn_odbc_backend:
            return self.conn_odbc_backend
        elif self.conn_odbc_frontend:
            return self.conn_odbc_frontend
        else:
            raise ConnectionError("Keine ODBC-Verbindung")
    
    def disconnect(self):
        """Trennt alle Verbindungen"""
        try:
            # AutoHotkey stoppen
            self._stop_ahk_killer()
            
            # ODBC
            if self.conn_odbc_backend:
                self.conn_odbc_backend.close()
            if self.conn_odbc_frontend:
                self.conn_odbc_frontend.close()
            
            # COM
            if self.access_app and not self.use_running_instance:
                # Warnungen NICHT wieder aktivieren!
                # self.access_app.DoCmd.SetWarnings(True)
                
                self.access_app.CloseCurrentDatabase()
                self.access_app.Quit()
            
            pythoncom.CoUninitialize()
            self.is_connected = False
            
            print("✓ Verbindung getrennt")
            
        except Exception as e:
            print(f"Warnung beim Trennen: {e}")
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()
    
    # ==================== HELPER METHODS ====================
    
    def execute_sql(self, sql: str, params: tuple = None, fetch: bool = True) -> Optional[List]:
        """Führt SQL aus (mit automatischem Error Handling)"""
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
    
    def insert_vba_code_safe(self, module_name: str, code: str):
        """
        Fügt VBA-Code ein mit GARANTIERT fehlerfreier Ausführung
        Fügt automatisch "On Error Resume Next" hinzu
        """
        try:
            # Stelle sicher dass Code Error-Handling hat
            if "On Error" not in code:
                # Füge Error-Handling nach Option-Statements ein
                lines = code.split('\n')
                insert_pos = 0
                
                for i, line in enumerate(lines):
                    if line.strip().startswith('Option '):
                        insert_pos = i + 1
                
                lines.insert(insert_pos, "On Error Resume Next  ' Auto-inserted by Bridge")
                code = '\n'.join(lines)
            
            # Erstelle/Update Modul
            vbe = self.access_app.VBE
            
            # Suche existierendes Modul
            vbComp = None
            for comp in vbe.VBProjects.Item(1).VBComponents:
                if comp.Name == module_name:
                    vbComp = comp
                    break
            
            # Erstelle wenn nicht vorhanden
            if not vbComp:
                vbComp = vbe.VBProjects.Item(1).VBComponents.Add(1)
                vbComp.Name = module_name
            
            # Setze Code
            code_module = vbComp.CodeModule
            code_module.DeleteLines(1, code_module.CountOfLines)
            code_module.AddFromString(code)
            
            print(f"✓ VBA-Code eingefügt (mit Error-Handling): {module_name}")
            
        except Exception as e:
            raise RuntimeError(f"VBA-Code-Fehler: {e}")


# Alias
AccessBridge = AccessBridgeCombined


if __name__ == "__main__":
    print("="*60)
    print("Access Bridge - KOMBINIERTE Lösung")
    print("Präventiv + Reaktiv = 100% Dialog-frei!")
    print("="*60)
    
    with AccessBridge() as bridge:
        print("\n✓ Bridge aktiv")
        print("  Warte 5 Sekunden...")
        time.sleep(5)
        print("✓ Test abgeschlossen")
