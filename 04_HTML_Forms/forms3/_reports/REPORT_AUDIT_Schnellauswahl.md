# Funktionalitätsprüfung: frm_MA_VA_Schnellauswahl.html

**Datum:** 2026-01-03
**Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_MA_VA_Schnellauswahl.html`
**Logic-Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\logic\frm_MA_VA_Schnellauswahl.logic.js`

---

## ZUSAMMENFASSUNG

Das Formular "Mitarbeiterauswahl - Offene Mail Anfragen" ist für die schnelle Zuordnung von Mitarbeitern zu Aufträgen/Schichten konzipiert. Es gibt **zwei verschiedene Implementierungen**:

1. **Inline-Script** (direkt im HTML, Zeilen 563-955)
2. **Externe Logic-Datei** (frm_MA_VA_Schnellauswahl.logic.js)

**KRITISCHES PROBLEM:** Die beiden Implementierungen sind **NICHT identisch**. Das inline Script verwendet die alte `Bridge.loadData()` API, während die externe Logic-Datei die moderne `Bridge.execute()` und `Bridge.mitarbeiter.list()` API verwendet.

---

## 1. DATUMS-AUSWAHL (KRITISCH!)

### HTML-Struktur
```html
<!-- Auftrag Dropdown -->
<select id="VA_ID" class="form-select">
    <option value="">-- Auftrag wählen --</option>
</select>

<!-- Datum Dropdown -->
<select id="cboVADatum" class="form-select">
    <option value="">-- Datum --</option>
</select>
```

### Event-Handler (Inline-Script)

| Event | Element | Handler | Aktion |
|-------|---------|---------|--------|
| `change` | `#VA_ID` | `handleAuftragChange(vaId)` | Lädt Auftrag + Einsatztage |
| `change` | `#cboVADatum` | `handleDatumChange(vaDatumId)` | Lädt Schichten, MA, Geplant/Zugesagt |

### Event-Handler (Logic-Datei)

| Event | Element | Handler | Aktion |
|-------|---------|---------|--------|
| `change` | `#cboAuftrag` | `state.selectedAuftrag = value; loadSchichten()` | Lädt nur Schichten |
| `change` | `#datEinsatz` | `state.selectedDatum = value; loadMitarbeiter()` | Lädt nur Mitarbeiter |

**PROBLEM:** Die Element-IDs sind **inkonsistent**!
- Inline: `VA_ID` / `cboVADatum`
- Logic: `cboAuftrag` / `datEinsatz`

### Datenfluss bei Datumsänderung (Inline-Script)

```
1. User wählt Auftrag (VA_ID)
   ↓
2. handleAuftragChange(vaId)
   ↓
3. Bridge.loadData('auftrag', vaId)  → Zeile 660
   ↓
4. Bridge.loadData('einsatztage', null, { va_id: vaId })  → Zeile 661
   ↓
5. Bridge.on('onEinsatztageReceived') → Befüllt cboVADatum  → Zeilen 670-675
   ↓
6. User wählt Datum (cboVADatum)
   ↓
7. handleDatumChange(vaDatumId)
   ↓
8. loadSchichten()    → Bridge.loadData('schichten', ...) → Zeile 687
9. loadMitarbeiter()  → Bridge.loadData('mitarbeiter', ...) → Zeile 698
10. loadGeplantZugesagt() → Bridge.loadData('zuordnungen', ...) → Zeile 707
```

**BEWERTUNG DATUMS-AUSWAHL:**
- ✅ onChange-Events vorhanden
- ✅ Alle relevanten Daten werden nachgeladen
- ❌ Kein Kalender-Widget (nur Dropdown)
- ❌ Inkonsistente Element-IDs zwischen Inline/Logic
- ❌ Logic-Datei wird NICHT geladen (kein `<script src="...">`)

---

## 2. AUFTRAGS-/SCHICHT-AUSWAHL

### Schichten-Liste (Zeilen 470-487)

