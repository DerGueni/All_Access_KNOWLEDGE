/**
 * frm_abwesenheitsuebersicht.logic.js
import { Bridge } from '../api/bridgeClient.js';

const ANSTELLUNGSART_FILTERS = {
    '': 'Beide',
    '3': 'Minijobber',
    '5': 'Festangestellte'
};

const state = {
    month: new Date().getMonth() + 1,
    year: new Date().getFullYear(),
    anstellungsart: '',
    mitarbeiter: [],
    rawRecords: [],
    dayEntries: [],
    filteredEntries: [],
    selectedMaId: null,
    selectedDayId: null
};

let elements = {};

document.addEventListener('DOMContentLoaded', init);

async function init() {
    cacheElements();
    setupMonthSelect();
    setupEventListeners();

    await loadMitarbeiter();
    await loadAbwesenheiten();

    renderMitarbeiterList();
    applyFilters();
    setStatus('Bereit');
}

function cacheElements() {
    elements = {
        cboMonat: document.getElementById('cboMonat'),
        txtJahr: document.getElementById('txtJahr'),
        cboAnstellungsart: document.getElementById('cboAnstellungsart'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        maList: document.getElementById('maList'),
        tbodyTage: document.getElementById('tbodyTage'),
        detailDatum: document.getElementById('detailDatum'),
        detailMitarbeiter: document.getElementById('detailMitarbeiter'),
        detailArt: document.getElementById('detailArt'),
        detailZeitraum: document.getElementById('detailZeitraum'),
        detailBemerkung: document.getElementById('detailBemerkung'),
        lblStatus: document.getElementById('lblStatus'),
        lblRecordInfo: document.getElementById('lblRecordInfo')
    };
}

function setupMonthSelect() {
    const months = ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'];
    elements.cboMonat.innerHTML = months.map((m, idx) => `<option value="${idx + 1}">${m}</option>`).join('');
    elements.cboMonat.value = state.month;
    elements.txtJahr.value = state.year;
}

function setupEventListeners() {
    elements.cboMonat.addEventListener('change', () => {
        state.month = parseInt(elements.cboMonat.value, 10);
        loadAbwesenheiten();
    });

    elements.txtJahr.addEventListener('change', () => {
        state.year = parseInt(elements.txtJahr.value, 10) || state.year;
        loadAbwesenheiten();
    });

    elements.cboAnstellungsart.addEventListener('change', () => {
        state.anstellungsart = elements.cboAnstellungsart.value;
        applyFilters();
    });

    elements.btnAktualisieren.addEventListener('click', () => {
        loadAbwesenheiten();
    });

    elements.maList.addEventListener('click', event => {
        const item = event.target.closest('.ma-item');
        if (!item) return;
        const maId = parseInt(item.dataset.id, 10);
        state.selectedMaId = state.selectedMaId === maId ? null : maId;
        renderMitarbeiterList();
        applyFilters();
    });

    elements.tbodyTage.addEventListener('click', event => {
        const row = event.target.closest('tr[data-day-id]');
        if (!row) return;
        selectDay(row.dataset.dayId);
    });
}

async function loadMitarbeiter() {
    try {
        setStatus('Lade Mitarbeiter...');
        const result = await Bridge.query(`
            SELECT ID, Nachname, Vorname, Anstellungsart_ID
            FROM tbl_MA_Mitarbeiterstamm
            WHERE IstAktiv = -1
            ORDER BY Nachname, Vorname
        `);

        state.mitarbeiter = (result.data || []).map(rec => ({
            ID: rec.ID,
            Nachname: rec.Nachname || '',
            Vorname: rec.Vorname || '',
            Name: `${rec.Nachname || ''}, ${rec.Vorname || ''}`,
            Anstellungsart_ID: rec.Anstellungsart_ID
        }));
    } catch (error) {
        console.error('[Abwesenheitsübersicht] Fehler beim Laden der Mitarbeiter:', error);
        setStatus('Fehler beim Laden der Mitarbeiter');
    }
}

async function loadAbwesenheiten() {
    try {
        setStatus('Lade Tagesdaten...');

        const monthStart = new Date(state.year, state.month - 1, 1);
        const monthEnd = new Date(state.year, state.month, 0);
        const von = formatForAccess(monthStart);
        const bis = formatForAccess(monthEnd);

        const result = await Bridge.query(`
            SELECT nv.ID,
                   nv.MA_ID,
                   nv.vonDat,
                   nv.bisDat,
                   nv.Grund,
                   nv.Bemerkung,
                   ma.Nachname,
                   ma.Vorname,
                   ma.Anstellungsart_ID
            FROM tbl_MA_NVerfuegZeiten AS nv
            INNER JOIN tbl_MA_Mitarbeiterstamm AS ma ON ma.ID = nv.MA_ID
            WHERE ma.IstAktiv = -1
              AND nv.vonDat <= #${bis}#
              AND nv.bisDat >= #${von}#
            ORDER BY ma.Nachname, ma.Vorname, nv.vonDat
        `);

        state.rawRecords = result.data || [];
        buildDayEntries();
        applyFilters();

        setStatus(`${state.dayEntries.length} Tage generiert`);
    } catch (error) {
        console.error('[Abwesenheitsübersicht] Fehler beim Laden der Abwesenheiten:', error);
        setStatus('Fehler beim Laden der Abwesenheiten');
    }
}

function buildDayEntries() {
    const entries = [];

    state.rawRecords.forEach(rec => {
        const start = parseDate(rec.vonDat);
        const end = parseDate(rec.bisDat);
        if (!start || !end) return;

        const category = normalizeGrund(rec.Grund);
        const maName = `${rec.Nachname || ''}, ${rec.Vorname || ''}`.trim().replace(/^,\s*/, '');

        for (let day = new Date(start); day <= end; day.setDate(day.getDate() + 1)) {
            if (day.getMonth() + 1 !== state.month || day.getFullYear() !== state.year) continue;

            const datum = new Date(day);
            const iso = toISODate(datum);
            entries.push({
                id: `${rec.ID}-${iso}`,
                datum,
                datumDisplay: formatDisplayDate(datum),
                datumISO: iso,
                maId: rec.MA_ID,
                maName,
                anstellungsartId: rec.Anstellungsart_ID,
                grundKey: category.key,
                grundLabel: category.label,
                bemerkung: rec.Bemerkung || '',
                vonDat: start,
                bisDat: end,
                rawGrund: rec.Grund || '',
                nvId: rec.ID
            });
        }
    });

    entries.sort((a, b) => {
        if (a.datum.getTime() !== b.datum.getTime()) {
            return a.datum - b.datum;
        }
        return a.maName.localeCompare(b.maName);
    });

    state.dayEntries = entries;
}

