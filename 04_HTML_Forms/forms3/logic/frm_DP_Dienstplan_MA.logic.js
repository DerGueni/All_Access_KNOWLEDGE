/**
 * frm_DP_Dienstplan_MA.logic.js
 * Logik für Mitarbeiter-Dienstplanübersicht
 * WebView2 Bridge Integration
 */

// State
const state = {
    startDate: new Date(),
    mitarbeiter: [],
    dienstplaene: {},
    filter: 1 // 1=Alle aktiven, 0=Alle, 2=Festangestellte, 3=Minijobber, 4=Sub
};

// DOM-Elemente
let elements = {};

// KW-Dropdown befüllen
function populateKWDropdown() {
    const select = document.getElementById('cboKW');
    if (!select) return;

    // KW 1-53
    for (let kw = 1; kw <= 53; kw++) {
        const option = document.createElement('option');
        option.value = kw;
        option.textContent = kw.toString().padStart(2, '0');
        select.appendChild(option);
    }

    // Aktuelle KW auswählen
    select.value = getWeekNumber(new Date());
}

// ISO Kalenderwoche berechnen
function getWeekNumber(date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

// Montag einer bestimmten KW berechnen
function getMondayOfWeek(kw, year) {
    const jan4 = new Date(year, 0, 4);
    const dayOfWeek = jan4.getDay() || 7;
    const monday = new Date(jan4);
    monday.setDate(jan4.getDate() - dayOfWeek + 1 + (kw - 1) * 7);
    return monday;
}

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

    // KW-Dropdown befüllen
    populateKWDropdown();

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

    // WebView2 Bridge Event-Listener registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
    }

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

    // KW-Dropdown Event: Bei Auswahl zur gewählten KW springen
    const cboKW = document.getElementById('cboKW');
    if (cboKW) {
        cboKW.addEventListener('change', (e) => {
            const selectedKW = parseInt(e.target.value);
            const year = state.startDate.getFullYear();
            state.startDate = getMondayOfWeek(selectedKW, year);
            updateDateInputs();
            loadDienstplan();
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

    // Tag-Label DblClick Handler (Access: lbl_Tag_*_DblClick)
    // Ermöglicht schnelle Navigation zum gewählten Tag
    setupTagLabelDblClick();
}

/**
 * Access: lbl_Tag_*_DblClick - Schnellnavigation zum Tag
 * VBA Original: Springt zur Einsatzübersicht für den geklickten Tag
 */
function setupTagLabelDblClick() {
    for (let i = 1; i <= 7; i++) {
        const label = document.getElementById(`lbl_Tag_${i}`);
        if (label) {
            label.style.cursor = 'pointer';
            label.title = 'Doppelklick: Zur Tagesübersicht springen';

            label.addEventListener('dblclick', () => {
                // Datum für diesen Tag berechnen
                const targetDate = new Date(state.startDate);
                targetDate.setDate(targetDate.getDate() + (i - 1));

                const dateStr = formatDateForInput(targetDate);
                const dateDisplay = targetDate.toLocaleDateString('de-DE');

                console.log(`[lbl_Tag_${i}_DblClick] Springe zu:`, dateDisplay);

                // Option 1: Zur Einsatzübersicht mit diesem Datum springen
                if (window.parent?.ConsysShell?.showForm) {
                    localStorage.setItem('consec_datum', dateStr);
                    window.parent.ConsysShell.showForm('einsatzuebersicht');
                } else {
                    // Option 2: Fallback - Einsatzübersicht in neuem Fenster öffnen
                    window.open(`frm_Einsatzuebersicht.html?datum=${dateStr}`, 'Einsatzuebersicht', 'width=1200,height=800');
                }
            });
        }
    }
    console.log('[DP-MA] Tag-Label DblClick Handler registriert');
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

    // KW-Dropdown synchronisieren
    const cboKW = document.getElementById('cboKW');
    if (cboKW) {
        cboKW.value = getWeekNumber(state.startDate);
    }

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
        const params = { filter: state.filter };

        // WebView2 Bridge: Mitarbeiter laden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadMitarbeiter', params);
        } else {
            state.mitarbeiter = [];
            console.log('[DP-MA] Bridge nicht verfügbar');
        }

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

        // WebView2 Bridge: Dienstpläne laden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadDienstplan', {
                von: startStr,
                bis: endStr,
                filter: state.filter
            });
        } else {
            state.dienstplaene = {};
            renderWochenansicht();
        }

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
        if (typeof Toast !== 'undefined') Toast.warning('Bitte Enddatum auswählen');
        else alert('Bitte Enddatum auswählen');
        return;
    }

    if (!confirm(`Dienstpläne bis ${endDatum} per E-Mail senden?`)) {
        return;
    }

    setStatus('Sende Dienstpläne...');

    try {
        // Dienstpläne über API versenden
        const result = await Bridge.execute('sendDienstplaene', {
            start_datum: formatDateForInput(state.startDate),
            end_datum: endDatum,
            mitarbeiter_ids: state.mitarbeiter.map(m => m.MA_ID || m.ID)
        });

        if (result && result.success) {
            const anzahl = result.gesendet || 0;
            setStatus(`${anzahl} Dienstpläne versendet`);
            if (typeof Toast !== 'undefined') {
                Toast.success(`${anzahl} Dienstpläne erfolgreich versendet`);
            } else {
                alert(`${anzahl} Dienstpläne erfolgreich versendet`);
            }
        } else {
            throw new Error(result?.message || 'Versand fehlgeschlagen');
        }
    } catch (error) {
        console.error('[DP-MA] Fehler beim Senden:', error);
        setStatus('Fehler beim Senden');
        if (typeof Toast !== 'undefined') {
            Toast.error('Fehler beim Senden: ' + error.message);
        } else {
            alert('Fehler beim Senden: ' + error.message);
        }
    }
}

