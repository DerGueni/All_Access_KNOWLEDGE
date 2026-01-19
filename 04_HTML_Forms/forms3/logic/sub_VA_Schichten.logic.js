/**
 * sub_VA_Schichten.logic.js
 * Schichten-Subformular mit Stundenberechnung
 *
 * VBA-Referenz: Form_sub_VA_Start.bas
 * - VA_Start_AfterUpdate: Aktualisiert MA_Start in Zuordnungen, ruft calc_ZUO_Stunden_all
 * - VA_Ende_AfterUpdate: Aktualisiert MA_Ende in Zuordnungen, ruft calc_ZUO_Stunden_all
 * - Form_BeforeUpdate: Validiert Eingaben, berechnet MVA_Start/MVA_Ende
 *
 * Tabelle: tbl_VA_Start
 * Felder: ID, VA_ID, VADatum_ID, VA_Start, VA_Ende, MA_Anzahl, MA_Anzahl_Ist, Bemerkung
 *
 * @version 2.0.0
 * @date 2026-01-17
 */
'use strict';

// State
const SchichtenState = {
    VA_ID: null,
    VADatum_ID: null,
    currentDate: null,
    selectedSchicht: null,
    schichtenData: [],
    isEmbedded: false
};

/**
 * Initialisierung
 */
function initSchichten() {
    console.log('[sub_VA_Schichten] init()');

    SchichtenState.isEmbedded = window.parent !== window;

    // Message Handler
    window.addEventListener('message', handleSchichtenMessage);

    // Ready-Signal an Parent senden
    if (SchichtenState.isEmbedded) {
        sendReady();
    }

    console.log('[sub_VA_Schichten] Initialisiert, embedded:', SchichtenState.isEmbedded);
}

/**
 * Ready-Signal mehrfach senden (Robustheit)
 */
function sendReady() {
    const sendMsg = () => {
        window.parent.postMessage({ type: 'subform_ready', name: 'sub_VA_Schichten' }, '*');
    };
    sendMsg();
    setTimeout(sendMsg, 100);
    setTimeout(sendMsg, 500);
}

/**
 * Message-Handler für Parent-Kommunikation
 */
function handleSchichtenMessage(event) {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'LOAD_DATA':
            SchichtenState.VA_ID = data.va_id || data.id;
            SchichtenState.currentDate = data.datum || data.date;
            SchichtenState.VADatum_ID = data.vadatum_id || null;
            loadSchichtenData();
            break;

        case 'DAY_SELECTED':
            SchichtenState.currentDate = data.date;
            SchichtenState.VADatum_ID = data.vadatum_id || null;
            loadSchichtenData();
            break;

        case 'REQUERY':
            loadSchichtenData();
            break;
    }
}

/**
 * Daten laden via REST-API
 */
async function loadSchichtenData() {
    if (!SchichtenState.VA_ID) return;

    try {
        let url = `http://localhost:5000/api/schichten/${SchichtenState.VA_ID}`;
        if (SchichtenState.currentDate) url += `?datum=${SchichtenState.currentDate}`;

        const response = await fetch(url);
        if (!response.ok) throw new Error('API Fehler');

        const data = await response.json();
        SchichtenState.schichtenData = data.schichten || data || [];
        renderSchichten(SchichtenState.schichtenData);
    } catch (error) {
        console.error('[sub_VA_Schichten] Fehler:', error);
        renderSchichtenError(error.message);
    }
}

/**
 * Schichten rendern
 */
