/**
 * zfrm_MA_Stunden_Lexware.logic.js
 * Business Logic für Lexware Stunden Import/Export
 *
 * Funktionalität:
 * - Import von Lexware-Stundendaten
 * - Export zu Lexware
 * - Zeitkonten-Auswertungen (Mini, Fest, Einzeln)
 * - Abgleich Lexware vs. Consys
 * - Fehlerprotokollierung
 */

'use strict';

const API_BASE = 'http://localhost:5000/api';

// State
const state = {
    stundenData: [],
    abgleichData: [],
    fehlerData: [],
    mitarbeiterList: [],
    selectedMA: null,
    zeitraumVon: null,
    zeitraumBis: null,
    anstellungsart: null
};

// ============================================
// INITIALISIERUNG
// ============================================
document.addEventListener('DOMContentLoaded', async function() {
    console.log('[Lexware Stunden] Initializing...');

    // Event-Listener
    setupEventListeners();

    // Aktuellen Monat vorausfüllen
    setCurrentMonth();

    // Mitarbeiter laden
    await loadMitarbeiter();

    console.log('[Lexware Stunden] Initialized');
});

function setupEventListeners() {
    // Zeitraum-Auswahl
    document.getElementById('cboZeitraum').addEventListener('change', handleZeitraumChange);

    // Mitarbeiter-Filter
    document.getElementById('cboMA').addEventListener('change', () => {
        state.selectedMA = document.getElementById('cboMA').value || null;
        refreshData();
    });

    // Anstellungsart-Filter
    document.getElementById('cboAnstArt').addEventListener('change', () => {
        state.anstellungsart = document.getElementById('cboAnstArt').value || null;
        refreshData();
    });

    // Datumsänderungen
    document.getElementById('AU_von').addEventListener('change', () => {
        state.zeitraumVon = document.getElementById('AU_von').value;
        refreshData();
    });

    document.getElementById('AU_bis').addEventListener('change', () => {
        state.zeitraumBis = document.getElementById('AU_bis').value;
        refreshData();
    });

    // Button Handlers (Override globale Funktionen)
    window.handleImport = handleImport;
    window.handleExport = handleExport;
    window.handleZKMini = handleZKMini;
    window.handleZKFest = handleZKFest;
    window.handleZKEinzel = handleZKEinzel;
    window.handleExportDiff = handleExportDiff;
    window.handleZKMiniAbrech = handleZKMiniAbrech;
    window.handleZKFestAbrech = handleZKFestAbrech;
}

// ============================================
// DATUMS-FUNKTIONEN
// ============================================
function setCurrentMonth() {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    document.getElementById('AU_von').value = formatDateForInput(firstDay);
    document.getElementById('AU_bis').value = formatDateForInput(lastDay);

    state.zeitraumVon = formatDateForInput(firstDay);
    state.zeitraumBis = formatDateForInput(lastDay);
}

function handleZeitraumChange(e) {
    const value = e.target.value;
    const now = new Date();
    let von, bis;

    switch(value) {
        case 'aktuell':
            von = new Date(now.getFullYear(), now.getMonth(), 1);
            bis = new Date(now.getFullYear(), now.getMonth() + 1, 0);
            break;

        case 'vormonat':
            von = new Date(now.getFullYear(), now.getMonth() - 1, 1);
            bis = new Date(now.getFullYear(), now.getMonth(), 0);
            break;

        case 'quartal':
            const quarter = Math.floor(now.getMonth() / 3);
            von = new Date(now.getFullYear(), quarter * 3, 1);
            bis = new Date(now.getFullYear(), (quarter + 1) * 3, 0);
            break;

        case 'jahr':
            von = new Date(now.getFullYear(), 0, 1);
            bis = new Date(now.getFullYear(), 11, 31);
            break;

        case 'custom':
            // Keine Änderung, User setzt manuell
            return;

        default:
            return;
    }

    document.getElementById('AU_von').value = formatDateForInput(von);
    document.getElementById('AU_bis').value = formatDateForInput(bis);

    state.zeitraumVon = formatDateForInput(von);
    state.zeitraumBis = formatDateForInput(bis);

    refreshData();
}

