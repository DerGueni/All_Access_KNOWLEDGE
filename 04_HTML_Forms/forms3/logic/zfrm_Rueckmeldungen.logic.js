/**
 * zfrm_Rueckmeldungen.logic.js
 *
 * JavaScript-Logik für das Formular "Auswertung der Rückmeldungen"
 *
 * Entspricht dem Access-Formular zfrm_Rueckmeldungen mit:
 * - Form_Load: Ruft Rückmeldeauswertung auf (lädt Daten)
 * - Form_Close: Löscht temporäre Tabelle ztbl_Rueckmeldezeiten
 * - Subform zsub_Rueckmeldungen: Endlosformular mit Statistikdaten pro Mitarbeiter
 *
 * Query zqry_Rueckmeldungen:
 * SELECT MA_ID, Count(Anfragezeitpunkt) AS AnzahlvonAnfragezeitpunkt,
 *        Count(Rueckmeldezeitpunkt) AS AnzahlvonRueckmeldezeitpunkt,
 *        Avg(Reaktionszeit) AS MittelwertvonReaktionszeit,
 *        Round(IIf([AnzahlvonAnfragezeitpunkt]<>0,[AnzahlvonRueckmeldezeitpunkt]/[AnzahlvonAnfragezeitpunkt]*100,0),0) AS Antwortrate,
 *        Sum(IIf([Status_ID]=3,1,0)) AS Zusagen,
 *        Sum(IIf([Status_ID]=4,1,0)) AS Absagen
 * FROM ztbl_Rueckmeldezeiten GROUP BY MA_ID
 */

'use strict';

// ============================================================================
// KONSTANTEN & KONFIGURATION
// ============================================================================

const API_BASE = 'http://localhost:5000/api';
const VBA_BRIDGE = 'http://localhost:5002';

// Globaler State
let rueckmeldungenData = [];
let currentSortField = 'Name';
let currentSortOrder = 'ASC';
let selectedRowId = null;

// ============================================================================
// FORM EVENTS (Access VBA → JavaScript Mapping)
// ============================================================================

/**
 * Form_Load - Entspricht Access Form_Load Event
 * In Access: Call Rückmeldeauswertung
 */
async function Form_Load() {
    console.log('[zfrm_Rueckmeldungen] Form_Load');

    // VBA Bridge: Rückmeldeauswertung aufrufen (füllt ztbl_Rueckmeldezeiten)
    try {
        await callVBABridge('Rückmeldeauswertung');
    } catch (e) {
        console.warn('[Form_Load] VBA Bridge nicht erreichbar, verwende REST API:', e.message);
    }

    // Daten laden
    await loadRueckmeldungen();
}

/**
 * Form_Close - Entspricht Access Form_Close Event
 * In Access: CurrentDb.Execute "DELETE * FROM ztbl_Rueckmeldezeiten"
 */
async function Form_Close() {
    console.log('[zfrm_Rueckmeldungen] Form_Close');

    // Optional: VBA Bridge aufrufen um temporäre Tabelle zu leeren
    try {
        await fetch(`${VBA_BRIDGE}/execute`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'execute_sql',
                sql: 'DELETE * FROM ztbl_Rueckmeldezeiten'
            })
        });
    } catch (e) {
        console.warn('[Form_Close] Cleanup nicht möglich:', e.message);
    }
}

// ============================================================================
// DATEN LADEN & ANZEIGEN
// ============================================================================

/**
 * Lädt Rückmeldungen-Statistik vom API Server
 */
async function loadRueckmeldungen() {
    const tableBody = document.getElementById('tableBody');
    tableBody.innerHTML = '<tr><td colspan="8" class="loading">Lade Daten...</td></tr>';

    try {
        // Filter-Werte auslesen
        const anstellungsart = document.getElementById('filterAnstellungsart').value;
        const sortField = document.getElementById('sortField').value;
        const sortOrder = document.getElementById('sortOrder').value;

        currentSortField = sortField;
        currentSortOrder = sortOrder;

        // API Request mit Parametern
        let url = `${API_BASE}/rueckmeldungen/statistik`;
        const params = new URLSearchParams();

        if (anstellungsart) {
            params.append('anstellungsart', anstellungsart);
        }
        params.append('sort', sortField);
        params.append('order', sortOrder);

        if (params.toString()) {
            url += '?' + params.toString();
        }

        console.log('[loadRueckmeldungen] Fetching:', url);

        const response = await fetch(url);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();
        rueckmeldungenData = result.data || result || [];

        // Tabelle rendern
        renderTable(rueckmeldungenData);

        // Zusammenfassung berechnen
        updateSummary(rueckmeldungenData);

        // Status aktualisieren
        document.getElementById('recordCount').textContent = `${rueckmeldungenData.length} Datensätze`;
        document.getElementById('lastUpdate').textContent = `Letzte Aktualisierung: ${new Date().toLocaleTimeString('de-DE')}`;

    } catch (error) {
        console.error('[loadRueckmeldungen] Fehler:', error);
        tableBody.innerHTML = `<tr><td colspan="8" style="color:red; text-align:center;">Fehler beim Laden: ${error.message}</td></tr>`;

        // Fallback: Testdaten laden falls API nicht erreichbar
        if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
            console.log('[loadRueckmeldungen] Versuche Fallback mit Testdaten...');
            loadTestData();
        }
    }
}

