/**
 * frm_MA_Serien_eMail_Auftrag.logic.js
 * Logik fuer Serien-E-Mail-Versand von Auftragsbestaetigungen
 *
 * VBA-Funktions-Mapping:
 * - VA_ID_AfterUpdate -> onVAIDChange
 * - cboVADatum_AfterUpdate -> onVADatumChange
 * - cboeMail_Vorlage_AfterUpdate -> onVorlageChange
 * - IstPlanAlle_AfterUpdate -> onIstPlanAlleChange
 * - IstAlleZeiten_AfterUpdate -> onIstAlleZeitenChange
 * - IstHTML_AfterUpdate -> onIstHTMLChange
 * - lstZeiten_AfterUpdate -> onLstZeitenChange
 * - lstMA_Plan_Click -> onLstMAPlanClick
 * - ogZeitraum_AfterUpdate -> onOgZeitraumChange
 * - btnSendEmail_Click -> btnSendEmailClick
 * - btnAuftrag_Click -> btnAuftragClick
 * - btnAttachSuch_Click -> btnAttachSuchClick
 * - btnAttLoesch_Click -> btnAttLoeschClick
 * - btnPDFCrea_Click -> btnPDFCreaClick
 * - btnPosListeAtt_Click -> btnPosListeAttClick
 */

// API_BASE wird von webview2-bridge.js definiert - Fallback falls nicht vorhanden
const SERIEN_EMAIL_API = (typeof API_BASE !== 'undefined') ? API_BASE : 'http://localhost:5000/api';
const SERIEN_EMAIL_VBA_BRIDGE = 'http://localhost:5002';

let elements = {};
let currentVAID = null;
let currentVADatumID = null;
let emailVorlagen = [];
let attachments = [];

// ============================================================
// INITIALISIERUNG
// ============================================================

async function init() {
    console.log('[MA_Serien_eMail_Auftrag] Initialisierung...');

    elements = {
        // Auftrag/Datum
        VA_ID: document.getElementById('VA_ID'),
        cboVADatum: document.getElementById('cboVADatum'),

        // Vorlage
        cboeMail_Vorlage: document.getElementById('cboeMail_Vorlage'),

        // Filter
        IstPlanAlle: document.querySelectorAll('input[name="IstPlanAlle"]'),
        IstAlleZeiten: document.getElementById('IstAlleZeiten'),
        cbInfoAtConsec: document.getElementById('cbInfoAtConsec'),

        // Listen
        lstZeiten: document.getElementById('lstZeiten'),
        lstZeitenContainer: document.getElementById('lstZeitenContainer'),
        lstMA_Plan: document.getElementById('lstMA_Plan'),
        chkSelectAll: document.getElementById('chkSelectAll'),

        // Zeitraum
        ogZeitraum: document.querySelectorAll('input[name="ogZeitraum"]'),

        // Anhaenge
        btnAttachSuch: document.getElementById('btnAttachSuch'),
        btnAttLoesch: document.getElementById('btnAttLoesch'),
        btnPDFCrea: document.getElementById('btnPDFCrea'),
        btnPosListeAtt: document.getElementById('btnPosListeAtt'),
        attachmentList: document.getElementById('attachmentList'),

        // E-Mail Felder
        AbsendenAls: document.getElementById('AbsendenAls'),
        Voting_Text: document.getElementById('Voting_Text'),
        Betreffzeile: document.getElementById('Betreffzeile'),
        txEmpfaenger: document.getElementById('txEmpfaenger'),
        cboSendPrio: document.getElementById('cboSendPrio'),
        IstHTML: document.getElementById('IstHTML'),
        Textinhalt: document.getElementById('Textinhalt'),

        // Statistik
        iGes_MA: document.getElementById('iGes_MA'),

        // Buttons
        btnSendEmail: document.getElementById('btnSendEmail'),
        btnAuftrag: document.getElementById('btnAuftrag'),

        // Vorschau
        previewAn: document.getElementById('previewAn'),
        previewBetreff: document.getElementById('previewBetreff'),
        previewBody: document.getElementById('previewBody')
    };

    await loadInitialData();
    bindEvents();

    // Form_Open Logik: Datum setzen, Attachments loeschen
    document.getElementById('header-date').textContent = new Date().toLocaleDateString('de-DE');
    attachments = [];
    updateAttachmentList();
}

