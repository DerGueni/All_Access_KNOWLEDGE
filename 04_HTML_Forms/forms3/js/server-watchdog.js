/**
 * Server Watchdog - Prüft automatisch ob API Server läuft
 *
 * VERWENDUNG:
 * <script src="../js/server-watchdog.js"></script>
 *
 * Prüft beim Laden ob API Server (Port 5000) erreichbar ist.
 * Falls nicht: Zeigt Fehler-Toast mit Anleitung zum Starten.
 */

(function() {
    'use strict';

    const API_BASE_URL = 'http://localhost:5000';
    const VBA_BRIDGE_URL = 'http://localhost:5002';
    const CHECK_TIMEOUT = 5000; // 5 Sekunden Timeout

    /**
     * Prüft ob ein Server erreichbar ist
     */
    async function checkServer(url, name) {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), CHECK_TIMEOUT);

            const response = await fetch(url + '/api/health', {
                method: 'GET',
                signal: controller.signal,
                cache: 'no-cache'
            });

            clearTimeout(timeoutId);

            if (response.ok) {
                console.log(`✅ [Watchdog] ${name} läuft (${url})`);
                return true;
            } else {
                console.warn(`⚠️ [Watchdog] ${name} antwortet mit Status ${response.status}`);
                return false;
            }
        } catch (err) {
            if (err.name === 'AbortError') {
                console.error(`❌ [Watchdog] ${name} Timeout (${CHECK_TIMEOUT}ms)`);
            } else {
                console.error(`❌ [Watchdog] ${name} nicht erreichbar:`, err.message);
            }
            return false;
        }
    }

    /**
     * Zeigt Fehler-Toast mit Anleitung
     */
    function showServerError(serverName, serverUrl, port) {
        // Toast-Message (falls showToast-Funktion existiert)
        if (typeof window.showToast === 'function') {
            window.showToast(
                `${serverName} nicht erreichbar (Port ${port})`,
                'error',
                10000
            );
        }

        // Konsolen-Warnung mit Anleitung
        console.group(`❌ ${serverName} nicht erreichbar`);
        console.error(`Server: ${serverUrl}`);
        console.error(`Port: ${port}`);
        console.log('');
        console.log('LÖSUNG:');
        console.log('1. Access-Frontend öffnen (0_Consys_FE_Test.accdb)');
        console.log('   → Server starten automatisch beim Access-Start');
        console.log('');
        console.log('ODER manuell starten:');
        if (port === 5000) {
            console.log('   Doppelklick: C:\\Users\\guenther.siegert\\Documents\\Access Bridge\\start_api_silent.vbs');
        } else if (port === 5002) {
            console.log('   Doppelklick: C:\\Users\\guenther.siegert\\Documents\\0006_All_Access_KNOWLEDGE\\04_HTML_Forms\\api\\start_vba_bridge_silent.vbs');
        }
        console.groupEnd();

        // Overlay mit Fehler-Message (optional)
        showServerErrorOverlay(serverName, port);
    }

    /**
     * Zeigt Overlay mit Fehler-Message und Retry-Button
     */
    function showServerErrorOverlay(serverName, port) {
        // Prüfen ob bereits angezeigt
        if (document.getElementById('serverErrorOverlay')) return;

        const overlay = document.createElement('div');
        overlay.id = 'serverErrorOverlay';
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 999999;
            display: flex;
            align-items: center;
            justify-content: center;
        `;

        const box = document.createElement('div');
        box.style.cssText = `
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            max-width: 500px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        `;

        box.innerHTML = `
            <h2 style="color: #c00; margin: 0 0 20px 0; font-size: 20px;">
                ⚠️ ${serverName} nicht erreichbar
            </h2>
            <p style="margin: 0 0 10px 0; line-height: 1.6; font-size: 13px;">
                Der <strong>${serverName}</strong> (Port ${port}) ist nicht erreichbar.
                Das Formular kann keine Daten laden.
            </p>
            <p style="margin: 0 0 20px 0; line-height: 1.6; font-size: 13px;">
                <strong>Lösung:</strong><br>
                Öffnen Sie das <strong>Access-Frontend</strong> (0_Consys_FE_Test.accdb).<br>
                Die Server starten automatisch beim Access-Start.
            </p>
            <button id="retryServerBtn" style="
                background: #4CAF50;
                color: white;
                border: none;
                padding: 10px 20px;
                font-size: 13px;
                border-radius: 4px;
                cursor: pointer;
                margin-right: 10px;
            ">
                🔄 Erneut versuchen
            </button>
            <button id="closeServerOverlay" style="
                background: #999;
                color: white;
                border: none;
                padding: 10px 20px;
                font-size: 13px;
                border-radius: 4px;
                cursor: pointer;
            ">
                Schließen
            </button>
        `;

        overlay.appendChild(box);
        document.body.appendChild(overlay);

        // Retry-Button
        document.getElementById('retryServerBtn').addEventListener('click', () => {
            overlay.remove();
            window.location.reload();
        });

        // Close-Button
        document.getElementById('closeServerOverlay').addEventListener('click', () => {
            overlay.remove();
        });
    }

    /**
     * Versucht die VBA Bridge automatisch zu starten via API Server
     * @returns {Promise<boolean>} true wenn VBA Bridge läuft oder erfolgreich gestartet
     */
    async function ensureVBABridgeRunning() {
        // Erst prüfen ob bereits läuft
        try {
            const response = await fetch(VBA_BRIDGE_URL + '/api/health', {
                method: 'GET',
                signal: AbortSignal.timeout(2000),
                cache: 'no-cache'
            });

            if (response.ok) {
                console.log('✅ [Watchdog] VBA Bridge läuft bereits');
                return true;
            }
        } catch (e) {
            console.log('[Watchdog] VBA Bridge nicht erreichbar, versuche Auto-Start...');
        }

        // Versuche VBA Bridge über API Server zu starten
        try {
            console.log('[Watchdog] Sende Start-Anfrage an API Server...');
            const startResponse = await fetch(API_BASE_URL + '/api/start-vba-bridge', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                signal: AbortSignal.timeout(5000)
            });

            if (startResponse.ok) {
                const result = await startResponse.json();
                console.log('[Watchdog] Start-Anfrage Ergebnis:', result);

                if (result.status === 'already_running') {
                    console.log('✅ [Watchdog] VBA Bridge läuft bereits (bestätigt vom API Server)');
                    return true;
                }

                if (result.status === 'started') {
                    console.log('[Watchdog] VBA Bridge wird gestartet, warte 3 Sekunden...');

                    // Warten und erneut prüfen
                    await new Promise(resolve => setTimeout(resolve, 3000));

                    try {
                        const verifyResponse = await fetch(VBA_BRIDGE_URL + '/api/health', {
                            method: 'GET',
                            signal: AbortSignal.timeout(2000),
                            cache: 'no-cache'
                        });

                        if (verifyResponse.ok) {
                            console.log('✅ [Watchdog] VBA Bridge erfolgreich gestartet');
                            return true;
                        }
                    } catch (e) {
                        console.warn('[Watchdog] VBA Bridge Verifizierung fehlgeschlagen');
                    }
                }
            }
        } catch (e) {
            console.warn('[Watchdog] Auto-Start fehlgeschlagen:', e.message);
        }

        // Fallback: VBA Bridge konnte nicht gestartet werden
        console.warn('⚠️ [Watchdog] VBA Bridge konnte nicht automatisch gestartet werden');
        console.warn('⚠️ [Watchdog] E-Mail-Funktionen sind eingeschränkt');
        console.warn('[Watchdog] Tipp: Access-Frontend öffnen oder start_vba_bridge.bat ausführen');
        return false;
    }

    /**
     * Hauptprüfung beim Laden
     */
    async function checkServers() {
        console.log('[Watchdog] Prüfe Server-Verfügbarkeit...');

        // API Server prüfen (Port 5000)
        const apiRunning = await checkServer(API_BASE_URL, 'API Server');
        if (!apiRunning) {
            showServerError('API Server', API_BASE_URL, 5000);
            return false;
        }

        // VBA Bridge prüfen und ggf. automatisch starten
        const vbaRunning = await ensureVBABridgeRunning();
        if (!vbaRunning) {
            // Nur Console-Warnung, kein Toast - VBA Bridge ist optional für meiste Funktionen
            console.warn('⚠️ [Watchdog] VBA Bridge nicht erreichbar - E-Mail-Funktionen evtl. eingeschränkt');
        }

        console.log('[Watchdog] Server-Check abgeschlossen');
        return apiRunning;
    }

    // Auto-Check beim Laden (nach 3000ms Verzögerung - Server braucht Zeit zum Starten)
    // Beim Öffnen via Access müssen API Server und VBA Bridge erst hochfahren
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            setTimeout(checkServers, 3000);
        });
    } else {
        setTimeout(checkServers, 3000);
    }

    // Global verfügbar machen
    window.ServerWatchdog = {
        check: checkServers,
        checkAPI: () => checkServer(API_BASE_URL, 'API Server'),
        checkVBA: () => checkServer(VBA_BRIDGE_URL, 'VBA Bridge'),
        ensureVBABridge: ensureVBABridgeRunning,
        startVBABridge: async () => {
            // Direkter Start-Aufruf ohne vorherige Prüfung
            try {
                const response = await fetch(API_BASE_URL + '/api/start-vba-bridge', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    signal: AbortSignal.timeout(5000)
                });
                return response.ok ? await response.json() : { status: 'error' };
            } catch (e) {
                return { status: 'error', error: e.message };
            }
        }
    };

})();
