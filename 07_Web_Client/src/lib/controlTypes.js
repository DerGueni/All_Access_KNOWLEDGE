/**
 * Access Control Types
 *
 * Mapping von Access-ControlType-Codes zu lesbaren Namen
 */

export const CONTROL_TYPES = {
  100: 'Label',           // Bezeichnungsfeld
  101: 'Rectangle',       // Rechteck
  102: 'Line',            // Linie
  103: 'Image',           // Bild
  104: 'CommandButton',   // Befehlsschaltfläche (Button)
  105: 'OptionButton',    // Optionsfeld (Radio)
  106: 'CheckBox',        // Kontrollkästchen
  107: 'OptionGroup',     // Optionsgruppe
  108: 'BoundObjectFrame',// Gebundener Objektrahmen
  109: 'TextBox',         // Textfeld
  110: 'ListBox',         // Listenfeld
  111: 'ComboBox',        // Kombinationsfeld (Dropdown)
  112: 'Subform',         // Unterformular/Subreport
  113: 'ObjectFrame',     // Objektrahmen
  114: 'PageBreak',       // Seitenumbruch
  115: 'CustomControl',   // Benutzerdefiniertes Steuerelement
  116: 'Chart',           // Diagramm
  122: 'Toggle',          // Umschaltfläche
  123: 'TabControl',      // Registerkarten-Steuerelement
  124: 'Page',            // Seite (Tab-Page)
  125: 'EmptyCell',       // Leere Zelle
};

/**
 * Gibt den Control-Typ-Namen zurück
 * @param {number} controlType - Access-ControlType-Code
 * @returns {string} Control-Typ-Name
 */
export function getControlTypeName(controlType) {
  return CONTROL_TYPES[controlType] || 'Unknown';
}

/**
 * Prüft, ob ein Control ein Container ist (enthält andere Controls)
 * @param {number} controlType - Access-ControlType-Code
 * @returns {boolean}
 */
export function isContainerControl(controlType) {
  return [107, 112, 123, 124].includes(controlType); // OptionGroup, Subform, TabControl, Page
}
