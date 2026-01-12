/**
 * frm_Einsatzuebersicht.logic.js
 * Logik fuer Einsatzuebersicht (Auftraege/Schichten Listenansicht)
 * WebView2 Bridge Integration
 *
 * Features:
 * - Datumsfilter (Von/Bis)
 * - Schnellfilter (Heute, Diese Woche, Dieser Monat)
 * - Nur aktive Auftraege Filter
 * - Gruppierung nach Objekt/MA/Datum
 * - Sortierbare Spalten
 * - Klick auf Zeile oeffnet Auftragstamm
 * - Export Excel / Drucken
 */

'use strict';

// ============================================
// STATE MANAGEMENT
// ============================================
const state = {
    vonDatum: null,
    bisDatum: null,
    quickFilter: 'heute',        // 'heute', 'woche', 'monat'
    nurAktive: true,
    gruppierung: 'none',         // 'none', 'objekt', 'ma', 'datum'
    sortColumn: 'datum',
    sortDirection: 'asc',
    einsaetze: [],
    filteredEinsaetze: [],
    selectedRow: null,
    collapsedGroups: new Set()
};

// DOM-Elemente (werden bei Init gefuellt)
let elements = {};

// ============================================
// INITIALIZATION
// ============================================

/**
 * Initialisierung beim DOM-Ready
 */
function init() {
    console.log('[Einsatzuebersicht] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Datum
        dtVonDatum: document.getElementById('dtVonDatum'),
        dtBisDatum: document.getElementById('dtBisDatum'),

        // Buttons
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        btnZurueck: document.getElementById('btnZurueck'),
        btnHeute: document.getElementById('btnHeute'),
        btnVor: document.getElementById('btnVor'),
        btnExportExcel: document.getElementById('btnExportExcel'),
        btnDrucken: document.getElementById('btnDrucken'),

        // Filter
        chkNurAktive: document.getElementById('chkNurAktive'),
        cboGruppierung: document.getElementById('cboGruppierung'),
        btnFilterHeute: document.getElementById('btnFilterHeute'),
        btnFilterWoche: document.getElementById('btnFilterWoche'),
        btnFilterMonat: document.getElementById('btnFilterMonat'),

        // Tabelle
        tblEinsaetze: document.getElementById('tblEinsaetze'),
        tbodyEinsaetze: document.getElementById('tbodyEinsaetze'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblRecordInfo: document.getElementById('lblRecordInfo'),
        lblFormTitle: document.getElementById('lblFormTitle'),
        lbl_Version: document.getElementById('lbl_Version'),
        lbl_Datum: document.getElementById('lbl_Datum'),

        // Loading
        loadingOverlay: document.getElementById('loadingOverlay'),
        toastContainer: document.getElementById('toastContainer')
    };

    // WebView2 Bridge Event-Listener registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
    }

    // Event Listener fuer Datum-Inputs
    elements.dtVonDatum.addEventListener('change', onDateChange);
    elements.dtBisDatum.addEventListener('change', onDateChange);

    // Keyboard Shortcuts
    document.addEventListener('keydown', handleKeydown);

    // Version und Datum anzeigen
    Form_Load();

    // Initialen Zeitraum setzen (Heute)
    setQuickFilter('heute');
}

/**
 * Form_Load - Version und Datum anzeigen
 */
function Form_Load() {
    console.log('[Form_Load] Formular geladen');

    // Version anzeigen
    elements.lbl_Version.textContent = 'HTML 1.0 | WebView2';

    // Aktuelles Datum anzeigen
    const heute = new Date();
    elements.lbl_Datum.textContent = heute.toLocaleDateString('de-DE', {
        weekday: 'short',
        day: '2-digit',
        month: '2-digit',
        year: '2-digit'
    });
}

// ============================================
// FILTER FUNCTIONS
// ============================================

/**
 * Schnellfilter setzen (Heute, Woche, Monat)
 */
