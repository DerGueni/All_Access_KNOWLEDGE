# HTML → ACCESS SYNCHRONISATIONS-ANALYSE
**Datum:** 15.01.2026
**Zweck:** Detaillierte Analyse der Datensynchronisation zwischen HTML-Formularen und Access

---

## 🔍 ZUSAMMENFASSUNG

**Status:** ⚠️ **UNVOLLSTÄNDIG** - Viele Eingabefelder werden NICHT automatisch nach Access synchronisiert!

**Hauptproblem:** Fehlende automatische Speicher-Logik für die meisten Eingabefelder in den Formularen.

---

## 📊 ANALYSIERTE FORMULARE

### 1. frm_va_Auftragstamm.html (Auftragsverwaltung)

**Feld-Anzahl:**
- Gesamt: 74.054 Zeilen HTML-Code (zu groß für vollständige Analyse)
- Event-Listener (onBlur/onChange): 17 gefunden

**Synchronisations-Mechanismen:**

#### ✅ FUNKTIONIERT (Felder mit Event-Handling):
1. **Veranst_Status_ID** (Dropdown)
   - Event: `change` → `applyStatusRules()`
   - Logik: Z. 179-194 in `frm_va_Auftragstamm.logic.js`
   - **Problem:** Keine automatische Speicherung nach Access!

2. **Veranstalter_ID** (Dropdown)
   - Event: `change` → `applyVeranstalterRules()`
   - Event: `dblclick` → öffnet Kundenstamm
   - Logik: Z. 196-207
   - **Problem:** Keine automatische Speicherung!

3. **Objekt_ID** (Dropdown)
   - Event: `change` → `applyObjektRules()`
   - Event: `dblclick` → öffnet Positionen
   - Logik: Z. 209-215
   - **Problem:** Keine automatische Speicherung!

4. **cboVADatum** (Datumsauswahl)
   - Event: `change` → `updateMASubforms()`
   - Event: `dblclick` → öffnet Einsatztage-Übersicht
   - Logik: Z. 217-239
   - **Problem:** Keine automatische Speicherung!

5. **Auftraege_ab** (Datumsfilter)
   - Event: `dblclick` → öffnet Datumspicker
   - Logik: Z. 241-273
   - **Keine Speicherung** (nur Filter)

6. **Treffp_Zeit** (Treffpunktzeit)
   - Event: `keydown` → Validierung
   - Logik: Z. 289-300
   - **Problem:** Keine automatische Speicherung!

#### ❌ NICHT SYNCHRONISIERT (fehlende Events):
- **Auftrag** (Text-Input) - KEIN Event
- **VA_Veranstalter** (Text) - KEIN Event
- **VA_Objekt** (Text) - KEIN Event
- **VA_Auftragsart** (Dropdown) - KEIN Event
- **VA_Telefon** (Text) - KEIN Event
- **VA_Email** (Text) - KEIN Event
- **VA_Ansprechpartner** (Text) - KEIN Event
- **VA_Bemerkungen** (Textarea) - KEIN Event
- **Alle weiteren Stammdaten-Felder** - KEINE Events

#### 🔧 Speicher-Mechanismen (vorhanden):
```javascript
// KEINE automatische Speicherung bei Feldänderungen!
// Nur manuell via Button oder API-Aufruf

// API-Aufruf (muss explizit getriggert werden):
Bridge.update(va_id, data) // in bridgeClient.js
```

**API-Endpoint:**
- `PUT /api/auftraege/<int:id>` (Z. 863-930 in api_server.py)
- **Empfängt:** JSON mit allen Feldern
- **Problem:** Wird NICHT automatisch aufgerufen bei Feldänderungen!

---

### 2. frm_MA_Mitarbeiterstamm.html (Mitarbeiterstamm)

**Feld-Anzahl:**
- Gesamt: 41.488 Zeilen HTML-Code (zu groß für vollständige Analyse)
- WebView2-Bridge: vorhanden (`frm_MA_Mitarbeiterstamm.webview2.js`)

**Synchronisations-Mechanismen:**

