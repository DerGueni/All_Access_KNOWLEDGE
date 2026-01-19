/**
 * frm_Kundenpreise.logic.js
 * Logik für Verrechnungssaetze-Formular
 */

import { Bridge } from '../js/webview2-bridge.js';

// State
let allData = [];
let filteredData = [];
let editedRows = new Map(); // kun_Id -> edited data
let currentSort = { field: 'kun_Firma', direction: 'asc' };

// DOM Elements
let tbody;
let txtSuche;
let chkNurAktive;
let lblStatus;
let lblAnzahl;
let lblRecordInfo;

/**
 * Initialisierung
 */
document.addEventListener('DOMContentLoaded', async () => {
    // DOM-Referenzen
    tbody = document.getElementById('tbody_Preise');
    txtSuche = document.getElementById('txtSuche');
    chkNurAktive = document.getElementById('chkNurAktive');
    lblStatus = document.getElementById('lblStatus');
    lblAnzahl = document.getElementById('lblAnzahl');
    lblRecordInfo = document.getElementById('lblRecordInfo');

    // Event Listeners
    document.getElementById('btnNeuerPreis').addEventListener('click', neuerEintrag);
    document.getElementById('btnSpeichern').addEventListener('click', speichern);
    document.getElementById('btnLoeschen').addEventListener('click', loeschen);
    txtSuche.addEventListener('input', applyFilter);
    chkNurAktive.addEventListener('change', applyFilter);

    // Sortierung bei Klick auf Spaltenköpfe
    document.querySelectorAll('.data-table th[data-field]').forEach(th => {
        th.addEventListener('click', () => {
            const field = th.dataset.field;
            if (currentSort.field === field) {
                currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
            } else {
                currentSort.field = field;
                currentSort.direction = 'asc';
            }
            sortAndRender();
        });
    });

    // Daten laden
    await loadData();
});

/**
 * Daten von API laden
 */
async function loadData() {
    try {
        setStatus('Lade Verrechnungssätze...');

        // API-Endpoint für Kundenpreise (CROSSTAB Query)
        const response = await Bridge.execute('getKundenpreise');

        if (response && Array.isArray(response)) {
            allData = response;
            applyFilter();
            setStatus('Daten geladen');
        } else {
            throw new Error('Ungültige Daten vom Server');
        }
    } catch (error) {
        console.error('Fehler beim Laden der Daten:', error);
        setStatus('Fehler beim Laden der Daten');

        // Fallback: Testdaten
        allData = generateTestData();
        applyFilter();
    }
}

/**
 * Filter anwenden
 */
function applyFilter() {
    const searchTerm = txtSuche.value.toLowerCase();
    const nurAktive = chkNurAktive.checked;

    filteredData = allData.filter(row => {
        // Nur aktive Kunden?
        if (nurAktive && row.kun_IstAktiv === false) {
            return false;
        }

        // Suchfilter
        if (searchTerm) {
            const firma = (row.kun_Firma || '').toLowerCase();
            if (!firma.includes(searchTerm)) {
                return false;
            }
        }

        return true;
    });

    sortAndRender();
}

/**
 * Sortieren und Rendern
 */
function sortAndRender() {
    // Sortieren
    filteredData.sort((a, b) => {
        const aVal = a[currentSort.field];
        const bVal = b[currentSort.field];

        if (aVal === null || aVal === undefined) return 1;
        if (bVal === null || bVal === undefined) return -1;

        let cmp = 0;
        if (typeof aVal === 'number' && typeof bVal === 'number') {
            cmp = aVal - bVal;
        } else {
            cmp = String(aVal).localeCompare(String(bVal), 'de');
        }

        return currentSort.direction === 'asc' ? cmp : -cmp;
    });

    renderTable();
    updateStats();
}

/**
 * Tabelle rendern
 */
