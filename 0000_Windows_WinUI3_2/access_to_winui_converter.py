#!/usr/bin/env python3
"""
Access JSON to WinUI3 XAML Converter
Erstellt pixel-genaue 1:1 Nachbildungen von Access-Formularen

Verwendung:
    python access_to_winui_converter.py <json_file> <output_xaml>
"""

import json
import os
import sys
import re
from typing import Dict, List, Any, Tuple, Optional

# Twips zu Pixel Konvertierung (1 Twip = 1/1440 Zoll, bei 96 DPI = 1/15 Pixel)
TWIPS_TO_PIXELS = 1 / 15

# Access System-Farben (negative Long-Werte)
SYSTEM_COLORS = {
    -2147483633: "#F0F0F0",  # COLOR_BTNFACE
    -2147483643: "#000000",  # COLOR_WINDOWTEXT
    -2147483640: "#FFFFFF",  # COLOR_WINDOW
    -2147483635: "#C0C0C0",  # COLOR_BTNSHADOW
    -2147483632: "#808080",  # COLOR_GRAYTEXT
    -2147483630: "#000000",  # COLOR_BTNTEXT
    -2147483616: "#000000",  # COLOR_INFOTEXT
    -2147483605: "#F0F0F0",  # COLOR_BTNHIGHLIGHT
    -2147483607: "#F0F0F0",  # COLOR_3DLIGHT
    -2147483634: "#DFDFDF",  # COLOR_3DFACE
    -2147483624: "#000080",  # COLOR_HIGHLIGHT
    -2147483641: "#FFFFFF",  # COLOR_HIGHLIGHTTEXT
}


def access_color_to_hex(color_value: Any) -> str:
    """Konvertiert Access-Farbwerte (Long) zu HEX-Strings."""
    if color_value is None:
        return "#FFFFFF"

    try:
        color = int(color_value)
    except (ValueError, TypeError):
        return "#FFFFFF"

    # System-Farben (negative Werte)
    if color < 0:
        return SYSTEM_COLORS.get(color, "#FFFFFF")

    # Positive Long-Werte: BGR-Format
    r = color & 0xFF
    g = (color >> 8) & 0xFF
    b = (color >> 16) & 0xFF
    return f"#{r:02X}{g:02X}{b:02X}"


def twips_to_pixels(twips: Any) -> int:
    """Konvertiert Twips zu Pixeln."""
    try:
        return int(float(twips) * TWIPS_TO_PIXELS)
    except (ValueError, TypeError):
        return 0


def parse_german_bool(value: Any) -> bool:
    """Parst deutsche Boolean-Werte."""
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        val = value.lower().strip()
        return val in ("wahr", "true", "1", "ja", "yes")
    return bool(value)


