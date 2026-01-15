/**
 * frm_MA_VA_Schnellauswahl.logic.js
 * Logik fuer Mitarbeiter-Schnellauswahl
 *
 * Funktionen:
 * - Auftraege und Schichten laden
 * - Mitarbeiter laden mit Verfuegbarkeitspruefung
 * - Filtern und Suchen
 * - Mitarbeiter zuordnen
 */

import { Bridge } from '../api/bridgeClient.js';

// ============================================
// State
// ============================================
const state = {
    auftraege: [],
    schichten: [],
    mitarbeiter: [],
    entfernungen: new Map(),  // MA_ID -> Entf_KM
    currentObjektId: null,
    selectedAuftrag: null,
    selectedDatum: null,
    selectedSchicht: null,
    selectedMAs: new Set(),
    filteredMitarbeiter: [],
    sortMode: 'standard',  // 'standard' oder 'entfernung'
    filter: {
        typ: 'alle',
        nurAktive: true,
        suche: ''
    }
};

// ============================================
// DOM Elements
// ============================================
let elements = {};

// ============================================
// Initialisierung
// ============================================
function init() {
    console.log('[Schnellauswahl] Initialisierung...');

    elements = {
        // Filter (HTML IDs)
        cboAuftrag: document.getElementById('VA_ID'),
        datEinsatz: document.getElementById('cboVADatum'),
        cboSchicht: document.getElementById('lstZeiten_Body'),
        txtSuche: document.getElementById('strSchnellSuche'),
        chkNurAktive: document.getElementById('IstAktiv'),
        chkNurFreie: document.getElementById('IstVerfuegbar'),
        chkNur34a: document.getElementById('cbNur34a'),
        cboAnstArt: document.getElementById('cboAnstArt'),
        cboQuali: document.getElementById('cboQuali'),

        // Buttons
        btnZuordnen: document.getElementById('btnAddSelected'),
        btnAktualisieren: document.getElementById('btnSchnellGo'),
        btnMailSelected: document.getElementById('btnMailSelected'),
        btnMail: document.getElementById('btnMail'),
        btnAuftrag: document.getElementById('btnAuftrag'),
        btnClose: document.getElementById('btnClose'),
        btnDelSelected: document.getElementById('btnDelSelected'),
        btnListStandard: document.getElementById('cmdListMA_Standard'),
        btnListEntfernung: document.getElementById('cmdListMA_Entfernung'),

        // Listen
        maList: document.getElementById('List_MA_Body'),
        lstZeiten: document.getElementById('lstZeiten_Body'),
        lstGeplant: document.getElementById('lstMA_Plan_Body'),
        lstZusage: document.getElementById('lstMA_Zusage'),

        // Footer
        lblStatus: document.getElementById('lbAuftrag'),
        lblAnzahl: document.getElementById('iGes_MA'),
        lblDienstEnde: document.getElementById('DienstEnde')
    };

    setupEventListeners();
    loadAuftraege();

    // URL-Parameter pruefen fuer Auto-Load
    // Unterstuetzt sowohl va_id als auch id (fuer Shell-Kompatibilitaet)
    const urlParams = new URLSearchParams(window.location.search);
    const vaId = urlParams.get('va_id') || urlParams.get('id');
    if (vaId) {
        console.log('[Schnellauswahl] URL-Parameter va_id/id gefunden:', vaId);
        // SOFORT state setzen fuer "Zurueck zum Auftrag" Button
        state.selectedAuftrag = vaId;
        // NICHT mehr separat laden - HTML's VAOpen() laedt alles und sendet dispatchEvent
        // Die change-Handler updaten dann state.selectedAuftrag und state.selectedDatum
        // setTimeout(() => loadAuftragById(vaId), 500);  // ENTFERNT - Race Condition vermeiden!
    }
}

// ============================================
// Event Listeners
// ============================================
function setupEventListeners() {
    // Auftrag-Auswahl
    // WICHTIG: Nur State aktualisieren, NICHT selbst Daten laden!
    // HTML's VAOpen() laedt Daten und sendet dispatchEvent wenn fertig.
    elements.cboAuftrag?.addEventListener('change', () => {
        state.selectedAuftrag = elements.cboAuftrag.value;
        console.log('[Logic] Auftrag change - state.selectedAuftrag:', state.selectedAuftrag);
        // NICHT loadEinsatztage() aufrufen - HTML macht das bereits!
    });

    // Datum-Auswahl
    // WICHTIG: Nur State aktualisieren, NICHT selbst Daten laden!
    elements.datEinsatz?.addEventListener('change', () => {
        state.selectedDatum = elements.datEinsatz.value;
        console.log('[Logic] Datum change - state.selectedDatum:', state.selectedDatum);
        // NICHT loadSchichten/loadMitarbeiter aufrufen - HTML macht das bereits!
    });

    // Suche
    elements.txtSuche?.addEventListener('input', debounce(() => {
        state.filter.suche = elements.txtSuche.value.toLowerCase();
        renderMitarbeiterListe();
    }, 200));

    // Filter Checkboxen
    elements.chkNurAktive?.addEventListener('change', renderMitarbeiterListe);
    elements.chkNurFreie?.addEventListener('change', renderMitarbeiterListe);
    elements.chkNur34a?.addEventListener('change', renderMitarbeiterListe);
    elements.cboAnstArt?.addEventListener('change', renderMitarbeiterListe);
    elements.cboQuali?.addEventListener('change', renderMitarbeiterListe);

    // Zuordnen Buttons
    elements.btnZuordnen?.addEventListener('click', zuordnenAuswahl);
    elements.btnDelSelected?.addEventListener('click', entferneAusGeplant);
    elements.btnAktualisieren?.addEventListener('click', renderMitarbeiterListe);

    // E-Mail Anfragen - ENTFERNT: Wird bereits in HTML registriert (btnMail_Click, btnMailSelected_Click)
    // Diese nutzen den korrekten Batch-Endpoint /api/vba/anfragen
    // elements.btnMailSelected?.addEventListener('click', () => versendeAnfragen(false));
    // elements.btnMail?.addEventListener('click', () => versendeAnfragen(true));

    // Navigation - Zurück zum Auftrag
    elements.btnAuftrag?.addEventListener('click', () => {
        if (state.selectedAuftrag) {
            // Shell-Navigation via postMessage (wenn in Shell geladen)
            if (window.parent && window.parent !== window) {
                window.parent.postMessage({
                    type: 'NAVIGATE',
                    formName: 'frm_va_Auftragstamm',
                    id: state.selectedAuftrag
                }, '*');
            } else {
                // Standalone-Modus: direkte Navigation
                window.location.href = `frm_va_Auftragstamm.html?id=${state.selectedAuftrag}`;
            }
        } else {
            // Kein Auftrag ausgewählt - trotzdem zurück navigieren
            if (window.parent && window.parent !== window) {
                window.parent.postMessage({
                    type: 'NAVIGATE',
                    formName: 'frm_va_Auftragstamm'
                }, '*');
            } else {
                window.location.href = 'frm_va_Auftragstamm.html';
            }
        }
    });
    elements.btnClose?.addEventListener('click', () => {
        // Shell-Navigation: Zum Menü oder Auftragsverwaltung
        if (window.parent && window.parent !== window) {
            window.parent.postMessage({
                type: 'NAVIGATE',
                formName: 'frm_va_Auftragstamm'
            }, '*');
        } else {
            window.close();
        }
    });

    // Sortier-Buttons (Access-kompatibel: cmdListMA_Standard, cmdListMA_Entfernung)
    elements.btnListStandard?.addEventListener('click', cmdListMA_Standard);
    elements.btnListEntfernung?.addEventListener('click', cmdListMA_Entfernung);
}