function setQuickFilter(filter) {
    console.log('[setQuickFilter]', filter);

    state.quickFilter = filter;
    const heute = new Date();
    heute.setHours(0, 0, 0, 0);

    // Quick-Filter Buttons aktualisieren
    document.querySelectorAll('.quick-filter-btn').forEach(btn => btn.classList.remove('active'));

    switch (filter) {
        case 'heute':
            state.vonDatum = new Date(heute);
            state.bisDatum = new Date(heute);
            document.getElementById('btnFilterHeute').classList.add('active');
            break;

        case 'woche':
            // Montag dieser Woche
            const montag = new Date(heute);
            const day = montag.getDay();
            const diff = day === 0 ? -6 : 1 - day;
            montag.setDate(montag.getDate() + diff);

            // Sonntag dieser Woche
            const sonntag = new Date(montag);
            sonntag.setDate(sonntag.getDate() + 6);

            state.vonDatum = montag;
            state.bisDatum = sonntag;
            document.getElementById('btnFilterWoche').classList.add('active');
            break;

        case 'monat':
            // Erster des Monats
            state.vonDatum = new Date(heute.getFullYear(), heute.getMonth(), 1);
            // Letzter des Monats
            state.bisDatum = new Date(heute.getFullYear(), heute.getMonth() + 1, 0);
            document.getElementById('btnFilterMonat').classList.add('active');
            break;
    }

    // Datum-Inputs aktualisieren
    elements.dtVonDatum.value = formatDateISO(state.vonDatum);
    elements.dtBisDatum.value = formatDateISO(state.bisDatum);

    // Titel aktualisieren
    updateFormTitle();

    // Daten laden
    loadEinsaetze();
}

/**
 * Bei Datum-Aenderung
 */
function onDateChange() {
    // Quick-Filter deaktivieren wenn manuell geaendert
    document.querySelectorAll('.quick-filter-btn').forEach(btn => btn.classList.remove('active'));
    state.quickFilter = null;
}

/**
 * Checkbox "Nur aktive" geaendert
 */
function chkNurAktive_Change() {
    state.nurAktive = elements.chkNurAktive.checked;
    console.log('[chkNurAktive_Change]', state.nurAktive);
    applyFiltersAndRender();
}

/**
 * Gruppierung geaendert
 */
function cboGruppierung_Change() {
    state.gruppierung = elements.cboGruppierung.value;
    console.log('[cboGruppierung_Change]', state.gruppierung);
    state.collapsedGroups.clear();
    renderTable();
}

// ============================================
// NAVIGATION BUTTONS
// ============================================

/**
 * Aktualisieren Button
 */
function btnAktualisieren_Click() {
    console.log('[btnAktualisieren_Click]');

    // Datum aus Inputs holen
    if (elements.dtVonDatum.value) {
        state.vonDatum = new Date(elements.dtVonDatum.value);
    }
    if (elements.dtBisDatum.value) {
        state.bisDatum = new Date(elements.dtBisDatum.value);
    }

    // Zeitraum-Validierung
    if (!validateDateRange()) return;

    updateFormTitle();
    loadEinsaetze();
}

/**
 * Heute Button
 */
function btnHeute_Click() {
    console.log('[btnHeute_Click]');
    setQuickFilter('heute');
}

/**
 * Zeitraum zurueck
 */
function btnZurueck_Click() {
    console.log('[btnZurueck_Click]');

    if (!state.vonDatum || !state.bisDatum) return;

    // Zeitraum berechnen
    const diff = Math.ceil((state.bisDatum - state.vonDatum) / (1000 * 60 * 60 * 24)) + 1;

    state.vonDatum.setDate(state.vonDatum.getDate() - diff);
    state.bisDatum.setDate(state.bisDatum.getDate() - diff);

    elements.dtVonDatum.value = formatDateISO(state.vonDatum);
    elements.dtBisDatum.value = formatDateISO(state.bisDatum);

    // Quick-Filter deaktivieren
    document.querySelectorAll('.quick-filter-btn').forEach(btn => btn.classList.remove('active'));
    state.quickFilter = null;

    updateFormTitle();
    loadEinsaetze();
}

/**
 * Zeitraum vor
 */
function btnVor_Click() {
    console.log('[btnVor_Click]');

    if (!state.vonDatum || !state.bisDatum) return;

    // Zeitraum berechnen
    const diff = Math.ceil((state.bisDatum - state.vonDatum) / (1000 * 60 * 60 * 24)) + 1;

    state.vonDatum.setDate(state.vonDatum.getDate() + diff);
    state.bisDatum.setDate(state.bisDatum.getDate() + diff);

    elements.dtVonDatum.value = formatDateISO(state.vonDatum);
    elements.dtBisDatum.value = formatDateISO(state.bisDatum);

    // Quick-Filter deaktivieren
    document.querySelectorAll('.quick-filter-btn').forEach(btn => btn.classList.remove('active'));
    state.quickFilter = null;

    updateFormTitle();
    loadEinsaetze();
}

