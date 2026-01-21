/**
 * Pagination System
 * Serverseitige Pagination mit UI-Komponente
 *
 * Verwendung:
 *   const pager = new Pagination('#pagination-container', {
 *       totalItems: 500,
 *       itemsPerPage: 25,
 *       onPageChange: (page, limit, offset) => loadData(page)
 *   });
 *
 *   // Nach API-Antwort aktualisieren
 *   pager.update({ total: 523, page: 1 });
 */

'use strict';

class Pagination {
    constructor(containerSelector, options = {}) {
        this.container = typeof containerSelector === 'string' ?
            document.querySelector(containerSelector) : containerSelector;

        if (!this.container) {
            console.error('[Pagination] Container nicht gefunden:', containerSelector);
            return;
        }

        this.options = {
            totalItems: 0,
            itemsPerPage: 25,
            currentPage: 1,
            maxVisiblePages: 5,
            showFirstLast: true,
            showPrevNext: true,
            showInfo: true,
            showPerPageSelector: true,
            perPageOptions: [10, 25, 50, 100],
            onPageChange: null,
            onPerPageChange: null,
            labels: {
                first: '«',
                prev: '‹',
                next: '›',
                last: '»',
                info: 'Zeige {start}-{end} von {total}',
                perPage: 'Pro Seite:'
            },
            ...options
        };

        this.currentPage = this.options.currentPage;
        this.itemsPerPage = this.options.itemsPerPage;
        this.totalItems = this.options.totalItems;

        this.init();
    }

    /**
     * Initialisieren
     */
    init() {
        this.injectStyles();
        this.render();
        console.log('[Pagination] Initialisiert');
    }

    /**
     * CSS injizieren
     */
    injectStyles() {
        if (document.getElementById('pagination-styles')) return;

        const styles = document.createElement('style');
        styles.id = 'pagination-styles';
        styles.textContent = `
            .pagination-wrapper {
                display: flex;
                align-items: center;
                justify-content: space-between;
                flex-wrap: wrap;
                gap: 12px;
                padding: 12px 0;
                font-family: 'Segoe UI', sans-serif;
                font-size: 12px;
            }

            .pagination-info {
                color: #666;
            }

            .pagination-controls {
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .pagination-btn {
                min-width: 32px;
                height: 32px;
                padding: 0 8px;
                border: 1px solid #ddd;
                background: #fff;
                color: #333;
                cursor: pointer;
                border-radius: 4px;
                font-size: 12px;
                transition: all 0.15s ease;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .pagination-btn:hover:not(:disabled) {
                background: #f0f0f0;
                border-color: #ccc;
            }

            .pagination-btn:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }

            .pagination-btn.active {
                background: linear-gradient(to bottom, #4060a0 0%, #304080 100%);
                color: white;
                border-color: #304080;
                font-weight: bold;
            }

            .pagination-btn.nav-btn {
                font-weight: bold;
            }

            .pagination-ellipsis {
                padding: 0 8px;
                color: #999;
            }

            .pagination-per-page {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .pagination-per-page label {
                color: #666;
            }

            .pagination-per-page select {
                padding: 6px 8px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 12px;
                cursor: pointer;
            }

            .pagination-per-page select:focus {
                outline: none;
                border-color: #4060a0;
            }

            /* Kompakte Variante */
            .pagination-wrapper.compact {
                font-size: 11px;
            }

            .pagination-wrapper.compact .pagination-btn {
                min-width: 28px;
                height: 28px;
                font-size: 11px;
            }

            /* Dark Mode */
            body.dark-mode .pagination-btn {
                background: #2d3748;
                border-color: #4a5568;
                color: #e2e8f0;
            }

            body.dark-mode .pagination-btn:hover:not(:disabled) {
                background: #3d4758;
            }

            body.dark-mode .pagination-btn.active {
                background: linear-gradient(to bottom, #4060a0 0%, #304080 100%);
            }

            body.dark-mode .pagination-info,
            body.dark-mode .pagination-per-page label {
                color: #a0aec0;
            }

            body.dark-mode .pagination-per-page select {
                background: #2d3748;
                border-color: #4a5568;
                color: #e2e8f0;
            }
        `;
        document.head.appendChild(styles);
    }

