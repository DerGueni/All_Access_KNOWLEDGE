#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract_sidebar.py
==================
Extrahiert die Sidebar (left-menu) aus allen HTML-Formularen im forms/ Ordner.
Die Sidebar wird als separates sidebar.html erstellt und über die Shell eingebunden.

Ausführung: python extract_sidebar.py
"""

import os
import re
import shutil
from pathlib import Path
from datetime import datetime

# Konfiguration
FORMS_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms")
LOG_FILE = FORMS_PATH / "sidebar_extraction_log.txt"
BACKUP_DIR = FORMS_PATH / "_sidebar_backups"

# Dateien die nicht modifiziert werden sollen
SKIP_FILES = {
    'sidebar.html', 
    'index.html', 
    'test_ie.html', 
    'webview2_test.html',
    'eventdaten_test.html',
    'filter_test.html',
    'ping.html',
    'consys-common.css'
}

# Dateien die mit sub_ beginnen haben keine Sidebar
SKIP_PREFIXES = ('sub_', 'Sub_', 'SUB_')

def log(message, level="INFO"):
    """Logging in Datei und Konsole"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    line = f"[{timestamp}] [{level}] {message}"
    print(line)
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(line + '\n')

def extract_sidebar_from_html(html_content):
    """
    Entfernt die Sidebar (left-menu div) aus dem HTML-Inhalt.
    Verwendet zeilenbasierte Verarbeitung für robuste Extraktion.
    
    Returns:
        tuple: (modified_content, was_modified)
    """
    if 'class="left-menu"' not in html_content:
        return html_content, False
    
    lines = html_content.split('\n')
    result_lines = []
    in_sidebar = False
    sidebar_depth = 0
    sidebar_start_line = -1
    sidebar_end_line = -1
    
    for i, line in enumerate(lines):
        # Start der Sidebar erkennen
        if 'class="left-menu"' in line and not in_sidebar:
            in_sidebar = True
            sidebar_depth = 1
            sidebar_start_line = i
            # Wenn öffnendes und schließendes Tag in gleicher Zeile
            if '</div>' in line:
                closes_in_line = line.count('</div>')
                opens_in_line = line.count('<div')
                sidebar_depth = opens_in_line - closes_in_line
                if sidebar_depth <= 0:
                    in_sidebar = False
                    sidebar_end_line = i
            continue
        
        if in_sidebar:
            # Zähle öffnende und schließende div-Tags
            opens = len(re.findall(r'<div\b', line, re.IGNORECASE))
            closes = len(re.findall(r'</div>', line, re.IGNORECASE))
            sidebar_depth += opens - closes
            
            if sidebar_depth <= 0:
                in_sidebar = False
                sidebar_end_line = i
            continue
        
        result_lines.append(line)
    
    modified_content = '\n'.join(result_lines)
    was_modified = len(result_lines) < len(lines)
    
    return modified_content, was_modified

def process_file(filepath):
    """
    Verarbeitet eine einzelne HTML-Datei.
    
    Returns:
        bool: True wenn Datei modifiziert wurde
    """
    filename = filepath.name
    
    # Skip-Checks
    if filename in SKIP_FILES:
        log(f"SKIP: {filename} (in Skip-Liste)", "DEBUG")
        return False
    
    if filename.startswith(SKIP_PREFIXES):
        log(f"SKIP: {filename} (Subform)", "DEBUG")
        return False
    
    if not filename.endswith('.html'):
        return False
    
    try:
        # Datei lesen (BOM-tolerant)
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            original_content = f.read()
        
        original_size = len(original_content)
        
        # Prüfen ob Sidebar vorhanden
        if 'class="left-menu"' not in original_content:
            log(f"SKIP: {filename} - Keine Sidebar vorhanden", "DEBUG")
            return False
        
        # Backup erstellen
        BACKUP_DIR.mkdir(exist_ok=True)
        backup_file = BACKUP_DIR / f"{filename}.backup"
        if not backup_file.exists():
            shutil.copy2(filepath, backup_file)
            log(f"Backup erstellt: {backup_file.name}", "DEBUG")
        
        # Sidebar extrahieren
        modified_content, was_modified = extract_sidebar_from_html(original_content)
        
        if was_modified:
            # Modifizierte Datei speichern
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            
            new_size = len(modified_content)
            diff = original_size - new_size
            log(f"OK: {filename} - Sidebar entfernt ({original_size:,} -> {new_size:,} bytes, -{diff:,})", "SUCCESS")
            return True
        else:
            log(f"UNCHANGED: {filename} - Keine Änderung", "DEBUG")
            return False
            
    except Exception as e:
        log(f"ERROR: {filename} - {str(e)}", "ERROR")
        import traceback
        traceback.print_exc()
        return False

