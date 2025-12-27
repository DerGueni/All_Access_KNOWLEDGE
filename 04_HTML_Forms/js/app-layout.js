/**
 * app-layout.js
 * Einheitliches Layout-Framework für alle Formulare
 */

// Menü-Konfiguration
const MENU_CONFIG = [
    {
        section: 'Stammdaten',
        items: [
            { id: 'mitarbeiter', label: 'Mitarbeiter', form: 'frm_MA_Mitarbeiterstamm.html', icon: '👤' },
            { id: 'kunden', label: 'Kunden', form: 'frm_KD_Kundenstamm.html', icon: '🏢' },
            { id: 'auftraege', label: 'Aufträge', form: 'frm_va_Auftragstamm.html', icon: '📋' }
        ]
    },
    {
        section: 'Planung',
        items: [
            { id: 'dienstplan', label: 'Dienstplan', form: 'frm_N_Dienstplanuebersicht.html', icon: '📅' },
            { id: 'planung', label: 'Planungsübersicht', form: 'frm_VA_Planungsuebersicht.html', icon: '📊' },
            { id: 'einsatz', label: 'Einsatzübersicht', form: 'frm_Einsatzuebersicht.html', icon: '🎯' }
        ]
    },
    {
        section: 'Personal',
        items: [
            { id: 'abwesenheit', label: 'Abwesenheit', form: 'frm_MA_Abwesenheit.html', icon: '🏖️' },
            { id: 'zeitkonten', label: 'Zeitkonten', form: 'frm_MA_Zeitkonten.html', icon: '⏱️' }
        ]
    }
];

/**
 * AppLayout Klasse
 */
class AppLayout {
    constructor(options = {}) {
        this.options = {
            title: options.title || 'Formular',
            theme: options.theme || 'blue',
            activeMenu: options.activeMenu || '',
            showToolbar: options.showToolbar !== false,
            showStats: options.showStats || false,
            onReady: options.onReady || null
        };

        this.init();
    }

