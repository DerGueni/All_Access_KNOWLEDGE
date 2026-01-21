/**
 * Bulk Operations System
 * Mehrfachauswahl und Massenaktionen fuer Listen
 *
 * Verwendung:
 *   const bulk = new BulkOperations('#maTable', {
 *       idField: 'data-ma-id',
 *       onSelectionChange: (ids) => console.log('Ausgewählt:', ids)
 *   });
 *
 *   // Toolbar einblenden
 *   bulk.showToolbar([
 *       { label: 'Anfragen senden', action: () => bulk.execute(sendAnfragen) },
 *       { label: 'Zuordnen', action: () => bulk.execute(zuordnen) }
 *   ]);
 */

'use strict';

class BulkOperations {
    constructor(tableSelector, options = {}) {
        this.table = document.querySelector(tableSelector);
        if (!this.table) {
            console.error('[BulkOps] Tabelle nicht gefunden:', tableSelector);
            return;
        }

        this.options = {
            idField: 'data-id',
            rowSelector: 'tbody tr',
            checkboxClass: 'bulk-checkbox',
            selectedClass: 'bulk-selected',
            toolbarId: 'bulk-toolbar',
            onSelectionChange: null,
            ...options
        };

        this.selectedIds = new Set();
        this.toolbar = null;
        this.selectAllCheckbox = null;

        this.init();
    }

    /**
     * Initialisieren
     */
    init() {
        this.injectStyles();
        this.addCheckboxColumn();
        this.bindEvents();
        console.log('[BulkOps] Initialisiert fuer', this.table);
    }

    /**
     * CSS injizieren
     */
    injectStyles() {
        if (document.getElementById('bulk-ops-styles')) return;

        const styles = document.createElement('style');
        styles.id = 'bulk-ops-styles';
        styles.textContent = `
            .bulk-checkbox-cell {
                width: 30px;
                text-align: center;
                padding: 4px !important;
            }

            .bulk-checkbox {
                width: 16px;
                height: 16px;
                cursor: pointer;
                accent-color: #4060a0;
            }

            .bulk-selected {
                background-color: rgba(64, 96, 160, 0.15) !important;
            }

            .bulk-selected td {
                background-color: transparent !important;
            }

            #bulk-toolbar {
                position: fixed;
                bottom: 0;
                left: 0;
                right: 0;
                background: linear-gradient(to bottom, #4060a0 0%, #304080 100%);
                color: white;
                padding: 12px 20px;
                display: flex;
                align-items: center;
                gap: 16px;
                z-index: 10000;
                box-shadow: 0 -4px 20px rgba(0,0,0,0.3);
                transform: translateY(100%);
                transition: transform 0.3s ease;
            }

            #bulk-toolbar.visible {
                transform: translateY(0);
            }

            .bulk-toolbar-info {
                font-weight: bold;
                font-size: 14px;
                min-width: 120px;
            }

            .bulk-toolbar-actions {
                display: flex;
                gap: 8px;
                flex: 1;
            }

            .bulk-toolbar-btn {
                padding: 8px 16px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 12px;
                font-weight: bold;
                transition: all 0.2s ease;
            }

            .bulk-toolbar-btn.primary {
                background: #28a745;
                color: white;
            }

            .bulk-toolbar-btn.primary:hover {
                background: #218838;
            }

            .bulk-toolbar-btn.secondary {
                background: rgba(255,255,255,0.2);
                color: white;
            }

            .bulk-toolbar-btn.secondary:hover {
                background: rgba(255,255,255,0.3);
            }

            .bulk-toolbar-btn.danger {
                background: #dc3545;
                color: white;
            }

            .bulk-toolbar-btn.danger:hover {
                background: #c82333;
            }

            .bulk-toolbar-close {
                background: transparent;
                border: none;
                color: white;
                font-size: 20px;
                cursor: pointer;
                padding: 4px 8px;
                opacity: 0.7;
            }

            .bulk-toolbar-close:hover {
                opacity: 1;
            }

            /* Header Checkbox */
            th .bulk-checkbox {
                margin: 0;
            }
        `;
        document.head.appendChild(styles);
    }

