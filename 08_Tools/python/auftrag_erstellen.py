"""
Auftrag mit Mitarbeitern und Schichten anlegen
Beispiel: 2 Mitarbeiter, 18:00-23:00
"""

from access_bridge import AccessBridge
from datetime import datetime

def create_auftrag_with_shifts(db_path, auftrag_data):
    """
    Erstellt einen vollständigen Auftrag mit Schichten
    
    Args:
        db_path: Pfad zur Access-Datenbank
        auftrag_data: Dict mit Auftragsdaten
            {
                'auftrag_name': str,
                'objekt': str,
                'ort': str,
                'datum': str (YYYY-MM-DD),
                'ma_anzahl': int,
                'start_zeit': str (HH:MM),
                'end_zeit': str (HH:MM),
                'bemerkungen': str (optional)
            }
    
    Returns:
        Dict mit VA_ID, VADatum_ID, VAStart_ID
    """
    
    with AccessBridge(db_path) as bridge:
        
        # Schritt 1: Auftrag in tbl_VA_Auftragstamm erstellen
        print(f"Schritt 1: Erstelle Auftrag '{auftrag_data['auftrag_name']}'...")
        
        auftrag_sql = f"""
        INSERT INTO tbl_VA_Auftragstamm 
        (Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) 
        VALUES 
        ('{auftrag_data['auftrag_name']}', 
         '{auftrag_data['objekt']}', 
         '{auftrag_data['ort']}', 
         #{auftrag_data['datum']}#, 
         #{auftrag_data['datum']}#, 
         1, 
         '{bridge.get_username()}', 
         Now(), 
         1)
        """
        bridge.execute_sql(auftrag_sql)
        
        # Schritt 2: VA_ID ermitteln
        print("Schritt 2: Ermittle VA_ID...")
        va_id_result = bridge.execute_sql(
            f"SELECT MAX(ID) AS NewID FROM tbl_VA_Auftragstamm WHERE Auftrag = '{auftrag_data['auftrag_name']}'"
        )
        va_id = va_id_result[0]['NewID']
        print(f"  → VA_ID: {va_id}")
        
        # Schritt 3: Eintrag in tbl_VA_AnzTage erstellen
        print("Schritt 3: Erstelle VA_AnzTage Eintrag...")
        anztage_sql = f"""
        INSERT INTO tbl_VA_AnzTage 
        (VA_ID, VADatum, TVA_Soll, TVA_Ist) 
        VALUES 
        ({va_id}, #{auftrag_data['datum']}#, {auftrag_data['ma_anzahl']}, 0)
        """
        bridge.execute_sql(anztage_sql)
        
        # Schritt 4: VADatum_ID ermitteln
        print("Schritt 4: Ermittle VADatum_ID...")
        vadatum_id_result = bridge.execute_sql(
            f"SELECT ID FROM tbl_VA_AnzTage WHERE VA_ID = {va_id}"
        )
        vadatum_id = vadatum_id_result[0]['ID']
        print(f"  → VADatum_ID: {vadatum_id}")
        
        # Schritt 5: Mitarbeiter und Zeiten in tbl_VA_Start eintragen
        print("Schritt 5: Erstelle VA_Start Eintrag...")
        
        start_datetime = f"{auftrag_data['datum']} {auftrag_data['start_zeit']}:00"
        end_datetime = f"{auftrag_data['datum']} {auftrag_data['end_zeit']}:00"
        bemerkung = auftrag_data.get('bemerkungen', '')
        
        vastart_sql = f"""
        INSERT INTO tbl_VA_Start 
        (VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende, Bemerkungen) 
        VALUES 
        ({va_id}, 
         {vadatum_id}, 
         #{auftrag_data['datum']}#, 
         {auftrag_data['ma_anzahl']}, 
         #{auftrag_data['start_zeit']}:00#, 
         #{auftrag_data['end_zeit']}:00#, 
         #{start_datetime}#, 
         #{end_datetime}#,
         '{bemerkung}')
        """
        bridge.execute_sql(vastart_sql)
        
        # VAStart_ID ermitteln
        vastart_id_result = bridge.execute_sql(
            f"SELECT MAX(ID) FROM tbl_VA_Start WHERE VA_ID = {va_id}"
        )
        vastart_id = vastart_id_result[0]['MaxOfID'] if 'MaxOfID' in vastart_id_result[0] else vastart_id_result[0][list(vastart_id_result[0].keys())[0]]
        print(f"  → VAStart_ID: {vastart_id}")
        
        # Verifizierung: Prüfe ob Auftrag in qry_lst_Row_Auftrag erscheint
        print("\nVerifizierung...")
        verify_sql = f"""
        SELECT ID, Datum, Auftrag, Objekt, Ort, Soll, Ist, Status
        FROM qry_lst_Row_Auftrag
        WHERE ID = {va_id}
        """
        verify_result = bridge.execute_sql(verify_sql)
        
        if verify_result:
            print("✓ Auftrag erfolgreich in qry_lst_Row_Auftrag sichtbar!")
            print(f"  Datum: {verify_result[0].get('Datum')}")
            print(f"  Auftrag: {verify_result[0].get('Auftrag')}")
            print(f"  Soll: {verify_result[0].get('Soll')}")
        else:
            print("⚠ Warnung: Auftrag nicht in qry_lst_Row_Auftrag sichtbar!")
        
        return {
            'va_id': va_id,
            'vadatum_id': vadatum_id,
            'vastart_id': vastart_id,
            'success': True
        }


if __name__ == "__main__":
    # Beispiel-Auftrag erstellen
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    auftrag = {
        'auftrag_name': f'TEST_AUFTRAG_{datetime.now().strftime("%H%M%S")}',
        'objekt': 'Test Objekt',
        'ort': 'Test Ort',
        'datum': '2025-11-10',
        'ma_anzahl': 2,
        'start_zeit': '18:00',
        'end_zeit': '23:00',
        'bemerkungen': 'Testauftrag mit 2 MA'
    }
    
    print("=" * 60)
    print("AUFTRAGSERSTELLUNG - VOLLAUTOMATISCH")
    print("=" * 60)
    print(f"Auftrag: {auftrag['auftrag_name']}")
    print(f"Datum: {auftrag['datum']}")
    print(f"Zeit: {auftrag['start_zeit']} - {auftrag['end_zeit']}")
    print(f"Mitarbeiter: {auftrag['ma_anzahl']}")
    print("=" * 60)
    print()
    
    result = create_auftrag_with_shifts(db_path, auftrag)
    
    print("\n" + "=" * 60)
    print("ERGEBNIS")
    print("=" * 60)
    print(f"VA_ID: {result['va_id']}")
    print(f"VADatum_ID: {result['vadatum_id']}")
    print(f"VAStart_ID: {result['vastart_id']}")
    print("=" * 60)
