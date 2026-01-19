/**
 * =============================================================================
 * frm_MA_VA_Schnellauswahl - WebView2 Integration
 * =============================================================================
 * Erweitert die Mitarbeiter-Schnellauswahl für WebView2-Kommunikation mit Access
 * 
 * Erstellt: 28.12.2025 für CONSEC Security
 * =============================================================================
 */

(function() {
    'use strict';

    function init() {
        console.log('[Schnellauswahl-WebView2] Initialisiere Integration...');

        if (typeof WebView2Bridge === 'undefined') {
            console.warn('[Schnellauswahl-WebView2] WebView2Bridge nicht gefunden');
            return;
        }

        // Daten von Access empfangen (Auftrag + Datum)
        WebView2Bridge.onDataReceived((data) => {
            console.log('[Schnellauswahl-WebView2] Daten empfangen:', data);

            if (data.VA_ID) {
                // Auftrag laden
                if (typeof loadAuftrag === 'function') {
                    loadAuftrag(data.VA_ID);
                }
            }

            if (data.datum) {
                const datumSelect = document.getElementById('datum') || document.getElementById('cboVADatum');
                if (datumSelect) {
                    datumSelect.value = data.datum;
                }
            }
        });

        // Buttons verbinden
        hookButtons();

        console.log('[Schnellauswahl-WebView2] Integration aktiv');
    }

    function hookButtons() {
        // Zurück zum Auftrag
        hookButton('btnZurueck', () => {
            WebView2Bridge.close();
        });

        // Nur Selektierte anfragen
        hookButton('btnNurSelektierteAnfragen', () => {
            const selected = getSelectedMitarbeiter();
            WebView2Bridge.sendToAccess('anfrageSelektierte', { 
                mitarbeiter: selected,
                VA_ID: getValue('VA_ID'),
                datum: getValue('datum')
            });
        });

        // Alle Mitarbeiter anfragen
        hookButton('btnAlleMitarbeiterAnfragen', () => {
            WebView2Bridge.sendToAccess('anfrageAlle', { 
                VA_ID: getValue('VA_ID'),
                datum: getValue('datum'),
                anstellung: getValue('anstellung'),
                kategorie: getValue('kategorie')
            });
        });

        // Auswählen-Button (Mitarbeiter zur Schicht hinzufügen)
        hookButton('btnAuswaehlen', () => {
            const selected = getSelectedMitarbeiter();
            if (selected.length > 0) {
                WebView2Bridge.sendToAccess('zuordnungErstellen', {
                    mitarbeiter: selected,
                    VA_ID: getValue('VA_ID'),
                    datum: getValue('datum'),
                    schicht_id: getValue('schicht_id')
                });
            }
        });

        // Entfernen-Button
        hookButton('btnEntfernen', () => {
            const selected = getSelectedGeplant();
            if (selected.length > 0) {
                WebView2Bridge.sendToAccess('zuordnungEntfernen', {
                    zuordnungen: selected
                });
            }
        });

        // Doppelklick auf verfügbaren Mitarbeiter
        document.querySelectorAll('.ma-verfuegbar, [data-ma-verfuegbar]').forEach(row => {
            row.addEventListener('dblclick', () => {
                const maId = row.dataset.maId;
                if (maId) {
                    WebView2Bridge.sendToAccess('zuordnungErstellen', {
                        mitarbeiter: [maId],
                        VA_ID: getValue('VA_ID'),
                        datum: getValue('datum')
                    });
                }
            });
        });
    }

    function getSelectedMitarbeiter() {
        const selected = [];
        document.querySelectorAll('.ma-verfuegbar.selected, [data-ma-selected="true"]').forEach(el => {
            const maId = el.dataset.maId;
            if (maId) selected.push(maId);
        });
        return selected;
    }

    function getSelectedGeplant() {
        const selected = [];
        document.querySelectorAll('.ma-geplant.selected, [data-zuordnung-selected="true"]').forEach(el => {
            const id = el.dataset.zuordnungId;
            if (id) selected.push(id);
        });
        return selected;
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
