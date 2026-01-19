# Gap-Analyse: frm_abwesenheitsuebersicht

**Datum:** 2026-01-12
**Formular-Typ:** Abwesenheitsübersicht (Kalender-View)
**Priorität:** HOCH

---

## 1. Übersicht

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Formular-Typ** | Endlosformular (Datasheet) | Kalender-Matrix | ✅ Modernisiert |
| **Record Source** | qry_DP_MA_NVerfueg | API + Client-Rendering | ✅ Bessere Lösung |
| **Ansicht** | Tabellarisch | Kalender-Grid | ✅ Viel besser! |
| **Navigation** | Ja | Filter (Monat/Jahr) | ✅ Verbessert |
| **Allow Edits** | Ja | Lesemodus (View-Only) | ⚠️ Unterschied! |
| **Sidebar** | Nein | Ja (Personal-Menü) | ✅ Hinzugefügt |

---

## 2. Controls - Detailvergleich

### 2.1 Access Controls (12 TextBoxen)
**Felder im Endlosformular:**
- VA_ID, ZuordID, Anz_MA
- ObjOrt (Objekt/Ort)
- VADatum (Datum)
- Pos_Nr (Positionsnummer)
- MA_Start, MA_Ende (Zeiten)
- MA_ID, MAName
- IstFraglich, Hlp

**Sortierung:** ORDER BY VADatum

### 2.2 HTML Controls
**Filter-Bar:**
- `cboMonat` - Monatsauswahl ✅
- `txtJahr` - Jahreseingabe ✅
- `cboAbteilung` - Abteilungsfilter ✅
- `btnAktualisieren` - Reload Button ✅

**Mitarbeiter-Liste (Links):**
- Scrollbare Liste mit MA-Namen ✅
- Klickbar für Selektion ✅
- Zeigt aktive Mitarbeiter ✅

**Kalender-Grid (Rechts):**
- Tabellarische Ansicht (Tage als Spalten) ✅
- 1 Zeile pro Mitarbeiter ✅
- Farbcodierung nach Abwesenheitsgrund:
  - Grün: Urlaub ✅
  - Rosa: Krank ✅
  - Hellblau: Frei ✅
  - Gelb: Sonstige ✅
- Wochenenden grau hervorgehoben ✅

**Legende:**
- Farbcodes erklärt ✅

### 2.3 Fehlende Controls im HTML
⚠️ **Relevante Unterschiede:**
1. **KEINE Bearbeitungsmöglichkeit** - HTML ist View-Only
2. **KEINE Dienstplan-Felder** (VA_ID, ObjOrt, Schichten)
   - Access zeigt Abwesenheiten IM KONTEXT von Dienstplänen
   - HTML zeigt nur reine Abwesenheiten

❌ **Fehlende Access-Felder:**
- VA_ID, ZuordID (nicht in HTML sichtbar)
- ObjOrt, Pos_Nr (Dienstplan-Kontext fehlt)
- MA_Start, MA_Ende (Zeiten nicht angezeigt)
- IstFraglich-Status (fehlt)

---

## 3. Datenquellen

### Access Query: qry_DP_MA_NVerfueg
```sql
-- Vermutlich komplexe Query mit JOINs:
SELECT
    z.VA_ID, z.ID AS ZuordID, z.Anz_MA,
    v.ObjOrt, v.VADatum, v.Pos_Nr,
    z.MA_Start, z.MA_Ende,
    m.MA_ID, m.MAName, m.IstFraglich,
    ... (Hlp-Feld)
FROM tbl_MA_VA_Zuordnung z
INNER JOIN tbl_VA_... v ON ...
INNER JOIN tbl_MA_... m ON ...
WHERE [Nicht-Verfügbarkeits-Bedingungen]
ORDER BY v.VADatum
```

**Zweck:** Zeigt Mitarbeiter die NICHT verfügbar sind (wegen Abwesenheit oder anderer Zuordnung)

### HTML API-Endpoints
✅ **Implementiert:**
- `GET /api/mitarbeiter?aktiv=true` - Aktive Mitarbeiter
- `GET /api/abwesenheiten?monat=X&jahr=Y` - Abwesenheiten für Zeitraum

⚠️ **Fehlend:**
- `/api/dienstplan/nichtverfuegbar` - Zuordnungen + Abwesenheiten kombiniert

---

## 4. Funktionalität