def escape_xaml(text: str) -> str:
    """Escaped Sonderzeichen für XAML."""
    if not text:
        return ""
    return (text
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;"))


class AccessToWinUIConverter:
    """Konvertiert Access-Formular JSON zu WinUI3 XAML."""

    def __init__(self, json_path: str):
        self.json_path = json_path
        self.form_data = None
        self.controls = []
        self.pages = {}  # TabControl-Pages
        self.namespace = "ConsysWinUI.Views"

    def load(self):
        """Lädt die JSON-Datei."""
        # Versuche verschiedene Encodings
        for encoding in ['utf-8', 'cp1252', 'latin-1', 'iso-8859-1']:
            try:
                with open(self.json_path, 'r', encoding=encoding) as f:
                    content = f.read()
                break
            except UnicodeDecodeError:
                continue
        else:
            raise ValueError(f"Konnte Datei nicht lesen: {self.json_path}")

        # Deutsche Boolean-Werte ersetzen
        content = re.sub(r'\bwahr\b', 'true', content, flags=re.IGNORECASE)
        content = re.sub(r'\bfalsch\b', 'false', content, flags=re.IGNORECASE)
        self.form_data = json.loads(content)

        self.controls = self.form_data.get("controls", [])
        self._organize_controls()

    def _organize_controls(self):
        """Organisiert Controls nach TabControl-Pages."""
        for ctrl in self.controls:
            ctrl_type = ctrl.get("type", "")
            if ctrl_type == "Page":
                page_name = ctrl.get("name", "")
                self.pages[page_name] = []

    def get_form_name(self) -> str:
        """Gibt den Formularnamen zurück."""
        return self.form_data.get("name", "UnknownForm")

    def get_class_name(self) -> str:
        """Generiert den C#-Klassennamen."""
        name = self.get_form_name()
        # Entferne Präfixe und normalisiere
        name = name.replace("frm_", "").replace("FRM_", "")
        name = re.sub(r'[^a-zA-Z0-9_]', '', name)
        return f"{name}View"

    def convert_control(self, ctrl: Dict[str, Any], indent: int = 4) -> str:
        """Konvertiert ein einzelnes Control zu XAML."""
        ctrl_type = ctrl.get("type", "")
        props = ctrl.get("properties", {})
        name = ctrl.get("name", "")

        # Sichtbarkeit prüfen
        if not parse_german_bool(props.get("Visible", True)):
            return ""

        # Position und Größe
        left = twips_to_pixels(props.get("Left", 0))
        top = twips_to_pixels(props.get("Top", 0))
        width = twips_to_pixels(props.get("Width", 100))
        height = twips_to_pixels(props.get("Height", 25))

        # Farben
        fore_color = access_color_to_hex(props.get("ForeColor"))
        back_color = access_color_to_hex(props.get("BackColor"))
        border_color = access_color_to_hex(props.get("BorderColor"))

        # Border
        border_style = int(props.get("BorderStyle", 0))
        border_width = int(props.get("BorderWidth", 0)) if border_style > 0 else 0

        indent_str = " " * indent

        if ctrl_type == "Label":
            return self._convert_label(ctrl, indent_str, left, top, width, height,
                                       fore_color, back_color)
        elif ctrl_type == "TextBox":
            return self._convert_textbox(ctrl, indent_str, left, top, width, height,
                                         fore_color, back_color, border_color)
        elif ctrl_type == "CommandButton":
            return self._convert_button(ctrl, indent_str, left, top, width, height,
                                        fore_color, back_color)
        elif ctrl_type == "CheckBox":
            return self._convert_checkbox(ctrl, indent_str, left, top, width, height)
        elif ctrl_type == "ComboBox":
            return self._convert_combobox(ctrl, indent_str, left, top, width, height,
                                          fore_color, back_color)
        elif ctrl_type == "ListBox":
            return self._convert_listbox(ctrl, indent_str, left, top, width, height,
                                         fore_color, back_color)
        elif ctrl_type == "Rectangle":
            return self._convert_rectangle(ctrl, indent_str, left, top, width, height,
                                           back_color, border_color, border_width)
        elif ctrl_type == "TabControl":
            return self._convert_tabcontrol(ctrl, indent_str, left, top, width, height)
        elif ctrl_type == "SubForm":
            return self._convert_subform(ctrl, indent_str, left, top, width, height)
        else:
            # Unbekannter Typ - als Kommentar
            return f"{indent_str}<!-- Unbekannter Control-Typ: {ctrl_type} ({name}) -->\n"

    def _convert_label(self, ctrl, indent, left, top, width, height, fore, back) -> str:
        """Konvertiert ein Label."""
        name = ctrl.get("name", "")
        # Caption wird oft aus spec.json geladen, hier Fallback auf Name
        caption = escape_xaml(ctrl.get("caption", name))

        return f'''{indent}<TextBlock
{indent}    x:Name="{name}"
{indent}    Text="{caption}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Foreground="{fore}"
{indent}    VerticalAlignment="Center"/>
'''

    def _convert_textbox(self, ctrl, indent, left, top, width, height, fore, back, border) -> str:
        """Konvertiert eine TextBox."""
        name = ctrl.get("name", "")
        control_source = ctrl.get("control_source", "")
        props = ctrl.get("properties", {})
        locked = parse_german_bool(props.get("Locked", False))

        return f'''{indent}<TextBox
{indent}    x:Name="{name}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Foreground="{fore}"
{indent}    Background="{back}"
{indent}    BorderBrush="{border}"
{indent}    IsReadOnly="{str(locked).lower()}"
{indent}    VerticalAlignment="Center"/>
'''

    def _convert_button(self, ctrl, indent, left, top, width, height, fore, back) -> str:
        """Konvertiert einen Button."""
        name = ctrl.get("name", "")
        caption = escape_xaml(ctrl.get("caption", name))

        return f'''{indent}<Button
{indent}    x:Name="{name}"
{indent}    Content="{caption}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Foreground="{fore}"
{indent}    Background="{back}"/>
'''

    def _convert_checkbox(self, ctrl, indent, left, top, width, height) -> str:
        """Konvertiert eine CheckBox."""
        name = ctrl.get("name", "")
        caption = escape_xaml(ctrl.get("caption", ""))

        return f'''{indent}<CheckBox
{indent}    x:Name="{name}"
{indent}    Content="{caption}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"/>
'''

    def _convert_combobox(self, ctrl, indent, left, top, width, height, fore, back) -> str:
        """Konvertiert eine ComboBox."""
        name = ctrl.get("name", "")

        return f'''{indent}<ComboBox
{indent}    x:Name="{name}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Foreground="{fore}"
{indent}    Background="{back}"/>
'''

    def _convert_listbox(self, ctrl, indent, left, top, width, height, fore, back) -> str:
        """Konvertiert eine ListBox."""
        name = ctrl.get("name", "")

        return f'''{indent}<ListView
{indent}    x:Name="{name}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Foreground="{fore}"
{indent}    Background="{back}"/>
'''

    def _convert_rectangle(self, ctrl, indent, left, top, width, height, back, border, border_width) -> str:
        """Konvertiert ein Rechteck."""
        name = ctrl.get("name", "")

        return f'''{indent}<Border
{indent}    x:Name="{name}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Background="{back}"
{indent}    BorderBrush="{border}"
{indent}    BorderThickness="{border_width}"/>
'''

    def _convert_tabcontrol(self, ctrl, indent, left, top, width, height) -> str:
        """Konvertiert ein TabControl."""
        name = ctrl.get("name", "")
        props = ctrl.get("properties", {})
        back_color = access_color_to_hex(props.get("BackColor"))

        # Finde alle zugehörigen Pages
        pages_xaml = ""
        for page_ctrl in self.controls:
            if page_ctrl.get("type") == "Page":
                page_name = page_ctrl.get("name", "")
                page_props = page_ctrl.get("properties", {})
                page_visible = parse_german_bool(page_props.get("Visible", True))
                if not page_visible:
                    continue

                # Caption für Page
                page_caption = escape_xaml(page_ctrl.get("caption", page_name))

                pages_xaml += f'''{indent}    <PivotItem Header="{page_caption}" x:Name="{page_name}">
{indent}        <Canvas>
{indent}            <!-- Controls für {page_name} werden hier eingefügt -->
{indent}        </Canvas>
{indent}    </PivotItem>
'''

        return f'''{indent}<Pivot
{indent}    x:Name="{name}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    Background="{back_color}">
{pages_xaml}{indent}</Pivot>
'''

    def _convert_subform(self, ctrl, indent, left, top, width, height) -> str:
        """Konvertiert ein SubForm."""
        name = ctrl.get("name", "")
        subform = ctrl.get("subform", {})
        source_object = subform.get("source_object", "")

        return f'''{indent}<Border
{indent}    x:Name="{name}"
{indent}    Canvas.Left="{left}"
{indent}    Canvas.Top="{top}"
{indent}    Width="{width}"
{indent}    Height="{height}"
{indent}    BorderBrush="#A0A0A0"
{indent}    BorderThickness="1">
{indent}    <!-- SubForm: {source_object} -->
{indent}    <ContentControl x:Name="{name}_Content"/>
{indent}</Border>
'''

    def generate_xaml(self) -> str:
        """Generiert das vollständige XAML."""
        class_name = self.get_class_name()
        form_name = self.get_form_name()

        # Header
        xaml = f'''<Page
    x:Class="{self.namespace}.{class_name}"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:local="using:{self.namespace}"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    mc:Ignorable="d"
    Background="{{ThemeResource ApplicationPageBackgroundThemeBrush}}">

    <!-- 1:1 Nachbildung von Access-Formular: {form_name} -->
    <!-- Generiert von access_to_winui_converter.py -->

    <Canvas x:Name="MainCanvas">
'''

        # Controls konvertieren - erst Rectangles (Hintergrund), dann Rest
        rectangles = []
        other_controls = []

        for ctrl in self.controls:
            ctrl_type = ctrl.get("type", "")
            if ctrl_type == "Rectangle":
                rectangles.append(ctrl)
            else:
                other_controls.append(ctrl)

        # Erst Hintergrund-Rechtecke
        for ctrl in rectangles:
            xaml += self.convert_control(ctrl, indent=8)

        # Dann alle anderen Controls
        for ctrl in other_controls:
            xaml += self.convert_control(ctrl, indent=8)

        # Footer
        xaml += '''    </Canvas>
</Page>
'''
        return xaml

    def generate_codebehind(self) -> str:
        """Generiert die Code-Behind C#-Datei."""
        class_name = self.get_class_name()
        form_name = self.get_form_name()

        return f'''using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;

namespace {self.namespace}
{{
    /// <summary>
    /// 1:1 Nachbildung von Access-Formular: {form_name}
    /// </summary>
    public sealed partial class {class_name} : Page
    {{
        public {class_name}()
        {{
            this.InitializeComponent();
        }}
    }}
}}
'''

    def save(self, output_path: str):
        """Speichert XAML und Code-Behind."""
        xaml = self.generate_xaml()
        codebehind = self.generate_codebehind()

        # XAML speichern
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(xaml)
        print(f"XAML gespeichert: {output_path}")

        # Code-Behind speichern
        cs_path = output_path + ".cs"
        with open(cs_path, 'w', encoding='utf-8') as f:
            f.write(codebehind)
        print(f"Code-Behind gespeichert: {cs_path}")


def main():
    if len(sys.argv) < 2:
        print("Verwendung: python access_to_winui_converter.py <json_file> [output_xaml]")
        print()
        print("Beispiel:")
        print("  python access_to_winui_converter.py FRM_frm_MA_Mitarbeiterstamm.json")
        sys.exit(1)

    json_path = sys.argv[1]

    if len(sys.argv) >= 3:
        output_path = sys.argv[2]
    else:
        # Automatischer Output-Pfad
        base_name = os.path.basename(json_path).replace("FRM_", "").replace(".json", "")
        base_name = re.sub(r'[^a-zA-Z0-9_]', '', base_name.replace("frm_", ""))
        output_path = f"{base_name}View.xaml"

    converter = AccessToWinUIConverter(json_path)
    converter.load()
    converter.save(output_path)
    print(f"\nKonvertierung abgeschlossen!")


if __name__ == "__main__":
    main()
