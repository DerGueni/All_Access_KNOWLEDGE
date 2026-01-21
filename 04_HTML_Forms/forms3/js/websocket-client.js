/**
 * WebSocket Client fuer Echtzeit-Updates
 * Verbindet sich mit dem WebSocket-Server fuer Live-Daten
 *
 * Verwendung:
 *   // Verbinden
 *   WSClient.connect();
 *
 *   // Events abonnieren
 *   WSClient.subscribe('auftrag:updated', (data) => {
 *       console.log('Auftrag aktualisiert:', data);
 *       reloadAuftragData();
 *   });
 *
 *   // Event senden
 *   WSClient.send('auftrag:save', { va_id: 123, data: {...} });
 */

'use strict';

const WSClient = (function() {
    let socket = null;
    let reconnectAttempts = 0;
    let reconnectTimeout = null;
    let heartbeatInterval = null;
    let isConnecting = false;

    const config = {
        url: 'ws://localhost:5001',
        reconnectDelay: 2000,
        maxReconnectDelay: 30000,
        maxReconnectAttempts: 10,
        heartbeatInterval: 30000,
        debug: true
    };

    const subscribers = new Map();
    const pendingMessages = [];

    /**
     * Debug-Logging
     */
    function log(...args) {
        if (config.debug) {
            console.log('[WSClient]', ...args);
        }
    }

    /**
     * Verbindung herstellen
     */
    function connect(url) {
        if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
            log('Bereits verbunden oder verbinde...');
            return Promise.resolve(socket);
        }

        if (isConnecting) {
            return new Promise((resolve) => {
                const checkInterval = setInterval(() => {
                    if (socket && socket.readyState === WebSocket.OPEN) {
                        clearInterval(checkInterval);
                        resolve(socket);
                    }
                }, 100);
            });
        }

        isConnecting = true;
        const wsUrl = url || config.url;

        return new Promise((resolve, reject) => {
            try {
                log('Verbinde zu', wsUrl);
                socket = new WebSocket(wsUrl);

                socket.onopen = () => {
                    isConnecting = false;
                    reconnectAttempts = 0;
                    log('Verbunden');

                    // Heartbeat starten
                    startHeartbeat();

                    // Pending Messages senden
                    while (pendingMessages.length > 0) {
                        const msg = pendingMessages.shift();
                        sendRaw(msg);
                    }

                    // Connected Event
                    emit('connected', { timestamp: Date.now() });

                    resolve(socket);
                };

                socket.onclose = (event) => {
                    isConnecting = false;
                    log('Verbindung geschlossen:', event.code, event.reason);
                    stopHeartbeat();

                    emit('disconnected', { code: event.code, reason: event.reason });

                    // Automatisch reconnecten (ausser bei normalem Close)
                    if (event.code !== 1000 && event.code !== 1001) {
                        scheduleReconnect();
                    }
                };

                socket.onerror = (error) => {
                    isConnecting = false;
                    log('Fehler:', error);
                    emit('error', { error });
                };

                socket.onmessage = (event) => {
                    handleMessage(event.data);
                };

            } catch (error) {
                isConnecting = false;
                log('Verbindungsfehler:', error);
                reject(error);
            }
        });
    }

    /**
     * Verbindung trennen
     */
    function disconnect() {
        if (reconnectTimeout) {
            clearTimeout(reconnectTimeout);
            reconnectTimeout = null;
        }
        stopHeartbeat();

        if (socket) {
            socket.close(1000, 'Client disconnect');
            socket = null;
        }
        log('Getrennt');
    }

    /**
     * Reconnect planen
     */
    function scheduleReconnect() {
        if (reconnectAttempts >= config.maxReconnectAttempts) {
            log('Max Reconnect-Versuche erreicht');
            emit('reconnect_failed', { attempts: reconnectAttempts });
            return;
        }

        const delay = Math.min(
            config.reconnectDelay * Math.pow(1.5, reconnectAttempts),
            config.maxReconnectDelay
        );

        log(`Reconnect in ${delay}ms (Versuch ${reconnectAttempts + 1})`);

        reconnectTimeout = setTimeout(() => {
            reconnectAttempts++;
            connect().catch(() => {
                // Fehler wird im onerror behandelt
            });
        }, delay);
    }

    /**
     * Heartbeat starten
     */
    function startHeartbeat() {
        stopHeartbeat();
        heartbeatInterval = setInterval(() => {
            if (socket && socket.readyState === WebSocket.OPEN) {
                sendRaw(JSON.stringify({ type: 'ping', timestamp: Date.now() }));
            }
        }, config.heartbeatInterval);
    }

    /**
     * Heartbeat stoppen
     */
    function stopHeartbeat() {
        if (heartbeatInterval) {
            clearInterval(heartbeatInterval);
            heartbeatInterval = null;
        }
    }

    /**
     * Nachricht empfangen
     */
    function handleMessage(data) {
        try {
            const message = JSON.parse(data);

            // Pong ignorieren
            if (message.type === 'pong') {
                return;
            }

            log('Empfangen:', message.type, message);

            // Event an Subscriber weiterleiten
            emit(message.type, message.data || message);

            // Wildcard-Subscriber
            emit('*', message);

        } catch (error) {
            log('Parse-Fehler:', error, data);
        }
    }

    /**
     * Event an Subscriber senden
     */
    function emit(eventType, data) {
        const callbacks = subscribers.get(eventType);
        if (callbacks) {
            callbacks.forEach(callback => {
                try {
                    callback(data);
                } catch (error) {
                    console.error('[WSClient] Subscriber-Fehler:', error);
                }
            });
        }
    }

    /**
     * Raw-Nachricht senden
     */
    function sendRaw(data) {
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.send(data);
            return true;
        }
        return false;
    }

    /**
     * Nachricht senden
     */
    function send(type, data = {}) {
        const message = JSON.stringify({
            type: type,
            data: data,
            timestamp: Date.now()
        });

        if (socket && socket.readyState === WebSocket.OPEN) {
            sendRaw(message);
            log('Gesendet:', type, data);
        } else {
            // In Queue speichern fuer spaeter
            pendingMessages.push(message);
            log('In Queue:', type);

            // Verbindung herstellen falls nicht verbunden
            if (!socket || socket.readyState === WebSocket.CLOSED) {
                connect();
            }
        }
    }

    /**
     * Event abonnieren
     */
    function subscribe(eventType, callback) {
        if (!subscribers.has(eventType)) {
            subscribers.set(eventType, new Set());
        }
        subscribers.get(eventType).add(callback);

        log('Abonniert:', eventType);

        // Unsubscribe-Funktion zurueckgeben
        return () => {
            const callbacks = subscribers.get(eventType);
            if (callbacks) {
                callbacks.delete(callback);
            }
        };
    }

    /**
     * Einmaliges Event abonnieren
     */
    function once(eventType, callback) {
        const unsubscribe = subscribe(eventType, (data) => {
            unsubscribe();
            callback(data);
        });
        return unsubscribe;
    }

    /**
     * Alle Subscriptions fuer einen Event-Typ entfernen
     */
    function unsubscribeAll(eventType) {
        if (eventType) {
            subscribers.delete(eventType);
        } else {
            subscribers.clear();
        }
    }

    // Public API
    return {
        connect,
        disconnect,
        send,
        subscribe,
        once,
        unsubscribeAll,

        /**
         * Verbindungsstatus
         */
        get isConnected() {
            return socket && socket.readyState === WebSocket.OPEN;
        },

        /**
         * Konfiguration anpassen
         */
        configure(options) {
            Object.assign(config, options);
        },

        /**
         * Raum beitreten (fuer Multi-User)
         */
        joinRoom(room) {
            send('join', { room });
        },

        /**
         * Raum verlassen
         */
        leaveRoom(room) {
            send('leave', { room });
        }
    };
})();

