/**
 * frm_Ausweis_Create.logic.js
 * Business Logic für Dienstausweis-Erstellung
 */

'use strict';

const API_BASE = 'http://localhost:5000/api';

// State Management
const state = {
    allEmployees: [],
    selectedEmployees: [],
    validUntil: null
};

// ========================================
// INITIALIZATION
// ========================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Ausweis Create] Initializing...');

    // Set dates
    updateDateDisplays();
    setDefaultValidUntil();

    // Attach event listeners
    attachEventListeners();

    // Load employees
    await loadAllEmployees();

    console.log('[Ausweis Create] Ready');
});

/**
 * Set default validity date to end of current year
 */
function setDefaultValidUntil() {
    const now = new Date();
    const endOfYear = new Date(now.getFullYear(), 11, 31); // Dec 31
    const dateStr = endOfYear.toISOString().split('T')[0];
    document.getElementById('GueltBis').value = dateStr;
    state.validUntil = dateStr;
}

/**
 * Update date displays in header and footer
 */
function updateDateDisplays() {
    const now = new Date();
    const dateStr = now.toLocaleDateString('de-DE');
    const timeStr = now.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });

    document.getElementById('headerDate').textContent = `${dateStr} ${timeStr}`;
    document.getElementById('footerDate').textContent = dateStr;
}

/**
 * Attach all event listeners
 */
function attachEventListeners() {
    // Transfer buttons
    document.getElementById('btnAddSelected').addEventListener('click', addSelected);
    document.getElementById('btnAddAll').addEventListener('click', addAll);
    document.getElementById('btnDelSelected').addEventListener('click', removeSelected);
    document.getElementById('btnDelAll').addEventListener('click', removeAll);
    document.getElementById('btnDeselect').addEventListener('click', deselectAll);

    // Settings
    document.getElementById('GueltBis').addEventListener('change', (e) => {
        state.validUntil = e.target.value;
    });

    // Badge print buttons
    document.getElementById('btn_ausweiseinsatzleitung').addEventListener('click', () => printBadge('Einsatzleitung'));
    document.getElementById('btn_ausweisBereichsleiter').addEventListener('click', () => printBadge('Bereichsleiter'));
    document.getElementById('btn_ausweissec').addEventListener('click', () => printBadge('Security'));
    document.getElementById('btn_ausweisservice').addEventListener('click', () => printBadge('Service'));
    document.getElementById('btn_ausweisplatzanweiser').addEventListener('click', () => printBadge('Platzanweiser'));
    document.getElementById('btn_ausweisstaff').addEventListener('click', () => printBadge('Staff'));

    // Card print buttons
    document.getElementById('btn_Karte_Sicherheit').addEventListener('click', () => printCard('Sicherheit'));
    document.getElementById('btn_Karte_Service').addEventListener('click', () => printCard('Service'));
    document.getElementById('btn_Karte_Rueck').addEventListener('click', () => printCard('Rueckseite'));
    document.getElementById('btn_Sonder').addEventListener('click', () => printCard('Sonder'));

    // List selection changes
    document.getElementById('lstMA_Alle').addEventListener('change', updateCounters);
    document.getElementById('lstMA_Ausweis').addEventListener('change', updateCounters);
}

// ========================================
// API CALLS
// ========================================
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
        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'API Fehler');
        }
        return await response.json();
    } catch (err) {
        console.error('API Error:', err);
        showToast('Fehler: ' + err.message, 'error');
        throw err;
    }
}

/**
 * Load all active employees from API
 */
async function loadAllEmployees() {
    try {
        showLoading(true);
        const result = await apiCall('/mitarbeiter?aktiv=true');
        state.allEmployees = result.data || [];

        // Add badge info (simulate from backend)
        state.allEmployees.forEach(emp => {
            emp.ausweisNr = emp.DienstausweisNr || '-';
            emp.gueltBis = emp.Ausweis_GueltBis || '-';
        });

        renderAllEmployees();
        updateCounters();
    } catch (err) {
        console.error('Load employees failed:', err);
        showToast('Mitarbeiter konnten nicht geladen werden', 'error');
    } finally {
        showLoading(false);
    }
}

