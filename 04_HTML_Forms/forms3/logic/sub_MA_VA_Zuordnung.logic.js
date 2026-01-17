/**
 * sub_MA_VA_Zuordnung.logic.js
 * Logik für MA-Zuordnung Subform (tbl_MA_VA_Planung)
 *
 * RecordSource: qry_sub_MA_VA_Zuordnung (basiert auf tbl_MA_VA_Planung)
 * LinkMaster: ID;cboVADatum (vom Parent frm_va_Auftragstamm)
 * LinkChild: VA_ID;VADatum_ID
 *
 * Felder lt. Access-Export:
 * - ID, VA_ID, PosNr, MA_Start, MA_Ende, MA_ID, PKW, VADatum_ID, VAStart_ID
 * - Bemerkungen, Einsatzleitung, IstFraglich, PKW_Anzahl
 * - PreisArt_ID, MA_Brutto_Std, MA_netto_std, Info
 * - Anfragezeitpunkt, Rückmeldezeitpunkt, Rch_Erstellt
 * - Erst_von, Erst_am, Aend_von, Aend_am, RL_34a
 * - cboMA_Ausw (ungebundene Combobox für Eingabe)
 *
 * VBA-Events (aus Access-Export):
 * - sub_MA_VA_Zuordnung_Enter: Recalc der zsub_lstAuftrag
 * - sub_MA_VA_Zuordnung_Exit: Recalc der zsub_lstAuftrag
 * - cboMA_Ausw.AfterUpdate: MA-Selektion aktualisieren
 * - PKW.AfterUpdate: PKW-Status aktualisieren
 * - Einsatzleitung.AfterUpdate: EL-Status aktualisieren
 * - Row Click/DblClick: Zeilen-Auswahl und Bearbeitung
 */

// Subform State
const state = {
    VA_ID: null,
    VADatum_ID: null,
    schichten: [],    // Alle Schichten für das Datum
    zuordnungen: [],  // MA-Zuordnungen
    records: [],      // Kombinierte Anzeige-Daten (Schichten + Zuordnungen)
    selectedIndex: -1,
    isEmbedded: false,
    maLookup: [] // Mitarbeiter-Auswahlliste
};

// DOM Elements
let tbody = null;
let cboMASelect = null;

/**
 * Initialisierung
 */
function init() {
    console.log('[sub_MA_VA_Zuordnung] init() gestartet');
    tbody = document.getElementById('tbody_MA_VA_Zuordnung');
    cboMASelect = document.getElementById('new_cboMA_Ausw');

    // Prüfen ob embedded (in iframe)
    state.isEmbedded = window.parent !== window;

    // Event Listener
    document.getElementById('btnAddRow')?.addEventListener('click', addNewRow);

    // MA-Lookup laden
    loadMALookup();

    // Wenn embedded, auf Parent-Messages hören
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);

        // Ready-Signal MEHRFACH senden (Robustheit gegen Timing-Probleme)
        // 1. Sofort senden
        console.log('[sub_MA_VA_Zuordnung] Sende subform_ready (sofort)');
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_VA_Zuordnung' }, '*');

        // 2. Nach 100ms erneut senden (falls Parent noch nicht bereit war)
        setTimeout(() => {
            console.log('[sub_MA_VA_Zuordnung] Sende subform_ready (100ms delay)');
            window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_VA_Zuordnung' }, '*');
        }, 100);

        // 3. Nach 500ms erneut senden (für langsame Verbindungen)
        setTimeout(() => {
            console.log('[sub_MA_VA_Zuordnung] Sende subform_ready (500ms delay)');
            window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_VA_Zuordnung' }, '*');
        }, 500);
    }

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
    }

    console.log('[sub_MA_VA_Zuordnung] Initialisiert, embedded:', state.isEmbedded);
}

/**
 * Nachrichten vom Parent-Formular verarbeiten
 */
