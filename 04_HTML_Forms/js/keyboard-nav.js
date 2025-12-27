/**
 * CONSYS Keyboard Navigation Module
 * Verbesserte Tastatursteuerung fuer alle Formulare
 */

class KeyboardNav {
    constructor() {
        this.shortcuts = new Map();
        this.focusableSelector = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
        this.init();
    }

    init() {
        // Standard-Shortcuts registrieren
        this.registerDefaults();

        // Event Listener
        document.addEventListener('keydown', this.handleKeyDown.bind(this));

        // Focus-Indicator verbessern
        this.enhanceFocusIndicator();
    }

    registerDefaults() {
        // Navigation
        this.register('ctrl+k', () => {
            if (window.globalSearch) {
                window.globalSearch.open();
            }
        }, 'Globale Suche oeffnen');

        this.register('ctrl+s', (e) => {
            e.preventDefault();
            this.triggerSave();
        }, 'Speichern');

        this.register('ctrl+n', (e) => {
            e.preventDefault();
            this.triggerNew();
        }, 'Neu erstellen');

        this.register('ctrl+z', (e) => {
            // Standard-Undo erlauben in Eingabefeldern
            if (!this.isInInput()) {
                e.preventDefault();
                this.triggerUndo();
            }
        }, 'Rueckgaengig');

        this.register('alt+1', () => this.navigateTo('frm_N_Dashboard.html'), 'Dashboard');
        this.register('alt+2', () => this.navigateTo('frm_N_Dienstplanuebersicht.html'), 'Dienstplan');
        this.register('alt+3', () => this.navigateTo('frm_VA_Planungsuebersicht.html'), 'Planung');
        this.register('alt+4', () => this.navigateTo('frm_va_Auftragstamm.html'), 'Auftraege');
        this.register('alt+5', () => this.navigateTo('frm_MA_Mitarbeiterstamm.html'), 'Mitarbeiter');

        // Tab-Navigation
        this.register('ctrl+tab', (e) => {
            e.preventDefault();
            this.nextTab();
        }, 'Naechster Tab');

        this.register('ctrl+shift+tab', (e) => {
            e.preventDefault();
            this.prevTab();
        }, 'Vorheriger Tab');

        // Datensatz-Navigation
        this.register('alt+left', (e) => {
            e.preventDefault();
            this.prevRecord();
        }, 'Vorheriger Datensatz');

        this.register('alt+right', (e) => {
            e.preventDefault();
            this.nextRecord();
        }, 'Naechster Datensatz');

        this.register('alt+home', (e) => {
            e.preventDefault();
            this.firstRecord();
        }, 'Erster Datensatz');

        this.register('alt+end', (e) => {
            e.preventDefault();
            this.lastRecord();
        }, 'Letzter Datensatz');

        // Hilfe
        this.register('f1', (e) => {
            e.preventDefault();
            this.showHelp();
        }, 'Hilfe anzeigen');

        this.register('shift+/', (e) => {
            if (!this.isInInput()) {
                e.preventDefault();
                this.showHelp();
            }
        }, 'Shortcuts anzeigen');
    }

    register(shortcut, callback, description = '') {
        this.shortcuts.set(shortcut.toLowerCase(), { callback, description });
    }

    handleKeyDown(e) {
        const key = this.getKeyString(e);
        const handler = this.shortcuts.get(key);

        if (handler) {
            handler.callback(e);
        }
    }

    getKeyString(e) {
        const parts = [];
        if (e.ctrlKey) parts.push('ctrl');
        if (e.altKey) parts.push('alt');
        if (e.shiftKey) parts.push('shift');
        parts.push(e.key.toLowerCase());
        return parts.join('+');
    }

    isInInput() {
        const active = document.activeElement;
        return active && (
            active.tagName === 'INPUT' ||
            active.tagName === 'TEXTAREA' ||
            active.isContentEditable
        );
    }

    // Actions
    triggerSave() {
        const saveBtn = document.querySelector('[id*="btnSpeichern"], [id*="btnSave"], .btn-save, .btn-primary');
        if (saveBtn) {
            saveBtn.click();
            this.showNotification('Speichern...');
        }
    }

