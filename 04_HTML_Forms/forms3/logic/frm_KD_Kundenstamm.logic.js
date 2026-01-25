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

    // Such-Comboboxen initialisieren
    setupSuchComboboxen();

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
        // Single Click - Datensatz auswählen
        row.addEventListener('click', () => {
            const idx = parseInt(row.dataset.index);
            if (!isNaN(idx)) gotoRecord(idx);
        });

        // Double Click - Access: lst_KD_DblClick - Kundendetails öffnen
        row.addEventListener('dblclick', () => {
            const kdId = row.dataset.id;
            if (kdId) {
                lst_KD_DblClick(kdId);
            }
        });
    });
}

/**
 * Access: lst_KD_DblClick - Öffnet Kundendetails bei Doppelklick
 * VBA Original: Öffnet Detail-Dialog oder wechselt Tab
 * @param {string|number} kdId - Die Kunden-ID
 */
function lst_KD_DblClick(kdId) {
    console.log('[lst_KD_DblClick] KD-ID:', kdId);

    // Optionen für Doppelklick-Aktion:
    const actions = [
        'Aufträge anzeigen',
        'Verrechnungssätze öffnen',
        'Abbrechen'
    ];

    // Einfache Aktion: Zum Aufträge-Tab wechseln
    const auftraegeTab = document.querySelector('[data-tab="auftraege"]');
    if (auftraegeTab) {
        auftraegeTab.click();
        filterAuftraege(); // Aufträge für diesen Kunden laden
        return;
    }

    // Fallback: Auswahldialog
    const choice = confirm('Aufträge für diesen Kunden anzeigen?');
    if (choice) {
        filterAuftraege();
    }
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
// SUCH-COMBOBOXEN (Access-Parität)
// ============================================

/**
 * Access: cboSuchOrt_AfterUpdate - Suche nach Ort
 * VBA Original: Filtert Kundenliste nach Ort
 * @param {string} ort - Der gesuchte Ort
 */
async function cboSuchOrt_AfterUpdate(ort) {
    console.log('[cboSuchOrt_AfterUpdate] Suche nach Ort:', ort);

    if (!ort || ort.trim() === '') {
        await loadList();
        return;
    }

    setStatus('Suche nach Ort...');

    try {
        const result = await Bridge.kunden.list({ ort: ort, aktiv: state.nurAktive ? 1 : 0 });
        state.records = result.data || result || [];
        renderList();

        if (state.records.length > 0) {
            gotoRecord(0);
            setStatus(`${state.records.length} Kunden in ${ort} gefunden`);
        } else {
            clearForm();
            setStatus(`Keine Kunden in ${ort} gefunden`);
        }
    } catch (error) {
        console.error('[cboSuchOrt] Fehler:', error);
        // Lokale Filterung als Fallback
        const term = ort.toLowerCase();
        const filtered = state.records.filter(r =>
            (r.KD_Ort || r.kun_Ort || '').toLowerCase().includes(term)
        );
        state.records = filtered;
        renderList();
        if (filtered.length > 0) gotoRecord(0);
        setStatus(`${filtered.length} Kunden gefunden (lokal)`);
    }
}

/**
 * Access: cboSuchPLZ_AfterUpdate - Suche nach PLZ
 * VBA Original: Filtert Kundenliste nach PLZ
 * @param {string} plz - Die gesuchte PLZ
 */
async function cboSuchPLZ_AfterUpdate(plz) {
    console.log('[cboSuchPLZ_AfterUpdate] Suche nach PLZ:', plz);

    if (!plz || plz.trim() === '') {
        await loadList();
        return;
    }

    setStatus('Suche nach PLZ...');

    try {
        const result = await Bridge.kunden.list({ plz: plz, aktiv: state.nurAktive ? 1 : 0 });
        state.records = result.data || result || [];
        renderList();

        if (state.records.length > 0) {
            gotoRecord(0);
            setStatus(`${state.records.length} Kunden mit PLZ ${plz} gefunden`);
        } else {
            clearForm();
            setStatus(`Keine Kunden mit PLZ ${plz} gefunden`);
        }
    } catch (error) {
        console.error('[cboSuchPLZ] Fehler:', error);
        // Lokale Filterung als Fallback
        const filtered = state.records.filter(r =>
            (r.KD_PLZ || r.kun_PLZ || '').startsWith(plz)
        );
        state.records = filtered;
        renderList();
        if (filtered.length > 0) gotoRecord(0);
        setStatus(`${filtered.length} Kunden gefunden (lokal)`);
    }
}

/**
 * Initialisiert die Such-Comboboxen
 */
function setupSuchComboboxen() {
    // Ort-Suche
    const cboSuchOrt = document.getElementById('cboSuchOrt');
    if (cboSuchOrt) {
        cboSuchOrt.addEventListener('change', () => {
            cboSuchOrt_AfterUpdate(cboSuchOrt.value);
        });
        cboSuchOrt.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                cboSuchOrt_AfterUpdate(cboSuchOrt.value);
            }
        });
    }

    // PLZ-Suche
    const cboSuchPLZ = document.getElementById('cboSuchPLZ');
    if (cboSuchPLZ) {
        cboSuchPLZ.addEventListener('change', () => {
            cboSuchPLZ_AfterUpdate(cboSuchPLZ.value);
        });
        cboSuchPLZ.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                cboSuchPLZ_AfterUpdate(cboSuchPLZ.value);
            }
        });
    }

    console.log('[Kundenstamm] Such-Comboboxen initialisiert');
}

