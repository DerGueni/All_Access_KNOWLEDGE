# -*- coding: utf-8 -*-
"""
CCD AUTOPILOT - Vollständiges Audit aller Formulare
Schritt 3-8: Raster, Overlap, Tabs, Vollständigkeit, Funktionalität, Bildschirmgrößen
"""

import os
import re
from pathlib import Path
from datetime import datetime

FORMS_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\02_web\forms"
REPORT_DIR = r"C:\Users\guenther.siegert\Documents\Consys_HTML\_LOOP\reports"

# Klassifizierung
HAUPTFORMULARE = [
    "frm_Abwesenheiten.html", "frm_abwesenheitsuebersicht.html", "frm_Ausweis_Create.html",
    "frm_DP_Dienstplan_MA.html", "frm_DP_Dienstplan_Objekt.html", "frm_Einsatzuebersicht.html",
    "frm_KD_Kundenstamm.html", "frm_MA_Abwesenheit.html", "frm_MA_Mitarbeiterstamm.html",
    "frm_MA_Serien_eMail_Auftrag.html", "frm_MA_Serien_eMail_dienstplan.html",
    "frm_MA_VA_Positionszuordnung.html", "frm_MA_VA_Schnellauswahl.html", "frm_MA_Zeitkonten.html",
    "frm_Menuefuehrung.html", "frm_Menuefuehrung1.html", "frm_N_AuswahlMaster.html",
    "frm_N_Dienstplanuebersicht.html", "frm_N_MA_Bewerber_Verarbeitung.html", "frm_OB_Objekt.html",
    "frm_va_Auftragstamm.html", "frm_VA_Planungsuebersicht.html", "zfrm_Lohnabrechnungen.html",
    "zfrm_Rueckmeldungen.html",
]

UNTERFORMULARE = [
    "sub_DP_Grund.html", "sub_DP_Grund_MA.html", "sub_MA_Offene_Anfragen.html",
    "sub_MA_VA_Planung_Absage.html", "sub_MA_VA_Planung_Status.html", "sub_MA_VA_Zuordnung.html",
    "sub_OB_Objekt_Positionen.html", "sub_rch_Pos.html", "sub_VA_Anzeige.html",
    "sub_VA_Start.html", "sub_ZusatzDateien.html", "zsub_rch_Berechnungsliste.html",
    "zsub_Stundenabgleich.html",
]

def get_form_type(filename):
    if filename in HAUPTFORMULARE:
        return "Hauptformular"
    elif filename in UNTERFORMULARE:
        return "Unterformular"
    elif filename.startswith("frmOff_") or filename.startswith("frmTop_"):
        return "Dialog"
    else:
        return "Spezial"

