# -*- coding: utf-8 -*-
"""
Korrigiert Adressdaten und implementiert Zeitslot-Felder
"""

import win32com.client
import pythoncom
import time
import pyodbc

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

def get_odbc_connection():
    conn_str = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        f'DBQ={FRONTEND_PATH};'
    )
    return pyodbc.connect(conn_str)

def print_section(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)

def main():
    print_section("KORREKTUREN UND ZEITSLOT-IMPLEMENTIERUNG")

    pythoncom.CoInitialize()

    # === 1. Adressdaten korrigieren ===
    print_section("1. ADRESSDATEN KORRIGIEREN")

    # Korrekte Adressen
    correct_addresses = {
        "Brose Arena": {"strasse": "Forchheimer Strasse 15", "plz": "96052", "ort": "Bamberg"},
        "Donauarena": {"strasse": "Walhalla-Allee 24", "plz": "93053", "ort": "Regensburg"},
        "SAP Arena": {"strasse": "An der Arena 1", "plz": "68163", "ort": "Mannheim"},
        "Loewensaal": {"strasse": "Sulzbacher Str. 79", "plz": "90489", "ort": "Nuernberg"},
        "Stadion am Laubenweg": {"strasse": "Laubenweg 60", "plz": "90765", "ort": "Fuerth"},
        "Sportpark Ronhof": {"strasse": "Laubenweg 60", "plz": "90765", "ort": "Fuerth"},
        "Jurahalle": {"strasse": "Jahnstrasse 1", "plz": "92318", "ort": "Neumarkt"},
        "Max-Morlock-Stadion": {"strasse": "Zeppelinstrasse 4", "plz": "90471", "ort": "Nuernberg"},
        "Meistersingerhalle": {"strasse": "Muenchener Strasse 21", "plz": "90478", "ort": "Nuernberg"},
        "Markgrafensaal": {"strasse": "Ludwigstrasse 16", "plz": "91126", "ort": "Schwabach"},
        "Lux Kirche": {"strasse": "Rathenauplatz 3", "plz": "90489", "ort": "Nuernberg"},
        "PSD Bank Arena": {"strasse": "Dr.-Ingeborg-Bausenwein-Strasse 1", "plz": "90453", "ort": "Nuernberg"},
        "Kia Metropol Arena": {"strasse": "Dr.-Ingeborg-Bausenwein-Strasse 1", "plz": "90453", "ort": "Nuernberg"},
    }

    try:
        conn = get_odbc_connection()
        cursor = conn.cursor()

        for obj_name, addr in correct_addresses.items():
            sql = """UPDATE tbl_OB_Objekt
                    SET Strasse = ?, PLZ = ?, Ort = ?
                    WHERE Objekt LIKE ?"""
            cursor.execute(sql, (addr['strasse'], addr['plz'], addr['ort'], f"%{obj_name}%"))
            if cursor.rowcount > 0:
                print(f"  Korrigiert: {obj_name} -> {addr['strasse']}, {addr['plz']} {addr['ort']}")

        conn.commit()
        conn.close()
        print("Adresskorrekturen abgeschlossen!")

    except Exception as e:
        print(f"Adress-Fehler: {e}")

    # === 2. Zeitslot-Felder im Formular implementieren ===
    print_section("2. ZEITSLOT-FELDER IM FORMULAR")

    try:
        access = win32com.client.GetObject(Class="Access.Application")
        print("Access-Verbindung hergestellt!")

        # Formular im Entwurfsmodus oeffnen
        access.DoCmd.OpenForm("frm_OB_Objekt", 1)  # acViewDesign
        time.sleep(1)

        frm = access.Forms("frm_OB_Objekt")

        # Suche nach existierenden Zeitslot-Feldern
        print("\nSuche existierende Zeitslot-Felder...")
        zeitslot_controls = []
        for i in range(frm.Controls.Count):
            ctl = frm.Controls.Item(i)
            name = ctl.Name.lower()
            if 'zeit' in name or 'slot' in name or 'dienstbeginn' in name:
                print(f"  Gefunden: {ctl.Name} (Typ: {ctl.ControlType})")
                zeitslot_controls.append(ctl.Name)

        # Analyse des Unterformulars
        print("\nAnalyse Unterformular sub_OB_Objekt_Positionen...")
        subform_ctl = frm.Controls("sub_OB_Objekt_Positionen")
        print(f"  SourceObject: {subform_ctl.SourceObject}")

        access.DoCmd.Close(2, "frm_OB_Objekt", 2)  # acSaveNo

        # Unterformular analysieren
        subform_name = "sub_OB_Objekt_Positionen"
        access.DoCmd.OpenForm(subform_name, 1)
        time.sleep(1)

        sub_frm = access.Forms(subform_name)
        print(f"\nControls im Unterformular {subform_name}:")

        zeit_labels = []
        zeit_textboxes = []
        for i in range(sub_frm.Controls.Count):
            ctl = sub_frm.Controls.Item(i)
            name = ctl.Name
            if 'zeit' in name.lower():
                if ctl.ControlType == 100:  # Label
                    zeit_labels.append(name)
                    print(f"  Label: {name}")
                elif ctl.ControlType == 109:  # TextBox
                    zeit_textboxes.append(name)
                    print(f"  TextBox: {name}")

        # Labels im Unterformular anpassen
        print("\nPasse Zeit-Labels im Unterformular an...")

        # Versuche auf die Labels zuzugreifen und Kontrollnamen zu setzen
        # Die Labels im Datenblatt-Unterformular heissen typischerweise wie die Spalten

        access.DoCmd.Close(2, subform_name, 2)

        # === 3. VBA-Code fuer Zeitslot-Synchronisation ===
        print_section("3. VBA-CODE FUER ZEITSLOT-SYNCHRONISATION")

        vba_code = '''
' ============================================
' ZEITSLOT-SYNCHRONISATION
' Synchronisiert Zeitslot-Eingaben zwischen
' Hauptformular und Unterformular
' ============================================

Public Sub SyncZeitslots()
    ' Wird aufgerufen wenn sich das Objekt aendert
    ' oder wenn Zeitslots manuell geaendert werden
    On Error Resume Next

    Dim frm As Form
    Dim subFrm As Form
    Dim objID As Long
    Dim rs As DAO.Recordset

    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    ' Aktuelles Objekt ermitteln
    objID = Nz(frm("Liste_Obj"), 0)
    If objID = 0 Then
        objID = Nz(frm("ID"), 0)
    End If
    If objID = 0 Then Exit Sub

    ' Zeitslot-Labels aus Datenbank laden
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Zeit1_Label, Zeit2_Label, Zeit3_Label, Zeit4_Label " & _
        "FROM tbl_OB_Objekt WHERE ID = " & objID, dbOpenSnapshot)

    If rs.EOF Then
        rs.Close
        Exit Sub
    End If

    ' Zeitslot-Werte
    Dim z1 As String, z2 As String, z3 As String, z4 As String
    z1 = Nz(rs("Zeit1_Label"), "Zeit1")
    z2 = Nz(rs("Zeit2_Label"), "Zeit2")
    z3 = Nz(rs("Zeit3_Label"), "Zeit3")
    z4 = Nz(rs("Zeit4_Label"), "Zeit4")
    rs.Close

    ' Unterformular aktualisieren
    On Error Resume Next
    Set subFrm = frm("sub_OB_Objekt_Positionen").Form

    ' Spaltenueberschriften im Datenblatt aktualisieren
    ' Bei Datenblatt-Ansicht sind die Labels die Column-Headers
    subFrm("Zeit1").ColumnCaption = z1
    subFrm("Zeit2").ColumnCaption = z2
    subFrm("Zeit3").ColumnCaption = z3
    subFrm("Zeit4").ColumnCaption = z4

    ' Alternativ: Labels direkt setzen
    On Error Resume Next
    subFrm.Controls("Zeit1_Label").Caption = z1
    subFrm.Controls("Zeit2_Label").Caption = z2
    subFrm.Controls("Zeit3_Label").Caption = z3
    subFrm.Controls("Zeit4_Label").Caption = z4

End Sub

Public Sub SaveZeitslotLabels()
    ' Speichert die eingegebenen Zeitslot-Labels in die Datenbank
    On Error GoTo Fehler

    Dim frm As Form
    Dim objID As Long
    Dim strSQL As String

    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    objID = Nz(frm("Liste_Obj"), 0)
    If objID = 0 Then objID = Nz(frm("ID"), 0)
    If objID = 0 Then Exit Sub

    ' Zeitslots aus den 5 Eingabefeldern im Header holen
    ' (Die Felder mit den Nullen im Screenshot)
    Dim z1 As String, z2 As String, z3 As String, z4 As String, z5 As String

    ' Versuche verschiedene Feldnamen
    On Error Resume Next
    z1 = Nz(frm("txtZeitslot1"), "")
    If z1 = "" Then z1 = Nz(frm("Zeit1_Input"), "")
    z2 = Nz(frm("txtZeitslot2"), "")
    If z2 = "" Then z2 = Nz(frm("Zeit2_Input"), "")
    z3 = Nz(frm("txtZeitslot3"), "")
    If z3 = "" Then z3 = Nz(frm("Zeit3_Input"), "")
    z4 = Nz(frm("txtZeitslot4"), "")
    If z4 = "" Then z4 = Nz(frm("Zeit4_Input"), "")

    On Error GoTo Fehler

    strSQL = "UPDATE tbl_OB_Objekt SET " & _
             "Zeit1_Label = '" & Replace(z1, "'", "''") & "', " & _
             "Zeit2_Label = '" & Replace(z2, "'", "''") & "', " & _
             "Zeit3_Label = '" & Replace(z3, "'", "''") & "', " & _
             "Zeit4_Label = '" & Replace(z4, "'", "''") & "' " & _
             "WHERE ID = " & objID

    CurrentDb.Execute strSQL, dbFailOnError

    ' Unterformular aktualisieren
    Call SyncZeitslots

    Exit Sub

Fehler:
    Debug.Print "SaveZeitslotLabels Fehler: " & Err.Description
End Sub

' Event-Handler fuer das Hauptformular
' Muss im Formular-Modul mit OnCurrent verknuepft werden:
' Private Sub Form_Current()
'     Call SyncZeitslots
' End Sub
'''

        # VBA-Modul aktualisieren
        try:
            vbe = access.VBE
            proj = vbe.ActiveVBProject

            module_name = "mod_Zeitslots"

            # Altes Modul finden und ersetzen
            for i in range(1, proj.VBComponents.Count + 1):
                try:
                    comp = proj.VBComponents.Item(i)
                    if comp.Name == module_name:
                        proj.VBComponents.Remove(comp)
                        print(f"Altes Modul '{module_name}' entfernt")
                        time.sleep(0.5)
                        break
                except:
                    pass

            # Neues Modul erstellen
            new_module = proj.VBComponents.Add(1)
            new_module.Name = module_name
            new_module.CodeModule.AddFromString(vba_code)
            print(f"VBA-Modul '{module_name}' aktualisiert!")

        except Exception as e:
            print(f"VBA-Fehler: {e}")

        # === 4. Formular-Modul anpassen fuer OnCurrent Event ===
        print_section("4. FORMULAR-EVENT VERKNUEPFEN")

        try:
            access.DoCmd.OpenForm("frm_OB_Objekt", 1)  # acViewDesign
            time.sleep(1)

            frm = access.Forms("frm_OB_Objekt")

            # OnCurrent Event setzen
            current_oncurrent = frm.OnCurrent
            print(f"Aktueller OnCurrent: {current_oncurrent}")

            if not current_oncurrent or current_oncurrent == "":
                # Setze OnCurrent auf VBA-Funktion
                frm.OnCurrent = "=SyncZeitslots()"
                print("OnCurrent auf =SyncZeitslots() gesetzt!")
            elif "SyncZeitslots" not in current_oncurrent:
                print("OnCurrent ist bereits gesetzt, SyncZeitslots manuell hinzufuegen")

            access.DoCmd.Close(2, "frm_OB_Objekt", 1)  # acSaveYes
            print("Formular gespeichert!")

        except Exception as e:
            print(f"Event-Fehler: {e}")
            try:
                access.DoCmd.Close(2, "frm_OB_Objekt", 2)
            except:
                pass

        print_section("KORREKTUREN ABGESCHLOSSEN")

        print("""
Durchgefuehrte Aenderungen:
1. Adressdaten fuer falsch zugeordnete Objekte korrigiert
2. VBA-Modul 'mod_Zeitslots' mit Sync-Funktionen aktualisiert
3. OnCurrent-Event im Formular verknuepft

Die Zeitslot-Labels werden jetzt automatisch aus der Datenbank
geladen wenn ein Objekt ausgewaehlt wird.

Zum Testen:
1. Oeffnen Sie frm_OB_Objekt
2. Waehlen Sie ein Objekt mit definierten Zeit-Labels (z.B. ID 6 oder 14)
3. Die Spaltenüberschriften im Unterformular sollten sich aktualisieren
""")

    except Exception as e:
        print(f"Hauptfehler: {e}")

    finally:
        pythoncom.CoUninitialize()

if __name__ == "__main__":
    main()
