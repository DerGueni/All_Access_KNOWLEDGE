# GAP-ANALYSE: frm_MA_Offene_Anfragen

**Datum:** 2026-01-12
**Formular:** frm_MA_Offene_Anfragen
**Typ:** Container-Formular mit Subformular

---

## 1. ÜBERSICHT

### Access-Formular
- **Name:** frm_MA_Offene_Anfragen
- **Record Source:** (keine - Container-Formular)
- **Default View:** Other
- **Zweck:** Anzeige und Verwaltung offener Mitarbeiter-Anfragen

### HTML-Umsetzung
- **Datei:** `04_HTML_Forms\forms3\frm_MA_Offene_Anfragen.html`
- **Logic:** `04_HTML_Forms\forms3\logic\frm_MA_Offene_Anfragen.logic.js`
- **API-Endpoints:** `/api/anfragen`, `/api/vba/anfragen` (VBA Bridge)

---

## 2. STRUKTUR-VERGLEICH

### 2.1 Layout

| Element | Access | HTML | Status |
|---------|--------|------|--------|
| **Container** | Formular mit Subform | App-Layout mit Tabelle | ✅ UMGESETZT |
| **Subformular** | sub_MA_Offene_Anfragen | Inline-Tabelle | ✅ UMGESETZT |
| **Button "Anfragen"** | btnAnfragen (TopLeft) | btnAnfragen (Toolbar) | ✅ UMGESETZT |
| **Textbox Height** | txSelHeightSub | - | ⚠️ FEHLT (nur technisch) |
| **Labels** | 3 Labels | Header-Titel + Toolbar-Label | ✅ UMGESETZT |

**Bewertung:** ✅ Layout gut umgesetzt, HTML-Version nutzt moderne Toolbar statt Access-Button-Leiste

### 2.2 Controls

| Access Control | HTML Control | Position | Funktion | Status |
|----------------|--------------|----------|----------|--------|
| btnAnfragen | #btnAnfragen | Toolbar | E-Mail-Erinnerungen senden | ✅ VORHANDEN |
| txSelHeightSub | - | - | Höhe für Selektion | ⚠️ FEHLT |
| Bezeichnungsfeld3 | .app-title | Header | Formulartitel | ✅ VORHANDEN |
| Bezeichnungsfeld7 | .toolbar-label | Toolbar | "Anzeigen:" | ✅ VORHANDEN |
| sub_MA_Offene_Anfragen | .anfragen-table | Content | Anfragen-Liste | ✅ VORHANDEN |

---

## 3. DATENQUELLE UND FELDER

### 3.1 Access-Datenquelle (Subformular)

**Query:** `qry_MA_Offene_Anfragen`

**Filter-Logik (Access):**
- `Dat_VA_Von > Date()` - Nur zukünftige Einsätze
- `Anfragezeitpunkt > #1/1/2022#` - Nur aktuelle Anfragen
- `Rueckmeldezeitpunkt IS NULL` - Nur ohne Rückmeldung

**Sortierung:**
- Auftrag → Name → Dat_VA_Von

### 3.2 HTML-Datenquelle

**API-Endpoint:** `/api/anfragen?status=offen`

**Filter-Logik (JavaScript):**
```javascript
// Zeile 87-108 in frm_MA_Offene_Anfragen.logic.js
filter(item => {
    const datVon = parseDate(item.Dat_VA_Von);
    if (!datVon || datVon <= today) return false;

    const anfrageDat = parseDate(item.Anfragezeitpunkt);
    if (!anfrageDat || anfrageDat <= cutoffDate) return false;

    if (item.Rueckmeldezeitpunkt) return false;

    return true;
})
```

**Sortierung:**
```javascript
// Zeile 124-130
sort((a, b) => {
    if (a.datum.getTime() !== b.datum.getTime()) {
        return a.datum - b.datum;
    }
    return b.anfragezeitpunkt - a.anfragezeitpunkt;
})
```

**Status:** ✅ Filter-Logik korrekt implementiert, Sortierung leicht abweichend (Anfragezeitpunkt DESC statt Name)

### 3.3 Felder-Mapping