// ============================================
// Auftraege laden
// ============================================
async function loadAuftraege() {
    try {
        setStatus('Lade Auftraege...');

        // REST-API direkt nutzen (Bridge.loadData mit 'auftraege' fired kein Event!)
        const heute = new Date().toISOString().split('T')[0];
        const response = await fetch(`http://localhost:5000/api/auftraege?ab_datum=${heute}&limit=200`);
        const result = await response.json();

        if (result.success && result.data) {
            state.auftraege = result.data;

            // Dropdown befuellen
            if (elements.cboAuftrag) {
                elements.cboAuftrag.innerHTML = '<option value="">-- Auftrag wählen --</option>';
                state.auftraege.forEach(a => {
                    const opt = document.createElement('option');
                    opt.value = a.ID || a.VA_ID;
                    const datum = formatDate(a.Dat_VA_Von || a.VADatum);
                    opt.textContent = `${datum} ${a.Auftrag || ''} ${a.Objekt || ''}`;
                    elements.cboAuftrag.appendChild(opt);
                });
            }
            setStatus(`${state.auftraege.length} Aufträge geladen`);
            console.log('[Schnellauswahl] Aufträge geladen:', state.auftraege.length);
        }

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden Auftraege:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// Bridge Event Handler für Aufträge
Bridge.on('onDataReceived', function(data) {
    if (data.type === 'auftraege') {
        state.auftraege = data.records || [];

        // Dropdown befüllen
        if (elements.cboAuftrag) {
            elements.cboAuftrag.innerHTML = '<option value="">-- Auftrag wählen --</option>';
            state.auftraege.forEach(a => {
                const opt = document.createElement('option');
                opt.value = a.ID || a.VA_ID;
                const datum = formatDate(a.Dat_VA_Von || a.VADatum);
                opt.textContent = `${datum} ${a.Auftrag || ''} ${a.Objekt || ''}`;
                elements.cboAuftrag.appendChild(opt);
            });
        }
        setStatus('Aufträge geladen');
    }
    else if (data.type === 'einsatztage') {
        const tage = data.records || [];

        // Dropdown befüllen
        if (elements.datEinsatz) {
            elements.datEinsatz.innerHTML = '<option value="">-- Datum --</option>';
            tage.forEach(t => {
                const opt = document.createElement('option');
                opt.value = t.ID;
                opt.textContent = formatDate(t.VADatum);
                elements.datEinsatz.appendChild(opt);
            });
        }
        setStatus('Einsatztage geladen');
    }
    else if (data.type === 'schichten') {
        state.schichten = data.records || [];
        renderSchichtenListe();
        const gesamt = state.schichten.reduce((s, z) => s + (z.MA_Anzahl || 0), 0);
        if (elements.lblAnzahl) elements.lblAnzahl.value = gesamt;
        setStatus('Schichten geladen');
    }
    else if (data.type === 'mitarbeiter') {
        state.mitarbeiter = data.records || [];
        renderMitarbeiterListe();
        setStatus(`${state.mitarbeiter.length} Mitarbeiter geladen`);
    }
});

// ============================================
// Einsatztage laden
// ============================================
async function loadEinsatztage() {
    if (!state.selectedAuftrag) return;

    try {
        setStatus('Lade Einsatztage...');
        Bridge.loadData('einsatztage', null, { va_id: state.selectedAuftrag });

        // Auch Auftragsdaten für Statusanzeige laden
        const auftrag = state.auftraege.find(a => (a.ID || a.VA_ID) == state.selectedAuftrag);
        if (auftrag && elements.lblStatus) {
            elements.lblStatus.textContent = `${formatDate(auftrag.Dat_VA_Von)} ${auftrag.Auftrag || ''} ${auftrag.Objekt || ''}`;
        }

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden Einsatztage:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Auto-Load Auftrag by ID (URL-Parameter)
// ============================================
async function loadAuftragById(vaId) {
    console.log('[Schnellauswahl] Auto-Load Auftrag:', vaId);
    try {
        // Auftrag laden via REST API
        const response = await fetch(`http://localhost:5000/api/auftraege/${vaId}`);
        const result = await response.json();

        if (result.success && result.data) {
            const a = result.data;

            // Auftrag in State speichern
            state.selectedAuftrag = vaId;

            // Dropdown setzen (falls Option existiert)
            if (elements.cboAuftrag) {
                // Option hinzufuegen falls nicht vorhanden
                let option = elements.cboAuftrag.querySelector(`option[value="${vaId}"]`);
                if (!option) {
                    option = document.createElement('option');
                    option.value = vaId;
                    const datum = formatDate(a.Dat_VA_Von || a.VADatum);
                    option.textContent = `${datum} ${a.Auftrag || ''} ${a.Objekt || ''}`;
                    elements.cboAuftrag.appendChild(option);
                }
                elements.cboAuftrag.value = vaId;
            }

            // Status-Label setzen
            if (elements.lblStatus) {
                const datum = formatDate(a.Dat_VA_Von || a.VADatum);
                elements.lblStatus.textContent = `${datum} ${a.Auftrag || ''} - ${a.Objekt || ''} - ${a.Ort || ''}`;
            }

            // Objekt_ID merken fuer Entfernungsberechnung
            state.currentObjektId = a.Objekt_ID || a.VA_Objekt_ID;

            // Einsatztage fuer diesen Auftrag laden
            await loadEinsatztageForVA(vaId);

            console.log('[Schnellauswahl] Auto-Load erfolgreich:', a.Auftrag);
        } else {
            console.warn('[Schnellauswahl] Auftrag nicht gefunden:', vaId);
            setStatus('Auftrag nicht gefunden');
        }
    } catch (error) {
        console.error('[Schnellauswahl] Auto-Load Fehler:', error);
        setStatus('Fehler beim Laden: ' + error.message);
    }
}

// ============================================
// Einsatztage fuer spezifischen Auftrag laden
// ============================================
async function loadEinsatztageForVA(vaId) {
    console.log('[Schnellauswahl] Lade Einsatztage fuer VA:', vaId);
    try {
        // REST API Call fuer Einsatztage
        const response = await fetch(`http://localhost:5000/api/einsatztage?va_id=${vaId}`);
        const result = await response.json();

        if (result.success && result.data) {
            const tage = result.data;

            // Dropdown befuellen
            if (elements.datEinsatz) {
                elements.datEinsatz.innerHTML = '<option value="">-- Datum --</option>';
                tage.forEach(t => {
                    const opt = document.createElement('option');
                    opt.value = t.ID || t.VADatum_ID;
                    opt.textContent = formatDate(t.VADatum);
                    elements.datEinsatz.appendChild(opt);
                });

                // Erstes/naechstes Datum automatisch auswaehlen
                const heute = new Date().toISOString().split('T')[0];
                let selectedTag = tage.find(t => {
                    const tagDatum = new Date(t.VADatum).toISOString().split('T')[0];
                    return tagDatum >= heute;
                }) || tage[0];

                if (selectedTag && elements.datEinsatz.options.length > 1) {
                    const selectedId = selectedTag.ID || selectedTag.VADatum_ID;
                    elements.datEinsatz.value = selectedId;
                    state.selectedDatum = selectedId;

                    // Schichten und MA laden
                    await loadSchichten();
                    await loadMitarbeiter();
                }
            }

            console.log('[Schnellauswahl] Einsatztage geladen:', tage.length);
        } else {
            console.warn('[Schnellauswahl] Keine Einsatztage gefunden');
            if (elements.datEinsatz) {
                elements.datEinsatz.innerHTML = '<option value="">-- Keine Einsatztage --</option>';
            }
        }
    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden der Einsatztage:', error);

        // Fallback: Bridge verwenden
        Bridge.loadData('einsatztage', null, { va_id: vaId });
    }
}

// ============================================
// Schichten laden
// ============================================
async function loadSchichten() {
    if (!state.selectedAuftrag) return;

    try {
        setStatus('Lade Schichten...');
        Bridge.loadData('schichten', null, { va_id: state.selectedAuftrag });

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden Schichten:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Schichten-Liste rendern
// ============================================
function renderSchichtenListe() {
    if (!elements.lstZeiten) return;

    if (!state.schichten.length) {
        elements.lstZeiten.innerHTML = '<div style="padding:10px;color:#888;">Keine Schichten</div>';
        return;
    }

    elements.lstZeiten.innerHTML = state.schichten.map((z, i) => `
        <div class="listbox-row ${state.selectedSchicht === i ? 'selected' : ''}" data-idx="${i}">
            <span style="flex: 1;">${z.MA_Anzahl_Ist || 0}</span>
            <span style="flex: 1;">${z.MA_Anzahl || 0}</span>
            <span style="flex: 1;">${formatTime(z.VA_Start)}</span>
            <span style="flex: 1;">${formatTime(z.VA_Ende)}</span>
        </div>
    `).join('');

    // Event Listener
    elements.lstZeiten.querySelectorAll('.listbox-row[data-idx]').forEach(row => {
        row.addEventListener('click', () => {
            state.selectedSchicht = parseInt(row.dataset.idx);
            elements.lstZeiten.querySelectorAll('.listbox-row').forEach(r => r.classList.remove('selected'));
            row.classList.add('selected');
            if (elements.lblDienstEnde) {
                elements.lblDienstEnde.value = formatTime(state.schichten[state.selectedSchicht]?.VA_Ende);
            }
        });
    });
}

// ============================================
// Mitarbeiter laden
// ============================================
async function loadMitarbeiter() {
    try {
        setStatus('Lade Mitarbeiter...');
        Bridge.loadData('mitarbeiter', null, { aktiv: true });

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden MA:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Mitarbeiter-Liste rendern
// ============================================
function renderMitarbeiterListe() {
    if (!elements.maList) return;

    const nurAktive = elements.chkNurAktive?.checked || false;
    const nurFreie = elements.chkNurFreie?.checked || false;
    const nur34a = elements.chkNur34a?.checked || false;
    const anst = elements.cboAnstArt?.value || '';
    const suche = state.filter.suche;

    // Filtern
    let gefiltert = state.mitarbeiter.filter(ma => {
        if (nurAktive && !ma.IstAktiv) return false;
        if (nur34a && !ma.Hat34a) return false;
        if (anst && ma.Anstellungsart_ID != anst) return false;
        if (suche) {
            const name = `${ma.Nachname} ${ma.Vorname}`.toLowerCase();
            if (!name.includes(suche)) return false;
        }
        return true;
    });

    state.filteredMitarbeiter = gefiltert;

    if (gefiltert.length === 0) {
        elements.maList.innerHTML = '<div style="padding:20px;text-align:center;color:#888;">Keine Mitarbeiter gefunden</div>';
        return;
    }

    elements.maList.innerHTML = gefiltert.map(ma => {
        const id = ma.ID;
        const isSelected = state.selectedMAs.has(id);

        return `
            <div class="listbox-row ${isSelected ? 'selected' : ''}" data-id="${id}">
                <span style="flex: 2;">${ma.Nachname || ''}, ${ma.Vorname || ''}</span>
                <span style="flex: 1;">${ma.Stunden || ''}</span>
                <span style="flex: 1;">${ma.Beginn || ''}</span>
                <span style="flex: 1;">${ma.Ende || ''}</span>
                <span style="flex: 1;"></span>
            </div>
        `;
    }).join('');

    // Event Listener - NUR click, KEIN dblclick!
    // dblclick wird in HTML via List_MA_DblClick behandelt (ruft addMAToPlanung auf)
    elements.maList.querySelectorAll('.listbox-row[data-id]').forEach(row => {
        const id = parseInt(row.dataset.id);

        row.addEventListener('click', () => {
            if (state.selectedMAs.has(id)) {
                state.selectedMAs.delete(id);
                row.classList.remove('selected');
            } else {
                state.selectedMAs.add(id);
                row.classList.add('selected');
            }
        });

        // ENTFERNT: dblclick-Handler verursacht Konflikt mit HTML List_MA_DblClick
        // Die HTML-Version ist die korrekte - NICHT WIEDER AKTIVIEREN!
        // row.addEventListener('dblclick', () => {
        //     zuordneEinzelnenMA(id);
        // });
    });
}

// ============================================
// Zuordnen
// ============================================
async function zuordnenAuswahl() {
    if (state.selectedMAs.size === 0) {
        alert('Bitte Mitarbeiter auswählen');
        return;
    }

    if (!state.selectedAuftrag || !state.selectedDatum) {
        alert('Bitte Auftrag und Datum wählen');
        return;
    }

    for (const maId of state.selectedMAs) {
        await zuordneEinzelnenMA(maId);
    }

    state.selectedMAs.clear();
    renderMitarbeiterListe();
}

async function zuordneEinzelnenMA(maId) {
    const vaStartId = state.selectedSchicht !== null
        ? state.schichten[state.selectedSchicht]?.ID
        : null;

    Bridge.sendEvent('save', {
        type: 'zuordnung',
        action: 'create',
        data: {
            ma_id: maId,
            va_id: state.selectedAuftrag,
            vadatum_id: state.selectedDatum,
            vastart_id: vaStartId
        }
    });
}

async function entferneAusGeplant() {
    if (state.selectedMAs.size === 0) {
        alert('Bitte Mitarbeiter auswählen');
        return;
    }

    showCustomConfirm(`${state.selectedMAs.size} Zuordnung(en) löschen?`, async () => {
        for (const maId of state.selectedMAs) {
            Bridge.sendEvent('delete', {
                type: 'zuordnung',
                ma_id: maId,
                va_id: state.selectedAuftrag
            });
        }

        state.selectedMAs.clear();
        renderMitarbeiterListe();
    });
}

// ============================================
// Helper
// ============================================
function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) {
        return value.substring(0, 5);
    }
    // Dezimalwert (Access)
    if (typeof value === 'number' && value < 1) {
        const hours = Math.floor(value * 24);
        const mins = Math.round((value * 24 - hours) * 60);
        return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
    }
    try {
        return new Date(value).toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
    } catch {
        return value;
    }
}

function debounce(fn, delay) {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), delay);
    };
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function formatDate(d) {
    if (!d) return '';
    try {
        return new Date(d).toLocaleDateString('de-DE');
    } catch {
        return d;
    }
}

// ============================================
// Custom Confirm Modal (ohne Browser-Alert)
// ============================================
function showCustomConfirm(message, onConfirm, onCancel) {
    // Bestehenden Modal entfernen falls vorhanden
    let existingModal = document.getElementById('customConfirmModal');
    if (existingModal) existingModal.remove();

    // Modal erstellen
    const modal = document.createElement('div');
    modal.id = 'customConfirmModal';
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 10001;
        display: flex;
        align-items: center;
        justify-content: center;
    `;

    modal.innerHTML = `
        <div style="
            background: #d4d0c8;
            border: 2px solid;
            border-color: #ffffff #404040 #404040 #ffffff;
            min-width: 300px;
            max-width: 450px;
            box-shadow: 4px 4px 10px rgba(0,0,0,0.3);
        ">
            <div style="
                background: linear-gradient(to right, #000080, #1084d0);
                color: white;
                padding: 6px 12px;
                font-weight: bold;
                font-size: 12px;
            ">Bestätigung</div>
            <div style="padding: 20px; font-size: 12px; line-height: 1.5;">
                ${message.replace(/\n/g, '<br>')}
            </div>
            <div style="
                padding: 12px;
                text-align: center;
                border-top: 1px solid #808080;
                display: flex;
                gap: 15px;
                justify-content: center;
            ">
                <button id="confirmYes" style="
                    background: linear-gradient(to bottom, #60c060, #308030);
                    color: white;
                    border: 2px solid;
                    border-color: #ffffff #505050 #505050 #ffffff;
                    padding: 6px 25px;
                    cursor: pointer;
                    font-size: 12px;
                    font-weight: bold;
                ">OK</button>
                <button id="confirmNo" style="
                    background: linear-gradient(to bottom, #e8e8e8, #c0c0c0);
                    border: 2px solid;
                    border-color: #ffffff #808080 #808080 #ffffff;
                    padding: 6px 25px;
                    cursor: pointer;
                    font-size: 12px;
                ">Abbrechen</button>
            </div>
        </div>
    `;

    document.body.appendChild(modal);

    // Event Listener
    modal.querySelector('#confirmYes').addEventListener('click', () => {
        modal.remove();
        if (onConfirm) onConfirm();
    });

    modal.querySelector('#confirmNo').addEventListener('click', () => {
        modal.remove();
        if (onCancel) onCancel();
    });

    // ESC zum Schließen
    const escHandler = (e) => {
        if (e.key === 'Escape') {
            modal.remove();
            document.removeEventListener('keydown', escHandler);
            if (onCancel) onCancel();
        }
    };
    document.addEventListener('keydown', escHandler);

    // Fokus auf OK-Button
    modal.querySelector('#confirmYes').focus();
}

// ============================================
// Sortier-Funktionen (Access-kompatibel)
// ============================================

/**
 * cmdListMA_Standard_Click - Standard-Ansicht ohne Entfernung
 * Entspricht Access VBA: mdl_frm_MA_VA_Schnellauswahl_Code.cmdListMA_Standard_Click
 */
function cmdListMA_Standard() {
    console.log('[Schnellauswahl] Standard-Ansicht aktiviert');
    state.sortMode = 'standard';
    state.entfernungen.clear();
    renderMitarbeiterListe();
    setStatus('Standard-Ansicht');

    // Button-Highlight
    elements.btnListStandard?.classList.add('active');
    elements.btnListEntfernung?.classList.remove('active');
}

/**
 * cmdListMA_Entfernung_Click - MA-Liste nach Entfernung zum Objekt sortieren
 * Entspricht Access VBA: mdl_frm_MA_VA_Schnellauswahl_Code.cmdListMA_Entfernung_Click
 *
 * Access-Logik:
 * 1. Objekt_ID aus Auftrag holen
 * 2. Entfernungen aus tbl_MA_Objekt_Entfernung laden
 * 3. MA-Liste sortieren (null = 999 km)
 */
async function cmdListMA_Entfernung() {
    console.log('[Schnellauswahl] Entfernungs-Sortierung aktiviert');

    if (!state.selectedAuftrag) {
        alert('Kein Auftrag ausgewaehlt!');
        return;
    }

    // Objekt_ID aus Auftrag ermitteln
    const auftrag = state.auftraege.find(a => (a.ID || a.VA_ID) == state.selectedAuftrag);
    const objektId = auftrag?.Objekt_ID || auftrag?.VA_Objekt_ID;

    if (!objektId) {
        alert('Kein Objekt fuer diesen Auftrag hinterlegt!');
        return;
    }

    state.currentObjektId = objektId;
    setStatus('Lade Entfernungen...');

    try {
        // Entfernungen vom API laden
        const result = await Bridge.execute('getEntfernungen', { objekt_id: objektId });

        if (result.data && Array.isArray(result.data)) {
            // In Map speichern: MA_ID -> Entf_KM
            state.entfernungen.clear();
            result.data.forEach(e => {
                state.entfernungen.set(e.MA_ID, e.Entf_KM);
            });
            console.log(`[Schnellauswahl] ${state.entfernungen.size} Entfernungen geladen`);
        }

        state.sortMode = 'entfernung';
        renderMitarbeiterListeMitEntfernung();

        // Button-Highlight
        elements.btnListStandard?.classList.remove('active');
        elements.btnListEntfernung?.classList.add('active');

        setStatus(`${state.filteredMitarbeiter.length} MA nach Entfernung sortiert`);

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden der Entfernungen:', error);

        // Fallback: Haversine-Berechnung clientseitig (wenn Geo-Daten vorhanden)
        if (state.mitarbeiter.some(m => m.Lat && m.Lon)) {
            calculateEntfernungenClientside();
        } else {
            alert('Entfernungsdaten nicht verfuegbar.\nBitte API-Endpoint /api/entfernungen implementieren.');
            setStatus('Fehler: Entfernungen nicht verfuegbar');
        }
    }
}

/**
 * Fallback: Entfernungen clientseitig berechnen (Haversine)
 * Nur wenn MA und Objekt Geo-Koordinaten haben
 */
async function calculateEntfernungenClientside() {
    console.log('[Schnellauswahl] Fallback: Clientseitige Entfernungsberechnung');

    // Objekt-Koordinaten laden (falls nicht vorhanden)
    let objektLat = 0, objektLon = 0;

    try {
        const objektResult = await Bridge.execute('getObjekt', { id: state.currentObjektId });
        if (objektResult.data) {
            objektLat = objektResult.data.Lat || objektResult.data.GeoLat || 0;
            objektLon = objektResult.data.Lon || objektResult.data.GeoLon || 0;
        }
    } catch (e) {
        console.warn('[Schnellauswahl] Objekt-Geo-Daten nicht verfuegbar:', e);
    }

    if (!objektLat || !objektLon) {
        alert('Keine Geo-Koordinaten fuer das Objekt vorhanden.');
        return;
    }

    // Entfernungen berechnen
    state.entfernungen.clear();
    state.mitarbeiter.forEach(ma => {
        const maLat = ma.Lat || ma.GeoLat || 0;
        const maLon = ma.Lon || ma.GeoLon || 0;

        if (maLat && maLon) {
            const entf = haversineDistanz(maLat, maLon, objektLat, objektLon);
            state.entfernungen.set(ma.ID, Math.round(entf * 10) / 10);
        }
    });

    state.sortMode = 'entfernung';
    renderMitarbeiterListeMitEntfernung();
    setStatus(`${state.entfernungen.size} Entfernungen berechnet`);
}

/**
 * Haversine-Formel zur Entfernungsberechnung
 * Entspricht Access VBA: mdl_GeoDistanz.DistanceKm
 */
function haversineDistanz(lat1, lon1, lat2, lon2) {
    const PI = Math.PI;
    const EARTH_RADIUS_KM = 6371;

    if (!lat1 || !lon1 || !lat2 || !lon2) return 999;

    const dLat = (lat2 - lat1) * PI / 180;
    const dLon = (lon2 - lon1) * PI / 180;

    const a = Math.sin(dLat / 2) ** 2 +
              Math.cos(lat1 * PI / 180) * Math.cos(lat2 * PI / 180) *
              Math.sin(dLon / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return EARTH_RADIUS_KM * c;
}

/**
 * MA-Liste mit Entfernungsspalte rendern
 * Entspricht Access: frm!List_MA.RowSource = "ztmp_MA_Entfernung"
 */
function renderMitarbeiterListeMitEntfernung() {
    if (!elements.maList) return;

    const nurAktive = elements.chkNurAktive?.checked || false;
    const nurFreie = elements.chkNurFreie?.checked || false;
    const nur34a = elements.chkNur34a?.checked || false;
    const anst = elements.cboAnstArt?.value || '';
    const suche = state.filter.suche;

    // Filtern
    let gefiltert = state.mitarbeiter.filter(ma => {
        if (nurAktive && !ma.IstAktiv) return false;
        if (nur34a && !ma.Hat34a) return false;
        if (anst && ma.Anstellungsart_ID != anst) return false;
        if (suche) {
            const name = `${ma.Nachname} ${ma.Vorname}`.toLowerCase();
            if (!name.includes(suche)) return false;
        }
        return true;
    });

    // Nach Entfernung sortieren (null/unbekannt = 999)
    gefiltert.sort((a, b) => {
        const entfA = state.entfernungen.get(a.ID) ?? 999;
        const entfB = state.entfernungen.get(b.ID) ?? 999;
        if (entfA !== entfB) return entfA - entfB;
        // Sekundaer: alphabetisch nach Name
        return (a.Nachname || '').localeCompare(b.Nachname || '');
    });

    state.filteredMitarbeiter = gefiltert;

    if (gefiltert.length === 0) {
        elements.maList.innerHTML = '<div style="padding:20px;text-align:center;color:#888;">Keine Mitarbeiter gefunden</div>';
        return;
    }

    // Render mit Entfernungs-Spalte und Farbcodierung
    elements.maList.innerHTML = gefiltert.map(ma => {
        const id = ma.ID;
        const isSelected = state.selectedMAs.has(id);
        const entf = state.entfernungen.get(id);

        // Farbcodierung wie in Access
        let entfClass = 'entf-unbekannt';
        let entfText = '-- km';
        if (entf !== undefined && entf !== null) {
            entfText = `${entf.toFixed(1)} km`;
            if (entf <= 15) entfClass = 'entf-gruen';
            else if (entf <= 30) entfClass = 'entf-gelb';
            else entfClass = 'entf-rot';
        }

        return `
            <div class="listbox-row ${isSelected ? 'selected' : ''}" data-id="${id}">
                <span style="flex: 2;">${ma.Nachname || ''}, ${ma.Vorname || ''}</span>
                <span style="flex: 1;" class="${entfClass}">${entfText}</span>
                <span style="flex: 1;">${ma.Beginn || ''}</span>
                <span style="flex: 1;">${ma.Ende || ''}</span>
                <span style="flex: 1;">${ma.Grund || ''}</span>
            </div>
        `;
    }).join('');

    // Event Listener - NUR click, KEIN dblclick!
    // dblclick wird in HTML via List_MA_DblClick behandelt (ruft addMAToPlanung auf)
    elements.maList.querySelectorAll('.listbox-row[data-id]').forEach(row => {
        const id = parseInt(row.dataset.id);

        row.addEventListener('click', () => {
            if (state.selectedMAs.has(id)) {
                state.selectedMAs.delete(id);
                row.classList.remove('selected');
            } else {
                state.selectedMAs.add(id);
                row.classList.add('selected');
            }
        });

        // ENTFERNT: dblclick-Handler verursacht Konflikt mit HTML List_MA_DblClick
        // Die HTML-Version ist die korrekte - NICHT WIEDER AKTIVIEREN!
        // row.addEventListener('dblclick', () => {
        //     zuordneEinzelnenMA(id);
        // });
    });
}

// ============================================
// PHASE 2-8: Komplette Anfrage-Implementierung
// ============================================

// Modal-Steuerung (Phase 2)
const anfrageModal = {
    overlay: null,
    title: null,
    logBody: null,
    progressFill: null,
    progressPercent: null,
    progressCount: null,
    summary: null,
    closeBtn: null,
    closeX: null,
    logCounter: 0,
    stats: { ok: 0, fehler: 0, skip: 0 },

    init() {
        this.overlay = document.getElementById('anfrageModalOverlay');
        this.title = document.getElementById('anfrageModalTitle');
        this.logBody = document.getElementById('anfrageLogBody');
        this.progressFill = document.getElementById('anfrageProgressFill');
        this.progressPercent = document.getElementById('anfrageProgressPercent');
        this.progressCount = document.getElementById('anfrageProgressCount');
        this.summary = document.getElementById('anfrageSummary');
        this.closeBtn = document.getElementById('anfrageModalCloseBtn');
        this.closeX = document.getElementById('anfrageModalCloseX');

        // Close-Handler
        this.closeBtn?.addEventListener('click', () => this.close());
        this.closeX?.addEventListener('click', () => this.close());
    },

    show(title = 'Mitarbeiter werden angefragt...') {
        if (!this.overlay) this.init();
        this.logCounter = 0;
        this.stats = { ok: 0, fehler: 0, skip: 0 };
        this.title.textContent = title;
        this.logBody.innerHTML = '';
        this.progressFill.style.width = '0%';
        this.progressPercent.textContent = '0%';
        this.progressCount.textContent = '0 / 0';
        this.summary.textContent = '';
        this.closeBtn.disabled = true;
        this.closeX.disabled = true;
        this.overlay.classList.add('show');
    },

    updateProgress(current, total) {
        const percent = total > 0 ? Math.round((current / total) * 100) : 0;
        this.progressFill.style.width = percent + '%';
        this.progressPercent.textContent = percent + '%';
        this.progressCount.textContent = `${current} / ${total}`;
    },

    addLogEntry(name, status, result) {
        this.logCounter++;
        const row = document.createElement('tr');
        
        let statusClass = '';
        if (status === 'OK' || status === 'Gesendet') statusClass = 'status-ok';
        else if (status === 'Fehler') statusClass = 'status-fehler';
        else if (status === 'Übersprungen') statusClass = 'status-skip';

        row.innerHTML = `
            <td>${this.logCounter}</td>
            <td>${escapeHtml(name)}</td>
            <td class="${statusClass}">${escapeHtml(status)}</td>
            <td>${escapeHtml(result)}</td>
        `;
        this.logBody.appendChild(row);
        
        // Auto-Scroll zum Ende
        const container = this.logBody.closest('div');
        if (container) container.scrollTop = container.scrollHeight;

        // Stats aktualisieren
        if (status === 'OK' || status === 'Gesendet') this.stats.ok++;
        else if (status === 'Fehler') this.stats.fehler++;
        else this.stats.skip++;
    },

    complete(navigateToAuftrag = true) {
        this.title.textContent = 'Anfragen abgeschlossen';
        this.summary.textContent = `Ergebnis: ${this.stats.ok} gesendet, ${this.stats.skip} übersprungen, ${this.stats.fehler} Fehler`;
        this.closeBtn.disabled = false;
        this.closeX.disabled = false;
        
        // Nach Schließen zum Auftragstamm navigieren
        this._navigateAfterClose = navigateToAuftrag;
    },

    close() {
        this.overlay.classList.remove('show');
        
        if (this._navigateAfterClose && state.selectedAuftrag) {
            setTimeout(() => {
                navigateToForm('frm_va_Auftragstamm', state.selectedAuftrag);
            }, 100);
        }
    }
};

// HTML-Escape Helper
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Navigation Helper
function navigateToForm(formName, recordId) {
    if (window.parent && window.parent !== window) {
        window.parent.postMessage({
            type: 'NAVIGATE',
            formName: formName,
            id: recordId
        }, '*');
    } else {
        let url = formName + '.html';
        if (recordId) url += '?id=' + recordId;
        window.location.href = url;
    }
}

// Phase 3: Daten laden
async function loadAnfrageTexte(maId, vaId, vaDatumId, vaStartId) {
    try {
        // MA-Daten
        const maResponse = await fetch(`http://localhost:5000/api/mitarbeiter/${maId}`);
        const maResult = await maResponse.json();
        // API gibt { data: { mitarbeiter: {...}, nicht_verfuegbar: [...] } } zurück
        const ma = maResult.success ? (maResult.data?.mitarbeiter || maResult.data) : null;
        
        // DEBUG: Zeige alle MA-Felder in der Konsole
        console.log('[loadAnfrageTexte] MA-Daten für ID', maId, ':', ma);
        if (ma) {
            console.log('[loadAnfrageTexte] Verfügbare Felder:', Object.keys(ma));
            // Suche nach E-Mail-Feldern
            const emailFields = Object.keys(ma).filter(k => k.toLowerCase().includes('mail'));
            console.log('[loadAnfrageTexte] E-Mail-relevante Felder:', emailFields);
        }

        // VA-Daten
        const vaResponse = await fetch(`http://localhost:5000/api/auftraege/${vaId}`);
        const vaResult = await vaResponse.json();
        const va = vaResult.success ? (vaResult.data.auftrag || vaResult.data) : null;

        // Planungsdaten (Datum + Schicht)
        let planData = { VADatum: '', MVA_Start: '', MVA_Ende: '' };
        try {
            const planResponse = await fetch(`http://localhost:5000/api/auftraege/${vaId}/schichten?vadatum_id=${vaDatumId}`);
            const planResult = await planResponse.json();
            if (planResult.success && planResult.data && planResult.data.length > 0) {
                const schicht = vaStartId 
                    ? planResult.data.find(s => s.VAStart_ID == vaStartId) || planResult.data[0]
                    : planResult.data[0];
                planData.MVA_Start = schicht.VA_Start || '';
                planData.MVA_Ende = schicht.VA_Ende || '';
            }
            // Datum
            const datumResponse = await fetch(`http://localhost:5000/api/einsatztage?va_id=${vaId}`);
            const datumResult = await datumResponse.json();
            if (datumResult.success && datumResult.data) {
                const tag = datumResult.data.find(t => (t.ID || t.VADatum_ID) == vaDatumId);
                if (tag) planData.VADatum = tag.VADatum;
            }
        } catch (e) {
            console.warn('[loadAnfrageTexte] Planungsdaten nicht geladen:', e);
        }

        return {
            // MA
            MA_ID: maId,
            Vorname: ma?.Vorname || '',
            Nachname: ma?.Nachname || '',
            // E-Mail: Feldname in Access ist "Email"
            Email: ma?.Email || ma?.eMail || ma?.email || '',
            // VA
            Auftrag: va?.Auftrag || '',
            Objekt: va?.Objekt || va?.ObjektName || '',
            Ort: va?.Ort || va?.ob_Ort || '',
            Dienstkleidung: va?.Dienstkleidung || va?.va_Dienstkleidung || 'Normale Dienstkleidung',
            Treffpunkt: va?.Treffpunkt || va?.va_Treffpunkt || '',
            Treffp_Zeit: va?.Treffp_Zeit || va?.va_Treffp_Zeit || '',
            // Planung
            VADatum: planData.VADatum,
            MVA_Start: planData.MVA_Start,
            MVA_Ende: planData.MVA_Ende
        };
    } catch (error) {
        console.error('[loadAnfrageTexte] Fehler:', error);
        return null;
    }
}

// Phase 4: MD5-Hash generieren (Web Crypto API)
async function createMD5Hash(text) {
    // Web Crypto API unterstützt kein MD5, daher SHA-256 als Fallback
    // In Produktion sollte crypto-js oder serverseitig MD5 genutzt werden
    const encoder = new TextEncoder();
    const data = encoder.encode(text);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    // Nur erste 32 Zeichen für MD5-ähnliche Länge
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').substring(0, 32);
}

// Phase 4: URLs generieren
function createAnfrageUrls(md5, maId, vaId, vaDatumId, vaStartId, dienstkleidung) {
    const baseUrl = 'http://noreply.consec-security.selfhost.eu/mail/index.php';
    const dress = (dienstkleidung || '').replace(/\s+/g, '_');
    
    const params = new URLSearchParams({
        md5hash: md5,
        MA_ID: maId,
        VA_ID: vaId,
        VADatum_ID: vaDatumId,
        VAStart_ID: vaStartId || 0,
        dress: dress
    });

    return {
        urlJa: `${baseUrl}?${params.toString()}&ZUSAGE=1`,
        urlNein: `${baseUrl}?${params.toString()}&ZUSAGE=0`
    };
}

// Phase 5: E-Mail-Body erstellen
function createEmailBody(templateData) {
    // Template laden (inline für Browser-Kompatibilität)
    let html = getEmailTemplate();
    
    // Wochentag berechnen
    let wochentag = '';
    if (templateData.VADatum) {
        const datum = new Date(templateData.VADatum);
        const tage = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
        wochentag = tage[datum.getDay()];
    }

    // Datum formatieren
    let datumStr = '';
    if (templateData.VADatum) {
        datumStr = new Date(templateData.VADatum).toLocaleDateString('de-DE');
    }

    // Platzhalter ersetzen
    const replacements = {
        '[A_URL_JA]': templateData.urlJa || '#',
        '[A_URL_NEIN]': templateData.urlNein || '#',
        '[A_Auftr_Datum]': datumStr,
        '[A_Auftrag]': encodeHtmlEntities(templateData.Auftrag || ''),
        '[A_Ort]': encodeHtmlEntities(templateData.Ort || ''),
        '[A_Objekt]': encodeHtmlEntities(templateData.Objekt || ''),
        '[A_Start_Zeit]': templateData.MVA_Start || '',
        '[A_End_Zeit]': templateData.MVA_Ende || '',
        '[A_Treffpunkt]': encodeHtmlEntities(templateData.Treffpunkt || ''),
        '[A_Treffp_Zeit]': templateData.Treffp_Zeit || '',
        '[A_Dienstkleidung]': encodeHtmlEntities(templateData.Dienstkleidung || ''),
        '[A_Wochentag]': wochentag,
        '[A_Sender]': 'CONSEC Auftragsplanung',
        '[A_MA_Vorname]': encodeHtmlEntities(templateData.Vorname || '')
    };

    for (const [placeholder, value] of Object.entries(replacements)) {
        html = html.split(placeholder).join(value);
    }

    return html;
}

// Umlaute als HTML-Entities kodieren
function encodeHtmlEntities(str) {
    if (!str) return '';
    return str
        .replace(/ä/g, '&#228;')
        .replace(/ö/g, '&#246;')
        .replace(/ü/g, '&#252;')
        .replace(/Ä/g, '&#196;')
        .replace(/Ö/g, '&#214;')
        .replace(/Ü/g, '&#220;')
        .replace(/ß/g, '&#223;');
}

// E-Mail Template (inline)
function getEmailTemplate() {
    return `<!DOCTYPE html>
<html><head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f4f4f4;">
<table style="width:100%;">
<tr><td align="center" style="padding:20px;">
<table style="width:600px;max-width:100%;background:#fff;box-shadow:0 2px 8px rgba(0,0,0,0.1);">
<tr><td style="background:linear-gradient(135deg,#000080,#1a5276);padding:20px;text-align:center;">
<h1 style="color:#fff;margin:0;font-size:24px;">CONSEC Security</h1>
<p style="color:#b0c4de;margin:5px 0 0;font-size:14px;">Einsatzanfrage</p>
</td></tr>
<tr><td style="padding:30px;">
<p style="margin:0;font-size:16px;">Hallo <strong>[A_MA_Vorname]</strong>,</p>
<p style="margin:15px 0;font-size:14px;color:#555;line-height:1.5;">wir haben einen neuen Einsatz für Dich:</p>
</td></tr>
<tr><td style="padding:0 30px 20px;">
<table style="width:100%;background:#f8f9fa;border:1px solid #dee2e6;border-radius:8px;">
<tr><td style="padding:20px;">
<h2 style="margin:0 0 15px;font-size:18px;color:#000080;border-bottom:2px solid #000080;padding-bottom:10px;">📋 Einsatzdetails</h2>
<table style="width:100%;">
<tr><td style="padding:8px 0;width:130px;color:#666;font-size:13px;"><strong>Auftrag:</strong></td><td style="padding:8px 0;color:#333;font-size:13px;">[A_Auftrag]</td></tr>
<tr><td style="padding:8px 0;color:#666;font-size:13px;"><strong>Objekt:</strong></td><td style="padding:8px 0;color:#333;font-size:13px;">[A_Objekt]</td></tr>
<tr><td style="padding:8px 0;color:#666;font-size:13px;"><strong>Ort:</strong></td><td style="padding:8px 0;color:#333;font-size:13px;">[A_Ort]</td></tr>
<tr style="background:#e8f4f8;"><td style="padding:8px 10px;color:#666;font-size:13px;"><strong>📅 Datum:</strong></td><td style="padding:8px 0;color:#000080;font-size:14px;font-weight:bold;">[A_Wochentag], [A_Auftr_Datum]</td></tr>
<tr style="background:#e8f4f8;"><td style="padding:8px 10px;color:#666;font-size:13px;"><strong>⏰ Zeit:</strong></td><td style="padding:8px 0;color:#000080;font-size:14px;font-weight:bold;">[A_Start_Zeit] - [A_End_Zeit] Uhr</td></tr>
<tr><td style="padding:8px 0;color:#666;font-size:13px;"><strong>📍 Treffpunkt:</strong></td><td style="padding:8px 0;color:#333;font-size:13px;">[A_Treffpunkt] ([A_Treffp_Zeit] Uhr)</td></tr>
<tr><td style="padding:8px 0;color:#666;font-size:13px;"><strong>👔 Kleidung:</strong></td><td style="padding:8px 0;color:#333;font-size:13px;">[A_Dienstkleidung]</td></tr>
</table>
</td></tr></table>
</td></tr>
<tr><td style="padding:0 30px 30px;">
<p style="margin:0 0 15px;font-size:14px;color:#555;text-align:center;">Bitte antworte mit einem Klick:</p>
<table style="width:100%;">
<tr>
<td style="padding:5px;text-align:center;width:50%;">
<a href="[A_URL_JA]" style="display:inline-block;padding:15px 40px;background:linear-gradient(135deg,#28a745,#1e7e34);color:#fff;text-decoration:none;font-size:16px;font-weight:bold;border-radius:5px;">✓ JA</a>
</td>
<td style="padding:5px;text-align:center;width:50%;">
<a href="[A_URL_NEIN]" style="display:inline-block;padding:15px 40px;background:linear-gradient(135deg,#dc3545,#bd2130);color:#fff;text-decoration:none;font-size:16px;font-weight:bold;border-radius:5px;">✗ NEIN</a>
</td>
</tr></table>
</td></tr>
<tr><td style="background:#f8f9fa;padding:20px;border-top:1px solid #dee2e6;text-align:center;">
<p style="margin:0;font-size:12px;color:#666;">Mit freundlichen Grüßen<br><strong>[A_Sender]</strong></p>
</td></tr>
</table>
</td></tr></table>
</body></html>`;
}

// ============================================
// VBA BRIDGE: Access VBA-Funktion direkt aufrufen
// ============================================

/**
 * Ruft die Access VBA-Funktion Anfragen() direkt auf!
 * Dies ist die eleganteste Lösung - nutzt den bestehenden, getesteten VBA-Code.
 * 
 * Endpoint: http://localhost:5002/api/vba/anfragen (VBA Bridge Server)
 * 
 * Die VBA-Funktion macht alles:
 * - Texte laden
 * - MD5-Hash erzeugen  
 * - E-Mail via CDO/SMTP senden
 * - Status auf "Benachrichtigt" setzen
 * - PHP-Datei für automatische Antwort erstellen
 */
async function sendAnfrageViaAccessVBA(maId, vaId, vaDatumId, vaStartId) {
    console.log(`[VBA] Anfragen aufrufen: MA=${maId}, VA=${vaId}, Datum=${vaDatumId}, Start=${vaStartId}`);

    try {
        // Einzelnen MA-Aufruf über generischen /api/vba/execute Endpoint
        // (Der /api/vba/anfragen Endpoint ist für Batch-Verarbeitung gedacht)
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'Anfragen',
                args: [
                    parseInt(maId),
                    parseInt(vaId),
                    parseInt(vaDatumId),
                    parseInt(vaStartId || 0)
                ]
            })
        });
        
        if (response.ok) {
            const result = await response.json();
            console.log('[VBA] Ergebnis:', result);
            
            // Access gibt Strings zurück wie ">OK", ">HAT KEINE EMAIL", ">BEREITS ZUGESAGT!", etc.
            const vbaResult = result.result || '';
            
            if (vbaResult.includes('>OK')) {
                return { success: true, method: 'vba', result: vbaResult };
            } else if (vbaResult.includes('>HAT KEINE EMAIL')) {
                return { success: false, method: 'vba', error: 'Keine E-Mail-Adresse', result: vbaResult };
            } else if (vbaResult.includes('>BEREITS ZUGESAGT')) {
                return { success: false, method: 'vba', error: 'Bereits zugesagt', skip: true, result: vbaResult };
            } else if (vbaResult.includes('>BEREITS ABGESAGT')) {
                return { success: false, method: 'vba', error: 'Bereits abgesagt', skip: true, result: vbaResult };
            } else if (vbaResult.includes('>ERNEUT ANGEFRAGT')) {
                return { success: true, method: 'vba', result: vbaResult, requery: true };
            } else {
                return { success: false, method: 'vba', error: vbaResult || 'Unbekannter Fehler', result: vbaResult };
            }
        } else {
            console.warn('[VBA] HTTP Fehler:', response.status);
            return { success: false, method: 'vba', error: `HTTP ${response.status}` };
        }
    } catch (e) {
        console.log('[VBA] VBA Bridge nicht verfügbar:', e.message);
        return { success: false, method: 'none', error: 'VBA Bridge nicht erreichbar: ' + e.message };
    }
}

/**
 * Prüft ob der VBA Bridge Server läuft
 * Mit Retry-Logik und kompatiblem Timeout (für WebBrowser-Control)
 */
async function checkVBABridge() {
    const MAX_RETRIES = 3;
    const TIMEOUT_MS = 3000;
    
    for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
        try {
            console.log(`[VBA Bridge] Prüfe Verfügbarkeit (Versuch ${attempt}/${MAX_RETRIES})...`);
            
            // Timeout mit Promise.race (kompatibel mit älteren Browsern)
            const timeoutPromise = new Promise((_, reject) => 
                setTimeout(() => reject(new Error('Timeout')), TIMEOUT_MS)
            );
            
            const fetchPromise = fetch('http://localhost:5002/api/vba/status', { 
                method: 'GET',
                mode: 'cors',
                cache: 'no-cache'
            });
            
            const response = await Promise.race([fetchPromise, timeoutPromise]);
            
            if (response.ok) {
                const result = await response.json();
                // API gibt: access_connected, status (nicht success/access_running)
                if (result.access_connected && result.status === 'running') {
                    console.log('[VBA Bridge] ✅ Verfügbar und Access läuft');
                    return true;
                }
            }
        } catch (e) {
            console.log(`[VBA Bridge] Versuch ${attempt} fehlgeschlagen:`, e.message);
            
            // Bei letztem Versuch nicht mehr warten
            if (attempt < MAX_RETRIES) {
                await new Promise(resolve => setTimeout(resolve, 1000)); // 1s warten
            }
        }
    }
    
    console.log('[VBA Bridge] ❌ Nicht verfügbar nach', MAX_RETRIES, 'Versuchen');
    return false;
}

// ENTFERNT: sendAnfrageEmail (JavaScript Fallback) - VBA Bridge ist Pflicht

// Phase 7: Status abrufen (für Anzeigezwecke)
async function getPlanungStatus(maId, vaId, vaDatumId, vaStartId) {
    try {
        const response = await fetch(
            `http://localhost:5000/api/planungen?ma_id=${maId}&va_id=${vaId}&vadatum_id=${vaDatumId}`
        );
        if (response.ok) {
            const result = await response.json();
            if (result.success && result.data && result.data.length > 0) {
                return result.data[0].Status_ID || result.data[0].status_id || 1;
            }
        }
        return 1; // Standard: Geplant
    } catch (e) {
        console.warn('[getPlanungStatus] Fehler:', e);
        return 1;
    }
}

// Phase 7: Status setzen
async function setzeAngefragt(maId, vaId, vaDatumId, vaStartId) {
    try {
        const response = await fetch('http://localhost:5000/api/planungen/status', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                ma_id: maId,
                va_id: vaId,
                vadatum_id: vaDatumId,
                vastart_id: vaStartId,
                status_id: 2, // Benachrichtigt
                anfragezeitpunkt: new Date().toISOString()
            })
        });
        return response.ok;
    } catch (e) {
        console.warn('[setzeAngefragt] Fehler:', e);
        return false;
    }
}

