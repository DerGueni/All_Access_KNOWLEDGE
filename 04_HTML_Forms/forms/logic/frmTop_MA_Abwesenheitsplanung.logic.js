/**
 * frmTop_MA_Abwesenheitsplanung.logic.js
 * Geschäftslogik für Abwesenheitsplanung
 */

const API_BASE = 'http://localhost:5000/api';

// State Management
const state = {
    mitarbeiterList: [],
    abwesenheitsgruende: [],
    berechneteFehlzeiten: [],
    selectedItems: new Set()
};

// ============================================
// INITIALISIERUNG
// ============================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Abwesenheitsplanung] Initialisierung...');

    // Aktuelles Datum anzeigen
    const today = new Date();
    document.getElementById('currentDate').textContent = formatDate(today);

    // Event-Listener
    initEventListeners();

    // Daten laden
    await loadMitarbeiter();
    await loadAbwesenheitsgruende();

    // Radio-Button Logik
    updateTeilzeitFields();

    hideLoading();
    showToast('Formular geladen', 'success');
});

// ============================================
// EVENT-LISTENER
// ============================================
function initEventListeners() {
    // Radio-Buttons
    document.getElementById('optGanztag').addEventListener('change', updateTeilzeitFields);
    document.getElementById('optTeilzeit').addEventListener('change', updateTeilzeitFields);

    // Berechnen-Button
    document.getElementById('btnAbwBerechnen').addEventListener('click', berechneAbwesenheiten);

    // Listen-Aktionen
    document.getElementById('btnMarkLoesch').addEventListener('click', loescheMarkierte);
    document.getElementById('btnAllLoesch').addEventListener('click', loescheAlle);

    // Speichern & Schließen
    document.getElementById('btnSpeichern').addEventListener('click', speichereAbwesenheiten);
    document.getElementById('btnSchliessen').addEventListener('click', () => window.close());

    // Reset
    document.getElementById('btnReset').addEventListener('click', resetForm);
}

// ============================================
// TEILZEIT-FELDER TOGGLE
// ============================================
function updateTeilzeitFields() {
    const istTeilzeit = document.getElementById('optTeilzeit').checked;
    const teilzeitFelder = document.getElementById('teilzeitFelder');

    if (istTeilzeit) {
        teilzeitFelder.style.display = 'block';
        // Standardwerte setzen
        if (!document.getElementById('TlZeitVon').value) {
            document.getElementById('TlZeitVon').value = '08:00';
        }
        if (!document.getElementById('TlZeitBis').value) {
            document.getElementById('TlZeitBis').value = '12:00';
        }
    } else {
        teilzeitFelder.style.display = 'none';
    }
}

// ============================================
// DATEN LADEN
// ============================================
async function loadMitarbeiter() {
    showLoading();
    try {
        const response = await fetch(`${API_BASE}/mitarbeiter?aktiv=true`);
        const result = await response.json();

        if (result.success) {
            // Nur aktive, keine Subunternehmer
            state.mitarbeiterList = (result.data || []).filter(ma =>
                ma.IstAktiv && !ma.Subunternehmer
            );

            renderMitarbeiterDropdown();
            updateStatus(`${state.mitarbeiterList.length} Mitarbeiter geladen`);
        } else {
            throw new Error(result.error || 'Fehler beim Laden');
        }
    } catch (error) {
        console.error('Fehler beim Laden der Mitarbeiter:', error);
        showToast('Fehler beim Laden der Mitarbeiter', 'error');
    } finally {
        hideLoading();
    }
}

async function loadAbwesenheitsgruende() {
    showLoading();
    try {
        const response = await fetch(`${API_BASE}/dienstplan/gruende`);
        const result = await response.json();

        if (result.success) {
            state.abwesenheitsgruende = result.data || [];
            renderAbwesenheitsgruendeDropdown();
        } else {
            throw new Error(result.error || 'Fehler beim Laden');
        }
    } catch (error) {
        console.error('Fehler beim Laden der Abwesenheitsgründe:', error);
        showToast('Fehler beim Laden der Abwesenheitsgründe', 'error');
    } finally {
        hideLoading();
    }
}

// ============================================
// RENDERING
// ============================================
function renderMitarbeiterDropdown() {
    const select = document.getElementById('cbo_MA_ID');
    select.innerHTML = '<option value="">-- Bitte wählen --</option>';

    state.mitarbeiterList
        .sort((a, b) => {
            const nameA = `${a.Nachname} ${a.Vorname}`.toLowerCase();
            const nameB = `${b.Nachname} ${b.Vorname}`.toLowerCase();
            return nameA.localeCompare(nameB);
        })
        .forEach(ma => {
            const option = document.createElement('option');
            option.value = ma.ID;
            option.textContent = `${ma.Nachname}, ${ma.Vorname}`;
            select.appendChild(option);
        });
}

