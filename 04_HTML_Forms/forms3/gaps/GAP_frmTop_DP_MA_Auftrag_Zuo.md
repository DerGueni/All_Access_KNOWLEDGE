# Gap-Analyse: frmTop_DP_MA_Auftrag_Zuo

**Datum:** 2026-01-12
**Formular-Typ:** Popup - Mitarbeiter-Auftrag Zuordnung
**Priorität:** HOCH

---

## 1. Übersicht

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Formular-Typ** | Popup (ungebunden) | Modal Dialog | ✅ Korrekt |
| **Record Source** | Keine (ungebunden) | API-gesteuert | ✅ Korrekt |
| **Zweck** | MA zu Schicht zuordnen | MA zu Schicht zuordnen | ✅ Identisch |
| **Navigation** | Nein | Nein | ✅ Passend für Popup |
| **Modal** | Ja (Popup) | Ja (Dialog) | ✅ Korrekt |

---

## 2. Controls - Detailvergleich

### 2.1 Access Controls

**ComboBox: cboMA_ID**
- Position: 1155/60, 2850x255
- Bound Column: 1
- Row Source: `tbl_MA_Mitarbeiterstamm` (ID, Name)
- **Status:** GESPERRT (wird von außen gesetzt)

**ListBox: ListeAuft (Auftragsliste)**
- Position: 75/660, 3940x2094
- 6 Spalten: VA_ID, VADatum_ID, Datum, ObjOrt, Ist, Soll
- Row Source: Offene Aufträge mit freien Plätzen
- OnClick: VBA-Event → lädt Schichten in LstSchicht

**ListBox: LstSchicht (Schichtenliste)**
- Position: 4129/660, 1343x2094
- 4 Spalten: VAStart_ID, VADatum_ID, von, bis
- Row Source: Verfügbare Schichten für gewählten Auftrag
- Zeigt nur Schichten mit freien Plätzen

**Button: btn_Auswahl_Zuo**
- Caption: "Zuordnung"
- BackColor: #D7B5D5 (Rosa/Violett)
- OnClick: VBA → Zuordnung speichern

**Button: Befehl38**
- Caption: "Schließen"
- OnClick: Formular schließen

**Hidden Controls:**
- dtPlanDatum (TextBox, versteckt)
- MAemail (TextBox, versteckt)

### 2.2 HTML Controls

**Dialog-Header:**
- Title: "Mitarbeiter-Auftrag Zuordnung" ✅
- Close Button (X) ✅

**Toolbar:**
- Filter-Dropdown: Alle MA / Nur Verfügbare / Mit Qualifikation ✅
- Suchfeld: MA suchen ✅
- Checkbox: Nur aktive MA ✅

**Schicht-Info (Links):**
- Auftrag, Objekt, Kunde ✅
- Datum, Zeit, Position ✅
- MA Soll / Ist / Offen / Ausgewählt ✅
- **Statische Demo-Daten!** ⚠️

**MA-Liste (Rechts):**
- Name, Qualifikationen, Status ✅
- Checkbox für Auswahl ✅
- Farbcodierung:
  - Grau: Bereits zugeordnet ✅
  - Weiß: Verfügbar ✅
  - Hellgrau: Nicht verfügbar ✅

**Footer:**
- Buttons: "Alle wählen", "Abwählen", "Abbrechen", "Zuordnen" ✅

### 2.3 Fehlende/Unterschiedliche Controls

❌ **KRITISCH - Access-Features fehlen:**
1. **Auftragsliste** - FEHLT komplett!
   - Access: 2 Listen (Aufträge + Schichten)
   - HTML: Nur MA-Liste
2. **Dynamisches Laden** - FEHLT!
   - Access: Auftrag wählen → Schichten laden
   - HTML: Statische Schicht-Info

⚠️ **Workflow-Unterschied:**
- **Access:** Auftrag wählen → Schicht wählen → MA zuordnen
- **HTML:** Schicht ist vorgegeben → MA auswählen

**Frage:** Wie wird das Formular aufgerufen?
- Access: Standalone (keine Vorgaben)
- HTML: Aus Dienstplan mit vorgewählter Schicht?

---

## 3. Datenquellen

### Access SQL-Queries

**ListeAuft (Offene Aufträge):**
```sql
SELECT tbl_VA_AnzTage.VA_ID,
       tbl_VA_AnzTage.ID AS VADatum_ID,
       tbl_VA_AnzTage.VADatum AS Datum,
       fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjOrt,
       tbl_VA_AnzTage.TVA_Ist AS Ist,
       tbl_VA_AnzTage.TVA_Soll AS Soll
FROM tbl_VA_Auftragstamm
INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE tbl_VA_AnzTage.VADatum = #2016-01-01#
  AND tbl_VA_AnzTage.TVA_Offen = True
  AND tbl_VA_AnzTage.TVA_Soll > 0;
```