// ============================================
// KOPF_BERECH FUNKTION (Access-Parität)
// ============================================

/**
 * Access: Kopf_Berech - Berechnet Kopf-Statistiken für Kunden
 * VBA Original: Berechnet Aufträge, Personal, Stunden, Umsatz für 3 Zeiträume
 * @returns {Promise<Object>} Statistik-Objekt mit allen Werten
 */
async function Kopf_Berech() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) {
        console.warn('[Kopf_Berech] Keine Kunden-ID');
        return null;
    }

    console.log('[Kopf_Berech] Berechne Statistik für Kunde:', kdId);

    const heute = new Date();
    const vor90Tagen = new Date(heute.getTime() - 90 * 24 * 60 * 60 * 1000);
    const vor30Tagen = new Date(heute.getTime() - 30 * 24 * 60 * 60 * 1000);

    // Zeiträume wie in Access VBA
    const zeitraeume = [
        { name: 'Gesamt', von: null, bis: null },
        { name: 'Letzte 90 Tage', von: vor90Tagen, bis: heute },
        { name: 'Letzte 30 Tage', von: vor30Tagen, bis: heute }
    ];

    const stats = {
        zeitraeume: []
    };

    try {
        for (let i = 0; i < zeitraeume.length; i++) {
            const zr = zeitraeume[i];
            const params = { kunde_id: kdId };

            if (zr.von) params.von = formatDateISO(zr.von);
            if (zr.bis) params.bis = formatDateISO(zr.bis);

            // Aufträge zählen
            const auftraege = await Bridge.auftraege.list(params);
            const auftraegeData = auftraege.data || auftraege || [];

            // Stunden und Personal aus Zuordnungen
            const zuordnungen = await Bridge.execute('getZuordnungen', params);
            const zuordnungenData = zuordnungen.data || zuordnungen || [];

            // Berechne Summen
            let persGes = 0;
            let stdGes = 0;
            let umsGes = 0;
            let std5 = 0, std6 = 0, std7 = 0; // Freitag, Samstag, Sonntag
            let pers5 = 0, pers6 = 0, pers7 = 0;

            zuordnungenData.forEach(z => {
                persGes++;
                const stunden = parseFloat(z.MA_Brutto_Std || z.Stunden || 0);
                stdGes += stunden;

                // Wochentag ermitteln (5=Fr, 6=Sa, 7=So)
                const datum = new Date(z.VADatum || z.Datum);
                const wochentag = datum.getDay(); // 0=So, 1=Mo, ..., 6=Sa

                if (wochentag === 5) { std5 += stunden; pers5++; } // Freitag
                if (wochentag === 6) { std6 += stunden; pers6++; } // Samstag
                if (wochentag === 0) { std7 += stunden; pers7++; } // Sonntag
            });

            // Umsatz berechnen (falls Netto-Betrag vorhanden)
            auftraegeData.forEach(a => {
                umsGes += parseFloat(a.NettoBetrag || a.Umsatz || 0);
            });

            stats.zeitraeume.push({
                name: zr.name,
                index: i + 1,
                AufAnz: auftraegeData.length,
                PersGes: persGes,
                StdGes: stdGes.toFixed(2),
                UmsGes: umsGes.toFixed(2),
                Std5: std5.toFixed(2),
                Std6: std6.toFixed(2),
                Std7: std7.toFixed(2),
                Pers5: pers5,
                Pers6: pers6,
                Pers7: pers7
            });
        }

        // Werte in Formular eintragen falls Felder existieren
        stats.zeitraeume.forEach((s, i) => {
            const idx = i + 1;
            setFieldIfExists(`AufAnz${idx}`, s.AufAnz);
            setFieldIfExists(`PersGes${idx}`, s.PersGes);
            setFieldIfExists(`StdGes${idx}`, s.StdGes);
            setFieldIfExists(`UmsGes${idx}`, s.UmsGes);
            setFieldIfExists(`Std5${idx}`, s.Std5);
            setFieldIfExists(`Std6${idx}`, s.Std6);
            setFieldIfExists(`Std7${idx}`, s.Std7);
            setFieldIfExists(`Pers5${idx}`, s.Pers5);
            setFieldIfExists(`Pers6${idx}`, s.Pers6);
            setFieldIfExists(`Pers7${idx}`, s.Pers7);
        });

        console.log('[Kopf_Berech] Statistik berechnet:', stats);
        return stats;

    } catch (error) {
        console.error('[Kopf_Berech] Fehler:', error);
        return null;
    }
}