// ============================================
// DATA LOADING
// ============================================

/**
 * Einsatzdaten laden
 */
async function loadEinsaetze() {
    console.log('[loadEinsaetze] Von:', state.vonDatum, 'Bis:', state.bisDatum);

    if (!state.vonDatum || !state.bisDatum) {
        showToast('Bitte Zeitraum auswaehlen', 'warning');
        return;
    }

    setStatus('Lade Einsatzdaten...');
    showLoading(true);

    try {
        // WebView2 Bridge verwenden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadEinsatzuebersicht', {
                von: formatDateISO(state.vonDatum),
                bis: formatDateISO(state.bisDatum),
                nurAktive: state.nurAktive
            });
        } else {
            // REST-API Fallback oder Demo-Daten
            await loadEinsaetzeAPI();
        }
    } catch (error) {
        console.error('[loadEinsaetze] Fehler:', error);
        setStatus('Fehler: ' + error.message);
        showLoading(false);
        showToast('Fehler beim Laden: ' + error.message, 'error');
    }
}

/**
 * Einsatzdaten via REST-API laden (Fallback)
 */
async function loadEinsaetzeAPI() {
    try {
        // Neuer Endpoint /api/einsatzuebersicht mit allen Details
        const API_BASE = 'http://localhost:5000';
        const params = new URLSearchParams({
            von: formatDateISO(state.vonDatum),
            bis: formatDateISO(state.bisDatum),
            nurAktive: state.nurAktive
        });

        const response = await fetch(`${API_BASE}/api/einsatzuebersicht?${params}`);
        const result = await response.json();

        if (result && result.success && result.data) {
            processEinsatzData(result.data);
        } else {
            console.warn('[loadEinsaetzeAPI] Keine Daten, lade Demo-Daten');
            loadDemoData();
        }
    } catch (error) {
        console.error('[loadEinsaetzeAPI] Fehler:', error);
        loadDemoData();
    }
}

/**
 * Demo-Daten laden (fuer Entwicklung ohne Backend)
 */
function loadDemoData() {
    console.log('[loadDemoData] Lade Demo-Daten...');

    const demoEinsaetze = [];
    const heute = new Date();

    // Demo-Objekte
    const objekte = ['Messe Nuernberg', 'Konzerthalle Fuerth', 'Stadion FCN', 'Arena Erlangen', 'Congress Center'];
    const auftraege = ['Messe IAA', 'Konzert Helene Fischer', 'Bundesliga Heimspiel', 'Handball WM', 'Kongress IT-Branche'];
    const statusWerte = ['Offen', 'Teilbesetzt', 'Besetzt', 'In Planung'];

    // 20 Demo-Eintraege generieren
    for (let i = 0; i < 20; i++) {
        const datum = new Date(heute);
        datum.setDate(datum.getDate() + Math.floor(Math.random() * 14) - 7);

        const sollMA = Math.floor(Math.random() * 10) + 2;
        const istMA = Math.floor(Math.random() * (sollMA + 1));

        let status;
        if (istMA === 0) status = 'Offen';
        else if (istMA < sollMA) status = 'Teilbesetzt';
        else status = 'Besetzt';

        demoEinsaetze.push({
            VAS_ID: 1000 + i,
            VA_ID: 100 + Math.floor(i / 2),
            VADatum: datum.toISOString().split('T')[0],
            VA_Start: ['06:00', '08:00', '10:00', '12:00', '14:00', '18:00'][Math.floor(Math.random() * 6)],
            VA_Ende: ['14:00', '16:00', '18:00', '20:00', '22:00', '00:00'][Math.floor(Math.random() * 6)],
            Objekt: objekte[Math.floor(Math.random() * objekte.length)],
            Auftrag: auftraege[Math.floor(Math.random() * auftraege.length)],
            MA_Anzahl: sollMA,
            MA_Anzahl_Ist: istMA,
            Status: status,
            VA_IstAktiv: Math.random() > 0.1 ? -1 : 0
        });
    }

    processEinsatzData(demoEinsaetze);
    showToast('Demo-Modus aktiv (keine Datenbankverbindung)', 'info');
}

