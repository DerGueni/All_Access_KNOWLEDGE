/**
 * Responsive Sidebar JavaScript
 * Hamburger-Menu Steuerung fuer Mobile
 */

'use strict';

const ResponsiveSidebar = (function() {
    let hamburgerBtn = null;
    let sidebar = null;
    let overlay = null;
    let isOpen = false;

    /**
     * Hamburger-Button erstellen
     */
    function createHamburger() {
        if (document.querySelector('.hamburger-btn')) return;

        hamburgerBtn = document.createElement('button');
        hamburgerBtn.className = 'hamburger-btn';
        hamburgerBtn.setAttribute('aria-label', 'Menu oeffnen');
        hamburgerBtn.innerHTML = '<span></span><span></span><span></span>';
        document.body.appendChild(hamburgerBtn);
    }

    /**
     * Overlay erstellen
     */
    function createOverlay() {
        if (document.querySelector('.sidebar-overlay')) return;

        overlay = document.createElement('div');
        overlay.className = 'sidebar-overlay';
        document.body.appendChild(overlay);
    }

    /**
     * Sidebar oeffnen
     */
    function open() {
        if (!sidebar) return;
        isOpen = true;
        sidebar.classList.add('open');
        hamburgerBtn?.classList.add('active');
        overlay?.classList.add('visible');
        document.body.style.overflow = 'hidden';
    }

    /**
     * Sidebar schliessen
     */
    function close() {
        if (!sidebar) return;
        isOpen = false;
        sidebar.classList.remove('open');
        hamburgerBtn?.classList.remove('active');
        overlay?.classList.remove('visible');
        document.body.style.overflow = '';
    }

    /**
     * Toggle
     */
    function toggle() {
        if (isOpen) {
            close();
        } else {
            open();
        }
    }

    /**
     * Event Listener registrieren
     */
    function bindEvents() {
        // Hamburger Click
        hamburgerBtn?.addEventListener('click', toggle);

        // Overlay Click schliesst Sidebar
        overlay?.addEventListener('click', close);

        // ESC schliesst Sidebar
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && isOpen) {
                close();
            }
        });

        // Menu-Item Click schliesst Sidebar auf Mobile
        sidebar?.addEventListener('click', (e) => {
            if (e.target.closest('.menu-item') && window.innerWidth < 768) {
                // Kurze Verzoegerung fuer visuelle Feedback
                setTimeout(close, 150);
            }
        });

        // Resize Handler
        let resizeTimeout;
        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                // Sidebar automatisch schliessen bei Desktop
                if (window.innerWidth > 768 && isOpen) {
                    close();
                }
            }, 100);
        });

        // Swipe Gesten
        let touchStartX = 0;
        let touchEndX = 0;

        document.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
        }, { passive: true });

        document.addEventListener('touchend', (e) => {
            touchEndX = e.changedTouches[0].screenX;
            handleSwipe();
        }, { passive: true });

        function handleSwipe() {
            const swipeThreshold = 80;
            const diff = touchEndX - touchStartX;

            // Swipe von links nach rechts (oeffnen)
            if (diff > swipeThreshold && touchStartX < 50 && !isOpen) {
                open();
            }

            // Swipe von rechts nach links (schliessen)
            if (diff < -swipeThreshold && isOpen) {
                close();
            }
        }
    }

    /**
     * Initialisierung
     */
    function init() {
        sidebar = document.querySelector('.sidebar');
        if (!sidebar) {
            console.log('[ResponsiveSidebar] Keine Sidebar gefunden');
            return;
        }

        createHamburger();
        createOverlay();
        bindEvents();

        console.log('[ResponsiveSidebar] Initialisiert');
    }

    // Auto-Init
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    return {
        open: open,
        close: close,
        toggle: toggle,
        get isOpen() { return isOpen; }
    };
})();

// Global verfuegbar
window.ResponsiveSidebar = ResponsiveSidebar;
