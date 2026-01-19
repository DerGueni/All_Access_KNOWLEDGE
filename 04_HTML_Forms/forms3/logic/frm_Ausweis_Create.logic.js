/**
 * frm_Ausweis_Create.logic.js
 * Business Logic für Dienstausweis-Erstellung
 */

'use strict';

// State Management
const state = {
    allEmployees: [],
    selectedEmployees: [],
    validUntil: null
};

// Badge/Card service configuration
const BADGE_SERVICE_DEFAULT = 'http://192.168.128.24:5005';
const BADGE_TEMPLATE_KEYS = {
    Einsatzleitung: 'Einsatzleitung',
    Bereichsleiter: 'Bereichsleiter',
    Security: 'Security',
    Service: 'Service',
    Platzanweiser: 'Platzanweiser',
    Staff: 'Staff'
};

const CARD_TEMPLATE_KEYS = {
    Sicherheit: 'Sicherheit',
    Service: 'Servicekarte',
    Rueckseite: 'Rueckseite',
    Sonder: 'Sonder'
};

function getBadgeServiceBase() {
    const stored = (localStorage.getItem('badgeServiceUrl') || '').trim();
    const base = stored || BADGE_SERVICE_DEFAULT;
    return base.replace(/\/+$/, '');
}

async function callBadgeService(path, options = {}) {
    const url = `${getBadgeServiceBase()}${path}`;
    const defaultOptions = {
        headers: { 'Content-Type': 'application/json' }
    };
    const response = await fetch(url, {
        ...defaultOptions,
        ...options,
        headers: { ...defaultOptions.headers, ...(options.headers || {}) }
    });
    const text = await response.text();
    let data;
    try {
        data = text ? JSON.parse(text) : {};
    } catch (err) {
        data = { raw: text };
    }

    if (!response.ok) {
        const message = data?.error || response.statusText || 'Badge-Service Fehler';
        throw new Error(`${message} (HTTP ${response.status})`);
    }

    return data;
}

function getSelectedPrinter() {
    return document.getElementById('cbo_Kartendrucker').value;
}

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

    // Load employees via Bridge
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

    // headerDate ist optional - existiert nicht immer im HTML
    const headerDateEl = document.getElementById('headerDate');
    if (headerDateEl) {
        headerDateEl.textContent = `${dateStr} ${timeStr}`;
    }

    const footerDateEl = document.getElementById('footerDate');
    if (footerDateEl) {
        footerDateEl.textContent = dateStr;
    }
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

    // Gültig bis Doppelklick -> Kalender (wie Access)
    document.getElementById('GueltBis').addEventListener('dblclick', openDatePicker);

    // Badge print buttons
    document.getElementById('btn_ausweiseinsatzleitung').addEventListener('click', () => printBadge('Einsatzleitung'));
    document.getElementById('btn_ausweisBereichsleiter').addEventListener('click', () => printBadge('Bereichsleiter'));
    document.getElementById('btn_ausweissec').addEventListener('click', () => printBadge('Security'));
    document.getElementById('btn_ausweisservice').addEventListener('click', () => printBadge('Service'));
    document.getElementById('btn_ausweisplatzanweiser').addEventListener('click', () => printBadge('Platzanweiser'));
    document.getElementById('btn_ausweisstaff').addEventListener('click', () => printBadge('Staff'));

    // Card print buttons
    document.getElementById('btn_Karte_Sicherheit').addEventListener('click', () => printCardSingle('Sicherheit'));
    document.getElementById('btn_Karte_Service').addEventListener('click', () => printCardSingle('Service'));
    document.getElementById('btn_Karte_Rueck').addEventListener('click', () => printCardSingle('Rueckseite'));
    document.getElementById('btn_Sonder').addEventListener('click', printSonderausweis);

    // Extra Actions (NEU wie Access)
    const btnDienstauswNr = document.getElementById('btnDienstauswNr');
    if (btnDienstauswNr) {
        btnDienstauswNr.addEventListener('click', vergebeDienstausweisNr);
    }

    const btnAusweisReport = document.getElementById('btnAusweisReport');
    if (btnAusweisReport) {
        btnAusweisReport.addEventListener('click', openAusweisReport);
    }

    // Kartendrucker-Auswahl speichern (wie Access cbo_Kartendrucker_AfterUpdate)
    document.getElementById('cbo_Kartendrucker').addEventListener('change', saveKartendrucker);

    // List selection changes
    document.getElementById('lstMA_Alle').addEventListener('change', updateCounters);
    document.getElementById('lstMA_Ausweis').addEventListener('change', updateCounters);

    // DOPPELKLICK-HANDLER (wie Access lstMA_Alle_DblClick / lstMA_Ausweis_DblClick)
    document.getElementById('lstMA_Alle').addEventListener('dblclick', lstMA_Alle_DblClick);
    document.getElementById('lstMA_Ausweis').addEventListener('dblclick', lstMA_Ausweis_DblClick);

    // KEYDOWN-HANDLER (wie Access lstMA_Alle_KeyDown - Enter = Service drucken)
    document.getElementById('lstMA_Alle').addEventListener('keydown', lstMA_Alle_KeyDown);
}

