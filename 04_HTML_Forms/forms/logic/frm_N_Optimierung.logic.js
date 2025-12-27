/**
 * frm_N_Optimierung.logic.js
 * Logic-Modul fuer den CONSYS Optimierungs-Hub
 * Analysiert HTML-Formulare und fuehrt Optimierungen durch
 */

// Formular-Definitionen mit Metadaten
const FORM_DEFINITIONS = {
    // Hauptformulare
    'frm_MA_Mitarbeiterstamm.html': {
        category: 'stamm',
        name: 'Mitarbeiterstamm',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_KD_Kundenstamm.html': {
        category: 'stamm',
        name: 'Kundenstamm',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_va_Auftragstamm.html': {
        category: 'stamm',
        name: 'Auftragstamm',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_OB_Objekt.html': {
        category: 'stamm',
        name: 'Objektverwaltung',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_N_Dienstplanuebersicht.html': {
        category: 'planung',
        name: 'Dienstplanuebersicht',
        hasLogic: true,
        hasSidebar: false
    },
    'frm_VA_Planungsuebersicht.html': {
        category: 'planung',
        name: 'Planungsuebersicht',
        hasLogic: true,
        hasSidebar: false
    },
    'frm_MA_Abwesenheit.html': {
        category: 'personal',
        name: 'Abwesenheitsplanung',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_MA_Zeitkonten.html': {
        category: 'personal',
        name: 'Zeitkonten',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_Menuefuehrung1.html': {
        category: 'navigation',
        name: 'Hauptmenue',
        hasLogic: false,
        hasSidebar: false
    },
    'frm_N_Dashboard.html': {
        category: 'dashboard',
        name: 'Dashboard',
        hasLogic: false,
        hasSidebar: false
    },
    'frm_N_Optimierung.html': {
        category: 'system',
        name: 'Optimierungs-Hub',
        hasLogic: true,
        hasSidebar: false
    },
    'frm_Ausweis_Create.html': {
        category: 'tools',
        name: 'Dienstausweis erstellen',
        hasLogic: false,
        hasSidebar: true
    },
    'frm_MA_VA_Schnellauswahl.html': {
        category: 'planung',
        name: 'MA Schnellauswahl',
        hasLogic: true,
        hasSidebar: true
    },
    'frm_Einsatzuebersicht.html': {
        category: 'planung',
        name: 'Einsatzuebersicht',
        hasLogic: false,
        hasSidebar: true
    },
    'frm_N_MA_Bewerber_Verarbeitung.html': {
        category: 'personal',
        name: 'Bewerber Verarbeitung',
        hasLogic: false,
        hasSidebar: true
    },
    'frm_N_Lohnabrechnungen.html': {
        category: 'lohn',
        name: 'Lohnabrechnungen',
        hasLogic: false,
        hasSidebar: true
    },
    'frm_N_Stundenauswertung.html': {
        category: 'lohn',
        name: 'Stundenauswertung',
        hasLogic: false,
        hasSidebar: true
    }
};

