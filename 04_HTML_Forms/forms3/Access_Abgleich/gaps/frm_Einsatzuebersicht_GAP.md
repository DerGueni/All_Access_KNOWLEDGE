# Gap-Analyse: frm_Einsatzuebersicht

**Datum:** 2026-01-12
**Erstellt von:** Claude Code
**Status:** Detaillierte Analyse

---

## Executive Summary

Die HTML-Implementierung von **frm_Einsatzuebersicht** ist eine **massive Erweiterung** des ursprünglichen Access-Formulars. Während das Access-Formular nur eine einfache, nicht-interaktive Liste von 11 Feldern darstellt, bietet die HTML-Version ein vollständig funktionales **Dashboard mit Filtern, Gruppierung, Export und Navigation**.

**Zusammenfassung:**
- ✅ **Funktional überlegen** - HTML bietet deutlich mehr Features
- ⚠️ **Abweichende Datenquelle** - Access nutzt `qry_Einsatzuebersicht_kpl`, HTML lädt über API
- ✅ **Bessere UX** - Filter, Sortierung, Gruppierung, Schnellfilter
- ⚠️ **Fehlende Access-Felder** - 11 Access-Felder nicht vollständig in HTML-Spalten abgebildet

---

## 1. STRUKTURELLE UNTERSCHIEDE

### 1.1 Datenquelle

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **RecordSource** | `qry_Einsatzuebersicht_kpl` | API-Endpoint (nicht spezifiziert) | ⚠️ GAP |
| **Felder-Count** | 11 Felder | 6 Spalten (vereinfacht) | ⚠️ GAP |
| **Bearbeitbar** | Ja (AllowEdits=Wahr) | Nein (nur Anzeige) | ⚠️ GAP |
| **Hinzufügen** | Ja (AllowAdditions=Wahr) | Nein | ⚠️ GAP |
| **Löschen** | Ja (AllowDeletions=Wahr) | Nein | ⚠️ GAP |

**Kritische Abweichung:**
Access erlaubt **Inline-Bearbeitung** aller Felder, HTML ist **Read-Only** mit Doppelklick-Navigation zum Auftragstamm.

### 1.2 View-Typ

| Eigenschaft | Access | HTML | Status |
|-------------|--------|------|--------|
| **DefaultView** | ContinuousForms | HTML-Tabelle mit Scrolling | ✅ OK |
| **NavigationButtons** | Wahr | Eigene Filterbar | ✅ BESSER |
| **DividingLines** | Falsch | Border zwischen Zeilen | ✅ OK |

---

## 2. FELDER / SPALTEN MAPPING

### 2.1 Access-Felder vs. HTML-Spalten

| Access-Feld | In HTML | HTML-Spalte | Bemerkung |
|-------------|---------|-------------|-----------|
| **Auftrag** | ✅ Ja | "Auftrag / Veranstaltung" | Vorhanden |
| **Objekt** | ✅ Ja | "Objekt" | Vorhanden |
| **Ort** | ❌ Nein | - | **FEHLT in HTML** |
| **VADatum** | ✅ Ja | "Datum" | Vorhanden |
| **MA_Start** | ✅ Ja | "Schicht" (kombiniert) | Mit MA_Ende kombiniert |
| **MA_Ende** | ✅ Ja | "Schicht" (kombiniert) | Mit MA_Start kombiniert |
| **MA_Brutto_Std2** | ❌ Nein | - | **FEHLT in HTML** |
| **MA_Netto_Std2** | ❌ Nein | - | **FEHLT in HTML** |
| **Nachname** | ❌ Nein | - | **FEHLT in HTML** |
| **Vorname** | ❌ Nein | - | **FEHLT in HTML** |
| **PosNr** | ❌ Nein | - | **FEHLT in HTML** |

**Zusätzliche HTML-Spalten (nicht in Access):**
| HTML-Spalte | Quelle | Bemerkung |
|-------------|--------|-----------|
| **MA Soll/Ist** | `MA_Anzahl`, `MA_Anzahl_Ist` | Aus Schicht-Daten |
| **Status** | Berechnet | "Offen", "Teilbesetzt", "Besetzt", etc. |

