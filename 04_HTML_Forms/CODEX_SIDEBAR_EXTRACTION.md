# Codex CLI Arbeitsanweisung: Sidebar-Extraktion und Shell-Integration

## ZIEL
Extrahiere die Sidebar (`.left-menu`) aus allen HTML-Formularen im Ordner `forms/` und binde sie als separates `sidebar.html` Formular über die Shell (`shell.html`) ein.

## BERECHTIGUNGEN
✅ **FULL AUTO-EXECUTE MODE** - Alle Aktionen ohne Rückfrage ausführen
- Dateien lesen/schreiben/erstellen/löschen: JA
- Scripts ausführen: JA  
- PowerShell/Bash: JA
- Keine Bestätigungen erforderlich

## WORKSPACE
```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\
├── forms/                    # Quell-HTML-Formulare
├── shell.html               # Haupt-Shell für iframe-Navigation
├── js/                      # JavaScript-Dateien
└── css/                     # CSS-Dateien
```

---

## PHASE 1: Analyse und Extraktion

### 1.1 Sidebar-Struktur identifizieren
Die Sidebar in jedem HTML-Formular hat folgende Struktur:
```html
<div class="left-menu">
    <div>
        <div class="menu-header">HAUPTMENÜ</div>  <!-- oder HAUPTMENUE -->
    </div>
    <div class="menu-buttons">
        <button class="menu-btn" data-form="frm_xxx">Button Text</button>
        <!-- weitere menu-btn Elemente -->
    </div>
</div>
```

### 1.2 CSS-Klassen für Sidebar
Folgende CSS-Klassen gehören zur Sidebar:
- `.left-menu`
- `.menu-header`
- `.menu-buttons`
- `.menu-btn` (inkl. `:hover`, `:active`, `.active`, `::before`, `::after`)

---

## PHASE 2: Sidebar-Komponente erstellen

### 2.1 Erstelle `forms/sidebar.html`
```html
<!DOCTYPE html>
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

        /* Left Menu */
        .left-menu {
            width: 185px;
            height: 100vh;
            background-color: #6060a0;
            padding: 5px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
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
            justify-content: flex-start;
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
            <button class="menu-btn" data-form="frm_Abwesenheiten">Abwesenheitsplanung</button>
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
                
                // Fallback: ConsysShell direkt
                if (window.parent.ConsysShell) {
                    window.parent.ConsysShell.showForm(formName.replace('frm_', '').replace('_', '').toLowerCase());
                }
            });
        });

        // Aktives Formular von Shell empfangen
        window.addEventListener('message', function(event) {
            if (event.data.type === 'SET_ACTIVE_FORM') {
                const formName = event.data.form;
                document.querySelectorAll('.menu-btn').forEach(btn => {
                    const isActive = btn.dataset.form === formName || 
                                     btn.dataset.form === 'frm_' + formName;
                    btn.classList.toggle('active', isActive);
                });
            }
        });

        console.log('[Sidebar] Initialisiert');
    </script>
</body>
</html>
```

---

## PHASE 3: HTML-Formulare modifizieren

### 3.1 PowerShell-Script erstellen: `extract_sidebar.ps1`