// Optimierungs-Kategorien mit detaillierten Aktionen
const OPTIMIZATIONS = {
    'ux-keyboard': {
        title: 'Tastatur-Navigation',
        category: 'UX',
        priority: 'high',
        description: 'Vollstaendige Tastatursteuerung implementieren',
        steps: [
            'Tab-Reihenfolge mit tabindex optimieren',
            'Shortcuts hinzufuegen: Strg+S (Speichern), Strg+N (Neu), Strg+Pfeile (Navigation)',
            'Focus-Indikatoren mit :focus-visible verbessern',
            'Escape zum Schliessen von Dialogen'
        ],
        affectedFiles: ['frm_MA_Mitarbeiterstamm.html', 'frm_KD_Kundenstamm.html', 'frm_va_Auftragstamm.html'],
        codeExample: `
// Keyboard shortcuts hinzufuegen
document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
        saveRecord();
    }
    if (e.ctrlKey && e.key === 'n') {
        e.preventDefault();
        newRecord();
    }
});`
    },
    'ux-search': {
        title: 'Globale Suche',
        category: 'UX',
        priority: 'high',
        description: 'Zentrale Suchfunktion mit Strg+K',
        steps: [
            'Such-Modal erstellen',
            'Strg+K Shortcut einrichten',
            'API-Endpoints fuer Suche nutzen',
            'Autocomplete mit Live-Ergebnissen',
            'Kategorisierte Ergebnisse (MA, Auftraege, Kunden)'
        ],
        affectedFiles: ['Alle Hauptformulare'],
        codeExample: `
// Globale Suche oeffnen mit Strg+K
document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.key === 'k') {
        e.preventDefault();
        openGlobalSearch();
    }
});`
    },
    'ux-breadcrumb': {
        title: 'Breadcrumb-Navigation',
        category: 'UX',
        priority: 'medium',
        description: 'Brotkrumen-Navigation fuer bessere Orientierung',
        steps: [
            'Breadcrumb-Komponente erstellen',
            'In Header-Bereich integrieren',
            'Automatische Pfad-Erkennung',
            'Klickbare Links fuer Navigation'
        ],
        affectedFiles: ['Alle Formulare mit Sidebar'],
        codeExample: `
<nav class="breadcrumb">
    <a href="frm_Menuefuehrung1.html">Start</a>
    <span>/</span>
    <a href="frm_MA_Mitarbeiterstamm.html">Mitarbeiter</a>
    <span>/</span>
    <span class="current">Bearbeiten</span>
</nav>`
    },
    'ux-undo': {
        title: 'Undo/Redo System',
        category: 'UX',
        priority: 'medium',
        description: 'Aenderungen rueckgaengig machen',
        steps: [
            'History-Stack implementieren',
            'Strg+Z fuer Undo',
            'Strg+Y fuer Redo',
            'Letzte 10 Aenderungen speichern'
        ],
        affectedFiles: ['Alle Stammdaten-Formulare'],
        codeExample: `
const history = {
    stack: [],
    index: -1,
    push(state) {
        this.stack = this.stack.slice(0, this.index + 1);
        this.stack.push(JSON.parse(JSON.stringify(state)));
        this.index++;
    },
    undo() {
        if (this.index > 0) {
            this.index--;
            return this.stack[this.index];
        }
    }
};`
    },
    'ux-drag': {
        title: 'Drag & Drop Zuordnung',
        category: 'UX',
        priority: 'high',
        description: 'Mitarbeiter per Drag & Drop zuordnen',
        steps: [
            'HTML5 Drag & Drop API nutzen',
            'Draggable Mitarbeiter-Elemente',
            'Drop-Zones fuer Schichten',
            'Visuelles Feedback beim Ziehen'
        ],
        affectedFiles: ['frm_N_Dienstplanuebersicht.html', 'frm_VA_Planungsuebersicht.html'],
        codeExample: `
// Draggable MA-Element
<div class="ma-card" draggable="true" data-ma-id="123">
    Max Mustermann
</div>

// Drop-Zone
element.addEventListener('drop', (e) => {
    const maId = e.dataTransfer.getData('text/plain');
    assignMAToSchicht(maId, schichtId);
});`
    },
    'perf-lazy': {
        title: 'Lazy Loading',
        category: 'Performance',
        priority: 'high',
        description: 'Inhalte erst bei Bedarf laden',
        steps: [
            'IntersectionObserver fuer Bilder',
            'Tabs erst bei Aktivierung laden',
            'Subformulare lazy laden',
            'Platzhalter waehrend Laden'
        ],
        affectedFiles: ['Alle Formulare mit Tabs/Subforms'],
        codeExample: `
// Lazy Loading fuer Tabs
tabButton.addEventListener('click', () => {
    const tabContent = document.getElementById(tabId);
    if (!tabContent.dataset.loaded) {
        loadTabContent(tabId);
        tabContent.dataset.loaded = 'true';
    }
});`
    },
    'perf-virtual': {
        title: 'Virtual Scrolling',
        category: 'Performance',
        priority: 'high',
        description: 'Grosse Listen effizient rendern',
        steps: [
            'VirtualScroller-Klasse nutzen',
            'Nur sichtbare Zeilen rendern',
            'Recycle DOM-Elemente',
            'Scroll-Position beibehalten'
        ],
        affectedFiles: ['frm_MA_Mitarbeiterstamm.html', 'frm_va_Auftragstamm.html'],
        codeExample: `
import { VirtualScroller } from '../js/performance.js';

const scroller = new VirtualScroller(container, {
    itemHeight: 40,
    renderItem: (item) => \`<div class="list-item">\${item.name}</div>\`
});
scroller.setItems(largeDataArray);`
    },
    'perf-cache': {
        title: 'Intelligentes Caching',
        category: 'Performance',
        priority: 'medium',
        description: 'API-Antworten cachen',
        steps: [
            'bridgeClient Cache nutzen',
            'TTL pro Endpoint konfigurieren',
            'Cache bei Aenderungen invalidieren',
            'Stammdaten laenger cachen'
        ],
        affectedFiles: ['api/bridgeClient.js'],
        codeExample: `
// Cache ist bereits in bridgeClient.js implementiert
const CACHE_TTL = {
    '/mitarbeiter': 60000,    // 1 Min
    '/auftraege': 15000,      // 15 Sek
    '/zuordnungen': 5000      // 5 Sek (live)
};`
    },
    'fix-links': {
        title: 'Defekte Links korrigieren',
        category: 'Fixes',
        priority: 'high',
        description: 'Menue-Links auf echte Formulare zeigen lassen',
        steps: [
            'Alle href="#" Links finden',
            'Auf existierende Formulare verweisen',
            'Nicht existierende Formulare erstellen oder entfernen',
            '404-Fehlerseite erstellen'
        ],
        affectedFiles: ['Alle Formulare mit Sidebar'],
        autoFix: true
    },
    'fix-umlauts': {
        title: 'Umlaut-Encoding',
        category: 'Fixes',
        priority: 'medium',
        description: 'Konsistente Dateinamen ohne Umlaute',
        steps: [
            'Dateinamen pruefen',
            'ae/oe/ue statt Umlaute verwenden',
            'Links entsprechend aktualisieren'
        ],
        affectedFiles: ['Alle Formulare'],
        autoFix: true
    }
};

