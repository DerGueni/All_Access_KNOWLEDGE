# -*- coding: utf-8 -*-
"""
CCD AUTOPILOT - Schritt 1 & 2: Shell-Struktur und Theme
Korrigiert alle HTML-Formulare für Variante B
"""

import os
import re
from pathlib import Path

FORMS_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\forms"
THEME_CSS = "../theme/consys_theme.css"

# Klassifizierung der Formulare
HAUPTFORMULARE = [
    "frm_Abwesenheiten.html",
    "frm_abwesenheitsuebersicht.html",
    "frm_Ausweis_Create.html",
    "frm_DP_Dienstplan_MA.html",
    "frm_DP_Dienstplan_Objekt.html",
    "frm_Einsatzuebersicht.html",
    "frm_KD_Kundenstamm.html",
    "frm_MA_Abwesenheit.html",
    "frm_MA_Mitarbeiterstamm.html",
    "frm_MA_Serien_eMail_Auftrag.html",
    "frm_MA_Serien_eMail_dienstplan.html",
    "frm_MA_VA_Positionszuordnung.html",
    "frm_MA_VA_Schnellauswahl.html",
    "frm_MA_Zeitkonten.html",
    "frm_Menuefuehrung.html",
    "frm_Menuefuehrung1.html",
    "frm_N_AuswahlMaster.html",
    "frm_N_Dienstplanuebersicht.html",
    "frm_N_MA_Bewerber_Verarbeitung.html",
    "frm_OB_Objekt.html",
    "frm_va_Auftragstamm.html",
    "frm_VA_Planungsuebersicht.html",
    "zfrm_Lohnabrechnungen.html",
    "zfrm_Rueckmeldungen.html",
]

UNTERFORMULARE = [
    "sub_DP_Grund.html",
    "sub_DP_Grund_MA.html",
    "sub_MA_Offene_Anfragen.html",
    "sub_MA_VA_Planung_Absage.html",
    "sub_MA_VA_Planung_Status.html",
    "sub_MA_VA_Zuordnung.html",
    "sub_OB_Objekt_Positionen.html",
    "sub_rch_Pos.html",
    "sub_VA_Anzeige.html",
    "sub_VA_Start.html",
    "sub_ZusatzDateien.html",
    "zsub_rch_Berechnungsliste.html",
    "zsub_Stundenabgleich.html",
]

DIALOGE = [
    "frmOff_Outlook_aufrufen.html",
    "frmTop_DP_Auftragseingabe.html",
    "frmTop_DP_MA_Auftrag_Zuo.html",
    "frmTop_Geo_Verwaltung.html",
]

SPEZIAL = [
    "index.html",
    "frm_lst_row_auftrag.html",
    "frm_va_AuftragstammALT.html",
    "zfrm_MA_Stunden_Lexware.html",
    "zsub_ZK_Importfehler.html",
]

def add_theme_link(content):
    """Fügt consys_theme.css Link hinzu falls nicht vorhanden"""
    if "consys_theme.css" in content:
        return content, False

    # Nach app-layout.css suchen und danach einfügen
    pattern = r'(<link[^>]*app-layout\.css[^>]*>)'
    match = re.search(pattern, content)
    if match:
        insert_pos = match.end()
        theme_link = f'\n    <link rel="stylesheet" href="{THEME_CSS}">'
        content = content[:insert_pos] + theme_link + content[insert_pos:]
        return content, True

    # Alternativ: Nach </head> suchen
    pattern = r'(</head>)'
    match = re.search(pattern, content, re.IGNORECASE)
    if match:
        theme_link = f'    <link rel="stylesheet" href="{THEME_CSS}">\n'
        content = content[:match.start()] + theme_link + content[match.start():]
        return content, True

    return content, False

