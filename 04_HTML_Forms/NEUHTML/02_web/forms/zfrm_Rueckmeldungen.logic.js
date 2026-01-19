/**
 * zfrm_Rueckmeldungen.logic.js
 * Logik für Rückmeldungen/Nachrichten-Übersicht
 * REST-API Anbindung an localhost:5000
 */

import { Bridge } from '../js/webview2-bridge.js';

const state = {
    rueckmeldungen: [],
    selectedRueckmeldung: null,
    filter: ''
};

let elements = {};

async function init() {
    console.log('[Rueckmeldungen] Initialisierung...');

    elements = {
        // Filter
        cboFilter: document.getElementById('cboFilter'),
        txtSuche: document.getElementById('txtSuche'),
        btnAlleGelesen: document.getElementById('btnAlleGelesen'),
        btnAktualisieren: document.getElementById('btnAktualisieren'),

        // Stats
        statGesamt: document.getElementById('statGesamt'),
        statUngelesen: document.getElementById('statUngelesen'),
        statBestaetigt: document.getElementById('statBestätigt'),
        statAbsagen: document.getElementById('statAbsagen'),

        // Liste
        rueckmeldungListe: document.querySelector('.content-main'),

        // Detail
        nachrichtContainer: document.querySelector('.nachricht-container'),

        // Footer
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    setupEventListeners();
    await loadRueckmeldungen();
    setStatus('Bereit');
}

function setupEventListeners() {
    if (elements.cboFilter) {
        elements.cboFilter.addEventListener('change', () => {
            state.filter = elements.cboFilter.value;
            loadRueckmeldungen();
        });
    }

    if (elements.txtSuche) {
        elements.txtSuche.addEventListener('input', debounce(loadRueckmeldungen, 300));
    }

    if (elements.btnAlleGelesen) {
        elements.btnAlleGelesen.addEventListener('click', markAllRead);
    }

    if (elements.btnAktualisieren) {
        elements.btnAktualisieren.addEventListener('click', () => loadRueckmeldungen());
    }
}

async function loadRueckmeldungen() {
    setStatus('Lade Rückmeldungen...');
    try {
        const params = {
            filter: state.filter || null,
            search: elements.txtSuche?.value.trim() || null
        };

        const result = await Bridge.rueckmeldungen.list(params);
        state.rueckmeldungen = result.data || [];

        renderRueckmeldungen();
        updateStats();
        updateAnzahl();
        setStatus(`${state.rueckmeldungen.length} Rückmeldungen`);

    } catch (error) {
        console.error('[Rueckmeldungen] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function renderRueckmeldungen() {
    const container = elements.rueckmeldungListe;
    if (!container) return;

    if (state.rueckmeldungen.length === 0) {
        container.innerHTML = `
            <div style="text-align:center;padding:40px;color:#666;">
                Keine Rückmeldungen vorhanden
            </div>
        `;
        clearDetail();
        return;
    }

    container.innerHTML = state.rueckmeldungen.map(r => {
        const ungelesen = !r.Gelesen ? 'ungelesen' : '';
        const selected = state.selectedRueckmeldung?.ID === r.ID ? 'selected' : '';
        const typClass = getTypClass(r.Typ);

        return `
            <div class="rückmeldung-card ${ungelesen} ${selected}" data-id="${r.ID}">
                <div class="rückmeldung-indicator ${r.Gelesen ? 'gelesen' : ''}"></div>
                <div class="rückmeldung-content">
                    <div class="rückmeldung-header">
                        <span class="rückmeldung-absender">${r.Absender || 'Unbekannt'}</span>
                        <span class="rückmeldung-zeit">${formatZeit(r.Datum)}</span>
                    </div>
                    <div class="rückmeldung-betreff">
                        ${r.Betreff || 'Kein Betreff'}
                        <span class="rückmeldung-typ ${typClass}">${r.Typ || 'Info'}</span>
                    </div>
                    <div class="rückmeldung-preview">${truncate(r.Nachricht, 60)}</div>
                </div>
            </div>
        `;
    }).join('');

    // Click-Handler
    container.querySelectorAll('.rückmeldung-card').forEach(card => {
        card.addEventListener('click', () => {
            const id = parseInt(card.dataset.id);
            selectRueckmeldung(id);
        });
    });

    // Erste automatisch auswählen
    if (!state.selectedRueckmeldung && state.rueckmeldungen.length > 0) {
        selectRueckmeldung(state.rueckmeldungen[0].ID);
    }
}

async function selectRueckmeldung(id) {
    try {
        const result = await Bridge.rueckmeldungen.get(id);
        state.selectedRueckmeldung = result.data || result;

        // Als gelesen markieren
        if (!state.selectedRueckmeldung.Gelesen) {
            await Bridge.rueckmeldungen.markRead(id);
            state.selectedRueckmeldung.Gelesen = true;

            // UI aktualisieren
            const card = elements.rueckmeldungListe.querySelector(`[data-id="${id}"]`);
            if (card) {
                card.classList.remove('ungelesen');
                card.querySelector('.rückmeldung-indicator')?.classList.add('gelesen');
            }
            updateStats();
        }

        displayDetail(state.selectedRueckmeldung);

        // Selection aktualisieren
        elements.rueckmeldungListe.querySelectorAll('.rückmeldung-card').forEach(card => {
            card.classList.toggle('selected', parseInt(card.dataset.id) === id);
        });

    } catch (error) {
        console.error('[Rueckmeldungen] Fehler beim Laden Detail:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function displayDetail(r) {
    if (!elements.nachrichtContainer || !r) return;

    const typClass = getTypClass(r.Typ);

    elements.nachrichtContainer.innerHTML = `
        <div class="nachricht-header">
            <div class="nachricht-betreff">${r.Betreff || 'Kein Betreff'}</div>
            <div class="nachricht-meta">
                <span><strong>Von:</strong> ${r.Absender || 'Unbekannt'}</span>
                <span><strong>Datum:</strong> ${formatDatum(r.Datum)}</span>
                <span><strong>Typ:</strong> <span class="rückmeldung-typ ${typClass}">${r.Typ || 'Info'}</span></span>
            </div>
        </div>
        <div class="nachricht-body">
            ${formatNachricht(r.Nachricht)}
        </div>
        <div class="nachricht-actions">
            <button class="btn btn-primary" onclick="Rueckmeldungen.antworten(${r.ID})">Antworten</button>
            <button class="btn" onclick="Rueckmeldungen.weiterleiten(${r.ID})">Weiterleiten</button>
            <button class="btn" onclick="Rueckmeldungen.archivieren(${r.ID})">Archivieren</button>
            <button class="btn btn-danger" onclick="Rueckmeldungen.loeschen(${r.ID})">Löschen</button>
        </div>
    `;
}

function clearDetail() {
    state.selectedRueckmeldung = null;
    if (elements.nachrichtContainer) {
        elements.nachrichtContainer.innerHTML = `
            <div style="text-align:center;padding:40px;color:#666;">
                Keine Nachricht ausgewählt
            </div>
        `;
    }
}

async function markAllRead() {
    if (!confirm('Alle Nachrichten als gelesen markieren?')) return;

    try {
        setStatus('Markiere alle als gelesen...');
        await Bridge.rueckmeldungen.markAllRead();
        await loadRueckmeldungen();
        setStatus('Alle als gelesen markiert');
    } catch (error) {
        console.error('[Rueckmeldungen] Fehler:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function updateStats() {
    const gesamt = state.rueckmeldungen.length;
    const ungelesen = state.rueckmeldungen.filter(r => !r.Gelesen).length;
    const bestaetigt = state.rueckmeldungen.filter(r => r.Typ === 'Zusage' || r.Typ === 'Bestätigung').length;
    const absagen = state.rueckmeldungen.filter(r => r.Typ === 'Absage').length;

    if (elements.statGesamt) elements.statGesamt.textContent = gesamt;
    if (elements.statUngelesen) elements.statUngelesen.textContent = ungelesen;
    if (elements.statBestaetigt) elements.statBestaetigt.textContent = bestaetigt;
    if (elements.statAbsagen) elements.statAbsagen.textContent = absagen;
}

function updateAnzahl() {
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.rueckmeldungen.length} Rückmeldungen`;
    }
}

// Aktionen
function antworten(id) {
    const r = state.rueckmeldungen.find(x => x.ID === id);
    if (r?.AbsenderEmail) {
        window.open(`mailto:${r.AbsenderEmail}?subject=Re: ${r.Betreff || ''}`);
    } else {
        alert('Keine E-Mail-Adresse vorhanden');
    }
}

function weiterleiten(id) {
    alert('Weiterleiten: ID ' + id);
}

function archivieren(id) {
    alert('Archivieren: ID ' + id);
}

async function loeschen(id) {
    if (!confirm('Nachricht wirklich löschen?')) return;
    alert('Löschen: ID ' + id);
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function getTypClass(typ) {
    switch (typ?.toLowerCase()) {
        case 'zusage':
        case 'bestätigung': return 'typ-bestätigung';
        case 'absage': return 'typ-absage';
        case 'anfrage': return 'typ-anfrage';
        case 'problem': return 'typ-problem';
        default: return 'typ-info';
    }
}

function formatZeit(value) {
    if (!value) return '';
    const d = new Date(value);
    const now = new Date();
    const diff = (now - d) / 1000;

    if (diff < 3600) return `vor ${Math.floor(diff / 60)} Min`;
    if (diff < 86400) return `vor ${Math.floor(diff / 3600)} Std`;
    if (diff < 172800) return 'gestern';
    return d.toLocaleDateString('de-DE');
}

function formatDatum(value) {
    if (!value) return '-';
    const d = new Date(value);
    return d.toLocaleDateString('de-DE') + ' ' + d.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
}

function formatNachricht(text) {
    if (!text) return '<p>Keine Nachricht</p>';
    return text.split('\n').map(line => `<p>${line || '&nbsp;'}</p>`).join('');
}

function truncate(text, length) {
    if (!text) return '';
    return text.length > length ? text.substring(0, length) + '...' : text;
}

function debounce(fn, delay) {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), delay);
    };
}

document.addEventListener('DOMContentLoaded', init);

window.Rueckmeldungen = {
    loadRueckmeldungen,
    selectRueckmeldung,
    markAllRead,
    antworten,
    weiterleiten,
    archivieren,
    loeschen
};
