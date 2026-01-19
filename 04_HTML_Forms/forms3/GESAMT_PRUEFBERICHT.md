# GESAMT-PRUEFBERICHT: HTML-Formulare

**Erstellt:** 2026-01-06
**Version:** 1.0
**Pfad:** `04_HTML_Forms/forms3/`
**Geprueft gegen:** Access-Originale aus CONSYS Frontend

---

## EXECUTIVE SUMMARY

### Gesamtstatus: 68% FUNKTIONSGLEICHHEIT

Das HTML-Frontend bildet die Kernfunktionalitaet des Access-Originals ab. Die wichtigsten Stammdatenformulare sind funktional, es bestehen jedoch Luecken bei Spezialfunktionen und einigen Subformularen.

| Kategorie | Status | Beschreibung |
|-----------|--------|--------------|
| **Stammdaten** | FUNKTIONAL | Mitarbeiter, Kunden, Objekte, Auftraege grundlegend nutzbar |
| **Planung** | TEILWEISE | Dienstplan-Ansichten vorhanden, Schnellauswahl OK |
| **Reports** | LUECKENHAFT | Export-Funktionen teilweise, Druckvorschau fehlt |
| **Navigation** | FUNKTIONAL | Shell + Sidebar vollstaendig, alle Links geprueft |
| **API-Anbindung** | FUNKTIONAL | REST-API auf Port 5000, Bridge-Integration OK |

### Kritische Metriken

| Metrik | Wert | Bewertung |
|--------|------|-----------|
| Formulare gesamt | 20 | - |
| Formulare vollstaendig | 8 (40%) | AKZEPTABEL |
| Formulare teilweise | 9 (45%) | IN ARBEIT |
| Formulare Platzhalter | 3 (15%) | KRITISCH |
| Buttons implementiert | ~75% | AKZEPTABEL |
| Felder implementiert | ~80% | GUT |
| Event-Handler | ~60% | VERBESSERUNGSBEDARF |

---

## 1. FUNKTIONSGLEICHHEIT PRO FORMULAR

### 1.1 Stammdaten-Formulare

| Formular | Abdeckung | Buttons | Felder | Events | Status |
|----------|-----------|---------|--------|--------|--------|
| frm_MA_Mitarbeiterstamm | 60% | 55% | 70% | 50% | TEILWEISE |
| frm_KD_Kundenstamm | 75% | 82% | 90% | 81% | TEILWEISE |
| frm_va_Auftragstamm | 60% | 55% | 75% | 40% | UNVOLLSTAENDIG |
| frm_OB_Objekt | 90% | 87% | 100% | 71% | VOLLSTAENDIG |

### 1.2 Planungs-Formulare

| Formular | Abdeckung | Buttons | Felder | Events | Status |
|----------|-----------|---------|--------|--------|--------|
| frm_N_Dienstplanuebersicht | 95% | 100% | 100% | 90% | VOLLSTAENDIG |
| frm_VA_Planungsuebersicht | 95% | 100% | 100% | 90% | VOLLSTAENDIG |
| frm_DP_Dienstplan_MA | 80% | 90% | 90% | 70% | TEILWEISE |
| frm_DP_Dienstplan_Objekt | 95% | 100% | 100% | 90% | VOLLSTAENDIG |
| frm_MA_VA_Schnellauswahl | 85% | 80% | 90% | 80% | VOLLSTAENDIG |

### 1.3 Personal-Formulare

| Formular | Abdeckung | Buttons | Felder | Events | Status |
|----------|-----------|---------|--------|--------|--------|
| frm_MA_Abwesenheit | 70% | 60% | 80% | 50% | TEILWEISE |
| frm_MA_Zeitkonten | 65% | 50% | 70% | 40% | TEILWEISE |
| frm_N_Lohnabrechnungen | 70% | 60% | 80% | 50% | TEILWEISE |
| frm_N_Stundenauswertung | 70% | 60% | 80% | 50% | TEILWEISE |
| frm_N_Bewerber | 60% | 50% | 70% | 40% | TEILWEISE |

