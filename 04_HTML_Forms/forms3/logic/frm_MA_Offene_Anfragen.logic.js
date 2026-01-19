/**
 * frm_MA_Offene_Anfragen.logic.js
 * Logik für Formular "Offene MA-Anfragen"
 *
 * Funktionalität:
 * - Lädt offene Anfragen von API (/api/anfragen)
 * - Filtert nach Datum (zukünftige Anfragen ohne Rückmeldung)
 * - Zeigt MA-Name, Datum, Auftrag, Ort, Zeit, Anfragezeitpunkt
 * - Klick auf Zeile zeigt Details
 * - Filter-Funktionen für verschiedene Zeiträume
 */

(function() {
    'use strict';

    // State
    let allAnfragen = [];
    let filteredAnfragen = [];
    let selectedRow = null;
    let selectedRows = new Set(); // Multi-Selektion für btnAnfragen

    // DOM-Elemente
    let tbody = null;
    let recordCount = null;
    let footerStatus = null;
    let lastUpdate = null;
    let filterView = null;

    /**
     * Initialisierung beim Laden der Seite
     */
    function init() {
        console.log('[Offene Anfragen] Initialisiere Formular...');

        // DOM-Referenzen cachen
        tbody = document.getElementById('anfrageTableBody');
        recordCount = document.getElementById('recordCount');
        footerStatus = document.getElementById('footerStatus');
        lastUpdate = document.getElementById('lastUpdate');
        filterView = document.getElementById('filterView');

        // Event Listener
        document.getElementById('btnRefresh').addEventListener('click', loadAnfragen);
        document.getElementById('btnAnfragen')?.addEventListener('click', erneutAnfragen);
        document.getElementById('btnFilter').addEventListener('click', toggleFilterDialog);
        document.getElementById('btnExport').addEventListener('click', exportToExcel);
        filterView.addEventListener('change', applyFilter);

        // Event Delegation für Tabellenzeilen
        tbody.addEventListener('click', handleRowClick);

        // Aktuelles Datum anzeigen
        updateCurrentDate();

        // Daten initial laden
        loadAnfragen();
    }

    /**
     * Lädt offene Anfragen über Bridge oder REST-API Fallback
     */
    async function loadAnfragen() {
        console.log('[Offene Anfragen] Lade Daten von API...');

        showLoading(true);
        footerStatus.textContent = 'Lade Daten...';

        // Bridge Event senden (WebView2)
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadAnfragen', {
                filter: {
                    openOnly: true,
                    futureOnly: true
                }
            });
        } else {
            // REST-API Fallback (Browser-Modus)
            console.log('[Offene Anfragen] Bridge nicht verfügbar, nutze REST-API Fallback');
            try {
                const response = await fetch('http://localhost:5000/api/anfragen?offen=true');
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                const data = await response.json();
                console.log('[Offene Anfragen] REST-API Daten empfangen:', data);

                // Daten verarbeiten (gleiche Logik wie handleBridgeData)
                allAnfragen = processAnfragenData(data);
                applyFilter();
                updateLastUpdateTime();
                footerStatus.textContent = 'Bereit';
                showLoading(false);
            } catch (err) {
                console.error('[Offene Anfragen] REST-API Fehler:', err);
                showError('Keine Verbindung zum API-Server (Port 5000)');
                showLoading(false);
            }
        }
    }

    /**
     * Verarbeitet die API-Daten und filtert offene Anfragen
     * Entspricht der Access-Abfrage: qry_MA_Offene_Anfragen
     * WHERE VADatum > Date() AND Anfragezeitpunkt > #1/1/2022# AND Rueckmeldezeitpunkt IS NULL
     */
    function processAnfragenData(data) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const cutoffDate = new Date('2022-01-01');

        // API gibt {data: Array, success: true} oder {anfragen: Array} zurück
        const rawData = data.data || data.anfragen || (Array.isArray(data) ? data : []);

        console.log('[Offene Anfragen] Verarbeite', rawData.length, 'Datensätze...');

        return rawData
            .filter(item => {
                // Nur zukünftige Einsätze (VADatum > heute)
                // API liefert: VADatum (Access-Feld)
                const vaDatum = item.VADatum || item.Dat_VA_Von;
                const datVon = vaDatum ? parseDate(vaDatum) : null;
                if (!datVon || datVon <= today) return false;

                // Nur mit Anfragezeitpunkt nach 1.1.2022
                const anfrageDat = item.Anfragezeitpunkt ? parseDate(item.Anfragezeitpunkt) : null;
                if (!anfrageDat || anfrageDat <= cutoffDate) return false;

                // Nur ohne Rückmeldung
                if (item.Rueckmeldezeitpunkt) return false;

                return true;
            })
            .map(item => ({
                id: item.id || item.ID || `${item.VA_ID}_${item.MA_ID}_${item.VAStart_ID}`,
                name: item.Name || `${item.Nachname || ''} ${item.Vorname || ''}`.trim(),
                datum: parseDate(item.VADatum || item.Dat_VA_Von),
                auftrag: item.Auftrag || '',
                ort: item.Ort || item.Objekt || '',
                von: item.von || item.MVA_Start || '',
                bis: item.bis || item.MVA_Ende || '',
                anfragezeitpunkt: parseDate(item.Anfragezeitpunkt),
                // IDs für Details
                va_id: item.VA_ID,
                ma_id: item.MA_ID,
                vastart_id: item.VAStart_ID,
                vadatum_id: item.VADatum_ID
            }))
            .sort((a, b) => {
                // Sortierung: Datum aufsteigend, dann Anfragezeitpunkt absteigend
                if (a.datum.getTime() !== b.datum.getTime()) {
                    return a.datum - b.datum;
                }
                return b.anfragezeitpunkt - a.anfragezeitpunkt;
            });
    }

    /**
     * Wendet den gewählten Filter an
     */
    function applyFilter() {
        const filterValue = filterView.value;
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        switch (filterValue) {
            case 'all':
                filteredAnfragen = allAnfragen;
                break;

            case 'future':
                filteredAnfragen = allAnfragen.filter(a => a.datum > today);
                break;

            case 'next7days':
                const next7 = new Date(today);
                next7.setDate(next7.getDate() + 7);
                filteredAnfragen = allAnfragen.filter(a => a.datum > today && a.datum <= next7);
                break;

            case 'next30days':
                const next30 = new Date(today);
                next30.setDate(next30.getDate() + 30);
                filteredAnfragen = allAnfragen.filter(a => a.datum > today && a.datum <= next30);
                break;

            default:
                filteredAnfragen = allAnfragen;
        }

        renderTable();
    }

    /**
     * Rendert die Tabelle mit den gefilterten Anfragen
     */
    function renderTable() {
        if (!tbody) return;

        tbody.innerHTML = '';

        if (filteredAnfragen.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="no-results">
                        Keine offenen Anfragen gefunden.
                    </td>
                </tr>
            `;
            recordCount.textContent = 'Keine Datensätze';
            return;
        }

        const fragment = document.createDocumentFragment();

        filteredAnfragen.forEach((anfrage, index) => {
            const tr = document.createElement('tr');
            tr.dataset.index = index;
            tr.dataset.id = anfrage.id;

            // Datum-CSS-Klasse basierend auf Zeitraum
            const datumClass = getDateClass(anfrage.datum);

            tr.innerHTML = `
                <td>${escapeHtml(anfrage.name)}</td>
                <td class="${datumClass}">${formatDate(anfrage.datum)}</td>
                <td>${escapeHtml(anfrage.auftrag)}</td>
                <td>${escapeHtml(anfrage.ort)}</td>
                <td>${formatTime(anfrage.von)}</td>
                <td>${formatTime(anfrage.bis)}</td>
                <td>${formatDate(anfrage.anfragezeitpunkt)}</td>
            `;

            fragment.appendChild(tr);
        });

        tbody.appendChild(fragment);

        // Record Count aktualisieren
        recordCount.textContent = `${filteredAnfragen.length} offene Anfrage${filteredAnfragen.length !== 1 ? 'n' : ''}`;
    }

    /**
     * Behandelt Klick auf Tabellenzeile
     * Unterstützt Multi-Selektion wie Access Datasheet:
     * - Einfacher Klick: Einzelselektion
     * - Ctrl+Klick: Zur Selektion hinzufügen/entfernen
     * - Shift+Klick: Bereich selektieren
     */
    let lastSelectedIndex = null; // Für Shift-Klick Bereichsselektion

    function handleRowClick(e) {
        const tr = e.target.closest('tr');
        if (!tr || !tr.dataset.index) return;

        const index = parseInt(tr.dataset.index, 10);

        // Shift+Klick: Bereichsselektion (wie Access SelHeight)
        if (e.shiftKey && lastSelectedIndex !== null) {
            const start = Math.min(lastSelectedIndex, index);
            const end = Math.max(lastSelectedIndex, index);

            // Alle Zeilen im Bereich selektieren
            for (let i = start; i <= end; i++) {
                selectedRows.add(i);
            }
            updateRowSelection();
            updateSelectionCount();
            return;
        }

        // Ctrl+Klick: Toggle einzelne Zeile
        if (e.ctrlKey || e.metaKey) {
            if (selectedRows.has(index)) {
                selectedRows.delete(index);
                tr.classList.remove('selected');
            } else {
                selectedRows.add(index);
                tr.classList.add('selected');
            }
            lastSelectedIndex = index;
            updateSelectionCount();
            return;
        }

        // Einfacher Klick: Einzelselektion (bisheriges Verhalten)
        // Vorherige Selektion komplett entfernen
        selectedRows.clear();
        if (selectedRow) {
            selectedRow.classList.remove('selected');
        }
        document.querySelectorAll('.anfragen-table tbody tr.selected').forEach(row => {
            row.classList.remove('selected');
        });

        // Neue Selektion setzen
        tr.classList.add('selected');
        selectedRow = tr;
        selectedRows.add(index);
        lastSelectedIndex = index;

        // Details anzeigen
        const anfrage = filteredAnfragen[index];
        showAnfrageDetails(anfrage);
        updateSelectionCount();
    }

    /**
     * Aktualisiert die Anzeige der Selektionsanzahl (entspricht txSelHeightSub in Access)
     */
    function updateSelectionCount() {
        const count = selectedRows.size;
        if (count > 1) {
            footerStatus.textContent = `${count} Datensätze ausgewählt`;
        } else if (count === 1) {
            const idx = Array.from(selectedRows)[0];
            const anfrage = filteredAnfragen[idx];
            if (anfrage) {
                footerStatus.textContent = `Ausgewählt: ${anfrage.name} - ${anfrage.auftrag}`;
            }
        } else {
            footerStatus.textContent = 'Bereit';
        }
    }

    /**
     * Zeigt Details der ausgewählten Anfrage
     */
    function showAnfrageDetails(anfrage) {
        console.log('[Offene Anfragen] Details:', anfrage);

        const details = `
Mitarbeiter: ${anfrage.name}
Auftrag: ${anfrage.auftrag}
Ort: ${anfrage.ort}
Datum: ${formatDate(anfrage.datum)}
Zeit: ${formatTime(anfrage.von)} - ${formatTime(anfrage.bis)}
Angefragt am: ${formatDate(anfrage.anfragezeitpunkt)}

IDs: VA=${anfrage.va_id}, MA=${anfrage.ma_id}, VAStart=${anfrage.vastart_id}
        `.trim();

        footerStatus.textContent = `Ausgewählt: ${anfrage.name} - ${anfrage.auftrag}`;

        // Hier könnte ein Detail-Panel oder Modal geöffnet werden
        // Für jetzt nur console.log
    }

    /**
     * Toggle Filter Dialog (Platzhalter)
     */
    function toggleFilterDialog() {
        alert('Filter-Dialog wird in einer späteren Version implementiert.');
    }

    /**
     * Export zu Excel (Platzhalter)
     */
    function exportToExcel() {
        if (filteredAnfragen.length === 0) {
            alert('Keine Daten zum Exportieren vorhanden.');
            return;
        }

        // CSV-Export als einfache Alternative
        const csv = convertToCSV(filteredAnfragen);
        downloadCSV(csv, 'Offene_Anfragen.csv');
    }

    /**
     * Erneut anfragen - Sendet Anfragen an ausgewählte Mitarbeiter
     * Entspricht VBA: btnAnfragen_Click()
     */
    async function erneutAnfragen() {
        // Wenn keine Multi-Selektion, die aktuelle Zeile verwenden
        if (selectedRows.size === 0 && selectedRow !== null) {
            const idx = parseInt(selectedRow.dataset.index);
            if (!isNaN(idx)) {
                selectedRows.add(idx);
            }
        }

        if (selectedRows.size === 0) {
            alert('Bitte wählen Sie mindestens eine Anfrage aus.');
            return;
        }

        const results = [];
        footerStatus.textContent = 'Sende Anfragen...';

        for (const idx of selectedRows) {
            const anfrage = filteredAnfragen[idx];
            if (!anfrage) continue;

            console.log('[Offene Anfragen] Sende Anfrage an:', anfrage.name, anfrage);

            try {
                // Bridge-Event senden um VBA-Funktion "Anfragen" aufzurufen
                if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
                    await Bridge.sendEvent('anfragen', {
                        ma_id: anfrage.ma_id,
                        va_id: anfrage.va_id,
                        vadatum_id: anfrage.vadatum_id,
                        vastart_id: anfrage.vastart_id
                    });
                    results.push(`${anfrage.name}: OK`);
                } else {
                    // Fallback: API-Aufruf an VBA Bridge Server (Port 5002)
                    // Die VBA-Funktion "Anfragen" sendet die E-Mail und setzt Anfragezeitpunkt
                    try {
                        const response = await fetch('http://localhost:5002/api/vba/anfragen', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                ma_id: anfrage.ma_id,
                                va_id: anfrage.va_id,
                                vadatum_id: anfrage.vadatum_id,
                                vastart_id: anfrage.vastart_id
                            })
                        });
                        if (response.ok) {
                            const result = await response.json();
                            results.push(`${anfrage.name}: ${result.message || 'OK'}`);
                        } else {
                            results.push(`${anfrage.name}: Fehler (API)`);
                        }
                    } catch (apiErr) {
                        console.error('[Offene Anfragen] API-Fallback fehlgeschlagen:', apiErr);
                        results.push(`${anfrage.name}: Keine Verbindung zu VBA Bridge`);
                    }
                }
            } catch (err) {
                console.error('[Offene Anfragen] Fehler bei Anfrage:', err);
                results.push(`${anfrage.name}: Fehler - ${err.message}`);
            }
        }

        // Ergebnis anzeigen
        alert('Anfragen-Ergebnis:\n\n' + results.join('\n'));

        // Selektion zurücksetzen
        selectedRows.clear();
        updateRowSelection();

        // Daten neu laden
        loadAnfragen();

        footerStatus.textContent = 'Anfragen gesendet';
    }

    /**
     * Aktualisiert die visuelle Selektion der Zeilen
     */
    function updateRowSelection() {
        if (!tbody) return;
        const rows = tbody.querySelectorAll('tr');
        rows.forEach(row => {
            const idx = parseInt(row.dataset.index);
            if (selectedRows.has(idx)) {
                row.classList.add('selected');
            } else {
                row.classList.remove('selected');
            }
        });
    }

    /**
     * Konvertiert Daten zu CSV
     */
    function convertToCSV(data) {
        const headers = ['Mitarbeiter', 'Datum', 'Auftrag', 'Ort', 'Von', 'Bis', 'Angefragt am'];
        const rows = data.map(a => [
            a.name,
            formatDate(a.datum),
            a.auftrag,
            a.ort,
            formatTime(a.von),
            formatTime(a.bis),
            formatDate(a.anfragezeitpunkt)
        ]);

        const csvContent = [
            headers.join(';'),
            ...rows.map(r => r.map(cell => `"${cell}"`).join(';'))
        ].join('\n');

        return csvContent;
    }

    /**
     * Download CSV-Datei
     */
    function downloadCSV(csvContent, filename) {
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);

        link.setAttribute('href', url);
        link.setAttribute('download', filename);
        link.style.visibility = 'hidden';

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    /**
     * Zeigt/versteckt Loading State
     */
    function showLoading(show) {
        if (!tbody) return;

        if (show) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="loading">
                        <div class="spinner"></div>
                        <div>Lade offene Anfragen...</div>
                    </td>
                </tr>
            `;
        }
    }

    /**
     * Zeigt Fehlermeldung
     */
    function showError(message) {
        if (!tbody) return;

        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="no-results" style="color: #d9534f;">
                    ⚠️ ${escapeHtml(message)}
                </td>
            </tr>
        `;
        recordCount.textContent = 'Fehler';
    }

    /**
     * Aktualisiert das aktuelle Datum im Header
     */
    function updateCurrentDate() {
        const dateEl = document.getElementById('currentDate');
        if (dateEl) {
            const now = new Date();
            dateEl.textContent = formatDate(now);
        }
    }

    /**
     * Aktualisiert die "Zuletzt aktualisiert" Anzeige
     */
    function updateLastUpdateTime() {
        if (lastUpdate) {
            const now = new Date();
            lastUpdate.textContent = `Stand: ${formatTime(now)}`;
        }
    }

    /**
     * Bestimmt CSS-Klasse für Datum basierend auf Zeitraum
     */
    function getDateClass(date) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const diff = Math.floor((date - today) / (1000 * 60 * 60 * 24));

        if (diff < 0) return 'date-past';
        if (diff <= 7) return 'date-soon';
        return 'date-future';
    }

    /**
     * Parst Datums-String zu Date-Objekt
     */
    function parseDate(dateStr) {
        if (!dateStr) return null;

        // ISO-Format oder Access-Format
        if (typeof dateStr === 'string') {
            // Wenn bereits ISO-Format (YYYY-MM-DD)
            if (dateStr.match(/^\d{4}-\d{2}-\d{2}/)) {
                return new Date(dateStr);
            }
            // Wenn DD.MM.YYYY
            if (dateStr.match(/^\d{2}\.\d{2}\.\d{4}/)) {
                const parts = dateStr.split('.');
                return new Date(parts[2], parts[1] - 1, parts[0]);
            }
        }

        return new Date(dateStr);
    }

    /**
     * Formatiert Datum zu deutschem Format
     */
    function formatDate(date) {
        if (!date) return '';
        if (!(date instanceof Date)) date = new Date(date);

        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();

        return `${day}.${month}.${year}`;
    }

    /**
     * Formatiert Zeit zu deutschem Format (HH:MM)
     */
    function formatTime(timeStr) {
        if (!timeStr) return '';

        // Wenn bereits HH:MM Format
        if (typeof timeStr === 'string' && timeStr.match(/^\d{2}:\d{2}$/)) {
            return timeStr;
        }

        // Wenn ISO DateTime Format (2026-12-19T17:30:00)
        if (typeof timeStr === 'string' && timeStr.includes('T')) {
            const timePart = timeStr.split('T')[1];
            if (timePart) {
                return timePart.substring(0, 5); // HH:MM
            }
        }

        // Wenn HH:MM:SS Format
        if (typeof timeStr === 'string' && timeStr.match(/^\d{2}:\d{2}:\d{2}/)) {
            return timeStr.substring(0, 5);
        }

        // Wenn Date-Objekt
        if (timeStr instanceof Date) {
            const hours = String(timeStr.getHours()).padStart(2, '0');
            const minutes = String(timeStr.getMinutes()).padStart(2, '0');
            return `${hours}:${minutes}`;
        }

        return timeStr;
    }

    /**
     * Escaped HTML für sichere Anzeige
     */
    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Bridge Event-Handler für eingehende Daten
     */
    function handleBridgeData(data) {
        console.log('[Offene Anfragen] Bridge Daten empfangen:', data);

        try {
            if (data.anfragen) {
                // Daten verarbeiten und filtern
                allAnfragen = processAnfragenData(data);

                // Initial Filter anwenden
                applyFilter();

                // UI aktualisieren
                updateLastUpdateTime();
                footerStatus.textContent = 'Bereit';
            } else if (data.error) {
                throw new Error(data.error);
            }
        } catch (error) {
            console.error('[Offene Anfragen] Fehler bei Datenverarbeitung:', error);
            showError('Fehler beim Verarbeiten der Daten: ' + error.message);
            footerStatus.textContent = 'Fehler';
        } finally {
            showLoading(false);
        }
    }

    // Bridge Event-Listener registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
        console.log('[Offene Anfragen] Bridge Event-Listener registriert');
    }

    // Initialisierung beim DOM-Ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
