# Claude Code Anweisungen - CONSYS Projekt

## HOECHSTE PRIORITAET: SICHTBAR TESTEN VOR FERTIGMELDUNG!

**JEDE erledigte Anweisung MUSS vor Fertigmeldung:**

1. **GEPRUEFT** werden - Code/Aenderung nochmal durchgehen
2. **SICHTBAR GETESTET** werden - Mit Playwright/DevTools/Browser LIVE verifizieren
3. **SCREENSHOT oder LOG** als Beweis - Nicht nur API-Response, sondern echte UI-Pruefung
4. **Erst bei ERFOLGREICHEN sichtbaren Tests** als erledigt melden

**VERBOTEN:**
- Aufgabe als "fertig" oder "erledigt" bezeichnen OHNE sichtbaren Test!
- Nur Datenbank/API pruefen ohne zu verifizieren dass die Aktion wirklich ausgefuehrt wurde
- "Erfolg" melden basierend auf API-Response ohne Live-Pruefung im Browser

**PFLICHT bei Funktionstests:**
- Playwright MCP verwenden um Seite zu oeffnen und Aktion durchzufuehren
- Chrome DevTools MCP fuer DOM/Netzwerk-Analyse
- Screenshots machen als Beweis
- Console-Logs pruefen auf Fehler

---

## KURZBEFEHL: kk (Screenshot aus Zwischenablage)

### TRIGGER
Wenn Guenther nur **"kk"** eingibt:

### AKTION
1. **PowerShell-Skript ausfuehren** um Screenshot aus Zwischenablage zu speichern:
   ```bash
   powershell -ExecutionPolicy Bypass -File "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\clipboard_screenshot.ps1"
   ```

2. **Screenshot einlesen und anzeigen:**
   ```bash
   view "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\temp_screenshot.png"
   ```

3. **Warten** auf Guenthers Kommentar/Anweisung zum Bild (KEINE Nachfrage!)

---

## AUTOMATISCHE SKILL & MCP AKTIVIERUNG (PFLICHT!)

**KEINE RUECKFRAGE** - Bei jeder Aufgabe selbststaendig die passenden Skills und MCP-Server aktivieren.

---

## PFLICHT: FREEZE-NACHFRAGE NACH JEDER HTML-AENDERUNG

**Nach JEDER abgeschlossenen Aenderung an HTML/CSS/JS Dateien MUSS gefragt werden:**

```
Aenderung abgeschlossen:
- Element: [#id oder .class]
- Datei: [Dateiname]
- Was wurde geaendert: [Kurzbeschreibung]

Funktioniert wie gewuenscht?
-> JA: Soll ich das Element einfrieren? (Schutz vor unbeabsichtigten Aenderungen)
-> NEIN: Was muss angepasst werden?
```

**Bei Bestaetigung "einfrieren" oder "ja, freeze":**
1. `/freeze` ausfuehren
2. Element in CLAUDE2.md EINGEFRORENE-ELEMENTE-Tabelle eintragen
3. Bestaetigen: "Element [X] ist jetzt eingefroren"

---

## Skill-Trigger -> Sofort aktivieren

| Trigger | Skill(s) aktivieren |
|---------|---------------------|
| HTML, CSS, Form, Formular | `/form-master` + `/html-change-tracker` |
| Bug, Fehler, funktioniert nicht | `/systematic-debugging` + `/root-cause-tracing` |
| Neue Funktion, Feature | `/test-driven-development` |
| Fertig, erledigt, abgeschlossen | `/verification-before-completion` |
| Access, VBA, Datenbank-Sync | `/access-html-sync` |
| Formular pruefen, Check | `/fc` |
| Design, Optik, Aussehen | `/fo` |
| Optimierung, Verbesserung | `/fv` |
| Weiterarbeiten, fortsetzen | `/fort` |

---

## MCP-Server -> Automatisch nutzen

