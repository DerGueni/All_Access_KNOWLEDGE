// ============================================================
// frm_KD_Verrechnungssaetze.logic.js
// Logic-Datei fuer Verrechnungssaetze-Formular
// ============================================================

const VERRECHNUNGSSAETZE_API = 'http://127.0.0.1:5000/api';
let allData = [];
let filteredData = [];
let kundenListe = [];
let currentSort = { field: 'firma', direction: 'asc' };
let selectedRow = null;
let selectedData = null;

// ============================================================
// Initialisierung
// ============================================================

document.addEventListener('DOMContentLoaded', function() {
    console.log('[Verrechnungssaetze] Init');
    loadKundenFilter();
    loadData();
});

// ============================================================
// Kunden-Filter laden
// ============================================================

async function loadKundenFilter() {
    try {
        const response = await fetch(`${VERRECHNUNGSSAETZE_API}/kunden`);
        const result = await response.json();

        if (result.success) {
            kundenListe = result.data || [];
            const select = document.getElementById('kundenFilter');
            select.innerHTML = '<option value="">-- Alle Kunden --</option>';

            kundenListe
                .filter(k => k.kun_IstAktiv)
                .sort((a, b) => (a.kun_Firma || '').localeCompare(b.kun_Firma || '', 'de'))
                .forEach(kunde => {
                    const opt = document.createElement('option');
                    opt.value = kunde.kun_Id;
                    opt.textContent = kunde.kun_Firma || `Kunde ${kunde.kun_Id}`;
                    select.appendChild(opt);
                });
        }
    } catch (error) {
        console.error('[Verrechnungssaetze] Fehler beim Laden der Kunden:', error);
    }
}

// ============================================================
// Daten laden
// ============================================================

async function loadData() {
    showLoading(true);
    setStatus('Lade Daten...');

    try {
        const response = await fetch(`${VERRECHNUNGSSAETZE_API}/kundenpreise`);
        const result = await response.json();

        if (result.success && result.data) {
            allData = result.data;
            filteredData = [...allData];
            renderTable();
            updateRecordCount();
            setStatus('Daten geladen');
            document.getElementById('lastUpdate').textContent =
                'Aktualisiert: ' + new Date().toLocaleTimeString('de-DE');
        } else if (Array.isArray(result)) {
            // Alte API-Struktur Fallback
            allData = result;
            filteredData = [...allData];
            renderTable();
            updateRecordCount();
            setStatus('Daten geladen');
            document.getElementById('lastUpdate').textContent =
                'Aktualisiert: ' + new Date().toLocaleTimeString('de-DE');
        } else {
            showToast('Fehler: ' + (result.error || 'Unbekannter Fehler'), 'error');
            setStatus('Fehler beim Laden');
        }
    } catch (error) {
        console.error('[Verrechnungssaetze] Fehler:', error);
        showToast('Verbindungsfehler: ' + error.message, 'error');
        setStatus('Verbindungsfehler');
    } finally {
        showLoading(false);
    }
}

// ============================================================
// Tabelle rendern
// ============================================================

function renderTable() {
    const tbody = document.getElementById('preisBody');
    tbody.innerHTML = '';

    filteredData.forEach(row => {
        const tr = document.createElement('tr');
        tr.onclick = () => selectRowHandler(tr, row);
        tr.ondblclick = () => openKunde(row.kunId);

        tr.innerHTML = `
            <td>${row.firma || ''}</td>
            <td class="price">${formatPrice(row.Sicherheitspersonal)}</td>
            <td class="price">${formatPrice(row.Leitungspersonal)}</td>
            <td class="price">${formatPrice(row.Nachtzuschlag)}</td>
            <td class="price">${formatPrice(row.Sonntagszuschlag)}</td>
            <td class="price">${formatPrice(row.Feiertagszuschlag)}</td>
            <td class="price">${formatPrice(row.Fahrtkosten)}</td>
            <td class="price">${formatPrice(row.Sonstiges)}</td>
        `;

        tbody.appendChild(tr);
    });
}

// ============================================================
// Preis formatieren
// ============================================================

function formatPrice(value) {
    if (value === null || value === undefined) return '-';
    return parseFloat(value).toFixed(2).replace('.', ',') + ' EUR';
}

// ============================================================
// Zeile selektieren
// ============================================================

function selectRowHandler(tr, data) {
    if (selectedRow) {
        selectedRow.classList.remove('selected');
    }
    tr.classList.add('selected');
    selectedRow = tr;
    selectedData = data;
}

// ============================================================
// Kunde oeffnen (Doppelklick)
// ============================================================

function openKunde(kunId) {
    console.log('[Verrechnungssaetze] Oeffne Kunde:', kunId);
    // Navigation zum Kundenstamm
    if (typeof Bridge !== 'undefined' && Bridge.navigate) {
        Bridge.navigate('frm_KD_Kundenstamm', { id: kunId });
    } else {
        window.location.href = `frm_KD_Kundenstamm.html?id=${kunId}`;
    }
}

