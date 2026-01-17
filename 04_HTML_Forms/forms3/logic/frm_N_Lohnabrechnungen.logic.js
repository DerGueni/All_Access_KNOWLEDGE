/**
 * frm_N_Lohnabrechnungen.logic.js
 * Lohnabrechnungen-Formular Logik
 */

import { Bridge } from '../api/bridgeClient.js';

// State
let currentData = [];
let selectedIds = new Set();

// DOM Elemente
const cboJahr = document.getElementById('cboJahr');
const cboMonat = document.getElementById('cboMonat');
const cboAnstArt = document.getElementById('cboAnstArt');
const btnLaden = document.getElementById('btnLaden');
const btnVersenden = document.getElementById('btnVersenden');
const tbody = document.getElementById('tbody_Lohn');
const chkAll = document.getElementById('chkAll');
const lblStatus = document.getElementById('lblStatus');
const lblAnzahl = document.getElementById('lblAnzahl');

// Monatsnamen
const MONATE = [
    '', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
];

/**
 * Lohnabrechnungen laden
 */
async function loadAbrechnungen() {
    const jahr = cboJahr.value;
    const monat = cboMonat.value;
    const anstArt = cboAnstArt.value;

    if (!jahr || !monat) {
        alert('Bitte Jahr und Monat auswählen!');
        return;
    }

    try {
        lblStatus.textContent = 'Lade Lohnabrechnungen...';
        btnLaden.disabled = true;

        // API-Aufruf
        const params = {
            jahr: parseInt(jahr),
            monat: parseInt(monat)
        };

        if (anstArt) {
            params.anstellungsart_id = parseInt(anstArt);
        }

        const result = await Bridge.execute('getLohnabrechnungen', params);
        currentData = result.data || [];

        renderTable();

        lblStatus.textContent = `${currentData.length} Lohnabrechnungen geladen`;
        lblAnzahl.textContent = `${currentData.length} Einträge`;

    } catch (error) {
        console.error('Fehler beim Laden:', error);
        lblStatus.textContent = 'Fehler beim Laden der Daten';
        alert('Fehler beim Laden der Lohnabrechnungen:\n' + error.message);
    } finally {
        btnLaden.disabled = false;
    }
}

/**
 * Tabelle rendern
 */
