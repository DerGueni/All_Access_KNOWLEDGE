/**
 * frm_MA_Zeitkonten.logic.js
 * Logik für Mitarbeiter-Zeitkonten
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../js/webview2-bridge.js';

// State
const state = {
    records: [],
    selectedMA: null,
    periode: 'monat',
    vonDatum: null,
    bisDatum: null,
    maLookup: []
};

// DOM-Elemente
let elements = {};

/**
 * Initialisierung
 */
async function init() {
    console.log('[Zeitkonten] Initialisierung...');

    // DOM-Referenzen sammeln
    elements = {
        // Filter
        cboMitarbeiter: document.getElementById('cboMitarbeiter'),
        cboPeriode: document.getElementById('cboPeriode'),
        customDates: document.getElementById('customDates'),
        datVon: document.getElementById('datVon'),
        datBis: document.getElementById('datBis'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),
        btnExport: document.getElementById('btnExport'),
        btnDrucken: document.getElementById('btnDrucken'),

        // Zusammenfassung
        summSoll: document.getElementById('summSoll'),
        summIst: document.getElementById('summIst'),
        summSaldo: document.getElementById('summSaldo'),
        summUeberstunden: document.getElementById('summUeberstunden'),
        summUrlaub: document.getElementById('summUrlaub'),
        summKrank: document.getElementById('summKrank'),

        // Tabelle
        tbody: document.getElementById('tbody_Zeitkonto'),
        sumDauer: document.getElementById('sumDauer'),
        sumPause: document.getElementById('sumPause'),
        sumNetto: document.getElementById('sumNetto'),

        // Monats-Panel
        monthChart: document.getElementById('monthChart'),
        statArbeitstage: document.getElementById('statArbeitstage'),
        statEinsaetze: document.getElementById('statEinsaetze'),
        statDurchschnitt: document.getElementById('statDurchschnitt'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl'),
        lblPeriode: document.getElementById('lblPeriode')
    };

    // Standard-Zeitraum setzen
    setPeriode('monat');

    // Event Listener
    setupEventListeners();

    // Mitarbeiter laden
    await loadMitarbeiter();

    setStatus('Bereit - Bitte Mitarbeiter auswählen');
}

/**
 * Event Listener einrichten
 */
function setupEventListeners() {
    elements.cboMitarbeiter.addEventListener('change', (e) => {
        state.selectedMA = e.target.value;
        if (state.selectedMA) {
            loadData();
        } else {
            clearTable();
        }
    });

    elements.cboPeriode.addEventListener('change', (e) => {
        setPeriode(e.target.value);
        if (state.selectedMA) {
            loadData();
        }
    });

    elements.datVon.addEventListener('change', () => {
        state.vonDatum = new Date(elements.datVon.value);
        if (state.selectedMA) loadData();
    });

    elements.datBis.addEventListener('change', () => {
        state.bisDatum = new Date(elements.datBis.value);
        if (state.selectedMA) loadData();
    });

    elements.btnAktualisieren.addEventListener('click', () => {
        if (state.selectedMA) loadData();
    });

    elements.btnExport.addEventListener('click', exportData);
    elements.btnDrucken.addEventListener('click', () => window.print());
}

/**
 * Periode setzen
 */
function setPeriode(periode) {
    state.periode = periode;

    const heute = new Date();
    let von, bis;

    switch (periode) {
        case 'monat':
            von = new Date(heute.getFullYear(), heute.getMonth(), 1);
            bis = new Date(heute.getFullYear(), heute.getMonth() + 1, 0);
            break;
        case 'vormonat':
            von = new Date(heute.getFullYear(), heute.getMonth() - 1, 1);
            bis = new Date(heute.getFullYear(), heute.getMonth(), 0);
            break;
        case 'quartal':
            const quartal = Math.floor(heute.getMonth() / 3);
            von = new Date(heute.getFullYear(), quartal * 3, 1);
            bis = new Date(heute.getFullYear(), quartal * 3 + 3, 0);
            break;
        case 'jahr':
            von = new Date(heute.getFullYear(), 0, 1);
            bis = new Date(heute.getFullYear(), 11, 31);
            break;
        case 'custom':
            elements.customDates.style.display = 'flex';
            return;
        default:
            von = new Date(heute.getFullYear(), heute.getMonth(), 1);
            bis = new Date(heute.getFullYear(), heute.getMonth() + 1, 0);
    }

    elements.customDates.style.display = periode === 'custom' ? 'flex' : 'none';

    state.vonDatum = von;
    state.bisDatum = bis;

    elements.datVon.value = formatDate(von);
    elements.datBis.value = formatDate(bis);

    updatePeriodeAnzeige();
}

/**
 * Periodennanzeige aktualisieren
 */
function updatePeriodeAnzeige() {
    const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
    const vonStr = state.vonDatum.toLocaleDateString('de-DE', options);
    const bisStr = state.bisDatum.toLocaleDateString('de-DE', options);
    elements.lblPeriode.textContent = `${vonStr} - ${bisStr}`;
}

/**
 * Datum formatieren
 */
function formatDate(date) {
    return date.toISOString().split('T')[0];
}

/**
 * Mitarbeiter laden
 */
async function loadMitarbeiter() {
    try {
        const result = await Bridge.mitarbeiter.list({ aktiv: true });

        state.maLookup = (result.data || []).map(ma => ({
            ID: ma.MA_ID || ma.ID,
            Name: `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`
        }));

        elements.cboMitarbeiter.innerHTML = '<option value="">-- Mitarbeiter wählen --</option>';
        state.maLookup.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = ma.Name;
            elements.cboMitarbeiter.appendChild(option);
        });

    } catch (error) {
        console.error('[Zeitkonten] Fehler beim Laden der Mitarbeiter:', error);
    }
}