def remove_inline_header_colors(content):
    """Entfernt inline Header/Footer Farbdefinitionen"""
    changes = []

    # Lila/andere Header-Farben entfernen
    patterns = [
        (r'\.app-header\s*\{[^}]*background:\s*linear-gradient[^}]*#6a5acd[^}]*\}',
         '.app-header { /* Theme übernimmt Farben */ }'),
        (r':root\s*\{[^}]*--accent-color:\s*#6a5acd[^}]*\}',
         ':root { /* Farben aus consys_theme.css */ }'),
        # Detail-Panel mit lila Hintergrund
        (r'style="[^"]*background:\s*#6a5acd[^"]*"',
         'style="background: var(--consys-primary);"'),
    ]

    for pattern, replacement in patterns:
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            changes.append(f"Inline-Farbe ersetzt")

    return content, changes

def check_shell_structure(content, form_type):
    """Prüft Shell-Struktur (Header/Footer/Sidebar)"""
    has_header = bool(re.search(r'<header[^>]*class="[^"]*app-header', content))
    has_footer = bool(re.search(r'<footer[^>]*class="[^"]*app-footer', content))
    has_sidebar = bool(re.search(r'<aside[^>]*class="[^"]*app-sidebar', content))
    has_subform = bool(re.search(r'class="[^"]*subform-container', content))

    issues = []

    if form_type == "haupt":
        if not has_header:
            issues.append("FEHLT: Header")
        if not has_footer:
            issues.append("FEHLT: Footer")
        # Sidebar optional aber empfohlen
    elif form_type == "unter":
        if has_header:
            issues.append("ENTFERNEN: Header nicht erlaubt")
        if has_footer:
            issues.append("ENTFERNEN: Footer nicht erlaubt")
        if has_sidebar:
            issues.append("ENTFERNEN: Sidebar nicht erlaubt")
        if not has_subform:
            issues.append("FEHLT: subform-container")
    elif form_type == "dialog":
        # Dialoge haben eigenen Header, kein Footer
        pass

    return {
        "has_header": has_header,
        "has_footer": has_footer,
        "has_sidebar": has_sidebar,
        "has_subform": has_subform,
        "issues": issues
    }

def process_hauptformular(filepath):
    """Verarbeitet ein Hauptformular"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changes = []
    original = content

    # 1. Theme hinzufügen
    content, added = add_theme_link(content)
    if added:
        changes.append("Theme-CSS hinzugefügt")

    # 2. Inline-Farben korrigieren
    content, color_changes = remove_inline_header_colors(content)
    changes.extend(color_changes)

    # 3. Shell prüfen
    shell = check_shell_structure(content, "haupt")

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    return {
        "file": os.path.basename(filepath),
        "type": "Hauptformular",
        "changes": changes,
        "shell": shell,
        "modified": content != original
    }

def process_unterformular(filepath):
    """Verarbeitet ein Unterformular"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changes = []
    original = content

    # Theme für Basis-Styles hinzufügen
    content, added = add_theme_link(content)
    if added:
        changes.append("Theme-CSS hinzugefügt")

    # Shell prüfen
    shell = check_shell_structure(content, "unter")

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    return {
        "file": os.path.basename(filepath),
        "type": "Unterformular",
        "changes": changes,
        "shell": shell,
        "modified": content != original
    }

def process_dialog(filepath):
    """Verarbeitet einen Dialog"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changes = []
    original = content

    content, added = add_theme_link(content)
    if added:
        changes.append("Theme-CSS hinzugefügt")

    shell = check_shell_structure(content, "dialog")

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    return {
        "file": os.path.basename(filepath),
        "type": "Dialog",
        "changes": changes,
        "shell": shell,
        "modified": content != original
    }

def process_spezial(filepath):
    """Verarbeitet Spezialformulare"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changes = []
    original = content

    content, added = add_theme_link(content)
    if added:
        changes.append("Theme-CSS hinzugefügt")

    content, color_changes = remove_inline_header_colors(content)
    changes.extend(color_changes)

    shell = check_shell_structure(content, "haupt")  # Spezial behandeln wie Haupt

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

    return {
        "file": os.path.basename(filepath),
        "type": "Spezial",
        "changes": changes,
        "shell": shell,
        "modified": content != original
    }

