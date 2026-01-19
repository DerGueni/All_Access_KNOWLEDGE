#!/usr/bin/env python3
"""
Analysiert Access-JSON und extrahiert visuelle Eigenschaften
für Vergleich mit WinUI3-App
"""

import json
import sys

def bgr_to_hex(color_value):
    """Konvertiert Access-Farbe (BGR Long) zu HEX"""
    if color_value is None:
        return None

    # Negative Werte = System-Farben
    system_colors = {
        -2147483633: '#F0F0F0',  # COLOR_BTNFACE
        -2147483643: '#000000',  # COLOR_WINDOWTEXT
        -2147483640: '#FFFFFF',  # COLOR_WINDOW
        -2147483635: '#C0C0C0',  # COLOR_BTNSHADOW
        -2147483632: '#808080',  # COLOR_GRAYTEXT
        -2147483630: '#000000',  # COLOR_BTNTEXT
        -2147483616: '#000000',  # COLOR_INFOTEXT
        -2147483605: '#F0F0F0',  # COLOR_BTNHIGHLIGHT
    }

    if color_value < 0:
        return system_colors.get(color_value, f'SYSTEM({color_value})')

    # Positive Werte: BGR Long zu RGB HEX
    r = color_value & 0xFF
    g = (color_value >> 8) & 0xFF
    b = (color_value >> 16) & 0xFF
    return f'#{r:02X}{g:02X}{b:02X}'

def twips_to_px(twips):
    """Konvertiert Twips zu Pixel"""
    if twips is None:
        return None
    return round(twips / 15, 2)

def analyze_form_properties(json_path):
    """Analysiert Formular-Eigenschaften"""

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Formular-Grundeigenschaften
    form_props = data.get('properties', {})

    print("=" * 80)
    print("ACCESS FORMULAR: frm_MA_Mitarbeiterstamm")
    print("=" * 80)
    print()

    print("FORMULAR-EIGENSCHAFTEN:")
    print(f"  BackColor:    {bgr_to_hex(form_props.get('BackColor'))}")
    print(f"  Width (Twips): {form_props.get('Width')} → {twips_to_px(form_props.get('Width'))} px")
    print(f"  Height (Twips): {form_props.get('InsideHeight')} → {twips_to_px(form_props.get('InsideHeight'))} px")
    print()

    # Wichtige Controls finden
    controls = data.get('controls', [])

    # Sidebar-Bereich (links)
    print("\n" + "=" * 80)
    print("SIDEBAR / NAVIGATION")
    print("=" * 80)

    sidebar_controls = [c for c in controls if
                       c.get('properties', {}).get('Left', 9999) < 1000]

    for ctrl in sidebar_controls[:10]:  # Ersten 10
        props = ctrl.get('properties', {})
        name = props.get('Name', 'N/A')
        ctrl_type = props.get('ControlType', 'N/A')

        if ctrl_type == 104:  # Button
            print(f"\n  Button: {name}")
            print(f"    BackColor: {bgr_to_hex(props.get('BackColor'))}")
            print(f"    ForeColor: {bgr_to_hex(props.get('ForeColor'))}")
            print(f"    Position: ({twips_to_px(props.get('Left'))}, {twips_to_px(props.get('Top'))}) px")
            print(f"    Size: {twips_to_px(props.get('Width'))} x {twips_to_px(props.get('Height'))} px")

    # Haupt-Container/Rechtecke
    print("\n" + "=" * 80)
    print("HINTERGRUND-RECHTECKE")
    print("=" * 80)

    rectangles = [c for c in controls if
                 c.get('properties', {}).get('ControlType') == 106]  # Rectangle

    for rect in rectangles[:10]:
        props = rect.get('properties', {})
        name = props.get('Name', 'N/A')
        print(f"\n  Rechteck: {name}")
        print(f"    BackColor: {bgr_to_hex(props.get('BackColor'))}")
        print(f"    BorderColor: {bgr_to_hex(props.get('BorderColor'))}")
        print(f"    Position: ({twips_to_px(props.get('Left'))}, {twips_to_px(props.get('Top'))}) px")
        print(f"    Size: {twips_to_px(props.get('Width'))} x {twips_to_px(props.get('Height'))} px")

    # Tabs
    print("\n" + "=" * 80)
    print("TAB-CONTROL")
    print("=" * 80)

    tabs = [c for c in controls if
           c.get('properties', {}).get('ControlType') == 123]  # TabControl

    for tab in tabs:
        props = tab.get('properties', {})
        name = props.get('Name', 'N/A')
        print(f"\n  TabControl: {name}")
        print(f"    BackColor: {bgr_to_hex(props.get('BackColor'))}")
        print(f"    Position: ({twips_to_px(props.get('Left'))}, {twips_to_px(props.get('Top'))}) px")
        print(f"    Size: {twips_to_px(props.get('Width'))} x {twips_to_px(props.get('Height'))} px")

    # TextBoxen (Beispiele)
    print("\n" + "=" * 80)
    print("TEXTBOXEN (Beispiele)")
    print("=" * 80)

    textboxes = [c for c in controls if
                c.get('properties', {}).get('ControlType') == 109]  # TextBox

    for tb in textboxes[:5]:
        props = tb.get('properties', {})
        name = props.get('Name', 'N/A')
        print(f"\n  TextBox: {name}")
        print(f"    BackColor: {bgr_to_hex(props.get('BackColor'))}")
        print(f"    ForeColor: {bgr_to_hex(props.get('ForeColor'))}")
        print(f"    BorderColor: {bgr_to_hex(props.get('BorderColor'))}")
        print(f"    FontSize: {props.get('FontSize')}")
        print(f"    Height: {twips_to_px(props.get('Height'))} px")

    # Labels (Beispiele)
    print("\n" + "=" * 80)
    print("LABELS (Beispiele)")
    print("=" * 80)

    labels = [c for c in controls if
             c.get('properties', {}).get('ControlType') == 100]  # Label

    for lbl in labels[:5]:
        props = lbl.get('properties', {})
        name = props.get('Name', 'N/A')
        print(f"\n  Label: {name}")
        print(f"    BackColor: {bgr_to_hex(props.get('BackColor'))}")
        print(f"    ForeColor: {bgr_to_hex(props.get('ForeColor'))}")
        print(f"    FontSize: {props.get('FontSize')}")
        print(f"    FontWeight: {props.get('FontWeight')}")

    print("\n" + "=" * 80)
    print("ANALYSE ABGESCHLOSSEN")
    print("=" * 80)

if __name__ == '__main__':
    json_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export\000_Consys_Eport_11_25\30_forms\FRM_frm_MA_Mitarbeiterstamm.json'

    try:
        analyze_form_properties(json_path)
    except Exception as e:
        print(f"FEHLER: {e}", file=sys.stderr)
        sys.exit(1)
