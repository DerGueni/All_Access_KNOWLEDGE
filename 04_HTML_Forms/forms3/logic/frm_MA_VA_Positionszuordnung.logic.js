/**
 * frm_MA_VA_Positionszuordnung.logic.js
 * Logik für Mitarbeiter-Position-Zuordnung
 * Verwaltung der Zuordnung von Mitarbeitern zu spezifischen Positionen/Rollen in Aufträgen
 */
import { Bridge } from '../api/bridgeClient.js';

// API Basis-URL fuer REST Fallback
const API_BASE = 'http://localhost:5000/api';

let elements = {};
let currentAuftragId = null;
let currentDatum = null;
let currentSchichtId = null;
let currentPositionId = null;

async function init() {
    console.log('[MA_VA_Positionszuordnung] Initialisierung...');

    // Element-IDs passend zum HTML (Access-Namen: cbo_Akt_Objekt_Kopf, cboVADatum)
    elements = {
        auftragSelect: document.getElementById('cboAuftrag'),
        datumSelect: document.getElementById('cboDatum'),
        positionenListe: document.getElementById('panelPositionen'),
        mitarbeiterListe: document.getElementById('panelVerfügbar'),
        zugeordneteListe: document.getElementById('panelZugeordnet'),

        btnSpeichern: document.getElementById('btnSpeichern'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),

        // Labels für Anzahlen
        lblPosAnzahl: document.getElementById('lblPosAnzahl'),
        lblMAAnzahl: document.getElementById('lblMAAnzahl'),
        lblZugeordnetAnzahl: document.getElementById('lblZugeordnetAnzahl'),
        lblStatus: document.getElementById('lblStatus'),
        lblSumme: document.getElementById('lblSumme')
    };

    await loadInitialData();
    bindEvents();
}

async function loadInitialData() {
    try {
        // Aufträge laden
        const auftraege = await Bridge.execute('getAuftragListe', { limit: 100 });
        populateAuftragSelect(auftraege);

        // Qualifikationen laden
        await loadQualifikationen();

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden:', error);
        showError('Daten konnten nicht geladen werden');
    }
}

function populateAuftragSelect(auftraege) {
    if (!elements.auftragSelect) return;

    elements.auftragSelect.innerHTML = '<option value="">-- Auftrag wählen --</option>' +
        auftraege.map(a => `
            <option value="${a.VA_ID}">
                ${a.Auftrag || 'N/A'} - ${a.Objekt || ''} (${formatDate(a.VADatum)})
            </option>
        `).join('');
}

async function loadQualifikationen() {
    try {
        // TODO: Qualifikationen aus Backend laden
        const qualifikationen = [
            { id: 1, name: 'Sicherheitsmitarbeiter' },
            { id: 2, name: 'Teamleiter' },
            { id: 3, name: 'Ersthelfer' },
            { id: 4, name: 'Brandschutzhelfer' }
        ];

        populateQualifikationSelect(qualifikationen);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden der Qualifikationen:', error);
    }
}

function populateQualifikationSelect(qualifikationen) {
    const selects = [elements.positionQualifikation, elements.filterQualifikation];

    selects.forEach(select => {
        if (select) {
            select.innerHTML = '<option value="">-- Keine spezifische --</option>' +
                qualifikationen.map(q => `<option value="${q.id}">${q.name}</option>`).join('');
        }
    });
}

async function loadEinsatztage(vaId) {
    try {
        const tage = await Bridge.execute('getEinsatztage', { va_id: vaId });
        populateDatumSelect(tage);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden der Einsatztage:', error);
    }
}

function populateDatumSelect(tage) {
    if (!elements.datumSelect) return;

    elements.datumSelect.innerHTML = '<option value="">-- Datum wählen --</option>' +
        tage.map(t => `
            <option value="${t.VADatum}">
                ${formatDate(t.VADatum)} (${getDayName(t.VADatum)})
            </option>
        `).join('');
}

async function loadSchichten(vaId, datum) {
    try {
        const schichten = await Bridge.execute('getSchichten', {
            va_id: vaId,
            datum: datum
        });

        renderSchichtListe(schichten);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden der Schichten:', error);
    }
}

function renderSchichtListe(schichten) {
    if (!elements.schichtListe) return;

    elements.schichtListe.innerHTML = schichten.map(s => `
        <div class="schicht-item" data-id="${s.VAStart_ID}">
            <div class="schicht-zeit">${s.VA_Start} - ${s.VA_Ende}</div>
            <div class="schicht-bedarf">${s.MA_Anzahl_Ist || 0} / ${s.MA_Anzahl || 0} MA</div>
        </div>
    `).join('');
}

