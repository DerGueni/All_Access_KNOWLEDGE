import express from 'express';
import * as kundenController from '../controllers/kundenController.js';

const router = express.Router();

/**
 * Kunden-Routes
 *
 * GET    /api/kunden           - Liste aller Kunden
 * GET    /api/kunden/:id       - Einzelner Kunde
 * POST   /api/kunden           - Neuer Kunde
 * PUT    /api/kunden/:id       - Kunde aktualisieren
 * DELETE /api/kunden/:id       - Kunde löschen
 * GET    /api/kunden/:id/umsatz - Umsatzstatistiken
 */

// GET /api/kunden
router.get('/', kundenController.getAll);

// GET /api/kunden/:id
router.get('/:id', kundenController.getById);

// POST /api/kunden
router.post('/', kundenController.create);

// PUT /api/kunden/:id
router.put('/:id', kundenController.update);

// DELETE /api/kunden/:id
router.delete('/:id', kundenController.remove);

// GET /api/kunden/:id/umsatz
router.get('/:id/umsatz', kundenController.getUmsatz);

export default router;