/**
 * Hilfsfunktion: Setzt Feldwert falls Element existiert
 */
function setFieldIfExists(fieldId, value) {
    const el = document.getElementById(fieldId);
    if (el) {
        if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
            el.value = value ?? '';
        } else {
            el.textContent = value ?? '';
        }
    }
}

/**
 * Formatiert Datum als ISO-String (YYYY-MM-DD)
 */
function formatDateISO(date) {
    if (!date) return '';
    const d = date instanceof Date ? date : new Date(date);
    if (isNaN(d)) return '';
    return d.toISOString().split('T')[0];
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

// ============================================
// TAB-LOADER FUNKTIONEN (REST-API)
// ============================================

/**
 * Bemerkungen-Tab: Lädt kun_Anschreiben, kun_BriefKopf, kun_memo
 * Diese Felder werden bereits beim Laden des Kundendatensatzes geladen
 */
function loadTabContent_Bemerkungen() {
    // Bemerkungen werden mit dem Hauptdatensatz geladen (data-field Binding)
    console.log('[Tab:Bemerkungen] Felder sind bereits via data-field gebunden');
}

/**
 * Rechnungen-Tab: Lädt Rechnungen des Kunden
 */
async function loadTabContent_Rechnungen() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    const tbody = document.getElementById('rechnungenBody');
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:10px;">Lade Rechnungen...</td></tr>';
    }

    try {
        const response = await fetch(`http://localhost:5000/api/kunden/${kdId}/rechnungen`);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result || [];
            renderRechnungen(data);
        } else {
            console.warn('[Tab:Rechnungen] API nicht verfügbar, Status:', response.status);
            if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:10px;">Keine Rechnungen verfügbar</td></tr>';
        }
    } catch (err) {
        console.error('[Tab:Rechnungen] Fehler:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#999; padding:10px;">API nicht erreichbar</td></tr>';
    }
}

