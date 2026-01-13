/**
 * Logic für frm_MA_Tabelle - Tabellarische Mitarbeiter-Ansicht
 *
 * Features:
 * - Lädt alle MA-Felder via API (?view=table)
 * - Access-Standard Sortierung: IstAktiv DESC, Nachname, IstSubunternehmer DESC, HatSachkunde DESC, Hat_keine_34a DESC
 * - Filter nach Aktiv-Status, Anstellungsart, Suche
 * - Spalten-Sortierung per Klick
 * - CSV-Export
 */

const API_BASE = 'http://localhost:5000/api';

// State
let allMitarbeiter = [];
let originalMitarbeiter = []; // Backup für Cancel
let currentSort = {
    field: null,
    direction: null
};
let editMode = false;
let changedRows = new Map(); // MA_ID -> { fieldName: newValue }
let editableFields = [
    'Nachname', 'Vorname', 'Geschlecht', 'Geb_Ort', 'Staatsang',
    'Strasse', 'Nr', 'PLZ', 'Ort',
    'Tel_Mobil', 'Tel_Festnetz', 'Email',
    'Bankname', 'Kontoinhaber', 'IBAN', 'BIC',
    'Kostenstelle', 'Bemerkungen'
]; // Read-only: ID, LEXWare_ID, Geb_Dat, Eintrittsdatum, Austrittsdatum, Anstellungsart_ID, IstAktiv, IstSubunternehmer, HatSachkunde, Hat_keine_34a, Auszahlungsart

// Init
document.addEventListener('DOMContentLoaded', () => {
    console.log('[frm_MA_Tabelle] Init');

    // Event Listeners
    document.getElementById('chkAktiv').addEventListener('change', loadData);
    document.getElementById('txtSearch').addEventListener('input', debounce(loadData, 500));
    document.getElementById('selAnstellung').addEventListener('change', loadData);

    // Spalten-Sortierung
    document.querySelectorAll('thead th.sortable').forEach(th => {
        th.addEventListener('click', () => {
            const field = th.dataset.field;
            sortByField(field);
        });
    });

    // Initial load
    loadData();
});

/**
 * Lädt Mitarbeiter-Daten von API
 */