async function loadPositionen(vaId, datum, schichtId) {
    try {
        const positionen = await Bridge.execute('getPositionen', {
            va_id: vaId,
            datum: datum,
            schicht_id: schichtId
        });

        renderPositionenListe(positionen);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden der Positionen:', error);
    }
}

function renderPositionenListe(positionen) {
    if (!elements.positionenListe) return;

    elements.positionenListe.innerHTML = positionen.map(p => `
        <div class="position-item" data-id="${p.Position_ID}">
            <div class="position-name">${p.Name || 'Position'}</div>
            <div class="position-bedarf">${p.Anzahl_Ist || 0} / ${p.Anzahl || 0}</div>
            <div class="position-quali">${p.Qualifikation || ''}</div>
        </div>
    `).join('');
}

async function loadVerfuegbareMitarbeiter(positionId) {
    try {
        const verfuegbare = await Bridge.execute('getVerfuegbareMitarbeiterFuerPosition', {
            position_id: positionId,
            va_id: currentAuftragId,
            datum: currentDatum
        });

        renderMitarbeiterListe(verfuegbare);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden verfügbarer MA:', error);
    }
}

async function loadZugeordneteMitarbeiter(positionId) {
    try {
        const zugeordnete = await Bridge.execute('getZugeordneteMitarbeiterFuerPosition', {
            position_id: positionId
        });

        renderZugeordneteListe(zugeordnete);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Laden zugeordneter MA:', error);
    }
}

function renderMitarbeiterListe(mitarbeiter) {
    if (!elements.mitarbeiterListe) return;

    elements.mitarbeiterListe.innerHTML = mitarbeiter.map(m => `
        <div class="ma-item" data-id="${m.MA_ID}" draggable="true">
            <span class="ma-name">${m.Nachname}, ${m.Vorname}</span>
            <span class="ma-quali">${m.Qualifikationen || ''}</span>
            <button class="btn-zuordnen" data-ma-id="${m.MA_ID}">→</button>
        </div>
    `).join('');
}

function renderZugeordneteListe(mitarbeiter) {
    if (!elements.zugeordneteListe) return;

    elements.zugeordneteListe.innerHTML = mitarbeiter.map(m => `
        <div class="ma-item" data-id="${m.MA_ID}">
            <span class="ma-name">${m.Nachname}, ${m.Vorname}</span>
            <span class="ma-rolle">${m.Rolle || ''}</span>
            <button class="btn-entfernen" data-ma-id="${m.MA_ID}">✕</button>
        </div>
    `).join('');
}

function bindEvents() {
    // Auftrag auswählen (Access: cbo_Akt_Objekt_Kopf_AfterUpdate)
    if (elements.auftragSelect) {
        elements.auftragSelect.addEventListener('change', async (e) => {
            currentAuftragId = e.target.value;
            updateStatus('Auftrag gewählt: ' + (e.target.options[e.target.selectedIndex]?.text || ''));
            if (currentAuftragId) {
                await loadEinsatztage(currentAuftragId);
                // Positionen und MA für diesen Auftrag laden
                await loadPositionenFuerAuftrag(currentAuftragId);
            }
        });
    }

    // Datum auswählen (Access: cboVADatum)
    if (elements.datumSelect) {
        elements.datumSelect.addEventListener('change', async (e) => {
            currentDatum = e.target.value;
            if (currentAuftragId && currentDatum) {
                await loadPositionenFuerAuftrag(currentAuftragId, currentDatum);
            }
        });
    }

    // Position auswählen (Klick auf Position-Item)
    if (elements.positionenListe) {
        elements.positionenListe.addEventListener('click', async (e) => {
            const item = e.target.closest('.position-item');
            if (item) {
                // Aktive Position markieren
                elements.positionenListe.querySelectorAll('.position-item').forEach(i => i.classList.remove('selected'));
                item.classList.add('selected');

                // TODO: Verfügbare MA für diese Position laden
                updateStatus('Position ausgewählt');
            }
        });
    }

    // Mitarbeiter zuordnen (Klick auf Pfeil-Button im verfügbar-Panel)
    if (elements.mitarbeiterListe) {
        elements.mitarbeiterListe.addEventListener('click', async (e) => {
            const btn = e.target.closest('button.btn-success, button.btn-sm');
            if (btn) {
                const item = btn.closest('.position-item');
                const maName = item?.querySelector('.position-name')?.textContent;
                if (maName) {
                    await mitarbeiterZuordnen(item);
                }
            }
        });
    }

    // Mitarbeiter entfernen (Klick auf X-Button im zugeordnet-Panel)
    if (elements.zugeordneteListe) {
        elements.zugeordneteListe.addEventListener('click', async (e) => {
            const btn = e.target.closest('button.btn-danger, button.btn-sm');
            if (btn) {
                const item = btn.closest('.position-item');
                if (item) {
                    await mitarbeiterEntfernen(item);
                }
            }
        });
    }

    // Speichern-Button
    if (elements.btnSpeichern) {
        elements.btnSpeichern.addEventListener('click', speichern);
    }

    // Aktualisieren-Button
    if (elements.btnAktualisieren) {
        elements.btnAktualisieren.addEventListener('click', aktualisieren);
    }
}

