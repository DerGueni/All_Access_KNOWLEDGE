/**
 * frm_abwesenheitsuebersicht.logic.js
 * Logik für Abwesenheitsübersicht (Kalender-Ansicht)
 * Zeigt Abwesenheiten aller Mitarbeiter in einer Wochenansicht
 */

import { Bridge } from '../api/bridgeClient.js';

// State
const state = {
    currentDate: new Date(), // Aktuelles Datum für Wochenansicht
    selectedMonth: new Date().getMonth() + 1,
    selectedYear: new Date().getFullYear(),
    filterType: '', // Urlaub, Krank, Privat
    mitarbeiterList: [],
    abwesenheiten: [],
    weekStart: null,
    weekEnd: null
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Abwesenheitsübersicht] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Header Navigation
        btnVorwoche: document.getElementById('btnVorwoche'),
        btnNachwoche: document.getElementById('btnNachwoche'),
        btnHeute: document.getElementById('btnHeute'),
        lblWoche: document.getElementById('lblWoche'),

        // Toolbar Filter
        cboMonat: document.getElementById('cboMonat'),
        cboJahr: document.getElementById('cboJahr'),
        cboFilter: document.getElementById('cboFilter'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        btnExport: document.getElementById('btnExport'),
        btnDrucken: document.getElementById('btnDrucken'),

        // Kalender
        calendarGrid: document.getElementById('calendarGrid'),

        // Footer
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    // Event Listener einrichten
    setupEventListeners();

    // Aktuelles Datum auf Monatsbeginn setzen
    setCurrentMonth(state.selectedMonth, state.selectedYear);

    // Mitarbeiter laden
    await loadMitarbeiter();

    // Abwesenheiten laden
    await loadAbwesenheiten();

    // Kalender rendern
    renderCalendar();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Wochen-Navigation
    elements.btnVorwoche.addEventListener('click', () => {
        state.currentDate.setDate(state.currentDate.getDate() - 7);
        loadAbwesenheiten();
        renderCalendar();
    });

    elements.btnNachwoche.addEventListener('click', () => {
        state.currentDate.setDate(state.currentDate.getDate() + 7);
        loadAbwesenheiten();
        renderCalendar();
    });

    elements.btnHeute.addEventListener('click', () => {
        state.currentDate = new Date();
        const month = state.currentDate.getMonth() + 1;
        const year = state.currentDate.getFullYear();
        elements.cboMonat.value = month;
        elements.cboJahr.value = year;
        setCurrentMonth(month, year);
        loadAbwesenheiten();
        renderCalendar();
    });

    // Monats/Jahres-Wechsel
    elements.cboMonat.addEventListener('change', () => {
        const month = parseInt(elements.cboMonat.value);
        const year = parseInt(elements.cboJahr.value);
        setCurrentMonth(month, year);
        loadAbwesenheiten();
        renderCalendar();
    });

    elements.cboJahr.addEventListener('change', () => {
        const month = parseInt(elements.cboMonat.value);
        const year = parseInt(elements.cboJahr.value);
        setCurrentMonth(month, year);
        loadAbwesenheiten();
        renderCalendar();
    });

    // Filter
    elements.cboFilter.addEventListener('change', () => {
        state.filterType = elements.cboFilter.value;
        renderCalendar();
    });

    // Aktionen
    elements.btnAktualisieren.addEventListener('click', () => {
        loadAbwesenheiten();
        renderCalendar();
    });

    elements.btnExport.addEventListener('click', exportToCSV);
    elements.btnDrucken.addEventListener('click', printCalendar);
}

/**
 * Aktuellen Monat setzen
 */
function setCurrentMonth(month, year) {
    state.selectedMonth = month;
    state.selectedYear = year;
    state.currentDate = new Date(year, month - 1, 1);
}

/**
 * Mitarbeiter laden
 */
async function loadMitarbeiter() {
    try {
        setStatus('Lade Mitarbeiter...');

        const result = await Bridge.mitarbeiter.list({ aktiv: true });

        state.mitarbeiterList = (result.data || []).map(ma => ({
            ID: ma.MA_ID || ma.ID,
            Nachname: ma.MA_Nachname || ma.Nachname || '',
            Vorname: ma.MA_Vorname || ma.Vorname || '',
            Name: `${ma.MA_Nachname || ma.Nachname || ''}, ${ma.MA_Vorname || ma.Vorname || ''}`
        })).sort((a, b) => a.Nachname.localeCompare(b.Nachname));

        elements.lblAnzahl.textContent = `${state.mitarbeiterList.length} Mitarbeiter`;

    } catch (error) {
        console.error('[Abwesenheitsübersicht] Fehler beim Laden der Mitarbeiter:', error);
        setStatus('Fehler beim Laden der Mitarbeiter');
    }
}

