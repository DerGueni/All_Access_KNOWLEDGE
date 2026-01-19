# AUDIT: Geo/Entfernung Feature in frm_MA_VA_Schnellauswahl

**Erstellt:** 2026-01-05
**Betroffene Dateien:**
- Access VBA: `Form_frm_MA_VA_Schnellauswahl.bas`
- HTML: `forms3/frm_MA_VA_Schnellauswahl.html`
- Logic: `forms3/logic/frm_MA_VA_Schnellauswahl.logic.js`

---

## 1. WIE FUNKTIONIERT ES IN ACCESS (Schritt fuer Schritt)

### 1.1 Button "Entfernung" (`cmdListMA_Entfernung`)

**Position im Formular:**
Unterhalb der Mitarbeiter-Liste, neben Button "Standard"

**VBA-Event-Handler:** `cmdListMA_Entfernung_Click()` in `Form_frm_MA_VA_Schnellauswahl.bas` (Zeile 1224-1238)

```vba
Private Sub cmdListMA_Entfernung_Click()
    Dim lngObjektID As Long
    Dim strSQL As String
    lngObjektID = Nz(DLookup("Objekt_ID", "tbl_VA_Auftragstamm", "ID=" & Nz(Me.VA_ID, 0)), 0)
    If lngObjektID = 0 Then
        MsgBox "Kein Objekt fuer diesen Auftrag hinterlegt!", vbExclamation
        Exit Sub
    End If
    strSQL = "SELECT MA.ID AS MA_ID, MA.Nachname & ', ' & MA.Vorname & ' (' & Format(Nz(D.Entf_KM,0),'0.0') & ' km)' AS Anzeige " & _
             "FROM (ztbl_MA_Schnellauswahl AS S INNER JOIN tbl_MA_Mitarbeiterstamm AS MA ON MA.ID = S.MA_ID) " & _
             "LEFT JOIN tbl_MA_Objekt_Entfernung AS D ON D.MA_ID = MA.ID AND D.Objekt_ID = " & lngObjektID & " " & _
             "ORDER BY Nz(D.Entf_KM,9999), MA.Nachname, MA.Vorname"
    Me!List_MA.RowSource = strSQL
    Me!List_MA.Requery
    bEntfernungsModus = True
End Sub
```

### 1.2 Ablauf im Detail

1. **Objekt-ID ermitteln:**
   - Liest `Objekt_ID` aus `tbl_VA_Auftragstamm` fuer den aktuellen Auftrag (`VA_ID`)
   - Falls kein Objekt zugeordnet: Fehlermeldung und Abbruch

2. **SQL-Abfrage erstellen:**
   - Basis: `ztbl_MA_Schnellauswahl` (temporaere Tabelle mit gefilterten MA)
   - LEFT JOIN auf `tbl_MA_Objekt_Entfernung` fuer die Entfernungswerte
   - Formatierung: `Name (X.X km)`
   - Sortierung: Nach Entfernung aufsteigend (NULL-Werte = 9999 km)

3. **ListBox aktualisieren:**
   - RowSource = neue SQL-Abfrage
   - Requery ausfuehren
   - Flag `bEntfernungsModus = True` setzen

### 1.3 Woher kommen die Koordinaten?

**Mitarbeiter-Koordinaten (Wohnort):**
- Tabelle: `tbl_MA_Geo`
- Felder: `MA_ID`, `Strasse`, `PLZ`, `Ort`, `Lat`, `Lon`
- Befuellt durch: `GeocodeMA()` in `mdl_GeoDistanz.bas`
- Quelle: OpenStreetMap Nominatim API

**Objekt-Koordinaten:**
- Tabelle: `tbl_OB_Geo`
- Felder: `Objekt_ID`, `Strasse`, `PLZ`, `Ort`, `Lat`, `Lon`
- Befuellt durch: `GeocodeObjekt()` in `mdl_GeoDistanz.bas`
- Quelle: OpenStreetMap Nominatim API

### 1.4 Wie wird die Entfernung berechnet?

**Haversine-Formel** in `mdl_GeoDistanz1.bas`:

```vba
Public Function DistanceKm(Lat1 As Double, Lon1 As Double, Lat2 As Double, Lon2 As Double) As Double
    Const PI As Double = 3.14159265358979
    Const EARTH_RADIUS_KM As Double = 6371

    If Lat1 = 0 Or Lon1 = 0 Or Lat2 = 0 Or Lon2 = 0 Then
        DistanceKm = 9999
        Exit Function
    End If

    dLat = (Lat2 - Lat1) * PI / 180
    dLon = (Lon2 - Lon1) * PI / 180
    a = Sin(dLat / 2) * Sin(dLat / 2) + Cos(Lat1 * PI / 180) * Cos(Lat2 * PI / 180) * Sin(dLon / 2) * Sin(dLon / 2)
    c = 2 * Atn(Sqr(a) / Sqr(1 - a))
    DistanceKm = Round(EARTH_RADIUS_KM * c, 2)
End Function
```

**Batch-Berechnung** in `mdl_Distanzberechnung.bas`:

```vba
Public Function CalcDistanceForObjekt(lngObjektID As Long) As Long
    ' Berechnet Entfernung von ALLEN Mitarbeitern zu EINEM Objekt
    ' Speichert in tbl_MA_Objekt_Entfernung
End Function

Public Function BuildAllDistances() As Long
    ' Berechnet ALLE MA x Objekt Kombinationen
End Function
```

### 1.5 Entfernungs-Tabelle

**Tabelle:** `tbl_MA_Objekt_Entfernung`

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| MA_ID | Long | Mitarbeiter-ID |
| Objekt_ID | Long | Objekt-ID |
| Entf_KM | Double | Entfernung in Kilometern |
| LetzteAktualisierung | DateTime | Wann berechnet |
| Quelle | String | "Haversine" |

### 1.6 Wie wird die Entfernung angezeigt?

Im Listbox `List_MA`:
- Standard-Modus: Name, Stunden, Beginn, Ende, Grund
- Entfernungs-Modus: Name + Entfernung im Format `Nachname, Vorname (12.5 km)`
- Sortiert nach Entfernung aufsteigend
- MA ohne Geo-Daten erscheinen am Ende (9999 km)

---

## 2. WAS IST IM HTML VORHANDEN?

### 2.1 Button "Entfernung" - VORHANDEN

```html
<button class="btn" id="cmdListMA_Entfernung">Entfernung</button>
```
Position: Zeile 535 in forms3/frm_MA_VA_Schnellauswahl.html

### 2.2 Event-Handler - TEILWEISE VORHANDEN

```javascript
function cmdListMA_Entfernung_Click() {
    if (!formState.Objekt_ID || formState.Objekt_ID === 0) {
        alert('Kein Objekt für diesen Auftrag hinterlegt!');
        return;
    }
    formState.bEntfernungsModus = true;
    if (window.Bridge) {
        Bridge.loadData('mitarbeiter_entfernung', null, {
            objekt_id: formState.Objekt_ID,
            va_id: formState.VA_ID,
            vadatum_id: formState.VADatum_ID
        });
    }
}
```

### 2.3 Spalten-Header fuer Entfernung - VORHANDEN (versteckt)

```html
<span id="colEntfernung" style="flex: 1; display: none;">Entf.</span>
```

### 2.4 CSS fuer Entfernungs-Farbcodierung - VORHANDEN

```css
.entf-gruen { color: #008000; font-weight: bold; }
.entf-gelb { color: #B8860B; font-weight: bold; }
.entf-rot { color: #CC0000; font-weight: bold; }
.entf-unbekannt { color: #808080; font-style: italic; }
```

---

## 3. WAS FEHLT IM HTML

### 3.1 Kritische Luecken

| Nr | Was fehlt | Auswirkung |
|----|-----------|------------|
| 1 | API-Endpoint `/api/mitarbeiter_entfernung` | Keine Entfernungsdaten ladbar |
| 2 | Haversine-Berechnung in JavaScript | Keine Live-Berechnung moeglich |
| 3 | Geocoding-Funktion | Koordinaten koennen nicht ermittelt werden |
| 4 | Entfernungs-Spalte in MA-Liste | Entfernung wird nicht angezeigt |
| 5 | Sortierung nach Entfernung | MA werden nicht nach Naehe sortiert |

### 3.2 Fehlende Logik in `frm_MA_VA_Schnellauswahl.logic.js`

- Keine Entfernungs-Berechnung
- Keine spezielle Ansicht fuer Entfernungs-Modus
- Keine Farbcodierung nach Entfernung

---

