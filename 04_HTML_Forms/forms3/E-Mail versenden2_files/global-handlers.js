/**
 * CONSYS Global Button Handlers
 * ============================
 * Zentrale Button-Funktionen für alle HTML-Formulare
 * Erstellt: 01.01.2026
 *
 * VERWENDUNG:
 * 1. Script einbinden: <script src="../js/global-handlers.js"></script>
 * 2. appState registrieren: registerAppState({ ... })
 */

'use strict';

// ============================================================
// GLOBALER APP STATE
// ============================================================

/**
 * Globaler State für formular-spezifische Logik
 * Jedes Formular registriert hier seine Funktionen
 */
window.appState = {
    currentIndex: 0,
    records: [],
    formType: null,

    // Standard-Implementierungen (werden von Formularen überschrieben)
    gotoRecord: function(index) {
        console.warn('gotoRecord nicht implementiert für dieses Formular');
    },
    newRecord: function() {
        console.warn('newRecord nicht implementiert für dieses Formular');
    },
    saveRecord: function() {
        console.warn('saveRecord nicht implementiert für dieses Formular');
    },
    deleteRecord: function() {
        console.warn('deleteRecord nicht implementiert für dieses Formular');
    },
    refreshData: function() {
        console.warn('refreshData nicht implementiert für dieses Formular');
    }
};

/**
 * Registriert formular-spezifische Funktionen
 * @param {Object} state - Objekt mit formular-spezifischen Funktionen
 */
function registerAppState(state) {
    Object.assign(window.appState, state);
    console.log('AppState registriert für:', state.formType || 'unbekannt');
}

// ============================================================
// NAVIGATION (Datensätze)
// ============================================================

/**
 * Zum ersten Datensatz navigieren
 */
function navFirst() {
    if (window.appState && typeof window.appState.gotoRecord === 'function') {
        window.appState.gotoRecord(0);
    }
}

/**
 * Zum vorherigen Datensatz navigieren
 */
function navPrev() {
    if (window.appState) {
        const newIndex = Math.max(0, window.appState.currentIndex - 1);
        window.appState.gotoRecord(newIndex);
    }
}

/**
 * Zum nächsten Datensatz navigieren
 */
function navNext() {
    if (window.appState) {
        const maxIndex = (window.appState.records?.length || 1) - 1;
        const newIndex = Math.min(maxIndex, window.appState.currentIndex + 1);
        window.appState.gotoRecord(newIndex);
    }
}

/**
 * Zum letzten Datensatz navigieren
 */
function navLast() {
    if (window.appState && window.appState.records) {
        window.appState.gotoRecord(window.appState.records.length - 1);
    }
}

/**
 * Zu spezifischem Datensatz via ID navigieren
 */
function gotoRecordById(id) {
    if (window.appState && window.appState.records) {
        const index = window.appState.records.findIndex(r =>
            r.id === id || r.ID === id || r.MA_ID === id || r.VA_ID === id || r.kun_Id === id
        );
        if (index >= 0) {
            window.appState.gotoRecord(index);
        }
    }
}

// ============================================================
// CRUD OPERATIONEN
// ============================================================

/**
 * Neuen Datensatz anlegen
 */
function newRecord() {
    if (window.appState && typeof window.appState.newRecord === 'function') {
        window.appState.newRecord();
    }
}

/**
 * Aktuellen Datensatz speichern
 */
function saveRecord() {
    if (window.appState && typeof window.appState.saveRecord === 'function') {
        window.appState.saveRecord();
    }
}

/**
 * Aktuellen Datensatz löschen
 */
function deleteRecord() {
    if (window.appState && typeof window.appState.deleteRecord === 'function') {
        if (confirm('Soll dieser Datensatz wirklich gelöscht werden?')) {
            window.appState.deleteRecord();
        }
    }
}

/**
 * Daten aktualisieren
 */
function refreshData() {
    if (window.appState && typeof window.appState.refreshData === 'function') {
        window.appState.refreshData();
    }
}

// ============================================================
// FORMULAR-SPEZIFISCHE ALIASE
// ============================================================

// Mitarbeiter
function newMA() { newRecord(); }
function saveMA() { saveRecord(); }
function deleteMA() { deleteRecord(); }