/**
 * Abwesenheiten für den aktuellen Monat laden
 */
async function loadAbwesenheiten() {
    try {
        setStatus('Lade Abwesenheiten...');

        // Monatsbereich berechnen
        const monthStart = new Date(state.selectedYear, state.selectedMonth - 1, 1);
        const monthEnd = new Date(state.selectedYear, state.selectedMonth, 0);

        const vonDatum = formatDateForAPI(monthStart);
        const bisDatum = formatDateForAPI(monthEnd);

        // Abwesenheiten laden via Bridge
        const result = await Bridge.query(`
            SELECT nv.*, ma.Nachname, ma.Vorname
            FROM tbl_MA_NVerfuegZeiten nv
            LEFT JOIN tbl_MA_Mitarbeiterstamm ma ON nv.MA_ID = ma.ID
            WHERE ma.IstAktiv = -1
              AND (
                (nv.vonDat <= #${bisDatum}# AND nv.bisDat >= #${vonDatum}#)
              )
            ORDER BY ma.Nachname, ma.Vorname, nv.vonDat
        `);

        state.abwesenheiten = (result.data || []).map(rec => ({
            ID: rec.ID,
            MA_ID: rec.MA_ID,
            VonDat: parseDate(rec.vonDat),
            BisDat: parseDate(rec.bisDat),
            Grund: rec.Grund || 'Sonstiges',
            Ganztaegig: rec.Ganztaegig !== false,
            VonZeit: rec.vonZeit,
            BisZeit: rec.bisZeit,
            Bemerkung: rec.Bemerkung || ''
        }));

        setStatus(`${state.abwesenheiten.length} Abwesenheiten geladen`);

    } catch (error) {
        console.error('[Abwesenheitsübersicht] Fehler beim Laden der Abwesenheiten:', error);
        setStatus('Fehler beim Laden der Abwesenheiten');
    }
}

/**
 * Kalender rendern
 */
function renderCalendar() {
    // Wochenbeginn berechnen (Montag)
    const week = getWeekDays(state.currentDate);
    state.weekStart = week[0];
    state.weekEnd = week[6];

    // Wochenlabel aktualisieren
    const weekNum = getWeekNumber(state.currentDate);
    elements.lblWoche.textContent = `KW ${weekNum} (${formatDisplayDate(week[0])} - ${formatDisplayDate(week[6])})`;

    // Kalender-Grid leeren (Header behalten)
    const headerRows = 8; // 1 Header-Zeile mit Mitarbeiter + 7 Tage
    const gridItems = Array.from(elements.calendarGrid.children);

    // Alle Zeilen außer Header entfernen
    while (elements.calendarGrid.children.length > headerRows) {
        elements.calendarGrid.removeChild(elements.calendarGrid.lastChild);
    }

    // Datum-Header aktualisieren
    const dateHeaders = elements.calendarGrid.querySelectorAll('.calendar-header');
    week.forEach((date, idx) => {
        if (idx < 7 && dateHeaders[idx + 1]) { // +1 weil erste Header-Spalte "Mitarbeiter" ist
            const day = date.getDate();
            const weekday = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][idx];
            dateHeaders[idx + 1].innerHTML = `${weekday}<br>${day}.${state.selectedMonth}.`;
        }
    });

    // Mitarbeiter-Zeilen rendern
    let visibleCount = 0;
    state.mitarbeiterList.forEach(ma => {
        // Filter anwenden
        const maAbwesenheiten = state.abwesenheiten.filter(a => a.MA_ID === ma.ID);

        if (state.filterType) {
            const hasFilteredAbsence = maAbwesenheiten.some(a => a.Grund === state.filterType);
            if (!hasFilteredAbsence) return;
        }

        visibleCount++;

        // Mitarbeiter-Zelle
        const maCell = document.createElement('div');
        maCell.className = 'calendar-ma';
        maCell.textContent = ma.Name;
        elements.calendarGrid.appendChild(maCell);

        // Tag-Zellen für diese Woche
        week.forEach(date => {
            const cell = document.createElement('div');
            cell.className = 'calendar-cell';

            // Wochenende markieren
            const dayOfWeek = date.getDay();
            if (dayOfWeek === 0 || dayOfWeek === 6) {
                cell.classList.add('weekend');
            }

            // Abwesenheiten für diesen Tag prüfen
            const absence = getAbsenceForDate(ma.ID, date);
            if (absence) {
                cell.classList.add('absent');

                const grundClass = absence.Grund ? absence.Grund.toLowerCase() : 'sonstiges';
                cell.classList.add(grundClass);

                // Tooltip
                const tooltip = `${absence.Grund}${!absence.Ganztaegig ? ` (${absence.VonZeit || ''}-${absence.BisZeit || ''})` : ''}${absence.Bemerkung ? '\n' + absence.Bemerkung : ''}`;
                cell.title = tooltip;

                // Kurz-Anzeige
                if (!absence.Ganztaegig) {
                    const span = document.createElement('span');
                    span.style.fontSize = '9px';
                    span.textContent = `${absence.VonZeit || ''}-${absence.BisZeit || ''}`;
                    cell.appendChild(span);
                }
            }

            elements.calendarGrid.appendChild(cell);
        });
    });

    elements.lblAnzahl.textContent = `${visibleCount} Mitarbeiter (${state.abwesenheiten.length} Abwesenheiten)`;
}

