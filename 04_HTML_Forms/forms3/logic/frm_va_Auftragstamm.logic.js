/**
 * frm_va_Auftragstamm.logic.js
 * Hauptformular - Auftragsverwaltung
 * Kommuniziert mit eingebetteten Subforms via PostMessage
 */
import { Bridge } from '../api/bridgeClient.js';

// ╔═══════════════════════════════════════════════════════════════════════════════╗
// ║  GESCHÜTZTE LADE-LOGIK - NICHT ÄNDERN!                                        ║
// ║  Die Lade-Funktionen sind in auftragstamm-loader.js ausgelagert.             ║
// ║  Diese funktionieren korrekt und sollten NICHT modifiziert werden.           ║
// ╚═══════════════════════════════════════════════════════════════════════════════╝
import { 
    loadInitialDataProtected,
    loadAuftraegeWithFilterProtected,
    loadFirstVisibleAuftragProtected,
    highlightAuftragInListProtected,
    LOADER_VERSION 
} from './auftragstamm-loader.js';

// ============ DEBUG: Shell-Parameter prüfen ============
console.log('[Auftragstamm] DEBUG - Modul geladen, window.SHELL_PARAMS:', window.SHELL_PARAMS);
console.log('[Auftragstamm] DEBUG - window.location.search:', window.location.search);

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
    'zsub_lstAuftrag',
    'sub_tbl_Rch_Kopf',           // Rechnungskopf-Subformular
    'sub_tbl_Rch_Pos_Auftrag'     // Rechnungspositionen-Subformular
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
    // ENTFERNT: bindButton('btnSchnellPlan', openMitarbeiterauswahl); - HTML hat bereits onclick Handler
    bindButton('btn_Posliste_oeffnen', openPositionen);
    bindButton('btnmailpos', openZusatzdateien);
    bindButton('Befehl640', kopierenAuftrag);  // Auftrag komplett kopieren
    bindButton('btnPlan_Kopie', kopiereInFolgetag);  // FIX: Daten in Folgetag kopieren (Access-Paritaet)
    bindButton('btnneuveranst', neuerAuftrag);
    bindButton('mcobtnDelete', loeschenAuftrag);
    bindButton('cmd_Messezettel_NameEintragen', cmdMessezettelNameEintragen);
    // ENTFERNT: bindButton ueberschrieb korrekten HTML onclick Handler (VBA Bridge)
    // HTML hat bereits onclick="bwnSenden()" der VBA Bridge korrekt aufruft
    // bindButton('cmd_BWN_send', cmdBWNSend);
    // ENTFERNT: bindButton ueberschrieb korrekten HTML onclick Handler (VBA Bridge)
    // HTML hat bereits onclick="bwnDrucken()" der VBA Bridge korrekt aufruft
    // bindButton('btn_BWN_Druck', druckeBWN);

    // Ribbon/DaBa Toggle Buttons
    bindButton('btnRibbonAus', toggleRibbonAus);
    bindButton('btnRibbonEin', toggleRibbonEin);
    bindButton('btnDaBaAus', toggleDaBaAus);
    bindButton('btnDaBaEin', toggleDaBaEin);

    // HTML-Ansicht Button
    bindButton('btn_N_HTMLAnsicht', openHTMLAnsicht);

    // Zusätzliche Buttons
    bindButton('Befehl709', markELGesendet);
    bindButton('btn_Rueckmeld', openRueckmeldeStatistik);
    bindButton('btnSyncErr', checkSyncErrors);

    // Attachments
    bindButton('btnNeuAttach', addNewAttachment);

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

    const veranstalter = document.getElementById('Veranstalter_ID');
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
        // DblClick öffnet Einsatztage-Übersicht (Access: cboVADatum_DblClick)
        vaDatum.addEventListener('dblclick', () => {
            if (!state.currentVA_ID) {
                alert('Bitte zuerst einen Auftrag auswählen');
                return;
            }
            console.log('[cboVADatum_DblClick] Öffne Einsatztage für VA_ID:', state.currentVA_ID);
            // Öffne VA_AnzTage Editor/Übersicht
            if (window.parent?.ConsysShell?.showForm) {
                localStorage.setItem('consec_va_id', String(state.currentVA_ID));
                window.parent.ConsysShell.showForm('einsatztage');
            } else {
                window.open(`sub_VA_Einsatztage.html?va_id=${state.currentVA_ID}`, 'Einsatztage', 'width=600,height=400');
            }
        });
    }

    // Auftraege_ab DblClick - öffnet Kalender/Datumsauswahl (Access: Auftraege_ab_DblClick)
    const auftraegeAb = document.getElementById('Auftraege_ab');
    if (auftraegeAb) {
        auftraegeAb.addEventListener('dblclick', () => {
            console.log('[Auftraege_ab_DblClick] Öffne Datumsauswahl');
            // HTML5 date input - DblClick öffnet nativen Kalender
            if (auftraegeAb.type === 'date') {
                auftraegeAb.showPicker?.();
            } else {
                // Fallback: Text-Input in Date-Input umwandeln temporär
                const currentVal = auftraegeAb.value;
                auftraegeAb.type = 'date';
                if (currentVal) {
                    // Deutsches Datum (DD.MM.YYYY) zu ISO konvertieren
                    const parts = currentVal.split('.');
                    if (parts.length === 3) {
                        auftraegeAb.value = `${parts[2]}-${parts[1].padStart(2,'0')}-${parts[0].padStart(2,'0')}`;
                    }
                }
                auftraegeAb.showPicker?.();
                // Nach Auswahl zurück zu Text
                auftraegeAb.addEventListener('change', function handler() {
                    const isoVal = auftraegeAb.value;
                    if (isoVal) {
                        const [y, m, d] = isoVal.split('-');
                        auftraegeAb.type = 'text';
                        auftraegeAb.value = `${d}.${m}.${y}`;
                    }
                    auftraegeAb.removeEventListener('change', handler);
                }, { once: true });
            }
        });
    }

    // cboAnstArt DblClick - öffnet Anstellungsarten-Verwaltung (Access: cboAnstArt_DblClick)
    const cboAnstArt = document.getElementById('cboAnstArt');
    if (cboAnstArt) {
        cboAnstArt.addEventListener('dblclick', () => {
            console.log('[cboAnstArt_DblClick] Öffne Anstellungsarten-Verwaltung');
            // Öffne Anstellungsarten-Formular
            if (window.parent?.ConsysShell?.showForm) {
                window.parent.ConsysShell.showForm('anstellungsarten');
            } else {
                alert('Anstellungsarten-Verwaltung: Bitte in Access öffnen');
            }
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
    const tbody = document.querySelector('#auftraegeTable tbody');
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

        case 'row_dblclick':
            // Doppelklick auf MA-Zeile öffnet Mitarbeiterstamm (18.01.2026)
            if (data.ma_id) {
                console.log('[Auftragstamm] Öffne Mitarbeiterstamm für MA_ID:', data.ma_id);
                // Shell-Navigation wenn verfügbar
                if (window.parent?.ConsysShell?.showForm) {
                    localStorage.setItem('consec_ma_id', String(data.ma_id));
                    window.parent.ConsysShell.showForm('frm_MA_Mitarbeiterstamm', { ma_id: data.ma_id });
                } else if (window.ConsysShell?.showForm) {
                    localStorage.setItem('consec_ma_id', String(data.ma_id));
                    window.ConsysShell.showForm('frm_MA_Mitarbeiterstamm', { ma_id: data.ma_id });
                } else {
                    // Fallback: In neuem Fenster öffnen
                    window.open(`frm_MA_Mitarbeiterstamm.html?ma_id=${data.ma_id}`, 'Mitarbeiterstamm', 'width=1200,height=800');
                }
            }
            break;

        // ============ SUBFORM postMessage HANDLER (19.01.2026) ============

        case 'SCHICHT_SELECTED':
            // Von sub_VA_Schichten - Schicht gewählt (Großbuchstaben-Variante)
            console.log('[Auftragstamm] SCHICHT_SELECTED:', data);
            state.currentVAStart_ID = data.schicht_id;
            state.currentVADatum_ID = data.vadatum_id;
            updateMASubforms();
            break;

        case 'DAY_SELECTED':
            // Von sub_VA_Einsatztage - Tag ausgewählt
            console.log('[Auftragstamm] DAY_SELECTED:', data);
            state.currentVADatum_ID = data.datum_id;
            state.currentVADatum = data.date;
            // Schichten für diesen Tag laden
            if (state.currentVA_ID) {
                loadSchichtenForDay(state.currentVA_ID, data.datum_id);
            }
            break;

        case 'DAY_DBLCLICK':
            // Von sub_VA_Einsatztage - Doppelklick auf Tag
            console.log('[Auftragstamm] DAY_DBLCLICK:', data);
            // Tag-Details öffnen oder bearbeiten
            if (typeof openDayDetails === 'function') {
                openDayDetails(data.va_id, data.datum_id, data.date);
            }
            break;

        case 'FILTER_CHANGED':
            // Von sub_VA_Einsatztage - Filter geändert
            console.log('[Auftragstamm] FILTER_CHANGED:', data.filter, 'Count:', data.count);
            break;

        case 'SCHICHT_CHANGED':
            // Von sub_VA_Schichten - Schicht wurde geändert
            console.log('[Auftragstamm] SCHICHT_CHANGED:', data);
            // Subforms aktualisieren
            if (state.currentVA_ID) {
                loadSchichtenForDay(state.currentVA_ID, data.vadatum_id);
            }
            break;

        case 'ZUORDNUNG_RECALC_REQUEST':
            // Von sub_VA_Schichten - Zuordnungen neu laden
            console.log('[Auftragstamm] ZUORDNUNG_RECALC_REQUEST:', data);
            updateMASubforms();
            break;

        case 'ADD_DAY':
            // Von sub_VA_Einsatztage - Neuen Tag hinzufügen
            console.log('[Auftragstamm] ADD_DAY für VA:', data.va_id);
            if (typeof addNewDay === 'function') {
                addNewDay(data.va_id);
            }
            break;

        case 'REMOVE_DAY':
        case 'REMOVE_DAYS':
            // Von sub_VA_Einsatztage - Tag(e) löschen
            console.log('[Auftragstamm] REMOVE_DAY(S):', data);
            if (typeof removeDays === 'function') {
                removeDays(data.va_id, data.dates || [data.date]);
            }
            break;

        case 'COPY_DAY':
            // Von sub_VA_Einsatztage - Tag kopieren
            console.log('[Auftragstamm] COPY_DAY:', data);
            if (typeof copyDay === 'function') {
                copyDay(data.va_id, data.date, data.datum_id);
            }
            break;

        case 'ADD_SCHICHT':
            // Von sub_VA_Schichten - Neue Schicht hinzufügen
            console.log('[Auftragstamm] ADD_SCHICHT für VA:', data.va_id);
            if (typeof addNewSchicht === 'function') {
                addNewSchicht(data.va_id, data.vadatum_id);
            }
            break;

        case 'EDIT_SCHICHT':
            // Von sub_VA_Schichten - Schicht bearbeiten
            console.log('[Auftragstamm] EDIT_SCHICHT:', data.schicht_id);
            if (typeof editSchicht === 'function') {
                editSchicht(data.schicht_id);
            }
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

    // PostMessage an iframe-Subforms (falls vorhanden)
    subformIds.forEach(id => {
        sendToSubform(id, params);
    });

    // Inline HTML-Tabellen aktualisieren (Schichten, Einsatzliste, Absagen)
    // Verwendet kurzes Timeout damit cboVADatum Zeit hat sich zu aktualisieren
    setTimeout(() => {
        if (typeof window.loadSubformData === 'function') {
            const vaId = state.currentVA_ID;
            const vadatumId = document.getElementById('cboVADatum')?.value || state.currentVADatum_ID;
            if (vaId) {
                console.log('[Auftragstamm] updateAllSubforms -> loadSubformData mit VA_ID:', vaId, 'VADatum_ID:', vadatumId);
                window.loadSubformData(vaId, vadatumId);
            }
        }
    }, 350);
}

function updateMASubforms() {
    // MA-Zuordnung und Absagen-Subforms mit neuer Schicht aktualisieren
    const params = buildLinkParams();

    sendToSubform('sub_MA_VA_Zuordnung', params);
    sendToSubform('sub_MA_VA_Planung_Absage', params);

    // WICHTIG: Auch die inline HTML-Tabellen aktualisieren (Schichten, Einsatzliste, Absagen)
    // Diese Funktion wird im setTimeout aufgerufen NACHDEM das korrekte Datum gesetzt wurde
    if (typeof window.loadSubformData === 'function') {
        const vaId = state.currentVA_ID;
        const vadatumId = document.getElementById('cboVADatum')?.value || state.currentVADatum_ID;
        console.log('[Auftragstamm] updateMASubforms -> loadSubformData mit VA_ID:', vaId, 'VADatum_ID:', vadatumId);
        window.loadSubformData(vaId, vadatumId);
    }
}

/**
 * Lädt Schichten für einen bestimmten Tag (postMessage Handler)
 */
function loadSchichtenForDay(vaId, vadatumId) {
    console.log('[Auftragstamm] loadSchichtenForDay:', vaId, vadatumId);
    state.currentVADatum_ID = vadatumId;

    // Update cboVADatum dropdown wenn vorhanden
    const cboVADatum = document.getElementById('cboVADatum');
    if (cboVADatum) {
        cboVADatum.value = vadatumId;
    }

    // Subform-Daten laden
    if (typeof window.loadSubformData === 'function') {
        window.loadSubformData(vaId, vadatumId);
    }

    // MA-Subforms aktualisieren
    updateMASubforms();
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
// ╔═══════════════════════════════════════════════════════════════════════════════╗
// ║  ACHTUNG: Die folgenden Lade-Funktionen sind GESCHÜTZT!                        ║
// ║  Sie rufen die Logik aus auftragstamm-loader.js auf.                         ║
// ║  BEI PROBLEMEN: NICHT die Logik hier ändern, sondern Claude fragen!          ║
// ║  Letzte funktionierende Version: 11.01.2026                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════════╝

/**
 * Haupt-Initialisierung - Ruft geschützte Lade-Logik auf
 * NICHT ÄNDERN! Bei Problemen: auftragstamm-loader.js prüfen
 */
async function loadInitialData() {
    console.log('[Auftragstamm] Loader-Version:', LOADER_VERSION.version, LOADER_VERSION.status);

    // CRITICAL FIX: Bei srcdoc iframes (Shell) die Parameter aus window.SHELL_PARAMS lesen
    // Shell injiziert Parameter als window.SHELL_PARAMS, da srcdoc keine URL-Parameter hat
    const shellParams = window.SHELL_PARAMS || {};
    if (shellParams.id || shellParams.va_id) {
        console.log('[Auftragstamm] Shell-Parameter erkannt:', shellParams);
        const requestedId = shellParams.id || shellParams.va_id;
        console.log('[Auftragstamm] Lade spezifischen Auftrag:', requestedId);

        // Combos laden
        await loadCombos();

        // Auftragsliste laden
        await loadAuftraegeWithFilter();

        // Spezifischen Auftrag laden
        await loadAuftrag(requestedId);

        // Markierung in der Liste synchronisieren
        highlightAuftragInList(requestedId);

        setStatus('Auftrag geladen');
        return;
    }

    // Abhängigkeiten für die geschützte Logik bereitstellen
    const dependencies = {
        Bridge,
        state,
        loadCombos,
        loadAuftrag,
        highlightAuftragInList,
        renderAuftragsliste,
        setStatus,
        updateAllSubforms
    };

    // Geschützte Logik aufrufen
    await loadInitialDataProtected(dependencies);
}

/**
 * Lädt Auftragsliste mit Filter - Wrapper für geschützte Logik
 * NICHT ÄNDERN!
 */
async function loadAuftraegeWithFilter() {
    const dependencies = { Bridge, state, renderAuftragsliste };
    await loadAuftraegeWithFilterProtected(dependencies);
}

/**
 * Lädt ersten sichtbaren Auftrag - Wrapper für geschützte Logik
 * NICHT ÄNDERN!
 */
async function loadFirstVisibleAuftrag() {
    const dependencies = {
        state,
        loadAuftrag,
        highlightAuftragInList,
        renderAuftragsliste,
        setStatus
    };
    await loadFirstVisibleAuftragProtected(dependencies);
}

/**
 * Markiert Auftrag in der Liste - Wrapper für geschützte Logik
 * FIX 17.01.2026: Erweitert um VADatum_ID für Mehrtages-Aufträge
 * Bei Mehrtages-Aufträgen wird nur der exakte Tag markiert (VA_ID + VADatum_ID)
 */
function highlightAuftragInList(auftragId) {
    const tbody = document.querySelector('#auftraegeTable tbody');
    if (!tbody) {
        // Fallback zur geschützten Funktion
        highlightAuftragInListProtected(auftragId);
        return;
    }

    const idStr = String(auftragId);
    const vadatumIdStr = state.currentVADatum_ID ? String(state.currentVADatum_ID) : null;

    // FIX 17.01.2026: Bei Mehrtages-Aufträgen NUR die exakte Zeile markieren
    tbody.querySelectorAll('tr').forEach(row => {
        const rowVaId = row.dataset.id;
        const rowVadatumId = row.dataset.vadatumId || row.dataset.displayDate;

        let isMatch = false;

        if (vadatumIdStr && rowVadatumId) {
            // Mehrtages-Auftrag: Beide IDs müssen übereinstimmen
            isMatch = (rowVaId === idStr) && (rowVadatumId === vadatumIdStr);
        } else {
            // Eintages-Auftrag: Nur VA_ID prüfen
            isMatch = (rowVaId === idStr);
        }

        if (isMatch) {
            row.classList.add('selected');
            // Scroll zur markierten Zeile
            row.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        } else {
            row.classList.remove('selected');
        }
    });
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
        fillCombo('Veranstalter_ID', kunden.data, 'kun_Id', 'kun_Firma');

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

    // Datalist-Input (input mit list-Attribut)?
    if (combo.tagName === 'INPUT' && combo.list) {
        const datalist = combo.list;
        datalist.innerHTML = '';
        data.forEach(item => {
            const opt = document.createElement('option');
            opt.value = item[textField] || '';
            datalist.appendChild(opt);
        });
        return;
    }

    // Normales Select-Element
    if (!combo.options) return;

    // Bestehende Optionen behalten (erste Option = Placeholder)
    const firstOption = combo.options.length > 0 ? combo.options[0] : null;
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
        console.log('[Auftragstamm] loadAuftrag:', id);
        
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

            // Markierung in der Auftragsliste synchronisieren
            highlightAuftragInList(state.currentVA_ID);

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
        // FIX 16.01.2026: Numerische ID aus tbl_VA_AnzTage verwenden (nicht Datum-String!)
        opt.value = item.ID || item.VADatum_ID || item.VADatum;
        opt.textContent = formatDate(item.VADatum);
        combo.appendChild(opt);
    });

    // Erstes Datum auswählen
    combo.selectedIndex = 1;
    state.currentVADatum = einsatztage[0].VADatum;
    // FIX 16.01.2026: Numerische ID speichern
    state.currentVADatum_ID = einsatztage[0].ID || einsatztage[0].VADatum_ID;
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
                // FIX 16.01.2026: Numerische ID aus tbl_VA_AnzTage verwenden
                opt.value = item.ID || item.VADatum_ID || item.VADatum;
                opt.textContent = formatDate(item.VADatum);
                combo.appendChild(opt);
            });

            // Erstes Datum auswaehlen
            combo.selectedIndex = 1;
            state.currentVADatum = result.data[0].VADatum;
            // FIX 16.01.2026: Numerische ID speichern
            state.currentVADatum_ID = result.data[0].ID || result.data[0].VADatum_ID;
        }
    } catch (error) {
        console.warn('[Auftragstamm] VADatum-Liste fehlgeschlagen:', error);
    }
}

