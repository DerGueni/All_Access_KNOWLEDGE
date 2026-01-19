import { getFrontendConnection } from '../config/db.js';

/**
 * Kunden-Model
 * Zugriff auf tbl_KD_Kundenstamm (Frontend-DB)
 */

// Export für Warmup-Modul
export const KundenModel = {
  getAll: getAllKunden,
  getById: getKundeById,
  create: createKunde,
  update: updateKunde,
  delete: deleteKunde,
  getUmsatz: getKundeUmsatz,
};

/**
 * Holt alle Kunden
 * @param {Object} options - Filter-Optionen
 * @param {Boolean} options.aktiv - Nur aktive Kunden (kun_IstAktiv = True)
 * @param {String} options.plz - Filter nach PLZ
 * @param {String} options.ort - Filter nach Ort
 * @param {String} options.sortfeld - Filter nach Sortfeld
 */
export async function getAllKunden(options = {}) {
  const connection = await getFrontendConnection();
  try {
    let sql = 'SELECT kun_ID, kun_Firma, kun_Matchcode, kun_Ort, kun_IstAktiv FROM tbl_KD_Kundenstamm';
    const params = [];
    const whereClauses = [];

    if (options.aktiv !== undefined) {
      whereClauses.push('kun_IstAktiv = ?');
      params.push(options.aktiv);
    }

    if (options.plz) {
      whereClauses.push("kun_LKZ = 'D' AND kun_plz = ?");
      params.push(options.plz);
    }

    if (options.ort) {
      whereClauses.push("kun_LKZ = 'D' AND kun_ort = ?");
      params.push(options.ort);
    }

    if (options.sortfeld) {
      whereClauses.push('kun_Sortfeld = ?');
      params.push(options.sortfeld);
    }

    if (whereClauses.length > 0) {
      sql += ' WHERE ' + whereClauses.join(' AND ');
    }

    sql += ' ORDER BY kun_Firma';

    const result = await connection.query(sql, params);
    return result;
  } finally {
    await connection.close();
  }
}

/**
 * Holt einen Kunden nach ID
 */
export async function getKundeById(id) {
  const connection = await getFrontendConnection();
  try {
    const result = await connection.query(
      'SELECT * FROM tbl_KD_Kundenstamm WHERE kun_ID = ?',
      [id]
    );
    return result.length > 0 ? result[0] : null;
  } finally {
    await connection.close();
  }
}

/**
 * Erstellt neuen Kunden
 */
