/**
 * CONSYS Auftragsverwaltung - Preload Script
 * Stellt die API zwischen Main Process und Renderer bereit
 * 
 * Version 1.1.0 - 30.12.2025 - Mit Echtdaten-Unterstützung
 */

const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('api', {
    // ============================================
    // DATENBANK-STATUS
    // ============================================
    getDbStatus: () => ipcRenderer.invoke('get-db-status'),
    reconnectDb: () => ipcRenderer.invoke('reconnect-db'),
    
    // ============================================
    // AUFTRAG-OPERATIONEN
    // ============================================
    getAuftrag: (id) => ipcRenderer.invoke('get-auftrag', id),
    getAuftraegeList: (filter) => ipcRenderer.invoke('get-auftraege-list', filter),
    saveAuftrag: (data) => ipcRenderer.invoke('save-auftrag', data),
    deleteAuftrag: (id) => ipcRenderer.invoke('delete-auftrag', id),
    copyAuftrag: (id) => ipcRenderer.invoke('copy-auftrag', id),
    
    // ============================================
    // VA-DATUM & SCHICHTEN
    // ============================================
    getVaDatumList: (va_id) => ipcRenderer.invoke('get-va-datum-list', va_id),
    getSchichten: (va_id, vaDatum) => ipcRenderer.invoke('get-schichten', va_id, vaDatum),
    getMaZuordnung: (va_id, vaDatum) => ipcRenderer.invoke('get-ma-zuordnung', va_id, vaDatum),
    
    // ============================================
    // NAVIGATION
    // ============================================
    navigateFirst: () => ipcRenderer.invoke('navigate-first'),
    navigatePrev: () => ipcRenderer.invoke('navigate-prev'),
    navigateNext: () => ipcRenderer.invoke('navigate-next'),
    navigateLast: () => ipcRenderer.invoke('navigate-last'),
    
    // ============================================
    // MITARBEITER-OPERATIONEN
    // ============================================
    sendEinsatzliste: (type) => ipcRenderer.invoke('send-einsatzliste', type),
    openMitarbeiterauswahl: (va_id) => ipcRenderer.invoke('open-mitarbeiterauswahl', va_id),
    
    // ============================================
    // FORMULARE ÖFFNEN
    // ============================================
    openForm: (formName, params) => ipcRenderer.invoke('open-form', formName, params),
    
    // ============================================
    // LOOKUP-DATEN (COMBOS)
    // ============================================
    getKunden: () => ipcRenderer.invoke('get-kunden'),
    getObjekte: () => ipcRenderer.invoke('get-objekte'),
    getOrte: () => ipcRenderer.invoke('get-orte'),
    getStatus: () => ipcRenderer.invoke('get-status'),
    getDienstkleidung: () => ipcRenderer.invoke('get-dienstkleidung'),
    
    // ============================================
    // EVENT-LISTENER
    // ============================================
    onDbStatus: (callback) => {
        ipcRenderer.on('db-status', (event, data) => callback(data));
    },
    onDataUpdate: (callback) => {
        ipcRenderer.on('data-update', (event, data) => callback(data));
    },
    onNavigate: (callback) => {
        ipcRenderer.on('navigate', (event, data) => callback(data));
    },
    onSetVaId: (callback) => {
        ipcRenderer.on('set-va-id', (event, va_id) => callback(va_id));
    }
});

// Version info
contextBridge.exposeInMainWorld('appInfo', {
    version: '1.1.0',
    platform: process.platform,
    electron: process.versions.electron,
    node: process.versions.node,
    buildDate: '2025-12-30'
});

console.log('[Preload] API exposed to renderer');
