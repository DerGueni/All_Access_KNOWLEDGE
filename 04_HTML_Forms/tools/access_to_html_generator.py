#!/usr/bin/env python3
"""
Access zu HTML Generator - Pixelgenaue 1:1 Nachbildung
Liest Access Formular Specs und generiert exaktes HTML
"""

import json
import os
from typing import Dict, List, Optional, Tuple

class AccessToHtmlGenerator:
    """Generiert HTML aus Access Formular Spezifikationen"""

    # Twips zu Pixel Konvertierung (96 DPI)
    TWIPS_PER_PIXEL = 15

    # Access Control Types zu HTML Elementen
    CONTROL_TYPE_MAP = {
        'label': 'span',
        'textbox': 'input',
        'combobox': 'select',
        'commandbutton': 'button',
        'checkbox': 'input',
        'rectangle': 'div',
        'subform': 'div',
        'page': 'div',
        'optiongroup': 'div',
        'optionbutton': 'input',
        'tabctl': 'div',
    }

    def __init__(self, spec_path: str):
        """Lädt die Spec-Datei"""
        with open(spec_path, 'r', encoding='utf-8') as f:
            self.spec = json.load(f)

        self.form_name = self.spec.get('form_name', 'form')
        self.controls = self.spec.get('controls', [])
        self.subforms = self.spec.get('subforms', [])
        self.sections = self.spec.get('sections', [])

        # Farb-Cache
        self.colors = {}
        self._extract_colors()

    def _twips_to_px(self, twips: Optional[int]) -> int:
        """Konvertiert Twips zu Pixel"""
        if twips is None:
            return 0
        return round(twips / self.TWIPS_PER_PIXEL)

    def _access_color_to_hex(self, color_value: Optional[int]) -> str:
        """Konvertiert Access Long-Farbwert zu HEX
        Access speichert Farben als BGR Long: B*65536 + G*256 + R
        """
        if color_value is None or color_value == 0:
            return '#FFFFFF'
        if color_value < 0:
            # System-Farben (negativ) - Standardwerte
            system_colors = {
                -2147483633: '#F0F0F0',  # Formular-Hintergrund
                -2147483643: '#000000',  # Text
                -2147483640: '#FFFFFF',  # Fenster-Hintergrund
                -2147483635: '#C0C0C0',  # Button-Fläche
                -2147483632: '#808080',  # Button-Schatten
            }
            return system_colors.get(color_value, '#F0F0F0')

        # BGR zu RGB konvertieren
        r = color_value & 0xFF
        g = (color_value >> 8) & 0xFF
        b = (color_value >> 16) & 0xFF
        return f'#{r:02X}{g:02X}{b:02X}'

    def _extract_colors(self):
        """Extrahiert alle Farben aus den Controls"""
        for control in self.controls:
            name = control.get('name', '')
            back_color = control.get('backColor') or control.get('back_color')
            fore_color = control.get('foreColor') or control.get('fore_color')

            if back_color:
                self.colors[f'{name}_bg'] = self._access_color_to_hex(back_color)
            if fore_color:
                self.colors[f'{name}_fg'] = self._access_color_to_hex(fore_color)

        # Sektionen
        for section in self.sections:
            name = section.get('name', '')
            back_color = section.get('backColor') or section.get('back_color')
            if back_color:
                self.colors[f'section_{name}'] = self._access_color_to_hex(back_color)

    def _get_control_style(self, control: Dict) -> str:
        """Generiert CSS-Style für ein Control"""
        pos = control.get('position', {})

        left = self._twips_to_px(pos.get('left'))
        top = self._twips_to_px(pos.get('top'))
        width = self._twips_to_px(pos.get('width'))
        height = self._twips_to_px(pos.get('height'))

        # Farben
        back_color = control.get('backColor') or control.get('back_color')
        fore_color = control.get('foreColor') or control.get('fore_color')

        bg_hex = self._access_color_to_hex(back_color) if back_color else None
        fg_hex = self._access_color_to_hex(fore_color) if fore_color else None

        # Font
        font_name = control.get('fontName') or control.get('font_name', 'Segoe UI')
        font_size = control.get('fontSize') or control.get('font_size', 8)
        font_weight = 'bold' if control.get('fontBold') or control.get('font_bold') else 'normal'

        styles = [
            f'position: absolute',
            f'left: {left}px',
            f'top: {top}px',
        ]

        if width > 0:
            styles.append(f'width: {width}px')
        if height > 0:
            styles.append(f'height: {height}px')
        if bg_hex and bg_hex != '#FFFFFF':
            styles.append(f'background-color: {bg_hex}')
        if fg_hex:
            styles.append(f'color: {fg_hex}')

        styles.append(f'font-family: "{font_name}", sans-serif')
        styles.append(f'font-size: {font_size}pt')
        if font_weight == 'bold':
            styles.append('font-weight: bold')

        return '; '.join(styles)

    def _generate_control_html(self, control: Dict) -> str:
        """Generiert HTML für ein einzelnes Control"""
        ctrl_type = control.get('type', '').lower()
        name = control.get('name', '')
        caption = control.get('caption', '')
        visible = control.get('visible', True)

        if not visible:
            return ''

        style = self._get_control_style(control)

        # Je nach Control-Typ
        if ctrl_type == 'label':
            return f'<span class="access-label" id="{name}" style="{style}">{caption}</span>'

        elif ctrl_type == 'textbox':
            readonly = 'readonly' if control.get('locked') else ''
            return f'<input type="text" class="access-textbox" id="{name}" style="{style}" {readonly}>'

        elif ctrl_type == 'combobox':
            return f'<select class="access-combobox" id="{name}" style="{style}"></select>'

        elif ctrl_type == 'commandbutton':
            return f'<button class="access-button" id="{name}" style="{style}">{caption}</button>'

        elif ctrl_type == 'checkbox':
            return f'<input type="checkbox" class="access-checkbox" id="{name}" style="{style}">'

        elif ctrl_type == 'rectangle':
            return f'<div class="access-rectangle" id="{name}" style="{style}"></div>'

        elif ctrl_type == 'subform':
            source = control.get('sourceObject', '')
            return f'<div class="access-subform" id="{name}" data-source="{source}" style="{style}"></div>'

        elif ctrl_type == 'page':
            return f'<div class="access-page" id="{name}" style="{style}">{caption}</div>'

        else:
            return f'<!-- Unknown: {ctrl_type} {name} -->'

    def _generate_section_controls(self, section_name: str, top_offset: int) -> Tuple[str, int]:
        """Generiert HTML für alle Controls einer Sektion"""
        section_height = 0

        # Finde Sektion
        for section in self.sections:
            if section.get('name') == section_name:
                section_height = self._twips_to_px(section.get('height', 0))
                break

        # Finde Controls in dieser Sektion (basierend auf Top-Position)
        html_parts = []

        for control in self.controls:
            if not control.get('visible', True):
                continue

            pos = control.get('position', {})
            ctrl_top = self._twips_to_px(pos.get('top', 0))

            # Prüfe ob Control in dieser Sektion liegt
            # (vereinfachte Logik - könnte verfeinert werden)
            if top_offset <= ctrl_top < top_offset + section_height:
                html = self._generate_control_html(control)
                if html:
                    html_parts.append(html)

        return '\n            '.join(html_parts), section_height

    def generate_css(self) -> str:
        """Generiert das CSS für das Formular"""

        # Extrahiere Sektions-Farben
        header_bg = '#4A1570'  # Default lila
        detail_bg = '#F0F0F0'  # Default grau
        footer_bg = '#E8E8E8'  # Default hellgrau

        for section in self.sections:
            name = section.get('name', '').lower()
            color = section.get('backColor') or section.get('back_color')
            if color:
                hex_color = self._access_color_to_hex(color)
                if 'kopf' in name or 'header' in name:
                    header_bg = hex_color
                elif 'detail' in name:
                    detail_bg = hex_color
                elif 'fuss' in name or 'footer' in name:
                    footer_bg = hex_color

        return f'''
/* ========== AUTO-GENERATED FROM ACCESS SPEC ========== */
/* Form: {self.form_name} */

:root {{
    --header-bg: {header_bg};
    --detail-bg: {detail_bg};
    --footer-bg: {footer_bg};
}}

* {{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}}

body {{
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    font-size: 11px;
    background: #C0C0C0;
    overflow: auto;
}}

.form-container {{
    position: relative;
    width: 100%;
    min-height: 100vh;
    background: var(--detail-bg);
}}

/* Labels */
.access-label {{
    position: absolute;
    white-space: nowrap;
    display: flex;
    align-items: center;
}}

/* TextBoxes */
.access-textbox {{
    position: absolute;
    border: 1px solid #808080;
    background: #FFFFFF;
    padding: 2px 4px;
}}

.access-textbox:focus {{
    outline: none;
    border-color: #0066CC;
}}

/* ComboBoxes */
.access-combobox {{
    position: absolute;
    border: 1px solid #808080;
    background: #FFFFFF;
    padding: 1px 2px;
}}

/* Buttons */
.access-button {{
    position: absolute;
    border: 1px solid #666;
    background: linear-gradient(180deg, #F8F8F8 0%, #E0E0E0 100%);
    cursor: pointer;
    padding: 2px 6px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}}

.access-button:hover {{
    background: linear-gradient(180deg, #E8E8E8 0%, #D0D0D0 100%);
}}

/* Checkboxes */
.access-checkbox {{
    position: absolute;
}}

/* Rectangles */
.access-rectangle {{
    position: absolute;
    border: 1px solid #666;
}}

/* Subforms */
.access-subform {{
    position: absolute;
    border: 1px solid #999;
    background: #FFFFFF;
    overflow: auto;
}}

/* Pages (Tabs) */
.access-page {{
    position: absolute;
    background: #FFFFFF;
}}
'''

    def generate_html(self) -> str:
        """Generiert das komplette HTML"""

        # Sammle alle Controls nach Position sortiert
        sorted_controls = sorted(
            [c for c in self.controls if c.get('visible', True)],
            key=lambda x: (
                x.get('position', {}).get('top', 0) or 0,
                x.get('position', {}).get('left', 0) or 0
            )
        )

        # Generiere HTML für alle Controls
        control_html = []
        for control in sorted_controls:
            html = self._generate_control_html(control)
            if html:
                control_html.append(html)

        controls_str = '\n        '.join(control_html)
        css = self.generate_css()

        return f'''<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{self.spec.get('caption', self.form_name)}</title>
    <style>{css}</style>
</head>
<body>
    <div class="form-container">
        {controls_str}
    </div>

    <script>
        // API Configuration
        const API_BASE = 'http://localhost:5000/api';

        // Initialize
        document.addEventListener('DOMContentLoaded', async () => {{
            console.log('{self.form_name} initialisiert');
            // TODO: Load data from API
        }});
    </script>
</body>
</html>'''

    def save(self, output_path: str):
        """Speichert das generierte HTML"""
        html = self.generate_html()
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f'HTML gespeichert: {output_path}')

        # Statistik
        print(f'  Controls: {len([c for c in self.controls if c.get("visible", True)])}')
        print(f'  Subforms: {len(self.subforms)}')
        print(f'  Farben extrahiert: {len(self.colors)}')


