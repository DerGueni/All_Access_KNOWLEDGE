"""
Fix Form Code - Fügt den VBA-Code zum richtigen Formular hinzu
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge
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
        Dim VA_ID As Long
        Dim AnzTage_ID As Long
        Dim VADatum As Date

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

print("=" * 70)
print("FIX FORM CODE")
print("=" * 70)

try:
    with AccessBridge() as bridge:
        vbe = bridge.access_app.VBE
        proj = vbe.ActiveVBProject

        print("\n[1] Suche alle Form-Module mit 'Dashboard' oder 'DP'...")

        dashboard_forms = []
        for comp in proj.VBComponents:
            if comp.Type == 100:  # vbext_ct_Document (Form/Report)
                if "Dashboard" in comp.Name or "DP_Dashboard" in comp.Name or "DB_Dashboard" in comp.Name:
                    dashboard_forms.append(comp.Name)
                    print(f"    Gefunden: {comp.Name}")

        print(f"\n[2] Aktualisiere Code in gefundenen Formularen...")

        for form_name in dashboard_forms:
            for comp in proj.VBComponents:
                if comp.Name == form_name:
                    print(f"\n    Bearbeite: {form_name}")
                    code_module = comp.CodeModule

                    # Aktuellen Code anzeigen
                    if code_module.CountOfLines > 0:
                        current_code = code_module.Lines(1, code_module.CountOfLines)
                        print(f"    Aktueller Code hat {code_module.CountOfLines} Zeilen")

                        # Code loeschen und neu einfuegen
                        code_module.DeleteLines(1, code_module.CountOfLines)
                        code_module.AddFromString(FORM_CODE)
                        print(f"    [OK] Code aktualisiert")
                    else:
                        code_module.AddFromString(FORM_CODE)
                        print(f"    [OK] Code eingefuegt")
                    break

        # ListBox Spalten korrigieren
        print("\n[3] ListBox Spalten korrigieren...")

        try:
            bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
        except:
            pass
        time.sleep(0.3)

        bridge.access_app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
        time.sleep(0.5)
        frm = bridge.access_app.Forms("frm_N_DP_Dashboard")

        for i in range(frm.Controls.Count):
            ctl = frm.Controls(i)
            if ctl.Name == "lst_MA_Auswahl":
                print(f"    lst_MA_Auswahl gefunden")
                print(f"    Aktuell: ColumnCount={ctl.ColumnCount}, ColumnWidths={ctl.ColumnWidths}")
                ctl.ColumnCount = 4
                ctl.ColumnWidths = "0;2800;600;600"
                print(f"    Neu: ColumnCount=4, ColumnWidths=0;2800;600;600")
                break

        bridge.access_app.RunCommand(3)  # Save
        bridge.access_app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
        print("    [OK] Formular gespeichert")

        print("\n" + "=" * 70)
        print("[OK] FERTIG - Bitte Dashboard neu oeffnen")
        print("=" * 70)

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()
