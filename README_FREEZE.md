# Claude Code Freeze-Schutzsystem

## Uebersicht

Das Freeze-System schuetzt stabile, getestete Dateien und Funktionen vor unbeabsichtigten Aenderungen durch Claude Code oder andere Prozesse.

**Erstellt:** 2026-01-28
**OS:** Linux (Ubuntu 24.04)
**Version:** 1.0.0

---

## Schnellstart

```bash
# Alle eingefrorenen Dateien anzeigen
./scripts/freeze-list.sh

# Pruefen ob eine Datei eingefroren ist
./scripts/freeze-check.sh 04_HTML_Forms/forms3/css/style.css

# Datei einfrieren
./scripts/freeze.sh 04_HTML_Forms/forms3/css/style.css "Header fertig"

# Datei auftauen (nur mit Begruendung!)
./scripts/unfreeze.sh 04_HTML_Forms/forms3/css/style.css
```

---

## Dateistruktur

```
All_Access_KNOWLEDGE/
├── claude.freeze.json       # Zentrale Freeze-Datenbank
├── README_FREEZE.md         # Diese Dokumentation
├── scripts/
│   ├── freeze.sh            # Datei einfrieren
│   ├── unfreeze.sh          # Datei auftauen
│   ├── freeze-check.sh      # Prueft Freeze-Status
│   └── freeze-list.sh       # Zeigt alle eingefrorenen
├── stable/                  # Stabile Backup-Versionen
│   └── README.md
├── experiments/             # Testbereich fuer Aenderungen
│   └── README.md
└── .claude/
    └── settings.local.json  # Claude Code Konfiguration mit Freeze-Hooks
```

---

## Komponenten

### 1. claude.freeze.json

Die zentrale Datenbank mit allen eingefrorenen Elementen:

```json
{
  "frozenFiles": [
    {
      "path": "pfad/zur/datei.css",
      "reason": "Grund fuer Freeze",
      "frozenAt": "2026-01-28",
      "frozenBy": "Username"
    }
  ],
  "frozenPatterns": [
    {
      "pattern": "04_HTML_Forms/forms3/frm_*.html",
      "reason": "Alle Formulare geschuetzt"
    }
  ],
  "frozenFunctions": [
    {
      "file": "pfad/zur/datei.js",
      "function": "functionName",
      "reason": "Kritische Funktion"
    }
  ],
  "protectedBlocks": [
    {
      "file": "pfad/zur/datei.js",
      "startMarker": "// PROTECTED START",
      "endMarker": "// PROTECTED END",
      "reason": "Geschuetzter Code-Block"
    }
  ]
}
```

### 2. Skripte

#### freeze.sh - Datei einfrieren
```bash
./scripts/freeze.sh <pfad> [grund]

# Beispiele:
./scripts/freeze.sh css/style.css "Layout fertig"
./scripts/freeze.sh api_server.py "API stabil"
```

**Was passiert:**
1. Setzt Datei auf Read-Only (chmod a-w)
2. Fuegt Eintrag zu claude.freeze.json hinzu
3. Erstellt Backup in stable/

#### unfreeze.sh - Datei auftauen
```bash
./scripts/unfreeze.sh <pfad>

# Beispiel:
./scripts/unfreeze.sh css/style.css
```

**Was passiert:**
1. Fragt nach Bestaetigung ("ja")
2. Entfernt Read-Only (chmod u+w)
3. Entfernt Eintrag aus claude.freeze.json

#### freeze-check.sh - Status pruefen
```bash
./scripts/freeze-check.sh <pfad>

# Exit-Codes:
# 0 = Nicht eingefroren (Aenderung erlaubt)
# 1 = EINGEFROREN (STOPP!)
# 2 = Fehler
```

#### freeze-list.sh - Alle anzeigen
```bash
./scripts/freeze-list.sh

# Zeigt:
# - Eingefrorene Dateien
# - Eingefrorene Patterns
# - Geschuetzte Bloecke
# - Geschuetzte API Endpoints
# - Geschuetzte VBA Buttons
```

### 3. stable/ Verzeichnis

Enthaelt stabile Backup-Versionen von Dateien:

```
stable/
├── style.css_2026-01-28
├── api_server.py_2026-01-28
└── README.md
```

**Namenskonvention:** `dateiname_YYYY-MM-DD`

### 4. experiments/ Verzeichnis

Testbereich fuer Aenderungen bevor sie ins Projekt uebernommen werden:

```
experiments/
├── test_new_header_2026-01-28/
│   ├── original.css
│   ├── modified.css
│   └── notes.txt
└── README.md
```

---

## PROTECTED-Bloecke

Code zwischen PROTECTED-Markern darf NICHT geaendert werden:

### JavaScript/CSS
```javascript
// PROTECTED START - Beschreibung
function criticalFunction() {
  // Dieser Code ist geschuetzt
}
// PROTECTED END - Beschreibung
```

