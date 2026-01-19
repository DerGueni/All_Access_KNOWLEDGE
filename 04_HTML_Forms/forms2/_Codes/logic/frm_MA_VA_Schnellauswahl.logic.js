/**
 * frm_MA_VA_Schnellauswahl.logic.js
 * Logik fuer Mitarbeiter-Schnellauswahl
 *
 * Funktionen:
 * - Auftraege und Schichten laden
 * - Mitarbeiter laden mit Verfuegbarkeitspruefung
 * - Filtern und Suchen
 * - Mitarbeiter zuordnen
 */

import { Bridge } from '../../../api/bridgeClient.js';

// ============================================
// State
// ============================================
const state = {
    auftraege: [],
    schichten: [],
    mitarbeiter: [],
    selectedAuftrag: null,
    selectedDatum: null,
    selectedSchicht: null,
    selectedMAs: new Set(),
    filteredMitarbeiter: [],
    filter: {
        typ: 'alle',
        nurAktive: true,
        suche: ''
    }
};

// ============================================
// DOM Elements
// ============================================
let elements = {};

// ============================================
// Initialisierung
// ============================================
function init() {
    console.log('[Schnellauswahl] Initialisierung...');

    elements = {
        // Filter
        cboAuftrag: document.getElementById('cboAuftrag'),
        datEinsatz: document.getElementById('datEinsatz'),
        cboSchicht: document.getElementById('cboSchicht'),
        txtSuche: document.getElementById('txtSuche'),
        chkNurAktive: document.getElementById('chkNurAktive'),

        // Buttons
        btnZuordnen: document.getElementById('btnZuordnen'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        btnMailSelected: document.getElementById('btnMailSelected'),
        btnMail: document.getElementById('btnMail'),
        filterButtons: document.querySelectorAll('.filter-btn'),

        // Liste
        maList: document.getElementById('maList'),

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

    // Heutiges Datum als Default
    if (elements.datEinsatz) {
        elements.datEinsatz.valueAsDate = new Date();
        state.selectedDatum = elements.datEinsatz.value;
    }

    setupEventListeners();
    loadAuftraege();
}

// ============================================
// Event Listeners
// ============================================
function setupEventListeners() {
    // Auftrag-Auswahl
    elements.cboAuftrag?.addEventListener('change', () => {
        state.selectedAuftrag = elements.cboAuftrag.value;
        if (state.selectedAuftrag) {
            loadSchichten();
        }
    });

    // Datum-Auswahl
    elements.datEinsatz?.addEventListener('change', () => {
        state.selectedDatum = elements.datEinsatz.value;
        loadMitarbeiter();
    });

    // Schicht-Auswahl
    elements.cboSchicht?.addEventListener('change', () => {
        state.selectedSchicht = elements.cboSchicht.value;
    });

    // Suche
    elements.txtSuche?.addEventListener('input', debounce(() => {
        state.filter.suche = elements.txtSuche.value.toLowerCase();
        renderMitarbeiterListe();
    }, 200));

    // Nur Aktive
    elements.chkNurAktive?.addEventListener('change', () => {
        state.filter.nurAktive = elements.chkNurAktive.checked;
        loadMitarbeiter();
    });

    // Filter-Buttons
    elements.filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            elements.filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            state.filter.typ = btn.dataset.filter;
            renderMitarbeiterListe();
        });
    });

    // Zuordnen Button
    elements.btnZuordnen?.addEventListener('click', zuordnenAuswahl);

    // Aktualisieren Button
    elements.btnAktualisieren?.addEventListener('click', loadMitarbeiter);

    // E-Mail Anfragen
    elements.btnMailSelected?.addEventListener('click', () => versendeAnfragen(false));
    elements.btnMail?.addEventListener('click', () => versendeAnfragen(true));
}

