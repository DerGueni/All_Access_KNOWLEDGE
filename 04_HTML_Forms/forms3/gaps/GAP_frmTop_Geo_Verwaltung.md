# Gap-Analyse: frmTop_Geo_Verwaltung

**Datum:** 2026-01-12
**Formular-Typ:** Popup - Geografische Verwaltung (PLZ/Ort)
**Priorität:** NIEDRIG

---

## 1. Übersicht

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Formular-Typ** | Popup-Formular | Placeholder | ❌ Nicht implementiert |
| **Record Source** | tbl_PLZ (Tabelle) | KEINE API | ❌ Fehlt |
| **Zweck** | PLZ/Ort Stammdaten pflegen | - | ❌ Fehlt |
| **Allow Edits** | Ja | - | ❌ Fehlt |

---

## 2. Controls

### Access (14 Controls)
**TextBoxen:**
- PLZ (Postleitzahl, Tab Index 0)
- Ort (Ortsname, Tab Index 1)
- Bundesland_ID (ID, Tab Index 2)
- Bundesland (Anzeige, gesperrt)
- Landkreis (Tab Index 3)
- Telefon_Vorwahl (Tab Index 4)
- Kfz_Kennzeichen (Tab Index 5)

**Labels:** 7 Beschriftungen

**Navigation-Buttons:** 13 Buttons (Erste, Letzte, Neu, Löschen, etc.)

### HTML
❌ **Nur Placeholder-Seite:**
- Titel "Geo-Verwaltung"
- Text: "HTML-Version in Entwicklung"
- Buttons: Zurück, Schließen

---

## 3. Datenquelle

### Access
- **Tabelle:** `tbl_PLZ`
- **Felder:** PLZ, Ort, Bundesland_ID, Landkreis, Telefon_Vorwahl, Kfz_Kennzeichen

### HTML
❌ **FEHLT:** Keine API-Integration
⚠️ **Benötigt:** `/api/plz` CRUD-Endpoints

---

## 4. Gaps

### Kritische Gaps
❌ **KOMPLETT FEHLEND:**
1. Formular-Implementierung fehlt (nur Placeholder)
2. API-Endpoints fehlen (`/api/plz`)
3. Logic-File fehlt
4. Datenbank-Tabelle `tbl_PLZ` nicht integriert

---

## 5. Empfehlung

### Priorität: NIEDRIG
**Grund:** PLZ-Stammdaten werden selten geändert

### Aufwand: 1 Tag
1. API-Endpoints für `/api/plz` (CRUD)
2. HTML-Formular mit DataTable oder Grid
3. Logic-File für CRUD-Operationen
4. Navigation-Buttons (wie frm_Abwesenheiten)

### Alternative:
💡 **Import/Export-Funktion** statt interaktivem Formular:
- CSV-Import für PLZ-Datenbanken
- Nur Anzeige, keine Bearbeitung nötig

---

## 6. Zusammenfassung

**Status:** ❌ NICHT IMPLEMENTIERT (0%)
**Risiko:** NIEDRIG (Stammdaten, selten geändert)
**Aufwand:** 1 Tag (vollständige Implementierung)

**Empfehlung:** Niedrige Priorität - Erst implementieren wenn tatsächlich benötigt!
