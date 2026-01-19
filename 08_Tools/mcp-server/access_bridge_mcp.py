import os
import logging
import asyncio
import datetime
from typing import List

import pythoncom
import win32com.client

from mcp.server.fastmcp import FastMCP, tool
from mcp.server.stdio import stdio_server

# -------------------------------------------------------------------
# KONFIGURATION: Pfad zum TEST-Frontend
# -------------------------------------------------------------------
FRONTEND_PATH = os.environ.get(
    "ACCESS_FE_PATH",
    r"C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude.accdb"  # <- bei Bedarf anpassen
)

# Name der Log-Tabelle in Access (optional, anpassbar)
LOG_TABLE_NAME = "tbl_MCP_Log"

# Vereinfachte Access-Konstanten
AC_VIEW_DESIGN = 1          # acDesign
AC_FORM = 2                 # acForm
AC_REPORT = 3               # acReport
AC_CMD_BUTTON = 2           # acCommandButton (ggf. anpassen, wenn bei dir anders)
AC_SECTION_DETAIL = 0       # Detailbereich

# MCP-Server-Instanz
mcp = FastMCP("access-bridge")


# -------------------------------------------------------------------
# Hilfsfunktionen: Access starten, schließen, loggen
# -------------------------------------------------------------------
def get_access_app(visible: bool = False):
    """
    Startet Access über COM, öffnet das Test-Frontend und gibt die Application zurück.
    Access läuft unsichtbar, wenn visible=False.
    """
    pythoncom.CoInitialize()
    app = win32com.client.Dispatch("Access.Application")
    app.Visible = visible

    if not app.CurrentProject.FullName:
        app.OpenCurrentDatabase(FRONTEND_PATH)

    # Warnungen ausschalten (keine Aktionsbestätigungen)
    try:
        app.DoCmd.SetWarnings(False)
    except Exception:
        logging.exception("SetWarnings(False) fehlgeschlagen")

    return app


def close_access(app):
    """
    Access sauber schließen und COM aufräumen.
    """
    try:
        app.Quit()
    except Exception:
        logging.exception("Fehler beim Schließen von Access")
    finally:
        pythoncom.CoUninitialize()


def log_in_access(app, level: str, message: str):
    """
    Schreibt eine Meldung in die Log-Tabelle LOG_TABLE_NAME (wenn vorhanden).
    Keine MsgBox, keine Unterbrechung.
    """
    try:
        sql = f"""
            INSERT INTO {LOG_TABLE_NAME} (LogZeit, LogLevel, Meldung)
            VALUES (Now(), '{level.replace("'", "''")}', '{message.replace("'", "''")}')
        """
        app.CurrentDb().Execute(sql)
    except Exception:
        # Wenn die Tabelle fehlt o.ä., loggen wir nur im Python-Log
        logging.exception("Log in Access fehlgeschlagen")


def generate_timestamp_suffix() -> str:
    """
    Erzeugt einen Zeitstempel-Suffix für eindeutige Test-Namen.
    Format: YYYYMMDD_HHMMSS
    """
    return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")


# -------------------------------------------------------------------
# Namens-Helfer: Test-Objekte
# -------------------------------------------------------------------
def make_test_form_name() -> str:
    suffix = generate_timestamp_suffix()
    name = f"frm_N_Test_{suffix}"
    return name[:50]


def make_test_module_name() -> str:
    suffix = generate_timestamp_suffix()
    name = f"mod_N_Test_{suffix}"
    return name[:50]


def make_test_report_name() -> str:
    suffix = generate_timestamp_suffix()
    name = f"rpt_N_Test_{suffix}"
    return name[:50]


def make_test_button_name() -> str:
    suffix = generate_timestamp_suffix()
    name = f"btn_N_Test_{suffix}"
    return name[:50]


# -------------------------------------------------------------------
# MCP-TOOL: Verbindungstest
# -------------------------------------------------------------------
@tool()
def ping() -> str:
    """
    Einfache Verbindungskontrolle.
    """
    return f"Access-Bridge MCP läuft. FRONTEND_PATH = {FRONTEND_PATH}"


# -------------------------------------------------------------------
# MCP-TOOL: Formulare und Berichte auflisten (READ-ONLY)
# -------------------------------------------------------------------
@tool()
def list_forms() -> List[str]:
    """
    Liefert eine Liste aller Formularnamen im Frontend.
    READ-ONLY, ändert nichts.
    """
    app = get_access_app(visible=False)
    try:
        forms = [doc.Name for doc in app.CurrentProject.AllForms]
        return forms
    finally:
        close_access(app)