#### ✅ FUNKTIONIERT (WebView2-Bridge):
```javascript
// Z. 39-63 in frm_MA_Mitarbeiterstamm.webview2.js
WebView2Bridge.setFormDataProvider(() => collectMitarbeiterData());

function collectMitarbeiterData() {
    return {
        MA_ID: getValue('MA_ID'),
        MA_Nachname: getValue('MA_Nachname'),
        MA_Vorname: getValue('MA_Vorname'),
        MA_Strasse: getValue('MA_Strasse'),
        MA_PLZ: getValue('MA_PLZ'),
        MA_Ort: getValue('MA_Ort'),
        MA_TelMobil: getValue('MA_TelMobil'),
        // ... weitere Felder
        timestamp: new Date().toISOString()
    };
}
```

#### 🔧 Speicher-Button:
```javascript
// Z. 73-76
hookButton('btnSpeichern', () => {
    WebView2Bridge.save(collectMitarbeiterData());
});
```

**API-Endpoint:**
- `PUT /api/mitarbeiter/<int:id>` (Z. 2355-2415 in api_server.py)
- **Empfängt:** JSON mit allen Feldern
- **Problem:** Speicherung NUR via Button-Klick, NICHT bei Feldänderung!

#### ❌ NICHT AUTOMATISCH SYNCHRONISIERT:
- Alle Eingabefelder erfordern **manuellen Button-Klick** zum Speichern
- Keine `onBlur` oder `onChange` Events die automatisch speichern

---

### 3. frm_KD_Kundenstamm.html (Kundenstamm)

**Feld-Anzahl:**
- Gesamt: 64.367 Zeilen HTML-Code (zu groß für vollständige Analyse)
- Logic-Datei: `frm_KD_Kundenstamm.logic.js` (1170 Zeilen)

**Synchronisations-Mechanismen:**

#### ✅ FUNKTIONIERT (Change-Tracking):
```javascript
// Z. 133-147 in frm_KD_Kundenstamm.logic.js
const trackFields = [
    'KD_Kuerzel', 'KD_Name1', 'KD_Name2', 'KD_Strasse', 'KD_PLZ', 'KD_Ort',
    'KD_Land', 'KD_Telefon', 'KD_Fax', 'KD_Email', 'KD_Web', 'KD_UStIDNr',
    'KD_AP_Name', 'KD_AP_Position', 'KD_AP_Telefon', 'KD_AP_Email',
    'KD_Bemerkungen', 'KD_IstAktiv', 'KD_Zahlungsbedingung'
];
trackFields.forEach(field => {
    const el = elements[field];
    if (el) {
        el.addEventListener('change', () => { state.isDirty = true; });
        if (el.type !== 'checkbox') {
            el.addEventListener('input', () => { state.isDirty = true; });
        }
    }
});
```

**Dirty-Flag:** ✅ Vorhanden, aber **KEINE automatische Speicherung!**

#### 🔧 Speicher-Funktion:
```javascript
// Z. 440-496 in frm_KD_Kundenstamm.logic.js
async function saveRecord() {
    if (!validateRequired()) return;

    const data = {
        KD_Kuerzel: elements.KD_Kuerzel?.value?.trim() || '',
        KD_Name1: name1,
        KD_Name2: elements.KD_Name2?.value?.trim() || '',
        // ... alle Felder manuell sammeln
    };

    try {
        const id = elements.KD_ID?.value;
        if (id && state.currentRecord) {
            await Bridge.kunden.update(id, data);
        } else {
            await Bridge.kunden.create(data);
        }
        state.isDirty = false;
        await loadList();
    } catch (error) {
        // Fehlerbehandlung
    }
}
```

**API-Endpoint:**
- `PUT /api/kunden/<int:id>` (Z. 2264-2309 in api_server.py)
- **Empfängt:** JSON mit allen Feldern
- **Problem:** Speicherung NUR via Button-Klick, NICHT automatisch!

#### ❌ NICHT AUTOMATISCH SYNCHRONISIERT:
- Speicherung erfordert **manuellen Button-Klick** (`btnSpeichern`)
- Keine automatische Speicherung bei `onBlur` oder nach Timeout

#### 🔄 ACCESS VBA-SYNC EVENTS (vorhanden aber nicht genutzt):
```javascript
// Z. 758-869 - Funktionen vorhanden, aber NICHT verbunden mit HTML-Feldern!
function KD_Kuerzel_AfterUpdate(value) { /* ... */ }
function KD_Name1_AfterUpdate(value) { /* ... */ }
function KD_IstAktiv_AfterUpdate(value) { /* ... */ }
// ... weitere AfterUpdate-Handler
```
**Problem:** Diese Funktionen existieren, werden aber **NIE aufgerufen**, weil die HTML-Felder keine Event-Listener haben, die diese Funktionen triggern!

