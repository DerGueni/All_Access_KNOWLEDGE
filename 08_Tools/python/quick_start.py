"""
Quick Start Script - Schnellstart für Access Bridge
Demonstriert grundlegende Funktionen
"""

import os
import json
from access_bridge import AccessBridge
from access_helpers import AccessHelper


def load_config():
    """Lädt Konfiguration"""
    config_path = os.path.join(os.path.dirname(__file__), "config.json")
    
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            return json.load(f)
    
    # Fallback auf Standard-Pfad
    return {
        "database": {
            "frontend_path": r"C:\users\guenther.siegert\documents\Consys_FE_N_Test_Claude_GPT.accdb"
        }
    }


def demo_basic_operations():
    """Demonstriert Basis-Operationen"""
    config = load_config()
    db_path = config['database']['frontend_path']
    
    print("="*70)
    print("ACCESS BRIDGE - QUICK START DEMO")
    print("="*70)
    print(f"\nDatenbank: {db_path}\n")
    
    # Mit Context Manager - automatisches Verbinden/Trennen
    with AccessBridge(db_path) as bridge:
        
        # 1. Datenbank-Info
        print("1. DATENBANK-INFORMATIONEN")
        print("-"*70)
        info = bridge.get_database_info()
        for key, value in info.items():
            print(f"  {key:20}: {value}")
        
        # 2. Tabellen auflisten
        print("\n2. TABELLEN (erste 15)")
        print("-"*70)
        tables = bridge.list_tables()[:15]
        for i, table in enumerate(tables, 1):
            print(f"  {i:2}. {table}")
        print(f"  ... ({len(bridge.list_tables())} Tabellen gesamt)")
        
        # 3. Formulare auflisten
        print("\n3. FORMULARE (erste 10)")
        print("-"*70)
        forms = bridge.list_forms()[:10]
        for i, form in enumerate(forms, 1):
            print(f"  {i:2}. {form}")
        print(f"  ... ({len(bridge.list_forms())} Formulare gesamt)")
        
        # 4. Beispiel-Daten lesen
        print("\n4. BEISPIEL-DATEN aus tbl_MA_Einsatzart")
        print("-"*70)
        try:
            data = bridge.get_table_data("tbl_MA_Einsatzart", limit=5)
            if data:
                for row in data:
                    print(f"  ID: {row.get('ID')}, Name: {row.get('QualiName')}")
            else:
                print("  (keine Daten)")
        except Exception as e:
            print(f"  Fehler: {e}")
        
        # 5. Queries auflisten
        print("\n5. QUERIES (erste 10)")
        print("-"*70)
        queries = bridge.list_queries()[:10]
        for i, query in enumerate(queries, 1):
            print(f"  {i:2}. {query}")
        print(f"  ... ({len(bridge.list_queries())} Queries gesamt)")
        
        # 6. VBA-Module auflisten
        print("\n6. VBA-MODULE")
        print("-"*70)
        try:
            modules = bridge.list_modules()
            for i, module in enumerate(modules[:10], 1):
                print(f"  {i:2}. {module}")
            if len(modules) > 10:
                print(f"  ... ({len(modules)} Module gesamt)")
        except Exception as e:
            print(f"  VBA-Zugriff nicht möglich: {e}")


def demo_helper_functions():
    """Demonstriert Helper-Funktionen"""
    config = load_config()
    db_path = config['database']['frontend_path']
    
    print("\n" + "="*70)
    print("HELPER-FUNKTIONEN DEMO")
    print("="*70)
    
    with AccessHelper(db_path) as helper:
        # Statistiken
        helper.print_statistics()
        
        # Leere Tabellen finden
        print("\nLEERE TABELLEN (erste 10)")
        print("-"*70)
        empty = helper.find_empty_tables()[:10]
        if empty:
            for table in empty:
                print(f"  - {table}")
        else:
            print("  (keine leeren Tabellen gefunden)")


def interactive_menu():
    """Interaktives Menü"""
    config = load_config()
    db_path = config['database']['frontend_path']
    
    while True:
        print("\n" + "="*70)
        print("ACCESS BRIDGE - INTERAKTIVES MENÜ")
        print("="*70)
        print("\n1. Datenbank-Info anzeigen")
        print("2. Tabellen auflisten")
        print("3. Formulare auflisten")
        print("4. Queries auflisten")
        print("5. Reports auflisten")
        print("6. VBA-Module auflisten")
        print("7. Statistiken anzeigen")
        print("8. Leere Tabellen finden")
        print("9. SQL-Query ausführen")
        print("0. Beenden")
        
        choice = input("\nWahl: ").strip()
        
        if choice == "0":
            print("Auf Wiedersehen!")
            break
        
        try:
            with AccessBridge(db_path) as bridge:
                
                if choice == "1":
                    info = bridge.get_database_info()
                    print("\n--- Datenbank-Info ---")
                    for key, value in info.items():
                        print(f"{key}: {value}")
                
                elif choice == "2":
                    tables = bridge.list_tables()
                    print(f"\n--- Tabellen ({len(tables)}) ---")
                    for table in tables:
                        print(f"  - {table}")
                
                elif choice == "3":
                    forms = bridge.list_forms()
                    print(f"\n--- Formulare ({len(forms)}) ---")
                    for form in forms:
                        print(f"  - {form}")
                
                elif choice == "4":
                    queries = bridge.list_queries()
                    print(f"\n--- Queries ({len(queries)}) ---")
                    for query in queries:
                        print(f"  - {query}")
                
                elif choice == "5":
                    reports = bridge.list_reports()
                    print(f"\n--- Reports ({len(reports)}) ---")
                    for report in reports:
                        print(f"  - {report}")
                
                elif choice == "6":
                    modules = bridge.list_modules()
                    print(f"\n--- VBA-Module ({len(modules)}) ---")
                    for module in modules:
                        print(f"  - {module}")
                
                elif choice == "7":
                    helper = AccessHelper(db_path)
                    helper.print_statistics()
                    helper.bridge.disconnect()
                
                elif choice == "8":
                    helper = AccessHelper(db_path)
                    empty = helper.find_empty_tables()
                    print(f"\n--- Leere Tabellen ({len(empty)}) ---")
                    for table in empty:
                        print(f"  - {table}")
                    helper.bridge.disconnect()
                
                elif choice == "9":
                    sql = input("SQL-Query: ").strip()
                    if sql:
                        result = bridge.execute_sql(sql)
                        print(f"\n--- Ergebnis ({len(result)} Zeilen) ---")
                        for row in result[:20]:  # Max 20 Zeilen
                            print(row)
                        if len(result) > 20:
                            print(f"... ({len(result) - 20} weitere Zeilen)")
                
                else:
                    print("Ungültige Wahl!")
        
        except Exception as e:
            print(f"\nFehler: {e}")
        
        input("\nEnter drücken...")


def main():
    """Hauptfunktion"""
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "--demo":
            demo_basic_operations()
            demo_helper_functions()
        elif sys.argv[1] == "--interactive":
            interactive_menu()
        else:
            print("Unbekannte Option. Verwende: --demo oder --interactive")
    else:
        # Standard: Demo-Modus
        demo_basic_operations()
        demo_helper_functions()


if __name__ == "__main__":
    main()