function renderTable() {
    tbody.innerHTML = '';
    selectedIds.clear();
    chkAll.checked = false;

    if (currentData.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" style="text-align:center; padding:40px; color:#999;">
                    Keine Lohnabrechnungen gefunden
                </td>
            </tr>
        `;
        return;
    }

    currentData.forEach((item, index) => {
        const tr = document.createElement('tr');
        tr.dataset.id = item.id || index;
        tr.dataset.maId = item.ma_id;

        // Status-Badge
        let statusBadge = '';
        if (item.versendet_am) {
            const datum = new Date(item.versendet_am);
            statusBadge = `<span class="badge badge-success">Versendet ${datum.toLocaleDateString('de-DE')}</span>`;
        } else {
            statusBadge = `<span class="badge badge-warning">Nicht versendet</span>`;
        }

        tr.innerHTML = `
            <td style="text-align:center;">
                <input type="checkbox" class="chk-row" data-id="${item.id || index}">
            </td>
            <td style="text-align:center;">${index + 1}</td>
            <td>${escapeHtml(item.name || '')}</td>
            <td>${MONATE[item.monat] || item.monat}</td>
            <td style="font-size:12px;">${escapeHtml(item.datei || '')}</td>
            <td>${statusBadge}</td>
            <td style="font-size:12px;">${escapeHtml(item.protokoll || '')}</td>
        `;

        tbody.appendChild(tr);
    });

    // Event Listener für Checkboxen
    document.querySelectorAll('.chk-row').forEach(chk => {
        chk.addEventListener('change', handleRowCheckChange);
    });
}

/**
 * Einzelne Checkbox Change
 */
function handleRowCheckChange(e) {
    const checkbox = e.target;
    const id = checkbox.dataset.id;

    if (checkbox.checked) {
        selectedIds.add(id);
    } else {
        selectedIds.delete(id);
    }

    // "Alle auswählen" Checkbox aktualisieren
    const allCheckboxes = document.querySelectorAll('.chk-row');
    chkAll.checked = allCheckboxes.length > 0 && selectedIds.size === allCheckboxes.length;

    updateSelectionStatus();
}

/**
 * "Alle auswählen" Toggle
 */
function toggleSelectAll(e) {
    const isChecked = e.target.checked;

    document.querySelectorAll('.chk-row').forEach(chk => {
        chk.checked = isChecked;
        const id = chk.dataset.id;

        if (isChecked) {
            selectedIds.add(id);
        } else {
            selectedIds.delete(id);
        }
    });

    updateSelectionStatus();
}

/**
 * Selection Status aktualisieren
 */
function updateSelectionStatus() {
    const count = selectedIds.size;

    if (count > 0) {
        lblStatus.textContent = `${count} Abrechnung(en) ausgewählt`;
        btnVersenden.disabled = false;
    } else {
        lblStatus.textContent = 'Bereit';
        btnVersenden.disabled = true;
    }
}

/**
 * Ausgewählte Abrechnungen versenden
 */
async function sendAbrechnungen() {
    if (selectedIds.size === 0) {
        alert('Bitte mindestens eine Abrechnung auswählen!');
        return;
    }

    const selectedItems = currentData.filter((item, index) =>
        selectedIds.has(item.id?.toString() || index.toString())
    );

    const confirmMsg = `${selectedItems.length} Lohnabrechnungen per E-Mail versenden?\n\n` +
        selectedItems.map(item => `- ${item.name}`).join('\n');

    if (!confirm(confirmMsg)) {
        return;
    }

    try {
        lblStatus.textContent = 'Versende Lohnabrechnungen...';
        btnVersenden.disabled = true;
        btnLaden.disabled = true;

        // API-Aufruf für jeden ausgewählten Datensatz
        const sendPromises = selectedItems.map(item =>
            Bridge.execute('sendLohnabrechnung', {
                id: item.id,
                ma_id: item.ma_id,
                jahr: item.jahr,
                monat: item.monat
            })
        );

        const results = await Promise.allSettled(sendPromises);

        // Ergebnis auswerten
        const successful = results.filter(r => r.status === 'fulfilled').length;
        const failed = results.filter(r => r.status === 'rejected').length;

        let message = `Versand abgeschlossen:\n${successful} erfolgreich`;
        if (failed > 0) {
            message += `\n${failed} fehlgeschlagen`;
        }

        alert(message);

        // Daten neu laden
        await loadAbrechnungen();

    } catch (error) {
        console.error('Fehler beim Versenden:', error);
        alert('Fehler beim Versenden der Lohnabrechnungen:\n' + error.message);
    } finally {
        btnLaden.disabled = false;
        btnVersenden.disabled = false;
        lblStatus.textContent = 'Bereit';
    }
}

/**
 * HTML escapen
 */
function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, m => map[m]);
}

/**
 * Filter Change Handler
 */
function handleFilterChange() {
    // Optional: Auto-Reload bei Filter-Änderung
    // Aktuell: Benutzer muss "Laden" klicken
    lblStatus.textContent = 'Filter geändert - bitte "Laden" klicken';
}

/**
 * Initialisierung
 */
function init() {
    // Event Listeners
    btnLaden.addEventListener('click', loadAbrechnungen);
    btnVersenden.addEventListener('click', sendAbrechnungen);
    chkAll.addEventListener('change', toggleSelectAll);

    cboJahr.addEventListener('change', handleFilterChange);
    cboMonat.addEventListener('change', handleFilterChange);
    cboAnstArt.addEventListener('change', handleFilterChange);

    // Enter-Taste in Dropdowns
    [cboJahr, cboMonat, cboAnstArt].forEach(select => {
        select.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                loadAbrechnungen();
            }
        });
    });

    // Initial-State
    btnVersenden.disabled = true;
    lblStatus.textContent = 'Bereit';

    console.log('Lohnabrechnungen-Formular initialisiert');
}

// Bei DOM Ready initialisieren
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
