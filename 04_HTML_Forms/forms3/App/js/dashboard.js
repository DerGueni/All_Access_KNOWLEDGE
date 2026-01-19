/**
 * CONSEC PLANUNG - Dashboard Logic
 * Zeigt nur Daten des eingeloggten Mitarbeiters
 */

// Auto-Refresh Intervall (30 Sekunden)
const SYNC_INTERVAL = 30000;
let syncTimer = null;

document.addEventListener('DOMContentLoaded', () => {
    // Prüfen ob eingeloggt
    if (!App.isLoggedIn()) {
        window.location.href = 'index.html';
        return;
    }

    const user = App.getUser();
    initDashboard(user);

    // Auto-Sync starten
    startAutoSync(user.id);
});

/**
 * Auto-Sync mit Backend starten
 */
function startAutoSync(maId) {
    // Bestehenden Timer stoppen
    if (syncTimer) clearInterval(syncTimer);

    // Neuen Timer starten
    syncTimer = setInterval(() => {
        console.log('Auto-Sync: Lade aktuelle Daten...');
        refreshData(maId);
    }, SYNC_INTERVAL);

    console.log(`Auto-Sync gestartet (alle ${SYNC_INTERVAL/1000}s)`);
}

/**
 * Daten manuell aktualisieren
 */
async function refreshData(maId) {
    try {
        await Promise.all([
            loadEinsaetze(maId),
            loadAnfragen(maId)
        ]);
        console.log('Daten aktualisiert');
    } catch (error) {
        console.error('Sync-Fehler:', error);
    }
}

/**
 * Dashboard initialisieren
 */
async function initDashboard(user) {
    // Benutzername anzeigen
    document.getElementById('userName').textContent = `${user.vorname} ${user.nachname}`;

    // MA-ID global speichern
    window.currentMaId = user.id;

    // Event Listener setzen
    setupEventListeners();

    // Verbindungsstatus anzeigen
    showConnectionStatus();

    // Daten laden
    await Promise.all([
        loadEinsaetze(user.id),
        loadAnfragen(user.id)
    ]);
}

/**
 * Verbindungsstatus zum Backend anzeigen
 */
async function showConnectionStatus() {
    const statusDot = document.querySelector('.status-dot');
    const statusText = document.querySelector('.status-text');

    try {
        const response = await fetch(`${App.API_BASE}/health`);
        if (response.ok) {
            const data = await response.json();
            statusDot.className = 'status-dot connected';
            statusText.textContent = 'Mit Access verbunden';
            console.log('Backend-Status:', data);
        } else {
            throw new Error('Server error');
        }
    } catch (error) {
        statusDot.className = 'status-dot error';
        statusText.textContent = 'Offline - Keine Verbindung';
        console.error('Backend nicht erreichbar:', error);
    }
}

/**
 * Event Listener Setup
 */
function setupEventListeners() {
    // Sidebar Toggle
    const menuBtn = document.getElementById('menuBtn');
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('overlay');
    const closeSidebar = document.getElementById('closeSidebar');

    menuBtn.addEventListener('click', () => {
        sidebar.classList.add('open');
        sidebar.classList.remove('hidden');
        overlay.classList.add('visible');
        overlay.classList.remove('hidden');
    });

    const closeSidebarFn = () => {
        sidebar.classList.remove('open');
        overlay.classList.remove('visible');
        setTimeout(() => {
            sidebar.classList.add('hidden');
            overlay.classList.add('hidden');
        }, 300);
    };

    closeSidebar.addEventListener('click', closeSidebarFn);
    overlay.addEventListener('click', closeSidebarFn);

    // User Dropdown
    const userBtn = document.getElementById('userBtn');
    const userMenu = document.getElementById('userMenu');

    userBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        userMenu.classList.toggle('hidden');
    });

    document.addEventListener('click', () => {
        userMenu.classList.add('hidden');
    });

    // Logout
    document.getElementById('logoutLink').addEventListener('click', (e) => {
        e.preventDefault();
        App.logout();
    });

    // QR Code Modal
    const qrCodeBtn = document.getElementById('qrCodeBtn');
    const qrModal = document.getElementById('qrModal');
    const closeQrModal = document.getElementById('closeQrModal');

    qrCodeBtn.addEventListener('click', () => {
        const user = App.getUser();
        document.getElementById('qrCode').innerHTML = App.generateQRCode(user.id);
        showModal(qrModal);
    });

    // Refresh Button
    const refreshBtn = document.getElementById('refreshBtn');
    refreshBtn.addEventListener('click', async () => {
        refreshBtn.disabled = true;
        refreshBtn.innerHTML = `
            <svg class="spinner" width="20" height="20" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3" fill="none" stroke-dasharray="32" stroke-linecap="round"/>
            </svg>
            Laden...
        `;

        await refreshData(window.currentMaId);
        await showConnectionStatus();

        refreshBtn.disabled = false;
        refreshBtn.innerHTML = `
            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.65 6.35A7.958 7.958 0 0012 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0112 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
            </svg>
            Aktualisieren
        `;
        App.toast('Daten aktualisiert', 'success');
    });

    closeQrModal.addEventListener('click', () => hideModal(qrModal));

    // Detail Modal
    const detailModal = document.getElementById('detailModal');
    const closeModal = document.getElementById('closeModal');

    closeModal.addEventListener('click', () => hideModal(detailModal));

    // Modal schließen bei Klick außerhalb
    [qrModal, detailModal].forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                hideModal(modal);
            }
        });
    });

    // Navigation Items
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const page = item.dataset.page;
            // Hier könnte Navigation zu anderen Seiten implementiert werden
            closeSidebarFn();
        });
    });
}

