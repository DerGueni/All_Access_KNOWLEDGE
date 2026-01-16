/**
 * sub_rch_Pos.logic.js
 * Logik fuer Rechnungspositionen Subform
 *
 * VBA-Events:
 * - Row Click: Position auswählen
 * - DblClick: Position bearbeiten
 * - AfterUpdate: Summen neu berechnen
 * - OnCurrent: Aktuelle Position markieren
 */

const state = {
    RCH_ID: null,
    records: [],
    selectedIndex: -1,
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

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
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

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_rch_Pos] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        try {
            const url = `http://localhost:5000/api/rechnungen/${state.RCH_ID}/positionen`;
            console.log('[sub_rch_Pos] Fetch:', url);
            const response = await fetch(url);
            const result = await response.json();
            handleDataReceived({ type: 'rch_positionen', records: result.data || [] });
        } catch (error) {
            console.error('[sub_rch_Pos] API-Fehler:', error);
            renderEmpty();
        }
    }
    // Fallback: WebView2-Bridge (wenn verfügbar)
    else if (window.Bridge) {
        /* Bridge.sendEvent('loadSubformData', {
            type: 'rch_positionen',
            rch_id: state.RCH_ID
        }); */
    }
}

function handleDataReceived(data) {
    if (data.type === 'rch_positionen') {
        state.records = data.records || [];
        render();
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        renderEmpty();
        return;
    }

    let summe = 0;
    tbody.innerHTML = state.records.map((rec, idx) => {
        const betrag = (rec.Menge || 0) * (rec.Einzelpreis || 0);
        summe += betrag;
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        return `
            <tr data-id="${rec.ID}" data-index="${idx}" class="${selectedClass}">
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

    // Event Listener für Zeilen binden
    attachRowListeners();

    // Parent über Summe informieren
    notifyParentSum(summe);
}

/**
 * Event Listener an Zeilen binden (VBA-Events)
 */
function attachRowListeners() {
    tbody.querySelectorAll('tr[data-index]').forEach(row => {
        const idx = parseInt(row.dataset.index);

        // Row Click (VBA: OnClick)
        row.addEventListener('click', () => {
            selectRow(idx);
        });

        // Row DblClick (VBA: OnDblClick - Position bearbeiten)
        row.addEventListener('dblclick', () => {
            const rec = state.records[idx];
            if (rec && state.isEmbedded) {
                window.parent.postMessage({
                    type: 'row_dblclick',
                    name: 'sub_rch_Pos',
                    record: rec,
                    action: 'edit_position'
                }, '*');
            }
        });
    });
}

/**
 * Zeile auswählen (VBA: OnCurrent)
 */
function selectRow(index) {
    state.selectedIndex = index;
    tbody.querySelectorAll('tr[data-index]').forEach((row, idx) => {
        row.classList.toggle('selected', parseInt(row.dataset.index) === index);
    });

    // Parent informieren
    if (state.isEmbedded && state.records[index]) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'sub_rch_Pos',
            record: state.records[index]
        }, '*');
    }
}

/**
 * Parent über Summenänderung informieren (VBA: AfterUpdate -> Recalc)
 */
function notifyParentSum(summe) {
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'sum_changed',
            name: 'sub_rch_Pos',
            summe: summe,
            anzahl: state.records.length
        }, '*');
    }
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
