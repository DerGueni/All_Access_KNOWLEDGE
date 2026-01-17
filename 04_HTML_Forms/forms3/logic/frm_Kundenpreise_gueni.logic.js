/**
 * Logic-Datei für Kundenpreise Verwaltung
 * frm_Kundenpreise_gueni.logic.js
 */

const KundenpreiseLogic = (function() {
    'use strict';

    // State
    let state = {
        kundenpreise: [],
        filteredData: [],
        modifiedRows: new Set(),
        isLoading: false
    };

    // DOM Elements (cached)
    let elements = {};

    // API Base URL
    const API_BASE = 'http://localhost:5000/api';

    /**
     * Initialize the form
     */
    async function init() {
        console.log('[KundenpreiseLogic] Initialisiere...');

        // Cache DOM elements
        elements = {
            priceTableBody: document.getElementById('priceTableBody'),
            filterFirma: document.getElementById('filterFirma'),
            filterAktiv: document.getElementById('filterAktiv'),
            loadingOverlay: document.getElementById('loadingOverlay'),
            toastContainer: document.getElementById('toastContainer'),
            recordCount: document.getElementById('recordCount'),
            statusText: document.getElementById('statusText'),
            lastUpdate: document.getElementById('lastUpdate')
        };

        // Event Listeners
        if (elements.filterFirma) {
            elements.filterFirma.addEventListener('input', debounce(filterTable, 300));
        }
        if (elements.filterAktiv) {
            elements.filterAktiv.addEventListener('change', filterTable);
        }

        // Load initial data
        await refreshData();

        console.log('[KundenpreiseLogic] Initialisierung abgeschlossen');
    }

    /**
     * Load/refresh price data from API
     */
    async function refreshData() {
        showLoading(true);
        updateStatus('Lade Daten...');

        try {
            const response = await fetch(`${API_BASE}/kundenpreise`);

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            state.kundenpreise = Array.isArray(data) ? data : (data.data || []);
            state.modifiedRows.clear();

            filterTable();
            updateRecordCount();
            updateStatus('Bereit');
            updateLastUpdate();

            showToast(`${state.kundenpreise.length} Datensätze geladen`, 'success');

        } catch (error) {
            console.error('[KundenpreiseLogic] Fehler beim Laden:', error);
            showToast('Fehler beim Laden der Daten: ' + error.message, 'error');
            updateStatus('Fehler beim Laden');

            // Fallback: Demo-Daten
            loadDemoData();
        } finally {
            showLoading(false);
        }
    }

    /**
     * Load demo data as fallback
     */
    function loadDemoData() {
        state.kundenpreise = [
            { id: 1, kun_id: 1, firma: 'Demo GmbH', aktiv: true, sicherheit: 25.00, leitung: 35.00, nacht: 25, sonntag: 50, feiertag: 100, fahrt: 0.30, sonstiges: 0 },
            { id: 2, kun_id: 2, firma: 'Test AG', aktiv: true, sicherheit: 28.00, leitung: 38.00, nacht: 25, sonntag: 50, feiertag: 100, fahrt: 0.35, sonstiges: 5 }
        ];
        filterTable();
        updateRecordCount();
        showToast('Demo-Daten geladen (API nicht erreichbar)', 'warning');
    }

    /**
     * Filter table based on search input and aktiv checkbox
     */
    function filterTable() {
        const searchTerm = (elements.filterFirma?.value || '').toLowerCase().trim();
        const onlyAktiv = elements.filterAktiv?.checked !== false;

        state.filteredData = state.kundenpreise.filter(item => {
            const matchesFirma = !searchTerm ||
                (item.firma || '').toLowerCase().includes(searchTerm);
            const matchesAktiv = !onlyAktiv || item.aktiv;
            return matchesFirma && matchesAktiv;
        });

        renderTable();
        updateRecordCount();
    }

    /**
     * Render the price table
     */
    function renderTable() {
        if (!elements.priceTableBody) return;

        if (state.filteredData.length === 0) {
            elements.priceTableBody.innerHTML = `
                <tr>
                    <td colspan="9" style="text-align: center; padding: 20px; color: #666;">
                        Keine Daten gefunden
                    </td>
                </tr>
            `;
            return;
        }

        // Verwende kun_id aus den Daten (Standard-Feldname für Kunden-ID)
        elements.priceTableBody.innerHTML = state.filteredData.map((item, index) => {
            const kunId = item.kun_id || item.kun_ID || item.id;
            return `
            <tr data-id="${item.id}" data-kun-id="${kunId}" class="${state.modifiedRows.has(item.id) ? 'modified' : ''}">
                <td class="col-firma">
                    <input type="text" value="${escapeHtml(item.firma || '')}"
                           data-field="firma" readonly
                           style="font-weight: bold;">
                </td>
                <td class="col-price" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'sicherheit')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.sicherheit)}"
                           data-field="sicherheit" step="0.01" min="0"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-price" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'leitung')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.leitung)}"
                           data-field="leitung" step="0.01" min="0"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-percent" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'nacht')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.nacht)}"
                           data-field="nacht" step="1" min="0" max="100"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-percent" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'sonntag')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.sonntag)}"
                           data-field="sonntag" step="1" min="0" max="200"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-percent" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'feiertag')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.feiertag)}"
                           data-field="feiertag" step="1" min="0" max="200"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-price" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'fahrt')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.fahrt)}"
                           data-field="fahrt" step="0.01" min="0"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-price" ondblclick="KundenpreiseLogic.handlePriceDblClick(event, ${kunId}, 'sonstiges')" title="Doppelklick: Kundenstamm öffnen">
                    <input type="number" value="${formatNumber(item.sonstiges)}"
                           data-field="sonstiges" step="0.01" min="0"
                           onchange="KundenpreiseLogic.markModified(${item.id})">
                </td>
                <td class="col-action">
                    <button class="btn-save-row ${!state.modifiedRows.has(item.id) ? 'saved' : ''}"
                            onclick="KundenpreiseLogic.saveRow(${item.id})"
                            ${!state.modifiedRows.has(item.id) ? 'disabled' : ''}>
                        Speichern
                    </button>
                </td>
            </tr>
        `}).join('');
    }

    /**
     * Mark a row as modified
     */
    function markModified(id) {
        state.modifiedRows.add(id);

        const row = elements.priceTableBody?.querySelector(`tr[data-id="${id}"]`);
        if (row) {
            row.classList.add('modified');
            const btn = row.querySelector('.btn-save-row');
            if (btn) {
                btn.classList.remove('saved');
                btn.disabled = false;
            }
        }

        updateStatus(`${state.modifiedRows.size} Änderung(en) nicht gespeichert`);
    }

    /**
     * Save a single row
     */
    async function saveRow(id) {
        const row = elements.priceTableBody?.querySelector(`tr[data-id="${id}"]`);
        if (!row) return;

        // Collect values from inputs
        const data = { id };
        row.querySelectorAll('input[data-field]').forEach(input => {
            const field = input.dataset.field;
            data[field] = input.type === 'number' ? parseFloat(input.value) || 0 : input.value;
        });

        try {
            const response = await fetch(`${API_BASE}/kundenpreise/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            state.modifiedRows.delete(id);
            row.classList.remove('modified');

            const btn = row.querySelector('.btn-save-row');
            if (btn) {
                btn.classList.add('saved');
                btn.disabled = true;
            }

            showToast('Gespeichert', 'success');
            updateStatus(state.modifiedRows.size > 0
                ? `${state.modifiedRows.size} Änderung(en) nicht gespeichert`
                : 'Bereit');

        } catch (error) {
            console.error('[KundenpreiseLogic] Fehler beim Speichern:', error);
            showToast('Fehler beim Speichern: ' + error.message, 'error');
        }
    }

    /**
     * Save all modified rows
     */
    async function saveAll() {
        if (state.modifiedRows.size === 0) {
            showToast('Keine Änderungen zum Speichern', 'info');
            return;
        }

        showLoading(true);
        updateStatus('Speichere alle Änderungen...');

        let successCount = 0;
        let errorCount = 0;

        for (const id of state.modifiedRows) {
            try {
                await saveRow(id);
                successCount++;
            } catch (error) {
                errorCount++;
            }
        }

        showLoading(false);

        if (errorCount === 0) {
            showToast(`${successCount} Datensätze gespeichert`, 'success');
        } else {
            showToast(`${successCount} gespeichert, ${errorCount} Fehler`, 'warning');
        }

        updateStatus('Bereit');
    }

    /**
     * Export data to Excel (CSV)
     */
    function exportToExcel() {
        if (state.filteredData.length === 0) {
            showToast('Keine Daten zum Exportieren', 'warning');
            return;
        }

        // CSV Header
        const headers = [
            'Firma',
            'Sicherheitspersonal (€)',
            'Leitungspersonal (€)',
            'Nachtzuschlag (%)',
            'Sonntagszuschlag (%)',
            'Feiertagszuschlag (%)',
            'Fahrtkosten (€)',
            'Sonstiges (€)'
        ];

        // CSV Rows
        const rows = state.filteredData.map(item => [
            item.firma || '',
            formatNumber(item.sicherheit),
            formatNumber(item.leitung),
            formatNumber(item.nacht),
            formatNumber(item.sonntag),
            formatNumber(item.feiertag),
            formatNumber(item.fahrt),
            formatNumber(item.sonstiges)
        ]);

        // Build CSV content
        const csvContent = [
            headers.join(';'),
            ...rows.map(row => row.map(cell => `"${cell}"`).join(';'))
        ].join('\r\n');

        // Download
        const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `Kundenpreise_${formatDate(new Date())}.csv`;
        link.click();
        URL.revokeObjectURL(link.href);

        showToast('Export erfolgreich', 'success');
    }

    // === Helper Functions ===

    function showLoading(show) {
        state.isLoading = show;
        if (elements.loadingOverlay) {
            elements.loadingOverlay.classList.toggle('active', show);
        }
    }

    function showToast(message, type = 'info') {
        // Try global Toast system first
        if (typeof Toast !== 'undefined' && Toast.show) {
            Toast[type] ? Toast[type](message) : Toast.show(message, type);
            return;
        }

        // Fallback to local toast
        if (!elements.toastContainer) return;

        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        elements.toastContainer.appendChild(toast);

        setTimeout(() => toast.remove(), 3000);
    }

    function updateStatus(text) {
        if (elements.statusText) {
            elements.statusText.textContent = text;
        }
    }

    function updateRecordCount() {
        if (elements.recordCount) {
            elements.recordCount.textContent = `Datensätze: ${state.filteredData.length} / ${state.kundenpreise.length}`;
        }
    }

    function updateLastUpdate() {
        if (elements.lastUpdate) {
            elements.lastUpdate.textContent = `Letzte Aktualisierung: ${formatTime(new Date())}`;
        }
    }

    function formatNumber(value) {
        if (value === null || value === undefined) return '0';
        return parseFloat(value).toFixed(2).replace('.', ',');
    }

    function formatDate(date) {
        return date.toISOString().split('T')[0];
    }

    function formatTime(date) {
        return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function debounce(func, wait) {
        let timeout;
        return function(...args) {
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(this, args), wait);
        };
    }

    /**
     * Öffnet den Kundenstamm mit der entsprechenden Preisart markiert
     * Entspricht VBA: open_KDStamm(PreisArt_ID)
     * @param {number} kunId - Kunden-ID
     * @param {number} preisArtId - Preisart-ID (1=Sicherheit, 3=Leitung, 4=Fahrt, 5=Sonstiges, 11=Nacht, 12=Sonntag, 13=Feiertag)
     */
    function openKDStamm(kunId, preisArtId) {
        if (!kunId) {
            showToast('Keine Kunden-ID vorhanden', 'warning');
            return;
        }

        console.log(`[KundenpreiseLogic] openKDStamm: kun_ID=${kunId}, PreisArt_ID=${preisArtId}`);

        // URL zum Kundenstamm mit Parametern für Kunde und Preisart
        const url = `frm_KD_Kundenstamm.html?kun_id=${kunId}&tab=preise&preisart_id=${preisArtId}`;

        // Prüfe ob in Shell (iframe) oder standalone
        if (window.parent && window.parent !== window && typeof window.parent.shellNavigate === 'function') {
            // In Shell: Navigation über Shell-Funktion
            window.parent.shellNavigate(url);
        } else if (window.chrome && window.chrome.webview) {
            // WebView2: Nachricht an Access senden
            window.chrome.webview.postMessage({
                action: 'openForm',
                form: 'frm_KD_Kundenstamm',
                kun_id: kunId,
                preisart_id: preisArtId
            });
        } else {
            // Browser: Neues Fenster/Tab öffnen
            window.open(url, '_blank');
        }

        showToast(`Öffne Kundenstamm für Preisart ${preisArtId}`, 'info');
    }

    /**
     * Handler für DblClick auf Preisfelder
     * Wird von den Tabellenzellen aufgerufen
     * @param {Event} event - Das DblClick-Event
     * @param {number} kunId - Kunden-ID
     * @param {string} fieldType - Feldtyp (sicherheit, leitung, nacht, sonntag, feiertag, fahrt, sonstiges)
     */
    function handlePriceDblClick(event, kunId, fieldType) {
        // Mapping Feldtyp -> PreisArt_ID (wie in Access VBA)
        const preisArtMapping = {
            'sicherheit': 1,   // Sicherheitspersonal
            'leitung': 3,      // Leitungspersonal
            'fahrt': 4,        // Fahrtkosten
            'sonstiges': 5,    // Sonstiges
            'nacht': 11,       // Nachtzuschlag
            'sonntag': 12,     // Sonntagszuschlag
            'feiertag': 13     // Feiertagszuschlag
        };

        const preisArtId = preisArtMapping[fieldType];
        if (!preisArtId) {
            console.warn(`[KundenpreiseLogic] Unbekannter Feldtyp: ${fieldType}`);
            return;
        }

        openKDStamm(kunId, preisArtId);
    }

    // Public API
    return {
        init,
        refreshData,
        saveAll,
        saveRow,
        exportToExcel,
        filterTable,
        markModified,
        openKDStamm,
        handlePriceDblClick
    };

})();

// Export for global access
window.KundenpreiseLogic = KundenpreiseLogic;
