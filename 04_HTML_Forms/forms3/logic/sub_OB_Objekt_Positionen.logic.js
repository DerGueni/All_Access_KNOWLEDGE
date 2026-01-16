/**
 * sub_OB_Objekt_Positionen.logic.js
 * Logik für Objekt-Positionen Subform
 *
 * VBA-Events:
 * - Row Click: Position auswählen
 * - Row DblClick: Position bearbeiten (bearbeitePosition)
 * - btnNeu Click: Neue Position anlegen
 * - btnBearbeiten Click: Ausgewählte Position bearbeiten
 * - btnLöschen Click: Ausgewählte Position löschen
 * - AfterUpdate: Summen neu berechnen und Parent informieren
 */

const state = {
    objektId: null,
    positionen: [],
    selectedRow: null,
    isEmbedded: false
};

let elements = {};

function init() {
    console.log('[sub_OB_Objekt_Positionen] Initialisierung...');

    // Prüfen ob embedded
    state.isEmbedded = window.parent !== window;

    // Parameter aus URL lesen
    const params = new URLSearchParams(window.location.search);
    state.objektId = params.get('Objekt_ID') || params.get('objekt_id');

    elements = {
        btnNeu: document.getElementById('btnNeu'),
        btnBearbeiten: document.getElementById('btnBearbeiten'),
        btnLoeschen: document.getElementById('btnLöschen'),
        lblAnzahl: document.getElementById('lblAnzahl'),
        tbody: document.getElementById('tbody_Positionen'),
        sumMA: document.getElementById('sumMA')
    };

    setupEventListeners();

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
    }

    if (state.objektId) {
        loadPositionen();
    }

    // PostMessage vom Parent-Formular
    window.addEventListener('message', handleMessage);

    // Parent informieren dass Subform bereit ist
    if (state.isEmbedded) {
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_OB_Objekt_Positionen' }, '*');
    }
}

function setupEventListeners() {
    if (elements.btnNeu) {
        elements.btnNeu.addEventListener('click', neuePosition);
    }
    if (elements.btnBearbeiten) {
        elements.btnBearbeiten.addEventListener('click', bearbeitePosition);
    }
    if (elements.btnLoeschen) {
        elements.btnLoeschen.addEventListener('click', loeschePosition);
    }
}

function handleMessage(event) {
    const data = event.data;
    if (!data) return;

    // Unterstütze beide Formate: action und type
    const action = data.action || data.type;

    switch (action) {
        case 'setObjektID':
        case 'set_link_params':
            state.objektId = data.objektId || data.Objekt_ID || data.objekt_id;
            loadPositionen();
            break;
        case 'requery':
            loadPositionen();
            break;
        case 'lock_subform':
            // VBA: Subform sperren
            setSubformLocked(data.locked === true);
            break;
    }
}

/**
 * Subform sperren (VBA-Event)
 */
function setSubformLocked(locked) {
    if (elements.btnNeu) elements.btnNeu.disabled = locked;
    if (elements.btnBearbeiten) elements.btnBearbeiten.disabled = locked;
    if (elements.btnLoeschen) elements.btnLoeschen.disabled = locked;
}

async function loadPositionen() {
    if (!state.objektId) {
        renderEmpty();
        return;
    }

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_OB_Objekt_Positionen] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        try {
            const url = `http://localhost:5000/api/objekte/${state.objektId}/positionen`;
            console.log('[sub_OB_Objekt_Positionen] Fetch:', url);
            const response = await fetch(url);
            const result = await response.json();
            handleDataReceived({ type: 'objekt_positionen', records: result.data || [] });
        } catch (error) {
            console.error('[sub_OB_Objekt_Positionen] API-Fehler:', error);
            renderError(error.message);
        }
    }
    // Fallback: WebView2-Bridge (wenn verfügbar)
    else if (window.Bridge) {
        /* Bridge.sendEvent('loadSubformData', {
            type: 'objekt_positionen',
            objekt_id: state.objektId
        }); */
    }
}

function handleDataReceived(data) {
    if (data.type === 'objekt_positionen') {
        state.positionen = data.records || [];
        renderPositionen();
        updateSumme();
        updateCount();
    }
}

function renderPositionen() {
    if (!elements.tbody) return;

    if (state.positionen.length === 0) {
        renderEmpty();
        return;
    }

    elements.tbody.innerHTML = state.positionen.map((pos, idx) => {
        const selected = state.selectedRow === idx ? 'selected' : '';
        const qualiClass = pos.Qualifikation_Required ? 'required' : '';

        return `
            <tr data-index="${idx}" data-id="${pos.ID}" class="${selected}">
                <td class="text-center">${pos.Position || 'P' + (idx + 1).toString().padStart(2, '0')}</td>
                <td>${pos.Bezeichnung || ''}</td>
                <td class="text-center">${pos.MA_Soll || 0}</td>
                <td><span class="quali-badge ${qualiClass}">${pos.Qualifikation || '-'}</span></td>
                <td class="text-right">${formatBetrag(pos.Stundensatz)}</td>
                <td>${pos.Bemerkung || ''}</td>
            </tr>
        `;
    }).join('');

    // Click-Handler
    elements.tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => selectRow(row));
        row.addEventListener('dblclick', () => bearbeitePosition());
    });
}

