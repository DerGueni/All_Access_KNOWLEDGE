/**
 * Event-Daten Web-Scraper Client
 * Lädt automatisch Event-Informationen basierend auf Auftragsdaten
 */

class EventDatenLoader {
    constructor() {
        this.cache = new Map();
        this.loadingStates = new Set();
    }

    /**
     * Lädt Event-Daten für einen Auftrag
     * @param {number} va_id - Auftrags-ID
     * @returns {Promise<Object>} Event-Daten
     */
    async ladeEventDaten(va_id) {
        if (!va_id) {
            console.warn('Keine VA_ID übergeben');
            return this.getFallbackData();
        }

        // Cache-Check
        if (this.cache.has(va_id)) {
            console.log(`Event-Daten aus Cache geladen für VA_ID ${va_id}`);
            return this.cache.get(va_id);
        }

        // Verhindere doppelte Requests
        if (this.loadingStates.has(va_id)) {
            console.log(`Event-Daten werden bereits geladen für VA_ID ${va_id}`);
            return new Promise(resolve => {
                const checkInterval = setInterval(() => {
                    if (this.cache.has(va_id)) {
                        clearInterval(checkInterval);
                        resolve(this.cache.get(va_id));
                    }
                }, 100);
            });
        }

        this.loadingStates.add(va_id);

        try {
            console.log(`Lade Event-Daten für VA_ID ${va_id}...`);

            if (window.Bridge) {
                // Use Bridge to load event data
                const data = await new Promise((resolve, reject) => {
                    const handler = (eventData) => {
                        if (eventData.va_id === va_id) {
                            Bridge.off('onEventDataReceived', handler);
                            resolve(eventData);
                        }
                    };

                    Bridge.on('onEventDataReceived', handler);
                    Bridge.loadData('eventdaten', { va_id: va_id });

                    // Timeout after 10 seconds
                    setTimeout(() => {
                        Bridge.off('onEventDataReceived', handler);
                        reject(new Error('Timeout'));
                    }, 10000);
                });

                // Cache speichern
                this.cache.set(va_id, data);
                console.log('Event-Daten erfolgreich geladen:', data);
                return data;
            } else {
                throw new Error('Bridge nicht verfügbar');
            }

        } catch (error) {
            console.error('Fehler beim Laden der Event-Daten:', error);
            return this.getFallbackData(error.message);
        } finally {
            this.loadingStates.delete(va_id);
        }
    }

    /**
     * Fallback-Daten wenn keine Informationen gefunden wurden
     */
    getFallbackData(errorMsg = null) {
        return {
            einlass: 'Keine Infos verfügbar',
            beginn: 'Keine Infos verfügbar',
            ende: 'Keine Infos verfügbar',
            infos: errorMsg || 'Keine Infos verfügbar',
            weblink: '',
            suchbegriffe: '',
            timestamp: new Date().toISOString()
        };
    }

    /**
     * Füllt Formularfelder mit Event-Daten
     * @param {Object} data - Event-Daten vom Server
     * @param {Object} fieldMap - Mapping von Datenfeldern zu HTML-Element-IDs
     */
    fuelleFormular(data, fieldMap = null) {
        const defaultMap = {
            einlass: 'txt_einlass',
            beginn: 'txt_beginn',
            ende: 'txt_ende',
            infos: 'txt_event_infos',
            weblink: 'txt_weblink'
        };

        const map = fieldMap || defaultMap;

        Object.keys(map).forEach(key => {
            const elementId = map[key];
            const element = document.getElementById(elementId);

            if (element) {
                const value = data[key] || '';

                if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                    element.value = value;
                } else {
                    element.textContent = value;
                }

                // Weblink als anklickbarer Link
                if (key === 'weblink' && value && element.tagName === 'A') {
                    element.href = value;
                    element.target = '_blank';
                }
            }
        });
    }

    /**
     * Automatisches Laden bei Formular-Initialisierung
     * @param {number} va_id - Auftrags-ID
     * @param {Object} fieldMap - Optional: Custom Field Mapping
     */
    async autoLoad(va_id, fieldMap = null) {
        const data = await this.ladeEventDaten(va_id);
        this.fuelleFormular(data, fieldMap);
        return data;
    }

    /**
     * Cache leeren
     */
    clearCache() {
        this.cache.clear();
        console.log('Event-Daten Cache geleert');
    }

    /**
     * Manueller Reload (bypass Cache)
     */
    async reload(va_id, fieldMap = null) {
        this.cache.delete(va_id);
        return await this.autoLoad(va_id, fieldMap);
    }
}

// Globale Instanz
const eventDatenLoader = new EventDatenLoader();

// Export für Module
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { EventDatenLoader, eventDatenLoader };
}

/**
 * VERWENDUNG IM FORMULAR:
 *
 * // 1. Basic Usage (automatisch laden)
 * const va_id = 12345;
 * await eventDatenLoader.autoLoad(va_id);
 *
 * // 2. Custom Field Mapping
 * const customMap = {
 *     einlass: 'custom_einlass_field',
 *     beginn: 'custom_beginn_field'
 * };
 * await eventDatenLoader.autoLoad(va_id, customMap);
 *
 * // 3. Nur Daten laden (ohne Formular zu füllen)
 * const data = await eventDatenLoader.ladeEventDaten(va_id);
 * console.log(data);
 *
 * // 4. Reload (Cache umgehen)
 * await eventDatenLoader.reload(va_id);
 *
 * // 5. Cache leeren
 * eventDatenLoader.clearCache();
 */
