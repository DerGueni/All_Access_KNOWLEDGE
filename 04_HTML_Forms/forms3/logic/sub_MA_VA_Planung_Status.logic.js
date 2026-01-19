/**
 * sub_MA_VA_Planung_Status.logic.js
 * Logik für Antworten ausstehend Subform
 * LinkMaster: ID;cboVADatum | LinkChild: VA_ID;VADatum_ID
 *
 * VBA-Referenz (aus Access-Export):
 * - Form_BeforeUpdate: Setzt Aend_am und Aend_von
 * - MA_ID_DblClick: Öffnet Mitarbeiterstamm
 * - VA_Start_AfterUpdate / VA_Ende_AfterUpdate: Ruft Start_End_Aend
 * - Status_ID ComboBox: Dropdown mit Status 1-4:
 *   1 = Geplant, 2 = Benachrichtigt, 3 = Zusage, 4 = Absage
 *
 * Status_ID ComboBox RowSource:
 * SELECT tbl_MA_Plan_Status.ID, tbl_MA_Plan_Status.Status FROM tbl_MA_Plan_Status;
 */

// Status-Lookup (entspricht tbl_MA_Plan_Status)
const STATUS_OPTIONS = [
    { id: 1, text: 'Geplant', cssClass: 'status-geplant' },
    { id: 2, text: 'Benachrichtigt', cssClass: 'status-benachrichtigt' },
    { id: 3, text: 'Zusage', cssClass: 'status-zusage' },
    { id: 4, text: 'Absage', cssClass: 'status-absage' }
];

const state = {
    VA_ID: null,
    VADatum_ID: null,
    records: [],
    selectedIndex: -1,
    isEmbedded: false,
    pendingUpdates: new Map() // Track pending API updates
};

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
    if (!state.VA_ID) {
        renderEmpty();
        return;
    }

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_MA_VA_Planung_Status] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        try {
            let url = `http://localhost:5000/api/auftraege/${state.VA_ID}/zuordnungen`;
            if (state.VADatum_ID) {
                url += `?vadatum_id=${state.VADatum_ID}`;
            }
            // Filter nach Status 1 oder 2 (Geplant/Benachrichtigt = ausstehend)
            // Alternativ alle laden und im Frontend filtern
            console.log('[sub_MA_VA_Planung_Status] Fetch:', url);

            const response = await fetch(url);
            const result = await response.json();

            // Nur Einträge mit Status 1 oder 2 anzeigen (ausstehende Antworten)
            const filteredRecords = (result.data || []).filter(rec => {
                const statusId = rec.MVA_Status_ID || rec.Status_ID || rec.Status;
                return statusId === 1 || statusId === 2;
            });

            handleDataReceived({ type: 'ma_va_planung_status', records: filteredRecords });
        } catch (error) {
            console.error('[sub_MA_VA_Planung_Status] API-Fehler:', error);
            renderEmpty();
        }
    }
}

function handleDataReceived(data) {
    if (data.type === 'ma_va_planung_status') {
        state.records = (data.records || []).map(rec => ({
            ID: rec.MVA_ID || rec.ID,
            PosNr: rec.MVA_PosNr || rec.PosNr,
            MA_ID: rec.MVA_MA_ID || rec.MA_ID,
            MA_Name: rec.MA_Name || `${rec.MA_Nachname || ''}, ${rec.MA_Vorname || ''}`.trim() || rec.MA_ID,
            VA_Start: rec.MVA_VA_Start || rec.VA_Start || rec.MVA_Start,
            VA_Ende: rec.MVA_VA_Ende || rec.VA_Ende || rec.MVA_Ende,
            MA_Brutto_Std: rec.MVA_MA_Brutto_Std || rec.MA_Brutto_Std,
            Bemerkungen: rec.MVA_Bemerkungen || rec.Bemerkungen || '',
            Status_ID: rec.MVA_Status_ID || rec.Status_ID || rec.Status || 1
        }));
        render();
    }
}

function render() {
    if (!tbody) return;
    if (state.records.length === 0) {
        renderEmpty();
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        const statusOption = STATUS_OPTIONS.find(s => s.id === rec.Status_ID) || STATUS_OPTIONS[0];
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';

        return `
        <tr data-index="${idx}" data-id="${rec.ID}" class="${statusOption.cssClass}${selectedClass}">
            <td class="col-hidden">${rec.ID || ''}</td>
            <td class="col-lfd">${rec.PosNr || ''}</td>
            <td class="col-ma">${rec.MA_Name || rec.MA_ID || ''}</td>
            <td class="col-time">${formatTime(rec.VA_Start)}</td>
            <td class="col-time">${formatTime(rec.VA_Ende)}</td>
            <td class="col-std">${rec.MA_Brutto_Std || ''}</td>
            <td class="col-bemerk">${rec.Bemerkungen || ''}</td>
            <td class="col-status">
                ${renderStatusDropdown(rec.ID, rec.Status_ID)}
            </td>
        </tr>
    `}).join('');

    // Event Listener für Zeilen und Dropdowns binden
    attachRowListeners();
    attachStatusDropdownListeners();
}

/**
 * Rendert das Status-Dropdown (entspricht Access ComboBox Status_ID)
 * VBA: RowSource = "SELECT tbl_MA_Plan_Status.ID, tbl_MA_Plan_Status.Status FROM tbl_MA_Plan_Status;"
 */
function renderStatusDropdown(recordId, currentStatusId) {
    const options = STATUS_OPTIONS.map(opt => {
        const selected = opt.id === currentStatusId ? ' selected' : '';
        return `<option value="${opt.id}"${selected}>${opt.text}</option>`;
    }).join('');

    return `<select class="status-select" data-record-id="${recordId}">${options}</select>`;
}

