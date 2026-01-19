# Gap-Analyse: frmOff_Outlook_aufrufen

**Datum:** 2026-01-12
**Formular-Typ:** Popup - E-Mail versenden (Outlook-Integration)
**Priorität:** HOCH

---

## 1. Übersicht

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Formular-Typ** | Popup (ungebunden) | Vollbild-Formular | ✅ Implementiert |
| **Record Source** | Keine (ungebunden) | Ungebunden | ✅ Korrekt |
| **Zweck** | E-Mail via Outlook | E-Mail via Bridge | ⚠️ Unterschied! |
| **Integration** | COM (Outlook.Application) | WebView2 Bridge | ⚠️ Technologie-Unterschied |

---

## 2. Controls - Detailvergleich

### 2.1 Access Controls (60+ Controls!)

**E-Mail-Felder:**
- TO, CC, BCC (TextBoxen)
- Subject (TextBox)
- eMailText (TextBox, Large)
- AbsendenAls (TextBox) - Absender-E-Mail

**Template:**
- cboOutlooktemp (ComboBox) - E-Mail-Vorlagen
- Voting_Text (ComboBox)

**Optionen:**
- SendenAn (OptionGroup): MA / Kunde / Kundenmitarbeiter / Vorselektion
- TextAls (OptionGroup): ASCII / HTML
- IstEinzelEmail (CheckBox) - Einzel vs. Sammel-Mail
- IsDirectsend (CheckBox) - Direkt senden ohne Outlook öffnen
- IstEmpfangsbest (CheckBox) - Empfangsbestätigung
- IstSMS (CheckBox) - SMS statt E-Mail (vorbereitet)
- cboSendPrio (ComboBox) - Priorität (Hoch/Normal/Niedrig)

**Empfänger-Listen (4 ListBoxen!):**
1. **Lst_MA** - Mitarbeiter-Liste (Spalten: ID, Name, Vorname, Email)
2. **Lst_MA2** - Zweite MA-Liste (für Filter)
3. **lst_Kunden** - Kunden-Liste
4. **Liste256** - Vorselektion (dynamisch)

**Filter:**
- NurAktiveMA (ComboBox) - Nur Aktive / Festangestellte / Minijobber / etc.
- cboFirmaInf (ComboBox) - Firma-Filter
- cbo_VA_ID (ComboBox) - Auftragsbezogen (neu!)

**Anhänge:**
- sub_tbltmp_Attachfile (SubForm) - Anhangsliste
- btnAttachSuch (Button) - Datei suchen
- btnAttLoesch (Button) - Anhänge löschen
- Imagefile (TextBox) - Bilddatei für HTML-Mail
- btnBildSuch (Button) - Bild suchen

**Buttons:**
- btnOutlook - Senden
- Befehl121 - Hilfe
- Befehl38 - Schließen
- btnRibbonAus/Ein, btnDaBaAus/Ein

**Sidebar:** frm_Menuefuehrung

### 2.2 HTML Controls

**Header-Bar:**
- Titel "E-Mail versenden" ✅
- Senden-Button ✅
- Vorlage-Dropdown ✅
- Checkbox: Direkt Senden ✅
- Hilfe/Schließen Buttons ✅
- Datum-Anzeige ✅

**Linke Spalte - E-Mail-Felder:**
- TO, CC, BCC (Input) ✅
- Betreff (Input) ✅
- Text (Textarea) ✅
- Checkbox: HTML-Format ✅
- Priorität (Dropdown) ✅

**Mittlere Spalte:**
- Anhänge-Liste (Div) ✅
- Buttons: Suchen, Löschen ✅
- Festangestellte-Liste (Div) ✅

**Rechte Spalte:**
- Radio-Group: Senden an (MA/Kunde/Alle) ✅
- 2 MA-Listen nebeneinander ✅
- Spalten: Name, E-Mail ✅

**Fehlende Controls:**
❌ **WICHTIGE FEATURES FEHLEN:**
1. **Kunden-Liste** - Fehlt komplett!
2. **SendenAn: Kundenmitarbeiter** - Fehlt!
3. **Vorselektion-Liste** - Fehlt!
4. **Filter: NurAktiveMA** - Fehlt (nur 3 Radio-Buttons)
5. **cbo_VA_ID** - Auftrags-Dropdown FEHLT!
6. **Empfangsbestätigung** - Checkbox fehlt
7. **SMS-Option** - Fehlt (Access: vorbereitet)
8. **Voting-Text** - Fehlt
9. **Bild für HTML-Mail** - Fehlt

✅ **HTML hat mehr:**
- Vollbild-Button ✅
- Moderneres Layout ✅
- Toast-Notifications ✅

