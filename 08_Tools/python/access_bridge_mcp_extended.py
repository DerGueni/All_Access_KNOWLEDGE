"""
ACCESS BRIDGE MCP SERVER - EXTENDED VERSION
============================================
Vollstaendiger MCP-Server fuer autonomes Arbeiten mit Microsoft Access Frontend.

Features:
- Formulare: Erstellen, Lesen, Bearbeiten, Steuerelemente hinzufuegen/aendern
- Berichte: Erstellen, Lesen, Bearbeiten, Unterbericht-Verwaltung
- Module: VBA-Code lesen/schreiben, Prozeduren hinzufuegen
- Tabellen: Struktur lesen, Daten abfragen/aendern
- Abfragen: SQL ausfuehren, Abfragen erstellen/bearbeiten
- Design-Aenderungen: Persistent via SaveAsText/LoadFromText
- Automatische Fehlerbehandlung ohne Dialoge

Autor: Claude Code / Access Bridge
Version: 2.0 Extended
"""

import os
import sys
import logging
import asyncio
import datetime
import tempfile
import json
from typing import List, Dict, Any, Optional

import pythoncom
import win32com.client

from mcp.server.fastmcp import FastMCP
from mcp.server.stdio import stdio_server

# -------------------------------------------------------------------
# KONFIGURATION
# -------------------------------------------------------------------
FRONTEND_PATH = os.environ.get(
    "ACCESS_FE_PATH",
    r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
)

LOG_TABLE_NAME = "tbl_MCP_Log"

# Access-Konstanten
AC_VIEW_NORMAL = 0
AC_VIEW_DESIGN = 1
AC_VIEW_PREVIEW = 2
AC_FORM = 2
AC_REPORT = 3
AC_MODULE = 5
AC_TABLE = 0
AC_QUERY = 1
AC_SAVE_YES = 1
AC_SAVE_NO = 2
AC_CMD_BUTTON = 104
AC_TEXT_BOX = 109
AC_LABEL = 100
AC_COMBO_BOX = 111
AC_LIST_BOX = 110
AC_CHECK_BOX = 106
AC_SUBFORM = 112
AC_SECTION_DETAIL = 0
AC_SECTION_HEADER = 1
AC_SECTION_FOOTER = 2

# MCP-Server-Instanz
mcp = FastMCP("access-bridge")

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


# -------------------------------------------------------------------
# HILFSFUNKTIONEN
# -------------------------------------------------------------------
class AccessConnection:
    """Context Manager fuer sichere Access-Verbindungen"""

    def __init__(self, visible: bool = False, exclusive: bool = False):
        self.visible = visible
        self.exclusive = exclusive
        self.app = None

    def __enter__(self):
        pythoncom.CoInitialize()
        self.app = win32com.client.Dispatch("Access.Application")
        self.app.Visible = self.visible

        try:
            self.app.OpenCurrentDatabase(FRONTEND_PATH, self.exclusive)
        except Exception as e:
            if self.exclusive:
                # Fallback: ohne exklusiv
                self.app.OpenCurrentDatabase(FRONTEND_PATH, False)
            else:
                raise

        try:
            self.app.DoCmd.SetWarnings(False)
        except:
            pass

        return self.app

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            if self.app:
                self.app.Quit()
        except:
            pass
        finally:
            pythoncom.CoUninitialize()
        return False


def generate_timestamp() -> str:
    return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")


def twips_to_cm(twips: int) -> float:
    """Konvertiert Twips zu Zentimetern (567 Twips = 1 cm)"""
    return round(twips / 567, 2)


def cm_to_twips(cm: float) -> int:
    """Konvertiert Zentimeter zu Twips"""
    return int(cm * 567)


# -------------------------------------------------------------------
# PING / STATUS
# -------------------------------------------------------------------
@mcp.tool()
def ping() -> str:
    """Verbindungstest - prueft ob Access erreichbar ist."""
    try:
        with AccessConnection(visible=False) as app:
            db_name = app.CurrentDb().Name
            return f"Access-Bridge OK. Datenbank: {db_name}"
    except Exception as e:
        return f"Fehler: {str(e)}"


