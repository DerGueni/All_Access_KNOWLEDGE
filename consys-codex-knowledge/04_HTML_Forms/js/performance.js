/**
 * performance.js
 * Performance-Optimierungen fuer CONSYS HTML Frontend
 */

// ============================================
// 1. REQUEST CACHE - Reduziert redundante API-Calls
// ============================================
const RequestCache = {
    _cache: new Map(),
    _ttl: 30000, // 30 Sekunden Default-TTL

    /**
     * Cached Fetch mit TTL
     */
    async fetch(url, options = {}, ttl = this._ttl) {
        const cacheKey = url + JSON.stringify(options);
        const cached = this._cache.get(cacheKey);

        if (cached && Date.now() - cached.timestamp < ttl) {
            return cached.data;
        }

        const response = await fetch(url, options);
        const data = await response.json();

        this._cache.set(cacheKey, {
            data,
            timestamp: Date.now()
        });

        return data;
    },

    /**
     * Cache invalidieren
     */
    invalidate(urlPattern) {
        if (!urlPattern) {
            this._cache.clear();
            return;
        }

        for (const key of this._cache.keys()) {
            if (key.includes(urlPattern)) {
                this._cache.delete(key);
            }
        }
    },

    /**
     * Cache-Groesse pruefen
     */
    getStats() {
        return {
            size: this._cache.size,
            keys: Array.from(this._cache.keys())
        };
    }
};

// ============================================
// 2. DEBOUNCE & THROTTLE - Reduziert Event-Frequenz
// ============================================

/**
 * Debounce - Fuehrt Funktion erst nach Pause aus
 */
function debounce(fn, delay = 250) {
    let timeoutId;
    return function(...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn.apply(this, args), delay);
    };
}

/**
 * Throttle - Limitiert Ausfuehrungsfrequenz
 */
function throttle(fn, limit = 100) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            fn.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// ============================================
// 3. DOM BATCH UPDATES - Reduziert Reflows
// ============================================

/**
 * BatchUpdater - Sammelt DOM-Aenderungen
 */
const BatchUpdater = {
    _pending: [],
    _scheduled: false,

    /**
     * Aenderung einplanen
     */
    queue(fn) {
        this._pending.push(fn);

        if (!this._scheduled) {
            this._scheduled = true;
            requestAnimationFrame(() => this.flush());
        }
    },

    /**
     * Alle Aenderungen ausfuehren
     */
    flush() {
        const updates = this._pending.slice();
        this._pending = [];
        this._scheduled = false;

        updates.forEach(fn => {
            try {
                fn();
            } catch (e) {
                console.error('[BatchUpdater] Fehler:', e);
            }
        });
    }
};

// ============================================
// 4. VIRTUAL SCROLL - Fuer lange Listen
// ============================================

class VirtualScroller {
    constructor(container, options = {}) {
        this.container = container;
        this.itemHeight = options.itemHeight || 36;
        this.buffer = options.buffer || 5;
        this.items = [];
        this.renderItem = options.renderItem || ((item) => `<div>${item}</div>`);

        this._viewport = null;
        this._content = null;
        this._visibleStart = 0;
        this._visibleEnd = 0;

        this._init();
    }

    _init() {
        // Viewport erstellen
        this._viewport = document.createElement('div');
        this._viewport.style.cssText = 'overflow-y:auto;height:100%;position:relative;';

        this._content = document.createElement('div');
        this._content.style.cssText = 'position:relative;';

        this._viewport.appendChild(this._content);
        this.container.appendChild(this._viewport);

        // Scroll-Handler mit Throttle
        this._viewport.addEventListener('scroll', throttle(() => this._onScroll(), 16));
    }

    setItems(items) {
        this.items = items;
        this._content.style.height = `${items.length * this.itemHeight}px`;
        this._render();
    }

    _onScroll() {
        this._render();
    }

    _render() {
        const scrollTop = this._viewport.scrollTop;
        const viewportHeight = this._viewport.clientHeight;

        const start = Math.max(0, Math.floor(scrollTop / this.itemHeight) - this.buffer);
        const end = Math.min(this.items.length, Math.ceil((scrollTop + viewportHeight) / this.itemHeight) + this.buffer);

        // Nur neu rendern wenn sich der Bereich geaendert hat
        if (start === this._visibleStart && end === this._visibleEnd) {
            return;
        }

        this._visibleStart = start;
        this._visibleEnd = end;

        // Nur sichtbare Items rendern
        let html = '';
        for (let i = start; i < end; i++) {
            const item = this.items[i];
            const top = i * this.itemHeight;
            html += `<div style="position:absolute;top:${top}px;left:0;right:0;height:${this.itemHeight}px;">
                ${this.renderItem(item, i)}
            </div>`;
        }

        this._content.innerHTML = html;
    }

