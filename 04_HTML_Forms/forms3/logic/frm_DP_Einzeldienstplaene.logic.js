/**
 * Logic für frm_DP_Einzeldienstplaene - Druckbare Einzeldienstpläne
 *
 * Features:
 * - MA-Auswahl (Multi-Select)
 * - Zeitraum (Von/Bis)
 * - Dienstplan-Daten laden pro MA
 * - Druckbare A4-Seiten (pro MA eine Seite)
 * - Print-Support mit @media print
 */

const API_BASE = 'http://localhost:5000/api';

// State
const state = {
    mitarbeiter: [],
    filteredMA: [],
    selectedMAIds: new Set(),
    dienstplaene: {}
};

// Init
document.addEventListener('DOMContentLoaded', () => {
    console.log('[EinzelDP] Init');

    // Parse URL params
    const params = new URLSearchParams(window.location.search);
    const startParam = params.get('start');

    // Set dates
    const heute = new Date();
    const vonDate = startParam ? new Date(startParam) : heute;
    const bisDate = new Date(vonDate);
    bisDate.setDate(bisDate.getDate() + 6); // Default: 7 Tage

    document.getElementById('dtVon').value = formatDateISO(vonDate);
    document.getElementById('dtBis').value = formatDateISO(bisDate);

    // Event Listeners
    document.getElementById('txtMASearch').addEventListener('input', filterMA);
    document.getElementById('lstMitarbeiter').addEventListener('change', updateSelectedCount);

    // Load data
    loadMitarbeiter();
});

/**
 * Lädt Mitarbeiter-Liste
 */
async function loadMitarbeiter() {
    const loading = document.getElementById('loading');
    const statusLeft = document.getElementById('statusLeft');

    loading.style.display = 'block';
    statusLeft.textContent = 'Lade Mitarbeiter...';

    try {
        const response = await fetch(`${API_BASE}/mitarbeiter?aktiv=true&limit=500`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.error || 'API-Fehler');
        }

        state.mitarbeiter = (data.data || []).map(ma => ({
            ID: ma.ID,
            Name: `${ma.Nachname}, ${ma.Vorname}`,
            Nachname: ma.Nachname,
            Vorname: ma.Vorname
        }));

        state.filteredMA = [...state.mitarbeiter];

        renderMAList();

        statusLeft.textContent = `${state.mitarbeiter.length} Mitarbeiter geladen`;

    } catch (error) {
        console.error('[EinzelDP] Fehler beim Laden:', error);
        statusLeft.textContent = `Fehler: ${error.message}`;
    } finally {
        loading.style.display = 'none';
    }
}

/**
 * Rendert MA-Liste
 */
function renderMAList() {
    const select = document.getElementById('lstMitarbeiter');
    select.innerHTML = '';

    if (state.filteredMA.length === 0) {
        select.innerHTML = '<option value="">Keine Mitarbeiter gefunden</option>';
        return;
    }

    state.filteredMA.forEach(ma => {
        const option = document.createElement('option');
        option.value = ma.ID;
        option.textContent = ma.Name;
        option.selected = state.selectedMAIds.has(ma.ID);
        select.appendChild(option);
    });
}

/**
 * Filtert MA nach Suchbegriff
 */
function filterMA() {
    const search = document.getElementById('txtMASearch').value.toLowerCase();

    if (!search) {
        state.filteredMA = [...state.mitarbeiter];
    } else {
        state.filteredMA = state.mitarbeiter.filter(ma =>
            ma.Name.toLowerCase().includes(search)
        );
    }

    renderMAList();
}

/**
 * Selektiert alle MA
 */
function selectAllMA() {
    state.filteredMA.forEach(ma => state.selectedMAIds.add(ma.ID));
    renderMAList();
    updateSelectedCount();
}

/**
 * Deselektiert alle MA
 */
function selectNoneMA() {
    state.selectedMAIds.clear();
    renderMAList();
    updateSelectedCount();
}

/**
 * Update selected count
 */
function updateSelectedCount() {
    const select = document.getElementById('lstMitarbeiter');
    state.selectedMAIds.clear();

    Array.from(select.selectedOptions).forEach(opt => {
        state.selectedMAIds.add(parseInt(opt.value));
    });

    document.getElementById('statusRight').textContent =
        `${state.selectedMAIds.size} Mitarbeiter ausgewählt`;
}

