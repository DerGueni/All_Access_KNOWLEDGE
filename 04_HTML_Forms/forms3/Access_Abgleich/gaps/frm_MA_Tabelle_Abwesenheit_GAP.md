# Gap-Analyse: frm_MA_Tabelle & frm_MA_Abwesenheit

**Datum:** 2026-01-12
**Analysetyp:** Access → HTML Funktionsvergleich
**Status:** Beide Formulare existieren, aber mit unterschiedlichem Entwicklungsstand

---

## 1. frm_MA_Tabelle (MitarbeiterstammTabelle)

### 1.1 Access-Formular

**Zweck:** Tabellarische Übersicht aller Mitarbeiter-Stammdaten

**Eigenschaften:**
- **Name:** frm_Mitarbeiterstamm Tabelle
- **Record Source:** tbl_ma_mitarbeiterstamm
- **Default View:** Other (Tabellenansicht)
- **Editierbar:** Ja (AllowEdits, AllowAdditions, AllowDeletions = True)
- **Automatische Sortierung:**
  1. IstAktiv (aktive zuerst)
  2. Nachname
  3. IstSubunternehmer (DESC)
  4. HatSachkunde
  5. Hat_keine_34a

**Datenfelder (27 Felder):**

#### Persönliche Daten
- LEXWare_ID
- Nachname, Vorname
- Geschlecht
- Geb_Dat, Geb_Ort
- Staatsang

#### Adresse
- Strasse, Nr
- PLZ, Ort

#### Kontakt
- Tel_Mobil
- Tel_Festnetz
- Email

#### Beschäftigung
- Eintrittsdatum
- Austrittsdatum
- Auszahlungsart
- Bankname
- (weitere Beschäftigungsfelder)

#### Status-CheckBoxen
- IstSubunternehmer
- (weitere Status-Felder)

**Besonderheiten:**
- DividingLines aktiviert für Tabellenansicht
- BorderColor 12566463 (grau) für Feldrahmen
- Format "@" bei Textfeldern (erzwingt Text-Eingabe)
- NavigationButtons deaktiviert

### 1.2 HTML-Implementierung

**Datei:** `04_HTML_Forms\forms3\frm_MA_Tabelle.html`

**Status:** ❌ **PLACEHOLDER ONLY**

**Aktueller Inhalt:**
```html
<div class="placeholder">
    <h1>Mitarbeiter-Tabelle</h1>
    <p>Tabellarische Übersicht aller Mitarbeiter.</p>
    <p><em>HTML-Version in Entwicklung</em></p>
    <button class="btn" onclick="history.back()">Zurück</button>
    <button class="btn" onclick="Bridge.close()">Schließen</button>
</div>
```

**Logic-Datei:** ❌ **NICHT VORHANDEN**
`frm_MA_Tabelle.logic.js` existiert nicht

### 1.3 Gap-Analyse: frm_MA_Tabelle

| Feature | Access | HTML | Gap | Priorität |
|---------|--------|------|-----|-----------|
| **Tabellenansicht** | ✅ | ❌ | Keine HTML-Grid-Komponente | 🔴 HOCH |
| **Spalten-Sortierung** | ✅ Automatisch | ❌ | OrderBy nach IstAktiv, Nachname, etc. fehlt | 🔴 HOCH |
| **Inline-Editing** | ✅ | ❌ | Alle Felder editierbar im Grid | 🟠 MITTEL |
| **27 Datenfelder** | ✅ | ❌ | Alle Felder müssen als Spalten dargestellt werden | 🔴 HOCH |
| **Filter/Suche** | ❌ | ❌ | Weder Access noch HTML haben Filter | 🟡 NIEDRIG |
| **Export-Funktion** | ❌ | ❌ | Keine Export-Buttons erkennbar | 🟡 NIEDRIG |
| **Navigation** | ⚠️ Ohne Buttons | ❌ | Navigation via Scrolling | 🟡 NIEDRIG |
| **REST-API Integration** | - | ❌ | Keine Datenanbindung implementiert | 🔴 HOCH |
| **Logic-Datei** | - | ❌ | frm_MA_Tabelle.logic.js fehlt | 🔴 HOCH |