@mcp.tool()
def get_database_info() -> Dict[str, Any]:
    """Gibt detaillierte Informationen ueber die Datenbank zurueck."""
    with AccessConnection() as app:
        db = app.CurrentDb()
        return {
            "name": db.Name,
            "path": FRONTEND_PATH,
            "forms_count": app.CurrentProject.AllForms.Count,
            "reports_count": app.CurrentProject.AllReports.Count,
            "tables_count": len([t for t in db.TableDefs if not t.Name.startswith("MSys")]),
            "queries_count": db.QueryDefs.Count,
            "modules_count": app.CurrentProject.AllModules.Count
        }


# -------------------------------------------------------------------
# FORMULARE
# -------------------------------------------------------------------
@mcp.tool()
def list_forms() -> List[str]:
    """Listet alle Formulare im Frontend auf."""
    with AccessConnection() as app:
        return [doc.Name for doc in app.CurrentProject.AllForms]


@mcp.tool()
def get_form_details(form_name: str) -> Dict[str, Any]:
    """Gibt detaillierte Informationen zu einem Formular zurueck."""
    with AccessConnection() as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            frm = app.Forms(form_name)

            controls = []
            for ctl in frm.Controls:
                try:
                    ctl_info = {
                        "name": ctl.Name,
                        "type": ctl.ControlType,
                        "left": ctl.Left,
                        "top": ctl.Top,
                        "width": ctl.Width,
                        "height": ctl.Height,
                        "visible": getattr(ctl, 'Visible', True)
                    }

                    # ControlSource wenn vorhanden
                    if hasattr(ctl, 'ControlSource'):
                        ctl_info["control_source"] = ctl.ControlSource

                    # Caption wenn vorhanden
                    if hasattr(ctl, 'Caption'):
                        ctl_info["caption"] = ctl.Caption

                    # OnClick wenn vorhanden
                    if hasattr(ctl, 'OnClick'):
                        ctl_info["on_click"] = ctl.OnClick

                    controls.append(ctl_info)
                except:
                    pass

            return {
                "name": form_name,
                "record_source": frm.RecordSource,
                "caption": getattr(frm, 'Caption', ''),
                "width": frm.Width,
                "controls_count": len(controls),
                "controls": controls
            }
        finally:
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_NO)


@mcp.tool()
def get_form_vba_code(form_name: str) -> str:
    """Liest den VBA-Code eines Formulars aus."""
    with AccessConnection() as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            frm = app.Forms(form_name)
            mdl = frm.Module

            if mdl.CountOfLines > 0:
                return mdl.Lines(1, mdl.CountOfLines)
            return ""
        finally:
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_NO)


