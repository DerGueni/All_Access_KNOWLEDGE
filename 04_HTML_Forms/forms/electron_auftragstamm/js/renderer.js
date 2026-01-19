/**
 * CONSYS Auftragsverwaltung - Renderer Script
 * Hauptlogik für das Electron-Frontend
 * 
 * Version 1.1.0 - 30.12.2025 - Mit Echtdaten-Unterstützung
 */

// ============================================
// GLOBALE VARIABLEN
// ============================================
let currentAuftragId = null;
let currentVADatum = null;
let auftragsListe = [];
let auftragsIndex = 0;
let isDirty = false;
let isDemo = true;

// ============================================
// DOM READY
// ============================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('[Renderer] Auftragsverwaltung initialisiert');
    
    // DB-Status-Listener
    if (window.api) {
        window.api.onDbStatus((status) => {
            console.log('[Renderer] DB-Status:', status);
            isDemo = status.demo;
            updateDbStatusIndicator(status);
        });
    }
    
    // Initialisierung
    initTabs();
    initNavigation();
    initToolbar();
    initFormEvents();
    initAuftragsListe();
    
    // Lade Lookup-Daten
    await loadLookupData();
    
    // Lade initiale Auftragsliste (ab heute)
    await loadAuftraegeList(formatDateForFilter(new Date()));
    
    // Setze aktuelles Datum
    const lblDatum = document.getElementById('lblDatum');
    if (lblDatum) {
        lblDatum.textContent = new Date().toLocaleDateString('de-DE');
    }
    
    // Setze Filter auf heute
    const filterInput = document.getElementById('txtAuftraegeAb');
    if (filterInput) {
        filterInput.value = formatGermanDate(new Date());
    }
    
    // Prüfe DB-Status
    if (window.api) {
        const status = await window.api.getDbStatus();
        isDemo = status.demo;
        updateDbStatusIndicator(status);
    }
});

// ============================================
// DB STATUS ANZEIGE
// ============================================
function updateDbStatusIndicator(status) {
    let indicator = document.getElementById('dbStatusIndicator');
    
    if (!indicator) {
        indicator = document.createElement('div');
        indicator.id = 'dbStatusIndicator';
        indicator.style.cssText = `
            position: fixed; 
            bottom: 10px; 
            left: 10px; 
            padding: 5px 12px; 
            border-radius: 4px; 
            font-size: 11px; 
            z-index: 9999;
            cursor: pointer;
        `;
        indicator.title = 'Klicken zum Neu-Verbinden';
        indicator.addEventListener('click', reconnectDb);
        document.body.appendChild(indicator);
    }
    
    if (status.demo) {
        indicator.style.backgroundColor = '#f39c12';
        indicator.style.color = '#fff';
        indicator.textContent = '⚠ Demo-Modus';
    } else {
        indicator.style.backgroundColor = '#27ae60';
        indicator.style.color = '#fff';
        indicator.textContent = '✓ Verbunden';
    }
}

async function reconnectDb() {
    if (window.api) {
        const status = await window.api.reconnectDb();
        isDemo = status.demo;
        updateDbStatusIndicator(status);
        if (!status.demo) {
            await loadLookupData();
            await loadAuftraegeList();
        }
    }
}

// ============================================
// LOOKUP-DATEN LADEN
// ============================================
async function loadLookupData() {
    if (!window.api) return;
    
    try {
        // Kunden
        const kunden = await window.api.getKunden();
        fillCombo('cboAuftraggeber', kunden, 'kun_Id', 'kun_Firma');
        
        // Status
        const status = await window.api.getStatus();
        fillCombo('cboStatus', status, 'ID', 'Fortschritt');
        
        // Orte
        const orte = await window.api.getOrte();
        fillComboSimple('cboOrt', orte);
        
        // Objekte
        const objekte = await window.api.getObjekte();
        fillCombo('cboObjekt', objekte, 'ID', 'Objekt');
        
        // Dienstkleidung
        const dk = await window.api.getDienstkleidung();
        fillComboSimple('cboDienstkleidung', dk);
        
        console.log('[Renderer] Lookup-Daten geladen');
    } catch (error) {
        console.error('[Renderer] Fehler beim Laden der Lookup-Daten:', error);
    }
}

