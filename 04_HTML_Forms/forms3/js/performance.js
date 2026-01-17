/**
 * performance.js - Performance-Optimierungen fuer HTML-Formulare
 *
 * Features:
 * - RequestCache: HTTP-Request Caching mit TTL
 * - Debounce/Throttle: Event-Frequenz reduzieren
 * - LazyLoader: Lazy Loading fuer iframes/Bilder
 * - DOMBatcher: DOM-Aenderungen sammeln und batch-weise ausfuehren
 * - VirtualScroller: Effizientes Scrolling langer Listen
 * - SkeletonLoader: Loading-Skeletons waehrend Datenladung
 */

// ============================================
// REQUEST CACHE
// ============================================
const RequestCache = {
    _cache: new Map(),
    _pending: new Map(),

    // Cache-TTL in ms pro Endpoint-Pattern
    TTL: {
        '/mitarbeiter': 60000,        // 1 Minute
        '/kunden': 60000,             // 1 Minute
        '/objekte': 60000,            // 1 Minute
        '/status': 300000,            // 5 Minuten (aendert sich selten)
        '/dienstkleidung': 300000,    // 5 Minuten
        '/orte': 300000,              // 5 Minuten
        '/auftraege': 15000,          // 15 Sekunden
        '/einsatztage': 10000,        // 10 Sekunden
        '/schichten': 10000,          // 10 Sekunden
        '/zuordnungen': 5000,         // 5 Sekunden (live-Daten)
        '/anfragen': 5000,            // 5 Sekunden (live-Daten)
        'default': 30000              // 30 Sekunden Standard
    },

    /**
     * Holt TTL fuer einen Endpoint
     */
    getTTL(endpoint) {
        for (const [pattern, ttl] of Object.entries(this.TTL)) {
            if (pattern !== 'default' && endpoint.includes(pattern)) {
                return ttl;
            }
        }
        return this.TTL.default;
    },

    /**
     * Generiert Cache-Key aus URL und Parametern
     */
    getKey(url, params = {}) {
        const sortedParams = Object.keys(params).sort().map(k => `${k}=${params[k]}`).join('&');
        return `${url}?${sortedParams}`;
    },

    /**
     * Prueft ob Cache-Eintrag noch gueltig ist
     */
    isValid(entry, endpoint) {
        if (!entry) return false;
        const ttl = this.getTTL(endpoint);
        return (Date.now() - entry.timestamp) < ttl;
    },

    /**
     * Holt Daten aus Cache oder fuehrt Fetch aus
     */
    async fetch(url, options = {}) {
        const key = this.getKey(url, options.params || {});

        // 1. Pruefe Cache
        const cached = this._cache.get(key);
        if (cached && this.isValid(cached, url)) {
            console.debug('[Cache] HIT:', key);
            return cached.data;
        }

        // 2. Pruefe ob Request bereits laeuft (Deduplication)
        if (this._pending.has(key)) {
            console.debug('[Cache] PENDING:', key);
            return this._pending.get(key);
        }

        // 3. Neuer Request
        console.debug('[Cache] MISS:', key);
        const promise = this._doFetch(url, options);
        this._pending.set(key, promise);

        try {
            const data = await promise;
            // In Cache speichern
            this._cache.set(key, {
                data: data,
                timestamp: Date.now()
            });
            return data;
        } finally {
            this._pending.delete(key);
        }
    },

    async _doFetch(url, options = {}) {
        const response = await fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
    },

    /**
     * Loescht Cache fuer bestimmten Endpoint oder komplett
     */
    invalidate(pattern = null) {
        if (pattern) {
            for (const key of this._cache.keys()) {
                if (key.includes(pattern)) {
                    this._cache.delete(key);
                }
            }
            console.debug('[Cache] Invalidated pattern:', pattern);
        } else {
            this._cache.clear();
            console.debug('[Cache] Cleared all');
        }
    },

    /**
     * Loescht abgelaufene Eintraege
     */
    cleanup() {
        const now = Date.now();
        for (const [key, entry] of this._cache.entries()) {
            const ttl = this.getTTL(key.split('?')[0]);
            if ((now - entry.timestamp) > ttl) {
                this._cache.delete(key);
            }
        }
    }
};