### 4.1 Implementierte Features
| Feature | Access | HTML | Status |
|---------|--------|------|--------|
| Abwesenheiten anzeigen | ✅ | ✅ | Vollständig |
| Kalender-Ansicht | ❌ | ✅ | HTML besser! |
| Nach Monat filtern | ❌ | ✅ | HTML besser! |
| Nach Abteilung filtern | ❌ | ✅ | HTML besser! |
| Farbcodierung | ❌ | ✅ | HTML besser! |
| Wochenenden hervorheben | ❌ | ✅ | HTML besser! |
| Mitarbeiter-Liste | ❌ | ✅ | HTML besser! |
| Dienstplan-Kontext | ✅ | ❌ | Access besser! |
| Schichtzeiten anzeigen | ✅ | ❌ | Access besser! |
| Bearbeiten möglich | ✅ | ❌ | Access besser! |
| IstFraglich-Status | ✅ | ❌ | Access besser! |

### 4.2 Fehlende Features
❌ **KRITISCH:**
1. **Dienstplan-Integration fehlt** - HTML zeigt nur Abwesenheiten, NICHT Zuordnungen
2. **Keine Schichtzeiten** - MA_Start/MA_Ende nicht sichtbar
3. **Keine Bearbeitung** - View-Only Modus

⚠️ **WICHTIG:**
- Access-Formular hat einen ANDEREN Zweck als HTML!
- Access: "Wer ist WANN NICHT VERFÜGBAR (inkl. Dienstplan)"
- HTML: "Abwesenheitskalender (nur Urlaub/Krank/etc.)"

---

## 5. Layout & Design

### Access
- Endlosformular (Datasheet)
- 12 Spalten nebeneinander
- Sortiert nach VADatum
- Standard Access-Farben

### HTML
- **2-Spalten-Layout:**
  - Links: MA-Liste (200px)
  - Rechts: Kalender-Grid (flex)
- **Kalender-Matrix:**
  - Kopfzeile: Wochentag + Tagesnummer
  - Zeilen: Mitarbeiter
  - Zellen: Farbcodiert nach Abwesenheitsgrund
- **Filter-Bar:** Monat, Jahr, Abteilung
- **Legende:** Farbcodes erklärt

**HTML ist deutlich übersichtlicher und benutzerfreundlicher!** ✅

---

## 6. Events & VBA-Logik

### Access
- **Keine Events** definiert
- Reine Datenanzeige via Query

### HTML (frm_abwesenheitsuebersicht.html - Inline-Script)
✅ **Implementiert:**
- `initMonthSelect()` - Monatsliste füllen
- `renderMitarbeiterList()` - MA-Liste anzeigen
- `renderCalendar()` - Kalender-Grid erstellen
- `findAbsence(maId, dateStr)` - Abwesenheit für Datum suchen
- `getAbsenceClass(grund)` - CSS-Klasse für Farbcodierung
- `loadData()` - Daten von Bridge laden
- `Bridge.on('onDataReceived')` - Event-Handler

⚠️ **Logic-Datei fehlt:**
- Kein separates `.logic.js` File
- Alle Funktionen inline im HTML

---

## 7. Gaps & Risiken

### 7.1 Kritische Gaps
❌ **UNTERSCHIEDLICHER ZWECK:**
- Access: Nichtverfügbarkeiten IM KONTEXT von Dienstplänen
- HTML: Reiner Abwesenheitskalender (Urlaub/Krank)

**Frage:** Welche Variante wird benötigt?
1. **Kalender-View** (aktuell) → OK für Abwesenheitsplanung
2. **Dienstplan-Integration** → Erfordert Umbau + zusätzliche API

### 7.2 Moderate Gaps
⚠️ **Fehlende Access-Features:**
1. **Schichtzeiten** (MA_Start/MA_Ende) nicht angezeigt
2. **IstFraglich-Status** nicht sichtbar
3. **Keine Bearbeitung** möglich (nur View)
4. **Dienstplan-Felder** (VA_ID, ObjOrt) fehlen

⚠️ **API-Gap:**
- `/api/dienstplan/nichtverfuegbar` existiert NICHT
- Wäre nötig für Access-ähnliche Funktionalität

### 7.3 Nice-to-Have
💡 **Zusätzliche Verbesserungen:**
- Tooltip bei Hover (Details zur Abwesenheit)
- Konflikt-Anzeige (mehrere Abwesenheiten am selben Tag)
- Export-Funktion (PDF/Excel)
- Druckansicht für Monatsübersicht

---

## 8. Empfohlene Maßnahmen

### Priorität 1 (Sofort - Entscheidung erforderlich!)
1. ⚠️ **KLÄREN:** Soll HTML die Access-Funktionalität nachbilden?
   - Option A: Kalender-View beibehalten (aktuell) → OK für reine Abwesenheiten
   - Option B: Dienstplan-Integration hinzufügen → Aufwändiger Umbau

2. ⚠️ **Falls Option B:** API erweitern
   - `/api/dienstplan/nichtverfuegbar?datum=X` erstellen
   - Kombination aus Abwesenheiten + Zuordnungen

### Priorität 2 (Kurzfristig)
3. ✅ **Tooltip hinzufügen:** Details bei Hover über farbige Zellen
4. ✅ **IstFraglich-Status** anzeigen (z.B. mit Symbol ⚠️)
5. ✅ **Logic-Datei auslagern:** Inline-Script → `.logic.js`

