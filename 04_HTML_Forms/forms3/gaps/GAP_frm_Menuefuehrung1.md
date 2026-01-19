# Gap-Analyse: frm_Menuefuehrung1 (Hauptmenü Navigation)

**Formular-Typ:** Navigation/Menü-Formular (Sidebar)
**Priorität:** Hoch (Haupt-Navigation für Personal/Lohn-Funktionen)
**Access-Name:** `frm_Menuefuehrung1`
**HTML-Name:** `frm_Menuefuehrung1.html`

---

## Executive Summary

Das Menuefuehrung1-Formular ist ein **Seiten-Menü** für Personal-, Lohn- und Sync-Funktionen. Die HTML-Version zeigt ein identisches Popup-Overlay-Menü mit allen Buttons. Die Funktionalität ist stark eingeschränkt, da die verlinkten Ziel-Formulare teilweise noch nicht existieren oder nicht vollständig umgesetzt sind.

**Gesamtbewertung:** 80% UI umgesetzt, aber 30% funktional (viele Ziele fehlen)

---

## 1. Struktureller Vergleich

### Access-Original

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Menue-Buttons** | 14 | Personal/Lohn-Funktionen |
| **Unsichtbare Buttons** | 2 | Befehl24, Btn_Personalvorlagen |
| **Close-Button** | 1 | Menü schließen |
| **Labels** | 1 | Menü-Titel (mit OnMouseMove) |
| **Rechtecke** | 3 | Visuelle Gruppierung (3 Bereiche) |

**Gesamt:** 18 Buttons + 1 Label + 3 Rechtecke = 22 Elemente

### HTML-Version

| Kategorie | Anzahl | Beschreibung |
|-----------|--------|--------------|
| **Popup-Overlay** | 1 | Dunkler Hintergrund |
| **Menue-Buttons** | 14 | Identisch zu Access |
| **Close-Button** | 1 | X-Button in Titelleiste |
| **Title-Bar** | 1 | Windows-Style Titelleiste |
| **Gruppen-Sections** | 3 | Entspricht Access-Rechtecken |

**Gesamt:** 16 Buttons + 1 Overlay + 1 Title-Bar = 18 Elemente

---

## 2. Menü-Struktur (Access vs. HTML)

### Gruppe 1: Hauptfunktionen

| Button | Caption (Access) | HTML vorhanden? | Ziel-Formular | HTML-Ziel vorhanden? |
|--------|-----------------|----------------|---------------|---------------------|
| **Befehl22** | ??? | ✅ Ja | ??? | ❓ Unbekannt |
| **btn_1** | ??? | ✅ Ja | ??? | ❓ Unbekannt |

*Hinweis: Access-Export enthält keine Button-Captions für diese zwei Buttons*

### Gruppe 2: Berichte & Listen

| Button | Caption (HTML) | HTML vorhanden? | Ziel-Formular | HTML-Ziel vorhanden? |
|--------|---------------|----------------|---------------|---------------------|
| **btnLohnabrech** | Lohnabrechnungen | ✅ Ja | `frm_N_Lohnabrechnungen` | ✅ Ja (forms3) |
| **btnLetzterEinsatz** | Letzter Einsatz | ✅ Ja | Report: `rpt_Letzter_Einsatz` | ❌ Nein (Report, nicht HTML) |
| **btnFCN_Meldeliste** | FCN Meldeliste | ✅ Ja | Report: `rpt_FCN_Meldeliste` | ❌ Nein (Report, nicht HTML) |
| **btnNamensliste** | Namensliste | ✅ Ja | Report: `rpt_Namensliste` | ❌ Nein (Report, nicht HTML) |
| **btn_stunden_sub** | Stunden | ✅ Ja | ??? | ❓ Unbekannt |
| **btn_MAStamm_Excel** | MA-Stamm Excel | ✅ Ja | Excel-Export-Funktion | ❌ Nein (Excel-Interop) |
| **Befehl37** | ??? | ✅ Ja | ??? | ❓ Unbekannt |
| **Befehl24** | ??? (UNSICHTBAR) | ❌ Nein | ??? | ❓ Unbekannt |