/**
 * Abwesenheit für bestimmten MA und Datum finden
 */
function getAbsenceForDate(maId, date) {
    const dateOnly = new Date(date);
    dateOnly.setHours(0, 0, 0, 0);

    return state.abwesenheiten.find(a => {
        if (a.MA_ID !== maId) return false;

        const von = new Date(a.VonDat);
        von.setHours(0, 0, 0, 0);
        const bis = new Date(a.BisDat);
        bis.setHours(0, 0, 0, 0);

        return dateOnly >= von && dateOnly <= bis;
    });
}

/**
 * Wochentage für ein Datum ermitteln (Mo-So)
 */
function getWeekDays(date) {
    const current = new Date(date);
    const day = current.getDay();
    const diff = day === 0 ? -6 : 1 - day; // Montag als Wochenstart

    const monday = new Date(current);
    monday.setDate(current.getDate() + diff);
    monday.setHours(0, 0, 0, 0);

    const days = [];
    for (let i = 0; i < 7; i++) {
        const d = new Date(monday);
        d.setDate(monday.getDate() + i);
        days.push(d);
    }

    return days;
}

/**
 * Kalenderwoche berechnen
 */
function getWeekNumber(date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

/**
 * Datum formatieren für Anzeige (DD.MM.YYYY)
 */
function formatDisplayDate(date) {
    const d = date.getDate().toString().padStart(2, '0');
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const y = date.getFullYear();
    return `${d}.${m}.${y}`;
}

/**
 * Datum formatieren für Access-API (#MM/DD/YYYY#)
 */
function formatDateForAPI(date) {
    const m = (date.getMonth() + 1).toString().padStart(2, '0');
    const d = date.getDate().toString().padStart(2, '0');
    const y = date.getFullYear();
    return `${m}/${d}/${y}`;
}

/**
 * Datum-String parsen
 */
function parseDate(dateStr) {
    if (!dateStr) return null;

    // ISO-Format oder deutsches Format
    const date = new Date(dateStr);
    return isNaN(date.getTime()) ? null : date;
}

/**
 * Export zu CSV
 */
function exportToCSV() {
    try {
        let csv = 'Mitarbeiter;Von;Bis;Grund;Ganztägig;Bemerkung\n';

        state.abwesenheiten.forEach(a => {
            const ma = state.mitarbeiterList.find(m => m.ID === a.MA_ID);
            const maName = ma ? ma.Name : 'Unbekannt';
            const von = formatDisplayDate(a.VonDat);
            const bis = formatDisplayDate(a.BisDat);
            const ganztag = a.Ganztaegig ? 'Ja' : 'Nein';

            csv += `"${maName}";"${von}";"${bis}";"${a.Grund}";"${ganztag}";"${a.Bemerkung}"\n`;
        });

        // Download auslösen
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `Abwesenheiten_${state.selectedMonth}_${state.selectedYear}.csv`;
        link.click();

        setStatus('Export erfolgreich');

    } catch (error) {
        console.error('[Abwesenheitsübersicht] Fehler beim Export:', error);
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Export: ' + error.message);
        else alert('Fehler beim Export: ' + error.message);
    }
}

/**
 * Drucken
 */
function printCalendar() {
    window.print();
}

/**
 * Status setzen
 */
function setStatus(text) {
    elements.lblStatus.textContent = text;
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff für Debugging
window.AbwesenheitUebersicht = {
    state,
    loadAbwesenheiten,
    renderCalendar,
    exportToCSV
};
