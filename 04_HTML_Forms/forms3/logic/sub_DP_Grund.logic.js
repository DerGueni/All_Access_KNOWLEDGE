/**
 * sub_DP_Grund.logic.js
 * Logik fuer Dienstplan-Gruende Subform
 *
 * VBA-Events aus Form_sub_DP_Grund.bas:
 * - Row Click: Grund auswählen
 * - DblClick: Grund-Details anzeigen/bearbeiten (fTest, fTest1, fopenAuftragstamm)
 * - OnCurrent: Aktuellen Grund markieren
 * - KeyDown Events:
 *   - Delete (46): MA aus Zuordnung entfernen (fDel_MA_ID_Zuo)
 *   - ArrowDown (40): Auftragstamm öffnen
 *   - ArrowKeys (37-40): Navigation erlaubt
 *   - Andere Tasten: Blockiert
 *
 * HINWEIS: Access-Formular hat 7-Tage-Struktur (Tag1-Tag7) mit je:
 *   - TagX_Name (KeyDown), TagX_von (KeyDown für Tag1), TagX_bis
 *   - TagX_Zuo_ID, TagX_MA_ID, TagX_fraglich
 */

// VBA KeyCodes
const VBA_KEY = {
    DELETE: 46,
    ARROW_LEFT: 37,
    ARROW_UP: 38,
    ARROW_RIGHT: 39,
    ARROW_DOWN: 40,
    ENTER: 13,
    ESCAPE: 27,
    TAB: 9
};

const state = {
    records: [],
    selectedIndex: -1,
    isEmbedded: false,
    // Für 7-Tage-Struktur (zukünftige Erweiterung)
    currentField: null,  // GL_DP_Objekt_Fld equivalent
    absolutePosition: -1  // GL_lngPos equivalent
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

        // Row DblClick (VBA: OnDblClick) - entspricht fTest/fTest1 in VBA
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

        // KeyDown Events (VBA: TagX_Name_KeyDown, TagX_von_KeyDown)
        row.setAttribute('tabindex', '0'); // Zeile fokussierbar machen
        row.addEventListener('keydown', (event) => {
            handleRowKeyDown(event, idx, row);
        });
    });
}

/**
 * KeyDown Event Handler für Zeilen
 * Entspricht VBA: TagX_Name_KeyDown, TagX_von_KeyDown
 *
 * VBA-Logik:
 * - Delete (46): MA-ID aus Zuordnung entfernen (fDel_MA_ID_Zuo)
 * - ArrowDown (40): Auftragstamm öffnen (fopenAuftragstamm)
 * - ArrowKeys (37-40): Navigation erlaubt
 * - Andere Tasten: Blockiert (KeyCode = 0)
 *
 * @param {KeyboardEvent} event
 * @param {number} idx - Zeilen-Index
 * @param {HTMLElement} row - Die Zeile
 */
function handleRowKeyDown(event, idx, row) {
    const rec = state.records[idx];
    if (!rec) return;

    const keyCode = event.keyCode || event.which;

    // Speichere aktuelle Position (VBA: GL_lngPos = Me.Recordset.AbsolutePosition)
    state.absolutePosition = idx;
    state.currentField = row.dataset.field || 'row';

    switch (keyCode) {
        case VBA_KEY.DELETE:
            // VBA: fDel_MA_ID_Zuo - MA aus Zuordnung entfernen
            event.preventDefault();
            handleDeleteKey(rec, idx);
            break;

        case VBA_KEY.ARROW_DOWN:
            // VBA: fopenAuftragstamm(VA_ID, VADatum_ID)
            event.preventDefault();
            handleArrowDown(rec, idx);
            break;

        case VBA_KEY.ARROW_UP:
            // Navigation nach oben
            event.preventDefault();
            navigateRow(idx - 1);
            break;

        case VBA_KEY.ARROW_LEFT:
        case VBA_KEY.ARROW_RIGHT:
            // Pfeiltasten erlaubt (VBA: KeyCode 37-40 durchlassen)
            break;

        case VBA_KEY.ENTER:
            // Enter = DblClick Verhalten
            event.preventDefault();
            row.dispatchEvent(new MouseEvent('dblclick', { bubbles: true }));
            break;

        case VBA_KEY.ESCAPE:
            // Escape = Auswahl aufheben
            event.preventDefault();
            selectRow(-1);
            break;

        case VBA_KEY.TAB:
            // Tab-Navigation erlauben
            break;

        default:
            // VBA: Andere Tasten blockieren (KeyCode = 0)
            // In HTML: Verhindern dass Zeichen eingegeben werden
            if (!event.ctrlKey && !event.metaKey && !event.altKey) {
                // Nur Zeichen-Eingabe blockieren, Shortcuts erlauben
                if (event.key.length === 1) {
                    event.preventDefault();
                    console.log('[sub_DP_Grund] Taste blockiert:', event.key);
                }
            }
    }
}

