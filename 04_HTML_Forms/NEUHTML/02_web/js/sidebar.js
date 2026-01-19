/**
 * sidebar.js
 * Gemeinsame Sidebar-Komponente fuer alle Formulare
 * Mit Shell-Integration fuer Preload
 *
 * PERFORMANCE-OPTIMIERUNGEN:
 * - Event Delegation statt einzelner Listener
 * - DocumentFragment fuer initiales Rendering
 * - Cached DOM-Referenzen
 */

// Cached DOM References
let _sidebarEl = null;
let _dateEl = null;
let _statusEl = null;

// Form-Map als konstante Lookup-Tabelle
const FORM_MAP = Object.freeze({
    'mitarbeiter': 'frm_MA_Mitarbeiterstamm.html',
    'kunden': 'frm_KD_Kundenstamm.html',
    'auftraege': 'frm_va_Auftragstamm.html',
    'objekte': 'frm_OB_Objekt.html',
    'dienstplan': 'frm_DP_Dienstplan_MA.html',
    'planungsuebersicht': 'frm_VA_Planungsuebersicht.html',
    'einsatzuebersicht': 'frm_Einsatzuebersicht.html',
    'ma_schnellauswahl': 'frm_MA_VA_Schnellauswahl.html',
    'abwesenheit': 'frm_MA_Abwesenheit.html',
    'zeitkonten': 'frm_MA_Zeitkonten.html',
    'bewerber': 'frm_N_MA_Bewerber_Verarbeitung.html',
    'lohnabrechnungen': 'frm_N_Lohnabrechnungen.html',
    'stundenauswertung': 'frm_N_Stundenauswertung.html',
    'dienstausweis': 'frm_Ausweis_Create.html',
    'verrechnungssaetze': 'frm_Kundenpreise.html',
    'subrechnungen': 'frm_Subrechnungen.html',
    'offene_anfragen': 'frm_MA_Offene_Anfragen.html',
    'dashboard': 'frm_Menuefuehrung1.html',
    'menue2': 'frm_Menuefuehrung1.html'
});

const SIDEBAR_HTML = `
<div class="sidebar-header">
    <span class="sidebar-logo">CONSYS</span>
</div>
<nav class="sidebar-menu">
    <div class="menu-section">
        <div class="menu-section-title">Stammdaten</div>
        <a class="menu-item" data-id="mitarbeiter">Mitarbeiter</a>
        <a class="menu-item" data-id="kunden">Kunden</a>
        <a class="menu-item" data-id="auftraege">Auftraege</a>
        <a class="menu-item" data-id="objekte">Objekte</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Planung</div>
        <a class="menu-item" data-id="dienstplan">Dienstplan</a>
        <a class="menu-item" data-id="planungsuebersicht">Planungsuebersicht</a>
        <a class="menu-item" data-id="einsatzuebersicht">Einsatzuebersicht</a>
        <a class="menu-item" data-id="ma_schnellauswahl">MA Schnellauswahl</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Personal</div>
        <a class="menu-item" data-id="abwesenheit">Abwesenheit</a>
        <a class="menu-item" data-id="zeitkonten">Zeitkonten</a>
        <a class="menu-item" data-id="bewerber">Bewerber</a>
        <a class="menu-item" data-id="offene_anfragen">Offene Anfragen</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Lohn</div>
        <a class="menu-item" data-id="lohnabrechnungen">Lohnabrechnungen</a>
        <a class="menu-item" data-id="stundenauswertung">Stundenauswertung</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Tools</div>
        <a class="menu-item" data-id="dienstausweis">Dienstausweis erstellen</a>
        <a class="menu-item" data-id="verrechnungssaetze">Verrechnungssaetze</a>
        <a class="menu-item" data-id="subrechnungen">Sub Rechnungen</a>
    </div>
</nav>
<div class="sidebar-footer">
    <a class="menu-item" data-id="dashboard">Dashboard</a>
    <a class="menu-item" data-id="menue2">Menü 2</a>
</div>
`;

/**
 * Pruefen ob in Shell-Umgebung (iframe in shell.html)
 */
function isInShell() {
    try {
        return window.parent && window.parent.ConsysShell;
    } catch (e) {
        return false;
    }
}

/**
 * Navigation - WebView2, Shell oder direkter Link
 * PRIORITAET:
 * 1. WebView2 (Access-Integration)
 * 2. Shell (iframe-Navigation)
 * 3. Direkter Link (Fallback)
 */
