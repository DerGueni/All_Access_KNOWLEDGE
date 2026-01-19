/**
 * frm_Subrechnungen.logic.js
 * Logik für Sub Rechnungen Formular
 *
 * FEATURES:
 * - Aufträge laden nach Zeitraum + Mitarbeiter
 * - Abrechnungsdetails pro Auftrag
 * - Status-Änderungen
 * - Export-Funktionen
 */

import { Bridge } from '../js/webview2-bridge.js';

// State
let currentAuftraege = [];
let selectedAuftragId = null;
let currentDetails = [];
let currentMAID = null;

/**
 * Initialisierung
 */
document.addEventListener('DOMContentLoaded', async () => {
    console.log('Subrechnungen Formular geladen');

    // Datum-Felder initialisieren
    initDateFields();

    // Mitarbeiter-Dropdown laden
    await loadMitarbeiterDropdown();

    // Status-Dropdown laden
    await loadStatusDropdown();

    // Event Listeners
    document.getElementById('btnAktualisieren')?.addEventListener('click', loadAuftraege);
    document.getElementById('cboMitarbeiter')?.addEventListener('change', onMitarbeiterChanged);
    document.getElementById('cboZeitraum')?.addEventListener('change', onZeitraumChanged);
    document.getElementById('cboStatusAendern')?.addEventListener('change', onStatusChanged);
    document.getElementById('btnStundenlisteExportieren')?.addEventListener('click', exportStundenliste);
    document.getElementById('btnSpiegelrechnung')?.addEventListener('click', showSpiegelrechnung);

    // Aufträge-Tabelle Click
    document.getElementById('tblAuftraege')?.addEventListener('click', onAuftragClick);

    // Initiales Laden
    await loadAuftraege();

    setStatus('Bereit');
});

/**
 * Datum-Felder mit aktuellem Monat initialisieren
 */
function initDateFields() {
    const now = new Date();
    const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    document.getElementById('datVon').value = formatDateForInput(firstDay);
    document.getElementById('datBis').value = formatDateForInput(lastDay);
}

/**
 * Zeitraum-Änderung
 */
function onZeitraumChanged(e) {
    const zeitraum = e.target.value;
    const now = new Date();
    let von, bis;

    switch (zeitraum) {
        case 'aktuell':
            von = new Date(now.getFullYear(), now.getMonth(), 1);
            bis = new Date(now.getFullYear(), now.getMonth() + 1, 0);
            break;
        case 'vormonat':
            von = new Date(now.getFullYear(), now.getMonth() - 1, 1);
            bis = new Date(now.getFullYear(), now.getMonth(), 0);
            break;
        case 'jahr':
            von = new Date(now.getFullYear(), 0, 1);
            bis = new Date(now.getFullYear(), 11, 31);
            break;
        case 'custom':
            return; // User setzt manuell
    }

    document.getElementById('datVon').value = formatDateForInput(von);
    document.getElementById('datBis').value = formatDateForInput(bis);

    loadAuftraege();
}

/**
 * Mitarbeiter-Dropdown laden
 */
async function loadMitarbeiterDropdown() {
    try {
        const mitarbeiter = await Bridge.execute('getMitarbeiterListe', { aktiv: true });
        const select = document.getElementById('cboMitarbeiter');

        if (!select) return;

        // Alle option beibehalten
        select.innerHTML = '<option value="">-- Alle Mitarbeiter --</option>';

        mitarbeiter.forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = `${ma.Nachname}, ${ma.Vorname}`;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Fehler beim Laden der Mitarbeiter:', error);
    }
}

/**
 * Status-Dropdown laden
 */
