/**
 * api-autostart.js
 * Automatischer Start des API-Servers beim Laden des ersten HTML-Formulars
 *
 * Funktionsweise:
 * 1. Prüft ob API-Server erreichbar ist (localhost:5000)
 * 2. Falls nicht: Startet api_server.py via verstecktem Batch
 * 3. Wartet bis Server bereit ist
 * 4. Zeigt Status-Indikator an
 */

const API_CHECK_URL = 'http://localhost:5000/api/tables';
const API_SERVER_PATH = 'C:\\Users\\guenther.siegert\\Documents\\0006_All_Access_KNOWLEDGE\\08_Tools\\python\\api_server.py';
const START_SCRIPT_PATH = 'C:\\Users\\guenther.siegert\\Documents\\0006_All_Access_KNOWLEDGE\\04_HTML_Forms\\start_api_server.bat';

// Status-Element ID
const STATUS_ID = 'api-status-indicator';

// Maximale Wartezeit in ms
const MAX_WAIT_TIME = 30000;
const CHECK_INTERVAL = 500;

/**
 * Prüft ob der API-Server erreichbar ist
 */
async function checkApiServer() {
    try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 2000);

        const response = await fetch(API_CHECK_URL, {
            signal: controller.signal,
            mode: 'cors'
        });

        clearTimeout(timeoutId);
        return response.ok;
    } catch (e) {
        return false;
    }
}

/**
 * Zeigt Status-Indikator an
 */
function showStatus(message, type = 'info') {
    let statusEl = document.getElementById(STATUS_ID);

    if (!statusEl) {
        statusEl = document.createElement('div');
        statusEl.id = STATUS_ID;
        statusEl.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 8px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            z-index: 10000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transition: all 0.3s ease;
        `;
        document.body.appendChild(statusEl);
    }

    const colors = {
        info: { bg: '#3498db', color: '#fff' },
        success: { bg: '#27ae60', color: '#fff' },
        error: { bg: '#e74c3c', color: '#fff' },
        warning: { bg: '#f39c12', color: '#fff' }
    };

    const style = colors[type] || colors.info;
    statusEl.style.backgroundColor = style.bg;
    statusEl.style.color = style.color;
    statusEl.textContent = message;
    statusEl.style.display = 'block';
}

/**
 * Versteckt Status-Indikator
 */
function hideStatus() {
    const statusEl = document.getElementById(STATUS_ID);
    if (statusEl) {
        statusEl.style.opacity = '0';
        setTimeout(() => {
            statusEl.style.display = 'none';
            statusEl.style.opacity = '1';
        }, 300);
    }
}

/**
 * Startet den API-Server via Electron/Node oder Browser-Feature
 * Hinweis: Im Browser kann kein direkter Prozess gestartet werden.
 * Daher zeigen wir eine Anleitung oder nutzen einen Workaround.
 */
async function startApiServer() {
    // Prüfen ob wir in einer Electron-Umgebung sind
    if (typeof require !== 'undefined') {
        try {
            const { exec } = require('child_process');
            exec(`start /min "" python "${API_SERVER_PATH}"`, (error) => {
                if (error) {
                    console.error('[API-Autostart] Fehler beim Starten:', error);
                }
            });
            return true;
        } catch (e) {
            console.error('[API-Autostart] Electron exec fehlgeschlagen:', e);
        }
    }

    // Fallback: Zeige Anleitung
    showStatus('API-Server nicht erreichbar. Bitte start_api_server.bat ausführen.', 'warning');
    return false;
}

/**
 * Wartet bis der API-Server bereit ist
 */
async function waitForServer() {
    const startTime = Date.now();

    while (Date.now() - startTime < MAX_WAIT_TIME) {
        if (await checkApiServer()) {
            return true;
        }
        await new Promise(resolve => setTimeout(resolve, CHECK_INTERVAL));
    }

    return false;
}

/**
 * Hauptfunktion: Initialisiert API-Verbindung
 */
async function initApiConnection() {
    console.log('[API-Autostart] Prüfe API-Server...');

    // Erste Prüfung
    if (await checkApiServer()) {
        console.log('[API-Autostart] API-Server bereits aktiv');
        showStatus('API-Server verbunden', 'success');
        setTimeout(hideStatus, 2000);
        return true;
    }

    // Server nicht erreichbar - versuche zu starten
    showStatus('Starte API-Server...', 'info');
    console.log('[API-Autostart] Server nicht erreichbar, versuche Start...');

    const started = await startApiServer();

    if (started) {
        // Warte auf Server
        showStatus('Warte auf API-Server...', 'info');

        if (await waitForServer()) {
            console.log('[API-Autostart] API-Server erfolgreich gestartet');
            showStatus('API-Server bereit', 'success');
            setTimeout(hideStatus, 2000);
            return true;
        } else {
            console.error('[API-Autostart] Timeout beim Warten auf Server');
            showStatus('API-Server Timeout - bitte manuell starten', 'error');
            return false;
        }
    }

    return false;
}

/**
 * Event-basierte Initialisierung
 * Wird automatisch beim Laden der Seite ausgeführt
 */
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initApiConnection);
} else {
    // DOM bereits geladen
    initApiConnection();
}

// Export für manuelle Nutzung
window.ApiAutostart = {
    check: checkApiServer,
    init: initApiConnection,
    showStatus,
    hideStatus
};