| Aufgabe | MCP-Server |
|---------|------------|
| Dateien lesen/schreiben | filesystem |
| SQL, Datenbank, Query | sqlite |
| Access .accdb Zugriff | access-mcp-server |
| Browser testen | playwright |
| DOM/CSS debuggen | chrome-devtools |
| Web recherchieren | brave-search |
| Library Dokumentation | context7 |
| Komplexe Analyse | sequential-thinking |
| Excel/Word/PowerPoint/Outlook | officemcp |

---

## ACCESS BRIDGE vs. OFFICEMCP - ENTSCHEIDUNGSLOGIK (PFLICHT!)

### AUTOMATISCH bei JEDER Office/Access-Aufgabe entscheiden:

| Aufgabe | Tool | Grund |
|---------|------|-------|
| VBA-Funktion aufrufen | **Access Bridge** | `run_vba_function()` |
| Query/Form/Modul erstellen | **Access Bridge** | `create_query/form/module()` |
| SQL auf Backend ausfuehren | **Access Bridge** | `execute_sql()` |
| Mail MIT Access-Templates | **Access Bridge** | VBA `create_Mail()` mit Templates |
| Mail OHNE Access-Bezug | **OfficeMCP** | `Officer.Outlook` direkt |
| Excel bearbeiten | **OfficeMCP** | `Officer.Excel` |
| Word bearbeiten | **OfficeMCP** | `Officer.Word` |

### Entscheidungsbaum:

```
Aufgabe betrifft Access-Datenbank/VBA?
├── JA → ACCESS BRIDGE ULTIMATE
│   Pfad: C:\Users\guenther.siegert\Documents\Access Bridge\access_bridge_ultimate.py
│
└── NEIN → Andere Office-App (Excel/Word/Outlook)?
    └── JA → OFFICEMCP (mcp__officemcp__*)
```

### NIEMALS:
- OfficeMCP fuer Access-DB-Operationen
- Access Bridge fuer Excel/Word/PowerPoint
- Mail mit Access-Templates ueber OfficeMCP (Templates gehen verloren!)

### Mail-Templates Pfad:
`\\vConSYS01-NBG\Database\HTMLBodies\`
- HTML_Body_Anfrage.txt
- HTML_Body_Confirm.txt
- HTML_Body_DienstPl.txt
- HTML_Body_Abrechnung.txt

---

## VBA DEBUG MCP - ENTSCHEIDUNGSLOGIK

### Wann VBA Debug MCP nutzen:
| Situation | VBA Debug MCP | Alternative |
|-----------|---------------|-------------|
| VBA-Fehler zur Laufzeit | **JA** - Error-Trapping | - |
| Debug.Print Ausgaben lesen | **JA** - Echtzeit | VBA_DEBUG.txt (verzoegert) |
| Syntax vor Import pruefen | **JA** - Compile-Check | compile_vba.py |
| Call Stack bei Fehler | **JA** - Stack Trace | Manuell analysieren |
| VBA-Funktion ausfuehren | NEIN | Access Bridge |
| VBA-Modul importieren | NEIN | Access Bridge |
| Query/Form erstellen | NEIN | Access Bridge |

### Entscheidung bei VBA-Problemen:

```
VBA-Problem erkannt?
├── Syntax-/Compile-Fehler?
│   └── VBA DEBUG MCP (Compile-Check)
│
├── Runtime-Fehler?
│   └── VBA DEBUG MCP (Error-Trapping + Call Stack)
│
├── Debug-Ausgaben benoetigt?
│   └── VBA DEBUG MCP (Debug.Print abfangen)
│
└── VBA ausfuehren/importieren?
    └── ACCESS BRIDGE ULTIMATE
