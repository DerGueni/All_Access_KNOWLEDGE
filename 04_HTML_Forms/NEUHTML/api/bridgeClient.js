/**
 * bridgeClient.js
 * REST-Adapter zur Access Bridge API (localhost:5000)
 * Echte Datenbank-Anbindung über api_server.py
 *
 * PERFORMANCE-OPTIMIERUNGEN:
 * - Request-Caching mit TTL
 * - Request-Deduplication
 * - Batch-Requests
 */

const API_BASE = "http://localhost:5000/api";

// ============================================
// PERFORMANCE: Request Cache
// ============================================
const _cache = new Map();
const _pendingRequests = new Map();
const DEFAULT_CACHE_TTL = 30000; // 30 Sekunden

// Cache-TTL pro Endpoint (in ms)
const CACHE_TTL = {
    '/mitarbeiter': 60000,      // 1 Minute - aendert sich selten
    '/kunden': 60000,           // 1 Minute
    '/objekte': 60000,          // 1 Minute
    '/dienstplan/gruende': 300000, // 5 Minuten - fast statisch
    '/auftraege': 15000,        // 15 Sekunden - aendert sich oefter
    '/dashboard': 10000,        // 10 Sekunden
    '/zuordnungen': 5000,       // 5 Sekunden - live Daten
    '/anfragen': 5000,          // 5 Sekunden - live Daten
    '/verfuegbarkeit': 5000     // 5 Sekunden - live Daten
};

function getCacheTTL(endpoint) {
    for (const [pattern, ttl] of Object.entries(CACHE_TTL)) {
        if (endpoint.startsWith(pattern)) {
            return ttl;
        }
    }
    return DEFAULT_CACHE_TTL;
}

function getCacheKey(method, endpoint, data) {
    return `${method}:${endpoint}:${JSON.stringify(data || {})}`;
}

function getFromCache(key) {
    const cached = _cache.get(key);
    if (!cached) return null;

    if (Date.now() - cached.timestamp > cached.ttl) {
        _cache.delete(key);
        return null;
    }

    return cached.data;
}

function setCache(key, data, ttl) {
    _cache.set(key, {
        data,
        timestamp: Date.now(),
        ttl
    });

    // Cache-Groesse begrenzen (max 100 Eintraege)
    if (_cache.size > 100) {
        const firstKey = _cache.keys().next().value;
        _cache.delete(firstKey);
    }
}

// ============================================
// PERFORMANCE: Request Deduplication
// ============================================
async function dedupedFetch(key, fetchFn) {
    // Pruefe ob identischer Request bereits laeuft
    if (_pendingRequests.has(key)) {
        return _pendingRequests.get(key);
    }

    const promise = fetchFn().finally(() => {
        _pendingRequests.delete(key);
    });

    _pendingRequests.set(key, promise);
    return promise;
}

// ============================================
// API Methoden mit Caching
// ============================================
async function apiGet(endpoint, params = {}, options = {}) {
    const url = new URL(API_BASE + endpoint);
    Object.keys(params).forEach(key => {
        if (params[key] !== undefined && params[key] !== null) {
            url.searchParams.append(key, params[key]);
        }
    });

    const urlStr = url.toString();
    const cacheKey = getCacheKey('GET', endpoint, params);

    // Cache pruefen (ausser noCache Option)
    if (!options.noCache) {
        const cached = getFromCache(cacheKey);
        if (cached) {
            return cached;
        }
    }

    // Deduplication + Fetch
    const data = await dedupedFetch(cacheKey, async () => {
        const res = await fetch(urlStr);
        if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
        return await res.json();
    });

    // In Cache speichern
    const ttl = getCacheTTL(endpoint);
    setCache(cacheKey, data, ttl);

    return data;
}

async function apiPost(endpoint, data = {}) {
    const res = await fetch(API_BASE + endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);

    // POST invalidiert GET-Cache fuer diesen Endpoint
    invalidateCachePattern(endpoint.split('/')[1]);

    return await res.json();
}

async function apiPut(endpoint, data = {}) {
    const res = await fetch(API_BASE + endpoint, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);

    // PUT invalidiert Cache
    invalidateCachePattern(endpoint.split('/')[1]);

    return await res.json();
}

async function apiDelete(endpoint) {
    const res = await fetch(API_BASE + endpoint, { method: "DELETE" });
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);

    // DELETE invalidiert Cache
    invalidateCachePattern(endpoint.split('/')[1]);

    return await res.json();
}

