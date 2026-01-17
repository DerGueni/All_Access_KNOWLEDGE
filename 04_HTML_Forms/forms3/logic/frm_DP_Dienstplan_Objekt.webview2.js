/**
 * frm_DP_Dienstplan_Objekt.webview2.js
 * WebView2 Bridge Integration für Objekt-/Auftrag-Planungsübersicht
 * Version 2.0
 */

(function() {
    'use strict';

    const isWebView2 = typeof window.chrome !== 'undefined' &&
                       typeof window.chrome.webview !== 'undefined';

    if (!isWebView2) {
        console.log('[DP-Objekt] Nicht in WebView2 - Bridge-Integration übersprungen');
        return;
    }

    console.log('[DP-Objekt] WebView2 Bridge Integration aktiv');

    // Bridge Event-Handler registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
        console.log('[DP-Objekt] Bridge Event-Listener registriert');
    }

    /**
     * Bridge Event-Handler
     * Verarbeitet Daten vom Access Backend
     */
    function handleBridgeData(data) {
        console.log('[DP-Objekt] Bridge Data empfangen:', data);

        // Planungsübersicht-Daten
        if (data.auftraege) {
            if (window.DienstplanObjekt && window.DienstplanObjekt.state) {
                window.DienstplanObjekt.state.auftraege = data.auftraege || [];
                console.log(`[DP-Objekt] ${data.auftraege.length} Aufträge geladen`);
            }
        }

        // MA-Zuordnungen
        if (data.zuordnungen) {
            if (window.DienstplanObjekt && window.DienstplanObjekt.state) {
                const zuordnungen = {};
                (data.zuordnungen || []).forEach(z => {
                    const vaId = z.VA_ID;
                    const datum = formatDateForInput(new Date(z.VADatum || z.Datum));
                    const key = `${vaId}_${datum}`;
                    if (!zuordnungen[key]) zuordnungen[key] = [];
                    zuordnungen[key].push(z);
                });

                window.DienstplanObjekt.state.zuordnungen = zuordnungen;
                console.log(`[DP-Objekt] ${data.zuordnungen.length} Zuordnungen verarbeitet`);

                // Kalender neu rendern
                if (window.DienstplanObjekt.renderCalendar) {
                    window.DienstplanObjekt.renderCalendar();
                }
            }
        }

        // Fehlerbehandlung
        if (data.error) {
            console.error('[DP-Objekt] Fehler vom Backend:', data.error);
            showError(data.error);
        }
    }

    /**
     * Datum formatieren (YYYY-MM-DD)
     */
    function formatDateForInput(date) {
        if (!date) return '';
        const d = new Date(date);
        const year = d.getFullYear();
        const month = (d.getMonth() + 1).toString().padStart(2, '0');
        const day = d.getDate().toString().padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    /**
     * Fehler anzeigen
     */
    function showError(msg) {
        console.error('[DP-Objekt] Fehler:', msg);
        if (window.DienstplanObjekt && window.DienstplanObjekt.setStatus) {
            window.DienstplanObjekt.setStatus('Fehler: ' + msg);
        }

        // Optional: Fehler im UI anzeigen
        const calendarBody = document.getElementById('calendarBody');
        if (calendarBody) {
            calendarBody.innerHTML = `<div class="loading" style="color: red;">Fehler: ${msg}</div>`;
        }
    }

    /**
     * Planungsübersicht vom Backend laden
     */
    function loadPlanungsuebersicht(vonDatum, bisDatum) {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            console.log('[DP-Objekt] Lade Planungsübersicht:', vonDatum, '-', bisDatum);
            Bridge.sendEvent('loadPlanungsuebersicht', {
                von: vonDatum,
                bis: bisDatum
            });
        } else {
            console.warn('[DP-Objekt] Bridge nicht verfügbar');
            showError('Bridge nicht verfügbar');
        }
    }

    /**
     * Initiale Daten laden
     */
    function init() {
        console.log('[DP-Objekt] WebView2 Integration initialisiert');

        // Optional: Initiale Daten vom Backend anfordern
        // Wird normalerweise durch die Haupt-Logic getriggert
    }

    // Initialisierung
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Globale Funktionen für Zugriff von außen
    window.DP_Objekt_WebView2 = {
        loadPlanungsuebersicht,
        handleBridgeData
    };
})();
