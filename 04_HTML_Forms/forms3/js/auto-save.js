/**
 * auto-save.js
 * Universeller Auto-Save Manager für HTML-Formulare
 *
 * Features:
 * - Debounced Auto-Save (500ms nach letzter Änderung)
 * - UI-Status-Anzeige (Gespeichert / Wird gespeichert...)
 * - Conflict-Resolution bei Backend-Änderungen
 * - Change-Tracking für alle Eingabefelder
 * - Zentrale Fehlerbehandlung
 *
 * Erstellt: 2026-01-15
 */

export class AutoSaveManager {
    constructor(options = {}) {
        this.options = {
            debounceMs: options.debounceMs || 500,
            statusElementId: options.statusElementId || 'saveStatus',
            onSave: options.onSave || null,  // async function(data) { return savedData; }
            onConflict: options.onConflict || null,  // function(local, remote) { return resolved; }
            trackFields: options.trackFields || [],  // Array von Field-IDs
            autoTrack: options.autoTrack !== false,  // Auto-detect input fields
            showToast: options.showToast !== false,
            debug: options.debug || false
        };

        this.state = {
            isDirty: false,
            isSaving: false,
            lastSaved: null,
            lastData: null,
            saveTimeout: null
        };

        this.init();
    }

    init() {
        if (this.options.debug) {
            console.log('[AutoSave] Initialisiere mit Optionen:', this.options);
        }

        // Status-Element erstellen falls nicht vorhanden
        this.createStatusElement();

        // Felder tracken
        if (this.options.autoTrack) {
            this.autoDetectFields();
        }

        this.options.trackFields.forEach(fieldId => {
            this.trackField(fieldId);
        });

        this.setStatus('ready');
    }

    /**
     * Erstellt Status-Element im DOM falls nicht vorhanden
     */
    createStatusElement() {
        let statusEl = document.getElementById(this.options.statusElementId);

        if (!statusEl) {
            // Suche nach einem Container (z.B. .form-footer, .status-bar)
            const container = document.querySelector('.form-footer, .status-bar, footer');

            if (container) {
                statusEl = document.createElement('span');
                statusEl.id = this.options.statusElementId;
                statusEl.className = 'save-status';
                container.appendChild(statusEl);
            }
        }

        this.statusElement = statusEl;
    }

    /**
     * Auto-Detect aller Input-Felder im Formular
     */
    autoDetectFields() {
        const inputs = document.querySelectorAll('input, select, textarea');

        inputs.forEach(input => {
            // Skip hidden, buttons, submit, etc.
            if (
                input.type === 'hidden' ||
                input.type === 'button' ||
                input.type === 'submit' ||
                input.type === 'reset' ||
                !input.id
            ) {
                return;
            }

            this.trackField(input.id);
        });

        if (this.options.debug) {
            console.log('[AutoSave] Auto-Detected', inputs.length, 'Felder');
        }
    }

    /**
     * Feld für Change-Tracking registrieren
     */
    trackField(fieldId) {
        const el = document.getElementById(fieldId);
        if (!el) {
            console.warn('[AutoSave] Feld nicht gefunden:', fieldId);
            return;
        }

        // Change-Event
        el.addEventListener('change', () => {
            this.markDirty();
            this.scheduleSave();
        });

        // Input-Event für Text-Felder (debounced)
        if (
            el.tagName === 'INPUT' &&
            (el.type === 'text' || el.type === 'number' || el.type === 'email' || el.type === 'tel') ||
            el.tagName === 'TEXTAREA'
        ) {
            el.addEventListener('input', () => {
                this.markDirty();
                this.scheduleSave();
            });
        }
    }

    /**
     * Markiert Formular als geändert
     */
    markDirty() {
        this.state.isDirty = true;
        this.setStatus('unsaved');
    }

    /**
     * Plant Speichervorgang (debounced)
     */
    scheduleSave() {
        // Bestehenden Timeout abbrechen
        if (this.state.saveTimeout) {
            clearTimeout(this.state.saveTimeout);
        }

        // Neuen Timeout setzen
        this.state.saveTimeout = setTimeout(() => {
            this.save();
        }, this.options.debounceMs);
    }

