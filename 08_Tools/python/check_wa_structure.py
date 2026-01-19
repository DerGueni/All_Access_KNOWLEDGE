from access_bridge import AccessBridge
import sys

try:
    with AccessBridge('Consys_FE_N_Test_Claude_GPT.accdb') as bridge:
        # Prüfe Abfragen
        queries = bridge.get_query_list()
        print('=== Offene Anfragen Queries ===')
        for q in queries:
            if 'offene' in q.lower() or 'anfrage' in q.lower():
                print(f'  - {q}')
        
        # Prüfe WhatsApp Tabelle
        print('\n=== WhatsApp Tabellen ===')
        tables = bridge.get_table_list()
        for t in tables:
            if 'whatsapp' in t.lower():
                print(f'  - {t}')
                try:
                    cols = bridge.get_table_schema(t)
                    for col in cols:
                        print(f'    {col["name"]} ({col["type"]})')
                except Exception as e:
                    print(f'    Fehler beim Schema: {e}')
        
        # Prüfe zmd_Whatsapp Modul
        print('\n=== WhatsApp Module ===')
        modules = bridge.get_module_list()
        for m in modules:
            if 'whatsapp' in m.lower():
                print(f'  - {m}')
        
        # Prüfe Email-Log Tabelle
        print('\n=== Email Log Tabellen ===')
        for t in tables:
            if 'email' in t.lower() and 'log' in t.lower():
                print(f'  - {t}')
                
except Exception as e:
    print(f'Fehler: {e}')
    import traceback
    traceback.print_exc()
    sys.exit(1)
