/**
 * sub_MA_Offene_Anfragen.logic.js
 * Logik fuer offene MA-Anfragen Subform
 */

import { Bridge } from '../js/webview2-bridge.js';

const state = {
    MA_ID: null,
    VA_ID: null,
    records: [],
    isEmbedded: false
};

let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Anfragen');
    state.isEmbedded = window.parent !== window;

    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_Offene_Anfragen' }, '*');
    }
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'set_link_params':
            if (data.MA_ID !== undefined) state.MA_ID = data.MA_ID;
            if (data.VA_ID !== undefined) state.VA_ID = data.VA_ID;
            loadData();
            break;
        case 'requery':
            loadData();
            break;
    }
}

async function loadData() {
    try {
        let query = `
            SELECT p.*, m.Nachname, m.Vorname, a.Objekt, a.Auftrag
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
            WHERE p.MVP_Status = 1
        `;

        if (state.MA_ID) {
            query += ` AND p.MA_ID = ${state.MA_ID}`;
        }
        if (state.VA_ID) {
            query += ` AND p.VA_ID = ${state.VA_ID}`;
        }

        query += ' ORDER BY p.VADatum, m.Nachname';

        const result = await Bridge.query(query);
        state.records = result.data || [];
        render();
    } catch (error) {
        console.error('[sub_MA_Offene_Anfragen] Fehler:', error);
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;color:#666;padding:20px;">Keine offenen Anfragen</td></tr>';
        return;
    }

    tbody.innerHTML = state.records.map(rec => {
        const datum = rec.VADatum ? new Date(rec.VADatum).toLocaleDateString('de-DE') : '';
        const name = `${rec.Nachname || ''}, ${rec.Vorname || ''}`;
        return `
            <tr data-id="${rec.ID}">
                <td>${datum}</td>
                <td>${name}</td>
                <td>${rec.Objekt || ''}</td>
                <td>${formatTime(rec.VA_Start)} - ${formatTime(rec.VA_Ende)}</td>
                <td>
                    <button class="btn btn-sm btn-success" onclick="SubOffeneAnfragen.zusagen(${rec.ID})">Zusage</button>
                    <button class="btn btn-sm btn-danger" onclick="SubOffeneAnfragen.absagen(${rec.ID})">Absage</button>
                </td>
            </tr>
        `;
    }).join('');
}

function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) return value.substring(0, 5);
    const date = new Date(value);
    if (isNaN(date)) return value;
    return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

async function zusagen(id) {
    try {
        await Bridge.anfragen.update(id, { status: 2 }); // 2 = Zusage
        loadData();
        notifyParent('anfrage_beantwortet');
    } catch (error) {
        alert('Fehler: ' + error.message);
    }
}

async function absagen(id) {
    try {
        await Bridge.anfragen.update(id, { status: 3 }); // 3 = Absage
        loadData();
        notifyParent('anfrage_beantwortet');
    } catch (error) {
        alert('Fehler: ' + error.message);
    }
}

function notifyParent(type) {
    if (state.isEmbedded) {
        window.parent.postMessage({ type, name: 'sub_MA_Offene_Anfragen' }, '*');
    }
}

window.SubOffeneAnfragen = {
    setLinkParams(MA_ID, VA_ID) {
        state.MA_ID = MA_ID;
        state.VA_ID = VA_ID;
        loadData();
    },
    requery: loadData,
    zusagen,
    absagen
};

document.addEventListener('DOMContentLoaded', init);
