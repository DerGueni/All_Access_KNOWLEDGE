# Gap-Analyse: frm_Zeiterfassung

**Datum:** 2026-01-12
**Status:** HTML nicht vorhanden
**Priorität:** HOCH (Echtzeit-Funktion, produktiv genutzt)

---

## Zusammenfassung

Dieses Formular ist eine **Stempeluhr-ähnliche Zeiterfassung** für Mitarbeiter. Es ermöglicht:
- Ein- und Auschecken von Mitarbeitern auf Einsätzen
- QR-Code-Scan für schnelle Erfassung (Personal-ID scannen)
- Verwaltung von Check-In/Check-Out-Zeiten
- Automatische Rundung auf Viertelstunden
- Ungeplante Check-Ins (Mitarbeiter ohne Einteilung)

**Besonderheit:** Echtzeit-Erfassung, oft auf Tablet/Handy genutzt, muss schnell und responsive sein.

---

## 1. Datenquelle

### Access (Original)
- **Haupttabellen:**
  - `tbl_Zeiterfassung` (Check-In/Out-Daten)
  - `tbl_MA_VA_Zuordnung` (Mitarbeiter-Zuordnungen)
  - `tbl_VA_Start` (Schichten)
  - `tbl_MA_Mitarbeiterstamm` (Mitarbeiter-Info)

- **Queries (implizit in VBA):**
  - Zuordnungen für gewählten Einsatz
  - Eingecheckte Mitarbeiter
  - Ausgecheckte Mitarbeiter

### HTML (Aktuell)
- **Status:** Formular existiert nicht
- **Gap:** Vollständige Neuentwicklung nötig

### Erforderlich
```javascript
// Endpoints für Zeiterfassung
GET /api/zeiterfassung/einsaetze           // Liste aller Einsätze (für Dropdown)
GET /api/zeiterfassung/zuordnungen/:va_id  // Zuordnungen für Einsatz
GET /api/zeiterfassung/checkins/:va_id     // Eingecheckte MA
GET /api/zeiterfassung/checkouts/:va_id    // Ausgecheckte MA
POST /api/zeiterfassung/checkin            // Check-In durchführen
POST /api/zeiterfassung/checkout           // Check-Out durchführen
PUT /api/zeiterfassung/:zuo_id             // Zeit ändern
DELETE /api/zeiterfassung/checkin/:zuo_id  // Check-In löschen
DELETE /api/zeiterfassung/checkout/:zuo_id // Check-Out löschen
```

---

## 2. Controls / UI-Elemente

### Access-Controls (13 Haupt-Elemente)

| Control | Typ | Position | Größe | Funktion | Status HTML |
|---------|-----|----------|-------|----------|-------------|
| cmbEinsatz | ComboBox | 3005, 795 | 12462 x 435 | Einsatz wählen | ❌ Fehlt |
| txtQRScan | TextBox | 3005, 2610 | 1751 x 675 | QR-Code Eingabefeld | ❌ Fehlt |
| lblAusgewaehlterAuftrag | Label | 3005, 1425 | 12462 x 390 | Anzeige Auftrag | ❌ Fehlt |
| lblStatus | Label | 3005, 2085 | 12462 x 401 | Status-Meldung | ❌ Fehlt |
| lstZuo | ListBox | 570, 3865 | 6012 x 6292 | Noch nicht eingecheckt | ❌ Fehlt |
| lstCheckedIn | ListBox | 6690, 3865 | 6012 x 6292 | Eingecheckt | ❌ Fehlt |
| lstCheckedOut | ListBox | 12810, 3865 | 6012 x 6292 | Ausgecheckt | ❌ Fehlt |
| btnCheckIn | Button | 1860, 3525 | 1371 x 283 | Einchecken | ❌ Fehlt |
| btnCheckOut | Button | 8325, 3525 | 1371 x 283 | Auschecken | ❌ Fehlt |
| btnChangeZuo | Button | 3405, 3525 | 1086 x 283 | Ändern (Zuo) | ❌ Fehlt |
| btnChangeIn | Button | 9870, 3525 | 1086 x 283 | Ändern (CheckIn) | ❌ Fehlt |
| btnChangeOut | Button | 15363, 3514 | 1086 x 283 | Ändern (CheckOut) | ❌ Fehlt |
| btnDeleteCheckIn | Button | 11625, 3525 | 1086 x 283 | Löschen (CheckIn) | ❌ Fehlt |
| btnDeleteCheckOut | Button | 17746, 3514 | 1086 x 283 | Löschen (CheckOut) | ❌ Fehlt |