// ============================================================
// Suche / Filter
// ============================================================

function filterByKunde() {
    const kunId = document.getElementById('kundenFilter').value;
    document.getElementById('searchInput').value = '';  // Reset Textsuche

    if (!kunId) {
        filteredData = [...allData];
    } else {
        filteredData = allData.filter(row => row.kunId == kunId);
    }

    sortData();
    renderTable();
    updateRecordCount();
    setStatus(kunId ? `Filter: Kunde ${kunId}` : 'Alle Kunden');
}

function filterTable() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const kunId = document.getElementById('kundenFilter').value;

    // Start mit allen oder vorgefiltertem Kunden
    let baseData = kunId ? allData.filter(row => row.kunId == kunId) : [...allData];

    if (!searchTerm) {
        filteredData = baseData;
    } else {
        filteredData = baseData.filter(row =>
            (row.firma || '').toLowerCase().includes(searchTerm)
        );
    }

    sortData();
    renderTable();
    updateRecordCount();
}

function updateRecordCount() {
    const countEl = document.getElementById('recordCount');
    countEl.textContent = `${filteredData.length} von ${allData.length} Kunden`;
}

// ============================================================
// Sortierung
// ============================================================

function sortTable(field) {
    // Toggle Richtung wenn gleiches Feld
    if (currentSort.field === field) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }

    // Header-Klassen aktualisieren
    document.querySelectorAll('.data-grid th').forEach(th => {
        th.classList.remove('sort-asc', 'sort-desc');
        if (th.dataset.sort === field) {
            th.classList.add(currentSort.direction === 'asc' ? 'sort-asc' : 'sort-desc');
        }
    });

    sortData();
    renderTable();
}

function sortData() {
    const { field, direction } = currentSort;
    const multiplier = direction === 'asc' ? 1 : -1;

    filteredData.sort((a, b) => {
        let valA = a[field];
        let valB = b[field];

        // Null-Werte ans Ende
        if (valA === null) return 1;
        if (valB === null) return -1;

        // String-Vergleich fuer Firma
        if (field === 'firma') {
            return multiplier * (valA || '').localeCompare(valB || '', 'de');
        }

        // Numerischer Vergleich fuer Preise
        return multiplier * (parseFloat(valA) - parseFloat(valB));
    });
}

// ============================================================
// Export / Drucken
// ============================================================

function exportToExcel() {
    showToast('Excel-Export wird vorbereitet...', 'warning');
    // TODO: Implementierung via API
    console.log('[Verrechnungssaetze] Excel Export');
}

function printTable() {
    window.print();
}

// ============================================================
// Aktualisieren / Schliessen
// ============================================================

function refreshData() {
    loadData();
}

function closeForm() {
    if (typeof Bridge !== 'undefined' && Bridge.close) {
        Bridge.close();
    } else {
        window.close();
    }
}

// ============================================================
// Hilfsfunktionen
// ============================================================

function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.classList.toggle('active', show);
    }
}

function setStatus(text) {
    const statusEl = document.getElementById('statusText');
    if (statusEl) {
        statusEl.textContent = text;
    }
}

function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 3000);
}

// ============================================================
// Bearbeiten / Loeschen
// ============================================================

async function editSelected() {
    if (!selectedData) {
        showToast('Bitte zuerst einen Kunden auswaehlen', 'warning');
        return;
    }

    // Lade Detail-Daten fuer den Kunden
    try {
        const response = await fetch(`${VERRECHNUNGSSAETZE_API}/kundenpreise/${selectedData.kunId}`);
        const result = await response.json();

        if (!result.success || !result.data) {
            showToast('Fehler beim Laden der Preise: ' + (result.error || 'Keine Daten'), 'error');
            return;
        }

        // Einfaches Formular erstellen
        const preise = result.data.preise || {};
        const preisarten = result.data.preisarten || {};
        // Standard-Preisarten die wir anzeigen wollen
        const preisArtenNamen = ['Sicherheitspersonal', 'Leitungspersonal', 'Nachtzuschlag', 'Sonntagszuschlag', 'Feiertagszuschlag', 'Fahrtkosten', 'Sonstiges'];

        // Mapping von Preisart-Name zu ID erstellen
        const nameToId = {};
        for (const [id, name] of Object.entries(preisarten)) {
            nameToId[name] = id;
        }

        let html = `<div style="padding: 10px;">
            <h3 style="margin-bottom: 10px;">Preise bearbeiten: ${selectedData.firma}</h3>
            <table style="border-collapse: collapse;">`;

        preisArtenNamen.forEach(art => {
            const preisData = preise[art] || {};
            const preis = preisData.preis || '';
            const preisId = preisData.preisId || '';
            const preisartId = preisData.preisartId || nameToId[art] || '';
            html += `<tr>
                <td style="padding: 4px;">${art}:</td>
                <td><input type="number" step="0.01" id="preis_${art}" value="${preis}" data-preis-id="${preisId}" data-preisart-id="${preisartId}" style="width: 100px; text-align: right;"> EUR</td>
            </tr>`;
        });

        html += `</table>
            <div style="margin-top: 15px;">
                <button onclick="savePreise(${selectedData.kunId})" class="btn unified-btn btn-green">Speichern</button>
                <button onclick="closeModal()" class="btn unified-btn">Abbrechen</button>
            </div>
        </div>`;

        showModal(html);

    } catch (error) {
        console.error('[Verrechnungssaetze] Fehler:', error);
        showToast('Verbindungsfehler', 'error');
    }
}