/**
 * Rendert die Tabelle mit den Rückmeldungsdaten
 */
function renderTable(data) {
    const tableBody = document.getElementById('tableBody');

    if (!data || data.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="8" style="text-align:center; color:#606060;">Keine Daten vorhanden</td></tr>';
        return;
    }

    tableBody.innerHTML = data.map((row, index) => {
        const ma_id = row.MA_ID || row.ma_id || '';
        const name = row.Name || row.name || row.Mitarbeiter || `MA ${ma_id}`;
        const anstellungsart = row.Anstellungsart_ID || row.anstellungsart_id || row.Anstellungsart || '-';
        const anzAnfragen = row.AnzahlvonAnfragezeitpunkt || row.anzahl_anfragen || 0;
        const anzRueckmeldungen = row.AnzahlvonRueckmeldezeitpunkt || row.anzahl_rueckmeldungen || 0;
        const reaktionszeit = row.MittelwertvonReaktionszeit || row.reaktionszeit || 0;
        const antwortrate = row.Antwortrate || row.antwortrate || 0;
        const zusagen = row.Zusagen || row.zusagen || 0;
        const absagen = row.Absagen || row.absagen || 0;

        const isSelected = selectedRowId === ma_id;

        return `<tr data-ma-id="${ma_id}" class="${isSelected ? 'selected' : ''}"
                    onclick="selectRow(${ma_id})"
                    ondblclick="openMitarbeiter(${ma_id})">
            <td>${escapeHtml(name)}</td>
            <td class="num">${anstellungsart}</td>
            <td class="num">${anzAnfragen}</td>
            <td class="num">${anzRueckmeldungen}</td>
            <td class="num">${formatReaktionszeit(reaktionszeit)}</td>
            <td class="num">${antwortrate}%</td>
            <td class="num" style="color: #208020; font-weight: bold;">${zusagen}</td>
            <td class="num" style="color: #c04040; font-weight: bold;">${absagen}</td>
        </tr>`;
    }).join('');

    // Sortier-Icons aktualisieren
    updateSortIcons();
}

/**
 * Aktualisiert die Zusammenfassungs-Karten
 */
function updateSummary(data) {
    if (!data || data.length === 0) {
        document.getElementById('sumAnfragen').textContent = '0';
        document.getElementById('sumRueckmeldungen').textContent = '0';
        document.getElementById('sumZusagen').textContent = '0';
        document.getElementById('sumAbsagen').textContent = '0';
        document.getElementById('avgAntwortrate').textContent = '0%';
        return;
    }

    let sumAnfragen = 0;
    let sumRueckmeldungen = 0;
    let sumZusagen = 0;
    let sumAbsagen = 0;
    let sumAntwortrate = 0;

    data.forEach(row => {
        sumAnfragen += parseInt(row.AnzahlvonAnfragezeitpunkt || row.anzahl_anfragen || 0);
        sumRueckmeldungen += parseInt(row.AnzahlvonRueckmeldezeitpunkt || row.anzahl_rueckmeldungen || 0);
        sumZusagen += parseInt(row.Zusagen || row.zusagen || 0);
        sumAbsagen += parseInt(row.Absagen || row.absagen || 0);
        sumAntwortrate += parseFloat(row.Antwortrate || row.antwortrate || 0);
    });

    const avgAntwortrate = data.length > 0 ? Math.round(sumAntwortrate / data.length) : 0;

    document.getElementById('sumAnfragen').textContent = sumAnfragen.toLocaleString('de-DE');
    document.getElementById('sumRueckmeldungen').textContent = sumRueckmeldungen.toLocaleString('de-DE');
    document.getElementById('sumZusagen').textContent = sumZusagen.toLocaleString('de-DE');
    document.getElementById('sumAbsagen').textContent = sumAbsagen.toLocaleString('de-DE');
    document.getElementById('avgAntwortrate').textContent = avgAntwortrate + '%';
}

// ============================================================================
// SORTIERUNG
// ============================================================================

/**
 * Sortiert die Tabelle nach dem angegebenen Feld
 */