### Priorität 3 (Mittelfristig)
6. 💡 **Druckansicht** für Monatsübersicht
7. 💡 **Export-Funktion** (PDF/Excel)
8. 💡 **Schichtzeiten** optional anzeigen (falls relevant)

---

## 9. Technische Details

### API-Endpoint-Erweiterung (api_server.py)
```python
@app.route('/api/dienstplan/nichtverfuegbar', methods=['GET'])
def get_nichtverfuegbar():
    """
    Kombination aus:
    - Abwesenheiten (tbl_MA_NVerfuegZeiten)
    - Zuordnungen (tbl_MA_VA_Planung)
    """
    datum = request.args.get('datum')  # Format: YYYY-MM-DD

    # Abwesenheiten
    sql_abw = """
        SELECT MA_ID, 'Abwesenheit' AS Typ, vonDat, bisDat, Grund
        FROM tbl_MA_NVerfuegZeiten
        WHERE ? BETWEEN vonDat AND bisDat
    """

    # Zuordnungen (Dienstplan)
    sql_zuo = """
        SELECT
            p.MA_ID, 'Zuordnung' AS Typ,
            p.MVA_Start, p.MVA_Ende,
            v.Auftrag, v.ObjOrt
        FROM tbl_MA_VA_Planung p
        INNER JOIN tbl_VA_AnzTage vd ON p.VADatum_ID = vd.ID
        INNER JOIN tbl_VA_Auftragstamm v ON p.VA_ID = v.ID
        WHERE vd.VADatum = ?
    """

    # UNION und return...
```

### Tooltip-Erweiterung (HTML)
```javascript
function renderCalendar() {
    // ... existing code ...

    const absence = findAbsence(ma.ID, dateStr);
    const tooltip = absence
        ? `${absence.Grund}\n${absence.vonDat} - ${absence.bisDat}`
        : '';

    bodyHtml += `<td class="${weekendClass} ${absClass}"
                     title="${tooltip}"
                     data-ma="${ma.ID}"
                     data-date="${dateStr}"></td>`;
}

// Click-Handler für Details
document.getElementById('calendarBody').addEventListener('click', (e) => {
    if (e.target.tagName === 'TD' && e.target.dataset.ma) {
        showAbsenceDetails(e.target.dataset.ma, e.target.dataset.date);
    }
});
```

---

## 10. Zusammenfassung

### ✅ Stärken des HTML-Formulars
1. **Moderne Kalender-Ansicht** statt Tabelle
2. **Farbcodierung** für schnelle Übersicht
3. **Intuitive Filterung** (Monat/Jahr/Abteilung)
4. **Wochenenden hervorgehoben**
5. **Responsive Layout** für verschiedene Auflösungen

### ⚠️ Verbesserungsbedarf
1. **Zweck-Unterschied klären** - Kalender vs. Dienstplan-Kontext
2. **Tooltip** für Zusatzinformationen
3. **IstFraglich-Status** anzeigen
4. **Logic-Datei auslagern**

### ❌ Kritische Unterschiede zu Access
1. **Kein Dienstplan-Kontext** (VA_ID, ObjOrt fehlen)
2. **Keine Schichtzeiten** (MA_Start/MA_Ende)
3. **Keine Bearbeitung** (View-Only)

### 🎯 Bewertung
**Status:** 80% FERTIG (für Kalender-View)
**Status:** 40% FERTIG (für Access-Nachbildung)
**Risiko:** MITTEL (Zweck-Klärung erforderlich!)
**Aufwand:**
- Kalender-View: 4-6 Stunden (Tooltip, IstFraglich)
- Dienstplan-Integration: 2-3 Tage (API + Umbau)

**Fazit:** HTML ist als KALENDER-VIEW exzellent, aber für DIENSTPLAN-KONTEXT unvollständig! ⚠️

---

## 11. Entscheidungshilfe

### Variante A: Kalender-View (aktuell)
**Zweck:** Überblick über Abwesenheiten (Urlaub/Krank/etc.)
**Zielgruppe:** Personalplanung, Urlaubsplanung
**Aufwand:** 4-6 Stunden (Feinschliff)
**Empfehlung:** ✅ OK für diesen Zweck!

### Variante B: Dienstplan-Integration
**Zweck:** Wer ist WANN NICHT VERFÜGBAR (Abwesenheit + Zuordnung)
**Zielgruppe:** Dienstplan-Ersteller, Einsatzleitung
**Aufwand:** 2-3 Tage (API + Logik + UI)
**Empfehlung:** ⚠️ Nur wenn WIRKLICH benötigt!

**Frage an Nutzer:** Welche Variante wird benötigt? 🤔
