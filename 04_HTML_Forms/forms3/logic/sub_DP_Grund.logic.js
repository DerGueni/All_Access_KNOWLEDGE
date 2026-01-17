/**
 * sub_DP_Grund.logic.js
 * Logik fuer Dienstplan-Gruende Subform
 *
 * VBA-Events:
 * - Row Click: Grund auswählen
 * - DblClick: Grund-Details anzeigen/bearbeiten
 * - OnCurrent: Aktuellen Grund markieren
 */

const state = {
    records: [],
    selectedIndex: -1,
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

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
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

function loadData() {
    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_DP_Grund] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        loadDataViaAPI();
    } else if (window.Bridge) {
        Bridge.sendEvent('loadSubformData', {
            type: 'dp_grund'
        });
    } else {
        console.warn('[sub_DP_Grund] Bridge nicht verfuegbar und isBrowserMode=false, warte...');
        setTimeout(loadData, 100);
    }
}

async function loadDataViaAPI() {
    try {
        const response = await fetch('http://localhost:5000/api/dienstplan/gruende');
        if (!response.ok) throw new Error(`API Fehler: ${response.status}`);

        const records = await response.json();
        console.log('[sub_DP_Grund] API Daten geladen:', records.length, 'Eintraege');

        state.records = records;
        render();
    } catch (err) {
        console.error('[sub_DP_Grund] API Fehler:', err);
        // Fallback: versuche Bridge
        if (window.Bridge) {
            console.log('[sub_DP_Grund] Fallback zu Bridge...');
            Bridge.sendEvent('loadSubformData', {
                type: 'dp_grund'
            });
        }
    }
}

function handleDataReceived(data) {
    if (data.type === 'dp_grund') {
        state.records = data.records || [];
        render();
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" style="text-align:center;color:#666;padding:20px;">Keine Gruende vorhanden</td></tr>';
        updateCount(0);
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        return `
        <tr data-id="${rec.Grund_ID}" data-index="${idx}" class="${selectedClass}">
            <td>${rec.Grund_ID}</td>
            <td>${rec.Grund_Bez || ''}</td>
            <td>${rec.Grund_Kuerzel || ''}</td>
        </tr>
    `}).join('');

    // Event Listener für Zeilen binden
    attachRowListeners();
    updateCount(state.records.length);
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

        // Row DblClick (VBA: OnDblClick)
        row.addEventListener('dblclick', () => {
            const rec = state.records[idx];
            if (rec && state.isEmbedded) {
                window.parent.postMessage({
                    type: 'row_dblclick',
                    name: 'sub_DP_Grund',
                    record: rec,
                    grund_id: rec.Grund_ID
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
    tbody.querySelectorAll('tr[data-index]').forEach((row) => {
        row.classList.toggle('selected', parseInt(row.dataset.index) === index);
    });

    // Parent informieren
    if (state.isEmbedded && state.records[index]) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'sub_DP_Grund',
            record: state.records[index]
        }, '*');
    }
}

/**
 * Anzahl aktualisieren
 */
function updateCount(count) {
    const lblAnzahl = document.getElementById('lblAnzahl');
    if (lblAnzahl) {
        lblAnzahl.textContent = `${count} Einträge`;
    }
}

window.SubDPGrund = {
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