def main():
    results = {
        "hauptformulare": [],
        "unterformulare": [],
        "dialoge": [],
        "spezial": [],
        "not_found": [],
        "summary": {
            "total": 0,
            "modified": 0,
            "issues": 0
        }
    }

    print("=" * 60)
    print("CCD AUTOPILOT - Shell & Theme Korrektur")
    print("=" * 60)

    # Hauptformulare
    print("\n[1/4] Hauptformulare...")
    for filename in HAUPTFORMULARE:
        filepath = os.path.join(FORMS_DIR, filename)
        if os.path.exists(filepath):
            result = process_hauptformular(filepath)
            results["hauptformulare"].append(result)
            results["summary"]["total"] += 1
            if result["modified"]:
                results["summary"]["modified"] += 1
            if result["shell"]["issues"]:
                results["summary"]["issues"] += 1
            print(f"  {'[M]' if result['modified'] else '[ ]'} {filename}")
        else:
            results["not_found"].append(filename)
            print(f"  [!] {filename} - NICHT GEFUNDEN")

    # Unterformulare
    print("\n[2/4] Unterformulare...")
    for filename in UNTERFORMULARE:
        filepath = os.path.join(FORMS_DIR, filename)
        if os.path.exists(filepath):
            result = process_unterformular(filepath)
            results["unterformulare"].append(result)
            results["summary"]["total"] += 1
            if result["modified"]:
                results["summary"]["modified"] += 1
            if result["shell"]["issues"]:
                results["summary"]["issues"] += 1
            print(f"  {'[M]' if result['modified'] else '[ ]'} {filename}")
        else:
            results["not_found"].append(filename)
            print(f"  [!] {filename} - NICHT GEFUNDEN")

    # Dialoge
    print("\n[3/4] Dialoge...")
    for filename in DIALOGE:
        filepath = os.path.join(FORMS_DIR, filename)
        if os.path.exists(filepath):
            result = process_dialog(filepath)
            results["dialoge"].append(result)
            results["summary"]["total"] += 1
            if result["modified"]:
                results["summary"]["modified"] += 1
            print(f"  {'[M]' if result['modified'] else '[ ]'} {filename}")
        else:
            results["not_found"].append(filename)
            print(f"  [!] {filename} - NICHT GEFUNDEN")

    # Spezial
    print("\n[4/4] Spezial...")
    for filename in SPEZIAL:
        filepath = os.path.join(FORMS_DIR, filename)
        if os.path.exists(filepath):
            result = process_spezial(filepath)
            results["spezial"].append(result)
            results["summary"]["total"] += 1
            if result["modified"]:
                results["summary"]["modified"] += 1
            print(f"  {'[M]' if result['modified'] else '[ ]'} {filename}")
        else:
            results["not_found"].append(filename)
            print(f"  [!] {filename} - NICHT GEFUNDEN")

    # Zusammenfassung
    print("\n" + "=" * 60)
    print("ZUSAMMENFASSUNG")
    print("=" * 60)
    print(f"Gesamt geprüft:    {results['summary']['total']}")
    print(f"Modifiziert:       {results['summary']['modified']}")
    print(f"Mit Problemen:     {results['summary']['issues']}")
    print(f"Nicht gefunden:    {len(results['not_found'])}")

    # Shell-Probleme auflisten
    print("\n" + "-" * 60)
    print("SHELL-STRUKTUR PROBLEME:")
    print("-" * 60)

    all_results = results["hauptformulare"] + results["unterformulare"] + results["dialoge"] + results["spezial"]
    for r in all_results:
        if r["shell"]["issues"]:
            print(f"\n{r['file']} ({r['type']}):")
            for issue in r["shell"]["issues"]:
                print(f"  - {issue}")

    if not any(r["shell"]["issues"] for r in all_results):
        print("  Keine Probleme gefunden!")

    return results

if __name__ == "__main__":
    main()