// ============================================
// Auftraege laden
// ============================================
async function loadAuftraege() {
    try {
        setStatus('Lade Auftraege...');

        const result = await Bridge.auftraege.list({ limit: 200 });
        state.auftraege = result.data || [];

        // Dropdown befuellen
        if (elements.cboAuftrag) {
            elements.cboAuftrag.innerHTML = '<option value="">-- Auftrag waehlen --</option>';
            state.auftraege.forEach(a => {
                const opt = document.createElement('option');
                opt.value = a.VA_ID || a.ID;
                opt.textContent = `${a.Auftrag || a.VA_Bezeichnung || ''} - ${a.Objekt || a.VA_Objekt || ''}`;
                elements.cboAuftrag.appendChild(opt);
            });
        }

        setStatus('Auftraege geladen');

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden Auftraege:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Schichten laden
// ============================================
async function loadSchichten() {
    if (!state.selectedAuftrag) return;

    try {
        setStatus('Lade Schichten...');

        const result = await Bridge.execute('getSchichten', {
            va_id: state.selectedAuftrag,
            von: state.selectedDatum,
            bis: state.selectedDatum
        });

        state.schichten = result.data || [];

        // Dropdown befuellen
        if (elements.cboSchicht) {
            elements.cboSchicht.innerHTML = '<option value="">-- Schicht --</option>';
            state.schichten.forEach(s => {
                const opt = document.createElement('option');
                opt.value = s.ID || s.VAS_ID;
                const von = formatTime(s.VA_Start || s.VAS_Von);
                const bis = formatTime(s.VA_Ende || s.VAS_Bis);
                opt.textContent = `${von} - ${bis}`;
                elements.cboSchicht.appendChild(opt);
            });
        }

        // Mitarbeiter laden
        loadMitarbeiter();

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden Schichten:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Mitarbeiter laden
// ============================================
async function loadMitarbeiter() {
    try {
        setStatus('Lade Mitarbeiter...');

        // Alle aktiven MA laden
        const result = await Bridge.mitarbeiter.list({
            aktiv: state.filter.nurAktive
        });

        let mitarbeiter = result.data || [];

        // Verfuegbarkeit pruefen wenn Datum gewaehlt
        if (state.selectedDatum) {
            const verfResult = await Bridge.execute('checkVerfuegbarkeit', {
                datum: state.selectedDatum
            });
            const verfuegbareIds = new Set((verfResult.data || []).map(v => v.ID || v.MA_ID));

            mitarbeiter = mitarbeiter.map(ma => ({
                ...ma,
                isVerfuegbar: verfuegbareIds.has(ma.ID)
            }));
        }

        state.mitarbeiter = mitarbeiter;
        state.selectedMAs.clear();
        renderMitarbeiterListe();
        updateAnzahl();
        setStatus(`${state.mitarbeiter.length} Mitarbeiter`);

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Laden MA:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Mitarbeiter-Liste rendern
// ============================================
function renderMitarbeiterListe() {
    if (!elements.maList) return;

    // Filtern
    let gefiltert = state.mitarbeiter.filter(ma => {
        // Suche
        if (state.filter.suche) {
            const name = `${ma.Nachname} ${ma.Vorname}`.toLowerCase();
            if (!name.includes(state.filter.suche)) return false;
        }

        // Filter-Typ
        switch (state.filter.typ) {
            case 'verfügbar':
                if (!ma.isVerfuegbar) return false;
                break;
            case 'quali':
                // Nur MA mit Qualifikation (z.B. 34a)
                if (!ma.Hat34a && !ma.Qualifikation) return false;
                break;
            case 'favorit':
                // Nur Favoriten
                if (!ma.IstFavorit) return false;
                break;
        }

        return true;
    });

    state.filteredMitarbeiter = gefiltert;

    if (gefiltert.length === 0) {
        elements.maList.innerHTML = `
            <div style="padding:40px; text-align:center; color:#666;">
                Keine Mitarbeiter gefunden
            </div>
        `;
        return;
    }

    elements.maList.innerHTML = gefiltert.map(ma => {
        const id = ma.ID;
        const name = `${ma.Nachname}, ${ma.Vorname}`;
        const isSelected = state.selectedMAs.has(id);
        const isVerfuegbar = ma.isVerfuegbar !== false;

        // Status bestimmen
        let statusClass = 'verfügbar';
        let statusText = 'Verfuegbar';

        if (!isVerfuegbar) {
            statusClass = 'belegt';
            statusText = 'Nicht verfuegbar';
        }

        // Info zusammenstellen
        const infos = [];
        if (ma.Hat34a) infos.push('34a');
        if (ma.Fuehrerschein) infos.push('Fahrer');
        const infoText = infos.join(', ');

        return `
            <div class="ma-item ${isSelected ? 'selected' : ''} ${!isVerfuegbar ? 'unavailable' : ''}" data-id="${id}">
                <input type="checkbox" class="ma-checkbox" ${isSelected ? 'checked' : ''} ${!isVerfuegbar ? 'disabled' : ''}>
                <span class="ma-name">${name}</span>
                ${infoText ? `<span class="ma-info">${infoText}</span>` : ''}
                <span class="ma-status ${statusClass}">${statusText}</span>
            </div>
        `;
    }).join('');

    // Event Listener
    elements.maList.querySelectorAll('.ma-item').forEach(item => {
        const id = parseInt(item.dataset.id);
        const checkbox = item.querySelector('.ma-checkbox');

        item.addEventListener('click', (e) => {
            if (e.target === checkbox) return;
            if (checkbox.disabled) return;

            checkbox.checked = !checkbox.checked;
            toggleSelection(id, checkbox.checked);
        });

        checkbox?.addEventListener('change', () => {
            toggleSelection(id, checkbox.checked);
        });
    });

    updateAnzahl();
}

// ============================================
// Auswahl verwalten
// ============================================
function toggleSelection(id, selected) {
    if (selected) {
        state.selectedMAs.add(id);
    } else {
        state.selectedMAs.delete(id);
    }

    // Visuelles Update
    const item = elements.maList?.querySelector(`[data-id="${id}"]`);
    item?.classList.toggle('selected', selected);

    updateAnzahl();
}

// ============================================
// Zuordnen
// ============================================
async function zuordnenAuswahl() {
    if (state.selectedMAs.size === 0) {
        alert('Bitte mindestens einen Mitarbeiter auswaehlen');
        return;
    }

    if (!state.selectedAuftrag) {
        alert('Bitte zuerst einen Auftrag auswaehlen');
        return;
    }

    const bestaetigung = confirm(`${state.selectedMAs.size} Mitarbeiter zuordnen?`);
    if (!bestaetigung) return;

    try {
        setStatus(`Ordne ${state.selectedMAs.size} Mitarbeiter zu...`);

        let erfolg = 0;
        let fehler = 0;

        for (const maId of state.selectedMAs) {
            try {
                await Bridge.zuordnungen.create({
                    ma_id: maId,
                    va_id: parseInt(state.selectedAuftrag),
                    vastart_id: state.selectedSchicht ? parseInt(state.selectedSchicht) : null,
                    vadatum: state.selectedDatum
                });
                erfolg++;

            } catch (e) {
                console.error(`Fehler bei MA ${maId}:`, e);
                fehler++;
            }
        }

        if (fehler === 0) {
            setStatus(`${erfolg} Mitarbeiter erfolgreich zugeordnet`);
        } else {
            setStatus(`${erfolg} zugeordnet, ${fehler} Fehler`);
        }

        // Auswahl zuruecksetzen und neu laden
        state.selectedMAs.clear();
        loadMitarbeiter();

    } catch (error) {
        console.error('[Schnellauswahl] Fehler beim Zuordnen:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Helper
// ============================================
function formatTime(value) {
    if (!value) return '';
    if (typeof value === 'string' && value.includes(':')) {
        return value.substring(0, 5);
    }
    // Dezimalwert (Access)
    if (typeof value === 'number' && value < 1) {
        const hours = Math.floor(value * 24);
        const mins = Math.round((value * 24 - hours) * 60);
        return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
    }
    try {
        return new Date(value).toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
    } catch {
        return value;
    }
}

function debounce(fn, delay) {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), delay);
    };
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function updateAnzahl() {
    if (elements.lblAnzahl) {
        const total = state.mitarbeiter.length;
        const selected = state.selectedMAs.size;
        elements.lblAnzahl.textContent = selected > 0
            ? `${selected} von ${total} ausgewaehlt`
            : `${total} Mitarbeiter`;
    }
}

// ============================================
// Anfragen / E-Mail (Schnellauswahl)
// ============================================
const TEST_EMAIL_RECIPIENT = 'siegert@consec-nuernberg.de';

async function versendeAnfragen(alle) {
    if (!state.selectedAuftrag || !state.selectedDatum) {
        alert('Bitte Auftrag und Datum auswaehlen.');
        return;
    }

    const maIds = alle
        ? state.filteredMitarbeiter.map(m => m.ID || m.MA_ID).filter(Boolean)
        : Array.from(state.selectedMAs);

    if (maIds.length === 0) {
        alert('Keine Mitarbeiter ausgewaehlt.');
        return;
    }

    const bestaetigung = confirm(`${maIds.length} Mitarbeiter anfragen?`);
    if (!bestaetigung) return;

    setStatus(`Sende Anfragen an ${maIds.length} Mitarbeiter...`);

    const schicht = state.schichten.find(s => (s.ID || s.VAS_ID) === state.selectedSchicht) || {};
    const payloadBase = {
        VA_ID: state.selectedAuftrag,
        VADatum_ID: schicht.VADatum_ID || null,
        VAStart_ID: schicht.VAStart_ID || schicht.ID || schicht.VAS_ID || null,
        Status_ID: 1
    };

    for (const maId of maIds) {
        await Bridge.execute('createAnfrage', {
            ...payloadBase,
            MA_ID: maId
        });
    }

    // Test-Email (nur an definierte Adresse)
    const subject = encodeURIComponent(`Anfrage Auftrag ${state.selectedAuftrag}`);
    const body = encodeURIComponent(`Anfrage fuer Auftrag ${state.selectedAuftrag} am ${state.selectedDatum}\\nMitarbeiter: ${maIds.join(', ')}`);
    window.open(`mailto:${TEST_EMAIL_RECIPIENT}?subject=${subject}&body=${body}`);

    setStatus(`Anfragen erstellt (${maIds.length}).`);
}

// ============================================
// Export
// ============================================
window.SchnellauswahlForm = {
    reload: loadMitarbeiter,
    getSelected: () => Array.from(state.selectedMAs)
};

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);
