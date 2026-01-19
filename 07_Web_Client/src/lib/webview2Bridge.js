/**
 * WebView2 Bridge - Promise-basierte API für VBA-Kommunikation
 * Version 3.0 - Kompatibel mit mod_N_WebHost_Bridge.bas
 *
 * FEATURES:
 * - Promise-basierte Requests (async/await)
 * - Request/Response Matching via requestId
 * - Automatisches Error-Handling
 * - CRUD-Operations (loadData, list, save, delete)
 * - Type-Safe Mapping zu Access-Tabellen
 *
 * VERWENDUNG:
 * import { Bridge } from './webview2Bridge.js';
 *
 * // Einzelnen Datensatz laden
 * const mitarbeiter = await Bridge.loadData('mitarbeiter', 123);
 *
 * // Liste laden
 * const liste = await Bridge.list('mitarbeiter', {
 *   filters: { IstAktiv: true },
 *   orderBy: 'Nachname',
 *   limit: 100
 * });
 *
 * // Speichern (INSERT/UPDATE)
 * const result = await Bridge.save('mitarbeiter', {
 *   ID: 123, // Optional - wenn vorhanden: UPDATE, sonst: INSERT
 *   Nachname: 'Mustermann',
 *   Vorname: 'Max'
 * });
 *
 * // Löschen
 * await Bridge.delete('mitarbeiter', 123);
 */

(function() {
    'use strict';

    // Pending Requests (Promise-Tracking)
    const pendingRequests = new Map();

    // Request-ID Generator
    let requestCounter = 0;
    function generateRequestId() {
        return `req_${Date.now()}_${++requestCounter}`;
    }

    // Prüfen ob in WebView2 Environment
    function isWebView2() {
        return !!(window.chrome && window.chrome.webview);
    }

    /**
     * Sendet Message an VBA und wartet auf Response
     * @param {string} action - Action-Type (loadData, list, save, delete)
     * @param {object} payload - Zusätzliche Daten
     * @returns {Promise<any>} Response-Daten
     */
    function sendMessage(action, payload) {
        return new Promise((resolve, reject) => {
            if (!isWebView2()) {
                reject(new Error('WebView2 nicht verfügbar - läuft nicht in Access'));
                return;
            }

            const requestId = generateRequestId();
            const message = {
                requestId,
                action,
                ...payload
            };

            // Promise registrieren
            pendingRequests.set(requestId, { resolve, reject });

            // Timeout (10 Sekunden)
            const timeout = setTimeout(() => {
                pendingRequests.delete(requestId);
                reject(new Error(`Request timeout: ${action}`));
            }, 10000);

            // Store timeout in request für Cleanup
            pendingRequests.get(requestId).timeout = timeout;

            // Message senden
            console.log('[Bridge] Sende:', message);
            window.chrome.webview.postMessage(JSON.stringify(message));
        });
    }

    /**
     * Response-Handler (wird von WebView2 aufgerufen)
     */
    function handleResponse(event) {
        try {
            let response;

            // JSON parsen
            if (typeof event.data === 'string') {
                response = JSON.parse(event.data);
            } else {
                response = event.data;
            }

            console.log('[Bridge] Empfangen:', response);

            const { requestId, success, data, error } = response;

            // Request finden
            const request = pendingRequests.get(requestId);
            if (!request) {
                console.warn('[Bridge] Keine pending request für:', requestId);
                return;
            }

            // Timeout clearen
            clearTimeout(request.timeout);

            // Promise resolven/rejecten
            if (success) {
                request.resolve(data);
            } else {
                request.reject(new Error(error || 'Unbekannter Fehler'));
            }

            // Request entfernen
            pendingRequests.delete(requestId);

        } catch (err) {
            console.error('[Bridge] Fehler beim Verarbeiten der Response:', err);
        }
    }

    // Event-Listener registrieren
    if (isWebView2()) {
        window.chrome.webview.addEventListener('message', handleResponse);
        console.log('[Bridge] WebView2 Message-Listener registriert');
    }

    /**
     * Bridge API
     */
    const Bridge = {
        /**
         * Lädt einzelnen Datensatz nach ID
         * @param {string} type - Datentyp (mitarbeiter, kunden, auftraege, ...)
         * @param {number} id - Datensatz-ID
         * @returns {Promise<object>} Datensatz
         */
        async loadData(type, id) {
            return sendMessage('loadData', { type, id });
        },

        /**
         * Lädt Liste von Datensätzen
         * @param {string} type - Datentyp
         * @param {object} options - Filter/Sort/Limit
         * @param {object} options.filters - WHERE-Filters { IstAktiv: true, PLZ: '12345' }
         * @param {string} options.orderBy - ORDER BY Clause 'Nachname, Vorname'
         * @param {number} options.limit - LIMIT (TOP N)
         * @returns {Promise<Array>} Array von Datensätzen
         */
        async list(type, options = {}) {
            return sendMessage('list', {
                type,
                filters: options.filters || {},
                orderBy: options.orderBy || '',
                limit: options.limit || 0
            });
        },

        /**
         * Speichert Datensatz (INSERT oder UPDATE)
         * @param {string} type - Datentyp
         * @param {object} data - Datensatz-Daten (mit ID = UPDATE, ohne ID = INSERT)
         * @returns {Promise<{success: boolean, id: number}>}
         */
        async save(type, data) {
            return sendMessage('save', { type, data });
        },

        /**
         * Löscht Datensatz nach ID
         * @param {string} type - Datentyp
         * @param {number} id - Datensatz-ID
         * @returns {Promise<{success: boolean}>}
         */
        async delete(type, id) {
            return sendMessage('delete', { type, id });
        },

        /**
         * Prüft ob in WebView2 Environment
         * @returns {boolean}
         */
        isAvailable() {
            return isWebView2();
        },

        /**
         * Gibt Anzahl pending Requests zurück (für Debugging)
         * @returns {number}
         */
        getPendingCount() {
            return pendingRequests.size;
        }
    };

    // Legacy-Kompatibilität mit v2.0 Bridge
    Bridge.sendEvent = function(eventType, data) {
        console.warn('[Bridge] sendEvent() ist deprecated - verwende spezifische Methoden (loadData, save, etc.)');

        if (!isWebView2()) {
            console.error('[Bridge] WebView2 nicht verfügbar');
            return;
        }

        const message = JSON.stringify({
            type: eventType,
            timestamp: new Date().toISOString(),
            ...data
        });

        window.chrome.webview.postMessage(message);
    };

    // Export
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = { Bridge };
    } else if (typeof window !== 'undefined') {
        window.Bridge = Bridge;
    }

    console.log('[Bridge] webview2Bridge.js v3.0 geladen');

})();