---

### 4. frm_OB_Objekt.html (Objektstamm)

**Feld-Anzahl:**
- Gesamt: 4.631 Zeilen HTML
- Inline-JavaScript: 2.607 Zeilen (Z. 1990-4596)
- WebView2-Bridge: vorhanden (`frm_OB_Objekt.webview2.js`)

**Synchronisations-Mechanismen:**

#### ✅ FUNKTIONIERT (Change-Tracking):
```javascript
// Z. 2074-2083 in frm_OB_Objekt.html (Inline-JS)
document.querySelectorAll('[data-field]').forEach(el => {
    el.addEventListener('change', () => { state.isDirty = true; });
    el.addEventListener('input', () => { state.isDirty = true; });
});
```

**Dirty-Flag:** ✅ Vorhanden, aber **KEINE automatische Speicherung!**

#### 🔧 Speicher-Funktion:
```javascript
// Z. 2822-2896 in frm_OB_Objekt.html
async function saveRecord() {
    const data = collectFormData();
    if (!data.Objekt) {
        showToast('Bitte Objektname eingeben', 'error');
        return;
    }

    try {
        if (state.currentRecord && state.currentRecord.ID) {
            result = await apiCall(`/objekte/${state.currentRecord.ID}`, 'PUT', data);
        } else {
            result = await apiCall('/objekte', 'POST', data);
        }
        state.isDirty = false;
        await loadObjekte();

        if (window.Bridge) {
            Bridge.sendEvent('save', { formData: data });
        }
    } catch (error) {
        // Fehlerbehandlung
    }
}
```

**API-Endpoint:**
- `PUT /api/objekte/<int:id>` (Z. 2091-2131 in api_server.py)
- **Empfängt:** JSON mit allen Feldern
- **Problem:** Speicherung NUR via Button-Klick!

#### ❌ NICHT AUTOMATISCH SYNCHRONISIERT:
- Speicherung erfordert **manuellen Button-Klick** (`btnSpeichern`)
- Keine `onBlur`-Events
- Keine automatische Speicherung bei Navigation (wird dirty-Flag nur geprüft)

---

## 🚨 FEHLENDE SYNCHRONISATIONS-LOGIK

### Felder OHNE Speicher-Events:

#### frm_va_Auftragstamm (Beispiele):
| Feld | Typ | Event | Speicherung |
|------|-----|-------|-------------|
| Auftrag | text | ❌ | ❌ |
| VA_Veranstalter | text | ❌ | ❌ |
| VA_Objekt | text | ❌ | ❌ |
| VA_Telefon | tel | ❌ | ❌ |
| VA_Email | email | ❌ | ❌ |
| VA_Ansprechpartner | text | ❌ | ❌ |
| VA_Bemerkungen | textarea | ❌ | ❌ |
| Veranst_Status_ID | select | ✅ (change) | ❌ |
| Veranstalter_ID | select | ✅ (change) | ❌ |
| Objekt_ID | select | ✅ (change) | ❌ |

#### frm_MA_Mitarbeiterstamm (Beispiele):
| Feld | Typ | Event | Speicherung |
|------|-----|-------|-------------|
| MA_Nachname | text | ❌ | ⚠️ (nur via Button) |
| MA_Vorname | text | ❌ | ⚠️ (nur via Button) |
| MA_Strasse | text | ❌ | ⚠️ (nur via Button) |
| MA_PLZ | text | ❌ | ⚠️ (nur via Button) |
| MA_Ort | text | ❌ | ⚠️ (nur via Button) |
| MA_TelMobil | tel | ❌ | ⚠️ (nur via Button) |
| MA_Email | email | ❌ | ⚠️ (nur via Button) |

#### frm_KD_Kundenstamm (Beispiele):
| Feld | Typ | Event | Speicherung |
|------|-----|-------|-------------|
| KD_Name1 | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| KD_Name2 | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| KD_Strasse | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| KD_PLZ | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| KD_Telefon | tel | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| KD_Email | email | ✅ (input/change → dirty) | ⚠️ (nur via Button) |

#### frm_OB_Objekt (Beispiele):
| Feld | Typ | Event | Speicherung |
|------|-----|-------|-------------|
| Objekt | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| Strasse | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| PLZ | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| Ort | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| Ansprechpartner | text | ✅ (input/change → dirty) | ⚠️ (nur via Button) |
| Telefon | tel | ✅ (input/change → dirty) | ⚠️ (nur via Button) |

