/**
 * frm_Einsatzuebersicht.logic.js
 * Logik für Einsatzübersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../api/bridgeClient.js';

// State
const state = {
    records: [],
    selectedRecord: null,
    datum: new Date(),
    filters: {
        objekt: '',
        kunde: '',
        status: ''
    }
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Einsatzübersicht] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Filter
        datTag: document.getElementById('datTag'),
        cboObjekt: document.getElementById('cboObjekt'),
        cboKunde: document.getElementById('cboKunde'),
        cboStatus: document.getElementById('cboStatus'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        btnExport: document.getElementById('btnExport'),

        // Statistik
        statGesamt: document.getElementById('statGesamt'),
        statBesetzt: document.getElementById('statBesetzt'),
        statTeilweise: document.getElementById('statTeilweise'),
        statOffen: document.getElementById('statOffen'),
        statMASoll: document.getElementById('statMASoll'),
        statMAIst: document.getElementById('statMAIst'),

        // Tabelle
        tbody: document.getElementById('tbody_Einsaetze'),

        // Detail
        detailPanel: document.getElementById('detailPanel'),
        btnCloseDetail: document.getElementById('btnCloseDetail'),
        btnOeffnen: document.getElementById('btnOeffnen'),
        btnMAZuordnen: document.getElementById('btnMAZuordnen'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl'),
        lblDatum: document.getElementById('lblDatum')
    };

    // Heute setzen
    elements.datTag.value = formatDate(state.datum);
    updateDatumAnzeige();

    // Event Listener
    setupEventListeners();

    // Filter laden
    await Promise.all([loadObjekte(), loadKunden()]);

    // Daten laden
    await loadData();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    elements.datTag.addEventListener('change', (e) => {
        state.datum = new Date(e.target.value);
        updateDatumAnzeige();
        loadData();
    });

    elements.cboObjekt.addEventListener('change', (e) => {
        state.filters.objekt = e.target.value;
        renderTable();
        updateStats();
    });

    elements.cboKunde.addEventListener('change', (e) => {
        state.filters.kunde = e.target.value;
        renderTable();
        updateStats();
    });

    elements.cboStatus.addEventListener('change', (e) => {
        state.filters.status = e.target.value;
        renderTable();
        updateStats();
    });

    elements.btnAktualisieren.addEventListener('click', loadData);
    elements.btnExport.addEventListener('click', exportData);

    // Detail
    elements.btnCloseDetail.addEventListener('click', closeDetail);
    elements.btnOeffnen.addEventListener('click', openAuftrag);
    elements.btnMAZuordnen.addEventListener('click', zuordnenMA);

    // Keyboard Navigation
    document.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft') {
            changeDatum(-1);
        } else if (e.key === 'ArrowRight') {
            changeDatum(1);
        }
    });
}

/**
 * Datum formatieren
 */
function formatDate(date) {
    return date.toISOString().split('T')[0];
}

/**
 * Datum-Anzeige aktualisieren
 */
