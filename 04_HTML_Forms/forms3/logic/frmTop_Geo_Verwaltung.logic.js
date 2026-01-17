/**
 * frmTop_Geo_Verwaltung.logic.js
 * Logik für Geo-Verwaltung (Geofencing/Standortverwaltung)
 * Verwaltung von geografischen Daten, Objektstandorten und Geofencing-Zonen
 */
import { Bridge } from '../api/bridgeClient.js';

let elements = {};
let currentObjektId = null;
let mapInstance = null;

async function init() {
    console.log('[Geo_Verwaltung] Initialisierung...');

    elements = {
        objektListe: document.getElementById('objektListe'),
        mapContainer: document.getElementById('mapContainer'),
        searchInput: document.getElementById('searchInput'),

        btnNeu: document.getElementById('btnNeu'),
        btnSpeichern: document.getElementById('btnSpeichern'),
        btnLoeschen: document.getElementById('btnLoeschen'),
        btnKarteAktualisieren: document.getElementById('btnKarteAktualisieren'),

        // Formularfelder
        objektName: document.getElementById('objektName'),
        strasse: document.getElementById('strasse'),
        plz: document.getElementById('plz'),
        ort: document.getElementById('ort'),
        latitude: document.getElementById('latitude'),
        longitude: document.getElementById('longitude'),
        radius: document.getElementById('radius'),

        geofenceAktiv: document.getElementById('geofenceAktiv'),
        checkinErlaubt: document.getElementById('checkinErlaubt'),

        // Statistik
        anzahlObjekte: document.getElementById('anzahlObjekte'),
        anzahlGeofences: document.getElementById('anzahlGeofences')
    };

    await loadInitialData();
    bindEvents();
    initMap();
}

async function loadInitialData() {
    try {
        // Objekte laden
        const objekte = await Bridge.objekte.list();
        renderObjektListe(objekte);
        updateStatistik(objekte);

    } catch (error) {
        console.error('[Geo_Verwaltung] Fehler beim Laden:', error);
        showError('Daten konnten nicht geladen werden');
    }
}

function renderObjektListe(objekte) {
    if (!elements.objektListe) return;

    elements.objektListe.innerHTML = objekte.map(obj => `
        <div class="objekt-item ${obj.Geofence_Aktiv ? 'has-geofence' : ''}" data-id="${obj.obj_Id}">
            <div class="objekt-name">${obj.obj_Bezeichnung || 'N/A'}</div>
            <div class="objekt-adresse">${formatAdresse(obj)}</div>
            ${obj.Latitude && obj.Longitude ?
                '<span class="geo-marker">📍</span>' :
                '<span class="geo-marker inactive">○</span>'}
        </div>
    `).join('');
}

function updateStatistik(objekte) {
    if (elements.anzahlObjekte) {
        elements.anzahlObjekte.textContent = objekte.length;
    }

    if (elements.anzahlGeofences) {
        const mitGeofence = objekte.filter(o => o.Geofence_Aktiv).length;
        elements.anzahlGeofences.textContent = mitGeofence;
    }
}

function formatAdresse(obj) {
    const parts = [];
    if (obj.Strasse) parts.push(obj.Strasse);
    if (obj.PLZ || obj.Ort) parts.push(`${obj.PLZ || ''} ${obj.Ort || ''}`.trim());
    return parts.join(', ') || 'Keine Adresse';
}

function initMap() {
    // Platzhalter für Karten-Initialisierung
    // TODO: Google Maps, Leaflet oder andere Karten-Bibliothek integrieren
    console.log('[Geo_Verwaltung] Karten-Initialisierung (Platzhalter)');

    if (elements.mapContainer) {
        elements.mapContainer.innerHTML = `
            <div style="padding: 20px; text-align: center; background: #f0f0f0;">
                <p>Karten-Ansicht</p>
                <small>Geofencing-Zonen werden hier angezeigt</small>
            </div>
        `;
    }
}

