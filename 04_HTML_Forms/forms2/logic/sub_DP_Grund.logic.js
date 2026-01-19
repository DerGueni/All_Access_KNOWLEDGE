/**
 * sub_DP_Grund.logic.js
 * Logik fuer Dienstplan-Gruende Subform
 */

import { Bridge } from '../api/bridgeClient.js';

const state = {
    records: [],
    isEmbedded: false
};

let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Gruende');
    state.isEmbedded = window.parent !== window;

    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_DP_Grund' }, '*');
    }

    loadData();
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    if (data.type === 'requery') {
        loadData();
    }
}

async function loadData() {
    try {
        const result = await Bridge.query(`
            SELECT * FROM tbl_DP_Grund
            ORDER BY Grund_ID
        `);

        state.records = result.data || [];
        render();
    } catch (error) {
        console.error('[sub_DP_Grund] Fehler:', error);
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" style="text-align:center;color:#666;padding:20px;">Keine Gruende vorhanden</td></tr>';
        return;
    }

    tbody.innerHTML = state.records.map(rec => `
        <tr data-id="${rec.Grund_ID}">
            <td>${rec.Grund_ID}</td>
            <td>${rec.Grund_Bez || ''}</td>
            <td>${rec.Grund_Kuerzel || ''}</td>
        </tr>
    `).join('');
}

window.SubDPGrund = {
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
