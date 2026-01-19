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
    currentVADatum_ID: null,
    currentVAStart_ID: null,
    currentObjekt_ID: null,
    currentTabellenNr: null,
    records: [],
    recordIndex: 0,
    subformsReady: {},
    previousStatus: null
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

    // Feld-Events (Access-Regeln)
    bindFieldEvents();

    // PostMessage-Listener fuer Subforms
    window.addEventListener('message', handleSubformMessage);

    // Initial-Daten laden
    loadInitialData();
}

// ============ TAB HANDLING ============
function initTabs() {
    const tabBtns = document.querySelectorAll('.access-tab-button');
    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.dataset.tab;
            if (!tabId) return;

            // Tabs werden im HTML per Inline-Script umgeschaltet,
            // hier nur Tab-spezifische Requerys ausfuehren
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
        case 'pgRechnung':
            sendToSubform('sub_tbl_Rch_Kopf', { type: 'requery' });
            sendToSubform('sub_tbl_Rch_Pos_Auftrag', { type: 'requery' });
            break;
    }
}

// ============ BUTTON HANDLERS ============
function initButtons() {
    // Navigation - Access IDs
    bindButton('Befehl43', () => gotoRecord(0));
    bindButton('Befehl41', () => gotoRecord(state.recordIndex - 1));
    bindButton('Befehl40', () => gotoRecord(state.recordIndex + 1));
    bindButton('btn_letzer_Datensatz', () => gotoRecord(state.records.length - 1));
    bindButton('btn_rueck', undoChanges);
    bindButton('Befehl38', closeForm);

    // Datum-Navigation
    bindButton('btnDatumLeft', () => navigateVADatum(-1));
    bindButton('btnDatumRight', () => navigateVADatum(1));

    // Aktualisieren
    bindButton('btnReq', requeryAll);

    // Auftragsliste Filter
    bindButton('btn_AbWann', applyAuftraegeFilter);
    bindButton('btnTgBack', () => shiftAuftraegeFilter(-7));
    bindButton('btnTgVor', () => shiftAuftraegeFilter(7));
    bindButton('btnHeute', () => setAuftraegeFilterToday());

    // Aktions-Buttons - Auftragsverwaltung
    bindButton('btnSchnellPlan', openMitarbeiterauswahl);
    bindButton('btn_Posliste_oeffnen', openPositionen);
    bindButton('btnmailpos', openZusatzdateien);
    bindButton('Befehl640', kopierenAuftrag);
    bindButton('btnneuveranst', neuerAuftrag);
    bindButton('mcobtnDelete', loeschenAuftrag);
    bindButton('cmd_Messezettel_NameEintragen', cmdMessezettelNameEintragen);
    bindButton('cmd_BWN_send', cmdBWNSend);

    // E-Mail/Listen Buttons
    bindButton('btnMailEins', () => sendeEinsatzliste('MA'));
    bindButton('btn_Autosend_BOS', () => sendeEinsatzliste('BOS'));
    bindButton('btnMailSub', () => sendeEinsatzliste('SUB'));
    bindButton('btnDruckZusage', druckeEinsatzliste);
    bindButton('btn_ListeStd', druckeNamenlisteESS);

    // Auftragsliste Klick-Handler
    setupAuftragslisteClickHandler();
}

