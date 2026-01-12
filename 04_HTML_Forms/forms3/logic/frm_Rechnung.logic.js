/**
 * frm_Rechnung.logic.js
 * Business Logic für Rechnungserstellung mit VBA-Bridge Integration
 */

'use strict';

// ========================================
// STATE MANAGEMENT
// ========================================
const state = {
    kunden: [],
    positionen: [],
    rechnungsnummer: null,
    nextPositionNr: 1
};

// ========================================
// INITIALIZATION
// ========================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Rechnung] Initializing...');

    // Set default date to today
    document.getElementById('rechnungsdatum').value = new Date().toISOString().split('T')[0];

    // Load customers
    await loadKunden();

    // Get next invoice number
    await loadNextInvoiceNumber();

    // Add first empty position
    addPosition();

    console.log('[Rechnung] Ready');
});

// ========================================
// DATA LOADING
// ========================================
async function loadKunden() {
    try {
        const response = await fetch('http://localhost:5000/api/kunden');

        if (!response.ok) {
            throw new Error(`API-Fehler: ${response.statusText}`);
        }

        const kunden = await response.json();
        state.kunden = kunden;

        // Fill dropdown
        const select = document.getElementById('kunde');
        select.innerHTML = '<option value="">Bitte wählen...</option>';

        kunden.forEach(kunde => {
            const option = document.createElement('option');
            option.value = kunde.kun_Id;
            option.textContent = `${kunde.kun_Firma} (${kunde.kun_Id})`;
            select.appendChild(option);
        });

        console.log(`[Rechnung] ${kunden.length} Kunden geladen`);

    } catch (err) {
        console.error('Load Kunden failed:', err);
        showStatus(`Kunden konnten nicht geladen werden: ${err.message}`, 'error');
    }
}

async function loadNextInvoiceNumber() {
    try {
        // Get current invoice number (without incrementing)
        const response = await fetch('http://localhost:5002/api/vba/nummern/current/1');

        if (!response.ok) {
            throw new Error(`VBA-Bridge Fehler: ${response.statusText}`);
        }

        const data = await response.json();
        const currentNumber = data.nummer || 0;
        const nextNumber = currentNumber + 1;

        state.rechnungsnummer = nextNumber;
        document.getElementById('rechnungsnummer').value = nextNumber;

        console.log(`[Rechnung] Nächste Rechnungsnummer: ${nextNumber}`);

    } catch (err) {
        console.error('Load Invoice Number failed:', err);
        showStatus(`Rechnungsnummer konnte nicht geladen werden: ${err.message}`, 'error');
        // Use fallback
        document.getElementById('rechnungsnummer').value = 'AUTO';
    }
}

// ========================================
// POSITIONS MANAGEMENT
// ========================================
function addPosition() {
    const position = {
        nr: state.nextPositionNr++,
        beschreibung: '',
        menge: 1,
        preis: 0,
        gesamt: 0
    };

    state.positionen.push(position);
    renderPositions();
    updateTotals();
}

function removePosition(nr) {
    state.positionen = state.positionen.filter(p => p.nr !== nr);
    renderPositions();
    updateTotals();
}

function updatePosition(nr, field, value) {
    const position = state.positionen.find(p => p.nr === nr);
    if (!position) return;

    position[field] = value;

    // Recalculate total
    if (field === 'menge' || field === 'preis') {
        position.gesamt = parseFloat(position.menge) * parseFloat(position.preis);
    }

    renderPositions();
    updateTotals();
}

function renderPositions() {
    const tbody = document.getElementById('positionsTableBody');
    tbody.innerHTML = '';

    state.positionen.forEach(pos => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td class="col-nr">${pos.nr}</td>
            <td class="col-beschreibung">
                <input type="text"
                       value="${pos.beschreibung}"
                       onchange="updatePosition(${pos.nr}, 'beschreibung', this.value)"
                       placeholder="Beschreibung">
            </td>
            <td class="col-menge">
                <input type="number"
                       value="${pos.menge}"
                       onchange="updatePosition(${pos.nr}, 'menge', parseFloat(this.value) || 0)"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis">
                <input type="number"
                       value="${pos.preis}"
                       onchange="updatePosition(${pos.nr}, 'preis', parseFloat(this.value) || 0)"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-gesamt">${formatCurrency(pos.gesamt)}</td>
            <td class="col-aktionen">
                <button class="btn btn-danger" onclick="removePosition(${pos.nr})" style="padding: 4px 8px;">Löschen</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

function updateTotals() {
    const netto = state.positionen.reduce((sum, pos) => sum + pos.gesamt, 0);
    const mwst = netto * 0.19; // 19% MwSt
    const brutto = netto + mwst;

    document.getElementById('totalNetto').textContent = formatCurrency(netto);
    document.getElementById('totalMwst').textContent = formatCurrency(mwst);
    document.getElementById('totalBrutto').textContent = formatCurrency(brutto);
}

function formatCurrency(value) {
    return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR'
    }).format(value);
}

