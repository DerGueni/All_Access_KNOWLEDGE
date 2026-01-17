/**
 * global-handlers.js
 * Globale Button-Handler für alle HTML-Formulare
 * Löst Inkonsistenzen zwischen HTML-onclick und Logic.js
 */

// ============ NAVIGATION (CRUD) ============

/**
 * Navigiert zum ersten Datensatz
 */
function navFirst() {
    if (window.appState && typeof window.appState.gotoRecord === 'function') {
        window.appState.gotoRecord(0);
    } else {
        console.warn('[Global] navFirst: appState.gotoRecord nicht verfügbar');
    }
}

/**
 * Navigiert zum vorherigen Datensatz
 */
function navPrev() {
    if (window.appState && typeof window.appState.gotoRecord === 'function') {
        const newIndex = (window.appState.currentIndex || 0) - 1;
        window.appState.gotoRecord(newIndex);
    } else {
        console.warn('[Global] navPrev: appState.gotoRecord nicht verfügbar');
    }
}

/**
 * Navigiert zum nächsten Datensatz
 */
function navNext() {
    if (window.appState && typeof window.appState.gotoRecord === 'function') {
        const newIndex = (window.appState.currentIndex || 0) + 1;
        window.appState.gotoRecord(newIndex);
    } else {
        console.warn('[Global] navNext: appState.gotoRecord nicht verfügbar');
    }
}

/**
 * Navigiert zum letzten Datensatz
 */
function navLast() {
    if (window.appState && typeof window.appState.gotoRecord === 'function') {
        const lastIndex = (window.appState.records || []).length - 1;
        window.appState.gotoRecord(lastIndex);
    } else {
        console.warn('[Global] navLast: appState.gotoRecord nicht verfügbar');
    }
}

/**
 * Erstellt einen neuen Datensatz
 */
function newRecord() {
    if (window.appState && typeof window.appState.newRecord === 'function') {
        window.appState.newRecord();
    } else {
        console.warn('[Global] newRecord: appState.newRecord nicht verfügbar');
    }
}

/**
 * Speichert den aktuellen Datensatz
 */
function saveRecord() {
    if (window.appState && typeof window.appState.saveRecord === 'function') {
        window.appState.saveRecord();
    } else {
        console.warn('[Global] saveRecord: appState.saveRecord nicht verfügbar');
    }
}

/**
 * Löscht den aktuellen Datensatz
 */
function deleteRecord() {
    if (window.appState && typeof window.appState.deleteRecord === 'function') {
        window.appState.deleteRecord();
    } else {
        console.warn('[Global] deleteRecord: appState.deleteRecord nicht verfügbar');
    }
}

// ============ FORMULAR-ÜBERGREIFENDE NAVIGATION ============

/**
 * Formular-Mapping für openMenu()
 */
const FORM_MAP = {
    'dienstplan': 'frm_N_DP_Dienstplan_MA',
    'planung': 'frm_VA_Planungsuebersicht',
    'auftrag': 'frm_N_VA_Auftragstamm_V2',
    'mitarbeiter': 'frm_N_MA_Mitarbeiterstamm_V2',
    'kunden': 'frm_N_KD_Kundenstamm_V2',
    'objekte': 'frm_OB_Objekt',
    'mail': 'frm_MA_Serien_eMail_Auftrag',
    'excel': 'frm_MA_Zeitkonten',
    'zeitkonten': 'frm_MA_Zeitkonten',
    'abwesenheit': 'frm_MA_Abwesenheit',
    'ausweis': 'frm_N_Dienstausweis',
    'stunden': 'frm_N_Stundenauswertung',
    'lohn': 'frm_N_Lohnabrechnungen_V2',
    'bewerber': 'frm_N_MA_Bewerber_Verarbeitung',
    'schnellauswahl': 'frm_N_MA_VA_Schnellauswahl',
    // Deutsche Varianten (fuer Kompatibilitaet mit alten onclick-Attributen)
    'Dienstplanuebersicht': 'frm_N_DP_Dienstplan_MA',
    'Dienstplanübersicht': 'frm_N_DP_Dienstplan_MA',
    'Planungsuebersicht': 'frm_VA_Planungsuebersicht',
    'Planungsübersicht': 'frm_VA_Planungsuebersicht',
    'Mitarbeiterverwaltung': 'frm_N_MA_Mitarbeiterstamm_V2',
    'OffeneMailAnfragen': 'frm_MA_Serien_eMail_Auftrag',
    'ExcelZeitkonten': 'frm_MA_Zeitkonten',
    'Zeitkonten': 'frm_MA_Zeitkonten',
    'Abwesenheitsplanung': 'frm_MA_Abwesenheit',
    'Dienstausweis': 'frm_N_Dienstausweis',
    'Stundenabgleich': 'frm_N_Stundenauswertung',
    'Kundenverwaltung': 'frm_N_KD_Kundenstamm_V2',
    'Verrechnungssaetze': 'frm_KD_Verrechnungssaetze',
    'SubRechnungen': 'frm_N_SubRechnungen',
    'EMail': 'frm_MA_Serien_eMail_Auftrag',
    'Menu2': 'frm_Menuefuehrung1',
    'DatenbankWechseln': 'frm_DBWechsel'
};

/**
 * Öffnet ein anderes Formular über die Sidebar/Navigation
 * @param {string} target - Ziel-Formular (Key aus FORM_MAP)
 * @param {number|null} id - Optionale ID für Datensatz
 */
function openMenu(target, id = null) {
    const formName = FORM_MAP[target];

    if (!formName) {
        console.error(`[Global] openMenu: Unbekanntes Ziel "${target}"`);
        return;
    }

    console.log(`[Global] openMenu: Navigiere zu ${formName}`, id ? `mit ID ${id}` : '');

    // Prüfe ob Bridge verfügbar (WebView2)
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('navigate', {
            form: formName,
            id: id
        });
    }
    // Fallback: Shell-Navigation (iframe)
    else if (window.parent !== window) {
        window.parent.postMessage({
            type: 'NAVIGATE',
            form: formName,
            id: id
        }, '*');
    }
    // Fallback: Direkt laden (standalone)
    else {
        const formPath = formName.includes('_V2') ?
            `../${formName.replace('frm_N_', '').replace('frm_', '').toLowerCase()}verwaltung/${formName}.html` :
            `../${formName}.html`;

        window.location.href = formPath + (id ? `?id=${id}` : '');
    }
}

// ============ TAB-HANDLING ============

/**
 * Wechselt zwischen Tabs (Standard-Implementierung)
 * @param {string} tabId - ID des anzuzeigenden Tabs (ohne 'tab-' Präfix)
 * @param {HTMLElement} btnElement - Geklickter Tab-Button
 */
function showTab(tabId, btnElement) {
    console.log('[Global] showTab:', tabId);

    // Alle Tab-Inhalte verstecken
    document.querySelectorAll('.tab-content, .tab-body').forEach(function(tab) {
        tab.style.display = 'none';
        tab.classList.remove('active');
    });

    // Alle Tab-Buttons deaktivieren
    document.querySelectorAll('.tab-btn').forEach(function(btn) {
        btn.classList.remove('active');
    });

    // Gewählten Tab anzeigen
    const selectedTab = document.getElementById('tab-' + tabId);
    if (selectedTab) {
        selectedTab.style.display = 'block';
        selectedTab.classList.add('active');
    } else {
        console.warn(`[Global] showTab: Tab mit ID "tab-${tabId}" nicht gefunden`);
    }

    // Button aktivieren
    if (btnElement) {
        btnElement.classList.add('active');
    }

    // Tab-spezifische Logik ausführen (falls vorhanden)
    if (window.appState && typeof window.appState.onTabChange === 'function') {
        window.appState.onTabChange(tabId);
    }
}

/**
 * Alternative Tab-Funktion (für frm_OB_Objekt)
 * @param {string} tabId - ID des anzuzeigenden Tabs
 * @param {HTMLElement} btnElement - Geklickter Tab-Button
 */
