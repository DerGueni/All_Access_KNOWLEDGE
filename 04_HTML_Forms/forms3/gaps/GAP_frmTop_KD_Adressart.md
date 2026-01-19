# Gap-Analyse: frmTop_KD_Adressart

**Datum:** 2026-01-12
**Formular-Typ:** Popup - Kunden-Adressarten Verwaltung
**Priorität:** NIEDRIG

---

## 1. Übersicht

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Formular-Typ** | Popup-Formular | Placeholder | ❌ Nicht implementiert |
| **Record Source** | tbl_KD_Adressart | KEINE API | ❌ Fehlt |
| **Zweck** | Adressarten pflegen | - | ❌ Fehlt |
| **Allow Edits** | Ja | - | ❌ Fehlt |

---

## 2. Controls

### Access (15 Controls)
**TextBoxen:**
- ID (AutoWert, gesperrt)
- kun_AdressArt (Beschreibung, editierbar)

**Labels:** 2 Beschriftungen

**Buttons:** 11 Navigation-Buttons
- Hilfe, Navigation (Erste/Letzte), CRUD (Neu/Löschen/Speichern)
- BackColor: #FFFFFF (Standard), #D7B5D5 (Löschen)

**Rectangle:** Button-Leiste Hintergrund

**Image/Label:** Logo + Titel

### HTML
❌ **Nur Placeholder-Seite:**
- Titel "Kunden-Adressarten"
- Text: "HTML-Version in Entwicklung"
- Buttons: Zurück, Schließen

---

## 3. Datenquelle

### Access
- **Tabelle:** `tbl_KD_Adressart`
- **Felder:** ID (PK), kun_AdressArt (Text)
- **Beispiele:** Hauptadresse, Lieferadresse, Rechnungsadresse

### HTML
❌ **FEHLT:** Keine API-Integration
⚠️ **Benötigt:** `/api/adressarten` CRUD-Endpoints

---

## 4. Gaps

### Kritische Gaps
❌ **KOMPLETT FEHLEND:**
1. Formular-Implementierung fehlt (nur Placeholder)
2. API-Endpoints fehlen (`/api/adressarten`)
3. Logic-File fehlt
4. Tabelle `tbl_KD_Adressart` nicht integriert

---

## 5. Empfehlung

### Priorität: SEHR NIEDRIG
**Grund:** Stammdaten mit sehr wenigen Einträgen (3-5), wird fast nie geändert

### Aufwand: 4 Stunden
1. API-Endpoint `/api/adressarten` (CRUD)
2. Einfaches HTML-Formular (DataTable)
3. Logic-File
4. Navigation-Buttons

### Alternative:
💡 **Direkt in tbl_KD_Adressart pflegen** (Access-Backend):
- Nur 3-5 Einträge
- Keine HTML-UI erforderlich
- Bei Bedarf später nachrüsten

---

## 6. Zusammenfassung

**Status:** ❌ NICHT IMPLEMENTIERT (0%)
**Risiko:** SEHR NIEDRIG (Stammdaten, quasi statisch)
**Aufwand:** 4 Stunden

**Empfehlung:** SEHR niedrige Priorität - Nur bei explizitem Bedarf implementieren!