async function loadStatusDropdown() {
    try {
        // Annahme: Es gibt eine Tabelle tbl_Rch_Status
        const result = await Bridge.execute('executeSQL', {
            sql: 'SELECT ID, Status FROM tbl_Rch_Status ORDER BY Status',
            fetch: true
        });

        const select = document.getElementById('cboStatusAendern');
        if (!select) return;

        select.innerHTML = '<option value="">-- Status wählen --</option>';

        if (result && result.rows) {
            result.rows.forEach(status => {
                const option = document.createElement('option');
                option.value = status.ID;
                option.textContent = status.Status;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Fehler beim Laden der Status:', error);
        // Fallback
        const select = document.getElementById('cboStatusAendern');
        if (select) {
            select.innerHTML = `
                <option value="">-- Status wählen --</option>
                <option value="1">Ungeprüft</option>
                <option value="2">Geprüft</option>
                <option value="3">Freigegeben</option>
            `;
        }
    }
}

/**
 * Mitarbeiter-Änderung
 */
function onMitarbeiterChanged(e) {
    currentMAID = e.target.value || null;
    loadAuftraege();
}

/**
 * Aufträge laden
 */
async function loadAuftraege() {
    try {
        setStatus('Lade Aufträge...');
        const tbody = document.getElementById('tbodyAuftraege');
        if (!tbody) return;

        tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Lade Daten...</td></tr>';

        const von = document.getElementById('datVon').value;
        const bis = document.getElementById('datBis').value;

        if (!von || !bis) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Bitte Zeitraum wählen</td></tr>';
            return;
        }

        // Aufträge von API laden (Annahme: qry_Auftrag_Rechnung_Gueni)
        const sql = buildAuftragSQL(von, bis, currentMAID);
        const result = await Bridge.execute('executeSQL', { sql, fetch: true });

        if (!result || !result.rows || result.rows.length === 0) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Keine Daten gefunden</td></tr>';
            currentAuftraege = [];
            document.getElementById('lblAnzahlAuftraege').textContent = '0';
            return;
        }

        currentAuftraege = result.rows;
        renderAuftraege(currentAuftraege);

        document.getElementById('lblAnzahlAuftraege').textContent = currentAuftraege.length;
        setStatus(`${currentAuftraege.length} Aufträge geladen`);
    } catch (error) {
        console.error('Fehler beim Laden der Aufträge:', error);
        setStatus('Fehler beim Laden');
        const tbody = document.getElementById('tbodyAuftraege');
        if (tbody) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Fehler beim Laden</td></tr>';
        }
    }
}

/**
 * SQL für Aufträge erstellen
 */
function buildAuftragSQL(von, bis, maID) {
    // Basis-Query basierend auf qry_Auftrag_Rechnung_Gueni
    let sql = `
        SELECT
            VA_ID,
            ErsterWertvonVADatum AS VADatum,
            Auftrag,
            Objekt,
            Ort,
            Gesamtsumme1 AS Betrag,
            RchNr_Ext AS RechNr,
            Aend_von AS Geprueft,
            Aend_am AS GeprueftAm,
            Status,
            Rch_ID
        FROM qry_Auftrag_Rechnung_Gueni
        WHERE ErsterWertvonVADatum >= #${von}#
        AND ErsterWertvonVADatum <= #${bis}#
    `;

    if (maID) {
        sql += ` AND MA_ID = ${maID}`;
    }

    sql += ' ORDER BY ErsterWertvonVADatum DESC';

    return sql;
}

/**
 * Aufträge rendern
 */
function renderAuftraege(auftraege) {
    const tbody = document.getElementById('tbodyAuftraege');
    if (!tbody) return;

    tbody.innerHTML = '';

    auftraege.forEach((auftrag, index) => {
        const tr = document.createElement('tr');
        tr.dataset.vaId = auftrag.VA_ID;
        tr.dataset.rchId = auftrag.Rch_ID || '';
        if (index === 0) tr.classList.add('selected');

        tr.innerHTML = `
            <td>${formatDate(auftrag.VADatum)}</td>
            <td>${auftrag.Auftrag || ''}</td>
            <td>${auftrag.Objekt || ''}</td>
            <td>${auftrag.Ort || ''}</td>
            <td>${formatCurrency(auftrag.Betrag)}</td>
            <td>${auftrag.RechNr || ''}</td>
            <td>${auftrag.Geprueft || ''}</td>
            <td>${auftrag.GeprueftAm ? formatDate(auftrag.GeprueftAm) : ''}</td>
            <td>${auftrag.Status || 'Ungeprüft'}</td>
        `;

        tbody.appendChild(tr);
    });

    // Ersten Auftrag auswählen
    if (auftraege.length > 0) {
        selectAuftrag(auftraege[0].VA_ID);
    }
}

/**
 * Auftrag-Click
 */
function onAuftragClick(e) {
    const row = e.target.closest('tr');
    if (!row || row.classList.contains('loading-row')) return;

    const vaId = row.dataset.vaId;
    if (vaId) {
        selectAuftrag(vaId);
    }
}

/**
 * Auftrag auswählen
 */
