/**
 * Access Color Converter
 *
 * Access speichert Farben als Long Integer im BGR-Format:
 * - Positive Werte: RGB-Farben (aber BGR-kodiert)
 * - Negative Werte: System-Farben
 */

// System-Farben (negative Access-Werte)
const SYSTEM_COLORS = {
  '-2147483633': '#000000', // acBlack
  '-2147483643': '#C0C0C0', // acButtonFace
  '-2147483630': '#808080', // acButtonShadow
  '-2147483616': '#000000', // acWindowText
  '-2147483624': '#FFFFFF', // acWindow
  '-2147483607': '#F0F0F0', // acButtonFace (alternative)
};

/**
 * Konvertiert Access-Farbe (Long Integer) zu RGB-String
 * @param {number} accessColor - Access-Farbwert (BGR-Format oder System-Farbe)
 * @returns {string} CSS-Farbe (rgb() oder hex)
 */
export function accessColorToRgb(accessColor) {
  if (accessColor === null || accessColor === undefined) {
    return 'transparent';
  }

  // System-Farben (negative Werte)
  if (accessColor < 0) {
    const systemColor = SYSTEM_COLORS[accessColor.toString()];
    if (systemColor) {
      return systemColor;
    }
    // Fallback für unbekannte System-Farben
    return '#FFFFFF';
  }

  // BGR zu RGB konvertieren
  const b = (accessColor >> 16) & 0xFF;
  const g = (accessColor >> 8) & 0xFF;
  const r = accessColor & 0xFF;

  return `rgb(${r}, ${g}, ${b})`;
}

/**
 * Konvertiert Access-Farbe zu Hex-String
 * @param {number} accessColor - Access-Farbwert
 * @returns {string} Hex-Farbe (#RRGGBB)
 */
export function accessColorToHex(accessColor) {
  if (accessColor === null || accessColor === undefined) {
    return '#FFFFFF';
  }

  if (accessColor < 0) {
    const systemColor = SYSTEM_COLORS[accessColor.toString()];
    return systemColor || '#FFFFFF';
  }

  const b = (accessColor >> 16) & 0xFF;
  const g = (accessColor >> 8) & 0xFF;
  const r = accessColor & 0xFF;

  const toHex = (n) => n.toString(16).padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}
