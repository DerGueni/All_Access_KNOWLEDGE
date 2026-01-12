/**
 * frm_OB_Objekt.logic.js
 * Logik für Objekt-Stammdaten Formular
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../api/bridgeClient.js';

const state = {
    records: [],
    currentIndex: -1,
    currentRecord: null,
    isDirty: false,
    nurAktive: true
};

let elements = {};

async function init() {
    console.log('[frm_OB_Objekt] Initialisierung...');

    elements = {
        // Navigation - Angepasst an tatsächliche HTML-IDs
        btnErster: document.getElementById('btnErster'),
        btnVorheriger: document.getElementById('btnZurueck'),
        btnNaechster: document.getElementById('btnVor'),
        btnLetzter: document.getElementById('btnLetzter'),
        btnNeu: document.getElementById('btnNeu'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLoeschen'),
        txtSuche: document.getElementById('txtSuche'),
        btnSuchen: document.getElementById('btnSuchen'),
        chkNurAktive: document.getElementById('chkNurAktive'),
        lblNavigation: document.getElementById('lblNavigation'),

        // Info
        lblRecordInfo: document.getElementById('lblRecordInfo'),
        lblStatus: document.getElementById('lblStatus'),

        // Felder (korrekte HTML-IDs)
        Objekt_ID: document.getElementById('ID'),
        Objekt_Name: document.getElementById('Objekt'),
        Objekt_Strasse: document.getElementById('Strasse'),
        Objekt_PLZ: document.getElementById('PLZ'),
        Objekt_Ort: document.getElementById('Ort'),
        Objekt_Status: null, // Fehlt im HTML
        Objekt_Kunde: document.getElementById('cboVeranstalter'),
        Objekt_Ansprechpartner: document.getElementById('Ansprechpartner'),
        Objekt_Telefon: document.getElementById('Text435'),
        Objekt_Email: null, // Fehlt im HTML
        Objekt_Bemerkungen: document.getElementById('Bemerkung'),

        // Subform
        iframePositionen: document.getElementById('iframe_Positionen'),

        // Liste
        tbodyListe: document.getElementById('tbody_Liste')
    };

    setupEventListeners();
    await loadList();
    setStatus('Bereit');
}

function setupEventListeners() {
    if (elements.btnErster) elements.btnErster.addEventListener('click', () => gotoRecord(0));
    if (elements.btnVorheriger) elements.btnVorheriger.addEventListener('click', () => gotoRecord(state.currentIndex - 1));
    if (elements.btnNaechster) elements.btnNaechster.addEventListener('click', () => gotoRecord(state.currentIndex + 1));
    if (elements.btnLetzter) elements.btnLetzter.addEventListener('click', () => gotoRecord(state.records.length - 1));

    if (elements.btnNeu) elements.btnNeu.addEventListener('click', newRecord);
    if (elements.btnSpeichern) elements.btnSpeichern.addEventListener('click', saveRecord);
    if (elements.btnLoeschen) elements.btnLoeschen.addEventListener('click', deleteRecord);

    if (elements.btnSuchen) elements.btnSuchen.addEventListener('click', searchRecords);
    if (elements.txtSuche) elements.txtSuche.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') searchRecords();
    });

    if (elements.chkNurAktive) elements.chkNurAktive.addEventListener('change', () => {
        state.nurAktive = elements.chkNurAktive.checked;
        loadList();
    });

    // Dirty-Tracking
    const fields = ['Objekt_Name', 'Objekt_Strasse', 'Objekt_PLZ', 'Objekt_Ort',
                    'Objekt_Status', 'Objekt_Kunde', 'Objekt_Ansprechpartner',
                    'Objekt_Telefon', 'Objekt_Email', 'Objekt_Bemerkungen'];
    fields.forEach(field => {
        const el = elements[field];
        if (el) {
            el.addEventListener('change', () => { state.isDirty = true; });
            el.addEventListener('input', () => { state.isDirty = true; });
        }
    });
}

async function loadList() {
    setStatus('Lade Liste...');
    try {
        const result = await Bridge.objekte.list({
            status: state.nurAktive ? 1 : null
        });
        state.records = result.data || [];
        renderList();
        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }
        setStatus(`${state.records.length} Objekte geladen`);
    } catch (error) {
        console.error('[OB_Objekt] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function renderList() {
    if (!elements.tbodyListe) return;

    if (state.records.length === 0) {
        elements.tbodyListe.innerHTML = `
            <tr><td colspan="3" style="text-align:center;color:#666;padding:20px;">
                Keine Objekte gefunden
            </td></tr>`;
        return;
    }

    elements.tbodyListe.innerHTML = state.records.map((rec, idx) => {
        const selected = idx === state.currentIndex ? 'selected' : '';
        return `
            <tr data-index="${idx}" data-id="${rec.Objekt_ID}" class="${selected}">
                <td>${rec.Objekt_ID}</td>
                <td>${rec.Objekt_Name || ''}</td>
                <td>${rec.Objekt_Ort || ''}</td>
            </tr>`;
    }).join('');

    elements.tbodyListe.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            const idx = parseInt(row.dataset.index);
            gotoRecord(idx);
        });
    });
}

async function gotoRecord(index) {
    if (state.isDirty && !confirm('Änderungen verwerfen?')) return;

    if (index < 0) index = 0;
    if (index >= state.records.length) index = state.records.length - 1;
    if (index < 0) return;

    state.currentIndex = index;
    state.currentRecord = state.records[index];
    state.isDirty = false;

    await loadDetail(state.currentRecord.Objekt_ID);

    elements.tbodyListe.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    updateRecordInfo();
}

async function loadDetail(id) {
    try {
        const result = await Bridge.objekte.get(id);
        const data = result.data || result;
        displayRecord(data);

        // Positionen-Subform aktualisieren
        if (elements.iframePositionen && elements.iframePositionen.contentWindow) {
            elements.iframePositionen.contentWindow.postMessage({
                action: 'setObjektID',
                objektId: id
            }, '*');
        }
    } catch (error) {
        console.error('[OB_Objekt] Fehler beim Laden Detail:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function displayRecord(rec) {
    if (elements.Objekt_ID) elements.Objekt_ID.value = rec.Objekt_ID || '';
    if (elements.Objekt_Name) elements.Objekt_Name.value = rec.Objekt_Name || '';
    if (elements.Objekt_Strasse) elements.Objekt_Strasse.value = rec.Objekt_Strasse || '';
    if (elements.Objekt_PLZ) elements.Objekt_PLZ.value = rec.Objekt_PLZ || '';
    if (elements.Objekt_Ort) elements.Objekt_Ort.value = rec.Objekt_Ort || '';
    if (elements.Objekt_Status) elements.Objekt_Status.value = rec.Objekt_Status || '1';
    if (elements.Objekt_Kunde) elements.Objekt_Kunde.value = rec.Objekt_Kunde_ID || '';
    if (elements.Objekt_Ansprechpartner) elements.Objekt_Ansprechpartner.value = rec.Objekt_Ansprechpartner || '';
    if (elements.Objekt_Telefon) elements.Objekt_Telefon.value = rec.Objekt_Telefon || '';
    if (elements.Objekt_Email) elements.Objekt_Email.value = rec.Objekt_Email || '';
    if (elements.Objekt_Bemerkungen) elements.Objekt_Bemerkungen.value = rec.Objekt_Bemerkungen || '';
}

function clearForm() {
    state.currentRecord = null;
    state.currentIndex = -1;
    state.isDirty = false;

    Object.keys(elements).forEach(key => {
        if (key.startsWith('Objekt_') && elements[key]) {
            if (elements[key].tagName === 'SELECT') {
                elements[key].selectedIndex = 0;
            } else {
                elements[key].value = '';
            }
        }
    });
    updateRecordInfo();
}

function newRecord() {
    if (state.isDirty && !confirm('Änderungen verwerfen?')) return;
    clearForm();
    if (elements.Objekt_Name) elements.Objekt_Name.focus();
    setStatus('Neues Objekt');
}

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

async function saveRecord() {
    // Pflichtfeld-Validierung
    if (!validateRequired()) return;

    const name = elements.Objekt_Name?.value.trim();

    const data = {
        Objekt_Name: name,
        Objekt_Strasse: elements.Objekt_Strasse?.value.trim() || null,
        Objekt_PLZ: elements.Objekt_PLZ?.value.trim() || null,
        Objekt_Ort: elements.Objekt_Ort?.value.trim() || null,
        Objekt_Status: parseInt(elements.Objekt_Status?.value) || 1,
        Objekt_Kunde_ID: elements.Objekt_Kunde?.value || null,
        Objekt_Ansprechpartner: elements.Objekt_Ansprechpartner?.value.trim() || null,
        Objekt_Telefon: elements.Objekt_Telefon?.value.trim() || null,
        Objekt_Email: elements.Objekt_Email?.value.trim() || null,
        Objekt_Bemerkungen: elements.Objekt_Bemerkungen?.value.trim() || null
    };

    try {
        setStatus('Speichere...');
        const id = elements.Objekt_ID?.value;
        if (id) {
            await Bridge.objekte.update(id, data);
        } else {
            await Bridge.objekte.create(data);
        }
        state.isDirty = false;
        setStatus('Gespeichert');
        await loadList();
    } catch (error) {
        console.error('[OB_Objekt] Fehler beim Speichern:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Speichern: ' + error.message);
    }
}

async function deleteRecord() {
    const id = elements.Objekt_ID?.value;
    if (!id) {
        alert('Kein Datensatz ausgewählt');
        return;
    }
    if (!confirm('Objekt wirklich löschen?')) return;

    try {
        setStatus('Lösche...');
        await Bridge.objekte.delete(id);
        setStatus('Gelöscht');
        await loadList();
    } catch (error) {
        console.error('[OB_Objekt] Fehler beim Löschen:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Löschen: ' + error.message);
    }
}

async function searchRecords() {
    const searchTerm = elements.txtSuche?.value.trim();
    if (!searchTerm) {
        await loadList();
        return;
    }

    setStatus('Suche...');
    try {
        const result = await Bridge.objekte.list({
            status: state.nurAktive ? 1 : null,
            search: searchTerm
        });
        state.records = result.data || [];
        renderList();
        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }
        setStatus(`${state.records.length} Treffer`);
    } catch (error) {
        console.error('[OB_Objekt] Fehler bei Suche:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function updateRecordInfo() {
    if (elements.lblRecordInfo) {
        if (state.currentIndex >= 0) {
            elements.lblRecordInfo.textContent = `Datensatz: ${state.currentIndex + 1} / ${state.records.length}`;
        } else {
            elements.lblRecordInfo.textContent = 'Datensatz: - / -';
        }
    }
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

// ============================================
// ACCESS VBA-SYNC EVENTS (AfterUpdate)
// ============================================

/**
 * Access: Objekt_Name_AfterUpdate - Objektname geändert
 */
