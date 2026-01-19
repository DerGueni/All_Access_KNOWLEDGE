import {
  getAllKunden,
  getKundeById,
  createKunde,
  updateKunde,
  deleteKunde,
  getKundeUmsatz,
} from '../models/Kunde.js';

/**
 * Kunden-Controller
 * Enthält alle HTTP-Handler für Kunden-Endpoints
 */

/**
 * GET /api/kunden
 * Holt alle Kunden (mit optionalen Filtern)
 */
export async function getAll(req, res) {
  try {
    const options = {
      aktiv: req.query.aktiv === 'true' ? true : req.query.aktiv === 'false' ? false : undefined,
      plz: req.query.plz || undefined,
      ort: req.query.ort || undefined,
      sortfeld: req.query.sortfeld || undefined,
    };

    const kunden = await getAllKunden(options);

    res.json({
      success: true,
      data: kunden,
      count: kunden.length,
    });
  } catch (error) {
    console.error('Error in getAll:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

/**
 * GET /api/kunden/:id
 * Holt einen einzelnen Kunden
 */
export async function getById(req, res) {
  try {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid ID',
      });
    }

    const kunde = await getKundeById(id);

    if (!kunde) {
      return res.status(404).json({
        success: false,
        error: 'Kunde not found',
      });
    }

    res.json({
      success: true,
      data: kunde,
    });
  } catch (error) {
    console.error('Error in getById:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

/**
 * POST /api/kunden
 * Erstellt einen neuen Kunden
 */
export async function create(req, res) {
  try {
    const data = req.body;

    // Validierung: Mindestens Firma muss vorhanden sein
    if (!data.kun_Firma || data.kun_Firma.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'kun_Firma is required',
      });
    }

    const newKunde = await createKunde(data);

    res.status(201).json({
      success: true,
      data: newKunde,
      message: 'Kunde created successfully',
    });
  } catch (error) {
    console.error('Error in create:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

/**
 * PUT /api/kunden/:id
 * Aktualisiert einen Kunden
 */
export async function update(req, res) {
  try {
    const id = parseInt(req.params.id);
    const data = req.body;

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid ID',
      });
    }

    // Prüfe ob Kunde existiert
    const existingKunde = await getKundeById(id);
    if (!existingKunde) {
      return res.status(404).json({
        success: false,
        error: 'Kunde not found',
      });
    }

    const updatedKunde = await updateKunde(id, data);

    res.json({
      success: true,
      data: updatedKunde,
      message: 'Kunde updated successfully',
    });
  } catch (error) {
    console.error('Error in update:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

/**
 * DELETE /api/kunden/:id
 * Löscht einen Kunden (Soft-Delete)
 */
export async function remove(req, res) {
  try {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid ID',
      });
    }

    // Prüfe ob Kunde existiert
    const existingKunde = await getKundeById(id);
    if (!existingKunde) {
      return res.status(404).json({
        success: false,
        error: 'Kunde not found',
      });
    }

    await deleteKunde(id);

    res.json({
      success: true,
      message: 'Kunde deleted successfully',
    });
  } catch (error) {
    console.error('Error in remove:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

/**
 * GET /api/kunden/:id/umsatz
 * Holt Umsatz-Statistiken für einen Kunden
 */
export async function getUmsatz(req, res) {
  try {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid ID',
      });
    }

    const umsatz = await getKundeUmsatz(id);

    res.json({
      success: true,
      data: umsatz,
    });
  } catch (error) {
    console.error('Error in getUmsatz:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

export default {
  getAll,
  getById,
  create,
  update,
  remove,
  getUmsatz,
};