    triggerNew() {
        const newBtn = document.querySelector('[id*="btnNeu"], [id*="btnNew"], .btn-new');
        if (newBtn) {
            newBtn.click();
        }
    }

    triggerUndo() {
        // Custom Undo-System
        if (window.undoManager) {
            window.undoManager.undo();
        }
    }

    navigateTo(url) {
        window.location.href = url;
    }

    nextTab() {
        const tabs = document.querySelectorAll('.tab-btn, [role="tab"]');
        const activeTab = document.querySelector('.tab-btn.active, [role="tab"][aria-selected="true"]');
        if (tabs.length && activeTab) {
            const index = Array.from(tabs).indexOf(activeTab);
            const nextIndex = (index + 1) % tabs.length;
            tabs[nextIndex].click();
        }
    }

    prevTab() {
        const tabs = document.querySelectorAll('.tab-btn, [role="tab"]');
        const activeTab = document.querySelector('.tab-btn.active, [role="tab"][aria-selected="true"]');
        if (tabs.length && activeTab) {
            const index = Array.from(tabs).indexOf(activeTab);
            const prevIndex = (index - 1 + tabs.length) % tabs.length;
            tabs[prevIndex].click();
        }
    }

    prevRecord() {
        const btn = document.querySelector('[id*="btnVorheriger"], [id*="btnPrev"], .btn-prev');
        if (btn) btn.click();
    }

    nextRecord() {
        const btn = document.querySelector('[id*="btnNaechster"], [id*="btnNext"], .btn-next');
        if (btn) btn.click();
    }

    firstRecord() {
        const btn = document.querySelector('[id*="btnErster"], [id*="btnFirst"], .btn-first');
        if (btn) btn.click();
    }

    lastRecord() {
        const btn = document.querySelector('[id*="btnLetzter"], [id*="btnLast"], .btn-last');
        if (btn) btn.click();
    }

    showHelp() {
        this.createHelpModal();
    }

    enhanceFocusIndicator() {
        const style = document.createElement('style');
        style.textContent = `
            *:focus {
                outline: 2px solid #3498db !important;
                outline-offset: 2px !important;
            }

            *:focus:not(:focus-visible) {
                outline: none !important;
            }

            *:focus-visible {
                outline: 2px solid #3498db !important;
                outline-offset: 2px !important;
            }

            .skip-link {
                position: absolute;
                top: -40px;
                left: 0;
                background: #3498db;
                color: white;
                padding: 8px 16px;
                z-index: 100000;
                transition: top 0.2s;
            }

            .skip-link:focus {
                top: 0;
            }
        `;
        document.head.appendChild(style);

        // Skip-Link hinzufuegen
        const skipLink = document.createElement('a');
        skipLink.href = '#main-content';
        skipLink.className = 'skip-link';
        skipLink.textContent = 'Zum Hauptinhalt springen';
        document.body.insertBefore(skipLink, document.body.firstChild);
    }

