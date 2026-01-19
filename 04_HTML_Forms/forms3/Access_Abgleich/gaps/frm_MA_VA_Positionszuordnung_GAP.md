# GAP-ANALYSE: frm_MA_VA_Positionszuordnung

**Erstellt:** 2026-01-12
**Formular:** MA-VA Positionszuordnung
**Zweck:** Zuordnung von Mitarbeitern zu spezifischen Positionen/Rollen in Aufträgen

---

## 1. ÜBERSICHT

### Access-Formular
- **Record Source:** (keine - Ungebundenes Formular)
- **Default View:** Other (Custom)
- **Controls:** 43 (22 Buttons, 3 ListBoxes, 2 ComboBoxes, 1 TextBox, 1 OptionGroup, 3 OptionButtons, 11 Labels, 1 Subform)
- **Funktionalität:** Drag&Drop zwischen 3 Listen, MA-Typ Filter, Wiederholungsfunktion

### HTML-Formular
- **Layout:** 3-Panel Grid (Positionen | Verfügbare MA | Zugeordnete MA)
- **Controls:** 2 ComboBoxes (Auftrag/Datum), 3 Container-Panels, Buttons (Speichern/Aktualisieren)
- **Funktionalität:** Grundstruktur vorhanden, aber vereinfacht

---

## 2. FEHLENDE STRUKTURELEMENTE

### 2.1 Haupt-ComboBoxen

| Access Control | HTML Equivalent | Status | Bemerkung |
|----------------|-----------------|--------|-----------|
| `cbo_Akt_Objekt_Kopf` | `cboAuftrag` | ✅ VORHANDEN | Auftragsauswahl funktional |
| `cboVADatum` | `cboDatum` | ✅ VORHANDEN | Datumsauswahl funktional |

### 2.2 MA-Typ OptionGroup

| Access Control | HTML Equivalent | Status | Gap-Level |
|----------------|-----------------|--------|-----------|
| `MA_Typ` (OptionGroup) | ❌ FEHLT | ⚠️ FEHLT | **MITTEL** |
| - Option56 | ❌ FEHLT | ⚠️ FEHLT | Alle MA |
| - Option58 | ❌ FEHLT | ⚠️ FEHLT | Nur Fest |
| - Option60 | ❌ FEHLT | ⚠️ FEHLT | Nur Frei |

**Impact:** Filter nach Beschäftigungsart nicht möglich

### 2.3 Listen-Struktur

#### Access hat 3 ListBoxen:

| Access ListBox | HTML Equivalent | Status | Gap-Level |
|----------------|-----------------|--------|-----------|
| `lstMA_Zusage` | `panelVerfügbar` | ⚠️ TEILWEISE | **MITTEL** |
| `List_Pos` | `panelPositionen` | ⚠️ TEILWEISE | **MITTEL** |
| `Lst_MA_Zugeordnet` | `panelZugeordnet` | ⚠️ TEILWEISE | **MITTEL** |

**Unterschiede:**
- Access: Multi-Column ListBoxes mit nach-oben-Scrolling
- HTML: Div-basierte Listen mit einzelnen Items
- Access: AfterUpdate Events für lstMA_Zusage und List_Pos
- HTML: Click-Delegation

### 2.4 Anzahl-Anzeige TextBox

| Access Control | HTML Equivalent | Status | Gap-Level |
|----------------|-----------------|--------|-----------|
| `AnzAusw` | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |

**Zweck:** Zeigt Anzahl ausgewählter Items in lstMA_Zusage
**HTML:** Kann mit Counter-Badge ersetzt werden

---

## 3. FEHLENDE BUTTONS & AKTIONEN

### 3.1 Haupt-Navigation Buttons

