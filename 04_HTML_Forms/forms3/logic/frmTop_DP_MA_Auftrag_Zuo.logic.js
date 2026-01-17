/**
 * frmTop_DP_MA_Auftrag_Zuo.logic.js
 * Logik für Mitarbeiter-Auftrag-Zuordnung im Dienstplan
 * Verwaltung der Zuordnung von Mitarbeitern zu Aufträgen/Schichten
 */
import { Bridge } from '../api/bridgeClient.js';

let elements = {};
let currentVaId = null;
let currentDatum = null;

async function init() {
    console.log('[DP_MA_Auftrag_Zuo] Initialisierung...');

    elements = {
        auftragSelect: document.getElementById('auftragSelect'),
        datumSelect: document.getElementById('datumSelect'),
        schichtListe: document.getElementById('schichtListe'),
        verfuegbareListe: document.getElementById('verfuegbareListe'),
        zugeordneteListe: document.getElementById('zugeordneteListe'),

        btnZuordnen: document.getElementById('btnZuordnen'),
        btnEntfernen: document.getElementById('btnEntfernen'),
        btnAlleZuordnen: document.getElementById('btnAlleZuordnen'),

        filterAktiv: document.getElementById('filterAktiv'),
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

    } catch (error) {
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Laden:', error);
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

async function loadEinsatztage(vaId) {
    try {
        const tage = await Bridge.execute('getEinsatztage', { va_id: vaId });
        populateDatumSelect(tage);

    } catch (error) {
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Laden der Einsatztage:', error);
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
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Laden der Schichten:', error);
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

async function loadVerfuegbareMitarbeiter(vaId, datum, schichtId) {
    try {
        const verfuegbare = await Bridge.execute('getVerfuegbareMitarbeiter', {
            va_id: vaId,
            datum: datum,
            schicht_id: schichtId
        });

        renderVerfuegbareListe(verfuegbare);

    } catch (error) {
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Laden verfügbarer MA:', error);
    }
}

async function loadZugeordneteMitarbeiter(vaId, datum, schichtId) {
    try {
        const zugeordnete = await Bridge.execute('getZugeordneteMitarbeiter', {
            va_id: vaId,
            datum: datum,
            schicht_id: schichtId
        });

        renderZugeordneteListe(zugeordnete);

    } catch (error) {
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Laden zugeordneter MA:', error);
    }
}

function renderVerfuegbareListe(mitarbeiter) {
    if (!elements.verfuegbareListe) return;

    elements.verfuegbareListe.innerHTML = mitarbeiter.map(m => `
        <div class="ma-item" data-id="${m.MA_ID}">
            <input type="checkbox" class="ma-checkbox" value="${m.MA_ID}">
            <span class="ma-name">${m.Nachname}, ${m.Vorname}</span>
            <span class="ma-tel">${m.Tel_Mobil || ''}</span>
        </div>
    `).join('');
}

function renderZugeordneteListe(mitarbeiter) {
    if (!elements.zugeordneteListe) return;

    elements.zugeordneteListe.innerHTML = mitarbeiter.map(m => `
        <div class="ma-item" data-id="${m.MA_ID}">
            <input type="checkbox" class="ma-checkbox" value="${m.MA_ID}">
            <span class="ma-name">${m.Nachname}, ${m.Vorname}</span>
            <span class="ma-status">${m.Status || ''}</span>
        </div>
    `).join('');
}

function bindEvents() {
    // Auftrag auswählen
    if (elements.auftragSelect) {
        elements.auftragSelect.addEventListener('change', async (e) => {
            currentVaId = e.target.value;
            if (currentVaId) {
                await loadEinsatztage(currentVaId);
            }
        });
    }

    // Datum auswählen
    if (elements.datumSelect) {
        elements.datumSelect.addEventListener('change', async (e) => {
            currentDatum = e.target.value;
            if (currentVaId && currentDatum) {
                await loadSchichten(currentVaId, currentDatum);
            }
        });
    }

    // Schicht auswählen
    if (elements.schichtListe) {
        elements.schichtListe.addEventListener('click', async (e) => {
            const item = e.target.closest('.schicht-item');
            if (item) {
                const schichtId = item.dataset.id;

                // Aktive Schicht markieren
                document.querySelectorAll('.schicht-item').forEach(i => i.classList.remove('active'));
                item.classList.add('active');

                // Mitarbeiter laden
                await loadVerfuegbareMitarbeiter(currentVaId, currentDatum, schichtId);
                await loadZugeordneteMitarbeiter(currentVaId, currentDatum, schichtId);
            }
        });
    }

    // Zuordnen
    if (elements.btnZuordnen) {
        elements.btnZuordnen.addEventListener('click', () => {
            const selected = getSelectedMitarbeiter(elements.verfuegbareListe);
            if (selected.length > 0) {
                zuordnenMitarbeiter(selected);
            }
        });
    }

    // Entfernen
    if (elements.btnEntfernen) {
        elements.btnEntfernen.addEventListener('click', () => {
            const selected = getSelectedMitarbeiter(elements.zugeordneteListe);
            if (selected.length > 0) {
                entfernenMitarbeiter(selected);
            }
        });
    }

    // Alle zuordnen
    if (elements.btnAlleZuordnen) {
        elements.btnAlleZuordnen.addEventListener('click', () => {
            const all = Array.from(elements.verfuegbareListe?.querySelectorAll('.ma-item') || [])
                .map(item => parseInt(item.dataset.id));
            if (all.length > 0) {
                zuordnenMitarbeiter(all);
            }
        });
    }

    // Suche
    if (elements.searchMA) {
        elements.searchMA.addEventListener('input', handleSearch);
    }
}

function getSelectedMitarbeiter(container) {
    if (!container) return [];

    return Array.from(container.querySelectorAll('.ma-checkbox:checked'))
        .map(cb => parseInt(cb.value));
}

async function zuordnenMitarbeiter(maIds) {
    const schichtId = document.querySelector('.schicht-item.active')?.dataset.id;
    if (!schichtId) return;

    try {
        await Bridge.execute('zuordnenMitarbeiter', {
            va_id: currentVaId,
            datum: currentDatum,
            schicht_id: schichtId,
            ma_ids: maIds
        });

        // Listen neu laden
        await loadVerfuegbareMitarbeiter(currentVaId, currentDatum, schichtId);
        await loadZugeordneteMitarbeiter(currentVaId, currentDatum, schichtId);
        await loadSchichten(currentVaId, currentDatum);

        showSuccess('Mitarbeiter zugeordnet');

    } catch (error) {
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Zuordnen:', error);
        showError('Zuordnung fehlgeschlagen');
    }
}

async function entfernenMitarbeiter(maIds) {
    const schichtId = document.querySelector('.schicht-item.active')?.dataset.id;
    if (!schichtId) return;

    try {
        await Bridge.execute('entfernenMitarbeiter', {
            va_id: currentVaId,
            datum: currentDatum,
            schicht_id: schichtId,
            ma_ids: maIds
        });

        // Listen neu laden
        await loadVerfuegbareMitarbeiter(currentVaId, currentDatum, schichtId);
        await loadZugeordneteMitarbeiter(currentVaId, currentDatum, schichtId);
        await loadSchichten(currentVaId, currentDatum);

        showSuccess('Mitarbeiter entfernt');

    } catch (error) {
        console.error('[DP_MA_Auftrag_Zuo] Fehler beim Entfernen:', error);
        showError('Entfernen fehlgeschlagen');
    }
}

function handleSearch(e) {
    const term = e.target.value.toLowerCase();

    [elements.verfuegbareListe, elements.zugeordneteListe].forEach(liste => {
        const items = liste?.querySelectorAll('.ma-item');
        items?.forEach(item => {
            const text = item.textContent.toLowerCase();
            item.style.display = text.includes(term) ? '' : 'none';
        });
    });
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
    // TODO: UI-Feedback implementieren
}

function showSuccess(msg) {
    console.log(msg);
    // TODO: UI-Feedback implementieren
}

document.addEventListener('DOMContentLoaded', init);