function updateDatumAnzeige() {
    const options = { weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric' };
    elements.lblDatum.textContent = state.datum.toLocaleDateString('de-DE', options);
}

/**
 * Datum ändern
 */
function changeDatum(delta) {
    state.datum.setDate(state.datum.getDate() + delta);
    elements.datTag.value = formatDate(state.datum);
    updateDatumAnzeige();
    loadData();
}

/**
 * Objekte laden
 */
async function loadObjekte() {
    try {
        const result = await Bridge.query(`
            SELECT DISTINCT Objekt
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
        console.error('[Einsatzübersicht] Fehler beim Laden der Objekte:', error);
    }
}

/**
 * Kunden laden
 */
async function loadKunden() {
    try {
        const result = await Bridge.kunden.list();

        const kunden = result.data || [];

        elements.cboKunde.innerHTML = '<option value="">Alle Kunden</option>';
        kunden.forEach(k => {
            const option = document.createElement('option');
            option.value = k.KD_ID || k.kun_Id;
            option.textContent = k.KD_Name1 || k.kun_Firma;
            elements.cboKunde.appendChild(option);
        });

    } catch (error) {
        console.error('[Einsatzübersicht] Fehler beim Laden der Kunden:', error);
    }
}

/**
 * Daten laden
 */
async function loadData() {
    setStatus('Lade Einsätze...');

    try {
        const datum = formatDate(state.datum);

        // Einsätze für den Tag laden
        const result = await Bridge.einsatztage.list({
            von: datum,
            bis: datum,
            mitDetails: true
        });

        state.records = (result.data || []).map(rec => ({
            ID: rec.VAS_ID || rec.ID,
            VA_ID: rec.VA_ID,
            Start: rec.VA_Start || '08:00',
            Ende: rec.VA_Ende || '16:00',
            Objekt: rec.Objekt || '',
            Kunde: rec.Kunde || rec.kun_Firma || '',
            KundeID: rec.Veranstalter_ID || rec.KD_ID,
            MA_Soll: rec.MA_Anzahl || rec.MA_Soll || 0,
            MA_Ist: rec.MA_Anzahl_Ist || rec.MA_Ist || 0,
            Mitarbeiter: rec.Mitarbeiter || []
        }));

        // Sortieren nach Startzeit
        state.records.sort((a, b) => a.Start.localeCompare(b.Start));

        // Mitarbeiter-Details nachladen
        await loadMitarbeiterDetails();

        renderTable();
        updateStats();

        setStatus(`${state.records.length} Einsätze geladen`);
        elements.lblAnzahl.textContent = `${state.records.length} Einsätze`;

    } catch (error) {
        console.error('[Einsatzübersicht] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Mitarbeiter-Details nachladen
 */
async function loadMitarbeiterDetails() {
    for (const rec of state.records) {
        try {
            const result = await Bridge.zuordnungen.list({
                vas_id: rec.ID
            });

            rec.Mitarbeiter = (result.data || []).map(ma => ({
                ID: ma.MA_ID,
                Name: ma.MA_Name || `${ma.MA_Nachname || ''}, ${ma.MA_Vorname || ''}`,
                Status: ma.MVP_Status || 'Zugesagt'
            }));

        } catch (error) {
            console.error(`[Einsatzübersicht] Fehler bei MA für ${rec.ID}:`, error);
            rec.Mitarbeiter = [];
        }
    }
}

/**
 * Gefilterte Datensätze
 */
function getFilteredRecords() {
    return state.records.filter(rec => {
        if (state.filters.objekt && rec.Objekt !== state.filters.objekt) return false;
        if (state.filters.kunde && rec.KundeID != state.filters.kunde) return false;

        if (state.filters.status) {
            const status = getStatus(rec);
            if (state.filters.status !== status) return false;
        }

        return true;
    });
}

/**
 * Status ermitteln
 */
function getStatus(rec) {
    if (rec.MA_Ist >= rec.MA_Soll && rec.MA_Soll > 0) return 'besetzt';
    if (rec.MA_Ist > 0 && rec.MA_Ist < rec.MA_Soll) return 'teilweise';
    return 'offen';
}

/**
 * Tabelle rendern
 */
function renderTable() {
    const filtered = getFilteredRecords();

    if (filtered.length === 0) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="7" class="loading-cell">
                    Keine Einsätze gefunden
                </td>
            </tr>
        `;
        return;
    }

    elements.tbody.innerHTML = filtered.map((rec, idx) => {
        const zeit = `${rec.Start} - ${rec.Ende}`;
        const status = getStatus(rec);

        // MA-Pills erstellen
        let maPills = '';
        if (rec.Mitarbeiter && rec.Mitarbeiter.length > 0) {
            maPills = rec.Mitarbeiter.map(ma => {
                const statusClass = ma.Status === 'Zugesagt' ? 'status-ok' :
                                   ma.Status === 'Anfrage' ? 'status-anfrage' :
                                   ma.Status === 'Absage' ? 'status-absage' : '';
                return `<span class="ma-pill ${statusClass}">${ma.Name}</span>`;
            }).join('');
        } else {
            maPills = '<span style="color:#999;">-</span>';
        }

        const rowClass = status === 'offen' ? 'status-offen' :
                        status === 'teilweise' ? 'status-teilweise' : '';

        return `
            <tr data-index="${idx}" class="${rowClass}">
                <td class="col-zeit">${zeit}</td>
                <td class="col-objekt">${rec.Objekt}</td>
                <td class="col-kunde">${rec.Kunde}</td>
                <td class="col-ma">${rec.MA_Soll}</td>
                <td class="col-ma">${rec.MA_Ist}</td>
                <td class="col-status">
                    <span class="status-badge ${status}">
                        ${status === 'besetzt' ? 'Besetzt' :
                          status === 'teilweise' ? 'Teilweise' : 'Offen'}
                    </span>
                </td>
                <td class="col-mitarbeiter">
                    <div class="ma-pills">${maPills}</div>
                </td>
            </tr>
        `;
    }).join('');

    // Click-Handler
    elements.tbody.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            const idx = parseInt(row.dataset.index);
            selectRow(idx);
        });
    });

    elements.lblAnzahl.textContent = `${filtered.length} Einsätze`;
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

    let besetzt = 0, teilweise = 0, offen = 0;
    let maSoll = 0, maIst = 0;

    filtered.forEach(rec => {
        const status = getStatus(rec);
        if (status === 'besetzt') besetzt++;
        else if (status === 'teilweise') teilweise++;
        else offen++;

        maSoll += rec.MA_Soll || 0;
        maIst += rec.MA_Ist || 0;
    });

    elements.statGesamt.textContent = filtered.length;
    elements.statBesetzt.textContent = besetzt;
    elements.statTeilweise.textContent = teilweise;
    elements.statOffen.textContent = offen;
    elements.statMASoll.textContent = maSoll;
    elements.statMAIst.textContent = maIst;
}

/**
 * Detail anzeigen
 */
