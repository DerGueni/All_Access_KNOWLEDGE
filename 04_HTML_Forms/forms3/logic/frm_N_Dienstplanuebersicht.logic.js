/**
 * frm_N_Dienstplanuebersicht.logic.js
 * Logik fuer Dienstplanuebersicht (Kalenderansicht)
 * REST API Integration auf localhost:5000
 *
 * Erstellt: 2026-01-17
 */

// API Basis-URL
const API_BASE = 'http://localhost:5000/api';

// State
const state = {
    currentWeekStart: null,  // Montag der aktuellen Woche
    startDatum: null,        // Alias fuer currentWeekStart (Kompatibilitaet)
    currentView: 'woche',    // 'woche' oder 'monat'
    einsaetze: [],
    mitarbeiter: [],
    objekte: [],
    selectedEinsatz: null,
    filters: {
        ansicht: 'alle',
        objekt: '',
        ma: '',
        status: '',
        nurFreieSchichten: false  // NEU: Filter fuer freie Schichten
    }
};

// DOM-Elemente
let elements = {};

// Feiertage 2026 (Deutschland)
const FEIERTAGE_2026 = [
    '2026-01-01', // Neujahr
    '2026-04-03', // Karfreitag
    '2026-04-06', // Ostermontag
    '2026-05-01', // Tag der Arbeit
    '2026-05-14', // Christi Himmelfahrt
    '2026-05-25', // Pfingstmontag
    '2026-06-04', // Fronleichnam (Bayern)
    '2026-10-03', // Tag der Deutschen Einheit
    '2026-11-01', // Allerheiligen (Bayern)
    '2026-12-25', // 1. Weihnachtstag
    '2026-12-26'  // 2. Weihnachtstag
];

/**
 * Initialisierung
 */