function renderAbwesenheitsgruendeDropdown() {
    const select = document.getElementById('cboAbwGrund');
    select.innerHTML = '<option value="">-- Bitte wählen --</option>';

    state.abwesenheitsgruende
        .sort((a, b) => (a.Bezeichnung || '').localeCompare(b.Bezeichnung || ''))
        .forEach(grund => {
            const option = document.createElement('option');
            option.value = grund.ID;
            option.textContent = grund.Bezeichnung || grund.DP_Grund || `Grund ${grund.ID}`;
            select.appendChild(option);
        });
}

function renderFehlzeitenListe() {
    const container = document.getElementById('lsttmp_Fehlzeiten');
    const count = document.getElementById('countTage');

    container.innerHTML = '';
    count.textContent = state.berechneteFehlzeiten.length;

    if (state.berechneteFehlzeiten.length === 0) {
        container.innerHTML = '<div style="padding: 20px; text-align: center; color: #999;">Keine Einträge - Klicken Sie "Berechnen"</div>';
        return;
    }

    state.berechneteFehlzeiten.forEach((item, index) => {
        const div = document.createElement('div');
        div.className = 'list-item';
        if (state.selectedItems.has(index)) {
            div.classList.add('selected');
        }

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = state.selectedItems.has(index);
        checkbox.addEventListener('change', (e) => {
            if (e.target.checked) {
                state.selectedItems.add(index);
                div.classList.add('selected');
            } else {
                state.selectedItems.delete(index);
                div.classList.remove('selected');
            }
        });

        const dateSpan = document.createElement('span');
        dateSpan.className = 'item-date';
        dateSpan.textContent = formatDate(item.datum);

        const daySpan = document.createElement('span');
        daySpan.className = 'item-day';
        daySpan.textContent = getWochentag(item.datum);

        const typeSpan = document.createElement('span');
        typeSpan.className = 'item-type';
        typeSpan.textContent = item.typ || 'Ganztägig';

        div.appendChild(checkbox);
        div.appendChild(dateSpan);
        div.appendChild(daySpan);
        div.appendChild(typeSpan);

        div.addEventListener('click', (e) => {
            if (e.target !== checkbox) {
                checkbox.checked = !checkbox.checked;
                checkbox.dispatchEvent(new Event('change'));
            }
        });

        container.appendChild(div);
    });
}

// ============================================
// BERECHNEN
// ============================================
function berechneAbwesenheiten() {
    const maId = document.getElementById('cbo_MA_ID').value;
    const datVon = document.getElementById('DatVon').value;
    const datBis = document.getElementById('DatBis').value;
    const grundId = document.getElementById('cboAbwGrund').value;

    // Validierung
    if (!maId) {
        showToast('Bitte Mitarbeiter auswählen', 'warning');
        return;
    }
    if (!datVon || !datBis) {
        showToast('Bitte Zeitraum angeben', 'warning');
        return;
    }
    if (!grundId) {
        showToast('Bitte Abwesenheitsgrund auswählen', 'warning');
        return;
    }

    const von = new Date(datVon);
    const bis = new Date(datBis);

    if (von > bis) {
        showToast('Von-Datum muss vor Bis-Datum liegen', 'error');
        return;
    }

    const nurWerktags = document.getElementById('NurWerktags').checked;
    const istTeilzeit = document.getElementById('optTeilzeit').checked;
    const zeitVon = document.getElementById('TlZeitVon').value;
    const zeitBis = document.getElementById('TlZeitBis').value;

    // Alle Tage im Zeitraum berechnen
    state.berechneteFehlzeiten = [];
    state.selectedItems.clear();

    let current = new Date(von);
    while (current <= bis) {
        const dayOfWeek = current.getDay();
        const istWochenende = (dayOfWeek === 0 || dayOfWeek === 6);

        // Prüfen ob Tag eingefügt werden soll
        if (!nurWerktags || !istWochenende) {
            const entry = {
                datum: new Date(current),
                ma_id: maId,
                grund_id: grundId,
                typ: istTeilzeit ? `Teilzeit ${zeitVon} - ${zeitBis}` : 'Ganztägig',
                zeitVon: istTeilzeit ? zeitVon : null,
                zeitBis: istTeilzeit ? zeitBis : null
            };
            state.berechneteFehlzeiten.push(entry);
        }

        // Nächster Tag
        current.setDate(current.getDate() + 1);
    }

    renderFehlzeitenListe();
    updateStatus(`${state.berechneteFehlzeiten.length} Tage berechnet`);
    showToast(`${state.berechneteFehlzeiten.length} Tage berechnet`, 'success');
}