async function selectAuftrag(vaId) {
    // Selektion in Tabelle
    document.querySelectorAll('#tblAuftraege tbody tr').forEach(tr => {
        tr.classList.toggle('selected', tr.dataset.vaId === vaId);
    });

    selectedAuftragId = vaId;

    // Auftrag-Info anzeigen
    const auftrag = currentAuftraege.find(a => a.VA_ID == vaId);
    if (auftrag) {
        const info = `${auftrag.Auftrag || ''} ${auftrag.Objekt || ''} ${auftrag.Ort || ''}`;
        document.getElementById('lblAuftragInfo').textContent = info;
    }

    // Details laden
    await loadAbrechnungsdetails(vaId);
}

/**
 * Abrechnungsdetails laden
 */
async function loadAbrechnungsdetails(vaId) {
    try {
        setStatus('Lade Details...');
        const tbody = document.getElementById('tbodyAbrechnungsdetails');
        if (!tbody) return;

        tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Lade Details...</td></tr>';

        // Details-Query (Annahme: Stundenliste pro VA_ID)
        const sql = `
            SELECT
                z.VADatum,
                m.Nachname + ' ' + m.Vorname AS Name,
                z.VA_Start,
                z.VA_Ende,
                z.Stunden,
                z.Nacht,
                z.Sonntag,
                z.Feiertag,
                z.Fahrtkosten
            FROM tbl_MA_VA_Planung z
            INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
            WHERE z.VA_ID = ${vaId}
            ORDER BY z.VADatum, z.VA_Start
        `;

        const result = await Bridge.execute('executeSQL', { sql, fetch: true });

        if (!result || !result.rows || result.rows.length === 0) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Keine Details gefunden</td></tr>';
            currentDetails = [];
            clearSummen();
            return;
        }

        currentDetails = result.rows;
        renderDetails(currentDetails);
        calculateSummen(currentDetails);

        setStatus('Bereit');
    } catch (error) {
        console.error('Fehler beim Laden der Details:', error);
        const tbody = document.getElementById('tbodyAbrechnungsdetails');
        if (tbody) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="9">Fehler beim Laden</td></tr>';
        }
        setStatus('Fehler');
    }
}

/**
 * Details rendern
 */
