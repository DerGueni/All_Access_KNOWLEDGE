# -*- coding: utf-8 -*-
"""
Findet Access-Formulare die zu den HTML-Dateien passen koennten
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from access_bridge_ultimate import AccessBridge

# Suchbegriffe fuer jedes HTML-Formular
SEARCH_TERMS = {
    "frm_N_Kundenstammblatt.html": ["kunden", "kund", "KD"],
    "frm_N_Mitarbeiterstammblatt.html": ["mitarbeiter", "MA_Stamm", "Personal"],
    "frm_N_Abwesenheitsplanung.html": ["abwesen", "urlaub", "krank", "verfueg"],
    "frm_N_Abwesenheitsstatistik.html": ["abwesen", "statistik"],
    "frm_N_Dienstplanuebersicht.html": ["dienstplan", "planung", "uebersicht"],
    "frm_N_Mitarbeiterauswahl.html": ["auswahl", "schnell", "zuordnung"],
    "frm_N_Planungsuebersicht.html": ["planung", "board", "kalender"],
    "frm_N_Bewerberverwaltung.html": ["bewerber", "bewerbung", "recruiting"],
    "frm_VA_Auftragstamm_HTML.html": ["auftrag", "VA_Auftrag"]
}


def main():
    print("=" * 70)
    print("SUCHE PASSENDE ACCESS-FORMULARE")
    print("=" * 70)

    with AccessBridge() as bridge:
        all_forms = bridge.list_forms()
        print(f"\nGesamt Formulare in Access: {len(all_forms)}")

        print("\n" + "-" * 70)
        print("MOEGLICHE MATCHES:")
        print("-" * 70)

        for html_file, search_terms in SEARCH_TERMS.items():
            print(f"\n{html_file}:")
            matches = []

            for form in all_forms:
                form_lower = form.lower()
                for term in search_terms:
                    if term.lower() in form_lower:
                        matches.append(form)
                        break

            if matches:
                for m in sorted(set(matches))[:10]:  # Max 10 anzeigen
                    print(f"  -> {m}")
            else:
                print("  [!] Keine Matches gefunden")

        # Zeige alle Formulare die mit frm_ beginnen
        print("\n" + "-" * 70)
        print("ALLE frm_ FORMULARE (alphabetisch):")
        print("-" * 70)

        frm_forms = [f for f in all_forms if f.lower().startswith('frm_')]
        for i, f in enumerate(sorted(frm_forms)):
            print(f"  {i+1:3}. {f}")


if __name__ == "__main__":
    main()
