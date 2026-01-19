#!/usr/bin/env python3
"""
Install WebView2 Shell - Importiert VBA-Modul und aktualisiert Buttons
"""

import sys
import os

# Access Bridge Pfad hinzufuegen
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridge

MODULE_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\vba\mod_N_WebView2_Shell.bas"

def main():
    print("=" * 70)
    print("WEBVIEW2 SHELL INSTALLATION")
    print("=" * 70)
    print()

    try:
        with AccessBridge() as bridge:
            print("Access Bridge verbunden.\n")

            # 1. VBA-Modul importieren
            print("Importiere VBA-Modul: mod_N_WebView2_Shell...")

            # Modul-Code lesen
            with open(MODULE_PATH, 'r', encoding='utf-8') as f:
                module_code = f.read()

            # Attribute-Zeile entfernen (wird von Access automatisch gesetzt)
            lines = module_code.split('\n')
            filtered_lines = [l for l in lines if not l.startswith('Attribute VB_Name')]
            module_code = '\n'.join(filtered_lines)

            result = bridge.import_vba_module("WebView2_Shell", module_code, auto_prefix=True)
            print(f"  -> {result}")
            print()

            # 2. Liste der Module anzeigen
            print("Verfuegbare Module:")
            modules = bridge.list_modules()
            for m in modules:
                if "WebView2" in m or "HTML" in m:
                    print(f"  - {m}")
            print()

            # 3. Formulare auflisten die aktualisiert werden koennten
            print("Formulare mit moeglichen HTML-Buttons:")
            forms = bridge.list_forms()
            target_forms = ["frm_va_Auftragstamm", "frm_MA_Mitarbeiterstamm", "frm_KD_Kundenstamm"]
            for f in forms:
                if any(t in f for t in target_forms):
                    print(f"  - {f}")
            print()

            print("=" * 70)
            print("VBA-MODUL IMPORTIERT!")
            print("=" * 70)
            print()
            print("Naechste Schritte (manuell in Access):")
            print()
            print("1. Oeffne frm_va_Auftragstamm im Entwurfsmodus")
            print("2. Waehle den 'HTML Ansicht' Button")
            print("3. Setze 'Bei Klick' auf: =OpenShell_Auftragstamm([ID])")
            print()
            print("Oder fuer andere Formulare:")
            print("  - Mitarbeiter: =OpenShell_Mitarbeiterstamm([ID])")
            print("  - Kunden:      =OpenShell_Kundenstamm([kun_Id])")
            print("  - Objekte:     =OpenShell_Objekt([ID])")
            print()

    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
