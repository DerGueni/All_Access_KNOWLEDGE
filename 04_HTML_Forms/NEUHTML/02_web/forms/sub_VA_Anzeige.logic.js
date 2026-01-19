/**
 * sub_VA_Anzeige.logic.js
 * Auftragsstatus-Übersicht (keine LinkMaster/LinkChild)
 */
import { Bridge } from '../js/webview2-bridge.js';

const state = { isEmbedded: false };

function init() {
    state.isEmbedded = window.parent !== window;

    // Button-Listener
    ['btnAnz1', 'btnAnz2', 'btnAnz3', 'btnAnz4'].forEach((id, idx) => {
        document.getElementById(id)?.addEventListener('click', () => filterByStatus(idx + 1));
    });

    if (state.isEmbedded) {
        window.addEventListener('message', handleParentMessage);
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_VA_Anzeige' }, '*');
    }

    // Initial laden
    loadStatusCounts();
    console.log('[sub_VA_Anzeige] Initialisiert, embedded:', state.isEmbedded);
}

function handleParentMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;
    if (data.type === 'requery' || data.type === 'recalc') {
        loadStatusCounts();
    }
}

async function loadStatusCounts() {
    try {
        // REST-API: /api/dashboard für Status-Zähler
        const result = await Bridge.dashboard.get();
        if (result.data) {
            // API gibt Felder zurück, die wir mappen müssen
            document.getElementById('AnzStatus1').textContent = result.data.in_planung || result.data.status1 || 0;
            document.getElementById('AnzStatus2').textContent = result.data.in_bearbeitung || result.data.status2 || 0;
            document.getElementById('AnzStatus3').textContent = result.data.einsatzliste_versendet || result.data.status3 || 0;
            document.getElementById('AnzStatus4').textContent = result.data.rechnung_gestellt || result.data.status4 || 0;
        }
    } catch (error) {
        console.error('[VA_Anzeige] Fehler:', error);
    }
}

function filterByStatus(statusId) {
    if (state.isEmbedded) {
        window.parent.postMessage({
            type: 'filter_by_status',
            name: 'sub_VA_Anzeige',
            statusId: statusId
        }, '*');
    }
}

// VBA-kompatible Funktion
window.f_UpdStatus = loadStatusCounts;

window.SubVAAnzeige = {
    requery: loadStatusCounts,
    f_UpdStatus: loadStatusCounts
};

document.addEventListener('DOMContentLoaded', init);
