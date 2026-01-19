/**
 * sub_DP_Grund_MA.logic.js
 * Logik fuer Dienstplan-Gruende pro Mitarbeiter Subform
 *
 * VBA-Events:
 * - Row Click: Eintrag auswählen
 * - DblClick: Eintrag bearbeiten (fTest-Logik)
 * - AfterUpdate: Nach Änderung Parent informieren
 * - Filter via cboGrund: Filterung nach Grund-Typ
 *
 * VBA-Referenz: Form_sub_DP_Grund_MA.bas
 * - fTest(): MA-zu-Auftrag Zuordnung bei DblClick auf Tag-Feld
 * - fDel_MA_ID_Zuo(): MA-Zuordnung loeschen bei Entf-Taste
 * - Tag*_Name_DblClick: Ruft fTest auf
 * - Tag*_Name_KeyDown: Ruft fDel_MA_ID_Zuo bei Entf-Taste
 */

const state = {
    MA_ID: null,
    Startdat: null, // Startdatum der Wochenansicht (wie Access: Me!Startdat)
    records: [],
    filteredRecords: [],
    selectedIndex: -1,
    filterGrund: '',
    isEmbedded: false,
    activeTagNr: null // Aktiver Tag (1-7) fuer fTest
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
            if (data.Startdat !== undefined) state.Startdat = data.Startdat;
            loadData();
            break;

        case 'requery':
            loadData();
            break;

        // VBA-Parität: Tag-Feld Events vom Parent-Formular
        case 'tag_dblclick':
            // Parent sendet: { type: 'tag_dblclick', tagNr: 1-7, ma_id: X, startdat: 'YYYY-MM-DD' }
            if (data.tagNr && data.ma_id) {
                handleTagDblClick(data.tagNr, data.ma_id, data.startdat || state.Startdat);
            }
            break;

        case 'tag_keydown':
            // Parent sendet: { type: 'tag_keydown', tagNr: 1-7, zuo_id: X, keyCode: 46 }
            if (data.tagNr !== undefined && data.keyCode !== undefined) {
                const handled = handleTagKeyDown(data.tagNr, data.zuo_id, data.keyCode);
                // Antwort an Parent senden
                window.parent.postMessage({
                    type: 'tag_keydown_response',
                    handled: handled,
                    tagNr: data.tagNr
                }, '*');
            }
            break;

        case 'set_startdat':
            // Setzt nur Startdatum ohne Daten neu zu laden
            if (data.startdat) {
                state.Startdat = data.startdat;
            }
            break;

        case 'fTest':
            // Direkter Aufruf von fTest vom Parent
            if (data.tagNr && data.ma_id) {
                fTest(data.tagNr, data.ma_id, data.startdat || state.Startdat);
            }
            break;

        case 'fDel_MA_ID_Zuo':
            // Direkter Aufruf von fDel_MA_ID_Zuo vom Parent
            if (data.zuo_id !== undefined) {
                fDel_MA_ID_Zuo(data.zuo_id, data.keyCode || 46);
            }
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

/**
 * fTest - MA-zu-Auftrag Zuordnung (VBA-Parität)
 *
 * VBA-Original: Form_sub_DP_Grund_MA.fTest (Zeile 155-339)
 *
 * Logik:
 * 1. Ermittelt Datum aus Tag-Nummer (Tag1-7) und Startdat
 * 2. Sucht offene Auftraege fuer dieses Datum (TVA_Offen=True, TVA_Soll>0)
 * 3. Bei 0 Auftraegen: Meldung "Keine Auftraege mit leeren Plaetzen"
 * 4. Bei genau 1 Auftrag + 1 Schicht: Direktzuordnung des MA
 * 5. Sonst: Oeffnet Popup frmTop_DP_MA_Auftrag_Zuo zur manuellen Auswahl
 *
 * @param {number} tagNr - Tag-Nummer (1-7)
 * @param {number} maId - Mitarbeiter-ID
 * @param {Date|string} startdat - Startdatum der Wochenansicht
 */
async function fTest(tagNr, maId, startdat) {
    console.log('[fTest] Start - TagNr:', tagNr, 'MA_ID:', maId, 'Startdat:', startdat);

    if (!maId || maId === 0) {
        console.warn('[fTest] Keine MA_ID - Abbruch');
        return;
    }

    // Datum berechnen: Startdat + (TagNr - 1)
    const baseDate = startdat ? new Date(startdat) : new Date(state.Startdat);
    const targetDate = new Date(baseDate);
    targetDate.setDate(targetDate.getDate() + (tagNr - 1));

    const dtOdat = formatDateForAPI(targetDate);
    console.log('[fTest] Ziel-Datum:', dtOdat);

    try {
        // 1. Offene Auftraege fuer dieses Datum suchen
        // VBA: strSQL = "SELECT ... FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ... WHERE VADatum = dtOdat AND TVA_Offen = True AND TVA_Soll > 0"
        const response = await fetch(`http://localhost:5000/api/auftraege/offen?datum=${dtOdat}`);

        if (!response.ok) {
            // Fallback: Alle Auftraege fuer Datum holen und filtern
            const fallbackResponse = await fetch(`http://localhost:5000/api/einsatztage?datum=${dtOdat}`);
            if (!fallbackResponse.ok) {
                throw new Error(`API Fehler: ${response.status}`);
            }
            const allTage = await fallbackResponse.json();
            // Filtern auf offene mit Soll > Ist
            const offeneAuftraege = (Array.isArray(allTage) ? allTage : allTage.data || [])
                .filter(a => a.TVA_Offen && a.TVA_Soll > a.TVA_Ist);

            return processOffeneAuftraege(offeneAuftraege, maId, dtOdat, tagNr);
        }

        const offeneAuftraege = await response.json();
        return processOffeneAuftraege(
            Array.isArray(offeneAuftraege) ? offeneAuftraege : offeneAuftraege.data || [],
            maId, dtOdat, tagNr
        );

    } catch (err) {
        console.error('[fTest] API Fehler:', err);
        showMessage('Fehler beim Laden der Auftraege: ' + err.message, 'error');
    }
}

/**
 * Verarbeitet die Liste offener Auftraege (VBA fTest Zeile 224-281)
 */
async function processOffeneAuftraege(auftraege, maId, datum, tagNr) {
    const count = auftraege.length;
    console.log('[fTest] Offene Auftraege gefunden:', count);

    // 0 Auftraege: Meldung
    if (count === 0) {
        // VBA: MsgBox "Keine Aufträge mit leeren Plätzen im gewünschten Zeitraum vorhanden"
        showMessage('Keine Aufträge mit leeren Plätzen im gewünschten Zeitraum vorhanden', 'warning');
        return;
    }

    // 1 Auftrag: Schichten pruefen
    if (count === 1) {
        const auftrag = auftraege[0];
        const vaId = auftrag.VA_ID;
        const vaDatumId = auftrag.VADatum_ID || auftrag.ID;

        console.log('[fTest] Genau 1 Auftrag - VA_ID:', vaId, 'VADatum_ID:', vaDatumId);

        // Schichten fuer diesen Auftrag laden
        // VBA: strSQL = "SELECT ID AS VAStart_ID ... FROM tbl_VA_Start WHERE VADatum_ID = X AND VA_ID = Y AND MA_Anzahl > 0 AND MA_Anzahl_Ist < MA_Anzahl"
        try {
            const schichtenResponse = await fetch(
                `http://localhost:5000/api/auftraege/${vaId}/schichten?vadatum_id=${vaDatumId}&offen=true`
            );

            if (!schichtenResponse.ok) {
                throw new Error(`Schichten-API Fehler: ${schichtenResponse.status}`);
            }

            const schichten = await schichtenResponse.json();
            const offeneSchichten = (Array.isArray(schichten) ? schichten : schichten.data || [])
                .filter(s => s.MA_Anzahl > 0 && (s.MA_Anzahl_Ist || 0) < s.MA_Anzahl);

            console.log('[fTest] Offene Schichten:', offeneSchichten.length);

            // 1 Auftrag + 1 Schicht: Direktzuordnung
            if (offeneSchichten.length === 1) {
                const schicht = offeneSchichten[0];
                const vaStartId = schicht.VAStart_ID || schicht.ID;

                console.log('[fTest] Direktzuordnung - VAStart_ID:', vaStartId);
                await direktZuordnung(maId, vaStartId, vaDatumId);
                return;
            }

            // 1 Auftrag + mehrere Schichten: Popup oeffnen
            openZuordnungsPopup(maId, datum, auftrag, offeneSchichten, tagNr);

        } catch (err) {
            console.error('[fTest] Schichten-Fehler:', err);
            // Fallback: Popup oeffnen
            openZuordnungsPopup(maId, datum, auftrag, [], tagNr);
        }

    } else {
        // Mehrere Auftraege: Popup oeffnen
        console.log('[fTest] Mehrere Auftraege - Popup oeffnen');
        openZuordnungsPopup(maId, datum, null, [], tagNr, auftraege);
    }
}

/**
 * Direktzuordnung eines MA zu einer Schicht (VBA fTest Zeile 243-246)
 *
 * VBA-Original:
 *   k = Nz(DMin("ID", "tbl_MA_VA_Zuordnung", "VAStart_ID = " & iVAStart_ID & " AND MA_ID = 0"), 0)
 *   CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET MA_ID = " & iMA_ID & " WHERE ID = " & k)
 *   Call fTag_Schicht_Update(iVADatum_ID, iVAStart_ID)
 *   Form_frm_DP_Dienstplan_MA.btnSta
 */
async function direktZuordnung(maId, vaStartId, vaDatumId) {
    console.log('[fTest:direktZuordnung] MA_ID:', maId, 'VAStart_ID:', vaStartId, 'VADatum_ID:', vaDatumId);

    try {
        // API-Call: Zuordnung aktualisieren (MA_ID setzen fuer freien Platz)
        const response = await fetch('http://localhost:5000/api/zuordnungen/zuweisen', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                ma_id: maId,
                vastart_id: vaStartId,
                vadatum_id: vaDatumId
            })
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.message || `API Fehler: ${response.status}`);
        }

        const result = await response.json();
        console.log('[fTest:direktZuordnung] Erfolg:', result);

        // Parent informieren (VBA: Form_frm_DP_Dienstplan_MA.btnSta)
        if (state.isEmbedded) {
            window.parent.postMessage({
                type: 'zuordnung_erfolgt',
                name: 'sub_DP_Grund_MA',
                ma_id: maId,
                vastart_id: vaStartId,
                action: 'refresh'
            }, '*');
        }

        showMessage('Mitarbeiter erfolgreich zugeordnet', 'success');

    } catch (err) {
        console.error('[fTest:direktZuordnung] Fehler:', err);
        showMessage('Zuordnung fehlgeschlagen: ' + err.message, 'error');
    }
}