**Zusätzliche Labels:**
- lbZuo, lbCheckedIn, lbCheckedOut (Header für Listboxen)

---

## 3. VBA-Logik (Komplex!)

### Haupt-Funktionen

#### 1. `MA_Zeiterfassung(MA_ID, [ZUO_ID])` - Ein-/Auschecken
```vba
' Hauptfunktion für Zeiterfassung
' 1. Prüfen: MA bereits eingecheckt?
' 2. Wenn Nein → Check-In
' 3. Wenn Ja → Check-Out
' 4. Zeit runden auf Viertelstunde
' 5. In tbl_Zeiterfassung + tbl_MA_VA_Zuordnung speichern
```

**Kritische Logik:**
- Automatische Rundung: `ZeitAufViertelstundeRunden(Now())`
- Ungeplante Check-Ins: Falls keine Zuordnung existiert → `einteilen_checkIn`
- Doppelte Zeitfelder: `MA_Start`/`MVA_Start`, `MA_Ende`/`MVA_Ende`
- Status-Tracking: "EINGECHECKT", "AUSGECHECKT"

**HTML-Äquivalent:**
```javascript
async function checkInOut(maId, zuoId = null) {
    const response = await fetch('/api/zeiterfassung/checkin-out', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ maId, zuoId })
    });
    const result = await response.json();
    showStatus(result.message, result.success ? 'success' : 'error');
    refreshLists();
}
```

#### 2. `ZeitAufViertelstundeRunden(eingabeZeit)` - Rundung
```vba
' Rundet Zeit auf Viertelstunde
Select Case minuten
    Case 0 To 7:   neueMinuten = 0
    Case 8 To 22:  neueMinuten = 15
    Case 23 To 37: neueMinuten = 30
    Case 38 To 52: neueMinuten = 45
    Case 53 To 59: neueMinuten = 0; stunden = stunden + 1
End Select
```

**HTML-Äquivalent:**
```javascript
function roundToQuarterHour(time) {
    const minutes = time.getMinutes();
    let newMinutes, newHours = time.getHours();

    if (minutes <= 7) newMinutes = 0;
    else if (minutes <= 22) newMinutes = 15;
    else if (minutes <= 37) newMinutes = 30;
    else if (minutes <= 52) newMinutes = 45;
    else {
        newMinutes = 0;
        newHours++;
    }

    return new Date(time.getFullYear(), time.getMonth(), time.getDate(), newHours, newMinutes, 0);
}
```

#### 3. `einteilen_checkIn(MA_ID, VA_ID, VADatum_ID)` - Ungeplanter Check-In
```vba
' Falls MA nicht eingeteilt → automatisch einplanen
' 1. Neuer Datensatz in tbl_MA_VA_Zuordnung
' 2. Neuer Datensatz in tbl_Zeiterfassung mit Flag "ungeplant"
```

**HTML-Äquivalent:**
```javascript
async function einteilen_checkIn(maId, vaId, vaDatumId) {
    const response = await fetch('/api/zeiterfassung/ungeplanter-checkin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ maId, vaId, vaDatumId })
    });
    return response.json();
}
```

#### 4. `MA_Zeiterfassung_zuocheck(MA_ID, [isSub])` - Zuordnungs-Prüfung
```vba
' Prüft welche Zuordnung für MA gilt
' Fall 1: Keine Zuordnung → ungeplanter Check-In
' Fall 2: Eine Zuordnung → direkt nutzen
' Fall 3: Mehrere Zuordnungen → Popup zur Auswahl
' Fall 4: Subunternehmer → immer Popup (wegen Bemerkung)
```

#### 5. `txtQRScan_AfterUpdate()` - QR-Scan-Verarbeitung
```vba
' Wenn MA-ID eingegeben/gescannt → MA_Zeiterfassung aufrufen
MA_ID = Me.txtQRScan
If Not IsInitial(MA_ID) Then
    Call MA_Zeiterfassung(MA_ID)
End If
```