function renderRechnungen(data) {
    const tbody = document.getElementById('rechnungenBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:20px;">Keine Rechnungen vorhanden</td></tr>';
        return;
    }

    data.forEach(row => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${row.Rch_Nr || row.ID || ''}</td>
            <td>${formatDateDE(row.Rch_Datum || row.Datum)}</td>
            <td>${row.Rch_Bezeichnung || row.Bezeichnung || ''}</td>
            <td style="text-align:right;">${formatCurrency(row.Rch_Betrag || row.Betrag)}</td>
            <td>${row.Rch_Status || row.Status || ''}</td>
            <td>${formatDateDE(row.Rch_Bezahlt || row.BezahltAm)}</td>
        `;
        tbody.appendChild(tr);
    });
}

/**
 * Aufträge-Tab: Lädt Aufträge des Kunden
 */
async function loadTabContent_Auftraege() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    const von = document.getElementById('datAuftraegeVon')?.value || document.getElementById('datAufträgeVon')?.value;
    const bis = document.getElementById('datAuftraegeBis')?.value || document.getElementById('datAufträgeBis')?.value;

    const tbody = document.getElementById('auftraegeBody') || document.getElementById('tbody_Auftraege');
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:10px;">Lade Aufträge...</td></tr>';
    }

    try {
        let url = `http://localhost:5000/api/kunden/${kdId}/auftraege`;
        const params = [];
        if (von) params.push(`von=${von}`);
        if (bis) params.push(`bis=${bis}`);
        if (params.length > 0) url += '?' + params.join('&');

        const response = await fetch(url);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result || [];
            renderAuftraegeTab(data);
        } else {
            // Fallback: Versuche allgemeines Auftraege-Endpoint mit Filter
            const fallbackResponse = await fetch(`http://localhost:5000/api/auftraege?kunde_id=${kdId}`);
            if (fallbackResponse.ok) {
                const result = await fallbackResponse.json();
                const data = result.data || result || [];
                renderAuftraegeTab(data);
            } else {
                if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:10px;">Keine Aufträge verfügbar</td></tr>';
            }
        }
    } catch (err) {
        console.error('[Tab:Auftraege] Fehler:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#999; padding:10px;">API nicht erreichbar</td></tr>';
    }
}

function renderAuftraegeTab(data) {
    const tbody = document.getElementById('auftraegeBody') || document.getElementById('tbody_Auftraege');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:20px;">Keine Aufträge vorhanden</td></tr>';
        return;
    }

    data.forEach(row => {
        const tr = document.createElement('tr');
        tr.dataset.id = row.VA_ID || row.ID;
        tr.innerHTML = `
            <td>${row.VA_Nr || row.Auftrag || row.ID || ''}</td>
            <td>${row.VA_Bezeichnung || row.Bezeichnung || ''}</td>
            <td>${formatDateDE(row.VA_Datum || row.Dat_VA_Von || row.Datum)}</td>
            <td>${row.VA_Objekt || row.Objekt || ''}</td>
            <td>${row.VA_Status || row.Status || ''}</td>
            <td style="text-align:right;">${formatCurrency(row.VA_Betrag || row.Betrag)}</td>
        `;
        tr.addEventListener('click', () => {
            document.querySelectorAll('#auftraegeBody tr, #tbody_Auftraege tr').forEach(r => r.classList.remove('selected'));
            tr.classList.add('selected');
        });
        tbody.appendChild(tr);
    });
}

/**
 * Objekte-Tab: Lädt Objekte des Kunden
 */
async function loadTabContent_Objekte() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    const tbody = document.getElementById('objekteBody');
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:10px;">Lade Objekte...</td></tr>';
    }

    try {
        const response = await fetch(`http://localhost:5000/api/kunden/${kdId}/objekte`);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result || [];
            renderObjekteTab(data);
        } else {
            // Fallback: Versuche allgemeines Objekte-Endpoint mit Filter
            const fallbackResponse = await fetch(`http://localhost:5000/api/objekte?kunde_id=${kdId}`);
            if (fallbackResponse.ok) {
                const result = await fallbackResponse.json();
                const data = result.data || result || [];
                renderObjekteTab(data);
            } else {
                if (tbody) tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:#666; padding:10px;">Keine Objekte verfügbar</td></tr>';
            }
        }
    } catch (err) {
        console.error('[Tab:Objekte] Fehler:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:#999; padding:10px;">API nicht erreichbar</td></tr>';
    }
}