function renderSchichten(schichten) {
    const container = document.getElementById('schichtenList');
    if (!container) return;

    if (schichten.length === 0) {
        container.innerHTML = '<div class="empty-state">Keine Schichten</div>';
        return;
    }

    container.innerHTML = schichten.map((s, idx) => {
        const isComplete = (s.MA_Anzahl_Ist || 0) >= (s.MA_Anzahl || 0);
        const statusClass = isComplete ? 'complete' : 'incomplete';
        const schichtId = s.VAStart_ID || s.ID;
        const duration = calc_ZUO_Stunden(s.VA_Start, s.VA_Ende);

        return `
            <div class="schicht-item" data-id="${schichtId}" data-index="${idx}" onclick="selectSchichtItem(this)">
                <div class="schicht-header">
                    <span class="schicht-zeit" ondblclick="editSchichtTime(event, ${idx})">
                        <span class="time-display">${formatSchichtTime(s.VA_Start)} - ${formatSchichtTime(s.VA_Ende)}</span>
                    </span>
                    <span class="schicht-anzahl ${statusClass}">
                        ${s.MA_Anzahl_Ist || 0}/${s.MA_Anzahl || 0} MA
                    </span>
                </div>
                <div class="schicht-details">
                    <span class="schicht-stunden" data-schicht-id="${schichtId}">${duration} Std</span>
                    ${s.Bemerkung ? ' | <em>' + s.Bemerkung + '</em>' : ''}
                </div>
            </div>
        `;
    }).join('');

    // Erste Schicht automatisch selektieren
    const firstSchicht = container.querySelector('.schicht-item');
    if (firstSchicht) selectSchichtItem(firstSchicht);
}

/**
 * Fehler anzeigen
 */
function renderSchichtenError(message) {
    const container = document.getElementById('schichtenList');
    if (container) {
        container.innerHTML = `<div class="empty-state" style="color:#800000;">Fehler: ${message}</div>`;
    }
}

/**
 * calc_ZUO_Stunden - Stundenberechnung
 * JavaScript-Äquivalent zur VBA-Funktion
 *
 * Berechnet Stunden zwischen Start- und Endzeit
 * Berücksichtigt Mitternacht-Überschreitung (Nachtschichten)
 *
 * @param {string} startTime - Startzeit (HH:MM oder ISO-Format)
 * @param {string} endTime - Endzeit (HH:MM oder ISO-Format)
 * @returns {string} Stunden als formatierte Zahl (z.B. "8.5")
 */
function calc_ZUO_Stunden(startTime, endTime) {
    if (!startTime || !endTime) return '0.0';

    try {
        const start = parseTimeToMinutes(startTime);
        const end = parseTimeToMinutes(endTime);

        let diffMinutes = end - start;

        // Nachtschicht: Ende ist am nächsten Tag
        if (diffMinutes < 0) {
            diffMinutes += 24 * 60; // +24 Stunden
        }

        const hours = diffMinutes / 60;
        return hours.toFixed(1);
    } catch (e) {
        console.error('[calc_ZUO_Stunden] Fehler:', e);
        return '0.0';
    }
}

/**
 * Zeit zu Minuten konvertieren
 * Unterstützt verschiedene Formate: HH:MM, ISO-String, Dezimalwert
 *
 * @param {string|number} value - Zeitwert
 * @returns {number} Minuten seit Mitternacht
 */
function parseTimeToMinutes(value) {
    if (!value) return 0;

    // ISO-String (z.B. "1899-12-30T15:00:00" oder "2026-01-17T15:00:00")
    if (typeof value === 'string' && value.includes('T')) {
        const date = new Date(value);
        if (!isNaN(date)) {
            return date.getHours() * 60 + date.getMinutes();
        }
    }

    // HH:MM oder HH:MM:SS Format
    if (typeof value === 'string' && /^\d{1,2}:\d{2}(:\d{2})?$/.test(value)) {
        const parts = value.split(':').map(Number);
        return parts[0] * 60 + parts[1];
    }

    // Dezimalwert (Access-typisch: 0.5 = 12:00)
    if (typeof value === 'number' && value < 1) {
        return Math.round(value * 24 * 60);
    }

    // Ganzzahl als Stunden
    if (typeof value === 'number') {
        return value * 60;
    }

    return 0;
}

/**
 * Zeit formatieren für Anzeige
 *
 * @param {string|number} value - Zeitwert
 * @returns {string} Formatierte Zeit (HH:MM)
 */
function formatSchichtTime(value) {
    if (!value) return '';

    // ISO-String
    if (typeof value === 'string' && value.includes('T')) {
        const date = new Date(value);
        if (!isNaN(date)) {
            return date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
        }
    }

    // Bereits formatiert (HH:MM)
    if (typeof value === 'string' && /^\d{1,2}:\d{2}$/.test(value)) {
        return value;
    }

    // HH:MM:SS Format
    if (typeof value === 'string' && /^\d{1,2}:\d{2}:\d{2}$/.test(value)) {
        return value.substring(0, 5);
    }

    // Dezimalwert
    if (typeof value === 'number' && value < 1) {
        const totalMinutes = Math.round(value * 24 * 60);
        const hours = Math.floor(totalMinutes / 60);
        const mins = totalMinutes % 60;
        return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
    }

    return String(value);
}

