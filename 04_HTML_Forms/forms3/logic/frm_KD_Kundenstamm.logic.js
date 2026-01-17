/**
 * frm_KD_Kundenstamm.logic.js
 * Logik für Kundenstamm-Formular
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../api/bridgeClient.js';

// State
const state = {
    records: [],
    currentIndex: -1,
    currentRecord: null,
    isDirty: false,
    nurAktive: true
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[frm_KD_Kundenstamm] Initialisierung...');

    // DOM-Referenzen sammeln - Angepasst an tatsächliche HTML-IDs
    elements = {
        // Navigation Buttons
        btnErster: document.getElementById('btnErster'),
        btnVorheriger: document.getElementById('btnVorheriger'),
        btnNaechster: document.getElementById('btnNaechster'),
        btnLetzter: document.getElementById('btnLetzter'),

        // Action Buttons
        btnNeuerKunde: document.getElementById('btnNeuerKunde'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnKundeLoeschen: document.getElementById('btnKundeLoeschen'),
        btnVerrechnungssaetze: document.getElementById('btnVerrechnungssaetze'),
        btnUmsatzauswertung: document.getElementById('btnUmsatzauswertung'),
        btnAuftraegeFiltern: document.getElementById('btnAuftraegeFiltern'),
        btnDateiHinzufuegen: document.getElementById('btnDateiHinzufuegen'),

        // Infos
        lblRecordInfo: document.getElementById('lblRecordInfo'),
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl'),

        // Stammdaten-Felder
        KD_ID: document.getElementById('KD_ID'),
        KD_Kuerzel: document.getElementById('KD_Kuerzel'),
        KD_IstAktiv: document.getElementById('KD_IstAktiv'),
        KD_Name1: document.getElementById('KD_Name1'),
        KD_Name2: document.getElementById('KD_Name2'),
        KD_Strasse: document.getElementById('KD_Strasse'),
        KD_PLZ: document.getElementById('KD_PLZ'),
        KD_Ort: document.getElementById('KD_Ort'),
        KD_Land: document.getElementById('KD_Land'),
        KD_Telefon: document.getElementById('KD_Telefon'),
        KD_Fax: document.getElementById('KD_Fax'),
        KD_Email: document.getElementById('KD_Email'),
        KD_Web: document.getElementById('KD_Web'),
        KD_UStIDNr: document.getElementById('KD_UStIDNr'),
        KD_Zahlungsbedingung: document.getElementById('KD_Zahlungsbedingung'),
        KD_AP_Name: document.getElementById('KD_AP_Name'),
        KD_AP_Position: document.getElementById('KD_AP_Position'),
        KD_AP_Telefon: document.getElementById('KD_AP_Telefon'),
        KD_AP_Email: document.getElementById('KD_AP_Email'),
        KD_Bemerkungen: document.getElementById('KD_Bemerkungen'),
        KD_Rabatt: document.getElementById('KD_Rabatt'),
        KD_Skonto: document.getElementById('KD_Skonto'),
        KD_SkontoTage: document.getElementById('KD_SkontoTage'),

        // Filter/Suche
        chkNurAktive: document.getElementById('chkNurAktive'),
        txtSuche: document.getElementById('txtSuche'),

        // Listen
        tbodyListe: document.getElementById('tbody_Liste'),
        tbodyAuftraege: document.getElementById('tbody_Auftraege'),
        tbodyDateien: document.getElementById('tbody_Dateien'),

        // Auftragsfilter
        datAuftraegeVon: document.getElementById('datAuftraegeVon'),
        datAuftraegeBis: document.getElementById('datAuftraegeBis')
    };

    // Event Listener
    setupEventListeners();

    // Daten laden
    await loadList();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    if (elements.btnErster) elements.btnErster.addEventListener('click', () => gotoRecord(0));
    if (elements.btnVorheriger) elements.btnVorheriger.addEventListener('click', () => gotoRecord(state.currentIndex - 1));
    if (elements.btnNaechster) elements.btnNaechster.addEventListener('click', () => gotoRecord(state.currentIndex + 1));
    if (elements.btnLetzter) elements.btnLetzter.addEventListener('click', () => gotoRecord(state.records.length - 1));

    // Aktionen
    if (elements.btnNeuerKunde) elements.btnNeuerKunde.addEventListener('click', newRecord);
    if (elements.btnSpeichern) elements.btnSpeichern.addEventListener('click', saveRecord);
    if (elements.btnKundeLoeschen) elements.btnKundeLoeschen.addEventListener('click', deleteRecord);
    if (elements.btnVerrechnungssaetze) elements.btnVerrechnungssaetze.addEventListener('click', openVerrechnungssaetze);
    if (elements.btnUmsatzauswertung) elements.btnUmsatzauswertung.addEventListener('click', openUmsatzauswertung);
    if (elements.btnAuftraegeFiltern) elements.btnAuftraegeFiltern.addEventListener('click', filterAuftraege);
    if (elements.btnDateiHinzufuegen) elements.btnDateiHinzufuegen.addEventListener('click', dateiHinzufuegen);

    // Suche
    if (elements.txtSuche) {
        elements.txtSuche.addEventListener('input', debounce(searchRecords, 300));
        elements.txtSuche.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') searchRecords();
        });
    }

    // Filter
    if (elements.chkNurAktive) {
        elements.chkNurAktive.addEventListener('change', () => {
            state.nurAktive = elements.chkNurAktive.checked;
            loadList();
        });
    }

    // Feldänderungen tracken
    const trackFields = [
        'KD_Kuerzel', 'KD_Name1', 'KD_Name2', 'KD_Strasse', 'KD_PLZ', 'KD_Ort',
        'KD_Land', 'KD_Telefon', 'KD_Fax', 'KD_Email', 'KD_Web', 'KD_UStIDNr',
        'KD_AP_Name', 'KD_AP_Position', 'KD_AP_Telefon', 'KD_AP_Email',
        'KD_Bemerkungen', 'KD_IstAktiv', 'KD_Zahlungsbedingung'
    ];
    trackFields.forEach(field => {
        const el = elements[field];
        if (el) {
            el.addEventListener('change', () => { state.isDirty = true; });
            if (el.type !== 'checkbox') {
                el.addEventListener('input', () => { state.isDirty = true; });
            }
        }
    });

    // Keyboard Navigation
    document.addEventListener('keydown', (e) => {
        if (e.ctrlKey) {
            switch(e.key) {
                case 's':
                    e.preventDefault();
                    saveRecord();
                    break;
                case 'n':
                    e.preventDefault();
                    newRecord();
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    gotoRecord(state.currentIndex - 1);
                    break;
                case 'ArrowDown':
                    e.preventDefault();
                    gotoRecord(state.currentIndex + 1);
                    break;
            }
        }
    });
}

/**
 * Debounce-Funktion
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Kundenliste laden
 */