function handleParentMessage(event) {
    const data = event.data;
    console.log('[sub_MA_VA_Zuordnung] Message empfangen:', JSON.stringify(data));
    if (!data || !data.type) {
        console.log('[sub_MA_VA_Zuordnung] Message ignoriert - kein type');
        return;
    }

    switch (data.type) {
        case 'set_link_params':
            console.log('[sub_MA_VA_Zuordnung] set_link_params VA_ID:', data.VA_ID, 'VADatum_ID:', data.VADatum_ID);
            if (data.VA_ID !== undefined) state.VA_ID = data.VA_ID;
            if (data.VADatum_ID !== undefined) state.VADatum_ID = data.VADatum_ID;
            loadData();
            break;

        case 'requery':
            loadData();
            break;

        case 'recalc':
            recalc();
            break;

        case 'set_column_hidden':
            // PKW/Einsatzleitung ausblenden bei bestimmten Veranstaltern (VBA: Veranstalter_ID = 20760)
            if (data.column && data.hidden !== undefined) {
                setColumnHidden(data.column, data.hidden);
            }
            break;

        case 'lock_subform':
            // VBA: Veranst_Status_ID > 3 -> Subform sperren
            setSubformLocked(data.locked === true);
            break;

        case 'set_veranstalter':
            // VBA: Form_Current - Spalten ein/ausblenden je nach Veranstalter
            handleVeranstalterChange(data.veranstalter_id);
            break;
    }
}

/**
 * Subform sperren (VBA: Veranst_Status_ID_AfterUpdate)
 * Me!sub_MA_VA_Zuordnung.Locked = True/False
 */
function setSubformLocked(locked) {
    state.isLocked = locked;
    const inputs = document.querySelectorAll('input, select');
    inputs.forEach(el => {
        el.disabled = locked;
    });
    const addBtn = document.getElementById('btnAddRow');
    if (addBtn) addBtn.disabled = locked;

    // Parent informieren
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_locked_changed',
            name: 'sub_MA_VA_Zuordnung',
            locked: locked
        }, '*');
    }
}

/**
 * Veranstalter-spezifische Anpassungen (VBA: Form_Current)
 * Bei Veranstalter_ID = 20760: PKW und EL ausblenden, RE einblenden
 * Bei anderen Veranstaltern: PKW und EL einblenden, RE ausblenden
 */
function handleVeranstalterChange(veranstalterId) {
    const isBWNKunde = veranstalterId === 20760;
    // Bei BWN-Kunde (20760): PKW und EL verstecken, RE zeigen
    setColumnHidden('col-pkw', isBWNKunde);
    setColumnHidden('col-el', isBWNKunde);
    // RE-Spalte nur bei BWN-Kunde zeigen (14.01.2026)
    setColumnHidden('col-re', !isBWNKunde);
}

/**
 * MA-Lookup laden via WebView2-Bridge oder REST-API (Browser-Fallback)
 */
async function loadMALookup() {
    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    if (isBrowserMode) {
        try {
            const url = 'http://localhost:5000/api/mitarbeiter?aktiv=true';
            console.log('[sub_MA_VA_Zuordnung] Lade MA-Lookup:', url);
            const response = await fetch(url);
            const result = await response.json();
            const records = result.data || result || [];
            state.maLookup = records.map(ma => ({
                ID: ma.ID || ma.MA_ID,
                Name: `${ma.Nachname || ''}, ${ma.Vorname || ''}`,
                Tel_Mobil: ma.Tel_Mobil || ''
            }));
            console.log('[sub_MA_VA_Zuordnung] MA-Lookup geladen:', state.maLookup.length, 'Mitarbeiter');
            populateMASelect();
            // Falls Daten schon da sind, neu rendern für MA-Namen
            if (state.records.length > 0) {
                render();
            }
        } catch (e) {
            console.error('[sub_MA_VA_Zuordnung] Fehler beim Laden MA-Lookup:', e);
        }
        return;
    }

    // WebView2-Modus: Über Bridge
    Bridge.sendEvent('loadSubformData', {
        type: 'ma_lookup',
        aktiv: true
    });
}

