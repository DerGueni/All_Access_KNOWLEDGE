/**
 * frm_Einsatzuebersicht.webview2.js
 * WebView2-spezifische Bridge-Integration fuer Einsatzuebersicht
 *
 * Dieses Modul erweitert die allgemeine webview2-bridge.js um
 * formularspezifische Funktionen fuer die Einsatzuebersicht.
 *
 * VBA-Aufruf: OpenEinsatzuebersicht_WebView2(VonDatum, BisDatum)
 */

'use strict';

// ============================================
// WEBVIEW2 BRIDGE ERWEITERUNG
// ============================================

/**
 * Einsatzuebersicht-spezifische Bridge-Erweiterung
 */
const EinsatzuebersichtBridge = {
    /**
     * Initialisierung
     */
    init: function() {
        console.log('[EinsatzuebersichtBridge] Initialisierung...');

        // Pruefen ob WebView2 verfuegbar
        if (typeof Bridge === 'undefined') {
            console.warn('[EinsatzuebersichtBridge] Bridge nicht verfuegbar');
            return;
        }

        // Event-Handler registrieren
        this.registerEventHandlers();

        // Initiale Daten vom Host empfangen (falls mit -data Parameter gestartet)
        this.checkInitialData();
    },

    /**
     * Event-Handler fuer WebView2 registrieren
     */
    registerEventHandlers: function() {
        if (typeof Bridge.on !== 'function') return;

        // Einsatzdaten empfangen
        Bridge.on('onEinsatzuebersicht', (data) => {
            console.log('[EinsatzuebersichtBridge] Einsatzdaten empfangen:', data);
            if (window.Einsatzuebersicht && typeof window.Einsatzuebersicht.processEinsatzData === 'function') {
                // Direkt verarbeiten wenn Funktion verfuegbar
                processEinsatzData(data.einsaetze || data);
            }
        });

        // Export-Ergebnis empfangen
        Bridge.on('onExportComplete', (data) => {
            console.log('[EinsatzuebersichtBridge] Export abgeschlossen:', data);
            if (data.success) {
                showToast('Export erfolgreich: ' + (data.filepath || ''), 'success');
            } else {
                showToast('Export fehlgeschlagen: ' + (data.error || 'Unbekannter Fehler'), 'error');
            }
        });

        // Druck-Ergebnis empfangen
        Bridge.on('onPrintComplete', (data) => {
            console.log('[EinsatzuebersichtBridge] Druck abgeschlossen:', data);
            if (data.success) {
                showToast('Druck gestartet', 'success');
            } else {
                showToast('Druck fehlgeschlagen: ' + (data.error || 'Unbekannter Fehler'), 'error');
            }
        });

        // Navigation zu Auftrag bestaetigt
        Bridge.on('onNavigateComplete', (data) => {
            console.log('[EinsatzuebersichtBridge] Navigation:', data);
        });

        // Fehler empfangen
        Bridge.on('onError', (data) => {
            console.error('[EinsatzuebersichtBridge] Fehler:', data);
            showToast('Fehler: ' + (data.message || data.error || 'Unbekannter Fehler'), 'error');
        });
    },

    /**
     * Pruefen ob initiale Daten vorhanden (von VBA uebergeben)
     */
    checkInitialData: function() {
        // URL-Parameter pruefen
        const urlParams = new URLSearchParams(window.location.search);

        const vonDatum = urlParams.get('von');
        const bisDatum = urlParams.get('bis');

        if (vonDatum && bisDatum) {
            console.log('[EinsatzuebersichtBridge] Initiale Parameter:', vonDatum, bisDatum);

            // Warten bis DOM und Logic geladen sind
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', () => {
                    this.applyInitialParams(vonDatum, bisDatum);
                });
            } else {
                setTimeout(() => this.applyInitialParams(vonDatum, bisDatum), 100);
            }
        }
    },

    /**
     * Initiale Parameter anwenden
     */
    applyInitialParams: function(vonDatum, bisDatum) {
        const dtVon = document.getElementById('dtVonDatum');
        const dtBis = document.getElementById('dtBisDatum');

        if (dtVon && vonDatum) {
            dtVon.value = vonDatum;
        }
        if (dtBis && bisDatum) {
            dtBis.value = bisDatum;
        }

        // Quick-Filter deaktivieren
        document.querySelectorAll('.quick-filter-btn').forEach(btn => btn.classList.remove('active'));

        // Daten laden
        if (typeof btnAktualisieren_Click === 'function') {
            btnAktualisieren_Click();
        }
    },

    /**
     * Einsatzdaten laden via WebView2
     */
    loadEinsaetze: function(vonDatum, bisDatum, nurAktive) {
        if (!this.isWebView2()) {
            console.log('[EinsatzuebersichtBridge] Kein WebView2 - verwende API');
            return false;
        }

        Bridge.sendEvent('loadEinsatzuebersicht', {
            von: vonDatum,
            bis: bisDatum,
            nurAktive: nurAktive !== false
        });

        return true;
    },

    /**
     * Excel-Export via WebView2
     */
    exportExcel: function(vonDatum, bisDatum, data) {
        if (!this.isWebView2()) {
            console.log('[EinsatzuebersichtBridge] Kein WebView2 - verwende CSV-Export');
            return false;
        }

        Bridge.sendEvent('exportExcel', {
            type: 'einsatzuebersicht',
            von: vonDatum,
            bis: bisDatum,
            data: data,
            filename: 'Einsatzuebersicht_' + vonDatum + '_bis_' + bisDatum + '.xlsx'
        });

        return true;
    },

    /**
     * Drucken via WebView2
     */
    print: function(vonDatum, bisDatum) {
        if (!this.isWebView2()) {
            console.log('[EinsatzuebersichtBridge] Kein WebView2 - verwende Browser-Print');
            return false;
        }

        Bridge.sendEvent('print', {
            type: 'einsatzuebersicht',
            von: vonDatum,
            bis: bisDatum,
            title: 'Einsatzuebersicht ' + vonDatum + ' bis ' + bisDatum
        });

        return true;
    },

    /**
     * Auftragstamm oeffnen via WebView2
     */
    openAuftrag: function(vaId) {
        if (!this.isWebView2()) {
            console.log('[EinsatzuebersichtBridge] Kein WebView2 - verwende Navigation');
            return false;
        }

        Bridge.sendEvent('openAuftrag', {
            va_id: vaId,
            formName: 'frm_va_Auftragstamm'
        });

        return true;
    },

    /**
     * Formular schliessen via WebView2
     */
    close: function() {
        if (!this.isWebView2()) {
            window.close();
            return;
        }

        Bridge.sendEvent('close', {
            formName: 'frm_Einsatzuebersicht'
        });
    },

    /**
     * Pruefen ob WebView2 verfuegbar ist
     */
    isWebView2: function() {
        return !!(window.chrome && window.chrome.webview);
    },

    /**
     * SQL-Abfrage direkt ausfuehren (fuer komplexe Abfragen)
     */
    executeSQL: async function(sql) {
        if (!this.isWebView2()) {
            console.warn('[EinsatzuebersichtBridge] executeSQL nur mit WebView2 verfuegbar');
            return null;
        }

        try {
            const result = await Bridge.execute('executeSQL', { sql: sql });
            return result;
        } catch (error) {
            console.error('[EinsatzuebersichtBridge] SQL-Fehler:', error);
            return null;
        }
    }
};

