/**
 * API Client - frm_va_Auftragstamm
 *
 * Zentraler API-Client fuer alle Backend-Aufrufe.
 * Basiert auf: api_contract_frm_va_Auftragstamm.md
 *
 * HINWEIS: Alle Funktionen sind async und geben Promises zurueck.
 * Bei Fehlern wird ein Error mit { error, details } geworfen.
 */

'use strict';

const ApiClient = (function() {

    // Basis-URL - anpassen je nach Backend
    const BASE_URL = '/api';

    // ========================================================
    // HTTP HELPER
    // ========================================================

    async function request(method, endpoint, data = null) {
        const url = BASE_URL + endpoint;
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            }
        };

        if (data && (method === 'POST' || method === 'PUT')) {
            options.body = JSON.stringify(data);
        }

        try {
            const response = await fetch(url, options);
            const json = await response.json();

            if (!response.ok) {
                throw {
                    error: json.error || 'Unbekannter Fehler',
                    details: json.details || null,
                    status: response.status
                };
            }

            return json;

        } catch (err) {
            if (err.error) throw err; // Bereits formatierter Fehler
            throw { error: 'Netzwerkfehler', details: err.message };
        }
    }

    // ========================================================
    // AUFTRAG CRUD
    // ========================================================

    /**
     * Einzelnen Auftrag laden
     * @param {number} id - Auftrag-ID
     * @returns {Promise<Object>} Auftrag-Daten
     */
    async function getAuftrag(id) {
        return request('GET', `/auftrag/${id}`);
    }

    /**
     * Auftrag speichern
     * @param {number} id - Auftrag-ID
     * @param {Object} data - Auftrag-Daten
     * @returns {Promise<{success: boolean, ID: number}>}
     */
    async function saveAuftrag(id, data) {
        return request('PUT', `/auftrag/${id}`, data);
    }

    /**
     * Neuen Auftrag anlegen
     * @param {Object} data - Initiale Daten (optional)
     * @returns {Promise<{success: boolean, ID: number}>}
     */
    async function createAuftrag(data = {}) {
        return request('POST', '/auftrag', data);
    }

    /**
     * Auftrag loeschen
     * @param {number} id - Auftrag-ID
     * @returns {Promise<{success: boolean}>}
     */
    async function deleteAuftrag(id) {
        return request('DELETE', `/auftrag/${id}`);
    }

    /**
     * Auftrag kopieren
     * @param {number} id - Auftrag-ID
     * @returns {Promise<{success: boolean, newID: number}>}
     */
    async function copyAuftrag(id) {
        return request('POST', `/auftrag/${id}/copy`);
    }

    // ========================================================
    // AUFTRAGSLISTE (zsub_lstAuftrag)
    // ========================================================

    /**
     * Auftragsliste mit Filter laden
     * @param {Object} filter - Filter-Parameter
     * @param {string} filter.abDatum - VADatum >= abDatum (YYYY-MM-DD)
     * @param {number} filter.status - Veranst_Status_ID (-5 = alle)
     * @param {number} filter.limit - Max. Anzahl (default: 100)
     * @param {number} filter.offset - Pagination offset
     * @returns {Promise<{items: Array, total: number, hasMore: boolean}>}
     */
    async function getAuftragList(filter = {}) {
        const params = new URLSearchParams();

        if (filter.abDatum) params.append('abDatum', filter.abDatum);
        if (filter.status !== undefined) params.append('status', filter.status);
        if (filter.limit) params.append('limit', filter.limit);
        if (filter.offset) params.append('offset', filter.offset);

        const queryString = params.toString();
        const endpoint = '/auftrag/list' + (queryString ? '?' + queryString : '');

        return request('GET', endpoint);
    }

    // ========================================================
    // LOOKUP-DATEN (Comboboxen)
    // ========================================================

    /**
     * VA-Status Liste laden
     * @returns {Promise<Array<{ID: number, Fortschritt: string}>>}
     */
    async function getVAStatus() {
        return request('GET', '/lookup/va-status');
    }

    /**
     * VA-Datum Liste fuer Auftrag laden
     * @param {number} vaId - Auftrag-ID
     * @returns {Promise<Array<{ID: number, VADatum: string}>>}
     */
    async function getVADatumList(vaId) {
        return request('GET', `/lookup/va-datum/${vaId}`);
    }

    /**
     * Objekte laden
     * @returns {Promise<Array<{ID: number, Objekt: string, Strasse: string}>>}
     */
    async function getObjekte() {
        return request('GET', '/lookup/objekt');
    }

    /**
     * Kunden/Veranstalter laden
     * @returns {Promise<Array<{kun_Id: number, kun_Firma: string}>>}
     */
    async function getKunden() {
        return request('GET', '/lookup/kunde');
    }

    /**
     * Anstellungsarten laden
     * @returns {Promise<Array<{ID: number, Anstellungsart: string}>>}
     */
    async function getAnstellungsarten() {
        return request('GET', '/lookup/anstellungsart');
    }

    /**
     * DISTINCT-Werte aus tbl_VA_Auftragstamm
     * @param {string} field - Feldname (Objekt, Ort, Dienstkleidung, Auftrag)
     * @returns {Promise<Array<string>>}
     */
    async function getDistinctValues(field) {
        return request('GET', `/lookup/distinct/${field}`);
    }

    // ========================================================
    // SUBFORM-DATEN
    // ========================================================

    /**
     * Subform-Daten laden
     * @param {string} name - Subform-Name
     * @param {Object} params - LinkChild-Parameter
     * @returns {Promise<{columns: Array, rows: Array}>}
     */
    async function getSubformData(name, params = {}) {
        const queryParams = new URLSearchParams();

        Object.entries(params).forEach(([key, value]) => {
            if (value !== null && value !== undefined) {
                queryParams.append(key, value);
            }
        });

        const queryString = queryParams.toString();
        const endpoint = `/subform/${name}` + (queryString ? '?' + queryString : '');

        return request('GET', endpoint);
    }

    // ========================================================
    // SPEZIAL-ENDPUNKTE
    // ========================================================

    /**
     * VA-Anzeige laden (sub_VA_Anzeige / f_UpdStatus)
     * @param {number} vaId - Auftrag-ID
     * @returns {Promise<{status: string, tage: number, ma_gesamt: number, ma_zugesagt: number, ma_offen: number}>}
     */
    async function getVAAnzeige(vaId) {
        return request('GET', `/va-anzeige/${vaId}`);
    }

    // ========================================================
    // PUBLIC API
    // ========================================================

    return {
        // CRUD
        getAuftrag,
        saveAuftrag,
        createAuftrag,
        deleteAuftrag,
        copyAuftrag,

        // Liste
        getAuftragList,

        // Lookups
        getVAStatus,
        getVADatumList,
        getObjekte,
        getKunden,
        getAnstellungsarten,
        getDistinctValues,

        // Subforms
        getSubformData,

        // Spezial
        getVAAnzeige
    };

})();


