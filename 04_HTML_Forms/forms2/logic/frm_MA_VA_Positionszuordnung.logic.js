/**
 * frm_MA_VA_Positionszuordnung.logic.js
 * Logik für Mitarbeiter-Position-Zuordnung
 * Verwaltung der Zuordnung von Mitarbeitern zu spezifischen Positionen/Rollen in Aufträgen
 */
import { Bridge } from '../../api/bridgeClient.js';

let elements = {};
let currentAuftragId = null;
let currentDatum = null;
let currentSchichtId = null;

async function init() {
    console.log('[MA_VA_Positionszuordnung] Initialisierung...');

    elements = {
        auftragSelect: document.getElementById('auftragSelect'),
        datumSelect: document.getElementById('datumSelect'),
        schichtListe: document.getElementById('schichtListe'),
        positionenListe: document.getElementById('positionenListe'),
        mitarbeiterListe: document.getElementById('mitarbeiterListe'),

        btnPositionHinzufuegen: document.getElementById('btnPositionHinzufuegen'),
        btnPositionLoeschen: document.getElementById('btnPositionLoeschen'),
        btnSpeichern: document.getElementById('btnSpeichern'),

        // Position-Details
        positionName: document.getElementById('positionName'),
        positionBeschreibung: document.getElementById('positionBeschreibung'),
        positionAnzahl: document.getElementById('positionAnzahl'),
        positionQualifikation: document.getElementById('positionQualifikation'),

        // Zugeordnete MA
        zugeordneteListe: document.getElementById('zugeordneteListe'),

        // Filter
        filterQualifikation: document.getElementById('filterQualifikation'),
        filterVerfuegbar: document.getElementById('filterVerfuegbar'),
        searchMA: document.getElementById('searchMA')
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
    // Auftrag auswählen
    if (elements.auftragSelect) {
        elements.auftragSelect.addEventListener('change', async (e) => {
            currentAuftragId = e.target.value;
            if (currentAuftragId) {
                await loadEinsatztage(currentAuftragId);
            }
        });
    }

    // Datum auswählen
    if (elements.datumSelect) {
        elements.datumSelect.addEventListener('change', async (e) => {
            currentDatum = e.target.value;
            if (currentAuftragId && currentDatum) {
                await loadSchichten(currentAuftragId, currentDatum);
            }
        });
    }

    // Schicht auswählen
    if (elements.schichtListe) {
        elements.schichtListe.addEventListener('click', async (e) => {
            const item = e.target.closest('.schicht-item');
            if (item) {
                currentSchichtId = item.dataset.id;

                // Aktive Schicht markieren
                document.querySelectorAll('.schicht-item').forEach(i => i.classList.remove('active'));
                item.classList.add('active');

                // Positionen laden
                await loadPositionen(currentAuftragId, currentDatum, currentSchichtId);
            }
        });
    }

    // Position auswählen
    if (elements.positionenListe) {
        elements.positionenListe.addEventListener('click', async (e) => {
            const item = e.target.closest('.position-item');
            if (item) {
                const positionId = item.dataset.id;

                // Aktive Position markieren
                document.querySelectorAll('.position-item').forEach(i => i.classList.remove('active'));
                item.classList.add('active');

                // Mitarbeiter laden
                await loadVerfuegbareMitarbeiter(positionId);
                await loadZugeordneteMitarbeiter(positionId);
            }
        });
    }

    // Position hinzufügen
    if (elements.btnPositionHinzufuegen) {
        elements.btnPositionHinzufuegen.addEventListener('click', neuePosition);
    }

    // Position löschen
    if (elements.btnPositionLoeschen) {
        elements.btnPositionLoeschen.addEventListener('click', positionLoeschen);
    }

    // Mitarbeiter zuordnen (Event Delegation)
    if (elements.mitarbeiterListe) {
        elements.mitarbeiterListe.addEventListener('click', async (e) => {
            if (e.target.classList.contains('btn-zuordnen')) {
                const maId = parseInt(e.target.dataset.maId);
                await mitarbeiterZuordnen(maId);
            }
        });
    }

    // Mitarbeiter entfernen (Event Delegation)
    if (elements.zugeordneteListe) {
        elements.zugeordneteListe.addEventListener('click', async (e) => {
            if (e.target.classList.contains('btn-entfernen')) {
                const maId = parseInt(e.target.dataset.maId);
                await mitarbeiterEntfernen(maId);
            }
        });
    }

    // Suche
    if (elements.searchMA) {
        elements.searchMA.addEventListener('input', handleSearch);
    }

    // Filter
    if (elements.filterQualifikation) {
        elements.filterQualifikation.addEventListener('change', applyFilter);
    }

    if (elements.filterVerfuegbar) {
        elements.filterVerfuegbar.addEventListener('change', applyFilter);
    }
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

async function mitarbeiterZuordnen(maId) {
    const positionId = document.querySelector('.position-item.active')?.dataset.id;

    if (!positionId) {
        showError('Bitte Position auswählen');
        return;
    }

    try {
        await Bridge.execute('zuordnenMitarbeiterZuPosition', {
            position_id: positionId,
            ma_id: maId
        });

        await loadVerfuegbareMitarbeiter(positionId);
        await loadZugeordneteMitarbeiter(positionId);
        await loadPositionen(currentAuftragId, currentDatum, currentSchichtId);

        showSuccess('Mitarbeiter zugeordnet');

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Zuordnen:', error);
        showError('Zuordnung fehlgeschlagen');
    }
}

async function mitarbeiterEntfernen(maId) {
    const positionId = document.querySelector('.position-item.active')?.dataset.id;

    if (!positionId) return;

    try {
        await Bridge.execute('entfernenMitarbeiterVonPosition', {
            position_id: positionId,
            ma_id: maId
        });

        await loadVerfuegbareMitarbeiter(positionId);
        await loadZugeordneteMitarbeiter(positionId);
        await loadPositionen(currentAuftragId, currentDatum, currentSchichtId);

        showSuccess('Mitarbeiter entfernt');

    } catch (error) {
        console.error('[MA_VA_Positionszuordnung] Fehler beim Entfernen:', error);
        showError('Entfernen fehlgeschlagen');
    }
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
    alert(msg); // TODO: Besseres UI-Feedback
}

function showSuccess(msg) {
    console.log(msg);
    alert(msg); // TODO: Besseres UI-Feedback
}

document.addEventListener('DOMContentLoaded', init);
