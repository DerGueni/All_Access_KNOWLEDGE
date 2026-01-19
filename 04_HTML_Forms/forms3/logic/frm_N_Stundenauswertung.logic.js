/**
 * frm_N_Stundenauswertung.logic.js
 *
 * Stundenauswertung - Soll/Ist Vergleich fuer Mitarbeiter
 *
 * Erstellt: 2026-01-17
 * API-Endpoints:
 * - GET /api/mitarbeiter
 * - GET /api/zeitkonten/ma/{id}
 * - GET /api/ueberhang/{ma_id}
 */

// ============================================
// STATE
// ============================================
const state = {
    records: [],
    filteredRecords: [],
    selectedMA: null,
    jahr: new Date().getFullYear(),
    monat: new Date().getMonth() + 1,
    anstArt: null,
    nurDifferenzen: false,
    maLookup: [],
    sortColumn: 1,
    sortAsc: true
};

// ============================================
// DOM ELEMENTS
// ============================================
const el = {};

// ============================================
// ANSTELLUNGSARTEN MAPPING
// ============================================
const ANSTELLUNGSARTEN = {
    3: 'Festangestellt',
    5: 'Minijobber',
    6: 'Aushilfe',
    7: 'Praktikant'
};

// ============================================
// INITIALIZATION
// ============================================
document.addEventListener('DOMContentLoaded', function() {
    console.log('[Stundenauswertung] Initialisierung...');

    // Cache DOM elements
    el.cboJahr = document.getElementById('cboJahr');
    el.cboMonat = document.getElementById('cboMonat');
    el.cboMitarbeiter = document.getElementById('cboMitarbeiter');
    el.cboAnstArt = document.getElementById('cboAnstArt');
    el.chkNurDifferenzen = document.getElementById('chkNurDifferenzen');
    el.tbody_Auswertung = document.getElementById('tbody_Auswertung');

    // Summary
    el.summAnzahlMA = document.getElementById('summAnzahlMA');
    el.summSollGesamt = document.getElementById('summSollGesamt');
    el.summIstGesamt = document.getElementById('summIstGesamt');
    el.summDifferenzGesamt = document.getElementById('summDifferenzGesamt');
    el.summUeberstunden = document.getElementById('summUeberstunden');
    el.summFehlstunden = document.getElementById('summFehlstunden');

    // Footer
    el.sumSoll = document.getElementById('sumSoll');
    el.sumIst = document.getElementById('sumIst');
    el.sumDiff = document.getElementById('sumDiff');
    el.sumUrlaub = document.getElementById('sumUrlaub');
    el.sumKrank = document.getElementById('sumKrank');
    el.sumUeberhang = document.getElementById('sumUeberhang');

    // Stats
    el.statArbeitstage = document.getElementById('statArbeitstage');
    el.statFeiertage = document.getElementById('statFeiertage');
    el.statDurchschnitt = document.getElementById('statDurchschnitt');
    el.statMAUeberstunden = document.getElementById('statMAUeberstunden');
    el.statMAFehlstunden = document.getElementById('statMAFehlstunden');
    el.statPeriode = document.getElementById('statPeriode');
    el.topUeberstunden = document.getElementById('topUeberstunden');
    el.topFehlstunden = document.getElementById('topFehlstunden');

    // Status
    el.lblStatus = document.getElementById('lblStatus');
    el.lblAnzahl = document.getElementById('lblAnzahl');
    el.lblPeriode = document.getElementById('lblPeriode');

    // Initialize Jahr-Dropdown
    initJahrDropdown();

    // Set current month
    if (el.cboMonat) el.cboMonat.value = state.monat;

    // Setup Event Listeners
    setupEventListeners();

    // Load initial data
    loadMitarbeiter().then(() => {
        loadData();
    });
});