def audit_form(filepath):
    """Vollständiges Audit eines Formulars"""
    filename = os.path.basename(filepath)
    form_type = get_form_type(filename)

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return {"file": filename, "error": str(e)}

    audit = {
        "file": filename,
        "type": form_type,
        "checks": {},
        "issues": [],
        "warnings": [],
        "pass": True
    }

    # ===== Schritt 1: Shell-Struktur =====
    has_theme_css = "consys_theme.css" in content
    has_app_layout = "app-layout.css" in content
    has_app_header = bool(re.search(r'class="[^"]*app-header', content))
    has_app_footer = bool(re.search(r'class="[^"]*app-footer', content))
    has_app_sidebar = bool(re.search(r'class="[^"]*app-sidebar', content))
    has_subform_container = bool(re.search(r'class="[^"]*subform-container', content))
    has_form_header = bool(re.search(r'class="[^"]*form-header', content))  # Access-Style
    has_form_footer = bool(re.search(r'class="[^"]*form-footer', content))  # Access-Style

    audit["checks"]["theme_css"] = has_theme_css
    audit["checks"]["app_layout_css"] = has_app_layout
    audit["checks"]["has_header"] = has_app_header or has_form_header
    audit["checks"]["has_footer"] = has_app_footer or has_form_footer
    audit["checks"]["has_sidebar"] = has_app_sidebar

    if not has_theme_css:
        audit["issues"].append("Theme CSS fehlt")
        audit["pass"] = False

    if form_type == "Unterformular":
        if has_app_header or has_app_footer:
            audit["issues"].append("Unterformular sollte keine Shell-Elemente haben")
            audit["pass"] = False
        if not has_subform_container and not has_app_layout:
            audit["warnings"].append("Kein subform-container gefunden")

    # ===== Schritt 2: Theme-Farben =====
    wrong_colors = ["#6a5acd", "#5a4abd", "rgb(106, 90, 205)"]
    for color in wrong_colors:
        if color.lower() in content.lower():
            audit["issues"].append(f"Falsche Farbe gefunden: {color}")
            audit["pass"] = False

    # ===== Schritt 3: Raster & Ausrichtung =====
    # Prüfe auf absolute Positionierung (problematisch für responsive)
    absolute_count = len(re.findall(r'position:\s*absolute', content))
    fixed_count = len(re.findall(r'position:\s*fixed', content))

    if absolute_count > 10:
        audit["warnings"].append(f"Viele absolute Positionierungen ({absolute_count}x)")
    if fixed_count > 3:
        audit["warnings"].append(f"Mehrere fixed Positionierungen ({fixed_count}x)")

    # Prüfe auf Flexbox/Grid (positiv)
    has_flex = "display: flex" in content or "display:flex" in content
    has_grid = "display: grid" in content or "display:grid" in content
    audit["checks"]["uses_flex"] = has_flex
    audit["checks"]["uses_grid"] = has_grid

    # ===== Schritt 4: Overlap/Clipping =====
    # Prüfe auf overflow-hidden ohne entsprechende Container
    overflow_hidden = "overflow: hidden" in content or "overflow:hidden" in content
    audit["checks"]["overflow_hidden"] = overflow_hidden

    # Prüfe auf z-index (potenzielle Overlap-Probleme)
    zindex_matches = re.findall(r'z-index:\s*(\d+)', content)
    if zindex_matches:
        max_zindex = max(int(z) for z in zindex_matches)
        if max_zindex > 1000:
            audit["warnings"].append(f"Hoher z-index gefunden ({max_zindex})")

    # ===== Schritt 5: Tabs & Subforms =====
    has_tabs = bool(re.search(r'class="[^"]*tab-', content))
    has_iframes = "<iframe" in content
    iframe_count = content.count("<iframe")

    audit["checks"]["has_tabs"] = has_tabs
    audit["checks"]["has_subforms"] = has_iframes
    audit["checks"]["subform_count"] = iframe_count

    # Prüfe Tab-Struktur
    if has_tabs:
        tab_btns = len(re.findall(r'class="[^"]*tab-btn', content))
        tab_panes = len(re.findall(r'class="[^"]*tab-pane', content))
        if tab_btns != tab_panes:
            audit["warnings"].append(f"Tab-Mismatch: {tab_btns} Buttons vs {tab_panes} Panes")

    # ===== Schritt 6: Inhaltliche Vollständigkeit =====
    # Prüfe auf Platzhalter
    placeholders = [
        "TODO", "FIXME", "XXX", "PLACEHOLDER",
        "Lorem ipsum", "Dummy", "Test-Daten"
    ]
    for ph in placeholders:
        if ph in content:
            audit["warnings"].append(f"Platzhalter gefunden: {ph}")

    # Prüfe auf leere Tabellen
    empty_tbody = re.findall(r'<tbody[^>]*>\s*</tbody>', content)
    if empty_tbody:
        audit["warnings"].append("Leere Tabellen-Body gefunden")

    # ===== Schritt 7: Funktionalität =====
    # Prüfe auf Script-Tags
    has_module_script = 'type="module"' in content
    has_inline_script = "<script>" in content
    has_external_script = re.search(r'<script\s+src=', content)

    audit["checks"]["has_module_script"] = has_module_script
    audit["checks"]["has_inline_script"] = has_inline_script
    audit["checks"]["has_external_script"] = bool(has_external_script)

    # Prüfe auf Event-Handler
    onclick_count = content.count("onclick=")
    onchange_count = content.count("onchange=")
    audit["checks"]["event_handlers"] = onclick_count + onchange_count

    # ===== Schritt 8: Bildschirmgrößen =====
    # Prüfe auf Media Queries (im inline Style oder referenzierten CSS)
    has_media_queries = "@media" in content
    audit["checks"]["has_media_queries"] = has_media_queries

    # Prüfe auf viewport meta tag
    has_viewport = 'name="viewport"' in content
    audit["checks"]["has_viewport"] = has_viewport
    if not has_viewport:
        audit["issues"].append("Viewport Meta-Tag fehlt")
        audit["pass"] = False

    # Prüfe auf feste Pixel-Werte (problematisch)
    fixed_widths = re.findall(r'width:\s*(\d{4,})px', content)
    if fixed_widths:
        audit["warnings"].append(f"Große feste Breiten: {fixed_widths}")

    return audit

