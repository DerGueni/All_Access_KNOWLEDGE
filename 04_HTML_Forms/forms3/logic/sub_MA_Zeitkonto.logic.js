'use strict';
/**
 * sub_MA_Zeitkonto.logic.js
 * Logic-Datei fuer Mitarbeiter Zeitkonto Subformular
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

    try {
        const response = await fetch(`http://localhost:5000/api/zeitkonten/ma/${currentMA_ID}`);
        if (!response.ok) throw new Error('API Fehler');

        const data = await response.json();
        renderData(data);
    } catch (error) {
        console.log('[sub_MA_Zeitkonto] Fehler:', error);
    }
}

function renderData(data) {
    // Summary
    if (data.summary) {
        document.getElementById('sollStunden').textContent = data.summary.soll || '0:00';
        document.getElementById('istStunden').textContent = data.summary.ist || '0:00';

        const diff = data.summary.differenz || '0:00';
        const diffEl = document.getElementById('differenz');
        diffEl.textContent = diff;
        diffEl.className = 'summary-value ' + (diff.startsWith('-') ? 'negative' : 'positive');

        document.getElementById('ueberstunden').textContent = data.summary.ueberstunden || '0:00';
    }

    // Table
    const tbody = document.getElementById('tableBody');
    const rows = data.monate || data.rows || [];

    if (rows.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="empty-state">Keine Zeitkonto-Daten vorhanden</td></tr>';
        return;
    }

    tbody.innerHTML = rows.map(row => `
        <tr>
            <td>${row.Monat || ''}</td>
            <td class="text-right">${row.Soll || ''}</td>
            <td class="text-right">${row.Ist || ''}</td>
            <td class="text-right">${row.Diff || ''}</td>
            <td class="text-right">${row.Saldo || ''}</td>
        </tr>
    `).join('');
}

// Window exports fuer onclick-Handler im HTML
window.loadData = loadData;
