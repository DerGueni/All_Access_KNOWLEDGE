/**
 * sub_MA_VA_Planung_Absage.logic.js
 * Logik für Absagen-Subform
 * LinkMaster: ID;cboVADatum | LinkChild: VA_ID;VADatum_ID
 *
 * VBA-Events (aus Access-Export frm_va_Auftragstamm):
 * - Veranst_Status_ID_AfterUpdate: Me!sub_MA_VA_Planung_Absage.Locked = True/False
 * - Row Click: Zeile auswählen
 * - DblClick: MA-Details anzeigen
 */

const state = { VA_ID: null, VADatum_ID: null, records: [], selectedIndex: -1, isLocked: false, isEmbedded: false };
let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Absagen');
    state.isEmbedded = window.parent !== window;
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_MA_VA_Planung_Absage' }, '*');
    }

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
    }

    console.log('[sub_MA_VA_Planung_Absage] Initialisiert, embedded:', state.isEmbedded);
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'set_link_params':
            if (data.VA_ID !== undefined) state.VA_ID = data.VA_ID;
            if (data.VADatum_ID !== undefined) state.VADatum_ID = data.VADatum_ID;
            loadData();
            break;

        case 'requery':
            loadData();
            break;

        case 'lock_subform':
            // VBA: Me!sub_MA_VA_Planung_Absage.Locked = True/False
            setSubformLocked(data.locked === true);
            break;
    }
}

/**
 * Subform sperren (VBA: Veranst_Status_ID > 3)
 */
function setSubformLocked(locked) {
    state.isLocked = locked;
    // Bei Absagen-Liste gibt es normalerweise keine editierbaren Felder
    // aber für Konsistenz mit anderen Subforms implementieren
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_locked_changed',
            name: 'sub_MA_VA_Planung_Absage',
            locked: locked
        }, '*');
    }
}

function loadData() {
    if (!state.VA_ID) { renderEmpty(); return; }

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_MA_VA_Planung_Absage] Verwende REST-API Modus (erzwungen) fuer VA_ID:', state.VA_ID);

    if (isBrowserMode) {
        loadDataViaAPI();
    } else if (window.Bridge) {
        Bridge.sendEvent('loadSubformData', {
            type: 'ma_va_planung_absage',
            va_id: state.VA_ID,
            vadatum_id: state.VADatum_ID,
            status: 'Absage'
        });
    } else {
        console.warn('[sub_MA_VA_Planung_Absage] Bridge nicht verfuegbar und isBrowserMode=false, warte...');
        setTimeout(loadData, 100);
    }
}

async function loadDataViaAPI() {
    try {
        const response = await fetch(`http://localhost:5000/api/auftraege/${state.VA_ID}/absagen`);
        if (!response.ok) throw new Error(`API Fehler: ${response.status}`);

        const records = await response.json();
        console.log('[sub_MA_VA_Planung_Absage] API Daten geladen:', records.length, 'Absagen fuer VA:', state.VA_ID);

        handleDataReceived({
            type: 'ma_va_planung_absage',
            records: records
        });
    } catch (err) {
        console.error('[sub_MA_VA_Planung_Absage] API Fehler:', err);
        // Fallback: versuche Bridge
        if (window.Bridge) {
            console.log('[sub_MA_VA_Planung_Absage] Fallback zu Bridge...');
            Bridge.sendEvent('loadSubformData', {
                type: 'ma_va_planung_absage',
                va_id: state.VA_ID,
                vadatum_id: state.VADatum_ID,
                status: 'Absage'
            });
        }
    }
}

function handleDataReceived(data) {
    if (data.type === 'ma_va_planung_absage') {
        state.records = (data.records || []).map(rec => ({
            ID: rec.MVA_ID || rec.ID,
            PosNr: rec.MVA_PosNr || rec.PosNr,
            MA_ID: rec.MVA_MA_ID || rec.MA_ID,
            MA_Name: rec.MA_Name || `${rec.MA_Nachname || ''}, ${rec.MA_Vorname || ''}`.trim() || rec.MA_ID,
            VA_Start: rec.MVA_VA_Start || rec.VA_Start,
            VA_Ende: rec.MVA_VA_Ende || rec.VA_Ende,
            Bemerkungen: rec.MVA_Bemerkungen || rec.Bemerkungen || ''
        }));
        render();
    }
}

function render() {
    if (!tbody) return;
    if (state.records.length === 0) { renderEmpty(); return; }
    tbody.innerHTML = state.records.map((rec, idx) => {
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        const disabledAttr = state.isLocked ? 'disabled' : '';
        return `
        <tr data-index="${idx}" data-id="${rec.ID}" class="${selectedClass}">
            <td class="col-hidden">${rec.ID || ''}</td>
            <td class="col-lfd">${rec.PosNr || ''}</td>
            <td class="col-ma">${rec.MA_Name || rec.MA_ID || ''}</td>
            <td class="col-time">${formatTime(rec.VA_Start)}</td>
            <td class="col-time">${formatTime(rec.VA_Ende)}</td>
            <td class="col-bemerk">
                <input type="text" class="bemerk-input"
                       data-id="${rec.ID}"
                       data-index="${idx}"
                       value="${escapeHtml(rec.Bemerkungen || '')}"
                       ${disabledAttr}
                       title="Bemerkung bearbeiten"/>
            </td>
        </tr>
    `}).join('');

    // Event Listener für Zeilen binden
    attachRowListeners();
    // Event Listener für Bemerkungen-Inputs binden
    attachBemerkInputListeners();
}

