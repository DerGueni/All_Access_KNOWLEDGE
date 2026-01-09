/**
 * frm_MA_Mitarbeiterstamm.logic.js
 * Logik für Mitarbeiterstamm-Formular
 * REST-API Anbindung an localhost:5000
 */

(function() {
'use strict';

// Bridge ist global verfuegbar via webview2-bridge.js
const Bridge = window.Bridge;

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
const fieldCache = {};

function getField(fieldName) {
    if (fieldCache[fieldName]) return fieldCache[fieldName];
    const selector = `[data-field="${fieldName}"]`;
    const el = document.querySelector(selector);
    fieldCache[fieldName] = el;
    return el;
}

function setFieldValue(fieldName, value) {
    const el = getField(fieldName);
    if (el) {
        el.value = value ?? '';
    }
}

function setCheckbox(fieldName, checked) {
    const el = getField(fieldName);
    if (el) {
        el.checked = !!checked;
    }
}

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
        displayNachname: document.getElementById('displayNachname'),
        displayVorname: document.getElementById('displayVorname'),

        // Liste & Suche (HTML: maListTable)
        tblMAListe: document.getElementById('maListTable'),
        searchInput: document.getElementById('searchInput'),
        filterSelect: document.getElementById('filterSelect'),

        // Foto
        fotoContainer: document.getElementById('fotoContainer'),

        // Status timestamps
        erstelltAm: document.getElementById('erstelltAm'),
        erstelltVon: document.getElementById('erstelltVon'),
        geaendertAm: document.getElementById('geaendertAm'),
        geaendertVon: document.getElementById('geaendertVon')
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
    if (elements.searchInput) {
        elements.searchInput.addEventListener('input', debounce(searchRecords, 300));
        elements.searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') searchRecords();
        });
    }

    // Filter
    if (elements.filterSelect) elements.filterSelect.addEventListener('change', loadList);

    // Feldänderungen tracken
    const trackFields = [
        'Nachname', 'Vorname', 'Strasse', 'Nr', 'PLZ', 'Ort',
        'Tel_Mobil', 'Tel_Festnetz', 'Email', 'Kontoinhaber', 'IBAN',
        'SteuerNr', 'KV_Kasse', 'IstAktiv', 'IstSubunternehmer', 'Lex_Aktiv'
    ];
    trackFields.forEach(field => {
        const el = getField(field);
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
 *
 * Standard-Filter: Nur Festangestellte (3) und Minijobber (5)
 * Sortierung: Alphabetisch nach Nachname (vom API-Server)
 * Auto-Load: Erster Mitarbeiter wird automatisch angezeigt
 */
async function loadList() {
    setStatus('Lade Liste...');

    try {
        // Parameter fuer API-Aufruf
        const params = {
            aktiv: state.nurAktive ? 1 : 0
        };

        // Filter-Optionen aus Dropdown (HTML: filterSelect)
        const filterValue = elements.filterSelect?.value || 'standard';
        console.log('[MA-Logic] Filter-Wert:', filterValue);

        switch (filterValue) {
            case 'standard':
                // Default: Festangestellte (3) + Minijobber (5)
                // API wendet diesen Filter automatisch an wenn kein anstellung-Param
                break;
            case 'fest':
                params.anstellung = '3';  // Nur Festangestellte
                break;
            case 'mini':
                params.anstellung = '5';  // Nur Minijobber
                break;
            case 'alle':
                params.filter_anstellung = 'false';  // Alle Anstellungsarten
                break;
            default:
                // Bei unbekanntem Wert: Standard-Filter nutzen
                break;
        }

        console.log('[MA-Logic] Calling Bridge.mitarbeiter.list with params:', params);
        const result = await Bridge.mitarbeiter.list(params);
        console.log('[MA-Logic] Bridge result:', result);
        console.log('[MA-Logic] result.data type:', typeof result?.data, 'isArray:', Array.isArray(result?.data));

        state.records = result.data || result || [];
        console.log('[MA-Logic] state.records length:', state.records.length);

        // Daten sind bereits alphabetisch sortiert vom API-Server
        // Aber zur Sicherheit nochmal client-seitig sortieren
        state.records.sort((a, b) => {
            const nachnameA = (a.Nachname || a.MA_Nachname || '').toLowerCase();
            const nachnameB = (b.Nachname || b.MA_Nachname || '').toLowerCase();
            if (nachnameA !== nachnameB) return nachnameA.localeCompare(nachnameB, 'de');
            const vornameA = (a.Vorname || a.MA_Vorname || '').toLowerCase();
            const vornameB = (b.Vorname || b.MA_Vorname || '').toLowerCase();
            return vornameA.localeCompare(vornameB, 'de');
        });

        if (state.records.length > 0) {
            console.log('[MA-Logic] First record (alphabetisch erster MA):', state.records[0]);
            console.log('[MA-Logic] First record keys:', Object.keys(state.records[0]));
        }

        renderList();

        // SOFORT ersten Datensatz anzeigen (alphabetisch erster Mitarbeiter)
        if (state.records.length > 0) {
            await gotoRecord(0);
            console.log('[MA-Logic] Auto-Load: Erster MA geladen:', state.currentRecord?.Nachname);
        } else {
            clearForm();
        }

        setStatus(`${state.records.length} Mitarbeiter geladen (Fest/Mini)`);

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
    console.log('[MA-Logic] renderList called, records:', state.records.length);
    const tbody = elements.tblMAListe?.querySelector('tbody');
    console.log('[MA-Logic] tbody element:', tbody);
    if (!tbody) {
        console.error('[MA-Logic] tbody not found!');
        return;
    }

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

    // Debug: Check first few records
    console.log('[MA-Logic] Rendering first 3 records:');
    state.records.slice(0, 3).forEach((rec, i) => {
        console.log(`  [${i}] Nachname:`, rec.Nachname, 'MA_Nachname:', rec.MA_Nachname);
    });

    tbody.innerHTML = state.records.map((rec, idx) => {
        const nachname = rec.MA_Nachname || rec.Nachname || '';
        const vorname = rec.MA_Vorname || rec.Vorname || '';
        const ort = rec.MA_Ort || rec.Ort || '';
        const selected = idx === state.currentIndex ? 'selected' : '';
        const isAktiv = rec.IstAktiv !== false && rec.IstAktiv !== 0;

        // Bedingte Formatierung: MA inaktiv → rote Schrift
        const inaktivStyle = !isAktiv ? 'color: #cc0000;' : '';
        const inaktivTitle = !isAktiv ? 'Mitarbeiter inaktiv' : '';

        return `
            <tr data-index="${idx}" data-id="${rec.MA_ID || rec.ID}" class="${selected}" style="${inaktivStyle}" title="${inaktivTitle}">
                <td>${nachname}</td>
                <td>${vorname}</td>
                <td>${ort}</td>
            </tr>
        `;
    }).join('');

    console.log('[MA-Logic] Rendered rows:', tbody.querySelectorAll('tr').length);

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
        // API gibt ID zurueck, nicht MA_ID
        const maId = state.currentRecord.ID || state.currentRecord.MA_ID;
        console.log('[MA-Logic] Loading details for MA_ID:', maId);
        const detail = await Bridge.mitarbeiter.get(maId);
        console.log('[MA-Logic] API Response:', JSON.stringify(detail).substring(0, 200));
        // API gibt {data: {mitarbeiter: {...}, nicht_verfuegbar: [...]}} zurueck
        let data = detail;
        if (detail.data) data = detail.data;
        if (data.mitarbeiter) data = data.mitarbeiter;
        console.log('[MA-Logic] Extracted data:', JSON.stringify(data).substring(0, 200));
        displayRecord(data);
    } catch (error) {
        console.error('[MA-Logic] Detail load error:', error);
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
    // API gibt ID zurueck, nicht MA_ID - beide Varianten unterstuetzen
    const maId = rec.ID || rec.MA_ID || '';
    const nachname = rec.Nachname || rec.MA_Nachname || '';
    const vorname = rec.Vorname || rec.MA_Vorname || '';
    const ort = rec.Ort || rec.MA_Ort || '';

    // Header-Infos
    if (elements.lblMAID) elements.lblMAID.textContent = maId;
    if (elements.lblNachname) elements.lblNachname.textContent = nachname;
    if (elements.lblVorname) elements.lblVorname.textContent = vorname;
    if (elements.lblKuerzel) elements.lblKuerzel.textContent = getKuerzel(rec);
    if (elements.displayNachname) elements.displayNachname.textContent = nachname || '-';
    if (elements.displayVorname) elements.displayVorname.textContent = vorname || '-';

    // Stammdaten-Felder - API Feldnamen direkt verwenden
    setFieldValue('ID', maId);
    setFieldValue('LEXWare_ID', rec.LEXWare_ID);
    setCheckbox('IstAktiv', rec.IstAktiv ?? true);
    setCheckbox('IstSubunternehmer', rec.IstSubunternehmer ?? false);
    setCheckbox('Lex_Aktiv', rec.Lex_Aktiv ?? true);

    setFieldValue('Nachname', nachname);
    setFieldValue('Vorname', vorname);
    setFieldValue('Strasse', rec.Strasse);
    setFieldValue('Nr', rec.Nr);  // API: Nr (nicht HausNr)
    setFieldValue('PLZ', rec.PLZ);
    setFieldValue('Ort', ort);
    setFieldValue('Land', rec.Land);
    setFieldValue('Bundesland', rec.Bundesland);
    setFieldValue('Tel_Mobil', rec.Tel_Mobil);
    setFieldValue('Tel_Festnetz', rec.Tel_Festnetz);
    setFieldValue('Email', rec.Email);
    setFieldValue('Geschlecht', rec.Geschlecht);
    setFieldValue('Staatsang', rec.Staatsang);  // API: Staatsang (nicht Staatsangehoerigkeit)
    setFieldValue('Geb_Dat', formatDateISO(rec.Geb_Dat));  // Date-Input braucht ISO-Format
    setFieldValue('Geb_Ort', rec.Geb_Ort);  // API: Geb_Ort (nicht GebOrt)
    setFieldValue('Geb_Name', rec.Geb_Name);  // API: Geb_Name (nicht GebName)

    // Mittlere Spalte - Beschäftigung & Ausweis
    setFieldValue('Eintrittsdatum', formatDateISO(rec.Eintrittsdatum));
    setFieldValue('Austrittsdatum', formatDateISO(rec.Austrittsdatum));
    setFieldValue('Anstellungsart', rec.Anstellungsart_ID);
    setFieldValue('Kleidergroesse', rec.Kleidergroesse);
    setCheckbox('Fahrerlaubnis', rec.Fahrerlaubnis);
    setCheckbox('Eigener_PKW', rec.Eigener_PKW);
    setFieldValue('DienstausweisNr', rec.DienstausweisNr);
    setFieldValue('Ausweis_Endedatum', formatDateISO(rec.Ausweis_Endedatum));
    setFieldValue('Ausweis_Funktion', rec.AUsweis_Funktion);  // API hat Typo: AUsweis_Funktion
    setFieldValue('Letzte_Ueberpr_OA', formatDateISO(rec.Datum_Pruefung));  // API: Datum_Pruefung
    setFieldValue('Personalausweis_Nr', rec.Bewacher_ID);  // Personal-ID
    setFieldValue('DFB_Epin', rec.Epin_DFB);
    setCheckbox('DFB_Modul1', rec.Modul1_DFB);
    setFieldValue('Bewacher_ID', rec.Bewacher_ID);
    setFieldValue('Amt_Pruefung', rec.Amt_Pruefung);

    // Rechte Spalte
    setFieldValue('Kontoinhaber', rec.Kontoinhaber);
    setFieldValue('BIC', rec.BIC);
    setFieldValue('IBAN', rec.IBAN);
    setFieldValue('SteuerNr', rec.SteuerNr);
    setFieldValue('Steuerklasse', rec.Steuerklasse);
    setFieldValue('KV_Kasse', rec.KV_Kasse);  // API: KV_Kasse (nicht Krankenkasse)
    setFieldValue('Urlaubsanspr_pro_Jahr', rec.Urlaubsanspr_pro_Jahr);  // API: exakt dieser Name
    setFieldValue('Stundenzahl', rec.StundenZahlMax);  // API: StundenZahlMax
    setCheckbox('eMail_Abrechnung', rec.eMail_Abrechnung ?? true);  // API: eMail_Abrechnung
    setFieldValue('Lichtbild', rec.tblBilddatei);  // API: tblBilddatei

    // Foto laden - API: tblBilddatei
    loadFoto(rec.tblBilddatei);
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
 * Datum formatieren (ISO -> DE) für Anzeige
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
 * Datum formatieren für input[type="date"] (erwartet YYYY-MM-DD)
 */
function formatDateISO(value) {
    if (!value) return '';
    try {
        const d = new Date(value);
        if (isNaN(d)) return '';
        // Format: YYYY-MM-DD
        return d.toISOString().split('T')[0];
    } catch {
        return '';
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
    document.querySelectorAll('[data-field]').forEach(el => {
        if (el.tagName === 'INPUT') {
            if (el.type === 'checkbox') {
                el.checked = false;
            } else {
                el.value = '';
            }
        } else if (el.tagName === 'SELECT') {
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
    const nachnameField = getField('Nachname');
    if (nachnameField) nachnameField.focus();
    setStatus('Neuer Mitarbeiter - Daten eingeben');
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

    const nachname = getField('Nachname')?.value?.trim();
    const vorname = getField('Vorname')?.value?.trim();

    // Feldnamen muessen EXAKT mit API-allowed-Liste uebereinstimmen!
    const data = {
        Nachname: nachname,
        Vorname: vorname || '',
        Strasse: getField('Strasse')?.value?.trim() || '',
        Nr: getField('Nr')?.value?.trim() || '',
        PLZ: getField('PLZ')?.value?.trim() || '',
        Ort: getField('Ort')?.value?.trim() || '',
        Tel_Mobil: getField('Tel_Mobil')?.value?.trim() || '',
        Tel_Festnetz: getField('Tel_Festnetz')?.value?.trim() || '',
        Email: getField('Email')?.value?.trim() || '',
        IstAktiv: getField('IstAktiv')?.checked ? 1 : 0,
        IstSubunternehmer: getField('IstSubunternehmer')?.checked ? 1 : 0,
        Kontoinhaber: getField('Kontoinhaber')?.value?.trim() || '',
        IBAN: getField('IBAN')?.value?.trim() || '',
        SteuerNr: getField('SteuerNr')?.value?.trim() || '',
        KV_Kasse: getField('KV_Kasse')?.value?.trim() || '',
        Geschlecht: getField('Geschlecht')?.value || ''
    };

    try {
        setStatus('Speichere...');

        const id = getField('ID')?.value;

        let result;
        if (id && state.currentRecord) {
            // Update
            console.log('[MA-Logic] Speichere Update fuer ID:', id, 'Data:', JSON.stringify(data));
            result = await Bridge.execute('updateMitarbeiter', { id, ...data });
        } else {
            // Insert
            console.log('[MA-Logic] Erstelle neuen Mitarbeiter:', JSON.stringify(data));
            result = await Bridge.execute('createMitarbeiter', data);
        }

        console.log('[MA-Logic] Speichern Ergebnis:', result);

        // Pruefen ob API erfolgreich war
        if (result && result.success === false) {
            throw new Error(result.error || 'API-Fehler');
        }

        state.isDirty = false;
        setStatus('Gespeichert');
        if (typeof Toast !== 'undefined') Toast.success('Erfolgreich gespeichert!');

        // Liste neu laden
        await loadList();

    } catch (error) {
        console.error('[Mitarbeiterstamm] Fehler beim Speichern:', error);
        setStatus('Fehler: ' + error.message);
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Speichern: ' + error.message);
        else alert('Fehler beim Speichern: ' + error.message);
    }
}

/**
 * Löschen
 */
async function deleteRecord() {
    const id = getField('ID')?.value;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Kein Datensatz ausgewählt');
        else alert('Kein Datensatz ausgewählt');
        return;
    }

    const name = `${getField('Nachname')?.value || ''} ${getField('Vorname')?.value || ''}`.trim();
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
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Löschen: ' + error.message);
        else alert('Fehler beim Löschen: ' + error.message);
    }
}

/**
 * Suchen
 */
async function searchRecords() {
    const searchTerm = elements.searchInput?.value?.trim() || '';

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
    const id = getField('ID')?.value || state.currentRecord?.MA_ID;
    if (!id) {
        alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }
    window.open(`frm_MA_Zeitkonten.html?ma_id=${id}`, '_blank');
}

function openMAAdresse() {
    const id = state.currentRecord?.MA_ID;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Mitarbeiter auswählen');
        else alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }
    // Öffne MA-Adressen Formular mit MA_ID
    const url = `frm_MA_Adressen.html?ma_id=${id}`;
    window.open(url, 'MA_Adressen', 'width=600,height=400,menubar=no,toolbar=no');
}

function openMaps() {
    const strasse = getField('Strasse')?.value || '';
    const nr = getField('Nr')?.value || '';
    const plz = getField('PLZ')?.value || '';
    const ort = getField('Ort')?.value || '';

    if (!ort) {
        alert('Keine Adresse vorhanden');
        return;
    }

    const adresse = encodeURIComponent(`${strasse} ${nr}, ${plz} ${ort}`);
    window.open(`https://www.google.com/maps/search/${adresse}`, '_blank');
}

async function getKoordinaten() {
    const strasse = getField('Strasse')?.value || '';
    const nr = getField('Nr')?.value || '';
    const plz = getField('PLZ')?.value || '';
    const ort = getField('Ort')?.value || '';

    if (!ort) {
        if (typeof Toast !== 'undefined') Toast.warning('Keine Adresse vorhanden');
        else alert('Keine Adresse vorhanden');
        return;
    }

    setStatus('Ermittle Koordinaten...');
    const adresse = `${strasse} ${nr}, ${plz} ${ort}`;

    try {
        // Nutze Nominatim OpenStreetMap Geocoding (kostenlos)
        const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(adresse)}`;
        const response = await fetch(url, { headers: { 'User-Agent': 'ConsysApp/1.0' } });
        const data = await response.json();

        if (data && data.length > 0) {
            const lat = data[0].lat;
            const lon = data[0].lon;

            // Koordinaten in Felder eintragen falls vorhanden
            const latField = getField('Latitude') || getField('MA_Latitude');
            const lonField = getField('Longitude') || getField('MA_Longitude');
            if (latField) latField.value = lat;
            if (lonField) lonField.value = lon;

            setStatus(`Koordinaten: ${lat}, ${lon}`);
            if (typeof Toast !== 'undefined') {
                Toast.success(`Koordinaten ermittelt: ${lat}, ${lon}`);
            } else {
                alert(`Koordinaten ermittelt:\nBreite: ${lat}\nLänge: ${lon}`);
            }
        } else {
            setStatus('Keine Koordinaten gefunden');
            if (typeof Toast !== 'undefined') Toast.warning('Keine Koordinaten für diese Adresse gefunden');
            else alert('Keine Koordinaten für diese Adresse gefunden');
        }
    } catch (error) {
        setStatus('Fehler bei Koordinatenermittlung');
        console.error('Geocoding error:', error);
        if (typeof Toast !== 'undefined') Toast.error('Fehler bei der Koordinatenermittlung');
        else alert('Fehler bei der Koordinatenermittlung: ' + error.message);
    }
}

function openMATabelle() {
    // Tabellenansicht aller Mitarbeiter öffnen
    const url = 'frm_MA_Tabelle.html';
    window.open(url, 'MA_Tabelle', 'width=1000,height=700,menubar=no,toolbar=no,scrollbars=yes');
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

async function spiegelrechnungErstellen() {
    const id = state.currentRecord?.MA_ID;
    if (!id) {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte zuerst einen Mitarbeiter auswählen');
        else alert('Bitte zuerst einen Mitarbeiter auswählen');
        return;
    }

    // Bestätigung einholen
    const confirmed = typeof Toast !== 'undefined'
        ? await Toast.confirm('Spiegelrechnung für diesen Mitarbeiter erstellen?')
        : confirm('Spiegelrechnung für diesen Mitarbeiter erstellen?');

    if (!confirmed) return;

    setStatus('Erstelle Spiegelrechnung...');
    try {
        const result = await Bridge.execute('createSpiegelrechnung', { ma_id: id });
        if (result && result.success) {
            setStatus('Spiegelrechnung erstellt');
            if (typeof Toast !== 'undefined') {
                Toast.success('Spiegelrechnung erfolgreich erstellt');
            } else {
                alert('Spiegelrechnung erfolgreich erstellt');
            }
            // Optional: Rechnung öffnen
            if (result.rechnung_id) {
                window.open(`frm_Rechnung.html?id=${result.rechnung_id}`, '_blank');
            }
        } else {
            throw new Error(result?.message || 'Unbekannter Fehler');
        }
    } catch (error) {
        setStatus('Fehler bei Spiegelrechnung');
        console.error('Spiegelrechnung error:', error);
        if (typeof Toast !== 'undefined') Toast.error('Fehler: ' + error.message);
        else alert('Fehler bei Spiegelrechnung: ' + error.message);
    }
}

// ============================================
// FEHLENDE EVENT-HANDLER (Access-Sync)
// ============================================

/**
 * Access: MANameEingabe_AfterUpdate - Suche synchronisieren
 */
function MANameEingabe_AfterUpdate() {
    const searchTerm = elements.searchInput?.value?.trim() || '';
    if (searchTerm) {
        searchRecords();
    }
}

/**
 * Access: cboFilterAuftrag_AfterUpdate - Auftragsfilter
 * @param {number} auftragId - Die Auftrags-ID zum Filtern
 */
function cboFilterAuftrag_AfterUpdate(auftragId) {
    console.log('[Access-Sync] cboFilterAuftrag_AfterUpdate - Auftrags-Filter:', auftragId);
    if (auftragId && state.currentRecord) {
        // Filtert Einsaetze nach Auftrag
        Bridge.execute('getEinsaetze', {
            ma_id: state.currentRecord.MA_ID,
            auftrag_id: auftragId
        }).then(result => {
            const records = result.data || result || [];
            renderEinsaetze(records);
        }).catch(err => {
            console.error('[cboFilterAuftrag] Fehler:', err);
        });
    }
}

/**
 * Access: cboIDSuche_AfterUpdate - MA-ID Suche
 * @param {number} maId - Die gesuchte Mitarbeiter-ID
 */
function cboIDSuche_AfterUpdate(maId) {
    console.log('[Access-Sync] cboIDSuche_AfterUpdate - MA-ID Suche:', maId);
    if (maId) {
        const parsedId = parseInt(maId);
        const index = state.records.findIndex(m => (m.MA_ID || m.ID) === parsedId);
        if (index >= 0) {
            gotoRecord(index);
        } else {
            // Direkt laden via Bridge
            Bridge.mitarbeiter.get(parsedId).then(result => {
                const data = result.data || result;
                if (data) {
                    state.records.push(data);
                    gotoRecord(state.records.length - 1);
                } else {
                    console.warn('[cboIDSuche] MA-ID nicht gefunden:', maId);
                }
            }).catch(err => {
                console.error('[cboIDSuche] Fehler:', err);
            });
        }
    }
}

/**
 * Access: txRechSub_AfterUpdate - Sub-Rechnungen Filter
 * @param {string} rechnungsNr - Die Rechnungsnummer zum Filtern
 */
function txRechSub_AfterUpdate(rechnungsNr) {
    console.log('[Access-Sync] txRechSub_AfterUpdate - Rechnungs-Filter:', rechnungsNr);
    if (rechnungsNr && state.currentRecord) {
        Bridge.execute('getSubrechnungen', {
            ma_id: state.currentRecord.MA_ID || state.currentRecord.ID,
            rechnung_nr: rechnungsNr
        }).then(result => {
            const records = result.data || result || [];
            renderSubrechnungen(records);
        }).catch(err => {
            console.error('[txRechSub] Fehler:', err);
        });
    }
}

/**
 * Rendert Einsaetze-Tabelle (Hilffunktion fuer cboFilterAuftrag)
 * WICHTIG: data-va-id wird für lst_Zuo_DblClick benötigt
 */
function renderEinsaetze(records) {
    const tbody = document.getElementById('einsaetzeTbody');
    if (!tbody) return;

    tbody.innerHTML = '';
    if (!records || records.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#666; padding:10px;">Keine Einsaetze gefunden</td></tr>';
        return;
    }

    records.forEach(e => {
        const tr = document.createElement('tr');
        // VA_ID für DblClick-Handler (lst_Zuo_DblClick) speichern
        const vaId = e.VA_ID || e.Auftrag_ID || '';
        tr.dataset.vaId = vaId;
        tr.dataset.id = vaId;
        tr.style.cursor = 'pointer';  // Hinweis auf Klickbarkeit
        tr.title = vaId ? 'Doppelklick öffnet Auftrag' : '';

        tr.innerHTML = `
            <td>${formatDateDE(e.Datum || e.VADatum)}</td>
            <td>${e.Auftrag || ''}</td>
            <td>${e.Objekt || ''}</td>
            <td>${e.Von || e.VA_Start || ''}</td>
            <td>${e.Bis || e.VA_Ende || ''}</td>
            <td>${e.Stunden || ''}</td>
        `;
        tbody.appendChild(tr);
    });
}

/**
 * Rendert Subrechnungen-Tabelle (Hilfsfunktion fuer txRechSub)
 */
function renderSubrechnungen(records) {
    // Falls ein Subrechnungen-Container existiert
    const container = document.getElementById('subrechnungenTbody');
    if (!container) {
        console.log('[renderSubrechnungen] Container nicht gefunden');
        return;
    }

    container.innerHTML = '';
    if (!records || records.length === 0) {
        container.innerHTML = '<tr><td colspan="5" style="text-align:center; color:#666; padding:10px;">Keine Rechnungen gefunden</td></tr>';
        return;
    }

    records.forEach(r => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${r.RechnungsNr || ''}</td>
            <td>${formatDateDE(r.Datum)}</td>
            <td>${r.Betrag || ''}</td>
            <td>${r.Status || ''}</td>
            <td>${r.Bemerkung || ''}</td>
        `;
        container.appendChild(tr);
    });
}

// ============================================
// DBLCLICK EVENTS (Access-Parität)
// ============================================

/**
 * Access: lst_Zuo_DblClick - Öffnet Auftragstamm beim Doppelklick auf Einsatz
 * VBA Original: DoCmd.OpenForm "frm_va_Auftragstamm", , , "VA_ID=" & lst_Zuo.Column(5)
 */
function setupEinsaetzeDblClick() {
    const einsaetzeTbody = document.getElementById('einsaetzeTbody');
    if (!einsaetzeTbody) return;

    einsaetzeTbody.addEventListener('dblclick', (e) => {
        const row = e.target.closest('tr');
        if (!row) return;

        const vaId = row.dataset.vaId || row.dataset.id;
        if (!vaId) {
            console.warn('[lst_Zuo_DblClick] Keine VA_ID in Zeile gefunden');
            return;
        }

        console.log('[lst_Zuo_DblClick] Öffne Auftragstamm mit VA_ID:', vaId);

        // Öffne Auftragstamm (wie Access: DoCmd.OpenForm "frm_va_Auftragstamm")
        if (window.parent?.ConsysShell?.showForm) {
            localStorage.setItem('consec_va_id', String(vaId));
            window.parent.ConsysShell.showForm('auftragstamm');
        } else {
            window.open(`frm_va_Auftragstamm.html?va_id=${vaId}`, '_blank');
        }
    });

    console.log('[frm_MA_Mitarbeiterstamm] lst_Zuo_DblClick Handler registriert');
}

/**
 * Access: Quick Info Einsätze DblClick
 */
function setupQuickInfoEinsaetzeDblClick() {
    const qiEinsaetzeTbody = document.getElementById('qiEinsaetzeTbody');
    if (!qiEinsaetzeTbody) return;

    qiEinsaetzeTbody.addEventListener('dblclick', (e) => {
        const row = e.target.closest('tr');
        if (!row) return;

        const vaId = row.dataset.vaId || row.dataset.id;
        if (vaId) {
            console.log('[QuickInfo DblClick] Öffne Auftragstamm mit VA_ID:', vaId);
            if (window.parent?.ConsysShell?.showForm) {
                localStorage.setItem('consec_va_id', String(vaId));
                window.parent.ConsysShell.showForm('auftragstamm');
            } else {
                window.open(`frm_va_Auftragstamm.html?va_id=${vaId}`, '_blank');
            }
        }
    });
}

// ============================================
// BEDINGTE FORMATIERUNG (Access-Parität)
// ============================================

/**
 * Access: MA inaktiv → rote Schrift
 * Wendet bedingte Formatierung auf MA-Liste an
 */
function applyListConditionalFormatting() {
    const tbody = elements.tblMAListe?.querySelector('tbody');
    if (!tbody) return;

    tbody.querySelectorAll('tr').forEach(row => {
        const idx = parseInt(row.dataset.index);
        if (isNaN(idx) || !state.records[idx]) return;

        const rec = state.records[idx];
        const isAktiv = rec.IstAktiv !== false && rec.IstAktiv !== 0;

        // MA inaktiv → rote Schrift (Access: FormatCondition ForeColor = 255)
        if (!isAktiv) {
            row.style.color = '#cc0000';
            row.title = 'Mitarbeiter inaktiv';
        } else {
            row.style.color = '';
            row.title = '';
        }
    });
}

// Init bei DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        init();
        setupEinsaetzeDblClick();
        setupQuickInfoEinsaetzeDblClick();
    });
} else {
    init();
    setupEinsaetzeDblClick();
    setupQuickInfoEinsaetzeDblClick();
}

