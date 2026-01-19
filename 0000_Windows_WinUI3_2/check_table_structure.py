"""
Ermittelt die korrekten Tabellen- und Feldnamen im Access Backend
"""

import pyodbc

BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb"
CONN_STRING = f"Driver={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={BACKEND_PATH};"

def list_tables():
    """Listet alle Tabellen auf"""
    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    print("=" * 70)
    print("ALLE TABELLEN IM BACKEND")
    print("=" * 70)

    # Tabellen abrufen
    tables = []
    for row in cursor.tables(tableType='TABLE'):
        if not row.table_name.startswith('MSys'):
            tables.append(row.table_name)

    # Sortiert nach Präfix
    prefixes = {}
    for t in sorted(tables):
        prefix = t.split('_')[0] if '_' in t else 'other'
        if prefix not in prefixes:
            prefixes[prefix] = []
        prefixes[prefix].append(t)

    for prefix in sorted(prefixes.keys()):
        print(f"\n{prefix}:")
        for t in prefixes[prefix]:
            print(f"  - {t}")

    conn.close()
    return tables

def show_table_structure(table_name):
    """Zeigt Struktur einer Tabelle"""
    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    print(f"\n{'=' * 70}")
    print(f"STRUKTUR: {table_name}")
    print("=" * 70)

    try:
        cursor.execute(f"SELECT TOP 1 * FROM [{table_name}]")
        columns = cursor.description
        print(f"{'Spalte':<30} {'Typ':<15} {'Nullable'}")
        print("-" * 60)
        for col in columns:
            print(f"{col[0]:<30} {str(col[1]):<15} {col[6]}")

        # Ersten Datensatz zeigen
        row = cursor.fetchone()
        if row:
            print(f"\nBeispieldaten:")
            for i, col in enumerate(columns):
                val = row[i]
                if val is not None:
                    val_str = str(val)[:50]
                    print(f"  {col[0]}: {val_str}")
    except Exception as e:
        print(f"FEHLER: {e}")

    conn.close()

def find_similar_tables(pattern):
    """Sucht Tabellen mit ähnlichem Namen"""
    conn = pyodbc.connect(CONN_STRING)
    cursor = conn.cursor()

    print(f"\nTabellen mit '{pattern}':")
    for row in cursor.tables(tableType='TABLE'):
        if pattern.lower() in row.table_name.lower():
            print(f"  - {row.table_name}")

    conn.close()

# Hauptprogramm
if __name__ == "__main__":
    # Relevante Tabellen prüfen
    tables_to_check = [
        "tbl_MA_Mitarbeiterstamm",
        "tbl_KD_Kundenstamm",
        "tbl_OB_Objekt",        # Korrekter Name!
        "tbl_VA_Auftragstamm",
        "tbl_MA_NVerfuegZeiten",
    ]

    # Suche nach Zeitkonto, Bewerber, Gründe Tabellen
    print("\n" + "=" * 70)
    print("SUCHE NACH TABELLEN")
    print("=" * 70)

    find_similar_tables("Zeitkonto")
    find_similar_tables("ZK")
    find_similar_tables("Bewerber")
    find_similar_tables("Gruende")
    find_similar_tables("Grund")
    find_similar_tables("NV")

    # Struktur der wichtigsten Tabellen
    for table in tables_to_check:
        show_table_structure(table)