function navigateTo(formId) {
    const formFile = FORM_MAP[formId];
    if (!formFile) {
        console.error('Unbekannte Form-ID:', formId);
        return;
    }

    // 1. WebView2 verfuegbar? -> Access mitteilen
    if (window.chrome && window.chrome.webview) {
        console.log('CONSYS: WebView2 Navigation ->', formFile);
        window.chrome.webview.postMessage({
            event: 'navigate',
            data: {
                formName: formFile,
                formId: formId
            }
        });
        return;
    }

    // 2. Shell verfuegbar? -> Shell-Navigation nutzen (kein Reload)
    if (isInShell()) {
        console.log('CONSYS: Shell Navigation ->', formFile);
        window.parent.ConsysShell.showForm(formId);
        return;
    }

    // 3. Fallback: Direkte Navigation
    console.log('CONSYS: Direct Navigation ->', formFile);
    window.location.href = formFile;
}

/**
 * Sidebar initialisieren
 * @param {string} activeId - ID des aktiven Menuepunkts
 *
 * PERFORMANCE: Event Delegation statt einzelner Listener
 */
function initSidebar(activeId) {
    _sidebarEl = document.querySelector('.app-sidebar');
    if (!_sidebarEl) {
        console.error('Sidebar container nicht gefunden');
        return;
    }

    _sidebarEl.innerHTML = SIDEBAR_HTML;

    // PERFORMANCE: Ein einzelner Event-Listener mit Delegation
    _sidebarEl.addEventListener('click', (e) => {
        const menuItem = e.target.closest('.menu-item');
        if (menuItem) {
            e.preventDefault();
            const formId = menuItem.dataset.id;
            if (formId) {
                navigateTo(formId);
            }
        }
    });

    // Aktiven Menuepunkt markieren
    if (activeId) {
        const activeItem = _sidebarEl.querySelector(`[data-id="${activeId}"]`);
        if (activeItem) {
            activeItem.classList.add('active');
        }
    }
}

/**
 * Header-Datum aktualisieren
 * PERFORMANCE: Cached Element-Referenz
 */
function updateHeaderDate() {
    if (!_dateEl) {
        _dateEl = document.getElementById('header-date');
    }
    if (_dateEl) {
        _dateEl.textContent = new Date().toLocaleDateString('de-DE', {
            weekday: 'short',
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    }
}

/**
 * Tab-Switching initialisieren
 * PERFORMANCE: Event Delegation auf Container
 */
function initTabs() {
    const tabContainer = document.querySelector('.tab-buttons');
    if (!tabContainer) return;

    // Ein Listener fuer alle Tabs
    tabContainer.addEventListener('click', (e) => {
        const btn = e.target.closest('.tab-btn');
        if (!btn) return;

        const tabId = btn.dataset.tab;
        if (!tabId) return;

        // Alle Tabs deaktivieren
        tabContainer.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));

        // Ausgewaehlten Tab aktivieren
        btn.classList.add('active');
        const pane = document.getElementById(tabId);
        if (pane) pane.classList.add('active');
    });
}

/**
 * Status in Footer setzen
 * PERFORMANCE: Cached Element-Referenz
 */
function setStatus(text) {
    if (!_statusEl) {
        _statusEl = document.getElementById('lblStatus') || document.getElementById('footer-status');
    }
    if (_statusEl) {
        _statusEl.textContent = text;
    }
}

/**
 * Record-Info setzen
 */
function setRecordInfo(text) {
    const el = document.getElementById('lblRecordInfo');
    if (el) {
        el.textContent = text;
    }
}

// Exports
window.initSidebar = initSidebar;
window.updateHeaderDate = updateHeaderDate;
window.initTabs = initTabs;
window.setStatus = setStatus;
window.setRecordInfo = setRecordInfo;
window.navigateTo = navigateTo;
window.isInShell = isInShell;

// Auto-Init
document.addEventListener('DOMContentLoaded', () => {
    // Sidebar ID aus body data-attribute lesen
    const body = document.body;
    const activeMenu = body.dataset.activeMenu;

    if (document.querySelector('.app-sidebar')) {
        initSidebar(activeMenu);
    }

    updateHeaderDate();
    initTabs();

    // Shell-Status anzeigen
    if (isInShell()) {
        console.log('CONSYS: Laeuft in Shell-Umgebung (Preload aktiv)');
    }
});