// Globaler Zugriff
window.MitarbeiterStamm = {
    loadList,
    gotoRecord,
    newRecord,
    saveRecord,
    deleteRecord,
    searchRecords,
    // Fehlende Event-Handler (Access-Sync)
    MANameEingabe_AfterUpdate,
    cboFilterAuftrag_AfterUpdate,
    cboIDSuche_AfterUpdate,
    txRechSub_AfterUpdate
};

// ============ FUNCTION ALIASES (fuer onclick-Handler Kompatibilitaet) ============

// === Navigation ===
window.navFirst = function() { gotoRecord(0); };
window.navPrev = function() { if (state.currentIndex > 0) gotoRecord(state.currentIndex - 1); };
window.navNext = function() { if (state.currentIndex < state.records.length - 1) gotoRecord(state.currentIndex + 1); };
window.navLast = function() { gotoRecord(state.records.length - 1); };

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

// === Mitarbeiter-Aktionen ===
window.neuerMitarbeiter = typeof newRecord === 'function' ? newRecord : function() {
    if (typeof Toast !== 'undefined') Toast.info('Neuer Mitarbeiter wird angelegt...');
    else alert('Neuer Mitarbeiter wird angelegt...');
};
window.mitarbeiterLöschen = typeof deleteRecord === 'function' ? deleteRecord : function() {
    if (typeof Toast !== 'undefined') Toast.warning('Loeschen nicht verfuegbar');
    else alert('Loeschen nicht verfuegbar');
};

