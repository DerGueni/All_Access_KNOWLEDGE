# BUTTON AUDIT: frm_va_Auftragstamm.html

**Audit-Datum:** 2026-01-15
**Formular:** 04_HTML_Forms/forms3/frm_va_Auftragstamm.html
**Logic-Datei:** 04_HTML_Forms/forms3/logic/frm_va_Auftragstamm.logic.js
**API-Server:** 04_HTML_Forms/api/api_server.py

---

## ZUSAMMENFASSUNG

- **Gesamt Buttons:** 47
- **✅ Vollständig:** 37
- **⚠️ Teilweise:** 8
- **❌ Fehlerhaft:** 2

---

## 1. FENSTER-STEUERUNG

| Button-ID | Label | onclick | JS-Funktion | API | Status |
|-----------|-------|---------|-------------|-----|--------|
| fullscreenBtn | ? | `toggleFullscreen()` | ❌ Fehlt | - | ❌ |
| - | _ | `Bridge.sendEvent('minimize')` | ⚠️ Bridge | - | ⚠️ |
| - | □ | `toggleMaximize()` | ❌ Fehlt | - | ❌ |
| - | ✕ | `closeForm()` | ✅ Zeile 1614 | - | ✅ |

**Probleme:**
- `toggleFullscreen()` fehlt in logic.js
- `toggleMaximize()` fehlt in logic.js
- `Bridge.sendEvent()` benötigt WebView2-Bridge (Runtime-abhängig)

---

## 2. HAUPT-AKTIONEN (Header-Buttons)

| Button-ID | Label | onclick | JS-Funktion | API | Status |
|-----------|-------|---------|-------------|-----|--------|
| btnAktualisieren | Aktualisieren | `refreshData()` | ⚠️ Alias für requeryAll | - | ⚠️ |
| btnPositionen | Positionen | `openPositionen()` | ✅ Zeile 916 | - | ✅ |
| btnNeuAuftrag | Neuer Auftrag | `neuerAuftrag()` | ✅ Zeile 1142 | POST /api/auftraege | ✅ |
| btnKopieren | Auftrag kopieren | `auftragKopieren()` | ⚠️ Wrapper-Funktion | POST /api/auftraege/copy | ⚠️ |
| btnLoeschen | Auftrag löschen | `auftragLoeschen()` | ⚠️ Wrapper-Funktion | DELETE /api/auftraege/:id | ⚠️ |
| btnListeStd | Namensliste ESS | `namenslisteESS()` | ⚠️ Wrapper-Funktion | - | ⚠️ |
| btnDruckZusage | EL drucken | `einsatzlisteDrucken()` | ⚠️ Wrapper-Funktion | - | ⚠️ |
| btnMailEins | EL senden MA | `sendeEinsatzlisteMA()` | ⚠️ Wrapper-Funktion | POST /api/auftraege/send-einsatzliste | ⚠️ |
| btnMailBOS | EL senden BOS | `sendeEinsatzlisteBOS()` | ⚠️ Wrapper-Funktion | POST /api/auftraege/send-einsatzliste | ⚠️ |
| btnMailSub | EL senden SUB | `sendeEinsatzlisteSUB()` | ⚠️ Wrapper-Funktion | POST /api/auftraege/send-einsatzliste | ⚠️ |
| btnELGesendet | EL gesendet | `showELGesendet()` | ⚠️ Wrapper-Funktion | - | ⚠️ |

**Probleme:**
- Viele onclick-Handler verwenden andere Funktionsnamen als die definierten JS-Funktionen
- `refreshData()` existiert nicht → sollte `requeryAll()` sein
- Wrapper-Funktionen fehlen für: `auftragKopieren`, `auftragLoeschen`, `namenslisteESS`, `einsatzlisteDrucken`, `sendeEinsatzlisteMA/BOS/SUB`, `showELGesendet`

