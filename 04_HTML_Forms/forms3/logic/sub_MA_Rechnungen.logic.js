'use strict';
/**
 * sub_MA_Rechnungen.logic.js
 * Logic-Datei fuer Mitarbeiter Rechnungen (Subunternehmer) Subformular
 */

let currentMA_ID = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data && data.type === 'LOAD_DATA') {
        currentMA_ID = data.ma_id || data.id;
        loadData();
    }
});

async function loadData() {
    if (!currentMA_ID) return;

    document.getElementById('statusLeft').textContent = 'Lade...';

    try {
        const response = await fetch(`http://localhost:5000/api/rechnungen/ma/${currentMA_ID}`);
        if (!response.ok) throw new Error('API Fehler');

        const data = await response.json();
        renderTable(data);
    } catch (error) {
        console.log('[sub_MA_Rechnungen] Fehler:', error);
        document.getElementById('statusLeft').textContent = 'Fehler beim Laden';
    }
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    const rows = data.rechnungen || data || [];

    if (rows.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Keine Rechnungen vorhanden</td></tr>';
        document.getElementById('statusLeft').textContent = 'Keine Rechnungen';
        document.getElementById('statusRight').textContent = 'Summe: 0,00 EUR';
        return;
    }

    let summe = 0;

    tbody.innerHTML = rows.map(row => {
        const betrag = parseFloat(row.Betrag) || 0;
        summe += row.Status !== 'Storniert' ? betrag : 0;

        const statusClass = row.Status === 'Bezahlt' ? 'status-bezahlt' :
                           row.Status === 'Offen' ? 'status-offen' :
                           row.Status === 'Storniert' ? 'status-storniert' : '';

        return `
            <tr onclick="openRechnung(${row.ID})">
                <td>${row.RechNr || ''}</td>
                <td>${formatDate(row.Datum)}</td>
                <td>${row.Auftrag || ''}</td>
                <td>${row.Beschreibung || ''}</td>
                <td class="text-right">${formatCurrency(betrag)}</td>
                <td class="${statusClass}">${row.Status || ''}</td>
            </tr>
        `;
    }).join('');

    document.getElementById('statusLeft').textContent = `${rows.length} Rechnungen`;
    document.getElementById('statusRight').textContent = `Summe: ${formatCurrency(summe)}`;
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

function formatCurrency(value) {
    return value.toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' EUR';
}

function openRechnung(id) {
    window.parent.postMessage({ type: 'OPEN_RECHNUNG', id: id }, '*');
}

function createNew() {
    window.parent.postMessage({ type: 'NEW_RECHNUNG', ma_id: currentMA_ID }, '*');
}

// Window exports fuer onclick-Handler im HTML
window.loadData = loadData;
window.createNew = createNew;
window.openRechnung = openRechnung;
