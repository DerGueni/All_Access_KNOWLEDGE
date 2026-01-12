/**
 * frm_Angebot.logic.js
 * Business Logic für Angebotserstellung mit VBA-Bridge Integration
 */

'use strict';

// ========================================
// STATE MANAGEMENT
// ========================================
const state = {
    kunden: [],
    positionen: [],
    angebotsnummer: null,
    nextPositionNr: 1
};

// ========================================
// INITIALIZATION
// ========================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Angebot] Initializing...');

    // Set default dates
    const today = new Date();
    document.getElementById('angebotsdatum').value = today.toISOString().split('T')[0];

    // Set default valid-until to 30 days from now
    const validUntil = new Date(today);
    validUntil.setDate(validUntil.getDate() + 30);
    document.getElementById('gueltigBis').value = validUntil.toISOString().split('T')[0];

    // Load customers
    await loadKunden();

    // Get next offer number
    await loadNextOfferNumber();

    // Add first empty position
    addPosition();

    console.log('[Angebot] Ready');
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

        console.log(`[Angebot] ${kunden.length} Kunden geladen`);

    } catch (err) {
        console.error('Load Kunden failed:', err);
        showStatus(`Kunden konnten nicht geladen werden: ${err.message}`, 'error');
    }
}

async function loadNextOfferNumber() {
    try {
        // Get current offer number (without incrementing)
        // ID = 2 für Angebot (1 = Rechnung, 2 = Angebot, 3 = Brief, 4 = Mahnung)
        const response = await fetch('http://localhost:5002/api/vba/nummern/current/2');

        if (!response.ok) {
            throw new Error(`VBA-Bridge Fehler: ${response.statusText}`);
        }

        const data = await response.json();
        const currentNumber = data.nummer || 0;
        const nextNumber = currentNumber + 1;

        state.angebotsnummer = nextNumber;
        document.getElementById('angebotsnummer').value = nextNumber;

        console.log(`[Angebot] Nächste Angebotsnummer: ${nextNumber}`);

    } catch (err) {
        console.error('Load Offer Number failed:', err);
        showStatus(`Angebotsnummer konnte nicht geladen werden: ${err.message}`, 'error');
        // Use fallback
        document.getElementById('angebotsnummer').value = 'AUTO';
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
// OFFER CREATION
// ========================================
async function createOffer() {
    if (!validateForm()) return;

    showLoading(true);
    showStatus('Angebot wird erstellt (Word)...', 'info');

    try {
        const kundeId = parseInt(document.getElementById('kunde').value);

        // Step 1: Get next offer number and increment
        // ID = 2 für Angebot
        const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: 2 })
        });

        if (!nummerResponse.ok) {
            throw new Error('Angebotsnummer konnte nicht vergeben werden');
        }

        const nummerData = await nummerResponse.json();
        const angebotsnummer = nummerData.nummer;

        console.log(`[Angebot] Angebotsnummer vergeben: ${angebotsnummer}`);

        // Step 2: Fill Word template with customer data
        // doc_nr: 2 = Angebotsvorlage (muss in _tblEigeneFirma_TB_Dok_Dateinamen existieren)
        const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                doc_nr: 2, // Angebotsvorlage
                iRch_KopfID: angebotsnummer,
                kun_ID: kundeId
            })
        });

        if (!wordResponse.ok) {
            throw new Error('Word-Template konnte nicht gefüllt werden');
        }

        const wordData = await wordResponse.json();
        console.log('[Angebot] Word-Template gefüllt:', wordData);

        showStatus(`Angebot ${angebotsnummer} erfolgreich erstellt (Word)`, 'success');

        // Update form
        document.getElementById('angebotsnummer').value = angebotsnummer;

        // Refresh next number
        await loadNextOfferNumber();

    } catch (err) {
        console.error('Create Offer failed:', err);
        showStatus(`Fehler beim Erstellen: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

async function createOfferAndPDF() {
    if (!validateForm()) return;

    showLoading(true);
    showStatus('Angebot wird erstellt (Word + PDF)...', 'info');

    try {
        const kundeId = parseInt(document.getElementById('kunde').value);

        // Step 1: Get next offer number
        const nummerResponse = await fetch('http://localhost:5002/api/vba/nummern/next', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: 2 })
        });

        if (!nummerResponse.ok) {
            throw new Error('Angebotsnummer konnte nicht vergeben werden');
        }

        const nummerData = await nummerResponse.json();
        const angebotsnummer = nummerData.nummer;

        console.log(`[Angebot] Angebotsnummer vergeben: ${angebotsnummer}`);

        // Step 2: Fill Word template
        const wordResponse = await fetch('http://localhost:5002/api/vba/word/fill-template', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                doc_nr: 2,
                iRch_KopfID: angebotsnummer,
                kun_ID: kundeId
            })
        });

        if (!wordResponse.ok) {
            throw new Error('Word-Template konnte nicht gefüllt werden');
        }

        console.log('[Angebot] Word-Template gefüllt');

        // Step 3: Convert to PDF
        // HINWEIS: Word-Pfad muss existieren!
        // In Produktion sollte der Pfad aus VBA-Funktion zurückgegeben werden
        const wordPath = `C:\\Temp\\Angebot_${angebotsnummer}.docx`;

        const pdfResponse = await fetch('http://localhost:5002/api/vba/pdf/convert', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                word_path: wordPath
            })
        });

        if (!pdfResponse.ok) {
            // PDF-Konvertierung fehlgeschlagen, aber Word-Dokument existiert
            console.warn('[Angebot] PDF-Konvertierung fehlgeschlagen, aber Word-Dokument wurde erstellt');
            showStatus(`Angebot ${angebotsnummer} als Word erstellt (PDF-Konvertierung fehlgeschlagen)`, 'success');
        } else {
            const pdfData = await pdfResponse.json();
            console.log('[Angebot] PDF erstellt:', pdfData.pdf_path);
            showStatus(`Angebot ${angebotsnummer} erfolgreich erstellt (Word + PDF)`, 'success');
        }

        // Update form
        document.getElementById('angebotsnummer').value = angebotsnummer;

        // Refresh next number
        await loadNextOfferNumber();

    } catch (err) {
        console.error('Create Offer+PDF failed:', err);
        showStatus(`Fehler beim Erstellen: ${err.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

function validateForm() {
    const kunde = document.getElementById('kunde').value;
    const datum = document.getElementById('angebotsdatum').value;
    const gueltigBis = document.getElementById('gueltigBis').value;

    if (!kunde) {
        showStatus('Bitte wählen Sie einen Kunden aus', 'error');
        return false;
    }

    if (!datum) {
        showStatus('Bitte geben Sie ein Angebotsdatum an', 'error');
        return false;
    }

    if (!gueltigBis) {
        showStatus('Bitte geben Sie ein Gültigkeitsdatum an', 'error');
        return false;
    }

    // Check if gueltigBis is after datum
    if (new Date(gueltigBis) <= new Date(datum)) {
        showStatus('Gültigkeitsdatum muss nach dem Angebotsdatum liegen', 'error');
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

    const today = new Date();
    document.getElementById('angebotsdatum').value = today.toISOString().split('T')[0];

    const validUntil = new Date(today);
    validUntil.setDate(validUntil.getDate() + 30);
    document.getElementById('gueltigBis').value = validUntil.toISOString().split('T')[0];

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

console.log('[Angebot Logic] Module loaded');