// === Externe Formulare oeffnen ===
window.openMAAdressen = function() {
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_MA_Adressen', ma_id: state.currentRecord?.ID });
    } else {
        window.open('frm_MA_Adressen.html?ma_id=' + (state.currentRecord?.ID || ''), '_blank');
    }
};
window.openZeitkonto = function() {
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_MA_Zeitkonten', ma_id: state.currentRecord?.ID });
    } else {
        window.open('frm_MA_Zeitkonten.html?ma_id=' + (state.currentRecord?.ID || ''), '_blank');
    }
};
window.openDienstplan = function() {
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_DP_Dienstplan_MA', ma_id: state.currentRecord?.ID });
    } else {
        window.open('frm_DP_Dienstplan_MA.html?ma_id=' + (state.currentRecord?.ID || ''), '_blank');
    }
};
window.openEinsatzübersicht = function() {
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_Einsatzuebersicht', ma_id: state.currentRecord?.ID });
    } else {
        window.open('frm_Einsatzuebersicht.html?ma_id=' + (state.currentRecord?.ID || ''), '_blank');
    }
};
window.openMaps = function() {
    const rec = state.currentRecord;
    if (rec && (rec.Strasse || rec.PLZ || rec.Ort)) {
        const addr = encodeURIComponent([rec.Strasse, rec.PLZ, rec.Ort].filter(Boolean).join(', '));
        window.open('https://www.google.com/maps/search/' + addr, '_blank');
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Keine Adressdaten vorhanden');
        else alert('Keine Adressdaten vorhanden');
    }
};
window.mitarbeiterTabelle = function() {
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('openForm', { form: 'frm_MA_Tabelle' });
    } else {
        window.open('frm_MA_Tabelle.html', '_blank');
    }
};