```powershell
# extract_sidebar.ps1
# Entfernt Sidebar aus allen HTML-Formularen und passt Layout an

$formsPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms"
$logFile = "$formsPath\sidebar_extraction_log.txt"

# Logging initialisieren
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Sidebar Extraction gestartet" | Out-File $logFile

# Alle HTML-Dateien im forms Ordner
$htmlFiles = Get-ChildItem -Path $formsPath -Filter "*.html" -File | 
    Where-Object { $_.Name -ne "sidebar.html" -and $_.Name -ne "index.html" }

foreach ($file in $htmlFiles) {
    Write-Host "Verarbeite: $($file.Name)" -ForegroundColor Cyan
    
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $originalLength = $content.Length
        $modified = $false
        
        # Pattern für left-menu DIV (inkl. Inhalt)
        # Regex: <div class="left-menu">...</div> bis zum schließenden Tag
        $sidebarPattern = '(?s)<div class="left-menu">.*?</div>\s*(?=<div class="content-area">|<!-- Content)'
        
        if ($content -match '<div class="left-menu">') {
            # Sidebar entfernen
            $content = $content -replace $sidebarPattern, ''
            
            # CSS für left-menu entfernen (optional, kann beibehalten werden)
            # Nur wenn inline CSS vorhanden
            
            # .main-container Layout anpassen: flex-start statt space-between
            # Da Sidebar weg ist, brauchen wir kein Flex mehr
            
            # Prüfen ob Änderung stattfand
            if ($content.Length -ne $originalLength) {
                $modified = $true
            }
        }
        
        # Falls noch alte Sidebar-Patterns vorhanden
        if ($content -match 'class="menu-btn".*data-form=') {
            # Diese sind jetzt in sidebar.html
        }
        
        if ($modified) {
            # Backup erstellen
            $backupPath = "$($file.FullName).sidebar_backup"
            if (-not (Test-Path $backupPath)) {
                Copy-Item $file.FullName $backupPath
            }
            
            # Modifizierte Datei speichern
            $content | Set-Content -Path $file.FullName -Encoding UTF8 -NoNewline
            
            "$(Get-Date -Format 'HH:mm:ss') - $($file.Name): Sidebar entfernt (${originalLength} -> $($content.Length) bytes)" | 
                Add-Content $logFile
            Write-Host "  ✓ Sidebar entfernt" -ForegroundColor Green
        } else {
            "$(Get-Date -Format 'HH:mm:ss') - $($file.Name): Keine Sidebar gefunden oder bereits entfernt" | 
                Add-Content $logFile
            Write-Host "  - Keine Änderung nötig" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "  ✗ Fehler: $_" -ForegroundColor Red
        "$(Get-Date -Format 'HH:mm:ss') - $($file.Name): FEHLER - $_" | Add-Content $logFile
    }
}

"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Sidebar Extraction abgeschlossen" | Add-Content $logFile
Write-Host "`nFertig! Log: $logFile" -ForegroundColor Green
```

### 3.2 Detailliertes Python-Script (Alternative): `extract_sidebar.py`

```python
#!/usr/bin/env python3
# extract_sidebar.py
# Präzise Sidebar-Extraktion mit BeautifulSoup

import os
import re
import shutil
from pathlib import Path
from datetime import datetime

FORMS_PATH = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms")
LOG_FILE = FORMS_PATH / "sidebar_extraction_log.txt"
BACKUP_DIR = FORMS_PATH / "_sidebar_backups"

# Skip-Liste für Dateien die nicht modifiziert werden sollen
SKIP_FILES = {'sidebar.html', 'index.html', 'test_ie.html', 'webview2_test.html'}