function bindFieldEvents() {
    const status = document.getElementById('Veranst_Status_ID');
    if (status) {
        status.addEventListener('change', () => {
            const newValue = Number(status.value || 0);
            if (state.previousStatus !== null && state.previousStatus > 3 && newValue < state.previousStatus) {
                const ok = confirm('Status herabsetzen?');
                if (!ok) {
                    status.value = state.previousStatus;
                    return;
                }
            }
            state.previousStatus = newValue;
            applyStatusRules(newValue);
            sendToSubform('zsub_lstAuftrag', { type: 'recalc' });
        });
    }

    const veranstalter = document.getElementById('veranstalter_id');
    if (veranstalter) {
        veranstalter.addEventListener('change', () => {
            applyVeranstalterRules(veranstalter.value);
        });
        veranstalter.addEventListener('dblclick', () => {
            const shell = window.parent?.ConsysShell || window.ConsysShell;
            if (shell?.showForm) {
                shell.showForm('kundenstamm');
            }
        });
    }

    const objektId = document.getElementById('Objekt_ID');
    if (objektId) {
        objektId.addEventListener('change', () => {
            applyObjektRules(objektId.value);
        });
        objektId.addEventListener('dblclick', openPositionen);
    }

    const vaDatum = document.getElementById('cboVADatum');
    if (vaDatum) {
        vaDatum.addEventListener('change', () => {
            state.currentVADatum = vaDatum.value;
            state.currentVADatum_ID = vaDatum.value;
            updateMASubforms();
        });
    }

    const treffpZeit = document.getElementById('Treffp_Zeit');
    if (treffpZeit) {
        treffpZeit.addEventListener('keydown', (e) => {
            if (e.key !== 'Enter' && e.key !== 'Tab') return;
            const value = treffpZeit.value?.trim();
            if (!value) return;
            const valid = /^\d{1,2}(:\d{2})?$/.test(value) || /^\d{3,4}$/.test(value);
            if (!valid) {
                e.preventDefault();
                alert("Bitte Treffpunktzeit im Format 'hh:mm' oder 'hhmm' eingeben!");
                return;
            }
            if (/^\d{3,4}$/.test(value)) {
                const s = value.length === 3 ? value[0] : value.slice(0, 2);
                const m = value.length === 3 ? value.slice(1) : value.slice(2);
                treffpZeit.value = `${s.padStart(2, '0')}:${m}`;
            }
        });
    }
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
            state.currentVADatum_ID = data.VADatum_ID || data.VADatum;
            updateMASubforms();
            break;

        case 'request_link_params':
            sendLinkParamsToSubform(data.name);
            break;
    }
}

function sendToSubform(subformId, message) {
    const container = document.getElementById(subformId);
    const iframe = container?.tagName === 'IFRAME' ? container : container?.querySelector('iframe');
    if (iframe && iframe.contentWindow) {
        try {
            iframe.contentWindow.postMessage(message, '*');
        } catch (e) {
            console.warn('[Auftragstamm] Kann nicht an Subform senden:', subformId, e);
        }
    }
}

function sendLinkParamsToSubform(subformName) {
    const params = buildLinkParams();
    sendToSubform(subformName, params);
}

function updateAllSubforms() {
    const params = buildLinkParams();

    subformIds.forEach(id => {
        sendToSubform(id, params);
    });
}

function updateMASubforms() {
    // MA-Zuordnung und Absagen-Subforms mit neuer Schicht aktualisieren
    const params = buildLinkParams();

    sendToSubform('sub_MA_VA_Zuordnung', params);
    sendToSubform('sub_MA_VA_Planung_Absage', params);
}

function handleSubformSelection(data) {
    // Subform hat Datensatz gewaehlt
    console.log('[Auftragstamm] Subform Selection:', data.name, data.record);
    if (data.name === 'zsub_lstAuftrag' && data.record) {
        const id = data.record.VA_ID || data.record.ID;
        if (id) loadAuftrag(id);
    }
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
    state.currentVADatum_ID = einsatztage[0].VADatum_ID || einsatztage[0].VADatum;
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
            state.currentVADatum_ID = result.data[0].VADatum_ID || result.data[0].VADatum;
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

    state.currentObjekt_ID = rec.VA_Objekt_ID || rec.Objekt_ID;
    state.currentTabellenNr = getTabellenNr();
    state.previousStatus = Number(rec.VA_Status || rec.Veranst_Status_ID || 0);

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

    applyAccessRules(rec);
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
    state.currentVADatum_ID = combo.value;

    // Subforms aktualisieren
    sendToSubform('sub_VA_Start', buildLinkParams());
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
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }
    if (window.parent?.ConsysShell?.showForm) {
        localStorage.setItem('consec_va_id', String(state.currentVA_ID));
        window.parent.ConsysShell.showForm('schnellauswahl');
        return;
    }
    const url = new URL(`frm_MA_VA_Schnellauswahl.html?va_id=${state.currentVA_ID}`, window.location.href).href;
    window.open(url, '_blank');
}