**LstSchicht (Verfügbare Schichten):**
```sql
SELECT tbl_VA_Start.ID AS VAStart_ID,
       tbl_VA_Start.VADatum_ID,
       Format([VA_Start],'Short Time') AS von,
       Format([VA_Ende],'Short Time') AS bis
FROM tbl_VA_Start
WHERE tbl_VA_Start.VADatum_ID = 135173
  AND tbl_VA_Start.VA_ID = 570
  AND tbl_VA_Start.MA_Anzahl > 0
  AND tbl_VA_Start.MA_Anzahl_Ist < [MA_Anzahl]
ORDER BY tbl_VA_Start.VA_Start;
```

### HTML API-Endpoints
⚠️ **Fehlend/Unvollständig:**
- `/api/auftraege/offen?datum=X` - Offene Aufträge FEHLT
- `/api/schichten/verfuegbar?va_id=X&datum_id=Y` - FEHLT
- `/api/mitarbeiter/verfuegbar?schicht_id=X` - FEHLT
- `/api/zuordnungen` - POST zum Speichern (vorhanden?)

---

## 4. Funktionalität

### 4.1 Implementierte Features
| Feature | Access | HTML | Status |
|---------|--------|------|--------|
| Auftragsliste | ✅ | ❌ | FEHLT! |
| Schichtenliste | ✅ | ⚠️ | Statisch |
| MA-Liste | ✅ | ✅ | Vorhanden |
| MA-Filter | ❌ | ✅ | HTML besser! |
| MA-Suche | ❌ | ✅ | HTML besser! |
| Mehrfach-Auswahl | ❌ | ✅ | HTML besser! |
| Qualifikations-Anzeige | ❌ | ✅ | HTML besser! |
| Status-Anzeige (belegt/frei) | ❌ | ✅ | HTML besser! |
| Zuordnung speichern | ✅ | ⚠️ | Unklar |

### 4.2 Fehlende Features
❌ **KRITISCH:**
1. **Auftragsliste fehlt** - Kann nicht zwischen Aufträgen wählen
2. **Schichtenliste fehlt** - Kann nicht zwischen Schichten wählen
3. **Dynamisches Laden fehlt** - Schicht-Info statisch

⚠️ **WICHTIG - Workflow-Frage:**
- Wird Formular MIT vorgewählter Schicht aufgerufen?
- Oder soll User selbst Schicht wählen?

---

## 5. Layout & Design

### Access
- Kompaktes Popup-Formular (ca. 5500x2800 Twips)
- 3-Spalten-Layout:
  - Links: MA-Auswahl (ComboBox)
  - Mitte: Auftragsliste (ListBox)
  - Rechts: Schichtenliste (ListBox)
- Buttons unten: Zuordnen, Schließen
- Standard Access-Farben

### HTML
- **Moderner Modal-Dialog** mit Schatten
- **2-Spalten-Layout:**
  - Links: Schicht-Info (25%)
  - Rechts: MA-Liste (75%)
- **Toolbar** mit Filter/Suche
- **Responsive:** Passt sich an Bildschirmgröße an
- **CONSYS-Farben:** #4316B2 (Header), Weiß (Content)

**HTML ist moderner, aber funktional unvollständig!** ⚠️

---

## 6. Events & VBA-Logik

### Access VBA

**ListeAuft_Click():**
```vba
' Bei Auftragswahl: Schichtenliste aktualisieren
Me!LstSchicht.RowSource = "SELECT ... WHERE VA_ID = " & Me!ListeAuft
Me!LstSchicht.Requery
```

**btn_Auswahl_Zuo_Click():**
```vba
' Zuordnung speichern
INSERT INTO tbl_MA_VA_Planung (MA_ID, VAStart_ID, VADatum_ID, VA_ID)
VALUES (Me!cboMA_ID, Me!LstSchicht, ...)
' Formular schließen
DoCmd.Close
```

### HTML (frmTop_DP_MA_Auftrag_Zuo.logic.js)
⚠️ **Logic-Datei existiert:**
Pfad: `forms3/logic/frmTop_DP_MA_Auftrag_Zuo.logic.js`

**Erwartete Funktionen:**
- `loadSchichtInfo(schichtId)` - Schicht-Daten laden
- `loadMitarbeiter(filter)` - MA-Liste laden
- `filterMitarbeiter()` - Client-seitiger Filter
- `selectMitarbeiter(maId)` - MA auswählen
- `saveZuordnung()` - POST zu /api/zuordnungen
- `closeDialog()` - Fenster schließen

