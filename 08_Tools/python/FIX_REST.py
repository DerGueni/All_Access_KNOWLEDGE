"""
Fix den Rest - Form Code einfuegen (Access ist bereits offen)
"""
import win32com.client
import pythoncom
import time

FORM_CODE = '''
Private Sub lstMA_DblClick(Cancel As Integer)
    If Not IsNull(Me!lstMA) Then DP_MA_Doppelklick Me!lstMA
End Sub

Private Sub lst_MA_Auswahl_DblClick(Cancel As Integer)
    If Not IsNull(Me!lst_MA_Auswahl) Then DP_MA_Aus_Anfrage Me!lst_MA_Auswahl
End Sub

Private Sub cmd_MA_Anfragen_Click()
    DP_Mitarbeiter_Anfragen
End Sub

Private Sub sub_lstAuftrag_Current()
    On Error Resume Next
    Dim subFrm As Form: Set subFrm = Me!sub_lstAuftrag.Form
    If Not subFrm.Recordset.EOF And Not subFrm.Recordset.BOF Then
        Dim VA_ID As Long, AnzTage_ID As Long, VADatum As Date
        VA_ID = Nz(subFrm!VA_ID, 0): AnzTage_ID = Nz(subFrm!AnzTage_ID, 0): VADatum = Nz(subFrm!Datum, Date)
        If VA_ID > 0 And AnzTage_ID > 0 Then DP_Auftrag_Ausgewaehlt VA_ID, AnzTage_ID, VADatum
    End If
    On Error GoTo 0
End Sub

Private Sub Form_Load()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    Me!lst_MA_Auswahl.Requery: Me!lstMA.Requery
    On Error GoTo 0
End Sub

Private Sub btn_N_AnsichtWechseln_Click()
    On Error Resume Next
    Dim VA_ID As Long: VA_ID = DP_Get_CurrentVA_ID()
    DoCmd.Close acForm, Me.Name, acSaveNo
    If VA_ID > 0 Then DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & VA_ID Else DoCmd.OpenForm "frm_va_auftragstamm"
    On Error GoTo 0
End Sub
'''

SUBFORM_CODE = '''
Private Sub Form_Current()
    On Error Resume Next
    If Not Me.NewRecord Then DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    On Error GoTo 0
End Sub

Private Sub MA_Name_DblClick(Cancel As Integer)
    On Error Resume Next
    If Nz(Me!MA_ID, 0) = 0 Then DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    On Error GoTo 0
End Sub
'''

print("=" * 70)
print("FIX REST - Form Code einfuegen")
print("=" * 70)

try:
    pythoncom.CoInitialize()

    print("\n[1] Verbinde zu Access...")
    app = win32com.client.GetObject(Class="Access.Application")
    print("[OK] Verbunden")

    app.DoCmd.SetWarnings(False)

    # Formulare schliessen
    print("\n[2] Schliesse Formulare...")
    for f in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste"]:
        try:
            app.DoCmd.Close(2, f, 2)
        except:
            pass
    time.sleep(1)

    # Hauptformular
    print("\n[3] Hauptformular bearbeiten...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
    time.sleep(1)

    frm = app.Forms("frm_N_DP_Dashboard")
    frm.HasModule = True

    for i in range(frm.Controls.Count):
        ctl = frm.Controls(i)
        if ctl.Name == "lstMA":
            ctl.OnDblClick = "[Event Procedure]"
            print("    lstMA.OnDblClick gesetzt")
        elif ctl.Name == "lst_MA_Auswahl":
            ctl.OnDblClick = "[Event Procedure]"
            ctl.ColumnCount = 4
            ctl.ColumnWidths = "0;2800;600;600"
            print("    lst_MA_Auswahl Events und Spalten gesetzt")

    app.RunCommand(3)  # Save
    time.sleep(0.5)

    # Form-Code
    print("\n[4] Form-Code einfuegen...")
    vbe = app.VBE
    if vbe:
        proj = vbe.ActiveVBProject
        if proj:
            for comp in proj.VBComponents:
                if comp.Name == "Form_frm_N_DP_Dashboard":
                    cm = comp.CodeModule
                    if cm.CountOfLines > 0:
                        cm.DeleteLines(1, cm.CountOfLines)
                    cm.AddFromString(FORM_CODE)
                    print(f"    [OK] Form-Code eingefuegt ({cm.CountOfLines} Zeilen)")
                    break
            else:
                print("    [!] Form_frm_N_DP_Dashboard nicht gefunden")

    app.RunCommand(3)
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("[OK] Hauptformular gespeichert")

    time.sleep(0.5)

    # Unterformular
    print("\n[5] Unterformular bearbeiten...")
    app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
    time.sleep(0.5)

    frm = app.Forms("zsub_N_DP_Einsatzliste")
    frm.AllowEdits = True
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    frm.HasModule = True
    print("    AllowEdits = True")

    app.RunCommand(3)
    time.sleep(0.3)

    vbe = app.VBE
    if vbe:
        proj = vbe.ActiveVBProject
        if proj:
            for comp in proj.VBComponents:
                if comp.Name == "Form_zsub_N_DP_Einsatzliste":
                    cm = comp.CodeModule
                    if cm.CountOfLines > 0:
                        cm.DeleteLines(1, cm.CountOfLines)
                    cm.AddFromString(SUBFORM_CODE)
                    print(f"    [OK] Unterformular-Code eingefuegt ({cm.CountOfLines} Zeilen)")
                    break

    app.RunCommand(3)
    app.DoCmd.Close(2, "zsub_N_DP_Einsatzliste", 1)
    print("[OK] Unterformular gespeichert")

    app.DoCmd.SetWarnings(True)

    print("\n" + "=" * 70)
    print("FERTIG! Bitte Dashboard testen.")
    print("=" * 70)

except Exception as e:
    print(f"\n[FEHLER] {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()
