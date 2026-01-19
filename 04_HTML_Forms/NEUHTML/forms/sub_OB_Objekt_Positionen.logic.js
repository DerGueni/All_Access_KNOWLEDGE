/**
 * sub_OB_Objekt_Positionen.logic.js
 * Logik für Objekt-Positionen Subform
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../api/bridgeClient.js';

const state = {
    objektId: null,
    positionen: [],
    selectedRow: null
};

let elements = {};

async function init() {
    console.log('[sub_OB_Objekt_Positionen] Initialisierung...');

    // Parameter aus URL lesen
    const params = new URLSearchParams(window.location.search);
    state.objektId = params.get('Objekt_ID') || params.get('objekt_id');

    elements = {
        btnNeu: document.getElementById('btnNeu'),
        btnBearbeiten: document.getElementById('btnBearbeiten'),
        btnLoeschen: document.getElementById('btnLöschen'),
        lblAnzahl: document.getElementById('lblAnzahl'),
        tbody: document.getElementById('tbody_Positionen'),
        sumMA: document.getElementById('sumMA')
    };

    setupEventListeners();

    if (state.objektId) {
        await loadPositionen();
    }

    // PostMessage vom Parent-Formular
    window.addEventListener('message', handleMessage);
}

function setupEventListeners() {
    if (elements.btnNeu) {
        elements.btnNeu.addEventListener('click', neuePosition);
    }
    if (elements.btnBearbeiten) {
        elements.btnBearbeiten.addEventListener('click', bearbeitePosition);
    }
    if (elements.btnLoeschen) {
        elements.btnLoeschen.addEventListener('click', loeschePosition);
    }
}

function handleMessage(event) {
    const data = event.data;
    if (!data) return;

    switch (data.action) {
        case 'setObjektID':
            state.objektId = data.objektId;
            loadPositionen();
            break;
        case 'requery':
            loadPositionen();
            break;
    }
}

async function loadPositionen() {
    if (!state.objektId) {
        renderEmpty();
        return;
    }

    try {
        const result = await Bridge.objekte.positionen(state.objektId);
        state.positionen = result.data || [];
        renderPositionen();
        updateSumme();
        updateCount();
    } catch (error) {
        console.error('[Positionen] Fehler beim Laden:', error);
        renderError(error.message);
    }
}

function renderPositionen() {
    if (!elements.tbody) return;

    if (state.positionen.length === 0) {
        renderEmpty();
        return;
    }

    elements.tbody.innerHTML = state.positionen.map((pos, idx) => {
        const selected = state.selectedRow === idx ? 'selected' : '';
        const qualiClass = pos.Qualifikation_Required ? 'required' : '';

        return `
            <tr data-index="${idx}" data-id="${pos.ID}" class="${selected}">
                <td class="text-center">${pos.Position || 'P' + (idx + 1).toString().padStart(2, '0')}</td>
                <td>${pos.Bezeichnung || ''}</td>
                <td class="text-center">${pos.MA_Soll || 0}</td>
                <td><span class="quali-badge ${qualiClass}">${pos.Qualifikation || '-'}</span></td>
                <td class="text-right">${formatBetrag(pos.Stundensatz)}</td>
                <td>${pos.Bemerkung || ''}</td>
            </tr>
        `;
    }).join('');

    // Click-Handler
    elements.tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => selectRow(row));
        row.addEventListener('dblclick', () => bearbeitePosition());
    });
}

function renderEmpty() {
    if (elements.tbody) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align:center;color:#666;padding:20px;">
                    Keine Positionen vorhanden
                </td>
            </tr>
        `;
    }
    state.positionen = [];
    updateCount();
    updateSumme();
}

function renderError(message) {
    if (elements.tbody) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align:center;color:#c00;padding:20px;">
                    Fehler: ${message}
                </td>
            </tr>
        `;
    }
}

function selectRow(row) {
    const idx = parseInt(row.dataset.index);
    state.selectedRow = idx;

    elements.tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
    row.classList.add('selected');
}

function neuePosition() {
    if (!state.objektId) {
        alert('Bitte zuerst ein Objekt auswählen');
        return;
    }

    // Dialog öffnen oder Inline-Eingabe
    const bezeichnung = prompt('Bezeichnung der Position:');
    if (!bezeichnung) return;

    const maSoll = prompt('Anzahl MA (Soll):', '1');
    const stundensatz = prompt('Stundensatz:', '20.00');

    createPosition({
        Objekt_ID: state.objektId,
        Bezeichnung: bezeichnung,
        MA_Soll: parseInt(maSoll) || 1,
        Stundensatz: parseFloat(stundensatz) || 20.00
    });
}

async function createPosition(data) {
    try {
        await Bridge.execute('createObjektPosition', data);
        await loadPositionen();
    } catch (error) {
        console.error('[Positionen] Fehler beim Erstellen:', error);
        alert('Fehler: ' + error.message);
    }
}

function bearbeitePosition() {
    if (state.selectedRow === null || state.selectedRow === undefined) {
        alert('Bitte zuerst eine Position auswählen');
        return;
    }

    const pos = state.positionen[state.selectedRow];
    if (!pos) return;

    const bezeichnung = prompt('Bezeichnung:', pos.Bezeichnung);
    if (bezeichnung === null) return;

    const maSoll = prompt('Anzahl MA (Soll):', pos.MA_Soll);
    const stundensatz = prompt('Stundensatz:', pos.Stundensatz);

    updatePosition(pos.ID, {
        Bezeichnung: bezeichnung,
        MA_Soll: parseInt(maSoll) || pos.MA_Soll,
        Stundensatz: parseFloat(stundensatz) || pos.Stundensatz
    });
}

async function updatePosition(id, data) {
    try {
        await Bridge.execute('updateObjektPosition', { id, ...data });
        await loadPositionen();
    } catch (error) {
        console.error('[Positionen] Fehler beim Aktualisieren:', error);
        alert('Fehler: ' + error.message);
    }
}

async function loeschePosition() {
    if (state.selectedRow === null || state.selectedRow === undefined) {
        alert('Bitte zuerst eine Position auswählen');
        return;
    }

    const pos = state.positionen[state.selectedRow];
    if (!pos) return;

    if (!confirm('Position wirklich löschen?')) return;

    try {
        await Bridge.execute('deleteObjektPosition', { id: pos.ID });
        state.selectedRow = null;
        await loadPositionen();
    } catch (error) {
        console.error('[Positionen] Fehler beim Löschen:', error);
        alert('Fehler: ' + error.message);
    }
}

function updateCount() {
    if (elements.lblAnzahl) {
        const count = state.positionen.length;
        elements.lblAnzahl.textContent = `${count} Position${count !== 1 ? 'en' : ''}`;
    }
}

function updateSumme() {
    if (elements.sumMA) {
        const sum = state.positionen.reduce((acc, pos) => acc + (parseInt(pos.MA_Soll) || 0), 0);
        elements.sumMA.textContent = sum;
    }
}

function formatBetrag(value) {
    if (!value && value !== 0) return '-';
    return Number(value).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.SubOBPositionen = {
    loadPositionen,
    neuePosition,
    bearbeitePosition,
    loeschePosition,
    setObjektId: (id) => {
        state.objektId = id;
        loadPositionen();
    }
};