function handleDataReceived(data) {
    if (data.type === 'ma_lookup') {
        state.maLookup = (data.records || []).map(ma => ({
            ID: ma.MA_ID || ma.ID,
            Name: `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`,
            Tel_Mobil: ma.MA_Tel_Mobil || ma.Tel_Mobil
        }));
        populateMASelect();
    } else if (data.type === 'ma_va_zuordnung') {
        state.records = (data.records || []).map(rec => ({
            ID: rec.MVP_ID || rec.ID,
            VA_ID: rec.MVP_VA_ID || rec.VA_ID,
            PosNr: rec.MVP_PosNr || rec.PosNr,
            MA_Start: rec.MVP_MA_Start || rec.MA_Start,
            MA_Ende: rec.MVP_MA_Ende || rec.MA_Ende,
            MA_ID: rec.MVP_MA_ID || rec.MA_ID,
            PKW: rec.MVP_PKW || rec.PKW,
            VADatum_ID: rec.MVP_VADatum_ID || rec.VADatum_ID,
            VAStart_ID: rec.MVP_VAStart_ID || rec.VAStart_ID,
            Bemerkungen: rec.MVP_Bemerkungen || rec.Bemerkungen,
            Einsatzleitung: rec.MVP_Einsatzleitung || rec.Einsatzleitung,
            IstFraglich: rec.MVP_IstFraglich || rec.IstFraglich,
            PKW_Anzahl: rec.MVP_PKW_Anzahl || rec.PKW_Anzahl,
            PreisArt_ID: rec.MVP_PreisArt_ID || rec.PreisArt_ID,
            MA_Brutto_Std: rec.MVP_MA_Brutto_Std || rec.MA_Brutto_Std,
            Rch_Erstellt: rec.MVP_Rch_Erstellt || rec.Rch_Erstellt
        }));
        render();
    }
}

/**
 * MA-Combobox befüllen
 */
function populateMASelect() {
    if (!cboMASelect) return;

    cboMASelect.innerHTML = '<option value="">-- MA wählen --</option>';
    state.maLookup.forEach(ma => {
        const opt = document.createElement('option');
        opt.value = ma.ID;
        opt.textContent = ma.Name;
        cboMASelect.appendChild(opt);
    });
}

/**
 * Daten laden via WebView2-Bridge oder REST-API (Browser-Fallback)
 *
 * WICHTIG: Lädt ALLE SCHICHTEN für das Datum, dann MA-Zuordnungen
 * Zeigt jede Schicht an - auch wenn keine MA zugeordnet sind
 */
async function loadData() {
    console.log('[sub_MA_VA_Zuordnung] loadData() aufgerufen - VA_ID:', state.VA_ID, 'VADatum_ID:', state.VADatum_ID);

    if (!state.VA_ID) {
        console.warn('[sub_MA_VA_Zuordnung] loadData() ABBRUCH: keine VA_ID');
        renderEmpty();
        return;
    }

    console.log('[sub_MA_VA_Zuordnung] loadData startet API-Calls...');

    // IMMER REST-API verwenden - WebView2-Bridge ist zu langsam/unzuverlässig für iframes
    // Die WebView2-Bridge hat Timeout-Probleme bei eingebetteten iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_MA_VA_Zuordnung] Verwende REST-API Modus (erzwungen)');
    if (isBrowserMode) {
        try {
            // 1. ALLE SCHICHTEN für das Datum laden
            let schichtenUrl = `http://localhost:5000/api/auftraege/${state.VA_ID}/schichten`;
            if (state.VADatum_ID) {
                schichtenUrl += `?vadatum_id=${state.VADatum_ID}`;
            }
            console.log('[sub_MA_VA_Zuordnung] Fetch Schichten:', schichtenUrl);
            const schichtenResponse = await fetch(schichtenUrl);
            const schichtenResult = await schichtenResponse.json();
            state.schichten = schichtenResult.data || [];
            console.log('[sub_MA_VA_Zuordnung] Schichten geladen:', state.schichten.length);

            // 2. MA-Zuordnungen laden
            let zuordnungenUrl = `http://localhost:5000/api/auftraege/${state.VA_ID}/zuordnungen`;
            if (state.VADatum_ID) {
                zuordnungenUrl += `?vadatum_id=${state.VADatum_ID}`;
            }
            console.log('[sub_MA_VA_Zuordnung] Fetch Zuordnungen:', zuordnungenUrl);
            const zuordnungenResponse = await fetch(zuordnungenUrl);
            const zuordnungenResult = await zuordnungenResponse.json();
            state.zuordnungen = zuordnungenResult.data || [];
            console.log('[sub_MA_VA_Zuordnung] Zuordnungen geladen:', state.zuordnungen.length);

            // 3. Records kombinieren: Jede Schicht + ihre MA-Zuordnungen
            state.records = buildDisplayRecords();

            console.log('[sub_MA_VA_Zuordnung] Display-Records:', state.records.length);
            render();
        } catch (e) {
            console.error('[sub_MA_VA_Zuordnung] Fehler beim Laden:', e);
            renderEmpty();
        }
        return;
    }

    // WebView2-Modus: Über Bridge
    Bridge.sendEvent('loadSubformData', {
        type: 'ma_va_zuordnung',
        va_id: state.VA_ID,
        vadatum_id: state.VADatum_ID
    });
}