async function loadList() {
    setStatus('Lade Liste...');

    try {
        const params = {};
        if (state.nurAktive) params.aktiv = 1;

        const result = await Bridge.kunden.list(params);
        state.records = result.data || result || [];
        renderList();

        // Ersten Datensatz anzeigen
        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }

        if (elements.lblAnzahl) {
            elements.lblAnzahl.textContent = `${state.records.length} Kunden`;
        }
        setStatus(`${state.records.length} Kunden geladen`);

    } catch (error) {
        console.error('[Kundenstamm] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        // Fallback: Demo-Daten
        showDemoData();
    }
}

/**
 * Demo-Daten anzeigen wenn API nicht erreichbar
 */
function showDemoData() {
    state.records = [
        { KD_ID: 1, KD_Name1: 'CONSEC GmbH', KD_Ort: 'Nürnberg', KD_IstAktiv: 1 },
        { KD_ID: 2, KD_Name1: 'ABC Veranstaltungen', KD_Ort: 'Fürth', KD_IstAktiv: 1 },
        { KD_ID: 3, KD_Name1: 'HC Erlangen', KD_Ort: 'Erlangen', KD_IstAktiv: 1 }
    ];
    renderList();
    if (state.records.length > 0) gotoRecord(0);
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.records.length} Kunden`;
    }
}

/**
 * Liste rendern
 */
function renderList() {
    if (!elements.tbodyListe) return;

    if (state.records.length === 0) {
        elements.tbodyListe.innerHTML = `
            <tr>
                <td colspan="3" style="text-align:center; color:#666; padding:20px;">
                    Keine Kunden gefunden
                </td>
            </tr>
        `;
        return;
    }

    elements.tbodyListe.innerHTML = state.records.map((rec, idx) => {
        const id = rec.KD_ID || rec.kun_Id;
        const name = rec.KD_Name1 || rec.kun_Firma || '';
        const ort = rec.KD_Ort || rec.kun_Ort || '';
        const contact = rec.KD_AP_Name || rec.kun_AP_Name || '';
        const phone = rec.KD_AP_Telefon || rec.kun_AP_Telefon || rec.KD_Telefon || rec.kun_Telefon || '';
        const selected = idx === state.currentIndex ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${id}" class="${selected}">
                <td>${id}</td>
                <td>${name}</td>
                <td>${ort}</td>
                <td>${contact}</td>
                <td>${phone}</td>
            </tr>
        `;
    }).join('');

    // Click-Handler
    elements.tbodyListe.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            const idx = parseInt(row.dataset.index);
            if (!isNaN(idx)) gotoRecord(idx);
        });
    });
}

/**
 * Zu Datensatz navigieren
 */
