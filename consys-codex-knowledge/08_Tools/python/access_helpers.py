"""
Hilfsskripte für häufige Access-Operationen
"""

from access_bridge import AccessBridge
from typing import List, Dict
import json
import os


class AccessHelper:
    """Erweiterte Hilfsfunktionen für Access-Operationen"""
    
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.bridge = AccessBridge(db_path)
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.bridge.disconnect()
    
    # ==================== FORMULAR-HELPERS ====================
    
    def create_simple_form(self, form_name: str, table_name: str, 
                          fields: List[str] = None) -> None:
        """
        Erstellt einfaches Formular mit Controls
        
        Args:
            form_name: Name des neuen Formulars
            table_name: Zugrunde liegende Tabelle
            fields: Liste der anzuzeigenden Felder (None = alle)
        """
        # Formular erstellen
        self.bridge.run_vba_function("CreateNewForm", form_name, table_name)
        
        if fields:
            # Controls für spezifische Felder hinzufügen
            y_position = 500
            for field in fields:
                # Label
                self.bridge.run_vba_function("AddControlToForm", 
                    form_name, 100, f"lbl_{field}", 500, y_position, 2000, 300)
                
                # Textbox
                self.bridge.run_vba_function("AddControlToForm",
                    form_name, 109, field, 2600, y_position, 3000, 300)
                
                y_position += 400
        
        print(f"✓ Formular '{form_name}' erstellt mit {len(fields) if fields else 'allen'} Feldern")
    
    def populate_form_from_dict(self, form_name: str, data: Dict) -> None:
        """
        Füllt Formular mit Werten aus Dictionary
        
        Args:
            form_name: Name des Formulars
            data: Dictionary mit Feldnamen und Werten
        """
        # Formular öffnen
        self.bridge.open_form(form_name, data_mode=0)  # 0 = Add mode
        
        # Werte setzen
        for field, value in data.items():
            try:
                self.bridge.set_form_control_value(form_name, field, value)
            except Exception as e:
                print(f"Warnung: Feld '{field}' konnte nicht gesetzt werden: {e}")
        
        # Datensatz speichern
        self.bridge.run_vba_sub("DoCmd.RunCommand", 97)  # acCmdSaveRecord
        
        print(f"✓ Formular '{form_name}' gefüllt und gespeichert")
    
    def export_form_data_to_json(self, form_name: str, output_path: str) -> None:
        """
        Exportiert aktuelle Formular-Daten als JSON
        
        Args:
            form_name: Name des Formulars
            output_path: Pfad für JSON-Datei
        """
        # Formular öffnen
        self.bridge.open_form(form_name, window_mode=1)  # Hidden
        
        # RecordSource ermitteln
        recordsource = self.bridge.get_form_recordsource(form_name)
        
        # Daten aus RecordSource holen
        data = self.bridge.execute_sql(f"SELECT * FROM {recordsource}")
        
        # Als JSON speichern
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, default=str)
        
        # Formular schließen
        self.bridge.close_form(form_name, save=2)  # NoSave
        
        print(f"✓ Daten exportiert: {output_path}")
    
    # ==================== BATCH-OPERATIONEN ====================
    
    def bulk_insert(self, table_name: str, records: List[Dict]) -> int:
        """
        Fügt mehrere Datensätze auf einmal ein
        
        Args:
            table_name: Name der Tabelle
            records: Liste von Dictionaries (ein Dict pro Datensatz)
        
        Returns:
            Anzahl erfolgreich eingefügter Datensätze
        """
        success_count = 0
        
        for record in records:
            try:
                self.bridge.insert_record(table_name, record)
                success_count += 1
            except Exception as e:
                print(f"Fehler bei Datensatz {success_count + 1}: {e}")
        
        print(f"✓ {success_count}/{len(records)} Datensätze eingefügt")
        return success_count
    
    def bulk_update(self, table_name: str, updates: List[Dict], 
                   id_field: str = "ID") -> int:
        """
        Aktualisiert mehrere Datensätze
        
        Args:
            table_name: Name der Tabelle
            updates: Liste von Dicts mit ID und zu aktualisierenden Feldern
            id_field: Name des ID-Felds
        
        Returns:
            Anzahl erfolgreich aktualisierter Datensätze
        """
        success_count = 0
        
        for update in updates:
            try:
                record_id = update.pop(id_field)
                where = f"{id_field} = {record_id}"
                self.bridge.update_record(table_name, update, where)
                success_count += 1
            except Exception as e:
                print(f"Fehler bei Update {success_count + 1}: {e}")
        
        print(f"✓ {success_count}/{len(updates)} Datensätze aktualisiert")
        return success_count
    
    # ==================== REPORT-HELPERS ====================
    
    def generate_reports_batch(self, report_configs: List[Dict]) -> None:
        """
        Generiert mehrere Reports auf einmal
        
        Args:
            report_configs: Liste von Dicts mit report_name, output_path, where
        """
        for config in report_configs:
            try:
                self.bridge.export_report_pdf(
                    config['report_name'],
                    config['output_path'],
                    config.get('where')
                )
                print(f"✓ Report generiert: {config['output_path']}")
            except Exception as e:
                print(f"Fehler bei Report {config['report_name']}: {e}")
    
    # ==================== DATENBANK-WARTUNG ====================
    
    def analyze_table_sizes(self) -> List[Dict]:
        """
        Analysiert Größe aller Tabellen
        
        Returns:
            Liste mit Tabellen-Infos (Name, Anzahl Datensätze)
        """
        tables = self.bridge.list_tables()
        results = []
        
        for table in tables:
            try:
                count_sql = f"SELECT COUNT(*) as cnt FROM [{table}]"
                result = self.bridge.execute_sql(count_sql)
                count = result[0]['cnt'] if result else 0
                
                results.append({
                    'table': table,
                    'record_count': count
                })
            except Exception as e:
                print(f"Warnung: Tabelle '{table}' nicht lesbar: {e}")
        
        # Nach Anzahl sortieren
        results.sort(key=lambda x: x['record_count'], reverse=True)
        return results
    
    def find_empty_tables(self) -> List[str]:
        """
        Findet alle leeren Tabellen
        
        Returns:
            Liste mit Namen leerer Tabellen
        """
        analysis = self.analyze_table_sizes()
        return [item['table'] for item in analysis if item['record_count'] == 0]
    
    def cleanup_temp_tables(self) -> int:
        """
        Löscht temporäre Tabellen (Namen mit tmp, temp, zz)
        
        Returns:
            Anzahl gelöschter Tabellen
        """
        tables = self.bridge.list_tables()
        deleted = 0
        
        for table in tables:
            # Temporäre Tabellen-Präfixe
            if any(table.lower().startswith(prefix) for prefix in ['tmp', 'temp', 'zz', 'tbltmp']):
                try:
                    self.bridge.execute_sql(f"DROP TABLE [{table}]", fetch=False)
                    deleted += 1
                    print(f"✓ Gelöscht: {table}")
                except Exception as e:
                    print(f"Fehler beim Löschen von {table}: {e}")
        
        print(f"\n✓ {deleted} temporäre Tabellen gelöscht")
        return deleted
    
    # ==================== DATEN-MIGRATION ====================
    
    def export_table_to_json(self, table_name: str, output_path: str) -> None:
        """
        Exportiert Tabelle komplett als JSON
        
        Args:
            table_name: Name der Tabelle
            output_path: Pfad für JSON-Datei
        """
        data = self.bridge.get_table_data(table_name)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, default=str)
        
        print(f"✓ Tabelle '{table_name}' exportiert: {output_path}")
    
    def import_table_from_json(self, table_name: str, json_path: str) -> int:
        """
        Importiert Tabelle aus JSON
        
        Args:
            table_name: Name der Zieltabelle
            json_path: Pfad zur JSON-Datei
        
        Returns:
            Anzahl importierter Datensätze
        """
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        return self.bulk_insert(table_name, data)
    
    # ==================== QUERY-HELPERS ====================
    
    def create_filtered_query(self, query_name: str, table_name: str, 
                             filters: Dict) -> None:
        """
        Erstellt gefilterte Query
        
        Args:
            query_name: Name der neuen Query
            table_name: Quelltabelle
            filters: Dictionary mit Feldern und Werten für Filter
        """
        where_clauses = []
        for field, value in filters.items():
            if isinstance(value, str):
                where_clauses.append(f"[{field}] = '{value}'")
            else:
                where_clauses.append(f"[{field}] = {value}")
        
        where = " AND ".join(where_clauses)
        sql = f"SELECT * FROM [{table_name}] WHERE {where}"
        
        self.bridge.create_query(query_name, sql)
        print(f"✓ Gefilterte Query '{query_name}' erstellt")
    
    # ==================== VALIDIERUNG ====================
    
    def validate_table_integrity(self, table_name: str, 
                                required_fields: List[str]) -> Dict:
        """
        Validiert Tabellenintegrität
        
        Args:
            table_name: Name der Tabelle
            required_fields: Liste mit Pflichtfeldern
        
        Returns:
            Dictionary mit Validierungsergebnissen
        """
        results = {
            'valid': True,
            'missing_fields': [],
            'null_counts': {},
            'total_records': 0
        }
        
        # Schema prüfen
        schema = self.bridge.get_table_schema(table_name)
        existing_fields = [field['name'] for field in schema]
        
        for field in required_fields:
            if field not in existing_fields:
                results['missing_fields'].append(field)
                results['valid'] = False
        
        # Null-Werte zählen
        data = self.bridge.get_table_data(table_name)
        results['total_records'] = len(data)
        
        for field in required_fields:
            if field in existing_fields:
                null_count = sum(1 for row in data if row.get(field) is None)
                if null_count > 0:
                    results['null_counts'][field] = null_count
                    results['valid'] = False
        
        return results
    
    # ==================== STATISTIKEN ====================
    
    def get_database_statistics(self) -> Dict:
        """
        Sammelt umfassende Datenbank-Statistiken
        
        Returns:
            Dictionary mit Statistiken
        """
        stats = self.bridge.get_database_info()
        
        # Tabellen-Analyse
        table_analysis = self.analyze_table_sizes()
        stats['largest_tables'] = table_analysis[:10]
        stats['empty_tables_count'] = len([t for t in table_analysis if t['record_count'] == 0])
        stats['total_records'] = sum(t['record_count'] for t in table_analysis)
        
        return stats
    
    def print_statistics(self) -> None:
        """Gibt Datenbank-Statistiken aus"""
        stats = self.get_database_statistics()
        
        print("\n" + "="*60)
        print("DATENBANK-STATISTIKEN")
        print("="*60)
        print(f"Pfad: {stats['path']}")
        print(f"Größe: {stats['size_mb']:.2f} MB")
        print(f"Tabellen: {stats['tables_count']}")
        print(f"Queries: {stats['queries_count']}")
        print(f"Formulare: {stats['forms_count']}")
        print(f"Reports: {stats['reports_count']}")
        print(f"Module: {stats['modules_count']}")
        print(f"Gesamt-Datensätze: {stats['total_records']:,}")
        print(f"Leere Tabellen: {stats['empty_tables_count']}")
        
        print("\n" + "-"*60)
        print("GRÖßTE TABELLEN (Top 10)")
        print("-"*60)
        for item in stats['largest_tables']:
            print(f"{item['table']:40} {item['record_count']:>10,} Datensätze")
        print("="*60)


# ==================== BEISPIELE ====================

def example_usage():
    """Beispiele für Hilfsfunktionen"""
    
    db_path = r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
    
    with AccessHelper(db_path) as helper:
        # Statistiken anzeigen
        helper.print_statistics()
        
        # Leere Tabellen finden
        print("\n=== Leere Tabellen ===")
        empty = helper.find_empty_tables()
        for table in empty[:10]:
            print(f"- {table}")
        
        # Tabelle als JSON exportieren
        # helper.export_table_to_json("tbl_MA_Einsatzart", "export_einsatzart.json")


if __name__ == "__main__":
    example_usage()