function fillCombo(comboId, data, valueField, textField) {
    const combo = document.getElementById(comboId);
    if (!combo || !data) return;
    
    // Erste Option behalten (Placeholder)
    const firstOption = combo.options[0];
    combo.innerHTML = '';
    if (firstOption) {
        combo.add(firstOption);
    } else {
        combo.add(new Option('-- Auswählen --', ''));
    }
    
    data.forEach(item => {
        const value = item[valueField] || item;
        const text = item[textField] || item;
        combo.add(new Option(text, value));
    });
}

function fillComboSimple(comboId, data) {
    const combo = document.getElementById(comboId);
    if (!combo || !data) return;
    
    combo.innerHTML = '';
    combo.add(new Option('-- Auswählen --', ''));
    
    data.forEach(item => {
        const text = typeof item === 'string' ? item : item.toString();
        combo.add(new Option(text, text));
    });
}

// ============================================
// AUFTRAGSLISTE LADEN
// ============================================
async function loadAuftraegeList(datumAb) {
    if (!window.api) return;
    
    try {
        const filter = datumAb ? { datumAb } : null;
        auftragsListe = await window.api.getAuftraegeList(filter);
        
        renderAuftragsListe();
        
        // Ersten Auftrag laden wenn vorhanden
        if (auftragsListe.length > 0) {
            await loadAuftrag(auftragsListe[0].ID);
        }
        
        console.log(`[Renderer] ${auftragsListe.length} Aufträge geladen`);
    } catch (error) {
        console.error('[Renderer] Fehler beim Laden der Auftragsliste:', error);
    }
}

function renderAuftragsListe() {
    const tbody = document.getElementById('auftraegeListBody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    auftragsListe.forEach((auftrag, index) => {
        const tr = document.createElement('tr');
        tr.dataset.id = auftrag.ID;
        tr.dataset.index = index;
        
        if (auftrag.ID === currentAuftragId) {
            tr.classList.add('selected');
        }
        
        tr.innerHTML = `
            <td>${auftrag.Datum || ''}</td>
            <td>${auftrag.Auftrag || ''}</td>
        `;
        
        tbody.appendChild(tr);
    });
}

// ============================================
// TAB FUNKTIONALITÄT
// ============================================
function initTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const tabId = btn.dataset.tab;
            
            tabButtons.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));
            
            btn.classList.add('active');
            const tabContent = document.getElementById(`tab-${tabId}`);
            if (tabContent) {
                tabContent.classList.add('active');
            }
        });
    });
}

// ============================================
// NAVIGATION (Datensatz-Navigation)
// ============================================
function initNavigation() {
    bindButton('btnFirst', navigateFirst);
    bindButton('btnPrev', navigatePrev);
    bindButton('btnNext', navigateNext);
    bindButton('btnLast', navigateLast);
    bindButton('btnRefresh', refreshData);
    
    bindButton('btnDatumLeft', () => navigateVADatum(-1));
    bindButton('btnDatumRight', () => navigateVADatum(1));
}

function bindButton(id, handler) {
    const btn = document.getElementById(id);
    if (btn) {
        btn.addEventListener('click', handler);
    }
}

async function navigateFirst() {
    if (auftragsListe.length > 0) {
        auftragsIndex = 0;
        await loadAuftrag(auftragsListe[0].ID);
    }
}

async function navigatePrev() {
    if (auftragsIndex > 0) {
        auftragsIndex--;
        await loadAuftrag(auftragsListe[auftragsIndex].ID);
    }
}

