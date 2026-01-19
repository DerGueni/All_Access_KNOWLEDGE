/**
 * webview2-bridge.js
 * WebView2 Bridge für direkte Kommunikation mit Access-Backend (Desktop Host)
 * MIT API-FALLBACK für Browser-Entwicklung/Test
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

console.log(`[Bridge] Modus: ${USE_WEBVIEW2 ? 'WebView2' : 'REST-API Fallback (localhost:5000)'}`);

// Event-Handler für empfangene Daten
const eventHandlers = {};
const pendingRequests = new Map();
let requestId = 0;

// ============================================
// WEBVIEW2 MESSAGE HANDLER
// ============================================
if (USE_WEBVIEW2) {
    window.chrome.webview.addEventListener('message', (event) => {
        const data = event.data;

        if (data.requestId && pendingRequests.has(data.requestId)) {
            const { resolve, reject } = pendingRequests.get(data.requestId);
            pendingRequests.delete(data.requestId);

            if (data.error) {
                reject(new Error(data.error));
            } else {
                resolve(data);
            }
        } else if (data.event) {
            const handlers = eventHandlers[data.event] || [];
            handlers.forEach(handler => handler(data.data));
        }
    });
}

// ============================================
// REST API FALLBACK FUNCTIONS
// ============================================
async function apiFetch(endpoint, options = {}) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error(`[Bridge API] Fehler bei ${endpoint}:`, error);
        throw error;
    }
}

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
export const Bridge = {
    /**
     * Daten vom Host laden
     */
    async loadData(type, id) {
        if (USE_WEBVIEW2) {
            return this.sendRequest('loadData', { type, id });
        }
        // API Fallback
        const endpoint = TYPE_ENDPOINTS[type] || `/${type}`;
        return await apiFetch(`${endpoint}/${id}`);
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
            return this.sendRequest('save', { type, data });
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
                window.parent.postMessage({ type: 'navigate', formName, id }, '*');
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
     */
    sendEvent(type, data) {
        if (USE_WEBVIEW2) {
            window.chrome.webview.postMessage({ event: type, data: data });
        } else {
            console.log('[Bridge] Event (Browser-Modus):', type, data);
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

            case 'getKunde':
                return await this.loadData('kunde', params.id);
            case 'getKundenListe':
            case 'listKunden':
                return await this.list('kunden', params);

            case 'getOrtListe':
                return await this.list('orte', params);
            case 'getObjektListe':
                return await this.list('objekte', params);
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
                if (USE_WEBVIEW2) return await this.sendRequest('printBWN', params);
                return await apiFetch('/bwn/print', { method: 'POST', body: JSON.stringify(params) });

            case 'getKundenpreise':
                if (USE_WEBVIEW2) return await this.sendRequest('getKundenpreise', params);
                return await apiFetch(`/kundenpreise?kunde_id=${params.kunde_id || ''}`);

            case 'updateKundenpreise':
                if (USE_WEBVIEW2) return await this.sendRequest('updateKundenpreise', params);
                return await apiFetch('/kundenpreise', { method: 'PUT', body: JSON.stringify(params) });

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
        get: async (id) => await Bridge.loadData('mitarbeiter', id)
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
    }
};

// Globaler Zugriff für Debugging
window.Bridge = Bridge;