**HTML-Äquivalent:**
```javascript
document.getElementById('qrScan').addEventListener('input', async (e) => {
    const maId = parseInt(e.target.value);
    if (maId && !isNaN(maId)) {
        await checkInOut(maId);
        e.target.value = '';
        e.target.focus();
    }
});
```

---

## 4. Layout und UI-Konzept

### Access-Layout
```
+--------------------------------------------------------------------+
| Zeiterfassung                                                      |
+--------------------------------------------------------------------+
| Einsatz wählen: [Dropdown mit Datum + Auftrag + Ort + Objekt   ▼] |
| Ausgewählter Auftrag: [14.01.2026 Eventname Frankfurt Messe       ]|
+--------------------------------------------------------------------+
| QR-Code scannen: [___________________]                             |
| Status: [Einsatz ausgewählt - bereit für Scan!]                   |
+--------------------------------------------------------------------+
| Noch nicht eingecheckt | Eingecheckt        | Ausgecheckt         |
| [Einchecken] [Ändern]  | [Auschecken] [Änd] | [Ändern] [Löschen]  |
| +-----------+           | +-----------+      | +-----------+       |
| | ☐ Müller  |           | | ☑ Schmidt |      | | ✓ Meyer   |       |
| | ☐ Weber   |           | | ☑ Fischer |      | | ✓ Wagner  |       |
| | ...       |           | | ...       |      | | ...       |       |
| +-----------+           | +-----------+      | +-----------+       |
+--------------------------------------------------------------------+
```

### HTML-Layout (Empfohlen für Tablet)
```html
<div class="zeiterfassung-container">
  <!-- Header -->
  <header class="header">
    <h1>⏱️ Zeiterfassung</h1>
    <select id="einsatzSelect" class="einsatz-dropdown">
      <!-- Optionen dynamisch -->
    </select>
    <div class="auftrag-info" id="auftragInfo">
      Ausgewählter Auftrag: <strong>...</strong>
    </div>
  </header>

  <!-- QR-Scan-Bereich (prominent) -->
  <div class="scan-area">
    <input type="number" id="qrScan" placeholder="Personal-ID scannen oder eingeben" autofocus>
    <div class="status-message" id="statusMsg">Bereit für Scan</div>
  </div>

  <!-- Drei-Spalten-Layout -->
  <div class="columns">
    <div class="column">
      <h3>Noch nicht eingecheckt</h3>
      <div class="ma-list" id="zuoList"><!-- ... --></div>
      <button onclick="checkinSelected()">Einchecken</button>
    </div>

    <div class="column">
      <h3>Eingecheckt</h3>
      <div class="ma-list" id="checkinList"><!-- ... --></div>
      <button onclick="checkoutSelected()">Auschecken</button>
    </div>

    <div class="column">
      <h3>Ausgecheckt</h3>
      <div class="ma-list" id="checkoutList"><!-- ... --></div>
    </div>
  </div>
</div>
```

**CSS für Tablet-Optimierung:**
```css
.zeiterfassung-container {
    font-size: 16px; /* Größer für Touch */
    padding: 20px;
}

.scan-area input {
    font-size: 24px;
    padding: 15px;
    width: 100%;
    border: 3px solid #4CAF50;
}

.ma-list {
    overflow-y: auto;
    max-height: 50vh;
}

.ma-list-item {
    padding: 15px;
    margin: 5px 0;
    border: 2px solid #ddd;
    cursor: pointer;
    font-size: 18px;
}

.ma-list-item:active {
    background: #e8f5e9;
}
```

---

## 5. Funktionale Gaps

### ❌ FEHLT: Komplette UI
- Keine HTML-Datei vorhanden
- Gesamte UI muss neu erstellt werden

### ❌ FEHLT: QR-Code-Scanner-Integration
- **Access:** Nutzt TextBox mit Auto-Submit
- **HTML:** Benötigt evtl. native Scanner-API
```javascript
// Option 1: Einfach (Input-Feld mit Barcode-Scanner)
<input type="number" id="qrScan">

// Option 2: Camera-API (komplex)
navigator.mediaDevices.getUserMedia({ video: true })
    .then(stream => { /* QR-Code aus Video decodieren */ });
```