function Objekt_Name_AfterUpdate(value) {
    console.log('[Access-Sync] Objekt_Name_AfterUpdate:', value);
    if (elements.Objekt_Name) elements.Objekt_Name.value = value || '';
    state.isDirty = true;
    // Objekt in Liste aktualisieren
    if (state.currentIndex >= 0 && state.records[state.currentIndex]) {
        state.records[state.currentIndex].Objekt_Name = value;
        renderList();
    }
}

/**
 * Access: Objekt_Status_AfterUpdate - Status geändert
 * @param {number} statusId - Die Status-ID (1=Aktiv, 0=Inaktiv)
 */
function Objekt_Status_AfterUpdate(statusId) {
    console.log('[Access-Sync] Objekt_Status_AfterUpdate:', statusId);
    if (elements.Objekt_Status) elements.Objekt_Status.value = statusId || '1';
    state.isDirty = true;
}

/**
 * Access: Objekt_Kunde_AfterUpdate - Kunde geändert
 * @param {number} kundeId - Die Kunden-ID
 */
function Objekt_Kunde_AfterUpdate(kundeId) {
    console.log('[Access-Sync] Objekt_Kunde_AfterUpdate:', kundeId);
    if (elements.Objekt_Kunde) elements.Objekt_Kunde.value = kundeId || '';
    state.isDirty = true;
}