/**
 * calc_ZUO_Stunden_all - Alle Stunden für eine Schicht neu berechnen
 * JavaScript-Äquivalent zur VBA-Funktion in Form_sub_MA_VA_Zuordnung
 *
 * Wird aufgerufen wenn Schicht-Zeiten geändert werden
 * Aktualisiert alle MA-Zuordnungen der Schicht
 *
 * VBA-Referenz: Form_sub_MA_VA_Zuordnung.calc_ZUO_Stunden_all
 *
 * @param {number} VAStart_ID - ID der Schicht
 */
async function calc_ZUO_Stunden_all(VAStart_ID) {
    if (!VAStart_ID) return;

    console.log('[sub_VA_Schichten] calc_ZUO_Stunden_all für Schicht:', VAStart_ID);

    try {
        // API-Aufruf um Stunden für alle Zuordnungen der Schicht zu berechnen
        const response = await fetch(`http://localhost:5000/api/schichten/${VAStart_ID}/recalc_hours`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                va_id: SchichtenState.VA_ID,
                vadatum_id: SchichtenState.VADatum_ID
            })
        });

        if (!response.ok) {
            console.warn('[sub_VA_Schichten] Stunden-Neuberechnung nicht verfügbar (Endpoint fehlt)');
        }

        // Parent informieren dass Zuordnungen aktualisiert werden müssen
        notifySchichtenRecalc();

    } catch (e) {
        console.error('[sub_VA_Schichten] calc_ZUO_Stunden_all Fehler:', e);
        notifySchichtenRecalc();
    }
}

/**
 * Zeit inline bearbeiten (Doppelklick)
 * VBA-Äquivalent: VA_Start/VA_Ende Felder editieren
 */
function editSchichtTime(event, schichtIndex) {
    event.stopPropagation();

    const schicht = SchichtenState.schichtenData[schichtIndex];
    if (!schicht) return;

    const schichtId = schicht.VAStart_ID || schicht.ID;
    const startFormatted = formatSchichtTime(schicht.VA_Start);
    const endFormatted = formatSchichtTime(schicht.VA_Ende);

    // Dialog für Zeit-Bearbeitung
    const newStart = prompt('Startzeit (HH:MM):', startFormatted);
    if (newStart === null) return;

    const newEnd = prompt('Endzeit (HH:MM):', endFormatted);
    if (newEnd === null) return;

    // Validierung (VBA: Form_BeforeUpdate)
    if (!validateSchichtTime(newStart) || !validateSchichtTime(newEnd)) {
        alert('Ungültiges Zeitformat. Bitte HH:MM eingeben.');
        return;
    }

    // API-Update
    updateSchichtTime(schichtId, newStart, newEnd, schichtIndex);
}

/**
 * Zeit-Validierung (VBA: Form_BeforeUpdate)
 *
 * @param {string} timeStr - Zeit-String
 * @returns {boolean} true wenn gültig
 */
function validateSchichtTime(timeStr) {
    if (!timeStr) return false;
    return /^([01]?\d|2[0-3]):([0-5]\d)$/.test(timeStr.trim());
}

/**
 * Schicht-Zeiten aktualisieren
 * VBA-Äquivalent: VA_Start_AfterUpdate / VA_Ende_AfterUpdate
 */
