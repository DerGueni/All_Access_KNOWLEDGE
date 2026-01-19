/**
 * =============================================================================
 * frm_va_Auftragstamm - WebView2 Integration
 * =============================================================================
 * Erweitert das Auftragstamm-Formular für WebView2-Kommunikation mit Access
 * 
 * Lädt automatisch nach dem Haupt-Script und:
 * - Registriert Access-Bridge Callbacks
 * - Überschreibt Save/Navigation mit Access-Benachrichtigung
 * - Empfängt Daten von Access (z.B. VA_ID zum Laden)
 * 
 * Erstellt: 28.12.2025 für CONSEC Security
 * =============================================================================
 */

(function() {
    'use strict';

    // Warten bis DOM und Bridge geladen sind
    function init() {
        console.log('[Auftragstamm-WebView2] Initialisiere Integration...');

        // Prüfen ob Bridge verfügbar
        if (typeof WebView2Bridge === 'undefined') {
            console.warn('[Auftragstamm-WebView2] WebView2Bridge nicht gefunden, verwende Standalone-Modus');
            return;
        }

        // Modus loggen
        console.log('[Auftragstamm-WebView2] Modus:', WebView2Bridge.getMode());

        // =====================================================================
        // DATEN VON ACCESS EMPFANGEN
        // =====================================================================
        WebView2Bridge.onDataReceived((data) => {
            console.log('[Auftragstamm-WebView2] Daten von Access empfangen:', data);

            // Auftrag laden wenn VA_ID übergeben
            if (data.VA_ID) {
                if (typeof showRecord === 'function') {
                    showRecord(data.VA_ID);
                } else if (typeof window.loadAuftrag === 'function') {
                    window.loadAuftrag(data.VA_ID);
                }
            }

            // Filter setzen wenn übergeben
            if (data.filter) {
                applyFilter(data.filter);
            }
        });

        // =====================================================================
        // FORMULAR-DATEN PROVIDER
        // =====================================================================
        WebView2Bridge.setFormDataProvider(() => {
            return collectAuftragData();
        });

        // =====================================================================
        // BUTTONS MIT ACCESS-EVENTS VERBINDEN
        // =====================================================================
        hookButtons();

        console.log('[Auftragstamm-WebView2] Integration aktiv');
    }

    // =========================================================================
    // FORMULARDATEN SAMMELN
    // =========================================================================
    function collectAuftragData() {
        const data = {
            // ID
            VA_ID: getValue('VA_ID') || getValue('currentId'),
            
            // Auftragsdaten
            VA_Auftrag: getValue('VA_Auftrag') || getValue('cboAuftrag'),
            VA_Bezeichnung: getValue('VA_Bezeichnung'),
            VA_Ort: getValue('VA_Ort') || getValue('cboOrt'),
            VA_Objekt: getValue('Objekt'),
            VA_Objekt_ID: getValue('Objekt_ID'),
            
            // Datum/Zeit
            VA_Datum_von: getValue('Datum_von'),
            VA_Datum_bis: getValue('Datum_bis') || getValue('BisNr'),
            VA_Treffpunkt_Zeit: getValue('Zeit'),
            
            // Kunde/Veranstalter
            VA_Veranstalter_ID: getValue('veranstalter_id') || getValue('VA_Veranstalter_ID'),
            VA_Ansprechpartner: getValue('VA_Ansprechpartner'),
            
            // PKW
            VA_PKW_Anzahl: getValue('PKW_Anzahl'),
            VA_Fahrtkosten: getValue('Fahrtkosten_pro_PKW'),
            
            // Dienstkleidung
            VA_Dienstkleidung_ID: getValue('Dienstkleidung'),
            
            // Status
            VA_Status: getValue('Status') || getValue('cboStatus'),
            
            // Treffpunkt
            VA_Treffpunkt: getValue('Treffpunkt'),
            
            // Timestamp
            timestamp: new Date().toISOString()
        };

        // Null-Werte entfernen
        Object.keys(data).forEach(key => {
            if (data[key] === null || data[key] === undefined || data[key] === '') {
                delete data[key];
            }
        });

        return data;
    }

    // =========================================================================
    // HELPER FUNKTIONEN
    // =========================================================================
    function getValue(id) {
        const el = document.getElementById(id);
        if (!el) return null;
        
        if (el.type === 'checkbox') {
            return el.checked;
        }
        return el.value || null;
    }

    function applyFilter(filter) {
        // Filter auf Formular anwenden
        if (filter.datum && document.getElementById('Auftraege_ab')) {
            document.getElementById('Auftraege_ab').value = filter.datum;
        }
        if (filter.status && document.getElementById('cboStatus')) {
            document.getElementById('cboStatus').value = filter.status;
        }
        
        // Liste neu laden
        if (typeof loadAuftraege === 'function') {
            loadAuftraege();
        }
    }

    // =========================================================================
    // BUTTON HOOKS
    // =========================================================================
    function hookButtons() {
        // Speichern-Button
        hookButton('btnSpeichern', () => {
            const data = collectAuftragData();
            WebView2Bridge.save(data);
        });

        // Schließen-Button
        hookButton('btnSchliessen', () => {
            WebView2Bridge.close();
        });

        // Neuer Auftrag
        hookButton('btnNeu', () => {
            WebView2Bridge.sendToAccess('newRecord', {});
        });

        // Löschen
        hookButton('btnLoeschen', () => {
            const id = getValue('VA_ID');
            if (id && confirm('Auftrag wirklich löschen?')) {
                WebView2Bridge.sendToAccess('delete', { VA_ID: id });
            }
        });

        // Kopieren
        hookButton('btnKopieren', () => {
            const data = collectAuftragData();
            WebView2Bridge.sendToAccess('copy', data);
        });

        // Drucken
        hookButton('btnDrucken', () => {
            WebView2Bridge.print();
        });

        // Mitarbeiterauswahl
        hookButton('btnMitarbeiterauswahl', () => {
            const data = collectAuftragData();
            WebView2Bridge.sendToAccess('openSchnellauswahl', {
                VA_ID: data.VA_ID,
                datum: getValue('cboVADatum')
            });
        });

        // Navigation-Buttons mit Access-Sync
        ['btnErster', 'btnVorheriger', 'btnNaechster', 'btnLetzter'].forEach(btnId => {
            const btn = document.getElementById(btnId);
            if (btn) {
                const originalClick = btn.onclick;
                btn.onclick = function(e) {
                    // Original-Handler ausführen
                    if (originalClick) originalClick.call(this, e);
                    
                    // Access über Navigation informieren
                    setTimeout(() => {
                        const id = getValue('VA_ID') || getValue('currentId');
                        if (id) {
                            WebView2Bridge.sendToAccess('recordChanged', { VA_ID: id });
                        }
                    }, 100);
                };
            }
        });
    }

    function hookButton(id, handler) {
        const btn = document.getElementById(id);
        if (btn) {
            btn.addEventListener('click', handler);
        }
    }

    // =========================================================================
    // INITIALISIERUNG
    // =========================================================================
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        // DOM bereits geladen
        setTimeout(init, 100);
    }

})();