async function init() {
    console.log('[Dienstplanuebersicht] Initialisierung...');

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
        cboMA: document.getElementById('cboMA'),
        cboStatus: document.getElementById('cboStatus'),
        chkNurFreieSchichten: document.getElementById('chkNurFreieSchichten'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),

        // Kalender
        calendarGrid: document.getElementById('calendarGrid'),
        calendarContainer: document.getElementById('calendarContainer'),

        // Detail Panel
        detailPanel: document.getElementById('detailPanel'),
        btnCloseDetail: document.getElementById('btnCloseDetail'),
        btnEditEinsatz: document.getElementById('btnEditEinsatz'),
        btnPlanung: document.getElementById('btnPlanung'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzEinsaetze: document.getElementById('lblAnzEinsaetze'),

        // Loading
        loadingOverlay: document.getElementById('loadingOverlay'),

        // Buttons
        btnExcel: document.getElementById('btnExcel'),
        btnDrucken: document.getElementById('btnDrucken'),
        btnDPSenden: document.getElementById('btnDPSenden')
    };

    // Event Listener
    setupEventListeners();

    // Gespeichertes Startdatum laden oder aktuelle Woche
    loadSavedStartdatum();
    if (!state.currentWeekStart) {
        state.currentWeekStart = getMonday(new Date());
    }
    // Sync startDatum Alias
    state.startDatum = state.currentWeekStart;

    // Filter laden
    await Promise.all([
        loadObjekte(),
        loadMitarbeiter()
    ]);

    // Wochenanzeige aktualisieren
    updateWeekDisplay();

    // Tag-Header DblClick einrichten
    setupTagHeaderDblClick();

    // Daten laden
    await loadEinsaetze();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    elements.btnVorwoche?.addEventListener('click', () => changeWeek(-1));
    elements.btnNachwoche?.addEventListener('click', () => changeWeek(1));
    elements.btnHeute?.addEventListener('click', gotoToday);
    elements.btnAktualisieren?.addEventListener('click', () => loadEinsaetze());

    elements.datePicker?.addEventListener('change', (e) => {
        const date = new Date(e.target.value);
        if (!isNaN(date)) {
            state.currentWeekStart = getMonday(date);
            updateWeekDisplay();
            loadEinsaetze();
        }
    });

    // Filter
    elements.cboAnsicht?.addEventListener('change', (e) => {
        state.filters.ansicht = e.target.value;
        renderCalendar();
    });

    elements.cboObjekt?.addEventListener('change', (e) => {
        state.filters.objekt = e.target.value;
        renderCalendar();
    });

    elements.cboMA?.addEventListener('change', (e) => {
        state.filters.ma = e.target.value;
        renderCalendar();
    });

    elements.cboStatus?.addEventListener('change', (e) => {
        state.filters.status = e.target.value;
        renderCalendar();
    });

    // Checkbox "Nur freie Schichten"
    elements.chkNurFreieSchichten?.addEventListener('change', filterNurFreieSchichten);

    // Detail Panel
    elements.btnCloseDetail?.addEventListener('click', closeDetailPanel);
    elements.btnEditEinsatz?.addEventListener('click', editEinsatz);
    elements.btnPlanung?.addEventListener('click', openPlanung);

    // View Tabs
    document.querySelectorAll('.view-tab').forEach(tab => {
        tab.addEventListener('click', (e) => {
            document.querySelectorAll('.view-tab').forEach(t => t.classList.remove('active'));
            e.target.classList.add('active');
            state.currentView = e.target.dataset.view;
            updateWeekDisplay();
            loadEinsaetze();
        });
    });

    // Buttons - verwende globale Funktionen fuer onclick-Handler
    elements.btnExcel?.addEventListener('click', () => window.btnExcelExport_Click());
    elements.btnDrucken?.addEventListener('click', printOverview);
    elements.btnDPSenden?.addEventListener('click', () => window.btnDPSenden_Click());

    // Keyboard
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeDetailPanel();
        if (e.key === 'ArrowLeft' && e.ctrlKey) changeWeek(-1);
        if (e.key === 'ArrowRight' && e.ctrlKey) changeWeek(1);
        if (e.key === 'F5') { e.preventDefault(); loadEinsaetze(); }
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
    const days = state.currentView === 'monat' ? delta * 28 : delta * 7;
    const newDate = new Date(state.currentWeekStart);
    newDate.setDate(newDate.getDate() + days);
    state.currentWeekStart = newDate;
    state.startDatum = newDate; // Sync Alias
    saveStartdatum(); // Persistieren
    updateWeekDisplay();
    loadEinsaetze();
}

/**
 * Zu heute springen
 */
function gotoToday() {
    state.currentWeekStart = getMonday(new Date());
    state.startDatum = state.currentWeekStart; // Sync Alias
    saveStartdatum(); // Persistieren
    updateWeekDisplay();
    loadEinsaetze();
}

/**
 * Wochenanzeige aktualisieren
 */