/**
 * VBA: fDel_MA_ID_Zuo - MA aus Zuordnung entfernen bei Delete-Taste
 *
 * Original VBA:
 * CurrentDb.Execute("UPDATE tbl_MA_VA_Zuordnung SET MA_ID = 0, IstFraglich = 0 WHERE ID = " & iZuo)
 * Call fTag_Schicht_Update(iVADatum_ID, iVAStart_ID)
 */
async function handleDeleteKey(rec, idx) {
    const zuoId = rec.Zuo_ID || rec.Tag_Zuo_ID;

    if (!zuoId || zuoId <= 0) {
        console.log('[sub_DP_Grund] Delete: Keine Zuordnungs-ID vorhanden');
        return;
    }

    // Bestätigung (optional, VBA hat keine)
    // In VBA wird direkt gelöscht

    console.log('[sub_DP_Grund] Delete-Taste: Entferne MA aus Zuordnung', zuoId);

    // Parent informieren für VBA Bridge Aufruf
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'delete_ma_zuordnung',
            name: 'sub_DP_Grund',
            zuo_id: zuoId,
            record: rec
        }, '*');
    } else {
        // Direkter API-Aufruf
        try {
            const response = await fetch(`http://localhost:5000/api/zuordnungen/${zuoId}/remove-ma`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ma_id: 0, ist_fraglich: 0 })
            });

            if (response.ok) {
                console.log('[sub_DP_Grund] MA erfolgreich aus Zuordnung entfernt');
                loadData(); // Requery
            } else {
                console.error('[sub_DP_Grund] Fehler beim Entfernen:', response.status);
            }
        } catch (err) {
            console.error('[sub_DP_Grund] API-Fehler bei Delete:', err);
        }
    }
}

/**
 * VBA: ArrowDown öffnet Auftragstamm
 *
 * Original VBA:
 * If KeyCode = 40 Then 'nach unten Taste
 *     VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID = " & iZuo)
 *     VADatum_ID = TLookup("VADatum_ID", ZUORDNUNG, "ID = " & iZuo)
 *     Call fopenAuftragstamm(VA_ID, VADatum_ID)
 * End If
 */
function handleArrowDown(rec, idx) {
    const vaId = rec.VA_ID;
    const vaDatumId = rec.VADatum_ID || rec.Datum_ID;

    if (!vaId) {
        console.log('[sub_DP_Grund] ArrowDown: Keine VA_ID vorhanden');
        // Normale Navigation nach unten
        navigateRow(idx + 1);
        return;
    }

    console.log('[sub_DP_Grund] ArrowDown: Öffne Auftragstamm', { vaId, vaDatumId });

    // Parent informieren (VBA: fopenAuftragstamm)
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'open_auftragstamm',
            name: 'sub_DP_Grund',
            va_id: vaId,
            vadatum_id: vaDatumId
        }, '*');
    } else {
        // Standalone: Navigation oder Alert
        console.log('[sub_DP_Grund] Auftragstamm öffnen:', vaId);
        // Alternativ: window.open('frm_va_Auftragstamm.html?va_id=' + vaId, '_blank');
    }
}

/**
 * Navigation zu einer anderen Zeile
 */
function navigateRow(newIdx) {
    if (newIdx >= 0 && newIdx < state.records.length) {
        selectRow(newIdx);
        // Fokus auf neue Zeile setzen
        const newRow = tbody.querySelector(`tr[data-index="${newIdx}"]`);
        if (newRow) {
            newRow.focus();
        }
    }
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

/**
 * Globale Keyboard-Unterstützung für Container
 * Ermöglicht Navigation auch wenn keine Zeile fokussiert ist
 */
function initGlobalKeyboard() {
    const container = document.querySelector('.subform-content');
    if (!container) return;

    container.setAttribute('tabindex', '-1');
    container.addEventListener('keydown', (event) => {
        // Nur wenn keine Zeile fokussiert ist
        if (document.activeElement.tagName === 'TR') return;

        const keyCode = event.keyCode || event.which;

        if (keyCode === VBA_KEY.ARROW_DOWN || keyCode === VBA_KEY.ARROW_UP) {
            event.preventDefault();

            // Erste/Letzte Zeile auswählen
            let targetIdx = state.selectedIndex;
            if (keyCode === VBA_KEY.ARROW_DOWN) {
                targetIdx = targetIdx < 0 ? 0 : Math.min(targetIdx + 1, state.records.length - 1);
            } else {
                targetIdx = targetIdx < 0 ? state.records.length - 1 : Math.max(targetIdx - 1, 0);
            }

            if (targetIdx >= 0 && targetIdx < state.records.length) {
                navigateRow(targetIdx);
            }
        }
    });
}

// Globale API exportieren
window.SubDPGrund = {
    requery: loadData,
    selectRow: selectRow,
    navigateRow: navigateRow,
    getState: () => ({ ...state }),
    getSelectedRecord: () => state.records[state.selectedIndex] || null,
    // VBA-Kompatible Funktionen
    handleDeleteKey: handleDeleteKey,
    handleArrowDown: handleArrowDown
};

document.addEventListener('DOMContentLoaded', () => {
    init();
    initGlobalKeyboard();
});
