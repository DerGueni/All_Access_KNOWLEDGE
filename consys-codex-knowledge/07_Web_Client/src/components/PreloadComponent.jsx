import React, { useEffect, useState } from 'react';
import { preloadAllForms, getPreloadStatus } from '../lib/preloader';

/**
 * Preload-Component
 *
 * Diese Component wird von Access-Frontend gecallt um alle
 * Formulare vorzuladen (versteckt im Hintergrund)
 */
function PreloadComponent() {
  const [status, setStatus] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function runPreload() {
      try {
        console.log('🔥 PreloadComponent: Starte Preload...');
        await preloadAllForms();

        const finalStatus = getPreloadStatus();
        setStatus(finalStatus);
        setLoading(false);

        console.log('✅ PreloadComponent: Preload abgeschlossen', finalStatus);
      } catch (error) {
        console.error('❌ PreloadComponent: Fehler', error);
        setStatus({ error: error.message });
        setLoading(false);
      }
    }

    runPreload();
  }, []);

  return (
    <div
      style={{
        padding: '20px',
        fontFamily: 'Arial, sans-serif',
        maxWidth: '600px',
        margin: '50px auto',
      }}
    >
      <h1>🔥 Consys Preload</h1>

      {loading ? (
        <div>
          <p>⏳ Lade Formulare vor...</p>
          <div
            style={{
              width: '100%',
              height: '4px',
              background: '#eee',
              borderRadius: '2px',
              overflow: 'hidden',
              marginTop: '20px',
            }}
          >
            <div
              style={{
                width: '100%',
                height: '100%',
                background: 'linear-gradient(90deg, #4CAF50, #2196F3)',
                animation: 'loading 1.5s ease-in-out infinite',
              }}
            />
          </div>
        </div>
      ) : status?.error ? (
        <div style={{ color: '#f44336' }}>
          <p>❌ Fehler beim Preload:</p>
          <pre style={{ background: '#ffebee', padding: '10px', borderRadius: '4px' }}>
            {status.error}
          </pre>
        </div>
      ) : (
        <div style={{ color: '#4CAF50' }}>
          <h2>✅ Preload abgeschlossen</h2>
          <ul style={{ listStyle: 'none', padding: 0 }}>
            <li>📊 Formulare: {status?.forms || 0}</li>
            <li>📦 Assets: {status?.assets || 0}</li>
            <li>⏱️ Dauer: {status?.duration || 0}ms</li>
            <li>🚀 Status: {status?.ready ? 'Bereit' : 'Nicht bereit'}</li>
          </ul>

          <p style={{ marginTop: '30px', color: '#666' }}>
            Dieses Fenster kann geschlossen werden.
            <br />
            Alle Formulare sind jetzt vorgeladen.
          </p>
        </div>
      )}

      <style>
        {`
          @keyframes loading {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
          }
        `}
      </style>
    </div>
  );
}

export default PreloadComponent;