def generate_report(audits):
    """Generiert den Batch-Report"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    total = len(audits)
    passed = sum(1 for a in audits if a.get("pass", False))
    failed = total - passed
    with_warnings = sum(1 for a in audits if a.get("warnings"))

    report = []
    report.append("=" * 70)
    report.append("CCD AUTOPILOT - BATCH AUDIT REPORT")
    report.append(f"Erstellt: {timestamp}")
    report.append("=" * 70)
    report.append("")
    report.append("## ZUSAMMENFASSUNG")
    report.append(f"Formulare gesamt:    {total}")
    report.append(f"PASS:                {passed}")
    report.append(f"FAIL:                {failed}")
    report.append(f"Mit Warnungen:       {with_warnings}")
    report.append("")

    # Gruppiert nach Typ
    for form_type in ["Hauptformular", "Unterformular", "Dialog", "Spezial"]:
        type_audits = [a for a in audits if a.get("type") == form_type]
        if not type_audits:
            continue

        report.append("-" * 70)
        report.append(f"## {form_type.upper()}E ({len(type_audits)})")
        report.append("-" * 70)

        for audit in type_audits:
            status = "PASS" if audit.get("pass") else "FAIL"
            report.append(f"\n### {audit['file']} [{status}]")

            if audit.get("issues"):
                report.append("  Probleme:")
                for issue in audit["issues"]:
                    report.append(f"    - {issue}")

            if audit.get("warnings"):
                report.append("  Warnungen:")
                for warning in audit["warnings"]:
                    report.append(f"    - {warning}")

            if not audit.get("issues") and not audit.get("warnings"):
                report.append("  Keine Probleme gefunden")

    report.append("")
    report.append("=" * 70)
    report.append("ENDE DES REPORTS")
    report.append("=" * 70)

    return "\n".join(report)

def main():
    print("=" * 60)
    print("CCD AUTOPILOT - Vollständiges Formular-Audit")
    print("=" * 60)

    # Report-Verzeichnis erstellen
    os.makedirs(REPORT_DIR, exist_ok=True)

    audits = []

    # Alle HTML-Dateien verarbeiten
    html_files = list(Path(FORMS_DIR).glob("*.html"))
    print(f"\nPrüfe {len(html_files)} HTML-Dateien...\n")

    for filepath in sorted(html_files):
        audit = audit_form(str(filepath))
        audits.append(audit)

        status = "PASS" if audit.get("pass", False) else "FAIL"
        warnings = len(audit.get("warnings", []))
        issues = len(audit.get("issues", []))

        indicator = "OK" if status == "PASS" else "XX"
        warning_str = f" ({warnings} Warnungen)" if warnings > 0 else ""
        issue_str = f" ({issues} Probleme)" if issues > 0 else ""

        print(f"  [{indicator}] {audit['file'][:40]:<40} {audit['type']:<15}{issue_str}{warning_str}")

    # Report generieren
    report = generate_report(audits)

    # Report speichern
    report_file = os.path.join(REPORT_DIR, "BATCH_AUDIT_REPORT.txt")
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)

    print("\n" + "=" * 60)
    print("ZUSAMMENFASSUNG")
    print("=" * 60)

    total = len(audits)
    passed = sum(1 for a in audits if a.get("pass", False))
    failed = total - passed

    print(f"Gesamt:  {total}")
    print(f"PASS:    {passed}")
    print(f"FAIL:    {failed}")
    print(f"\nReport gespeichert: {report_file}")

    return audits

if __name__ == "__main__":
    main()