// ========================================
// USAGE EXAMPLES (für Copy-Paste)
// ========================================

/*

// === BEISPIEL 1: Mitarbeiter laden ===

async function loadMitarbeiter(id) {
    try {
        const ma = await Bridge.loadData('mitarbeiter', id);
        console.log('Mitarbeiter:', ma);

        // Felder befüllen
        document.getElementById('nachname').value = ma.Nachname;
        document.getElementById('vorname').value = ma.Vorname;
        document.getElementById('tel').value = ma.Tel_Mobil;

    } catch (error) {
        console.error('Fehler beim Laden:', error);
        alert('Mitarbeiter konnte nicht geladen werden: ' + error.message);
    }
}

// === BEISPIEL 2: Mitarbeiterliste (gefiltert) ===

async function loadMitarbeiterListe() {
    try {
        const liste = await Bridge.list('mitarbeiter', {
            filters: { IstAktiv: true },
            orderBy: 'Nachname, Vorname',
            limit: 100
        });

        console.log(`${liste.length} Mitarbeiter geladen`);

        // Tabelle befüllen
        const tbody = document.querySelector('#ma-table tbody');
        tbody.innerHTML = '';

        liste.forEach(ma => {
            const row = tbody.insertRow();
            row.innerHTML = `
                <td>${ma.ID}</td>
                <td>${ma.Nachname}</td>
                <td>${ma.Vorname}</td>
                <td>${ma.Tel_Mobil || ''}</td>
            `;
        });

    } catch (error) {
        console.error('Fehler beim Laden:', error);
    }
}

// === BEISPIEL 3: Mitarbeiter speichern (UPDATE) ===

async function saveMitarbeiter(id) {
    try {
        const data = {
            ID: id,
            Nachname: document.getElementById('nachname').value,
            Vorname: document.getElementById('vorname').value,
            Tel_Mobil: document.getElementById('tel').value
        };

        const result = await Bridge.save('mitarbeiter', data);
        console.log('Gespeichert:', result);

        alert('Mitarbeiter erfolgreich gespeichert!');

    } catch (error) {
        console.error('Fehler beim Speichern:', error);
        alert('Fehler beim Speichern: ' + error.message);
    }
}

// === BEISPIEL 4: Neuen Mitarbeiter erstellen (INSERT) ===

async function createMitarbeiter() {
    try {
        const data = {
            // KEINE ID! -> INSERT
            Nachname: document.getElementById('nachname').value,
            Vorname: document.getElementById('vorname').value,
            IstAktiv: true,
            Tel_Mobil: document.getElementById('tel').value
        };

        const result = await Bridge.save('mitarbeiter', data);
        console.log('Neuer Mitarbeiter erstellt mit ID:', result.id);

        alert('Mitarbeiter erstellt mit ID: ' + result.id);

        // Neu laden mit der ID
        await loadMitarbeiter(result.id);

    } catch (error) {
        console.error('Fehler beim Erstellen:', error);
        alert('Fehler beim Erstellen: ' + error.message);
    }
}

// === BEISPIEL 5: Mitarbeiter löschen ===

async function deleteMitarbeiter(id) {
    if (!confirm('Mitarbeiter wirklich löschen?')) {
        return;
    }

    try {
        await Bridge.delete('mitarbeiter', id);
        console.log('Mitarbeiter gelöscht:', id);

        alert('Mitarbeiter gelöscht!');

        // Zurück zur Liste
        await loadMitarbeiterListe();

    } catch (error) {
        console.error('Fehler beim Löschen:', error);
        alert('Fehler beim Löschen: ' + error.message);
    }
}

// === BEISPIEL 6: Formular beim Laden initialisieren ===

document.addEventListener('DOMContentLoaded', async () => {
    console.log('Formular geladen');

    // Prüfen ob WebView2 verfügbar
    if (!Bridge.isAvailable()) {
        alert('WARNUNG: Läuft nicht in Access WebView2!');
        return;
    }

    // ID aus URL-Parameter holen
    const params = new URLSearchParams(window.location.search);
    const id = params.get('id');

    if (id) {
        await loadMitarbeiter(id);
    } else {
        // Neue Eingabe
        console.log('Neuer Datensatz');
    }

    // Event-Handler für Buttons
    document.getElementById('btn-save').addEventListener('click', async () => {
        if (id) {
            await saveMitarbeiter(id);
        } else {
            await createMitarbeiter();
        }
    });

    document.getElementById('btn-delete').addEventListener('click', async () => {
        if (id) {
            await deleteMitarbeiter(id);
        }
    });
});

// === BEISPIEL 7: Kunden-Suche mit Autocomplete ===

let searchTimeout;

document.getElementById('search').addEventListener('input', (e) => {
    clearTimeout(searchTimeout);

    const term = e.target.value.trim();
    if (term.length < 2) return;

    searchTimeout = setTimeout(async () => {
        try {
            const results = await Bridge.list('kunden', {
                filters: {
                    // LIKE-Filter müsste in VBA erweitert werden
                    kun_Firma: term
                },
                orderBy: 'kun_Firma',
                limit: 10
            });

            // Autocomplete befüllen
            const dropdown = document.getElementById('search-results');
            dropdown.innerHTML = '';

            results.forEach(kunde => {
                const item = document.createElement('div');
                item.className = 'dropdown-item';
                item.textContent = kunde.kun_Firma;
                item.addEventListener('click', () => {
                    loadKunde(kunde.kun_Id);
                });
                dropdown.appendChild(item);
            });

        } catch (error) {
            console.error('Suchfehler:', error);
        }
    }, 300);
});

// === BEISPIEL 8: Alle verfügbaren Datentypen ===

const AVAILABLE_TYPES = [
    'mitarbeiter',      // tbl_MA_Mitarbeiterstamm
    'kunden',           // tbl_KD_Kundenstamm
    'auftraege',        // tbl_VA_Auftragstamm
    'objekte',          // tbl_OB_Objekt
    'zuordnungen',      // tbl_MA_VA_Planung
    'anfragen',         // tbl_MA_VA_Anfragen
    'schichten',        // tbl_VA_Start
    'einsatztage',      // tbl_VA_AnzTage
    'abwesenheiten',    // tbl_MA_NVerfuegZeiten
    'bewerber',         // tbl_MA_Bewerber
    'lohnabrechnungen', // tbl_Lohn_Abrechnungen
    'zeitkonten'        // tbl_Zeitkonten_Importfehler
];

*/
