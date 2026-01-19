# -*- coding: utf-8 -*-
"""
Direkte Analyse mit pyodbc (ohne Access Bridge Unicode-Probleme)
"""

import pyodbc
import os

# Pfade
FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT.accdb"
BACKEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_BE_N_Test_Claude_GPT.accdb"

def get_connection(db_path):
    """ODBC-Verbindung herstellen"""
    conn_str = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        f'DBQ={db_path};'
    )
    return pyodbc.connect(conn_str)

def analyze():
    print("=" * 70)
    print("ANALYSE: frm_OB_Objekt / rpt_OB_Objekt")
    print("=" * 70)

    # Zuerst Backend pruefen (dort sind die Daten)
    backend_exists = os.path.exists(BACKEND_PATH)
    print(f"\nBackend vorhanden: {backend_exists}")
    print(f"Backend-Pfad: {BACKEND_PATH}")

    # Verbindung zum Backend
    try:
        conn = get_connection(BACKEND_PATH if backend_exists else FRONTEND_PATH)
        cursor = conn.cursor()
        print("Verbindung hergestellt!")

        # 1. Alle Tabellen auflisten
        print("\n=== ALLE TABELLEN ===")
        tables = []
        for row in cursor.tables(tableType='TABLE'):
            table_name = row.table_name
            if not table_name.startswith('MSys') and not table_name.startswith('~'):
                tables.append(table_name)

        tables.sort()
        for t in tables:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM [{t}]")
                cnt = cursor.fetchone()[0]
                print(f"  {t}: {cnt} Datensaetze")
            except:
                print(f"  {t}: (Fehler)")

        # 2. OB-Tabellen im Detail
        print("\n=== OB-TABELLEN DETAIL ===")
        ob_tables = [t for t in tables if 'OB' in t.upper()]

        for table in ob_tables:
            print(f"\n--- {table} ---")
            try:
                # Spalten ermitteln
                cursor.execute(f"SELECT TOP 1 * FROM [{table}]")
                columns = [col[0] for col in cursor.description]
                print(f"  Spalten: {columns}")

                # Beispieldaten
                cursor.execute(f"SELECT TOP 3 * FROM [{table}]")
                rows = cursor.fetchall()
                for i, row in enumerate(rows):
                    row_dict = dict(zip(columns, row))
                    print(f"  Zeile {i+1}: {row_dict}")
            except Exception as e:
                print(f"  Fehler: {e}")

        # 3. Spezifisch tbl_OB_Objekt
        print("\n=== tbl_OB_Objekt VOLLSTAENDIG ===")
        try:
            cursor.execute("SELECT * FROM [tbl_OB_Objekt] ORDER BY OB_Objekt")
            columns = [col[0] for col in cursor.description]
            print(f"Spalten: {columns}")
            rows = cursor.fetchall()
            print(f"\nGesamt: {len(rows)} Objekte\n")

            for row in rows:
                row_dict = dict(zip(columns, row))
                obj_id = row_dict.get('ID_OB_Objekt', 'N/A')
                name = row_dict.get('OB_Objekt', 'N/A')
                ort = row_dict.get('Ort', 'N/A')
                strasse = row_dict.get('Strasse', 'N/A')
                print(f"  ID={obj_id}: {name} | Ort={ort} | Strasse={strasse}")
        except Exception as e:
            print(f"  Fehler: {e}")

        # 4. tbl_OB_Position
        print("\n=== tbl_OB_Position STRUKTUR ===")
        try:
            cursor.execute("SELECT TOP 1 * FROM [tbl_OB_Position]")
            columns = [col[0] for col in cursor.description]
            print(f"Spalten: {columns}")

            # Anzahl pro Objekt
            cursor.execute("""
                SELECT ID_OB_Objekt, COUNT(*) as cnt
                FROM [tbl_OB_Position]
                GROUP BY ID_OB_Objekt
                ORDER BY cnt DESC
            """)
            print("\nPositionen pro Objekt:")
            for row in cursor.fetchall():
                print(f"  Objekt {row[0]}: {row[1]} Positionen")
        except Exception as e:
            print(f"  Fehler: {e}")

        # 5. Positionslisten
        print("\n=== POSITIONSLISTEN ===")
        positionslisten_tables = [t for t in tables if 'POSITIONSLISTE' in t.upper() or 'VORLAGE' in t.upper()]
        print(f"Gefundene Tabellen: {positionslisten_tables}")

        for pt in positionslisten_tables:
            try:
                cursor.execute(f"SELECT TOP 5 * FROM [{pt}]")
                columns = [col[0] for col in cursor.description]
                print(f"\n{pt} - Spalten: {columns}")
                for row in cursor.fetchall():
                    print(f"  {dict(zip(columns, row))}")
            except Exception as e:
                print(f"  Fehler: {e}")

        # 6. Zeitslot-relevante Spalten
        print("\n=== ZEITSLOT-FELDER ===")
        try:
            cursor.execute("SELECT TOP 1 * FROM [tbl_OB_Position]")
            columns = [col[0] for col in cursor.description]
            zeit_cols = [c for c in columns if 'ZEIT' in c.upper() or 'TIME' in c.upper() or 'SLOT' in c.upper()]
            print(f"Zeitbezogene Spalten in tbl_OB_Position: {zeit_cols}")

            # Beispieldaten mit Zeitfeldern
            if zeit_cols:
                select_cols = ['ID_OB_Position', 'ID_OB_Objekt', 'OB_Position'] + zeit_cols
                sql = f"SELECT TOP 5 {', '.join(select_cols)} FROM [tbl_OB_Position]"
                cursor.execute(sql)
                for row in cursor.fetchall():
                    print(f"  {dict(zip(select_cols, row))}")
        except Exception as e:
            print(f"  Fehler: {e}")

        conn.close()
        print("\n" + "=" * 70)
        print("ANALYSE ABGESCHLOSSEN")
        print("=" * 70)

    except Exception as e:
        print(f"Verbindungsfehler: {e}")

if __name__ == "__main__":
    analyze()
