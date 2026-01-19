/**
 * frm_lst_row_auftrag.logic.js
 * Auftragsliste (keine LinkMaster/LinkChild, aber dynamische RecordSource)
 */
import { Bridge } from '../../../api/bridgeClient.js';

const state = { records: [], selectedIndex: -1, selectedId: null, isEmbedded: false, filter: {} };
let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Auftraege');
    state.isEmbedded = window.parent !== window;

    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'zsub_lstAuftrag' }, '*');
    }

    loadData();
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

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
    }
}

async function loadData() {
    try {
        const result = await Bridge.execute('loadAuftragsliste', {
            filter: state.filter
        });
        state.records = result.data || [];
        render();
    } catch (error) {
        console.error('[Auftragsliste] Fehler:', error);
        renderEmpty();
    }
}

function render() {
    if (!tbody) return;
    if (state.records.length === 0) { renderEmpty(); return; }

    tbody.innerHTML = state.records.map((rec, idx) => {
        // API-Felder haben VA_* Präfix
        const id = rec.VA_ID || rec.ID;
        const datum = rec.VA_DatumVon || rec.Datum;
        const auftrag = rec.VA_Bezeichnung || rec.Auftrag || '';
        const objekt = rec.VA_Objekt || rec.Objekt || '';
        const ort = rec.VA_Ort || rec.Ort || '';
        const soll = rec.Soll || 0;
        const ist = rec.Ist || 0;

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
    `}).join('');

    // Click-Listener
    tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => selectRow(parseInt(row.dataset.index)));
        row.addEventListener('dblclick', () => openAuftrag(row.dataset.id));
    });
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#666;padding:20px;">Keine Aufträge</td></tr>';
}

function selectRow(index) {
    const record = state.records[index] || {};
    const selectedId = record.VA_ID || record.ID;
    state.selectedIndex = index;
    state.selectedId = selectedId;

    tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'zsub_lstAuftrag',
            record: record
        }, '*');
    }
}

function openAuftrag(id) {
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'open_auftrag',
            name: 'zsub_lstAuftrag',
            id: id
        }, '*');
    }
}

function gotoRecord(id) {
    const idx = state.records.findIndex(r => (r.VA_ID || r.ID) == id);
    if (idx >= 0) {
        selectRow(idx);
        // Scroll in Sicht
        const row = tbody.querySelector(`tr[data-id="${id}"]`);
        row?.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function getSollIstClass(soll, ist) {
    if (!soll || soll === 0) return '';
    if (ist >= soll) return 'soll-ok';
    if (ist > 0) return 'soll-warn';
    return 'soll-err';
}

function formatDate(value) {
    if (!value) return '';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit' });
}

window.LstRowAuftrag = {
    requery: loadData,
    recalc: render,
    setFilter(filter) { state.filter = filter; loadData(); },
    gotoRecord: gotoRecord,
    getSelectedId() { return state.selectedId; }
};

document.addEventListener('DOMContentLoaded', init);
