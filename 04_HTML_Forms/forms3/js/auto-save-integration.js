/**
 * auto-save-integration.js
 * Integration von AutoSave in bestehende Formulare
 *
 * Dieser Code ergänzt die bestehenden Logic-Dateien um Auto-Save-Funktionalität
 * OHNE die originalen Dateien zu verändern.
 *
 * Erstellt: 2026-01-15
 */

import { AutoSaveManager } from './auto-save.js';
import { Bridge } from '../api/bridgeClient.js';

/**
 * AutoSave für Auftragstamm-Formular
 */
export function initAutoSaveAuftragstamm(state) {
    const autoSave = new AutoSaveManager({
        debounceMs: 500,
        statusElementId: 'saveStatus',
        trackFields: [
            'Auftrag', 'Ort', 'Objekt', 'Objekt_ID',
            'Dat_VA_Von', 'Dat_VA_Bis',
            'Treffpunkt', 'Treffp_Zeit',
            'PKW_Anzahl', 'Fahrtkosten',
            'Dienstkleidung', 'Ansprechpartner',
            'Veranstalter_ID', 'Veranst_Status_ID',
            'Bemerkungen', 'cbAutosendEL'
        ],
        onSave: async (data) => {
            if (!state.currentVA_ID) {
                console.warn('[AutoSave-Auftragstamm] Kein Auftrag geladen - Speichern übersprungen');
                return null;
            }

            // Daten-Mapping: HTML-IDs zu Backend-Feldern
            const payload = {
                VA_ID: state.currentVA_ID,
                VA_Bezeichnung: data.Auftrag,
                VA_Ort: data.Ort,
                VA_Objekt: data.Objekt,
                VA_Objekt_ID: data.Objekt_ID,
                VA_DatumVon: data.Dat_VA_Von,
                VA_DatumBis: data.Dat_VA_Bis,
                VA_Treffpunkt: data.Treffpunkt,
                VA_Treffp_Zeit: data.Treffp_Zeit,
                VA_PKW_Anzahl: parseInt(data.PKW_Anzahl) || 0,
                VA_Fahrtkosten: parseFloat(data.Fahrtkosten) || 0,
                VA_Dienstkleidung: data.Dienstkleidung,
                VA_Ansprechpartner: data.Ansprechpartner,
                VA_KD_ID: parseInt(data.Veranstalter_ID) || null,
                VA_Status: parseInt(data.Veranst_Status_ID) || 0,
                VA_Bemerkung: data.Bemerkungen,
                VA_AutosendEL: data.cbAutosendEL ? 1 : 0
            };

            console.log('[AutoSave-Auftragstamm] Speichere:', payload);

            // Speichern via Bridge
            const result = await Bridge.execute('updateAuftrag', payload);

            return result.data;
        },
        onConflict: (local, remote) => {
            // Einfache Strategie: Lokale Änderungen haben Vorrang
            // Aber User fragen ob überschreiben
            return local;
        },
        showToast: true,
        debug: false
    });

    return autoSave;
}

/**
 * AutoSave für Mitarbeiterstamm-Formular
 */
export function initAutoSaveMitarbeiterstamm(state) {
    const autoSave = new AutoSaveManager({
        debounceMs: 500,
        statusElementId: 'saveStatus',
        trackFields: [
            'MA_Nachname', 'MA_Vorname',
            'MA_Strasse', 'MA_PLZ', 'MA_Ort',
            'MA_TelMobil', 'MA_TelFestnetz', 'MA_Email',
            'MA_Geburtsdatum', 'MA_Anstellung', 'MA_Aktiv'
        ],
        onSave: async (data) => {
            const currentId = state.currentId || state.currentRecord?.MA_ID || state.currentRecord?.ID;

            if (!currentId) {
                console.warn('[AutoSave-Mitarbeiterstamm] Kein MA geladen');
                return null;
            }

            const payload = {
                MA_ID: currentId,
                MA_Nachname: data.MA_Nachname,
                MA_Vorname: data.MA_Vorname,
                MA_Strasse: data.MA_Strasse,
                MA_PLZ: data.MA_PLZ,
                MA_Ort: data.MA_Ort,
                MA_TelMobil: data.MA_TelMobil,
                MA_TelFestnetz: data.MA_TelFestnetz,
                MA_Email: data.MA_Email,
                MA_Geburtsdatum: data.MA_Geburtsdatum,
                MA_Anstellung: data.MA_Anstellung,
                MA_Aktiv: data.MA_Aktiv ? 1 : 0
            };

            console.log('[AutoSave-Mitarbeiterstamm] Speichere:', payload);

            const result = await Bridge.mitarbeiter.update(currentId, payload);
            return result.data || result;
        },
        showToast: true,
        debug: false
    });

    return autoSave;
}

/**
 * AutoSave für Kundenstamm-Formular
 */
