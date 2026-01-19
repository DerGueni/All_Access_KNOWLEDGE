# Gap-Analyse: Dienstplan-Formulare - Zusammenfassung

**Datum:** 2026-01-12
**Analysierte Formulare:** 4 (DP Dienstplan MA, DP Dienstplan Objekt, DP Einzeldienstpläne, Einsatzübersicht)

---

## GESAMTBEWERTUNG

| Formular | Completion | Kritische Gaps | Aufwand | Status |
|----------|------------|----------------|---------|--------|
| **frm_DP_Dienstplan_MA** | **70%** | ID-Mismatch, 100 MA Limit | 12-16h | ⚠️ Fast fertig |
| **frm_DP_Dienstplan_Objekt** | **75%** | KW-Logik, Master-Detail | 8-12h | ⚠️ Fast fertig |
| **frm_DP_Einzeldienstplaene** | **2%** | NUR PLACEHOLDER! | 17h | 🔴 Nicht implementiert |
| **frm_Einsatzuebersicht** | **85%** | Fehlende Spalten, Read-Only | 4-6h | ✅ Überlegen! |
| **Durchschnitt** | **58%** | **18 Gaps** | **~11h/Form** | ⚠️ |

---

## STATUS-ÜBERSICHT

### ✅ **Einsatzübersicht - FUNKTIONAL ÜBERLEGEN!** (85%)

**HTML ist BESSER als Access:**
- **Mehr Features:** Datumsbereich, Schnellfilter (Heute/Woche/Monat), Gruppierung
- **Besser Benutzbar:** Collapse/Expand, Tastatur-Shortcuts, Export
- **Moderneres UI:** Status-Badges, farbcodierte MA-Zahlen, Sidebar
- **Navigation:** Doppelklick → Auftragstamm

**Nur kleine Gaps:**
- ❌ Fehlende Spalten: Ort, MA-Namen, Stunden (Brutto/Netto), PosNr
- ❌ Read-Only (Inline-Edit fehlt, aber vermutlich nicht nötig)

**Aufwand:** 4-6h für fehlende Spalten

---

### ⚠️ **Dienstplan MA & Objekt - FAST FERTIG** (70-75%)

#### frm_DP_Dienstplan_MA (70%)
**Stärken:**
- Moderne UI mit CSS Grid
- Wochennavigation vollständig
- **NEU:** KW-Dropdown (Verbesserung!)
- DblClick auf Tag funktioniert
- 18/30 Controls implementiert

**Kritische Gaps:**
- 🔴 **WebView2 ID-Mismatch:** `#dtStartdatum` vs. `#startDatum`
- 🔴 **100 MA Limit:** Nur 100 Mitarbeiter angezeigt (Zeile 422)
- 🔴 **E-Mail API fehlt:** POST `/api/dienstplan/senden`
- ⚠️ **Excel-Export:** Nur CSV statt XLS mit Formatierung

**Aufwand:** 12-16h

#### frm_DP_Dienstplan_Objekt (75%)
**Stärken:**
- Kalender-Layout mit 7-Tage-Matrix
- Filter für freie Schichten
- Status-Highlighting (unbesetzt/fraglich/storno)
- Excel-Export (CSV)