// ============================================
// EVENT LISTENERS
// ============================================
function setupEventListeners() {
    if (el.cboJahr) {
        el.cboJahr.addEventListener('change', () => {
            state.jahr = parseInt(el.cboJahr.value);
            loadData();
        });
    }

    if (el.cboMonat) {
        el.cboMonat.addEventListener('change', () => {
            state.monat = parseInt(el.cboMonat.value);
            loadData();
        });
    }

    if (el.cboMitarbeiter) {
        el.cboMitarbeiter.addEventListener('change', () => {
            state.selectedMA = el.cboMitarbeiter.value || null;
            applyFilters();
        });
    }

    if (el.cboAnstArt) {
        el.cboAnstArt.addEventListener('change', () => {
            state.anstArt = el.cboAnstArt.value ? parseInt(el.cboAnstArt.value) : null;
            applyFilters();
        });
    }

    if (el.chkNurDifferenzen) {
        el.chkNurDifferenzen.addEventListener('change', () => {
            state.nurDifferenzen = el.chkNurDifferenzen.checked;
            applyFilters();
        });
    }

    // Menu navigation
    document.querySelectorAll('.menu-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const formName = this.dataset.form;
            if (formName) navigateToForm(formName);
        });
    });
}

// ============================================
// INITIALIZATION HELPERS
// ============================================
function initJahrDropdown() {
    if (!el.cboJahr) return;

    const currentYear = new Date().getFullYear();
    el.cboJahr.innerHTML = '';

    for (let y = currentYear - 2; y <= currentYear + 1; y++) {
        const option = document.createElement('option');
        option.value = y;
        option.textContent = y;
        if (y === currentYear) option.selected = true;
        el.cboJahr.appendChild(option);
    }
}

// ============================================
// DATA LOADING
// ============================================
async function loadMitarbeiter() {
    try {
        const response = await fetch('http://localhost:5000/api/mitarbeiter?aktiv=true');
        if (!response.ok) throw new Error('API nicht erreichbar');

        const data = await response.json();
        state.maLookup = (data.data || data || []).map(ma => ({
            ID: ma.MA_ID || ma.ID,
            Nachname: ma.MA_Nachname || ma.Nachname,
            Vorname: ma.MA_Vorname || ma.Vorname,
            Name: `${ma.MA_Nachname || ma.Nachname}, ${ma.MA_Vorname || ma.Vorname}`,
            Anstellungsart_ID: ma.Anstellungsart_ID || ma.MA_Anstellungsart_ID || 5
        }));

        // Populate dropdown
        if (el.cboMitarbeiter) {
            el.cboMitarbeiter.innerHTML = '<option value="">-- Alle Mitarbeiter --</option>';
            state.maLookup.sort((a, b) => a.Name.localeCompare(b.Name)).forEach(ma => {
                const option = document.createElement('option');
                option.value = ma.ID;
                option.textContent = ma.Name;
                el.cboMitarbeiter.appendChild(option);
            });
        }

        console.log(`[Stundenauswertung] ${state.maLookup.length} Mitarbeiter geladen`);
    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Laden der Mitarbeiter:', error);
        setStatus('API-Fehler: Mitarbeiter konnten nicht geladen werden');
    }
}