export function initAutoSaveKundenstamm(state) {
    const autoSave = new AutoSaveManager({
        debounceMs: 500,
        statusElementId: 'saveStatus',
        trackFields: [
            'KD_Kuerzel', 'KD_Name1', 'KD_Name2',
            'KD_Strasse', 'KD_PLZ', 'KD_Ort', 'KD_Land',
            'KD_Telefon', 'KD_Fax', 'KD_Email', 'KD_Web',
            'KD_UStIDNr', 'KD_Zahlungsbedingung',
            'KD_AP_Name', 'KD_AP_Position', 'KD_AP_Telefon', 'KD_AP_Email',
            'KD_Bemerkungen', 'KD_IstAktiv',
            'KD_Rabatt', 'KD_Skonto', 'KD_SkontoTage'
        ],
        onSave: async (data) => {
            const currentId = state.currentRecord?.KD_ID || state.currentRecord?.kun_Id;

            if (!currentId) {
                console.warn('[AutoSave-Kundenstamm] Kein Kunde geladen');
                return null;
            }

            const payload = {
                KD_ID: currentId,
                KD_Kuerzel: data.KD_Kuerzel,
                KD_Name1: data.KD_Name1,
                KD_Name2: data.KD_Name2,
                KD_Strasse: data.KD_Strasse,
                KD_PLZ: data.KD_PLZ,
                KD_Ort: data.KD_Ort,
                KD_Land: data.KD_Land,
                KD_Telefon: data.KD_Telefon,
                KD_Fax: data.KD_Fax,
                KD_Email: data.KD_Email,
                KD_Web: data.KD_Web,
                KD_UStIDNr: data.KD_UStIDNr,
                KD_Zahlungsbedingung: data.KD_Zahlungsbedingung,
                KD_AP_Name: data.KD_AP_Name,
                KD_AP_Position: data.KD_AP_Position,
                KD_AP_Telefon: data.KD_AP_Telefon,
                KD_AP_Email: data.KD_AP_Email,
                KD_Bemerkungen: data.KD_Bemerkungen,
                KD_IstAktiv: data.KD_IstAktiv ? 1 : 0,
                KD_Rabatt: parseFloat(data.KD_Rabatt) || 0,
                KD_Skonto: parseFloat(data.KD_Skonto) || 0,
                KD_SkontoTage: parseInt(data.KD_SkontoTage) || 0
            };

            console.log('[AutoSave-Kundenstamm] Speichere:', payload);

            const result = await Bridge.kunden.update(currentId, payload);
            return result.data || result;
        },
        showToast: true,
        debug: false
    });

    return autoSave;
}

/**
 * AutoSave für Objekt-Formular
 */
export function initAutoSaveObjekt(state) {
    const autoSave = new AutoSaveManager({
        debounceMs: 500,
        statusElementId: 'saveStatus',
        trackFields: [
            'Objekt_Name', 'Objekt_Strasse', 'Objekt_PLZ', 'Objekt_Ort',
            'Objekt_Status', 'Objekt_Kunde', 'Objekt_Ansprechpartner',
            'Objekt_Telefon', 'Objekt_Email', 'Objekt_Bemerkungen'
        ],
        onSave: async (data) => {
            const currentId = state.currentRecord?.Objekt_ID || state.currentRecord?.ID;

            if (!currentId) {
                console.warn('[AutoSave-Objekt] Kein Objekt geladen');
                return null;
            }

            const payload = {
                Objekt_ID: currentId,
                Objekt_Name: data.Objekt_Name,
                Objekt_Strasse: data.Objekt_Strasse,
                Objekt_PLZ: data.Objekt_PLZ,
                Objekt_Ort: data.Objekt_Ort,
                Objekt_Status: data.Objekt_Status,
                Objekt_Kunde: parseInt(data.Objekt_Kunde) || null,
                Objekt_Ansprechpartner: data.Objekt_Ansprechpartner,
                Objekt_Telefon: data.Objekt_Telefon,
                Objekt_Email: data.Objekt_Email,
                Objekt_Bemerkungen: data.Objekt_Bemerkungen
            };

            console.log('[AutoSave-Objekt] Speichere:', payload);

            const result = await Bridge.objekte.update(currentId, payload);
            return result.data || result;
        },
        showToast: true,
        debug: false
    });

    return autoSave;
}

/**
 * Utility: AutoSave Status-Element in Formular-Footer einfügen
 */
export function injectAutoSaveStatus() {
    // Suche nach Footer-Bereich
    const footer = document.querySelector('.form-footer, .status-bar, footer, .app-footer');

    if (footer) {
        // Prüfe ob bereits vorhanden
        if (!document.getElementById('saveStatus')) {
            const statusSpan = document.createElement('span');
            statusSpan.id = 'saveStatus';
            statusSpan.className = 'save-status';
            statusSpan.style.cssText = 'margin-left: auto; padding: 4px 8px; font-size: 12px;';
            footer.appendChild(statusSpan);
        }
    } else {
        console.warn('[AutoSave] Kein Footer-Element gefunden - Status-Element wird nicht injiziert');
    }
}

// Globaler Zugriff
window.AutoSaveIntegration = {
    initAutoSaveAuftragstamm,
    initAutoSaveMitarbeiterstamm,
    initAutoSaveKundenstamm,
    initAutoSaveObjekt,
    injectAutoSaveStatus
};