async function loadInitialData() {
    try {
        // Auftraege laden (VA_ID RowSource)
        const auftraegeResp = await fetch(`${SERIEN_EMAIL_API}/auftraege?limit=200`);
        const auftraege = await auftraegeResp.json();
        populateVAIDSelect(auftraege);

        // E-Mail Vorlagen laden
        await loadEmailVorlagen();

        // Voting-Texte laden
        await loadVotingTexte();

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler beim Laden:', error);
    }
}

function populateVAIDSelect(auftraege) {
    if (!elements.VA_ID) return;

    const arr = Array.isArray(auftraege) ? auftraege : (auftraege.auftraege || []);

    elements.VA_ID.innerHTML = '<option value="">-- Auftrag waehlen --</option>' +
        arr.map(a => `<option value="${a.ID || a.VA_ID}">${a.Auftrag || ''} - ${a.Objekt || ''}</option>`).join('');
}

async function loadEmailVorlagen() {
    try {
        const resp = await fetch(`${SERIEN_EMAIL_API}/email-vorlagen`);
        if (resp.ok) {
            const data = await resp.json();
            emailVorlagen = data.vorlagen || data || [];
            populateVorlageSelect();
        }
    } catch (error) {
        console.warn('[MA_Serien_eMail_Auftrag] E-Mail-Vorlagen nicht verfuegbar:', error);
        // Fallback: Statische Vorlagen
        emailVorlagen = [
            { ID: 1, eMail_Vorlage: 'Einladung', Absenden_als: '', Voting_Text: '', BetreffZeile: 'Einladung', IstHTML: false },
            { ID: 2, eMail_Vorlage: 'Versammlungsinfo', Absenden_als: '', Voting_Text: '', BetreffZeile: 'Versammlungsinfo', IstHTML: false },
            { ID: 8, eMail_Vorlage: 'Einsatzliste', Absenden_als: '', Voting_Text: '', BetreffZeile: 'Einsatzliste', IstHTML: true },
            { ID: 10, eMail_Vorlage: 'Einsatzliste KD', Absenden_als: '', Voting_Text: '', BetreffZeile: 'Einsatzliste', IstHTML: true },
            { ID: 11, eMail_Vorlage: 'Einsatzliste SUB', Absenden_als: '', Voting_Text: '', BetreffZeile: 'Einsatzliste SUB', IstHTML: true }
        ];
        populateVorlageSelect();
    }
}

function populateVorlageSelect() {
    if (!elements.cboeMail_Vorlage) return;

    elements.cboeMail_Vorlage.innerHTML = '<option value="">-- Vorlage waehlen --</option>' +
        emailVorlagen.map(v => `<option value="${v.ID}">${v.eMail_Vorlage || v.name || 'Vorlage ' + v.ID}</option>`).join('');
}

async function loadVotingTexte() {
    try {
        const resp = await fetch(`${SERIEN_EMAIL_API}/voting-texte`);
        if (resp.ok) {
            const data = await resp.json();
            populateVotingSelect(data.texte || data || []);
        }
    } catch (error) {
        console.warn('[MA_Serien_eMail_Auftrag] Voting-Texte nicht verfuegbar');
    }
}

function populateVotingSelect(texte) {
    if (!elements.Voting_Text) return;

    elements.Voting_Text.innerHTML = '<option value="">-- kein Voting --</option>' +
        texte.map(t => `<option value="${t.ID || t}">${t.Text || t}</option>`).join('');
}

// ============================================================
// EVENT BINDING
// ============================================================