// Automatischer Cleanup alle 2 Minuten
setInterval(() => RequestCache.cleanup(), 120000);


// ============================================
// DEBOUNCE & THROTTLE
// ============================================

/**
 * Debounce - Fuehrt Funktion erst nach Wartezeit aus (letzte Aufruf gewinnt)
 * Ideal fuer: Suche, Auto-Save, Resize-Handler
 */
function debounce(func, wait = 300, options = {}) {
    let timeout;
    let lastArgs;
    const leading = options.leading || false;

    const debounced = function(...args) {
        lastArgs = args;
        const callNow = leading && !timeout;

        clearTimeout(timeout);
        timeout = setTimeout(() => {
            timeout = null;
            if (!leading) {
                func.apply(this, lastArgs);
            }
        }, wait);

        if (callNow) {
            func.apply(this, args);
        }
    };

    debounced.cancel = () => {
        clearTimeout(timeout);
        timeout = null;
    };

    debounced.flush = () => {
        if (timeout) {
            clearTimeout(timeout);
            timeout = null;
            func.apply(this, lastArgs);
        }
    };

    return debounced;
}

/**
 * Throttle - Fuehrt Funktion hoechstens einmal pro Zeitraum aus
 * Ideal fuer: Scroll-Handler, Maus-Bewegung, Resize
 */
function throttle(func, limit = 100) {
    let inThrottle = false;
    let lastArgs = null;

    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => {
                inThrottle = false;
                if (lastArgs) {
                    func.apply(this, lastArgs);
                    lastArgs = null;
                }
            }, limit);
        } else {
            lastArgs = args;
        }
    };
}


// ============================================
// LAZY LOADER
// ============================================
const LazyLoader = {
    observer: null,

    /**
     * Initialisiert IntersectionObserver fuer Lazy Loading
     */
    init(options = {}) {
        if (this.observer) return;

        const defaultOptions = {
            root: null,
            rootMargin: '100px', // 100px vor Sichtbarkeit laden
            threshold: 0
        };

        this.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    this._loadElement(entry.target);
                    this.observer.unobserve(entry.target);
                }
            });
        }, { ...defaultOptions, ...options });

        // Alle [data-lazy-src] Elemente beobachten
        document.querySelectorAll('[data-lazy-src]').forEach(el => {
            this.observer.observe(el);
        });
    },

    /**
     * Laedt ein lazy Element
     */
    _loadElement(el) {
        const src = el.dataset.lazySrc;
        if (!src) return;

        if (el.tagName === 'IFRAME') {
            el.src = src;
        } else if (el.tagName === 'IMG') {
            el.src = src;
        } else {
            // Fuer andere Elemente: data-lazy-content laden
            el.innerHTML = el.dataset.lazyContent || '';
        }

        el.removeAttribute('data-lazy-src');
        el.classList.add('lazy-loaded');
        el.dispatchEvent(new CustomEvent('lazyloaded'));
    },

    /**
     * Fuegt Element zur Beobachtung hinzu
     */
    observe(element) {
        if (this.observer && element.dataset.lazySrc) {
            this.observer.observe(element);
        }
    },

    /**
     * Laedt alle ausstehenden Elemente sofort
     */
    loadAll() {
        document.querySelectorAll('[data-lazy-src]').forEach(el => {
            this._loadElement(el);
        });
    }
};


// ============================================
// DOM BATCHER
// ============================================
const DOMBatcher = {
    _queue: [],
    _scheduled: false,

    /**
     * Fuegt DOM-Operation zur Queue hinzu
     */
    add(operation) {
        this._queue.push(operation);
        this._schedule();
    },

    _schedule() {
        if (this._scheduled) return;
        this._scheduled = true;

        requestAnimationFrame(() => {
            this._flush();
        });
    },

    _flush() {
        const operations = this._queue.splice(0);
        this._scheduled = false;

        // Alle Operationen in einem Frame ausfuehren
        operations.forEach(op => {
            try {
                op();
            } catch (e) {
                console.error('[DOMBatcher] Operation failed:', e);
            }
        });
    }
};


