/**
 * logger.js - Zentrales Event-Logging-System fuer CONSYS HTML-Formulare
 *
 * Erweitert das bestehende debug-logger.js um strukturierte Event-Logs.
 * Trackt Benutzeraktionen, API-Calls und Systemereignisse.
 *
 * VERWENDUNG:
 *   // Event loggen
 *   Logger.log('FORM_OPEN', 'frm_va_Auftragstamm', null, { va_id: 123 });
 *   Logger.log('BUTTON_CLICK', 'frm_va_Auftragstamm', 'btnSave');
 *   Logger.log('API_CALL', 'frm_va_Auftragstamm', null, { endpoint: '/auftraege/123' });
 *
 *   // Logs abrufen
 *   const logs = Logger.getRecentLogs(50);
 *   const filtered = Logger.filterLogs({ action: 'BUTTON_CLICK', formular: 'frm_va_Auftragstamm' });
 *
 *   // Export
 *   Logger.exportLogs();           // Download als JSON
 *   Logger.exportLogsCSV();        // Download als CSV
 *   Logger.copyLogsToClipboard();  // In Zwischenablage
 *
 * EINSTELLUNGEN:
 *   Logger.setConfig('STORE_LOGS', true);   // localStorage aktivieren
 *   Logger.setConfig('MAX_STORED_LOGS', 500);
 *   Logger.enableProductionMode();          // Nur Errors loggen
 *
 * LOGS EINSEHEN:
 *   - Browser DevTools Console: Logger.getRecentLogs()
 *   - localStorage: consys_event_logs
 *   - Export: Logger.exportLogs() / Logger.exportLogsCSV()
 *
 * @author Claude Code
 * @version 1.0.0
 * @date 2026-01-07
 */

'use strict';

// Falls debug-logger.js noch nicht geladen, warten wir darauf
// oder erstellen ein minimales Logger-Objekt
if (typeof window.Logger === 'undefined') {
    window.Logger = {};
}

