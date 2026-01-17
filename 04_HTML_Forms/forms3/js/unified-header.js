/**
 * UNIFIED HEADER - JavaScript Helper
 *
 * Erstellt: 15.01.2026
 * Zweck: Dynamische Header-Verwaltung für HTML-Formulare
 *
 * Verwendung:
 * <script src="js/unified-header.js"></script>
 * <script>
 *   const header = new UnifiedHeader({
 *     title: 'Auftragsverwaltung',
 *     buttons: ['refresh', 'new', 'delete'],
 *     onRefresh: () => loadData(),
 *     onNew: () => createRecord(),
 *     onDelete: () => deleteRecord()
 *   });
 * </script>
 */

'use strict';

class UnifiedHeader {
    /**
     * Erstellt einen neuen Unified Header
     * @param {Object} options - Konfigurationsobjekt
     * @param {string} options.title - Formulartitel
     * @param {Array<string>} options.buttons - Button-Liste: ['refresh', 'new', 'copy', 'delete', 'save', 'close']
     * @param {string} [options.variant='standard'] - Header-Variante: 'standard', 'compact', 'extended', 'readonly', 'minimal'
     * @param {boolean} [options.showStatus=false] - Status-Badge anzeigen
     * @param {string} [options.statusText=''] - Status-Text
     * @param {string} [options.statusType=''] - Status-Typ: 'active', 'inactive', 'pending'
     * @param {boolean} [options.showFilters=false] - Filter-Zeile anzeigen
     * @param {Function} [options.onRefresh] - Callback für Aktualisieren-Button
     * @param {Function} [options.onNew] - Callback für Neu-Button
     * @param {Function} [options.onCopy] - Callback für Kopieren-Button
     * @param {Function} [options.onDelete] - Callback für Löschen-Button
     * @param {Function} [options.onSave] - Callback für Speichern-Button
     * @param {Function} [options.onClose] - Callback für Schließen-Button
     */
    constructor(options = {}) {
        this.options = {
            title: options.title || 'Formular',
            buttons: options.buttons || ['refresh', 'new', 'delete'],
            variant: options.variant || 'standard',
            showStatus: options.showStatus || false,
            statusText: options.statusText || '',
            statusType: options.statusType || '',
            showFilters: options.showFilters || false,
            onRefresh: options.onRefresh || null,
            onNew: options.onNew || null,
            onCopy: options.onCopy || null,
            onDelete: options.onDelete || null,
            onSave: options.onSave || null,
            onClose: options.onClose || null
        };

        this.container = null;
        this.titleElement = null;
        this.controlsElement = null;
        this.statusElement = null;
        this.filtersElement = null;
        this.buttons = {};

        this.init();
    }

    /**
     * Initialisiert den Header
     */
    init() {
        // Header-Container erstellen
        this.container = document.createElement('div');
        this.container.className = 'form-header-unified';

        // Variante anwenden
        if (this.options.variant !== 'standard') {
            this.container.classList.add(this.options.variant);
        }

        // Titel erstellen
        this.createTitle();

        // Status-Badge erstellen (falls gewünscht)
        if (this.options.showStatus) {
            this.createStatus();
        }

        // Buttons erstellen
        this.createButtons();

        // Filter erstellen (falls gewünscht)
        if (this.options.showFilters) {
            this.createFilters();
        }

        // In DOM einfügen (am Anfang des Body)
        document.body.insertBefore(this.container, document.body.firstChild);
    }

    /**
     * Erstellt den Titel
     */
    createTitle() {
        this.titleElement = document.createElement('h1');
        this.titleElement.className = 'form-title-unified';
        this.titleElement.textContent = this.options.title;
        this.container.appendChild(this.titleElement);
    }

    /**
     * Erstellt Status-Badge
     */
    createStatus() {
        this.statusElement = document.createElement('div');
        this.statusElement.className = 'form-header-status';

        const badge = document.createElement('span');
        badge.className = 'form-status-badge';
        if (this.options.statusType) {
            badge.classList.add(this.options.statusType);
        }
        badge.textContent = this.options.statusText;

        this.statusElement.appendChild(badge);
        this.container.appendChild(this.statusElement);
    }