### HTML
```html
<!-- PROTECTED START - Header Layout -->
<div class="header">
  <!-- Geschuetzter Header -->
</div>
<!-- PROTECTED END - Header Layout -->
```

### Python
```python
# PROTECTED START - API Authentication
def authenticate_user():
    # Geschuetzter Code
    pass
# PROTECTED END - API Authentication
```

---

## Workflow fuer Aenderungen

### Vor jeder Aenderung

```
┌─────────────────────────────────────────┐
│ 1. FREEZE-CHECK                         │
│    ./scripts/freeze-check.sh <datei>    │
│                                         │
│    Exit 0 → Weiter zu Schritt 2         │
│    Exit 1 → STOPP! User fragen!         │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 2. PROTECTED-BLOCK CHECK                │
│    Ist Aenderung in PROTECTED-Block?    │
│                                         │
│    Nein → Weiter zu Schritt 3           │
│    Ja   → STOPP! User fragen!           │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 3. EXPERIMENT-FIRST (bei grossen        │
│    Aenderungen)                         │
│    - Kopie nach experiments/            │
│    - Dort testen                        │
│    - Bei Erfolg: weiter                 │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 4. AENDERUNG DURCHFUEHREN               │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 5. TESTEN                               │
│    - Browser-Test                       │
│    - Console-Check                      │
│    - API-Test                           │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 6. FREEZE-FRAGE                         │
│    "Funktioniert? Soll ich einfrieren?" │
│                                         │
│    Ja  → ./scripts/freeze.sh            │
│    Nein → Anpassungen vornehmen         │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ 7. DOKUMENTIEREN                        │
│    - CLAUDE2.md aktualisieren           │
│    - Aenderung beschreiben              │
└─────────────────────────────────────────┘
```

---

## Aktuell eingefrorene Elemente

### Dateien (aus claude.freeze.json)

| Datei | Grund | Datum |
|-------|-------|-------|
| 04_HTML_Forms/forms3/css/form-titles.css | Header-Styling 15px schwarz | 2026-01-16 |
| 04_HTML_Forms/forms3/css/unified-header.css | Unified Header | 2026-01-16 |
| 06_Server/api_server.py | API Server - kritische Infrastruktur | 2026-01-28 |
| 04_HTML_Forms/forms3/_scripts/mini_api.py | VBA-API | 2026-01-28 |

### Patterns

| Pattern | Grund |
|---------|-------|
| 04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html | Header-korrigiertes Formular |
| 04_HTML_Forms/forms3/frm_DP_Dienstplan_*.html | Dienstplan-Formulare |
| exports/vba/**/*.bas | VBA-Exports - nur lesen |

### Geschuetzte API Endpoints

- /api/auftraege/<va_id>/schichten
- /api/auftraege/<va_id>/zuordnungen
- /api/auftraege/<va_id>/absagen

### Geschuetzte VBA Buttons

btn_ListeStd, btnDruckZusage, btnMailEins, btnMailBOS, btnMailSub, cmdAuftragKopieren, cmdAuftragLoeschen, btn_BWN_Druck, cmd_BWN_send

---

## Regeln fuer zukuenftige Sessions

### MUSS-Regeln (IMMER befolgen)

1. **FREEZE-CHECK VOR JEDER AENDERUNG**
   ```bash
   ./scripts/freeze-check.sh <datei>
   ```

2. **NIE frozenFiles ueberschreiben** ohne explizite User-Erlaubnis

3. **NIE PROTECTED-Bloecke aendern**

4. **NIE neverModify-Dateien aendern:**
   - claude.freeze.json
   - CLAUDE.md
   - .claude/settings.local.json

5. **IMMER nachfragen** bei alwaysAskBefore-Dateien:
   - *.css
   - *.html
   - **/logic/*.js
   - **/*api*.py

### SOLL-Regeln (Best Practice)

1. Grosse Aenderungen ZUERST in experiments/ testen
2. Nach erfolgreichem Test Kopie nach stable/
3. Dann erst ins Projekt uebernehmen
4. Nach jeder erfolgreichen Aenderung Freeze-Frage stellen

---

## Troubleshooting

### "Permission denied" beim Bearbeiten
→ Datei ist eingefroren. Pruefe mit:
```bash
./scripts/freeze-check.sh <datei>
```

### jq nicht installiert
Die Skripte funktionieren auch ohne jq, aber mit eingeschraenkter Funktionalitaet.
```bash
# Installation (Ubuntu/Debian):
sudo apt install jq
```

### Falsches Einfrieren rueckgaengig machen
```bash
./scripts/unfreeze.sh <datei>
# Bestaetigung mit "ja" eingeben
```

### Backup wiederherstellen
```bash
cp stable/<datei>_<datum> <original-pfad>
```

---

## Kontakt

Bei Fragen oder Problemen mit dem Freeze-System:
- CLAUDE2.md pruefen
- CLAUDE.md Freeze-Abschnitt lesen
- Guenther fragen

---

**Letzte Aktualisierung:** 2026-01-28