@mcp.tool()
def add_vba_procedure_to_form(form_name: str, procedure_code: str) -> str:
    """
    Fuegt eine VBA-Prozedur zu einem Formular hinzu.
    Der Code wird am Ende des Moduls eingefuegt.
    """
    with AccessConnection(visible=True) as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            frm = app.Forms(form_name)
            mdl = frm.Module

            # Code am Ende einfuegen
            mdl.InsertText("\n" + procedure_code + "\n")

            app.DoCmd.Save(AC_FORM, form_name)
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_YES)

            return f"VBA-Code erfolgreich zu {form_name} hinzugefuegt"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def set_control_property(
    form_name: str,
    control_name: str,
    property_name: str,
    property_value: str
) -> str:
    """
    Setzt eine Eigenschaft eines Steuerelements.
    Beispiele: Visible, Left, Width, Caption, ControlSource, OnClick
    """
    with AccessConnection(visible=True) as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            frm = app.Forms(form_name)
            ctl = frm.Controls(control_name)

            # Wert konvertieren
            if property_value.lower() == 'true':
                value = True
            elif property_value.lower() == 'false':
                value = False
            elif property_value.isdigit():
                value = int(property_value)
            else:
                try:
                    value = float(property_value)
                except:
                    value = property_value

            setattr(ctl, property_name, value)

            app.DoCmd.Save(AC_FORM, form_name)
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_YES)

            return f"{control_name}.{property_name} = {value} gesetzt"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def add_control_to_form(
    form_name: str,
    control_type: str,
    control_name: str,
    left_cm: float = 1.0,
    top_cm: float = 1.0,
    width_cm: float = 3.0,
    height_cm: float = 0.6,
    caption: str = "",
    control_source: str = ""
) -> str:
    """
    Fuegt ein Steuerelement zu einem Formular hinzu.

    control_type: "button", "textbox", "label", "combobox", "listbox", "checkbox"
    Positionen und Groessen in Zentimetern.
    """
    type_map = {
        "button": AC_CMD_BUTTON,
        "textbox": AC_TEXT_BOX,
        "label": AC_LABEL,
        "combobox": AC_COMBO_BOX,
        "listbox": AC_LIST_BOX,
        "checkbox": AC_CHECK_BOX
    }

    if control_type.lower() not in type_map:
        return f"Unbekannter Steuerelementtyp: {control_type}"

    with AccessConnection(visible=True) as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            ctl = app.CreateControl(
                form_name,
                type_map[control_type.lower()],
                AC_SECTION_DETAIL,
                "",
                control_source,
                cm_to_twips(left_cm),
                cm_to_twips(top_cm),
                cm_to_twips(width_cm),
                cm_to_twips(height_cm)
            )

            ctl.Name = control_name

            if caption and hasattr(ctl, 'Caption'):
                ctl.Caption = caption

            app.DoCmd.Save(AC_FORM, form_name)
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_YES)

            return f"Steuerelement '{control_name}' ({control_type}) hinzugefuegt"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def export_form_as_text(form_name: str) -> str:
    """
    Exportiert ein Formular als Text (fuer Analyse oder Backup).
    Gibt den Dateipfad zurueck.
    """
    with AccessConnection() as app:
        export_path = os.path.join(
            tempfile.gettempdir(),
            f"{form_name}_export.txt"
        )
        app.SaveAsText(AC_FORM, form_name, export_path)

        # Inhalt lesen und zurueckgeben
        with open(export_path, 'r', encoding='utf-16') as f:
            content = f.read()

        return content[:50000]  # Erste 50000 Zeichen


@mcp.tool()
def import_form_from_text(form_name: str, text_file_path: str) -> str:
    """
    Importiert ein Formular aus einer Text-Datei (LoadFromText).
    Ermoeglicht persistente Design-Aenderungen.
    """
    with AccessConnection(exclusive=True, visible=True) as app:
        try:
            # Altes Formular loeschen wenn vorhanden
            try:
                app.DoCmd.DeleteObject(AC_FORM, form_name)
            except:
                pass

            app.LoadFromText(AC_FORM, form_name, text_file_path)
            return f"Formular '{form_name}' erfolgreich importiert"
        except Exception as e:
            return f"Fehler: {str(e)}"


# -------------------------------------------------------------------
# BERICHTE
# -------------------------------------------------------------------
@mcp.tool()
def list_reports() -> List[str]:
    """Listet alle Berichte im Frontend auf."""
    with AccessConnection() as app:
        return [doc.Name for doc in app.CurrentProject.AllReports]


@mcp.tool()
def get_report_details(report_name: str) -> Dict[str, Any]:
    """Gibt detaillierte Informationen zu einem Bericht zurueck."""
    with AccessConnection() as app:
        app.DoCmd.OpenReport(report_name, AC_VIEW_DESIGN)
        try:
            rpt = app.Reports(report_name)

            controls = []
            for ctl in rpt.Controls:
                try:
                    ctl_info = {
                        "name": ctl.Name,
                        "type": ctl.ControlType,
                        "left": ctl.Left,
                        "width": ctl.Width
                    }
                    if hasattr(ctl, 'ControlSource'):
                        ctl_info["control_source"] = ctl.ControlSource
                    controls.append(ctl_info)
                except:
                    pass

            return {
                "name": report_name,
                "record_source": rpt.RecordSource,
                "width": rpt.Width,
                "controls": controls
            }
        finally:
            app.DoCmd.Close(AC_REPORT, report_name, AC_SAVE_NO)


@mcp.tool()
def set_report_record_source(report_name: str, record_source: str) -> str:
    """Setzt die RecordSource eines Berichts."""
    with AccessConnection(visible=True) as app:
        app.DoCmd.OpenReport(report_name, AC_VIEW_DESIGN)
        try:
            rpt = app.Reports(report_name)
            rpt.RecordSource = record_source

            app.DoCmd.Save(AC_REPORT, report_name)
            app.DoCmd.Close(AC_REPORT, report_name, AC_SAVE_YES)

            return f"RecordSource von {report_name} geaendert"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def export_report_as_text(report_name: str) -> str:
    """Exportiert einen Bericht als Text."""
    with AccessConnection() as app:
        export_path = os.path.join(
            tempfile.gettempdir(),
            f"{report_name}_export.txt"
        )
        app.SaveAsText(AC_REPORT, report_name, export_path)

        with open(export_path, 'r', encoding='utf-16') as f:
            content = f.read()

        return content[:50000]


