import os
import logging
import asyncio
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
    r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"  # <- bei Bedarf anpassen
)

# Log-Tabelle in Access (optional, kann angepasst werden)
LOG_TABLE_NAME = "tbl_MCP_Log"

# Access-Konstanten (vereinfachte Variante)
AC_VIEW_DESIGN = 1          # acDesign
AC_FORM = 2                 # acForm
AC_REPORT = 3               # acReport
AC_CMD_BUTTON = 2           # acCommandButton
AC_SECTION_DETAIL = 0       # Detailbereich

# MCP-Server-Instanz
mcp = FastMCP("access-bridge")


# -------------------------------------------------------------------
# Hilfsfunktionen: Access steuern, Logging ohne MsgBox
# -------------------------------------------------------------------
def get_access_app(visible: bool = False):
    """
    Startet Access über COM, öffnet das Test-Frontend und gibt die Application zurück.
    Access läuft unsichtbar, wenn visible=False.
    """
    pythoncom.CoInitialize()
    app = win32com.client.Dispatch("Access.Application")
    app.Visible = visible

    # Test-Frontend öffnen, falls noch nichts offen ist
    if not app.CurrentProject.FullName:
        app.OpenCurrentDatabase(FRONTEND_PATH)

    # Warnungen ausschalten (z.B. Aktionsbestätigungen)
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
    Kein MsgBox, keine Unterbrechung.
    """
    try:
        # Minimaler Insert, passt an deine Tabelle an
        # z.B. Felder: LogZeit (Date/Time), LogLevel (Text), Meldung (Memo)
        sql = f"""
            INSERT INTO {LOG_TABLE_NAME} (LogZeit, LogLevel, Meldung)
            VALUES (Now(), '{level.replace("'", "''")}', '{message.replace("'", "''")}')
        """
        app.CurrentDb().Execute(sql)
    except Exception:
        # Wenn die Tabelle nicht existiert, ignorieren wir das still und loggen nur im Python-Log
        logging.exception("Log in Access fehlgeschlagen")


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
# MCP-TOOL: Button zu einem Formular hinzufügen
# -------------------------------------------------------------------
@tool()
def add_button_to_form(
    form_name: str,
    button_name: str,
    caption: str = "Neuer Button",
    on_click_macro_or_proc: str = ""
) -> str:
    """
    Fügt einem Formular im Entwurf einen Button hinzu.
    - form_name: Name des Formulars (z.B. 'frm_Dashboard')
    - button_name: Name des Steuerelements (z.B. 'btn_Test')
    - caption: Beschriftung
    - on_click_macro_or_proc:
        * leer          -> kein Event
        * 'MeineMakro'  -> ruft Makro MeineMakro() auf
        * '[Event Procedure]' -> setzt Ereignis auf Ereignisprozedur (VBA im Formularmodul muss existieren)
    """

    app = get_access_app(visible=False)

    try:
        # Formular in Entwurfsansicht öffnen
        app.DoCmd.OpenForm(form_name, AC_VIEW_DESIGN)

        frm = app.Forms(form_name)

        # Position/Größe grob setzen (Twips)
        left = 1000
        top = 1000
        width = 2000
        height = 500

        # Neuen Button erstellen
        btn = app.CreateControl(
            form_name,
            AC_CMD_BUTTON,
            AC_SECTION_DETAIL,
            "",               # Parent
            "",               # ColumnName
            left,
            top,
            width,
            height
        )

        btn.Name = button_name
        btn.Caption = caption

        # Click-Ereignis zuweisen, falls gewünscht
        if on_click_macro_or_proc.strip():
            if on_click_macro_or_proc.strip() == "[Event Procedure]":
                btn.OnClick = "[Event Procedure]"
            else:
                # Makro-Aufruf
                btn.OnClick = on_click_macro_or_proc

        # Formular speichern und schließen
        app.DoCmd.Save(AC_FORM, form_name)
        app.DoCmd.Close(AC_FORM, form_name)

        msg = f"Button '{button_name}' in Formular '{form_name}' erstellt."
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
# Serverstart über STDIO (für Claude Desktop / Code)
# -------------------------------------------------------------------
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    async def main():
        await stdio_server.run(mcp)

    asyncio.run(main())
