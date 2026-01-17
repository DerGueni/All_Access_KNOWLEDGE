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
    if (state.selectedEmployees.length !== 1) {
        showToast('Sonderausweise bitte einzeln drucken!', 'warning');
        return;
    }

    const printer = document.getElementById('cbo_Kartendrucker').value;
    if (!printer || !printer.toLowerCase().includes('badgy')) {
        showToast('Für Kartendruck nur Kartendrucker (Badgy) zulässig!', 'warning');
        return;
    }

    // Zeile 1 und 2 abfragen (wie Access InputBox)
    const zeile1 = prompt('Text Zeile1:', '');
    if (zeile1 === null) return; // Abbruch

    const zeile2 = prompt('Text Zeile2:', '');
    if (zeile2 === null) return; // Abbruch

    const sonderText = `${zeile1}/${zeile2}`;

    try {
        const emp = state.selectedEmployees[0];

        const response = await fetch('http://localhost:5002/api/vba/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: 'Karte_Drucken_Sonder',
                args: [emp.ID, sonderText, printer]
            })
        });

        if (!response.ok) {
            throw new Error(`Karten-Druck fehlgeschlagen: ${response.statusText}`);
        }

        showToast(`Sonderausweis gedruckt: ${sonderText}`, 'success');

    } catch (err) {
        console.error('Sonderausweis drucken fehlgeschlagen:', err);
        showToast(`Fehler: ${err.message}`, 'error');
    }
}

/**
 * printCardSingle - Karte drucken mit Prüfung auf Einzelauswahl
 * VBA: If TCount("MA_ID", "tbltmp_AusweisMA_ID") <> 1 Then MsgBox "Ausweiskarten bitte einzeln drucken!"
 */
async function printCardSingle(cardType) {
    if (state.selectedEmployees.length !== 1) {
        showToast('Ausweiskarten bitte einzeln drucken!', 'warning');
        return;
    }

    const printer = document.getElementById('cbo_Kartendrucker').value;
    if (!printer) {
        showToast('Bitte Kartendrucker auswählen', 'warning');
        return;
    }

    // Prüfung auf Kartendrucker (wie Access: InStr(lbl_Kartendrucker.caption, "Badgy"))
    if (cardType !== 'Rueckseite' && !printer.toLowerCase().includes('badgy')) {
        showToast('Für Kartendruck nur Kartendrucker (Badgy) zulässig!', 'warning');
        return;
    }

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

    console.log(`Print Badge: ${badgeType}`, {
        employees: state.selectedEmployees.map(e => `${e.Nachname}, ${e.Vorname}`),
        validUntil: validUntil,
        count: state.selectedEmployees.length
    });

    showToast(`Erstelle ${state.selectedEmployees.length} Ausweise (${badgeType})...`, 'info');
    showLoading(true);

    try {
        let successCount = 0;
        let errorCount = 0;

        // Process each employee
        for (const emp of state.selectedEmployees) {
            try {
                // Step 1: Assign badge number if needed (only if not already assigned)
                if (!emp.ausweisNr || emp.ausweisNr === '-') {
                    const nummerResponse = await fetch('http://localhost:5002/api/vba/ausweis/nummer', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ MA_ID: emp.ID })
                    });

                    if (!nummerResponse.ok) {
                        throw new Error(`Nummer-Vergabe fehlgeschlagen: ${nummerResponse.statusText}`);
                    }

                    const nummerData = await nummerResponse.json();
                    console.log(`[${emp.Nachname}] Ausweis-Nummer vergeben:`, nummerData.ausweis_nr);
                    emp.ausweisNr = nummerData.ausweis_nr; // Update local state
                }

                // Step 2: Print badge via VBA-Bridge
                const druckResponse = await fetch('http://localhost:5002/api/vba/ausweis/drucken', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        MA_ID: emp.ID,
                        badgeType: badgeType,
                        validUntil: validUntil
                    })
                });

                if (!druckResponse.ok) {
                    throw new Error(`Druck fehlgeschlagen: ${druckResponse.statusText}`);
                }

                const druckData = await druckResponse.json();
                console.log(`[${emp.Nachname}] Ausweis gedruckt:`, druckData);
                successCount++;

            } catch (err) {
                console.error(`Fehler bei ${emp.Nachname}:`, err);
                errorCount++;
            }
        }

        // Show result
        if (errorCount === 0) {
            showToast(`${successCount} Ausweise erfolgreich gedruckt (${badgeType})`, 'success');
        } else {
            showToast(`${successCount} erfolgreich, ${errorCount} fehlgeschlagen`, 'warning');
        }

        // Refresh employee list to show updated badge numbers
        await loadAllEmployees();

    } catch (err) {
        console.error('Print Badge Error:', err);
        showToast(`Fehler beim Drucken: ${err.message}`, 'error');

        // Fallback: Show preview if VBA-Bridge not available
        showPrintPreview(badgeType, state.selectedEmployees, validUntil);
    } finally {
        showLoading(false);
    }
}

async function printCard(cardType) {
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

    showToast(`Drucke ${state.selectedEmployees.length} Karten (${cardType}) auf ${printer}...`, 'info');
    showLoading(true);

    try {
        let successCount = 0;
        let errorCount = 0;

        // Process each employee
        for (const emp of state.selectedEmployees) {
            try {
                // Print card via VBA-Bridge (using Karte_Drucken VBA function)
                const response = await fetch('http://localhost:5002/api/vba/execute', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        function: 'Karte_Drucken',
                        args: [emp.ID, cardType, printer]
                    })
                });

                if (!response.ok) {
                    throw new Error(`Karten-Druck fehlgeschlagen: ${response.statusText}`);
                }

                const data = await response.json();
                console.log(`[${emp.Nachname}] Karte gedruckt:`, data);
                successCount++;

            } catch (err) {
                console.error(`Fehler bei ${emp.Nachname}:`, err);
                errorCount++;
            }
        }

        // Show result
        if (errorCount === 0) {
            showToast(`${successCount} Karten erfolgreich gedruckt (${cardType})`, 'success');
        } else {
            showToast(`${successCount} erfolgreich, ${errorCount} fehlgeschlagen`, 'warning');
        }

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