    /**
     * Checkbox-Spalte hinzufuegen
     */
    addCheckboxColumn() {
        // Header
        const headerRow = this.table.querySelector('thead tr');
        if (headerRow) {
            const th = document.createElement('th');
            th.className = 'bulk-checkbox-cell';
            th.innerHTML = `<input type="checkbox" class="bulk-checkbox bulk-select-all" title="Alle auswaehlen">`;
            headerRow.insertBefore(th, headerRow.firstChild);

            this.selectAllCheckbox = th.querySelector('.bulk-select-all');
        }

        // Body Rows
        const rows = this.table.querySelectorAll(this.options.rowSelector);
        rows.forEach(row => {
            const td = document.createElement('td');
            td.className = 'bulk-checkbox-cell';
            td.innerHTML = `<input type="checkbox" class="${this.options.checkboxClass}">`;
            row.insertBefore(td, row.firstChild);
        });
    }

    /**
     * Events binden
     */
    bindEvents() {
        // Checkbox-Klicks
        this.table.addEventListener('change', (e) => {
            if (e.target.classList.contains(this.options.checkboxClass)) {
                this.handleCheckboxChange(e.target);
            } else if (e.target.classList.contains('bulk-select-all')) {
                this.handleSelectAll(e.target.checked);
            }
        });

        // Shift+Click fuer Bereichsauswahl
        let lastCheckedIndex = null;
        this.table.addEventListener('click', (e) => {
            if (!e.target.classList.contains(this.options.checkboxClass)) return;

            const rows = Array.from(this.table.querySelectorAll(this.options.rowSelector));
            const currentRow = e.target.closest('tr');
            const currentIndex = rows.indexOf(currentRow);

            if (e.shiftKey && lastCheckedIndex !== null) {
                const start = Math.min(lastCheckedIndex, currentIndex);
                const end = Math.max(lastCheckedIndex, currentIndex);

                for (let i = start; i <= end; i++) {
                    const checkbox = rows[i].querySelector('.' + this.options.checkboxClass);
                    if (checkbox && !checkbox.checked) {
                        checkbox.checked = true;
                        this.handleCheckboxChange(checkbox);
                    }
                }
            }

            lastCheckedIndex = currentIndex;
        });

        // Keyboard: Escape zum Abbrechen
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.selectedIds.size > 0) {
                this.clearSelection();
            }
        });
    }

    /**
     * Checkbox-Aenderung verarbeiten
     */
    handleCheckboxChange(checkbox) {
        const row = checkbox.closest('tr');
        const id = row.getAttribute(this.options.idField) ||
                   row.querySelector(`[${this.options.idField}]`)?.getAttribute(this.options.idField) ||
                   row.dataset.id;

        if (!id) {
            console.warn('[BulkOps] Keine ID gefunden fuer Zeile');
            return;
        }

        if (checkbox.checked) {
            this.selectedIds.add(id);
            row.classList.add(this.options.selectedClass);
        } else {
            this.selectedIds.delete(id);
            row.classList.remove(this.options.selectedClass);
        }

        this.updateUI();
        this.notifySelectionChange();
    }

    /**
     * Alle auswaehlen/abwaehlen
     */
    handleSelectAll(checked) {
        const checkboxes = this.table.querySelectorAll(
            `${this.options.rowSelector} .${this.options.checkboxClass}`
        );

        checkboxes.forEach(checkbox => {
            if (checkbox.checked !== checked) {
                checkbox.checked = checked;
                this.handleCheckboxChange(checkbox);
            }
        });
    }

    /**
     * UI aktualisieren
     */
    updateUI() {
        const count = this.selectedIds.size;

        // Select-All Checkbox Status
        if (this.selectAllCheckbox) {
            const totalRows = this.table.querySelectorAll(this.options.rowSelector).length;
            this.selectAllCheckbox.checked = count > 0 && count === totalRows;
            this.selectAllCheckbox.indeterminate = count > 0 && count < totalRows;
        }

        // Toolbar anzeigen/verstecken
        if (this.toolbar) {
            if (count > 0) {
                this.toolbar.classList.add('visible');
                this.toolbar.querySelector('.bulk-toolbar-info').textContent =
                    `${count} ausgewaehlt`;
            } else {
                this.toolbar.classList.remove('visible');
            }
        }
    }

    /**
     * Selection-Change Callback
     */
    notifySelectionChange() {
        if (typeof this.options.onSelectionChange === 'function') {
            this.options.onSelectionChange(Array.from(this.selectedIds));
        }
    }

    /**
     * Toolbar anzeigen
     */
    showToolbar(actions = []) {
        if (this.toolbar) {
            this.toolbar.remove();
        }

        this.toolbar = document.createElement('div');
        this.toolbar.id = this.options.toolbarId;

        let actionsHtml = actions.map((action, i) => {
            const btnClass = action.primary ? 'primary' :
                            action.danger ? 'danger' : 'secondary';
            return `<button class="bulk-toolbar-btn ${btnClass}" data-action="${i}">
                ${action.icon || ''} ${action.label}
            </button>`;
        }).join('');

        this.toolbar.innerHTML = `
            <span class="bulk-toolbar-info">0 ausgewaehlt</span>
            <div class="bulk-toolbar-actions">${actionsHtml}</div>
            <button class="bulk-toolbar-close" title="Auswahl aufheben">&times;</button>
        `;

        // Action-Handler
        this.toolbar.querySelectorAll('[data-action]').forEach(btn => {
            btn.addEventListener('click', () => {
                const index = parseInt(btn.dataset.action);
                if (actions[index] && actions[index].action) {
                    actions[index].action(Array.from(this.selectedIds));
                }
            });
        });

        // Close-Handler
        this.toolbar.querySelector('.bulk-toolbar-close').addEventListener('click', () => {
            this.clearSelection();
        });

        document.body.appendChild(this.toolbar);
        this.updateUI();
    }

    /**
     * Auswahl leeren
     */
    clearSelection() {
        const checkboxes = this.table.querySelectorAll('.' + this.options.checkboxClass);
        checkboxes.forEach(checkbox => {
            checkbox.checked = false;
        });

        const rows = this.table.querySelectorAll('.' + this.options.selectedClass);
        rows.forEach(row => {
            row.classList.remove(this.options.selectedClass);
        });

        if (this.selectAllCheckbox) {
            this.selectAllCheckbox.checked = false;
            this.selectAllCheckbox.indeterminate = false;
        }

        this.selectedIds.clear();
        this.updateUI();
        this.notifySelectionChange();
    }

    /**
     * Aktion auf ausgewaehlte IDs ausfuehren
     */
    async execute(actionFn, options = {}) {
        const ids = Array.from(this.selectedIds);

        if (ids.length === 0) {
            if (window.Toast) {
                Toast.warning('Bitte erst Eintraege auswaehlen');
            }
            return;
        }

        // Bestaetigung
        if (options.confirm) {
            const message = typeof options.confirm === 'string' ?
                options.confirm : `${ids.length} Eintraege verarbeiten?`;

            if (window.Toast && Toast.confirm) {
                const confirmed = await Toast.confirm(message);
                if (!confirmed) return;
            } else if (!confirm(message)) {
                return;
            }
        }

        // Loading-Status
        if (this.toolbar) {
            this.toolbar.querySelectorAll('.bulk-toolbar-btn').forEach(btn => {
                btn.disabled = true;
            });
        }

        try {
            const result = await actionFn(ids);

            if (options.clearAfter !== false) {
                this.clearSelection();
            }

            if (window.Toast) {
                Toast.success(`${ids.length} Eintraege verarbeitet`);
            }

            return result;

        } catch (error) {
            console.error('[BulkOps] Fehler:', error);
            if (window.Toast) {
                Toast.error('Fehler: ' + error.message);
            }
            throw error;

        } finally {
            if (this.toolbar) {
                this.toolbar.querySelectorAll('.bulk-toolbar-btn').forEach(btn => {
                    btn.disabled = false;
                });
            }
        }
    }

    /**
     * Ausgewaehlte IDs abrufen
     */
    getSelectedIds() {
        return Array.from(this.selectedIds);
    }

    /**
     * Anzahl ausgewaehlter Eintraege
     */
    getSelectionCount() {
        return this.selectedIds.size;
    }

    /**
     * Programmatisch auswaehlen
     */
    selectIds(ids) {
        ids.forEach(id => {
            const row = this.table.querySelector(
                `[${this.options.idField}="${id}"], [data-id="${id}"]`
            );
            if (row) {
                const checkbox = row.querySelector('.' + this.options.checkboxClass);
                if (checkbox && !checkbox.checked) {
                    checkbox.checked = true;
                    this.handleCheckboxChange(checkbox);
                }
            }
        });
    }

    /**
     * Cleanup
     */
    destroy() {
        if (this.toolbar) {
            this.toolbar.remove();
        }
        // Checkboxen entfernen
        this.table.querySelectorAll('.bulk-checkbox-cell').forEach(cell => {
            cell.remove();
        });
    }
}

// Global verfuegbar
window.BulkOperations = BulkOperations;