// Kunden
function newKunde() { newRecord(); }
function saveKunde() { saveRecord(); }
function deleteKunde() { deleteRecord(); }

// Aufträge
function newAuftrag() { newRecord(); }
function saveAuftrag() { saveRecord(); }
function deleteAuftrag() { deleteRecord(); }

// Objekte
function newObjekt() { newRecord(); }
function saveObjekt() { saveRecord(); }
function deleteObjekt() { deleteRecord(); }

// ============================================================
// FORMULAR-NAVIGATION (Sidebar/Menü)
// ============================================================

/**
 * Mapping von Menü-Keys zu Formular-Namen
 */
const FORM_MAP = {
    // Hauptmenü
    'hauptmenu': 'frm_Menuefuehrung1',
    'dashboard': 'frm_Menuefuehrung1',
    'frm_menuefuehrung1': 'frm_Menuefuehrung1',
    'menu-2': 'frm_Menuefuehrung1',

    // Planung & Dienstplan
    'dienstplan': 'frm_DP_Dienstplan_MA',
    'dienstplan-ma': 'frm_DP_Dienstplan_MA',
    'dienstplan-objekt': 'frm_DP_Dienstplan_Objekt',
    'frm_n_dienstplanuebersicht': 'frm_N_Dienstplanuebersicht',
    'dienstplanuebersicht': 'frm_N_Dienstplanuebersicht',
    'dienstplanubersicht': 'frm_N_Dienstplanuebersicht',
    'planung': 'frm_VA_Planungsuebersicht',
    'planungsuebersicht': 'frm_VA_Planungsuebersicht',
    'planungsubersicht': 'frm_VA_Planungsuebersicht',
    'frm_va_planungsuebersicht': 'frm_VA_Planungsuebersicht',
    'einsatzuebersicht': 'frm_Einsatzuebersicht',
    'schnellauswahl': 'frm_MA_VA_Schnellauswahl',
    'frm_ma_va_schnellauswahl': 'frm_MA_VA_Schnellauswahl',
    'offene-mail-anfragen': 'frm_MA_VA_Schnellauswahl',

    // Stammdaten
    'auftrag': 'frm_va_Auftragstamm',
    'auftraege': 'frm_va_Auftragstamm',
    'auftragstamm': 'frm_va_Auftragstamm',
    'auftragsverwaltung': 'frm_va_Auftragstamm',
    'frm_va_auftragstamm': 'frm_va_Auftragstamm',
    'mitarbeiter': 'frm_MA_Mitarbeiterstamm',
    'mitarbeiterstamm': 'frm_MA_Mitarbeiterstamm',
    'mitarbeiterverwaltung': 'frm_MA_Mitarbeiterstamm',
    'frm_ma_mitarbeiterstamm': 'frm_MA_Mitarbeiterstamm',
    'kunden': 'frm_KD_Kundenstamm',
    'kundenstamm': 'frm_KD_Kundenstamm',
    'kundenverwaltung': 'frm_KD_Kundenstamm',
    'frm_kd_kundenstamm': 'frm_KD_Kundenstamm',
    'objekt': 'frm_OB_Objekt',
    'objekte': 'frm_OB_Objekt',
    'objektverwaltung': 'frm_OB_Objekt',
    'frm_ob_objekt': 'frm_OB_Objekt',

    // Personal
    'abwesenheiten': 'frm_Abwesenheiten',
    'abwesenheit': 'frm_Abwesenheiten',
    'abwesenheitsplanung': 'frm_Abwesenheiten',
    'frm_ma_abwesenheit': 'frm_Abwesenheiten',
    'zeitkonten': 'frm_MA_Zeitkonten',
    'frm_ma_zeitkonten': 'frm_MA_Zeitkonten',
    'excel-zeitkonten': 'frm_MA_Zeitkonten',
    'bewerber': 'frm_N_MA_Bewerber_Verarbeitung',

    // Lohn & Auswertung
    'lohn': 'frm_N_Lohnabrechnungen',
    'lohnabrechnungen': 'frm_N_Lohnabrechnungen',
    'stundenauswertung': 'frm_N_Stundenauswertung',
    'stundenabgleich': 'frm_N_Stundenauswertung',
    'frm_n_stundenauswertung': 'frm_N_Stundenauswertung',
    'stunden': 'frm_N_Stundenauswertung',

    // Email
    'email': 'frm_Email',
    'frm_email': 'frm_Email',
    'e-mail': 'frm_Email',
    'email-auftrag': 'frm_MA_Serien_eMail_Auftrag',
    'email-dienstplan': 'frm_MA_Serien_eMail_dienstplan',

    // Dienstausweis
    'dienstausweis': 'frm_Dienstausweis',
    'frm_dienstausweis': 'frm_Dienstausweis',
    'dienstausweis-erstellen': 'frm_Dienstausweis',

    // Verrechnungssätze & Rechnungen
    'verrechnungssaetze': 'frm_Verrechnungssaetze',
    'verrechnungssatze': 'frm_Verrechnungssaetze',
    'frm_verrechnungssaetze': 'frm_Verrechnungssaetze',
    'sub-rechnungen': 'frm_SubRechnungen',
    'subrechnungen': 'frm_SubRechnungen',
    'frm_subrechnungen': 'frm_SubRechnungen',

    // System
    'systeminfo': 'frm_SystemInfo',
    'system-info': 'frm_SystemInfo',
    'frm_systeminfo': 'frm_SystemInfo',
    'dbwechseln': 'frm_DBWechseln',
    'datenbank-wechseln': 'frm_DBWechseln',
    'frm_dbwechseln': 'frm_DBWechseln',

    // Sonstiges
    'rueckmeldungen': 'frm_Rueckmeldungen',
    'positionszuordnung': 'frm_MA_VA_Positionszuordnung'
};

