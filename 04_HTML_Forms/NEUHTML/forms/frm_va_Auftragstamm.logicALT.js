/**
 * frm_va_Auftragstamm.logic.js
 *
 * Logik-Modul für das Formular "Auftragsverwaltung"
 * Basiert auf: frm_va_Auftragstamm.spec.json
 *
 * Backend-Anbindung: Access Bridge (localhost:5000/api)
 * Import: bridgeClient.js
 */

'use strict';

import { Bridge } from "../api/bridgeClient.js";

// ============================================================
// FORM CONTROLLER
// ============================================================
const FormController = (function() {

    // Aktueller Datensatz
    let currentRecord = null;
    let currentRecordId = null;
    let currentVADatumId = null;
    let isDirty = false;

    // Recordset-Navigation
    let recordset = [];
    let recordIndex = -1;

    // ========================================================
    // INITIALIZATION
    // ========================================================

    function init() {
        console.log('[FormController] Initialisierung...');

        // Event-Handler binden
        bindButtonHandlers();
        bindFieldEvents();
        bindTabEvents();
        bindNavigationEvents();

        // Subforms initialisieren
        SubformManager.init();

        // Initiales Laden
        Form_Open();
        Form_Load();

        console.log('[FormController] Initialisierung abgeschlossen.');
    }

    // ========================================================
    // FORM EVENTS (aus VBA)
    // ========================================================

    /**
     * Form_Open - Wird beim Öffnen des Formulars aufgerufen
     * VBA: Private Sub Form_Open(Cancel As Integer)
     */
    function Form_Open() {
        console.log('[Form_Open] Formular wird geöffnet...');

        // Datum-Label aktualisieren
        const lblDatum = document.getElementById('lbl_Datum');
        if (lblDatum) {
            lblDatum.textContent = formatDate(new Date());
        }

        // Comboboxen initialisieren
        loadComboboxData();

        // Auftragsliste laden (zsub_lstAuftrag)
        SubformManager.refresh('zsub_lstAuftrag');
    }

    /**
     * Form_Load - Wird nach dem Öffnen aufgerufen
     * VBA: Private Sub Form_Load()
     */
    function Form_Load() {
        console.log('[Form_Load] Formulardaten werden geladen...');

        // Letzten Datensatz laden (Standard-Verhalten)
        VAOpen_LastDS();
    }

    /**
     * Form_Current - Wird bei Datensatzwechsel aufgerufen
     * VBA: Private Sub Form_Current()
     */
    function Form_Current() {
        console.log('[Form_Current] Datensatz gewechselt:', currentRecordId);

        if (!currentRecord) return;

        // Felder befüllen
        populateFields(currentRecord);

        // cboVADatum aktualisieren
        loadVADatumCombo(currentRecordId);

        // Subforms aktualisieren
        refreshAllSubforms();

        isDirty = false;
    }

    /**
     * Form_BeforeUpdate - Vor dem Speichern
     * VBA: Private Sub Form_BeforeUpdate(Cancel As Integer)
     */
    function Form_BeforeUpdate() {
        console.log('[Form_BeforeUpdate] Validierung vor Speichern...');

        // Validierung hier einfügen
        const isValid = validateRecord();

        if (!isValid) {
            console.warn('[Form_BeforeUpdate] Validierung fehlgeschlagen');
            return false;
        }

        return true;
    }

    /**
     * Form_BeforeDelConfirm - Vor dem Löschen
     * VBA: Private Sub Form_BeforeDelConfirm(Cancel As Integer, response As Integer)
     */
    function Form_BeforeDelConfirm() {
        console.log('[Form_BeforeDelConfirm] Löschbestätigung...');
        return confirm('Möchten Sie diesen Auftrag wirklich löschen?');
    }

    // ========================================================
    // RECORD OPERATIONS (Bridge-Aufrufe)
    // ========================================================

    /**
     * Datensatz laden
     * @param {number} id - Auftrag-ID
     */
    async function loadRecord(id) {
        console.log('[loadRecord] Lade Datensatz:', id);

        try {
            const response = await Bridge.loadAuftrag(id);
            currentRecord = response.data || response;
            currentRecordId = id;

            Form_Current();

        } catch (error) {
            console.error('[loadRecord] Fehler:', error);
            alert('Fehler beim Laden des Datensatzes');
        }
    }

    /**
     * Datensatz speichern
     */
    async function saveRecord() {
        console.log('[saveRecord] Speichere Datensatz...');

        if (!Form_BeforeUpdate()) {
            return false;
        }

        try {
            const data = collectFieldData();

            await Bridge.saveAuftrag(data);

            isDirty = false;
            console.log('[saveRecord] Datensatz gespeichert');
            return true;

        } catch (error) {
            console.error('[saveRecord] Fehler:', error);
            alert('Fehler beim Speichern');
            return false;
        }
    }

    /**
     * Neuen Datensatz erstellen
     */
    async function createRecord() {
        console.log('[createRecord] Neuer Datensatz...');

        if (isDirty) {
            const save = confirm('Änderungen speichern?');
            if (save) await saveRecord();
        }

        try {
            const response = await Bridge.saveAuftrag({ _new: true });
            const newId = response.ID || response.id || response.data?.ID;

            if (newId) {
                await loadRecord(newId);
                // Auftragsliste aktualisieren
                SubformManager.refresh('zsub_lstAuftrag');
            }

        } catch (error) {
            console.error('[createRecord] Fehler:', error);
            alert('Fehler beim Erstellen');
        }
    }

    /**
     * Datensatz löschen
     */
    async function deleteRecord() {
        console.log('[deleteRecord] Lösche Datensatz...');

        if (!Form_BeforeDelConfirm()) {
            return;
        }

        try {
            await Bridge.deleteAuftrag(currentRecordId);

            // Auftragsliste aktualisieren
            SubformManager.refresh('zsub_lstAuftrag');

            // Zum vorherigen Datensatz navigieren
            navigatePrevious();

        } catch (error) {
            console.error('[deleteRecord] Fehler:', error);
            alert('Fehler beim Löschen');
        }
    }

    /**
     * Datensatz kopieren
     */
    async function copyRecord() {
        console.log('[copyRecord] Kopiere Auftrag...');

        try {
            // Kopieren über speziellen Aufruf
            const response = await Bridge.saveAuftrag({
                _copy: true,
                _sourceId: currentRecordId
            });
            const newId = response.ID || response.id || response.data?.ID;

            if (newId) {
                await loadRecord(newId);
                // Auftragsliste aktualisieren
                SubformManager.refresh('zsub_lstAuftrag');
                alert('Auftrag wurde kopiert. Neue ID: ' + newId);
            }

        } catch (error) {
            console.error('[copyRecord] Fehler:', error);
            alert('Fehler beim Kopieren');
        }
    }

    // ========================================================
    // NAVIGATION
    // ========================================================

    function navigateFirst() {
        console.log('[navigateFirst]');
        if (recordset.length > 0) {
            recordIndex = 0;
            loadRecord(recordset[recordIndex].ID);
        }
    }

    function navigatePrevious() {
        console.log('[navigatePrevious]');
        if (recordIndex > 0) {
            recordIndex--;
            loadRecord(recordset[recordIndex].ID);
        }
    }

    function navigateNext() {
        console.log('[navigateNext]');
        if (recordIndex < recordset.length - 1) {
            recordIndex++;
            loadRecord(recordset[recordIndex].ID);
        }
    }

    function navigateLast() {
        console.log('[navigateLast]');
        if (recordset.length > 0) {
            recordIndex = recordset.length - 1;
            loadRecord(recordset[recordIndex].ID);
        }
    }

    /**
     * VAOpen_LastDS - Letzten Datensatz öffnen
     * VBA: Public Function VAOpen_LastDS()
     */
    async function VAOpen_LastDS() {
        console.log('[VAOpen_LastDS]');

        try {
            const response = await Bridge.listAuftraege({});
            recordset = response.items || response.data || response || [];
            if (recordset.length > 0) {
                navigateLast();
            }
        } catch (error) {
            console.error('[VAOpen_LastDS] Fehler:', error);
        }
    }

    /**
     * VAOpen - Bestimmten Auftrag öffnen
     * VBA: Public Function VAOpen(iVA_ID As Long, iVADatum_ID As Long)
     */
    async function VAOpen(vaId, vaDatumId) {
        console.log('[VAOpen]', vaId, vaDatumId);

        await loadRecord(vaId);

        if (vaDatumId) {
            currentVADatumId = vaDatumId;
            const cboVADatum = document.getElementById('cboVADatum');
            if (cboVADatum) {
                cboVADatum.value = vaDatumId;
                cboVADatum_AfterUpdate();
            }
        }
    }

    // ========================================================
    // DATUM NAVIGATION
    // ========================================================

    function btnDatumLeft_Click() {
        console.log('[btnDatumLeft_Click] Vorheriges Datum');
        const cbo = document.getElementById('cboVADatum');
        if (cbo && cbo.selectedIndex > 0) {
            cbo.selectedIndex--;
            cboVADatum_AfterUpdate();
        }
    }

    function btnDatumRight_Click() {
        console.log('[btnDatumRight_Click] Nächstes Datum');
        const cbo = document.getElementById('cboVADatum');
        if (cbo && cbo.selectedIndex < cbo.options.length - 1) {
            cbo.selectedIndex++;
            cboVADatum_AfterUpdate();
        }
    }

    function cboVADatum_AfterUpdate() {
        console.log('[cboVADatum_AfterUpdate]');
        const cbo = document.getElementById('cboVADatum');
        if (cbo) {
            currentVADatumId = cbo.value;

            // Subforms mit neuem Datum aktualisieren
            SubformManager.refresh('sub_VA_Start');
            SubformManager.refresh('sub_MA_VA_Zuordnung');
            SubformManager.refresh('sub_MA_VA_Planung_Absage');
            SubformManager.refresh('sub_MA_VA_Zuordnung_Status');
        }
    }

    // ========================================================
    // AUFTRAGSLISTE FILTER
    // ========================================================

    function btn_AbWann_Click() {
        console.log('[btn_AbWann_Click]');
        const auftraegeAb = document.getElementById('Auftraege_ab');
        const istStatus = document.getElementById('IstStatus');

        if (auftraegeAb && auftraegeAb.value) {
            const statusValue = istStatus ? istStatus.value : -5;
            filterAuftragsliste(auftraegeAb.value, statusValue);
        }
    }

    function btnHeute_Click() {
        console.log('[btnHeute_Click]');
        const heute = formatDate(new Date());
        document.getElementById('Auftraege_ab').value = heute;
        filterAuftragsliste(heute, getStatusFilter());
    }

    function btnTgBack_Click() {
        console.log('[btnTgBack_Click]');
        adjustAuftraegeAbDate(-1);
    }

    function btnTgVor_Click() {
        console.log('[btnTgVor_Click]');
        adjustAuftraegeAbDate(1);
    }

    function adjustAuftraegeAbDate(days) {
        const input = document.getElementById('Auftraege_ab');
        if (input && input.value) {
            const date = parseDate(input.value);
            if (date) {
                date.setDate(date.getDate() + days);
                input.value = formatDate(date);
                filterAuftragsliste(input.value, getStatusFilter());
            }
        }
    }

    function getStatusFilter() {
        const istStatus = document.getElementById('IstStatus');
        return istStatus ? (istStatus.value || -5) : -5;
    }

    /**
     * Filter Auftragsliste - nutzt Bridge.listAuftraege
     * @param {string} abDatum - Datum ab dem gefiltert wird
     * @param {number} status - Status-Filter (-5 = alle)
     */
    async function filterAuftragsliste(abDatum, status) {
        console.log('[filterAuftragsliste] Ab:', abDatum, 'Status:', status);

        try {
            const filter = { abDatum: abDatum };
            if (status && status != -5) {
                filter.status = status;
            }

            const response = await Bridge.listAuftraege(filter);
            recordset = response.items || response.data || response || [];

            // Subform mit Filter-Parametern aktualisieren
            SubformManager.refresh('zsub_lstAuftrag', filter);
        } catch (error) {
            console.error('[filterAuftragsliste] Fehler:', error);
        }
    }

    // ========================================================
    // BUTTON HANDLERS BINDING
    // ========================================================

    function bindButtonHandlers() {
        console.log('[bindButtonHandlers] Binde Button-Handler...');

        // Navigation
        bindClick('Befehl43', navigateFirst);
        bindClick('Befehl41', navigatePrevious);
        bindClick('Befehl40', navigateNext);
        bindClick('btn_letzer_Datensatz', navigateLast);
        bindClick('btn_rueck', () => { /* TODO: Rückgängig */ console.log('TODO: btn_rueck'); });

        // Datum-Navigation
        bindClick('btnDatumLeft', btnDatumLeft_Click);
        bindClick('btnDatumRight', btnDatumRight_Click);

        // Auftragsliste-Filter
        bindClick('btn_AbWann', btn_AbWann_Click);
        bindClick('btnHeute', btnHeute_Click);
        bindClick('btnTgBack', btnTgBack_Click);
        bindClick('btnTgVor', btnTgVor_Click);

        // CRUD Operations
        bindClick('btnneuveranst', createRecord);
        bindClick('Befehl640', copyRecord);  // Auftrag kopieren
        bindClick('mcobtnDelete', deleteRecord);
        bindClick('btnReq', () => { loadRecord(currentRecordId); });  // Aktualisieren

        // Toolbar Buttons
        bindClick('btnSchnellPlan', btnSchnellPlan_Click);
        bindClick('btn_N_HTMLAnsicht', btn_N_HTMLAnsicht_Click);
        bindClick('btn_Posliste_oeffnen', btn_Posliste_oeffnen_Click);

        // Einsatzliste Buttons
        bindClick('btnMailEins', btnMailEins_Click);
        bindClick('btn_Autosend_BOS', btn_Autosend_BOS_Click);
        bindClick('btnMailSub', btnMailSub_Click);
        bindClick('btnDruckZusage', btnDruckZusage_Click);
        bindClick('btn_ListeStd', btn_ListeStd_Click);
        bindClick('Befehl709', Befehl709_Click);  // EL gesendet

        // Info Buttons
        bindClick('btn_Rueckmeld', btn_Rueckmeld_Click);
        bindClick('btnSyncErr', btnSyncErr_Click);

        // Tab: Einsatzliste
        bindClick('btn_BWN_Druck', btn_BWN_Druck_Click);

        // Tab: Zusatzdateien
        bindClick('btnNeuAttach', btnNeuAttach_Click);

        // Tab: Rechnung
        bindClick('btnPDFKopf', btnPDFKopf_Click);
        bindClick('btnPDFPos', btnPDFPos_Click);
        bindClick('btnLoad', btnLoad_Click);
        bindClick('btnRchLex', btnRchLex_Click);

        // Utility Buttons
        bindClick('btnRibbonAus', btnRibbonAus_Click);
        bindClick('btnRibbonEin', btnRibbonEin_Click);
        bindClick('btnDaBaAus', btnDaBaAus_Click);
        bindClick('btnDaBaEin', btnDaBaEin_Click);

        // Close Button
        bindClick('Befehl38', () => {
            if (isDirty && !confirm('Änderungen verwerfen?')) return;
            window.close();
        });

        // Hidden but may be needed
        bindClick('btnAuftrBerech', btnAuftrBerech_Click);
        bindClick('btnDruckZusage1', btnDruckZusage1_Click);
        bindClick('btnPlan_Kopie', btnPlan_Kopie_Click);
        bindClick('btnVAPlanCrea', btnVAPlanCrea_Click);
        bindClick('btn_VA_Abwesenheiten', btn_VA_Abwesenheiten_Click);
        bindClick('btn_sortieren', btn_sortieren_Click);
        bindClick('cmd_Messezettel_NameEintragen', cmd_Messezettel_NameEintragen_Click);
        bindClick('cmd_BWN_send', cmd_BWN_send_Click);
    }

    // ========================================================
    // BUTTON CLICK HANDLERS
    // ========================================================

    function btnSchnellPlan_Click() {
        console.log('[btnSchnellPlan_Click] Mitarbeiterauswahl öffnen');
        // TODO: Mitarbeiterauswahl-Dialog öffnen
        alert('TODO: Mitarbeiterauswahl-Dialog öffnen');
    }

    function btn_N_HTMLAnsicht_Click() {
        console.log('[btn_N_HTMLAnsicht_Click] HTML Ansicht öffnen');
        // Entspricht VBA: =HTMLAnsichtOeffnen()
        // TODO: HTML-Ansicht öffnen
        alert('TODO: HTML Ansicht öffnen');
    }

    function btn_Posliste_oeffnen_Click() {
        console.log('[btn_Posliste_oeffnen_Click] Positionen öffnen');
        // TODO: Positionen-Formular öffnen
        alert('TODO: Positionen öffnen');
    }

    function btnMailEins_Click() {
        console.log('[btnMailEins_Click] Einsatzliste senden MA');
        // TODO: E-Mail mit Einsatzliste an MA senden
        alert('TODO: Einsatzliste an Mitarbeiter senden');
    }

    function btn_Autosend_BOS_Click() {
        console.log('[btn_Autosend_BOS_Click] Einsatzliste senden BOS');
        // TODO: E-Mail an BOS senden
        alert('TODO: Einsatzliste an BOS senden');
    }

    function btnMailSub_Click() {
        console.log('[btnMailSub_Click] Einsatzliste senden SUB');
        // TODO: E-Mail an SUB senden
        alert('TODO: Einsatzliste an SUB senden');
    }

    function btnDruckZusage_Click() {
        console.log('[btnDruckZusage_Click] Einsatzliste drucken');
        // TODO: Einsatzliste drucken
        alert('TODO: Einsatzliste drucken');
    }

    function btn_ListeStd_Click() {
        console.log('[btn_ListeStd_Click] Namensliste ESS');
        // TODO: Namensliste ESS generieren
        alert('TODO: Namensliste ESS');
    }

    function Befehl709_Click() {
        console.log('[Befehl709_Click] EL gesendet');
        // TODO: Markiert als "EL gesendet"
        alert('TODO: EL gesendet markieren');
    }

    function btn_Rueckmeld_Click() {
        console.log('[btn_Rueckmeld_Click] Rückmelde-Statistik');
        // TODO: Rückmelde-Statistik anzeigen
        alert('TODO: Rückmelde-Statistik');
    }

    function btnSyncErr_Click() {
        console.log('[btnSyncErr_Click] Syncfehler checken');
        // TODO: Sync-Fehler prüfen
        alert('TODO: Syncfehler checken');
    }

    function btn_BWN_Druck_Click() {
        console.log('[btn_BWN_Druck_Click] BWN drucken');
        // TODO: BWN drucken
        alert('TODO: BWN drucken');
    }

    function btnNeuAttach_Click() {
        console.log('[btnNeuAttach_Click] Neuen Attach hinzufügen');
        // TODO: Datei-Upload Dialog
        alert('TODO: Datei-Upload für Zusatzdateien');
    }

    function btnPDFKopf_Click() {
        console.log('[btnPDFKopf_Click] Rechnung PDF');
        // TODO: Rechnung als PDF generieren
        alert('TODO: Rechnung PDF generieren');
    }

    function btnPDFPos_Click() {
        console.log('[btnPDFPos_Click] Berechnungsliste PDF');
        // TODO: Berechnungsliste als PDF
        alert('TODO: Berechnungsliste PDF');
    }

    function btnLoad_Click() {
        console.log('[btnLoad_Click] Daten laden');
        // TODO: Rechnungsdaten laden
        SubformManager.refresh('sub_rch_Pos');
        SubformManager.refresh('sub_Berechnungsliste');
    }

    function btnRchLex_Click() {
        console.log('[btnRchLex_Click] Rechnung in Lexware erstellen');
        // TODO: Lexware-Integration
        alert('TODO: Lexware-Integration');
    }

    function btnRibbonAus_Click() {
        console.log('[btnRibbonAus_Click]');
        // In Web nicht relevant, war Access-spezifisch
    }

    function btnRibbonEin_Click() {
        console.log('[btnRibbonEin_Click]');
        // In Web nicht relevant
    }

    function btnDaBaAus_Click() {
        console.log('[btnDaBaAus_Click]');
        // In Web nicht relevant
    }

    function btnDaBaEin_Click() {
        console.log('[btnDaBaEin_Click]');
        // In Web nicht relevant
    }

    // Hidden Buttons (visible=false in spec, aber Handler trotzdem angelegt)

    function btnAuftrBerech_Click() {
        console.log('[btnAuftrBerech_Click] Auftrag berechnen');
        // TODO: Berechnung durchführen
        alert('TODO: Auftrag berechnen');
    }

    function btnDruckZusage1_Click() {
        console.log('[btnDruckZusage1_Click] Mehrtagesliste drucken');
        // TODO: Mehrtagesliste drucken
        alert('TODO: Mehrtagesliste drucken');
    }

    function btnPlan_Kopie_Click() {
        console.log('[btnPlan_Kopie_Click] Daten in Folgetag kopieren');
        // TODO: Planung in Folgetag kopieren
        alert('TODO: Daten in Folgetag kopieren');
    }

    function btnVAPlanCrea_Click() {
        console.log('[btnVAPlanCrea_Click] Liste aktualisieren');
        SubformManager.refresh('sub_MA_VA_Zuordnung');
    }

    function btn_VA_Abwesenheiten_Click() {
        console.log('[btn_VA_Abwesenheiten_Click] Abwesenheiten');
        // TODO: Abwesenheiten-Dialog
        alert('TODO: Abwesenheiten anzeigen');
    }

    function btn_sortieren_Click() {
        console.log('[btn_sortieren_Click] Sortieren');
        // TODO: MA-Zuordnung sortieren
        alert('TODO: Sortierung');
    }

    function cmd_Messezettel_NameEintragen_Click() {
        console.log('[cmd_Messezettel_NameEintragen_Click] BWN Namen');
        // TODO: BWN Namen eintragen
        alert('TODO: BWN Namen eintragen');
    }

    function cmd_BWN_send_Click() {
        console.log('[cmd_BWN_send_Click] BWN senden');
        // TODO: BWN senden
        alert('TODO: BWN senden');
    }

    // ========================================================
    // FIELD EVENTS
    // ========================================================

    function bindFieldEvents() {
        console.log('[bindFieldEvents] Binde Feld-Events...');

        // Combobox AfterUpdate Events
        bindChange('cboVADatum', cboVADatum_AfterUpdate);
        bindChange('Veranst_Status_ID', Veranst_Status_ID_AfterUpdate);
        bindChange('Objekt_ID', Objekt_ID_AfterUpdate);
        bindChange('veranstalter_id', veranstalter_id_AfterUpdate);
        bindChange('cboID', cboID_AfterUpdate);
        bindChange('IstStatus', IstStatus_AfterUpdate);
        bindChange('cboAnstArt', cboAnstArt_AfterUpdate);
        bindChange('IstVerfuegbar', IstVerfuegbar_AfterUpdate);
        bindChange('cbAutosendEL', () => { isDirty = true; });

        // Textfield Events
        bindChange('Dat_VA_Von', () => { isDirty = true; });
        bindChange('Dat_VA_Bis', Dat_VA_Bis_AfterUpdate);
        bindChange('Treffp_Zeit', () => { isDirty = true; });
        bindChange('Treffpunkt', () => { isDirty = true; });
        bindChange('Ansprechpartner', () => { isDirty = true; });
        bindChange('PKW_Anzahl', () => { isDirty = true; });
        bindChange('Fahrtkosten', () => { isDirty = true; });

        // DblClick Events
        bindDblClick('Dat_VA_Von', Dat_VA_Von_DblClick);
        bindDblClick('Dat_VA_Bis', Dat_VA_Bis_DblClick);
        bindDblClick('cboVADatum', cboVADatum_DblClick);
        bindDblClick('Objekt', Objekt_DblClick);
        bindDblClick('Objekt_ID', Objekt_ID_DblClick);
        bindDblClick('veranstalter_id', Veranstalter_ID_DblClick);
        bindDblClick('Veranst_Status_ID', Veranst_Status_ID_DblClick);
        bindDblClick('Auftraege_ab', Auftraege_ab_DblClick);
    }

    // Field Event Handlers

    function Veranst_Status_ID_AfterUpdate() {
        console.log('[Veranst_Status_ID_AfterUpdate]');
        isDirty = true;
        // Auftragsliste aktualisieren (Recalc)
        SubformManager.refresh('zsub_lstAuftrag');
    }

    function Objekt_ID_AfterUpdate() {
        console.log('[Objekt_ID_AfterUpdate]');
        isDirty = true;
        // TODO: Objekt-Daten laden
    }

    function veranstalter_id_AfterUpdate() {
        console.log('[veranstalter_id_AfterUpdate]');
        isDirty = true;
        // TODO: Veranstalter-Daten aktualisieren
    }

    function cboID_AfterUpdate() {
        console.log('[cboID_AfterUpdate]');
        const cbo = document.getElementById('cboID');
        if (cbo && cbo.value) {
            loadRecord(parseInt(cbo.value));
        }
    }

    function IstStatus_AfterUpdate() {
        console.log('[IstStatus_AfterUpdate]');
        // Filter für Auftragsliste anwenden
        const auftraegeAb = document.getElementById('Auftraege_ab');
        const abDatum = auftraegeAb ? auftraegeAb.value : null;
        if (abDatum) {
            filterAuftragsliste(abDatum, getStatusFilter());
        } else {
            SubformManager.refresh('zsub_lstAuftrag', { status: getStatusFilter() });
        }
    }

    function cboAnstArt_AfterUpdate() {
        console.log('[cboAnstArt_AfterUpdate]');
        // TODO: MA-Filter nach Anstellungsart
        SubformManager.refresh('sub_MA_VA_Zuordnung');
    }

    function IstVerfuegbar_AfterUpdate() {
        console.log('[IstVerfuegbar_AfterUpdate]');
        // TODO: Filter für verfügbare MA
        SubformManager.refresh('sub_MA_VA_Zuordnung');
    }

    function Dat_VA_Bis_AfterUpdate() {
        console.log('[Dat_VA_Bis_AfterUpdate]');
        isDirty = true;
        // Auftragsliste aktualisieren
        SubformManager.refresh('zsub_lstAuftrag');
    }

    // DblClick Handlers

    function Dat_VA_Von_DblClick() {
        console.log('[Dat_VA_Von_DblClick]');
        // TODO: Datepicker öffnen
    }

    function Dat_VA_Bis_DblClick() {
        console.log('[Dat_VA_Bis_DblClick]');
        // TODO: Datepicker öffnen
    }

    function cboVADatum_DblClick() {
        console.log('[cboVADatum_DblClick]');
        // TODO: Tages-Details öffnen
    }

    function Objekt_DblClick() {
        console.log('[Objekt_DblClick]');
        // TODO: Objekt-Formular öffnen
        alert('TODO: Objekt-Formular öffnen');
    }

    function Objekt_ID_DblClick() {
        console.log('[Objekt_ID_DblClick]');
        // TODO: Objekt-Suche öffnen
        alert('TODO: Objekt-Suche öffnen');
    }

    function Veranstalter_ID_DblClick() {
        console.log('[Veranstalter_ID_DblClick]');
        // TODO: Kundenstamm öffnen
        alert('TODO: Kundenstamm öffnen (frm_KD_Kundenstamm)');
    }

    function Veranst_Status_ID_DblClick() {
        console.log('[Veranst_Status_ID_DblClick]');
        // TODO: Status-Verwaltung öffnen
        alert('TODO: Veranstaltungsstatus öffnen');
    }

    function Auftraege_ab_DblClick() {
        console.log('[Auftraege_ab_DblClick]');
        // TODO: Datepicker öffnen
    }

    // ========================================================
    // TAB EVENTS
    // ========================================================

    function bindTabEvents() {
        // Tab-Wechsel ist bereits im HTML via inline script implementiert
        // Hier können zusätzliche Tab-spezifische Aktionen hinzugefügt werden

        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const tabId = this.dataset.tab;
                onTabChange(tabId);
            });
        });
    }

    function onTabChange(tabId) {
        console.log('[onTabChange]', tabId);

        // Tab-spezifische Subforms aktualisieren
        switch(tabId) {
            case 'pgMA_Zusage':
                SubformManager.refresh('sub_VA_Start');
                SubformManager.refresh('sub_MA_VA_Zuordnung');
                SubformManager.refresh('sub_MA_VA_Planung_Absage');
                break;
            case 'pgMA_Plan':
                SubformManager.refresh('sub_MA_VA_Zuordnung_Status');
                break;
            case 'pgAttach':
                SubformManager.refresh('sub_ZusatzDateien');
                break;
            case 'pgRechnung':
                SubformManager.refresh('sub_rch_Pos');
                SubformManager.refresh('sub_Berechnungsliste');
                break;
            case 'pgBemerk':
                // Keine Subforms
                break;
        }
    }

    // ========================================================
    // NAVIGATION EVENTS
    // ========================================================

    function bindNavigationEvents() {
        // Keyboard Navigation
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey) {
                switch(e.key) {
                    case 'Home':
                        e.preventDefault();
                        navigateFirst();
                        break;
                    case 'End':
                        e.preventDefault();
                        navigateLast();
                        break;
                    case 'ArrowUp':
                        e.preventDefault();
                        navigatePrevious();
                        break;
                    case 'ArrowDown':
                        e.preventDefault();
                        navigateNext();
                        break;
                    case 's':
                        e.preventDefault();
                        saveRecord();
                        break;
                }
            }
        });
    }

    // ========================================================
    // HELPER FUNCTIONS
    // ========================================================

    function bindClick(elementId, handler) {
        const el = document.getElementById(elementId);
        if (el) {
            el.addEventListener('click', handler);
        } else {
            console.warn(`[bindClick] Element nicht gefunden: ${elementId}`);
        }
    }

    function bindChange(elementId, handler) {
        const el = document.getElementById(elementId);
        if (el) {
            el.addEventListener('change', handler);
        }
    }

    function bindDblClick(elementId, handler) {
        const el = document.getElementById(elementId);
        if (el) {
            el.addEventListener('dblclick', handler);
        }
    }

    function formatDate(date) {
        const d = date.getDate().toString().padStart(2, '0');
        const m = (date.getMonth() + 1).toString().padStart(2, '0');
        const y = date.getFullYear();
        return `${d}.${m}.${y}`;
    }

    function parseDate(str) {
        const parts = str.split('.');
        if (parts.length === 3) {
            return new Date(parts[2], parts[1] - 1, parts[0]);
        }
        return null;
    }

    function populateFields(record) {
        if (!record) return;

        setFieldValue('ID', record.ID);
        setFieldValue('Dat_VA_Von', record.Dat_VA_Von);
        setFieldValue('Dat_VA_Bis', record.Dat_VA_Bis);
        setFieldValue('Kombinationsfeld656', record.Auftrag);
        setFieldValue('Ort', record.Ort);
        setFieldValue('Objekt', record.Objekt);
        setFieldValue('Objekt_ID', record.Objekt_ID);
        setFieldValue('Treffp_Zeit', record.Treffp_Zeit);
        setFieldValue('Treffpunkt', record.Treffpunkt);
        setFieldValue('Dienstkleidung', record.Dienstkleidung);
        setFieldValue('Ansprechpartner', record.Ansprechpartner);
        setFieldValue('veranstalter_id', record.Veranstalter_ID);
        setFieldValue('PKW_Anzahl', record.Dummy);
        setFieldValue('Fahrtkosten', record.Fahrtkosten);
        setFieldValue('Veranst_Status_ID', record.Veranst_Status_ID);
        setFieldValue('cbAutosendEL', record.Autosend_EL);
        setFieldValue('Bemerkungen', record.Bemerkungen);
        setFieldValue('Text416', record.Erst_von);
        setFieldValue('Text418', record.Erst_am);
        setFieldValue('Text419', record.Aend_von);
        setFieldValue('Text422', record.Aend_am);
    }

    function setFieldValue(elementId, value) {
        const el = document.getElementById(elementId);
        if (!el) return;

        if (el.type === 'checkbox') {
            el.checked = !!value;
        } else {
            el.value = value || '';
        }
    }

    function collectFieldData() {
        return {
            ID: currentRecordId,
            Dat_VA_Von: getFieldValue('Dat_VA_Von'),
            Dat_VA_Bis: getFieldValue('Dat_VA_Bis'),
            Auftrag: getFieldValue('Kombinationsfeld656'),
            Ort: getFieldValue('Ort'),
            Objekt: getFieldValue('Objekt'),
            Objekt_ID: getFieldValue('Objekt_ID'),
            Treffp_Zeit: getFieldValue('Treffp_Zeit'),
            Treffpunkt: getFieldValue('Treffpunkt'),
            Dienstkleidung: getFieldValue('Dienstkleidung'),
            Ansprechpartner: getFieldValue('Ansprechpartner'),
            Veranstalter_ID: getFieldValue('veranstalter_id'),
            Fahrtkosten: getFieldValue('Fahrtkosten'),
            Veranst_Status_ID: getFieldValue('Veranst_Status_ID'),
            Autosend_EL: document.getElementById('cbAutosendEL')?.checked || false,
            Bemerkungen: getFieldValue('Bemerkungen')
        };
    }

    function getFieldValue(elementId) {
        const el = document.getElementById(elementId);
        return el ? el.value : null;
    }

    function validateRecord() {
        // Basis-Validierung
        const datVon = getFieldValue('Dat_VA_Von');
        const datBis = getFieldValue('Dat_VA_Bis');

        if (!datVon) {
            alert('Datum Von ist erforderlich');
            return false;
        }

        return true;
    }

    function refreshAllSubforms() {
        SubformManager.refreshAll();
    }

    /**
     * Combobox-Daten laden über Bridge.loadLookup
     */
    async function loadComboboxData() {
        console.log('[loadComboboxData] Lade Combobox-Daten...');

        try {
            // Status-Combobox
            const statusResponse = await Bridge.loadLookup('tbl_VA_Status', {});
            const statusData = statusResponse.data || statusResponse || [];
            populateCombobox('Veranst_Status_ID', statusData, 'ID', 'Fortschritt');

            // Objekte
            const objekteResponse = await Bridge.loadLookup('tbl_OB_Objekt', {});
            const objekteData = objekteResponse.data || objekteResponse || [];
            populateCombobox('Objekt_ID', objekteData, 'ID', 'Objekt');

            // Kunden
            const kundenResponse = await Bridge.loadLookup('tbl_KD_Kundenstamm', {});
            const kundenData = kundenResponse.data || kundenResponse || [];
            populateCombobox('veranstalter_id', kundenData, 'kun_Id', 'kun_Firma');

            // Anstellungsart
            const anstArtResponse = await Bridge.loadLookup('tbl_hlp_MA_Anstellungsart', {});
            const anstArtData = anstArtResponse.data || anstArtResponse || [];
            populateCombobox('cboAnstArt', anstArtData, 'ID', 'Anstellungsart');

            // IstStatus - Hardcoded Value List (wie in Access)
            populateCombobox('IstStatus', [
                { ID: -5, Text: 'Alle' },
                { ID: 1, Text: '1' },
                { ID: 2, Text: '2' },
                { ID: 3, Text: '3' },
                { ID: 4, Text: '4' },
                { ID: 5, Text: '5' }
            ], 'ID', 'Text');

        } catch (error) {
            console.error('[loadComboboxData] Fehler:', error);
        }
    }

    /**
     * VA-Datum Combobox laden über Bridge.loadLookup
     */
    async function loadVADatumCombo(vaId) {
        console.log('[loadVADatumCombo] Lade VA-Datum für:', vaId);

        try {
            const response = await Bridge.loadLookup('tbl_VA_AnzTage', { VA_ID: vaId });
            const datumList = response.data || response || [];
            populateCombobox('cboVADatum', datumList, 'ID', 'VADatum');

            // Erstes Datum auswählen
            if (datumList.length > 0) {
                document.getElementById('cboVADatum').value = datumList[0].ID;
                currentVADatumId = datumList[0].ID;
            }

        } catch (error) {
            console.error('[loadVADatumCombo] Fehler:', error);
        }
    }

    function populateCombobox(elementId, data, valueField, textField) {
        const cbo = document.getElementById(elementId);
        if (!cbo) return;

        // Bestehende Optionen entfernen (außer erste "Bitte wählen")
        while (cbo.options.length > 1) {
            cbo.remove(1);
        }

        // Neue Optionen hinzufügen
        data.forEach(item => {
            const option = document.createElement('option');
            option.value = item[valueField];
            option.textContent = item[textField];
            cbo.appendChild(option);
        });
    }

    // ========================================================
    // PUBLIC API
    // ========================================================

    return {
        init: init,
        loadRecord: loadRecord,
        saveRecord: saveRecord,
        createRecord: createRecord,
        deleteRecord: deleteRecord,
        VAOpen: VAOpen,
        getCurrentRecordId: () => currentRecordId,
        getCurrentVADatumId: () => currentVADatumId,
        isDirty: () => isDirty
    };

})();