/**
 * Daten laden
 */
async function loadData() {
    if (!state.selectedMA) return;

    setStatus('Lade Zeitkonto...');

    try {
        const von = formatDate(state.vonDatum);
        const bis = formatDate(state.bisDatum);

        // Einsätze des Mitarbeiters laden
        const result = await Bridge.query(`
            SELECT p.*, s.VADatum, s.VA_Start, s.VA_Ende, a.Objekt, a.Auftrag
            FROM tbl_MA_VA_Planung p
            LEFT JOIN tbl_VA_Start s ON p.VAStart_ID = s.ID
            LEFT JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
            WHERE p.MA_ID = ${state.selectedMA}
            AND s.VADatum BETWEEN #${von}# AND #${bis}#
            ORDER BY s.VADatum, s.VA_Start
        `);

        // Abwesenheiten laden
        const abwResult = await Bridge.query(`
            SELECT * FROM tbl_MA_NVerfuegZeiten
            WHERE MA_ID = ${state.selectedMA}
            AND vonDat <= #${bis}# AND bisDat >= #${von}#
        `);

        const einsaetze = result.data || [];
        const abwesenheiten = abwResult.data || [];

        // Tage im Zeitraum aufbauen
        state.records = buildRecords(einsaetze, abwesenheiten);

        renderTable();
        renderSummary();
        renderMonthChart();

        setStatus(`${state.records.length} Tage geladen`);
        elements.lblAnzahl.textContent = `${state.records.length} Einträge`;

    } catch (error) {
        console.error('[Zeitkonten] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

/**
 * Datensätze aufbauen
 */
function buildRecords(einsaetze, abwesenheiten) {
    const records = [];
    const current = new Date(state.vonDatum);

    while (current <= state.bisDatum) {
        const dateStr = formatDate(current);
        const dayOfWeek = current.getDay();
        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;

        // Einsätze für diesen Tag
        const dayEinsaetze = einsaetze.filter(e => {
            const eDatum = new Date(e.VADatum || e.Datum);
            return eDatum.toDateString() === current.toDateString();
        });

        // Abwesenheit für diesen Tag
        const abwesenheit = abwesenheiten.find(a => {
            const von = new Date(a.vonDat);
            const bis = new Date(a.bisDat);
            return current >= von && current <= bis;
        });

        if (dayEinsaetze.length > 0) {
            // Einsätze eintragen
            dayEinsaetze.forEach(e => {
                const start = e.VA_Start || '08:00';
                const ende = e.VA_Ende || '16:00';
                const dauer = calcDuration(start, ende);
                const pause = dauer > 6 * 60 ? 30 : 0; // 30 Min Pause ab 6 Std

                records.push({
                    Datum: new Date(current),
                    Tag: getTagKurz(current.getDay()),
                    Objekt: e.Objekt || e.Auftrag || '',
                    Beginn: start,
                    Ende: ende,
                    Dauer: dauer,
                    Pause: pause,
                    Netto: dauer - pause,
                    Typ: 'Arbeit',
                    Bemerkung: '',
                    isWeekend: isWeekend
                });
            });
        } else if (abwesenheit) {
            // Abwesenheit eintragen
            records.push({
                Datum: new Date(current),
                Tag: getTagKurz(current.getDay()),
                Objekt: '-',
                Beginn: '-',
                Ende: '-',
                Dauer: 0,
                Pause: 0,
                Netto: 0,
                Typ: abwesenheit.Grund || 'Frei',
                Bemerkung: abwesenheit.Bemerkung || '',
                isWeekend: isWeekend,
                isAbwesend: true
            });
        } else if (!isWeekend) {
            // Leerer Arbeitstag
            records.push({
                Datum: new Date(current),
                Tag: getTagKurz(current.getDay()),
                Objekt: '-',
                Beginn: '-',
                Ende: '-',
                Dauer: 0,
                Pause: 0,
                Netto: 0,
                Typ: 'Frei',
                Bemerkung: '',
                isWeekend: false
            });
        }

        current.setDate(current.getDate() + 1);
    }

    return records;
}

/**
 * Dauer berechnen (Minuten)
 */
function calcDuration(start, ende) {
    const [sh, sm] = start.split(':').map(Number);
    const [eh, em] = ende.split(':').map(Number);
    return (eh * 60 + em) - (sh * 60 + sm);
}

/**
 * Minuten zu HH:MM formatieren
 */
function formatMinutes(minutes) {
    if (!minutes || minutes === 0) return '0:00';
    const h = Math.floor(Math.abs(minutes) / 60);
    const m = Math.abs(minutes) % 60;
    const sign = minutes < 0 ? '-' : '';
    return `${sign}${h}:${m.toString().padStart(2, '0')}`;
}

/**
 * Wochentag Kurzform
 */
function getTagKurz(day) {
    return ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'][day];
}

/**
 * Tabelle rendern
 */
function renderTable() {
    if (state.records.length === 0) {
        elements.tbody.innerHTML = `
            <tr>
                <td colspan="10" class="loading-cell">
                    Keine Einträge gefunden
                </td>
            </tr>
        `;
        return;
    }

    let sumDauer = 0, sumPause = 0, sumNetto = 0;

    elements.tbody.innerHTML = state.records.map(rec => {
        sumDauer += rec.Dauer || 0;
        sumPause += rec.Pause || 0;
        sumNetto += rec.Netto || 0;

        const datum = rec.Datum.toLocaleDateString('de-DE');
        const rowClass = [];
        if (rec.isWeekend) rowClass.push('weekend');
        if (rec.Typ === 'Urlaub') rowClass.push('urlaub');
        if (rec.Typ === 'Krank') rowClass.push('krank');

        const typClass = rec.Typ.toLowerCase().replace(/\s/g, '');

        return `
            <tr class="${rowClass.join(' ')}">
                <td class="col-datum">${datum}</td>
                <td class="col-tag">${rec.Tag}</td>
                <td class="col-objekt">${rec.Objekt}</td>
                <td class="col-zeit">${rec.Beginn}</td>
                <td class="col-zeit">${rec.Ende}</td>
                <td class="col-dauer">${formatMinutes(rec.Dauer)}</td>
                <td class="col-pause">${formatMinutes(rec.Pause)}</td>
                <td class="col-netto">${formatMinutes(rec.Netto)}</td>
                <td class="col-typ">
                    <span class="typ-badge ${typClass}">${rec.Typ}</span>
                </td>
                <td class="col-bemerkung">${rec.Bemerkung}</td>
            </tr>
        `;
    }).join('');

    elements.sumDauer.textContent = formatMinutes(sumDauer);
    elements.sumPause.textContent = formatMinutes(sumPause);
    elements.sumNetto.textContent = formatMinutes(sumNetto);
}

/**
 * Zusammenfassung berechnen
 */
function renderSummary() {
    // Arbeitstage im Zeitraum (Mo-Fr)
    let arbeitstage = 0;
    const current = new Date(state.vonDatum);
    while (current <= state.bisDatum) {
        const day = current.getDay();
        if (day !== 0 && day !== 6) arbeitstage++;
        current.setDate(current.getDate() + 1);
    }

    // Sollstunden (8h pro Arbeitstag)
    const sollMinuten = arbeitstage * 8 * 60;

    // Iststunden
    const istMinuten = state.records.reduce((sum, r) => sum + (r.Netto || 0), 0);

    // Urlaub/Krank Tage
    const urlaubTage = state.records.filter(r => r.Typ === 'Urlaub').length;
    const krankTage = state.records.filter(r => r.Typ === 'Krank').length;

    // Saldo
    const saldo = istMinuten - sollMinuten;

    // Überstunden (alles über 8h pro Tag)
    let ueberstunden = 0;
    state.records.forEach(r => {
        if (r.Netto > 8 * 60) {
            ueberstunden += r.Netto - 8 * 60;
        }
    });

    elements.summSoll.textContent = formatMinutes(sollMinuten);
    elements.summIst.textContent = formatMinutes(istMinuten);
    elements.summSaldo.textContent = formatMinutes(saldo);
    elements.summSaldo.className = 'summary-value ' + (saldo >= 0 ? 'positive' : 'negative');
    elements.summUeberstunden.textContent = formatMinutes(ueberstunden);
    elements.summUrlaub.textContent = urlaubTage;
    elements.summKrank.textContent = krankTage;
}

/**
 * Monats-Balkendiagramm rendern
 */
function renderMonthChart() {
    // Stunden pro Woche berechnen
    const wochen = {};
    state.records.forEach(rec => {
        const kw = getWeekNumber(rec.Datum);
        if (!wochen[kw]) wochen[kw] = 0;
        wochen[kw] += rec.Netto || 0;
    });

    const kwList = Object.keys(wochen).sort((a, b) => a - b);
    const maxMinuten = Math.max(...Object.values(wochen), 40 * 60); // Min 40h

    let html = '';
    kwList.forEach(kw => {
        const minuten = wochen[kw];
        const stunden = minuten / 60;
        const prozent = (minuten / maxMinuten) * 100;

        let barClass = '';
        if (stunden < 35) barClass = 'low';
        else if (stunden > 45) barClass = 'over';

        html += `
            <div class="chart-bar-container">
                <span class="chart-label">KW${kw}</span>
                <div class="chart-bar-wrapper">
                    <div class="chart-bar ${barClass}" style="width: ${prozent}%"></div>
                </div>
                <span class="chart-value">${stunden.toFixed(1)}h</span>
            </div>
        `;
    });

    elements.monthChart.innerHTML = html || '<div class="loading-cell">Keine Daten</div>';

    // Statistiken
    const arbeitsTage = state.records.filter(r => r.Typ === 'Arbeit' && r.Netto > 0).length;
    const einsaetze = state.records.filter(r => r.Typ === 'Arbeit' && r.Objekt !== '-').length;
    const totalMinuten = state.records.reduce((sum, r) => sum + (r.Netto || 0), 0);
    const durchschnitt = arbeitsTage > 0 ? totalMinuten / arbeitsTage : 0;

    elements.statArbeitstage.textContent = arbeitsTage;
    elements.statEinsaetze.textContent = einsaetze;
    elements.statDurchschnitt.textContent = formatMinutes(Math.round(durchschnitt));
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
 * Tabelle leeren
 */
function clearTable() {
    elements.tbody.innerHTML = `
        <tr>
            <td colspan="10" class="loading-cell">
                Bitte Mitarbeiter auswählen...
            </td>
        </tr>
    `;

    elements.sumDauer.textContent = '0:00';
    elements.sumPause.textContent = '0:00';
    elements.sumNetto.textContent = '0:00';

    elements.summSoll.textContent = '0:00';
    elements.summIst.textContent = '0:00';
    elements.summSaldo.textContent = '0:00';
    elements.summUeberstunden.textContent = '0:00';
    elements.summUrlaub.textContent = '0';
    elements.summKrank.textContent = '0';

    elements.monthChart.innerHTML = '';
    elements.statArbeitstage.textContent = '0';
    elements.statEinsaetze.textContent = '0';
    elements.statDurchschnitt.textContent = '0:00';

    elements.lblAnzahl.textContent = '0 Einträge';
}

/**
 * Export
 */
function exportData() {
    if (state.records.length === 0) {
        alert('Keine Daten zum Exportieren');
        return;
    }

    const headers = ['Datum', 'Tag', 'Objekt', 'Beginn', 'Ende', 'Dauer', 'Pause', 'Netto', 'Typ', 'Bemerkung'];
    const rows = state.records.map(rec => [
        rec.Datum.toLocaleDateString('de-DE'),
        rec.Tag,
        rec.Objekt,
        rec.Beginn,
        rec.Ende,
        formatMinutes(rec.Dauer),
        formatMinutes(rec.Pause),
        formatMinutes(rec.Netto),
        rec.Typ,
        rec.Bemerkung
    ]);

    const csv = [headers, ...rows]
        .map(row => row.map(cell => `"${cell}"`).join(';'))
        .join('\n');

    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;

    const maName = state.maLookup.find(m => m.ID == state.selectedMA)?.Name || 'MA';
    a.download = `Zeitkonto_${maName}_${formatDate(state.vonDatum)}.csv`;
    a.click();
    URL.revokeObjectURL(url);

    setStatus('Export abgeschlossen');
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
window.Zeitkonten = {
    loadData,
    exportData
};