function bindEvents() {
    // Objekt aus Liste auswählen
    if (elements.objektListe) {
        elements.objektListe.addEventListener('click', (e) => {
            const item = e.target.closest('.objekt-item');
            if (item) {
                const id = parseInt(item.dataset.id);
                loadObjekt(id);
            }
        });
    }

    // Neues Objekt
    if (elements.btnNeu) {
        elements.btnNeu.addEventListener('click', () => {
            clearForm();
            currentObjektId = null;
        });
    }

    // Speichern
    if (elements.btnSpeichern) {
        elements.btnSpeichern.addEventListener('click', saveObjekt);
    }

    // Löschen
    if (elements.btnLoeschen) {
        elements.btnLoeschen.addEventListener('click', deleteObjekt);
    }

    // Karte aktualisieren
    if (elements.btnKarteAktualisieren) {
        elements.btnKarteAktualisieren.addEventListener('click', updateMap);
    }

    // Adresse zu Koordinaten
    if (elements.strasse || elements.plz || elements.ort) {
        const adressFields = [elements.strasse, elements.plz, elements.ort];
        adressFields.forEach(field => {
            if (field) {
                field.addEventListener('blur', geocodeAdresse);
            }
        });
    }

    // Koordinaten zu Adresse
    if (elements.latitude || elements.longitude) {
        [elements.latitude, elements.longitude].forEach(field => {
            if (field) {
                field.addEventListener('blur', reverseGeocode);
            }
        });
    }

    // Suche
    if (elements.searchInput) {
        elements.searchInput.addEventListener('input', handleSearch);
    }
}

async function loadObjekt(id) {
    try {
        const objekt = await Bridge.objekte.get(id);
        currentObjektId = id;

        if (elements.objektName) elements.objektName.value = objekt.obj_Bezeichnung || '';
        if (elements.strasse) elements.strasse.value = objekt.Strasse || '';
        if (elements.plz) elements.plz.value = objekt.PLZ || '';
        if (elements.ort) elements.ort.value = objekt.Ort || '';
        if (elements.latitude) elements.latitude.value = objekt.Latitude || '';
        if (elements.longitude) elements.longitude.value = objekt.Longitude || '';
        if (elements.radius) elements.radius.value = objekt.Geofence_Radius || 100;
        if (elements.geofenceAktiv) elements.geofenceAktiv.checked = objekt.Geofence_Aktiv || false;
        if (elements.checkinErlaubt) elements.checkinErlaubt.checked = objekt.Checkin_Erlaubt || false;

        updateMapMarker(objekt);

    } catch (error) {
        console.error('[Geo_Verwaltung] Fehler beim Laden des Objekts:', error);
        showError('Objekt konnte nicht geladen werden');
    }
}

async function saveObjekt() {
    try {
        const data = {
            obj_Bezeichnung: elements.objektName?.value,
            Strasse: elements.strasse?.value,
            PLZ: elements.plz?.value,
            Ort: elements.ort?.value,
            Latitude: elements.latitude?.value ? parseFloat(elements.latitude.value) : null,
            Longitude: elements.longitude?.value ? parseFloat(elements.longitude.value) : null,
            Geofence_Radius: elements.radius?.value ? parseInt(elements.radius.value) : 100,
            Geofence_Aktiv: elements.geofenceAktiv?.checked || false,
            Checkin_Erlaubt: elements.checkinErlaubt?.checked || false
        };

        if (currentObjektId) {
            await Bridge.objekte.update(currentObjektId, data);
            showSuccess('Objekt aktualisiert');
        } else {
            const result = await Bridge.objekte.create(data);
            currentObjektId = result.obj_Id;
            showSuccess('Objekt erstellt');
        }

        await loadInitialData();

    } catch (error) {
        console.error('[Geo_Verwaltung] Fehler beim Speichern:', error);
        showError('Speichern fehlgeschlagen');
    }
}

