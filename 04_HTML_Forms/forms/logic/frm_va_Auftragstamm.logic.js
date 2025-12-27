/**
 * frm_va_Auftragstamm.logic.js
 * Hauptformular - Auftragsverwaltung
 * Kommuniziert mit eingebetteten Subforms via PostMessage
 */
import { Bridge } from '../api/bridgeClient.js';

// ============ STATE ============
const state = {
    currentRecord: null,
    currentVA_ID: null,
    currentVADatum: null,
    currentVAStart_ID: null,
    records: [],
    recordIndex: 0,
    subformsReady: {}
};

// ============ SUBFORM REGISTRY ============
const subformIds = [
    'frm_Menuefuehrung',
    'sub_VA_Start',
    'sub_MA_VA_Zuordnung',
    'sub_MA_VA_Planung_Absage',
    'sub_MA_VA_Zuordnung_Status',
    'sub_ZusatzDateien',
    'sub_VA_Anzeige',
    'zsub_lstAuftrag'
];

// ============ INIT ============
function init() {
    console.log('[Auftragstamm] Init');

    // Datum setzen
    const lblDatum = document.getElementById('lbl_Datum');
    if (lblDatum) {
        lblDatum.textContent = new Date().toLocaleDateString('de-DE');
    }

    // Tab-Handling
    initTabs();

    // Button-Events
    initButtons();

    // PostMessage-Listener fuer Subforms
    window.addEventListener('message', handleSubformMessage);

    // Initial-Daten laden
    loadInitialData();
}

// ============ TAB HANDLING ============
function initTabs() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.dataset.tab;

            // Buttons aktualisieren
            tabBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            // Panes aktualisieren
            document.querySelectorAll('.tab-pane').forEach(pane => {
                pane.classList.remove('active');
            });
            document.getElementById(tabId)?.classList.add('active');

            // Subforms im Tab aktualisieren
            requeryTabSubforms(tabId);
        });
    });
}

function requeryTabSubforms(tabId) {
    switch (tabId) {
        case 'pgMA_Zusage':
            sendToSubform('sub_VA_Start', { type: 'requery' });
            sendToSubform('sub_MA_VA_Zuordnung', { type: 'requery' });
            sendToSubform('sub_MA_VA_Planung_Absage', { type: 'requery' });
            break;
        case 'pgMA_Plan':
            sendToSubform('sub_MA_VA_Zuordnung_Status', { type: 'requery' });
            break;
        case 'pgAttach':
            sendToSubform('sub_ZusatzDateien', { type: 'requery' });
            break;
    }
}

// ============ BUTTON HANDLERS ============
function initButtons() {
    // Navigation - Angepasst an tatsächliche HTML-IDs
    bindButton('btnErster', () => gotoRecord(0));
    bindButton('btnVorheriger', () => gotoRecord(state.recordIndex - 1));
    bindButton('btnNaechster', () => gotoRecord(state.recordIndex + 1));
    bindButton('btnLetzter', () => gotoRecord(state.records.length - 1));
    bindButton('btnRueck', undoChanges);

    // Aktualisieren
    bindButton('btnReq', requeryAll);

    // Auftragsliste Filter
    bindButton('btnAbWann', applyAuftraegeFilter);
    bindButton('btnTgBack', () => shiftAuftraegeFilter(-7));
    bindButton('btnTgVor', () => shiftAuftraegeFilter(7));
    bindButton('btnHeute', () => setAuftraegeFilterToday());

    // Aktions-Buttons - Auftragsverwaltung
    bindButton('btnSchnellPlan', openMitarbeiterauswahl);
    bindButton('btn_N_HTMLAnsicht', openHTMLAnsicht);
    bindButton('btn_Posliste_oeffnen', openPositionen);
    bindButton('btnAuftragKopieren', kopierenAuftrag);
    bindButton('btnneuveranst', neuerAuftrag);
    bindButton('mcobtnDelete', loeschenAuftrag);

    // E-Mail/Listen Buttons
    bindButton('btnMailEins', () => sendeEinsatzliste('MA'));
    bindButton('btn_Autosend_BOS', () => sendeEinsatzliste('BOS'));
    bindButton('btnMailSub', () => sendeEinsatzliste('SUB'));
    bindButton('btnDruckZusage', druckeEinsatzliste);
    bindButton('btn_ListeStd', druckeNamenlisteESS);

    // Auftragsliste Klick-Handler
    setupAuftragslisteClickHandler();
}

