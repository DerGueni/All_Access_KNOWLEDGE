/**
 * =============================================================================
 * frm_DP_Dienstplan_MA - WebView2 Integration
 * =============================================================================
 * Erweitert die Dienstplanübersicht (MA) für WebView2-Kommunikation mit Access
 * 
 * Erstellt: 28.12.2025 für CONSEC Security
 * =============================================================================
 */

(function() {
    'use strict';

    function init() {
        console.log('[Dienstplan-MA-WebView2] Initialisiere Integration...');

        if (typeof WebView2Bridge === 'undefined') {
            console.warn('[Dienstplan-MA-WebView2] WebView2Bridge nicht gefunden');
            return;
        }

        // Daten von Access empfangen
        WebView2Bridge.onDataReceived((data) => {
            console.log('[Dienstplan-MA-WebView2] Daten empfangen:', data);

            // Startdatum setzen
            if (data.startDatum) {
                const datumInput = document.getElementById('startDatum') || document.getElementById('Startdatum');
                if (datumInput) {
                    datumInput.value = data.startDatum;
                    if (typeof loadDienstplan === 'function') {
                        loadDienstplan();
                    }
                }
            }

            // Anstellungsart filtern
            if (data.anstellung) {
                const select = document.getElementById('anstellung') || document.getElementById('Anstellung');
                if (select) {
                    select.value = data.anstellung;
                }
            }
        });

        // Buttons verbinden
        hookButtons();

        console.log('[Dienstplan-MA-WebView2] Integration aktiv');
    }

    function hookButtons() {
        // Dienstpläne senden
        hookButton('btnDienstplaeneSenden', () => {
            const bisDatum = getValue('bisDatum') || getValue('Dienstplaene_senden_bis');
            WebView2Bridge.sendToAccess('sendDienstplaene', { 
                bisDatum: bisDatum 
            });
        });

        // Übersicht drucken
        hookButton('btnUebersichtDrucken', () => {
            WebView2Bridge.sendToAccess('printUebersicht', {
                startDatum: getValue('startDatum'),
                anstellung: getValue('anstellung')
            });
        });

        // Einzeldienstpläne
        hookButton('btnEinzeldienstplaene', () => {
            WebView2Bridge.sendToAccess('openEinzeldienstplaene', {});
        });

        // Mitarbeiter anklicken -> Details öffnen
        document.querySelectorAll('.mitarbeiter-row, [data-ma-id]').forEach(row => {
            row.addEventListener('dblclick', () => {
                const maId = row.dataset.maId || row.getAttribute('data-ma-id');
                if (maId) {
                    WebView2Bridge.sendToAccess('openMitarbeiter', { MA_ID: maId });
                }
            });
        });

        // Auftrag anklicken -> Auftrag öffnen
        document.querySelectorAll('.auftrag-cell, [data-va-id]').forEach(cell => {
            cell.addEventListener('dblclick', () => {
                const vaId = cell.dataset.vaId || cell.getAttribute('data-va-id');
                if (vaId) {
                    WebView2Bridge.sendToAccess('openAuftrag', { VA_ID: vaId });
                }
            });
        });
    }

    function getValue(id) {
        const el = document.getElementById(id);
        return el ? el.value : null;
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
