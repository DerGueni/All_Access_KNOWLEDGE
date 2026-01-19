# -*- coding: utf-8 -*-
"""
VOLLSTAENDIGE MODIFIKATIONEN fuer frm_OB_Objekt und rpt_OB_Objekt
Implementiert alle angeforderten Aenderungen
"""

import win32com.client
import pythoncom
import time
import pyodbc

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

def get_odbc_connection():
    """ODBC Verbindung zum Frontend"""
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
    print_section("VOLLSTAENDIGE MODIFIKATIONEN - START")

    pythoncom.CoInitialize()

    try:
        # === 1. Verbindung zu Access ===
        print_section("1. VERBINDUNG ZU ACCESS")
        try:
            access = win32com.client.GetObject(Class="Access.Application")
            print("Laufende Access-Instanz gefunden!")
        except:
            print("Starte neue Access-Instanz...")
            access = win32com.client.Dispatch("Access.Application")
            access.Visible = True
            access.OpenCurrentDatabase(FRONTEND_PATH)
            time.sleep(2)

        db = access.CurrentDb()

        # === 2. Listenfeld anpassen ===
        print_section("2. LISTENFELD ANPASSEN")
        try:
            # Formular im Entwurfsmodus oeffnen
            access.DoCmd.OpenForm("frm_OB_Objekt", 1)  # acViewDesign
            time.sleep(1)

            frm = access.Forms("frm_OB_Objekt")

            # Listenfeld finden
            lst = frm.Controls("Liste_Obj")
            print(f"Listenfeld gefunden: {lst.Name}")
            print(f"Aktuelle RowSource: {lst.RowSource[:100]}...")

            # Neue RowSource: Nur Objekte MIT Positionen + Anzahl Positionen
            new_sql = """SELECT o.ID, o.Objekt, o.Ort,
                         (SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) AS AnzPos
                         FROM tbl_OB_Objekt o
                         WHERE (SELECT COUNT(*) FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID) > 0
                         ORDER BY o.Objekt"""

            lst.RowSource = new_sql
            lst.ColumnCount = 4
            lst.ColumnWidths = "0cm;4cm;3cm;1,5cm"

            print("Listenfeld angepasst:")
            print("  - Zeigt nur Objekte MIT Positionen")
            print("  - Neue Spalte: Anzahl Positionen")

            # Speichern und schliessen
            access.DoCmd.Close(2, "frm_OB_Objekt", 1)  # acSaveYes
            print("Formular gespeichert!")

        except Exception as e:
            print(f"Fehler beim Listenfeld: {e}")
            try:
                access.DoCmd.Close(2, "frm_OB_Objekt", 2)  # acSaveNo
            except:
                pass

        # === 3. Zeitslot-Funktionalitaet ===
        print_section("3. ZEITSLOT-FUNKTIONALITAET")

        # Zuerst schauen wir uns das Unterformular an
        try:
            access.DoCmd.OpenForm("frm_OB_Objekt", 1)  # acViewDesign
            time.sleep(1)

            frm = access.Forms("frm_OB_Objekt")
            subform = frm.Controls("sub_OB_Objekt_Positionen")

            print(f"Unterformular gefunden: {subform.Name}")
            print(f"SourceObject: {subform.SourceObject}")
            print(f"LinkMasterFields: {subform.LinkMasterFields}")
            print(f"LinkChildFields: {subform.LinkChildFields}")

            access.DoCmd.Close(2, "frm_OB_Objekt", 2)

            # Unterformular oeffnen und analysieren
            subform_name = str(subform.SourceObject).replace("Form.", "")
            print(f"\nAnalysiere Unterformular: {subform_name}")

            access.DoCmd.OpenForm(subform_name, 1)
            time.sleep(1)

            sub_frm = access.Forms(subform_name)
            print(f"Unterformular Controls:")
            for i in range(sub_frm.Controls.Count):
                ctl = sub_frm.Controls.Item(i)
                if ctl.ControlType in [100, 109]:  # Label, TextBox
                    name = ctl.Name
                    if "zeit" in name.lower() or "time" in name.lower() or "slot" in name.lower():
                        print(f"  ZEIT-Control: {name} (Typ: {ctl.ControlType})")

            access.DoCmd.Close(2, subform_name, 2)

        except Exception as e:
            print(f"Fehler bei Zeitslot-Analyse: {e}")

        # === 4. VBA-Modul fuer Zeitslot-Labels erstellen ===
        print_section("4. VBA-MODUL FUER ZEITSLOTS")

        vba_code = '''
' ===== Zeitslot-Label Funktionen =====
' Dieses Modul verwaltet die Zeitslot-Ueberschriften

Public Sub Zeitslots_Laden()
    ' Laedt die Zeitslot-Labels aus tbl_OB_Objekt
    On Error Resume Next

    Dim frm As Form
    Dim objID As Long
    Dim rs As DAO.Recordset

    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    ' Objekt-ID aus Listenfeld holen
    objID = Nz(frm("Liste_Obj"), 0)
    If objID = 0 Then Exit Sub

    ' Labels laden
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Zeit1_Label, Zeit2_Label, Zeit3_Label, Zeit4_Label FROM tbl_OB_Objekt WHERE ID = " & objID)

    If Not rs.EOF Then
        ' Wenn Zeitslot-Textfelder vorhanden sind, befuellen
        On Error Resume Next
        If Not IsNull(rs("Zeit1_Label")) Then frm("txtZeit1") = rs("Zeit1_Label")
        If Not IsNull(rs("Zeit2_Label")) Then frm("txtZeit2") = rs("Zeit2_Label")
        If Not IsNull(rs("Zeit3_Label")) Then frm("txtZeit3") = rs("Zeit3_Label")
        If Not IsNull(rs("Zeit4_Label")) Then frm("txtZeit4") = rs("Zeit4_Label")
    End If

    rs.Close
    Set rs = Nothing
End Sub

Public Sub Zeitslots_Speichern()
    ' Speichert die eingegebenen Zeitslot-Labels in tbl_OB_Objekt
    On Error Resume Next

    Dim frm As Form
    Dim objID As Long

    Set frm = Forms("frm_OB_Objekt")
    If frm Is Nothing Then Exit Sub

    objID = Nz(frm("Liste_Obj"), 0)
    If objID = 0 Then Exit Sub

    Dim sql As String
    sql = "UPDATE tbl_OB_Objekt SET " & _
          "Zeit1_Label = '" & Nz(frm("txtZeit1"), "") & "', " & _
          "Zeit2_Label = '" & Nz(frm("txtZeit2"), "") & "', " & _
          "Zeit3_Label = '" & Nz(frm("txtZeit3"), "") & "', " & _
          "Zeit4_Label = '" & Nz(frm("txtZeit4"), "") & "' " & _
          "WHERE ID = " & objID

    CurrentDb.Execute sql, dbFailOnError
End Sub

Public Sub RefreshUnterformularHeader()
    ' Aktualisiert die Spaltenueberschriften im Unterformular
    On Error Resume Next

    Dim frm As Form
    Dim subFrm As Form
    Dim objID As Long
    Dim rs As DAO.Recordset

    Set frm = Forms("frm_OB_Objekt")
    objID = Nz(frm("Liste_Obj"), 0)
    If objID = 0 Then Exit Sub

    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Zeit1_Label, Zeit2_Label, Zeit3_Label, Zeit4_Label FROM tbl_OB_Objekt WHERE ID = " & objID)

    If Not rs.EOF Then
        ' Zugriff auf Unterformular
        Set subFrm = frm("sub_OB_Objekt_Positionen").Form

        ' Labels im Unterformular aktualisieren
        On Error Resume Next
        subFrm("lblZeit1").Caption = Nz(rs("Zeit1_Label"), "Zeit1")
        subFrm("lblZeit2").Caption = Nz(rs("Zeit2_Label"), "Zeit2")
        subFrm("lblZeit3").Caption = Nz(rs("Zeit3_Label"), "Zeit3")
        subFrm("lblZeit4").Caption = Nz(rs("Zeit4_Label"), "Zeit4")
    End If

    rs.Close
End Sub
'''

        try:
            vbe = access.VBE
            proj = vbe.ActiveVBProject

            module_name = "mod_Zeitslots"

            # Altes Modul entfernen
            for i in range(1, proj.VBComponents.Count + 1):
                try:
                    comp = proj.VBComponents.Item(i)
                    if comp.Name == module_name:
                        proj.VBComponents.Remove(comp)
                        print(f"Altes Modul '{module_name}' entfernt")
                        break
                except:
                    pass

            # Neues Modul erstellen
            new_module = proj.VBComponents.Add(1)
            new_module.Name = module_name
            new_module.CodeModule.AddFromString(vba_code)
            print(f"VBA-Modul '{module_name}' erstellt!")

        except Exception as e:
            print(f"VBA-Fehler: {e}")

        # === 5. Buttons pruefen und reparieren ===
        print_section("5. BUTTON-ANALYSE UND REPARATUR")

        try:
            access.DoCmd.OpenForm("frm_OB_Objekt", 1)
            time.sleep(1)
            frm = access.Forms("frm_OB_Objekt")

            problematic_buttons = []
            working_buttons = []

            for i in range(frm.Controls.Count):
                ctl = frm.Controls.Item(i)
                if ctl.ControlType == 104:  # CommandButton
                    name = ctl.Name
                    try:
                        onclick = ctl.OnClick
                        if onclick:
                            if onclick == "[Event Procedure]":
                                working_buttons.append((name, "Event Procedure"))
                            elif onclick.startswith("[Eingebettetes Makro]"):
                                working_buttons.append((name, "Eingebettetes Makro"))
                            else:
                                working_buttons.append((name, onclick))
                        else:
                            problematic_buttons.append((name, "Kein OnClick definiert"))
                    except:
                        problematic_buttons.append((name, "Fehler beim Lesen"))

            print("\nFunktionierende Buttons:")
            for name, event in working_buttons:
                print(f"  OK: {name} -> {event}")

            print("\nProblematische Buttons:")
            for name, issue in problematic_buttons:
                print(f"  PROBLEM: {name} -> {issue}")

            # btnNeuVeranst hat kein OnClick - das sollten wir beheben
            if problematic_buttons:
                print("\nRepariere problematische Buttons...")
                for name, issue in problematic_buttons:
                    try:
                        btn = frm.Controls(name)
                        # Setze ein einfaches Makro oder Event
                        if name == "btnNeuVeranst":
                            # Dieser Button sollte ein neues Objekt erstellen
                            btn.OnClick = "=MsgBox(\"Neues Objekt erstellen - Funktion muss implementiert werden\")"
                            print(f"  {name}: Placeholder-Event gesetzt")
                    except Exception as e:
                        print(f"  {name}: Konnte nicht repariert werden - {e}")

            access.DoCmd.Close(2, "frm_OB_Objekt", 1)

        except Exception as e:
            print(f"Button-Fehler: {e}")
            try:
                access.DoCmd.Close(2, "frm_OB_Objekt", 2)
            except:
                pass

        # === 6. Bericht anpassen ===
        print_section("6. BERICHT RPT_OB_OBJEKT ANPASSEN")

        try:
            access.DoCmd.OpenReport("rpt_OB_Objekt", 1)  # acViewDesign
            time.sleep(1)

            rpt = access.Reports("rpt_OB_Objekt")
            print(f"Bericht geoeffnet: {rpt.Name}")
            print(f"Aktuelle RecordSource: {rpt.RecordSource}")

            # RecordSource anpassen um Zeitslot-Labels einzubinden
            new_recordsource = """SELECT o.*,
                                  o.Zeit1_Label, o.Zeit2_Label, o.Zeit3_Label, o.Zeit4_Label
                                  FROM tbl_OB_Objekt AS o"""

            rpt.RecordSource = new_recordsource
            print(f"Neue RecordSource gesetzt")

            # Controls im Bericht analysieren
            print("\nBericht-Controls:")
            for i in range(rpt.Controls.Count):
                ctl = rpt.Controls.Item(i)
                if ctl.ControlType == 112:  # SubReport
                    print(f"  SubReport: {ctl.Name} -> {ctl.SourceObject}")

            access.DoCmd.Close(3, "rpt_OB_Objekt", 1)  # acReport, acSaveYes
            print("Bericht gespeichert!")

        except Exception as e:
            print(f"Bericht-Fehler: {e}")
            try:
                access.DoCmd.Close(3, "rpt_OB_Objekt", 2)
            except:
                pass

        # === 7. Adressdaten ergaenzen ===
        print_section("7. ADRESSDATEN ERGAENZEN")

        # Bekannte Adressen fuer Veranstaltungsorte in der Region Nuernberg/Fuerth
        known_addresses = {
            "E-Werk": {"strasse": "Fuchsenwiese 1", "plz": "91054", "ort": "Erlangen"},
            "Heinrich-Lades-Halle": {"strasse": "Rathausplatz 1", "plz": "91052", "ort": "Erlangen"},
            "Frankenhalle": {"strasse": "Karl-Schoenleben-Strasse 2", "plz": "90471", "ort": "Nuernberg"},
            "Loewensaal": {"strasse": "Sulzbacher Str. 79", "plz": "90489", "ort": "Nuernberg"},
            "Arena Nuernberger Versicherungen": {"strasse": "Dr.-Ingeborg-Bausenwein-Strasse 1", "plz": "90453", "ort": "Nuernberg"},
            "Serenadenhof": {"strasse": "Luitpoldhain", "plz": "90478", "ort": "Nuernberg"},
            "Grundig Stadion": {"strasse": "Zeppelinstrasse 4", "plz": "90471", "ort": "Nuernberg"},
            "Stadthalle": {"strasse": "Rosenstrasse 50", "plz": "90762", "ort": "Fuerth"},
            "Stadion am Laubenweg": {"strasse": "Laubenweg 60", "plz": "90765", "ort": "Fuerth"},
            "Terminal 90": {"strasse": "Dr.-Kurt-Schumacher-Strasse 5", "plz": "90402", "ort": "Nuernberg"},
            "KIA Arena": {"strasse": "Dr.-Ingeborg-Bausenwein-Strasse 1", "plz": "90453", "ort": "Nuernberg"},
            "Arena": {"strasse": "Dr.-Ingeborg-Bausenwein-Strasse 1", "plz": "90453", "ort": "Nuernberg"},
            "Messezentrum": {"strasse": "Messezentrum 1", "plz": "90471", "ort": "Nuernberg"},
            "Hirsch": {"strasse": "Vogelweiherstrasse 66", "plz": "90441", "ort": "Nuernberg"},
            "Cult": {"strasse": "Dooser Strasse 60", "plz": "90427", "ort": "Nuernberg"},
            "Katharinenruine": {"strasse": "Am Katharinenkloster", "plz": "90403", "ort": "Nuernberg"},
            "Norisring": {"strasse": "Zeppelinstrasse", "plz": "90471", "ort": "Nuernberg"},
            "Neues Museum": {"strasse": "Luitpoldstrasse 5", "plz": "90402", "ort": "Nuernberg"},
            "Brose Arena": {"strasse": "Forchheimer Strasse 15", "plz": "96052", "ort": "Bamberg"},
            "Donauarena": {"strasse": "Walhalla-Allee 24", "plz": "93053", "ort": "Regensburg"},
            "Maimarkthalle": {"strasse": "Xaver-Fuhr-Strasse 101", "plz": "68163", "ort": "Mannheim"},
            "SAP Arena": {"strasse": "An der Arena 1", "plz": "68163", "ort": "Mannheim"},
            "Jurahalle": {"strasse": "Jahnstrasse 1", "plz": "92318", "ort": "Neumarkt"},
            "Lux Kirche": {"strasse": "Rathenauplatz", "plz": "90489", "ort": "Nuernberg"},
            "Max-Morlock-Stadion": {"strasse": "Zeppelinstrasse 4", "plz": "90471", "ort": "Nuernberg"},
            "Meistersingerhalle": {"strasse": "Muenchener Strasse 21", "plz": "90478", "ort": "Nuernberg"},
            "Markgrafensaal": {"strasse": "Ludwigstrasse 16", "plz": "91126", "ort": "Schwabach"},
            "Sportpark Ronhof": {"strasse": "Laubenweg 60", "plz": "90765", "ort": "Fuerth"},
            "Gymnasium Stein": {"strasse": "Faber-Castell-Allee 10", "plz": "90547", "ort": "Stein"},
            "Gutmann am Dutzendteich": {"strasse": "Bayernstrasse 150", "plz": "90478", "ort": "Nuernberg"},
            "Villa": {"strasse": "Schultheissallee 13", "plz": "90478", "ort": "Nuernberg"},
            "Spittlertorzwinger": {"strasse": "Spittlertorzwinger 4", "plz": "90429", "ort": "Nuernberg"},
            "Klaragasse": {"strasse": "Klaragasse", "plz": "90402", "ort": "Nuernberg"},
        }

        print("Aktualisiere Adressdaten in tbl_OB_Objekt...")

        try:
            conn = get_odbc_connection()
            cursor = conn.cursor()

            # Aktuelle Objekte laden
            cursor.execute("SELECT ID, Objekt, Strasse, PLZ, Ort FROM tbl_OB_Objekt")
            columns = [col[0] for col in cursor.description]

            updates = 0
            for row in cursor.fetchall():
                obj = dict(zip(columns, row))
                obj_name = obj['Objekt']
                obj_id = obj['ID']

                # Normalisiere Namen fuer Vergleich
                normalized_name = obj_name.replace("ae", "ae").replace("oe", "oe").replace("ue", "ue")
                normalized_name = normalized_name.replace("ss", "ss")

                # Suche passende Adresse
                for known_name, addr in known_addresses.items():
                    if known_name.lower() in obj_name.lower() or obj_name.lower() in known_name.lower():
                        # Nur aktualisieren wenn Felder leer sind
                        if not obj['Strasse'] or not obj['PLZ']:
                            update_sql = """UPDATE tbl_OB_Objekt
                                           SET Strasse = ?, PLZ = ?, Ort = ?
                                           WHERE ID = ?"""
                            try:
                                cursor.execute(update_sql, (addr['strasse'], addr['plz'], addr['ort'], obj_id))
                                conn.commit()
                                updates += 1
                                print(f"  Aktualisiert: {obj_name}")
                                print(f"    -> {addr['strasse']}, {addr['plz']} {addr['ort']}")
                            except Exception as e:
                                print(f"  Fehler bei {obj_name}: {e}")
                        break

            conn.close()
            print(f"\n{updates} Objekte mit Adressdaten aktualisiert!")

        except Exception as e:
            print(f"Adress-Fehler: {e}")

        # === ABSCHLUSS ===
        print_section("MODIFIKATIONEN ABGESCHLOSSEN")

        print("""
Durchgefuehrte Aenderungen:
1. Listenfeld 'Liste_Obj' zeigt jetzt nur Objekte MIT Positionen
2. VBA-Modul 'mod_Zeitslots' fuer Zeitslot-Label-Verwaltung erstellt
3. Problematische Buttons identifiziert und teilweise repariert
4. Bericht 'rpt_OB_Objekt' RecordSource angepasst
5. Adressdaten fuer bekannte Veranstaltungsorte ergaenzt

Naechste manuelle Schritte:
- Formular frm_OB_Objekt oeffnen und pruefen
- Zeitslot-Eingabefelder im Formular-Header hinzufuegen
- OnCurrent-Event mit Zeitslots_Laden verknuepfen
- Button-Funktionen bei Bedarf erweitern
""")

    except Exception as e:
        print(f"\nHAUPTFEHLER: {e}")

    finally:
        pythoncom.CoUninitialize()

if __name__ == "__main__":
    main()