function displayRecord(rec) {
    if (!rec) return;

    console.log('[Auftragstamm] displayRecord - Rohdaten:', rec);

    // API-Felder haben VA_* Präfix
    setFieldValue('ID', rec.VA_ID || rec.ID);
    
    // Datum-Felder: HTML date-input braucht ISO-Format (YYYY-MM-DD)
    setDateFieldValue('Dat_VA_Von', rec.VA_DatumVon || rec.Dat_VA_Von);
    setDateFieldValue('Dat_VA_Bis', rec.VA_DatumBis || rec.Dat_VA_Bis);
    
    // Auftrag-Feld (HTML-ID ist 'Auftrag', nicht 'Kombinationsfeld656')
    setFieldValue('Auftrag', rec.VA_Bezeichnung || rec.Auftrag);
    
    // Ort und Objekt
    setFieldValue('Ort', rec.VA_Ort || rec.Ort);
    setFieldValue('Objekt', rec.VA_Objekt || rec.Objekt);
    setFieldValue('Objekt_ID', rec.VA_Objekt_ID || rec.Objekt_ID);
    
    // VA_ID_Display (Auftragsnummer-Anzeige)
    setFieldValue('VA_ID_Display', rec.VA_ID || rec.ID);
    
    // Treffpunkt: Zeit im Format HH:MM fuer time-input
    setTimeFieldValue('Treffp_Zeit', rec.VA_Treffp_Zeit || rec.Treffp_Zeit);
    setFieldValue('Treffpunkt', rec.VA_Treffpunkt || rec.Treffpunkt);
    
    // Weitere Felder
    setFieldValue('PKW_Anzahl', rec.VA_PKW_Anzahl || rec.PKW_Anzahl);
    setFieldValue('Fahrtkosten', rec.VA_Fahrtkosten || rec.Fahrtkosten);
    setFieldValue('Dienstkleidung', rec.VA_Dienstkleidung || rec.Dienstkleidung);
    setFieldValue('Ansprechpartner', rec.VA_Ansprechpartner || rec.Ansprechpartner);
    setFieldValue('Veranstalter_ID', rec.VA_KD_ID || rec.Veranstalter_ID);
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

/**
 * Setzt Datum-Feld (type="date") - konvertiert verschiedene Formate zu ISO (YYYY-MM-DD)
 */
function setDateFieldValue(id, value) {
    const el = document.getElementById(id);
    if (!el) return;
    
    if (!value) {
        el.value = '';
        return;
    }
    
    let isoDate = '';
    
    // Bereits ISO-Format?
    if (/^\d{4}-\d{2}-\d{2}/.test(value)) {
        isoDate = value.substring(0, 10);
    }
    // Deutsches Format (DD.MM.YYYY)?
    else if (/^\d{1,2}\.\d{1,2}\.\d{4}$/.test(value)) {
        const parts = value.split('.');
        isoDate = `${parts[2]}-${parts[1].padStart(2, '0')}-${parts[0].padStart(2, '0')}`;
    }
    // Date-Objekt oder Timestamp?
    else {
        const d = new Date(value);
        if (!isNaN(d.getTime())) {
            isoDate = d.toISOString().substring(0, 10);
        }
    }
    
    el.value = isoDate;
    console.log(`[setDateFieldValue] ${id}: "${value}" -> "${isoDate}"`);
}

/**
 * Setzt Zeit-Feld (type="time") - konvertiert verschiedene Formate zu HH:MM
 */
function setTimeFieldValue(id, value) {
    const el = document.getElementById(id);
    if (!el) return;
    
    if (!value) {
        el.value = '';
        return;
    }
    
    let timeStr = String(value).trim();
    
    // Bereits HH:MM Format?
    if (/^\d{1,2}:\d{2}$/.test(timeStr)) {
        const [h, m] = timeStr.split(':');
        el.value = `${h.padStart(2, '0')}:${m}`;
        return;
    }
    
    // HH:MM:SS Format?
    if (/^\d{1,2}:\d{2}:\d{2}$/.test(timeStr)) {
        el.value = timeStr.substring(0, 5);
        return;
    }
    
    // Nur Ziffern (HHMM oder HMM)?
    if (/^\d{3,4}$/.test(timeStr)) {
        const h = timeStr.length === 3 ? timeStr[0] : timeStr.substring(0, 2);
        const m = timeStr.length === 3 ? timeStr.substring(1) : timeStr.substring(2);
        el.value = `${h.padStart(2, '0')}:${m}`;
        return;
    }
    
    // Fallback
    el.value = timeStr;
    console.log(`[setTimeFieldValue] ${id}: "${value}" -> "${el.value}"`);
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

async function setAuftraegeFilterToday() {
    const datumInput = document.getElementById('Auftraege_ab');
    if (datumInput) {
        datumInput.value = formatDate(new Date());
    }
    // Liste neu laden und ersten Eintrag auswaehlen
    await loadAuftraegeWithFilter();
    await loadFirstVisibleAuftrag();
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

    const params = new URLSearchParams();
    params.set('va_id', state.currentVA_ID);
    params.set('id', state.currentVA_ID);
    if (state.currentVADatum_ID) params.set('vadatum_id', state.currentVADatum_ID);
    if (state.currentVAStart_ID) params.set('vaStart_id', state.currentVAStart_ID);
    if (state.currentVADatum) params.set('va_datum', state.currentVADatum);

    const context = Object.fromEntries(params.entries());

    // Fix: about:srcdoc ist keine gueltige Base-URL, verwende Parent-Origin oder localhost
    let baseUrl = window.location.href;
    if (baseUrl.startsWith('about:') || !baseUrl.startsWith('http')) {
        baseUrl = window.parent?.location?.href || 'http://localhost:8080/';
    }
    const url = new URL('frm_MA_VA_Schnellauswahl.html', baseUrl);
    url.search = params.toString();

    if (window.parent?.ConsysShell?.showForm) {
        localStorage.setItem('consec_va_id', String(state.currentVA_ID));
        window.parent.ConsysShell.showForm('schnellauswahl', context);
        return;
    }

    window.open(url.href, '_blank');
}

function openHTMLAnsicht() {
    if (!state.currentVA_ID) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Auftrag auswählen');
        else alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    // Öffne Auftrag in separatem HTML-Fenster mit Druckansicht
    const url = `frm_va_Auftragstamm_Druckansicht.html?va_id=${state.currentVA_ID}`;
    window.open(url, 'HTML_Ansicht', 'width=900,height=700,menubar=no,toolbar=no,scrollbars=yes');
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

async function addNewAttachment() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    // Datei-Dialog via Bridge (wenn verfügbar)
    try {
        const result = await Bridge.execute('openFileDialog', {
            title: 'Datei hinzufuegen',
            filter: 'Alle Dateien (*.*)|*.*|PDF (*.pdf)|*.pdf|Bilder (*.jpg;*.png)|*.jpg;*.png'
        });

        if (result.success && result.data?.filepath) {
            // Datei hochladen
            const uploadResult = await Bridge.execute('uploadAttachment', {
                va_id: state.currentVA_ID,
                tabellen_nr: state.currentTabellenNr || 42,
                filepath: result.data.filepath
            });

            if (uploadResult.success) {
                setStatus('Datei hinzugefuegt');
                sendToSubform('sub_ZusatzDateien', { type: 'requery' });
            } else {
                throw new Error(uploadResult.error || 'Upload fehlgeschlagen');
            }
        }
    } catch (error) {
        console.error('[Auftragstamm] Attachment hinzufuegen fehlgeschlagen:', error);
        setStatus('Fehler beim Hinzufuegen');
        // Fallback: File-Input im DOM
        openFileInputFallback();
    }
}

function openFileInputFallback() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '*/*';
    input.style.display = 'none';

    input.onchange = async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;

        try {
            setStatus(`Lade ${file.name} hoch...`);

            // File als Base64 konvertieren und via Bridge senden
            const reader = new FileReader();
            reader.onload = async function(event) {
                try {
                    const result = await Bridge.execute('uploadAttachment', {
                        filename: file.name,
                        contentType: file.type,
                        data: event.target.result, // Base64
                        va_id: state.currentVA_ID,
                        tabellen_nr: state.currentTabellenNr || 42
                    });

                    if (result.success) {
                        setStatus('Datei hinzugefuegt');
                        sendToSubform('sub_ZusatzDateien', { type: 'requery' });
                    } else {
                        throw new Error(result.error || 'Upload fehlgeschlagen');
                    }
                } catch (err) {
                    setStatus('Fehler beim Hochladen: ' + err.message);
                    console.error('[Auftragstamm] Upload-Fehler:', err);
                }

                input.remove();
            };

            reader.onerror = function() {
                setStatus('Fehler beim Lesen der Datei');
                input.remove();
            };

            reader.readAsDataURL(file);
        } catch (err) {
            setStatus('Fehler beim Hochladen');
            console.error('[Auftragstamm] Upload-Fehler:', err);
            input.remove();
        }
    };

    document.body.appendChild(input);
    input.click();
}

