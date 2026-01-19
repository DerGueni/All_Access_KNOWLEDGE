# -*- coding: utf-8 -*-
"""
Importiert das HTML Ansicht Wechsler Modul in das Access Frontend
"""

import sys
import os

# Access Bridge importieren
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from access_bridge_ultimate import AccessBridge
except ImportError:
    print("[!] access_bridge_ultimate.py nicht gefunden!")
    print("    Bitte sicherstellen, dass die Datei im gleichen Verzeichnis liegt.")
    sys.exit(1)

# Pfad zum VBA-Modul
MODULE_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML\mod_N_HTML_Ansicht_Wechsler.bas"

def main():
    print("=" * 60)
    print("IMPORT: mod_N_HTML_Ansicht_Wechsler")
    print("=" * 60)

    # Pruefen ob Modul-Datei existiert
    if not os.path.exists(MODULE_PATH):
        print(f"[!] Modul-Datei nicht gefunden: {MODULE_PATH}")
        return False

    print(f"[OK] Modul-Datei gefunden: {MODULE_PATH}")

    # VBA-Code laden
    with open(MODULE_PATH, 'r', encoding='utf-8') as f:
        vba_code = f.read()

    # Die ersten Zeilen (Attribute) entfernen falls vorhanden
    lines = vba_code.split('\n')
    clean_lines = []
    skip_attributes = True
    for line in lines:
        if skip_attributes:
            if line.strip().startswith("Attribute") or line.strip() == "":
                continue
            else:
                skip_attributes = False
        clean_lines.append(line)

    vba_code = '\n'.join(clean_lines)

    print(f"[OK] VBA-Code geladen ({len(vba_code)} Zeichen)")

    try:
        with AccessBridge() as bridge:
            print("[OK] Access Bridge verbunden")

            # Pruefen ob Modul bereits existiert
            existing_modules = bridge.list_modules()
            module_name = "mod_N_HTML_Ansicht_Wechsler"

            if module_name in existing_modules:
                print(f"[i] Modul '{module_name}' existiert bereits - wird aktualisiert")

            # Modul importieren (auto_prefix=False da Name bereits _N_ hat)
            result = bridge.import_vba_module(module_name, vba_code, auto_prefix=False)

            if result:
                print(f"[OK] Modul '{module_name}' erfolgreich importiert!")
            else:
                print(f"[!] Fehler beim Import des Moduls")
                return False

            # Liste der Module anzeigen
            print("\n[i] Vorhandene Module:")
            for mod in bridge.list_modules():
                marker = " <-- NEU" if mod == module_name else ""
                print(f"    - {mod}{marker}")

    except Exception as e:
        print(f"[!] Fehler: {e}")
        return False

    print("\n" + "=" * 60)
    print("[OK] IMPORT ABGESCHLOSSEN")
    print("=" * 60)
    print("\nNaechste Schritte:")
    print("1. In Access das Direktfenster oeffnen (Strg+G)")
    print("2. Ausfuehren: HTML_ListeFormulareOhneButton")
    print("   -> Zeigt alle Formulare mit HTML-Version")
    print("3. Fuer jedes Formular:")
    print("   - WebBrowser Control 'ctlHTMLOverlay' hinzufuegen")
    print("   - Button 'HTML Ansicht' mit OnClick: =HTML_Ansicht_Button_Click([Form])")

    return True


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
