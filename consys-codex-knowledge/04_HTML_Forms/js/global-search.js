/**
 * CONSYS Global Search Module
 * Globale Suchfunktion fuer alle Formulare
 * Aktivierung: Strg+K
 */

class GlobalSearch {
    constructor(options = {}) {
        this.options = {
            placeholder: 'Suche nach Mitarbeitern, Auftraegen, Kunden...',
            maxResults: 10,
            debounceTime: 300,
            ...options
        };

        this.isOpen = false;
        this.searchResults = [];
        this.selectedIndex = -1;
        this.debounceTimer = null;

        this.init();
    }

    init() {
        this.createModal();
        this.bindEvents();
    }

    createModal() {
        // Container
        this.modal = document.createElement('div');
        this.modal.className = 'gs-modal';
        this.modal.innerHTML = `
            <div class="gs-backdrop"></div>
            <div class="gs-container">
                <div class="gs-search-box">
                    <span class="gs-icon">&#128269;</span>
                    <input type="text" class="gs-input" placeholder="${this.options.placeholder}">
                    <span class="gs-shortcut">ESC</span>
                </div>
                <div class="gs-results"></div>
                <div class="gs-footer">
                    <span class="gs-hint"><kbd>&#8593;</kbd><kbd>&#8595;</kbd> Navigation</span>
                    <span class="gs-hint"><kbd>Enter</kbd> Oeffnen</span>
                    <span class="gs-hint"><kbd>ESC</kbd> Schliessen</span>
                </div>
            </div>
        `;

        // Styles
        const style = document.createElement('style');
        style.textContent = `
            .gs-modal {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                z-index: 10000;
                display: none;
                align-items: flex-start;
                justify-content: center;
                padding-top: 100px;
            }

            .gs-modal.open {
                display: flex;
            }

            .gs-backdrop {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.6);
                backdrop-filter: blur(4px);
            }

            .gs-container {
                position: relative;
                width: 600px;
                max-width: 90vw;
                background: #1a1a2e;
                border: 1px solid rgba(255, 255, 255, 0.15);
                border-radius: 12px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
                overflow: hidden;
                animation: gs-slide-down 0.2s ease-out;
            }

            @keyframes gs-slide-down {
                from {
                    opacity: 0;
                    transform: translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .gs-search-box {
                display: flex;
                align-items: center;
                padding: 16px 20px;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                gap: 12px;
            }

            .gs-icon {
                font-size: 18px;
                color: #7f8c8d;
            }

            .gs-input {
                flex: 1;
                background: transparent;
                border: none;
                outline: none;
                font-size: 16px;
                color: white;
            }

            .gs-input::placeholder {
                color: #7f8c8d;
            }

            .gs-shortcut {
                background: rgba(255, 255, 255, 0.1);
                color: #7f8c8d;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 11px;
            }

            .gs-results {
                max-height: 400px;
                overflow-y: auto;
            }

            .gs-results:empty::after {
                content: 'Tippen Sie, um zu suchen...';
                display: block;
                padding: 40px;
                text-align: center;
                color: #7f8c8d;
                font-size: 13px;
            }

            .gs-results.has-query:empty::after {
                content: 'Keine Ergebnisse gefunden';
            }

            .gs-category {
                padding: 8px 20px;
                color: #7f8c8d;
                font-size: 10px;
                text-transform: uppercase;
                letter-spacing: 1px;
                background: rgba(0, 0, 0, 0.2);
            }

            .gs-result {
                display: flex;
                align-items: center;
                gap: 14px;
                padding: 12px 20px;
                cursor: pointer;
                transition: background 0.15s;
            }

            .gs-result:hover,
            .gs-result.selected {
                background: rgba(52, 152, 219, 0.2);
            }

            .gs-result-icon {
                width: 36px;
                height: 36px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                flex-shrink: 0;
            }

            .gs-result-icon.ma { background: rgba(52, 152, 219, 0.2); color: #3498db; }
            .gs-result-icon.auftrag { background: rgba(39, 174, 96, 0.2); color: #27ae60; }
            .gs-result-icon.kunde { background: rgba(155, 89, 182, 0.2); color: #9b59b6; }
            .gs-result-icon.objekt { background: rgba(243, 156, 18, 0.2); color: #f39c12; }

            .gs-result-content {
                flex: 1;
                min-width: 0;
            }

            .gs-result-title {
                color: white;
                font-size: 14px;
                font-weight: 500;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .gs-result-title mark {
                background: rgba(52, 152, 219, 0.4);
                color: white;
                padding: 0 2px;
                border-radius: 2px;
            }

            .gs-result-meta {
                color: #7f8c8d;
                font-size: 12px;
                margin-top: 2px;
            }

            .gs-result-action {
                color: #7f8c8d;
                font-size: 12px;
            }

            .gs-footer {
                display: flex;
                justify-content: center;
                gap: 24px;
                padding: 12px 20px;
                border-top: 1px solid rgba(255, 255, 255, 0.1);
                background: rgba(0, 0, 0, 0.2);
            }

            .gs-hint {
                color: #7f8c8d;
                font-size: 11px;
            }

            .gs-hint kbd {
                background: rgba(255, 255, 255, 0.1);
                padding: 2px 6px;
                border-radius: 3px;
                margin-right: 4px;
            }

            .gs-results::-webkit-scrollbar {
                width: 6px;
            }

            .gs-results::-webkit-scrollbar-track {
                background: transparent;
            }

            .gs-results::-webkit-scrollbar-thumb {
                background: rgba(255, 255, 255, 0.2);
                border-radius: 3px;
            }
        `;

        document.head.appendChild(style);
        document.body.appendChild(this.modal);

        // Store references
        this.backdrop = this.modal.querySelector('.gs-backdrop');
        this.input = this.modal.querySelector('.gs-input');
        this.resultsContainer = this.modal.querySelector('.gs-results');
    }

