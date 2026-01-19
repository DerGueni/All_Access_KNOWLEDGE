# Gap-Analyse: Access vs. HTML - Arbeitsplan

**Erstellt:** 2026-01-12
**Ziel:** Systematischer Vergleich aller Access-Formulare mit ihren HTML-Pendants

---

## METHODIK

### 1. Vergleichskriterien

Für jedes Formular prüfen:

#### A) Controls
- **Anzahl:** Access Controls vs. HTML Elements
- **Typen:** Buttons, TextBoxen, ComboBoxen, Subforms, etc.
- **Fehlend in HTML:** Welche Access-Controls fehlen komplett?
- **Zusätzlich in HTML:** Welche HTML-Elements gibt es extra?

#### B) Events
- **Access-Events:** OnClick, AfterUpdate, OnLoad, OnCurrent, etc.
- **HTML-Events:** JavaScript Event-Handler in .logic.js/.webview2.js
- **Fehlend in HTML:** Welche Events sind nicht implementiert?
- **VBA vs. JS:** Funktionsvergleich

#### C) Datenanbindung
- **Access RecordSource:** Tabelle/Abfrage
- **HTML Data Source:** API-Endpoints, Bridge-Aufrufe
- **Fehlend:** Welche Datenquellen sind nicht angebunden?

#### D) Funktionalität
- **VBA-Logik:** Button-Funktionen, Validierungen, Berechnungen
- **JS-Logik:** Implementierte Funktionen in .logic.js
- **Fehlend:** Welche Business-Logik fehlt?

---

## PRIORITÄTEN

### Prio 1: Kernformulare (4 Stück)
1. frm_va_Auftragstamm
2. frm_MA_Mitarbeiterstamm
3. frm_KD_Kundenstamm
4. frm_OB_Objekt

**Warum:** Meistgenutzte Formulare, höchste Business-Relevanz

### Prio 2: Kritische Formulare (4 Stück)
5. frm_MA_VA_Schnellauswahl
6. frm_DP_Dienstplan_MA
7. frm_DP_Dienstplan_Objekt
8. frm_Einsatzuebersicht

**Warum:** Täglich genutzt, komplexe Logik

### Prio 3: Mitarbeiter-Formulare (7 Stück)
9-15. Alle frm_MA_* (Offene Anfragen, E-Mail, Abwesenheit, etc.)

### Prio 4: Restliche Formulare (37 Stück)
16-54. Alle anderen Haupt- und Unterformulare

---

## OUTPUT-FORMAT

### Pro Formular: {FormName}_GAP_ANALYSIS.md

```markdown
# Gap-Analyse: {FormName}

## Übersicht
| Metrik | Access | HTML | Gap |
|--------|--------|------|-----|
| Controls gesamt | X | Y | -Z |
| Buttons | X | Y | -Z |
| TextBoxen | X | Y | -Z |
| ComboBoxen | X | Y | -Z |
| Events gesamt | X | Y | -Z |

## Controls-Vergleich

### ✅ Implementiert in HTML (X von Y)
| Control | Access-Name | HTML-ID | Status |
|---------|-------------|---------|--------|
| Button | btnSave | btnSave | ✅ Vorhanden |

### ❌ Fehlend in HTML (Z Controls)
| Control | Access-Name | Typ | Funktion |
|---------|-------------|-----|----------|
| Button | btnExport | CommandButton | Excel-Export |

### ➕ Zusätzlich in HTML (N Controls)
| Element | HTML-ID | Typ | Zweck |
|---------|---------|------|-------|
| Button | btnRefresh | button | Daten neu laden |

## Events-Vergleich

### ✅ Implementierte Events (X von Y)
| Event | Access-Handler | HTML-Handler | Status |
|-------|----------------|--------------|--------|
| OnLoad | Form_Load() | Form_Load() | ✅ Portiert |

### ❌ Fehlende Events (Z Events)
| Event | Access-Handler | VBA-Funktion | Auswirkung |
|-------|----------------|--------------|------------|
| AfterUpdate | txtDatum_AfterUpdate() | Datumsvalidierung | Keine Validierung in HTML |

## Funktionalität-Vergleich

### ✅ Implementierte Funktionen
- [x] Datensatz laden
- [x] Datensatz speichern
- [x] Formular navigieren

### ❌ Fehlende Funktionen
- [ ] Excel-Export
- [ ] PDF-Erstellung
- [ ] E-Mail versenden

## Datenanbindung

### Access
- **RecordSource:** qry_Auftragstamm
- **Subforms:** 4 (Schichten, Einsatztage, Zuordnungen, Absagen)

### HTML
- **API-Endpoints:** /api/auftraege, /api/auftraege/{id}/schichten
- **Fehlend:** /api/auftraege/{id}/export-excel

## Priorität der Gaps

### 🔴 Kritisch (P0)
- [ ] Speichern-Funktion fehlt
- [ ] Validierung fehlt komplett

### 🟡 Wichtig (P1)
- [ ] Excel-Export fehlt
- [ ] Subform-Navigation fehlt

### 🟢 Nice-to-have (P2)
- [ ] Tooltips fehlen
- [ ] Keyboard-Shortcuts fehlen

## Empfehlung

**Completion:** 75%
**Kritische Gaps:** 2
**Aufwand-Schätzung:** 8-12 Stunden

**Nächste Schritte:**
1. Speichern-Funktion implementieren (API POST)
2. Validierung hinzufügen (JS)
3. Excel-Export via VBA-Bridge
```