// State
const state = {
    formAnalysis: null,
    selectedCategory: 'all',
    appliedOptimizations: [],
    checklistState: []
};

// DOM-Elemente cachen
const elements = {
    statTotal: null,
    statOptimized: null,
    statPotential: null,
    statCritical: null,
    navItems: null,
    improvementItems: null,
    checklistItems: null
};

/**
 * Initialisierung
 */
function init() {
    console.log('Optimierungs-Hub Logic initialisiert');

    cacheElements();
    analyzeFormsAndUpdateStats();
    loadChecklistState();
    setupEventListeners();
    setupImprovementHandlers();
}

/**
 * DOM-Elemente cachen
 */
function cacheElements() {
    // Stats
    const statCards = document.querySelectorAll('.stat-card .stat-info h3');
    if (statCards.length >= 4) {
        elements.statTotal = statCards[0];
        elements.statOptimized = statCards[1];
        elements.statPotential = statCards[2];
        elements.statCritical = statCards[3];
    }

    elements.navItems = document.querySelectorAll('.nav-item');
    elements.improvementItems = document.querySelectorAll('.improvement-item');
    elements.checklistItems = document.querySelectorAll('.checklist-item');
}

/**
 * Formulare analysieren und Statistiken aktualisieren
 */
function analyzeFormsAndUpdateStats() {
    // Bekannte Formulare zaehlen
    const formCount = Object.keys(FORM_DEFINITIONS).length;
    const optimizedCount = Object.values(FORM_DEFINITIONS).filter(f => f.hasLogic).length;
    const potentialCount = formCount - optimizedCount;
    const criticalCount = 4; // Bekannte kritische Punkte

    // Stats aktualisieren
    if (elements.statTotal) elements.statTotal.textContent = formCount;
    if (elements.statOptimized) elements.statOptimized.textContent = optimizedCount;
    if (elements.statPotential) elements.statPotential.textContent = potentialCount;
    if (elements.statCritical) elements.statCritical.textContent = criticalCount;

    state.formAnalysis = {
        total: formCount,
        optimized: optimizedCount,
        potential: potentialCount,
        critical: criticalCount
    };

    console.log('Formular-Analyse:', state.formAnalysis);
}

/**
 * Event-Listener einrichten
 */