```html
<div class="list-panel narrow">
    <span class="form-label">Dienstbeginn auswählen:</span>
    <div class="grid-wrapper">
        <div class="listbox-header">
            <span>Ist</span>
            <span>Soll</span>
            <span>Beginn</span>
            <span>Ende</span>
        </div>
        <div id="lstZeiten_Body"></div>
    </div>
</div>
```

### Render-Funktion (Zeilen 722-747)

```javascript
function renderZeitenListe() {
    const container = document.getElementById('lstZeiten_Body');

    container.innerHTML = state.zeiten.map((z, i) => `
        <div class="listbox-row ${state.selectedZeit === i ? 'selected' : ''}" data-idx="${i}">
            <span>${z.MA_Anzahl_Ist || 0}</span>
            <span>${z.MA_Anzahl || 0}</span>
            <span>${formatTime(z.VA_Start)}</span>
            <span>${formatTime(z.VA_Ende)}</span>
        </div>
    `).join('');

    // Click-Handler für Schichtauswahl
    container.querySelectorAll('.listbox-row').forEach(row => {
        row.addEventListener('click', () => {
            state.selectedZeit = parseInt(row.dataset.idx);
            // ...
        });
    });
}
```

**BEWERTUNG AUFTRAGS-/SCHICHT-AUSWAHL:**
- ✅ Liste wird nach Datum gefiltert (über va_id Parameter)
- ✅ Schicht-Auswahl aktualisiert Dienstende-Feld
- ⚠️ MA-Listen werden NICHT automatisch bei Schichtauswahl aktualisiert
- ✅ Gesamt-MA-Anzahl wird berechnet (Zeile 693)

---

## 3. MITARBEITER-LISTEN

### Verfügbar-Liste (Zeilen 489-514)

```html
<div class="list-panel wide">
    <span class="form-label">Mitarbeiterauswahl durch Doppelklick</span>
    <div class="grid-wrapper">
        <div class="listbox-header">
            <span>Name</span>
            <span>Std</span>
            <span>Beginn</span>
            <span>Ende</span>
            <span>Grund</span>
        </div>
        <div id="List_MA_Body"></div>
    </div>
</div>
```

### Filter-Optionen (Zeilen 433-465)

| Filter | Element | Funktion |
|--------|---------|----------|
| Nur Aktive | `#IstAktiv` (checked) | Filtert inaktive MA aus |
| Nur Freie | `#IstVerfuegbar` | Zeigt nur verfügbare MA |
| Nur 34a | `#cbNur34a` | Nur MA mit 34a-Qualifikation |
| Anstellungsart | `#cboAnstArt` | Festangestellt (3) / Aushilfe (5) |
| Kategorie | `#cboQuali` | Qualifikations-Filter |
| Schnellsuche | `#strSchnellSuche` | Namens-Suche |

### Render-Funktion (Zeilen 749-806)

```javascript
function renderMAListe() {
    const nurAktive = document.getElementById('IstAktiv').checked;
    const nurFreie = document.getElementById('IstVerfuegbar').checked;
    const nur34a = document.getElementById('cbNur34a').checked;
    const anst = document.getElementById('cboAnstArt').value;
    const suche = document.getElementById('strSchnellSuche').value.toLowerCase();

    let filtered = state.mitarbeiter.filter(ma => {
        if (nurAktive && !ma.IstAktiv) return false;
        if (nur34a && !ma.Hat34a) return false;
        if (anst && ma.Anstellungsart_ID != anst) return false;
        if (suche && !`${ma.Nachname} ${ma.Vorname}`.toLowerCase().includes(suche)) return false;
        return true;
    });

    container.innerHTML = filtered.map(ma => {
        const isGeplant = state.geplant.some(g => g.MA_ID === ma.ID);
        const isZugesagt = state.zugesagt.some(z => z.MA_ID === ma.ID);
        const cls = isZugesagt ? 'zugesagt' : (isGeplant ? 'geplant' : '');

        return `<div class="listbox-row ${cls}" data-id="${ma.ID}">...</div>`;
    }).join('');
}
```