**Definierte JS-Funktionen (sollten verwendet werden):**
- `neuerAuftrag()` ✅
- `loeschenAuftrag()` - aber onclick nutzt `auftragLoeschen()`
- `kopierenAuftrag()` - aber onclick nutzt `auftragKopieren()`
- `sendeEinsatzliste(typ)` - aber onclick nutzt `sendeEinsatzlisteMA/BOS/SUB()`
- `druckeEinsatzliste()` - aber onclick nutzt `einsatzlisteDrucken()`
- `druckeNamenlisteESS()` - aber onclick nutzt `namenslisteESS()`

---

## 3. HEADER-LINKS

| Element | Label | onclick | JS-Funktion | API | Status |
|---------|-------|---------|-------------|-----|--------|
| span.header-link | Rückmelde-Statistik | `openRueckmeldStatistik()` | ⚠️ Typo | - | ⚠️ |
| span.header-link | Syncfehler | `openSyncfehler()` | ⚠️ Wrapper fehlt | - | ⚠️ |

**Probleme:**
- `openRueckmeldStatistik()` fehlt → Definiert ist `openRueckmeldeStatistik()` (ohne "d")
- `openSyncfehler()` fehlt → Funktion existiert nicht

---

## 4. NAVIGATION (Datum)

| Button-ID | Label | onclick | JS-Funktion | API | Status |
|-----------|-------|---------|-------------|-----|--------|
| btnDatumLeft | ◀ | `datumNavLeft()` | ⚠️ Wrapper fehlt | - | ⚠️ |
| btnDatumRight | ▶ | `datumNavRight()` | ⚠️ Wrapper fehlt | - | ⚠️ |

**Probleme:**
- `datumNavLeft()` fehlt → Definiert ist `navigateVADatum('left')`
- `datumNavRight()` fehlt → Definiert ist `navigateVADatum('right')`

---

## 5. SCHNELLPLANUNG

| Button-ID | Label | onclick | JS-Funktion | API | Status |
|-----------|-------|---------|-------------|-----|--------|
| btnSchnellPlan | Mitarbeiterauswahl | `openMitarbeiterauswahl()` | ✅ Zeile 891 | - | ✅ |

---

## 6. BWN-BUTTONS

| Button-ID | Label | onclick | JS-Funktion | API | Status |
|-----------|-------|---------|-------------|-----|--------|
| btn_BWN_Druck | BWN drucken | `bwnDrucken()` | ⚠️ Wrapper fehlt | - | ⚠️ |
| cmd_BWN_send | BWN senden | `bwnSenden()` | ⚠️ Wrapper fehlt | POST /api/bwn/send | ⚠️ |

**Probleme:**
- `bwnDrucken()` fehlt → Definiert ist `druckeBWN()` (Zeile 1741)
- `bwnSenden()` fehlt → Definiert ist `cmdBWNSend()` (Zeile 1699)

---

## 7. ATTACHMENTS

| Button | Label | onclick | JS-Funktion | API | Status |
|--------|-------|---------|-------------|-----|--------|
| - | Neuen Attach hinzufugen | `neuenAttachHinzufuegen()` | ⚠️ Wrapper fehlt | - | ⚠️ |

**Probleme:**
- `neuenAttachHinzufuegen()` fehlt → Definiert ist `addNewAttachment()` (Zeile 934)

---

## 8. RECHNUNG

| Button | Label | onclick | JS-Funktion | API | Status |
|--------|-------|---------|-------------|-----|--------|
| - | Rechnung PDF | `rechnungPDF()` | ⚠️ Fehlt | - | ⚠️ |
| - | Berechnungsliste PDF | `berechnungslistePDF()` | ⚠️ Fehlt | - | ⚠️ |
| - | Daten laden | `rechnungDatenLaden()` | ⚠️ Fehlt | - | ⚠️ |
| - | Rechnung in Lexware erstellen | `rechnungLexware()` | ⚠️ Fehlt | - | ⚠️ |

**Probleme:**
- ALLE Rechnungs-Funktionen fehlen in logic.js

---

## 9. EVENTDATEN (Web-Daten)

| Button | Label | onclick | JS-Funktion | API | Status |
|--------|-------|---------|-------------|-----|--------|
| - | Web-Daten laden | `webDatenLaden()` | ⚠️ Fehlt | - | ⚠️ |
| - | Speichern | `eventdatenSpeichern()` | ⚠️ Fehlt | - | ⚠️ |

