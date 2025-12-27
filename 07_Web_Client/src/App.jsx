import React, { useState, useEffect } from 'react';
import MitarbeiterstammForm from './components/MitarbeiterstammForm';
import KundenstammForm from './components/KundenstammForm';
import PreloadComponent from './components/PreloadComponent';
import { MitarbeiterAPI, KundenAPI } from './lib/apiClient';
import { initPreload } from './lib/preloader';
import './styles/App.css';

function App() {
  const [view, setView] = useState('mitarbeiter'); // 'mitarbeiter' oder 'kunden'
  const [mitarbeiterId, setMitarbeiterId] = useState(707); // Default: Ahmad (ID 707)
  const [kundenId, setKundenId] = useState(20727); // Default-Kunde
  const [scale, setScale] = useState(1.0);
  const [allMitarbeiterIds, setAllMitarbeiterIds] = useState([]);
  const [allKundenIds, setAllKundenIds] = useState([]);

  // Einfaches Routing basierend auf URL-Path
  const currentPath = window.location.pathname;

  // Initialisiere Preload beim App-Start (non-blocking)
  useEffect(() => {
    // Nur wenn nicht bereits auf /preload
    if (currentPath !== '/preload') {
      initPreload();
    }
  }, [currentPath]);

  // Lade alle Mitarbeiter-IDs für Navigation
  useEffect(() => {
    async function loadAllIds() {
      try {
        const allMA = await MitarbeiterAPI.getAll();
        const ids = allMA.map(ma => ma.ID);
        setAllMitarbeiterIds(ids);
      } catch (error) {
        console.error('Error loading MA IDs:', error);
      }
    }

    // Nur laden wenn nicht auf Preload-Seite
    if (currentPath !== '/preload') {
      loadAllIds();
    }
  }, [currentPath]);

  // Lade alle Kunden-IDs für Navigation
  useEffect(() => {
    async function loadAllKundenIds() {
      try {
        const result = await KundenAPI.getAll();
        const ids = result.data.map(kd => kd.kun_ID);
        setAllKundenIds(ids);
      } catch (error) {
        console.error('Error loading Kunden IDs:', error);
      }
    }

    // Nur laden wenn nicht auf Preload-Seite
    if (currentPath !== '/preload') {
      loadAllKundenIds();
    }
  }, [currentPath]);

  // Navigation-Handler
  const handleNavigation = (direction) => {
    if (view === 'mitarbeiter') {
      const currentIndex = allMitarbeiterIds.indexOf(mitarbeiterId);
      let newId;

      switch (direction) {
        case 'first':
          newId = allMitarbeiterIds[0];
          break;
        case 'previous':
          newId = currentIndex > 0 ? allMitarbeiterIds[currentIndex - 1] : mitarbeiterId;
          break;
        case 'next':
          newId = currentIndex < allMitarbeiterIds.length - 1 ? allMitarbeiterIds[currentIndex + 1] : mitarbeiterId;
          break;
        case 'last':
          newId = allMitarbeiterIds[allMitarbeiterIds.length - 1];
          break;
        default:
          newId = mitarbeiterId;
      }

      if (newId) {
        setMitarbeiterId(newId);
      }
    } else if (view === 'kunden') {
      const currentIndex = allKundenIds.indexOf(kundenId);
      let newId;

      switch (direction) {
        case 'first':
          newId = allKundenIds[0];
          break;
        case 'previous':
          newId = currentIndex > 0 ? allKundenIds[currentIndex - 1] : kundenId;
          break;
        case 'next':
          newId = currentIndex < allKundenIds.length - 1 ? allKundenIds[currentIndex + 1] : kundenId;
          break;
        case 'last':
          newId = allKundenIds[allKundenIds.length - 1];
          break;
        default:
          newId = kundenId;
      }

      if (newId) {
        setKundenId(newId);
      }
    }
  };

  // Route-Handling
  if (currentPath === '/preload') {
    return <PreloadComponent />;
  }

  // URL-basierte ID-Extraktion für direkten Zugriff
  // z.B. /mitarbeiter/707 oder /kunden/20727
  const maMatch = currentPath.match(/^\/mitarbeiter\/(\d+)$/);
  if (maMatch) {
    const urlId = parseInt(maMatch[1], 10);
    if (urlId !== mitarbeiterId) {
      setMitarbeiterId(urlId);
      setView('mitarbeiter');
    }
  }

  const kdMatch = currentPath.match(/^\/kunden\/(\d+)$/);
  if (kdMatch) {
    const urlId = parseInt(kdMatch[1], 10);
    if (urlId !== kundenId) {
      setKundenId(urlId);
      setView('kunden');
    }
  }

  return (
    <div className="app">
      {/* Control-Panel */}
      <div className="control-panel">
        <h1>
          Consys {view === 'mitarbeiter' ? 'Mitarbeiterstamm' : 'Kundenstamm'}
        </h1>
        <div className="controls">
          {/* View-Umschalter */}
          <div style={{ display: 'flex', gap: '10px', marginRight: '20px' }}>
            <button
              onClick={() => setView('mitarbeiter')}
              style={{
                backgroundColor: view === 'mitarbeiter' ? '#4CAF50' : '#ccc',
                color: '#fff',
                padding: '5px 15px',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
              }}
            >
              Mitarbeiter
            </button>
            <button
              onClick={() => setView('kunden')}
              style={{
                backgroundColor: view === 'kunden' ? '#4CAF50' : '#ccc',
                color: '#fff',
                padding: '5px 15px',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
              }}
            >
              Kunden
            </button>
          </div>

          {/* Navigation */}
          <div style={{ display: 'flex', gap: '5px' }}>
            <button onClick={() => handleNavigation('first')} title="Erster Datensatz">
              |◄
            </button>
            <button onClick={() => handleNavigation('previous')} title="Vorheriger Datensatz">
              ◄
            </button>
            <button onClick={() => handleNavigation('next')} title="Nächster Datensatz">
              ►
            </button>
            <button onClick={() => handleNavigation('last')} title="Letzter Datensatz">
              ►|
            </button>
          </div>

          {/* ID-Input */}
          {view === 'mitarbeiter' ? (
            <label>
              MA-ID:
              <input
                type="number"
                value={mitarbeiterId}
                onChange={(e) => setMitarbeiterId(parseInt(e.target.value))}
                style={{ marginLeft: '10px', padding: '4px', width: '80px' }}
              />
            </label>
          ) : (
            <label>
              Kunden-ID:
              <input
                type="number"
                value={kundenId}
                onChange={(e) => setKundenId(parseInt(e.target.value))}
                style={{ marginLeft: '10px', padding: '4px', width: '80px' }}
              />
            </label>
          )}

          <label style={{ marginLeft: '20px' }}>
            Zoom:
            <input
              type="range"
              min="0.5"
              max="1.5"
              step="0.1"
              value={scale}
              onChange={(e) => setScale(parseFloat(e.target.value))}
              style={{ marginLeft: '10px' }}
            />
            <span style={{ marginLeft: '10px' }}>{Math.round(scale * 100)}%</span>
          </label>
        </div>
      </div>

      {/* Form-Container mit Zoom */}
      <div className="form-container">
        <div
          style={{
            transform: `scale(${scale})`,
            transformOrigin: 'top left',
          }}
        >
          {view === 'mitarbeiter' ? (
            <MitarbeiterstammForm mitarbeiterId={mitarbeiterId} />
          ) : (
            <KundenstammForm kundenId={kundenId} />
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