    /**
     * Erstellt Buttons
     */
    createButtons() {
        this.controlsElement = document.createElement('div');
        this.controlsElement.className = 'form-header-controls-unified';

        // Button-Mapping: Name -> {label, className, callback}
        const buttonConfig = {
            refresh: { label: 'Aktualisieren', className: 'form-btn-refresh', callback: this.options.onRefresh },
            new: { label: 'Neu', className: 'form-btn-new', callback: this.options.onNew },
            copy: { label: 'Kopieren', className: 'form-btn-copy', callback: this.options.onCopy },
            delete: { label: 'Löschen', className: 'form-btn-delete', callback: this.options.onDelete },
            save: { label: 'Speichern', className: 'form-btn-save', callback: this.options.onSave },
            close: { label: 'Schließen', className: 'form-btn-close', callback: this.options.onClose }
        };

        // Buttons erstellen
        this.options.buttons.forEach(buttonName => {
            const config = buttonConfig[buttonName];
            if (!config) {
                console.warn('[UnifiedHeader] Unbekannter Button:', buttonName);
                return;
            }

            const button = document.createElement('button');
            button.className = 'form-btn ' + config.className;
            button.textContent = config.label;

            // Event Listener
            if (config.callback && typeof config.callback === 'function') {
                button.addEventListener('click', config.callback);
            }

            this.buttons[buttonName] = button;
            this.controlsElement.appendChild(button);
        });

        this.container.appendChild(this.controlsElement);
    }

    /**
     * Erstellt Filter-Zeile (nur bei extended-Variante)
     */
    createFilters() {
        this.filtersElement = document.createElement('div');
        this.filtersElement.className = 'form-header-filters';
        this.container.appendChild(this.filtersElement);
    }

    /**
     * Aktualisiert den Titel
     * @param {string} newTitle - Neuer Titel
     */
    setTitle(newTitle) {
        if (this.titleElement) {
            this.titleElement.textContent = newTitle;
            this.options.title = newTitle;
        }
    }

    /**
     * Aktualisiert Status-Badge
     * @param {string} text - Neuer Status-Text
     * @param {string} type - Status-Typ: 'active', 'inactive', 'pending', ''
     */
    setStatus(text, type = '') {
        if (!this.statusElement) {
            // Status-Element existiert nicht -> erstellen
            this.options.showStatus = true;
            this.createStatus();
        }

        const badge = this.statusElement.querySelector('.form-status-badge');
        if (badge) {
            badge.textContent = text;
            badge.className = 'form-status-badge';
            if (type) {
                badge.classList.add(type);
            }
        }

        this.options.statusText = text;
        this.options.statusType = type;
    }

    /**
     * Aktiviert/Deaktiviert einen Button
     * @param {string} buttonName - Button-Name: 'refresh', 'new', 'copy', 'delete', 'save', 'close'
     * @param {boolean} enabled - true = aktiviert, false = deaktiviert
     */
    setButtonEnabled(buttonName, enabled) {
        const button = this.buttons[buttonName];
        if (button) {
            button.disabled = !enabled;
        }
    }

    /**
     * Ändert Button-Text
     * @param {string} buttonName - Button-Name
     * @param {string} newLabel - Neuer Button-Text
     */
    setButtonLabel(buttonName, newLabel) {
        const button = this.buttons[buttonName];
        if (button) {
            button.textContent = newLabel;
        }
    }

    /**
     * Zeigt/Versteckt einen Button
     * @param {string} buttonName - Button-Name
     * @param {boolean} visible - true = sichtbar, false = versteckt
     */
    setButtonVisible(buttonName, visible) {
        const button = this.buttons[buttonName];
        if (button) {
            button.style.display = visible ? 'flex' : 'none';
        }
    }

    /**
     * Fügt einen Filter hinzu (nur bei extended-Variante)
     * @param {string} label - Filter-Label
     * @param {string} type - Filter-Typ: 'input', 'date', 'select'
     * @param {Object} options - Zusätzliche Optionen (z.B. selectOptions für Select)
     * @returns {HTMLElement} - Das erstellte Filter-Element
     */
    addFilter(label, type = 'input', options = {}) {
        if (!this.filtersElement) {
            console.warn('[UnifiedHeader] Filter nur bei extended-Variante verfügbar');
            return null;
        }

        // Label erstellen
        const labelElement = document.createElement('label');
        labelElement.className = 'form-filter-label';
        labelElement.textContent = label + ':';
        this.filtersElement.appendChild(labelElement);

        // Filter-Element erstellen
        let filterElement;
        if (type === 'select') {
            filterElement = document.createElement('select');
            filterElement.className = 'form-filter-select';

            // Optionen hinzufügen
            if (options.selectOptions && Array.isArray(options.selectOptions)) {
                options.selectOptions.forEach(opt => {
                    const option = document.createElement('option');
                    option.value = opt.value || opt;
                    option.textContent = opt.label || opt;
                    filterElement.appendChild(option);
                });
            }
        } else {
            filterElement = document.createElement('input');
            filterElement.className = 'form-filter-input';
            filterElement.type = type; // 'text', 'date', 'number', etc.

            if (options.placeholder) {
                filterElement.placeholder = options.placeholder;
            }
            if (options.value) {
                filterElement.value = options.value;
            }
        }

        // ID setzen (falls angegeben)
        if (options.id) {
            filterElement.id = options.id;
        }

        // Event Listener (falls angegeben)
        if (options.onChange && typeof options.onChange === 'function') {
            filterElement.addEventListener('change', options.onChange);
        }

        this.filtersElement.appendChild(filterElement);
        return filterElement;
    }