```

### Zusammenspiel der Tools:

1. **Entwicklung:** Access Bridge (Module importieren, Queries erstellen)
2. **Debugging:** VBA Debug MCP (Fehler erkennen, Debug.Print)
3. **Ausfuehrung:** Access Bridge (run_vba_function)
4. **Office-Apps:** OfficeMCP (Excel, Word, Outlook ohne Access)

---

## HTML-REGELN

1. **UTF-8** - Umlaute direkt schreiben (ae, oe, ue wenn Encoding-Probleme)
2. **Layout-Schutz** - NIEMALS width/height/margin/padding aendern ohne Anweisung
3. **Token sparen** - `/compact` bei 70% Kapazitaet

---

## LAYOUT-SCHUTZ - KEINE EIGENMAECHTIGE AENDERUNGEN!

**WICHTIG: Folgende Eigenschaften duerfen NUR mit ausdruecklicher Anweisung von Guenther geaendert werden:**

### Geschuetzte Eigenschaften:
- **Positionen** (left, top, position, transform)
- **Groessen** (width, height, min-width, max-width, min-height, max-height)
- **Abstaende** (margin, padding, gap)
- **Controls** (Hinzufuegen, Entfernen, Umbenennen von Eingabefeldern, Buttons, Labels)
- **Unterformulare/Subforms** (Einfuegen, Entfernen, Groesse aendern)
- **Tabs/TabControls** (Reihenfolge, Anzahl, Groesse)
- **Listen/Tabellen** (Spaltenbreiten, Spaltenanzahl, Zeilenhoehe)
- **Grid/Flex-Layout** (grid-template-columns, flex-basis, etc.)

### VERBOTEN ohne Anweisung:
- Elemente verschieben oder neu positionieren
- Breiten oder Hoehen von Formularbereichen aendern
- Controls hinzufuegen oder entfernen
- Spaltenbreiten in Listen/Tabellen anpassen
- Unterformulare einbetten oder entfernen
- Tab-Reihenfolge oder Tab-Anzahl aendern

### ERLAUBT ohne Anweisung:
- Farben anpassen (wenn Design-Verbesserung)
- Schriftgroessen minimal anpassen (fuer Lesbarkeit)
- Hover-Effekte hinzufuegen
- Tooltips ergaenzen
- Bugfixes die keine Layout-Aenderung erfordern
- onclick/Event-Handler korrigieren

### Bei Unsicherheit:
**IMMER NACHFRAGEN** bevor Layout-relevante Aenderungen vorgenommen werden!

---

## EINGEFRORENE ELEMENTE PRUEFEN

**VOR jeder Aenderung:**
1. Oeffne `CLAUDE2.md`
2. Pruefe EINGEFRORENE-ELEMENTE-Tabelle
3. Ist Element gelistet? -> STOPP, nachfragen!

---

## AENDERUNGS-TRACKING

Bei JEDER HTML/CSS Aenderung dokumentieren in:
`C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\CLAUDE2.md`

---

## PROJEKTPFADE

- **HTML Forms:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3`
- **Access Frontend:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
- **ACCESS_EXPORT:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\ACCESS_EXPORT`
- **Skills:** `C:\Users\guenther.siegert\.claude\skills\`
- **CLAUDE2.md:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\CLAUDE2.md`

---

## ACCESS_EXPORT WISSENSBASIS - PFLICHT FÜR ALLE AGENTS!

### Pfad zum Export
`C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\ACCESS_EXPORT\`

### Export-Stand (2026-01-24)
- **175 Formulare** vollstaendig exportiert
- **132 VBA-Module** exportiert
- **5.313 Controls** erfasst
- **1.169 Events** dokumentiert
- **117 Queries/Tabellen** referenziert

### PFLICHT vor JEDER HTML-Formular-Arbeit

**Bevor ein Agent eine Aufgabe in einem HTML-Formular durchführt (Korrektur, Fehlerbehebung, neues Feature), MUSS er:**

1. **Access-Export konsultieren** - Die entsprechende JSON-Datei im forms-Verzeichnis lesen
2. **Ablauf verstehen** - Wie funktioniert der Vorgang in Access? Welche Events werden ausgelöst? Welche Funktionen aufgerufen?
3. **Zusammenhaenge erkennen** - Welche Subforms, Queries, Tabellen sind beteiligt?
4. **Erst dann implementieren** - Mit diesem Wissen gezielt und korrekt arbeiten

### Beispiel-Workflow

```
Aufgabe: "Soll/Ist wird nicht angezeigt in Auftragsliste"

