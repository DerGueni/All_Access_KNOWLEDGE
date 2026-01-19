/**
 * frm_DP_Dienstplan_MA.logic.js
 * Logik für Mitarbeiter-Dienstplanübersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../../api/bridgeClient.js';

// State
const state = {
    startDate: new Date(),
    mitarbeiter: [],
    dienstplaene: {},
    filter: 1 // 1=Alle aktiven, 0=Alle, 2=Festangestellte, 3=Minijobber, 4=Sub
};

// DOM-Elemente
let elements = {};

// Wochentage
const WOCHENTAGE = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
const WOCHENTAGE_LANG = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];

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
    console.log('[DP-MA] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Navigation
        dtStartdatum: document.getElementById('dtStartdatum'),
        dtEnddatum: document.getElementById('dtEnddatum'),
        btnVor: document.getElementById('btnVor'),
        btnrueck: document.getElementById('btnrueck'),
        btn_Heute: document.getElementById('btn_Heute'),
        btnStartdatum: document.getElementById('btnStartdatum'),

        // Filter
        NurAktiveMA: document.getElementById('NurAktiveMA'),

        // Buttons
        btnDPSenden: document.getElementById('btnDPSenden'),
        btnMADienstpl: document.getElementById('btnMADienstpl'),
        btnOutpExcel: document.getElementById('btnOutpExcel'),
        btnOutpExcelSend: document.getElementById('btnOutpExcelSend'),
        Befehl20: document.getElementById('Befehl20'),
        Befehl37: document.getElementById('Befehl37'),

        // Labels
        lbl_Datum: document.getElementById('lbl_Datum'),
        lbl_Version: document.getElementById('lbl_Version'),

        // Kalender
        sub_DP_Grund: document.getElementById('sub_DP_Grund')
    };

    // Aktuelles Datum auf Montag dieser Woche setzen
    const today = new Date();
    const dayOfWeek = today.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek; // Montag
    state.startDate = new Date(today.setDate(today.getDate() + diff));

    // Datum-Inputs setzen
    updateDateInputs();

    // Aktuelles Datum Label setzen
    elements.lbl_Datum.textContent = new Date().toLocaleDateString('de-DE');

    // Event Listener
    setupEventListeners();

    // Daten laden
    await loadMitarbeiter();
    await loadDienstplan();

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
            loadDienstplan();
        }
    });

    elements.dtStartdatum.addEventListener('change', (e) => {
        state.startDate = new Date(e.target.value);
        // Auf Montag der Woche setzen
        const dayOfWeek = state.startDate.getDay();
        const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
        state.startDate.setDate(state.startDate.getDate() + diff);
        updateDateInputs();
        loadDienstplan();
    });

    // Filter
    elements.NurAktiveMA.addEventListener('change', (e) => {
        state.filter = parseInt(e.target.value);
        loadDienstplan();
    });

    // Buttons
    elements.Befehl37.addEventListener('click', () => window.close());
    elements.btnDPSenden.addEventListener('click', sendDienstplaene);
    elements.btnMADienstpl.addEventListener('click', openEinzeldienstplaene);
    elements.btnOutpExcel.addEventListener('click', exportExcel);
    elements.btnOutpExcelSend.addEventListener('click', sendExcel);
    elements.Befehl20.addEventListener('click', sendDienstplaene);
}

/**
 * Navigation: Woche vor/zurück
 */
function navigateWeek(direction) {
    state.startDate.setDate(state.startDate.getDate() + (direction * 7));
    updateDateInputs();
    loadDienstplan();
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
    loadDienstplan();
}

/**
 * Datum-Inputs aktualisieren
 */
function updateDateInputs() {
    elements.dtStartdatum.value = formatDateForInput(state.startDate);

    // Enddatum = Startdatum + 6 Tage (Sonntag)
    const endDate = new Date(state.startDate);
    endDate.setDate(endDate.getDate() + 6);
    elements.dtEnddatum.value = formatDateForInput(endDate);

    // Header-Labels aktualisieren
    updateHeaderLabels();
}

/**
 * Header-Labels aktualisieren
 */
function updateHeaderLabels() {
    for (let i = 0; i < 7; i++) {
        const date = new Date(state.startDate);
        date.setDate(date.getDate() + i);

        const dayName = WOCHENTAGE_LANG[date.getDay()];
        const dateStr = date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });

        const label = document.getElementById(`lbl_Tag_${i + 1}`);
        if (label) {
            label.textContent = `${dayName} ${dateStr}`;
        }
    }
}

/**
 * Mitarbeiter laden
 */
