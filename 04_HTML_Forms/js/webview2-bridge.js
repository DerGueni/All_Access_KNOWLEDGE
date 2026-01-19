/**
 * WebView2 Bridge - Kommunikation zwischen HTML und Access via C# COM
 * Version 3.0 für CONSEC Security
 *
 * Diese Datei stellt die Bridge-Funktionen bereit, die HTML-Formulare
 * mit dem Access-Backend kommunizieren lassen.
 *
 * WICHTIG: Verwendet die C# AccessDataBridge für direkte OleDb-Zugriffe.
 *          Kein Python-API-Server erforderlich!
 */

(function() {
    'use strict';

    // Bridge-Namespace erstellen
    window.Bridge = window.Bridge || {};

    // Interner State
    const _state = {
        initialized: false,
        isWebView2: false,
        formData: {},
        callbacks: {},
        eventHandlers: {},
        pendingRequests: {},
        requestCounter: 0
    };

    /**
     * Generiert eine eindeutige Request-ID
     */
    function generateRequestId() {
        return ++_state.requestCounter;
    }

    /**
     * Initialisiert die Bridge
     */
    Bridge.init = function(options) {
        options = options || {};

        // Prüfe ob WebView2 verfügbar ist
        _state.isWebView2 = !!(window.chrome && window.chrome.webview);

        if (_state.isWebView2) {
            console.log('[Bridge] WebView2 erkannt - nutze C# AccessDataBridge');

            // WebView2 Message-Handler
            window.chrome.webview.addEventListener('message', function(event) {
                Bridge._handleResponse(event.data);
            });
        } else {
            console.log('[Bridge] Browser-Modus - API-Server erforderlich');

            // Fallback: postMessage für Tests
            window.addEventListener('message', function(event) {
                if (event.data && typeof event.data === 'string') {
                    try {
                        Bridge._handleResponse(event.data);
                    } catch (e) {}
                }
            });
        }

        _state.initialized = true;
        console.log('[Bridge] Initialisiert (v3.0)');

        // Callback für Init
        if (options.onReady) {
            options.onReady();
        }

        // Deaktiviere API-Lifecycle wenn WebView2
        if (_state.isWebView2) {
            window._skipApiLifecycle = true;
        }
    };

    /**
     * Verarbeitet Responses von C# AccessDataBridge
     */
    Bridge._handleResponse = function(responseData) {
        try {
            let response;
            if (typeof responseData === 'string') {
                response = JSON.parse(responseData);
            } else {
                response = responseData;
            }

            console.log('[Bridge] Response empfangen:', response);

            // Prüfe auf requestId
            if (response.requestId && _state.pendingRequests[response.requestId]) {
                const pending = _state.pendingRequests[response.requestId];
                delete _state.pendingRequests[response.requestId];

                if (response.ok) {
                    if (pending.resolve) {
                        pending.resolve(response.data);
                    }
                    // Event-Handler aufrufen
                    if (pending.dataType && _state.eventHandlers['on' + pending.dataType]) {
                        _state.eventHandlers['on' + pending.dataType](response.data);
                    }
                } else {
                    console.error('[Bridge] Fehler:', response.error);
                    if (pending.reject) {
                        pending.reject(response.error);
                    }
                    if (_state.eventHandlers.onError) {
                        _state.eventHandlers.onError(response.error);
                    }
                }
            }

            // Legacy: onDataReceived Handler
            if (_state.eventHandlers.onDataReceived) {
                _state.eventHandlers.onDataReceived(response.data || response);
            }

        } catch (e) {
            console.error('[Bridge] Fehler beim Parsen der Response:', e, responseData);
        }
    };

    /**
     * Sendet einen Request an C# AccessDataBridge
     * @param {string} action - Aktion (z.B. "getAuftrag", "listMitarbeiter")
     * @param {object} params - Parameter
     * @returns {Promise} - Promise mit den Daten
     */
    Bridge.request = function(action, params) {
        return new Promise((resolve, reject) => {
            const requestId = generateRequestId();

            const message = {
                action: action,
                requestId: requestId,
                params: params || {}
            };

            // Speichere Pending-Request
            _state.pendingRequests[requestId] = {
                resolve: resolve,
                reject: reject,
                action: action,
                timestamp: Date.now()
            };

            console.log('[Bridge] Sende Request:', message);

            if (_state.isWebView2) {
                window.chrome.webview.postMessage(JSON.stringify(message));
            } else {
                // Fallback: Zeige Warnung
                console.warn('[Bridge] WebView2 nicht verfügbar - Request kann nicht gesendet werden');
                setTimeout(() => {
                    reject({ code: 'NO_WEBVIEW2', message: 'WebView2 nicht verfügbar' });
                }, 100);
            }

            // Timeout nach 30 Sekunden
            setTimeout(() => {
                if (_state.pendingRequests[requestId]) {
                    delete _state.pendingRequests[requestId];
                    reject({ code: 'TIMEOUT', message: 'Request Timeout' });
                }
            }, 30000);
        });
    };

    /**
     * Lädt Daten vom Backend (für Kompatibilität mit bestehendem Code)
     * @param {string} dataType - Typ der Daten
     * @param {number} id - Optional: ID des Datensatzes
     * @param {object} params - Zusätzliche Parameter
     */
    Bridge.loadData = function(dataType, id, params) {
        params = params || {};

        // Mapping von dataType zu action
        const actionMap = {
            'auftraege_liste': 'listAuftraege',
            'auftrag_detail': 'getAuftrag',
            'auftrag_tage': 'getEinsatztage',
            'mitarbeiter_liste': 'listMitarbeiter',
            'mitarbeiter': 'getMitarbeiter',
            'kunden': 'listKunden',
            'kunde': 'getKunde',
            'objekte': 'listObjekte',
            'objekt': 'getObjekt',
            'zuordnungen': 'getZuordnungen',
            'schichten': 'getSchichten',
            'status': 'getStatusListe',
            'absagen': 'getAbsagen',
            'anfragen': 'getAnfragen',
            'vorschlaege': 'getVorschlaege',
            'rechnungspositionen': 'getRechnungspositionen',
            'berechnungsliste': 'getBerechnungsliste',
            'attachments': 'getAttachments'
        };

        const action = actionMap[dataType] || dataType;

        if (id) {
            params.id = id;
            params.va_id = id;
            params.VA_ID = id;
        }

        const requestId = generateRequestId();

        // Speichere für Event-Handler
        _state.pendingRequests[requestId] = {
            dataType: dataType,
            timestamp: Date.now()
        };

        const message = {
            action: action,
            requestId: requestId,
            params: params
        };

        console.log('[Bridge] loadData:', message);

        if (_state.isWebView2) {
            window.chrome.webview.postMessage(JSON.stringify(message));
        } else {
            console.warn('[Bridge] WebView2 nicht verfügbar');
            // Fallback: Versuche API-Server
            Bridge._fetchFromApi(dataType, id, params);
        }
    };

    /**
     * Fallback: Lädt Daten vom API-Server (wenn nicht in WebView2)
     */
    Bridge._fetchFromApi = async function(dataType, id, params) {
        try {
            let url = 'http://localhost:5000/api/';

            switch (dataType) {
                case 'auftraege_liste':
                    url += 'auftraege';
                    break;
                case 'auftrag_detail':
                    url += 'auftraege/' + id;
                    break;
                case 'mitarbeiter_liste':
                    url += 'mitarbeiter';
                    break;
                case 'kunden':
                    url += 'kunden';
                    break;
                case 'status':
                    url += 'status';
                    break;
                default:
                    url += dataType;
            }

            const response = await fetch(url);
            if (!response.ok) throw new Error('API-Fehler: ' + response.status);

            const responseData = await response.json();

            // Extrahiere data-Feld wenn vorhanden (API gibt {data: [...], success: true})
            const records = responseData.data !== undefined ? responseData.data : responseData;

            console.log('[Bridge] API-Daten geladen:', Array.isArray(records) ? records.length + ' Datensätze' : records);

            // Mapping von dataType zu type für Formular-Kompatibilität
            const typeMap = {
                'mitarbeiter': 'mitarbeiter_list',
                'mitarbeiter_liste': 'mitarbeiter_list',
                'auftraege': 'auftraege_list',
                'auftraege_liste': 'auftraege_list',
                'kunden': 'kunden_list',
                'objekte': 'objekte_list'
            };

            // Formular erwartet {type: '...', records: [...]}
            const formattedData = {
                type: typeMap[dataType] || dataType + '_list',
                records: Array.isArray(records) ? records : [records]
            };

            // Falls einzelner Datensatz (mit ID), verwende _detail
            if (id && !Array.isArray(records)) {
                formattedData.type = dataType.replace('_liste', '') + '_detail';
                formattedData.record = records;
            }

            console.log('[Bridge] Sende an Formular:', formattedData.type, formattedData.records ? formattedData.records.length + ' records' : '1 record');

            // Trigger Event-Handler
            if (_state.eventHandlers.onDataReceived) {
                _state.eventHandlers.onDataReceived(formattedData);
            }
        } catch (e) {
            console.error('[Bridge] API-Fehler:', e);
            if (_state.eventHandlers.onError) {
                _state.eventHandlers.onError({ code: 'API_ERROR', message: e.message });
            }
        }
    };

    /**
     * Sendet ein Event an Access (für Navigation, Close, etc.)
     * @param {string} eventType - Typ des Events
     * @param {object} data - Zusätzliche Daten
     */
    Bridge.sendEvent = function(eventType, data) {
        data = data || {};

        const message = {
            action: eventType,
            requestId: generateRequestId(),
            params: data
        };

        console.log('[Bridge] Sende Event:', message);

        if (_state.isWebView2) {
            window.chrome.webview.postMessage(JSON.stringify(message));
        } else {
            console.log('[Bridge] Event (Browser-Modus):', eventType, data);
        }
    };

    /**
     * Empfängt Daten von Access (wird von C# aufgerufen)
     * Für Kompatibilität mit bestehendem VBA-Code
     * @param {string} jsonData - JSON-String mit den Daten
     */
    Bridge.onDataReceived = function(jsonData) {
        console.log('[Bridge] onDataReceived:', jsonData);

        try {
            let data;
            if (typeof jsonData === 'string') {
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

            // Formular befüllen wenn Hauptdaten vorhanden
            if (data.auftrag) Bridge.fillForm(data.auftrag);
            if (data.mitarbeiter) Bridge.fillForm(data.mitarbeiter);
            if (data.kunde) Bridge.fillForm(data.kunde);
            if (data.objekt) Bridge.fillForm(data.objekt);

        } catch (e) {
            console.error('[Bridge] Fehler beim Parsen:', e, jsonData);
        }
    };

    /**
     * Speichert Daten
     * @param {string} type - Datentyp (auftrag, mitarbeiter, etc.)
     * @param {object} data - Die zu speichernden Daten
     */
    Bridge.save = function(type, data) {
        return Bridge.request('save', { type: type, data: data || _state.formData });
    };

    /**
     * Löscht einen Datensatz
     * @param {string} type - Datentyp
     * @param {number} id - ID des Datensatzes
     */
    Bridge.delete = function(type, id) {
        return Bridge.request('delete', { type: type, id: id });
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
     * Führt eine Suche aus
     * @param {string} searchType - Typ der Suche
     * @param {string} term - Suchbegriff
     */
    Bridge.search = function(searchType, term) {
        return Bridge.request('search', { type: searchType, term: term });
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
     */
    Bridge.setFormValue = function(key, value) {
        _state.formData[key] = value;
    };

    /**
     * Holt einen Wert aus den Formulardaten
     */
    Bridge.getFormValue = function(key) {
        return _state.formData[key];
    };

    /**
     * Registriert einen Event-Handler
     */
    Bridge.on = function(eventName, handler) {
        _state.eventHandlers[eventName] = handler;
    };

    /**
     * Befüllt Formularfelder mit Daten
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

    /**
     * Prüft ob WebView2 aktiv ist
     */
    Bridge.isWebView2 = function() {
        return _state.isWebView2;
    };

    /**
     * Ping-Test zur C# Bridge
     */
    Bridge.ping = function() {
        return Bridge.request('ping', {});
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

    console.log('[Bridge] webview2-bridge.js geladen (v3.0)');

})();