def generate_control_report(spec_path: str):
    """Generiert einen detaillierten Bericht aller Controls"""
    with open(spec_path, 'r', encoding='utf-8') as f:
        spec = json.load(f)

    controls = spec.get('controls', [])

    print("=" * 120)
    print(f"CONTROL REPORT: {spec.get('form_name')}")
    print("=" * 120)
    print(f"{'Name':<35} {'Type':<15} {'Left':>6} {'Top':>6} {'Width':>6} {'Height':>6} {'BackColor':>12} {'Caption':<30}")
    print("-" * 120)

    for c in sorted(controls, key=lambda x: (x.get('position', {}).get('top', 0) or 0)):
        if not c.get('visible', True):
            continue

        pos = c.get('position', {})
        left = round((pos.get('left') or 0) / 15)
        top = round((pos.get('top') or 0) / 15)
        width = round((pos.get('width') or 0) / 15)
        height = round((pos.get('height') or 0) / 15)
        back_color = c.get('backColor') or c.get('back_color') or ''
        caption = (c.get('caption') or '')[:30]

        print(f"{c.get('name', ''):<35} {c.get('type', ''):<15} {left:>6} {top:>6} {width:>6} {height:>6} {str(back_color):>12} {caption:<30}")


if __name__ == '__main__':
    import sys

    spec_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\05_Dokumentation\specs\frm_va_Auftragstamm.spec.json'
    output_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm_generated.html'

    if len(sys.argv) > 1 and sys.argv[1] == '--report':
        generate_control_report(spec_path)
    else:
        generator = AccessToHtmlGenerator(spec_path)
        generator.save(output_path)
