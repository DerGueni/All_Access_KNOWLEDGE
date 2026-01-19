/**
 * CONSYS Auftragsverwaltung - Electron Main Process
 * 1:1 Nachbildung von frm_VA_Auftragstamm
 * 
 * Mit ECHTER Access-Backend-Anbindung via ODBC
 * 
 * Version 1.1.0 - 30.12.2025
 */

const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');

// ODBC für Access-Backend
let odbc;
try {
    odbc = require('odbc');
} catch (e) {
    console.warn('ODBC-Modul nicht geladen, verwende Demo-Modus:', e.message);
    odbc = null;
}

// Entwicklungsmodus
const isDev = process.argv.includes('--dev');

// ============================================
// KONFIGURATION
// ============================================
const CONFIG = {
    // Access Backend Pfad
    ACCESS_BACKEND: 'S:\\CONSEC\\CONSEC PLANUNG AKTUELL\\Consec_BE_V1.55ANALYSETEST.accdb',
    // Alternative: lokale Kopie
    ACCESS_BACKEND_LOCAL: 'C:\\Users\\guenther.siegert\\Documents\\0006_All_Access_KNOWLEDGE\\00_Backend\\Consec_BE_local.accdb',
    // ODBC Connection String
    get connectionString() {
        return `Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=${this.ACCESS_BACKEND};`;
    }
};

// Datenbankverbindung
let dbConnection = null;
let useDemo = false;

// ============================================
// DEMO-DATEN (Fallback wenn kein ODBC)
// ============================================
const demoData = {
    auftraege: [
        { ID: 9152, Dat_VA_Von: '2025-12-12', Dat_VA_Bis: '2025-12-12', 
          Auftrag: 'Spvgg Greuther Fürth - Hertha Bsc', Ort: 'Fürth', 
          Objekt: 'Sportpark am Ronhof', Treffpunkt: '15 min vor DB vor Ort',
          Dienstkleidung: 'schwarz neutral', Veranst_Status_ID: 1, 
          Veranstalter_ID: 1, Ansprechpartner: '', PKW_Anzahl: 0, Fahrtkosten: 0 },
        { ID: 9153, Dat_VA_Von: '2025-12-13', Dat_VA_Bis: '2025-12-13', 
          Auftrag: '1. Fc Nürnberg Frauen', Ort: 'Nürnberg', 
          Objekt: 'Max Morlock Stadion', Treffpunkt: 'Haupteingang',
          Dienstkleidung: 'schwarz neutral', Veranst_Status_ID: 1,
          Veranstalter_ID: 2, Ansprechpartner: 'Herr Müller', PKW_Anzahl: 2, Fahrtkosten: 15 }
    ],
    kunden: [
        { kun_Id: 1, kun_Firma: 'SPVGG Greuther Fürth GmbH & Co. KG' },
        { kun_Id: 2, kun_Firma: '1. FC Nürnberg e.V.' },
        { kun_Id: 3, kun_Firma: 'Messe Nürnberg' }
    ],
    status: [
        { ID: 1, Fortschritt: 'In Planung' },
        { ID: 2, Fortschritt: 'Auftrag beendet' },
        { ID: 3, Fortschritt: 'Zeiten noch in Bearbeitung' }
    ]
};

let mainWindow;

// ============================================
// DATENBANK-VERBINDUNG
// ============================================
async function connectToDatabase() {
    if (!odbc) {
        console.log('[DB] ODBC nicht verfügbar - Demo-Modus aktiv');
        useDemo = true;
        return false;
    }

    try {
        console.log('[DB] Verbinde zu Access-Backend:', CONFIG.ACCESS_BACKEND);
        dbConnection = await odbc.connect(CONFIG.connectionString);
        console.log('[DB] Verbindung erfolgreich!');
        useDemo = false;
        return true;
    } catch (error) {
        console.error('[DB] Verbindungsfehler:', error.message);
        
        // Versuche lokale Kopie
        try {
            console.log('[DB] Versuche lokale Backend-Kopie...');
            const localConnStr = `Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=${CONFIG.ACCESS_BACKEND_LOCAL};`;
            dbConnection = await odbc.connect(localConnStr);
            console.log('[DB] Lokale Verbindung erfolgreich!');
            useDemo = false;
            return true;
        } catch (localError) {
            console.error('[DB] Auch lokale Verbindung fehlgeschlagen:', localError.message);
            useDemo = true;
            return false;
        }
    }
}