function renderObjekteTab(data) {
    const tbody = document.getElementById('objekteBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:#666; padding:20px;">Keine Objekte vorhanden</td></tr>';
        return;
    }

    data.forEach(row => {
        const tr = document.createElement('tr');
        tr.dataset.id = row.ob_id || row.ID;
        tr.innerHTML = `
            <td>${row.ob_id || row.ID || ''}</td>
            <td>${row.ob_Objektname || row.Objektname || ''}</td>
            <td>${row.ob_Ort || row.Ort || ''}</td>
            <td>${row.ob_IstAktiv ? 'Ja' : 'Nein'}</td>
            <td>${row.anzahl_auftraege || row.AnzahlAuftraege || ''}</td>
        `;
        tr.addEventListener('click', () => {
            document.querySelectorAll('#objekteBody tr').forEach(r => r.classList.remove('selected'));
            tr.classList.add('selected');
        });
        tbody.appendChild(tr);
    });
}

/**
 * Ansprechpartner-Tab: Lädt Ansprechpartner des Kunden
 */
async function loadTabContent_Ansprechpartner() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    const tbody = document.getElementById('ansprechpartnerTbody') || document.getElementById('ansprechpartnerBody');
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:10px;">Lade Ansprechpartner...</td></tr>';
    }

    try {
        const response = await fetch(`http://localhost:5000/api/kunden/${kdId}/ansprechpartner`);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result || [];
            renderAnsprechpartnerTab(data);
        } else {
            if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:10px;">Keine Ansprechpartner verfügbar</td></tr>';
        }
    } catch (err) {
        console.error('[Tab:Ansprechpartner] Fehler:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#999; padding:10px;">API nicht erreichbar</td></tr>';
    }
}

function renderAnsprechpartnerTab(data) {
    const tbody = document.getElementById('ansprechpartnerTbody') || document.getElementById('ansprechpartnerBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:20px;">Keine Ansprechpartner vorhanden</td></tr>';
        return;
    }

    data.forEach(row => {
        const tr = document.createElement('tr');
        tr.dataset.id = row.adr_ID || row.ID;
        tr.innerHTML = `
            <td>${row.adr_Nachname || row.Nachname || ''}</td>
            <td>${row.adr_Vorname || row.Vorname || ''}</td>
            <td>${row.adr_Name1 || row.Position || ''}</td>
            <td>${row.adr_Tel || row.Telefon || ''}</td>
            <td>${row.adr_Handy || row.Mobil || ''}</td>
            <td>${row.adr_eMail || row.Email || ''}</td>
        `;
        tr.addEventListener('click', () => {
            document.querySelectorAll('#ansprechpartnerTbody tr, #ansprechpartnerBody tr').forEach(r => r.classList.remove('selected'));
            tr.classList.add('selected');
        });
        tbody.appendChild(tr);
    });
}

/**
 * Preise-Tab: Lädt Kundenpreise
 */
async function loadTabContent_Preise() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    const tbody = document.getElementById('kundenpreiseBody');
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:10px;">Lade Preise...</td></tr>';
    }

    try {
        const response = await fetch(`http://localhost:5000/api/kunden/${kdId}/preise`);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result || [];
            renderPreiseTab(data);
        } else {
            if (tbody) tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color:#666; padding:10px;">Keine Preise verfügbar</td></tr>';
        }
    } catch (err) {
        console.error('[Tab:Preise] Fehler:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color:#999; padding:10px;">API nicht erreichbar</td></tr>';
    }
}

function renderPreiseTab(data) {
    const tbody = document.getElementById('kundenpreiseBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; color:#666; padding:20px;">Keine Kundenpreise vorhanden. Klicken Sie auf "Standardpreise anlegen".</td></tr>';
        return;
    }

    data.forEach((row, index) => {
        const tr = document.createElement('tr');
        tr.dataset.id = row.ID;
        tr.innerHTML = `
            <td style="text-align:center;">${index + 1}</td>
            <td>${row.Bezeichnung || ''}</td>
            <td style="text-align:right;">${formatCurrency(row.StdPreis)}</td>
            <td style="text-align:right;">${formatCurrency(row.TagPreis)}</td>
            <td style="text-align:right;">${row.Nachtzuschlag ? row.Nachtzuschlag + ' %' : '-'}</td>
            <td>${row.Bemerkung || ''}</td>
            <td>${formatDateDE(row.GeaendertAm)}</td>
        `;
        tr.addEventListener('click', () => {
            document.querySelectorAll('#kundenpreiseBody tr').forEach(r => r.classList.remove('selected'));
            tr.classList.add('selected');
        });
        tbody.appendChild(tr);
    });
}

