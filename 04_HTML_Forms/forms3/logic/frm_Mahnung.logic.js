/**
 * frm_Mahnung.logic.js
 * Business Logic für Mahnungserstellung mit VBA-Bridge Integration
 */

'use strict';

// ========================================
// STATE MANAGEMENT
// ========================================
const state = {
    invoices: [],
    selectedInvoices: new Set(),
    mahnungsnummer: null,
    currentKunde: null
};

// ========================================
// INITIALIZATION
// ========================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Mahnung] Initializing...');

    // Set default date to today
    const today = new Date();
    document.getElementById('mahndatum').value = today.toISOString().split('T')[0];

    // Get next reminder number
    await loadNextReminderNumber();

    // Load overdue invoices
    await loadOverdueInvoices();

    console.log('[Mahnung] Ready');
});

// ========================================
// DATA LOADING
// ========================================
async function loadOverdueInvoices() {
    try {
        // Load all open invoices
        const response = await fetch('http://localhost:5000/api/rechnungen/offen');

        if (!response.ok) {
            throw new Error(`API-Fehler: ${response.statusText}`);
        }

        const allInvoices = await response.json();

        // Filter for overdue invoices (Zahlungsziel + Zahlungstage < heute)
        const today = new Date();
        const overdueInvoices = allInvoices.filter(inv => {
            const invoiceDate = new Date(inv.Rechnungsdatum);
            const zahlungsziel = inv.Zahlungsziel || 30; // Default 30 Tage
            const dueDate = new Date(invoiceDate);
            dueDate.setDate(dueDate.getDate() + zahlungsziel);

            return dueDate < today; // Überfällig wenn Zahlungsziel vorbei
        });

        state.invoices = overdueInvoices.map(inv => {
            const invoiceDate = new Date(inv.Rechnungsdatum);
            const zahlungsziel = inv.Zahlungsziel || 30;
            const dueDate = new Date(invoiceDate);
            dueDate.setDate(dueDate.getDate() + zahlungsziel);

            const daysDiff = Math.floor((today - dueDate) / (1000 * 60 * 60 * 24));

            return {
                rechnr: inv.Rechnungsnummer,
                kunde: inv.Kunde_Firma,
                kun_ID: inv.kun_ID,
                datum: invoiceDate.toLocaleDateString('de-DE'),
                betrag: parseFloat(inv.Bruttobetrag || inv.Nettobetrag || 0),
                tage: daysDiff,
                zahlungsziel: zahlungsziel
            };
        });

        renderInvoiceTable();
        console.log(`[Mahnung] ${state.invoices.length} überfällige Rechnungen geladen`);

    } catch (err) {
        console.error('Load Overdue Invoices failed:', err);
        showStatus(`Überfällige Rechnungen konnten nicht geladen werden: ${err.message}`, 'error');
    }
}

async function loadNextReminderNumber() {
    try {
        // Get current reminder number (without incrementing)
        // ID = 4 für Mahnung (1 = Rechnung, 2 = Angebot, 3 = Brief, 4 = Mahnung)
        const response = await fetch('http://localhost:5002/api/vba/nummern/current/4');

        if (!response.ok) {
            throw new Error(`VBA-Bridge Fehler: ${response.statusText}`);
        }

        const data = await response.json();
        const currentNumber = data.nummer || 0;
        const nextNumber = currentNumber + 1;

        state.mahnungsnummer = nextNumber;
        document.getElementById('mahnungsnummer').value = nextNumber;

        console.log(`[Mahnung] Nächste Mahnungsnummer: ${nextNumber}`);

    } catch (err) {
        console.error('Load Reminder Number failed:', err);
        showStatus(`Mahnungsnummer konnte nicht geladen werden: ${err.message}`, 'error');
        // Use fallback
        document.getElementById('mahnungsnummer').value = 'AUTO';
    }
}