    /**
     * Speichert Formular-Daten
     */
    async save() {
        if (!this.state.isDirty || this.state.isSaving) {
            return;
        }

        if (!this.options.onSave) {
            console.error('[AutoSave] Keine onSave-Funktion definiert!');
            return;
        }

        this.state.isSaving = true;
        this.setStatus('saving');

        try {
            // Formular-Daten sammeln
            const data = this.collectFormData();

            // Conflict-Detection: Prüfen ob Backend-Daten sich geändert haben
            if (this.options.onConflict && this.state.lastData) {
                const remoteData = await this.fetchRemoteData();
                if (remoteData && this.hasConflict(data, remoteData)) {
                    const resolved = this.options.onConflict(data, remoteData);
                    if (!resolved) {
                        this.setStatus('conflict');
                        this.showConflictDialog(data, remoteData);
                        return;
                    }
                    // Verwende resolved data
                    Object.assign(data, resolved);
                }
            }

            // Speichern via Callback
            const savedData = await this.options.onSave(data);

            // Erfolg
            this.state.isDirty = false;
            this.state.lastSaved = new Date();
            this.state.lastData = savedData || data;
            this.setStatus('saved');

            if (this.options.showToast && typeof Toast !== 'undefined') {
                Toast.success('Automatisch gespeichert');
            }

            if (this.options.debug) {
                console.log('[AutoSave] Erfolgreich gespeichert:', data);
            }

        } catch (error) {
            console.error('[AutoSave] Fehler beim Speichern:', error);
            this.setStatus('error', error.message);

            if (this.options.showToast && typeof Toast !== 'undefined') {
                Toast.error('Fehler beim Speichern: ' + error.message);
            }

        } finally {
            this.state.isSaving = false;
        }
    }

    /**
     * Sammelt alle Formular-Daten
     */
    collectFormData() {
        const data = {};

        const inputs = document.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            if (!input.id || input.type === 'button' || input.type === 'submit') {
                return;
            }

            if (input.type === 'checkbox') {
                data[input.id] = input.checked;
            } else if (input.type === 'radio') {
                if (input.checked) {
                    data[input.name] = input.value;
                }
            } else {
                data[input.id] = input.value;
            }
        });

        return data;
    }

    /**
     * Lädt Remote-Daten für Conflict-Detection
     * Muss von Subclass überschrieben werden
     */
    async fetchRemoteData() {
        // Überschreiben in Subclass oder via options.onFetchRemote
        return null;
    }

    /**
     * Prüft ob lokale und Remote-Daten konfliktieren
     */
    hasConflict(localData, remoteData) {
        // Einfache Prüfung: Haben sich Remote-Daten seit letztem Speichern geändert?
        if (!this.state.lastData) return false;

        // Vergleiche kritische Felder
        const criticalFields = Object.keys(localData);

        for (const field of criticalFields) {
            const lastValue = this.state.lastData[field];
            const remoteValue = remoteData[field];
            const localValue = localData[field];

            // Wenn Remote-Wert sich geändert hat UND lokal auch geändert wurde
            if (lastValue !== remoteValue && localValue !== lastValue) {
                if (this.options.debug) {
                    console.log('[AutoSave] Conflict detected:', field, {
                        last: lastValue,
                        remote: remoteValue,
                        local: localValue
                    });
                }
                return true;
            }
        }

        return false;
    }

    /**
     * Zeigt Conflict-Dialog
     */
    showConflictDialog(localData, remoteData) {
        const msg = 'Die Daten wurden zwischenzeitlich geändert. Möchten Sie Ihre Änderungen überschreiben?';

        if (confirm(msg)) {
            // Lokale Änderungen forcieren
            this.state.lastData = null;  // Conflict-Detection deaktivieren
            this.save();
        } else {
            // Remote-Daten übernehmen
            this.applyRemoteData(remoteData);
            this.state.isDirty = false;
            this.setStatus('ready');
        }
    }

    /**
     * Wendet Remote-Daten auf Formular an
     */
    applyRemoteData(data) {
        Object.keys(data).forEach(fieldId => {
            const el = document.getElementById(fieldId);
            if (el) {
                if (el.type === 'checkbox') {
                    el.checked = !!data[fieldId];
                } else {
                    el.value = data[fieldId] || '';
                }
            }
        });
    }

    /**
     * Setzt Status-Anzeige
     */
    setStatus(status, message = '') {
        const statusMap = {
            ready: { icon: '', text: '', className: '' },
            unsaved: { icon: '●', text: 'Nicht gespeichert', className: 'unsaved' },
            saving: { icon: '⏳', text: 'Wird gespeichert...', className: 'saving' },
            saved: { icon: '✓', text: 'Gespeichert', className: 'saved' },
            error: { icon: '✗', text: 'Fehler: ' + message, className: 'error' },
            conflict: { icon: '⚠', text: 'Konflikt erkannt', className: 'conflict' }
        };

        const statusInfo = statusMap[status] || statusMap.ready;

        if (this.statusElement) {
            this.statusElement.innerHTML = `<span class="status-icon">${statusInfo.icon}</span> ${statusInfo.text}`;
            this.statusElement.className = 'save-status ' + statusInfo.className;
        }

        if (this.options.debug) {
            console.log('[AutoSave] Status:', status, message);
        }
    }

    /**
     * Manuelles Speichern erzwingen
     */
    forceSave() {
        if (this.state.saveTimeout) {
            clearTimeout(this.state.saveTimeout);
        }
        this.save();
    }

    /**
     * Cleanup
     */
    destroy() {
        if (this.state.saveTimeout) {
            clearTimeout(this.state.saveTimeout);
        }
    }
}

/**
 * Globale Instanz für einfachen Zugriff
 */
window.AutoSave = AutoSaveManager;
