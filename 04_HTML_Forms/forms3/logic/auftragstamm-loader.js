/**
 * ╔═══════════════════════════════════════════════════════════════════════════════╗
 * ║                    AUFTRAGSTAMM LOADER - GESCHÜTZTE LOGIK                     ║
 * ║                                                                               ║
 * ║  ACHTUNG: DIESE DATEI NICHT ÄNDERN!                                          ║
 * ║                                                                               ║
 * ║  Diese Datei enthält die funktionierende Lade-Logik für das Auftragstamm-    ║
 * ║  Formular. Die Logik wurde am 11.01.2026 getestet und funktioniert korrekt.  ║
 * ║                                                                               ║
 * ║  FUNKTIONALITÄT:                                                              ║
 * ║  - Lädt Aufträge ab dem heutigen Datum                                       ║
 * ║  - Sortiert chronologisch (älteste zuerst)                                   ║
 * ║  - Synchronisiert Formular-Anzeige mit Auftragsliste                         ║
 * ║  - Markiert den ersten sichtbaren Auftrag automatisch                        ║
 * ║                                                                               ║
 * ║  GRUND FÜR CLIENTSEITIGE LOGIK:                                              ║
 * ║  Die REST-API ignoriert Filter- und Sortierparameter. Daher wird             ║
 * ║  clientseitig gefiltert und sortiert.                                        ║
 * ║                                                                               ║
 * ║  Letzte funktionierende Version: 11.01.2026                                  ║
 * ║  Getestet von: Claude                                                         ║
 * ╚═══════════════════════════════════════════════════════════════════════════════╝
 */

// ============================================================================
// EXPORT: Diese Funktionen werden von frm_va_Auftragstamm.logic.js importiert
// ============================================================================

/**
 * Haupt-Lade-Funktion beim Formular-Start
 * 
 * ABLAUF:
 * 1. Combo-Boxen füllen
 * 2. URL-Parameter prüfen (spezifischer Auftrag angefordert?)
 * 3. Auftragsliste laden (ab heute, chronologisch sortiert)
 * 4. Ersten sichtbaren Auftrag laden und markieren
 * 
 * @param {Object} dependencies - Abhängigkeiten (Bridge, state, callbacks)
 */
export async function loadInitialDataProtected(dependencies) {
    const { Bridge, state, loadCombos, loadAuftrag, highlightAuftragInList, 
            renderAuftragsliste, setStatus, updateAllSubforms } = dependencies;
    
    try {
        // Combo-Boxen füllen
        await loadCombos();

        // URL-Parameter prüfen: Spezifischer Auftrag angefordert?
        // Unterstützt sowohl normale URLs als auch SHELL_PARAMS (bei srcdoc iframes von Shell)
        const urlParams = new URLSearchParams(window.location.search);
        const shellParams = window.SHELL_PARAMS || {};
        console.log('[Auftragstamm-Loader] DEBUG - shellParams:', shellParams);
        console.log('[Auftragstamm-Loader] DEBUG - urlParams id:', urlParams.get('id'), 'va_id:', urlParams.get('va_id'));
        const requestedId = urlParams.get('id') || urlParams.get('va_id') || shellParams.id || shellParams.va_id;
        console.log('[Auftragstamm-Loader] DEBUG - requestedId:', requestedId);

        if (requestedId) {
            // Spezifischen Auftrag laden (z.B. von Schnellauswahl kommend)
            console.log('[Auftragstamm-Loader] URL-Parameter id gefunden:', requestedId);
            
            // Auftragsliste laden
            await loadAuftraegeWithFilterProtected(dependencies);
            
            // Dann spezifischen Auftrag laden
            await loadAuftrag(requestedId);
            
            // Markierung in der Liste synchronisieren
            highlightAuftragInList(requestedId);
            
            setStatus('Auftrag geladen');
        } else {
            // Auftragsliste laden und ERSTEN sichtbaren Auftrag automatisch laden
            await loadAuftraegeWithFilterProtected(dependencies);
            await loadFirstVisibleAuftragProtected(dependencies);
        }

    } catch (error) {
        console.error('[Auftragstamm-Loader] Init-Fehler:', error);
    }
}