@mcp.tool()
def import_report_from_text(report_name: str, text_file_path: str) -> str:
    """Importiert einen Bericht aus einer Text-Datei."""
    with AccessConnection(exclusive=True, visible=True) as app:
        try:
            try:
                app.DoCmd.DeleteObject(AC_REPORT, report_name)
            except:
                pass

            app.LoadFromText(AC_REPORT, report_name, text_file_path)
            return f"Bericht '{report_name}' erfolgreich importiert"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def create_report_with_fields(
    report_name: str,
    record_source: str,
    fields: List[Dict[str, Any]]
) -> str:
    """
    Erstellt einen neuen Bericht mit angegebenen Feldern.

    fields: Liste von Dictionaries mit:
        - name: Feldname
        - control_source: Datenquelle
        - left_cm: Position links in cm
        - width_cm: Breite in cm
    """
    with AccessConnection(visible=True) as app:
        try:
            rpt = app.CreateReport()
            original_name = rpt.Name

            rpt.RecordSource = record_source

            top = 30
            for field in fields:
                ctl = app.CreateReportControl(
                    original_name,
                    AC_TEXT_BOX,
                    AC_SECTION_DETAIL,
                    "",
                    field.get("control_source", ""),
                    cm_to_twips(field.get("left_cm", 0)),
                    top,
                    cm_to_twips(field.get("width_cm", 2)),
                    360
                )
                ctl.Name = field.get("name", "")
                ctl.FontName = "Arial"
                ctl.FontSize = 10

            app.DoCmd.Save(AC_REPORT, original_name)
            app.DoCmd.Rename(report_name, AC_REPORT, original_name)
            app.DoCmd.Close(AC_REPORT, report_name, AC_SAVE_YES)

            return f"Bericht '{report_name}' erstellt"
        except Exception as e:
            return f"Fehler: {str(e)}"


# -------------------------------------------------------------------
# TABELLEN
# -------------------------------------------------------------------
@mcp.tool()
def list_tables() -> List[str]:
    """Listet alle Tabellen (ohne Systemtabellen) auf."""
    with AccessConnection() as app:
        db = app.CurrentDb()
        return [t.Name for t in db.TableDefs if not t.Name.startswith("MSys")]


@mcp.tool()
def get_table_structure(table_name: str) -> Dict[str, Any]:
    """Gibt die Struktur einer Tabelle zurueck (Felder, Typen)."""
    with AccessConnection() as app:
        db = app.CurrentDb()
        tbl = db.TableDefs(table_name)

        fields = []
        for fld in tbl.Fields:
            fields.append({
                "name": fld.Name,
                "type": fld.Type,
                "size": fld.Size,
                "required": fld.Required
            })

        return {
            "name": table_name,
            "record_count": db.OpenRecordset(f"SELECT COUNT(*) FROM [{table_name}]").Fields(0).Value,
            "fields": fields
        }


@mcp.tool()
def execute_sql(sql: str, return_data: bool = False) -> str:
    """
    Fuehrt SQL aus. Bei SELECT mit return_data=True werden Daten zurueckgegeben.
    Bei UPDATE/INSERT/DELETE wird die Anzahl betroffener Zeilen zurueckgegeben.
    """
    with AccessConnection() as app:
        db = app.CurrentDb()

        sql_upper = sql.strip().upper()

        if sql_upper.startswith("SELECT") and return_data:
            rs = db.OpenRecordset(sql)
            rows = []

            # Feldnamen
            field_names = [rs.Fields(i).Name for i in range(rs.Fields.Count)]

            while not rs.EOF:
                row = {}
                for i, name in enumerate(field_names):
                    val = rs.Fields(i).Value
                    row[name] = str(val) if val is not None else None
                rows.append(row)
                rs.MoveNext()

            rs.Close()
            return json.dumps(rows[:1000], ensure_ascii=False, indent=2)
        else:
            db.Execute(sql, 128)  # dbFailOnError
            return f"SQL ausgefuehrt. Betroffene Zeilen: {db.RecordsAffected}"