### ❌ FEHLT: Echtzeit-Updates
- **Access:** Manuelle Requery nach jeder Aktion
- **HTML:** Sollte Auto-Refresh haben (alle 30 Sek?)
```javascript
setInterval(() => refreshLists(), 30000); // 30 Sekunden
```

### ❌ FEHLT: Sound-Feedback
- **Access:** `Beep` bei Erfolg/Fehler
- **HTML:** Web Audio API oder `<audio>`
```javascript
function playBeep(success = true) {
    const audio = new Audio(success ? 'success.mp3' : 'error.mp3');
    audio.play();
}
```

### ❌ FEHLT: Visuelles Feedback
- **Access:** Grünes Label bei Erfolg, Rotes bei Fehler
- **HTML:** Toast-Notifications oder Status-Banner
```javascript
function showStatus(message, type = 'success') {
    const statusDiv = document.getElementById('statusMsg');
    statusDiv.textContent = message;
    statusDiv.className = `status-message ${type}`;
    setTimeout(() => statusDiv.className = 'status-message', 3000);
}
```

### ❌ FEHLT: Popup für mehrere Schichten
- **Access:** `MA_Zeiterfassung_popup` öffnet Dialog
- **HTML:** Modal-Dialog mit Schicht-Auswahl
```javascript
async function showSchichtAuswahl(maId, vaId) {
    const schichten = await fetch(`/api/zeiterfassung/schichten/${vaId}/${maId}`).then(r => r.json());
    // Modal anzeigen mit Radio-Buttons für Schichten
}
```

### ❌ FEHLT: Offline-Fähigkeit
- **Access:** Lokale Datenbank → funktioniert offline
- **HTML:** Benötigt Service Worker + IndexedDB
```javascript
// Service Worker registrieren
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js');
}

// Offline-Queue für Check-Ins
const offlineQueue = [];
window.addEventListener('online', () => {
    offlineQueue.forEach(checkin => sendCheckin(checkin));
});
```

---

## 6. Backend-API-Anforderungen

### Neue Endpoints