1. Agent oeffnet: ACCESS_EXPORT/forms/frm_VA_Auftragstamm.json
2. Liest: properties.record_source -> "qry_Auftrag_Sort"
3. Liest: controls[] -> Findet lstAuftraege mit Spalten-Definition
4. Liest: connections.bound_controls -> Findet MA_Anzahl_Soll, MA_Anzahl_Ist
5. Liest: events.OnCurrent -> Findet welche VBA-Funktion aufgerufen wird
6. Versteht: API muss diese Felder liefern, JS muss sie rendern
7. Behebt: Gezielt das fehlende Feld im Rendering
```

### Schnellsuche (Token-effizient)

| Was suchen? | Wo nachschauen? |
|-------------|-----------------|
| Formular-Uebersicht | `ACCESS_EXPORT/output/MASTER_INDEX.json` |
| Event-Handler finden | `ACCESS_EXPORT/output/EVENT_MAP.json` |
| Query-Verwendung | `ACCESS_EXPORT/output/QUERY_USAGE.json` |
| Abhaengigkeiten/Subforms | `ACCESS_EXPORT/output/DEPENDENCY_MAP.json` |
| Formular-Details | `ACCESS_EXPORT/forms/{formname}.json` |
| VBA-Module | `ACCESS_EXPORT/modules/modules/{modulname}.bas` |

### Struktur einer Formular-JSON

```json
ACCESS_EXPORT/forms/frm_VA_Auftragstamm.json
{
  "meta": { "export_date", "form_name", "export_method" },
  "properties": { "record_source", "caption", "has_module", ... },
  "sections": { "detail", "header", "footer" mit height/colors },
  "controls": [ { "name", "type_name", "control_source", "events", ... } ],
  "events": { "OnCurrent": "[Event Procedure]", ... },
  "tabs": { "TabControl1": { "pages": [...] } },
  "subforms": [ { "control_name", "source_object", "link_fields", ... } ],
  "connections": { "record_source", "bound_controls", "combo_sources", ... }
}
```

### ELEMENT-MAPPING (Wenn Namen nicht uebereinstimmen)

In Access heissen Elemente oft anders als in HTML (z.B. "Btn1234" vs "btnSpeichern").

**Element-Mapper verwenden:**
```python
# Pfad: ACCESS_EXPORT/scripts/element_mapper.py
from element_mapper import ElementMapper, quick_search

mapper = ElementMapper(r'C:\...\ACCESS_EXPORT')

# Suche nach Caption
results = mapper.find_element_by_caption("Speichern")

# Suche welches Element eine Funktion aufruft
results = mapper.find_element_by_function("btnSpeichern_Click")

# Fuzzy-Suche (findet aehnliche Namen)
results = mapper.find_similar_elements("btnSave", threshold=0.6)