/**
 * Kombiniert Schichten und Zuordnungen zu Anzeige-Records
 *
 * Für jede Schicht (tbl_VA_Start):
 * - Zeige MA_Anzahl Zeilen (so viele wie geplant)
 * - Fülle mit zugeordneten MA, Rest bleibt leer
 *
 * Sortierung: Nach Schicht-Startzeit (VA_Start)
 */
function buildDisplayRecords() {
    const records = [];
    let lfdNr = 1;

    // Schichten nach Startzeit sortieren
    const sortedSchichten = [...state.schichten].sort((a, b) => {
        const timeA = a.VA_Start || '';
        const timeB = b.VA_Start || '';
        return timeA.localeCompare(timeB);
    });

    for (const schicht of sortedSchichten) {
        const schichtId = schicht.ID;
        const maAnzahl = schicht.MA_Anzahl || 1;  // Geplante Anzahl MA

        // MA-Zuordnungen für diese Schicht finden (VAStart_ID = Schicht-ID)
        const schichtZuordnungen = state.zuordnungen.filter(z =>
            z.VAStart_ID === schichtId || z.VAStart_ID == schichtId
        );

        // Erzeuge MA_Anzahl Zeilen für diese Schicht
        for (let i = 0; i < maAnzahl; i++) {
            const zuo = schichtZuordnungen[i];  // Zuordnung falls vorhanden

            if (zuo) {
                // MA zugeordnet
                records.push({
                    ID: zuo.ID || zuo.MVP_ID,
                    VA_ID: zuo.VA_ID || state.VA_ID,
                    PosNr: lfdNr++,
                    MA_Start: zuo.MA_Start || zuo.MVA_Start || schicht.VA_Start,
                    MA_Ende: zuo.MA_Ende || zuo.MVA_Ende || schicht.VA_Ende,
                    MA_ID: zuo.MA_ID || 0,
                    MA_Name: zuo.Nachname ? `${zuo.Nachname}, ${zuo.Vorname || ''}`.trim() : '',
                    PKW: zuo.PKW || 0,
                    VADatum_ID: zuo.VADatum_ID || state.VADatum_ID,
                    VAStart_ID: schichtId,
                    Bemerkungen: zuo.Bemerkungen || zuo.Bemerkung || '',
                    Einsatzleitung: zuo.Einsatzleitung || false,
                    IstFraglich: zuo.IstFraglich || false,
                    PKW_Anzahl: zuo.PKW_Anzahl,
                    PreisArt_ID: zuo.PreisArt_ID,
                    MA_Brutto_Std: zuo.MA_Brutto_Std || zuo.Std,
                    Rch_Erstellt: zuo.Rch_Erstellt || false,
                    _isNewRow: false,
                    _schichtInfo: schicht
                });
            } else {
                // Leere Zeile (noch kein MA zugeordnet)
                records.push({
                    ID: null,
                    VA_ID: state.VA_ID,
                    PosNr: lfdNr++,
                    MA_Start: schicht.VA_Start,
                    MA_Ende: schicht.VA_Ende,
                    MA_ID: null,
                    MA_Name: '',
                    PKW: 0,
                    VADatum_ID: state.VADatum_ID,
                    VAStart_ID: schichtId,
                    Bemerkungen: '',
                    Einsatzleitung: false,
                    IstFraglich: false,
                    PKW_Anzahl: null,
                    PreisArt_ID: null,
                    MA_Brutto_Std: null,
                    Rch_Erstellt: false,
                    _isNewRow: true,
                    _schichtInfo: schicht
                });
            }
        }
    }

    return records;
}