@tool()
def list_reports() -> List[str]:
    """
    Liefert eine Liste aller Berichtsnamen im Frontend.
    READ-ONLY, ändert nichts.
    """
    app = get_access_app(visible=False)
    try:
        reps = [doc.Name for doc in app.CurrentProject.AllReports]
        return reps
    finally:
        close_access(app)


# -------------------------------------------------------------------
# MCP-TOOL: Test-Formular erstellen (frm_N_Test_<Zeitstempel>)
# -------------------------------------------------------------------
@tool()
def create_test_form() -> str:
    """
    Erstellt ein neues Test-Formular mit Namen frm_N_Test_<Zeitstempel>.
    - Form wird leer im Entwurf erstellt und gespeichert.
    - Es werden KEINE bestehenden Formulare gelöscht oder überschrieben.
    """
    app = get_access_app(visible=False)
    form_name = make_test_form_name()

    try:
        # Prüfen, ob der Name zufällig doch existiert
        for doc in app.CurrentProject.AllForms:
            if doc.Name == form_name:
                msg = f"Formular '{form_name}' existiert bereits. Es wird NICHT überschrieben."
                log_in_access(app, "INFO", msg)
                return msg

        # Neues Formular erstellen
        frm = app.CreateForm()
        original_name = frm.Name

        # Speichern & umbenennen
        app.DoCmd.Save(AC_FORM, original_name)
        app.DoCmd.Rename(form_name, AC_FORM, original_name)

        msg = f"Test-Formular '{form_name}' wurde erstellt."
        log_in_access(app, "INFO", msg)
        return msg

    except Exception as e:
        err_msg = f"Fehler beim Erstellen des Test-Formulars '{form_name}': {e}"
        logging.exception(err_msg)
        log_in_access(app, "ERROR", err_msg)
        return err_msg

    finally:
        close_access(app)


# -------------------------------------------------------------------
# MCP-TOOL: Test-Bericht erstellen (rpt_N_Test_<Zeitstempel>)
# -------------------------------------------------------------------
@tool()
def create_test_report() -> str:
    """
    Erstellt einen neuen Test-Bericht mit Namen rpt_N_Test_<Zeitstempel>.
    - Bericht wird leer im Entwurf erstellt und gespeichert.
    - Es werden KEINE bestehenden Berichte gelöscht oder überschrieben.
    """
    app = get_access_app(visible=False)
    report_name = make_test_report_name()

    try:
        for doc in app.CurrentProject.AllReports:
            if doc.Name == report_name:
                msg = f"Bericht '{report_name}' existiert bereits. Es wird NICHT überschrieben."
                log_in_access(app, "INFO", msg)
                return msg

        rpt = app.CreateReport()
        original_name = rpt.Name

        app.DoCmd.Save(AC_REPORT, original_name)
        app.DoCmd.Rename(report_name, AC_REPORT, original_name)

        msg = f"Test-Bericht '{report_name}' wurde erstellt."
        log_in_access(app, "INFO", msg)
        return msg

    except Exception as e:
        err_msg = f"Fehler beim Erstellen des Test-Berichts '{report_name}': {e}"
        logging.exception(err_msg)
        log_in_access(app, "ERROR", err_msg)
        return err_msg

    finally:
        close_access(app)


# -------------------------------------------------------------------
# MCP-TOOL: Test-Modul erstellen (mod_N_Test_<Zeitstempel>)
#   - ohne doppelte Option-Zeilen
# -------------------------------------------------------------------
@tool()
def create_test_module() -> str:
    """
    Erstellt ein neues Standardmodul 'mod_N_Test_<Zeitstempel>'.
    - Entfernt aus dem neu erzeugten Modul ggf. doppelte
      'Option Explicit' / 'Option Compare Database' Zeilen.
    - Löscht KEINE bestehenden Module.
    """
    app = get_access_app(visible=False)

    try:
        vb_proj = app.VBE.ActiveVBProject
        new_name = make_test_module_name()

        # Prüfen, ob der Name schon existiert
        for comp in vb_proj.VBComponents:
            if comp.Name == new_name:
                msg = f"Modul '{new_name}' existiert bereits. Es wird NICHT neu angelegt."
                log_in_access(app, "INFO", msg)
                return msg

        # 1 = vbext_ct_StdModule (Standardmodul)
        vb_comp = vb_proj.VBComponents.Add(1)
        vb_comp.Name = new_name
        code_mod = vb_comp.CodeModule

        # Option-Zeilen bereinigen (falls doppelt)
        try:
            line_count = code_mod.CountOfLines
            max_check = min(10, line_count)
            lines_to_delete = []

            for i in range(1, max_check + 1):
                text = code_mod.Lines(i, 1).strip().lower()
                if text.startswith("option explicit") or text.startswith("option compare database"):
                    lines_to_delete.append(i)

            for i in reversed(lines_to_delete):
                code_mod.DeleteLines(i, 1)

        except Exception:
            logging.exception("Konnte Option-Zeilen im neuen Modul nicht bereinigen")

        msg = f"Test-Modul '{new_name}' wurde erstellt (Option-Zeilen bereinigt, soweit möglich)."
        log_in_access(app, "INFO", msg)
        return msg

    except Exception as e:
        err_msg = f"Fehler beim Erstellen des Test-Moduls: {e}"
        logging.exception(err_msg)
        try:
            log_in_access(app, "ERROR", err_msg)
        except Exception:
            pass
        return err_msg

    finally:
        close_access(app)