// ========================================
// RENDERING
// ========================================
function renderAllEmployees() {
    const listbox = document.getElementById('lstMA_Alle');
    listbox.innerHTML = '';

    state.allEmployees.forEach(emp => {
        const option = document.createElement('option');
        option.value = emp.ID;
        option.textContent = formatEmployeeLine(emp);
        option.dataset.employee = JSON.stringify(emp);
        listbox.appendChild(option);
    });

    document.getElementById('countAll').textContent = state.allEmployees.length;
}

function renderSelectedEmployees() {
    const listbox = document.getElementById('lstMA_Ausweis');
    listbox.innerHTML = '';

    state.selectedEmployees.forEach(emp => {
        const option = document.createElement('option');
        option.value = emp.ID;
        option.textContent = formatEmployeeLine(emp);
        option.dataset.employee = JSON.stringify(emp);
        listbox.appendChild(option);
    });

    document.getElementById('countSelected').textContent = state.selectedEmployees.length;
    updateStatusMessage();
}

function formatEmployeeLine(emp) {
    const name = `${emp.Nachname || ''}, ${emp.Vorname || ''}`.padEnd(30);
    const ausweisNr = (emp.ausweisNr || '-').padEnd(12);
    const gueltBis = formatDate(emp.gueltBis);
    return `${name} | Ausweis: ${ausweisNr} | Gültig: ${gueltBis}`;
}

function formatDate(dateStr) {
    if (!dateStr || dateStr === '-') return '-';
    try {
        const d = new Date(dateStr);
        return d.toLocaleDateString('de-DE');
    } catch {
        return dateStr;
    }
}

function updateCounters() {
    document.getElementById('countAll').textContent = state.allEmployees.length;
    document.getElementById('countSelected').textContent = state.selectedEmployees.length;
    updateStatusMessage();
}

function updateStatusMessage() {
    document.getElementById('statusMessage').textContent =
        `Ausgewählte MA: ${state.selectedEmployees.length}`;
}

// ========================================
// TRANSFER OPERATIONS
// ========================================
function addSelected() {
    const listbox = document.getElementById('lstMA_Alle');
    const selected = Array.from(listbox.selectedOptions);

    if (selected.length === 0) {
        showToast('Bitte Mitarbeiter auswählen', 'warning');
        return;
    }

    selected.forEach(option => {
        const emp = JSON.parse(option.dataset.employee);

        // Check if not already selected
        if (!state.selectedEmployees.find(e => e.ID === emp.ID)) {
            state.selectedEmployees.push(emp);
        }
    });

    renderSelectedEmployees();
    showToast(`${selected.length} Mitarbeiter hinzugefügt`, 'success');
}

function addAll() {
    state.selectedEmployees = [...state.allEmployees];
    renderSelectedEmployees();
    showToast('Alle Mitarbeiter hinzugefügt', 'success');
}

function removeSelected() {
    const listbox = document.getElementById('lstMA_Ausweis');
    const selected = Array.from(listbox.selectedOptions);

    if (selected.length === 0) {
        showToast('Bitte Mitarbeiter in rechter Liste auswählen', 'warning');
        return;
    }

    const selectedIds = selected.map(opt => parseInt(opt.value));
    state.selectedEmployees = state.selectedEmployees.filter(emp => !selectedIds.includes(emp.ID));

    renderSelectedEmployees();
    showToast(`${selected.length} Mitarbeiter entfernt`, 'success');
}

function removeAll() {
    if (state.selectedEmployees.length === 0) {
        showToast('Keine Mitarbeiter ausgewählt', 'info');
        return;
    }

    const count = state.selectedEmployees.length;
    state.selectedEmployees = [];
    renderSelectedEmployees();
    showToast(`Alle ${count} Mitarbeiter entfernt`, 'success');
}

function deselectAll() {
    document.getElementById('lstMA_Alle').selectedIndex = -1;
    document.getElementById('lstMA_Ausweis').selectedIndex = -1;
}

