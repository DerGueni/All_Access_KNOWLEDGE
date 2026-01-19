# -*- coding: utf-8 -*-
"""
Analyse der Positionen und Objekte mit Positionen
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

    print("=" * 70)
    print("=== OBJEKTE MIT POSITIONEN ===")
    print("=" * 70)

    # Alle Objekte holen
    cursor.execute("SELECT * FROM [tbl_OB_Objekt]")
    obj_columns = [col[0] for col in cursor.description]
    all_objects = {row[0]: dict(zip(obj_columns, row)) for row in cursor.fetchall()}

    print(f"Gesamt Objekte: {len(all_objects)}")

    # Alle Positionen holen
    print("\nPositionen-Tabelle analysieren...")
    try:
        cursor.execute("SELECT * FROM [tbl_OB_Objekt_Positionen]")
        pos_columns = [col[0] for col in cursor.description]
        print(f"Positions-Spalten: {pos_columns}")

        positions = cursor.fetchall()
        print(f"Gesamt Positionen: {len(positions)}")

        # Gruppieren nach Objekt
        obj_positions = {}
        for pos in positions:
            pos_dict = dict(zip(pos_columns, pos))
            obj_id = pos_dict.get('OB_Objekt_Kopf_ID')
            if obj_id not in obj_positions:
                obj_positions[obj_id] = []
            obj_positions[obj_id].append(pos_dict)

        print(f"\nObjekte mit Positionen: {len(obj_positions)}")
        for obj_id, pos_list in obj_positions.items():
            obj = all_objects.get(obj_id, {})
            obj_name = obj.get('Objekt', 'Unbekannt')
            print(f"\n  Objekt {obj_id}: {obj_name} ({len(pos_list)} Positionen)")
            for pos in pos_list[:5]:
                print(f"    - {pos.get('Gruppe', 'N/A')}: {pos.get('Zusatztext', '')}")
            if len(pos_list) > 5:
                print(f"    ... und {len(pos_list) - 5} weitere")

    except Exception as e:
        print(f"Fehler: {e}")

    # Objekte ohne Positionen
    print("\n" + "=" * 70)
    print("=== OBJEKTE OHNE POSITIONEN ===")
    print("=" * 70)
    objects_with_positions = set(obj_positions.keys()) if 'obj_positions' in dir() else set()
    for obj_id, obj in all_objects.items():
        if obj_id not in objects_with_positions:
            print(f"  ID {obj_id}: {obj.get('Objekt', 'N/A')} ({obj.get('Ort', '')})")

    conn.close()

if __name__ == "__main__":
    analyze()
