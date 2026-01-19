import React, { useState, useEffect } from 'react';
import AccessControl from './AccessControl';
import { loadAccessJson } from '../lib/jsonParser';
import { twipsToStyle, twipsToPx } from '../lib/twipsConverter';

/**
 * Generische Subform-Komponente
 * Lädt Subform-Exports dynamisch oder zeigt Daten-Tabelle
 */
export default function SubformRenderer({
  subformName,
  sourceObject,
  linkMasterFields,
  linkChildFields,
  masterData,
  control
}) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [subformData, setSubformData] = useState(null);
  const [subformControls, setSubformControls] = useState(null);
  const [dataRows, setDataRows] = useState([]);

  useEffect(() => {
    async function loadSubform() {
      try {
        setLoading(true);

        // Versuche Subform-Export zu laden
        try {
          const controls = await loadAccessJson(`/exports/forms/${sourceObject}/controls.json`);
          setSubformControls(controls);
        } catch (err) {
          console.warn(`Subform ${sourceObject} hat keinen Export, zeige Daten-Tabelle`);
        }

        // TODO: Lade Subform-Daten via API
        // Filter basierend auf LinkMasterFields/LinkChildFields
        const filterValue = linkMasterFields && masterData
          ? linkMasterFields.split(';').map(field => masterData[field]).join(',')
          : null;

        // Dummy-Daten für jetzt
        if (sourceObject === 'frm_Menuefuehrung') {
          // Menü hat keine Daten, nur Controls
          setDataRows([]);
        } else {
          // Andere Subforms: Dummy-Daten
          setDataRows([
            { ID: 1, Name: 'Dummy-Eintrag 1' },
            { ID: 2, Name: 'Dummy-Eintrag 2' },
          ]);
        }

        setLoading(false);
      } catch (err) {
        console.error(`Error loading subform ${sourceObject}:`, err);
        setError(err.message);
        setLoading(false);
      }
    }

    loadSubform();
  }, [sourceObject, linkMasterFields, linkChildFields, masterData]);

  const containerStyle = {
    ...twipsToStyle(control),
    backgroundColor: '#fff',
    border: '1px solid #ccc',
    overflow: 'auto',
  };

  if (loading) {
    return (
      <div style={containerStyle}>
        <div style={{ padding: '8px', color: '#666', fontSize: '11px' }}>
          Lade {sourceObject}...
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={containerStyle}>
        <div style={{ padding: '8px', color: 'red', fontSize: '11px' }}>
          Fehler: {error}
        </div>
      </div>
    );
  }

  // Falls Subform-Export vorhanden: Rendere Controls
  if (subformControls && subformControls.Controls) {
    const formWidth = twipsToPx(subformControls.InsideWidth);
    const formHeight = twipsToPx(subformControls.InsideHeight);

    return (
      <div
        style={{
          ...containerStyle,
          position: 'relative',
        }}
      >
        <div
          style={{
            position: 'relative',
            width: `${formWidth}px`,
            height: `${formHeight}px`,
          }}
        >
          {subformControls.Controls.map((ctrl, index) => (
            <AccessControl
              key={ctrl.Name || index}
              control={ctrl}
              formData={masterData}
            />
          ))}
        </div>
      </div>
    );
  }

  // Fallback: Daten-Tabelle (für Subforms ohne Export)
  return (
    <div style={containerStyle}>
      <div style={{ padding: '8px' }}>
        <div style={{ fontSize: '11px', color: '#666', marginBottom: '8px' }}>
          <strong>{sourceObject}</strong>
          {linkMasterFields && linkChildFields && (
            <span style={{ marginLeft: '10px', fontSize: '10px' }}>
              [{linkMasterFields} → {linkChildFields}]
            </span>
          )}
        </div>

        {dataRows.length > 0 ? (
          <table style={{ width: '100%', fontSize: '11px', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ backgroundColor: '#f0f0f0', borderBottom: '1px solid #ccc' }}>
                {Object.keys(dataRows[0]).map((key) => (
                  <th key={key} style={{ padding: '4px', textAlign: 'left' }}>
                    {key}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {dataRows.map((row, index) => (
                <tr key={index} style={{ borderBottom: '1px solid #eee' }}>
                  {Object.values(row).map((value, i) => (
                    <td key={i} style={{ padding: '4px' }}>
                      {value}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div style={{ fontSize: '11px', color: '#999', fontStyle: 'italic' }}>
            Keine Daten
          </div>
        )}
      </div>
    </div>
  );
}
