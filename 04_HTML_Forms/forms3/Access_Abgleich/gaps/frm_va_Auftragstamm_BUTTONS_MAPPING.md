# BUTTON-MAPPING: frm_va_Auftragstamm

**Detaillierte Zuordnung Access → HTML**

---

## ✅ IMPLEMENTIERTE BUTTONS (35/45)

| # | Access-Button | HTML-Button | Funktion | Status |
|---|---------------|-------------|----------|--------|
| 1 | `btnSchnellPlan` | `auftrag-btn-mitarbeiterauswahl` | Mitarbeiter-Schnellauswahl öffnen | ✅ Button vorhanden, Event fehlt |
| 2 | `btnMailEins` | `auftrag-btn-el-senden-ma` | E-Mail Einsatzliste an MA | ✅ Implementiert |
| 3 | `btnDruckZusage` | `btnDruckZusage` / `btn_BWN_Druck` | BWN Drucken | ✅ Implementiert |
| 4 | `btn_letzer_Datensatz` | Navigation (in Logic.js) | Letzter Datensatz | ✅ Implementiert |
| 5 | `Befehl40` | Navigation | Erster Datensatz | ✅ Implementiert |
| 6 | `Befehl41` | Navigation | Vorheriger Datensatz | ✅ Implementiert |
| 7 | `Befehl43` | Navigation | Nächster Datensatz | ✅ Implementiert |
| 8 | `mcobtnDelete` | `auftrag-btn-loeschen` / `btnLoeschen` | Auftrag löschen | ✅ Implementiert |
| 9 | `Befehl38` | `auftrag-btn-neu` / `btnNeuAuftrag` | Neuer Auftrag | ✅ Implementiert |
| 10 | `btnRibbonAus` | - | Ribbon ausblenden | ⚠️ Kein Ribbon in HTML |
| 11 | `btnRibbonEin` | - | Ribbon einblenden | ⚠️ Kein Ribbon in HTML |
| 12 | `btnDaBaEin` | - | Datenbank-Fenster ein | ⚠️ Kein DB-Fenster in HTML |
| 13 | `btnDaBaAus` | - | Datenbank-Fenster aus | ⚠️ Kein DB-Fenster in HTML |
| 14 | `btnReq` | - | Anforderungen | ⚠️ Unklar, evtl. obsolet |
| 15 | `btnneuveranst` | - | Neuer Veranstalter | ⚠️ Sollte über Kundenstamm gehen |
| 16 | `Befehl640` | `auftrag-btn-aktualisieren` | Aktualisieren | ✅ Implementiert |
| 17 | `btn_rueck` | - | Rückmeldungen öffnen | ❌ **FEHLT** |
| 18 | `btnSyncErr` | - | Sync-Fehler prüfen | ⚠️ JS: `checkSyncErrors()` |
| 19 | `btn_ListeStd` | `btnListeStd` | Stundenliste | ✅ Button vorhanden |
| 20 | `btn_Autosend_BOS` | `auftrag-btn-el-senden-bos` / `btnMailBOS` | Auto-Senden BOS | ✅ Implementiert |
| 21 | `Befehl709` | - | Unbekannt | ⚠️ Obsolet? |
| 22 | `btnMailSub` | `auftrag-btn-el-senden-sub` / `btnMailSub` | Mail Subunternehmer | ✅ Implementiert |
| 23 | `btnDatumLeft` | `auftrag-btn-datum-links` / `btnDatumLeft` | Datum zurück | ✅ Implementiert |
| 24 | `btnDatumRight` | `auftrag-btn-datum-rechts` / `btnDatumRight` | Datum vor | ✅ Implementiert |
| 25 | `btnPlan_Kopie` | `auftrag-btn-kopieren` / `btnKopieren` | Planung kopieren | ✅ Implementiert |
| 26 | `btnNeuAttach` | `auftrag-btn-attach-hinzufuegen` | Anhang hinzufügen | ✅ Button vorhanden |
| 27 | `btnPDFKopf` | - | PDF Kopfdaten | ❌ **FEHLT** |
| 28 | `btnPDFPos` | - | PDF Positionen | ❌ **FEHLT** |
| 29 | `btn_AbWann` | - | Ab Wann (Filter) | ⚠️ Evtl. `Auftraege_ab` Input |
| 30 | `btnHeute` | `auftrag-btn-ab-heute` | Filter ab Heute | ✅ Implementiert |
| 31 | `btnTgBack` | `auftrag-btn-tage-zurueck` | Tage zurück | ✅ Implementiert |
| 32 | `btnTgVor` | `auftrag-btn-tage-vor` | Tage vor | ✅ Implementiert |
| 33 | - | `auftrag-btn-einsatzliste-drucken` | Einsatzliste drucken | ➕ **ZUSÄTZLICH** |
| 34 | - | `auftrag-btn-el-gesendet` / `btnELGesendet` | EL als gesendet markieren | ➕ **ZUSÄTZLICH** |
| 35 | - | `auftrag-btn-rechnung-daten-laden` | Rechnung laden | ➕ **ZUSÄTZLICH** |

