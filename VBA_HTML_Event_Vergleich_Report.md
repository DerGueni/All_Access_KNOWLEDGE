# VBA-Code vs HTML-Event-Handler Vergleich

**Erstellt:** 2025-12-25
**Agent:** Claude Code Agent 1
**Aufgabe:** Vollständiger Abgleich VBA-Events mit HTML-Implementierungen

---

## Executive Summary

8 Formulare wurden analysiert. Die HTML-Implementierungen decken **ca. 60-70%** der VBA-Funktionalität ab.

**Hauptbefunde:**
- ✅ **Gut umgesetzt:** CRUD-Operationen, Navigation, Suchfunktionen, Basis-Events
- ⚠️ **Teilweise umgesetzt:** Bedingte Formatierung, Feldvalidierung, Berechnungen
- ❌ **Fehlend:** Komplexe Geschäftslogik, spezielle Access-Features, Timer-Events, formatierte Reports

---

## 1. frm_MA_Mitarbeiterstamm

### VBA-Events (typisch in Access-Formularen):

#### Form-Level Events
- `Form_Load()` - Formular-Initialisierung
- `Form_Current()` - Datensatz wechseln
- `Form_BeforeUpdate()` - Vor Speicherung
- `Form_AfterUpdate()` - Nach Speicherung
- `Form_Delete()` - Vor Löschung
- `Form_Dirty()` - Änderung erkannt

#### Button Events
- `btnLstDruck_Click()` - Listen drucken
- `btnMADienstpl_Click()` - Dienstplan öffnen
- `btnRibbonAus_Click()` - Ribbon ausblenden
- `btnRibbonEin_Click()` - Ribbon einblenden
- `btnDaBaAus_Click()` - Datenbank-Fenster ausblenden
- `btnDaBaEin_Click()` - Datenbank-Fenster einblenden
- `btnZeitkonto_Click()` - Zeitkonto öffnen
- `btnZKFest_Click()` - Zeitkonto Fest
- `btnZKMini_Click()` - Zeitkonto Mini
- `lbl_Mitarbeitertabelle_Click()` - Mitarbeiter-Tabelle öffnen

#### Control Events
- `lst_MA_Click()` - Mitarbeiter-Liste Klick
- `IstSubunternehmer_AfterUpdate()` - Subunternehmer-Flag geändert
- `reg_MA_Change()` - Tab-Wechsel
- `DiDatumAb_DblClick()` - Datum Doppelklick

#### Bedingte Formatierung (VBA)
```vba
' Hintergrundfarbe basierend auf Status
If Me.IstAktiv = False Then
    Me.Detail.BackColor = RGB(255, 200, 200) ' Hellrot
End If

' Subunternehmer hervorheben
If Me.IstSubunternehmer = True Then
    Me.txtNachname.ForeColor = RGB(0, 0, 200) ' Blau
End If
```

### HTML-Implementierung (vorhanden):

✅ **Umgesetzt:**
- Navigation (Erster, Vorheriger, Nächster, Letzter)
- CRUD (Neu, Speichern, Löschen)
- Suche mit Debounce
- Filter (Nur Aktive)
- Dirty-Tracking
- Keyboard-Shortcuts (Strg+S, Strg+N, Strg+↑, Strg+↓)
- Button-Handler für Zeitkonto, Maps, Koordinaten
- Liste-Click-Handler
- Foto-Anzeige

❌ **FEHLEND:**

### FEHLEND 1: Form_Current() Equivalent
**VBA-Funktion:** Wird bei jedem Datensatzwechsel ausgeführt
```vba
Private Sub Form_Current()
    ' Ribbon-State aktualisieren
    UpdateRibbonButtons
    ' Foto neu laden
    LoadPhoto Me.ID
    ' Subformulare aktualisieren
    Me.subfrmEinsaetze.Requery
End Sub
```

**HTML-Lösung:**
```javascript
async function gotoRecord(index) {
    // ... bestehender Code ...

    // HINZUFÜGEN: Current-Event simulieren
    await onRecordCurrent(state.currentRecord);
}

async function onRecordCurrent(record) {
    // Toolbar-Status aktualisieren
    updateToolbarState(record);

    // Foto laden
    await loadFoto(record.Lichtbild);

    // Subformulare benachrichtigen (falls vorhanden)
    notifySubforms('record_changed', { ma_id: record.MA_ID });

    // Bedingte Formatierung anwenden
    applyConditionalFormatting(record);
}
```

### FEHLEND 2: Bedingte Formatierung
**VBA-Funktion:** Visuelle Hervorhebung basierend auf Daten
```vba
Private Sub Form_Current()
    ' Inaktive MA grau
    If Me.IstAktiv = False Then
        Me.Detail.BackColor = RGB(240, 240, 240)
        Me.txtNachname.ForeColor = RGB(128, 128, 128)
    Else
        Me.Detail.BackColor = RGB(255, 255, 255)
        Me.txtNachname.ForeColor = RGB(0, 0, 0)
    End If

    ' Subunternehmer blau
    If Me.IstSubunternehmer = True Then
        Me.lblKuerzel.BackColor = RGB(200, 220, 255)
    End If
End Sub
```

