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

// Form-Map als konstante Lookup-Tabelle (synchron mit shell.html)
const FORM_MAP = Object.freeze({
    // Stammdaten
    'mitarbeiter': 'frm_MA_Mitarbeiterstamm.html',
    'kunden': 'frm_KD_Kundenstamm.html',
    'auftraege': 'frm_va_Auftragstamm.html',
    'objekte': 'frm_OB_Objekt.html',
    // Planung
    'dienstplan': 'frm_DP_Dienstplan_MA.html',
    'dienstplan_objekt': 'frm_DP_Dienstplan_Objekt.html',
    'planungsuebersicht': 'frm_VA_Planungsuebersicht.html',
    'ma_auftrag_zuo': 'frmTop_DP_MA_Auftrag_Zuo.html',
    'auftragseingabe': 'frmTop_DP_Auftragseingabe.html',
    'schnellauswahl': 'frm_MA_VA_Schnellauswahl.html',
    'positionszuordnung': 'frm_MA_VA_Positionszuordnung.html',
    // Personal
    'mitarbeiterstamm': 'frm_MA_Mitarbeiterstamm.html',
    'abwesenheiten': 'frm_Abwesenheiten.html',
    'abwesenheitsuebersicht': 'frm_abwesenheitsuebersicht.html',
    'zeitkonten': 'frm_MA_Zeitkonten.html',
    'abwesenheit_ma': 'frm_MA_Abwesenheit.html',
    'bewerber': 'frm_N_Bewerber.html',
    // Lohn
    'lohnabrechnungen': 'frm_N_Lohnabrechnungen.html',
    'stunden_lexware': 'zfrm_MA_Stunden_Lexware.html',
    // Kommunikation
    'email_dienstplan': 'frm_MA_Serien_eMail_dienstplan.html',
    'email_auftrag': 'frm_MA_Serien_eMail_Auftrag.html',
    'email_versenden': 'frm_N_Email_versenden.html',
    // Verwaltung
    'geo_verwaltung': 'frmTop_Geo_Verwaltung.html',
    'optimierung': 'frm_Menuefuehrung1.html',
    // Dashboard / Menue
    'dashboard': 'frm_Menuefuehrung1.html',
    'dashboard_neu': 'frm_N_Dienstplanuebersicht.html',
    'menue': 'frm_Menuefuehrung.html',
    // Access-style Hauptmenue
    'dienstplanuebersicht': 'frm_N_Dienstplanuebersicht.html',
    'auftragsverwaltung': 'frm_va_Auftragstamm.html',
    'mitarbeiterverwaltung': 'frm_MA_Mitarbeiterstamm.html',
    'kundenverwaltung': 'frm_KD_Kundenstamm.html',
    'kundenpreise': 'frm_Kundenpreise_gueni.html',
    'abwesenheitsplanung': 'frmTop_MA_Abwesenheitsplanung.html',
    'dienstausweis': 'frm_Ausweis_Create.html',
    'stundenabgleich': 'frm_N_Stundenauswertung.html',
    'offene_mail_anfragen': 'frm_N_Email_versenden.html',
    'excel_zeitkonten': 'frm_MA_Zeitkonten.html',
    'verrechnungssaetze': 'frm_KD_Kundenstamm.html',
    'sub_rechnungen': 'frm_N_Lohnabrechnungen.html',
    'email': 'frm_N_Email_versenden.html',
    'menue2': 'frm_Menuefuehrung1.html',
    'offene_anfragen': 'frm_MA_Offene_Anfragen.html'
});

const ACCESS_MENU_HTML = `
<div class="sidebar-header">
    <span class="sidebar-logo">HAUPTMENÜ</span>
</div>
<nav class="sidebar-menu">
    <a class="menu-item" data-id="dienstplanuebersicht">Dienstplanübersicht</a>
    <a class="menu-item" data-id="planungsuebersicht">Planungsübersicht</a>
    <a class="menu-item" data-id="auftragsverwaltung">Auftragsverwaltung</a>
    <a class="menu-item" data-id="mitarbeiterverwaltung">Mitarbeiterverwaltung</a>
    <a class="menu-item" data-id="offene_anfragen">Offene Anfragen</a>
    <a class="menu-item" data-id="offene_mail_anfragen">Offene Mail Anfragen</a>
    <a class="menu-item" data-id="excel_zeitkonten">Excel Zeitkonten</a>
    <div class="menu-divider"></div>
    <a class="menu-item" data-id="zeitkonten">Zeitkonten</a>
    <a class="menu-item" data-id="abwesenheitsplanung">Abwesenheitsplanung</a>
    <a class="menu-item" data-id="dienstausweis">Dienstausweis erstellen</a>
    <a class="menu-item" data-id="stundenabgleich">Stundenabgleich</a>
    <a class="menu-item" data-id="stunden_lexware">Stunden Lexware</a>
    <div class="menu-divider"></div>
    <a class="menu-item" data-id="kundenverwaltung">Kundenverwaltung</a>
    <a class="menu-item" data-id="kundenpreise">Kundenpreise</a>
    <a class="menu-item" data-id="verrechnungssaetze">Verrechnungssätze</a>
    <a class="menu-item" data-id="sub_rechnungen">Sub Rechnungen</a>
    <a class="menu-item" data-id="email">E-Mail</a>
    <div class="menu-divider"></div>
    <a class="menu-item" data-id="menue2">Menü 2</a>
    <a class="menu-item disabled" data-disabled="true">HTML Ansicht</a>
    <a class="menu-item disabled" data-disabled="true">Datenbank wechseln</a>
</nav>
`;


