/**
 * Debug Logger - Zentrales Logging-System
 *
 * Ersetzt console.log durch konfigurierbaren Logger.
 * In Produktion kann DEBUG_ENABLED auf false gesetzt werden.
 *
 * Verwendung:
 *   Logger.log('Nachricht');
 *   Logger.warn('Warnung');
 *   Logger.error('Fehler');
 *   Logger.info('Info');
 *   Logger.debug('Debug-Details');
 */

'use strict';

const Logger = (function() {
    // Konfiguration
    const CONFIG = {
        DEBUG_ENABLED: true,  // false fuer Produktion
        LOG_LEVEL: 'debug',   // 'error' | 'warn' | 'info' | 'debug'
        PREFIX: '[CONSYS]',
        SHOW_TIMESTAMP: true,
        STORE_LOGS: false,    // Logs im localStorage speichern
        MAX_STORED_LOGS: 100
    };

    const LEVELS = {
        error: 0,
        warn: 1,
        info: 2,
        debug: 3
    };

    let storedLogs = [];

    function getTimestamp() {
        if (!CONFIG.SHOW_TIMESTAMP) return '';
        const now = new Date();
        return `[${now.toLocaleTimeString('de-DE')}]`;
    }

    function shouldLog(level) {
        if (!CONFIG.DEBUG_ENABLED && level !== 'error') return false;
        return LEVELS[level] <= LEVELS[CONFIG.LOG_LEVEL];
    }

    function formatMessage(level, args) {
        const timestamp = getTimestamp();
        const prefix = CONFIG.PREFIX;
        const levelTag = `[${level.toUpperCase()}]`;
        return { prefix: `${timestamp} ${prefix} ${levelTag}`, args };
    }

    function storeLog(level, message) {
        if (!CONFIG.STORE_LOGS) return;

        storedLogs.push({
            timestamp: new Date().toISOString(),
            level,
            message: typeof message === 'object' ? JSON.stringify(message) : message
        });

        if (storedLogs.length > CONFIG.MAX_STORED_LOGS) {
            storedLogs = storedLogs.slice(-CONFIG.MAX_STORED_LOGS);
        }

        try {
            localStorage.setItem('consys_logs', JSON.stringify(storedLogs));
        } catch (e) {
            // Storage voll oder nicht verfuegbar
        }
    }

    return {
        log: function(...args) {
            if (!shouldLog('info')) return;
            const { prefix } = formatMessage('log', args);
            console.log(prefix, ...args);
            storeLog('log', args[0]);
        },

        info: function(...args) {
            if (!shouldLog('info')) return;
            const { prefix } = formatMessage('info', args);
            console.info(prefix, ...args);
            storeLog('info', args[0]);
        },

        warn: function(...args) {
            if (!shouldLog('warn')) return;
            const { prefix } = formatMessage('warn', args);
            console.warn(prefix, ...args);
            storeLog('warn', args[0]);
        },

        error: function(...args) {
            // Errors werden IMMER geloggt
            const { prefix } = formatMessage('error', args);
            console.error(prefix, ...args);
            storeLog('error', args[0]);
        },

        debug: function(...args) {
            if (!shouldLog('debug')) return;
            const { prefix } = formatMessage('debug', args);
            console.debug(prefix, ...args);
            storeLog('debug', args[0]);
        },

        // Gruppierung fuer komplexe Logs
        group: function(label) {
            if (!CONFIG.DEBUG_ENABLED) return;
            console.group(`${CONFIG.PREFIX} ${label}`);
        },

        groupEnd: function() {
            if (!CONFIG.DEBUG_ENABLED) return;
            console.groupEnd();
        },

        // Performance-Messung
        time: function(label) {
            if (!CONFIG.DEBUG_ENABLED) return;
            console.time(`${CONFIG.PREFIX} ${label}`);
        },

        timeEnd: function(label) {
            if (!CONFIG.DEBUG_ENABLED) return;
            console.timeEnd(`${CONFIG.PREFIX} ${label}`);
        },

        // Konfiguration aendern
        setConfig: function(key, value) {
            if (CONFIG.hasOwnProperty(key)) {
                CONFIG[key] = value;
            }
        },

        // Logs exportieren
        exportLogs: function() {
            return storedLogs;
        },

        // Logs loeschen
        clearLogs: function() {
            storedLogs = [];
            try {
                localStorage.removeItem('consys_logs');
            } catch (e) {}
        },

        // Produktionsmodus aktivieren
        enableProductionMode: function() {
            CONFIG.DEBUG_ENABLED = false;
            CONFIG.STORE_LOGS = false;
        }
    };
})();

// Global verfuegbar machen
window.Logger = Logger;

// Optional: console.log ueberschreiben (auskommentiert fuer Sicherheit)
// window._originalConsoleLog = console.log;
// console.log = function(...args) { Logger.log(...args); };
