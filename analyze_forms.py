"""
Analysiert Access-JSON-Export-Dateien und erstellt Übersicht der Formular-Dimensionen
"""
import json
import os
from typing import Dict, List, Any

# Twips zu Pixel Konvertierung
def twips_to_px(twips) -> float:
    """Konvertiert Twips zu Pixel (1px = 15 Twips)"""
    if twips is None or twips == "":
        return 0
    # Konvertiere zu int falls String
    try:
        twips = int(twips) if isinstance(twips, str) else twips
        return round(twips / 15, 2)
    except (ValueError, TypeError):
        return 0

def analyze_form(json_path: str) -> Dict[str, Any]:
    """
    Analysiert eine JSON-Formular-Datei und extrahiert Dimensionen
    """
    print(f"Analysiere: {os.path.basename(json_path)}")

    # Versuche verschiedene Encodings
    encodings = ['latin-1', 'iso-8859-1', 'cp1252', 'utf-8']
    data = None
    used_encoding = None

    for enc in encodings:
        try:
            with open(json_path, 'r', encoding=enc) as f:
                content = f.read()

                # Bereinige deutsche Boolean-Werte
                content = content.replace(':wahr', ':true')
                content = content.replace(':falsch', ':false')
                content = content.replace(':"Wahr"', ':true')
                content = content.replace(':"Falsch"', ':false')

                # Versuche JSON zu parsen
                data = json.loads(content)
            used_encoding = enc
            print(f"  Encoding: {enc} (Dateigroesse: {len(content)} Zeichen)")
            break
        except (UnicodeDecodeError, json.JSONDecodeError) as e:
            print(f"  {enc} fehlgeschlagen: {type(e).__name__}")
            continue

    if data is None:
        raise Exception(f"Konnte Datei nicht lesen mit keinem Encoding")

    # Extrahiere Formular-Eigenschaften
    props = data.get('properties', {})
    form_name = data.get('name', 'Unknown')

    # Formular-Dimensionen (oft nicht direkt gespeichert in Access)
    form_width_twips = props.get('Width', 0)
    form_height_twips = props.get('InsideHeight', 0) or props.get('Height', 0)

    form_info = {
        'name': form_name,
        'width_twips': form_width_twips,
        'height_twips': form_height_twips,
        'width_px': twips_to_px(form_width_twips),
        'height_px': twips_to_px(form_height_twips),
        'controls': [],
        'max_right_px': 0,
        'max_bottom_px': 0
    }

    # Extrahiere Controls
    controls = data.get('controls', [])

    for ctrl in controls:
        ctrl_props = ctrl.get('properties', {})
        ctrl_name = ctrl.get('name', 'Unknown')
        ctrl_type = ctrl.get('type', 'Unknown')

        left_twips = ctrl_props.get('Left', 0)
        top_twips = ctrl_props.get('Top', 0)
        width_twips = ctrl_props.get('Width', 0)
        height_twips = ctrl_props.get('Height', 0)

        visible = ctrl_props.get('Visible', True)

        left_px = twips_to_px(left_twips)
        top_px = twips_to_px(top_twips)
        width_px = twips_to_px(width_twips)
        height_px = twips_to_px(height_twips)

        # Berechne rechte und untere Kante
        right_px = left_px + width_px
        bottom_px = top_px + height_px

        # Aktualisiere maximale Dimensionen
        form_info['max_right_px'] = max(form_info['max_right_px'], right_px)
        form_info['max_bottom_px'] = max(form_info['max_bottom_px'], bottom_px)

        ctrl_info = {
            'name': ctrl_name,
            'type': ctrl_type,
            'left_twips': left_twips,
            'top_twips': top_twips,
            'width_twips': width_twips,
            'height_twips': height_twips,
            'left_px': left_px,
            'top_px': top_px,
            'width_px': width_px,
            'height_px': height_px,
            'visible': visible
        }

        form_info['controls'].append(ctrl_info)

    print(f"  Gefunden: {len(controls)} Controls")
    return form_info