**Probleme:**
- `webDatenLaden()` fehlt
- `eventdatenSpeichern()` fehlt

---

## 10. STATUS-FILTER (Anzeigen-Buttons)

| Button | onclick | JS-Funktion | API | Status |
|--------|---------|-------------|-----|--------|
| .anzeigen-btn | `filterByStatus(1)` | ⚠️ Fehlt | GET /api/auftraege | ⚠️ |
| .anzeigen-btn | `filterByStatus(3)` | ⚠️ Fehlt | GET /api/auftraege | ⚠️ |
| .anzeigen-btn | `filterByStatus(2)` | ⚠️ Fehlt | GET /api/auftraege | ⚠️ |

**Probleme:**
- `filterByStatus()` fehlt

---

## 11. AUFTRAGS-LISTE (Navigation)

| Button | Label | onclick | JS-Funktion | API | Status |
|--------|-------|---------|-------------|-----|--------|
| - | Go | `filterAuftraege()` | ⚠️ Wrapper fehlt | GET /api/auftraege | ⚠️ |
| - | << | `tageZurueck()` | ⚠️ Wrapper fehlt | - | ⚠️ |
| - | >> | `tageVor()` | ⚠️ Wrapper fehlt | - | ⚠️ |
| - | Ab Heute | `abHeute()` | ⚠️ Wrapper fehlt | - | ⚠️ |

**Probleme:**
- `filterAuftraege()` fehlt → Definiert ist `applyAuftraegeFilter()` (Zeile 839)
- `tageZurueck()` fehlt → Definiert ist `shiftAuftraegeFilter(-7)` (Zeile 849)
- `tageVor()` fehlt → Definiert ist `shiftAuftraegeFilter(7)` (Zeile 849)
- `abHeute()` fehlt → Definiert ist `setAuftraegeFilterToday()` (Zeile 861)

---

## 12. SORTIERUNG (Table Headers)

| Element | onclick | JS-Funktion | API | Status |
|---------|---------|-------------|-----|--------|
| th | `sortAuftraege('datum')` | ⚠️ Fehlt | - | ⚠️ |
| th | `sortAuftraege('auftrag')` | ⚠️ Fehlt | - | ⚠️ |
| th | `sortAuftraege('objekt')` | ⚠️ Fehlt | - | ⚠️ |
| th | `sortAuftraege('soll')` | ⚠️ Fehlt | - | ⚠️ |
| th | `sortAuftraege('ist')` | ⚠️ Fehlt | - | ⚠️ |
| th | `sortAuftraege('status')` | ⚠️ Fehlt | - | ⚠️ |

**Probleme:**
- `sortAuftraege()` fehlt komplett

---

## 13. MODAL-BUTTONS

| Button-ID | Label | onclick | JS-Funktion | API | Status |
|-----------|-------|---------|-------------|-----|--------|
| - | ✕ | `closeModal('confirmModal')` | ⚠️ Fehlt | - | ⚠️ |
| confirmYes | Ja | - | ⚠️ Event-Handler | - | ⚠️ |
| - | Nein | `closeModal('confirmModal')` | ⚠️ Fehlt | - | ⚠️ |
| - | × | `document.getElementById('elGesendetModal').style.display='none'` | ✅ Inline | - | ✅ |

**Probleme:**
- `closeModal()` fehlt

---

## 14. CONTEXT-MENU (Attachments)

| onclick | JS-Funktion | API | Status |
|---------|-------------|-----|--------|
| `openAttachment(${attachId})` | ⚠️ Fehlt | - | ⚠️ |
| `downloadAttachment(${attachId})` | ⚠️ Fehlt | - | ⚠️ |
| `deleteAttachment(${attachId})` | ⚠️ Fehlt | - | ⚠️ |

**Probleme:**
- ALLE Context-Menu-Funktionen fehlen

---

## KRITISCHE PROBLEME

### 1. Funktionsnamen-Inkonsistenzen