/**
 * Einsätze (zugeordnete Aufträge) laden
 */
async function loadEinsaetze(maId) {
    const container = document.getElementById('einsaetzeList');

    try {
        // Lade Zuordnungen für diesen Mitarbeiter
        const response = await App.get(`/zuordnungen?ma_id=${maId}`);
        const zuordnungen = response.data || response;

        if (!zuordnungen || zuordnungen.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11zM9 10H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm-8 4H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2z"/>
                    </svg>
                    <p>Keine zugeordneten Veranstaltungen gefunden.</p>
                </div>
            `;
            return;
        }

        // Nur zukünftige Einsätze anzeigen
        const heute = new Date();
        heute.setHours(0, 0, 0, 0);

        const zukunft = zuordnungen.filter(z => {
            const datum = new Date(z.VADatum || z.Datum);
            return datum >= heute;
        }).sort((a, b) => {
            return new Date(a.VADatum || a.Datum) - new Date(b.VADatum || b.Datum);
        });

        if (zukunft.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                    </svg>
                    <p>Keine anstehenden Einsätze.</p>
                </div>
            `;
            return;
        }

        container.innerHTML = zukunft.slice(0, 5).map(einsatz => `
            <div class="einsatz-card" data-id="${einsatz.ID}" data-type="einsatz">
                <div class="einsatz-header">
                    <span class="einsatz-title">${escapeHtml(einsatz.Auftrag || einsatz.Titel || 'Einsatz')}</span>
                    <span class="einsatz-date">${App.formatDate(einsatz.VADatum || einsatz.Datum)}</span>
                </div>
                <div class="einsatz-info">
                    <span class="einsatz-time">${App.formatTime(einsatz.MVA_Start || einsatz.VA_Start)} - ${App.formatTime(einsatz.MVA_Ende || einsatz.VA_Ende)}</span>
                    <span>${escapeHtml(einsatz.Ort || einsatz.Objekt || '-')}</span>
                    <span>${escapeHtml(einsatz.Objektname || einsatz.Location || '')}</span>
                </div>
            </div>
        `).join('');

        // Click Handler für Details
        container.querySelectorAll('.einsatz-card').forEach(card => {
            card.addEventListener('click', () => {
                const id = card.dataset.id;
                const einsatz = zukunft.find(e => e.ID == id);
                if (einsatz) showEinsatzDetail(einsatz);
            });
        });

    } catch (error) {
        console.error('Error loading Einsätze:', error);
        container.innerHTML = `
            <div class="empty-state">
                <p>Fehler beim Laden der Einsätze.</p>
                <button class="btn btn-outline" onclick="loadEinsaetze(${maId})">Erneut versuchen</button>
            </div>
        `;
    }
}

/**
 * Offene Anfragen laden
 */