function bindEvents() {
    // VA_ID AfterUpdate
    if (elements.VA_ID) {
        elements.VA_ID.addEventListener('change', onVAIDChange);
    }

    // cboVADatum AfterUpdate
    if (elements.cboVADatum) {
        elements.cboVADatum.addEventListener('change', onVADatumChange);
    }

    // cboeMail_Vorlage AfterUpdate
    if (elements.cboeMail_Vorlage) {
        elements.cboeMail_Vorlage.addEventListener('change', onVorlageChange);
    }

    // IstPlanAlle AfterUpdate (RadioGroup)
    elements.IstPlanAlle.forEach(radio => {
        radio.addEventListener('change', onIstPlanAlleChange);
    });

    // IstAlleZeiten AfterUpdate
    if (elements.IstAlleZeiten) {
        elements.IstAlleZeiten.addEventListener('change', onIstAlleZeitenChange);
    }

    // IstHTML AfterUpdate
    if (elements.IstHTML) {
        elements.IstHTML.addEventListener('change', onIstHTMLChange);
    }

    // lstZeiten AfterUpdate
    if (elements.lstZeiten) {
        elements.lstZeiten.addEventListener('change', onLstZeitenChange);
    }

    // lstMA_Plan Click
    if (elements.lstMA_Plan) {
        elements.lstMA_Plan.addEventListener('click', onLstMAPlanClick);
    }

    // ogZeitraum AfterUpdate (RadioGroup)
    elements.ogZeitraum.forEach(radio => {
        radio.addEventListener('change', onOgZeitraumChange);
    });

    // Buttons
    if (elements.btnSendEmail) {
        elements.btnSendEmail.addEventListener('click', btnSendEmailClick);
    }

    if (elements.btnAuftrag) {
        elements.btnAuftrag.addEventListener('click', btnAuftragClick);
    }

    if (elements.btnAttachSuch) {
        elements.btnAttachSuch.addEventListener('click', btnAttachSuchClick);
    }

    if (elements.btnAttLoesch) {
        elements.btnAttLoesch.addEventListener('click', btnAttLoeschClick);
    }

    if (elements.btnPDFCrea) {
        elements.btnPDFCrea.addEventListener('click', btnPDFCreaClick);
    }

    if (elements.btnPosListeAtt) {
        elements.btnPosListeAtt.addEventListener('click', btnPosListeAttClick);
    }

    // SelectAll Checkbox
    if (elements.chkSelectAll) {
        elements.chkSelectAll.addEventListener('change', onSelectAllChange);
    }
}

// ============================================================
// VBA EVENT HANDLER - AfterUpdate
// ============================================================

/**
 * VA_ID_AfterUpdate - Auftrag geaendert
 * VBA: Laedt Datumsauswahl, Schichten, Mitarbeiter
 */
async function onVAIDChange() {
    const vaId = elements.VA_ID?.value;
    if (!vaId) {
        clearFormData();
        return;
    }

    currentVAID = parseInt(vaId);
    console.log('[MA_Serien_eMail_Auftrag] Auftrag gewaehlt:', currentVAID);

    try {
        // cboVADatum RowSource laden
        const tageResp = await fetch(`${SERIEN_EMAIL_API}/auftraege/${currentVAID}/einsatztage`);
        const tage = await tageResp.json();
        populateDatumSelect(tage);

        // Erstes Datum auswaehlen
        if (tage.length > 0) {
            elements.cboVADatum.value = tage[0].ID || tage[0].VADatum_ID;
            await onVADatumChange();
        }

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei VA_ID_AfterUpdate:', error);
    }
}

function populateDatumSelect(tage) {
    if (!elements.cboVADatum) return;

    const arr = Array.isArray(tage) ? tage : (tage.tage || []);

    elements.cboVADatum.innerHTML = '<option value="">-- Datum --</option>' +
        arr.map(t => {
            const datum = t.VADatum ? new Date(t.VADatum).toLocaleDateString('de-DE') : '';
            return `<option value="${t.ID || t.VADatum_ID}">${datum}</option>`;
        }).join('');
}

/**
 * cboVADatum_AfterUpdate - Datum geaendert
 * VBA: Laedt lstZeiten und lstMA_Plan, Statistik
 */
async function onVADatumChange() {
    const vadatumId = elements.cboVADatum?.value;
    if (!vadatumId || !currentVAID) return;

    currentVADatumID = parseInt(vadatumId);
    console.log('[MA_Serien_eMail_Auftrag] Datum gewaehlt:', currentVADatumID);

    // Attachments loeschen (wie in VBA)
    attachments = [];
    updateAttachmentList();

    try {
        // lstZeiten laden (Schichten)
        const schichtenResp = await fetch(`${SERIEN_EMAIL_API}/auftraege/${currentVAID}/schichten?vadatum_id=${currentVADatumID}`);
        const schichten = await schichtenResp.json();
        populateLstZeiten(schichten);

        // Statistik aktualisieren
        await updateStatistik();

        // MA-Liste aktualisieren
        await onIstPlanAlleChange();

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei cboVADatum_AfterUpdate:', error);
    }
}

