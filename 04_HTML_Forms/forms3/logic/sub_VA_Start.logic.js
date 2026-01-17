/**
 * sub_VA_Start.logic.js
 * Logik für Schichten-Subform (tbl_VA_Start)
 *
 * RecordSource: tbl_VA_Start
 * LinkMaster: ID;cboVADatum (vom Parent frm_va_Auftragstamm)
 * LinkChild: VA_ID;VADatum
 */

import { Bridge } from '../api/bridgeClient.js';

// Subform State
const state = {
    VA_ID: null,
    VADatum: null,
    records: [],
    selectedIndex: -1,
    selectedRecord: null,
    isEmbedded: false
};

// DOM Elements
let tbody = null;

/**
 * Initialisierung
 */
function init() {
    tbody = document.getElementById('tbody_VA_Start');

    // Prüfen ob embedded (in iframe)
    state.isEmbedded = window.parent !== window;

    // Event Listener
    document.getElementById('btnAddRow')?.addEventListener('click', addNewRow);

    // Wenn embedded, auf Parent-Messages hören
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        // Parent informieren dass bereit
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_VA_Start' }, '*');
    }

    console.log('[sub_VA_Start] Initialisiert, embedded:', state.isEmbedded);
}

/**
 * Nachrichten vom Parent-Formular verarbeiten
 */
function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'set_link_params':
            // LinkMaster-Werte vom Parent
            if (data.VA_ID !== undefined) state.VA_ID = data.VA_ID;
            if (data.VADatum !== undefined) state.VADatum = data.VADatum;
            if (data.VADatum_ID !== undefined) state.VADatum = data.VADatum_ID;
            loadData();
            break;

        case 'requery':
            loadData();
            break;

        case 'recalc':
            recalc();
            break;
    }
}

/**
 * Daten laden via REST-API
 */