### 2.2 Fehlende Felder (Gap)

Die folgenden Access-Felder sind **in HTML nicht sichtbar**:

1. **Ort** - Stadt/Adresse des Einsatzes
2. **MA_Brutto_Std2** - Brutto-Stunden
3. **MA_Netto_Std2** - Netto-Stunden
4. **Nachname** - MA Nachname
5. **Vorname** - MA Vorname
6. **PosNr** - Positionsnummer

**Auswirkung:**
- Keine Stundeninformation sichtbar
- Keine Zuordnung zu spezifischen Mitarbeitern sichtbar (nur Anzahl)
- Keine Positionsnummer ersichtlich

---

## 3. FUNKTIONALITÄT

### 3.1 Access-Funktionen

| Funktion | Vorhanden | Bemerkung |
|----------|-----------|-----------|
| **Inline-Bearbeitung** | ✅ | Alle Felder editierbar |
| **Datensatz hinzufügen** | ✅ | AllowAdditions=Wahr |
| **Datensatz löschen** | ✅ | AllowDeletions=Wahr |
| **Sortierung** | ✅ | OrderBy nach VADatum, Auftrag, PosNr |
| **Navigation** | ✅ | Standard-Navigationsbuttons |
| **Events** | ❌ | Keine VBA-Events |

**Access-Formular ist ein reines Datenerfassungs-/Bearbeitungsformular.**

### 3.2 HTML-Funktionen

| Funktion | Vorhanden | Bemerkung |
|----------|-----------|-----------|
| **Inline-Bearbeitung** | ❌ | Read-Only |
| **Datensatz hinzufügen** | ❌ | - |
| **Datensatz löschen** | ❌ | - |
| **Sortierung** | ✅ BESSER | Alle Spalten sortierbar per Klick |
| **Filter (Datum)** | ✅ NEU | Von/Bis-Datum mit Schnellfiltern |
| **Filter (Aktiv)** | ✅ NEU | "Nur aktive Aufträge" Checkbox |
| **Gruppierung** | ✅ NEU | Nach Objekt/MA/Datum |
| **Schnellfilter** | ✅ NEU | Heute/Woche/Monat |
| **Export Excel** | ✅ NEU | Mit Bridge oder CSV-Fallback |
| **Drucken** | ✅ NEU | Mit Bridge oder Browser-Print |
| **Navigation** | ✅ NEU | Doppelklick öffnet Auftragstamm |
| **Tastatur-Shortcuts** | ✅ NEU | F5, Ctrl+E, Ctrl+P, ESC, Enter |
| **Status-Badges** | ✅ NEU | Farbcodierte Status-Anzeige |
| **MA Soll/Ist** | ✅ NEU | Farbcodierter Besetzungsgrad |
| **Loading-Overlay** | ✅ NEU | Spinner bei Datenladung |
| **Toast-Notifications** | ✅ NEU | Feedback für Benutzer |

**HTML-Formular ist ein Analyse-/Reporting-Dashboard mit Navigation.**

### 3.3 Funktionale Gaps

| Gap | Beschreibung | Priorität |
|-----|--------------|-----------|
| **Keine Bearbeitung** | HTML ist Read-Only, Access erlaubt Bearbeitung | 🔴 HOCH |
| **Keine Stundenanzeige** | MA_Brutto_Std2 / MA_Netto_Std2 fehlen | 🟡 MITTEL |
| **Keine MA-Details** | Nachname/Vorname nicht sichtbar | 🟡 MITTEL |
| **Kein Ort-Feld** | Ort-Information fehlt | 🟢 NIEDRIG |
| **Keine PosNr** | Positionsnummer nicht angezeigt | 🟢 NIEDRIG |

---

## 4. LAYOUT & DESIGN

### 4.1 Access-Layout

| Element | Position (twips) | Größe |
|---------|------------------|-------|
| **Auto_Logo0** | 300, 60 | 690 x 460 |
| **Auto_Kopfzeile0** | 1050, 60 | 10755 x 460 |
| **TextBoxen** | Left: 2190, Width: 11325 | Alle gleich breit |
| **Labels** | Width: 1783 | Standard-Label-Breite |