function populateLstZeiten(schichten) {
    if (!elements.lstZeiten) return;

    const arr = Array.isArray(schichten) ? schichten : (schichten.schichten || []);

    elements.lstZeiten.innerHTML = arr.map(s => {
        const start = s.VA_Start || '';
        const ende = s.VA_Ende || '';
        return `<option value="${s.VAStart_ID || s.ID}">${s.MA_Anzahl_Ist || 0}/${s.MA_Anzahl || 0} - ${start} - ${ende}</option>`;
    }).join('');

    // Erstes Item auswaehlen
    if (elements.lstZeiten.options.length > 0) {
        elements.lstZeiten.selectedIndex = 0;
    }
}

/**
 * cboeMail_Vorlage_AfterUpdate - Vorlage geaendert
 * VBA: Fuellt Absender, Voting, Betreff, IstHTML, Textinhalt
 */
function onVorlageChange() {
    const vorlageId = parseInt(elements.cboeMail_Vorlage?.value);
    if (!vorlageId) return;

    const vorlage = emailVorlagen.find(v => v.ID === vorlageId);
    if (!vorlage) return;

    console.log('[MA_Serien_eMail_Auftrag] Vorlage gewaehlt:', vorlage);

    // Felder fuellen wie in VBA
    if (elements.AbsendenAls) elements.AbsendenAls.value = vorlage.Absenden_als || '';
    if (elements.Voting_Text) elements.Voting_Text.value = vorlage.Voting_Text || '';
    if (elements.Betreffzeile) elements.Betreffzeile.value = vorlage.BetreffZeile || '';
    if (elements.IstHTML) elements.IstHTML.checked = vorlage.IstHTML === true || vorlage.IstHTML === -1;
    if (elements.Textinhalt) elements.Textinhalt.value = vorlage.Textinhalt || '';

    // IstHTML_AfterUpdate aufrufen
    onIstHTMLChange();
}

/**
 * IstPlanAlle_AfterUpdate - Filter geaendert (Geplant/Zugesagt/Alle/Sub)
 * VBA: Aendert RowSource von lstMA_Plan
 */
async function onIstPlanAlleChange() {
    if (!currentVAID || !currentVADatumID) return;

    const selectedRadio = document.querySelector('input[name="IstPlanAlle"]:checked');
    const filter = parseInt(selectedRadio?.value) || 2;

    console.log('[MA_Serien_eMail_Auftrag] Filter gewaehlt:', filter);

    // Schicht-Filter
    const istAlleZeiten = elements.IstAlleZeiten?.checked;
    const vastartId = !istAlleZeiten ? elements.lstZeiten?.value : null;

    try {
        let endpoint = '';
        switch (filter) {
            case 1: // Zugesagt
                endpoint = `${SERIEN_EMAIL_API}/auftraege/${currentVAID}/zuordnungen?vadatum_id=${currentVADatumID}&status=zugesagt`;
                break;
            case 2: // Geplant
                endpoint = `${SERIEN_EMAIL_API}/auftraege/${currentVAID}/zuordnungen?vadatum_id=${currentVADatumID}&status=geplant`;
                break;
            case 3: // Alle
                endpoint = `${SERIEN_EMAIL_API}/auftraege/${currentVAID}/zuordnungen?vadatum_id=${currentVADatumID}`;
                break;
            case 4: // Subunternehmer
                endpoint = `${SERIEN_EMAIL_API}/auftraege/${currentVAID}/zuordnungen?vadatum_id=${currentVADatumID}&sub=true`;
                break;
        }

        if (vastartId) {
            endpoint += `&vastart_id=${vastartId}`;
        }

        const resp = await fetch(endpoint);
        const data = await resp.json();
        populateLstMAPlan(data);

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei IstPlanAlle_AfterUpdate:', error);
    }
}

function populateLstMAPlan(data) {
    if (!elements.lstMA_Plan) return;

    const arr = Array.isArray(data) ? data : (data.zuordnungen || data.mitarbeiter || []);

    if (arr.length === 0) {
        elements.lstMA_Plan.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#999;">Keine Mitarbeiter gefunden</td></tr>';
        return;
    }

    elements.lstMA_Plan.innerHTML = arr.map(m => `
        <tr data-ma-id="${m.MA_ID}">
            <td><input type="checkbox" class="ma-checkbox" value="${m.MA_ID}" ${m.Email ? 'checked' : 'disabled'}></td>
            <td>${m.Nachname || ''}</td>
            <td>${m.Vorname || ''}</td>
            <td>${m.Email || '<span style="color:#c00;">Keine E-Mail</span>'}</td>
            <td>${m.VA_Start || m.MVA_Start || ''}</td>
            <td>${m.VA_Ende || m.MVA_Ende || ''}</td>
        </tr>
    `).join('');

    updateAuswahlStatistik();
}

