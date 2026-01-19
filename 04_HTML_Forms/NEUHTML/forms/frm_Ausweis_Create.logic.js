/**
 * frm_Ausweis_Create.logic.js
 * Logik fuer Ausweisdruck
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../api/bridgeClient.js';

// State
const state = {
    alleMA: [],
    auswahlMA: [],
    selectedAusweistyp: 1,
    gueltigBis: null,
    kartendrucker: 'Badgy200'
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Ausweis] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Listen
        lstMA_Alle: document.getElementById('lstMA_Alle'),
        lstMA_Ausweis: document.getElementById('lstMA_Ausweis'),

        // Transfer-Buttons
        btnAddSelected: document.getElementById('btnAddSelected'),
        btnDelSelected: document.getElementById('btnDelSelected'),

        // Ausweistyp-Buttons
        btnAusweis1: document.getElementById('btnAusweis1'),
        btnAusweis2: document.getElementById('btnAusweis2'),
        btnAusweis3: document.getElementById('btnAusweis3'),
        btnAusweis4: document.getElementById('btnAusweis4'),
        btnAusweis5: document.getElementById('btnAusweis5'),
        btnAusweis6: document.getElementById('btnAusweis6'),
        btnAusweis7: document.getElementById('btnAusweis7'),

        // Toolbar
        btnObjektliste: document.getElementById('btnObjektliste'),
        btnHilfe: document.getElementById('btnHilfe'),

        // Kartendrucker
        cbo_Kartendrucker: document.getElementById('cbo_Kartendrucker'),
        lblKartendrucker: document.getElementById('lblKartendrucker'),

        // Gueltig bis
        datGueltigBis: document.getElementById('datGueltigBis'),

        // Vorschau
        previewName: document.getElementById('previewName'),
        previewFunktion: document.getElementById('previewFunktion'),
        previewNr: document.getElementById('previewNr'),

        // Erstellen
        btnAusweisErstellen: document.getElementById('btnAusweisErstellen'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    // Standard Gueltig-Bis (1 Jahr)
    const nextYear = new Date();
    nextYear.setFullYear(nextYear.getFullYear() + 1);
    elements.datGueltigBis.value = formatDate(nextYear);
    state.gueltigBis = nextYear;

    // Event Listener einrichten
    setupEventListeners();

    // Mitarbeiter laden
    await loadMitarbeiter();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Transfer-Buttons
    elements.btnAddSelected.addEventListener('click', addSelected);
    elements.btnDelSelected.addEventListener('click', removeSelected);

    // Ausweistyp-Buttons
    const ausweisButtons = [
        { btn: elements.btnAusweis1, type: 1, funktion: 'Sicherheitsmitarbeiter' },
        { btn: elements.btnAusweis2, type: 2, funktion: 'Einsatzleitung' },
        { btn: elements.btnAusweis3, type: 3, funktion: 'Bereichsleiter' },
        { btn: elements.btnAusweis4, type: 4, funktion: 'Sicherheitspersonal' },
        { btn: elements.btnAusweis5, type: 5, funktion: 'Servicepersonal' },
        { btn: elements.btnAusweis6, type: 6, funktion: 'Garderobenpersonal' },
        { btn: elements.btnAusweis7, type: 7, funktion: 'Verwaltung' }
    ];

    ausweisButtons.forEach(({ btn, type, funktion }) => {
        if (btn) {
            btn.addEventListener('click', () => selectAusweistyp(type, funktion));
        }
    });

    // Kartendrucker
    if (elements.cbo_Kartendrucker) {
        elements.cbo_Kartendrucker.addEventListener('change', (e) => {
            const selected = e.target.options[e.target.selectedIndex];
            state.kartendrucker = selected.textContent;
            elements.lblKartendrucker.textContent = state.kartendrucker;
        });
    }

    // Gueltig bis
    if (elements.datGueltigBis) {
        elements.datGueltigBis.addEventListener('change', (e) => {
            state.gueltigBis = new Date(e.target.value);
        });
    }

    // Listen-Click fuer Vorschau
    if (elements.lstMA_Ausweis) {
        elements.lstMA_Ausweis.addEventListener('click', updatePreview);
    }

    // Toolbar
    if (elements.btnObjektliste) {
        elements.btnObjektliste.addEventListener('click', printObjektliste);
    }
    if (elements.btnHilfe) {
        elements.btnHilfe.addEventListener('click', showHelp);
    }

    // Ausweis erstellen
    if (elements.btnAusweisErstellen) {
        elements.btnAusweisErstellen.addEventListener('click', createAusweis);
    }
}

/**
 * Mitarbeiter laden
 */