async function navigateNext() {
    if (auftragsIndex < auftragsListe.length - 1) {
        auftragsIndex++;
        await loadAuftrag(auftragsListe[auftragsIndex].ID);
    }
}

async function navigateLast() {
    if (auftragsListe.length > 0) {
        auftragsIndex = auftragsListe.length - 1;
        await loadAuftrag(auftragsListe[auftragsIndex].ID);
    }
}

async function refreshData() {
    if (currentAuftragId) {
        await loadAuftrag(currentAuftragId);
    }
}

function navigateVADatum(direction) {
    const combo = document.getElementById('cboVADatum');
    if (!combo) return;
    
    const newIndex = combo.selectedIndex + direction;
    if (newIndex >= 0 && newIndex < combo.options.length) {
        combo.selectedIndex = newIndex;
        currentVADatum = combo.value;
        loadSubforms();
    }
}

// ============================================
// TOOLBAR BUTTONS
// ============================================
function initToolbar() {
    bindButton('btnMitarbeiterauswahl', openMitarbeiterauswahl);
    bindButton('btnAktualisieren', refreshData);
    bindButton('btnNeuerAuftrag', createNewAuftrag);
    bindButton('btnAuftragKopieren', copyAuftrag);
    bindButton('btnAuftragLoeschen', deleteAuftrag);
    bindButton('btnPositionen', openPositionen);
    
    bindButton('btnEinsatzlisteMA', () => sendEinsatzliste('MA'));
    bindButton('btnEinsatzlisteBOS', () => sendEinsatzliste('BOS'));
    bindButton('btnEinsatzlisteSUB', () => sendEinsatzliste('SUB'));
    bindButton('btnEinsatzlisteDrucken', printEinsatzliste);
    bindButton('btnNamenslisteESS', openNamenslisteESS);
    
    bindButton('btnBWNDrucken', printBWN);
}

async function openMitarbeiterauswahl() {
    if (!currentAuftragId) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    
    console.log('[Renderer] Öffne Mitarbeiterauswahl für Auftrag:', currentAuftragId);
    
    if (window.api) {
        await window.api.openMitarbeiterauswahl(currentAuftragId);
    }
}

async function createNewAuftrag() {
    if (isDirty && !confirm('Ungespeicherte Änderungen verwerfen?')) {
        return;
    }
    
    clearForm();
    currentAuftragId = null;
    isDirty = true;
    
    // Fokus auf erstes Feld
    const datVon = document.getElementById('txtDatVon');
    if (datVon) datVon.focus();
}

async function copyAuftrag() {
    if (!currentAuftragId) {
        alert('Kein Auftrag ausgewählt');
        return;
    }
    
    if (!confirm('Auftrag kopieren?')) return;
    
    if (window.api) {
        const result = await window.api.copyAuftrag(currentAuftragId);
        if (result.success && result.id) {
            await loadAuftraegeList();
            await loadAuftrag(result.id);
            alert(result.message || 'Auftrag kopiert');
        }
    }
}

async function deleteAuftrag() {
    if (!currentAuftragId) {
        alert('Kein Auftrag ausgewählt');
        return;
    }
    
    if (window.api) {
        const result = await window.api.deleteAuftrag(currentAuftragId);
        if (result.success) {
            await loadAuftraegeList();
        }
    }
}

function openPositionen() {
    console.log('[Renderer] Öffne Positionen für Auftrag:', currentAuftragId);
}

async function sendEinsatzliste(type) {
    if (!currentAuftragId) {
        alert('Bitte zuerst einen Auftrag auswählen');
        return;
    }
    
    console.log(`[Renderer] Sende Einsatzliste ${type}`);
    
    if (window.api) {
        const result = await window.api.sendEinsatzliste(type);
        if (result.message) {
            alert(result.message);
        }
    }
}

function printEinsatzliste() {
    console.log('[Renderer] Drucke Einsatzliste');
    window.print();
}