    /**
     * Initialisierung
     */
    init() {
        // Warten bis DOM bereit
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.setup());
        } else {
            this.setup();
        }
    }

    /**
     * Layout aufbauen
     */
    setup() {
        // Body-Inhalt sichern
        const originalContent = document.body.innerHTML;

        // Layout erstellen
        document.body.innerHTML = this.createLayoutHTML();
        document.body.classList.add(`theme-${this.options.theme}`);

        // Originalen Inhalt in Content-Bereich einfügen
        const contentMain = document.getElementById('content-main');
        if (contentMain) {
            contentMain.innerHTML = originalContent;
        }

        // Event Listener
        this.setupEventListeners();

        // Datum anzeigen
        this.updateDateTime();
        setInterval(() => this.updateDateTime(), 60000);

        // Ready Callback
        if (this.options.onReady) {
            this.options.onReady();
        }
    }

    /**
     * Layout HTML erstellen
     */
    createLayoutHTML() {
        return `
            <div class="app-container">
                <!-- Sidebar -->
                <aside class="app-sidebar">
                    <div class="sidebar-header">
                        <span class="sidebar-logo">CONSYS</span>
                    </div>
                    <nav class="sidebar-menu">
                        ${this.createMenuHTML()}
                    </nav>
                    <div class="sidebar-footer">
                        <button class="menu-item" id="btn-settings">⚙️ Einstellungen</button>
                        <button class="menu-item" id="btn-logout">🚪 Beenden</button>
                    </div>
                </aside>

                <!-- Main Area -->
                <main class="app-main">
                    <!-- Header -->
                    <header class="app-header">
                        <div class="header-left">
                            <h1 class="app-title">${this.options.title}</h1>
                        </div>
                        <div class="header-center" id="header-center">
                            <!-- Wird von Formular befüllt -->
                        </div>
                        <div class="header-right">
                            <span class="header-info" id="header-info"></span>
                            <span class="header-date" id="header-date"></span>
                        </div>
                    </header>

                    ${this.options.showToolbar ? '<div class="app-toolbar" id="app-toolbar"></div>' : ''}
                    ${this.options.showStats ? '<div class="stats-bar" id="stats-bar"></div>' : ''}

                    <!-- Content -->
                    <div class="app-content">
                        <div class="content-main" id="content-main">
                            <!-- Formular-Inhalt wird hier eingefügt -->
                        </div>
                    </div>

                    <!-- Footer -->
                    <footer class="app-footer">
                        <div class="footer-left">
                            <span class="footer-status" id="footer-status">Bereit</span>
                        </div>
                        <div class="footer-center" id="footer-center">
                            <!-- Zusätzliche Infos -->
                        </div>
                        <div class="footer-right">
                            <span id="footer-record">-</span>
                            <span id="footer-user">Benutzer</span>
                        </div>
                    </footer>
                </main>
            </div>
        `;
    }

    /**
     * Menü HTML erstellen
     */
    createMenuHTML() {
        let html = '';

        MENU_CONFIG.forEach(section => {
            html += `
                <div class="menu-section">
                    <div class="menu-section-title">${section.section}</div>
                    ${section.items.map(item => {
                        const active = item.id === this.options.activeMenu ? 'active' : '';
                        return `
                            <button class="menu-item ${active}" data-form="${item.form}" data-id="${item.id}">
                                ${item.label}
                            </button>
                        `;
                    }).join('')}
                </div>
                <div class="menu-divider"></div>
            `;
        });

        return html;
    }

    /**
     * Event Listener einrichten
     */
    setupEventListeners() {
        // Menü-Navigation
        document.querySelectorAll('.menu-item[data-form]').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const form = e.target.dataset.form;
                if (form) {
                    this.navigateTo(form);
                }
            });
        });

        // Keyboard Shortcuts
        document.addEventListener('keydown', (e) => {
            // Ctrl+M = Menü Toggle
            if (e.ctrlKey && e.key === 'm') {
                e.preventDefault();
                this.toggleSidebar();
            }
        });

        // Resize Handler
        window.addEventListener('resize', () => this.handleResize());
        this.handleResize();
    }

    /**
     * Zu Formular navigieren
     */
    navigateTo(form) {
        // Prüfen ob gleiches Formular
        const currentForm = window.location.pathname.split('/').pop();
        if (currentForm === form) return;

        // Navigation
        window.location.href = form;
    }

    /**
     * Sidebar Toggle
     */
    toggleSidebar() {
        const sidebar = document.querySelector('.app-sidebar');
        sidebar.classList.toggle('collapsed');
    }

    /**
     * Resize Handler
     */
    handleResize() {
        const width = window.innerWidth;
        const sidebar = document.querySelector('.app-sidebar');

        if (width < 1000) {
            sidebar.classList.add('compact');
        } else {
            sidebar.classList.remove('compact');
        }
    }

    /**
     * Datum/Zeit aktualisieren
     */
    updateDateTime() {
        const dateEl = document.getElementById('header-date');
        if (dateEl) {
            const now = new Date();
            dateEl.textContent = now.toLocaleDateString('de-DE', {
                weekday: 'short',
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        }
    }

    /**
     * Status setzen
     */
    setStatus(text) {
        const statusEl = document.getElementById('footer-status');
        if (statusEl) {
            statusEl.textContent = text;
        }
    }

    /**
     * Record-Info setzen
     */
    setRecordInfo(text) {
        const recordEl = document.getElementById('footer-record');
        if (recordEl) {
            recordEl.textContent = text;
        }
    }

    /**
     * Header-Info setzen
     */
    setHeaderInfo(text) {
        const infoEl = document.getElementById('header-info');
        if (infoEl) {
            infoEl.textContent = text;
        }
    }

    /**
     * Toolbar-Inhalt setzen
     */
    setToolbar(html) {
        const toolbar = document.getElementById('app-toolbar');
        if (toolbar) {
            toolbar.innerHTML = html;
        }
    }

    /**
     * Stats-Bar Inhalt setzen
     */
    setStats(statsArray) {
        const statsBar = document.getElementById('stats-bar');
        if (!statsBar) return;

        statsBar.innerHTML = statsArray.map(stat => `
            <div class="stat-item ${stat.class || ''}">
                <span class="stat-value">${stat.value}</span>
                <span class="stat-label">${stat.label}</span>
            </div>
        `).join('');
    }
}

// Global exportieren
window.AppLayout = AppLayout;

// Auto-Init wenn data-app-layout Attribut vorhanden
document.addEventListener('DOMContentLoaded', () => {
    const body = document.body;
    if (body.dataset.appLayout) {
        try {
            const options = JSON.parse(body.dataset.appLayout);
            window.appLayout = new AppLayout(options);
        } catch (e) {
            console.error('AppLayout config error:', e);
        }
    }
});