// ============================================================
// SUBFORM MANAGER
// ============================================================
const SubformManager = (function() {

    /**
     * Subform-Konfiguration aus spec.json und subform_links.txt
     */
    const subformConfig = {
        'frm_Menuefuehrung': {
            source: 'frm_Menuefuehrung',
            linkMaster: null,
            linkChild: null
        },
        'sub_VA_Start': {
            source: 'sub_VA_Start',
            linkMaster: ['ID', 'cboVADatum'],
            linkChild: ['VA_ID', 'VADatum_ID']
        },
        'sub_MA_VA_Zuordnung': {
            source: 'sub_MA_VA_Zuordnung',
            linkMaster: ['ID', 'cboVADatum'],
            linkChild: ['VA_ID', 'VADatum_ID']
        },
        'sub_MA_VA_Planung_Absage': {
            source: 'sub_MA_VA_Planung_Absage',
            linkMaster: ['ID', 'cboVADatum'],
            linkChild: ['VA_ID', 'VADatum_ID']
        },
        'sub_MA_VA_Zuordnung_Status': {
            source: 'sub_MA_VA_Planung_Status',
            linkMaster: ['ID', 'cboVADatum'],
            linkChild: ['VA_ID', 'VADatum_ID']
        },
        'sub_ZusatzDateien': {
            source: 'sub_ZusatzDateien',
            linkMaster: ['Objekt_ID', 'TabellenNr'],
            linkChild: ['Ueberordnung', 'TabellenID']
        },
        'sub_rch_Pos': {
            source: 'zqry_Rch_Pos',
            linkMaster: ['ID'],
            linkChild: ['VA_ID']
        },
        'sub_Berechnungsliste': {
            source: 'zsub_rch_Berechnungsliste',
            linkMaster: ['ID'],
            linkChild: ['VA_ID']
        },
        'sub_VA_Anzeige': {
            source: 'sub_VA_Anzeige',
            linkMaster: null,
            linkChild: null
        },
        'zsub_lstAuftrag': {
            source: 'frm_lst_row_auftrag',
            linkMaster: null,
            linkChild: null
        }
    };

    function init() {
        console.log('[SubformManager] Initialisierung...');

        // Subform-Container mit Click-Handlern versehen
        Object.keys(subformConfig).forEach(name => {
            const container = document.getElementById(name);
            if (container) {
                // zsub_lstAuftrag braucht Row-Click-Handler
                if (name === 'zsub_lstAuftrag') {
                    container.addEventListener('click', handleAuftragListClick);
                }
            }
        });
    }

    /**
     * Row-Click-Handler für zsub_lstAuftrag
     * Öffnet den angeklickten Auftrag via VAOpen
     */
    function handleAuftragListClick(event) {
        const row = event.target.closest('[data-va-id]');
        if (row) {
            const vaId = parseInt(row.dataset.vaId);
            const vaDatumId = row.dataset.vaDatumId ? parseInt(row.dataset.vaDatumId) : null;
            console.log('[handleAuftragListClick] VAOpen:', vaId, vaDatumId);
            FormController.VAOpen(vaId, vaDatumId);
        }
    }

    /**
     * Subform aktualisieren - nutzt Bridge.loadSubform
     * @param {string} name - Subform-Name
     * @param {object} additionalParams - Zusätzliche Parameter
     */
    async function refresh(name, additionalParams = {}) {
        console.log(`[SubformManager.refresh] ${name}`);

        const config = subformConfig[name];
        if (!config) {
            console.warn(`[SubformManager] Unbekanntes Subform: ${name}`);
            return;
        }

        const container = document.getElementById(name);
        if (!container) {
            console.warn(`[SubformManager] Container nicht gefunden: ${name}`);
            return;
        }

        // Parameter aufbauen
        const params = buildLinkParams(config);
        Object.assign(params, additionalParams);

        try {
            // Bridge-Aufruf für Subform-Daten
            const response = await Bridge.loadSubform(config.source, params);
            const data = response.data || response || [];

            // Subform rendern
            renderSubform(container, name, data, params);

        } catch (error) {
            console.error(`[SubformManager.refresh] Fehler bei ${name}:`, error);
            updatePlaceholder(container, name, params, 'Fehler beim Laden');
        }
    }

    function refreshAll() {
        console.log('[SubformManager.refreshAll]');

        // Nur sichtbare Subforms aktualisieren (aktiver Tab)
        const activePane = document.querySelector('.tab-pane.active');
        if (activePane) {
            activePane.querySelectorAll('.subform-placeholder').forEach(sf => {
                refresh(sf.id);
            });
        }

        // Sidebar immer aktualisieren
        refresh('sub_VA_Anzeige');
        // zsub_lstAuftrag: Highlight aktualisieren statt komplett neu laden
        highlightCurrentAuftrag();
    }

    function buildLinkParams(config) {
        const params = {};

        if (!config.linkMaster || !config.linkChild) {
            return params;
        }

        config.linkMaster.forEach((masterField, index) => {
            const childField = config.linkChild[index];
            let value = null;

            // Wert aus Hauptformular holen
            if (masterField === 'ID') {
                value = FormController.getCurrentRecordId();
            } else if (masterField === 'cboVADatum') {
                value = FormController.getCurrentVADatumId();
            } else {
                const el = document.getElementById(masterField);
                if (el) value = el.value;
            }

            if (value !== null) {
                params[childField] = value;
            }
        });

        return params;
    }

    /**
     * Subform-Daten rendern
     */
    function renderSubform(container, name, data, params) {
        // Für zsub_lstAuftrag: Tabellen-Darstellung
        if (name === 'zsub_lstAuftrag') {
            renderAuftragList(container, data);
            return;
        }

        // Für andere Subforms: Einfache Tabelle oder Placeholder
        if (Array.isArray(data) && data.length > 0) {
            const table = document.createElement('table');
            table.className = 'subform-table';

            // Header
            const thead = document.createElement('thead');
            const headerRow = document.createElement('tr');
            Object.keys(data[0]).forEach(key => {
                const th = document.createElement('th');
                th.textContent = key;
                headerRow.appendChild(th);
            });
            thead.appendChild(headerRow);
            table.appendChild(thead);

            // Body
            const tbody = document.createElement('tbody');
            data.forEach(row => {
                const tr = document.createElement('tr');
                Object.values(row).forEach(val => {
                    const td = document.createElement('td');
                    td.textContent = val || '';
                    tr.appendChild(td);
                });
                tbody.appendChild(tr);
            });
            table.appendChild(tbody);

            container.innerHTML = '';
            container.appendChild(table);
        } else {
            updatePlaceholder(container, name, params, 'Keine Daten');
        }
    }

    /**
     * Auftragsliste rendern
     */
    function renderAuftragList(container, data) {
        if (!Array.isArray(data) || data.length === 0) {
            container.innerHTML = '<div class="no-data">Keine Aufträge gefunden</div>';
            return;
        }

        const table = document.createElement('table');
        table.className = 'auftrag-list-table';

        // Header
        const thead = document.createElement('thead');
        thead.innerHTML = `
            <tr>
                <th>Datum</th>
                <th>Auftrag</th>
                <th>Objekt</th>
                <th>Status</th>
            </tr>
        `;
        table.appendChild(thead);

        // Body
        const tbody = document.createElement('tbody');
        const currentId = FormController.getCurrentRecordId();

        data.forEach(row => {
            const tr = document.createElement('tr');
            tr.dataset.vaId = row.ID || row.VA_ID;
            if (row.VADatum_ID) tr.dataset.vaDatumId = row.VADatum_ID;

            // Aktiven Datensatz hervorheben
            if ((row.ID || row.VA_ID) == currentId) {
                tr.classList.add('active');
            }

            tr.innerHTML = `
                <td>${row.Datum || row.VADatum || ''}</td>
                <td>${row.Auftrag || ''}</td>
                <td>${row.Objekt || ''}</td>
                <td>${row.Status || row.Veranst_Status_ID || ''}</td>
            `;
            tbody.appendChild(tr);
        });
        table.appendChild(tbody);

        container.innerHTML = '';
        container.appendChild(table);
    }

    /**
     * Aktuellen Auftrag in Liste hervorheben
     */
    function highlightCurrentAuftrag() {
        const container = document.getElementById('zsub_lstAuftrag');
        if (!container) return;

        const currentId = FormController.getCurrentRecordId();
        container.querySelectorAll('tr').forEach(tr => {
            if (tr.dataset.vaId == currentId) {
                tr.classList.add('active');
            } else {
                tr.classList.remove('active');
            }
        });
    }

    function updatePlaceholder(container, name, params, message) {
        // Placeholder-Info aktualisieren
        let info = container.querySelector('.placeholder-params');
        if (!info) {
            info = document.createElement('span');
            info.className = 'placeholder-params';
            info.style.cssText = 'font-size: 9px; color: #666; display: block; margin-top: 5px;';
            container.appendChild(info);
        }

        const paramStr = Object.entries(params)
            .map(([k, v]) => `${k}=${v}`)
            .join(', ');

        info.textContent = message || (paramStr ? `Params: ${paramStr}` : '(keine Filter)');
    }

    return {
        init: init,
        refresh: refresh,
        refreshAll: refreshAll,
        getConfig: () => subformConfig
    };

})();


// ============================================================
// INITIALIZATION
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    console.log('===========================================');
    console.log('frm_va_Auftragstamm.logic.js geladen');
    console.log('Backend: Access Bridge (localhost:5000/api)');
    console.log('===========================================');

    FormController.init();
});


// Export für ES Module
export { FormController, SubformManager };
