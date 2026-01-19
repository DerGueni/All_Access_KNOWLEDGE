# -*- coding: utf-8 -*-
"""
Listet alle Formulare in der Access-Datenbank auf
"""

import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

def main():
    with AccessBridge() as bridge:
        forms = bridge.list_forms()
        print(f"\n{'='*60}")
        print(f"FORMULARE IN DER DATENBANK ({len(forms)} gefunden)")
        print(f"{'='*60}")

        # Sortieren
        forms = sorted(forms)

        # Kategorisieren
        frm_forms = [f for f in forms if f.startswith('frm_')]
        sub_forms = [f for f in forms if f.startswith('sub_')]
        other_forms = [f for f in forms if not f.startswith('frm_') and not f.startswith('sub_')]

        print(f"\n--- HAUPTFORMULARE (frm_) [{len(frm_forms)}] ---")
        for f in frm_forms:
            print(f"  {f}")

        print(f"\n--- UNTERFORMULARE (sub_) [{len(sub_forms)}] ---")
        for f in sub_forms:
            print(f"  {f}")

        print(f"\n--- ANDERE [{len(other_forms)}] ---")
        for f in other_forms:
            print(f"  {f}")

if __name__ == "__main__":
    main()