    bindEvents() {
        // Global keyboard shortcut
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey && e.key === 'k') {
                e.preventDefault();
                this.open();
            }
            if (e.key === 'Escape' && this.isOpen) {
                this.close();
            }
        });

        // Close on backdrop click
        this.backdrop.addEventListener('click', () => this.close());

        // Search input
        this.input.addEventListener('input', (e) => {
            this.handleSearch(e.target.value);
        });

        // Keyboard navigation
        this.input.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                this.selectNext();
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                this.selectPrev();
            } else if (e.key === 'Enter') {
                e.preventDefault();
                this.openSelected();
            }
        });
    }

    open() {
        this.isOpen = true;
        this.modal.classList.add('open');
        this.input.value = '';
        this.input.focus();
        this.resultsContainer.innerHTML = '';
        this.resultsContainer.classList.remove('has-query');
        document.body.style.overflow = 'hidden';
    }

    close() {
        this.isOpen = false;
        this.modal.classList.remove('open');
        document.body.style.overflow = '';
    }

    handleSearch(query) {
        clearTimeout(this.debounceTimer);

        if (!query.trim()) {
            this.resultsContainer.innerHTML = '';
            this.resultsContainer.classList.remove('has-query');
            return;
        }

        this.resultsContainer.classList.add('has-query');

        this.debounceTimer = setTimeout(() => {
            this.search(query);
        }, this.options.debounceTime);
    }

    async search(query) {
        // Demo-Daten - in Produktion: API-Aufruf
        const demoData = {
            mitarbeiter: [
                { id: 707, name: 'Alali Ahmad', meta: 'Nuernberg | Aktiv', icon: '&#128100;' },
                { id: 708, name: 'Alayoubi Salim', meta: 'Nuernberg | Aktiv', icon: '&#128100;' },
                { id: 709, name: 'Glatz Michaela', meta: 'Fuerth | Aktiv', icon: '&#128100;' },
                { id: 710, name: 'Goeschelbauer Thomas', meta: 'Erlangen | Aktiv', icon: '&#128100;' },
                { id: 711, name: 'Mueller Klaus', meta: 'Nuernberg | Aktiv', icon: '&#128100;' },
            ],
            auftraege: [
                { id: 101, name: 'NERVY Nuernberg', meta: '18.12.2025 | Besetzt', icon: '&#128203;' },
                { id: 102, name: 'HC Erlangen', meta: '19.12.2025 | 2 MA fehlen', icon: '&#128203;' },
                { id: 103, name: '1. FC Nuernberg', meta: '20.12.2025 | Geplant', icon: '&#128203;' },
                { id: 104, name: 'Studentenverbindung', meta: '21.12.2025 | Geplant', icon: '&#128203;' },
            ],
            kunden: [
                { id: 1, name: 'Arena Nuernberger Versicherung', meta: 'Nuernberg | Aktiv', icon: '&#127970;' },
                { id: 2, name: 'HC Erlangen GmbH', meta: 'Erlangen | Aktiv', icon: '&#127970;' },
                { id: 3, name: '1. FC Nuernberg e.V.', meta: 'Nuernberg | Aktiv', icon: '&#127970;' },
            ],
            objekte: [
                { id: 1, name: 'Arena Nuernberg', meta: 'Nuernberg | 5 Positionen', icon: '&#127919;' },
                { id: 2, name: 'Frankenhalle', meta: 'Nuernberg | 3 Positionen', icon: '&#127919;' },
                { id: 3, name: 'PSD Bank Arena', meta: 'Frankfurt | 8 Positionen', icon: '&#127919;' },
            ]
        };

        const q = query.toLowerCase();
        const results = {
            mitarbeiter: demoData.mitarbeiter.filter(m => m.name.toLowerCase().includes(q)),
            auftraege: demoData.auftraege.filter(a => a.name.toLowerCase().includes(q)),
            kunden: demoData.kunden.filter(k => k.name.toLowerCase().includes(q)),
            objekte: demoData.objekte.filter(o => o.name.toLowerCase().includes(q)),
        };

        this.renderResults(results, query);
    }

    renderResults(results, query) {
        let html = '';
        this.searchResults = [];

        const categories = [
            { key: 'mitarbeiter', label: 'Mitarbeiter', type: 'ma', url: 'frm_MA_Mitarbeiterstamm.html' },
            { key: 'auftraege', label: 'Auftraege', type: 'auftrag', url: 'frm_va_Auftragstamm.html' },
            { key: 'kunden', label: 'Kunden', type: 'kunde', url: 'frm_KD_Kundenstamm.html' },
            { key: 'objekte', label: 'Objekte', type: 'objekt', url: 'frm_OB_Objekt.html' },
        ];

        categories.forEach(cat => {
            const items = results[cat.key];
            if (items && items.length > 0) {
                html += `<div class="gs-category">${cat.label}</div>`;
                items.slice(0, 5).forEach(item => {
                    const highlighted = this.highlightMatch(item.name, query);
                    html += `
                        <div class="gs-result" data-url="${cat.url}?id=${item.id}" data-index="${this.searchResults.length}">
                            <div class="gs-result-icon ${cat.type}">${item.icon}</div>
                            <div class="gs-result-content">
                                <div class="gs-result-title">${highlighted}</div>
                                <div class="gs-result-meta">${item.meta}</div>
                            </div>
                            <span class="gs-result-action">&#8594;</span>
                        </div>
                    `;
                    this.searchResults.push({ url: `${cat.url}?id=${item.id}`, item });
                });
            }
        });

        this.resultsContainer.innerHTML = html;
        this.selectedIndex = -1;

        // Add click handlers
        this.resultsContainer.querySelectorAll('.gs-result').forEach((el, index) => {
            el.addEventListener('click', () => {
                this.selectedIndex = index;
                this.openSelected();
            });
        });
    }

    highlightMatch(text, query) {
        const regex = new RegExp(`(${query})`, 'gi');
        return text.replace(regex, '<mark>$1</mark>');
    }

    selectNext() {
        if (this.searchResults.length === 0) return;
        this.selectedIndex = Math.min(this.selectedIndex + 1, this.searchResults.length - 1);
        this.updateSelection();
    }

    selectPrev() {
        if (this.searchResults.length === 0) return;
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0);
        this.updateSelection();
    }

    updateSelection() {
        this.resultsContainer.querySelectorAll('.gs-result').forEach((el, index) => {
            el.classList.toggle('selected', index === this.selectedIndex);
            if (index === this.selectedIndex) {
                el.scrollIntoView({ block: 'nearest' });
            }
        });
    }

    openSelected() {
        if (this.selectedIndex >= 0 && this.searchResults[this.selectedIndex]) {
            window.location.href = this.searchResults[this.selectedIndex].url;
        }
    }
}

// Auto-initialize
document.addEventListener('DOMContentLoaded', () => {
    window.globalSearch = new GlobalSearch();
});

// Export for ES modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = GlobalSearch;
}