def create_sidebar_html():
    """Erstellt die zentrale sidebar.html Datei."""
    sidebar_content = '''<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CONSYS Sidebar</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 11px;
        }

        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            height: 100vh;
        }

        .left-menu {
            width: 185px;
            height: 100vh;
            background-color: #6060a0;
            padding: 5px;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            flex-shrink: 0;
        }

        .menu-header {
            background-color: #000080;
            color: white;
            padding: 6px;
            text-align: center;
            font-weight: bold;
            font-size: 12px;
            margin-bottom: 8px;
        }

        .menu-buttons {
            display: flex;
            flex-direction: column;
            flex: 1;
            gap: 2px;
        }

        .menu-btn {
            background: linear-gradient(to bottom, #d0d0e0, #a0a0c0);
            padding: 8px 10px;
            text-align: center;
            cursor: pointer;
            font-size: 12px;
            color: #000;
            font-weight: 500;
            position: relative;
            border: none;
            margin: 1px 0;
            overflow: visible;
        }

        .menu-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: calc(100% - 4px);
            height: 2px;
            background: #ffffff;
            z-index: 1;
        }

        .menu-btn::after {
            content: '';
            position: absolute;
            bottom: 0;
            right: 0;
            width: calc(100% - 4px);
            height: 2px;
            background: #404070;
            z-index: 1;
        }

        .menu-btn:hover {
            background: linear-gradient(to bottom, #e0e0f0, #b0b0d0);
        }

        .menu-btn:active {
            background: linear-gradient(to bottom, #b0b0d0, #9090b0);
        }

        .menu-btn:active::before {
            background: #404070;
            left: 4px;
            width: calc(100% - 4px);
        }

        .menu-btn:active::after {
            background: #ffffff;
            right: 4px;
            width: calc(100% - 4px);
        }

        .menu-btn.active {
            background: linear-gradient(to bottom, #a0a0d0, #8080b0);
        }

        .menu-btn.active::before {
            background: #505080;
            left: 4px;
            width: calc(100% - 4px);
        }

        .menu-btn.active::after {
            background: #c0c0d8;
            right: 4px;
            width: calc(100% - 4px);
        }
    </style>
</head>
<body>
    <div class="left-menu">
        <div>
            <div class="menu-header">HAUPTMENÜ</div>
        </div>
        <div class="menu-buttons">
            <button class="menu-btn" data-form="frm_N_Dienstplanuebersicht">Dienstplanübersicht</button>
            <button class="menu-btn" data-form="frm_DP_Dienstplan_Objekt">Planungsübersicht</button>
            <button class="menu-btn" data-form="frm_va_Auftragstamm">Auftragsverwaltung</button>
            <button class="menu-btn" data-form="frm_MA_Mitarbeiterstamm">Mitarbeiterverwaltung</button>
            <button class="menu-btn" data-form="frm_MA_Offene_Anfragen">Offene Mail Anfragen</button>
            <button class="menu-btn" data-form="frm_MA_Zeitkonten">Excel Zeitkonten</button>
            <button class="menu-btn" data-form="frm_MA_Zeitkonten">Zeitkonten</button>
            <button class="menu-btn" data-form="frmTop_MA_Abwesenheitsplanung">Abwesenheitsplanung</button>
            <button class="menu-btn" data-form="frm_Ausweis_Create">Dienstausweis erstellen</button>
            <button class="menu-btn" data-form="frm_N_Stundenauswertung">Stundenabgleich</button>
            <button class="menu-btn" data-form="frm_KD_Kundenstamm">Kundenverwaltung</button>
            <button class="menu-btn" data-form="frm_OB_Objekt">Objektverwaltung</button>
            <button class="menu-btn" data-form="frm_Verrechnungssaetze">Verrechnungssätze</button>
            <button class="menu-btn" data-form="frm_SubRechnungen">Sub Rechnungen</button>
            <button class="menu-btn" data-form="frmOff_Outlook_aufrufen">E-Mail</button>
            <button class="menu-btn" data-form="frm_Menuefuehrung1">Menü 2</button>
            <button class="menu-btn" data-form="frm_SystemInfo">System Info</button>
        </div>
    </div>

    <script>
        // Sidebar Navigation Handler
        document.querySelectorAll('.menu-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const formName = this.dataset.form;
                if (!formName) return;
                
                // Aktiven Button markieren
                document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                
                // Navigation via PostMessage an Parent (Shell)
                if (window.parent !== window) {
                    window.parent.postMessage({
                        type: 'SIDEBAR_NAVIGATE',
                        form: formName
                    }, '*');
                }
            });
        });

        // Aktives Formular von Shell empfangen
        window.addEventListener('message', function(event) {
            if (event.data.type === 'SET_ACTIVE_FORM') {
                const formName = event.data.form;
                document.querySelectorAll('.menu-btn').forEach(btn => {
                    const btnForm = btn.dataset.form;
                    const isActive = btnForm === formName || 
                                     btnForm === 'frm_' + formName ||
                                     btnForm.replace('frm_', '') === formName.replace('frm_', '');
                    btn.classList.toggle('active', isActive);
                });
            }
        });

        console.log('[Sidebar] Initialisiert');
    </script>
</body>
</html>'''
    
    sidebar_path = FORMS_PATH / "sidebar.html"
    with open(sidebar_path, 'w', encoding='utf-8') as f:
        f.write(sidebar_content)
    
    log(f"Sidebar erstellt: {sidebar_path}", "SUCCESS")