**BEWERTUNG MITARBEITER-LISTEN:**
- ✅ Verfügbar-Liste funktioniert
- ✅ Filter funktionieren (Aktiv, 34a, Anstellung, Suche)
- ✅ Farbcodierung: Geplant (gelb), Zugesagt (grün)
- ❌ "Nur freie anzeigen" wird NICHT implementiert (nurFreie wird nicht verwendet!)
- ✅ Click-Handler für Auswahl
- ✅ Doppelklick für direkte Zuordnung (Zeile 802-804)

---

## 4. ZUORDNUNGS-FUNKTIONEN

### Zuordnungs-Buttons (Zeilen 517-521)

```html
<button class="btn" id="btnAddSelected" title="Ausgewählte MA zur Planung hinzufügen">→</button>
<button class="btn" id="btnDelSelected" title="Ausgewählte MA aus Planung entfernen">←</button>
<button class="btn" id="btnDelAll" title="Alle aus Planung entfernen">✕</button>
```

### Event-Handler (Zeilen 624-625)

```javascript
document.getElementById('btnAddSelected').addEventListener('click', addSelectedToGeplant);
document.getElementById('btnDelSelected').addEventListener('click', removeSelectedFromGeplant);
```

### Zuordnen-Funktion (Zeilen 841-851)

```javascript
async function addSelectedToGeplant() {
    if (!state.selectedMAs.size) { alert('Bitte Mitarbeiter auswählen'); return; }
    if (!state.selectedVA || !state.selectedVADatum) { alert('Bitte Auftrag und Datum wählen'); return; }

    for (const maId of state.selectedMAs) {
        await addMAToGeplant(maId);
    }
    state.selectedMAs.clear();
    await loadGeplantZugesagt();
    renderMAListe();
}
```

### Persistierung (Zeilen 853-864)

```javascript
async function addMAToGeplant(maId) {
    Bridge.sendEvent('save', {
        type: 'zuordnung',
        action: 'create',
        data: {
            ma_id: maId,
            va_id: state.selectedVA,
            vadatum_id: state.selectedVADatum,
            vastart_id: state.zeiten[state.selectedZeit]?.ID
        }
    });
}
```

### Entfernen-Funktion (Zeilen 866-885)

```javascript
async function removeSelectedFromGeplant() {
    if (!state.selectedMAs.size) { alert('Bitte Mitarbeiter auswählen'); return; }

    const ids = Array.from(state.selectedMAs);
    const toDelete = state.geplant.filter(g => ids.includes(g.MA_ID)).map(g => g.ID);

    if (!toDelete.length) { alert('Keine geplanten Zuordnungen gefunden'); return; }
    if (!confirm(`${toDelete.length} Zuordnung(en) loeschen?`)) return;

    for (const id of toDelete) {
        Bridge.sendEvent('delete', { type: 'zuordnung', id: id });
    }

    state.selectedMAs.clear();
    await loadGeplantZugesagt();
    renderMAListe();
}
```

**BEWERTUNG ZUORDNUNGS-FUNKTIONEN:**
- ✅ Button "Zuordnen" (→) funktioniert
- ✅ Button "Entfernen" (←) funktioniert
- ❌ Button "Alle entfernen" (✕) NICHT implementiert (kein Event-Listener)
- ✅ Mehrfachauswahl möglich (Set-basiert)
- ✅ Bridge.sendEvent() für Persistierung
- ✅ Bestätigungsdialog vor Löschen
- ✅ Automatisches Nachladen nach Änderungen

---

## 5. SCHNELL-AKTIONEN

### Mail-Buttons (Zeilen 426, 440)

```html
<button class="btn btn-green" id="btnMailSelected">Nur Selektierte anfragen</button>
<button class="btn btn-green" id="btnMail">Alle Mitarbeiter anfragen</button>
```

### Event-Handler (Zeilen 630-631)

```javascript
document.getElementById('btnMail').addEventListener('click', () => versendeAnfragen(true));
document.getElementById('btnMailSelected').addEventListener('click', () => versendeAnfragen(false));
```