function switchTab(tabId, btnElement) {
    console.log('[Global] switchTab:', tabId);

    // Alle Tab-Inhalte verstecken
    document.querySelectorAll('[id^="tab"]').forEach(function(tab) {
        if (tab.id.startsWith('tab')) {
            tab.style.display = 'none';
            tab.classList.remove('active');
        }
    });

    // Alle Tab-Buttons deaktivieren
    document.querySelectorAll('.tab-btn').forEach(function(btn) {
        btn.classList.remove('active');
    });

    // Gewählten Tab anzeigen
    const selectedTab = document.getElementById(tabId);
    if (selectedTab) {
        selectedTab.style.display = 'block';
        selectedTab.classList.add('active');
    }

    // Button aktivieren
    if (btnElement) {
        btnElement.classList.add('active');
    }
}

// ============ FORMULAR-SPEZIFISCHE ALIASE ============

// Mitarbeiterstamm
function newMA() { newRecord(); }
function deleteMA() { deleteRecord(); }
/**
 * Zeigt Adressenformular
 */
function showAdressen() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    if (maId) {
        window.open('frm_MA_Adressen.html?ma_id=' + maId, '_blank', 'width=600,height=500');
    } else {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
    }
}
function showZeitkonto() {
    if (window.appState && window.appState.currentRecord) {
        openMenu('zeitkonten', window.appState.currentRecord.MA_ID);
    }
}
/**
 * Zeigt Zeitkonto Festanstellung
 */
function showZKFest() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    if (maId) {
        window.open('frm_MA_Zeitkonten.html?ma_id=' + maId + '&typ=fest', '_blank');
    } else {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
    }
}

/**
 * Zeigt Zeitkonto Minijob
 */
function showZKMini() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    if (maId) {
        window.open('frm_MA_Zeitkonten.html?ma_id=' + maId + '&typ=mini', '_blank');
    } else {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
    }
}

/**
 * Sendet Einsaetze per E-Mail
 */
async function sendEinsaetze() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    var email = window.appState?.currentRecord?.Email || document.getElementById('Email')?.value;

    if (!maId) {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
        return;
    }

    if (!email) {
        showToast('Keine E-Mail-Adresse vorhanden', 'warning');
        return;
    }

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('sendEinsaetze', { ma_id: maId, email: email });
            if (result.success) {
                showToast('Einsaetze wurden gesendet', 'success');
            }
        } else {
            // Fallback: mailto
            var subject = encodeURIComponent('Ihre Einsaetze');
            var body = encodeURIComponent('Anbei finden Sie Ihre aktuellen Einsaetze.');
            window.location.href = 'mailto:' + email + '?subject=' + subject + '&body=' + body;
        }
    } catch (error) {
        showToast('Fehler beim Senden', 'error');
    }
}

// Kundenstamm
function newKunde() { newRecord(); }
function deleteKunde() { deleteRecord(); }
/**
 * Zeigt Verrechnungssaetze des Kunden
 */
function showVerrechnungssaetze() {
    var kdId = window.appState?.currentRecord?.kun_Id || window.appState?.currentRecord?.ID;
    if (kdId) {
        window.open('frm_KD_Verrechnungssaetze.html?kd_id=' + kdId, '_blank');
    } else {
        showToast('Bitte zuerst einen Kunden auswaehlen', 'warning');
    }
}

/**
 * Zeigt Umsatzauswertung des Kunden
 */
function showUmsatzauswertung() {
    var kdId = window.appState?.currentRecord?.kun_Id || window.appState?.currentRecord?.ID;
    if (kdId) {
        window.open('frm_KD_Umsatzauswertung.html?kd_id=' + kdId, '_blank');
    } else {
        showToast('Bitte zuerst einen Kunden auswaehlen', 'warning');
    }
}

// Auftragstamm
function neuerAuftrag() { newRecord(); }
function auftragLoeschen() { deleteRecord(); }
function auftragKopieren() {
    if (window.appState && typeof window.appState.kopierenAuftrag === 'function') {
        window.appState.kopierenAuftrag();
    } else {
        console.warn('[Global] auftragKopieren: Funktion nicht verfügbar');
    }
}
/**
 * Zeigt Rueckmelde-Statistik
 */
function showRueckmeldeStatistik() {
    var vaId = window.appState?.currentRecord?.VA_ID || window.appState?.currentRecord?.ID;
    if (vaId) {
        window.open('frm_Rueckmeldestatistik.html?va_id=' + vaId, '_blank', 'width=800,height=600');
    } else {
        showToast('Bitte zuerst einen Auftrag auswaehlen', 'warning');
    }
}

/**
 * Zeigt Synchronisierungsfehler
 */
async function showSyncfehler() {
    var vaId = window.appState?.currentRecord?.VA_ID || window.appState?.currentRecord?.ID;

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('getSyncErrors', { va_id: vaId });

            if (result.data && result.data.length > 0) {
                showToast(result.data.length + ' Synchronisierungsfehler gefunden', 'warning');
                window.open('zfrm_SyncError.html?va_id=' + (vaId || ''), '_blank', 'width=800,height=600');
            } else {
                showToast('Keine Synchronisierungsfehler gefunden', 'success');
            }
        } else {
            window.open('zfrm_SyncError.html?va_id=' + (vaId || ''), '_blank', 'width=800,height=600');
        }
    } catch (error) {
        showToast('Fehler beim Pruefen', 'error');
    }
}
function aktualisieren() {
    if (window.appState && typeof window.appState.requeryAll === 'function') {
        window.appState.requeryAll();
    } else {
        window.location.reload();
    }
}
function openMitarbeiterauswahl() {
    if (window.appState && typeof window.appState.openMitarbeiterauswahl === 'function') {
        window.appState.openMitarbeiterauswahl();
    } else {
        openMenu('schnellauswahl', window.appState?.currentRecord?.VA_ID);
    }
}
/**
 * Zeigt Positionen/Positionsliste
 */
function showPositionen() {
    var vaId = window.appState?.currentRecord?.VA_ID || window.appState?.currentRecord?.ID;
    var objektId = window.appState?.currentRecord?.Objekt_ID;

    if (objektId) {
        window.open('frm_OB_Objekt.html?id=' + objektId, '_blank');
    } else if (vaId) {
        window.open('frm_OB_Objekt.html?va_id=' + vaId, '_blank');
    } else {
        showToast('Bitte zuerst einen Auftrag auswaehlen', 'warning');
    }
}
function sendEinsatzlisteMA() {
    if (window.appState && typeof window.appState.sendeEinsatzliste === 'function') {
        window.appState.sendeEinsatzliste('MA');
    }
}
function sendEinsatzlisteBOS() {
    if (window.appState && typeof window.appState.sendeEinsatzliste === 'function') {
        window.appState.sendeEinsatzliste('BOS');
    }
}
function sendEinsatzlisteSUB() {
    if (window.appState && typeof window.appState.sendeEinsatzliste === 'function') {
        window.appState.sendeEinsatzliste('SUB');
    }
}
function showNamenslisteESS() {
    if (window.appState && typeof window.appState.druckeNamenlisteESS === 'function') {
        window.appState.druckeNamenlisteESS();
    }
}
function druckEinsatzliste() {
    if (window.appState && typeof window.appState.druckeEinsatzliste === 'function') {
        window.appState.druckeEinsatzliste();
    }
}
function prevDay() {
    if (window.appState && typeof window.appState.navigateDay === 'function') {
        window.appState.navigateDay(-1);
    }
}
function nextDay() {
    if (window.appState && typeof window.appState.navigateDay === 'function') {
        window.appState.navigateDay(1);
    }
}

// Objektstamm
function goFirst() { navFirst(); }
function goPrev() { navPrev(); }
function goNext() { navNext(); }
function goLast() { navLast(); }
function closeForm() {
    window.close();
}
/**
 * Oeffnet Auftragsliste/Auftragsverwaltung
 */
