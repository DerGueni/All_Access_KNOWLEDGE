/**
 * frm_KD_Kundenstamm.logic.js
 * Vollständige REST-API Anbindung für Kundenstamm-Formular
 * API-Basis: http://localhost:5000/api
 */

const API_BASE = 'http://localhost:5000/api';

// State Management
const state = {
    kundenListe: [],
    currentIndex: 0,
    currentKundeId: null,
    currentKunde: null,
    isDirty: false,
    nurAktive: true
};

// DOM-Elemente Cache
let elements = {};

/**
 * Initialisierung beim Laden der Seite
 */
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Kundenstamm] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Navigation
        btnErster: document.getElementById('btnErster'),
        btnVorheriger: document.getElementById('btnVorheriger'),
        btnNaechster: document.getElementById('btnNaechster'),
        btnLetzter: document.getElementById('btnLetzter'),

        // Aktionen
        btnNeuerKunde: document.getElementById('btnNeuerKunde'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLoeschen'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblRecordInfo: document.getElementById('lblRecordInfo'),
        lblAnzahl: document.getElementById('lblAnzahl'),

        // Filter
        chkNurAktive: document.getElementById('chkNurAktive'),
        txtSuche: document.getElementById('txtSuche'),

        // Listen
        tbodyListe: document.getElementById('tbody_Liste'),
        tbodyAuftraege: document.getElementById('tbody_Auftraege'),

        // Formularfelder (Stammdaten)
        KD_ID: document.getElementById('KD_ID'),
        KD_Name1: document.getElementById('KD_Name1'),
        KD_Name2: document.getElementById('KD_Name2'),
        KD_Kuerzel: document.getElementById('KD_Kuerzel'),
        KD_Strasse: document.getElementById('KD_Strasse'),
        KD_PLZ: document.getElementById('KD_PLZ'),
        KD_Ort: document.getElementById('KD_Ort'),
        KD_Land: document.getElementById('KD_Land'),
        KD_Telefon: document.getElementById('KD_Telefon'),
        kun_mobil: document.getElementById('kun_mobil'),
        KD_Fax: document.getElementById('KD_Fax'),
        KD_Email: document.getElementById('KD_Email'),
        KD_Web: document.getElementById('KD_Web'),
        KD_IstAktiv: document.getElementById('KD_IstAktiv'),
        kun_IstSammelRechnung: document.getElementById('kun_IstSammelRechnung'),
        kun_ans_manuell: document.getElementById('kun_ans_manuell'),

        // Bankdaten
        kun_kreditinstitut: document.getElementById('kun_kreditinstitut'),
        kun_blz: document.getElementById('kun_blz'),
        kun_kontonummer: document.getElementById('kun_kontonummer'),
        kun_iban: document.getElementById('kun_iban'),
        kun_bic: document.getElementById('kun_bic'),
        KD_UStIDNr: document.getElementById('KD_UStIDNr'),
        KD_Zahlungsbedingung: document.getElementById('KD_Zahlungsbedingung'),

        // Konditionen
        KD_Rabatt: document.getElementById('KD_Rabatt'),
        KD_Skonto: document.getElementById('KD_Skonto'),
        KD_SkontoTage: document.getElementById('KD_SkontoTage'),

        // Ansprechpartner
        KD_AP_Name: document.getElementById('KD_AP_Name'),
        KD_AP_Position: document.getElementById('KD_AP_Position'),
        KD_AP_Telefon: document.getElementById('KD_AP_Telefon'),
        KD_AP_Email: document.getElementById('KD_AP_Email'),

        // Bemerkungen
        kun_Anschreiben: document.getElementById('kun_Anschreiben'),
        kun_BriefKopf: document.getElementById('kun_BriefKopf'),
        KD_Bemerkungen: document.getElementById('KD_Bemerkungen')
    };

    // Event Listener registrieren
    initEventHandlers();

    // Kundenliste laden
    await loadKundenListe();

    setStatus('Bereit');
});

/**
 * Event Handler initialisieren
 */
function initEventHandlers() {
    // Navigation
    elements.btnErster?.addEventListener('click', () => navigateTo(0));
    elements.btnVorheriger?.addEventListener('click', () => navigateTo(state.currentIndex - 1));
    elements.btnNaechster?.addEventListener('click', () => navigateTo(state.currentIndex + 1));
    elements.btnLetzter?.addEventListener('click', () => navigateTo(state.kundenListe.length - 1));

    // Aktionen
    elements.btnNeuerKunde?.addEventListener('click', handleNeu);
    elements.btnSpeichern?.addEventListener('click', handleSpeichern);
    elements.btnLoeschen?.addEventListener('click', handleLoeschen);

    // Filter/Suche
    elements.chkNurAktive?.addEventListener('change', loadKundenListe);
    elements.txtSuche?.addEventListener('input', debounce(filterKundenListe, 300));

    // Formularfelder auf Änderungen überwachen
    document.querySelectorAll('input, select, textarea').forEach(el => {
        el.addEventListener('change', () => {
            state.isDirty = true;
        });
    });
}