    /**
     * Gesamtzahl Seiten berechnen
     */
    get totalPages() {
        return Math.ceil(this.totalItems / this.itemsPerPage) || 1;
    }

    /**
     * Offset berechnen
     */
    get offset() {
        return (this.currentPage - 1) * this.itemsPerPage;
    }

    /**
     * Sichtbare Seitenzahlen berechnen
     */
    getVisiblePages() {
        const total = this.totalPages;
        const current = this.currentPage;
        const max = this.options.maxVisiblePages;

        if (total <= max) {
            return Array.from({ length: total }, (_, i) => i + 1);
        }

        const half = Math.floor(max / 2);
        let start = current - half;
        let end = current + half;

        if (start < 1) {
            start = 1;
            end = max;
        }

        if (end > total) {
            end = total;
            start = total - max + 1;
        }

        const pages = [];

        // Erste Seite + Ellipsis
        if (start > 1) {
            pages.push(1);
            if (start > 2) pages.push('...');
        }

        // Sichtbare Seiten
        for (let i = start; i <= end; i++) {
            if (i >= 1 && i <= total) {
                pages.push(i);
            }
        }

        // Ellipsis + Letzte Seite
        if (end < total) {
            if (end < total - 1) pages.push('...');
            pages.push(total);
        }

        return pages;
    }

    /**
     * Rendern
     */
    render() {
        const startItem = this.totalItems > 0 ? this.offset + 1 : 0;
        const endItem = Math.min(this.offset + this.itemsPerPage, this.totalItems);

        let html = '<div class="pagination-wrapper">';

        // Info
        if (this.options.showInfo) {
            const infoText = this.options.labels.info
                .replace('{start}', startItem)
                .replace('{end}', endItem)
                .replace('{total}', this.totalItems);
            html += `<div class="pagination-info">${infoText}</div>`;
        }

        // Controls
        html += '<div class="pagination-controls">';

        // First
        if (this.options.showFirstLast) {
            html += `<button class="pagination-btn nav-btn" data-page="1"
                ${this.currentPage === 1 ? 'disabled' : ''}>${this.options.labels.first}</button>`;
        }

        // Prev
        if (this.options.showPrevNext) {
            html += `<button class="pagination-btn nav-btn" data-page="${this.currentPage - 1}"
                ${this.currentPage === 1 ? 'disabled' : ''}>${this.options.labels.prev}</button>`;
        }

        // Page Numbers
        this.getVisiblePages().forEach(page => {
            if (page === '...') {
                html += '<span class="pagination-ellipsis">...</span>';
            } else {
                html += `<button class="pagination-btn ${page === this.currentPage ? 'active' : ''}"
                    data-page="${page}">${page}</button>`;
            }
        });

        // Next
        if (this.options.showPrevNext) {
            html += `<button class="pagination-btn nav-btn" data-page="${this.currentPage + 1}"
                ${this.currentPage === this.totalPages ? 'disabled' : ''}>${this.options.labels.next}</button>`;
        }

        // Last
        if (this.options.showFirstLast) {
            html += `<button class="pagination-btn nav-btn" data-page="${this.totalPages}"
                ${this.currentPage === this.totalPages ? 'disabled' : ''}>${this.options.labels.last}</button>`;
        }

        html += '</div>';

        // Per Page Selector
        if (this.options.showPerPageSelector) {
            html += '<div class="pagination-per-page">';
            html += `<label>${this.options.labels.perPage}</label>`;
            html += '<select class="per-page-select">';
            this.options.perPageOptions.forEach(opt => {
                html += `<option value="${opt}" ${opt === this.itemsPerPage ? 'selected' : ''}>${opt}</option>`;
            });
            html += '</select>';
            html += '</div>';
        }

        html += '</div>';

        this.container.innerHTML = html;
        this.bindEvents();
    }

