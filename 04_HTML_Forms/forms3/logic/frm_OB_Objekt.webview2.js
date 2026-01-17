/**
 * frm_OB_Objekt.webview2.js
 * WebView2 Bridge Integration für Objekt-Stammdaten
 * Version 2.0
 */

(function() {
    'use strict';

    const isWebView2 = typeof window.chrome !== 'undefined' &&
                       typeof window.chrome.webview !== 'undefined';

    if (!isWebView2) {
        console.log('[OB-Objekt] Nicht in WebView2 - Bridge-Integration übersprungen');
        return;
    }

    console.log('[OB-Objekt] WebView2 Bridge Integration aktiv');

    // Bridge Event-Handler registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
        console.log('[OB-Objekt] Bridge Event-Listener registriert');
    }

    /**
     * Bridge Event-Handler
     * Verarbeitet Daten vom Access Backend
     */
    function handleBridgeData(data) {
        console.log('[OB-Objekt] Bridge Data empfangen:', data);

        // Objektliste
        if (data.type === 'objektListe' && data.records) {
            if (window.ObjektStamm && window.ObjektStamm.state) {
                window.ObjektStamm.state.records = data.records || [];
                console.log(`[OB-Objekt] ${data.records.length} Objekte geladen`);

                // Liste neu rendern
                if (window.ObjektStamm.renderList) {
                    window.ObjektStamm.renderList();
                }

                // Erstes Objekt anzeigen
                if (data.records.length > 0 && window.ObjektStamm.gotoRecord) {
                    window.ObjektStamm.gotoRecord(0);
                }
            }
        }

        // Objekt-Details
        if (data.type === 'objektDetail' && data.objekt) {
            displayObjektDetail(data.objekt);
        }

        // Kunden-Lookup für Dropdown
        if (data.type === 'kundenListe' && data.kunden) {
            fillKundenDropdown(data.kunden);
        }

        // Speichern-Erfolg
        if (data.type === 'saveSuccess') {
            console.log('[OB-Objekt] Speichern erfolgreich');
            if (window.ObjektStamm && window.ObjektStamm.setStatus) {
                window.ObjektStamm.setStatus('Gespeichert');
            }
            // Liste neu laden
            loadObjektListe();
        }

        // Löschen-Erfolg
        if (data.type === 'deleteSuccess') {
            console.log('[OB-Objekt] Löschen erfolgreich');
            if (window.ObjektStamm && window.ObjektStamm.setStatus) {
                window.ObjektStamm.setStatus('Gelöscht');
            }
            // Liste neu laden
            loadObjektListe();
        }

        // Fehlerbehandlung
        if (data.error) {
            console.error('[OB-Objekt] Fehler vom Backend:', data.error);
            showError(data.error);
        }
    }

    /**
     * Objekt-Details anzeigen
     */
    function displayObjektDetail(objekt) {
        const fields = [
            'Objekt_ID', 'Objekt_Name', 'Objekt_Strasse', 'Objekt_PLZ',
            'Objekt_Ort', 'Objekt_Status', 'Objekt_Kunde', 'Objekt_Ansprechpartner',
            'Objekt_Telefon', 'Objekt_Email', 'Objekt_Bemerkungen'
        ];

        fields.forEach(field => {
            const element = document.getElementById(field);
            if (element) {
                element.value = objekt[field] || '';
            }
        });

        console.log('[OB-Objekt] Objekt-Details angezeigt:', objekt.Objekt_ID);

        // Positionen-Subform aktualisieren
        const iframe = document.getElementById('iframe_Positionen');
        if (iframe && iframe.contentWindow) {
            iframe.contentWindow.postMessage({
                action: 'setObjektID',
                objektId: objekt.Objekt_ID
            }, '*');
        }
    }

    /**
     * Kunden-Dropdown befüllen
     */
    function fillKundenDropdown(kunden) {
        const dropdown = document.getElementById('Objekt_Kunde');
        if (!dropdown) return;

        dropdown.innerHTML = '<option value="">-- Bitte wählen --</option>';
        kunden.forEach(kunde => {
            const option = document.createElement('option');
            option.value = kunde.kun_Id;
            option.textContent = kunde.kun_Firma;
            dropdown.appendChild(option);
        });

        console.log('[OB-Objekt] Kunden-Dropdown befüllt:', kunden.length);
    }

    /**
     * Objektliste vom Backend laden
     */
    function loadObjektListe(nurAktive = true) {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            console.log('[OB-Objekt] Lade Objektliste, nurAktive:', nurAktive);
            Bridge.sendEvent('loadObjektListe', {
                nurAktive: nurAktive
            });
        } else {
            console.warn('[OB-Objekt] Bridge nicht verfügbar');
            showError('Bridge nicht verfügbar');
        }
    }

    /**
     * Objekt-Details vom Backend laden
     */
    function loadObjektDetail(objektId) {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            console.log('[OB-Objekt] Lade Objekt-Details:', objektId);
            Bridge.sendEvent('loadObjektDetail', {
                objektId: objektId
            });
        } else {
            console.warn('[OB-Objekt] Bridge nicht verfügbar');
            showError('Bridge nicht verfügbar');
        }
    }

    /**
     * Objekt speichern
     */
    function saveObjekt(objektData) {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            console.log('[OB-Objekt] Speichere Objekt:', objektData);
            Bridge.sendEvent('saveObjekt', objektData);
        } else {
            console.warn('[OB-Objekt] Bridge nicht verfügbar');
            showError('Bridge nicht verfügbar');
        }
    }

    /**
     * Objekt löschen
     */
    function deleteObjekt(objektId) {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            console.log('[OB-Objekt] Lösche Objekt:', objektId);
            Bridge.sendEvent('deleteObjekt', {
                objektId: objektId
            });
        } else {
            console.warn('[OB-Objekt] Bridge nicht verfügbar');
            showError('Bridge nicht verfügbar');
        }
    }

    /**
     * Kunden-Liste für Dropdown laden
     */
    function loadKundenListe() {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            console.log('[OB-Objekt] Lade Kunden-Liste für Dropdown');
            Bridge.sendEvent('loadKundenListe', {});
        }
    }

    /**
     * Fehler anzeigen
     */
    function showError(msg) {
        console.error('[OB-Objekt] Fehler:', msg);
        if (window.ObjektStamm && window.ObjektStamm.setStatus) {
            window.ObjektStamm.setStatus('Fehler: ' + msg);
        }
        alert('Fehler: ' + msg);
    }

    /**
     * Initiale Daten laden
     */
    function init() {
        console.log('[OB-Objekt] WebView2 Integration initialisiert');

        // Kunden-Liste für Dropdown laden
        loadKundenListe();

        // Optional: Objektliste initialisieren
        // Wird normalerweise durch die Haupt-Logic getriggert
    }

    // Initialisierung
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Globale Funktionen für Zugriff von außen
    window.OB_Objekt_WebView2 = {
        loadObjektListe,
        loadObjektDetail,
        saveObjekt,
        deleteObjekt,
        loadKundenListe,
        handleBridgeData
    };
})();
