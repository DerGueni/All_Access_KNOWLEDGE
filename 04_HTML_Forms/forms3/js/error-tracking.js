/**
 * Error Tracking System
 * Frontend-Fehler erfassen, loggen und optional an Server senden
 *
 * Verwendung:
 *   ErrorTracker.init({ endpoint: '/api/errors', console: true });
 *   ErrorTracker.captureError(new Error('Test'));
 *   ErrorTracker.captureMessage('Info', 'warning');
 */

'use strict';

const ErrorTracker = (function() {
    let config = {
        endpoint: null,           // API-Endpoint fuer Fehler-Reports
        console: true,            // Fehler in Console ausgeben
        maxErrors: 50,            // Max gespeicherte Fehler
        sampleRate: 1.0,          // 1.0 = 100% der Fehler erfassen
        ignorePatterns: [],       // Regex-Patterns zum Ignorieren
        context: {},              // Zusaetzlicher Kontext (User, Version, etc.)
        onError: null             // Callback bei Fehler
    };

    let errorLog = [];
    let initialized = false;

    // Fehler-Objekt erstellen
    function createErrorEntry(error, type = 'error', extra = {}) {
        const entry = {
            id: crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(36) + Math.random().toString(36).substr(2),
            timestamp: new Date().toISOString(),
            type: type,
            message: error?.message || String(error),
            stack: error?.stack || null,
            url: window.location.href,
            userAgent: navigator.userAgent,
            context: { ...config.context, ...extra }
        };

        // Browser-Info
        entry.browser = {
            language: navigator.language,
            platform: navigator.platform,
            cookiesEnabled: navigator.cookieEnabled,
            online: navigator.onLine,
            screenWidth: window.screen?.width,
            screenHeight: window.screen?.height,
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight
        };

        return entry;
    }

    // Fehler loggen
    function logError(entry) {
        // Sample Rate pruefen
        if (Math.random() > config.sampleRate) {
            return;
        }

        // Ignore Patterns pruefen
        for (const pattern of config.ignorePatterns) {
            if (pattern.test(entry.message) || (entry.stack && pattern.test(entry.stack))) {
                return;
            }
        }

        // In Log speichern
        errorLog.unshift(entry);
        if (errorLog.length > config.maxErrors) {
            errorLog.pop();
        }

        // Console-Ausgabe
        if (config.console) {
            const style = entry.type === 'error' ? 'color: #dc3545; font-weight: bold' :
                         entry.type === 'warning' ? 'color: #ffc107; font-weight: bold' :
                         'color: #17a2b8';
            console.groupCollapsed(`%c[ErrorTracker] ${entry.type.toUpperCase()}: ${entry.message}`, style);
            console.log('Timestamp:', entry.timestamp);
            console.log('URL:', entry.url);
            if (entry.stack) console.log('Stack:', entry.stack);
            if (Object.keys(entry.context).length) console.log('Context:', entry.context);
            console.groupEnd();
        }

        // Callback ausfuehren
        if (typeof config.onError === 'function') {
            try {
                config.onError(entry);
            } catch (e) {
                console.error('[ErrorTracker] onError callback failed:', e);
            }
        }

        // An Server senden
        if (config.endpoint) {
            sendToServer(entry);
        }
    }

    // An Server senden
    async function sendToServer(entry) {
        try {
            const response = await fetch(config.endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(entry),
                keepalive: true // Auch bei Page-Unload senden
            });

            if (!response.ok) {
                console.warn('[ErrorTracker] Server returned:', response.status);
            }
        } catch (e) {
            // Netzwerk-Fehler ignorieren (sonst Endlosschleife)
            console.warn('[ErrorTracker] Failed to send error to server');
        }
    }

    // Global Error Handler
    function handleGlobalError(event) {
        const entry = createErrorEntry(event.error || event.message, 'error', {
            filename: event.filename,
            lineno: event.lineno,
            colno: event.colno
        });
        logError(entry);
    }

    // Unhandled Promise Rejection Handler
    function handleUnhandledRejection(event) {
        const error = event.reason instanceof Error ? event.reason : new Error(String(event.reason));
        const entry = createErrorEntry(error, 'unhandled_rejection');
        logError(entry);
    }

    // Console.error ueberschreiben
    function wrapConsoleError() {
        const originalError = console.error;
        console.error = function(...args) {
            // Originalfunktion aufrufen
            originalError.apply(console, args);

            // Fehler erfassen
            const message = args.map(arg =>
                arg instanceof Error ? arg.message :
                typeof arg === 'object' ? JSON.stringify(arg) :
                String(arg)
            ).join(' ');

            const entry = createErrorEntry({ message }, 'console_error');
            logError(entry);
        };
    }

    // Fetch-Fehler abfangen
    function wrapFetch() {
        const originalFetch = window.fetch;
        window.fetch = async function(...args) {
            const url = typeof args[0] === 'string' ? args[0] : args[0]?.url || 'unknown';
            const method = args[1]?.method || 'GET';

            try {
                const response = await originalFetch.apply(this, args);

                // HTTP-Fehler loggen (4xx, 5xx)
                if (!response.ok && response.status >= 400) {
                    const entry = createErrorEntry(
                        { message: `HTTP ${response.status}: ${response.statusText}` },
                        'http_error',
                        { url, method, status: response.status }
                    );
                    logError(entry);
                }

                return response;
            } catch (error) {
                // Netzwerk-Fehler
                const entry = createErrorEntry(error, 'network_error', { url, method });
                logError(entry);
                throw error;
            }
        };
    }

    // Initialisierung
    function init(options = {}) {
        if (initialized) {
            console.warn('[ErrorTracker] Already initialized');
            return;
        }

        // Config uebernehmen
        Object.assign(config, options);

        // Event Listener registrieren
        window.addEventListener('error', handleGlobalError);
        window.addEventListener('unhandledrejection', handleUnhandledRejection);

        // Console.error wrappen (optional)
        if (options.wrapConsole !== false) {
            wrapConsoleError();
        }

        // Fetch wrappen (optional)
        if (options.wrapFetch !== false) {
            wrapFetch();
        }

        initialized = true;
        console.log('[ErrorTracker] Initialized', config.endpoint ? `(endpoint: ${config.endpoint})` : '(local only)');
    }

    return {
        /**
         * Initialisiert das Error Tracking
         * @param {Object} options - Konfiguration
         */
        init: init,

        /**
         * Fehler manuell erfassen
         * @param {Error|string} error - Fehler-Objekt oder Nachricht
         * @param {Object} extra - Zusaetzlicher Kontext
         */
        captureError: function(error, extra = {}) {
            if (!initialized) init();
            const err = error instanceof Error ? error : new Error(String(error));
            const entry = createErrorEntry(err, 'error', extra);
            logError(entry);
        },

        /**
         * Nachricht erfassen (Info, Warning)
         * @param {string} message - Nachricht
         * @param {string} level - Level: 'info', 'warning', 'error'
         * @param {Object} extra - Zusaetzlicher Kontext
         */
        captureMessage: function(message, level = 'info', extra = {}) {
            if (!initialized) init();
            const entry = createErrorEntry({ message }, level, extra);
            logError(entry);
        },

        /**
         * Kontext setzen (User-ID, Version, etc.)
         * @param {Object} context - Kontext-Daten
         */
        setContext: function(context) {
            Object.assign(config.context, context);
        },

        /**
         * User-Info setzen
         * @param {Object} user - { id, name, email }
         */
        setUser: function(user) {
            config.context.user = user;
        },

        /**
         * Fehler-Log abrufen
         * @returns {Array} Alle erfassten Fehler
         */
        getErrors: function() {
            return [...errorLog];
        },

        /**
         * Letzten Fehler abrufen
         * @returns {Object|null}
         */
        getLastError: function() {
            return errorLog[0] || null;
        },

        /**
         * Fehler-Log leeren
         */
        clearErrors: function() {
            errorLog = [];
        },

        /**
         * Fehler-Statistik
         * @returns {Object}
         */
        getStats: function() {
            const stats = {
                total: errorLog.length,
                byType: {},
                last24h: 0
            };

            const dayAgo = Date.now() - 24 * 60 * 60 * 1000;

            for (const entry of errorLog) {
                stats.byType[entry.type] = (stats.byType[entry.type] || 0) + 1;
                if (new Date(entry.timestamp).getTime() > dayAgo) {
                    stats.last24h++;
                }
            }

            return stats;
        },

        /**
         * Error Boundary fuer async Funktionen
         * @param {Function} fn - Async Funktion
         * @param {Object} extra - Zusaetzlicher Kontext
         * @returns {Function} Gewrappte Funktion
         */
        wrap: function(fn, extra = {}) {
            return async function(...args) {
                try {
                    return await fn.apply(this, args);
                } catch (error) {
                    ErrorTracker.captureError(error, { ...extra, args: args.slice(0, 3) });
                    throw error;
                }
            };
        },

        /**
         * Try-Catch Helper
         * @param {Function} fn - Funktion
         * @param {*} fallback - Fallback-Wert bei Fehler
         * @param {Object} extra - Zusaetzlicher Kontext
         */
        try: function(fn, fallback = null, extra = {}) {
            try {
                return fn();
            } catch (error) {
                this.captureError(error, extra);
                return fallback;
            }
        }
    };
})();

// Global verfuegbar
window.ErrorTracker = ErrorTracker;

// Auto-Init wenn shell.html geladen
document.addEventListener('DOMContentLoaded', function() {
    // Nur initialisieren wenn nicht bereits geschehen
    if (!window._errorTrackerInitialized) {
        ErrorTracker.init({
            console: true,
            maxErrors: 100,
            ignorePatterns: [
                /ResizeObserver loop/i,  // Chrome-Bug ignorieren
                /Script error\./i         // Cross-Origin-Fehler ohne Details
            ],
            context: {
                app: 'CONSYS',
                version: '3.0'
            }
        });
        window._errorTrackerInitialized = true;
    }
});