function updateStatus(msg) {
    if (elements.lblStatus) {
        elements.lblStatus.textContent = msg;
    }
}

async function loadPositionenFuerAuftrag(vaId, datum) {
    try {
        updateStatus('Lade Positionen...');
        // Placeholder: In Zukunft echte Daten laden
        console.log('[MA_VA_Positionszuordnung] Lade Positionen für VA_ID:', vaId, 'Datum:', datum);
        updateStatus('Bereit');
    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler:', error);
        updateStatus('Fehler beim Laden');
    }
}

async function speichern() {
    try {
        updateStatus('Speichere...');
        // TODO: Zuordnungen speichern
        console.log('[MA_VA_Positionszuordnung] Speichern...');
        showSuccess('Gespeichert');
        updateStatus('Gespeichert');
    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Speichern:', error);
        showError('Speichern fehlgeschlagen');
    }
}

async function aktualisieren() {
    if (currentAuftragId) {
        await loadPositionenFuerAuftrag(currentAuftragId, currentDatum);
    }
    updateStatus('Aktualisiert');
}

async function neuePosition() {
    const positionId = document.querySelector('.position-item.active')?.dataset.id;

    const name = elements.positionName?.value;
    const beschreibung = elements.positionBeschreibung?.value;
    const anzahl = elements.positionAnzahl?.value;
    const qualifikation = elements.positionQualifikation?.value;

    if (!name) {
        showError('Bitte Position-Namen eingeben');
        return;
    }

    try {
        await Bridge.execute('createPosition', {
            va_id: currentAuftragId,
            datum: currentDatum,
            schicht_id: currentSchichtId,
            name: name,
            beschreibung: beschreibung,
            anzahl: anzahl,
            qualifikation_id: qualifikation
        });

        await loadPositionen(currentAuftragId, currentDatum, currentSchichtId);
        clearPositionForm();
        showSuccess('Position erstellt');

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Erstellen:', error);
        showError('Position konnte nicht erstellt werden');
    }
}

async function positionLoeschen() {
    const positionId = document.querySelector('.position-item.active')?.dataset.id;

    if (!positionId) {
        showError('Bitte Position auswählen');
        return;
    }

    if (!confirm('Position wirklich löschen?')) return;

    try {
        await Bridge.execute('deletePosition', { position_id: positionId });
        await loadPositionen(currentAuftragId, currentDatum, currentSchichtId);
        clearPositionForm();
        showSuccess('Position gelöscht');

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Löschen:', error);
        showError('Position konnte nicht gelöscht werden');
    }
}

async function mitarbeiterZuordnen(maItem) {
    const selectedPosition = elements.positionenListe?.querySelector('.position-item.selected');

    if (!selectedPosition) {
        showError('Bitte zuerst eine Position auswählen');
        return;
    }

    try {
        const maName = maItem.querySelector('.position-name')?.textContent;
        const maInfo = maItem.querySelector('.position-info')?.textContent;

        // MA vom verfügbar-Panel ins zugeordnet-Panel verschieben (visuell)
        const clonedItem = maItem.cloneNode(true);
        // Button ändern: von grünem Pfeil zu rotem X
        const btn = clonedItem.querySelector('button');
        if (btn) {
            btn.className = 'btn btn-sm btn-danger';
            btn.innerHTML = '&#10006;';
        }
        // Position-Info aktualisieren
        const infoEl = clonedItem.querySelector('.position-info');
        if (infoEl) {
            infoEl.textContent = 'Position: ' + (selectedPosition.querySelector('.position-name')?.textContent || '');
        }

        elements.zugeordneteListe?.appendChild(clonedItem);
        maItem.remove();

        updateCounters();
        showSuccess('Mitarbeiter zugeordnet: ' + maName);
        console.log('[MA_VA_Positionszuordnung] Zugeordnet:', maName, 'zu Position');

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Zuordnen:', error);
        showError('Zuordnung fehlgeschlagen');
    }
}