function openNamenslisteESS() {
    console.log('[Renderer] Öffne Namensliste ESS');
}

function printBWN() {
    console.log('[Renderer] Drucke BWN');
}

// ============================================
// FORMULAR EVENTS
// ============================================
function initFormEvents() {
    // Änderungserkennung
    document.querySelectorAll('input, select, textarea').forEach(input => {
        input.addEventListener('change', () => {
            isDirty = true;
        });
    });
    
    // VA-Datum Änderung
    const cboVADatum = document.getElementById('cboVADatum');
    if (cboVADatum) {
        cboVADatum.addEventListener('change', () => {
            currentVADatum = cboVADatum.value;
            loadSubforms();
        });
    }
    
    // Keyboard Shortcuts
    document.addEventListener('keydown', handleKeyboard);
}

function handleKeyboard(e) {
    if (e.ctrlKey && e.key === 's') {
        e.preventDefault();
        saveAuftrag();
    }
    if (e.key === 'F5') {
        e.preventDefault();
        refreshData();
    }
    if (e.ctrlKey && e.key === 'n') {
        e.preventDefault();
        createNewAuftrag();
    }
}

// ============================================
// AUFTRAGS-LISTE SIDEBAR
// ============================================
function initAuftragsListe() {
    const tbody = document.getElementById('auftraegeListBody');
    if (!tbody) return;
    
    tbody.addEventListener('click', async (e) => {
        const row = e.target.closest('tr');
        if (row && row.dataset.id) {
            tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
            row.classList.add('selected');
            
            auftragsIndex = parseInt(row.dataset.index) || 0;
            await loadAuftrag(parseInt(row.dataset.id));
        }
    });
    
    tbody.addEventListener('dblclick', async (e) => {
        const row = e.target.closest('tr');
        if (row && row.dataset.id) {
            await loadAuftrag(parseInt(row.dataset.id));
        }
    });
    
    // Filter-Buttons
    bindButton('btnGo', filterAuftraege);
    bindButton('btnTgBack', () => shiftDateFilter(-7));
    bindButton('btnTgVor', () => shiftDateFilter(7));
    bindButton('btnHeute', setFilterToday);
}

async function filterAuftraege() {
    const filterInput = document.getElementById('txtAuftraegeAb');
    if (filterInput && filterInput.value) {
        const datumAb = formatDateForFilter(parseGermanDate(filterInput.value));
        await loadAuftraegeList(datumAb);
    }
}

function shiftDateFilter(days) {
    const input = document.getElementById('txtAuftraegeAb');
    if (!input) return;
    
    const currentDate = parseGermanDate(input.value) || new Date();
    currentDate.setDate(currentDate.getDate() + days);
    input.value = formatGermanDate(currentDate);
    filterAuftraege();
}

function setFilterToday() {
    const input = document.getElementById('txtAuftraegeAb');
    if (input) {
        input.value = formatGermanDate(new Date());
        filterAuftraege();
    }
}

// ============================================
// DATEN LADEN
// ============================================
async function loadAuftrag(id) {
    console.log('[Renderer] Lade Auftrag:', id);
    
    if (!window.api) {
        console.warn('[Renderer] API nicht verfügbar');
        return;
    }
    
    try {
        const auftrag = await window.api.getAuftrag(id);
        
        if (auftrag) {
            currentAuftragId = auftrag.ID;
            fillForm(auftrag);
            
            // VA-Datum-Liste laden
            await loadVADatumList(auftrag.ID);
            
            // Subforms laden
            await loadSubforms();
            
            // Liste aktualisieren (Markierung)
            renderAuftragsListe();
            
            isDirty = false;
        }
    } catch (error) {
        console.error('[Renderer] Fehler beim Laden des Auftrags:', error);
    }
}

