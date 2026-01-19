/**
 * frm_VA_Planungsuebersicht.logic.js
 * Logik für Planungsübersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../../../api/bridgeClient.js';

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
    if (window.ApiAutostart) {
        await window.ApiAutostart.init();
    }
    console.log('[Planungsübersicht] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Filter
        datStartdatum: document.getElementById('datStartdatum'),
        btnStartdatumAendern: document.getElementById('btnStartdatumAendern'),
        btnVorwoche: document.getElementById('btnVorwoche'),
        btnNachwoche: document.getElementById('btnNachwoche'),
        btnAbHeute: document.getElementById('btnAbHeute'),
        chkNurFreieSchichten: document.getElementById('chkNurFreieSchichten'),
        chkWenigerAls: document.getElementById('chkWenigerAls'),
        txtPositionen: document.getElementById('txtPositionen'),
        btnUebersichtDrucken: document.getElementById('btnUebersichtDrucken'),

        // Tabelle
        tbody: document.getElementById('tbody_Planung'),

        // Tages-Header
        thTag1: document.getElementById('thTag1'),
        thTag2: document.getElementById('thTag2'),
        thTag3: document.getElementById('thTag3'),
        thTag4: document.getElementById('thTag4'),
        thTag5: document.getElementById('thTag5'),
        thTag6: document.getElementById('thTag6'),
        thTag7: document.getElementById('thTag7'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzAuftraege: document.getElementById('lblAnzAuftraege'),
        lblDatum: document.getElementById('lblDatum'),
        lblVersion: document.getElementById('lblVersion')
    };

    // Standard-Zeitraum: heute + 7 Tage
    const heute = new Date();
    heute.setHours(0, 0, 0, 0);

    elements.datStartdatum.value = formatDate(heute);
    state.filters.von = new Date(heute);

    // 7 Tage Bereich
    const bis = new Date(heute);
    bis.setDate(bis.getDate() + 6);
    state.filters.bis = bis;

    // Aktuelles Datum anzeigen
    elements.lblDatum.textContent = heute.toLocaleDateString('de-DE', {
        weekday: 'short',
        day: '2-digit',
        month: '2-digit',
        year: '2-digit'
    });

    // Event Listener
    setupEventListeners();

    // Daten laden
    await loadData();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    elements.btnAbHeute.addEventListener('click', () => {
        const heute = new Date();
        heute.setHours(0, 0, 0, 0);
        elements.datStartdatum.value = formatDate(heute);
        state.filters.von = new Date(heute);
        const bis = new Date(heute);
        bis.setDate(bis.getDate() + 6);
        state.filters.bis = bis;
        loadData();
    });

    elements.btnVorwoche.addEventListener('click', () => {
        const neuesDatum = new Date(state.filters.von);
        neuesDatum.setDate(neuesDatum.getDate() - 7);
        elements.datStartdatum.value = formatDate(neuesDatum);
        state.filters.von = neuesDatum;
        const bis = new Date(neuesDatum);
        bis.setDate(bis.getDate() + 6);
        state.filters.bis = bis;
        loadData();
    });

    elements.btnNachwoche.addEventListener('click', () => {
        const neuesDatum = new Date(state.filters.von);
        neuesDatum.setDate(neuesDatum.getDate() + 7);
        elements.datStartdatum.value = formatDate(neuesDatum);
        state.filters.von = neuesDatum;
        const bis = new Date(neuesDatum);
        bis.setDate(bis.getDate() + 6);
        state.filters.bis = bis;
        loadData();
    });

    elements.btnStartdatumAendern.addEventListener('click', () => {
        const datum = new Date(elements.datStartdatum.value);
        state.filters.von = datum;
        const bis = new Date(datum);
        bis.setDate(bis.getDate() + 6);
        state.filters.bis = bis;
        loadData();
    });

    // Filter
    elements.chkNurFreieSchichten.addEventListener('change', () => {
        renderTable();
    });

    elements.chkWenigerAls.addEventListener('change', () => {
        renderTable();
    });

    elements.txtPositionen.addEventListener('change', () => {
        renderTable();
    });

    // Export
    elements.btnUebersichtDrucken.addEventListener('click', exportData);
    document.getElementById('btnUebers')?.addEventListener('click', exportData);
    document.getElementById('btnHilfe')?.addEventListener('click', () => alert('Hilfe ist derzeit nicht verfügbar.'));
    document.getElementById('Befehl38')?.addEventListener('click', () => {
        if (window.parent !== window) {
            window.parent.postMessage({ type: 'close_form', name: 'frm_VA_Planungsuebersicht' }, '*');
        } else {
            window.close();
        }
    });
}

/**
 * Datum formatieren für Input
 */
function formatDate(date) {
    return date.toISOString().split('T')[0];
}

function formatAccessDate(date) {
    const d = new Date(date);
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    const yyyy = d.getFullYear();
    return `${mm}/${dd}/${yyyy}`;
}

