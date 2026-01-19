"""
Fix: Stellt sicher dass frm_N_DP_Dashboard ein Modul hat und der Code darin ist
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
print("FIX FORMULAR-MODUL")
print("=" * 70)

try:
    pythoncom.CoInitialize()

    app = win32com.client.GetObject(Class="Access.Application")
    print("[OK] Access verbunden")

    # 1. Alle Form-Module auflisten
    print("\n[1] Alle Form-Module mit 'Dashboard' oder 'DP':")

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    for comp in proj.VBComponents:
        if comp.Type == 100:  # Document (Form/Report)
            if "Dashboard" in comp.Name or "DP" in comp.Name:
                print(f"    {comp.Name}")

    # 2. Formular öffnen und HasModule prüfen
    print("\n[2] Pruefe frm_N_DP_Dashboard...")

    try:
        app.DoCmd.Close(2, "frm_N_DP_Dashboard", 2)
    except:
        pass
    time.sleep(0.3)

    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)  # acDesign
    time.sleep(0.5)

    frm = app.Forms("frm_N_DP_Dashboard")

    has_module = frm.HasModule
    print(f"    HasModule: {has_module}")

    if not has_module:
        print("    [!] Formular hat KEIN Modul - aktiviere HasModule...")
        frm.HasModule = True
        print("    [OK] HasModule aktiviert")

    # 3. Formular-Modul mit Code füllen
    print("\n[3] Fuege Code zum Formular-Modul hinzu...")

    # Speichern und neu öffnen damit das Modul erstellt wird
    app.RunCommand(3)
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    time.sleep(0.5)

    # Jetzt sollte Form_frm_N_DP_Dashboard existieren
    app.DoCmd.OpenForm("frm_N_DP_Dashboard", 1)
    time.sleep(0.3)

    # VBE neu holen
    vbe = app.VBE
    proj = vbe.ActiveVBProject

    form_module = None
    for comp in proj.VBComponents:
        if comp.Name == "Form_frm_N_DP_Dashboard":
            form_module = comp
            print(f"    Gefunden: {comp.Name}")
            break

    if form_module:
        cm = form_module.CodeModule
        print(f"    Aktuelle Zeilen: {cm.CountOfLines}")

        # Code löschen und neu einfügen
        if cm.CountOfLines > 0:
            cm.DeleteLines(1, cm.CountOfLines)

        cm.AddFromString(FORM_CODE)
        print(f"    [OK] Code eingefuegt ({cm.CountOfLines} Zeilen)")
    else:
        print("    [!] Form_frm_N_DP_Dashboard nicht gefunden!")

        # Vielleicht heißt es anders - alle Module nochmal auflisten
        print("\n    Alle Form-Module:")
        for comp in proj.VBComponents:
            if comp.Type == 100:
                print(f"      {comp.Name}")

    # 4. Speichern
    print("\n[4] Speichere...")
    app.RunCommand(3)
    app.DoCmd.Close(2, "frm_N_DP_Dashboard", 1)
    print("    [OK] Gespeichert")

    print("\n" + "=" * 70)
    print("[OK] FERTIG - Bitte Dashboard testen")
    print("=" * 70)

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()
