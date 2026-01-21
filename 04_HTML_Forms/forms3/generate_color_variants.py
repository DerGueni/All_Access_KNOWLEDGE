# -*- coding: utf-8 -*-
"""
Erstellt 8 Farbvarianten des Auftragsformulars
"""

import os
import re

# Quellpfad
base_path = os.path.dirname(os.path.abspath(__file__))
source_file = os.path.join(base_path, "frm_va_Auftragstamm.html")

# Farb-Varianten mit Verlaeufen
variants = [
    {
        "name": "Variante1_Lila_Blau",
        "title": "Variante 1: Lila - Blau",
        "body_bg": "linear-gradient(135deg, #8060a0 0%, #4060a0 100%)",
        "frame_bg": "linear-gradient(135deg, #8060a0 0%, #4060a0 100%)",
        "left_menu_bg": "linear-gradient(180deg, #6040a0 0%, #3050a0 100%)",
        "menu_header_bg": "linear-gradient(90deg, #5030a0 0%, #2040a0 100%)",
        "button_row_bg": "linear-gradient(135deg, #9080c0 0%, #6080c0 100%)",
        "logo_gradient": "linear-gradient(135deg, #6040a0, #4060c0)",
        "title_color": "#3030a0",
        "accent": "#4050a0",
    },
    {
        "name": "Variante2_Blau_Hellblau",
        "title": "Variante 2: Blau - Hellblau",
        "body_bg": "linear-gradient(135deg, #2060a0 0%, #60a0d0 100%)",
        "frame_bg": "linear-gradient(135deg, #2060a0 0%, #60a0d0 100%)",
        "left_menu_bg": "linear-gradient(180deg, #1050a0 0%, #4090c0 100%)",
        "menu_header_bg": "linear-gradient(90deg, #003080 0%, #2070a0 100%)",
        "button_row_bg": "linear-gradient(135deg, #4080c0 0%, #80b0e0 100%)",
        "logo_gradient": "linear-gradient(135deg, #1050a0, #60a0d0)",
        "title_color": "#1050a0",
        "accent": "#2070b0",
    },
    {
        "name": "Variante3_Bordeaux_Weiss",
        "title": "Variante 3: Bordeaux - Weiss",
        "body_bg": "linear-gradient(135deg, #8b2942 0%, #e8d8d8 100%)",
        "frame_bg": "linear-gradient(135deg, #8b2942 0%, #e8d8d8 100%)",
        "left_menu_bg": "linear-gradient(180deg, #6b1932 0%, #c0a0a0 100%)",
        "menu_header_bg": "linear-gradient(90deg, #5a1428 0%, #803040 100%)",
        "button_row_bg": "linear-gradient(135deg, #a04050 0%, #d8c0c0 100%)",
        "logo_gradient": "linear-gradient(135deg, #6b1932, #a04050)",
        "title_color": "#6b1932",
        "accent": "#8b2942",
    },
    {
        "name": "Variante4_Grau_Weiss",
        "title": "Variante 4: Grau - Weiss",
        "body_bg": "linear-gradient(135deg, #606060 0%, #e8e8e8 100%)",
        "frame_bg": "linear-gradient(135deg, #606060 0%, #e8e8e8 100%)",
        "left_menu_bg": "linear-gradient(180deg, #505050 0%, #c0c0c0 100%)",
        "menu_header_bg": "linear-gradient(90deg, #404040 0%, #606060 100%)",
        "button_row_bg": "linear-gradient(135deg, #808080 0%, #d0d0d0 100%)",
        "logo_gradient": "linear-gradient(135deg, #505050, #808080)",
        "title_color": "#404040",
        "accent": "#505050",
    },
    {
        "name": "Variante5_Blau_Weiss",
        "title": "Variante 5: Blau - Weiss",
        "body_bg": "linear-gradient(135deg, #2050a0 0%, #e0e8f0 100%)",
        "frame_bg": "linear-gradient(135deg, #2050a0 0%, #e0e8f0 100%)",
        "left_menu_bg": "linear-gradient(180deg, #104090 0%, #b0c0d8 100%)",
        "menu_header_bg": "linear-gradient(90deg, #002080 0%, #1040a0 100%)",
        "button_row_bg": "linear-gradient(135deg, #4070b0 0%, #c8d8e8 100%)",
        "logo_gradient": "linear-gradient(135deg, #104090, #4070b0)",
        "title_color": "#104090",
        "accent": "#2050a0",
    },
    {
        "name": "Variante6_Gruen_Weiss",
        "title": "Variante 6: Gruen - Weiss",
        "body_bg": "linear-gradient(135deg, #206040 0%, #d8e8d8 100%)",
        "frame_bg": "linear-gradient(135deg, #206040 0%, #d8e8d8 100%)",
        "left_menu_bg": "linear-gradient(180deg, #105030 0%, #a0c0a0 100%)",
        "menu_header_bg": "linear-gradient(90deg, #004020 0%, #206040 100%)",
        "button_row_bg": "linear-gradient(135deg, #408060 0%, #c0d8c0 100%)",
        "logo_gradient": "linear-gradient(135deg, #105030, #408060)",
        "title_color": "#105030",
        "accent": "#206040",
    },
    {
        "name": "Variante7_Orange_Gelb",
        "title": "Variante 7: Orange - Gelb",
        "body_bg": "linear-gradient(135deg, #d06020 0%, #f0d060 100%)",
        "frame_bg": "linear-gradient(135deg, #d06020 0%, #f0d060 100%)",
        "left_menu_bg": "linear-gradient(180deg, #c05010 0%, #e0b040 100%)",
        "menu_header_bg": "linear-gradient(90deg, #a04000 0%, #c06020 100%)",
        "button_row_bg": "linear-gradient(135deg, #e08040 0%, #f0d080 100%)",
        "logo_gradient": "linear-gradient(135deg, #c05010, #e08040)",
        "title_color": "#a04000",
        "accent": "#c06020",
    },
    {
        "name": "Variante8_Dunkelblau_Tuerkis",
        "title": "Variante 8: Dunkelblau - Tuerkis",
        "body_bg": "linear-gradient(135deg, #102040 0%, #40a0a0 100%)",
        "frame_bg": "linear-gradient(135deg, #102040 0%, #40a0a0 100%)",
        "left_menu_bg": "linear-gradient(180deg, #081830 0%, #308080 100%)",
        "menu_header_bg": "linear-gradient(90deg, #001020 0%, #103050 100%)",
        "button_row_bg": "linear-gradient(135deg, #204060 0%, #60b0b0 100%)",
        "logo_gradient": "linear-gradient(135deg, #081830, #40a0a0)",
        "title_color": "#103050",
        "accent": "#204060",
    },
]