// ============================================
// VBA SQL-QUERIES REFERENZ
// ============================================

/**
 * SQL-Queries die vom VBA-Backend verwendet werden
 * (Referenz fuer die Bridge-Integration)
 */
const SQL_QUERIES = {
    /**
     * Einsatztage mit Schichten und MA-Zaehlung
     * Entspricht qry_Einsatzuebersicht in Access
     */
    EINSATZUEBERSICHT: `
        SELECT
            VAS.VAS_ID,
            VAS.VA_ID,
            VAT.VADatum,
            VAS.VA_Start,
            VAS.VA_Ende,
            VA.Auftrag,
            VA.Objekt,
            OB.Ob_Bezeichnung AS ObjektName,
            VAS.MA_Anzahl AS MA_Soll,
            (SELECT COUNT(*) FROM tbl_MA_VA_Planung MVP
             WHERE MVP.VAStart_ID = VAS.VAS_ID
             AND MVP.MVP_Status IN (1,2,3)) AS MA_Ist,
            CASE
                WHEN VAS.MA_Anzahl = 0 THEN 'In Planung'
                WHEN (SELECT COUNT(*) FROM tbl_MA_VA_Planung MVP
                      WHERE MVP.VAStart_ID = VAS.VAS_ID
                      AND MVP.MVP_Status IN (1,2,3)) = 0 THEN 'Offen'
                WHEN (SELECT COUNT(*) FROM tbl_MA_VA_Planung MVP
                      WHERE MVP.VAStart_ID = VAS.VAS_ID
                      AND MVP.MVP_Status IN (1,2,3)) < VAS.MA_Anzahl THEN 'Teilbesetzt'
                ELSE 'Besetzt'
            END AS Status,
            VA.VA_IstAktiv
        FROM tbl_VA_Start VAS
        INNER JOIN tbl_VA_AnzTage VAT ON VAS.VA_ID = VAT.VA_ID AND VAS.VADatum = VAT.VADatum
        INNER JOIN tbl_VA_Auftragstamm VA ON VAS.VA_ID = VA.VA_ID
        LEFT JOIN tbl_OB_Objekt OB ON VA.Objekt_ID = OB.Ob_ID
        WHERE VAT.VADatum BETWEEN @vonDatum AND @bisDatum
        ORDER BY VAT.VADatum, VAS.VA_Start
    `,

    /**
     * Einsatztage gefiltert nach aktiven Auftraegen
     */
    EINSATZUEBERSICHT_AKTIV: `
        SELECT * FROM (
            -- Basis-Query wie oben
        ) WHERE VA_IstAktiv = -1
    `
};

// ============================================
// INITIALISIERUNG
// ============================================

// Bei DOM-Ready initialisieren
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => EinsatzuebersichtBridge.init());
} else {
    EinsatzuebersichtBridge.init();
}

// Global verfuegbar machen
window.EinsatzuebersichtBridge = EinsatzuebersichtBridge;
