/**
 * frm_DP_Dienstplan_Objekt.logic.js
 * Logik für Objekt-/Auftrag-Planungsübersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../../api/bridgeClient.js';

// State
const state = {
    startDate: new Date(),
    auftraege: [],
    zuordnungen: {},
    nurFreieSchichten: false,
    istAuftrAusblend: false,
    posAusblendAb: 25
};

// DOM-Elemente
let elements = {};

// Wochentage
const WOCHENTAGE = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];

// Deutsche Feiertage 2025
const FEIERTAGE_2025 = [
    '2025-01-01', // Neujahr
    '2025-04-18', // Karfreitag
    '2025-04-21', // Ostermontag
    '2025-05-01', // Tag der Arbeit
    '2025-05-29', // Christi Himmelfahrt
    '2025-06-09', // Pfingstmontag
    '2025-10-03', // Tag der Deutschen Einheit
    '2025-12-25', // 1. Weihnachtstag
    '2025-12-26'  // 2. Weihnachtstag
];

/**
 * Prüft ob ein Datum ein Feiertag ist
 */
function istFeiertag(datum) {
    const dateKey = formatDateForInput(datum);
    return FEIERTAGE_2025.includes(dateKey);
}

/**
 * Initialisierung
 */
async function init() {
    console.log('[DP-Objekt] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Navigation
        dtStartdatum: document.getElementById('dtStartdatum'),
        btnVor: document.getElementById('btnVor'),
        btnrueck: document.getElementById('btnrueck'),
        btn_Heute: document.getElementById('btn_Heute'),
        btnStartdatum: document.getElementById('btnStartdatum'),

        // Filter
        NurIstNichtZugeordnet: document.getElementById('NurIstNichtZugeordnet'),
        IstAuftrAusblend: document.getElementById('IstAuftrAusblend'),
        PosAusblendAb: document.getElementById('PosAusblendAb'),

        // Buttons
        btnOutpExcel: document.getElementById('btnOutpExcel'),
        Befehl37: document.getElementById('Befehl37'),

        // Kalender
        calendarBody: document.getElementById('calendarBody')
    };

    // Aktuelles Datum auf Montag dieser Woche setzen
    const today = new Date();
    const dayOfWeek = today.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek; // Montag
    state.startDate = new Date(today.setDate(today.getDate() + diff));

    // Datum-Inputs setzen
    updateDateInputs();

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
    elements.btnVor.addEventListener('click', () => navigateWeek(1));
    elements.btnrueck.addEventListener('click', () => navigateWeek(-1));
    elements.btn_Heute.addEventListener('click', goToToday);

    elements.btnStartdatum.addEventListener('click', () => {
        const newDate = elements.dtStartdatum.value;
        if (newDate) {
            state.startDate = new Date(newDate);
            // Auf Montag der Woche setzen
            const dayOfWeek = state.startDate.getDay();
            const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
            state.startDate.setDate(state.startDate.getDate() + diff);
            updateDateInputs();
            loadData();
        }
    });

    // Filter
    elements.NurIstNichtZugeordnet.addEventListener('change', (e) => {
        state.nurFreieSchichten = e.target.checked;
        renderCalendar();
    });

    elements.IstAuftrAusblend.addEventListener('change', (e) => {
        state.istAuftrAusblend = e.target.checked;
        renderCalendar();
    });

    elements.PosAusblendAb.addEventListener('change', (e) => {
        state.posAusblendAb = parseInt(e.target.value) || 25;
        if (state.istAuftrAusblend) {
            renderCalendar();
        }
    });

    // Buttons
    elements.Befehl37.addEventListener('click', () => window.close());
    elements.btnOutpExcel.addEventListener('click', exportExcel);
}

/**
 * Navigation: Woche vor/zurück
 */
function navigateWeek(direction) {
    state.startDate.setDate(state.startDate.getDate() + (direction * 7));
    updateDateInputs();
    loadData();
}

/**
 * Navigation: Ab Heute
 */
function goToToday() {
    const today = new Date();
    const dayOfWeek = today.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    state.startDate = new Date(today.setDate(today.getDate() + diff));
    updateDateInputs();
    loadData();
}

/**
 * Datum-Inputs aktualisieren
 */
function updateDateInputs() {
    elements.dtStartdatum.value = formatDateForInput(state.startDate);
    updateHeaderLabels();
}

