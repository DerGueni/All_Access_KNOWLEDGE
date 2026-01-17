/**
 * fetch-retry.js
 * Zentrale Fetch-Funktion mit automatischem Retry bei Server-Überlastung (503)
 *
 * Einbinden in HTML-Formulare:
 * <script src="js/fetch-retry.js"></script>
 *
 * Verwendung:
 * const data = await fetchRetry('/api/mitarbeiter');
 * const data = await fetchRetry('/api/auftraege/123', { method: 'POST', body: JSON.stringify({...}) });
 */

(function() {
    'use strict';

    const API_BASE = 'http://localhost:5000';

    // Konfiguration
    const CONFIG = {
        maxRetries: 3,           // Maximale Anzahl Retries bei 503
        initialDelay: 500,       // Initiale Wartezeit in ms
        maxDelay: 3000,          // Maximale Wartezeit in ms
        backoffMultiplier: 2,    // Exponentieller Backoff
        timeout: 30000           // Request-Timeout in ms
    };

    // Statistik für Debugging
    const stats = {
        totalRequests: 0,
        retriedRequests: 0,
        failedRequests: 0,
        successfulRequests: 0
    };

    /**
     * Fetch mit automatischem Retry bei 503-Fehlern
     * @param {string} url - API-Endpoint (relativ oder absolut)
     * @param {object} options - Fetch-Optionen
     * @returns {Promise<Response>} - Fetch Response
     */
    async function fetchRetry(url, options = {}) {
        // URL normalisieren
        const fullUrl = url.startsWith('http') ? url : (API_BASE + url);

        stats.totalRequests++;
        let lastError = null;
        let delay = CONFIG.initialDelay;

        for (let attempt = 0; attempt <= CONFIG.maxRetries; attempt++) {
            try {
                // Timeout hinzufügen falls nicht vorhanden
                if (!options.signal) {
                    const controller = new AbortController();
                    setTimeout(() => controller.abort(), CONFIG.timeout);
                    options.signal = controller.signal;
                }

                const response = await fetch(fullUrl, options);

                // Bei 503 (Server überlastet) - Retry mit Backoff
                if (response.status === 503) {
                    const retryAfter = response.headers.get('Retry-After');
                    const waitTime = retryAfter
                        ? parseInt(retryAfter) * 1000
                        : Math.min(delay, CONFIG.maxDelay);

                    if (attempt < CONFIG.maxRetries) {
                        console.log(`[fetchRetry] 503 bei ${url}, Retry ${attempt + 1}/${CONFIG.maxRetries} in ${waitTime}ms`);
                        stats.retriedRequests++;
                        await sleep(waitTime);
                        delay *= CONFIG.backoffMultiplier;
                        continue;
                    }
                }

                // Bei anderen Fehlern (4xx, 5xx) - kein Retry, sofort zurückgeben
                stats.successfulRequests++;
                return response;

            } catch (error) {
                lastError = error;

                // Bei Netzwerk-Fehlern (Server nicht erreichbar) - Retry
                if (error.name === 'TypeError' || error.name === 'AbortError') {
                    if (attempt < CONFIG.maxRetries) {
                        console.log(`[fetchRetry] Netzwerk-Fehler bei ${url}, Retry ${attempt + 1}/${CONFIG.maxRetries}`);
                        stats.retriedRequests++;
                        await sleep(Math.min(delay, CONFIG.maxDelay));
                        delay *= CONFIG.backoffMultiplier;
                        continue;
                    }
                }

                // Bei anderen Fehlern - abbrechen
                break;
            }
        }

        // Alle Retries fehlgeschlagen
        stats.failedRequests++;
        console.error(`[fetchRetry] Alle ${CONFIG.maxRetries} Versuche fehlgeschlagen für ${url}`, lastError);
        throw lastError || new Error(`Request fehlgeschlagen: ${url}`);
    }

    /**
     * Convenience-Funktionen für JSON-Requests
     */
    async function fetchJSON(url, options = {}) {
        const response = await fetchRetry(url, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                ...options.headers
            }
        });

        if (!response.ok) {
            const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
            error.status = response.status;
            try {
                error.body = await response.json();
            } catch (e) {
                error.body = await response.text();
            }
            throw error;
        }

        return response.json();
    }

    async function getJSON(url) {
        return fetchJSON(url, { method: 'GET' });
    }

    async function postJSON(url, data) {
        return fetchJSON(url, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async function putJSON(url, data) {
        return fetchJSON(url, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    async function deleteJSON(url) {
        return fetchJSON(url, { method: 'DELETE' });
    }

    /**
     * Hilfsfunktion: Sleep
     */
    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Öffentliche API
     */
    window.fetchRetry = fetchRetry;
    window.fetchJSON = fetchJSON;
    window.API = {
        get: getJSON,
        post: postJSON,
        put: putJSON,
        delete: deleteJSON,
        fetch: fetchRetry,
        fetchJSON: fetchJSON,
        stats: () => ({ ...stats }),
        config: CONFIG
    };

    console.log('[fetchRetry] Initialisiert - API-Requests werden bei 503 automatisch wiederholt');

})();