---

## 3. Datenquellen

### Access Queries

**Lst_MA (Mitarbeiter):**
```sql
-- Dynamisch via VBA (NurAktiveMA_AfterUpdate)
SELECT ID, Nachname, Vorname, email
FROM qry_eMail_MA_Std
WHERE Anstellungsart_ID = 3 OR Anstellungsart_ID = 5
ORDER BY Nachname, Vorname;
```

**lst_Kunden:**
```sql
-- Vermutlich
SELECT kun_Id, kun_Firma, kun_email
FROM tbl_KD_Kundenstamm
WHERE kun_IstAktiv = True
ORDER BY kun_Firma;
```

**cbo_VA_ID (NEU!):**
```sql
-- VBA Form_Load
SELECT dat_va_von, id, auftrag, ort, objekt
FROM tbl_va_auftragstamm
WHERE dat_va_von >= Date()
  AND dat_va_von <= DateAdd("d", 30, Date())
ORDER BY dat_va_von ASC
```

### HTML API-Endpoints
⚠️ **Teilweise vorhanden:**
- `GET /api/mitarbeiter` - MA-Liste ✅
- `GET /api/kunden` - Kunden-Liste ⚠️ (prüfen!)
- `GET /api/auftraege?status=aktiv` - Aufträge ⚠️ (fehlt!)

❌ **Fehlend:**
- `/api/email/templates` - E-Mail-Vorlagen
- `/api/email/send` - E-Mail senden (via Bridge oder Server?)

---

## 4. Funktionalität

### 4.1 Implementierte Features
| Feature | Access | HTML | Status |
|---------|--------|------|--------|
| TO/CC/BCC | ✅ | ✅ | Vollständig |
| Betreff/Text | ✅ | ✅ | Vollständig |
| HTML-Format | ✅ | ✅ | Vollständig |
| Priorität | ✅ | ✅ | Vollständig |
| Template-Auswahl | ✅ | ⚠️ | Prüfen! |
| Direkt senden | ✅ | ✅ | Vollständig |
| MA-Liste | ✅ | ✅ | Vollständig |
| MA-Mehrfachauswahl | ✅ (manuell) | ✅ (Checkbox) | HTML besser! |
| Kunden-Liste | ✅ | ❌ | FEHLT! |
| Anhänge | ✅ | ⚠️ | Prüfen! |
| Bild für HTML-Mail | ✅ | ❌ | FEHLT! |
| Empfangsbestätigung | ✅ | ❌ | FEHLT! |
| Filter (Aktive/Fest/Mini) | ✅ | ❌ | FEHLT! |
| Auftragsbezug (cbo_VA_ID) | ✅ | ❌ | FEHLT! |
| SMS-Option | ⚠️ (vorbereitet) | ❌ | FEHLT! |

### 4.2 Kritische Unterschiede

**Access:**
- Nutzt **Outlook COM** (Outlook.Application)
- E-Mail wird in Outlook erstellt
- User sieht Outlook-Fenster (falls nicht DirectSend)
- Anhänge via Outlook-Attachments

**HTML:**
- Nutzt **WebView2 Bridge** zu VBA
- VBA erstellt Outlook-Mail (Bridge-Event)
- User sieht HTML-Formular
- Anhänge via Bridge übertragen

⚠️ **RISIKO:** Funktioniert HTML-Bridge mit Outlook COM?

---

## 5. VBA-Logik (Access) - SEHR KOMPLEX!

### Hauptfunktionen

**btnOutlook_Click() - 200+ Zeilen VBA:**
1. Validierung (Empfänger, Absender, Betreff)
2. Anhänge sammeln (aus sub_tbltmp_Attachfile)
3. Text-Ersetzungen (Platzhalter wie %MA_Name%)
4. Outlook COM erstellen
5. E-Mail-Item erstellen (HTML oder Plain)
6. Attachments hinzufügen
7. TO/CC/BCC setzen
8. Priorität setzen
9. Voting-Optionen (falls gesetzt)
10. .Display oder .Send (je nach IsDirectsend)

**CreatePlainMail() - Hilfsfunktion:**
- Universelle E-Mail-Erstellung
- HTML oder Plain Text
- Attachments
- Voting
- Importance
- SentOnBehalfOf (Absender)

**Empfänger-Logik:**
- **IstEinzelEmail = True:** Jeder Empfänger einzeln (Platzhalter individuell)
- **IstEinzelEmail = False:** Alle in BCC (Sammel-Mail)

**Text-Ersetzungen (Textbau_Ersetz):**
- %MA_Name%, %MA_Email%, %Kunde_Name%, etc.
- Dynamischer Austausch pro Empfänger