async function loadVADatumList(va_id) {
    if (!window.api) return;
    
    try {
        const datumList = await window.api.getVaDatumList(va_id);
        const combo = document.getElementById('cboVADatum');
        
        if (combo) {
            combo.innerHTML = '';
            
            datumList.forEach((item, index) => {
                const text = formatGermanDate(new Date(item.VADatum));
                combo.add(new Option(text, item.VADatum));
            });
            
            if (datumList.length > 0) {
                combo.selectedIndex = 0;
                currentVADatum = datumList[0].VADatum;
            }
        }
    } catch (error) {
        console.error('[Renderer] Fehler beim Laden der VA-Datum-Liste:', error);
    }
}

async function loadSubforms() {
    if (!currentAuftragId || !window.api) return;
    
    try {
        // Schichten laden
        const schichten = await window.api.getSchichten(currentAuftragId, currentVADatum);
        renderSchichten(schichten);
        
        // MA-Zuordnung laden
        const maZuordnung = await window.api.getMaZuordnung(currentAuftragId, currentVADatum);
        renderMAZuordnung(maZuordnung);
        
    } catch (error) {
        console.error('[Renderer] Fehler beim Laden der Subforms:', error);
    }
}

function renderSchichten(schichten) {
    const tbody = document.getElementById('schichtenBody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    schichten.forEach(schicht => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${schicht.Anzahl_Ist || 0}</td>
            <td>${schicht.Anzahl_Soll || 0}</td>
            <td>${schicht.Beginn || ''}</td>
            <td>${schicht.Ende || ''}</td>
        `;
        tbody.appendChild(tr);
    });
}

function renderMAZuordnung(zuordnungen) {
    const tbody = document.getElementById('zuordnungBody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    zuordnungen.forEach(z => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${z.Lfd || ''}</td>
            <td>${z.Nachname || ''}, ${z.Vorname || ''}</td>
            <td>${z.von || ''}</td>
            <td>${z.bis || ''}</td>
            <td>${z.Stunden || ''}</td>
        `;
        tbody.appendChild(tr);
    });
}

function fillForm(data) {
    setInputValue('txtID', data.ID);
    setInputValue('txtDatVon', formatGermanDate(new Date(data.Dat_VA_Von)));
    setInputValue('txtDatBis', formatGermanDate(new Date(data.Dat_VA_Bis)));
    setInputValue('txtTreffpunkt', data.Treffpunkt);
    setInputValue('txtTreffpunktZeit', data.Treffp_Zeit);
    setInputValue('txtAnsprechpartner', data.Ansprechpartner);
    setInputValue('txtPKWAnzahl', data.PKW_Anzahl);
    setInputValue('txtFahrtkosten', data.Fahrtkosten);
    
    setComboValue('cboAuftrag', data.Auftrag);
    setComboValue('cboOrt', data.Ort);
    setComboValue('cboObjekt', data.Objekt_ID || data.Objekt);
    setComboValue('cboDienstkleidung', data.Dienstkleidung);
    setComboValue('cboAuftraggeber', data.Veranstalter_ID);
    setComboValue('cboStatus', data.Veranst_Status_ID);
    
    // Kundenname anzeigen
    const kundenLabel = document.getElementById('lblKundenname');
    if (kundenLabel && data.kun_Firma) {
        kundenLabel.textContent = data.kun_Firma;
    }
}

function setInputValue(id, value) {
    const el = document.getElementById(id);
    if (el) {
        el.value = value || '';
    }
}

function setComboValue(comboId, value) {
    const combo = document.getElementById(comboId);
    if (!combo || !value) return;
    
    for (let option of combo.options) {
        if (option.value == value || option.text == value) {
            combo.value = option.value;
            return;
        }
    }
    
    // Wenn nicht gefunden, als Text-Option hinzufügen
    if (typeof value === 'string' && value.length > 0) {
        combo.add(new Option(value, value, true, true));
    }
}

