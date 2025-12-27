import * as Mitarbeiter from '../models/Mitarbeiter.js';
import { MockMitarbeiter } from '../models/MockData.js';

// Wähle Model basierend auf Umgebungsvariable
const useMock = process.env.USE_MOCK_DATA === 'true';
const MitarbeiterModel = useMock ? MockMitarbeiter : Mitarbeiter;

/**
 * GET /api/mitarbeiter
 * Holt alle Mitarbeiter
 */
export async function getAllMitarbeiter(req, res) {
  try {
    const mitarbeiter = await MitarbeiterModel.getAllMitarbeiter();
    res.json(mitarbeiter);
  } catch (error) {
    console.error('Error in getAllMitarbeiter:', error);
    res.status(500).json({ error: 'Fehler beim Laden der Mitarbeiter', details: error.message });
  }
}

/**
 * GET /api/mitarbeiter/:id
 * Holt einen Mitarbeiter nach ID
 */
export async function getMitarbeiterById(req, res) {
  try {
    const { id } = req.params;
    const mitarbeiter = await MitarbeiterModel.getMitarbeiterById(parseInt(id));

    if (!mitarbeiter) {
      return res.status(404).json({ error: 'Mitarbeiter nicht gefunden' });
    }

    res.json(mitarbeiter);
  } catch (error) {
    console.error('Error in getMitarbeiterById:', error);
    res.status(500).json({ error: 'Fehler beim Laden des Mitarbeiters', details: error.message });
  }
}

/**
 * POST /api/mitarbeiter
 * Erstellt neuen Mitarbeiter
 */
export async function createMitarbeiter(req, res) {
  try {
    const data = req.body;

    // Validierung
    if (!data.Nachname || !data.Vorname) {
      return res.status(400).json({ error: 'Nachname und Vorname sind Pflichtfelder' });
    }

    const newMitarbeiter = await MitarbeiterModel.createMitarbeiter(data);
    res.status(201).json(newMitarbeiter);
  } catch (error) {
    console.error('Error in createMitarbeiter:', error);
    res.status(500).json({ error: 'Fehler beim Erstellen des Mitarbeiters', details: error.message });
  }
}

/**
 * PUT /api/mitarbeiter/:id
 * Aktualisiert Mitarbeiter
 */
export async function updateMitarbeiter(req, res) {
  try {
    const { id } = req.params;
    const data = req.body;

    // Prüfe, ob Mitarbeiter existiert
    const existing = await MitarbeiterModel.getMitarbeiterById(parseInt(id));
    if (!existing) {
      return res.status(404).json({ error: 'Mitarbeiter nicht gefunden' });
    }

    await MitarbeiterModel.updateMitarbeiter(parseInt(id), data);
    const updated = await MitarbeiterModel.getMitarbeiterById(parseInt(id));
    res.json(updated);
  } catch (error) {
    console.error('Error in updateMitarbeiter:', error);
    res.status(500).json({ error: 'Fehler beim Aktualisieren des Mitarbeiters', details: error.message });
  }
}

/**
 * DELETE /api/mitarbeiter/:id
 * Löscht Mitarbeiter
 */
export async function deleteMitarbeiter(req, res) {
  try {
    const { id } = req.params;

    // Prüfe, ob Mitarbeiter existiert
    const existing = await MitarbeiterModel.getMitarbeiterById(parseInt(id));
    if (!existing) {
      return res.status(404).json({ error: 'Mitarbeiter nicht gefunden' });
    }

    await MitarbeiterModel.deleteMitarbeiter(parseInt(id));
    res.json({ message: 'Mitarbeiter gelöscht', id: parseInt(id) });
  } catch (error) {
    console.error('Error in deleteMitarbeiter:', error);
    res.status(500).json({ error: 'Fehler beim Löschen des Mitarbeiters', details: error.message });
  }
}