**cbo_VA_ID_AfterUpdate() - NEU!:**
- Lädt E-Mails aller MA die diesem Auftrag zugeordnet sind
- Fügt sie automatisch in BCC ein

---

## 6. HTML Events & Bridge

### HTML (Inline-Script)

**setupEventListeners():**
- btnOutlook → sendEmail()
- btnAttachSuch → selectAttachment()
- btnAttLoesch → clearAttachments()
- cboOutlooktemp → loadTemplate()

**Bridge Events:**
```javascript
Bridge.on('onDataReceived', handleDataReceived)
Bridge.on('onTemplateLoaded', handleTemplateLoaded)
Bridge.on('onAttachmentSelected', handleAttachmentSelected)
Bridge.on('onEmailSent', handleEmailSent)
```

**sendEmail():**
```javascript
const emailData = {
    to: document.getElementById('TO').value,
    cc: document.getElementById('CC').value,
    bcc: document.getElementById('BCC').value,
    subject: document.getElementById('Subject').value,
    body: document.getElementById('Body').value,
    isHTML: document.getElementById('IsHTML').checked,
    priority: parseInt(document.getElementById('Priority').value),
    attachments: [...],
    directSend: document.getElementById('IsDirectsend').checked,
    selectedMAs: Array.from(state.selectedMAs)
};

Bridge.sendEvent('sendEmail', emailData);
```

⚠️ **VBA-Empfang:**
- Bridge empfängt 'sendEmail'-Event
- Ruft CreatePlainMail() auf
- Erstellt Outlook-Mail
- Sendet Erfolg/Fehler zurück

---

## 7. Gaps & Risiken

### 7.1 Kritische Gaps
❌ **SHOWSTOPPER:**
1. **Kunden-Liste fehlt** - Kann nicht an Kunden mailen!
2. **Auftragsbezug fehlt** (cbo_VA_ID) - Neue Access-Funktion nicht portiert
3. **Empfangsbestätigung** - Feature fehlt
4. **Text-Ersetzungen** - Platzhalter wie %MA_Name% fehlen (?)
5. **Einzel vs. Sammel-Mail** - Logik unklar

### 7.2 Moderate Gaps
⚠️ **WICHTIG:**
1. **Filter fehlen** - Nur 3 Radio-Buttons statt Dropdown mit 5 Optionen
2. **Bild für HTML-Mail** - Fehlt (Header-Image)
3. **Voting-Text** - Fehlt (Outlook Voting Buttons)
4. **Template-System** - Prüfen ob funktioniert

### 7.3 Nice-to-Have
💡 **Access hat mehr:**
- SMS-Option (vorbereitet, aber inaktiv)
- Vorselektion-Liste (dynamisch)
- WinWord-Integration (btnWinWord_Click - 200+ Zeilen!)

---

## 8. Empfohlene Maßnahmen

### Priorität 1 (Sofort - KRITISCH!)
1. ❌ **Kunden-Liste hinzufügen:**
   - Tab: "Kunden" neben "Mitarbeiter"
   - Liste mit kun_Firma, kun_Email
   - API: GET /api/kunden

2. ❌ **Auftragsbezug hinzufügen:**
   - Dropdown: cbo_VA_ID (nächste 30 Tage)
   - Bei Auswahl: MA-E-Mails automatisch in BCC

3. ⚠️ **Bridge-Test:**
   - Kann Bridge Outlook COM ansprechen?
   - Funktioniert sendEmail-Event?
   - Attachments übertragbar?

### Priorität 2 (Kurzfristig)
4. ✅ **Filter erweitern:**
   - Dropdown statt 3 Radio-Buttons
   - Optionen: Alle / Aktive / Festangestellte / Minijobber / Subunternehmer

5. ✅ **Empfangsbestätigung:**
   - Checkbox hinzufügen
   - Bridge übertragen → Outlook.ReadReceiptRequested = True

6. ✅ **Text-Ersetzungen:**
   - Client-seitig: %MA_Name%, %MA_Email% ersetzen
   - Bei Einzel-Mails pro Empfänger individuell

### Priorität 3 (Mittelfristig)
7. 💡 **Template-System ausbauen:**
   - API: /api/email/templates
   - Vorlagen laden/speichern
   - Platzhalter dokumentieren

8. 💡 **Bild für HTML-Mail:**
   - FileDialog via Bridge
   - Als Attachment hinzufügen
   - In HTML-Body einbinden

---

## 9. Technische Details

### VBA-Bridge-Handler (Access)