function setupAuftragslisteClickHandler() {
    const tbody = document.querySelector('#tblAuftragsliste tbody');
    if (!tbody) return;

    tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
            row.classList.add('selected');

            // Auftrag laden wenn data-id vorhanden
            const id = row.dataset.id;
            if (id) loadAuftrag(id);
        });
    });
}

function bindButton(id, handler) {
    const btn = document.getElementById(id);
    if (btn) {
        btn.addEventListener('click', handler);
    }
}

// ============ SUBFORM COMMUNICATION ============
function handleSubformMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    console.log('[Auftragstamm] Message from subform:', data.type, data.name);

    switch (data.type) {
        case 'subform_ready':
            state.subformsReady[data.name] = true;
            // Link-Parameter senden wenn Hauptdatensatz geladen
            if (state.currentVA_ID) {
                sendLinkParamsToSubform(data.name);
            }
            break;

        case 'subform_selection':
            handleSubformSelection(data);
            break;

        case 'open_auftrag':
            // Von zsub_lstAuftrag - Auftrag oeffnen
            loadAuftrag(data.id);
            break;

        case 'schicht_selected':
            // Von sub_VA_Start - Schicht gewaehlt
            state.currentVAStart_ID = data.VAStart_ID;
            state.currentVADatum = data.VADatum;
            updateMASubforms();
            break;

        case 'request_link_params':
            sendLinkParamsToSubform(data.name);
            break;
    }
}

function sendToSubform(subformId, message) {
    const iframe = document.getElementById(subformId);
    if (iframe && iframe.contentWindow) {
        try {
            iframe.contentWindow.postMessage(message, '*');
        } catch (e) {
            console.warn('[Auftragstamm] Kann nicht an Subform senden:', subformId, e);
        }
    }
}

function sendLinkParamsToSubform(subformName) {
    const params = {
        type: 'set_link_params',
        VA_ID: state.currentVA_ID,
        VADatum: state.currentVADatum,
        VAStart_ID: state.currentVAStart_ID
    };
    sendToSubform(subformName, params);
}

function updateAllSubforms() {
    const params = {
        type: 'set_link_params',
        VA_ID: state.currentVA_ID,
        VADatum: state.currentVADatum,
        VAStart_ID: state.currentVAStart_ID
    };

    subformIds.forEach(id => {
        sendToSubform(id, params);
    });
}

function updateMASubforms() {
    // MA-Zuordnung und Absagen-Subforms mit neuer Schicht aktualisieren
    const params = {
        type: 'set_link_params',
        VA_ID: state.currentVA_ID,
        VADatum: state.currentVADatum,
        VAStart_ID: state.currentVAStart_ID
    };

    sendToSubform('sub_MA_VA_Zuordnung', params);
    sendToSubform('sub_MA_VA_Planung_Absage', params);
}

function handleSubformSelection(data) {
    // Subform hat Datensatz gewaehlt
    console.log('[Auftragstamm] Subform Selection:', data.name, data.record);
}

// ============ DATA LOADING ============
async function loadInitialData() {
    try {
        // Combo-Boxen fuellen
        await loadCombos();

        // Auftragsliste laden
        setAuftraegeFilterToday();

    } catch (error) {
        console.error('[Auftragstamm] Init-Fehler:', error);
    }
}

async function loadCombos() {
    try {
        // Auftraege
        const auftraege = await Bridge.execute('getAuftragListe');
        fillCombo('Kombinationsfeld656', auftraege.data, 'Auftrag', 'Auftrag');

        // Orte
        const orte = await Bridge.execute('getOrtListe');
        fillCombo('Ort', orte.data, 'Ort', 'Ort');

        // Objekte
        const objekte = await Bridge.execute('getObjektListe');
        fillCombo('Objekt', objekte.data, 'Objekt', 'Objekt');
        fillCombo('Objekt_ID', objekte.data, 'Objekt_ID', 'Objekt_ID');

        // Auftraggeber
        const kunden = await Bridge.execute('getKundenListe');
        fillCombo('veranstalter_id', kunden.data, 'kun_Id', 'kun_Firma');

        // Status
        const status = await Bridge.execute('getStatusListe');
        fillCombo('Veranst_Status_ID', status.data, 'Status_ID', 'Status_Bez');

        // Dienstkleidung
        const kleidung = await Bridge.execute('getDienstkleidungListe');
        fillCombo('Dienstkleidung', kleidung.data, 'DK_ID', 'DK_Bezeichnung');

    } catch (error) {
        console.warn('[Auftragstamm] Combo-Laden fehlgeschlagen:', error);
    }
}

