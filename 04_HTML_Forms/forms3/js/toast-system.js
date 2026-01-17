/**
 * Toast Notification System
 *
 * Ersetzt alert() durch nicht-blockierende Toast-Nachrichten.
 *
 * Verwendung:
 *   Toast.show('Nachricht');
 *   Toast.success('Erfolgreich gespeichert');
 *   Toast.error('Fehler beim Speichern');
 *   Toast.warning('Achtung!');
 *   Toast.info('Information');
 *
 *   // Mit Optionen:
 *   Toast.show('Nachricht', { duration: 5000, position: 'top-right' });
 *
 *   // Confirm-Dialog (ersetzt confirm()):
 *   const result = await Toast.confirm('Wirklich loeschen?');
 *   if (result) { ... }
 */

'use strict';

const Toast = (function() {
    // Konfiguration
    const CONFIG = {
        defaultDuration: 3000,
        position: 'top-right',  // 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left' | 'top-center' | 'bottom-center'
        maxToasts: 5,
        animation: true
    };

    let container = null;
    let toastCount = 0;

    // Container erstellen
    function getContainer() {
        if (container && document.body.contains(container)) {
            return container;
        }

        container = document.createElement('div');
        container.id = 'toast-container';
        container.className = `toast-container toast-${CONFIG.position}`;

        // Styles injizieren wenn nicht vorhanden
        if (!document.getElementById('toast-styles')) {
            const styles = document.createElement('style');
            styles.id = 'toast-styles';
            styles.textContent = `
                .toast-container {
                    position: fixed;
                    z-index: 99999;
                    pointer-events: none;
                    display: flex;
                    flex-direction: column;
                    gap: 8px;
                    max-width: 350px;
                }
                .toast-top-right { top: 20px; right: 20px; }
                .toast-top-left { top: 20px; left: 20px; }
                .toast-bottom-right { bottom: 20px; right: 20px; }
                .toast-bottom-left { bottom: 20px; left: 20px; }
                .toast-top-center { top: 20px; left: 50%; transform: translateX(-50%); }
                .toast-bottom-center { bottom: 20px; left: 50%; transform: translateX(-50%); }

                .toast {
                    pointer-events: auto;
                    display: flex;
                    align-items: flex-start;
                    gap: 10px;
                    padding: 12px 16px;
                    background: #333;
                    color: white;
                    border-radius: 4px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
                    font-family: 'Segoe UI', sans-serif;
                    font-size: 13px;
                    line-height: 1.4;
                    opacity: 0;
                    transform: translateX(100%);
                    transition: all 0.3s ease;
                }
                .toast.show { opacity: 1; transform: translateX(0); }
                .toast.hide { opacity: 0; transform: translateX(100%); }

                .toast-success { background: linear-gradient(135deg, #28a745 0%, #218838 100%); }
                .toast-error { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); }
                .toast-warning { background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%); color: #333; }
                .toast-info { background: linear-gradient(135deg, #17a2b8 0%, #138496 100%); }

                .toast-icon {
                    font-size: 18px;
                    flex-shrink: 0;
                    margin-top: 1px;
                }
                .toast-content { flex: 1; }
                .toast-title { font-weight: 600; margin-bottom: 2px; }
                .toast-message { opacity: 0.95; }
                .toast-close {
                    background: none;
                    border: none;
                    color: inherit;
                    font-size: 18px;
                    cursor: pointer;
                    opacity: 0.7;
                    padding: 0;
                    line-height: 1;
                }
                .toast-close:hover { opacity: 1; }

                .toast-progress {
                    position: absolute;
                    bottom: 0;
                    left: 0;
                    height: 3px;
                    background: rgba(255,255,255,0.5);
                    border-radius: 0 0 4px 4px;
                }

                /* Confirm Dialog */
                .toast-confirm-overlay {
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: rgba(0,0,0,0.5);
                    z-index: 99998;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }
                .toast-confirm-dialog {
                    background: white;
                    padding: 20px 24px;
                    border-radius: 6px;
                    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
                    max-width: 400px;
                    font-family: 'Segoe UI', sans-serif;
                }
                .toast-confirm-message {
                    font-size: 14px;
                    color: #333;
                    margin-bottom: 20px;
                    line-height: 1.5;
                }
                .toast-confirm-buttons {
                    display: flex;
                    gap: 10px;
                    justify-content: flex-end;
                }
                .toast-confirm-btn {
                    padding: 8px 20px;
                    border: none;
                    border-radius: 4px;
                    font-size: 13px;
                    cursor: pointer;
                    font-weight: 500;
                }
                .toast-confirm-btn-cancel {
                    background: #e0e0e0;
                    color: #333;
                }
                .toast-confirm-btn-cancel:hover { background: #d0d0d0; }
                .toast-confirm-btn-ok {
                    background: #000080;
                    color: white;
                }
                .toast-confirm-btn-ok:hover { background: #0000a0; }
                .toast-confirm-btn-danger {
                    background: #dc3545;
                    color: white;
                }
                .toast-confirm-btn-danger:hover { background: #c82333; }
            `;
            document.head.appendChild(styles);
        }

        document.body.appendChild(container);
        return container;
    }

    // Icons
    const ICONS = {
        success: '\u2714',  // Checkmark
        error: '\u2716',    // X
        warning: '\u26A0',  // Warning
        info: '\u2139',     // Info
        default: '\u2022'   // Bullet
    };

    function createToast(message, options = {}) {
        const {
            type = 'default',
            duration = CONFIG.defaultDuration,
            title = null,
            closable = true,
            showProgress = true
        } = options;

        const container = getContainer();

        // Max toasts pruefen
        const existingToasts = container.querySelectorAll('.toast');
        if (existingToasts.length >= CONFIG.maxToasts) {
            existingToasts[0].remove();
        }

        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.style.position = 'relative';

        const icon = ICONS[type] || ICONS.default;

        toast.innerHTML = `
            <span class="toast-icon">${icon}</span>
            <div class="toast-content">
                ${title ? `<div class="toast-title">${title}</div>` : ''}
                <div class="toast-message">${message}</div>
            </div>
            ${closable ? '<button class="toast-close">&times;</button>' : ''}
            ${showProgress && duration > 0 ? '<div class="toast-progress"></div>' : ''}
        `;

        container.appendChild(toast);

        // Animation
        requestAnimationFrame(() => {
            toast.classList.add('show');
        });

        // Progress bar animation
        if (showProgress && duration > 0) {
            const progress = toast.querySelector('.toast-progress');
            if (progress) {
                progress.style.width = '100%';
                progress.style.transition = `width ${duration}ms linear`;
                requestAnimationFrame(() => {
                    progress.style.width = '0%';
                });
            }
        }

        // Close button
        const closeBtn = toast.querySelector('.toast-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => removeToast(toast));
        }

        // Auto-remove
        if (duration > 0) {
            setTimeout(() => removeToast(toast), duration);
        }

        toastCount++;
        return toast;
    }

    function removeToast(toast) {
        toast.classList.remove('show');
        toast.classList.add('hide');
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 300);
    }

    return {
        show: function(message, options = {}) {
            return createToast(message, options);
        },

        success: function(message, options = {}) {
            return createToast(message, { ...options, type: 'success', title: options.title || 'Erfolg' });
        },

        error: function(message, options = {}) {
            return createToast(message, { ...options, type: 'error', title: options.title || 'Fehler', duration: options.duration || 5000 });
        },

        warning: function(message, options = {}) {
            return createToast(message, { ...options, type: 'warning', title: options.title || 'Warnung' });
        },

        info: function(message, options = {}) {
            return createToast(message, { ...options, type: 'info', title: options.title || 'Info' });
        },

        // Ersetzt confirm()
        confirm: function(message, options = {}) {
            return new Promise((resolve) => {
                const {
                    title = 'Bestaetigung',
                    okText = 'OK',
                    cancelText = 'Abbrechen',
                    danger = false
                } = options;

                const overlay = document.createElement('div');
                overlay.className = 'toast-confirm-overlay';
                overlay.innerHTML = `
                    <div class="toast-confirm-dialog">
                        <div class="toast-confirm-message">${message}</div>
                        <div class="toast-confirm-buttons">
                            <button class="toast-confirm-btn toast-confirm-btn-cancel">${cancelText}</button>
                            <button class="toast-confirm-btn ${danger ? 'toast-confirm-btn-danger' : 'toast-confirm-btn-ok'}">${okText}</button>
                        </div>
                    </div>
                `;

                const cancelBtn = overlay.querySelector('.toast-confirm-btn-cancel');
                const okBtn = overlay.querySelector('.toast-confirm-btn-ok, .toast-confirm-btn-danger');

                cancelBtn.addEventListener('click', () => {
                    overlay.remove();
                    resolve(false);
                });

                okBtn.addEventListener('click', () => {
                    overlay.remove();
                    resolve(true);
                });

                // ESC zum Abbrechen
                const escHandler = (e) => {
                    if (e.key === 'Escape') {
                        overlay.remove();
                        document.removeEventListener('keydown', escHandler);
                        resolve(false);
                    }
                };
                document.addEventListener('keydown', escHandler);

                document.body.appendChild(overlay);
                okBtn.focus();
            });
        },

        // Alle Toasts entfernen
        clear: function() {
            const container = document.getElementById('toast-container');
            if (container) {
                container.innerHTML = '';
            }
        },

        // Konfiguration aendern
        setConfig: function(key, value) {
            if (CONFIG.hasOwnProperty(key)) {
                CONFIG[key] = value;
            }
        }
    };
})();

// Global verfuegbar machen
window.Toast = Toast;

// Optional: alert() ueberschreiben (auskommentiert fuer Sicherheit)
// window._originalAlert = window.alert;
// window.alert = function(message) { Toast.info(message); };