function renderEmpty() {
    if (elements.tbody) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align:center;color:#666;padding:20px;">
                    Keine Positionen vorhanden
                </td>
            </tr>
        `;
    }
    state.positionen = [];
    updateCount();
    updateSumme();
}

function renderError(message) {
    if (elements.tbody) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align:center;color:#c00;padding:20px;">
                    Fehler: ${message}
                </td>
            </tr>
        `;
    }
}

function selectRow(row) {
    const idx = parseInt(row.dataset.index);
    state.selectedRow = idx;

    elements.tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
    row.classList.add('selected');

    // Parent informieren (VBA: OnCurrent)
    if (state.isEmbedded && state.positionen[idx]) {
        window.parent.postMessage({
            type: 'subform_selection',
            name: 'sub_OB_Objekt_Positionen',
            record: state.positionen[idx]
        }, '*');
    }
}

function neuePosition() {
    if (!state.objektId) {
        alert('Bitte zuerst ein Objekt auswählen');
        return;
    }

    // Dialog öffnen oder Inline-Eingabe
    const bezeichnung = prompt('Bezeichnung der Position:');
    if (!bezeichnung) return;

    const maSoll = prompt('Anzahl MA (Soll):', '1');
    const stundensatz = prompt('Stundensatz:', '20.00');

    createPosition({
        Objekt_ID: state.objektId,
        Bezeichnung: bezeichnung,
        MA_Soll: parseInt(maSoll) || 1,
        Stundensatz: parseFloat(stundensatz) || 20.00
    });
}

function createPosition(data) {
    Bridge.sendEvent('insertRecord', {
        table: 'tbl_OB_Objekt_Positionen',
        data: data
    });
    loadPositionen();
    notifyParentChanged('position_created');
}

function bearbeitePosition() {
    if (state.selectedRow === null || state.selectedRow === undefined) {
        alert('Bitte zuerst eine Position auswählen');
        return;
    }

    const pos = state.positionen[state.selectedRow];
    if (!pos) return;

    const bezeichnung = prompt('Bezeichnung:', pos.Bezeichnung);
    if (bezeichnung === null) return;

    const maSoll = prompt('Anzahl MA (Soll):', pos.MA_Soll);
    const stundensatz = prompt('Stundensatz:', pos.Stundensatz);

    updatePosition(pos.ID, {
        Bezeichnung: bezeichnung,
        MA_Soll: parseInt(maSoll) || pos.MA_Soll,
        Stundensatz: parseFloat(stundensatz) || pos.Stundensatz
    });
}

function updatePosition(id, data) {
    Bridge.sendEvent('updateRecord', {
        table: 'tbl_OB_Objekt_Positionen',
        id: id,
        data: data
    });
    loadPositionen();
    notifyParentChanged('position_updated');
}

function loeschePosition() {
    if (state.selectedRow === null || state.selectedRow === undefined) {
        alert('Bitte zuerst eine Position auswählen');
        return;
    }

    const pos = state.positionen[state.selectedRow];
    if (!pos) return;

    if (!confirm('Position wirklich löschen?')) return;

    Bridge.sendEvent('deleteRecord', {
        table: 'tbl_OB_Objekt_Positionen',
        id: pos.ID
    });
    state.selectedRow = null;
    loadPositionen();
    notifyParentChanged('position_deleted');
}

/**
 * Parent über Änderung informieren (VBA: AfterUpdate)
 */
function notifyParentChanged(action) {
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'subform_changed',
            name: 'sub_OB_Objekt_Positionen',
            action: action,
            anzahl: state.positionen.length,
            sumMA: state.positionen.reduce((acc, pos) => acc + (parseInt(pos.MA_Soll) || 0), 0)
        }, '*');
    }
}

function updateCount() {
    if (elements.lblAnzahl) {
        const count = state.positionen.length;
        elements.lblAnzahl.textContent = `${count} Position${count !== 1 ? 'en' : ''}`;
    }
}

function updateSumme() {
    if (elements.sumMA) {
        const sum = state.positionen.reduce((acc, pos) => acc + (parseInt(pos.MA_Soll) || 0), 0);
        elements.sumMA.textContent = sum;
    }
}

function formatBetrag(value) {
    if (!value && value !== 0) return '-';
    return Number(value).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.SubOBPositionen = {
    loadPositionen,
    neuePosition,
    bearbeitePosition,
    loeschePosition,
    setObjektId: (id) => {
        state.objektId = id;
        loadPositionen();
    }
};