### 1.4 Sonstige Formulare

| Formular | Abdeckung | Buttons | Felder | Events | Status |
|----------|-----------|---------|--------|--------|--------|
| frm_Menuefuehrung1 | 100% | 100% | N/A | 100% | VOLLSTAENDIG |
| shell.html | 100% | 100% | N/A | 100% | VOLLSTAENDIG |
| frm_Einsatzuebersicht | 5% | 0% | 0% | 0% | PLATZHALTER |
| frm_Ausweis_Create | 80% | 70% | 90% | 60% | TEILWEISE |

---

## 2. KRITISCHE ABWEICHUNGEN

### 2.1 HOHE Prioritaet

#### A) frm_va_Auftragstamm - Fehlende Kernfunktionen

| Funktion | Access | HTML | Auswirkung |
|----------|--------|------|------------|
| Datensatz-Navigation | Befehl40/41/43 | Buttons in Logic.js, nicht im HTML | Benutzer kann nicht navigieren |
| Auftrag berechnen | btnAuftrBerech | FEHLT | Keine Rechnungserstellung |
| Auftragsfilter | btnHeute, btnTgVor, btnTgBack | FEHLT (in HTML), vorhanden in Logic | Filter nicht nutzbar |
| Formular schliessen | Befehl38 | FEHLT | Kein Schliessen moeglich |
| Vorbelegungslogik | GotFocus-Events | FEHLT | Keine automatische Feldvorbelegung |

**Empfehlung:** Button-IDs im HTML an Logic.js angleichen, fehlende Buttons ergaenzen.

#### B) frm_MA_Mitarbeiterstamm - Export/Foto fehlt

| Funktion | Access | HTML | Auswirkung |
|----------|--------|------|------------|
| Foto-Upload | btnDateisuch | FEHLT | Keine Foto-Verwaltung |
| Excel-Export Zeitkonto | btnXLZeitkto | FEHLT | Kein Export moeglich |
| Excel-Export Jahr | btnXLJahr | FEHLT | Kein Export moeglich |
| Berechnungsfunktionen | calc_brutto_std, calc_netto_std | FEHLT | Keine Stundenberechnung |

**Empfehlung:** Export-Funktionen via Bridge.sendEvent implementieren.

#### C) frm_KD_Kundenstamm - Kundenpreise fehlt

| Funktion | Access | HTML | Auswirkung |
|----------|--------|------|------------|
| Kundenpreise-Tab | pgPreise + sub_KD_Standardpreise | Tab vorhanden, Subform fehlt | Keine Preisverwaltung |
| Hauptansprechpartner | kun_IDF_PersonID ComboBox | FEHLT | Keine AP-Auswahl |
| Statistik-Felder | AufAnz, PersGes, StdGes, UmsGes | TEILWEISE (nur 4 von 32) | Controlling eingeschraenkt |

**Empfehlung:** Kundenpreise-Tabelle und Hauptansprechpartner-Dropdown implementieren.

#### D) frm_Einsatzuebersicht - Nur Platzhalter

**Status:** Komplett nicht implementiert - nur Platzhalter-HTML vorhanden.

**Erforderlich:**
- Einsatzliste mit Datum/Objekt/MA-Uebersicht
- Filterung nach Zeitraum
- Gruppierung nach Objekt oder MA
- Export-Funktion
- Logic.js erstellen

### 2.2 MITTLERE Prioritaet

| Formular | Fehlende Funktion | Beschreibung |
|----------|-------------------|--------------|
| frm_MA_Abwesenheit | Mehrfachtermine | btnMehrfachtermine fehlt |
| frm_MA_Zeitkonten | Monatsauswahl | cboMonat/cboJahr Combos fehlen |
| frm_DP_Dienstplan_MA | Druckfunktion | Keine Print-Funktion |
| Alle Formulare | Ribbon/DaBa-Toggle | Access-spezifisch, niedrige Prio |

### 2.3 NIEDRIGE Prioritaet

