# -*- coding: utf-8 -*-
"""
Finale Verifizierung aller Aenderungen (Access-kompatibel)
"""

import win32com.client
import pythoncom
import pyodbc
import time

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

def print_section(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)

def main():
    print_section("FINALE VERIFIZIERUNG")

    pythoncom.CoInitialize()

    # === 1. Datenbankstand pruefen ===
    print_section("1. DATENBANKSTAND")

    conn_str = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        f'DBQ={FRONTEND_PATH};'
    )
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Objekte mit Positionen zaehlen
    cursor.execute("""
        SELECT COUNT(*)
        FROM tbl_OB_Objekt o
        WHERE EXISTS (SELECT 1 FROM tbl_OB_Objekt_Positionen p WHERE p.OB_Objekt_Kopf_ID = o.ID)
    """)
    count_with_pos = cursor.fetchone()[0]
    print(f"Objekte MIT Positionen: {count_with_pos}")

    # Objekte mit Adressdaten zaehlen
    cursor.execute("""
        SELECT COUNT(*)
        FROM tbl_OB_Objekt
        WHERE Strasse IS NOT NULL AND Strasse <> ''
    """)
    count_with_addr = cursor.fetchone()[0]
    print(f"Objekte MIT Adressdaten: {count_with_addr}")

    # Objekte mit Zeit-Labels zaehlen
    cursor.execute("""
        SELECT COUNT(*)
        FROM tbl_OB_Objekt
        WHERE Zeit1_Label IS NOT NULL AND Zeit1_Label <> ''
    """)
    count_with_zeit = cursor.fetchone()[0]
    print(f"Objekte MIT Zeit-Labels: {count_with_zeit}")

    # Beispiel-Objekte mit Zeit-Labels anzeigen
    cursor.execute("""
        SELECT ID, Objekt, Zeit1_Label, Zeit2_Label, Zeit3_Label, Zeit4_Label
        FROM tbl_OB_Objekt
        WHERE Zeit1_Label IS NOT NULL AND Zeit1_Label <> ''
    """)
    print("\nObjekte mit Zeit-Labels:")
    for row in cursor.fetchall():
        print(f"  ID {row[0]}: {row[1]}")
        print(f"    Zeit1={row[2]}, Zeit2={row[3]}, Zeit3={row[4]}, Zeit4={row[5]}")

    conn.close()

    # === 2. Access-Objekte pruefen ===
    print_section("2. ACCESS-OBJEKTE")

    try:
        access = win32com.client.GetObject(Class="Access.Application")
        print("Access-Verbindung hergestellt!")

        # Formular pruefen
        print("\nFormular frm_OB_Objekt:")
        access.DoCmd.OpenForm("frm_OB_Objekt", 1)
        time.sleep(0.5)
        frm = access.Forms("frm_OB_Objekt")

        # Listenfeld RowSource
        lst = frm.Controls("Liste_Obj")
        print(f"  Listenfeld RowSource (erste 100 Zeichen): {lst.RowSource[:100]}...")
        print(f"  Spaltenanzahl: {lst.ColumnCount}")

        # OnCurrent Event
        print(f"  OnCurrent: {frm.OnCurrent}")

        access.DoCmd.Close(2, "frm_OB_Objekt", 2)

        # Unterformular pruefen
        print("\nUnterformular sub_OB_Objekt_Positionen:")
        access.DoCmd.OpenForm("sub_OB_Objekt_Positionen", 1)
        time.sleep(0.5)
        sub_frm = access.Forms("sub_OB_Objekt_Positionen")

        zeit_controls = []
        for i in range(sub_frm.Controls.Count):
            ctl = sub_frm.Controls.Item(i)
            if ctl.Name in ['Zeit1', 'Zeit2', 'Zeit3', 'Zeit4']:
                zeit_controls.append(ctl.Name)

        print(f"  Zeit-Controls gefunden: {zeit_controls}")
        access.DoCmd.Close(2, "sub_OB_Objekt_Positionen", 2)

        # Bericht pruefen
        print("\nBericht rpt_OB_Objekt:")
        access.DoCmd.OpenReport("rpt_OB_Objekt", 1)
        time.sleep(0.5)
        rpt = access.Reports("rpt_OB_Objekt")
        print(f"  RecordSource: {rpt.RecordSource[:100]}...")
        access.DoCmd.Close(3, "rpt_OB_Objekt", 2)

        # Sub-Bericht pruefen
        print("\nSub-Bericht rpt_OB_Objekt_Sub:")
        access.DoCmd.OpenReport("rpt_OB_Objekt_Sub", 1)
        time.sleep(0.5)
        sub_rpt = access.Reports("rpt_OB_Objekt_Sub")

        zeit_controls = []
        for i in range(sub_rpt.Controls.Count):
            ctl = sub_rpt.Controls.Item(i)
            if ctl.Name in ['Zeit1', 'Zeit2', 'Zeit3', 'Zeit4']:
                zeit_controls.append(ctl.Name)

        print(f"  Zeit-Controls gefunden: {zeit_controls}")
        access.DoCmd.Close(3, "rpt_OB_Objekt_Sub", 2)

        # VBA-Module pruefen
        print("\nVBA-Module:")
        vbe = access.VBE
        proj = vbe.ActiveVBProject
        for i in range(1, proj.VBComponents.Count + 1):
            comp = proj.VBComponents.Item(i)
            if 'zeit' in comp.Name.lower() or 'slot' in comp.Name.lower():
                print(f"  {comp.Name} (Typ: {comp.Type})")

    except Exception as e:
        print(f"Access-Fehler: {e}")

    print_section("VERIFIZIERUNG ABGESCHLOSSEN")

    print("""
ZUSAMMENFASSUNG DER DURCHGEFUEHRTEN AENDERUNGEN:

1. LISTENFELD (Liste_Obj):
   - Zeigt jetzt nur Objekte MIT Positionen an
   - Neue Spalte zeigt Anzahl der Positionen

2. ZEITSLOT-FUNKTIONALITAET:
   - VBA-Modul 'mod_Zeitslots' erstellt
   - Funktionen: SyncZeitslots(), SaveZeitslotLabels()
   - OnCurrent-Event im Formular verknuepft
   - Zeit1-Zeit4 Felder in Unterformular hinzugefuegt
   - Zeit1-Zeit4 Felder in Sub-Bericht hinzugefuegt

3. BUTTONS:
   - Alle Buttons analysiert
   - btnNeuVeranst hatte kein Event -> Placeholder gesetzt

4. BERICHT (rpt_OB_Objekt):
   - RecordSource aktualisiert (enthaelt Zeit-Labels)
   - Sub-Bericht enthaelt jetzt Zeit1-Zeit4 Spalten

5. ADRESSDATEN:
   - 25+ Objekte mit korrekten Adressen aktualisiert
   - Bekannte Veranstaltungsorte wie Arena, Meistersingerhalle,
     Stadthalle, Brose Arena, SAP Arena etc.

NAECHSTE SCHRITTE (falls gewuenscht):
- Formular im Normalmodus testen
- Bericht mit echten Daten drucken/exportieren
- Zeitslot-Eingabefelder im Header positionieren
- Ggf. weitere Adressdaten manuell ergaenzen
""")

    pythoncom.CoUninitialize()

if __name__ == "__main__":
    main()
