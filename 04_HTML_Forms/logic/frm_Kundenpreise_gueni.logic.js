/**
 * frm_Kundenpreise_gueni.logic.js
 * Business Logic für Kundenpreise-Verwaltung
 *
 * Features:
 * - Laden aller Kundenpreise aus API
 * - Inline-Editing mit Validierung
 * - Speichern einzelner Zeilen oder aller Änderungen
 * - Filter nach Firma und Aktiv-Status
 * - Excel Export
 */

const KundenpreiseLogic = (() => {
    'use strict';

    // ========== CONFIGURATION ==========
    const API_BASE = 'http://localhost:5000/api';
    const DEBOUNCE_DELAY = 300;

    // ========== STATE ==========
    const state = {
        kundenpreise: [],           // Alle geladenen Kundenpreise
        filteredData: [],           // Gefilterte Daten
        changedRows: new Set(),     // Set von kun_Id die geändert wurden
        isLoading: false
    };

    // ========== INITIALIZATION ==========
    async function init() {
        console.log('[Kundenpreise] Initialisiere...');
        await loadKundenpreise();
    }

    // ========== API CALLS ==========
    async function apiCall(endpoint, method = 'GET', data = null) {
        const options = {
            method: method,
            headers: { 'Content-Type': 'application/json' }
        };

        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }

        try {
            const response = await fetch(`${API_BASE}${endpoint}`, options);
            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error || `HTTP ${response.status}`);
            }

            return result;
        } catch (error) {
            console.error('[Kundenpreise] API-Fehler:', error);
            showToast(`API-Fehler: ${error.message}`, 'error');
            throw error;
        }
    }

    async function loadKundenpreise() {
        if (state.isLoading) return;

        setLoading(true);
        setStatus('Lade Kundenpreise...');

        try {
            // API-Endpunkt: /api/kundenpreise (GET)
            const result = await apiCall('/kundenpreise');

            state.kundenpreise = result.data || [];
            state.changedRows.clear();

            console.log('[Kundenpreise] Geladen:', state.kundenpreise.length);

            filterTable();
            updateRecordCount();
            setStatus('Bereit');
            updateLastUpdate();

        } catch (error) {
            console.error('[Kundenpreise] Laden fehlgeschlagen:', error);
            setStatus('Fehler beim Laden');
        } finally {
            setLoading(false);
        }
    }

    // ========== RENDERING ==========
    function filterTable() {
        const firmaFilter = document.getElementById('filterFirma').value.toLowerCase();
        const aktivFilter = document.getElementById('filterAktiv').checked;

        state.filteredData = state.kundenpreise.filter(kp => {
            // Filter: Firma
            if (firmaFilter && !kp.kun_Firma?.toLowerCase().includes(firmaFilter)) {
                return false;
            }

            // Filter: Nur Aktive
            if (aktivFilter && !kp.kun_IstAktiv) {
                return false;
            }

            return true;
        });

        renderTable();
        updateRecordCount();
    }

    function renderTable() {
        const tbody = document.getElementById('priceTableBody');
        tbody.innerHTML = '';

        if (state.filteredData.length === 0) {
            const tr = document.createElement('tr');
            tr.innerHTML = `<td colspan="9" style="text-align: center; padding: 20px; color: #666;">
                Keine Kundenpreise gefunden
            </td>`;
            tbody.appendChild(tr);
            return;
        }

        state.filteredData.forEach((kp) => {
            const tr = createTableRow(kp);
            tbody.appendChild(tr);
        });
    }

    function createTableRow(kp) {
        const tr = document.createElement('tr');
        tr.dataset.kunId = kp.kun_Id;

        const isChanged = state.changedRows.has(kp.kun_Id);

        tr.innerHTML = `
            <td class="col-firma">
                <input type="text"
                       class="field-firma"
                       value="${escapeHtml(kp.kun_Firma || '')}"
                       readonly
                       title="${escapeHtml(kp.kun_Firma || '')}">
            </td>
            <td class="col-price">
                <input type="number"
                       class="field-sicherheitspersonal"
                       value="${kp.Sicherheitspersonal || ''}"
                       step="0.01"
                       min="0"
                       data-field="Sicherheitspersonal">
            </td>
            <td class="col-price">
                <input type="number"
                       class="field-leitungspersonal"
                       value="${kp.Leitungspersonal || ''}"
                       step="0.01"
                       min="0"
                       data-field="Leitungspersonal">
            </td>
            <td class="col-percent">
                <input type="number"
                       class="field-nachtzuschlag"
                       value="${kp.Nachtzuschlag || ''}"
                       step="0.1"
                       min="0"
                       max="100"
                       data-field="Nachtzuschlag">
            </td>
            <td class="col-percent">
                <input type="number"
                       class="field-sonntagszuschlag"
                       value="${kp.Sonntagszuschlag || ''}"
                       step="0.1"
                       min="0"
                       max="100"
                       data-field="Sonntagszuschlag">
            </td>
            <td class="col-percent">
                <input type="number"
                       class="field-feiertagszuschlag"
                       value="${kp.Feiertagszuschlag || ''}"
                       step="0.1"
                       min="0"
                       max="100"
                       data-field="Feiertagszuschlag">
            </td>
            <td class="col-price">
                <input type="number"
                       class="field-fahrtkosten"
                       value="${kp.Fahrtkosten || ''}"
                       step="0.01"
                       min="0"
                       data-field="Fahrtkosten">
            </td>
            <td class="col-price">
                <input type="number"
                       class="field-sonstiges"
                       value="${kp.Sonstiges || ''}"
                       step="0.01"
                       min="0"
                       data-field="Sonstiges">
            </td>
            <td class="col-action">
                <button class="btn-save-row ${isChanged ? '' : 'saved'}"
                        onclick="KundenpreiseLogic.saveRow(${kp.kun_Id})"
                        ${isChanged ? '' : 'disabled'}>
                    ${isChanged ? '💾 Speichern' : '✓ Gespeichert'}
                </button>
            </td>
        `;

        // Event Listener für Änderungen
        const inputs = tr.querySelectorAll('input[data-field]');
        inputs.forEach(input => {
            input.addEventListener('input', () => markRowChanged(kp.kun_Id));
            input.addEventListener('change', () => markRowChanged(kp.kun_Id));
        });

        return tr;
    }

    // ========== CHANGE TRACKING ==========
    function markRowChanged(kunId) {
        state.changedRows.add(kunId);
        updateSaveButton(kunId);
    }

    function updateSaveButton(kunId) {
        const tr = document.querySelector(`tr[data-kun-id="${kunId}"]`);
        if (!tr) return;

        const btn = tr.querySelector('.btn-save-row');
        if (!btn) return;

        btn.classList.remove('saved');
        btn.disabled = false;
        btn.textContent = '💾 Speichern';
    }

    function markRowSaved(kunId) {
        state.changedRows.delete(kunId);

        const tr = document.querySelector(`tr[data-kun-id="${kunId}"]`);
        if (!tr) return;

        const btn = tr.querySelector('.btn-save-row');
        if (!btn) return;

        btn.classList.add('saved');
        btn.disabled = true;
        btn.textContent = '✓ Gespeichert';
    }

    // ========== SAVE OPERATIONS ==========
    async function saveRow(kunId) {
        const tr = document.querySelector(`tr[data-kun-id="${kunId}"]`);
        if (!tr) {
            showToast('Zeile nicht gefunden', 'error');
            return;
        }

        const data = extractRowData(tr);
        if (!data) return;

        setLoading(true);
        setStatus(`Speichere Kundenpreis ${kunId}...`);

        try {
            // API-Endpunkt: PUT /api/kundenpreise/:id
            await apiCall(`/kundenpreise/${kunId}`, 'PUT', data);

            markRowSaved(kunId);
            showToast(`Kundenpreis für "${data.kun_Firma}" gespeichert`, 'success');
            setStatus('Gespeichert');

            // Daten im State aktualisieren
            const index = state.kundenpreise.findIndex(kp => kp.kun_Id === kunId);
            if (index >= 0) {
                state.kundenpreise[index] = { ...state.kundenpreise[index], ...data };
            }

        } catch (error) {
            console.error('[Kundenpreise] Speichern fehlgeschlagen:', error);
            showToast(`Fehler beim Speichern: ${error.message}`, 'error');
            setStatus('Speichern fehlgeschlagen');
        } finally {
            setLoading(false);
        }
    }

    async function saveAll() {
        if (state.changedRows.size === 0) {
            showToast('Keine Änderungen vorhanden', 'info');
            return;
        }

        const count = state.changedRows.size;
        if (!confirm(`${count} geänderte Zeile(n) speichern?`)) {
            return;
        }

        setLoading(true);
        setStatus(`Speichere ${count} Zeile(n)...`);

        let successCount = 0;
        let errorCount = 0;

        // Kopie erstellen da Set während Iteration geändert wird
        const idsToSave = Array.from(state.changedRows);

        for (const kunId of idsToSave) {
            try {
                await saveRow(kunId);
                successCount++;
            } catch (error) {
                errorCount++;
                console.error(`[Kundenpreise] Fehler bei kun_Id ${kunId}:`, error);
            }
        }

        setLoading(false);

        if (errorCount === 0) {
            showToast(`Alle ${successCount} Zeilen erfolgreich gespeichert`, 'success');
            setStatus('Alle gespeichert');
        } else {
            showToast(`${successCount} gespeichert, ${errorCount} Fehler`, 'warning');
            setStatus(`${errorCount} Fehler beim Speichern`);
        }
    }

    function extractRowData(tr) {
        const kunId = parseInt(tr.dataset.kunId);
        const data = { kun_Id: kunId };

        const fields = [
            'Sicherheitspersonal',
            'Leitungspersonal',
            'Nachtzuschlag',
            'Sonntagszuschlag',
            'Feiertagszuschlag',
            'Fahrtkosten',
            'Sonstiges'
        ];

        fields.forEach(field => {
            const input = tr.querySelector(`[data-field="${field}"]`);
            if (input) {
                const value = input.value.trim();
                data[field] = value ? parseFloat(value) : null;
            }
        });

        // Firma für Toast-Meldung
        const firmaInput = tr.querySelector('.field-firma');
        if (firmaInput) {
            data.kun_Firma = firmaInput.value;
        }

        return data;
    }

    // ========== EXPORT ==========
    function exportToExcel() {
        if (state.filteredData.length === 0) {
            showToast('Keine Daten zum Exportieren', 'warning');
            return;
        }

        // CSV-Export (einfache Variante)
        let csv = 'Firma;Sicherheitspersonal;Leitungspersonal;Nachtzuschlag;Sonntagszuschlag;Feiertagszuschlag;Fahrtkosten;Sonstiges\n';

        state.filteredData.forEach(kp => {
            csv += `"${(kp.kun_Firma || '').replace(/"/g, '""')}";`;
            csv += `${kp.Sicherheitspersonal || ''};`;
            csv += `${kp.Leitungspersonal || ''};`;
            csv += `${kp.Nachtzuschlag || ''};`;
            csv += `${kp.Sonntagszuschlag || ''};`;
            csv += `${kp.Feiertagszuschlag || ''};`;
            csv += `${kp.Fahrtkosten || ''};`;
            csv += `${kp.Sonstiges || ''}\n`;
        });

        // Download
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `Kundenpreise_${formatDateForFile()}.csv`;
        link.click();

        showToast('Excel-Export erfolgreich', 'success');
    }

    // ========== HELPERS ==========
    function refreshData() {
        loadKundenpreise();
    }

    function setLoading(loading) {
        state.isLoading = loading;
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.classList.toggle('active', loading);
        }
    }

    function setStatus(text) {
        const statusEl = document.getElementById('statusText');
        if (statusEl) {
            statusEl.textContent = text;
        }
    }

    function updateRecordCount() {
        const countEl = document.getElementById('recordCount');
        if (countEl) {
            const total = state.kundenpreise.length;
            const filtered = state.filteredData.length;
            countEl.textContent = filtered === total
                ? `Datensätze: ${total}`
                : `Datensätze: ${filtered} / ${total}`;
        }
    }

    function updateLastUpdate() {
        const updateEl = document.getElementById('lastUpdate');
        if (updateEl) {
            const now = new Date();
            updateEl.textContent = `Letzte Aktualisierung: ${formatDateTime(now)}`;
        }
    }

    function showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        if (!container) return;

        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        container.appendChild(toast);

        setTimeout(() => toast.remove(), 3000);
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function formatDateTime(date) {
        if (!date) return '-';
        return new Date(date).toLocaleString('de-DE', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    function formatDateForFile() {
        const now = new Date();
        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');
        const h = String(now.getHours()).padStart(2, '0');
        const i = String(now.getMinutes()).padStart(2, '0');
        return `${y}${m}${d}_${h}${i}`;
    }

    // ========== PUBLIC API ==========
    return {
        init,
        refreshData,
        saveRow,
        saveAll,
        filterTable,
        exportToExcel
    };
})();
