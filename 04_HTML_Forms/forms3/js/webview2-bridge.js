/**
 * webview2-bridge.js
 * WebView2 Bridge für direkte Kommunikation mit Access-Backend (Desktop Host)
 *
 * NEU: WebView2 kommuniziert jetzt DIREKT mit Access Backend via OleDb!
 *      Kein Python-Server mehr nötig!
 *
 * Fallback: REST-API (localhost:5000) für Browser-Entwicklung/Test
 *
 * VERWENDUNG:
 * import { Bridge } from '../js/webview2-bridge.js';
 * const data = await Bridge.loadData('auftrag', 123);
 */

// ============================================
// DETECTION & CONFIGURATION
// ============================================
const USE_WEBVIEW2 = !!(window.chrome && window.chrome.webview);
const API_BASE = 'http://localhost:5000/api';

console.log(`[Bridge] Modus: ${USE_WEBVIEW2 ? 'WebView2 (Direkt-DB, kein Server!)' : 'REST-API Fallback (localhost:5000)'}`);

// Event-Handler für empfangene Daten
const eventHandlers = {};
const pendingRequests = new Map();
let requestId = 0;

// ============================================
// WEBVIEW2 MESSAGE HANDLER
// ============================================
if (USE_WEBVIEW2) {
    window.chrome.webview.addEventListener('message', (event) => {
        let data = event.data;

        // Falls String, parsen
        if (typeof data === 'string') {
            try {
                data = JSON.parse(data);
            } catch (e) {
                console.error('[Bridge] JSON Parse Error:', e);
                return;
            }
        }

        if (data.requestId && pendingRequests.has(data.requestId)) {
            const { resolve, reject } = pendingRequests.get(data.requestId);
            pendingRequests.delete(data.requestId);

            // NEU: Response-Format von AccessDataBridge: { ok, data, error }
            if (data.ok === false || data.error) {
                const errMsg = data.error?.message || data.error || 'Unbekannter Fehler';
                reject(new Error(errMsg));
            } else {
                // Erfolg - data.data enthält die eigentlichen Daten
                resolve(data.data || data);
            }
        } else if (data.event) {
            const handlers = eventHandlers[data.event] || [];
            handlers.forEach(handler => handler(data.data));
        }
    });
}

// ============================================
// REQUEST CACHE (Performance-Optimierung)
// ============================================
const _cache = new Map();
const _pending = new Map();

// ============================================
// REQUEST SERIALISIERUNG (Access ODBC ist NICHT thread-safe!)
// ============================================
let _requestQueue = Promise.resolve();
let _queueLength = 0;

/**
 * Serialisiert alle API-Requests
 * Access ODBC-Treiber crasht bei parallelen Zugriffen!
 */
function queueRequest(fn) {
    _queueLength++;
    console.debug(`[Bridge Queue] +1 Request (Queue: ${_queueLength})`);

    _requestQueue = _requestQueue
        .then(() => fn())
        .catch(err => {
            console.error('[Bridge Queue] Request failed:', err);
            throw err;
        })
        .finally(() => {
            _queueLength--;
            console.debug(`[Bridge Queue] -1 Request (Queue: ${_queueLength})`);
        });

    return _requestQueue;
}

// ============================================
// CONNECTION HEALTH & RETRY CONFIG
// ============================================
const CONNECTION_CONFIG = {
    maxRetries: 3,
    initialDelay: 500,       // 500ms initial retry delay
    maxDelay: 5000,          // max 5s between retries
    backoffMultiplier: 2,
    healthCheckInterval: 30000,  // 30s health check
    timeoutMs: 30000         // 30s request timeout
};

let connectionHealthy = true;
let healthCheckTimer = null;

// Connection-Health-Monitoring
function updateConnectionStatus(isHealthy) {
    connectionHealthy = isHealthy;
    // Dispatch custom event for UI updates
    window.dispatchEvent(new CustomEvent('bridge:connectionStatus', {
        detail: { healthy: isHealthy, mode: USE_WEBVIEW2 ? 'WebView2' : 'REST' }
    }));

    // Update status indicator if exists
    const statusEl = document.getElementById('modeIndicator') || document.getElementById('connectionStatus');
    if (statusEl) {
        statusEl.style.color = isHealthy ? '#008000' : '#c00000';
        statusEl.title = isHealthy ? 'Verbunden' : 'Keine Verbindung';
    }
}