function formatDateForInput(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function formatDateDE(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

// ============================================
// API-FUNKTIONEN
// ============================================
async function apiCall(endpoint, method = 'GET', data = null) {
    const options = {
        method: method,
        headers: { 'Content-Type': 'application/json' }
    };

    if (data && method !== 'GET') {
        options.body = JSON.stringify(data);
    }

    try {
        const response = await fetch(`${API_BASE}${endpoint}`, options);
        const result = await response.json();
        if (!response.ok) {
            throw new Error(result.error || 'API-Fehler');
        }
        return result;
    } catch (e) {
        console.error('API Error:', e);
        showNotification('API-Fehler: ' + e.message, 'error');
        throw e;
    }
}

async function loadMitarbeiter() {
    try {
        showLoading(true);
        const result = await apiCall('/mitarbeiter?aktiv=true');
        state.mitarbeiterList = result.data || [];

        // Mitarbeiter-Dropdown befüllen
        const cboMA = document.getElementById('cboMA');
        cboMA.innerHTML = '<option value="">-- Alle --</option>';

        state.mitarbeiterList.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = `${ma.Nachname}, ${ma.Vorname} (${ma.ID})`;
            cboMA.appendChild(option);
        });

        console.log(`[Lexware] ${state.mitarbeiterList.length} Mitarbeiter geladen`);
    } catch (e) {
        console.error('Mitarbeiter laden fehlgeschlagen:', e);
    } finally {
        showLoading(false);
    }
}

async function loadStundenData() {
    try {
        showLoading(true);

        // Parameter zusammenstellen
        const params = new URLSearchParams();
        if (state.zeitraumVon) params.append('von', state.zeitraumVon);
        if (state.zeitraumBis) params.append('bis', state.zeitraumBis);
        if (state.selectedMA) params.append('ma_id', state.selectedMA);
        if (state.anstellungsart) params.append('anstellungsart', state.anstellungsart);

        const result = await apiCall(`/stunden?${params.toString()}`);
        state.stundenData = result.data || [];

        renderStundenTable();
        updateStatusBar();

        console.log(`[Lexware] ${state.stundenData.length} Stunden geladen`);
    } catch (e) {
        console.error('Stunden laden fehlgeschlagen:', e);
        state.stundenData = [];
        renderStundenTable();
    } finally {
        showLoading(false);
    }
}

async function loadAbgleichData() {
    try {
        showLoading(true);

        const params = new URLSearchParams();
        if (state.zeitraumVon) params.append('von', state.zeitraumVon);
        if (state.zeitraumBis) params.append('bis', state.zeitraumBis);
        if (state.selectedMA) params.append('ma_id', state.selectedMA);
        if (state.anstellungsart) params.append('anstellungsart', state.anstellungsart);

        const result = await apiCall(`/stunden/abgleich?${params.toString()}`);
        state.abgleichData = result.data || [];

        renderAbgleichTable();

        console.log(`[Lexware] ${state.abgleichData.length} Abgleicheinträge geladen`);
    } catch (e) {
        console.error('Abgleich laden fehlgeschlagen:', e);
        state.abgleichData = [];
        renderAbgleichTable();
    } finally {
        showLoading(false);
    }
}

async function loadFehlerData() {
    try {
        showLoading(true);

        const result = await apiCall('/zeitkonten/importfehler');
        state.fehlerData = result.data || [];

        renderFehlerTable();

        console.log(`[Lexware] ${state.fehlerData.length} Fehler geladen`);
    } catch (e) {
        console.error('Fehler laden fehlgeschlagen:', e);
        state.fehlerData = [];
        renderFehlerTable();
    } finally {
        showLoading(false);
    }
}

