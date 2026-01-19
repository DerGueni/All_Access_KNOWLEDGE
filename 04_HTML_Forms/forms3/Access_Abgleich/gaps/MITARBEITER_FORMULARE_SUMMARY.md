# Gap-Analyse: Mitarbeiter-Formulare - Zusammenfassung

**Datum:** 2026-01-12
**Analysierte Formulare:** 7 (MA-Schnellauswahl, Positionszuordnung, Offene Anfragen, 2x Serien-eMail, Tabelle, Abwesenheit)

---

## GESAMTBEWERTUNG

| Formular | Completion | Kritische Gaps | Aufwand | Status |
|----------|------------|----------------|---------|--------|
| **frm_MA_VA_Schnellauswahl** | **75%** | Umlaut-IDs, DblClick, API | 6-9h | ⚠️ Fast fertig |
| **frm_MA_VA_Positionszuordnung** | **20%** | Drag&Drop fehlt komplett | 32-48h | 🔴 Kritisch |
| **frm_MA_Offene_Anfragen** | **70%** | Bridge fehlt, Fallback-API | 8-12h | ⚠️ Fast fertig |
| **frm_MA_Serien_eMail_Auftrag** | **25%** | Templates, Attachments | 25-35h | 🔴 Kritisch |
| **frm_MA_Serien_eMail_dienstplan** | **25%** | Templates, Voting | 25-35h | 🔴 Kritisch |
| **frm_MA_Tabelle** | **0%** | Nicht implementiert | 8-12h | 🔴 Kritisch |
| **frm_MA_Abwesenheit** | **40%** | Inkonsistente Workflows | 10-14h | 🔴 Kritisch |
| **Durchschnitt** | **36%** | **47 Gaps** | **~20h/Form** | 🔴 |

---

## KRITISCHE BLOCKER (SOFORT BEHEBEN!)

### 🔴 TOP 5 BLOCKER

1. **Drag & Drop fehlt** (frm_MA_VA_Positionszuordnung)
   - Hauptfunktionalität des Formulars!
   - 3 ListBoxes mit Multi-Select nicht umgesetzt
   - **Aufwand:** 32-48h

2. **E-Mail-Templates nicht aus DB** (2x Serien-eMail)
   - Aktuell hardcodiert
   - Muss aus `tbl_MA_Serien_eMail_Vorlage` kommen
   - **Aufwand:** 12h

3. **Voting-System fehlt** (Serien-eMail)
   - Zusage/Absage-Management nicht implementiert
   - `tbl_hlp_Voting` nicht angebunden
   - **Aufwand:** 8h

4. **Umlaut-IDs brechen Filter** (frm_MA_VA_Schnellauswahl)
   - `cbVerplantVerfügbar` → muss `cbVerplantVerfuegbar` sein
   - `IstVerfügbar` → muss `IstVerfuegbar` sein
   - **Filter funktionieren NICHT!**
   - **Aufwand:** 30min

5. **Bridge-Integration fehlt** (frm_MA_Offene_Anfragen)
   - Kein Import von `webview2-bridge.js`
   - `Bridge.sendEvent()` undefined
   - **E-Mail-Anfragen unmöglich!**
   - **Aufwand:** 2h

---

## FEHLENDE FORMULARE

### 🔴 Komplett nicht implementiert

#### frm_MA_Tabelle (0%)
- **Was es ist:** Tabellarische Ansicht aller Mitarbeiter
- **Was fehlt:**
  - AG-Grid oder Tabulator.js Komponente
  - 27 Datenfelder
  - Sortierung nach IstAktiv → Nachname
  - Inline-Editing
  - REST-API Integration
- **Warum kritisch:** Schnellübersicht über alle MAs fehlt!
- **Aufwand:** 8-12h

---

## INKONSISTENZEN

### ⚠️ frm_MA_Abwesenheit - Zwei Workflows!

**Access hat 2 verschiedene Formulare:**
1. `frm_MA_Abwesenheiten_Urlaub_Gueni` - Kreuztabellen-Auswertung (12 Monate)
2. `frmTop_MA_Abwesenheitsplanung` - Eingabeformular mit "Berechnen → Vorschau → Übernehmen"

**HTML implementiert BEIDES gleichzeitig:**
- **Inline-JS:** "Berechnen → Vorschau → Übernehmen" Workflow
- **Logic.js:** Direktes CRUD ohne Vorschau
- **Problem:** Beide sind nicht kompatibel!

**Entscheidung erforderlich:**
- Welcher Workflow soll verwendet werden?
- Konsolidierung von inline-JS und logic.js
- **Aufwand:** 4-6h Entscheidung + 6-8h Implementierung

---

## STÄRKEN

### ✅ Was gut umgesetzt ist

#### frm_MA_VA_Schnellauswahl (75%)
- E-Mail-System via VBA Bridge (Modal, Progress, Log)
- Grundstruktur: Auftrag → Datum → Schichten → MA-Auswahl
- MA-Zuordnung (hinzufügen/entfernen)
- Filter: Anstellungsart, Aktiv, §34a
- URL-Parameter für Auto-Load
- Entfernungs-Feature (Basis)

#### frm_MA_Offene_Anfragen (70%)
- Modernes Design mit Toolbar, Sticky Header
- Alle Felder korrekt gemappt
- Filter 7/30 Tage (besser als Access!)
- CSV-Export
- Datum-Farbcodierung (grün/orange/rot)