// Event-Logging-Erweiterung
(function(Logger) {
    // ============================================
    // KONFIGURATION
    // ============================================
    const EVENT_CONFIG = {
        ENABLED: true,              // Event-Logging aktiviert
        STORE_LOGS: true,           // In localStorage speichern
        MAX_STORED_LOGS: 500,       // Max. Anzahl gespeicherter Logs
        LOG_TO_CONSOLE: true,       // Auch in Console ausgeben
        PREFIX: '[CONSYS]',         // Log-Prefix
        INCLUDE_STACK: false,       // Stack-Trace mitloggen (Performance!)
        AUTO_FLUSH_INTERVAL: 60000, // Auto-Save alle 60 Sekunden
        SESSION_ID: generateSessionId()
    };

    // Bekannte Event-Typen mit Beschreibungen
    const EVENT_TYPES = {
        // Formular-Events
        FORM_OPEN: 'Formular geoeffnet',
        FORM_CLOSE: 'Formular geschlossen',
        FORM_SAVE: 'Formular gespeichert',
        FORM_LOAD: 'Formulardaten geladen',
        FORM_ERROR: 'Formularfehler',

        // Button-Events
        BUTTON_CLICK: 'Button geklickt',

        // Navigation
        NAV_FIRST: 'Zum ersten Datensatz',
        NAV_PREV: 'Zum vorherigen Datensatz',
        NAV_NEXT: 'Zum naechsten Datensatz',
        NAV_LAST: 'Zum letzten Datensatz',
        NAV_GOTO: 'Zu Datensatz navigiert',

        // API-Events
        API_CALL: 'API-Request gestartet',
        API_RESPONSE: 'API-Response erhalten',
        API_ERROR: 'API-Fehler',
        API_CACHE_HIT: 'Cache-Treffer',

        // Daten-Events
        RECORD_NEW: 'Neuer Datensatz',
        RECORD_SAVE: 'Datensatz gespeichert',
        RECORD_DELETE: 'Datensatz geloescht',
        RECORD_LOAD: 'Datensatz geladen',

        // Export-Events
        EXPORT_START: 'Export gestartet',
        EXPORT_COMPLETE: 'Export abgeschlossen',
        EXPORT_ERROR: 'Export-Fehler',

        // Email-Events
        EMAIL_SEND: 'E-Mail gesendet',
        EMAIL_ERROR: 'E-Mail-Fehler',

        // System-Events
        SESSION_START: 'Session gestartet',
        SESSION_END: 'Session beendet',
        ERROR: 'Allgemeiner Fehler',
        WARNING: 'Warnung'
    };

    // Event-Log-Speicher (Memory)
    let eventLogs = [];
    let flushTimer = null;

    // ============================================
    // HILFSFUNKTIONEN
    // ============================================

    /**
     * Generiert eine eindeutige Session-ID
     */
    function generateSessionId() {
        return 'sess_' + Date.now().toString(36) + '_' + Math.random().toString(36).substr(2, 9);
    }

    /**
     * Formatiert Timestamp fuer Anzeige
     */
    function formatTimestamp(isoString) {
        try {
            const d = new Date(isoString);
            return d.toLocaleString('de-DE', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
        } catch (e) {
            return isoString;
        }
    }

    /**
     * Laedt gespeicherte Logs aus localStorage
     */
    function loadStoredLogs() {
        try {
            const stored = localStorage.getItem('consys_event_logs');
            if (stored) {
                eventLogs = JSON.parse(stored);
                // Alte Logs bereinigen
                if (eventLogs.length > EVENT_CONFIG.MAX_STORED_LOGS) {
                    eventLogs = eventLogs.slice(-EVENT_CONFIG.MAX_STORED_LOGS);
                }
            }
        } catch (e) {
            console.warn('[Logger] Fehler beim Laden der Logs:', e);
            eventLogs = [];
        }
    }

    /**
     * Speichert Logs in localStorage
     */
    function saveLogs() {
        if (!EVENT_CONFIG.STORE_LOGS) return;

        try {
            // Auf maximale Groesse begrenzen
            if (eventLogs.length > EVENT_CONFIG.MAX_STORED_LOGS) {
                eventLogs = eventLogs.slice(-EVENT_CONFIG.MAX_STORED_LOGS);
            }
            localStorage.setItem('consys_event_logs', JSON.stringify(eventLogs));
        } catch (e) {
            // localStorage voll - aelteste Haelfte loeschen
            console.warn('[Logger] localStorage voll, loesche aeltere Logs');
            eventLogs = eventLogs.slice(-Math.floor(EVENT_CONFIG.MAX_STORED_LOGS / 2));
            try {
                localStorage.setItem('consys_event_logs', JSON.stringify(eventLogs));
            } catch (e2) {
                // Aufgeben
            }
        }
    }

    /**
     * Startet Auto-Flush Timer
     */
    function startAutoFlush() {
        if (flushTimer) return;
        flushTimer = setInterval(saveLogs, EVENT_CONFIG.AUTO_FLUSH_INTERVAL);
    }

    /**
     * Ermittelt aktuelles Formular aus URL oder DOM
     */
    function detectCurrentForm() {
        // 1. Aus URL
        const path = window.location.pathname;
        const match = path.match(/([^\/]+)\.html$/);
        if (match) {
            return match[1];
        }

        // 2. Aus body data-attribute
        const body = document.body;
        if (body && body.dataset.form) {
            return body.dataset.form;
        }

        // 3. Aus title
        const title = document.title;
        if (title) {
            const formMatch = title.match(/^(frm_[^\s-]+)/);
            if (formMatch) return formMatch[1];
        }

        return 'unknown';
    }

    // ============================================
    // HAUPT-LOGGING-FUNKTION
    // ============================================

    /**
     * Loggt ein strukturiertes Event
     *
     * @param {string} action - Event-Typ (z.B. 'FORM_OPEN', 'BUTTON_CLICK')
     * @param {string} formular - Formularname (optional, wird auto-detected)
     * @param {string} control - Control/Button-Name (optional)
     * @param {object} details - Zusaetzliche Details (optional)
     * @returns {object} Das erstellte Log-Entry
     */
    Logger.log = function(action, formular, control, details) {
        if (!EVENT_CONFIG.ENABLED) return null;

        // Falls nur action und details uebergeben (Kurzform)
        if (typeof formular === 'object' && !control && !details) {
            details = formular;
            formular = null;
            control = null;
        }

        const entry = {
            id: Date.now().toString(36) + Math.random().toString(36).substr(2, 5),
            action: action,
            actionDesc: EVENT_TYPES[action] || action,
            formular: formular || detectCurrentForm(),
            control: control || null,
            timestamp: new Date().toISOString(),
            sessionId: EVENT_CONFIG.SESSION_ID,
            details: details || {}
        };

        // Optional: Stack-Trace (nur im Debug-Modus)
        if (EVENT_CONFIG.INCLUDE_STACK) {
            try {
                throw new Error();
            } catch (e) {
                entry.stack = e.stack.split('\n').slice(2, 5).join('\n');
            }
        }

        // In Memory speichern
        eventLogs.push(entry);

        // Auf Max begrenzen
        if (eventLogs.length > EVENT_CONFIG.MAX_STORED_LOGS * 1.2) {
            eventLogs = eventLogs.slice(-EVENT_CONFIG.MAX_STORED_LOGS);
        }

        // Console-Ausgabe
        if (EVENT_CONFIG.LOG_TO_CONSOLE) {
            const prefix = EVENT_CONFIG.PREFIX;
            const ts = formatTimestamp(entry.timestamp).split(', ')[1]; // Nur Zeit
            const controlStr = control ? ` [${control}]` : '';
            const detailsStr = Object.keys(entry.details).length > 0
                ? ' ' + JSON.stringify(entry.details)
                : '';

            // Farbcodierung nach Event-Typ
            let style = 'color: #555';
            if (action.startsWith('API_')) style = 'color: #0066cc';
            if (action.includes('ERROR')) style = 'color: #cc0000';
            if (action.includes('SAVE') || action.includes('COMPLETE')) style = 'color: #008800';
            if (action.startsWith('BUTTON')) style = 'color: #6600cc';

            console.log(
                `%c${prefix} [${ts}] ${action}${controlStr} - ${entry.formular}${detailsStr}`,
                style
            );
        }

        return entry;
    };

    // ============================================
    // SPEZIALISIERTE LOG-METHODEN
    // ============================================

    /**
     * Loggt Formular-Oeffnung
     */
    Logger.formOpen = function(formular, params) {
        return Logger.log('FORM_OPEN', formular, null, params || {});
    };

    /**
     * Loggt Formular-Schliessung
     */
    Logger.formClose = function(formular) {
        return Logger.log('FORM_CLOSE', formular);
    };

    /**
     * Loggt Button-Klick
     */
    Logger.buttonClick = function(buttonId, formular) {
        return Logger.log('BUTTON_CLICK', formular, buttonId);
    };

    /**
     * Loggt API-Call
     */
    Logger.apiCall = function(endpoint, method, params) {
        return Logger.log('API_CALL', null, null, {
            endpoint: endpoint,
            method: method || 'GET',
            params: params
        });
    };

    /**
     * Loggt API-Response
     */
    Logger.apiResponse = function(endpoint, status, duration) {
        return Logger.log('API_RESPONSE', null, null, {
            endpoint: endpoint,
            status: status,
            duration: duration ? `${duration}ms` : undefined
        });
    };

    /**
     * Loggt API-Fehler
     */
    Logger.apiError = function(endpoint, error) {
        return Logger.log('API_ERROR', null, null, {
            endpoint: endpoint,
            error: error instanceof Error ? error.message : error
        });
    };

    /**
     * Loggt Export-Start
     */
    Logger.exportStart = function(type, target) {
        return Logger.log('EXPORT_START', null, null, {
            type: type,
            target: target
        });
    };

    /**
     * Loggt Export-Ende
     */
    Logger.exportComplete = function(type, filename, rows) {
        return Logger.log('EXPORT_COMPLETE', null, null, {
            type: type,
            filename: filename,
            rows: rows
        });
    };

    /**
     * Loggt E-Mail-Versand
     */
    Logger.emailSend = function(recipient, subject) {
        return Logger.log('EMAIL_SEND', null, null, {
            recipient: recipient ? recipient.substr(0, 3) + '***' : 'unknown', // Datenschutz
            subject: subject
        });
    };

    /**
     * Loggt Fehler
     */
    Logger.logError = function(error, context) {
        return Logger.log('ERROR', null, null, {
            message: error instanceof Error ? error.message : error,
            context: context
        });
    };

    // ============================================
    // LOG-ABRUF UND FILTERUNG
    // ============================================

    /**
     * Gibt die letzten N Logs zurueck
     * @param {number} count - Anzahl (default: 50)
     * @returns {Array} Log-Eintraege
     */
    Logger.getRecentLogs = function(count) {
        count = count || 50;
        return eventLogs.slice(-count);
    };

    /**
     * Gibt alle Logs zurueck
     * @returns {Array} Alle Log-Eintraege
     */
    Logger.getAllLogs = function() {
        return [...eventLogs];
    };

    /**
     * Filtert Logs nach Kriterien
     * @param {object} criteria - Filter-Kriterien
     * @returns {Array} Gefilterte Logs
     */
    Logger.filterLogs = function(criteria) {
        criteria = criteria || {};
        return eventLogs.filter(function(log) {
            if (criteria.action && log.action !== criteria.action) return false;
            if (criteria.formular && log.formular !== criteria.formular) return false;
            if (criteria.control && log.control !== criteria.control) return false;
            if (criteria.sessionId && log.sessionId !== criteria.sessionId) return false;
            if (criteria.from) {
                const fromDate = new Date(criteria.from);
                if (new Date(log.timestamp) < fromDate) return false;
            }
            if (criteria.to) {
                const toDate = new Date(criteria.to);
                if (new Date(log.timestamp) > toDate) return false;
            }
            return true;
        });
    };

    /**
     * Zaehlt Logs nach Action-Typ
     * @returns {object} Zaehlung pro Action
     */
    Logger.countByAction = function() {
        const counts = {};
        eventLogs.forEach(function(log) {
            counts[log.action] = (counts[log.action] || 0) + 1;
        });
        return counts;
    };

    // ============================================
    // EXPORT-FUNKTIONEN
    // ============================================

    /**
     * Exportiert Logs als JSON-Datei
     * @param {string} filename - Dateiname (optional)
     */
    Logger.exportLogs = function(filename) {
        const data = {
            exportDate: new Date().toISOString(),
            sessionId: EVENT_CONFIG.SESSION_ID,
            totalLogs: eventLogs.length,
            logs: eventLogs
        };

        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename || ('consys_logs_' + new Date().toISOString().slice(0,10) + '.json');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);

        Logger.log('EXPORT_COMPLETE', null, null, { type: 'JSON', count: eventLogs.length });
    };

    /**
     * Exportiert Logs als CSV-Datei
     * @param {string} filename - Dateiname (optional)
     */
    Logger.exportLogsCSV = function(filename) {
        const headers = ['Timestamp', 'Action', 'Formular', 'Control', 'Details', 'SessionID'];
        const rows = [headers.join(';')];

        eventLogs.forEach(function(log) {
            const row = [
                formatTimestamp(log.timestamp),
                log.action,
                log.formular || '',
                log.control || '',
                JSON.stringify(log.details || {}).replace(/;/g, ','),
                log.sessionId
            ];
            rows.push(row.map(function(v) { return '"' + String(v).replace(/"/g, '""') + '"'; }).join(';'));
        });

        const csvContent = '\uFEFF' + rows.join('\n');
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename || ('consys_logs_' + new Date().toISOString().slice(0,10) + '.csv');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);

        Logger.log('EXPORT_COMPLETE', null, null, { type: 'CSV', count: eventLogs.length });
    };

    /**
     * Kopiert Logs in Zwischenablage
     */
    Logger.copyLogsToClipboard = function() {
        const text = eventLogs.map(function(log) {
            return `${formatTimestamp(log.timestamp)} | ${log.action} | ${log.formular} | ${log.control || '-'} | ${JSON.stringify(log.details)}`;
        }).join('\n');

        navigator.clipboard.writeText(text).then(function() {
            console.log('[Logger] Logs in Zwischenablage kopiert');
        }).catch(function(err) {
            console.error('[Logger] Clipboard-Fehler:', err);
        });
    };

    // ============================================
    // KONFIGURATION
    // ============================================

    /**
     * Setzt Konfigurationswert
     */
    Logger.setConfig = function(key, value) {
        if (EVENT_CONFIG.hasOwnProperty(key)) {
            EVENT_CONFIG[key] = value;
            console.log('[Logger] Config:', key, '=', value);
        }
    };

    /**
     * Gibt aktuelle Konfiguration zurueck
     */
    Logger.getConfig = function() {
        return { ...EVENT_CONFIG };
    };

    /**
     * Aktiviert Produktionsmodus (weniger Logging)
     */
    Logger.enableProductionMode = function() {
        EVENT_CONFIG.LOG_TO_CONSOLE = false;
        EVENT_CONFIG.INCLUDE_STACK = false;
        console.log('[Logger] Produktionsmodus aktiviert');
    };

    /**
     * Loescht alle Logs
     */
    Logger.clearLogs = function() {
        eventLogs = [];
        try {
            localStorage.removeItem('consys_event_logs');
        } catch (e) {}
        console.log('[Logger] Alle Logs geloescht');
    };

    // ============================================
    // INITIALISIERUNG
    // ============================================

    // Gespeicherte Logs laden
    loadStoredLogs();

    // Auto-Flush starten
    startAutoFlush();

    // Session-Start loggen
    Logger.log('SESSION_START', null, null, {
        userAgent: navigator.userAgent.substr(0, 100),
        url: window.location.href,
        referrer: document.referrer || 'direct'
    });

    // Bei Seiten-Unload speichern
    window.addEventListener('beforeunload', function() {
        Logger.log('SESSION_END');
        saveLogs();
    });

    // Bei Visibility-Change speichern (Tab-Wechsel)
    document.addEventListener('visibilitychange', function() {
        if (document.visibilityState === 'hidden') {
            saveLogs();
        }
    });

    // Global Error Handler
    window.addEventListener('error', function(event) {
        Logger.log('ERROR', null, null, {
            message: event.message,
            filename: event.filename,
            lineno: event.lineno,
            colno: event.colno
        });
    });

    // Unhandled Promise Rejection
    window.addEventListener('unhandledrejection', function(event) {
        Logger.log('ERROR', null, null, {
            type: 'unhandledrejection',
            reason: event.reason ? String(event.reason).substr(0, 200) : 'Unknown'
        });
    });

    console.log('[Logger] Event-Logging initialisiert - Session:', EVENT_CONFIG.SESSION_ID);

})(window.Logger);

// ============================================
// GLOBALE LOGGER-INSTANZ
// ============================================
// Logger ist jetzt unter window.Logger verfuegbar

/**
 * DOKUMENTATION - WO LOGS EINSEHEN:
 *
 * 1. BROWSER CONSOLE (F12):
 *    - Echtzeit-Ausgabe aller Events mit [CONSYS] Prefix
 *    - Logger.getRecentLogs() - letzte 50 Logs
 *    - Logger.getAllLogs() - alle Logs
 *    - Logger.filterLogs({ action: 'BUTTON_CLICK' }) - gefiltert
 *    - Logger.countByAction() - Statistik
 *
 * 2. LOCALSTORAGE:
 *    - Key: consys_event_logs
 *    - Max 500 Eintraege
 *    - Persistiert ueber Browser-Sessions
 *
 * 3. EXPORT:
 *    - Logger.exportLogs() - JSON-Download
 *    - Logger.exportLogsCSV() - CSV-Download (Excel-kompatibel)
 *    - Logger.copyLogsToClipboard() - In Zwischenablage
 *
 * 4. EVENT-TYPEN:
 *    FORM_OPEN, FORM_CLOSE, FORM_SAVE, FORM_LOAD, FORM_ERROR
 *    BUTTON_CLICK
 *    NAV_FIRST, NAV_PREV, NAV_NEXT, NAV_LAST, NAV_GOTO
 *    API_CALL, API_RESPONSE, API_ERROR, API_CACHE_HIT
 *    RECORD_NEW, RECORD_SAVE, RECORD_DELETE, RECORD_LOAD
 *    EXPORT_START, EXPORT_COMPLETE, EXPORT_ERROR
 *    EMAIL_SEND, EMAIL_ERROR
 *    SESSION_START, SESSION_END, ERROR, WARNING
 */