| Access Button | Position | HTML Equivalent | Status | Gap-Level |
|---------------|----------|-----------------|--------|-----------|
| `btnAuftrag` | Header | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `btnBack_PosKopfTl1` | Header | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `btnPosList_PDF` | Header | ❌ FEHLT | ⚠️ FEHLT | **MITTEL** |
| `mcobtnDelete` | Header | ❌ FEHLT | ⚠️ FEHLT | **HOCH** |
| `Befehl49` | Header | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |

### 3.2 Zuordnungs-Buttons (Detail-Bereich)

| Access Button | OnClick | HTML Equivalent | Status | Gap-Level |
|---------------|---------|-----------------|--------|-----------|
| `btnAddSelected` | Procedure | ⚠️ INLINE BUTTON | TEILWEISE | **HOCH** |
| `btnAddAll` | Procedure | ❌ FEHLT | ⚠️ FEHLT | **HOCH** |
| `btnDelSelected` | Procedure | ⚠️ INLINE BUTTON | TEILWEISE | **HOCH** |
| `btnDelAll` | Procedure | ❌ FEHLT | ⚠️ FEHLT | **HOCH** |

**Impact:**
- Bulk-Operationen (Alle hinzufügen/entfernen) fehlen komplett
- Einzeln-Operationen sind über Inline-Buttons vorhanden, aber nicht wie in Access

### 3.3 Wiederholungs-Buttons

| Access Button | Position | HTML Equivalent | Status | Gap-Level |
|---------------|----------|-----------------|--------|-----------|
| `btnRepeat` | Detail Links | ❌ FEHLT | ⚠️ FEHLT | **HOCH** |
| `btnRepeatAus` | Detail Rechts | ❌ FEHLT | ⚠️ FEHLT | **HOCH** |

**Zweck:** Wiederholung der Zuordnung für andere Tage/Schichten
**Impact:** Wichtige Produktivitäts-Funktion fehlt

### 3.4 Toolbar-Buttons (6 Makro-Buttons)

| Access Button | BackColor | HTML Equivalent | Status | Gap-Level |
|---------------|-----------|-----------------|--------|-----------|
| `Befehl48` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `Befehl39` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `Befehl40` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `Befehl41` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `Befehl42` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `Befehl43` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `btnHilfe` | 16777215 | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |

**Bemerkung:** Vermutlich Quick-Access Icons/Tools

### 3.5 Ansichts-Toggle Buttons

| Access Button | Zweck | HTML Equivalent | Status | Gap-Level |
|---------------|-------|-----------------|--------|-----------|
| `btnRibbonAus` | Ribbon ausblenden | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `btnRibbonEin` | Ribbon einblenden | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `btnDaBaEin` | DB-Ansicht ein | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |
| `btnDaBaAus` | DB-Ansicht aus | ❌ FEHLT | ⚠️ FEHLT | **NIEDRIG** |

---

## 4. FEHLENDE LABELS & BESCHRIFTUNGEN

### 4.1 Haupt-Labels

| Access Label | Caption | Position | HTML Equivalent | Status |
|--------------|---------|----------|-----------------|--------|
| `Auto_Kopfzeile0` | (Titel) | 2295, 540 | `<h1 class="app-title">` | ✅ VORHANDEN |
| `lbl_Datum` | Datum-Label | 21147, 850 | `<span id="header-date">` | ✅ VORHANDEN |

### 4.2 Listen-Labels

| Access Label | Caption | Position | HTML Equivalent | Status |
|--------------|---------|----------|-----------------|--------|
| `Bezeichnungsfeld32` | (lstMA_Zusage) | 3475, 915 | `<div class="panel-header">` | ⚠️ GENERISCH |
| `Bezeichnungsfeld5` | (List_Pos) | 7335, 907 | `<div class="panel-header">` | ⚠️ GENERISCH |
| `Bezeichnungsfeld43` | (Lst_MA_Zugeordnet) | 15990, 915 | `<div class="panel-header">` | ⚠️ GENERISCH |

### 4.3 Filter-Labels