async function savePreise(kunId) {
    const preisArten = ['Sicherheitspersonal', 'Leitungspersonal', 'Nachtzuschlag', 'Sonntagszuschlag', 'Feiertagszuschlag', 'Fahrtkosten', 'Sonstiges'];
    let erfolg = 0;
    let fehler = 0;

    for (const art of preisArten) {
        const input = document.getElementById(`preis_${art}`);
        if (!input) continue;

        const preisId = input.dataset.preisId;
        const neuerPreis = parseFloat(input.value);

        if (isNaN(neuerPreis)) continue;

        try {
            if (preisId) {
                // Update bestehender Preis
                const resp = await fetch(`${VERRECHNUNGSSAETZE_API}/kundenpreise/preis/${preisId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ StdPreis: neuerPreis })
                });
                const result = await resp.json();
                result.success ? erfolg++ : fehler++;
            } else if (neuerPreis > 0) {
                // TODO: Neuen Preis erstellen (POST) - erfordert Preisart_ID Mapping
                console.log(`[Verrechnungssaetze] Neuer Preis fuer ${art}: ${neuerPreis} - POST nicht implementiert`);
            }
        } catch (e) {
            fehler++;
            console.error(`Fehler bei ${art}:`, e);
        }
    }

    closeModal();

    if (fehler === 0 && erfolg > 0) {
        showToast(`${erfolg} Preis(e) aktualisiert`, 'success');
        loadData();
    } else if (fehler > 0) {
        showToast(`${erfolg} gespeichert, ${fehler} Fehler`, 'warning');
        loadData();
    } else {
        showToast('Keine Aenderungen', 'warning');
    }
}

async function deleteSelected() {
    if (!selectedData) {
        showToast('Bitte zuerst einen Kunden auswaehlen', 'warning');
        return;
    }

    if (!confirm(`Alle Preise fuer "${selectedData.firma}" loeschen?`)) {
        return;
    }

    try {
        // Lade Detail-Daten fuer den Kunden
        const response = await fetch(`${VERRECHNUNGSSAETZE_API}/kundenpreise/${selectedData.kunId}`);
        const result = await response.json();

        if (!result.success) {
            showToast('Fehler beim Laden der Preise', 'error');
            return;
        }

        const preise = result.data.preise || {};
        let geloescht = 0;

        for (const art of Object.keys(preise)) {
            const preisId = preise[art].preisId;
            if (preisId) {
                const delResp = await fetch(`${VERRECHNUNGSSAETZE_API}/kundenpreise/preis/${preisId}`, {
                    method: 'DELETE'
                });
                const delResult = await delResp.json();
                if (delResult.success) geloescht++;
            }
        }

        showToast(`${geloescht} Preis(e) geloescht`, 'success');
        loadData();

    } catch (error) {
        console.error('[Verrechnungssaetze] Fehler:', error);
        showToast('Fehler beim Loeschen', 'error');
    }
}

// ============================================================
// Modal-Funktionen
// ============================================================

function showModal(content) {
    // Modal erstellen wenn nicht vorhanden
    let modal = document.getElementById('editModal');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'editModal';
        modal.style.cssText = `
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: flex; justify-content: center;
            align-items: center; z-index: 10000;
        `;
        document.body.appendChild(modal);
    }

    modal.innerHTML = `<div style="background: #e0e0e0; border: 2px outset #c0c0c0; padding: 0; min-width: 350px;">
        <div style="background: linear-gradient(to right, #000080, #1084d0); color: white; padding: 4px 8px; font-weight: bold;">
            Preise bearbeiten
        </div>
        ${content}
    </div>`;
    modal.style.display = 'flex';
}

function closeModal() {
    const modal = document.getElementById('editModal');
    if (modal) modal.style.display = 'none';
}

// ============================================================
// WINDOW EXPORTS fuer onclick Handler
// ============================================================
window.filterTable = filterTable;
window.filterByKunde = filterByKunde;
window.sortTable = sortTable;
window.exportToExcel = exportToExcel;
window.printTable = printTable;
window.refreshData = refreshData;
window.closeForm = closeForm;
window.editSelected = editSelected;
window.deleteSelected = deleteSelected;
window.savePreise = savePreise;
window.closeModal = closeModal;
