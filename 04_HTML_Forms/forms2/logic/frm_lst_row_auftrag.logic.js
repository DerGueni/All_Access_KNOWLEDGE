/**
 * frm_lst_row_auftrag.logic.js
 * Vollständige REST-API Anbindung für Auftragsliste
 * API-Basis: http://localhost:5000/api
 */

const API_BASE = 'http://localhost:5000/api';

const state = {
    records: [],
    selectedIndex: -1,
    selectedId: null,
    isEmbedded: false,
    filter: {}
};

let tbody = null;

/**
 * Initialisierung
 */
function init() {
    console.log('[Auftragsliste] Initialisierung...');

    tbody = document.getElementById('tbody_Auftraege');
    state.isEmbedded = window.parent !== window;

    // PostMessage-Listener für Embedded-Mode
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'frm_lst_row_auftrag' }, '*');
    }

    // Daten laden
    loadData();
}

/**
 * Parent-Messages verarbeiten
 */
function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    console.log('[Auftragsliste] Parent-Message:', data.type);

    switch (data.type) {
        case 'requery':
            loadData();
            break;
        case 'recalc':
            render();
            break;
        case 'set_filter':
            state.filter = data.filter || {};
            loadData();
            break;
        case 'goto_record':
            gotoRecord(data.id);
            break;
        case 'load_for_kunde':
            loadForKunde(data.kunde_id, data.von, data.bis);
            break;
    }
}

/**
 * Aufträge von REST API laden
 */
async function loadData() {
    try {
        console.log('[Auftragsliste] Lade Aufträge...');

        // Query-Parameter aufbauen
        const params = new URLSearchParams();

        if (state.filter.kunde_id) params.append('kunde_id', state.filter.kunde_id);
        if (state.filter.von) params.append('von', state.filter.von);
        if (state.filter.bis) params.append('bis', state.filter.bis);
        if (state.filter.status) params.append('status', state.filter.status);
        if (state.filter.objekt_id) params.append('objekt_id', state.filter.objekt_id);

        const url = `${API_BASE}/auftraege${params.toString() ? '?' + params.toString() : ''}`;

        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        state.records = data.data || data || [];

        console.log(`[Auftragsliste] ${state.records.length} Aufträge geladen`);

        render();
    } catch (error) {
        console.error('[Auftragsliste] Fehler beim Laden:', error);
        renderError(error.message);
    }
}

/**
 * Aufträge für Kunde laden
 */
async function loadForKunde(kundeId, von = null, bis = null) {
    state.filter = {
        kunde_id: kundeId,
        von: von,
        bis: bis
    };
    await loadData();
}

/**
 * Tabelle rendern
 */
function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        renderEmpty();
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        // Felder aus API-Antwort
        const id = rec.VA_ID || rec.Auftrag || rec.ID;
        const datum = rec.VADatum || rec.VA_DatumVon || rec.Datum;
        const auftrag = rec.Auftrag || rec.VA_Bezeichnung || '';
        const objekt = rec.Objekt || rec.Objekt_Name || rec.VA_Objekt || '';
        const ort = rec.Ort || rec.Objekt_Ort || rec.VA_Ort || '';
        const soll = rec.MA_Anzahl || rec.Soll || 0;
        const ist = rec.MA_Anzahl_Ist || rec.Ist || 0;

        const istClass = getSollIstClass(soll, ist);
        const selClass = idx === state.selectedIndex ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${id}" class="${selClass}">
                <td class="col-id">${id}</td>
                <td class="col-datum">${formatDate(datum)}</td>
                <td class="col-auftrag">${auftrag}</td>
                <td class="col-objekt">${objekt}</td>
                <td class="col-ort">${ort}</td>
                <td class="col-soll">${soll}</td>
                <td class="col-ist ${istClass}">${ist}</td>
            </tr>
        `;
    }).join('');

    // Event-Listener für Zeilen
    tbody.querySelectorAll('tr').forEach(row => {
        const index = parseInt(row.dataset.index);
        const id = row.dataset.id;

        row.addEventListener('click', () => selectRow(index));
        row.addEventListener('dblclick', () => openAuftrag(id));
    });
}

/**
 * Leere Tabelle rendern
 */
function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = `
        <tr>
            <td colspan="7" style="text-align:center;color:#999;padding:20px;">
                Keine Aufträge gefunden
            </td>
        </tr>
    `;
}

/**
 * Fehler rendern
 */
function renderError(message) {
    if (!tbody) return;
    tbody.innerHTML = `
        <tr>
            <td colspan="7" style="text-align:center;color:red;padding:20px;">
                Fehler: ${message}
            </td>
        </tr>
    `;
}

/**
 * Zeile selektieren
 */
function selectRow(index) {
    state.selectedIndex = index;
    state.selectedId = state.records[index]?.VA_ID || state.records[index]?.ID;

    // Visuelle Selektion
    tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    // Parent benachrichtigen (wenn embedded)
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'frm_lst_row_auftrag',
            record: state.records[index]
        }, '*');
    }
}

/**
 * Auftrag öffnen
 */
function openAuftrag(id) {
    console.log(`[Auftragsliste] Öffne Auftrag ${id}`);

    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'open_auftrag',
            name: 'frm_lst_row_auftrag',
            id: id
        }, '*');
    } else {
        // Standalone: Navigation
        window.location.href = `frm_va_Auftragstamm.html?id=${id}`;
    }
}

/**
 * Zu Datensatz navigieren
 */
function gotoRecord(id) {
    const idx = state.records.findIndex(r => (r.VA_ID || r.ID) == id);
    if (idx >= 0) {
        selectRow(idx);
        // In Sicht scrollen
        const row = tbody.querySelector(`tr[data-id="${id}"]`);
        row?.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

/**
 * Soll/Ist CSS-Klasse ermitteln
 */
function getSollIstClass(soll, ist) {
    if (!soll || soll === 0) return '';
    if (ist >= soll) return 'soll-ok';
    if (ist > 0) return 'soll-warn';
    return 'soll-err';
}

/**
 * Datum formatieren
 */
function formatDate(value) {
    if (!value) return '';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

/**
 * Globale API für externe Nutzung
 */
window.LstRowAuftrag = {
    requery: loadData,
    recalc: render,
    setFilter(filter) {
        state.filter = filter;
        loadData();
    },
    loadForKunde: loadForKunde,
    gotoRecord: gotoRecord,
    getSelectedId() {
        return state.selectedId;
    },
    getSelectedRecord() {
        return state.records[state.selectedIndex];
    },
    getRecords() {
        return state.records;
    }
};

/**
 * Initialisierung beim DOM-Load
 */
document.addEventListener('DOMContentLoaded', init);