    /**
     * Events binden
     */
    bindEvents() {
        // Page Buttons
        this.container.querySelectorAll('.pagination-btn[data-page]').forEach(btn => {
            btn.addEventListener('click', () => {
                const page = parseInt(btn.dataset.page);
                if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
                    this.goToPage(page);
                }
            });
        });

        // Per Page Selector
        const perPageSelect = this.container.querySelector('.per-page-select');
        if (perPageSelect) {
            perPageSelect.addEventListener('change', () => {
                this.setItemsPerPage(parseInt(perPageSelect.value));
            });
        }
    }

    /**
     * Zu Seite wechseln
     */
    goToPage(page) {
        if (page < 1 || page > this.totalPages) return;

        this.currentPage = page;
        this.render();

        if (typeof this.options.onPageChange === 'function') {
            this.options.onPageChange(this.currentPage, this.itemsPerPage, this.offset);
        }
    }

    /**
     * Items pro Seite aendern
     */
    setItemsPerPage(value) {
        this.itemsPerPage = value;
        this.currentPage = 1; // Zurueck zur ersten Seite
        this.render();

        if (typeof this.options.onPerPageChange === 'function') {
            this.options.onPerPageChange(this.itemsPerPage);
        }

        if (typeof this.options.onPageChange === 'function') {
            this.options.onPageChange(this.currentPage, this.itemsPerPage, this.offset);
        }
    }

    /**
     * Daten aktualisieren (nach API-Antwort)
     */
    update(data) {
        if (data.total !== undefined) {
            this.totalItems = data.total;
        }
        if (data.page !== undefined) {
            this.currentPage = data.page;
        }
        if (data.perPage !== undefined) {
            this.itemsPerPage = data.perPage;
        }
        this.render();
    }

    /**
     * Gesamtzahl setzen
     */
    setTotal(total) {
        this.totalItems = total;
        if (this.currentPage > this.totalPages) {
            this.currentPage = this.totalPages || 1;
        }
        this.render();
    }

    /**
     * Aktuelle Seite abrufen
     */
    getCurrentPage() {
        return this.currentPage;
    }

    /**
     * Items pro Seite abrufen
     */
    getItemsPerPage() {
        return this.itemsPerPage;
    }

    /**
     * Offset abrufen
     */
    getOffset() {
        return this.offset;
    }

    /**
     * Query-Parameter fuer API-Aufruf
     */
    getQueryParams() {
        return {
            page: this.currentPage,
            limit: this.itemsPerPage,
            offset: this.offset
        };
    }

    /**
     * Naechste Seite
     */
    next() {
        if (this.currentPage < this.totalPages) {
            this.goToPage(this.currentPage + 1);
        }
    }

    /**
     * Vorherige Seite
     */
    prev() {
        if (this.currentPage > 1) {
            this.goToPage(this.currentPage - 1);
        }
    }

    /**
     * Erste Seite
     */
    first() {
        this.goToPage(1);
    }

    /**
     * Letzte Seite
     */
    last() {
        this.goToPage(this.totalPages);
    }
}

// Global verfuegbar
window.Pagination = Pagination;

// =====================================================
// API-Helper fuer Pagination
// =====================================================

/**
 * Paginierte API-Abfrage
 *
 * Verwendung:
 *   const result = await paginatedFetch('/api/mitarbeiter', pager.getQueryParams());
 *   pager.update({ total: result.total });
 *   renderData(result.items);
 */
async function paginatedFetch(url, params = {}) {
    const queryParams = new URLSearchParams({
        page: params.page || 1,
        limit: params.limit || 25,
        ...params.filters
    });

    const response = await fetch(`${url}?${queryParams}`);

    if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
    }

    return response.json();
}

window.paginatedFetch = paginatedFetch;