---

## 📡 API-ENDPOINTS ANALYSE

### Verfügbare Endpoints für Speicherung:

#### 1. Aufträge (Auftragsverwaltung)
```python
# POST /api/auftraege (Z. 816-861)
# PUT /api/auftraege/<int:id> (Z. 863-930)

# Empfängt ALLE Felder:
- VA_KD_ID (Pflicht)
- VA_Objekt_ID
- VA_Datum
- VA_Status
- Auftrag
- Veranstalter
- Objekt
- Telefon
- Email
- Ansprechpartner
- Bemerkungen
# ... weitere ~30 Felder

# UPDATE erfolgt dynamisch:
updates = []
values = []
for key, value in data.items():
    if key not in ['ID']:
        updates.append(f"[{key}] = ?")
        values.append(value)
```

#### 2. Mitarbeiter
```python
# POST /api/mitarbeiter (Z. 2311-2353)
# PUT /api/mitarbeiter/<int:id> (Z. 2355-2415)

# Empfängt ALLE Felder:
- Nachname (Pflicht)
- Vorname
- Strasse
- PLZ
- Ort
- Tel_Mobil
- Tel_Festnetz
- Email
- Geburtsdatum
- Anstellung
- IstAktiv
# ... weitere Felder

# Allowed Fields List (Z. 2362-2387):
allowed_fields = [
    'Nachname', 'Vorname', 'Strasse', 'PLZ', 'Ort',
    'Tel_Mobil', 'Tel_Festnetz', 'Email', ...
]
```

#### 3. Kunden
```python
# POST /api/kunden (Z. 2232-2262)
# PUT /api/kunden/<int:id> (Z. 2264-2309)

# Empfängt ALLE Felder:
- kun_Firma (Pflicht)
- kun_Kuerzel
- kun_Strasse
- kun_PLZ
- kun_Ort
- kun_Telefon
- kun_Email
- kun_IstAktiv
# ... weitere Felder

# UPDATE SQL wird dynamisch generiert
```

#### 4. Objekte
```python
# POST /api/objekte (Z. 2058-2089)
# PUT /api/objekte/<int:id> (Z. 2091-2131)

# Empfängt ALLE Felder:
- Objekt (Pflicht)
- Strasse
- PLZ
- Ort
- Veranstalter_ID
- Ansprechpartner
- Telefon
- Bemerkungen
# ... weitere Felder
```

### ✅ API-Endpoints funktionieren korrekt
- Alle Endpoints akzeptieren JSON mit allen Feldern
- Dynamische Updates (nur geänderte Felder werden aktualisiert)
- Fehlerbehandlung vorhanden
- CORS-Header korrekt gesetzt

**Problem:** Endpoints werden **NICHT automatisch aufgerufen** bei Feldänderungen!

---

## 🔍 URSACHEN-ANALYSE

### Warum fehlt die automatische Synchronisation?

#### 1. **Fehlende onBlur/onChange Events**
```javascript
// AKTUELL (FEHLT):
<input type="text" id="Auftrag" name="Auftrag" />

// BENÖTIGT:
<input type="text" id="Auftrag" name="Auftrag"
       onblur="saveField('Auftrag', this.value)" />
```

#### 2. **Nur Dirty-Flag, keine Speicherung**
```javascript
// AKTUELL:
el.addEventListener('change', () => { state.isDirty = true; });
// → Nur Flag setzen, KEINE Speicherung!

// BENÖTIGT:
el.addEventListener('blur', () => {
    if (state.isDirty) {
        saveCurrentField();
    }
});
```

#### 3. **Speicherung nur via Button**
```javascript
// AKTUELL:
bindButton('btnSpeichern', saveRecord);
// → User muss Button klicken

// BENÖTIGT:
bindButton('btnSpeichern', saveRecord); // Behalten
// + automatische Speicherung bei onBlur
```

#### 4. **Access VBA-Sync Events nicht verbunden**
```javascript
// AKTUELL:
function KD_Name1_AfterUpdate(value) { ... }
// → Funktion existiert, wird aber NIE aufgerufen!

// BENÖTIGT:
document.getElementById('KD_Name1').addEventListener('blur', () => {
    KD_Name1_AfterUpdate(this.value);
});
```

---