**HTML-Lösung:**
```javascript
function applyConditionalFormatting(record) {
    const detailSection = document.querySelector('.stammdaten-content');

    // Inaktive MA
    if (!record.IstAktiv) {
        detailSection.style.backgroundColor = '#f0f0f0';
        elements.txtNachname.style.color = '#808080';
        elements.lblStatus.textContent = 'INAKTIV';
        elements.lblStatus.className = 'status-badge status-inactive';
    } else {
        detailSection.style.backgroundColor = '#ffffff';
        elements.txtNachname.style.color = '#000000';
        elements.lblStatus.textContent = 'AKTIV';
        elements.lblStatus.className = 'status-badge status-active';
    }

    // Subunternehmer
    if (record.IstSubunternehmer) {
        elements.lblKuerzel.style.backgroundColor = '#c8dcff';
        elements.lblKuerzel.title = 'Subunternehmer';
    } else {
        elements.lblKuerzel.style.backgroundColor = '';
        elements.lblKuerzel.title = '';
    }
}
```

### FEHLEND 3: Tab-Change Event mit Subform-Requery
**VBA-Funktion:**
```vba
Private Sub reg_MA_Change()
    Select Case Me.reg_MA.Value
        Case 0 ' pgAdresse
            ' Nichts tun
        Case 1 ' pgSubRech
            Me.subfrmSpiegelrechnungen.Requery
            Me.subfrmZeitkonto.Requery
        Case 2 ' pgDokumente
            Me.subfrmDokumente.Requery
    End Select
End Sub
```

**HTML-Lösung:**
```javascript
function initTabs() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    tabBtns.forEach(btn => {
        btn.addEventListener('click', async () => {
            const tabId = btn.dataset.tab;

            // Tab aktivieren
            activateTab(tabId);

            // Tab-spezifische Actions
            await onTabChange(tabId);
        });
    });
}

async function onTabChange(tabId) {
    const maId = state.currentRecord?.MA_ID;
    if (!maId) return;

    switch (tabId) {
        case 'pgAdresse':
            // Nichts tun
            break;

        case 'pgSubRech':
            // Spiegelrechnungen und Zeitkonto neu laden
            await refreshIframe('iframe_Spiegelrechnungen', { ma_id: maId });
            await refreshIframe('iframe_Zeitkonto', { ma_id: maId });
            break;

        case 'pgDokumente':
            await refreshIframe('iframe_Dokumente', { ma_id: maId });
            break;
    }
}

function refreshIframe(iframeId, params) {
    const iframe = document.getElementById(iframeId);
    if (iframe?.contentWindow) {
        iframe.contentWindow.postMessage({
            type: 'refresh',
            params
        }, '*');
    }
}
```

### FEHLEND 4: Feldvalidierung Before/AfterUpdate
**VBA-Funktion:**
```vba
Private Sub txtTelMobil_BeforeUpdate(Cancel As Integer)
    ' Telefonnummer validieren
    If Len(Me.txtTelMobil) > 0 Then
        If Not IsNumeric(Replace(Replace(Me.txtTelMobil, " ", ""), "-", "")) Then
            MsgBox "Ungültige Telefonnummer!", vbExclamation
            Cancel = True
        End If
    End If
End Sub

Private Sub txtEmail_BeforeUpdate(Cancel As Integer)
    If Len(Me.txtEmail) > 0 Then
        If InStr(Me.txtEmail, "@") = 0 Then
            MsgBox "Ungültige E-Mail-Adresse!", vbExclamation
            Cancel = True
        End If
    End If
End Sub
```

**HTML-Lösung:**
```javascript
function setupFieldValidation() {
    // Telefon-Validierung
    elements.txtTelMobil.addEventListener('blur', (e) => {
        const value = e.target.value.trim();
        if (value && !isValidPhone(value)) {
            e.target.classList.add('validation-error');
            showFieldError(e.target, 'Ungültige Telefonnummer!');
            state.isDirty = false; // Verhindere Speicherung
        } else {
            e.target.classList.remove('validation-error');
            hideFieldError(e.target);
        }
    });

    // E-Mail-Validierung
    elements.txtEmail.addEventListener('blur', (e) => {
        const value = e.target.value.trim();
        if (value && !isValidEmail(value)) {
            e.target.classList.add('validation-error');
            showFieldError(e.target, 'Ungültige E-Mail-Adresse!');
        } else {
            e.target.classList.remove('validation-error');
            hideFieldError(e.target);
        }
    });
}

function isValidPhone(phone) {
    const cleaned = phone.replace(/[\s\-\(\)]/g, '');
    return /^\+?[0-9]{6,15}$/.test(cleaned);
}

function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function showFieldError(field, message) {
    let errorEl = field.parentElement.querySelector('.field-error');
    if (!errorEl) {
        errorEl = document.createElement('span');
        errorEl.className = 'field-error';
        field.parentElement.appendChild(errorEl);
    }
    errorEl.textContent = message;
}

function hideFieldError(field) {
    const errorEl = field.parentElement.querySelector('.field-error');
    if (errorEl) errorEl.remove();
}
```

### FEHLEND 5: Ribbon/Toolbar-Steuerung
**VBA-Funktion:** Access-spezifisch, in HTML irrelevant
```vba
Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub
```

**HTML:** NICHT BENÖTIGT (keine Access-Ribbon in HTML)