/**
 * Einzeldienstpläne öffnen
 */
function openEinzeldienstplaene() {
    // Einzeldienstplan-Formular öffnen
    const startDatum = formatDateForInput(state.startDate);
    const url = `frm_DP_Einzeldienstplaene.html?start=${startDatum}`;
    window.open(url, 'Einzeldienstplaene', 'width=800,height=600,menubar=no,toolbar=no,scrollbars=yes');
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
        if (typeof Toast !== 'undefined') Toast.error('Fehler beim Export: ' + error.message);
        else alert('Fehler beim Export: ' + error.message);
        setStatus('Fehler beim Export');
    }
}

/**
 * Excel-Export senden
 */
async function sendExcel() {
    const confirmed = typeof Toast !== 'undefined'
        ? await Toast.confirm('Übersicht per E-Mail senden?')
        : confirm('Übersicht per E-Mail senden?');

    if (!confirmed) return;

    setStatus('Sende Übersicht...');

    try {
        // CSV erstellen und über API versenden
        const csvData = generateCSVData();
        const result = await Bridge.execute('sendDienstplanUebersicht', {
            start_datum: formatDateForInput(state.startDate),
            csv_data: csvData,
            empfaenger: 'planung@consec.de' // Default oder konfigurierbar
        });

        if (result && result.success) {
            setStatus('Übersicht versendet');
            if (typeof Toast !== 'undefined') {
                Toast.success('Übersicht erfolgreich per E-Mail versendet');
            } else {
                alert('Übersicht erfolgreich per E-Mail versendet');
            }
        } else {
            throw new Error(result?.message || 'Versand fehlgeschlagen');
        }
    } catch (error) {
        console.error('[DP-MA] Fehler beim Senden:', error);
        setStatus('Fehler beim Senden');
        if (typeof Toast !== 'undefined') {
            Toast.error('Fehler beim Senden: ' + error.message);
        } else {
            alert('Fehler beim Senden: ' + error.message);
        }
    }
}

/**
 * CSV-Daten für Export generieren
 */
function generateCSVData() {
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

    return rows.map(row => row.map(cell => `"${cell}"`).join(';')).join('\n');
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

/**
 * Bridge Event-Handler
 */
function handleBridgeData(data) {
    console.log('[DP-MA] Bridge Data empfangen:', data);

    if (data.mitarbeiter) {
        state.mitarbeiter = data.mitarbeiter || [];
        console.log(`[DP-MA] ${state.mitarbeiter.length} Mitarbeiter geladen`);
    }

    if (data.dienstplan) {
        // Dienstplandaten nach MA_ID gruppieren
        state.dienstplaene = {};
        (data.dienstplan || []).forEach(eintrag => {
            const maId = eintrag.MA_ID || eintrag.ID;
            if (!state.dienstplaene[maId]) {
                state.dienstplaene[maId] = [];
            }
            state.dienstplaene[maId].push(eintrag);
        });

        renderWochenansicht();
        setStatus(`${state.mitarbeiter.length} Mitarbeiter geladen`);
    }

    if (data.error) {
        setStatus('Fehler: ' + data.error);
    }
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);

// Globaler Zugriff
window.DienstplanMA = {
    loadDienstplan,
    exportExcel
};