/**
 * Öffnet ein anderes Formular
 * @param {string} target - Menü-Key oder Formular-Name
 * @param {number|null} id - Optional: ID für Datensatz
 */
function openMenu(target, id = null) {
    // Normalisieren
    const key = target.toLowerCase().replace(/[_\s-]+/g, '-');
    const formName = FORM_MAP[key] || target;

    console.log('openMenu:', target, '→', formName, 'ID:', id);

    // WebView2 Bridge verwenden wenn verfügbar
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('navigate', {
            form: formName,
            id: id
        });
    } else {
        // Fallback: Direkte Navigation im Browser
        const htmlName = formName.replace('frm_', '').replace(/_/g, '_') + '.html';
        const url = id ? `${formName}.html?id=${id}` : `${formName}.html`;
        window.location.href = url;
    }
}

/**
 * Sidebar-Button Click Handler (für data-form Attribute)
 */
function handleSidebarClick(event) {
    const btn = event.target.closest('.menu-btn, [data-form]');
    if (!btn) return;

    const formKey = btn.dataset.form || btn.textContent.toLowerCase().trim();
    openMenu(formKey);
}

// ============================================================
// TAB-NAVIGATION
// ============================================================

/**
 * Tab anzeigen und Button aktivieren
 * @param {string} tabId - ID des Tab-Containers (ohne 'tab-' Präfix)
 * @param {HTMLElement} btnElement - Der geklickte Button
 */
function showTab(tabId, btnElement) {
    // Alle Tabs verstecken
    document.querySelectorAll('.tab-content, .tab-panel, [id^="tab-"]').forEach(tab => {
        tab.style.display = 'none';
        tab.classList.remove('active');
    });

    // Alle Tab-Buttons deaktivieren
    document.querySelectorAll('.tab-btn, .tab-button, [role="tab"]').forEach(btn => {
        btn.classList.remove('active');
        btn.setAttribute('aria-selected', 'false');
    });

    // Gewählten Tab anzeigen
    const targetTab = document.getElementById('tab-' + tabId) || document.getElementById(tabId);
    if (targetTab) {
        targetTab.style.display = 'block';
        targetTab.classList.add('active');
    }

    // Button aktivieren
    if (btnElement) {
        btnElement.classList.add('active');
        btnElement.setAttribute('aria-selected', 'true');
    }
}

/**
 * Alternative Tab-Funktion für unterschiedliche Namenskonventionen
 */
function switchTab(tabName, button) {
    showTab(tabName, button);
}

function activateTab(tabId) {
    showTab(tabId, document.querySelector(`[data-tab="${tabId}"]`));
}