### Anfragen-Versand (Zeilen 887-918)

```javascript
async function versendeAnfragen(alle) {
    if (!state.selectedVA || !state.selectedVADatum) {
        alert('Bitte Auftrag und Datum auswaehlen');
        return;
    }

    const maIds = alle
        ? state.filteredMitarbeiter.map(m => m.ID || m.MA_ID).filter(Boolean)
        : Array.from(state.selectedMAs);

    if (!maIds.length) { alert('Keine Mitarbeiter ausgewaehlt'); return; }
    if (!confirm(`${maIds.length} Mitarbeiter anfragen?`)) { return; }

    const vaStartId = state.zeiten[state.selectedZeit]?.ID || null;

    // Backend-Event senden
    Bridge.sendEvent('anfragen_versenden', {
        ma_ids: maIds,
        va_id: state.selectedVA,
        vadatum_id: state.selectedVADatum,
        vastart_id: vaStartId
    });

    // mailto-Link öffnen
    const subject = encodeURIComponent(`Anfrage Auftrag ${state.selectedVA}`);
    const body = encodeURIComponent(`Anfrage fuer Auftrag ${state.selectedVA}`);
    window.open(`mailto:siegert@consec-nuernberg.de?subject=${subject}&body=${body}`);
}
```

### Weitere Buttons (Zeilen 408-410)

```html
<button class="btn" id="btnAuftrag">Zurück zum Auftrag</button>
<button class="btn" id="btnPosListe">Positionsliste</button>
<button class="btn" id="btnZuAbsage">Manuelles Bearbeiten</button>
```

**BEWERTUNG SCHNELL-AKTIONEN:**
- ✅ "Alle anfragen" funktioniert
- ✅ "Nur Selektierte anfragen" funktioniert
- ✅ Bestätigungsdialog mit Anzahl
- ✅ Backend-Event + mailto-Link
- ⚠️ "Zurück zum Auftrag" navigiert zu frm_va_Auftragstamm.html
- ❌ "Positionsliste" NICHT implementiert
- ❌ "Manuelles Bearbeiten" NICHT implementiert
- ❌ Sortier-Buttons (btnSortPLan, btnSortZugeord) NICHT implementiert
- ❌ Standard/Entfernung-Buttons (cmdListMA_Standard, cmdListMA_Entfernung) NICHT implementiert

---

## 6. ECHTZEIT-UPDATES

### Nach Zuordnung

```javascript
async function addSelectedToGeplant() {
    // ... Zuordnung ...

    await loadGeplantZugesagt();  // Lädt geplante/zugesagte MA
    renderMAListe();              // Aktualisiert MA-Liste (Farbcodierung)
}
```

### Nach Löschung

```javascript
async function removeSelectedFromGeplant() {
    // ... Löschung ...

    await loadGeplantZugesagt();
    renderMAListe();
}
```

### MA Soll vs. Ist

```javascript
Bridge.on('onSchichtenReceived', function(data) {
    state.zeiten = data.schichten || [];
    renderZeitenListe();

    const gesamt = state.zeiten.reduce((s, z) => s + (z.MA_Anzahl || 0), 0);
    document.getElementById('iGes_MA').value = gesamt;  // Zeile 694
});
```

**BEWERTUNG ECHTZEIT-UPDATES:**
- ✅ Ansicht wird nach Zuordnung aktualisiert
- ✅ MA Soll wird angezeigt (iGes_MA)
- ⚠️ MA Ist wird in Schichtliste angezeigt, aber NICHT als Gesamt-Summe
- ✅ Farbcodierung: Geplant (gelb), Zugesagt (grün)
- ❌ KEINE Farbcodierung für Unter-/Überbesetzung
- ❌ KEINE automatische Aktualisierung (kein Polling/WebSocket)

---

## 7. SUBFORMULARE

### Suche nach iframes

```bash
grep -n "iframe" frm_MA_VA_Schnellauswahl.html
# Ergebnis: KEINE Treffer
```