## ✅ VORHANDENE SPEICHER-MECHANISMEN

### Was funktioniert bereits:

#### 1. **Bridge API-Client** (`api/bridgeClient.js`)
```javascript
// CRUD-Operationen vorhanden:
Bridge.auftraege.get(id)
Bridge.auftraege.list(params)
Bridge.auftraege.create(data)
Bridge.auftraege.update(id, data)
Bridge.auftraege.delete(id)

// Analog für: kunden, mitarbeiter, objekte, ...
```

#### 2. **WebView2-Bridge** (`js/webview2-bridge.js`)
```javascript
// Speichern via Access:
WebView2Bridge.save(formData)
WebView2Bridge.sendEvent('save', data)
```

#### 3. **Dirty-Tracking**
```javascript
// In allen Formularen:
state.isDirty = true/false
```

#### 4. **Validation**
```javascript
// Pflichtfeld-Validierung:
function validateRequired() { ... }
// Z.B. in frm_KD_Kundenstamm.logic.js Z. 413-435
```

---

## 📋 FEHLENDE FUNKTIONALITÄT - ZUSAMMENFASSUNG

### Pro Formular:

#### frm_va_Auftragstamm
- ❌ Automatische Speicherung bei Feldänderung
- ❌ onBlur-Events für Text-Inputs
- ❌ onChange-Events für Dropdowns führen zu Speicherung
- ⚠️ Nur Status-Änderungen triggern Regeln, aber KEINE Speicherung
- ✅ Dirty-Flag vorhanden (aber nicht genutzt für Auto-Save)

**Geschätzte fehlende Events:** ~40 Eingabefelder ohne Speicher-Logik

#### frm_MA_Mitarbeiterstamm
- ❌ Automatische Speicherung bei Feldänderung
- ❌ onBlur-Events
- ⚠️ WebView2Bridge vorhanden, aber nur Button-triggered
- ⚠️ collectMitarbeiterData() vorhanden, aber nicht automatisch aufgerufen
- ✅ Speicher-Button funktioniert

**Geschätzte fehlende Events:** ~25 Eingabefelder ohne Auto-Save

#### frm_KD_Kundenstamm
- ❌ Automatische Speicherung bei Feldänderung
- ❌ onBlur-Events
- ⚠️ Change/Input-Events setzen nur Dirty-Flag
- ⚠️ AfterUpdate-Handler vorhanden aber nicht verbunden
- ✅ Dirty-Tracking funktioniert
- ✅ Speicher-Button funktioniert

**Geschätzte fehlende Events:** ~20 Eingabefelder ohne Auto-Save

#### frm_OB_Objekt
- ❌ Automatische Speicherung bei Feldänderung
- ❌ onBlur-Events
- ⚠️ Change/Input-Events setzen nur Dirty-Flag
- ✅ Dirty-Tracking funktioniert
- ✅ Speicher-Button funktioniert

**Geschätzte fehlende Events:** ~15 Eingabefelder ohne Auto-Save

---

## 🎯 EMPFEHLUNGEN

### Kritische Maßnahmen:

#### 1. **onBlur-Events für alle Eingabefelder hinzufügen**
```javascript
// Beispiel-Implementation:
function setupAutoSave() {
    document.querySelectorAll('[data-field]').forEach(el => {
        if (el.readOnly || el.disabled) return;

        el.addEventListener('blur', async () => {
            if (!state.isDirty) return;

            const fieldName = el.getAttribute('data-field');
            const value = el.value;

            try {
                await saveField(fieldName, value);
                console.log(`[AutoSave] ${fieldName} gespeichert`);
            } catch (err) {
                console.error(`[AutoSave] Fehler bei ${fieldName}:`, err);
            }
        });
    });
}
```

#### 2. **Feld-spezifische Speicher-Funktion**
```javascript
async function saveField(fieldName, value) {
    if (!state.currentRecord?.ID) {
        console.warn('[AutoSave] Keine aktuelle ID - überspringe');
        return;
    }

    const data = { [fieldName]: value };

    try {
        // Formular-spezifisch:
        if (isAuftragstamm) {
            await Bridge.auftraege.update(state.currentRecord.ID, data);
        } else if (isKundenstamm) {
            await Bridge.kunden.update(state.currentRecord.ID, data);
        } else if (isMitarbeiterstamm) {
            await Bridge.mitarbeiter.update(state.currentRecord.ID, data);
        } else if (isObjektstamm) {
            await Bridge.objekte.update(state.currentRecord.ID, data);
        }

        state.isDirty = false;
        showToast(`${fieldName} gespeichert`, 'success');
    } catch (error) {
        showToast(`Fehler beim Speichern: ${error.message}`, 'error');
        throw error;
    }
}
```