function normalizeDateKey(value) {
    if (!value) return null;
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) return null;
    return formatDate(parsed);
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
        const von = formatAccessDate(state.filters.von);
        const bis = formatAccessDate(state.filters.bis);

        // Tages-Header setzen
        updateDayHeaders();

        // Planungsdaten laden (Aufträge mit Schichten)
        const result = await Bridge.query(`
            SELECT
                a.ID AS VA_ID,
                a.Auftrag,
                a.Objekt,
                a.Ort,
                k.kun_Firma,
                d.ID AS VADatum_ID,
                d.VADatum,
                s.VA_Start,
                s.VA_Ende,
                s.MA_Anzahl,
                s.MA_Anzahl_Ist,
                m.Nachname AS MA_Nachname,
                m.Vorname AS MA_Vorname
            FROM tbl_VA_Auftragstamm a
            LEFT JOIN tbl_KD_Kundenstamm k ON a.Veranstalter_ID = k.kun_Id
            LEFT JOIN tbl_VA_AnzTage d ON a.ID = d.VA_ID
            LEFT JOIN tbl_VA_Start s ON s.VADatum_ID = d.ID
            LEFT JOIN tbl_MA_VA_Planung p ON s.ID = p.VAStart_ID
            LEFT JOIN tbl_MA_Mitarbeiterstamm m ON p.MA_ID = m.ID
            WHERE d.VADatum >= #${von}# AND d.VADatum <= #${bis}#
            ORDER BY a.ID, d.VADatum, s.VA_Start
        `);

        // Daten gruppieren nach Auftrag
        const auftraege = groupByAuftrag(result.data || []);
        state.records = auftraege;

        renderTable();

        setStatus(`${auftraege.length} Aufträge geladen`);
        elements.lblAnzAuftraege.textContent = `${auftraege.length} Aufträge`;

    } catch (error) {
        console.error('[Planungsübersicht] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="22" style="text-align:center;padding:20px;color:#c44;">
                    Fehler beim Laden: ${error.message}
                </td>
            </tr>
        `;
    }
}

/**
 * Tages-Header aktualisieren
 */
function updateDayHeaders() {
    const startDatum = new Date(state.filters.von);

    for (let i = 0; i < 7; i++) {
        const datum = new Date(startDatum);
        datum.setDate(datum.getDate() + i);

        const wochentag = datum.toLocaleDateString('de-DE', { weekday: 'short' });
        const tag = datum.getDate().toString().padStart(2, '0');
        const monat = (datum.getMonth() + 1).toString().padStart(2, '0');
        const jahr = datum.getFullYear().toString().substr(-2);

        const headerText = `${wochentag}. ${tag}.${monat}.${jahr}`;
        const thElement = elements[`thTag${i + 1}`];

        if (thElement) {
            thElement.querySelector('.th-content').textContent = headerText;
        }
    }
}

/**
 * Daten nach Auftrag gruppieren
 */
function groupByAuftrag(data) {
    const grouped = new Map();

    data.forEach(row => {
        const key = row.VA_ID;

        if (!grouped.has(key)) {
            grouped.set(key, {
                VA_ID: row.VA_ID,
                Objekt: row.Objekt || '',
                Ort: row.Ort || '',
                Kunde: row.kun_Firma || '',
                tage: {}
            });
        }

        const auftrag = grouped.get(key);
        const datumKey = normalizeDateKey(row.VADatum);
        if (!datumKey) return;

        if (!auftrag.tage[datumKey]) {
            auftrag.tage[datumKey] = [];
        }

        const von = row.VA_Start || '';
        const bis = row.VA_Ende || '';
        const maName = row.MA_Nachname && row.MA_Vorname
            ? `${row.MA_Nachname}, ${row.MA_Vorname.charAt(0)}.`
            : '';

        if (von || bis || maName) {
            auftrag.tage[datumKey].push({
                von,
                bis,
                ma_name: maName,
                soll: row.MA_Anzahl || 0,
                ist: row.MA_Anzahl_Ist || 0
            });
        }
    });

    return Array.from(grouped.values());
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
    return state.records.filter(auftrag => {
        // Filter: Nur freie Schichten
        if (elements.chkNurFreieSchichten.checked) {
            let hatFreieSchichten = false;
            Object.values(auftrag.tage).forEach(schichten => {
                schichten.forEach(s => {
                    if (!s.ma_name || s.ist < s.soll) {
                        hatFreieSchichten = true;
                    }
                });
            });
            if (!hatFreieSchichten) return false;
        }

        // Filter: Weniger als X Positionen
        if (elements.chkWenigerAls.checked) {
            const maxPositionen = parseInt(elements.txtPositionen.value) || 25;
            const anzahlPositionen = Object.keys(auftrag.tage).length;
            if (anzahlPositionen >= maxPositionen) return false;
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
                <td colspan="22" style="text-align:center;padding:40px;color:#666;">
                    Keine Aufträge gefunden
                </td>
            </tr>
        `;
        return;
    }

    // 7 Tage Array erstellen
    const tageArray = [];
    for (let i = 0; i < 7; i++) {
        const datum = new Date(state.filters.von);
        datum.setDate(datum.getDate() + i);
        tageArray.push(formatDate(datum));
    }

    elements.tbody.innerHTML = filtered.map((auftrag, idx) => {
        let html = `<tr data-index="${idx}">`;
        html += `<td style="vertical-align:top;padding:5px;">`;
        html += `<strong>${auftrag.VA_ID}</strong><br>`;
        html += `${auftrag.Objekt}<br>`;
        html += `<small>${auftrag.Ort}</small>`;
        html += `</td>`;

        tageArray.forEach(datum => {
            const schichten = auftrag.tage[datum] || [];
            const names = schichten.map(s => s.ma_name || '').filter(Boolean).join('<br>');
            const von = schichten.map(s => s.von || '').filter(Boolean).join('<br>');
            const bis = schichten.map(s => s.bis || '').filter(Boolean).join('<br>');

            html += `<td style="padding:2px;font-size:9px;border-right:1px solid #ccc;">${names}</td>`;
            html += `<td style="padding:2px;font-size:9px;text-align:center;border-right:1px solid #ccc;">${von}</td>`;
            html += `<td style="padding:2px;font-size:9px;text-align:center;border-right:2px solid #999;">${bis}</td>`;
        });

        html += `</tr>`;
        return html;
    }).join('');

    elements.lblAnzAuftraege.textContent = `${filtered.length} Aufträge`;
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
