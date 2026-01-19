import { Bridge } from '../api/bridgeClient.js';

const MONTH_NAMES = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];

const state = {
    kunden: [],
    rawRows: [],
    monthlyData: [],
    sort: { field: 'jahr', direction: 'desc' },
    selectedRowKey: null
};

const elements = {};

document.addEventListener('DOMContentLoaded', () => {
    init().catch(error => {
        console.error('[Umsatzauswertung] Init-Fehler:', error);
        showToast('Initialisierung fehlgeschlagen: ' + error.message, 'error');
    });
});

async function init() {
    cacheElements();
    initMeta();
    registerWindowBindings();
    await loadKunden();

    const params = new URLSearchParams(window.location.search);
    const kdId = params.get('id') || params.get('kd_id');
    if (kdId) {
        elements.cboKunde.value = kdId;
    }

    await loadUmsatzDaten();
}

function cacheElements() {
    elements.cboKunde = document.getElementById('cboKunde');
    elements.dtVon = document.getElementById('dtVonDatum');
    elements.dtBis = document.getElementById('dtBisDatum');
    elements.tbody = document.getElementById('tbodyUmsatz');
    elements.lblStatus = document.getElementById('lblStatus');
    elements.lblRecordInfo = document.getElementById('lblRecordInfo');
    elements.lblVersion = document.getElementById('lbl_Version');
    elements.lblDatum = document.getElementById('lbl_Datum');
    elements.statGesamt = document.getElementById('statGesamtumsatz');
    elements.statAnzahl = document.getElementById('statAnzahlAuftraege');
    elements.statDurchschnitt = document.getElementById('statDurchschnitt');
    elements.loading = document.getElementById('loadingOverlay');
    elements.toast = document.getElementById('toastContainer');
}

function initMeta() {
    elements.lblDatum.textContent = new Date().toLocaleDateString('de-DE');
    elements.lblVersion.textContent = 'v1.0';
    setCurrentYearRange();
}

function registerWindowBindings() {
    window.cboKunde_Change = () => loadUmsatzDaten();
    window.btnAktualisieren_Click = () => loadUmsatzDaten();
    window.btnHeute_Click = () => {
        setCurrentYearRange();
        loadUmsatzDaten();
    };
    window.btnJahrZurueck_Click = () => {
        shiftYearRange(-1);
        loadUmsatzDaten();
    };
    window.btnJahrVor_Click = () => {
        shiftYearRange(1);
        loadUmsatzDaten();
    };
    window.btnExportCSV_Click = () => exportCSV();
    window.btnDrucken_Click = () => printView();
    window.closeForm = closeForm;
    window.navigateToForm = navigateToForm;
    window.sortTable = sortTable;
}