const SIDEBAR_HTML = `
<div class="sidebar-header">
    <span class="sidebar-logo">CONSYS</span>
</div>
<nav class="sidebar-menu">
    <div class="menu-section">
        <div class="menu-section-title">Stammdaten</div>
        <a class="menu-item" data-id="mitarbeiter">Mitarbeiter</a>
        <a class="menu-item" data-id="kunden">Kunden</a>
        <a class="menu-item" data-id="kundenpreise">Kundenpreise</a>
        <a class="menu-item" data-id="auftraege">Aufträge</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Planung</div>
        <a class="menu-item" data-id="dienstplan">Dienstplanübersicht</a>
        <a class="menu-item" data-id="planungsuebersicht">Planungsübersicht</a>
        <a class="menu-item" data-id="offene_anfragen">Offene Anfragen</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Personal</div>
        <a class="menu-item" data-id="mitarbeiterstamm">Mitarbeiterstamm</a>
        <a class="menu-item" data-id="abwesenheitsuebersicht">Abwesenheitsübersicht</a>
        <a class="menu-item" data-id="abwesenheitsplanung">Abwesenheitsplanung</a>
        <a class="menu-item" data-id="zeitkonten">Zeitkonten</a>
        <a class="menu-item" data-id="bewerber">Bewerber</a>
        <a class="menu-item" data-id="dienstausweis">Ausweiserstellung</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Lohn</div>
        <a class="menu-item" data-id="lohnabrechnungen">Lohnabrechnungen</a>
        <a class="menu-item" data-id="stunden_lexware">Stunden Lexware</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Kommunikation</div>
        <a class="menu-item" data-id="email_versenden">E-Mail versenden</a>
    </div>
    <div class="menu-divider"></div>
    <div class="menu-section">
        <div class="menu-section-title">Verwaltung</div>
        <a class="menu-item" data-id="geo_verwaltung">Geo-Verwaltung</a>
        <a class="menu-item" data-id="optimierung">Optimierung</a>
    </div>
</nav>
<div class="sidebar-footer">
    <a class="menu-item" data-id="dashboard">Dashboard</a>
    <a class="menu-item" data-id="dashboard_neu">Dashboard (Neu)</a>
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
 * Navigation - entweder ueber Shell oder direkter Link
 */
function navigateTo(formId) {
    if (isInShell()) {
        // Shell-Navigation nutzen (kein Reload)
        window.parent.ConsysShell.showForm(formId);
    } else {
        // Fallback: Direkte Navigation mit konstanter Lookup-Tabelle
        const url = FORM_MAP[formId];
        if (url) {
            const target = new URL(url, window.location.href).href;
            window.location.href = target;
        }
    }
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

    const menuStyle = document.body?.dataset?.menuStyle;
    _sidebarEl.innerHTML = menuStyle === 'access' ? ACCESS_MENU_HTML : SIDEBAR_HTML;

    // PERFORMANCE: Ein einzelner Event-Listener mit Delegation
    _sidebarEl.addEventListener('click', (e) => {
        const menuItem = e.target.closest('.menu-item');
        if (menuItem) {
            if (menuItem.dataset.disabled === 'true' || menuItem.classList.contains('disabled')) {
                return;
            }
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

// API Server Lifecycle laden
function loadApiLifecycle() {
    return new Promise((resolve) => {
        // Prüfe ob bereits geladen
        if (window.APILifecycle) {
            resolve();
            return;
        }

        const script = document.createElement('script');
        script.src = '../js/api-lifecycle.js';
        script.onload = () => {
            console.log('CONSYS: API-Lifecycle geladen');
            resolve();
        };
        script.onerror = () => {
            console.warn('CONSYS: api-lifecycle.js konnte nicht geladen werden');
            resolve();
        };
        document.head.appendChild(script);
    });
}

// Auto-Init
document.addEventListener('DOMContentLoaded', async () => {
    // Sidebar ID aus body data-attribute lesen
    const body = document.body;
    const activeMenu = body.dataset.activeMenu;

    if (document.querySelector('.app-sidebar')) {
        initSidebar(activeMenu);
    }

    updateHeaderDate();
    initTabs();

    // API-Server Lifecycle initialisieren (Auto-Start/Stop)
    await loadApiLifecycle();

    // Shell-Status anzeigen
    if (isInShell()) {
        console.log('CONSYS: Laeuft in Shell-Umgebung (Preload aktiv)');
    }
});
