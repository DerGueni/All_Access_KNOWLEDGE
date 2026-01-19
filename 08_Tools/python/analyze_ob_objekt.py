"""
Analyse-Skript für frm_OB_Objekt und rpt_OB_Objekt
Ermittelt Struktur und benötigte Anpassungen
"""

import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge import AccessBridge
import json

def analyze_database():
    """Analysiert die Datenbank-Struktur für OB_Objekt"""

    print("=" * 60)
    print("ANALYSE: frm_OB_Objekt / rpt_OB_Objekt")
    print("=" * 60)

    with AccessBridge() as bridge:
        # 1. Alle OB-relevanten Tabellen finden
        print("\n=== OB-relevante Tabellen ===")
        tables = bridge.list_tables()
        ob_tables = [t for t in tables if 'OB' in t.upper() or 'OBJEKT' in t.upper() or 'POSITION' in t.upper()]

        for table in ob_tables:
            try:
                count = bridge.execute_sql(f"SELECT COUNT(*) as cnt FROM [{table}]")[0]['cnt']
                print(f"  {table}: {count} Datensätze")
            except Exception as e:
                print(f"  {table}: Fehler - {e}")

        # 2. tbl_OB_Objekt Struktur
        print("\n=== tbl_OB_Objekt Struktur ===")
        try:
            sample = bridge.execute_sql("SELECT TOP 5 * FROM [tbl_OB_Objekt]")
            if sample:
                print(f"  Felder: {list(sample[0].keys())}")
                print(f"  Beispieldaten:")
                for row in sample[:3]:
                    print(f"    ID={row.get('ID_OB_Objekt', row.get('ID'))}, Name={row.get('OB_Objekt', row.get('Objekt'))}, Ort={row.get('Ort', row.get('OB_Ort'))}")
        except Exception as e:
            print(f"  Fehler: {e}")

        # 3. Positionslisten-Tabelle
        print("\n=== Positionslisten-Tabelle ===")
        try:
            pos_tables = [t for t in tables if 'POSITIONSLISTE' in t.upper() or 'OB_POS' in t.upper()]
            for pt in pos_tables:
                sample = bridge.execute_sql(f"SELECT TOP 5 * FROM [{pt}]")
                if sample:
                    print(f"  Tabelle: {pt}")
                    print(f"  Felder: {list(sample[0].keys())}")
        except Exception as e:
            print(f"  Fehler: {e}")

        # 4. OB_Position Tabelle (Unterformular-Daten)
        print("\n=== OB_Position Tabelle ===")
        try:
            sample = bridge.execute_sql("SELECT TOP 10 * FROM [tbl_OB_Position]")
            if sample:
                print(f"  Felder: {list(sample[0].keys())}")
                # Beispiel für ein Objekt
                if 'ID_OB_Objekt' in sample[0]:
                    obj_id = sample[0]['ID_OB_Objekt']
                    positions = bridge.execute_sql(f"SELECT * FROM [tbl_OB_Position] WHERE ID_OB_Objekt = {obj_id}")
                    print(f"  Positionen für Objekt {obj_id}: {len(positions)}")
        except Exception as e:
            print(f"  Fehler: {e}")

        # 5. Formulare auflisten
        print("\n=== OB-relevante Formulare ===")
        forms = bridge.list_forms()
        ob_forms = [f for f in forms if 'OB' in f.upper() or 'OBJEKT' in f.upper()]
        for f in ob_forms:
            print(f"  {f}")

        # 6. Reports auflisten
        print("\n=== OB-relevante Berichte ===")
        reports = bridge.list_reports()
        ob_reports = [r for r in reports if 'OB' in r.upper() or 'OBJEKT' in r.upper()]
        for r in ob_reports:
            print(f"  {r}")

        # 7. Zeitslot-Felder prüfen
        print("\n=== Zeitslot-Analyse ===")
        try:
            sample = bridge.execute_sql("SELECT TOP 1 * FROM [tbl_OB_Position]")
            if sample:
                zeit_felder = [k for k in sample[0].keys() if 'ZEIT' in k.upper() or 'SLOT' in k.upper() or 'TIME' in k.upper()]
                print(f"  Zeitfelder in tbl_OB_Position: {zeit_felder}")
        except Exception as e:
            print(f"  Fehler: {e}")

        # 8. Alle Objekte mit Positionslisten
        print("\n=== Objekte mit Positionslisten ===")
        try:
            # Prüfe welche Objekte Positionen haben
            sql = """
            SELECT DISTINCT o.ID_OB_Objekt, o.OB_Objekt, o.Ort, COUNT(p.ID_OB_Position) as AnzahlPositionen
            FROM tbl_OB_Objekt o
            LEFT JOIN tbl_OB_Position p ON o.ID_OB_Objekt = p.ID_OB_Objekt
            GROUP BY o.ID_OB_Objekt, o.OB_Objekt, o.Ort
            HAVING COUNT(p.ID_OB_Position) > 0
            ORDER BY o.OB_Objekt
            """
            objects_with_positions = bridge.execute_sql(sql)
            print(f"  Gefunden: {len(objects_with_positions)} Objekte mit Positionen")
            for obj in objects_with_positions[:10]:
                print(f"    {obj['ID_OB_Objekt']}: {obj['OB_Objekt']} ({obj['Ort']}) - {obj['AnzahlPositionen']} Positionen")
        except Exception as e:
            print(f"  Fehler bei Objekt-Analyse: {e}")
            # Versuche alternative Abfrage
            try:
                sql_alt = "SELECT TOP 20 * FROM tbl_OB_Objekt ORDER BY OB_Objekt"
                objects = bridge.execute_sql(sql_alt)
                print(f"  Alternative: {len(objects)} Objekte gefunden")
                for obj in objects[:5]:
                    print(f"    {obj}")
            except Exception as e2:
                print(f"  Alternative fehlgeschlagen: {e2}")

        print("\n" + "=" * 60)
        print("ANALYSE ABGESCHLOSSEN")
        print("=" * 60)

if __name__ == "__main__":
    analyze_database()