async function loadMitarbeiter() {
    try {
        const params = {};

        // Filter anwenden
        switch (state.filter) {
            case 1: // Alle aktiven
                params.aktiv = true;
                break;
            case 2: // Festangestellte
                params.aktiv = true;
                params.typ = 'Festangestellt';
                break;
            case 3: // Minijobber
                params.aktiv = true;
                params.typ = 'Minijob';
                break;
            case 4: // Sub
                params.aktiv = true;
                params.typ = 'Sub';
                break;
            default: // Alle
                break;
        }

        const result = await Bridge.mitarbeiter.list(params);
        state.mitarbeiter = result.data || [];

        console.log(`[DP-MA] ${state.mitarbeiter.length} Mitarbeiter geladen`);

    } catch (error) {
        console.error('[DP-MA] Fehler beim Laden der Mitarbeiter:', error);
        setStatus('Fehler beim Laden der Mitarbeiter');
    }
}

/**
 * Dienstplan laden
 */
async function loadDienstplan() {
    setStatus('Lade Dienstpläne...');

    try {
        // Mitarbeiter neu laden (mit aktuellem Filter)
        await loadMitarbeiter();

        const startStr = formatDateForInput(state.startDate);
        const endDate = new Date(state.startDate);
        endDate.setDate(endDate.getDate() + 6);
        const endStr = formatDateForInput(endDate);

        // Dienstpläne für jeden Mitarbeiter laden
        state.dienstplaene = {};

        // Batch-Laden aller Mitarbeiter (max 100)
        const promises = state.mitarbeiter.slice(0, 100).map(async (ma) => {
            try {
                const maId = ma.MA_ID || ma.ID;
                const result = await Bridge.dienstplan.getByMA(maId, {
                    von: startStr,
                    bis: endStr
                });

                if (result.data) {
                    state.dienstplaene[maId] = result.data;
                }
            } catch (e) {
                // Einzelne Fehler ignorieren
                console.warn(`[DP-MA] Fehler beim Laden für MA ${ma.MA_ID}:`, e);
            }
        });

        await Promise.all(promises);

        // Kalender rendern
        renderWochenansicht();

        setStatus(`${state.mitarbeiter.length} Mitarbeiter geladen`);

    } catch (error) {
        console.error('[DP-MA] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        elements.sub_DP_Grund.innerHTML = '<div class="loading" style="color: red;">Fehler beim Laden der Daten</div>';
    }
}

/**
 * Wochenansicht rendern
 */
function renderWochenansicht() {
    const container = elements.sub_DP_Grund;

    if (state.mitarbeiter.length === 0) {
        container.innerHTML = '<div style="padding: 20px; text-align: center; color: #888;">Keine Mitarbeiter gefunden</div>';
        return;
    }

    // Kalender Grid erstellen
    let html = '<div class="calendar-grid">';

    // Header-Zeile
    html += '<div class="calendar-header" style="background-color:#5c0000;color:#fff;">Mitarbeiter</div>';

    for (let i = 0; i < 7; i++) {
        const date = new Date(state.startDate);
        date.setDate(date.getDate() + i);
        const isWeekend = date.getDay() === 0 || date.getDay() === 6;
        const isFeiertag = istFeiertag(date);

        let headerClass = 'calendar-header';
        if (isWeekend) headerClass += ' weekend';
        if (isFeiertag) headerClass += ' feiertag';

        html += `<div class="${headerClass}">
            ${WOCHENTAGE[date.getDay()]} ${date.getDate()}.${date.getMonth() + 1}
        </div>`;
    }

    // MA Zeilen
    for (const ma of state.mitarbeiter.slice(0, 100)) {
        html += '<div class="calendar-row">';

        const maId = ma.MA_ID || ma.ID;
        const maName = `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`;

        // Name-Zelle
        html += `<div class="calendar-cell-name">${escapeHtml(maName)}</div>`;

        // 7 Tage
        for (let i = 0; i < 7; i++) {
            const date = new Date(state.startDate);
            date.setDate(date.getDate() + i);
            const dateKey = formatDateForInput(date);
            const isWeekend = date.getDay() === 0 || date.getDay() === 6;
            const isToday = formatDateForInput(date) === formatDateForInput(new Date());

            let cellClass = 'calendar-cell';
            if (isWeekend) cellClass += ' weekend';
            if (isToday) cellClass += ' today';

            html += `<div class="${cellClass}">`;

            // Einträge für diesen Tag
            const eintraege = (state.dienstplaene[maId] || []).filter(e => {
                const eDatum = new Date(e.VADatum || e.Datum);
                return formatDateForInput(eDatum) === dateKey;
            });

            for (const eintrag of eintraege) {
                let entryClass = 'einsatz-entry';
                const typ = (eintrag.Typ || eintrag.Grund || eintrag.AbwGrund || '').toLowerCase();
                const bemerkung = (eintrag.Bemerkung || '').toLowerCase();

                // Abwesenheitstypen erkennen (in Prioritätsreihenfolge)
                if (typ.includes('krank') || bemerkung.includes('krank')) {
                    entryClass += ' krank';
                } else if (typ.includes('urlaub') || bemerkung.includes('urlaub')) {
                    entryClass += ' urlaub';
                } else if (typ.includes('fraglich') || typ.includes('?') || bemerkung.includes('fraglich')) {
                    entryClass += ' fraglich';
                } else if (typ.includes('privat') || typ.includes('frei') || typ.includes('schule') ||
                           bemerkung.includes('privat') || bemerkung.includes('frei')) {
                    entryClass += ' privat';
                } else if (eintrag.IstAbwesend || eintrag.Abwesend ||
                           typ.includes('abwesend') || typ.includes('nicht verfügbar')) {
                    entryClass += ' abwesend';
                }

                const zeit = eintrag.VA_Start ? formatTime(eintrag.VA_Start) : '';
                const zeitEnde = eintrag.VA_Ende ? ' - ' + formatTime(eintrag.VA_Ende) : '';
                const text = eintrag.Auftrag || eintrag.Objekt || eintrag.Typ || eintrag.Grund || eintrag.Bemerkung || '';

                html += `<div class="${entryClass}" title="${escapeHtml(text)}">
                    ${zeit}${zeitEnde}${zeit ? '<br>' : ''}${escapeHtml(text)}
                </div>`;
            }

            html += '</div>';
        }

        html += '</div>';
    }

    html += '</div>';
    container.innerHTML = html;
}

/**
 * Dienstpläne senden
 */
async function sendDienstplaene() {
    const endDatum = elements.dtEnddatum.value;

    if (!endDatum) {
        alert('Bitte Enddatum auswählen');
        return;
    }

    if (!confirm(`Dienstpläne bis ${endDatum} per E-Mail senden?`)) {
        return;
    }

    setStatus('Sende Dienstpläne...');

    try {
        // TODO: Implementierung des Versands
        alert(`Dienstpläne würden bis ${endDatum} versendet werden.\n(Funktion in Entwicklung)`);
        setStatus('Bereit');
    } catch (error) {
        console.error('[DP-MA] Fehler beim Senden:', error);
        alert('Fehler beim Senden: ' + error.message);
        setStatus('Fehler beim Senden');
    }
}

/**
 * Einzeldienstpläne öffnen
 */
function openEinzeldienstplaene() {
    // TODO: Formular für Einzeldienstpläne öffnen
    alert('Einzeldienstpläne-Dialog öffnen\n(Funktion in Entwicklung)');
}

/**
 * Excel-Export
 */
function exportExcel() {
    setStatus('Exportiere nach Excel...');

    try {
        // CSV-Export erstellen
        const headers = ['Mitarbeiter'];
        for (let i = 0; i < 7; i++) {
            const date = new Date(state.startDate);
            date.setDate(date.getDate() + i);
            headers.push(`${WOCHENTAGE[date.getDay()]} ${date.toLocaleDateString('de-DE')}`);
        }

        const rows = [headers];

        for (const ma of state.mitarbeiter.slice(0, 100)) {
            const maId = ma.MA_ID || ma.ID;
            const maName = `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`;
            const row = [maName];

            for (let i = 0; i < 7; i++) {
                const date = new Date(state.startDate);
                date.setDate(date.getDate() + i);
                const dateKey = formatDateForInput(date);

                const eintraege = (state.dienstplaene[maId] || []).filter(e => {
                    const eDatum = new Date(e.VADatum || e.Datum);
                    return formatDateForInput(eDatum) === dateKey;
                });

                const cellText = eintraege.map(e => {
                    const zeit = e.VA_Start ? formatTime(e.VA_Start) : '';
                    const zeitEnde = e.VA_Ende ? ' - ' + formatTime(e.VA_Ende) : '';
                    const text = e.Auftrag || e.Objekt || e.Typ || e.Grund || '';
                    return `${zeit}${zeitEnde} ${text}`.trim();
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
        a.download = `Dienstplan_Uebersicht_${formatDateForInput(state.startDate)}.csv`;
        a.click();
        URL.revokeObjectURL(url);

        setStatus('Export abgeschlossen');

    } catch (error) {
        console.error('[DP-MA] Fehler beim Export:', error);
        alert('Fehler beim Export: ' + error.message);
        setStatus('Fehler beim Export');
    }
}

/**
 * Excel-Export senden
 */
async function sendExcel() {
    if (!confirm('Übersicht per E-Mail senden?')) {
        return;
    }

    setStatus('Sende Übersicht...');

    try {
        // TODO: Implementierung des Versands
        alert('Übersicht würde per E-Mail versendet werden.\n(Funktion in Entwicklung)');
        setStatus('Bereit');
    } catch (error) {
        console.error('[DP-MA] Fehler beim Senden:', error);
        alert('Fehler beim Senden: ' + error.message);
        setStatus('Fehler beim Senden');
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
    console.log(`[DP-MA] ${text}`);
    // Optionaler Status-Bereich könnte hier aktualisiert werden
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.DienstplanMA = {
    loadDienstplan,
    exportExcel
};