// ============================================
// VIRTUAL SCROLLER (fuer lange Listen)
// ============================================
class VirtualScroller {
    constructor(container, options = {}) {
        this.container = typeof container === 'string'
            ? document.querySelector(container)
            : container;

        this.options = {
            itemHeight: options.itemHeight || 36,
            overscan: options.overscan || 5,
            renderItem: options.renderItem || (item => `<div>${item}</div>`)
        };

        this.items = [];
        this.scrollTop = 0;
        this.containerHeight = 0;

        this._init();
    }

    _init() {
        if (!this.container) return;

        // Wrapper erstellen
        this.wrapper = document.createElement('div');
        this.wrapper.style.cssText = 'position: relative; overflow: hidden;';

        this.content = document.createElement('div');
        this.content.style.cssText = 'position: absolute; left: 0; right: 0;';

        this.wrapper.appendChild(this.content);
        this.container.innerHTML = '';
        this.container.appendChild(this.wrapper);
        this.container.style.overflow = 'auto';

        // Scroll-Handler mit Throttle
        this.container.addEventListener('scroll', throttle(() => {
            this.scrollTop = this.container.scrollTop;
            this._render();
        }, 16));

        // Resize beobachten
        if (window.ResizeObserver) {
            new ResizeObserver(() => {
                this.containerHeight = this.container.clientHeight;
                this._render();
            }).observe(this.container);
        }

        this.containerHeight = this.container.clientHeight;
    }

    setItems(items) {
        this.items = items || [];
        this.wrapper.style.height = `${this.items.length * this.options.itemHeight}px`;
        this._render();
    }

    _render() {
        if (!this.items.length) {
            this.content.innerHTML = '';
            return;
        }

        const { itemHeight, overscan, renderItem } = this.options;

        // Berechne sichtbaren Bereich
        const startIndex = Math.max(0, Math.floor(this.scrollTop / itemHeight) - overscan);
        const endIndex = Math.min(
            this.items.length,
            Math.ceil((this.scrollTop + this.containerHeight) / itemHeight) + overscan
        );

        // Position des Content-Wrappers
        this.content.style.top = `${startIndex * itemHeight}px`;

        // Nur sichtbare Items rendern
        const visibleItems = this.items.slice(startIndex, endIndex);
        this.content.innerHTML = visibleItems.map((item, i) => {
            const html = renderItem(item, startIndex + i);
            return `<div style="height: ${itemHeight}px; overflow: hidden;">${html}</div>`;
        }).join('');
    }

    refresh() {
        this._render();
    }

    scrollToIndex(index) {
        const top = index * this.options.itemHeight;
        this.container.scrollTop = top;
    }
}


// ============================================
// SKELETON LOADER
// ============================================
const SkeletonLoader = {
    /**
     * Zeigt Skeleton-Placeholder in einem Container
     */
    show(container, options = {}) {
        const el = typeof container === 'string'
            ? document.querySelector(container)
            : container;
        if (!el) return;

        const rows = options.rows || 5;
        const type = options.type || 'table';

        if (type === 'table') {
            el.innerHTML = this._tableSkeletonHTML(rows, options.columns || 4);
        } else if (type === 'list') {
            el.innerHTML = this._listSkeletonHTML(rows);
        } else if (type === 'form') {
            el.innerHTML = this._formSkeletonHTML(options.fields || 6);
        }

        el.classList.add('skeleton-loading');
    },

    /**
     * Entfernt Skeleton und zeigt echten Inhalt
     */
    hide(container) {
        const el = typeof container === 'string'
            ? document.querySelector(container)
            : container;
        if (el) {
            el.classList.remove('skeleton-loading');
        }
    },

    _tableSkeletonHTML(rows, cols) {
        let html = '<table class="skeleton-table" style="width: 100%;">';
        for (let r = 0; r < rows; r++) {
            html += '<tr>';
            for (let c = 0; c < cols; c++) {
                const width = 60 + Math.random() * 30;
                html += `<td><div class="skeleton-pulse" style="height: 14px; width: ${width}%; background: #e0e0e0; border-radius: 3px;"></div></td>`;
            }
            html += '</tr>';
        }
        html += '</table>';
        return html;
    },

    _listSkeletonHTML(rows) {
        let html = '<div class="skeleton-list">';
        for (let r = 0; r < rows; r++) {
            const width = 50 + Math.random() * 40;
            html += `<div class="skeleton-list-item" style="padding: 8px 0;">
                <div class="skeleton-pulse" style="height: 16px; width: ${width}%; background: #e0e0e0; border-radius: 3px;"></div>
            </div>`;
        }
        html += '</div>';
        return html;
    },

    _formSkeletonHTML(fields) {
        let html = '<div class="skeleton-form">';
        for (let f = 0; f < fields; f++) {
            html += `<div style="margin-bottom: 12px;">
                <div class="skeleton-pulse" style="height: 12px; width: 80px; background: #d0d0d0; margin-bottom: 4px; border-radius: 2px;"></div>
                <div class="skeleton-pulse" style="height: 24px; width: 100%; background: #e8e8e8; border-radius: 3px;"></div>
            </div>`;
        }
        html += '</div>';
        return html;
    }
};


