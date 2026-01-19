/**
 * Event-Handler für Form-Events
 * Portierte VBA-Funktionalität
 */

import { MitarbeiterAPI } from './apiClient';

/**
 * Navigation: Nächster Mitarbeiter
 */
export async function goToNext(currentId, allIds) {
  const currentIndex = allIds.indexOf(currentId);
  if (currentIndex < allIds.length - 1) {
    return allIds[currentIndex + 1];
  }
  return currentId; // Bleibt beim letzten
}

/**
 * Navigation: Vorheriger Mitarbeiter
 */
export async function goToPrevious(currentId, allIds) {
  const currentIndex = allIds.indexOf(currentId);
  if (currentIndex > 0) {
    return allIds[currentIndex - 1];
  }
  return currentId; // Bleibt beim ersten
}

/**
 * Navigation: Erster Mitarbeiter
 */
export async function goToFirst(allIds) {
  return allIds.length > 0 ? allIds[0] : null;
}

/**
 * Navigation: Letzter Mitarbeiter
 */
export async function goToLast(allIds) {
  return allIds.length > 0 ? allIds[allIds.length - 1] : null;
}

/**
 * Speichert Mitarbeiter-Änderungen
 */
export async function saveMitarbeiter(id, data) {
  try {
    await MitarbeiterAPI.update(id, data);
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

/**
 * Erstellt neuen Mitarbeiter
 */
export async function createNewMitarbeiter(data) {
  try {
    const newMA = await MitarbeiterAPI.create(data);
    return { success: true, mitarbeiter: newMA };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

/**
 * Löscht Mitarbeiter
 */
export async function deleteMitarbeiter(id) {
  if (!confirm('Mitarbeiter wirklich löschen?')) {
    return { success: false, cancelled: true };
  }

  try {
    await MitarbeiterAPI.delete(id);
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
