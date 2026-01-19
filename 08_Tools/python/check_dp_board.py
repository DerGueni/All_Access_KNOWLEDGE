"""Prueft ob Planungs-Dashboard Komponenten vorhanden sind"""
from access_bridge_ultimate import AccessBridge

with AccessBridge() as bridge:
    print("\n=== PLANUNGS-DASHBOARD CHECK ===\n")

    # Abfragen pruefen
    queries_needed = ["qry_DP_Board_Objekt", "qry_DP_Board_MA", "qry_DP_MA_Verfuegbar"]
    print("ABFRAGEN:")
    for q in queries_needed:
        exists = bridge.query_exists(q)
        status = "[OK]" if exists else "[FEHLT]"
        print(f"  {status} {q}")

    # Modul pruefen
    print("\nMODULE:")
    modules = bridge.list_modules()
    mod_exists = "mod_N_DP_Board" in modules
    status = "[OK]" if mod_exists else "[FEHLT]"
    print(f"  {status} mod_N_DP_Board")

    # Formulare pruefen
    forms_needed = ["frm_DP_Board", "frm_DP_Board_Objekt", "frm_DP_Board_MA", "frm_DP_MA_Verfuegbar"]
    print("\nFORMULARE:")
    for f in forms_needed:
        exists = bridge.form_exists(f)
        status = "[OK]" if exists else "[FEHLT]"
        print(f"  {status} {f}")

    print("\n" + "=" * 40)
