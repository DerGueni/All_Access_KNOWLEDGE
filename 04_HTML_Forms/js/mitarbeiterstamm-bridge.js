    <!-- WebView2 Bridge -->

// Mitarbeiterstamm WebView2 Bridge Integration
        // ==================== GLOBALE VARIABLEN ====================
        let allMitarbeiter = [];
        let filteredMitarbeiter = [];
        let currentIndex = 0;
        let currentMA = null;
        let isWebView2 = false;
        
        // ==================== INITIALISIERUNG ====================
        document.addEventListener('DOMContentLoaded', function() {
            // Prüfe ob WebView2 verfügbar
            isWebView2 = typeof window.chrome !== 'undefined' && window.chrome.webview;
            
            // Bridge initialisieren
            if (typeof Bridge !== 'undefined') {
                Bridge.init();
                Bridge.on('onDataReceived', handleDataReceived);
                Bridge.on('onSearchResults', handleSearchResults);
                Bridge.on('onSaveComplete', handleSaveComplete);
                console.log('WebView2 Bridge initialisiert');
            }
            
            initDateFields();
            loadAllData();
            setupEventListeners();
        });
        
        function initDateFields() {
            const today = new Date().toISOString().split('T')[0];
            const el = document.getElementById('dpStartDate');
            if (el) el.value = today;
            
            const von = document.getElementById('auftrVon');
            const bis = document.getElementById('auftrBis');
            if (von) von.value = new Date().getFullYear() + '-01-01';
            if (bis) bis.value = today;
        }
        
        function setupEventListeners() {
            // Suche mit Enter
            const searchEl = document.getElementById('maSearch');
            if (searchEl) {
                searchEl.addEventListener('keyup', function(e) {
                    if (e.key === 'Enter') filterMitarbeiter();
                    else if (this.value.length > 2 || this.value.length === 0) filterMitarbeiter();
                });
            }
            
            // Nur Aktive Filter
            const nurAktiveEl = document.getElementById('nurAktive');
            if (nurAktiveEl) {
                nurAktiveEl.addEventListener('change', filterMitarbeiter);
            }
            
            // AfterUpdate Events für wichtige Felder
            const fieldsWithAfterUpdate = ['Nachname', 'Vorname', 'Strasse', 'PLZ', 'Ort', 'Email', 'TelMobil'];
            fieldsWithAfterUpdate.forEach(fieldId => {
                const el = document.getElementById(fieldId);
                if (el) {
                    el.addEventListener('change', function() {
                        markAsDirty();
                        autoSave();
                    });
                }
            });
        }
        
        // ==================== DATEN LADEN ====================
        async function loadAllData() {
            if (isWebView2 && typeof Bridge !== 'undefined') {
                // Lade Daten über WebView2 Bridge
                Bridge.sendEvent('loadData', { type: 'mitarbeiterstammComplete', id: 0 });
            } else {
                // Fallback: Lade von externem Script oder Demo-Daten
                try {
                    // Versuche externes Datenscript
                    const response = await fetch('../../data/mitarbeiter_data.js');
                    if (response.ok) {
                        const text = await response.text();
                        eval(text);
                        if (typeof MITARBEITER_DATA !== 'undefined') {
                            handleDataReceived(MITARBEITER_DATA);
                        }
                    }
                } catch (e) {
                    console.log('Lade Demo-Daten');
                    loadDemoData();
                }
            }
        }
        
        function loadDemoData() {
            // Prüfe ob Echtdaten vorhanden
            if (typeof MITARBEITER_ECHTDATEN !== 'undefined' && MITARBEITER_ECHTDATEN.length > 0) {
                console.log('Echtdaten gefunden:', MITARBEITER_ECHTDATEN.length, 'Mitarbeiter');
                const data = {
                    alleMitarbeiter: MITARBEITER_ECHTDATEN,
                    stammdaten: MITARBEITER_ECHTDATEN[0],
                    einsaetze: [],
                    dienstplan: [],
                    nichtVerfuegbar: [],
                    dienstkleidung: []
                };
                handleDataReceived(data);
                return;
            }
            // Fallback Demo-Daten
            console.log('Keine Echtdaten - verwende Demo');
            const demoData = {
                alleMitarbeiter: [
                    { id: 707, nachname: 'Alali', vorname: 'Ahmad', ort: 'Nürnberg', istAktiv: true }
                ],
                stammdaten: {
                    id: 707, nachname: 'Alali', vorname: 'Ahmad', ort: 'Nürnberg'
                },
                einsaetze: [],
                dienstplan: [],
                nichtVerfuegbar: [],
                dienstkleidung: []
            };
            handleDataReceived(demoData);
        }
        
        function handleDataReceived(data) {
            console.log('Daten empfangen:', data);
            
            // Mitarbeiter-Liste
            if (data.alleMitarbeiter) {
                allMitarbeiter = data.alleMitarbeiter;
                filterMitarbeiter();
            }
            
            // Stammdaten
            if (data.stammdaten) {
                currentMA = data.stammdaten;
                fillStammdaten(data.stammdaten);
            }
            
            // Einsätze
            if (data.einsaetze) {
                fillEinsaetze(data.einsaetze);
            }
            
            // Dienstplan
            if (data.dienstplan) {
                fillDienstplan(data.dienstplan);
            }
            
            // Nicht Verfügbar
            if (data.nichtVerfuegbar) {
                fillNichtVerfuegbar(data.nichtVerfuegbar);
            }
            
            // Dienstkleidung
            if (data.dienstkleidung) {
                fillDienstkleidung(data.dienstkleidung);
            }
            
            // Zeitkonto
            if (data.zeitkontoMonat) {
                fillZeitkontoMonat(data.zeitkontoMonat);
            }
            
            // Sub-Rechnungen
            if (data.subRechnungen) {
                fillSubRechnungen(data.subRechnungen);
            }
        }
        
        // ==================== FORMULAR BEFÜLLEN ====================
        function fillStammdaten(ma) {
            // Header
            setElementValue('maNameDisplay', (ma.nachname || '') + ', ' + (ma.vorname || ''));
            setElementValue('maStatusText', getAnstellungsart(ma.anstellungsartId) + (ma.istAktiv ? ' - Aktiv' : ' - Inaktiv'));
            setElementValue('maIdBox', ma.id);
            
            // Stammdaten-Felder
            setElementValue('PersNr', ma.id || ma.persNr);
            setElementValue('LexNr', ma.lexId);
            setElementChecked('Aktiv', ma.istAktiv);
            setElementChecked('Subunternehmer', ma.istSub);
            setElementChecked('Lex_Aktiv', ma.lexAktiv);
            
            // Persönliche Daten
            setElementValue('Nachname', ma.nachname);
            setElementValue('Vorname', ma.vorname);
            setElementValue('Strasse', ma.strasse);
            setElementValue('Nr', ma.nr);
            setElementValue('PLZ', ma.plz);
            setElementValue('Ort', ma.ort);
            setElementValue('Land', ma.land || 'Deutschland');
            setElementValue('Bundesland', ma.bundesland || 'Bayern');
            setElementValue('TelMobil', ma.telMobil);
            setElementValue('TelFestnetz', ma.telFest);
            setElementValue('Email', ma.email);
            setElementValue('Geschlecht', ma.geschlecht);
            setElementValue('Staatsangehoerigkeit', ma.staatsang);
            setElementValue('GebDatum', ma.gebDat);
            setElementValue('GebOrt', ma.gebOrt);
            setElementValue('GebName', ma.gebName);
            
            // Bankdaten
            setElementValue('Kontoinhaber', ma.kontoinhaber);
            setElementValue('BIC', ma.bic);
            setElementValue('IBAN', ma.iban);
            setElementValue('BezuegeGezahltAls', ma.bezuegeAls);
            
            // Sozialversicherung
            setElementValue('SteuerID', ma.steuerNr);
            setElementValue('Steuerklasse', ma.steuerklasse);
            setElementValue('Krankenkasse', ma.krankenkasse);
            setElementChecked('RVBefreiung', ma.rvBefreit);
            
            // Arbeitszeit
            setElementValue('UrlaubProJahr', ma.urlaubsanspr);
            setElementValue('StundenMonatMax', ma.maxStunden);
            setElementValue('stdProTag', ma.arbStdTag);
            setElementValue('tageProWoche', ma.arbTageWoche);
            
            // Tätigkeit
            setElementValue('Taetigkeit', ma.taetigkeit);
            setElementValue('Lohngruppe', ma.lohngruppe);
            setElementChecked('BruttoStd', ma.bruttoStd);
            setElementChecked('AbrechnungEmail', ma.emailAbrechnung);
            
            
    // Zusätzliche Stammdaten-Felder
    setElementChecked('Aktiv', ma.istAktiv);
    setElementChecked('Subunternehmer', ma.istSubunternehmer);
    setElementChecked('RVBefreiung', ma.rvBefreiung);
    setElementChecked('Lex_Aktiv', ma.lexAktiv);
    setElementChecked('AbrechnungEmail', ma.abrechnungEmail);
    setElementValue('BruttoStd', ma.bruttoStd);
    setElementValue('Lichtbild', ma.lichtbild);
    // Erstellt/Geändert
            setElementValue('erstelltVon', ma.erstVon);
            setElementValue('erstelltAm', ma.erstAm);
            setElementValue('geaendertVon', ma.aendVon);
            setElementValue('geaendertAm', ma.aendAm);
            
            // Foto
            if (ma.lichtbild) {
                const photoBox = document.getElementById('photoBox');
                if (photoBox) {
                    photoBox.innerHTML = '<img src="' + ma.lichtbild + '" alt="Mitarbeiterfoto">';
                }
            }
        }
        
        function fillEinsaetze(einsaetze) {
            const tbody = document.getElementById('einsatzMonatBody') || document.querySelector('#tblEinsatzMonat tbody');
            if (!tbody) return;
            
            tbody.innerHTML = '';
            let sumStunden = 0, sumNacht = 0, sumSonntag = 0, sumFeiertag = 0;
            
            einsaetze.forEach(e => {
                sumStunden += e.stunden || 0;
                sumNacht += e.nacht || 0;
                sumSonntag += e.sonntag || 0;
                sumFeiertag += e.feiertag || 0;
                
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${e.datum}</td>
                    <td>${e.auftrag || ''}</td>
                    <td>${e.ort || ''}</td>
                    <td>${e.von || ''}</td>
                    <td>${e.bis || ''}</td>
                    <td style="text-align:right">${formatNumber(e.stunden)}</td>
                    <td style="text-align:right">${formatNumber(e.nacht || 0)}</td>
                    <td style="text-align:right">${formatNumber(e.sonntag || 0)}</td>
                    <td style="text-align:right">${formatNumber(e.feiertag || 0)}</td>
                `;
                tr.onclick = () => openAuftrag(e.vaId);
                tbody.appendChild(tr);
            });
            
            // Summen
            setElementValue('sumStunden', formatNumber(sumStunden));
            setElementValue('sumNacht', formatNumber(sumNacht));
            setElementValue('sumSonntag', formatNumber(sumSonntag));
            setElementValue('sumFeiertag', formatNumber(sumFeiertag));
        }
        
        function fillDienstplan(dienstplan) {
            const tbody = document.getElementById('dienstplanBody') || document.querySelector('#tblDienstplan tbody');
            if (!tbody) return;
            
            tbody.innerHTML = '';
            dienstplan.forEach(d => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${d.datum}</td>
                    <td>${d.auftrag || ''}</td>
                    <td>${d.ort || ''}</td>
                    <td>${d.von || ''}</td>
                    <td>${d.bis || ''}</td>
                `;
                tr.onclick = () => openAuftrag(d.vaId);
                tbody.appendChild(tr);
            });
        }
        
        function fillNichtVerfuegbar(nvZeiten) {
            const tbody = document.getElementById('nichtVerfuegBody') || document.querySelector('#tblNichtVerfueg tbody');
            if (!tbody) return;
            
            tbody.innerHTML = '';
            nvZeiten.forEach(nv => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${nv.von}</td>
                    <td>${nv.bis}</td>
                    <td>${nv.grund || ''}</td>
                `;
                tbody.appendChild(tr);
            });
        }
        
        function fillDienstkleidung(kleidung) {
            const tbody = document.getElementById('kleidungBody') || document.querySelector('#tblKleidung tbody');
            if (!tbody) return;
            
            tbody.innerHTML = '';
            kleidung.forEach(k => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${k.artikel || ''}</td>
                    <td>${k.groesse || ''}</td>
                    <td>${k.anzahl || 0}</td>
                    <td>${k.ausgabeDat || ''}</td>
                `;
                tbody.appendChild(tr);
            });
        }
        
        function fillZeitkontoMonat(zk) {
            // Implementierung für Zeitkonto-Monat
        }
        
        function fillSubRechnungen(rech) {
            const tbody = document.getElementById('subRechBody') || document.querySelector('#tblSubRech tbody');
            if (!tbody) return;
            
            tbody.innerHTML = '';
            rech.forEach(r => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${r.datum}</td>
                    <td>${r.auftrag || ''}</td>
                    <td>${r.location || ''}</td>
                    <td>${r.ort || ''}</td>
                    <td style="text-align:right">${formatCurrency(r.betrag)}</td>
                    <td>${r.rechNr || ''}</td>
                    <td>${r.geprueft || ''}</td>
                    <td>${r.am || ''}</td>
                    <td>${r.status || ''}</td>
                `;
                tbody.appendChild(tr);
            });
        }
        
        // ==================== MITARBEITER-LISTE ====================
        function filterMitarbeiter() {
            const searchTerm = (document.getElementById('maSearch')?.value || '').toLowerCase();
            const nurAktive = document.getElementById('nurAktive')?.checked ?? true;
            
            filteredMitarbeiter = allMitarbeiter.filter(ma => {
                const nameMatch = (ma.nachname + ' ' + ma.vorname).toLowerCase().includes(searchTerm);
                const aktivMatch = !nurAktive || ma.aktiv;
                return nameMatch && aktivMatch;
            });
            
            renderMitarbeiterListe();
        }
        
        function renderMitarbeiterListe() {
            const listBody = document.getElementById('maListBody');
            if (!listBody) return;
            
            listBody.innerHTML = '';
            filteredMitarbeiter.forEach((ma, idx) => {
                const row = document.createElement('div');
                row.className = 'ma-list-row' + (idx === currentIndex ? ' selected' : '');
                row.innerHTML = `
                    <div>${ma.nachname || ''}</div>
                    <div>${ma.vorname || ''}</div>
                    <div>${ma.ort || ''}</div>
                `;
                row.onclick = () => selectMitarbeiter(idx);
                row.ondblclick = () => loadMitarbeiter(ma.id);
                listBody.appendChild(row);
            });
        }
        
        function selectMitarbeiter(idx) {
            currentIndex = idx;
            renderMitarbeiterListe();
            const ma = filteredMitarbeiter[idx];
            if (ma) loadMitarbeiter(ma.id);
        }
        
        function loadMitarbeiter(maId) {
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('loadData', { type: 'mitarbeiterstammComplete', id: maId });
            } else {
                // Demo: Aktualisiere mit Basisdaten
                const ma = allMitarbeiter.find(m => m.id === maId);
                if (ma) {
                    handleDataReceived({
                        stammdaten: { ...ma, id: maId, persNr: maId },
                        einsaetze: [],
                        dienstplan: [],
                        nichtVerfuegbar: [],
                        dienstkleidung: []
                    });
                }
            }
        }
        
        // ==================== NAVIGATION ====================
        function navFirst() { if (filteredMitarbeiter.length > 0) selectMitarbeiter(0); }
        function navPrev() { if (currentIndex > 0) selectMitarbeiter(currentIndex - 1); }
        function navNext() { if (currentIndex < filteredMitarbeiter.length - 1) selectMitarbeiter(currentIndex + 1); }
        function navLast() { if (filteredMitarbeiter.length > 0) selectMitarbeiter(filteredMitarbeiter.length - 1); }
        
        // ==================== AKTIONEN ====================
        function saveMA() {
            const data = collectFormData();
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('save', { type: 'mitarbeiter', data: data });
            } else {
                console.log('Speichere:', data);
                alert('Gespeichert (Demo)');
            }
        }
        
        function deleteMA() {
            if (!currentMA || !confirm('Mitarbeiter wirklich löschen?')) return;
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('delete', { type: 'mitarbeiter', id: currentMA.id });
            }
        }
        
        function newMA() {
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('navigate', { target: 'neuerMitarbeiter' });
            } else {
                alert('Neuer Mitarbeiter (Demo)');
            }
        }
        
        function openAuftrag(vaId) {
            if (!vaId) return;
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('navigate', { target: 'auftragsverwaltung', id: vaId });
            } else {
                alert('Öffne Auftrag ' + vaId + ' (Demo)');
            }
        }
        
        function showZeitkonto() {
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('navigate', { target: 'zeitkonto', id: currentMA?.id });
            }
        }
        
        function showZKFest() { Bridge?.sendEvent('navigate', { target: 'zeitkontoFest' }); }
        function showZKMini() { Bridge?.sendEvent('navigate', { target: 'zeitkontoMini' }); }
        function sendEinsaetze() { Bridge?.sendEvent('action', { type: 'einsaetzeUebertragen', id: currentMA?.id }); }
        function showAdressen() { Bridge?.sendEvent('navigate', { target: 'maAdressen' }); }
        
        function collectFormData() {
            return {
                id: currentMA?.id || 0,
                nachname: getElementValue('Nachname'),
                vorname: getElementValue('Vorname'),
                strasse: getElementValue('Strasse'),
                nr: getElementValue('Nr'),
                plz: getElementValue('PLZ'),
                ort: getElementValue('Ort'),
                land: getElementValue('Land'),
                bundesland: getElementValue('Bundesland'),
                telMobil: getElementValue('TelMobil'),
                telFest: getElementValue('TelFestnetz'),
                email: getElementValue('Email'),
                istAktiv: getElementChecked('Aktiv'),
                istSub: getElementChecked('Subunternehmer'),
                lexAktiv: getElementChecked('Lex_Aktiv')
            };
        }
        
        function markAsDirty() {
            // Markiere Formular als geändert
            document.title = '* Mitarbeiterstammblatt - CONSEC';
        }
        
        function autoSave() {
            // Optional: Auto-Save nach Änderung
        }
        
        // ==================== TABS ====================
        function showTab(tabId, btn) {
            // Alle Tabs ausblenden
            document.querySelectorAll('.tab-body').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            
            // Gewählten Tab anzeigen
            const tab = document.getElementById('tab-' + tabId);
            if (tab) tab.classList.add('active');
            if (btn) btn.classList.add('active');
            
            // Tab-spezifische Daten laden
            if (tabId === 'einsatzmonat' && currentMA) {
                loadTabData('einsaetze');
            } else if (tabId === 'dienstplan' && currentMA) {
                loadTabData('dienstplan');
            } else if (tabId === 'auftragueb' && currentMA) {
                loadTabData('auftragsUebersicht');
            }
        }
        
        function loadTabData(type) {
            if (isWebView2 && typeof Bridge !== 'undefined') {
                Bridge.sendEvent('loadData', { type: type, id: currentMA?.id });
            }
        }
        
        // ==================== MENÜ ====================
        function openMenu(target) {
            const urls = {
                'dienstplan': '../frm_N_DP_Dienstplan_MA.html',
                'planung': '../frm_N_DP_Dienstplan_Objekt.html',
                'auftrag': '../auftragsverwaltung/frm_N_VA_Auftragstamm.html',
                'kunden': '../kundenverwaltung/frm_N_KD_Kundenstamm.html',
                'stunden': '../frm_N_Stundenauswertung.html',
                'abwesenheit': '../frm_N_MA_Abwesenheiten.html'
            };
            if (urls[target]) window.location.href = urls[target];
        }
        
        // ==================== HILFSFUNKTIONEN ====================
        function setElementValue(id, value) {
            const el = document.getElementById(id);
            if (el) {
                if (el.tagName === 'DIV' || el.tagName === 'SPAN') {
                    el.textContent = value ?? '';
                } else {
                    el.value = value ?? '';
                }
            }
        }
        
        function getElementValue(id) {
            const el = document.getElementById(id);
            return el ? el.value : '';
        }
        
        function setElementChecked(id, checked) {
            const el = document.getElementById(id);
            if (el) el.checked = !!checked;
        }
        
        function getElementChecked(id) {
            const el = document.getElementById(id);
            return el ? el.checked : false;
        }
        
        function formatNumber(num) {
            if (num === undefined || num === null) return '';
            return Number(num).toLocaleString('de-DE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }
        
        function formatCurrency(num) {
            if (num === undefined || num === null) return '';
            return Number(num).toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });
        }
        
        function getAnstellungsart(id) {
            const arten = { 1: 'Minijobber', 2: 'Festangestellter' };
            return arten[id] || 'Unbekannt';
        }
        
        function handleSearchResults(results) {
            // Suchergebnisse verarbeiten
        }
        
        function handleSaveComplete(result) {
            if (result.success) {
                document.title = 'Mitarbeiterstammblatt - CONSEC';
                alert('Erfolgreich gespeichert');
            } else {
                alert('Fehler beim Speichern: ' + result.error);
            }
        }