function renderDetails(details) {
    const tbody = document.getElementById('tbodyAbrechnungsdetails');
    if (!tbody) return;

    tbody.innerHTML = '';

    details.forEach(detail => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${formatDate(detail.VADatum)}</td>
            <td>${detail.Name || ''}</td>
            <td>${formatTime(detail.VA_Start)}</td>
            <td>${formatTime(detail.VA_Ende)}</td>
            <td>${formatNumber(detail.Stunden)}</td>
            <td>${formatNumber(detail.Nacht)}</td>
            <td>${formatNumber(detail.Sonntag)}</td>
            <td>${formatNumber(detail.Feiertag)}</td>
            <td>${formatCurrency(detail.Fahrtkosten)}</td>
        `;
        tbody.appendChild(tr);
    });
}

/**
 * Summen berechnen
 */
function calculateSummen(details) {
    let summeStunden = 0;
    let summeNacht = 0;
    let summeSonntag = 0;
    let summeFeiertag = 0;
    let summeFahrtkosten = 0;

    details.forEach(d => {
        summeStunden += parseFloat(d.Stunden || 0);
        summeNacht += parseFloat(d.Nacht || 0);
        summeSonntag += parseFloat(d.Sonntag || 0);
        summeFeiertag += parseFloat(d.Feiertag || 0);
        summeFahrtkosten += parseFloat(d.Fahrtkosten || 0);
    });

    // Annahme: Beträge werden berechnet (Stundensatz * Stunden)
    // Hier vereinfacht als 0, da Stundensätze nicht verfügbar
    document.getElementById('txtSummeStunden').value = formatNumber(summeStunden);
    document.getElementById('txtSummeNacht').value = formatNumber(summeNacht);
    document.getElementById('txtSummeSonntag').value = formatNumber(summeSonntag);
    document.getElementById('txtSummeFeiertag').value = formatNumber(summeFeiertag);

    // Beträge (würden echte Berechnungen benötigen)
    document.getElementById('txtSummeSVS').value = '0,00 EUR';
    document.getElementById('txtSummeNZ').value = '0,00 EUR';
    document.getElementById('txtSummeSZ').value = '0,00 EUR';
    document.getElementById('txtSummeFZ').value = '0,00 EUR';

    document.getElementById('txtBetragSVS').value = '0,00 EUR';
    document.getElementById('txtBetragNZ').value = '0,00 EUR';
    document.getElementById('txtBetragSZ').value = '0,00 EUR';
    document.getElementById('txtBetragFZ').value = '0,00 EUR';
    document.getElementById('txtBetragFahrtkosten').value = formatCurrency(summeFahrtkosten);

    // Gesamtbetrag aus Auftrag
    const auftrag = currentAuftraege.find(a => a.VA_ID == selectedAuftragId);
    if (auftrag) {
        document.getElementById('txtBetragGesamt').value = formatCurrency(auftrag.Betrag);
    }
}

/**
 * Summen löschen
 */
function clearSummen() {
    document.getElementById('txtSummeStunden').value = '0';
    document.getElementById('txtSummeNacht').value = '0';
    document.getElementById('txtSummeSonntag').value = '0';
    document.getElementById('txtSummeFeiertag').value = '0';
    document.getElementById('txtSummeSVS').value = '0,00 EUR';
    document.getElementById('txtSummeNZ').value = '0,00 EUR';
    document.getElementById('txtSummeSZ').value = '0,00 EUR';
    document.getElementById('txtSummeFZ').value = '0,00 EUR';
    document.getElementById('txtBetragSVS').value = '0,00 EUR';
    document.getElementById('txtBetragNZ').value = '0,00 EUR';
    document.getElementById('txtBetragSZ').value = '0,00 EUR';
    document.getElementById('txtBetragFZ').value = '0,00 EUR';
    document.getElementById('txtBetragFahrtkosten').value = '0,00 EUR';
    document.getElementById('txtBetragGesamt').value = '0,00 EUR';
}

/**
 * Status ändern
 */
async function onStatusChanged(e) {
    const statusId = e.target.value;
    if (!statusId) return;

    // Alle selektierten Aufträge ändern
    const selectedRows = document.querySelectorAll('#tblAuftraege tbody tr.selected');
    if (selectedRows.length === 0) {
        alert('Bitte Auftrag auswählen');
        return;
    }

    try {
        setStatus('Ändere Status...');

        for (const row of selectedRows) {
            const rchId = row.dataset.rchId;
            if (rchId) {
                await Bridge.execute('executeSQL', {
                    sql: `UPDATE tbl_Rch_Rechnung SET Status_ID = ${statusId} WHERE ID = ${rchId}`,
                    fetch: false
                });
            }
        }

        // Neu laden
        await loadAuftraege();
        setStatus('Status geändert');
    } catch (error) {
        console.error('Fehler beim Ändern des Status:', error);
        alert('Fehler beim Ändern des Status');
        setStatus('Fehler');
    }

    // Dropdown zurücksetzen
    e.target.value = '';
}

/**
 * Stundenliste exportieren
 */
function exportStundenliste() {
    if (currentDetails.length === 0) {
        alert('Keine Details zum Exportieren');
        return;
    }

    // CSV erstellen
    let csv = 'Datum;Name;von;bis;Stunden;Nacht;Sonntag;Feiertag;Fahrtkosten\n';
    currentDetails.forEach(d => {
        csv += `${formatDate(d.VADatum)};${d.Name};${formatTime(d.VA_Start)};${formatTime(d.VA_Ende)};${formatNumber(d.Stunden)};${formatNumber(d.Nacht)};${formatNumber(d.Sonntag)};${formatNumber(d.Feiertag)};${formatCurrency(d.Fahrtkosten)}\n`;
    });

    // Download
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `Stundenliste_${selectedAuftragId}.csv`;
    link.click();

    setStatus('Stundenliste exportiert');
}

/**
 * Spiegelrechnung anzeigen
 */
function showSpiegelrechnung() {
    alert('Spiegelrechnung-Funktion nicht implementiert');
}

/**
 * Helper: Status setzen
 */
function setStatus(text) {
    const el = document.getElementById('lblStatus');
    if (el) el.textContent = text;
}

/**
 * Helper: Datum formatieren
 */
function formatDate(date) {
    if (!date) return '';
    const d = new Date(date);
    return d.toLocaleDateString('de-DE');
}

/**
 * Helper: Datum für Input formatieren
 */
function formatDateForInput(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * Helper: Währung formatieren
 */
function formatCurrency(value) {
    if (value === null || value === undefined || value === '') return '0,00 EUR';
    const num = parseFloat(value) || 0;
    return num.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });
}

/**
 * Helper: Zahl formatieren
 */
function formatNumber(value) {
    if (value === null || value === undefined || value === '') return '0';
    const num = parseFloat(value) || 0;
    return num.toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

/**
 * Helper: Zeit formatieren
 */
function formatTime(time) {
    if (!time) return '';
    // Annahme: Zeit als Date oder String
    if (typeof time === 'string') return time;
    const t = new Date(time);
    return t.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}