async function loadData() {
    const loading = document.getElementById('loading');
    const tbody = document.getElementById('tbody');
    const statusLeft = document.getElementById('statusLeft');
    const statusRight = document.getElementById('statusRight');

    loading.style.display = 'block';
    statusLeft.textContent = 'Lade Daten...';

    try {
        // Parameter
        const aktiv = document.getElementById('chkAktiv').checked;
        const search = document.getElementById('txtSearch').value.trim();
        const anstellung = document.getElementById('selAnstellung').value;

        // API-Aufruf mit view=table für alle Felder
        const params = new URLSearchParams({
            view: 'table',
            aktiv: aktiv,
            limit: 1000,
            filter_anstellung: 'false' // Kein Default-Filter, nutze selAnstellung
        });

        if (search) {
            params.set('search', search);
        }

        if (anstellung) {
            params.set('anstellung', anstellung);
        }

        const response = await fetch(`${API_BASE}/mitarbeiter?${params}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.error || 'API-Fehler');
        }

        allMitarbeiter = data.data || [];
        originalMitarbeiter = JSON.parse(JSON.stringify(allMitarbeiter)); // Deep copy

        // Rendere Tabelle
        renderTable(allMitarbeiter);

        statusLeft.textContent = 'Bereit';
        statusRight.textContent = `${allMitarbeiter.length} Datensätze`;

    } catch (error) {
        console.error('[frm_MA_Tabelle] Fehler beim Laden:', error);
        statusLeft.textContent = `Fehler: ${error.message}`;
        tbody.innerHTML = `<tr><td colspan="29" style="text-align:center; color:red; padding:20px;">Fehler beim Laden der Daten: ${error.message}</td></tr>`;
    } finally {
        loading.style.display = 'none';
    }
}

/**
 * Rendert Tabelle mit Mitarbeiter-Daten
 */
function renderTable(mitarbeiter) {
    const tbody = document.getElementById('tbody');
    tbody.innerHTML = '';

    if (mitarbeiter.length === 0) {
        tbody.innerHTML = '<tr><td colspan="29" style="text-align:center; padding:20px;">Keine Datensätze gefunden</td></tr>';
        return;
    }

    mitarbeiter.forEach(ma => {
        const tr = document.createElement('tr');
        tr.dataset.maId = ma.ID;

        // Helper: Erstellt TD mit optionalem contenteditable
        const createTd = (value, fieldName) => {
            const td = document.createElement('td');
            const displayValue = value != null ? value : '';
            td.textContent = displayValue;

            if (editMode && editableFields.includes(fieldName)) {
                td.classList.add('editable');
                td.contentEditable = 'true';
                td.dataset.field = fieldName;
                td.dataset.original = displayValue;

                // Track changes
                td.addEventListener('blur', function() {
                    const newValue = this.textContent.trim();
                    const originalValue = this.dataset.original;

                    if (newValue !== originalValue) {
                        trackChange(ma.ID, fieldName, newValue);
                        this.classList.add('changed');
                    } else {
                        untrackChange(ma.ID, fieldName);
                        this.classList.remove('changed');
                    }
                });
            }

            return td;
        };

        // ID (read-only)
        tr.appendChild(createTd(ma.ID, 'ID'));

        // LEXWare_ID (read-only)
        tr.appendChild(createTd(ma.LEXWare_ID, 'LEXWare_ID'));

        // Editable Text Fields
        tr.appendChild(createTd(ma.Nachname, 'Nachname'));
        tr.appendChild(createTd(ma.Vorname, 'Vorname'));
        tr.appendChild(createTd(ma.Geschlecht, 'Geschlecht'));

        // Geb_Dat (read-only)
        tr.appendChild(createTd(formatDate(ma.Geb_Dat), 'Geb_Dat'));

        // Editable
        tr.appendChild(createTd(ma.Geb_Ort, 'Geb_Ort'));
        tr.appendChild(createTd(ma.Staatsang, 'Staatsang'));
        tr.appendChild(createTd(ma.Strasse, 'Strasse'));
        tr.appendChild(createTd(ma.Nr, 'Nr'));
        tr.appendChild(createTd(ma.PLZ, 'PLZ'));
        tr.appendChild(createTd(ma.Ort, 'Ort'));
        tr.appendChild(createTd(ma.Tel_Mobil, 'Tel_Mobil'));
        tr.appendChild(createTd(ma.Tel_Festnetz, 'Tel_Festnetz'));
        tr.appendChild(createTd(ma.Email, 'Email'));

        // Dates (read-only)
        tr.appendChild(createTd(formatDate(ma.Eintrittsdatum), 'Eintrittsdatum'));
        tr.appendChild(createTd(formatDate(ma.Austrittsdatum), 'Austrittsdatum'));

        // Auszahlungsart (read-only)
        tr.appendChild(createTd(ma.Auszahlungsart, 'Auszahlungsart'));

        // Editable Bank Fields
        tr.appendChild(createTd(ma.Bankname, 'Bankname'));
        tr.appendChild(createTd(ma.Kontoinhaber, 'Kontoinhaber'));
        tr.appendChild(createTd(ma.IBAN, 'IBAN'));
        tr.appendChild(createTd(ma.BIC, 'BIC'));

        // Anstellungsart_ID (read-only)
        tr.appendChild(createTd(ma.Anstellungsart_ID, 'Anstellungsart_ID'));

        // Checkboxes (read-only)
        const tdAktiv = document.createElement('td');
        tdAktiv.className = 'checkbox-cell';
        tdAktiv.innerHTML = `<input type="checkbox" ${ma.IstAktiv ? 'checked' : ''} disabled>`;
        tr.appendChild(tdAktiv);

        const tdSubunt = document.createElement('td');
        tdSubunt.className = 'checkbox-cell';
        tdSubunt.innerHTML = `<input type="checkbox" ${ma.IstSubunternehmer ? 'checked' : ''} disabled>`;
        tr.appendChild(tdSubunt);

        const tdSachkunde = document.createElement('td');
        tdSachkunde.className = 'checkbox-cell';
        tdSachkunde.innerHTML = `<input type="checkbox" ${ma.HatSachkunde ? 'checked' : ''} disabled>`;
        tr.appendChild(tdSachkunde);

        const tdKeine34a = document.createElement('td');
        tdKeine34a.className = 'checkbox-cell';
        tdKeine34a.innerHTML = `<input type="checkbox" ${ma.Hat_keine_34a ? 'checked' : ''} disabled>`;
        tr.appendChild(tdKeine34a);

        // Editable
        tr.appendChild(createTd(ma.Kostenstelle, 'Kostenstelle'));
        tr.appendChild(createTd(ma.Bemerkungen, 'Bemerkungen'));

        tbody.appendChild(tr);
    });
}

/**
 * Sortiert nach Feld
 */
function sortByField(field) {
    // Toggle direction
    if (currentSort.field === field) {
        if (currentSort.direction === 'asc') {
            currentSort.direction = 'desc';
        } else if (currentSort.direction === 'desc') {
            // Reset to default Access sort
            currentSort.field = null;
            currentSort.direction = null;
        } else {
            currentSort.direction = 'asc';
        }
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }

    // Update header classes
    document.querySelectorAll('thead th.sortable').forEach(th => {
        th.classList.remove('sorted-asc', 'sorted-desc');
        if (th.dataset.field === field) {
            if (currentSort.direction === 'asc') {
                th.classList.add('sorted-asc');
            } else if (currentSort.direction === 'desc') {
                th.classList.add('sorted-desc');
            }
        }
    });

    // Sort data
    let sorted = [...allMitarbeiter];

    if (currentSort.field && currentSort.direction) {
        // Custom sort
        sorted.sort((a, b) => {
            let valA = a[currentSort.field];
            let valB = b[currentSort.field];

            // Null handling
            if (valA == null) valA = '';
            if (valB == null) valB = '';

            // Boolean handling
            if (typeof valA === 'boolean') valA = valA ? 1 : 0;
            if (typeof valB === 'boolean') valB = valB ? 1 : 0;

            // Number handling
            if (typeof valA === 'number' && typeof valB === 'number') {
                return currentSort.direction === 'asc' ? valA - valB : valB - valA;
            }

            // String comparison
            const strA = String(valA).toLowerCase();
            const strB = String(valB).toLowerCase();

            if (strA < strB) return currentSort.direction === 'asc' ? -1 : 1;
            if (strA > strB) return currentSort.direction === 'asc' ? 1 : -1;
            return 0;
        });
    } else {
        // Default Access sort: IstAktiv DESC, Nachname, IstSubunternehmer DESC, HatSachkunde DESC, Hat_keine_34a DESC
        sorted.sort((a, b) => {
            // 1. IstAktiv DESC (aktive zuerst)
            if (a.IstAktiv !== b.IstAktiv) {
                return b.IstAktiv ? 1 : -1;
            }

            // 2. Nachname ASC
            const nachA = (a.Nachname || '').toLowerCase();
            const nachB = (b.Nachname || '').toLowerCase();
            if (nachA !== nachB) {
                return nachA < nachB ? -1 : 1;
            }

            // 3. IstSubunternehmer DESC
            if (a.IstSubunternehmer !== b.IstSubunternehmer) {
                return b.IstSubunternehmer ? 1 : -1;
            }

            // 4. HatSachkunde DESC
            if (a.HatSachkunde !== b.HatSachkunde) {
                return b.HatSachkunde ? 1 : -1;
            }

            // 5. Hat_keine_34a DESC
            if (a.Hat_keine_34a !== b.Hat_keine_34a) {
                return b.Hat_keine_34a ? 1 : -1;
            }

            return 0;
        });
    }

    renderTable(sorted);
}

/**
 * Exportiert zu CSV
 */
function exportToCSV() {
    if (allMitarbeiter.length === 0) {
        alert('Keine Daten zum Exportieren');
        return;
    }

    // CSV Header
    const headers = [
        'ID', 'LEXWare_ID', 'Nachname', 'Vorname', 'Geschlecht',
        'Geb_Dat', 'Geb_Ort', 'Staatsang',
        'Strasse', 'Nr', 'PLZ', 'Ort',
        'Tel_Mobil', 'Tel_Festnetz', 'Email',
        'Eintrittsdatum', 'Austrittsdatum',
        'Auszahlungsart', 'Bankname', 'Kontoinhaber', 'IBAN', 'BIC',
        'Anstellungsart_ID', 'IstAktiv', 'IstSubunternehmer',
        'HatSachkunde', 'Hat_keine_34a',
        'Kostenstelle', 'Bemerkungen'
    ];

    // CSV Rows
    const rows = allMitarbeiter.map(ma => headers.map(field => {
        const value = ma[field];
        if (value == null) return '';
        if (typeof value === 'boolean') return value ? '1' : '0';
        // Escape quotes and wrap in quotes if contains comma
        const str = String(value);
        if (str.includes(',') || str.includes('"') || str.includes('\n')) {
            return `"${str.replace(/"/g, '""')}"`;
        }
        return str;
    }).join(','));

    // Combine
    const csv = [headers.join(','), ...rows].join('\n');

    // Download
    const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' }); // BOM for Excel
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `Mitarbeiter_Tabelle_${new Date().toISOString().slice(0,10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
}

/**
 * Formatiert Datum
 */
function formatDate(dateStr) {
    if (!dateStr) return '';
    try {
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) return dateStr;
        return date.toLocaleDateString('de-DE');
    } catch (e) {
        return dateStr;
    }
}

/**
 * Debounce Helper
 */
function debounce(func, wait) {
    let timeout;
    return function(...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
    };
}

/**
 * Toggle Edit Mode
 */
function toggleEditMode() {
    editMode = !editMode;

    const btnEdit = document.getElementById('btnEdit');
    const btnSave = document.getElementById('btnSave');
    const btnCancel = document.getElementById('btnCancel');
    const editModeInfo = document.getElementById('editModeInfo');

    if (editMode) {
        btnEdit.style.display = 'none';
        btnSave.style.display = 'inline-block';
        btnCancel.style.display = 'inline-block';
        editModeInfo.classList.add('active');
    } else {
        btnEdit.style.display = 'inline-block';
        btnSave.style.display = 'none';
        btnCancel.style.display = 'none';
        editModeInfo.classList.remove('active');
    }

    // Re-render table with contenteditable
    renderTable(allMitarbeiter);
    updateChangesCount();
}

/**
 * Track Changes
 */
function trackChange(maId, fieldName, newValue) {
    if (!changedRows.has(maId)) {
        changedRows.set(maId, {});
    }
    changedRows.get(maId)[fieldName] = newValue;
    updateChangesCount();
}

/**
 * Untrack Changes
 */
function untrackChange(maId, fieldName) {
    if (changedRows.has(maId)) {
        delete changedRows.get(maId)[fieldName];
        if (Object.keys(changedRows.get(maId)).length === 0) {
            changedRows.delete(maId);
        }
    }
    updateChangesCount();
}

/**
 * Update Changes Counter
 */
function updateChangesCount() {
    const count = changedRows.size;
    document.getElementById('changesCount').textContent = `${count} Änderung${count !== 1 ? 'en' : ''}`;
}

/**
 * Save Changes
 */
async function saveChanges() {
    if (changedRows.size === 0) {
        alert('Keine Änderungen vorhanden');
        return;
    }

    const statusLeft = document.getElementById('statusLeft');
    const loading = document.getElementById('loading');

    if (!confirm(`${changedRows.size} Mitarbeiter speichern?`)) {
        return;
    }

    loading.style.display = 'block';
    statusLeft.textContent = 'Speichere Änderungen...';

    let successCount = 0;
    let errorCount = 0;
    const errors = [];

    for (const [maId, changes] of changedRows.entries()) {
        try {
            const response = await fetch(`${API_BASE}/mitarbeiter/${maId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(changes)
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.error || 'Unbekannter Fehler');
            }

            successCount++;

            // Update allMitarbeiter with saved values
            const ma = allMitarbeiter.find(m => m.ID == maId);
            if (ma) {
                Object.assign(ma, changes);
            }

        } catch (error) {
            console.error(`[saveChanges] Fehler für MA ${maId}:`, error);
            errorCount++;
            errors.push(`MA ${maId}: ${error.message}`);

            // Mark row as error
            const row = document.querySelector(`tr[data-ma-id="${maId}"]`);
            if (row) {
                row.querySelectorAll('.changed').forEach(td => {
                    td.classList.remove('changed');
                    td.classList.add('error');
                });
            }
        }
    }

    loading.style.display = 'none';

    if (errorCount === 0) {
        // All saved successfully
        statusLeft.textContent = `${successCount} Mitarbeiter gespeichert`;
        changedRows.clear();
        originalMitarbeiter = JSON.parse(JSON.stringify(allMitarbeiter)); // Update backup
        updateChangesCount();

        // Exit edit mode
        editMode = false;
        toggleEditMode();
    } else {
        // Some errors
        statusLeft.textContent = `${successCount} gespeichert, ${errorCount} Fehler`;
        alert(`Fehler beim Speichern:\n\n${errors.join('\n')}\n\nFehlerhafte Zeilen sind rot markiert.`);

        // Remove successfully saved from changedRows
        for (const [maId] of changedRows.entries()) {
            if (!errors.some(e => e.startsWith(`MA ${maId}`))) {
                changedRows.delete(maId);
            }
        }
        updateChangesCount();
    }
}

/**
 * Cancel Edit Mode
 */
function cancelEdit() {
    if (changedRows.size > 0) {
        if (!confirm(`${changedRows.size} ungespeicherte Änderungen verwerfen?`)) {
            return;
        }
    }

    // Restore original data
    allMitarbeiter = JSON.parse(JSON.stringify(originalMitarbeiter));
    changedRows.clear();

    // Exit edit mode
    editMode = false;
    toggleEditMode();
}

// Expose für HTML onclick
window.loadData = loadData;
window.exportToCSV = exportToCSV;
window.toggleEditMode = toggleEditMode;
window.saveChanges = saveChanges;
window.cancelEdit = cancelEdit;
