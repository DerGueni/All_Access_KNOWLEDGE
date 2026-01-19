/**
 * frm_VA_Planungsuebersicht.logic.js
 * Logik für Planungsübersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../js/webview2-bridge.js';

// State
const state = {
    records: [],
    selectedRecord: null,
    filters: {
        von: null,
        bis: null,
        status: '',
        objekt: ''
    }
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Planungsübersicht] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Filter
        datVon: document.getElementById('datVon'),
        datBis: document.getElementById('datBis'),
        cboStatus: document.getElementById('cboStatus'),
        cboObjekt: document.getElementById('cboObjekt'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        btnExport: document.getElementById('btnExport'),

        // Statistik
        statGesamt: document.getElementById('statGesamt'),
        statBesetzt: document.getElementById('statBesetzt'),
        statPlanung: document.getElementById('statPlanung'),
        statOffen: document.getElementById('statOffen'),
        statProbleme: document.getElementById('statProbleme'),

        // Tabelle
        tbody: document.getElementById('tbody_Planung'),

        // Detail
        detailPanel: document.getElementById('detailPanel'),
        btnCloseDetail: document.getElementById('btnCloseDetail'),
        btnOeffnen: document.getElementById('btnOeffnen'),
        btnVerfuegbar: document.getElementById('btnVerfuegbar'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl'),
        lblDatum: document.getElementById('lblDatum')
    };

    // Standard-Zeitraum: heute + 14 Tage
    const heute = new Date();
    const in14Tagen = new Date();
    in14Tagen.setDate(in14Tagen.getDate() + 14);

    elements.datVon.value = formatDate(heute);
    elements.datBis.value = formatDate(in14Tagen);
    state.filters.von = heute;
    state.filters.bis = in14Tagen;

    // Aktuelles Datum anzeigen
    elements.lblDatum.textContent = heute.toLocaleDateString('de-DE', {
        weekday: 'long',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });

    // Event Listener
    setupEventListeners();

    // Objekte laden
    await loadObjekte();

    // Daten laden
    await loadData();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Filter
    elements.datVon.addEventListener('change', (e) => {
        state.filters.von = new Date(e.target.value);
        loadData();
    });

    elements.datBis.addEventListener('change', (e) => {
        state.filters.bis = new Date(e.target.value);
        loadData();
    });

    elements.cboStatus.addEventListener('change', (e) => {
        state.filters.status = e.target.value;
        renderTable();
        updateStats();
    });

    elements.cboObjekt.addEventListener('change', (e) => {
        state.filters.objekt = e.target.value;
        renderTable();
        updateStats();
    });

    elements.btnAktualisieren.addEventListener('click', loadData);
    elements.btnExport.addEventListener('click', exportData);

    // Detail Panel
    elements.btnCloseDetail.addEventListener('click', closeDetail);
    elements.btnOeffnen.addEventListener('click', openAuftrag);
    elements.btnVerfuegbar.addEventListener('click', showVerfuegbareMA);
}

/**
 * Datum formatieren für Input
 */
function formatDate(date) {
    return date.toISOString().split('T')[0];
}

/**
 * Objekte für Filter laden
 */
async function loadObjekte() {
    try {
        const result = await Bridge.query(`
            SELECT DISTINCT VA_ID, Objekt
            FROM tbl_VA_Auftragstamm
            WHERE Objekt IS NOT NULL
            ORDER BY Objekt
        `);

        const objekte = result.data || [];

        elements.cboObjekt.innerHTML = '<option value="">Alle Objekte</option>';
        objekte.forEach(obj => {
            const option = document.createElement('option');
            option.value = obj.Objekt;
            option.textContent = obj.Objekt;
            elements.cboObjekt.appendChild(option);
        });

    } catch (error) {
        console.error('[Planungsübersicht] Fehler beim Laden der Objekte:', error);
    }
}

/**
 * Daten laden
 */
