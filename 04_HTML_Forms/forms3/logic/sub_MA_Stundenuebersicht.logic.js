'use strict';
/**
 * sub_MA_Stundenuebersicht.logic.js
 * Logic-Datei fuer Mitarbeiter Stundenuebersicht Subformular
 */

let currentMA_ID = null;

// Set default dates
document.addEventListener('DOMContentLoaded', function() {
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    document.getElementById('filterVon').valueAsDate = firstDay;
    document.getElementById('filterBis').valueAsDate = today;
});

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data && data.type === 'LOAD_DATA') {
        currentMA_ID = data.ma_id || data.id;
        loadData();
    }
});

async function loadData() {
    if (!currentMA_ID) return;

    const von = document.getElementById('filterVon').value;
    const bis = document.getElementById('filterBis').value;

    document.getElementById('statusBar').textContent = 'Lade Daten...';

    try {
        const response = await fetch(`http://localhost:5000/api/stunden/ma/${currentMA_ID}?von=${von}&bis=${bis}`);
        if (!response.ok) throw new Error('API Fehler');

        const data = await response.json();
        renderTable(data);
    } catch (error) {
        console.log('[sub_MA_Stundenuebersicht] Fehler:', error);
        document.getElementById('statusBar').textContent = 'Fehler beim Laden';
    }
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    const tfoot = document.getElementById('tableFoot');
    const rows = data.eintraege || data || [];

    if (rows.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Keine Stunden-Eintraege vorhanden</td></tr>';
        tfoot.style.display = 'none';
        document.getElementById('statusBar').textContent = 'Keine Eintraege';
        return;
    }

    let sumStd = 0, sumZusch = 0, sumGes = 0;

    tbody.innerHTML = rows.map(row => {
        const std = parseFloat(row.Stunden) || 0;
        const zusch = parseFloat(row.Zuschlag) || 0;
        const ges = std + zusch;
        sumStd += std;
        sumZusch += zusch;
        sumGes += ges;

        return `
            <tr>
                <td>${formatDate(row.Datum)}</td>
                <td>${row.Auftrag || ''}</td>
                <td>${row.Objekt || ''}</td>
                <td class="text-right">${std.toFixed(2)}</td>
                <td class="text-right">${zusch.toFixed(2)}</td>
                <td class="text-right">${ges.toFixed(2)}</td>
            </tr>
        `;
    }).join('');

    document.getElementById('sumStunden').textContent = sumStd.toFixed(2);
    document.getElementById('sumZuschlag').textContent = sumZusch.toFixed(2);
    document.getElementById('sumGesamt').textContent = sumGes.toFixed(2);
    tfoot.style.display = '';

    document.getElementById('statusBar').textContent = `${rows.length} Eintraege | Gesamt: ${sumGes.toFixed(2)} Std`;
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

// Window exports fuer onclick-Handler im HTML
window.loadData = loadData;
