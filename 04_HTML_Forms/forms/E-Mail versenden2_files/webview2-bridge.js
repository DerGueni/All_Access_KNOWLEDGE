/**
 * WebView2 Bridge - Kommunikation zwischen HTML und Access VBA
 * Version 2.0 für CONSEC Security
 * 
 * Diese Datei stellt die Bridge-Funktionen bereit, die HTML-Formulare
 * mit dem Access-Backend kommunizieren lassen.
 */

(function() {
    'use strict';

    // Bridge-Namespace erstellen
    window.Bridge = window.Bridge || {};
    
    // Interner State
    const _state = {
        initialized: false,
        formData: {},
        callbacks: {},
        eventHandlers: {}
    };

    /**
     * Initialisiert die Bridge
     */
    Bridge.init = function(options) {
        options = options || {};
        
        // Event-Handler für Chrome-PostMessage
        window.addEventListener('message', function(event) {
            if (event.data && typeof event.data === 'string') {
                try {
                    const data = JSON.parse(event.data);
                    Bridge.onDataReceived(JSON.stringify(data));
                } catch (e) {
                    Bridge.onDataReceived(event.data);
                }
            }
        });

        // WebView2-spezifische Initialisierung
        if (window.chrome && window.chrome.webview) {
            window.chrome.webview.addEventListener('message', function(event) {
                Bridge.onDataReceived(event.data);
            });
        }

        _state.initialized = true;
        console.log('[Bridge] Initialisiert');
        
        // Callback für Init
        if (options.onReady) {
            options.onReady();
        }
    };

    /**
     * Empfängt Daten von Access (wird von C# aufgerufen)
     * @param {string} jsonData - JSON-String mit den Daten
     */
    Bridge.onDataReceived = function(jsonData) {
        console.log('[Bridge] Daten empfangen:', jsonData);
        
        try {
            let data;
            if (typeof jsonData === 'string') {
                // Doppelte Escapes bereinigen
                jsonData = jsonData.replace(/\\'/g, "'");
                data = JSON.parse(jsonData);
            } else {
                data = jsonData;
            }
            
            // In formData speichern
            if (data) {
                Object.assign(_state.formData, data);
            }
            
            // Event-Handler aufrufen
            if (_state.eventHandlers.onDataReceived) {
                _state.eventHandlers.onDataReceived(data);
            }
            
            // Spezielle Action-Handler
            if (data.action) {
                switch (data.action) {
                    case 'load':
                        Bridge._handleLoadAction(data);
                        break;
                    case 'refresh':
                        Bridge._handleRefreshAction(data);
                        break;
                    case 'searchResults':
                        Bridge._handleSearchResults(data);
                        break;
                }
            }
            
            // Typ-basierte Handler (für Suchergebnisse etc.)
            if (data.type === 'searchResults' && _state.eventHandlers.onSearchResults) {
                _state.eventHandlers.onSearchResults(data.data);
            }
            
        } catch (e) {
            console.error('[Bridge] Fehler beim Parsen der Daten:', e, jsonData);
        }
    };

    /**
     * Sendet ein Event an Access
     * @param {string} eventType - Typ des Events (save, delete, navigate, etc.)
     * @param {object} data - Zusätzliche Daten
     */
    Bridge.sendEvent = function(eventType, data) {
        const message = JSON.stringify({
            type: eventType,
            timestamp: new Date().toISOString(),
            ...data
        });
        
        console.log('[Bridge] Sende Event:', message);
        
        // WebView2 PostMessage
        if (window.chrome && window.chrome.webview) {
            window.chrome.webview.postMessage(message);
        } else {
            // Fallback für Tests
            console.log('[Bridge] WebView2 nicht verfügbar - Event:', message);
        }
    };

    /**
     * Speichert die aktuellen Formulardaten
     */
    Bridge.save = function() {
        Bridge.sendEvent('save', { formData: _state.formData });
    };

    /**
     * Löscht den aktuellen Datensatz
     */
    Bridge.delete = function() {
        Bridge.sendEvent('delete', { id: _state.formData.id });
    };

    /**
     * Navigiert zu einem anderen Formular
     * @param {string} formName - Name des Zielformulars
     * @param {number} id - ID des zu ladenden Datensatzes
     */
    Bridge.navigate = function(formName, id) {
        Bridge.sendEvent('navigate', { form: formName, id: id });
    };

    /**
     * Fordert Daten vom Access-Backend an
     * @param {string} dataType - Typ der Daten (auftrag, mitarbeiter, kunde, etc.)
     * @param {number} id - ID des Datensatzes
     */
    Bridge.loadData = function(dataType, id) {
        Bridge.sendEvent('loadData', { dataType: dataType, id: id });
    };

    /**
     * Führt eine Suche aus
     * @param {string} searchType - Typ der Suche (mitarbeiter, kunde, auftrag)
     * @param {string} term - Suchbegriff
     */
    Bridge.search = function(searchType, term) {
        Bridge.sendEvent('search', { searchType: searchType, term: term });
    };

    /**
     * Aktualisiert die Anzeige
     */
    Bridge.refresh = function() {
        Bridge.sendEvent('refresh', {});
    };

    /**
     * Schließt das Formular
     */
    Bridge.close = function() {
        Bridge.sendEvent('close', {});
    };

    /**
     * Gibt die aktuellen Formulardaten zurück
     * @returns {object} Die Formulardaten
     */
    Bridge.getFormData = function() {
        // Aktuelle Werte aus Eingabefeldern sammeln
        const inputs = document.querySelectorAll('input, select, textarea');
        inputs.forEach(function(input) {
            const name = input.name || input.id;
            if (name) {
                if (input.type === 'checkbox') {
                    _state.formData[name] = input.checked;
                } else if (input.type === 'radio') {
                    if (input.checked) {
                        _state.formData[name] = input.value;
                    }
                } else {
                    _state.formData[name] = input.value;
                }
            }
        });
        
        return _state.formData;
    };

    /**
     * Setzt einen Wert in den Formulardaten
     * @param {string} key - Schlüssel
     * @param {*} value - Wert
     */
    Bridge.setFormValue = function(key, value) {
        _state.formData[key] = value;
    };

    /**
     * Holt einen Wert aus den Formulardaten
     * @param {string} key - Schlüssel
     * @returns {*} Der Wert
     */
    Bridge.getFormValue = function(key) {
        return _state.formData[key];
    };

    /**
     * Registriert einen Event-Handler
     * @param {string} eventName - Name des Events
     * @param {function} handler - Handler-Funktion
     */
    Bridge.on = function(eventName, handler) {
        _state.eventHandlers[eventName] = handler;
    };

    /**
     * Befüllt Formularfelder mit Daten
     * @param {object} data - Objekt mit Feldnamen und Werten
     */
    Bridge.fillForm = function(data) {
        if (!data) return;
        
        Object.keys(data).forEach(function(key) {
            const value = data[key];
            const elements = document.querySelectorAll('[name="' + key + '"], #' + key);
            
            elements.forEach(function(el) {
                if (el.tagName === 'INPUT') {
                    if (el.type === 'checkbox') {
                        el.checked = !!value;
                    } else if (el.type === 'radio') {
                        el.checked = (el.value === String(value));
                    } else {
                        el.value = value || '';
                    }
                } else if (el.tagName === 'SELECT' || el.tagName === 'TEXTAREA') {
                    el.value = value || '';
                } else if (el.classList.contains('display-field')) {
                    el.textContent = value || '';
                }
            });
        });
        
        Object.assign(_state.formData, data);
    };

    // Interne Handler
    Bridge._handleLoadAction = function(data) {
        console.log('[Bridge] Load-Action:', data);
        
        // Hauptdaten befüllen (je nach Formular-Typ)
        if (data.auftrag) {
            Bridge.fillForm(data.auftrag);
        }
        if (data.mitarbeiter) {
            Bridge.fillForm(data.mitarbeiter);
        }
        if (data.kunde) {
            Bridge.fillForm(data.kunde);
        }
        
        // Custom Handler aufrufen
        if (_state.eventHandlers.onLoad) {
            _state.eventHandlers.onLoad(data);
        }
    };

    Bridge._handleRefreshAction = function(data) {
        console.log('[Bridge] Refresh-Action:', data);
        if (_state.eventHandlers.onRefresh) {
            _state.eventHandlers.onRefresh(data);
        }
    };

    Bridge._handleSearchResults = function(data) {
        console.log('[Bridge] Search-Results:', data);
        if (_state.eventHandlers.onSearchResults) {
            _state.eventHandlers.onSearchResults(data.data);
        }
    };

    // Auto-Init wenn DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            Bridge.init();
        });
    } else {
        Bridge.init();
    }

    // Globale Fehlerbehandlung
    window.onerror = function(msg, url, line, col, error) {
        console.error('[Bridge] Globaler Fehler:', msg, 'at', url + ':' + line);
        return false;
    };

    console.log('[Bridge] webview2-bridge.js geladen (v2.0)');

})();
