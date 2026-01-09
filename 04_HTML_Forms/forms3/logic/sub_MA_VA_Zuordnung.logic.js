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
    records: [],
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
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_VA_Zuordnung' }, '*');
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
    if (!data || !data.type) return;

    switch (data.type) {
        case 'set_link_params':
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
 * Bei Veranstalter_ID = 20760: PKW und Einsatzleitung ausblenden
 */
function handleVeranstalterChange(veranstalterId) {
    const isPKWHidden = veranstalterId === 20760;
    setColumnHidden('col-pkw', isPKWHidden);
    setColumnHidden('col-el', isPKWHidden);
}

/**
 * MA-Lookup laden via WebView2-Bridge
 */
function loadMALookup() {
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
            MA_Brutto_Std: rec.MVP_MA_Brutto_Std || rec.MA_Brutto_Std
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
 * Daten laden via WebView2-Bridge
 */
function loadData() {
    if (!state.VA_ID) {
        renderEmpty();
        return;
    }

    Bridge.sendEvent('loadSubformData', {
        type: 'ma_va_zuordnung',
        va_id: state.VA_ID,
        vadatum_id: state.VADatum_ID
    });
}

/**
 * Daten rendern
 */
function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        renderEmpty();
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        const rowClass = getRowClass(rec, idx);
        const maName = getMAName(rec.MA_ID);

        return `
            <tr data-index="${idx}" data-id="${rec.ID}" class="${rowClass}">
                <td class="col-hidden">${rec.ID || ''}</td>
                <td class="col-hidden">${rec.VA_ID || ''}</td>
                <td class="col-lfd">${rec.PosNr || ''}</td>
                <td class="col-time">
                    <input type="text" value="${formatTime(rec.MA_Start)}"
                           data-field="MA_Start" data-id="${rec.ID}">
                </td>
                <td class="col-time">
                    <input type="text" value="${formatTime(rec.MA_Ende)}"
                           data-field="MA_Ende" data-id="${rec.ID}">
                </td>
                <td class="col-ma">
                    <select data-field="MA_ID" data-id="${rec.ID}">
                        ${renderMAOptions(rec.MA_ID)}
                    </select>
                </td>
                <td class="col-pkw">
                    <input type="checkbox" ${rec.PKW ? 'checked' : ''}
                           data-field="PKW" data-id="${rec.ID}">
                </td>
                <td class="col-hidden">${rec.VADatum_ID || ''}</td>
                <td class="col-schicht">
                    ${formatSchicht(rec.VAStart_ID)}
                </td>
                <td class="col-bemerk">
                    <input type="text" value="${rec.Bemerkungen || ''}"
                           data-field="Bemerkungen" data-id="${rec.ID}">
                </td>
                <td class="col-el">
                    <input type="checkbox" ${rec.Einsatzleitung ? 'checked' : ''}
                           data-field="Einsatzleitung" data-id="${rec.ID}">
                </td>
                <td class="col-info">
                    <input type="checkbox" ${rec.IstFraglich ? 'checked' : ''}
                           data-field="IstFraglich" data-id="${rec.ID}" title="Informieren">
                </td>
                <td class="col-preis">${rec.PreisArt_ID || ''}</td>
                <td class="col-pkwanz cell-number">${rec.PKW_Anzahl || ''}</td>
                <td class="col-std cell-number">${formatDecimal(rec.MA_Brutto_Std)}</td>
            </tr>
        `;
    }).join('');

    // Event Listener für Zeilen
    attachRowListeners();
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
 */
function handleFieldChange(event) {
    const el = event.target;
    const field = el.dataset.field;
    const id = el.dataset.id;
    let value = el.value;

    // Zeit-Felder konvertieren
    if (field === 'MA_Start' || field === 'MA_Ende') {
        value = parseTime(value);
    }

    Bridge.sendEvent('updateRecord', {
        table: 'tbl_MA_VA_Planung',
        id: id,
        field: field,
        value: value
    });

    // Lokalen Record aktualisieren
    const rec = state.records.find(r => r.ID == id);
    if (rec) rec[field] = value;

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
    if (typeof value === 'string' && value.includes(':')) return value;

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