// === Einsaetze/Listen ===
window.einsaetzeUebertragen = function(typ) {
    console.log('[einsaetzeUebertragen] Typ:', typ, 'MA:', state.currentRecord?.ID);
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('einsaetzeUebertragen', { typ: typ, ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Einsaetze ' + typ + ' werden uebertragen...');
        else alert('Einsaetze ' + typ + ' werden uebertragen...');
    }
};
window.listenDrucken = function() {
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('listenDrucken', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Listen werden gedruckt...');
        else alert('Listen werden gedruckt...');
    }
};
window.loadEinsaetze = function() {
    console.log('[loadEinsaetze] MA:', state.currentRecord?.ID);
    // Wird in cboFilterAuftrag_AfterUpdate geladen
    cboFilterAuftrag_AfterUpdate('');
};

// === Excel-Export Funktionen ===
window.btnXLEinsUeber_Click = function() {
    console.log('[Excel] Einsatzuebersicht exportieren');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'Einsatzuebersicht', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Einsatzuebersicht');
        else alert('Excel-Export: Einsatzuebersicht');
    }
};
window.btnXLDiePl_Click = function() {
    console.log('[Excel] Dienstplan exportieren');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'Dienstplan', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Dienstplan');
        else alert('Excel-Export: Dienstplan');
    }
};
window.btnXLZeitkto_Click = function() {
    console.log('[Excel] Zeitkonto exportieren');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'Zeitkonto', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Zeitkonto');
        else alert('Excel-Export: Zeitkonto');
    }
};
window.btnXLJahr_Click = function() {
    console.log('[Excel] Jahresuebersicht exportieren');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'Jahresuebersicht', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Jahresuebersicht');
        else alert('Excel-Export: Jahresuebersicht');
    }
};
window.btnXLNverfueg_Click = function() {
    console.log('[Excel] Nicht-Verfuegbar exportieren');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'NichtVerfuegbar', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Nicht Verfuegbar');
        else alert('Excel-Export: Nicht Verfuegbar');
    }
};
window.btnXLUeberhangStd_Click = function() {
    console.log('[Excel] Ueberhang-Stunden exportieren');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('excelExport', { typ: 'UeberhangStunden', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Excel-Export: Ueberhang Stunden');
        else alert('Excel-Export: Ueberhang Stunden');
    }
};

// === Zeitkonten-Fortschreibung ===
window.btnZKFest_Click = function() {
    console.log('[ZK] Festangestellte fortschreiben');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('zeitkontoFortschreiben', { typ: 'Fest' });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Zeitkonten Festangestellte werden fortgeschrieben...');
        else alert('Zeitkonten Festangestellte werden fortgeschrieben...');
    }
};
window.btnZKMini_Click = function() {
    console.log('[ZK] Minijobber fortschreiben');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('zeitkontoFortschreiben', { typ: 'Mini' });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Zeitkonten Minijobber werden fortgeschrieben...');
        else alert('Zeitkonten Minijobber werden fortgeschrieben...');
    }
};
window.btnZKeinzel_Click = function() {
    console.log('[ZK] Einzelsatz fortschreiben');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('zeitkontoFortschreiben', { typ: 'Einzel', ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Zeitkonto Einzelsatz wird fortgeschrieben...');
        else alert('Zeitkonto Einzelsatz wird fortgeschrieben...');
    }
};

// === Foto/Dokument Upload ===
window.btnDateisuch2_Click = function() {
    console.log('[Foto] Zweites Foto/Dokument hochladen');
    // Trigger hidden file input for secondary document
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*,.pdf,.doc,.docx';
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (file) {
            console.log('[Foto2] Datei ausgewaehlt:', file.name);
            if (typeof Bridge !== 'undefined' && Bridge.execute) {
                Bridge.execute('uploadDokument', { ma_id: state.currentRecord?.ID, file: file.name, typ: 'Foto2' });
            }
        }
    };
    input.click();
};