// ========================================
// INVOICE CREATION
// ========================================
async function createInvoice() {
    if (!validateForm()) return;

    showLoading(true);
    showStatus('Rechnung wird erstellt (Word)...', 'info');

    try {
        const kundeId = parseInt(document.getElementById('kunde').value);

        // Step 1: Get next invoice number and increment
        const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: 1 }) // 1 = Rechnung
        });

        if (!nummerResponse.ok) {
            throw new Error('Rechnungsnummer konnte nicht vergeben werden');
        }

        const nummerData = await nummerResponse.json();
        const rechnungsnummer = nummerData.nummer;

        console.log(`[Rechnung] Rechnungsnummer vergeben: ${rechnungsnummer}`);

        // Step 2: Fill Word template with customer data
        // doc_nr: 1 = Rechnungsvorlage (muss in _tblEigeneFirma_TB_Dok_Dateinamen existieren)
        const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                doc_nr: 1, // Rechnungsvorlage
                iRch_KopfID: rechnungsnummer,
                kun_ID: kundeId
            })
        });

        if (!wordResponse.ok) {
            throw new Error('Word-Template konnte nicht gefüllt werden');
        }

        const wordData = await wordResponse.json();
        console.log('[Rechnung] Word-Template gefüllt:', wordData);

        showStatus(`Rechnung ${rechnungsnummer} erfolgreich erstellt (Word)`, 'success');

        // Update form
        document.getElementById('rechnungsnummer').value = rechnungsnummer;

        // Refresh next number
        await loadNextInvoiceNumber();

    } catch (err) {
        console.error('Create Invoice failed:', err);
        showStatus(`Fehler beim Erstellen: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

async function createInvoiceAndPDF() {
    if (!validateForm()) return;

    showLoading(true);
    showStatus('Rechnung wird erstellt (Word + PDF)...', 'info');

    try {
        const kundeId = parseInt(document.getElementById('kunde').value);

        // Step 1: Get next invoice number
        const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: 1 })
        });

        if (!nummerResponse.ok) {
            throw new Error('Rechnungsnummer konnte nicht vergeben werden');
        }

        const nummerData = await nummerResponse.json();
        const rechnungsnummer = nummerData.nummer;

        console.log(`[Rechnung] Rechnungsnummer vergeben: ${rechnungsnummer}`);

        // Step 2: Fill Word template
        const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                doc_nr: 1,
                iRch_KopfID: rechnungsnummer,
                kun_ID: kundeId
            })
        });

        if (!wordResponse.ok) {
            throw new Error('Word-Template konnte nicht gefüllt werden');
        }

        console.log('[Rechnung] Word-Template gefüllt');

        // Step 3: Convert to PDF
        // HINWEIS: Word-Pfad muss existieren!
        // In Produktion sollte der Pfad aus VBA-Funktion zurückgegeben werden
        const wordPath = `C:\\Temp\\Rechnung_${rechnungsnummer}.docx`;

        const pdfResponse = await fetch('http://localhost:5002/api/vba/pdf/convert', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                word_path: wordPath
            })
        });

        if (!pdfResponse.ok) {
            // PDF-Konvertierung fehlgeschlagen, aber Word-Dokument existiert
            console.warn('[Rechnung] PDF-Konvertierung fehlgeschlagen, aber Word-Dokument wurde erstellt');
            showStatus(`Rechnung ${rechnungsnummer} als Word erstellt (PDF-Konvertierung fehlgeschlagen)`, 'success');
        } else {
            const pdfData = await pdfResponse.json();
            console.log('[Rechnung] PDF erstellt:', pdfData.pdf_path);
            showStatus(`Rechnung ${rechnungsnummer} erfolgreich erstellt (Word + PDF)`, 'success');
        }

        // Update form
        document.getElementById('rechnungsnummer').value = rechnungsnummer;

        // Refresh next number
        await loadNextInvoiceNumber();

    } catch (err) {
        console.error('Create Invoice+PDF failed:', err);
        showStatus(`Fehler beim Erstellen: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

function validateForm() {
    const kunde = document.getElementById('kunde').value;
    const datum = document.getElementById('rechnungsdatum').value;

    if (!kunde) {
        showStatus('Bitte wählen Sie einen Kunden aus', 'error');
        return false;
    }

    if (!datum) {
        showStatus('Bitte geben Sie ein Rechnungsdatum an', 'error');
        return false;
    }

    if (state.positionen.length === 0) {
        showStatus('Bitte fügen Sie mindestens eine Position hinzu', 'error');
        return false;
    }

    // Check if at least one position has description and price
    const validPositions = state.positionen.filter(p => p.beschreibung && p.preis > 0);
    if (validPositions.length === 0) {
        showStatus('Bitte füllen Sie mindestens eine Position vollständig aus', 'error');
        return false;
    }

    return true;
}

function resetForm() {
    if (!confirm('Formular wirklich zurücksetzen? Alle Eingaben gehen verloren.')) {
        return;
    }

    // Reset form
    document.getElementById('kunde').value = '';
    document.getElementById('rechnungsdatum').value = new Date().toISOString().split('T')[0];
    document.getElementById('zahlungsziel').value = '30';

    // Reset positions
    state.positionen = [];
    state.nextPositionNr = 1;
    addPosition();

    updateTotals();

    showStatus('Formular zurückgesetzt', 'info');
}

// ========================================
// UI UTILITIES
// ========================================
function showLoading(show) {
    document.getElementById('loadingOverlay').style.display = show ? 'flex' : 'none';
}

function showStatus(message, type = 'info') {
    const statusDiv = document.getElementById('statusMessage');
    statusDiv.textContent = message;
    statusDiv.className = `status-message ${type}`;
    statusDiv.style.display = 'block';

    // Auto-hide after 5 seconds for success/info
    if (type === 'success' || type === 'info') {
        setTimeout(() => {
            statusDiv.style.display = 'none';
        }, 5000);
    }
}

console.log('[Rechnung Logic] Module loaded');