/**
 * Lädt Auftragsliste mit Filter (ab heute)
 * 
 * WICHTIG: Die API ignoriert Filter- und Sortierparameter!
 * Daher wird clientseitig gefiltert und sortiert.
 * 
 * LOGIK:
 * 1. Hole ALLE Aufträge von der API (limit: 500)
 * 2. Filtere clientseitig: Nur Aufträge mit Datum >= heute
 * 3. Sortiere clientseitig: Nach Datum aufsteigend (chronologisch)
 * 4. Speichere in state.records
 * 5. Rendere die Auftragsliste
 * 
 * @param {Object} dependencies - Abhängigkeiten
 */
export async function loadAuftraegeWithFilterProtected(dependencies) {
    const { Bridge, state, renderAuftragsliste } = dependencies;
    
    try {
        // ═══════════════════════════════════════════════════════════════
        // SCHRITT 1: Heutiges Datum ermitteln (ISO-Format für Vergleich)
        // ═══════════════════════════════════════════════════════════════
        const heute = new Date();
        const heuteISO = heute.toISOString().split('T')[0]; // Format: YYYY-MM-DD
        
        // Filter-Feld aktualisieren
        const datumInput = document.getElementById('Auftraege_ab');
        if (datumInput) {
            datumInput.value = heuteISO;
        }
        
        console.log('[Auftragstamm-Loader] Lade Auftragsliste ab:', heuteISO);
        
        // ═══════════════════════════════════════════════════════════════
        // SCHRITT 2: ALLE Aufträge von API holen
        // HINWEIS: API ignoriert datum_von und sort Parameter!
        // ═══════════════════════════════════════════════════════════════
        const result = await Bridge.execute('getAuftragListe', {
            limit: 500  // Genug um alle relevanten Aufträge zu bekommen
        });
        
        if (result.data && result.data.length > 0) {
            // ═══════════════════════════════════════════════════════════
            // SCHRITT 3: CLIENTSEITIGE Filterung - Nur Aufträge ab heute
            // ═══════════════════════════════════════════════════════════
            const gefiltert = result.data.filter(auftrag => {
                // Datum aus verschiedenen möglichen Feldnamen extrahieren
                const datumVon = (auftrag.Dat_VA_Von || auftrag.VA_DatumVon || '').substring(0, 10);
                // Nur Aufträge die heute oder später beginnen
                return datumVon >= heuteISO;
            });
            
            // ═══════════════════════════════════════════════════════════
            // SCHRITT 4: CLIENTSEITIGE Sortierung - Chronologisch
            // ═══════════════════════════════════════════════════════════
            gefiltert.sort((a, b) => {
                const vonA = (a.Dat_VA_Von || a.VA_DatumVon || '');
                const vonB = (b.Dat_VA_Von || b.VA_DatumVon || '');
                return vonA.localeCompare(vonB); // Aufsteigend = älteste zuerst
            });
            
            // ═══════════════════════════════════════════════════════════
            // SCHRITT 5: State aktualisieren und Liste rendern
            // ═══════════════════════════════════════════════════════════
            state.records = gefiltert;
            renderAuftragsliste();
            
            console.log('[Auftragstamm-Loader] Auftragsliste geladen:', 
                        gefiltert.length, 'Aufträge ab', heuteISO);
        } else {
            state.records = [];
            console.log('[Auftragstamm-Loader] Keine Aufträge gefunden');
        }
        
    } catch (error) {
        console.error('[Auftragstamm-Loader] Auftragsliste laden fehlgeschlagen:', error);
        state.records = [];
    }
}

/**
 * Lädt den ERSTEN sichtbaren Auftrag aus der Auftragsliste
 * 
 * ZWECK: Synchronisiert Formular-Anzeige mit der Listenmarkierung
 * 
 * LOGIK:
 * 1. Finde die erste Zeile in der gerenderten Tabelle
 * 2. Extrahiere die Auftrag-ID aus data-id Attribut
 * 3. Markiere die Zeile als "selected"
 * 4. Lade den Auftrag ins Formular
 * 
 * @param {Object} dependencies - Abhängigkeiten
 */