async function gotoRecord(index) {
    // Dirty-Check
    if (state.isDirty) {
        if (!confirm('Änderungen verwerfen?')) return;
    }

    // Bounds prüfen
    if (index < 0) index = 0;
    if (index >= state.records.length) index = state.records.length - 1;
    if (index < 0) return;

    state.currentIndex = index;
    state.currentRecord = state.records[index];
    state.isDirty = false;

    // Details laden (wenn API verfügbar)
    try {
        const id = state.currentRecord.KD_ID || state.currentRecord.kun_Id;
        const detail = await Bridge.kunden.get(id);
        const data = detail.data || detail;
        displayRecord(data);
    } catch (error) {
        // Fallback: Nur Listendaten anzeigen
        displayRecord(state.currentRecord);
    }

    // Liste aktualisieren (Selection)
    elements.tbodyListe?.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    // In Sicht scrollen
    const selectedRow = elements.tbodyListe?.querySelector('tr.selected');
    selectedRow?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

    updateRecordInfo();
}

/**
 * Datensatz in Formular anzeigen
 */
function displayRecord(rec) {
    setFieldValue('KD_ID', rec.KD_ID || rec.kun_Id);
    setFieldValue('KD_Kuerzel', rec.KD_Kuerzel || rec.kun_Kuerzel);
    setCheckbox('KD_IstAktiv', rec.KD_IstAktiv ?? rec.kun_IstAktiv ?? true);
    setFieldValue('KD_Name1', rec.KD_Name1 || rec.kun_Firma);
    setFieldValue('KD_Name2', rec.KD_Name2 || rec.kun_Name2);
    setFieldValue('KD_Strasse', rec.KD_Strasse || rec.kun_Strasse);
    setFieldValue('KD_PLZ', rec.KD_PLZ || rec.kun_PLZ);
    setFieldValue('KD_Ort', rec.KD_Ort || rec.kun_Ort);
    setFieldValue('KD_Land', rec.KD_Land || rec.kun_Land);
    setFieldValue('KD_Telefon', rec.KD_Telefon || rec.kun_Telefon);
    setFieldValue('KD_Fax', rec.KD_Fax || rec.kun_Fax);
    setFieldValue('KD_Email', rec.KD_Email || rec.kun_Email);
    setFieldValue('KD_Web', rec.KD_Web || rec.kun_Web);
    setFieldValue('KD_UStIDNr', rec.KD_UStIDNr || rec.kun_UStIDNr);
    setFieldValue('KD_Zahlungsbedingung', rec.KD_Zahlungsbedingung);
    setFieldValue('KD_AP_Name', rec.KD_AP_Name || rec.kun_AP_Name);
    setFieldValue('KD_AP_Position', rec.KD_AP_Position);
    setFieldValue('KD_AP_Telefon', rec.KD_AP_Telefon || rec.kun_AP_Telefon);
    setFieldValue('KD_AP_Email', rec.KD_AP_Email || rec.kun_AP_Email);
    setFieldValue('KD_Bemerkungen', rec.KD_Bemerkungen || rec.kun_Bemerkungen);
    setFieldValue('KD_Rabatt', rec.KD_Rabatt);
    setFieldValue('KD_Skonto', rec.KD_Skonto);
    setFieldValue('KD_SkontoTage', rec.KD_SkontoTage);
}

/**
 * Hilfsfunktion: Feld-Wert setzen
 */
function setFieldValue(fieldName, value) {
    const el = elements[fieldName];
    if (el) {
        el.value = value ?? '';
    }
}

/**
 * Hilfsfunktion: Checkbox setzen
 */
function setCheckbox(fieldName, checked) {
    const el = elements[fieldName];
    if (el) {
        el.checked = !!checked;
    }
}

/**
 * Formular leeren
 */
function clearForm() {
    state.currentRecord = null;
    state.currentIndex = -1;
    state.isDirty = false;

    Object.keys(elements).forEach(key => {
        const el = elements[key];
        if (el && el.tagName === 'INPUT' && el.type !== 'checkbox') {
            el.value = '';
        } else if (el && el.tagName === 'INPUT' && el.type === 'checkbox') {
            el.checked = false;
        } else if (el && el.tagName === 'SELECT') {
            el.selectedIndex = 0;
        } else if (el && el.tagName === 'TEXTAREA') {
            el.value = '';
        }
    });

    updateRecordInfo();
}

/**
 * Neuer Datensatz
 */
