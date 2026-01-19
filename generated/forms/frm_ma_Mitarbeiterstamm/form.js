(function(){
  'use strict';

  // ============================================
  // STATE MANAGEMENT
  // ============================================
  const state = {
    currentRecord: null,
    recordList: [],
    isDirty: false,
    currentTab: 'pgAdresse',
    filters: {
      anstellungsart_id: [3, 5] // Only active employees (Anstellungsart 3, 5)
    }
  };

  // ============================================
  // DOM REFERENCES
  // ============================================
  const dom = {
    app: document.getElementById('app'),

    // Toolbar
    versionLabel: document.getElementById('lbl_Version'),
    navFirst: document.querySelector('.nav-first'),
    navPrev: document.querySelector('.nav-prev'),
    navNext: document.querySelector('.nav-next'),
    navLast: document.querySelector('.nav-last'),

    // Buttons
    btnSave: document.getElementById('btnSave'),
    btnDelete: document.getElementById('mcobtnDelete'),
    btnPrint: document.getElementById('btnLstDruck'),
    btnTimeAcct: document.getElementById('btnZeitkonto'),
    btnZKFest: document.getElementById('btnZKFest'),
    btnZKMini: document.getElementById('btnZKMini'),
    btnStaffTable: document.getElementById('lbl_Mitarbeitertabelle'),
    btnMADienstpl: document.getElementById('btnMADienstpl'),

    // Sidebar
    btnRibbonHide: document.getElementById('btnRibbonAus'),
    btnRibbonShow: document.getElementById('btnRibbonEin'),
    btnDataAreaHide: document.getElementById('btnDaBaAus'),
    btnDataAreaShow: document.getElementById('btnDaBaEin'),

    // Tab Control
    tabButtons: document.querySelectorAll('.tab-button'),
    tabPages: document.querySelectorAll('.tab-page'),

    // Form Fields (Administrative)
    PersNr: document.getElementById('PersNr'),
    LEXWare_ID: document.getElementById('LEXWare_ID'),
    IstAktiv: document.getElementById('IstAktiv'),
    IstSubunternehmer: document.getElementById('IstSubunternehmer'),

    // Personal Data
    Nachname: document.getElementById('Nachname'),
    Vorname: document.getElementById('Vorname'),
    Geschlecht: document.getElementById('Geschlecht'),
    Geb_Dat: document.getElementById('Geb_Dat'),
    Geb_Ort: document.getElementById('Geb_Ort'),
    Geb_Name: document.getElementById('Geb_Name'),
    Staatsang: document.getElementById('Staatsang'),

    // Address
    Strasse: document.getElementById('Strasse'),
    Nr: document.getElementById('Nr'),
    PLZ: document.getElementById('PLZ'),
    Ort: document.getElementById('Ort'),
    Land: document.getElementById('Land'),
    Bundesland: document.getElementById('Bundesland'),

    // Contact
    Tel_Mobil: document.getElementById('Tel_Mobil'),
    Tel_Festnetz: document.getElementById('Tel_Festnetz'),
    Email: document.getElementById('Email'),

    // Bank Data
    Auszahlungsart: document.getElementById('Auszahlungsart'),
    Bankname: document.getElementById('Bankname'),
    Bankleitzahl: document.getElementById('Bankleitzahl'),
    Kontonummer: document.getElementById('Kontonummer'),
    BIC: document.getElementById('BIC'),
    IBAN: document.getElementById('IBAN'),

    // Employment
    Anstellungsart: document.getElementById('Anstellungsart'),
    Eintrittsdatum: document.getElementById('Eintrittsdatum'),
    Austrittsdatum: document.getElementById('Austrittsdatum'),
    Kostenstelle: document.getElementById('Kostenstelle'),
    Eigener_PKW: document.getElementById('Eigener_PKW'),

    // Badge/ID
    DienstausweisNr: document.getElementById('DienstausweisNr'),
    Ausweis_Endedatum: document.getElementById('Ausweis_Endedatum'),
    Ausweis_Funktion: document.getElementById('Ausweis_Funktion'),
    Epin_DFB: document.getElementById('Epin_DFB'),
    Bewacher_ID: document.getElementById('Bewacher_ID'),

    // Image
    MA_Bild: document.getElementById('MA_Bild'),

    // Hidden Fields
    DiDatumAb: document.getElementById('DiDatumAb'),
    lbl_ab: document.getElementById('lbl_ab'),

    // List
    lstMATable: document.getElementById('lst_MA_tbody')
  };

  // ============================================
  // FIELD MAPPING (ControlName -> DOM Element)
  // ============================================
  const fieldMap = {
    ID: dom.PersNr,
    Nachname: dom.Nachname,
    Vorname: dom.Vorname,
    Geschlecht: dom.Geschlecht,
    Geb_Dat: dom.Geb_Dat,
    Geb_Ort: dom.Geb_Ort,
    Geb_Name: dom.Geb_Name,
    Staatsang: dom.Staatsang,
    Strasse: dom.Strasse,
    Nr: dom.Nr,
    PLZ: dom.PLZ,
    Ort: dom.Ort,
    Land: dom.Land,
    Bundesland: dom.Bundesland,
    Tel_Mobil: dom.Tel_Mobil,
    Tel_Festnetz: dom.Tel_Festnetz,
    Email: dom.Email,
    Auszahlungsart: dom.Auszahlungsart,
    Bankname: dom.Bankname,
    Bankleitzahl: dom.Bankleitzahl,
    Kontonummer: dom.Kontonummer,
    BIC: dom.BIC,
    IBAN: dom.IBAN,
    Anstellungsart: dom.Anstellungsart,
    Eintrittsdatum: dom.Eintrittsdatum,
    Austrittsdatum: dom.Austrittsdatum,
    Kostenstelle: dom.Kostenstelle,
    Eigener_PKW: dom.Eigener_PKW,
    DienstausweisNr: dom.DienstausweisNr,
    Ausweis_Endedatum: dom.Ausweis_Endedatum,
    Ausweis_Funktion: dom.Ausweis_Funktion,
    Epin_DFB: dom.Epin_DFB,
    Bewacher_ID: dom.Bewacher_ID,
    IstAktiv: dom.IstAktiv,
    IstSubunternehmer: dom.IstSubunternehmer,
    LEXWare_ID: dom.LEXWare_ID
  };

  // ============================================
  // INITIALIZATION
  // ============================================
  function init() {
    console.log('Initializing frm_MA_Mitarbeiterstamm WebForm...');
    setupEventListeners();
    setupTabNavigation();
    setupBridgeListeners();
    setupSubFormCommunication();
    setVersionLabel();

    // Request initial data from Access via Bridge
    // This triggers LoadForm in mod_N_WebForm_Handler VBA module
    const loadResult = window.Bridge.callAccess('LoadForm', {
      formName: 'frm_MA_Mitarbeiterstamm',
      recordId: 0 // 0 = load first active employee
    });

    console.log('LoadForm call sent to Access, waiting for loadForm event...');
  }

  // ============================================
  // BRIDGE LISTENERS (Access -> Browser)
  // ============================================
  function setupBridgeListeners() {
    // Load Form Data (fired after LoadForm() call to VBA)
    // Payload: [currentRecord, recordListArray]
    window.Bridge.on('loadForm', (payload) => {
      console.log('loadForm event received from mod_N_WebForm_Handler');

      try {
        // payload[0] = currentRecord, payload[1] = recordList
        if (payload && payload.length >= 1) {
          const currentRecord = payload[0];
          const recordList = payload.length > 1 ? payload[1] : [];

          state.currentRecord = currentRecord;
          populateFormFields(currentRecord);
          console.log('Form populated with record ID:', currentRecord?.ID);

          state.recordList = recordList;
          populateEmployeeList(recordList);
          console.log('Employee list populated with', recordList.length, 'records');

          state.isDirty = false;
        } else {
          console.warn('loadForm payload invalid:', payload);
        }
      } catch (e) {
        console.error('Error in loadForm handler:', e);
        showErrorMessage('Fehler beim Laden der Formulardaten: ' + e.message);
      }
    });

    // Event: Record Changed (after navigation)
    // Payload: [newRecord]
    window.Bridge.on('recordChanged', (payload) => {
      console.log('recordChanged event received');

      try {
        if (payload && payload.length > 0) {
          const newRecord = payload[0];
          state.currentRecord = newRecord;
          populateFormFields(newRecord);
          state.isDirty = false;

          console.log('Record changed to ID:', newRecord?.ID);
        }
      } catch (e) {
        console.error('Error in recordChanged handler:', e);
      }
    });

    // Event: Record Saved
    // Payload: [recordId]
    window.Bridge.on('recordSaved', (payload) => {
      console.log('recordSaved event received');

      try {
        if (payload && payload.length > 0) {
          const recordId = payload[0];
          state.isDirty = false;
          showSuccessMessage(`Datensatz #${recordId} gespeichert`);

          // Re-enable Save Button
          if (dom.btnSave) {
            dom.btnSave.disabled = false;
            dom.btnSave.textContent = 'Speichern';
          }
        }
      } catch (e) {
        console.error('Error in recordSaved handler:', e);
      }
    });

    // Event: Record Deleted
    // Payload: [recordId]
    window.Bridge.on('recordDeleted', (payload) => {
      console.log('recordDeleted event received');

      try {
        if (payload && payload.length > 0) {
          const recordId = payload[0];
          showSuccessMessage(`Datensatz #${recordId} gelöscht. Nächster Datensatz wird geladen...`);
          // Die VBA-Funktion lädt automatisch den nächsten Datensatz
        }
      } catch (e) {
        console.error('Error in recordDeleted handler:', e);
      }
    });

    // Event: Error from Access
    // Payload: [errorMessage]
    window.Bridge.on('error', (payload) => {
      console.error('error event from Access:', payload);

      try {
        if (payload && payload.length > 0) {
          showErrorMessage(payload[0] || 'Ein Fehler ist aufgetreten');
        } else {
          showErrorMessage('Ein unbekannter Fehler ist aufgetreten');
        }

        // Re-enable Save Button (falls disabled)
        if (dom.btnSave && dom.btnSave.disabled) {
          dom.btnSave.disabled = false;
          dom.btnSave.textContent = 'Speichern';
        }
      } catch (e) {
        console.error('Error in error handler:', e);
      }
    });

    // Event: Form Closed
    window.Bridge.on('formClosed', () => {
      console.log('formClosed event from Access');
    });

    console.log('Bridge listeners setup complete');
  }

  // ============================================
  // SUBFORM COMMUNICATION (PostMessage)
  // ============================================
  function setupSubFormCommunication() {
    // Listen für Messages von SubForms
    window.addEventListener('message', (event) => {
      console.log('Parent received message from SubForm:', event.data);

      const data = event.data;

      // Menu Navigation
      if (data.type === 'MENU_OPEN_FORM') {
        const formName = data.formName;
        console.log(`Menü: Form ${formName} soll geöffnet werden`);
        // Hier könnte weitere Logik folgen (z.B. Modal öffnen)
      }

      // Ersatz-Email Daten geändert
      if (data.type === 'ERSATZ_EMAIL_CHANGED') {
        console.log(`Ersatz-Email geändert für MA #${data.empId}:`, data.emails);
        // Hier könnte Speichern ausgelöst werden
        state.isDirty = true;
      }

      // SubForm signalisiert Ready
      if (data.type === 'SUBFORM_READY') {
        console.log(`SubForm ready: ${data.source}`);

        // Wenn ErsatzEmail SubForm ready ist, sende initiale Daten
        if (data.source === 'sub_MA_ErsatzEmail' && state.currentRecord) {
          sendDataToSubForm('sub_MA_ErsatzEmail', {
            type: 'LOAD_ERSATZ_EMAIL',
            empId: state.currentRecord.ID,
            emails: [] // TODO: Daten von Access laden
          });
        }
      }
    });

    console.log('SubForm communication setup complete');
  }

  // ============================================
  // HELPER: SEND DATA TO SUBFORM
  // ============================================
  function sendDataToSubForm(subFormId, data) {
    const iframe = document.getElementById(`iframe-${subFormId}`);
    if (iframe && iframe.contentWindow) {
      iframe.contentWindow.postMessage(data, '*');
      console.log(`Data sent to SubForm ${subFormId}:`, data);
    } else {
      console.warn(`SubForm iframe not found: ${subFormId}`);
    }
  }

  // ============================================
  // EVENT LISTENERS
  // ============================================
  function setupEventListeners() {
    // Navigation Buttons
    dom.navFirst?.addEventListener('click', () => navigateRecord('first'));
    dom.navPrev?.addEventListener('click', () => navigateRecord('prev'));
    dom.navNext?.addEventListener('click', () => navigateRecord('next'));
    dom.navLast?.addEventListener('click', () => navigateRecord('last'));

    // Action Buttons
    dom.btnSave?.addEventListener('click', saveCurrentRecord);
    dom.btnDelete?.addEventListener('click', deleteCurrentRecord);
    dom.btnPrint?.addEventListener('click', () => {
      window.Bridge.callAccess('PrintEmployeeList', {});
    });
    dom.btnTimeAcct?.addEventListener('click', () => {
      window.Bridge.callAccess('OpenTimeAccountForm', { empId: state.currentRecord?.ID });
    });
    dom.btnZKFest?.addEventListener('click', () => {
      window.Bridge.callAccess('OpenTimeAccountFixed', { empId: state.currentRecord?.ID });
    });
    dom.btnZKMini?.addEventListener('click', () => {
      window.Bridge.callAccess('OpenTimeAccountMini', { empId: state.currentRecord?.ID });
    });
    dom.btnStaffTable?.addEventListener('click', () => {
      window.Bridge.callAccess('OpenStaffTable', {});
    });

    // Sidebar Toggle Buttons
    dom.btnRibbonHide?.addEventListener('click', () => toggleSidebar(false));
    dom.btnRibbonShow?.addEventListener('click', () => toggleSidebar(true));
    dom.btnDataAreaHide?.addEventListener('click', () => toggleDataArea(false));
    dom.btnDataAreaShow?.addEventListener('click', () => toggleDataArea(true));

    // Form Field Changes
    const inputFields = document.querySelectorAll('.field-input, input[type="text"], input[type="email"], input[type="tel"], input[type="date"], input[type="checkbox"]');
    inputFields.forEach(field => {
      field.addEventListener('change', () => {
        state.isDirty = true;

        const fieldName = field.name || field.id;
        const fieldValue = field.type === 'checkbox' ? field.checked : field.value;

        console.log(`Field changed: ${fieldName} = ${fieldValue}`);

        // Trigger field change event to VBA via Bridge
        // VBA module can perform validation/logging
        window.Bridge.callAccess('FieldChanged', {
          fieldName: fieldName,
          value: fieldValue,
          recordId: state.currentRecord?.ID
        });

        // Update local state
        if (state.currentRecord) {
          state.currentRecord[fieldName] = fieldValue;
        }
      });

      // Real-time feedback for important fields
      if (field.id === 'Nachname' || field.id === 'Vorname' || field.id === 'Email') {
        field.addEventListener('input', (e) => {
          // Mark as dirty on keystroke
          state.isDirty = true;

          // Email validation
          if (field.id === 'Email') {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (e.target.value && !emailRegex.test(e.target.value)) {
              field.style.borderColor = '#ff9800';
            } else {
              field.style.borderColor = '#999';
            }
          }
        });
      }
    });
  }

  // ============================================
  // TAB NAVIGATION
  // ============================================
  function setupTabNavigation() {
    dom.tabButtons.forEach(btn => {
      btn.addEventListener('click', (e) => {
        const tabId = e.target.getAttribute('data-tab');
        switchTab(tabId);
      });
    });
  }

  function switchTab(tabId) {
    // Hide all pages
    dom.tabPages.forEach(page => page.classList.remove('tab-active'));

    // Deactivate all buttons
    dom.tabButtons.forEach(btn => btn.classList.remove('tab-active'));

    // Show selected page
    const selectedPage = document.getElementById(tabId);
    if (selectedPage) {
      selectedPage.classList.add('tab-active');
    }

    // Activate button
    const selectedBtn = document.querySelector(`[data-tab="${tabId}"]`);
    if (selectedBtn) {
      selectedBtn.classList.add('tab-active');
    }

    state.currentTab = tabId;
  }

  // ============================================
  // FORM DATA POPULATION
  // ============================================
  function populateFormFields(record) {
    if (!record) return;

    Object.keys(fieldMap).forEach(fieldName => {
      const element = fieldMap[fieldName];
      if (!element) return;

      const value = record[fieldName];

      if (element.type === 'checkbox') {
        element.checked = !!value;
      } else {
        element.value = value || '';
      }
    });

    // Handle image
    if (record.MA_Bild && dom.MA_Bild) {
      const img = dom.MA_Bild.querySelector('img');
      if (img) {
        // Assume base64 or URL from Access
        img.src = record.MA_Bild;
      }
    }

    state.isDirty = false;
  }

  // ============================================
  // EMPLOYEE LIST POPULATION
  // ============================================
  function populateEmployeeList(records) {
    if (!dom.lstMATable) return;

    dom.lstMATable.innerHTML = '';

    records.forEach((record, index) => {
      const row = document.createElement('tr');
      row.dataset.recordId = record.ID;
      row.dataset.index = index;

      row.addEventListener('click', () => {
        document.querySelectorAll('.employee-table tbody tr').forEach(r => {
          r.classList.remove('selected');
        });
        row.classList.add('selected');

        // Navigate to this record
        state.currentRecord = record;
        populateFormFields(record);
        state.isDirty = false;
      });

      row.innerHTML = `
        <td>${record.ID || ''}</td>
        <td>${record.Nachname || ''}</td>
        <td>${record.Vorname || ''}</td>
        <td>${record.Ort || ''}</td>
      `;

      dom.lstMATable.appendChild(row);
    });
  }

  // ============================================
  // NAVIGATION FUNCTIONS
  // ============================================
  function navigateRecord(direction) {
    // Delegate to VBA module via Bridge for proper record locking/validation
    console.log(`navigateRecord: ${direction}`);

    window.Bridge.callAccess('NavigateRecord', {
      direction: direction  // 'first', 'last', 'next', 'prev'
    });

    // The VBA module will fire 'recordChanged' event when done
  }

  function gatherFormData() {
    // Sammelt alle Formulardaten von Inputs
    const formData = {};

    // Alle Input-Felder erfassen
    const inputFields = document.querySelectorAll('.field-input, input[type="text"], input[type="email"], input[type="tel"], input[type="date"], input[type="checkbox"]');

    inputFields.forEach(field => {
      const fieldName = field.name || field.id;
      if (fieldName && fieldName.length > 0) {
        if (field.type === 'checkbox') {
          formData[fieldName] = field.checked;
        } else {
          formData[fieldName] = field.value || '';
        }
      }
    });

    // ID hinzufügen
    if (state.currentRecord && state.currentRecord.ID) {
      formData['ID'] = state.currentRecord.ID;
    }

    console.log('Gathered form data:', formData);
    return formData;
  }

  function saveCurrentRecord() {
    if (!state.currentRecord) {
      showErrorMessage('Kein Datensatz zum Speichern ausgewählt');
      return;
    }

    // Sammle Formulardaten
    const recordData = gatherFormData();

    console.log(`Saving record ID: ${recordData.ID}`);

    // Disable Save-Button während Speichern
    if (dom.btnSave) {
      dom.btnSave.disabled = true;
      dom.btnSave.textContent = 'Speichert...';
    }

    // Sende zu VBA
    window.Bridge.callAccess('SaveRecord', recordData);

    // VBA sendet 'recordSaved' oder 'error' Event zurück
    // Button wird in Event-Handler re-enabled
  }

  function deleteCurrentRecord() {
    if (!state.currentRecord) {
      showErrorMessage('Kein Datensatz zum Löschen ausgewählt');
      return;
    }

    const fullName = `${state.currentRecord.Nachname || ''}, ${state.currentRecord.Vorname || ''}`.trim();
    const confirmMsg = `Möchten Sie den Mitarbeiter "${fullName}" wirklich löschen?\n\nDiese Aktion kann nicht rückgängig gemacht werden.`;

    if (confirm(confirmMsg)) {
      console.log(`Deleting record ID: ${state.currentRecord.ID}`);

      window.Bridge.callAccess('DeleteRecord', {
        recordId: state.currentRecord.ID
      });

      // VBA module will fire 'recordDeleted' and load next record
    }
  }

  // ============================================
  // SIDEBAR TOGGLE
  // ============================================
  function toggleSidebar(show) {
    const sidebar = document.querySelector('.sidebar');
    if (show) {
      sidebar.style.display = 'flex';
    } else {
      sidebar.style.display = 'none';
    }
  }

  function toggleDataArea(show) {
    const contentArea = document.querySelector('.content-area');
    if (show) {
      contentArea.style.display = 'flex';
    } else {
      contentArea.style.display = 'none';
    }
  }

  // ============================================
  // UTILITY FUNCTIONS
  // ============================================
  function setVersionLabel() {
    const now = new Date();
    dom.versionLabel.textContent = `v1.0 (${now.toLocaleDateString('de-DE')})`;
  }

  function showErrorMessage(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    errorDiv.style.cssText = `
      position: fixed;
      top: 60px;
      right: 10px;
      background-color: #d84848;
      color: white;
      padding: 12px;
      border-radius: 3px;
      z-index: 1000;
      font-size: 11px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    `;
    dom.app.appendChild(errorDiv);

    setTimeout(() => {
      errorDiv.remove();
    }, 5000);
  }

  function showSuccessMessage(message) {
    const successDiv = document.createElement('div');
    successDiv.className = 'success-message';
    successDiv.textContent = message;
    successDiv.style.cssText = `
      position: fixed;
      top: 60px;
      right: 10px;
      background-color: #48d84a;
      color: white;
      padding: 12px;
      border-radius: 3px;
      z-index: 1000;
      font-size: 11px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    `;
    dom.app.appendChild(successDiv);

    setTimeout(() => {
      successDiv.remove();
    }, 3000);
  }

  // ============================================
  // START
  // ============================================
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