# Intelligente Kombinations-Suche
results = mapper.smart_find("Speichern")
```

**Mapping-Hints manuell hinzufuegen (bei bekannten Abweichungen):**
```json
ACCESS_EXPORT/MAPPING_HINTS.json
{
  "mappings": {
    "frm_VA_Auftragstamm": {
      "Btn1234": "btnSpeichern",
      "Text567": "txtKunde"
    }
  }
}
```

### VBA-Module nachschlagen

Alle VBA-Module sind unter `ACCESS_EXPORT/modules/` als .bas/.cls Dateien verfuegbar:
```
ACCESS_EXPORT/modules/
├── modules/           # Standard-Module (.bas)
│   ├── zmd_Funktionen.bas
│   ├── zmd_Mail.bas
│   └── ...
├── classes/           # Klassen-Module (.cls)
│   ├── clsExcel.cls
│   └── ...
└── MODULES_INDEX.json # Uebersicht aller Module mit Funktionslisten
```

### VERBOTEN

- HTML-Formular aendern OHNE vorher den Access-Export zu konsultieren
- Vermutungen ueber Access-Verhalten anstellen ohne Beweis aus Export
- Events implementieren ohne zu wissen welche VBA-Funktion in Access aufgerufen wird
- Bei nicht gefundenen Elementen aufgeben - stattdessen Element-Mapper und Suchstrategien nutzen
- `forms/` mit alten Timestamp-Dateien benutzen - immer die aktuelle {formname}.json nehmen

---

## FREEZE-SCHUTZSYSTEM (NEU 2026-01-28)

### Uebersicht

Das Freeze-System schuetzt stabile Dateien und Funktionen vor unbeabsichtigten Aenderungen.

### Wichtige Dateien

| Datei | Zweck |
|-------|-------|
| `claude.freeze.json` | Zentrale Freeze-Datenbank |
| `scripts/freeze.sh` | Datei einfrieren |
| `scripts/unfreeze.sh` | Datei auftauen |
| `scripts/freeze-check.sh` | Prueft ob eingefroren |
| `scripts/freeze-list.sh` | Zeigt alle eingefrorenen |
| `stable/` | Stabile Versionen |
| `experiments/` | Testbereich |

### VOR JEDER AENDERUNG - PFLICHT-CHECK

```bash
# Pruefe ob Datei eingefroren ist
./scripts/freeze-check.sh <pfad>

# Zeige alle eingefrorenen Dateien
./scripts/freeze-list.sh
```

### Workflow bei Aenderungen

```
1. FREEZE-CHECK: ./scripts/freeze-check.sh <datei>
   -> Eingefroren? STOPP! User fragen!
   -> Nicht eingefroren? Weiter.

2. EXPERIMENT-FIRST: Grosse Aenderungen zuerst in experiments/

3. AENDERN: Aenderung durchfuehren

4. TESTEN: Browser-Test + Console-Check

5. FREEZE-FRAGE: "Soll ich das einfrieren?"
   -> Ja: ./scripts/freeze.sh <datei> "Grund"
   -> Nein: Weiter

6. DOKUMENTIEREN: In CLAUDE2.md eintragen
```

### PROTECTED-Bloecke

Code zwischen diesen Markern darf NICHT geaendert werden:

```javascript
// PROTECTED START - Beschreibung
... geschuetzter Code ...
// PROTECTED END - Beschreibung
```

```html
<!-- PROTECTED START - Beschreibung -->
... geschuetzter Code ...
<!-- PROTECTED END - Beschreibung -->
```

```python
# PROTECTED START - Beschreibung
... geschuetzter Code ...
# PROTECTED END - Beschreibung
```

### Einfrieren/Auftauen

```bash
# Datei einfrieren
./scripts/freeze.sh 04_HTML_Forms/forms3/css/style.css "Header-Styling fertig"

# Datei auftauen (NUR mit User-Erlaubnis!)
./scripts/unfreeze.sh 04_HTML_Forms/forms3/css/style.css
```

### Regeln fuer zukuenftige Sessions

1. **IMMER** freeze-check vor Aenderungen
2. **NIE** frozenFiles ueberschreiben ohne Erlaubnis
3. **NIE** PROTECTED-Bloecke aendern
4. **ZUERST** in experiments/ testen
5. **DANN** nach stable/ kopieren
6. **DANN** ins Projekt uebernehmen

### Exit-Codes freeze-check.sh

| Code | Bedeutung |
|------|-----------|
| 0 | Nicht eingefroren - Aenderung erlaubt |
| 1 | EINGEFROREN - STOPP! |
| 2 | Fehler (Parameter fehlt) |