**Charakteristik:** Vertical-Stack Layout, alle Felder untereinander.

### 4.2 HTML-Layout

| Element | Typ | Breite |
|---------|-----|--------|
| **Left Sidebar** | Menu | 185px fix |
| **Header-Bar** | Titel + Version | Flex |
| **Filter-Bar** | Horizontal | Wrap bei wenig Platz |
| **Tabelle** | Grid | 100% mit Min-Width 900px |
| **Footer-Bar** | Status + Record-Count | Flex |

**Charakteristik:** Dashboard-Layout mit Sidebar, horizontaler Filterbar, Tabelle.

### 4.3 Layout-Unterschiede

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Struktur** | Vertical-Stack (Felder untereinander) | Tabellarisch (Spalten) | ✅ BESSER |
| **Sidebar** | Keine | Ja (185px) | ✅ NEU |
| **Filter** | Keine | Ja (Filter-Bar) | ✅ NEU |
| **Responsive** | Nein | Ja (Flex, Wrap) | ✅ NEU |
| **Logo** | Ja | Nein | ⚠️ GAP |

---

## 5. SORTIERUNG

### 5.1 Access-Sortierung

**OrderBy:** `[qry_Einsatzuebersicht_kpl].[VADatum], [qry_Einsatzuebersicht_kpl].[Auftrag], [qry_Einsatzuebersicht_kpl].[PosNr]`

**OrderByOn:** Wahr

**Fixe Sortierung** nach:
1. VADatum (Datum)
2. Auftrag
3. PosNr

### 5.2 HTML-Sortierung

**Dynamisch sortierbar** durch Spalten-Klick:
- Datum
- Auftrag
- Objekt
- Schicht
- MA Soll/Ist
- Status

**Default:** Datum aufsteigend (wie Access)

**Status:** ✅ **HTML BESSER** - Flexibler, alle Spalten sortierbar.

---

## 6. FILTER

### 6.1 Access-Filter

| Eigenschaft | Wert |
|-------------|------|
| **FilterOn** | Falsch |
| **Filter** | (leer) |

**Keine Filter-Funktionalität in Access.**

### 6.2 HTML-Filter

| Filter-Typ | Beschreibung | UI-Element |
|------------|--------------|------------|
| **Datumsbereich** | Von/Bis-Datum | Date-Inputs + Buttons |
| **Schnellfilter** | Heute, Woche, Monat | Quick-Filter-Buttons |
| **Nur Aktive** | Checkbox | Checkbox + Label |
| **Gruppierung** | Nach Objekt/MA/Datum | Dropdown |

**Zusätzliche Features:**
- Zeitraum vor/zurück Navigation
- "Heute" Quick-Button
- Gruppierung mit Collapse/Expand

**Status:** ✅ **HTML DEUTLICH BESSER**

---

## 7. EXPORT & PRINT

### 7.1 Access

**Keine Export-/Druckfunktionen** direkt im Formular.

### 7.2 HTML

| Funktion | Implementierung | Fallback |
|----------|-----------------|----------|
| **Excel-Export** | WebView2 Bridge Event | CSV-Download |
| **Drucken** | WebView2 Bridge Event | window.print() |

**Status:** ✅ **HTML BESSER**

---

## 8. DATENQUELLE & API

### 8.1 Access

**RecordSource:** `qry_Einsatzuebersicht_kpl`

**Felder aus Query:**
- Auftrag, Objekt, Ort, VADatum
- MA_Start, MA_Ende
- MA_Brutto_Std2, MA_Netto_Std2
- Nachname, Vorname, PosNr

### 8.2 HTML

**Datenquelle:** Nicht explizit genannt, aber wahrscheinlich:
- WebView2 Bridge Event: `loadEinsatzuebersicht`
- API-Endpoint: `Bridge.loadData('einsatztage', ...)`
- Demo-Daten als Fallback