    createHelpModal() {
        // Modal entfernen falls vorhanden
        const existing = document.querySelector('.kb-help-modal');
        if (existing) {
            existing.remove();
            return;
        }

        const modal = document.createElement('div');
        modal.className = 'kb-help-modal';
        modal.innerHTML = `
            <div class="kb-help-backdrop"></div>
            <div class="kb-help-content">
                <div class="kb-help-header">
                    <h2>Tastaturkuerzel</h2>
                    <button class="kb-help-close">&times;</button>
                </div>
                <div class="kb-help-body">
                    <div class="kb-help-section">
                        <h3>Allgemein</h3>
                        <div class="kb-help-item"><kbd>Strg</kbd> + <kbd>K</kbd> <span>Globale Suche</span></div>
                        <div class="kb-help-item"><kbd>Strg</kbd> + <kbd>S</kbd> <span>Speichern</span></div>
                        <div class="kb-help-item"><kbd>Strg</kbd> + <kbd>N</kbd> <span>Neu erstellen</span></div>
                        <div class="kb-help-item"><kbd>Strg</kbd> + <kbd>Z</kbd> <span>Rueckgaengig</span></div>
                        <div class="kb-help-item"><kbd>F1</kbd> / <kbd>?</kbd> <span>Hilfe</span></div>
                    </div>
                    <div class="kb-help-section">
                        <h3>Navigation</h3>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>1</kbd> <span>Dashboard</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>2</kbd> <span>Dienstplan</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>3</kbd> <span>Planung</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>4</kbd> <span>Auftraege</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>5</kbd> <span>Mitarbeiter</span></div>
                    </div>
                    <div class="kb-help-section">
                        <h3>Datensaetze</h3>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>&#8592;</kbd> <span>Vorheriger</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>&#8594;</kbd> <span>Naechster</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>Pos1</kbd> <span>Erster</span></div>
                        <div class="kb-help-item"><kbd>Alt</kbd> + <kbd>Ende</kbd> <span>Letzter</span></div>
                    </div>
                    <div class="kb-help-section">
                        <h3>Tabs</h3>
                        <div class="kb-help-item"><kbd>Strg</kbd> + <kbd>Tab</kbd> <span>Naechster Tab</span></div>
                        <div class="kb-help-item"><kbd>Strg</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> <span>Vorheriger Tab</span></div>
                    </div>
                </div>
            </div>
        `;

        const style = document.createElement('style');
        style.textContent = `
            .kb-help-modal {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                z-index: 10001;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .kb-help-backdrop {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(4px);
            }

            .kb-help-content {
                position: relative;
                width: 600px;
                max-width: 90vw;
                max-height: 80vh;
                background: #1a1a2e;
                border: 1px solid rgba(255, 255, 255, 0.15);
                border-radius: 12px;
                overflow: hidden;
                animation: kb-fade-in 0.2s ease-out;
            }

            @keyframes kb-fade-in {
                from { opacity: 0; transform: scale(0.95); }
                to { opacity: 1; transform: scale(1); }
            }

            .kb-help-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 16px 20px;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            }

            .kb-help-header h2 {
                color: white;
                font-size: 18px;
                font-weight: 600;
            }

            .kb-help-close {
                background: none;
                border: none;
                color: #7f8c8d;
                font-size: 24px;
                cursor: pointer;
                padding: 0;
                line-height: 1;
            }

            .kb-help-close:hover {
                color: white;
            }

            .kb-help-body {
                padding: 20px;
                overflow-y: auto;
                max-height: calc(80vh - 60px);
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 24px;
            }

            .kb-help-section h3 {
                color: #7f8c8d;
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 12px;
            }

            .kb-help-item {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 8px;
                color: #ecf0f1;
                font-size: 13px;
            }

            .kb-help-item kbd {
                background: rgba(255, 255, 255, 0.1);
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 11px;
                min-width: 28px;
                text-align: center;
            }

            .kb-help-item span {
                margin-left: auto;
                color: #7f8c8d;
            }
        `;

        document.head.appendChild(style);
        document.body.appendChild(modal);

        // Event Listener
        modal.querySelector('.kb-help-backdrop').addEventListener('click', () => modal.remove());
        modal.querySelector('.kb-help-close').addEventListener('click', () => modal.remove());
        document.addEventListener('keydown', function closeOnEsc(e) {
            if (e.key === 'Escape') {
                modal.remove();
                document.removeEventListener('keydown', closeOnEsc);
            }
        });
    }

    showNotification(message) {
        const existing = document.querySelector('.kb-notification');
        if (existing) existing.remove();

        const notification = document.createElement('div');
        notification.className = 'kb-notification';
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #27ae60;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 13px;
            z-index: 10000;
            animation: kb-slide-up 0.3s ease-out;
        `;

        const style = document.createElement('style');
        style.textContent = `
            @keyframes kb-slide-up {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }
        `;
        document.head.appendChild(style);
        document.body.appendChild(notification);

        setTimeout(() => notification.remove(), 2000);
    }
}

// Auto-initialize
document.addEventListener('DOMContentLoaded', () => {
    window.keyboardNav = new KeyboardNav();
});

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = KeyboardNav;
}