function fillCombo(comboId, data, valueField, textField) {
    const combo = document.getElementById(comboId);
    if (!combo || !data) return;

    // Bestehende Optionen behalten (erste Option = Placeholder)
    const firstOption = combo.options[0];
    combo.innerHTML = '';
    if (firstOption) combo.appendChild(firstOption);

    data.forEach(item => {
        const opt = document.createElement('option');
        opt.value = item[valueField] || '';
        opt.textContent = item[textField] || '';
        combo.appendChild(opt);
    });
}

async function loadAuftrag(id) {
    try {
        const result = await Bridge.execute('getAuftrag', { id: id });
        // API gibt { data: { auftrag: {...}, einsatztage: [...], ... } }
        const auftrag = result.data?.auftrag || result.data;
        if (auftrag) {
            state.currentRecord = auftrag;
            state.currentVA_ID = auftrag.VA_ID || auftrag.ID;
            displayRecord(auftrag);

            // Einsatztage aus API-Response nutzen (falls vorhanden)
            if (result.data?.einsatztage) {
                fillVADatumComboFromData(result.data.einsatztage);
            } else {
                await loadVADatumCombo(state.currentVA_ID);
            }

            // Subforms aktualisieren
            updateAllSubforms();
        }
    } catch (error) {
        console.error('[Auftragstamm] Auftrag laden fehlgeschlagen:', error);
    }
}

function fillVADatumComboFromData(einsatztage) {
    const combo = document.getElementById('cboVADatum');
    if (!combo || !einsatztage || einsatztage.length === 0) return;

    combo.innerHTML = '<option value="">-- Datum wählen --</option>';

    einsatztage.forEach(item => {
        const opt = document.createElement('option');
        opt.value = item.VADatum || item.VADatum_ID;
        opt.textContent = formatDate(item.VADatum);
        combo.appendChild(opt);
    });

    // Erstes Datum auswählen
    combo.selectedIndex = 1;
    state.currentVADatum = einsatztage[0].VADatum;
}

async function loadVADatumCombo(va_id) {
    try {
        const result = await Bridge.execute('getVADatumListe', { VA_ID: va_id });
        const combo = document.getElementById('cboVADatum');
        if (!combo) return;

        combo.innerHTML = '<option value="">-- Datum --</option>';

        if (result.data && result.data.length > 0) {
            result.data.forEach(item => {
                const opt = document.createElement('option');
                opt.value = item.VADatum;
                opt.textContent = formatDate(item.VADatum);
                combo.appendChild(opt);
            });

            // Erstes Datum auswaehlen
            combo.selectedIndex = 1;
            state.currentVADatum = result.data[0].VADatum;
        }
    } catch (error) {
        console.warn('[Auftragstamm] VADatum-Liste fehlgeschlagen:', error);
    }
}

function displayRecord(rec) {
    if (!rec) return;

    // API-Felder haben VA_* Präfix
    setFieldValue('ID', rec.VA_ID || rec.ID);
    setFieldValue('Dat_VA_Von', formatDate(rec.VA_DatumVon || rec.Dat_VA_Von));
    setFieldValue('Dat_VA_Bis', formatDate(rec.VA_DatumBis || rec.Dat_VA_Bis));
    setFieldValue('Kombinationsfeld656', rec.VA_Bezeichnung || rec.Auftrag);
    setFieldValue('Ort', rec.VA_Ort || rec.Ort);
    setFieldValue('Objekt', rec.VA_Objekt || rec.Objekt);
    setFieldValue('Objekt_ID', rec.VA_Objekt_ID || rec.Objekt_ID);
    setFieldValue('Treffp_Zeit', rec.VA_Treffp_Zeit || rec.Treffp_Zeit);
    setFieldValue('Treffpunkt', rec.VA_Treffpunkt || rec.Treffpunkt);
    setFieldValue('PKW_Anzahl', rec.VA_PKW_Anzahl || rec.PKW_Anzahl);
    setFieldValue('Fahrtkosten', rec.VA_Fahrtkosten || rec.Fahrtkosten);
    setFieldValue('Dienstkleidung', rec.VA_Dienstkleidung || rec.Dienstkleidung);
    setFieldValue('Ansprechpartner', rec.VA_Ansprechpartner || rec.Ansprechpartner);
    setFieldValue('veranstalter_id', rec.VA_KD_ID || rec.Veranstalter_ID);
    setFieldValue('Veranst_Status_ID', rec.VA_Status || rec.Veranst_Status_ID);
    setFieldValue('Bemerkungen', rec.VA_Bemerkung || rec.Bemerkungen);

    // Footer - Erstellungs/Änderungsdaten
    setFieldValue('Text416', rec.VA_ErstelltVon || rec.Erst_von);
    setFieldValue('Text418', formatDateTime(rec.VA_ErstelltAm || rec.Erst_am));
    setFieldValue('Text419', rec.VA_GeaendertVon || rec.Aend_von);
    setFieldValue('Text422', formatDateTime(rec.VA_GeaendertAm || rec.Aend_am));

    // Checkbox
    const cbAutosend = document.getElementById('cbAutosendEL');
    if (cbAutosend) cbAutosend.checked = !!(rec.VA_AutosendEL || rec.Autosend_EL);

    // Kundeninfo anzeigen falls vorhanden
    if (rec.kunde) {
        console.log('[Auftragstamm] Kunde:', rec.kunde.KD_Name1);
    }
}

