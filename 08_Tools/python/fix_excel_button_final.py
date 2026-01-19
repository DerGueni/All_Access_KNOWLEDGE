"""
Korrigiere den btn_N_ExcelOeffnen Button - verwende korrekte API oder Screen-Objekt
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

# Neuer Code für den Button - verwende Screen.Width/Height von Access oder feste Werte
new_code = '''
Private Sub btn_N_ExcelOeffnen_Click()
    On Error GoTo Err_Handler

    Dim strPfad As String
    Dim xlApp As Object
    Dim xlWb As Object
    Dim intAktuellerMonat As Integer
    Dim lngScreenWidth As Long
    Dim lngScreenHeight As Long

    strPfad = Nz(Me!Zeitkonto_Pfad, "")

    If strPfad = "" Then
        MsgBox "Kein Zeitkonto-Pfad hinterlegt!", vbExclamation, "Hinweis"
        Exit Sub
    End If

    ' Prüfe ob Pfad mit .xlsx endet und ändere zu .xlsm
    If Right(LCase(strPfad), 5) = ".xlsx" Then
        strPfad = Left(strPfad, Len(strPfad) - 5) & ".xlsm"
    ElseIf Right(LCase(strPfad), 4) = ".xls" Then
        strPfad = Left(strPfad, Len(strPfad) - 4) & ".xlsm"
    ElseIf Right(LCase(strPfad), 5) <> ".xlsm" Then
        strPfad = strPfad & ".xlsm"
    End If

    If Dir(strPfad) = "" Then
        MsgBox "Datei nicht gefunden:" & vbCrLf & strPfad, vbExclamation, "Fehler"
        Exit Sub
    End If

    ' Excel über COM öffnen
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = True

    ' Fenster in unterer Bildschirmhälfte positionieren
    ' Verwende Excel's UsableWidth/UsableHeight für Bildschirmgröße
    xlApp.WindowState = -4143  ' xlNormal

    lngScreenWidth = xlApp.Application.UsableWidth
    lngScreenHeight = xlApp.Application.UsableHeight

    xlApp.Left = 0
    xlApp.Top = lngScreenHeight / 2
    xlApp.Width = lngScreenWidth
    xlApp.Height = lngScreenHeight / 2

    Set xlWb = xlApp.Workbooks.Open(strPfad, , False)

    ' Aktuellen Monat ermitteln und Blatt wechseln
    intAktuellerMonat = Month(Date)

    ' Versuche zum Monatsblatt zu wechseln
    On Error Resume Next
    xlWb.Sheets(intAktuellerMonat).Select
    On Error GoTo Err_Handler

Exit_Sub:
    Set xlWb = Nothing
    Set xlApp = Nothing
    Exit Sub

Err_Handler:
    MsgBox "Fehler " & Err.Number & ": " & Err.Description, vbCritical, "Fehler"
    Resume Exit_Sub
End Sub
'''

with AccessBridge() as bridge:
    print("=" * 70)
    print("KORRIGIERE btn_N_ExcelOeffnen_Click - Verwende Excel UsableWidth/Height")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_MA_Mitarbeiterstamm":
            code_module = comp.CodeModule
            total_lines = code_module.CountOfLines

            # Finde Start und Ende der alten Funktion
            start_line = 0
            end_line = 0

            for i in range(1, total_lines + 1):
                line = code_module.Lines(i, 1)
                if "Sub btn_N_ExcelOeffnen_Click" in line:
                    start_line = i
                    print(f"Alte Funktion gefunden bei Zeile {i}")
                if start_line > 0 and line.strip() == "End Sub":
                    end_line = i
                    print(f"Ende der Funktion bei Zeile {i}")
                    break

            if start_line > 0 and end_line > 0:
                # Lösche alte Funktion
                num_lines = end_line - start_line + 1
                print(f"Lösche {num_lines} Zeilen (Zeile {start_line} bis {end_line})")
                code_module.DeleteLines(start_line, num_lines)

                # Füge neue Funktion ein
                clean_code = new_code.strip()
                code_module.InsertLines(start_line, clean_code)
                print(f"Neue Funktion eingefügt ab Zeile {start_line}")

                print("\n[OK] Button-Code erfolgreich aktualisiert!")
            else:
                print("[FEHLER] Funktion nicht gefunden!")
            break

print("\n[FERTIG]")