**BEWERTUNG SUBFORMULARE:**
- ❌ KEINE Subformulare vorhanden
- ❌ KEINE iframe-Kommunikation
- ℹ️ Alles ist in einem einzigen Formular implementiert

---

## 8. DATEN-LADEN BEI EVENTS (SEQUENZ)

### Event-Kette (Inline-Script)

```
┌─────────────────────────────────────────────────────────────┐
│  1. USER WÄHLT AUFTRAG (VA_ID)                               │
└───────────────────────┬─────────────────────────────────────┘
                        ↓
        handleAuftragChange(vaId)  [Zeile 656]
                        ↓
    ┌───────────────────┴───────────────────┐
    │  Bridge.loadData('auftrag', vaId)     │  [Zeile 660]
    │  Bridge.loadData('einsatztage', ...)  │  [Zeile 661]
    └───────────────────┬───────────────────┘
                        ↓
    ┌───────────────────┴───────────────────┐
    │  onAuftragReceived                    │  [Zeile 664]
    │    → Zeigt Auftragsinfo in lbAuftrag  │
    │  onEinsatztageReceived                │  [Zeile 670]
    │    → Befüllt cboVADatum Dropdown      │
    └───────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  2. USER WÄHLT DATUM (cboVADatum)                            │
└───────────────────────┬─────────────────────────────────────┘
                        ↓
        handleDatumChange(vaDatumId)  [Zeile 677]
                        ↓
    ┌───────────────────┴───────────────────┐
    │  loadSchichten()                      │  [Zeile 681]
    │  loadMitarbeiter()                    │  [Zeile 682]
    │  loadGeplantZugesagt()                │  [Zeile 683]
    └───────────────────┬───────────────────┘
                        ↓
    ┌───────────────────┴───────────────────┐
    │  Bridge.loadData('schichten', ...)    │  [Zeile 687]
    │  Bridge.loadData('mitarbeiter', ...)  │  [Zeile 698]
    │  Bridge.loadData('zuordnungen', ...)  │  [Zeile 707]
    └───────────────────┬───────────────────┘
                        ↓
    ┌───────────────────┴───────────────────┐
    │  onSchichtenReceived                  │  [Zeile 690]
    │    → renderZeitenListe()              │
    │    → Berechnet Gesamt MA-Anzahl       │
    │  onMitarbeiterReceived                │  [Zeile 701]
    │    → renderMAListe()                  │
    │  onZuordnungenReceived                │  [Zeile 710]
    │    → renderGeplantListe()             │
    │    → renderZugesagtListe()            │
    └───────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  3. USER WÄHLT SCHICHT (lstZeiten_Body click)                │
└───────────────────────┬─────────────────────────────────────┘
                        ↓
    ┌───────────────────┴───────────────────┐
    │  state.selectedZeit = index           │  [Zeile 741]
    │  Zeigt Dienstende im Feld             │  [Zeile 744]
    └───────────────────────────────────────┘
```

### Bridge-Events (Übersicht)

| Event-Typ | Parameter | Ziel-Handler | Aktion |
|-----------|-----------|--------------|--------|
| `loadData('auftraege')` | `{ ab_datum, limit }` | `onAuftraegeReceived` | Befüllt VA_ID Dropdown |
| `loadData('auftrag')` | `vaId` | `onAuftragReceived` | Zeigt Auftragsinfo |
| `loadData('einsatztage')` | `{ va_id }` | `onEinsatztageReceived` | Befüllt cboVADatum |
| `loadData('schichten')` | `{ va_id }` | `onSchichtenReceived` | Zeigt Schichten-Liste |
| `loadData('mitarbeiter')` | `{ aktiv }` | `onMitarbeiterReceived` | Zeigt MA-Liste |
| `loadData('zuordnungen')` | `{ va_id }` | `onZuordnungenReceived` | Zeigt Geplant/Zugesagt |
| `sendEvent('save')` | `{ type: 'zuordnung', data }` | Backend | Erstellt Zuordnung |
| `sendEvent('delete')` | `{ type: 'zuordnung', id }` | Backend | Löscht Zuordnung |
| `sendEvent('anfragen_versenden')` | `{ ma_ids, va_id, ... }` | Backend | Erstellt Anfragen |

