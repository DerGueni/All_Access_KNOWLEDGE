/**
 * frm_MA_Serien_eMail_Auftrag.logic.js
 * Logik für Serien-E-Mail-Versand von Auftragsbestätigungen
 * Versand von Auftrags-E-Mails an zugeordnete Mitarbeiter
 */
import { Bridge } from '../../api/bridgeClient.js';

let elements = {};
let currentAuftragId = null;

async function init() {
    console.log('[MA_Serien_eMail_Auftrag] Initialisierung...');

    elements = {
        auftragSelect: document.getElementById('auftragSelect'),
        datumSelect: document.getElementById('datumSelect'),
        mitarbeiterListe: document.getElementById('mitarbeiterListe'),
        vorschauContainer: document.getElementById('vorschauContainer'),

        btnAlleAuswaehlen: document.getElementById('btnAlleAuswaehlen'),
        btnKeineAuswaehlen: document.getElementById('btnKeineAuswaehlen'),
        btnVorschau: document.getElementById('btnVorschau'),
        btnVersenden: document.getElementById('btnVersenden'),

        // E-Mail-Template
        betreff: document.getElementById('betreff'),
        nachrichtText: document.getElementById('nachrichtText'),

        // Auftragsinformationen einschließen
        inkludiereObjekt: document.getElementById('inkludiereObjekt'),
        inkludiereZeiten: document.getElementById('inkludiereZeiten'),
        inkludiereAnfahrt: document.getElementById('inkludiereAnfahrt'),
        inkludiereKontakt: document.getElementById('inkludiereKontakt'),

        // Statistik
        anzahlZugeordnet: document.getElementById('anzahlZugeordnet'),
        anzahlAusgewaehlt: document.getElementById('anzahlAusgewaehlt'),
        anzahlVersandt: document.getElementById('anzahlVersandt'),
        anzahlFehler: document.getElementById('anzahlFehler'),

        progressBar: document.getElementById('progressBar'),
        statusLog: document.getElementById('statusLog')
    };

    await loadInitialData();
    bindEvents();
}

async function loadInitialData() {
    try {
        // Aufträge laden
        const auftraege = await Bridge.execute('getAuftragListe', { limit: 100 });
        populateAuftragSelect(auftraege);

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler beim Laden:', error);
        showError('Daten konnten nicht geladen werden');
    }
}

function populateAuftragSelect(auftraege) {
    if (!elements.auftragSelect) return;

    elements.auftragSelect.innerHTML = '<option value="">-- Auftrag wählen --</option>' +
        auftraege.map(a => `
            <option value="${a.VA_ID}">
                ${a.Auftrag || 'N/A'} - ${a.Objekt || ''} (${formatDate(a.VADatum)})
            </option>
        `).join('');
}

async function loadEinsatztage(vaId) {
    try {
        const tage = await Bridge.execute('getEinsatztage', { va_id: vaId });
        populateDatumSelect(tage);

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler beim Laden der Einsatztage:', error);
    }
}

function populateDatumSelect(tage) {
    if (!elements.datumSelect) return;

    elements.datumSelect.innerHTML = '<option value="">-- Alle Tage --</option>' +
        tage.map(t => `
            <option value="${t.VADatum}">
                ${formatDate(t.VADatum)} (${getDayName(t.VADatum)})
            </option>
        `).join('');
}

async function loadZugeordeneMitarbeiter(vaId, datum = null) {
    try {
        const params = { va_id: vaId };
        if (datum) params.datum = datum;

        const mitarbeiter = await Bridge.execute('getZugeordneteMitarbeiter', params);
        renderMitarbeiterListe(mitarbeiter);

        if (elements.anzahlZugeordnet) {
            elements.anzahlZugeordnet.textContent = mitarbeiter.length;
        }

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler beim Laden der Mitarbeiter:', error);
        showError('Mitarbeiter konnten nicht geladen werden');
    }
}

function renderMitarbeiterListe(mitarbeiter) {
    if (!elements.mitarbeiterListe) return;

    elements.mitarbeiterListe.innerHTML = mitarbeiter.map(m => `
        <div class="ma-item" data-id="${m.MA_ID}">
            <input type="checkbox" class="ma-checkbox" value="${m.MA_ID}"
                   ${!m.eMail ? 'disabled' : ''} checked>
            <span class="ma-name">${m.Nachname}, ${m.Vorname}</span>
            <span class="ma-email ${!m.eMail ? 'missing' : ''}">${m.eMail || 'Keine E-Mail'}</span>
            <span class="ma-zeiten">${m.VA_Start} - ${m.VA_Ende}</span>
            <span class="ma-status" data-ma-id="${m.MA_ID}"></span>
        </div>
    `).join('');

    updateAuswahlStatistik();
}