function applyFilters() {
    let list = [...state.dayEntries];

    if (state.anstellungsart) {
        list = list.filter(entry => String(entry.anstellungsartId) === state.anstellungsart);
    }

    if (state.selectedMaId) {
        list = list.filter(entry => entry.maId === state.selectedMaId);
    }

    state.filteredEntries = list;
    renderDaysTable();
    updateRecordInfo();
}

function renderMitarbeiterList() {
    if (!state.mitarbeiter.length) {
        elements.maList.innerHTML = '<div class="ma-item">Keine Mitarbeiter gefunden</div>';
        return;
    }

    elements.maList.innerHTML = state.mitarbeiter.map(ma => {
        const selected = ma.ID === state.selectedMaId ? 'selected' : '';
        return `<div class="ma-item ${selected}" data-id="${ma.ID}">${ma.Name}</div>`;
    }).join('');
}

function renderDaysTable() {
    if (!state.filteredEntries.length) {
        elements.tbodyTage.innerHTML = '<tr><td colspan="4" style="text-align:center;padding:20px;">Keine Tage im gewählten Zeitraum</td></tr>';
        clearDetails();
        return;
    }

    const rows = state.filteredEntries.map(entry => {
        const selectedClass = entry.id === state.selectedDayId ? 'selected' : '';
        return `
            <tr class="day-row ${selectedClass}" data-day-id="${entry.id}">
                <td>${entry.datumDisplay}</td>
                <td>${entry.maName}</td>
                <td><span class="category-pill category-${entry.grundKey}">${entry.grundLabel}</span></td>
                <td>${entry.bemerkung || ''}</td>
            </tr>
        `;
    }).join('');

    elements.tbodyTage.innerHTML = rows;

    if (state.filteredEntries.length && !state.selectedDayId) {
        selectDay(state.filteredEntries[0].id);
    } else if (state.selectedDayId) {
        const stillExists = state.filteredEntries.some(entry => entry.id === state.selectedDayId);
        if (!stillExists && state.filteredEntries.length) {
            selectDay(state.filteredEntries[0].id);
        } else if (!stillExists) {
            clearDetails();
        }
    }
}

function selectDay(dayId) {
    state.selectedDayId = dayId;
    const entry = state.filteredEntries.find(item => item.id === dayId);
    updateDetails(entry || null);
    renderDaysTable();
}

function updateDetails(entry) {
    if (!entry) {
        clearDetails();
        return;
    }

    elements.detailDatum.value = entry.datumDisplay;
    elements.detailMitarbeiter.value = entry.maName;
    elements.detailArt.value = entry.grundLabel;
    elements.detailZeitraum.value = `${formatDisplayDate(entry.vonDat)} - ${formatDisplayDate(entry.bisDat)}`;
    elements.detailBemerkung.value = entry.bemerkung;
}

function clearDetails() {
    state.selectedDayId = null;
    elements.detailDatum.value = '';
    elements.detailMitarbeiter.value = '';
    elements.detailArt.value = '';
    elements.detailZeitraum.value = '';
    elements.detailBemerkung.value = '';
}

function updateRecordInfo() {
    if (!elements.lblRecordInfo) return;
    const filterText = ANSTELLUNGSART_FILTERS[state.anstellungsart] || 'Beide';
    elements.lblRecordInfo.textContent = `${state.filteredEntries.length} Tage (${filterText})`;
}

function normalizeGrund(grund) {
    const value = (grund || '').toLowerCase();
    if (value.includes('krank')) return { label: 'Krank', key: 'krank' };
    if (value.includes('urlaub')) return { label: 'Urlaub', key: 'urlaub' };
    return { label: 'Privat Verplant', key: 'privat' };
}

function parseDate(value) {
    if (!value) return null;
    const date = new Date(value);
    return isNaN(date.getTime()) ? null : date;
}

function formatDisplayDate(date) {
    if (!date) return '';
    const d = String(date.getDate()).padStart(2, '0');
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const y = date.getFullYear();
    return `${d}.${m}.${y}`;
}

function formatForAccess(date) {
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const y = date.getFullYear();
    return `${m}/${d}/${y}`;
}

function toISODate(date) {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

function setStatus(text) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = text;
    }
}
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
