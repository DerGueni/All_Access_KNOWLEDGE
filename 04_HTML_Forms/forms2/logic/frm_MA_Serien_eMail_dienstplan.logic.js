/**
 * frm_MA_Serien_eMail_dienstplan.logic.js
 * Logik für Serien-E-Mail-Versand von Dienstplänen
 * Versand von Dienstplan-E-Mails an mehrere Mitarbeiter
 */
import { Bridge } from '../../api/bridgeClient.js';

let elements = {};
let selectedMitarbeiter = [];

async function init() {
    console.log('[MA_Serien_eMail_dienstplan] Initialisierung...');

    elements = {
        mitarbeiterListe: document.getElementById('mitarbeiterListe'),
        vorschauContainer: document.getElementById('vorschauContainer'),

        btnAlleAuswaehlen: document.getElementById('btnAlleAuswaehlen'),
        btnKeineAuswaehlen: document.getElementById('btnKeineAuswaehlen'),
        btnVorschau: document.getElementById('btnVorschau'),
        btnVersenden: document.getElementById('btnVersenden'),

        // Filter
        filterAbteilung: document.getElementById('filterAbteilung'),
        filterZeitraum: document.getElementById('filterZeitraum'),
        vonDatum: document.getElementById('vonDatum'),
        bisDatum: document.getElementById('bisDatum'),

        // E-Mail-Template
        betreff: document.getElementById('betreff'),
        nachrichtText: document.getElementById('nachrichtText'),
        pdfAnhaengen: document.getElementById('pdfAnhaengen'),

        // Statistik
        anzahlAusgewaehlt: document.getElementById('anzahlAusgewaehlt'),
        anzahlVersandt: document.getElementById('anzahlVersandt'),
        anzahlFehler: document.getElementById('anzahlFehler'),

        progressBar: document.getElementById('progressBar'),
        statusLog: document.getElementById('statusLog')
    };

    await loadInitialData();
    bindEvents();
    setDefaultDates();
}

async function loadInitialData() {
    try {
        // Aktive Mitarbeiter laden
        const mitarbeiter = await Bridge.mitarbeiter.list({ aktiv: true });
        renderMitarbeiterListe(mitarbeiter);

    } catch (error) {
        console.error('[MA_Serien_eMail_dienstplan] Fehler beim Laden:', error);
        showError('Mitarbeiterdaten konnten nicht geladen werden');
    }
}

function renderMitarbeiterListe(mitarbeiter) {
    if (!elements.mitarbeiterListe) return;

    elements.mitarbeiterListe.innerHTML = mitarbeiter.map(m => `
        <div class="ma-item" data-id="${m.MA_ID}">
            <input type="checkbox" class="ma-checkbox" value="${m.MA_ID}"
                   ${!m.eMail ? 'disabled' : ''}>
            <span class="ma-name">${m.Nachname}, ${m.Vorname}</span>
            <span class="ma-email ${!m.eMail ? 'missing' : ''}">${m.eMail || 'Keine E-Mail'}</span>
            <span class="ma-status" data-ma-id="${m.MA_ID}"></span>
        </div>
    `).join('');
}

function setDefaultDates() {
    const heute = new Date();
    const naechsteWoche = new Date(heute);
    naechsteWoche.setDate(heute.getDate() + 7);

    if (elements.vonDatum) {
        elements.vonDatum.value = formatDateInput(heute);
    }

    if (elements.bisDatum) {
        elements.bisDatum.value = formatDateInput(naechsteWoche);
    }

    // Standard-Betreff
    if (elements.betreff) {
        elements.betreff.value = `Dienstplan KW ${getWeekNumber(heute)}`;
    }
}

function bindEvents() {
    // Alle auswählen
    if (elements.btnAlleAuswaehlen) {
        elements.btnAlleAuswaehlen.addEventListener('click', () => {
            const checkboxes = elements.mitarbeiterListe?.querySelectorAll('.ma-checkbox:not(:disabled)');
            checkboxes?.forEach(cb => cb.checked = true);
            updateAuswahlStatistik();
        });
    }

    // Keine auswählen
    if (elements.btnKeineAuswaehlen) {
        elements.btnKeineAuswaehlen.addEventListener('click', () => {
            const checkboxes = elements.mitarbeiterListe?.querySelectorAll('.ma-checkbox');
            checkboxes?.forEach(cb => cb.checked = false);
            updateAuswahlStatistik();
        });
    }

    // Auswahl-Change
    if (elements.mitarbeiterListe) {
        elements.mitarbeiterListe.addEventListener('change', (e) => {
            if (e.target.classList.contains('ma-checkbox')) {
                updateAuswahlStatistik();
            }
        });
    }

    // Vorschau
    if (elements.btnVorschau) {
        elements.btnVorschau.addEventListener('click', showVorschau);
    }

    // Versenden
    if (elements.btnVersenden) {
        elements.btnVersenden.addEventListener('click', versendeEmails);
    }

    // Filter
    if (elements.filterAbteilung) {
        elements.filterAbteilung.addEventListener('change', applyFilter);
    }
}

function updateAuswahlStatistik() {
    const selected = elements.mitarbeiterListe?.querySelectorAll('.ma-checkbox:checked');
    if (elements.anzahlAusgewaehlt) {
        elements.anzahlAusgewaehlt.textContent = selected?.length || 0;
    }
}

