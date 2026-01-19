# Fehlende Formulare für Auftragstamm-Buttons

**Datum:** 2026-01-15 19:30

Folgende Access-Formulare werden von Buttons im Auftragstamm aufgerufen, haben aber noch kein HTML-Pendant:

---

## 🔴 Priorität 1: Kritisch fehlend

### 1. zfrm_Rueckmeldungen
- **Button:** `btn_Rueckmeld` (Access) / fehlt in HTML
- **Access-Code:** `DoCmd.OpenForm "zfrm_Rueckmeldungen", acNormal`
- **Funktion:** Zeigt Rückmeldungen von Mitarbeitern an
- **Status:** ❌ HTML-Formular existiert: `zfrm_Rueckmeldungen.html` ✅
- **Action Required:** Button zu Auftragstamm hinzufügen

### 2. frm_abwesenheitsuebersicht
- **Button:** `btn_VA_Abwesenheiten` (Access) / fehlt in HTML
- **Access-Code:** `DoCmd.OpenForm "frm_abwesenheitsuebersicht", acFormDS`
- **Funktion:** Zeigt Abwesenheitsübersicht aller Mitarbeiter
- **Status:** ❌ HTML-Formular existiert: `frm_abwesenheitsuebersicht.html` ✅
- **Action Required:** Button zu Auftragstamm hinzufügen

### 3. frmtop_va_auftrag_neu
- **Button:** `btn_Neuer_Auftrag2` (Access) / `btnNeuAuftrag` (HTML)
- **Access-Code:** `DoCmd.OpenForm "frmtop_va_auftrag_neu"`
- **Funktion:** Dialog zum Erstellen eines neuen Auftrags
- **Status:** ⚠️ HTML nutzt `neuerAuftrag()` Funktion
- **HTML-Code:**
  ```javascript
  async function neuerAuftrag() {
      // Erstellt direkt neuen Datensatz
      const response = await fetch('http://localhost:5000/api/auftraege', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ Auftrag: 'Neuer Auftrag' })
      });
  }
  ```
- **Action Required:** Prüfen ob Dialog-Formular benötigt wird oder direktes Erstellen ausreicht

### 4. frm_MA_Serien_eMail_Auftrag
- **Buttons:** `btnMailEins`, `btnMailPos`, `btnMailSub`, `btn_Autosend_BOS` (Access)
- **Access-Code:** `DoCmd.OpenForm "frm_MA_Serien_eMail_Auftrag"`
- **Funktion:** Serien-E-Mail-Formular für Einsatzlisten-Versand
- **Status:** ❌ HTML-Formular existiert: `frm_MA_Serien_eMail_Auftrag.html` ✅
- **HTML-Implementation:**
  - `sendeEinsatzlisteMA()` - Sendet direkt per API
  - `sendeEinsatzlisteBOS()` - Sendet direkt per API
  - `sendeEinsatzlisteSUB()` - Sendet direkt per API
- **Unterschied:** HTML ruft E-Mail-Funktionen direkt auf (kein Dialog-Formular)
- **Action Required:** ✅ Funktioniert bereits, kein Dialog nötig

### 5. frm_MA_VA_Schnellauswahl
- **Button:** `btnSchnellPlan` (Access + HTML)
- **Access-Code:** `DoCmd.OpenForm "frm_MA_VA_Schnellauswahl", , , , , , iVA_ID & " " & iVADatum_ID`
- **Funktion:** Schnellplanung - Mitarbeiter zu Schichten zuordnen
- **Status:** ✅ HTML-Formular existiert: `frm_MA_VA_Schnellauswahl.html`
- **HTML-Code:**
  ```javascript
  async function openMitarbeiterauswahl() {
      const url = `frm_MA_VA_Schnellauswahl.html?va_id=${currentVA_ID}&vadatum_id=${currentVADatum_ID}`;
      window.parent.postMessage({
          type: 'NAVIGATE',
          url: url
      }, '*');
  }
  ```
- **Action Required:** ✅ Bereits implementiert und funktioniert

### 6. zfrm_SyncError
- **Button:** `btnSyncErr` (Access) / fehlt in HTML
- **Access-Code:** `DoCmd.OpenForm "zfrm_SyncError"`
- **Funktion:** Zeigt Synchronisations-Fehler bei Zeitkonten-Import
- **Status:** ❌ HTML-Formular existiert: `zfrm_SyncError.html` ✅
- **Action Required:** Button zu Auftragstamm hinzufügen (niedrige Priorität)

---

## 🟡 Priorität 2: Wichtig

### 7. frm_KD_Kundenstamm (Add-Modus)
- **Button:** `btnNeuVeranst` (Access) / fehlt in HTML
- **Access-Code:** `DoCmd.OpenForm "frm_KD_Kundenstamm", , , , acFormAdd`
- **Funktion:** Öffnet Kundenstamm im Neuanlage-Modus für neuen Veranstalter
- **Status:** ✅ HTML-Formular existiert: `frm_KD_Kundenstamm.html`
- **Action Required:** Button hinzufügen mit URL-Parameter `?mode=add`
- **HTML-Code-Vorschlag:**
  ```javascript
  async function neuerVeranstalter() {
      window.parent.postMessage({
          type: 'NAVIGATE',
          url: 'frm_KD_Kundenstamm.html?mode=add'
      }, '*');
  }
  ```