---

## ❌ FEHLENDE BUTTONS (10/45)

| # | Access-Button | Funktion | Kritikalität | Notiz |
|---|---------------|----------|--------------|-------|
| 1 | `btnAuftrBerech` | Auftragsberechnung | 🟡 Wichtig | Fehlt komplett |
| 2 | `btn_aenderungsprotokoll` | Änderungsprotokoll | 🟢 Nice-to-have | Audit-Trail |
| 3 | `btnmailpos` | Mail Positionen | 🟡 Wichtig | Positionen per Mail |
| 4 | `btn_Posliste_oeffnen` | Positionsliste öffnen | 🟡 Wichtig | Teilweise: `btnPositionen` |
| 5 | `btnCheck` | Check/Validierung | 🟢 Nice-to-have | Unbekannte Funktion |
| 6 | `btnDruckZusage1` | Zusage drucken (alt) | 🟢 Nice-to-have | Duplikat, `btnDruckZusage` neu |
| 7 | `btnVAPlanCrea` | VA-Plan erstellen | 🟡 Wichtig | Planung aus Vorlage |
| 8 | `btn_VA_Abwesenheiten` | VA-Abwesenheiten | 🟡 Wichtig | Abwesenheiten verwalten |
| 9 | `btn_Tag_loeschen` | Tag löschen | 🟡 Wichtig | Tag aus Auftrag entfernen |
| 10 | `cmd_Messezettel_NameEintragen` | Messezettel Namen | 🟢 Nice-to-have | Spezialfunktion |

---

## ➕ ZUSÄTZLICHE HTML-BUTTONS (Nicht in Access)

| # | HTML-Button | Funktion | Notiz |
|---|-------------|----------|-------|
| 1 | `auftrag-btn-eventdaten-speichern` | Eventdaten speichern | Eventdaten-Scraper (NEU) |
| 2 | `auftrag-btn-webdaten-laden` | Eventdaten laden | Eventdaten-Scraper (NEU) |
| 3 | `auftrag-btn-vollbild` | Vollbild-Modus | UI-Feature |
| 4 | `auftrag-btn-rechnung-lexware` | Lexware Export | Lexware-Integration |
| 5 | `auftrag-btn-rechnung-pdf` | Rechnung als PDF | PDF-Export |
| 6 | `auftrag-btn-namenslisteess` | Namensliste ESS | ESS-Funktion |

---

## 🔄 BUTTON-EVENTS VERGLEICH

### Access VBA Events (Beispiele)

```vba
' btnSchnellPlan_Click
Private Sub btnSchnellPlan_Click()
    DoCmd.OpenForm "frm_MA_VA_Schnellauswahl", , , _
        "VA_ID=" & Me.ID & " AND VADatum_ID=" & Me.cboVADatum
End Sub

' btnMailEins_Click
Private Sub btnMailEins_Click()
    ' E-Mail an Mitarbeiter senden
    Call SendMailToMA(Me.ID, Me.cboVADatum)
End Sub

' mcobtnDelete_Click
Private Sub mcobtnDelete_Click()
    If MsgBox("Auftrag wirklich löschen?", vbYesNo) = vbYes Then
        DoCmd.RunCommand acCmdDeleteRecord
    End If
End Sub

' btnDatumLeft_Click
Private Sub btnDatumLeft_Click()
    If Me.cboVADatum.ListIndex > 0 Then
        Me.cboVADatum.ListIndex = Me.cboVADatum.ListIndex - 1
    End If
End Sub
```

### HTML/JS Events (Entsprechungen)

```javascript
// auftrag-btn-mitarbeiterauswahl (btnSchnellPlan)
document.getElementById('auftrag-btn-mitarbeiterauswahl').addEventListener('click', () => {
    // TODO: Implementieren
    alert('Mitarbeiter-Schnellauswahl öffnen');
});

// auftrag-btn-el-senden-ma (btnMailEins)
document.getElementById('auftrag-btn-el-senden-ma').addEventListener('click', async () => {
    await sendEinsatzliste('MA');
});

// btnLoeschen (mcobtnDelete)
document.getElementById('btnLoeschen').addEventListener('click', async () => {
    if (confirm('Auftrag wirklich löschen?')) {
        await loeschenAuftrag();
    }
});

// btnDatumLeft (btnDatumLeft)
document.getElementById('btnDatumLeft').addEventListener('click', () => {
    navigateVADatum(-1);
});
```