def main():
    """Hauptfunktion"""
    # Log initialisieren
    with open(LOG_FILE, 'w', encoding='utf-8') as f:
        f.write(f"Sidebar Extraction Log - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=" * 70 + "\n\n")
    
    log("=" * 60)
    log("SIDEBAR EXTRACTION GESTARTET")
    log(f"Quellordner: {FORMS_PATH}")
    log("=" * 60)
    
    # 1. Sidebar.html erstellen
    log("\n[Phase 1] Erstelle sidebar.html...")
    create_sidebar_html()
    
    # 2. Alle HTML-Dateien verarbeiten
    log("\n[Phase 2] Verarbeite HTML-Formulare...")
    
    html_files = list(FORMS_PATH.glob("*.html"))
    processed = 0
    modified = 0
    skipped = 0
    
    for filepath in sorted(html_files):
        processed += 1
        result = process_file(filepath)
        if result:
            modified += 1
        elif filepath.name not in SKIP_FILES:
            skipped += 1
    
    # 3. Zusammenfassung
    log("\n" + "=" * 60)
    log("ZUSAMMENFASSUNG")
    log("=" * 60)
    log(f"Dateien verarbeitet: {processed}")
    log(f"Dateien modifiziert: {modified}")
    log(f"Dateien übersprungen: {skipped}")
    log(f"Backups in: {BACKUP_DIR}")
    log(f"Log-Datei: {LOG_FILE}")
    log("=" * 60)
    
    print(f"\n✅ Fertig! {modified} Formulare modifiziert.")
    print(f"📁 Backups: {BACKUP_DIR}")
    print(f"📄 Log: {LOG_FILE}")

if __name__ == "__main__":
    main()
