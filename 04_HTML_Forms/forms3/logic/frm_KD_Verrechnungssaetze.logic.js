// ============================================================
// frm_KD_Verrechnungssaetze.logic.js
// Logic-Datei fuer Verrechnungssaetze-Formular
// ============================================================

const VERRECHNUNGSSAETZE_API = 'http://127.0.0.1:5000/api';
let allData = [];
let filteredData = [];
let currentSort = { field: 'firma', direction: 'asc' };
let selectedRow = null;

// ============================================================
// Initialisierung
// ============================================================

document.addEventListener('DOMContentLoaded', function() {
    console.log('[Verrechnungssaetze] Init');
    loadData();
});

// ============================================================
// Daten laden
// ============================================================

async function loadData() {
    showLoading(true);
    setStatus('Lade Daten...');

    try {
        const response = await fetch(`${VERRECHNUNGSSAETZE_API}/kundenpreise`);
        const result = await response.json();

        if (result.success) {
            allData = result.data;
            filteredData = [...allData];
            renderTable();
            updateRecordCount();
            setStatus('Daten geladen');
            document.getElementById('lastUpdate').textContent =
                'Aktualisiert: ' + new Date().toLocaleTimeString('de-DE');
        } else {
            showToast('Fehler: ' + result.error, 'error');
            setStatus('Fehler beim Laden');
        }
    } catch (error) {
        console.error('[Verrechnungssaetze] Fehler:', error);
        showToast('Verbindungsfehler: ' + error.message, 'error');
        setStatus('Verbindungsfehler');
    } finally {
        showLoading(false);
    }
}

// ============================================================
// Tabelle rendern
// ============================================================

function renderTable() {
    const tbody = document.getElementById('preisBody');
    tbody.innerHTML = '';

    filteredData.forEach(row => {
        const tr = document.createElement('tr');
        tr.onclick = () => selectRowHandler(tr, row);
        tr.ondblclick = () => openKunde(row.kunId);

        tr.innerHTML = `
            <td>${row.firma || ''}</td>
            <td class="price">${formatPrice(row.Sicherheitspersonal)}</td>
            <td class="price">${formatPrice(row.Leitungspersonal)}</td>
            <td class="price">${formatPrice(row.Nachtzuschlag)}</td>
            <td class="price">${formatPrice(row.Sonntagszuschlag)}</td>
            <td class="price">${formatPrice(row.Feiertagszuschlag)}</td>
            <td class="price">${formatPrice(row.Fahrtkosten)}</td>
            <td class="price">${formatPrice(row.Sonstiges)}</td>
        `;

        tbody.appendChild(tr);
    });
}

// ============================================================
// Preis formatieren
// ============================================================

function formatPrice(value) {
    if (value === null || value === undefined) return '-';
    return parseFloat(value).toFixed(2).replace('.', ',') + ' EUR';
}

// ============================================================
// Zeile selektieren
// ============================================================

function selectRowHandler(tr, data) {
    if (selectedRow) {
        selectedRow.classList.remove('selected');
    }
    tr.classList.add('selected');
    selectedRow = tr;
}

// ============================================================
// Kunde oeffnen (Doppelklick)
// ============================================================

function openKunde(kunId) {
    console.log('[Verrechnungssaetze] Oeffne Kunde:', kunId);
    // Navigation zum Kundenstamm
    if (typeof Bridge !== 'undefined' && Bridge.navigate) {
        Bridge.navigate('frm_KD_Kundenstamm', { id: kunId });
    } else {
        window.location.href = `frm_KD_Kundenstamm.html?id=${kunId}`;
    }
}

// ============================================================
// Suche / Filter
// ============================================================

function filterTable() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();

    if (!searchTerm) {
        filteredData = [...allData];
    } else {
        filteredData = allData.filter(row =>
            (row.firma || '').toLowerCase().includes(searchTerm)
        );
    }

    sortData();
    renderTable();
    updateRecordCount();
}

function updateRecordCount() {
    const countEl = document.getElementById('recordCount');
    countEl.textContent = `${filteredData.length} von ${allData.length} Kunden`;
}

// ============================================================
// Sortierung
// ============================================================

function sortTable(field) {
    // Toggle Richtung wenn gleiches Feld
    if (currentSort.field === field) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }

    // Header-Klassen aktualisieren
    document.querySelectorAll('.data-grid th').forEach(th => {
        th.classList.remove('sort-asc', 'sort-desc');
        if (th.dataset.sort === field) {
            th.classList.add(currentSort.direction === 'asc' ? 'sort-asc' : 'sort-desc');
        }
    });

    sortData();
    renderTable();
}

function sortData() {
    const { field, direction } = currentSort;
    const multiplier = direction === 'asc' ? 1 : -1;

    filteredData.sort((a, b) => {
        let valA = a[field];
        let valB = b[field];

        // Null-Werte ans Ende
        if (valA === null) return 1;
        if (valB === null) return -1;

        // String-Vergleich fuer Firma
        if (field === 'firma') {
            return multiplier * (valA || '').localeCompare(valB || '', 'de');
        }

        // Numerischer Vergleich fuer Preise
        return multiplier * (parseFloat(valA) - parseFloat(valB));
    });
}

// ============================================================
// Export / Drucken
// ============================================================

function exportToExcel() {
    showToast('Excel-Export wird vorbereitet...', 'warning');
    // TODO: Implementierung via API
    console.log('[Verrechnungssaetze] Excel Export');
}

function printTable() {
    window.print();
}

// ============================================================
// Aktualisieren / Schliessen
// ============================================================

function refreshData() {
    loadData();
}

function closeForm() {
    if (typeof Bridge !== 'undefined' && Bridge.close) {
        Bridge.close();
    } else {
        window.close();
    }
}

// ============================================================
// Hilfsfunktionen
// ============================================================

function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.classList.toggle('active', show);
    }
}

function setStatus(text) {
    const statusEl = document.getElementById('statusText');
    if (statusEl) {
        statusEl.textContent = text;
    }
}

function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 3000);
}

// ============================================================
// WINDOW EXPORTS fuer onclick Handler
// ============================================================
window.filterTable = filterTable;
window.sortTable = sortTable;
window.exportToExcel = exportToExcel;
window.printTable = printTable;
window.refreshData = refreshData;
window.closeForm = closeForm;