async function loadData() {
    setStatus('Lade Stundenauswertung...');
    if (el.tbody_Auswertung) {
        el.tbody_Auswertung.innerHTML = '<tr><td colspan="10" class="loading-cell">Lade Daten...</td></tr>';
    }

    try {
        // Berechne Zeitraum
        const von = new Date(state.jahr, state.monat - 1, 1);
        const bis = new Date(state.jahr, state.monat, 0); // Letzter Tag des Monats

        const vonStr = formatDateSQL(von);
        const bisStr = formatDateSQL(bis);

        // Lade Zeitkontendaten fuer alle Mitarbeiter
        const records = [];

        for (const ma of state.maLookup) {
            try {
                // Zeitkonto-Daten
                const zkResponse = await fetch(`http://localhost:5000/api/zeitkonten?ma_id=${ma.ID}&von=${vonStr}&bis=${bisStr}`);
                let zkData = [];
                if (zkResponse.ok) {
                    const zkResult = await zkResponse.json();
                    zkData = zkResult.data || zkResult || [];
                }

                // Ueberhang-Daten
                let ueberhang = 0;
                try {
                    const uhResponse = await fetch(`http://localhost:5000/api/ueberhang/${ma.ID}`);
                    if (uhResponse.ok) {
                        const uhResult = await uhResponse.json();
                        ueberhang = uhResult.stunden || uhResult.ueberhang || 0;
                    }
                } catch (e) {
                    // Endpoint existiert moeglicherweise nicht
                }

                // Berechne Soll-Stunden (8h pro Arbeitstag fuer Festangestellte)
                const arbeitsTage = countWorkdays(von, bis);
                const sollStunden = ma.Anstellungsart_ID === 3 ? arbeitsTage * 8 : 0;

                // Berechne Ist-Stunden
                const istStunden = zkData.reduce((sum, zk) => sum + ((zk.Netto || zk.Stunden || 0) / 60), 0);

                // Zaehle Urlaub und Krankheitstage
                const urlaubTage = zkData.filter(zk => zk.Typ === 'Urlaub' || zk.AbwesenheitTyp === 'Urlaub').length;
                const krankTage = zkData.filter(zk => zk.Typ === 'Krank' || zk.AbwesenheitTyp === 'Krank').length;

                const differenz = istStunden - sollStunden;

                records.push({
                    MA_ID: ma.ID,
                    Name: ma.Name,
                    Nachname: ma.Nachname,
                    Vorname: ma.Vorname,
                    Anstellungsart_ID: ma.Anstellungsart_ID,
                    Anstellungsart: ANSTELLUNGSARTEN[ma.Anstellungsart_ID] || 'Unbekannt',
                    SollStunden: sollStunden,
                    IstStunden: istStunden,
                    Differenz: differenz,
                    Urlaub: urlaubTage,
                    Krank: krankTage,
                    Ueberhang: ueberhang,
                    Bemerkung: ''
                });
            } catch (maError) {
                console.warn(`[Stundenauswertung] Fehler bei MA ${ma.ID}:`, maError);
            }
        }

        state.records = records;
        console.log(`[Stundenauswertung] ${records.length} Datensaetze geladen`);

        applyFilters();
        updateStats();
        setStatus(`${records.length} Mitarbeiter ausgewertet`);

    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Laden:', error);
        setStatus('Fehler beim Laden: ' + error.message);

        // Fallback: Demo-Daten
        loadDemoData();
    }
}

function loadDemoData() {
    console.log('[Stundenauswertung] Lade Demo-Daten...');

    const demoRecords = [
        { MA_ID: 1, Name: 'Mustermann, Max', Nachname: 'Mustermann', Vorname: 'Max', Anstellungsart_ID: 3, Anstellungsart: 'Festangestellt', SollStunden: 168, IstStunden: 175, Differenz: 7, Urlaub: 0, Krank: 1, Ueberhang: 12, Bemerkung: '' },
        { MA_ID: 2, Name: 'Schmidt, Anna', Nachname: 'Schmidt', Vorname: 'Anna', Anstellungsart_ID: 3, Anstellungsart: 'Festangestellt', SollStunden: 168, IstStunden: 160, Differenz: -8, Urlaub: 2, Krank: 0, Ueberhang: 0, Bemerkung: 'Urlaub genehmigt' },
        { MA_ID: 3, Name: 'Mueller, Hans', Nachname: 'Mueller', Vorname: 'Hans', Anstellungsart_ID: 5, Anstellungsart: 'Minijobber', SollStunden: 0, IstStunden: 45, Differenz: 45, Urlaub: 0, Krank: 0, Ueberhang: 5, Bemerkung: '' },
        { MA_ID: 4, Name: 'Weber, Lisa', Nachname: 'Weber', Vorname: 'Lisa', Anstellungsart_ID: 3, Anstellungsart: 'Festangestellt', SollStunden: 168, IstStunden: 168, Differenz: 0, Urlaub: 0, Krank: 0, Ueberhang: 0, Bemerkung: '' },
        { MA_ID: 5, Name: 'Fischer, Tom', Nachname: 'Fischer', Vorname: 'Tom', Anstellungsart_ID: 5, Anstellungsart: 'Minijobber', SollStunden: 0, IstStunden: 38, Differenz: 38, Urlaub: 0, Krank: 2, Ueberhang: 0, Bemerkung: '' }
    ];

    state.records = demoRecords;
    applyFilters();
    updateStats();
    setStatus('Demo-Daten geladen (API nicht erreichbar)');
}

