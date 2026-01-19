# REPORT: Button-Paritaet (Access vs. HTML)

**Erstellt:** 2026-01-08
**Aktualisiert:** 2026-01-08
**Status:** FIXES IMPLEMENTIERT

---

## Uebersicht

| Access-Button | HTML-Button-ID | Paritaet | Status |
|---------------|----------------|----------|--------|
| btnMailEins | btnMailEins | **TEILWEISE** | API benoetigt |
| btnDruckZusage | btnDruckZusage | **GEFIXT** | Excel-Export implementiert |
| btn_Autosend_BOS | btnMailBOS | **TEILWEISE** | API benoetigt |
| btn_BWN_Druck | btn_BWN_Druck | **N/A** | Access-Code auskommentiert |
| cmd_BWN_send | cmd_BWN_send | **GEFIXT** | Option "nur markierte" hinzugefuegt |
| btnPlan_Kopie | btnPlan_Kopie | **GEFIXT** | Neuer Button + Funktion hinzugefuegt |

---

## Durchgefuehrte Fixes

### FIX 1: btnDruckZusage - Excel-Export (Zeile 847-906)

**Problem:** HTML machte nur `window.print()`, Access erstellt Excel-Datei + setzt Status

**Loesung implementiert:**
```javascript
async function druckeEinsatzliste() {
    // 1. Excel-Export via API
    const result = await Bridge.execute('exportAuftragExcel', { va_id, vadatum });

    // 2. Download der Excel-Datei
    // 3. Status auf "Beendet" setzen (Veranst_Status_ID = 2)
    await Bridge.execute('setAuftragStatus', { va_id, status_id: 2 });

    // Fallback: Browser-Druck wenn API nicht verfuegbar
}
```

**Datei:** `04_HTML_Forms/forms3/logic/frm_va_Auftragstamm.logic.js`

---

### FIX 2: btnPlan_Kopie - Daten in Folgetag kopieren (Zeile 777-846)

**Problem:** HTML-Button "Auftrag kopieren" kopierte den GANZEN Auftrag.
Access btnPlan_Kopie kopiert nur Schichten + MA-Zuordnungen zum naechsten Tag.

**Loesung implementiert:**

1. **Neue Funktion `kopiereInFolgetag()`:**
```javascript
async function kopiereInFolgetag() {
    // Bestaetigung wie in Access
    const antwort = confirm('Daten in Folgetag kopieren?');

    // API-Call zum Kopieren der Tagesdaten
    const result = await Bridge.execute('copyToNextDay', {
        va_id, current_datum, current_datum_id
    });

    // Zum Folgetag navigieren (wie Access btnDatumRight_Click)
}
```

2. **Neuer HTML-Button:**
```html
<button id="btnPlan_Kopie" onclick="kopiereInFolgetag()">Daten in Folgetag</button>
```

3. **Button-Bindung:**
```javascript
bindButton('btnPlan_Kopie', kopiereInFolgetag);
```

**Dateien:**
- `04_HTML_Forms/forms3/logic/frm_va_Auftragstamm.logic.js`
- `04_HTML_Forms/forms3/frm_va_Auftragstamm.html`

---

### FIX 3: cmd_BWN_send - Option "nur markierte Mitarbeiter" (Zeile 1385-1429)

**Problem:** HTML fragte nur "BWN senden?", Access fragt zusaetzlich "Nur markierte?"

**Loesung implementiert:**
```javascript
async function cmdBWNSend() {
    // Erste Bestaetigung
    if (!confirm('BWN wirklich senden?')) return;

    // Zweite Frage wie in Access
    const nurMarkierte = confirm('Nur markierte Mitarbeiter versenden?');

    // API-Call mit Option
    const result = await Bridge.execute('sendBWN', {
        va_id, vadatum, vadatum_id,
        nur_markierte: nurMarkierte  // NEU
    });
}
```

**Datei:** `04_HTML_Forms/forms3/logic/frm_va_Auftragstamm.logic.js`

---

## Erforderliche API-Endpoints

Die folgenden API-Endpoints muessen im Backend implementiert werden:

| Endpoint | Methode | Parameter | Beschreibung |
|----------|---------|-----------|--------------|
| `/api/auftrag/{id}/excel-export` | POST | va_id, vadatum | Erstellt Excel-Datei, gibt download_url zurueck |
| `/api/auftrag/{id}/status` | PUT | va_id, status_id | Setzt Auftragsstatus |
| `/api/auftrag/{id}/copy-to-next-day` | POST | va_id, current_datum, current_datum_id | Kopiert Schichten + Zuordnungen |
| `/api/bwn/send` | POST | va_id, vadatum, nur_markierte | Sendet BWN per E-Mail |

### Bridge.execute Mapping

```javascript
// In bridgeClient.js oder api_server.py muessen diese Mappings existieren:

Bridge.execute('exportAuftragExcel', params)
  -> POST /api/auftrag/{va_id}/excel-export

Bridge.execute('setAuftragStatus', params)
  -> PUT /api/auftrag/{va_id}/status

Bridge.execute('copyToNextDay', params)
  -> POST /api/auftrag/{va_id}/copy-to-next-day

Bridge.execute('sendBWN', params)
  -> POST /api/bwn/send
```

---

## Zusammenfassung

| Metrik | Wert |
|--------|------|
| Buttons analysiert | 6 |
| Buttons mit voller Paritaet | 0 → 3 (nach Fixes) |
| Buttons mit teilweiser Paritaet | 6 → 2 |
| Buttons inaktiv (Access) | 1 |
| Code-Aenderungen | 3 Funktionen |
| Neue HTML-Buttons | 1 |
| Neue Window-Aliase | 4 |

---

## Verbleibende Aufgaben

### Backend-Implementierung erforderlich:

1. **exportAuftragExcel** - Excel-Template befuellen und als Download bereitstellen
2. **setAuftragStatus** - Status in tbl_VA_Auftragstamm aktualisieren
3. **copyToNextDay** - tbl_VA_Start und tbl_MA_VA_Zuordnung kopieren
4. **sendBWN mit nur_markierte** - Parameter im Backend auswerten

---

*Erstellt und aktualisiert von Claude Code*