/**
 * Event Listener an Status-Dropdowns binden
 * VBA-Äquivalent: Status_ID_AfterUpdate
 */
function attachStatusDropdownListeners() {
    tbody.querySelectorAll('.status-select').forEach(select => {
        select.addEventListener('change', async function(event) {
            event.stopPropagation(); // Prevent row click

            const recordId = parseInt(this.dataset.recordId);
            const newStatusId = parseInt(this.value);

            console.log(`[sub_MA_VA_Planung_Status] Status_ID_AfterUpdate: ID=${recordId}, NewStatus=${newStatusId}`);

            // Update local state
            const record = state.records.find(r => r.ID === recordId);
            if (record) {
                const oldStatusId = record.Status_ID;
                record.Status_ID = newStatusId;

                // Update row class
                const row = this.closest('tr');
                if (row) {
                    STATUS_OPTIONS.forEach(opt => row.classList.remove(opt.cssClass));
                    const newStatus = STATUS_OPTIONS.find(s => s.id === newStatusId);
                    if (newStatus) row.classList.add(newStatus.cssClass);
                }

                // API Update
                await updateStatusInDB(recordId, newStatusId, oldStatusId);

                // Parent über Änderung informieren
                if (state.isEmbedded) {
                    window.parent.postMessage({
                        type: 'status_changed',
                        name: 'sub_MA_VA_Planung_Status',
                        record_id: recordId,
                        old_status: oldStatusId,
                        new_status: newStatusId,
                        status_text: STATUS_OPTIONS.find(s => s.id === newStatusId)?.text
                    }, '*');
                }

                // Bei Zusage (3) oder Absage (4): Zeile aus Ansicht entfernen
                // da dieses Subform nur ausstehende Antworten (Status 1,2) zeigt
                if (newStatusId === 3 || newStatusId === 4) {
                    setTimeout(() => {
                        state.records = state.records.filter(r => r.ID !== recordId);
                        render();
                    }, 500); // Kurze Verzögerung für visuelles Feedback
                }
            }
        });

        // Focus styling
        select.addEventListener('focus', function() {
            this.closest('tr')?.classList.add('editing');
        });

        select.addEventListener('blur', function() {
            this.closest('tr')?.classList.remove('editing');
        });
    });
}

/**
 * API-Update für Status-Änderung
 * VBA-Äquivalent: Form_BeforeUpdate + Dirty=True
 */
async function updateStatusInDB(recordId, newStatusId, oldStatusId) {
    try {
        // PUT request zum Aktualisieren des Status
        // Falls PUT nicht existiert, nutzen wir PATCH oder simulieren mit DELETE+INSERT
        const response = await fetch(`http://localhost:5000/api/zuordnungen/${recordId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                Status_ID: newStatusId,
                Aend_am: new Date().toISOString(),
                Aend_von: 'HTML'
            })
        });

        if (!response.ok) {
            // Fallback: Versuche PATCH
            const patchResponse = await fetch(`http://localhost:5000/api/zuordnungen/${recordId}`, {
                method: 'PATCH',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ Status_ID: newStatusId })
            });

            if (!patchResponse.ok) {
                throw new Error(`HTTP ${patchResponse.status}`);
            }
        }

        console.log(`[sub_MA_VA_Planung_Status] Status aktualisiert: ID=${recordId}, Status=${newStatusId}`);
        return true;

    } catch (error) {
        console.error(`[sub_MA_VA_Planung_Status] Fehler beim Status-Update:`, error);

        // Rollback local state
        const record = state.records.find(r => r.ID === recordId);
        if (record) {
            record.Status_ID = oldStatusId;
            render();
        }

        // Fehler anzeigen
        alert(`Fehler beim Speichern des Status: ${error.message}`);
        return false;
    }
}

/**
 * Event Listener an Zeilen binden (VBA-Events)
 */
function attachRowListeners() {
    tbody.querySelectorAll('tr').forEach(row => {
        // Row Click (VBA: OnClick)
        row.addEventListener('click', (event) => {
            // Ignore clicks on dropdown
            if (event.target.classList.contains('status-select')) return;
            selectRow(parseInt(row.dataset.index));
        });

        // Row DblClick (VBA: MA_ID_DblClick - öffnet MA-Details)
        row.addEventListener('dblclick', (event) => {
            // Ignore double-clicks on dropdown
            if (event.target.classList.contains('status-select')) return;

            const idx = parseInt(row.dataset.index);
            const rec = state.records[idx];
            if (rec && rec.MA_ID) {
                console.log(`[sub_MA_VA_Planung_Status] MA_ID_DblClick: MA_ID=${rec.MA_ID}`);

                if (state.isEmbedded) {
                    window.parent.postMessage({
                        type: 'open_mitarbeiterstamm',
                        name: 'sub_MA_VA_Planung_Status',
                        ma_id: rec.MA_ID
                    }, '*');
                }
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

function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) return value.substring(0, 5);
    if (typeof value === 'number' && value < 1) {
        const h = Math.floor(value * 24);
        const m = Math.round((value * 24 - h) * 60);
        return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
    }
    return value;
}

// Öffentliche API
window.SubMAPlanungStatus = {
    setLinkParams(VA_ID, VADatum_ID) {
        state.VA_ID = VA_ID;
        state.VADatum_ID = VADatum_ID;
        loadData();
    },
    requery: loadData,
    getState: () => ({ ...state }),
    getStatusOptions: () => STATUS_OPTIONS
};

document.addEventListener('DOMContentLoaded', init);
