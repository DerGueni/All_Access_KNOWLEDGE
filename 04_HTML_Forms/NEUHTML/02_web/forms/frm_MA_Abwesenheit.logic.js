/**
 * frm_MA_Abwesenheit.logic.js
 * Logik für Mitarbeiter-Abwesenheit
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../js/webview2-bridge.js';

// State
const state = {
    records: [],
    currentIndex: -1,
    currentRecord: null,
    isDirty: false,
    maLookup: [],
    filterMA: '',
    calendarMonth: new Date()
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Abwesenheit] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Toolbar
        btnErster: document.getElementById('btnErster'),
        btnVorheriger: document.getElementById('btnVorheriger'),
        btnNaechster: document.getElementById('btnNaechster'),
        btnLetzter: document.getElementById('btnLetzter'),
        btnNeu: document.getElementById('btnNeu'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLoeschen'),
        cboMitarbeiter: document.getElementById('cboMitarbeiter'),
        txtSuche: document.getElementById('txtSuche'),
        btnSuchen: document.getElementById('btnSuchen'),

        // Infos
        lblRecordInfo: document.getElementById('lblRecordInfo'),
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl'),

        // Felder
        NV_ID: document.getElementById('NV_ID'),
        NV_MA_ID: document.getElementById('NV_MA_ID'),
        NV_VonDat: document.getElementById('NV_VonDat'),
        NV_BisDat: document.getElementById('NV_BisDat'),
        NV_Grund: document.getElementById('NV_Grund'),
        NV_Ganztaegig: document.getElementById('NV_Ganztaegig'),
        NV_VonZeit: document.getElementById('NV_VonZeit'),
        NV_BisZeit: document.getElementById('NV_BisZeit'),
        NV_Bemerkung: document.getElementById('NV_Bemerkung'),
        rowZeiten: document.getElementById('rowZeiten'),

        // Kalender
        calendarPreview: document.getElementById('calendarPreview'),

        // Liste
        tbodyListe: document.getElementById('tbody_Liste')
    };

    // Event Listener
    setupEventListeners();

    // Mitarbeiter laden
    await loadMitarbeiter();

    // Daten laden
    await loadList();

    // Kalender rendern
    renderCalendar();

    setStatus('Bereit');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    elements.btnErster.addEventListener('click', () => gotoRecord(0));
    elements.btnVorheriger.addEventListener('click', () => gotoRecord(state.currentIndex - 1));
    elements.btnNaechster.addEventListener('click', () => gotoRecord(state.currentIndex + 1));
    elements.btnLetzter.addEventListener('click', () => gotoRecord(state.records.length - 1));

    // Aktionen
    elements.btnNeu.addEventListener('click', newRecord);
    elements.btnSpeichern.addEventListener('click', saveRecord);
    elements.btnLoeschen.addEventListener('click', deleteRecord);

    // Filter
    elements.cboMitarbeiter.addEventListener('change', (e) => {
        state.filterMA = e.target.value;
        loadList();
    });

    // Suche
    elements.btnSuchen.addEventListener('click', searchRecords);
    elements.txtSuche.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') searchRecords();
    });

    // Ganztägig Toggle
    elements.NV_Ganztaegig.addEventListener('change', (e) => {
        elements.rowZeiten.style.display = e.target.checked ? 'none' : 'flex';
        state.isDirty = true;
    });

    // Datum-Änderung für Kalender-Update
    elements.NV_VonDat.addEventListener('change', () => {
        state.isDirty = true;
        updateCalendarHighlight();
    });

    elements.NV_BisDat.addEventListener('change', () => {
        state.isDirty = true;
        updateCalendarHighlight();
    });

    // Feldänderungen tracken
    const fields = ['NV_MA_ID', 'NV_Grund', 'NV_VonZeit', 'NV_BisZeit', 'NV_Bemerkung'];
    fields.forEach(field => {
        const el = elements[field];
        if (el) {
            el.addEventListener('change', () => { state.isDirty = true; });
            el.addEventListener('input', () => { state.isDirty = true; });
        }
    });
}

/**
 * Mitarbeiter für Lookup laden
 */