---

## 7. Gaps & Risiken

### 7.1 Kritische Gaps
❌ **SHOWSTOPPER:**
1. **Auftragsliste fehlt** - KEINE Möglichkeit Auftrag zu wählen
2. **Schichtenliste fehlt** - KEINE Möglichkeit Schicht zu wählen
3. **Workflow unklar** - Wie wird Schicht vorgegeben?

### 7.2 Moderate Gaps
⚠️ **API-Gaps:**
- `/api/auftraege/offen` - FEHLT
- `/api/schichten/verfuegbar` - FEHLT
- `/api/mitarbeiter/verfuegbar?schicht=X` - FEHLT
- `/api/zuordnungen` POST - Prüfen ob vorhanden

⚠️ **Schicht-Info statisch:**
- Demo-Daten hart-codiert
- Keine API-Integration

### 7.3 Nice-to-Have
💡 **Zusätzliche Features (HTML besser):**
- MA-Filter (Verfügbar/Qualifikation) ✅
- MA-Suche ✅
- Mehrfach-Auswahl ✅
- Qualifikations-Badge ✅
- Status-Anzeige ✅

---

## 8. Empfohlene Maßnahmen

### Priorität 1 (Sofort - Klärung erforderlich!)
1. ⚠️ **KLÄREN:** Aufruf-Kontext
   - Option A: Formular wird MIT vorgewählter Schicht aufgerufen → OK
   - Option B: User soll Schicht selbst wählen → Auftrag/Schicht-Listen hinzufügen

2. ⚠️ **ENTSCHEIDEN:** Workflow
   - Wenn Option A: API für `/api/schichten/:id/info` erstellen
   - Wenn Option B: Kompletter Umbau nötig

### Priorität 2 (Kurzfristig - falls Option A)
3. ✅ **API erstellen:**
   - `GET /api/schichten/:id/info` - Schicht-Details
   - `GET /api/mitarbeiter/verfuegbar?schicht=X` - Verfügbare MA
   - `POST /api/zuordnungen` - Zuordnung speichern

4. ✅ **Logic-Datei implementieren:**
   - Schicht-Info dynamisch laden
   - MA-Liste mit Verfügbarkeit
   - Zuordnung speichern

### Priorität 3 (Mittelfristig - falls Option B)
5. ⚠️ **Auftragsliste hinzufügen:**
   - Neuer Bereich: Aufträge auswählen
   - Dynamisches Laden von Schichten

6. ⚠️ **3-Stufen-Workflow:**
   - Schritt 1: Auftrag wählen
   - Schritt 2: Schicht wählen
   - Schritt 3: MA zuordnen

---

## 9. Technische Details

### API-Endpoint (api_server.py) - NEU ERFORDERLICH

```python
@app.route('/api/schichten/<int:schicht_id>/info', methods=['GET'])
def get_schicht_info(schicht_id):
    """
    Liefert alle Infos zu einer Schicht für das Zuordnungs-Formular
    """
    sql = """
        SELECT
            s.ID AS VAStart_ID,
            s.VA_ID,
            s.VADatum_ID,
            s.VA_Start,
            s.VA_Ende,
            s.MA_Anzahl AS Soll,
            s.MA_Anzahl_Ist AS Ist,
            (s.MA_Anzahl - s.MA_Anzahl_Ist) AS Offen,
            v.Auftrag,
            v.Objekt,
            v.Ort,
            vd.VADatum,
            k.kun_Firma AS Kunde
        FROM tbl_VA_Start s
        INNER JOIN tbl_VA_Auftragstamm v ON s.VA_ID = v.ID
        INNER JOIN tbl_VA_AnzTage vd ON s.VADatum_ID = vd.ID
        LEFT JOIN tbl_KD_Kundenstamm k ON v.Veranstalter_ID = k.kun_Id
        WHERE s.ID = ?
    """

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(sql, (schicht_id,))
    row = cursor.fetchone()
    conn.close()

    if not row:
        return jsonify({'error': 'Schicht nicht gefunden'}), 404

    # Convert to dict...
    return jsonify(result)


@app.route('/api/mitarbeiter/verfuegbar', methods=['GET'])
def get_verfuegbare_mitarbeiter():
    """
    Liefert MA die für eine Schicht verfügbar sind
    """
    schicht_id = request.args.get('schicht_id', type=int)
    datum = request.args.get('datum')  # YYYY-MM-DD

    # 1. Alle aktiven MA
    # 2. MINUS: MA mit Abwesenheit an diesem Datum
    # 3. MINUS: MA bereits dieser Schicht zugeordnet
    # 4. MINUS: MA mit überlappender Schicht

    sql = """
        SELECT m.ID, m.Nachname, m.Vorname, m.Email,
               m.Qualifikationen,
               CASE
                   WHEN EXISTS(SELECT 1 FROM tbl_MA_VA_Planung
                              WHERE MA_ID = m.ID AND VAStart_ID = ?) THEN 'zugeordnet'
                   WHEN EXISTS(SELECT 1 FROM tbl_MA_NVerfuegZeiten nv
                              WHERE nv.MA_ID = m.ID
                              AND ? BETWEEN nv.vonDat AND nv.bisDat) THEN 'abwesend'
                   ELSE 'verfuegbar'
               END AS Status
        FROM tbl_MA_Mitarbeiterstamm m
        WHERE m.IstAktiv = True
    """

    # Execute und return...
```