// ============================================
// FILTERING & SORTING
// ============================================
function applyFilters() {
    let filtered = [...state.records];

    // Filter by Mitarbeiter
    if (state.selectedMA) {
        filtered = filtered.filter(r => r.MA_ID == state.selectedMA);
    }

    // Filter by Anstellungsart
    if (state.anstArt) {
        if (state.anstArt === 13) {
            // Fest + Mini
            filtered = filtered.filter(r => r.Anstellungsart_ID === 3 || r.Anstellungsart_ID === 5);
        } else {
            filtered = filtered.filter(r => r.Anstellungsart_ID === state.anstArt);
        }
    }

    // Filter nur Differenzen
    if (state.nurDifferenzen) {
        filtered = filtered.filter(r => Math.abs(r.Differenz) > 0.5);
    }

    // Sort
    sortRecords(filtered);

    state.filteredRecords = filtered;
    renderTable();
    renderSummary();
    renderTopLists();

    if (el.lblAnzahl) el.lblAnzahl.textContent = `${filtered.length} Mitarbeiter`;
}

function sortRecords(records) {
    const keys = ['MA_ID', 'Name', 'Anstellungsart', 'SollStunden', 'IstStunden', 'Differenz', 'Urlaub', 'Krank', 'Ueberhang', 'Bemerkung'];
    const key = keys[state.sortColumn] || 'Name';

    records.sort((a, b) => {
        let valA = a[key];
        let valB = b[key];

        if (typeof valA === 'string') valA = valA.toLowerCase();
        if (typeof valB === 'string') valB = valB.toLowerCase();

        if (valA < valB) return state.sortAsc ? -1 : 1;
        if (valA > valB) return state.sortAsc ? 1 : -1;
        return 0;
    });
}

// ============================================
// TABLE RENDERING
// ============================================
function renderTable() {
    if (!el.tbody_Auswertung) return;

    if (state.filteredRecords.length === 0) {
        el.tbody_Auswertung.innerHTML = '<tr><td colspan="10" class="loading-cell">Keine Daten gefunden</td></tr>';
        return;
    }

    el.tbody_Auswertung.innerHTML = state.filteredRecords.map(rec => {
        const diffClass = rec.Differenz > 0 ? 'positive' : (rec.Differenz < 0 ? 'negative' : '');
        const ueberhangClass = rec.Ueberhang > 0 ? 'positive' : '';

        return `
            <tr data-ma-id="${rec.MA_ID}">
                <td class="number">${rec.MA_ID}</td>
                <td>${rec.Name}</td>
                <td>${rec.Anstellungsart}</td>
                <td class="number">${formatHours(rec.SollStunden)}</td>
                <td class="number">${formatHours(rec.IstStunden)}</td>
                <td class="number ${diffClass}">${formatHours(rec.Differenz, true)}</td>
                <td class="number">${rec.Urlaub || 0}</td>
                <td class="number">${rec.Krank || 0}</td>
                <td class="number ${ueberhangClass}">${formatHours(rec.Ueberhang)}</td>
                <td>${rec.Bemerkung || ''}</td>
            </tr>
        `;
    }).join('');

    // Row click handler
    el.tbody_Auswertung.querySelectorAll('tr').forEach(row => {
        row.addEventListener('click', () => {
            el.tbody_Auswertung.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
            row.classList.add('selected');
        });

        row.addEventListener('dblclick', () => {
            const maId = row.dataset.maId;
            if (maId) {
                navigateToForm('frm_MA_Zeitkonten', maId);
            }
        });
    });
}

function renderSummary() {
    const records = state.filteredRecords;

    let sumSoll = 0, sumIst = 0, sumUrlaub = 0, sumKrank = 0, sumUeberhang = 0;
    let ueberstunden = 0, fehlstunden = 0;

    records.forEach(rec => {
        sumSoll += rec.SollStunden || 0;
        sumIst += rec.IstStunden || 0;
        sumUrlaub += rec.Urlaub || 0;
        sumKrank += rec.Krank || 0;
        sumUeberhang += rec.Ueberhang || 0;

        if (rec.Differenz > 0) ueberstunden += rec.Differenz;
        if (rec.Differenz < 0) fehlstunden += Math.abs(rec.Differenz);
    });

    const sumDiff = sumIst - sumSoll;

    // Summary Bar
    if (el.summAnzahlMA) el.summAnzahlMA.textContent = records.length;
    if (el.summSollGesamt) el.summSollGesamt.textContent = formatHours(sumSoll);
    if (el.summIstGesamt) el.summIstGesamt.textContent = formatHours(sumIst);
    if (el.summDifferenzGesamt) {
        el.summDifferenzGesamt.textContent = formatHours(sumDiff, true);
        el.summDifferenzGesamt.className = 'summary-value ' + (sumDiff >= 0 ? 'positive' : 'negative');
    }
    if (el.summUeberstunden) el.summUeberstunden.textContent = formatHours(ueberstunden);
    if (el.summFehlstunden) el.summFehlstunden.textContent = formatHours(fehlstunden);

    // Table Footer
    if (el.sumSoll) el.sumSoll.textContent = formatHours(sumSoll);
    if (el.sumIst) el.sumIst.textContent = formatHours(sumIst);
    if (el.sumDiff) {
        el.sumDiff.textContent = formatHours(sumDiff, true);
        el.sumDiff.className = 'number ' + (sumDiff >= 0 ? 'positive' : 'negative');
    }
    if (el.sumUrlaub) el.sumUrlaub.textContent = sumUrlaub;
    if (el.sumKrank) el.sumKrank.textContent = sumKrank;
    if (el.sumUeberhang) el.sumUeberhang.textContent = formatHours(sumUeberhang);
}

