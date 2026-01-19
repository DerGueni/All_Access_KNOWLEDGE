# -*- coding: utf-8 -*-
"""
Aktualisiert alle HTML-Formulare mit der access-bridge.js
=========================================================
Fuegt das Script-Tag ein falls noch nicht vorhanden
"""

import os
import re

HTML_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\HTML"
BRIDGE_SCRIPT = '<script src="js/access-bridge.js"></script>'

def update_html_file(filepath):
    """Fuegt access-bridge.js zu einer HTML-Datei hinzu"""

    filename = os.path.basename(filepath)

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pruefen ob Bridge bereits eingebunden
    if 'access-bridge.js' in content:
        print(f"  [=] {filename} - Bridge bereits vorhanden")
        return False

    # Suche nach dem letzten </head> oder vor </body>
    # Am besten nach dem letzten <script> im <head> oder vor </head>

    # Strategie 1: Vor </head> einfuegen
    if '</head>' in content:
        # Fuege vor </head> ein
        new_content = content.replace(
            '</head>',
            f'    {BRIDGE_SCRIPT}\n</head>'
        )
        print(f"  [+] {filename} - Bridge vor </head> eingefuegt")

    # Strategie 2: Falls kein </head>, vor erstem <script> im body oder vor </body>
    elif '</body>' in content:
        new_content = content.replace(
            '</body>',
            f'    {BRIDGE_SCRIPT}\n</body>'
        )
        print(f"  [+] {filename} - Bridge vor </body> eingefuegt")

    else:
        print(f"  [!] {filename} - Konnte Bridge nicht einfuegen (keine head/body Tags)")
        return False

    # Datei speichern
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True


def main():
    print("=" * 60)
    print("HTML-FORMULARE MIT ACCESS-BRIDGE AKTUALISIEREN")
    print("=" * 60)
    print(f"Pfad: {HTML_PATH}")
    print(f"Bridge-Script: {BRIDGE_SCRIPT}")
    print("")

    # Pruefen ob Bridge-Datei existiert
    bridge_file = os.path.join(HTML_PATH, "js", "access-bridge.js")
    if not os.path.exists(bridge_file):
        print(f"[!] Bridge-Datei nicht gefunden: {bridge_file}")
        return

    print(f"[OK] Bridge-Datei vorhanden: {bridge_file}")
    print("")

    # Alle HTML-Formulare finden
    html_files = []
    for f in os.listdir(HTML_PATH):
        if f.startswith('frm_') and f.endswith('.html'):
            html_files.append(os.path.join(HTML_PATH, f))

    print(f"Gefundene Formulare: {len(html_files)}")
    print("")

    updated = 0
    skipped = 0

    for filepath in sorted(html_files):
        if update_html_file(filepath):
            updated += 1
        else:
            skipped += 1

    print("")
    print("=" * 60)
    print(f"ERGEBNIS: {updated} aktualisiert, {skipped} uebersprungen")
    print("=" * 60)


if __name__ == "__main__":
    main()