# -------------------------------------------------------------------
# MCP-TOOL: Generischen Test-Button in einem Formular anlegen
# -------------------------------------------------------------------
@tool()
def add_test_button(
    form_name: str,
    caption: str = "Test",
    on_click_macro_or_proc: str = ""
) -> str:
    """
    Fügt einem bestehenden Formular einen Test-Button hinzu.
    - Buttonname wird automatisch als 'btn_N_Test_<Zeitstempel>' erzeugt.
    - Formular muss existieren.
    - Es wird NICHT versucht, bestehende Buttons zu löschen oder zu ändern.
    """
    app = get_access_app(visible=False)

    try:
        # Prüfen, ob Formular existiert
        exists = False
        for doc in app.CurrentProject.AllForms:
            if doc.Name == form_name:
                exists = True
                break

        if not exists:
            msg = f"Formular '{form_name}' existiert nicht."
            log_in_access(app, "ERROR", msg)
            return msg

        # Formular im Entwurf öffnen
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        frm = app.Forms(form_name)

        btn_name = make_test_button_name()

        # Grobe Standard-Position (Twips)
        left = 1000
        top = 1000
        width = 2000
        height = 500

        btn = app.CreateControl(
            form_name,
            AC_CMD_BUTTON,
            AC_SECTION_DETAIL,
            "",
            "",
            left,
            top,
            width,
            height
        )

        btn.Name = btn_name
        btn.Caption = caption

        if on_click_macro_or_proc.strip():
            if on_click_macro_or_proc.strip() == "[Event Procedure]":
                btn.OnClick = "[Event Procedure]"
            else:
                btn.OnClick = on_click_macro_or_proc

        app.DoCmd.Save(AC_FORM, form_name)
        app.DoCmd.Close(AC_FORM, form_name)

        msg = f"Test-Button '{btn.Name}' wurde in Formular '{form_name}' erstellt."
        log_in_access(app, "INFO", msg)
        return msg

    except Exception as e:
        err_msg = f"Fehler beim Hinzufügen eines Test-Buttons zu Formular '{form_name}': {e}"
        logging.exception(err_msg)
        try:
            log_in_access(app, "ERROR", err_msg)
        except Exception:
            pass
        return err_msg

    finally:
        close_access(app)


# -------------------------------------------------------------------
# OPTIONAL: generischer Button (falls du später gezielt Namen willst)
# -------------------------------------------------------------------
@tool()
def add_button_to_form(
    form_name: str,
    button_name: str,
    caption: str = "Neuer Button",
    on_click_macro_or_proc: str = ""
) -> str:
    """
    Fügt einem Formular im Entwurf einen Button mit festem Namen hinzu.
    Diese Funktion verwendet KEINE automatischen Test-Namen.
    """
    app = get_access_app(visible=False)

    try:
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)
        frm = app.Forms(form_name)

        left = 1000
        top = 1000
        width = 2000
        height = 500

        btn = app.CreateControl(
            form_name,
            AC_CMD_BUTTON,
            AC_SECTION_DETAIL,
            "",
            "",
            left,
            top,
            width,
            height
        )

        btn.Name = button_name[:50]
        btn.Caption = caption

        if on_click_macro_or_proc.strip():
            if on_click_macro_or_proc.strip() == "[Event Procedure]":
                btn.OnClick = "[Event Procedure]"
            else:
                btn.OnClick = on_click_macro_or_proc

        app.DoCmd.Save(AC_FORM, form_name)
        app.DoCmd.Close(AC_FORM, form_name)

        msg = f"Button '{btn.Name}' in Formular '{form_name}' erstellt."
        log_in_access(app, "INFO", msg)
        return msg

    except Exception as e:
        err_msg = f"Fehler beim Hinzufügen eines Buttons zu Formular '{form_name}': {e}"
        logging.exception(err_msg)
        try:
            log_in_access(app, "ERROR", err_msg)
        except Exception:
            pass
        return err_msg

    finally:
        close_access(app)


# -------------------------------------------------------------------
# Serverstart über STDIO (für Claude Code Desktop)
# -------------------------------------------------------------------
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    async def main():
        await stdio_server.run(mcp)

    asyncio.run(main())