function sortBy(field) {
    // Toggle Sortierrichtung wenn gleiches Feld
    if (currentSortField === field) {
        currentSortOrder = currentSortOrder === 'ASC' ? 'DESC' : 'ASC';
    } else {
        currentSortField = field;
        currentSortOrder = 'ASC';
    }

    // Dropdown-Werte aktualisieren
    document.getElementById('sortField').value = field;
    document.getElementById('sortOrder').value = currentSortOrder;

    // Daten neu laden
    loadRueckmeldungen();
}

/**
 * Aktualisiert die Sortier-Icons in den Spaltenköpfen
 */
function updateSortIcons() {
    // Alle Icons entfernen
    document.querySelectorAll('.data-table th').forEach(th => {
        th.classList.remove('sort-asc', 'sort-desc');
    });

    // Aktuelles Icon setzen
    const activeHeader = document.querySelector(`.data-table th[data-field="${currentSortField}"]`);
    if (activeHeader) {
        activeHeader.classList.add(currentSortOrder === 'ASC' ? 'sort-asc' : 'sort-desc');
    }
}

// ============================================================================
// ZEILEN-INTERAKTION
// ============================================================================

/**
 * Wählt eine Zeile aus (einzelklick)
 */
function selectRow(ma_id) {
    selectedRowId = ma_id;

    // Alle Zeilen deselektieren
    document.querySelectorAll('.data-table tbody tr').forEach(tr => {
        tr.classList.remove('selected');
    });

    // Aktuelle Zeile selektieren
    const row = document.querySelector(`.data-table tbody tr[data-ma-id="${ma_id}"]`);
    if (row) {
        row.classList.add('selected');
    }
}

/**
 * Öffnet den Mitarbeiterstamm (Doppelklick)
 */
function openMitarbeiter(ma_id) {
    console.log('[openMitarbeiter] MA_ID:', ma_id);

    // Versuche WebView2 Bridge
    if (typeof Bridge !== 'undefined' && Bridge.openForm) {
        Bridge.openForm('frm_MA_Mitarbeiterstamm', { MA_ID: ma_id });
    } else {
        // Fallback: Shell-Navigation
        const shellFrame = window.parent;
        if (shellFrame && shellFrame !== window) {
            shellFrame.postMessage({
                type: 'NAVIGATE',
                form: 'frm_MA_Mitarbeiterstamm.html',
                params: { ma_id: ma_id }
            }, '*');
        } else {
            // Direktes Öffnen
            window.location.href = `frm_MA_Mitarbeiterstamm.html?ma_id=${ma_id}`;
        }
    }
}

// ============================================================================
// BUTTON-HANDLER
// ============================================================================

/**
 * Exportiert die Daten nach Excel
 */
function exportToExcel() {
    console.log('[exportToExcel] Export gestartet');

    if (!rueckmeldungenData || rueckmeldungenData.length === 0) {
        alert('Keine Daten zum Exportieren vorhanden.');
        return;
    }

    // CSV erstellen
    const headers = ['Mitarbeiter', 'Anstellungsart', 'Anz. Anfragen', 'Anz. Rückmeldungen', 'Reaktionszeit (h)', 'Antwortrate %', 'Zusagen', 'Absagen'];
    const rows = rueckmeldungenData.map(row => [
        row.Name || row.name || '',
        row.Anstellungsart_ID || row.anstellungsart_id || '',
        row.AnzahlvonAnfragezeitpunkt || row.anzahl_anfragen || 0,
        row.AnzahlvonRueckmeldezeitpunkt || row.anzahl_rueckmeldungen || 0,
        formatReaktionszeit(row.MittelwertvonReaktionszeit || row.reaktionszeit || 0),
        row.Antwortrate || row.antwortrate || 0,
        row.Zusagen || row.zusagen || 0,
        row.Absagen || row.absagen || 0
    ]);

    const csv = [
        headers.join(';'),
        ...rows.map(r => r.join(';'))
    ].join('\n');

    // Download
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `Rueckmeldungen_${formatDate(new Date())}.csv`;
    link.click();

    console.log('[exportToExcel] Export abgeschlossen');
}

/**
 * Schließt das Formular
 */
function closeForm() {
    console.log('[closeForm] Formular wird geschlossen');

    // Form_Close Event aufrufen
    Form_Close();

    // Versuche verschiedene Schließ-Methoden
    if (typeof Bridge !== 'undefined' && Bridge.close) {
        Bridge.close();
    } else if (window.parent && window.parent !== window) {
        window.parent.postMessage({ type: 'CLOSE_FORM' }, '*');
    } else {
        window.history.back();
    }
}

// ============================================================================
// HILFSFUNKTIONEN
// ============================================================================

/**
 * Ruft eine VBA-Funktion über den VBA Bridge Server auf
 */