**Fehlende Komponenten:**
1. ❌ HTML-Tabellen-Grid mit allen 27 Spalten
2. ❌ Sortierung nach IstAktiv → Nachname → IstSubunternehmer
3. ❌ Inline-Editing-Funktionalität
4. ❌ API-Anbindung an `/api/mitarbeiter`
5. ❌ Logic-Datei für Datenladung und Interaktion
6. ❌ Spalten-Resizing und horizontales Scrolling
7. ❌ Checkbox-Controls für Status-Felder

**Geschätzter Entwicklungsaufwand:** 🔴 **8-12 Stunden**
- 3-4h: HTML-Grid mit allen Spalten und horizontalem Scrolling
- 2-3h: Sortierung und Filter-Logik
- 2-3h: Inline-Editing mit Validierung
- 1-2h: API-Integration und CRUD-Operationen

---

## 2. frm_MA_Abwesenheit (Abwesenheiten_Urlaub_Gueni)

### 2.1 Access-Formulare (2 Varianten)

#### Variante A: frm_MA_Abwesenheiten_Urlaub_Gueni (Kreuztabelle)

**Zweck:** Urlaubsübersicht pro Mitarbeiter und Monat (Kreuztabellen-Auswertung)

**Eigenschaften:**
- **Record Source:** qry_MA_Abwesenheiten_Urlaub_Gueni_KT (Kreuztabellenabfrage)
- **Default View:** ContinuousForms (Endlosformular)
- **Editierbar:** Ja (aber nur lesend verwendet)

**Datenfelder:**
- Name (Mitarbeiter)
- Jahr
- Jan, Feb, Mrz, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez (12 Monatsfelder)
- Gesamtsumme von Zeittyp_ID (Jahressumme)

**Layout:**
- Mitarbeitername in Spalte 1
- Jahr in Spalte 2
- Alle 12 Monate vertikal untereinander (nicht horizontal!)
- Summe am Ende

**Besonderheiten:**
- Kompaktes Layout für Übersicht
- Kreuztabellen-Query als Datenquelle
- Navigationsbuttons aktiviert
- Keine Events implementiert

#### Variante B: frmTop_MA_Abwesenheitsplanung (Eingabeformular)

**Zweck:** Abwesenheiten berechnen und erfassen

**Eigenschaften:**
- **Record Source:** tbltmp_Fehlzeiten (Temporäre Tabelle)
- **Default View:** Single Form
- **Event-gesteuert:** VBA-Code für Berechnung und Speichern

**Hauptfunktionen:**
1. **Eingabefelder:**
   - cbo_MA_ID (Mitarbeiter-Dropdown)
   - cboAbwGrund (Abwesenheitsgrund)
   - Bemerkung
   - DatVon, DatBis (Zeitraum)
   - AbwesenArt (Radio: Ganztag/Teilzeit)
   - TlZeitVon, TlZeitBis (Zeit von/bis)
   - NurWerktags (Checkbox)

2. **Berechnung (btnAbwBerechnen_Click):**
   - Validiert Eingaben
   - Iteriert über Datumsbereich
   - Filtert Wochenenden/Feiertage (wenn NurWerktags)
   - Erstellt Einträge in tbltmp_Fehlzeiten

3. **Vorschau (lsttmp_Fehlzeiten):**
   - Zeigt berechnete Abwesenheiten
   - Multi-Select zum Löschen einzelner Einträge
   - btnMarkLoesch_Click, btnAllLoesch_Click

4. **Übernehmen (bznUebernehmen_Click):**
   - INSERT INTO tbl_MA_NVerfuegZeiten
   - Aktualisiert Zeit-Aggregationen
   - Leert Temp-Tabelle

**Events:**
- Form_Open: Initialisiert, leert Temp-Tabelle
- cbo_MA_ID_AfterUpdate: Filtert Gründe nach Anstellungsart
- AbwesenArt_AfterUpdate: Aktiviert/deaktiviert Zeitfelder
- DatVon_DblClick, DatBis_DblClick: Kalender öffnen

### 2.2 HTML-Implementierung

**Datei:** `04_HTML_Forms\forms3\frm_MA_Abwesenheit.html`
**Logic-Datei:** `04_HTML_Forms\forms3\logic\frm_MA_Abwesenheit.logic.js`

**Status:** ✅ **TEILWEISE IMPLEMENTIERT**