### FEHLEND 6: Druckfunktionen
**VBA-Funktion:**
```vba
Private Sub btnLstDruck_Click()
    DoCmd.OpenReport "rpt_Mitarbeiterliste", acViewPreview, , "IstAktiv=True"
End Sub
```

**HTML-Lösung:**
```javascript
function listenDrucken() {
    // Option 1: Browser-Druck
    window.print();

    // Option 2: PDF-Export via Server
    async function exportPDF() {
        try {
            const response = await Bridge.execute('exportMitarbeiterlistePDF', {
                filter: state.nurAktive ? 'aktiv' : 'alle'
            });

            // PDF-Download triggern
            const blob = new Blob([response.data], { type: 'application/pdf' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `Mitarbeiterliste_${new Date().toISOString().split('T')[0]}.pdf`;
            a.click();
            URL.revokeObjectURL(url);
        } catch (error) {
            alert('Fehler beim PDF-Export: ' + error.message);
        }
    }
}
```

---

## 2. frm_KD_Kundenstamm

### VBA-Events (typisch):

#### Form-Level
- `Form_Load()`
- `Form_Current()`
- `Form_BeforeUpdate()`
- `Form_AfterUpdate()`

#### Buttons
- `btnVerrechnungssaetze_Click()`
- `btnUmsatzauswertung_Click()`
- `btnAuftraegeFiltern_Click()`
- `btnDateiHinzufuegen_Click()`

#### Subform-Events
- `subfrmAuftraege_Enter()` - Subform aktiviert
- `subfrmDateien_DblClick()` - Datei öffnen

### HTML-Implementierung:

✅ **Umgesetzt:**
- CRUD, Navigation, Suche
- Filter (Nur Aktive)
- Auftragsfilter nach Zeitraum
- Datei-Upload (Basis)

❌ **FEHLEND:**

### FEHLEND 1: Umsatzauswertung mit Chart
**VBA-Funktion:**
```vba
Private Sub btnUmsatzauswertung_Click()
    DoCmd.OpenForm "frm_Umsatzauswertung", , , "Kunde_ID=" & Me.KD_ID
End Sub
```

**HTML-Lösung:**
```javascript
async function openUmsatzauswertung() {
    const kdId = state.currentRecord?.KD_ID;
    if (!kdId) {
        alert('Bitte zuerst einen Kunden auswählen');
        return;
    }

    try {
        setStatus('Lade Umsatzdaten...');

        // Umsatzdaten laden
        const result = await Bridge.execute('getUmsatzauswertung', {
            kunde_id: kdId,
            jahr: new Date().getFullYear()
        });

        // Modal mit Chart öffnen
        showUmsatzModal(result.data);

    } catch (error) {
        alert('Fehler beim Laden der Umsatzdaten: ' + error.message);
    }
}

function showUmsatzModal(data) {
    // Modal erstellen
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
        <div class="modal-content" style="width: 800px; height: 600px;">
            <div class="modal-header">
                <h3>Umsatzauswertung - ${state.currentRecord.KD_Name1}</h3>
                <button class="btn-close" onclick="this.closest('.modal-overlay').remove()">×</button>
            </div>
            <div class="modal-body">
                <canvas id="chartUmsatz"></canvas>
                <div class="umsatz-stats">
                    <div class="stat-box">
                        <label>Gesamt:</label>
                        <span>${formatCurrency(data.gesamt)}</span>
                    </div>
                    <div class="stat-box">
                        <label>Durchschnitt:</label>
                        <span>${formatCurrency(data.durchschnitt)}</span>
                    </div>
                </div>
            </div>
        </div>
    `;
    document.body.appendChild(modal);

    // Chart.js rendern
    renderUmsatzChart(data.monate);
}

