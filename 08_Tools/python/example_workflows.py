"""
Beispiel-Workflows für häufige CONSEC-Aufgaben
"""

from access_bridge import AccessBridge
from access_helpers import AccessHelper
from consec_helpers import ConsecHelper
import json


# ==================== WORKFLOW 1: MITARBEITER-QUALIFIKATIONEN VERWALTEN ====================

def workflow_manage_qualifications():
    """Qualifikationen verwalten und zuweisen"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with ConsecHelper(db_path) as helper:
        print("=== QUALIFIKATIONS-VERWALTUNG ===\n")
        
        # 1. Übersicht über alle Qualifikationen
        print("1. Alle Qualifikationen:")
        qualifications = helper.list_all_qualifications()
        for q in qualifications:
            print(f"  - {q['QualiName']} ({q['AnzahlMA']} Mitarbeiter)")
        
        # 2. Neue Qualifikation erstellen (Beispiel)
        # quali_id = helper.create_new_qualification(
        #     "Brandschutzhelfer",
        #     "Grundausbildung gemäß ASR A2.2"
        # )
        
        # 3. Mitarbeiter mit bestimmter Qualifikation finden
        print("\n2. Mitarbeiter mit §34a GewO:")
        ma_34a = helper.get_employees_with_qualification("§34a GewO")
        for ma in ma_34a[:5]:
            print(f"  - {ma['Nachname']}, {ma['Vorname']}")
        
        # 4. Qualifikation zu Mitarbeiter hinzufügen (Beispiel)
        # helper.add_qualification_to_employee(123, "Brandschutzhelfer")
        
        # 5. Statistik-Report
        print("\n3. Qualifikations-Report:")
        helper.print_qualification_report()


# ==================== WORKFLOW 2: VERANSTALTUNGS-PLANUNG ====================

def workflow_event_planning():
    """Veranstaltungen planen und Personal zuordnen"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with ConsecHelper(db_path) as helper:
        print("=== VERANSTALTUNGS-PLANUNG ===\n")
        
        # 1. Kommende Veranstaltungen anzeigen
        print("1. Kommende Veranstaltungen (30 Tage):")
        events = helper.get_upcoming_events(days=30)
        for event in events[:10]:
            print(f"  - {event['VA_Datum']}: {event['Veranstaltung']}")
        
        # 2. Personal-Zuordnung für bestimmte Veranstaltung
        if events:
            va_id = events[0]['ID']
            print(f"\n2. Personal für VA {va_id}:")
            staff = helper.get_event_staff_assignments(va_id)
            for s in staff:
                print(f"  - {s['Nachname']}, {s['Vorname']}: "
                      f"{s['MVA_Start']} - {s['MVA_Ende']}")
        
        # 3. Mitarbeiter zuordnen (Beispiel)
        # helper.assign_employee_to_event(
        #     va_id=123,
        #     vadatum_id=456,
        #     ma_id=789,
        #     start="14:00",
        #     ende="22:00"
        # )


# ==================== WORKFLOW 3: DATENBANK-WARTUNG ====================

def workflow_database_maintenance():
    """Datenbank warten und optimieren"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with AccessHelper(db_path) as helper:
        print("=== DATENBANK-WARTUNG ===\n")
        
        # 1. Statistiken anzeigen
        print("1. Datenbank-Statistiken:")
        helper.print_statistics()
        
        # 2. Leere Tabellen finden
        print("\n2. Leere Tabellen:")
        empty_tables = helper.find_empty_tables()
        for table in empty_tables[:10]:
            print(f"  - {table}")
        
        # 3. Temporäre Tabellen löschen (Vorsicht!)
        # print("\n3. Temporäre Tabellen löschen:")
        # count = helper.cleanup_temp_tables()
        # print(f"  Gelöscht: {count} Tabellen")
        
        # 4. Backup erstellen
        print("\n4. Backup erstellen:")
        from datetime import datetime
        backup_name = f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.accdb"
        backup_path = f"C:\\Users\\guenther.siegert\\Documents\\Access Bridge\\backups\\{backup_name}"
        helper.bridge.backup_database(backup_path)
        print(f"  Gespeichert: {backup_path}")
        
        # 5. Komprimieren und reparieren
        # print("\n5. Datenbank komprimieren:")
        # helper.bridge.compact_and_repair()


# ==================== WORKFLOW 4: DATEN-EXPORT ====================

def workflow_data_export():
    """Daten in verschiedene Formate exportieren"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    export_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\exports"
    
    with AccessHelper(db_path) as helper:
        print("=== DATEN-EXPORT ===\n")
        
        # 1. Tabelle als JSON exportieren
        print("1. Exportiere Qualifikationen als JSON:")
        helper.export_table_to_json(
            "tbl_MA_Einsatzart",
            f"{export_path}\\qualifikationen.json"
        )
        
        # 2. Formular-Daten exportieren
        print("\n2. Exportiere Formular-Daten:")
        helper.export_form_data_to_json(
            "frm_MA_Mitarbeiterstamm",
            f"{export_path}\\mitarbeiter.json"
        )
        
        # 3. Eigene Daten-Auswahl exportieren
        print("\n3. Exportiere aktive Mitarbeiter:")
        data = helper.bridge.execute_sql("""
            SELECT Nachname, Vorname, Email, Tel_Mobil
            FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = True
            ORDER BY Nachname, Vorname
        """)
        
        with open(f"{export_path}\\aktive_mitarbeiter.json", 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, default=str)
        
        print(f"  Exportiert: {len(data)} Mitarbeiter")


