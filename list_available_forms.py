"""
Liste alle verfügbaren Formulare in Access
"""
import sys
sys.path.append(r'C:\Users\guenther.siegert\Documents\Access Bridge')
from access_bridge_ultimate import AccessBridge

FORMS_TO_CHECK = [
    'frm_VA_Planungsuebersicht',
    'frm_KD_Umsatzauswertung',
    'frm_KD_Verrechnungssaetze',
    'frm_DP_Einzeldienstplaene',
    'frm_Angebot',
    'frm_Rechnung',
    'frm_N_Bewerber',
    'frmTop_Geo_Verwaltung',
    'frmOff_WinWord_aufrufen',
    'frm_MA_Adressen',
    'frm_MA_Zeitkonten'
]

with AccessBridge() as bridge:
    print("Alle verfuegbaren Formulare:")
    print("-" * 60)
    all_forms = bridge.list_forms()
    for form in sorted(all_forms):
        print(f"  {form}")

    print("\n" + "=" * 60)
    print("Pruefe angeforderte Formulare:")
    print("=" * 60)

    for form_name in FORMS_TO_CHECK:
        exists = bridge.form_exists(form_name)
        status = "OK" if exists else "NICHT GEFUNDEN"
        print(f"  [{status}] {form_name}")