## 4. IMPLEMENTIERUNGSVORSCHLAG FUER HTML

### 4.1 Haversine-Funktion in JavaScript

```javascript
// geo-utils.js
const GeoUtils = {
    EARTH_RADIUS_KM: 6371,

    /**
     * Berechnet Entfernung zwischen zwei Koordinaten (Haversine)
     */
    distanceKm(lat1, lon1, lat2, lon2) {
        if (!lat1 || !lon1 || !lat2 || !lon2) return 9999;

        const toRad = (deg) => deg * Math.PI / 180;

        const dLat = toRad(lat2 - lat1);
        const dLon = toRad(lon2 - lon1);

        const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                  Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
                  Math.sin(dLon/2) * Math.sin(dLon/2);

        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

        return Math.round(this.EARTH_RADIUS_KM * c * 10) / 10; // 1 Dezimalstelle
    },

    /**
     * Farbklasse basierend auf Entfernung
     */
    getEntfernungsKlasse(km) {
        if (km === null || km === undefined || km >= 9999) return 'entf-unbekannt';
        if (km <= 15) return 'entf-gruen';
        if (km <= 30) return 'entf-gelb';
        return 'entf-rot';
    },

    /**
     * Formatiert Entfernung fuer Anzeige
     */
    formatEntfernung(km) {
        if (km === null || km === undefined || km >= 9999) return '?';
        return km.toFixed(1) + ' km';
    }
};

export default GeoUtils;
```

### 4.2 Geocoding via Nominatim (Browser)

```javascript
// geocoding.js
async function geocodeAdresse(strasse, plz, ort, land = 'Germany') {
    const adresse = `${strasse}, ${plz} ${ort}, ${land}`;
    const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(adresse)}&format=json&limit=1`;

    try {
        const response = await fetch(url, {
            headers: { 'User-Agent': 'ConsysHTMLApp/1.0' }
        });
        const data = await response.json();

        if (data && data.length > 0) {
            return {
                lat: parseFloat(data[0].lat),
                lon: parseFloat(data[0].lon),
                success: true
            };
        }
        return { lat: 0, lon: 0, success: false, error: 'Keine Koordinaten gefunden' };
    } catch (err) {
        return { lat: 0, lon: 0, success: false, error: err.message };
    }
}
```

### 4.3 API-Endpoint hinzufuegen (api_server.py)

```python
@app.route('/api/mitarbeiter_entfernung', methods=['GET'])
def get_mitarbeiter_entfernung():
    """
    Liefert Mitarbeiter mit Entfernung zu einem Objekt
    Parameter: objekt_id (required)
    """
    objekt_id = request.args.get('objekt_id', type=int)
    if not objekt_id:
        return jsonify({'success': False, 'error': 'objekt_id required'})

    sql = """
        SELECT
            MA.ID AS MA_ID,
            MA.Nachname,
            MA.Vorname,
            MA.IstAktiv,
            MG.Lat AS MA_Lat,
            MG.Lon AS MA_Lon,
            OG.Lat AS Obj_Lat,
            OG.Lon AS Obj_Lon,
            D.Entf_KM
        FROM tbl_MA_Mitarbeiterstamm AS MA
        LEFT JOIN tbl_MA_Geo AS MG ON MG.MA_ID = MA.ID
        LEFT JOIN tbl_OB_Geo AS OG ON OG.Objekt_ID = ?
        LEFT JOIN tbl_MA_Objekt_Entfernung AS D ON D.MA_ID = MA.ID AND D.Objekt_ID = ?
        WHERE MA.IstAktiv = True
        ORDER BY IIF(D.Entf_KM IS NULL, 9999, D.Entf_KM), MA.Nachname
    """

    result = execute_query(sql, [objekt_id, objekt_id])
    return jsonify({'success': True, 'data': result})
