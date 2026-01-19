import win32com.client
import sys
import time

print("=== START Formatierungskonfiguration ===")

try:
    # Access öffnen
    print("Erstelle Access.Application...")
    access = win32com.client.Dispatch("Access.Application")
    access.Visible = False
    
    db_path = r"C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb"
    print(f"Öffne DB: {db_path}")
    access.OpenCurrentDatabase(db_path)
    print("✓ DB geöffnet")
    
    # VBA-Code
    vba_code = '''Option Compare Database
Option Explicit

Public Sub Configure_Ist_ConditionalFormatting()
    Const FORM_NAME As String = "frm_lst_row_auftrag"
    Dim hasTxtOffene As Boolean, ctl As Control, istCtl As Control
    
    DoCmd.OpenForm FORM_NAME, View:=acDesign, WindowMode:=acHidden
    
    hasTxtOffene = False
    For Each ctl In Forms(FORM_NAME).Controls
        If ctl.Name = "txtOffeneAnfragen" Then: hasTxtOffene = True: Exit For
    Next
    
    If Not hasTxtOffene Then
        Dim txt As Control
        Set txt = Application.CreateControl(FORM_NAME, acTextBox, acDetail)
        txt.Name = "txtOffeneAnfragen"
        txt.Top = 0: txt.Left = 0: txt.Width = 100: txt.Height = 200
    End If
    
    With Forms(FORM_NAME).Controls("txtOffeneAnfragen")
        .ControlSource = "=Nz(DCount(""""*""""; """"qry_MA_Offene_Anfragen""""; """"VA_ID="""" & [ID]);0)"
        .Visible = False: .Locked = True: .TabStop = False
    End With
    
    DoCmd.Close acForm, FORM_NAME, acSaveYes
    DoCmd.OpenForm FORM_NAME, View:=acNormal
    
    On Error Resume Next
    Set istCtl = Forms(FORM_NAME).Controls("Ist")
    On Error GoTo 0
    If istCtl Is Nothing Then
        For Each ctl In Forms(FORM_NAME).Controls
            If ctl.ControlType = acTextBox And LCase$(Nz(ctl.ControlSource,"")) = "ist" Then
                Set istCtl = ctl: Exit For
            End If
        Next
    End If
    If istCtl Is Nothing Then: MsgBox "Ist-Feld nicht gefunden", vbExclamation: Exit Sub
    
    With istCtl.FormatConditions
        .Delete
        Dim fc As FormatCondition
        Set fc = .Add(Type:=acExpression, Expression:="[txtOffeneAnfragen] > 0")
        fc.ForeColor = vbBlue
        Set fc = .Add(Type:=acExpression, Expression:="[txtOffeneAnfragen] = 0 And Nz([Ist],0) <> Nz([Soll],0)")
        fc.ForeColor = vbRed
    End With
    
    Forms(FORM_NAME).Recalc
    DoCmd.RunCommand acCmdSaveRecord
    DoCmd.Close acForm, FORM_NAME, acSaveYes
    MsgBox "Formatierung konfiguriert!", vbInformation
End Sub'''
    
    # VBE-Zugriff
    print("Erstelle VBA-Modul...")
    vbe = access.VBE
    vb_project = vbe.ActiveVBProject
    
    # Altes Modul löschen
    for component in vb_project.VBComponents:
        if component.Name == "mod_InitIstFormat":
            vb_project.VBComponents.Remove(component)
            print("  Altes Modul entfernt")
            break
    
    # Neues Modul erstellen
    vb_module = vb_project.VBComponents.Add(1)  # 1 = vbext_ct_StdModule
    vb_module.Name = "mod_InitIstFormat"
    vb_module.CodeModule.AddFromString(vba_code)
    print("✓ Modul erstellt")
    
    # Prozedur ausführen
    print("Führe Konfiguration aus...")
    access.Run("Configure_Ist_ConditionalFormatting")
    print("✓ Prozedur ausgeführt")
    
    # Schließen
    print("Schließe Access...")
    access.Quit()
    print("✓ Access geschlossen")
    
    print()
    print("==========================================")
    print("ERFOLGREICH ABGESCHLOSSEN")
    print("==========================================")
    print()
    print("Feld 'Ist' in frm_lst_row_auftrag:")
    print("  • BLAU = Offene Mitarbeiteranfragen")
    print("  • ROT = Keine Anfragen offen, Ist ≠ Soll")
    print()
    
except Exception as e:
    print(f"FEHLER: {e}")
    print(f"Typ: {type(e).__name__}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