```python
# api_server.py

@app.route('/api/zeiterfassung/einsaetze', methods=['GET'])
def get_einsaetze():
    """Liste aller Einsätze für Dropdown"""
    cursor.execute("""
        SELECT
            vad.VADatum_ID,
            vad.VA_ID,
            vad.VADatum,
            va.Auftrag,
            va.Objekt,
            k.kun_Firma,
            o.ObjOrt
        FROM tbl_VA_AnzTage vad
        INNER JOIN tbl_VA_Auftragstamm va ON vad.VA_ID = va.ID
        LEFT JOIN tbl_KD_Kundenstamm k ON va.Veranstalter_ID = k.ID
        LEFT JOIN tbl_OB_Objekt o ON va.Objekt_ID = o.ID
        WHERE vad.VADatum >= DATE('now', '-7 days')
        ORDER BY vad.VADatum DESC
    """)
    return jsonify(cursor.fetchall())

@app.route('/api/zeiterfassung/zuordnungen/<int:va_id>', methods=['GET'])
def get_zuordnungen(va_id):
    """Mitarbeiter die noch nicht eingecheckt sind"""
    vadatum_id = request.args.get('vadatum_id')
    cursor.execute("""
        SELECT
            z.ID AS Zuo_ID,
            z.MA_ID,
            m.Nachname || ' ' || m.Vorname AS MA_Name,
            z.VA_Start,
            z.VA_Ende
        FROM tbl_MA_VA_Zuordnung z
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON z.MA_ID = m.ID
        WHERE z.VA_ID = ?
          AND z.VADatum_ID = ?
          AND z.ID NOT IN (SELECT ZUO_ID FROM tbl_Zeiterfassung WHERE CheckOut_Zeit IS NULL)
        ORDER BY m.Nachname, m.Vorname
    """, (va_id, vadatum_id))
    return jsonify(cursor.fetchall())

@app.route('/api/zeiterfassung/checkins/<int:va_id>', methods=['GET'])
def get_checkins(va_id):
    """Eingecheckte Mitarbeiter"""
    cursor.execute("""
        SELECT
            t.ZUO_ID,
            t.MA_ID,
            m.Nachname || ' ' || m.Vorname AS MA_Name,
            t.CheckIn_Zeit,
            t.CheckIn_Original
        FROM tbl_Zeiterfassung t
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON t.MA_ID = m.ID
        WHERE t.VA_ID = ?
          AND t.CheckOut_Zeit IS NULL
        ORDER BY t.CheckIn_Zeit DESC
    """, (va_id,))
    return jsonify(cursor.fetchall())

@app.route('/api/zeiterfassung/checkouts/<int:va_id>', methods=['GET'])
def get_checkouts(va_id):
    """Ausgecheckte Mitarbeiter"""
    cursor.execute("""
        SELECT
            t.ZUO_ID,
            t.MA_ID,
            m.Nachname || ' ' || m.Vorname AS MA_Name,
            t.CheckIn_Zeit,
            t.CheckOut_Zeit,
            (JULIANDAY(t.CheckOut_Zeit) - JULIANDAY(t.CheckIn_Zeit)) * 24 AS Stunden
        FROM tbl_Zeiterfassung t
        INNER JOIN tbl_MA_Mitarbeiterstamm m ON t.MA_ID = m.ID
        WHERE t.VA_ID = ?
          AND t.CheckOut_Zeit IS NOT NULL
        ORDER BY t.CheckOut_Zeit DESC
    """, (va_id,))
    return jsonify(cursor.fetchall())

@app.route('/api/zeiterfassung/checkin', methods=['POST'])
def checkin():
    """Check-In durchführen"""
    data = request.json
    ma_id = data['maId']
    zuo_id = data.get('zuoId')
    va_id = data['vaId']
    vadatum_id = data['vaDatumId']

    # Zeit runden
    now = datetime.now()
    rounded_time = round_to_quarter_hour(now)

    # Prüfen: Bereits eingecheckt?
    existing = cursor.execute("""
        SELECT ZUO_ID FROM tbl_Zeiterfassung
        WHERE MA_ID = ? AND VA_ID = ? AND CheckOut_Zeit IS NULL
    """, (ma_id, va_id)).fetchone()

    if existing:
        return jsonify({'success': False, 'message': 'Bereits eingecheckt!'})

    # Falls keine Zuordnung → ungeplanter Check-In
    if not zuo_id:
        zuo_id = create_ungeplante_zuordnung(ma_id, va_id, vadatum_id)

    # Check-In speichern
    cursor.execute("""
        INSERT INTO tbl_Zeiterfassung (ZUO_ID, MA_ID, VA_ID, CheckIn_Zeit, CheckIn_Original, Status)
        VALUES (?, ?, ?, ?, ?, 'EINGECHECKT')
    """, (zuo_id, ma_id, va_id, rounded_time, now))

    # Zuordnung aktualisieren
    cursor.execute("""
        UPDATE tbl_MA_VA_Zuordnung
        SET MA_Start = ?, MVA_Start = ?
        WHERE ID = ?
    """, (rounded_time.time(), rounded_time, zuo_id))

    conn.commit()

    ma_name = cursor.execute("SELECT Nachname || ' ' || Vorname FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?", (ma_id,)).fetchone()[0]
    return jsonify({'success': True, 'message': f'CHECK-IN: {ma_name} - {rounded_time.strftime("%H:%M")}'})

@app.route('/api/zeiterfassung/checkout', methods=['POST'])
def checkout():
    """Check-Out durchführen"""
    # Ähnlich wie checkin, aber CheckOut_Zeit setzen
    # ...
```

---

## 7. Implementierungs-Roadmap

### Phase 1: Basis-UI (3-4h)
- [ ] HTML-Struktur (Header, Scan-Area, 3 Spalten)
- [ ] CSS für Tablet-Optimierung (große Touch-Targets)
- [ ] Einsatz-Dropdown mit Daten

### Phase 2: Backend-API (4-5h)
- [ ] Alle oben genannten Endpoints implementieren
- [ ] Rundungs-Logik in Python
- [ ] Ungeplante Check-Ins
- [ ] Transaktionssicherheit

