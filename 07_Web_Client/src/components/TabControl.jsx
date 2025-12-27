import React, { useState } from 'react';
import AccessControl from './AccessControl';
import { twipsToStyle } from '../lib/twipsConverter';
import { accessColorToRgb } from '../lib/colorConverter';
import { accessFontToStyle } from '../lib/fontConverter';

/**
 * TabControl-Komponente (Access ControlType 123)
 * Rendert 13 Tab-Pages mit ihren Controls
 */
export default function TabControl({ control, tabsData, allControls, formData }) {
  const [activeTabIndex, setActiveTabIndex] = useState(0);

  if (!tabsData || !tabsData.TabControls || tabsData.TabControls.length === 0) {
    return <div style={twipsToStyle(control)}>No Tabs</div>;
  }

  const tabControlData = tabsData.TabControls[0]; // reg_MA
  const pages = tabControlData.Pages || [];

  // Finde alle Page-Controls (ControlType 124)
  const pageControls = allControls.filter(c => c.ControlType === 124);

  // Style für TabControl-Container
  const containerStyle = {
    ...twipsToStyle(control),
    backgroundColor: accessColorToRgb(control.BackColor),
    border: '1px solid ' + accessColorToRgb(control.BorderColor),
    display: 'flex',
    flexDirection: 'column',
  };

  // Style für Tab-Header
  const tabHeaderStyle = {
    display: 'flex',
    flexDirection: 'row',
    backgroundColor: accessColorToRgb(control.BackColor),
    borderBottom: '2px solid ' + accessColorToRgb(control.BorderColor),
  };

  // Finde Controls innerhalb einer bestimmten Tab-Page
  const getControlsForPage = (pageName) => {
    // Finde das Page-Control
    const pageControl = pageControls.find(c => c.Name === pageName);
    if (!pageControl) return [];

    // Finde alle Controls, die innerhalb der Page-Bounds liegen
    // (Controls mit Left/Top innerhalb der Page-Grenzen)
    return allControls.filter(c => {
      // Skip das Page-Control selbst
      if (c.Name === pageName) return false;
      // Skip TabControl und andere Pages
      if (c.ControlType === 123 || c.ControlType === 124) return false;

      // Prüfe, ob Control innerhalb der Page-Grenzen liegt
      const isInside =
        c.Left >= pageControl.Left &&
        c.Top >= pageControl.Top &&
        c.Left + c.Width <= pageControl.Left + pageControl.Width &&
        c.Top + c.Height <= pageControl.Top + pageControl.Height;

      return isInside;
    });
  };

  return (
    <div style={containerStyle}>
      {/* Tab-Header (die Tab-Buttons oben) */}
      <div style={tabHeaderStyle}>
        {pages.map((page, index) => {
          const isActive = index === activeTabIndex;
          return (
            <button
              key={page.Name}
              onClick={() => setActiveTabIndex(index)}
              style={{
                padding: '8px 16px',
                backgroundColor: isActive
                  ? '#fff'
                  : accessColorToRgb(control.BackColor),
                color: isActive
                  ? accessColorToRgb(control.ForeColor)
                  : '#666',
                border: 'none',
                borderBottom: isActive ? '2px solid #fff' : 'none',
                cursor: 'pointer',
                fontFamily: control.FontName || 'Arial',
                fontSize: control.FontSize ? `${control.FontSize}pt` : '10pt',
                fontWeight: isActive ? 'bold' : 'normal',
              }}
            >
              {page.Caption}
            </button>
          );
        })}
      </div>

      {/* Tab-Content (die aktive Page) */}
      <div
        style={{
          position: 'relative',
          flex: 1,
          backgroundColor: '#fff',
          overflow: 'auto',
        }}
      >
        {pages.map((page, index) => {
          if (index !== activeTabIndex) return null;

          // Finde Page-Control
          const pageControl = pageControls.find(c => c.Name === page.Name);
          const pageControls_filtered = getControlsForPage(page.Name);

          return (
            <div
              key={page.Name}
              style={{
                position: 'relative',
                width: '100%',
                height: '100%',
              }}
            >
              {/* Rendere alle Controls dieser Page */}
              {pageControls_filtered.map((ctrl, idx) => (
                <AccessControl
                  key={ctrl.Name || idx}
                  control={ctrl}
                  formData={formData}
                />
              ))}

              {/* Debug-Info */}
              <div
                style={{
                  position: 'absolute',
                  top: '5px',
                  right: '5px',
                  fontSize: '10px',
                  color: '#999',
                }}
              >
                {page.Caption} ({pageControls_filtered.length} controls)
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
