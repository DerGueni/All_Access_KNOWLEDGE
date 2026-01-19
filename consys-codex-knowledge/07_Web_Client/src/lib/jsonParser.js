/**
 * JSON-Parser für Access-Exports
 *
 * Access-Exports haben manchmal trailing commas, die JSON.parse() nicht mag.
 * Dieser Parser bereinigt das JSON vor dem Parsen.
 */

/**
 * Bereinigt Access-JSON (entfernt trailing commas)
 * @param {string} jsonString - JSON-String mit möglichen trailing commas
 * @returns {string} Bereinigter JSON-String
 */
export function cleanAccessJson(jsonString) {
  // Entferne trailing commas vor } oder ]
  return jsonString
    .replace(/,\s*}/g, '}')
    .replace(/,\s*]/g, ']');
}

/**
 * Parst Access-JSON sicher
 * @param {string} jsonString - JSON-String aus Access-Export
 * @returns {object} Geparste Daten
 */
export function parseAccessJson(jsonString) {
  try {
    // Versuche zuerst normales Parsen
    return JSON.parse(jsonString);
  } catch (error) {
    // Falls das fehlschlägt, bereinige und parse nochmal
    try {
      const cleaned = cleanAccessJson(jsonString);
      return JSON.parse(cleaned);
    } catch (cleanError) {
      console.error('JSON Parse Error:', cleanError);
      console.error('Original JSON:', jsonString.substring(0, 500));
      throw cleanError;
    }
  }
}

/**
 * Lädt und parst eine Access-JSON-Datei
 * @param {string} url - URL zur JSON-Datei
 * @returns {Promise<object>} Geparste Daten
 */
export async function loadAccessJson(url) {
  const response = await fetch(url);
  const text = await response.text();
  return parseAccessJson(text);
}
