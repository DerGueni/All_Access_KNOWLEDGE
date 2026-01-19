/**
 * =============================================================================
 * frm_MA_Mitarbeiterstamm - WebView2 Integration
 * =============================================================================
 * Erweitert das Mitarbeiterstamm-Formular für WebView2-Kommunikation mit Access
 * 
 * Erstellt: 28.12.2025 für CONSEC Security
 * =============================================================================
 */

(function() {
    'use strict';

    function init() {
        console.log('[Mitarbeiterstamm-WebView2] Initialisiere Integration...');

        if (typeof WebView2Bridge === 'undefined') {
            console.warn('[Mitarbeiterstamm-WebView2] WebView2Bridge nicht gefunden');
            return;
        }

        console.log('[Mitarbeiterstamm-WebView2] Modus:', WebView2Bridge.getMode());

        // Daten von Access empfangen
        WebView2Bridge.onDataReceived((data) => {
            console.log('[Mitarbeiterstamm-WebView2] Daten empfangen:', data);

            if (data.MA_ID) {
                // Mitarbeiter laden
                if (typeof loadMitarbeiter === 'function') {
                    loadMitarbeiter(data.MA_ID);
                } else if (typeof showRecord === 'function') {
                    showRecord(data.MA_ID);
                }
            }
        });

        // FormData Provider setzen
        WebView2Bridge.setFormDataProvider(() => collectMitarbeiterData());

        // Buttons verbinden
        hookButtons();

        console.log('[Mitarbeiterstamm-WebView2] Integration aktiv');
    }

    function collectMitarbeiterData() {
        return {
            MA_ID: getValue('MA_ID') || getValue('currentId'),
            MA_Nachname: getValue('MA_Nachname') || getValue('Nachname'),
            MA_Vorname: getValue('MA_Vorname') || getValue('Vorname'),
            MA_Strasse: getValue('MA_Strasse') || getValue('Strasse'),
            MA_PLZ: getValue('MA_PLZ') || getValue('PLZ'),
            MA_Ort: getValue('MA_Ort') || getValue('Ort'),
            MA_TelMobil: getValue('MA_TelMobil') || getValue('Tel_Mobil'),
            MA_TelFestnetz: getValue('MA_TelFestnetz') || getValue('Tel_Festnetz'),
            MA_Email: getValue('MA_Email') || getValue('Email'),
            MA_Geburtsdatum: getValue('MA_Geburtsdatum') || getValue('Geburtsdatum'),
            MA_Anstellung: getValue('MA_Anstellung') || getValue('Anstellung'),
            MA_Aktiv: getValue('MA_Aktiv') || getValue('Ist_aktiv'),
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
        // Speichern
        hookButton('btnSpeichern', () => {
            WebView2Bridge.save(collectMitarbeiterData());
        });

        // Schließen
        hookButton('btnSchliessen', () => {
            WebView2Bridge.close();
        });

        // Neuer Mitarbeiter
        hookButton('btnNeu', () => {
            WebView2Bridge.sendToAccess('newRecord', {});
        });

        // Löschen
        hookButton('btnLoeschen', () => {
            const id = getValue('MA_ID');
            if (id && confirm('Mitarbeiter wirklich löschen?')) {
                WebView2Bridge.sendToAccess('delete', { MA_ID: id });
            }
        });

        // Zeitkonto öffnen
        hookButton('btnZeitkonto', () => {
            const id = getValue('MA_ID');
            if (id) {
                WebView2Bridge.sendToAccess('openZeitkonto', { MA_ID: id });
            }
        });

        // Dienstausweis erstellen
        hookButton('btnDienstausweis', () => {
            const id = getValue('MA_ID');
            if (id) {
                WebView2Bridge.sendToAccess('createDienstausweis', { MA_ID: id });
            }
        });
    }

    function hookButton(id, handler) {
        const btn = document.getElementById(id);
        if (btn) {
            btn.addEventListener('click', handler);
        }
    }

    // Init
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        setTimeout(init, 100);
    }

})();