| Access Label | Caption | Position | HTML Equivalent | Status |
|--------------|---------|----------|-----------------|--------|
| `Bezeichnungsfeld1` | Auftrag | 7335, 225 | `<label class="toolbar-label">` | ✅ VORHANDEN |
| `Bezeichnungsfeld26` | Datum | 15990, 255 | `<label class="toolbar-label">` | ✅ VORHANDEN |
| `Bezeichnungsfeld55` | MA-Typ 1 | 3588, 233 | ❌ FEHLT | ⚠️ FEHLT |
| `Bezeichnungsfeld57` | MA-Typ 2 | 4266, 233 | ❌ FEHLT | ⚠️ FEHLT |
| `Bezeichnungsfeld59` | MA-Typ 3 | 5180, 233 | ❌ FEHLT | ⚠️ FEHLT |
| `Bezeichnungsfeld61` | MA-Typ 4 | 6275, 233 | ❌ FEHLT | ⚠️ FEHLT |

### 4.4 Sonstige Labels

| Access Label | Caption | Position | HTML Equivalent | Status |
|--------------|---------|----------|-----------------|--------|
| `Bezeichnungsfeld22` | (Trennlinie?) | 14295, 5865 | ❌ FEHLT | ⚠️ FEHLT |

---

## 5. FEHLENDE FUNKTIONALITÄT

### 5.1 Drag & Drop (KRITISCH!)

**Access:**
- ListBoxes unterstützen Multi-Select
- Drag & Drop zwischen Listen möglich
- Visuelle Feedback bei Drag-Over

**HTML:**
- ❌ FEHLT: Keine Drag & Drop Implementierung
- Logic.js Zeile 205: `draggable="true"` ist gesetzt, aber keine Event-Handler
- **Gap-Level:** **KRITISCH**

**Erforderlich:**
```javascript
// dragstart, dragover, drop Events
item.addEventListener('dragstart', handleDragStart);
panel.addEventListener('dragover', handleDragOver);
panel.addEventListener('drop', handleDrop);
```

### 5.2 Wiederholungs-Funktion (HOCH)

**Access:**
- `btnRepeat` / `btnRepeatAus`
- Kopiert Zuordnungen auf andere Tage/Schichten

**HTML:**
- ❌ FEHLT: Keine Wiederholungs-Logik
- **Gap-Level:** **HOCH**

### 5.3 Bulk-Operationen (HOCH)

**Access:**
- `btnAddAll` - Alle verfügbaren MA zuordnen
- `btnDelAll` - Alle zugeordneten MA entfernen

**HTML:**
- ❌ FEHLT: Nur einzelne Zuordnungen möglich
- **Gap-Level:** **HOCH**

### 5.4 PDF-Export (MITTEL)

**Access:**
- `btnPosList_PDF` - Positionsliste als PDF

**HTML:**
- ❌ FEHLT: Kein Export
- **Gap-Level:** **MITTEL**

### 5.5 Position Löschen (HOCH)

**Access:**
- `mcobtnDelete` - Löscht ausgewählte Position

**HTML:**
- ❌ FEHLT: Kein Löschen-Button im Toolbar
- Logic.js hat `positionLoeschen()`, aber kein UI-Element
- **Gap-Level:** **HOCH**

### 5.6 MA-Typ Filter (MITTEL)

**Access:**
- OptionGroup `MA_Typ` mit 3 Optionen
- AfterUpdate Event filtert lstMA_Zusage

**HTML:**
- ❌ FEHLT: Keine Filter-OptionGroup
- **Gap-Level:** **MITTEL**

### 5.7 Anzahl-Anzeige (NIEDRIG)

**Access:**
- `AnzAusw` TextBox zeigt Anzahl ausgewählter Items

**HTML:**
- Teilweise vorhanden als Counter-Badges in Panel-Headers
- **Gap-Level:** **NIEDRIG**

---

## 6. LOGIC.JS ANALYSE

### 6.1 Vorhandene Funktionen