// ============================================================
// STUB-MODUS (Entwicklung ohne Backend)
// ============================================================

/**
 * Stub-Implementierung fuer Entwicklung ohne Backend.
 * Aktivieren durch: ApiClient.useStubs(true)
 */
const ApiStubs = (function() {

    let stubsEnabled = false;

    // Simulierte Daten
    const mockAuftrag = {
        ID: 1234,
        Auftrag: 'Testevent',
        Objekt: 'Olympiastadion',
        Objekt_ID: 1,
        Ort: 'Muenchen',
        PLZ: '80809',
        Veranstalter_ID: 1,
        Dat_VA_Von: '2025-12-20',
        Dat_VA_Bis: '2025-12-22',
        Treffp_Zeit: '08:00',
        Treffpunkt: 'Haupteingang',
        Dienstkleidung: 'Schwarz',
        Ansprechpartner: 'Max Mustermann',
        Fahrtkosten: 50.00,
        Veranst_Status_ID: 1,
        Autosend_EL: false,
        Bemerkungen: '',
        Erst_von: 'Admin',
        Erst_am: '2025-12-01',
        Aend_von: null,
        Aend_am: null
    };

    const mockList = [
        { ID: 1001, VADatum_ID: 100, Datum: '2025-12-15', Auftrag: 'Event A', Objekt: 'Olympiastadion', Ort: 'Muenchen', Soll: 10, Ist: 8, Status: 'Neu', kun_Firma: 'Event GmbH' },
        { ID: 1002, VADatum_ID: 101, Datum: '2025-12-16', Auftrag: 'Event B', Objekt: 'Allianz Arena', Ort: 'Muenchen', Soll: 20, Ist: 20, Status: 'Abgeschlossen', kun_Firma: 'Messe AG' },
        { ID: 1003, VADatum_ID: 102, Datum: '2025-12-17', Auftrag: 'Event C', Objekt: 'Messe', Ort: 'Nuernberg', Soll: 15, Ist: 10, Status: 'In Bearbeitung', kun_Firma: 'Sport GmbH' }
    ];

    const mockStatus = [
        { ID: 1, Fortschritt: 'Neu' },
        { ID: 2, Fortschritt: 'In Bearbeitung' },
        { ID: 3, Fortschritt: 'Abgeschlossen' },
        { ID: 4, Fortschritt: 'Berechnet' }
    ];

    // Stub-Funktionen (ueberschreiben ApiClient)
    const stubs = {
        getAuftrag: async (id) => {
            await delay(100);
            return { ...mockAuftrag, ID: id };
        },

        saveAuftrag: async (id, data) => {
            await delay(200);
            console.log('[STUB] saveAuftrag:', id, data);
            return { success: true, ID: id };
        },

        createAuftrag: async (data) => {
            await delay(200);
            const newId = Math.floor(Math.random() * 10000) + 2000;
            console.log('[STUB] createAuftrag:', newId, data);
            return { success: true, ID: newId };
        },

        deleteAuftrag: async (id) => {
            await delay(200);
            console.log('[STUB] deleteAuftrag:', id);
            return { success: true };
        },

        copyAuftrag: async (id) => {
            await delay(300);
            const newId = Math.floor(Math.random() * 10000) + 2000;
            console.log('[STUB] copyAuftrag:', id, '->', newId);
            return { success: true, newID: newId };
        },

        getAuftragList: async (filter) => {
            await delay(150);
            console.log('[STUB] getAuftragList:', filter);
            return { items: mockList, total: mockList.length, hasMore: false };
        },

        getVAStatus: async () => {
            await delay(50);
            return mockStatus;
        },

        getVADatumList: async (vaId) => {
            await delay(50);
            return [
                { ID: 100, VADatum: '2025-12-20' },
                { ID: 101, VADatum: '2025-12-21' },
                { ID: 102, VADatum: '2025-12-22' }
            ];
        },

        getObjekte: async () => {
            await delay(50);
            return [
                { ID: 1, Objekt: 'Olympiastadion', Strasse: 'Spiridon-Louis-Ring' },
                { ID: 2, Objekt: 'Allianz Arena', Strasse: 'Werner-Heisenberg-Allee' }
            ];
        },

        getKunden: async () => {
            await delay(50);
            return [
                { kun_Id: 1, kun_Firma: 'Event GmbH' },
                { kun_Id: 2, kun_Firma: 'Messe AG' }
            ];
        },

        getAnstellungsarten: async () => {
            await delay(50);
            return [
                { ID: 1, Anstellungsart: 'Festangestellt' },
                { ID: 2, Anstellungsart: 'Aushilfe' }
            ];
        },

        getDistinctValues: async (field) => {
            await delay(50);
            const values = {
                'Objekt': ['Olympiastadion', 'Allianz Arena', 'Messe'],
                'Ort': ['Muenchen', 'Nuernberg', 'Stuttgart'],
                'Dienstkleidung': ['Schwarz', 'Weiss', 'Business'],
                'Auftrag': ['Event A', 'Event B', 'Event C']
            };
            return values[field] || [];
        },

        getSubformData: async (name, params) => {
            await delay(100);
            console.log('[STUB] getSubformData:', name, params);
            return { columns: ['ID', 'Name'], rows: [] };
        },

        getVAAnzeige: async (vaId) => {
            await delay(100);
            return {
                status: 'In Bearbeitung',
                tage: 3,
                ma_gesamt: 30,
                ma_zugesagt: 25,
                ma_offen: 5
            };
        }
    };

    function delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    function useStubs(enable) {
        stubsEnabled = enable;
        if (enable) {
            console.log('[ApiClient] Stub-Modus aktiviert');
            Object.assign(ApiClient, stubs);
        }
    }

    function isStubMode() {
        return stubsEnabled;
    }

    return {
        useStubs,
        isStubMode
    };

})();

// Stubs standardmaessig aktivieren (bis Backend existiert)
ApiStubs.useStubs(true);