// ========================================
// DATA LOADING
// ========================================
async function loadAllEmployees() {
    try {
        showLoading(true);

        // Load employees from REST API (Port 5000)
        const response = await fetch('http://localhost:5000/api/mitarbeiter?aktiv=true');

        if (!response.ok) {
            throw new Error(`API-Fehler: ${response.statusText}`);
        }

        const data = await response.json();

        // Map API data to state
        state.allEmployees = data.map(emp => ({
            ID: emp.ID,
            Nachname: emp.Nachname || '',
            Vorname: emp.Vorname || '',
            ausweisNr: emp.DienstausweisNr || '-',
            gueltBis: emp.Ausweis_GueltBis || '-'
        }));

        renderAllEmployees();
        updateCounters();
        refreshSelectedEmployeesFromAll();

        console.log(`[Ausweis Create] ${state.allEmployees.length} Mitarbeiter geladen`);

    } catch (err) {
        console.error('Load employees failed:', err);
        showToast(`Mitarbeiter konnten nicht geladen werden: ${err.message}`, 'error');

        // Keep empty state
        state.allEmployees = [];
        renderAllEmployees();
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

function refreshSelectedEmployeesFromAll() {
    if (state.selectedEmployees.length === 0) return;
    const lookup = new Map(state.allEmployees.map(emp => [emp.ID, emp]));
    state.selectedEmployees = state.selectedEmployees.map(emp => lookup.get(emp.ID) || emp);
    renderSelectedEmployees();
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

function getSingleSelectedEmployee() {
    if (state.selectedEmployees.length !== 1) {
        showToast('Ausweiskarten bitte einzeln drucken!', 'warning');
        return null;
    }
    return state.selectedEmployees[0];
}

// ========================================
// ACCESS-PARITÄT: DOPPELKLICK-HANDLER
// ========================================

/**
 * lstMA_Alle_DblClick - Doppelklick auf Mitarbeiter in "Alle" Liste
 * VBA: Löscht Auswahl, fügt aktuellen hinzu, druckt Sicherheitskarte
 */
function lstMA_Alle_DblClick() {
    const listbox = document.getElementById('lstMA_Alle');
    const selected = Array.from(listbox.selectedOptions);

    if (selected.length === 0) return;

    // Wie Access: btnDelAll_Click + btnAddSelected_Click + btn_Karte_Sicherheit_Click
    state.selectedEmployees = [];

    selected.forEach(option => {
        const emp = JSON.parse(option.dataset.employee);
        state.selectedEmployees.push(emp);
    });

    renderSelectedEmployees();

    // Automatisch Sicherheitskarte drucken
    printCardSingle('Sicherheit');
}

/**
 * lstMA_Ausweis_DblClick - Doppelklick auf Mitarbeiter in "Für Ausweiserstellung" Liste
 * VBA: Öffnet Servicepersonal-Karte
 */
function lstMA_Ausweis_DblClick() {
    const listbox = document.getElementById('lstMA_Ausweis');
    const selected = Array.from(listbox.selectedOptions);

    if (selected.length === 0) return;

    // Wie Access: btn_Karte_Service_Click
    printCardSingle('Service');
}

/**
 * Öffnet Kalender-Picker (wie Access GueltBis_DblClick)
 */
function openDatePicker() {
    const input = document.getElementById('GueltBis');
    // Browser-eigener Date-Picker wird bei click geöffnet
    input.showPicker && input.showPicker();
}

/**
 * lstMA_Alle_KeyDown - Tastendruck auf Mitarbeiter in "Alle" Liste
 * VBA: Bei Enter/Leertaste: Löscht Auswahl, fügt aktuellen hinzu, druckt SERVICE-Karte
 * (Unterschied zu DblClick: Service statt Sicherheit!)
 */
function lstMA_Alle_KeyDown(event) {
    // Nur bei Enter oder Leertaste reagieren
    if (event.key !== 'Enter' && event.key !== ' ') return;

    event.preventDefault();

    const listbox = document.getElementById('lstMA_Alle');
    const selected = Array.from(listbox.selectedOptions);

    if (selected.length === 0) return;

    // Wie Access: btnDelAll_Click + btnAddSelected_Click + btn_ausweisservice_Click
    state.selectedEmployees = [];

    selected.forEach(option => {
        const emp = JSON.parse(option.dataset.employee);
        state.selectedEmployees.push(emp);
    });

    renderSelectedEmployees();

    // Automatisch SERVICE drucken (nicht Sicherheit wie bei DblClick!)
    printBadge('Service');

    // Fokus zurück zur Liste
    listbox.focus();
}

// ========================================
// ACCESS-PARITÄT: EXTRA AKTIONEN
// ========================================

/**
 * btnDienstauswNr_Click - DienstausweisNr für alle MA ohne Nummer vergeben
 * VBA: UPDATE ... SET DienstausweisNr = [ID] WHERE Len(trim(Nz(DienstausweisNr))) = 0
 */
async function vergebeDienstausweisNr() {
    showLoading(true);

    try {
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'DienstausweisNr_Vergeben',
                args: []
            })
        });

        if (!response.ok) {
            throw new Error(`API-Fehler: ${response.statusText}`);
        }

        const data = await response.json();
        showToast(`Dienstausweisnummern vergeben: ${data.count || 'OK'}`, 'success');

        // Liste aktualisieren
        await loadAllEmployees();

    } catch (err) {
        console.error('DienstausweisNr vergeben fehlgeschlagen:', err);
        showToast(`Fehler: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

/**
 * btnAusweisReport_Click - Öffnet Report rpt_Ausweis
 * VBA: DoCmd.OpenReport "rpt_Ausweis", acViewReport
 */
async function openAusweisReport() {
    if (state.selectedEmployees.length === 0) {
        showToast('Bitte zuerst Mitarbeiter auswählen', 'warning');
        return;
    }

    const validUntil = state.validUntil || document.getElementById('GueltBis').value;

    try {
        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'OpenAusweisReport',
                args: [state.selectedEmployees.map(e => e.ID), validUntil]
            })
        });

        if (!response.ok) {
            throw new Error(`API-Fehler: ${response.statusText}`);
        }

        showToast('Report wird geöffnet...', 'info');

    } catch (err) {
        console.error('Report öffnen fehlgeschlagen:', err);
        // Fallback: Vorschau anzeigen
        showPrintPreview('Ausweis-Report', state.selectedEmployees, validUntil);
    }
}

/**
 * cbo_Kartendrucker_AfterUpdate - Speichert Drucker-Einstellung
 * VBA: Call Set_Priv_Property("prp_Kartendrucker", ...)
 */
async function saveKartendrucker() {
    const drucker = document.getElementById('cbo_Kartendrucker').value;

    if (!drucker) return;

    try {
        await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'Set_Priv_Property',
                args: ['prp_Kartendrucker', drucker]
            })
        });

        console.log('[Ausweis Create] Kartendrucker gespeichert:', drucker);
        showToast(`Kartendrucker gesetzt: ${drucker}`, 'success');

    } catch (err) {
        console.warn('Kartendrucker speichern fehlgeschlagen (kein VBA-Bridge):', err);
        // Lokal in localStorage speichern als Fallback
        localStorage.setItem('prp_Kartendrucker', drucker);
    }
}

/**
 * printSonderausweis - Sonderausweis mit 2 Zeilen Text (wie Access InputBox)
 */
async function printSonderausweis() {
    const employee = getSingleSelectedEmployee();
    if (!employee) {
        showToast('Sonderausweise bitte einzeln drucken!', 'warning');
        return;
    }

    const printer = getSelectedPrinter();
    if (!printer) {
        showToast('Bitte Kartendrucker auswählen', 'warning');
        return;
    }

    const zeile1 = prompt('Text Zeile1:', '');
    if (zeile1 === null) return;

    const zeile2 = prompt('Text Zeile2:', '');
    if (zeile2 === null) return;

    const sonderText = `${zeile1}/${zeile2}`.trim();
    if (!zeile1.trim() && !zeile2.trim()) {
        showToast('Bitte Text für den Sonderausweis eingeben', 'warning');
        return;
    }

    await printCard('Sonder', { customText: sonderText, printer });
}

/**
 * printCardSingle - Karte drucken mit Prüfung auf Einzelauswahl
 * VBA: If TCount("MA_ID", "tbltmp_AusweisMA_ID") <> 1 Then MsgBox "Ausweiskarten bitte einzeln drucken!"
 */
async function printCardSingle(cardType) {
    await printCard(cardType);
}

// ========================================
// BADGE & CARD PRINTING
// ========================================
async function printBadge(badgeType) {
    if (state.selectedEmployees.length === 0) {
        showToast('Bitte zuerst Mitarbeiter auswählen', 'warning');
        return;
    }

    const validUntil = state.validUntil || document.getElementById('GueltBis').value;

    if (!validUntil) {
        showToast('Bitte Gültigkeitsdatum setzen', 'warning');
        return;
    }

    const templateKey = BADGE_TEMPLATE_KEYS[badgeType];
    if (!templateKey) {
        showToast(`Unbekanntes Ausweis-Template: ${badgeType}`, 'error');
        return;
    }

    const employeeIds = state.selectedEmployees.map(emp => emp.ID);
    const printer = getSelectedPrinter();

    console.log(`Badge job via service: ${badgeType}`, { employeeIds, validUntil, printer });

    showToast(`Lege ${employeeIds.length} Ausweise in die Warteschlange…`, 'info');
    showLoading(true);

    try {
        const job = await callBadgeService('/api/badges/jobs', {
            method: 'POST',
            body: JSON.stringify({
                template: templateKey,
                employeeIds,
                validUntil,
                printer,
                assignNumbers: true,
                updateEmployeeValidity: true
            })
        });

        showToast(`Ausweisjob angelegt (Job ${job.jobId || 'n/a'})`, 'success');
        await loadAllEmployees();

    } catch (err) {
        console.error('Print Badge Error:', err);
        showToast(`Fehler beim Drucken: ${err.message}`, 'error');
        showPrintPreview(badgeType, state.selectedEmployees, validUntil);
    } finally {
        showLoading(false);
    }
}

async function printCard(cardType, options = {}) {
    const employee = getSingleSelectedEmployee();
    if (!employee) return;

    const requestPrinter = (options.printer || getSelectedPrinter() || '').trim();
    if (!requestPrinter) {
        showToast('Bitte Kartendrucker auswählen', 'warning');
        return;
    }

    if (cardType !== 'Rueckseite' && !requestPrinter.toLowerCase().includes('badgy')) {
        showToast('Für Kartendruck nur Kartendrucker (Badgy) zulässig!', 'warning');
        return;
    }

    const templateKey = CARD_TEMPLATE_KEYS[cardType];
    if (!templateKey) {
        showToast(`Unbekannter Kartentyp: ${cardType}`, 'error');
        return;
    }

    const payload = {
        cardType: templateKey,
        employeeId: employee.ID,
        printer: requestPrinter
    };

    if (options.customText) {
        payload.customText = options.customText;
    }

    showToast(`Kartenjob "${cardType}" wird vorbereitet…`, 'info');
    showLoading(true);

    try {
        const job = await callBadgeService('/api/cards/jobs', {
            method: 'POST',
            body: JSON.stringify(payload)
        });

        showToast(`Kartenjob angelegt (Job ${job.jobId || 'n/a'})`, 'success');

    } catch (err) {
        console.error('Print Card Error:', err);
        showToast(`Fehler beim Kartendruck: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
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
