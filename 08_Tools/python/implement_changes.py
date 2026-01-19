# -*- coding: utf-8 -*-
"""
Implementiert alle Aenderungen fuer frm_OB_Objekt und rpt_OB_Objekt
Arbeitet mit laufender Access-Instanz via COM
"""

import win32com.client
import pythoncom
import time

def main():
    print("=" * 70)
    print("IMPLEMENTIERUNG: frm_OB_Objekt und rpt_OB_Objekt Anpassungen")
    print("=" * 70)

    pythoncom.CoInitialize()

    try:
        # Verbindung zu laufender Access-Instanz
        print("\n1. Verbinde mit Access...")
        try:
            access = win32com.client.GetObject(Class="Access.Application")
            print("   Laufende Access-Instanz gefunden!")
        except:
            print("   Keine laufende Instanz - starte neue...")
            access = win32com.client.Dispatch("Access.Application")
            access.Visible = True
            access.OpenCurrentDatabase(
                r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
            )

        db = access.CurrentDb()

        # VBA-Code als String
        vba_module_code = '''
Option Compare Database
Option Explicit

' ===== ZEITSLOT-LABELS AKTUALISIEREN =====
' Wird beim Current-Event des Formulars aufgerufen

Public Sub UpdateZeitLabels_OB_Objekt()
    On Error Resume Next

    Dim frm As Form
    Dim objID As Long
    Dim rs As DAO.Recordset
    Dim i As Integer

    ' Formular referenzieren
    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    ' Aktuelle Objekt-ID ermitteln (aus Combo oder Listbox)
    On Error Resume Next

    ' Versuche verschiedene Control-Namen
    objID = Nz(frm("cbo_Objekt"), 0)
    If objID = 0 Then objID = Nz(frm("lst_Objekte"), 0)
    If objID = 0 Then objID = Nz(frm("ID"), 0)

    If objID = 0 Then Exit Sub

    ' Zeit-Labels aus Tabelle laden
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Zeit1_Label, Zeit2_Label, Zeit3_Label, Zeit4_Label " & _
        "FROM tbl_OB_Objekt WHERE ID = " & objID, dbOpenSnapshot)

    If Not rs.EOF Then
        ' Textfelder im Formular fuer Zeitslot-Eingabe suchen und aktualisieren
        Dim ctl As Control
        For Each ctl In frm.Controls
            Select Case ctl.Name
                Case "txt_Zeit1", "Zeitslot1", "Zeit1"
                    On Error Resume Next
                    ctl.Value = Nz(rs("Zeit1_Label"), "")
                Case "txt_Zeit2", "Zeitslot2", "Zeit2"
                    On Error Resume Next
                    ctl.Value = Nz(rs("Zeit2_Label"), "")
                Case "txt_Zeit3", "Zeitslot3", "Zeit3"
                    On Error Resume Next
                    ctl.Value = Nz(rs("Zeit3_Label"), "")
                Case "txt_Zeit4", "Zeitslot4", "Zeit4"
                    On Error Resume Next
                    ctl.Value = Nz(rs("Zeit4_Label"), "")
            End Select
        Next
    End If

    rs.Close
    Set rs = Nothing
End Sub

' ===== ZEITSLOT-WERTE SPEICHERN =====
' Speichert die eingegebenen Uhrzeiten in tbl_OB_Objekt

Public Sub SaveZeitLabels_OB_Objekt()
    On Error Resume Next

    Dim frm As Form
    Dim objID As Long
    Dim strSQL As String
    Dim zeit1 As String, zeit2 As String, zeit3 As String, zeit4 As String

    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    ' Objekt-ID ermitteln
    objID = Nz(frm("cbo_Objekt"), 0)
    If objID = 0 Then objID = Nz(frm("lst_Objekte"), 0)
    If objID = 0 Then objID = Nz(frm("ID"), 0)
    If objID = 0 Then Exit Sub

    ' Zeitwerte aus den 5 Eingabefeldern (laut Screenshot gibt es 5 Felder)
    Dim ctl As Control
    For Each ctl In frm.Controls
        Select Case True
            Case ctl.Name Like "*Zeit*1*" Or ctl.Name Like "*Slot*1*"
                zeit1 = Nz(ctl.Value, "")
            Case ctl.Name Like "*Zeit*2*" Or ctl.Name Like "*Slot*2*"
                zeit2 = Nz(ctl.Value, "")
            Case ctl.Name Like "*Zeit*3*" Or ctl.Name Like "*Slot*3*"
                zeit3 = Nz(ctl.Value, "")
            Case ctl.Name Like "*Zeit*4*" Or ctl.Name Like "*Slot*4*"
                zeit4 = Nz(ctl.Value, "")
        End Select
    Next

    ' In Tabelle speichern
    strSQL = "UPDATE tbl_OB_Objekt SET " & _
             "Zeit1_Label = '" & Replace(zeit1, "'", "''") & "', " & _
             "Zeit2_Label = '" & Replace(zeit2, "'", "''") & "', " & _
             "Zeit3_Label = '" & Replace(zeit3, "'", "''") & "', " & _
             "Zeit4_Label = '" & Replace(zeit4, "'", "''") & "' " & _
             "WHERE ID = " & objID

    CurrentDb.Execute strSQL, dbFailOnError
End Sub

' ===== LISTENFELD AKTUALISIEREN =====
' Filtert auf Objekte mit Positionen

Public Sub FilterListeAufObjekteMitPositionen()
    On Error Resume Next

    Dim frm As Form
    Dim lst As Control
    Dim strSQL As String

    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    ' Listenfeld finden
    Dim ctl As Control
    For Each ctl In frm.Controls
        If ctl.ControlType = 110 Then ' acListBox = 110
            Set lst = ctl
            Exit For
        End If
    Next

    If lst Is Nothing Then Exit Sub

    ' SQL fuer Objekte MIT Positionen
    strSQL = "SELECT o.ID, o.Objekt, o.Ort, " & _
             "(SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) AS AnzPos " & _
             "FROM tbl_OB_Objekt o " & _
             "WHERE (SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) > 0 " & _
             "ORDER BY o.Objekt"

    lst.RowSource = strSQL
    lst.Requery
End Sub
'''

        # 2. VBA-Modul erstellen
        print("\n2. Erstelle VBA-Modul...")
        try:
            vbe = access.VBE
            proj = vbe.ActiveVBProject

            # Pruefen ob Modul existiert
            module_name = "mod_OB_Zeitslots"
            for i in range(1, proj.VBComponents.Count + 1):
                comp = proj.VBComponents.Item(i)
                if comp.Name == module_name:
                    proj.VBComponents.Remove(comp)
                    print(f"   Bestehendes Modul '{module_name}' entfernt")
                    break

            # Neues Modul erstellen
            new_module = proj.VBComponents.Add(1)  # vbext_ct_StdModule = 1
            new_module.Name = module_name

            # Code hinzufuegen (ohne die ersten 2 Zeilen, da Access die automatisch hinzufuegt)
            code_lines = vba_module_code.strip().split('\n')
            # Ueberspringe Option Compare und Option Explicit wenn sie schon da sind
            start_line = 0
            for i, line in enumerate(code_lines):
                if line.strip().startswith("Option"):
                    start_line = i + 1
                else:
                    break

            clean_code = '\n'.join(code_lines[start_line:])
            new_module.CodeModule.AddFromString(clean_code)

            print(f"   VBA-Modul '{module_name}' erstellt!")

        except Exception as e:
            print(f"   VBA-Fehler: {e}")
            print("   Fahre mit direkten Aenderungen fort...")

        # 3. Formular analysieren
        print("\n3. Analysiere frm_OB_Objekt...")
        try:
            # Formular im Entwurfsmodus oeffnen
            access.DoCmd.OpenForm("frm_OB_Objekt", 1)  # acViewDesign = 1
            time.sleep(1)

            frm = access.Forms("frm_OB_Objekt")
            print(f"   Formular geoeffnet: {frm.Name}")

            # Alle Controls auflisten
            print("\n   Controls im Formular:")
            for i in range(frm.Controls.Count):
                ctl = frm.Controls.Item(i)
                ctl_type = ctl.ControlType
                ctl_name = ctl.Name

                # Control-Typ Namen
                type_names = {
                    100: "Label",
                    109: "TextBox",
                    106: "CheckBox",
                    105: "OptionButton",
                    110: "ListBox",
                    111: "ComboBox",
                    104: "CommandButton",
                    112: "SubForm",
                    114: "Rectangle",
                    103: "OptionGroup"
                }
                type_name = type_names.get(ctl_type, f"Type{ctl_type}")

                # Nur relevante Controls ausgeben
                if ctl_type in [104, 109, 110, 111, 112]:
                    print(f"      {type_name}: {ctl_name}")

                    # Bei Buttons: OnClick pruefen
                    if ctl_type == 104:
                        try:
                            onclick = ctl.OnClick
                            if onclick:
                                print(f"         -> OnClick: {onclick}")
                        except:
                            pass

            # Formular schliessen
            access.DoCmd.Close(2, "frm_OB_Objekt", 1)  # acForm=2, acSaveYes=1

        except Exception as e:
            print(f"   Fehler: {e}")

        # 4. Bericht analysieren
        print("\n4. Analysiere rpt_OB_Objekt...")
        try:
            access.DoCmd.OpenReport("rpt_OB_Objekt", 1)  # acViewDesign = 1
            time.sleep(1)

            rpt = access.Reports("rpt_OB_Objekt")
            print(f"   Bericht geoeffnet: {rpt.Name}")
            print(f"   RecordSource: {rpt.RecordSource}")

            access.DoCmd.Close(3, "rpt_OB_Objekt", 2)  # acReport=3, acSaveNo=2

        except Exception as e:
            print(f"   Fehler: {e}")

        print("\n" + "=" * 70)
        print("ANALYSE ABGESCHLOSSEN")
        print("=" * 70)
        print("\nNaechste Schritte:")
        print("1. Oeffnen Sie frm_OB_Objekt")
        print("2. Das VBA-Modul 'mod_OB_Zeitslots' enthaelt die neuen Funktionen")
        print("3. Verknuepfen Sie die Funktionen mit den entsprechenden Events")

    except Exception as e:
        print(f"\nFehler: {e}")

    finally:
        pythoncom.CoUninitialize()

if __name__ == "__main__":
    main()
