"""
Aktualisiere btn_N_ExcelOeffnen - Excel mit exakten cm-Maßen positionieren
7 cm vom linken Rand, 5 cm vom oberen Rand, 20 cm breit, 15 cm hoch
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

# Excel verwendet Punkte (Points) als Einheit: 1 cm = 28.35 Punkte
# 7 cm = 198.45 pt, 5 cm = 141.75 pt, 20 cm = 567 pt, 15 cm = 425.25 pt

new_code = '''
Private Sub btn_N_ExcelOeffnen_Click()
    On Error GoTo Err_Handler

    Dim strPfad As String
    Dim xlApp As Object
    Dim xlWb As Object
    Dim intAktuellerMonat As Integer

    ' Umrechnung cm zu Points (1 cm = 28.35 pt)
    Const dblCmToPoints As Double = 28.35
    Const dblLeft As Double = 7 * 28.35      ' 7 cm = 198.45 pt
    Const dblTop As Double = 5 * 28.35       ' 5 cm = 141.75 pt
    Const dblWidth As Double = 20 * 28.35    ' 20 cm = 567 pt
    Const dblHeight As Double = 15 * 28.35   ' 15 cm = 425.25 pt

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

    ' Fenster mit exakten Maßen positionieren
    xlApp.WindowState = -4143  ' xlNormal

    xlApp.Left = dblLeft
    xlApp.Top = dblTop
    xlApp.Width = dblWidth
    xlApp.Height = dblHeight

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
    print("AKTUALISIERE btn_N_ExcelOeffnen - Exakte cm-Positionierung")
    print("7cm links, 5cm oben, 20cm breit, 15cm hoch")
    print("=" * 70)

    vbe = bridge.access_app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_MA_Mitarbeiterstamm":
            code_module = comp.CodeModule
            total_lines = code_module.CountOfLines

            start_line = 0
            end_line = 0

            for i in range(1, total_lines + 1):
                line = code_module.Lines(i, 1)
                if "Sub btn_N_ExcelOeffnen_Click" in line:
                    start_line = i
                    print(f"Funktion gefunden bei Zeile {i}")
                if start_line > 0 and line.strip() == "End Sub":
                    end_line = i
                    break

            if start_line > 0 and end_line > 0:
                num_lines = end_line - start_line + 1
                code_module.DeleteLines(start_line, num_lines)
                code_module.InsertLines(start_line, new_code.strip())
                print(f"[OK] Button-Code aktualisiert!")
            break

print("\n[FERTIG]")