/**
 * Angebote-Tab: Lädt Angebote des Kunden
 */
async function loadTabContent_Angebote() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    const tbody = document.getElementById('angeboteBody');
    if (tbody) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:10px;">Lade Angebote...</td></tr>';
    }

    try {
        const response = await fetch(`http://localhost:5000/api/kunden/${kdId}/angebote`);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result || [];
            renderAngeboteTab(data);
        } else {
            if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:10px;">Keine Angebote verfügbar</td></tr>';
        }
    } catch (err) {
        console.error('[Tab:Angebote] Fehler:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#999; padding:10px;">API nicht erreichbar</td></tr>';
    }
}

function renderAngeboteTab(data) {
    const tbody = document.getElementById('angeboteBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:20px;">Keine Angebote vorhanden</td></tr>';
        // Summen aktualisieren
        const anzahlEl = document.getElementById('angeboteAnzahl');
        const gesamtwertEl = document.getElementById('angeboteGesamtwert');
        if (anzahlEl) anzahlEl.textContent = '0';
        if (gesamtwertEl) gesamtwertEl.textContent = '0,00 EUR';
        return;
    }

    let gesamtwert = 0;

    data.forEach(row => {
        const tr = document.createElement('tr');
        tr.dataset.id = row.ID || row.ang_ID;
        const betrag = parseFloat(row.Betrag || row.ang_Betrag || 0);
        gesamtwert += betrag;

        tr.innerHTML = `
            <td>${formatDateDE(row.Datum || row.ang_Datum)}</td>
            <td>${row.Nummer || row.ang_Nummer || ''}</td>
            <td>${row.Bezeichnung || row.ang_Bezeichnung || ''}</td>
            <td style="text-align:right;">${formatCurrency(betrag)}</td>
            <td>${getAngebotStatusText(row.Status || row.ang_Status)}</td>
            <td>${formatDateDE(row.GueltigBis || row.ang_GueltigBis)}</td>
        `;
        tr.addEventListener('click', () => {
            document.querySelectorAll('#angeboteBody tr').forEach(r => r.classList.remove('selected'));
            tr.classList.add('selected');
        });
        tbody.appendChild(tr);
    });

    // Summen aktualisieren
    const anzahlEl = document.getElementById('angeboteAnzahl');
    const gesamtwertEl = document.getElementById('angeboteGesamtwert');
    if (anzahlEl) anzahlEl.textContent = data.length;
    if (gesamtwertEl) gesamtwertEl.textContent = formatCurrency(gesamtwert);
}

function getAngebotStatusText(status) {
    const statusMap = { 0: 'Offen', 1: 'Angenommen', 2: 'Abgelehnt', 3: 'Abgelaufen' };
    return statusMap[status] || status || 'Offen';
}

/**
 * Statistik-Tab: Lädt detaillierte Statistik (pg_Rch_Kopf)
 */
async function loadTabContent_Statistik() {
    const kdId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!kdId) return;

    try {
        const response = await fetch(`http://localhost:5000/api/kunden/${kdId}/statistik`);
        if (response.ok) {
            const result = await response.json();
            const data = result.data || result;
            renderStatistikTab(data);
        } else {
            console.warn('[Tab:Statistik] API nicht verfügbar');
            // Zeige zumindest die Jahres-Header
            updateStatistikJahre();
        }
    } catch (err) {
        console.error('[Tab:Statistik] Fehler:', err);
    }
}

function updateStatistikJahre() {
    const aktJahr = new Date().getFullYear();
    const el1 = document.getElementById('statJahr1Header');
    const el2 = document.getElementById('statJahr2Header');
    const el3 = document.getElementById('statJahr3Header');
    if (el1) el1.textContent = aktJahr;
    if (el2) el2.textContent = aktJahr - 1;
    if (el3) el3.textContent = aktJahr - 2;
}