/**
 * Event Listener an Zeilen binden (VBA-Events)
 */
function attachRowListeners() {
    tbody.querySelectorAll('tr').forEach(row => {
        // Row Click
        row.addEventListener('click', () => {
            selectRow(parseInt(row.dataset.index));
        });

        // Row DblClick - öffnet MA-Details
        row.addEventListener('dblclick', () => {
            const idx = parseInt(row.dataset.index);
            const rec = state.records[idx];
            if (rec && rec.MA_ID && state.isEmbedded) {
                window.parent.postMessage({
                    type: 'row_dblclick',
                    name: 'sub_MA_VA_Planung_Absage',
                    record: rec,
                    ma_id: rec.MA_ID
                }, '*');
            }
        });
    });
}

/**
 * Zeile auswählen
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
            name: 'sub_MA_VA_Planung_Absage',
            record: state.records[index]
        }, '*');
    }
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#666;padding:10px;">Keine Absagen</td></tr>';
}

/**
 * Escape HTML Sonderzeichen für sichere Darstellung
 */
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Event Listener für Bemerkungen-Inputs (AfterUpdate wie VBA)
 * VBA: Form_BeforeUpdate setzt Aend_am und Aend_von
 */
function attachBemerkInputListeners() {
    tbody.querySelectorAll('.bemerk-input').forEach(input => {
        // Speichere ursprünglichen Wert
        input.dataset.originalValue = input.value;

        // AfterUpdate (blur = Fokus verliert)
        input.addEventListener('blur', async (e) => {
            await handleBemerkungAfterUpdate(e.target);
        });

        // Enter-Taste = Speichern
        input.addEventListener('keydown', async (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                e.target.blur(); // Löst blur-Event aus
            } else if (e.key === 'Escape') {
                // Abbrechen: Wert zurücksetzen
                e.target.value = e.target.dataset.originalValue || '';
                e.target.blur();
            }
        });
    });
}

/**
 * Bemerkung AfterUpdate Handler (wie VBA Form_BeforeUpdate)
 * Speichert Bemerkung via REST API
 */
async function handleBemerkungAfterUpdate(input) {
    const newValue = input.value.trim();
    const originalValue = input.dataset.originalValue || '';

    // Keine Änderung = nichts tun
    if (newValue === originalValue) return;

    const recordId = input.dataset.id;
    const recordIndex = parseInt(input.dataset.index);

    if (!recordId) {
        console.warn('[sub_MA_VA_Planung_Absage] Keine Record-ID für Bemerkung');
        return;
    }

    console.log(`[sub_MA_VA_Planung_Absage] Bemerkung AfterUpdate: ID=${recordId}, "${originalValue}" → "${newValue}"`);

    // REST API: PUT /api/zuordnungen/<id>
    // (verwendet existierenden Endpoint aus api_server.py Zeilen 1990-2063)
    try {
        const response = await fetch(`http://localhost:5000/api/zuordnungen/${recordId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                Bemerkungen: newValue,
                Aend_von: 'HTML'  // Wie VBA: atCNames(1)
            })
        });

        if (!response.ok) {
            throw new Error(`API Fehler: ${response.status}`);
        }

        const result = await response.json();
        console.log('[sub_MA_VA_Planung_Absage] Bemerkung gespeichert:', result);

        // Erfolg: Lokalen State aktualisieren
        if (state.records[recordIndex]) {
            state.records[recordIndex].Bemerkungen = newValue;
        }
        input.dataset.originalValue = newValue;

        // Visuelles Feedback
        showSaveStatus(input, 'success', '✓');

        // Parent informieren (für mögliche Aktualisierung)
        if (state.isEmbedded) {
            window.parent.postMessage({
                type: 'bemerkung_updated',
                name: 'sub_MA_VA_Planung_Absage',
                record_id: recordId,
                bemerkung: newValue
            }, '*');
        }

    } catch (err) {
        console.error('[sub_MA_VA_Planung_Absage] Fehler beim Speichern:', err);

        // Fehler: Wert zurücksetzen
        input.value = originalValue;
        showSaveStatus(input, 'error', '✗');
    }
}

/**
 * Zeigt kurzen Speicher-Status neben dem Input an
 */
function showSaveStatus(input, type, text) {
    // Entferne vorherigen Status
    const existingStatus = input.parentNode.querySelector('.save-status');
    if (existingStatus) existingStatus.remove();

    // Neuen Status erstellen
    const status = document.createElement('span');
    status.className = `save-status ${type}`;
    status.textContent = text;
    input.parentNode.appendChild(status);

    // Nach 2 Sekunden ausblenden
    setTimeout(() => {
        status.remove();
    }, 2000);
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

window.SubMAPlanungAbsage = {
    setLinkParams(VA_ID, VADatum_ID) { state.VA_ID = VA_ID; state.VADatum_ID = VADatum_ID; loadData(); },
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