/**
 * Access: Objekt_Ort_AfterUpdate - Ort geändert (fuer Geocoding)
 */
function Objekt_Ort_AfterUpdate(value) {
    console.log('[Access-Sync] Objekt_Ort_AfterUpdate:', value);
    if (elements.Objekt_Ort) elements.Objekt_Ort.value = value || '';
    state.isDirty = true;
    // Objekt in Liste aktualisieren
    if (state.currentIndex >= 0 && state.records[state.currentIndex]) {
        state.records[state.currentIndex].Objekt_Ort = value;
        renderList();
    }
}

/**
 * Access: cboObjektSuche_AfterUpdate - Objekt-ID Schnellsuche
 * @param {number} objektId - Die gesuchte Objekt-ID
 */
function cboObjektSuche_AfterUpdate(objektId) {
    console.log('[Access-Sync] cboObjektSuche_AfterUpdate:', objektId);
    if (objektId) {
        const parsedId = parseInt(objektId);
        const index = state.records.findIndex(o => o.Objekt_ID === parsedId);
        if (index >= 0) {
            gotoRecord(index);
        } else {
            // Direkt laden via Bridge
            Bridge.objekte.get(parsedId).then(result => {
                const data = result.data || result;
                if (data) {
                    state.records.push(data);
                    gotoRecord(state.records.length - 1);
                } else {
                    console.warn('[cboObjektSuche] Objekt nicht gefunden:', objektId);
                }
            }).catch(err => {
                console.error('[cboObjektSuche] Fehler:', err);
            });
        }
    }
}

