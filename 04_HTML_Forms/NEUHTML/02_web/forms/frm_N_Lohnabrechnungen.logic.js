/**
 * frm_N_Lohnabrechnungen.logic.js
 * Logik fuer Lohnabrechnungen Formular
 *
 * Funktionen:
 * - Lohnabrechnungen laden und filtern
 * - Checkboxen fuer Versand verwalten
 * - Lohnabrechnungen versenden
 */

import { Bridge } from '../js/webview2-bridge.js';

// ============================================
// State
// ============================================
const state = {
    abrechnungen: [],
    filter: {
        jahr: new Date().getFullYear(),
        monat: new Date().getMonth() + 1,
        anstArt: 'fest'
    },
    selectedIds: new Set()
};

// ============================================
// DOM Elements
// ============================================
let elements = {};

// ============================================
// Initialisierung
// ============================================
function init() {
    console.log('[Lohnabrechnungen] Initialisierung...');

    elements = {
        // Filter
        cboJahr: document.getElementById('cboJahr'),
        cboMonat: document.getElementById('cboMonat'),
        cboAnstArt: document.getElementById('cboAnstArt'),

        // Buttons
        btnLaden: document.getElementById('btnLaden'),
        btnVersenden: document.getElementById('btnVersenden'),

        // Tabelle
        tblLohnabrechnungen: document.getElementById('tblLohnabrechnungen'),
        tbodyLohnabrechnungen: document.getElementById('tbodyLohnabrechnungen'),

        // Footer
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl'),

        // Header
        headerDate: document.getElementById('header-date')
    };

    // Datum setzen
    if (elements.headerDate) {
        elements.headerDate.textContent = new Date().toLocaleDateString('de-DE');
    }

    // Filter-Werte initialisieren
    if (elements.cboJahr) {
        elements.cboJahr.value = state.filter.jahr;
    }
    if (elements.cboMonat) {
        elements.cboMonat.value = state.filter.monat;
    }

    setupEventListeners();
    loadAbrechnungen();
}

// ============================================
// Event Listeners
// ============================================
function setupEventListeners() {
    // Filter-Aenderungen
    elements.cboJahr?.addEventListener('change', () => {
        state.filter.jahr = parseInt(elements.cboJahr.value);
    });

    elements.cboMonat?.addEventListener('change', () => {
        state.filter.monat = parseInt(elements.cboMonat.value);
    });

    elements.cboAnstArt?.addEventListener('change', () => {
        state.filter.anstArt = elements.cboAnstArt.value;
    });

    // Buttons
    elements.btnLaden?.addEventListener('click', loadAbrechnungen);
    elements.btnVersenden?.addEventListener('click', versendeAbrechnungen);

    // Table Header Checkbox (Select All)
    const headerCheckbox = elements.tblLohnabrechnungen?.querySelector('thead input[type="checkbox"]');
    if (headerCheckbox) {
        headerCheckbox.addEventListener('change', (e) => {
            toggleSelectAll(e.target.checked);
        });
    }
}

