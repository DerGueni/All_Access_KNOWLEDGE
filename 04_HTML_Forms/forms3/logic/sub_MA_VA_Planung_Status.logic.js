/**
 * sub_MA_VA_Planung_Status.logic.js
 * Logik für Antworten ausstehend Subform
 * LinkMaster: ID;cboVADatum | LinkChild: VA_ID;VADatum_ID
 *
 * VBA-Events (aus Access-Export frm_va_Auftragstamm):
 * - Subform wird bei cboVADatum_AfterUpdate neu geladen
 * - OnCurrent: Statusanzeige aktualisieren
 * - Row Click: Zeile auswählen und Parent informieren
 * - DblClick: MA-Details öffnen
 */

const state = { VA_ID: null, VADatum_ID: null, records: [], selectedIndex: -1, isEmbedded: false };
let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Status');
    state.isEmbedded = window.parent !== window;
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_VA_Planung_Status' }, '*');
    }

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
    }

    console.log('[sub_MA_VA_Planung_Status] Initialisiert, embedded:', state.isEmbedded);
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;
    if (data.type === 'set_link_params') {
        if (data.VA_ID !== undefined) state.VA_ID = data.VA_ID;
        if (data.VADatum_ID !== undefined) state.VADatum_ID = data.VADatum_ID;
        loadData();
    } else if (data.type === 'requery') {
        loadData();
    }
}

async function loadData() {
    if (!state.VA_ID) { renderEmpty(); return; }

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_MA_VA_Planung_Status] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        try {
            let url = `http://localhost:5000/api/auftraege/${state.VA_ID}/absagen`;
            if (state.VADatum_ID) {
                url += `?vadatum_id=${state.VADatum_ID}`;
            }
            console.log('[sub_MA_VA_Planung_Status] Fetch:', url);
            const response = await fetch(url);
            const result = await response.json();
            handleDataReceived({ type: 'ma_va_planung_status', records: result.data || [] });
        } catch (error) {
            console.error('[sub_MA_VA_Planung_Status] API-Fehler:', error);
            renderEmpty();
        }
    }
    // Fallback: WebView2-Bridge (wenn verfügbar)
    else if (window.Bridge) {
        /* Bridge.sendEvent('loadSubformData', {
            type: 'ma_va_planung_status',
            va_id: state.VA_ID,
            vadatum_id: state.VADatum_ID,
            status: 'Offen'
        }); */
    }
}

function handleDataReceived(data) {
    if (data.type === 'ma_va_planung_status') {
        state.records = (data.records || []).map(rec => ({
            ID: rec.MVA_ID || rec.ID,
            PosNr: rec.MVA_PosNr || rec.PosNr,
            MA_ID: rec.MVA_MA_ID || rec.MA_ID,
            MA_Name: rec.MA_Name || `${rec.MA_Nachname || ''}, ${rec.MA_Vorname || ''}`.trim() || rec.MA_ID,
            VA_Start: rec.MVA_VA_Start || rec.VA_Start,
            VA_Ende: rec.MVA_VA_Ende || rec.VA_Ende,
            MA_Brutto_Std: rec.MVA_MA_Brutto_Std || rec.MA_Brutto_Std,
            Bemerkungen: rec.MVA_Bemerkungen || rec.Bemerkungen || '',
            Status: rec.MVA_Status || rec.Status || 'offen'
        }));
        render();
    }
}

function render() {
    if (!tbody) return;
    if (state.records.length === 0) { renderEmpty(); return; }
    tbody.innerHTML = state.records.map((rec, idx) => {
        const statusClass = getStatusClass(rec.Status);
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        return `
        <tr data-index="${idx}" data-id="${rec.ID}" class="${statusClass}${selectedClass}">
            <td class="col-hidden">${rec.ID || ''}</td>
            <td class="col-lfd">${rec.PosNr || ''}</td>
            <td class="col-ma">${rec.MA_Name || rec.MA_ID || ''}</td>
            <td class="col-time">${formatTime(rec.VA_Start)}</td>
            <td class="col-time">${formatTime(rec.VA_Ende)}</td>
            <td class="col-std">${rec.MA_Brutto_Std || ''}</td>
            <td class="col-bemerk">${rec.Bemerkungen || ''}</td>
            <td class="col-status">${rec.Status || 'offen'}</td>
        </tr>
    `}).join('');

    // Event Listener für Zeilen binden
    attachRowListeners();
}

/**
 * Event Listener an Zeilen binden (VBA-Events)
 */
function attachRowListeners() {
    tbody.querySelectorAll('tr').forEach(row => {
        // Row Click (VBA: OnClick)
        row.addEventListener('click', () => {
            selectRow(parseInt(row.dataset.index));
        });

        // Row DblClick (VBA: OnDblClick - öffnet MA-Details)
        row.addEventListener('dblclick', () => {
            const idx = parseInt(row.dataset.index);
            const rec = state.records[idx];
            if (rec && rec.MA_ID && state.isEmbedded) {
                window.parent.postMessage({
                    type: 'row_dblclick',
                    name: 'sub_MA_VA_Planung_Status',
                    record: rec,
                    ma_id: rec.MA_ID
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
    tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    // Parent informieren
    if (state.isEmbedded && state.records[index]) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'sub_MA_VA_Planung_Status',
            record: state.records[index]
        }, '*');
    }
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:#666;padding:10px;">Keine ausstehenden Antworten</td></tr>';
}

function getStatusClass(status) {
    if (!status) return 'status-offen';
    if (status.toLowerCase().includes('zusag')) return 'status-zugesagt';
    if (status.toLowerCase().includes('absag')) return 'status-abgesagt';
    return 'status-offen';
}

function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) return value;
    if (typeof value === 'number' && value < 1) {
        const h = Math.floor(value * 24), m = Math.round((value * 24 - h) * 60);
        return `${h.toString().padStart(2,'0')}:${m.toString().padStart(2,'0')}`;
    }
    return value;
}

window.SubMAPlanungStatus = {
    setLinkParams(VA_ID, VADatum_ID) { state.VA_ID = VA_ID; state.VADatum_ID = VADatum_ID; loadData(); },
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
