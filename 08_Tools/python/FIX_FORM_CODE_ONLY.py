"""
Fuegt nur den Formular-Code ein - nachdem Access bereit ist
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
import pythoncom
import time

FORM_CODE = '''
Private Sub lstMA_DblClick(Cancel As Integer)
    If Not IsNull(Me!lstMA) Then
        DP_MA_Doppelklick Me!lstMA
    End If
End Sub

Private Sub lst_MA_Auswahl_DblClick(Cancel As Integer)
    If Not IsNull(Me!lst_MA_Auswahl) Then
        DP_MA_Aus_Anfrage Me!lst_MA_Auswahl
    End If
End Sub

Private Sub cmd_MA_Anfragen_Click()
    DP_Mitarbeiter_Anfragen
End Sub

Private Sub sub_lstAuftrag_Current()
    On Error Resume Next
    Dim subFrm As Form
    Set subFrm = Me!sub_lstAuftrag.Form
    If Not subFrm.Recordset.EOF And Not subFrm.Recordset.BOF Then
        Dim VA_ID As Long, AnzTage_ID As Long, VADatum As Date
        VA_ID = Nz(subFrm!VA_ID, 0)
        AnzTage_ID = Nz(subFrm!AnzTage_ID, 0)
        VADatum = Nz(subFrm!Datum, Date)
        If VA_ID > 0 And AnzTage_ID > 0 Then
            DP_Auftrag_Ausgewaehlt VA_ID, AnzTage_ID, VADatum
        End If
    End If
    On Error GoTo 0
End Sub

Private Sub Form_Load()
    On Error Resume Next
    CurrentDb.Execute "DELETE FROM ztbl_MA_Schnellauswahl"
    Me!lst_MA_Auswahl.Requery
    Me!lstMA.Requery
    On Error GoTo 0
End Sub

Private Sub btn_N_AnsichtWechseln_Click()
    On Error Resume Next
    Dim VA_ID As Long
    VA_ID = DP_Get_CurrentVA_ID()
    DoCmd.Close acForm, Me.Name, acSaveNo
    If VA_ID > 0 Then
        DoCmd.OpenForm "frm_va_auftragstamm", , , "ID = " & VA_ID
    Else
        DoCmd.OpenForm "frm_va_auftragstamm"
    End If
    On Error GoTo 0
End Sub
'''

SUBFORM_CODE = '''
Private Sub Form_Current()
    On Error Resume Next
    If Not Me.NewRecord Then
        DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    End If
    On Error GoTo 0
End Sub

Private Sub MA_Name_DblClick(Cancel As Integer)
    On Error Resume Next
    If Nz(Me!MA_ID, 0) = 0 Then
        DP_Einsatzliste_Click Nz(Me!ID, 0), Nz(Me!VAStart_ID, 0), Nz(Me!MA_Start, 0), Nz(Me!MA_Ende, 0)
    End If
    On Error GoTo 0
End Sub
'''

print("=" * 70)
print("FORMULAR-CODE EINFUEGEN")
print("=" * 70)
print()
print("Stellen Sie sicher dass:")
print("  - Access offen ist")
print("  - Das Frontend geladen ist")
print("  - Keine Formulare offen sind")
print()

try:
    pythoncom.CoInitialize()

    print("[...] Verbinde zu Access...")
    app = win32com.client.GetObject(Class="Access.Application")
    print("[OK] Verbunden")

    app.DoCmd.SetWarnings(False)

    # Alle Formulare schliessen
    print("\n[1] Schliesse alle Formulare...")
    for form_name in ["frm_N_DP_Dashboard", "zsub_N_DP_Einsatzliste"]:
        try:
            app.DoCmd.Close(2, form_name, 2)
        except:
            pass
    time.sleep(0.5)

    # Hauptformular oeffnen und Code einfuegen
    print("\n[2] Oeffne frm_N_DP_Dashboard im Design-Modus...")
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
    time.sleep(0.5)

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    print("\n[3] Suche Form-Modul...")
    form_found = False

    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_N_DP_Dashboard":
            print(f"    [OK] Gefunden: {comp.Name}")
            cm = comp.CodeModule
            if cm.CountOfLines > 0:
                cm.DeleteLines(1, cm.CountOfLines)
            cm.AddFromString(FORM_CODE)
            print(f"    [OK] Code eingefuegt ({cm.CountOfLines} Zeilen)")
            form_found = True
            break

    if not form_found:
        print("    [!] Form_frm_N_DP_Dashboard nicht gefunden")
        print("    Versuche alternatives Modul...")
        for comp in proj.VBComponents:
            if comp.Type == 100 and "Dashboard" in comp.Name:
                print(f"    Gefunden: {comp.Name}")
                cm = comp.CodeModule
                if cm.CountOfLines > 0:
                    cm.DeleteLines(1, cm.CountOfLines)
                cm.AddFromString(FORM_CODE)
                print(f"    [OK] Code eingefuegt")
                break

    app.RunCommand(3)  # Save
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("[OK] Hauptformular gespeichert")

    time.sleep(0.3)

    # Unterformular
    print("\n[4] Oeffne zsub_N_DP_Einsatzliste im Design-Modus...")
    app.DoCmd.OpenForm("zsub_N_DP_Einsatzliste", 1)
    time.sleep(0.5)

    # AllowEdits setzen
    frm = app.Forms("zsub_N_DP_Einsatzliste")
    frm.AllowEdits = True
    frm.AllowAdditions = False
    frm.AllowDeletions = False
    print("    [OK] AllowEdits = True")

    vbe = app.VBE
    proj = vbe.ActiveVBProject

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
    print("FERTIG!")
    print("=" * 70)
    print("\nBitte oeffnen Sie jetzt frm_N_DP_Dashboard und testen.")

except Exception as e:
    print(f"\n[FEHLER] {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()
