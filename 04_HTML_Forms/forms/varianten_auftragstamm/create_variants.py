#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Erstellt Design-Varianten des Auftragstamm-Formulars
NUR CSS-Änderungen - HTML und JavaScript bleiben unverändert
"""

import re
import os

# Pfade
ORIGINAL_FILE = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\frm_va_Auftragstamm.html"
OUTPUT_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\varianten_auftragstamm"

# Original-HTML lesen
with open(ORIGINAL_FILE, 'r', encoding='utf-8') as f:
    original_html = f.read()

# ==================================================
# VARIANTE 5: ELEGANT DARK MODE
# ==================================================
dark_mode_replacements = [
    # Title
    (r'<title>Auftragsverwaltung</title>', '<title>Auftragsverwaltung - Dark Mode</title>'),

    # Body & Window Frame Background
    (r'background-color: #8080c0;', 'background-color: #1E1E1E;'),

    # Title Bar
    (r'background: linear-gradient\(to right, #000080, #1084d0\);',
     'background: linear-gradient(to right, #2D2D2D, #3D3D3D); border-bottom: 1px solid #BB86FC;'),

    # Title Bar Text - ersetze nur in title-bar Kontext
    (r'(\.title-bar \{[^}]*color: )white;', r'\1#E0E0E0;'),

    # Title Buttons
    (r'background: #ece9d8;', 'background: #3C3C3C;'),
    (r'border-color: #ffffff #808080 #808080 #ffffff;', 'border-color: #5C5C5C #1C1C1C #1C1C1C #5C5C5C;'),

    # Close Button
    (r'(\.title-btn\.close \{[^}]*)background: #c75050;', r'\1background: #BB3030;'),

    # Left Menu
    (r'background-color: #6060a0;', 'background-color: #2D2D2D;'),
    (r'background-color: #000080;', 'background-color: #BB86FC;'),

    # Menu Buttons
    (r'background: linear-gradient\(to bottom, #d0d0e0, #a0a0c0\);',
     'background: linear-gradient(to bottom, #3C3C3C, #2D2D2D);'),
    (r'(\.menu-btn \{[^}]*)color: #000;', r'\1color: #E0E0E0;'),
    (r'(\.menu-btn::before \{[^}]*)background: #ffffff;', r'\1background: #5C5C5C;'),
    (r'(\.menu-btn::after \{[^}]*)background: #404070;', r'\1background: #1C1C1C;'),
    (r'background: linear-gradient\(to bottom, #e0e0f0, #b0b0d0\);',
     'background: linear-gradient(to bottom, #4C4C4C, #3D3D3D);'),
    (r'background: linear-gradient\(to bottom, #b0b0d0, #9090b0\);',
     'background: linear-gradient(to bottom, #3D3D3D, #2D2D2D);'),
    (r'background: linear-gradient\(to bottom, #a0a0d0, #8080b0\);',
     'background: linear-gradient(to bottom, #BB86FC, #9B66DC);'),

    # Content Area
    (r'background-color: #9090c0;', 'background-color: #2D2D2D;'),
    (r'border: 1px solid #606090;', 'border: 1px solid #4C4C4C;'),

    # Logo Box
    (r'background: linear-gradient\(135deg, #4040a0, #8080c0\);',
     'background: linear-gradient(135deg, #BB86FC, #9B66DC);'),
    (r'border: 2px solid #404080;', 'border: 2px solid #BB86FC;'),

    # Title Text
    (r'color: #000080;', 'color: #BB86FC;'),

    # Buttons
    (r'background: linear-gradient\(to bottom, #e8e8e8, #c0c0c0\);',
     'background: linear-gradient(to bottom, #3C3C3C, #2D2D2D);'),
    (r'(\.btn \{[^}]*)border-color: #ffffff #808080 #808080 #ffffff;',
     r'\1border-color: #5C5C5C #1C1C1C #1C1C1C #5C5C5C; color: #E0E0E0;'),
    (r'background: linear-gradient\(to bottom, #f0f0f0, #d0d0d0\);',
     'background: linear-gradient(to bottom, #4C4C4C, #3D3D3D);'),

    # Colored Buttons
    (r'background: linear-gradient\(to bottom, #60c060, #308030\);',
     'background: linear-gradient(to bottom, #4CAF50, #388E3C);'),
    (r'background: linear-gradient\(to bottom, #e0e080, #c0c040\);',
     'background: linear-gradient(to bottom, #FFC107, #FFA000);'),
    (r'background: linear-gradient\(to bottom, #e06060, #c04040\);',
     'background: linear-gradient(to bottom, #F44336, #D32F2F);'),

    # GPT Box
    (r'background: #ffe0e0;', 'background: #4C2020;'),
    (r'border: 1px solid #a00000;', 'border: 1px solid #BB3030;'),
    (r'(\.gpt-box \{[^}]*)font-size:', r'\1color: #E0E0E0; font-size:'),

    # Form Section
    (r'background-color: #b8b8d8;', 'background-color: #3C3C3C;'),

    # Form Inputs
    (r'(\.form-select, \.form-input \{[^}]*)background: white;',
     r'\1background: #2D2D2D; color: #E0E0E0;'),
    (r'background: #e0e0e0;', 'background: #1E1E1E;'),
    (r'border-color: #000080;', 'border-color: #BB86FC;'),
    (r'box-shadow: 0 0 2px #000080;', 'box-shadow: 0 0 2px #BB86FC;'),

    # Tab Container
    (r'background: #8080b0;', 'background: #2D2D2D;'),
    (r'background: #a0a0c0;', 'background: #3C3C3C;'),

    # Data Grid
    (r'(\.data-grid th \{[^}]*)background: linear-gradient\(to bottom, #e0e0e0, #c0c0c0\);',
     r'\1background: linear-gradient(to bottom, #3C3C3C, #2D2D2D); color: #E0E0E0;'),
    (r'background: #e0e0ff;', 'background: #3C3C4C;'),
    (r'background: #000080;', 'background: #BB86FC;'),
    (r'(\.data-grid tr\.selected \{[^}]*)color: white;', r'\1color: #000000;'),
    (r'(\.data-grid input, \.data-grid select \{[^}]*)background: transparent;',
     r'\1background: transparent; color: #E0E0E0;'),

    # Cell Colors
    (r'background-color: #add8e6;', 'background-color: #2C4C5C;'),
    (r'background-color: #90ee90;', 'background-color: #2C5C2C;'),
    (r'background-color: #ffff90;', 'background-color: #5C5C2C;'),
    (r'background-color: #ffb0b0;', 'background-color: #5C2C2C;'),

    # Right Panel
    (r'(\.auftraege-table th \{[^}]*)background: linear-gradient\(to bottom, #c0c0d0, #a0a0b0\);',
     r'\1background: linear-gradient(to bottom, #3C3C3C, #2D2D2D); color: #E0E0E0;'),
    (r'(\.auftraege-table td \{[^}]*)background: white;',
     r'\1background: #2D2D2D; color: #E0E0E0;'),
    (r'background: #f0f0ff;', 'background: #353545;'),
    (r'background: #d0d0ff;', 'background: #4C4C6C;'),

    # Status Bar
    (r'background: #c0c0c0;', 'background: #2D2D2D;'),
    (r'border: 1px inset #808080;', 'border: 1px solid #4C4C4C;'),
    (r'(\.status-section \{[^}]*)background: #e0e0e0;',
     r'\1background: #3C3C3C; color: #E0E0E0;'),

    # Loading Overlay
    (r'background: rgba\(128, 128, 192, 0\.8\);', 'background: rgba(30, 30, 30, 0.9);'),
    (r'border: 4px solid #fff;', 'border: 4px solid #BB86FC;'),
    (r'border-top-color: #000080;', 'border-top-color: #E0E0E0;'),

    # Modal
    (r'background: rgba\(0,0,0,0\.5\);', 'background: rgba(0,0,0,0.8);'),
    (r'(\.modal-content \{[^}]*)background: #c0c0c0;',
     r'\1background: #2D2D2D; color: #E0E0E0;'),
    (r'border-color: #fff #808080 #808080 #fff;', 'border-color: #5C5C5C #1C1C1C #1C1C1C #5C5C5C;'),

    # Scrollbar
    (r'(::-webkit-scrollbar-track \{[^}]*)background: #c0c0c0;',
     r'\1background: #1E1E1E;'),
    (r'(::-webkit-scrollbar-thumb \{[^}]*)background: #a0a0a0;',
     r'\1background: #4C4C4C;'),
    (r'border-color: #e0e0e0 #606060 #606060 #e0e0e0;', 'border-color: #5C5C5C #1C1C1C #1C1C1C #5C5C5C;'),

    # Fullscreen Button
    (r'(\.fullscreen-btn \{[^}]*)background: linear-gradient\(to bottom, #e8e8e8, #c0c0c0\);',
     r'\1background: linear-gradient(to bottom, #3C3C3C, #2D2D2D);'),
    (r'(\.fullscreen-btn \{[^}]*)color: #000080;', r'\1color: #BB86FC;'),
]

dark_mode_html = original_html
for pattern, replacement in dark_mode_replacements:
    dark_mode_html = re.sub(pattern, replacement, dark_mode_html)

# Datei speichern
output_file = os.path.join(OUTPUT_DIR, 'variante_05_dark_mode.html')
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(dark_mode_html)

print(f"✓ Variante 5 (Dark Mode) erstellt: {output_file}")

# ==================================================
# VARIANTE 6: CORPORATE ENTERPRISE GRAY
# ==================================================
enterprise_replacements = [
    # Title
    (r'<title>Auftragsverwaltung</title>', '<title>Auftragsverwaltung - Enterprise</title>'),

    # Body & Window Frame Background
    (r'background-color: #8080c0;', 'background-color: #ECEFF1;'),

    # Title Bar
    (r'background: linear-gradient\(to right, #000080, #1084d0\);',
     'background: linear-gradient(to right, #37474F, #455A64);'),

    # Left Menu
    (r'background-color: #6060a0;', 'background-color: #37474F;'),
    (r'background-color: #000080;', 'background-color: #0288D1;'),

    # Menu Buttons
    (r'background: linear-gradient\(to bottom, #d0d0e0, #a0a0c0\);',
     'background: linear-gradient(to bottom, #CFD8DC, #B0BEC5);'),
    (r'(\.menu-btn \{[^}]*)color: #000;', r'\1color: #263238;'),
    (r'(\.menu-btn::before \{[^}]*)background: #ffffff;', r'\1background: #ECEFF1;'),
    (r'(\.menu-btn::after \{[^}]*)background: #404070;', r'\1background: #78909C;'),
    (r'background: linear-gradient\(to bottom, #e0e0f0, #b0b0d0\);',
     'background: linear-gradient(to bottom, #ECEFF1, #CFD8DC);'),
    (r'background: linear-gradient\(to bottom, #b0b0d0, #9090b0\);',
     'background: linear-gradient(to bottom, #B0BEC5, #90A4AE);'),
    (r'background: linear-gradient\(to bottom, #a0a0d0, #8080b0\);',
     'background: linear-gradient(to bottom, #0288D1, #0277BD);'),

    # Content Area
    (r'background-color: #9090c0;', 'background-color: #CFD8DC;'),
    (r'border: 1px solid #606090;', 'border: 1px solid #90A4AE;'),

    # Logo Box
    (r'background: linear-gradient\(135deg, #4040a0, #8080c0\);',
     'background: linear-gradient(135deg, #0288D1, #0277BD);'),
    (r'border: 2px solid #404080;', 'border: 2px solid #0288D1;'),

    # Title Text
    (r'color: #000080;', 'color: #0288D1;'),

    # Buttons
    (r'background: linear-gradient\(to bottom, #e8e8e8, #c0c0c0\);',
     'background: linear-gradient(to bottom, #ECEFF1, #CFD8DC);'),
    (r'(\.btn \{[^}]*)border-color: #ffffff #808080 #808080 #ffffff;',
     r'\1border-color: #FFFFFF #B0BEC5 #B0BEC5 #FFFFFF; color: #263238;'),
    (r'background: linear-gradient\(to bottom, #f0f0f0, #d0d0d0\);',
     'background: linear-gradient(to bottom, #FFFFFF, #ECEFF1);'),

    # Colored Buttons - bleiben ähnlich aber dezenter
    (r'background: linear-gradient\(to bottom, #60c060, #308030\);',
     'background: linear-gradient(to bottom, #4CAF50, #388E3C);'),
    (r'background: linear-gradient\(to bottom, #e0e080, #c0c040\);',
     'background: linear-gradient(to bottom, #FFC107, #FFA000);'),
    (r'background: linear-gradient\(to bottom, #e06060, #c04040\);',
     'background: linear-gradient(to bottom, #F44336, #D32F2F);'),

    # GPT Box
    (r'background: #ffe0e0;', 'background: #FFEBEE;'),
    (r'border: 1px solid #a00000;', 'border: 1px solid #EF5350;'),

    # Form Section
    (r'background-color: #b8b8d8;', 'background-color: #ECEFF1;'),

    # Form Inputs
    (r'(\.form-select, \.form-input \{[^}]*)background: white;',
     r'\1background: #FFFFFF; color: #263238;'),
    (r'background: #e0e0e0;', 'background: #ECEFF1;'),
    (r'border-color: #000080;', 'border-color: #0288D1;'),
    (r'box-shadow: 0 0 2px #000080;', 'box-shadow: 0 0 2px #0288D1;'),

    # Tab Container
    (r'background: #8080b0;', 'background: #B0BEC5;'),
    (r'background: #a0a0c0;', 'background: #CFD8DC;'),

    # Data Grid
    (r'(\.data-grid th \{[^}]*)background: linear-gradient\(to bottom, #e0e0e0, #c0c0c0\);',
     r'\1background: linear-gradient(to bottom, #CFD8DC, #B0BEC5); color: #263238;'),
    (r'background: #e0e0ff;', 'background: #E1F5FE;'),
    (r'background: #000080;', 'background: #0288D1;'),

    # Cell Colors
    (r'background-color: #add8e6;', 'background-color: #B3E5FC;'),
    (r'background-color: #90ee90;', 'background-color: #C8E6C9;'),
    (r'background-color: #ffff90;', 'background-color: #FFF9C4;'),
    (r'background-color: #ffb0b0;', 'background-color: #FFCCBC;'),

    # Right Panel
    (r'(\.auftraege-table th \{[^}]*)background: linear-gradient\(to bottom, #c0c0d0, #a0a0b0\);',
     r'\1background: linear-gradient(to bottom, #CFD8DC, #B0BEC5); color: #263238;'),
    (r'background: #f0f0ff;', 'background: #F5F5F5;'),
    (r'background: #d0d0ff;', 'background: #E1F5FE;'),

    # Status Bar
    (r'background: #c0c0c0;', 'background: #CFD8DC;'),
    (r'border: 1px inset #808080;', 'border: 1px solid #B0BEC5;'),
    (r'(\.status-section \{[^}]*)background: #e0e0e0;',
     r'\1background: #ECEFF1; color: #263238;'),

    # Loading Overlay
    (r'background: rgba\(128, 128, 192, 0\.8\);', 'background: rgba(236, 239, 241, 0.9);'),
    (r'border-top-color: #000080;', 'border-top-color: #0288D1;'),

    # Modal
    (r'(\.modal-content \{[^}]*)background: #c0c0c0;',
     r'\1background: #ECEFF1; color: #263238;'),
    (r'border-color: #fff #808080 #808080 #fff;', 'border-color: #FFFFFF #B0BEC5 #B0BEC5 #FFFFFF;'),

    # Scrollbar
    (r'(::-webkit-scrollbar-track \{[^}]*)background: #c0c0c0;',
     r'\1background: #ECEFF1;'),
    (r'(::-webkit-scrollbar-thumb \{[^}]*)background: #a0a0a0;',
     r'\1background: #B0BEC5;'),
    (r'border-color: #e0e0e0 #606060 #606060 #e0e0e0;', 'border-color: #CFD8DC #78909C #78909C #CFD8DC;'),

    # Fullscreen Button
    (r'(\.fullscreen-btn \{[^}]*)background: linear-gradient\(to bottom, #e8e8e8, #c0c0c0\);',
     r'\1background: linear-gradient(to bottom, #ECEFF1, #CFD8DC);'),
    (r'(\.fullscreen-btn \{[^}]*)color: #000080;', r'\1color: #0288D1;'),
]

enterprise_html = original_html
for pattern, replacement in enterprise_replacements:
    enterprise_html = re.sub(pattern, replacement, enterprise_html)

# Datei speichern
output_file = os.path.join(OUTPUT_DIR, 'variante_06_enterprise.html')
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(enterprise_html)

print(f"✓ Variante 6 (Enterprise) erstellt: {output_file}")

print("\n=== FERTIG ===")
print("Beide Varianten wurden erstellt:")
print("- variante_05_dark_mode.html")
print("- variante_06_enterprise.html")