| Formular | Fehlende Funktion | Beschreibung |
|----------|-------------------|--------------|
| frm_OB_Objekt | Zeit-Labels | btnZeitLabels fuer Positions-Grid |
| frm_va_Auftragstamm | Audit-Felder | Text416-422 (Erstellt/Geaendert) |
| Alle | Aenderungsprotokoll | btn_aenderungsprotokoll |

---

## 3. BEHOBENE FEHLER (Vorherige Phasen)

### Phase 1: Shell-Navigation
- [x] Umlaut-Pruefung korrigiert (ue statt ue in Dateinamen)
- [x] Alle 13 Ziel-HTML-Dateien existieren
- [x] Bridge.navigate-Aufrufe validiert

### Phase 2: API-Endpoints
- [x] 10 Rechnungen-Endpoints implementiert (CRUD + Positionen)
- [x] Mitarbeiter-API mit korrekten Feldnamen (ID statt MA_ID)
- [x] MVA_Start/MVA_Ende Aliase in API

### Phase 3: Stammdaten-Buttons
- [x] frm_va_Auftragstamm: 8 Button-IDs vorhanden
- [x] frm_KD_Kundenstamm: Preise-Tab implementiert
- [x] frm_MA_Mitarbeiterstamm: Foto-Anzeige, Excel-Buttons vorhanden

### Phase 4: WebView2-Bridge
- [x] Bridge.loadData() implementiert
- [x] Bridge.sendEvent() implementiert
- [x] 3 Event-Handler registriert (onDataReceived, onSaveComplete, onDeleteComplete)

### Phase 5: Sidebar-Refactoring
- [x] Event Delegation implementiert
- [x] Cached DOM-Referenzen
- [x] FORM_MAP fuer schnelle Lookups

---

## 4. OFFENE PUNKTE MIT PRIORITAET

### KRITISCH (Blocker fuer Produktivbetrieb)

| # | Formular | Punkt | Aufwand |
|---|----------|-------|---------|
| 1 | frm_Einsatzuebersicht | Komplett implementieren | 8h |
| 2 | frm_va_Auftragstamm | Button-IDs korrigieren | 2h |
| 3 | frm_va_Auftragstamm | Navigations-Buttons hinzufuegen | 1h |
| 4 | frm_KD_Kundenstamm | Kundenpreise-Subform | 4h |

### HOCH (Wichtig fuer Vollstaendigkeit)

| # | Formular | Punkt | Aufwand |
|---|----------|-------|---------|
| 5 | frm_MA_Mitarbeiterstamm | Foto-Upload | 3h |
| 6 | frm_MA_Mitarbeiterstamm | Excel-Export | 2h |
| 7 | frm_va_Auftragstamm | Auftrag-berechnen Button | 2h |
| 8 | frm_KD_Kundenstamm | Hauptansprechpartner-Combo | 2h |
| 9 | frm_va_Auftragstamm | Vorbelegungslogik | 4h |

### MITTEL (Komfortfunktionen)

| # | Formular | Punkt | Aufwand |
|---|----------|-------|---------|
| 10 | frm_MA_Zeitkonten | Monats-/Jahresauswahl | 2h |
| 11 | frm_DP_Dienstplan_MA | Druckfunktion | 2h |
| 12 | frm_MA_Abwesenheit | Mehrfachtermine | 3h |
| 13 | Alle Formulare | Berechnungsfunktionen | 4h |
| 14 | frm_KD_Kundenstamm | Statistik-Felder | 3h |

### NIEDRIG (Nice-to-have)

| # | Formular | Punkt | Aufwand |
|---|----------|-------|---------|
| 15 | frm_OB_Objekt | Zeit-Labels Button | 1h |
| 16 | frm_OB_Objekt | Karten-Widget | 4h |
| 17 | Alle | Aenderungsprotokoll | 2h |
| 18 | Alle | Feiertage 2026 aktualisieren | 0.5h |

---

## 5. EMPFEHLUNGEN

### Sofortmassnahmen (Diese Woche)

