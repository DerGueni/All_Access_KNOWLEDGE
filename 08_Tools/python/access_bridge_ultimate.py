"""
Access Bridge ULTIMATE - Vollautomatische Access-Steuerung
============================================================
WICHTIGE REGELN:
- Arbeitet NUR mit dem Test-Frontend: Consys_FE_N_Test_Claude_GPT.accdb
- Andere Frontends werden NIEMALS angefasst oder geschlossen!
- Neue Objekte IMMER mit Praefix "_N_": mod_N_xxx, qry_N_xxx, frm_N_xxx, tbl_N_xxx
- VBA-Module OHNE "Option Compare Database" und "Option Explicit" (VBA-Voreinstellung)
- DialogKiller laeuft automatisch - KEINE manuellen Eingriffe erforderlich

Verwendung:
    from access_bridge_ultimate import AccessBridge
    bridge = AccessBridge()
"""

import win32com.client
import pythoncom
import pyodbc
import os
import sys
import json
import subprocess
import time
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Union


class AccessBridgeUltimate:
    """
    Vollautomatische Access Bridge fuer Claude Code
    ================================================

    NAMENSKONVENTIONEN (WICHTIG!):
    - Formulare:  frm_N_xxx
    - Abfragen:   qry_N_xxx
    - Module:     mod_N_xxx
    - Tabellen:   tbl_N_xxx
    - Berichte:   rpt_N_xxx
    - Buttons:    btn_N_xxx

    ERLAUBTES FRONTEND:
    - NUR: Consys_FE_N_Test_Claude_GPT.accdb
    - Andere Frontends werden NICHT angefasst!
    """

    # Erlaubtes Frontend (NUR dieses darf bearbeitet werden!)
    ALLOWED_FRONTEND = "0_Consys_FE_Test.accdb"

    # Namenskonventionen fuer neue Objekte
    PREFIX_FORM = "frm_N_"
    PREFIX_QUERY = "qry_N_"
    PREFIX_MODULE = "mod_N_"
    PREFIX_TABLE = "tbl_N_"
    PREFIX_REPORT = "rpt_N_"
    PREFIX_BUTTON = "btn_N_"

    def __init__(self, config_path: str = None, auto_connect: bool = True):
        """
        Initialisiert die Bridge
        """
        self.bridge_dir = Path(__file__).parent

        if not config_path:
            config_path = self.bridge_dir / "config.json"

        with open(config_path, 'r', encoding='utf-8') as f:
            self.config = json.load(f)

        self.frontend_path = self.config['database']['frontend_path']
        self.backend_path = self.config['database']['backend_path']

        # Sicherheitspruefung: Nur erlaubtes Frontend!
        if self.ALLOWED_FRONTEND.lower() not in self.frontend_path.lower():
            raise RuntimeError(f"SICHERHEITSFEHLER: Nur {self.ALLOWED_FRONTEND} darf bearbeitet werden!")

        self.access_app = None
        self.current_db = None
        self.conn_backend = None
        self.is_connected = False
        self.dialog_killer_process = None
        self.last_error = None
        self._we_started_access = False  # Merken ob WIR Access gestartet haben

        if auto_connect:
            self.connect()

    def _start_dialog_killer(self):
        """Startet den Dialog Killer ULTIMATE im Hintergrund"""
        try:
            killer_script = self.bridge_dir / "DialogKillerPermanent.ps1"
            if not killer_script.exists():
                print(f"[!] DialogKiller nicht gefunden: {killer_script}")
                return

            minutes = self.config['bridge'].get('dialog_killer_minutes', 60)
            interval = self.config['bridge'].get('dialog_killer_interval', 50)
            cmd = [
                "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass",
                "-WindowStyle", "Hidden", "-File", str(killer_script),
                "-Minutes", str(minutes), "-IntervalMs", str(interval)
            ]
            self.dialog_killer_process = subprocess.Popen(
                cmd, creationflags=subprocess.CREATE_NO_WINDOW,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            print(f"[OK] DialogKiller ULTIMATE gestartet (PID: {self.dialog_killer_process.pid}, {interval}ms Intervall)")
            time.sleep(0.5)
        except Exception as e:
            print(f"[!] DialogKiller Start fehlgeschlagen: {e}")

    def _stop_dialog_killer(self):
        """Stoppt den Dialog Killer"""
        if self.dialog_killer_process:
            try:
                self.dialog_killer_process.terminate()
                self.dialog_killer_process.wait(timeout=2)
                print("[OK] DialogKiller gestoppt")
            except:
                try:
                    self.dialog_killer_process.kill()
                except:
                    pass

    def connect(self):
        """Stellt Verbindung her - NUR zum erlaubten Frontend!"""
        try:
            print("=" * 60)
            print("ACCESS BRIDGE ULTIMATE")
            print(f"Erlaubtes Frontend: {self.ALLOWED_FRONTEND}")
            print("=" * 60)

            if self.config['bridge'].get('start_dialog_killer', True):
                self._start_dialog_killer()

            pythoncom.CoInitialize()
            self._connect_access()
            self._connect_backend()
            self._configure_silent_mode()

            self.is_connected = True
            print("=" * 60)
            print("[OK] BRIDGE VERBUNDEN")
            print("=" * 60)

        except Exception as e:
            self.last_error = str(e)
            raise ConnectionError(f"Verbindung fehlgeschlagen: {e}")

    def _connect_access(self):
        """Verbindet zu Access - NUR zum erlaubten Frontend!"""
        try:
            # Versuche laufende Instanz mit RICHTIGEM Frontend zu finden
            if self.config['bridge'].get('use_running_instance', True):
                try:
                    # Alle Access-Instanzen durchgehen
                    self.access_app = win32com.client.GetObject(Class="Access.Application")
                    current_db_name = self.access_app.CurrentDb().Name

                    # Pruefen ob es das ERLAUBTE Frontend ist
                    if self.ALLOWED_FRONTEND.lower() in current_db_name.lower():
                        print(f"[OK] Laufende Instanz mit korrektem Frontend gefunden")
                        self.current_db = self.access_app.CurrentDb()
                        self._we_started_access = False
                        return
                    else:
                        # FALSCHE Datenbank - NICHT verwenden!
                        print(f"[!] Laufende Instanz hat anderes Frontend: {os.path.basename(current_db_name)}")
                        print(f"    -> Starte NEUE Instanz fuer {self.ALLOWED_FRONTEND}")
                        self.access_app = None
                except:
                    pass

            # Neue Instanz starten
            self.access_app = win32com.client.Dispatch("Access.Application")
            self.access_app.Visible = self.config['bridge'].get('access_visible', True)
            self.access_app.UserControl = True
            self._we_started_access = True

            print(f"[...] Oeffne: {self.frontend_path}")
            self.access_app.OpenCurrentDatabase(self.frontend_path, False)
            time.sleep(2)

            self.current_db = self.access_app.CurrentDb()
            print(f"[OK] Access-Verbindung hergestellt")

        except Exception as e:
            raise RuntimeError(f"Access COM-Fehler: {e}")

    def _connect_backend(self):
        """Verbindet zum Backend via ODBC"""
        try:
            conn_str = (
                r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
                f'DBQ={self.backend_path};'
            )
            self.conn_backend = pyodbc.connect(conn_str)
            print(f"[OK] ODBC Backend verbunden")
        except Exception as e:
            print(f"[!] ODBC Backend nicht verfuegbar: {e}")

    def _configure_silent_mode(self):
        """Konfiguriert Access fuer stille Operation"""
        try:
            self.access_app.DoCmd.SetWarnings(False)
            try:
                self.access_app.SetOption("Confirm Record Changes", False)
                self.access_app.SetOption("Confirm Document Deletions", False)
                self.access_app.SetOption("Confirm Action Queries", False)
            except:
                pass
            print("[OK] Silent Mode aktiviert")
        except Exception as e:
            print(f"[!] Silent Mode Warnung: {e}")

    def disconnect(self):
        """Trennt Verbindung - schliesst NUR unsere eigene Access-Instanz!"""
        try:
            self._stop_dialog_killer()

            if self.conn_backend:
                self.conn_backend.close()

            # NUR schliessen wenn WIR Access gestartet haben!
            if self.access_app and self._we_started_access:
                try:
                    self.access_app.DoCmd.SetWarnings(True)
                    self.access_app.CloseCurrentDatabase()
                    self.access_app.Quit()
                    print("[OK] Unsere Access-Instanz geschlossen")
                except:
                    pass
            else:
                print("[OK] Laufende Access-Instanz bleibt offen")

            pythoncom.CoUninitialize()
            self.is_connected = False
            print("[OK] Verbindung getrennt")

        except Exception as e:
            print(f"[!] Warnung beim Trennen: {e}")

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()

    # ================================================================
    # HILFSMETHODEN FUER NAMENSKONVENTIONEN
    # ================================================================

    def _strip_vba_options(self, code: str) -> str:
        """
        Entfernt Option Compare Database und Option Explicit aus VBA-Code
        (Diese sind in VBA voreingestellt und wuerden sonst doppelt sein)
        """
        lines = code.split('\n')
        filtered_lines = []
        for line in lines:
            stripped = line.strip().lower()
            if stripped.startswith('option compare') or stripped.startswith('option explicit'):
                continue  # Diese Zeilen ueberspringen
            filtered_lines.append(line)
        return '\n'.join(filtered_lines)

    def _ensure_prefix(self, name: str, prefix: str) -> str:
        """Stellt sicher dass der Name das richtige Praefix hat"""
        if not name.startswith(prefix):
            # Pruefe ob es ein anderes bekanntes Praefix hat
            prefixes = [self.PREFIX_FORM, self.PREFIX_QUERY, self.PREFIX_MODULE,
                       self.PREFIX_TABLE, self.PREFIX_REPORT, self.PREFIX_BUTTON]
            for p in prefixes:
                if name.startswith(p):
                    return name  # Hat bereits ein Praefix
            return prefix + name
        return name

    # ================================================================
    # ABFRAGEN
    # ================================================================

    def create_query(self, name: str, sql: str, auto_prefix: bool = True) -> bool:
        """
        Erstellt oder aktualisiert eine Abfrage

        Args:
            name: Name (wird automatisch mit qry_N_ prefixiert wenn auto_prefix=True)
            sql: SQL-Statement
            auto_prefix: Automatisch qry_N_ voranstellen (default: True)
        """
        try:
            if auto_prefix:
                name = self._ensure_prefix(name, self.PREFIX_QUERY)

            exists = False
            for qdef in self.current_db.QueryDefs:
                if qdef.Name == name:
                    qdef.SQL = sql
                    exists = True
                    print(f"[OK] Abfrage aktualisiert: {name}")
                    break

            if not exists:
                self.current_db.CreateQueryDef(name, sql)
                print(f"[OK] Abfrage erstellt: {name}")

            return True
        except Exception as e:
            self.last_error = str(e)
            print(f"[!] Abfrage-Fehler: {e}")
            return False

    def delete_query(self, name: str) -> bool:
        """Loescht eine Abfrage"""
        try:
            self.access_app.DoCmd.DeleteObject(5, name)
            print(f"[OK] Abfrage geloescht: {name}")
            return True
        except Exception as e:
            self.last_error = str(e)
            return False

    def execute_sql(self, sql: str, params: tuple = None, fetch: bool = True) -> Optional[List[Dict]]:
        """Fuehrt SQL aus (via ODBC auf Backend)"""
        try:
            cursor = self.conn_backend.cursor()
            if params:
                cursor.execute(sql, params)
            else:
                cursor.execute(sql)

            if fetch:
                columns = [col[0] for col in cursor.description]
                results = [dict(zip(columns, row)) for row in cursor.fetchall()]
                cursor.close()
                return results
            else:
                self.conn_backend.commit()
                cursor.close()
                return None
        except Exception as e:
            self.last_error = str(e)
            if not fetch:
                self.conn_backend.rollback()
            raise RuntimeError(f"SQL-Fehler: {e}")

    # ================================================================
    # FORMULARE
    # ================================================================

    def create_form(self, name: str, record_source: str = None,
                   default_view: int = 2, allow_edits: bool = False,
                   auto_prefix: bool = True) -> bool:
        """
        Erstellt ein neues Formular

        Args:
            name: Name (wird automatisch mit frm_N_ prefixiert)
            record_source: Tabelle oder Abfrage
            default_view: 0=Einzelformular, 2=Datenblatt
            auto_prefix: Automatisch frm_N_ voranstellen
        """
        try:
            if auto_prefix:
                name = self._ensure_prefix(name, self.PREFIX_FORM)

            self.delete_form(name)

            new_form = self.access_app.CreateForm()
            temp_name = new_form.Name

            if record_source:
                new_form.RecordSource = record_source
            new_form.DefaultView = default_view
            new_form.AllowAdditions = False
            new_form.AllowDeletions = False
            new_form.AllowEdits = allow_edits
            new_form.NavigationButtons = False
            new_form.RecordSelectors = False

            self.access_app.DoCmd.Close(2, temp_name, 1)
            self.access_app.DoCmd.Rename(name, 2, temp_name)

            print(f"[OK] Formular erstellt: {name}")
            return True
        except Exception as e:
            self.last_error = str(e)
            print(f"[!] Formular-Fehler: {e}")
            return False

    def delete_form(self, name: str) -> bool:
        """Loescht ein Formular (wenn vorhanden)"""
        try:
            for doc in self.access_app.CurrentProject.AllForms:
                if doc.Name == name:
                    self.access_app.DoCmd.Close(2, name, 2)
                    self.access_app.DoCmd.DeleteObject(2, name)
                    return True
            return True
        except:
            return True

    def add_control_to_form(self, form_name: str, control_type: int,
                           section: int, left: int, top: int,
                           width: int, height: int, **properties) -> bool:
        """
        Fuegt ein Steuerelement zu einem Formular hinzu

        Control Types:
            100=Label, 109=TextBox, 111=ComboBox, 112=Subform, 104=Button
        Sections:
            0=Detail, 1=Header, 2=Footer
        """
        try:
            # acDesign = 1 (nicht 0!)
            self.access_app.DoCmd.OpenForm(form_name, 1)
            time.sleep(0.3)  # Warten bis Formular bereit

            ctl = self.access_app.CreateControl(
                form_name, control_type, section, "", "", left, top, width, height
            )
            for prop, value in properties.items():
                try:
                    setattr(ctl, prop, value)
                except:
                    pass

            # acForm = 2, acSaveYes = 1
            self.access_app.DoCmd.Close(2, form_name, 1)
            return True
        except Exception as e:
            self.last_error = str(e)
            print(f"[!] Control-Fehler: {e}")
            # Versuche Formular zu schliessen
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)  # acSaveNo
            except:
                pass
            return False

    # ================================================================
    # VBA MODULE
    # ================================================================

    def import_vba_module(self, module_name: str, code: str, auto_prefix: bool = True) -> bool:
        """
        Importiert VBA-Code als Modul

        WICHTIG: Option Compare Database und Option Explicit werden
        automatisch entfernt (sind in VBA voreingestellt)!

        Args:
            module_name: Name (wird automatisch mit mod_N_ prefixiert)
            code: VBA-Code
            auto_prefix: Automatisch mod_N_ voranstellen
        """
        try:
            if auto_prefix:
                module_name = self._ensure_prefix(module_name, self.PREFIX_MODULE)

            # WICHTIG: Option-Zeilen entfernen!
            code = self._strip_vba_options(code)

            vbe = self.access_app.VBE
            proj = vbe.ActiveVBProject

            comp = None
            for c in proj.VBComponents:
                if c.Name == module_name:
                    comp = c
                    code_module = comp.CodeModule
                    if code_module.CountOfLines > 0:
                        code_module.DeleteLines(1, code_module.CountOfLines)
                    break

            if not comp:
                comp = proj.VBComponents.Add(1)
                comp.Name = module_name

            code_module = comp.CodeModule
            code_module.AddFromString(code)

            print(f"[OK] VBA-Modul importiert: {module_name}")
            return True
        except Exception as e:
            self.last_error = str(e)
            print(f"[!] VBA-Fehler: {e}")
            return False

    def import_vba_from_file(self, bas_file_path: str) -> bool:
        """Importiert ein .bas Modul direkt"""
        try:
            vbe = self.access_app.VBE
            proj = vbe.ActiveVBProject
            proj.VBComponents.Import(bas_file_path)
            print(f"[OK] VBA-Datei importiert: {bas_file_path}")
            return True
        except Exception as e:
            self.last_error = str(e)
            print(f"[!] VBA-Import-Fehler: {e}")
            return False

    def run_vba_function(self, function_name: str, *args) -> Any:
        """Fuehrt eine VBA-Funktion aus"""
        try:
            return self.access_app.Run(function_name, *args)
        except Exception as e:
            self.last_error = str(e)
            raise RuntimeError(f"VBA-Ausfuehrungsfehler: {e}")

    # ================================================================
    # HILFSMETHODEN
    # ================================================================

    def list_forms(self) -> List[str]:
        """Listet alle Formulare"""
        return sorted([doc.Name for doc in self.access_app.CurrentProject.AllForms])

    def list_queries(self) -> List[str]:
        """Listet alle Abfragen"""
        return sorted([q.Name for q in self.current_db.QueryDefs if not q.Name.startswith("~")])

    def list_tables(self) -> List[str]:
        """Listet alle Tabellen"""
        return sorted([t.Name for t in self.current_db.TableDefs
                      if not t.Name.startswith("MSys") and not t.Name.startswith("~")])

    def list_modules(self) -> List[str]:
        """Listet alle VBA-Module"""
        try:
            return sorted([c.Name for c in self.access_app.VBE.ActiveVBProject.VBComponents if c.Type == 1])
        except:
            return []

    def form_exists(self, name: str) -> bool:
        """Prueft ob Formular existiert"""
        return any(doc.Name == name for doc in self.access_app.CurrentProject.AllForms)

    def query_exists(self, name: str) -> bool:
        """Prueft ob Abfrage existiert"""
        return any(q.Name == name for q in self.current_db.QueryDefs)

    def module_exists(self, name: str) -> bool:
        """Prueft ob Modul existiert"""
        return name in self.list_modules()

    def open_form(self, name: str, view: int = 0) -> bool:
        """Oeffnet ein Formular (0=Normal, 1=Design)"""
        try:
            self.access_app.DoCmd.OpenForm(name, view)
            return True
        except Exception as e:
            self.last_error = str(e)
            return False

    def close_form(self, name: str, save: bool = True) -> bool:
        """Schliesst ein Formular"""
        try:
            # acForm = 2, acSaveYes = 1, acSaveNo = 2
            self.access_app.DoCmd.Close(2, name, 1 if save else 2)
            return True
        except Exception as e:
            self.last_error = str(e)
            return False

    # ================================================================
    # ERWEITERTE FORMULAR-BEARBEITUNG
    # ================================================================

    def get_form_property(self, form_name: str, property_name: str) -> Any:
        """Liest eine Formular-Eigenschaft"""
        try:
            self.access_app.DoCmd.OpenForm(form_name, 1)  # Design View
            time.sleep(0.2)
            frm = self.access_app.Forms(form_name)
            value = getattr(frm, property_name, None)
            self.access_app.DoCmd.Close(2, form_name, 2)  # Ohne Speichern
            return value
        except Exception as e:
            self.last_error = str(e)
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)
            except:
                pass
            return None

    def set_form_property(self, form_name: str, property_name: str, value: Any) -> bool:
        """Setzt eine Formular-Eigenschaft"""
        try:
            self.access_app.DoCmd.OpenForm(form_name, 1)  # Design View
            time.sleep(0.2)
            frm = self.access_app.Forms(form_name)
            setattr(frm, property_name, value)
            self.access_app.DoCmd.Close(2, form_name, 1)  # Mit Speichern
            return True
        except Exception as e:
            self.last_error = str(e)
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)
            except:
                pass
            return False

    def get_form_controls(self, form_name: str) -> List[Dict]:
        """Listet alle Controls eines Formulars"""
        try:
            self.access_app.DoCmd.OpenForm(form_name, 1)  # Design View
            time.sleep(0.2)
            frm = self.access_app.Forms(form_name)

            controls = []
            for ctl in frm.Controls:
                try:
                    controls.append({
                        'name': ctl.Name,
                        'type': ctl.ControlType,
                        'left': ctl.Left,
                        'top': ctl.Top,
                        'width': ctl.Width,
                        'height': ctl.Height
                    })
                except:
                    pass

            self.access_app.DoCmd.Close(2, form_name, 2)  # Ohne Speichern
            return controls
        except Exception as e:
            self.last_error = str(e)
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)
            except:
                pass
            return []

    def control_exists(self, form_name: str, control_name: str) -> bool:
        """Prueft ob ein Control in einem Formular existiert"""
        controls = self.get_form_controls(form_name)
        return any(c['name'] == control_name for c in controls)

    def add_button_to_form(self, form_name: str, button_name: str,
                          caption: str, left: int, top: int,
                          width: int = 1500, height: int = 400,
                          on_click: str = None, section: int = 0) -> bool:
        """
        Fuegt einen Button zu einem Formular hinzu

        Args:
            form_name: Name des Formulars
            button_name: Name des Buttons
            caption: Beschriftung
            left: Position links (in Twips, 1440 Twips = 1 Inch)
            top: Position oben
            width: Breite (default 1500)
            height: Hoehe (default 400)
            on_click: OnClick Event Expression (z.B. "=MeineFunktion()")
            section: 0=Detail, 1=Header, 2=Footer
        """
        try:
            # Pruefe ob Button bereits existiert
            if self.control_exists(form_name, button_name):
                print(f"[=] Button '{button_name}' existiert bereits in {form_name}")
                return True

            # Formular in Design-Ansicht oeffnen
            self.access_app.DoCmd.OpenForm(form_name, 1)
            time.sleep(0.3)

            # Button erstellen (acCommandButton = 104)
            ctl = self.access_app.CreateControl(
                form_name, 104, section, "", "", left, top, width, height
            )
            ctl.Name = button_name
            ctl.Caption = caption

            # Farben setzen (Royalblau)
            try:
                ctl.BackColor = 4286945  # RGB(65, 105, 225) = #4169E1
                ctl.ForeColor = 16777215  # Weiss
                ctl.FontBold = True
                ctl.FontSize = 9
            except:
                pass

            # OnClick Event
            if on_click:
                try:
                    ctl.OnClick = on_click
                except:
                    pass

            # Speichern und schliessen
            self.access_app.DoCmd.Close(2, form_name, 1)
            print(f"[OK] Button '{button_name}' zu {form_name} hinzugefuegt")
            return True

        except Exception as e:
            self.last_error = str(e)
            print(f"[!] Button-Fehler bei {form_name}: {e}")
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)
            except:
                pass
            return False

    def add_webbrowser_to_form(self, form_name: str, control_name: str = "ctlHTMLOverlay",
                               left: int = 0, top: int = 0,
                               width: int = 15000, height: int = 10000,
                               visible: bool = False, section: int = 0) -> bool:
        """
        Fuegt ein WebBrowser ActiveX Control zu einem Formular hinzu

        Args:
            form_name: Name des Formulars
            control_name: Name des Controls (default: ctlHTMLOverlay)
            left, top: Position
            width, height: Groesse
            visible: Sichtbar (default: False fuer Overlay)
            section: 0=Detail
        """
        try:
            # Pruefe ob Control bereits existiert
            if self.control_exists(form_name, control_name):
                print(f"[=] WebBrowser '{control_name}' existiert bereits in {form_name}")
                return True

            # Formular in Design-Ansicht oeffnen
            self.access_app.DoCmd.OpenForm(form_name, 1)
            time.sleep(0.3)

            # ActiveX Control erstellen (acObjectFrame = 114)
            # Fuer WebBrowser benoetigen wir acCustomControl = 119
            try:
                # Versuche ueber CreateControl mit ActiveX
                frm = self.access_app.Forms(form_name)

                # WebBrowser Class ID: {8856F961-340A-11D0-A96B-00C04FD705A2}
                # oder Shell.Explorer.2

                # Alternative: Ungebundenes Objekt-Frame mit OLE
                ctl = self.access_app.CreateControl(
                    form_name, 114, section, "", "", left, top, width, height
                )
                ctl.Name = control_name

                # Versuche OLE Class zu setzen
                try:
                    ctl.OLEClass = "Shell.Explorer.2"
                except:
                    pass

                try:
                    ctl.Visible = visible
                except:
                    pass

                # Speichern
                self.access_app.DoCmd.Close(2, form_name, 1)
                print(f"[OK] WebBrowser '{control_name}' zu {form_name} hinzugefuegt")
                return True

            except Exception as inner_e:
                print(f"[!] WebBrowser CreateControl fehlgeschlagen: {inner_e}")
                self.access_app.DoCmd.Close(2, form_name, 2)
                return False

        except Exception as e:
            self.last_error = str(e)
            print(f"[!] WebBrowser-Fehler bei {form_name}: {e}")
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)
            except:
                pass
            return False

    def add_form_module_code(self, form_name: str, code: str, append: bool = True) -> bool:
        """
        Fuegt VBA-Code zum Klassenmodul eines Formulars hinzu

        Args:
            form_name: Name des Formulars
            code: VBA-Code (ohne Option-Zeilen)
            append: True = an bestehenden Code anhaengen, False = ersetzen
        """
        try:
            # Option-Zeilen entfernen
            code = self._strip_vba_options(code)

            # Formular in Design-Ansicht oeffnen
            self.access_app.DoCmd.OpenForm(form_name, 1)
            time.sleep(0.3)

            # Zugriff auf VBE
            vbe = self.access_app.VBE
            proj = vbe.ActiveVBProject

            # Formular-Modul finden (Type 100 = vbext_ct_Document)
            form_module = None
            for comp in proj.VBComponents:
                if comp.Type == 100:  # Document/Form
                    # Pruefe ob es das richtige Formular ist
                    if form_name in comp.Name or comp.Name == "Form_" + form_name:
                        form_module = comp
                        break

            if not form_module:
                # Manchmal hat das Formular noch kein Modul - einfach HasModule setzen
                try:
                    frm = self.access_app.Forms(form_name)
                    frm.HasModule = True
                    time.sleep(0.2)
                    # Nochmal suchen
                    for comp in proj.VBComponents:
                        if comp.Type == 100 and (form_name in comp.Name or comp.Name == "Form_" + form_name):
                            form_module = comp
                            break
                except:
                    pass

            if form_module:
                code_module = form_module.CodeModule

                if append:
                    # Am Ende anhaengen
                    line_count = code_module.CountOfLines
                    code_module.InsertLines(line_count + 1, "\n" + code)
                else:
                    # Alles ersetzen (ausser Declarations)
                    if code_module.CountOfDeclarationLines > 0:
                        start = code_module.CountOfDeclarationLines + 1
                        if code_module.CountOfLines >= start:
                            code_module.DeleteLines(start, code_module.CountOfLines - start + 1)
                    code_module.InsertLines(code_module.CountOfLines + 1, code)

                print(f"[OK] VBA-Code zu {form_name} hinzugefuegt")
            else:
                print(f"[!] Formular-Modul fuer {form_name} nicht gefunden")

            # Speichern und schliessen
            self.access_app.DoCmd.Close(2, form_name, 1)
            return True

        except Exception as e:
            self.last_error = str(e)
            print(f"[!] Form-Code-Fehler bei {form_name}: {e}")
            try:
                self.access_app.DoCmd.Close(2, form_name, 2)
            except:
                pass
            return False

    def setup_html_view_switch(self, form_name: str, html_file: str,
                               button_position: tuple = None) -> bool:
        """
        Richtet den kompletten HTML-Ansicht-Wechsel fuer ein Formular ein

        Args:
            form_name: Name des Access-Formulars
            html_file: Name der HTML-Datei (ohne Pfad)
            button_position: (left, top) oder None fuer automatisch oben rechts

        Fuegt hinzu:
        - Button "HTML Ansicht" oben rechts
        - WebBrowser Control "ctlHTMLOverlay" (unsichtbar)
        - VBA-Code fuer Button-Click und Browser-Events
        """
        print(f"\n[...] Richte HTML-Ansicht-Wechsel ein fuer: {form_name}")

        # 1. Button hinzufuegen
        if button_position:
            btn_left, btn_top = button_position
        else:
            # Versuche Formularbreite zu ermitteln, sonst Standard
            btn_left = 12000  # Ca. rechts bei Standard-Formular
            btn_top = 100

        success = self.add_button_to_form(
            form_name=form_name,
            button_name="btnHTMLAnsicht",
            caption="HTML Ansicht",
            left=btn_left,
            top=btn_top,
            width=1500,
            height=400,
            on_click="=HTML_Ansicht_Button_Click([Form])",
            section=1  # Header
        )

        if not success:
            # Versuche in Detail-Section
            success = self.add_button_to_form(
                form_name=form_name,
                button_name="btnHTMLAnsicht",
                caption="HTML Ansicht",
                left=btn_left,
                top=btn_top,
                width=1500,
                height=400,
                on_click="=HTML_Ansicht_Button_Click([Form])",
                section=0  # Detail
            )

        # 2. WebBrowser Control hinzufuegen (optional, fuer Overlay-Modus)
        # self.add_webbrowser_to_form(form_name)

        return success

    def setup_all_html_forms(self, form_mapping: Dict[str, str]) -> Dict[str, bool]:
        """
        Richtet HTML-Ansicht-Wechsel fuer mehrere Formulare ein

        Args:
            form_mapping: Dict von Access-Formularname -> HTML-Dateiname

        Returns:
            Dict mit Ergebnissen pro Formular
        """
        results = {}

        for form_name, html_file in form_mapping.items():
            # Pruefe ob Formular existiert
            if self.form_exists(form_name):
                results[form_name] = self.setup_html_view_switch(form_name, html_file)
            else:
                print(f"[!] Formular nicht gefunden: {form_name}")
                results[form_name] = False

        return results


# Alias
AccessBridge = AccessBridgeUltimate


def main():
    """Test der Bridge"""
    print("\n" + "=" * 60)
    print("ACCESS BRIDGE ULTIMATE - SELBSTTEST")
    print("=" * 60)
    print(f"Erlaubtes Frontend: {AccessBridge.ALLOWED_FRONTEND}")
    print(f"Praefixe: frm_N_, qry_N_, mod_N_, tbl_N_, rpt_N_")
    print("=" * 60 + "\n")

    with AccessBridge() as bridge:
        print(f"\nFormulare: {len(bridge.list_forms())}")
        print(f"Abfragen: {len(bridge.list_queries())}")
        print(f"Module: {len(bridge.list_modules())}")
        print("\n[OK] TEST ERFOLGREICH")


if __name__ == "__main__":
    main()