/**
 * Kundenliste von API laden
 */
async function loadKundenListe() {
    try {
        setStatus('Lade Kundenliste...');

        const nurAktiv = elements.chkNurAktive?.checked ?? true;
        const url = nurAktiv ? `${API_BASE}/kunden?aktiv=true` : `${API_BASE}/kunden`;

        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        state.kundenListe = data.data || data || [];

        renderKundenListe();

        // Ersten Datensatz laden wenn vorhanden
        if (state.kundenListe.length > 0) {
            await loadKunde(state.kundenListe[0].kun_Id);
        } else {
            clearForm();
            setStatus('Keine Kunden gefunden');
        }

        updateAnzahl();
    } catch (error) {
        console.error('Fehler beim Laden der Kundenliste:', error);
        showError('Kundenliste konnte nicht geladen werden: ' + error.message);
    }
}

/**
 * Kundenliste in Tabelle rendern
 */
function renderKundenListe() {
    const tbody = elements.tbodyListe;
    if (!tbody) return;

    tbody.innerHTML = '';

    state.kundenListe.forEach((kunde, index) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${kunde.kun_Id || ''}</td>
            <td>${kunde.kun_Firma || kunde.kun_Name1 || ''}</td>
            <td>${kunde.kun_Ort || ''}</td>
        `;

        // Click-Handler für Zeile
        tr.addEventListener('click', () => {
            // Alle anderen Zeilen deselektieren
            tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
            // Aktuelle Zeile selektieren
            tr.classList.add('selected');
            // Kunde laden
            loadKunde(kunde.kun_Id);
        });

        tbody.appendChild(tr);
    });

    // Erste Zeile automatisch selektieren
    if (state.kundenListe.length > 0) {
        tbody.querySelector('tr')?.classList.add('selected');
    }
}

/**
 * Kundenliste filtern (Suche)
 */
function filterKundenListe() {
    const searchTerm = (elements.txtSuche?.value || '').toLowerCase();
    const tbody = elements.tbodyListe;
    if (!tbody) return;

    tbody.querySelectorAll('tr').forEach(tr => {
        const text = tr.textContent.toLowerCase();
        tr.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

/**
 * Einzelnen Kunden von API laden
 */
async function loadKunde(kundeId) {
    if (!kundeId) return;

    try {
        setStatus(`Lade Kunde ${kundeId}...`);

        const response = await fetch(`${API_BASE}/kunden/${kundeId}`);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        state.currentKunde = data.data || data;
        state.currentKundeId = kundeId;

        // Index in Liste aktualisieren
        state.currentIndex = state.kundenListe.findIndex(k => k.kun_Id === kundeId);

        fillKundeForm(state.currentKunde);
        updateNavigationInfo();

        // Aufträge laden wenn gewünscht
        // await loadKundenAuftraege(kundeId);

        state.isDirty = false;
        setStatus('Bereit');
    } catch (error) {
        console.error('Fehler beim Laden des Kunden:', error);
        showError('Kunde konnte nicht geladen werden: ' + error.message);
    }
}

/**
 * Formular mit Kundendaten befüllen
 */
function fillKundeForm(kunde) {
    if (!kunde) return;

    // Stammdaten
    setValue('KD_ID', kunde.kun_Id);
    setValue('KD_Name1', kunde.kun_Firma || kunde.kun_Name1);
    setValue('KD_Name2', kunde.kun_Name2);
    setValue('KD_Kuerzel', kunde.kun_Kuerzel);
    setValue('KD_Strasse', kunde.kun_Strasse);
    setValue('KD_PLZ', kunde.kun_PLZ);
    setValue('KD_Ort', kunde.kun_Ort);
    setValue('KD_Land', kunde.kun_Land || 'DE');
    setValue('KD_Telefon', kunde.kun_Telefon);
    setValue('kun_mobil', kunde.kun_mobil);
    setValue('KD_Fax', kunde.kun_Fax);
    setValue('KD_Email', kunde.kun_Email);
    setValue('KD_Web', kunde.kun_Web);

    // Checkboxen
    setChecked('KD_IstAktiv', kunde.kun_IstAktiv);
    setChecked('kun_IstSammelRechnung', kunde.kun_IstSammelRechnung);
    setChecked('kun_ans_manuell', kunde.kun_ans_manuell);

    // Bankdaten
    setValue('kun_kreditinstitut', kunde.kun_kreditinstitut);
    setValue('kun_blz', kunde.kun_blz);
    setValue('kun_kontonummer', kunde.kun_kontonummer);
    setValue('kun_iban', kunde.kun_iban);
    setValue('kun_bic', kunde.kun_bic);
    setValue('KD_UStIDNr', kunde.kun_UStIDNr);
    setValue('KD_Zahlungsbedingung', kunde.kun_Zahlungsbedingung);

    // Konditionen
    setValue('KD_Rabatt', kunde.kun_Rabatt);
    setValue('KD_Skonto', kunde.kun_Skonto);
    setValue('KD_SkontoTage', kunde.kun_SkontoTage);

    // Ansprechpartner
    setValue('KD_AP_Name', kunde.kun_AP_Name);
    setValue('KD_AP_Position', kunde.kun_AP_Position);
    setValue('KD_AP_Telefon', kunde.kun_AP_Telefon);
    setValue('KD_AP_Email', kunde.kun_AP_Email);

    // Bemerkungen
    setValue('kun_Anschreiben', kunde.kun_Anschreiben);
    setValue('kun_BriefKopf', kunde.kun_BriefKopf);
    setValue('KD_Bemerkungen', kunde.kun_Bemerkungen);
}

/**
 * Formulardaten sammeln
 */
function collectFormData() {
    return {
        kun_Id: state.currentKundeId || null,
        kun_Firma: getValue('KD_Name1'),
        kun_Name1: getValue('KD_Name1'),
        kun_Name2: getValue('KD_Name2'),
        kun_Kuerzel: getValue('KD_Kuerzel'),
        kun_Strasse: getValue('KD_Strasse'),
        kun_PLZ: getValue('KD_PLZ'),
        kun_Ort: getValue('KD_Ort'),
        kun_Land: getValue('KD_Land'),
        kun_Telefon: getValue('KD_Telefon'),
        kun_mobil: getValue('kun_mobil'),
        kun_Fax: getValue('KD_Fax'),
        kun_Email: getValue('KD_Email'),
        kun_Web: getValue('KD_Web'),
        kun_IstAktiv: getChecked('KD_IstAktiv'),
        kun_IstSammelRechnung: getChecked('kun_IstSammelRechnung'),
        kun_ans_manuell: getChecked('kun_ans_manuell'),
        kun_kreditinstitut: getValue('kun_kreditinstitut'),
        kun_blz: getValue('kun_blz'),
        kun_kontonummer: getValue('kun_kontonummer'),
        kun_iban: getValue('kun_iban'),
        kun_bic: getValue('kun_bic'),
        kun_UStIDNr: getValue('KD_UStIDNr'),
        kun_Zahlungsbedingung: getValue('KD_Zahlungsbedingung'),
        kun_Rabatt: parseFloat(getValue('KD_Rabatt')) || 0,
        kun_Skonto: parseFloat(getValue('KD_Skonto')) || 0,
        kun_SkontoTage: parseInt(getValue('KD_SkontoTage')) || 0,
        kun_AP_Name: getValue('KD_AP_Name'),
        kun_AP_Position: getValue('KD_AP_Position'),
        kun_AP_Telefon: getValue('KD_AP_Telefon'),
        kun_AP_Email: getValue('KD_AP_Email'),
        kun_Anschreiben: getValue('kun_Anschreiben'),
        kun_BriefKopf: getValue('kun_BriefKopf'),
        kun_Bemerkungen: getValue('KD_Bemerkungen')
    };
}

/**
 * Neuen Kunden anlegen
 */
async function handleNeu() {
    if (state.isDirty && !confirm('Änderungen verwerfen?')) {
        return;
    }

    state.currentKundeId = null;
    state.currentKunde = null;
    clearForm();

    // Aktiv standardmäßig angehakt
    setChecked('KD_IstAktiv', true);
    setValue('KD_Land', 'DE');

    elements.KD_Name1?.focus();
    setStatus('Neuer Kunde');
}

/**
 * Kunden speichern (Create/Update)
 */
async function handleSpeichern() {
    try {
        const formData = collectFormData();

        // Validierung
        if (!formData.kun_Firma && !formData.kun_Name1) {
            showError('Bitte geben Sie einen Firmennamen ein.');
            elements.KD_Name1?.focus();
            return;
        }

        const isNew = !state.currentKundeId;
        const url = isNew
            ? `${API_BASE}/kunden`
            : `${API_BASE}/kunden/${state.currentKundeId}`;
        const method = isNew ? 'POST' : 'PUT';

        setStatus('Speichere...');

        const response = await fetch(url, {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `HTTP ${response.status}`);
        }

        const result = await response.json();

        showSuccess('Erfolgreich gespeichert!');

        // Bei neuem Datensatz: ID setzen
        if (isNew && result.data?.kun_Id) {
            state.currentKundeId = result.data.kun_Id;
        }

        // Liste neu laden
        await loadKundenListe();

        // Gespeicherten Datensatz wieder laden
        if (state.currentKundeId) {
            await loadKunde(state.currentKundeId);
        }

        state.isDirty = false;
    } catch (error) {
        console.error('Fehler beim Speichern:', error);
        showError('Speichern fehlgeschlagen: ' + error.message);
    }
}

/**
 * Kunden löschen
 */
async function handleLoeschen() {
    if (!state.currentKundeId) {
        showError('Kein Kunde ausgewählt.');
        return;
    }

    const kunde = state.currentKunde;
    const kundenName = kunde?.kun_Firma || kunde?.kun_Name1 || `Kunde ${state.currentKundeId}`;

    if (!confirm(`Kunde "${kundenName}" wirklich löschen?`)) {
        return;
    }

    try {
        setStatus('Lösche...');

        const response = await fetch(`${API_BASE}/kunden/${state.currentKundeId}`, {
            method: 'DELETE'
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        showSuccess('Kunde gelöscht!');

        // Liste neu laden
        await loadKundenListe();
    } catch (error) {
        console.error('Fehler beim Löschen:', error);
        showError('Löschen fehlgeschlagen: ' + error.message);
    }
}

/**
 * Navigation zu Index
 */
function navigateTo(index) {
    if (index < 0) index = 0;
    if (index >= state.kundenListe.length) index = state.kundenListe.length - 1;

    if (state.kundenListe[index]) {
        state.currentIndex = index;
        loadKunde(state.kundenListe[index].kun_Id);
    }
}

/**
 * Formular leeren
 */
function clearForm() {
    document.querySelectorAll('input[type="text"], input[type="number"], textarea, select').forEach(el => {
        el.value = '';
    });
    document.querySelectorAll('input[type="checkbox"]').forEach(el => {
        el.checked = false;
    });
}

/**
 * Navigations-Info aktualisieren
 */
function updateNavigationInfo() {
    if (elements.lblRecordInfo) {
        elements.lblRecordInfo.textContent =
            `Datensatz ${state.currentIndex + 1} von ${state.kundenListe.length}`;
    }
}

/**
 * Anzahl aktualisieren
 */
function updateAnzahl() {
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.kundenListe.length} Kunden`;
    }
}