/**
 * Einsatzdaten verarbeiten
 */
function processEinsatzData(rawData) {
    console.log('[processEinsatzData] Verarbeite', rawData.length, 'Eintraege');

    // Daten transformieren
    state.einsaetze = rawData.map(row => ({
        id: row.VAS_ID || row.ID,
        va_id: row.VA_ID,
        datum: row.VADatum || row.Datum,
        posnr: row.PosNr || '',
        start: formatTime(row.VA_Start),
        ende: formatTime(row.VA_Ende),
        objekt: row.Objekt || row.VA_Objekt || '',
        ort: row.Ort || '',
        auftrag: row.Auftrag || row.VA_Auftrag || row.Veranstaltung || '',
        ma_namen: row.MA_Namen || '',
        soll: row.MA_Anzahl || row.MA_Soll || 0,
        ist: row.MA_Anzahl_Ist || row.MA_Ist || 0,
        stunden_brutto: row.Stunden_Brutto || 0,
        stunden_netto: row.Stunden_Netto || 0,
        status: row.Status || calculateStatus(row),
        istAktiv: row.VA_IstAktiv !== 0
    }));

    // Sortieren nach Datum
    state.einsaetze.sort((a, b) => new Date(a.datum) - new Date(b.datum));

    applyFiltersAndRender();
    showLoading(false);
}

/**
 * Status berechnen falls nicht vorhanden
 */
function calculateStatus(row) {
    const soll = row.MA_Anzahl || row.MA_Soll || 0;
    const ist = row.MA_Anzahl_Ist || row.MA_Ist || 0;

    if (soll === 0) return 'In Planung';
    if (ist === 0) return 'Offen';
    if (ist < soll) return 'Teilbesetzt';
    return 'Besetzt';
}

/**
 * Filter anwenden und rendern
 */
function applyFiltersAndRender() {
    // Filter anwenden
    state.filteredEinsaetze = state.einsaetze.filter(e => {
        // Nur aktive Filter
        if (state.nurAktive && !e.istAktiv) return false;

        // Datumsbereich
        const datum = new Date(e.datum);
        if (state.vonDatum && datum < state.vonDatum) return false;
        if (state.bisDatum && datum > state.bisDatum) return false;

        return true;
    });

    // Sortieren
    sortData();

    // Rendern
    renderTable();

    // Status aktualisieren
    setStatus('Bereit');
    elements.lblRecordInfo.textContent = state.filteredEinsaetze.length + ' Eintraege';
}

// ============================================
// SORTING
// ============================================

/**
 * Tabelle sortieren
 */
function sortTable(column) {
    console.log('[sortTable]', column);

    // Wenn gleiche Spalte, Richtung umkehren
    if (state.sortColumn === column) {
        state.sortDirection = state.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
        state.sortColumn = column;
        state.sortDirection = 'asc';
    }

    // Header-Klassen aktualisieren
    document.querySelectorAll('.einsatz-table th').forEach(th => {
        th.classList.remove('sort-asc', 'sort-desc');
        if (th.dataset.sort === column) {
            th.classList.add(state.sortDirection === 'asc' ? 'sort-asc' : 'sort-desc');
        }
    });

    sortData();
    renderTable();
}

/**
 * Daten sortieren
 */
function sortData() {
    const col = state.sortColumn;
    const dir = state.sortDirection === 'asc' ? 1 : -1;

    state.filteredEinsaetze.sort((a, b) => {
        let valA, valB;

        switch (col) {
            case 'datum':
                valA = new Date(a.datum);
                valB = new Date(b.datum);
                break;
            case 'posnr':
                valA = parseInt(a.posnr) || 0;
                valB = parseInt(b.posnr) || 0;
                break;
            case 'auftrag':
                valA = (a.auftrag || '').toLowerCase();
                valB = (b.auftrag || '').toLowerCase();
                break;
            case 'objekt':
                valA = (a.objekt || '').toLowerCase();
                valB = (b.objekt || '').toLowerCase();
                break;
            case 'ort':
                valA = (a.ort || '').toLowerCase();
                valB = (b.ort || '').toLowerCase();
                break;
            case 'schicht':
                valA = a.start || '';
                valB = b.start || '';
                break;
            case 'ma_namen':
                valA = (a.ma_namen || '').toLowerCase();
                valB = (b.ma_namen || '').toLowerCase();
                break;
            case 'ma':
                valA = a.ist - a.soll;  // Differenz
                valB = b.ist - b.soll;
                break;
            case 'stunden_brutto':
                valA = a.stunden_brutto || 0;
                valB = b.stunden_brutto || 0;
                break;
            case 'stunden_netto':
                valA = a.stunden_netto || 0;
                valB = b.stunden_netto || 0;
                break;
            case 'status':
                valA = a.status || '';
                valB = b.status || '';
                break;
            default:
                return 0;
        }

        if (valA < valB) return -1 * dir;
        if (valA > valB) return 1 * dir;
        return 0;
    });
}

