/**
 * sub_ZusatzDateien.logic.js
 * LinkMaster: Objekt_ID;TabellenNr | LinkChild: Ueberordnung;TabellenID
 *
 * VBA-Events (aus Access-Export):
 * - Requery nach f_btnNeuAttach: Me!sub_ZusatzDateien.Form.Requery
 * - DblClick auf Dateiname: Datei öffnen
 * - Row Click: Zeile auswählen
 */

const state = { Objekt_ID: null, TabellenNr: 42, records: [], selectedIndex: -1, isEmbedded: false };
let tbody = null;

function init() {
    tbody = document.getElementById('tbody_Zusatz');
    state.isEmbedded = window.parent !== window;
    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_ZusatzDateien' }, '*');
    }

    // WebView2 Event Listener
    if (window.Bridge) {
        Bridge.on('onDataReceived', handleDataReceived);
    }
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;
    if (data.type === 'set_link_params') {
        if (data.Objekt_ID !== undefined) state.Objekt_ID = data.Objekt_ID;
        if (data.TabellenNr !== undefined) state.TabellenNr = data.TabellenNr;
        loadData();
    } else if (data.type === 'requery') {
        loadData();
    }
}

async function loadData() {
    if (!state.Objekt_ID) { renderEmpty(); return; }

    // IMMER REST-API verwenden - WebView2-Bridge hat Timeout-Probleme bei iframes
    const isBrowserMode = true; // Erzwinge REST-API Modus
    console.log('[sub_ZusatzDateien] Verwende REST-API Modus (erzwungen)');

    if (isBrowserMode) {
        try {
            // Endpoint: /api/attachments?objekt_id=...&tabellen_nr=42
            let url = `http://localhost:5000/api/attachments?objekt_id=${state.Objekt_ID}`;
            if (state.TabellenNr) {
                url += `&tabellen_nr=${state.TabellenNr}`;
            }
            console.log('[sub_ZusatzDateien] Fetch:', url);
            const response = await fetch(url);
            const result = await response.json();
            handleDataReceived({ type: 'zusatzdateien', records: result.data || [] });
        } catch (error) {
            console.error('[sub_ZusatzDateien] API-Fehler:', error);
            renderEmpty();
        }
    }
    // Fallback: WebView2-Bridge (wenn verfügbar)
    else if (window.Bridge) {
        /* Bridge.sendEvent('loadSubformData', {
            type: 'zusatzdateien',
            objekt_id: state.Objekt_ID,
            tabellen_nr: state.TabellenNr
        }); */
    }
}

function handleDataReceived(data) {
    if (data.type === 'zusatzdateien') {
        state.records = data.records || [];
        render();
    }
}

function render() {
    if (!tbody) return;
    if (state.records.length === 0) { renderEmpty(); return; }
    tbody.innerHTML = state.records.map((rec, idx) => {
        const selectedClass = idx === state.selectedIndex ? ' selected' : '';
        // Escape Dateiname für onclick
        const escapedFilename = (rec.Dateiname || '').replace(/'/g, "\\'");
        return `
        <tr data-index="${idx}" data-id="${rec.ZusatzNr}" class="${selectedClass}">
            <td class="col-hidden">${rec.ZusatzNr || ''}</td>
            <td class="col-hidden">${rec.TabellenID || ''}</td>
            <td class="col-hidden">${rec.Ueberordnung || ''}</td>
            <td class="col-datei">${rec.Dateiname || ''}</td>
            <td class="col-datum">${formatDate(rec.DFiledate)}</td>
            <td class="col-laenge">${formatSize(rec.DLaenge)}</td>
            <td class="col-typ">${rec.Texttyp || ''}</td>
            <td class="col-beschreib">${rec.Kurzbeschreibung || ''}</td>
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
        const idx = parseInt(row.dataset.index);

        // Row Click
        row.addEventListener('click', () => {
            selectRow(idx);
        });

        // Row DblClick - Datei öffnen (VBA: OnDblClick)
        row.addEventListener('dblclick', () => {
            const rec = state.records[idx];
            if (rec && rec.Dateiname) {
                openFile(rec.Dateiname);
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
            name: 'sub_ZusatzDateien',
            record: state.records[index]
        }, '*');
    }
}

function renderEmpty() {
    if (!tbody) return;
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;color:#666;padding:10px;">Keine Zusatzdateien</td></tr>';
}

function formatDate(value) {
    if (!value) return '';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE');
}

function formatSize(bytes) {
    if (!bytes) return '';
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024*1024) return (bytes/1024).toFixed(1) + ' KB';
    return (bytes/1024/1024).toFixed(1) + ' MB';
}

/**
 * Datei öffnen (VBA: DblClick Event)
 */
window.openFile = function(filename) {
    // Via WebView2 Bridge
    if (window.Bridge) {
        Bridge.sendEvent('openFile', { filename: filename });
    }

    // Parent informieren (falls embedded)
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'file_open_request',
            name: 'sub_ZusatzDateien',
            filename: filename
        }, '*');
    }
};

window.SubZusatzDateien = {
    setLinkParams(Objekt_ID, TabellenNr) { state.Objekt_ID = Objekt_ID; state.TabellenNr = TabellenNr || 42; loadData(); },
    requery: loadData
};

document.addEventListener('DOMContentLoaded', init);
