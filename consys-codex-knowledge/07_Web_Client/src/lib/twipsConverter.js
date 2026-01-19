/**
 * Twips to Pixel Converter
 *
 * Access verwendet Twips als Maßeinheit:
 * - 1 Inch = 1440 Twips
 * - Bei 96 DPI: 1 Twip = 0.0666667 Pixel
 */

export const TWIPS_PER_INCH = 1440;
export const PIXELS_PER_INCH = 96; // Standard-DPI
export const TWIPS_TO_PX_FACTOR = PIXELS_PER_INCH / TWIPS_PER_INCH; // 0.0666667

/**
 * Konvertiert Twips zu Pixels
 * @param {number} twips - Twips-Wert aus Access
 * @returns {number} Pixel-Wert (gerundet)
 */
export function twipsToPx(twips) {
  if (typeof twips !== 'number' || isNaN(twips)) {
    return 0;
  }
  return Math.round(twips * TWIPS_TO_PX_FACTOR);
}

/**
 * Konvertiert Pixels zu Twips
 * @param {number} pixels - Pixel-Wert
 * @returns {number} Twips-Wert
 */
export function pxToTwips(pixels) {
  if (typeof pixels !== 'number' || isNaN(pixels)) {
    return 0;
  }
  return Math.round(pixels / TWIPS_TO_PX_FACTOR);
}

/**
 * Konvertiert Access-Position/Größe zu CSS-Style-Objekt
 * @param {object} control - Control mit Left, Top, Width, Height in Twips
 * @returns {object} CSS-Style-Objekt
 */
export function twipsToStyle(control) {
  return {
    position: 'absolute',
    left: `${twipsToPx(control.Left)}px`,
    top: `${twipsToPx(control.Top)}px`,
    width: `${twipsToPx(control.Width)}px`,
    height: `${twipsToPx(control.Height)}px`,
  };
}