    scrollToIndex(index) {
        this._viewport.scrollTop = index * this.itemHeight;
    }
}

// ============================================
// 5. LAZY LOADING - Fuer Subforms/iframes
// ============================================

const LazyLoader = {
    _observer: null,
    _loaded: new Set(),

    init() {
        if (this._observer) return;

        this._observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    this._loadElement(entry.target);
                }
            });
        }, {
            rootMargin: '100px'
        });
    },

    observe(element) {
        if (!this._observer) this.init();
        this._observer.observe(element);
    },

    _loadElement(element) {
        const src = element.dataset.lazySrc;
        if (!src || this._loaded.has(element)) return;

        if (element.tagName === 'IFRAME') {
            element.src = src;
        } else if (element.tagName === 'IMG') {
            element.src = src;
        }

        this._loaded.add(element);
        this._observer.unobserve(element);
    }
};

// ============================================
// 6. MEMORY MANAGEMENT - Cleanup
// ============================================

const MemoryManager = {
    _cleanupFns: [],

    /**
     * Cleanup-Funktion registrieren
     */
    onCleanup(fn) {
        this._cleanupFns.push(fn);
    },

    /**
     * Alle Cleanups ausfuehren
     */
    cleanup() {
        this._cleanupFns.forEach(fn => {
            try {
                fn();
            } catch (e) {
                console.error('[MemoryManager] Cleanup-Fehler:', e);
            }
        });
        this._cleanupFns = [];

        // Request-Cache leeren
        RequestCache.invalidate();
    }
};

// Cleanup bei Page-Unload
window.addEventListener('beforeunload', () => MemoryManager.cleanup());

// ============================================
// 7. RENDER OPTIMIZATION - DocumentFragment
// ============================================

/**
 * Effizientes Rendering einer Liste
 */
function renderList(container, items, renderFn) {
    const fragment = document.createDocumentFragment();

    items.forEach((item, index) => {
        const el = renderFn(item, index);
        if (el) fragment.appendChild(el);
    });

    container.innerHTML = '';
    container.appendChild(fragment);
}

/**
 * Effizientes Table-Body Rendering
 */
function renderTableBody(tbody, rows, renderRowFn) {
    const fragment = document.createDocumentFragment();

    rows.forEach((row, index) => {
        const tr = renderRowFn(row, index);
        if (tr) fragment.appendChild(tr);
    });

    tbody.innerHTML = '';
    tbody.appendChild(fragment);
}

// ============================================
// 8. EVENT DELEGATION - Weniger Event-Listener
// ============================================

/**
 * Event-Delegation Helper
 */
function delegate(container, eventType, selector, handler) {
    container.addEventListener(eventType, (e) => {
        const target = e.target.closest(selector);
        if (target && container.contains(target)) {
            handler.call(target, e, target);
        }
    });
}

// ============================================
// 9. CSS ANIMATION PERFORMANCE
// ============================================

/**
 * Forciert GPU-Beschleunigung
 */
function enableGPUAcceleration(element) {
    element.style.transform = 'translateZ(0)';
    element.style.willChange = 'transform';
}

/**
 * Deaktiviert GPU nach Animation
 */
function disableGPUAcceleration(element) {
    element.style.transform = '';
    element.style.willChange = 'auto';
}

// ============================================
// 10. PERFORMANCE MONITORING
// ============================================

const PerfMonitor = {
    _marks: new Map(),

    start(label) {
        this._marks.set(label, performance.now());
    },

    end(label) {
        const start = this._marks.get(label);
        if (!start) return null;

        const duration = performance.now() - start;
        this._marks.delete(label);

        if (duration > 100) {
            console.warn(`[Perf] ${label}: ${duration.toFixed(2)}ms (langsam!)`);
        }

        return duration;
    },

    measure(label, fn) {
        this.start(label);
        const result = fn();
        this.end(label);
        return result;
    },

    async measureAsync(label, fn) {
        this.start(label);
        const result = await fn();
        this.end(label);
        return result;
    }
};

// ============================================
// EXPORTS
// ============================================

window.Performance = {
    RequestCache,
    BatchUpdater,
    VirtualScroller,
    LazyLoader,
    MemoryManager,
    PerfMonitor,
    debounce,
    throttle,
    renderList,
    renderTableBody,
    delegate,
    enableGPUAcceleration,
    disableGPUAcceleration
};

// Auto-Init LazyLoader
document.addEventListener('DOMContentLoaded', () => {
    LazyLoader.init();

    // Alle lazy-load Elemente beobachten
    document.querySelectorAll('[data-lazy-src]').forEach(el => {
        LazyLoader.observe(el);
    });
});

console.log('[Performance] Module geladen');