@mcp.tool()
def add_field_to_table(
    table_name: str,
    field_name: str,
    field_type: str,
    field_size: int = 255
) -> str:
    """
    Fuegt ein Feld zu einer Tabelle hinzu.

    field_type: "text", "number", "date", "boolean", "memo", "currency"
    """
    type_map = {
        "text": 10,      # dbText
        "number": 4,     # dbLong
        "date": 8,       # dbDate
        "boolean": 1,    # dbBoolean
        "memo": 12,      # dbMemo
        "currency": 5    # dbCurrency
    }

    if field_type.lower() not in type_map:
        return f"Unbekannter Feldtyp: {field_type}"

    with AccessConnection() as app:
        db = app.CurrentDb()
        tbl = db.TableDefs(table_name)

        fld = tbl.CreateField(field_name, type_map[field_type.lower()])
        if field_type.lower() == "text":
            fld.Size = field_size

        tbl.Fields.Append(fld)

        return f"Feld '{field_name}' zu Tabelle '{table_name}' hinzugefuegt"


# -------------------------------------------------------------------
# MODULE / VBA
# -------------------------------------------------------------------
@mcp.tool()
def list_modules() -> List[str]:
    """Listet alle Standardmodule auf."""
    with AccessConnection() as app:
        return [doc.Name for doc in app.CurrentProject.AllModules]


@mcp.tool()
def get_module_code(module_name: str) -> str:
    """Liest den Code eines Standardmoduls aus."""
    with AccessConnection() as app:
        vb_proj = app.VBE.ActiveVBProject

        for comp in vb_proj.VBComponents:
            if comp.Name == module_name:
                code_mod = comp.CodeModule
                if code_mod.CountOfLines > 0:
                    return code_mod.Lines(1, code_mod.CountOfLines)
                return ""

        return f"Modul '{module_name}' nicht gefunden"


@mcp.tool()
def add_code_to_module(module_name: str, code: str) -> str:
    """Fuegt Code zu einem bestehenden Modul hinzu."""
    with AccessConnection(visible=True) as app:
        vb_proj = app.VBE.ActiveVBProject

        for comp in vb_proj.VBComponents:
            if comp.Name == module_name:
                code_mod = comp.CodeModule
                code_mod.InsertText("\n" + code + "\n")
                return f"Code zu Modul '{module_name}' hinzugefuegt"

        return f"Modul '{module_name}' nicht gefunden"


@mcp.tool()
def create_module(module_name: str, initial_code: str = "") -> str:
    """Erstellt ein neues Standardmodul."""
    with AccessConnection(visible=True) as app:
        vb_proj = app.VBE.ActiveVBProject

        # Pruefen ob existiert
        for comp in vb_proj.VBComponents:
            if comp.Name == module_name:
                return f"Modul '{module_name}' existiert bereits"

        vb_comp = vb_proj.VBComponents.Add(1)  # vbext_ct_StdModule
        vb_comp.Name = module_name

        if initial_code:
            code_mod = vb_comp.CodeModule
            # Option-Zeilen entfernen
            while code_mod.CountOfLines > 0:
                line = code_mod.Lines(1, 1).strip().lower()
                if line.startswith("option"):
                    code_mod.DeleteLines(1, 1)
                else:
                    break

            code_mod.InsertText(initial_code)

        return f"Modul '{module_name}' erstellt"


@mcp.tool()
def find_procedure_in_codebase(procedure_name: str) -> List[Dict[str, str]]:
    """Sucht eine Prozedur in allen Modulen und Formularen."""
    results = []

    with AccessConnection() as app:
        vb_proj = app.VBE.ActiveVBProject

        for comp in vb_proj.VBComponents:
            try:
                code_mod = comp.CodeModule
                if code_mod.CountOfLines > 0:
                    code = code_mod.Lines(1, code_mod.CountOfLines)
                    if procedure_name.lower() in code.lower():
                        results.append({
                            "module": comp.Name,
                            "type": "Module" if comp.Type == 1 else "Form/Report"
                        })
            except:
                pass

    return results


