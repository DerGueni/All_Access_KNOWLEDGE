/**
 * e2e-logger.js
 * Zentrales E2E-Logging-System für alle Tests
 * Loggt in JSON Lines Format an Backend
 */

class E2ELogger {
    constructor() {
        this.run_id = this.generateRunId();
        this.logs = [];
        this.api_endpoint = '/e2e/log'; // Backend-Endpoint für Logs
    }

    /**
     * Generiere eindeutige Run-ID (YYYYMMDDHHmmssSSS + Random)
     */
    generateRunId() {
        const now = new Date();
        const ts = now.toISOString().replace(/[:-]/g, '').replace('T', '').slice(0, 14);
        const rand = Math.random().toString(36).substring(2, 8).toUpperCase();
        return `RUN_${ts}_${rand}`;
    }

    /**
     * Log einen Event
     * @param {string} action - Aktion (z.B. BUTTON_CLICK, NAVIGATE_REQUEST)
     * @param {object} details - Beliebige Details
     */
    log(action, details = {}) {
        const entry = {
            ts: new Date().toISOString(),
            run_id: this.run_id,
            action,
            ...details
        };

        console.log(`[E2E] ${action}`, entry);
        this.logs.push(entry);

        // Async: Sende an Backend
        this.sendToBackend(entry).catch(err => {
            console.error('[E2E] Fehler beim Log-Senden:', err);
        });
    }

    /**
     * Sende Log an Backend
     */
    async sendToBackend(entry) {
        try {
            const response = await fetch(this.api_endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(entry)
            });

            if (!response.ok) {
                console.warn(`[E2E] Log-Endpoint returned ${response.status}`);
            }
        } catch (err) {
            // Silent fail - Backend nicht verfügbar
        }
    }

    /**
     * Exportiere alle Logs als JSON Lines
     */
    exportJsonLines() {
        return this.logs.map(log => JSON.stringify(log)).join('\n');
    }

    /**
     * Gib Run-ID zurück
     */
    getRunId() {
        return this.run_id;
    }
}

// Global Logger-Instanz
window.e2eLogger = new E2ELogger();