/**
 * Oeffnet das Zuordnungs-Popup (VBA fTest Zeile 252-280)
 *
 * VBA-Original:
 *   DoCmd.OpenForm "frmTop_DP_MA_Auftrag_Zuo"
 *   frm!cboMA_ID = iMA_ID
 *   frm!dtPlanDatum = dtOdat
 *   frm!ListeAuft.RowSource = strSQL
 */
function openZuordnungsPopup(maId, datum, auftrag, schichten, tagNr, auftraege) {
    console.log('[fTest:openZuordnungsPopup] MA_ID:', maId, 'Datum:', datum);

    // URL mit Parametern aufbauen
    const params = new URLSearchParams({
        ma_id: maId,
        datum: datum,
        tag_nr: tagNr
    });

    if (auftrag) {
        params.append('va_id', auftrag.VA_ID);
        params.append('vadatum_id', auftrag.VADatum_ID || auftrag.ID);
    }

    if (auftraege && auftraege.length > 0) {
        params.append('auftraege', JSON.stringify(auftraege.map(a => ({
            VA_ID: a.VA_ID,
            VADatum_ID: a.VADatum_ID || a.ID,
            Auftrag: a.Auftrag,
            ObjOrt: a.ObjOrt || a.Objekt || ''
        }))));
    }

    const popupUrl = `frmTop_DP_MA_Auftrag_Zuo.html?${params.toString()}`;

    // Popup oeffnen oder Shell-Navigation
    if (window.parent?.ConsysShell?.showPopup) {
        window.parent.ConsysShell.showPopup(popupUrl, {
            title: 'Mitarbeiter-Auftrag Zuordnung',
            width: 800,
            height: 600
        });
    } else {
        window.open(popupUrl, 'MA_Auftrag_Zuo', 'width=800,height=600,menubar=no,toolbar=no,scrollbars=yes');
    }

    // Parent informieren
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'popup_opened',
            name: 'frmTop_DP_MA_Auftrag_Zuo',
            ma_id: maId,
            datum: datum
        }, '*');
    }
}