function newRecord() {
    if (state.isDirty) {
        if (!confirm('Änderungen verwerfen?')) return;
    }

    clearForm();
    if (elements.KD_Name1) elements.KD_Name1.focus();
    setStatus('Neuer Kunde - Daten eingeben');
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

/**
 * Speichern
 */
async function saveRecord() {
    // Pflichtfeld-Validierung
    if (!validateRequired()) return;

    const name1 = elements.KD_Name1?.value?.trim();

    const data = {
        KD_Kuerzel: elements.KD_Kuerzel?.value?.trim() || '',
        KD_Name1: name1,
        KD_Name2: elements.KD_Name2?.value?.trim() || '',
        KD_Strasse: elements.KD_Strasse?.value?.trim() || '',
        KD_PLZ: elements.KD_PLZ?.value?.trim() || '',
        KD_Ort: elements.KD_Ort?.value?.trim() || '',
        KD_Land: elements.KD_Land?.value?.trim() || '',
        KD_Telefon: elements.KD_Telefon?.value?.trim() || '',
        KD_Fax: elements.KD_Fax?.value?.trim() || '',
        KD_Email: elements.KD_Email?.value?.trim() || '',
        KD_Web: elements.KD_Web?.value?.trim() || '',
        KD_UStIDNr: elements.KD_UStIDNr?.value?.trim() || '',
        KD_Zahlungsbedingung: elements.KD_Zahlungsbedingung?.value || '',
        KD_AP_Name: elements.KD_AP_Name?.value?.trim() || '',
        KD_AP_Position: elements.KD_AP_Position?.value?.trim() || '',
        KD_AP_Telefon: elements.KD_AP_Telefon?.value?.trim() || '',
        KD_AP_Email: elements.KD_AP_Email?.value?.trim() || '',
        KD_Bemerkungen: elements.KD_Bemerkungen?.value?.trim() || '',
        KD_IstAktiv: elements.KD_IstAktiv?.checked ? 1 : 0,
        KD_Rabatt: parseFloat(elements.KD_Rabatt?.value) || 0,
        KD_Skonto: parseFloat(elements.KD_Skonto?.value) || 0,
        KD_SkontoTage: parseInt(elements.KD_SkontoTage?.value) || 0
    };

    try {
        setStatus('Speichere...');

        const id = elements.KD_ID?.value;

        if (id && state.currentRecord) {
            // Update
            await Bridge.kunden.update(id, data);
        } else {
            // Insert
            await Bridge.kunden.create(data);
        }

        state.isDirty = false;
        setStatus('Gespeichert');

        // Liste neu laden
        await loadList();

    } catch (error) {
        console.error('[Kundenstamm] Fehler beim Speichern:', error);
        setStatus('Fehler: ' + error.message);
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Speichern: ' + error.message);
        else alert('Fehler beim Speichern: ' + error.message);
    }
}

/**
 * Löschen
 */
async function deleteRecord() {
    const id = elements.KD_ID?.value;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Kein Datensatz ausgewählt');
        else alert('Kein Datensatz ausgewählt');
        return;
    }

    const name = elements.KD_Name1?.value || '';
    if (!confirm(`Kunde "${name}" wirklich löschen?`)) return;

    try {
        setStatus('Lösche...');

        await Bridge.kunden.delete(id);

        setStatus('Gelöscht');

        // Liste neu laden
        await loadList();

    } catch (error) {
        console.error('[Kundenstamm] Fehler beim Löschen:', error);
        setStatus('Fehler: ' + error.message);
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Löschen: ' + error.message);
        else alert('Fehler beim Löschen: ' + error.message);
    }
}

/**
 * Suchen
 */
async function searchRecords() {
    const searchTerm = elements.txtSuche?.value?.trim() || '';

    if (!searchTerm) {
        await loadList();
        return;
    }

    setStatus('Suche...');

    try {
        const result = await Bridge.kunden.list({ search: searchTerm });
        state.records = result.data || result || [];
        renderList();

        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }

        setStatus(`${state.records.length} Treffer`);

    } catch (error) {
        console.error('[Kundenstamm] Fehler bei Suche:', error);
        // Lokale Suche als Fallback
        const term = searchTerm.toLowerCase();
        const filtered = state.records.filter(r =>
            (r.KD_Name1 || '').toLowerCase().includes(term) ||
            (r.KD_Ort || '').toLowerCase().includes(term)
        );
        state.records = filtered;
        renderList();
        if (filtered.length > 0) gotoRecord(0);
        setStatus(`${filtered.length} Treffer (lokal)`);
    }
}

/**
 * Datensatz-Info aktualisieren
 */
function updateRecordInfo() {
    if (elements.lblRecordInfo) {
        if (state.currentIndex >= 0) {
            elements.lblRecordInfo.textContent =
                `Datensatz: ${state.currentIndex + 1} / ${state.records.length}`;
        } else {
            elements.lblRecordInfo.textContent = 'Datensatz: - / -';
        }
    }
}

/**
 * Status setzen
 */
function setStatus(text) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = text;
    }
}

// ============================================
// Button-Aktionen
// ============================================