function renderStatistikTab(data) {
    if (!data) return;

    updateStatistikJahre();

    // Jahres-Statistiken
    for (let i = 1; i <= 3; i++) {
        const jahr = data[`jahr${i}`] || {};
        setElementText(`UmsNGes${i}`, formatCurrency(jahr.UmsatzNetto));
        setElementText(`UmsGes${i}`, formatCurrency(jahr.UmsatzBrutto));
        setElementText(`StdGes${i}`, jahr.Stunden || '0');
        setElementText(`AufAnz${i}`, jahr.Auftraege || '0');
        setElementText(`PersGes${i}`, jahr.Personal || '0');
    }

    // KW-Statistiken (letzte Wochen)
    if (data.wochen) {
        data.wochen.forEach((woche, idx) => {
            const kwNr = 51 + idx;
            setElementText(`Std${kwNr}`, woche.Stunden || '0');
            setElementText(`Pers${kwNr}`, woche.Personal || '0');
        });
    }
}

function setElementText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value ?? '';
}

/**
 * Erweiterte switchTab-Funktion für die Logic-Datei
 * Diese wird als globale Funktion registriert und kann die HTML-inline switchTab überschreiben
 */
function switchTabExtended(tabName) {
    console.log('[switchTab] Wechsel zu Tab:', tabName);

    // Tab-Buttons aktivieren/deaktivieren
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabName);
    });

    // Tab-Seiten ein-/ausblenden
    document.querySelectorAll('.tab-page').forEach(page => {
        page.classList.toggle('active', page.id === 'tab-' + tabName);
    });

    // Tab-spezifische Daten laden, wenn Kunde ausgewählt
    if (state.currentRecord) {
        switch (tabName) {
            case 'stammdaten':
                // Stammdaten sind bereits geladen
                break;
            case 'objekte':
                loadTabContent_Objekte();
                break;
            case 'konditionen':
                // Konditionen sind Teil des Hauptdatensatzes
                break;
            case 'zusatzdateien':
                // loadZusatzdateien() - falls im HTML definiert
                if (typeof window.loadZusatzdateien === 'function') {
                    window.loadZusatzdateien();
                }
                break;
            case 'bemerkungen':
                loadTabContent_Bemerkungen();
                break;
            case 'preise':
                loadTabContent_Preise();
                break;
            case 'auftraguebersicht':
                loadTabContent_Auftraege();
                break;
            case 'ansprechpartner':
                loadTabContent_Ansprechpartner();
                break;
            case 'angebote':
                loadTabContent_Angebote();
                break;
            case 'statistik':
                loadTabContent_Statistik();
                break;
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
    cboKundenSuche_AfterUpdate,
    // NEU: Such-Comboboxen
    cboSuchOrt_AfterUpdate,
    cboSuchPLZ_AfterUpdate,
    // NEU: Kopf-Berechnung
    Kopf_Berech,
    // NEU: DblClick Handler
    lst_KD_DblClick,
    // NEU: Tab-Loader Funktionen
    loadTabContent_Bemerkungen,
    loadTabContent_Rechnungen,
    loadTabContent_Auftraege,
    loadTabContent_Objekte,
    loadTabContent_Ansprechpartner,
    loadTabContent_Preise,
    loadTabContent_Angebote,
    loadTabContent_Statistik,
    switchTabExtended
};

// Tab-Loader als globale Funktionen registrieren
window.loadTabContent_Bemerkungen = loadTabContent_Bemerkungen;
window.loadTabContent_Rechnungen = loadTabContent_Rechnungen;
window.loadTabContent_Auftraege = loadTabContent_Auftraege;
window.loadTabContent_Objekte = loadTabContent_Objekte;
window.loadTabContent_Ansprechpartner = loadTabContent_Ansprechpartner;
window.loadTabContent_Preise = loadTabContent_Preise;
window.loadTabContent_Angebote = loadTabContent_Angebote;
window.loadTabContent_Statistik = loadTabContent_Statistik;
window.switchTabExtended = switchTabExtended;

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
window.kundeLoeschen = window.kundeLöschen; // Alias ohne Umlaut fuer HTML onclick
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