async function kopierenAuftrag(inkl_ma_zuordnungen = false) {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    // Startdatum abfragen wie in Access (InputBox)
    // Standard: Heute + 7 Tage
    const heute = new Date();
    const defaultDatum = new Date(heute.getTime() + 7 * 24 * 60 * 60 * 1000);
    const defaultStr = defaultDatum.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });

    const neuesStartdatum = prompt(
        'Neues Startdatum für die Kopie eingeben:\n\nFormat: TT.MM.JJJJ',
        defaultStr
    );

    if (!neuesStartdatum) {
        // Benutzer hat abgebrochen
        return;
    }

    // Validierung des Datums
    const datumParts = neuesStartdatum.split('.');
    if (datumParts.length !== 3 || datumParts[0].length !== 2 || datumParts[1].length !== 2 || datumParts[2].length !== 4) {
        alert('Ungültiges Datumsformat!\n\nBitte Format TT.MM.JJJJ verwenden (z.B. 27.01.2026)');
        return;
    }

    try {
        setStatus('Kopiere Auftrag via VBA Bridge...');

        // VBA Bridge aufrufen - HTML_AuftragKopieren mit Startdatum
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'HTML_AuftragKopieren',
                args: [state.currentVA_ID, neuesStartdatum]
            })
        });

        const result = await response.json();
        console.log('[Auftragstamm] VBA HTML_AuftragKopieren Ergebnis:', result);

        // Ergebnis prüfen - Format: "OK:12345" mit neuer VA_ID
        if (result.result && result.result.startsWith('OK:')) {
            const newVaId = parseInt(result.result.split(':')[1], 10);
            setStatus('Auftrag kopiert - Neue ID: ' + newVaId);

            // Neuen Auftrag laden
            await loadAuftrag(newVaId);

            alert(`Auftrag erfolgreich kopiert!\n\nNeue Auftrag-ID: ${newVaId}\nStartdatum: ${neuesStartdatum}`);
        } else if (result.result && result.result.startsWith('Fehler:')) {
            throw new Error(result.result);
        } else {
            throw new Error(result.error || result.result || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler beim Kopieren');
        console.error('[Auftragstamm] Fehler beim Kopieren:', error);
        alert('Fehler beim Kopieren: ' + error.message);
    }
}

/**
 * FIX 2: btnPlan_Kopie - Daten in Folgetag kopieren (wie Access btnPlan_Kopie_Click)
 * Access: Kopiert tbl_VA_Start und tbl_MA_VA_Zuordnung vom aktuellen Tag zum naechsten Tag
 * NICHT: Kopiert den ganzen Auftrag (das macht kopierenAuftrag)
 */
async function kopiereInFolgetag() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    if (!state.currentVADatum && !state.currentVADatum_ID) {
        alert('Bitte zuerst ein Datum auswaehlen');
        return;
    }

    // Bestaetigung wie in Access
    const antwort = confirm('Daten in Folgetag kopieren?\n\nDie Schichten und MA-Zuordnungen vom aktuellen Tag werden in den naechsten Tag kopiert.');
    if (!antwort) return;

    try {
        setStatus('Kopiere Daten in Folgetag...');

        // API-Call zum Kopieren der Tagesdaten in den Folgetag
        const result = await Bridge.execute('copyToNextDay', {
            va_id: state.currentVA_ID,
            current_datum: state.currentVADatum,
            current_datum_id: state.currentVADatum_ID
        });

        if (result.success) {
            const info = [];
            if (result.data?.schichten_count) info.push(`${result.data.schichten_count} Schichten`);
            if (result.data?.zuordnungen_count) info.push(`${result.data.zuordnungen_count} MA-Zuordnungen`);

            setStatus('Daten in Folgetag kopiert: ' + info.join(', '));

            // Zum Folgetag navigieren (wie Access btnDatumRight_Click)
            if (result.data?.next_datum || result.data?.next_datum_id) {
                state.currentVADatum = result.data.next_datum || result.data.next_datum_id;
                state.currentVADatum_ID = result.data.next_datum_id || result.data.next_datum;

                // Datum-Dropdown aktualisieren
                const cboVADatum = document.getElementById('cboVADatum');
                if (cboVADatum) {
                    for (let i = 0; i < cboVADatum.options.length; i++) {
                        if (cboVADatum.options[i].value === state.currentVADatum ||
                            cboVADatum.options[i].value === state.currentVADatum_ID) {
                            cboVADatum.selectedIndex = i;
                            break;
                        }
                    }
                }
            }

            // Subforms aktualisieren
            updateAllSubforms();

            alert('Daten wurden in den Folgetag kopiert:\n' + info.join('\n'));

        } else {
            throw new Error(result.error || 'Kopieren fehlgeschlagen');
        }

    } catch (error) {
        console.error('[Auftragstamm] Folgetag kopieren Fehler:', error);
        setStatus('Fehler beim Kopieren in Folgetag');
        alert('Fehler: ' + error.message);
    }
}

// Auftrag kopieren mit MA-Zuordnungen (eigener Button-Handler)
async function kopierenAuftragMitMA() {
    await kopierenAuftrag(true);
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
    if (!confirm(`Auftrag "${auftrag}" wirklich löschen?\n\nACHTUNG: Der Auftrag wird PERMANENT gelöscht!`)) return;

    try {
        setStatus('Lösche Auftrag via VBA Bridge...');

        // VBA Bridge aufrufen - ECHTES DELETE wie in Access!
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'HTML_AuftragLoeschen',
                args: [state.currentVA_ID]
            })
        });

        const result = await response.json();
        console.log('[Auftragstamm] VBA HTML_AuftragLoeschen Ergebnis:', result);

        if (result.success || (result.result && result.result.startsWith('OK'))) {
            setStatus('Auftrag gelöscht');
            // Auftragsliste neu laden
            await loadAuftraege();
        } else {
            throw new Error(result.result || result.error || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler beim Löschen');
        console.error('[Auftragstamm] Fehler beim Löschen:', error);
        alert('Fehler beim Löschen: ' + error.message);
    }
}

async function sendeEinsatzliste(typ) {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    if (!state.currentVADatum_ID) {
        alert('Bitte zuerst ein Datum auswählen');
        return;
    }

    setStatus(`Sende Einsatzliste an ${typ}...`);

    try {
        // Bestimme VBA-Funktion und Parameter basierend auf Typ
        let vbaFunction = '';
        let args = [];

        switch (typ) {
            case 'MA':
                // btnMailEins_Click - Autosend Typ 2
                vbaFunction = 'HTML_btnMailEins_Click';
                args = [state.currentVA_ID, state.currentVADatum_ID];
                break;

            case 'BOS':
                // btn_Autosend_BOS_Click - Autosend Typ 4 (nur fuer bestimmte Veranstalter)
                vbaFunction = 'HTML_btn_Autosend_BOS_Click';
                const veranstalterId = parseInt(document.getElementById('Veranstalter_ID')?.value) || 0;
                args = [state.currentVA_ID, state.currentVADatum_ID, veranstalterId];
                break;

            case 'SUB':
                // btnMailSub_Click - Autosend Typ 5
                vbaFunction = 'HTML_btnMailSub_Click';
                args = [state.currentVA_ID, state.currentVADatum_ID];
                break;

            default:
                throw new Error('Unbekannter Typ: ' + typ);
        }

        console.log(`[Auftragstamm] Rufe ${vbaFunction} auf mit:`, args);

        // VBA Bridge Server Call (Port 5002)
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                function: vbaFunction,
                args: args
            })
        });

        const result = await response.json();

        if (result.success) {
            setStatus(`Einsatzliste an ${typ} gesendet`);
            showToast(result.result || `Einsatzliste wurde erfolgreich an ${typ} versendet`, 'success');
            console.log(`[Auftragstamm] ${vbaFunction} Ergebnis:`, result.result);
        } else {
            throw new Error(result.error || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler beim Senden');
        console.error('[Auftragstamm] Einsatzliste senden Fehler:', error);
        showToast('Fehler beim Senden: ' + error.message, 'error');
        alert('Fehler beim Senden: ' + error.message);
    }
}

/**
 * btnDruckZusage - Excel-Export wie in Access (exakter Ablauf!)
 * Ruft HTML_btnDruckZusage_Click auf - erzeugt Excel und setzt Status auf Beendet
 */