### Gruppe 3: Sync & Abwesenheiten

| Button | Caption (HTML) | HTML vorhanden? | Ziel-Formular | HTML-Ziel vorhanden? |
|--------|---------------|----------------|---------------|---------------------|
| **btn_LoewensaalSync** | Löwensaal Sync | ✅ Ja | Sync-Funktion | ❌ Nein (Backend-Prozess) |
| **btn_Loewensaal Sync HP** | Löwensaal Sync HP | ✅ Ja | Sync-Funktion | ❌ Nein (Backend-Prozess) |
| **btnLohnarten** | Lohnarten | ✅ Ja | `tbl_Lohnarten` Verwaltung | ❓ Unbekannt |
| **btn_Abwesenheiten** | Abwesenheiten | ✅ Ja | `frm_Abwesenheiten` | ✅ Ja (forms3) |
| **btnStundenMA** | Stunden MA | ✅ Ja | ??? | ❓ Unbekannt |
| **Btn_Personalvorlagen** | ??? (UNSICHTBAR) | ❌ Nein | ??? | ❓ Unbekannt |

### Fußbereich

| Button | Caption | HTML vorhanden? | Funktion |
|--------|---------|----------------|----------|
| **btn_menue2_close** | [Menü schließen Icon] | ✅ Ja | Menü schließen |
| **Befehl40** | ??? | ✅ Ja | ??? |

---

## 3. Fehlende Features (Access → HTML)

### ❌ NICHT vorhanden/funktional in HTML

1. **Report-Aufrufe:**
   - Letzter Einsatz (Report)
   - FCN Meldeliste (Report)
   - Namensliste (Report)
   → **Problem:** HTML hat keine Report-Engine

2. **Excel-Export:**
   - MA-Stamm Excel (direkter Excel-Export)
   → **Problem:** Kein COM-Interop in Browser

3. **Backend-Sync-Prozesse:**
   - Löwensaal Sync
   - Löwensaal Sync HP
   → **Problem:** Backend-Prozesse laufen in Access/VBA

4. **Unbekannte Ziele:**
   - Befehl22, btn_1, Befehl37, Befehl40
   - btn_stunden_sub, btnStundenMA
   → **Problem:** Access-Export enthält keine Captions/Ziele

5. **Unsichtbare Buttons:**
   - Befehl24
   - Btn_Personalvorlagen
   → In HTML weggelassen (korrekt)

### ⚠️ TEILWEISE vorhanden

1. **Formulare:**
   - ✅ Lohnabrechnungen → `frm_N_Lohnabrechnungen.html` (vorhanden)
   - ✅ Abwesenheiten → `frm_Abwesenheiten.html` (vorhanden)
   - ❓ Lohnarten → Unbekannt ob HTML existiert

---

## 4. UI/UX Unterschiede

### Access-Original