**HTML-Struktur:**
1. **Sidebar-Navigation** (left-menu)
2. **Form-Header** mit Titel und Datum
3. **Content Area:**
   - **Input Section** (Eingabefelder)
     - Mitarbeiter-Auswahl
     - Abwesenheitsgrund
     - Zeitraum (Von/Bis)
     - Ganztag/Teilzeit Radio
     - Nur-Werktags Checkbox
     - Buttons: Berechnen, Übernehmen
   - **List Section** (Vorschau-Tabelle)
     - Checkbox-Select
     - Spalten: ID, Mitarbeiter, Von, Bis, Grund, Bemerkung
     - Buttons: Markierte löschen, Alle löschen
4. **Status Bar**

**JavaScript-Implementierung (in HTML embedded):**
- ✅ State-Management (fehlzeiten, maLookup, gruendeLookup)
- ✅ Form_Open Logik (DELETE * FROM tbltmp_Fehlzeiten simuliert)
- ✅ AbwesenArt_AfterUpdate (Zeitfelder enable/disable)
- ✅ cbo_MA_ID_AfterUpdate (Gründe-Filter nach Anstellungsart)
- ✅ btnAbwBerechnen_Click (Loop durch Datumsbereich)
- ✅ bznUebernehmen_Click (API-Call /api/abwesenheiten)
- ✅ btnMarkLoesch_Click, btnAllLoesch_Click
- ✅ Checkbox-Select (All + Individual)
- ✅ Datum-Wochentag-Anzeige (lblDatVonTag, lblDatBisTag)
- ✅ API-Anbindung (loadMitarbeiter, loadAbwesenheitsgruende)

**Logic-Datei: frm_MA_Abwesenheit.logic.js**

**Status:** ⚠️ **ALTERNATIVE IMPLEMENTIERUNG**

Diese Logic-Datei implementiert ein **ANDERES KONZEPT**:
- Import von `bridgeClient.js`
- CRUD für `tbl_MA_NVerfuegZeiten` (nicht temporär)
- Navigation (Erster, Vorheriger, Nächster, Letzter)
- Mini-Kalender mit Range-Highlighting
- Liste mit Click-to-Edit
- Kein "Berechnen → Vorschau → Übernehmen" Workflow

**⚠️ INKONSISTENZ:** HTML hat Logic inline, Logic.js hat anderen Ansatz!

### 2.3 Gap-Analyse: frm_MA_Abwesenheit

#### Variante A: Kreuztabelle (Urlaubs-Auswertung)

| Feature | Access | HTML | Gap | Priorität |
|---------|--------|------|-----|-----------|
| **Kreuztabelle** | ✅ 12 Monate | ❌ | Keine Pivot/Kreuztabellen-Darstellung | 🔴 HOCH |
| **Monats-Aggregation** | ✅ Jan-Dez | ❌ | qry_MA_Abwesenheiten_Urlaub_Gueni_KT fehlt | 🔴 HOCH |
| **Jahressumme** | ✅ | ❌ | Gesamtsumme-Berechnung fehlt | 🟠 MITTEL |
| **Export nach Excel** | ❌ | ❌ | Keine Export-Funktion erkennbar | 🟡 NIEDRIG |
| **Drill-Down** | ❌ | ❌ | Click auf Monat → Details | 🟡 NIEDRIG |

**Fehlende Komponenten:**
1. ❌ Separates HTML-Formular für Kreuztabellen-Auswertung
2. ❌ API-Endpoint `/api/abwesenheiten/kreuztabelle`
3. ❌ Pivot-Grid oder Kreuztabellen-Komponente
4. ❌ Monats-Aggregations-Logik
5. ❌ Jahressummen-Berechnung

**Empfehlung:** ⚠️ **Separates Formular erstellen:** `frm_MA_Abwesenheit_Auswertung.html`

#### Variante B: Eingabeformular (Planung)

