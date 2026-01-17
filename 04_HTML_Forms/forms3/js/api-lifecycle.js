/**
 * api-lifecycle.js
 * Automatische API-Server Lifecycle-Verwaltung
 *
 * Funktionen:
 * - Prueft beim Laden ob API-Server laeuft
 * - Startet Server automatisch wenn noetig (via VBA oder lokal)
 * - Registriert Formular beim Oeffnen
 * - Meldet Formular beim Schliessen ab
 *
 * Einbinden in jedes HTML-Formular:
 * <script src="../js/api-lifecycle.js"></script>
 */

(function() {
    'use strict';

    const API_BASE = 'http://localhost:5000';
    const API_CHECK_ENDPOINT = '/api/tables';
    const CHECK_INTERVAL = 30000; // 30 Sekunden
    const MAX_RETRIES = 3;
    const RETRY_DELAY = 2000; // 2 Sekunden

    // State
    let _isRunning = false;
    let _checkInterval = null;
    let _formId = null;
    let _retryCount = 0;

    /**
     * Initialisiert den Lifecycle-Manager
     */
    async function init() {
        // Generiere Form-ID
        _formId = generateFormId();

        console.log('[API-Lifecycle] Initialisiere...', _formId);

        // Registriere Formular
        registerForm();

        // Pruefe API-Server
        const serverOk = await checkAndStartServer();

        if (serverOk) {
            console.log('[API-Lifecycle] API-Server bereit');
            // Starte periodische Ueberpruefung
            startHealthCheck();
        } else {
            console.warn('[API-Lifecycle] API-Server nicht verfuegbar');
            showServerError();
        }

        // Registriere Cleanup bei Fenster-Schliessen
        window.addEventListener('beforeunload', handleUnload);
        window.addEventListener('unload', handleUnload);
    }

    /**
     * Generiert eindeutige Form-ID
     */
    function generateFormId() {
        const path = window.location.pathname;
        const filename = path.substring(path.lastIndexOf('/') + 1);
        const timestamp = Date.now();
        return `${filename}_${timestamp}`;
    }

    /**
     * Registriert Formular beim "Tracker"
     */
    function registerForm() {
        // Speichere in sessionStorage (Tab-spezifisch)
        const openForms = getOpenForms();
        openForms[_formId] = {
            file: window.location.pathname,
            opened: new Date().toISOString()
        };
        saveOpenForms(openForms);

        // Sende an VBA falls WebView2 vorhanden
        if (window.chrome && window.chrome.webview) {
            window.chrome.webview.postMessage(JSON.stringify({
                type: 'FORM_OPENED',
                formId: _formId
            }));
        }

        console.log('[API-Lifecycle] Formular registriert:', _formId);
    }

    /**
     * Meldet Formular ab
     */
    function unregisterForm() {
        const openForms = getOpenForms();
        delete openForms[_formId];
        saveOpenForms(openForms);

        // Sende an VBA falls WebView2 vorhanden
        if (window.chrome && window.chrome.webview) {
            window.chrome.webview.postMessage(JSON.stringify({
                type: 'FORM_CLOSED',
                formId: _formId,
                remainingForms: Object.keys(openForms).length
            }));
        }

        console.log('[API-Lifecycle] Formular abgemeldet:', _formId);
    }

    /**
     * Holt Liste offener Formulare aus localStorage
     */
    function getOpenForms() {
        try {
            const data = localStorage.getItem('consys_open_forms');
            return data ? JSON.parse(data) : {};
        } catch (e) {
            return {};
        }
    }

    /**
     * Speichert Liste offener Formulare
     */
    function saveOpenForms(forms) {
        try {
            localStorage.setItem('consys_open_forms', JSON.stringify(forms));
        } catch (e) {
            console.warn('[API-Lifecycle] localStorage nicht verfuegbar');
        }
    }

    /**
     * Prueft und startet API-Server wenn noetig
     */
    async function checkAndStartServer() {
        // Erste Pruefung
        if (await isServerRunning()) {
            _isRunning = true;
            return true;
        }

        console.log('[API-Lifecycle] Server nicht erreichbar, versuche Start...');

        // Versuche Server zu starten (via VBA oder lokal)
        const started = await tryStartServer();

        if (!started) {
            return false;
        }

        // Warte auf Server (max 10 Sekunden)
        for (let i = 0; i < 10; i++) {
            await sleep(1000);
            if (await isServerRunning()) {
                _isRunning = true;
                return true;
            }
            console.log('[API-Lifecycle] Warte auf Server... (' + (i+1) + '/10)');
        }

        return false;
    }

    /**
     * Prueft ob Server laeuft
     */
    async function isServerRunning() {
        try {
            const response = await fetch(API_BASE + API_CHECK_ENDPOINT, {
                method: 'GET',
                headers: { 'Accept': 'application/json' },
                signal: AbortSignal.timeout(3000) // 3 Sekunden Timeout
            });
            return response.ok || response.status < 500;
        } catch (e) {
            return false;
        }
    }

    /**
     * Versucht Server zu starten
     */
    async function tryStartServer() {
        // Methode 1: Via WebView2/VBA (wenn in Access eingebettet)
        if (window.chrome && window.chrome.webview) {
            console.log('[API-Lifecycle] Starte via VBA...');
            window.chrome.webview.postMessage(JSON.stringify({
                type: 'START_API_SERVER'
            }));
            return true; // VBA kuemmert sich drum
        }

        // Methode 2: Zeige Anweisung zum manuellen Start
        console.log('[API-Lifecycle] Kein WebView2 - manueller Start erforderlich');
        showStartInstructions();
        return false;
    }

    /**
     * Zeigt Fehler-Overlay wenn Server nicht verfuegbar
     */
    function showServerError() {
        // Pruefe ob bereits vorhanden
        if (document.getElementById('api-error-overlay')) return;

        const overlay = document.createElement('div');
        overlay.id = 'api-error-overlay';
        overlay.innerHTML = `
            <div style="
                position: fixed;
                top: 0; left: 0; right: 0; bottom: 0;
                background: rgba(0,0,0,0.8);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 99999;
            ">
                <div style="
                    background: white;
                    padding: 30px;
                    border-radius: 8px;
                    max-width: 500px;
                    text-align: center;
                    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
                ">
                    <h2 style="color: #c00; margin-bottom: 15px;">
                        API-Server nicht verfuegbar
                    </h2>
                    <p style="margin-bottom: 20px; color: #333;">
                        Der API-Server auf Port 5000 antwortet nicht.
                        Das Formular kann keine Daten laden.
                    </p>
                    <div style="text-align: left; background: #f5f5f5; padding: 15px; border-radius: 4px; margin-bottom: 20px;">
                        <strong>Server starten:</strong><br>
                        <code style="color: #0066cc;">
                            C:\\Users\\guenther.siegert\\Documents\\Access Bridge\\start_api_hidden.vbs
                        </code>
                    </div>
                    <button onclick="location.reload()" style="
                        background: #0066cc;
                        color: white;
                        border: none;
                        padding: 10px 30px;
                        border-radius: 4px;
                        cursor: pointer;
                        font-size: 14px;
                    ">
                        Erneut versuchen
                    </button>
                    <button onclick="this.closest('#api-error-overlay').remove()" style="
                        background: #666;
                        color: white;
                        border: none;
                        padding: 10px 30px;
                        border-radius: 4px;
                        cursor: pointer;
                        font-size: 14px;
                        margin-left: 10px;
                    ">
                        Trotzdem fortfahren
                    </button>
                </div>
            </div>
        `;
        document.body.appendChild(overlay);
    }

    /**
     * Zeigt Anweisungen zum manuellen Start
     */
    function showStartInstructions() {
        console.log('='.repeat(60));
        console.log('API-Server manuell starten:');
        console.log('  Doppelklick auf: start_api_hidden.vbs');
        console.log('  Pfad: C:\\Users\\guenther.siegert\\Documents\\Access Bridge\\');
        console.log('='.repeat(60));
    }

    /**
     * Startet periodische Server-Pruefung
     */
    function startHealthCheck() {
        if (_checkInterval) clearInterval(_checkInterval);

        _checkInterval = setInterval(async () => {
            const running = await isServerRunning();

            if (!running && _isRunning) {
                console.warn('[API-Lifecycle] Server-Verbindung verloren!');
                _isRunning = false;
                _retryCount++;

                if (_retryCount <= MAX_RETRIES) {
                    console.log('[API-Lifecycle] Versuche Reconnect... (' + _retryCount + '/' + MAX_RETRIES + ')');
                    await checkAndStartServer();
                } else {
                    showServerError();
                }
            } else if (running && !_isRunning) {
                console.log('[API-Lifecycle] Server wieder verfuegbar');
                _isRunning = true;
                _retryCount = 0;

                // Entferne Fehler-Overlay falls vorhanden
                const overlay = document.getElementById('api-error-overlay');
                if (overlay) overlay.remove();
            }
        }, CHECK_INTERVAL);
    }

    /**
     * Handler fuer Fenster schliessen
     */
    function handleUnload(event) {
        // Stoppe Health-Check
        if (_checkInterval) {
            clearInterval(_checkInterval);
            _checkInterval = null;
        }

        // Melde Formular ab
        unregisterForm();

        // Pruefe ob letztes Formular
        const openForms = getOpenForms();
        const count = Object.keys(openForms).length;

        if (count === 0) {
            console.log('[API-Lifecycle] Letztes Formular geschlossen');

            // Sende Stop-Signal an VBA
            if (window.chrome && window.chrome.webview) {
                window.chrome.webview.postMessage(JSON.stringify({
                    type: 'ALL_FORMS_CLOSED',
                    stopServer: true
                }));
            }
        }
    }

    /**
     * Hilfsfunktion: Sleep
     */
    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Oeffentliche API
     */
    window.APILifecycle = {
        /**
         * Prueft ob Server laeuft
         */
        isRunning: function() {
            return _isRunning;
        },

        /**
         * Erzwingt Server-Neustart
         */
        restart: async function() {
            if (window.chrome && window.chrome.webview) {
                window.chrome.webview.postMessage(JSON.stringify({
                    type: 'RESTART_API_SERVER'
                }));
            }
            await sleep(2000);
            return await checkAndStartServer();
        },

        /**
         * Gibt Status-Info zurueck
         */
        getStatus: function() {
            return {
                formId: _formId,
                isRunning: _isRunning,
                openForms: getOpenForms(),
                retryCount: _retryCount
            };
        },

        /**
         * Manueller Health-Check
         */
        checkNow: async function() {
            return await isServerRunning();
        }
    };

    // Automatische Initialisierung wenn DOM bereit
    // ABER: Nicht initialisieren wenn WebView2 erkannt wurde (Bridge uebernimmt)
    function shouldInit() {
        // Skip wenn WebView2 vorhanden
        if (window.chrome && window.chrome.webview) {
            console.log('[API-Lifecycle] WebView2 erkannt - ueberspringe API-Server-Check');
            return false;
        }
        // Skip wenn Bridge das Flag gesetzt hat
        if (window._skipApiLifecycle) {
            console.log('[API-Lifecycle] Skip-Flag gesetzt - ueberspringe API-Server-Check');
            return false;
        }
        return true;
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            if (shouldInit()) init();
        });
    } else {
        if (shouldInit()) init();
    }

})();
