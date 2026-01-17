/**
 * sub_MA_Offene_Anfragen.logic.js
 * Logik fuer offene MA-Anfragen Subform
 *
 * VBA-Events:
 * - Row Click: Anfrage auswählen
 * - Zusagen/Absagen Buttons: Status ändern und Parent informieren
 * - OnCurrent: Aktuelle Anfrage markieren
 * - AfterUpdate: Nach Statusänderung alle betroffenen Subforms aktualisieren
 */

const state = {
    MA_ID: null,
    VA_ID: null,
    records: [],
    selectedIndex: -1,
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
            if (data.MA_ID !== undefined) state.MA_ID = data.MA_ID;
            if (data.VA_ID !== undefined) state.VA_ID = data.VA_ID;
            loadData();
            break;
        case 'requery':
            loadData();
            break;
    }
}

function loadData() {
    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_MA_Offene_Anfragen] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        loadDataViaAPI();
    } else if (window.Bridge) {
        Bridge.sendEvent('loadSubformData', {
            type: 'ma_offene_anfragen',
            ma_id: state.MA_ID,
            va_id: state.VA_ID
        });
    } else {
        console.warn('[sub_MA_Offene_Anfragen] Bridge nicht verfuegbar und isBrowserMode=false, warte...');
        setTimeout(loadData, 100);
    }
}

async function loadDataViaAPI() {
    try {
        const response = await fetch('http://localhost:5000/api/anfragen');
        if (!response.ok) throw new Error(`API Fehler: ${response.status}`);

        let records = await response.json();
        console.log('[sub_MA_Offene_Anfragen] API Daten geladen:', records.length, 'Eintraege');

        // Filter nach MA_ID und VA_ID wenn vorhanden
        if (state.MA_ID) {
            records = records.filter(r => r.MA_ID === state.MA_ID || r.MVA_MA_ID === state.MA_ID);
        }
        if (state.VA_ID) {
            records = records.filter(r => r.VA_ID === state.VA_ID);
        }

        state.records = records;
        render();
    } catch (err) {
        console.error('[sub_MA_Offene_Anfragen] API Fehler:', err);
        // Fallback: versuche Bridge
        if (window.Bridge) {
            console.log('[sub_MA_Offene_Anfragen] Fallback zu Bridge...');
            Bridge.sendEvent('loadSubformData', {
                type: 'ma_offene_anfragen',
                ma_id: state.MA_ID,
                va_id: state.VA_ID
            });
        }
    }
}

function handleDataReceived(data) {
    if (data.type === 'ma_offene_anfragen') {
        state.records = data.records || [];
        render();
    }
}

function render() {
    if (!tbody) return;

    if (state.records.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;color:#666;padding:20px;">Keine offenen Anfragen</td></tr>';
        updateCount(0);
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        const datum = rec.VADatum ? new Date(rec.VADatum).toLocaleDateString('de-DE') : '';
        const name = `${rec.Nachname || ''}, ${rec.Vorname || ''}`;
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        return `
            <tr data-id="${rec.ID}" data-index="${idx}" class="${selectedClass}">
                <td>${datum}</td>
                <td>${name}</td>
                <td>${rec.Objekt || ''}</td>
                <td>${formatTime(rec.VA_Start)} - ${formatTime(rec.VA_Ende)}</td>
                <td>
                    <button class="btn-action zusagen" data-action="zusagen" data-id="${rec.ID}">Zusage</button>
                    <button class="btn-action absagen" data-action="absagen" data-id="${rec.ID}">Absage</button>
                </td>
            </tr>
        `;
    }).join('');

    // Event Listener für Zeilen und Buttons binden
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
        row.addEventListener('click', (e) => {
            // Nicht bei Button-Klicks
            if (e.target.tagName !== 'BUTTON') {
                selectRow(idx);
            }
        });

        // Row DblClick (VBA: OnDblClick - Anfrage-Details)
        row.addEventListener('dblclick', (e) => {
            if (e.target.tagName !== 'BUTTON') {
                const rec = state.records[idx];
                if (rec && state.isEmbedded) {
                    window.parent.postMessage({
                        type: 'row_dblclick',
                        name: 'sub_MA_Offene_Anfragen',
                        record: rec,
                        action: 'show_details'
                    }, '*');
                }
            }
        });
    });

    // Zusagen/Absagen Buttons
    tbody.querySelectorAll('button[data-action]').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const action = btn.dataset.action;
            const id = parseInt(btn.dataset.id);
            if (action === 'zusagen') {
                zusagen(id);
            } else if (action === 'absagen') {
                absagen(id);
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
            name: 'sub_MA_Offene_Anfragen',
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
        lblAnzahl.textContent = `${count} Anfragen`;
    }
}

function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) return value.substring(0, 5);
    const date = new Date(value);
    if (isNaN(date)) return value;
    return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

async function zusagen(id) {
    if (!window.Bridge) {
        console.error('[sub_MA_Offene_Anfragen] Bridge nicht verfuegbar');
        return;
    }
    await Bridge.sendEvent('updateRecord', {
        table: 'tbl_MA_VA_Planung',
        id: id,
        field: 'MVP_Status',
        value: 2
    });
    setTimeout(loadData, 200);
    notifyParent('anfrage_beantwortet');
}

async function absagen(id) {
    if (!window.Bridge) {
        console.error('[sub_MA_Offene_Anfragen] Bridge nicht verfuegbar');
        return;
    }
    await Bridge.sendEvent('updateRecord', {
        table: 'tbl_MA_VA_Planung',
        id: id,
        field: 'MVP_Status',
        value: 3
    });
    setTimeout(loadData, 200);
    notifyParent('anfrage_beantwortet');
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