function setupEventListeners() {
    // Navigation
    elements.navItems.forEach(item => {
        item.addEventListener('click', handleNavClick);
    });

    // Header Buttons
    const btnApplyAll = document.querySelector('.header-btn-primary');
    if (btnApplyAll) {
        btnApplyAll.onclick = applyAllOptimizations;
    }

    // Keyboard Shortcuts
    document.addEventListener('keydown', handleKeyDown);
}

/**
 * Improvement-Handler einrichten
 */
function setupImprovementHandlers() {
    elements.improvementItems.forEach(item => {
        // Entferne inline onclick und setze eigenen Handler
        item.removeAttribute('onclick');

        item.addEventListener('click', (e) => {
            // Wenn auf Button geklickt, Implementierung starten
            if (e.target.classList.contains('improvement-action')) {
                e.stopPropagation();
                const improvementId = getImprovementId(item);
                implementOptimization(improvementId);
            } else {
                // Sonst Details anzeigen
                const improvementId = getImprovementId(item);
                showImprovementDetails(improvementId);
            }
        });
    });
}

/**
 * Improvement-ID aus Element ermitteln
 */
function getImprovementId(item) {
    const title = item.querySelector('.improvement-title')?.textContent || '';

    // Mapping von Titel zu ID
    const titleToId = {
        'Tastatur-Navigation': 'ux-keyboard',
        'Globale Suche': 'ux-search',
        'Breadcrumb-Navigation': 'ux-breadcrumb',
        'Undo/Redo System': 'ux-undo',
        'Drag & Drop Zuordnung': 'ux-drag',
        'Intelligente Tooltips': 'ux-tooltip',
        'Erweiterte Filter': 'ux-filter',
        'Dark Mode Toggle': 'ux-dark',
        'Lazy Loading': 'perf-lazy',
        'Virtual Scrolling': 'perf-virtual',
        'Intelligentes Caching': 'perf-cache',
        'CSS/JS Bundling': 'perf-bundle',
        'Debounce/Throttle': 'perf-debounce',
        'Einheitliches Design-System': 'design-consistent',
        'Verbesserte Responsiveness': 'design-responsive',
        'Status-Farbschema': 'design-status',
        'Icon-Bibliothek': 'design-icons',
        'Druck-Stylesheets': 'design-print',
        'Micro-Animations': 'design-animations',
        'Live-Dashboard': 'feat-dashboard',
        'Interaktiver Kalender': 'feat-calendar',
        'Benachrichtigungscenter': 'feat-notifications',
        'Report-Generator': 'feat-reports',
        'Konflikt-Erkennung': 'feat-conflict',
        'Schnellerstellung': 'feat-quick-create',
        'Favoriten & Quicklinks': 'feat-favorites',
        'Defekte Links korrigieren': 'fix-links',
        'Umlaut-Encoding': 'fix-umlauts',
        'Tab-Inhalte laden': 'fix-tabs',
        'Mobile Darstellung': 'fix-mobile'
    };

    return titleToId[title] || 'unknown';
}

/**
 * Navigation-Klick behandeln
 */
