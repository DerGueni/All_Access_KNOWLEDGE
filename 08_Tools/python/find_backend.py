# -*- coding: utf-8 -*-
"""
Findet das verknuepfte Backend und analysiert OB-Tabellen
"""

import pyodbc

FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"

def analyze():
    conn_str = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        f'DBQ={FRONTEND_PATH};'
    )
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Verknuepfungstabellen-Info auslesen
    print("=== VERKNUEPFUNGSTABELLEN ===")
    try:
        cursor.execute("SELECT * FROM [Acc_Acc_tblVerknuepfungstabellen]")
        columns = [col[0] for col in cursor.description]
        print(f"Spalten: {columns}")

        rows = cursor.fetchall()
        backends = set()
        for row in rows[:20]:
            row_dict = dict(zip(columns, row))
            # Suche nach Pfad-Spalten
            for col, val in row_dict.items():
                if val and isinstance(val, str) and ('.accdb' in val.lower() or '.mdb' in val.lower()):
                    print(f"  {row_dict.get('Tabellenname', 'N/A')}: {val}")
                    backends.add(val)

        print(f"\nGefundene Backends: {backends}")
    except Exception as e:
        print(f"Fehler: {e}")

    # OB-Tabellen suchen in allen sichtbaren Tabellen
    print("\n=== ALLE TABELLEN MIT 'OB' ===")
    for row in cursor.tables(tableType='TABLE'):
        if 'OB' in row.table_name.upper():
            print(f"  {row.table_name}")

    # Linked Tables (ODBC)
    print("\n=== VERKNUEPFTE TABELLEN ===")
    for row in cursor.tables():
        # Linked table types often have special table_type values
        if row.table_type not in ['TABLE', 'VIEW', 'SYSTEM TABLE']:
            print(f"  {row.table_name} (Typ: {row.table_type})")

    conn.close()

if __name__ == "__main__":
    analyze()