| Access-Feld | Access-Quelle | HTML-Feld | HTML-Spalte | Status |
|-------------|---------------|-----------|-------------|--------|
| Name | qry...Name | name | Mitarbeiter | ✅ OK |
| Dat_VA_Von | qry...Dat_VA_Von | datum | Datum | ✅ OK |
| Auftrag | qry...Auftrag | auftrag | Auftrag | ✅ OK |
| Ort | qry...Ort | ort | Ort | ✅ OK |
| von | qry...von | von | Von | ✅ OK |
| bis | qry...bis | bis | Bis | ✅ OK |
| Anfragezeitpunkt | qry...Anfragezeitpunkt | anfragezeitpunkt | Angefragt am | ✅ OK |

**Bewertung:** ✅ Alle Felder korrekt gemappt

---

## 4. FUNKTIONALITÄT

### 4.1 Button: "Erneut anfragen" (btnAnfragen)

#### Access-VBA (Original)

**Event:** btnAnfragen_Click()

**Funktion:**
- Ausgewählte Zeilen im Subformular identifizieren
- E-Mail-Erinnerungen an Mitarbeiter senden
- Status-Update in tbl_MA_VA_Planung

**VBA-Code-Logik (typisch):**
```vba
Private Sub btnAnfragen_Click()
    ' Sende Anfragen für ausgewählte Datensätze
    ' Loop über Recordset
    ' Call VBA_MailSenden(MA_ID, VA_ID, ...)
End Sub
```

#### HTML-JavaScript (Umsetzung)

**Event:** `#btnAnfragen.click` (Zeile 44)

**Funktion (Zeile 288-356):**
```javascript
async function erneutAnfragen() {
    // Multi-Selektion oder aktuelle Zeile
    if (selectedRows.size === 0 && selectedRow !== null) {
        selectedRows.add(parseInt(selectedRow.dataset.index));
    }

    // Loop über ausgewählte Anfragen
    for (const idx of selectedRows) {
        const anfrage = filteredAnfragen[idx];

        // Bridge-Event für VBA-Funktion "Anfragen"
        await Bridge.sendEvent('anfragen', {
            ma_id: anfrage.ma_id,
            va_id: anfrage.va_id,
            vadatum_id: anfrage.vadatum_id,
            vastart_id: anfrage.vastart_id
        });

        // Fallback: REST API
        await fetch('/api/anfragen/senden', {
            method: 'POST',
            body: JSON.stringify({ ... })
        });
    }

    // Daten neu laden
    loadAnfragen();
}
```

**VBA-Bridge-Endpoint:** `POST /api/vba/anfragen` (vba_bridge_server.py)

**Request Body:**
```json
{
    "VA_ID": 12345,
    "VADatum_ID": 67890,
    "VAStart_ID": 111,
    "MA_IDs": [1, 2, 3],
    "selectedOnly": true
}
```

**Status:** ✅ Funktionalität implementiert mit Bridge + Fallback

**GAP:** ⚠️ **VBA-Bridge muss laufen** - Kein reines REST-API-Fallback vorhanden

---

### 4.2 Filter-Funktionen

#### Access

**Filter:** Fest in Query `qry_MA_Offene_Anfragen`
- Nur zukünftige Einsätze
- Nur ohne Rückmeldung

#### HTML

**Filter-Dropdown:** (Zeile 340-346)
- Alle Anfragen
- Nur zukünftige
- Nächste 7 Tage
- Nächste 30 Tage

**Funktion:** `applyFilter()` (Zeile 136-167)

**Status:** ✅ Erweiterte Filter-Funktionen gegenüber Access

---

### 4.3 Export-Funktionen

#### Access
- Keine explizite Export-Funktion im Formular
- Manuell über Access-UI möglich

#### HTML
- **Button:** `#btnExport` (Zeile 333-335)
- **Funktion:** `exportToExcel()` (Zeile 273-282)
- **Format:** CSV-Download mit UTF-8 BOM
- **Dateiname:** `Offene_Anfragen.csv`

**Status:** ✅ Zusatzfunktion in HTML vorhanden

---

### 4.4 Refresh / Aktualisieren

#### Access
- Automatisch bei Formular-Öffnung
- Manuell: F5 oder Requery

