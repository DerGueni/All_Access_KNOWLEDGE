import os
import re

forms_dir = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\NEUHTML\02_web\forms"

# Files that need to be fixed (from bridgeClient.js to webview2-bridge.js)
files_to_fix = [
    "frm_Ausweis_Create.logic.js",
    "frm_Einsatzuebersicht.logic.js",
    "frm_KD_Kundenstamm.logic.js",
    "frm_lst_row_auftrag.logic.js",
    "frm_MA_Abwesenheit.logic.js",
    "frm_MA_Mitarbeiterstamm.logic.js",
    "frm_MA_VA_Schnellauswahl.logic.js",
    "frm_MA_Zeitkonten.logic.js",
    "frm_N_Dienstplanuebersicht.logic.js",
    "frm_N_Lohnabrechnungen.logic.js",
    "frm_N_MA_Bewerber_Verarbeitung.logic.js",
    "frm_N_Stundenauswertung.logic.js",
    "frm_VA_Planungsuebersicht.logic.js",
    "index.html",
    "sub_DP_Grund.logic.js",
    "sub_DP_Grund_MA.logic.js",
    "sub_MA_Offene_Anfragen.logic.js",
    "sub_MA_VA_Planung_Absage.logic.js",
    "sub_MA_VA_Planung_Status.logic.js",
    "sub_MA_VA_Zuordnung.logic.js",
    "sub_OB_Objekt_Positionen.logic.js",
    "sub_rch_Pos.logic.js",
    "sub_VA_Anzeige.logic.js",
    "sub_VA_Start.logic.js",
    "sub_ZusatzDateien.logic.js",
    "zfrm_Lohnabrechnungen.logic.js",
    "zfrm_Rueckmeldungen.logic.js"
]

fixed_count = 0
for filename in files_to_fix:
    filepath = os.path.join(forms_dir, filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Replace the import
        new_content = content.replace("from '../api/bridgeClient.js'", "from '../js/webview2-bridge.js'")
        new_content = new_content.replace('from "../api/bridgeClient.js"', "from '../js/webview2-bridge.js'")

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"[OK] Fixed: {filename}")
            fixed_count += 1
        else:
            print(f"[SKIP] No change needed: {filename}")
    else:
        print(f"[ERROR] Not found: {filename}")

print(f"\nTotal files fixed: {fixed_count}")
