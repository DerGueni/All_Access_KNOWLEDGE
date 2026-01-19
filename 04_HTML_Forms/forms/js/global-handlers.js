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
    'schnellauswahl': 'frm_N_MA_VA_Schnellauswahl'
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
function showAdressen() {
    console.log('[Global] showAdressen - TODO: Implementieren');
    // TODO: Adressenformular öffnen
}
function showZeitkonto() {
    if (window.appState && window.appState.currentRecord) {
        openMenu('zeitkonten', window.appState.currentRecord.MA_ID);
    }
}
function showZKFest() {
    console.log('[Global] showZKFest - TODO: Implementieren');
}
function showZKMini() {
    console.log('[Global] showZKMini - TODO: Implementieren');
}
function sendEinsaetze() {
    console.log('[Global] sendEinsaetze - TODO: Implementieren');
}

// Kundenstamm
function newKunde() { newRecord(); }
function deleteKunde() { deleteRecord(); }
function showVerrechnungssaetze() {
    console.log('[Global] showVerrechnungssaetze - TODO: Implementieren');
}
function showUmsatzauswertung() {
    console.log('[Global] showUmsatzauswertung - TODO: Implementieren');
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
function showRueckmeldeStatistik() {
    console.log('[Global] showRueckmeldeStatistik - TODO: Implementieren');
}
function showSyncfehler() {
    console.log('[Global] showSyncfehler - TODO: Implementieren');
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
function showPositionen() {
    console.log('[Global] showPositionen - TODO: Implementieren');
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
function openAuftraege() {
    console.log('[Global] openAuftraege - TODO: Implementieren');
}
function openPositionen() {
    console.log('[Global] openPositionen - TODO: Implementieren');
}

// ============ TAB-CONTENT BUTTONS ============

function openKoordinaten() {
    console.log('[Global] openKoordinaten - TODO: Implementieren');
}
function loadEinsatzMonat() {
    console.log('[Global] loadEinsatzMonat - TODO: Implementieren');
}
function exportXLEinsatz() {
    console.log('[Global] exportXLEinsatz - TODO: Implementieren');
}
function loadEinsatzJahr() {
    console.log('[Global] loadEinsatzJahr - TODO: Implementieren');
}
function exportXLJahr() {
    console.log('[Global] exportXLJahr - TODO: Implementieren');
}
function calcStunden() {
    console.log('[Global] calcStunden - TODO: Implementieren');
}
function dpToday() {
    console.log('[Global] dpToday - TODO: Implementieren');
}
function printDienstplan() {
    console.log('[Global] printDienstplan - TODO: Implementieren');
}
function sendDienstplan() {
    console.log('[Global] sendDienstplan - TODO: Implementieren');
}
function addNichtVerfuegbar() {
    console.log('[Global] addNichtVerfuegbar - TODO: Implementieren');
}
function deleteNichtVerfuegbar() {
    console.log('[Global] deleteNichtVerfuegbar - TODO: Implementieren');
}
function exportXLNVerfueg() {
    console.log('[Global] exportXLNVerfueg - TODO: Implementieren');
}
function addKleidung() {
    console.log('[Global] addKleidung - TODO: Implementieren');
}
function reportKleidung() {
    console.log('[Global] reportKleidung - TODO: Implementieren');
}
function loadVordrucke() {
    console.log('[Global] loadVordrucke - TODO: Implementieren');
}
function selectVorlageDatei() {
    console.log('[Global] selectVorlageDatei - TODO: Implementieren');
}
function exportXLVordrucke() {
    console.log('[Global] exportXLVordrucke - TODO: Implementieren');
}
function createBrief() {
    console.log('[Global] createBrief - TODO: Implementieren');
}
function openWord() {
    console.log('[Global] openWord - TODO: Implementieren');
}
function loadUeberhang() {
    console.log('[Global] loadUeberhang - TODO: Implementieren');
}
function exportXLUeberhang() {
    console.log('[Global] exportXLUeberhang - TODO: Implementieren');
}
function openMaps() {
    console.log('[Global] openMaps - TODO: Implementieren');
}
function calcRoute() {
    console.log('[Global] calcRoute - TODO: Implementieren');
}
function geocodeAddress() {
    console.log('[Global] geocodeAddress - TODO: Implementieren');
}
function openRechnung() {
    console.log('[Global] openRechnung - TODO: Implementieren');
}
function selectPhoto() {
    console.log('[Global] selectPhoto - TODO: Implementieren');
}

// Kundenstamm Tab-Content
function loadKdAuftraege() {
    console.log('[Global] loadKdAuftraege - TODO: Implementieren');
}
function exportRchPDF() {
    console.log('[Global] exportRchPDF - TODO: Implementieren');
}
function exportRchPosPDF() {
    console.log('[Global] exportRchPosPDF - TODO: Implementieren');
}
function exportEinsPDF() {
    console.log('[Global] exportEinsPDF - TODO: Implementieren');
}
function newAngebot() {
    console.log('[Global] newAngebot - TODO: Implementieren');
}
function addAttachment() {
    console.log('[Global] addAttachment - TODO: Implementieren');
}
function addAnsprechpartner() {
    console.log('[Global] addAnsprechpartner - TODO: Implementieren');
}

// Auftragstamm Tab-Content
function druckBWN() {
    console.log('[Global] druckBWN - TODO: Implementieren');
}
function openPDFKopf() {
    console.log('[Global] openPDFKopf - TODO: Implementieren');
}
function openPDFPos() {
    console.log('[Global] openPDFPos - TODO: Implementieren');
}
function goAuftraege() {
    console.log('[Global] goAuftraege - TODO: Implementieren');
}
function prevAuftraege() {
    console.log('[Global] prevAuftraege - TODO: Implementieren');
}
function nextAuftraege() {
    console.log('[Global] nextAuftraege - TODO: Implementieren');
}

// Objektstamm Tab-Content
function newPosition() {
    console.log('[Global] newPosition - TODO: Implementieren');
}
function deletePosition() {
    console.log('[Global] deletePosition - TODO: Implementieren');
}
function deleteAttachment() {
    console.log('[Global] deleteAttachment - TODO: Implementieren');
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

// Export für ES6-Module (falls benötigt)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        navFirst, navPrev, navNext, navLast,
        newRecord, saveRecord, deleteRecord,
        openMenu, showTab, switchTab,
        registerAppState
    };
}

console.log('[Global] global-handlers.js geladen');
