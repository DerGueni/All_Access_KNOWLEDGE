/**
 * frm_N_Dienstplanuebersicht.logic.js
 * Logik für Dienstplanübersicht (Kalenderansicht)
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../js/webview2-bridge.js';

// State
const state = {
    currentWeekStart: null,  // Montag der aktuellen Woche
    einsaetze: [],
    selectedEinsatz: null,
    filters: {
        ansicht: 'alle',
        objekt: '',
        status: ''
    }
};

// DOM-Elemente
let elements = {};

// Konstanten
const HOUR_HEIGHT = 40;  // Pixel pro Stunde
const START_HOUR = 6;    // Erste Stunde im Kalender
const END_HOUR = 22;     // Letzte Stunde im Kalender

/**
 * Initialisierung
 */
async function init() {
    console.log('[Dienstplanübersicht] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Navigation
        btnVorwoche: document.getElementById('btnVorwoche'),
        btnNachwoche: document.getElementById('btnNachwoche'),
        btnHeute: document.getElementById('btnHeute'),
        lblWoche: document.getElementById('lblWoche'),
        datePicker: document.getElementById('datePicker'),

        // Filter
        cboAnsicht: document.getElementById('cboAnsicht'),
        cboObjekt: document.getElementById('cboObjekt'),
        cboStatus: document.getElementById('cboStatus'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),

        // Kalender
        calendarHeader: document.getElementById('calendarHeader'),
        calendarBody: document.getElementById('calendarBody'),

        // Detail Panel
        detailPanel: document.getElementById('detailPanel'),
        btnCloseDetail: document.getElementById('btnCloseDetail'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzEinsaetze: document.getElementById('lblAnzEinsaetze')
    };

    // Event Listener
    setupEventListeners();

    // Aktuelle Woche setzen (Montag)
    state.currentWeekStart = getMonday(new Date());

    // Objekt-Filter laden
    await loadObjekte();

    // Kalender aufbauen
    renderCalendarStructure();

    // Daten laden
    await loadEinsaetze();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    elements.btnVorwoche.addEventListener('click', () => changeWeek(-1));
    elements.btnNachwoche.addEventListener('click', () => changeWeek(1));
    elements.btnHeute.addEventListener('click', gotoToday);

    elements.datePicker.addEventListener('change', (e) => {
        const date = new Date(e.target.value);
        if (!isNaN(date)) {
            state.currentWeekStart = getMonday(date);
            updateWeekDisplay();
            loadEinsaetze();
        }
    });

    // Filter
    elements.cboAnsicht.addEventListener('change', (e) => {
        state.filters.ansicht = e.target.value;
        renderEinsaetze();
    });

    elements.cboObjekt.addEventListener('change', (e) => {
        state.filters.objekt = e.target.value;
        renderEinsaetze();
    });

    elements.cboStatus.addEventListener('change', (e) => {
        state.filters.status = e.target.value;
        renderEinsaetze();
    });

    elements.btnAktualisieren.addEventListener('click', loadEinsaetze);

    // Detail Panel schließen
    elements.btnCloseDetail.addEventListener('click', closeDetailPanel);

    // Keyboard
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeDetailPanel();
        if (e.key === 'ArrowLeft' && e.ctrlKey) changeWeek(-1);
        if (e.key === 'ArrowRight' && e.ctrlKey) changeWeek(1);
    });
}

/**
 * Montag einer Woche ermitteln
 */
function getMonday(date) {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1);
    d.setDate(diff);
    d.setHours(0, 0, 0, 0);
    return d;
}

/**
 * Woche wechseln
 */
function changeWeek(delta) {
    const newDate = new Date(state.currentWeekStart);
    newDate.setDate(newDate.getDate() + (delta * 7));
    state.currentWeekStart = newDate;
    updateWeekDisplay();
    loadEinsaetze();
}

/**
 * Zu heute springen
 */
function gotoToday() {
    state.currentWeekStart = getMonday(new Date());
    updateWeekDisplay();
    loadEinsaetze();
}

/**
 * Wochenanzeige aktualisieren
 */
function updateWeekDisplay() {
    const start = state.currentWeekStart;
    const end = new Date(start);
    end.setDate(end.getDate() + 6);

    const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
    const startStr = start.toLocaleDateString('de-DE', options);
    const endStr = end.toLocaleDateString('de-DE', options);

    // KW berechnen
    const kw = getWeekNumber(start);

    elements.lblWoche.textContent = `KW ${kw}: ${startStr} - ${endStr}`;
    elements.datePicker.value = start.toISOString().split('T')[0];

    // Kalender-Header aktualisieren
    updateCalendarHeader();
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
            option.value = obj.VA_ID || obj.Objekt;
            option.textContent = obj.Objekt;
            elements.cboObjekt.appendChild(option);
        });

    } catch (error) {
        console.error('[Dienstplanübersicht] Fehler beim Laden der Objekte:', error);
    }
}

