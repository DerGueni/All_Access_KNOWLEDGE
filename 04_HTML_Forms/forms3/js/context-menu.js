/**
 * Context Menu System
 * Rechtsklick-Menue fuer schnelle Aktionen
 *
 * Verwendung:
 *   ContextMenu.register('#myTable tr', [
 *       { label: 'Bearbeiten', icon: '✏️', action: (el) => edit(el) },
 *       { label: 'Loeschen', icon: '🗑️', action: (el) => remove(el), danger: true },
 *       { divider: true },
 *       { label: 'Kopieren', icon: '📋', action: (el) => copy(el) }
 *   ]);
 *
 *   // Mit Bedingungen:
 *   ContextMenu.register('.ma-row', [
 *       { label: 'Anfragen', action: sendRequest, condition: (el) => !el.dataset.requested },
 *       { label: 'Stornieren', action: cancel, condition: (el) => el.dataset.status === 'pending' }
 *   ]);
 */

'use strict';

const ContextMenu = (function() {
    let menuElement = null;
    let currentTarget = null;
    let registeredSelectors = new Map();

    // CSS injizieren
    function injectStyles() {
        if (document.getElementById('context-menu-styles')) return;

        const styles = document.createElement('style');
        styles.id = 'context-menu-styles';
        styles.textContent = `
            .context-menu {
                position: fixed;
                z-index: 99999;
                background: white;
                border: 1px solid #ccc;
                border-radius: 6px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.25);
                min-width: 180px;
                max-width: 280px;
                padding: 6px 0;
                font-family: 'Segoe UI', sans-serif;
                font-size: 13px;
                opacity: 0;
                transform: scale(0.95) translateY(-5px);
                transform-origin: top left;
                transition: opacity 0.15s ease, transform 0.15s ease;
            }

            .context-menu.visible {
                opacity: 1;
                transform: scale(1) translateY(0);
            }

            .context-menu-item {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 8px 16px;
                cursor: pointer;
                color: #333;
                transition: background 0.1s ease;
            }

            .context-menu-item:hover {
                background: #f0f0f0;
            }

            .context-menu-item.disabled {
                color: #aaa;
                cursor: not-allowed;
            }

            .context-menu-item.disabled:hover {
                background: transparent;
            }

            .context-menu-item.danger {
                color: #dc3545;
            }

            .context-menu-item.danger:hover {
                background: #fff0f0;
            }

            .context-menu-icon {
                width: 20px;
                text-align: center;
                flex-shrink: 0;
            }

            .context-menu-label {
                flex: 1;
            }

            .context-menu-shortcut {
                color: #888;
                font-size: 11px;
                margin-left: 12px;
            }

            .context-menu-divider {
                height: 1px;
                background: #e0e0e0;
                margin: 6px 12px;
            }

            .context-menu-header {
                padding: 6px 16px;
                font-weight: 600;
                color: #666;
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            /* Submenu */
            .context-menu-item.has-submenu::after {
                content: '▶';
                font-size: 9px;
                color: #888;
                margin-left: auto;
            }

            /* Dark Mode Support */
            body.dark-mode .context-menu {
                background: #2d3748;
                border-color: #4a5568;
            }

            body.dark-mode .context-menu-item {
                color: #e2e8f0;
            }

            body.dark-mode .context-menu-item:hover {
                background: #3d4758;
            }

            body.dark-mode .context-menu-divider {
                background: #4a5568;
            }

            body.dark-mode .context-menu-header {
                color: #a0aec0;
            }
        `;
        document.head.appendChild(styles);
    }

    // Menu erstellen
    function createMenu(items, targetElement) {
        if (menuElement) {
            menuElement.remove();
        }

        menuElement = document.createElement('div');
        menuElement.className = 'context-menu';

        items.forEach(item => {
            if (item.divider) {
                const divider = document.createElement('div');
                divider.className = 'context-menu-divider';
                menuElement.appendChild(divider);
                return;
            }

            if (item.header) {
                const header = document.createElement('div');
                header.className = 'context-menu-header';
                header.textContent = item.header;
                menuElement.appendChild(header);
                return;
            }

            // Bedingung pruefen
            if (item.condition && !item.condition(targetElement)) {
                return;
            }

            const menuItem = document.createElement('div');
            menuItem.className = 'context-menu-item';

            if (item.danger) menuItem.classList.add('danger');
            if (item.disabled) menuItem.classList.add('disabled');

            menuItem.innerHTML = `
                ${item.icon ? `<span class="context-menu-icon">${item.icon}</span>` : ''}
                <span class="context-menu-label">${item.label}</span>
                ${item.shortcut ? `<span class="context-menu-shortcut">${item.shortcut}</span>` : ''}
            `;

            if (!item.disabled && item.action) {
                menuItem.addEventListener('click', (e) => {
                    e.stopPropagation();
                    hideMenu();
                    item.action(targetElement, e);
                });
            }

            menuElement.appendChild(menuItem);
        });

        document.body.appendChild(menuElement);
        return menuElement;
    }

    // Menu positionieren
    function positionMenu(x, y) {
        if (!menuElement) return;

        const menuRect = menuElement.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;

        // Rechts am Rand?
        if (x + menuRect.width > viewportWidth - 10) {
            x = viewportWidth - menuRect.width - 10;
        }

        // Unten am Rand?
        if (y + menuRect.height > viewportHeight - 10) {
            y = viewportHeight - menuRect.height - 10;
        }

        // Mindestens 10px vom Rand
        x = Math.max(10, x);
        y = Math.max(10, y);

        menuElement.style.left = x + 'px';
        menuElement.style.top = y + 'px';

        // Animation
        requestAnimationFrame(() => {
            menuElement.classList.add('visible');
        });
    }

    // Menu ausblenden
    function hideMenu() {
        if (menuElement) {
            menuElement.classList.remove('visible');
            setTimeout(() => {
                if (menuElement) {
                    menuElement.remove();
                    menuElement = null;
                }
            }, 150);
        }
        currentTarget = null;
    }

    // Event Handler
    function handleContextMenu(e) {
        const target = e.target;

        // Registrierte Selektoren pruefen
        for (const [selector, items] of registeredSelectors) {
            const matchedElement = target.closest(selector);
            if (matchedElement) {
                e.preventDefault();
                currentTarget = matchedElement;
                createMenu(items, matchedElement);
                positionMenu(e.clientX, e.clientY);
                return;
            }
        }
    }

    // Initialisierung
    function init() {
        injectStyles();

        // Global click zum Schliessen
        document.addEventListener('click', (e) => {
            if (menuElement && !menuElement.contains(e.target)) {
                hideMenu();
            }
        });

        // ESC zum Schliessen
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && menuElement) {
                hideMenu();
            }
        });

        // Scroll zum Schliessen
        document.addEventListener('scroll', hideMenu, true);

        // Context Menu Handler
        document.addEventListener('contextmenu', handleContextMenu);
    }

    // Auto-Init
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    return {
        /**
         * Registriert ein Kontextmenue fuer einen Selektor
         * @param {string} selector - CSS Selektor
         * @param {Array} items - Array von Menu-Items
         */
        register: function(selector, items) {
            registeredSelectors.set(selector, items);
        },

        /**
         * Entfernt Registrierung
         * @param {string} selector
         */
        unregister: function(selector) {
            registeredSelectors.delete(selector);
        },

        /**
         * Zeigt Menu programmatisch
         * @param {number} x - X-Position
         * @param {number} y - Y-Position
         * @param {Array} items - Menu-Items
         * @param {Element} targetElement - Ziel-Element
         */
        show: function(x, y, items, targetElement = null) {
            currentTarget = targetElement;
            createMenu(items, targetElement);
            positionMenu(x, y);
        },

        /**
         * Schliesst Menu
         */
        hide: hideMenu,

        /**
         * Aktuelles Ziel-Element
         */
        get currentTarget() {
            return currentTarget;
        }
    };
})();