// ============================================
// Cache Management
// ============================================
function invalidateCachePattern(pattern) {
    for (const key of _cache.keys()) {
        if (key.includes(pattern)) {
            _cache.delete(key);
        }
    }
}

function clearCache() {
    _cache.clear();
}

function getCacheStats() {
    return {
        size: _cache.size,
        pendingRequests: _pendingRequests.size
    };
}

export const Bridge = {
    // ============ Generische Execute-Methode ============
    async execute(action, params = {}) {
        switch (action) {
            // Aufträge
            case 'getAuftrag':
                return await apiGet(`/auftraege/${params.id}`);
            case 'getAuftragListe':
            case 'listAuftraege':
            case 'loadAuftragsliste':
                return await apiGet('/auftraege', params);
            case 'saveAuftrag':
                if (params.VA_ID) {
                    return await apiPut(`/auftraege/${params.VA_ID}`, params);
                } else {
                    return await apiPost('/auftraege', params);
                }
            case 'deleteAuftrag':
                return await apiDelete(`/auftraege/${params.id}`);

            // Mitarbeiter
            case 'getMitarbeiter':
                return await apiGet(`/mitarbeiter/${params.id}`);
            case 'getMitarbeiterListe':
            case 'listMitarbeiter':
                return await apiGet('/mitarbeiter', params);

            // Kunden
            case 'getKunde':
                return await apiGet(`/kunden/${params.id}`);
            case 'getKundenListe':
            case 'listKunden':
                return await apiGet('/kunden', params);

            // Einsatztage
            case 'getEinsatztage':
            case 'getVADatumListe':
                return await apiGet('/einsatztage', { va_id: params.VA_ID || params.va_id });

            // Zuordnungen (MA-VA)
            case 'getZuordnungen':
            case 'loadZuordnungen':
                return await apiGet('/zuordnungen', params);
            case 'createZuordnung':
                return await apiPost('/zuordnungen', params);
            case 'deleteZuordnung':
                return await apiDelete(`/zuordnungen/${params.id}`);

            // Anfragen
            case 'getAnfragen':
            case 'loadAnfragen':
                return await apiGet('/anfragen', params);
            case 'updateAnfrage':
                return await apiPut(`/anfragen/${params.id}`, params);

            // Verfügbarkeit
            case 'checkVerfuegbarkeit':
            case 'getVerfuegbareMitarbeiter':
                return await apiGet('/verfuegbarkeit', params);

            // Dashboard
            case 'getDashboard':
                return await apiGet('/dashboard');

            // Tabellen
            case 'getTables':
                return await apiGet('/tables');

            // Custom Query
            case 'query':
                return await apiPost('/query', params);

            // Lookups (für ComboBoxen)
            case 'getOrtListe':
                return await apiPost('/query', {
                    query: "SELECT DISTINCT VA_Ort AS Ort FROM tbl_VA_Auftrag WHERE VA_Ort IS NOT NULL ORDER BY VA_Ort"
                });
            case 'getObjektListe':
                return await apiPost('/query', {
                    query: "SELECT DISTINCT VA_Objekt AS Objekt, VA_ID AS Objekt_ID FROM tbl_VA_Auftrag WHERE VA_Objekt IS NOT NULL ORDER BY VA_Objekt"
                });
            case 'getStatusListe':
                return await apiPost('/query', {
                    query: "SELECT Status_ID, Status_Bez FROM tbl_Status ORDER BY Status_ID"
                });
            case 'getDienstkleidungListe':
                return await apiPost('/query', {
                    query: "SELECT DK_ID, DK_Bezeichnung FROM tbl_Dienstkleidung ORDER BY DK_Bezeichnung"
                });

            // Subform-Daten
            case 'loadSubform':
                return await this.loadSubformData(params.name, params.params || params);

            // ============ Generische CRUD-Operationen ============

            // Einzelnes Feld aktualisieren
            case 'updateField':
                return await apiPut('/field', {
                    table: params.table,
                    id: params.id,
                    field: params.field,
                    value: params.value
                });

            // Neuen Record einfügen
            case 'insertRecord':
                return await apiPost('/record', {
                    table: params.table,
                    data: params.data
                });

            // Record löschen
            case 'deleteRecord':
                return await apiDelete('/record', {
                    table: params.table,
                    id: params.id
                });

            // ============ Bewerber ============
            case 'getBewerber':
                return await apiGet(`/bewerber/${params.id}`);
            case 'getBewerberListe':
            case 'listBewerber':
                return await apiGet('/bewerber', params);
            case 'acceptBewerber':
                return await apiPost(`/bewerber/${params.id}/accept`);
            case 'rejectBewerber':
                return await apiPost(`/bewerber/${params.id}/reject`);

            // ============ Lohnabrechnungen ============
            case 'getLohnabrechnungen':
                return await apiGet('/lohn/abrechnungen', params);
            case 'getStundenExport':
                return await apiGet('/lohn/stunden-export', params);

            // ============ Zeitkonten ============
            case 'getImportfehler':
                return await apiGet('/zeitkonten/importfehler', params);
            case 'fixImportfehler':
                return await apiPost(`/zeitkonten/importfehler/${params.id}/fix`);
            case 'ignoreImportfehler':
                return await apiPost(`/zeitkonten/importfehler/${params.id}/ignore`);

            // ============ Dienstplan ============
            case 'getDienstplanMA':
                return await apiGet(`/dienstplan/ma/${params.ma_id}`, params);
            case 'getDienstplanObjekt':
                return await apiGet(`/dienstplan/objekt/${params.objekt_id}`, params);
            case 'getDienstplanGruende':
                return await apiGet('/dienstplan/gruende');
            case 'getSchichten':
                return await apiGet('/dienstplan/schichten', params);

            default:
                console.warn(`[Bridge] Unbekannte Aktion: ${action}`);
                return { success: false, error: `Unbekannte Aktion: ${action}` };
        }
    },

    // ============ Subform-Daten laden ============
    async loadSubformData(subformName, params) {
        const va_id = params.VA_ID || params.va_id;
        const datum = params.VADatum || params.datum;
        const start_id = params.VAStart_ID || params.vas_id;

        switch (subformName) {
            case 'sub_VA_Start':
                // Schichten für einen Auftrag/Datum
                return await apiPost('/query', {
                    query: `SELECT s.*, d.VADatum
                            FROM tbl_VA_Start s
                            INNER JOIN tbl_VA_Datum d ON s.VAS_VADatum_ID = d.VADatum_ID
                            WHERE d.VADatum_VA_ID = ${va_id || 0}
                            ${datum ? `AND d.VADatum = #${datum}#` : ''}
                            ORDER BY d.VADatum, s.VAS_Von`
                });

            case 'sub_MA_VA_Zuordnung':
                // MA-Zuordnungen für eine Schicht
                return await apiGet('/zuordnungen', { va_id, datum });

            case 'sub_MA_VA_Planung_Absage':
                // Absagen für einen Auftrag
                return await apiGet('/anfragen', { va_id, status: 3 });

            case 'sub_MA_VA_Planung_Status':
                // Offene Anfragen
                return await apiGet('/anfragen', { va_id, status: 1 });

            case 'sub_ZusatzDateien':
                // Anhänge (wenn Tabelle existiert)
                return await apiPost('/query', {
                    query: `SELECT * FROM tbl_VA_Attach WHERE Attach_VA_ID = ${va_id || 0} ORDER BY Attach_ID`
                });

            case 'sub_VA_Anzeige':
                // Auftragsinfo
                return await apiGet(`/auftraege/${va_id}`);

            case 'frm_lst_row_auftrag':
                // Auftragsliste
                const filter = params.filter || {};
                return await apiGet('/auftraege', {
                    limit: 50,
                    ...filter
                });

            default:
                return { success: false, error: `Unbekanntes Subform: ${subformName}` };
        }
    },

    // ============ Direktzugriff ============
    auftraege: {
        list: (params) => apiGet('/auftraege', params),
        get: (id) => apiGet(`/auftraege/${id}`),
        create: (data) => apiPost('/auftraege', data),
        update: (id, data) => apiPut(`/auftraege/${id}`, data),
        delete: (id) => apiDelete(`/auftraege/${id}`)
    },

    mitarbeiter: {
        list: (params) => apiGet('/mitarbeiter', params),
        get: (id) => apiGet(`/mitarbeiter/${id}`)
    },

    kunden: {
        list: (params) => apiGet('/kunden', params),
        get: (id) => apiGet(`/kunden/${id}`),
        create: (data) => apiPost('/kunden', data),
        update: (id, data) => apiPut(`/kunden/${id}`, data),
        delete: (id) => apiDelete(`/kunden/${id}`)
    },

    zuordnungen: {
        list: (params) => apiGet('/zuordnungen', params),
        create: (data) => apiPost('/zuordnungen', data),
        delete: (id) => apiDelete(`/zuordnungen/${id}`)
    },

    anfragen: {
        list: (params) => apiGet('/anfragen', params),
        update: (id, data) => apiPut(`/anfragen/${id}`, data)
    },

    // ============ Objekte ============
    objekte: {
        list: (params) => apiGet('/objekte', params),
        get: (id) => apiGet(`/objekte/${id}`),
        create: (data) => apiPost('/objekte', data),
        update: (id, data) => apiPut(`/objekte/${id}`, data),
        delete: (id) => apiDelete(`/objekte/${id}`),
        positionen: (objektId) => apiGet(`/objekte/${objektId}/positionen`)
    },

    // ============ Bewerber ============
    bewerber: {
        list: (params) => apiGet('/bewerber', params),
        get: (id) => apiGet(`/bewerber/${id}`),
        create: (data) => apiPost('/bewerber', data),
        update: (id, data) => apiPut(`/bewerber/${id}`, data),
        accept: (id) => apiPost(`/bewerber/${id}/accept`),
        reject: (id) => apiPost(`/bewerber/${id}/reject`)
    },

    // ============ Lohn/Stunden ============
    lohn: {
        abrechnungen: (params) => apiGet('/lohn/abrechnungen', params),
        stundenExport: (params) => apiGet('/lohn/stunden-export', params),
        stundenabgleich: (maId, periode) => apiGet('/lohn/stundenabgleich', { ma_id: maId, periode })
    },

    // ============ Rückmeldungen ============
    rueckmeldungen: {
        list: (params) => apiGet('/rueckmeldungen', params),
        get: (id) => apiGet(`/rueckmeldungen/${id}`),
        markRead: (id) => apiPut(`/rueckmeldungen/${id}/read`),
        markAllRead: () => apiPost('/rueckmeldungen/mark-all-read')
    },

    // ============ Zeitkonten ============
    zeitkonten: {
        importfehler: (params) => apiGet('/zeitkonten/importfehler', params),
        fixError: (id) => apiPost(`/zeitkonten/importfehler/${id}/fix`),
        ignoreError: (id) => apiPost(`/zeitkonten/importfehler/${id}/ignore`)
    },

    // ============ Dienstplan ============
    dienstplan: {
        getByMA: (maId, params) => apiGet(`/dienstplan/ma/${maId}`, params),
        getByObjekt: (objektId, params) => apiGet(`/dienstplan/objekt/${objektId}`, params),
        gruende: () => apiGet('/dienstplan/gruende'),
        schichten: (params) => apiGet('/dienstplan/schichten', params)
    },

    // ============ Abwesenheiten ============
    abwesenheiten: {
        list: (params) => apiGet('/abwesenheiten', params),
        get: (id) => apiGet(`/abwesenheiten/${id}`),
        create: (data) => apiPost('/abwesenheiten', data),
        update: (id, data) => apiPut(`/abwesenheiten/${id}`, data),
        delete: (id) => apiDelete(`/abwesenheiten/${id}`)
    },

    // ============ Einsatztage ============
    einsatztage: {
        list: (params) => apiGet('/einsatztage', params),
        byAuftrag: (va_id) => apiGet('/einsatztage', { va_id })
    },

    // ============ Verfügbarkeit ============
    verfuegbarkeit: {
        check: (params) => apiGet('/verfuegbarkeit/check', params),
        list: (datum) => apiGet('/verfuegbarkeit', { datum })
    },

    // ============ Planungen ============
    planungen: {
        list: (params) => apiGet('/planungen', params),
        create: (data) => apiPost('/planungen', data),
        update: (id, data) => apiPut(`/planungen/${id}`, data),
        delete: (id) => apiDelete(`/planungen/${id}`)
    },

    // ============ Utility ============
    query: (sql) => apiPost('/query', { query: sql }),
    dashboard: {
        get: () => apiGet('/dashboard')
    },
    tables: () => apiGet('/tables'),

    // ============ Cache Management ============
    cache: {
        clear: clearCache,
        invalidate: invalidateCachePattern,
        stats: getCacheStats
    }
};

// Globaler Zugriff für Debugging
window.Bridge = Bridge;