async function loadMitarbeiter() {
    try {
        const result = await Bridge.mitarbeiter.list({ aktiv: true });

        state.maLookup = (result.data || []).map(ma => ({
            ID: ma.MA_ID || ma.ID,
            Name: `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`
        }));

        // Filter-Dropdown füllen
        elements.cboMitarbeiter.innerHTML = '<option value="">Alle Mitarbeiter</option>';
        state.maLookup.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = ma.Name;
            elements.cboMitarbeiter.appendChild(option);
        });

        // Formular-Dropdown füllen
        elements.NV_MA_ID.innerHTML = '<option value="">-- Mitarbeiter wählen --</option>';
        state.maLookup.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = ma.Name;
            elements.NV_MA_ID.appendChild(option);
        });

    } catch (error) {
        console.error('[Abwesenheit] Fehler beim Laden der Mitarbeiter:', error);
    }
}

/**
 * Abwesenheiten laden
 */
async function loadList() {
    setStatus('Lade Abwesenheiten...');

    try {
        const params = {};
        if (state.filterMA) {
            params.ma_id = state.filterMA;
        }

        // Nichtverfügbarkeiten laden
        const result = await Bridge.query(`
            SELECT nv.*, ma.Nachname, ma.Vorname
            FROM tbl_MA_NVerfuegZeiten nv
            LEFT JOIN tbl_MA_Mitarbeiterstamm ma ON nv.MA_ID = ma.ID
            ${state.filterMA ? `WHERE nv.MA_ID = ${state.filterMA}` : ''}
            ORDER BY nv.vonDat DESC
        `);

        state.records = (result.data || []).map(rec => ({
            ID: rec.ID || rec.NV_ID,
            MA_ID: rec.MA_ID,
            MA_Name: `${rec.Nachname || ''}, ${rec.Vorname || ''}`,
            VonDat: rec.vonDat || rec.VonDat,
            BisDat: rec.bisDat || rec.BisDat,
            Grund: rec.Grund || 'Sonstiges',
            Ganztaegig: rec.Ganztaegig !== false,
            VonZeit: rec.vonZeit || rec.VonZeit,
            BisZeit: rec.bisZeit || rec.BisZeit,
            Bemerkung: rec.Bemerkung || ''
        }));

        renderList();

        if (state.records.length > 0) {
            gotoRecord(0);
        } else {
            clearForm();
        }

        setStatus(`${state.records.length} Abwesenheiten geladen`);
        elements.lblAnzahl.textContent = state.records.length;

    } catch (error) {
        console.error('[Abwesenheit] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Liste rendern
 */
function renderList() {
    if (state.records.length === 0) {
        elements.tbodyListe.innerHTML = `
            <tr>
                <td colspan="4" style="text-align:center; color:#666; padding:20px;">
                    Keine Abwesenheiten gefunden
                </td>
            </tr>
        `;
        return;
    }

    elements.tbodyListe.innerHTML = state.records.map((rec, idx) => {
        const von = formatDisplayDate(rec.VonDat);
        const bis = formatDisplayDate(rec.BisDat);
        const grundClass = rec.Grund ? rec.Grund.toLowerCase() : 'sonstiges';
        const selected = idx === state.currentIndex ? 'selected' : '';

        return `
            <tr data-index="${idx}" class="${selected}">
                <td>${rec.MA_Name}</td>
                <td>${von}</td>
                <td>${bis}</td>
                <td><span class="grund-badge ${grundClass}">${rec.Grund}</span></td>
            </tr>
        `;
    }).join('');

    // Click-Handler
    elements.tbodyListe.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            const idx = parseInt(row.dataset.index);
            gotoRecord(idx);
        });
    });
}

/**
 * Datum formatieren für Anzeige
 */
function formatDisplayDate(dateStr) {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleDateString('de-DE');
}

/**
 * Datum formatieren für Input
 */
function formatInputDate(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toISOString().split('T')[0];
}

/**
 * Zu Datensatz navigieren
 */
function gotoRecord(index) {
    if (state.isDirty) {
        if (!confirm('Änderungen verwerfen?')) return;
    }

    if (index < 0) index = 0;
    if (index >= state.records.length) index = state.records.length - 1;
    if (index < 0) return;

    state.currentIndex = index;
    state.currentRecord = state.records[index];
    state.isDirty = false;

    displayRecord(state.currentRecord);

    // Liste aktualisieren
    elements.tbodyListe.querySelectorAll('tr').forEach((row, idx) => {
        row.classList.toggle('selected', idx === index);
    });

    const selectedRow = elements.tbodyListe.querySelector('tr.selected');
    selectedRow?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

    updateRecordInfo();
    updateCalendarHighlight();
}

/**
 * Datensatz anzeigen
 */