// ============================================
// PRELOADER (fuer Formular-Daten)
// ============================================
const Preloader = {
    _preloaded: new Map(),

    /**
     * Laedt Daten im Voraus (z.B. beim Hover)
     */
    async preload(type, id) {
        const key = `${type}:${id}`;
        if (this._preloaded.has(key)) return;

        try {
            const data = await window.Bridge?.loadData(type, id);
            this._preloaded.set(key, {
                data: data,
                timestamp: Date.now()
            });
        } catch (e) {
            console.warn('[Preloader] Failed to preload:', key, e);
        }
    },

    /**
     * Holt vorgeladene Daten (oder null)
     */
    get(type, id) {
        const key = `${type}:${id}`;
        const cached = this._preloaded.get(key);

        // Cache nur 30 Sekunden gueltig
        if (cached && (Date.now() - cached.timestamp) < 30000) {
            this._preloaded.delete(key);
            return cached.data;
        }
        return null;
    },

    /**
     * Laedt alle Dropdown-Stammdaten vor
     */
    async preloadDropdowns() {
        const types = ['status', 'kunden', 'objekte', 'orte', 'dienstkleidung'];
        await Promise.all(types.map(type =>
            RequestCache.fetch(`http://localhost:5000/api/${type}`)
        ));
        console.debug('[Preloader] Dropdowns geladen');
    }
};


// ============================================
// PERFORMANCE MONITOR
// ============================================
const PerfMonitor = {
    _marks: new Map(),

    start(label) {
        this._marks.set(label, performance.now());
    },

    end(label, log = true) {
        const start = this._marks.get(label);
        if (!start) return 0;

        const duration = performance.now() - start;
        this._marks.delete(label);

        if (log) {
            const color = duration < 100 ? 'green' : duration < 300 ? 'orange' : 'red';
            console.log(`%c[Perf] ${label}: ${duration.toFixed(1)}ms`, `color: ${color}`);
        }

        return duration;
    },

    measure(label, fn) {
        this.start(label);
        const result = fn();
        if (result instanceof Promise) {
            return result.finally(() => this.end(label));
        }
        this.end(label);
        return result;
    }
};


// ============================================
// CSS fuer Skeleton Animation (wird einmalig injiziert)
// ============================================
(function injectSkeletonCSS() {
    if (document.getElementById('skeleton-styles')) return;

    const style = document.createElement('style');
    style.id = 'skeleton-styles';
    style.textContent = `
        @keyframes skeleton-pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .skeleton-pulse {
            animation: skeleton-pulse 1.2s ease-in-out infinite;
        }
        .skeleton-loading {
            pointer-events: none;
        }
        .lazy-loaded {
            animation: fadeIn 0.3s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    `;
    document.head.appendChild(style);
})();


// ============================================
// EXPORT
// ============================================
const Performance = {
    RequestCache,
    debounce,
    throttle,
    LazyLoader,
    DOMBatcher,
    VirtualScroller,
    SkeletonLoader,
    Preloader,
    PerfMonitor
};

// Globaler Zugriff
window.Performance = Performance;

// ES Module Export
export {
    RequestCache,
    debounce,
    throttle,
    LazyLoader,
    DOMBatcher,
    VirtualScroller,
    SkeletonLoader,
    Preloader,
    PerfMonitor
};

export default Performance;
