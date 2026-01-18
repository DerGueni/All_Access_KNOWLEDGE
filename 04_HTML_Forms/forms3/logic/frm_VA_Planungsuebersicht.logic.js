/**
 * frm_VA_Planungsuebersicht.logic.js
 * Logik für Planungsübersicht
 * REST-API Anbindung an localhost:5000
 *
 * Features:
 * - DblClick auf Zeile: Öffnet Auftragstamm
 * - DblClick auf MA-Zelle: Öffnet Schnellauswahl
 * - DblClick auf Tag-Header: Setzt Startdatum
 * - Entf-Taste: Löscht MA-Zuordnung
 * - Navigation: ±3 Tage (wie Access)
 */

import { Bridge } from '../api/bridgeClient.js';

// State
const state = {
    records: [],
    selectedRecord: null,
    selectedZuoId: null,  // Für Entf-Taste Löschung
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

    // Navigation ±3 Tage (wie Access)
    elements.btnVorwoche.addEventListener('click', () => {
        const neuesDatum = new Date(state.filters.von);
        neuesDatum.setDate(neuesDatum.getDate() - 3);  // Access macht -3, nicht -7
        elements.datStartdatum.value = formatDate(neuesDatum);
        state.filters.von = neuesDatum;
        const bis = new Date(neuesDatum);
        bis.setDate(bis.getDate() + 6);
        state.filters.bis = bis;
        loadData();
    });

    elements.btnNachwoche.addEventListener('click', () => {
        const neuesDatum = new Date(state.filters.von);
        neuesDatum.setDate(neuesDatum.getDate() + 3);  // Access macht +3, nicht +7
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

    // Tag-Header DblClick: Setzt Startdatum auf diesen Tag
    setupTagHeaderDblClick();

    // Entf-Taste für Zuordnungs-Löschung
    setupDeleteKeyHandler();
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

        // Tages-Header setzen
        updateDayHeaders();

        // Planungsdaten laden (Aufträge mit Schichten)
        // Access-SQL: Mehrfache JOINs benötigen Klammerung
        // Erweitert um IDs für DblClick-Funktionen
        const result = await Bridge.query(`
            SELECT
                a.ID AS VA_ID,
                a.Objekt,
                a.Ort AS VA_Ort,
                a.Kun_Firma,
                d.ID AS VADatum_ID,
                d.VADatum,
                s.ID AS VAStart_ID,
                s.VA_Start,
                s.VA_Ende,
                s.MA_Anzahl,
                s.MA_Anzahl_Ist,
                p.ID AS Zuo_ID,
                m.ID AS MA_ID,
                m.Nachname AS MA_Nachname,
                m.Vorname AS MA_Vorname
            FROM (((tbl_VA_Auftragstamm AS a
                INNER JOIN tbl_VA_AnzTage AS d ON a.ID = d.VA_ID)
                LEFT JOIN tbl_VA_Start AS s ON s.VADatum_ID = d.ID)
                LEFT JOIN tbl_MA_VA_Planung AS p ON s.ID = p.VAStart_ID)
                LEFT JOIN tbl_MA_Mitarbeiterstamm AS m ON p.MA_ID = m.ID
            WHERE d.VADatum >= CDate('${von}') AND d.VADatum <= CDate('${bis}')
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
 * Erweitert um IDs für DblClick-Funktionen
 */
function groupByAuftrag(data) {
    const grouped = new Map();

    data.forEach(row => {
        const key = row.VA_ID;

        if (!grouped.has(key)) {
            grouped.set(key, {
                VA_ID: row.VA_ID,
                Objekt: row.Objekt || '',
                Ort: row.VA_Ort || '',
                Kunde: row.Kun_Firma || '',
                tage: {}
            });
        }

        const auftrag = grouped.get(key);
        const datum = row.VADatum;

        if (datum && row.VA_Start) {
            if (!auftrag.tage[datum]) {
                auftrag.tage[datum] = [];
            }

            // Zeit formatieren (von datetime zu HH:MM)
            const formatTime = (dt) => {
                if (!dt) return '';
                const d = new Date(dt);
                return d.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
            };

            auftrag.tage[datum].push({
                von: formatTime(row.VA_Start),
                bis: formatTime(row.VA_Ende),
                ma_name: row.MA_Nachname && row.MA_Vorname
                    ? `${row.MA_Nachname}, ${row.MA_Vorname.charAt(0)}.`
                    : '',
                soll: row.MA_Anzahl || 0,
                ist: row.MA_Anzahl_Ist || 0,
                // IDs für DblClick-Funktionen
                vadatum_id: row.VADatum_ID || '',
                vastart_id: row.VAStart_ID || '',
                zuo_id: row.Zuo_ID || '',
                ma_id: row.MA_ID || ''
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
        // Erste Zeile: Auftraginfo mit data-va-id für DblClick
        let html = `<tr class="dp-row auftrag-row" data-index="${idx}" data-va-id="${auftrag.VA_ID}">`;
        html += `<td class="col-auftrag" rowspan="2" style="vertical-align:top;padding:5px;">`;
        html += `<strong>${auftrag.VA_ID}</strong><br>`;
        html += `${auftrag.Objekt}<br>`;
        html += `<small>${auftrag.Ort}</small>`;
        html += `</td>`;

        // Für jeden Tag: MA-Zelle mit DblClick für Schnellauswahl
        tageArray.forEach((datum, dayIdx) => {
            const schichten = auftrag.tage[datum] || [];
            const vadatumId = schichten[0]?.vadatum_id || '';
            const zuoId = schichten[0]?.zuo_id || '';

            html += `<td class="ma-zelle ma-name"
                        data-vadatum-id="${vadatumId}"
                        data-zuo-id="${zuoId}"
                        data-day="${dayIdx}"
                        style="padding:2px;font-size:9px;border-right:1px solid #ccc;">`;
            schichten.forEach(s => {
                if (s.ma_name) {
                    html += `<span class="ma-eintrag" data-zuo-id="${s.zuo_id || ''}">${s.ma_name}</span><br>`;
                }
            });
            if (schichten.length === 0 || !schichten.some(s => s.ma_name)) {
                html += `<span class="ma-leer" style="color:#999;">&nbsp;</span>`;
            }
            html += `</td>`;

            // von/bis Spalten
            html += `<td class="zeit" style="padding:2px;font-size:9px;text-align:center;">`;
            schichten.forEach(s => {
                if (s.von) html += `${s.von}<br>`;
            });
            html += `</td>`;
            html += `<td class="zeit" style="padding:2px;font-size:9px;text-align:center;border-right:2px solid #999;">`;
            schichten.forEach(s => {
                if (s.bis) html += `${s.bis}<br>`;
            });
            html += `</td>`;
        });

        html += `</tr>`;

        return html;
    }).join('');

    elements.lblAnzAuftraege.textContent = `${filtered.length} Aufträge`;

    // DblClick-Handler nach dem Rendern einrichten
    setupAuftragDblClick();
    setupMaZuordnungDblClick();
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

// ============================================================
// DBLCLICK-FUNKTIONEN (Access-Parität)
// ============================================================

/**
 * DblClick auf Auftrags-Zeile: Öffnet Auftragstamm
 */
function setupAuftragDblClick() {
    document.querySelectorAll('#tbody_Planung tr[data-va-id]').forEach(row => {
        row.addEventListener('dblclick', (e) => {
            // Ignorieren wenn auf MA-Zelle geklickt
            if (e.target.classList.contains('ma-zelle')) return;

            const vaId = row.dataset.vaId;
            if (vaId) {
                console.log('[Planungsübersicht] Öffne Auftragstamm für VA_ID:', vaId);
                const url = 'frm_va_Auftragstamm.html?va_id=' + vaId;
                if (window.parent && window.parent.loadFormInShell) {
                    window.parent.loadFormInShell(url);
                } else {
                    window.location.href = url;
                }
            }
        });
        row.style.cursor = 'pointer';
    });
}

/**
 * DblClick auf MA-Zelle: Öffnet Schnellauswahl für diese Schicht
 */
function setupMaZuordnungDblClick() {
    document.querySelectorAll('.ma-zelle').forEach(cell => {
        cell.addEventListener('dblclick', (e) => {
            e.stopPropagation(); // Verhindert Auftrag-DblClick

            const vadatumId = cell.dataset.vadatumId;
            const vaId = cell.closest('tr')?.dataset.vaId;

            if (vadatumId && vaId) {
                console.log('[Planungsübersicht] Öffne Schnellauswahl für VA_ID:', vaId, 'VADatum_ID:', vadatumId);
                const url = `frm_MA_VA_Schnellauswahl.html?va_id=${vaId}&vadatum_id=${vadatumId}`;
                if (window.parent && window.parent.loadFormInShell) {
                    window.parent.loadFormInShell(url);
                } else {
                    window.location.href = url;
                }
            }
        });

        // Click für Selektion (für Entf-Taste)
        cell.addEventListener('click', (e) => {
            // Vorherige Selektion entfernen
            document.querySelectorAll('.ma-zelle.selected').forEach(c => c.classList.remove('selected'));

            // Neue Selektion
            cell.classList.add('selected');
            state.selectedZuoId = cell.dataset.zuoId || null;
            console.log('[Planungsübersicht] MA-Zelle selektiert, ZuoID:', state.selectedZuoId);
        });
    });
}

/**
 * Tag-Header DblClick: Setzt Startdatum auf diesen Tag
 */
function setupTagHeaderDblClick() {
    document.querySelectorAll('.tag-header').forEach((header) => {
        header.addEventListener('dblclick', () => {
            const offset = parseInt(header.dataset.dayOffset) || 0;
            const start = new Date(state.filters.von);
            start.setDate(start.getDate() + offset);

            console.log('[Planungsübersicht] Setze Startdatum auf:', formatDate(start));
            elements.datStartdatum.value = formatDate(start);
            state.filters.von = start;

            const bis = new Date(start);
            bis.setDate(bis.getDate() + 6);
            state.filters.bis = bis;

            loadData();
        });
    });
}

/**
 * Entf-Taste: Löscht selektierte MA-Zuordnung
 */
function setupDeleteKeyHandler() {
    document.addEventListener('keydown', async (e) => {
        if (e.key === 'Delete' && state.selectedZuoId) {
            if (confirm('Zuordnung wirklich löschen?')) {
                try {
                    console.log('[Planungsübersicht] Lösche Zuordnung:', state.selectedZuoId);
                    const response = await fetch(`http://localhost:5000/api/zuordnungen/${state.selectedZuoId}`, {
                        method: 'DELETE'
                    });

                    if (response.ok) {
                        setStatus('Zuordnung gelöscht');
                        state.selectedZuoId = null;
                        await loadData();
                    } else {
                        const error = await response.json();
                        setStatus('Fehler: ' + (error.message || 'Löschen fehlgeschlagen'));
                    }
                } catch (err) {
                    console.error('[Planungsübersicht] Löschen fehlgeschlagen:', err);
                    setStatus('Fehler: ' + err.message);
                }
            }
        }
    });
}

/**
 * Navigation ±3 Tage (globale Funktionen für onclick im HTML)
 */
window.navigateVor = function() {
    const start = new Date(elements.datStartdatum.value);
    start.setDate(start.getDate() + 3); // Access macht +3, nicht +7
    elements.datStartdatum.value = formatDate(start);
    state.filters.von = start;
    const bis = new Date(start);
    bis.setDate(bis.getDate() + 6);
    state.filters.bis = bis;
    loadData();
};

window.navigateZurueck = function() {
    const start = new Date(elements.datStartdatum.value);
    start.setDate(start.getDate() - 3); // Access macht -3, nicht -7
    elements.datStartdatum.value = formatDate(start);
    state.filters.von = start;
    const bis = new Date(start);
    bis.setDate(bis.getDate() + 6);
    state.filters.bis = bis;
    loadData();
};

// ============================================================
// INITIALISIERUNG
// ============================================================

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.Planungsuebersicht = {
    loadData,
    exportData,
    navigateVor: window.navigateVor,
    navigateZurueck: window.navigateZurueck
};
