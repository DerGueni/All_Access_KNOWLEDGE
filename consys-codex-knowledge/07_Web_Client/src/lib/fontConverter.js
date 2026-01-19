/**
 * Access Font Converter
 *
 * Konvertiert Access-Font-Eigenschaften zu CSS
 */

/**
 * Konvertiert Access-Font-Eigenschaften zu CSS-Style-Objekt
 * @param {object} control - Control mit FontName, FontSize, FontBold, FontItalic, etc.
 * @returns {object} CSS-Style-Objekt
 */
export function accessFontToStyle(control) {
  const style = {};

  // Font-Familie
  if (control.FontName) {
    style.fontFamily = control.FontName;
  }

  // Font-Größe (in pt)
  if (control.FontSize) {
    style.fontSize = `${control.FontSize}pt`;
  }

  // Font-Weight (Bold)
  if (control.FontBold === 1 || control.FontBold === '1') {
    style.fontWeight = 'bold';
  } else if (control.FontBold === 0 || control.FontBold === '0') {
    style.fontWeight = 'normal';
  }

  // Font-Style (Italic)
  if (control.FontItalic === 'Wahr' || control.FontItalic === true || control.FontItalic === '1') {
    style.fontStyle = 'italic';
  } else {
    style.fontStyle = 'normal';
  }

  // Underline
  if (control.FontUnderline === 'Wahr' || control.FontUnderline === true) {
    style.textDecoration = 'underline';
  }

  return style;
}