**Erwartete API-Felder:**
```javascript
{
    VAS_ID, VA_ID, VADatum,
    VA_Start, VA_Ende,
    Objekt, Auftrag,
    MA_Anzahl, MA_Anzahl_Ist,
    Status, VA_IstAktiv
}
```

### 8.3 Mapping-Probleme

| Problem | Beschreibung | Lösung |
|---------|--------------|--------|
| **Fehlende Felder** | Ort, Brutto/Netto-Std, MA-Namen, PosNr | API erweitern ODER in HTML ergänzen |
| **Abweichende Struktur** | Access: MA-bezogen, HTML: Schicht-bezogen | Datenmodell-Transformation nötig |
| **Aggregation** | HTML zeigt Soll/Ist pro Schicht, nicht pro MA | Ggf. Subform/Detail-Ansicht nötig |

---

## 9. BEDINGTE FORMATIERUNG

### 9.1 Access

**Keine bedingte Formatierung** im Formular definiert.

### 9.2 HTML

**Umfangreiche bedingte Formatierung:**

#### Status-Badges
```css
.status-offen       → #ffcccc (Rot)
.status-teilbesetzt → #fff3cd (Gelb)
.status-besetzt     → #d4edda (Grün)
.status-abgesagt    → #e2e3e5 (Grau, durchgestrichen)
.status-inplanung   → #cce5ff (Blau)
```

#### MA-Count (Soll/Ist)
```javascript
ist >= soll → .ma-count.ok   (Grün #155724)
ist > 0     → .ma-count.warn (Gelb #856404)
ist === 0   → .ma-count.err  (Rot #c00000)
```

**Status:** ✅ **HTML DEUTLICH BESSER**

---

## 10. NAVIGATION & INTEGRATION

### 10.1 Access

**Keine Navigation** zu anderen Formularen aus diesem Formular heraus.

### 10.2 HTML

**Umfangreiche Navigation:**

#### Sidebar-Menu
- Dienstplanübersicht
- Planungsübersicht
- Auftragsverwaltung
- Mitarbeiterverwaltung
- Offene Anfragen
- Einsatzübersicht (aktiv)

#### Zeilen-Klick
- **Einfach-Klick:** Zeile markieren
- **Doppel-Klick:** Auftragstamm öffnen (`openAuftragstamm(va_id)`)

#### Tastatur-Navigation
- **Enter:** Ausgewählten Auftrag öffnen
- **Pfeiltasten:** Zeilen-Navigation
- **ESC:** Formular schließen
- **F5:** Aktualisieren
- **Ctrl+E:** Excel-Export
- **Ctrl+P:** Drucken

**Status:** ✅ **HTML DEUTLICH BESSER**

---

## 11. WEBVIEW2 BRIDGE INTEGRATION

### 11.1 Events an Access

| Event | Zweck | Payload |
|-------|-------|---------|
| **loadEinsatzuebersicht** | Daten laden | `{ von, bis, nurAktive }` |
| **exportExcel** | Excel-Export | `{ type, von, bis, data }` |
| **print** | Drucken | `{ type, von, bis }` |

### 11.2 Events von Access

| Event | Handler | Daten |
|-------|---------|-------|
| **onDataReceived** | `handleBridgeData` | `{ einsatzuebersicht/einsatztage/schichten, error }` |

### 11.3 Navigation

| Methode | Beschreibung |
|---------|--------------|
| **Bridge.navigate** | Form öffnen mit ID |
| **Bridge.close** | Formular schließen |
| **PostMessage** | Shell-Modus Fallback |

---

## 12. GAP PRIORISIERUNG

### 🔴 KRITISCHE GAPS (Must-Have)

| # | Gap | Impact | Lösung |
|---|-----|--------|--------|
| 1 | **Keine Bearbeitung** | Dateneingabe/-korrektur nicht möglich | Bearbeiten-Modus implementieren ODER Access-Form für Bearbeitung nutzen |
| 2 | **Fehlende API-Definition** | Unklar welcher Endpoint/Query | `qry_Einsatzuebersicht_kpl` als API-Endpoint anlegen |
| 3 | **Fehlende MA-Details** | Nachname/Vorname nicht sichtbar | Spalten ergänzen ODER Tooltip/Detail-View |