**Kritische Gaps:**
- 🔴 **KW-Combobox:** Element da, aber keine Logik
- 🔴 **Master-Detail Navigation:** DblClick fehlt
- 🔴 **Überbuchungs-Anzeige:** Nur Unterbuchung implementiert
- ⚠️ **Feiertags-CSS:** Logik da, Styling fehlt
- ⚠️ **Farben falsch:** Werktage sollten hellorange sein (#f6c683), nicht dunkelblau

**Aufwand:** 8-12h

---

### 🔴 **Einzeldienstpläne - NUR PLACEHOLDER!** (2%)

**Kritisch:**
- HTML zeigt nur "Diese Ansicht wird noch implementiert"
- 43 Zeilen Code, davon nur Placeholder-UI
- **Keine Controls, keine Daten, keine Logik**
- Access-Export fehlt (nicht im JSON-Export 11/25)

**Geschätzte Features (basierend auf Name):**
- MA-Auswahl (Multi-Select)
- Zeitraum (Von/Bis + Vorlagen)
- Format-Optionen (A4 Hoch/Quer)
- Filter (Nur bestätigte, Objekt, Kunde)
- Vorschau-Bereich (Druckbares Layout)
- Export (Drucken, PDF, Excel)

**Aufwand:** 17h (komplette Neuimplementierung)

**Offene Fragen:**
- Existiert dieses Formular in Access?
- Welche Features sind Muss-Kriterien?
- Druckformat: Eine Seite pro MA oder alle zusammen?

---

## KRITISCHE BLOCKER

### 🔴 TOP 5 BLOCKER

1. **Einzeldienstpläne komplett fehlt**
   - Nur Placeholder vorhanden
   - Vermutlich wichtig für Druck/PDF-Export
   - **Aufwand:** 17h

2. **100 MA Limit** (Dienstplan MA)
   - Nur 100 Mitarbeiter werden geladen
   - Bei größeren Firmen kritisch!
   - **Aufwand:** 1h (Query-Limit entfernen)

3. **WebView2 ID-Mismatch** (Dienstplan MA)
   - Button-IDs stimmen nicht überein
   - Buttons funktionieren nicht in WebView2!
   - **Aufwand:** 30min

4. **KW-Combobox ohne Logik** (Dienstplan Objekt)
   - Element da, aber keine Options, kein Change-Event
   - KW-Wechsel nicht möglich!
   - **Aufwand:** 2h

5. **E-Mail API fehlt** (Dienstplan MA)
   - POST `/api/dienstplan/senden` nicht implementiert
   - Dienstplan-Versand nicht möglich
   - **Aufwand:** 3-4h

---

## STÄRKEN

### ✅ Was gut umgesetzt ist

#### Einsatzübersicht (85%)
- **Filter:** Datumsbereich, Schnellfilter, "Nur Aktive"
- **Gruppierung:** Nach Objekt/MA/Datum mit Collapse
- **Export:** Excel, CSV, Drucken
- **Navigation:** Doppelklick → Auftragstamm
- **Tastatur-Shortcuts:** F5, Ctrl+E, Ctrl+P, ESC

#### Dienstplan MA (70%)
- CSS Grid Layout (modern!)
- Wochennavigation
- KW-Dropdown (besser als Access!)
- Robuste Fehlerbehandlung
- DblClick auf Tag

#### Dienstplan Objekt (75%)
- Kalender-Matrix (7 Tage)
- Filter freie Schichten
- Status-Highlighting
- REST-API Anbindung

---

## SCHWÄCHEN

### ❌ Was fehlt

#### Fehlende Features
- **Einzeldienstpläne:** Komplett nicht implementiert (2%)
- **Excel-Export:** Nur CSV statt formatiertes XLS
- **PDF-Export:** Fehlt überall
- **E-Mail-Versand:** API nicht implementiert
- **Inline-Bearbeitung:** Nur Einsatzübersicht, aber Read-Only

#### Technische Probleme
- **100 MA Limit:** Skalierung
- **ID-Mismatch:** WebView2-Kompatibilität
- **Farben weichen ab:** Corporate Design nicht eingehalten
- **Fehlende Spalten:** Ort, MA-Namen, Stunden

---

## SOFORT-MASSNAHMEN (Diese Woche)

### Quick-Wins (10h)
1. **100 MA Limit entfernen** - Dienstplan MA (1h) → **Unblock!**
2. **WebView2 IDs korrigieren** - Dienstplan MA (30min) → **Funktioniert in WebView2**
3. **Fehlende Spalten** - Einsatzübersicht (4h) → **Vollständig**
4. **KW-Combobox Logik** - Dienstplan Objekt (2h) → **KW-Wechsel möglich**
5. **Feiertags-CSS** - Dienstplan Objekt (30min) → **Visuell korrekt**
6. **Farben korrigieren** - Dienstplan Objekt (1h) → **Corporate Design**

### Mittelfristig (30h)
7. **E-Mail API** - Dienstplan MA (4h) → **Versand möglich**
8. **Excel-Export** - Beide Dienstpläne (6h) → **Formatiert**
9. **Master-Detail Navigation** - Dienstplan Objekt (3h) → **Detail-Ansicht**
10. **Einzeldienstpläne** - Komplett (17h) → **100% Formular**

**Nach 40h:** Durchschnitt 58% → 85% (+27%)

---

## ROADMAP

### Phase 1: Quick-Wins (1 Woche, 10h)
**Ziel:** Kritische Blocker entfernen
- 100 MA Limit, WebView2 IDs, KW-Logik, Farben
- Completion: 58% → 70%

### Phase 2: Core-Features (2 Wochen, 13h)
**Ziel:** E-Mail, Excel, Navigation
- E-Mail API, Excel-Export, Master-Detail
- Completion: 70% → 78%

### Phase 3: Einzeldienstpläne (1 Woche, 17h)
**Ziel:** Fehlendes Formular implementieren
- Komplett-Implementierung
- Completion: 78% → 88%

### Phase 4: Polishing (1 Woche, 10h)
**Ziel:** PDF, Inline-Edit, Restliche Gaps
- Completion: 88% → 95%

**Gesamt:** 50h für 95% Feature-Parity

---

## METRIKEN

### Control-Abdeckung (Durchschnitt über 4 Formulare)
| Typ | Access | HTML | Status |
|-----|--------|------|--------|
| Buttons | 10 | 8 | 80% ✅ |
| TextBoxen | 8 | 6 | 75% ⚠️ |
| ComboBoxen | 4 | 2 | 50% ⚠️ |
| DatePicker | 2 | 2 | 100% ✅ |
| Kalender-Grid | 1 | 1 | 100% ✅ |

### Funktionalität
| Feature | Implementiert | Status |
|---------|---------------|--------|
| Kalender-Ansicht | 100% | ✅ |
| Navigation (Woche/Monat) | 90% | ✅ |
| Filter/Suche | 80% | ✅ |
| Export (CSV) | 80% | ✅ |
| Export (Excel/PDF) | 40% | ❌ |
| E-Mail-Versand | 0% | 🔴 |
| Inline-Bearbeitung | 0% | 🔴 |
| DblClick-Navigation | 75% | ⚠️ |

---

## ZUSAMMENFASSUNG

### 👍 Positive Aspekte:
- **Einsatzübersicht überlegen:** Mehr Features als Access!
- **Dienstpläne fast fertig:** 70-75% Completion
- **Modernes UI:** CSS Grid, Responsive, Keyboard-Shortcuts

### 👎 Kritische Probleme:
- **Einzeldienstpläne fehlen:** Nur 2% (Placeholder)
- **100 MA Limit:** Skalierungsproblem
- **E-Mail/Excel/PDF:** Export-Funktionen unvollständig
- **Inline-Edit fehlt:** Alle Formulare Read-Only

### 🎯 Nächste Schritte:
1. **Sofort:** Quick-Wins (10h) → 58% auf 70%
2. **Diese/Nächste Woche:** Core-Features (13h) → 70% auf 78%
3. **In 2-3 Wochen:** Einzeldienstpläne (17h) → 78% auf 88%

**Mit 50h Entwicklung: 58% → 95% Feature-Parity**

---

## BESONDERHEIT: Einsatzübersicht als Dashboard

Die **Einsatzübersicht** ist funktional überlegen und sollte als **primäres Dashboard** verwendet werden:
- ✅ Für Übersicht, Filterung, Export, Navigation
- ⏩ Bearbeitung im Auftragstamm (Doppelklick öffnet)
- ➕ Nur fehlende Spalten ergänzen (4h)

**Inline-Bearbeitung NICHT empfohlen:**
- Sehr aufwendig (~20h)
- Würde Access 1:1 nachbilden (nicht immer besser!)
- Dashboard-Ansatz ist moderner und benutzerfreundlicher

---

*Zusammenfassung erstellt: 2026-01-12*