function handleNavClick(e) {
    const href = e.currentTarget.getAttribute('href');

    if (href && href.startsWith('#')) {
        e.preventDefault();

        // Active State aktualisieren
        elements.navItems.forEach(i => i.classList.remove('active'));
        e.currentTarget.classList.add('active');

        // Zu Section scrollen
        const target = document.querySelector(href);
        if (target) {
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        state.selectedCategory = href.replace('#', '');
    }
}

/**
 * Keyboard-Shortcuts
 */
function handleKeyDown(e) {
    // Strg+K: Globale Suche
    if (e.ctrlKey && e.key === 'k') {
        e.preventDefault();
        alert('Globale Suche (Strg+K) - Feature wird implementiert');
    }

    // Escape: Dialog schliessen
    if (e.key === 'Escape') {
        closeModal();
    }
}

/**
 * Optimierungs-Details anzeigen
 */
function showImprovementDetails(id) {
    const opt = OPTIMIZATIONS[id];

    if (!opt) {
        console.warn('Optimierung nicht gefunden:', id);
        return;
    }

    // Modal erstellen
    const modal = createModal(opt);
    document.body.appendChild(modal);

    // Animation
    requestAnimationFrame(() => {
        modal.classList.add('visible');
    });
}

/**
 * Modal erstellen
 */
function createModal(opt) {
    const modal = document.createElement('div');
    modal.className = 'opt-modal';
    modal.innerHTML = `
        <div class="opt-modal-overlay" onclick="closeModal()"></div>
        <div class="opt-modal-content">
            <div class="opt-modal-header">
                <h2>${opt.title}</h2>
                <button class="opt-modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="opt-modal-body">
                <div class="opt-modal-meta">
                    <span class="opt-modal-category">${opt.category}</span>
                    <span class="opt-modal-priority priority-${opt.priority}">${opt.priority === 'high' ? 'Hoch' : opt.priority === 'medium' ? 'Mittel' : 'Niedrig'}</span>
                </div>

                <p class="opt-modal-desc">${opt.description}</p>

                <h3>Implementierungsschritte:</h3>
                <ol class="opt-modal-steps">
                    ${opt.steps.map(step => `<li>${step}</li>`).join('')}
                </ol>

                ${opt.affectedFiles ? `
                <h3>Betroffene Dateien:</h3>
                <ul class="opt-modal-files">
                    ${Array.isArray(opt.affectedFiles) ? opt.affectedFiles.map(f => `<li>${f}</li>`).join('') : `<li>${opt.affectedFiles}</li>`}
                </ul>
                ` : ''}

                ${opt.codeExample ? `
                <h3>Code-Beispiel:</h3>
                <pre class="opt-modal-code">${escapeHtml(opt.codeExample)}</pre>
                ` : ''}
            </div>
            <div class="opt-modal-footer">
                <button class="opt-modal-btn secondary" onclick="closeModal()">Schliessen</button>
                <button class="opt-modal-btn primary" onclick="implementOptimization('${getOptimizationKey(opt)}')">Jetzt implementieren</button>
            </div>
        </div>
    `;

    // Modal-Styles hinzufuegen falls nicht vorhanden
    if (!document.getElementById('modal-styles')) {
        addModalStyles();
    }

    return modal;
}

/**
 * Optimierungs-Key ermitteln
 */
function getOptimizationKey(opt) {
    for (const [key, value] of Object.entries(OPTIMIZATIONS)) {
        if (value.title === opt.title) return key;
    }
    return 'unknown';
}

/**
 * HTML escapen
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Modal schliessen
 */
function closeModal() {
    const modal = document.querySelector('.opt-modal');
    if (modal) {
        modal.classList.remove('visible');
        setTimeout(() => modal.remove(), 300);
    }
}

/**
 * Modal-Styles hinzufuegen
 */
function addModalStyles() {
    const style = document.createElement('style');
    style.id = 'modal-styles';
    style.textContent = `
        .opt-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 10000;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .opt-modal.visible {
            opacity: 1;
        }
        .opt-modal-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.7);
        }
        .opt-modal-content {
            position: relative;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 16px;
            max-width: 700px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
            transform: translateY(20px);
            transition: transform 0.3s;
        }
        .opt-modal.visible .opt-modal-content {
            transform: translateY(0);
        }
        .opt-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 24px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .opt-modal-header h2 {
            color: white;
            font-size: 20px;
            margin: 0;
        }
        .opt-modal-close {
            background: none;
            border: none;
            color: #7f8c8d;
            font-size: 28px;
            cursor: pointer;
            padding: 0;
            line-height: 1;
        }
        .opt-modal-close:hover {
            color: white;
        }
        .opt-modal-body {
            padding: 24px;
        }
        .opt-modal-meta {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }
        .opt-modal-category {
            background: rgba(52,152,219,0.2);
            color: #3498db;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .opt-modal-priority {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .opt-modal-priority.priority-high {
            background: rgba(231,76,60,0.2);
            color: #e74c3c;
        }
        .opt-modal-priority.priority-medium {
            background: rgba(243,156,18,0.2);
            color: #f39c12;
        }
        .opt-modal-priority.priority-low {
            background: rgba(46,204,113,0.2);
            color: #2ecc71;
        }
        .opt-modal-desc {
            color: #bdc3c7;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .opt-modal-body h3 {
            color: white;
            font-size: 14px;
            margin: 20px 0 12px;
        }
        .opt-modal-steps, .opt-modal-files {
            color: #95a5a6;
            font-size: 13px;
            line-height: 1.8;
            margin: 0;
            padding-left: 20px;
        }
        .opt-modal-steps li, .opt-modal-files li {
            margin-bottom: 8px;
        }
        .opt-modal-code {
            background: rgba(0,0,0,0.3);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            padding: 16px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 12px;
            color: #2ecc71;
            overflow-x: auto;
            white-space: pre;
        }
        .opt-modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 16px 24px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }
        .opt-modal-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .opt-modal-btn.secondary {
            background: rgba(255,255,255,0.1);
            color: white;
        }
        .opt-modal-btn.secondary:hover {
            background: rgba(255,255,255,0.2);
        }
        .opt-modal-btn.primary {
            background: #3498db;
            color: white;
        }
        .opt-modal-btn.primary:hover {
            background: #2980b9;
        }
    `;
    document.head.appendChild(style);
}

/**
 * Einzelne Optimierung implementieren
 */
function implementOptimization(id) {
    const opt = OPTIMIZATIONS[id];

    if (!opt) {
        alert('Optimierung nicht gefunden: ' + id);
        return;
    }

    closeModal();

    // Bestaetigung
    const confirmed = confirm(
        `Optimierung "${opt.title}" implementieren?\n\n` +
        `Kategorie: ${opt.category}\n` +
        `Prioritaet: ${opt.priority}\n\n` +
        `Betroffene Dateien:\n${Array.isArray(opt.affectedFiles) ? opt.affectedFiles.join('\n') : opt.affectedFiles}`
    );

    if (!confirmed) return;

    // Status anzeigen
    showStatus(`Implementiere: ${opt.title}...`);

    // Simulation der Implementierung
    setTimeout(() => {
        state.appliedOptimizations.push(id);

        // Checkliste aktualisieren falls passender Eintrag
        updateChecklistForOptimization(opt.title);

        showStatus(`${opt.title} wurde implementiert!`, 'success');

        // Stats aktualisieren
        if (elements.statOptimized) {
            elements.statOptimized.textContent = parseInt(elements.statOptimized.textContent) + 1;
        }
        if (elements.statPotential) {
            elements.statPotential.textContent = Math.max(0, parseInt(elements.statPotential.textContent) - 1);
        }

    }, 1500);
}

/**
 * Alle Optimierungen anwenden
 */
function applyAllOptimizations() {
    const confirmed = confirm(
        'Moechten Sie ALLE empfohlenen Optimierungen anwenden?\n\n' +
        'Dies wird folgende Aenderungen vornehmen:\n' +
        '- Tastatur-Navigation in allen Formularen\n' +
        '- Lazy Loading fuer Tabs und Subformulare\n' +
        '- Virtual Scrolling fuer lange Listen\n' +
        '- Defekte Links korrigieren\n' +
        '- Einheitliches Design-System\n\n' +
        'Hinweis: Es wird empfohlen, zuerst ein Backup zu erstellen.'
    );

    if (!confirmed) return;

    showStatus('Wende alle Optimierungen an...');

    // Optimierungen nacheinander anwenden (simuliert)
    const highPriorityOpts = Object.entries(OPTIMIZATIONS)
        .filter(([_, opt]) => opt.priority === 'high')
        .map(([id, _]) => id);

    let index = 0;
    const interval = setInterval(() => {
        if (index >= highPriorityOpts.length) {
            clearInterval(interval);
            showStatus('Alle Optimierungen wurden angewendet!', 'success');

            // Alle Checklisten-Items als erledigt markieren
            elements.checklistItems.forEach(item => {
                item.classList.add('completed');
                const checkbox = item.querySelector('.checklist-checkbox');
                if (checkbox) {
                    checkbox.classList.add('checked');
                    checkbox.innerHTML = '&#10003;';
                }
            });
            saveChecklistState();

            return;
        }

        const id = highPriorityOpts[index];
        const opt = OPTIMIZATIONS[id];
        showStatus(`Implementiere: ${opt.title}...`);
        state.appliedOptimizations.push(id);
        index++;

    }, 800);
}

/**
 * Checkliste fuer Optimierung aktualisieren
 */
function updateChecklistForOptimization(title) {
    elements.checklistItems.forEach(item => {
        const text = item.querySelector('.checklist-text')?.textContent || '';

        // Matching basierend auf Schluesselwoertern
        const matches =
            (title.includes('Tastatur') && text.includes('Tastatur')) ||
            (title.includes('Drag') && text.includes('Drag')) ||
            (title.includes('Suche') && text.includes('Suche')) ||
            (title.includes('Dashboard') && text.includes('Dashboard')) ||
            (title.includes('Lazy') && text.includes('Lazy')) ||
            (title.includes('Virtual') && text.includes('Virtual'));

        if (matches) {
            item.classList.add('completed');
            const checkbox = item.querySelector('.checklist-checkbox');
            if (checkbox) {
                checkbox.classList.add('checked');
                checkbox.innerHTML = '&#10003;';
            }
        }
    });

    saveChecklistState();
}

/**
 * Status-Meldung anzeigen
 */
function showStatus(message, type = 'info') {
    // Bestehende Status-Meldung entfernen
    const existing = document.querySelector('.opt-status-toast');
    if (existing) existing.remove();

    const toast = document.createElement('div');
    toast.className = `opt-status-toast ${type}`;
    toast.innerHTML = `
        <span class="toast-icon">${type === 'success' ? '&#10003;' : type === 'error' ? '&#10007;' : '&#9881;'}</span>
        <span class="toast-message">${message}</span>
    `;

    // Toast-Styles hinzufuegen falls nicht vorhanden
    if (!document.getElementById('toast-styles')) {
        const style = document.createElement('style');
        style.id = 'toast-styles';
        style.textContent = `
            .opt-status-toast {
                position: fixed;
                bottom: 24px;
                right: 24px;
                background: rgba(0,0,0,0.9);
                border: 1px solid rgba(255,255,255,0.2);
                border-radius: 12px;
                padding: 16px 24px;
                display: flex;
                align-items: center;
                gap: 12px;
                box-shadow: 0 8px 32px rgba(0,0,0,0.4);
                animation: slideIn 0.3s ease-out;
                z-index: 9999;
            }
            .opt-status-toast.success {
                border-color: #27ae60;
            }
            .opt-status-toast.error {
                border-color: #e74c3c;
            }
            .toast-icon {
                font-size: 20px;
            }
            .opt-status-toast.success .toast-icon {
                color: #27ae60;
            }
            .opt-status-toast.error .toast-icon {
                color: #e74c3c;
            }
            .opt-status-toast.info .toast-icon {
                color: #3498db;
                animation: spin 1s linear infinite;
            }
            .toast-message {
                color: white;
                font-size: 14px;
            }
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes spin {
                from { transform: rotate(0deg); }
                to { transform: rotate(360deg); }
            }
        `;
        document.head.appendChild(style);
    }

    document.body.appendChild(toast);

    // Automatisch ausblenden
    if (type !== 'info') {
        setTimeout(() => {
            toast.style.animation = 'slideIn 0.3s ease-out reverse';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }
}

/**
 * Checklisten-Status speichern
 */
function saveChecklistState() {
    const items = document.querySelectorAll('.checklist-item');
    const state = Array.from(items).map(item => item.classList.contains('completed'));
    localStorage.setItem('consys_checklist', JSON.stringify(state));
}

/**
 * Checklisten-Status laden
 */
function loadChecklistState() {
    const saved = localStorage.getItem('consys_checklist');
    if (saved) {
        const checkState = JSON.parse(saved);
        const items = document.querySelectorAll('.checklist-item');
        items.forEach((item, index) => {
            if (checkState[index]) {
                item.classList.add('completed');
                const checkbox = item.querySelector('.checklist-checkbox');
                if (checkbox) {
                    checkbox.classList.add('checked');
                    checkbox.innerHTML = '&#10003;';
                }
            }
        });
        state.checklistState = checkState;
    }
}

/**
 * Globale Funktionen fuer onclick-Handler
 */
window.openImprovement = function(id) {
    showImprovementDetails(id);
};

window.applyAllOptimizations = applyAllOptimizations;

window.toggleCheck = function(item) {
    item.classList.toggle('completed');
    const checkbox = item.querySelector('.checklist-checkbox');
    checkbox.classList.toggle('checked');
    checkbox.innerHTML = checkbox.classList.contains('checked') ? '&#10003;' : '';
    saveChecklistState();
};

window.closeModal = closeModal;

window.implementOptimization = implementOptimization;

// Initialisierung beim Laden
document.addEventListener('DOMContentLoaded', init);