function setFieldValue(id, value) {
    const el = document.getElementById(id);
    if (!el) return;

    if (el.tagName === 'SELECT') {
        el.value = value || '';
    } else if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
        el.value = value || '';
    } else {
        el.textContent = value || '';
    }
}

// ============ NAVIGATION ============
function gotoRecord(index) {
    if (index < 0) index = 0;
    if (index >= state.records.length) index = state.records.length - 1;
    if (index < 0) return;

    state.recordIndex = index;
    const rec = state.records[index];
    if (rec && rec.ID) {
        loadAuftrag(rec.ID);
    }
}

function navigateVADatum(direction) {
    const combo = document.getElementById('cboVADatum');
    if (!combo) return;

    let newIndex = combo.selectedIndex + direction;
    if (newIndex < 1) newIndex = 1;
    if (newIndex >= combo.options.length) newIndex = combo.options.length - 1;

    combo.selectedIndex = newIndex;
    state.currentVADatum = combo.value;

    // Subforms aktualisieren
    sendToSubform('sub_VA_Start', { type: 'set_link_params', VA_ID: state.currentVA_ID, VADatum: state.currentVADatum });
}

// ============ AUFTRAGSLISTE FILTER ============
function applyAuftraegeFilter() {
    const datumInput = document.getElementById('Auftraege_ab');
    if (!datumInput) return;

    sendToSubform('zsub_lstAuftrag', {
        type: 'set_filter',
        filter: { ab_datum: datumInput.value }
    });
}

function shiftAuftraegeFilter(days) {
    const datumInput = document.getElementById('Auftraege_ab');
    if (!datumInput || !datumInput.value) return;

    const date = parseGermanDate(datumInput.value);
    if (date) {
        date.setDate(date.getDate() + days);
        datumInput.value = formatDate(date);
        applyAuftraegeFilter();
    }
}

function setAuftraegeFilterToday() {
    const datumInput = document.getElementById('Auftraege_ab');
    if (datumInput) {
        datumInput.value = formatDate(new Date());
        applyAuftraegeFilter();
    }
}

// ============ BRIDGE CALLS ============
async function callBridge(action) {
    try {
        const result = await Bridge.execute(action, {
            VA_ID: state.currentVA_ID,
            VADatum: state.currentVADatum,
            VAStart_ID: state.currentVAStart_ID
        });

        if (result.requery) {
            requeryAll();
        }

        return result;
    } catch (error) {
        console.error('[Auftragstamm] Bridge-Aufruf fehlgeschlagen:', action, error);
    }
}

// ============ BUTTON ACTION FUNCTIONS ============
function openMitarbeiterauswahl() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    window.open(`frm_MA_VA_Schnellauswahl.html?va_id=${state.currentVA_ID}`, '_blank');
}

function openHTMLAnsicht() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    alert('HTML-Ansicht: Funktion in Entwicklung\n\nAuftrag-ID: ' + state.currentVA_ID);
}

function openPositionen() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    window.open(`frm_OB_Objekt.html?va_id=${state.currentVA_ID}`, '_blank');
}