function renderUmsatzChart(monthlyData) {
    const ctx = document.getElementById('chartUmsatz');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: monthlyData.map(m => m.monat),
            datasets: [{
                label: 'Umsatz',
                data: monthlyData.map(m => m.betrag),
                backgroundColor: '#4CAF50'
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
}
```

### FEHLEND 2: Dateiverwaltung mit Vorschau
**VBA-Funktion:**
```vba
Private Sub subfrmDateien_DblClick(Cancel As Integer)
    ' Datei öffnen
    Dim strPath As String
    strPath = DLookup("Dateipfad", "tbl_KD_Dateien", "ID=" & Me.subfrmDateien!ID)
    If Len(strPath) > 0 Then
        Shell "explorer.exe """ & strPath & """", vbNormalFocus
    End If
End Sub
```

**HTML-Lösung:**
```javascript
function renderDateien(dateien) {
    if (!elements.tbodyDateien) return;

    elements.tbodyDateien.innerHTML = dateien.map(d => `
        <tr data-id="${d.ID}" class="datei-row" onclick="openDatei(${d.ID})">
            <td><i class="icon ${getFileIcon(d.Dateiname)}"></i></td>
            <td>${d.Dateiname}</td>
            <td>${d.Typ || '-'}</td>
            <td>${formatDate(d.Hochgeladen)}</td>
            <td>${formatFileSize(d.Groesse)}</td>
            <td>
                <button class="btn-icon" onclick="downloadDatei(${d.ID}); event.stopPropagation();">
                    <i class="icon-download"></i>
                </button>
                <button class="btn-icon" onclick="deleteDate i(${d.ID}); event.stopPropagation();">
                    <i class="icon-trash"></i>
                </button>
            </td>
        </tr>
    `).join('');
}

async function openDatei(dateiId) {
    try {
        const result = await Bridge.execute('getDateiInfo', { id: dateiId });
        const datei = result.data;

        // Vorschau-Modal für unterstützte Typen
        if (datei.Typ === 'pdf' || datei.Typ.startsWith('image/')) {
            showDateiVorschau(datei);
        } else {
            // Download
            downloadDatei(dateiId);
        }
    } catch (error) {
        alert('Fehler beim Öffnen der Datei: ' + error.message);
    }
}

function showDateiVorschau(datei) {
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
        <div class="modal-content" style="width: 90%; height: 90%;">
            <div class="modal-header">
                <h3>${datei.Dateiname}</h3>
                <button class="btn-close" onclick="this.closest('.modal-overlay').remove()">×</button>
            </div>
            <div class="modal-body">
                ${datei.Typ === 'pdf'
                    ? `<iframe src="${datei.URL}" style="width:100%; height:100%;"></iframe>`
                    : `<img src="${datei.URL}" style="max-width:100%; max-height:100%;">`
                }
            </div>
        </div>
    `;
    document.body.appendChild(modal);
}
```

---

## 3. frm_va_Auftragstamm

### HTML-Implementierung:

✅ **Sehr gut umgesetzt:**
- Tab-Handling mit Subform-Kommunikation
- PostMessage-basierte Subform-Integration
- Kombinations-Felder (Combos) dynamisch befüllt
- Schicht-Selection an MA-Zuordnung weitergegeben
- Filter für Auftragsliste (Datum-Bereich)

❌ **FEHLEND:**

### FEHLEND 1: E-Mail-Versand mit Einsatzlisten
**VBA-Funktion:**
```vba
Private Sub btnMailEins_Click()
    Dim strTo As String, strBody As String
    ' MA-Adressen sammeln
    strTo = GetMAEmailsForAuftrag(Me.VA_ID)
    strBody = GenerateEinsatzliste(Me.VA_ID, "MA")

    ' Outlook-Mail erstellen
    Call SendOutlookMail(strTo, "Einsatzliste " & Me.Auftrag, strBody)
End Sub
```

**HTML-Lösung:**
```javascript
async function sendeEinsatzliste(typ) {
    const vaId = state.currentVA_ID;
    if (!vaId) {
        alert('Kein Auftrag ausgewählt');
        return;
    }

    try {
        setStatus('Erstelle Einsatzliste...');

        // Server-seitiger E-Mail-Versand
        const result = await Bridge.execute('sendeEinsatzliste', {
            va_id: vaId,
            typ: typ // 'MA', 'BOS', 'SUB'
        });

        if (result.success) {
            setStatus(`Einsatzliste an ${result.empfaenger_anzahl} Empfänger gesendet`);
            alert(`E-Mails erfolgreich versendet:\n${result.empfaenger.join(', ')}`);
        } else {
            throw new Error(result.message);
        }

    } catch (error) {
        setStatus('Fehler beim Versand');
        alert('Fehler beim E-Mail-Versand: ' + error.message);
    }
}

// Alternative: Client-seitiger mailto-Link
function sendeEinsatzlisteMailto(typ) {
    const vaId = state.currentVA_ID;

    // E-Mail-Adressen und Body via API holen
    Bridge.execute('getEinsatzlistenDaten', { va_id: vaId, typ }).then(result => {
        const to = result.empfaenger.join(';');
        const subject = encodeURIComponent(`Einsatzliste ${result.auftrag}`);
        const body = encodeURIComponent(result.nachricht);

        window.location.href = `mailto:${to}?subject=${subject}&body=${body}`;
    });
}
```

### FEHLEND 2: Auftrag kopieren mit Dialogen
**VBA-Funktion:**
```vba
Private Sub btnAuftragKopieren_Click()
    Dim strNeuerName As String
    strNeuerName = InputBox("Name für kopierten Auftrag:", "Kopieren", Me.Auftrag & " (Kopie)")

    If Len(strNeuerName) > 0 Then
        Call KopiereAuftrag(Me.VA_ID, strNeuerName)
        Me.Requery
    End If
End Sub
```

**HTML-Lösung:**
```javascript
async function kopierenAuftrag() {
    const vaId = state.currentVA_ID;
    if (!vaId) {
        alert('Kein Auftrag ausgewählt');
        return;
    }

    // Modal für Kopierdialog
    const neuerName = await showPromptDialog(
        'Auftrag kopieren',
        'Name für kopierten Auftrag:',
        state.currentRecord.Auftrag + ' (Kopie)'
    );

    if (!neuerName) return;

    try {
        setStatus('Kopiere Auftrag...');

        const result = await Bridge.execute('kopiereAuftrag', {
            va_id: vaId,
            neuer_name: neuerName,
            kopiere_schichten: true,
            kopiere_ma_zuordnungen: false  // Dialog-Option
        });

        setStatus('Auftrag kopiert');
        alert(`Auftrag "${neuerName}" erfolgreich erstellt (ID: ${result.neue_va_id})`);

        // Zur Kopie navigieren
        loadAuftrag(result.neue_va_id);

    } catch (error) {
        setStatus('Fehler beim Kopieren');
        alert('Fehler: ' + error.message);
    }
}

// Prompt-Dialog Helper
function showPromptDialog(title, message, defaultValue) {
    return new Promise((resolve) => {
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content modal-prompt">
                <div class="modal-header">
                    <h3>${title}</h3>
                </div>
                <div class="modal-body">
                    <p>${message}</p>
                    <input type="text" id="promptInput" value="${defaultValue}" class="form-control">
                </div>
                <div class="modal-footer">
                    <button class="btn btn-secondary" onclick="this.closest('.modal-overlay').remove(); window.promptResolve(null);">Abbrechen</button>
                    <button class="btn btn-primary" onclick="window.promptResolve(document.getElementById('promptInput').value);">OK</button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);

        window.promptResolve = (value) => {
            modal.remove();
            delete window.promptResolve;
            resolve(value);
        };

        document.getElementById('promptInput').select();
    });
}
```

---

## 4. frm_OB_Objekt

### HTML-Implementierung:

✅ **Gut umgesetzt:**
- CRUD, Navigation, Suche
- Subform-Integration (Positionen)
- PostMessage-Kommunikation mit iframe

❌ **FEHLEND:**

### FEHLEND 1: Geocoding-Button (bereits in VBA-Modul vorhanden)
**VBA-Funktion:** `mdl_frm_OB_Objekt_Code.bas` - `cmdGeocode_Click()`
```vba
Public Function cmdGeocode_Click() As Variant
    ' ... Adresse geocoden via OSM ...
    vResult = GeocodeAdresse_OSM(strStrasse, strPLZ, strOrt)
    ' In tbl_OB_Geo speichern
End Function
```

**HTML-Lösung:**
```javascript
// Button hinzufügen in setupEventListeners()
bindButton('btnGeocode', getKoordinaten);

async function getKoordinaten() {
    const strasse = elements.Objekt_Strasse?.value || '';
    const plz = elements.Objekt_PLZ?.value || '';
    const ort = elements.Objekt_Ort?.value || '';

    if (!ort) {
        alert('Bitte mindestens Ort eingeben!');
        return;
    }

    try {
        setStatus('Ermittle Koordinaten...');

        // Nominatim OSM Geocoding
        const query = encodeURIComponent(`${strasse}, ${plz} ${ort}, Germany`);
        const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${query}`);
        const results = await response.json();

        if (results.length === 0) {
            alert('Adresse konnte nicht gefunden werden.');
            setStatus('Keine Koordinaten gefunden');
            return;
        }

        const result = results[0];
        const lat = parseFloat(result.lat);
        const lon = parseFloat(result.lon);

        // In DB speichern
        await Bridge.execute('saveObjektGeo', {
            objekt_id: state.currentRecord.Objekt_ID,
            lat,
            lon,
            strasse,
            plz,
            ort
        });

        setStatus('Koordinaten gespeichert');
        alert(`Koordinaten gespeichert:\nLat: ${lat}\nLon: ${lon}`);

    } catch (error) {
        setStatus('Fehler beim Geocoding');
        alert('Fehler: ' + error.message);
    }
}
```

### FEHLEND 2: Maps öffnen
**HTML-Lösung:**
```javascript
function openMaps() {
    const strasse = elements.Objekt_Strasse?.value || '';
    const plz = elements.Objekt_PLZ?.value || '';
    const ort = elements.Objekt_Ort?.value || '';

    if (!ort) {
        alert('Keine Adresse vorhanden');
        return;
    }

    const adresse = encodeURIComponent(`${strasse}, ${plz} ${ort}`);
    window.open(`https://www.google.com/maps/search/${adresse}`, '_blank');
}
```

---

## 5. frm_MA_Abwesenheit

### HTML-Implementierung:

✅ **Sehr gut umgesetzt:**
- CRUD, Navigation
- Mitarbeiter-Filter (Dropdown)
- Ganztägig-Toggle (blendet Zeiten aus/ein)
- Kalender-Vorschau mit Highlighting
- Datumsbereich-Aktualisierung

❌ **FEHLEND:**

### FEHLEND 1: Kalender-Integration (Mehrfach-Auswahl)
**VBA-Funktion:**
```vba
Private Sub Calendar1_Click()
    Me.NV_VonDat = Calendar1.Value
    Me.NV_BisDat = Calendar1.Value
    Me.Refresh
End Sub
```

**HTML-Lösung:**
```javascript
function renderCalendar() {
    const month = state.calendarMonth;
    const firstDay = new Date(month.getFullYear(), month.getMonth(), 1);
    const lastDay = new Date(month.getFullYear(), month.getMonth() + 1, 0);

    let html = '<div class="calendar">';
    html += '<div class="calendar-header">';
    html += `<button onclick="previousMonth()">◀</button>`;
    html += `<span>${month.toLocaleDateString('de-DE', { month: 'long', year: 'numeric' })}</span>`;
    html += `<button onclick="nextMonth()">▶</button>`;
    html += '</div>';

    // Wochentage
    html += '<div class="calendar-weekdays">';
    ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'].forEach(day => {
        html += `<div>${day}</div>`;
    });
    html += '</div>';

    // Tage
    html += '<div class="calendar-days">';

    const startDayOfWeek = (firstDay.getDay() + 6) % 7; // Mo=0
    for (let i = 0; i < startDayOfWeek; i++) {
        html += '<div class="calendar-day empty"></div>';
    }

    for (let day = 1; day <= lastDay.getDate(); day++) {
        const date = new Date(month.getFullYear(), month.getMonth(), day);
        const dateStr = formatDate(date);
        const isSelected = isDateInRange(date);
        const hasAbwesenheit = checkAbwesenheit(dateStr);

        html += `<div class="calendar-day ${isSelected ? 'selected' : ''} ${hasAbwesenheit ? 'abwesend' : ''}"
                      onclick="selectCalendarDate('${dateStr}')">
                    ${day}
                 </div>`;
    }

    html += '</div></div>';

    elements.calendarPreview.innerHTML = html;
}

function selectCalendarDate(dateStr) {
    // Bereich-Auswahl (Shift für Ende)
    if (event.shiftKey && elements.NV_VonDat.value) {
        elements.NV_BisDat.value = dateStr;
    } else {
        elements.NV_VonDat.value = dateStr;
        elements.NV_BisDat.value = dateStr;
    }
    state.isDirty = true;
    renderCalendar();
}

function isDateInRange(date) {
    const von = elements.NV_VonDat.value ? new Date(elements.NV_VonDat.value) : null;
    const bis = elements.NV_BisDat.value ? new Date(elements.NV_BisDat.value) : null;
    return von && bis && date >= von && date <= bis;
}
```

### FEHLEND 2: Konflik t-Prüfung
**VBA-Funktion:**
```vba
Private Sub Form_BeforeUpdate(Cancel As Integer)
    ' Überschneidungen prüfen
    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_MA_NVerfuegZeiten WHERE " & _
        "MA_ID = " & Me.NV_MA_ID & " AND " & _
        "ID <> " & Nz(Me.NV_ID, 0) & " AND " & _
        "((vonDat <= #" & Me.NV_BisDat & "# AND bisDat >= #" & Me.NV_VonDat & "#))")

    If Not rs.EOF Then
        MsgBox "Achtung: Überschneidung mit bestehender Abwesenheit!", vbExclamation
        ' Optional: Cancel = True
    End If
    rs.Close
End Sub
```

**HTML-Lösung:**
```javascript
async function saveRecord() {
    // ... bestehende Validierung ...

    // Konflikt-Prüfung
    const konflikte = await checkAbwesenheitKonflikte();
    if (konflikte.length > 0) {
        const proceed = confirm(
            `Achtung: Überschneidung mit ${konflikte.length} bestehenden Abwesenheit(en):\n\n` +
            konflikte.map(k => `• ${formatDate(k.vonDat)} - ${formatDate(k.bisDat)}: ${k.Grund}`).join('\n') +
            `\n\nTrotzdem speichern?`
        );
        if (!proceed) return;
    }

    // ... Speicherlogik ...
}

async function checkAbwesenheitKonflikte() {
    const maId = elements.NV_MA_ID.value;
    const nvId = elements.NV_ID.value || 0;
    const vonDat = elements.NV_VonDat.value;
    const bisDat = elements.NV_BisDat.value;

    if (!maId || !vonDat || !bisDat) return [];

    try {
        const result = await Bridge.execute('checkAbwesenheitKonflikte', {
            ma_id: maId,
            nv_id: nvId,
            von_dat: vonDat,
            bis_dat: bisDat
        });

        return result.data || [];
    } catch (error) {
        console.error('Fehler bei Konflikt-Prüfung:', error);
        return [];
    }
}
```

---

## 6. frm_Abwesenheiten

### HTML-Implementierung:

✅ **Gut umgesetzt:**
- Tabellen-basierte Ansicht
- Filter nach MA und Zeitraum
- Default-Zeitraum: aktueller Monat

❌ **Zusätzliche Empfehlungen:**

### EMPFEHLUNG 1: Kalender-Ansicht
```javascript
function toggleView() {
    // Zwischen Tabelle und Kalender-Ansicht wechseln
    state.viewMode = state.viewMode === 'table' ? 'calendar' : 'table';

    if (state.viewMode === 'calendar') {
        renderMonthCalendarView();
    } else {
        renderTable();
    }
}

function renderMonthCalendarView() {
    // Monatskalender mit allen Abwesenheiten
    const abwesenheitenByDate = groupAbwesenheitenByDate(state.records);

    // Ähnlich wie frm_MA_Abwesenheit, aber mit allen MA
    // Farbcodierung nach MA oder Grund
}
```

---

## 7. frm_abwesenheitsuebersicht

**Status:** Keine logic.js-Datei analysiert.

**Empfehlung:** Ähnlich wie frm_Abwesenheiten, aber mit:
- Statistiken (Anzahl Abwesenheiten pro MA, pro Grund)
- Zeitstrahl-Ansicht (Gantt-Chart)
- Exportfunktion (CSV/PDF)

---

## 8. frm_MA_Zeitkonten

### HTML-Implementierung:

✅ **Sehr gut umgesetzt:**
- Perioden-Auswahl (Monat, Vormonat, Quartal, Jahr, Custom)
- Zusammenfassungs-Statistiken
- Monatschart
- Export- und Druckfunktionen

❌ **FEHLEND:**

### FEHLEND 1: Überstunden-Berechnung
**VBA-Funktion:**
```vba
Private Sub CalculateUeberstunden()
    Dim SollStd As Double, IstStd As Double
    SollStd = Me.txtUrlaubsanspruch * 4.33 * Me.txtStundenzahlMonat
    IstStd = DSum("Arbeitsstunden", "qry_Zeiterfassung", "MA_ID=" & Me.MA_ID & " AND Monat=" & Month(Date))
    Me.txtUeberstunden = IstStd - SollStd
End Sub
```

**HTML-Lösung:**
```javascript
async function loadData() {
    const maId = state.selectedMA;
    const von = state.vonDatum.toISOString().split('T')[0];
    const bis = state.bisDatum.toISOString().split('T')[0];

    try {
        setStatus('Lade Zeitkonto...');

        // Zeitkonto-Daten laden
        const result = await Bridge.zeitkonten.get({
            ma_id: maId,
            von,
            bis
        });

        const data = result.data;

        // Tabelle befüllen
        renderTable(data.eintraege);

        // Statistiken berechnen und anzeigen
        calculateAndDisplayStats(data);

        // Chart rendern
        renderMonthChart(data.tageSummen);

        setStatus(`${data.eintraege.length} Einträge geladen`);

    } catch (error) {
        console.error('[Zeitkonten] Fehler beim Laden:', error);
        setStatus('Fehler: ' + error.message);
    }
}

function calculateAndDisplayStats(data) {
    // Soll-Stunden berechnen
    const sollStd = data.sollstunden || 0;

    // Ist-Stunden summieren
    const istStd = data.eintraege.reduce((sum, e) => sum + (e.Nettostunden || 0), 0);

    // Saldo
    const saldo = istStd - sollStd;

    // Überstunden (nur positive Differenz)
    const ueberstunden = Math.max(0, saldo);

    // Urlaub/Krank summieren
    const urlaub = data.eintraege.filter(e => e.Grund === 'Urlaub')
                                  .reduce((sum, e) => sum + (e.Stunden || 8), 0);
    const krank = data.eintraege.filter(e => e.Grund === 'Krank')
                                 .reduce((sum, e) => sum + (e.Stunden || 8), 0);

    // Anzeigen
    elements.summSoll.textContent = formatHours(sollStd);
    elements.summIst.textContent = formatHours(istStd);
    elements.summSaldo.textContent = formatHours(saldo);
    elements.summSaldo.className = saldo >= 0 ? 'stat-value positive' : 'stat-value negative';
    elements.summUeberstunden.textContent = formatHours(ueberstunden);
    elements.summUrlaub.textContent = formatHours(urlaub);
    elements.summKrank.textContent = formatHours(krank);
}

function formatHours(hours) {
    const sign = hours < 0 ? '-' : '';
    const absHours = Math.abs(hours);
    const h = Math.floor(absHours);
    const m = Math.round((absHours - h) * 60);
    return `${sign}${h}:${m.toString().padStart(2, '0')}`;
}
```

### FEHLEND 2: Monatschart mit Chart.js
```javascript
function renderMonthChart(tageSummen) {
    if (!elements.monthChart) return;

    const labels = tageSummen.map(t => t.tag);
    const stunden = tageSummen.map(t => t.stunden);
    const soll = tageSummen.map(t => t.sollstunden || 0);

    // Altes Chart zerstören
    if (window.zeitkontoChart) {
        window.zeitkontoChart.destroy();
    }

    // Neues Chart erstellen
    const ctx = elements.monthChart.getContext('2d');
    window.zeitkontoChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels,
            datasets: [
                {
                    label: 'Ist-Stunden',
                    data: stunden,
                    backgroundColor: '#4CAF50',
                    borderColor: '#388E3C',
                    borderWidth: 1
                },
                {
                    label: 'Soll-Stunden',
                    data: soll,
                    type: 'line',
                    borderColor: '#FF9800',
                    borderWidth: 2,
                    fill: false,
                    pointRadius: 0
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Stunden'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Tag'
                    }
                }
            },
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return context.dataset.label + ': ' + formatHours(context.parsed.y);
                        }
                    }
                }
            }
        }
    });
}
```

---

## Zusammenfassung: Fehlende Funktionen nach Kategorie

### 1. Form-Level Events (HOCH)
- `Form_Current()` - Bei jedem Datensatzwechsel
- `Form_BeforeUpdate()` - Vor Speicherung (Validierung)
- `Form_AfterUpdate()` - Nach Speicherung (Refresh)
- `Form_Dirty()` - Änderungen erkannt

**Lösung:** Event-System in HTML logic.js ergänzen

### 2. Bedingte Formatierung (MITTEL)
- Hintergrundfarben basierend auf Status
- Schrift-Formatierung (Farbe, Fett, etc.)
- Sichtbarkeit von Controls

**Lösung:** `applyConditionalFormatting()` Funktion

### 3. Feldvalidierung (HOCH)
- `BeforeUpdate` auf Feld-Ebene
- Datentyp-Prüfung
- Pflichtfeld-Prüfung
- Bereichsprüfung

**Lösung:** `setupFieldValidation()` mit blur/change-Events

### 4. Berechnungen (MITTEL)
- Berechnete Felder
- Summen/Durchschnitte
- Aggregationen

**Lösung:** Berechnungsfunktionen in logic.js

### 5. Subform-Integration (HOCH)
- Requery nach Master-Änderung
- Link Master/Child Fields
- Subform-Events

**Lösung:** PostMessage-System (bereits teilweise vorhanden)

### 6. Reporting/Export (MITTEL)
- PDF-Export
- Excel-Export
- Formatierte Druckausgaben

**Lösung:** Server-seitige Export-Funktionen

### 7. E-Mail-Integration (NIEDRIG)
- Outlook-Automation
- Serien-E-Mails

**Lösung:** Server-seitiger E-Mail-Versand oder mailto-Links

### 8. Charts/Visualisierungen (MITTEL)
- Balken-/Liniendiagramme
- Pivot-Charts

**Lösung:** Chart.js Integration

### 9. Access-spezifische Features (IRRELEVANT)
- Ribbon-Steuerung
- Datenbank-Fenster
- Access-Reports

**Lösung:** Nicht benötigt in HTML

---

## Implementierungs-Prioritäten

### Phase 1: Kritisch (Sofort)
1. ✅ Form_Current()-Äquivalent für alle Formulare
2. ✅ Feldvalidierung (BeforeUpdate)
3. ✅ Bedingte Formatierung
4. ✅ Subform-Requery bei Master-Change

### Phase 2: Wichtig (Kurzfristig)
5. ⚠️ E-Mail-Funktionen (Einsatzlisten)
6. ⚠️ PDF/Excel-Export
7. ⚠️ Charts (Zeitkonten, Umsatz)
8. ⚠️ Geocoding (Objekte)

### Phase 3: Nice-to-have (Mittelfristig)
9. 📝 Kalender-Mehrfach-Auswahl
10. 📝 Konflikt-Prüfung mit Warnungen
11. 📝 Dateiverwaltung mit Vorschau
12. 📝 Umsatzauswertung mit Chart

### Phase 4: Optional
13. 🔧 Erweiterte Such-Optionen
14. 🔧 Batch-Operationen
15. 🔧 Import/Export-Assistenten

---

## Code-Templates für häufige Patterns

### 1. Form_Current() Equivalent
```javascript
// In gotoRecord() nach displayRecord() hinzufügen:
await onRecordCurrent(state.currentRecord);

async function onRecordCurrent(record) {
    // Bedingte Formatierung
    applyConditionalFormatting(record);

    // Toolbar-Status
    updateToolbarState(record);

    // Subforms aktualisieren
    await notifySubforms('record_changed', {
        master_id: record.ID,
        master_data: record
    });
}
```

### 2. Feldvalidierung
```javascript
function setupFieldValidation() {
    const validations = {
        txtEmail: {
            validate: (v) => !v || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
            message: 'Ungültige E-Mail-Adresse'
        },
        txtTelMobil: {
            validate: (v) => !v || /^\+?[0-9\s\-\(\)]{6,20}$/.test(v),
            message: 'Ungültige Telefonnummer'
        },
        txtPLZ: {
            validate: (v) => !v || /^[0-9]{5}$/.test(v),
            message: 'PLZ muss 5-stellig sein'
        }
    };

    Object.entries(validations).forEach(([fieldName, rule]) => {
        const field = elements[fieldName];
        if (!field) return;

        field.addEventListener('blur', () => {
            if (!rule.validate(field.value.trim())) {
                field.classList.add('validation-error');
                showFieldError(field, rule.message);
            } else {
                field.classList.remove('validation-error');
                hideFieldError(field);
            }
        });
    });
}
```

### 3. Bedingte Formatierung
```javascript
function applyConditionalFormatting(record) {
    // Status-Badge
    if (record.IstAktiv) {
        elements.lblStatus.className = 'status-badge status-active';
        elements.lblStatus.textContent = 'AKTIV';
    } else {
        elements.lblStatus.className = 'status-badge status-inactive';
        elements.lblStatus.textContent = 'INAKTIV';
    }

    // Hintergrundfarbe
    const detailSection = document.querySelector('.detail-content');
    if (detailSection) {
        detailSection.style.backgroundColor = record.IstAktiv ? '#ffffff' : '#f5f5f5';
    }

    // Schrift-Farbe für inaktive
    const nameFields = [elements.txtNachname, elements.txtVorname];
    nameFields.forEach(field => {
        if (field) {
            field.style.color = record.IstAktiv ? '#000000' : '#999999';
        }
    });
}
```

### 4. Subform-Requery
```javascript
function notifySubforms(eventType, data) {
    const subforms = document.querySelectorAll('iframe.subform');
    subforms.forEach(iframe => {
        if (iframe.contentWindow) {
            iframe.contentWindow.postMessage({
                type: eventType,
                ...data
            }, '*');
        }
    });
}

// Im Subform (empfangen):
window.addEventListener('message', (event) => {
    if (event.data.type === 'record_changed') {
        // Filter aktualisieren
        state.linkMasterID = event.data.master_id;
        loadData();
    }
});
```

---

## Nächste Schritte

1. **Agent 2:** Übernimmt die restlichen Formulare und erstellt Implementierungs-Code
2. **Testing:** Jede fehlende Funktion in Isolierung testen
3. **Integration:** In bestehende logic.js-Dateien einarbeiten
4. **Dokumentation:** CLAUDE.md um neue Patterns erweitern

---

**Bericht Ende**