#### HTML
- **Button:** `#btnRefresh` (Zeile 324-326)
- **Funktion:** `loadAnfragen()` (Zeile 62-81)
- **Auto-Refresh:** Nach "Erneut anfragen"

**Status:** ✅ Vorhanden

---

### 4.5 Zeilen-Selektion

#### Access
- Single-Select im Subformular
- Multi-Select möglich mit Shift/Ctrl

#### HTML
- **Single-Select:** Klick auf Zeile (Zeile 221-238)
- **Multi-Select:** ⚠️ **FEHLT** - `selectedRows` Set vorhanden aber keine UI
- **Visual Feedback:** `.selected` CSS-Klasse (Zeile 93-96)

**GAP:** ⚠️ Multi-Selektion in UI nicht sichtbar/bedienbar

---

## 5. EVENTS

### 5.1 Formular-Events

| Access Event | HTML Event | Funktion | Status |
|--------------|------------|----------|--------|
| OnOpen | - | - | ⚠️ N/A |
| OnLoad | DOMContentLoaded → init() | Initialisierung | ✅ OK |
| OnClose | - | - | ⚠️ N/A |
| OnCurrent | - | - | ⚠️ N/A |

### 5.2 Button-Events

| Access Event | HTML Event | Funktion | Status |
|--------------|------------|----------|--------|
| btnAnfragen.OnClick | #btnAnfragen.click | E-Mail-Anfragen senden | ✅ OK |
| - | #btnRefresh.click | Daten neu laden | ✅ ZUSATZ |
| - | #btnFilter.click | Filter-Dialog (Placeholder) | ⚠️ TODO |
| - | #btnExport.click | CSV-Export | ✅ ZUSATZ |

### 5.3 Subformular-Events

| Access Event | HTML Event | Funktion | Status |
|--------------|------------|----------|--------|
| OnCurrent | tbody.click → handleRowClick | Zeilen-Selektion | ✅ OK |
| OnDblClick | - | - | ⚠️ FEHLT |

---

## 6. STYLING UND FARBEN

### 6.1 Access-Farben (Long → HEX)

| Element | Access Long | HEX | HTML Equivalent |
|---------|-------------|-----|-----------------|
| btnAnfragen BackColor | 14136213 | #D7D7D7 | `.btn-success` #28a745 |
| Label ForeColor | 0 (Schwarz) | #000000 | `.toolbar-label` #666 |
| Textbox ForeColor | - | - | `.anfragen-table td` #333 |
| Subform BackColor | - | - | `white` |

**Status:** ⚠️ Button-Farbe abweichend (HTML grün statt grau)

### 6.2 Tabellen-Styling

**Access (Subformular):**
- Endlosformular (Continuous Forms)
- Standard Access-Datasheet-Look