async function loadData() {
    if (!state.VA_ID) {
        renderEmpty();
        return;
    }

    try {
        // REST-API: /api/query mit SQL
        const result = await Bridge.query(`
            SELECT s.*, d.VADatum
            FROM tbl_VA_Start s
            INNER JOIN tbl_VA_Datum d ON s.VAS_VADatum_ID = d.VADatum_ID
            WHERE d.VADatum_VA_ID = ${state.VA_ID}
            ${state.VADatum ? `AND d.VADatum = #${state.VADatum}#` : ''}
            ORDER BY d.VADatum, s.VAS_Von
        `);

        state.records = result.data || [];
        render();

    } catch (error) {
        console.error('[sub_VA_Start] Fehler beim Laden:', error);
        renderError(error.message);
    }
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
        // API-Felder: VAS_* Präfix
        const id = rec.VAS_ID || rec.ID;
        const von = rec.VAS_Von || rec.VA_Start;
        const bis = rec.VAS_Bis || rec.VA_Ende;
        const soll = rec.VAS_Soll || rec.MA_Anzahl || 0;
        const ist = rec.VAS_Ist || rec.MA_Anzahl_Ist || 0;

        const istClass = getStatusClass(soll, ist);
        return `
            <tr data-index="${idx}" data-id="${id}" class="${idx === state.selectedIndex ? 'selected' : ''}">
                <td>
                    <input type="text" value="${formatTime(von)}"
                           data-field="VAS_Von" data-id="${id}" class="time-input">
                </td>
                <td>
                    <input type="text" value="${formatTime(bis)}"
                           data-field="VAS_Bis" data-id="${id}" class="time-input">
                </td>
                <td class="cell-number">
                    <input type="text" value="${soll}"
                           data-field="VAS_Soll" data-id="${id}" class="number-input">
                </td>
                <td class="cell-number cell-readonly ${istClass}">
                    ${ist}
                </td>
            </tr>
        `;
    }).join('');

    // Event Listener für Zeilen
    tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => selectRow(parseInt(row.dataset.index)));
    });

    // Event Listener für Inputs
    tbody.querySelectorAll('input').forEach(input => {
        input.addEventListener('change', handleFieldChange);
        input.addEventListener('focus', () => selectRow(parseInt(input.closest('tr').dataset.index)));
    });
}

/**
 * Leere Ansicht
 */
function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = `
        <tr>
            <td colspan="4" style="text-align:center; color:#666; padding:20px;">
                Keine Schichten vorhanden
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
            <td colspan="4" style="text-align:center; color:#dc3545; padding:20px;">
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
    state.selectedRecord = state.records[index] || null;

    tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    // Parent informieren - Schicht wurde gewählt
    if (state.isEmbedded && state.selectedRecord) {
        const rec = state.selectedRecord;
        window.parent.postMessage({
            type: 'schicht_selected',
            name: 'sub_VA_Start',
            VAStart_ID: rec.VAS_ID || rec.ID,
            VADatum: rec.VADatum,
            record: rec
        }, '*');
    }
}

/**
 * Feldänderung verarbeiten
 */
async function handleFieldChange(event) {
    const input = event.target;
    const field = input.dataset.field;
    const id = input.dataset.id;
    const value = input.value;

    try {
        await Bridge.execute('updateField', {
            table: 'tbl_VA_Start',
            id: id,
            field: field,
            value: field.includes('VA_') ? parseTime(value) : value
        });

        // Lokalen Record aktualisieren
        const rec = state.records.find(r => r.ID == id);
        if (rec) rec[field] = value;

        // Parent informieren (Recalc auslösen)
        if (state.isEmbedded) {
            window.parent.postMessage({
                type: 'subform_changed',
                name: 'sub_VA_Start'
            }, '*');
        }

    } catch (error) {
        console.error('[sub_VA_Start] Fehler beim Speichern:', error);
        // Wert zurücksetzen
        const rec = state.records.find(r => r.ID == id);
        if (rec) input.value = rec[field];
    }
}

/**
 * Neue Zeile hinzufügen
 */
async function addNewRow() {
    const startInput = document.getElementById('new_VA_Start');
    const endeInput = document.getElementById('new_VA_Ende');
    const anzahlInput = document.getElementById('new_MA_Anzahl');

    const newRecord = {
        VA_ID: state.VA_ID,
        VADatum_ID: state.VADatum_ID,
        VA_Start: parseTime(startInput.value),
        VA_Ende: parseTime(endeInput.value),
        MA_Anzahl: parseInt(anzahlInput.value) || 1,
        MA_Anzahl_Ist: 0
    };

    try {
        const result = await Bridge.execute('insertRecord', {
            table: 'tbl_VA_Start',
            data: newRecord
        });

        // Inputs leeren
        startInput.value = '';
        endeInput.value = '';
        anzahlInput.value = '';

        // Neu laden
        await loadData();

        // Parent informieren
        if (state.isEmbedded) {
            window.parent.postMessage({
                type: 'subform_changed',
                name: 'sub_VA_Start'
            }, '*');
        }

    } catch (error) {
        console.error('[sub_VA_Start] Fehler beim Einfügen:', error);
    }
}

/**
 * Recalc - Neuberechnung ohne Reload
 */
function recalc() {
    // MA_Anzahl_Ist könnte sich geändert haben
    loadData();
}

/**
 * Zeit formatieren (Date zu HH:MM)
 */
function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) return value;

    const date = new Date(value);
    if (isNaN(date)) return value;

    return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

/**
 * Zeit parsen (HH:MM zu Dezimal oder Date)
 */
function parseTime(value) {
    if (!value) return null;

    // Format HH:MM
    const match = value.match(/^(\d{1,2}):(\d{2})$/);
    if (match) {
        const h = parseInt(match[1]);
        const m = parseInt(match[2]);
        // Als Dezimalwert (Access-typisch)
        return h + m / 60;
    }

    return value;
}

/**
 * Status-Klasse basierend auf Soll/Ist
 */
function getStatusClass(soll, ist) {
    if (!soll || soll === 0) return '';
    if (ist >= soll) return 'status-ok';
    if (ist > 0) return 'status-warning';
    return 'status-error';
}

// API für Parent-Formular (wenn nicht embedded)
window.SubVAStart = {
    setLinkParams(VA_ID, VADatum_ID) {
        state.VA_ID = VA_ID;
        state.VADatum_ID = VADatum_ID;
        loadData();
    },
    requery: loadData,
    recalc: recalc,
    getSelectedRecord() {
        return state.records[state.selectedIndex] || null;
    }
};

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);