function openAuftraege() {
    var objektId = window.appState?.currentRecord?.Objekt_ID || window.appState?.currentRecord?.ID;
    if (objektId) {
        window.open('frm_va_Auftragstamm.html?objekt_id=' + objektId, '_blank');
    } else {
        window.open('frm_va_Auftragstamm.html', '_blank');
    }
}

/**
 * Oeffnet Positionsliste des Objekts
 */
function openPositionen() {
    var objektId = window.appState?.currentRecord?.Objekt_ID || window.appState?.currentRecord?.ID;
    if (objektId) {
        // Zur Positionen-Tab wechseln
        var tabPositionen = document.getElementById('tab-positionen');
        if (tabPositionen) {
            showTab('positionen', document.querySelector('[data-tab="positionen"]'));
        } else {
            showToast('Positionen-Tab nicht gefunden', 'warning');
        }
    } else {
        showToast('Bitte zuerst ein Objekt auswaehlen', 'warning');
    }
}

// ============ TAB-CONTENT BUTTONS ============

/**
 * Oeffnet Google Maps mit der aktuellen Adresse
 */
function openKoordinaten() {
    const adresse = document.getElementById('Strasse')?.value || document.getElementById('Adresse')?.value || '';
    const nr = document.getElementById('Nr')?.value || document.getElementById('HausNr')?.value || '';
    const plz = document.getElementById('PLZ')?.value || '';
    const ort = document.getElementById('Ort')?.value || '';

    if (!adresse && !ort) {
        showToast('Keine Adresse vorhanden', 'warning');
        return;
    }

    const query = encodeURIComponent([adresse, nr, plz, ort].filter(Boolean).join(', '));
    window.open('https://www.google.com/maps/search/' + query, '_blank');
}

/**
 * Laedt Einsaetze fuer den ausgewaehlten Monat
 */
async function loadEinsatzMonat() {
    const maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    const monatSelect = document.getElementById('cboMonat') || document.getElementById('monat');
    const jahrSelect = document.getElementById('cboJahr') || document.getElementById('jahr');

    if (!maId) {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
        return;
    }

    const monat = monatSelect?.value || new Date().getMonth() + 1;
    const jahr = jahrSelect?.value || new Date().getFullYear();

    try {
        if (typeof Bridge !== 'undefined') {
            const result = await Bridge.execute('getEinsaetzeMonat', { ma_id: maId, monat: monat, jahr: jahr });
            if (result.data) {
                renderEinsatzTabelle(result.data, 'einsatzMonatTbody');
                showToast(result.data.length + ' Einsaetze geladen', 'success');
            }
        } else {
            showToast('Bridge nicht verfuegbar', 'warning');
        }
    } catch (error) {
        console.error('[Global] loadEinsatzMonat Fehler:', error);
        showToast('Fehler beim Laden der Einsaetze', 'error');
    }
}
function exportXLEinsatz() {
    exportExcel(null, 'Einsatzuebersicht');
}
/**
 * Laedt Jahresuebersicht der Einsaetze
 */
async function loadEinsatzJahr() {
    const maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    const jahrSelect = document.getElementById('cboJahrUeber') || document.getElementById('jahrUeber');

    if (!maId) {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
        return;
    }

    const jahr = jahrSelect?.value || new Date().getFullYear();

    try {
        if (typeof Bridge !== 'undefined') {
            const result = await Bridge.execute('getEinsaetzeJahr', { ma_id: maId, jahr: jahr });
            if (result.data) {
                renderJahresTabelle(result.data, 'einsatzJahrTbody');
                showToast('Jahresuebersicht geladen', 'success');
            }
        } else {
            showToast('Bridge nicht verfuegbar', 'warning');
        }
    } catch (error) {
        console.error('[Global] loadEinsatzJahr Fehler:', error);
        showToast('Fehler beim Laden der Jahresuebersicht', 'error');
    }
}
function exportXLJahr() {
    exportExcel(null, 'Jahresuebersicht');
}

/**
 * Berechnet Stunden zwischen Start und Ende
 */
function calcStunden() {
    const vonField = document.getElementById('VA_Start') || document.getElementById('Von') || document.getElementById('Schicht_Von');
    const bisField = document.getElementById('VA_Ende') || document.getElementById('Bis') || document.getElementById('Schicht_Bis');
    const pauseField = document.getElementById('Pause') || document.getElementById('Pausenzeit');
    const stdField = document.getElementById('Std') || document.getElementById('Stunden') || document.getElementById('calcStunden');

    if (!vonField || !bisField) {
        console.warn('[Global] calcStunden: Von/Bis Felder nicht gefunden');
        return;
    }

    const von = vonField.value;
    const bis = bisField.value;

    if (!von || !bis) {
        showToast('Bitte Start- und Endzeit eingeben', 'warning');
        return;
    }

    var vonParts = von.split(':');
    var bisParts = bis.split(':');
    var hVon = parseInt(vonParts[0]) || 0;
    var mVon = parseInt(vonParts[1]) || 0;
    var hBis = parseInt(bisParts[0]) || 0;
    var mBis = parseInt(bisParts[1]) || 0;
    var pause = pauseField ? parseFloat(pauseField.value || 0) : 0;

    var minuten = (hBis * 60 + mBis) - (hVon * 60 + mVon);
    if (minuten < 0) minuten += 24 * 60; // Ueber Mitternacht

    // Pause abziehen (in Minuten)
    minuten -= pause;

    var stunden = (minuten / 60).toFixed(2);

    if (stdField) {
        stdField.value = stunden;
    }

    showToast('Berechnete Stunden: ' + stunden, 'info');
    return parseFloat(stunden);
}

/**
 * Setzt Dienstplan-Datum auf heute
 */
function dpToday() {
    var datumField = document.getElementById('dpDatum') || document.getElementById('Datum') || document.getElementById('cboVADatum');
    if (datumField) {
        var heute = new Date().toISOString().split('T')[0];
        datumField.value = heute;
        datumField.dispatchEvent(new Event('change'));
        showToast('Datum auf heute gesetzt', 'info');
    }
}
function printDienstplan() {
    printDienstplanGrid();
}
/**
 * Sendet Dienstplan per E-Mail
 */
async function sendDienstplan() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    var email = window.appState?.currentRecord?.Email || document.getElementById('Email')?.value;

    if (!maId) {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
        return;
    }

    if (!email) {
        showToast('Keine E-Mail-Adresse vorhanden', 'warning');
        return;
    }

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('sendDienstplan', { ma_id: maId, email: email });
            if (result.success) {
                showToast('Dienstplan wurde gesendet', 'success');
            } else {
                throw new Error(result.error || 'Unbekannter Fehler');
            }
        } else {
            // Fallback: mailto
            var subject = encodeURIComponent('Ihr Dienstplan');
            var body = encodeURIComponent('Anbei finden Sie Ihren aktuellen Dienstplan.');
            window.location.href = 'mailto:' + email + '?subject=' + subject + '&body=' + body;
        }
    } catch (error) {
        console.error('[Global] sendDienstplan Fehler:', error);
        showToast('Fehler beim Senden des Dienstplans', 'error');
    }
}

/**
 * Fuegt neue Nicht-Verfuegbarkeit hinzu
 */
async function addNichtVerfuegbar() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    if (!maId) {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
        return;
    }

    // Modal oeffnen falls vorhanden
    var modal = document.getElementById('modalNichtVerfuegbar');
    if (modal) {
        modal.style.display = 'block';
        modal.classList.add('active');
        var hiddenMA = modal.querySelector('input[name="ma_id"]');
        if (hiddenMA) hiddenMA.value = maId;
    } else {
        // Fallback: Prompt-Dialog
        var vonDat = prompt('Von Datum (TT.MM.JJJJ):');
        var bisDat = prompt('Bis Datum (TT.MM.JJJJ):');
        var grund = prompt('Grund:');

        if (vonDat && grund) {
            try {
                if (typeof Bridge !== 'undefined') {
                    await Bridge.execute('createNichtVerfuegbar', {
                        ma_id: maId,
                        von_dat: vonDat,
                        bis_dat: bisDat || vonDat,
                        grund: grund
                    });
                    showToast('Nicht-Verfuegbarkeit hinzugefuegt', 'success');
                    if (typeof refreshData === 'function') refreshData();
                }
            } catch (error) {
                showToast('Fehler: ' + error.message, 'error');
            }
        }
    }
}

