#!/usr/bin/env python3
"""
integrate_auto_save.py
Integriert Auto-Save automatisch in bestehende HTML-Formulare

Verwendung:
    python integrate_auto_save.py

Features:
- Fügt CSS-Link in <head> ein
- Fügt Import in Logic-Datei ein
- Fügt Init-Code in init() Funktion ein
- Backup der Originaldateien
- Dry-Run Modus

Erstellt: 2026-01-15
"""

import os
import re
import shutil
from pathlib import Path
from datetime import datetime

# Konfiguration
FORMS_DIR = Path(__file__).parent.parent
LOGIC_DIR = FORMS_DIR / "logic"
HTML_DIR = FORMS_DIR

FORMS = [
    {
        "name": "Auftragstamm",
        "html": "frm_va_Auftragstamm.html",
        "logic": "frm_va_Auftragstamm.logic.js",
        "init_function": "initAutoSaveAuftragstamm"
    },
    {
        "name": "Mitarbeiterstamm",
        "html": "frm_MA_Mitarbeiterstamm.html",
        "logic": "frm_MA_Mitarbeiterstamm.webview2.js",
        "init_function": "initAutoSaveMitarbeiterstamm"
    },
    {
        "name": "Kundenstamm",
        "html": "frm_KD_Kundenstamm.html",
        "logic": "frm_KD_Kundenstamm.logic.js",
        "init_function": "initAutoSaveKundenstamm"
    },
    {
        "name": "Objektverwaltung",
        "html": "frm_OB_Objekt.html",
        "logic": "frm_OB_Objekt.webview2.js",
        "init_function": "initAutoSaveObjekt"
    }
]

DRY_RUN = False  # True = Keine Dateien ändern, nur Ausgabe


def backup_file(file_path):
    """Erstellt Backup der Datei"""
    if not file_path.exists():
        return None

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = file_path.with_suffix(f".{timestamp}.backup")
    shutil.copy2(file_path, backup_path)
    return backup_path


def add_css_to_html(html_path):
    """Fügt CSS-Link in <head> ein"""
    if not html_path.exists():
        print(f"  ❌ HTML nicht gefunden: {html_path}")
        return False

    content = html_path.read_text(encoding="utf-8")

    # Prüfen ob bereits vorhanden
    if "auto-save.css" in content:
        print(f"  ℹ️  CSS bereits eingebunden")
        return True

    # CSS-Link erstellen
    css_link = '    <link rel="stylesheet" href="../css/auto-save.css">'

    # Nach letztem <link> oder vor </head> einfügen
    if "<link" in content:
        # Nach letztem <link> einfügen
        content = re.sub(
            r'(<link[^>]*>)(\s*)',
            r'\1\n' + css_link + r'\2',
            content,
            count=1,
            flags=re.IGNORECASE
        )
    else:
        # Vor </head> einfügen
        content = content.replace("</head>", f"{css_link}\n</head>")

    if not DRY_RUN:
        html_path.write_text(content, encoding="utf-8")

    print(f"  ✅ CSS-Link eingefügt")
    return True


def add_import_to_logic(logic_path, init_function):
    """Fügt Import in Logic-Datei ein"""
    if not logic_path.exists():
        print(f"  ❌ Logic-Datei nicht gefunden: {logic_path}")
        return False

    content = logic_path.read_text(encoding="utf-8")

    # Prüfen ob bereits vorhanden
    if "auto-save-integration" in content:
        print(f"  ℹ️  Import bereits vorhanden")
        return True

    # Import-Statement erstellen
    import_statement = f"import {{ {init_function}, injectAutoSaveStatus }} from '../js/auto-save-integration.js';"

    # Nach letztem Import einfügen
    if "import " in content:
        # Nach letztem Import einfügen
        lines = content.split('\n')
        last_import_idx = -1

        for i, line in enumerate(lines):
            if line.strip().startswith('import '):
                last_import_idx = i

        if last_import_idx >= 0:
            lines.insert(last_import_idx + 1, import_statement)
            content = '\n'.join(lines)
    else:
        # Am Anfang der Datei einfügen
        content = import_statement + '\n\n' + content

    if not DRY_RUN:
        logic_path.write_text(content, encoding="utf-8")

    print(f"  ✅ Import eingefügt")
    return True


def add_init_to_logic(logic_path, init_function):
    """Fügt Init-Code in init() Funktion ein"""
    if not logic_path.exists():
        return False

    content = logic_path.read_text(encoding="utf-8")

    # Prüfen ob bereits vorhanden
    if init_function in content:
        print(f"  ℹ️  Init-Code bereits vorhanden")
        return True

    # Init-Code erstellen
    init_code = f"""
    // Auto-Save aktivieren
    injectAutoSaveStatus();
    state.autoSave = {init_function}(state);
    console.log('[{init_function.replace("initAutoSave", "")}] Auto-Save aktiviert');
"""

    # init() Funktion finden
    init_match = re.search(
        r'(async\s+)?function\s+init\s*\(\s*\)\s*\{',
        content,
        re.IGNORECASE
    )

    if not init_match:
        print(f"  ❌ init() Funktion nicht gefunden")
        return False

    # Nach der öffnenden { der init() Funktion einfügen
    insert_pos = init_match.end()
    content = content[:insert_pos] + init_code + content[insert_pos:]

    if not DRY_RUN:
        logic_path.write_text(content, encoding="utf-8")

    print(f"  ✅ Init-Code eingefügt")
    return True


def integrate_form(form_config):
    """Integriert Auto-Save in ein Formular"""
    print(f"\n📝 {form_config['name']}")

    html_path = HTML_DIR / form_config["html"]
    logic_path = LOGIC_DIR / form_config["logic"]

    # Backups erstellen
    if not DRY_RUN:
        html_backup = backup_file(html_path)
        logic_backup = backup_file(logic_path)

        if html_backup:
            print(f"  💾 HTML Backup: {html_backup.name}")
        if logic_backup:
            print(f"  💾 Logic Backup: {logic_backup.name}")

    # CSS in HTML einfügen
    add_css_to_html(html_path)

    # Import in Logic einfügen
    add_import_to_logic(logic_path, form_config["init_function"])

    # Init-Code in Logic einfügen
    add_init_to_logic(logic_path, form_config["init_function"])


def main():
    print("=" * 60)
    print("Auto-Save Integration")
    print("=" * 60)

    if DRY_RUN:
        print("\n⚠️  DRY-RUN MODUS - Keine Dateien werden geändert\n")

    # Prüfen ob Verzeichnisse existieren
    if not LOGIC_DIR.exists():
        print(f"❌ Logic-Verzeichnis nicht gefunden: {LOGIC_DIR}")
        return

    # Formulare integrieren
    for form_config in FORMS:
        try:
            integrate_form(form_config)
        except Exception as e:
            print(f"  ❌ Fehler: {e}")

    print("\n" + "=" * 60)
    print("✅ Integration abgeschlossen")
    print("=" * 60)

    if not DRY_RUN:
        print("\n💡 Nächste Schritte:")
        print("   1. Formulare im Browser testen")
        print("   2. Console-Logs überprüfen")
        print("   3. Status-Anzeige überprüfen")
        print("   4. Speichern testen")
        print("\n⚠️  Bei Problemen: Backups wiederherstellen (.backup Dateien)")


if __name__ == "__main__":
    main()
