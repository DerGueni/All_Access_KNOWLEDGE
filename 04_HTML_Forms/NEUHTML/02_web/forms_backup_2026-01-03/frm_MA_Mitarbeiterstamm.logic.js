/**
 * frm_MA_Mitarbeiterstamm.logic.js
 * Logik für Mitarbeiterstamm-Formular
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

// DOM-Elemente (nach Init gefüllt)
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[frm_MA_Mitarbeiterstamm] Initialisierung...');

    // DOM-Referenzen sammeln - Angepasst an tatsächliche HTML-IDs
    elements = {
        // Navigation Buttons
        btnErster: document.getElementById('btnErster'),
        btnVorheriger: document.getElementById('btnVorheriger'),
        btnNaechster: document.getElementById('btnNaechster'),
        btnLetzter: document.getElementById('btnLetzter'),

        // Action Buttons
        btnNeuMA: document.getElementById('btnNeuMA'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLoeschen'),
        btnZeitkonto: document.getElementById('btnZeitkonto'),
        btnMAAdresse: document.getElementById('btnMAAdresse'),
        btnEinsaetzeFA: document.getElementById('btnEinsaetzeFA'),
        btnEinsaetzeMJ: document.getElementById('btnEinsaetzeMJ'),
        btnListenDrucken: document.getElementById('btnListenDrucken'),
        btnMATabelle: document.getElementById('btnMATabelle'),
        btnKoordinaten: document.getElementById('btnKoordinaten'),
        btnMapsOeffnen: document.getElementById('btnMapsOeffnen'),
        btnStundenlisteExportieren: document.getElementById('btnStundenlisteExportieren'),
        btnSpiegelrechnung: document.getElementById('btnSpiegelrechnung'),

        // Header-Anzeige
        lblKuerzel: document.getElementById('lblKuerzel'),
        lblNachname: document.getElementById('lblNachname'),
        lblVorname: document.getElementById('lblVorname'),
        lblMAID: document.getElementById('lblMAID'),
        lblStatus: document.getElementById('lblStatus'),

        // Stammdaten-Felder
        txtPersNr: document.getElementById('txtPersNr'),
        txtLexNr: document.getElementById('txtLexNr'),
        chkAktiv: document.getElementById('chkAktiv'),
        chkSubunternehmer: document.getElementById('chkSubunternehmer'),
        chkLexAktiv: document.getElementById('chkLexAktiv'),
        txtNachname: document.getElementById('txtNachname'),
        txtVorname: document.getElementById('txtVorname'),
        txtStrasse: document.getElementById('txtStrasse'),
        txtNr: document.getElementById('txtNr'),
        txtPLZ: document.getElementById('txtPLZ'),
        txtOrt: document.getElementById('txtOrt'),
        txtLand: document.getElementById('txtLand'),
        txtBundesland: document.getElementById('txtBundesland'),
        txtTelMobil: document.getElementById('txtTelMobil'),
        txtTelFestnetz: document.getElementById('txtTelFestnetz'),
        txtEmail: document.getElementById('txtEmail'),
        cboGeschlecht: document.getElementById('cboGeschlecht'),
        txtStaatsangehoerigkeit: document.getElementById('txtStaatsangehoerigkeit'),
        txtGebDatum: document.getElementById('txtGebDatum'),
        txtGebOrt: document.getElementById('txtGebOrt'),
        txtGebName: document.getElementById('txtGebName'),

        // Rechte Spalte
        txtKontoinhaber: document.getElementById('txtKontoinhaber'),
        txtBIC: document.getElementById('txtBIC'),
        txtIBAN: document.getElementById('txtIBAN'),
        cboLohngruppe: document.getElementById('cboLohngruppe'),
        txtBezuege: document.getElementById('txtBezuege'),
        txtSteuerID: document.getElementById('txtSteuerID'),
        txtSteuerID2: document.getElementById('txtSteuerID2'),
        cboTaetigkeit: document.getElementById('cboTaetigkeit'),
        txtKrankenkasse: document.getElementById('txtKrankenkasse'),
        txtSteuerklasse: document.getElementById('txtSteuerklasse'),
        txtUrlaubsanspruch: document.getElementById('txtUrlaubsanspruch'),
        txtStundenzahl: document.getElementById('txtStundenzahl'),
        chkRVBefreiung: document.getElementById('chkRVBefreiung'),
        chkBruttoStd: document.getElementById('chkBruttoStd'),
        chkAbrechnungEmail: document.getElementById('chkAbrechnungEmail'),
        txtLichtbild: document.getElementById('txtLichtbild'),

        // Suche/Filter
        txtSuche: document.getElementById('txtSuche'),
        cboFilter: document.getElementById('cboFilter'),
        cboZusatz: document.getElementById('cboZusatz'),

        // MA-Liste
        tblMAListe: document.getElementById('tblMAListe'),

        // Foto
        fotoContainer: document.getElementById('fotoContainer')
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

    // Action Buttons
    if (elements.btnNeuMA) elements.btnNeuMA.addEventListener('click', newRecord);
    if (elements.btnSpeichern) elements.btnSpeichern.addEventListener('click', saveRecord);
    if (elements.btnLoeschen) elements.btnLoeschen.addEventListener('click', deleteRecord);
    if (elements.btnZeitkonto) elements.btnZeitkonto.addEventListener('click', openZeitkonto);
    if (elements.btnMAAdresse) elements.btnMAAdresse.addEventListener('click', openMAAdresse);
    if (elements.btnMapsOeffnen) elements.btnMapsOeffnen.addEventListener('click', openMaps);
    if (elements.btnKoordinaten) elements.btnKoordinaten.addEventListener('click', getKoordinaten);
    if (elements.btnMATabelle) elements.btnMATabelle.addEventListener('click', openMATabelle);
    if (elements.btnListenDrucken) elements.btnListenDrucken.addEventListener('click', listenDrucken);
    if (elements.btnStundenlisteExportieren) elements.btnStundenlisteExportieren.addEventListener('click', stundenlisteExportieren);
    if (elements.btnSpiegelrechnung) elements.btnSpiegelrechnung.addEventListener('click', spiegelrechnungErstellen);

    // Suche
    if (elements.txtSuche) {
        elements.txtSuche.addEventListener('input', debounce(searchRecords, 300));
        elements.txtSuche.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') searchRecords();
        });
    }

    // Filter
    if (elements.cboFilter) elements.cboFilter.addEventListener('change', loadList);

    // Feldänderungen tracken
    const trackFields = [
        'txtNachname', 'txtVorname', 'txtStrasse', 'txtNr', 'txtPLZ', 'txtOrt',
        'txtTelMobil', 'txtTelFestnetz', 'txtEmail', 'txtKontoinhaber', 'txtIBAN',
        'txtSteuerID', 'txtKrankenkasse', 'chkAktiv', 'chkSubunternehmer'
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

    // MA-Liste Klick (wird in renderList() auch gesetzt)
    setupListClickHandler();

    // Auto-Speichern bei Feldverlust (optional)
    document.addEventListener('focusout', (e) => {
        if (state.isDirty && e.target.closest('.stammdaten-content')) {
            // Optional: Auto-Save implementieren
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
 * Mitarbeiterliste laden
 */