// ============================================
// RENDERING
// ============================================

/**
 * Tabelle rendern
 */
function renderTable() {
    const tbody = elements.tbodyEinsaetze;

    if (state.filteredEinsaetze.length === 0) {
        tbody.innerHTML = '<tr><td colspan="11" style="text-align:center; padding:40px; color:#666;">Keine Einsaetze im gewaehlten Zeitraum gefunden</td></tr>';
        return;
    }

    let html = '';

    if (state.gruppierung === 'none') {
        // Ohne Gruppierung
        html = state.filteredEinsaetze.map(e => renderRow(e)).join('');
    } else {
        // Mit Gruppierung
        html = renderGrouped();
    }

    tbody.innerHTML = html;

    // Click-Handler fuer Zeilen
    tbody.querySelectorAll('tr[data-id]').forEach(tr => {
        tr.addEventListener('click', () => onRowClick(tr));
        tr.addEventListener('dblclick', () => onRowDblClick(tr));
    });

    // Click-Handler fuer Gruppierung
    tbody.querySelectorAll('.group-header').forEach(tr => {
        tr.addEventListener('click', () => toggleGroup(tr.dataset.group));
    });
}

/**
 * Einzelne Zeile rendern
 */
function renderRow(e) {
    const statusClass = getStatusClass(e.status);
    const maClass = getMaClass(e.soll, e.ist);

    return `
        <tr data-id="${e.id}" data-va-id="${e.va_id}">
            <td class="col-datum">${formatDateDisplay(e.datum)}</td>
            <td class="col-posnr">${escapeHtml(e.posnr)}</td>
            <td class="col-auftrag">${escapeHtml(e.auftrag)}</td>
            <td class="col-objekt">${escapeHtml(e.objekt)}</td>
            <td class="col-ort">${escapeHtml(e.ort)}</td>
            <td class="col-schicht">${e.start} - ${e.ende}</td>
            <td class="col-ma-namen">${escapeHtml(e.ma_namen)}</td>
            <td class="col-ma"><span class="ma-count ${maClass}">${e.ist}/${e.soll}</span></td>
            <td class="col-stunden">${e.stunden_brutto.toFixed(2)}</td>
            <td class="col-stunden">${e.stunden_netto.toFixed(2)}</td>
            <td class="col-status"><span class="status-badge ${statusClass}">${e.status}</span></td>
        </tr>
    `;
}

/**
 * Gruppierte Darstellung rendern
 */
function renderGrouped() {
    let html = '';
    const groups = new Map();

    // Nach Gruppierungskriterium gruppieren
    state.filteredEinsaetze.forEach(e => {
        let groupKey;
        switch (state.gruppierung) {
            case 'objekt':
                groupKey = e.objekt || 'Ohne Objekt';
                break;
            case 'datum':
                groupKey = e.datum;
                break;
            case 'ma':
                groupKey = e.status || 'Unbekannt';
                break;
            default:
                groupKey = 'Alle';
        }

        if (!groups.has(groupKey)) {
            groups.set(groupKey, []);
        }
        groups.get(groupKey).push(e);
    });

    // Gruppen sortieren
    const sortedKeys = Array.from(groups.keys()).sort();

    // Gruppen rendern
    sortedKeys.forEach(key => {
        const items = groups.get(key);
        const isCollapsed = state.collapsedGroups.has(key);
        const icon = isCollapsed ? '+' : '-';

        // Gruppen-Header mit Zusammenfassung
        const totalSoll = items.reduce((sum, e) => sum + e.soll, 0);
        const totalIst = items.reduce((sum, e) => sum + e.ist, 0);

        let displayKey = key;
        if (state.gruppierung === 'datum') {
            displayKey = formatDateDisplay(key);
        }

        html += `
            <tr class="group-header" data-group="${escapeHtml(key)}">
                <td colspan="8">
                    <span class="toggle-icon">${icon}</span>
                    <strong>${escapeHtml(displayKey)}</strong>
                    <span style="color:#666; margin-left:10px;">(${items.length} Einsaetze)</span>
                </td>
                <td class="col-ma"><span class="ma-count ${getMaClass(totalSoll, totalIst)}">${totalIst}/${totalSoll}</span></td>
                <td colspan="2"></td>
            </tr>
        `;

        // Zeilen der Gruppe
        if (!isCollapsed) {
            items.forEach(e => {
                html += renderRow(e).replace('<tr', '<tr class="group-row"');
            });
        }
    });

    return html;
}

