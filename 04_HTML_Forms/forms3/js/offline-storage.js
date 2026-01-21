/**
 * Offline Storage System
 * IndexedDB-basierte Datenspeicherung fuer Offline-Modus
 *
 * Verwendung:
 *   // Daten speichern
 *   await OfflineStorage.set('auftraege', auftragListe);
 *   await OfflineStorage.setItem('auftrag_123', auftragData);
 *
 *   // Daten laden
 *   const auftraege = await OfflineStorage.get('auftraege');
 *   const auftrag = await OfflineStorage.getItem('auftrag_123');
 *
 *   // Offline-Queue fuer Requests
 *   await OfflineStorage.queueRequest('/api/zuordnung', 'POST', data);
 *   await OfflineStorage.syncQueue(); // Wenn wieder online
 */

'use strict';

const OfflineStorage = (function() {
    const DB_NAME = 'consys-offline';
    const DB_VERSION = 1;
    const STORES = {
        DATA: 'data',
        QUEUE: 'queue',
        META: 'meta'
    };

    let db = null;

    /**
     * Datenbank oeffnen/erstellen
     */
    async function openDB() {
        if (db) return db;

        return new Promise((resolve, reject) => {
            const request = indexedDB.open(DB_NAME, DB_VERSION);

            request.onerror = () => {
                console.error('[OfflineStorage] DB Fehler:', request.error);
                reject(request.error);
            };

            request.onsuccess = () => {
                db = request.result;
                console.log('[OfflineStorage] DB geoeffnet');
                resolve(db);
            };

            request.onupgradeneeded = (event) => {
                const database = event.target.result;

                // Data Store - fuer gecachte Daten
                if (!database.objectStoreNames.contains(STORES.DATA)) {
                    database.createObjectStore(STORES.DATA, { keyPath: 'key' });
                }

                // Queue Store - fuer ausstehende Requests
                if (!database.objectStoreNames.contains(STORES.QUEUE)) {
                    const queueStore = database.createObjectStore(STORES.QUEUE, {
                        keyPath: 'id',
                        autoIncrement: true
                    });
                    queueStore.createIndex('timestamp', 'timestamp');
                    queueStore.createIndex('status', 'status');
                }

                // Meta Store - fuer Metadaten (letzte Sync, etc.)
                if (!database.objectStoreNames.contains(STORES.META)) {
                    database.createObjectStore(STORES.META, { keyPath: 'key' });
                }

                console.log('[OfflineStorage] DB Schema aktualisiert');
            };
        });
    }

    /**
     * Transaktion ausfuehren
     */
    async function transaction(storeName, mode, callback) {
        const database = await openDB();
        return new Promise((resolve, reject) => {
            const tx = database.transaction(storeName, mode);
            const store = tx.objectStore(storeName);

            tx.oncomplete = () => resolve();
            tx.onerror = () => reject(tx.error);

            callback(store, resolve, reject);
        });
    }

    // =====================================================
    // DATA STORE - Gecachte Daten
    // =====================================================

    /**
     * Daten speichern
     */
    async function set(key, value) {
        await transaction(STORES.DATA, 'readwrite', (store) => {
            store.put({
                key: key,
                value: value,
                timestamp: Date.now()
            });
        });
    }

    /**
     * Daten laden
     */
    async function get(key) {
        return new Promise(async (resolve) => {
            await transaction(STORES.DATA, 'readonly', (store, _, reject) => {
                const request = store.get(key);
                request.onsuccess = () => {
                    resolve(request.result?.value || null);
                };
                request.onerror = () => {
                    reject(request.error);
                };
            });
        });
    }

    /**
     * Daten loeschen
     */
    async function remove(key) {
        await transaction(STORES.DATA, 'readwrite', (store) => {
            store.delete(key);
        });
    }

    /**
     * Alle Daten loeschen
     */
    async function clear() {
        await transaction(STORES.DATA, 'readwrite', (store) => {
            store.clear();
        });
    }

    /**
     * Alle Keys abrufen
     */
    async function keys() {
        return new Promise(async (resolve) => {
            await transaction(STORES.DATA, 'readonly', (store) => {
                const request = store.getAllKeys();
                request.onsuccess = () => {
                    resolve(request.result || []);
                };
            });
        });
    }

    // =====================================================
    // QUEUE STORE - Ausstehende Requests
    // =====================================================

    /**
     * Request zur Queue hinzufuegen
     */
    async function queueRequest(url, method, data, headers = {}) {
        const database = await openDB();
        return new Promise((resolve, reject) => {
            const tx = database.transaction(STORES.QUEUE, 'readwrite');
            const store = tx.objectStore(STORES.QUEUE);

            const request = store.add({
                url: url,
                method: method,
                data: data,
                headers: headers,
                timestamp: Date.now(),
                status: 'pending',
                retries: 0
            });

            request.onsuccess = () => {
                console.log('[OfflineStorage] Request in Queue:', method, url);
                resolve(request.result);
            };
            request.onerror = () => reject(request.error);
        });
    }

    /**
     * Ausstehende Requests abrufen
     */
    async function getQueuedRequests() {
        return new Promise(async (resolve) => {
            const database = await openDB();
            const tx = database.transaction(STORES.QUEUE, 'readonly');
            const store = tx.objectStore(STORES.QUEUE);
            const index = store.index('status');

            const request = index.getAll('pending');
            request.onsuccess = () => {
                resolve(request.result || []);
            };
        });
    }

    /**
     * Request-Status aktualisieren
     */
    async function updateQueueItem(id, updates) {
        const database = await openDB();
        return new Promise((resolve, reject) => {
            const tx = database.transaction(STORES.QUEUE, 'readwrite');
            const store = tx.objectStore(STORES.QUEUE);

            const getRequest = store.get(id);
            getRequest.onsuccess = () => {
                const item = getRequest.result;
                if (item) {
                    Object.assign(item, updates);
                    store.put(item);
                    resolve(item);
                } else {
                    reject(new Error('Item not found'));
                }
            };
        });
    }

    /**
     * Request aus Queue entfernen
     */
    async function removeFromQueue(id) {
        await transaction(STORES.QUEUE, 'readwrite', (store) => {
            store.delete(id);
        });
    }

    /**
     * Queue synchronisieren
     */
    async function syncQueue() {
        const pending = await getQueuedRequests();

        if (pending.length === 0) {
            console.log('[OfflineStorage] Queue ist leer');
            return { synced: 0, failed: 0 };
        }

        console.log(`[OfflineStorage] Synchronisiere ${pending.length} Requests...`);

        let synced = 0;
        let failed = 0;

        for (const item of pending) {
            try {
                const response = await fetch(item.url, {
                    method: item.method,
                    headers: {
                        'Content-Type': 'application/json',
                        ...item.headers
                    },
                    body: item.data ? JSON.stringify(item.data) : undefined
                });

                if (response.ok) {
                    await removeFromQueue(item.id);
                    synced++;
                    console.log('[OfflineStorage] Sync OK:', item.method, item.url);
                } else {
                    await updateQueueItem(item.id, {
                        status: 'failed',
                        error: `HTTP ${response.status}`,
                        lastTry: Date.now()
                    });
                    failed++;
                }
            } catch (error) {
                await updateQueueItem(item.id, {
                    retries: item.retries + 1,
                    lastTry: Date.now(),
                    error: error.message
                });
                failed++;
            }
        }

        console.log(`[OfflineStorage] Sync abgeschlossen: ${synced} OK, ${failed} fehlgeschlagen`);

        return { synced, failed };
    }

    /**
     * Queue leeren
     */
    async function clearQueue() {
        await transaction(STORES.QUEUE, 'readwrite', (store) => {
            store.clear();
        });
    }

    /**
     * Queue-Groesse
     */
    async function getQueueSize() {
        return new Promise(async (resolve) => {
            await transaction(STORES.QUEUE, 'readonly', (store) => {
                const request = store.count();
                request.onsuccess = () => {
                    resolve(request.result);
                };
            });
        });
    }

    // =====================================================
    // META STORE - Metadaten
    // =====================================================

    /**
     * Letzten Sync-Zeitpunkt setzen
     */
    async function setLastSync(endpoint) {
        await transaction(STORES.META, 'readwrite', (store) => {
            store.put({
                key: `lastSync_${endpoint}`,
                timestamp: Date.now()
            });
        });
    }

    /**
     * Letzten Sync-Zeitpunkt abrufen
     */
    async function getLastSync(endpoint) {
        return new Promise(async (resolve) => {
            await transaction(STORES.META, 'readonly', (store) => {
                const request = store.get(`lastSync_${endpoint}`);
                request.onsuccess = () => {
                    resolve(request.result?.timestamp || null);
                };
            });
        });
    }

    // =====================================================
    // ONLINE/OFFLINE EVENTS
    // =====================================================

    // Auto-Sync wenn wieder online
    if (typeof window !== 'undefined') {
        window.addEventListener('online', async () => {
            console.log('[OfflineStorage] Online - starte Auto-Sync');
            const result = await syncQueue();

            if (result.synced > 0 && window.Toast) {
                Toast.success(`${result.synced} Aenderungen synchronisiert`);
            }
            if (result.failed > 0 && window.Toast) {
                Toast.warning(`${result.failed} Aenderungen konnten nicht synchronisiert werden`);
            }
        });
    }

    // Public API
    return {
        // Data Store
        set,
        get,
        remove,
        clear,
        keys,

        // Aliases
        setItem: set,
        getItem: get,
        removeItem: remove,

        // Queue Store
        queueRequest,
        getQueuedRequests,
        syncQueue,
        clearQueue,
        getQueueSize,

        // Meta Store
        setLastSync,
        getLastSync,

        // Status
        get isOnline() {
            return navigator.onLine;
        }
    };
})();

// Global verfuegbar
window.OfflineStorage = OfflineStorage;

console.log('[OfflineStorage] Modul geladen');
