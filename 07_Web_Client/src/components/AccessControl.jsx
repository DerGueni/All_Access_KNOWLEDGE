import React from 'react';
import { twipsToStyle } from '../lib/twipsConverter';
import { accessColorToRgb } from '../lib/colorConverter';
import { accessFontToStyle } from '../lib/fontConverter';
import { getControlTypeName } from '../lib/controlTypes';

/**
 * Rendert ein einzelnes Access-Control
 */
export default function AccessControl({ control, formData }) {
  const baseStyle = {
    ...twipsToStyle(control),
    backgroundColor: accessColorToRgb(control.BackColor),
    color: accessColorToRgb(control.ForeColor),
    borderColor: accessColorToRgb(control.BorderColor),
    ...accessFontToStyle(control),
    boxSizing: 'border-box',
    overflow: 'hidden',
  };

  // Sichtbarkeit
  if (control.Visible === 'Falsch' || control.Visible === false) {
    baseStyle.display = 'none';
  }

  // Border-Style basierend auf SpecialEffect
  const borderStyles = {
    0: 'none',       // Flach
    1: 'solid',      // Erhöht
    2: 'solid',      // Vertieft
    3: 'ridge',      // Geätzt
    4: 'solid',      // Schattiert
  };
  if (control.SpecialEffect !== undefined) {
    baseStyle.borderStyle = borderStyles[control.SpecialEffect] || 'solid';
    baseStyle.borderWidth = control.SpecialEffect === 0 ? '0' : '1px';
  }

  // Control-Value (ControlSource oder gebundene Daten)
  const getValue = () => {
    if (control.ControlSource && formData) {
      return formData[control.ControlSource] || '';
    }
    return control.Caption || control.Value || '';
  };

  // Render basierend auf ControlType
  const renderControl = () => {
    const controlType = control.ControlType;
    const value = getValue();

    switch (controlType) {
      case 100: // Label
        return (
          <div style={baseStyle} title={control.Name}>
            {control.Caption}
          </div>
        );

      case 101: // Rectangle
        return (
          <div
            style={{
              ...baseStyle,
              borderWidth: '1px',
              borderStyle: 'solid',
            }}
            title={control.Name}
          />
        );

      case 103: // Image
        return (
          <div
            style={{
              ...baseStyle,
              backgroundSize: 'contain',
              backgroundRepeat: 'no-repeat',
              backgroundPosition: 'center',
            }}
            title={control.Name}
          >
            {/* Image-Source wird später via API geladen */}
          </div>
        );

      case 104: // CommandButton
        return (
          <button
            style={{
              ...baseStyle,
              cursor: 'pointer',
              textAlign: 'center',
            }}
            disabled={control.Enabled === 'Falsch' || control.Enabled === false}
            title={control.Name}
          >
            {control.Caption}
          </button>
        );

      case 106: // CheckBox
        return (
          <input
            type="checkbox"
            style={{
              ...baseStyle,
              width: 'auto',
              height: 'auto',
              margin: '0',
            }}
            checked={value === true || value === -1}
            disabled={control.Locked === 'Wahr' || control.Enabled === 'Falsch'}
            readOnly={control.Locked === 'Wahr'}
            title={control.Name}
          />
        );

      case 109: // TextBox
        return (
          <input
            type="text"
            style={{
              ...baseStyle,
              padding: '2px 4px',
            }}
            value={value}
            disabled={control.Locked === 'Wahr' || control.Enabled === 'Falsch'}
            readOnly={control.Locked === 'Wahr'}
            title={control.Name}
            onChange={() => {/* TODO: Implement */}}
          />
        );

      case 110: // ListBox
        return (
          <select
            multiple
            style={{
              ...baseStyle,
              padding: '2px',
            }}
            disabled={control.Locked === 'Wahr' || control.Enabled === 'Falsch'}
            title={control.Name}
          >
            {/* RowSource wird später via API geladen */}
            <option>Loading...</option>
          </select>
        );

      case 111: // ComboBox
        return (
          <select
            style={{
              ...baseStyle,
              padding: '2px',
            }}
            value={value}
            disabled={control.Locked === 'Wahr' || control.Enabled === 'Falsch'}
            title={control.Name}
            onChange={() => {/* TODO: Implement */}}
          >
            {/* RowSource wird später via API geladen */}
            <option value="">Loading...</option>
          </select>
        );

      case 112: // Subform
        // Subform wird von SubformRenderer gehandelt
        return null;

      case 123: // TabControl
        return (
          <div
            style={{
              ...baseStyle,
              border: '1px solid ' + accessColorToRgb(control.BorderColor),
            }}
            title={control.Name}
          >
            {/* TabControl wird später als eigene Komponente gerendert */}
            <div style={{ padding: '8px' }}>
              [TabControl: {control.Name}]
            </div>
          </div>
        );

      case 124: // Page (Tab-Page)
        return (
          <div
            style={{
              ...baseStyle,
            }}
            title={control.Name}
          >
            {/* Tab-Content wird hier gerendert */}
            {control.Caption}
          </div>
        );

      default:
        return (
          <div
            style={{
              ...baseStyle,
              border: '1px dashed #ccc',
              fontSize: '10px',
              color: '#999',
            }}
            title={control.Name}
          >
            [{getControlTypeName(controlType)}: {control.Name}]
          </div>
        );
    }
  };

  return renderControl();
}
