/**
 * frm_MA_Adressen.logic.js
 * Logic-Datei fuer das Mitarbeiter-Adressen Formular
 */
'use strict';

// ============================================
// STATE
// ============================================
const state = {
    mitarbeiterList: [],
    currentRecord: null,
    currentIndex: -1,
    isDirty: false
};

// ============================================
// BRIDGE - API CONNECTION
// ============================================
const API_BASE = 'http://localhost:5000/api';

const Bridge = {
    async get(endpoint) {
        try {
            const response = await fetch(`${API_BASE}${endpoint}`);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return await response.json();
        } catch (error) {
            console.error('[Bridge] GET Error:', error);
            showToast('Fehler beim Laden der Daten: ' + error.message, 'error');
            throw error;
        }
    },

    async put(endpoint, data) {
        try {
            const response = await fetch(`${API_BASE}${endpoint}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return await response.json();
        } catch (error) {
            console.error('[Bridge] PUT Error:', error);
            showToast('Fehler beim Speichern: ' + error.message, 'error');
            throw error;
        }
    }
};

// ============================================
// MITARBEITER LADEN
// ============================================
async function loadMitarbeiterList() {
    showLoading();
    try {
        const filter = document.getElementById('filterSelect').value;
        const data = await Bridge.get('/mitarbeiter');

        // Filter anwenden
        state.mitarbeiterList = data.filter(m => {
            if (filter === 'aktiv') return m.IstAktiv === true;
            if (filter === 'inaktiv') return m.IstAktiv === false;
            return true;
        });

        renderMitarbeiterList();

        // Ersten MA auswaehlen wenn vorhanden
        if (state.mitarbeiterList.length > 0) {
            selectMitarbeiter(0);
        }

        showToast(`${state.mitarbeiterList.length} Mitarbeiter geladen`, 'success');
    } catch (error) {
        console.error('Fehler beim Laden der Mitarbeiterliste:', error);
    } finally {
        hideLoading();
    }
}

function renderMitarbeiterList() {
    const tbody = document.getElementById('maListBody');
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();

    // Filter nach Suchbegriff
    let filtered = state.mitarbeiterList;
    if (searchTerm) {
        filtered = state.mitarbeiterList.filter(m =>
            (m.Nachname || '').toLowerCase().includes(searchTerm) ||
            (m.Vorname || '').toLowerCase().includes(searchTerm) ||
            (m.Ort || '').toLowerCase().includes(searchTerm)
        );
    }

    if (filtered.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 20px;">Keine Mitarbeiter gefunden</td></tr>';
        return;
    }

    tbody.innerHTML = filtered.map((m, idx) => `
        <tr class="${state.currentRecord?.ID === m.ID ? 'active' : ''}"
            onclick="selectMitarbeiterByIndex(${state.mitarbeiterList.indexOf(m)})">
            <td>${m.ID}</td>
            <td>${escapeHtml(m.Nachname || '')}</td>
            <td>${escapeHtml(m.Vorname || '')}</td>
            <td>${escapeHtml(m.Ort || '')}</td>
        </tr>
    `).join('');
}

function selectMitarbeiterByIndex(index) {
    if (index < 0 || index >= state.mitarbeiterList.length) return;

    if (state.isDirty) {
        if (!confirm('Ungespeicherte Aenderungen gehen verloren. Fortfahren?')) {
            return;
        }
    }

    selectMitarbeiter(index);
}

async function selectMitarbeiter(index) {
    if (index < 0 || index >= state.mitarbeiterList.length) return;

    showLoading();
    try {
        const ma = state.mitarbeiterList[index];

        // Vollstaendige Daten laden
        const fullData = await Bridge.get(`/mitarbeiter/${ma.ID}`);

        state.currentRecord = fullData;
        state.currentIndex = index;
        state.isDirty = false;

        displayMitarbeiter(fullData);
        renderMitarbeiterList(); // Liste neu rendern fuer active-Klasse

    } catch (error) {
        console.error('Fehler beim Laden des Mitarbeiters:', error);
    } finally {
        hideLoading();
    }
}

function displayMitarbeiter(ma) {
    // Header
    document.getElementById('maId').value = ma.ID || '';
    document.getElementById('displayNachname').textContent = ma.Nachname || '-';
    document.getElementById('displayVorname').textContent = ma.Vorname || '-';

    // Adressfelder
    document.getElementById('strasse').value = ma.Strasse || '';
    document.getElementById('nr').value = ma.Nr || '';
    document.getElementById('plz').value = ma.PLZ || '';
    document.getElementById('ort').value = ma.Ort || '';
    document.getElementById('land').value = ma.Land || 'Deutschland';
    document.getElementById('bundesland').value = ma.Bundesland || '';

    // Kontaktdaten
    document.getElementById('telFestnetz').value = ma.Tel_Festnetz || '';
    document.getElementById('telMobil').value = ma.Tel_Mobil || '';
    document.getElementById('email').value = ma.Email || '';
}

// ============================================
// SPEICHERN
// ============================================
async function saveMitarbeiter() {
    if (!state.currentRecord) {
        showToast('Kein Mitarbeiter ausgewaehlt', 'warning');
        return;
    }

    // Validierung
    const strasse = document.getElementById('strasse').value.trim();
    const plz = document.getElementById('plz').value.trim();
    const ort = document.getElementById('ort').value.trim();
    const telMobil = document.getElementById('telMobil').value.trim();
    const email = document.getElementById('email').value.trim();

    if (!strasse) {
        showToast('Strasse ist ein Pflichtfeld', 'error');
        document.getElementById('strasse').classList.add('invalid');
        return;
    }

    if (!plz) {
        showToast('PLZ ist ein Pflichtfeld', 'error');
        document.getElementById('plz').classList.add('invalid');
        return;
    }

    if (plz && !/^\d{5}$/.test(plz)) {
        showToast('PLZ muss 5 Ziffern haben', 'error');
        document.getElementById('plz').classList.add('invalid');
        return;
    }

    if (!ort) {
        showToast('Ort ist ein Pflichtfeld', 'error');
        document.getElementById('ort').classList.add('invalid');
        return;
    }

    if (!telMobil) {
        showToast('Telefon Mobil ist ein Pflichtfeld', 'error');
        document.getElementById('telMobil').classList.add('invalid');
        return;
    }

    if (email && !validateEmail(email)) {
        showToast('E-Mail Format ungueltig', 'error');
        document.getElementById('email').classList.add('invalid');
        return;
    }

    // Alle invalid-Klassen entfernen
    document.querySelectorAll('.invalid').forEach(el => el.classList.remove('invalid'));

    // Daten sammeln
    const data = {
        Strasse: strasse,
        Nr: document.getElementById('nr').value.trim(),
        PLZ: plz,
        Ort: ort,
        Land: document.getElementById('land').value.trim() || 'Deutschland',
        Bundesland: document.getElementById('bundesland').value,
        Tel_Festnetz: document.getElementById('telFestnetz').value.trim(),
        Tel_Mobil: telMobil,
        Email: email
    };

    showLoading();
    try {
        await Bridge.put(`/mitarbeiter/${state.currentRecord.ID}`, data);

        // State aktualisieren
        Object.assign(state.currentRecord, data);
        state.mitarbeiterList[state.currentIndex] = { ...state.currentRecord };
        state.isDirty = false;

        showToast('Adressdaten erfolgreich gespeichert', 'success');
        renderMitarbeiterList();

    } catch (error) {
        console.error('Fehler beim Speichern:', error);
    } finally {
        hideLoading();
    }
}

// ============================================
// HELPER FUNCTIONS
// ============================================
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

let loadingTimeout = null;

function showLoading() {
    loadingTimeout = setTimeout(() => {
        document.getElementById('loadingOverlay').classList.add('active');
    }, 150);
}

function hideLoading() {
    if (loadingTimeout) {
        clearTimeout(loadingTimeout);
        loadingTimeout = null;
    }
    document.getElementById('loadingOverlay').classList.remove('active');
}

function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

function toggleFullscreen() {
    const btn = document.getElementById('fullscreenBtn');
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().then(() => {
            btn.title = 'Vollbild beenden';
        }).catch(err => console.error('Fullscreen error:', err));
    } else {
        document.exitFullscreen().then(() => {
            btn.title = 'Vollbild';
        }).catch(err => console.error('Exit fullscreen error:', err));
    }
}

// ============================================
// EVENT LISTENERS
// ============================================
function initEventListeners() {
    document.getElementById('searchInput').addEventListener('input', () => {
        renderMitarbeiterList();
    });

    document.getElementById('filterSelect').addEventListener('change', () => {
        loadMitarbeiterList();
    });

    // Dirty-Tracking
    const trackFields = ['strasse', 'nr', 'plz', 'ort', 'land', 'bundesland', 'telFestnetz', 'telMobil', 'email'];
    trackFields.forEach(fieldId => {
        const el = document.getElementById(fieldId);
        if (el) {
            el.addEventListener('input', () => {
                state.isDirty = true;
            });
        }
    });

    document.addEventListener('fullscreenchange', () => {
        const btn = document.getElementById('fullscreenBtn');
        btn.title = document.fullscreenElement ? 'Vollbild beenden' : 'Vollbild';
    });
}

// ============================================
// INITIALIZATION
// ============================================
window.addEventListener('DOMContentLoaded', () => {
    console.log('[frm_MA_Adressen] Initialisierung...');

    // Event Listeners initialisieren
    initEventListeners();

    // Datum anzeigen
    document.getElementById('lblDatum').textContent = new Date().toLocaleDateString('de-DE');

    // Mitarbeiter laden
    loadMitarbeiterList();
});

// ============================================
// WINDOW EXPORTS (fuer onclick Handler)
// ============================================
window.loadMitarbeiterList = loadMitarbeiterList;
window.saveMitarbeiter = saveMitarbeiter;
window.selectMitarbeiterByIndex = selectMitarbeiterByIndex;
window.toggleFullscreen = toggleFullscreen;

console.log('[frm_MA_Adressen] Logic-Datei geladen');
