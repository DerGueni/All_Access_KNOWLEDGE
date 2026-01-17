/**
 * performance-init.js - Auto-Initialisierung der Performance-Optimierungen
 *
 * Dieses Modul wird automatisch beim Laden einer Seite ausgefuehrt und:
 * - Zeigt Loading-Skeletons waehrend Datenladung
 * - Initialisiert Lazy Loading fuer iframes
 * - Setzt Debounce fuer Suchfelder
 * - Aktiviert Virtual Scrolling fuer grosse Listen
 *
 * VERWENDUNG:
 * <script src="../js/performance-init.js"></script>
 */

(function() {
    'use strict';

    // ============================================
    // SKELETON STYLES INJECTION
    // ============================================
    const SKELETON_STYLES = `
        @keyframes skeleton-shimmer {
            0% { background-position: -200px 0; }
            100% { background-position: 200px 0; }
        }

        .skeleton-loading {
            pointer-events: none;
        }

        .skeleton-row {
            display: flex;
            gap: 8px;
            padding: 6px 4px;
            border-bottom: 1px solid #e0e0e0;
        }

        .skeleton-cell {
            height: 14px;
            background: linear-gradient(90deg, #e8e8e8 25%, #f0f0f0 50%, #e8e8e8 75%);
            background-size: 400px 100%;
            animation: skeleton-shimmer 1.2s ease-in-out infinite;
            border-radius: 3px;
        }

        .skeleton-cell.w-20 { width: 20%; }
        .skeleton-cell.w-30 { width: 30%; }
        .skeleton-cell.w-40 { width: 40%; }
        .skeleton-cell.w-50 { width: 50%; }
        .skeleton-cell.w-60 { width: 60%; }

        .form-loading::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255,255,255,0.7);
            z-index: 100;
        }

        .form-loading::after {
            content: 'Laden...';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #fff;
            padding: 10px 20px;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            z-index: 101;
            font-size: 12px;
            color: #666;
        }

        [data-lazy-src]:not(.lazy-loaded) {
            background: #f5f5f5;
            min-height: 50px;
        }

        .fade-in {
            animation: fadeIn 0.2s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    `;

    // Styles injizieren
    function injectStyles() {
        if (document.getElementById('perf-init-styles')) return;
        const style = document.createElement('style');
        style.id = 'perf-init-styles';
        style.textContent = SKELETON_STYLES;
        document.head.appendChild(style);
    }

    // ============================================
    // SKELETON GENERATORS
    // ============================================
    function generateTableSkeleton(rows = 8, cols = 4) {
        const widths = ['w-30', 'w-40', 'w-20', 'w-50', 'w-60'];
        let html = '';
        for (let r = 0; r < rows; r++) {
            html += '<div class="skeleton-row">';
            for (let c = 0; c < cols; c++) {
                const w = widths[(r + c) % widths.length];
                html += `<div class="skeleton-cell ${w}"></div>`;
            }
            html += '</div>';
        }
        return html;
    }

    function generateListSkeleton(rows = 6) {
        let html = '';
        for (let r = 0; r < rows; r++) {
            const width = 40 + Math.random() * 40;
            html += `<div class="skeleton-row">
                <div class="skeleton-cell" style="width: ${width}%"></div>
            </div>`;
        }
        return html;
    }

    // ============================================
    // AUTO-SKELETON FOR TABLES
    // ============================================
    function showTableSkeletons() {
        // Alle tbody-Elemente finden die leer sind
        document.querySelectorAll('tbody:empty, tbody[data-loading]').forEach(tbody => {
            if (tbody.innerHTML.trim() === '' || tbody.dataset.loading) {
                tbody.innerHTML = generateTableSkeleton(6, 4);
                tbody.classList.add('skeleton-loading');
            }
        });

        // Auftragsliste-Container
        const auftragsListe = document.querySelector('.auftrags-liste, #auftragsListe, [data-auftragsliste]');
        if (auftragsListe && auftragsListe.innerHTML.trim() === '') {
            auftragsListe.innerHTML = generateListSkeleton(10);
            auftragsListe.classList.add('skeleton-loading');
        }

        // Mitarbeiterliste
        const maListe = document.querySelector('.ma-liste, #maListe, [data-maliste]');
        if (maListe && maListe.innerHTML.trim() === '') {
            maListe.innerHTML = generateListSkeleton(10);
            maListe.classList.add('skeleton-loading');
        }
    }

    function hideSkeletons(container) {
        const el = typeof container === 'string' ? document.querySelector(container) : container;
        if (el) {
            el.classList.remove('skeleton-loading');
            el.classList.add('fade-in');
        }
    }

    // ============================================
    // LAZY LOADING FOR IFRAMES/SUBFORMS
    // ============================================
    let lazyObserver = null;

    function initLazyLoading() {
        if (lazyObserver) return;

        // IntersectionObserver fuer Lazy Loading
        lazyObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    loadLazyElement(entry.target);
                    lazyObserver.unobserve(entry.target);
                }
            });
        }, {
            root: null,
            rootMargin: '100px',
            threshold: 0
        });

        // Alle lazy-src Elemente beobachten
        document.querySelectorAll('[data-lazy-src]').forEach(el => {
            lazyObserver.observe(el);
        });

        // MutationObserver fuer dynamisch hinzugefuegte Elemente
        const mutationObserver = new MutationObserver((mutations) => {
            mutations.forEach(mutation => {
                mutation.addedNodes.forEach(node => {
                    if (node.nodeType === 1) {
                        if (node.dataset && node.dataset.lazySrc) {
                            lazyObserver.observe(node);
                        }
                        node.querySelectorAll?.('[data-lazy-src]').forEach(el => {
                            lazyObserver.observe(el);
                        });
                    }
                });
            });
        });

        mutationObserver.observe(document.body, { childList: true, subtree: true });
    }

    function loadLazyElement(el) {
        const src = el.dataset.lazySrc;
        if (!src) return;

        if (el.tagName === 'IFRAME') {
            // Preload: Zeige Loading-Indikator
            el.style.background = '#f5f5f5';

            el.onload = () => {
                el.classList.add('lazy-loaded', 'fade-in');
                el.style.background = '';
                console.debug('[LazyLoad] Loaded:', src);
            };

            el.src = src;
        } else if (el.tagName === 'IMG') {
            el.onload = () => {
                el.classList.add('lazy-loaded', 'fade-in');
            };
            el.src = src;
        }

        el.removeAttribute('data-lazy-src');
    }

    // ============================================
    // DEBOUNCE FOR SEARCH INPUTS
    // ============================================
    function initSearchDebounce() {
        const searchInputs = document.querySelectorAll(
            'input[type="search"], ' +
            'input[data-debounce], ' +
            'input.search-input, ' +
            '#txtSuche, #searchInput, [id*="Suche"], [id*="suche"]'
        );

        searchInputs.forEach(input => {
            const delay = parseInt(input.dataset.debounceDelay) || 300;
            const originalHandler = input.oninput || input.onkeyup;

            if (originalHandler) {
                let timeout;
                const debouncedHandler = function(e) {
                    clearTimeout(timeout);
                    timeout = setTimeout(() => originalHandler.call(this, e), delay);
                };

                input.oninput = debouncedHandler;
                input.onkeyup = null;
            }
        });
    }

    // ============================================
    // PRELOAD DROPDOWN DATA
    // ============================================
    async function preloadDropdowns() {
        // Nur im Browser-Modus (nicht WebView2)
        if (window.chrome && window.chrome.webview) return;

        // Bridge muss verfuegbar sein
        if (!window.Bridge) return;

        try {
            // Stammdaten parallel laden (werden gecacht)
            const types = ['status', 'kunden', 'objekte', 'orte'];
            await Promise.all(types.map(type => {
                return window.Bridge.list?.(type).catch(e => {
                    console.debug('[Preload] Failed:', type, e.message);
                });
            }));
            console.debug('[Preload] Dropdowns gecacht');
        } catch (e) {
            console.debug('[Preload] Error:', e.message);
        }
    }

    // ============================================
    // GLOBAL HELPERS (exposed)
    // ============================================
    window.PerfInit = {
        showTableSkeletons,
        hideSkeletons,
        generateTableSkeleton,
        generateListSkeleton,
        loadLazyElement,
        preloadDropdowns
    };

    // ============================================
    // AUTO-INIT ON DOM READY
    // ============================================
    function autoInit() {
        injectStyles();
        showTableSkeletons();
        initLazyLoading();
        initSearchDebounce();

        // Dropdowns nach kurzer Verzoegerung preloaden
        setTimeout(preloadDropdowns, 500);

        console.debug('[PerfInit] Performance-Optimierungen initialisiert');
    }

    // Initialisierung
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', autoInit);
    } else {
        autoInit();
    }

})();