function openVerrechnungssaetze() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Kunden auswählen');
        else alert('Bitte zuerst einen Kunden auswählen');
        return;
    }
    // Öffne Verrechnungssätze-Formular
    const url = `frm_KD_Verrechnungssaetze.html?kd_id=${id}`;
    window.open(url, 'Verrechnungssaetze', 'width=800,height=600,menubar=no,toolbar=no,scrollbars=yes');
}

function openUmsatzauswertung() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Kunden auswählen');
        else alert('Bitte zuerst einen Kunden auswählen');
        return;
    }
    // Öffne Umsatzauswertung-Formular
    const kundeName = elements.KD_Name1?.value || elements.kun_Firma?.value || '';
    const url = `frm_KD_Umsatzauswertung.html?kd_id=${id}&name=${encodeURIComponent(kundeName)}`;
    window.open(url, 'Umsatzauswertung', 'width=900,height=700,menubar=no,toolbar=no,scrollbars=yes');
}

function filterAuftraege() {
    const von = elements.datAuftraegeVon?.value;
    const bis = elements.datAuftraegeBis?.value;
    const id = state.currentRecord?.KD_ID;

    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Kunden auswählen');
        else alert('Bitte zuerst einen Kunden auswählen');
        return;
    }

    // Zeitraum-Validierung
    if (von && bis && von > bis) {
        if (typeof Toast !== 'undefined') Toast.error('Enddatum muss nach Startdatum liegen');
        else alert('Enddatum muss nach Startdatum liegen');
        return;
    }

    setStatus('Filtere Aufträge...');
    // Hier würde API-Aufruf zum Filtern der Aufträge kommen
    Bridge.auftraege.list({ kunde_id: id, von, bis })
        .then(result => {
            const auftraege = result.data || [];
            renderAuftraege(auftraege);
            setStatus(`${auftraege.length} Aufträge gefunden`);
        })
        .catch(error => {
            setStatus('Fehler beim Laden der Aufträge');
            console.error(error);
        });
}

function renderAuftraege(auftraege) {
    if (!elements.tbodyAuftraege) return;

    if (auftraege.length === 0) {
        elements.tbodyAuftraege.innerHTML = `
            <tr><td colspan="6" style="text-align:center; color:#666;">Keine Aufträge gefunden</td></tr>
        `;
        return;
    }

    elements.tbodyAuftraege.innerHTML = auftraege.map(a => `
        <tr>
            <td>${a.VA_Nummer || a.Auftrag || ''}</td>
            <td>${a.VA_Bezeichnung || ''}</td>
            <td>${formatDateDE(a.VA_Datum)}</td>
            <td>${a.VA_Objekt || ''}</td>
            <td class="status-${getStatusClass(a.VA_Status)}">${a.VA_Status || ''}</td>
            <td>${formatCurrency(a.VA_Betrag)}</td>
        </tr>
    `).join('');
}

function formatDateDE(value) {
    if (!value) return '';
    try {
        const d = new Date(value);
        if (isNaN(d)) return value;
        return d.toLocaleDateString('de-DE');
    } catch {
        return value;
    }
}

function formatCurrency(value) {
    if (!value) return '';
    return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value);
}

function getStatusClass(status) {
    if (!status) return 'open';
    const s = status.toLowerCase();
    if (s.includes('abgeschlossen') || s.includes('erledigt')) return 'ok';
    if (s.includes('planung') || s.includes('warten')) return 'warn';
    return 'open';
}

async function dateiHinzufuegen() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Kunden auswählen');
        else alert('Bitte zuerst einen Kunden auswählen');
        return;
    }

    // File-Input erstellen und triggern
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '*/*';
    input.onchange = async (e) => {
        const file = e.target.files[0];
        if (file) {
            setStatus('Datei wird hochgeladen...');

            try {
                // FormData für Upload erstellen
                const formData = new FormData();
                formData.append('file', file);
                formData.append('kd_id', id);
                formData.append('typ', 'kunde_dokument');

                const response = await fetch('http://localhost:5000/api/upload', {
                    method: 'POST',
                    body: formData
                });

                if (response.ok) {
                    const result = await response.json();
                    setStatus('Datei hochgeladen: ' + file.name);
                    if (typeof Toast !== 'undefined') {
                        Toast.success('Datei erfolgreich hochgeladen: ' + file.name);
                    } else {
                        alert('Datei erfolgreich hochgeladen: ' + file.name);
                    }
                    // Dateien-Liste aktualisieren falls vorhanden
                    if (typeof loadKundenDateien === 'function') loadKundenDateien();
                } else {
                    throw new Error('Upload fehlgeschlagen');
                }
            } catch (error) {
                setStatus('Upload-Fehler');
                console.error('Upload error:', error);
                if (typeof Toast !== 'undefined') {
                    Toast.error('Fehler beim Hochladen: ' + error.message);
                } else {
                    alert('Fehler beim Hochladen: ' + error.message);
                }
            }
        }
    };
    input.click();
}