/**
 * Daten rendern - Normale Tabellenzeilen ohne Input-Felder
 */
function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        renderNoSchichten();
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        const rowClass = getRowClass(rec, idx);
        const isNewRow = rec._isNewRow === true;
        const maName = rec.MA_Name || getMAName(rec.MA_ID) || '';
        const stunden = formatDecimal(rec.MA_Brutto_Std || calculateHours(rec.MA_Start, rec.MA_Ende));

        // Normale Tabellenzeilen - keine Input-Felder
        return `
            <tr data-index="${idx}" data-id="${rec.ID || ''}" data-vastart-id="${rec.VAStart_ID || ''}"
                class="${rowClass} ${isNewRow ? 'new-row' : ''}">
                <td class="col-lfd">${rec.PosNr || ''}</td>
                <td class="col-ma">${maName}</td>
                <td class="col-time">${formatTime(rec.MA_Start)}</td>
                <td class="col-time">${formatTime(rec.MA_Ende)}</td>
                <td class="col-std">${stunden}</td>
                <td class="col-bemerk">${rec.Bemerkungen || ''}</td>
                <td class="col-info"><input type="checkbox" ${rec.IstFraglich ? 'checked' : ''} disabled title="Fraglich"></td>
                <td class="col-pkw">${formatCurrency(rec.PKW)}</td>
                <td class="col-el"><input type="checkbox" ${rec.Einsatzleitung ? 'checked' : ''} disabled title="Einsatzleitung"></td>
                <td class="col-re"><input type="checkbox" ${rec.Rch_Erstellt ? 'checked' : ''} disabled title="Rechnung erstellt"></td>
            </tr>
        `;
    }).join('');

    // Event Listener für Zeilen-Klick
    attachRowListeners();
}

/**
 * Anzeige wenn keine Schichten vorhanden
 */
function renderNoSchichten() {
    if (!tbody) return;
    tbody.innerHTML = `
        <tr>
            <td colspan="15" style="text-align:center; color:#666; padding:20px;">
                Keine Schichten für dieses Datum angelegt
            </td>
        </tr>
    `;
}

/**
 * MA-Options für Select rendern
 */
function renderMAOptions(selectedId) {
    let html = '<option value="">--</option>';
    state.maLookup.forEach(ma => {
        const selected = ma.ID == selectedId ? 'selected' : '';
        html += `<option value="${ma.ID}" ${selected}>${ma.Name}</option>`;
    });
    return html;
}

/**
 * Zeilen-CSS-Klasse ermitteln
 *
 * BEDINGTE FORMATIERUNG (Access-Parität):
 * - IstFraglich = -1 (True) → türkisblaue Hintergrundfarbe
 * - Einsatzleitung = True → spezielle Markierung
 * - PKW = True → PKW-Markierung
 */
function getRowClass(rec, idx) {
    let classes = [];
    if (idx === state.selectedIndex) classes.push('selected');
    if (rec.Einsatzleitung) classes.push('is-el');
    if (rec.PKW) classes.push('has-pkw');
    // IstFraglich = True → türkisblaue Hintergrundfarbe (Access: BackColor = 16777088 = RGB(192, 255, 255))
    if (rec.IstFraglich) classes.push('ist-fraglich');
    return classes.join(' ');
}

/**
 * MA-Name aus Lookup holen
 */
function getMAName(maId) {
    const ma = state.maLookup.find(m => m.ID == maId);
    return ma ? ma.Name : '';
}

/**
 * Event Listener an Zeilen binden
 * VBA-Events: Row Click, DblClick, AfterUpdate
 */