```

### 4.4 Mitarbeiter-Liste mit Entfernung rendern

```javascript
function renderMitarbeiterListeEntfernung(mitarbeiter, objektKoords) {
    const listBody = document.getElementById('List_MA_Body');
    const colEntf = document.getElementById('colEntfernung');

    // Entfernungs-Spalte einblenden
    if (colEntf) colEntf.style.display = '';

    // Mitarbeiter mit Entfernung anreichern und sortieren
    const maWithDistance = mitarbeiter.map(ma => {
        let entf = ma.Entf_KM;

        // Falls keine gespeicherte Entfernung: Live berechnen
        if (entf === null && ma.MA_Lat && ma.MA_Lon && objektKoords.lat && objektKoords.lon) {
            entf = GeoUtils.distanceKm(ma.MA_Lat, ma.MA_Lon, objektKoords.lat, objektKoords.lon);
        }

        return { ...ma, Entf_KM: entf };
    });

    // Sortieren nach Entfernung
    maWithDistance.sort((a, b) => (a.Entf_KM || 9999) - (b.Entf_KM || 9999));

    // Rendern
    listBody.innerHTML = maWithDistance.map(ma => {
        const entfKlasse = GeoUtils.getEntfernungsKlasse(ma.Entf_KM);
        const entfText = GeoUtils.formatEntfernung(ma.Entf_KM);

        return `
            <div class="listbox-row" data-id="${ma.MA_ID}">
                <span style="flex: 2;">${ma.Nachname}, ${ma.Vorname}</span>
                <span style="flex: 1;">${ma.Stunden || ''}</span>
                <span style="flex: 1;">${ma.Beginn || ''}</span>
                <span style="flex: 1;">${ma.Ende || ''}</span>
                <span style="flex: 1;"></span>
                <span style="flex: 1;" class="${entfKlasse}">${entfText}</span>
            </div>
        `;
    }).join('');
}
```

### 4.5 Umschalten zwischen Standard und Entfernung

```javascript
function cmdListMA_Standard_Click() {
    formState.bEntfernungsModus = false;
    document.getElementById('colEntfernung').style.display = 'none';
    zf_MA_Selektion(); // Laedt Standard-Ansicht
}

function cmdListMA_Entfernung_Click() {
    if (!formState.Objekt_ID) {
        alert('Kein Objekt fuer diesen Auftrag hinterlegt!');
        return;
    }

    formState.bEntfernungsModus = true;

    // Objekt-Koordinaten laden
    Bridge.execute('getObjektGeo', { objekt_id: formState.Objekt_ID })
        .then(geo => {
            if (geo && geo.Lat && geo.Lon) {
                formState.objektKoords = { lat: geo.Lat, lon: geo.Lon };
                loadMitarbeiterMitEntfernung();
            } else {
                alert('Keine Geo-Daten fuer dieses Objekt vorhanden!');
            }
        });
}

function loadMitarbeiterMitEntfernung() {
    Bridge.loadData('mitarbeiter_entfernung', null, {
        objekt_id: formState.Objekt_ID
    });
}
```

---

## 5. ZUSAMMENFASSUNG

### Access VBA (Status: VOLLSTAENDIG)
- Button vorhanden und funktional
- Geocoding via Nominatim
- Haversine-Berechnung
- Entfernungstabelle gepflegt
- Sortierung nach Naehe
- Anzeige im Listbox

### HTML/JavaScript (Status: TEILWEISE)
- Button vorhanden
- Event-Handler vorhanden (aber unvollstaendig)
- CSS-Klassen vorhanden
- **FEHLT:** API-Endpoint, Haversine-JS, Geocoding-JS, Rendering

### Prioritaet der Implementierung
1. **Hoch:** API-Endpoint `/api/mitarbeiter_entfernung`
2. **Hoch:** JavaScript Haversine-Funktion
3. **Mittel:** Entfernungs-Rendering in Liste
4. **Niedrig:** Live-Geocoding (kann zunaechst nur gespeicherte Werte nutzen)

---

## 6. RELEVANTE DATEIEN

### VBA Module
- `/exports/vba/forms/Form_frm_MA_VA_Schnellauswahl.bas`
- `/exports/vba/modules/mdl_GeoDistanz.bas`
- `/exports/vba/modules/mdl_GeoDistanz1.bas` (enthaelt DistanceKm)
- `/exports/vba/modules/mdl_Distanzberechnung.bas`
- `/exports/vba/modules/mdl_frm_MA_VA_Schnellauswahl_Code.bas`

### HTML/JS
- `/04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html`
- `/04_HTML_Forms/forms3/logic/frm_MA_VA_Schnellauswahl.logic.js`

### Tabellen (Access Backend)
- `tbl_MA_Geo` - MA-Koordinaten
- `tbl_OB_Geo` - Objekt-Koordinaten
- `tbl_MA_Objekt_Entfernung` - Berechnete Entfernungen
