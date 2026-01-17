/**
 * frm_Menuefuehrung.logic.js
 * Hauptmenü (keine LinkMaster/LinkChild)
 */

const state = { isEmbedded: false };

function init() {
    state.isEmbedded = window.parent !== window;

    // Button-Listener
    document.querySelectorAll('.menu-btn').forEach(btn => {
        btn.addEventListener('click', () => handleMenuClick(btn.id));
    });

    if (state.isEmbedded) {
        window.parent.postMessage({ type: 'subform_ready', name: 'frm_Menuefuehrung' }, '*');
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
            window.open(target, '_blank');
        }
    }
}

window.MenueFuehrung = {
    setActive(btnId) {
        document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
        document.getElementById(btnId)?.classList.add('active');
    }
};

document.addEventListener('DOMContentLoaded', init);
