/**
 * frmTop_DP_Auftragseingabe.logic.js
 * Logik für Dienstplan-Auftragseingabe
 * Verwaltung von Aufträgen im Dienstplan-Kontext
 */
import { Bridge } from '../api/bridgeClient.js';

let elements = {};
let currentAuftragId = null;

async function init() {
    console.log('[DP_Auftragseingabe] Initialisierung...');

    elements = {
        auftragListe: document.getElementById('auftragListe'),
        btnNeu: document.getElementById('btnNeu'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLoeschen'),
        searchInput: document.getElementById('searchInput'),

        // Formularfelder
        auftragNr: document.getElementById('auftragNr'),
        veranstalter: document.getElementById('veranstalter'),
        objekt: document.getElementById('objekt'),
        von: document.getElementById('von'),
        bis: document.getElementById('bis'),
        status: document.getElementById('status')
    };

    await loadInitialData();
    bindEvents();
}

async function loadInitialData() {
    try {
        // Auftrags-Liste laden
        const auftraege = await Bridge.execute('getAuftragListe', { limit: 100 });
        renderAuftragListe(auftraege);

        // Veranstalter-Dropdown laden
        const veranstalter = await Bridge.kunden.list({ aktiv: true });
        populateDropdown(elements.veranstalter, veranstalter, 'kun_Id', 'kun_Firma');

        // Objekte-Dropdown laden
        const objekte = await Bridge.objekte.list({ aktiv: true });
        populateDropdown(elements.objekt, objekte, 'obj_Id', 'obj_Bezeichnung');

    } catch (error) {
        console.error('[DP_Auftragseingabe] Fehler beim Laden:', error);
        showError('Daten konnten nicht geladen werden');
    }
}

function renderAuftragListe(auftraege) {
    if (!elements.auftragListe) return;

    elements.auftragListe.innerHTML = auftraege.map(a => `
        <div class="auftrag-item" data-id="${a.VA_ID}">
            <div class="auftrag-nr">${a.Auftrag || 'N/A'}</div>
            <div class="auftrag-objekt">${a.Objekt || ''}</div>
            <div class="auftrag-datum">${formatDate(a.VADatum)}</div>
        </div>
    `).join('');
}

function populateDropdown(selectElement, items, idField, textField) {
    if (!selectElement) return;

    selectElement.innerHTML = '<option value="">-- Bitte wählen --</option>' +
        items.map(item => `<option value="${item[idField]}">${item[textField]}</option>`).join('');
}

function bindEvents() {
    // Auftrag aus Liste auswählen
    if (elements.auftragListe) {
        elements.auftragListe.addEventListener('click', (e) => {
            const item = e.target.closest('.auftrag-item');
            if (item) {
                const id = parseInt(item.dataset.id);
                loadAuftrag(id);
            }
        });
    }

    // Neuer Auftrag
    if (elements.btnNeu) {
        elements.btnNeu.addEventListener('click', () => {
            clearForm();
            currentAuftragId = null;
        });
    }

    // Speichern
    if (elements.btnSpeichern) {
        elements.btnSpeichern.addEventListener('click', saveAuftrag);
    }

    // Löschen
    if (elements.btnLoeschen) {
        elements.btnLoeschen.addEventListener('click', deleteAuftrag);
    }

    // Suche
    if (elements.searchInput) {
        elements.searchInput.addEventListener('input', handleSearch);
    }
}

async function loadAuftrag(id) {
    try {
        const auftrag = await Bridge.auftraege.get(id);
        currentAuftragId = id;

        if (elements.auftragNr) elements.auftragNr.value = auftrag.Auftrag || '';
        if (elements.veranstalter) elements.veranstalter.value = auftrag.Veranstalter_ID || '';
        if (elements.objekt) elements.objekt.value = auftrag.Objekt_ID || '';
        if (elements.von) elements.von.value = auftrag.VADatum || '';
        if (elements.bis) elements.bis.value = auftrag.VAEnde || '';
        if (elements.status) elements.status.value = auftrag.Status || '';

    } catch (error) {
        console.error('[DP_Auftragseingabe] Fehler beim Laden des Auftrags:', error);
        showError('Auftrag konnte nicht geladen werden');
    }
}

async function saveAuftrag() {
    try {
        const data = {
            Auftrag: elements.auftragNr?.value,
            Veranstalter_ID: elements.veranstalter?.value,
            Objekt_ID: elements.objekt?.value,
            VADatum: elements.von?.value,
            VAEnde: elements.bis?.value,
            Status: elements.status?.value
        };

        if (currentAuftragId) {
            await Bridge.auftraege.update(currentAuftragId, data);
            showSuccess('Auftrag aktualisiert');
        } else {
            const result = await Bridge.auftraege.create(data);
            currentAuftragId = result.VA_ID;
            showSuccess('Auftrag erstellt');
        }

        await loadInitialData();

    } catch (error) {
        console.error('[DP_Auftragseingabe] Fehler beim Speichern:', error);
        showError('Speichern fehlgeschlagen');
    }
}

async function deleteAuftrag() {
    if (!currentAuftragId) return;

    if (!confirm('Auftrag wirklich löschen?')) return;

    try {
        await Bridge.auftraege.delete(currentAuftragId);
        showSuccess('Auftrag gelöscht');
        clearForm();
        currentAuftragId = null;
        await loadInitialData();

    } catch (error) {
        console.error('[DP_Auftragseingabe] Fehler beim Löschen:', error);
        showError('Löschen fehlgeschlagen');
    }
}

function clearForm() {
    if (elements.auftragNr) elements.auftragNr.value = '';
    if (elements.veranstalter) elements.veranstalter.value = '';
    if (elements.objekt) elements.objekt.value = '';
    if (elements.von) elements.von.value = '';
    if (elements.bis) elements.bis.value = '';
    if (elements.status) elements.status.value = '';
}

function handleSearch(e) {
    const term = e.target.value.toLowerCase();
    const items = elements.auftragListe?.querySelectorAll('.auftrag-item');

    items?.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(term) ? '' : 'none';
    });
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleDateString('de-DE');
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