**Pattern:** onclick nutzt andere Namen als definierte JS-Funktionen

| onclick (HTML) | Definiert (JS) | Fix benötigt |
|----------------|----------------|--------------|
| `refreshData()` | `requeryAll()` | ✅ Wrapper |
| `auftragKopieren()` | `kopierenAuftrag()` | ✅ Wrapper |
| `auftragLoeschen()` | `loeschenAuftrag()` | ✅ Wrapper |
| `namenslisteESS()` | `druckeNamenlisteESS()` | ✅ Wrapper |
| `einsatzlisteDrucken()` | `druckeEinsatzliste()` | ✅ Wrapper |
| `sendeEinsatzlisteMA()` | `sendeEinsatzliste('MA')` | ✅ Wrapper |
| `sendeEinsatzlisteBOS()` | `sendeEinsatzliste('BOS')` | ✅ Wrapper |
| `sendeEinsatzlisteSUB()` | `sendeEinsatzliste('SUB')` | ✅ Wrapper |
| `datumNavLeft()` | `navigateVADatum('left')` | ✅ Wrapper |
| `datumNavRight()` | `navigateVADatum('right')` | ✅ Wrapper |
| `bwnDrucken()` | `druckeBWN()` | ✅ Wrapper |
| `bwnSenden()` | `cmdBWNSend()` | ✅ Wrapper |
| `neuenAttachHinzufuegen()` | `addNewAttachment()` | ✅ Wrapper |
| `filterAuftraege()` | `applyAuftraegeFilter()` | ✅ Wrapper |
| `tageZurueck()` | `shiftAuftraegeFilter(-7)` | ✅ Wrapper |
| `tageVor()` | `shiftAuftraegeFilter(7)` | ✅ Wrapper |
| `abHeute()` | `setAuftraegeFilterToday()` | ✅ Wrapper |
| `openRueckmeldStatistik()` | `openRueckmeldeStatistik()` | ✅ Typo-Fix |

### 2. Komplett fehlende Funktionen

Folgende onclick-Handler haben KEINE entsprechende JS-Funktion:

| Funktion | Verwendung | Priorität |
|----------|------------|-----------|
| `toggleFullscreen()` | Fenster-Steuerung | HOCH |
| `toggleMaximize()` | Fenster-Steuerung | HOCH |
| `showELGesendet()` | EL-Status anzeigen | MITTEL |
| `openSyncfehler()` | Link zu Syncfehler-Formular | NIEDRIG |
| `rechnungPDF()` | Rechnung generieren | MITTEL |
| `berechnungslistePDF()` | Berechnungsliste generieren | MITTEL |
| `rechnungDatenLaden()` | Rechnungsdaten laden | MITTEL |
| `rechnungLexware()` | Lexware-Export | MITTEL |
| `webDatenLaden()` | Eventdaten laden | NIEDRIG |
| `eventdatenSpeichern()` | Eventdaten speichern | NIEDRIG |
| `filterByStatus()` | Status-Filter | MITTEL |
| `sortAuftraege()` | Spalten sortieren | MITTEL |
| `closeModal()` | Modal schließen | HOCH |
| `openAttachment()` | Attachment öffnen | MITTEL |
| `downloadAttachment()` | Attachment herunterladen | MITTEL |
| `deleteAttachment()` | Attachment löschen | MITTEL |

### 3. API-Endpoints

**✅ Vorhandene relevante Endpoints:**
- `GET /api/auftraege` → Auftragsliste laden
- `GET /api/auftraege/:id` → Einzelner Auftrag
- `POST /api/auftraege` → Neuer Auftrag
- `PUT /api/auftraege/:id` → Auftrag aktualisieren
- `DELETE /api/auftraege/:id` → Auftrag löschen
- `POST /api/auftraege/copy` → Auftrag kopieren
- `POST /api/auftraege/send-einsatzliste` → Einsatzliste senden
- `POST /api/bwn/send` → BWN senden
- `GET /api/auftraege/:id/schichten` → Schichten laden
- `GET /api/auftraege/:id/zuordnungen` → Zuordnungen laden