// ========================================
// BADGE & CARD PRINTING
// ========================================
function printBadge(badgeType) {
    if (state.selectedEmployees.length === 0) {
        showToast('Bitte zuerst Mitarbeiter auswählen', 'warning');
        return;
    }

    const validUntil = state.validUntil || document.getElementById('GueltBis').value;

    if (!validUntil) {
        showToast('Bitte Gültigkeitsdatum setzen', 'warning');
        return;
    }

    console.log(`Print Badge: ${badgeType}`, {
        employees: state.selectedEmployees.map(e => `${e.Nachname}, ${e.Vorname}`),
        validUntil: validUntil,
        count: state.selectedEmployees.length
    });

    // Simulate badge generation
    showToast(`Erstelle ${state.selectedEmployees.length} Ausweise (${badgeType})...`, 'success');

    // In production: call API to generate PDF/print
    setTimeout(() => {
        showPrintPreview(badgeType, state.selectedEmployees, validUntil);
    }, 500);
}

function printCard(cardType) {
    if (state.selectedEmployees.length === 0) {
        showToast('Bitte zuerst Mitarbeiter auswählen', 'warning');
        return;
    }

    const printer = document.getElementById('cbo_Kartendrucker').value;

    if (!printer) {
        showToast('Bitte Kartendrucker auswählen', 'warning');
        return;
    }

    const validUntil = state.validUntil || document.getElementById('GueltBis').value;

    console.log(`Print Card: ${cardType}`, {
        employees: state.selectedEmployees.map(e => `${e.Nachname}, ${e.Vorname}`),
        printer: printer,
        validUntil: validUntil,
        count: state.selectedEmployees.length
    });

    showToast(`Drucke ${state.selectedEmployees.length} Karten (${cardType}) auf ${printer}...`, 'success');

    // In production: send to card printer via API
    setTimeout(() => {
        showToast(`Kartendruck erfolgreich (${cardType})`, 'success');
    }, 1500);
}

function showPrintPreview(badgeType, employees, validUntil) {
    const preview = window.open('', 'BadgePreview', 'width=800,height=600');

    let html = `
        <!DOCTYPE html>
        <html>
        <head>
            <title>Ausweis Vorschau - ${badgeType}</title>
            <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                .badge {
                    border: 2px solid #4316B2;
                    padding: 20px;
                    margin: 20px 0;
                    width: 85mm;
                    height: 54mm;
                    page-break-after: always;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-between;
                }
                .badge-header {
                    background: #4316B2;
                    color: white;
                    padding: 10px;
                    text-align: center;
                    font-weight: bold;
                }
                .badge-name {
                    font-size: 18px;
                    font-weight: bold;
                    text-align: center;
                    margin: 15px 0;
                }
                .badge-type {
                    background: #f0f0f0;
                    padding: 8px;
                    text-align: center;
                    font-size: 14px;
                }
                .badge-footer {
                    font-size: 10px;
                    text-align: center;
                    color: #666;
                }
                @media print {
                    .no-print { display: none; }
                }
            </style>
        </head>
        <body>
            <h1 class="no-print">Ausweis Vorschau - ${badgeType}</h1>
            <button class="no-print" onclick="window.print()">Drucken</button>
            <button class="no-print" onclick="window.close()">Schließen</button>
            <hr class="no-print">
    `;

    employees.forEach(emp => {
        html += `
            <div class="badge">
                <div class="badge-header">CONSYS Sicherheitsdienst</div>
                <div class="badge-name">${emp.Nachname || ''}, ${emp.Vorname || ''}</div>
                <div class="badge-type">${badgeType}</div>
                <div class="badge-footer">
                    Ausweis-Nr: ${emp.ausweisNr || 'N/A'}<br>
                    Gültig bis: ${formatDate(validUntil)}
                </div>
            </div>
        `;
    });

    html += `
        </body>
        </html>
    `;

    preview.document.write(html);
    preview.document.close();
}

// ========================================
// UI UTILITIES
// ========================================
function showLoading(show) {
    // Could show loading overlay if implemented
    console.log('Loading:', show);
}

function showToast(message, type = 'info') {
    console.log(`[Toast ${type}] ${message}`);

    // Simple alert fallback (in production: use proper toast component)
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background: ${type === 'error' ? '#d9534f' : type === 'warning' ? '#f0ad4e' : type === 'success' ? '#5cb85c' : '#5bc0de'};
        color: white;
        border-radius: 4px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        z-index: 10000;
        font-size: 13px;
        max-width: 300px;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 3000);
}

console.log('[Ausweis Create Logic] Module loaded');