### Phase 3: Check-In/Out-Logik (3-4h)
- [ ] QR-Scan-Input-Feld
- [ ] Auto-Submit bei Eingabe
- [ ] Check-In/Out API-Calls
- [ ] Listen-Refresh nach Aktion

### Phase 4: UX-Features (2-3h)
- [ ] Sound-Feedback (Beep)
- [ ] Visuelles Feedback (Toast/Status-Banner)
- [ ] Auto-Refresh (30 Sekunden)
- [ ] Fehlerbehandlung

### Phase 5: Erweiterte Features (3-4h)
- [ ] Mehrfach-Schichten-Popup
- [ ] Ändern-Funktionen (Zeit editieren)
- [ ] Löschen-Funktionen (Check-In/Out entfernen)
- [ ] Subunternehmer-Handling

### Phase 6: Offline-Support (optional, 4-6h)
- [ ] Service Worker
- [ ] IndexedDB für Offline-Queue
- [ ] Sync bei Online-Rückkehr

**Gesamt-Aufwand:** 15-22 Stunden (ohne Offline)

---

## 8. Technische Herausforderungen

### Challenge 1: Echtzeit-Performance
- **Problem:** Viele gleichzeitige Check-Ins (z.B. Schichtwechsel)
- **Lösung:** Optimistische UI-Updates + Background-Sync
```javascript
// Optimistisches Update
addToCheckedInList(maId, maName);
fetch('/api/zeiterfassung/checkin', { ... })
    .catch(() => removeFromCheckedInList(maId)); // Rollback bei Fehler
```

### Challenge 2: Tablet-Browsing
- **Problem:** Muss auf Tablets gut bedienbar sein
- **Lösung:** Responsive Design, große Touch-Targets (min 44x44px)

### Challenge 3: QR-Scanner-Hardware
- **Problem:** Verschiedene Scanner-Typen (USB, Bluetooth, Camera)
- **Lösung:** Scanner simuliert Tastatur → einfaches Input-Feld reicht

### Challenge 4: Viertelstunden-Rundung
- **Problem:** Muss genau wie Access runden (53-59 Min → nächste Stunde)
- **Lösung:** Exakt gleiche Logik in Python/JS portieren

### Challenge 5: Ungeplante Check-Ins
- **Problem:** MA ohne Einteilung → automatisch einplanen
- **Lösung:** Backend erstellt Zuordnung on-the-fly

---

## 9. Offene Fragen

1. **Welche Hardware wird genutzt?**
   - Tablets? Handys? Desktop?
   - QR-Scanner-Typ?
   - **Action:** Hardware-Anforderungen klären

2. **Offline-Betrieb erforderlich?**
   - Funktioniert WLAN immer?
   - Oder muss Offline-Queue implementiert werden?
   - **Action:** Netzwerk-Zuverlässigkeit prüfen

3. **Foto-Anzeige bei Check-In?**
   - Soll MA-Foto angezeigt werden?
   - **Action:** UX-Feedback einholen

4. **Subunternehmer-Bemerkung?**
   - Wie wird "Bemerkungen"-Feld eingegeben?
   - Popup? Zusätzliches Feld?
   - **Action:** VBA-Code für Subunternehmer-Flow analysieren

5. **Check-In/Out-Historie?**
   - Wie lange bleiben Ausgecheckte in Liste?
   - Nur heute? Oder mehrere Tage?
   - **Action:** Business-Regel definieren

---

## Priorität: HOCH

**Begründung:**
- **Produktiv genutzt** (täglich/mehrmals pro Tag)
- Echtzeit-Funktion (kritisch für Lohnabrechnung)
- Tablet-Nutzung → HTML ideal dafür
- Ersetzt manuelle Zeitzettel

**Empfehlung:**
1. **Phase 1-4 priorisieren** (Basis + UX)
2. Offline-Support später (nur wenn nötig)
3. Tablet-Testing von Anfang an
4. User-Feedback früh einholen (nach Phase 3)

**Abhängigkeiten:**
- API-Server muss laufen
- WLAN/Netzwerk am Einsatzort
- Evtl. QR-Scanner-Hardware (USB oder Bluetooth)

**Risiko-Mitigation:**
- Fallback: Access-Version bleibt parallel verfügbar
- Pilot-Test mit einem Einsatz vor Rollout
- Ausführliches User-Training