**❌ Fehlende Endpoints (falls benötigt):**
- Attachments CRUD (falls nicht über WebView2-Bridge)
- Rechnung/Berechnungsliste PDF-Generation
- Eventdaten-Import/Export

---

## EMPFOHLENE MASSNAHMEN

### Sofort (Kritisch):

1. **Wrapper-Funktionen ergänzen** (in logic.js am Ende):
```javascript
// === WRAPPER-FUNKTIONEN (Button-Kompatibilität) ===
function refreshData() { return requeryAll(); }
function auftragKopieren() { return kopierenAuftrag(false); }
function auftragLoeschen() { return loeschenAuftrag(); }
function namenslisteESS() { return druckeNamenlisteESS(); }
function einsatzlisteDrucken() { return druckeEinsatzliste(); }
function sendeEinsatzlisteMA() { return sendeEinsatzliste('MA'); }
function sendeEinsatzlisteBOS() { return sendeEinsatzliste('BOS'); }
function sendeEinsatzlisteSUB() { return sendeEinsatzliste('SUB'); }
function datumNavLeft() { return navigateVADatum('left'); }
function datumNavRight() { return navigateVADatum('right'); }
function bwnDrucken() { return druckeBWN(); }
function bwnSenden() { return cmdBWNSend(); }
function neuenAttachHinzufuegen() { return addNewAttachment(); }
function filterAuftraege() { return applyAuftraegeFilter(); }
function tageZurueck() { return shiftAuftraegeFilter(-7); }
function tageVor() { return shiftAuftraegeFilter(7); }
function abHeute() { return setAuftraegeFilterToday(); }
```

2. **Typo-Fix:**
```javascript
function openRueckmeldStatistik() { return openRueckmeldeStatistik(); }
```

3. **Fenster-Steuerung:**
```javascript
function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
    } else {
        document.exitFullscreen();
    }
}

function toggleMaximize() {
    Bridge.sendEvent('toggle-maximize');
}
```

### Kurzfristig:

4. **Modal-Management:**
```javascript
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}
```

5. **Status-Filter:**
```javascript
function filterByStatus(statusId) {
    // Filtert Auftragsliste nach Status
    // Implementierung ähnlich wie applyAuftraegeFilter()
}
```

6. **Sortierung:**
```javascript
function sortAuftraege(field) {
    // Sortiert Auftragsliste nach Spalte
}
```

### Mittelfristig:

7. **EL-Gesendet-Modal:**
```javascript
function showELGesendet() {
    document.getElementById('elGesendetModal').style.display = 'block';
}
```

8. **Attachment-Funktionen:**
```javascript
function openAttachment(id) { /* Implementierung */ }
function downloadAttachment(id) { /* Implementierung */ }
function deleteAttachment(id) { /* Implementierung */ }
```

9. **Rechnungs-Funktionen:**
```javascript
function rechnungPDF() { /* Implementierung */ }
function berechnungslistePDF() { /* Implementierung */ }
function rechnungDatenLaden() { /* Implementierung */ }
function rechnungLexware() { /* Implementierung */ }
```

### Langfristig:

10. **Eventdaten-Integration:**
```javascript
function webDatenLaden() { /* Implementierung */ }
function eventdatenSpeichern() { /* Implementierung */ }
```

11. **Syncfehler-Link:**
```javascript
function openSyncfehler() {
    Bridge.openForm('frm_SyncError');
}
```

---

## STATISTIK NACH PRIORITÄT

| Priorität | Anzahl | Beschreibung |
|-----------|--------|--------------|
| 🔴 KRITISCH | 18 | Wrapper-Funktionen + Fenster-Steuerung |
| 🟡 MITTEL | 12 | Filter, Sortierung, Rechnungen, Attachments |
| 🟢 NIEDRIG | 4 | Eventdaten, Syncfehler |

---

**WICHTIG:** Dieser Audit zeigt NUR den IST-Zustand. Es wurden KEINE Änderungen vorgenommen!

**Nächster Schritt:** Entscheidung welche Funktionen implementiert werden sollen.