function updateWeekDisplay() {
    const start = state.currentWeekStart;
    let end;

    if (state.currentView === 'monat') {
        end = new Date(start);
        end.setDate(end.getDate() + 27); // 4 Wochen
    } else {
        end = new Date(start);
        end.setDate(end.getDate() + 6);
    }

    const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
    const startStr = start.toLocaleDateString('de-DE', options);
    const endStr = end.toLocaleDateString('de-DE', options);

    // KW berechnen
    const kw = getWeekNumber(start);

    if (state.currentView === 'monat') {
        elements.lblWoche.textContent = `${startStr} - ${endStr}`;
    } else {
        elements.lblWoche.textContent = `KW ${kw}: ${startStr} - ${endStr}`;
    }

    elements.datePicker.value = start.toISOString().split('T')[0];
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
 * Objekte fuer Filter laden
 */
async function loadObjekte() {
    try {
        const response = await fetch(`${API_BASE}/objekte`);
        if (!response.ok) throw new Error('Objekte laden fehlgeschlagen');

        const data = await response.json();
        state.objekte = data.data || data || [];

        elements.cboObjekt.innerHTML = '<option value="">Alle Objekte</option>';
        state.objekte.forEach(obj => {
            const option = document.createElement('option');
            option.value = obj.OB_ID || obj.Objekt_ID || obj.ID;
            option.textContent = obj.OB_Objekt || obj.Objekt || obj.Bezeichnung || '';
            elements.cboObjekt.appendChild(option);
        });

        console.log(`[Dienstplanuebersicht] ${state.objekte.length} Objekte geladen`);

    } catch (error) {
        console.error('[Dienstplanuebersicht] Fehler beim Laden der Objekte:', error);
        elements.cboObjekt.innerHTML = '<option value="">Fehler beim Laden</option>';
    }
}

/**
 * Mitarbeiter fuer Filter laden
 */
async function loadMitarbeiter() {
    try {
        const response = await fetch(`${API_BASE}/mitarbeiter?aktiv=1`);
        if (!response.ok) throw new Error('Mitarbeiter laden fehlgeschlagen');

        const data = await response.json();
        state.mitarbeiter = data.data || data || [];

        elements.cboMA.innerHTML = '<option value="">Alle Mitarbeiter</option>';
        state.mitarbeiter.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID || ma.MA_ID;
            option.textContent = `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`;
            elements.cboMA.appendChild(option);
        });

        console.log(`[Dienstplanuebersicht] ${state.mitarbeiter.length} Mitarbeiter geladen`);

    } catch (error) {
        console.error('[Dienstplanuebersicht] Fehler beim Laden der Mitarbeiter:', error);
        elements.cboMA.innerHTML = '<option value="">Fehler beim Laden</option>';
    }
}

/**
 * Einsaetze laden
 */
