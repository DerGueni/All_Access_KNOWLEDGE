/**
 * Shell-Detector: Erkennt ob Formular im Shell-iframe laeuft
 * und versteckt die eingebettete Sidebar
 *
 * Einbinden: <script src="js/shell-detector.js"></script>
 * Muss VOR dem </body> Tag eingebunden werden
 */
(function() {
    'use strict';

    // Pruefen ob im Shell-Modus (Parameter shell=1 oder im iframe)
    const urlParams = new URLSearchParams(window.location.search);
    const isShellMode = urlParams.get('shell') === '1' || window.parent !== window;

    if (isShellMode) {
        // Sidebar verstecken
        const sidebar = document.querySelector('.left-menu');
        if (sidebar) {
            sidebar.style.display = 'none';
        }

        // Main-Container anpassen (volle Breite)
        const mainContainer = document.querySelector('.main-container');
        if (mainContainer) {
            mainContainer.style.marginLeft = '0';
        }

        // Body-Class hinzufuegen fuer zusaetzliches CSS
        document.body.classList.add('shell-mode');

        console.log('[ShellDetector] Shell-Modus aktiv - Sidebar versteckt');
    }

    // Navigation via postMessage an Shell weiterleiten
    // Speichere auch als _shellNavigateToForm damit lokale Funktionen diese aufrufen koennen
    var shellNavigate = function(formName, recordId) {
        if (isShellMode && window.parent !== window) {
            window.parent.postMessage({
                type: 'NAVIGATE',
                formName: formName,
                id: recordId
            }, '*');
        } else {
            // Direkter Aufruf (nicht im Shell)
            var url = formName + '.html';
            if (recordId) {
                url += '?id=' + recordId;
            }
            window.location.href = url;
        }
    };

    window.navigateToForm = shellNavigate;
    window._shellNavigateToForm = shellNavigate; // Backup-Referenz fuer lokale Funktionen

    // Close-Handler
    window.closeToShell = function() {
        if (isShellMode && window.parent !== window) {
            window.parent.postMessage({ type: 'CLOSE' }, '*');
        } else {
            window.close();
        }
    };

    // Status an Shell senden
    window.updateShellStatus = function(message) {
        if (isShellMode && window.parent !== window) {
            window.parent.postMessage({ type: 'STATUS', message: message }, '*');
        }
    };

    // Refresh an Shell senden
    window.requestShellRefresh = function() {
        if (isShellMode && window.parent !== window) {
            window.parent.postMessage({ type: 'REFRESH' }, '*');
        } else {
            window.location.reload();
        }
    };

    // Globale Variable fuer Abfragen
    window.isInShellMode = isShellMode;

    // CSS fuer Shell-Modus injizieren
    if (isShellMode) {
        const style = document.createElement('style');
        style.textContent = `
            /* Shell-Modus: Sidebar versteckt */
            body.shell-mode .left-menu {
                display: none !important;
            }
            body.shell-mode .main-container {
                margin-left: 0 !important;
            }
            body.shell-mode .content-area {
                width: 100% !important;
            }
        `;
        document.head.appendChild(style);
    }
})();