// ============================================
// LISTEN-AKTIONEN
// ============================================
function loescheMarkierte() {
    if (state.selectedItems.size === 0) {
        showToast('Keine Einträge markiert', 'warning');
        return;
    }

    // Von hinten nach vorne löschen um Index-Probleme zu vermeiden
    const toDelete = Array.from(state.selectedItems).sort((a, b) => b - a);
    toDelete.forEach(index => {
        state.berechneteFehlzeiten.splice(index, 1);
    });

    state.selectedItems.clear();
    renderFehlzeitenListe();
    showToast(`${toDelete.length} Einträge gelöscht`, 'success');
}

function loescheAlle() {
    if (state.berechneteFehlzeiten.length === 0) {
        showToast('Keine Einträge vorhanden', 'warning');
        return;
    }

    if (!confirm(`Wirklich alle ${state.berechneteFehlzeiten.length} Einträge löschen?`)) {
        return;
    }

    state.berechneteFehlzeiten = [];
    state.selectedItems.clear();
    renderFehlzeitenListe();
    showToast('Alle Einträge gelöscht', 'success');
}

// ============================================
// SPEICHERN
// ============================================
async function speichereAbwesenheiten() {
    if (state.berechneteFehlzeiten.length === 0) {
        showToast('Keine Abwesenheiten zum Speichern', 'warning');
        return;
    }

    const maId = document.getElementById('cbo_MA_ID').value;
    const grundId = document.getElementById('cboAbwGrund').value;
    const bemerkung = document.getElementById('Bemerkung').value;

    if (!maId || !grundId) {
        showToast('Mitarbeiter und Grund müssen ausgewählt sein', 'error');
        return;
    }

    const grundObj = state.abwesenheitsgruende.find(g => g.ID == grundId);
    const grundBezeichnung = grundObj ? grundObj.Bezeichnung : '';

    showLoading();
    updateStatus('Speichere Abwesenheiten...');

    let erfolg = 0;
    let fehler = 0;

    try {
        for (const entry of state.berechneteFehlzeiten) {
            try {
                const payload = {
                    MA_ID: parseInt(maId),
                    vonDat: formatDateISO(entry.datum),
                    bisDat: formatDateISO(entry.datum),
                    Grund: grundBezeichnung,
                    Bemerkung: bemerkung || null,
                    IstGanztag: !entry.zeitVon,
                    ZeitVon: entry.zeitVon || null,
                    ZeitBis: entry.zeitBis || null
                };

                const response = await fetch(`${API_BASE}/abwesenheiten`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                const result = await response.json();

                if (result.success) {
                    erfolg++;
                } else {
                    fehler++;
                    console.error('Fehler beim Speichern:', result.error);
                }
            } catch (err) {
                fehler++;
                console.error('Fehler beim Speichern eines Eintrags:', err);
            }
        }

        hideLoading();

        if (fehler === 0) {
            showToast(`${erfolg} Abwesenheiten erfolgreich gespeichert`, 'success');
            updateStatus(`${erfolg} Abwesenheiten gespeichert`);

            // Formular zurücksetzen nach erfolgreichem Speichern
            setTimeout(() => {
                resetForm();
            }, 1500);
        } else {
            showToast(`${erfolg} erfolgreich, ${fehler} Fehler`, 'warning');
            updateStatus(`Teilweise gespeichert: ${erfolg}/${erfolg + fehler}`);
        }
    } catch (error) {
        hideLoading();
        console.error('Fehler beim Speichern:', error);
        showToast('Fehler beim Speichern der Abwesenheiten', 'error');
        updateStatus('Fehler beim Speichern');
    }
}

// ============================================
// RESET
// ============================================
function resetForm() {
    document.getElementById('cbo_MA_ID').value = '';
    document.getElementById('cboAbwGrund').value = '';
    document.getElementById('Bemerkung').value = '';
    document.getElementById('DatVon').value = '';
    document.getElementById('DatBis').value = '';
    document.getElementById('TlZeitVon').value = '08:00';
    document.getElementById('TlZeitBis').value = '12:00';
    document.getElementById('NurWerktags').checked = false;
    document.getElementById('optGanztag').checked = true;

    state.berechneteFehlzeiten = [];
    state.selectedItems.clear();

    updateTeilzeitFields();
    renderFehlzeitenListe();
    updateStatus('Bereit');
}

// ============================================
// HELPER-FUNKTIONEN
// ============================================
function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return '';

    const day = String(d.getDate()).padStart(2, '0');
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const year = d.getFullYear();
    return `${day}.${month}.${year}`;
}

function formatDateISO(date) {
    if (!date) return '';
    const d = new Date(date);
    if (isNaN(d.getTime())) return '';

    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function getWochentag(dateStr) {
    const d = new Date(dateStr);
    const tage = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    return tage[d.getDay()];
}

function showLoading() {
    document.getElementById('loadingOverlay').classList.add('active');
}

function hideLoading() {
    document.getElementById('loadingOverlay').classList.remove('active');
}

function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type} show`;

    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

function updateStatus(text) {
    document.getElementById('statusText').textContent = text;
}

console.log('[Abwesenheitsplanung] Logic Script geladen');