/**
 * Generiert Vorschau
 */
async function generatePreview() {
    if (state.selectedMAIds.size === 0) {
        alert('Bitte mindestens einen Mitarbeiter auswählen');
        return;
    }

    const dtVon = document.getElementById('dtVon').value;
    const dtBis = document.getElementById('dtBis').value;

    if (!dtVon || !dtBis) {
        alert('Bitte Zeitraum angeben');
        return;
    }

    const loading = document.getElementById('loading');
    const statusLeft = document.getElementById('statusLeft');
    const previewArea = document.getElementById('previewArea');

    loading.style.display = 'block';
    statusLeft.textContent = 'Lade Dienstpläne...';

    try {
        // Lade Dienstpläne für ausgewählte MA
        state.dienstplaene = {};

        for (const maId of state.selectedMAIds) {
            const dp = await loadDienstplanForMA(maId, dtVon, dtBis);
            state.dienstplaene[maId] = dp;
        }

        // Render Vorschau
        renderPreview();

        // Enable Drucken + PDF buttons
        document.getElementById('btnDrucken').disabled = false;
        document.getElementById('btnPDF').disabled = false;

        statusLeft.textContent = 'Vorschau erstellt';

    } catch (error) {
        console.error('[EinzelDP] Fehler bei Vorschau:', error);
        statusLeft.textContent = `Fehler: ${error.message}`;
        previewArea.innerHTML = `<div class="preview-empty" style="color:red;">Fehler: ${error.message}</div>`;
    } finally {
        loading.style.display = 'none';
    }
}

/**
 * Lädt Dienstplan für einen MA
 */
async function loadDienstplanForMA(maId, vonDat, bisDat) {
    try {
        // API-Call: Dienstplan für MA im Zeitraum
        const params = new URLSearchParams({
            von: vonDat,
            bis: bisDat
        });

        const response = await fetch(`${API_BASE}/dienstplan/ma/${maId}?${params}`);
        const data = await response.json();

        if (!data.success) {
            return { einsaetze: [], ma: null };
        }

        return {
            ma: data.data.mitarbeiter || { Nachname: 'Unbekannt', Vorname: '' },
            einsaetze: data.data.einsaetze || []
        };

    } catch (error) {
        console.warn(`[EinzelDP] Fehler für MA ${maId}:`, error.message);
        return { einsaetze: [], ma: null };
    }
}

/**
 * Rendert Vorschau mit druckbaren Seiten
 */
function renderPreview() {
    const previewArea = document.getElementById('previewArea');
    const dtVon = document.getElementById('dtVon').value;
    const dtBis = document.getElementById('dtBis').value;

    const vonDate = new Date(dtVon);
    const bisDate = new Date(dtBis);

    previewArea.innerHTML = '';

    // Pro MA eine Seite
    for (const [maId, dpData] of Object.entries(state.dienstplaene)) {
        const ma = state.mitarbeiter.find(m => m.ID == maId);
        if (!ma) continue;

        const page = createDienstplanPage(ma, dpData, vonDate, bisDate);
        previewArea.appendChild(page);
    }

    if (previewArea.children.length === 0) {
        previewArea.innerHTML = '<div class="preview-empty">Keine Dienstpläne gefunden</div>';
    }
}

/**
 * Erstellt eine druckbare Dienstplan-Seite (A4)
 */
