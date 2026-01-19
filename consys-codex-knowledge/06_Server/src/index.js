import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { initializePools } from './config/db.js';
import mitarbeiterRoutes from './routes/mitarbeiter.js';
import kundenRoutes from './routes/kunden.js';
import { warmupServer, getWarmupStatus, isServerReady } from './warmup.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Consys API laeuft',
    timestamp: new Date().toISOString(),
    database: 'Connected',
    ready: isServerReady(),
  });
});

// Preload Endpoint (für Access-Frontend)
app.get('/api/preload', async (req, res) => {
  try {
    const status = getWarmupStatus();

    // Falls noch nicht warm, jetzt warmup triggern
    if (!status.ready) {
      await warmupServer();
    }

    const finalStatus = getWarmupStatus();

    res.json({
      success: true,
      message: 'Server ist bereit',
      ...finalStatus,
      forms: [
        'mitarbeiter',
        'kunden',
        'auftraege',
        'objekte',
      ],
    });
  } catch (error) {
    console.error('Preload-Fehler:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Routes
app.use('/api/mitarbeiter', mitarbeiterRoutes);
app.use('/api/kunden', kundenRoutes);

// Error Handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Interner Serverfehler',
    details: err.message,
  });
});

// Start Server
async function startServer() {
  try {
    const useMock = process.env.USE_MOCK_DATA === 'true';

    if (useMock) {
      console.log('⚠️  MOCK-MODUS aktiviert - Keine echte DB-Verbindung');
    } else {
      // Initialisiere DB-Verbindungen
      await initializePools();
    }

    app.listen(PORT, async () => {
      console.log(`🚀 Consys API laeuft auf http://localhost:${PORT}`);
      console.log(`📊 Health Check: http://localhost:${PORT}/api/health`);
      console.log(`🔥 Preload: http://localhost:${PORT}/api/preload`);
      console.log(`👤 Mitarbeiter API: http://localhost:${PORT}/api/mitarbeiter`);
      console.log(`🏢 Kunden API: http://localhost:${PORT}/api/kunden`);
      if (useMock) {
        console.log('💡 Mock-Daten werden verwendet (USE_MOCK_DATA=true in .env)');
      }

      // Automatischer Warmup beim Server-Start
      console.log('');
      await warmupServer();
      console.log('');
    });
  } catch (error) {
    console.error('❌ Server-Start fehlgeschlagen:', error);
    process.exit(1);
  }
}

startServer();
