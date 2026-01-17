// ============================================================
// frm_KD_Umsatzauswertung.logic.js
// Logic-Datei fuer Kunden-Umsatzauswertung
// ============================================================

// ============================================
// GLOBALE VARIABLEN
// ============================================
const API_BASE = 'http://localhost:5000/api';
let alleKunden = [];
let alleAuftraege = [];
let umsatzDaten = [];
let currentSort = { field: 'jahr', direction: 'desc' };

// ============================================
// INITIALISIERUNG
// ============================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[frm_KD_Umsatzauswertung] Initialisiere...');

    // Datum heute anzeigen
    document.getElementById('lbl_Datum').textContent = new Date().toLocaleDateString('de-DE');
    document.getElementById('lbl_Version').textContent = 'v1.0';

    // Standard-Zeitraum: Aktuelles Jahr
    setzeAktuellesJahr();

    // Lade Kunden
    await ladeKunden();

    // URL-Parameter pruefen
    const urlParams = new URLSearchParams(window.location.search);
    const kdId = urlParams.get('id') || urlParams.get('kd_id');
    if (kdId) {
        document.getElementById('cboKunde').value = kdId;
    }

    // Lade initiale Daten
    await ladeUmsatzDaten();
});

// ============================================
// KUNDEN LADEN
// ============================================
async function ladeKunden() {
    try {
        showLoading(true);
        const response = await fetch(`${API_BASE}/kunden`);
        if (!response.ok) throw new Error('Fehler beim Laden der Kunden');

        alleKunden = await response.json();

        const select = document.getElementById('cboKunde');
        select.innerHTML = '<option value="">-- Alle Kunden --</option>';

        alleKunden
            .filter(k => k.kun_IstAktiv)
            .sort((a, b) => (a.kun_Firma || '').localeCompare(b.kun_Firma || ''))
            .forEach(kunde => {
                const option = document.createElement('option');
                option.value = kunde.kun_Id;
                option.textContent = kunde.kun_Firma;
                select.appendChild(option);
            });

        console.log(`[Kunden] ${alleKunden.length} Kunden geladen`);
    } catch (error) {
        console.error('[Kunden] Fehler:', error);
        showToast('Fehler beim Laden der Kunden: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

// ============================================
// UMSATZDATEN LADEN
// ============================================
async function ladeUmsatzDaten() {
    try {
        showLoading(true);
        document.getElementById('lblStatus').textContent = 'Lade Daten...';

        // Filter-Werte
        const kundeId = document.getElementById('cboKunde').value;
        const vonDatum = document.getElementById('dtVonDatum').value;
        const bisDatum = document.getElementById('dtBisDatum').value;

        // Lade Auftraege
        let url = `${API_BASE}/auftraege`;
        const response = await fetch(url);
        if (!response.ok) throw new Error('Fehler beim Laden der Auftraege');

        alleAuftraege = await response.json();
        console.log(`[Auftraege] ${alleAuftraege.length} Auftraege geladen`);

        // Filter Auftraege nach Kunde und Zeitraum
        let gefiltert = alleAuftraege.filter(a => {
            // Kunden-Filter
            if (kundeId && a.Veranstalter_ID != kundeId) return false;

            // Zeitraum-Filter (basierend auf VADatum_Erste oder CreatedDate)
            const auftragDatum = a.VADatum_Erste || a.CreatedDate;
            if (auftragDatum) {
                const datum = new Date(auftragDatum);
                if (vonDatum && datum < new Date(vonDatum)) return false;
                if (bisDatum && datum > new Date(bisDatum)) return false;
            }

            return true;
        });

        console.log(`[Filter] ${gefiltert.length} Auftraege nach Filter`);

        // Berechne Umsatz pro Monat
        umsatzDaten = berechneMonatsumsatz(gefiltert);

        // Anzeige aktualisieren
        zeigeUmsatzDaten();
        aktualisiereStatistik();

        document.getElementById('lblStatus').textContent = 'Bereit';
        document.getElementById('lblRecordInfo').textContent = `${umsatzDaten.length} Monate`;

    } catch (error) {
        console.error('[Umsatzauswertung] Fehler:', error);
        showToast('Fehler beim Laden der Umsatzdaten: ' + error.message, 'error');
        document.getElementById('lblStatus').textContent = 'Fehler';
    } finally {
        showLoading(false);
    }
}

// ============================================
// UMSATZ PRO MONAT BERECHNEN
// ============================================
function berechneMonatsumsatz(auftraege) {
    const monatMap = new Map();

    auftraege.forEach(auftrag => {
        const datum = new Date(auftrag.VADatum_Erste || auftrag.CreatedDate || Date.now());
        const jahr = datum.getFullYear();
        const monat = datum.getMonth() + 1;
        const key = `${jahr}-${String(monat).padStart(2, '0')}`;

        if (!monatMap.has(key)) {
            monatMap.set(key, {
                jahr: jahr,
                monat: monat,
                monatName: getMonatName(monat),
                umsatz: 0,
                anzahl: 0,
                auftraege: []
            });
        }

        const eintrag = monatMap.get(key);
        eintrag.anzahl++;
        eintrag.auftraege.push(auftrag);

        // Umsatz berechnen (aus Gesamtsumme oder geschaetzt)
        const umsatz = auftrag.Gesamtsumme || auftrag.Gesamt_Netto || 0;
        eintrag.umsatz += parseFloat(umsatz) || 0;
    });

    // Zu Array konvertieren
    const result = Array.from(monatMap.values());

    // Sortieren nach Jahr/Monat
    result.sort((a, b) => {
        if (a.jahr !== b.jahr) return b.jahr - a.jahr;
        return b.monat - a.monat;
    });

    return result;
}

// ============================================
// UMSATZDATEN ANZEIGEN
// ============================================
function zeigeUmsatzDaten() {
    const tbody = document.getElementById('tbodyUmsatz');
    tbody.innerHTML = '';

    if (umsatzDaten.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:40px;">Keine Daten im gewaehlten Zeitraum</td></tr>';
        return;
    }

    // Sortierung anwenden
    const sortiert = [...umsatzDaten].sort((a, b) => {
        let valA = a[currentSort.field];
        let valB = b[currentSort.field];

        if (currentSort.field === 'durchschnitt') {
            valA = a.anzahl > 0 ? a.umsatz / a.anzahl : 0;
            valB = b.anzahl > 0 ? b.umsatz / b.anzahl : 0;
        }

        if (typeof valA === 'number') {
            return currentSort.direction === 'asc' ? valA - valB : valB - valA;
        } else {
            return currentSort.direction === 'asc'
                ? String(valA).localeCompare(String(valB))
                : String(valB).localeCompare(String(valA));
        }
    });

    // Zeilen erstellen
    sortiert.forEach((zeile, idx) => {
        const tr = document.createElement('tr');
        tr.dataset.index = idx;

        const durchschnitt = zeile.anzahl > 0 ? zeile.umsatz / zeile.anzahl : 0;

        tr.innerHTML = `
            <td class="col-jahr">${zeile.jahr}</td>
            <td class="col-monat">${zeile.monatName}</td>
            <td class="col-umsatz currency">${formatCurrency(zeile.umsatz)}</td>
            <td class="col-anzahl number">${zeile.anzahl}</td>
            <td class="col-durchschnitt currency">${formatCurrency(durchschnitt)}</td>
        `;

        tr.onclick = () => selectRow(tr);
        tbody.appendChild(tr);
    });

    // Summenzeile hinzufuegen
    const summe = {
        umsatz: sortiert.reduce((sum, z) => sum + z.umsatz, 0),
        anzahl: sortiert.reduce((sum, z) => sum + z.anzahl, 0)
    };
    const durchschnittGesamt = summe.anzahl > 0 ? summe.umsatz / summe.anzahl : 0;

    const trSumme = document.createElement('tr');
    trSumme.className = 'summe-row';
    trSumme.innerHTML = `
        <td colspan="2" style="text-align:right; padding-right:10px;">SUMME:</td>
        <td class="col-umsatz currency">${formatCurrency(summe.umsatz)}</td>
        <td class="col-anzahl number">${summe.anzahl}</td>
        <td class="col-durchschnitt currency">${formatCurrency(durchschnittGesamt)}</td>
    `;
    tbody.appendChild(trSumme);
}

// ============================================
// STATISTIK AKTUALISIEREN
// ============================================
function aktualisiereStatistik() {
    const gesamtumsatz = umsatzDaten.reduce((sum, z) => sum + z.umsatz, 0);
    const anzahlAuftraege = umsatzDaten.reduce((sum, z) => sum + z.anzahl, 0);
    const durchschnitt = umsatzDaten.length > 0 ? gesamtumsatz / umsatzDaten.length : 0;

    document.getElementById('statGesamtumsatz').textContent = formatCurrency(gesamtumsatz);
    document.getElementById('statAnzahlAuftraege').textContent = anzahlAuftraege;
    document.getElementById('statDurchschnitt').textContent = formatCurrency(durchschnitt);
}

// ============================================
// SORTIERUNG
// ============================================
function sortTable(field) {
    if (currentSort.field === field) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.field = field;
        currentSort.direction = 'asc';
    }

    // Header-Markierung aktualisieren
    document.querySelectorAll('.umsatz-table th').forEach(th => {
        th.classList.remove('sort-asc', 'sort-desc');
        if (th.dataset.sort === field) {
            th.classList.add(currentSort.direction === 'asc' ? 'sort-asc' : 'sort-desc');
        }
    });

    zeigeUmsatzDaten();
}

// ============================================
// ZEILEN-AUSWAHL
// ============================================
function selectRow(tr) {
    document.querySelectorAll('.umsatz-table tbody tr').forEach(r => r.classList.remove('selected'));
    tr.classList.add('selected');
}

// ============================================
// EVENT HANDLER
// ============================================
function cboKunde_Change() {
    ladeUmsatzDaten();
}

function btnAktualisieren_Click() {
    ladeUmsatzDaten();
}

function btnHeute_Click() {
    setzeAktuellesJahr();
    ladeUmsatzDaten();
}

function btnJahrZurueck_Click() {
    const vonDatum = new Date(document.getElementById('dtVonDatum').value);
    vonDatum.setFullYear(vonDatum.getFullYear() - 1);
    const bisDatum = new Date(document.getElementById('dtBisDatum').value);
    bisDatum.setFullYear(bisDatum.getFullYear() - 1);

    document.getElementById('dtVonDatum').value = formatDate(vonDatum);
    document.getElementById('dtBisDatum').value = formatDate(bisDatum);
    ladeUmsatzDaten();
}

function btnJahrVor_Click() {
    const vonDatum = new Date(document.getElementById('dtVonDatum').value);
    vonDatum.setFullYear(vonDatum.getFullYear() + 1);
    const bisDatum = new Date(document.getElementById('dtBisDatum').value);
    bisDatum.setFullYear(bisDatum.getFullYear() + 1);

    document.getElementById('dtVonDatum').value = formatDate(vonDatum);
    document.getElementById('dtBisDatum').value = formatDate(bisDatum);
    ladeUmsatzDaten();
}

function btnExportCSV_Click() {
    try {
        let csv = 'Jahr;Monat;Umsatz;Anzahl Auftraege;Durchschnitt\n';

        umsatzDaten.forEach(zeile => {
            const durchschnitt = zeile.anzahl > 0 ? zeile.umsatz / zeile.anzahl : 0;
            csv += `${zeile.jahr};${zeile.monatName};${zeile.umsatz.toFixed(2)};${zeile.anzahl};${durchschnitt.toFixed(2)}\n`;
        });

        // Summenzeile
        const summeUmsatz = umsatzDaten.reduce((sum, z) => sum + z.umsatz, 0);
        const summeAnzahl = umsatzDaten.reduce((sum, z) => sum + z.anzahl, 0);
        const summeDurch = summeAnzahl > 0 ? summeUmsatz / summeAnzahl : 0;
        csv += `SUMME;;${summeUmsatz.toFixed(2)};${summeAnzahl};${summeDurch.toFixed(2)}\n`;

        // Download
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'umsatzauswertung_' + new Date().toISOString().split('T')[0] + '.csv';
        link.click();

        showToast('CSV-Export erfolgreich', 'success');
    } catch (error) {
        console.error('[Export] Fehler:', error);
        showToast('Fehler beim CSV-Export: ' + error.message, 'error');
    }
}

function btnDrucken_Click() {
    window.print();
    showToast('Druckdialog geoeffnet', 'info');
}

function closeForm() {
    if (window.parent && window.parent.closeCurrentForm) {
        window.parent.closeCurrentForm();
    } else {
        window.close();
    }
}

function navigateToForm(formName) {
    if (window.parent && window.parent.navigateToForm) {
        window.parent.navigateToForm(formName);
    } else {
        window.location.href = formName + '.html';
    }
}

// ============================================
// HILFSFUNKTIONEN
// ============================================
function setzeAktuellesJahr() {
    const heute = new Date();
    const jahresAnfang = new Date(heute.getFullYear(), 0, 1);
    const jahresEnde = new Date(heute.getFullYear(), 11, 31);

    document.getElementById('dtVonDatum').value = formatDate(jahresAnfang);
    document.getElementById('dtBisDatum').value = formatDate(jahresEnde);
}

function formatDate(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
}

function formatCurrency(value) {
    return new Intl.NumberFormat('de-DE', {
        style: 'currency',
        currency: 'EUR'
    }).format(value || 0);
}

function getMonatName(monat) {
    const monate = ['Januar', 'Februar', 'Maerz', 'April', 'Mai', 'Juni',
                   'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
    return monate[monat - 1] || '';
}

function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    if (show) {
        overlay.classList.add('active');
    } else {
        overlay.classList.remove('active');
    }
}

function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'slideIn 0.3s ease-out reverse';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// ============================================
// WINDOW EXPORTS fuer onclick Handler
// ============================================
window.cboKunde_Change = cboKunde_Change;
window.btnAktualisieren_Click = btnAktualisieren_Click;
window.btnHeute_Click = btnHeute_Click;
window.btnJahrZurueck_Click = btnJahrZurueck_Click;
window.btnJahrVor_Click = btnJahrVor_Click;
window.btnExportCSV_Click = btnExportCSV_Click;
window.btnDrucken_Click = btnDrucken_Click;
window.closeForm = closeForm;
window.navigateToForm = navigateToForm;
window.sortTable = sortTable;
