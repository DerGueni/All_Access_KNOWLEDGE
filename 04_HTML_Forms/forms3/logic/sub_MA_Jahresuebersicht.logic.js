/**
 * sub_MA_Jahresuebersicht.logic.js
 * Logic-Datei fuer das Mitarbeiter Jahresuebersicht Subformular
 */
'use strict';

const MONATE = ['Jan', 'Feb', 'Mrz', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
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

    const year = document.getElementById('yearSelect').value;

    try {
        const response = await fetch(`http://localhost:5000/api/zeitkonten/jahresuebersicht/${currentMA_ID}?jahr=${year}`);
        if (!response.ok) throw new Error('API Fehler');

        const data = await response.json();
        renderData(data);
    } catch (error) {
        console.log('[sub_MA_Jahresuebersicht] Fehler:', error);
        renderEmptyState();
    }
}

function renderData(data) {
    // Calendar Grid
    const grid = document.getElementById('calendarGrid');
    const monate = data.monate || [];

    grid.innerHTML = MONATE.map((name, i) => {
        const monat = monate[i] || {};
        return `
            <div class="month-card">
                <div class="month-name">${name}</div>
                <div class="month-hours">${monat.stunden || '0'}h</div>
                <div class="month-stats">${monat.tage || '0'} Tage</div>
            </div>
        `;
    }).join('');

    // Table
    const tbody = document.getElementById('tableBody');
    if (monate.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Keine Daten vorhanden</td></tr>';
        return;
    }

    tbody.innerHTML = monate.map((m, i) => `
        <tr>
            <td>${MONATE[i]}</td>
            <td class="text-right">${m.arbeitstage || ''}</td>
            <td class="text-right">${m.soll || ''}</td>
            <td class="text-right">${m.ist || ''}</td>
            <td class="text-right">${m.urlaub || ''}</td>
            <td class="text-right">${m.krank || ''}</td>
        </tr>
    `).join('');
}

function renderEmptyState() {
    const grid = document.getElementById('calendarGrid');
    grid.innerHTML = MONATE.map(name => `
        <div class="month-card">
            <div class="month-name">${name}</div>
            <div class="month-hours">0h</div>
            <div class="month-stats">0 Tage</div>
        </div>
    `).join('');

    document.getElementById('tableBody').innerHTML =
        '<tr><td colspan="6" class="empty-state">Keine Daten vorhanden</td></tr>';
}

// ============================================
// WINDOW EXPORTS (fuer onclick Handler)
// ============================================
window.loadData = loadData;

// Initial render
renderEmptyState();

console.log('[sub_MA_Jahresuebersicht] Logic-Datei geladen');
