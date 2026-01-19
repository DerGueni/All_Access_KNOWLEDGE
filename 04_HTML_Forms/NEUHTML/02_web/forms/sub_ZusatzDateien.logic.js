/**
 * sub_ZusatzDateien.logic.js
 * LinkMaster: Objekt_ID;TabellenNr | LinkChild: Ueberordnung;TabellenID
 */
import { Bridge } from '../js/webview2-bridge.js';

const state = { Objekt_ID: null, TabellenNr: 42, records: [], isEmbedded: false };
let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Zusatz');
    state.isEmbedded = window.parent !== window;
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_ZusatzDateien' }, '*');
    }
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;
    if (data.type === 'set_link_params') {
        if (data.Objekt_ID !== undefined) state.Objekt_ID = data.Objekt_ID;
        if (data.TabellenNr !== undefined) state.TabellenNr = data.TabellenNr;
        loadData();
    } else if (data.type === 'requery') {
        loadData();
    }
}

async function loadData() {
    if (!state.Objekt_ID) { renderEmpty(); return; }
    try {
        // REST-API: /api/query für Zusatzdateien
        const result = await Bridge.query(`
            SELECT * FROM tbl_Zusatzdateien
            WHERE Ueberordnung = ${state.Objekt_ID}
            AND TabellenID = ${state.TabellenNr}
            ORDER BY Dateiname
        `);
        state.records = result.data || [];
        render();
    } catch (error) {
        console.error('[ZusatzDateien] Fehler:', error);
        renderEmpty();
    }
}

function render() {
    if (!tbody) return;
    if (state.records.length === 0) { renderEmpty(); return; }
    tbody.innerHTML = state.records.map((rec, idx) => `
        <tr data-index="${idx}">
            <td class="col-hidden">${rec.ZusatzNr || ''}</td>
            <td class="col-hidden">${rec.TabellenID || ''}</td>
            <td class="col-hidden">${rec.Ueberordnung || ''}</td>
            <td class="col-datei" ondblclick="openFile('${rec.Dateiname}')">${rec.Dateiname || ''}</td>
            <td class="col-datum">${formatDate(rec.DFiledate)}</td>
            <td class="col-laenge">${formatSize(rec.DLaenge)}</td>
            <td class="col-typ">${rec.Texttyp || ''}</td>
            <td class="col-beschreib">${rec.Kurzbeschreibung || ''}</td>
        </tr>
    `).join('');
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:#666;padding:10px;">Keine Zusatzdateien</td></tr>';
}

function formatDate(value) {
    if (!value) return '';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE');
}

function formatSize(bytes) {
    if (!bytes) return '';
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024*1024) return (bytes/1024).toFixed(1) + ' KB';
    return (bytes/1024/1024).toFixed(1) + ' MB';
}

window.openFile = async function(filename) {
    try {
        await Bridge.execute('openFile', { filename: filename });
    } catch (e) {
        console.error('Fehler beim Öffnen:', e);
    }
};

window.SubZusatzDateien = {
    setLinkParams(Objekt_ID, TabellenNr) { state.Objekt_ID = Objekt_ID; state.TabellenNr = TabellenNr || 42; loadData(); },
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