// ========================================
// INVOICE SELECTION
// ========================================
function renderInvoiceTable() {
    const tbody = document.getElementById('invoicesTableBody');
    tbody.innerHTML = '';

    if (state.invoices.length === 0) {
        const row = document.createElement('tr');
        row.innerHTML = '<td colspan="6" style="text-align: center; padding: 20px; color: #666;">Keine überfälligen Rechnungen gefunden</td>';
        tbody.appendChild(row);
        return;
    }

    state.invoices.forEach(inv => {
        const row = document.createElement('tr');

        // Determine row class based on overdue days
        let rowClass = '';
        if (inv.tage >= 60) {
            rowClass = 'overdue-60';
        } else if (inv.tage >= 30) {
            rowClass = 'overdue-30';
        }

        // Check if selected
        if (state.selectedInvoices.has(inv.rechnr)) {
            rowClass += ' selected';
        }

        row.className = rowClass;
        row.onclick = () => toggleInvoiceSelection(inv.rechnr);
        row.style.cursor = 'pointer';

        row.innerHTML = `
            <td class="col-select">${state.selectedInvoices.has(inv.rechnr) ? '✓' : ''}</td>
            <td class="col-rechnr">${inv.rechnr}</td>
            <td class="col-kunde">${inv.kunde}</td>
            <td class="col-datum">${inv.datum}</td>
            <td class="col-betrag">${formatCurrency(inv.betrag)}</td>
            <td class="col-tage">${inv.tage}</td>
        `;

        tbody.appendChild(row);
    });

    updateSummary();
}

function toggleInvoiceSelection(rechnr) {
    if (state.selectedInvoices.has(rechnr)) {
        state.selectedInvoices.delete(rechnr);
    } else {
        state.selectedInvoices.add(rechnr);

        // Store customer ID from first selected invoice
        if (state.selectedInvoices.size === 1) {
            const inv = state.invoices.find(i => i.rechnr === rechnr);
            state.currentKunde = inv.kun_ID;
        }
    }

    renderInvoiceTable();
}

function deselectAll() {
    state.selectedInvoices.clear();
    state.currentKunde = null;
    renderInvoiceTable();
}

function updateSummary() {
    const selectedInvoicesList = Array.from(state.selectedInvoices)
        .map(rechnr => state.invoices.find(i => i.rechnr === rechnr))
        .filter(inv => inv !== undefined);

    const count = selectedInvoicesList.length;
    const invoiceTotal = selectedInvoicesList.reduce((sum, inv) => sum + inv.betrag, 0);
    const fee = parseFloat(document.getElementById('mahngebuehr').value) || 0;
    const total = invoiceTotal + fee;

    document.getElementById('summaryCount').textContent = count;
    document.getElementById('summaryInvoices').textContent = formatCurrency(invoiceTotal);
    document.getElementById('summaryFee').textContent = formatCurrency(fee);
    document.getElementById('summaryTotal').textContent = formatCurrency(total);

    // Show/hide summary
    const summaryDiv = document.getElementById('summary');
    summaryDiv.style.display = count > 0 ? 'block' : 'none';
}

function updateMahngebuehr() {
    // Update summary when fee changes
    updateSummary();
}

function formatCurrency(value) {
    return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR'
    }).format(value);
}

