import express from 'express';
import * as mitarbeiterController from '../controllers/mitarbeiterController.js';

const router = express.Router();

// Mitarbeiter-CRUD
router.get('/', mitarbeiterController.getAllMitarbeiter);
router.get('/:id', mitarbeiterController.getMitarbeiterById);
router.post('/', mitarbeiterController.createMitarbeiter);
router.put('/:id', mitarbeiterController.updateMitarbeiter);
router.delete('/:id', mitarbeiterController.deleteMitarbeiter);

export default router;