/**
 * IstAlleZeiten_AfterUpdate - Alle Zeiten Checkbox
 * VBA: Versteckt/zeigt lstZeiten
 */
function onIstAlleZeitenChange() {
    const alleZeiten = elements.IstAlleZeiten?.checked;

    if (elements.lstZeitenContainer) {
        elements.lstZeitenContainer.style.display = alleZeiten ? 'none' : 'block';
    }

    // MA-Liste aktualisieren
    onIstPlanAlleChange();
}

/**
 * IstHTML_AfterUpdate - HTML-Format Checkbox
 * VBA: Aendert Caption
 */
function onIstHTMLChange() {
    const istHTML = elements.IstHTML?.checked;
    console.log('[MA_Serien_eMail_Auftrag] IstHTML:', istHTML);
    // Keine sichtbare Aenderung noetig, wird beim Senden beruecksichtigt
}

/**
 * lstZeiten_AfterUpdate - Schicht ausgewaehlt
 * VBA: Ruft IstPlanAlle_AfterUpdate auf
 */
function onLstZeitenChange() {
    onIstPlanAlleChange();
}

/**
 * lstMA_Plan_Click - Mitarbeiter angeklickt
 * VBA: Warnt wenn IstAlleZeiten = False
 */
function onLstMAPlanClick(e) {
    if (!elements.IstAlleZeiten?.checked) {
        const checkbox = e.target.closest('.ma-checkbox');
        if (checkbox) {
            alert('Eine Mitarbeiterauswahl ist nur moeglich, wenn "Alle Zeiten" gesetzt ist, nicht bei Einzel-Schichten');
            checkbox.checked = false;
        }
    }
    updateAuswahlStatistik();
}

/**
 * ogZeitraum_AfterUpdate - Zeitraum fuer Einsatzliste
 * VBA: Setzt prp_Report1_Auftrag_IstTage und erstellt PDF
 */
async function onOgZeitraumChange() {
    const selectedRadio = document.querySelector('input[name="ogZeitraum"]:checked');
    const zeitraum = parseInt(selectedRadio?.value) || 1;

    console.log('[MA_Serien_eMail_Auftrag] Zeitraum gewaehlt:', zeitraum);

    // VBA Bridge aufrufen um Property zu setzen
    try {
        let istTage = -1;
        switch (zeitraum) {
            case 1: istTage = -1; break; // Gesamt
            case 2: istTage = 1; break;  // Ab heute
            case 3: istTage = 0; break;  // Nur dieser Tag
            case 4: istTage = 2; break;  // MA
        }

        await callVBABridge('Set_Priv_Property', { name: 'prp_Report1_Auftrag_IstTage', value: istTage });

        // Attachments loeschen und PDF erstellen
        attachments = [];
        updateAttachmentList();
        await btnPDFCreaClick();

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei ogZeitraum:', error);
    }
}

// ============================================================
// VBA EVENT HANDLER - Button Clicks
// ============================================================

/**
 * btnSendEmail_Click - E-Mails versenden
 * VBA: Komplexe Logik zum Sammeln der Empfaenger und Versenden
 */