async function druckeEinsatzliste() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    try {
        setStatus('Erstelle Excel-Export...');

        // Hole Formular-Daten fuer den Dateinamen (wie im Original Access)
        const auftrag = document.getElementById('Auftrag')?.value || `VA${state.currentVA_ID}`;
        const objekt = document.getElementById('Objekt')?.value || '';
        const datVaVon = document.getElementById('Dat_VA_Von')?.value || '';

        console.log('[Auftragstamm] Excel-Export mit:', { VA_ID: state.currentVA_ID, Auftrag: auftrag, Objekt: objekt, Dat_VA_Von: datVaVon });

        // VBA Bridge Server Call (Port 5002) - HTML_btnDruckZusage_Click
        // Dieser ruft fXL_Export_Auftrag UND setzt Status auf Beendet
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                function: 'HTML_btnDruckZusage_Click',
                args: [
                    state.currentVA_ID,
                    auftrag,
                    objekt,
                    datVaVon
                ]
            })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Excel-Export erstellt');
            showToast(result.result || 'Excel-Datei wurde erstellt', 'success');
            console.log('[Auftragstamm] HTML_btnDruckZusage_Click Ergebnis:', result.result);

            // Status-Dropdown im HTML aktualisieren (VBA hat bereits DB aktualisiert)
            const statusDropdown = document.getElementById('Veranst_Status_ID');
            if (statusDropdown) {
                statusDropdown.value = '2';
                state.previousStatus = 2;
            }

        } else {
            throw new Error(result.error || 'Excel-Export fehlgeschlagen');
        }

    } catch (error) {
        console.error('[Auftragstamm] Excel-Export Fehler:', error);
        showToast('Excel-Export fehlgeschlagen: ' + error.message, 'error');

        // Fallback: Browser-Druck
        const useFallback = confirm('Excel-Export via VBA fehlgeschlagen.\n\nMoechten Sie stattdessen den Browser-Druck verwenden?');
        if (useFallback) {
            setStatus('Verwende Browser-Druck als Fallback...');
            window.print();
        } else {
            setStatus('Excel-Export abgebrochen');
        }
    }
}

async function druckeNamenlisteESS() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    try {
        setStatus('Erstelle ESS Namensliste/Stundenliste...');

        // Veranstalter_ID aus Formular holen
        const veranstalterId = parseInt(document.getElementById('Veranstalter_ID')?.value) ||
                               parseInt(state.currentRecord?.Veranstalter_ID) || 0;

        // VBA Bridge Server Call (Port 5002) - Original Access Funktion
        // Ruft HTML_btn_ListeStd_Click auf, welche Stundenliste_erstellen aufruft
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                function: 'HTML_btn_ListeStd_Click',
                args: [
                    state.currentVA_ID,
                    veranstalterId
                ]
            })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('ESS Namensliste erstellt');
            showToast('ESS Namensliste wurde erfolgreich erstellt', 'success');
            alert('ESS Namensliste wurde erstellt und in Access geöffnet.');
        } else {
            throw new Error(result.error || 'ESS Namensliste Fehler');
        }

    } catch (error) {
        console.error('[Auftragstamm] ESS Namensliste VBA Fehler:', error);
        showToast('VBA-Export fehlgeschlagen, verwende CSV-Fallback', 'warning');

        // Fallback: CSV-Export (bestehende Implementierung)
        try {
            setStatus('Lade ESS Namensliste (CSV Fallback)...');

            // Daten via REST-API laden
            const result = await Bridge.execute('getNamenlisteESS', { va_id: state.currentVA_ID });

            if (!result.success && !result.data) {
                throw new Error(result.error || 'Keine Daten erhalten');
            }

            const auftrag = result.data?.auftrag || state.currentRecord || {};
            const mitarbeiter = result.data?.mitarbeiter || [];

            // CSV fuer Excel erstellen
            let csv = '\uFEFF'; // BOM fuer UTF-8 in Excel
            csv += `ESS Namensliste: ${auftrag.Auftrag || auftrag.VA_Bezeichnung || ''}\n`;
            csv += `Objekt: ${auftrag.Objekt || auftrag.VA_Objekt || ''}\n`;
            csv += `Ort: ${auftrag.Ort || auftrag.VA_Ort || ''}\n`;
            csv += `Erstellt: ${new Date().toLocaleDateString('de-DE')}\n\n`;

            // Header
            csv += 'Nachname;Vorname;Kurzname;Geburtsdatum;Geburtsort;Nationalitaet;';
            csv += 'Ausweis-Nr;Ausweis gueltig bis;IHK 34a Nr;IHK gueltig bis;Telefon;E-Mail\n';

            // Daten
            mitarbeiter.forEach(m => {
                const gebdat = m.Geburtsdatum ? new Date(m.Geburtsdatum).toLocaleDateString('de-DE') : '';
                const ausweisBis = m.Ausweis_Gueltig_Bis ? new Date(m.Ausweis_Gueltig_Bis).toLocaleDateString('de-DE') : '';
                const ihkBis = m.IHK_34a_Gueltig_Bis ? new Date(m.IHK_34a_Gueltig_Bis).toLocaleDateString('de-DE') : '';

                csv += `${m.Nachname || ''};${m.Vorname || ''};${m.Kurzname || ''};`;
                csv += `${gebdat};${m.Geburtsort || ''};${m.Nationalitaet || ''};`;
                csv += `${m.Ausweis_Nr || ''};${ausweisBis};${m.IHK_34a_Nr || ''};${ihkBis};`;
                csv += `${m.Tel_Mobil || ''};${m.eMail || ''}\n`;
            });

            // Download
            downloadCSV(csv, `ESS_Namensliste_${state.currentVA_ID}.csv`);
            setStatus(`ESS Namensliste mit ${mitarbeiter.length} Eintraegen exportiert (CSV)`);
            showToast(`CSV-Datei mit ${mitarbeiter.length} Einträgen heruntergeladen`, 'success');

        } catch (fallbackError) {
            setStatus('Fehler beim Export der ESS Namensliste');
            console.error('[Auftragstamm] ESS Namensliste CSV Fallback Fehler:', fallbackError);
            showToast('Fehler beim Export: ' + fallbackError.message, 'error');
            alert('Fehler beim Export: ' + fallbackError.message);
        }
    }
}

// Hilfsfunktion: CSV-Download
function downloadCSV(csvContent, filename) {
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
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

// Hilfsfunktion: Generiert alle Tage zwischen Von und Bis
function generateDaysBetween(dateVon, dateBis) {
    const days = [];
    if (!dateVon) return days;
    const startDate = new Date(dateVon);
    const endDate = dateBis ? new Date(dateBis) : startDate;
    const maxDays = 365;
    let count = 0;
    const current = new Date(startDate);
    while (current <= endDate && count < maxDays) {
        days.push(new Date(current));
        current.setDate(current.getDate() + 1);
        count++;
    }
    return days;
}

function renderAuftragsliste() {
    const tbody = document.querySelector('#auftraegeTable tbody');
    if (!tbody) return;

    console.log('[Auftragsliste] MEHRTAGES-VERSION AKTIV - Rendering', state.records.length, 'Aufträge');

    // Mehrtages-Ansicht: Jeder Tag wird als separate Zeile angezeigt
    const allDays = [];

    state.records.forEach(rec => {
        const dateVon = rec.VA_DatumVon || rec.Dat_VA_Von;
        const dateBis = rec.VA_DatumBis || rec.Dat_VA_Bis || dateVon;
        console.log('[Auftragsliste]', rec.VA_Bezeichnung || rec.Auftrag, '- Von:', dateVon, 'Bis:', dateBis);

        // Generiere alle Tage zwischen Von und Bis
        const days = generateDaysBetween(dateVon, dateBis);

        days.forEach(day => {
            // FIX 19.01.2026: Lokales Datum verwenden statt UTC (toISOString verschiebt bei UTC+1)
            const localDateString = day.getFullYear() + '-' +
                String(day.getMonth() + 1).padStart(2, '0') + '-' +
                String(day.getDate()).padStart(2, '0');
            allDays.push({
                date: day,
                dateString: localDateString, // YYYY-MM-DD (lokal, nicht UTC!)
                auftrag: rec.VA_Bezeichnung || rec.Auftrag || '',
                ort: rec.VA_Ort || rec.Ort || '',
                objekt: rec.VA_Objekt || rec.Objekt || '',
                soll: rec.MA_Anzahl || 0,
                ist: rec.MA_Anzahl_Ist || 0,
                status: rec.Veranst_Status_ID || 0,
                vaId: rec.VA_ID || rec.ID
            });
        });
    });

    // Sortiere alle Tage nach Datum
    allDays.sort((a, b) => a.date - b.date);

    tbody.innerHTML = allDays.map((day, idx) => {
        const datum = formatDate(day.dateString);

        // Markierung wenn aktueller Auftrag UND aktuelles Datum (15.01.2026 Fix)
        const isSelected = (day.vaId === state.currentVA_ID) &&
                          (day.dateString === state.currentVADatum ||
                           day.dateString === state.currentVADatum_ID);
        const selectedClass = isSelected ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${day.vaId}" data-display-date="${day.dateString}" class="${selectedClass}">
                <td>${datum}</td>
                <td>${day.auftrag}</td>
                <td>${day.objekt || day.ort}</td>
                <td style="text-align: center;">${day.soll}</td>
                <td style="text-align: center;">${day.ist}</td>
                <td style="text-align: center;">${getStatusText(day.status)}</td>
            </tr>
        `;
    }).join('');

    setupAuftragslisteClickHandlerWithDate();
}

// Hilfsfunktion: Status-Text ermitteln
function getStatusText(statusId) {
    switch (parseInt(statusId)) {
        case 1: return 'Plan';
        case 2: return 'Beendet';
        case 3: return 'Abrechnung';
        default: return '';
    }
}

// ============ STATUS-GEFILTERTE AUFTRAGSLISTE (17.01.2026) ============
/**
 * Rendert die Auftragsliste gefiltert nach Status
 * Status-IDs: 1=In Planung, 2=Versendet, 3=Beendet
 */
function renderAuftragslisteFiltered(filterStatusId) {
    const tbody = document.querySelector('#auftraegeTable tbody');
    if (!tbody) {
        console.warn('[Auftragsliste] Tabelle #auftraegeTable tbody nicht gefunden');
        return;
    }

    console.log('[Auftragsliste] STATUS-GEFILTERT - Filtere nach Status:', filterStatusId);

    // Mehrtages-Ansicht: Jeder Tag wird als separate Zeile angezeigt
    const allDays = [];

    // Filtere state.records nach Status
    const filteredRecords = state.records.filter(rec => {
        const recStatus = parseInt(rec.Veranst_Status_ID) || 1;
        return recStatus === filterStatusId;
    });

    console.log('[Auftragsliste] Gefiltert:', filteredRecords.length, 'von', state.records.length, 'Aufträgen');

    filteredRecords.forEach(rec => {
        const dateVon = rec.VA_DatumVon || rec.Dat_VA_Von;
        const dateBis = rec.VA_DatumBis || rec.Dat_VA_Bis || dateVon;

        // Generiere alle Tage zwischen Von und Bis
        const days = generateDaysBetween(dateVon, dateBis);

        days.forEach(day => {
            // FIX 19.01.2026: Lokales Datum verwenden statt UTC (toISOString verschiebt bei UTC+1)
            const localDateString = day.getFullYear() + '-' +
                String(day.getMonth() + 1).padStart(2, '0') + '-' +
                String(day.getDate()).padStart(2, '0');
            allDays.push({
                date: day,
                dateString: localDateString, // YYYY-MM-DD (lokal, nicht UTC!)
                auftrag: rec.VA_Bezeichnung || rec.Auftrag || '',
                ort: rec.VA_Ort || rec.Ort || '',
                objekt: rec.VA_Objekt || rec.Objekt || '',
                soll: rec.MA_Anzahl || 0,
                ist: rec.MA_Anzahl_Ist || 0,
                status: rec.Veranst_Status_ID || 0,
                vaId: rec.VA_ID || rec.ID
            });
        });
    });

    // Sortiere alle Tage nach Datum
    allDays.sort((a, b) => a.date - b.date);

    tbody.innerHTML = allDays.map((day, idx) => {
        const datum = formatDate(day.dateString);

        // Markierung wenn aktueller Auftrag UND aktuelles Datum
        const isSelected = (day.vaId === state.currentVA_ID) &&
                          (day.dateString === state.currentVADatum ||
                           day.dateString === state.currentVADatum_ID);
        const selectedClass = isSelected ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${day.vaId}" data-display-date="${day.dateString}" class="${selectedClass}">
                <td>${datum}</td>
                <td>${day.auftrag}</td>
                <td>${day.objekt || day.ort}</td>
                <td style="text-align: center;">${day.soll}</td>
                <td style="text-align: center;">${day.ist}</td>
                <td style="text-align: center;">${getStatusText(day.status)}</td>
            </tr>
        `;
    }).join('');

    setupAuftragslisteClickHandlerWithDate();

    // Lade ersten gefilterten Auftrag wenn vorhanden
    if (allDays.length > 0) {
        const firstRow = tbody.querySelector('tr');
        if (firstRow) {
            firstRow.classList.add('selected');
            const firstId = firstRow.dataset.id;
            if (firstId && typeof loadAuftrag === 'function') {
                loadAuftrag(parseInt(firstId));
            }
        }
    }

    console.log('[Auftragsliste] Status-gefiltert gerendert:', allDays.length, 'Tage');
}

// Erweiterter Click-Handler fuer tagesweise Auswahl
function setupAuftragslisteClickHandlerWithDate() {
    const tbody = document.querySelector('#auftraegeTable tbody');
    if (!tbody) return;

    tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
            row.classList.add('selected');

            const id = row.dataset.id;
            const displayDate = row.dataset.displayDate;

            if (id) {
                // State aktualisieren
                state.currentVA_ID = parseInt(id);
                if (displayDate) {
                    state.currentVADatum = displayDate;
                    state.currentVADatum_ID = displayDate;
                }

                // Auftrag laden
                loadAuftrag(id);

                // Nach Laden: VADatum Dropdown auf das gewaehlte Datum setzen
                setTimeout(() => {
                    const cboVADatum = document.getElementById('cboVADatum');
                    if (cboVADatum && displayDate) {
                        for (let i = 0; i < cboVADatum.options.length; i++) {
                            const optValue = cboVADatum.options[i].value;
                            // Datum-Vergleich (ISO oder formatiert)
                            if (optValue === displayDate || optValue.includes(displayDate)) {
                                cboVADatum.selectedIndex = i;
                                state.currentVADatum = optValue;
                                state.currentVADatum_ID = optValue;
                                break;
                            }
                        }
                    }
                    // Subforms mit neuem Datum aktualisieren
                    updateMASubforms();
                }, 300);
            }
        });
    });
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
    const isSpecialClient = veranstalterId === 20750;

    setVisible('cmd_Messezettel_NameEintragen', isMesse);
    setVisible('cmd_BWN_send', isMesse);

    // BWN-Buttons: NUR sichtbar wenn Veranstalter_ID = 20760
    setVisible('btn_BWN_Druck', isMesse);
    // cmd_BWN_send hat bereits eine ID und wird oben behandelt

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

    // gridZuordnungen: Spalten-Sichtbarkeit basierend auf Veranstalter_ID
    // Spalten EL und PKW: unsichtbar wenn Veranstalter_ID = 20750
    // Spalte RE: NUR sichtbar wenn Veranstalter_ID = 20760
    applyGridZuordnungenColumnRules(veranstalterId);
}