/**
 * fDel_MA_ID_Zuo - MA-Zuordnung loeschen bei Entf-Taste (VBA-Parität)
 *
 * VBA-Original: Form_sub_DP_Grund_MA.fDel_MA_ID_Zuo (Zeile 20-36)
 *
 * Bei Druecken der Entf-Taste (KeyCode=46) auf einem Tag-Feld:
 * - Zuordnung loeschen (MA_ID = 0 setzen)
 * - Schicht-Update aufrufen
 * - Dienstplan aktualisieren
 *
 * @param {number} zuoId - Zuordnungs-ID
 * @param {number} keyCode - Tastaturcode (46 = Entf)
 */
async function fDel_MA_ID_Zuo(zuoId, keyCode) {
    // Nur bei Entf-Taste (KeyCode 46) und gültiger Zuordnungs-ID
    if (keyCode !== 46 || !zuoId || zuoId === 0) {
        console.log('[fDel_MA_ID_Zuo] Keine Aktion - KeyCode:', keyCode, 'ZuoId:', zuoId);
        return false;
    }

    console.log('[fDel_MA_ID_Zuo] Loeschen - Zuo_ID:', zuoId);

    try {
        // VBA: CurrentDb.Execute ("UPDATE tbl_MA_VA_Zuordnung SET MA_ID = 0, IstFraglich = 0 WHERE ID = " & iZuo)
        const response = await fetch(`http://localhost:5000/api/zuordnungen/${zuoId}/entfernen`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                ma_id: 0,
                ist_fraglich: 0
            })
        });

        if (!response.ok) {
            // Fallback: DELETE-Methode
            const deleteResponse = await fetch(`http://localhost:5000/api/zuordnungen/${zuoId}`, {
                method: 'DELETE'
            });

            if (!deleteResponse.ok) {
                throw new Error(`API Fehler: ${response.status}`);
            }
        }

        console.log('[fDel_MA_ID_Zuo] Zuordnung geloescht');

        // Parent informieren (VBA: Form_frm_DP_Dienstplan_MA.btnSta)
        if (state.isEmbedded) {
            window.parent.postMessage({
                type: 'zuordnung_geloescht',
                name: 'sub_DP_Grund_MA',
                zuo_id: zuoId,
                action: 'refresh'
            }, '*');
        }

        showMessage('Zuordnung entfernt', 'success');
        return true;

    } catch (err) {
        console.error('[fDel_MA_ID_Zuo] Fehler:', err);
        showMessage('Loeschen fehlgeschlagen: ' + err.message, 'error');
        return false;
    }
}