async function btnSendEmailClick() {
    console.log('[MA_Serien_eMail_Auftrag] btnSendEmail_Click');

    // Validierung
    if (!currentVAID) {
        alert('Veranstaltung nicht ausgewaehlt');
        return;
    }
    if (!elements.Betreffzeile?.value?.trim()) {
        alert('Betreffzeile nicht eingegeben');
        return;
    }
    if (!elements.Textinhalt?.value?.trim()) {
        alert('eMailText nicht eingegeben');
        return;
    }

    // Empfaenger sammeln
    const checkboxes = elements.lstMA_Plan?.querySelectorAll('.ma-checkbox:checked:not(:disabled)');
    if (!checkboxes || checkboxes.length === 0) {
        alert('Keine Mitarbeiter mit E-Mail ausgewaehlt');
        return;
    }

    const empfaenger = Array.from(checkboxes).map(cb => {
        const row = cb.closest('tr');
        const emailCell = row?.querySelector('td:nth-child(4)');
        return emailCell?.textContent?.trim();
    }).filter(e => e && !e.includes('Keine'));

    if (empfaenger.length === 0) {
        alert('Keine gueltigen E-Mail-Adressen gefunden');
        return;
    }

    // Bestaetigung
    if (!confirm(`${empfaenger.length} E-Mail(s) versenden?`)) {
        return;
    }

    // Optional: Zusaetzlich an Info@Consec
    let empfaengerListe = empfaenger.join('; ');
    if (elements.cbInfoAtConsec?.checked) {
        empfaengerListe += '; info@consec-nuernberg.de';
    }

    // Eigener Empfaenger ueberschreibt?
    if (elements.txEmpfaenger?.value?.trim()) {
        empfaengerListe = elements.txEmpfaenger.value.trim();
    }

    try {
        // VBA Bridge zum Senden aufrufen
        const result = await callVBABridge('HTML_btnSendEmail_Click', {
            va_id: currentVAID,
            vadatum_id: currentVADatumID,
            empfaenger: empfaengerListe,
            absender: elements.AbsendenAls?.value || '',
            betreff: elements.Betreffzeile?.value || '',
            text: elements.Textinhalt?.value || '',
            ist_html: elements.IstHTML?.checked || false,
            prio: parseInt(elements.cboSendPrio?.value) || 1,
            voting: elements.Voting_Text?.value || '',
            attachments: attachments
        });

        alert(result?.message || 'E-Mail versendet');

        // Zurueck zum Auftrag
        btnAuftragClick();

    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler beim Senden:', error);
        alert('Fehler beim Senden: ' + error.message);
    }
}

/**
 * btnAuftrag_Click - Zurueck zum Auftrag
 * VBA: Schliesst Formular und oeffnet frm_VA_Auftragstamm
 */
function btnAuftragClick() {
    console.log('[MA_Serien_eMail_Auftrag] btnAuftrag_Click');

    if (currentVAID) {
        // Navigation zum Auftragstamm mit VA_ID
        if (window.parent && window.parent !== window) {
            window.parent.postMessage({
                type: 'NAVIGATE',
                form: 'frm_va_Auftragstamm',
                params: { va_id: currentVAID, vadatum_id: currentVADatumID }
            }, '*');
        } else {
            window.location.href = `frm_va_Auftragstamm.html?va_id=${currentVAID}&vadatum_id=${currentVADatumID}`;
        }
    } else {
        // Nur Formular oeffnen
        if (window.parent && window.parent !== window) {
            window.parent.postMessage({ type: 'NAVIGATE', form: 'frm_va_Auftragstamm' }, '*');
        } else {
            window.location.href = 'frm_va_Auftragstamm.html';
        }
    }
}

/**
 * btnAttachSuch_Click - Datei auswaehlen
 * VBA: Oeffnet Dateidialog und fuegt Attachment hinzu
 */
async function btnAttachSuchClick() {
    console.log('[MA_Serien_eMail_Auftrag] btnAttachSuch_Click');

    try {
        // VBA Bridge zum Dateiauswahl-Dialog aufrufen
        const result = await callVBABridge('AlleSuch', {});

        if (result?.path) {
            attachments.push(result.path);
            updateAttachmentList();
        }
    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei Dateiauswahl:', error);
        // Fallback: File Input erstellen
        const input = document.createElement('input');
        input.type = 'file';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (file) {
                attachments.push(file.name);
                updateAttachmentList();
            }
        };
        input.click();
    }
}

/**
 * btnAttLoesch_Click - Alle Anhaenge loeschen
 * VBA: DELETE * FROM tbltmp_Attachfile
 */
function btnAttLoeschClick() {
    console.log('[MA_Serien_eMail_Auftrag] btnAttLoesch_Click');
    attachments = [];
    updateAttachmentList();
}

/**
 * btnPDFCrea_Click - Einsatzliste als PDF erstellen
 * VBA: Erstellt PDF und fuegt als Attachment hinzu
 */
async function btnPDFCreaClick() {
    console.log('[MA_Serien_eMail_Auftrag] btnPDFCrea_Click');

    if (!currentVAID || !currentVADatumID) {
        alert('Bitte erst Auftrag und Datum waehlen');
        return;
    }

    try {
        // VBA Bridge zum PDF erstellen aufrufen
        const result = await callVBABridge('HTML_btnPDFCrea_Click', {
            va_id: currentVAID,
            vadatum_id: currentVADatumID
        });

        if (result?.pdf_path) {
            attachments.push(result.pdf_path);
            updateAttachmentList();
            console.log('[MA_Serien_eMail_Auftrag] PDF erstellt:', result.pdf_path);
        }
    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei PDF-Erstellung:', error);
        alert('Fehler bei PDF-Erstellung: ' + error.message);
    }
}