    /**
     * Entfernt den Header aus dem DOM
     */
    destroy() {
        if (this.container && this.container.parentNode) {
            this.container.parentNode.removeChild(this.container);
        }
        this.container = null;
        this.titleElement = null;
        this.controlsElement = null;
        this.statusElement = null;
        this.filtersElement = null;
        this.buttons = {};
    }
}

// ========================================
// HELPER FUNCTIONS
// ========================================

/**
 * Erstellt einen Unified Header aus einem bestehenden HTML-Element
 * @param {string|HTMLElement} selector - CSS-Selektor oder DOM-Element
 * @returns {Object} - Objekt mit Helper-Methoden für den Header
 */
function attachUnifiedHeader(selector) {
    const container = typeof selector === 'string'
        ? document.querySelector(selector)
        : selector;

    if (!container || !container.classList.contains('form-header-unified')) {
        console.error('[UnifiedHeader] Element nicht gefunden oder keine form-header-unified:', selector);
        return null;
    }

    const titleElement = container.querySelector('.form-title-unified');
    const controlsElement = container.querySelector('.form-header-controls-unified');
    const statusElement = container.querySelector('.form-header-status');
    const buttons = {};

    // Buttons sammeln
    if (controlsElement) {
        controlsElement.querySelectorAll('.form-btn').forEach(btn => {
            // Button-Name aus Klasse extrahieren (z.B. form-btn-refresh -> refresh)
            const btnClasses = Array.from(btn.classList);
            const btnClass = btnClasses.find(c => c.startsWith('form-btn-') && c !== 'form-btn');
            if (btnClass) {
                const btnName = btnClass.replace('form-btn-', '');
                buttons[btnName] = btn;
            }
        });
    }

    // Helper-Objekt zurückgeben
    return {
        container: container,
        titleElement: titleElement,
        controlsElement: controlsElement,
        statusElement: statusElement,
        buttons: buttons,

        setTitle(newTitle) {
            if (titleElement) {
                titleElement.textContent = newTitle;
            }
        },

        setStatus(text, type = '') {
            if (statusElement) {
                const badge = statusElement.querySelector('.form-status-badge');
                if (badge) {
                    badge.textContent = text;
                    badge.className = 'form-status-badge';
                    if (type) {
                        badge.classList.add(type);
                    }
                }
            }
        },

        setButtonEnabled(buttonName, enabled) {
            const button = buttons[buttonName];
            if (button) {
                button.disabled = !enabled;
            }
        },

        setButtonLabel(buttonName, newLabel) {
            const button = buttons[buttonName];
            if (button) {
                button.textContent = newLabel;
            }
        },

        setButtonVisible(buttonName, visible) {
            const button = buttons[buttonName];
            if (button) {
                button.style.display = visible ? 'flex' : 'none';
            }
        },

        on(buttonName, callback) {
            const button = buttons[buttonName];
            if (button && typeof callback === 'function') {
                button.addEventListener('click', callback);
            }
        }
    };
}

/**
 * Einfacher Helper zum Erstellen eines Standard-Headers
 * @param {string} title - Formulartitel
 * @param {Function} onRefresh - Callback für Aktualisieren-Button
 * @param {Function} onNew - Callback für Neu-Button
 * @param {Function} onDelete - Callback für Löschen-Button
 * @returns {UnifiedHeader} - Header-Instanz
 */
function createStandardHeader(title, onRefresh, onNew, onDelete) {
    return new UnifiedHeader({
        title: title,
        buttons: ['refresh', 'new', 'delete'],
        onRefresh: onRefresh,
        onNew: onNew,
        onDelete: onDelete
    });
}

/**
 * Einfacher Helper zum Erstellen eines Readonly-Headers
 * @param {string} title - Formulartitel
 * @param {Function} onRefresh - Callback für Aktualisieren-Button
 * @returns {UnifiedHeader} - Header-Instanz
 */
function createReadonlyHeader(title, onRefresh) {
    return new UnifiedHeader({
        title: title,
        variant: 'readonly',
        buttons: ['refresh', 'close'],
        onRefresh: onRefresh,
        onClose: () => window.close()
    });
}

// Export für Module (falls verwendet)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        UnifiedHeader,
        attachUnifiedHeader,
        createStandardHeader,
        createReadonlyHeader
    };
}