export async function loadFirstVisibleAuftragProtected(dependencies) {
    const { state, loadAuftrag, highlightAuftragInList, 
            renderAuftragsliste, setStatus } = dependencies;
    
    try {
        console.log('[Auftragstamm-Loader] Lade ersten sichtbaren Auftrag...');
        
        // ═══════════════════════════════════════════════════════════════
        // Ersten Eintrag aus der gerenderten Tabelle holen
        // ═══════════════════════════════════════════════════════════════
        const tbody = document.querySelector('#auftraegeTable tbody');
        const firstRow = tbody?.querySelector('tr');
        
        if (firstRow) {
            const auftragId = firstRow.dataset.id;
            const displayDate = firstRow.dataset.displayDate;
            
            if (auftragId) {
                console.log('[Auftragstamm-Loader] Erster sichtbarer Auftrag:', auftragId);
                
                // ═══════════════════════════════════════════════════════
                // Zeile als "selected" markieren
                // ═══════════════════════════════════════════════════════
                tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
                firstRow.classList.add('selected');
                
                // ═══════════════════════════════════════════════════════
                // State aktualisieren
                // ═══════════════════════════════════════════════════════
                state.currentVA_ID = parseInt(auftragId);
                if (displayDate) {
                    state.currentVADatum = displayDate;
                    state.currentVADatum_ID = displayDate;
                }
                state.recordIndex = 0;
                
                // ═══════════════════════════════════════════════════════
                // Auftrag ins Formular laden
                // ═══════════════════════════════════════════════════════
                await loadAuftrag(auftragId);

                // FIX 19.01.2026: Nach loadAuftrag das gewählte Datum wiederherstellen
                // loadAuftrag überschreibt state.currentVADatum mit einsatztage[0]
                // Gleiche Logik wie in setupAuftragslisteClickHandlerWithDate()
                if (displayDate) {
                    setTimeout(() => {
                        const cboVADatum = document.getElementById('cboVADatum');
                        if (cboVADatum) {
                            for (let i = 0; i < cboVADatum.options.length; i++) {
                                const optValue = cboVADatum.options[i].value;
                                if (optValue === displayDate || optValue.includes(displayDate)) {
                                    cboVADatum.selectedIndex = i;
                                    state.currentVADatum = displayDate;
                                    state.currentVADatum_ID = optValue;
                                    console.log('[Auftragstamm-Loader] VADatum wiederhergestellt:', displayDate);
                                    break;
                                }
                            }
                        }
                    }, 300);
                }

                setStatus('Auftrag geladen');
                return;
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // Fallback: Wenn Tabelle leer, versuche ersten aus state.records
        // ═══════════════════════════════════════════════════════════════
        if (state.records && state.records.length > 0) {
            const firstRec = state.records[0];
            const auftragId = firstRec.VA_ID || firstRec.ID;
            
            console.log('[Auftragstamm-Loader] Fallback: Lade ersten aus state.records:', auftragId);
            state.recordIndex = 0;
            await loadAuftrag(auftragId);
            
            renderAuftragsliste();
            highlightAuftragInList(auftragId);
            
            setStatus('Auftrag geladen');
        } else {
            console.log('[Auftragstamm-Loader] Keine Aufträge vorhanden');
            setStatus('Keine Aufträge vorhanden');
        }
        
    } catch (error) {
        console.error('[Auftragstamm-Loader] Erster Auftrag laden fehlgeschlagen:', error);
    }
}

/**
 * Markiert einen Auftrag in der Auftragsliste (rechts)
 * 
 * @param {number|string} auftragId - Die ID des zu markierenden Auftrags
 */
export function highlightAuftragInListProtected(auftragId) {
    const tbody = document.querySelector('#auftraegeTable tbody');
    if (!tbody) return;
    
    const idStr = String(auftragId);
    
    tbody.querySelectorAll('tr').forEach(row => {
        if (row.dataset.id === idStr) {
            row.classList.add('selected');
            // Scroll zur markierten Zeile
            row.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        } else {
            row.classList.remove('selected');
        }
    });
}

// ============================================================================
// VERSION INFO - Nicht ändern!
// ============================================================================
export const LOADER_VERSION = {
    version: '1.0.0',
    date: '2026-01-11',
    status: 'FUNKTIONIERT - NICHT ÄNDERN',
    testedBy: 'Claude',
    description: 'Clientseitige Filterung und Sortierung der Auftragsliste'
};