/**
 * Bedingte Spalten-Sichtbarkeit fuer gridZuordnungen basierend auf Veranstalter_ID
 * - EL und PKW: unsichtbar wenn Veranstalter_ID = 20750
 * - RE: NUR sichtbar wenn Veranstalter_ID = 20760
 */
function applyGridZuordnungenColumnRules(veranstalterId) {
    const grid = document.getElementById('gridZuordnungen');
    if (!grid) return;

    const isSpecialClient = veranstalterId === 20750;
    const isMesse = veranstalterId === 20760;

    // Spalten-Indizes (0-basiert):
    // 0=Lfd, 1=Mitarbeiter, 2=von, 3=bis, 4=Std, 5=Bemerkungen, 6=?, 7=PKW, 8=EL, 9=RE
    const colPKW = 7;
    const colEL = 8;
    const colRE = 9;

    // Header-Zellen
    const headerCells = grid.querySelectorAll('thead th');

    // EL und PKW: unsichtbar wenn Veranstalter_ID = 20750
    if (headerCells[colPKW]) {
        headerCells[colPKW].classList.toggle('col-hidden', isSpecialClient);
    }
    if (headerCells[colEL]) {
        headerCells[colEL].classList.toggle('col-hidden', isSpecialClient);
    }

    // RE: NUR sichtbar wenn Veranstalter_ID = 20760
    if (headerCells[colRE]) {
        headerCells[colRE].classList.toggle('col-hidden', !isMesse);
    }

    // Body-Zellen aktualisieren
    const bodyRows = grid.querySelectorAll('tbody tr');
    bodyRows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells[colPKW]) {
            cells[colPKW].classList.toggle('col-hidden', isSpecialClient);
        }
        if (cells[colEL]) {
            cells[colEL].classList.toggle('col-hidden', isSpecialClient);
        }
        if (cells[colRE]) {
            cells[colRE].classList.toggle('col-hidden', !isMesse);
        }
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
    // ACCESS-PARITÄT: Veranst_Status_ID_AfterUpdate -> sub_MA_VA_Zuordnung.Locked = True/False
    sendToSubform('sub_MA_VA_Zuordnung', { type: 'lock_subform', locked: lockInputs });
}

async function applyObjektRules(value) {
    const hasObjekt = !!(value && Number(value) > 0);
    setVisible('btn_Posliste_oeffnen', hasObjekt);
    setVisible('btnmailpos', hasObjekt);

    // #23: Wenn Objekt ausgewählt, Ansprechpartner + Treffpunkt laden
    if (hasObjekt) {
        try {
            const result = await Bridge.execute('getObjekt', { id: Number(value) });
            if (result && result.data) {
                const obj = result.data;
                // Ansprechpartner übernehmen (falls im Auftrag noch leer)
                const ansprField = document.getElementById('Ansprechpartner');
                if (ansprField && !ansprField.value && obj.Ansprechpartner) {
                    ansprField.value = obj.Ansprechpartner;
                    console.log('[applyObjektRules] Ansprechpartner übernommen:', obj.Ansprechpartner);
                }
                // Treffpunkt übernehmen (falls leer)
                const treffField = document.getElementById('Treffpunkt');
                if (treffField && !treffField.value && obj.Treffpunkt) {
                    treffField.value = obj.Treffpunkt;
                    console.log('[applyObjektRules] Treffpunkt übernommen:', obj.Treffpunkt);
                }
                // Dienstkleidung übernehmen (falls leer)
                const dklField = document.getElementById('Dienstkleidung');
                if (dklField && !dklField.value && obj.Dienstkleidung) {
                    dklField.value = obj.Dienstkleidung;
                    console.log('[applyObjektRules] Dienstkleidung übernommen:', obj.Dienstkleidung);
                }
            }
        } catch (e) {
            console.warn('[applyObjektRules] Objekt-Daten laden fehlgeschlagen:', e);
        }
    }
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

/**
 * Pflichtfeld-Validierung
 */
function validateRequired() {
    const requiredFields = document.querySelectorAll('[required]');
    let valid = true;
    let firstInvalid = null;

    requiredFields.forEach(field => {
        if (!field.value || field.value.trim() === '') {
            field.classList.add('invalid');
            valid = false;
            if (!firstInvalid) firstInvalid = field;
        } else {
            field.classList.remove('invalid');
        }
    });

    if (!valid) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte alle Pflichtfelder ausfuellen');
        else alert('Bitte alle Pflichtfelder ausfuellen');
        if (firstInvalid) firstInvalid.focus();
    }
    return valid;
}

async function requeryAll() {
    // VBA Bridge aufrufen für echtes Access Form.Requery
    try {
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'HTML_AuftragAktualisieren',
                args: [state.currentVA_ID || 0]
            })
        });
        const result = await response.json();
        console.log('[Auftragstamm] VBA HTML_AuftragAktualisieren Ergebnis:', result);
    } catch (error) {
        console.log('[Auftragstamm] VBA Requery nicht verfügbar, verwende JS-Fallback');
    }

    // Daten im HTML neu laden
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