# -------------------------------------------------------------------
# ABFRAGEN
# -------------------------------------------------------------------
@mcp.tool()
def list_queries() -> List[str]:
    """Listet alle Abfragen auf."""
    with AccessConnection() as app:
        db = app.CurrentDb()
        return [q.Name for q in db.QueryDefs if not q.Name.startswith("~")]


@mcp.tool()
def get_query_sql(query_name: str) -> str:
    """Gibt das SQL einer Abfrage zurueck."""
    with AccessConnection() as app:
        db = app.CurrentDb()
        return db.QueryDefs(query_name).SQL


@mcp.tool()
def create_or_update_query(query_name: str, sql: str) -> str:
    """Erstellt oder aktualisiert eine Abfrage."""
    with AccessConnection() as app:
        db = app.CurrentDb()

        # Pruefen ob existiert
        exists = False
        for q in db.QueryDefs:
            if q.Name == query_name:
                exists = True
                break

        if exists:
            db.QueryDefs(query_name).SQL = sql
            return f"Abfrage '{query_name}' aktualisiert"
        else:
            qd = db.CreateQueryDef(query_name, sql)
            return f"Abfrage '{query_name}' erstellt"


# -------------------------------------------------------------------
# OBJEKT-VERWALTUNG
# -------------------------------------------------------------------
@mcp.tool()
def rename_object(object_type: str, old_name: str, new_name: str) -> str:
    """
    Benennt ein Objekt um.

    object_type: "form", "report", "table", "query", "module"
    """
    type_map = {
        "form": AC_FORM,
        "report": AC_REPORT,
        "table": AC_TABLE,
        "query": AC_QUERY,
        "module": AC_MODULE
    }

    if object_type.lower() not in type_map:
        return f"Unbekannter Objekttyp: {object_type}"

    with AccessConnection(exclusive=True) as app:
        try:
            app.DoCmd.Rename(new_name, type_map[object_type.lower()], old_name)
            return f"{object_type} '{old_name}' umbenannt zu '{new_name}'"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def delete_object(object_type: str, object_name: str) -> str:
    """
    Loescht ein Objekt.

    object_type: "form", "report", "table", "query", "module"
    """
    type_map = {
        "form": AC_FORM,
        "report": AC_REPORT,
        "table": AC_TABLE,
        "query": AC_QUERY,
        "module": AC_MODULE
    }

    if object_type.lower() not in type_map:
        return f"Unbekannter Objekttyp: {object_type}"

    with AccessConnection(exclusive=True) as app:
        try:
            app.DoCmd.DeleteObject(type_map[object_type.lower()], object_name)
            return f"{object_type} '{object_name}' geloescht"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def copy_object(
    object_type: str,
    source_name: str,
    dest_name: str
) -> str:
    """
    Kopiert ein Objekt.

    object_type: "form", "report", "table", "query"
    """
    type_map = {
        "form": AC_FORM,
        "report": AC_REPORT,
        "table": AC_TABLE,
        "query": AC_QUERY
    }

    if object_type.lower() not in type_map:
        return f"Unbekannter Objekttyp: {object_type}"

    with AccessConnection() as app:
        try:
            app.DoCmd.CopyObject("", dest_name, type_map[object_type.lower()], source_name)
            return f"{object_type} '{source_name}' kopiert zu '{dest_name}'"
        except Exception as e:
            return f"Fehler: {str(e)}"


# -------------------------------------------------------------------
# MAKROS & EREIGNISSE
# -------------------------------------------------------------------
@mcp.tool()
def set_form_event(form_name: str, event_name: str, code: str) -> str:
    """
    Setzt ein Formular-Ereignis (z.B. Form_Load, Form_Current).

    event_name: "Load", "Current", "Open", "Close", "BeforeUpdate", etc.
    """
    with AccessConnection(visible=True) as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            frm = app.Forms(form_name)
            mdl = frm.Module

            # Vollstaendige Prozedur erstellen
            proc_code = f"""
Private Sub Form_{event_name}()
{code}
End Sub
"""
            mdl.InsertText(proc_code)

            # Event-Eigenschaft setzen
            setattr(frm, f"On{event_name}", "[Event Procedure]")

            app.DoCmd.Save(AC_FORM, form_name)
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_YES)

            return f"Event Form_{event_name} fuer {form_name} erstellt"
        except Exception as e:
            return f"Fehler: {str(e)}"