/**
 * Loescht ausgewaehlte Nicht-Verfuegbarkeit
 */
async function deleteNichtVerfuegbar() {
    var selectedRow = document.querySelector('#tblNichtVerfuegbar tr.selected, .nv-item.selected');
    if (!selectedRow) {
        showToast('Bitte zuerst einen Eintrag auswaehlen', 'warning');
        return;
    }

    var nvId = selectedRow.dataset.id || selectedRow.dataset.nvId;
    if (!nvId) {
        showToast('Keine ID gefunden', 'error');
        return;
    }

    if (!confirm('Eintrag wirklich loeschen?')) return;

    try {
        if (typeof Bridge !== 'undefined') {
            await Bridge.execute('deleteNichtVerfuegbar', { id: nvId });
            showToast('Eintrag geloescht', 'success');
            selectedRow.remove();
        }
    } catch (error) {
        showToast('Fehler beim Loeschen: ' + error.message, 'error');
    }
}
function exportXLNVerfueg() {
    exportExcel(null, 'NichtVerfuegbar');
}
/**
 * Fuegt neue Dienstkleidungs-Ausgabe hinzu
 */
async function addKleidung() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    if (!maId) {
        showToast('Bitte zuerst einen Mitarbeiter auswaehlen', 'warning');
        return;
    }

    var modal = document.getElementById('modalKleidung');
    if (modal) {
        modal.style.display = 'block';
        modal.classList.add('active');
        var hiddenMA = modal.querySelector('input[name="ma_id"]');
        if (hiddenMA) hiddenMA.value = maId;
    } else {
        // Fallback
        var artikel = prompt('Artikel (z.B. Jacke, Hose):');
        var groesse = prompt('Groesse:');
        var anzahl = prompt('Anzahl:', '1');

        if (artikel) {
            try {
                if (typeof Bridge !== 'undefined') {
                    await Bridge.execute('createKleidung', {
                        ma_id: maId,
                        artikel: artikel,
                        groesse: groesse,
                        anzahl: parseInt(anzahl) || 1
                    });
                    showToast('Dienstkleidung hinzugefuegt', 'success');
                    if (typeof refreshData === 'function') refreshData();
                }
            } catch (error) {
                showToast('Fehler: ' + error.message, 'error');
            }
        }
    }
}

/**
 * Erstellt Kleidungsbericht
 */
async function reportKleidung() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('getKleidungReport', { ma_id: maId || null });
            if (result.data) {
                exportDataToExcel(result.data, 'Kleidungsbericht', ['MA_ID', 'Nachname', 'Vorname', 'Artikel', 'Groesse', 'Anzahl', 'AusgabeDatum', 'RueckgabeDatum']);
                showToast('Bericht erstellt', 'success');
            }
        } else {
            showToast('Bridge nicht verfuegbar', 'warning');
        }
    } catch (error) {
        showToast('Fehler beim Erstellen des Berichts', 'error');
    }
}

/**
 * Laedt Vordrucke-Liste
 */
async function loadVordrucke() {
    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('getVordruckeListe');
            if (result.data) {
                var container = document.getElementById('vordruckeListe');
                if (container) {
                    container.innerHTML = result.data.map(function(v) {
                        return '<div class="vordruck-item" data-id="' + v.ID + '">' +
                            '<span>' + v.Bezeichnung + '</span>' +
                            '<button onclick="selectVordruck(' + v.ID + ')">Auswaehlen</button>' +
                            '</div>';
                    }).join('');
                }
            }
        }
    } catch (error) {
        console.error('[Global] loadVordrucke Fehler:', error);
    }
}

/**
 * Oeffnet Dateiauswahl fuer Vorlage
 */
function selectVorlageDatei() {
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = '.doc,.docx,.pdf,.odt';
    input.onchange = function(e) {
        var file = e.target.files[0];
        if (file) {
            var pfadField = document.getElementById('vorlagePfad');
            if (pfadField) pfadField.value = file.name;
            showToast('Vorlage ausgewaehlt: ' + file.name, 'success');
        }
    };
    input.click();
}
function exportXLVordrucke() {
    exportExcel(null, 'Vordrucke');
}
/**
 * Erstellt einen Brief aus Vorlage
 */
async function createBrief() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;
    var vorlageId = document.getElementById('cboVorlage')?.value;

    if (!vorlageId) {
        showToast('Bitte zuerst eine Vorlage auswaehlen', 'warning');
        return;
    }

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('createBrief', {
                ma_id: maId,
                vorlage_id: vorlageId
            });

            if (result.success && result.data?.filepath) {
                showToast('Brief erstellt', 'success');
                if (confirm('Brief in Word oeffnen?')) {
                    window.open(result.data.filepath, '_blank');
                }
            }
        } else {
            showToast('Bridge nicht verfuegbar - verwende Fallback', 'info');
            window.open('/api/brief/vorlage/' + vorlageId + '?ma_id=' + (maId || ''), '_blank');
        }
    } catch (error) {
        showToast('Fehler beim Erstellen des Briefs', 'error');
    }
}

/**
 * Oeffnet Word (wenn lokal verfuegbar)
 */
function openWord() {
    if (typeof Bridge !== 'undefined') {
        Bridge.execute('openWord').catch(function(err) {
            showToast('Word konnte nicht geoeffnet werden', 'warning');
        });
    } else {
        showToast('Diese Funktion ist nur mit WebView2-Bridge verfuegbar', 'info');
    }
}

/**
 * Laedt Ueberhangstunden
 */
async function loadUeberhang() {
    var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('getUeberhangStunden', { ma_id: maId });
            if (result.data) {
                var container = document.getElementById('ueberhangContainer');
                if (container) {
                    container.innerHTML = '<div class="ueberhang-summary">' +
                        '<div>Soll-Stunden: ' + (result.data.soll || 0) + '</div>' +
                        '<div>Ist-Stunden: ' + (result.data.ist || 0) + '</div>' +
                        '<div>Differenz: ' + (result.data.differenz || 0) + '</div>' +
                        '</div>';
                }
                showToast('Ueberhang geladen', 'success');
            }
        }
    } catch (error) {
        showToast('Fehler beim Laden des Ueberhangs', 'error');
    }
}
function exportXLUeberhang() {
    exportExcel(null, 'Ueberhangstunden');
}
/**
 * Oeffnet Google Maps mit aktueller Adresse
 */
function openMaps() {
    var adresse = document.getElementById('Strasse')?.value || document.getElementById('Adresse')?.value || '';
    var nr = document.getElementById('Nr')?.value || document.getElementById('HausNr')?.value || '';
    var plz = document.getElementById('PLZ')?.value || '';
    var ort = document.getElementById('Ort')?.value || '';

    if (!adresse && !ort) {
        showToast('Keine Adresse vorhanden', 'warning');
        return;
    }

    var query = encodeURIComponent([adresse, nr, plz, ort].filter(Boolean).join(', '));
    window.open('https://www.google.com/maps/search/' + query, '_blank');
}

/**
 * Berechnet Route zwischen zwei Adressen
 */
function calcRoute() {
    var vonAdresse = document.getElementById('vonAdresse')?.value || '';
    var nachAdresse = document.getElementById('nachAdresse')?.value;

    if (!nachAdresse) {
        var parts = [
            document.getElementById('Strasse')?.value,
            document.getElementById('Nr')?.value,
            document.getElementById('PLZ')?.value,
            document.getElementById('Ort')?.value
        ];
        nachAdresse = parts.filter(Boolean).join(', ');
    }

    if (!nachAdresse) {
        showToast('Keine Zieladresse vorhanden', 'warning');
        return;
    }

    var von = vonAdresse ? encodeURIComponent(vonAdresse) : '';
    var nach = encodeURIComponent(nachAdresse);

    if (von) {
        window.open('https://www.google.com/maps/dir/' + von + '/' + nach, '_blank');
    } else {
        window.open('https://www.google.com/maps/dir//' + nach, '_blank');
    }
}