/**
 * Gruppe ein-/ausklappen
 */
function toggleGroup(groupKey) {
    if (state.collapsedGroups.has(groupKey)) {
        state.collapsedGroups.delete(groupKey);
    } else {
        state.collapsedGroups.add(groupKey);
    }
    renderTable();
}

// ============================================
// ROW CLICK HANDLERS
// ============================================

/**
 * Zeile angeklickt (Auswahl)
 */
function onRowClick(tr) {
    // Vorherige Auswahl entfernen
    elements.tbodyEinsaetze.querySelectorAll('tr.selected').forEach(row => row.classList.remove('selected'));

    // Neue Auswahl setzen
    tr.classList.add('selected');
    state.selectedRow = {
        id: tr.dataset.id,
        va_id: tr.dataset.vaId
    };

    console.log('[onRowClick] Ausgewaehlt:', state.selectedRow);
}

/**
 * Zeile doppelgeklickt (Auftrag oeffnen)
 */
function onRowDblClick(tr) {
    const va_id = tr.dataset.vaId;
    console.log('[onRowDblClick] Oeffne Auftrag:', va_id);

    openAuftragstamm(va_id);
}

/**
 * Auftragstamm oeffnen
 */
function openAuftragstamm(va_id) {
    if (!va_id) {
        showToast('Keine VA_ID verfuegbar', 'warning');
        return;
    }

    // WebView2 Bridge verwenden
    if (typeof Bridge !== 'undefined' && Bridge.navigate) {
        Bridge.navigate('frm_va_Auftragstamm', va_id);
    } else if (window.parent !== window) {
        // Shell-Modus: PostMessage
        window.parent.postMessage({
            type: 'navigate',
            formName: 'frm_va_Auftragstamm',
            id: va_id
        }, '*');
    } else {
        // Direkter Link
        window.location.href = 'frm_va_Auftragstamm.html?id=' + va_id;
    }
}

// ============================================
// EXPORT FUNCTIONS
// ============================================

/**
 * Excel-Export
 */
function btnExportExcel_Click() {
    console.log('[btnExportExcel_Click]');

    if (state.filteredEinsaetze.length === 0) {
        showToast('Keine Daten zum Exportieren', 'warning');
        return;
    }

    // WebView2 Bridge verwenden
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('exportExcel', {
            type: 'einsatzuebersicht',
            von: formatDateISO(state.vonDatum),
            bis: formatDateISO(state.bisDatum),
            data: state.filteredEinsaetze
        });
        showToast('Excel-Export wird erstellt...', 'info');
    } else {
        // CSV-Export als Fallback
        exportToCSV();
    }
}

/**
 * CSV-Export (Browser-Fallback)
 */
