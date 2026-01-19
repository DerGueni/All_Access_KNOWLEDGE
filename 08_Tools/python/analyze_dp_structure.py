"""
Analysiert die Dienstplan-Struktur in der Access-Datenbank
"""
import win32com.client
import pythoncom
import json
from pathlib import Path

# Config laden
config_path = Path(__file__).parent / "config.json"
with open(config_path, 'r') as f:
    config = json.load(f)

BACKEND_PATH = config['database']['backend_path']
FRONTEND_PATH = config['database']['frontend_path']

def analyze_tables():
    """Analysiert relevante Tabellen fuer Dienstplan"""
    pythoncom.CoInitialize()

    print("=" * 60)
    print("DIENSTPLAN STRUKTUR-ANALYSE")
    print("=" * 60)

    # Backend analysieren
    print(f"\nBackend: {BACKEND_PATH}")

    try:
        db_engine = win32com.client.Dispatch("DAO.DBEngine.120")
        db = db_engine.OpenDatabase(BACKEND_PATH)

        # Relevante Tabellen suchen
        dp_tables = []
        ma_tables = []
        va_tables = []
        ob_tables = []

        for tdef in db.TableDefs:
            name = tdef.Name
            if name.startswith("MSys") or name.startswith("~"):
                continue

            if "DP_" in name or "Dienstplan" in name or "Plan" in name:
                dp_tables.append(name)
            elif name.startswith("tbl_MA_"):
                ma_tables.append(name)
            elif name.startswith("tbl_VA_"):
                va_tables.append(name)
            elif name.startswith("tbl_OB_"):
                ob_tables.append(name)

        print("\n--- DIENSTPLAN-TABELLEN ---")
        for t in sorted(dp_tables):
            print(f"  {t}")
            # Felder anzeigen
            tdef = db.TableDefs(t)
            fields = []
            for f in tdef.Fields:
                fields.append(f"{f.Name} ({f.Type})")
            print(f"    Felder: {', '.join(fields[:8])}...")

        print("\n--- MITARBEITER-TABELLEN ---")
        for t in sorted(ma_tables)[:15]:
            print(f"  {t}")

        print("\n--- AUFTRAGS-TABELLEN ---")
        for t in sorted(va_tables)[:15]:
            print(f"  {t}")

        print("\n--- OBJEKT-TABELLEN ---")
        for t in sorted(ob_tables)[:10]:
            print(f"  {t}")

        # Detailanalyse wichtiger Tabellen
        key_tables = [
            "tbl_MA_Mitarbeiter",
            "tbl_VA_Auftrag",
            "tbl_VA_Datum",
            "tbl_VA_Start",
            "tbl_MA_VA_Einsatz",
            "tbl_MA_VA_Anfrage",
            "tbl_MA_NVerfueg",
            "tbl_OB_Objekt"
        ]

        print("\n" + "=" * 60)
        print("DETAIL-ANALYSE WICHTIGER TABELLEN")
        print("=" * 60)

        for tname in key_tables:
            try:
                tdef = db.TableDefs(tname)
                print(f"\n>>> {tname}")
                for f in tdef.Fields:
                    type_map = {1: "Boolean", 2: "Byte", 3: "Integer", 4: "Long",
                               5: "Currency", 6: "Single", 7: "Double", 8: "Date",
                               10: "Text", 11: "OLE", 12: "Memo"}
                    ftype = type_map.get(f.Type, f"Type{f.Type}")
                    print(f"    {f.Name}: {ftype}")
            except:
                print(f"\n>>> {tname} - NICHT GEFUNDEN")

        db.Close()

    except Exception as e:
        print(f"Fehler: {e}")

    # Frontend analysieren - Formulare und Abfragen
    print("\n" + "=" * 60)
    print("FRONTEND ANALYSE - FORMULARE & ABFRAGEN")
    print("=" * 60)

    try:
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = False
        access.OpenCurrentDatabase(FRONTEND_PATH)

        db = access.CurrentDb()

        # DP-Formulare
        print("\n--- DIENSTPLAN-FORMULARE ---")
        for doc in access.CurrentProject.AllForms:
            if "DP_" in doc.Name or "Dienstplan" in doc.Name or "Plan" in doc.Name:
                print(f"  {doc.Name}")

        # DP-Abfragen
        print("\n--- DIENSTPLAN-ABFRAGEN ---")
        dp_queries = []
        for qdef in db.QueryDefs:
            if "DP_" in qdef.Name or "Dienstplan" in qdef.Name:
                dp_queries.append(qdef.Name)

        for q in sorted(dp_queries)[:30]:
            print(f"  {q}")

        access.CloseCurrentDatabase()
        access.Quit()

    except Exception as e:
        print(f"Frontend-Fehler: {e}")

    pythoncom.CoUninitialize()

if __name__ == "__main__":
    analyze_tables()