async function loadEinsaetze() {
    showLoading(true);
    setStatus('Lade Einsaetze...');

    try {
        const startDate = state.currentWeekStart.toISOString().split('T')[0];
        const endDate = new Date(state.currentWeekStart);

        if (state.currentView === 'monat') {
            endDate.setDate(endDate.getDate() + 27);
        } else {
            endDate.setDate(endDate.getDate() + 6);
        }

        const endDateStr = endDate.toISOString().split('T')[0];

        // Einsatztage/Schichten laden
        const response = await fetch(`${API_BASE}/dienstplan/schichten?von=${startDate}&bis=${endDateStr}`);

        if (!response.ok) {
            // Fallback: auftraege mit einsatztage
            const fallbackResponse = await fetch(`${API_BASE}/auftraege?von=${startDate}&bis=${endDateStr}`);
            if (!fallbackResponse.ok) throw new Error('Daten laden fehlgeschlagen');
            const fallbackData = await fallbackResponse.json();
            state.einsaetze = transformAuftraege(fallbackData.data || fallbackData || []);
        } else {
            const data = await response.json();
            state.einsaetze = transformSchichten(data.data || data || []);
        }

        renderCalendar();
        setStatus(`${state.einsaetze.length} Einsaetze geladen`);
        elements.lblAnzEinsaetze.textContent = `Einsaetze: ${state.einsaetze.length}`;

    } catch (error) {
        console.error('[Dienstplanuebersicht] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
        state.einsaetze = [];
        renderCalendar();
    } finally {
        showLoading(false);
    }
}

/**
 * Schichten-Daten transformieren
 */
function transformSchichten(data) {
    return data.map(e => ({
        ID: e.VAS_ID || e.VADatum_ID || e.ID,
        VA_ID: e.VA_ID || e.Auftrag_ID,
        Datum: e.VADatum || e.Datum,
        Start: e.VA_Start || e.Start || '08:00',
        Ende: e.VA_Ende || e.Ende || '16:00',
        Objekt: e.Objekt || e.VA_Objekt || e.OB_Objekt || '',
        Objekt_ID: e.Objekt_ID || e.OB_ID,
        Status: e.Status || 'Planung',
        MA_Soll: parseInt(e.MA_Anzahl) || parseInt(e.MA_Soll) || 0,
        MA_Ist: parseInt(e.MA_Anzahl_Ist) || parseInt(e.MA_Ist) || 0,
        Bemerkung: e.Bemerkung || '',
        Kunde: e.Kunde || e.Veranstalter || ''
    }));
}

/**
 * Auftraege-Daten transformieren (Fallback)
 */
function transformAuftraege(data) {
    const einsaetze = [];
    data.forEach(auftrag => {
        if (auftrag.einsatztage) {
            auftrag.einsatztage.forEach(tag => {
                einsaetze.push({
                    ID: tag.VADatum_ID || tag.ID,
                    VA_ID: auftrag.VA_ID || auftrag.Auftrag,
                    Datum: tag.VADatum || tag.Datum,
                    Start: tag.VA_Start || '08:00',
                    Ende: tag.VA_Ende || '16:00',
                    Objekt: auftrag.Objekt || auftrag.OB_Objekt || '',
                    Objekt_ID: auftrag.Objekt_ID,
                    Status: tag.Status || auftrag.Status || 'Planung',
                    MA_Soll: parseInt(tag.MA_Anzahl) || 0,
                    MA_Ist: parseInt(tag.MA_Anzahl_Ist) || 0,
                    Bemerkung: tag.Bemerkung || '',
                    Kunde: auftrag.Veranstalter || ''
                });
            });
        }
    });
    return einsaetze;
}

/**
 * Kalender rendern
 */
function renderCalendar() {
    const days = state.currentView === 'monat' ? 28 : 7;
    const wochentage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    // Gefilterte Einsaetze
    const filtered = state.einsaetze.filter(e => {
        if (state.filters.objekt && e.Objekt_ID != state.filters.objekt) return false;
        if (state.filters.status && e.Status !== state.filters.status) return false;
        // NEU: Filter "Nur freie Schichten" (MA_Ist < MA_Soll)
        if (state.filters.nurFreieSchichten && e.MA_Ist >= e.MA_Soll) return false;
        return true;
    });

    // Einsaetze nach Datum gruppieren
    const byDate = {};
    filtered.forEach(einsatz => {
        const dateKey = einsatz.Datum.split('T')[0];
        if (!byDate[dateKey]) byDate[dateKey] = [];
        byDate[dateKey].push(einsatz);
    });

    // HTML aufbauen
    let html = '';

    // Header-Zeile
    html += '<div class="calendar-header ma-col">Datum</div>';

    for (let i = 0; i < days; i++) {
        const date = new Date(state.currentWeekStart);
        date.setDate(date.getDate() + i);

        const dayOfWeek = (i % 7);
        const isWeekend = dayOfWeek >= 5;
        const isToday = isSameDay(date, new Date());
        const dateStr = date.toISOString().split('T')[0];
        const isFeiertag = FEIERTAGE_2026.includes(dateStr);

        let headerClass = 'calendar-header';
        if (isFeiertag) headerClass += ' feiertag';
        else if (isWeekend) headerClass += ' weekend';
        if (isToday) headerClass += ' today';

        const dayName = wochentage[dayOfWeek];
        const dayNum = date.getDate();
        const month = date.getMonth() + 1;

        html += `<div class="${headerClass}">${dayName}<br>${dayNum}.${month}.</div>`;
    }

    // Daten-Zeilen (eine Zeile pro Tag-Uebersicht)
    // Bei Ansicht "alle" zeigen wir eine kompakte Uebersicht

    if (state.filters.ansicht === 'ma' && state.filters.ma) {
        // Einzelner MA - zeige seine Einsaetze
        html += renderMARow(state.filters.ma, days, byDate);
    } else if (state.filters.ansicht === 'objekt' && state.filters.objekt) {
        // Einzelnes Objekt - zeige dessen Einsaetze
        html += renderObjektRow(state.filters.objekt, days, byDate);
    } else {
        // Alle Einsaetze - kompakte Uebersicht nach Objekten
        const objekteInPeriode = [...new Set(filtered.map(e => e.Objekt))].filter(o => o).sort();

        if (objekteInPeriode.length === 0) {
            html += '<div class="calendar-cell-name">Keine Einsaetze</div>';
            for (let i = 0; i < days; i++) {
                html += '<div class="calendar-cell">-</div>';
            }
        } else {
            objekteInPeriode.forEach(objekt => {
                html += renderObjektRowByName(objekt, days, byDate);
            });
        }
    }

    elements.calendarGrid.innerHTML = html;

    // Event Listener fuer Einsatz-Eintraege
    elements.calendarGrid.querySelectorAll('.einsatz-entry').forEach(entry => {
        entry.addEventListener('click', (e) => {
            const id = e.currentTarget.dataset.id;
            const einsatz = state.einsaetze.find(ei => ei.ID == id);
            if (einsatz) showDetail(einsatz);
        });
    });

    // Tag-Header DblClick nach Render neu einrichten
    setupTagHeaderDblClick();

    // Anzahl aktualisieren
    elements.lblAnzEinsaetze.textContent = `Einsaetze: ${filtered.length}`;
}

/**
 * Zeile fuer ein Objekt rendern (nach Name)
 */
function renderObjektRowByName(objektName, days, byDate) {
    let html = `<div class="calendar-cell-name">${objektName}</div>`;

    for (let i = 0; i < days; i++) {
        const date = new Date(state.currentWeekStart);
        date.setDate(date.getDate() + i);

        const dateStr = date.toISOString().split('T')[0];
        const dayOfWeek = (i % 7);
        const isWeekend = dayOfWeek >= 5;
        const isToday = isSameDay(date, new Date());
        const isFeiertag = FEIERTAGE_2026.includes(dateStr);

        let cellClass = 'calendar-cell';
        if (isFeiertag) cellClass += ' feiertag';
        else if (isWeekend) cellClass += ' weekend';
        if (isToday) cellClass += ' today';

        const tagesEinsaetze = (byDate[dateStr] || []).filter(e => e.Objekt === objektName);

        let cellContent = '';
        tagesEinsaetze.forEach(einsatz => {
            const statusClass = getStatusClass(einsatz);
            cellContent += `
                <div class="einsatz-entry ${statusClass}" data-id="${einsatz.ID}" title="${einsatz.Objekt}: ${einsatz.Start}-${einsatz.Ende}">
                    <span class="zeit">${einsatz.Start.substring(0, 5)}</span>
                    <span class="ma-count">${einsatz.MA_Ist}/${einsatz.MA_Soll}</span>
                </div>
            `;
        });

        html += `<div class="${cellClass}">${cellContent || '-'}</div>`;
    }

    return html;
}

/**
 * Zeile fuer einen MA rendern
 */
function renderMARow(maId, days, byDate) {
    const ma = state.mitarbeiter.find(m => (m.ID || m.MA_ID) == maId);
    const maName = ma ? `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}` : 'Mitarbeiter';

    let html = `<div class="calendar-cell-name">${maName}</div>`;

    for (let i = 0; i < days; i++) {
        const date = new Date(state.currentWeekStart);
        date.setDate(date.getDate() + i);

        const dateStr = date.toISOString().split('T')[0];
        const dayOfWeek = (i % 7);
        const isWeekend = dayOfWeek >= 5;
        const isToday = isSameDay(date, new Date());
        const isFeiertag = FEIERTAGE_2026.includes(dateStr);

        let cellClass = 'calendar-cell';
        if (isFeiertag) cellClass += ' feiertag';
        else if (isWeekend) cellClass += ' weekend';
        if (isToday) cellClass += ' today';

        // TODO: MA-spezifische Einsaetze filtern (benoetigt Zuordnungen)
        const tagesEinsaetze = byDate[dateStr] || [];

        let cellContent = '';
        tagesEinsaetze.forEach(einsatz => {
            const statusClass = getStatusClass(einsatz);
            cellContent += `
                <div class="einsatz-entry ${statusClass}" data-id="${einsatz.ID}">
                    <span class="zeit">${einsatz.Start.substring(0, 5)}</span>
                    <span class="objekt">${einsatz.Objekt}</span>
                </div>
            `;
        });

        html += `<div class="${cellClass}">${cellContent || '-'}</div>`;
    }

    return html;
}

/**
 * Zeile fuer ein Objekt rendern (nach ID)
 */
function renderObjektRow(objektId, days, byDate) {
    const objekt = state.objekte.find(o => (o.OB_ID || o.Objekt_ID || o.ID) == objektId);
    const objektName = objekt ? (objekt.OB_Objekt || objekt.Objekt || objekt.Bezeichnung) : 'Objekt';

    let html = `<div class="calendar-cell-name">${objektName}</div>`;

    for (let i = 0; i < days; i++) {
        const date = new Date(state.currentWeekStart);
        date.setDate(date.getDate() + i);

        const dateStr = date.toISOString().split('T')[0];
        const dayOfWeek = (i % 7);
        const isWeekend = dayOfWeek >= 5;
        const isToday = isSameDay(date, new Date());
        const isFeiertag = FEIERTAGE_2026.includes(dateStr);

        let cellClass = 'calendar-cell';
        if (isFeiertag) cellClass += ' feiertag';
        else if (isWeekend) cellClass += ' weekend';
        if (isToday) cellClass += ' today';

        const tagesEinsaetze = (byDate[dateStr] || []).filter(e => e.Objekt_ID == objektId);

        let cellContent = '';
        tagesEinsaetze.forEach(einsatz => {
            const statusClass = getStatusClass(einsatz);
            cellContent += `
                <div class="einsatz-entry ${statusClass}" data-id="${einsatz.ID}">
                    <span class="zeit">${einsatz.Start.substring(0, 5)}-${einsatz.Ende.substring(0, 5)}</span>
                    <span class="ma-count">${einsatz.MA_Ist}/${einsatz.MA_Soll}</span>
                </div>
            `;
        });

        html += `<div class="${cellClass}">${cellContent || '-'}</div>`;
    }

    return html;
}

/**
 * Status-Klasse ermitteln
 */
function getStatusClass(einsatz) {
    if (einsatz.Status === 'Abgesagt') return 'status-problem';
    if (einsatz.MA_Ist < einsatz.MA_Soll) {
        return einsatz.MA_Ist === 0 ? 'status-problem' : 'status-planung';
    }
    return 'status-bestaetigt';
}

/**
 * Pruefen ob gleicher Tag
 */
function isSameDay(date1, date2) {
    return date1.getDate() === date2.getDate() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getFullYear() === date2.getFullYear();
}

/**
 * Detail-Panel anzeigen
 */
async function showDetail(einsatz) {
    state.selectedEinsatz = einsatz;

    // Panel-Felder fuellen
    document.getElementById('detailObjekt').textContent = einsatz.Objekt || '-';
    document.getElementById('detailDatum').textContent =
        new Date(einsatz.Datum).toLocaleDateString('de-DE');
    document.getElementById('detailZeit').textContent =
        `${einsatz.Start} - ${einsatz.Ende}`;
    document.getElementById('detailStatus').textContent = einsatz.Status || '-';
    document.getElementById('detailSoll').textContent = einsatz.MA_Soll;
    document.getElementById('detailIst').textContent = einsatz.MA_Ist;

    // Zugeordnete MA laden
    await loadZuordnungenDetail(einsatz.ID);

    // Panel anzeigen
    elements.detailPanel.classList.add('show');
}

/**
 * Zuordnungen fuer Detail laden
 */
async function loadZuordnungenDetail(vasId) {
    const maList = document.getElementById('detailMAListe');

    try {
        // Versuche Zuordnungen zu laden
        const response = await fetch(`${API_BASE}/zuordnungen?vadatum_id=${vasId}`);

        if (!response.ok) {
            maList.innerHTML = '<li>Keine Daten verfuegbar</li>';
            return;
        }

        const data = await response.json();
        const zuordnungen = data.data || data || [];

        if (zuordnungen.length === 0) {
            maList.innerHTML = '<li>Keine Mitarbeiter zugeordnet</li>';
        } else {
            maList.innerHTML = zuordnungen.map(z => {
                const name = z.MA_Name || `${z.MA_Nachname}, ${z.MA_Vorname}`;
                const status = z.MVP_Status || '';
                return `<li>${name} ${status ? `(${status})` : ''}</li>`;
            }).join('');
        }

    } catch (error) {
        console.error('[Dienstplanuebersicht] Fehler beim Laden der Zuordnungen:', error);
        maList.innerHTML = '<li>Fehler beim Laden</li>';
    }
}

/**
 * Detail-Panel schliessen
 */
function closeDetailPanel() {
    elements.detailPanel.classList.remove('show');
    state.selectedEinsatz = null;
}

/**
 * Einsatz bearbeiten (oeffnet Auftragsstamm)
 */
function editEinsatz() {
    if (!state.selectedEinsatz) return;

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
 * Planung oeffnen
 */
function openPlanung() {
    if (!state.selectedEinsatz) return;

    const va_id = state.selectedEinsatz.VA_ID;

    if (window.parent !== window) {
        window.parent.postMessage({
            action: 'openSchnellauswahl',
            va_id: va_id
        }, '*');
    } else {
        window.open(`frm_MA_VA_Schnellauswahl.html?va_id=${va_id}`, '_blank');
    }
}

/**
 * Datum als ISO-String formatieren (YYYY-MM-DD)
 */
function formatDateISO(date) {
    if (!date) return '';
    const d = new Date(date);
    return d.toISOString().split('T')[0];
}

/**
 * CSV-Export als Fallback
 */
function exportToCSV() {
    console.log('[CSV] Exportiere Dienstplan...');

    const von = state.startDatum || state.currentWeekStart;
    const bis = new Date(von);
    bis.setDate(bis.getDate() + 6);

    // Header
    let csv = 'Datum;Objekt;Start;Ende;MA Soll;MA Ist;Status\n';

    // Daten
    state.einsaetze.forEach(e => {
        csv += `${e.Datum};${e.Objekt};${e.Start};${e.Ende};${e.MA_Soll};${e.MA_Ist};${e.Status}\n`;
    });

    // Download
    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `Dienstplan_${formatDateISO(von)}_bis_${formatDateISO(bis)}.csv`;
    link.click();

    if (typeof Toast !== 'undefined') Toast.success('CSV exportiert');
}

/**
 * Excel Export via VBA Bridge
 */
window.btnExcelExport_Click = async function() {
    console.log('[Excel] Dienstplan exportieren');
    const von = state.startDatum || state.currentWeekStart;
    const bis = new Date(von);
    bis.setDate(bis.getDate() + 6);

    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        try {
            await Bridge.execute('excelExport', {
                typ: 'Dienstplan',
                von: formatDateISO(von),
                bis: formatDateISO(bis)
            });
            if (typeof Toast !== 'undefined') Toast.success('Excel-Export gestartet...');
        } catch (error) {
            console.error('[Excel] Bridge-Fehler:', error);
            // Fallback: CSV-Export
            exportToCSV();
        }
    } else {
        console.log('[Excel] VBA Bridge nicht verfuegbar, nutze CSV-Fallback');
        // Fallback: CSV-Export
        exportToCSV();
    }
};

// Legacy-Alias
function exportToExcel() {
    window.btnExcelExport_Click();
}

/**
 * Drucken
 */
function printOverview() {
    window.print();
}

/**
 * Dienstplaene per E-Mail senden via VBA Bridge
 */
window.btnDPSenden_Click = async function() {
    console.log('[DP] Dienstplaene senden');
    if (!confirm('Dienstplaene an alle angezeigten MA senden?')) return;

    const von = state.startDatum || state.currentWeekStart;
    const bis = new Date(von);
    bis.setDate(bis.getDate() + 6);

    if (typeof Bridge !== 'undefined' && Bridge.execute) {
        try {
            await Bridge.execute('sendeDienstplaene', {
                von: formatDateISO(von),
                bis: formatDateISO(bis)
            });
            if (typeof Toast !== 'undefined') Toast.success('Dienstplaene werden gesendet...');
        } catch (error) {
            console.error('[DP] Bridge-Fehler:', error);
            alert('Fehler beim Senden: ' + error.message);
        }
    } else {
        alert('VBA Bridge nicht verfuegbar. Bitte aus Access heraus oeffnen.');
    }
};

// Legacy-Alias
function sendDienstplaene() {
    window.btnDPSenden_Click();
}

/**
 * Filter: Nur freie Schichten (MA_Ist < MA_Soll)
 */
window.filterNurFreieSchichten = function() {
    state.filters.nurFreieSchichten = document.getElementById('chkNurFreieSchichten')?.checked || false;
    console.log('[Filter] Nur freie Schichten:', state.filters.nurFreieSchichten);
    renderCalendar();
};

/**
 * Tag-Header DblClick - Springt zu diesem Tag als neues Startdatum
 */
function setupTagHeaderDblClick() {
    // Muss nach jedem renderCalendar() neu aufgerufen werden
    setTimeout(() => {
        document.querySelectorAll('.calendar-header:not(.ma-col)').forEach((header, idx) => {
            header.addEventListener('dblclick', () => {
                const newStart = new Date(state.currentWeekStart);
                newStart.setDate(newStart.getDate() + idx);
                state.currentWeekStart = getMonday(newStart); // Montag der gewaehlten Woche
                state.startDatum = state.currentWeekStart;
                saveStartdatum();
                updateWeekDisplay();
                loadEinsaetze();
            });
            header.style.cursor = 'pointer';
            header.title = 'Doppelklick: Zu dieser Woche springen';
        });
    }, 100);
}

/**
 * Startdatum in localStorage speichern
 */
function saveStartdatum() {
    try {
        const dateToSave = state.startDatum || state.currentWeekStart;
        if (dateToSave) {
            localStorage.setItem('dp_startdatum', dateToSave.toISOString());
            console.log('[Storage] Startdatum gespeichert:', dateToSave.toISOString());
        }
    } catch (e) {
        console.warn('[Storage] Speichern fehlgeschlagen:', e);
    }
}

/**
 * Gespeichertes Startdatum aus localStorage laden
 */
function loadSavedStartdatum() {
    try {
        const saved = localStorage.getItem('dp_startdatum');
        if (saved) {
            const parsedDate = new Date(saved);
            if (!isNaN(parsedDate.getTime())) {
                state.currentWeekStart = getMonday(parsedDate);
                state.startDatum = state.currentWeekStart;
                console.log('[Storage] Startdatum geladen:', state.currentWeekStart.toISOString());
            }
        }
    } catch (e) {
        console.warn('[Storage] Laden fehlgeschlagen:', e);
    }
}

/**
 * Loading-Overlay
 */
function showLoading(show) {
    if (show) {
        elements.loadingOverlay?.classList.add('show');
    } else {
        elements.loadingOverlay?.classList.remove('show');
    }
}

/**
 * Status setzen
 */
function setStatus(text) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = text;
    }
}

// Shell-Modus erkennen
function checkShellMode() {
    if (window.parent !== window || window.location.search.includes('shell=true')) {
        document.body.classList.add('shell-mode');
    }
}

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', () => {
    checkShellMode();
    init();
});

// Globaler Zugriff
window.Dienstplan = {
    loadEinsaetze,
    changeWeek,
    gotoToday,
    editEinsatz,
    refresh: loadEinsaetze,
    exportToExcel,
    exportToCSV,
    sendDienstplaene,
    filterNurFreieSchichten: window.filterNurFreieSchichten,
    saveStartdatum,
    loadSavedStartdatum
};