async function updateSchichtTime(schichtId, newStart, newEnd, schichtIndex) {
    console.log('[sub_VA_Schichten] Update Schicht:', schichtId, newStart, '-', newEnd);

    try {
        // 1. Schicht aktualisieren (tbl_VA_Start)
        const response = await fetch(`http://localhost:5000/api/schichten/${schichtId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                VA_Start: newStart,
                VA_Ende: newEnd
            })
        });

        if (response.ok) {
            // 2. Lokale Daten aktualisieren
            if (SchichtenState.schichtenData[schichtIndex]) {
                SchichtenState.schichtenData[schichtIndex].VA_Start = newStart;
                SchichtenState.schichtenData[schichtIndex].VA_Ende = newEnd;
            }

            // 3. UI aktualisieren
            updateSchichtDisplay(schichtId, newStart, newEnd);

            // 4. Stunden für alle MA-Zuordnungen neu berechnen
            await calc_ZUO_Stunden_all(schichtId);

            // 5. Parent informieren
            notifySchichtenChanged();

            console.log('[sub_VA_Schichten] Schicht erfolgreich aktualisiert');
        } else {
            console.error('[sub_VA_Schichten] Update fehlgeschlagen');
            alert('Fehler beim Speichern der Schicht-Zeiten');
        }
    } catch (e) {
        console.error('[sub_VA_Schichten] Update Fehler:', e);
        alert('Netzwerkfehler beim Speichern');
    }
}

/**
 * Schicht-Anzeige im UI aktualisieren (ohne komplettes Re-Render)
 */
function updateSchichtDisplay(schichtId, newStart, newEnd) {
    const item = document.querySelector(`.schicht-item[data-id="${schichtId}"]`);
    if (!item) return;

    const timeDisplay = item.querySelector('.time-display');
    if (timeDisplay) {
        timeDisplay.textContent = `${newStart} - ${newEnd}`;
    }

    const stundenDisplay = item.querySelector('.schicht-stunden');
    if (stundenDisplay) {
        const newDuration = calc_ZUO_Stunden(newStart, newEnd);
        stundenDisplay.textContent = `${newDuration} Std`;
    }
}

/**
 * Schicht auswählen
 */
function selectSchichtItem(element) {
    document.querySelectorAll('.schicht-item').forEach(el => el.classList.remove('active'));
    element.classList.add('active');
    SchichtenState.selectedSchicht = element.dataset.id;

    // Parent informieren
    window.parent.postMessage({
        type: 'SCHICHT_SELECTED',
        schicht_id: SchichtenState.selectedSchicht,
        va_id: SchichtenState.VA_ID,
        datum: SchichtenState.currentDate,
        vadatum_id: SchichtenState.VADatum_ID
    }, '*');
}

/**
 * Neue Schicht hinzufügen
 */
function addSchichtItem() {
    window.parent.postMessage({
        type: 'ADD_SCHICHT',
        va_id: SchichtenState.VA_ID,
        datum: SchichtenState.currentDate,
        vadatum_id: SchichtenState.VADatum_ID
    }, '*');
}

/**
 * Schicht bearbeiten
 */
function editSchichtItem() {
    if (SchichtenState.selectedSchicht) {
        window.parent.postMessage({
            type: 'EDIT_SCHICHT',
            schicht_id: SchichtenState.selectedSchicht,
            va_id: SchichtenState.VA_ID,
            vadatum_id: SchichtenState.VADatum_ID
        }, '*');
    }
}

/**
 * Parent über Änderungen informieren
 */
function notifySchichtenChanged() {
    window.parent.postMessage({
        type: 'SCHICHT_CHANGED',
        va_id: SchichtenState.VA_ID,
        datum: SchichtenState.currentDate,
        vadatum_id: SchichtenState.VADatum_ID
    }, '*');
}

/**
 * Parent über Recalc informieren (Zuordnungen neu laden)
 */
function notifySchichtenRecalc() {
    window.parent.postMessage({
        type: 'ZUORDNUNG_RECALC_REQUEST',
        va_id: SchichtenState.VA_ID,
        vadatum_id: SchichtenState.VADatum_ID
    }, '*');
}

// API für externen Zugriff
window.SubVASchichten = {
    init: initSchichten,
    loadData: loadSchichtenData,
    calc_ZUO_Stunden: calc_ZUO_Stunden,
    calc_ZUO_Stunden_all: calc_ZUO_Stunden_all,
    parseTimeToMinutes: parseTimeToMinutes,
    formatTime: formatSchichtTime,
    validateTime: validateSchichtTime,
    getSelectedSchicht: () => SchichtenState.selectedSchicht,
    getSchichtenData: () => SchichtenState.schichtenData,
    getState: () => SchichtenState
};

// Auto-Init bei DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSchichten);
} else {
    initSchichten();
}