function displayRecord(rec) {
    elements.NV_ID.value = rec.ID || '';
    elements.NV_MA_ID.value = rec.MA_ID || '';
    elements.NV_VonDat.value = formatInputDate(rec.VonDat);
    elements.NV_BisDat.value = formatInputDate(rec.BisDat);
    elements.NV_Grund.value = rec.Grund || '';
    elements.NV_Ganztaegig.checked = rec.Ganztaegig !== false;
    elements.NV_VonZeit.value = rec.VonZeit || '';
    elements.NV_BisZeit.value = rec.BisZeit || '';
    elements.NV_Bemerkung.value = rec.Bemerkung || '';

    elements.rowZeiten.style.display = rec.Ganztaegig ? 'none' : 'flex';
}

/**
 * Formular leeren
 */
function clearForm() {
    state.currentRecord = null;
    state.currentIndex = -1;
    state.isDirty = false;

    elements.NV_ID.value = '';
    elements.NV_MA_ID.value = '';
    elements.NV_VonDat.value = '';
    elements.NV_BisDat.value = '';
    elements.NV_Grund.value = '';
    elements.NV_Ganztaegig.checked = true;
    elements.NV_VonZeit.value = '';
    elements.NV_BisZeit.value = '';
    elements.NV_Bemerkung.value = '';
    elements.rowZeiten.style.display = 'none';

    updateRecordInfo();
}

/**
 * Neuer Datensatz
 */
function newRecord() {
    if (state.isDirty) {
        if (!confirm('Änderungen verwerfen?')) return;
    }

    clearForm();

    // Heute als Standard
    const heute = new Date().toISOString().split('T')[0];
    elements.NV_VonDat.value = heute;
    elements.NV_BisDat.value = heute;

    elements.NV_MA_ID.focus();
    setStatus('Neue Abwesenheit');
}

/**
 * Speichern
 */
async function saveRecord() {
    // Validierung
    const ma_id = elements.NV_MA_ID.value;
    if (!ma_id) {
        alert('Bitte Mitarbeiter auswählen');
        elements.NV_MA_ID.focus();
        return;
    }

    const vonDat = elements.NV_VonDat.value;
    const bisDat = elements.NV_BisDat.value;

    if (!vonDat || !bisDat) {
        alert('Bitte Von- und Bis-Datum eingeben');
        return;
    }

    if (new Date(bisDat) < new Date(vonDat)) {
        alert('Bis-Datum muss nach Von-Datum liegen');
        return;
    }

    const data = {
        MA_ID: parseInt(ma_id),
        vonDat: vonDat,
        bisDat: bisDat,
        Grund: elements.NV_Grund.value || 'Sonstiges',
        Ganztaegig: elements.NV_Ganztaegig.checked,
        vonZeit: elements.NV_Ganztaegig.checked ? null : elements.NV_VonZeit.value,
        bisZeit: elements.NV_Ganztaegig.checked ? null : elements.NV_BisZeit.value,
        Bemerkung: elements.NV_Bemerkung.value.trim()
    };

    try {
        setStatus('Speichere...');

        const id = elements.NV_ID.value;

        if (id) {
            await Bridge.execute('updateNVerfueg', { id, ...data });
        } else {
            await Bridge.execute('createNVerfueg', data);
        }

        state.isDirty = false;
        setStatus('Gespeichert');

        await loadList();

    } catch (error) {
        console.error('[Abwesenheit] Fehler beim Speichern:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Speichern: ' + error.message);
    }
}

/**
 * Löschen
 */
async function deleteRecord() {
    const id = elements.NV_ID.value;
    if (!id) {
        alert('Kein Datensatz ausgewählt');
        return;
    }

    if (!confirm('Abwesenheit wirklich löschen?')) return;

    try {
        setStatus('Lösche...');

        await Bridge.execute('deleteNVerfueg', { id });

        setStatus('Gelöscht');
        await loadList();

    } catch (error) {
        console.error('[Abwesenheit] Fehler beim Löschen:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler beim Löschen: ' + error.message);
    }
}

/**
 * Suchen
 */
async function searchRecords() {
    const term = elements.txtSuche.value.trim().toLowerCase();

    if (!term) {
        await loadList();
        return;
    }

    const filtered = state.records.filter(rec =>
        rec.MA_Name.toLowerCase().includes(term) ||
        (rec.Bemerkung && rec.Bemerkung.toLowerCase().includes(term)) ||
        (rec.Grund && rec.Grund.toLowerCase().includes(term))
    );

    state.records = filtered;
    renderList();

    if (filtered.length > 0) {
        gotoRecord(0);
    } else {
        clearForm();
    }

    setStatus(`${filtered.length} Treffer`);
}

/**
 * Mini-Kalender rendern
 */