/**
 * Header-Labels aktualisieren
 */
function updateHeaderLabels() {
    for (let i = 0; i < 7; i++) {
        const date = new Date(state.startDate);
        date.setDate(date.getDate() + i);

        const dayName = WOCHENTAGE[date.getDay()];
        const dateStr = `${date.getDate().toString().padStart(2, '0')}.${(date.getMonth() + 1).toString().padStart(2, '0')}.${date.getFullYear().toString().slice(-2)}`;

        const dayHeader = document.querySelector(`#day_${i + 1} .day-title`);
        if (dayHeader) {
            dayHeader.textContent = `${dayName}. ${dateStr}`;

            const isWeekend = date.getDay() === 0 || date.getDay() === 6;
            const isFeiertag = istFeiertag(date);

            dayHeader.classList.toggle('weekend', isWeekend);
            dayHeader.classList.toggle('feiertag', isFeiertag);
        }
    }
}

/**
 * Daten laden
 */
async function loadData() {
    setStatus('Lade Planungsübersicht...');

    try {
        const startStr = formatDateForInput(state.startDate);
        const endDate = new Date(state.startDate);
        endDate.setDate(endDate.getDate() + 6);
        const endStr = formatDateForInput(endDate);

        // Aufträge im Zeitraum laden
        const auftragResult = await Bridge.auftraege.list({
            von: startStr,
            bis: endStr,
            limit: 100
        });

        state.auftraege = auftragResult.data || [];

        // Zuordnungen laden
        state.zuordnungen = {};

        try {
            const zuordResult = await Bridge.zuordnungen.list({
                von: startStr,
                bis: endStr
            });

            // Zuordnungen nach VA_ID + Datum gruppieren
            for (const z of (zuordResult.data || [])) {
                const vaId = z.VA_ID;
                const datum = formatDateForInput(new Date(z.VADatum || z.Datum));
                const key = `${vaId}_${datum}`;

                if (!state.zuordnungen[key]) {
                    state.zuordnungen[key] = [];
                }
                state.zuordnungen[key].push(z);
            }
        } catch (e) {
            console.warn('[DP-Objekt] Zuordnungen laden fehlgeschlagen:', e);
        }

        // Kalender rendern
        renderCalendar();

        setStatus(`${state.auftraege.length} Aufträge geladen`);

    } catch (error) {
        console.error('[DP-Objekt] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        elements.calendarBody.innerHTML = '<div class="loading" style="color: red;">Fehler beim Laden der Daten</div>';
    }
}

/**
 * Kalender rendern
 */
function renderCalendar() {
    const container = elements.calendarBody;

    let auftraege = state.auftraege;

    // Filter anwenden
    if (state.istAuftrAusblend && state.posAusblendAb > 0) {
        // TODO: Aufträge mit mehr als X Positionen ausblenden
        // (benötigt Positions-Count aus Backend)
    }

    if (state.nurFreieSchichten) {
        // Nur Aufträge mit freien Schichten anzeigen
        auftraege = auftraege.filter(auftrag => {
            // Prüfe ob irgendein Tag im Zeitraum freie Schichten hat
            for (let i = 0; i < 7; i++) {
                const date = new Date(state.startDate);
                date.setDate(date.getDate() + i);
                const dateKey = formatDateForInput(date);
                const key = `${auftrag.VA_ID || auftrag.ID}_${dateKey}`;
                const zuordnungen = state.zuordnungen[key] || [];

                // TODO: Mit Soll-Anzahl vergleichen
                // Für jetzt: Wenn keine Zuordnungen vorhanden
                if (zuordnungen.length === 0) {
                    return true;
                }
            }
            return false;
        });
    }

    if (auftraege.length === 0) {
        container.innerHTML = '<div style="padding: 20px; text-align: center; color: #888;">Keine Aufträge im gewählten Zeitraum</div>';
        return;
    }

    let html = '';

    for (const auftrag of auftraege.slice(0, 50)) {
        const vaId = auftrag.VA_ID || auftrag.ID;
        const auftragName = auftrag.Auftrag || auftrag.VA_Bezeichnung || 'Unbekannt';
        const objekt = auftrag.Objekt || auftrag.VA_Objekt || '';
        const ort = auftrag.Ort || auftrag.VA_Ort || '';

        html += '<div class="calendar-row">';
        html += `<div class="col-auftrag">
            <span class="auftrag-name">${escapeHtml(auftragName)}</span>
            <span class="auftrag-details">${escapeHtml(objekt)} - ${escapeHtml(ort)}</span>
        </div>`;

        // 7 Tage
        for (let i = 0; i < 7; i++) {
            const date = new Date(state.startDate);
            date.setDate(date.getDate() + i);
            const dateKey = formatDateForInput(date);
            const isWeekend = date.getDay() === 0 || date.getDay() === 6;

            const key = `${vaId}_${dateKey}`;
            const zuordnungen = state.zuordnungen[key] || [];

            html += `<div class="day-column ${isWeekend ? 'weekend' : ''}">`;

            // MA-Zuordnungen anzeigen
            for (const z of zuordnungen) {
                const maName = z.MAName || z.MA_Nachname || z.Nachname || 'MA';
                const von = formatTime(z.VA_Start);
                const bis = formatTime(z.VA_Ende);
                const isStorno = (z.Status || '').toLowerCase().includes('storno') ||
                                 (z.IstStorno || false);

                html += `<div class="ma-entry ${isStorno ? 'storno' : ''}">
                    <span class="ma-name" title="${escapeHtml(maName)}">${escapeHtml(maName)}</span>
                    <span class="ma-von">${von}</span>
                    <span class="ma-bis">${bis}</span>
                </div>`;
            }

            html += '</div>';
        }

        html += '</div>';
    }

    container.innerHTML = html;
}

/**
 * Excel-Export
 */
function exportExcel() {
    setStatus('Exportiere nach Excel...');

    try {
        // CSV-Export erstellen
        const headers = ['Auftrag/Objekt'];
        for (let i = 0; i < 7; i++) {
            const date = new Date(state.startDate);
            date.setDate(date.getDate() + i);
            headers.push(`${WOCHENTAGE[date.getDay()]} ${date.toLocaleDateString('de-DE')}`);
        }

        const rows = [headers];

        for (const auftrag of state.auftraege.slice(0, 50)) {
            const vaId = auftrag.VA_ID || auftrag.ID;
            const auftragName = auftrag.Auftrag || auftrag.VA_Bezeichnung || 'Unbekannt';
            const row = [auftragName];

            for (let i = 0; i < 7; i++) {
                const date = new Date(state.startDate);
                date.setDate(date.getDate() + i);
                const dateKey = formatDateForInput(date);

                const key = `${vaId}_${dateKey}`;
                const zuordnungen = state.zuordnungen[key] || [];

                const cellText = zuordnungen.map(z => {
                    const maName = z.MAName || z.MA_Nachname || z.Nachname || 'MA';
                    const von = formatTime(z.VA_Start);
                    const bis = formatTime(z.VA_Ende);
                    return `${maName} (${von}-${bis})`;
                }).join('; ');

                row.push(cellText);
            }

            rows.push(row);
        }

        const csv = rows
            .map(row => row.map(cell => `"${cell}"`).join(';'))
            .join('\n');

        const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `Planungsuebersicht_${formatDateForInput(state.startDate)}.csv`;
        a.click();
        URL.revokeObjectURL(url);

        setStatus('Export abgeschlossen');

    } catch (error) {
        console.error('[DP-Objekt] Fehler beim Export:', error);
        alert('Fehler beim Export: ' + error.message);
        setStatus('Fehler beim Export');
    }
}

/**
 * Datum formatieren (YYYY-MM-DD)
 */
function formatDateForInput(date) {
    if (!date) return '';
    const d = new Date(date);
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * Zeit formatieren
 */
function formatTime(t) {
    if (!t) return '';

    // Access-Zeit (Dezimalzahl < 1)
    if (typeof t === 'number' && t < 1) {
        const h = Math.floor(t * 24);
        const m = Math.round((t * 24 - h) * 60);
        return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
    }

    // String-Zeit
    if (typeof t === 'string' && t.includes(':')) {
        return t.substring(0, 5);
    }

    return t;
}

/**
 * HTML escapen
 */
function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

/**
 * Status setzen
 */
function setStatus(text) {
    console.log(`[DP-Objekt] ${text}`);
    // Optionaler Status-Bereich könnte hier aktualisiert werden
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.DienstplanObjekt = {
    loadData,
    exportExcel
};