def create_markdown_report(forms_data: List[Dict[str, Any]], output_path: str):
    """
    Erstellt einen Markdown-Bericht mit allen Formular-Dimensionen
    """

    md_content = [
        "# Access Formular Control Mapping",
        "",
        "Übersicht aller Controls und ihrer Dimensionen (Twips → Pixel Konvertierung)",
        "",
        "**Konvertierungsregel:** 1 Pixel = 15 Twips",
        "",
        "---",
        ""
    ]

    for form in forms_data:
        md_content.append(f"## {form['name']}")
        md_content.append("")
        md_content.append(f"**Formular-Dimensionen:**")

        if form['width_px'] > 0 and form['height_px'] > 0:
            md_content.append(f"- Breite: {form['width_twips']} Twips = **{form['width_px']} px**")
            md_content.append(f"- Höhe: {form['height_twips']} Twips = **{form['height_px']} px**")
        else:
            md_content.append(f"- *Formular-Dimensionen nicht direkt gespeichert*")
            md_content.append(f"- **Berechnete Breite (max Control-Rechts):** {form['max_right_px']} px")
            md_content.append(f"- **Berechnete Höhe (max Control-Unten):** {form['max_bottom_px']} px")

        md_content.append(f"- Anzahl Controls: **{len(form['controls'])}**")
        md_content.append("")

        # Controls Tabelle
        md_content.append("### Controls")
        md_content.append("")
        md_content.append("| Name | Type | Left (px) | Top (px) | Width (px) | Height (px) | Visible |")
        md_content.append("|------|------|-----------|----------|------------|-------------|---------|")

        # Sortiere Controls nach Top, dann Left
        sorted_controls = sorted(form['controls'], key=lambda c: (c['top_px'], c['left_px']))

        for ctrl in sorted_controls:
            visible_marker = "YES" if ctrl['visible'] else "NO"
            md_content.append(
                f"| {ctrl['name']} | {ctrl['type']} | "
                f"{ctrl['left_px']} | {ctrl['top_px']} | "
                f"{ctrl['width_px']} | {ctrl['height_px']} | {visible_marker} |"
            )

        md_content.append("")
        md_content.append("---")
        md_content.append("")

    # Zusammenfassung
    md_content.append("## Zusammenfassung")
    md_content.append("")
    md_content.append("| Formular | Berechnete Breite (px) | Berechnete Höhe (px) | Anzahl Controls |")
    md_content.append("|----------|------------------------|----------------------|-----------------|")

    for form in forms_data:
        width = form['width_px'] if form['width_px'] > 0 else form['max_right_px']
        height = form['height_px'] if form['height_px'] > 0 else form['max_bottom_px']
        md_content.append(
            f"| {form['name']} | {width} | {height} | {len(form['controls'])} |"
        )

    md_content.append("")

    # Control-Typen Statistik
    md_content.append("## Control-Typen Übersicht")
    md_content.append("")
    md_content.append("Verteilung der Control-Typen über alle Formulare:")
    md_content.append("")

    # Sammle alle Control-Typen
    type_counts = {}
    for form in forms_data:
        for ctrl in form['controls']:
            ctrl_type = ctrl['type']
            type_counts[ctrl_type] = type_counts.get(ctrl_type, 0) + 1

    # Sortiere nach Häufigkeit
    sorted_types = sorted(type_counts.items(), key=lambda x: x[1], reverse=True)

    md_content.append("| Control-Typ | Anzahl | Prozent |")
    md_content.append("|-------------|--------|---------|")

    total_controls = sum(type_counts.values())

    for ctrl_type, count in sorted_types:
        percent = (count / total_controls * 100) if total_controls > 0 else 0
        md_content.append(f"| {ctrl_type} | {count} | {percent:.1f}% |")

    md_content.append("")
    md_content.append(f"**Gesamt:** {total_controls} Controls")

    md_content.append("")
    md_content.append("---")
    md_content.append("")
    md_content.append(f"*Generiert: {__file__}*")

    # Schreibe Datei
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md_content))

    print(f"\n[OK] Bericht erstellt: {output_path}")

def main():
    base_path = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export\000_Consys_Eport_11_25\30_forms"

    forms_to_analyze = [
        "FRM_frm_MA_Mitarbeiterstamm.json",
        "FRM_frm_KD_Kundenstamm.json",
        "FRM_frm_VA_Auftragstamm.json",
        "FRM_frm_DP_Dienstplan_MA.json",
        "FRM_frm_OB_Objekt.json"
    ]

    forms_data = []

    for form_file in forms_to_analyze:
        json_path = os.path.join(base_path, form_file)

        if os.path.exists(json_path):
            try:
                form_info = analyze_form(json_path)
                forms_data.append(form_info)
            except Exception as e:
                print(f"  [FEHLER] bei {form_file}: {e}")
        else:
            print(f"  [FEHLER] Nicht gefunden: {form_file}")

    # Erstelle Bericht
    output_path = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\WINUI3_ACCESS_CONTROL_MAPPING.md"
    create_markdown_report(forms_data, output_path)

    print(f"\n[OK] Analyse abgeschlossen: {len(forms_data)} Formulare")

if __name__ == "__main__":
    main()