### 🟡 WICHTIGE GAPS (Should-Have)

| # | Gap | Impact | Lösung |
|---|-----|--------|--------|
| 4 | **Keine Stundenanzeige** | Brutto/Netto-Stunden fehlen | Spalten ergänzen ODER in Detail-View |
| 5 | **Kein Ort-Feld** | Einsatzort-Info fehlt | Spalte "Ort" hinzufügen |
| 6 | **Keine PosNr** | Positionsnummer nicht sichtbar | Spalte "Pos" hinzufügen |

### 🟢 OPTIONALE GAPS (Nice-to-Have)

| # | Gap | Impact | Lösung |
|---|-----|--------|--------|
| 7 | **Kein Logo** | Corporate Identity | Logo in Header-Bar einfügen |
| 8 | **Keine Inline-Validierung** | - | Nicht nötig da Read-Only |

---

## 13. EMPFEHLUNGEN

### 13.1 Sofort-Maßnahmen (P0)

1. **API-Endpoint definieren:**
   ```
   GET /api/einsatzuebersicht?von=YYYY-MM-DD&bis=YYYY-MM-DD&nurAktive=true
   ```
   Basierend auf `qry_Einsatzuebersicht_kpl` mit allen 11 Feldern.

2. **Fehlende Spalten ergänzen:**
   - Ort
   - MA Name (Nachname, Vorname kombiniert)
   - Brutto-Std
   - Netto-Std
   - Pos

3. **Bearbeiten-Modus entscheiden:**
   - **Option A:** HTML Read-Only lassen, Doppelklick öffnet Auftragstamm für Bearbeitung
   - **Option B:** Inline-Bearbeitung implementieren (sehr aufwendig)

   **Empfehlung:** Option A - HTML als Dashboard, Bearbeitung im Auftragstamm.

### 13.2 Kurzfristig (P1)

4. **Demo-Daten entfernen:**
   Sobald API steht, `loadDemoData()` durch echte API-Aufrufe ersetzen.

5. **Logo ergänzen:**
   Header-Bar um Logo erweitern (wie in anderen Formularen).

6. **Testing mit echten Daten:**
   Mit 100+ Einsätzen testen, Performance prüfen.

### 13.3 Mittelfristig (P2)

7. **Detail-View/Drill-Down:**
   Bei Klick auf Zeile: Sliding-Panel mit allen Details (inkl. MA-Namen, Stunden, etc.)

8. **Filter-Persistenz:**
   Letzte Filter-Einstellungen im LocalStorage speichern.

9. **Virtualisierung:**
   Bei 1000+ Zeilen: Virtual Scrolling implementieren (`performance.js`).

---

## 14. TESTFÄLLE

### 14.1 Datenladung

| Test | Erwartung | Status |
|------|-----------|--------|
| **Laden bei Init** | Daten für "Heute" werden geladen | ✅ |
| **Filter ändern** | Tabelle wird neu geladen | ✅ |
| **Keine Daten** | "Keine Einsätze gefunden" Meldung | ✅ |
| **API-Fehler** | Toast + Demo-Daten Fallback | ✅ |

### 14.2 Filter

| Test | Erwartung | Status |
|------|-----------|--------|
| **Schnellfilter "Heute"** | Von=Bis=Heute | ✅ |
| **Schnellfilter "Woche"** | Mo-So dieser Woche | ✅ |
| **Nur Aktive** | Inaktive Aufträge werden ausgeblendet | ✅ |
| **Datum vor/zurück** | Zeitraum verschiebt sich korrekt | ✅ |

### 14.3 Sortierung

| Test | Erwartung | Status |
|------|-----------|--------|
| **Klick auf Spalte** | Sortierung wechselt | ✅ |
| **Wiederholter Klick** | ASC ↔ DESC Toggle | ✅ |
| **Sort-Icon** | Pfeil zeigt Richtung | ✅ |

### 14.4 Gruppierung