// ============================================================
// DIALOG & MODAL FUNKTIONEN
// ============================================================

/**
 * Formular schließen
 */
function closeForm() {
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('close', {});
    } else {
        window.close();
    }
}

/**
 * Zeigt eine Toast-Nachricht
 * @param {string} message - Nachricht
 * @param {string} type - 'success', 'error', 'warning', 'info'
 */
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer') || createToastContainer();

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;

    container.appendChild(toast);

    // Auto-remove nach 3 Sekunden
    setTimeout(() => {
        toast.classList.add('fade-out');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'toast-container';
    container.style.cssText = 'position:fixed;top:20px;right:20px;z-index:9999;';
    document.body.appendChild(container);
    return container;
}

/**
 * Zeigt/versteckt Loading-Overlay
 */
function showLoading(show = true) {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.style.display = show ? 'flex' : 'none';
    }
}

function hideLoading() {
    showLoading(false);
}

// ============================================================
// SUCHE & FILTER
// ============================================================

/**
 * Suche im aktuellen Formular
 * @param {string} term - Suchbegriff
 */
function searchRecords(term) {
    if (typeof Bridge !== 'undefined' && Bridge.search) {
        const type = window.appState?.formType || 'general';
        Bridge.search(type, term);
    } else if (window.appState?.search) {
        window.appState.search(term);
    }
}

/**
 * Filter anwenden
 * @param {Object} filters - Filter-Objekt
 */
function applyFilter(filters) {
    if (window.appState?.applyFilter) {
        window.appState.applyFilter(filters);
    }
}

/**
 * Filter zurücksetzen
 */
function clearFilter() {
    if (window.appState?.clearFilter) {
        window.appState.clearFilter();
    }

    // Input-Felder leeren
    document.querySelectorAll('.filter-input, [data-filter]').forEach(input => {
        input.value = '';
    });
}

// ============================================================
// DRUCK & EXPORT
// ============================================================

/**
 * Aktuelle Ansicht drucken
 */
function printView() {
    window.print();
}

/**
 * Daten exportieren
 * @param {string} format - 'csv', 'excel', 'pdf'
 */
function exportData(format = 'csv') {
    if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
        Bridge.sendEvent('export', {
            format: format,
            formType: window.appState?.formType
        });
    }
}

// ============================================================
// SPEZIELLE FORMULAR-FUNKTIONEN
// ============================================================

// Dienstplan
function openDienstplanMA(maId) {
    openMenu('dienstplan-ma', maId);
}

function openDienstplanObjekt(objektId) {
    openMenu('dienstplan-objekt', objektId);
}

// Auftrag
function openAuftragDetails(vaId) {
    openMenu('auftrag', vaId);
}

function openPlanungsuebersicht(vaId) {
    openMenu('planung', vaId);
}

// Email
function sendEmailAuftrag() {
    if (window.appState?.sendEmail) {
        window.appState.sendEmail('auftrag');
    } else {
        openMenu('email-auftrag');
    }
}

function sendEmailDienstplan() {
    if (window.appState?.sendEmail) {
        window.appState.sendEmail('dienstplan');
    } else {
        openMenu('email-dienstplan');
    }
}

// ============================================================
// INITIALISIERUNG
// ============================================================

document.addEventListener('DOMContentLoaded', function() {
    // Sidebar Event Delegation
    const sidebar = document.querySelector('.left-menu, .app-sidebar, .sidebar');
    if (sidebar) {
        sidebar.addEventListener('click', handleSidebarClick);
    }

    // Active Menu markieren basierend auf data-active-menu
    const activeMenu = document.body.dataset.activeMenu;
    if (activeMenu) {
        const activeBtn = document.querySelector(`[data-form="${activeMenu}"]`);
        if (activeBtn) {
            activeBtn.classList.add('active');
        }
    }

    console.log('Global Handlers initialisiert');
});

// ============================================================
// EXPORT FÜR MODULE
// ============================================================

if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        registerAppState,
        navFirst, navPrev, navNext, navLast,
        newRecord, saveRecord, deleteRecord, refreshData,
        openMenu, showTab, switchTab,
        showToast, showLoading, hideLoading,
        searchRecords, applyFilter, clearFilter,
        printView, exportData
    };
}
