# AUDIT: Weitere HTML-Formulare vs Access-Originale

**Erstellt:** 2026-01-05
**Pfad:** forms3/
**Gepruefte Formulare:** frm_DP_Dienstplan_MA, frm_N_Dienstplanuebersicht, frm_DP_Dienstplan_Objekt (Planungsuebersicht), frm_Einsatzuebersicht

---

## Zusammenfassung

| Formular | Status | Bewertung |
|----------|--------|-----------|
| frm_DP_Dienstplan_MA.html | Teilweise implementiert | TEILWEISE |
| frm_N_Dienstplanuebersicht.html | Vollstaendig implementiert | VOLLSTAENDIG |
| frm_DP_Dienstplan_Objekt.html | Vollstaendig implementiert | VOLLSTAENDIG |
| frm_Einsatzuebersicht.html | Nur Platzhalter | FEHLT |

---

## 1. frm_DP_Dienstplan_MA.html (Dienstplan Mitarbeiter)

### Status: TEILWEISE

### Vorhandene Elemente

| Feature | Status | Details |
|---------|--------|---------|
| **Buttons/Event-Handler** | VOLLSTAENDIG | btnVor, btnrueck, btn_Heute, btnDPSenden, btnMADienstpl, btnOutpExcel vorhanden |
| **Datumsfelder** | VOLLSTAENDIG | Datumswahl mit Navigation (vor/zurueck/heute) |
| **Kalender/Grid-Anzeige** | VOLLSTAENDIG | 7-Tage Raster mit Tag1-Tag7 Spalten |
| **Datenladung bei Datumswechsel** | VOLLSTAENDIG | loadWeekData() in Logic.js |
| **Datensatznavigation** | VOLLSTAENDIG | navigateWeek(direction) implementiert |
| **Druckfunktion** | FEHLT | Keine Print-Funktion gefunden |
| **Export-Funktion** | VOLLSTAENDIG | exportExcel() in Logic.js |

### Logic.js Funktionen (frm_DP_Dienstplan_MA.logic.js)

```javascript
// Vorhandene Funktionen:
- init()
- setupEventListeners()
- loadWeekData()
- navigateWeek(direction)
- goToToday()
- renderCalendar(data)
- exportExcel()
- sendDienstplan()
```

### Fehlende Funktionen gegenueber Access VBA

| VBA-Funktion | HTML-Aequivalent | Status |
|--------------|------------------|--------|
| fCreate_DP_MA_tmptable() | loadWeekData() | VORHANDEN (andere Implementierung) |
| Filter: NurAktiveMA | Filter-Checkboxen | TEILWEISE (UI vorhanden, Logic pruefen) |
| Druckvorschau | - | FEHLT |

---

## 2. frm_N_Dienstplanuebersicht.html

### Status: VOLLSTAENDIG

### Vorhandene Elemente

| Feature | Status | Details |
|---------|--------|---------|
| **Buttons/Event-Handler** | VOLLSTAENDIG | Navigation, Filter, Export-Buttons |
| **Datumsfelder** | VOLLSTAENDIG | Datepicker mit Wochennavigation |
| **Kalender/Grid-Anzeige** | VOLLSTAENDIG | 7-Tage Grid mit MA-Zeilen |
| **Datenladung bei Datumswechsel** | VOLLSTAENDIG | loadData() bei Datumswechsel |
| **Datensatznavigation** | VOLLSTAENDIG | Vor/Zurueck/Heute Buttons |
| **Filter-Optionen** | VOLLSTAENDIG | NurFreieSchichten, IstAuftrAusblend |
| **Export-Funktion** | VOLLSTAENDIG | CSV/Excel Export |

### Logic.js Funktionen (frm_N_Dienstplanuebersicht.logic.js)

```javascript
// Vorhandene Funktionen:
- init()
- setupEventListeners()
- loadData()
- navigateWeek(direction)
- goToToday()
- applyFilters()
- renderGrid(data)
- exportToExcel()
- handleCellClick(cell)
```

### Besonderheiten
- Feiertage-Array fuer 2025 integriert (FEIERTAGE_2025)
- Sidebar-Navigation vollstaendig
- WebView2-Bridge Integration via Bridge.sendEvent()

---

## 3. frm_DP_Dienstplan_Objekt.html (Planungsuebersicht)

### Status: VOLLSTAENDIG

### Vorhandene Elemente

| Feature | Status | Details |
|---------|--------|---------|
| **Buttons/Event-Handler** | VOLLSTAENDIG | Alle Navigation- und Filter-Buttons |
| **Datumsfelder** | VOLLSTAENDIG | Wochenauswahl mit Vor/Zurueck |
| **Kalender/Grid-Anzeige** | VOLLSTAENDIG | 7-Tage Raster mit Auftrag/VA-Zeilen |
| **Datenladung bei Datumswechsel** | VOLLSTAENDIG | loadData() mit von/bis Parameter |
| **Datensatznavigation** | VOLLSTAENDIG | navigateWeek() implementiert |
| **Filter-Optionen** | VOLLSTAENDIG | NurIstNichtZugeordnet, IstAuftrAusblend |
| **Export-Funktion** | VOLLSTAENDIG | exportExcel() vorhanden |
| **Sidebar-Navigation** | VOLLSTAENDIG | Komplette Menu-Integration |

