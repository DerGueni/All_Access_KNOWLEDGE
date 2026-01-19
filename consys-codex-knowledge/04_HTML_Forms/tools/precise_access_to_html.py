#!/usr/bin/env python3
"""
Präziser Access zu HTML Generator
Kombiniert FRM_*.json (Farben) mit spec.json (Captions) für pixel-genaue Nachbildung
"""

import json
import os
from typing import Dict, List, Optional

class PreciseAccessToHtml:
    """Generiert pixel-genaues HTML aus Access Formular JSON"""

    # Twips zu Pixel (96 DPI Standard)
    TWIPS_PER_PIXEL = 15

    # Access System-Farben (OLE_COLOR negative Werte)
    SYSTEM_COLORS = {
        -2147483633: '#F0F0F0',  # COLOR_BTNFACE - Formular-Hintergrund
        -2147483643: '#000000',  # COLOR_WINDOWTEXT - Text
        -2147483640: '#FFFFFF',  # COLOR_WINDOW - Fenster-Hintergrund
        -2147483635: '#C0C0C0',  # COLOR_BTNSHADOW - Button-Schatten
        -2147483632: '#808080',  # COLOR_GRAYTEXT - Deaktivierter Text
        -2147483630: '#000000',  # COLOR_BTNTEXT - Button-Text
        -2147483616: '#000000',  # COLOR_INFOTEXT - Info-Text
        -2147483605: '#F0F0F0',  # COLOR_BTNHIGHLIGHT - Button-Highlight
        -2147483606: '#C0C0C0',  # COLOR_3DLIGHT
        -2147483624: '#FFFFFF',  # COLOR_HIGHLIGHTTEXT
        -2147483639: '#000000',  # COLOR_CAPTIONTEXT
    }

    def __init__(self, frm_json_path: str, spec_json_path: str = None):
        """
        Lädt beide JSON-Dateien und kombiniert sie
        - frm_json_path: FRM_*.json mit Farben und Positionen
        - spec_json_path: spec.json mit Captions
        """
        # Lade FRM JSON (mit Farben)
        with open(frm_json_path, 'r', encoding='utf-8') as f:
            content = f.read()
            content = self._fix_german_booleans(content)
            self.frm_data = json.loads(content)

        # Lade Spec JSON (mit Captions)
        self.captions = {}
        if spec_json_path and os.path.exists(spec_json_path):
            with open(spec_json_path, 'r', encoding='utf-8') as f:
                spec_data = json.load(f)
                # Baue Caption-Lookup
                for ctrl in spec_data.get('controls', []):
                    name = ctrl.get('name', '')
                    caption = ctrl.get('caption')
                    if name and caption:
                        self.captions[name] = caption

        self.form_name = self.frm_data.get('name', 'form')
        self.controls = self.frm_data.get('controls', [])
        self.properties = self.frm_data.get('properties', {})

        print(f"Loaded {len(self.controls)} controls, {len(self.captions)} captions")

    def _fix_german_booleans(self, content: str) -> str:
        """Ersetzt deutsche Boolean-Werte"""
        content = content.replace(':wahr,', ':true,')
        content = content.replace(':falsch,', ':false,')
        content = content.replace(':wahr}', ':true}')
        content = content.replace(':falsch}', ':false}')
        content = content.replace('"Wahr"', 'true')
        content = content.replace('"Falsch"', 'false')
        return content

    def twips_to_px(self, twips) -> int:
        """Konvertiert Twips zu Pixel"""
        try:
            return round(int(twips) / self.TWIPS_PER_PIXEL)
        except (ValueError, TypeError):
            return 0

    def access_color_to_hex(self, color_value) -> str:
        """Konvertiert Access Farbwert zu HEX"""
        if color_value is None:
            return '#FFFFFF'

        try:
            color = int(color_value)
        except (ValueError, TypeError):
            return '#FFFFFF'

        # System-Farben (negativ)
        if color < 0:
            return self.SYSTEM_COLORS.get(color, '#F0F0F0')

        # Standard Access BGR zu RGB
        r = color & 0xFF
        g = (color >> 8) & 0xFF
        b = (color >> 16) & 0xFF
        return f'#{r:02X}{g:02X}{b:02X}'

    def get_control_style(self, ctrl: Dict) -> str:
        """Generiert CSS-Style für ein Control"""
        props = ctrl.get('properties', {})

        # Position
        left = self.twips_to_px(props.get('Left', 0))
        top = self.twips_to_px(props.get('Top', 0))
        width = self.twips_to_px(props.get('Width', 0))
        height = self.twips_to_px(props.get('Height', 0))

        # Farben
        back_color = self.access_color_to_hex(props.get('BackColor'))
        fore_color = self.access_color_to_hex(props.get('ForeColor'))
        border_color = self.access_color_to_hex(props.get('BorderColor'))

        # Border
        border_style = props.get('BorderStyle', '0')
        border_width = props.get('BorderWidth', '0')

        styles = [
            f'position: absolute',
            f'left: {left}px',
            f'top: {top}px',
        ]

        if width > 0:
            styles.append(f'width: {width}px')
        if height > 0:
            styles.append(f'height: {height}px')

        # Hintergrundfarbe - immer setzen für exakte Nachbildung
        styles.append(f'background-color: {back_color}')

        # Textfarbe
        if fore_color:
            styles.append(f'color: {fore_color}')

        # Border
        if border_style != '0':
            bw = max(1, int(border_width) if border_width else 1)
            styles.append(f'border: {bw}px solid {border_color}')

        return '; '.join(styles)

    def get_caption(self, name: str, fallback: str = '') -> str:
        """Holt Caption aus spec.json oder verwendet Fallback"""
        return self.captions.get(name, fallback or name)

    def generate_control_html(self, ctrl: Dict) -> str:
        """Generiert HTML für ein Control"""
        ctrl_type = ctrl.get('type', '').lower()
        name = ctrl.get('name', '')
        props = ctrl.get('properties', {})

        # Sichtbarkeit prüfen
        visible = props.get('Visible', True)
        if visible in (False, 'false', '0', 0):
            return ''

        style = self.get_control_style(ctrl)
        caption = self.get_caption(name)
        control_source = ctrl.get('control_source', '')

        if ctrl_type == 'label':
            # Escape HTML in caption
            safe_caption = caption.replace('<', '&lt;').replace('>', '&gt;')
            return f'<span class="access-label" id="{name}" style="{style}">{safe_caption}</span>'

        elif ctrl_type == 'textbox':
            enabled = props.get('Enabled', True) not in (False, 'false', '0', 0)
            locked = props.get('Locked', False) in (True, 'true', '1', 1)
            readonly = 'readonly' if locked or not enabled else ''
            disabled = 'disabled' if not enabled else ''
            data_field = f'data-field="{control_source}"' if control_source else ''
            return f'<input type="text" class="access-textbox" id="{name}" style="{style}" {readonly} {disabled} {data_field}>'

        elif ctrl_type == 'combobox':
            row_source = ctrl.get('row_source', {})
            data_source = row_source.get('ref', '') if isinstance(row_source, dict) else ''
            return f'<select class="access-combobox" id="{name}" style="{style}" data-source="{data_source}"></select>'

        elif ctrl_type == 'commandbutton':
            safe_caption = caption.replace('<', '&lt;').replace('>', '&gt;')
            return f'<button class="access-button" id="{name}" style="{style}">{safe_caption}</button>'

        elif ctrl_type == 'checkbox':
            checked = 'checked' if props.get('DefaultValue', False) else ''
            return f'<label class="access-checkbox-wrapper" style="{style}"><input type="checkbox" id="{name}" {checked}><span>{caption}</span></label>'

        elif ctrl_type == 'rectangle':
            return f'<div class="access-rectangle" id="{name}" style="{style}"></div>'

        elif ctrl_type == 'subform':
            source = ctrl.get('source_object', '')
            return f'<div class="access-subform" id="{name}" data-source="{source}" style="{style}"><iframe></iframe></div>'

        elif ctrl_type == 'tabcontrol':
            return f'<div class="access-tabctl" id="{name}" style="{style}"></div>'

        elif ctrl_type == 'page':
            return f'<div class="access-page" id="{name}" style="{style}"><span class="page-caption">{caption}</span></div>'

        elif ctrl_type == 'optiongroup':
            return f'<div class="access-optiongroup" id="{name}" style="{style}"></div>'

        elif ctrl_type == 'optionbutton':
            return f'<label class="access-optionbutton" style="{style}"><input type="radio" name="optgroup" id="{name}"><span>{caption}</span></label>'

        elif ctrl_type == 'line':
            return f'<hr class="access-line" id="{name}" style="{style}">'

        elif ctrl_type == 'image':
            return f'<img class="access-image" id="{name}" style="{style}" alt="{name}">'

        elif ctrl_type == 'emptycell':
            return ''  # Leere Zellen ignorieren

        else:
            return f'<!-- Unknown: {ctrl_type} {name} -->'

    def generate_css(self) -> str:
        """Generiert CSS basierend auf Access-Formular-Stil"""
        return '''
/* ========== PRECISE ACCESS FORM STYLES ========== */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    font-size: 8pt;
    background: #E4E4E4;
    overflow: auto;
}

.form-container {
    position: relative;
    background: #E4E4E4;
    min-height: 100vh;
    min-width: 1920px;
}

/* Labels */
.access-label {
    position: absolute;
    white-space: nowrap;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    font-size: 8pt;
    user-select: none;
    overflow: hidden;
    text-overflow: ellipsis;
    padding: 0 2px;
}

/* TextBoxes */
.access-textbox {
    position: absolute;
    border: 1px solid #7A7A7A;
    background: #FFFFFF;
    padding: 1px 3px;
    font-size: 8pt;
    font-family: inherit;
}

.access-textbox:focus {
    outline: none;
    border-color: #0078D7;
}

.access-textbox[readonly] {
    background: #F0F0F0;
    color: #6D6D6D;
}

/* ComboBoxes */
.access-combobox {
    position: absolute;
    border: 1px solid #7A7A7A;
    background: #FFFFFF;
    padding: 0 2px;
    font-size: 8pt;
    font-family: inherit;
    cursor: pointer;
}

/* Buttons */
.access-button {
    position: absolute;
    border: 1px solid #707070;
    background: linear-gradient(180deg, #F5F5F5 0%, #E5E5E5 50%, #D4D4D4 100%);
    cursor: pointer;
    font-size: 8pt;
    font-family: inherit;
    padding: 0 8px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    border-radius: 2px;
}

.access-button:hover {
    background: linear-gradient(180deg, #E8F4FC 0%, #D0E8F8 50%, #B8DCF0 100%);
    border-color: #0078D7;
}

.access-button:active {
    background: linear-gradient(180deg, #CCE4F7 0%, #9DCCEA 50%, #6EB4DD 100%);
}

/* Rectangles */
.access-rectangle {
    position: absolute;
    pointer-events: none;
}

/* Subforms */
.access-subform {
    position: absolute;
    border: 1px solid #ABABAB;
    background: #FFFFFF;
    overflow: hidden;
}

.access-subform iframe {
    width: 100%;
    height: 100%;
    border: none;
}

/* Checkboxes */
.access-checkbox-wrapper {
    position: absolute;
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 8pt;
    cursor: pointer;
}

.access-checkbox-wrapper input[type="checkbox"] {
    width: 13px;
    height: 13px;
}

/* Tab Control */
.access-tabctl {
    position: absolute;
    background: #FFFFFF;
    border: 1px solid #999;
}

/* Pages (Tab Pages) */
.access-page {
    position: absolute;
    background: #F0F0F0;
    border: 1px solid #ABABAB;
    border-top: none;
}

.access-page .page-caption {
    position: absolute;
    top: -20px;
    left: 0;
    background: #F0F0F0;
    border: 1px solid #ABABAB;
    border-bottom: none;
    padding: 2px 10px;
    font-size: 8pt;
}

/* Option Groups */
.access-optiongroup {
    position: absolute;
    border: 1px solid #ABABAB;
    background: #F0F0F0;
}

.access-optionbutton {
    position: absolute;
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 8pt;
    cursor: pointer;
}

/* Lines */
.access-line {
    position: absolute;
    border: none;
    border-top: 1px solid #000;
    margin: 0;
}

/* Images */
.access-image {
    position: absolute;
    object-fit: contain;
}
'''

    def generate_html(self) -> str:
        """Generiert das komplette HTML"""

        # Sortiere Controls nach Z-Order (erst Rechtecke, dann andere)
        def sort_key(c):
            props = c.get('properties', {})
            ctrl_type = c.get('type', '').lower()
            # Rechtecke zuerst (Hintergrund)
            type_order = 0 if ctrl_type == 'rectangle' else 1
            top = self.twips_to_px(props.get('Top', '0'))
            left = self.twips_to_px(props.get('Left', '0'))
            return (type_order, top, left)

        sorted_controls = sorted(self.controls, key=sort_key)

        # Generiere HTML für alle sichtbaren Controls
        control_html = []
        stats = {'visible': 0, 'hidden': 0, 'types': {}}

        for ctrl in sorted_controls:
            props = ctrl.get('properties', {})
            visible = props.get('Visible', True)
            ctrl_type = ctrl.get('type', 'unknown')

            stats['types'][ctrl_type] = stats['types'].get(ctrl_type, 0) + 1

            if visible in (False, 'false', '0', 0):
                stats['hidden'] += 1
                continue

            html = self.generate_control_html(ctrl)
            if html:
                control_html.append(f'        {html}')
                stats['visible'] += 1

        controls_str = '\n'.join(control_html)
        css = self.generate_css()

        # Statistik ausgeben
        print(f"\n=== GENERATION STATS ===")
        print(f"Form: {self.form_name}")
        print(f"Total Controls: {len(self.controls)}")
        print(f"Visible: {stats['visible']}, Hidden: {stats['hidden']}")
        print(f"Types: {stats['types']}")
        print(f"Captions loaded: {len(self.captions)}")

        return f'''<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{self.form_name}</title>
    <style>{css}</style>
</head>
<body>
    <div class="form-container">
{controls_str}
    </div>

    <script>
        // API Configuration
        const API_BASE = 'http://localhost:5000/api';

        // Form: {self.form_name}
        // Generated with pixel-precise positioning from Access JSON
        // Captions: {len(self.captions)} loaded from spec.json

        document.addEventListener('DOMContentLoaded', () => {{
            console.log('{self.form_name} loaded - {stats['visible']} controls');

            // Button click handlers
            document.querySelectorAll('.access-button').forEach(btn => {{
                btn.addEventListener('click', () => {{
                    console.log('Button clicked:', btn.id);
                }});
            }});
        }});
    </script>
</body>
</html>'''

    def save(self, output_path: str):
        """Speichert das generierte HTML"""
        html = self.generate_html()
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f'\nHTML saved: {output_path}')


if __name__ == '__main__':
    import sys

    # Pfade
    frm_json = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\11_json_Export\000_Consys_Eport_11_25\30_forms\FRM_frm_VA_Auftragstamm.json'
    spec_json = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\05_Dokumentation\specs\frm_va_Auftragstamm.spec.json'
    output_path = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm_precise.html'

    generator = PreciseAccessToHtml(frm_json, spec_json)
    generator.save(output_path)
