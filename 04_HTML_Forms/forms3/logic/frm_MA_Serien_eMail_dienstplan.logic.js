/**
 * frm_MA_Serien_eMail_dienstplan.logic.js
 * Logik für Serien-E-Mail-Versand von Dienstplänen
 * Versand von Dienstplan-E-Mails an mehrere Mitarbeiter
 *
 * VBA-Referenz: Form_frm_MA_Serien_eMail_dienstplan.bas
 *
 * VBA-Events implementiert:
 * - btnSendEmail_Click -> versendeEmails()
 * - cboeMail_Vorlage_AfterUpdate -> onVorlageChange()
 * - btnVorschau -> showVorschau() [NEU]
 * - btnAuftrag_Click -> openAuftrag() [NEU]
 * - btnSchnellPlan_Click -> openSchnellPlan() [NEU]
 * - btnZuAbsage_Click -> openZuAbsage() [NEU]
 * - btnAttachSuch_Click -> attachmentSuchen() [NEU]
 * - btnAttLoesch_Click -> attachmentLoeschen() [NEU]
 * - btnPDFCrea_Click -> pdfErstellen() [NEU]
 */
import { Bridge } from '../api/bridgeClient.js';

// VBA Bridge Server Endpoint
const VBA_BRIDGE_URL = 'http://localhost:5002/api/vba/execute';

let elements = {};
let selectedMitarbeiter = [];
let emailVorlagen = [];

// Formular-Kontext (wie in VBA: VA_ID, cboVADatum)
let formContext = {
    VA_ID: null,
    VADatum_ID: null,
    VAStart_ID: null
};