function attachRowListeners() {
    tbody.querySelectorAll('tr').forEach(row => {
        // Row Click Event (VBA: sub_MA_VA_Zuordnung_Enter)
        row.addEventListener('click', (e) => {
            if (e.target.tagName !== 'INPUT' && e.target.tagName !== 'SELECT') {
                selectRow(parseInt(row.dataset.index));
                // VBA: zsub_lstAuftrag.Form.Recalc
                notifyParentRecalc();
            }
        });

        // Row DblClick Event (VBA: OnDblClick)
        row.addEventListener('dblclick', (e) => {
            const rec = state.records[parseInt(row.dataset.index)];
            if (rec && rec.MA_ID) {
                // VBA: DblClick öffnet oft Details-Dialog
                if (state.isEmbedded) {
                    window.parent.postMessage({
                        type: 'row_dblclick',
                        name: 'sub_MA_VA_Zuordnung',
                        record: rec,
                        ma_id: rec.MA_ID
                    }, '*');
                }
            }
        });
    });

    // Inputs - AfterUpdate Events
    tbody.querySelectorAll('input[type="text"]').forEach(input => {
        input.addEventListener('change', handleFieldChange);
        input.addEventListener('focus', () => selectRow(parseInt(input.closest('tr').dataset.index)));
        // VBA: BeforeUpdate Validation
        input.addEventListener('blur', (e) => validateField(e.target));
    });

    // Checkboxen - AfterUpdate Events
    tbody.querySelectorAll('input[type="checkbox"]').forEach(cb => {
        cb.addEventListener('change', handleCheckboxChange);
    });

    // Selects - AfterUpdate Events (VBA: cboMA_Ausw_AfterUpdate)
    tbody.querySelectorAll('select').forEach(sel => {
        sel.addEventListener('change', handleFieldChange);
        sel.addEventListener('focus', () => selectRow(parseInt(sel.closest('tr').dataset.index)));
    });
}

/**
 * Feld-Validierung (VBA: BeforeUpdate)
 */
function validateField(input) {
    const field = input.dataset.field;
    let isValid = true;

    // Zeit-Validierung
    if (field === 'MA_Start' || field === 'MA_Ende') {
        const value = input.value.trim();
        if (value && !value.match(/^\d{1,2}:\d{2}$/)) {
            isValid = false;
            input.classList.add('validation-error');
            // VBA: Cancel = True würde Änderung verhindern
        } else {
            input.classList.remove('validation-error');
        }
    }

    return isValid;
}

/**
 * Parent über Recalc informieren (VBA: zsub_lstAuftrag.Form.Recalc)
 */
function notifyParentRecalc() {
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_recalc_request',
            name: 'sub_MA_VA_Zuordnung'
        }, '*');
    }
}

/**
 * Leere Ansicht
 */
function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = `
        <tr>
            <td colspan="15" style="text-align:center; color:#666; padding:20px;">
                Keine MA-Zuordnungen vorhanden
            </td>
        </tr>
    `;
}

/**
 * Fehler anzeigen
 */
function renderError(message) {
    if (!tbody) return;
    tbody.innerHTML = `
        <tr>
            <td colspan="15" style="text-align:center; color:#dc3545; padding:20px;">
                Fehler: ${message}
            </td>
        </tr>
    `;
}

/**
 * Zeile auswählen
 */
function selectRow(index) {
    state.selectedIndex = index;

    tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    // Parent informieren
    if (state.isEmbedded && state.records[index]) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'sub_MA_VA_Zuordnung',
            record: state.records[index]
        }, '*');
    }
}

/**
 * Feldänderung verarbeiten
 *
 * Behandelt sowohl existierende Records als auch neue Zeilen
 */