**HTML:**
- Modern Table mit sticky Header
- Zebra-Stripes (#fafafa)
- Hover-Effekt (#e8f4ff)
- Selected-State (#cce5ff)

**Status:** ✅ Modernes Design, bessere UX

---

## 7. API-ABHÄNGIGKEITEN

### 7.1 REST API (api_server.py - Port 5000)

| Endpoint | Methode | Verwendung | Status |
|----------|---------|------------|--------|
| `/api/anfragen` | GET | Offene Anfragen laden | ✅ ERFORDERLICH |
| `/api/anfragen/<id>` | PUT | Status aktualisieren | ⚠️ NICHT GENUTZT |
| `/api/anfragen/senden` | POST | Anfragen senden (Fallback) | ⚠️ NICHT IMPLEMENTIERT |

**GAP:** ⚠️ `/api/anfragen/senden` existiert nicht in api_server.py

### 7.2 VBA Bridge (vba_bridge_server.py - Port 5002)

| Endpoint | Methode | Verwendung | Status |
|----------|---------|------------|--------|
| `/api/vba/anfragen` | POST | E-Mail-Anfragen über VBA senden | ✅ ERFORDERLICH |
| `/api/vba/status` | GET | Bridge-Status prüfen | ⚠️ NICHT GENUTZT |

**Kritisch:** HTML-Formular **MUSS** VBA-Bridge nutzen für E-Mail-Versand

---

## 8. FEHLENDE FUNKTIONEN (GAPS)

### 8.1 Kritische Gaps (Funktionalität fehlt)

| Nr | Beschreibung | Access | HTML | Priorität |
|----|--------------|--------|------|-----------|
| 1 | Multi-Selektion in UI | ✅ Vorhanden | ❌ Code ja, UI nein | 🔴 HOCH |
| 2 | DblClick auf Zeile → Detail-Ansicht | ✅ Möglich | ❌ Fehlt | 🟡 MITTEL |
| 3 | Filter-Dialog (erweitert) | ❌ Nicht vorhanden | ⚠️ Placeholder | 🟢 NIEDRIG |
| 4 | Fallback API-Endpoint `/api/anfragen/senden` | N/A | ❌ Fehlt | 🔴 HOCH |

### 8.2 Technische Gaps

| Nr | Beschreibung | Auswirkung | Priorität |
|----|--------------|------------|-----------|
| 1 | `txSelHeightSub` Control fehlt | Keine - nur Access-intern | 🟢 NIEDRIG |
| 2 | Sortierung nach Name fehlt | Sortiert nur nach Datum + Anfragezeitpunkt | 🟡 MITTEL |
| 3 | VBA-Bridge Dependency | HTML funktioniert NICHT ohne Bridge | 🔴 HOCH |
| 4 | Bridge Event-Listener fehlt | `Bridge.on('onDataReceived', ...)` registriert aber Bridge fehlt | 🔴 HOCH |

### 8.3 UX-Verbesserungen (HTML besser als Access)

| Nr | Feature | Vorteil |
|----|---------|---------|
| 1 | Filter-Dropdown | Schnelle Zeitraum-Filter |
| 2 | CSV-Export | Direkter Daten-Export |
| 3 | Datum-Farbcodierung | Visuell: Grün (Zukunft), Orange (bald), Rot (vorbei) |
| 4 | Loading-Spinner | User-Feedback während Laden |
| 5 | Sticky Table-Header | Immer sichtbar bei Scrollen |

---

## 9. BRIDGE-INTEGRATION

### 9.1 Bridge-Events (JavaScript)

**Senden:**
```javascript
Bridge.sendEvent('loadAnfragen', { filter: { openOnly: true } })
Bridge.sendEvent('anfragen', { ma_id, va_id, ... })
```

**Empfangen:**
```javascript
Bridge.on('onDataReceived', handleBridgeData)
```

**Status:** ⚠️ **Bridge-Objekt fehlt** - Code referenziert `Bridge` aber Import fehlt

### 9.2 Erforderliche Bridge-Dateien

| Datei | Pfad | Status |
|-------|------|--------|
| webview2-bridge.js | js/ oder logic/ | ❌ FEHLT |
| Bridge-Script-Tag | frm_MA_Offene_Anfragen.html | ❌ FEHLT |

**GAP:** 🔴 **KRITISCH** - Bridge nicht eingebunden

---

## 10. BEWERTUNG UND EMPFEHLUNGEN

### 10.1 Gesamtbewertung

| Kategorie | Status | Prozent | Bewertung |
|-----------|--------|---------|-----------|
| **Layout/UI** | ✅ | 95% | Sehr gut umgesetzt, modernes Design |
| **Daten-Anzeige** | ✅ | 90% | Felder korrekt, Filter besser als Access |
| **Button-Funktionen** | ⚠️ | 60% | btnAnfragen vorhanden aber Bridge fehlt |
| **Interaktivität** | ⚠️ | 70% | Single-Select ja, Multi-Select nur Code |
| **API-Integration** | ⚠️ | 50% | API-Calls vorhanden aber Bridge fehlt |
| **Export/Filter** | ✅ | 100% | Zusatzfunktionen vorhanden |

**Gesamt:** ⚠️ **70% - Gut aber unvollständig**

### 10.2 Kritische Punkte

🔴 **BLOCKER:**
1. **Bridge-Objekt nicht eingebunden** → E-Mail-Funktion funktioniert nicht
2. **VBA-Bridge Dependency** → Ohne `vba_bridge_server.py` keine Anfragen sendbar
3. **Fallback-API fehlt** → `/api/anfragen/senden` nicht implementiert

🟡 **WICHTIG:**
1. **Multi-Selektion nicht bedienbar** → Nur Single-Select möglich
2. **Sortierung unvollständig** → Name-Sortierung fehlt

🟢 **NICE-TO-HAVE:**
1. Filter-Dialog erweitern
2. Detail-Ansicht bei DblClick
3. Status-Update direkt in Tabelle

### 10.3 Empfohlene Fixes (Reihenfolge)

#### Fix 1: Bridge einbinden (KRITISCH)
```html
<!-- In frm_MA_Offene_Anfragen.html vor </body> -->
<script src="logic/frm_MA_Offene_Anfragen.webview2.js"></script>
<script src="logic/frm_MA_Offene_Anfragen.logic.js"></script>
```

**Erstelle:** `logic/frm_MA_Offene_Anfragen.webview2.js`
- Bridge-Objekt definieren
- `sendEvent()` und `on()` implementieren
- WebView2 `postMessage` verwenden

#### Fix 2: Fallback-API implementieren
**In api_server.py:**
```python
@app.route('/api/anfragen/senden', methods=['POST'])
def send_anfragen():
    # Alternative zu VBA-Bridge
    # Sendet E-Mails über Python smtplib
    pass
```

#### Fix 3: Multi-Selektion aktivieren
**In frm_MA_Offene_Anfragen.logic.js:**
```javascript
function handleRowClick(e) {
    const tr = e.target.closest('tr');
    const idx = parseInt(tr.dataset.index);

    if (e.ctrlKey) {
        // Toggle Multi-Select
        if (selectedRows.has(idx)) {
            selectedRows.delete(idx);
        } else {
            selectedRows.add(idx);
        }
    } else {
        // Single-Select
        selectedRows.clear();
        selectedRows.add(idx);
    }
    updateRowSelection();
}
```

#### Fix 4: Sortierung korrigieren
**In frm_MA_Offene_Anfragen.logic.js (Zeile 124):**
```javascript
.sort((a, b) => {
    // Sortierung: Auftrag → Name → Datum
    if (a.auftrag !== b.auftrag) {
        return a.auftrag.localeCompare(b.auftrag);
    }
    if (a.name !== b.name) {
        return a.name.localeCompare(b.name);
    }
    return a.datum - b.datum;
})
```

---

## 11. ZUSAMMENFASSUNG

### Was funktioniert ✅
- Layout und Design modern und benutzerfreundlich
- Daten-Anzeige mit allen Feldern korrekt
- Filter-Funktionen erweitert (besser als Access)
- CSV-Export vorhanden
- Refresh-Button
- Single-Select mit Visual Feedback

### Was fehlt ❌
- **Bridge-Objekt nicht eingebunden** (KRITISCH)
- **VBA-Bridge-Dependency** ungelöst
- **Fallback-API für Anfragen senden** fehlt
- **Multi-Selektion in UI** nicht bedienbar
- **DblClick-Event** für Details fehlt

### Was besser ist als Access ⭐
- Moderne Tabellen-UI mit Sticky Header
- Erweiterte Filter-Optionen (7/30 Tage)
- CSV-Export direkt verfügbar
- Datum-Farbcodierung (grün/orange/rot)
- Loading-Feedback mit Spinner
- Responsive Design

### Nächste Schritte (Priorität)
1. 🔴 Bridge-Integration herstellen → `frm_MA_Offene_Anfragen.webview2.js` erstellen
2. 🔴 Fallback-API implementieren → `/api/anfragen/senden` in api_server.py
3. 🟡 Multi-Selektion UI → Ctrl+Klick für mehrere Zeilen
4. 🟡 Sortierung korrigieren → Auftrag → Name → Datum
5. 🟢 Filter-Dialog → Erweiterte Filter-UI
6. 🟢 Detail-Ansicht → DblClick öffnet Modal mit Details

---

**FAZIT:** Das Formular ist zu **70% funktional**. Die UI ist modern und gut umgesetzt, aber die **Bridge-Integration fehlt** komplett, wodurch die Hauptfunktion (E-Mail-Anfragen senden) nicht funktioniert. Nach Behebung der Bridge-Integration und Implementierung des Fallback-Endpoints wäre das Formular zu **90%+ vollständig**.