async function kopierenAuftrag() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    if (!confirm('Auftrag wirklich kopieren?')) return;

    try {
        setStatus('Kopiere Auftrag...');
        // API-Call zum Kopieren
        const result = await Bridge.execute('copyAuftrag', { id: state.currentVA_ID });
        if (result.data?.new_id) {
            setStatus('Auftrag kopiert');
            await loadAuftrag(result.data.new_id);
        }
    } catch (error) {
        setStatus('Fehler beim Kopieren');
        alert('Fehler beim Kopieren: ' + error.message);
    }
}

async function neuerAuftrag() {
    state.currentRecord = null;
    state.currentVA_ID = null;

    // Formular leeren
    const fields = ['ID', 'Dat_VA_Von', 'Dat_VA_Bis', 'cboAuftrag', 'txtOrt', 'txtObjekt'];
    fields.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });

    setStatus('Neuer Auftrag - Daten eingeben');

    // Fokus auf erstes Feld
    const firstField = document.getElementById('Dat_VA_Von');
    if (firstField) firstField.focus();
}

async function loeschenAuftrag() {
    if (!state.currentVA_ID) {
        alert('Kein Auftrag ausgewählt');
        return;
    }

    const auftrag = document.getElementById('cboAuftrag')?.value || '';
    if (!confirm(`Auftrag "${auftrag}" wirklich löschen?`)) return;

    try {
        setStatus('Lösche Auftrag...');
        await Bridge.auftraege.delete(state.currentVA_ID);
        setStatus('Auftrag gelöscht');

        // Auftragsliste neu laden
        await loadAuftraege();
    } catch (error) {
        setStatus('Fehler beim Löschen');
        alert('Fehler beim Löschen: ' + error.message);
    }
}

async function sendeEinsatzliste(typ) {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    setStatus(`Sende Einsatzliste an ${typ}...`);

    try {
        const result = await Bridge.execute('sendEinsatzliste', {
            va_id: state.currentVA_ID,
            typ: typ
        });

        if (result.success) {
            setStatus(`Einsatzliste an ${typ} gesendet`);
        } else {
            throw new Error(result.error || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler beim Senden');
        alert('Fehler beim Senden: ' + error.message);
    }
}

function druckeEinsatzliste() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    window.print();
}

function druckeNamenlisteESS() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    alert('Namensliste ESS: Funktion in Entwicklung');
}

async function loadAuftraege() {
    try {
        const result = await Bridge.auftraege.list({ limit: 50 });
        state.records = result.data || [];
        renderAuftragsliste();
    } catch (error) {
        console.error('[Auftragstamm] Fehler beim Laden der Aufträge:', error);
    }
}

function renderAuftragsliste() {
    const tbody = document.querySelector('#tblAuftragsliste tbody');
    if (!tbody || state.records.length === 0) return;

    tbody.innerHTML = state.records.map((rec, idx) => {
        const datum = formatDate(rec.VA_DatumVon || rec.Dat_VA_Von);
        const auftrag = rec.VA_Bezeichnung || rec.Auftrag || '';
        const ort = rec.VA_Ort || rec.Ort || '';
        const selected = idx === state.recordIndex ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${rec.VA_ID || rec.ID}" class="${selected}">
                <td>${datum}</td>
                <td>${auftrag}</td>
                <td>${ort}</td>
            </tr>
        `;
    }).join('');

    setupAuftragslisteClickHandler();
}

function setStatus(text) {
    const el = document.getElementById('lblStatus');
    if (el) el.textContent = text;
}

// ============ HELPER FUNCTIONS ============
function requeryAll() {
    if (state.currentVA_ID) {
        loadAuftrag(state.currentVA_ID);
    }
    subformIds.forEach(id => {
        sendToSubform(id, { type: 'requery' });
    });
}

function undoChanges() {
    if (state.currentRecord) {
        displayRecord(state.currentRecord);
    }
}

function closeForm() {
    if (window.parent !== window) {
        window.parent.postMessage({ type: 'close_form', name: 'frm_va_Auftragstamm' }, '*');
    } else {
        window.close();
    }
}

function formatDate(value) {
    if (!value) return '';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

function formatDateTime(value) {
    if (!value) return '';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE') + ' ' + d.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

function parseGermanDate(str) {
    if (!str) return null;
    const parts = str.split('.');
    if (parts.length !== 3) return null;
    return new Date(parts[2], parts[1] - 1, parts[0]);
}

// ============ EXPORT ============
window.Auftragstamm = {
    requery: requeryAll,
    loadAuftrag: loadAuftrag,
    getState() { return state; }
};

document.addEventListener('DOMContentLoaded', init);