async function cmdMessezettelNameEintragen() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    try {
        setStatus('Erstelle Messezettel...');

        // Bridge-Call an VBA: cmd_Messezettel_NameEintragen
        const result = await Bridge.execute('messezettelNameEintragen', {
            va_id: state.currentVA_ID,
            vadatum: state.currentVADatum
        });

        if (result.success) {
            setStatus('Messezettel erstellt');
            // Subforms aktualisieren
            requeryAll();
        } else {
            throw new Error(result.error || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler beim Erstellen des Messezettels');
        console.error('[Auftragstamm] Messezettel Fehler:', error);
        alert('Fehler: ' + error.message);
    }
}

/**
 * FIX 3: cmd_BWN_send - Bewachungsnachweis senden mit Option "nur markierte"
 * Access fragt: "Nur markierte Mitarbeiter versenden?" (Ja/Nein)
 */
async function cmdBWNSend() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    // Erste Bestaetigung
    if (!confirm('BWN (Bewachungsnachweis) wirklich senden?')) return;

    // Zweite Frage wie in Access: "Nur markierte Mitarbeiter versenden?"
    const nurMarkierte = confirm('Nur markierte Mitarbeiter versenden?\n\n[OK] = Nur markierte Mitarbeiter\n[Abbrechen] = Alle Mitarbeiter');

    try {
        setStatus(nurMarkierte ? 'Sende BWN an markierte Mitarbeiter...' : 'Sende BWN an alle Mitarbeiter...');

        // Bridge-Call an VBA: cmd_BWN_send mit Option fuer nur_markierte
        const result = await Bridge.execute('sendBWN', {
            va_id: state.currentVA_ID,
            vadatum: state.currentVADatum,
            vadatum_id: state.currentVADatum_ID,
            nur_markierte: nurMarkierte  // NEU: Option wie in Access
        });

        if (result.success) {
            const countInfo = result.data?.sent_count ? ` (${result.data.sent_count} E-Mails)` : '';
            setStatus('BWN erfolgreich gesendet' + countInfo);
            alert('BWN wurde erfolgreich gesendet.' + countInfo);

            // Optional: Markierungen zuruecksetzen (wie in Access)
            if (result.data?.reset_markierungen) {
                sendToSubform('sub_MA_VA_Zuordnung', { type: 'requery' });
            }
        } else {
            throw new Error(result.error || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler beim Senden des BWN');
        console.error('[Auftragstamm] BWN senden Fehler:', error);
        alert('Fehler beim Senden: ' + error.message);
    }
}

async function druckeBWN() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    try {
        setStatus('Erstelle BWN zum Drucken...');

        // Versuche Bridge-Call an VBA fuer nativen Druck
        const result = await Bridge.execute('druckeBWN', {
            va_id: state.currentVA_ID,
            vadatum: state.currentVADatum,
            vadatum_id: state.currentVADatum_ID
        });

        if (result.success) {
            setStatus('BWN wird gedruckt...');
            return;
        }
    } catch (error) {
        // Fallback: Browser-basierter Druck
        console.log('[Auftragstamm] Native BWN-Druck nicht verfuegbar, verwende Browser-Druck');
    }

    // Browser-Fallback: Druckfenster erstellen
    const auftrag = state.currentRecord || {};
    const printWindow = window.open('', '_blank', 'width=800,height=600');

    if (printWindow) {
        printWindow.document.write(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>BWN - ${auftrag.Auftrag || auftrag.VA_Bezeichnung || ''}</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; }
                    h1 { font-size: 18px; color: #000080; border-bottom: 2px solid #000080; padding-bottom: 5px; }
                    h2 { font-size: 14px; margin-top: 15px; }
                    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
                    th, td { border: 1px solid #808080; padding: 5px 8px; text-align: left; font-size: 11px; }
                    th { background: #e0e0e0; }
                    .info-row { display: flex; gap: 20px; margin: 5px 0; }
                    .info-label { font-weight: bold; min-width: 100px; }
                    @media print { body { margin: 10px; } }
                </style>
            </head>
            <body>
                <h1>Bewachungsnachweis (BWN)</h1>
                <div class="info-row">
                    <span class="info-label">Auftrag:</span>
                    <span>${auftrag.Auftrag || auftrag.VA_Bezeichnung || ''}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Objekt:</span>
                    <span>${auftrag.Objekt || auftrag.VA_Objekt || ''}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Ort:</span>
                    <span>${auftrag.Ort || auftrag.VA_Ort || ''}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Datum:</span>
                    <span>${formatDate(auftrag.Dat_VA_Von || auftrag.VA_DatumVon)} - ${formatDate(auftrag.Dat_VA_Bis || auftrag.VA_DatumBis)}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Treffpunkt:</span>
                    <span>${auftrag.Treffp_Zeit || auftrag.VA_Treffp_Zeit || ''} Uhr - ${auftrag.Treffpunkt || auftrag.VA_Treffpunkt || ''}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Dienstkleidung:</span>
                    <span>${auftrag.Dienstkleidung || auftrag.VA_Dienstkleidung || ''}</span>
                </div>
                <h2>Mitarbeiter</h2>
                <table>
                    <tr>
                        <th>Nr</th>
                        <th>Name</th>
                        <th>Von</th>
                        <th>Bis</th>
                        <th>Unterschrift</th>
                    </tr>
                    <tr><td>1</td><td></td><td></td><td></td><td style="min-width: 150px;"></td></tr>
                    <tr><td>2</td><td></td><td></td><td></td><td></td></tr>
                    <tr><td>3</td><td></td><td></td><td></td><td></td></tr>
                    <tr><td>4</td><td></td><td></td><td></td><td></td></tr>
                    <tr><td>5</td><td></td><td></td><td></td><td></td></tr>
                </table>
                <script>
                    window.onload = function() { window.print(); };
                <\/script>
            </body>
            </html>
        `);
        printWindow.document.close();
        setStatus('BWN wird gedruckt...');
    } else {
        alert('Pop-up Blocker verhindert das Druckfenster. Bitte Pop-ups erlauben.');
        setStatus('Druck fehlgeschlagen - Pop-up blockiert');
    }
}

function toggleRibbonAus() {
    // Ribbon ausblenden (Access-Style Menüband)
    const ribbon = document.querySelector('.access-header-bar');
    if (ribbon) {
        ribbon.style.display = 'none';
    }
    setVisible('btnRibbonAus', false);
    setVisible('btnRibbonEin', true);
}

function toggleRibbonEin() {
    // Ribbon einblenden
    const ribbon = document.querySelector('.access-header-bar');
    if (ribbon) {
        ribbon.style.display = '';
    }
    setVisible('btnRibbonAus', true);
    setVisible('btnRibbonEin', false);
}

function toggleDaBaAus() {
    // Datenbank-Navigationsbereich ausblenden
    const sidebar = document.querySelector('.left-menu');
    if (sidebar) {
        sidebar.style.display = 'none';
    }
    setVisible('btnDaBaAus', false);
    setVisible('btnDaBaEin', true);
}

function toggleDaBaEin() {
    // Datenbank-Navigationsbereich einblenden
    const sidebar = document.querySelector('.left-menu');
    if (sidebar) {
        sidebar.style.display = '';
    }
    setVisible('btnDaBaAus', true);
    setVisible('btnDaBaEin', false);
}

async function markELGesendet() {
    // Einsatzliste als gesendet markieren
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    try {
        setStatus('Markiere EL als gesendet...');
        await Bridge.execute('markELGesendet', { va_id: state.currentVA_ID });
        setStatus('Einsatzliste als gesendet markiert');
        requeryAll();
    } catch (error) {
        setStatus('Fehler beim Markieren');
        console.error('[Auftragstamm] EL markieren fehlgeschlagen:', error);
    }
}

function openRueckmeldeStatistik() {
    // Rückmelde-Statistik öffnen
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    const url = new URL(`frm_Rueckmeldestatistik.html?va_id=${state.currentVA_ID}`, window.location.href).href;
    window.open(url, '_blank', 'width=800,height=600');
}

async function checkSyncErrors() {
    // Synchronisierungsfehler prüfen
    setStatus('Prüfe Synchronisierungsfehler...');

    try {
        const result = await Bridge.execute('getSyncErrors', { va_id: state.currentVA_ID });

        if (result.data && result.data.length > 0) {
            const count = result.data.length;
            alert(`${count} Synchronisierungsfehler gefunden.\nDetails siehe Konsole.`);
            console.log('[Auftragstamm] Sync-Fehler:', result.data);
        } else {
            alert('Keine Synchronisierungsfehler gefunden.');
        }
        setStatus('Sync-Prüfung abgeschlossen');
    } catch (error) {
        setStatus('Fehler bei Sync-Prüfung');
        console.error('[Auftragstamm] Sync-Fehler prüfen fehlgeschlagen:', error);
    }
}

// ============ FUNCTION ALIASES (fuer onclick-Handler Kompatibilitaet) ============

// Case-Varianten
window.openHtmlAnsicht = typeof openHTMLAnsicht === 'function' ? openHTMLAnsicht : function() { alert('Funktion openHTMLAnsicht nicht verfuegbar'); };

// Verb-Position-Varianten (auftragKopieren vs kopierenAuftrag)
window.auftragKopieren = typeof kopierenAuftrag === 'function' ? kopierenAuftrag : function() { alert('Funktion kopierenAuftrag nicht verfuegbar'); };

// FIX 2: Folgetag-Kopie Aliase (btnPlan_Kopie - Access-Paritaet)
window.kopiereInFolgetag = typeof kopiereInFolgetag === 'function' ? kopiereInFolgetag : function() { alert('Funktion kopiereInFolgetag nicht verfuegbar'); };
window.copyToNextDay = typeof kopiereInFolgetag === 'function' ? kopiereInFolgetag : function() { alert('Funktion kopiereInFolgetag nicht verfuegbar'); };
window.planKopie = typeof kopiereInFolgetag === 'function' ? kopiereInFolgetag : function() { alert('Funktion kopiereInFolgetag nicht verfuegbar'); };
window.datenInFolgetag = typeof kopiereInFolgetag === 'function' ? kopiereInFolgetag : function() { alert('Funktion kopiereInFolgetag nicht verfuegbar'); };
window.auftragLoeschen = typeof loeschenAuftrag === 'function' ? loeschenAuftrag : function() { alert('Funktion loeschenAuftrag nicht verfuegbar'); };

// FIX: btnSchnellPlan - Mitarbeiterauswahl - NICHT ueberschreiben! Die HTML-Datei hat die korrekte Implementierung
// window.openMitarbeiterauswahl = typeof openMitarbeiterauswahl === 'function' ? openMitarbeiterauswahl : function() { alert('Funktion openMitarbeiterauswahl nicht verfuegbar'); };

// Einsatzliste-Varianten
window.sendeEinsatzlisteMA = function() { if (typeof sendeEinsatzliste === 'function') sendeEinsatzliste('MA'); else alert('Funktion sendeEinsatzliste nicht verfuegbar'); };
window.sendeEinsatzlisteBOS = function() { if (typeof sendeEinsatzliste === 'function') sendeEinsatzliste('BOS'); else alert('Funktion sendeEinsatzliste nicht verfuegbar'); };
window.sendeEinsatzlisteSUB = function() { if (typeof sendeEinsatzliste === 'function') sendeEinsatzliste('SUB'); else alert('Funktion sendeEinsatzliste nicht verfuegbar'); };

// Export Excel
window.exportEinsatzlisteExcel = function() {
    if (typeof Toast !== 'undefined') Toast.info('Excel-Export wird vorbereitet...');
    // Placeholder - kann spaeter implementiert werden
    console.log('[Auftragstamm] exportEinsatzlisteExcel aufgerufen');
};

// Namensliste und Drucken
window.namenslisteESS = typeof druckeNamenlisteESS === 'function' ? druckeNamenlisteESS : function() { alert('Funktion druckeNamenlisteESS nicht verfuegbar'); };
window.einsatzlisteDrucken = typeof druckeEinsatzliste === 'function' ? druckeEinsatzliste : function() { alert('Funktion druckeEinsatzliste nicht verfuegbar'); };

// Stunden berechnen
window.berechneStunden = function() {
    if (typeof Toast !== 'undefined') Toast.info('Stunden werden berechnet...');
    console.log('[Auftragstamm] berechneStunden aufgerufen');
};

// EL Gesendet
window.showELGesendet = typeof markELGesendet === 'function' ? markELGesendet : function() { alert('Funktion markELGesendet nicht verfuegbar'); };

// Datum Navigation
window.datumNavLeft = function() {
    // Navigiere zum vorherigen Einsatztag
    const tageSelect = document.getElementById('cboTag');
    if (tageSelect && tageSelect.selectedIndex > 0) {
        tageSelect.selectedIndex--;
        tageSelect.dispatchEvent(new Event('change'));
    }
};
window.datumNavRight = function() {
    // Navigiere zum naechsten Einsatztag
    const tageSelect = document.getElementById('cboTag');
    if (tageSelect && tageSelect.selectedIndex < tageSelect.options.length - 1) {
        tageSelect.selectedIndex++;
        tageSelect.dispatchEvent(new Event('change'));
    }
};

// BWN-Varianten - ENTFERNT: Diese ueberschrieben die korrekten HTML onclick Handler (VBA Bridge)
// HTML definiert bwnDrucken() und bwnSenden() bereits korrekt mit VBA Bridge (Port 5002)
// window.bwnDrucken = typeof druckeBWN === 'function' ? druckeBWN : function() { alert('Funktion druckeBWN nicht verfuegbar'); };
// window.bwnSenden = typeof cmdBWNSend === 'function' ? cmdBWNSend : function() { alert('Funktion cmdBWNSend nicht verfuegbar'); };
window.messezettelNameEintragen = typeof cmdMessezettelNameEintragen === 'function' ? cmdMessezettelNameEintragen : function() { alert('Funktion cmdMessezettelNameEintragen nicht verfuegbar'); };

// Attachment-Funktionen
window.neuenAttachHinzufuegen = typeof addNewAttachment === 'function' ? addNewAttachment : function() { alert('Funktion addNewAttachment nicht verfuegbar'); };
window.openAttachment = function(id) { console.log('[Auftragstamm] openAttachment:', id); window.open(`/api/attachments/${id}`, '_blank'); };
window.downloadAttachment = function(id) { console.log('[Auftragstamm] downloadAttachment:', id); window.location.href = `/api/attachments/${id}/download`; };
window.deleteAttachment = function(id) { if (confirm('Anhang wirklich loeschen?')) console.log('[Auftragstamm] deleteAttachment:', id); };

// Rechnungs-Funktionen (15.01.2026 - jetzt mit VBA-Bridge)
window.rechnungPDF = rechnungPDF;
window.berechnungslistePDF = berechnungslistePDF;
window.rechnungDatenLaden = rechnungDatenLaden;
window.rechnungLexware = rechnungLexware;

// Event-Funktionen (Placeholder)
window.loadEventInfoFromWeb = function() { console.log('[Auftragstamm] loadEventInfoFromWeb'); };
window.openEventWeblink = function() { console.log('[Auftragstamm] openEventWeblink'); };
window.loadEventWetter = function() { console.log('[Auftragstamm] loadEventWetter'); };
window.saveEventNotes = function() { console.log('[Auftragstamm] saveEventNotes'); };

// Filter-Funktionen - Status-Filter für Header-Block (16.01.2026)
window.filterByStatus = function(statusId) {
    console.log('[Auftragstamm] filterByStatus aufgerufen mit:', statusId);

    // Status-Filter in state speichern
    state.auftraegeFilter = state.auftraegeFilter || {};
    state.auftraegeFilter.status = statusId;

    // Visuelles Feedback: aktiven Filter markieren
    const statusBlock = document.getElementById('statusHeaderBlock');
    if (statusBlock) {
        statusBlock.querySelectorAll('div[onclick]').forEach(el => {
            el.style.fontWeight = 'normal';
            el.style.backgroundColor = '';
        });
        // Aktuellen Filter hervorheben
        const activeFilter = statusBlock.querySelector(`div[onclick="filterByStatus(${statusId})"]`);
        if (activeFilter) {
            activeFilter.style.fontWeight = 'bold';
            activeFilter.style.backgroundColor = '#9090b8';
        }
    }

    // Auftragsliste mit Status-Filter rendern
    renderAuftragslisteFiltered(statusId);

    console.log('[Auftragstamm] Status-Filter gesetzt auf:', statusId);
};

// Tage-Navigation
window.tageZurueck = function() { if (typeof shiftAuftraegeFilter === 'function') shiftAuftraegeFilter(-7); };
window.tageVor = function() { if (typeof shiftAuftraegeFilter === 'function') shiftAuftraegeFilter(7); };
window.abHeute = function() { if (typeof setAuftraegeFilterToday === 'function') setAuftraegeFilterToday(); };

// Sort-Funktionen
window.sortAuftraege = function(field) {
    console.log('[Auftragstamm] sortAuftraege:', field);
};

// Navigation-Aliase
window.gotoErster = function() { if (typeof gotoRecord === 'function') gotoRecord(0); };
window.gotoVorheriger = function() { if (typeof gotoRecord === 'function' && state.currentIndex > 0) gotoRecord(state.currentIndex - 1); };
window.gotoNaechster = function() { if (typeof gotoRecord === 'function') gotoRecord(state.currentIndex + 1); };
window.gotoLetzter = function() { if (typeof gotoRecord === 'function' && state.auftraege) gotoRecord(state.auftraege.length - 1); };

// Undo-Alias
window.rueckgaengig = typeof undoChanges === 'function' ? undoChanges : function() { alert('Rueckgaengig nicht verfuegbar'); };

// Kopieren-Dialog
window.executeAuftragKopieren = typeof kopierenAuftragMitMA === 'function' ? kopierenAuftragMitMA : function() { alert('Funktion kopierenAuftragMitMA nicht verfuegbar'); };

// Sync-Fehler
window.openSyncfehler = typeof checkSyncErrors === 'function' ? checkSyncErrors : function() { alert('Funktion checkSyncErrors nicht verfuegbar'); };

// Maximize
window.toggleMaximize = function() {
    if (document.fullscreenElement) {
        document.exitFullscreen();
    } else {
        document.documentElement.requestFullscreen();
    }
};

// ============ EINSATZLISTE-BEARBEITUNGS-FUNKTIONEN (15.01.2026 ergänzt) ============
// Diese Funktionen rufen die VBA-Bridge auf Port 5002 auf

window.sortiereZuordnungen = sortiereZuordnungen;
window.erstelleZuordnungen = erstelleZuordnungen;
window.stundenCheck = stundenCheck;
window.openRueckmeldeAuswertung = openRueckmeldeAuswertung;
window.openAbwesenheiten = openAbwesenheiten;

// ============ ZUSAETZLICHE ALIASE (fuer Auftragsverwaltung2.html und frm_N_VA_Auftragstamm.html) ============

// Umlaut-Varianten (fuer HTML onclick mit Umlauten)
window.auftragLöschen = typeof loeschenAuftrag === 'function' ? loeschenAuftrag : function() { alert('Funktion loeschenAuftrag nicht verfuegbar'); };
window.filterAufträge = typeof applyAuftraegeFilter === 'function' ? applyAuftraegeFilter : function() { console.log('[Auftragstamm] filterAuftraege'); };
window.tageZurück = function() { if (typeof shiftAuftraegeFilter === 'function') shiftAuftraegeFilter(-7); };
window.openRückmeldStatistik = typeof openRueckmeldeStatistik === 'function' ? openRueckmeldeStatistik : function() { console.log('[Auftragstamm] openRueckmeldeStatistik'); };
window.showRückmeldungen = typeof openRueckmeldeStatistik === 'function' ? openRueckmeldeStatistik : function() { console.log('[Auftragstamm] showRueckmeldungen'); };

// Englische Varianten (fuer frm_N_VA_Auftragstamm.html)
window.refresh = typeof requeryAll === 'function' ? requeryAll : function() { window.location.reload(); };
window.refreshData = typeof requeryAll === 'function' ? requeryAll : function() { window.location.reload(); };
window.copyAuftrag = typeof kopierenAuftrag === 'function' ? kopierenAuftrag : function() { alert('Funktion kopierenAuftrag nicht verfuegbar'); };
window.deleteAuftrag = typeof loeschenAuftrag === 'function' ? loeschenAuftrag : function() { alert('Funktion loeschenAuftrag nicht verfuegbar'); };
window.sendMA = function() { if (typeof sendeEinsatzliste === 'function') sendeEinsatzliste('MA'); else console.log('[Auftragstamm] sendMA'); };
window.sendBOS = function() { if (typeof sendeEinsatzliste === 'function') sendeEinsatzliste('BOS'); else console.log('[Auftragstamm] sendBOS'); };
window.sendSUB = function() { if (typeof sendeEinsatzliste === 'function') sendeEinsatzliste('SUB'); else console.log('[Auftragstamm] sendSUB'); };
window.printNamesliste = typeof druckeNamenlisteESS === 'function' ? druckeNamenlisteESS : function() {
    if (typeof printTable === 'function') printTable('einsatzliste-container');
    else window.print();
};
window.printEinsatzliste = typeof druckeEinsatzliste === 'function' ? druckeEinsatzliste : function() {
    if (typeof printTable === 'function') printTable('einsatzliste-container');
    else window.print();
};
window.datePrev = function() { if (typeof navigateVADatum === 'function') navigateVADatum(-1); else window.datumNavLeft(); };
window.dateNext = function() { if (typeof navigateVADatum === 'function') navigateVADatum(1); else window.datumNavRight(); };
window.filterStatus = typeof filterByStatus !== 'undefined' ? window.filterByStatus : function(status) { console.log('[Auftragstamm] filterStatus:', status); };
window.filterGo = typeof applyAuftraegeFilter === 'function' ? applyAuftraegeFilter : function() { console.log('[Auftragstamm] filterGo'); };
window.filterBack = function() { if (typeof shiftAuftraegeFilter === 'function') shiftAuftraegeFilter(-7); };
window.filterFwd = function() { if (typeof shiftAuftraegeFilter === 'function') shiftAuftraegeFilter(7); };
window.filterToday = typeof setAuftraegeFilterToday === 'function' ? setAuftraegeFilterToday : function() { console.log('[Auftragstamm] filterToday'); };
window.printBWN = typeof druckeBWN === 'function' ? druckeBWN : function() {
    if (typeof printTable === 'function') printTable('bwn-container');
    else window.print();
};
window.newAuftrag = typeof neuerAuftrag === 'function' ? neuerAuftrag : function() { console.log('[Auftragstamm] newAuftrag'); };
window.showSyncfehler = typeof checkSyncErrors === 'function' ? checkSyncErrors : function() { console.log('[Auftragstamm] showSyncfehler'); };

// closeModal fuer Dialoge
window.closeModal = function(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
        modal.classList.remove('active');
    }
};

// ============ FEHLENDE HANDLER (14.01.2026) ============
// Diese Funktionen werden von HTML onclick aufgerufen

// Vollbild-Toggle
window.toggleFullscreen = function() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.log('[Auftragstamm] Vollbild nicht moeglich:', err);
        });
    } else {
        document.exitFullscreen();
    }
};

// Filter-Funktionen (Auftragliste)
window.filterAuftraege = typeof applyAuftraegeFilter === 'function' ? applyAuftraegeFilter : function() {
    console.log('[Auftragstamm] filterAuftraege ausgefuehrt');
    if (typeof loadAuftraegeWithFilter === 'function') loadAuftraegeWithFilter();
};

// Rueckmelde-Statistik oeffnen
window.openRueckmeldStatistik = typeof openRueckmeldeStatistik === 'function' ? openRueckmeldeStatistik : function() {
    const vaId = state?.currentVA_ID || new URLSearchParams(window.location.search).get('id');
    if (vaId) {
        const url = `frm_Rueckmeldestatistik.html?va_id=${vaId}`;
        if (window.parent && window.parent !== window) {
            window.parent.postMessage({ type: 'NAVIGATE', formName: 'frm_Rueckmeldestatistik', id: vaId }, '*');
        } else {
            window.open(url, '_blank', 'width=800,height=600');
        }
    } else {
        alert('Bitte zuerst einen Auftrag auswaehlen');
    }
};

// Eventdaten aus Web laden
window.webDatenLaden = async function() {
    console.log('[Auftragstamm] webDatenLaden gestartet');
    const spinner = document.querySelector('.loading-spinner');
    if (spinner) spinner.classList.add('active');

    try {
        // TODO: Implementierung Web-Scraper fuer Eventdaten
        // Derzeit Platzhalter - zeigt Info-Meldung
        if (typeof Toast !== 'undefined') {
            Toast.info('Web-Daten werden geladen...');
        }
        await new Promise(resolve => setTimeout(resolve, 1000));
        if (typeof Toast !== 'undefined') {
            Toast.warning('Eventdaten-Scraper noch nicht implementiert');
        }
    } catch (err) {
        console.error('[Auftragstamm] Fehler beim Laden der Web-Daten:', err);
        if (typeof Toast !== 'undefined') Toast.error('Fehler: ' + err.message);
    } finally {
        if (spinner) spinner.classList.remove('active');
    }
};

// Eventdaten speichern
window.eventdatenSpeichern = async function() {
    console.log('[Auftragstamm] eventdatenSpeichern gestartet');
    const vaId = state?.currentVA_ID;
    if (!vaId) {
        alert('Kein Auftrag ausgewaehlt');
        return;
    }

    try {
        // Sammle Eventdaten aus dem Formular
        const eventdaten = {
            va_id: vaId,
            event_name: document.getElementById('EventName')?.value || '',
            event_url: document.getElementById('EventURL')?.value || '',
            event_beschreibung: document.getElementById('EventBeschreibung')?.value || ''
        };

        // API-Call zum Speichern
        const response = await fetch(`http://localhost:5000/api/auftraege/${vaId}/eventdaten`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(eventdaten)
        });

        if (response.ok) {
            if (typeof Toast !== 'undefined') Toast.success('Eventdaten gespeichert');
        } else {
            throw new Error('HTTP ' + response.status);
        }
    } catch (err) {
        console.error('[Auftragstamm] Fehler beim Speichern der Eventdaten:', err);
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Speichern');
    }
};

// closeForm - Formular schliessen
window.closeForm = typeof closeForm === 'function' ? closeForm : function() {
    if (window.parent !== window) {
        window.parent.postMessage({ type: 'CLOSE' }, '*');
    } else {
        window.close();
    }
};

// ============ WRAPPER-FUNKTIONEN (Button-Kompatibilität) ============
// Diese Funktionen sorgen dafür, dass die onclick-Handler im HTML
// mit den definierten JS-Funktionen kompatibel sind

// Aktualisierung
function refreshData() { return requeryAll(); }

// Auftrags-Aktionen
function auftragKopieren() { return kopierenAuftrag(false); }
function auftragLoeschen() { return loeschenAuftrag(); }

// Einsatzlisten & Export
function namenslisteESS() { return druckeNamenlisteESS(); }
function einsatzlisteDrucken() { return druckeEinsatzliste(); }
function sendeEinsatzlisteMA() { return sendeEinsatzliste('MA'); }
function sendeEinsatzlisteBOS() { return sendeEinsatzliste('BOS'); }
function sendeEinsatzlisteSUB() { return sendeEinsatzliste('SUB'); }
function sendeEinsatzlistePOS() { return sendeEinsatzliste('POS'); }

// Auftrag aus Vorlage erstellen (Access: btn_VA_Neu_Aus_Vorlage_Click)
async function auftragAusVorlage() {
    console.log('[auftragAusVorlage] Auftrag aus Vorlage erstellen');

    // Pruefe ob VBA Bridge verfuegbar
    try {
        const response = await fetch('http://localhost:5002/api/vba/auftrag/aus-vorlage', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });

        if (response.ok) {
            const result = await response.json();
            if (result.va_id) {
                // Neuen Auftrag laden
                state.currentVA_ID = result.va_id;
                await loadAuftragDetails(result.va_id);
                setStatus('Auftrag aus Vorlage erstellt: ' + result.va_id);
            }
        } else {
            // Fallback: Manueller Dialog
            const vorlageId = prompt('Vorlagen-Auftrag-ID eingeben:');
            if (vorlageId) {
                alert('Auftrag aus Vorlage ' + vorlageId + ' wird erstellt (VBA Bridge erforderlich)');
            }
        }
    } catch (error) {
        console.warn('[auftragAusVorlage] VBA Bridge nicht verfuegbar:', error.message);
        alert('Auftrag aus Vorlage: VBA Bridge erforderlich (Port 5002)');
    }
}

// Datum-Navigation
function datumNavLeft() { return navigateVADatum('left'); }
function datumNavRight() { return navigateVADatum('right'); }

// BWN - ENTFERNT: Diese ueberschrieben die korrekten HTML-Funktionen (VBA Bridge)
// HTML definiert bwnDrucken() und bwnSenden() bereits korrekt mit VBA Bridge (Port 5002)
// function bwnDrucken() { return druckeBWN(); }
// function bwnSenden() { return cmdBWNSend(); }

// Attachments
function neuenAttachHinzufuegen() { return addNewAttachment(); }

// Auftrags-Filter & Navigation
function filterAuftraege() { return applyAuftraegeFilter(); }
function tageZurueck() { return shiftAuftraegeFilter(-7); }
function tageVor() { return shiftAuftraegeFilter(7); }
function abHeute() { return setAuftraegeFilterToday(); }

// Typo-Fix (Rückmeldestatistik)
function openRueckmeldStatistik() { return openRueckmeldeStatistik(); }

// Fenster-Steuerung
function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.warn('[toggleFullscreen] Vollbild nicht möglich:', err);
        });
    } else {
        document.exitFullscreen();
    }
}

