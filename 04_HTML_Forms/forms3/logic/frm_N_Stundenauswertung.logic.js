/**
 * frm_N_Stundenauswertung.logic.js
 * Logik fuer Datenimport Zeitkonten / Stundenauswertung
 * WebView2 Bridge Integration
 *
 * Funktionen:
 * - Importierte Daten laden und anzeigen
 * - Stundenvergleich durchfuehren
 * - Importfehler anzeigen und beheben
 * - Export fuer Lexware
 */

// ============================================
// State
// ============================================
const state = {
    importierteDaten: [],
    stundenvergleich: [],
    importfehler: [],
    filter: {
        mitarbeiter: null,
        anstellungsart: 'mini',
        zeitraum: 'aktuell'
    },
    activeTab: 'tabImportiert'
};

// ============================================
// DOM Elements
// ============================================
let elements = {};

// ============================================
// Initialisierung
// ============================================
function init() {
    console.log('[Stundenauswertung] Initialisierung...');

    elements = {
        // Filter
        cboMitarbeiter: document.getElementById('cboMitarbeiter'),
        cboAnstellungsart: document.getElementById('cboAnstellungsart'),
        cboZeitraum: document.getElementById('cboZeitraum'),

        // Buttons
        btnEinsaetzeEinzeln: document.getElementById('btnEinsaetzeEinzeln'),
        btnEinsaetzeFA: document.getElementById('btnEinsaetzeFA'),
        btnEinsaetzeFAAbrechnung: document.getElementById('btnEinsaetzeFAAbrechnung'),
        btnEinsaetzeMJ: document.getElementById('btnEinsaetzeMJ'),
        btnEinsaetzeMJAbrechnung: document.getElementById('btnEinsaetzeMJAbrechnung'),
        btnExport: document.getElementById('btnExport'),
        btnLexwareImport: document.getElementById('btnLexwareImport'),

        // Tabs
        tabButtons: document.querySelectorAll('.tab-btn'),
        tabPanes: document.querySelectorAll('.tab-pane'),

        // Tabellen
        tblImportiert: document.getElementById('tblImportiert'),
        tabImportiert: document.getElementById('tabImportiert'),
        tabStundenvergleich: document.getElementById('tabStundenvergleich'),
        tabImportfehler: document.getElementById('tabImportfehler'),

        // Footer
        lblStatus: document.getElementById('lblStatus'),
        lblAnzahl: document.getElementById('lblAnzahl')
    };

    // WebView2 Bridge Event-Listener registrieren
    if (typeof Bridge !== 'undefined' && Bridge.on) {
        Bridge.on('onDataReceived', handleBridgeData);
    }

    setupEventListeners();
    loadMitarbeiterLookup();
    loadData();
}

// ============================================
// Event Listeners
// ============================================
function setupEventListeners() {
    // Filter
    elements.cboMitarbeiter?.addEventListener('change', () => {
        state.filter.mitarbeiter = elements.cboMitarbeiter.value || null;
        loadData();
    });

    elements.cboAnstellungsart?.addEventListener('change', () => {
        state.filter.anstellungsart = elements.cboAnstellungsart.value;
        loadData();
    });

    elements.cboZeitraum?.addEventListener('change', () => {
        state.filter.zeitraum = elements.cboZeitraum.value;
        loadData();
    });

    // Tabs
    elements.tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.dataset.tab;
            switchTab(tabId);
        });
    });

    // Buttons
    elements.btnEinsaetzeEinzeln?.addEventListener('click', () => uebertrageEinsaetze('einzeln'));
    elements.btnEinsaetzeFA?.addEventListener('click', () => uebertrageEinsaetze('fa'));
    elements.btnEinsaetzeFAAbrechnung?.addEventListener('click', () => uebertrageEinsaetze('fa_abrechnung'));
    elements.btnEinsaetzeMJ?.addEventListener('click', () => uebertrageEinsaetze('mj'));
    elements.btnEinsaetzeMJAbrechnung?.addEventListener('click', () => uebertrageEinsaetze('mj_abrechnung'));
    elements.btnExport?.addEventListener('click', exportDaten);
    elements.btnLexwareImport?.addEventListener('click', erstelleLexwareImport);
}

