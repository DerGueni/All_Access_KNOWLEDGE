/**
 * sub_DP_Grund_MA.logic.js
 * Logik fuer Dienstplan-Gruende pro Mitarbeiter Subform
 */

import { Bridge } from '../api/bridgeClient.js';

const state = {
    MA_ID: null,
    records: [],
    isEmbedded: false
};

let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Gruende_MA');
    state.isEmbedded = window.parent !== window;

    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_DP_Grund_MA' }, '*');
    }
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'set_link_params':
            if (data.MA_ID !== undefined) state.MA_ID = data.MA_ID;
            loadData();
            break;
        case 'requery':
            loadData();
            break;
    }
}

async function loadData() {
    if (!state.MA_ID) {
        renderEmpty();
        return;
    }

    try {
        const result = await Bridge.query(`
            SELECT g.*, ma.Nachname, ma.Vorname
            FROM tbl_DP_Grund_MA g
            LEFT JOIN tbl_MA_Mitarbeiterstamm ma ON g.MA_ID = ma.ID
            WHERE g.MA_ID = ${state.MA_ID}
            ORDER BY g.Datum DESC
        `);

        state.records = result.data || [];
        render();
    } catch (error) {
        console.error('[sub_DP_Grund_MA] Fehler:', error);
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        renderEmpty();
        return;
    }

    tbody.innerHTML = state.records.map(rec => {
        const datum = rec.Datum ? new Date(rec.Datum).toLocaleDateString('de-DE') : '';
        return `
            <tr data-id="${rec.ID}">
                <td>${datum}</td>
                <td>${rec.Grund_Bez || ''}</td>
                <td>${rec.Bemerkung || ''}</td>
            </tr>
        `;
    }).join('');
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="3" style="text-align:center;color:#666;padding:20px;">Keine Eintraege</td></tr>';
}

window.SubDPGrundMA = {
    setLinkParams(MA_ID) {
        state.MA_ID = MA_ID;
        loadData();
    },
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