# ==================== WORKFLOW 5: REPORT-GENERIERUNG ====================

def workflow_report_generation():
    """Reports automatisch generieren"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    output_path = r"C:\Users\guenther.siegert\Documents\Access Bridge\exports"
    
    with AccessBridge(db_path) as bridge:
        print("=== REPORT-GENERIERUNG ===\n")
        
        # 1. Einzelner Report
        print("1. Generiere Mitarbeiter-Report:")
        # bridge.export_report_pdf(
        #     "rpt_Mitarbeiterliste",
        #     f"{output_path}\\mitarbeiter_liste.pdf",
        #     where="IstAktiv = True"
        # )
        
        # 2. Batch-Reports für mehrere Filter
        print("\n2. Generiere mehrere Reports:")
        
        # report_configs = [
        #     {
        #         "report_name": "rpt_Mitarbeiterliste",
        #         "output_path": f"{output_path}\\aktive_mitarbeiter.pdf",
        #         "where": "IstAktiv = True"
        #     },
        #     {
        #         "report_name": "rpt_Mitarbeiterliste",
        #         "output_path": f"{output_path}\\inaktive_mitarbeiter.pdf",
        #         "where": "IstAktiv = False"
        #     }
        # ]
        
        # from access_helpers import AccessHelper
        # helper = AccessHelper(db_path)
        # helper.generate_reports_batch(report_configs)


# ==================== WORKFLOW 6: FORMULAR-AUTOMATION ====================

def workflow_form_automation():
    """Formulare automatisch öffnen und ausfüllen"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with AccessBridge(db_path) as bridge:
        print("=== FORMULAR-AUTOMATION ===\n")
        
        # 1. Formular öffnen
        print("1. Öffne Mitarbeiter-Formular:")
        # bridge.open_form("frm_MA_Mitarbeiterstamm", data_mode=0)  # 0 = Add
        
        # 2. Felder ausfüllen
        # data = {
        #     "Nachname": "Mustermann",
        #     "Vorname": "Max",
        #     "Email": "max.mustermann@example.com",
        #     "Tel_Mobil": "0171-1234567",
        #     "IstAktiv": True
        # }
        
        # for field, value in data.items():
        #     bridge.set_form_control_value(
        #         "frm_MA_Mitarbeiterstamm",
        #         field,
        #         value
        #     )
        
        # 3. Formular speichern und schließen
        # bridge.run_vba_sub("DoCmd.RunCommand", 97)  # acCmdSaveRecord
        # bridge.close_form("frm_MA_Mitarbeiterstamm", save=1)
        
        print("  (Im Beispiel deaktiviert)")


# ==================== WORKFLOW 7: BATCH-IMPORT ====================

def workflow_batch_import():
    """Daten aus CSV importieren"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with AccessHelper(db_path) as helper:
        print("=== BATCH-IMPORT ===\n")
        
        # Beispiel: Neue Qualifikationen aus Liste importieren
        new_qualifications = [
            {"QualiName": "Erste Hilfe", "Bemerkung": "16h Grundkurs"},
            {"QualiName": "Brandschutzhelfer", "Bemerkung": "ASR A2.2"},
            {"QualiName": "Evakuierungshelfer", "Bemerkung": "4h Schulung"}
        ]
        
        print("1. Importiere neue Qualifikationen:")
        # count = helper.bulk_insert("tbl_MA_Einsatzart", new_qualifications)
        # print(f"  {count} Qualifikationen importiert")
        
        print("  (Im Beispiel deaktiviert)")


# ==================== HAUPTMENÜ ====================

def main():
    """Hauptmenü für Workflows"""
    
    workflows = {
        "1": ("Qualifikationen verwalten", workflow_manage_qualifications),
        "2": ("Veranstaltungs-Planung", workflow_event_planning),
        "3": ("Datenbank-Wartung", workflow_database_maintenance),
        "4": ("Daten-Export", workflow_data_export),
        "5": ("Report-Generierung", workflow_report_generation),
        "6": ("Formular-Automation", workflow_form_automation),
        "7": ("Batch-Import", workflow_batch_import)
    }
    
    while True:
        print("\n" + "="*70)
        print("WORKFLOW-BEISPIELE")
        print("="*70)
        
        for key, (name, _) in workflows.items():
            print(f"{key}. {name}")
        
        print("\n0. Beenden")
        print("="*70)
        
        choice = input("\nWorkflow wählen: ").strip()
        
        if choice == "0":
            print("Auf Wiedersehen!")
            break
        
        if choice in workflows:
            print()
            try:
                workflows[choice][1]()
            except Exception as e:
                print(f"\nFehler: {e}")
            
            input("\nEnter drücken...")
        else:
            print("Ungültige Wahl!")


if __name__ == "__main__":
    main()
