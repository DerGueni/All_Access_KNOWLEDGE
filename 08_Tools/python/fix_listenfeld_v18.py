"""
FIX LISTENFELD V18 - Status-Spalte und korrektes Datenformat
"""
import win32com.client
import pythoncom
import subprocess
import time
from pathlib import Path

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

# Neue Funktion - Zeigt MA aus tbl_MA_VA_Planung mit Status
NEW_AKTUALISIERE_CODE = '''Public Sub DP_Aktualisiere_Angefragte_MA()
    On Error Resume Next
    Dim frm As Form
    Set frm = Forms!frm_N_DP_Dashboard
    Dim strSQL As String

    ' Zeige MA aus tbl_MA_VA_Planung fuer aktuelle Schicht
    ' Status 1=Geplant, 2=Benachrichtigt (3=Zusage, 4=Absage werden nicht angezeigt)
    If m_CurrentVAStart_ID > 0 Then
        strSQL = "SELECT p.MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
                 "Format(p.MVA_Start, 'hh:nn') AS von, " & _
                 "Format(p.MVA_Ende, 'hh:nn') AS bis, " & _
                 "s.Status " & _
                 "FROM (tbl_MA_VA_Planung AS p " & _
                 "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID) " & _
                 "INNER JOIN tbl_MA_Plan_Status AS s ON p.Status_ID = s.ID " & _
                 "WHERE p.VAStart_ID = " & m_CurrentVAStart_ID & " " & _
                 "AND p.Status_ID IN (1, 2) " & _
                 "ORDER BY m.Nachname, m.Vorname"
    Else
        ' Fallback auf ztbl_MA_Schnellauswahl wenn keine Schicht ausgewaehlt
        strSQL = "SELECT s.ID AS MA_ID, m.Nachname & ' ' & m.Vorname AS MA_Name, " & _
                 "Format(s.Beginn, 'hh:nn') AS von, Format(s.Ende, 'hh:nn') AS bis, " & _
                 "'Neu' AS Status " & _
                 "FROM ztbl_MA_Schnellauswahl AS s " & _
                 "INNER JOIN tbl_MA_Mitarbeiterstamm AS m ON s.ID = m.ID " & _
                 "ORDER BY m.Nachname, m.Vorname"
    End If

    frm!lst_MA_Auswahl.RowSource = strSQL
    frm!lst_MA_Auswahl.Requery
    On Error GoTo 0
End Sub'''

def start_killer():
    p = Path(r"C:\Users\guenther.siegert\Documents\Access Bridge\DialogKillerPermanent.ps1")
    if p.exists():
        return subprocess.Popen(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", str(p), "-Minutes", "30", "-IntervalMs", "50"],
            creationflags=subprocess.CREATE_NO_WINDOW, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return None

print("=" * 70)
print("FIX LISTENFELD V18 - Status-Spalte aus tbl_MA_VA_Planung")
print("=" * 70)

killer = start_killer()

try:
    pythoncom.CoInitialize()

    print("[1] Access verbinden...")
    try:
        app = win32com.client.GetObject(Class="Access.Application")
    except:
        app = win32com.client.Dispatch("Access.Application")
        app.Visible = True
        app.UserControl = True
        app.OpenCurrentDatabase(FRONTEND_PATH, False)
        time.sleep(3)

    print("[OK] Access verbunden")

    # Formulare schliessen
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste", "zfrm_Log"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    print("[2] Aktualisiere mod_N_DP_Dashboard...")

    for c in proj.VBComponents:
        if c.Name == "mod_N_DP_Dashboard":
            cm = c.CodeModule
            print(f"    Gefunden ({cm.CountOfLines} Zeilen)")

            # Versionskommentar aktualisieren
            cm.ReplaceLine(1, "' mod_N_DP_Dashboard V18 - Listenfeld mit Status aus tbl_MA_VA_Planung")

            # Finde DP_Aktualisiere_Angefragte_MA
            start_line = 0
            end_line = 0

            for i in range(1, cm.CountOfLines + 1):
                line = cm.Lines(i, 1)
                if "Public Sub DP_Aktualisiere_Angefragte_MA()" in line:
                    start_line = i
                if start_line > 0 and i > start_line and line.strip() == "End Sub":
                    end_line = i
                    break

            if start_line > 0 and end_line > 0:
                print(f"    DP_Aktualisiere_Angefragte_MA: Zeile {start_line}-{end_line}")

                # Loesche alte Funktion
                cm.DeleteLines(start_line, end_line - start_line + 1)
                print(f"    Alte Funktion geloescht")

                # Fuege neue Funktion ein
                cm.InsertLines(start_line, NEW_AKTUALISIERE_CODE)
                print(f"    Neue Funktion eingefuegt")
                print(f"    Neue Zeilenanzahl: {cm.CountOfLines}")
            else:
                print(f"    [!] Funktion nicht gefunden!")

            break

    # Listenfeld-Eigenschaften anpassen (5 Spalten statt 4)
    print("\n[3] Oeffne frm_N_DP_Dashboard im Design...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")

    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lst_MA_Auswahl":
            print(f"    lst_MA_Auswahl gefunden")
            print(f"    Alte ColumnCount: {ctl.ColumnCount}")
            print(f"    Alte ColumnWidths: {ctl.ColumnWidths}")

            # 5 Spalten: MA_ID (hidden), Name, von, bis, Status
            ctl.ColumnCount = 5
            ctl.ColumnWidths = "0;2500;600;600;1200"

            print(f"    Neue ColumnCount: {ctl.ColumnCount}")
            print(f"    Neue ColumnWidths: {ctl.ColumnWidths}")
            break

    # Speichern
    app.DoCmd.Save(2, "frm_N_DP_Dashboard")
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)

    print("\n[OK] V18 - Listenfeld zeigt jetzt Status aus tbl_MA_VA_Planung")

except Exception as e:
    print(f"\n[FEHLER] {e}")
    import traceback
    traceback.print_exc()

finally:
    if killer:
        try:
            killer.terminate()
        except:
            pass
    pythoncom.CoUninitialize()