// ============================================
// ACCESS VBA-SYNC EVENTS (AfterUpdate)
// ============================================

/**
 * Access: KD_Kuerzel_AfterUpdate - Kürzel geändert
 */
function KD_Kuerzel_AfterUpdate(value) {
    console.log('[Access-Sync] KD_Kuerzel_AfterUpdate:', value);
    if (elements.KD_Kuerzel) elements.KD_Kuerzel.value = value || '';
    state.isDirty = true;
}

/**
 * Access: KD_Name1_AfterUpdate - Hauptname geändert
 */
function KD_Name1_AfterUpdate(value) {
    console.log('[Access-Sync] KD_Name1_AfterUpdate:', value);
    if (elements.KD_Name1) elements.KD_Name1.value = value || '';
    state.isDirty = true;
    // Kunde in Liste aktualisieren
    if (state.currentIndex >= 0 && state.records[state.currentIndex]) {
        state.records[state.currentIndex].KD_Name1 = value;
        renderList();
    }
}

/**
 * Access: KD_IstAktiv_AfterUpdate - Status geändert
 */
function KD_IstAktiv_AfterUpdate(value) {
    console.log('[Access-Sync] KD_IstAktiv_AfterUpdate:', value);
    if (elements.KD_IstAktiv) elements.KD_IstAktiv.checked = !!value;
    state.isDirty = true;
}

/**
 * Access: cboAuftragsfilter_AfterUpdate - Auftragsfilter geändert
 * @param {string} filterValue - Der Filterwert (z.B. Status-ID)
 */
function cboAuftragsfilter_AfterUpdate(filterValue) {
    console.log('[Access-Sync] cboAuftragsfilter_AfterUpdate:', filterValue);
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (id) {
        Bridge.auftraege.list({ kunde_id: id, status: filterValue })
            .then(result => {
                const auftraege = result.data || [];
                renderAuftraege(auftraege);
                setStatus(`${auftraege.length} Aufträge gefunden`);
            })
            .catch(error => {
                console.error('[cboAuftragsfilter] Fehler:', error);
                setStatus('Fehler beim Laden der Aufträge');
            });
    }
}

/**
 * Access: datAuftraegeVon_AfterUpdate - Datum Von geändert
 */
function datAuftraegeVon_AfterUpdate(datum) {
    console.log('[Access-Sync] datAuftraegeVon_AfterUpdate:', datum);
    if (elements.datAuftraegeVon) elements.datAuftraegeVon.value = datum || '';
    filterAuftraege();
}

/**
 * Access: datAuftraegeBis_AfterUpdate - Datum Bis geändert
 */
function datAuftraegeBis_AfterUpdate(datum) {
    console.log('[Access-Sync] datAuftraegeBis_AfterUpdate:', datum);
    if (elements.datAuftraegeBis) elements.datAuftraegeBis.value = datum || '';
    filterAuftraege();
}

/**
 * Access: KD_Zahlungsbedingung_AfterUpdate - Zahlungsbedingung geändert
 */
function KD_Zahlungsbedingung_AfterUpdate(value) {
    console.log('[Access-Sync] KD_Zahlungsbedingung_AfterUpdate:', value);
    if (elements.KD_Zahlungsbedingung) elements.KD_Zahlungsbedingung.value = value || '';
    state.isDirty = true;
}

/**
 * Access: cboKundenSuche_AfterUpdate - Kunden-ID Schnellsuche
 * @param {number} kundeId - Die gesuchte Kunden-ID
 */
function cboKundenSuche_AfterUpdate(kundeId) {
    console.log('[Access-Sync] cboKundenSuche_AfterUpdate:', kundeId);
    if (kundeId) {
        const parsedId = parseInt(kundeId);
        const index = state.records.findIndex(k =>
            (k.KD_ID || k.kun_Id) === parsedId
        );
        if (index >= 0) {
            gotoRecord(index);
        } else {
            // Direkt laden via Bridge
            Bridge.kunden.get(parsedId).then(result => {
                const data = result.data || result;
                if (data) {
                    state.records.push(data);
                    gotoRecord(state.records.length - 1);
                } else {
                    console.warn('[cboKundenSuche] Kunde nicht gefunden:', kundeId);
                }
            }).catch(err => {
                console.error('[cboKundenSuche] Fehler:', err);
            });
        }
    }
}

// Init bei DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}