async function callVBABridge(functionName, params = {}) {
    const response = await fetch(`${VBA_BRIDGE}/execute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            action: 'run_vba',
            function: functionName,
            params: params
        })
    });

    if (!response.ok) {
        throw new Error(`VBA Bridge Error: ${response.status}`);
    }

    return await response.json();
}

/**
 * Formatiert Reaktionszeit in lesbares Format
 */
function formatReaktionszeit(hours) {
    if (hours === null || hours === undefined || isNaN(hours)) return '-';
    const h = parseFloat(hours);
    if (h < 1) {
        return Math.round(h * 60) + ' min';
    }
    return h.toFixed(1);
}

/**
 * Formatiert Datum für Dateinamen
 */
function formatDate(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
}

/**
 * Escaped HTML-Sonderzeichen
 */
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Lädt Testdaten falls API nicht erreichbar
 */
function loadTestData() {
    console.log('[loadTestData] Lade Testdaten...');

    const testData = [
        { MA_ID: 1, Name: 'Müller, Hans', Anstellungsart_ID: 3, AnzahlvonAnfragezeitpunkt: 45, AnzahlvonRueckmeldezeitpunkt: 42, MittelwertvonReaktionszeit: 2.5, Antwortrate: 93, Zusagen: 38, Absagen: 4 },
        { MA_ID: 2, Name: 'Schmidt, Anna', Anstellungsart_ID: 3, AnzahlvonAnfragezeitpunkt: 32, AnzahlvonRueckmeldezeitpunkt: 30, MittelwertvonReaktionszeit: 1.8, Antwortrate: 94, Zusagen: 28, Absagen: 2 },
        { MA_ID: 3, Name: 'Weber, Peter', Anstellungsart_ID: 5, AnzahlvonAnfragezeitpunkt: 28, AnzahlvonRueckmeldezeitpunkt: 20, MittelwertvonReaktionszeit: 4.2, Antwortrate: 71, Zusagen: 18, Absagen: 2 },
        { MA_ID: 4, Name: 'Fischer, Maria', Anstellungsart_ID: 3, AnzahlvonAnfragezeitpunkt: 50, AnzahlvonRueckmeldezeitpunkt: 48, MittelwertvonReaktionszeit: 1.2, Antwortrate: 96, Zusagen: 45, Absagen: 3 },
        { MA_ID: 5, Name: 'Bauer, Thomas', Anstellungsart_ID: 5, AnzahlvonAnfragezeitpunkt: 15, AnzahlvonRueckmeldezeitpunkt: 10, MittelwertvonReaktionszeit: 8.5, Antwortrate: 67, Zusagen: 8, Absagen: 2 },
    ];

    // Filter anwenden
    const anstellungsart = document.getElementById('filterAnstellungsart').value;
    let filteredData = testData;

    if (anstellungsart) {
        const filterValues = anstellungsart.split(',').map(v => parseInt(v.trim()));
        filteredData = testData.filter(row => filterValues.includes(row.Anstellungsart_ID));
    }

    // Sortieren
    const sortField = document.getElementById('sortField').value;
    const sortOrder = document.getElementById('sortOrder').value;

    filteredData.sort((a, b) => {
        let valA = a[sortField] || a.Name;
        let valB = b[sortField] || b.Name;

        if (typeof valA === 'string') {
            valA = valA.toLowerCase();
            valB = valB.toLowerCase();
        }

        if (sortOrder === 'ASC') {
            return valA < valB ? -1 : valA > valB ? 1 : 0;
        } else {
            return valA > valB ? -1 : valA < valB ? 1 : 0;
        }
    });

    rueckmeldungenData = filteredData;
    renderTable(filteredData);
    updateSummary(filteredData);

    document.getElementById('recordCount').textContent = `${filteredData.length} Datensätze (Testdaten)`;
    document.getElementById('lastUpdate').textContent = `Letzte Aktualisierung: ${new Date().toLocaleTimeString('de-DE')} (Offline)`;
}

// ============================================================================
// INITIALISIERUNG (DOMContentLoaded = Form_Load)
// ============================================================================

document.addEventListener('DOMContentLoaded', function() {
    console.log('[zfrm_Rueckmeldungen] DOMContentLoaded - Initialisierung');

    // Form_Load aufrufen
    Form_Load();

    // Cleanup bei Page Unload (Form_Close)
    window.addEventListener('beforeunload', Form_Close);
});

// Globale Funktionen für onclick-Handler verfügbar machen
window.loadRueckmeldungen = loadRueckmeldungen;
window.sortBy = sortBy;
window.selectRow = selectRow;
window.openMitarbeiter = openMitarbeiter;
window.exportToExcel = exportToExcel;
window.closeForm = closeForm;