function renderTable() {
    if (filteredData.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="9" class="empty-state">
                    <div class="empty-state-icon">📊</div>
                    <div class="empty-state-text">Keine Verrechnungssätze gefunden</div>
                </td>
            </tr>
        `;
        return;
    }

    const html = filteredData.map(row => createTableRow(row)).join('');
    tbody.innerHTML = html;

    // Event Listeners für editierbare Felder
    tbody.querySelectorAll('.editable-input').forEach(input => {
        input.addEventListener('input', handleEdit);
        input.addEventListener('blur', handleBlur);
        input.addEventListener('keydown', handleKeyDown);
    });

    // Event Listeners für Löschen-Buttons
    tbody.querySelectorAll('.btn-delete').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const kunId = parseInt(e.target.closest('tr').dataset.kunId);
            deleteRow(kunId);
        });
    });
}

/**
 * Tabellenzeile erstellen
 */
function createTableRow(row) {
    const isEdited = editedRows.has(row.kun_Id);
    const data = isEdited ? editedRows.get(row.kun_Id) : row;

    return `
        <tr data-kun-id="${row.kun_Id}" class="${isEdited ? 'edited' : ''}">
            <td class="col-firma">${escapeHtml(data.kun_Firma || '')}</td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Sicherheitspersonal"
                       value="${data.Sicherheitspersonal || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Leitungspersonal"
                       value="${data.Leitungspersonal || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Nachtzuschlag"
                       value="${data.Nachtzuschlag || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Sonntagszuschlag"
                       value="${data.Sonntagszuschlag || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Feiertagszuschlag"
                       value="${data.Feiertagszuschlag || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Fahrtkosten"
                       value="${data.Fahrtkosten || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-preis editable-cell">
                <input type="number"
                       class="editable-input currency-input"
                       data-field="Sonstiges"
                       value="${data.Sonstiges || ''}"
                       step="0.01"
                       min="0">
            </td>
            <td class="col-actions">
                <button class="action-btn btn-delete" title="Löschen">&times;</button>
            </td>
        </tr>
    `;
}

/**
 * Edit-Event Handler
 */
function handleEdit(e) {
    const input = e.target;
    const tr = input.closest('tr');
    const kunId = parseInt(tr.dataset.kunId);
    const field = input.dataset.field;
    const value = parseFloat(input.value) || null;

    // Edited-Data speichern
    if (!editedRows.has(kunId)) {
        const original = allData.find(r => r.kun_Id === kunId);
        editedRows.set(kunId, { ...original });
    }

    const editedRow = editedRows.get(kunId);
    editedRow[field] = value;

    // Zeile markieren
    tr.classList.add('edited');
    updateStats();
}

/**
 * Blur-Event Handler
 */
function handleBlur(e) {
    const input = e.target;
    const value = parseFloat(input.value);
    if (!isNaN(value)) {
        input.value = value.toFixed(2);
    }
}

/**
 * KeyDown-Event Handler
 */
function handleKeyDown(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        e.target.blur();

        // Nächstes Eingabefeld fokussieren
        const inputs = Array.from(tbody.querySelectorAll('.editable-input'));
        const currentIndex = inputs.indexOf(e.target);
        if (currentIndex >= 0 && currentIndex < inputs.length - 1) {
            inputs[currentIndex + 1].focus();
            inputs[currentIndex + 1].select();
        }
    } else if (e.key === 'Escape') {
        e.target.blur();
    }
}

/**
 * Neuer Eintrag
 */
function neuerEintrag() {
    setStatus('Neue Einträge können nur über Kundenverwaltung angelegt werden');
}

/**
 * Speichern
 */
async function speichern() {
    if (editedRows.size === 0) {
        setStatus('Keine Änderungen zum Speichern');
        return;
    }

    try {
        setStatus('Speichere Änderungen...');

        // Alle geänderten Zeilen speichern
        const updates = Array.from(editedRows.values());

        for (const row of updates) {
            await Bridge.execute('updateKundenpreise', {
                kun_Id: row.kun_Id,
                preise: {
                    Sicherheitspersonal: row.Sicherheitspersonal,
                    Leitungspersonal: row.Leitungspersonal,
                    Nachtzuschlag: row.Nachtzuschlag,
                    Sonntagszuschlag: row.Sonntagszuschlag,
                    Feiertagszuschlag: row.Feiertagszuschlag,
                    Fahrtkosten: row.Fahrtkosten,
                    Sonstiges: row.Sonstiges
                }
            });

            // Original-Daten aktualisieren
            const original = allData.find(r => r.kun_Id === row.kun_Id);
            if (original) {
                Object.assign(original, row);
            }
        }

        // Edited-Markierungen zurücksetzen
        editedRows.clear();
        renderTable();
        setStatus(`${updates.length} Datensätze gespeichert`);
    } catch (error) {
        console.error('Fehler beim Speichern:', error);
        setStatus('Fehler beim Speichern');
    }
}

/**
 * Zeile löschen
 */
function deleteRow(kunId) {
    if (!confirm('Alle Verrechnungssätze für diesen Kunden wirklich löschen?')) {
        return;
    }

    // Aus edited rows entfernen falls vorhanden
    editedRows.delete(kunId);

    setStatus(`Verrechnungssätze für Kunde ${kunId} gelöscht (lokal)`);
}

/**
 * Löschen (ausgewählte)
 */
function loeschen() {
    const selected = tbody.querySelector('tr.selected');
    if (!selected) {
        setStatus('Keine Zeile ausgewählt');
        return;
    }

    const kunId = parseInt(selected.dataset.kunId);
    deleteRow(kunId);
}

/**
 * Statistik aktualisieren
 */
function updateStats() {
    lblAnzahl.textContent = `${filteredData.length} Datensätze geladen`;
    lblRecordInfo.textContent = `Datensätze: ${filteredData.length} | Geändert: ${editedRows.size}`;
}

/**
 * Status setzen
 */
function setStatus(text) {
    if (lblStatus) {
        lblStatus.textContent = text;
    }
}

/**
 * HTML escapen
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Testdaten generieren (Fallback)
 */
function generateTestData() {
    return [
        {
            kun_Id: 1,
            kun_Firma: 'CONSEC GmbH',
            kun_IstAktiv: true,
            Sicherheitspersonal: 28.50,
            Leitungspersonal: 32.00,
            Nachtzuschlag: 5.00,
            Sonntagszuschlag: 7.50,
            Feiertagszuschlag: 10.00,
            Fahrtkosten: 0.35,
            Sonstiges: 0.00
        },
        {
            kun_Id: 2,
            kun_Firma: 'ABC Veranstaltungen',
            kun_IstAktiv: true,
            Sicherheitspersonal: 26.00,
            Leitungspersonal: 30.00,
            Nachtzuschlag: 4.50,
            Sonntagszuschlag: 6.50,
            Feiertagszuschlag: 9.00,
            Fahrtkosten: 0.30,
            Sonstiges: 0.00
        },
        {
            kun_Id: 3,
            kun_Firma: 'HC Erlangen',
            kun_IstAktiv: true,
            Sicherheitspersonal: 29.00,
            Leitungspersonal: 33.50,
            Nachtzuschlag: 5.50,
            Sonntagszuschlag: 8.00,
            Feiertagszuschlag: 11.00,
            Fahrtkosten: 0.40,
            Sonstiges: 2.50
        },
        {
            kun_Id: 4,
            kun_Firma: '1. FC Nürnberg',
            kun_IstAktiv: true,
            Sicherheitspersonal: 30.00,
            Leitungspersonal: 35.00,
            Nachtzuschlag: 6.00,
            Sonntagszuschlag: 8.50,
            Feiertagszuschlag: 12.00,
            Fahrtkosten: 0.45,
            Sonstiges: 0.00
        }
    ];
}