// Phase 8: Hauptfunktion - MIT VBA BRIDGE INTEGRATION
async function versendeAnfragen(alle) {
    console.log('[Logic] versendeAnfragen - state.selectedAuftrag:', state.selectedAuftrag, 'state.selectedDatum:', state.selectedDatum);
    
    if (!state.selectedAuftrag || !state.selectedDatum) {
        alert('Bitte Auftrag und Datum auswählen');
        return;
    }

    // MA-Liste aus lstMA_Plan holen (HTML-DOM)
    const lstPlanBody = document.getElementById('lstMA_Plan_Body');
    let maRows;
    
    if (alle) {
        maRows = lstPlanBody?.querySelectorAll('.listbox-row');
    } else {
        maRows = lstPlanBody?.querySelectorAll('.listbox-row.selected');
    }

    if (!maRows || maRows.length === 0) {
        alert('Keine Mitarbeiter zum Anfragen vorhanden');
        return;
    }

    const maList = Array.from(maRows).map(row => ({
        id: parseInt(row.dataset.maid || row.dataset.id),
        name: row.textContent.trim().split('\n')[0] || 'Unbekannt'
    })).filter(ma => ma.id);

    if (maList.length === 0) {
        alert('Keine gültigen Mitarbeiter gefunden');
        return;
    }

    // Custom Confirm Modal statt Browser-confirm()
    showCustomConfirm(`${maList.length} Mitarbeiter anfragen?`, async () => {
        // === Ab hier: Bestätigt ===
        const vaStartId = state.selectedSchicht !== null
            ? (state.schichten[state.selectedSchicht]?.ID || state.schichten[state.selectedSchicht]?.VAStart_ID)
            : null;

        // 1. VBA Bridge prüfen - PFLICHT! (kein Fallback)
        const vbaBridgeAvailable = await checkVBABridge();

        console.log('[versendeAnfragen] VBA Bridge verfügbar:', vbaBridgeAvailable);

        // VBA Bridge ist PFLICHT - kein Fallback!
        if (!vbaBridgeAvailable) {
            alert('VBA Bridge Server ist nicht erreichbar!\n\nE-Mail-Anfragen können nur über VBA versendet werden.\n\nBitte starten Sie: start_vba_bridge.bat');
            return;
        }

        // 2. Modal öffnen
        const methodHint = ' (via Access VBA)';
        anfrageModal.show(`${maList.length} Mitarbeiter werden angefragt...${methodHint}`);
        anfrageModal.updateProgress(0, maList.length);

        // 3. Schleife über alle MA
        for (let i = 0; i < maList.length; i++) {
            const ma = maList[i];
            
            try {
                // ========================================
                // VBA BRIDGE (PFLICHT!)
                // Nutzt getesteten Access VBA-Code für:
                // - E-Mail-Versand via CDO/SMTP
                // - Status auf "Benachrichtigt" setzen
                // - PHP-Datei für automatische Antwort
                // - MD5-Hash Generierung
                // ========================================
                const vbaResult = await sendAnfrageViaAccessVBA(
                    ma.id,
                    state.selectedAuftrag,
                    state.selectedDatum,
                    vaStartId
                );

                if (vbaResult.success) {
                    // VBA hat alles erledigt inkl. Status-Update!
                    const resultText = vbaResult.requery ? 'Erneut angefragt' : 'Gesendet via Access';
                    anfrageModal.addLogEntry(ma.name, 'OK', resultText);
                } else if (vbaResult.skip) {
                    // Bereits zugesagt/abgesagt
                    anfrageModal.addLogEntry(ma.name, 'Übersprungen', vbaResult.error);
                } else if (vbaResult.error === 'Keine E-Mail-Adresse') {
                    anfrageModal.addLogEntry(ma.name, 'Übersprungen', 'Keine E-Mail-Adresse');
                } else {
                    // Anderer Fehler
                    anfrageModal.addLogEntry(ma.name, 'Fehler', vbaResult.error || 'VBA Fehler');
                }

                anfrageModal.updateProgress(i + 1, maList.length);
                await new Promise(resolve => setTimeout(resolve, 50));

            } catch (error) {
                console.error(`[versendeAnfragen] Fehler bei MA ${ma.id}:`, error);
                anfrageModal.addLogEntry(ma.name, 'Fehler', error.message);
                anfrageModal.updateProgress(i + 1, maList.length);
            }
        }

        // 4. Abschluss
        anfrageModal.complete(true);
        setStatus(`Anfragen abgeschlossen (${anfrageModal.stats.ok} gesendet via VBA Bridge)`);
    });
}