| Funktion | Implementiert | Status | Bemerkung |
|----------|---------------|--------|-----------|
| `loadInitialData()` | ✅ JA | FUNKTIONAL | Lädt Aufträge |
| `loadEinsatztage()` | ✅ JA | FUNKTIONAL | Lädt Datum-Dropdown |
| `loadSchichten()` | ✅ JA | FUNKTIONAL | Lädt Schichten |
| `loadPositionen()` | ✅ JA | FUNKTIONAL | Lädt Positionen |
| `loadVerfuegbareMitarbeiter()` | ✅ JA | FUNKTIONAL | Lädt verfügbare MA |
| `loadZugeordneteMitarbeiter()` | ✅ JA | FUNKTIONAL | Lädt zugeordnete MA |
| `mitarbeiterZuordnen()` | ✅ JA | FUNKTIONAL | Einzelne Zuordnung |
| `mitarbeiterEntfernen()` | ✅ JA | FUNKTIONAL | Einzelne Entfernung |
| `neuePosition()` | ⚠️ JA | UI FEHLT | Funktion da, aber kein UI |
| `positionLoeschen()` | ⚠️ JA | UI FEHLT | Funktion da, aber kein Button |

### 6.2 Fehlende Funktionen

| Funktion | Gap-Level | Bemerkung |
|----------|-----------|-----------|
| `alleHinzufuegen()` | **HOCH** | btnAddAll fehlt |
| `alleEntfernen()` | **HOCH** | btnDelAll fehlt |
| `zuordnungWiederholen()` | **HOCH** | btnRepeat fehlt |
| `positionslistePDF()` | **MITTEL** | btnPosList_PDF fehlt |
| `maTypFilterAnwenden()` | **MITTEL** | OptionGroup fehlt |
| `dragDropHandler()` | **KRITISCH** | Kein Drag&Drop |

### 6.3 Bridge-API Calls

**Verwendete Endpoints:**
- ✅ `getAuftragListe` (Zeile 49)
- ✅ `getEinsatztage` (Zeile 102)
- ✅ `getSchichten` (Zeile 123)
- ⚠️ `getPositionen` (Zeile 148) - Existiert dieser Endpoint?
- ⚠️ `getVerfuegbareMitarbeiterFuerPosition` (Zeile 175)
- ⚠️ `getZugeordneteMitarbeiterFuerPosition` (Zeile 191)
- ⚠️ `createPosition` (Zeile 340)
- ⚠️ `deletePosition` (Zeile 371)
- ⚠️ `zuordnenMitarbeiterZuPosition` (Zeile 391)
- ⚠️ `entfernenMitarbeiterVonPosition` (Zeile 414)

**Status:** Viele Endpoints sind custom und müssen im api_server.py implementiert werden!

---

## 7. DATENQUELLEN-MAPPING

### 7.1 Access Queries/Tables

**cbo_Akt_Objekt_Kopf:**
```sql
RowSource: qry_VA_Akt_Auftragskopf
```

**cboVADatum:**
```sql
RowSource: SELECT DISTINCT [VADatum] FROM [tbl_VA_AnzTage] WHERE [VA_ID]=[Forms]![frm_MA_VA_Positionszuordnung]![cbo_Akt_Objekt_Kopf] ORDER BY [VADatum];
```

**lstMA_Zusage:**
- Keine RowSource im Export sichtbar
- Vermutlich dynamisch geladen in OnLoad/OnCurrent

**List_Pos:**
- Keine RowSource im Export sichtbar
- Vermutlich dynamisch geladen nach Auftrag/Datum

**Lst_MA_Zugeordnet:**
- Keine RowSource im Export sichtbar
- Vermutlich dynamisch geladen nach Position

### 7.2 HTML API Calls

**cboAuftrag:**
```javascript
Bridge.execute('getAuftragListe', { limit: 100 })
```

