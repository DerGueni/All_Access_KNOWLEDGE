/**
 * frm_Abwesenheiten.logic.js
 * Logik fuer Abwesenheitsverwaltung
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../../api/bridgeClient.js';

// State
const state = {
    records: [],
    currentIndex: -1,
    currentRecord: null,
    isDirty: false,
    maLookup: []
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Abwesenheiten] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Navigation
        btnErster: document.getElementById('btnErster'),
        btnVorheriger: document.getElementById('btnVorheriger'),
        btnNaechster: document.getElementById('btnNächster'),
        btnLetzter: document.getElementById('btnLetzter'),

        // Aktionen
        btnNeu: document.getElementById('btnNeu'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLöschen'),

        // Filter
        cboMitarbeiter: document.getElementById('cboMitarbeiter'),
        datVon: document.getElementById('datVon'),
        datBis: document.getElementById('datBis'),

        // Tabelle
        tbody: document.getElementById('tbody_Liste'),

        // Formular-Felder
        NV_ID: document.getElementById('NV_ID'),
        NV_MA_ID: document.getElementById('NV_MA_ID'),
        NV_VonDat: document.getElementById('NV_VonDat'),
        NV_BisDat: document.getElementById('NV_BisDat'),
        NV_Grund: document.getElementById('NV_Grund'),
        NV_Ganztaegig: document.getElementById('NV_Ganztaegig'),
        NV_Bemerkung: document.getElementById('NV_Bemerkung'),

        // Status
        lblRecordInfo: document.getElementById('lblRecordInfo'),
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    // Standard-Datumszeitraum: aktueller Monat
    const heute = new Date();
    const monatsStart = new Date(heute.getFullYear(), heute.getMonth(), 1);
    const monatsEnde = new Date(heute.getFullYear(), heute.getMonth() + 1, 0);

    elements.datVon.value = formatDate(monatsStart);
    elements.datBis.value = formatDate(monatsEnde);

    // Event Listener
    setupEventListeners();

    // Mitarbeiter laden
    await loadMitarbeiter();

    // Daten laden
    await loadList();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    elements.btnErster.addEventListener('click', () => gotoRecord(0));
    elements.btnVorheriger.addEventListener('click', () => gotoRecord(state.currentIndex - 1));
    elements.btnNaechster.addEventListener('click', () => gotoRecord(state.currentIndex + 1));
    elements.btnLetzter.addEventListener('click', () => gotoRecord(state.records.length - 1));

    // Aktionen
    elements.btnNeu.addEventListener('click', newRecord);
    elements.btnSpeichern.addEventListener('click', saveRecord);
    elements.btnLoeschen.addEventListener('click', deleteRecord);

    // Filter
    elements.cboMitarbeiter.addEventListener('change', loadList);
    elements.datVon.addEventListener('change', loadList);
    elements.datBis.addEventListener('change', loadList);

    // Dirty-Tracking
    const fields = ['NV_MA_ID', 'NV_VonDat', 'NV_BisDat', 'NV_Grund', 'NV_Ganztaegig', 'NV_Bemerkung'];
    fields.forEach(field => {
        const el = elements[field];
        if (el) {
            el.addEventListener('change', () => { state.isDirty = true; });
            if (el.tagName === 'TEXTAREA') {
                el.addEventListener('input', () => { state.isDirty = true; });
            }
        }
    });
}

/**
 * Datum formatieren
 */
function formatDate(date) {
    return date.toISOString().split('T')[0];
}

/**
 * Mitarbeiter laden
 */
async function loadMitarbeiter() {
    try {
        const result = await Bridge.mitarbeiter.list({ aktiv: true });

        state.maLookup = (result.data || []).map(ma => ({
            ID: ma.ID,
            Name: `${ma.Nachname}, ${ma.Vorname}`
        }));

        // Mitarbeiter-Comboboxen fuellen
        const options = '<option value="">Alle Mitarbeiter</option>' +
            state.maLookup.map(ma => `<option value="${ma.ID}">${ma.Name}</option>`).join('');

        elements.cboMitarbeiter.innerHTML = options;
        elements.NV_MA_ID.innerHTML = '<option value="">-- Mitarbeiter waehlen --</option>' +
            state.maLookup.map(ma => `<option value="${ma.ID}">${ma.Name}</option>`).join('');

    } catch (error) {
        console.error('[Abwesenheiten] Fehler beim Laden der Mitarbeiter:', error);
    }
}

/**
 * Liste laden
 */