def log(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%mm:%S')
    line = f"{timestamp} - {message}"
    print(line)
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(line + '\n')

def extract_sidebar_from_html(html_content):
    """
    Entfernt die Sidebar (left-menu) aus dem HTML und gibt modifizierten Content zurück.
    """
    # Pattern 1: Komplettes left-menu div mit allen Kindern
    # Berücksichtigt verschachtelte divs
    pattern_sidebar = r'''
        <div\s+class="left-menu"[^>]*>  # Opening tag
        (?:                               # Non-capturing group für Inhalt
            (?!<div\s+class="left-menu")  # Negative lookahead
            [\s\S]                        # Any character
        )*?                               # Non-greedy
        </div>                            # Passendes closing tag
        \s*                               # Optional whitespace
    '''
    
    # Einfacheres Pattern das funktioniert:
    # Findet <div class="left-menu"> und entfernt bis zum Content-Bereich
    
    # Strategie: Zeilenweise verarbeiten
    lines = html_content.split('\n')
    result_lines = []
    in_sidebar = False
    sidebar_depth = 0
    
    for line in lines:
        # Start der Sidebar erkennen
        if 'class="left-menu"' in line:
            in_sidebar = True
            sidebar_depth = 1
            continue
        
        if in_sidebar:
            # Zähle öffnende/schließende divs
            opens = len(re.findall(r'<div\b', line))
            closes = len(re.findall(r'</div>', line))
            sidebar_depth += opens - closes
            
            if sidebar_depth <= 0:
                in_sidebar = False
            continue
        
        result_lines.append(line)
    
    return '\n'.join(result_lines)

def remove_sidebar_css(html_content):
    """
    Optional: Entfernt Sidebar-bezogene CSS-Regeln aus dem <style> Block.
    VORSICHT: Nur ausführen wenn CSS nicht von anderen Elementen gebraucht wird.
    """
    # CSS-Klassen die zur Sidebar gehören
    sidebar_css_patterns = [
        r'/\*\s*Left Menu\s*\*/[\s\S]*?(?=/\*|</style>)',
        r'\.left-menu\s*\{[^}]*\}',
        r'\.menu-header\s*\{[^}]*\}',
        r'\.menu-buttons\s*\{[^}]*\}',
        r'\.menu-btn[^{]*\{[^}]*\}',
    ]
    
    # NICHT ausführen - CSS bleibt für Kompatibilität
    return html_content

def process_file(filepath):
    """Verarbeitet eine einzelne HTML-Datei."""
    filename = filepath.name
    
    if filename in SKIP_FILES:
        log(f"SKIP: {filename}")
        return False
    
    try:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            original_content = f.read()
        
        # Prüfen ob Sidebar vorhanden
        if 'class="left-menu"' not in original_content:
            log(f"SKIP: {filename} - Keine Sidebar gefunden")
            return False
        
        # Backup erstellen
        BACKUP_DIR.mkdir(exist_ok=True)
        backup_file = BACKUP_DIR / f"{filename}.backup"
        if not backup_file.exists():
            shutil.copy2(filepath, backup_file)
        
        # Sidebar extrahieren
        modified_content = extract_sidebar_from_html(original_content)
        
        # Nur speichern wenn tatsächlich geändert
        if modified_content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            
            orig_size = len(original_content)
            new_size = len(modified_content)
            diff = orig_size - new_size
            log(f"OK: {filename} - Sidebar entfernt ({orig_size} -> {new_size} bytes, -{diff})")
            return True
        else:
            log(f"UNCHANGED: {filename}")
            return False
            
    except Exception as e:
        log(f"ERROR: {filename} - {str(e)}")
        return False

def main():
    log("=" * 60)
    log("Sidebar Extraction gestartet")
    log("=" * 60)
    
    html_files = list(FORMS_PATH.glob("*.html"))
    processed = 0
    modified = 0
    
    for filepath in sorted(html_files):
        processed += 1
        if process_file(filepath):
            modified += 1
    
    log("-" * 60)
    log(f"Fertig: {processed} Dateien verarbeitet, {modified} modifiziert")
    log(f"Backups in: {BACKUP_DIR}")

if __name__ == "__main__":
    main()
```

---

## PHASE 4: Shell anpassen

### 4.1 Modifizierte `shell.html` mit Sidebar-Frame

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CONSYS - Shell</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body {
            height: 100%;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow: hidden;
        }

        .shell-container {
            display: flex;
            height: 100vh;
            width: 100%;
        }

        /* Sidebar Frame - Fest links */
        #sidebarFrame {
            width: 185px;
            height: 100%;
            border: none;
            flex-shrink: 0;
        }

        /* Content Frame Container */
        .frame-container {
            flex: 1;
            position: relative;
            overflow: hidden;
            background: #8080c0;
        }

        .form-frame {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
            display: none;
            background: #f0f0f0;
        }

        .form-frame.active {
            display: block;
            z-index: 10;
        }

        /* Loading Overlay */
        #loadingOverlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #4316B2;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            color: white;
        }

        #loadingOverlay.hidden { display: none; }

        .loading-logo { font-size: 32px; font-weight: 700; margin-bottom: 20px; }
        .loading-text { font-size: 14px; margin-bottom: 10px; }
        .loading-progress {
            width: 300px;
            height: 6px;
            background: rgba(255,255,255,0.3);
            border-radius: 3px;
            overflow: hidden;
        }
        .loading-bar {
            height: 100%;
            background: white;
            width: 0%;
            transition: width 0.2s;
        }
        .loading-status { font-size: 11px; margin-top: 10px; opacity: 0.8; }
    </style>
</head>
<body>
    <div id="loadingOverlay">
        <div class="loading-logo">CONSYS</div>
        <div class="loading-text">Formulare werden geladen...</div>
        <div class="loading-progress">
            <div class="loading-bar" id="loadingBar"></div>
        </div>
        <div class="loading-status" id="loadingStatus">Initialisiere...</div>
    </div>

    <div class="shell-container">
        <!-- Sidebar als separater iframe -->
        <iframe id="sidebarFrame" src="forms/sidebar.html"></iframe>
        
        <!-- Content Frames -->
        <div class="frame-container" id="frameContainer">
            <!-- Frames werden dynamisch eingefügt -->
        </div>
    </div>

    <script>
    const ConsysShell = {
        forms: [
            { id: 'mitarbeiterstamm', file: 'frm_MA_Mitarbeiterstamm.html', formName: 'frm_MA_Mitarbeiterstamm' },
            { id: 'kunden', file: 'frm_KD_Kundenstamm.html', formName: 'frm_KD_Kundenstamm' },
            { id: 'auftraege', file: 'frm_va_Auftragstamm.html', formName: 'frm_va_Auftragstamm' },
            { id: 'dienstplan', file: 'frm_N_Dienstplanuebersicht.html', formName: 'frm_N_Dienstplanuebersicht' },
            { id: 'planungsuebersicht', file: 'frm_DP_Dienstplan_Objekt.html', formName: 'frm_DP_Dienstplan_Objekt' },
            { id: 'zeitkonten', file: 'frm_MA_Zeitkonten.html', formName: 'frm_MA_Zeitkonten' },
            { id: 'abwesenheiten', file: 'frm_Abwesenheiten.html', formName: 'frm_Abwesenheiten' },
            { id: 'stundenauswertung', file: 'frm_N_Stundenauswertung.html', formName: 'frm_N_Stundenauswertung' },
            { id: 'objekt', file: 'frm_OB_Objekt.html', formName: 'frm_OB_Objekt' },
            { id: 'email', file: 'frmOff_Outlook_aufrufen.html', formName: 'frmOff_Outlook_aufrufen' },
        ],
        
        loadedCount: 0,
        activeFormId: null,
        frames: {},

        init() {
            this.preloadAllForms();
            this.setupMessageHandler();
        },

        setupMessageHandler() {
            window.addEventListener('message', (event) => {
                if (event.data.type === 'SIDEBAR_NAVIGATE') {
                    this.navigateByFormName(event.data.form);
                }
            });
        },

        navigateByFormName(formName) {
            const form = this.forms.find(f => 
                f.formName === formName || 
                f.formName === 'frm_' + formName ||
                f.file.replace('.html', '') === formName
            );
            
            if (form) {
                this.showForm(form.id);
            } else {
                console.warn('Form nicht gefunden:', formName);
            }
        },

        preloadAllForms() {
            const container = document.getElementById('frameContainer');
            const total = this.forms.length;

            this.forms.forEach((form, index) => {
                const iframe = document.createElement('iframe');
                iframe.id = 'frame_' + form.id;
                iframe.className = 'form-frame';
                iframe.src = 'forms/' + form.file;
                iframe.dataset.formId = form.id;

                iframe.onload = () => {
                    this.loadedCount++;
                    this.updateLoadingProgress(this.loadedCount, total, form.file);
                    
                    if (this.loadedCount === total) {
                        this.onAllFormsLoaded();
                    }
                };

                iframe.onerror = () => {
                    console.error('Fehler beim Laden:', form.file);
                    this.loadedCount++;
                    if (this.loadedCount === total) {
                        this.onAllFormsLoaded();
                    }
                };

                container.appendChild(iframe);
                this.frames[form.id] = iframe;
            });
        },

        updateLoadingProgress(loaded, total, currentFile) {
            const percent = Math.round((loaded / total) * 100);
            document.getElementById('loadingBar').style.width = percent + '%';
            document.getElementById('loadingStatus').textContent = 
                loaded + '/' + total + ' - ' + currentFile;
        },

        onAllFormsLoaded() {
            setTimeout(() => {
                document.getElementById('loadingOverlay').classList.add('hidden');
                const startForm = this.getStartFormFromURL() || 'mitarbeiterstamm';
                this.showForm(startForm);
                console.log('CONSYS Shell: ' + this.forms.length + ' Formulare geladen');
            }, 300);
        },

        getStartFormFromURL() {
            const params = new URLSearchParams(window.location.search);
            return params.get('form');
        },

        showForm(formId) {
            if (this.activeFormId && this.frames[this.activeFormId]) {
                this.frames[this.activeFormId].classList.remove('active');
            }

            if (this.frames[formId]) {
                this.frames[formId].classList.add('active');
                this.activeFormId = formId;

                // URL aktualisieren
                const url = new URL(window.location);
                url.searchParams.set('form', formId);
                window.history.replaceState({}, '', url);

                // Sidebar über aktives Formular informieren
                const form = this.forms.find(f => f.id === formId);
                if (form) {
                    const sidebarFrame = document.getElementById('sidebarFrame');
                    if (sidebarFrame.contentWindow) {
                        sidebarFrame.contentWindow.postMessage({
                            type: 'SET_ACTIVE_FORM',
                            form: form.formName
                        }, '*');
                    }
                }
            }
        }
    };

    window.ConsysShell = ConsysShell;
    document.addEventListener('DOMContentLoaded', () => ConsysShell.init());
    </script>
</body>
</html>
```

---

## PHASE 5: Ausführungsreihenfolge

### Schritt-für-Schritt Anleitung für Codex:

```bash
# 1. Backup erstellen
mkdir -p "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\_sidebar_backups"

# 2. sidebar.html erstellen (Code aus Phase 2.1)

# 3. Python-Script ausführen ODER PowerShell-Script
python extract_sidebar.py
# ODER
powershell -ExecutionPolicy Bypass -File extract_sidebar.ps1

# 4. shell.html ersetzen mit neuer Version (Code aus Phase 4.1)

# 5. Testen: shell.html im Browser öffnen
```

---

## VALIDIERUNG

Nach Ausführung prüfen:

1. ✅ `forms/sidebar.html` existiert
2. ✅ `forms/_sidebar_backups/` enthält Originaldateien  
3. ✅ HTML-Formulare haben kein `<div class="left-menu">` mehr
4. ✅ `shell.html` zeigt Sidebar links und Content rechts
5. ✅ Navigation zwischen Formularen funktioniert

---

## ROLLBACK

Falls Probleme auftreten:

```powershell
# Alle Backups wiederherstellen
$backupDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\_sidebar_backups"
$formsDir = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms"

Get-ChildItem $backupDir -Filter "*.backup" | ForEach-Object {
    $targetName = $_.Name -replace '\.backup$', ''
    Copy-Item $_.FullName "$formsDir\$targetName" -Force
    Write-Host "Restored: $targetName"
}
```

---

## HINWEISE

- Die Sidebar-CSS-Regeln bleiben in den Formularen (schadet nicht, erleichtert Rollback)
- Menu-Buttons in den Formularen werden ignoriert (ohne Sidebar nicht sichtbar)
- `consys-common.css` wird nicht modifiziert
- Subforms (`sub_*.html`) haben keine Sidebar - werden übersprungen