| Feature | Access | HTML (inline) | HTML (logic.js) | Gap | Priorität |
|---------|--------|---------------|-----------------|-----|-----------|
| **Mitarbeiter-Dropdown** | ✅ | ✅ | ✅ | - | ✅ |
| **Gründe-Dropdown** | ✅ Filter nach Anstellungsart | ✅ | ✅ | - | ✅ |
| **Zeitraum Von/Bis** | ✅ | ✅ | ✅ | - | ✅ |
| **Ganztag/Teilzeit Radio** | ✅ | ✅ | ✅ | - | ✅ |
| **Zeit Von/Bis** | ✅ Disable bei Ganztag | ✅ | ✅ | - | ✅ |
| **Nur-Werktags Filter** | ✅ | ✅ | ⚠️ Fehlt | logic.js hat keine Nur-Werktags Berechnung | 🟠 MITTEL |
| **Feiertags-Check** | ✅ create_Default_AlleTage | ⚠️ TODO-Kommentar | ❌ | Keine Feiertags-API integriert | 🟠 MITTEL |
| **Berechnen-Button** | ✅ btnAbwBerechnen_Click | ✅ | ❌ | logic.js hat keinen Berechnen-Workflow | 🔴 HOCH |
| **Vorschau-Tabelle** | ✅ lsttmp_Fehlzeiten | ✅ tblFehlzeiten | ❌ | logic.js zeigt direkt aus DB | 🔴 HOCH |
| **Temp-Tabelle** | ✅ tbltmp_Fehlzeiten | ✅ state.fehlzeiten (Memory) | ❌ | logic.js arbeitet direkt auf DB | 🔴 HOCH |
| **Übernehmen-Button** | ✅ bznUebernehmen_Click | ✅ | ❌ | logic.js hat nur Save (direkt DB) | 🔴 HOCH |
| **Markierte löschen** | ✅ | ✅ | ❌ | logic.js löscht nur einzelnen Datensatz | 🟠 MITTEL |
| **Alle löschen** | ✅ | ✅ | ❌ | logic.js hat keine Temp-Clear-Funktion | 🟠 MITTEL |
| **Kalender-Integration** | ✅ DatVon_DblClick | ⚠️ Basic HTML5 date | ✅ Mini-Kalender | logic.js hat besseren Kalender | 🟡 NIEDRIG |
| **Navigation** | ❌ | ❌ | ✅ Erster/Vorheriger/Nächster/Letzter | logic.js hat mehr Features | 🟡 NIEDRIG |
| **API /abwesenheiten** | - | ✅ POST | ✅ CRUD | Beide implementiert | ✅ |
| **Zeit-Update Queries** | ✅ qry_MA_NVerfueg_ZeitUpdate | ⚠️ Backend | ❌ | Updates nach INSERT fehlen | 🟠 MITTEL |

**Kritische Inkonsistenz:**
- **HTML (inline JS):** Implementiert Access-Konzept (Berechnen → Vorschau → Übernehmen)
- **logic.js:** Implementiert CRUD-Konzept (Direkt DB-Editing ohne Vorschau)
- **❌ KEINE DER BEIDEN IST MIT DER ANDEREN KOMPATIBEL!**

**Empfehlung:** 🔴 **ENTSCHEIDUNG ERFORDERLICH:**
1. **Option A:** Inline-JS entfernen, logic.js erweitern um Berechnen-Workflow
2. **Option B:** logic.js löschen, inline-JS in separates Modul extrahieren
3. **Option C:** Beide behalten, zwei separate Formulare erstellen:
   - `frm_MA_Abwesenheit_Planung.html` (Berechnen-Workflow)
   - `frm_MA_Abwesenheit_Verwaltung.html` (CRUD-Workflow)

### 2.4 Fehlende Access-Features in HTML

**Nicht implementiert (Access vorhanden):**
1. ❌ Kreuztabellen-Auswertung (frm_MA_Abwesenheiten_Urlaub_Gueni)
2. ⚠️ Feiertags-Check via `create_Default_AlleTage()`
3. ⚠️ Anstellungsart-Filter für Gründe:
   - Minijobber (ID=5): ohne Krank (ID=6?) und Urlaub (ID=7?)
   - Andere: ohne Hauptjob (ID=11?)
4. ⚠️ Zeit-Update-Queries nach INSERT:
   - `qry_MA_NVerfueg_ZeitUpdate`
   - `qry_MA_NVerfueg_ZeitUpdate_2`
5. ❌ Zeitüberschneidungs-Prüfung
6. ❌ Wochenende-Erkennung basierend auf MA-Einstellungen

**Besser in HTML:**
1. ✅ Mini-Kalender mit Range-Highlighting (logic.js)
2. ✅ Wochentag-Anzeige bei Datums-Auswahl
3. ✅ Moderne UI mit Sidebar-Navigation
4. ✅ Responsive Design