async function showDetail(record) {
    state.selectedRecord = record;

    // Felder füllen
    document.getElementById('detailAuftrag').textContent = record.VA_ID || '-';
    document.getElementById('detailObjekt').textContent = record.Objekt || '-';
    document.getElementById('detailKunde').textContent = record.Kunde || '-';
    document.getElementById('detailZeit').textContent = `${record.Start} - ${record.Ende}`;
    document.getElementById('detailSoll').textContent = record.MA_Soll;
    document.getElementById('detailIst').textContent = record.MA_Ist;

    const fehlend = record.MA_Soll - record.MA_Ist;
    const fehlendEl = document.getElementById('detailFehlend');
    fehlendEl.textContent = fehlend > 0 ? fehlend : '0';
    fehlendEl.style.color = fehlend > 0 ? '#d9534f' : '#5cb85c';

    // Zugeordnete MA anzeigen
    const maListe = document.getElementById('detailMAListe');
    if (record.Mitarbeiter && record.Mitarbeiter.length > 0) {
        maListe.innerHTML = record.Mitarbeiter.map(ma => {
            const statusClass = ma.Status === 'Zugesagt' ? 'ok' :
                               ma.Status === 'Anfrage' ? 'anfrage' : '';
            return `
                <li>
                    <span>${ma.Name}</span>
                    <span class="ma-status ${statusClass}">${ma.Status}</span>
                </li>
            `;
        }).join('');
    } else {
        maListe.innerHTML = '<li>Keine Mitarbeiter zugeordnet</li>';
    }

    // Verfügbare MA laden
    await loadVerfuegbareMA(record);

    elements.detailPanel.style.display = 'flex';
}

/**
 * Verfügbare Mitarbeiter laden
 */
async function loadVerfuegbareMA(record) {
    const liste = document.getElementById('detailVerfuegbar');
    liste.innerHTML = '<li>Wird geladen...</li>';

    try {
        const result = await Bridge.verfuegbarkeit.check({
            datum: formatDate(state.datum),
            start: record.Start,
            ende: record.Ende
        });

        const verfuegbar = result.data || [];

        // Bereits zugeordnete MA ausfiltern
        const zugeordnetIDs = (record.Mitarbeiter || []).map(m => m.ID);
        const filtered = verfuegbar.filter(ma => !zugeordnetIDs.includes(ma.MA_ID));

        if (filtered.length === 0) {
            liste.innerHTML = '<li>Keine verfügbaren Mitarbeiter</li>';
        } else {
            liste.innerHTML = filtered.map(ma => `
                <li data-ma-id="${ma.MA_ID}">
                    <span>${ma.MA_Nachname}, ${ma.MA_Vorname}</span>
                    <span class="ma-status">verfügbar</span>
                </li>
            `).join('');

            // Click-Handler für Zuordnung
            liste.querySelectorAll('li').forEach(li => {
                li.addEventListener('click', () => {
                    const maId = li.dataset.maId;
                    if (maId) {
                        assignMA(maId, record);
                    }
                });
            });
        }

    } catch (error) {
        console.error('[Einsatzübersicht] Fehler:', error);
        liste.innerHTML = '<li>Fehler beim Laden</li>';
    }
}

/**
 * MA zuordnen
 */
async function assignMA(maId, record) {
    try {
        await Bridge.execute('createZuordnung', {
            VA_ID: record.VA_ID,
            VAStart_ID: record.ID,
            MA_ID: maId,
            VADatum: formatDate(state.datum),
            Status: 'Anfrage'
        });

        setStatus('Mitarbeiter zugeordnet');

        // Daten neu laden
        await loadData();

        // Detail aktualisieren
        const updatedRecord = state.records.find(r => r.ID === record.ID);
        if (updatedRecord) {
            showDetail(updatedRecord);
        }

    } catch (error) {
        console.error('[Einsatzübersicht] Fehler bei Zuordnung:', error);
        alert('Fehler bei der Zuordnung: ' + error.message);
    }
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
 * MA zuordnen (Button)
 */
function zuordnenMA() {
    if (!state.selectedRecord) return;

    // Liste der verfügbaren MA anzeigen (scroll dorthin)
    const liste = document.getElementById('detailVerfuegbar');
    liste.scrollIntoView({ behavior: 'smooth' });
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

    const datumStr = state.datum.toLocaleDateString('de-DE');

    const headers = ['Zeit', 'Objekt', 'Kunde', 'MA Soll', 'MA Ist', 'Status', 'Mitarbeiter'];
    const rows = filtered.map(rec => {
        const maNames = (rec.Mitarbeiter || []).map(m => m.Name).join(', ');
        return [
            `${rec.Start} - ${rec.Ende}`,
            rec.Objekt,
            rec.Kunde,
            rec.MA_Soll,
            rec.MA_Ist,
            getStatus(rec),
            maNames
        ];
    });

    const csv = [headers, ...rows]
        .map(row => row.map(cell => `"${cell}"`).join(';'))
        .join('\n');

    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Einsatzuebersicht_${formatDate(state.datum)}.csv`;
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
window.Einsatzuebersicht = {
    loadData,
    changeDatum,
    exportData
};