**BEWERTUNG DATEN-LADEN:**
- ✅ Jeder Schritt löst korrekte Bridge-Events aus
- ✅ Event-Handler sind registriert (Bridge.on)
- ✅ Daten werden korrekt in state gespeichert
- ✅ Render-Funktionen werden aufgerufen
- ⚠️ KEINE automatische Aktualisierung bei Schicht-Auswahl

---

## 9. VERGLEICH MIT ACCESS VBA (FEHLT)

**PROBLEM:** Es wurde KEIN Original-VBA-Modul für dieses Formular gefunden.

Mögliche Dateinamen:
- `frm_MA_VA_Schnellauswahl.bas`
- `frm_MA_Offene_Anfragen.bas`

**EMPFEHLUNG:** Original-VBA prüfen für:
- Event-Reihenfolge
- Verfügbarkeitsprüfung-Logik
- Mail-Versand-Logik
- Sortier-Algorithmen

---

## 10. TABELLEN-STRUKTUR

### Verwendete Tabellen (aus Bridge-Events erkennbar)

| Tabelle | Verwendung | Bridge-Event |
|---------|------------|--------------|
| `tbl_VA_Auftragstamm` | Auftrags-Liste | `loadData('auftraege')` |
| `tbl_VA_AnzTage` | Einsatztage | `loadData('einsatztage')` |
| `tbl_VA_Start` | Schichten | `loadData('schichten')` |
| `tbl_MA_Mitarbeiterstamm` | Mitarbeiter | `loadData('mitarbeiter')` |
| `tbl_MA_VA_Planung` | Zuordnungen | `loadData('zuordnungen')` |
| `tbl_MA_NVerfuegZeiten` | Verfügbarkeit (implizit) | - |

---

## 11. KRITISCHE PROBLEME (ZUSAMMENFASSUNG)

### 🔴 KRITISCH

1. **Doppelte Implementierung**
   - Inline-Script im HTML (alt)
   - Externe Logic-Datei (neu, modern)
   - Logic-Datei wird NICHT geladen (kein `<script src="...">`)

2. **Inkonsistente Element-IDs**
   - Inline: `VA_ID`, `cboVADatum`, `List_MA_Body`
   - Logic: `cboAuftrag`, `datEinsatz`, `maList`
   - Nur eine kann funktionieren!

3. **Fehlende Filter-Implementierung**
   - `IstVerfuegbar` Checkbox wird gelesen, aber NICHT verwendet
   - Verfügbarkeitsprüfung fehlt komplett (im Inline-Script)

### 🟡 WICHTIG

4. **Fehlende Button-Funktionen**
   - btnDelAll (Alle entfernen)
   - btnPosListe
   - btnZuAbsage
   - btnSortPLan
   - btnSortZugeord
   - cmdListMA_Standard
   - cmdListMA_Entfernung

5. **Keine Unter-/Überbesetzung-Warnung**
   - MA Soll vs. Ist wird angezeigt, aber KEINE Farbcodierung
   - Keine Warnung bei zu wenig MA

6. **Kein Datum-Picker**
   - Nur Dropdown für Einsatztage
   - Kein freies Datum wählbar

### 🟢 MINOR

7. **Keine Auto-Aktualisierung**
   - Manuelle Refresh nötig
   - Kein Polling/WebSocket

8. **Hardcoded Test-Email**
   - `siegert@consec-nuernberg.de` hardcoded
   - Sollte aus MA-Daten kommen

---

## 12. FUNKTIONS-ÜBERSICHT (ALLE BUTTONS)