/**
 * Kalender-Grundstruktur rendern
 */
function renderCalendarStructure() {
    // Header mit Wochentagen wird in updateCalendarHeader() gefüllt
    updateCalendarHeader();

    // Body mit Zeitzeilen
    let html = '';

    for (let hour = START_HOUR; hour <= END_HOUR; hour++) {
        html += `
            <div class="time-row" data-hour="${hour}">
                <div class="time-cell">${hour.toString().padStart(2, '0')}:00</div>
                <div class="day-cell" data-day="0"></div>
                <div class="day-cell" data-day="1"></div>
                <div class="day-cell" data-day="2"></div>
                <div class="day-cell" data-day="3"></div>
                <div class="day-cell" data-day="4"></div>
                <div class="day-cell weekend" data-day="5"></div>
                <div class="day-cell weekend" data-day="6"></div>
            </div>
        `;
    }

    elements.calendarBody.innerHTML = html;
}

/**
 * Kalender-Header aktualisieren
 */
function updateCalendarHeader() {
    const wochentage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    let html = '<div class="calendar-header-cell time-col">Zeit</div>';

    for (let i = 0; i < 7; i++) {
        const date = new Date(state.currentWeekStart);
        date.setDate(date.getDate() + i);

        const isToday = isSameDay(date, new Date());
        const dayClass = i >= 5 ? 'weekend' : '';
        const todayClass = isToday ? 'today' : '';

        html += `
            <div class="calendar-header-cell day-col ${dayClass} ${todayClass}">
                <div class="day-name">${wochentage[i]}</div>
                <div class="day-date">${date.getDate()}.${date.getMonth() + 1}.</div>
            </div>
        `;
    }

    elements.calendarHeader.innerHTML = html;
}

/**
 * Prüfen ob gleicher Tag
 */
function isSameDay(date1, date2) {
    return date1.getDate() === date2.getDate() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getFullYear() === date2.getFullYear();
}

/**
 * Einsätze laden
 */
