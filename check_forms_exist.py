"""Prüft ob die gefragten Formulare in Access existieren"""
import sys
sys.path.append(r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

forms_to_check = [
    "frm_VA_Planungsuebersicht",
    "frm_KD_Umsatzauswertung",
    "frm_KD_Verrechnungssaetze",
    "frm_DP_Einzeldienstplaene",
    "frm_Angebot",
    "frm_Rechnung",
    "frm_N_Bewerber",
    "frmOff_WinWord_aufrufen",
    "frm_MA_Adressen",
    "frm_MA_Zeitkonten"
]

print("Prüfe Existenz der Formulare in Access...\n")

try:
    with AccessBridge() as bridge:
        app = bridge.access_app
        db = app.CurrentDb()
        all_forms = []

        # Iterate through AllForms collection via CurrentProject
        for i in range(app.CurrentProject.AllForms.Count):
            all_forms.append(app.CurrentProject.AllForms(i).Name)

        print(f"Gesamt-Anzahl Formulare in Access: {len(all_forms)}\n")

        print("PRÜFERGEBNIS:")
        print("-" * 60)

        for form_name in forms_to_check:
            exists = form_name in all_forms
            status = "[OK] VORHANDEN" if exists else "[XX] FEHLT"
            print(f"{status}  {form_name}")

        # Ähnliche Namen suchen
        print("\n" + "="*60)
        print("ÄHNLICHE NAMEN (Falls exakter Name nicht existiert):")
        print("="*60)

        for form_name in forms_to_check:
            if form_name not in all_forms:
                # Suche nach ähnlichen Namen
                keywords = form_name.replace("frm_", "").replace("frmTop_", "").replace("frmOff_", "").lower()
                similar = [f for f in all_forms if keywords.split("_")[0] in f.lower()]
                if similar:
                    print(f"\n{form_name}:")
                    for sim in similar[:5]:  # Max 5 Vorschläge
                        print(f"  → {sim}")

except Exception as e:
    print(f"FEHLER: {e}")
    import traceback
    traceback.print_exc()