async function deleteObjekt() {
    if (!currentObjektId) return;

    if (!confirm('Objekt wirklich löschen?')) return;

    try {
        await Bridge.objekte.delete(currentObjektId);
        showSuccess('Objekt gelöscht');
        clearForm();
        currentObjektId = null;
        await loadInitialData();

    } catch (error) {
        console.error('[Geo_Verwaltung] Fehler beim Löschen:', error);
        showError('Löschen fehlgeschlagen');
    }
}

async function geocodeAdresse() {
    // Adresse zu Koordinaten umwandeln
    const adresse = `${elements.strasse?.value || ''} ${elements.plz?.value || ''} ${elements.ort?.value || ''}`.trim();

    if (!adresse) return;

    try {
        // TODO: Geocoding-API aufrufen (Google, OpenStreetMap, etc.)
        console.log('[Geo_Verwaltung] Geocoding:', adresse);

        // Platzhalter
        // const coords = await geocode(adresse);
        // if (elements.latitude) elements.latitude.value = coords.lat;
        // if (elements.longitude) elements.longitude.value = coords.lng;

    } catch (error) {
        console.error('[Geo_Verwaltung] Geocoding fehlgeschlagen:', error);
    }
}

async function reverseGeocode() {
    // Koordinaten zu Adresse umwandeln
    const lat = elements.latitude?.value;
    const lng = elements.longitude?.value;

    if (!lat || !lng) return;

    try {
        // TODO: Reverse Geocoding-API aufrufen
        console.log('[Geo_Verwaltung] Reverse Geocoding:', lat, lng);

        // Platzhalter
        // const adresse = await reverseGeocode(lat, lng);
        // if (elements.strasse) elements.strasse.value = adresse.street;
        // if (elements.plz) elements.plz.value = adresse.zip;
        // if (elements.ort) elements.ort.value = adresse.city;

    } catch (error) {
        console.error('[Geo_Verwaltung] Reverse Geocoding fehlgeschlagen:', error);
    }
}

function updateMap() {
    if (!currentObjektId) return;

    const lat = parseFloat(elements.latitude?.value);
    const lng = parseFloat(elements.longitude?.value);
    const radius = parseInt(elements.radius?.value) || 100;

    if (!lat || !lng) {
        showError('Bitte Koordinaten eingeben');
        return;
    }

    updateMapMarker({ Latitude: lat, Longitude: lng, Geofence_Radius: radius });
}

function updateMapMarker(objekt) {
    // Platzhalter für Karten-Marker-Update
    console.log('[Geo_Verwaltung] Marker aktualisieren:', objekt);

    // TODO: Karten-Bibliothek verwenden
    // mapInstance.setCenter(objekt.Latitude, objekt.Longitude);
    // mapInstance.addCircle(objekt.Latitude, objekt.Longitude, objekt.Geofence_Radius);
}

function clearForm() {
    if (elements.objektName) elements.objektName.value = '';
    if (elements.strasse) elements.strasse.value = '';
    if (elements.plz) elements.plz.value = '';
    if (elements.ort) elements.ort.value = '';
    if (elements.latitude) elements.latitude.value = '';
    if (elements.longitude) elements.longitude.value = '';
    if (elements.radius) elements.radius.value = '100';
    if (elements.geofenceAktiv) elements.geofenceAktiv.checked = false;
    if (elements.checkinErlaubt) elements.checkinErlaubt.checked = false;
}

function handleSearch(e) {
    const term = e.target.value.toLowerCase();
    const items = elements.objektListe?.querySelectorAll('.objekt-item');

    items?.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(term) ? '' : 'none';
    });
}

function showError(msg) {
    console.error(msg);
    // TODO: UI-Feedback implementieren
}

function showSuccess(msg) {
    console.log(msg);
    // TODO: UI-Feedback implementieren
}

document.addEventListener('DOMContentLoaded', init);