// ============================================
// Selection-Management (fuer HTML-Integration)
// ============================================
function selectMA(id) {
    const numId = parseInt(id);
    if (!isNaN(numId)) {
        state.selectedMAs.add(numId);
        console.log('[Logic] MA selected:', numId, 'Total:', state.selectedMAs.size);
    }
}

function deselectMA(id) {
    const numId = parseInt(id);
    if (!isNaN(numId)) {
        state.selectedMAs.delete(numId);
        console.log('[Logic] MA deselected:', numId, 'Total:', state.selectedMAs.size);
    }
}

function toggleSelectMA(id) {
    const numId = parseInt(id);
    if (isNaN(numId)) return false;

    if (state.selectedMAs.has(numId)) {
        state.selectedMAs.delete(numId);
        console.log('[Logic] MA deselected:', numId, 'Total:', state.selectedMAs.size);
        return false;
    } else {
        state.selectedMAs.add(numId);
        console.log('[Logic] MA selected:', numId, 'Total:', state.selectedMAs.size);
        return true;
    }
}

function clearSelectedMAs() {
    state.selectedMAs.clear();
    console.log('[Logic] All MAs deselected');
}

// ============================================
// Export
// ============================================
window.SchnellauswahlForm = {
    reload: loadMitarbeiter,
    getSelected: () => Array.from(state.selectedMAs),
    // Selection-Management (fuer HTML-Integration)
    selectMA: selectMA,
    deselectMA: deselectMA,
    toggleSelectMA: toggleSelectMA,
    clearSelectedMAs: clearSelectedMAs,
    // Access-kompatible Button-Funktionen
    cmdListMA_Standard: cmdListMA_Standard,
    cmdListMA_Entfernung: cmdListMA_Entfernung,
    // Auto-Load Funktionen
    loadAuftragById: loadAuftragById,
    loadEinsatztageForVA: loadEinsatztageForVA,
    // State fuer Debugging
    getState: () => state
};

// Init sofort ausfuehren - Module sind bereits deferred und laufen nach DOM-Parsing
// WICHTIG: Nicht DOMContentLoaded warten, da HTML-Inline-Scripts deren Handler frueher registrieren!
init();