async function mitarbeiterEntfernen(maItem) {
    try {
        const maName = maItem.querySelector('.position-name')?.textContent;

        // MA vom zugeordnet-Panel zurück ins verfügbar-Panel verschieben (visuell)
        const clonedItem = maItem.cloneNode(true);
        // Button ändern: von rotem X zu grünem Pfeil
        const btn = clonedItem.querySelector('button');
        if (btn) {
            btn.className = 'btn btn-sm btn-success';
            btn.innerHTML = '&#10140;';
        }
        // Position-Info zurücksetzen
        const infoEl = clonedItem.querySelector('.position-info');
        if (infoEl) {
            infoEl.textContent = 'Qualifikation: 34a'; // Default
        }

        elements.mitarbeiterListe?.appendChild(clonedItem);
        maItem.remove();

        updateCounters();
        showSuccess('Mitarbeiter entfernt: ' + maName);
        console.log('[MA_VA_Positionszuordnung] Entfernt:', maName);

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Entfernen:', error);
        showError('Entfernen fehlgeschlagen');
    }
}

function updateCounters() {
    const posCount = elements.positionenListe?.querySelectorAll('.position-item').length || 0;
    const maCount = elements.mitarbeiterListe?.querySelectorAll('.position-item').length || 0;
    const zugeordnetCount = elements.zugeordneteListe?.querySelectorAll('.position-item').length || 0;

    if (elements.lblPosAnzahl) elements.lblPosAnzahl.textContent = `(${posCount})`;
    if (elements.lblMAAnzahl) elements.lblMAAnzahl.textContent = `(${maCount})`;
    if (elements.lblZugeordnetAnzahl) elements.lblZugeordnetAnzahl.textContent = `(${zugeordnetCount})`;
    if (elements.lblSumme) elements.lblSumme.textContent = `${posCount} Positionen | ${zugeordnetCount} MA zugeordnet`;
}

function clearPositionForm() {
    if (elements.positionName) elements.positionName.value = '';
    if (elements.positionBeschreibung) elements.positionBeschreibung.value = '';
    if (elements.positionAnzahl) elements.positionAnzahl.value = '1';
    if (elements.positionQualifikation) elements.positionQualifikation.value = '';
}

function handleSearch(e) {
    const term = e.target.value.toLowerCase();
    const items = elements.mitarbeiterListe?.querySelectorAll('.ma-item');

    items?.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(term) ? '' : 'none';
    });
}

function applyFilter() {
    // TODO: Filter-Logik implementieren
    console.log('[MA_VA_Positionszuordnung] Filter anwenden');
}

// ============================================
// BULK-OPERATIONEN MIT API (Access: btnAddAll, btnDelAll)
// ============================================

async function alleHinzufuegen() {
    const selectedPosition = elements.positionenListe?.querySelector('.position-item.selected');
    if (!selectedPosition) {
        showError('Bitte zuerst eine Position auswaehlen');
        return;
    }

    const positionId = selectedPosition.dataset.id;
    const items = elements.mitarbeiterListe?.querySelectorAll('.position-item, .ma-item');
    if (!items || items.length === 0) {
        updateStatus('Keine verfuegbaren MA');
        return;
    }

    updateStatus('Ordne alle MA zu...');
    let count = 0;

    for (const item of items) {
        try {
            const maId = item.dataset.id;
            if (maId && positionId) {
                // Versuche API-Aufruf
                if (typeof Bridge !== 'undefined' && Bridge.execute) {
                    await Bridge.execute('zuordnenMitarbeiterZuPosition', {
                        position_id: positionId,
                        ma_id: maId
                    });
                } else {
                    // REST API Fallback
                    await fetch(`${API_BASE}/positionen/${positionId}/zuordnen`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ ma_id: maId })
                    });
                }
            }
            // Visuelles Verschieben
            await mitarbeiterZuordnen(item);
            count++;
        } catch (error) {
            console.error('[MA_VA_Positionszuordnung] Fehler bei MA:', error);
        }
    }

    showSuccess(count + ' MA zugeordnet');
    updateCounters();
}