/**
 * Ermittelt Koordinaten fuer aktuelle Adresse (Geocoding via OpenStreetMap)
 */
async function geocodeAddress() {
    var adresse = document.getElementById('Strasse')?.value || '';
    var nr = document.getElementById('Nr')?.value || '';
    var plz = document.getElementById('PLZ')?.value || '';
    var ort = document.getElementById('Ort')?.value || '';

    if (!ort && !adresse) {
        showToast('Keine Adresse vorhanden', 'warning');
        return;
    }

    var fullAddress = [adresse, nr, plz, ort].filter(Boolean).join(', ');
    showToast('Ermittle Koordinaten...', 'info');

    try {
        // Nominatim OpenStreetMap API (kostenlos)
        var url = 'https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(fullAddress);
        var response = await fetch(url, { headers: { 'User-Agent': 'ConsysApp/1.0' } });
        var data = await response.json();

        if (data && data.length > 0) {
            var lat = data[0].lat;
            var lon = data[0].lon;

            // In Felder eintragen
            var latField = document.getElementById('Latitude') || document.getElementById('lat');
            var lonField = document.getElementById('Longitude') || document.getElementById('lon');
            if (latField) latField.value = lat;
            if (lonField) lonField.value = lon;

            showToast('Koordinaten: ' + lat + ', ' + lon, 'success');
            return { lat: lat, lon: lon };
        } else {
            showToast('Keine Koordinaten gefunden', 'warning');
            return null;
        }
    } catch (error) {
        console.error('[Global] geocodeAddress Fehler:', error);
        showToast('Fehler bei Koordinatenermittlung', 'error');
        return null;
    }
}

/**
 * Oeffnet Rechnungsformular
 */
function openRechnung() {
    var rechnungId = document.getElementById('Rech_NR')?.value ||
        window.appState?.currentRecord?.Rech_NR;
    var vaId = window.appState?.currentRecord?.VA_ID || window.appState?.currentRecord?.ID;

    if (rechnungId) {
        window.open('frm_Rechnung.html?id=' + rechnungId, '_blank');
    } else if (vaId) {
        window.open('frm_Rechnung.html?va_id=' + vaId, '_blank');
    } else {
        showToast('Keine Rechnung vorhanden', 'warning');
    }
}

/**
 * Oeffnet Dateiauswahl fuer Foto
 */
function selectPhoto() {
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = async function(e) {
        var file = e.target.files[0];
        if (!file) return;

        var maId = window.appState?.currentRecord?.MA_ID || window.appState?.currentRecord?.ID;

        // Preview anzeigen
        var fotoContainer = document.getElementById('fotoContainer') || document.getElementById('foto');
        if (fotoContainer) {
            var reader = new FileReader();
            reader.onload = function(ev) {
                fotoContainer.innerHTML = '<img src="' + ev.target.result + '" alt="Foto" style="max-width:100%;max-height:100%;">';
            };
            reader.readAsDataURL(file);
        }

        // Upload via Bridge
        if (typeof Bridge !== 'undefined' && maId) {
            try {
                var base64 = await fileToBase64(file);
                await Bridge.execute('uploadFoto', {
                    ma_id: maId,
                    filename: file.name,
                    data: base64
                });
                showToast('Foto hochgeladen', 'success');
            } catch (error) {
                showToast('Fehler beim Upload: ' + error.message, 'error');
            }
        }
    };
    input.click();
}

/**
 * Hilfsfunktion: File zu Base64 konvertieren
 */
