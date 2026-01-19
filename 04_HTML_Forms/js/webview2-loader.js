/**
 * =============================================================================
 * WebView2 Auto-Loader
 * =============================================================================
 * Lädt automatisch die WebView2-Bridge und formular-spezifische Integration
 * 
 * Einbinden am Ende jedes HTML-Formulars:
 * <script src="../js/webview2-loader.js"></script>
 * 
 * Erstellt: 28.12.2025 für CONSEC Security
 * =============================================================================
 */

(function() {
    'use strict';

    const CONFIG = {
        DEBUG: true,
        BRIDGE_PATH: '../js/webview2-bridge.js',
        INTEGRATION_PATH: 'logic/',
        INTEGRATION_SUFFIX: '.webview2.js'
    };

    function log(...args) {
        if (CONFIG.DEBUG) {
            console.log('[WebView2-Loader]', ...args);
        }
    }

    // =========================================================================
    // FORMULARNAME ERMITTELN
    // =========================================================================
    function getFormName() {
        // Aus URL extrahieren
        const path = window.location.pathname;
        const filename = path.split('/').pop();
        
        if (filename && filename.endsWith('.html')) {
            return filename.replace('.html', '');
        }
        
        // Fallback: aus Title
        const title = document.title;
        if (title) {
            return title.toLowerCase().replace(/\s+/g, '_');
        }
        
        return null;
    }

    // =========================================================================
    // SCRIPT DYNAMISCH LADEN
    // =========================================================================
    function loadScript(src, callback) {
        const script = document.createElement('script');
        script.src = src;
        script.async = false;
        
        script.onload = () => {
            log('Script geladen:', src);
            if (callback) callback(null);
        };
        
        script.onerror = (err) => {
            log('Script nicht gefunden (optional):', src);
            if (callback) callback(err);
        };
        
        document.body.appendChild(script);
    }

    // =========================================================================
    // INITIALISIERUNG
    // =========================================================================
    function init() {
        log('Starte Auto-Loader...');
        
        const formName = getFormName();
        log('Formular:', formName);

        // 1. Bridge laden
        loadScript(CONFIG.BRIDGE_PATH, (err) => {
            if (err) {
                log('Bridge nicht gefunden, verwende eingebettete Version falls vorhanden');
            }

            // 2. Formular-spezifische Integration laden (falls vorhanden)
            if (formName) {
                const integrationPath = CONFIG.INTEGRATION_PATH + formName + CONFIG.INTEGRATION_SUFFIX;
                loadScript(integrationPath, () => {
                    log('Integration geladen oder nicht vorhanden');
                });
            }
        });
    }

    // =========================================================================
    // AUTO-START
    // =========================================================================
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
