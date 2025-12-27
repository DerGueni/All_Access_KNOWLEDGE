/**
 * e2e-visibility.js
 * Handshake-System zur Überprüfung der Sichtbarkeit von HTML-Elementen
 * Verwendet Polling um zu prüfen, ob Elemente sichtbar sind
 */

class E2EVisibility {
    constructor(anchors = [], pollInterval = 50, maxWait = 3000) {
        this.anchors = anchors; // z.B. ['#mainForm', '.form-header']
        this.pollInterval = pollInterval; // ms
        this.maxWait = maxWait; // ms
        this.isVisible = false;
        this.reason = '';
    }

    /**
     * Überprüfe ob ein Element sichtbar ist
     */
    isElementVisible(selector) {
        try {
            const elem = document.querySelector(selector);
            if (!elem) return { visible: false, reason: `Element nicht gefunden: ${selector}` };

            const style = window.getComputedStyle(elem);
            const rect = elem.getBoundingClientRect();

            // Prüfe verschiedene Sichtbarkeitskriterien
            if (style.display === 'none') {
                return { visible: false, reason: `display:none auf ${selector}` };
            }

            if (style.visibility === 'hidden') {
                return { visible: false, reason: `visibility:hidden auf ${selector}` };
            }

            if (parseFloat(style.opacity) === 0) {
                return { visible: false, reason: `opacity:0 auf ${selector}` };
            }

            if (rect.width === 0 || rect.height === 0) {
                return { visible: false, reason: `Breite/Höhe=0 auf ${selector}` };
            }

            return { visible: true, reason: 'OK', rect };
        } catch (err) {
            return { visible: false, reason: `Fehler: ${err.message}` };
        }
    }

    /**
     * Polling-Schleife: Warte bis alle Anker sichtbar sind
     */
    async waitForVisibility() {
        const startTime = Date.now();
        const results = {};

        while (Date.now() - startTime < this.maxWait) {
            let allVisible = true;

            for (const anchor of this.anchors) {
                const result = this.isElementVisible(anchor);
                results[anchor] = result;

                if (!result.visible) {
                    allVisible = false;
                }
            }

            if (allVisible) {
                this.isVisible = true;
                this.reason = 'Alle Anker sichtbar';
                return {
                    ok: true,
                    ms: Date.now() - startTime,
                    anchors: results,
                    reason: this.reason
                };
            }

            // Warte und versuche es erneut
            await new Promise(resolve => setTimeout(resolve, this.pollInterval));
        }

        // Timeout
        this.isVisible = false;
        this.reason = `Timeout nach ${this.maxWait}ms`;
        return {
            ok: false,
            ms: Date.now() - startTime,
            anchors: results,
            reason: this.reason,
            timeout: true
        };
    }

    /**
     * Sende Visibility-Report an Backend
     */
    async reportToBackend(runId) {
        const report = {
            ts: new Date().toISOString(),
            run_id: runId,
            action: 'VISIBILITY_CHECK',
            form: document.title || 'unknown',
            visible: this.isVisible,
            reason: this.reason
        };

        try {
            const response = await fetch('/e2e/visible', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(report)
            });

            if (response.ok) {
                console.log('[E2E] Visibility-Report gesendet:', report);
            }
        } catch (err) {
            console.warn('[E2E] Fehler beim Visibility-Report:', err);
        }
    }
}

// Export
window.E2EVisibility = E2EVisibility;