function fileToBase64(file) {
    return new Promise(function(resolve, reject) {
        var reader = new FileReader();
        reader.onload = function() { resolve(reader.result); };
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

// Kundenstamm Tab-Content
/**
 * Laedt Auftraege fuer den aktuellen Kunden
 */
async function loadKdAuftraege() {
    var kdId = window.appState?.currentRecord?.kun_Id || window.appState?.currentRecord?.ID;
    if (!kdId) {
        showToast('Bitte zuerst einen Kunden auswaehlen', 'warning');
        return;
    }

    try {
        if (typeof Bridge !== 'undefined') {
            var result = await Bridge.execute('getKundenAuftraege', { kd_id: kdId });
            if (result.data) {
                var tbody = document.getElementById('kdAuftrageTbody') || document.querySelector('#tab-auftraege tbody');
                if (tbody) {
                    tbody.innerHTML = result.data.map(function(a) {
                        return '<tr data-id="' + a.VA_ID + '">' +
                            '<td>' + formatDateDE(a.Datum) + '</td>' +
                            '<td>' + (a.Auftrag || '') + '</td>' +
                            '<td>' + (a.Objekt || '') + '</td>' +
                            '<td>' + (a.Status || '') + '</td>' +
                            '</tr>';
                    }).join('');
                }
                showToast(result.data.length + ' Auftraege geladen', 'success');
            }
        }
    } catch (error) {
        showToast('Fehler beim Laden der Auftraege', 'error');
    }
}
function exportRchPDF() {
    showToast('Rechnung PDF - Bitte "Als PDF speichern" wählen', 'info');
    printTable('tab-rechnungen');
}
function exportRchPosPDF() {
    showToast('Positionen PDF - Bitte "Als PDF speichern" wählen', 'info');
    printTable('tab-positionen');
}
function exportEinsPDF() {
    showToast('Einsätze PDF - Bitte "Als PDF speichern" wählen', 'info');
    printTable('tab-einsaetze');
}
/**
 * Erstellt neues Angebot
 */
function newAngebot() {
    var kdId = window.appState?.currentRecord?.kun_Id || window.appState?.currentRecord?.ID;
    if (kdId) {
        window.open('frm_Angebot.html?kd_id=' + kdId, '_blank');
    } else {
        window.open('frm_Angebot.html', '_blank');
    }
}

/**
 * Fuegt Anhang hinzu
 */
function addAttachment() {
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = '*/*';
    input.onchange = async function(e) {
        var file = e.target.files[0];
        if (!file) return;

        var recordId = window.appState?.currentRecord?.ID || window.appState?.currentRecord?.VA_ID;
        var tabellenNr = document.getElementById('TabellenNr')?.value || 42;

        showToast('Lade ' + file.name + ' hoch...', 'info');

        if (typeof Bridge !== 'undefined' && recordId) {
            try {
                var base64 = await fileToBase64(file);
                await Bridge.execute('uploadAttachment', {
                    record_id: recordId,
                    tabellen_nr: tabellenNr,
                    filename: file.name,
                    data: base64
                });
                showToast('Datei hochgeladen', 'success');
                if (typeof refreshData === 'function') refreshData();
            } catch (error) {
                showToast('Fehler beim Upload: ' + error.message, 'error');
            }
        } else {
            showToast('Upload nicht verfuegbar', 'warning');
        }
    };
    input.click();
}

/**
 * Fuegt neuen Ansprechpartner hinzu
 */
async function addAnsprechpartner() {
    var kdId = window.appState?.currentRecord?.kun_Id || window.appState?.currentRecord?.ID;
    if (!kdId) {
        showToast('Bitte zuerst einen Kunden auswaehlen', 'warning');
        return;
    }

    var modal = document.getElementById('modalAnsprechpartner');
    if (modal) {
        modal.style.display = 'block';
        modal.classList.add('active');
        var hiddenKD = modal.querySelector('input[name="kd_id"]');
        if (hiddenKD) hiddenKD.value = kdId;
    } else {
        // Fallback
        var name = prompt('Name des Ansprechpartners:');
        var position = prompt('Position/Funktion:');
        var tel = prompt('Telefon:');
        var email = prompt('E-Mail:');

        if (name) {
            try {
                if (typeof Bridge !== 'undefined') {
                    await Bridge.execute('createAnsprechpartner', {
                        kd_id: kdId,
                        name: name,
                        position: position,
                        tel: tel,
                        email: email
                    });
                    showToast('Ansprechpartner hinzugefuegt', 'success');
                    if (typeof refreshData === 'function') refreshData();
                }
            } catch (error) {
                showToast('Fehler: ' + error.message, 'error');
            }
        }
    }
}

// Auftragstamm Tab-Content
function druckBWN() {
    printTable('bwn-container');
}
function openPDFKopf() {
    showToast('Rechnung PDF wird erstellt...', 'info');
    exportPDF();
}
function openPDFPos() {
    showToast('Berechnungsliste PDF wird erstellt...', 'info');
    printTable('tab-positionen');
}
/**
 * Springt zur Auftragsliste
 */
function goAuftraege() {
    var auftraegeTbody = document.querySelector('#tblAuftragsliste tbody, .auftraege-liste tbody');
    if (auftraegeTbody) {
        auftraegeTbody.scrollIntoView({ behavior: 'smooth' });
    }
    filterGo();
}

/**
 * Navigiert in der Auftragsliste zurueck (7 Tage)
 */
function prevAuftraege() {
    filterBack();
}

/**
 * Navigiert in der Auftragsliste vor (7 Tage)
 */
function nextAuftraege() {
    filterFwd();
}

// Objektstamm Tab-Content
/**
 * Erstellt neue Position
 */
async function newPosition() {
    var objektId = window.appState?.currentRecord?.Objekt_ID || window.appState?.currentRecord?.ID;
    if (!objektId) {
        showToast('Bitte zuerst ein Objekt auswaehlen', 'warning');
        return;
    }

    var modal = document.getElementById('modalPosition');
    if (modal) {
        modal.style.display = 'block';
        modal.classList.add('active');
        var hiddenObjekt = modal.querySelector('input[name="objekt_id"]');
        if (hiddenObjekt) hiddenObjekt.value = objektId;
    } else {
        // Fallback
        var bezeichnung = prompt('Positions-Bezeichnung:');
        var anzahl = prompt('Anzahl MA:', '1');

        if (bezeichnung) {
            try {
                if (typeof Bridge !== 'undefined') {
                    await Bridge.execute('createPosition', {
                        objekt_id: objektId,
                        bezeichnung: bezeichnung,
                        anzahl: parseInt(anzahl) || 1
                    });
                    showToast('Position hinzugefuegt', 'success');
                    if (typeof refreshData === 'function') refreshData();
                }
            } catch (error) {
                showToast('Fehler: ' + error.message, 'error');
            }
        }
    }
}

/**
 * Loescht ausgewaehlte Position
 */
async function deletePosition() {
    var selectedRow = document.querySelector('#tblPositionen tr.selected, .position-item.selected');
    if (!selectedRow) {
        showToast('Bitte zuerst eine Position auswaehlen', 'warning');
        return;
    }

    var posId = selectedRow.dataset.id || selectedRow.dataset.posId;
    if (!posId) {
        showToast('Keine ID gefunden', 'error');
        return;
    }

    if (!confirm('Position wirklich loeschen?')) return;

    try {
        if (typeof Bridge !== 'undefined') {
            await Bridge.execute('deletePosition', { id: posId });
            showToast('Position geloescht', 'success');
            selectedRow.remove();
        }
    } catch (error) {
        showToast('Fehler beim Loeschen: ' + error.message, 'error');
    }
}

/**
 * Loescht ausgewaehlten Anhang
 */
async function deleteAttachment() {
    var selectedRow = document.querySelector('#tblAttachments tr.selected, .attachment-item.selected');
    if (!selectedRow) {
        showToast('Bitte zuerst einen Anhang auswaehlen', 'warning');
        return;
    }

    var attachId = selectedRow.dataset.id || selectedRow.dataset.attachId;
    if (!attachId) {
        showToast('Keine ID gefunden', 'error');
        return;
    }

    if (!confirm('Anhang wirklich loeschen?')) return;

    try {
        if (typeof Bridge !== 'undefined') {
            await Bridge.execute('deleteAttachment', { id: attachId });
            showToast('Anhang geloescht', 'success');
            selectedRow.remove();
        }
    } catch (error) {
        showToast('Fehler beim Loeschen: ' + error.message, 'error');
    }
}

// ============ EXPORT / DRUCK FUNKTIONEN ============

/**
 * Zeigt eine Toast-Nachricht an
 * @param {string} message - Nachricht
 * @param {string} type - 'success', 'warning', 'error', 'info'
 */
function showToast(message, type) {
    // Prüfe ob Toast-Modul verfügbar ist
    if (typeof Toast !== 'undefined') {
        Toast[type] ? Toast[type](message) : Toast.info(message);
        return;
    }
    // Fallback: Console + einfacher Alert für wichtige Meldungen
    console.log(`[Toast ${type}] ${message}`);
    if (type === 'error') {
        alert(message);
    }
}

/**
 * Exportiert Tabellendaten als CSV (für Excel)
 * @param {string} tableId - ID der Tabelle (optional - sucht sonst die erste Tabelle)
 * @param {string} filename - Dateiname ohne Extension (optional)
 */
function exportExcel(tableId, filename) {
    const table = tableId
        ? document.getElementById(tableId)
        : document.querySelector('table, .data-grid, .grid-container table');

    if (!table) {
        showToast('Keine Daten zum Exportieren gefunden', 'warning');
        return;
    }

    let csv = [];
    const rows = table.querySelectorAll('tr');

    if (rows.length === 0) {
        showToast('Tabelle ist leer', 'warning');
        return;
    }

    rows.forEach(function(row) {
        const cols = row.querySelectorAll('td, th');
        const rowData = [];
        cols.forEach(function(col) {
            // Escape quotes und wrap in quotes
            let text = col.innerText.replace(/"/g, '""');
            // Zeilenumbrüche entfernen
            text = text.replace(/\r?\n/g, ' ').trim();
            rowData.push('"' + text + '"');
        });
        if (rowData.length > 0) {
            csv.push(rowData.join(';')); // Semikolon für deutsche Excel-Version
        }
    });

    // BOM für UTF-8 damit Excel Umlaute richtig erkennt
    const csvContent = '\uFEFF' + csv.join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);

    // Dateiname generieren
    const exportFilename = (filename || 'export') + '_' + new Date().toISOString().slice(0,10) + '.csv';
    link.download = exportFilename;

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    // Cleanup URL
    URL.revokeObjectURL(link.href);

    showToast('Export erfolgreich: ' + exportFilename, 'success');
    console.log('[Global] exportExcel:', exportFilename, '- ' + rows.length + ' Zeilen');
}

/**
 * Exportiert ein Array von Objekten als CSV
 * @param {Array} data - Array von Objekten
 * @param {string} filename - Dateiname ohne Extension
 * @param {Array} columns - Optionales Array von Spaltennamen (ansonsten aus erstem Objekt)
 */
function exportDataToExcel(data, filename, columns) {
    if (!data || data.length === 0) {
        showToast('Keine Daten zum Exportieren', 'warning');
        return;
    }

    // Spaltennamen ermitteln
    const headers = columns || Object.keys(data[0]);

    let csv = [];
    // Header-Zeile
    csv.push(headers.map(function(h) { return '"' + h + '"'; }).join(';'));

    // Daten-Zeilen
    data.forEach(function(row) {
        const rowData = headers.map(function(col) {
            let value = row[col];
            if (value === null || value === undefined) value = '';
            value = String(value).replace(/"/g, '""');
            value = value.replace(/\r?\n/g, ' ').trim();
            return '"' + value + '"';
        });
        csv.push(rowData.join(';'));
    });

    const csvContent = '\uFEFF' + csv.join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);

    const exportFilename = (filename || 'export') + '_' + new Date().toISOString().slice(0,10) + '.csv';
    link.download = exportFilename;

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);

    showToast('Export erfolgreich: ' + exportFilename, 'success');
    console.log('[Global] exportDataToExcel:', exportFilename, '- ' + data.length + ' Datensätze');
}

/**
 * Druckt den Inhalt eines Containers oder die ganze Seite
 * @param {string} containerId - ID des zu druckenden Containers (optional)
 */
function printTable(containerId) {
    const container = containerId
        ? document.getElementById(containerId)
        : document.querySelector('.main-content, .content-area, main, .grid-container');

    if (!container) {
        // Fallback: ganze Seite drucken
        window.print();
        return;
    }

    const printWindow = window.open('', '_blank', 'width=800,height=600');
    if (!printWindow) {
        showToast('Popup-Blocker verhindert Druckvorschau. Bitte erlauben Sie Popups.', 'warning');
        window.print();
        return;
    }

    const title = document.title || 'Druckvorschau';

    printWindow.document.write(`
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>${title}</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    font-size: 10pt;
                    margin: 15mm;
                    color: #000;
                }
                h1, h2, h3 {
                    margin-bottom: 10px;
                    color: #333;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin-top: 10px;
                }
                th, td {
                    border: 1px solid #333;
                    padding: 4px 8px;
                    text-align: left;
                    font-size: 9pt;
                }
                th {
                    background: #f0f0f0;
                    font-weight: bold;
                }
                tr:nth-child(even) {
                    background: #fafafa;
                }
                .no-print, button, .btn, .sidebar, nav, .toolbar {
                    display: none !important;
                }
                @media print {
                    body { margin: 0; }
                    @page { margin: 10mm; }
                }
                .print-header {
                    border-bottom: 2px solid #333;
                    padding-bottom: 10px;
                    margin-bottom: 15px;
                }
                .print-footer {
                    position: fixed;
                    bottom: 10mm;
                    left: 0;
                    right: 0;
                    text-align: center;
                    font-size: 8pt;
                    color: #666;
                }
            </style>
        </head>
        <body>
            <div class="print-header">
                <h2>${title}</h2>
                <small>Erstellt: ${new Date().toLocaleString('de-DE')}</small>
            </div>
            ${container.innerHTML}
            <div class="print-footer">
                Seite 1 - Gedruckt am ${new Date().toLocaleDateString('de-DE')}
            </div>
        </body>
        </html>
    `);

    printWindow.document.close();

    // Warten bis Inhalt geladen ist, dann drucken
    printWindow.onload = function() {
        printWindow.focus();
        printWindow.print();
        // Nach dem Drucken schließen (optional)
        // printWindow.close();
    };

    console.log('[Global] printTable: Druckvorschau geöffnet für', containerId || 'main-content');
}

/**
 * Alias für printTable
 */
function drucken(containerId) {
    printTable(containerId);
}

/**
 * PDF Export - nutzt Browser-Print-Dialog mit PDF-Option
 */
function exportPDF() {
    showToast('Bitte "Als PDF speichern" im Druckdialog wählen', 'info');
    window.print();
}

/**
 * Spezialisierte Druckfunktion für Dienstplan
 * @param {string} containerId - Container mit Dienstplan-Grid
 */
function printDienstplanGrid(containerId) {
    const container = containerId
        ? document.getElementById(containerId)
        : document.querySelector('.dp-grid, .dienstplan-grid, .grid-container');

    if (!container) {
        showToast('Kein Dienstplan zum Drucken gefunden', 'warning');
        return;
    }

    const printWindow = window.open('', '_blank', 'width=1000,height=800');
    if (!printWindow) {
        showToast('Popup blockiert', 'warning');
        window.print();
        return;
    }

    const title = 'Dienstplan';

    printWindow.document.write(`
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>${title}</title>
            <style>
                @page { size: landscape; margin: 5mm; }
                body {
                    font-family: Arial, sans-serif;
                    font-size: 8pt;
                    margin: 5mm;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
                th, td {
                    border: 1px solid #666;
                    padding: 2px 4px;
                    text-align: center;
                    font-size: 7pt;
                }
                th {
                    background: #ddd;
                    font-weight: bold;
                }
                .header-row {
                    background: #f0f0f0;
                }
                .weekend { background: #ffe0e0 !important; }
                .today { background: #ffffcc !important; }
            </style>
        </head>
        <body>
            <h3>${title} - ${new Date().toLocaleDateString('de-DE')}</h3>
            ${container.innerHTML}
        </body>
        </html>
    `);

    printWindow.document.close();
    printWindow.onload = function() {
        printWindow.focus();
        printWindow.print();
    };

    console.log('[Global] printDienstplanGrid: Druckvorschau geöffnet');
}

// ============ HELPER ============

/**
 * Exportiert appState für globalen Zugriff
 * @param {object} state - State-Objekt aus Logic.js
 */
function registerAppState(state) {
    window.appState = state;
    console.log('[Global] appState registriert:', Object.keys(state));
}

// ============ ZUSAETZLICHE GLOBALE ALIASE ============

// Auftrag-Funktionen (verschiedene Schreibweisen)
function auftragLoeschen() { deleteRecord(); }
function copyAuftrag() { auftragKopieren(); }
function deleteAuftrag() { deleteRecord(); }
function refresh() {
    if (window.appState && typeof window.appState.requeryAll === 'function') {
        window.appState.requeryAll();
    } else {
        window.location.reload();
    }
}
function refreshData() { refresh(); }

// Einsatzliste-Funktionen
function sendMA() { sendEinsatzlisteMA(); }
function sendBOS() { sendEinsatzlisteBOS(); }
function sendSUB() { sendEinsatzlisteSUB(); }
function printNamesliste() { showNamenslisteESS(); }
function printEinsatzliste() { druckEinsatzliste(); }

// Datum-Navigation
function datePrev() { prevDay(); }
function dateNext() { nextDay(); }

// Filter-Funktionen
function filterStatus(status) {
    if (window.appState && typeof window.appState.filterByStatus === 'function') {
        window.appState.filterByStatus(status);
    } else {
        console.log('[Global] filterStatus:', status);
    }
}
function filterGo() {
    if (window.appState && typeof window.appState.applyAuftraegeFilter === 'function') {
        window.appState.applyAuftraegeFilter();
    }
}
function filterBack() {
    if (window.appState && typeof window.appState.shiftAuftraegeFilter === 'function') {
        window.appState.shiftAuftraegeFilter(-7);
    }
}
function filterFwd() {
    if (window.appState && typeof window.appState.shiftAuftraegeFilter === 'function') {
        window.appState.shiftAuftraegeFilter(7);
    }
}
function filterToday() {
    if (window.appState && typeof window.appState.setAuftraegeFilterToday === 'function') {
        window.appState.setAuftraegeFilterToday();
    }
}

// BWN-Funktionen
function printBWN() { druckBWN(); }

// Modal-Dialog
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
        modal.classList.remove('active');
    }
}