function renderCalendar() {
    const month = state.calendarMonth;
    const year = month.getFullYear();
    const monthNum = month.getMonth();

    // Navigation
    let html = `
        <div class="calendar-nav">
            <button id="btnPrevMonth">◀</button>
            <span class="calendar-month">${month.toLocaleDateString('de-DE', { month: 'long', year: 'numeric' })}</span>
            <button id="btnNextMonth">▶</button>
        </div>
    `;

    // Wochentage Header
    const tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    tage.forEach(t => {
        html += `<div class="calendar-header-day">${t}</div>`;
    });

    // Erster Tag des Monats
    const firstDay = new Date(year, monthNum, 1);
    let startDay = firstDay.getDay() - 1;
    if (startDay < 0) startDay = 6;

    // Letzter Tag des Monats
    const lastDay = new Date(year, monthNum + 1, 0).getDate();

    // Tage des vorherigen Monats
    const prevMonthLast = new Date(year, monthNum, 0).getDate();

    // Heute
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Von/Bis aus Form
    const vonStr = elements.NV_VonDat.value;
    const bisStr = elements.NV_BisDat.value;
    const vonDate = vonStr ? new Date(vonStr) : null;
    const bisDate = bisStr ? new Date(bisStr) : null;

    let dayCount = 1;
    let nextMonthDay = 1;

    for (let i = 0; i < 42; i++) {
        let dayNum, dateObj, classes = ['calendar-day'];

        if (i < startDay) {
            // Vorheriger Monat
            dayNum = prevMonthLast - startDay + i + 1;
            dateObj = new Date(year, monthNum - 1, dayNum);
            classes.push('other-month');
        } else if (dayCount <= lastDay) {
            // Aktueller Monat
            dayNum = dayCount;
            dateObj = new Date(year, monthNum, dayNum);
            dayCount++;
        } else {
            // Nächster Monat
            dayNum = nextMonthDay;
            dateObj = new Date(year, monthNum + 1, dayNum);
            classes.push('other-month');
            nextMonthDay++;
        }

        // Heute
        if (dateObj.getTime() === today.getTime()) {
            classes.push('today');
        }

        // In Range prüfen
        if (vonDate && bisDate) {
            const d = dateObj.getTime();
            if (d >= vonDate.getTime() && d <= bisDate.getTime()) {
                classes.push('in-range');
            }
            if (d === vonDate.getTime() || d === bisDate.getTime()) {
                classes.push('selected');
            }
        }

        html += `<div class="${classes.join(' ')}" data-date="${dateObj.toISOString().split('T')[0]}">${dayNum}</div>`;

        if (i >= 41 || (i >= 34 && nextMonthDay > 7)) break;
    }

    elements.calendarPreview.innerHTML = html;

    // Event Listener für Navigation
    document.getElementById('btnPrevMonth')?.addEventListener('click', () => {
        state.calendarMonth.setMonth(state.calendarMonth.getMonth() - 1);
        renderCalendar();
    });

    document.getElementById('btnNextMonth')?.addEventListener('click', () => {
        state.calendarMonth.setMonth(state.calendarMonth.getMonth() + 1);
        renderCalendar();
    });

    // Click auf Tag
    elements.calendarPreview.querySelectorAll('.calendar-day').forEach(day => {
        day.addEventListener('click', () => {
            const dateStr = day.dataset.date;
            if (!elements.NV_VonDat.value) {
                elements.NV_VonDat.value = dateStr;
                elements.NV_BisDat.value = dateStr;
            } else if (!elements.NV_BisDat.value || elements.NV_VonDat.value === elements.NV_BisDat.value) {
                if (new Date(dateStr) >= new Date(elements.NV_VonDat.value)) {
                    elements.NV_BisDat.value = dateStr;
                } else {
                    elements.NV_VonDat.value = dateStr;
                }
            } else {
                elements.NV_VonDat.value = dateStr;
                elements.NV_BisDat.value = dateStr;
            }
            state.isDirty = true;
            updateCalendarHighlight();
        });
    });
}

/**
 * Kalender-Markierung aktualisieren
 */
function updateCalendarHighlight() {
    renderCalendar();
}

/**
 * Datensatz-Info aktualisieren
 */
function updateRecordInfo() {
    if (state.currentIndex >= 0) {
        elements.lblRecordInfo.textContent =
            `Datensatz: ${state.currentIndex + 1} / ${state.records.length}`;
    } else {
        elements.lblRecordInfo.textContent = 'Datensatz: - / -';
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
window.Abwesenheit = {
    loadList,
    gotoRecord,
    newRecord,
    saveRecord
};