#### 3. **Debounce für Input-Events (optional)**
```javascript
// Für Textfelder mit häufigen Änderungen:
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func(...args), wait);
    };
}

const debouncedSave = debounce(saveField, 500);

el.addEventListener('input', () => {
    state.isDirty = true;
    debouncedSave(fieldName, el.value);
});
```

#### 4. **Access VBA-Sync Events verbinden**
```javascript
// Für frm_KD_Kundenstamm:
function setupAccessSyncEvents() {
    const fields = {
        'KD_Kuerzel': KD_Kuerzel_AfterUpdate,
        'KD_Name1': KD_Name1_AfterUpdate,
        'KD_IstAktiv': KD_IstAktiv_AfterUpdate,
        // ... weitere
    };

    Object.entries(fields).forEach(([fieldId, handler]) => {
        const el = document.getElementById(fieldId);
        if (el) {
            el.addEventListener('blur', () => handler(el.value));
        }
    });
}
```

#### 5. **Auto-Save beim Verlassen des Formulars**
```javascript
window.addEventListener('beforeunload', (e) => {
    if (state.isDirty) {
        e.preventDefault();
        e.returnValue = ''; // Chrome

        // Optional: Automatisch speichern
        saveRecord().then(() => {
            console.log('[AutoSave] Beim Verlassen gespeichert');
        });
    }
});
```

#### 6. **Periodisches Auto-Save (optional)**
```javascript
// Alle 30 Sekunden speichern wenn dirty:
setInterval(() => {
    if (state.isDirty && state.currentRecord?.ID) {
        console.log('[AutoSave] Periodisches Speichern...');
        saveRecord();
    }
}, 30000); // 30 Sekunden
```

---

## 📊 PRIORISIERUNG

### Kritisch (Sofort):
1. **frm_va_Auftragstamm** - Meistgenutzt, viele Felder
2. **frm_MA_Mitarbeiterstamm** - Kritische Stammdaten
3. **frm_KD_Kundenstamm** - Kritische Stammdaten

### Wichtig (Bald):
4. **frm_OB_Objekt** - Weniger Felder, aber wichtig

### Optional:
- Alle weiteren Formulare folgen demselben Muster

---

## ⚠️ RISIKEN OHNE AUTO-SAVE

### Datenverlust-Szenarien:
1. **User vergisst Speichern-Button** → Alle Änderungen verloren
2. **Browser-Absturz** → Alle nicht-gespeicherten Änderungen verloren
3. **Versehentliches Schließen** → Änderungen verloren
4. **Navigation zu anderem Datensatz** → Änderungen verloren (wenn dirty-Check fehlt)
5. **Timeout/Session-Verlust** → Änderungen verloren

### User-Experience Probleme:
- **Inkonsistent:** Einige Felder speichern sofort (Subforms), andere nicht
- **Verwirrend:** User weiß nicht, ob Daten gespeichert sind
- **Fehleranfällig:** Manuelles Speichern wird vergessen
- **Nicht Access-kompatibel:** Access speichert automatisch bei Feldwechsel

---

## ✅ VOLLSTÄNDIGE FELD-LISTE (Beispiel: frm_KD_Kundenstamm)

### Felder MIT Change-Tracking OHNE Auto-Save:

| Feld-ID | Typ | Event | Dirty | Save |
|---------|-----|-------|-------|------|
| KD_Kuerzel | text | change/input | ✅ | ❌ |
| KD_Name1 | text | change/input | ✅ | ❌ |
| KD_Name2 | text | change/input | ✅ | ❌ |
| KD_Strasse | text | change/input | ✅ | ❌ |
| KD_PLZ | text | change/input | ✅ | ❌ |
| KD_Ort | text | change/input | ✅ | ❌ |
| KD_Land | text | change/input | ✅ | ❌ |
| KD_Telefon | tel | change/input | ✅ | ❌ |
| KD_Fax | tel | change/input | ✅ | ❌ |
| KD_Email | email | change/input | ✅ | ❌ |
| KD_Web | url | change/input | ✅ | ❌ |
| KD_UStIDNr | text | change/input | ✅ | ❌ |
| KD_Zahlungsbedingung | select | change | ✅ | ❌ |
| KD_AP_Name | text | change/input | ✅ | ❌ |
| KD_AP_Position | text | change/input | ✅ | ❌ |
| KD_AP_Telefon | tel | change/input | ✅ | ❌ |
| KD_AP_Email | email | change/input | ✅ | ❌ |
| KD_Bemerkungen | textarea | change/input | ✅ | ❌ |
| KD_IstAktiv | checkbox | change | ✅ | ❌ |