function createDienstplanPage(ma, dpData, vonDate, bisDate) {
    const page = document.createElement('div');
    page.className = 'dienstplan-page';

    // Header
    const header = document.createElement('div');
    header.className = 'dp-header';
    header.innerHTML = `
        <h2>Dienstplan: ${ma.Name}</h2>
        <div class="meta">
            Zeitraum: ${formatDateDE(vonDate)} - ${formatDateDE(bisDate)}<br>
            Erstellt: ${new Date().toLocaleDateString('de-DE')} ${new Date().toLocaleTimeString('de-DE')}
        </div>
    `;
    page.appendChild(header);

    // Einsätze
    const einsaetze = dpData.einsaetze || [];

    if (einsaetze.length === 0) {
        const empty = document.createElement('p');
        empty.textContent = 'Keine Einsätze im ausgewählten Zeitraum.';
        empty.style.marginTop = '20px';
        empty.style.color = '#666';
        page.appendChild(empty);
        return page;
    }

    // Table
    const table = document.createElement('table');
    table.className = 'dp-table';
    table.innerHTML = `
        <thead>
            <tr>
                <th>Datum</th>
                <th>Zeit</th>
                <th>Objekt/Kunde</th>
                <th>Position</th>
                <th>Bemerkung</th>
            </tr>
        </thead>
        <tbody></tbody>
    `;

    const tbody = table.querySelector('tbody');

    einsaetze.forEach(einsatz => {
        const tr = document.createElement('tr');

        // Datum
        const tdDatum = document.createElement('td');
        tdDatum.textContent = formatDateDE(new Date(einsatz.VADatum || einsatz.Datum));
        tr.appendChild(tdDatum);

        // Zeit
        const tdZeit = document.createElement('td');
        const start = einsatz.VA_Start || einsatz.Start || '00:00';
        const ende = einsatz.VA_Ende || einsatz.Ende || '23:59';
        tdZeit.textContent = `${start} - ${ende}`;
        tr.appendChild(tdZeit);

        // Objekt/Kunde
        const tdObjekt = document.createElement('td');
        const objekt = einsatz.Objekt || einsatz.ObjektName || 'N/A';
        const kunde = einsatz.Veranstalter || einsatz.Kunde || '';
        tdObjekt.innerHTML = `<strong>${objekt}</strong>`;
        if (kunde) {
            tdObjekt.innerHTML += `<div class="einsatz-detail">Kunde: ${kunde}</div>`;
        }
        tr.appendChild(tdObjekt);

        // Position
        const tdPosition = document.createElement('td');
        tdPosition.textContent = einsatz.Position || einsatz.Positionsname || '-';
        tr.appendChild(tdPosition);

        // Bemerkung
        const tdBemerkung = document.createElement('td');
        tdBemerkung.textContent = einsatz.Bemerkung || '';
        tr.appendChild(tdBemerkung);

        tbody.appendChild(tr);
    });

    page.appendChild(table);

    return page;
}

/**
 * Format helpers
 */
function formatDateISO(date) {
    return date.toISOString().slice(0, 10);
}

function formatDateDE(date) {
    return date.toLocaleDateString('de-DE');
}

/**
 * Exportiert Dienstpläne als PDF
 */
async function exportToPDF() {
    if (state.selectedMAIds.size === 0) {
        alert('Bitte erst Vorschau generieren');
        return;
    }

    const loading = document.getElementById('loading');
    const statusLeft = document.getElementById('statusLeft');
    const previewArea = document.getElementById('previewArea');

    loading.style.display = 'block';
    statusLeft.textContent = 'Generiere PDF...';

    try {
        // html2pdf.js Optionen
        const opt = {
            margin: 0, // Kein Margin, da A4-Seiten bereits Padding haben
            filename: `Einzeldienstplaene_${formatDateISO(new Date())}.pdf`,
            image: { type: 'jpeg', quality: 0.98 },
            html2canvas: {
                scale: 2,
                useCORS: true,
                letterRendering: true
            },
            jsPDF: {
                unit: 'mm',
                format: 'a4',
                orientation: 'portrait'
            },
            pagebreak: {
                mode: ['css', 'legacy'],
                avoid: ['.dp-table tr', '.dp-header']
            }
        };

        // Clone preview area (damit UI nicht flackert)
        const clone = previewArea.cloneNode(true);

        // Entferne "preview-empty" falls vorhanden
        const emptyDiv = clone.querySelector('.preview-empty');
        if (emptyDiv) {
            emptyDiv.remove();
        }

        // Generiere PDF
        await html2pdf().set(opt).from(clone).save();

        statusLeft.textContent = 'PDF erfolgreich erstellt';

    } catch (error) {
        console.error('[EinzelDP] Fehler bei PDF-Export:', error);
        statusLeft.textContent = `Fehler: ${error.message}`;
        alert(`Fehler beim PDF-Export:\n${error.message}`);
    } finally {
        loading.style.display = 'none';
    }
}

// Expose für HTML onclick
window.generatePreview = generatePreview;
window.selectAllMA = selectAllMA;
window.selectNoneMA = selectNoneMA;
window.exportToPDF = exportToPDF;