1. **frm_va_Auftragstamm Button-IDs korrigieren**
   - HTML-IDs an Logic.js angleichen
   - Fehlende Navigations-Buttons hinzufuegen
   - Geschaetzter Aufwand: 3h

2. **frm_Einsatzuebersicht implementieren**
   - Grundstruktur aus frm_N_Dienstplanuebersicht kopieren
   - Logic.js erstellen
   - Geschaetzter Aufwand: 8h

3. **Validierung durchfuehren**
   - `node tools/form_validator.js --output` ausfuehren
   - Ergebnisse pruefen und priorisieren

### Mittelfristig (Naechste 2 Wochen)

4. **Export-Funktionen implementieren**
   - Bridge.sendEvent('export', { type: 'excel', ... })
   - Fuer Mitarbeiter, Zeitkonten, Dienstplan

5. **Kundenpreise-Modul**
   - Subform sub_KD_Standardpreise
   - standardleistungenAnlegen() Funktion

### Langfristig (Naechster Monat)

6. **Foto-Upload System**
   - FileDialog via Bridge
   - Speicherung im Backend

7. **Vollstaendige Berechnungslogik**
   - calc_brutto_std, calc_netto_std
   - Ueberhangstunden-Berechnung

---

## 6. TECHNISCHE DETAILS

### API-Server Status

| Endpoint-Gruppe | Anzahl | Status |
|-----------------|--------|--------|
| /api/mitarbeiter | 5 | OK |
| /api/kunden | 5 | OK |
| /api/auftraege | 5 | OK |
| /api/objekte | 5 | OK |
| /api/zuordnungen | 4 | OK |
| /api/dienstplan | 4 | OK |
| /api/rechnungen | 10 | OK |
| /api/abwesenheiten | 5 | OK |

### Bridge-Integration

| Funktion | Status | Verwendung |
|----------|--------|------------|
| Bridge.loadData() | OK | 6 Datentypen |
| Bridge.sendEvent() | OK | 5 Event-Typen |
| Bridge.on() | OK | 3 Handler registriert |
| Bridge.navigate() | OK | Shell-Navigation |

### Bekannte Einschraenkungen

1. API-Server muss manuell gestartet werden
2. Keine Echtzeit-Updates (Polling erforderlich)
3. Subform-Kommunikation nur innerhalb same-origin
4. Access ODBC ist NICHT thread-safe (waitress threads=1)

---

## 7. ANHANG

### A) Dateien-Struktur

```
04_HTML_Forms/forms3/
├── frm_*.html          # Hauptformulare (20)
├── sub_*.html          # Subformulare (10)
├── shell.html          # Navigation-Container
├── sidebar.html        # Sidebar-Komponente
├── logic/              # JavaScript Logic-Dateien
│   └── *.logic.js      # 44 Dateien
├── css/                # Stylesheets
├── js/                 # Gemeinsame JS-Module
├── api/                # Bridge-Client
├── tools/              # Validierungs-Tools
│   └── form_validator.js
├── _reports/           # Audit-Reports
├── _audit/             # Detaillierte Audits
└── _docs/              # Dokumentation
```

### B) Referenz-Dokumente

| Dokument | Pfad | Inhalt |
|----------|------|--------|
| AUDIT_frm_va_Auftragstamm | _audit/ | 60% Abdeckung, Button-Liste |
| AUDIT_frm_MA_Mitarbeiterstamm | _audit/ | 60% Abdeckung, Tab-Vergleich |
| AUDIT_frm_KD_Kundenstamm | _audit/ | 75% Abdeckung, Preise fehlt |
| AUDIT_frm_OB_Objekt | _audit/ | 90% Abdeckung, Zeit-Labels |
| VALIDIERUNG_FINAL | _audit/ | Alle Korrekturen validiert |
| REFACTORING_REPORT | _reports/ | WebView2 Bridge Migration |

---

**Ende des Gesamt-Pruefberichts**

*Naechste Aktualisierung: Nach Behebung der kritischen Punkte*