async function showVorschau() {
    const selected = getSelectedMitarbeiter();

    if (selected.length === 0) {
        showError('Bitte wählen Sie mindestens einen Mitarbeiter aus');
        return;
    }

    try {
        // Ersten ausgewählten MA für Vorschau verwenden
        const maId = selected[0];
        const vonDatum = elements.vonDatum?.value;
        const bisDatum = elements.bisDatum?.value;

        const dienstplan = await Bridge.execute('getDienstplanFuerMitarbeiter', {
            ma_id: maId,
            von: vonDatum,
            bis: bisDatum
        });

        const mitarbeiter = await Bridge.mitarbeiter.get(maId);

        renderVorschau(mitarbeiter, dienstplan);

    } catch (error) {
        console.error('[MA_Serien_eMail_dienstplan] Fehler bei Vorschau:', error);
        showError('Vorschau konnte nicht erstellt werden');
    }
}

function renderVorschau(mitarbeiter, dienstplan) {
    if (!elements.vorschauContainer) return;

    const betreff = elements.betreff?.value || 'Ihr Dienstplan';
    const nachricht = elements.nachrichtText?.value || '';

    elements.vorschauContainer.innerHTML = `
        <div class="email-vorschau">
            <div class="email-header">
                <strong>An:</strong> ${mitarbeiter.eMail}<br>
                <strong>Betreff:</strong> ${betreff}
            </div>
            <div class="email-body">
                <p>Hallo ${mitarbeiter.Vorname} ${mitarbeiter.Nachname},</p>
                <p>${nachricht}</p>
                <div class="dienstplan-tabelle">
                    <h3>Ihr Dienstplan</h3>
                    ${renderDienstplanTabelle(dienstplan)}
                </div>
            </div>
        </div>
    `;
}

function renderDienstplanTabelle(dienstplan) {
    if (!dienstplan || dienstplan.length === 0) {
        return '<p>Keine Einträge für diesen Zeitraum</p>';
    }

    return `
        <table>
            <thead>
                <tr>
                    <th>Datum</th>
                    <th>Objekt</th>
                    <th>Zeit</th>
                    <th>Stunden</th>
                </tr>
            </thead>
            <tbody>
                ${dienstplan.map(e => `
                    <tr>
                        <td>${formatDate(e.VADatum)}</td>
                        <td>${e.Objekt || 'N/A'}</td>
                        <td>${e.VA_Start} - ${e.VA_Ende}</td>
                        <td>${e.Stunden || 0}</td>
                    </tr>
                `).join('')}
            </tbody>
        </table>
    `;
}

async function versendeEmails() {
    const selected = getSelectedMitarbeiter();

    if (selected.length === 0) {
        showError('Bitte wählen Sie mindestens einen Mitarbeiter aus');
        return;
    }

    if (!confirm(`${selected.length} E-Mails versenden?`)) {
        return;
    }

    // UI vorbereiten
    if (elements.btnVersenden) elements.btnVersenden.disabled = true;
    if (elements.progressBar) elements.progressBar.style.width = '0%';

    let versandt = 0;
    let fehler = 0;

    for (let i = 0; i < selected.length; i++) {
        const maId = selected[i];

        try {
            await versendeDienstplanEmail(maId);
            versandt++;
            updateStatus(maId, 'success', 'Versendet');

        } catch (error) {
            fehler++;
            updateStatus(maId, 'error', 'Fehler: ' + error.message);
            logError(`Fehler bei MA_ID ${maId}: ${error.message}`);
        }

        // Progress aktualisieren
        const progress = ((i + 1) / selected.length) * 100;
        if (elements.progressBar) elements.progressBar.style.width = progress + '%';
    }

    // Statistik aktualisieren
    if (elements.anzahlVersandt) elements.anzahlVersandt.textContent = versandt;
    if (elements.anzahlFehler) elements.anzahlFehler.textContent = fehler;

    // UI zurücksetzen
    if (elements.btnVersenden) elements.btnVersenden.disabled = false;

    showSuccess(`${versandt} E-Mails versendet, ${fehler} Fehler`);
}

async function versendeDienstplanEmail(maId) {
    const vonDatum = elements.vonDatum?.value;
    const bisDatum = elements.bisDatum?.value;
    const betreff = elements.betreff?.value;
    const nachricht = elements.nachrichtText?.value;
    const mitPdf = elements.pdfAnhaengen?.checked || false;

    return await Bridge.execute('versendeDienstplanEmail', {
        ma_id: maId,
        von: vonDatum,
        bis: bisDatum,
        betreff: betreff,
        nachricht: nachricht,
        mit_pdf: mitPdf
    });
}

function getSelectedMitarbeiter() {
    const checkboxes = elements.mitarbeiterListe?.querySelectorAll('.ma-checkbox:checked');
    return Array.from(checkboxes || []).map(cb => parseInt(cb.value));
}

function updateStatus(maId, status, text) {
    const statusElement = document.querySelector(`.ma-status[data-ma-id="${maId}"]`);
    if (statusElement) {
        statusElement.className = `ma-status ${status}`;
        statusElement.textContent = text;
    }
}

function logError(message) {
    if (elements.statusLog) {
        const entry = document.createElement('div');
        entry.className = 'log-entry error';
        entry.textContent = `${new Date().toLocaleTimeString()}: ${message}`;
        elements.statusLog.appendChild(entry);
    }
}

function applyFilter() {
    // TODO: Filter-Logik implementieren
    console.log('[MA_Serien_eMail_dienstplan] Filter anwenden');
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

function formatDateInput(date) {
    return date.toISOString().split('T')[0];
}

function getWeekNumber(date) {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + 4 - (d.getDay() || 7));
    const yearStart = new Date(d.getFullYear(), 0, 1);
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

function showError(msg) {
    console.error(msg);
    alert(msg); // TODO: Besseres UI-Feedback
}

function showSuccess(msg) {
    console.log(msg);
    alert(msg); // TODO: Besseres UI-Feedback
}

document.addEventListener('DOMContentLoaded', init);