---

## 3. Zusammenfassung & Empfehlungen

### 3.1 frm_MA_Tabelle

**Status:** ❌ **NICHT IMPLEMENTIERT** (nur Placeholder)

**Kritische Gaps:**
1. Keine HTML-Grid-Komponente
2. Keine Sortierung nach IstAktiv, Nachname
3. Keine REST-API Integration
4. Keine Logic-Datei

**Empfohlene Aktionen:**
1. 🔴 **Prio 1:** HTML-Grid mit allen 27 Spalten erstellen
2. 🔴 **Prio 1:** API-Endpoint `/api/mitarbeiter?view=table` implementieren
3. 🔴 **Prio 1:** Logic-Datei `frm_MA_Tabelle.logic.js` erstellen
4. 🟠 **Prio 2:** Inline-Editing-Funktionalität
5. 🟠 **Prio 2:** Sortierung nach OrderBy-Kriterien
6. 🟡 **Prio 3:** Export nach Excel/CSV

**Template-Vorschlag:** AG-Grid oder Tabulator.js für komplexe Tabellen

### 3.2 frm_MA_Abwesenheit

**Status:** ⚠️ **INKONSISTENT IMPLEMENTIERT**

**Kritische Gaps:**
1. 🔴 Inline-JS vs. logic.js: Zwei verschiedene Ansätze
2. 🔴 Kreuztabellen-Auswertung fehlt komplett
3. 🟠 Feiertags-API nicht integriert
4. 🟠 Zeit-Update-Queries fehlen

**Empfohlene Aktionen:**

#### Kurzfristig (1-2 Tage):
1. 🔴 **Entscheidung treffen:** Berechnen-Workflow vs. CRUD-Workflow
2. 🔴 **Wenn Berechnen-Workflow:** Inline-JS in `frm_MA_Abwesenheit.logic.js` extrahieren
3. 🔴 **Wenn CRUD-Workflow:** HTML-Inline-JS löschen, logic.js verwenden
4. 🟠 **Feiertags-API:** Integriere z.B. `https://feiertage-api.de/`
5. 🟠 **Zeit-Update:** Backend-Endpoint `/api/abwesenheiten/update-zeitkonten`

#### Mittelfristig (3-5 Tage):
6. 🔴 **Separates Formular:** `frm_MA_Abwesenheit_Auswertung.html` für Kreuztabelle
7. 🟠 **API-Endpoint:** `/api/abwesenheiten/kreuztabelle?jahr=2026`
8. 🟠 **Pivot-Grid:** Implementiere Kreuztabellen-Komponente
9. 🟡 **Export:** Excel-Export für Auswertung

### 3.3 Geschätzter Gesamt-Aufwand

| Formular | Status | Aufwand | Priorität |
|----------|--------|---------|-----------|
| **frm_MA_Tabelle** | ❌ Nicht implementiert | 8-12h | 🔴 HOCH |
| **frm_MA_Abwesenheit (Planung)** | ⚠️ Inkonsistent | 4-6h | 🔴 HOCH |
| **frm_MA_Abwesenheit (Auswertung)** | ❌ Nicht implementiert | 6-8h | 🟠 MITTEL |
| **API-Endpoints** | ⚠️ Teilweise | 2-3h | 🔴 HOCH |
| **Feiertags-Integration** | ❌ Fehlt | 2-3h | 🟠 MITTEL |

**Gesamt:** 22-32 Stunden

---

## 4. Technische Details

### 4.1 Erforderliche API-Endpoints

#### Für frm_MA_Tabelle:
```http
GET /api/mitarbeiter?view=table&sort=IstAktiv,Nachname&limit=1000
PUT /api/mitarbeiter/:id (Inline-Update)
```

#### Für frm_MA_Abwesenheit (Planung):
```http
GET /api/mitarbeiter?aktiv=true
GET /api/dienstplan/gruende (bereits vorhanden)
POST /api/abwesenheiten (bereits vorhanden)
POST /api/abwesenheiten/batch (für Übernehmen-Button)
POST /api/abwesenheiten/update-zeitkonten (Zeit-Updates)
```

