/**
 * frm_DP_Dienstplan_Objekt.logic.js
 * Logik für Objekt-/Auftrag-Planungsübersicht
 * WebView2 Bridge Integration
 */

// State
const state = {
    startDate: new Date(),
    auftraege: [],
    einsatztage: {},    // Schichten pro VA_ID + Datum
    zuordnungen: {},    // MA-Zuordnungen pro VA_ID + Datum + Schicht
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
 * KW-Dropdown befüllen (1-53)
 */
function populateKWDropdown() {
    const select = elements.cboKW;
    if (!select) return;

    select.innerHTML = ''; // Erst leeren

    // KW 1-53
    for (let kw = 1; kw <= 53; kw++) {
        const option = document.createElement('option');
        option.value = kw;
        option.textContent = kw.toString().padStart(2, '0');
        select.appendChild(option);
    }

    // Aktuelle KW auswählen
    const currentKW = getWeekNumber(new Date());
    select.value = currentKW;

    console.log('[DP-Objekt] KW-Dropdown befüllt, aktuelle KW:', currentKW);
}

/**
 * ISO Kalenderwoche berechnen
 */
function getWeekNumber(date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

/**
 * Montag einer bestimmten KW berechnen
 */
function getMondayOfWeek(kw, year) {
    const jan4 = new Date(year, 0, 4);
    const dayOfWeek = jan4.getDay() || 7;
    const monday = new Date(jan4);
    monday.setDate(jan4.getDate() - dayOfWeek + 1 + (kw - 1) * 7);
    return monday;
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
        cboKW: document.getElementById('cboKW'),
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

    // KW-Dropdown befüllen
    populateKWDropdown();

    // Aktuelles Datum auf Montag dieser Woche setzen
    const today = new Date();
    const dayOfWeek = today.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek; // Montag
    state.startDate = new Date(today.setDate(today.getDate() + diff));

    // Datum-Inputs setzen
    updateDateInputs();

    // WebView2 Bridge Event-Listener registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
    }

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

    // KW-Dropdown Event: Bei Auswahl zur gewählten KW springen
    if (elements.cboKW) {
        elements.cboKW.addEventListener('change', (e) => {
            const selectedKW = parseInt(e.target.value);
            const year = state.startDate.getFullYear();
            state.startDate = getMondayOfWeek(selectedKW, year);
            updateDateInputs();
            loadData();
            console.log('[cboKW] Gewechselt zu KW', selectedKW);
        });
    }

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

    // KW-Combobox synchronisieren
    if (elements.cboKW) {
        const currentKW = getWeekNumber(state.startDate);
        elements.cboKW.value = currentKW;
        console.log('[updateDateInputs] KW synchronisiert:', currentKW);
    }

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
    elements.calendarBody.innerHTML = '<div class="loading">Lade Planungsübersicht...</div>';

    try {
        const startStr = formatDateForInput(state.startDate);
        const endDate = new Date(state.startDate);
        endDate.setDate(endDate.getDate() + 6);
        const endStr = formatDateForInput(endDate);

        // WebView2 Bridge oder REST-API
        if (typeof Bridge !== 'undefined' && Bridge.isWebView2) {
            Bridge.sendEvent('loadPlanungsuebersicht', {
                von: startStr,
                bis: endStr
            });
        } else {
            // REST-API Fallback fuer Browser-Modus
            const API_BASE = 'http://localhost:5000';

            // Auftraege laden (mit Schichten im Zeitraum)
            const auftraegeResponse = await fetch(`${API_BASE}/api/auftraege?von=${startStr}&bis=${endStr}&limit=100`);
            const auftraege = await auftraegeResponse.json();

            // Einsatztage/Schichten laden (VADatum-Tabelle)
            const einsatztageResponse = await fetch(`${API_BASE}/api/einsatztage?von=${startStr}&bis=${endStr}`);
            const einsatztageJson = await einsatztageResponse.json();
            let einsatztage = [];
            if (Array.isArray(einsatztageJson)) {
                einsatztage = einsatztageJson;
            } else if (einsatztageJson && Array.isArray(einsatztageJson.data)) {
                einsatztage = einsatztageJson.data;
            }

            // Zuordnungen laden (MA-Zuweisungen)
            const zuordnungenResponse = await fetch(`${API_BASE}/api/zuordnungen?von=${startStr}&bis=${endStr}`);
            const zuordnungenJson = await zuordnungenResponse.json();
            let zuordnungen = [];
            if (Array.isArray(zuordnungenJson)) {
                zuordnungen = zuordnungenJson;
            } else if (zuordnungenJson && Array.isArray(zuordnungenJson.data)) {
                zuordnungen = zuordnungenJson.data;
            }

            // State aktualisieren - sicherstellen dass auftraege ein Array ist
            if (Array.isArray(auftraege)) {
                state.auftraege = auftraege;
            } else if (auftraege && Array.isArray(auftraege.data)) {
                state.auftraege = auftraege.data;
            } else {
                state.auftraege = [];
            }

            // Einsatztage nach VA_ID + Datum gruppieren
            // Neue Struktur: einsatztage["VA_ID_DATUM"] = [schicht1, schicht2, ...]
            state.einsatztage = {};
            einsatztage.forEach(e => {
                const vaId = e.VA_ID;
                const datum = formatDateForInput(new Date(e.VADatum || e.Datum));
                const key = `${vaId}_${datum}`;
                if (!state.einsatztage[key]) state.einsatztage[key] = [];
                state.einsatztage[key].push({
                    ...e,
                    VADatum_ID: e.VADatum_ID || e.ID,
                    VA_Start: e.VA_Start || e.Start,
                    VA_Ende: e.VA_Ende || e.Ende,
                    Soll: e.Soll || e.MA_Soll || 1
                });
            });

            // Zuordnungen nach VAStart_ID gruppieren (für Schicht-spezifische Zuordnung)
            // Fallback auf VADatum_ID wenn VAStart_ID nicht verfügbar
            state.zuordnungen = {};
            zuordnungen.forEach(z => {
                // Gruppieren nach VAStart_ID (Schicht-ID) oder VADatum_ID als Fallback
                const schichtId = z.VAStart_ID || z.VADatum_ID;
                if (!state.zuordnungen[schichtId]) state.zuordnungen[schichtId] = [];
                state.zuordnungen[schichtId].push({
                    ...z,
                    MAName: z.Nachname ? `${z.Nachname}, ${z.Vorname || ''}` : (z.MA_Nachname || ''),
                    MA_Start: z.MA_Start || z.MVA_Start,
                    MA_Ende: z.MA_Ende || z.MVA_Ende
                });
            });

            renderCalendar();
            setStatus(`${state.auftraege.length} Aufträge, ${einsatztage.length} Schichten geladen`);
        }

    } catch (error) {
        console.error('[DP-Objekt] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        elements.calendarBody.innerHTML = '<div class="loading" style="color: red;">Fehler beim Laden: ' + error.message + '</div>';
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
        // Aufträge mit mehr als X Positionen ausblenden
        auftraege = auftraege.filter(auftrag => {
            const vaId = auftrag.VA_ID || auftrag.ID;
            let totalSchichten = 0;
            for (let i = 0; i < 7; i++) {
                const date = new Date(state.startDate);
                date.setDate(date.getDate() + i);
                const dateKey = formatDateForInput(date);
                const key = `${vaId}_${dateKey}`;
                totalSchichten += (state.einsatztage[key] || []).length;
            }
            return totalSchichten <= state.posAusblendAb;
        });
    }

    if (state.nurFreieSchichten) {
        // Nur Aufträge mit freien Schichten anzeigen
        auftraege = auftraege.filter(auftrag => {
            const vaId = auftrag.VA_ID || auftrag.ID;
            for (let i = 0; i < 7; i++) {
                const date = new Date(state.startDate);
                date.setDate(date.getDate() + i);
                const dateKey = formatDateForInput(date);
                const key = `${vaId}_${dateKey}`;
                const schichten = state.einsatztage[key] || [];
                
                for (const schicht of schichten) {
                    const zuordnungen = state.zuordnungen[schicht.VADatum_ID] || [];
                    const soll = schicht.Soll || 1;
                    if (zuordnungen.length < soll) {
                        return true; // Hat freie Schichten
                    }
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
            const isFeiertag = istFeiertag(date);

            const key = `${vaId}_${dateKey}`;
            const schichten = state.einsatztage[key] || [];

            const dayClasses = [];
            if (isWeekend) dayClasses.push('weekend');
            if (isFeiertag) dayClasses.push('feiertag');

            html += `<div class="day-column ${dayClasses.join(' ')}">`;

            // Alle Schichten für diesen Tag anzeigen
            for (const schicht of schichten) {
                // Schicht-ID für Zuordnungs-Lookup (VADatum_ID ist die ID aus tbl_VA_Start)
                const schichtId = schicht.VADatum_ID;
                const zuordnungen = state.zuordnungen[schichtId] || [];
                const soll = schicht.Soll || 1;
                const von = formatTime(schicht.VA_Start);
                const bis = formatTime(schicht.VA_Ende);

                // Zugeordnete MA anzeigen
                for (const z of zuordnungen) {
                    const maName = z.MAName || 'MA';
                    const maVon = formatTime(z.MA_Start) || von;
                    const maBis = formatTime(z.MA_Ende) || bis;
                    const statusId = z.Status_ID || z.Status;
                    const isStorno = statusId === 5 || statusId === 6;
                    const isFraglich = statusId === 4;

                    let entryClass = 'ma-entry';
                    if (isStorno) entryClass += ' storno';
                    if (isFraglich) entryClass += ' fraglich';

                    html += `<div class="${entryClass}">
                        <span class="ma-name" title="${escapeHtml(maName)}">${escapeHtml(maName)}</span>
                        <span class="ma-von">${maVon}</span>
                        <span class="ma-bis">${maBis}</span>
                    </div>`;
                }

                // Unbesetzte Positionen anzeigen (gelb)
                const unbesetzt = Math.max(0, soll - zuordnungen.length);
                for (let u = 0; u < unbesetzt; u++) {
                    html += `<div class="ma-entry unbesetzt">
                        <span class="ma-name" title="Unbesetzt">&nbsp;</span>
                        <span class="ma-von">${von}</span>
                        <span class="ma-bis">${bis}</span>
                    </div>`;
                }
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

    // ISO-Datumsformat: "1899-12-30T12:00:00" oder "2026-01-11T12:00:00"
    if (typeof t === 'string' && t.includes('T')) {
        const timePart = t.split('T')[1]; // "12:00:00"
        if (timePart) {
            return timePart.substring(0, 5); // "12:00"
        }
    }

    // Einfache Zeit "12:00:00" oder "12:00"
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

/**
 * Bridge Event-Handler
 */
function handleBridgeData(data) {
    console.log('[DP-Objekt] Bridge Data empfangen:', data);

    if (data.auftraege) {
        state.auftraege = data.auftraege || [];
    }

    if (data.zuordnungen) {
        state.zuordnungen = {};
        (data.zuordnungen || []).forEach(z => {
            const vaId = z.VA_ID;
            const datum = formatDateForInput(new Date(z.VADatum || z.Datum));
            const key = `${vaId}_${datum}`;
            if (!state.zuordnungen[key]) state.zuordnungen[key] = [];
            state.zuordnungen[key].push(z);
        });

        renderCalendar();
        setStatus(`${state.auftraege.length} Aufträge geladen`);
    }

    if (data.error) {
        setStatus('Fehler: ' + data.error);
    }
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.DienstplanObjekt = {
    state,
    loadData,
    exportExcel,
    renderCalendar,
    setStatus
};
