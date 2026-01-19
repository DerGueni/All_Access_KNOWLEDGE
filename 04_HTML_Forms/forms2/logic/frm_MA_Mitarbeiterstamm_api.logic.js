/**
 * frm_MA_Mitarbeiterstamm_api.logic.js
 * Erweiterte API-Funktionalität für Mitarbeiterstamm
 * API-Basis: http://localhost:5000/api
 *
 * HINWEIS: Diese Datei ergänzt das eingebettete JavaScript im HTML.
 * Sie kann als Modul importiert oder direkt eingebunden werden.
 */

const API_BASE = 'http://localhost:5000/api';

/**
 * API-Handler für Mitarbeiter-CRUD-Operationen
 */
const MitarbeiterAPI = {
    /**
     * Alle Mitarbeiter laden (mit Filter)
     */
    async getAll(filter = {}) {
        try {
            const params = new URLSearchParams();
            if (filter.aktiv !== undefined) {
                params.append('aktiv', filter.aktiv);
            }
            if (filter.search) {
                params.append('search', filter.search);
            }

            const url = `${API_BASE}/mitarbeiter${params.toString() ? '?' + params.toString() : ''}`;
            const response = await fetch(url);

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            return data.data || data || [];
        } catch (error) {
            console.error('[MitarbeiterAPI] Fehler beim Laden der Liste:', error);
            throw error;
        }
    },

    /**
     * Einzelnen Mitarbeiter laden
     */
    async getById(id) {
        try {
            const response = await fetch(`${API_BASE}/mitarbeiter/${id}`);

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            return data.data?.mitarbeiter || data.data || data;
        } catch (error) {
            console.error(`[MitarbeiterAPI] Fehler beim Laden von MA ${id}:`, error);
            throw error;
        }
    },

    /**
     * Neuen Mitarbeiter anlegen
     */
    async create(mitarbeiterData) {
        try {
            const response = await fetch(`${API_BASE}/mitarbeiter`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(mitarbeiterData)
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.message || `HTTP ${response.status}`);
            }

            const data = await response.json();
            return data.data || data;
        } catch (error) {
            console.error('[MitarbeiterAPI] Fehler beim Anlegen:', error);
            throw error;
        }
    },

    /**
     * Mitarbeiter aktualisieren
     */
    async update(id, mitarbeiterData) {
        try {
            const response = await fetch(`${API_BASE}/mitarbeiter/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(mitarbeiterData)
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.message || `HTTP ${response.status}`);
            }

            const data = await response.json();
            return data.data || data;
        } catch (error) {
            console.error(`[MitarbeiterAPI] Fehler beim Aktualisieren von MA ${id}:`, error);
            throw error;
        }
    },

    /**
     * Mitarbeiter löschen
     */
    async delete(id) {
        try {
            const response = await fetch(`${API_BASE}/mitarbeiter/${id}`, {
                method: 'DELETE'
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return true;
        } catch (error) {
            console.error(`[MitarbeiterAPI] Fehler beim Löschen von MA ${id}:`, error);
            throw error;
        }
    },

    /**
     * Formulardaten aus DOM sammeln
     */
    collectFormData() {
        const data = {};

        // Alle Felder mit data-field Attribut sammeln
        document.querySelectorAll('[data-field]').forEach(el => {
            const fieldName = el.dataset.field;

            if (el.type === 'checkbox') {
                data[fieldName] = el.checked;
            } else if (el.type === 'number') {
                data[fieldName] = el.value ? parseFloat(el.value) : null;
            } else if (el.type === 'date') {
                data[fieldName] = el.value || null;
            } else {
                data[fieldName] = el.value || null;
            }
        });

        return data;
    },

    /**
     * Formular mit Mitarbeiterdaten befüllen
     */
    fillForm(mitarbeiter) {
        if (!mitarbeiter) return;

        // Alle Felder mit data-field Attribut befüllen
        document.querySelectorAll('[data-field]').forEach(el => {
            const fieldName = el.dataset.field;
            const value = mitarbeiter[fieldName];

            if (el.type === 'checkbox') {
                el.checked = !!value;
            } else if (value !== null && value !== undefined) {
                // Datumsfelder formatieren
                if (value && typeof value === 'string' && value.includes('T')) {
                    const date = new Date(value);
                    if (!isNaN(date)) {
                        el.value = date.toISOString().split('T')[0]; // YYYY-MM-DD
                    } else {
                        el.value = value;
                    }
                } else {
                    el.value = value;
                }
            } else {
                el.value = '';
            }
        });

        // Header-Anzeige aktualisieren
        const displayNachname = document.getElementById('displayNachname');
        const displayVorname = document.getElementById('displayVorname');
        const maNr = document.getElementById('maNr');

        if (displayNachname) displayNachname.textContent = mitarbeiter.Nachname || '-';
        if (displayVorname) displayVorname.textContent = mitarbeiter.Vorname || '-';
        if (maNr) maNr.value = mitarbeiter.ID || '';

        // Foto aktualisieren
        this.updatePhoto(mitarbeiter.Lichtbild || mitarbeiter.MA_Lichtbild);

        // Zeitstempel aktualisieren
        this.updateTimestamps(mitarbeiter);
    },

    /**
     * Foto aktualisieren
     */
    updatePhoto(photoPath) {
        const photoEl = document.getElementById('maPhoto');
        if (!photoEl) return;

        if (!photoPath) {
            photoEl.removeAttribute('src');
            photoEl.alt = 'Kein Foto';
            return;
        }

        // Pfad-Auflösung
        let src = '';
        if (/^https?:/i.test(photoPath) || /^file:/i.test(photoPath)) {
            src = photoPath;
        } else if (/^[A-Za-z]:[\\/]/.test(photoPath)) {
            src = `file:///${photoPath.replace(/\\/g, '/')}`;
        } else if (/^\\\\/.test(photoPath)) {
            src = `file:${photoPath.replace(/\\/g, '/')}`;
        } else {
            src = `../media/mitarbeiter/${photoPath}`;
        }

        photoEl.onerror = () => {
            photoEl.removeAttribute('src');
            photoEl.alt = 'Foto nicht gefunden';
        };
        photoEl.src = src;
        photoEl.alt = 'Mitarbeiterfoto';
    },

    /**
     * Zeitstempel aktualisieren
     */
    updateTimestamps(mitarbeiter) {
        if (mitarbeiter.Erst_am) {
            const erstelltAm = document.getElementById('erstelltAm');
            if (erstelltAm) {
                const date = new Date(mitarbeiter.Erst_am);
                erstelltAm.textContent = date.toLocaleDateString('de-DE');
            }
        }

        if (mitarbeiter.Erst_von) {
            const erstelltVon = document.getElementById('erstelltVon');
            if (erstelltVon) erstelltVon.textContent = mitarbeiter.Erst_von;
        }

        if (mitarbeiter.Aend_am) {
            const geaendertAm = document.getElementById('geaendertAm');
            if (geaendertAm) {
                const date = new Date(mitarbeiter.Aend_am);
                geaendertAm.textContent = date.toLocaleDateString('de-DE');
            }
        }

        if (mitarbeiter.Aend_von) {
            const geaendertVon = document.getElementById('geaendertVon');
            if (geaendertVon) geaendertVon.textContent = mitarbeiter.Aend_von;
        }
    },

    /**
     * Formular leeren
     */
    clearForm() {
        document.querySelectorAll('[data-field]').forEach(el => {
            if (el.type === 'checkbox') {
                el.checked = false;
            } else {
                el.value = '';
            }
        });

        const displayNachname = document.getElementById('displayNachname');
        const displayVorname = document.getElementById('displayVorname');
        const maNr = document.getElementById('maNr');

        if (displayNachname) displayNachname.textContent = '-';
        if (displayVorname) displayVorname.textContent = '-';
        if (maNr) maNr.value = '';

        this.updatePhoto(null);
    }
};

/**
 * Export für Verwendung in anderen Modulen
 */
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MitarbeiterAPI;
}

// Global verfügbar machen
if (typeof window !== 'undefined') {
    window.MitarbeiterAPI = MitarbeiterAPI;
}