async function executeQuery(sql, params = []) {
    if (useDemo || !dbConnection) {
        console.log('[DB-DEMO] Query:', sql);
        return null;
    }

    try {
        console.log('[DB] Query:', sql.substring(0, 100) + '...');
        const result = await dbConnection.query(sql, params);
        return result;
    } catch (error) {
        console.error('[DB] Query-Fehler:', error.message);
        throw error;
    }
}

// ============================================
// FENSTER ERSTELLEN
// ============================================
function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1700,
        height: 950,
        minWidth: 1400,
        minHeight: 800,
        title: 'CONSYS - Auftragsverwaltung',
        icon: path.join(__dirname, 'assets', 'icon.svg'),
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        },
        backgroundColor: '#f0f0f0',
        show: false
    });

    mainWindow.loadFile('index.html');

    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
        if (isDev) {
            mainWindow.webContents.openDevTools();
        }
        // Status an Renderer senden
        mainWindow.webContents.send('db-status', { connected: !useDemo, demo: useDemo });
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

// ============================================
// APP START
// ============================================
app.whenReady().then(async () => {
    // Erst DB verbinden, dann Fenster öffnen
    await connectToDatabase();
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (dbConnection) {
        dbConnection.close();
    }
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// ============================================
// IPC HANDLER - Auftragsliste
// ============================================
ipcMain.handle('get-auftraege-list', async (event, filter) => {
    console.log('[IPC] get-auftraege-list', filter);
    
    if (useDemo) {
        let result = [...demoData.auftraege];
        if (filter?.datumAb) {
            result = result.filter(a => a.Dat_VA_Von >= filter.datumAb);
        }
        return result.map(a => ({
            ID: a.ID,
            Datum: formatDateShort(a.Dat_VA_Von),
            Auftrag: a.Auftrag,
            Ort: a.Ort
        }));
    }

    try {
        let sql = `
            SELECT TOP 100 
                tbl_VA_Auftragstamm.ID,
                tbl_VA_Auftragstamm.Dat_VA_Von,
                tbl_VA_Auftragstamm.Auftrag,
                tbl_VA_Auftragstamm.Ort
            FROM tbl_VA_Auftragstamm
        `;
        
        if (filter?.datumAb) {
            sql += ` WHERE tbl_VA_Auftragstamm.Dat_VA_Von >= #${filter.datumAb}#`;
        }
        
        sql += ` ORDER BY tbl_VA_Auftragstamm.Dat_VA_Von DESC, tbl_VA_Auftragstamm.ID DESC`;
        
        const result = await executeQuery(sql);
        
        return result.map(row => ({
            ID: row.ID,
            Datum: formatDateShort(row.Dat_VA_Von),
            Auftrag: row.Auftrag || '',
            Ort: row.Ort || ''
        }));
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Auftragsliste:', error);
        return [];
    }
});

// ============================================
// IPC HANDLER - Einzelnen Auftrag laden
// ============================================
ipcMain.handle('get-auftrag', async (event, id) => {
    console.log('[IPC] get-auftrag', id);
    
    if (useDemo) {
        return demoData.auftraege.find(a => a.ID === id) || demoData.auftraege[0];
    }

    try {
        const sql = `
            SELECT 
                tbl_VA_Auftragstamm.*,
                tbl_KD_Kundenstamm.kun_Firma
            FROM tbl_VA_Auftragstamm
            LEFT JOIN tbl_KD_Kundenstamm ON tbl_VA_Auftragstamm.Veranstalter_ID = tbl_KD_Kundenstamm.kun_Id
            WHERE tbl_VA_Auftragstamm.ID = ?
        `;
        
        const result = await executeQuery(sql, [id]);
        
        if (result && result.length > 0) {
            const row = result[0];
            return {
                ID: row.ID,
                Dat_VA_Von: row.Dat_VA_Von,
                Dat_VA_Bis: row.Dat_VA_Bis,
                Auftrag: row.Auftrag,
                Ort: row.Ort,
                Objekt: row.Objekt,
                Objekt_ID: row.Objekt_ID,
                Treffp_Zeit: row.Treffp_Zeit,
                Treffpunkt: row.Treffpunkt,
                PKW_Anzahl: row.PKW_Anzahl,
                Fahrtkosten: row.Fahrtkosten_pro_PKW || row.Fahrtkosten,
                Dienstkleidung: row.Dienstkleidung,
                Ansprechpartner: row.Ansprechpartner,
                Veranstalter_ID: row.Veranstalter_ID,
                Veranst_Status_ID: row.Veranst_Status_ID,
                Erst_von: row.Erst_von,
                Erst_am: row.Erst_am,
                Aend_von: row.Aend_von,
                Aend_am: row.Aend_am,
                Autosend_EL: row.Autosend_EL,
                Bemerkungen: row.Bemerkungen,
                kun_Firma: row.kun_Firma
            };
        }
        return null;
    } catch (error) {
        console.error('[IPC] Fehler beim Laden des Auftrags:', error);
        return null;
    }
});

// ============================================
// IPC HANDLER - Einsatztage laden
// ============================================
ipcMain.handle('get-va-datum-list', async (event, va_id) => {
    console.log('[IPC] get-va-datum-list', va_id);
    
    if (useDemo) {
        return [
            { VADatum: '2025-12-12', VADatum_ID: 1 },
            { VADatum: '2025-12-13', VADatum_ID: 2 }
        ];
    }

    try {
        const sql = `
            SELECT ID, VADatum 
            FROM tbl_VA_AnzTage 
            WHERE VA_ID = ? 
            ORDER BY VADatum
        `;
        
        const result = await executeQuery(sql, [va_id]);
        
        return result.map(row => ({
            VADatum_ID: row.ID,
            VADatum: row.VADatum
        }));
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der VA-Datum-Liste:', error);
        return [];
    }
});

// ============================================
// IPC HANDLER - Schichten laden
// ============================================
ipcMain.handle('get-schichten', async (event, va_id, vaDatum) => {
    console.log('[IPC] get-schichten', va_id, vaDatum);
    
    if (useDemo) {
        return [
            { Anzahl_Ist: 2, Anzahl_Soll: 40, Beginn: '15:00', Ende: '21:00' },
            { Anzahl_Ist: 0, Anzahl_Soll: 0, Beginn: '16:00', Ende: '21:00' }
        ];
    }

    try {
        let sql = `
            SELECT 
                tbl_VA_Start.ID,
                tbl_VA_Start.Anzahl_Ist,
                tbl_VA_Start.Anzahl_Soll,
                tbl_VA_Start.Beginn,
                tbl_VA_Start.Ende
            FROM tbl_VA_Start
            WHERE tbl_VA_Start.VA_ID = ?
        `;
        
        const params = [va_id];
        
        if (vaDatum) {
            sql += ` AND tbl_VA_Start.VADatum = ?`;
            params.push(vaDatum);
        }
        
        sql += ` ORDER BY tbl_VA_Start.Beginn`;
        
        const result = await executeQuery(sql, params);
        return result || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Schichten:', error);
        return [];
    }
});

// ============================================
// IPC HANDLER - MA-Zuordnung laden
// ============================================
ipcMain.handle('get-ma-zuordnung', async (event, va_id, vaDatum) => {
    console.log('[IPC] get-ma-zuordnung', va_id, vaDatum);
    
    if (useDemo) {
        return [
            { Lfd: 1, MA_ID: 707, Nachname: 'Alali', Vorname: 'Ahmad', von: '15:00', bis: '21:00', Stunden: 6 },
            { Lfd: 2, MA_ID: 708, Nachname: 'Müller', Vorname: 'Max', von: '15:00', bis: '21:00', Stunden: 6 }
        ];
    }

    try {
        let sql = `
            SELECT 
                tbl_MA_VA_Planung.Lfd,
                tbl_MA_VA_Planung.MA_ID,
                tbl_MA_Mitarbeiterstamm.Nachname,
                tbl_MA_Mitarbeiterstamm.Vorname,
                tbl_MA_VA_Planung.von,
                tbl_MA_VA_Planung.bis,
                tbl_MA_VA_Planung.Stunden
            FROM tbl_MA_VA_Planung
            INNER JOIN tbl_MA_Mitarbeiterstamm ON tbl_MA_VA_Planung.MA_ID = tbl_MA_Mitarbeiterstamm.ID
            WHERE tbl_MA_VA_Planung.VA_ID = ?
        `;
        
        const params = [va_id];
        
        if (vaDatum) {
            sql += ` AND tbl_MA_VA_Planung.VADatum = ?`;
            params.push(vaDatum);
        }
        
        sql += ` ORDER BY tbl_MA_VA_Planung.Lfd`;
        
        const result = await executeQuery(sql, params);
        return result || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der MA-Zuordnung:', error);
        return [];
    }
});

// ============================================
// IPC HANDLER - Lookup-Daten (Combos)
// ============================================
ipcMain.handle('get-kunden', async () => {
    if (useDemo) {
        return demoData.kunden;
    }

    try {
        const sql = `
            SELECT kun_Id, kun_Firma 
            FROM tbl_KD_Kundenstamm 
            WHERE kun_AdressArt = 1 AND kun_IstAktiv = True
            ORDER BY kun_Firma
        `;
        const result = await executeQuery(sql);
        return result || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Kunden:', error);
        return demoData.kunden;
    }
});

ipcMain.handle('get-status', async () => {
    if (useDemo) {
        return demoData.status;
    }

    try {
        const sql = `SELECT ID, Fortschritt FROM tbl_VA_Status ORDER BY ID`;
        const result = await executeQuery(sql);
        return result || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Status:', error);
        return demoData.status;
    }
});

ipcMain.handle('get-orte', async () => {
    if (useDemo) {
        return ['Nürnberg', 'Fürth', 'Erlangen', 'Altdorf'];
    }

    try {
        const sql = `
            SELECT DISTINCT Ort 
            FROM tbl_VA_Auftragstamm 
            WHERE Len(Trim(Nz(Ort))) > 0
            ORDER BY Ort
        `;
        const result = await executeQuery(sql);
        return result?.map(r => r.Ort) || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Orte:', error);
        return [];
    }
});

ipcMain.handle('get-objekte', async () => {
    if (useDemo) {
        return [
            { ID: 1, Objekt: 'Max Morlock Stadion' },
            { ID: 2, Objekt: 'Sportpark am Ronhof' }
        ];
    }

    try {
        const sql = `
            SELECT ID, Objekt 
            FROM tbl_OB_Objekt 
            ORDER BY Objekt
        `;
        const result = await executeQuery(sql);
        return result || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Objekte:', error);
        return [];
    }
});

ipcMain.handle('get-dienstkleidung', async () => {
    if (useDemo) {
        return ['schwarz neutral', 'schwarz elegant', 'Jacke CONSEC'];
    }

    try {
        const sql = `
            SELECT DISTINCT Dienstkleidung 
            FROM tbl_VA_Auftragstamm 
            WHERE Len(Trim(Nz(Dienstkleidung))) > 0
            ORDER BY Dienstkleidung
        `;
        const result = await executeQuery(sql);
        return result?.map(r => r.Dienstkleidung) || [];
    } catch (error) {
        console.error('[IPC] Fehler beim Laden der Dienstkleidung:', error);
        return [];
    }
});

// ============================================
// IPC HANDLER - Speichern
// ============================================
ipcMain.handle('save-auftrag', async (event, data) => {
    console.log('[IPC] save-auftrag', data);
    
    if (useDemo) {
        return { success: true, message: 'Demo-Modus: Speichern simuliert', id: data.ID };
    }

    try {
        if (data.ID) {
            // UPDATE
            const sql = `
                UPDATE tbl_VA_Auftragstamm SET
                    Dat_VA_Von = ?,
                    Dat_VA_Bis = ?,
                    Auftrag = ?,
                    Ort = ?,
                    Objekt = ?,
                    Objekt_ID = ?,
                    Treffp_Zeit = ?,
                    Treffpunkt = ?,
                    PKW_Anzahl = ?,
                    Fahrtkosten_pro_PKW = ?,
                    Dienstkleidung = ?,
                    Ansprechpartner = ?,
                    Veranstalter_ID = ?,
                    Veranst_Status_ID = ?,
                    Bemerkungen = ?,
                    Aend_am = Now(),
                    Aend_von = ?
                WHERE ID = ?
            `;
            
            await executeQuery(sql, [
                data.Dat_VA_Von, data.Dat_VA_Bis, data.Auftrag, data.Ort,
                data.Objekt, data.Objekt_ID, data.Treffp_Zeit, data.Treffpunkt,
                data.PKW_Anzahl, data.Fahrtkosten, data.Dienstkleidung,
                data.Ansprechpartner, data.Veranstalter_ID, data.Veranst_Status_ID,
                data.Bemerkungen, 'electron_app', data.ID
            ]);
            
            return { success: true, message: 'Auftrag gespeichert', id: data.ID };
        } else {
            // INSERT - neue ID generieren
            const sql = `
                INSERT INTO tbl_VA_Auftragstamm 
                (Dat_VA_Von, Dat_VA_Bis, Auftrag, Ort, Objekt, Treffpunkt, 
                 Dienstkleidung, Veranstalter_ID, Veranst_Status_ID, Erst_am, Erst_von)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, Now(), ?)
            `;
            
            await executeQuery(sql, [
                data.Dat_VA_Von, data.Dat_VA_Bis, data.Auftrag, data.Ort,
                data.Objekt, data.Treffpunkt, data.Dienstkleidung,
                data.Veranstalter_ID, data.Veranst_Status_ID || 1, 'electron_app'
            ]);
            
            // Neue ID abrufen
            const idResult = await executeQuery('SELECT @@IDENTITY AS NewID');
            const newId = idResult?.[0]?.NewID;
            
            return { success: true, message: 'Auftrag erstellt', id: newId };
        }
    } catch (error) {
        console.error('[IPC] Fehler beim Speichern:', error);
        return { success: false, message: error.message };
    }
});

// ============================================
// IPC HANDLER - Löschen
// ============================================
ipcMain.handle('delete-auftrag', async (event, id) => {
    console.log('[IPC] delete-auftrag', id);
    
    const result = await dialog.showMessageBox(mainWindow, {
        type: 'warning',
        buttons: ['Abbrechen', 'Löschen'],
        defaultId: 0,
        title: 'Auftrag löschen',
        message: `Auftrag ${id} wirklich löschen?\n\nDiese Aktion kann nicht rückgängig gemacht werden.`
    });
    
    if (result.response !== 1) {
        return { success: false, message: 'Abgebrochen' };
    }
    
    if (useDemo) {
        const index = demoData.auftraege.findIndex(a => a.ID === id);
        if (index >= 0) {
            demoData.auftraege.splice(index, 1);
        }
        return { success: true, message: 'Demo: Auftrag gelöscht' };
    }

    try {
        await executeQuery('DELETE FROM tbl_VA_Auftragstamm WHERE ID = ?', [id]);
        return { success: true, message: 'Auftrag gelöscht' };
    } catch (error) {
        console.error('[IPC] Fehler beim Löschen:', error);
        return { success: false, message: error.message };
    }
});

// ============================================
// IPC HANDLER - Kopieren
// ============================================
ipcMain.handle('copy-auftrag', async (event, id) => {
    console.log('[IPC] copy-auftrag', id);
    
    if (useDemo) {
        const auftrag = demoData.auftraege.find(a => a.ID === id);
        if (auftrag) {
            const newId = Math.max(...demoData.auftraege.map(a => a.ID)) + 1;
            const newAuftrag = { ...auftrag, ID: newId, Auftrag: auftrag.Auftrag + ' (Kopie)' };
            demoData.auftraege.push(newAuftrag);
            return { success: true, id: newId };
        }
        return { success: false, message: 'Auftrag nicht gefunden' };
    }

    try {
        // Original laden
        const original = await executeQuery('SELECT * FROM tbl_VA_Auftragstamm WHERE ID = ?', [id]);
        if (!original || original.length === 0) {
            return { success: false, message: 'Auftrag nicht gefunden' };
        }
        
        const row = original[0];
        
        // Kopie erstellen
        const sql = `
            INSERT INTO tbl_VA_Auftragstamm 
            (Dat_VA_Von, Dat_VA_Bis, Auftrag, Ort, Objekt, Objekt_ID, Treffpunkt, Treffp_Zeit,
             Dienstkleidung, Ansprechpartner, Veranstalter_ID, Veranst_Status_ID, 
             Bemerkungen, Erst_am, Erst_von)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, Now(), ?)
        `;
        
        await executeQuery(sql, [
            row.Dat_VA_Von, row.Dat_VA_Bis, row.Auftrag + ' (Kopie)', row.Ort,
            row.Objekt, row.Objekt_ID, row.Treffpunkt, row.Treffp_Zeit,
            row.Dienstkleidung, row.Ansprechpartner, row.Veranstalter_ID,
            row.Bemerkungen, 'electron_app'
        ]);
        
        const idResult = await executeQuery('SELECT @@IDENTITY AS NewID');
        const newId = idResult?.[0]?.NewID;
        
        return { success: true, id: newId, message: 'Auftrag kopiert' };
    } catch (error) {
        console.error('[IPC] Fehler beim Kopieren:', error);
        return { success: false, message: error.message };
    }
});

// ============================================
// IPC HANDLER - DB Status
// ============================================
ipcMain.handle('get-db-status', async () => {
    return {
        connected: !useDemo,
        demo: useDemo,
        backend: useDemo ? 'Demo-Daten' : CONFIG.ACCESS_BACKEND
    };
});

ipcMain.handle('reconnect-db', async () => {
    const success = await connectToDatabase();
    if (mainWindow) {
        mainWindow.webContents.send('db-status', { connected: success, demo: !success });
    }
    return { success, demo: !success };
});

// ============================================
// IPC HANDLER - Mitarbeiterauswahl
// ============================================
ipcMain.handle('open-mitarbeiterauswahl', async (event, va_id) => {
    console.log('[IPC] open-mitarbeiterauswahl', va_id);
    
    // Neues Fenster für Mitarbeiterauswahl
    const childWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        parent: mainWindow,
        modal: true,
        title: 'Mitarbeiterauswahl',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        }
    });
    
    childWindow.loadFile('mitarbeiterauswahl.html');
    
    // VA_ID an Fenster senden wenn bereit
    childWindow.webContents.once('did-finish-load', () => {
        childWindow.webContents.send('set-va-id', va_id);
    });
    
    return { success: true };
});

// ============================================
// HELPER FUNKTIONEN
// ============================================
function formatDateShort(dateValue) {
    if (!dateValue) return '';
    
    let date;
    if (dateValue instanceof Date) {
        date = dateValue;
    } else if (typeof dateValue === 'string') {
        if (dateValue.includes('.')) {
            const parts = dateValue.split('.');
            date = new Date(parts[2], parts[1] - 1, parts[0]);
        } else {
            date = new Date(dateValue);
        }
    } else {
        return dateValue;
    }
    
    if (isNaN(date.getTime())) return dateValue;
    
    const days = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = String(date.getFullYear()).substring(2);
    
    return `${days[date.getDay()]}. ${day}.${month}.${year}`;
}