async function loadList() {
    setStatus('Lade Liste...');

    try {
        const params = {};
        if (state.nurAktive) params.aktiv = 1;
        if (elements.cboFilter?.value === 'unternehmer') params.subunternehmer = 1;

        const result = await Bridge.mitarbeiter.list(params);

        state.records = result.data || result || [];
        renderList();

        // Ersten Datensatz anzeigen
        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }

        setStatus(`${state.records.length} Mitarbeiter geladen`);

    } catch (error) {
        console.error('[Mitarbeiterstamm] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        // Fallback: Demo-Daten zeigen
        showDemoData();
    }
}

/**
 * Demo-Daten anzeigen wenn API nicht erreichbar
 */
function showDemoData() {
    state.records = [
        { MA_ID: 707, MA_Nachname: 'Alali', MA_Vorname: 'Ahmad', MA_Ort: 'Nürnberg', IstAktiv: true },
        { MA_ID: 708, MA_Nachname: 'Müller', MA_Vorname: 'Thomas', MA_Ort: 'Fürth', IstAktiv: true },
        { MA_ID: 709, MA_Nachname: 'Schmidt', MA_Vorname: 'Peter', MA_Ort: 'Erlangen', IstAktiv: true }
    ];
    renderList();
    if (state.records.length > 0) gotoRecord(0);
}

/**
 * Liste rendern
 */