**Gesamt:** 19 Felder mit Dirty-Tracking, **ALLE ohne Auto-Save!**

---

## 🔧 IMPLEMENTIERUNGS-BEISPIEL

### Code für frm_KD_Kundenstamm.logic.js:

```javascript
// Nach Z. 148 einfügen:

// ============================================
// AUTO-SAVE IMPLEMENTATION
// ============================================

/**
 * Setup Auto-Save für alle Eingabefelder
 */
function setupAutoSave() {
    console.log('[KD] Setup Auto-Save...');

    const saveFields = [
        'KD_Kuerzel', 'KD_Name1', 'KD_Name2', 'KD_Strasse', 'KD_PLZ', 'KD_Ort',
        'KD_Land', 'KD_Telefon', 'KD_Fax', 'KD_Email', 'KD_Web', 'KD_UStIDNr',
        'KD_Zahlungsbedingung', 'KD_AP_Name', 'KD_AP_Position',
        'KD_AP_Telefon', 'KD_AP_Email', 'KD_Bemerkungen', 'KD_IstAktiv'
    ];

    saveFields.forEach(fieldName => {
        const el = elements[fieldName];
        if (!el) return;

        // onBlur → Speichern wenn dirty
        el.addEventListener('blur', async () => {
            if (!state.isDirty || !state.currentRecord?.KD_ID) return;

            try {
                await saveFieldUpdate(fieldName, el);
                console.log(`[AutoSave] ${fieldName} gespeichert`);
            } catch (err) {
                console.error(`[AutoSave] Fehler bei ${fieldName}:`, err);
            }
        });
    });
}

/**
 * Speichert ein einzelnes Feld nach Access
 */
async function saveFieldUpdate(fieldName, element) {
    const value = element.type === 'checkbox' ? element.checked : element.value;
    const id = state.currentRecord.KD_ID || state.currentRecord.kun_Id;

    if (!id) {
        console.warn('[AutoSave] Keine ID vorhanden');
        return;
    }

    const data = { [fieldName]: value };

    try {
        await Bridge.kunden.update(id, data);
        state.isDirty = false;
        setStatus(`${fieldName} gespeichert`);

        // Access VBA-Sync Event aufrufen (falls vorhanden)
        const afterUpdateHandler = window.KundenStamm?.[`${fieldName}_AfterUpdate`];
        if (typeof afterUpdateHandler === 'function') {
            afterUpdateHandler(value);
        }
    } catch (error) {
        setStatus(`Fehler: ${error.message}`);
        throw error;
    }
}

// In init() nach Z. 94 einfügen:
setupAutoSave();
```

---

## 📝 TESTPLAN

### Test-Szenarien für Auto-Save:

#### 1. **Feld ändern und Tab wechseln**
- Erwartung: Speicherung bei onBlur
- Zu prüfen: API-Aufruf erfolgt

#### 2. **Feld ändern und zu anderem Datensatz wechseln**
- Erwartung: Speicherung vor Navigation
- Zu prüfen: Kein Datenverlust

#### 3. **Feld ändern und Formular schließen**
- Erwartung: beforeunload-Warnung oder Auto-Save
- Zu prüfen: Daten bleiben erhalten

#### 4. **Schnelle Eingabe (Input-Event)**
- Erwartung: Debounced Save nach 500ms
- Zu prüfen: Nicht zu viele API-Aufrufe

#### 5. **Pflichtfeld leer lassen**
- Erwartung: Validation vor Save
- Zu prüfen: Fehlermelding, kein API-Aufruf

---

## 📞 KONTAKT

Bei Fragen zur Implementierung:
- **Projektordner:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE`
- **API-Server:** `C:\Users\guenther.siegert\Documents\Access Bridge\api_server.py`
- **HTML-Forms:** `04_HTML_Forms\forms3\`

---

**Ende des Reports**