```vba
' In mod_N_WebView2_forms3.bas
Public Sub HandleEmailEvent(ByVal jsonData As String)
    ' JSON parsen
    Dim emailData As Object
    Set emailData = JsonConverter.ParseJson(jsonData)

    ' Outlook COM erstellen
    Dim outlookApp As Object
    Set outlookApp = CreateObject("Outlook.Application")

    Dim mailItem As Object
    Set mailItem = outlookApp.CreateItem(0) ' olMailItem

    With mailItem
        .To = emailData("to")
        .CC = emailData("cc")
        .BCC = emailData("bcc")
        .Subject = emailData("subject")

        If emailData("isHTML") Then
            .BodyFormat = 2 ' olFormatHTML
            .HTMLBody = emailData("body")
        Else
            .Body = emailData("body")
        End If

        .Importance = emailData("priority") ' 0=Low, 1=Normal, 2=High

        ' Attachments (falls vorhanden)
        If emailData.Exists("attachments") Then
            Dim att As Variant
            For Each att In emailData("attachments")
                .Attachments.Add CStr(att)
            Next
        End If

        ' Direkt senden oder anzeigen
        If emailData("directSend") Then
            .Send
        Else
            .Display
        End If
    End With

    ' Erfolg zurückmelden
    SendBridgeEvent "onEmailSent", "{""success"":true}"
End Sub
```

### Kunden-Liste hinzufügen (HTML)

```javascript
// Neuen Tab für Kunden
<div class="senden-an-options">
    <label><input type="radio" name="sendeTo" value="ma" checked> Mitarbeiter</label>
    <label><input type="radio" name="sendeTo" value="kunde"> Kunden</label>
    <label><input type="radio" name="sendeTo" value="all"> Alle</label>
</div>

// Container für Kunden-Liste
<div id="kundenContainer" style="display:none;">
    <div class="ma-list-header">
        <span class="col-name">Firma</span>
        <span class="col-email">E-Mail</span>
    </div>
    <div id="lst_Kunden" class="ma-list"></div>
</div>

// Toggle zwischen MA/Kunde
document.querySelectorAll('input[name="sendeTo"]').forEach(radio => {
    radio.addEventListener('change', (e) => {
        document.getElementById('kundenContainer').style.display = e.target.value === 'kunde' ? 'block' : 'none';
        document.querySelector('.ma-lists-container').style.display = e.target.value === 'ma' ? 'flex' : 'none';
    });
});
```

---

## 10. Zusammenfassung

### ✅ Stärken des HTML-Formulars
1. **Modernes Layout** (3-Spalten-Design)
2. **Vollbild-Modus** verfügbar
3. **Bessere MA-Auswahl** (2 Listen, Checkboxen)
4. **Toast-Notifications**
5. **Responsive Design**

### ❌ Kritische Schwächen
1. **Kunden-Liste fehlt** (Access-Hauptfeature!)
2. **Auftragsbezug fehlt** (NEU in Access)
3. **Empfangsbestätigung fehlt**
4. **Filter eingeschränkt**
5. **Text-Ersetzungen unklar**
6. **Bridge-Funktionalität ungeklärt**

### ⚠️ Höchstes Risiko
**Bridge-Integration mit Outlook COM:**
- Kann WebView2 Bridge Outlook ansprechen?
- Funktionieren Attachments?
- Wie werden große E-Mails übertragen?

### 🎯 Bewertung
**Status:** 70% FERTIG (ohne Kunden/Auftrag)
**Status:** 50% FERTIG (mit allen Features)
**Risiko:** HOCH (Bridge-Unklarheit, kritische Features fehlen)
**Aufwand:** 2-3 Tage (Kunden-Liste, Auftragsbezug, Tests)

**Fazit:** HTML hat gutes UI, aber **KRITISCHE FEATURES FEHLEN** (Kunden-Liste, Auftragsbezug)! **DRINGEND nachbessern!** ⚠️

---

## 11. Entscheidungshilfe

### Variante A: Outlook-Bridge belassen
**Pro:**
- Nutzt vorhandenes Outlook auf PC
- Gewohnte Outlook-Oberfläche
- Alle Outlook-Features verfügbar

**Contra:**
- Bridge-Komplexität
- Abhängig von Outlook-Installation
- Attachments-Übertragung problematisch

### Variante B: Server-seitiges E-Mail-System
**Pro:**
- Unabhängig von Outlook
- SMTP direkt vom Server
- Einfachere Implementierung
- Moderne Web-Technologie

**Contra:**
- Kein Outlook-Zugriff mehr
- SMTP-Server erforderlich
- Gesendete Mails nicht in Outlook-History

**Empfehlung:** ⚠️ **Entscheidung mit Nutzer klären!**