/**
 * Status-Text setzen
 */
function setStatus(text) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = text;
    }
}

/**
 * Erfolgsmeldung anzeigen
 */
function showSuccess(message) {
    setStatus(message);
    setTimeout(() => setStatus('Bereit'), 3000);
}

/**
 * Fehlermeldung anzeigen
 */
function showError(message) {
    setStatus('FEHLER: ' + message);
    alert(message);
}

/**
 * Hilfsfunktion: Wert setzen
 */
function setValue(elementId, value) {
    const el = elements[elementId];
    if (el) {
        el.value = value ?? '';
    }
}

/**
 * Hilfsfunktion: Wert lesen
 */
function getValue(elementId) {
    const el = elements[elementId];
    return el ? el.value : '';
}

/**
 * Hilfsfunktion: Checkbox setzen
 */
function setChecked(elementId, checked) {
    const el = elements[elementId];
    if (el) {
        el.checked = !!checked;
    }
}

/**
 * Hilfsfunktion: Checkbox lesen
 */
function getChecked(elementId) {
    const el = elements[elementId];
    return el ? el.checked : false;
}

/**
 * Debounce-Funktion für Suche
 */
function debounce(fn, delay) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn.apply(this, args), delay);
    };
}

/**
 * WebView2 Bridge Integration (falls vorhanden)
 */
if (typeof Bridge !== 'undefined') {
    Bridge.on('onDataReceived', (data) => {
        console.log('[Kundenstamm] Daten von Bridge empfangen:', data);
        if (data.kunde) {
            fillKundeForm(data.kunde);
        }
        if (data.kun_Id) {
            loadKunde(data.kun_Id);
        }
    });
}
