/**
 * Server Warmup & Preload System
 *
 * Funktionen:
 * - Initialisiert alle API-Endpoints beim Server-Start
 * - Pre-cacht häufig genutzte Queries
 * - Stellt sicher, dass erste Requests schnell sind
 *
 * @module warmup
 */

import { MitarbeiterModel } from './models/Mitarbeiter.js';
import { KundenModel } from './models/Kunde.js';

// Cache für Warmup-Daten
let warmupCache = {
  mitarbeiterListe: null,
  kundenListe: null,
  lastWarmup: null,
  isReady: false,
};

/**
 * Warmup: Lädt alle Mitarbeiter vor
 */
async function warmupMitarbeiter() {
  try {
    console.log('🔥 Warmup: Lade Mitarbeiter-Liste...');
    const mitarbeiter = await MitarbeiterModel.getAll();
    warmupCache.mitarbeiterListe = mitarbeiter;
    console.log(`✅ Warmup: ${mitarbeiter.length} Mitarbeiter vorgeladen`);
    return true;
  } catch (error) {
    console.error('❌ Warmup: Mitarbeiter fehlgeschlagen:', error.message);
    return false;
  }
}

/**
 * Warmup: Lädt alle Kunden vor
 */
async function warmupKunden() {
  try {
    console.log('🔥 Warmup: Lade Kunden-Liste...');
    const kunden = await KundenModel.getAll();
    warmupCache.kundenListe = kunden;
    console.log(`✅ Warmup: ${kunden.length} Kunden vorgeladen`);
    return true;
  } catch (error) {
    console.error('❌ Warmup: Kunden fehlgeschlagen:', error.message);
    return false;
  }
}

/**
 * Haupt-Warmup-Funktion
 * Initialisiert alle kritischen Endpoints
 */
export async function warmupServer() {
  console.log('🚀 Server-Warmup startet...');
  const startTime = Date.now();

  try {
    // Parallel warmup aller Endpoints
    const results = await Promise.allSettled([
      warmupMitarbeiter(),
      warmupKunden(),
      // Weitere Warmup-Funktionen können hier hinzugefügt werden:
      // warmupAuftraege(),
    ]);

    const successCount = results.filter(r => r.status === 'fulfilled' && r.value).length;
    const totalCount = results.length;

    warmupCache.lastWarmup = new Date();
    warmupCache.isReady = successCount > 0;

    const duration = Date.now() - startTime;
    console.log(`✅ Server-Warmup abgeschlossen: ${successCount}/${totalCount} erfolgreich (${duration}ms)`);

    return {
      success: true,
      duration,
      results: {
        mitarbeiter: results[0].status === 'fulfilled' && results[0].value,
      },
    };
  } catch (error) {
    console.error('❌ Server-Warmup fehlgeschlagen:', error);
    warmupCache.isReady = false;
    return {
      success: false,
      error: error.message,
    };
  }
}

/**
 * Prüft ob Server bereit ist
 */
export function isServerReady() {
  return warmupCache.isReady;
}

/**
 * Gibt Warmup-Status zurück
 */
export function getWarmupStatus() {
  return {
    ready: warmupCache.isReady,
    lastWarmup: warmupCache.lastWarmup,
    cachedData: {
      mitarbeiter: warmupCache.mitarbeiterListe?.length || 0,
    },
  };
}

/**
 * Holt vorgeladene Mitarbeiter aus Cache
 * (Performance-Optimierung für erste Requests)
 */
export function getCachedMitarbeiter() {
  return warmupCache.mitarbeiterListe;
}

/**
 * Invalidiert Cache (bei Datenänderungen)
 */
export function invalidateCache() {
  console.log('🔄 Cache invalidiert');
  warmupCache.mitarbeiterListe = null;
  warmupCache.isReady = false;
}

export default {
  warmupServer,
  isServerReady,
  getWarmupStatus,
  getCachedMitarbeiter,
  invalidateCache,
};