### Navigation
| Button | ID | Implementiert | Funktion |
|--------|----|--------------:|----------|
| Zurück zum Auftrag | `btnAuftrag` | ✅ | → frm_va_Auftragstamm.html?id={va_id} |
| Positionsliste | `btnPosListe` | ❌ | - |
| Manuelles Bearbeiten | `btnZuAbsage` | ❌ | - |
| Hilfe | `btnHilfe` | ❌ | - |
| Schließen | `btnClose` | ✅ | window.close() |
| Vollbild | `fullscreenBtn` | ✅ | toggleFullscreen() |

### Filter
| Button/Feld | ID | Implementiert | Funktion |
|-------------|----|--------------:|----------|
| Auftrag Dropdown | `VA_ID` | ✅ | Lädt Einsatztage |
| Datum Dropdown | `cboVADatum` | ✅ | Lädt Schichten, MA, Zuordnungen |
| Auftrags-Status | `cboAuftrStatus` | ❌ | - |
| geplant = verfügbar | `cbVerplantVerfuegbar` | ❌ | - |
| Nur freie anzeigen | `IstVerfuegbar` | ❌ | (gelesen, nicht verwendet) |
| Nur aktive anzeigen | `IstAktiv` | ✅ | Filtert MA-Liste |
| Anstellung | `cboAnstArt` | ✅ | Filtert nach Festangestellt/Aushilfe |
| Kategorie | `cboQuali` | ⚠️ | (Dropdown leer) |
| Nur 34a | `cbNur34a` | ✅ | Filtert MA-Liste |
| Schnellsuche | `strSchnellSuche` | ✅ | Namens-Suche |
| GO | `btnSchnellGo` | ✅ | Löst Suche aus |

### Zuordnung
| Button | ID | Implementiert | Funktion |
|--------|----|--------------:|----------|
| → (MA hinzufügen) | `btnAddSelected` | ✅ | Fügt ausgewählte MA zu Planung |
| ← (MA entfernen) | `btnDelSelected` | ✅ | Entfernt MA aus Planung |
| ✕ (Alle entfernen) | `btnDelAll` | ❌ | - |
| → (Zu Zusage) | `btnAddZusage` | ❌ | - |
| ← (Von Zusage) | `btnMoveZusage` | ❌ | - |
| ✕ (Zusage entfernen) | `btnDelZusage` | ❌ | - |

### Sortierung
| Button | ID | Implementiert | Funktion |
|--------|----|--------------:|----------|
| Sortieren (Planung) | `btnSortPLan` | ❌ | - |
| Sortieren (Zusage) | `btnSortZugeord` | ❌ | - |
| Standard | `cmdListMA_Standard` | ❌ | - |
| Entfernung | `cmdListMA_Entfernung` | ❌ | - |

### Anfragen
| Button | ID | Implementiert | Funktion |
|--------|----|--------------:|----------|
| Alle anfragen | `btnMail` | ✅ | Sendet Anfragen an alle MA |
| Nur Selektierte anfragen | `btnMailSelected` | ✅ | Sendet Anfragen an ausgewählte MA |

**STATISTIK:**
- ✅ Implementiert: 14 / 33 (42%)
- ❌ Nicht implementiert: 16 / 33 (48%)
- ⚠️ Teilweise: 3 / 33 (9%)

---

## 13. EMPFEHLUNGEN

### SOFORT (KRITISCH)

1. **Entscheidung treffen:**
   - Inline-Script ODER Logic-Datei verwenden
   - Empfehlung: Logic-Datei (moderner, wartbarer)
   - Action: Inline-Script entfernen, Logic-Datei einbinden

2. **Element-IDs synchronisieren:**
   - Alle IDs im HTML an Logic-Datei anpassen
   - ODER: Logic-Datei an HTML-IDs anpassen

3. **Verfügbarkeits-Filter implementieren:**
   ```javascript
   if (nurFreie && ma.isVerfuegbar === false) return false;
   ```

### KURZFRISTIG

4. **Fehlende Buttons implementieren:**
   - btnDelAll
   - btnAddZusage, btnMoveZusage, btnDelZusage
   - btnSortPLan, btnSortZugeord
   - cmdListMA_Standard, cmdListMA_Entfernung