// Rueckmelde-Statistik
function showRueckmeldungen() {
    if (window.appState && typeof window.appState.openRueckmeldeStatistik === 'function') {
        window.appState.openRueckmeldeStatistik();
    } else {
        showRueckmeldeStatistik();
    }
}

// Umlaut-Varianten (fuer HTML mit Umlauten)
window.auftragLöschen = auftragLoeschen;
window.filterAufträge = filterGo;
window.tageZurück = filterBack;
window.openRückmeldStatistik = showRueckmeldungen;
window.showRückmeldungen = showRueckmeldungen;

// ============ HILFSFUNKTIONEN ============

/**
 * Rendert Einsatztabelle
 */
function renderEinsatzTabelle(data, tbodyId) {
    var tbody = document.getElementById(tbodyId);
    if (!tbody) return;

    tbody.innerHTML = '';
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#666;padding:10px;">Keine Einsaetze gefunden</td></tr>';
        return;
    }

    data.forEach(function(e) {
        var tr = document.createElement('tr');
        tr.innerHTML = '<td>' + formatDateDE(e.Datum || e.VADatum) + '</td>' +
            '<td>' + (e.Auftrag || '') + '</td>' +
            '<td>' + (e.Objekt || '') + '</td>' +
            '<td>' + (e.Von || e.VA_Start || '') + '</td>' +
            '<td>' + (e.Bis || e.VA_Ende || '') + '</td>' +
            '<td>' + (e.Stunden || '') + '</td>';
        tbody.appendChild(tr);
    });
}