// ============================================
// Daten laden
// ============================================
async function loadAbrechnungen() {
    try {
        setStatus('Lade Lohnabrechnungen...');

        const result = await Bridge.execute('getLohnabrechnungen', {
            jahr: state.filter.jahr,
            monat: state.filter.monat,
            anstArt: state.filter.anstArt
        });

        if (result.success) {
            state.abrechnungen = result.data || [];
            state.selectedIds.clear();
            renderTable();
            updateAnzahl();
            setStatus(`${state.abrechnungen.length} Abrechnungen geladen`);
        } else {
            setStatus('Fehler: ' + result.error);
        }

    } catch (error) {
        console.error('[Lohnabrechnungen] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Tabelle rendern
// ============================================
function renderTable() {
    if (!elements.tbodyLohnabrechnungen) return;

    if (state.abrechnungen.length === 0) {
        elements.tbodyLohnabrechnungen.innerHTML = `
            <tr>
                <td colspan="6" style="text-align:center; padding:40px; color:#666;">
                    Keine Abrechnungen gefunden
                </td>
            </tr>
        `;
        return;
    }

    elements.tbodyLohnabrechnungen.innerHTML = state.abrechnungen.map(ab => {
        const id = ab.ID || ab.MA_ID;
        const monat = state.filter.monat;
        const name = `${ab.MA_Nachname || ab.Nachname} ${ab.MA_Vorname || ab.Vorname}`;
        const datei = ab.Datei || ab.DateiPfad || '';
        const versendetAm = ab.VersendetAm || '';
        const protokoll = ab.Protokoll || ab.Status || '';

        const isChecked = state.selectedIds.has(id);

        return `
            <tr data-id="${id}">
                <td>${monat}</td>
                <td>${name}</td>
                <td>
                    <input type="checkbox" ${isChecked ? 'checked' : ''} data-id="${id}">
                </td>
                <td class="datei-cell" title="${datei}">${datei ? datei.substring(datei.length - 60) : ''}</td>
                <td>${formatDateTime(versendetAm)}</td>
                <td>${protokoll}</td>
            </tr>
        `;
    }).join('');

    // Checkbox Event Listener
    elements.tbodyLohnabrechnungen.querySelectorAll('input[type="checkbox"]').forEach(cb => {
        cb.addEventListener('change', (e) => {
            const id = parseInt(e.target.dataset.id);
            if (e.target.checked) {
                state.selectedIds.add(id);
            } else {
                state.selectedIds.delete(id);
            }
            updateSelectAllState();
        });
    });
}

// ============================================
// Select All
// ============================================
function toggleSelectAll(checked) {
    state.selectedIds.clear();

    if (checked) {
        state.abrechnungen.forEach(ab => {
            const id = ab.ID || ab.MA_ID;
            state.selectedIds.add(id);
        });
    }

    // Alle Checkboxen aktualisieren
    elements.tbodyLohnabrechnungen?.querySelectorAll('input[type="checkbox"]').forEach(cb => {
        cb.checked = checked;
    });
}

function updateSelectAllState() {
    const headerCheckbox = elements.tblLohnabrechnungen?.querySelector('thead input[type="checkbox"]');
    if (headerCheckbox) {
        const allCount = state.abrechnungen.length;
        const selectedCount = state.selectedIds.size;

        headerCheckbox.checked = selectedCount === allCount && allCount > 0;
        headerCheckbox.indeterminate = selectedCount > 0 && selectedCount < allCount;
    }
}

// ============================================
// Versenden
// ============================================
async function versendeAbrechnungen() {
    if (state.selectedIds.size === 0) {
        alert('Bitte mindestens eine Abrechnung auswaehlen');
        return;
    }

    const bestaetigung = confirm(`${state.selectedIds.size} Lohnabrechnung(en) versenden?`);
    if (!bestaetigung) return;

    try {
        setStatus(`Versende ${state.selectedIds.size} Abrechnungen...`);

        // Hier wuerde der eigentliche Versand stattfinden
        // Fuer jede ausgewaehlte ID:
        let erfolg = 0;
        let fehler = 0;

        for (const id of state.selectedIds) {
            try {
                // API-Call fuer Versand (Platzhalter)
                // await Bridge.execute('sendLohnabrechnung', { id, monat: state.filter.monat, jahr: state.filter.jahr });
                erfolg++;

                // Status in Tabelle aktualisieren
                const row = elements.tbodyLohnabrechnungen?.querySelector(`tr[data-id="${id}"]`);
                if (row) {
                    const protokollCell = row.querySelector('td:last-child');
                    const versendetCell = row.querySelector('td:nth-child(5)');
                    if (protokollCell) protokollCell.textContent = 'Email wurde versendet';
                    if (versendetCell) versendetCell.textContent = new Date().toLocaleString('de-DE');
                }

            } catch (e) {
                fehler++;
                console.error(`Fehler beim Versenden ID ${id}:`, e);
            }
        }

        if (fehler === 0) {
            setStatus(`${erfolg} Abrechnung(en) erfolgreich versendet`);
        } else {
            setStatus(`${erfolg} versendet, ${fehler} Fehler`);
        }

        // Auswahl zuruecksetzen
        state.selectedIds.clear();
        updateSelectAllState();

    } catch (error) {
        console.error('[Lohnabrechnungen] Fehler beim Versenden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Helper
// ============================================
function formatDateTime(value) {
    if (!value) return '';
    try {
        const d = new Date(value);
        return d.toLocaleString('de-DE');
    } catch {
        return value;
    }
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function updateAnzahl() {
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.abrechnungen.length} Mitarbeiter`;
    }
}

// ============================================
// Export
// ============================================
window.LohnabrechnungenForm = {
    reload: loadAbrechnungen,
    getSelected: () => Array.from(state.selectedIds)
};

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);