// Start health monitoring
function startHealthMonitoring() {
    if (healthCheckTimer) return;

    healthCheckTimer = setInterval(async () => {
        try {
            if (USE_WEBVIEW2) {
                // WebView2: Simple ping
                const result = await Bridge.sendRequest('ping', {});
                updateConnectionStatus(true);
            } else {
                // REST: Health endpoint
                const response = await fetch(API_BASE + '/health', {
                    method: 'GET',
                    signal: AbortSignal.timeout(5000)
                });
                updateConnectionStatus(response.ok);
            }
        } catch (e) {
            updateConnectionStatus(false);
            console.warn('[Bridge] Health check failed:', e.message);
        }
    }, CONNECTION_CONFIG.healthCheckInterval);
}

// Retry with exponential backoff
async function withRetry(fn, retries = CONNECTION_CONFIG.maxRetries) {
    let lastError;
    let delay = CONNECTION_CONFIG.initialDelay;

    for (let i = 0; i <= retries; i++) {
        try {
            return await fn();
        } catch (error) {
            lastError = error;

            // Don't retry on certain errors
            if (error.message?.includes('Invalid action') ||
                error.message?.includes('Ungültige Aktion')) {
                throw error;
            }

            if (i < retries) {
                console.warn(`[Bridge] Retry ${i + 1}/${retries} after ${delay}ms:`, error.message);
                await new Promise(r => setTimeout(r, delay));
                delay = Math.min(delay * CONNECTION_CONFIG.backoffMultiplier, CONNECTION_CONFIG.maxDelay);
            }
        }
    }

    updateConnectionStatus(false);
    throw lastError;
}

const CACHE_TTL = {
    '/mitarbeiter': 60000,        // 1 Minute
    '/kunden': 60000,             // 1 Minute
    '/objekte': 60000,            // 1 Minute
    '/status': 300000,            // 5 Minuten
    '/dienstkleidung': 300000,    // 5 Minuten
    '/orte': 300000,              // 5 Minuten
    '/auftraege': 15000,          // 15 Sekunden
    '/einsatztage': 10000,        // 10 Sekunden
    '/schichten': 10000,          // 10 Sekunden
    '/zuordnungen': 5000,         // 5 Sekunden (live)
    '/anfragen': 5000,            // 5 Sekunden (live)
    'default': 30000              // 30 Sekunden Standard
};

function getCacheTTL(endpoint) {
    for (const [pattern, ttl] of Object.entries(CACHE_TTL)) {
        if (pattern !== 'default' && endpoint.includes(pattern)) {
            return ttl;
        }
    }
    return CACHE_TTL.default;
}

function getCacheKey(endpoint, body = null) {
    return body ? `${endpoint}:${JSON.stringify(body)}` : endpoint;
}