export async function createKunde(data) {
  const connection = await getFrontendConnection();
  try {
    // Generiere neue ID (Max-ID + 1)
    const maxIdResult = await connection.query('SELECT MAX(kun_ID) AS MaxID FROM tbl_KD_Kundenstamm');
    const newId = (maxIdResult[0]?.MaxID || 0) + 1;

    const now = new Date();
    const userName = 'Claude'; // TODO: Von Auth-System holen

    const result = await connection.query(
      `INSERT INTO tbl_KD_Kundenstamm (
        kun_ID, kun_Firma, kun_Matchcode, kun_bezeichnung, kun_IstAktiv,
        kun_strasse, kun_plz, kun_ort, kun_LKZ,
        kun_telefon, kun_telefax, kun_mobil, kun_email, kun_URL,
        kun_kreditinstitut, kun_blz, kun_kontonummer, kun_iban, kun_bic, kun_ustidnr,
        kun_Zahlbed, kun_IstSammelRechnung, kun_Sortfeld,
        kun_IDF_PersonID, kun_Anschreiben, kun_BriefKopf, kun_ans_manuell,
        kun_land_vorwahl, kun_geloescht, kun_memo, TabellenNr,
        Erstellt_am, Erstellt_von, Aend_am, Aend_von
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        newId,
        data.kun_Firma || 'Neuer Kunde',
        data.kun_Matchcode || '',
        data.kun_bezeichnung || '',
        data.kun_IstAktiv !== undefined ? data.kun_IstAktiv : true,
        data.kun_strasse || '',
        data.kun_plz || '',
        data.kun_ort || '',
        data.kun_LKZ || 'DE',
        data.kun_telefon || '',
        data.kun_telefax || '',
        data.kun_mobil || '',
        data.kun_email || '',
        data.kun_URL || '',
        data.kun_kreditinstitut || '',
        data.kun_blz || '',
        data.kun_kontonummer || '',
        data.kun_iban || '',
        data.kun_bic || '',
        data.kun_ustidnr || '',
        data.kun_Zahlbed || null,
        data.kun_IstSammelRechnung || false,
        data.kun_Sortfeld || '',
        data.kun_IDF_PersonID || null,
        data.kun_Anschreiben || '',
        data.kun_BriefKopf || '',
        data.kun_ans_manuell || false,
        data.kun_land_vorwahl || '',
        data.kun_geloescht || '',
        data.kun_memo || '',
        data.TabellenNr || 2, // 2 = Kunden-Tabelle
        now,
        userName,
        now,
        userName,
      ]
    );

    return {
      kun_ID: newId,
      ...data,
      Erstellt_am: now,
      Erstellt_von: userName,
      Aend_am: now,
      Aend_von: userName,
    };
  } finally {
    await connection.close();
  }
}

/**
 * Aktualisiert einen Kunden
 */
export async function updateKunde(id, data) {
  const connection = await getFrontendConnection();
  try {
    const now = new Date();
    const userName = 'Claude'; // TODO: Von Auth-System holen

    // Baue UPDATE-Statement dynamisch (nur übergebene Felder)
    const fields = [];
    const params = [];

    Object.keys(data).forEach(key => {
      if (key !== 'kun_ID') { // ID nicht ändern
        fields.push(`${key} = ?`);
        params.push(data[key]);
      }
    });

    // Füge Änderungsdatum hinzu
    fields.push('Aend_am = ?', 'Aend_von = ?');
    params.push(now, userName);

    // ID für WHERE-Clause
    params.push(id);

    const sql = `UPDATE tbl_KD_Kundenstamm SET ${fields.join(', ')} WHERE kun_ID = ?`;

    await connection.query(sql, params);

    return {
      kun_ID: id,
      ...data,
      Aend_am: now,
      Aend_von: userName,
    };
  } finally {
    await connection.close();
  }
}

/**
 * Löscht einen Kunden (Soft-Delete)
 */
export async function deleteKunde(id) {
  const connection = await getFrontendConnection();
  try {
    const now = new Date();

    // Soft-Delete: Setze kun_geloescht und kun_IstAktiv
    await connection.query(
      `UPDATE tbl_KD_Kundenstamm
       SET kun_geloescht = ?, kun_IstAktiv = False, Aend_am = ?, Aend_von = ?
       WHERE kun_ID = ?`,
      [now.toISOString(), now, 'Claude', id]
    );

    return { success: true, kun_ID: id };
  } finally {
    await connection.close();
  }
}

/**
 * Holt Umsatz-Statistiken für einen Kunden
 * @param {Number} id - Kunden-ID
 * @returns {Object} { ges, vj, lj, lm } - Gesamt, Vorjahr, Lfd. Jahr, Akt. Monat
 */
export async function getKundeUmsatz(id) {
  const connection = await getFrontendConnection();
  try {
    const currentYear = new Date().getFullYear();
    const currentMonth = new Date().getMonth() + 1;
    const lastYear = currentYear - 1;

    // Gesamt-Umsatz
    const gesResult = await connection.query(
      `SELECT SUM(Zwi_Sum1) AS Umsatz
       FROM qry_KD_Auftragskopf
       WHERE kun_ID = ?`,
      [id]
    );

    // Vorjahres-Umsatz
    const vjResult = await connection.query(
      `SELECT SUM(Zwi_Sum1) AS Umsatz
       FROM qry_KD_Auftragskopf
       WHERE kun_ID = ? AND RchJahr = ?`,
      [id, lastYear]
    );

    // Laufendes Jahr
    const ljResult = await connection.query(
      `SELECT SUM(Zwi_Sum1) AS Umsatz
       FROM qry_KD_Auftragskopf
       WHERE kun_ID = ? AND RchJahr = ?`,
      [id, currentYear]
    );

    // Aktueller Monat
    const lmResult = await connection.query(
      `SELECT SUM(Zwi_Sum1) AS Umsatz
       FROM qry_KD_Auftragskopf
       WHERE kun_ID = ? AND RchMon = ?`,
      [id, currentMonth]
    );

    return {
      ges: gesResult[0]?.Umsatz || 0,
      vj: vjResult[0]?.Umsatz || 0,
      lj: ljResult[0]?.Umsatz || 0,
      lm: lmResult[0]?.Umsatz || 0,
    };
  } catch (err) {
    // Fallback: Query existiert nicht oder Fehler
    console.warn('Umsatz-Query fehlgeschlagen:', err.message);
    return {
      ges: 0,
      vj: 0,
      lj: 0,
      lm: 0,
    };
  } finally {
    await connection.close();
  }
}

export default {
  getAllKunden,
  getKundeById,
  createKunde,
  updateKunde,
  deleteKunde,
  getKundeUmsatz,
};