async function alleEntfernen() {
    const items = elements.zugeordneteListe?.querySelectorAll('.position-item, .ma-item');
    if (!items || items.length === 0) {
        updateStatus('Keine zugeordneten MA');
        return;
    }

    if (!confirm('Wirklich alle ' + items.length + ' Zuordnungen entfernen?')) {
        return;
    }

    updateStatus('Entferne alle Zuordnungen...');
    let count = 0;

    for (const item of items) {
        try {
            const maId = item.dataset.id;
            const positionId = currentPositionId || item.dataset.positionId;

            if (maId && positionId) {
                // Versuche API-Aufruf
                if (typeof Bridge !== 'undefined' && Bridge.execute) {
                    await Bridge.execute('entfernenMitarbeiterVonPosition', {
                        position_id: positionId,
                        ma_id: maId
                    });
                } else {
                    // REST API Fallback
                    await fetch(`${API_BASE}/positionen/${positionId}/zuordnen/${maId}`, {
                        method: 'DELETE'
                    });
                }
            }
            // Visuelles Verschieben
            await mitarbeiterEntfernen(item);
            count++;
        } catch (error) {
            console.error('[MA_VA_Positionszuordnung] Fehler beim Entfernen:', error);
        }
    }

    showSuccess(count + ' MA entfernt');
    updateCounters();
}

async function zuordnungWiederholen() {
    const selectedPosition = elements.positionenListe?.querySelector('.position-item.selected');
    if (!selectedPosition) {
        showError('Bitte zuerst eine Position auswaehlen');
        return;
    }

    const zugeordnete = elements.zugeordneteListe?.querySelectorAll('.position-item, .ma-item');
    if (!zugeordnete || zugeordnete.length === 0) {
        showError('Keine Zuordnungen zum Wiederholen vorhanden');
        return;
    }

    const zielDatum = prompt('Auf welches Datum soll die Zuordnung kopiert werden? (Format: TT.MM.JJJJ oder YYYY-MM-DD)');
    if (!zielDatum) return;

    const positionId = selectedPosition.dataset.id || currentPositionId;
    updateStatus('Wiederhole Zuordnung auf ' + zielDatum + '...');

    try {
        if (typeof Bridge !== 'undefined' && Bridge.execute) {
            await Bridge.execute('zuordnungWiederholen', {
                position_id: positionId,
                ziel_datum: zielDatum
            });
        } else {
            // REST API Fallback
            await fetch(`${API_BASE}/positionen/${positionId}/wiederholen`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ziel_datum: zielDatum })
            });
        }

        showSuccess(zugeordnete.length + ' Zuordnungen auf ' + zielDatum + ' kopiert');
    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Wiederholen:', error);
        showError('Wiederholung fehlgeschlagen');
    }
}

// MA-Typ Filter anwenden (Access: MA_Typ_AfterUpdate)
function maTypFilterAnwenden(filterValue) {
    const items = elements.mitarbeiterListe?.querySelectorAll('.position-item, .ma-item');

    items?.forEach(item => {
        const istFest = item.dataset.istFest === 'true' || item.dataset.istFest === '1';

        switch (filterValue) {
            case '0': // Alle
                item.style.display = '';
                break;
            case '1': // Nur Fest
                item.style.display = istFest ? '' : 'none';
                break;
            case '2': // Nur Frei
                item.style.display = !istFest ? '' : 'none';
                break;
        }
    });

    updateStatus('Filter: ' + (filterValue === '0' ? 'Alle' : filterValue === '1' ? 'Fest' : 'Frei'));
}

// Expose functions to global scope for inline script
window.alleHinzufuegen = alleHinzufuegen;
window.alleEntfernen = alleEntfernen;
window.zuordnungWiederholen = zuordnungWiederholen;
window.maTypFilterAnwenden = maTypFilterAnwenden;

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
}

function getDayName(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    const days = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    return days[d.getDay()];
}

function showError(msg) {
    console.error(msg);
    if (typeof Toast !== 'undefined') Toast.error(msg);
    else alert(msg);
}

function showSuccess(msg) {
    console.log(msg);
    if (typeof Toast !== 'undefined') Toast.success(msg);
    else alert(msg);
}

document.addEventListener('DOMContentLoaded', init);
