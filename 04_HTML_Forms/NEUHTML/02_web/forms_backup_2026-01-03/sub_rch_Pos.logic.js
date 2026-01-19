/**
 * sub_rch_Pos.logic.js
 * Logik fuer Rechnungspositionen Subform
 */

import { Bridge } from '../api/bridgeClient.js';

const state = {
    RCH_ID: null,
    records: [],
    isEmbedded: false
};

let tbody = null;

function init() {
    tbody = document.getElementById('tbody_RCH_Pos');
    state.isEmbedded = window.parent !== window;

    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_rch_Pos' }, '*');
    }
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'set_link_params':
            if (data.RCH_ID !== undefined) state.RCH_ID = data.RCH_ID;
            loadData();
            break;
        case 'requery':
            loadData();
            break;
    }
}

async function loadData() {
    if (!state.RCH_ID) {
        renderEmpty();
        return;
    }

    try {
        const result = await Bridge.query(`
            SELECT * FROM tbl_RCH_Position
            WHERE RCH_ID = ${state.RCH_ID}
            ORDER BY Pos_Nr
        `);

        state.records = result.data || [];
        render();
    } catch (error) {
        console.error('[sub_rch_Pos] Fehler:', error);
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        renderEmpty();
        return;
    }

    let summe = 0;
    tbody.innerHTML = state.records.map(rec => {
        const betrag = (rec.Menge || 0) * (rec.Einzelpreis || 0);
        summe += betrag;
        return `
            <tr data-id="${rec.ID}">
                <td>${rec.Pos_Nr || ''}</td>
                <td>${rec.Bezeichnung || ''}</td>
                <td class="text-right">${formatNumber(rec.Menge)}</td>
                <td class="text-right">${formatCurrency(rec.Einzelpreis)}</td>
                <td class="text-right">${formatCurrency(betrag)}</td>
            </tr>
        `;
    }).join('');

    // Summenzeile
    tbody.innerHTML += `
        <tr class="summe-row">
            <td colspan="4" class="text-right"><strong>Summe:</strong></td>
            <td class="text-right"><strong>${formatCurrency(summe)}</strong></td>
        </tr>
    `;
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;color:#666;padding:20px;">Keine Positionen</td></tr>';
}

function formatNumber(value) {
    if (!value && value !== 0) return '';
    return Number(value).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function formatCurrency(value) {
    if (!value && value !== 0) return '';
    return Number(value).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' EUR';
}

window.SubRchPos = {
    setLinkParams(RCH_ID) {
        state.RCH_ID = RCH_ID;
        loadData();
    },
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
