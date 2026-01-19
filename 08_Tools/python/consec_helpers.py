"""
CONSEC-spezifische Helper-Funktionen
Spezielle Operationen für das CONSEC-System
"""

from access_bridge import AccessBridge
from typing import List, Dict, Optional
from datetime import datetime, timedelta


class ConsecHelper:
    """CONSEC-spezifische Datenbankoperationen"""
    
    def __init__(self, db_path: str):
        self.bridge = AccessBridge(db_path)
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.bridge.disconnect()
    
    # ==================== MITARBEITER ====================
    
    def get_active_employees(self, with_qualifications: bool = False) -> List[Dict]:
        """
        Holt alle aktiven Mitarbeiter
        
        Args:
            with_qualifications: Auch Qualifikationen laden
        
        Returns:
            Liste mit Mitarbeiter-Daten
        """
        sql = """
        SELECT ID, Nachname, Vorname, Email, Tel_Mobil, 
               Hat_keine_34a, HatSachkunde, Datum_34a
        FROM tbl_MA_Mitarbeiterstamm
        WHERE IstAktiv = True
        ORDER BY Nachname, Vorname
        """
        
        employees = self.bridge.execute_sql(sql)
        
        if with_qualifications:
            for emp in employees:
                emp['qualifikationen'] = self.get_employee_qualifications(emp['ID'])
        
        return employees
    
    def get_employee_qualifications(self, ma_id: int) -> List[str]:
        """
        Holt Qualifikationen eines Mitarbeiters
        
        Args:
            ma_id: Mitarbeiter-ID
        
        Returns:
            Liste mit Qualifikationsnamen
        """
        sql = f"""
        SELECT e.QualiName
        FROM tbl_MA_Einsatz_Zuo z
        INNER JOIN tbl_MA_Einsatzart e ON z.Quali_ID = e.ID
        WHERE z.MA_ID = {ma_id}
        """
        
        result = self.bridge.execute_sql(sql)
        return [row['QualiName'] for row in result]
    
    def add_qualification_to_employee(self, ma_id: int, quali_name: str) -> bool:
        """
        Fügt Qualifikation zu Mitarbeiter hinzu
        
        Args:
            ma_id: Mitarbeiter-ID
            quali_name: Name der Qualifikation
        
        Returns:
            True bei Erfolg
        """
        # Qualifikations-ID ermitteln
        sql = f"SELECT ID FROM tbl_MA_Einsatzart WHERE QualiName = '{quali_name}'"
        result = self.bridge.execute_sql(sql)
        
        if not result:
            print(f"Qualifikation '{quali_name}' nicht gefunden")
            return False
        
        quali_id = result[0]['ID']
        
        # Prüfen ob schon vorhanden
        check_sql = f"""
        SELECT * FROM tbl_MA_Einsatz_Zuo 
        WHERE MA_ID = {ma_id} AND Quali_ID = {quali_id}
        """
        existing = self.bridge.execute_sql(check_sql)
        
        if existing:
            print(f"Qualifikation bereits vorhanden")
            return False
        
        # Einfügen
        self.bridge.insert_record("tbl_MA_Einsatz_Zuo", {
            "MA_ID": ma_id,
            "Quali_ID": quali_id
        })
        
        print(f"✓ Qualifikation '{quali_name}' zu MA {ma_id} hinzugefügt")
        return True
    
    def get_employees_with_qualification(self, quali_name: str) -> List[Dict]:
        """
        Findet alle Mitarbeiter mit bestimmter Qualifikation
        
        Args:
            quali_name: Name der Qualifikation
        
        Returns:
            Liste mit Mitarbeitern
        """
        sql = f"""
        SELECT m.ID, m.Nachname, m.Vorname, m.Email, m.Tel_Mobil
        FROM tbl_MA_Mitarbeiterstamm m
        INNER JOIN tbl_MA_Einsatz_Zuo z ON m.ID = z.MA_ID
        INNER JOIN tbl_MA_Einsatzart e ON z.Quali_ID = e.ID
        WHERE m.IstAktiv = True AND e.QualiName = '{quali_name}'
        ORDER BY m.Nachname, m.Vorname
        """
        
        return self.bridge.execute_sql(sql)
    
    def update_employee_34a_status(self, ma_id: int, has_34a: bool, 
                                   datum: Optional[str] = None) -> None:
        """
        Aktualisiert §34a-Status eines Mitarbeiters
        
        Args:
            ma_id: Mitarbeiter-ID
            has_34a: True = hat §34a
            datum: Datum der Prüfung (YYYY-MM-DD)
        """
        data = {
            "Hat_keine_34a": not has_34a  # Invertiert!
        }
        
        if datum:
            data["Datum_34a"] = datum
        
        self.bridge.update_record(
            "tbl_MA_Mitarbeiterstamm",
            data,
            where=f"ID = {ma_id}"
        )
        
        print(f"✓ §34a-Status aktualisiert für MA {ma_id}")
    
    # ==================== VERANSTALTUNGEN ====================
    
    def get_upcoming_events(self, days: int = 30) -> List[Dict]:
        """
        Holt kommende Veranstaltungen
        
        Args:
            days: Anzahl Tage in die Zukunft
        
        Returns:
            Liste mit Veranstaltungen
        """
        today = datetime.now().strftime("%m/%d/%Y")  # Access-Format
        future = (datetime.now() + timedelta(days=days)).strftime("%m/%d/%Y")
        
        sql = f"""
        SELECT v.ID, v.Auftrag, v.Veranstaltung, a.VA_Datum, a.Anzahl
        FROM tbl_VA_Auftragstamm v
        INNER JOIN tbl_VA_AnzTage a ON v.ID = a.VA_ID
        WHERE a.VA_Datum >= #{today}# AND a.VA_Datum <= #{future}#
        ORDER BY a.VA_Datum
        """
        
        return self.bridge.execute_sql(sql)
    
    def get_event_staff_assignments(self, va_id: int) -> List[Dict]:
        """
        Holt Mitarbeiter-Zuordnungen für Veranstaltung
        
        Args:
            va_id: Veranstaltungs-ID
        
        Returns:
            Liste mit Zuordnungen
        """
        sql = f"""
        SELECT m.Nachname, m.Vorname, z.MVA_Start, z.MVA_Ende,
               s.Start_Std, s.Start_Min
        FROM tbl_MA_VA_Zuordnung z
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
        INNER JOIN tbl_VA_Start s ON z.VA_ID = s.VA_ID AND z.VADatum_ID = s.VADatum_ID
        WHERE z.VA_ID = {va_id}
        ORDER BY s.Start_Std, s.Start_Min, m.Nachname
        """
        
        return self.bridge.execute_sql(sql)
    
    def assign_employee_to_event(self, va_id: int, vadatum_id: int, 
                                 ma_id: int, start: str, ende: str) -> bool:
        """
        Ordnet Mitarbeiter zu Veranstaltung zu
        
        Args:
            va_id: Veranstaltungs-ID
            vadatum_id: Veranstaltungsdatum-ID
            ma_id: Mitarbeiter-ID
            start: Startzeit (HH:MM)
            ende: Endzeit (HH:MM)
        
        Returns:
            True bei Erfolg
        """
        try:
            self.bridge.insert_record("tbl_MA_VA_Zuordnung", {
                "VA_ID": va_id,
                "VADatum_ID": vadatum_id,
                "MA_ID": ma_id,
                "MVA_Start": start,
                "MVA_Ende": ende
            })
            print(f"✓ MA {ma_id} zu VA {va_id} zugeordnet")
            return True
        except Exception as e:
            print(f"Fehler bei Zuordnung: {e}")
            return False
    
    # ==================== QUALIFIKATIONEN ====================
    
    def list_all_qualifications(self) -> List[Dict]:
        """
        Listet alle Qualifikationen auf
        
        Returns:
            Liste mit Qualifikationen und Anzahl Mitarbeiter
        """
        sql = """
        SELECT e.ID, e.QualiName, e.Bemerkung,
               COUNT(z.MA_ID) AS AnzahlMA
        FROM tbl_MA_Einsatzart e
        LEFT JOIN tbl_MA_Einsatz_Zuo z ON e.ID = z.Quali_ID
        GROUP BY e.ID, e.QualiName, e.Bemerkung
        ORDER BY e.QualiName
        """
        
        return self.bridge.execute_sql(sql)
    
    def create_new_qualification(self, quali_name: str, 
                                bemerkung: str = "") -> int:
        """
        Erstellt neue Qualifikation
        
        Args:
            quali_name: Name der Qualifikation
            bemerkung: Optional Bemerkung
        
        Returns:
            ID der neuen Qualifikation
        """
        self.bridge.insert_record("tbl_MA_Einsatzart", {
            "QualiName": quali_name,
            "Bemerkung": bemerkung
        })
        
        # ID ermitteln
        sql = f"SELECT ID FROM tbl_MA_Einsatzart WHERE QualiName = '{quali_name}'"
        result = self.bridge.execute_sql(sql)
        
        quali_id = result[0]['ID']
        print(f"✓ Qualifikation '{quali_name}' erstellt (ID: {quali_id})")
        return quali_id
    
    def delete_qualification(self, quali_id: int) -> bool:
        """
        Löscht Qualifikation (inkl. Zuordnungen)
        
        Args:
            quali_id: Qualifikations-ID
        
        Returns:
            True bei Erfolg
        """
        try:
            # Erst Zuordnungen löschen
            self.bridge.delete_record(
                "tbl_MA_Einsatz_Zuo",
                where=f"Quali_ID = {quali_id}"
            )
            
            # Dann Qualifikation
            self.bridge.delete_record(
                "tbl_MA_Einsatzart",
                where=f"ID = {quali_id}"
            )
            
            print(f"✓ Qualifikation {quali_id} gelöscht")
            return True
        except Exception as e:
            print(f"Fehler beim Löschen: {e}")
            return False
    
    # ==================== STATISTIKEN ====================
    
    def get_qualification_statistics(self) -> Dict:
        """
        Erstellt Qualifikations-Statistik
        
        Returns:
            Dictionary mit Statistiken
        """
        stats = {}
        
        # Gesamt-Qualifikationen
        qualifications = self.list_all_qualifications()
        stats['gesamt_qualifikationen'] = len(qualifications)
        
        # Top 10 häufigste
        stats['top_qualifikationen'] = sorted(
            qualifications,
            key=lambda x: x['AnzahlMA'],
            reverse=True
        )[:10]
        
        # Qualifikationen ohne Mitarbeiter
        stats['ungenutzte_qualifikationen'] = [
            q for q in qualifications if q['AnzahlMA'] == 0
        ]
        
        # Mitarbeiter nach Qualifikationsanzahl
        sql = """
        SELECT m.ID, m.Nachname, m.Vorname, COUNT(z.Quali_ID) AS AnzahlQuali
        FROM tbl_MA_Mitarbeiterstamm m
        LEFT JOIN tbl_MA_Einsatz_Zuo z ON m.ID = z.MA_ID
        WHERE m.IstAktiv = True
        GROUP BY m.ID, m.Nachname, m.Vorname
        ORDER BY COUNT(z.Quali_ID) DESC
        """
        
        ma_quali = self.bridge.execute_sql(sql)
        stats['ma_mit_meisten_quali'] = ma_quali[:10]
        stats['ma_ohne_quali'] = [m for m in ma_quali if m['AnzahlQuali'] == 0]
        
        return stats
    
    def print_qualification_report(self) -> None:
        """Gibt Qualifikations-Report aus"""
        stats = self.get_qualification_statistics()
        
        print("\n" + "="*70)
        print("QUALIFIKATIONS-REPORT")
        print("="*70)
        
        print(f"\nGesamt: {stats['gesamt_qualifikationen']} Qualifikationen")
        
        print("\n" + "-"*70)
        print("TOP 10 QUALIFIKATIONEN")
        print("-"*70)
        for q in stats['top_qualifikationen']:
            print(f"{q['QualiName']:40} {q['AnzahlMA']:>5} MA")
        
        if stats['ungenutzte_qualifikationen']:
            print("\n" + "-"*70)
            print(f"UNGENUTZTE QUALIFIKATIONEN ({len(stats['ungenutzte_qualifikationen'])})")
            print("-"*70)
            for q in stats['ungenutzte_qualifikationen'][:10]:
                print(f"- {q['QualiName']}")
        
        print("\n" + "-"*70)
        print("MITARBEITER MIT MEISTEN QUALIFIKATIONEN")
        print("-"*70)
        for ma in stats['ma_mit_meisten_quali']:
            print(f"{ma['Nachname']:20} {ma['Vorname']:15} {ma['AnzahlQuali']:>5} Quali.")
        
        if stats['ma_ohne_quali']:
            print(f"\nMitarbeiter ohne Qualifikationen: {len(stats['ma_ohne_quali'])}")
        
        print("="*70)
    
    # ==================== BATCH-OPERATIONEN ====================
    
    def bulk_assign_qualification(self, ma_ids: List[int], 
                                  quali_name: str) -> int:
        """
        Weist mehreren Mitarbeitern eine Qualifikation zu
        
        Args:
            ma_ids: Liste mit Mitarbeiter-IDs
            quali_name: Name der Qualifikation
        
        Returns:
            Anzahl erfolgreicher Zuordnungen
        """
        success_count = 0
        
        for ma_id in ma_ids:
            if self.add_qualification_to_employee(ma_id, quali_name):
                success_count += 1
        
        print(f"\n✓ {success_count}/{len(ma_ids)} Zuordnungen erfolgreich")
        return success_count
    
    def update_all_34a_from_date(self, cutoff_date: str) -> int:
        """
        Setzt §34a-Status basierend auf Datum
        
        Args:
            cutoff_date: Stichtag (YYYY-MM-DD)
        
        Returns:
            Anzahl aktualisierter Datensätze
        """
        sql = f"""
        UPDATE tbl_MA_Mitarbeiterstamm
        SET Hat_keine_34a = IIF(Datum_34a >= #{cutoff_date}#, False, True)
        WHERE Datum_34a IS NOT NULL
        """
        
        self.bridge.execute_sql(sql, fetch=False)
        print(f"✓ §34a-Status aktualisiert (Stichtag: {cutoff_date})")
        return 0


# ==================== BEISPIELE ====================

def example_usage():
    """Beispiele für CONSEC-Helper"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with ConsecHelper(db_path) as helper:
        # Qualifikations-Report
        helper.print_qualification_report()
        
        # Aktive Mitarbeiter
        print("\n=== AKTIVE MITARBEITER ===")
        employees = helper.get_active_employees()
        print(f"Anzahl: {len(employees)}")
        
        # Mitarbeiter mit bestimmter Qualifikation
        print("\n=== MITARBEITER MIT §34a ===")
        ma_34a = helper.get_employees_with_qualification("§34a GewO")
        for ma in ma_34a[:10]:
            print(f"- {ma['Nachname']}, {ma['Vorname']}")


if __name__ == "__main__":
    example_usage()