#### Für frm_MA_Abwesenheit (Auswertung):
```http
GET /api/abwesenheiten/kreuztabelle?jahr=2026&ma_id=123
GET /api/abwesenheiten/statistik?von=2026-01-01&bis=2026-12-31
```

#### Feiertags-Integration:
```http
GET https://feiertage-api.de/api/?jahr=2026&nur_land=BY
```

### 4.2 Erforderliche VBA-Änderungen

**Keine VBA-Änderungen erforderlich**, da:
- frm_MA_Tabelle keine Events hat
- frm_MA_Abwesenheiten_Urlaub_Gueni keine Events hat
- frmTop_MA_Abwesenheitsplanung bereits vollständig in HTML/JS repliziert

### 4.3 Datenbank-Schema

**Tabellen (bereits vorhanden):**
- `tbl_MA_Mitarbeiterstamm` (27+ Felder)
- `tbl_MA_NVerfuegZeiten` (ID, MA_ID, vonDat, bisDat, Grund, Ganztaegig, vonZeit, bisZeit, Bemerkung)

**Queries:**
- `qry_MA_Abwesenheiten_Urlaub_Gueni_KT` (Kreuztabelle) → Muss in HTML/JS nachgebaut werden

**Temporäre Tabelle:**
- `tbltmp_Fehlzeiten` (nur in Access, in HTML als `state.fehlzeiten` Array)

---

## 5. Priorisierte Roadmap

### Phase 1: Kritische Fixes (1-2 Tage)
1. ✅ **frm_MA_Abwesenheit:** Entscheide zwischen Berechnen-Workflow vs. CRUD
2. ✅ **frm_MA_Abwesenheit:** Extrahiere Inline-JS in logic.js ODER lösche logic.js
3. ✅ **API:** Teste `/api/abwesenheiten` POST für Batch-Insert

### Phase 2: frm_MA_Tabelle (3-4 Tage)
4. ✅ **HTML-Grid:** Implementiere mit AG-Grid oder Tabulator.js
5. ✅ **Logic-Datei:** Erstelle `frm_MA_Tabelle.logic.js`
6. ✅ **API-Integration:** Lade alle 27 Felder via `/api/mitarbeiter`
7. ✅ **Sortierung:** Implementiere OrderBy nach IstAktiv, Nachname, etc.
8. ✅ **Inline-Editing:** Aktiviere Cell-Editing für alle Felder

### Phase 3: Abwesenheit Auswertung (2-3 Tage)
9. ✅ **Separates Formular:** Erstelle `frm_MA_Abwesenheit_Auswertung.html`
10. ✅ **API-Endpoint:** Implementiere `/api/abwesenheiten/kreuztabelle`
11. ✅ **Kreuztabelle:** Pivot-Grid mit 12 Monaten und Summen
12. ✅ **Export:** Excel-Export-Funktion

### Phase 4: Feinschliff (1-2 Tage)
13. ✅ **Feiertags-API:** Integriere externe API
14. ✅ **Zeit-Updates:** Backend-Endpoint für qry_MA_NVerfueg_ZeitUpdate
15. ✅ **Testing:** E2E-Tests für alle Workflows
16. ✅ **Dokumentation:** User-Guide für beide Formulare

---

## 6. Offene Fragen

1. **frm_MA_Tabelle:**
   - Welche der 27 Felder sollen read-only sein?
   - Brauchen wir Filter/Suche-Funktionen?
   - Soll es Export nach Excel geben?

2. **frm_MA_Abwesenheit:**
   - Behalten wir beide Workflows (Berechnen + CRUD) als separate Formulare?
   - Welche Bundesland-Feiertage sollen geprüft werden?
   - Soll die Kreuztabelle nach Jahr oder Datum-Range filtern?

3. **API:**
   - Ist `/api/abwesenheiten` bereits vollständig implementiert?
   - Sind qry_MA_NVerfueg_ZeitUpdate als Stored Procedures verfügbar?

4. **Priorisierung:**
   - Was ist wichtiger: frm_MA_Tabelle oder Kreuztabellen-Auswertung?
   - Gibt es andere Formulare mit höherer Priorität?

---

**Analysiert von:** Claude Code
**Letzte Aktualisierung:** 2026-01-12
**Nächste Schritte:** Entscheidung zu frm_MA_Abwesenheit-Workflows durch Benutzer
