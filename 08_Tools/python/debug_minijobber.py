"""
Debug Minijobber-Problem via Access
"""
import win32com.client
import pythoncom
import time

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (4).accdb"

print("=" * 70)
print("DEBUG MINIJOBBER")
print("=" * 70)

try:
    pythoncom.CoInitialize()

    print("\n[1] Verbinde mit Access...")
    try:
        app = win32com.client.GetObject(Class="Access.Application")
    except:
        app = win32com.client.Dispatch("Access.Application")
        app.Visible = True
        app.UserControl = True
        app.OpenCurrentDatabase(FRONTEND_PATH, False)
        time.sleep(3)

    print("[OK] Access verbunden")

    # Pruefe ztbl_MA_Schnellauswahl via CurrentDb
    print("\n[2] Pruefe Tabelle ztbl_MA_Schnellauswahl...")

    # VBA ausfuehren um Tabelle zu pruefen
    vba_check = """
Public Function CheckSchnellauswahl() As String
    On Error GoTo ErrHandler
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim result As String

    Set db = CurrentDb

    ' Pruefe ob Tabelle existiert
    On Error Resume Next
    Set rs = db.OpenRecordset("SELECT * FROM ztbl_MA_Schnellauswahl", dbOpenSnapshot)
    If Err.Number <> 0 Then
        result = "FEHLER: Tabelle existiert nicht - " & Err.Description
        Err.Clear
        On Error GoTo 0
        CheckSchnellauswahl = result
        Exit Function
    End If
    On Error GoTo ErrHandler

    result = "Tabelle OK, Datensaetze: " & rs.RecordCount

    ' Zeige Inhalt
    If Not rs.EOF Then
        rs.MoveFirst
        Do While Not rs.EOF
            result = result & vbCrLf & "ID=" & rs!ID & ", Beginn=" & rs!Beginn & ", Ende=" & rs!Ende
            rs.MoveNext
        Loop
    End If

    rs.Close
    Set db = Nothing
    CheckSchnellauswahl = result
    Exit Function

ErrHandler:
    CheckSchnellauswahl = "FEHLER: " & Err.Description
End Function
"""

    # Modul hinzufuegen und Funktion ausfuehren
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    # Temporaeres Modul erstellen
    temp_module = None
    for c in proj.VBComponents:
        if c.Name == "mod_TempDebug":
            temp_module = c
            break

    if not temp_module:
        temp_module = proj.VBComponents.Add(1)
        temp_module.Name = "mod_TempDebug"

    cm = temp_module.CodeModule
    if cm.CountOfLines > 0:
        cm.DeleteLines(1, cm.CountOfLines)
    cm.AddFromString(vba_check)

    # Funktion ausfuehren
    time.sleep(1)
    try:
        result = app.Run("CheckSchnellauswahl")
        print(f"    {result}")
    except Exception as e:
        print(f"    [FEHLER beim Ausfuehren] {e}")

    # Pruefe den aktuellen VBA-Code
    print("\n[3] Pruefe mod_N_DP_Dashboard...")
    for c in proj.VBComponents:
        if c.Name == "mod_N_DP_Dashboard":
            cm = c.CodeModule
            print(f"    Zeilen: {cm.CountOfLines}")

            # Suche nach DP_MA_Zur_Anfrage
            found = False
            for i in range(1, cm.CountOfLines + 1):
                line = cm.Lines(i, 1)
                if "Public Sub DP_MA_Zur_Anfrage" in line:
                    found = True
                    print(f"    DP_MA_Zur_Anfrage gefunden in Zeile {i}")
                    # Zeige 20 Zeilen
                    code_block = cm.Lines(i, min(20, cm.CountOfLines - i + 1))
                    print("    ---")
                    for ln in code_block.split('\n'):
                        print(f"    {ln}")
                    print("    ---")
                    break

            if not found:
                print("    [!] DP_MA_Zur_Anfrage NICHT GEFUNDEN!")

            # Suche nach DP_MA_Doppelklick
            for i in range(1, cm.CountOfLines + 1):
                line = cm.Lines(i, 1)
                if "Public Sub DP_MA_Doppelklick" in line:
                    print(f"\n    DP_MA_Doppelklick in Zeile {i}:")
                    code_block = cm.Lines(i, min(15, cm.CountOfLines - i + 1))
                    print("    ---")
                    for ln in code_block.split('\n'):
                        print(f"    {ln}")
                    print("    ---")
                    break
            break

    # Loesche temporaeres Modul
    try:
        proj.VBComponents.Remove(temp_module)
    except:
        pass

    print("\n" + "=" * 70)
    print("DEBUG ABGESCHLOSSEN")
    print("=" * 70)

except Exception as e:
    print(f"\n[FEHLER] {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()