async function handleFieldChange(event) {
    const el = event.target;
    const field = el.dataset.field;
    const id = el.dataset.id;
    const vastartId = el.dataset.vastartId;
    const isNew = el.dataset.isNew === 'true' || !id;
    let value = el.value;

    // Zeit-Felder konvertieren
    if (field === 'MA_Start' || field === 'MA_Ende') {
        value = parseTime(value);
    }

    // Bei MA-Auswahl auf leerer Zeile: Neuen Record erstellen
    if (isNew && field === 'MA_ID' && value) {
        await createNewZuordnung(vastartId, parseInt(value), el);
        return;
    }

    // Existierender Record: Update via API
    if (id) {
        try {
            // Browser-Modus: REST-API
            const isBrowserMode = !(window.chrome && window.chrome.webview);
            if (isBrowserMode) {
                const response = await fetch(`http://localhost:5000/api/zuordnungen/${id}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ [field]: value })
                });
                if (!response.ok) {
                    console.error('[sub_MA_VA_Zuordnung] Update fehlgeschlagen');
                }
            } else {
                Bridge.sendEvent('updateRecord', {
                    table: 'tbl_MA_VA_Planung',
                    id: id,
                    field: field,
                    value: value
                });
            }
        } catch (e) {
            console.error('[sub_MA_VA_Zuordnung] Update-Fehler:', e);
        }

        // Lokalen Record aktualisieren
        const rec = state.records.find(r => r.ID == id);
        if (rec) rec[field] = value;
    }

    notifyParentChanged();
}

/**
 * Neue MA-Zuordnung erstellen (wenn MA auf leerer Schicht-Zeile ausgewählt wird)
 */
async function createNewZuordnung(vastartId, maId, selectElement) {
    if (!vastartId || !maId) return;

    const row = selectElement.closest('tr');
    const idx = parseInt(row.dataset.index);
    const rec = state.records[idx];

    if (!rec) return;

    const newData = {
        VA_ID: state.VA_ID,
        VADatum_ID: state.VADatum_ID,
        VAStart_ID: parseInt(vastartId),
        MA_ID: maId,
        MVA_Start: rec.MA_Start,
        MVA_Ende: rec.MA_Ende,
        Bemerkungen: rec.Bemerkungen || '',
        PKW: rec.PKW || 0,
        Einsatzleitung: rec.Einsatzleitung || false,
        IstFraglich: rec.IstFraglich || false
    };

    console.log('[sub_MA_VA_Zuordnung] Erstelle neue Zuordnung:', newData);

    try {
        const isBrowserMode = !(window.chrome && window.chrome.webview);
        if (isBrowserMode) {
            const response = await fetch('http://localhost:5000/api/zuordnungen', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(newData)
            });

            if (response.ok) {
                const result = await response.json();
                console.log('[sub_MA_VA_Zuordnung] Zuordnung erstellt:', result);
                // Daten neu laden um ID zu bekommen
                loadData();
            } else {
                console.error('[sub_MA_VA_Zuordnung] Erstellen fehlgeschlagen');
            }
        } else {
            Bridge.sendEvent('insertRecord', {
                table: 'tbl_MA_VA_Planung',
                data: newData
            });
            loadData();
        }
    } catch (e) {
        console.error('[sub_MA_VA_Zuordnung] Fehler beim Erstellen:', e);
    }

    notifyParentChanged();
}

/**
 * Checkbox-Änderung verarbeiten
 */
function handleCheckboxChange(event) {
    const cb = event.target;
    const field = cb.dataset.field;
    const id = cb.dataset.id;
    const value = cb.checked;

    Bridge.sendEvent('updateRecord', {
        table: 'tbl_MA_VA_Planung',
        id: id,
        field: field,
        value: value
    });

    // Lokalen Record aktualisieren
    const rec = state.records.find(r => r.ID == id);
    if (rec) rec[field] = value;

    // Zeilen-Klasse aktualisieren bei Einsatzleitung, PKW, IstFraglich
    const row = cb.closest('tr');
    if (field === 'Einsatzleitung') row.classList.toggle('is-el', value);
    if (field === 'PKW') row.classList.toggle('has-pkw', value);
    // IstFraglich = True → türkisblaue Hintergrundfarbe (Access: BackColor = 16777088)
    if (field === 'IstFraglich') row.classList.toggle('ist-fraglich', value);

    notifyParentChanged();
}

/**
 * Neue Zeile hinzufügen
 */
function addNewRow() {
    const maId = cboMASelect.value;
    const startInput = document.getElementById('new_MA_Start');
    const endeInput = document.getElementById('new_MA_Ende');

    if (!maId) {
        alert('Bitte Mitarbeiter auswählen');
        cboMASelect.focus();
        return;
    }

    // Nächste PosNr ermitteln
    const maxPosNr = state.records.reduce((max, r) => Math.max(max, r.PosNr || 0), 0);

    const newRecord = {
        VA_ID: state.VA_ID,
        VADatum_ID: state.VADatum_ID,
        MA_ID: parseInt(maId),
        MA_Start: parseTime(startInput.value) || null,
        MA_Ende: parseTime(endeInput.value) || null,
        PosNr: maxPosNr + 1,
        PKW: false,
        Einsatzleitung: false,
        IstFraglich: false
    };

    Bridge.sendEvent('insertRecord', {
        table: 'tbl_MA_VA_Planung',
        data: newRecord
    });

    // Inputs leeren
    cboMASelect.value = '';
    startInput.value = '';
    endeInput.value = '';

    // Neu laden
    loadData();

    notifyParentChanged();
}

/**
 * Parent über Änderung informieren
 */
function notifyParentChanged() {
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_changed',
            name: 'sub_MA_VA_Zuordnung'
        }, '*');
    }
}

/**
 * Spalte ein-/ausblenden
 */
function setColumnHidden(columnClass, hidden) {
    document.querySelectorAll(`.${columnClass}`).forEach(el => {
        el.style.display = hidden ? 'none' : '';
    });
}

/**
 * Recalc - Neuberechnung
 */
function recalc() {
    loadData();
}

/**
 * Zeit formatieren
 */
function formatTime(value) {
    if (!value) return '';

    // ISO-String mit T erkennen (z.B. "1899-12-30T15:00:00")
    if (typeof value === 'string' && value.includes('T')) {
        const date = new Date(value);
        if (!isNaN(date)) {
            return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
        }
    }

    // Bereits formatierte Zeit (z.B. "15:00")
    if (typeof value === 'string' && /^\d{1,2}:\d{2}$/.test(value)) return value;

    // Dezimalwert (Access-typisch, z.B. 0.5 = 12:00)
    if (typeof value === 'number' && value < 1) {
        const hours = Math.floor(value * 24);
        const mins = Math.round((value * 24 - hours) * 60);
        return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
    }

    const date = new Date(value);
    if (isNaN(date)) return value;

    return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

/**
 * Zeit parsen
 */
function parseTime(value) {
    if (!value) return null;

    const match = value.match(/^(\d{1,2}):(\d{2})$/);
    if (match) {
        const h = parseInt(match[1]);
        const m = parseInt(match[2]);
        return h + m / 60;
    }

    return value;
}

/**
 * Schicht formatieren
 */
function formatSchicht(vaStartId) {
    // TODO: Lookup für Schicht-Zeiten
    return vaStartId || '';
}

/**
 * Dezimalzahl formatieren
 */
function formatDecimal(value) {
    if (!value && value !== 0) return '';
    return parseFloat(value).toFixed(2);
}

/**
 * Währung formatieren (Euro)
 */
function formatCurrency(value) {
    if (!value && value !== 0) return '';
    const num = parseFloat(value);
    if (isNaN(num) || num === 0) return '';
    return num.toFixed(2).replace('.', ',') + ' €';
}

/**
 * Stunden aus Start/Ende berechnen
 */
function calculateHours(startVal, endVal) {
    if (!startVal || !endVal) return null;

    const parseTimeValue = (val) => {
        if (typeof val === 'string' && val.includes('T')) {
            const date = new Date(val);
            return date.getHours() + date.getMinutes() / 60;
        }
        if (typeof val === 'number' && val < 1) {
            return val * 24;
        }
        if (typeof val === 'string' && /^\d{1,2}:\d{2}$/.test(val)) {
            const [h, m] = val.split(':').map(Number);
            return h + m / 60;
        }
        return null;
    };

    const start = parseTimeValue(startVal);
    const end = parseTimeValue(endVal);

    if (start === null || end === null) return null;

    let hours = end - start;
    if (hours < 0) hours += 24; // Über Mitternacht
    return hours;
}

// API für Parent-Formular
window.SubMAVAZuordnung = {
    setLinkParams(VA_ID, VADatum_ID) {
        state.VA_ID = VA_ID;
        state.VADatum_ID = VADatum_ID;
        loadData();
    },
    requery: loadData,
    recalc: recalc,
    getSelectedRecord() {
        return state.records[state.selectedIndex] || null;
    },
    setColumnHidden: setColumnHidden
};

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);
