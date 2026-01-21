/**
 * Service Worker fuer CONSYS PWA
 * Caching-Strategie: Cache-First fuer statische Assets, Network-First fuer API
 */

const CACHE_NAME = 'consys-v1';
const STATIC_CACHE = 'consys-static-v1';
const API_CACHE = 'consys-api-v1';

// Statische Assets die gecached werden sollen
const STATIC_ASSETS = [
    '/',
    '/shell.html',
    '/offline.html',
    '/css/main.css',
    '/css/critical.css',
    '/css/form-titles.css',
    '/css/unified-header.css',
    '/css/dark-mode.css',
    '/css/responsive-sidebar.css',
    '/js/sidebar.js',
    '/js/performance.js',
    '/js/toast-system.js',
    '/js/auto-save.js',
    '/js/context-menu.js',
    '/js/error-tracking.js',
    '/js/responsive-sidebar.js',
    '/js/websocket-client.js',
    '/js/bulk-operations.js',
    '/js/pagination.js',
    '/js/offline-storage.js',
    '/api/bridgeClient.js'
];

// Offline Queue fuer ausstehende Requests
const OFFLINE_QUEUE = 'consys-offline-queue';

// Formulare die gecached werden koennen
const FORM_PAGES = [
    '/frm_MA_Mitarbeiterstamm.html',
    '/frm_KD_Kundenstamm.html',
    '/frm_va_Auftragstamm.html',
    '/frm_OB_Objekt.html',
    '/frm_DP_Dienstplan_MA.html',
    '/frm_DP_Dienstplan_Objekt.html',
    '/frm_MA_VA_Schnellauswahl.html',
    '/frm_MA_Abwesenheit.html',
    '/frm_MA_Zeitkonten.html',
    '/frm_Einsatzuebersicht.html'
];

/**
 * Install Event - Cache statische Assets
 */
self.addEventListener('install', (event) => {
    console.log('[SW] Installing...');
    event.waitUntil(
        caches.open(STATIC_CACHE)
            .then((cache) => {
                console.log('[SW] Caching static assets');
                return cache.addAll(STATIC_ASSETS.map(url => {
                    return new Request(url, { cache: 'reload' });
                })).catch(err => {
                    console.warn('[SW] Some assets failed to cache:', err);
                });
            })
            .then(() => self.skipWaiting())
    );
});

/**
 * Activate Event - Alte Caches loeschen
 */
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating...');
    event.waitUntil(
        caches.keys()
            .then((cacheNames) => {
                return Promise.all(
                    cacheNames
                        .filter((name) => name !== STATIC_CACHE && name !== API_CACHE)
                        .map((name) => {
                            console.log('[SW] Deleting old cache:', name);
                            return caches.delete(name);
                        })
                );
            })
            .then(() => self.clients.claim())
    );
});

/**
 * Fetch Event - Caching Strategien
 */
self.addEventListener('fetch', (event) => {
    const url = new URL(event.request.url);

    // API Requests - Network First
    if (url.pathname.startsWith('/api/')) {
        event.respondWith(networkFirst(event.request, API_CACHE));
        return;
    }

    // Statische Assets - Cache First
    if (isStaticAsset(url.pathname)) {
        event.respondWith(cacheFirst(event.request, STATIC_CACHE));
        return;
    }

    // HTML Seiten - Stale While Revalidate
    if (url.pathname.endsWith('.html')) {
        event.respondWith(staleWhileRevalidate(event.request, STATIC_CACHE));
        return;
    }

    // Default - Network mit Cache Fallback
    event.respondWith(networkFirst(event.request, CACHE_NAME));
});

/**
 * Cache First Strategie
 */
async function cacheFirst(request, cacheName) {
    const cache = await caches.open(cacheName);
    const cached = await cache.match(request);

    if (cached) {
        return cached;
    }

    try {
        const response = await fetch(request);
        if (response.ok) {
            cache.put(request, response.clone());
        }
        return response;
    } catch (error) {
        // Offline-Fallback fuer HTML-Seiten
        if (request.headers.get('accept')?.includes('text/html')) {
            const offlinePage = await caches.match('/offline.html');
            if (offlinePage) return offlinePage;
        }
        return new Response('Offline', { status: 503, statusText: 'Service Unavailable' });
    }
}

/**
 * Network First Strategie
 */
async function networkFirst(request, cacheName) {
    const cache = await caches.open(cacheName);

    try {
        const response = await fetch(request);
        if (response.ok) {
            cache.put(request, response.clone());
        }
        return response;
    } catch (error) {
        const cached = await cache.match(request);
        if (cached) {
            return cached;
        }
        return new Response(JSON.stringify({ error: 'Offline', cached: false }), {
            status: 503,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}

/**
 * Stale While Revalidate
 */
async function staleWhileRevalidate(request, cacheName) {
    const cache = await caches.open(cacheName);
    const cached = await cache.match(request);

    const fetchPromise = fetch(request)
        .then((response) => {
            if (response.ok) {
                cache.put(request, response.clone());
            }
            return response;
        })
        .catch(() => null);

    return cached || fetchPromise;
}

/**
 * Pruefen ob statisches Asset
 */
function isStaticAsset(pathname) {
    const staticExtensions = ['.js', '.css', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.woff', '.woff2'];
    return staticExtensions.some(ext => pathname.endsWith(ext));
}

/**
 * Background Sync fuer Offline-Aktionen
 */
self.addEventListener('sync', (event) => {
    if (event.tag === 'sync-data') {
        event.waitUntil(syncPendingData());
    }
});

/**
 * Pending Data synchronisieren
 */
async function syncPendingData() {
    // Hier koennten offline gespeicherte Aenderungen synchronisiert werden
    console.log('[SW] Syncing pending data...');
}

/**
 * Push Notifications
 */
self.addEventListener('push', (event) => {
    if (!event.data) return;

    const data = event.data.json();
    const options = {
        body: data.body || 'Neue Benachrichtigung',
        icon: '/img/icon-192.png',
        badge: '/img/icon-72.png',
        vibrate: [100, 50, 100],
        data: data.url ? { url: data.url } : {},
        actions: data.actions || []
    };

    event.waitUntil(
        self.registration.showNotification(data.title || 'CONSYS', options)
    );
});

/**
 * Notification Click
 */
self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    if (event.notification.data?.url) {
        event.waitUntil(
            clients.openWindow(event.notification.data.url)
        );
    }
});

console.log('[SW] Service Worker loaded');