// === Nicht-Verfuegbarkeit ===
window.neueNichtVerfügbar = function() {
    console.log('[NV] Neue Nicht-Verfuegbarkeit');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('neueNichtVerfuegbarkeit', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Neue Nicht-Verfuegbarkeit wird angelegt...');
        else alert('Neue Nicht-Verfuegbarkeit wird angelegt...');
    }
};
window.loescheNichtVerfügbar = function() {
    console.log('[NV] Nicht-Verfuegbarkeit loeschen');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('loescheNichtVerfuegbarkeit', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Eintrag auswaehlen');
        else alert('Bitte Eintrag auswaehlen');
    }
};

// === Dienstkleidung ===
window.neueDienstkleidung = function() {
    console.log('[DK] Neue Dienstkleidung-Ausgabe');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('neueDienstkleidung', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Dienstkleidung-Ausgabe wird erfasst...');
        else alert('Dienstkleidung-Ausgabe wird erfasst...');
    }
};
window.rückgabeDienstkleidung = function() {
    console.log('[DK] Dienstkleidung-Rueckgabe');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('rueckgabeDienstkleidung', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Dienstkleidung-Rueckgabe wird erfasst...');
        else alert('Dienstkleidung-Rueckgabe wird erfasst...');
    }
};

// === Vordrucke drucken ===
window.druckeVordruck = function(typ) {
    console.log('[Druck] Vordruck:', typ);
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('druckeVordruck', { typ: typ, ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Vordruck "' + typ + '" wird gedruckt...');
        else alert('Vordruck "' + typ + '" wird gedruckt...');
    }
};

// === Qualifikationen ===
window.neueQualifikation = function() {
    console.log('[Quali] Neue Qualifikation');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('neueQualifikation', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Neue Qualifikation wird angelegt...');
        else alert('Neue Qualifikation wird angelegt...');
    }
};
window.loescheQualifikation = function() {
    console.log('[Quali] Qualifikation loeschen');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('loescheQualifikation', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Qualifikation auswaehlen');
        else alert('Bitte Qualifikation auswaehlen');
    }
};
window.loadQualifikationen = function() {
    console.log('[Quali] Qualifikationen laden');
    // Implementierung je nach API
};

// === Dokumente ===
window.neuesDokument = function() {
    console.log('[Dok] Neues Dokument');
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.pdf,.doc,.docx,.jpg,.png';
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (file && typeof Bridge !== 'undefined' && Bridge.execute) {
            Bridge.execute('uploadDokument', { ma_id: state.currentRecord?.ID, file: file.name, typ: 'Dokument' });
        }
    };
    input.click();
};
window.loescheDokument = function() {
    console.log('[Dok] Dokument loeschen');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('loescheDokument', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Dokument auswaehlen');
        else alert('Bitte Dokument auswaehlen');
    }
};
window.öffneDokument = function() {
    console.log('[Dok] Dokument oeffnen');
    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        Bridge.execute('oeffneDokument', { ma_id: state.currentRecord?.ID });
    } else {
        if (typeof Toast !== 'undefined') Toast.info('Dokument wird geoeffnet...');
        else alert('Dokument wird geoeffnet...');
    }
};
window.loadDokumente = function() {
    console.log('[Dok] Dokumente laden');
    // Implementierung je nach API
};

// === QuickInfo-Aktionen ===
window.quickInfoSendEmail = function() {
    const rec = state.currentRecord;
    if (rec && rec.Email) {
        window.open('mailto:' + rec.Email, '_blank');
    } else {
        if (typeof Toast !== 'undefined') Toast.warning('Keine E-Mail-Adresse vorhanden');
        else alert('Keine E-Mail-Adresse vorhanden');
    }
};
window.quickInfoShowEinsatzplan = function() {
    openDienstplan();
};
window.quickInfoShowDokumente = function() {
    // Tab "Dokumente" aktivieren
    const dokTab = document.querySelector('[data-tab="dokumente"]');
    if (dokTab) dokTab.click();
};
window.quickInfoShowNotizen = function() {
    // Tab "Notizen" aktivieren oder Notizen-Modal oeffnen
    const notizTab = document.querySelector('[data-tab="notizen"]');
    if (notizTab) notizTab.click();
};

console.log('[frm_MA_Mitarbeiterstamm] Alle onclick-Handler registriert');

})(); // Ende IIFE