/**
 * Access: btnKoordinatenHolen_Click - Geocoding via API
 */
async function btnKoordinatenHolen_Click() {
    const strasse = elements.Objekt_Strasse?.value || '';
    const plz = elements.Objekt_PLZ?.value || '';
    const ort = elements.Objekt_Ort?.value || '';

    if (!ort && !plz) {
        alert('Bitte Adresse eingeben');
        return;
    }

    const adresse = `${strasse}, ${plz} ${ort}`;
    console.log('[Access-Sync] btnKoordinatenHolen_Click - Geocoding fuer:', adresse);
    setStatus('Ermittle Koordinaten...');

    try {
        const result = await Bridge.execute('geocode', { address: adresse });
        if (result && result.lat && result.lng) {
            setStatus(`Koordinaten: ${result.lat}, ${result.lng}`);
            // Koordinaten speichern
            state.isDirty = true;
        } else {
            setStatus('Keine Koordinaten gefunden');
        }
    } catch (error) {
        console.error('[btnKoordinatenHolen] Fehler:', error);
        setStatus('Geocoding-Fehler');
    }
}

/**
 * Access: btnGoogleMaps_Click - Google Maps öffnen
 */
function btnGoogleMaps_Click() {
    const strasse = elements.Objekt_Strasse?.value || '';
    const plz = elements.Objekt_PLZ?.value || '';
    const ort = elements.Objekt_Ort?.value || '';

    if (!ort) {
        alert('Keine Adresse vorhanden');
        return;
    }

    const adresse = encodeURIComponent(`${strasse}, ${plz} ${ort}`);
    window.open(`https://www.google.com/maps/search/${adresse}`, '_blank');
}

document.addEventListener('DOMContentLoaded', init);

window.ObjektStamm = {
    state,
    loadList,
    gotoRecord,
    newRecord,
    saveRecord,
    renderList,
    setStatus,
    // Access VBA-Sync Events
    Objekt_Name_AfterUpdate,
    Objekt_Status_AfterUpdate,
    Objekt_Kunde_AfterUpdate,
    Objekt_Ort_AfterUpdate,
    cboObjektSuche_AfterUpdate,
    btnKoordinatenHolen_Click,
    btnGoogleMaps_Click
};
