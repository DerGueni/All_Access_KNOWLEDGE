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
        const selected = idx === state.currentIndex ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${id}" class="${selected}">
                <td>${id}</td>
                <td>${name}</td>
                <td>${ort}</td>
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
 * Speichern
 */
async function saveRecord() {
    const name1 = elements.KD_Name1?.value?.trim();

    if (!name1) {
        alert('Bitte Firma/Name eingeben!');
        if (elements.KD_Name1) elements.KD_Name1.focus();
        return;
    }

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
        alert('Fehler beim Speichern: ' + error.message);
    }
}

/**
 * Löschen
 */
async function deleteRecord() {
    const id = elements.KD_ID?.value;
    if (!id) {
        alert('Kein Datensatz ausgewählt');
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
        alert('Fehler beim Löschen: ' + error.message);
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
        alert('Bitte zuerst einen Kunden auswählen');
        return;
    }
    alert('Verrechnungssätze: Funktion in Entwicklung\n\nKunde: ' + (elements.KD_Name1?.value || ''));
}

function openUmsatzauswertung() {
    const id = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;
    if (!id) {
        alert('Bitte zuerst einen Kunden auswählen');
        return;
    }
    alert('Umsatzauswertung: Funktion in Entwicklung\n\nKunde: ' + (elements.KD_Name1?.value || ''));
}

function filterAuftraege() {
    const von = elements.datAuftraegeVon?.value;
    const bis = elements.datAuftraegeBis?.value;
    const id = state.currentRecord?.KD_ID;

    if (!id) {
        alert('Bitte zuerst einen Kunden auswählen');
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

function dateiHinzufuegen() {
    const id = state.currentRecord?.KD_ID;
    if (!id) {
        alert('Bitte zuerst einen Kunden auswählen');
        return;
    }

    // File-Input erstellen und triggern
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '*/*';
    input.onchange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setStatus('Datei wird hochgeladen...');
            // Hier würde Upload-Logik kommen
            setTimeout(() => {
                setStatus('Datei hochgeladen: ' + file.name);
                alert('Upload-Funktion in Entwicklung\n\nDatei: ' + file.name);
            }, 500);
        }
    };
    input.click();
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
    searchRecords
};