async function init() {
    console.log('[MA_Serien_eMail_dienstplan] Initialisierung...');

    elements = {
        mitarbeiterListe: document.getElementById('tbody_Empfaenger'),
        vorlageSelect: document.getElementById('cboVorlage'),
        vorschauContainer: document.getElementById('vorschauContainer'),

        btnAlleAuswaehlen: document.getElementById('btnAlleAuswaehlen'),
        btnKeineAuswaehlen: document.getElementById('btnKeineAuswaehlen'),
        btnVorschau: document.getElementById('btnVorschau'),
        btnVersenden: document.getElementById('btnSenden'),

        // Filter
        filterAbteilung: document.getElementById('filterAbteilung'),
        filterZeitraum: document.getElementById('filterZeitraum'),
        vonDatum: document.getElementById('datVon'),
        bisDatum: document.getElementById('datBis'),

        // E-Mail-Template
        betreff: document.getElementById('txtBetreff'),
        nachrichtText: document.getElementById('txtNachricht'),
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
        // E-Mail-Vorlagen laden
        await loadEmailVorlagen();

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
        <tr>
            <td><input type="checkbox" class="ma-checkbox" value="${m.MA_ID}" ${!m.eMail ? 'disabled' : ''}></td>
            <td>${m.Nachname}, ${m.Vorname}</td>
            <td class="${!m.eMail ? 'missing' : ''}">${m.eMail || 'Keine E-Mail'}</td>
            <td><span class="ma-status" data-ma-id="${m.MA_ID}"></span></td>
        </tr>
    `).join('');
}

async function loadEmailVorlagen() {
    try {
        const response = await fetch('http://localhost:5000/api/email-vorlagen');
        const data = await response.json();

        if (data.success) {
            emailVorlagen = data.vorlagen;
            populateVorlageSelect(emailVorlagen);
        } else {
            console.error('[MA_Serien_eMail_dienstplan] Fehler beim Laden der Vorlagen:', data.error);
        }
    } catch (error) {
        console.error('[MA_Serien_eMail_dienstplan] Fehler beim Laden der Vorlagen:', error);
        showError('E-Mail-Vorlagen konnten nicht geladen werden');
    }
}

function populateVorlageSelect(vorlagen) {
    if (!elements.vorlageSelect) return;

    elements.vorlageSelect.innerHTML = '<option value="">-- Vorlage wählen --</option>' +
        vorlagen.map(v => `<option value="${v.id}">${v.name}</option>`).join('');
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

    // Vorlage auswählen
    if (elements.vorlageSelect) {
        elements.vorlageSelect.addEventListener('change', onVorlageChange);
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

function onVorlageChange() {
    const vorlageId = parseInt(elements.vorlageSelect.value);
    if (!vorlageId) return;

    const vorlage = emailVorlagen.find(v => v.id === vorlageId);
    if (vorlage) {
        if (elements.betreff) {
            elements.betreff.value = vorlage.betreff || '';
        }
        if (elements.nachrichtText) {
            elements.nachrichtText.value = vorlage.text || '';
        }
        console.log('[MA_Serien_eMail_dienstplan] Vorlage geladen:', vorlage.name);
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
    if (typeof Toast !== 'undefined') Toast.error(msg);
    else alert(msg);
}

function showSuccess(msg) {
    console.log(msg);
    if (typeof Toast !== 'undefined') Toast.success(msg);
    else alert(msg);
}

// ============================================
// VBA-BRIDGE FUNKTIONEN
// ============================================

/**
 * Ruft VBA-Funktion über Bridge Server auf
 * @param {string} funcName - Name der VBA-Funktion
 * @param {object} args - Argumente für die Funktion
 * @returns {Promise<any>} - Ergebnis der VBA-Funktion
 */
async function callVBAFunction(funcName, args = {}) {
    console.log(`[MA_Serien_eMail_dienstplan] VBA Call: ${funcName}`, args);

    try {
        const response = await fetch(VBA_BRIDGE_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                function: funcName,
                args: args
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (!result.success) {
            throw new Error(result.error || 'VBA-Funktion fehlgeschlagen');
        }

        console.log(`[MA_Serien_eMail_dienstplan] VBA Result:`, result);
        return result.result;

    } catch (error) {
        console.error(`[MA_Serien_eMail_dienstplan] VBA Error:`, error);
        throw error;
    }
}

/**
 * btnAuftrag_Click - Öffnet Auftragstamm mit aktuellem Auftrag
 * VBA: DoCmd.OpenForm "frm_VA_Auftragstamm" + Call Form_frm_VA_Auftragstamm.VAOpen(iVA_ID, iVADatum_ID)
 */
async function openAuftrag() {
    console.log('[MA_Serien_eMail_dienstplan] openAuftrag');

    if (!formContext.VA_ID) {
        // Ohne VA_ID einfach Auftragstamm öffnen (Navigation)
        navigateToForm('frm_va_Auftragstamm.html');
        return;
    }

    // Mit VA_ID: Im Shell-Kontext navigieren
    const params = new URLSearchParams({
        va_id: formContext.VA_ID,
        vadatum_id: formContext.VADatum_ID || ''
    });
    navigateToForm(`frm_va_Auftragstamm.html?${params.toString()}`);
}

/**
 * btnSchnellPlan_Click - Öffnet Schnellauswahl mit aktuellem Auftrag
 * VBA: DoCmd.OpenForm "frm_MA_VA_Schnellauswahl" + Call Form_frm_MA_VA_Schnellauswahl.VAOpen(iVA_ID, iVADatum_ID)
 */
async function openSchnellPlan() {
    console.log('[MA_Serien_eMail_dienstplan] openSchnellPlan');

    if (!formContext.VA_ID) {
        navigateToForm('frm_MA_VA_Schnellauswahl.html');
        return;
    }

    const params = new URLSearchParams({
        va_id: formContext.VA_ID,
        vadatum_id: formContext.VADatum_ID || ''
    });
    navigateToForm(`frm_MA_VA_Schnellauswahl.html?${params.toString()}`);
}

/**
 * btnZuAbsage_Click - Öffnet Zu-/Absage-Formular
 * VBA: DoCmd.OpenForm "frmTop_MA_ZuAbsage"
 */
async function openZuAbsage() {
    console.log('[MA_Serien_eMail_dienstplan] openZuAbsage');

    try {
        // Versuche über VBA Bridge zu öffnen
        await callVBAFunction('HTML_OpenForm', {
            formName: 'frmTop_MA_ZuAbsage'
        });
        showSuccess('Zu-/Absage-Formular geöffnet');
    } catch (error) {
        console.warn('[MA_Serien_eMail_dienstplan] VBA Bridge nicht verfügbar, öffne HTML-Version');
        // Fallback: Navigiere zu HTML-Version falls vorhanden
        navigateToForm('frmTop_MA_ZuAbsage.html');
    }
}

/**
 * btnAttachSuch_Click - Attachment-Datei suchen
 * VBA: s = AlleSuch() + INSERT INTO tbltmp_Attachfile
 */
async function attachmentSuchen() {
    console.log('[MA_Serien_eMail_dienstplan] attachmentSuchen');

    try {
        const result = await callVBAFunction('HTML_AttachmentSuchen', {
            VA_ID: formContext.VA_ID,
            VADatum_ID: formContext.VADatum_ID
        });

        if (result && result.filename) {
            showSuccess(`Attachment hinzugefügt: ${result.filename}`);
            // TODO: Attachment-Liste aktualisieren wenn UI vorhanden
        }
    } catch (error) {
        showError('Attachment-Suche fehlgeschlagen: ' + error.message);
    }
}

/**
 * btnAttLoesch_Click - Alle Attachments löschen
 * VBA: DELETE * FROM tbltmp_Attachfile
 */
async function attachmentLoeschen() {
    console.log('[MA_Serien_eMail_dienstplan] attachmentLoeschen');

    if (!confirm('Alle Attachments entfernen?')) {
        return;
    }

    try {
        await callVBAFunction('HTML_AttachmentLoeschen', {});
        showSuccess('Attachments entfernt');
        // TODO: Attachment-Liste aktualisieren wenn UI vorhanden
    } catch (error) {
        showError('Fehler beim Löschen: ' + error.message);
    }
}

/**
 * btnPDFCrea_Click - PDF-Zusage erstellen und als Attachment hinzufügen
 * VBA: DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", "PDF", PDF_Datei
 */
async function pdfErstellen() {
    console.log('[MA_Serien_eMail_dienstplan] pdfErstellen');

    if (!formContext.VA_ID || !formContext.VADatum_ID) {
        showError('Bitte zuerst einen Auftrag und Datum auswählen');
        return;
    }

    try {
        const result = await callVBAFunction('HTML_PDF_Zusage_Erstellen', {
            VA_ID: formContext.VA_ID,
            VADatum_ID: formContext.VADatum_ID
        });

        if (result && result.filename) {
            showSuccess(`PDF erstellt: ${result.filename}`);
        } else {
            showSuccess('PDF als Attachment hinzugefügt');
        }
    } catch (error) {
        showError('PDF-Erstellung fehlgeschlagen: ' + error.message);
    }
}

/**
 * btnPosListeAtt_Click - Positionsliste als Attachment hinzufügen
 * VBA: Lookup in tbl_Zusatzdateien nach Kurzbeschreibung = VA_ID_VADatum_ID
 */
async function positionslisteAnhaengen() {
    console.log('[MA_Serien_eMail_dienstplan] positionslisteAnhaengen');

    if (!formContext.VA_ID || !formContext.VADatum_ID) {
        showError('Bitte zuerst einen Auftrag und Datum auswählen');
        return;
    }

    try {
        const result = await callVBAFunction('HTML_PosListeAtt', {
            VA_ID: formContext.VA_ID,
            VADatum_ID: formContext.VADatum_ID
        });

        if (result && result.found) {
            showSuccess('Positionsliste angehängt');
        } else {
            showError('Keine Positionsliste für diesen Auftrag/Tag gefunden');
        }
    } catch (error) {
        showError('Fehler: ' + error.message);
    }
}

/**
 * Navigiert zu einem anderen Formular (Shell-Integration)
 */
function navigateToForm(formUrl) {
    // Prüfe ob in Shell eingebettet
    if (window.parent && window.parent !== window) {
        window.parent.postMessage({
            type: 'NAVIGATE',
            form: formUrl
        }, '*');
    } else {
        // Direkter Navigation
        window.location.href = formUrl;
    }
}

/**
 * VAOpen - Öffnet Formular mit Auftragsdaten (wird von außen aufgerufen)
 * VBA: Public Function VAOpen(iVA_ID As Long, iVADatum_ID As Long)
 */
async function VAOpen(va_id, vadatum_id) {
    console.log(`[MA_Serien_eMail_dienstplan] VAOpen: VA_ID=${va_id}, VADatum_ID=${vadatum_id}`);

    formContext.VA_ID = va_id;
    formContext.VADatum_ID = vadatum_id;

    // Daten für diesen Auftrag laden
    try {
        // Mitarbeiter für diesen Auftrag laden (geplant + zugesagt)
        const mitarbeiter = await Bridge.execute('getMitarbeiterFuerAuftrag', {
            va_id: va_id,
            vadatum_id: vadatum_id
        });

        if (mitarbeiter && mitarbeiter.length > 0) {
            renderMitarbeiterListe(mitarbeiter);
        }
    } catch (error) {
        console.error('[MA_Serien_eMail_dienstplan] Fehler bei VAOpen:', error);
    }
}

/**
 * Autosend - Automatischer E-Mail-Versand (wird von Auftragstamm aufgerufen)
 * VBA: Public Function Autosend(iTyp As Integer, iVA_ID As Long, iVADatum_ID As Long)
 * Typ 1 = Einladung (geplante MA, alle Zeiten einzeln, mit Voting)
 * Typ 2 = Versammlungsinfo (alle MA, alle Zeiten zusammen, PDF-Attach)
 * Typ 3 = Positionsliste (zugesagte MA, alle Zeiten, Positionsliste-Attach)
 */
async function Autosend(typ, va_id, vadatum_id) {
    console.log(`[MA_Serien_eMail_dienstplan] Autosend: Typ=${typ}, VA_ID=${va_id}, VADatum_ID=${vadatum_id}`);

    try {
        const result = await callVBAFunction('HTML_Autosend_Dienstplan', {
            typ: typ,
            VA_ID: va_id,
            VADatum_ID: vadatum_id
        });

        showSuccess(`E-Mails für Typ ${typ} versendet`);
        return result;
    } catch (error) {
        showError('Autosend fehlgeschlagen: ' + error.message);
        throw error;
    }
}

// Globale Funktionen für onclick-Handler verfügbar machen
window.openAuftrag = openAuftrag;
window.openSchnellPlan = openSchnellPlan;
window.openZuAbsage = openZuAbsage;
window.attachmentSuchen = attachmentSuchen;
window.attachmentLoeschen = attachmentLoeschen;
window.pdfErstellen = pdfErstellen;
window.positionslisteAnhaengen = positionslisteAnhaengen;
window.VAOpen = VAOpen;
window.Autosend = Autosend;

document.addEventListener('DOMContentLoaded', init);