function openHTMLAnsicht() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }
    alert('HTML-Ansicht: Funktion in Entwicklung. Auftrag-ID: ' + state.currentVA_ID);
}

function openPositionen() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }
    const url = new URL(`frm_OB_Objekt.html?va_id=${state.currentVA_ID}`, window.location.href).href;
    window.open(url, '_blank');
}

function openZusatzdateien() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }
    sendToSubform('sub_ZusatzDateien', { type: 'requery' });
    setStatus('Zusatzdateien aktualisiert');
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
    if (el) {
        el.textContent = text;
    } else {
        console.log('[Auftragstamm] Status:', text);
    }
}

function applyAccessRules(rec) {
    applyVeranstalterRules(rec.VA_KD_ID || rec.Veranstalter_ID);
    applyStatusRules(rec.VA_Status || rec.Veranst_Status_ID);
    applyObjektRules(rec.VA_Objekt_ID || rec.Objekt_ID);
}

function applyVeranstalterRules(value) {
    const veranstalterId = Number(value || 0);
    const isMesse = veranstalterId === 20760;

    setVisible('cmd_Messezettel_NameEintragen', isMesse);
    setVisible('cmd_BWN_send', isMesse);

    sendToSubform('sub_MA_VA_Zuordnung', {
        type: 'set_column_hidden',
        column: 'col-pkw',
        hidden: isMesse
    });
    sendToSubform('sub_MA_VA_Zuordnung', {
        type: 'set_column_hidden',
        column: 'col-el',
        hidden: isMesse
    });
}

function applyStatusRules(statusValue) {
    const status = Number(statusValue || 0);
    const lockInputs = status > 3;
    const showCalc = status >= 3;

    setVisible('btnAuftrBerech', showCalc);
    setVisible('pgRechnung', showCalc);
    setVisible('lbl_rechnungsnr', lockInputs);
    setVisible('Rech_NR', lockInputs);
    setVisible('lbl_KeineEingabe', lockInputs);

    setSubformLocked('sub_MA_VA_Zuordnung', lockInputs);
    setSubformLocked('sub_VA_Start', lockInputs);
    setSubformLocked('sub_MA_VA_Planung_Absage', lockInputs);
    sendToSubform('sub_MA_VA_Zuordnung', { type: 'set_locked', locked: lockInputs });
}

function applyObjektRules(value) {
    const hasObjekt = !!(value && Number(value) > 0);
    setVisible('btn_Posliste_oeffnen', hasObjekt);
    setVisible('btnmailpos', hasObjekt);
}

function setVisible(id, visible) {
    const el = document.getElementById(id);
    if (!el) return;
    el.classList.toggle('is-hidden', !visible);
}

function setSubformLocked(id, locked) {
    const el = document.getElementById(id);
    if (!el) return;
    el.classList.toggle('is-locked', !!locked);
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

function getTabellenNr() {
    const el = document.getElementById('TabellenNr');
    if (!el) return null;
    return el.value || el.textContent || null;
}

function buildLinkParams() {
    const tabellenNr = getTabellenNr();
    if (tabellenNr !== null && tabellenNr !== undefined) {
        state.currentTabellenNr = tabellenNr;
    }
    return {
        type: 'set_link_params',
        ID: state.currentVA_ID,
        VA_ID: state.currentVA_ID,
        VADatum: state.currentVADatum,
        VADatum_ID: state.currentVADatum_ID || state.currentVADatum,
        VAStart_ID: state.currentVAStart_ID,
        Objekt_ID: state.currentObjekt_ID,
        TabellenNr: state.currentTabellenNr
    };
}

function cmdMessezettelNameEintragen() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }
    alert('TODO: Messezettel Namen eintragen');
}

function cmdBWNSend() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }
    alert('TODO: BWN senden');
}

// ============ EXPORT ============
window.Auftragstamm = {
    requery: requeryAll,
    loadAuftrag: loadAuftrag,
    getState() { return state; }
};

document.addEventListener('DOMContentLoaded', async () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('embedded') === '1') {
        document.body.classList.add('embedded');
    }
    if (window.ApiAutostart) {
        await window.ApiAutostart.init();
    }
    init();
});
