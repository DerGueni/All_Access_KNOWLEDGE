# -*- coding: utf-8 -*-
"""
Automatisches Setup der HTML-Ansicht-Buttons in Access-Formularen
==================================================================
Findet alle Access-Formulare die eine HTML-Version haben und fuegt
automatisch den "HTML Ansicht" Button hinzu.
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from access_bridge_ultimate import AccessBridge

# HTML-Pfad
HTML_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML"

# Mapping von HTML-Dateinamen zu moeglichen Access-Formularnamen
# AKTUALISIERT basierend auf tatsaechlich vorhandenen Formularen!
HTML_TO_ACCESS_MAPPING = {
    "frm_N_Kundenstammblatt.html": [
        "frm_KD_Kundenstamm",  # Existiert!
        "frm_N_Kundenstammblatt",
    ],
    "frm_N_Mitarbeiterstammblatt.html": [
        "frm_MA_Mitarbeiterstamm",  # Existiert!
        "frm_N_Mitarbeiterstammblatt",
    ],
    "frm_N_Abwesenheitsplanung.html": [
        "frm_Abwesenheiten",  # Existiert!
        "frm_MA_NVerfuegZeiten_Si",  # Existiert!
        "frm_N_Abwesenheitsplanung"
    ],
    "frm_N_Abwesenheitsstatistik.html": [
        "frm_abwesenheitsuebersicht",  # Existiert!
        "frm_N_Abwesenheitsstatistik"
    ],
    "frm_N_Dienstplanuebersicht.html": [
        "frm_DP_Dienstplan_MA",  # Existiert!
        "frm_DP_Dienstplan_Objekt",  # Existiert!
        "frm_Einsatzuebersicht_kpl",  # Existiert!
        "frm_N_Dienstplanuebersicht"
    ],
    "frm_N_Mitarbeiterauswahl.html": [
        "frm_MA_VA_Schnellauswahl",  # Existiert!
        "frm_MA_VA_Positionszuordnung",  # Existiert!
        "frm_N_MA_VA_Positionszuordnung",  # Existiert!
        "frm_N_Mitarbeiterauswahl"
    ],
    "frm_VA_Auftragstamm_HTML.html": [
        "frm_VA_Auftragstamm",  # Existiert!
        "frm_N_VA_Auftragstamm_HTML",  # Existiert!
        "frm_Auftragsuebersicht_neu"  # Existiert!
    ],
    "frm_N_Planungsuebersicht.html": [
        "frm_N_MA_Monatsuebersicht",  # Existiert!
        "frm_N_Planungsuebersicht"
    ],
    "frm_N_Bewerberverwaltung.html": [
        "frm_N_MA_Bewerber_Verarbeitung",  # Existiert!
        "frm_N_Bewerberverwaltung"
    ]
}


def find_existing_forms(bridge, possible_names):
    """Findet welche der moeglichen Formularnamen tatsaechlich existieren"""
    existing = []
    all_forms = bridge.list_forms()

    for name in possible_names:
        if name in all_forms:
            existing.append(name)

    return existing


def main():
    print("=" * 70)
    print("AUTOMATISCHES SETUP: HTML-ANSICHT BUTTONS")
    print("=" * 70)
    print(f"HTML-Pfad: {HTML_PATH}")
    print("")

    # Pruefe welche HTML-Dateien existieren
    html_files = []
    for f in os.listdir(HTML_PATH):
        if f.startswith('frm_') and f.endswith('.html'):
            html_files.append(f)

    print(f"Gefundene HTML-Formulare: {len(html_files)}")
    for hf in sorted(html_files):
        print(f"  - {hf}")
    print("")

    try:
        with AccessBridge() as bridge:
            print("")
            print("-" * 70)
            print("SUCHE PASSENDE ACCESS-FORMULARE")
            print("-" * 70)

            # Sammle alle zu bearbeitenden Formulare
            forms_to_setup = {}

            for html_file in html_files:
                if html_file in HTML_TO_ACCESS_MAPPING:
                    possible_forms = HTML_TO_ACCESS_MAPPING[html_file]
                else:
                    # Fallback: Versuche Name ohne .html
                    base_name = html_file.replace('.html', '')
                    possible_forms = [base_name]

                existing = find_existing_forms(bridge, possible_forms)

                if existing:
                    for form_name in existing:
                        forms_to_setup[form_name] = html_file
                        print(f"  [OK] {html_file} -> {form_name}")
                else:
                    print(f"  [!] {html_file} -> Kein passendes Access-Formular gefunden")
                    print(f"       Gesucht: {', '.join(possible_forms)}")

            print("")
            print("-" * 70)
            print(f"FUEGE BUTTONS ZU {len(forms_to_setup)} FORMULAREN HINZU")
            print("-" * 70)

            if not forms_to_setup:
                print("[!] Keine Formulare zum Bearbeiten gefunden!")
                return

            # Buttons hinzufuegen
            results = {"success": [], "failed": [], "skipped": []}

            for form_name, html_file in forms_to_setup.items():
                print(f"\n>>> Bearbeite: {form_name}")

                # Pruefe ob Button bereits existiert
                if bridge.control_exists(form_name, "btnHTMLAnsicht"):
                    print(f"    [=] Button existiert bereits")
                    results["skipped"].append(form_name)
                    continue

                # Button hinzufuegen
                success = bridge.setup_html_view_switch(form_name, html_file)

                if success:
                    results["success"].append(form_name)
                else:
                    results["failed"].append(form_name)

            # Ergebnis
            print("")
            print("=" * 70)
            print("ERGEBNIS")
            print("=" * 70)
            print(f"Erfolgreich: {len(results['success'])}")
            for f in results['success']:
                print(f"  [OK] {f}")

            print(f"\nUebersprungen (bereits vorhanden): {len(results['skipped'])}")
            for f in results['skipped']:
                print(f"  [=] {f}")

            print(f"\nFehlgeschlagen: {len(results['failed'])}")
            for f in results['failed']:
                print(f"  [!] {f}")

            print("")
            print("=" * 70)
            print("SETUP ABGESCHLOSSEN")
            print("=" * 70)

    except Exception as e:
        print(f"\n[!] FEHLER: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