// ============================================
// REST API FALLBACK FUNCTIONS (mit Cache + Serialisierung)
// ============================================
async function apiFetch(endpoint, options = {}) {
    const useCache = !options.method || options.method === 'GET';
    const cacheKey = getCacheKey(endpoint, options.body);
    const method = options.method || 'GET';
    const startTime = Date.now();

    // Logger-Integration
    if (typeof Logger !== 'undefined' && Logger.apiCall) {
        Logger.apiCall(endpoint, method);
    }

    // 1. Cache pruefen (nur fuer GET)
    if (useCache) {
        const cached = _cache.get(cacheKey);
        if (cached && (Date.now() - cached.timestamp) < getCacheTTL(endpoint)) {
            console.debug('[Bridge Cache] HIT:', endpoint);
            // Cache-Hit loggen
            if (typeof Logger !== 'undefined' && Logger.log) {
                Logger.log('API_CACHE_HIT', null, null, { endpoint: endpoint });
            }
            return cached.data;
        }

        // 2. Deduplication: Falls Request bereits laeuft
        if (_pending.has(cacheKey)) {
            console.debug('[Bridge Cache] PENDING:', endpoint);
            return _pending.get(cacheKey);
        }
    }

    // 3. Request serialisieren (Access ODBC ist NICHT thread-safe!)
    const fetchPromise = queueRequest(async () => {
        try {
            console.debug('[Bridge] Fetching:', endpoint);
            const response = await fetch(`${API_BASE}${endpoint}`, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            if (!response.ok) {
                const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
                // API-Error loggen
                if (typeof Logger !== 'undefined' && Logger.apiError) {
                    Logger.apiError(endpoint, error);
                }
                throw error;
            }

            const data = await response.json();
            const duration = Date.now() - startTime;

            // API-Response loggen
            if (typeof Logger !== 'undefined' && Logger.apiResponse) {
                Logger.apiResponse(endpoint, response.status, duration);
            }

            // In Cache speichern (nur GET)
            if (useCache) {
                _cache.set(cacheKey, { data, timestamp: Date.now() });
            } else {
                // Bei POST/PUT/DELETE: Relevanten Cache invalidieren
                invalidateCache(endpoint.split('/')[1]);
            }

            return data;
        } finally {
            _pending.delete(cacheKey);
        }
    });

    if (useCache) {
        _pending.set(cacheKey, fetchPromise);
    }

    return fetchPromise;
}

// Cache invalidieren bei Aenderungen
function invalidateCache(pattern = null) {
    if (pattern) {
        for (const key of _cache.keys()) {
            if (key.includes(pattern)) {
                _cache.delete(key);
            }
        }
        console.debug('[Bridge Cache] Invalidated:', pattern);
    } else {
        _cache.clear();
        console.debug('[Bridge Cache] Cleared all');
    }
}

// Automatischer Cache-Cleanup alle 2 Minuten
setInterval(() => {
    const now = Date.now();
    for (const [key, entry] of _cache.entries()) {
        const ttl = getCacheTTL(key.split(':')[0]);
        if ((now - entry.timestamp) > ttl) {
            _cache.delete(key);
        }
    }
}, 120000);


// Type-to-Endpoint Mapping
const TYPE_ENDPOINTS = {
    'auftraege': '/auftraege',
    'auftrag': '/auftraege',
    'mitarbeiter': '/mitarbeiter',
    'kunden': '/kunden',
    'kunde': '/kunden',
    'objekte': '/objekte',
    'objekt': '/objekte',
    'orte': '/orte',
    'status': '/status',
    'dienstkleidung': '/dienstkleidung',
    'einsatztage': '/einsatztage',
    'zuordnungen': '/zuordnungen',
    'zuordnung': '/zuordnungen',
    'schichten': '/schichten',
    'abwesenheiten': '/abwesenheiten',
    'rechnung': '/rechnungen',
    'rechnungen': '/rechnungen'
};

// ============================================
// BRIDGE API
// ============================================
const Bridge = {
    /**
     * Daten vom Host laden
     * Unterstützt sowohl Promise-basiert als auch Event-basiert (für WebView2-Kompatibilität)
     */
    async loadData(type, id, params = {}) {
        if (USE_WEBVIEW2) {
            // Mit Retry-Logic für stabile Verbindung
            return withRetry(() => this.sendRequest('loadData', { type, id, ...params }));
        }

        // API Fallback mit Event-Simulation für Browser-Modus
        try {
            let result;

            // Spezielle Type-Mappings für forms3 HTML
            switch(type) {
                case 'auftraege_liste':
                    const queryParams = new URLSearchParams();
                    if (params.ab) queryParams.append('ab', params.ab);
                    if (params.status) queryParams.append('status', params.status);
                    if (params.limit) queryParams.append('limit', params.limit);
                    const auftraegeUrl = `/auftraege${queryParams.toString() ? '?' + queryParams.toString() : ''}`;
                    result = await apiFetch(auftraegeUrl);
                    // Event simulieren für Kompatibilität
                    this._fireEvent('onDataReceived', { type: 'auftraege_liste', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'auftrag_detail':
                    // Der Endpoint /auftraege/<id> liefert ALLE Daten in einem Request!
                    // Dies vermeidet parallele Requests die den Access ODBC-Treiber crashen
                    result = await apiFetch(`/auftraege/${id}`);
                    const data = result.data || result;

                    // Auftragsdaten
                    this._fireEvent('onDataReceived', {
                        type: 'auftrag_detail',
                        record: data.auftrag || result
                    });

                    // Wenn kombinierter Response: Auch die anderen Daten feuern
                    if (data.einsatztage) {
                        this._fireEvent('onDataReceived', {
                            type: 'auftrag_tage',
                            records: data.einsatztage
                        });
                    }
                    if (data.startzeiten) {
                        this._fireEvent('onDataReceived', {
                            type: 'schichten',
                            records: data.startzeiten
                        });
                    }
                    if (data.zuordnungen) {
                        this._fireEvent('onDataReceived', {
                            type: 'zuordnungen',
                            records: data.zuordnungen
                        });
                    }
                    if (data.anfragen) {
                        this._fireEvent('onDataReceived', {
                            type: 'absagen',
                            records: data.anfragen
                        });
                    }

                    return result;

                case 'auftrag_tage':
                    // Einzelanfrage nur wenn nötig (wird vom kombinierten auftrag_detail mitgeliefert)
                    result = await apiFetch(`/einsatztage?va_id=${id}`);
                    this._fireEvent('onDataReceived', { type: 'auftrag_tage', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'status':
                    result = await apiFetch('/status');
                    this._fireEvent('onDataReceived', { type: 'status', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'kunden':
                    const kundenParams = params.aktiv ? '?aktiv=true' : '';
                    result = await apiFetch(`/kunden${kundenParams}`);
                    this._fireEvent('onDataReceived', { type: 'kunden', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'schichten':
                    // WICHTIG: vadatum_id Parameter beruecksichtigen - nur Schichten des ausgewaehlten Tages laden
                    let schichtenUrl = `/schichten?va_id=${id}`;
                    if (params && params.vadatum_id) {
                        schichtenUrl += `&vadatum_id=${params.vadatum_id}`;
                    }
                    result = await apiFetch(schichtenUrl);
                    this._fireEvent('onDataReceived', { type: 'schichten', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'zuordnungen':
                    // WICHTIG: vadatum_id Parameter beruecksichtigen - nur Zuordnungen des ausgewaehlten Tages laden
                    let zuordUrl = `/zuordnungen?va_id=${id}`;
                    if (params && params.vadatum_id) {
                        zuordUrl += `&vadatum_id=${params.vadatum_id}`;
                    }
                    result = await apiFetch(zuordUrl);
                    this._fireEvent('onDataReceived', { type: 'zuordnungen', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'absagen':
                    // WICHTIG: vadatum_id Parameter beruecksichtigen - nur Absagen des ausgewaehlten Tages laden
                    let absagenUrl = `/absagen?va_id=${id}`;
                    if (params && params.vadatum_id) {
                        absagenUrl += `&vadatum_id=${params.vadatum_id}`;
                    }
                    result = await apiFetch(absagenUrl);
                    this._fireEvent('onDataReceived', { type: 'absagen', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'vorschlaege':
                    // Vorschläge/Autocomplete - geben leere Liste zurück
                    this._fireEvent('onDataReceived', { type: 'vorschlaege', field: params.field, records: [] });
                    return { records: [] };

                case 'attachments':
                    result = await apiFetch(`/attachments?va_id=${id}`);
                    this._fireEvent('onDataReceived', { type: 'attachments', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'anfragen':
                    result = await apiFetch(`/anfragen?va_id=${id}`);
                    this._fireEvent('onDataReceived', { type: 'anfragen', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'rechnungspositionen':
                    result = await apiFetch(`/rechnungen/positionen?va_id=${id}`);
                    this._fireEvent('onDataReceived', { type: 'rechnungspositionen', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                case 'berechnungsliste':
                    result = await apiFetch(`/berechnungsliste?va_id=${id}`);
                    this._fireEvent('onDataReceived', { type: 'berechnungsliste', records: Array.isArray(result) ? result : (result.data || []) });
                    return result;

                default:
                    // Standard-Fallback
                    const endpoint = TYPE_ENDPOINTS[type] || `/${type}`;
                    if (id) {
                        result = await apiFetch(`${endpoint}/${id}`);
                    } else {
                        result = await apiFetch(endpoint);
                    }
                    return result;
            }
        } catch (error) {
            console.error(`[Bridge] loadData Fehler für ${type}:`, error);
            this._fireEvent('onError', { type, error: error.message });
            throw error;
        }
    },

    /**
     * Interner Event-Feuerer für Browser-Modus
     */
    _fireEvent(eventName, data) {
        const handlers = eventHandlers[eventName] || [];
        handlers.forEach(handler => {
            try {
                handler(data);
            } catch (e) {
                console.error(`[Bridge] Event-Handler Fehler:`, e);
            }
        });
    },

    /**
     * Suche durchführen
     */
    async search(type, term) {
        if (USE_WEBVIEW2) {
            return this.sendRequest('search', { type, term });
        }
        const endpoint = TYPE_ENDPOINTS[type] || `/${type}`;
        return await apiFetch(`${endpoint}?search=${encodeURIComponent(term)}`);
    },

    /**
     * Liste laden
     */
    async list(type, params = {}) {
        if (USE_WEBVIEW2) {
            return this.sendRequest('list', { type, ...params });
        }
        // API Fallback
        const endpoint = TYPE_ENDPOINTS[type] || `/${type}`;
        const queryParams = new URLSearchParams();
        Object.entries(params).forEach(([key, value]) => {
            if (value !== undefined && value !== null) {
                queryParams.append(key, value);
            }
        });
        const queryString = queryParams.toString();
        const url = queryString ? `${endpoint}?${queryString}` : endpoint;
        const result = await apiFetch(url);
        // Normalize response format
        return { data: Array.isArray(result) ? result : (result.data || result.rows || []) };
    },

    /**
     * Daten speichern
     */
    async save(type, data) {
        if (USE_WEBVIEW2) {
            // Mit Retry für Speicheroperationen (weniger Retries bei Schreibvorgängen)
            return withRetry(() => this.sendRequest('save', { type, data }), 2);
        }
        const endpoint = TYPE_ENDPOINTS[type] || `/${type}`;
        const method = data.id || data.ID ? 'PUT' : 'POST';
        const url = data.id || data.ID ? `${endpoint}/${data.id || data.ID}` : endpoint;
        return await apiFetch(url, { method, body: JSON.stringify(data) });
    },

    /**
     * Datensatz löschen
     */
    async delete(type, id) {
        if (USE_WEBVIEW2) {
            return this.sendRequest('delete', { type, id });
        }
        const endpoint = TYPE_ENDPOINTS[type] || `/${type}`;
        return await apiFetch(`${endpoint}/${id}`, { method: 'DELETE' });
    },

    /**
     * Zu einem Formular navigieren
     */
    navigate(formName, id = null) {
        if (USE_WEBVIEW2) {
            this.sendEvent('navigate', { formName, id });
        } else {
            // Browser Fallback: iframe oder neues Fenster
            const url = `${formName}.html${id ? `?id=${id}` : ''}`;
            if (window.parent !== window) {
                // Shell erwartet 'NAVIGATE' (Grossbuchstaben)
                window.parent.postMessage({ type: 'NAVIGATE', formName, id }, '*');
            } else {
                window.location.href = url;
            }
        }
    },

    /**
     * Formular aktualisieren
     */
    refresh() {
        if (USE_WEBVIEW2) {
            this.sendEvent('refresh', {});
        } else {
            window.location.reload();
        }
    },

    /**
     * Formular schließen
     */
    close() {
        if (USE_WEBVIEW2) {
            this.sendEvent('close', {});
        } else {
            window.close();
        }
    },

    /**
     * Custom Event senden
     * Im Browser-Modus werden bestimmte Events automatisch ueber REST-API behandelt
     */
    async sendEvent(type, data) {
        if (USE_WEBVIEW2) {
            window.chrome.webview.postMessage({ event: type, data: data });
            return;
        }

        // Browser-Modus: REST-API Fallback fuer bekannte Events
        console.log('[Bridge] Event (Browser-Modus):', type, data);

        try {
            switch (type) {
                case 'loadSubformData':
                    await this._handleLoadSubformData(data);
                    break;

                case 'updateRecord':
                    await this._handleUpdateRecord(data);
                    break;

                default:
                    // Unbekanntes Event - nur loggen
                    break;
            }
        } catch (error) {
            console.error('[Bridge] sendEvent Fehler:', error);
            this._fireEvent('onError', { type, error: error.message });
        }
    },

    /**
     * Subform-Daten via REST-API laden (Browser-Modus)
     */
    async _handleLoadSubformData(data) {
        const { type, ma_id, va_id } = data;
        let result = [];

        switch (type) {
            case 'dp_grund':
                // Dienstplan-Gruende (Zeittypen)
                result = await apiFetch('/dienstplan/gruende');
                this._fireEvent('onDataReceived', {
                    type: 'dp_grund',
                    records: Array.isArray(result) ? result : (result.data || [])
                });
                break;

            case 'dp_grund_ma':
                // Abwesenheiten/Gruende fuer einen Mitarbeiter
                if (!ma_id) {
                    this._fireEvent('onDataReceived', { type: 'dp_grund_ma', records: [] });
                    return;
                }
                result = await apiFetch(`/abwesenheiten?ma_id=${ma_id}`);
                this._fireEvent('onDataReceived', {
                    type: 'dp_grund_ma',
                    records: Array.isArray(result) ? result : (result.data || [])
                });
                break;

            case 'ma_offene_anfragen':
                // Offene Anfragen fuer MA oder VA
                let url = '/anfragen/offen?';
                if (ma_id) url += `ma_id=${ma_id}&`;
                if (va_id) url += `va_id=${va_id}`;
                result = await apiFetch(url);
                this._fireEvent('onDataReceived', {
                    type: 'ma_offene_anfragen',
                    records: Array.isArray(result) ? result : (result.data || [])
                });
                break;

            default:
                console.warn('[Bridge] Unbekannter Subform-Typ:', type);
                this._fireEvent('onDataReceived', { type, records: [] });
        }
    },

    /**
     * Record-Update via REST-API (Browser-Modus)
     */
    async _handleUpdateRecord(data) {
        const { table, id, field, value } = data;
        try {
            await apiFetch('/record/update', {
                method: 'POST',
                body: JSON.stringify({ table, id, field, value })
            });
            this._fireEvent('onRecordUpdated', { table, id, field, value, success: true });
        } catch (error) {
            this._fireEvent('onRecordUpdated', { table, id, field, value, success: false, error: error.message });
        }
    },

    /**
     * Request an Host senden
     */
    async sendRequest(action, params) {
        if (!USE_WEBVIEW2) {
            throw new Error('sendRequest nur im WebView2-Modus verfügbar');
        }

        const reqId = ++requestId;

        return new Promise((resolve, reject) => {
            pendingRequests.set(reqId, { resolve, reject });

            window.chrome.webview.postMessage({
                requestId: reqId,
                action: action,
                params: params
            });

            setTimeout(() => {
                if (pendingRequests.has(reqId)) {
                    pendingRequests.delete(reqId);
                    reject(new Error('Request Timeout'));
                }
            }, 30000);
        });
    },

    /**
     * Event-Handler registrieren
     */
    on(eventName, handler) {
        if (!eventHandlers[eventName]) {
            eventHandlers[eventName] = [];
        }
        eventHandlers[eventName].push(handler);
    },

    /**
     * Event-Handler entfernen
     */
    off(eventName, handler) {
        if (eventHandlers[eventName]) {
            eventHandlers[eventName] = eventHandlers[eventName].filter(h => h !== handler);
        }
    },

    /**
     * Formular mit Daten befüllen
     */
    fillForm(data) {
        Object.keys(data).forEach(key => {
            const el = document.getElementById(key);
            if (el) {
                if (el.tagName === 'SELECT') {
                    el.value = data[key] || '';
                } else if (el.type === 'checkbox') {
                    el.checked = !!data[key];
                } else {
                    el.value = data[key] || '';
                }
            }
        });
    },

    /**
     * Formulardaten auslesen
     */
    getFormData(fieldIds) {
        const data = {};
        fieldIds.forEach(id => {
            const el = document.getElementById(id);
            if (el) {
                if (el.type === 'checkbox') {
                    data[id] = el.checked;
                } else {
                    data[id] = el.value;
                }
            }
        });
        return data;
    },

    /**
     * Execute-Methode (API-kompatibel)
     */
    async execute(action, params = {}) {
        // SQL-Ausführung - spezieller Handler
        if (action === 'executeSQL') {
            if (USE_WEBVIEW2) {
                return await this.sendRequest('executeSQL', params);
            }
            // API Fallback für SQL - nutzt /query Endpoint mit 'query' Parameter
            const result = await apiFetch('/query', {
                method: 'POST',
                body: JSON.stringify({ query: params.sql })
            });
            // Normalisiere Response-Format
            return { rows: result.data || [], success: result.success };
        }

        // Standard-Mappings
        switch (action) {
            case 'getAuftrag':
                return await this.loadData('auftrag', params.id);
            case 'getAuftragListe':
            case 'listAuftraege':
                return await this.list('auftraege', params);
            case 'saveAuftrag':
                return await this.save('auftrag', params);
            case 'deleteAuftrag':
                return await this.delete('auftrag', params.id);
            case 'copyAuftrag':
                if (USE_WEBVIEW2) return await this.sendRequest('copyAuftrag', params);
                return await apiFetch('/auftraege/copy', { method: 'POST', body: JSON.stringify(params) });

            case 'getMitarbeiter':
                return await this.loadData('mitarbeiter', params.id);
            case 'getMitarbeiterListe':
            case 'listMitarbeiter':
                return await this.list('mitarbeiter', params);
            case 'updateMitarbeiter':
                return await this.save('mitarbeiter', params);
            case 'createMitarbeiter':
                return await this.save('mitarbeiter', params);
            case 'deleteMitarbeiter':
                return await this.delete('mitarbeiter', params.id);

            case 'getKunde':
                return await this.loadData('kunde', params.id);
            case 'getKundenListe':
            case 'listKunden':
                return await this.list('kunden', params);
            case 'updateKunde':
            case 'saveKunde':
                return await this.save('kunde', params);
            case 'createKunde':
                return await this.save('kunde', params);
            case 'deleteKunde':
                return await this.delete('kunde', params.id);

            case 'getObjekt':
                return await this.loadData('objekt', params.id);
            case 'getObjektListe':
            case 'listObjekte':
                return await this.list('objekte', params);
            case 'updateObjekt':
            case 'saveObjekt':
                return await this.save('objekt', params);
            case 'createObjekt':
                return await this.save('objekt', params);
            case 'deleteObjekt':
                return await this.delete('objekt', params.id);

            case 'getOrtListe':
                return await this.list('orte', params);
            case 'getStatusListe':
                return await this.list('status', params);
            case 'getDienstkleidungListe':
                return await this.list('dienstkleidung', params);

            case 'getVADatumListe':
                return await this.list('einsatztage', { va_id: params.VA_ID });

            case 'getZuordnungen':
            case 'loadZuordnungen':
                return await this.list('zuordnungen', params);
            case 'createZuordnung':
                return await this.save('zuordnung', params);
            case 'deleteZuordnung':
                return await this.delete('zuordnung', params.id);

            case 'sendEinsatzliste':
                if (USE_WEBVIEW2) return await this.sendRequest('sendEinsatzliste', params);
                return await apiFetch('/einsatzliste/send', { method: 'POST', body: JSON.stringify(params) });

            case 'createRechnungPDF':
                if (USE_WEBVIEW2) return await this.sendRequest('createRechnungPDF', params);
                return await apiFetch('/rechnungen/pdf', { method: 'POST', body: JSON.stringify(params) });

            case 'createBerechnungslistePDF':
                if (USE_WEBVIEW2) return await this.sendRequest('createBerechnungslistePDF', params);
                return await apiFetch('/berechnungsliste/pdf', { method: 'POST', body: JSON.stringify(params) });

            case 'sendToLexware':
                if (USE_WEBVIEW2) return await this.sendRequest('sendToLexware', params);
                return await apiFetch('/lexware/send', { method: 'POST', body: JSON.stringify(params) });

            case 'uploadZusatzdatei':
                if (USE_WEBVIEW2) return await this.sendRequest('uploadZusatzdatei', params);
                return await apiFetch('/zusatzdateien/upload', { method: 'POST', body: JSON.stringify(params) });

            case 'printBWN':
            case 'druckeBWN':
                if (USE_WEBVIEW2) return await this.sendRequest('printBWN', params);
                return await apiFetch('/bwn/print', { method: 'POST', body: JSON.stringify(params) });

            // =============================================
            // NEU: Button-Paritaet Endpoints (FIX 1-3)
            // =============================================

            // FIX 1: Excel-Export (wie Access btnDruckZusage_Click)
            case 'exportAuftragExcel':
                if (USE_WEBVIEW2) return await this.sendRequest('exportAuftragExcel', params);
                return await apiFetch(`/auftraege/${params.va_id}/excel-export`, {
                    method: 'POST',
                    body: JSON.stringify(params)
                });

            // FIX 1 (Teil 2): Status setzen (wie Access Me!Veranst_Status_ID = 2)
            case 'setAuftragStatus':
                if (USE_WEBVIEW2) return await this.sendRequest('setAuftragStatus', params);
                return await apiFetch(`/auftraege/${params.va_id}/status`, {
                    method: 'PUT',
                    body: JSON.stringify(params)
                });

            // FIX 2: Daten in Folgetag kopieren (wie Access btnPlan_Kopie_Click)
            case 'copyToNextDay':
                if (USE_WEBVIEW2) return await this.sendRequest('copyToNextDay', params);
                return await apiFetch(`/auftraege/${params.va_id}/copy-to-next-day`, {
                    method: 'POST',
                    body: JSON.stringify(params)
                });

            // FIX 3: BWN senden mit Option nur_markierte (wie Access cmd_BWN_send_Click)
            case 'sendBWN':
                if (USE_WEBVIEW2) return await this.sendRequest('sendBWN', params);
                return await apiFetch('/bwn/send', {
                    method: 'POST',
                    body: JSON.stringify(params)
                });

            case 'getKundenpreise':
                if (USE_WEBVIEW2) return await this.sendRequest('getKundenpreise', params);
                return await apiFetch(`/kundenpreise?kunde_id=${params.kunde_id || ''}`);

            case 'updateKundenpreise':
                if (USE_WEBVIEW2) return await this.sendRequest('updateKundenpreise', params);
                return await apiFetch('/kundenpreise', { method: 'PUT', body: JSON.stringify(params) });

            // =============================================
            // E-Mail Versand - Dienstplan
            // =============================================

            case 'getDienstplanFuerMitarbeiter':
                // Lädt Dienstplan-Daten für einen Mitarbeiter
                {
                    const queryParams = new URLSearchParams();
                    if (params.von) queryParams.append('von', params.von);
                    if (params.bis) queryParams.append('bis', params.bis);
                    const url = `/dienstplan/ma/${params.ma_id}${queryParams.toString() ? '?' + queryParams.toString() : ''}`;

                    if (USE_WEBVIEW2) return await this.sendRequest('getDienstplanFuerMitarbeiter', params);
                    const result = await apiFetch(url);
                    return result.data || result;
                }

            case 'versendeDienstplanEmail':
                // Versendet Dienstplan per E-Mail
                if (USE_WEBVIEW2) return await this.sendRequest('versendeDienstplanEmail', params);
                return await apiFetch('/dienstplan/email', {
                    method: 'POST',
                    body: JSON.stringify(params)
                });

            default:
                console.warn('[Bridge] Unbekannte Aktion:', action);
                if (USE_WEBVIEW2) {
                    return await this.sendRequest(action, params);
                }
                // Generischer API-Call
                return await apiFetch(`/${action}`, { method: 'POST', body: JSON.stringify(params) });
        }
    },

    // Direktzugriff-APIs
    auftraege: {
        list: async (params) => await Bridge.list('auftraege', params),
        get: async (id) => await Bridge.loadData('auftrag', id),
        create: async (data) => await Bridge.save('auftrag', data),
        update: async (id, data) => await Bridge.save('auftrag', { ...data, id }),
        delete: async (id) => await Bridge.delete('auftrag', id)
    },

    mitarbeiter: {
        list: async (params) => await Bridge.list('mitarbeiter', params),
        get: async (id) => await Bridge.loadData('mitarbeiter', id),
        create: async (data) => await Bridge.save('mitarbeiter', data),
        update: async (id, data) => await Bridge.save('mitarbeiter', { ...data, id }),
        delete: async (id) => await Bridge.delete('mitarbeiter', id)
    },

    kunden: {
        list: async (params) => await Bridge.list('kunden', params),
        get: async (id) => await Bridge.loadData('kunde', id),
        create: async (data) => await Bridge.save('kunde', data),
        update: async (id, data) => await Bridge.save('kunde', { ...data, id }),
        delete: async (id) => await Bridge.delete('kunde', id)
    },

    objekte: {
        list: async (params) => await Bridge.list('objekte', params),
        get: async (id) => await Bridge.loadData('objekt', id),
        create: async (data) => await Bridge.save('objekt', data),
        update: async (id, data) => await Bridge.save('objekt', { ...data, id }),
        delete: async (id) => await Bridge.delete('objekt', id)
    },

    // Cache-Kontrolle
    cache: {
        /**
         * Loescht Cache fuer bestimmten Typ oder komplett
         */
        invalidate: (pattern) => invalidateCache(pattern),

        /**
         * Loescht gesamten Cache
         */
        clear: () => invalidateCache(null),

        /**
         * Gibt Cache-Statistik zurueck
         */
        stats: () => ({
            entries: _cache.size,
            pending: _pending.size
        })
    }
};


/**
 * setFormValue - Speichert einen Wert fuer spaetere Verwendung (z.B. aktuell geladene ID)
 * Wird verwendet um z.B. die aktuelle Kunden-ID, MA-ID etc. zu speichern
 */
Bridge.setFormValue = function(key, value) {
    if (!Bridge._formValues) {
        Bridge._formValues = {};
    }
    Bridge._formValues[key] = value;
    console.debug('[Bridge] setFormValue:', key, '=', value);
};

/**
 * getFormValue - Liest einen gespeicherten Wert
 */
Bridge.getFormValue = function(key) {
    return Bridge._formValues ? Bridge._formValues[key] : null;
};

/**
 * onDataReceived - Wird vom C# Host aufgerufen wenn -data Parameter uebergeben wurde
 * Diese Methode parst die JSON-Daten und feuert das 'onDataReceived' Event
 */
Bridge.onDataReceived = function(dataString) {
    console.log('[Bridge] onDataReceived aufgerufen:', dataString);

    let data = dataString;

    // Falls String, parsen
    if (typeof dataString === 'string') {
        try {
            data = JSON.parse(dataString);
        } catch (e) {
            console.error('[Bridge] JSON Parse Fehler in onDataReceived:', e);
            return;
        }
    }

    console.log('[Bridge] Geparste Daten:', data);

    // Event an alle registrierten Handler feuern
    this._fireEvent('onDataReceived', data);
};

// Globaler Zugriff für Debugging
window.Bridge = Bridge;

// ============================================
// PERFORMANCE & CONNECTION APIS
// ============================================
Bridge.connection = {
    /**
     * Prüft ob Verbindung aktiv ist
     */
    isHealthy: () => connectionHealthy,

    /**
     * Startet Health-Monitoring
     */
    startMonitoring: startHealthMonitoring,

    /**
     * Stoppt Health-Monitoring
     */
    stopMonitoring: () => {
        if (healthCheckTimer) {
            clearInterval(healthCheckTimer);
            healthCheckTimer = null;
        }
    },

    /**
     * Manueller Verbindungstest
     */
    async test() {
        try {
            if (USE_WEBVIEW2) {
                await Bridge.sendRequest('ping', {});
            } else {
                await fetch(API_BASE + '/health', { signal: AbortSignal.timeout(5000) });
            }
            updateConnectionStatus(true);
            return { ok: true, mode: USE_WEBVIEW2 ? 'WebView2' : 'REST' };
        } catch (e) {
            updateConnectionStatus(false);
            return { ok: false, error: e.message };
        }
    },

    /**
     * Konfiguration abrufen/ändern
     */
    config: CONNECTION_CONFIG
};

// Auto-Start Health-Monitoring nach kurzer Verzögerung
setTimeout(() => {
    startHealthMonitoring();
    console.log('[Bridge] Health-Monitoring gestartet');
}, 2000);