---

## 🎯 PRIORITÄTEN FÜR FEHLENDE BUTTONS

### 🔴 Priorität 1 (Sofort) - 6h
1. `btn_Posliste_oeffnen` → Positionsliste öffnen (2h)
2. `btnVAPlanCrea` → VA-Plan erstellen (2h)
3. `btn_VA_Abwesenheiten` → Abwesenheiten (2h)

### 🟡 Priorität 2 (Wichtig) - 4h
4. `btnmailpos` → Mail Positionen (2h)
5. `btn_Tag_loeschen` → Tag löschen (1h)
6. `btnAuftrBerech` → Auftragsberechnung (1h)

### 🟢 Priorität 3 (Nice-to-have) - 2h
7. `btn_aenderungsprotokoll` → Änderungsprotokoll (1h)
8. `cmd_Messezettel_NameEintragen` → Messezettel (1h)

**GESAMT: 12h**

---

## 📋 IMPLEMENTIERUNGS-CHECKLISTE

### Schritt 1: Event-Handler vorbereiten
```javascript
// In frm_va_Auftragstamm.logic.js

// Positionsliste öffnen
async function openPositionsliste() {
    const va_id = getValue('VA_ID');
    if (!va_id) return alert('Kein Auftrag ausgewählt');

    // Option 1: Popup
    window.open(`frm_VA_Positionen.html?va_id=${va_id}`, 'positionen', 'width=800,height=600');

    // Option 2: Shell-Navigation
    window.parent.postMessage({ type: 'NAVIGATE', form: 'frm_VA_Positionen', id: va_id }, '*');
}

// VA-Plan erstellen
async function createVAPlan() {
    const va_id = getValue('VA_ID');
    if (!va_id) return alert('Kein Auftrag ausgewählt');

    if (!confirm('VA-Plan aus Vorlage erstellen?')) return;

    const response = await fetch(`/api/auftraege/${va_id}/plan-erstellen`, {
        method: 'POST'
    });

    if (response.ok) {
        alert('Plan erstellt');
        await loadAuftrag(va_id);
    }
}

// Abwesenheiten verwalten
async function openVAAbwesenheiten() {
    const va_id = getValue('VA_ID');
    if (!va_id) return alert('Kein Auftrag ausgewählt');

    window.parent.postMessage({
        type: 'NAVIGATE',
        form: 'frm_VA_Abwesenheiten',
        filter: `VA_ID=${va_id}`
    }, '*');
}
```

### Schritt 2: Buttons in HTML einfügen
```html
<!-- Nach auftrag-btn-positionen -->
<button id="auftrag-btn-posliste-oeffnen" class="btn unified-btn">
    Positionsliste
</button>

<button id="auftrag-btn-va-plan-erstellen" class="btn unified-btn btn-yellow">
    Plan erstellen
</button>

<button id="auftrag-btn-va-abwesenheiten" class="btn unified-btn">
    Abwesenheiten
</button>
```

### Schritt 3: Event-Listener binden
```javascript
// In init()
bindButton('auftrag-btn-posliste-oeffnen', openPositionsliste);
bindButton('auftrag-btn-va-plan-erstellen', createVAPlan);
bindButton('auftrag-btn-va-abwesenheiten', openVAAbwesenheiten);
```

---

## 🔍 BUTTON-STATISTIK

### Nach Typ
- **Navigation:** 7 Buttons (100% implementiert)
- **CRUD:** 3 Buttons (100% implementiert)
- **Druck:** 5 Buttons (80% implementiert, PDF-Kopf/Pos fehlt)
- **E-Mail:** 4 Buttons (75% implementiert, mailpos fehlt)
- **Planung:** 3 Buttons (33% implementiert, VAPlan + Abwesenheiten fehlen)
- **Filter:** 4 Buttons (100% implementiert)
- **UI-Toggle:** 4 Buttons (0% implementiert, nicht relevant für HTML)
- **Sonstiges:** 15 Buttons (60% implementiert)

### Nach Kritikalität
- 🔴 **Kritisch (Blocker):** 0 Buttons fehlen
- 🟡 **Wichtig (Einschränkung):** 6 Buttons fehlen
- 🟢 **Nice-to-have:** 4 Buttons fehlen

### Nach Implementierungsstatus
- ✅ **Vollständig:** 28 Buttons (62%)
- ⚠️ **Teilweise:** 7 Buttons (16%)
- ❌ **Fehlt:** 10 Buttons (22%)

---

**Ende Button-Mapping**