### Logic-File Implementierung

```javascript
// frmTop_DP_MA_Auftrag_Zuo.logic.js
import { Bridge } from '../api/bridgeClient.js';

let state = {
    schichtId: null,
    schichtInfo: null,
    mitarbeiter: [],
    selectedMAs: new Set()
};

// Beim Öffnen des Dialogs
export async function initDialog(schichtId) {
    state.schichtId = schichtId;

    // Schicht-Info laden
    const schichtInfo = await fetch(`/api/schichten/${schichtId}/info`);
    state.schichtInfo = await schichtInfo.json();
    renderSchichtInfo();

    // Verfügbare MA laden
    const maResponse = await fetch(`/api/mitarbeiter/verfuegbar?schicht_id=${schichtId}&datum=${state.schichtInfo.VADatum}`);
    state.mitarbeiter = await maResponse.json();
    renderMitarbeiterListe();
}

function renderSchichtInfo() {
    document.getElementById('lblAuftrag').textContent = state.schichtInfo.Auftrag;
    document.getElementById('lblObjekt').textContent = state.schichtInfo.Objekt;
    document.getElementById('lblKunde').textContent = state.schichtInfo.Kunde;
    document.getElementById('lblDatum').textContent = formatDate(state.schichtInfo.VADatum);
    document.getElementById('lblZeit').textContent = `${state.schichtInfo.VA_Start} - ${state.schichtInfo.VA_Ende}`;
    document.getElementById('lblSoll').textContent = state.schichtInfo.Soll;
    document.getElementById('lblIst').textContent = state.schichtInfo.Ist;
    document.getElementById('lblOffen').textContent = state.schichtInfo.Offen;
}

async function saveZuordnung() {
    const response = await fetch('/api/zuordnungen', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            VAStart_ID: state.schichtId,
            MA_IDs: Array.from(state.selectedMAs),
            VA_ID: state.schichtInfo.VA_ID,
            VADatum_ID: state.schichtInfo.VADatum_ID
        })
    });

    if (response.ok) {
        showToast('Zuordnung gespeichert', 'success');
        setTimeout(() => window.close(), 1000);
    } else {
        showToast('Fehler beim Speichern', 'error');
    }
}
```

---

## 10. Zusammenfassung

### ✅ Stärken des HTML-Formulars
1. **Modernes Dialog-Design** mit Shadow
2. **Bessere MA-Suche** und Filter
3. **Mehrfach-Auswahl** (Access: nur 1 MA)
4. **Qualifikations-Anzeige** und Status
5. **Responsive Layout**

### ❌ Kritische Schwächen
1. **Auftragsliste fehlt** (Access-Hauptfeature)
2. **Schichtenliste fehlt** (Access-Hauptfeature)
3. **Statische Demo-Daten** statt API
4. **Workflow unklar** (wie wird Schicht vorgegeben?)

### ⚠️ Entscheidungsbedarf
**Frage:** Wie soll das Formular genutzt werden?
- **Variante A:** Aus Dienstplan aufgerufen mit vorgewählter Schicht → 6-8 Stunden Aufwand
- **Variante B:** Standalone mit Auftrag/Schicht-Wahl → 2-3 Tage Aufwand

### 🎯 Bewertung
**Status (Variante A):** 60% FERTIG
**Status (Variante B):** 30% FERTIG
**Risiko:** HOCH (Workflow-Klärung erforderlich!)
**Aufwand:**
- Variante A: 6-8 Stunden (API + Logic)
- Variante B: 2-3 Tage (Komplett-Umbau)

**Fazit:** HTML hat modernes UI, aber funktionale Lücken! Workflow-Klärung DRINGEND erforderlich! ⚠️
