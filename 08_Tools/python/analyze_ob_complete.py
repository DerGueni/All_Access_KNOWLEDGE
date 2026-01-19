# -*- coding: utf-8 -*-
"""
Vollstaendige Analyse der OB-Tabellen (verknuepfte Tabellen)
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

    # 1. tbl_OB_Objekt analysieren
    print("=" * 70)
    print("=== tbl_OB_Objekt ===")
    print("=" * 70)
    try:
        cursor.execute("SELECT * FROM [tbl_OB_Objekt]")
        columns = [col[0] for col in cursor.description]
        print(f"Spalten: {columns}")

        rows = cursor.fetchall()
        print(f"\nGesamt: {len(rows)} Objekte\n")

        for row in rows:
            row_dict = dict(zip(columns, row))
            print(f"  ID={row_dict.get('ID_OB_Objekt', 'N/A')}: {row_dict.get('OB_Objekt', 'N/A')}")
            print(f"    Ort: {row_dict.get('Ort', 'N/A')}")
            print(f"    Strasse: {row_dict.get('Strasse', 'N/A')}")
            print(f"    PLZ: {row_dict.get('PLZ', 'N/A')}")
            # Zeige alle Felder
            for k, v in row_dict.items():
                if v and k not in ['ID_OB_Objekt', 'OB_Objekt', 'Ort', 'Strasse', 'PLZ']:
                    print(f"    {k}: {v}")
            print()
    except Exception as e:
        print(f"Fehler: {e}")

    # 2. tbl_OB_Objekt_Positionen analysieren
    print("\n" + "=" * 70)
    print("=== tbl_OB_Objekt_Positionen ===")
    print("=" * 70)
    try:
        cursor.execute("SELECT TOP 1 * FROM [tbl_OB_Objekt_Positionen]")
        columns = [col[0] for col in cursor.description]
        print(f"Spalten: {columns}")

        # Zaehlen pro Objekt
        cursor.execute("""
            SELECT ID_OB_Objekt, COUNT(*) as cnt
            FROM [tbl_OB_Objekt_Positionen]
            GROUP BY ID_OB_Objekt
        """)
        print("\nPositionen pro Objekt:")
        for row in cursor.fetchall():
            print(f"  Objekt {row[0]}: {row[1]} Positionen")

        # Beispiel-Positionen fuer ein Objekt
        print("\nBeispiel-Positionen (erstes Objekt mit Positionen):")
        cursor.execute("""
            SELECT TOP 10 *
            FROM [tbl_OB_Objekt_Positionen]
            ORDER BY ID_OB_Objekt, ID_OB_Objekt_Pos
        """)
        columns = [col[0] for col in cursor.description]
        for row in cursor.fetchall():
            row_dict = dict(zip(columns, row))
            print(f"  {row_dict}")
    except Exception as e:
        print(f"Fehler: {e}")

    # 3. Positionslisten-Vorlagen
    print("\n" + "=" * 70)
    print("=== tbl_N_Positions_Vorlagen ===")
    print("=" * 70)
    try:
        cursor.execute("SELECT * FROM [tbl_N_Positions_Vorlagen]")
        columns = [col[0] for col in cursor.description]
        print(f"Spalten: {columns}")
        rows = cursor.fetchall()
        print(f"\nGesamt: {len(rows)} Vorlagen")
        for row in rows:
            print(f"  {dict(zip(columns, row))}")
    except Exception as e:
        print(f"Fehler: {e}")

    # 4. Vorlagen-Details
    print("\n=== tbl_N_Positions_Vorlagen_Details ===")
    try:
        cursor.execute("SELECT * FROM [tbl_N_Positions_Vorlagen_Details]")
        columns = [col[0] for col in cursor.description]
        print(f"Spalten: {columns}")
        rows = cursor.fetchall()
        print(f"\nGesamt: {len(rows)} Detail-Eintraege")
        for row in rows[:10]:
            print(f"  {dict(zip(columns, row))}")
    except Exception as e:
        print(f"Fehler: {e}")

    conn.close()
    print("\n" + "=" * 70)
    print("ANALYSE ABGESCHLOSSEN")
    print("=" * 70)

if __name__ == "__main__":
    analyze()
