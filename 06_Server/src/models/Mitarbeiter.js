import { getFrontendConnection } from '../config/db.js';

/**
 * Mitarbeiter-Model
 * Zugriff auf tbl_MA_Mitarbeiterstamm (Frontend-DB)
 */

// Export für Warmup-Modul
export const MitarbeiterModel = {
  getAll: getAllMitarbeiter,
  getById: getMitarbeiterById,
  create: createMitarbeiter,
  update: updateMitarbeiter,
  delete: deleteMitarbeiter,
};

/**
 * Holt alle Mitarbeiter
 */
export async function getAllMitarbeiter() {
  const connection = await getFrontendConnection();
  try {
    const result = await connection.query(
      'SELECT ID, Nachname, Vorname, Ort, IstAktiv FROM tbl_MA_Mitarbeiterstamm ORDER BY Nachname, Vorname'
    );
    return result;
  } finally {
    await connection.close();
  }
}

/**
 * Holt einen Mitarbeiter nach ID
 */
export async function getMitarbeiterById(id) {
  const connection = await getFrontendConnection();
  try {
    const result = await connection.query(
      'SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?',
      [id]
    );
    return result.length > 0 ? result[0] : null;
  } finally {
    await connection.close();
  }
}

/**
 * Erstellt neuen Mitarbeiter
 */
export async function createMitarbeiter(data) {
  const connection = await getFrontendConnection();
  try {
    // Generiere neue ID (Max-ID + 1)
    const maxIdResult = await connection.query('SELECT MAX(ID) AS MaxID FROM tbl_MA_Mitarbeiterstamm');
    const newId = (maxIdResult[0]?.MaxID || 0) + 1;

    const result = await connection.query(
      `INSERT INTO tbl_MA_Mitarbeiterstamm (
        ID, Nachname, Vorname, Strasse, Nr, PLZ, Ort, Land, Bundesland,
        Tel_Mobil, Tel_Festnetz, Email, Geschlecht, Staatsang,
        Geb_Dat, Geb_Ort, Eintrittsdatum, IstAktiv, Anstellungsart_ID
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        newId,
        data.Nachname,
        data.Vorname,
        data.Strasse || '',
        data.Nr || '',
        data.PLZ || '',
        data.Ort || '',
        data.Land || 'Deutschland',
        data.Bundesland || '',
        data.Tel_Mobil || '',
        data.Tel_Festnetz || '',
        data.Email || '',
        data.Geschlecht || null,
        data.Staatsang || '',
        data.Geb_Dat || null,
        data.Geb_Ort || '',
        data.Eintrittsdatum || new Date(),
        data.IstAktiv !== undefined ? data.IstAktiv : true,
        data.Anstellungsart_ID || 3,
      ]
    );

    return { ID: newId, ...data };
  } finally {
    await connection.close();
  }
}

/**
 * Aktualisiert Mitarbeiter
 */
export async function updateMitarbeiter(id, data) {
  const connection = await getFrontendConnection();
  try {
    const result = await connection.query(
      `UPDATE tbl_MA_Mitarbeiterstamm SET
        Nachname = ?, Vorname = ?, Strasse = ?, Nr = ?, PLZ = ?, Ort = ?,
        Land = ?, Bundesland = ?, Tel_Mobil = ?, Tel_Festnetz = ?, Email = ?,
        Geschlecht = ?, Staatsang = ?, Geb_Dat = ?, Geb_Ort = ?,
        Eintrittsdatum = ?, Austrittsdatum = ?, IstAktiv = ?, Anstellungsart_ID = ?
      WHERE ID = ?`,
      [
        data.Nachname,
        data.Vorname,
        data.Strasse,
        data.Nr,
        data.PLZ,
        data.Ort,
        data.Land,
        data.Bundesland,
        data.Tel_Mobil,
        data.Tel_Festnetz,
        data.Email,
        data.Geschlecht,
        data.Staatsang,
        data.Geb_Dat,
        data.Geb_Ort,
        data.Eintrittsdatum,
        data.Austrittsdatum,
        data.IstAktiv,
        data.Anstellungsart_ID,
        id,
      ]
    );
    return result;
  } finally {
    await connection.close();
  }
}

/**
 * Löscht Mitarbeiter
 */
export async function deleteMitarbeiter(id) {
  const connection = await getFrontendConnection();
  try {
    const result = await connection.query(
      'DELETE FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?',
      [id]
    );
    return result;
  } finally {
    await connection.close();
  }
}