**cboDatum:**
```javascript
Bridge.execute('getEinsatztage', { va_id: vaId })
```

**panelPositionen:**
```javascript
Bridge.execute('getPositionen', { va_id, datum, schicht_id })
```

**panelVerfügbar:**
```javascript
Bridge.execute('getVerfuegbareMitarbeiterFuerPosition', { position_id, va_id, datum })
```

**panelZugeordnet:**
```javascript
Bridge.execute('getZugeordneteMitarbeiterFuerPosition', { position_id })
```

---

## 8. EVENT-HANDLING VERGLEICH

### 8.1 Form-Events

| Access Event | Handler | HTML Equivalent | Status |
|--------------|---------|-----------------|--------|
| `OnLoad` | Procedure | `DOMContentLoaded` → `init()` | ✅ VORHANDEN |
| `OnCurrent` | Procedure | ❌ FEHLT | ⚠️ FEHLT |

**OnCurrent:** Wird in Access bei Navigation zwischen Records getriggert. In HTML ungebundenes Formular → nicht relevant.

### 8.2 Control-Events

| Access Control | Event | Handler | HTML Equivalent | Status |
|----------------|-------|---------|-----------------|--------|
| `cbo_Akt_Objekt_Kopf` | AfterUpdate | Procedure | `change` Event | ✅ VORHANDEN |
| `cboVADatum` | AfterUpdate | (keine) | `change` Event | ✅ VORHANDEN |
| `MA_Typ` | AfterUpdate | Procedure | ❌ FEHLT | ⚠️ FEHLT |
| `lstMA_Zusage` | AfterUpdate | Procedure | ❌ FEHLT | ⚠️ FEHLT |
| `List_Pos` | AfterUpdate | Procedure | `click` Event | ⚠️ TEILWEISE |
| `btnAddSelected` | OnClick | Procedure | `click` Event | ⚠️ INLINE |
| `btnAddAll` | OnClick | Procedure | ❌ FEHLT | ⚠️ FEHLT |
| `btnDelSelected` | OnClick | Procedure | `click` Event | ⚠️ INLINE |
| `btnDelAll` | OnClick | Procedure | ❌ FEHLT | ⚠️ FEHLT |
| `btnRepeat` | OnClick | Procedure | ❌ FEHLT | ⚠️ FEHLT |
| `btnPosList_PDF` | OnClick | Procedure | ❌ FEHLT | ⚠️ FEHLT |
| `mcobtnDelete` | OnClick | Macro | ❌ FEHLT | ⚠️ FEHLT |

---

## 9. STYLING & FARBEN

### 9.1 Access Farben (BackColor)

| Control | BackColor (Long) | HEX | Bemerkung |
|---------|------------------|-----|-----------|
| `body` (Formular) | (Default) | #8080c0 | Lila-Grau Hintergrund |
| `btnAuftrag` | 15918812 | #F2D8CC | Beige/Creme |
| `btnPosList_PDF` | 15918812 | #F2D8CC | Beige/Creme |
| `btnAddSelected` | 14136213 | #D7D7D7 | Hellgrau |
| `Befehl48..43` | 16777215 | #FFFFFF | Weiß (Icons) |

**Konvertierung:**
```
R = 15918812 & 255 = 204
G = (15918812 >> 8) & 255 = 216
B = (15918812 >> 16) & 255 = 242
→ #F2D8CC
```

### 9.2 HTML Farben

| Element | CSS | Bemerkung |
|---------|-----|-----------|
| `body` | `background-color: #8080c0` | ✅ KORREKT |
| `.app-header` | `background: #4316B2` | Lila Accent |
| `.btn-success` | (Bootstrap) | Grün |
| `.btn-danger` | (Bootstrap) | Rot |