---

## MASTER-REPORT

### MASTER_GAP_REPORT.md

```markdown
# Gap-Analyse: Access vs. HTML - Master-Report

## Zusammenfassung

| Kategorie | Formulare | Ø Completion | Kritische Gaps | Aufwand |
|-----------|-----------|--------------|----------------|---------|
| Kernformulare | 4 | 85% | 8 | 40h |
| Kritische | 4 | 72% | 12 | 60h |
| Mitarbeiter | 7 | 65% | 18 | 80h |
| Restliche | 39 | 45% | 45 | 120h |

## Top 10 Gaps (nach Kritikalität)

1. **Speichern-Funktionalität fehlt** - 12 Formulare betroffen
2. **E-Mail-Versand fehlt** - 8 Formulare betroffen
3. **Excel-Export fehlt** - 15 Formulare betroffen
...

## Gesamt-Statistiken

| Metrik | Access | HTML | Gap |
|--------|--------|------|-----|
| Controls gesamt | 1,209 | ~900 | -300 |
| Events gesamt | 46 | ~30 | -16 |
| Buttons gesamt | 195 | ~150 | -45 |

## Roadmap

### Phase 1: Kritische Gaps (2-3 Wochen)
- Speichern-Funktionalität in allen Kernformularen
- Validierung implementieren
- E-Mail-Versand via VBA-Bridge

### Phase 2: Wichtige Gaps (4-6 Wochen)
- Excel-Export
- Subform-Navigation
- Fehlende Events

### Phase 3: Nice-to-have (6-8 Wochen)
- Tooltips
- Keyboard-Shortcuts
- Optische Anpassungen
```

---

## ABLAUF

### Batch 1: Kernformulare (Parallel-Agents)
Agent pro Formular:
- frm_va_Auftragstamm
- frm_MA_Mitarbeiterstamm
- frm_KD_Kundenstamm
- frm_OB_Objekt

### Batch 2: Kritische Formulare (Parallel-Agents)
- frm_MA_VA_Schnellauswahl
- frm_DP_Dienstplan_MA
- frm_DP_Dienstplan_Objekt
- frm_Einsatzuebersicht

### Batch 3: Restliche Formulare (5er-Batches)
- 10 Batches à 5 Formulare

### Batch 4: Master-Report
- Aggregation aller Einzel-Reports
- Statistiken erstellen
- Roadmap ableiten

---

## TECHNISCHE DETAILS

### Dateien zu vergleichen

**Access-Export (MD):**
```
04_HTML_Forms\forms3\Access_Abgleich\forms\{FormName}.md
04_HTML_Forms\forms3\Access_Abgleich\subforms\{FormName}.md
```

**HTML-Formulare:**
```
04_HTML_Forms\forms3\{FormName}.html
04_HTML_Forms\forms3\logic\{FormName}.logic.js
04_HTML_Forms\forms3\logic\{FormName}.webview2.js
```

### Automatisierung

Python-Script zur Gap-Analyse:
```python
def analyze_gap(access_md, html_file, logic_js):
    # Parse Access MD
    access_controls = parse_controls(access_md)
    access_events = parse_events(access_md)

    # Parse HTML
    html_controls = parse_html_controls(html_file)
    html_events = parse_js_events(logic_js)

    # Compare
    gaps = {
        'missing_controls': access_controls - html_controls,
        'missing_events': access_events - html_events,
        'extra_controls': html_controls - access_controls
    }

    return gaps
```

---

*Arbeitsplan-Ende*