// ========================================
// REMINDER CREATION
// ========================================
async function createReminder() {
    if (!validateForm()) return;

    showLoading(true);
    showStatus('Mahnung wird erstellt (Word)...', 'info');

    try {
        // Step 1: Get next reminder number and increment
        // ID = 4 für Mahnung
        const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: 4 })
        });

        if (!nummerResponse.ok) {
            throw new Error('Mahnungsnummer konnte nicht vergeben werden');
        }

        const nummerData = await nummerResponse.json();
        const mahnungsnummer = nummerData.nummer;

        console.log(`[Mahnung] Mahnungsnummer vergeben: ${mahnungsnummer}`);

        // Step 2: Fill Word template with customer data
        // doc_nr: 4 = Mahnungsvorlage (muss in _tblEigeneFirma_TB_Dok_Dateinamen existieren)
        const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                doc_nr: 4, // Mahnungsvorlage
                iRch_KopfID: mahnungsnummer,
                kun_ID: state.currentKunde
            })
        });

        if (!wordResponse.ok) {
            throw new Error('Word-Template konnte nicht gefüllt werden');
        }

        const wordData = await wordResponse.json();
        console.log('[Mahnung] Word-Template gefüllt:', wordData);

        showStatus(`Mahnung ${mahnungsnummer} erfolgreich erstellt (Word)`, 'success');

        // Update form
        document.getElementById('mahnungsnummer').value = mahnungsnummer;

        // Refresh next number
        await loadNextReminderNumber();

        // Clear selection
        deselectAll();

    } catch (err) {
        console.error('Create Reminder failed:', err);
        showStatus(`Fehler beim Erstellen: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

async function createReminderAndPDF() {
    if (!validateForm()) return;

    showLoading(true);
    showStatus('Mahnung wird erstellt (Word + PDF)...', 'info');

    try {
        // Step 1: Get next reminder number
        const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: 4 })
        });

        if (!nummerResponse.ok) {
            throw new Error('Mahnungsnummer konnte nicht vergeben werden');
        }

        const nummerData = await nummerResponse.json();
        const mahnungsnummer = nummerData.nummer;

        console.log(`[Mahnung] Mahnungsnummer vergeben: ${mahnungsnummer}`);

        // Step 2: Fill Word template
        const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                doc_nr: 4,
                iRch_KopfID: mahnungsnummer,
                kun_ID: state.currentKunde
            })
        });

        if (!wordResponse.ok) {
            throw new Error('Word-Template konnte nicht gefüllt werden');
        }

        console.log('[Mahnung] Word-Template gefüllt');

        // Step 3: Convert to PDF
        // HINWEIS: Word-Pfad muss existieren!
        // In Produktion sollte der Pfad aus VBA-Funktion zurückgegeben werden
        const wordPath = `C:\\Temp\\Mahnung_${mahnungsnummer}.docx`;

        const pdfResponse = await fetch('http://localhost:5002/api/vba/pdf/convert', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                word_path: wordPath
            })
        });

        if (!pdfResponse.ok) {
            // PDF-Konvertierung fehlgeschlagen, aber Word-Dokument existiert
            console.warn('[Mahnung] PDF-Konvertierung fehlgeschlagen, aber Word-Dokument wurde erstellt');
            showStatus(`Mahnung ${mahnungsnummer} als Word erstellt (PDF-Konvertierung fehlgeschlagen)`, 'success');
        } else {
            const pdfData = await pdfResponse.json();
            console.log('[Mahnung] PDF erstellt:', pdfData.pdf_path);
            showStatus(`Mahnung ${mahnungsnummer} erfolgreich erstellt (Word + PDF)`, 'success');
        }

        // Update form
        document.getElementById('mahnungsnummer').value = mahnungsnummer;

        // Refresh next number
        await loadNextReminderNumber();

        // Clear selection
        deselectAll();

    } catch (err) {
        console.error('Create Reminder+PDF failed:', err);
        showStatus(`Fehler beim Erstellen: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

function validateForm() {
    const mahnstufe = document.getElementById('mahnstufe').value;
    const mahndatum = document.getElementById('mahndatum').value;

    if (!mahnstufe) {
        showStatus('Bitte wählen Sie eine Mahnstufe aus', 'error');
        return false;
    }

    if (!mahndatum) {
        showStatus('Bitte geben Sie ein Mahndatum an', 'error');
        return false;
    }

    if (state.selectedInvoices.size === 0) {
        showStatus('Bitte wählen Sie mindestens eine Rechnung aus', 'error');
        return false;
    }

    // Check if all selected invoices are from same customer
    const selectedInvoicesList = Array.from(state.selectedInvoices)
        .map(rechnr => state.invoices.find(i => i.rechnr === rechnr));

    const uniqueKunden = new Set(selectedInvoicesList.map(inv => inv.kun_ID));
    if (uniqueKunden.size > 1) {
        showStatus('Alle ausgewählten Rechnungen müssen vom selben Kunden sein', 'error');
        return false;
    }

    return true;
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

console.log('[Mahnung Logic] Module loaded');
