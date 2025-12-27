/**
 * Frontend Preload & Prefetch System
 *
 * Funktionen:
 * - Lädt alle Formular-Routes vor
 * - Pre-fetcht Assets (Controls-JSONs, CSS)
 * - Stellt sicher, dass UI sofort bereit ist
 *
 * @module preloader
 */

/**
 * Prefetch-Status
 */
const preloadStatus = {
  forms: {},
  assets: {},
  isReady: false,
  startTime: null,
  endTime: null,
};

/**
 * Liste aller verfügbaren Formulare
 */
const FORMS = [
  { name: 'mitarbeiter', path: '/mitarbeiter', defaultId: 707 },
  { name: 'kunden', path: '/kunden', defaultId: 1 },
  { name: 'auftraege', path: '/auftraege', defaultId: 1 },
  { name: 'objekte', path: '/objekte', defaultId: 1 },
];

/**
 * Liste kritischer Assets
 */
const CRITICAL_ASSETS = [
  // Formular-Exports (werden beim Build in public/ kopiert)
  '/exports/forms/frm_MA_Mitarbeiterstamm/controls.json',
  '/exports/forms/frm_MA_Mitarbeiterstamm/tabs.json',
  '/exports/forms/frm_MA_Mitarbeiterstamm/subforms.json',
  '/exports/forms/frm_Menuefuehrung/controls.json',
];

/**
 * Prefetch einer einzelnen URL (ohne Rendering)
 */
async function prefetchUrl(url, name) {
  try {
    console.log(`🔥 Prefetch: ${name} (${url})`);
    const response = await fetch(url, {
      method: 'HEAD', // Nur Header, kein Body
      mode: 'no-cors', // Keine CORS-Probleme
    });

    preloadStatus.forms[name] = {
      ready: true,
      url,
      timestamp: new Date(),
    };

    return true;
  } catch (error) {
    console.warn(`⚠️ Prefetch fehlgeschlagen: ${name}`, error.message);
    preloadStatus.forms[name] = {
      ready: false,
      url,
      error: error.message,
    };
    return false;
  }
}

/**
 * Prefetch eines Assets (JSON, CSS, etc.)
 */
async function prefetchAsset(path) {
  try {
    const response = await fetch(path);
    if (response.ok) {
      // Asset vorladen (Browser cached automatisch)
      await response.text();
      preloadStatus.assets[path] = { ready: true };
      return true;
    }
  } catch (error) {
    console.warn(`⚠️ Asset-Prefetch fehlgeschlagen: ${path}`, error.message);
    preloadStatus.assets[path] = { ready: false, error: error.message };
  }
  return false;
}

/**
 * Lädt alle Assets vor
 */
export async function prefetchAssets() {
  console.log('🔥 Prefetch: Assets werden geladen...');

  const results = await Promise.allSettled(
    CRITICAL_ASSETS.map(asset => prefetchAsset(asset))
  );

  const successCount = results.filter(r => r.status === 'fulfilled' && r.value).length;
  console.log(`✅ Prefetch: ${successCount}/${CRITICAL_ASSETS.length} Assets geladen`);

  return successCount;
}

/**
 * Lädt alle Formular-Routes vor
 */
export async function preloadAllForms() {
  console.log('🔥 Preload: Formulare werden vorgeladen...');
  preloadStatus.startTime = Date.now();

  // Backend-Preload triggern
  try {
    const backendUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';
    await fetch(`${backendUrl}/api/preload`);
    console.log('✅ Backend-Preload erfolgreich');
  } catch (error) {
    console.warn('⚠️ Backend-Preload fehlgeschlagen:', error.message);
  }

  // Frontend-Forms prefetchen (parallel)
  const results = await Promise.allSettled(
    FORMS.map(form => prefetchUrl(form.path, form.name))
  );

  const successCount = results.filter(r => r.status === 'fulfilled' && r.value).length;

  // Assets prefetchen
  await prefetchAssets();

  preloadStatus.isReady = true;
  preloadStatus.endTime = Date.now();

  const duration = preloadStatus.endTime - preloadStatus.startTime;
  console.log(`✅ Preload abgeschlossen: ${successCount}/${FORMS.length} Formulare (${duration}ms)`);

  return {
    success: true,
    duration,
    forms: successCount,
    total: FORMS.length,
  };
}

/**
 * Prüft ob Preload abgeschlossen ist
 */
export function isPreloadReady() {
  return preloadStatus.isReady;
}

/**
 * Gibt Preload-Status zurück
 */
export function getPreloadStatus() {
  return {
    ready: preloadStatus.isReady,
    forms: Object.keys(preloadStatus.forms).length,
    assets: Object.keys(preloadStatus.assets).length,
    duration: preloadStatus.endTime
      ? preloadStatus.endTime - preloadStatus.startTime
      : null,
    details: preloadStatus,
  };
}

/**
 * Initialisiert Preload beim App-Start (non-blocking)
 */
export function initPreload() {
  // Verzögerter Start (nicht beim ersten Render blockieren)
  setTimeout(() => {
    preloadAllForms().catch(error => {
      console.error('❌ Preload fehlgeschlagen:', error);
    });
  }, 100);
}

export default {
  preloadAllForms,
  prefetchAssets,
  isPreloadReady,
  getPreloadStatus,
  initPreload,
};
