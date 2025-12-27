import odbc from 'odbc';
import dotenv from 'dotenv';

dotenv.config();

let frontendPool = null;
let backendPool = null;

/**
 * Initialisiert ODBC-Verbindungspools
 */
export async function initializePools() {
  try {
    // Frontend-DB Pool
    frontendPool = await odbc.pool({
      connectionString: process.env.ODBC_FRONTEND,
      connectionTimeout: 10,
      loginTimeout: 10,
    });
    console.log('✅ Frontend-DB Pool initialisiert');

    // Backend-DB Pool
    backendPool = await odbc.pool({
      connectionString: process.env.ODBC_BACKEND,
      connectionTimeout: 10,
      loginTimeout: 10,
    });
    console.log('✅ Backend-DB Pool initialisiert');

    return { frontendPool, backendPool };
  } catch (error) {
    console.error('❌ DB-Verbindung fehlgeschlagen:', error.message);
    throw error;
  }
}

/**
 * Gibt Frontend-DB-Connection zurück
 */
export async function getFrontendConnection() {
  if (!frontendPool) {
    await initializePools();
  }
  return frontendPool.connect();
}

/**
 * Gibt Backend-DB-Connection zurück
 */
export async function getBackendConnection() {
  if (!backendPool) {
    await initializePools();
  }
  return backendPool.connect();
}

/**
 * Schließt alle Verbindungspools
 */
export async function closePools() {
  if (frontendPool) await frontendPool.close();
  if (backendPool) await backendPool.close();
  console.log('✅ DB-Verbindungen geschlossen');
}

// Graceful Shutdown
process.on('SIGINT', async () => {
  await closePools();
  process.exit(0);
});