// ============================================
// Tab-Wechsel
// ============================================
function switchTab(tabId) {
    state.activeTab = tabId;

    // Buttons aktualisieren
    elements.tabButtons.forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabId);
    });

    // Panes aktualisieren
    elements.tabPanes.forEach(pane => {
        pane.classList.toggle('active', pane.id === tabId);
    });

    // Daten fuer Tab laden
    switch (tabId) {
        case 'tabImportiert':
            renderImportierteDaten();
            break;
        case 'tabStundenvergleich':
            loadStundenvergleich();
            break;
        case 'tabImportfehler':
            loadImportfehler();
            break;
    }
}

// ============================================
// Mitarbeiter-Lookup laden
// ============================================
async function loadMitarbeiterLookup() {
    try {
        // WebView2 Bridge: Mitarbeiter Lookup laden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadMitarbeiterLookup', { aktiv: true });
        }

    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Laden MA-Lookup:', error);
    }
}

// ============================================
// Daten laden
// ============================================
async function loadData() {
    setStatus('Lade Daten...');

    try {
        // Zeitraum berechnen
        const zeitraum = berechneZeitraum(state.filter.zeitraum);

        // WebView2 Bridge: Stundendaten laden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadStundenExport', {
                ma_id: state.filter.mitarbeiter,
                anstellungsart: state.filter.anstellungsart,
                von: zeitraum.von,
                bis: zeitraum.bis
            });
        } else {
            state.importierteDaten = [];
            renderImportierteDaten();
        }

    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Importierte Daten rendern
// ============================================
function renderImportierteDaten() {
    const tbody = elements.tblImportiert?.querySelector('tbody');
    if (!tbody) return;

    if (state.importierteDaten.length === 0) {
        tbody.innerHTML = `
            <tr class="summe-row">
                <td></td><td></td><td><strong>Summe</strong></td>
                <td></td><td></td><td></td>
            </tr>
            <tr>
                <td colspan="6" style="text-align:center; padding:40px; color:#666;">
                    Keine Daten vorhanden
                </td>
            </tr>
        `;
        return;
    }

    // Summen berechnen
    let summeWert = 0;
    let summeFaktor = 0;

    const rows = state.importierteDaten.map(d => {
        summeWert += parseFloat(d.Wert || 0);
        summeFaktor += parseFloat(d.Faktor || 0);

        return `
            <tr>
                <td>${d.Jahr || ''}</td>
                <td>${d.Monat || ''}</td>
                <td>${d.Name || d.MA_Name || ''}</td>
                <td>${d.Lohnart || ''}</td>
                <td class="cell-number">${formatNumber(d.Wert)}</td>
                <td class="cell-number">${formatNumber(d.Faktor)}</td>
            </tr>
        `;
    });

    tbody.innerHTML = `
        <tr class="summe-row">
            <td></td><td></td><td><strong>Summe</strong></td>
            <td></td>
            <td class="cell-number"><strong>${formatNumber(summeWert)}</strong></td>
            <td class="cell-number"><strong>${formatNumber(summeFaktor)}</strong></td>
        </tr>
        ${rows.join('')}
    `;
}