function renderList() {
    const tbody = elements.tblMAListe?.querySelector('tbody');
    if (!tbody) return;

    if (state.records.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="3" style="text-align:center; color:#666; padding:20px;">
                    Keine Mitarbeiter gefunden
                </td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = state.records.map((rec, idx) => {
        const nachname = rec.MA_Nachname || rec.Nachname || '';
        const vorname = rec.MA_Vorname || rec.Vorname || '';
        const ort = rec.MA_Ort || rec.Ort || '';
        const selected = idx === state.currentIndex ? 'selected' : '';

        return `
            <tr data-index="${idx}" data-id="${rec.MA_ID}" class="${selected}">
                <td>${nachname}</td>
                <td>${vorname}</td>
                <td>${ort}</td>
            </tr>
        `;
    }).join('');

    setupListClickHandler();
}

/**
 * Click-Handler für MA-Liste
 */
function setupListClickHandler() {
    const tbody = elements.tblMAListe?.querySelector('tbody');
    if (!tbody) return;

    tbody.querySelectorAll('tr').forEach(row => {
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
        const detail = await Bridge.mitarbeiter.get(state.currentRecord.MA_ID);
        const data = detail.data || detail;
        displayRecord(data);
    } catch (error) {
        // Fallback: Nur Listendaten anzeigen
        displayRecord(state.currentRecord);
    }

    // Liste aktualisieren (Selection)
    const tbody = elements.tblMAListe?.querySelector('tbody');
    tbody?.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    // In Sicht scrollen
    const selectedRow = tbody?.querySelector('tr.selected');
    selectedRow?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

/**
 * Datensatz in Formular anzeigen
 */
function displayRecord(rec) {
    // Header-Infos
    if (elements.lblMAID) elements.lblMAID.textContent = rec.MA_ID || '';
    if (elements.lblNachname) elements.lblNachname.textContent = rec.MA_Nachname || rec.Nachname || '';
    if (elements.lblVorname) elements.lblVorname.textContent = rec.MA_Vorname || rec.Vorname || '';
    if (elements.lblKuerzel) elements.lblKuerzel.textContent = getKuerzel(rec);

    // Stammdaten-Felder
    setFieldValue('txtPersNr', rec.MA_ID || rec.PersNr);
    setFieldValue('txtLexNr', rec.LexNr);
    setCheckbox('chkAktiv', rec.IstAktiv ?? rec.MA_IstAktiv ?? true);
    setCheckbox('chkSubunternehmer', rec.IstSubunternehmer ?? false);
    setCheckbox('chkLexAktiv', rec.LexAktiv ?? true);

    setFieldValue('txtNachname', rec.MA_Nachname || rec.Nachname);
    setFieldValue('txtVorname', rec.MA_Vorname || rec.Vorname);
    setFieldValue('txtStrasse', rec.Strasse);
    setFieldValue('txtNr', rec.HausNr);
    setFieldValue('txtPLZ', rec.PLZ);
    setFieldValue('txtOrt', rec.Ort || rec.MA_Ort);
    setFieldValue('txtLand', rec.Land);
    setFieldValue('txtBundesland', rec.Bundesland);
    setFieldValue('txtTelMobil', rec.Tel_Mobil);
    setFieldValue('txtTelFestnetz', rec.Tel_Festnetz);
    setFieldValue('txtEmail', rec.Email);
    setFieldValue('cboGeschlecht', rec.Geschlecht);
    setFieldValue('txtStaatsangehoerigkeit', rec.Staatsangehoerigkeit);
    setFieldValue('txtGebDatum', formatDateDE(rec.GebDatum));
    setFieldValue('txtGebOrt', rec.GebOrt);
    setFieldValue('txtGebName', rec.GebName);

    // Rechte Spalte
    setFieldValue('txtKontoinhaber', rec.Kontoinhaber);
    setFieldValue('txtBIC', rec.BIC);
    setFieldValue('txtIBAN', rec.IBAN);
    setFieldValue('txtSteuerID', rec.SteuerID);
    setFieldValue('txtSteuerID2', rec.SteuerID2);
    setFieldValue('txtKrankenkasse', rec.Krankenkasse);
    setFieldValue('txtSteuerklasse', rec.Steuerklasse);
    setFieldValue('txtUrlaubsanspruch', rec.Urlaubsanspruch);
    setFieldValue('txtStundenzahl', rec.StundenzahlMonat);
    setCheckbox('chkRVBefreiung', rec.RVBefreiung ?? false);
    setCheckbox('chkBruttoStd', rec.BruttoStd ?? false);
    setCheckbox('chkAbrechnungEmail', rec.AbrechnungPerEmail ?? true);
    setFieldValue('txtLichtbild', rec.Lichtbild);

    // Foto laden
    loadFoto(rec.Lichtbild);
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
 * Kürzel generieren
 */
function getKuerzel(rec) {
    const nachname = rec.MA_Nachname || rec.Nachname || '';
    const vorname = rec.MA_Vorname || rec.Vorname || '';
    return (nachname.charAt(0) + vorname.charAt(0)).toUpperCase();
}

/**
 * Datum formatieren (ISO -> DE)
 */
function formatDateDE(value) {
    if (!value) return '';
    try {
        const d = new Date(value);
        if (isNaN(d)) return value;
        return d.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
    } catch {
        return value;
    }
}

/**
 * Foto laden
 */
function loadFoto(filename) {
    if (!elements.fotoContainer) return;

    if (filename) {
        // Hier könnte der tatsächliche Foto-Pfad stehen
        elements.fotoContainer.innerHTML = `<img src="../images/mitarbeiter/${filename}" alt="Foto" onerror="this.parentElement.innerHTML='<div class=\\'foto-placeholder\\'>Kein Foto</div>'">`;
    } else {
        elements.fotoContainer.innerHTML = '<div class="foto-placeholder">Foto</div>';
    }
}

/**
 * Formular leeren
 */
function clearForm() {
    state.currentRecord = null;
    state.currentIndex = -1;
    state.isDirty = false;

    // Alle Text-Felder leeren
    Object.keys(elements).forEach(key => {
        const el = elements[key];
        if (el && el.tagName === 'INPUT' && el.type !== 'checkbox') {
            el.value = '';
        } else if (el && el.tagName === 'INPUT' && el.type === 'checkbox') {
            el.checked = false;
        } else if (el && el.tagName === 'SELECT') {
            el.selectedIndex = 0;
        }
    });

    // Header leeren
    if (elements.lblMAID) elements.lblMAID.textContent = '-';
    if (elements.lblNachname) elements.lblNachname.textContent = '';
    if (elements.lblVorname) elements.lblVorname.textContent = '';
    if (elements.lblKuerzel) elements.lblKuerzel.textContent = '--';
}

/**
 * Neuer Datensatz
 */
function newRecord() {
    if (state.isDirty) {
        if (!confirm('Änderungen verwerfen?')) return;
    }

    clearForm();
    if (elements.txtNachname) elements.txtNachname.focus();
    setStatus('Neuer Mitarbeiter - Daten eingeben');
}

/**
 * Speichern
 */
async function saveRecord() {
    const nachname = elements.txtNachname?.value?.trim();
    const vorname = elements.txtVorname?.value?.trim();

    if (!nachname) {
        alert('Bitte Nachname eingeben!');
        if (elements.txtNachname) elements.txtNachname.focus();
        return;
    }

    const data = {
        MA_Nachname: nachname,
        MA_Vorname: vorname || '',
        Strasse: elements.txtStrasse?.value?.trim() || '',
        HausNr: elements.txtNr?.value?.trim() || '',
        PLZ: elements.txtPLZ?.value?.trim() || '',
        Ort: elements.txtOrt?.value?.trim() || '',
        Tel_Mobil: elements.txtTelMobil?.value?.trim() || '',
        Tel_Festnetz: elements.txtTelFestnetz?.value?.trim() || '',
        Email: elements.txtEmail?.value?.trim() || '',
        IstAktiv: elements.chkAktiv?.checked ? 1 : 0,
        IstSubunternehmer: elements.chkSubunternehmer?.checked ? 1 : 0,
        Kontoinhaber: elements.txtKontoinhaber?.value?.trim() || '',
        IBAN: elements.txtIBAN?.value?.trim() || '',
        SteuerID: elements.txtSteuerID?.value?.trim() || '',
        Krankenkasse: elements.txtKrankenkasse?.value?.trim() || ''
    };

    try {
        setStatus('Speichere...');

        const id = elements.txtPersNr?.value;

        if (id && state.currentRecord) {
            // Update
            await Bridge.execute('updateMitarbeiter', { id, ...data });
        } else {
            // Insert
            await Bridge.execute('createMitarbeiter', data);
        }

        state.isDirty = false;
        setStatus('Gespeichert');

        // Liste neu laden
        await loadList();

    } catch (error) {
        console.error('[Mitarbeiterstamm] Fehler beim Speichern:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Speichern: ' + error.message);
    }
}

/**
 * Löschen
 */
async function deleteRecord() {
    const id = elements.txtPersNr?.value;
    if (!id) {
        alert('Kein Datensatz ausgewählt');
        return;
    }

    const name = `${elements.txtNachname?.value || ''} ${elements.txtVorname?.value || ''}`.trim();
    if (!confirm(`Mitarbeiter "${name}" wirklich löschen?`)) return;

    try {
        setStatus('Lösche...');

        await Bridge.execute('deleteMitarbeiter', { id });

        setStatus('Gelöscht');

        // Liste neu laden
        await loadList();

    } catch (error) {
        console.error('[Mitarbeiterstamm] Fehler beim Löschen:', error);
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
        const result = await Bridge.mitarbeiter.list({ search: searchTerm });
        state.records = result.data || result || [];
        renderList();

        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }

        setStatus(`${state.records.length} Treffer`);

    } catch (error) {
        console.error('[Mitarbeiterstamm] Fehler bei Suche:', error);
        // Lokale Suche als Fallback
        const term = searchTerm.toLowerCase();
        const filtered = state.records.filter(r =>
            (r.MA_Nachname || '').toLowerCase().includes(term) ||
            (r.MA_Vorname || '').toLowerCase().includes(term) ||
            (r.MA_Ort || '').toLowerCase().includes(term)
        );
        state.records = filtered;
        renderList();
        if (filtered.length > 0) gotoRecord(0);
        setStatus(`${filtered.length} Treffer (lokal)`);
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

function openZeitkonto() {
    const id = state.currentRecord?.MA_ID;
    if (!id) {
        alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }
    window.open(`frm_MA_Zeitkonten.html?ma_id=${id}`, '_blank');
}

function openMAAdresse() {
    const id = state.currentRecord?.MA_ID;
    if (!id) {
        alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }
    // Modal oder separate Seite öffnen
    alert('MA Adressen: Funktion in Entwicklung');
}

function openMaps() {
    const strasse = elements.txtStrasse?.value || '';
    const nr = elements.txtNr?.value || '';
    const plz = elements.txtPLZ?.value || '';
    const ort = elements.txtOrt?.value || '';

    if (!ort) {
        alert('Keine Adresse vorhanden');
        return;
    }

    const adresse = encodeURIComponent(`${strasse} ${nr}, ${plz} ${ort}`);
    window.open(`https://www.google.com/maps/search/${adresse}`, '_blank');
}

function getKoordinaten() {
    const strasse = elements.txtStrasse?.value || '';
    const nr = elements.txtNr?.value || '';
    const plz = elements.txtPLZ?.value || '';
    const ort = elements.txtOrt?.value || '';

    if (!ort) {
        alert('Keine Adresse vorhanden');
        return;
    }

    setStatus('Ermittle Koordinaten...');
    // Hier könnte Geocoding-API aufgerufen werden
    alert('Koordinaten-Ermittlung: Funktion in Entwicklung\n\nAdresse: ' + `${strasse} ${nr}, ${plz} ${ort}`);
}

function openMATabelle() {
    // Tabellenansicht aller Mitarbeiter
    alert('Mitarbeiter-Tabelle: Funktion in Entwicklung');
}

function listenDrucken() {
    window.print();
}

function stundenlisteExportieren() {
    const id = state.currentRecord?.MA_ID;
    if (!id) {
        alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }

    setStatus('Exportiere Stundenliste...');
    // Export-Logik
    Bridge.lohn.stundenExport({ ma_id: id })
        .then(result => {
            setStatus('Export abgeschlossen');
            alert('Stundenliste exportiert');
        })
        .catch(error => {
            setStatus('Export-Fehler');
            alert('Fehler beim Export: ' + error.message);
        });
}

function spiegelrechnungErstellen() {
    const id = state.currentRecord?.MA_ID;
    if (!id) {
        alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }
    alert('Spiegelrechnung: Funktion in Entwicklung');
}

// Init bei DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}

// Globaler Zugriff
window.MitarbeiterStamm = {
    loadList,
    gotoRecord,
    newRecord,
    saveRecord,
    deleteRecord,
    searchRecords
};