function updateStats() {
    const von = new Date(state.jahr, state.monat - 1, 1);
    const bis = new Date(state.jahr, state.monat, 0);

    const arbeitstage = countWorkdays(von, bis);
    const feiertage = countFeiertage(state.jahr, state.monat);

    if (el.statArbeitstage) el.statArbeitstage.textContent = arbeitstage;
    if (el.statFeiertage) el.statFeiertage.textContent = feiertage;

    const totalIst = state.filteredRecords.reduce((sum, r) => sum + (r.IstStunden || 0), 0);
    const durchschnitt = state.filteredRecords.length > 0 ? totalIst / state.filteredRecords.length / arbeitstage : 0;
    if (el.statDurchschnitt) el.statDurchschnitt.textContent = formatHours(durchschnitt);

    const maUeber = state.filteredRecords.filter(r => r.Differenz > 0).length;
    const maFehl = state.filteredRecords.filter(r => r.Differenz < 0).length;
    if (el.statMAUeberstunden) el.statMAUeberstunden.textContent = maUeber;
    if (el.statMAFehlstunden) el.statMAFehlstunden.textContent = maFehl;

    const monatName = ['Januar', 'Februar', 'Maerz', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'][state.monat - 1];
    if (el.statPeriode) el.statPeriode.textContent = `${monatName} ${state.jahr}`;
    if (el.lblPeriode) el.lblPeriode.textContent = `${monatName} ${state.jahr}`;
}

function renderTopLists() {
    // Top 5 Ueberstunden
    const topUeber = [...state.filteredRecords]
        .filter(r => r.Differenz > 0)
        .sort((a, b) => b.Differenz - a.Differenz)
        .slice(0, 5);

    if (el.topUeberstunden) {
        el.topUeberstunden.innerHTML = topUeber.length > 0
            ? topUeber.map(r => `<div class="stat-row"><span class="stat-label">${r.Nachname}</span><span class="stat-value positive">+${formatHours(r.Differenz)}</span></div>`).join('')
            : '<div class="stat-row"><span class="stat-label">-</span><span class="stat-value">-</span></div>';
    }

    // Top 5 Fehlstunden
    const topFehl = [...state.filteredRecords]
        .filter(r => r.Differenz < 0)
        .sort((a, b) => a.Differenz - b.Differenz)
        .slice(0, 5);

    if (el.topFehlstunden) {
        el.topFehlstunden.innerHTML = topFehl.length > 0
            ? topFehl.map(r => `<div class="stat-row"><span class="stat-label">${r.Nachname}</span><span class="stat-value negative">${formatHours(r.Differenz, true)}</span></div>`).join('')
            : '<div class="stat-row"><span class="stat-label">-</span><span class="stat-value">-</span></div>';
    }
}

// ============================================
// BUTTON HANDLERS
// ============================================
window.btnAktualisieren_Click = function() {
    loadData();
};

window.btnExportExcel_Click = function() {
    exportToExcel();
};

window.btnDrucken_Click = function() {
    window.print();
};

window.btnVergleich_Click = function() {
    alert('Monatsvergleich: Feature in Entwicklung');
};

// ============================================
// TABLE SORTING
// ============================================
window.sortTable = function(colIndex) {
    if (state.sortColumn === colIndex) {
        state.sortAsc = !state.sortAsc;
    } else {
        state.sortColumn = colIndex;
        state.sortAsc = true;
    }

    // Update sort arrows
    document.querySelectorAll('.datasheet th .sort-arrow').forEach((arrow, i) => {
        arrow.innerHTML = i === colIndex ? (state.sortAsc ? '&#x25B2;' : '&#x25BC;') : '';
    });

    applyFilters();
};

// ============================================
// EXPORT
// ============================================
function exportToExcel() {
    const headers = ['MA-Nr', 'Name', 'Anstellungsart', 'Soll-Std', 'Ist-Std', 'Differenz', 'Urlaub', 'Krank', 'Ueberhang', 'Bemerkung'];
    const rows = state.filteredRecords.map(rec => [
        rec.MA_ID,
        rec.Name,
        rec.Anstellungsart,
        formatHours(rec.SollStunden),
        formatHours(rec.IstStunden),
        formatHours(rec.Differenz, true),
        rec.Urlaub,
        rec.Krank,
        formatHours(rec.Ueberhang),
        rec.Bemerkung || ''
    ]);

    const monatName = ['Januar', 'Februar', 'Maerz', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'][state.monat - 1];
    const fileName = `Stundenauswertung_${monatName}_${state.jahr}.csv`;

    const csv = [headers, ...rows]
        .map(row => row.map(cell => `"${cell}"`).join(';'))
        .join('\n');

    const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    a.click();
    URL.revokeObjectURL(url);

    setStatus(`Export erstellt: ${fileName}`);
}

// ============================================
// UTILITY FUNCTIONS
// ============================================
function formatDateSQL(date) {
    if (!date) return '';
    return date.toISOString().split('T')[0];
}

function formatHours(hours, showSign = false) {
    if (hours === undefined || hours === null || isNaN(hours)) return '0:00';

    const h = Math.floor(Math.abs(hours));
    const m = Math.round((Math.abs(hours) - h) * 60);
    const sign = hours < 0 ? '-' : (showSign && hours > 0 ? '+' : '');

    return `${sign}${h}:${m.toString().padStart(2, '0')}`;
}

function countWorkdays(von, bis) {
    let count = 0;
    const current = new Date(von);
    while (current <= bis) {
        const day = current.getDay();
        if (day !== 0 && day !== 6) count++;
        current.setDate(current.getDate() + 1);
    }
    return count;
}

function countFeiertage(jahr, monat) {
    // Vereinfachte Feiertagsberechnung fuer Deutschland
    const feiertage = [
        [1, 1],   // Neujahr
        [5, 1],   // Tag der Arbeit
        [10, 3],  // Tag der Deutschen Einheit
        [12, 25], // 1. Weihnachtstag
        [12, 26]  // 2. Weihnachtstag
    ];

    return feiertage.filter(f => f[0] === monat).length;
}

function setStatus(text) {
    if (el.lblStatus) el.lblStatus.textContent = text;
    console.log('[Stundenauswertung] ' + text);
}

function navigateToForm(formName, recordId) {
    if (typeof window._shellNavigateToForm === 'function') {
        window._shellNavigateToForm(formName, recordId);
    } else if (window.parent && window.parent !== window) {
        window.parent.postMessage({ type: 'NAVIGATE', formName: formName, id: recordId }, '*');
    } else {
        let url = formName + '.html';
        if (recordId) url += '?ma_id=' + recordId;
        window.location.href = url;
    }
}

// Fullscreen toggle
window.toggleFullscreen = function() {
    const btn = document.getElementById('fullscreenBtn');
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().then(() => {
            if (btn) btn.title = 'Vollbild beenden';
        }).catch(err => console.error('Fullscreen error:', err));
    } else {
        document.exitFullscreen().then(() => {
            if (btn) btn.title = 'Vollbild';
        }).catch(err => console.error('Exit fullscreen error:', err));
    }
};

document.addEventListener('fullscreenchange', () => {
    const btn = document.getElementById('fullscreenBtn');
    if (btn) btn.title = document.fullscreenElement ? 'Vollbild beenden' : 'Vollbild';
});

// Global access
window.Stundenauswertung = {
    loadData: loadData,
    exportData: exportToExcel,
    getState: () => state
};

// Legacy support
window.StundenauswertungForm = {
    reload: loadData
};