### 8. frm_OB_Objekt (Positionen)
- **Button:** `btn_Posliste_oeffnen` (Access) / `btnPositionen` (HTML)
- **Access-Code:** `Call OpenObjektPositionenFromAuftrag`
- **Funktion:** Öffnet Objektverwaltung mit Fokus auf Positionen
- **Status:** ✅ HTML-Formular existiert: `frm_OB_Objekt.html`
- **HTML-Code:**
  ```javascript
  async function openPositionen() {
      const objektId = document.getElementById('Objekt_ID').value;
      window.parent.postMessage({
          type: 'NAVIGATE',
          url: `frm_OB_Objekt.html?id=${objektId}&tab=positionen`
      }, '*');
  }
  ```
- **Action Required:** ✅ Bereits implementiert

---

## 🟢 Priorität 3: Optional

### 9. tbl_Log_eMail_Sent (Tabelle)
- **Button:** `Befehl709` (Access) / `btnELGesendet` (HTML)
- **Access-Code:** `DoCmd.OpenTable "tbl_Log_eMail_Sent"`
- **Funktion:** Zeigt E-Mail-Log-Tabelle
- **Status:** ⚠️ HTML zeigt Log in Modal-Dialog
- **HTML-Code:**
  ```javascript
  async function showELGesendet() {
      const logs = await fetch('http://localhost:5000/api/email_log').then(r => r.json());
      // Zeigt in Modal
  }
  ```
- **Action Required:** ✅ Funktioniert, andere Darstellung als Access

### 10. Reports (PDF-Ausgabe)
- **Buttons:** `btnDruck`, `btnPDFKopf`, `btnPDFPos` (Access)
- **Access-Code:** `DoCmd.OutputTo acOutputReport, "rpt_Auftrag", "PDF", Pfad`
- **Funktion:** Generiert PDF-Reports
- **Status:** ⚠️ HTML nutzt Excel-Export statt PDF
- **Access-Reports:**
  - `rpt_Auftrag` - Vollständiger Auftragsbericht
  - `rpt_Auftrag_Zusage` - Einsatzliste/Zusage
  - `rpt_Auftrag_Kopf` - Nur Auftragskopf
  - `rpt_Auftrag_Pos` - Nur Positionen
- **HTML-Alternative:** Excel-Export via `fXL_Export_Auftrag()`
- **Action Required:** Prüfen ob PDF-Export zusätzlich benötigt wird

---

## 📊 Zusammenfassung

| Status | Anzahl | Formulare |
|--------|--------|-----------|
| ✅ HTML existiert bereits | 6 | zfrm_Rueckmeldungen, frm_abwesenheitsuebersicht, frm_MA_Serien_eMail_Auftrag, frm_MA_VA_Schnellauswahl, zfrm_SyncError, frm_KD_Kundenstamm |
| ⚠️ Andere Implementation | 2 | tbl_Log_eMail_Sent (Modal), Reports (Excel statt PDF) |
| ❌ Nicht benötigt | 1 | frmtop_va_auftrag_neu (direkte API-Erstellung) |

---

## ✅ Maßnahmenplan

### Sofort (Priorität 1):
1. **Button "Rückmeldungen" hinzufügen**
   ```javascript
   function openRueckmeldungen() {
       window.parent.postMessage({
           type: 'NAVIGATE',
           url: 'zfrm_Rueckmeldungen.html'
       }, '*');
   }
   ```

2. **Button "Abwesenheiten" hinzufügen**
   ```javascript
   function openAbwesenheitsuebersicht() {
       window.parent.postMessage({
           type: 'NAVIGATE',
           url: 'frm_abwesenheitsuebersicht.html'
       }, '*');
   }
   ```

3. **Button "Neuer Veranstalter" hinzufügen**
   ```javascript
   function neuerVeranstalter() {
       window.parent.postMessage({
           type: 'NAVIGATE',
           url: 'frm_KD_Kundenstamm.html?mode=add'
       }, '*');
   }
   ```

### Kurzfristig (Priorität 2):
4. **Sync-Error-Button hinzufügen** (niedrige Frequenz)
5. **Stundenberechnung-Funktion implementieren** (Backend-API)
6. **Sortier-Funktion hinzufügen** (Zuordnungen sortieren)

### Langfristig (Priorität 3):
7. **PDF-Export-Funktionalität prüfen** (falls Excel nicht ausreicht)
8. **Zusätzliche Navigation-Buttons** (Tag vor/zurück, Heute)

---

**Fazit:** Die meisten benötigten Formulare existieren bereits als HTML-Versionen. Hauptsächlich müssen nur noch Buttons zur Navigation hinzugefügt werden.

---

**Erstellt am:** 2026-01-15 19:30
**Erstellt von:** Claude Code (Access Bridge Ultimate)
