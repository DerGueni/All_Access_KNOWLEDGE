/**
 * zfrm_Lohnabrechnungen.logic.js
 * Logik für Lohnabrechnungen-Übersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../api/bridgeClient.js';

const state = {
    abrechnungen: [],
    selectedAbrechnung: null,
    monat: new Date().getMonth() + 1,
    jahr: new Date().getFullYear(),
    statusFilter: ''
};

let elements = {};

async function init() {
    console.log('[Lohnabrechnungen] Initialisierung...');

    elements = {
        // Filter
        cboMonat: document.getElementById('cboMonat'),
        cboJahr: document.getElementById('cboJahr'),
        cboStatus: document.getElementById('cboStatus'),

        // Aktionen
        btnErstellen: document.getElementById('btnErstellen'),
        btnExportLexware: document.getElementById('btnExportLexware'),

        // Stats
        statGesamt: document.getElementById('statGesamt'),
        statOffen: document.getElementById('statOffen'),
        statErstellt: document.getElementById('statErstellt'),
        statVersendet: document.getElementById('statVersendet'),

        // Liste
        abrechnungListe: document.querySelector('.content-main'),

        // Detail
        detailContent: document.querySelector('.detail-content'),

        // Footer
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    setupEventListeners();
    initFilter();
    await loadAbrechnungen();
    setStatus('Bereit');
}

function setupEventListeners() {
    if (elements.cboMonat) {
        elements.cboMonat.addEventListener('change', () => {
            state.monat = parseInt(elements.cboMonat.value);
            loadAbrechnungen();
        });
    }

    if (elements.cboJahr) {
        elements.cboJahr.addEventListener('change', () => {
            state.jahr = parseInt(elements.cboJahr.value);
            loadAbrechnungen();
        });
    }

    if (elements.cboStatus) {
        elements.cboStatus.addEventListener('change', () => {
            state.statusFilter = elements.cboStatus.value;
            loadAbrechnungen();
        });
    }

    if (elements.btnErstellen) {
        elements.btnErstellen.addEventListener('click', erstelleAbrechnungen);
    }

    if (elements.btnExportLexware) {
        elements.btnExportLexware.addEventListener('click', () => {
            window.location.href = 'zfrm_MA_Stunden_Lexware.html';
        });
    }
}

function initFilter() {
    if (elements.cboMonat) elements.cboMonat.value = state.monat;
    if (elements.cboJahr) elements.cboJahr.value = state.jahr;
}

async function loadAbrechnungen() {
    setStatus('Lade Abrechnungen...');
    try {
        const params = {
            monat: state.monat,
            jahr: state.jahr,
            status: state.statusFilter || null
        };

        const result = await Bridge.lohn.abrechnungen(params);
        state.abrechnungen = result.data || [];

        renderAbrechnungen();
        updateStats();
        updateAnzahl();
        setStatus(`${state.abrechnungen.length} Abrechnungen geladen`);

    } catch (error) {
        console.error('[Lohnabrechnungen] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function renderAbrechnungen() {
    const container = elements.abrechnungListe;
    if (!container) return;

    if (state.abrechnungen.length === 0) {
        container.innerHTML = `
            <div style="text-align:center;padding:40px;color:#666;">
                Keine Abrechnungen für diesen Zeitraum
            </div>
        `;
        return;
    }

    container.innerHTML = state.abrechnungen.map(a => {
        const statusClass = getStatusClass(a.Status);
        const statusText = a.Status || 'Offen';
        const selected = state.selectedAbrechnung?.ID === a.ID ? 'selected' : '';

        return `
            <div class="abrechnung-item ${selected}" data-id="${a.ID}">
                <div class="abrechnung-icon">📄</div>
                <div class="abrechnung-info">
                    <div class="abrechnung-periode">${getMonatName(state.monat)} ${state.jahr}</div>
                    <div class="abrechnung-detail">${a.MA_Nachname}, ${a.MA_Vorname}</div>
                </div>
                <div class="abrechnung-status">
                    <span class="status-badge ${statusClass}">${statusText}</span>
                    <div class="abrechnung-betrag">${formatBetrag(a.Brutto)} EUR</div>
                </div>
            </div>
        `;
    }).join('');

    // Click-Handler
    container.querySelectorAll('.abrechnung-item').forEach(item => {
        item.addEventListener('click', () => {
            const id = parseInt(item.dataset.id);
            selectAbrechnung(id);
        });
    });

    // Erste automatisch auswählen
    if (!state.selectedAbrechnung && state.abrechnungen.length > 0) {
        selectAbrechnung(state.abrechnungen[0].ID);
    }
}

function selectAbrechnung(id) {
    state.selectedAbrechnung = state.abrechnungen.find(a => a.ID === id);
    displayDetail(state.selectedAbrechnung);

    // Selection aktualisieren
    elements.abrechnungListe.querySelectorAll('.abrechnung-item').forEach(item => {
        item.classList.toggle('selected', parseInt(item.dataset.id) === id);
    });
}

function displayDetail(a) {
    if (!elements.detailContent || !a) return;

    elements.detailContent.innerHTML = `
        <div class="detail-section">
            <div class="detail-section-title">Mitarbeiter</div>
            <div class="info-grid">
                <div class="info-item"><span class="info-label">Name:</span><span class="info-value">${a.MA_Nachname}, ${a.MA_Vorname}</span></div>
                <div class="info-item"><span class="info-label">Personal-Nr:</span><span class="info-value">${a.MA_PersonalNr || '-'}</span></div>
                <div class="info-item"><span class="info-label">Steuerklasse:</span><span class="info-value">${a.Steuerklasse || '-'}</span></div>
                <div class="info-item"><span class="info-label">Konfession:</span><span class="info-value">${a.Konfession || '-'}</span></div>
            </div>
        </div>
        <div class="detail-section">
            <div class="detail-section-title">Arbeitszeit</div>
            <div class="info-grid">
                <div class="info-item"><span class="info-label">Soll-Stunden:</span><span class="info-value">${formatZahl(a.SollStunden)}</span></div>
                <div class="info-item"><span class="info-label">Ist-Stunden:</span><span class="info-value">${formatZahl(a.IstStunden)}</span></div>
                <div class="info-item"><span class="info-label">Überstunden:</span><span class="info-value">${formatZahl(a.Ueberstunden)}</span></div>
                <div class="info-item"><span class="info-label">Urlaub (Tage):</span><span class="info-value">${a.Urlaubstage || 0}</span></div>
            </div>
        </div>
        <div class="detail-section">
            <div class="detail-section-title">Vergütung</div>
            <div class="info-grid">
                <div class="info-item"><span class="info-label">Brutto:</span><span class="info-value">${formatBetrag(a.Brutto)} EUR</span></div>
                <div class="info-item"><span class="info-label">Netto:</span><span class="info-value">${formatBetrag(a.Netto)} EUR</span></div>
                <div class="info-item"><span class="info-label">Zuschläge:</span><span class="info-value">${formatBetrag(a.Zuschlaege)} EUR</span></div>
                <div class="info-item"><span class="info-label">Abzüge:</span><span class="info-value">${formatBetrag(a.Abzuege)} EUR</span></div>
            </div>
        </div>
        <div class="detail-section">
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <button class="btn btn-sm" onclick="LohnAbrechnungen.erstellePDF(${a.ID})">PDF erstellen</button>
                <button class="btn btn-sm" onclick="LohnAbrechnungen.sendeEmail(${a.ID})">Per E-Mail senden</button>
                <button class="btn btn-sm" onclick="LohnAbrechnungen.korrigieren(${a.ID})">Korrigieren</button>
            </div>
        </div>
    `;
}

function updateStats() {
    const gesamt = state.abrechnungen.length;
    const offen = state.abrechnungen.filter(a => !a.Status || a.Status === 'offen').length;
    const erstellt = state.abrechnungen.filter(a => a.Status === 'erstellt').length;
    const versendet = state.abrechnungen.filter(a => a.Status === 'versendet').length;

    if (elements.statGesamt) elements.statGesamt.textContent = gesamt;
    if (elements.statOffen) elements.statOffen.textContent = offen;
    if (elements.statErstellt) elements.statErstellt.textContent = erstellt;
    if (elements.statVersendet) elements.statVersendet.textContent = versendet;
}

function updateAnzahl() {
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.abrechnungen.length} Abrechnungen`;
    }
}

async function erstelleAbrechnungen() {
    if (!confirm('Abrechnungen für alle Mitarbeiter erstellen?')) return;

    setStatus('Erstelle Abrechnungen...');
    try {
        await Bridge.execute('erstelleAbrechnungen', {
            monat: state.monat,
            jahr: state.jahr
        });
        setStatus('Abrechnungen erstellt');
        await loadAbrechnungen();
    } catch (error) {
        console.error('[Lohnabrechnungen] Fehler:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler: ' + error.message);
    }
}

function erstellePDF(id) {
    alert('PDF-Export wird gestartet für ID: ' + id);
}

function sendeEmail(id) {
    alert('E-Mail-Versand für ID: ' + id);
}

function korrigieren(id) {
    alert('Korrektur für ID: ' + id);
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function getStatusClass(status) {
    switch (status?.toLowerCase()) {
        case 'offen': return 'status-offen';
        case 'erstellt': return 'status-erstellt';
        case 'versendet': return 'status-versendet';
        case 'fehler': return 'status-fehler';
        default: return 'status-offen';
    }
}

function getMonatName(monat) {
    const monate = ['', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
                    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
    return monate[monat] || '';
}

function formatBetrag(value) {
    if (!value && value !== 0) return '0,00';
    return Number(value).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function formatZahl(value) {
    if (!value && value !== 0) return '0,00';
    return Number(value).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

document.addEventListener('DOMContentLoaded', init);

window.LohnAbrechnungen = {
    loadAbrechnungen,
    selectAbrechnung,
    erstelleAbrechnungen,
    erstellePDF,
    sendeEmail,
    korrigieren
};