| Test | Erwartung | Status |
|------|-----------|--------|
| **Nach Objekt** | Zeilen nach Objekt gruppiert | ✅ |
| **Collapse/Expand** | Klick auf Gruppe klappt ein/aus | ✅ |
| **Gesamt-Summen** | Soll/Ist pro Gruppe korrekt | ✅ |

### 14.5 Navigation

| Test | Erwartung | Status |
|------|-----------|--------|
| **Doppelklick auf Zeile** | Auftragstamm mit VA_ID öffnet | ⚠️ UNGETESTET |
| **Sidebar-Buttons** | Navigation zu anderen Forms | ⚠️ UNGETESTET |
| **Pfeiltasten** | Zeilen-Navigation funktioniert | ✅ |
| **Enter** | Auftrag öffnen | ⚠️ UNGETESTET |

### 14.6 Export

| Test | Erwartung | Status |
|------|-----------|--------|
| **Excel-Export (Bridge)** | VBA wird aufgerufen | ⚠️ UNGETESTET |
| **CSV-Export (Fallback)** | Download mit korrekten Daten | ✅ |
| **Drucken (Bridge)** | VBA wird aufgerufen | ⚠️ UNGETESTET |
| **Drucken (Browser)** | window.print() öffnet | ✅ |

---

## 15. TECHNISCHE SCHULDEN

| Schuld | Beschreibung | Risiko |
|--------|--------------|--------|
| **Demo-Daten im Produktivcode** | `loadDemoData()` sollte entfernt werden | 🟡 MITTEL |
| **Keine Error-Boundary** | Bei JS-Fehler keine Fallback-UI | 🟢 NIEDRIG |
| **Kein Loading-State bei Sort** | Bei großen Datenmengen könnte Sortierung blocken | 🟢 NIEDRIG |
| **Keine Unit-Tests** | Logik nicht getestet | 🟡 MITTEL |

---

## 16. ZUSAMMENFASSUNG

### Stärken der HTML-Implementierung ✅

1. **Moderne UX:** Filter, Sortierung, Gruppierung
2. **Interaktivität:** Klick-Navigation, Tastatur-Shortcuts
3. **Visuelle Feedback:** Status-Badges, MA-Count-Farben, Loading, Toast
4. **Export-Funktionen:** Excel, CSV, Drucken
5. **Responsive Design:** Flex-Layout, Sidebar
6. **Bessere Performance:** Nur sichtbare Daten, keine Access-Overhead

### Schwächen/Gaps ⚠️

1. **Keine Bearbeitung:** Read-Only (Access erlaubt Bearbeitung)
2. **Fehlende Felder:** Ort, Stunden, MA-Namen, PosNr
3. **Abweichende Datenstruktur:** Schicht- statt MA-bezogen
4. **API nicht definiert:** Unklar welcher Endpoint
5. **Ungetestete Navigation:** WebView2 Bridge-Integration

### Fazit 🎯

Die HTML-Implementierung ist ein **modernisiertes Dashboard** für die Einsatzübersicht, das die Access-Grundfunktion **erweitert** aber **nicht 1:1 nachbildet**.

**Wenn Ziel ist:**
- **Dashboard/Reporting:** HTML ist deutlich besser
- **Datenerfassung/-korrektur:** Access ist besser (oder HTML erweitern)

**Empfehlung:** HTML als Read-Only-Dashboard nutzen, für Bearbeitung Auftragstamm öffnen.

---

## 17. NÄCHSTE SCHRITTE

1. ✅ **Gap-Analyse abgeschlossen**
2. ⏳ **API-Endpoint definieren** (`qry_Einsatzuebersicht_kpl` → REST-API)
3. ⏳ **Fehlende Spalten ergänzen** (Ort, Stunden, MA-Namen, Pos)
4. ⏳ **Testing mit echten Daten** (WebView2 Bridge)
5. ⏳ **Entscheidung Bearbeiten-Modus** (Read-Only oder Inline-Edit)

---

**Bericht erstellt:** 2026-01-12
**Datei:** `frm_Einsatzuebersicht_GAP.md`
**Autor:** Claude Code (Automated Analysis)