async function loadList() {
    setStatus('Lade Abwesenheiten...');

    try {
        const params = {
            datum_von: elements.datVon.value,
            datum_bis: elements.datBis.value
        };

        if (elements.cboMitarbeiter.value) {
            params.ma_id = elements.cboMitarbeiter.value;
        }

        const result = await Bridge.abwesenheiten.list(params);
        state.records = result.data || [];

        renderTable();

        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }

        setStatus(`${state.records.length} Abwesenheiten geladen`);
        elements.lblAnzahl.textContent = `${state.records.length} Eintraege`;

    } catch (error) {
        console.error('[Abwesenheiten] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Tabelle rendern
 */
function renderTable() {
    if (state.records.length === 0) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="7" style="text-align:center;padding:40px;color:#666;">
                    Keine Abwesenheiten gefunden
                </td>
            </tr>
        `;
        return;
    }

    elements.tbody.innerHTML = state.records.map((rec, idx) => {
        const vonDat = rec.vonDat ? new Date(rec.vonDat).toLocaleDateString('de-DE') : '-';
        const bisDat = rec.bisDat ? new Date(rec.bisDat).toLocaleDateString('de-DE') : '-';
        const maName = rec.Nachname ? `${rec.Nachname}, ${rec.Vorname || ''}` : '-';
        const selected = idx === state.currentIndex ? 'class="selected"' : '';

        return `
            <tr data-index="${idx}" ${selected}>
                <td>${rec.NV_ID || rec.ID || '-'}</td>
                <td>${maName}</td>
                <td>${vonDat}</td>
                <td>${bisDat}</td>
                <td>${rec.Grund || '-'}</td>
                <td>${rec.Ganztaegig ? 'Ja' : 'Nein'}</td>
                <td>${rec.Bemerkung || ''}</td>
            </tr>
        `;
    }).join('');

    // Click Handler
    elements.tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            const idx = parseInt(row.dataset.index);
            gotoRecord(idx);
        });
    });
}

/**
 * Zu Record navigieren
 */
function gotoRecord(index) {
    if (state.isDirty && !confirm('Aenderungen verwerfen?')) return;

    if (index < 0) index = 0;
    if (index >= state.records.length) index = state.records.length - 1;
    if (index < 0) return;

    state.currentIndex = index;
    state.currentRecord = state.records[index];
    state.isDirty = false;

    displayRecord(state.currentRecord);

    // Zeile markieren
    elements.tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    updateRecordInfo();
}

/**
 * Record anzeigen
 */
function displayRecord(rec) {
    elements.NV_ID.value = rec.NV_ID || rec.ID || '';
    elements.NV_MA_ID.value = rec.MA_ID || '';
    elements.NV_VonDat.value = rec.vonDat ? rec.vonDat.split('T')[0] : '';
    elements.NV_BisDat.value = rec.bisDat ? rec.bisDat.split('T')[0] : '';
    elements.NV_Grund.value = rec.Grund || 'Sonstiges';
    elements.NV_Ganztaegig.checked = rec.Ganztaegig !== false;
    elements.NV_Bemerkung.value = rec.Bemerkung || '';
}

/**
 * Formular leeren
 */
function clearForm() {
    state.currentRecord = null;
    state.currentIndex = -1;
    state.isDirty = false;

    elements.NV_ID.value = '';
    elements.NV_MA_ID.value = '';
    elements.NV_VonDat.value = '';
    elements.NV_BisDat.value = '';
    elements.NV_Grund.value = 'Sonstiges';
    elements.NV_Ganztaegig.checked = true;
    elements.NV_Bemerkung.value = '';

    updateRecordInfo();
}

/**
 * Neuer Record
 */
function newRecord() {
    if (state.isDirty && !confirm('Aenderungen verwerfen?')) return;
    clearForm();
    elements.NV_MA_ID.focus();
    setStatus('Neue Abwesenheit');
}

/**
 * Record speichern
 */
async function saveRecord() {
    const ma_id = elements.NV_MA_ID.value;
    const vonDat = elements.NV_VonDat.value;
    const bisDat = elements.NV_BisDat.value;

    if (!ma_id) {
        alert('Bitte Mitarbeiter auswaehlen');
        elements.NV_MA_ID.focus();
        return;
    }

    if (!vonDat || !bisDat) {
        alert('Bitte Zeitraum angeben');
        return;
    }

    const data = {
        MA_ID: parseInt(ma_id),
        vonDat: vonDat,
        bisDat: bisDat,
        Grund: elements.NV_Grund.value,
        Ganztaegig: elements.NV_Ganztaegig.checked,
        Bemerkung: elements.NV_Bemerkung.value.trim()
    };

    try {
        setStatus('Speichere...');
        const id = elements.NV_ID.value;

        if (id) {
            await Bridge.abwesenheiten.update(id, data);
        } else {
            await Bridge.abwesenheiten.create(data);
        }

        state.isDirty = false;
        setStatus('Gespeichert');
        await loadList();

    } catch (error) {
        console.error('[Abwesenheiten] Fehler beim Speichern:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Speichern: ' + error.message);
    }
}

/**
 * Record loeschen
 */
async function deleteRecord() {
    const id = elements.NV_ID.value;
    if (!id) {
        alert('Kein Datensatz ausgewaehlt');
        return;
    }

    if (!confirm('Abwesenheit wirklich loeschen?')) return;

    try {
        setStatus('Loesche...');
        await Bridge.abwesenheiten.delete(id);
        setStatus('Geloescht');
        await loadList();

    } catch (error) {
        console.error('[Abwesenheiten] Fehler beim Loeschen:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Loeschen: ' + error.message);
    }
}

/**
 * Record-Info aktualisieren
 */
function updateRecordInfo() {
    if (elements.lblRecordInfo) {
        if (state.currentIndex >= 0) {
            elements.lblRecordInfo.textContent = `Datensatz: ${state.currentIndex + 1} / ${state.records.length}`;
        } else {
            elements.lblRecordInfo.textContent = 'Datensatz: - / -';
        }
    }
}

/**
 * Status setzen
 */
function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.Abwesenheiten = {
    loadList,
    gotoRecord,
    newRecord,
    saveRecord,
    deleteRecord
};
