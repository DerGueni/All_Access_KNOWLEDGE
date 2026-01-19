import React, { useState, useEffect } from 'react';
import AccessControl from './AccessControl';
import TabControl from './TabControl';
import SubformRenderer from './SubformRenderer';
import { loadAccessJson } from '../lib/jsonParser';
import { twipsToPx } from '../lib/twipsConverter';

/**
 * Haupt-Formular: frm_MA_Mitarbeiterstamm
 * Rendert alle 292 Controls pixelgenau
 */
export default function MitarbeiterstammForm({ mitarbeiterId = 707 }) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState(null);
  const [controlsData, setControlsData] = useState(null);
  const [tabsData, setTabsData] = useState(null);
  const [subformsData, setSubformsData] = useState(null);

  // Lade Form-Metadaten
  useEffect(() => {
    async function loadFormData() {
      try {
        setLoading(true);

        // Lade controls.json
        const controls = await loadAccessJson('/exports/forms/frm_MA_Mitarbeiterstamm/controls.json');
        setControlsData(controls);

        // Lade tabs.json
        const tabs = await loadAccessJson('/exports/forms/frm_MA_Mitarbeiterstamm/tabs.json');
        setTabsData(tabs);

        // Lade subforms.json
        const subforms = await loadAccessJson('/exports/forms/frm_MA_Mitarbeiterstamm/subforms.json');
        setSubformsData(subforms);

        // Lade recordsource.json
        const recordSource = await loadAccessJson('/exports/forms/frm_MA_Mitarbeiterstamm/recordsource.json');
        console.log('RecordSource:', recordSource);

        // Lade Mitarbeiter-Daten via API
        try {
          const mitarbeiterModule = await import('../lib/apiClient.js');
          const mitarbeiterData = await mitarbeiterModule.MitarbeiterAPI.getById(mitarbeiterId);
          setFormData(mitarbeiterData);
          console.log('Mitarbeiter-Daten geladen:', mitarbeiterData);
        } catch (apiError) {
          console.warn('API nicht erreichbar, verwende Dummy-Daten:', apiError);
          // Fallback: Dummy-Daten
          setFormData({
            ID: mitarbeiterId,
            Nachname: 'Alali',
            Vorname: 'Ahmad',
            Strasse: 'Musterstr.',
            Nr: '123',
            PLZ: '90478',
            Ort: 'Nürnberg',
            Land: 'Deutschland',
          });
        }

        setLoading(false);
      } catch (err) {
        console.error('Error loading form data:', err);
        setError(err.message);
        setLoading(false);
      }
    }

    loadFormData();
  }, [mitarbeiterId]);

  if (loading) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h2>Lade Formular...</h2>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ padding: '20px', color: 'red' }}>
        <h2>Fehler beim Laden:</h2>
        <pre>{error}</pre>
      </div>
    );
  }

  if (!controlsData) {
    return <div>Keine Controls gefunden</div>;
  }

  // Form-Dimensionen (aus controls.json)
  const formWidth = twipsToPx(controlsData.InsideWidth);
  const formHeight = twipsToPx(controlsData.InsideHeight);

  // Finde TabControl
  const tabControl = controlsData.Controls.find(c => c.ControlType === 123);

  // Finde alle Controls, die NICHT innerhalb des TabControls sind
  // (TabControl rendert seine eigenen Children)
  const mainControls = controlsData.Controls.filter(c => {
    // Rendere TabControl separat
    if (c.ControlType === 123) return false;
    // Rendere Tab-Pages nicht direkt (werden vom TabControl gerendert)
    if (c.ControlType === 124) return false;
    // Rendere Subforms separat
    if (c.ControlType === 112) return false;
    return true;
  });

  // Finde alle Subform-Controls (ControlType 112)
  const subformControls = controlsData.Controls.filter(c => c.ControlType === 112);

  // Mappe Subform-Controls zu ihren Metadaten aus subforms.json
  const subformsWithMetadata = subformControls.map(subformControl => {
    const metadata = subformsData?.Subforms?.find(sf => sf.Name === subformControl.Name);
    return {
      control: subformControl,
      sourceObject: metadata?.SourceObject || subformControl.Name,
      linkMasterFields: metadata?.LinkMasterFields || '',
      linkChildFields: metadata?.LinkChildFields || '',
    };
  });

  return (
    <div
      style={{
        position: 'relative',
        width: `${formWidth}px`,
        height: `${formHeight}px`,
        backgroundColor: '#fff',
        border: '1px solid #ccc',
        overflow: 'auto',
      }}
    >
      {/* Rendere alle Haupt-Controls */}
      {mainControls.map((control, index) => (
        <AccessControl
          key={control.Name || index}
          control={control}
          formData={formData}
        />
      ))}

      {/* Rendere TabControl separat (falls vorhanden) */}
      {tabControl && tabsData && (
        <TabControl
          control={tabControl}
          tabsData={tabsData}
          allControls={controlsData.Controls}
          formData={formData}
        />
      )}

      {/* Rendere alle Subforms */}
      {subformsWithMetadata.map((subform, index) => (
        <SubformRenderer
          key={subform.control.Name || index}
          subformName={subform.control.Name}
          sourceObject={subform.sourceObject}
          linkMasterFields={subform.linkMasterFields}
          linkChildFields={subform.linkChildFields}
          masterData={formData}
          control={subform.control}
        />
      ))}

      {/* Debug-Info */}
      <div
        style={{
          position: 'absolute',
          bottom: '10px',
          right: '10px',
          padding: '5px 10px',
          backgroundColor: 'rgba(0,0,0,0.7)',
          color: '#fff',
          fontSize: '10px',
          borderRadius: '3px',
        }}
      >
        {mainControls.length} Controls | {formWidth} × {formHeight} px
      </div>
    </div>
  );
}