/**
 * btnPosListeAtt_Click - Positionsliste als Attachment hinzufuegen
 * VBA: Sucht Zusatzdatei und fuegt hinzu
 */
async function btnPosListeAttClick() {
    console.log('[MA_Serien_eMail_Auftrag] btnPosListeAtt_Click');

    if (!currentVAID || !currentVADatumID) return;

    try {
        const result = await callVBABridge('HTML_btnPosListeAtt_Click', {
            va_id: currentVAID,
            vadatum_id: currentVADatumID
        });

        if (result?.path) {
            attachments.push(result.path);
            updateAttachmentList();
        }
    } catch (error) {
        console.error('[MA_Serien_eMail_Auftrag] Fehler bei Positionsliste:', error);
    }
}

// ============================================================
// HILFSFUNKTIONEN
// ============================================================

function updateAttachmentList() {
    if (!elements.attachmentList) return;

    if (attachments.length === 0) {
        elements.attachmentList.textContent = 'Keine Anhaenge';
    } else {
        elements.attachmentList.innerHTML = attachments.map((a, i) => {
            const filename = a.split('\\').pop().split('/').pop();
            return `<div style="margin:2px 0;">${i + 1}. ${filename}</div>`;
        }).join('');
    }
}

async function updateStatistik() {
    if (!currentVAID || !currentVADatumID) return;

    try {
        const resp = await fetch(`${SERIEN_EMAIL_API}/auftraege/${currentVAID}/statistik?vadatum_id=${currentVADatumID}`);
        const data = await resp.json();

        if (elements.iGes_MA) {
            elements.iGes_MA.textContent = `Ist / Soll: ${data.ist || 0} / ${data.soll || 0}`;
        }
    } catch (error) {
        console.warn('[MA_Serien_eMail_Auftrag] Statistik nicht verfuegbar');
    }
}

function updateAuswahlStatistik() {
    const checked = elements.lstMA_Plan?.querySelectorAll('.ma-checkbox:checked:not(:disabled)');
    const total = elements.lstMA_Plan?.querySelectorAll('.ma-checkbox:not(:disabled)');

    console.log(`[MA_Serien_eMail_Auftrag] Ausgewaehlt: ${checked?.length || 0} von ${total?.length || 0}`);
}

function onSelectAllChange() {
    const checked = elements.chkSelectAll?.checked;
    const checkboxes = elements.lstMA_Plan?.querySelectorAll('.ma-checkbox:not(:disabled)');
    checkboxes?.forEach(cb => cb.checked = checked);
    updateAuswahlStatistik();
}

function clearFormData() {
    currentVAID = null;
    currentVADatumID = null;

    if (elements.cboVADatum) elements.cboVADatum.innerHTML = '<option value="">-- Datum --</option>';
    if (elements.lstZeiten) elements.lstZeiten.innerHTML = '';
    if (elements.lstMA_Plan) elements.lstMA_Plan.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#999;">Bitte Auftrag waehlen</td></tr>';
    if (elements.iGes_MA) elements.iGes_MA.textContent = 'Ist / Soll: 0 / 0';

    attachments = [];
    updateAttachmentList();
}

/**
 * VBA Bridge Aufruf
 */
async function callVBABridge(action, params) {
    // WebView2 Bridge verfuegbar?
    if (window.chrome?.webview?.hostObjects?.vbaBridge) {
        try {
            const result = await window.chrome.webview.hostObjects.vbaBridge.execute(action, JSON.stringify(params));
            return JSON.parse(result);
        } catch (e) {
            console.warn('[MA_Serien_eMail_Auftrag] WebView2 Bridge Fehler:', e);
        }
    }

    // REST API Fallback
    try {
        const resp = await fetch(`${SERIEN_EMAIL_VBA_BRIDGE}/execute`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action, params })
        });
        return await resp.json();
    } catch (e) {
        console.warn('[MA_Serien_eMail_Auftrag] VBA Bridge REST Fehler:', e);
        throw e;
    }
}

// ============================================================
// INITIALISIERUNG
// ============================================================

document.addEventListener('DOMContentLoaded', init);