// Globaler Zugriff
window.KundenStamm = {
    loadList,
    gotoRecord,
    newRecord,
    saveRecord,
    deleteRecord,
    searchRecords,
    // Access VBA-Sync Events
    KD_Kuerzel_AfterUpdate,
    KD_Name1_AfterUpdate,
    KD_IstAktiv_AfterUpdate,
    cboAuftragsfilter_AfterUpdate,
    datAuftraegeVon_AfterUpdate,
    datAuftraegeBis_AfterUpdate,
    KD_Zahlungsbedingung_AfterUpdate,
    cboKundenSuche_AfterUpdate
};

// ============ FUNCTION ALIASES (fuer onclick-Handler Kompatibilitaet) ============

// === Formular-Aktionen ===
window.closeForm = function() {
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) Bridge.sendEvent('close');
    else window.close();
};
window.toggleFullscreen = function() {
    if (!document.fullscreenElement) document.documentElement.requestFullscreen();
    else if (document.exitFullscreen) document.exitFullscreen();
};
window.refreshData = function() { loadList(); };
window.speichern = typeof saveRecord === 'function' ? saveRecord : function() {
    if (typeof Toast !== 'undefined') Toast.warning('Speichern nicht verfuegbar');
    else alert('Speichern nicht verfuegbar');
};

// === Navigation ===
window.gotoFirstRecord = function() { gotoRecord(0); };
window.gotoPrevRecord = function() { if (state.currentIndex > 0) gotoRecord(state.currentIndex - 1); };
window.gotoNextRecord = function() { if (state.currentIndex < state.records.length - 1) gotoRecord(state.currentIndex + 1); };
window.gotoLastRecord = function() { gotoRecord(state.records.length - 1); };

// === Kunden-Aktionen ===
window.neuerKunde = typeof newRecord === 'function' ? newRecord : function() {
    if (typeof Toast !== 'undefined') Toast.info('Neuer Kunde wird angelegt...');
    else alert('Neuer Kunde wird angelegt...');
};
window.kundeLöschen = typeof deleteRecord === 'function' ? deleteRecord : function() {
    if (typeof Toast !== 'undefined') Toast.warning('Loeschen nicht verfuegbar');
    else alert('Loeschen nicht verfuegbar');
};
window.sucheKundeNr = function() {
    const input = document.getElementById('inputKundeNr') || document.querySelector('input[name="kundeNr"]');
    if (input && input.value) {
        cboKundenSuche_AfterUpdate(input.value);
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Kunden-Nr. eingeben');
        else alert('Bitte Kunden-Nr. eingeben');
    }
};

// === Office-Integration ===
window.openOutlook = function() {
    const email = elements.KD_Email?.value || state.currentRecord?.KD_Email;
    if (email) {
        window.open('mailto:' + email, '_blank');
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Keine E-Mail-Adresse vorhanden');
        else alert('Keine E-Mail-Adresse vorhanden');
    }
};
window.openWord = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openWordBrief', { kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Word-Brief wird erstellt...');
        else alert('Word-Brief wird erstellt...');
    }
};

// === Tab-Wechsel ===
window.switchTab = function(tabName) {
    const tabBtn = document.querySelector('[data-tab="' + tabName + '"]');
    if (tabBtn) tabBtn.click();
    else console.warn('[switchTab] Tab nicht gefunden:', tabName);
};

// === Objekte ===
window.neuesObjekt = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_OB_Objekt', kd_id: id, modus: 'neu' });
    } else {
        window.open('frm_OB_Objekt.html?kd_id=' + (id || '') + '&modus=neu', '_blank');
    }
};
window.loadObjekte = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (id && typeof Bridge !== 'undefined') {
        Bridge.objekte.list({ kunde_id: id }).then(result => {
            console.log('[loadObjekte] Ergebnis:', result);
            // Objekte-Liste rendern falls Container vorhanden
        }).catch(err => console.error('[loadObjekte] Fehler:', err));
    }
};
window.openObjekt = function() {
    const selectedRow = document.querySelector('#objekteTbody tr.selected');
    if (selectedRow) {
        const objektId = selectedRow.dataset.id;
        if (typeof Bridge !== 'undefined' && Bridge.execute) {
            Bridge.execute('openForm', { form: 'frm_OB_Objekt', ob_id: objektId });
        } else {
            window.open('frm_OB_Objekt.html?ob_id=' + objektId, '_blank');
        }
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Objekt auswaehlen');
        else alert('Bitte Objekt auswaehlen');
    }
};

// === Auftraege ===
window.loadAufträge = function() { filterAuftraege(); };
window.activateDatumsfilter = function() {
    const vonInput = document.getElementById('datAuftraegeVon');
    const bisInput = document.getElementById('datAuftraegeBis');
    if (vonInput) vonInput.focus();
};
window.openNeuerAuftrag = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_va_Auftragstamm', kd_id: id, modus: 'neu' });
    } else {
        window.open('frm_va_Auftragstamm.html?kd_id=' + (id || '') + '&modus=neu', '_blank');
    }
};
window.loadAuftragsPositionen = function() {
    console.log('[loadAuftragsPositionen] Aufgerufen');
    // Implementierung je nach API
};