async function loadData() {
    setStatus('Lade Planungsdaten...');

    try {
        const von = formatDate(state.filters.von);
        const bis = formatDate(state.filters.bis);

        // Einsatztage mit Details laden
        const result = await Bridge.einsatztage.list({
            von: von,
            bis: bis,
            mitDetails: true
        });

        state.records = (result.data || []).map(rec => ({
            ID: rec.VAS_ID || rec.ID,
            VA_ID: rec.VA_ID,
            Datum: rec.VADatum || rec.Datum,
            Start: rec.VA_Start || '08:00',
            Ende: rec.VA_Ende || '16:00',
            Objekt: rec.Objekt || rec.VA_Objekt || '',
            Kunde: rec.Kunde || rec.kun_Firma || '',
            MA_Soll: rec.MA_Anzahl || rec.MA_Soll || 0,
            MA_Ist: rec.MA_Anzahl_Ist || rec.MA_Ist || 0,
            Status: berechneStatus(rec),
            Bemerkung: rec.Bemerkung || ''
        }));

        // Sortieren nach Datum
        state.records.sort((a, b) => new Date(a.Datum) - new Date(b.Datum));

        renderTable();
        updateStats();

        setStatus(`${state.records.length} Einträge geladen`);
        elements.lblAnzahl.textContent = `${state.records.length} Einträge`;

    } catch (error) {
        console.error('[Planungsübersicht] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Status berechnen
 */
function berechneStatus(rec) {
    const soll = rec.MA_Anzahl || rec.MA_Soll || 0;
    const ist = rec.MA_Anzahl_Ist || rec.MA_Ist || 0;

    if (ist >= soll && soll > 0) return 'Besetzt';
    if (ist > 0 && ist < soll) return 'Planung';
    if (ist === 0 && soll > 0) return 'Offen';
    return 'Offen';
}

/**
 * Gefilterte Datensätze
 */
function getFilteredRecords() {
    return state.records.filter(rec => {
        if (state.filters.status) {
            if (state.filters.status === 'Problem') {
                if (rec.MA_Ist >= rec.MA_Soll) return false;
            } else if (rec.Status !== state.filters.status) {
                return false;
            }
        }
        if (state.filters.objekt && rec.Objekt !== state.filters.objekt) {
            return false;
        }
        return true;
    });
}

/**
 * Tabelle rendern
 */
function renderTable() {
    const filtered = getFilteredRecords();

    if (filtered.length === 0) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="8" class="loading-cell">
                    Keine Einträge gefunden
                </td>
            </tr>
        `;
        return;
    }

    elements.tbody.innerHTML = filtered.map((rec, idx) => {
        const datum = new Date(rec.Datum).toLocaleDateString('de-DE');
        const zeit = `${rec.Start} - ${rec.Ende}`;

        // Soll/Ist Klasse
        let sollIstClass = 'ok';
        if (rec.MA_Ist < rec.MA_Soll) {
            sollIstClass = rec.MA_Ist === 0 ? 'err' : 'warn';
        }

        // Status Badge
        let statusClass = rec.Status.toLowerCase();
        if (rec.MA_Ist < rec.MA_Soll && rec.MA_Ist > 0) {
            const datumObj = new Date(rec.Datum);
            const heute = new Date();
            heute.setHours(0, 0, 0, 0);
            const diffTage = Math.floor((datumObj - heute) / (1000 * 60 * 60 * 24));
            if (diffTage <= 2) statusClass = 'problem';
        }

        return `
            <tr data-index="${idx}" data-id="${rec.ID}">
                <td class="col-datum">${datum}</td>
                <td class="col-zeit">${zeit}</td>
                <td class="col-objekt">${rec.Objekt}</td>
                <td class="col-kunde">${rec.Kunde}</td>
                <td class="col-soll">${rec.MA_Soll}</td>
                <td class="col-ist soll-ist-cell ${sollIstClass}">${rec.MA_Ist}</td>
                <td class="col-status">
                    <span class="status-badge ${statusClass}">${rec.Status}</span>
                </td>
                <td class="col-aktion">
                    <button class="row-btn btn-detail" data-index="${idx}">Details</button>
                </td>
            </tr>
        `;
    }).join('');

    // Click Handler
    elements.tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', (e) => {
            if (e.target.classList.contains('btn-detail')) {
                const idx = parseInt(e.target.dataset.index);
                showDetail(getFilteredRecords()[idx]);
            } else {
                const idx = parseInt(row.dataset.index);
                selectRow(idx);
            }
        });
    });

    elements.lblAnzahl.textContent = `${filtered.length} Einträge`;
}

/**
 * Zeile auswählen
 */
function selectRow(index) {
    elements.tbody.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    const filtered = getFilteredRecords();
    if (index >= 0 && index < filtered.length) {
        showDetail(filtered[index]);
    }
}

/**
 * Statistik aktualisieren
 */
function updateStats() {
    const filtered = getFilteredRecords();

    let besetzt = 0, planung = 0, offen = 0, probleme = 0;

    filtered.forEach(rec => {
        if (rec.Status === 'Besetzt') besetzt++;
        else if (rec.Status === 'Planung') planung++;
        else if (rec.Status === 'Offen') offen++;

        // Probleme: nicht besetzt und innerhalb 2 Tagen
        if (rec.MA_Ist < rec.MA_Soll) {
            const datumObj = new Date(rec.Datum);
            const heute = new Date();
            heute.setHours(0, 0, 0, 0);
            const diffTage = Math.floor((datumObj - heute) / (1000 * 60 * 60 * 24));
            if (diffTage <= 2) probleme++;
        }
    });

    elements.statGesamt.textContent = filtered.length;
    elements.statBesetzt.textContent = besetzt;
    elements.statPlanung.textContent = planung;
    elements.statOffen.textContent = offen;
    elements.statProbleme.textContent = probleme;
}

/**
 * Detail anzeigen
 */
async function showDetail(record) {
    state.selectedRecord = record;

    // Felder füllen
    document.getElementById('detailAuftrag').textContent = record.VA_ID || '-';
    document.getElementById('detailObjekt').textContent = record.Objekt || '-';
    document.getElementById('detailDatum').textContent =
        new Date(record.Datum).toLocaleDateString('de-DE');
    document.getElementById('detailZeit').textContent =
        `${record.Start} - ${record.Ende}`;
    document.getElementById('detailKunde').textContent = record.Kunde || '-';
    document.getElementById('detailSoll').textContent = record.MA_Soll;
    document.getElementById('detailIst').textContent = record.MA_Ist;
    document.getElementById('detailStatus').textContent = record.Status;

    // Zugeordnete MA laden
    try {
        const result = await Bridge.zuordnungen.list({
            vas_id: record.ID
        });

        const maList = document.getElementById('detailMAListe');
        const mitarbeiter = result.data || [];

        if (mitarbeiter.length === 0) {
            maList.innerHTML = '<li>Keine Mitarbeiter zugeordnet</li>';
        } else {
            maList.innerHTML = mitarbeiter.map(ma => {
                const name = ma.MA_Name || `${ma.MA_Nachname || ''}, ${ma.MA_Vorname || ''}`;
                const status = ma.MVP_Status || '';
                return `<li>${name} ${status ? `(${status})` : ''}</li>`;
            }).join('');
        }

    } catch (error) {
        console.error('[Planungsübersicht] Fehler beim Laden der MA:', error);
        document.getElementById('detailMAListe').innerHTML =
            '<li>Fehler beim Laden</li>';
    }

    elements.detailPanel.style.display = 'flex';
}

/**
 * Detail schließen
 */
function closeDetail() {
    elements.detailPanel.style.display = 'none';
    state.selectedRecord = null;
}

/**
 * Auftrag öffnen
 */
function openAuftrag() {
    if (!state.selectedRecord) return;

    const va_id = state.selectedRecord.VA_ID;

    if (window.parent !== window) {
        window.parent.postMessage({
            action: 'openAuftrag',
            va_id: va_id
        }, '*');
    } else {
        window.open(`frm_va_Auftragstamm.html?va_id=${va_id}`, '_blank');
    }
}

/**
 * Verfügbare MA anzeigen
 */
async function showVerfuegbareMA() {
    if (!state.selectedRecord) return;

    try {
        const result = await Bridge.verfuegbarkeit.check({
            datum: state.selectedRecord.Datum,
            start: state.selectedRecord.Start,
            ende: state.selectedRecord.Ende
        });

        const ma = result.data || [];

        if (ma.length === 0) {
            alert('Keine verfügbaren Mitarbeiter gefunden');
        } else {
            const liste = ma.map(m => `${m.MA_Nachname}, ${m.MA_Vorname}`).join('\n');
            alert(`Verfügbare Mitarbeiter:\n\n${liste}`);
        }

    } catch (error) {
        console.error('[Planungsübersicht] Fehler:', error);
        alert('Fehler beim Laden der verfügbaren Mitarbeiter');
    }
}

/**
 * Export
 */
function exportData() {
    const filtered = getFilteredRecords();

    if (filtered.length === 0) {
        alert('Keine Daten zum Exportieren');
        return;
    }

    // CSV erstellen
    const headers = ['Datum', 'Zeit', 'Objekt', 'Kunde', 'Soll', 'Ist', 'Status'];
    const rows = filtered.map(rec => [
        new Date(rec.Datum).toLocaleDateString('de-DE'),
        `${rec.Start} - ${rec.Ende}`,
        rec.Objekt,
        rec.Kunde,
        rec.MA_Soll,
        rec.MA_Ist,
        rec.Status
    ]);

    const csv = [headers, ...rows]
        .map(row => row.map(cell => `"${cell}"`).join(';'))
        .join('\n');

    // Download
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Planungsuebersicht_${formatDate(new Date())}.csv`;
    a.click();
    URL.revokeObjectURL(url);

    setStatus('Export abgeschlossen');
}

/**
 * Status setzen
 */
function setStatus(text) {
    elements.lblStatus.textContent = text;
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.Planungsuebersicht = {
    loadData,
    exportData
};