@mcp.tool()
def set_control_event(
    form_name: str,
    control_name: str,
    event_name: str,
    code: str
) -> str:
    """
    Setzt ein Steuerelement-Ereignis (z.B. Click, AfterUpdate).

    event_name: "Click", "AfterUpdate", "Change", "Enter", "Exit", etc.
    """
    with AccessConnection(visible=True) as app:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        try:
            frm = app.Forms(form_name)
            ctl = frm.Controls(control_name)
            mdl = frm.Module

            proc_code = f"""
Private Sub {control_name}_{event_name}()
{code}
End Sub
"""
            mdl.InsertText(proc_code)

            setattr(ctl, f"On{event_name}", "[Event Procedure]")

            app.DoCmd.Save(AC_FORM, form_name)
            app.DoCmd.Close(AC_FORM, form_name, AC_SAVE_YES)

            return f"Event {control_name}_{event_name} fuer {form_name} erstellt"
        except Exception as e:
            return f"Fehler: {str(e)}"


# -------------------------------------------------------------------
# KOMPAKTIEREN & REPARIEREN
# -------------------------------------------------------------------
@mcp.tool()
def compact_and_repair() -> str:
    """Kompaktiert und repariert die Datenbank."""
    import shutil

    backup_path = FRONTEND_PATH + ".backup"
    temp_path = FRONTEND_PATH + ".temp"

    try:
        # Backup erstellen
        shutil.copy2(FRONTEND_PATH, backup_path)

        pythoncom.CoInitialize()
        try:
            dbe = win32com.client.Dispatch("DAO.DBEngine.120")
            dbe.CompactDatabase(FRONTEND_PATH, temp_path)

            # Original ersetzen
            os.remove(FRONTEND_PATH)
            os.rename(temp_path, FRONTEND_PATH)

            return f"Datenbank kompaktiert. Backup: {backup_path}"
        finally:
            pythoncom.CoUninitialize()

    except Exception as e:
        # Cleanup
        if os.path.exists(temp_path):
            os.remove(temp_path)
        return f"Fehler: {str(e)}"


# -------------------------------------------------------------------
# HILFSFUNKTIONEN FUER DESIGN-AENDERUNGEN
# -------------------------------------------------------------------
@mcp.tool()
def create_text_report_definition(
    report_name: str,
    record_source: str,
    fields: List[Dict[str, Any]]
) -> str:
    """
    Erstellt eine Report-Definition als Text-Datei fuer LoadFromText.

    fields: Liste von {"name": "...", "source": "...", "left": 100, "width": 1000}
    """
    # Basis-Template
    template = f'''Version =21
VersionRequired =20
Begin Report
    LayoutForPrint = NotDefault
    DividingLines = NotDefault
    Width =12000
    RecordSource ="{record_source}"
    FilterOnLoad =0
    Begin
        Begin TextBox
            AddColon = NotDefault
            BorderLineStyle =0
            Width =1701
            FontSize =10
            FontName ="Arial"
            GridlineColor =-2147483609
        End
        Begin Section
            KeepTogether = NotDefault
            CanGrow = NotDefault
            CanShrink = NotDefault
            Height =360
            Name ="Detailbereich"
            Begin
'''

    for idx, field in enumerate(fields):
        template += f'''                Begin TextBox
                    OverlapFlags =81
                    Left ={field.get('left', idx * 1500)}
                    Top =30
                    Width ={field.get('width', 1400)}
                    Height =300
                    Name ="{field['name']}"
                    ControlSource ="{field.get('source', field['name'])}"
                    FontName ="Arial"
                    FontSize =10
                End
'''

    template += '''            End
        End
    End
End
'''

    # Speichern
    file_path = os.path.join(tempfile.gettempdir(), f"{report_name}_def.txt")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(template)

    return file_path


# -------------------------------------------------------------------
# SERVERSTART
# -------------------------------------------------------------------
if __name__ == "__main__":
    logger.info(f"Access Bridge MCP Extended startet...")
    logger.info(f"Frontend: {FRONTEND_PATH}")

    async def main():
        await stdio_server.run(mcp)

    asyncio.run(main())