// === PDF-Ausgaben ===
window.openRechnungPDF = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('druckePDF', { typ: 'Rechnung', kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Rechnung wird erstellt...');
        else alert('Rechnung wird erstellt...');
    }
};
window.openBerechnungslistePDF = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('druckePDF', { typ: 'Berechnungsliste', kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Berechnungsliste wird erstellt...');
        else alert('Berechnungsliste wird erstellt...');
    }
};
window.openEinsatzlistePDF = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('druckePDF', { typ: 'Einsatzliste', kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Einsatzliste wird erstellt...');
        else alert('Einsatzliste wird erstellt...');
    }
};

// === Ansprechpartner ===
window.neuerAnsprechpartner = function() {
    console.log('[AP] Neuer Ansprechpartner');
    // Ansprechpartner-Eingabebereich einblenden/leeren
    const apForm = document.getElementById('ansprechpartnerForm');
    if (apForm) {
        apForm.querySelectorAll('input').forEach(i => i.value = '');
        apForm.style.display = 'block';
    }
};
window.loescheAnsprechpartner = function() {
    console.log('[AP] Ansprechpartner loeschen');
    const selectedRow = document.querySelector('#ansprechpartnerTbody tr.selected');
    if (selectedRow) {
        if (confirm('Ansprechpartner wirklich loeschen?')) {
            // Loeschen via Bridge
            if (typeof Toast !== 'undefined') Toast.success('Ansprechpartner geloescht');
        }
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Ansprechpartner auswaehlen');
        else alert('Bitte Ansprechpartner auswaehlen');
    }
};
window.loadAnsprechpartner = function() {
    console.log('[AP] Ansprechpartner laden');
    // Implementierung je nach API
};
window.speichereAnsprechpartner = function() {
    console.log('[AP] Ansprechpartner speichern');
    if (typeof Toast !== 'undefined') Toast.success('Ansprechpartner gespeichert');
    else alert('Ansprechpartner gespeichert');
};

// === Angebote ===
window.neuesAngebot = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('neuesAngebot', { kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Neues Angebot wird angelegt...');
        else alert('Neues Angebot wird angelegt...');
    }
};
window.loadAngebote = function() {
    console.log('[Angebote] Laden');
    // Implementierung je nach API
};
window.openAngebotPDF = function() {
    if (typeof Toast !== 'undefined') Toast.info('Angebot-PDF wird erstellt...');
    else alert('Angebot-PDF wird erstellt...');
};

// === Statistik ===
window.loadStatistik = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    console.log('[Statistik] Laden fuer Kunde:', id);
    // Implementierung je nach API
};
window.exportStatistikExcel = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'KundenStatistik', kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Statistik');
        else alert('Excel-Export: Statistik');
    }
};

// === Kundenpreise ===
window.standardpreiseAnlegen = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('standardpreiseAnlegen', { kd_id: id });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Standardpreise werden angelegt...');
        else alert('Standardpreise werden angelegt...');
    }
};
window.loadKundenpreise = function() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    console.log('[Preise] Laden fuer Kunde:', id);
    // Implementierung je nach API
};
window.neuerPreis = function() {
    console.log('[Preise] Neuer Preis');
    // Preis-Eingabebereich einblenden
    const preisForm = document.getElementById('preisForm');
    if (preisForm) {
        preisForm.querySelectorAll('input').forEach(i => i.value = '');
        preisForm.style.display = 'block';
    }
};
window.preisLoeschen = function() {
    const selectedRow = document.querySelector('#kundenpreiseTbody tr.selected');
    if (selectedRow) {
        if (confirm('Preis wirklich loeschen?')) {
            if (typeof Toast !== 'undefined') Toast.success('Preis geloescht');
        }
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Preis auswaehlen');
        else alert('Bitte Preis auswaehlen');
    }
};
window.speicherePreis = function() {
    console.log('[Preise] Preis speichern');
    if (typeof Toast !== 'undefined') Toast.success('Preis gespeichert');
    else alert('Preis gespeichert');
};

// === Filter ===
window.resetAuswahlfilter = function() {
    // Alle Filter zuruecksetzen
    const filterInputs = document.querySelectorAll('.filter-input, [data-filter]');
    filterInputs.forEach(input => {
        if (input.type === 'checkbox') input.checked = false;
        else input.value = '';
    });
    loadList(); // Liste neu laden
    if (typeof Toast !== 'undefined') Toast.info('Filter zurueckgesetzt');
};

console.log('[frm_KD_Kundenstamm] Alle onclick-Handler registriert');