# Quelle lesen
with open(source_file, 'r', encoding='utf-8') as f:
    source_html = f.read()

print("Erstelle 8 Farbvarianten...")

for variant in variants:
    # HTML kopieren
    html = source_html

    # Titel aendern
    html = html.replace('<title style="position: relative;">Auftragsverwaltung</title>',
                        f'<title>{variant["title"]} - Auftragsverwaltung</title>')
    html = html.replace('<title>Auftragsverwaltung</title>',
                        f'<title>{variant["title"]} - Auftragsverwaltung</title>')

    # Body background (solid color to gradient)
    html = re.sub(
        r'body\s*\{([^}]*?)background-color:\s*#[0-9a-fA-F]+;',
        f'body {{\\1background: {variant["body_bg"]};',
        html
    )

    # Window frame background
    html = re.sub(
        r'\.window-frame\s*\{([^}]*?)background-color:\s*#[0-9a-fA-F]+;',
        f'.window-frame {{\\1background: {variant["frame_bg"]};',
        html
    )

    # Left menu background
    html = re.sub(
        r'\.left-menu\s*\{([^}]*?)background-color:\s*#[0-9a-fA-F]+;',
        f'.left-menu {{\\1background: {variant["left_menu_bg"]};',
        html
    )

    # Menu header background
    html = re.sub(
        r'\.menu-header\s*\{([^}]*?)background-color:\s*#[0-9a-fA-F]+;',
        f'.menu-header {{\\1background: {variant["menu_header_bg"]};',
        html
    )

    # Button row background
    html = re.sub(
        r'\.button-row\s*\{([^}]*?)background-color:\s*#[0-9a-fA-F]+;',
        f'.button-row {{\\1background: {variant["button_row_bg"]};',
        html
    )

    # Logo gradient
    html = re.sub(
        r'\.logo-box\s*\{([^}]*?)background:\s*linear-gradient\([^)]+\);',
        f'.logo-box {{\\1background: {variant["logo_gradient"]};',
        html
    )

    # Title color
    html = re.sub(
        r'\.title-text\s*\{([^}]*?)color:\s*#[0-9a-fA-F]+;',
        f'.title-text {{\\1color: {variant["title_color"]};',
        html
    )

    # Header links color
    html = re.sub(
        r'\.header-link\s*\{([^}]*?)color:\s*#[0-9a-fA-F]+;',
        f'.header-link {{\\1color: {variant["title_color"]};',
        html
    )

    # Fullscreen button color
    html = re.sub(
        r'\.fullscreen-btn\s*\{([^}]*?)color:\s*#[0-9a-fA-F]+;',
        f'.fullscreen-btn {{\\1color: {variant["title_color"]};',
        html
    )

    # Varianten-Info Banner einfuegen (vor </head>)
    variant_banner = f'''
    <style>
    /* VARIANTE: {variant["title"]} */
    .variant-banner {{
        position: fixed;
        bottom: 10px;
        right: 10px;
        background: rgba(255,255,255,0.95);
        border: 2px solid {variant["accent"]};
        border-radius: 8px;
        padding: 8px 16px;
        font-size: 12px;
        font-weight: bold;
        color: {variant["accent"]};
        z-index: 9999;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    }}
    </style>
    '''
    html = html.replace('</head>', variant_banner + '</head>')

    # Banner HTML einfuegen (vor </body>)
    banner_html = f'<div class="variant-banner">{variant["title"]}</div>'
    html = html.replace('</body>', banner_html + '</body>')

    # Datei speichern
    output_file = os.path.join(base_path, f'frm_va_Auftragstamm_{variant["name"]}.html')
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html)

    print(f"  Erstellt: frm_va_Auftragstamm_{variant['name']}.html")

print("\nAlle 8 Varianten erstellt!")