async function loadMitarbeiter() {
    setStatus('Lade Mitarbeiter...');

    try {
        const result = await Bridge.mitarbeiter.list({ aktiv: true });

        state.alleMA = (result.data || []).map(ma => ({
            ID: ma.ID,
            Name: `${ma.Nachname}, ${ma.Vorname}`,
            Nachname: ma.Nachname,
            Vorname: ma.Vorname
        }));

        // Liste fuellen
        elements.lstMA_Alle.innerHTML = '';
        state.alleMA.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = ma.Name;
            elements.lstMA_Alle.appendChild(option);
        });

        setStatus(`${state.alleMA.length} Mitarbeiter geladen`);

    } catch (error) {
        console.error('[Ausweis] Fehler beim Laden der Mitarbeiter:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Ausgewaehlte MA hinzufuegen
 */
function addSelected() {
    const selected = Array.from(elements.lstMA_Alle.selectedOptions);

    selected.forEach(opt => {
        // Pruefen ob bereits vorhanden
        const exists = Array.from(elements.lstMA_Ausweis.options).some(o => o.value === opt.value);
        if (!exists) {
            const newOpt = opt.cloneNode(true);
            elements.lstMA_Ausweis.appendChild(newOpt);

            state.auswahlMA.push({
                ID: opt.value,
                Name: opt.textContent
            });
        }
    });

    updateCount();
    updatePreview();
}

/**
 * Ausgewaehlte MA entfernen
 */
function removeSelected() {
    const selected = Array.from(elements.lstMA_Ausweis.selectedOptions);

    selected.forEach(opt => {
        const idx = state.auswahlMA.findIndex(ma => ma.ID == opt.value);
        if (idx >= 0) {
            state.auswahlMA.splice(idx, 1);
        }
        opt.remove();
    });

    updateCount();
    updatePreview();
}

/**
 * Ausweistyp auswaehlen
 */
function selectAusweistyp(type, funktion) {
    state.selectedAusweistyp = type;

    // Buttons aktualisieren
    document.querySelectorAll('.ausweistyp-btn').forEach(btn => {
        btn.classList.remove('primary');
    });
    const selectedBtn = document.getElementById(`btnAusweis${type}`);
    if (selectedBtn) {
        selectedBtn.classList.add('primary');
    }

    // Vorschau aktualisieren
    if (elements.previewFunktion) {
        elements.previewFunktion.textContent = funktion;
    }
}

/**
 * Vorschau aktualisieren
 */
function updatePreview() {
    const selected = elements.lstMA_Ausweis.selectedOptions;
    if (selected.length > 0) {
        const opt = selected[0];
        elements.previewName.textContent = opt.textContent;
        elements.previewNr.textContent = `Nr: ${String(opt.value).padStart(5, '0')}`;
    } else if (state.auswahlMA.length > 0) {
        elements.previewName.textContent = state.auswahlMA[0].Name;
        elements.previewNr.textContent = `Nr: ${String(state.auswahlMA[0].ID).padStart(5, '0')}`;
    } else {
        elements.previewName.textContent = 'Max Mustermann';
        elements.previewNr.textContent = 'Nr: 00001';
    }
}

/**
 * Zaehler aktualisieren
 */
function updateCount() {
    const count = elements.lstMA_Ausweis.options.length;
    elements.lblAnzahl.textContent = `${count} ausgewaehlt`;
}

/**
 * Ausweis erstellen
 */
async function createAusweis() {
    if (state.auswahlMA.length === 0) {
        alert('Bitte waehlen Sie mindestens einen Mitarbeiter aus.');
        return;
    }

    if (!state.gueltigBis) {
        alert('Bitte geben Sie ein Gueltig-bis Datum ein.');
        return;
    }

    setStatus('Erstelle Ausweise...');

    try {
        // Hier wuerde der eigentliche Ausweis-Druck stattfinden
        // Entweder via Bridge-Call zum Access-Backend oder direkt

        const ausweisData = {
            mitarbeiter: state.auswahlMA.map(ma => ma.ID),
            ausweistyp: state.selectedAusweistyp,
            gueltigBis: formatDate(state.gueltigBis),
            drucker: state.kartendrucker
        };

        console.log('[Ausweis] Erstelle Ausweise:', ausweisData);

        // Simuliere erfolgreichen Druck
        alert(`${state.auswahlMA.length} Ausweis(e) werden gedruckt auf ${state.kartendrucker}`);

        setStatus(`${state.auswahlMA.length} Ausweis(e) erstellt`);

    } catch (error) {
        console.error('[Ausweis] Fehler beim Erstellen:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Erstellen der Ausweise: ' + error.message);
    }
}

/**
 * Objektliste drucken
 */
function printObjektliste() {
    // Oeffne Druckdialog fuer die aktuelle Liste
    window.print();
}

/**
 * Hilfe anzeigen
 */
function showHelp() {
    alert(
        'Ausweisdruck - Hilfe\n\n' +
        '1. Waehlen Sie Mitarbeiter aus der linken Liste aus\n' +
        '2. Klicken Sie ">" um sie zur Auswahl hinzuzufuegen\n' +
        '3. Waehlen Sie einen Ausweistyp\n' +
        '4. Setzen Sie das Gueltig-bis Datum\n' +
        '5. Waehlen Sie den Kartendrucker\n' +
        '6. Klicken Sie "Ausweis erstellen"'
    );
}

/**
 * Datum formatieren
 */
function formatDate(date) {
    return date.toISOString().split('T')[0];
}

/**
 * Status setzen
 */
function setStatus(text) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = text;
    }
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.AusweisCreate = {
    loadMitarbeiter,
    addSelected,
    removeSelected,
    createAusweis
};
