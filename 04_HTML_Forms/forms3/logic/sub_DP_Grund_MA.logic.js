/**
 * sub_DP_Grund_MA.logic.js
 * Logik fuer Dienstplan-Gruende pro Mitarbeiter Subform
 *
 * VBA-Events:
 * - Row Click: Eintrag auswählen
 * - DblClick: Eintrag bearbeiten
 * - AfterUpdate: Nach Änderung Parent informieren
 * - Filter via cboGrund: Filterung nach Grund-Typ
 */

const state = {
    MA_ID: null,
    records: [],
    filteredRecords: [],
    selectedIndex: -1,
    filterGrund: '',
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

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
    }

    // Filter-Dropdown Event Listener
    const cboGrund = document.getElementById('cboGrund');
    if (cboGrund) {
        cboGrund.addEventListener('change', handleFilterChange);
    }

    // Filter-Button
    const btnFilter = document.getElementById('btnFilter');
    if (btnFilter) {
        btnFilter.addEventListener('click', toggleFilter);
    }
}

/**
 * Filter-Änderung verarbeiten
 */
function handleFilterChange(event) {
    state.filterGrund = event.target.value;
    applyFilter();
}

/**
 * Filter anwenden
 */
function applyFilter() {
    if (!state.filterGrund) {
        state.filteredRecords = [...state.records];
    } else {
        state.filteredRecords = state.records.filter(rec => {
            const grund = (rec.Grund_Bez || '').toLowerCase();
            return grund.includes(state.filterGrund.toLowerCase());
        });
    }
    render();
}

/**
 * Filter-Bereich ein/ausblenden
 */
function toggleFilter() {
    const toolbar = document.querySelector('.subform-toolbar');
    if (toolbar) {
        toolbar.classList.toggle('filter-active');
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

function loadData() {
    if (!state.MA_ID) {
        renderEmpty();
        return;
    }

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_DP_Grund_MA] Verwende REST-API Modus (erzwungen) fuer MA_ID:', state.MA_ID);

    if (isBrowserMode) {
        loadDataViaAPI();
    } else if (window.Bridge) {
        Bridge.sendEvent('loadSubformData', {
            type: 'dp_grund_ma',
            ma_id: state.MA_ID
        });
    } else {
        console.warn('[sub_DP_Grund_MA] Bridge nicht verfuegbar und isBrowserMode=false, warte...');
        setTimeout(loadData, 100);
    }
}

async function loadDataViaAPI() {
    try {
        const response = await fetch(`http://localhost:5000/api/dienstplan/ma/${state.MA_ID}`);
        if (!response.ok) throw new Error(`API Fehler: ${response.status}`);

        const records = await response.json();
        console.log('[sub_DP_Grund_MA] API Daten geladen:', records.length, 'Eintraege fuer MA:', state.MA_ID);

        state.records = records;
        state.filteredRecords = [...records];
        render();
        updateCount();
    } catch (err) {
        console.error('[sub_DP_Grund_MA] API Fehler:', err);
        // Fallback: versuche Bridge
        if (window.Bridge) {
            console.log('[sub_DP_Grund_MA] Fallback zu Bridge...');
            Bridge.sendEvent('loadSubformData', {
                type: 'dp_grund_ma',
                ma_id: state.MA_ID
            });
        }
    }
}

function handleDataReceived(data) {
    if (data.type === 'dp_grund_ma') {
        state.records = data.records || [];
        state.filteredRecords = [...state.records];
        render();
        updateCount();
    }
}

function render() {
    if (!tbody) return;

    const displayRecords = state.filteredRecords.length > 0 ? state.filteredRecords : state.records;

    if (displayRecords.length === 0) {
        renderEmpty();
        return;
    }

    tbody.innerHTML = displayRecords.map((rec, idx) => {
        const datum = rec.Datum ? new Date(rec.Datum).toLocaleDateString('de-DE') : '';
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        return `
            <tr data-id="${rec.ID}" data-index="${idx}" class="${selectedClass}">
                <td>${datum}</td>
                <td>${rec.Grund_Bez || ''}</td>
                <td>${rec.Bemerkung || ''}</td>
            </tr>
        `;
    }).join('');

    // Event Listener für Zeilen binden
    attachRowListeners();
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

        // Row DblClick (VBA: OnDblClick - Eintrag bearbeiten)
        row.addEventListener('dblclick', () => {
            const rec = state.filteredRecords[idx] || state.records[idx];
            if (rec && state.isEmbedded) {
                window.parent.postMessage({
                    type: 'row_dblclick',
                    name: 'sub_DP_Grund_MA',
                    record: rec,
                    action: 'edit_grund'
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

    const rec = state.filteredRecords[index] || state.records[index];
    // Parent informieren
    if (state.isEmbedded && rec) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'sub_DP_Grund_MA',
            record: rec
        }, '*');
    }
}

/**
 * Anzahl aktualisieren
 */
function updateCount() {
    const lblAnzahl = document.getElementById('lblAnzahl');
    if (lblAnzahl) {
        const count = state.filteredRecords.length || state.records.length;
        lblAnzahl.textContent = `${count} MA`;
    }
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
