#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Erstellt Farbvarianten des frm_va_Auftragstamm.html Formulars
"""

import re
import os

# Farbmappings definieren
# Format: Original -> (Teal, Ocean Blue)

COLOR_MAPS = {
    # Hauptfarben
    '#8080c0': ('#00796B', '#1976D2'),  # Body Background / Window Frame
    '#6060a0': ('#004D40', '#0D47A1'),  # Sidebar Background
    '#000080': ('#00695C', '#1565C0'),  # Header / Title Bar Start / Dark Accents / Fullscreen Icon / Modal / Spinner
    '#1084d0': ('#26A69A', '#42A5F5'),  # Title Bar Gradient End

    # Content Area Backgrounds
    '#9090c0': ('#4DB6AC', '#64B5F6'),  # Header Row / Button Row / Tab Container
    '#b8b8d8': ('#80CBC4', '#90CAF9'),  # Form Section
    '#a0a0c0': ('#80CBC4', '#90CAF9'),  # Tab Button / Date Nav / Menu Button Gradient Bottom
    '#8080b0': ('#26A69A', '#42A5F5'),  # Tab Header / Menu Button Active Darker

    # Logo und Gradients
    '#4040a0': ('#00695C', '#1565C0'),  # Logo Gradient Start

    # Borders
    '#606090': ('#00695C', '#1565C0'),  # Dark Borders
    '#404080': ('#004D40', '#0D47A1'),  # Darker Borders
    '#404070': ('#004D40', '#0D47A1'),  # Menu Button Shadow
    '#505080': ('#00695C', '#1565C0'),  # Menu Button Active Shadow

    # Menu Buttons
    '#d0d0e0': ('#B2DFDB', '#BBDEFB'),  # Menu Button Gradient Top
    '#e0e0f0': ('#E0F2F1', '#E3F2FD'),  # Menu Button Hover Top
    '#b0b0d0': ('#B2DFDB', '#BBDEFB'),  # Menu Button Hover Bottom
    '#9090b0': ('#4DB6AC', '#64B5F6'),  # Menu Button Active Bottom
    '#a0a0d0': ('#80CBC4', '#90CAF9'),  # Menu Button Active Variant
    '#c0c0d8': ('#B2DFDB', '#BBDEFB'),  # Menu Button Active Light Border

    # Table Headers
    '#c0c0d0': ('#B2DFDB', '#BBDEFB'),  # Auftraege Table Header Top
    '#a0a0b0': ('#80CBC4', '#90CAF9'),  # Auftraege Table Header Bottom

    # Table Row Colors
    '#e0e0ff': ('#E0F2F1', '#E3F2FD'),  # Row Hover
    '#f0f0ff': ('#E0F2F1', '#E3F2FD'),  # Row Even
    '#d0d0ff': ('#B2DFDB', '#BBDEFB'),  # Row Hover (Auftraege)

    # Status Colors (Text)
    '#c00000': ('#B71C1C', '#C62828'),  # Red Status Text

    # Button Colors - Green
    '#60c060': ('#26A69A', '#42A5F5'),  # Green Button Top
    '#308030': ('#00796B', '#1976D2'),  # Green Button Bottom

    # Button Colors - Yellow
    '#e0e080': ('#FFD54F', '#FFD54F'),  # Yellow Button Top
    '#c0c040': ('#FFC107', '#FFC107'),  # Yellow Button Bottom

    # Button Colors - Red
    '#e06060': ('#EF5350', '#EF5350'),  # Red Button Top
    '#c04040': ('#E53935', '#E53935'),  # Red Button Bottom

    # Cell Colors
    '#add8e6': ('#80DEEA', '#81D4FA'),  # Cell Blue
    '#90ee90': ('#A5D6A7', '#A5D6A7'),  # Cell Green
    '#ffff90': ('#FFF59D', '#FFF59D'),  # Cell Yellow
    '#ffb0b0': ('#EF9A9A', '#EF9A9A'),  # Cell Red

    # GPT Box
    '#ffe0e0': ('#FFEBEE', '#FFEBEE'),  # GPT Box Background
    '#a00000': ('#C62828', '#C62828'),  # GPT Box Border

    # Close Button
    '#c75050': ('#EF5350', '#EF5350'),  # Close Button Background
}

def create_variant(source_path, target_path, variant_name, color_index):
    """
    Erstellt eine Farbvariante

    Args:
        source_path: Pfad zur Original-Datei
        target_path: Pfad zur Ziel-Datei
        variant_name: Name der Variante (für Kommentar)
        color_index: 0 für Teal, 1 für Ocean Blue
    """
    print(f"Erstelle {variant_name}...")

    # Datei lesen
    with open(source_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Titel anpassen
    content = content.replace(
        '<title>Auftragsverwaltung</title>',
        f'<title>Auftragsverwaltung - {variant_name}</title>'
    )

    # Kommentar am Anfang des <style> Tags hinzufügen
    content = content.replace(
        '    <style>',
        f'    <!-- VARIANTE: {variant_name} -->\n    <style>'
    )

    # Farbersetzungen durchführen
    replacements_made = 0
    for original_color, (teal_color, ocean_color) in COLOR_MAPS.items():
        target_color = teal_color if color_index == 0 else ocean_color

        # Ersetze in CSS-Properties (case-insensitive)
        # Muster: property: #XXXXXX oder property: linear-gradient(...#XXXXXX...)
        pattern = re.compile(re.escape(original_color), re.IGNORECASE)
        matches = len(pattern.findall(content))
        if matches > 0:
            content = pattern.sub(target_color, content)
            replacements_made += matches
            print(f"  {original_color} -> {target_color}: {matches}x")

    print(f"  Gesamt: {replacements_made} Farbersetzungen")

    # Datei schreiben
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with open(target_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"  Gespeichert: {target_path}\n")

def main():
    # Pfade definieren
    base_dir = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms'
    source_file = os.path.join(base_dir, 'frm_va_Auftragstamm.html')
    variant_dir = os.path.join(base_dir, 'varianten_auftragstamm')

    # Variante 9: Teal Refresh
    create_variant(
        source_file,
        os.path.join(variant_dir, 'variante_09_teal.html'),
        'Teal Refresh',
        0  # Teal
    )

    # Variante 10: Ocean Blue
    create_variant(
        source_file,
        os.path.join(variant_dir, 'variante_10_ocean_blue.html'),
        'Ocean Blue',
        1  # Ocean Blue
    )

    print("Fertig! Beide Varianten wurden erstellt.")

if __name__ == '__main__':
    main()