5. **Unter-/Überbesetzung-Warnung:**
   ```javascript
   const soll = state.zeiten.reduce((s, z) => s + (z.MA_Anzahl || 0), 0);
   const ist = state.zeiten.reduce((s, z) => s + (z.MA_Anzahl_Ist || 0), 0);
   if (ist < soll) {
       // Rote Warnung
   } else if (ist > soll) {
       // Orange Warnung
   }
   ```

6. **Qualifikations-Dropdown befüllen:**
   ```javascript
   Bridge.loadData('qualifikationen', null);
   ```

### MITTELFRISTIG

7. **Access VBA vergleichen:**
   - Original-Logik dokumentieren
   - Fehlende Features identifizieren

8. **Auto-Refresh:**
   ```javascript
   setInterval(() => loadGeplantZugesagt(), 30000); // alle 30 Sek
   ```

9. **Datum-Picker:**
   ```html
   <input type="date" id="datEinsatz">
   ```

---

## 14. DATENFLUSS-DIAGRAMM

```
┌──────────────────────────────────────────────────────────────┐
│                     USER INTERAKTION                         │
└────────────┬─────────────────────────────────────────────────┘
             │
             ▼
    ┌────────────────┐
    │ Auftrag wählen │
    └────────┬───────┘
             │ Bridge.loadData('auftrag', vaId)
             │ Bridge.loadData('einsatztage', {va_id})
             ▼
    ┌──────────────────┐
    │ onAuftraegeRcvd  │ → Zeigt Auftragsinfo
    │ onEinsatztageRcv │ → Befüllt Datum-Dropdown
    └────────┬─────────┘
             │
             ▼
    ┌────────────────┐
    │ Datum wählen   │
    └────────┬───────┘
             │ Bridge.loadData('schichten', {va_id})
             │ Bridge.loadData('mitarbeiter', {aktiv})
             │ Bridge.loadData('zuordnungen', {va_id})
             ▼
    ┌──────────────────────────────────────────┐
    │ onSchichtenReceived                      │ → Zeigt Schicht-Liste
    │ onMitarbeiterReceived                    │ → Zeigt MA-Liste (gefiltert)
    │ onZuordnungenReceived                    │ → Zeigt Geplant/Zugesagt
    └────────┬─────────────────────────────────┘
             │
             ▼
    ┌──────────────────┐
    │ Schicht wählen   │ → Speichert in state.selectedZeit
    └────────┬─────────┘
             │
             ▼
    ┌──────────────────┐
    │ MA selektieren   │ → state.selectedMAs.add(maId)
    └────────┬─────────┘
             │
             ▼
    ┌──────────────────┐
    │ "Zuordnen" Click │
    └────────┬─────────┘
             │ Bridge.sendEvent('save', {type:'zuordnung', data})
             ▼
    ┌──────────────────┐
    │ Backend speichert│ → tbl_MA_VA_Planung
    └────────┬─────────┘
             │
             ▼
    ┌──────────────────┐
    │ loadGeplantZugsg │ → Lädt aktualisierte Zuordnungen
    │ renderMAListe    │ → Aktualisiert MA-Liste (Farben)
    └──────────────────┘
```

---

## FAZIT

Das Formular **frm_MA_VA_Schnellauswahl.html** hat eine solide Basis-Funktionalität für die schnelle MA-Zuordnung, leidet jedoch unter:

1. **Architektur-Inkonsistenz** (Inline vs. Logic-Datei)
2. **Unvollständiger Implementierung** (58% der Buttons fehlen)
3. **Fehlender Verfügbarkeits-Logik**

**PRIORITÄT:**
1. Entscheidung Inline vs. Logic-Datei treffen (SOFORT)
2. Element-IDs synchronisieren (SOFORT)
3. Fehlende Kern-Funktionen implementieren (KURZFRISTIG)

**POSITIV:**
- Kern-Funktionalität (Auftrag → Datum → MA zuordnen) funktioniert
- Gute Filter-Optionen
- Saubere State-Verwaltung
- Bridge-Kommunikation funktioniert

---

**Ende des Berichts**