async function loadKunden() {
    try {
        setStatus('Lade Kunden...');
        showLoading(true);
        const result = await Bridge.query(`
            SELECT kun_Id, Nz(kun_Firma,'') AS kun_Firma
            FROM tbl_KD_Kundenstamm
            WHERE Nz(kun_IstAktiv, -1) <> 0
            ORDER BY kun_Firma
        `);

        state.kunden = (result?.data || result?.records || []).map(row => ({
            id: row.kun_Id,
            name: row.kun_Firma || ''
        }));

        renderKundenOptions();
        setStatus('Kunden geladen');
    } catch (error) {
        console.error('[Kunden] Fehler:', error);
        showToast('Fehler beim Laden der Kunden: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

function renderKundenOptions() {
    const currentValue = elements.cboKunde.value;
    const options = ['<option value="">-- Alle Kunden --</option>']
        .concat(state.kunden.map(k => `<option value="${k.id}">${escapeHtml(k.name)}</option>`));
    elements.cboKunde.innerHTML = options.join('');
    elements.cboKunde.value = currentValue || '';
}

async function loadUmsatzDaten() {
    try {
        setStatus('Lade Umsatzdaten...');
        showLoading(true);

        const { von, bis, kundeId } = getFilterValues();
        const kundeClause = kundeId ? ` AND r.kun_ID = ${kundeId}` : '';

        const sql = `
            SELECT r.ID, r.kun_ID, k.kun_Firma, r.RchDatum, Nz(r.Zwi_Sum1,0) AS NettoWert
            FROM tbl_Rch_Kopf AS r
            INNER JOIN tbl_KD_Kundenstamm AS k ON r.kun_ID = k.kun_Id
            WHERE r.RchDatum BETWEEN #${von}# AND #${bis}#
            ${kundeClause}
            ORDER BY r.RchDatum
        `;

        const result = await Bridge.query(sql);
        state.rawRows = (result?.data || result?.records || []).map(row => ({
            id: row.ID,
            kundeId: row.kun_ID,
            kunde: row.kun_Firma || '',
            datum: parseDate(row.RchDatum),
            netto: toNumber(row.NettoWert)
        })).filter(row => row.datum);

        buildMonthlyAggregation();
        renderTable();
        updateStats();

        elements.lblRecordInfo.textContent = `${state.monthlyData.length} Monate`;
        setStatus('Bereit');
    } catch (error) {
        console.error('[Umsatzdaten] Fehler:', error);
        showToast('Fehler beim Laden der Umsatzdaten: ' + error.message, 'error');
        setStatus('Fehler');
        elements.tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:40px;">Fehler beim Laden der Daten</td></tr>';
    } finally {
        showLoading(false);
    }
}

function buildMonthlyAggregation() {
    const map = new Map();

    state.rawRows.forEach(row => {
        const jahr = row.datum.getFullYear();
        const monat = row.datum.getMonth() + 1;
        const key = `${jahr}-${monat}`;

        if (!map.has(key)) {
            map.set(key, {
                key,
                jahr,
                monat,
                monatName: MONTH_NAMES[monat - 1] || '',
                umsatz: 0,
                anzahl: 0
            });
        }

        const bucket = map.get(key);
        bucket.umsatz += row.netto;
        bucket.anzahl += 1;
    });

    state.monthlyData = Array.from(map.values());
}

function renderTable() {
    if (!state.monthlyData.length) {
        elements.tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:40px;">Keine Daten im gewählten Zeitraum</td></tr>';
        return;
    }

    const sorted = [...state.monthlyData].sort(compareRows);
    const rowsHtml = sorted.map(item => {
        const avg = item.anzahl ? item.umsatz / item.anzahl : 0;
        const selected = state.selectedRowKey === item.key ? 'selected' : '';
        return `
            <tr class="${selected}" data-row-index="${item.key}">
                <td class="col-jahr">${item.jahr}</td>
                <td class="col-monat">${item.monatName}</td>
                <td class="col-umsatz currency">${formatCurrency(item.umsatz)}</td>
                <td class="col-anzahl number">${item.anzahl}</td>
                <td class="col-durchschnitt currency">${formatCurrency(avg)}</td>
            </tr>
        `;
    }).join('');

    const totalUmsatz = sorted.reduce((sum, item) => sum + item.umsatz, 0);
    const totalAnzahl = sorted.reduce((sum, item) => sum + item.anzahl, 0);
    const totalAvg = totalAnzahl ? totalUmsatz / totalAnzahl : 0;

    const sumRow = `
        <tr class="summe-row" data-row-index="sum">
            <td colspan="2" style="text-align:right; padding-right:10px;">SUMME:</td>
            <td class="col-umsatz currency">${formatCurrency(totalUmsatz)}</td>
            <td class="col-anzahl number">${totalAnzahl}</td>
            <td class="col-durchschnitt currency">${formatCurrency(totalAvg)}</td>
        </tr>
    `;

    elements.tbody.innerHTML = rowsHtml + sumRow;

    elements.tbody.querySelectorAll('tr[data-row-index]').forEach(tr => {
        if (tr.dataset.rowIndex === 'sum') return;
        tr.addEventListener('click', () => {
            state.selectedRowKey = tr.dataset.rowIndex;
            renderTable();
        });
    });
}

function compareRows(a, b) {
    const direction = state.sort.direction === 'asc' ? 1 : -1;
    let value = 0;

    switch (state.sort.field) {
        case 'monat':
            value = a.monat - b.monat;
            break;
        case 'umsatz':
            value = a.umsatz - b.umsatz;
            break;
        case 'anzahl':
            value = a.anzahl - b.anzahl;
            break;
        case 'durchschnitt': {
            const avgA = a.anzahl ? a.umsatz / a.anzahl : 0;
            const avgB = b.anzahl ? b.umsatz / b.anzahl : 0;
            value = avgA - avgB;
            break;
        }
        default:
            value = a.jahr - b.jahr;
    }

    if (value === 0 && state.sort.field !== 'jahr') {
        value = a.jahr - b.jahr;
    }

    return value * direction;
}

function sortTable(field) {
    if (state.sort.field === field) {
        state.sort.direction = state.sort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        state.sort.field = field;
        state.sort.direction = field === 'jahr' ? 'desc' : 'asc';
    }

    document.querySelectorAll('.umsatz-table th').forEach(th => {
        th.classList.remove('sort-asc', 'sort-desc');
        if (th.dataset.sort === field) {
            th.classList.add(state.sort.direction === 'asc' ? 'sort-asc' : 'sort-desc');
        }
    });

    renderTable();
}

function updateStats() {
    const totalUmsatz = state.monthlyData.reduce((sum, item) => sum + item.umsatz, 0);
    const totalAuftraege = state.monthlyData.reduce((sum, item) => sum + item.anzahl, 0);
    const avgMonat = state.monthlyData.length ? totalUmsatz / state.monthlyData.length : 0;

    elements.statGesamt.textContent = formatCurrency(totalUmsatz);
    elements.statAnzahl.textContent = totalAuftraege;
    elements.statDurchschnitt.textContent = formatCurrency(avgMonat);
}

function exportCSV() {
    if (!state.monthlyData.length) {
        showToast('Keine Daten zum Exportieren', 'warning');
        return;
    }

    const sorted = [...state.monthlyData].sort(compareRows);
    let csv = 'Jahr;Monat;Umsatz;Anzahl Aufträge;Durchschnitt je Auftrag\n';
    sorted.forEach(item => {
        const avg = item.anzahl ? item.umsatz / item.anzahl : 0;
        csv += `${item.jahr};${item.monatName};${item.umsatz.toFixed(2)};${item.anzahl};${avg.toFixed(2)}\n`;
    });

    const totalUmsatz = sorted.reduce((sum, item) => sum + item.umsatz, 0);
    const totalAnzahl = sorted.reduce((sum, item) => sum + item.anzahl, 0);
    const totalAvg = totalAnzahl ? totalUmsatz / totalAnzahl : 0;
    csv += `SUMME;;${totalUmsatz.toFixed(2)};${totalAnzahl};${totalAvg.toFixed(2)}\n`;

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `umsatzauswertung_${elements.dtBis.value || new Date().toISOString().split('T')[0]}.csv`;
    link.click();
    showToast('CSV-Export erfolgreich', 'success');
}

function printView() {
    window.print();
    showToast('Druckdialog geöffnet', 'info');
}

function closeForm() {
    if (window.parent && typeof window.parent.closeCurrentForm === 'function') {
        window.parent.closeCurrentForm();
    } else {
        window.close();
    }
}

function navigateToForm(formName) {
    if (window.parent && typeof window.parent.navigateToForm === 'function') {
        window.parent.navigateToForm(formName);
    } else {
        window.location.href = formName + '.html';
    }
}

function getFilterValues() {
    const vonDate = parseInputDate(elements.dtVon.value) || new Date(new Date().getFullYear(), 0, 1);
    const bisDate = parseInputDate(elements.dtBis.value) || new Date(new Date().getFullYear(), 11, 31);
    if (bisDate < vonDate) {
        bisDate.setTime(vonDate.getTime());
    }

    elements.dtVon.value = formatInputDate(vonDate);
    elements.dtBis.value = formatInputDate(bisDate);

    const kundeId = parseInt(elements.cboKunde.value, 10);
    return {
        von: formatAccessDate(vonDate),
        bis: formatAccessDate(bisDate),
        kundeId: Number.isFinite(kundeId) ? kundeId : null
    };
}

function setCurrentYearRange() {
    const now = new Date();
    const start = new Date(now.getFullYear(), 0, 1);
    const end = new Date(now.getFullYear(), 11, 31);
    elements.dtVon.value = formatInputDate(start);
    elements.dtBis.value = formatInputDate(end);
}

function shiftYearRange(offset) {
    const von = parseInputDate(elements.dtVon.value) || new Date();
    const bis = parseInputDate(elements.dtBis.value) || new Date();
    von.setFullYear(von.getFullYear() + offset);
    bis.setFullYear(bis.getFullYear() + offset);
    elements.dtVon.value = formatInputDate(von);
    elements.dtBis.value = formatInputDate(bis);
}

function formatCurrency(value) {
    return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value || 0);
}

function parseDate(value) {
    if (!value) return null;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
}

function parseInputDate(value) {
    if (!value) return null;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
}

function formatInputDate(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
}

function formatAccessDate(date) {
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const y = date.getFullYear();
    return `${m}/${d}/${y}`;
}

function toNumber(value) {
    if (typeof value === 'number') return value;
    if (typeof value === 'string') {
        const normalized = value.replace(/\./g, '').replace(',', '.');
        const parsed = parseFloat(normalized);
        return Number.isNaN(parsed) ? 0 : parsed;
    }
    return 0;
}

function escapeHtml(value) {
    return String(value || '').replace(/[&<>"']/g, char => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
    })[char] || char);
}

function setStatus(text) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = text;
    }
}

function showLoading(show) {
    if (!elements.loading) return;
    elements.loading.classList.toggle('active', !!show);
}

function showToast(message, type = 'info') {
    if (!elements.toast) return;
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    elements.toast.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideIn 0.3s ease-out reverse';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}