### Logic.js Funktionen (frm_DP_Dienstplan_Objekt.logic.js)

```javascript
// State-Verwaltung:
const state = {
    startDate: null,
    auftraege: [],
    zuordnungen: {},
    filters: {
        nurNichtZugeordnet: false,
        auftragAusgeblendet: false
    }
};

// Vorhandene Funktionen:
- init()
- setupEventListeners()
- navigateWeek(direction)
- goToToday()
- loadData()
- renderCalendar()
- applyFilters()
- exportExcel()
- handleAssignment(cell)
```

### Vergleich mit Access VBA (mdl_DP_Create.bas)

| VBA-Funktion | HTML-Funktion | Status |
|--------------|---------------|--------|
| fCreate_DP_tmptable() | loadData() | VORHANDEN |
| qry_DP_Alle_Obj | API-Call | VORHANDEN |
| qry_DP_Kreuztabelle | renderCalendar() | VORHANDEN |
| Filter iNurAktiveMA | filters.nurNichtZugeordnet | ANGEPASST |
| Tag1-7_Zuo_ID | state.zuordnungen | VORHANDEN |

---

## 4. frm_Einsatzuebersicht.html

### Status: FEHLT (NUR PLATZHALTER)

### Aktueller Inhalt

```html
<div class="placeholder-box">
    <h1>Einsatzuebersicht</h1>
    <p>Dieses Formular ist ein Platzhalter.</p>
    <p>Die vollstaendige Implementierung folgt.</p>
    <p class="status">Status: In Entwicklung</p>
</div>
```

### Vorhandene Elemente

| Feature | Status | Details |
|---------|--------|---------|
| **Buttons/Event-Handler** | FEHLT | Nur Close-Button vorhanden |
| **Datumsfelder** | FEHLT | - |
| **Kalender/Grid-Anzeige** | FEHLT | - |
| **Datenladung** | FEHLT | - |
| **Datensatznavigation** | FEHLT | - |
| **Filter-Optionen** | FEHLT | - |
| **Export-Funktion** | FEHLT | - |
| **Logic.js** | FEHLT | Keine Logic-Datei vorhanden |

### Erforderliche Implementierung

Basierend auf Access-Original werden benoetigt:
1. Einsatzliste mit Datum/Objekt/MA-Uebersicht
2. Filterung nach Zeitraum
3. Gruppierung nach Objekt oder MA
4. Export-Funktion (CSV/Excel)
5. Druckfunktion
6. Detailansicht bei Klick

---

## VBA-Module Referenz (mdl_DP_Create.bas)

### Hauptfunktionen

```vba
' Erstellt temporaere Tabellen fuer Objekt-basierte Ansicht
Public Function fCreate_DP_tmptable(ByVal vonDatum As Date, ByVal bisDatum As Date, _
    Optional ByVal iVA_ID As Long = 0, _
    Optional ByVal iNurFreieSchichten As Boolean = False, _
    Optional ByVal iIstAuftrAusblend As Boolean = False) As Boolean

' Erstellt temporaere Tabellen fuer MA-basierte Ansicht
Public Function fCreate_DP_MA_tmptable(ByVal vonDatum As Date, ByVal bisDatum As Date, _
    Optional ByVal iMA_ID As Long = 0, _
    Optional ByVal iNurAktiveMA As Integer = 0) As Boolean
```

### Filter-Parameter (iNurAktiveMA)
- 0 = Alle Mitarbeiter
- 1 = Nur Aktive
- 2 = Nur Festangestellte
- 3 = Nur Minijobber
- 4 = Nur Subs

### Temporaere Tabellen
- `tbltmp_DP_Grund` - Basis-Daten
- `tbltmp_DP_MA_Grund_FI` - MA-bezogene Daten

---

## Empfehlungen

### Prioritaet 1 (Kritisch)
- [ ] **frm_Einsatzuebersicht.html** vollstaendig implementieren
  - Logic.js erstellen
  - Grid-Ansicht mit Einsatzdaten
  - Filter und Export

### Prioritaet 2 (Wichtig)
- [ ] Druckfunktion in frm_DP_Dienstplan_MA.html hinzufuegen
- [ ] Filter-Logic in frm_DP_Dienstplan_MA.html vervollstaendigen

### Prioritaet 3 (Optional)
- [ ] Feiertage-Array fuer 2026 aktualisieren
- [ ] Performance-Optimierung bei grossen Datenmengen

---

## Dateien-Uebersicht

```
forms3/
├── frm_DP_Dienstplan_MA.html          [TEILWEISE]
├── frm_DP_Dienstplan_MA.logic.js      [VORHANDEN]
├── frm_N_Dienstplanuebersicht.html    [VOLLSTAENDIG]
├── frm_N_Dienstplanuebersicht.logic.js [VORHANDEN]
├── frm_DP_Dienstplan_Objekt.html      [VOLLSTAENDIG]
├── frm_DP_Dienstplan_Objekt.logic.js  [VORHANDEN]
├── frm_Einsatzuebersicht.html         [NUR PLATZHALTER]
└── frm_Einsatzuebersicht.logic.js     [FEHLT]
```

---

**Ende des Audit-Berichts**