// ============================================
// RENDERING-FUNKTIONEN
// ============================================
function renderStundenTable() {
    const tbody = document.getElementById('tbodyStunden');
    tbody.innerHTML = '';

    if (state.stundenData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="empty-state">Keine Daten vorhanden. Bitte Import durchführen.</td></tr>';
        return;
    }

    state.stundenData.forEach(row => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${escapeHtml(row.MA_ID || '')}</td>
            <td>${escapeHtml(row.Nachname || '')}</td>
            <td>${escapeHtml(row.Vorname || '')}</td>
            <td>${formatDateDE(row.Datum)}</td>
            <td>${escapeHtml(row.Stunden || '0')}</td>
            <td>${escapeHtml(row.Zuschlag || '0')}</td>
            <td>${escapeHtml(row.Auftrag || '')}</td>
            <td>${escapeHtml(row.Status || 'OK')}</td>
        `;
        tbody.appendChild(tr);
    });
}

function renderAbgleichTable() {
    const tbody = document.getElementById('tbodyAbgleich');
    tbody.innerHTML = '';

    if (state.abgleichData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="empty-state">Keine Abgleichdaten vorhanden.</td></tr>';
        return;
    }

    state.abgleichData.forEach(row => {
        const differenz = (parseFloat(row.Lexware_Std || 0) - parseFloat(row.Consys_Std || 0)).toFixed(2);
        const status = Math.abs(differenz) < 0.01 ? 'OK' : 'DIFFERENZ';
        const rowClass = status === 'DIFFERENZ' ? 'error-row' : 'success-row';

        const tr = document.createElement('tr');
        tr.className = rowClass;
        tr.innerHTML = `
            <td>${escapeHtml(row.MA_ID || '')}</td>
            <td>${escapeHtml(row.Nachname || '')}</td>
            <td>${escapeHtml(row.Vorname || '')}</td>
            <td>${formatDateDE(row.Datum)}</td>
            <td>${escapeHtml(row.Lexware_Std || '0')}</td>
            <td>${escapeHtml(row.Consys_Std || '0')}</td>
            <td>${differenz}</td>
            <td>${status}</td>
        `;
        tbody.appendChild(tr);
    });
}

function renderFehlerTable() {
    const tbody = document.getElementById('tbodyFehler');
    tbody.innerHTML = '';

    if (state.fehlerData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Keine Importfehler.</td></tr>';
        return;
    }

    state.fehlerData.forEach(row => {
        const tr = document.createElement('tr');
        tr.className = 'error-row';
        tr.innerHTML = `
            <td>${escapeHtml(row.Zeile || '')}</td>
            <td>${escapeHtml(row.MA_Nr || '')}</td>
            <td>${formatDateDE(row.Datum)}</td>
            <td>${escapeHtml(row.Fehlertyp || '')}</td>
            <td>${escapeHtml(row.Fehlermeldung || '')}</td>
            <td>${escapeHtml(row.Rohdaten || '')}</td>
        `;
        tbody.appendChild(tr);
    });
}

// ============================================
// BUTTON-HANDLER
// ============================================
async function handleImport() {
    showNotification('Import-Funktion: Bitte Lexware-Datei auswählen (Funktion in Entwicklung)', 'info');

    // Simulation: Nach Import Daten neu laden
    setTimeout(async () => {
        await loadStundenData();
        await loadFehlerData();
        showNotification('Import abgeschlossen', 'success');
    }, 1000);
}

async function handleExport() {
    if (state.stundenData.length === 0) {
        showNotification('Keine Daten zum Exportieren vorhanden', 'warning');
        return;
    }

    showNotification('Exportiere Daten zu Lexware...', 'info');

    try {
        showLoading(true);

        // CSV-Export simulieren
        const csv = generateCSV(state.stundenData);
        downloadFile(csv, 'lexware_export.csv', 'text/csv');

        showNotification('Export erfolgreich', 'success');
    } catch (e) {
        showNotification('Export fehlgeschlagen: ' + e.message, 'error');
    } finally {
        showLoading(false);
    }
}

async function handleZKMini() {
    showNotification('Zeitkonto Mini: Nur Minijobber', 'info');

    // Filter auf Anstellungsart 5 setzen
    document.getElementById('cboAnstArt').value = '5';
    state.anstellungsart = '5';

    await loadStundenData();
}

async function handleZKFest() {
    showNotification('Zeitkonto Fest: Nur Festangestellte', 'info');

    // Filter auf Anstellungsart 3 setzen
    document.getElementById('cboAnstArt').value = '3';
    state.anstellungsart = '3';

    await loadStundenData();
}

async function handleZKEinzel() {
    if (!state.selectedMA) {
        showNotification('Bitte Mitarbeiter auswählen', 'warning');
        return;
    }

    showNotification(`Zeitkonto für MA ${state.selectedMA}`, 'info');
    await loadStundenData();
}

async function handleExportDiff() {
    showNotification('Lade Abgleichdaten...', 'info');

    // Zum Abgleich-Tab wechseln
    document.querySelector('[data-tab="abgleich"]').click();

    await loadAbgleichData();
}

async function handleZKMiniAbrech() {
    showNotification('Zeitkonto Mini Abrechnung (Funktion in Entwicklung)', 'info');
}

async function handleZKFestAbrech() {
    showNotification('Zeitkonto Fest Abrechnung (Funktion in Entwicklung)', 'info');
}

// ============================================
// HILFSFUNKTIONEN
// ============================================
function refreshData() {
    // Je nach aktivem Tab entsprechende Daten laden
    const activeTab = document.querySelector('.tab-pane.active').id;

    if (activeTab === 'tab-stunden') {
        loadStundenData();
    } else if (activeTab === 'tab-abgleich') {
        loadAbgleichData();
    } else if (activeTab === 'tab-fehler') {
        loadFehlerData();
    }
}

function updateStatusBar() {
    const statusLeft = document.getElementById('statusLeft');
    const statusRight = document.getElementById('statusRight');

    const activeTab = document.querySelector('.tab-pane.active').id;
    let count = 0;

    if (activeTab === 'tab-stunden') {
        count = state.stundenData.length;
        statusLeft.textContent = `Stunden geladen: ${count}`;
    } else if (activeTab === 'tab-abgleich') {
        count = state.abgleichData.length;
        const fehler = state.abgleichData.filter(row => {
            const diff = Math.abs((parseFloat(row.Lexware_Std || 0) - parseFloat(row.Consys_Std || 0)));
            return diff >= 0.01;
        }).length;
        statusLeft.textContent = `Abgleich: ${count} Einträge, ${fehler} Differenzen`;
    } else if (activeTab === 'tab-fehler') {
        count = state.fehlerData.length;
        statusLeft.textContent = `Fehler: ${count}`;
    }

    statusRight.textContent = `Datensätze: ${count}`;
}

function generateCSV(data) {
    const headers = ['MA_ID', 'Nachname', 'Vorname', 'Datum', 'Stunden', 'Zuschlag', 'Auftrag', 'Status'];
    const rows = data.map(row => [
        row.MA_ID || '',
        row.Nachname || '',
        row.Vorname || '',
        row.Datum || '',
        row.Stunden || '0',
        row.Zuschlag || '0',
        row.Auftrag || '',
        row.Status || 'OK'
    ]);

    const csvContent = [
        headers.join(';'),
        ...rows.map(row => row.join(';'))
    ].join('\n');

    return csvContent;
}

function downloadFile(content, filename, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    if (show) {
        overlay.classList.add('active');
    } else {
        overlay.classList.remove('active');
    }
}

function showNotification(message, type = 'info') {
    console.log(`[${type.toUpperCase()}] ${message}`);

    // Optional: Toast-Notification anzeigen
    const statusLeft = document.getElementById('statusLeft');
    statusLeft.textContent = message;

    // Nach 3 Sekunden zurücksetzen
    setTimeout(() => {
        updateStatusBar();
    }, 3000);
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Tab-Wechsel Event-Listener
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        setTimeout(() => {
            refreshData();
            updateStatusBar();
        }, 100);
    });
});

console.log('[Lexware Stunden Logic] Loaded');