/**
 * Datum fuer API formatieren (YYYY-MM-DD)
 */
function formatDateForAPI(date) {
    if (!date) return '';
    const d = new Date(date);
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * Nachricht anzeigen
 */
function showMessage(message, type = 'info') {
    console.log(`[sub_DP_Grund_MA] ${type.toUpperCase()}: ${message}`);

    // Toast-Benachrichtigung wenn verfuegbar
    if (window.Toast) {
        if (type === 'error') Toast.error(message);
        else if (type === 'warning') Toast.warning(message);
        else if (type === 'success') Toast.success(message);
        else Toast.info(message);
    } else if (type === 'error' || type === 'warning') {
        // Fallback: Alert fuer Fehler/Warnungen
        alert(message);
    }
}

/**
 * Tag-Feld DblClick Handler fuer fTest (VBA Tag*_Name_DblClick)
 *
 * Wird vom Parent-Formular aufgerufen wenn ein Tages-Feld doppelgeklickt wird.
 */
function handleTagDblClick(tagNr, maId, startdat) {
    console.log('[handleTagDblClick] TagNr:', tagNr, 'MA_ID:', maId);
    state.activeTagNr = tagNr;
    fTest(tagNr, maId, startdat);
}

/**
 * Tag-Feld KeyDown Handler fuer Loeschen (VBA Tag*_Name_KeyDown)
 *
 * Wird vom Parent-Formular aufgerufen wenn eine Taste auf Tages-Feld gedrueckt wird.
 */
function handleTagKeyDown(tagNr, zuoId, keyCode) {
    console.log('[handleTagKeyDown] TagNr:', tagNr, 'ZuoId:', zuoId, 'KeyCode:', keyCode);

    if (keyCode === 46) { // Entf-Taste
        fDel_MA_ID_Zuo(zuoId, keyCode);
        return true; // Event konsumiert
    }

    // Pfeiltasten erlauben (37-40), sonst blockieren (wie VBA)
    if (keyCode < 37 || keyCode > 40) {
        return true; // Event blockieren
    }

    return false;
}

window.SubDPGrundMA = {
    setLinkParams(MA_ID, Startdat) {
        state.MA_ID = MA_ID;
        if (Startdat) state.Startdat = Startdat;
        loadData();
    },
    requery: loadData,

    // fTest API (VBA-Parität)
    fTest: fTest,
    fDel_MA_ID_Zuo: fDel_MA_ID_Zuo,
    handleTagDblClick: handleTagDblClick,
    handleTagKeyDown: handleTagKeyDown,

    // State-Zugriff
    getState: () => ({ ...state }),
    setStartdat: (date) => { state.Startdat = date; }
};

document.addEventListener('DOMContentLoaded', init);