function toggleMaximize() {
    // Versuche über Bridge (falls in WebView2)
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('toggle-maximize');
    } else {
        // Fallback: Vollbild
        toggleFullscreen();
    }
}

// Modal-Management
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
    }
}

// EL-Gesendet-Modal
function showELGesendet() {
    const modal = document.getElementById('elGesendetModal');
    if (modal) {
        modal.style.display = 'block';
    } else {
        console.warn('[showELGesendet] Modal elGesendetModal nicht gefunden');
    }
}

// Status-Filter - Alias auf window.filterByStatus (17.01.2026 korrigiert)
// Die echte Implementierung ist in window.filterByStatus definiert
function filterByStatus(statusId) {
    return window.filterByStatus(statusId);
}

// Sortierung
function sortAuftraege(field) {
    console.log('[sortAuftraege] Sortiere nach:', field);
    if (!state.sortField || state.sortField !== field) {
        state.sortField = field;
        state.sortAsc = true;
    } else {
        state.sortAsc = !state.sortAsc;
    }
    renderAuftragsliste();
}

// Syncfehler-Link
function openSyncfehler() {
    if (typeof Bridge !== 'undefined' && Bridge.openForm) {
        Bridge.openForm('frm_SyncError');
    } else {
        console.warn('[openSyncfehler] Bridge nicht verfügbar');
    }
}