// ============================================
// DATEN SPEICHERN
// ============================================
async function saveAuftrag() {
    console.log('[Renderer] Speichere Auftrag:', currentAuftragId);
    
    const data = collectFormData();
    
    if (window.api) {
        const result = await window.api.saveAuftrag(data);
        if (result.success) {
            isDirty = false;
            if (!currentAuftragId && result.id) {
                currentAuftragId = result.id;
                setInputValue('txtID', result.id);
            }
            alert(result.message || 'Gespeichert');
            await loadAuftraegeList();
        } else {
            alert('Fehler: ' + (result.message || 'Unbekannter Fehler'));
        }
    }
}

function collectFormData() {
    return {
        ID: currentAuftragId,
        Dat_VA_Von: document.getElementById('txtDatVon')?.value,
        Dat_VA_Bis: document.getElementById('txtDatBis')?.value,
        Auftrag: document.getElementById('cboAuftrag')?.value,
        Ort: document.getElementById('cboOrt')?.value,
        Objekt: document.getElementById('cboObjekt')?.selectedOptions[0]?.text,
        Objekt_ID: document.getElementById('cboObjekt')?.value,
        Treffp_Zeit: document.getElementById('txtTreffpunktZeit')?.value,
        Treffpunkt: document.getElementById('txtTreffpunkt')?.value,
        PKW_Anzahl: document.getElementById('txtPKWAnzahl')?.value,
        Fahrtkosten: document.getElementById('txtFahrtkosten')?.value,
        Dienstkleidung: document.getElementById('cboDienstkleidung')?.value,
        Ansprechpartner: document.getElementById('txtAnsprechpartner')?.value,
        Veranstalter_ID: document.getElementById('cboAuftraggeber')?.value,
        Veranst_Status_ID: document.getElementById('cboStatus')?.value
    };
}

function clearForm() {
    setInputValue('txtID', '');
    setInputValue('txtDatVon', formatGermanDate(new Date()));
    setInputValue('txtDatBis', formatGermanDate(new Date()));
    setInputValue('txtTreffpunkt', '');
    setInputValue('txtTreffpunktZeit', '');
    setInputValue('txtAnsprechpartner', '');
    setInputValue('txtPKWAnzahl', '');
    setInputValue('txtFahrtkosten', '');
    
    ['cboAuftrag', 'cboOrt', 'cboObjekt', 'cboDienstkleidung', 'cboAuftraggeber'].forEach(id => {
        const combo = document.getElementById(id);
        if (combo) combo.selectedIndex = 0;
    });
    
    const cboStatus = document.getElementById('cboStatus');
    if (cboStatus) cboStatus.selectedIndex = 1; // "In Planung"
    
    // Subforms leeren
    const schichtenBody = document.getElementById('schichtenBody');
    if (schichtenBody) schichtenBody.innerHTML = '';
    
    const zuordnungBody = document.getElementById('zuordnungBody');
    if (zuordnungBody) zuordnungBody.innerHTML = '';
}

// ============================================
// HELPER FUNKTIONEN
// ============================================
function parseGermanDate(dateStr) {
    if (!dateStr) return null;
    const parts = dateStr.split('.');
    if (parts.length === 3) {
        let year = parseInt(parts[2]);
        if (year < 100) year += 2000;
        return new Date(year, parseInt(parts[1]) - 1, parseInt(parts[0]));
    }
    return null;
}

function formatGermanDate(date) {
    if (!date || isNaN(date.getTime())) return '';
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}.${month}.${year}`;
}

function formatDateForFilter(date) {
    if (!date || isNaN(date.getTime())) return null;
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// ============================================
// MENÜ BUTTONS
// ============================================
document.querySelectorAll('.menu-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const formName = btn.dataset.form;
        console.log('[Renderer] Öffne Formular:', formName);
        
        document.querySelectorAll('.menu-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        if (window.api) {
            window.api.openForm(formName);
        }
    });
});

console.log('[Renderer] Script geladen');
