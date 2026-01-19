"""
Exportiert das komplette Entfernungsfeature aus frm_MA_VA_Schnellauswahl
in einen eigenen Ordner mit allen benötigten Komponenten
"""
from access_bridge_ultimate import AccessBridge
import os
from datetime import datetime

# Export-Ordner
EXPORT_DIR = r"C:\Users\guenther.siegert\Documents\Export_Entfernungsfeature"

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)
        print(f"[OK] Ordner erstellt: {path}")

def export_module_code(bridge, module_name, export_path):
    """Exportiert VBA-Code eines Moduls"""
    try:
        vbe = bridge.access_app.VBE
        proj = vbe.ActiveVBProject

        for comp in proj.VBComponents:
            if comp.Name == module_name:
                code_module = comp.CodeModule
                if code_module.CountOfLines > 0:
                    code = code_module.Lines(1, code_module.CountOfLines)

                    # Dateiendung basierend auf Typ
                    if comp.Type == 1:  # Standard Module
                        ext = ".bas"
                    elif comp.Type == 2:  # Class Module
                        ext = ".cls"
                    elif comp.Type == 100:  # Form Module
                        ext = ".frm_code.txt"
                    else:
                        ext = ".txt"

                    filename = os.path.join(export_path, module_name + ext)
                    with open(filename, 'w', encoding='utf-8') as f:
                        f.write(code)
                    print(f"  [OK] {module_name}{ext}")
                    return True
        return False
    except Exception as e:
        print(f"  [!] {module_name}: {e}")
        return False

def export_query_sql(bridge, query_name, export_path):
    """Exportiert SQL einer Abfrage"""
    try:
        for qdef in bridge.current_db.QueryDefs:
            if qdef.Name == query_name:
                sql = qdef.SQL
                filename = os.path.join(export_path, query_name + ".sql")
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(f"-- Abfrage: {query_name}\n")
                    f.write(f"-- Exportiert: {datetime.now()}\n\n")
                    f.write(sql)
                print(f"  [OK] {query_name}.sql")
                return True
        return False
    except Exception as e:
        print(f"  [!] {query_name}: {e}")
        return False

def export_table_structure(bridge, table_name, export_path):
    """Exportiert Tabellenstruktur als CREATE TABLE Statement"""
    try:
        tdef = None
        for t in bridge.current_db.TableDefs:
            if t.Name == table_name:
                tdef = t
                break

        if not tdef:
            print(f"  [!] Tabelle nicht gefunden: {table_name}")
            return False

        # Feldinfos sammeln
        fields = []
        for field in tdef.Fields:
            field_type = {
                1: "YESNO",
                2: "BYTE",
                3: "INTEGER",
                4: "LONG",
                5: "CURRENCY",
                6: "SINGLE",
                7: "DOUBLE",
                8: "DATE",
                10: "TEXT",
                11: "OLEOBJECT",
                12: "MEMO",
                15: "GUID",
                16: "BIGINT"
            }.get(field.Type, f"TYPE_{field.Type}")

            size_str = f"({field.Size})" if field.Type == 10 else ""
            fields.append(f"  [{field.Name}] {field_type}{size_str}")

        # CREATE TABLE generieren
        create_sql = f"-- Tabelle: {table_name}\n"
        create_sql += f"-- Exportiert: {datetime.now()}\n\n"
        create_sql += f"CREATE TABLE [{table_name}] (\n"
        create_sql += ",\n".join(fields)
        create_sql += "\n);\n"

        filename = os.path.join(export_path, table_name + "_struktur.sql")
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(create_sql)
        print(f"  [OK] {table_name}_struktur.sql")
        return True
    except Exception as e:
        print(f"  [!] {table_name}: {e}")
        return False


