/**
 * frm_Menuefuehrung.logic.js
 * Hauptmenü - Navigation mit API-Backend Unterstützung
 */

const API_BASE = 'http://localhost:5000/api';
const state = { isEmbedded: false, apiStatus: 'unknown' };

async function init() {
    state.isEmbedded = window.parent !== window;

    // API-Server Status prüfen
    await checkApiStatus();

    // Button-Listener
    document.querySelectorAll('.menu-btn').forEach(btn => {
        btn.addEventListener('click', () => handleMenuClick(btn.id));
    });

    if (state.isEmbedded) {
        window.parent.postMessage({ type: 'subform_ready', name: 'frm_Menuefuehrung' }, '*');
    }

    console.log('[Hauptmenü] Initialisiert - API:', state.apiStatus);
}

/**
 * API-Server Status prüfen
 */
async function checkApiStatus() {
    try {
        const response = await fetch(`${API_BASE}/mitarbeiter?limit=1`, {
            method: 'GET',
            signal: AbortSignal.timeout(2000) // 2 Sekunden Timeout
        });
        state.apiStatus = response.ok ? 'online' : 'error';
    } catch (error) {
        state.apiStatus = 'offline';
        console.warn('[Hauptmenü] API-Server nicht erreichbar:', error.message);
    }
}

function handleMenuClick(btnId) {
    // Aktiven Button markieren
    document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
    document.getElementById(btnId)?.classList.add('active');

    // An Parent senden
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'menu_click',
            name: 'frm_Menuefuehrung',
            buttonId: btnId
        }, '*');
    } else {
        // Standalone: In neuem Tab öffnen
        const formMap = {
            'btn_Mitarbeiterverwaltung': 'frm_MA_Mitarbeiterstamm.html',
            'btn_Kundenverwaltung': 'frm_KD_Kundenstamm.html',
            'btn_Dienstplanuebersicht': 'frm_N_Dienstplanuebersicht.html',
            'btn_Auftragsverwaltung': 'frm_va_Auftragstamm.html',
            'btn_Planungsuebersicht': 'frm_VA_Planungsuebersicht.html',
            'btn_Abwesenheitsuebersicht': 'frm_MA_Abwesenheit.html',
            'btn_Zeitkonten': 'frm_MA_Zeitkonten.html',
            'btn_Systeminfo': 'frm_Systeminfo.html'
        };

        const target = formMap[btnId];
        if (target) {
            // Im gleichen Fenster öffnen (statt new tab)
            window.location.href = target;
        }
    }
}

/**
 * Navigiert zu einem Formular (öffentliche API)
 */
function navigateToForm(formName) {
    const url = formName.endsWith('.html') ? formName : `${formName}.html`;
    window.location.href = url;
}

window.MenueFuehrung = {
    setActive(btnId) {
        document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
        document.getElementById(btnId)?.classList.add('active');
    },
    navigateToForm,
    checkApiStatus,
    getApiStatus() {
        return state.apiStatus;
    }
};

document.addEventListener('DOMContentLoaded', init);