// Global verfuegbar
window.WSClient = WSClient;

// =====================================================
// CONSYS-SPEZIFISCHE EVENT-HANDLER
// =====================================================

/**
 * Live-Update Handler fuer CONSYS
 * Registriert Standard-Events fuer Echtzeit-Aktualisierungen
 */
const LiveUpdates = (function() {
    let initialized = false;

    /**
     * Initialisieren
     */
    function init() {
        if (initialized) return;

        // Auftrag-Updates
        WSClient.subscribe('auftrag:updated', (data) => {
            console.log('[LiveUpdates] Auftrag aktualisiert:', data.va_id);
            if (window.reloadAuftragData) {
                window.reloadAuftragData(data.va_id);
            }
            showUpdateNotification('Auftrag aktualisiert', data);
        });

        // Zuordnung-Updates
        WSClient.subscribe('zuordnung:created', (data) => {
            console.log('[LiveUpdates] Neue Zuordnung:', data);
            if (window.reloadZuordnungen) {
                window.reloadZuordnungen();
            }
            showUpdateNotification('MA zugeordnet', data);
        });

        WSClient.subscribe('zuordnung:deleted', (data) => {
            console.log('[LiveUpdates] Zuordnung geloescht:', data);
            if (window.reloadZuordnungen) {
                window.reloadZuordnungen();
            }
        });

        // Anfrage-Updates
        WSClient.subscribe('anfrage:sent', (data) => {
            console.log('[LiveUpdates] Anfrage gesendet:', data);
            if (window.reloadAnfragen) {
                window.reloadAnfragen();
            }
        });

        WSClient.subscribe('anfrage:response', (data) => {
            console.log('[LiveUpdates] Anfrage-Antwort:', data);
            if (window.reloadAnfragen) {
                window.reloadAnfragen();
            }
            showUpdateNotification('Neue Antwort eingegangen', data);
        });

        // Verbindungsstatus
        WSClient.subscribe('connected', () => {
            if (window.Toast) {
                Toast.success('Live-Updates aktiviert', { duration: 2000 });
            }
        });

        WSClient.subscribe('disconnected', () => {
            if (window.Toast) {
                Toast.warning('Live-Updates unterbrochen', { duration: 3000 });
            }
        });

        initialized = true;
        console.log('[LiveUpdates] Initialisiert');
    }

    /**
     * Update-Benachrichtigung anzeigen
     */
    function showUpdateNotification(message, data) {
        if (window.Toast) {
            Toast.info(message, { duration: 3000 });
        }

        // Optional: Browser-Notification
        if (Notification.permission === 'granted' && document.hidden) {
            new Notification('CONSYS', {
                body: message,
                icon: '/img/icon-192.png'
            });
        }
    }

    /**
     * Browser-Notifications anfordern
     */
    function requestNotificationPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }

    return {
        init,
        requestNotificationPermission
    };
})();

// Global verfuegbar
window.LiveUpdates = LiveUpdates;

// Auto-Init wenn DOM bereit
document.addEventListener('DOMContentLoaded', () => {
    // Nur initialisieren wenn nicht in iframe
    if (window.parent === window) {
        // WebSocket-Verbindung nur herstellen wenn Server erreichbar
        fetch('http://localhost:5001/health', { method: 'GET', signal: AbortSignal.timeout(2000) })
            .then(() => {
                WSClient.connect();
                LiveUpdates.init();
            })
            .catch(() => {
                console.log('[WSClient] WebSocket-Server nicht erreichbar - Live-Updates deaktiviert');
            });
    }
});