// Attachment-Funktionen (Platzhalter für zukünftige Implementierung)
function openAttachment(attachId) {
    console.log('[openAttachment] Öffne Attachment:', attachId);
    // TODO: Implementierung über Bridge oder API
    if (typeof Bridge !== 'undefined' && Bridge.executeVBA) {
        Bridge.executeVBA('OpenAttachment', attachId);
    }
}

function downloadAttachment(attachId) {
    console.log('[downloadAttachment] Lade Attachment herunter:', attachId);
    // TODO: Implementierung über API
}

function deleteAttachment(attachId) {
    console.log('[deleteAttachment] Lösche Attachment:', attachId);
    // TODO: Implementierung über API
}

// ============ RECHNUNGS-FUNKTIONEN (VBA Bridge) ============

/**
 * Erstellt Rechnungs-PDF via VBA.
 * Entspricht btnPDFKopf_Click in Access.
 */
async function rechnungPDF() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    try {
        setStatus('Erstelle Rechnungs-PDF...');

        const response = await fetch('http://localhost:5002/api/vba/rechnung/pdf', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ va_id: state.currentVA_ID })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Rechnungs-PDF erstellt');
            showToast('Rechnungs-PDF wurde erstellt', 'success');
            if (result.pdf_path) {
                alert('PDF erstellt:\n' + result.pdf_path);
            }
        } else {
            throw new Error(result.error || 'PDF-Erstellung fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Rechnungs-PDF Fehler:', error);
        setStatus('Fehler bei PDF-Erstellung');
        showToast('Fehler: ' + error.message, 'error');
    }
}

/**
 * Erstellt Berechnungsliste-PDF via VBA.
 * Entspricht btnPDFPos_Click in Access.
 */
async function berechnungslistePDF() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    try {
        setStatus('Erstelle Berechnungsliste-PDF...');

        const response = await fetch('http://localhost:5002/api/vba/berechnungsliste/pdf', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ va_id: state.currentVA_ID })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Berechnungsliste-PDF erstellt');
            showToast('Berechnungsliste wurde erstellt', 'success');
            if (result.pdf_path) {
                alert('PDF erstellt:\n' + result.pdf_path);
            }
        } else {
            throw new Error(result.error || 'PDF-Erstellung fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Berechnungsliste-PDF Fehler:', error);
        setStatus('Fehler bei PDF-Erstellung');
        showToast('Fehler: ' + error.message, 'error');
    }
}

/**
 * Lädt Rechnungsdaten (Berechnungsliste füllen) via VBA.
 * Entspricht btnLoad_Click -> fill_Berechnungsliste() in Access.
 */
async function rechnungDatenLaden() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    try {
        setStatus('Lade Rechnungsdaten...');

        const response = await fetch('http://localhost:5002/api/vba/rechnung/daten-laden', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ va_id: state.currentVA_ID })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Rechnungsdaten geladen');
            showToast('Rechnungsdaten wurden geladen', 'success');
            // Subform aktualisieren
            sendToSubform('sub_Berechnungsliste', { type: 'requery' });
        } else {
            throw new Error(result.error || 'Laden fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Rechnungsdaten Fehler:', error);
        setStatus('Fehler beim Laden der Rechnungsdaten');
        showToast('Fehler: ' + error.message, 'error');
    }
}

/**
 * Erstellt Rechnung in Lexware via VBA.
 * Entspricht btnRchLex_Click in Access.
 */
async function rechnungLexware() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    if (!confirm('Rechnung in Lexware erstellen?\n\nDies erstellt eine neue Rechnung im Lexware-System.')) {
        return;
    }

    try {
        setStatus('Erstelle Lexware-Rechnung...');

        const response = await fetch('http://localhost:5002/api/vba/rechnung/lexware', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                va_id: state.currentVA_ID,
                kun_id: state.currentRecord?.Veranstalter_ID || 0
            })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Lexware-Rechnung erstellt');
            showToast('Rechnung in Lexware erstellt', 'success');
            if (result.lexware_nr) {
                alert('Lexware-Rechnungsnummer: ' + result.lexware_nr);
            }
        } else {
            throw new Error(result.error || 'Lexware-Rechnung fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Lexware-Rechnung Fehler:', error);
        setStatus('Fehler bei Lexware-Rechnung');
        showToast('Fehler: ' + error.message, 'error');
    }
}

// ============ WEITERE VBA-FUNKTIONEN ============

/**
 * Sortiert MA-Zuordnungen nach Zeit und Name.
 * Entspricht btn_sortieren_Click -> sort_zuo_plan() in Access.
 */
async function sortiereZuordnungen() {
    if (!state.currentVA_ID || !state.currentVADatum_ID) {
        alert('Bitte zuerst einen Auftrag und ein Datum auswählen');
        return;
    }

    try {
        setStatus('Sortiere Zuordnungen...');

        const response = await fetch('http://localhost:5002/api/vba/sortieren', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                va_id: state.currentVA_ID,
                vadatum_id: state.currentVADatum_ID,
                mode: 1  // 1=Zuordnung
            })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Zuordnungen sortiert');
            showToast('MA-Zuordnungen wurden sortiert', 'success');
            // Einsatzliste aktualisieren
            updateMASubforms();
        } else {
            throw new Error(result.error || 'Sortierung fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Sortierung Fehler:', error);
        setStatus('Fehler bei Sortierung');
        showToast('Fehler: ' + error.message, 'error');
    }
}

/**
 * Erstellt Zuordnungs-Slots für alle Schichten.
 * Entspricht btnVAPlanCrea_Click -> Zuord_Fill() in Access.
 */
async function erstelleZuordnungen() {
    if (!state.currentVA_ID || !state.currentVADatum_ID) {
        alert('Bitte zuerst einen Auftrag und ein Datum auswählen');
        return;
    }

    try {
        setStatus('Erstelle Zuordnungen...');

        const response = await fetch('http://localhost:5002/api/vba/zuordnung-fill', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                va_id: state.currentVA_ID,
                vadatum_id: state.currentVADatum_ID
            })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Zuordnungen erstellt');
            showToast('Zuordnungs-Slots wurden erstellt', 'success');
            // Subforms aktualisieren
            updateAllSubforms();
        } else {
            throw new Error(result.error || 'Erstellung fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Zuordnung erstellen Fehler:', error);
        setStatus('Fehler beim Erstellen');
        showToast('Fehler: ' + error.message, 'error');
    }
}

/**
 * Stunden-Check: Status auf Abrechnung + EL drucken.
 * Entspricht btn_std_check_Click in Access.
 */
async function stundenCheck() {
    if (!state.currentVA_ID) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }

    if (!confirm('Stunden-Check durchführen?\n\nDies setzt den Status auf "Abrechnung" und erstellt die Einsatzliste.')) {
        return;
    }

    try {
        setStatus('Führe Stunden-Check durch...');

        const response = await fetch('http://localhost:5002/api/vba/std-check', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ va_id: state.currentVA_ID })
        });

        const result = await response.json();

        if (result.success) {
            setStatus('Stunden-Check abgeschlossen');
            showToast('Status auf Abrechnung gesetzt', 'success');

            // Status-Dropdown aktualisieren
            const statusDropdown = document.getElementById('Veranst_Status_ID');
            if (statusDropdown) {
                statusDropdown.value = '3';
                state.previousStatus = 3;
            }

            alert('Stunden-Check abgeschlossen:\n- Status: Abrechnung\n- Einsatzliste wurde erstellt');
        } else {
            throw new Error(result.error || 'Stunden-Check fehlgeschlagen');
        }
    } catch (error) {
        console.error('[Auftragstamm] Stunden-Check Fehler:', error);
        setStatus('Fehler beim Stunden-Check');
        showToast('Fehler: ' + error.message, 'error');
    }
}

/**
 * Öffnet Rückmelde-Auswertung.
 * Entspricht btn_Rueckmeld_Click in Access.
 */
async function openRueckmeldeAuswertung() {
    try {
        const response = await fetch('http://localhost:5002/api/vba/rueckmeldungen', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ va_id: state.currentVA_ID || 0 })
        });

        const result = await response.json();

        if (result.success) {
            showToast('Rückmelde-Formular geöffnet', 'info');
        } else {
            // Fallback: HTML-Formular öffnen
            window.open('zfrm_Rueckmeldungen.html', '_blank');
        }
    } catch (error) {
        console.error('[Auftragstamm] Rückmeldungen Fehler:', error);
        // Fallback: HTML-Formular öffnen
        window.open('zfrm_Rueckmeldungen.html', '_blank');
    }
}

/**
 * Öffnet Abwesenheitsübersicht.
 * Entspricht btn_VA_Abwesenheiten_Click in Access.
 */
async function openAbwesenheiten() {
    try {
        const response = await fetch('http://localhost:5002/api/vba/abwesenheiten', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });

        const result = await response.json();

        if (result.success) {
            showToast('Abwesenheits-Formular geöffnet', 'info');
        } else {
            // Fallback: HTML-Formular öffnen
            window.open('frm_abwesenheitsuebersicht.html', '_blank');
        }
    } catch (error) {
        console.error('[Auftragstamm] Abwesenheiten Fehler:', error);
        // Fallback: HTML-Formular öffnen
        window.open('frm_abwesenheitsuebersicht.html', '_blank');
    }
}

// Eventdaten-Funktionen
function webDatenLaden() {
    console.log('[webDatenLaden] Lade Web-Eventdaten');
    // TODO: Implementierung - Scraping oder API-Import
    showToast('Web-Eventdaten laden wird noch implementiert', 'info');
}

// ============ EXPORT ============
window.Auftragstamm = {
    requery: requeryAll,
    loadAuftrag: loadAuftrag,
    getState() { return state; },
    applyGridZuordnungenColumnRules: applyGridZuordnungenColumnRules
};

// Globale Funktion fuer Aufruf aus renderZuordnungen
window.applyGridZuordnungenColumnRules = applyGridZuordnungenColumnRules;

document.addEventListener('DOMContentLoaded', async () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('embedded') === '1') {
        document.body.classList.add('embedded');
    }
    if (window.ApiAutostart) {
        await window.ApiAutostart.init();
    }

    // Scroll-Geschwindigkeit der Auftragsliste reduzieren (15.01.2026)
    const auftraegeListeContainer = document.querySelector('.auftraege-liste');
    if (auftraegeListeContainer) {
        auftraegeListeContainer.addEventListener('wheel', (e) => {
            e.preventDefault();
            const delta = e.deltaY;
            // Scroll-Geschwindigkeit auf 30% reduzieren (statt 100%)
            auftraegeListeContainer.scrollTop += delta * 0.3;
        }, { passive: false });
    }

    init();
});
