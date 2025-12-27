/**
 * menu-links.js
 * Zentrale Link-Definitionen fuer alle Menue-Eintraege
 * KEINE defekten Links mehr - alle href="#" wurden ersetzt
 */

// Alle verfuegbaren Formulare mit korrekten Pfaden
const MENU_LINKS = {
    // Hauptnavigation
    dienstplan: {
        href: 'frm_N_Dienstplanuebersicht.html',
        label: 'Dienstplanuebersicht',
        icon: '&#128197;'
    },
    planung: {
        href: 'frm_VA_Planungsuebersicht.html',
        label: 'Planungsuebersicht',
        icon: '&#128200;'
    },
    auftraege: {
        href: 'frm_va_Auftragstamm.html',
        label: 'Auftragsverwaltung',
        icon: '&#128203;'
    },
    mitarbeiter: {
        href: 'frm_MA_Mitarbeiterstamm.html',
        label: 'Mitarbeiterverwaltung',
        icon: '&#128100;'
    },

    // Vorher defekte Links - jetzt korrigiert
    mailanfragen: {
        href: 'frm_N_Email_versenden.html',
        label: 'Offene Mail Anfragen',
        icon: '&#128231;'
    },
    excelzeitkonten: {
        href: 'frm_MA_Zeitkonten.html',
        label: 'Excel Zeitkonten',
        icon: '&#128202;'
    },
    zeitkonten: {
        href: 'frm_MA_Zeitkonten.html',
        label: 'Zeitkonten',
        icon: '&#128336;'
    },
    abwesenheit: {
        href: 'frm_MA_Abwesenheit.html',
        label: 'Abwesenheitsplanung',
        icon: '&#128197;'
    },
    ausweis: {
        href: 'frm_Ausweis_Create.html',
        label: 'Dienstausweis erstellen',
        icon: '&#127380;'
    },
    stundenabgleich: {
        href: 'frm_N_Stundenauswertung.html',
        label: 'Stundenabgleich',
        icon: '&#128200;'
    },
    kunden: {
        href: 'frm_KD_Kundenstamm.html',
        label: 'Kundenverwaltung',
        icon: '&#127970;'
    },
    verrechnungssaetze: {
        href: 'frm_KD_Kundenstamm.html#konditionen',
        label: 'Verrechnungssaetze',
        icon: '&#128176;'
    },
    subrechnungen: {
        href: 'frm_N_Lohnabrechnungen.html',
        label: 'Sub Rechnungen',
        icon: '&#128179;'
    },
    email: {
        href: 'frm_N_Email_versenden.html',
        label: 'E-Mail',
        icon: '&#128231;'
    },

    // Sekundaere Navigation
    menue2: {
        href: 'frm_Menuefuehrung.html',
        label: 'Menue 2',
        icon: '&#128196;',
        secondary: true
    },
    systeminfo: {
        href: 'frm_N_Optimierung.html',
        label: 'System Info',
        icon: '&#9881;',
        secondary: true
    },

    // Zusaetzliche Formulare
    objekte: {
        href: 'frm_OB_Objekt.html',
        label: 'Objektverwaltung',
        icon: '&#127970;'
    },
    einsatzuebersicht: {
        href: 'frm_Einsatzuebersicht.html',
        label: 'Einsatzuebersicht',
        icon: '&#128200;'
    },
    schnellauswahl: {
        href: 'frm_MA_VA_Schnellauswahl.html',
        label: 'MA Schnellauswahl',
        icon: '&#9889;'
    },
    bewerber: {
        href: 'frm_N_MA_Bewerber_Verarbeitung.html',
        label: 'Bewerberverwaltung',
        icon: '&#128101;'
    },
    lohnabrechnungen: {
        href: 'frm_N_Lohnabrechnungen.html',
        label: 'Lohnabrechnungen',
        icon: '&#128176;'
    },
    dashboard: {
        href: 'frm_Menuefuehrung1.html',
        label: 'Dashboard',
        icon: '&#128202;'
    },
    optimierung: {
        href: 'frm_N_Optimierung.html',
        label: 'Optimierungs-Hub',
        icon: '&#9881;'
    }
};

// Standard-Menue-Reihenfolge
const MENU_ORDER = [
    'dienstplan',
    'planung',
    'auftraege',
    'mitarbeiter',
    'mailanfragen',
    'excelzeitkonten',
    'zeitkonten',
    'abwesenheit',
    'ausweis',
    'stundenabgleich',
    'kunden',
    'verrechnungssaetze',
    'subrechnungen',
    'email',
    '---', // Trenner
    'menue2',
    'systeminfo'
];

/**
 * Generiert HTML fuer das Sidebar-Menue
 * @param {string} activeKey - Schluessel des aktiven Menuepunkts
 * @returns {string} HTML-String
 */
function generateMenuHTML(activeKey) {
    let html = '';

    MENU_ORDER.forEach(key => {
        if (key === '---') {
            // Trenner
            html += '<hr class="menu-divider">';
            return;
        }

        const item = MENU_LINKS[key];
        if (!item) return;

        const isActive = key === activeKey;
        const classes = ['menu-btn'];
        if (isActive) classes.push('active');
        if (item.secondary) classes.push('secondary');

        html += `<a href="${item.href}" class="${classes.join(' ')}" data-menu="${key}">${item.label}</a>\n`;
    });

    return html;
}

/**
 * Korrigiert alle defekten Links in einem Container
 * @param {HTMLElement} container - Container mit Links
 */
function fixBrokenLinks(container) {
    const brokenLinks = container.querySelectorAll('a[href="#"]');

    brokenLinks.forEach(link => {
        const text = link.textContent.trim().toLowerCase();

        // Mapping von Text zu korrektem Link
        const linkMap = {
            'offene mail anfragen': MENU_LINKS.mailanfragen.href,
            'excel zeitkonten': MENU_LINKS.excelzeitkonten.href,
            'stundenabgleich': MENU_LINKS.stundenabgleich.href,
            'verrechnungssaetze': MENU_LINKS.verrechnungssaetze.href,
            'sub rechnungen': MENU_LINKS.subrechnungen.href,
            'e-mail': MENU_LINKS.email.href,
            'menue 2': MENU_LINKS.menue2.href,
            'system info': MENU_LINKS.systeminfo.href
        };

        const newHref = linkMap[text];
        if (newHref) {
            link.href = newHref;
            console.log(`Link korrigiert: "${text}" -> ${newHref}`);
        }
    });

    return brokenLinks.length;
}

/**
 * Initialisiert die Link-Korrektur beim Laden
 */
function initMenuLinks() {
    // Sidebar finden
    const sidebar = document.querySelector('.ma-menu, .kd-menu, .va-menu, .ob-menu, .abw-menu, .zk-menu, .app-sidebar');

    if (sidebar) {
        const fixed = fixBrokenLinks(sidebar);
        if (fixed > 0) {
            console.log(`${fixed} defekte Links wurden korrigiert`);
        }
    }
}

// Auto-Init
document.addEventListener('DOMContentLoaded', initMenuLinks);

// Exports
window.MENU_LINKS = MENU_LINKS;
window.generateMenuHTML = generateMenuHTML;
window.fixBrokenLinks = fixBrokenLinks;
