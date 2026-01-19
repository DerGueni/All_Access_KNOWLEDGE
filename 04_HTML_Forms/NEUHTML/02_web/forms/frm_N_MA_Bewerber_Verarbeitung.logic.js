/**
 * frm_N_MA_Bewerber_Verarbeitung.logic.js
 * Logik für Bewerber-Verarbeitung Formular
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../js/webview2-bridge.js';

const state = {
    bewerber: [],
    selectedBewerber: null,
    filter: 'neu' // neu, alle, abgelehnt
};

let elements = {};

async function init() {
    console.log('[Bewerber] Initialisierung...');

    elements = {
        // Filter
        cboFilter: document.getElementById('cboFilter'),
        txtSuche: document.getElementById('txtSuche'),

        // Bewerber-Liste
        bewerberListe: document.getElementById('bewerberListe'),

        // Detail-Felder
        detailName: document.getElementById('detailName'),
        detailEmail: document.getElementById('detailEmail'),
        detailTelefon: document.getElementById('detailTelefon'),
        detailBewerbungsDatum: document.getElementById('detailBewerbungsDatum'),
        detailQualifikationen: document.getElementById('detailQualifikationen'),
        detailBemerkungen: document.getElementById('detailBemerkungen'),
        detailDokumente: document.getElementById('detailDokumente'),

        // Aktions-Buttons
        btnAnnehmen: document.getElementById('btnAnnehmen'),
        btnAblehnen: document.getElementById('btnAblehnen'),
        btnKontaktieren: document.getElementById('btnKontaktieren'),

        // Status
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    setupEventListeners();
    await loadBewerber();
    setStatus('Bereit');
}

function setupEventListeners() {
    if (elements.cboFilter) {
        elements.cboFilter.addEventListener('change', () => {
            state.filter = elements.cboFilter.value;
            loadBewerber();
        });
    }

    if (elements.txtSuche) {
        elements.txtSuche.addEventListener('input', debounce(loadBewerber, 300));
    }

    if (elements.btnAnnehmen) {
        elements.btnAnnehmen.addEventListener('click', acceptBewerber);
    }

    if (elements.btnAblehnen) {
        elements.btnAblehnen.addEventListener('click', rejectBewerber);
    }

    if (elements.btnKontaktieren) {
        elements.btnKontaktieren.addEventListener('click', contactBewerber);
    }
}

async function loadBewerber() {
    setStatus('Lade Bewerber...');
    try {
        const params = {
            status: state.filter,
            search: elements.txtSuche?.value.trim() || null
        };

        const result = await Bridge.bewerber.list(params);
        state.bewerber = result.data || [];

        renderBewerberListe();
        updateAnzahl();
        setStatus(`${state.bewerber.length} Bewerber geladen`);

    } catch (error) {
        console.error('[Bewerber] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function renderBewerberListe() {
    if (!elements.bewerberListe) return;

    if (state.bewerber.length === 0) {
        elements.bewerberListe.innerHTML = `
            <div class="empty-message">Keine Bewerber gefunden</div>
        `;
        clearDetail();
        return;
    }

    elements.bewerberListe.innerHTML = state.bewerber.map(b => {
        const statusClass = b.Status === 'neu' ? 'status-neu' :
                           b.Status === 'angenommen' ? 'status-ok' : 'status-abgelehnt';
        const selected = state.selectedBewerber?.ID === b.ID ? 'selected' : '';

        return `
            <div class="bewerber-card ${selected}" data-id="${b.ID}">
                <div class="bewerber-avatar">${getInitials(b.Vorname, b.Nachname)}</div>
                <div class="bewerber-info">
                    <div class="bewerber-name">${b.Nachname}, ${b.Vorname}</div>
                    <div class="bewerber-meta">${formatDate(b.BewerbungsDatum)}</div>
                </div>
                <span class="bewerber-status ${statusClass}">${b.Status || 'Neu'}</span>
            </div>
        `;
    }).join('');

    // Click-Handler
    elements.bewerberListe.querySelectorAll('.bewerber-card').forEach(card => {
        card.addEventListener('click', () => {
            const id = parseInt(card.dataset.id);
            selectBewerber(id);
        });
    });

    // Ersten automatisch auswählen
    if (!state.selectedBewerber && state.bewerber.length > 0) {
        selectBewerber(state.bewerber[0].ID);
    }
}

async function selectBewerber(id) {
    try {
        const result = await Bridge.bewerber.get(id);
        state.selectedBewerber = result.data || result;
        displayDetail(state.selectedBewerber);

        // Selection aktualisieren
        elements.bewerberListe.querySelectorAll('.bewerber-card').forEach(card => {
            card.classList.toggle('selected', parseInt(card.dataset.id) === id);
        });
    } catch (error) {
        console.error('[Bewerber] Fehler beim Laden Detail:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function displayDetail(b) {
    if (elements.detailName) elements.detailName.textContent = `${b.Vorname} ${b.Nachname}`;
    if (elements.detailEmail) elements.detailEmail.textContent = b.Email || '-';
    if (elements.detailTelefon) elements.detailTelefon.textContent = b.Telefon || '-';
    if (elements.detailBewerbungsDatum) elements.detailBewerbungsDatum.textContent = formatDate(b.BewerbungsDatum);

    if (elements.detailQualifikationen) {
        const qualis = b.Qualifikationen || [];
        elements.detailQualifikationen.innerHTML = qualis.length > 0
            ? qualis.map(q => `<span class="quali-tag">${q}</span>`).join('')
            : '<span class="empty-text">Keine Qualifikationen</span>';
    }

    if (elements.detailBemerkungen) {
        elements.detailBemerkungen.textContent = b.Bemerkungen || '';
    }

    if (elements.detailDokumente) {
        const docs = b.Dokumente || [];
        elements.detailDokumente.innerHTML = docs.length > 0
            ? docs.map(d => `<a href="${d.Pfad}" class="doc-link">${d.Name}</a>`).join('')
            : '<span class="empty-text">Keine Dokumente</span>';
    }

    // Buttons aktivieren/deaktivieren
    const istNeu = b.Status === 'neu' || !b.Status;
    if (elements.btnAnnehmen) elements.btnAnnehmen.disabled = !istNeu;
    if (elements.btnAblehnen) elements.btnAblehnen.disabled = !istNeu;
}

function clearDetail() {
    state.selectedBewerber = null;
    if (elements.detailName) elements.detailName.textContent = '-';
    if (elements.detailEmail) elements.detailEmail.textContent = '-';
    if (elements.detailTelefon) elements.detailTelefon.textContent = '-';
    if (elements.detailBewerbungsDatum) elements.detailBewerbungsDatum.textContent = '-';
    if (elements.detailQualifikationen) elements.detailQualifikationen.innerHTML = '';
    if (elements.detailBemerkungen) elements.detailBemerkungen.textContent = '';
    if (elements.detailDokumente) elements.detailDokumente.innerHTML = '';
}

async function acceptBewerber() {
    if (!state.selectedBewerber) return;

    if (!confirm(`${state.selectedBewerber.Vorname} ${state.selectedBewerber.Nachname} als Mitarbeiter anlegen?`)) {
        return;
    }

    try {
        setStatus('Verarbeite...');
        await Bridge.bewerber.accept(state.selectedBewerber.ID);
        setStatus('Bewerber angenommen und als MA angelegt');
        await loadBewerber();
    } catch (error) {
        console.error('[Bewerber] Fehler bei Annahme:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler: ' + error.message);
    }
}

async function rejectBewerber() {
    if (!state.selectedBewerber) return;

    const grund = prompt('Ablehnungsgrund (optional):');
    if (grund === null) return; // Abbruch

    try {
        setStatus('Verarbeite...');
        await Bridge.bewerber.reject(state.selectedBewerber.ID);
        setStatus('Bewerber abgelehnt');
        await loadBewerber();
    } catch (error) {
        console.error('[Bewerber] Fehler bei Ablehnung:', error);
        setStatus('Fehler: ' + error.message);
        alert('Fehler: ' + error.message);
    }
}

function contactBewerber() {
    if (!state.selectedBewerber?.Email) {
        alert('Keine E-Mail-Adresse vorhanden');
        return;
    }
    window.open(`mailto:${state.selectedBewerber.Email}?subject=Ihre Bewerbung bei CONSEC`);
}

function updateAnzahl() {
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.bewerber.length} Bewerber`;
    }
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function getInitials(vorname, nachname) {
    return ((vorname?.[0] || '') + (nachname?.[0] || '')).toUpperCase();
}

function formatDate(value) {
    if (!value) return '-';
    const d = new Date(value);
    if (isNaN(d)) return value;
    return d.toLocaleDateString('de-DE');
}

function debounce(fn, delay) {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), delay);
    };
}

document.addEventListener('DOMContentLoaded', init);

window.BewerberVerarbeitung = { loadBewerber, selectBewerber };