- **Position:** Links im Fenster, fix positioniert
- **Stil:** 3 Rechtecke (Gruppe 1/2/3) als visuelle Trennung
- **Farben:** Hellblau (#d9a919 → #da9919 in Hex) für Buttons, gelber Border
- **Hover:** OnMouseMove Events für Titel-Label und Close-Button
- **Größe:** Feste Button-Größe (2580 x 335 Twips)

### HTML-Version

- **Position:** Popup-Overlay über gesamtem Bildschirm (dunkler Hintergrund)
- **Stil:** Windows XP/2000-Style mit Title-Bar (blauer Gradient)
- **Farben:** Blauer Hintergrund (#6060a0), hellblaue Buttons
- **Hover:** CSS-Hover-Effekte
- **Größe:** Feste Breite 200px, responsive Höhe
- **Animation:** Slide-in von links (CSS `transform: translateX(-100%)`)

**Unterschied:** HTML ist als **Overlay-Popup** implementiert, Access war ein **festes Seiten-Menü**.

---

## 5. Funktionale Gaps (detailliert)

### 5.1 Report-Funktionen (NICHT umsetzbar wie in Access)

| Button | Access-Funktion | HTML-Lösung | Aufwand |
|--------|----------------|-------------|---------|
| **Letzter Einsatz** | `DoCmd.OpenReport "rpt_Letzter_Einsatz"` | HTML-Report-Viewer oder PDF-Export | Hoch (20h) |
| **FCN Meldeliste** | `DoCmd.OpenReport "rpt_FCN_Meldeliste"` | HTML-Report-Viewer oder PDF-Export | Hoch (20h) |
| **Namensliste** | `DoCmd.OpenReport "rpt_Namensliste"` | HTML-Report-Viewer oder PDF-Export | Hoch (20h) |

**Alternativen:**
1. **PDF-Export:** API-Endpoint generiert PDF, zeigt es in neuem Tab an
2. **HTML-Report-Viewer:** Eigene HTML-Seite mit Report-Daten (wie Tabelle)
3. **Excel-Export:** Download als XLSX statt Anzeige

### 5.2 Excel-Export (NICHT direkt umsetzbar)

| Button | Access-Funktion | HTML-Lösung | Aufwand |
|--------|----------------|-------------|---------|
| **MA-Stamm Excel** | `DoCmd.OutputTo acOutputTable, "tbl_MA_Mitarbeiterstamm", acFormatXLSX` | API-Endpoint `/api/export/mitarbeiter/excel` | Mittel (8h) |

**Lösung:**
```javascript
// Button-Click in HTML
async function exportMitarbeiterExcel() {
    const response = await fetch('/api/export/mitarbeiter/excel');
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Mitarbeiterstamm.xlsx';
    a.click();
}
```

**API-Implementierung (Python):**
```python
import openpyxl
from flask import send_file

@app.route('/api/export/mitarbeiter/excel', methods=['GET'])
def export_mitarbeiter_excel():
    # Daten aus DB laden
    mitarbeiter = db.execute('SELECT * FROM tbl_MA_Mitarbeiterstamm').fetchall()

    # Excel erstellen
    wb = openpyxl.Workbook()
    ws = wb.active
    # ... Daten schreiben ...

    # Als Response senden
    return send_file(excel_file, as_attachment=True, download_name='Mitarbeiterstamm.xlsx')
```

### 5.3 Backend-Sync-Prozesse (Backend-API erforderlich)

| Button | Access-Funktion | HTML-Lösung | Aufwand |
|--------|----------------|-------------|---------|
| **Löwensaal Sync** | VBA-Prozess: Daten mit Löwensaal-DB synchronisieren | API-Endpoint `/api/sync/loewensaal` (POST) | Hoch (16h) |
| **Löwensaal Sync HP** | VBA-Prozess: Daten mit Löwensaal-HP synchronisieren | API-Endpoint `/api/sync/loewensaal-hp` (POST) | Hoch (16h) |

**Problem:** Sync-Logik ist komplex und liegt in VBA. Muss nach Python/API migriert werden.

**Lösung:**
1. Sync-VBA-Code analysieren
2. In Python umsetzen (z.B. mit `pyodbc` für SQL-Zugriff)
3. API-Endpoint bereitstellen
4. HTML-Button ruft API auf, zeigt Progress-Bar

---

## 6. Empfohlene Maßnahmen

### Phase 1: Button-Ziele dokumentieren (SOFORT)

**Aufgabe:** Access-Datenbank öffnen, VBA-Code für alle Buttons extrahieren

```vba
' Beispiel: btnLohnabrech_Click()
Private Sub btnLohnabrech_Click()
    DoCmd.OpenForm "frm_N_Lohnabrechnungen"
End Sub
```

**Aufwand:** 2 Stunden
**Nutzen:** Wissen, welche Formulare/Reports/Funktionen fehlen

### Phase 2: Fehlende Formulare umsetzen (WICHTIG)

| Formular | HTML vorhanden? | Priorität | Aufwand |
|----------|----------------|-----------|---------|
| `frm_N_Lohnabrechnungen` | ✅ Ja | - | - |
| `frm_Abwesenheiten` | ✅ Ja | - | - |
| `frm_Lohnarten` | ❓ | Mittel | 8h |
| `frm_Stunden` | ❓ | Hoch | 12h |
| `frm_StundenMA` | ❓ | Hoch | 12h |

**Gesamt:** ca. 32 Stunden (falls alle fehlen)

### Phase 3: Report-Alternative (OPTIONAL)

**Option A: PDF-Export (empfohlen)**

API-Endpoint generiert PDF, öffnet in neuem Tab:

```python
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

@app.route('/api/reports/letzter-einsatz', methods=['GET'])
def report_letzter_einsatz():
    # Daten laden
    data = db.execute('SELECT * FROM qry_Letzter_Einsatz').fetchall()

    # PDF erstellen
    pdf = generate_pdf_report(data, 'Letzter Einsatz')

    return send_file(pdf, mimetype='application/pdf')
```

**Aufwand pro Report:** 6-8 Stunden
**Nutzen:** Professionelle Report-Ausgabe

**Option B: HTML-Report-Viewer (einfacher)**

Eigene HTML-Seite mit Tabelle:

```html
<!-- report_letzter_einsatz.html -->
<table class="report-table">
    <thead>
        <tr><th>Mitarbeiter</th><th>Letzter Einsatz</th><th>Auftrag</th></tr>
    </thead>
    <tbody id="reportData"></tbody>
</table>
<script>
    fetch('/api/reports/letzter-einsatz/data')
        .then(r => r.json())
        .then(data => renderTable(data));
</script>
```

**Aufwand pro Report:** 3-4 Stunden
**Nutzen:** Schnelle Umsetzung, aber weniger professionell

### Phase 4: Excel-Export (WICHTIG)

**API-Endpoint für MA-Stamm Excel-Export:**

```python
@app.route('/api/export/mitarbeiter/excel', methods=['GET'])
def export_mitarbeiter_excel():
    import pandas as pd

    # Daten laden
    df = pd.read_sql('SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE IstAktiv = TRUE', conn)

    # Excel erstellen
    excel_file = 'MA_Stamm_Export.xlsx'
    df.to_excel(excel_file, index=False)

    return send_file(excel_file, as_attachment=True)
```

**Aufwand:** 4 Stunden
**Nutzen:** Kritische Funktion für Personalverwaltung

### Phase 5: Sync-Prozesse (LANGFRISTIG)

**Nur umsetzen, wenn Löwensaal-Sync tatsächlich genutzt wird!**

1. VBA-Sync-Code analysieren (4h)
2. In Python umsetzen (12h)
3. API-Endpoint bereitstellen (4h)
4. HTML-UI mit Progress-Bar (4h)

**Gesamt:** 24 Stunden pro Sync-Prozess

---

## 7. Priorisierung

| Phase | Feature | Umsetzbar? | Aufwand | Nutzen | Priorität |
|-------|---------|------------|---------|--------|-----------|
| **1** | Button-Ziele dokumentieren | ✅ Ja | 2h | Hoch | ⭐⭐⭐⭐⭐ |
| **2** | Fehlende Formulare umsetzen | ✅ Ja | 32h | Hoch | ⭐⭐⭐⭐ |
| **4** | Excel-Export (MA-Stamm) | ✅ Ja | 4h | Hoch | ⭐⭐⭐⭐ |
| **3A** | Reports als PDF | ✅ Ja | 20h | Mittel | ⭐⭐⭐ |
| **3B** | Reports als HTML-Tabelle | ✅ Ja | 10h | Mittel | ⭐⭐⭐ |
| **5** | Sync-Prozesse | ✅ Ja | 48h | Niedrig | ⭐⭐ |

**Gesamtaufwand (ohne Sync):** 68 Stunden (Phase 1-4)
**Erwarteter Umsetzungsgrad:** 90%+ (alle kritischen Funktionen)

---

## 8. Besonderheiten

### 8.1 Menü-Typ

- **Access:** Festes Seiten-Menü (immer sichtbar)
- **HTML:** Popup-Overlay (auf Klick öffnen/schließen)

**Vorteil HTML:** Spart Platz, moderneres UX
**Nachteil HTML:** Ein Klick mehr nötig

### 8.2 Unbekannte Button-Captions

Der Access-Export enthält **keine Captions** für:
- Befehl22, btn_1, Befehl37, Befehl40

**Lösung:** Access-Datenbank öffnen, im Form-Designer nachsehen oder VBA-Code prüfen.

### 8.3 Unsichtbare Buttons

- **Befehl24** (Position 5550, unsichtbar)
- **Btn_Personalvorlagen** (Position 8505, unsichtbar)

**Grund:** Wahrscheinlich deaktivierte Features oder "Work in Progress"
**HTML:** Korrekt weggelassen

### 8.4 OnMouseMove Events

Access nutzt `OnMouseMove` für:
- `lbl_Menue2` (Titel-Label)
- `btn_menue2_close` (Close-Button)

**Zweck:** Wahrscheinlich Hover-Effekte oder Drag&Drop
**HTML:** Über CSS `:hover` einfacher umsetzbar

---

## 9. Technische Implementierung (HTML)

### Popup-Overlay

```css
.popup-overlay {
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.3);
    z-index: 9998;
}
```

### Slide-in Animation

```css
.window-frame {
    animation: slideIn 0.3s ease-out;
}
@keyframes slideIn {
    from { transform: translateX(-100%); }
    to { transform: translateX(0); }
}
```

### Button-Struktur

```html
<div class="menu-group">
    <h4>Personal & Lohn</h4>
    <button onclick="openForm('frm_N_Lohnabrechnungen')">Lohnabrechnungen</button>
    <button onclick="openForm('frm_Abwesenheiten')">Abwesenheiten</button>
    <!-- ... -->
</div>
```

### Form-Navigation

```javascript
function openForm(formName) {
    // Shell-Modus: In iframe laden
    if (window.parent !== window) {
        window.parent.postMessage({
            type: 'NAVIGATE',
            form: formName
        }, '*');
    } else {
        // Standalone: Neue Seite
        window.location.href = formName + '.html';
    }
    closeMenu();
}
```

---

## 10. Fazit

**Status:** ⚠️ **UI zu 80% umgesetzt, funktional nur 30%**

Das Menü-UI ist vollständig vorhanden, aber viele Ziele fehlen:

### ✅ Was funktioniert:

- UI/Layout des Menüs (alle Buttons, Gruppen, Farben)
- Popup-Overlay-Mechanik
- Schließen-Funktion
- Links zu existierenden Formularen (Lohnabrechnungen, Abwesenheiten)

### ❌ Was fehlt:

- 3 Report-Buttons (Letzter Einsatz, FCN, Namensliste) → **Keine Reports in HTML**
- Excel-Export-Button → **Keine Excel-COM-Interop**
- 2 Sync-Buttons → **Backend-Prozesse fehlen**
- 6 unbekannte Buttons → **Captions/Ziele unbekannt**

### 📋 Nächste Schritte:

1. **SOFORT:** Button-Ziele in Access dokumentieren (2h)
2. **WICHTIG:** Fehlende Formulare umsetzen (32h)
3. **WICHTIG:** Excel-Export via API (4h)
4. **OPTIONAL:** Reports als PDF oder HTML-Tabelle (10-20h)
5. **LANGFRISTIG:** Sync-Prozesse nur bei Bedarf (48h)

**Gesamtaufwand für vollständige Funktionalität:** 88 Stunden (mit Reports + Sync)
**Minimalaufwand für Kernfunktionen:** 38 Stunden (ohne Reports/Sync)

**Endgültiger Umsetzungsgrad realistisch:** 90% (nach Phase 1-4, ohne Sync)