async function loadEinsaetze() {
    setStatus('Lade Einsätze...');

    try {
        const startDate = state.currentWeekStart.toISOString().split('T')[0];
        const endDate = new Date(state.currentWeekStart);
        endDate.setDate(endDate.getDate() + 6);
        const endDateStr = endDate.toISOString().split('T')[0];

        // Einsatztage laden mit Start/Ende-Zeiten
        const result = await Bridge.einsatztage.list({
            von: startDate,
            bis: endDateStr
        });

        state.einsaetze = (result.data || []).map(e => ({
            ID: e.VAS_ID || e.ID,
            VA_ID: e.VA_ID,
            Datum: e.VADatum || e.Datum,
            Start: e.VA_Start || e.Start || '08:00',
            Ende: e.VA_Ende || e.Ende || '16:00',
            Objekt: e.Objekt || e.VA_Objekt || '',
            Status: e.Status || 'Planung',
            MA_Soll: e.MA_Anzahl || e.MA_Soll || 0,
            MA_Ist: e.MA_Anzahl_Ist || e.MA_Ist || 0,
            Bemerkung: e.Bemerkung || ''
        }));

        renderEinsaetze();

        setStatus(`${state.einsaetze.length} Einsätze geladen`);
        elements.lblAnzEinsaetze.textContent = `Einsätze: ${state.einsaetze.length}`;

    } catch (error) {
        console.error('[Dienstplanübersicht] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Einsätze im Kalender rendern
 */
function renderEinsaetze() {
    // Alle bestehenden Einsatz-Blöcke entfernen
    document.querySelectorAll('.einsatz-block').forEach(el => el.remove());

    // Gefilterte Einsätze
    const filtered = state.einsaetze.filter(e => {
        if (state.filters.objekt && e.VA_ID != state.filters.objekt) return false;
        if (state.filters.status && e.Status !== state.filters.status) return false;
        return true;
    });

    // Einsätze nach Tag gruppieren
    const byDay = {};
    filtered.forEach(einsatz => {
        const date = new Date(einsatz.Datum);
        const dayIndex = getDayIndex(date);

        if (dayIndex >= 0 && dayIndex < 7) {
            if (!byDay[dayIndex]) byDay[dayIndex] = [];
            byDay[dayIndex].push(einsatz);
        }
    });

    // Einsätze rendern
    Object.keys(byDay).forEach(dayIndex => {
        const dayEinsaetze = byDay[dayIndex];

        dayEinsaetze.forEach(einsatz => {
            renderEinsatzBlock(parseInt(dayIndex), einsatz);
        });
    });

    // Anzahl aktualisieren
    elements.lblAnzEinsaetze.textContent = `Einsätze: ${filtered.length}`;
}

/**
 * Tag-Index berechnen (0=Mo, 6=So)
 */
function getDayIndex(date) {
    const d = new Date(date);
    const weekStart = state.currentWeekStart;

    const diffTime = d.getTime() - weekStart.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    return diffDays;
}

/**
 * Einzelnen Einsatz-Block rendern
 */
function renderEinsatzBlock(dayIndex, einsatz) {
    // Zeit parsen
    const startParts = einsatz.Start.split(':');
    const endParts = einsatz.Ende.split(':');

    const startHour = parseInt(startParts[0]) + parseInt(startParts[1]) / 60;
    const endHour = parseInt(endParts[0]) + parseInt(endParts[1]) / 60;

    // Position berechnen
    const top = (startHour - START_HOUR) * HOUR_HEIGHT;
    const height = (endHour - startHour) * HOUR_HEIGHT;

    // Status-Klasse
    let statusClass = '';
    if (einsatz.Status === 'Planung') statusClass = 'status-planung';
    else if (einsatz.Status === 'Bestätigt') statusClass = 'status-bestaetigt';
    else if (einsatz.MA_Ist < einsatz.MA_Soll) statusClass = 'status-problem';

    // Soll/Ist Klasse
    let sollIstClass = 'ok';
    if (einsatz.MA_Ist < einsatz.MA_Soll) {
        sollIstClass = einsatz.MA_Ist === 0 ? 'err' : 'warn';
    }

    // Block erstellen
    const block = document.createElement('div');
    block.className = `einsatz-block ${statusClass}`;
    block.style.top = `${top}px`;
    block.style.height = `${Math.max(height, 20)}px`;
    block.dataset.id = einsatz.ID;

    block.innerHTML = `
        <div class="einsatz-title">${einsatz.Objekt}</div>
        <div class="einsatz-info">${einsatz.Start} - ${einsatz.Ende}</div>
        <div class="soll-ist ${sollIstClass}">${einsatz.MA_Ist}/${einsatz.MA_Soll}</div>
    `;

    // Click Handler
    block.addEventListener('click', () => showDetail(einsatz));

    // In die richtige Zelle einfügen
    // Finde die erste Zeitzeile die passt
    const startRowHour = Math.floor(startHour);
    const row = elements.calendarBody.querySelector(`.time-row[data-hour="${startRowHour}"]`);

    if (row) {
        const cell = row.querySelector(`.day-cell[data-day="${dayIndex}"]`);
        if (cell) {
            // Position relativ zur Zelle anpassen
            const cellTop = (startHour - startRowHour) * HOUR_HEIGHT;
            block.style.top = `${cellTop}px`;
            cell.appendChild(block);
        }
    }
}

/**
 * Detail-Panel anzeigen
 */
async function showDetail(einsatz) {
    state.selectedEinsatz = einsatz;

    // Panel-Felder füllen
    document.getElementById('detailObjekt').textContent = einsatz.Objekt;
    document.getElementById('detailDatum').textContent =
        new Date(einsatz.Datum).toLocaleDateString('de-DE');
    document.getElementById('detailZeit').textContent =
        `${einsatz.Start} - ${einsatz.Ende}`;
    document.getElementById('detailStatus').textContent = einsatz.Status;
    document.getElementById('detailSoll').textContent = einsatz.MA_Soll;
    document.getElementById('detailIst').textContent = einsatz.MA_Ist;

    // Zugeordnete MA laden
    try {
        const result = await Bridge.zuordnungen.list({
            vas_id: einsatz.ID
        });

        const maList = document.getElementById('detailMAListe');
        const mitarbeiter = result.data || [];

        if (mitarbeiter.length === 0) {
            maList.innerHTML = '<li>Keine Mitarbeiter zugeordnet</li>';
        } else {
            maList.innerHTML = mitarbeiter.map(ma => {
                const name = ma.MA_Name || `${ma.MA_Nachname}, ${ma.MA_Vorname}`;
                const status = ma.MVP_Status || '';
                return `<li>${name} ${status ? `(${status})` : ''}</li>`;
            }).join('');
        }

    } catch (error) {
        console.error('[Dienstplanübersicht] Fehler beim Laden der MA:', error);
        document.getElementById('detailMAListe').innerHTML =
            '<li>Fehler beim Laden</li>';
    }

    // Panel anzeigen
    elements.detailPanel.style.display = 'block';
}

/**
 * Detail-Panel schließen
 */
function closeDetailPanel() {
    elements.detailPanel.style.display = 'none';
    state.selectedEinsatz = null;
}

/**
 * Einsatz bearbeiten (öffnet Hauptformular)
 */
function editEinsatz() {
    if (!state.selectedEinsatz) return;

    // PostMessage an Parent oder Hauptformular öffnen
    const va_id = state.selectedEinsatz.VA_ID;

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
 * Status setzen
 */
function setStatus(text) {
    elements.lblStatus.textContent = text;
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.Dienstplan = {
    loadEinsaetze,
    changeWeek,
    gotoToday,
    editEinsatz
};