// Global verfuegbar
window.ContextMenu = ContextMenu;

// Standard-Kontextmenues fuer CONSYS registrieren
document.addEventListener('DOMContentLoaded', function() {
    // Tabellen-Zeilen
    ContextMenu.register('table tbody tr', [
        { header: 'Aktionen' },
        { label: 'Bearbeiten', icon: '✏️', action: (el) => {
            const id = el.dataset.id || el.querySelector('[data-id]')?.dataset.id;
            if (id) console.log('Bearbeite:', id);
        }},
        { label: 'Details anzeigen', icon: '🔍', action: (el) => {
            const id = el.dataset.id || el.querySelector('[data-id]')?.dataset.id;
            if (id) console.log('Details:', id);
        }},
        { divider: true },
        { label: 'Kopieren', icon: '📋', shortcut: 'Strg+C', action: (el) => {
            const text = el.innerText.replace(/\t/g, ', ');
            navigator.clipboard?.writeText(text);
            if (window.Toast) Toast.success('In Zwischenablage kopiert');
        }},
        { divider: true },
        { label: 'Loeschen', icon: '🗑️', danger: true, action: async (el) => {
            if (window.Toast) {
                const confirmed = await Toast.confirm('Wirklich loeschen?', { danger: true });
                if (confirmed) console.log('Loeschen:', el);
            }
        }}
    ]);

    // Input-Felder
    ContextMenu.register('input[type="text"], textarea', [
        { label: 'Ausschneiden', icon: '✂️', shortcut: 'Strg+X', action: (el) => {
            document.execCommand('cut');
        }},
        { label: 'Kopieren', icon: '📋', shortcut: 'Strg+C', action: (el) => {
            document.execCommand('copy');
        }},
        { label: 'Einfuegen', icon: '📥', shortcut: 'Strg+V', action: (el) => {
            navigator.clipboard?.readText().then(text => {
                el.value = text;
                el.dispatchEvent(new Event('input', { bubbles: true }));
            });
        }},
        { divider: true },
        { label: 'Alles auswaehlen', icon: '☑️', shortcut: 'Strg+A', action: (el) => {
            el.select();
        }},
        { label: 'Leeren', icon: '🗑️', action: (el) => {
            el.value = '';
            el.dispatchEvent(new Event('input', { bubbles: true }));
        }}
    ]);
});