#### frm_MA_Abwesenheit (40%)
- Datepicker für Von/Bis
- Grundbedienkontrollen (Speichern, Löschen, Neu)
- REST-API Anbindung (`/api/abwesenheiten`)

---

## SCHWÄCHEN

### ❌ Was schlecht läuft

#### Serien-E-Mail (25%)
- **Templates:** Hardcodiert statt DB
- **Attachments:** Fehlt komplett (`sub_tbltmp_Attachfile`)
- **Voting:** Zusage/Absage-System fehlt
- **Zeitraum-Filter:** Nur rudimentär (Access: 4 Optionen)
- **PDF-Erstellung:** Fehlt
- **Priorität & CC:** Nicht implementiert
- **Dienstplan-Query:** Falsch (muss `qry_mitarbeiter_dienstplan_email_einzel` sein)

#### Positionszuordnung (20%)
- **Drag & Drop:** Fehlt komplett!
- **Bulk-Ops:** "Alle hinzufügen/entfernen" fehlt
- **Wiederholung:** btnRepeat fehlt (wichtig für Events!)
- **API-Endpoints:** 5+ fehlen (Positionen-CRUD, verfügbare MA)
- **Delete-Button:** Fehlt im UI (Funktion in Logic.js vorhanden)

---

## SOFORT-MASSNAHMEN (Diese Woche)

### Quick-Wins (12h)
1. **Umlaut-IDs korrigieren** - Schnellauswahl (30min) → **+10% Completion**
2. **Bridge-Integration** - Offene Anfragen (2h) → **+15% Completion**
3. **DblClick-Handler** - Schnellauswahl (1h) → **+5% Completion**
4. **Filter-Logik** - Schnellauswahl (3h) → **+5% Completion**
5. **Workflow-Entscheidung** - Abwesenheit (4h) → **Klarheit**
6. **Fallback-API** - Offene Anfragen (2h) → **+10% Completion**

### Mittelfristig (40h)
7. **E-Mail-Templates aus DB** - Serien-eMail (12h) → **+30% Completion**
8. **Voting-System** - Serien-eMail (8h) → **+20% Completion**
9. **frm_MA_Tabelle implementieren** - (10h) → **+100% (von 0)**
10. **Attachment-System** - Serien-eMail (10h) → **+20% Completion**

**Nach 52h:** Durchschnitt 36% → 65% (+29%)

---

## ROADMAP

### Phase 1: Kritische Fixes (1 Woche, 12h)
**Ziel:** Quick-Wins umsetzen, Blocker entfernen
- Umlaut-IDs, Bridge, DblClick, Filter
- Completion: 36% → 50%

### Phase 2: Core-Features (2 Wochen, 40h)
**Ziel:** Templates, Voting, Tabelle, Attachments
- Completion: 50% → 65%

### Phase 3: Drag & Drop (1 Woche, 40h)
**Ziel:** Positionszuordnung komplett umsetzen
- Completion: 65% → 75%

### Phase 4: Polishing (1 Woche, 20h)
**Ziel:** Restliche Gaps schließen
- Completion: 75% → 85%

**Gesamt:** 112h für 85% Feature-Parity

---

## METRIKEN

### Control-Abdeckung (Durchschnitt über 7 Formulare)
| Typ | Access | HTML | Status |
|-----|--------|------|--------|
| Buttons | 15 | 8 | 53% ⚠️ |
| TextBoxen | 12 | 10 | 83% ✅ |
| ComboBoxen | 6 | 3 | 50% ⚠️ |
| ListBoxen | 2 | 0.5 | 25% ❌ |
| CheckBoxen | 3 | 2 | 67% ⚠️ |
| Subforms | 1 | 0.3 | 30% ❌ |

### Funktionalität
| Feature | Implementiert | Status |
|---------|---------------|--------|
| CRUD-Operationen | 60% | ⚠️ |
| E-Mail-Versand | 40% | ❌ |
| Filter/Suche | 70% | ⚠️ |
| Templates | 20% | 🔴 |
| Drag & Drop | 0% | 🔴 |
| Voting/Status | 30% | 🔴 |
| Export (CSV/Excel) | 50% | ⚠️ |

---

## ZUSAMMENFASSUNG

### 👍 Positive Aspekte:
- **Schnellauswahl & Offene Anfragen:** Fast produktionsreif (70-75%)
- **REST-API:** Grundstruktur vorhanden
- **Modernes UI:** Besseres Design als Access

### 👎 Kritische Probleme:
- **Positionszuordnung:** Hauptfunktionalität fehlt (Drag & Drop)
- **Serien-E-Mail:** Nur 25% implementiert, nicht produktiv einsetzbar
- **MA-Tabelle:** Komplett nicht vorhanden
- **Inkonsistenzen:** Abwesenheit hat 2 konkurrierende Workflows

### 🎯 Nächste Schritte:
1. **Sofort:** Quick-Wins (12h) → 36% auf 50%
2. **Diese/Nächste Woche:** Core-Features (40h) → 50% auf 65%
3. **In 2-3 Wochen:** Drag & Drop (40h) → 65% auf 75%

**Mit 112h Entwicklung: 36% → 85% Feature-Parity**

---

*Zusammenfassung erstellt: 2026-01-12*
