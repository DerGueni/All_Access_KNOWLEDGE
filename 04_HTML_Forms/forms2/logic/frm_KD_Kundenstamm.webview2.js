/**
 * =============================================================================
 * frm_KD_Kundenstamm - WebView2 Integration
 * =============================================================================
 * Erweitert das Kundenstamm-Formular für WebView2-Kommunikation mit Access
 * 
 * Erstellt: 28.12.2025 für CONSEC Security
 * =============================================================================
 */

(function() {
    'use strict';

    function init() {
        console.log('[Kundenstamm-WebView2] Initialisiere Integration...');

        if (typeof WebView2Bridge === 'undefined') {
            console.warn('[Kundenstamm-WebView2] WebView2Bridge nicht gefunden');
            return;
        }

        // Daten von Access empfangen
        WebView2Bridge.onDataReceived((data) => {
            console.log('[Kundenstamm-WebView2] Daten empfangen:', data);

            if (data.KD_ID || data.kun_Id) {
                const id = data.KD_ID || data.kun_Id;
                if (typeof loadKunde === 'function') {
                    loadKunde(id);
                } else if (typeof showRecord === 'function') {
                    showRecord(id);
                }
            }
        });

        // FormData Provider
        WebView2Bridge.setFormDataProvider(() => collectKundenData());

        // Buttons verbinden
        hookButtons();

        console.log('[Kundenstamm-WebView2] Integration aktiv');
    }

    function collectKundenData() {
        return {
            kun_Id: getValue('kun_Id') || getValue('KD_ID') || getValue('currentId'),
            kun_Firma: getValue('kun_Firma') || getValue('Firma'),
            kun_Kuerzel: getValue('kun_Kuerzel') || getValue('Kunden_Kuerzel'),
            kun_Strasse: getValue('kun_Strasse') || getValue('Strasse'),
            kun_PLZ: getValue('kun_PLZ') || getValue('PLZ'),
            kun_Ort: getValue('kun_Ort') || getValue('Ort'),
            kun_Land: getValue('kun_Land') || getValue('Land'),
            kun_Telefon: getValue('kun_Telefon') || getValue('Telefon'),
            kun_Email: getValue('kun_Email') || getValue('E_Mail'),
            kun_Homepage: getValue('kun_Homepage') || getValue('Homepage'),
            kun_IBAN: getValue('kun_IBAN') || getValue('IBAN'),
            kun_BIC: getValue('kun_BIC') || getValue('BIC'),
            kun_Aktiv: getValue('kun_Aktiv') || getValue('Ist_aktiv'),
            timestamp: new Date().toISOString()
        };
    }

    function getValue(id) {
        const el = document.getElementById(id);
        if (!el) return null;
        if (el.type === 'checkbox') return el.checked;
        return el.value || null;
    }

    function hookButtons() {
        hookButton('btnSpeichern', () => {
            WebView2Bridge.save(collectKundenData());
        });

        hookButton('btnSchliessen', () => {
            WebView2Bridge.close();
        });

        hookButton('btnNeu', () => {
            WebView2Bridge.sendToAccess('newRecord', {});
        });

        hookButton('btnLoeschen', () => {
            const id = getValue('kun_Id') || getValue('KD_ID');
            if (id && confirm('Kunde wirklich löschen?')) {
                WebView2Bridge.sendToAccess('delete', { KD_ID: id });
            }
        });

        hookButton('btnVerrechnungssaetze', () => {
            const id = getValue('kun_Id') || getValue('KD_ID');
            if (id) {
                WebView2Bridge.sendToAccess('openVerrechnungssaetze', { KD_ID: id });
            }
        });

        hookButton('btnUmsatzauswertung', () => {
            const id = getValue('kun_Id') || getValue('KD_ID');
            if (id) {
                WebView2Bridge.sendToAccess('openUmsatzauswertung', { KD_ID: id });
            }
        });
    }

    function hookButton(id, handler) {
        const btn = document.getElementById(id);
        if (btn) {
            btn.addEventListener('click', handler);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        setTimeout(init, 100);
    }

})();