/**
 * Rendert Jahrestabelle
 */
function renderJahresTabelle(data, tbodyId) {
    var tbody = document.getElementById(tbodyId);
    if (!tbody) return;

    tbody.innerHTML = '';
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align:center;color:#666;padding:10px;">Keine Daten gefunden</td></tr>';
        return;
    }

    data.forEach(function(e) {
        var tr = document.createElement('tr');
        tr.innerHTML = '<td>' + (e.Monat || '') + '</td>' +
            '<td>' + (e.AnzahlEinsaetze || 0) + '</td>' +
            '<td>' + (e.StundenGesamt || 0) + '</td>' +
            '<td>' + (e.Umsatz || 0) + '</td>';
        tbody.appendChild(tr);
    });
}

/**
 * Datum formatieren (ISO -> DE)
 */
function formatDateDE(value) {
    if (!value) return '';
    try {
        var d = new Date(value);
        if (isNaN(d)) return value;
        return d.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
    } catch (e) {
        return value;
    }
}

// ============ GLOBALE WINDOW-EXPORTE FÜR EXPORT/DRUCK ============
// Diese Funktionen müssen global verfügbar sein für onclick-Handler in HTML
window.exportExcel = exportExcel;
window.exportDataToExcel = exportDataToExcel;
window.printTable = printTable;
window.drucken = drucken;
window.exportPDF = exportPDF;
window.printDienstplanGrid = printDienstplanGrid;
window.showToast = showToast;

// Spezifische Export/Druck-Funktionen
window.exportXLEinsatz = exportXLEinsatz;
window.exportXLJahr = exportXLJahr;
window.exportXLNVerfueg = exportXLNVerfueg;
window.exportXLVordrucke = exportXLVordrucke;
window.exportXLUeberhang = exportXLUeberhang;
window.printDienstplan = printDienstplan;
window.druckBWN = druckBWN;
window.printBWN = printBWN;
window.exportRchPDF = exportRchPDF;
window.exportRchPosPDF = exportRchPosPDF;
window.exportEinsPDF = exportEinsPDF;
window.openPDFKopf = openPDFKopf;
window.openPDFPos = openPDFPos;

// Koordinaten/Maps-Funktionen
window.openKoordinaten = openKoordinaten;
window.openMaps = openMaps;
window.calcRoute = calcRoute;
window.geocodeAddress = geocodeAddress;

// Einsatz-Funktionen
window.loadEinsatzMonat = loadEinsatzMonat;
window.loadEinsatzJahr = loadEinsatzJahr;

// Stunden-Funktion
window.calcStunden = calcStunden;

// Dienstplan-Funktionen
window.dpToday = dpToday;
window.sendDienstplan = sendDienstplan;

// Nicht-Verfuegbar-Funktionen
window.addNichtVerfuegbar = addNichtVerfuegbar;
window.deleteNichtVerfuegbar = deleteNichtVerfuegbar;

// Kleidung-Funktionen
window.addKleidung = addKleidung;
window.reportKleidung = reportKleidung;

// Vordrucke-Funktionen
window.loadVordrucke = loadVordrucke;
window.selectVorlageDatei = selectVorlageDatei;
window.createBrief = createBrief;
window.openWord = openWord;

// Ueberhang-Funktionen
window.loadUeberhang = loadUeberhang;

// Sonstige Funktionen
window.openRechnung = openRechnung;
window.selectPhoto = selectPhoto;
window.fileToBase64 = fileToBase64;

// Kundenstamm-Funktionen
window.loadKdAuftraege = loadKdAuftraege;
window.newAngebot = newAngebot;
window.addAttachment = addAttachment;
window.addAnsprechpartner = addAnsprechpartner;

// Auftragstamm-Funktionen
window.goAuftraege = goAuftraege;
window.prevAuftraege = prevAuftraege;
window.nextAuftraege = nextAuftraege;

// Objektstamm-Funktionen
window.newPosition = newPosition;
window.deletePosition = deletePosition;
window.deleteAttachment = deleteAttachment;

// Hilfsfunktionen
window.renderEinsatzTabelle = renderEinsatzTabelle;
window.renderJahresTabelle = renderJahresTabelle;
window.formatDateDE = formatDateDE;

// Neu implementierte Funktionen
window.showAdressen = showAdressen;
window.showZKFest = showZKFest;
window.showZKMini = showZKMini;
window.sendEinsaetze = sendEinsaetze;
window.showVerrechnungssaetze = showVerrechnungssaetze;
window.showUmsatzauswertung = showUmsatzauswertung;
window.showRueckmeldeStatistik = showRueckmeldeStatistik;
window.showSyncfehler = showSyncfehler;
window.showPositionen = showPositionen;
window.openAuftraege = openAuftraege;
window.openPositionen = openPositionen;
window.showRueckmeldungen = showRueckmeldungen;

// Export für ES6-Module (falls benötigt)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        navFirst, navPrev, navNext, navLast,
        newRecord, saveRecord, deleteRecord,
        openMenu, showTab, switchTab,
        registerAppState,
        // Neue Exporte
        auftragLoeschen, copyAuftrag, deleteAuftrag,
        refresh, refreshData, closeModal,
        sendMA, sendBOS, sendSUB,
        filterStatus, filterGo, filterBack, filterFwd, filterToday,
        // Export/Druck Funktionen
        exportExcel, exportDataToExcel, printTable, drucken, exportPDF,
        printDienstplanGrid, showToast
    };
}

console.log('[Global] global-handlers.js geladen');

// ============ LOGGING-INTEGRATION ============

/**
 * Auto-Logging fuer Button-Clicks via Event Delegation
 * Loggt alle Button-Klicks automatisch ohne manuelle Integration
 */
document.addEventListener('click', function(event) {
    // Nur Buttons und klickbare Elemente tracken
    const target = event.target.closest('button, [onclick], .btn, [role="button"]');
    if (!target) return;

    // Logger verfuegbar?
    if (typeof Logger === 'undefined' || typeof Logger.buttonClick !== 'function') return;

    // Button-ID oder Text ermitteln
    const buttonId = target.id ||
        target.name ||
        target.dataset.action ||
        target.textContent?.trim().substr(0, 30) ||
        'unknown';

    // Loggen
    Logger.buttonClick(buttonId);
}, true); // Capture-Phase fuer fruehes Logging

/**
 * Wrapper fuer exportExcel mit Logging
 */
const _originalExportExcel = window.exportExcel;
window.exportExcel = function(tableId, filename) {
    if (typeof Logger !== 'undefined') {
        Logger.exportStart('Excel/CSV', filename || tableId);
    }
    const result = _originalExportExcel.call(this, tableId, filename);
    return result;
};

/**
 * Wrapper fuer exportDataToExcel mit Logging
 */
const _originalExportDataToExcel = window.exportDataToExcel;
window.exportDataToExcel = function(data, filename, columns) {
    if (typeof Logger !== 'undefined') {
        Logger.exportStart('Excel/CSV', filename);
    }
    const result = _originalExportDataToExcel.call(this, data, filename, columns);
    if (typeof Logger !== 'undefined' && data) {
        Logger.exportComplete('Excel/CSV', filename, data.length);
    }
    return result;
};

/**
 * Wrapper fuer printTable mit Logging
 */
const _originalPrintTable = window.printTable;
window.printTable = function(containerId) {
    if (typeof Logger !== 'undefined') {
        Logger.exportStart('Print', containerId || 'page');
    }
    return _originalPrintTable.call(this, containerId);
};