def main():
    print("\n" + "=" * 70)
    print("EXPORT ENTFERNUNGSFEATURE")
    print("=" * 70 + "\n")

    # Export-Ordner erstellen
    ensure_dir(EXPORT_DIR)
    ensure_dir(os.path.join(EXPORT_DIR, "Module"))
    ensure_dir(os.path.join(EXPORT_DIR, "Abfragen"))
    ensure_dir(os.path.join(EXPORT_DIR, "Tabellen"))
    ensure_dir(os.path.join(EXPORT_DIR, "Formulare"))

    with AccessBridge() as bridge:
        # 1. Module exportieren
        print("\n--- VBA-Module exportieren ---")
        modules_to_export = [
            "Form_frm_MA_VA_Schnellauswahl",
            "mdl_GeoDistanz",
            "mdl_GeoDistanz_FormEvents",
            "mdl_GeoDistanz_Setup",
            "mdl_Distanzberechnung",
            "mdl_GeoFormFunctions",
            "mdl_GeoAdmin",
            "mdl_frm_MA_VA_Schnellauswahl_Code"
        ]

        for mod in modules_to_export:
            export_module_code(bridge, mod, os.path.join(EXPORT_DIR, "Module"))

        # 2. Abfragen exportieren
        print("\n--- Abfragen exportieren ---")
        queries_to_export = [
            "ztmp_MA_Entfernung"
        ]

        # Suche weitere relevante Abfragen
        for qdef in bridge.current_db.QueryDefs:
            name_lower = qdef.Name.lower()
            if any(x in name_lower for x in ["entfernung", "distanz", "geo", "objekt_entf"]):
                if qdef.Name not in queries_to_export:
                    queries_to_export.append(qdef.Name)

        for qry in queries_to_export:
            export_query_sql(bridge, qry, os.path.join(EXPORT_DIR, "Abfragen"))

        # 3. Tabellen exportieren
        print("\n--- Tabellenstrukturen exportieren ---")
        tables_to_export = [
            "tbl_MA_Objekt_Entfernung",
            "ztbl_MA_Schnellauswahl",
            "tbl_OB_Objektstamm"  # Falls Objekt-Koordinaten hier sind
        ]

        # Suche weitere relevante Tabellen
        for tdef in bridge.current_db.TableDefs:
            name_lower = tdef.Name.lower()
            if any(x in name_lower for x in ["entfernung", "distanz", "geo", "koordinat"]):
                if tdef.Name not in tables_to_export and not tdef.Name.startswith("MSys"):
                    tables_to_export.append(tdef.Name)

        for tbl in tables_to_export:
            export_table_structure(bridge, tbl, os.path.join(EXPORT_DIR, "Tabellen"))

        # 4. Formular exportieren (als Access-Export)
        print("\n--- Formular exportieren ---")
        try:
            form_export = os.path.join(EXPORT_DIR, "Formulare", "frm_MA_VA_Schnellauswahl.txt")
            bridge.access_app.DoCmd.OutputTo(2, "frm_MA_VA_Schnellauswahl", "Text Files", form_export)
            print(f"  [OK] frm_MA_VA_Schnellauswahl.txt")
        except Exception as e:
            print(f"  [!] Formular-Export: {e}")
            # Alternative: Formular-Eigenschaften auslesen
            try:
                bridge.access_app.DoCmd.OpenForm("frm_MA_VA_Schnellauswahl", 1)  # Design
                frm = bridge.access_app.Forms("frm_MA_VA_Schnellauswahl")

                # Control-Liste erstellen
                controls_info = []
                for ctl in frm.Controls:
                    try:
                        controls_info.append({
                            'Name': ctl.Name,
                            'Type': ctl.ControlType,
                            'Left': ctl.Left,
                            'Top': ctl.Top,
                            'Width': ctl.Width,
                            'Height': ctl.Height
                        })
                    except:
                        pass

                bridge.access_app.DoCmd.Close(2, "frm_MA_VA_Schnellauswahl", 2)

                # Als Info-Datei speichern
                info_file = os.path.join(EXPORT_DIR, "Formulare", "frm_MA_VA_Schnellauswahl_controls.txt")
                with open(info_file, 'w', encoding='utf-8') as f:
                    f.write("Formular: frm_MA_VA_Schnellauswahl\n")
                    f.write(f"Exportiert: {datetime.now()}\n\n")
                    f.write("Controls:\n")
                    for c in controls_info:
                        f.write(f"  - {c['Name']} (Type: {c['Type']})\n")
                print(f"  [OK] frm_MA_VA_Schnellauswahl_controls.txt")
            except Exception as e2:
                print(f"  [!] Control-Info: {e2}")

        # 5. README erstellen
        print("\n--- README erstellen ---")
        readme = f"""# EXPORT: ENTFERNUNGSFEATURE
# Exportiert am: {datetime.now()}

## BESCHREIBUNG
Das Entfernungsfeature ermöglicht im Formular frm_MA_VA_Schnellauswahl
die Sortierung der Mitarbeiter nach Entfernung zum Einsatzobjekt.

## BUTTON
- Name: cmdListMA_Entfernung
- Caption: "Entfernung"
- Event: cmdListMA_Entfernung_Click()

## FUNKTIONSWEISE
1. Button wird geklickt
2. Objekt_ID des aktuellen Auftrags wird aus tbl_VA_Auftragstamm geholt
3. SQL-Abfrage sortiert Mitarbeiter nach Entfernung zum Objekt
4. Entfernungsdaten kommen aus tbl_MA_Objekt_Entfernung

## BENÖTIGTE KOMPONENTEN

### Tabellen:
- tbl_MA_Objekt_Entfernung (MA_ID, Objekt_ID, Entf_KM)
- ztbl_MA_Schnellauswahl (temporäre MA-Auswahl)
- tbl_MA_Mitarbeiterstamm (Mitarbeiterdaten)
- tbl_VA_Auftragstamm (Auftragsdaten mit Objekt_ID)

### Module:
- mdl_GeoDistanz - Hauptmodul für Distanzberechnung
- mdl_GeoDistanz_FormEvents - Event-Handler
- mdl_GeoDistanz_Setup - Setup-Funktionen
- mdl_Distanzberechnung - Berechnungslogik
- mdl_GeoFormFunctions - Formular-Funktionen
- mdl_GeoAdmin - Admin-Funktionen

### Abfragen:
- ztmp_MA_Entfernung

## IMPORT-ANLEITUNG

1. Tabelle tbl_MA_Objekt_Entfernung erstellen (falls nicht vorhanden)
2. Alle Module importieren (VBA-Editor > Datei > Importieren)
3. Im Formular frm_MA_VA_Schnellauswahl:
   - Button cmdListMA_Entfernung hinzufügen
   - Bei Klicken: =cmdListMA_Entfernung_Click()
4. Entfernungsdaten müssen berechnet/importiert werden

## SQL DES BUTTONS

```sql
SELECT MA.ID AS MA_ID,
       MA.Nachname & ', ' & MA.Vorname & ' (' & Format(Nz(D.Entf_KM,0),'0.0') & ' km)' AS Anzeige
FROM (ztbl_MA_Schnellauswahl AS S
      INNER JOIN tbl_MA_Mitarbeiterstamm AS MA ON MA.ID = S.MA_ID)
LEFT JOIN tbl_MA_Objekt_Entfernung AS D
      ON D.MA_ID = MA.ID AND D.Objekt_ID = [Objekt_ID_Parameter]
ORDER BY Nz(D.Entf_KM,9999), MA.Nachname, MA.Vorname
```
"""
        readme_file = os.path.join(EXPORT_DIR, "README.md")
        with open(readme_file, 'w', encoding='utf-8') as f:
            f.write(readme)
        print(f"  [OK] README.md")

        print("\n" + "=" * 70)
        print(f"EXPORT ABGESCHLOSSEN!")
        print(f"Ordner: {EXPORT_DIR}")
        print("=" * 70)


if __name__ == "__main__":
    main()