function bindEvents() {
    // Auftrag auswählen
    if (elements.auftragSelect) {
        elements.auftragSelect.addEventListener('change', async (e) => {
            currentAuftragId = e.target.value;
            if (currentAuftragId) {
                await loadEinsatztage(currentAuftragId);
                await loadZugeordeneMitarbeiter(currentAuftragId);
                updateBetreff();
            }
        });
    }

    // Datum filtern
    if (elements.datumSelect) {
        elements.datumSelect.addEventListener('change', async (e) => {
            const datum = e.target.value || null;
            if (currentAuftragId) {
                await loadZugeordeneMitarbeiter(currentAuftragId, datum);
            }
        });
    }

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
}

function updateAuswahlStatistik() {
    const selected = elements.mitarbeiterListe?.querySelectorAll('.ma-checkbox:checked');
    if (elements.anzahlAusgewaehlt) {
        elements.anzahlAusgewaehlt.textContent = selected?.length || 0;
    }
}

async function updateBetreff() {
    if (!currentAuftragId || !elements.betreff) return;

    try {
        const auftrag = await Bridge.auftraege.get(currentAuftragId);
        elements.betreff.value = `Auftragsbestätigung: ${auftrag.Objekt || auftrag.Auftrag}`;

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler beim Laden des Auftrags:', error);
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
        const mitarbeiter = await Bridge.mitarbeiter.get(maId);
        const auftrag = await Bridge.auftraege.get(currentAuftragId);

        renderVorschau(mitarbeiter, auftrag);

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei Vorschau:', error);
        showError('Vorschau konnte nicht erstellt werden');
    }
}

function renderVorschau(mitarbeiter, auftrag) {
    if (!elements.vorschauContainer) return;

    const betreff = elements.betreff?.value || 'Auftragsbestätigung';
    const nachricht = elements.nachrichtText?.value || '';

    let details = '';

    if (elements.inkludiereObjekt?.checked) {
        details += `<p><strong>Objekt:</strong> ${auftrag.Objekt || 'N/A'}</p>`;
    }

    if (elements.inkludiereZeiten?.checked) {
        details += `<p><strong>Datum:</strong> ${formatDate(auftrag.VADatum)}<br>
                    <strong>Zeit:</strong> ${auftrag.VA_Start} - ${auftrag.VA_Ende}</p>`;
    }

    if (elements.inkludiereAnfahrt?.checked && auftrag.Anfahrt) {
        details += `<p><strong>Anfahrt:</strong> ${auftrag.Anfahrt}</p>`;
    }

    if (elements.inkludiereKontakt?.checked && auftrag.Kontakt) {
        details += `<p><strong>Kontakt:</strong> ${auftrag.Kontakt}</p>`;
    }

    elements.vorschauContainer.innerHTML = `
        <div class="email-vorschau">
            <div class="email-header">
                <strong>An:</strong> ${mitarbeiter.eMail}<br>
                <strong>Betreff:</strong> ${betreff}
            </div>
            <div class="email-body">
                <p>Hallo ${mitarbeiter.Vorname} ${mitarbeiter.Nachname},</p>
                <p>${nachricht}</p>
                ${details}
            </div>
        </div>
    `;
}

async function versendeEmails() {
    const selected = getSelectedMitarbeiter();

    if (selected.length === 0) {
        showError('Bitte wählen Sie mindestens einen Mitarbeiter aus');
        return;
    }

    if (!currentAuftragId) {
        showError('Bitte wählen Sie einen Auftrag aus');
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
            await versendeAuftragsEmail(maId);
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

async function versendeAuftragsEmail(maId) {
    const betreff = elements.betreff?.value;
    const nachricht = elements.nachrichtText?.value;
    const datum = elements.datumSelect?.value || null;

    const optionen = {
        inkludiere_objekt: elements.inkludiereObjekt?.checked || false,
        inkludiere_zeiten: elements.inkludiereZeiten?.checked || false,
        inkludiere_anfahrt: elements.inkludiereAnfahrt?.checked || false,
        inkludiere_kontakt: elements.inkludiereKontakt?.checked || false
    };

    return await Bridge.execute('versendeAuftragsEmail', {
        ma_id: maId,
        va_id: currentAuftragId,
        datum: datum,
        betreff: betreff,
        nachricht: nachricht,
        optionen: optionen
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

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

function getDayName(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    const days = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    return days[d.getDay()];
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