**Gap:** Access-Button-Farben (#F2D8CC, #D7D7D7) werden nicht verwendet

---

## 10. ZUSAMMENFASSUNG DER GAPS

### 10.1 KRITISCHE GAPS (Prio 1)

| # | Gap | Impact | Aufwand |
|---|-----|--------|---------|
| 1 | **Drag & Drop** zwischen Listen fehlt | Hauptfunktionalität nicht nutzbar | **HOCH** |
| 2 | **btnAddAll / btnDelAll** fehlen | Bulk-Operationen unmöglich | **MITTEL** |
| 3 | **btnRepeat** fehlt | Wiederholung auf andere Tage nicht möglich | **HOCH** |
| 4 | **mcobtnDelete** fehlt | Positionen können nicht gelöscht werden | **MITTEL** |
| 5 | **Custom API-Endpoints** fehlen im Backend | Daten können nicht geladen werden | **HOCH** |

### 10.2 HOHE GAPS (Prio 2)

| # | Gap | Impact | Aufwand |
|---|-----|--------|---------|
| 6 | **MA-Typ OptionGroup** fehlt | Filter nach Fest/Frei nicht möglich | **MITTEL** |
| 7 | **btnPosList_PDF** fehlt | Export nicht möglich | **HOCH** |
| 8 | **Position erstellen UI** fehlt | Neue Positionen können nicht angelegt werden | **NIEDRIG** |
| 9 | **lstMA_Zusage AfterUpdate** fehlt | Keine Reaktion auf Auswahl | **NIEDRIG** |

### 10.3 MITTLERE GAPS (Prio 3)

| # | Gap | Impact | Aufwand |
|---|-----|--------|---------|
| 10 | **Toolbar-Buttons** (Befehl48..43) fehlen | Quick-Access Icons fehlen | **NIEDRIG** |
| 11 | **AnzAusw TextBox** fehlt | Anzahl-Anzeige weniger prominent | **NIEDRIG** |
| 12 | **Access-Button-Farben** nicht übernommen | Visuell inkonsistent | **NIEDRIG** |

### 10.4 NIEDRIGE GAPS (Prio 4)

| # | Gap | Impact | Aufwand |
|---|-----|--------|---------|
| 13 | **btnRibbonAus/Ein** fehlen | Ansichts-Toggle fehlt | **NIEDRIG** |
| 14 | **btnDaBaAus/Ein** fehlen | DB-Ansichts-Toggle fehlt | **NIEDRIG** |
| 15 | **OnCurrent Event** fehlt | In HTML nicht relevant (ungebunden) | **KEIN** |

---

## 11. EMPFOHLENE MASSNAHMEN

### Phase 1: Kritische Funktionalität (1-2 Tage)

1. **Drag & Drop implementieren:**
   - `dragstart` / `dragover` / `drop` Events
   - Visual Feedback (Drag-Over-Highlighting)
   - Multi-Select Support

2. **API-Endpoints erstellen:**
   - `GET /api/positionen?va_id=X&datum=Y&schicht_id=Z`
   - `GET /api/positionen/:id/verfuegbare-ma`
   - `GET /api/positionen/:id/zugeordnete-ma`
   - `POST /api/positionen/:id/zuordnen`
   - `DELETE /api/positionen/:id/zuordnen/:ma_id`
   - `POST /api/positionen`
   - `DELETE /api/positionen/:id`

3. **Bulk-Buttons hinzufügen:**
   - `btnAddAll` - Alle verfügbaren MA zuordnen
   - `btnDelAll` - Alle zugeordneten MA entfernen

4. **Delete-Button im Toolbar:**
   - `mcobtnDelete` für Positionen löschen

### Phase 2: Wichtige Features (1 Tag)

5. **MA-Typ OptionGroup:**
   - Radio Buttons für Alle/Fest/Frei
   - AfterUpdate filtert panelVerfügbar

6. **Wiederholungs-Funktion:**
   - `btnRepeat` Button
   - Modal/Dialog für Datum-Auswahl
   - Kopiert Zuordnungen auf andere Tage

7. **Position erstellen UI:**
   - Modal/Sidebar für neue Position
   - Felder: Name, Beschreibung, Anzahl, Qualifikation

### Phase 3: Nice-to-Have (0.5 Tage)

8. **PDF-Export:**
   - `btnPosList_PDF`
   - Generiert PDF der Positionsliste

9. **Toolbar-Icons:**
   - Befehl48..43 Buttons
   - Klären: Was machen diese Buttons?

10. **Styling-Anpassungen:**
    - Access-Button-Farben übernehmen
    - AnzAusw TextBox prominent platzieren

---

## 12. API-ENDPOINTS SPEZIFIKATION

### Erforderliche Endpoints:

```javascript
// 1. Positionen abrufen
GET /api/auftraege/:va_id/positionen?datum=YYYY-MM-DD&schicht_id=123
Response: [
  {
    Position_ID: 1,
    VA_ID: 123,
    VAStart_ID: 456,
    Name: "Einlass Tor 1",
    Beschreibung: "...",
    Anzahl: 3,
    Anzahl_Ist: 1,
    Qualifikation_ID: 5,
    Qualifikation: "34a"
  }
]

// 2. Verfügbare MA für Position
GET /api/positionen/:position_id/verfuegbare-ma?va_id=X&datum=Y
Response: [
  {
    MA_ID: 10,
    Nachname: "Mustermann",
    Vorname: "Max",
    IstFest: true,
    Qualifikationen: ["34a", "Ersthelfer"]
  }
]

// 3. Zugeordnete MA für Position
GET /api/positionen/:position_id/zugeordnete-ma
Response: [
  {
    MA_ID: 20,
    Nachname: "Meier",
    Vorname: "Hans",
    Rolle: "Teamleiter",
    ZugeordnetAm: "2026-01-12T10:30:00"
  }
]

// 4. MA zu Position zuordnen
POST /api/positionen/:position_id/zuordnen
Body: {
  ma_id: 10,
  rolle: "Mitarbeiter"
}

// 5. MA von Position entfernen
DELETE /api/positionen/:position_id/zuordnen/:ma_id

// 6. Position erstellen
POST /api/positionen
Body: {
  va_id: 123,
  vastart_id: 456,
  name: "Neue Position",
  beschreibung: "...",
  anzahl: 2,
  qualifikation_id: 5
}

// 7. Position löschen
DELETE /api/positionen/:position_id

// 8. Zuordnungen wiederholen (Kopieren)
POST /api/positionen/:position_id/wiederholen
Body: {
  ziel_datum: "2026-01-15",
  ziel_schicht_id: 789
}
```

---

## 13. DATENBANK-SCHEMA (Annahme)

### Vermutete Tabellen:

**tbl_VA_Positionen:**
```
Position_ID (PK)
VA_ID (FK → tbl_VA_Auftragstamm)
VAStart_ID (FK → tbl_VA_Start)
Name (Text)
Beschreibung (Text)
Anzahl (Integer)
Qualifikation_ID (FK → tbl_Qualifikationen)
```

**tbl_MA_Position_Zuordnung:**
```
Zuordnung_ID (PK)
Position_ID (FK → tbl_VA_Positionen)
MA_ID (FK → tbl_MA_Mitarbeiterstamm)
Rolle (Text)
ZugeordnetAm (DateTime)
```

**tbl_Qualifikationen:**
```
Qualifikation_ID (PK)
Name (Text)
Beschreibung (Text)
```

---

## 14. GETESTETE SZENARIEN

### Was funktioniert:

✅ Formular öffnet in Browser
✅ Sidebar wird geladen
✅ Header mit Datum wird angezeigt
✅ Statische Panel-Struktur ist sichtbar

### Was noch nicht funktioniert:

❌ Auftrag-Dropdown bleibt leer (kein API-Call)
❌ Listen bleiben mit Dummy-Daten gefüllt
❌ Keine Drag & Drop Funktionalität
❌ Keine Bulk-Operationen
❌ Keine Wiederholungs-Funktion
❌ Keine Position-Erstellung/Löschung UI

---

## 15. PRIORITÄTEN-MATRIX

| Feature | Business Value | Technischer Aufwand | Priorität |
|---------|----------------|---------------------|-----------|
| Drag & Drop | **HOCH** | **HOCH** | **P1 - KRITISCH** |
| API-Endpoints | **HOCH** | **HOCH** | **P1 - KRITISCH** |
| Bulk-Buttons | **MITTEL** | **NIEDRIG** | **P1 - KRITISCH** |
| Delete-Button | **MITTEL** | **NIEDRIG** | **P1 - KRITISCH** |
| MA-Typ Filter | **MITTEL** | **MITTEL** | **P2 - HOCH** |
| Wiederholung | **HOCH** | **MITTEL** | **P2 - HOCH** |
| Position erstellen | **MITTEL** | **NIEDRIG** | **P2 - HOCH** |
| PDF-Export | **NIEDRIG** | **HOCH** | **P3 - MITTEL** |
| Toolbar-Icons | **NIEDRIG** | **NIEDRIG** | **P4 - NIEDRIG** |
| Styling | **NIEDRIG** | **NIEDRIG** | **P4 - NIEDRIG** |

---

## 16. GESCHÄTZTER AUFWAND

### Gesamtaufwand: **4-6 Arbeitstage**

**Phase 1 (Kritisch):** 2-3 Tage
- Drag & Drop: 1 Tag
- API-Endpoints: 1 Tag
- Bulk/Delete Buttons: 0.5 Tage
- Testing: 0.5 Tage

**Phase 2 (Hoch):** 1-2 Tage
- MA-Typ Filter: 0.5 Tage
- Wiederholung: 1 Tag
- Position erstellen: 0.5 Tage

**Phase 3 (Mittel/Niedrig):** 1 Tag
- PDF-Export: 0.5 Tage
- Toolbar-Icons: 0.25 Tage
- Styling: 0.25 Tage

---

## 17. RISIKEN & ABHÄNGIGKEITEN

### Risiken:

⚠️ **Datenbank-Schema unbekannt:**
Tabelle `tbl_VA_Positionen` existiert möglicherweise nicht → Muss erstellt werden

⚠️ **Drag & Drop Komplexität:**
Multi-Select Drag & Drop zwischen Listen ist technisch anspruchsvoll

⚠️ **Performance:**
Viele MA/Positionen können Liste verlangsamen → Virtual Scrolling nötig

### Abhängigkeiten:

🔗 **api_server.py:**
Alle neuen Endpoints müssen in Python implementiert werden

🔗 **Access Backend:**
Tabellen `tbl_VA_Positionen` und `tbl_MA_Position_Zuordnung` müssen existieren

🔗 **qry_VA_Akt_Auftragskopf:**
Query muss im Backend vorhanden sein

---

## 18. NÄCHSTE SCHRITTE

### Sofort:

1. **Datenbank-Schema prüfen:**
   Existieren `tbl_VA_Positionen` und `tbl_MA_Position_Zuordnung`?

2. **API-Endpoint Prototyp:**
   Einen Endpoint implementieren und testen

3. **Drag & Drop POC:**
   Einfacher Proof-of-Concept für Drag & Drop

### Kurzfristig (diese Woche):

4. **Alle API-Endpoints:**
   Komplett implementieren und testen

5. **Bulk-Buttons:**
   Hinzufügen und mit API verbinden

6. **Delete-Button:**
   UI hinzufügen und mit `positionLoeschen()` verbinden

### Mittelfristig (nächste Woche):

7. **MA-Typ Filter:**
   OptionGroup implementieren

8. **Wiederholungs-Funktion:**
   Modal + Logic implementieren

9. **End-to-End Testing:**
   Vollständiger Workflow testen

---

**Ende der Gap-Analyse**
