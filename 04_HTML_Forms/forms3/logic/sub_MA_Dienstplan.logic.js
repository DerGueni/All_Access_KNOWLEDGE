/**
 * sub_MA_Dienstplan.logic.js
 * Logic-Datei fuer das Mitarbeiter Dienstplan Subformular
 */
'use strict';

let currentMA_ID = null;

// PostMessage Handler
window.addEventListener('message', function(event) {
    const data = event.data;
    if (data && data.type === 'LOAD_DATA') {
        currentMA_ID = data.ma_id || data.id;
        loadData();
    }
});

async function loadData() {
    if (!currentMA_ID) {
        document.getElementById('statusText').textContent = 'Keine MA-ID';
        return;
    }

    document.getElementById('statusText').textContent = 'Lade...';

    try {
        const response = await fetch(`http://localhost:5000/api/dienstplan/ma/${currentMA_ID}`);
        if (!response.ok) throw new Error('API Fehler');

        const data = await response.json();
        renderTable(data);
        document.getElementById('statusText').textContent = `${data.length} Eintraege`;
    } catch (error) {
        console.log('[sub_MA_Dienstplan] Fehler:', error);
        document.getElementById('statusText').textContent = 'Fehler beim Laden';
    }
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Keine Dienstplan-Eintraege vorhanden</td></tr>';
        return;
    }

    tbody.innerHTML = data.map(row => `
        <tr>
            <td>${formatDate(row.VADatum || row.Datum)}</td>
            <td>${row.Auftrag || ''}</td>
            <td>${row.Objekt || ''}</td>
            <td>${row.VA_Start || row.Von || ''}</td>
            <td>${row.VA_Ende || row.Bis || ''}</td>
            <td>${row.Stunden || ''}</td>
            <td>${row.Status || ''}</td>
        </tr>
    `).join('');
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

function exportData() {
    window.parent.postMessage({ type: 'EXPORT', source: 'sub_MA_Dienstplan' }, '*');
}

// ============================================
// WINDOW EXPORTS (fuer onclick Handler)
// ============================================
window.loadData = loadData;
window.exportData = exportData;

// Initial
document.getElementById('statusText').textContent = 'Warte auf Daten...';

console.log('[sub_MA_Dienstplan] Logic-Datei geladen');