async function loadAnfragen(maId) {
    const container = document.getElementById('anfragenList');
    const badge = document.getElementById('anfragenBadge');

    try {
        // Lade Planungen/Anfragen für diesen Mitarbeiter mit Status "angefragt" (Status_ID = 2)
        const response = await App.get(`/planungen?ma_id=${maId}&status=2`);
        const anfragen = response.data || response;

        if (!anfragen || anfragen.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                    </svg>
                    <p>Keine offenen Anfragen vorhanden.</p>
                </div>
            `;
            badge.classList.add('hidden');
            return;
        }

        // Badge aktualisieren
        badge.textContent = anfragen.length;
        badge.classList.remove('hidden');

        container.innerHTML = anfragen.map(anfrage => `
            <div class="anfrage-card" data-id="${anfrage.ID}">
                <div class="anfrage-header">
                    <span class="anfrage-title">${escapeHtml(anfrage.Auftrag || anfrage.Titel || 'Anfrage')}</span>
                    <span class="anfrage-date">${App.formatDate(anfrage.VADatum || anfrage.Datum)}<br>${App.formatTime(anfrage.VA_Start)} - ${App.formatTime(anfrage.VA_Ende)}</span>
                </div>
                <div class="anfrage-info">
                    <span>${escapeHtml(anfrage.Ort || anfrage.Stadt || '-')}</span>
                    <span>${escapeHtml(anfrage.Objektname || anfrage.Objekt || '')}</span>
                    <span>${escapeHtml(anfrage.Treffpunkt || '')}</span>
                </div>
                <div class="anfrage-actions">
                    <button class="btn btn-success btn-zusage" data-id="${anfrage.ID}">Zusage</button>
                    <button class="btn btn-danger btn-absage" data-id="${anfrage.ID}">Absage</button>
                </div>
            </div>
        `).join('');

        // Click Handler für Details (Karte klicken)
        container.querySelectorAll('.anfrage-card').forEach(card => {
            card.addEventListener('click', (e) => {
                // Nicht bei Button-Klick
                if (e.target.closest('.anfrage-actions')) return;

                const id = card.dataset.id;
                const anfrage = anfragen.find(a => a.ID == id);
                if (anfrage) showAnfrageDetail(anfrage);
            });
        });

        // Zusage/Absage Handler
        container.querySelectorAll('.btn-zusage').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                handleAntwort(btn.dataset.id, true);
            });
        });

        container.querySelectorAll('.btn-absage').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                handleAntwort(btn.dataset.id, false);
            });
        });

    } catch (error) {
        console.error('Error loading Anfragen:', error);
        container.innerHTML = `
            <div class="empty-state">
                <p>Fehler beim Laden der Anfragen.</p>
                <button class="btn btn-outline" onclick="loadAnfragen(${maId})">Erneut versuchen</button>
            </div>
        `;
    }
}

/**
 * Einsatz Detail Modal anzeigen
 */
function showEinsatzDetail(einsatz) {
    const modal = document.getElementById('detailModal');
    const title = document.getElementById('modalTitle');
    const body = document.getElementById('modalBody');
    const footer = document.getElementById('modalFooter');

    title.textContent = einsatz.Auftrag || einsatz.Titel || 'Einsatz Details';

    body.innerHTML = `
        <div class="detail-row">
            <div class="detail-label">Objekt</div>
            <div class="detail-value">${escapeHtml(einsatz.Objektname || einsatz.Objekt || '-')}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Start</div>
            <div class="detail-value">${App.formatDate(einsatz.VADatum || einsatz.Datum)} ${App.formatTime(einsatz.MVA_Start || einsatz.VA_Start)}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Ende</div>
            <div class="detail-value">${App.formatDate(einsatz.VADatum || einsatz.Datum)} ${App.formatTime(einsatz.MVA_Ende || einsatz.VA_Ende)}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Treffpunkt</div>
            <div class="detail-value">${escapeHtml(einsatz.Treffpunkt || '-')}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Dienstkleidung</div>
            <div class="detail-value">
                ${einsatz.Dienstkleidung ? `<span class="detail-badge">${escapeHtml(einsatz.Dienstkleidung)}</span>` : '-'}
            </div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Ort</div>
            <div class="detail-value">${escapeHtml(einsatz.Ort || einsatz.Stadt || '-')}</div>
        </div>
        ${einsatz.Bemerkungen ? `
        <div class="detail-row">
            <div class="detail-label">Beschreibung</div>
            <div class="detail-value">${escapeHtml(einsatz.Bemerkungen)}</div>
        </div>
        ` : ''}
    `;

    footer.innerHTML = `
        <button class="btn btn-outline" onclick="hideModal(document.getElementById('detailModal'))">Schließen</button>
    `;

    showModal(modal);
}

/**
 * Anfrage Detail Modal anzeigen
 */
function showAnfrageDetail(anfrage) {
    const modal = document.getElementById('detailModal');
    const title = document.getElementById('modalTitle');
    const body = document.getElementById('modalBody');
    const footer = document.getElementById('modalFooter');

    title.textContent = anfrage.Auftrag || anfrage.Titel || 'Anfrage Details';

    body.innerHTML = `
        <div class="detail-row">
            <div class="detail-label">Titel</div>
            <div class="detail-value">${escapeHtml(anfrage.Auftrag || anfrage.Titel || '-')}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Objekt</div>
            <div class="detail-value">${escapeHtml(anfrage.Objektname || anfrage.Objekt || '-')}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Start</div>
            <div class="detail-value">${App.formatDate(anfrage.VADatum || anfrage.Datum)} ${App.formatTime(anfrage.VA_Start)}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Ende</div>
            <div class="detail-value">${App.formatDate(anfrage.VADatum || anfrage.Datum)} ${App.formatTime(anfrage.VA_Ende)}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Treffpunkt</div>
            <div class="detail-value">${escapeHtml(anfrage.Treffpunkt || '-')}</div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Dienstkleidung</div>
            <div class="detail-value">
                ${anfrage.Dienstkleidung ? `<span class="detail-badge">${escapeHtml(anfrage.Dienstkleidung)}</span>` : '-'}
            </div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Ort</div>
            <div class="detail-value">${escapeHtml(anfrage.Ort || anfrage.Stadt || '-')}</div>
        </div>
        ${anfrage.Bemerkungen ? `
        <div class="detail-row">
            <div class="detail-label">Beschreibung</div>
            <div class="detail-value">${escapeHtml(anfrage.Bemerkungen)}</div>
        </div>
        ` : ''}
    `;

    footer.innerHTML = `
        <button class="btn btn-success" onclick="handleAntwort(${anfrage.ID}, true); hideModal(document.getElementById('detailModal'));">Zusage</button>
        <button class="btn btn-danger" onclick="handleAntwort(${anfrage.ID}, false); hideModal(document.getElementById('detailModal'));">Absage</button>
    `;

    showModal(modal);
}

/**
 * Zusage/Absage verarbeiten
 * NEU: Verwendet die speziellen /zusage und /absage Endpoints
 */
async function handleAntwort(anfrageId, istZusage) {
    const user = App.getUser();

    try {
        const endpoint = istZusage
            ? `/planungen/${anfrageId}/zusage`
            : `/planungen/${anfrageId}/absage`;

        const response = await App.post(endpoint, {});

        if (response.success) {
            App.toast(
                response.message || (istZusage ? 'Zusage erfolgreich!' : 'Absage erfolgreich!'),
                istZusage ? 'success' : 'info'
            );
        } else {
            throw new Error(response.error || 'Unbekannter Fehler');
        }

        // Listen neu laden - bei Zusage erscheint der Einsatz jetzt in "Meine Einsätze"
        await Promise.all([
            loadEinsaetze(user.id),
            loadAnfragen(user.id)
        ]);

    } catch (error) {
        console.error('Error sending response:', error);
        App.toast(error.message || 'Fehler beim Senden der Antwort. Bitte erneut versuchen.', 'error');
    }
}

/**
 * Modal anzeigen
 */
function showModal(modal) {
    modal.classList.remove('hidden');
    requestAnimationFrame(() => {
        modal.classList.add('visible');
    });
    document.body.style.overflow = 'hidden';
}

/**
 * Modal verstecken
 */
function hideModal(modal) {
    modal.classList.remove('visible');
    setTimeout(() => {
        modal.classList.add('hidden');
    }, 300);
    document.body.style.overflow = '';
}

/**
 * HTML Escaping
 */
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Globale Funktionen für onclick
window.loadEinsaetze = loadEinsaetze;
window.loadAnfragen = loadAnfragen;
window.hideModal = hideModal;
window.handleAntwort = handleAntwort;