// ============================================
// Stundenvergleich laden
// ============================================
async function loadStundenvergleich() {
    try {
        setStatus('Lade Stundenvergleich...');

        // WebView2 Bridge: Stundenvergleich laden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadStundenvergleich', {});
        } else {
            state.stundenvergleich = [];
        }

        // Rendern
        const container = elements.tabStundenvergleich;
        if (container) {
            if (state.stundenvergleich.length === 0) {
                container.innerHTML = '<p style="padding: 20px; color: #666;">Keine Daten vorhanden.</p>';
            } else {
                container.innerHTML = `
                    <table class="std-table">
                        <thead>
                            <tr>
                                <th>Mitarbeiter</th>
                                <th>Plan-Stunden</th>
                                <th>Ist-Stunden</th>
                                <th>Differenz</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${state.stundenvergleich.map(s => {
                                const diff = (s.Ist || 0) - (s.Plan || 0);
                                const diffClass = diff < 0 ? 'text-danger' : diff > 0 ? 'text-success' : '';
                                return `
                                    <tr>
                                        <td>${s.MA_Name || s.MA_ID}</td>
                                        <td class="cell-number">${formatNumber(s.Plan)}</td>
                                        <td class="cell-number">${formatNumber(s.Ist)}</td>
                                        <td class="cell-number ${diffClass}">${formatNumber(diff)}</td>
                                    </tr>
                                `;
                            }).join('')}
                        </tbody>
                    </table>
                `;
            }
        }

        setStatus('Stundenvergleich geladen');

    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Stundenvergleich:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Importfehler laden
// ============================================
async function loadImportfehler() {
    try {
        setStatus('Lade Importfehler...');

        // WebView2 Bridge: Importfehler laden
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('loadImportfehler', {});
        } else {
            state.importfehler = [];
        }

        const container = elements.tabImportfehler;
        if (container) {
            if (state.importfehler.length === 0) {
                container.innerHTML = '<p style="padding: 20px; color: #27ae60;">Keine Importfehler vorhanden.</p>';
            } else {
                container.innerHTML = `
                    <table class="std-table">
                        <thead>
                            <tr>
                                <th>Datum</th>
                                <th>Mitarbeiter</th>
                                <th>Fehler</th>
                                <th>Aktionen</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${state.importfehler.map(f => `
                                <tr data-id="${f.ID}">
                                    <td>${formatDate(f.Datum)}</td>
                                    <td>${f.MA_Name || f.MA_ID}</td>
                                    <td>${f.Fehlermeldung || f.Fehler}</td>
                                    <td>
                                        <button class="btn btn-sm" onclick="StundenauswertungForm.fixFehler(${f.ID})">Beheben</button>
                                        <button class="btn btn-sm" onclick="StundenauswertungForm.ignoreFehler(${f.ID})">Ignorieren</button>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                `;
            }
        }

        setStatus(`${state.importfehler.length} Importfehler`);

    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Laden Importfehler:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Einsaetze uebertragen
// ============================================
async function uebertrageEinsaetze(typ) {
    try {
        setStatus(`Uebertrage Einsaetze (${typ})...`);

        // Platzhalter - echte Logik implementieren
        alert(`Funktion "Einsaetze uebertragen (${typ})" - Noch nicht implementiert`);

        setStatus('Bereit');

    } catch (error) {
        console.error('[Stundenauswertung] Fehler bei Uebertragung:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Export
// ============================================
async function exportDaten() {
    try {
        setStatus('Exportiere Daten...');

        // Platzhalter - CSV oder Excel Export
        alert('Funktion "Export" - Noch nicht implementiert');

        setStatus('Bereit');

    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Export:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Lexware Import erstellen
// ============================================
async function erstelleLexwareImport() {
    try {
        setStatus('Erstelle Lexware Importdatei...');

        // Platzhalter - Lexware CSV erstellen
        alert('Funktion "Lexware Import erstellen" - Noch nicht implementiert');

        setStatus('Bereit');

    } catch (error) {
        console.error('[Stundenauswertung] Fehler bei Lexware Import:', error);
        setStatus('Fehler: ' + error.message);
    }
}

// ============================================
// Importfehler Aktionen
// ============================================
async function fixFehler(id) {
    try {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('fixImportfehler', { id });
        }
    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Beheben:', error);
        alert('Fehler: ' + error.message);
    }
}

async function ignoreFehler(id) {
    try {
        if (typeof Bridge !== 'undefined' && Bridge.sendEvent) {
            Bridge.sendEvent('ignoreImportfehler', { id });
        }
    } catch (error) {
        console.error('[Stundenauswertung] Fehler beim Ignorieren:', error);
        alert('Fehler: ' + error.message);
    }
}

// ============================================
// Helper
// ============================================
function berechneZeitraum(typ) {
    const heute = new Date();
    let von, bis;

    switch (typ) {
        case 'aktuell':
            von = new Date(heute.getFullYear(), heute.getMonth(), 1);
            bis = new Date(heute.getFullYear(), heute.getMonth() + 1, 0);
            break;
        case 'vormonat':
            von = new Date(heute.getFullYear(), heute.getMonth() - 1, 1);
            bis = new Date(heute.getFullYear(), heute.getMonth(), 0);
            break;
        case 'quartal':
            const quartalStart = Math.floor(heute.getMonth() / 3) * 3;
            von = new Date(heute.getFullYear(), quartalStart, 1);
            bis = new Date(heute.getFullYear(), quartalStart + 3, 0);
            break;
        case 'jahr':
            von = new Date(heute.getFullYear(), 0, 1);
            bis = new Date(heute.getFullYear(), 11, 31);
            break;
        default:
            von = new Date(heute.getFullYear(), heute.getMonth(), 1);
            bis = new Date(heute.getFullYear(), heute.getMonth() + 1, 0);
    }

    return {
        von: von.toISOString().split('T')[0],
        bis: bis.toISOString().split('T')[0]
    };
}

function formatNumber(value) {
    if (value === null || value === undefined) return '';
    return parseFloat(value).toFixed(2);
}

function formatDate(value) {
    if (!value) return '';
    try {
        return new Date(value).toLocaleDateString('de-DE');
    } catch {
        return value;
    }
}

function setStatus(text) {
    if (elements.lblStatus) elements.lblStatus.textContent = text;
}

function updateAnzahl() {
    if (elements.lblAnzahl) {
        elements.lblAnzahl.textContent = `${state.importierteDaten.length} Datensaetze`;
    }
}

// ============================================
// Bridge Event-Handler
// ============================================
function handleBridgeData(data) {
    console.log('[Stundenauswertung] Bridge Data empfangen:', data);

    if (data.mitarbeiterLookup) {
        if (elements.cboMitarbeiter) {
            elements.cboMitarbeiter.innerHTML = '<option value="">-- Alle --</option>';
            (data.mitarbeiterLookup || []).forEach(ma => {
                const opt = document.createElement('option');
                opt.value = ma.ID;
                opt.textContent = `${ma.Nachname}, ${ma.Vorname}`;
                elements.cboMitarbeiter.appendChild(opt);
            });
        }
    }

    if (data.stundenExport) {
        state.importierteDaten = data.stundenExport || [];
        renderImportierteDaten();
        updateAnzahl();
        setStatus(`${state.importierteDaten.length} Datensaetze geladen`);
    }

    if (data.stundenvergleich) {
        state.stundenvergleich = data.stundenvergleich || [];
        renderStundenvergleichTable();
    }

    if (data.importfehler) {
        state.importfehler = data.importfehler || [];
        renderImportfehlerTable();
    }

    if (data.fehlerFixed || data.fehlerIgnored) {
        loadImportfehler();
    }

    if (data.error) {
        setStatus('Fehler: ' + data.error);
    }
}

function renderStundenvergleichTable() {
    const container = elements.tabStundenvergleich;
    if (container) {
        if (state.stundenvergleich.length === 0) {
            container.innerHTML = '<p style="padding: 20px; color: #666;">Keine Daten vorhanden.</p>';
        } else {
            container.innerHTML = `
                <table class="std-table">
                    <thead>
                        <tr>
                            <th>Mitarbeiter</th>
                            <th>Plan-Stunden</th>
                            <th>Ist-Stunden</th>
                            <th>Differenz</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${state.stundenvergleich.map(s => {
                            const diff = (s.Ist || 0) - (s.Plan || 0);
                            const diffClass = diff < 0 ? 'text-danger' : diff > 0 ? 'text-success' : '';
                            return `
                                <tr>
                                    <td>${s.MA_Name || s.MA_ID}</td>
                                    <td class="cell-number">${formatNumber(s.Plan)}</td>
                                    <td class="cell-number">${formatNumber(s.Ist)}</td>
                                    <td class="cell-number ${diffClass}">${formatNumber(diff)}</td>
                                </tr>
                            `;
                        }).join('')}
                    </tbody>
                </table>
            `;
        }
    }
    setStatus('Stundenvergleich geladen');
}

function renderImportfehlerTable() {
    const container = elements.tabImportfehler;
    if (container) {
        if (state.importfehler.length === 0) {
            container.innerHTML = '<p style="padding: 20px; color: #27ae60;">Keine Importfehler vorhanden.</p>';
        } else {
            container.innerHTML = `
                <table class="std-table">
                    <thead>
                        <tr>
                            <th>Datum</th>
                            <th>Mitarbeiter</th>
                            <th>Fehler</th>
                            <th>Aktionen</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${state.importfehler.map(f => `
                            <tr data-id="${f.ID}">
                                <td>${formatDate(f.Datum)}</td>
                                <td>${f.MA_Name || f.MA_ID}</td>
                                <td>${f.Fehlermeldung || f.Fehler}</td>
                                <td>
                                    <button class="btn btn-sm" onclick="StundenauswertungForm.fixFehler(${f.ID})">Beheben</button>
                                    <button class="btn btn-sm" onclick="StundenauswertungForm.ignoreFehler(${f.ID})">Ignorieren</button>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        }
    }
    setStatus(`${state.importfehler.length} Importfehler`);
}

// ============================================
// Export
// ============================================
window.StundenauswertungForm = {
    reload: loadData,
    fixFehler: fixFehler,
    ignoreFehler: ignoreFehler
};

// Init bei DOM ready
document.addEventListener('DOMContentLoaded', init);