function exportToCSV() {
    const headers = ['Datum', 'PosNr', 'Auftrag', 'Objekt', 'Ort', 'Schicht Start', 'Schicht Ende', 'Mitarbeiter', 'MA Soll', 'MA Ist', 'Std (B)', 'Std (N)', 'Status'];

    const rows = state.filteredEinsaetze.map(e => [
        formatDateDisplay(e.datum),
        e.posnr,
        e.auftrag,
        e.objekt,
        e.ort,
        e.start,
        e.ende,
        e.ma_namen,
        e.soll,
        e.ist,
        e.stunden_brutto.toFixed(2),
        e.stunden_netto.toFixed(2),
        e.status
    ]);

    const csv = [headers, ...rows]
        .map(row => row.map(cell => '"' + String(cell || '').replace(/"/g, '""') + '"').join(';'))
        .join('\n');

    // Download
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Einsatzuebersicht_' + formatDateISO(new Date()) + '.csv';
    a.click();
    URL.revokeObjectURL(url);

    showToast('CSV-Export abgeschlossen', 'success');
}

/**
 * Drucken
 */
function btnDrucken_Click() {
    console.log('[btnDrucken_Click]');

    // WebView2 Bridge verwenden
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('print', {
            type: 'einsatzuebersicht',
            von: formatDateISO(state.vonDatum),
            bis: formatDateISO(state.bisDatum)
        });
    } else {
        // Browser-Print
        window.print();
    }
}

// ============================================
// WEBVIEW2 BRIDGE HANDLER
// ============================================

/**
 * Daten von Bridge empfangen
 */
function handleBridgeData(data) {
    console.log('[handleBridgeData]', data);

    if (data.einsatzuebersicht || data.einsatztage || data.schichten) {
        const rawData = data.einsatzuebersicht || data.einsatztage || data.schichten || [];
        processEinsatzData(rawData);
    }

    if (data.error) {
        showToast('Fehler: ' + data.error, 'error');
        setStatus('Fehler: ' + data.error);
        showLoading(false);
    }
}

// ============================================
// KEYBOARD HANDLER
// ============================================

/**
 * Tastatur-Events
 */
function handleKeydown(e) {
    // ESC: Formular schliessen
    if (e.key === 'Escape') {
        closeForm();
        return;
    }

    // F5: Aktualisieren
    if (e.key === 'F5') {
        e.preventDefault();
        btnAktualisieren_Click();
        return;
    }

    // Ctrl+P: Drucken
    if (e.ctrlKey && e.key === 'p') {
        e.preventDefault();
        btnDrucken_Click();
        return;
    }

    // Ctrl+E: Excel-Export
    if (e.ctrlKey && e.key === 'e') {
        e.preventDefault();
        btnExportExcel_Click();
        return;
    }

    // Enter: Ausgewaehlten Auftrag oeffnen
    if (e.key === 'Enter' && state.selectedRow) {
        openAuftragstamm(state.selectedRow.va_id);
        return;
    }

    // Pfeiltasten: Navigation in Tabelle
    if (['ArrowUp', 'ArrowDown'].includes(e.key)) {
        e.preventDefault();
        navigateTable(e.key === 'ArrowUp' ? -1 : 1);
    }
}

/**
 * Tabellen-Navigation mit Pfeiltasten
 */
function navigateTable(direction) {
    const rows = elements.tbodyEinsaetze.querySelectorAll('tr[data-id]');
    if (rows.length === 0) return;

    let currentIndex = -1;
    rows.forEach((row, idx) => {
        if (row.classList.contains('selected')) {
            currentIndex = idx;
        }
    });

    let newIndex = currentIndex + direction;
    if (newIndex < 0) newIndex = rows.length - 1;
    if (newIndex >= rows.length) newIndex = 0;

    onRowClick(rows[newIndex]);
    rows[newIndex].scrollIntoView({ block: 'nearest' });
}

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Formular schliessen
 */
function closeForm() {
    console.log('[closeForm]');

    // Shell-Modus pruefen
    const urlParams = new URLSearchParams(window.location.search);
    const isShellMode = urlParams.get('shell') === '1';

    if (isShellMode && window.parent !== window) {
        window.parent.postMessage({ type: 'CLOSE' }, '*');
    } else if (typeof Bridge !== 'undefined' && Bridge.close) {
        Bridge.close();
    } else {
        window.close();
    }
}

/**
 * Navigation zu anderem Formular
 */
function navigateToForm(formName, id) {
    console.log('[navigateToForm]', formName, id);

    // Zuerst pruefen ob shell-detector.js bereits eine globale Funktion gesetzt hat
    if (window.isInShellMode && typeof window._shellNavigateToForm === 'function') {
        window._shellNavigateToForm(formName, id);
        return;
    }

    if (typeof Bridge !== 'undefined' && Bridge.navigate) {
        Bridge.navigate(formName, id);
    } else if (window.parent !== window) {
        // WICHTIG: type muss 'NAVIGATE' sein (uppercase) - shell.html erwartet das
        window.parent.postMessage({ type: 'NAVIGATE', formName: formName, id: id }, '*');
    } else {
        let url = formName + '.html';
        if (id) url += '?id=' + id;
        window.location.href = url;
    }
}

/**
 * Formular-Titel aktualisieren
 */
function updateFormTitle() {
    let title = 'Einsatzuebersicht';

    if (state.vonDatum && state.bisDatum) {
        const von = formatDateDisplay(state.vonDatum);
        const bis = formatDateDisplay(state.bisDatum);

        if (von === bis) {
            title += ' - ' + von;
        } else {
            title += ' - ' + von + ' bis ' + bis;
        }
    }

    elements.lblFormTitle.textContent = title;
}

/**
 * Status setzen
 */
function setStatus(text) {
    elements.lblStatus.textContent = text;
}

/**
 * Zeitraum-Validierung: Bis-Datum muss >= Von-Datum sein
 */
function validateDateRange() {
    const von = elements.dtVonDatum?.value;
    const bis = elements.dtBisDatum?.value;

    if (von && bis && von > bis) {
        showToast('Enddatum muss nach Startdatum liegen', 'error');
        return false;
    }
    return true;
}

/**
 * Loading-Overlay anzeigen/verstecken
 */
function showLoading(show) {
    if (show) {
        elements.loadingOverlay.classList.add('active');
    } else {
        elements.loadingOverlay.classList.remove('active');
    }
}

/**
 * Toast-Nachricht anzeigen
 */
function showToast(message, type) {
    type = type || 'info';

    const toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.textContent = message;
    elements.toastContainer.appendChild(toast);

    setTimeout(() => toast.remove(), 4000);
}

/**
 * Datum formatieren fuer API (ISO)
 */
function formatDateISO(date) {
    if (!date) return null;
    if (typeof date === 'string') return date.split('T')[0];
    return date.toISOString().split('T')[0];
}

/**
 * Datum formatieren fuer Anzeige
 */
function formatDateDisplay(date) {
    if (!date) return '';
    const d = typeof date === 'string' ? new Date(date) : date;
    return d.toLocaleDateString('de-DE', {
        weekday: 'short',
        day: '2-digit',
        month: '2-digit',
        year: '2-digit'
    });
}

/**
 * Zeit formatieren
 */
function formatTime(time) {
    if (!time) return '';
    if (typeof time === 'string') {
        // Bereits im Format "HH:MM" oder "HH:MM:SS"
        return time.substring(0, 5);
    }
    const d = new Date(time);
    return d.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

/**
 * Status-CSS-Klasse ermitteln
 */
function getStatusClass(status) {
    switch ((status || '').toLowerCase()) {
        case 'offen':
            return 'status-offen';
        case 'teilbesetzt':
            return 'status-teilbesetzt';
        case 'besetzt':
            return 'status-besetzt';
        case 'abgesagt':
            return 'status-abgesagt';
        case 'in planung':
            return 'status-inplanung';
        default:
            return '';
    }
}

/**
 * MA-Zaehler CSS-Klasse ermitteln
 */
function getMaClass(soll, ist) {
    if (soll === 0) return '';
    if (ist >= soll) return 'ok';
    if (ist > 0) return 'warn';
    return 'err';
}

/**
 * HTML escapen
 */
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ============================================
// GLOBALE FUNKTIONEN (fuer onclick im HTML)
// ============================================

window.btnAktualisieren_Click = btnAktualisieren_Click;
window.btnHeute_Click = btnHeute_Click;
window.btnZurueck_Click = btnZurueck_Click;
window.btnVor_Click = btnVor_Click;
window.btnExportExcel_Click = btnExportExcel_Click;
window.btnDrucken_Click = btnDrucken_Click;
window.chkNurAktive_Change = chkNurAktive_Change;
window.cboGruppierung_Change = cboGruppierung_Change;
window.setQuickFilter = setQuickFilter;
window.sortTable = sortTable;
window.closeForm = closeForm;
window.navigateToForm = navigateToForm;

// ============================================
// INIT BEI DOM READY
// ============================================

document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff fuer Debugging
window.Einsatzuebersicht = {
    state,
    loadEinsaetze,
    applyFiltersAndRender,
    openAuftragstamm
};
