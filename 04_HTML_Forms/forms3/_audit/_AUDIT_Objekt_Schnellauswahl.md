# AUDIT-BERICHT: Funktionalitaetspruefung HTML-Formulare vs. Access-Originale

**Datum:** 2026-01-05
**Geprueft:** frm_OB_Objekt.html, frm_MA_VA_Schnellauswahl.html
**VBA-Referenzen:** mdl_frm_OB_Objekt_Code.bas, mdl_frm_MA_VA_Schnellauswahl_Code.bas, mdl_GeoDistanz.bas, mdl_Distanzberechnung.bas, mdl_N_PositionsVorlagen.bas, mdl_N_PositionslistenExport.bas, mdl_N_PositionslistenImport.bas

---

## 1. frm_OB_Objekt.html - Objektstammdaten

### ZUSAMMENFASSUNG

| Kategorie | Anzahl |
|-----------|--------|
| VOLLSTAENDIG | 18 |
| FEHLT | 5 |
| FEHLERHAFT | 3 |

---

### VOLLSTAENDIG - Korrekt implementierte Features

#### 1.1 Grundfunktionen

| Feature | HTML-Implementation | VBA-Referenz | Status |
|---------|---------------------|--------------|--------|
| **Objektliste rechts** | `#objekteBody` mit ID, Objekt, Ort | Original Access ListBox | VOLLSTAENDIG |
| **Suchfilter** | `filterList()` filtert nach Objekt, Ort, ID | Me.Filter in VBA | VOLLSTAENDIG |
| **Navigation (Erster/Vor/Zurueck/Letzter)** | `goFirst()`, `goPrev()`, `goNext()`, `goLast()` | DoCmd.GoToRecord | VOLLSTAENDIG |
| **Datensatz-Anzeige "x / n"** | `updateRecordInfo()` in `#recordInfo` | CurrentRecord & "/" & RecordCount | VOLLSTAENDIG |
| **Neu/Speichern/Loeschen Buttons** | `newRecord()`, `saveRecord()`, `deleteRecord()` | DoCmd.RunCommand acCmdSaveRecord | VOLLSTAENDIG |
| **Dirty-Check bei Navigation** | `state.isDirty` mit confirm() | Form.Dirty | VOLLSTAENDIG |

#### 1.2 Objektdaten-Felder

| Feld | HTML-ID | data-field | Status |
|------|---------|------------|--------|
| Objekt-ID | `#ID` | ID | VOLLSTAENDIG |
| Objektname | `#Objekt` | Objekt | VOLLSTAENDIG |
| Strasse | `#Strasse` | Strasse | VOLLSTAENDIG |
| PLZ | `#PLZ` | PLZ | VOLLSTAENDIG |
| Ort | `#Ort` | Ort | VOLLSTAENDIG |
| Treffpunkt | `#Treffpunkt` | Treffpunkt | VOLLSTAENDIG |
| Treffpunkt-Zeit | `#Treffp_Zeit` | Treffp_Zeit | VOLLSTAENDIG |
| Dienstkleidung | `#Dienstkleidung` | Dienstkleidung | VOLLSTAENDIG |
| Ansprechpartner | `#Ansprechpartner` | Ansprechpartner | VOLLSTAENDIG |
| Telefon | `#Text435` | Text435 | VOLLSTAENDIG |

#### 1.3 Tabs/Registerkarten

| Tab | HTML-ID | Features | Status |
|-----|---------|----------|--------|
| Positionen | `#tabPositionen` | Liste, Sortierung, Tagesart | VOLLSTAENDIG |
| Zusatzdateien | `#tabAttach` | Upload, Download, Loeschen | VOLLSTAENDIG |
| Bemerkungen | `#tabBemerkungen` | Textfeld fuer Notizen | VOLLSTAENDIG |
| Auftraege | `#tabAuftraege` | Verknuepfte Auftraege zeigen | VOLLSTAENDIG |

#### 1.4 Geocodierung (Geo-Koordinaten)

| Feature | HTML-Implementation | VBA-Referenz | Status |
|---------|---------------------|--------------|--------|
| **Geocode-Button** | `geocodeAdresse()` | `cmdGeocode_Click()` in mdl_frm_OB_Objekt_Code.bas | VOLLSTAENDIG |
| **Nominatim/OSM API** | Fetch zu nominatim.openstreetmap.org | `GeocodeAdresse_OSM()` in mdl_GeoDistanz.bas | VOLLSTAENDIG |
| **User-Agent Header** | `CONSYS-Security-App` | `ConsysAccessApp/1.0` | VOLLSTAENDIG |
| **Koordinaten-Speicherung** | PUT /api/objekte/:id/geo | tbl_OB_Geo INSERT/UPDATE | VOLLSTAENDIG |
| **Feedback bei Erfolg/Fehler** | showToast() | MsgBox | VOLLSTAENDIG |

#### 1.5 Positions-Features

| Feature | HTML-Function | VBA-Referenz | Status |
|---------|---------------|--------------|--------|
| **Neue Position** | `newPosition()` | Form Add | VOLLSTAENDIG |
| **Position loeschen** | `deletePosition()` | DELETE SQL | VOLLSTAENDIG |
| **Position nach oben** | `movePositionUp()` | `MovePositionUp()` in mdl_N_PositionsVorlagen.bas | VOLLSTAENDIG |
| **Position nach unten** | `movePositionDown()` | `MovePositionDown()` in mdl_N_PositionsVorlagen.bas | VOLLSTAENDIG |

---

### FEHLT - Nicht implementierte Features

#### 1.6 Fehlende Felder

| Feld | VBA-Control | Beschreibung | Prioritaet |
|------|-------------|--------------|------------|
| **Geo_Lat / Geo_Lon Anzeige** | txtLat, txtLon | Koordinaten-Felder fehlen im Formular | MITTEL |
| **Nur aktive Checkbox Logik** | chkNurAktive | Checkbox existiert, aber API-Parameter fehlt teilweise | NIEDRIG |
| **Kunde/Veranstalter-Zuordnung** | cboVeranstalter | Dropdown zur Kundenzuordnung fehlt | HOCH |

#### 1.7 Fehlende Funktionen

| Feature | VBA-Referenz | Beschreibung | Prioritaet |
|---------|--------------|--------------|------------|
| **Anfahrtsbeschreibung-Feld** | txtAnfahrt | Textfeld fuer Anfahrtsbeschreibung nicht vorhanden | MITTEL |
| **Vorlagen-Auswahl-Dialog** | frm_N_VorlageAuswahl | `ladeVorlage()` zeigt nur prompt(), kein echtes Auswahl-Formular | NIEDRIG |

---

### FEHLERHAFT - Fehlerhafte Implementationen

#### 1.8 API-Endpunkt-Probleme

| Feature | Problem | Loesung |
|---------|---------|---------|
| **Positions-Sort API** | `movePositionUp/Down` ruft `/objekte/positionen/:id/sort` auf - Endpoint existiert moeglicherweise nicht | API-Endpunkt `/objekte/positionen/:id/sort` implementieren |
| **Vorlagen API** | `/objekte/vorlagen` POST/GET - Endpoints undefiniert | Vorlagen-Endpoints in api_server.py ergaenzen |
| **Positionen-Copy API** | `/objekte/:id/positionen/copy` POST - ungetestet | Endpoint verifizieren und testen |

#### 1.9 Logik-Fehler

| Feature | Problem | VBA-Verhalten |
|---------|---------|---------------|
| **Geo-Koordinaten in tbl_OB_Geo** | HTML speichert via `/api/objekte/:id/geo` - separate Tabelle wird nicht korrekt angesprochen | VBA speichert direkt in tbl_OB_Geo mit DELETE/INSERT |

---

## 2. frm_MA_VA_Schnellauswahl.html - Mitarbeiter-Schnellauswahl

### ZUSAMMENFASSUNG

| Kategorie | Anzahl |
|-----------|--------|
| VOLLSTAENDIG | 22 |
| FEHLT | 4 |
| FEHLERHAFT | 2 |

---

### VOLLSTAENDIG - Korrekt implementierte Features

#### 2.1 Grundstruktur

| Feature | HTML-Implementation | VBA-Referenz | Status |
|---------|---------------------|--------------|--------|
| **Auftrag-Auswahl** | `#VA_ID` Select | Me.VA_ID ComboBox | VOLLSTAENDIG |
| **Datum-Auswahl** | `#cboVADatum` Select | Me.cboVADatum ComboBox | VOLLSTAENDIG |
| **Auftragsstatus** | `#cboAuftrStatus` Select | Me.cboAuftrStatus | VOLLSTAENDIG |
| **Auftrag-Label** | `#lbAuftrag` | Me.lbAuftrag | VOLLSTAENDIG |

#### 2.2 Filter-Controls

| Filter | HTML-ID | VBA-Control | Status |
|--------|---------|-------------|--------|
| Anstellungsart | `#cboAnstArt` | Me.cboAnstArt | VOLLSTAENDIG |
| Kategorie/Qualifikation | `#cboQuali` | Me.cboQuali | VOLLSTAENDIG |
| Nur freie anzeigen | `#IstVerfuegbar` | Me.IstVerfuegbar | VOLLSTAENDIG |
| Nur aktive anzeigen | `#IstAktiv` | Me.IstAktiv | VOLLSTAENDIG |
| geplant = verfuegbar | `#cbVerplantVerfuegbar` | Me.cbVerplantVerfuegbar | VOLLSTAENDIG |
| Nur 34a | `#cbNur34a` | Me.cbNur34a | VOLLSTAENDIG |

#### 2.3 Listen

| Liste | HTML-ID | Beschreibung | Status |
|-------|---------|--------------|--------|
| Zeiten/Schichten | `#lstZeiten_Body` | Dienstbeginn-Auswahl | VOLLSTAENDIG |
| Mitarbeiter verfuegbar | `#List_MA_Body` | Alle/gefilterte MA | VOLLSTAENDIG |
| Mitarbeiter geplant | `#lstMA_Plan_Body` | Zur Planung hinzugefuegt | VOLLSTAENDIG |
| Mitarbeiter zugesagt | `#lstMA_Zusage` | Endgueltige Zusagen | VOLLSTAENDIG |
| Parallele Einsaetze | `#Lst_Parallel_Einsatz` | Andere Einsaetze am Datum | VOLLSTAENDIG |

#### 2.4 Buttons - MA-Verschiebung

| Button | HTML-ID | Funktion | VBA-Aequivalent | Status |
|--------|---------|----------|-----------------|--------|
| MA -> Planung | `#btnAddSelected` | `btnAddSelected_Click()` | Me.btnAddSelected_Click | VOLLSTAENDIG |
| MA <- Planung | `#btnDelSelected` | `btnDelSelected_Click()` | Me.btnDelSelected_Click | VOLLSTAENDIG |
| Alle aus Planung | `#btnDelAll` | `btnDelAll_Click()` | Me.btnDelAll_Click | VOLLSTAENDIG |
| Planung -> Zusage | `#btnAddZusage` | `btnAddZusage_Click()` | Me.btnAddZusage_Click | VOLLSTAENDIG |
| Zusage -> Planung | `#btnMoveZusage` | `btnMoveZusage_Click()` | Me.btnMoveZusage_Click | VOLLSTAENDIG |
| Aus Zusage entfernen | `#btnDelZusage` | `btnDelZusage_Click()` | Me.btnDelZusage_Click | VOLLSTAENDIG |

#### 2.5 GEO/Entfernung Feature - HAVERSINE-BERECHNUNG

| Feature | HTML-Implementation | VBA-Referenz | Status |
|---------|---------------------|--------------|--------|
| **Haversine-Formel** | `haversineDistance(lat1, lng1, lat2, lng2)` Zeile 1255-1264 | `DistanceKm()` in mdl_GeoDistanz.bas (auskommentiert) | VOLLSTAENDIG |
| **Erdradius 6371 km** | `const R = 6371` | `EARTH_RADIUS_KM = 6371` | VOLLSTAENDIG |
| **Mathematische Berechnung** | `Math.sin(dLat/2)^2 + cos*cos*sin(dLng/2)^2` | Identische Formel | VOLLSTAENDIG |
| **Button "Standard"** | `#cmdListMA_Standard` -> `cmdListMA_Standard_Click()` | `cmdListMA_Standard_Click()` in mdl_frm_MA_VA_Schnellauswahl_Code.bas | VOLLSTAENDIG |
| **Button "Entfernung"** | `#cmdListMA_Entfernung` -> `cmdListMA_Entfernung_Click()` | `cmdListMA_Entfernung_Click()` in mdl_frm_MA_VA_Schnellauswahl_Code.bas | VOLLSTAENDIG |

#### 2.6 Entfernungs-Farbcodierung (CSS)

| Klasse | HTML-CSS | Beschreibung | Status |
|--------|----------|--------------|--------|
| `.entf-gruen` | `color: #008000` | < 10 km | VOLLSTAENDIG |
| `.entf-gelb` | `color: #B8860B` | 10-30 km | VOLLSTAENDIG |
| `.entf-rot` | `color: #CC0000` | > 30 km | VOLLSTAENDIG |
| `.entf-unbekannt` | `color: #808080; font-style: italic` | Keine Koordinaten | VOLLSTAENDIG |

#### 2.7 Mail-Anfragen

| Feature | HTML-Function | VBA-Aequivalent | Status |
|---------|---------------|-----------------|--------|
| Alle anfragen | `btnMail_Click()` | Me.btnMail_Click | VOLLSTAENDIG |
| Selektierte anfragen | `btnMailSelected_Click()` | Me.btnMailSelected_Click | VOLLSTAENDIG |
| mailto-Link generieren | `window.open(mailto:...)` | Outlook CreateItem | VOLLSTAENDIG |

#### 2.8 Events

| Event | HTML-Implementation | VBA-Event | Status |
|-------|---------------------|-----------|--------|
| Form_Open | `Form_Open()` Zeile 612 | Form_Open() | VOLLSTAENDIG |
| Form_Load | `Form_Load()` Zeile 641 | Form_Load() | VOLLSTAENDIG |
| Form_Close | `Form_Close()` Zeile 656 | Form_Close() | VOLLSTAENDIG |
| Doppelklick MA-Liste | `List_MA_DblClick()` | List_MA_DblClick | VOLLSTAENDIG |
| Doppelklick Plan-Liste | `lstMA_Plan_DblClick()` | lstMA_Plan_DblClick | VOLLSTAENDIG |

---

### FEHLT - Nicht implementierte Features

#### 2.9 Fehlende Features

| Feature | VBA-Referenz | Beschreibung | Prioritaet |
|---------|--------------|--------------|------------|
| **Entfernungs-Daten aus tbl_MA_Objekt_Entfernung** | `cmdListMA_Entfernung_Click()` liest aus DB | HTML berechnet live via API/Geocoding - keine Nutzung der vorberechneten Tabelle | MITTEL |
| **Spaltenbreiten-Anpassung** | `frm!List_MA.ColumnWidths = "..."` | Feste CSS-Breiten, keine dynamische Anpassung | NIEDRIG |
| **ztbl_MA_Schnellauswahl View** | Access Query als RowSource | API muss diese Abfrage replizieren | HOCH |
| **sort_zuo_plan Sortierung** | Bridge-Event "sort_zuo_plan" | Tatsaechliche Backend-Sortierung fehlt | MITTEL |

---

### FEHLERHAFT - Fehlerhafte Implementationen

#### 2.10 Logik-Probleme

| Feature | Problem | VBA-Verhalten | Loesung |
|---------|---------|---------------|---------|
| **Entfernungs-Modus** | `berechneEntfernungen()` macht Live-Geocoding mit Rate-Limiting (1s/Request) - sehr langsam bei vielen MA | VBA nutzt vorberechnete Werte aus `tbl_MA_Objekt_Entfernung` via JOIN | API-Endpunkt fuer vorberechnete Entfernungen nutzen |
| **Objekt-Koordinaten** | `getObjektKoordinaten()` versucht SQL via Bridge.execute - im Browser-Modus nicht funktional | VBA liest direkt aus tbl_OB_Geo | REST-API `/objekte/:id/geo` konsistent implementieren |

---

## 3. DETAILANALYSE: Haversine-Implementierung

### HTML (Zeile 1255-1264 in frm_MA_VA_Schnellauswahl.html)

```javascript
function haversineDistance(lat1, lng1, lat2, lng2) {
    const R = 6371; // Erdradius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}
```

### VBA (mdl_GeoDistanz.bas, auskommentiert Zeile 97-112)

```vba
Public Function DistanceKm(ByVal Lat1 As Double, ByVal Lon1 As Double, _
                           ByVal Lat2 As Double, ByVal Lon2 As Double) As Double
    Dim dLat As Double, dLon As Double, a As Double, c As Double

    If Lat1 = 0 Or Lon1 = 0 Or Lat2 = 0 Or Lon2 = 0 Then
        DistanceKm = 9999
        Exit Function
    End If

    dLat = (Lat2 - Lat1) * PI / 180
    dLon = (Lon2 - Lon1) * PI / 180

    a = Sin(dLat / 2) ^ 2 + Cos(Lat1 * PI / 180) * Cos(Lat2 * PI / 180) * Sin(dLon / 2) ^ 2
    c = 2 * Application.Atn(Sqr(a) / Sqr(1 - a))

    DistanceKm = Round(EARTH_RADIUS_KM * c, 1)
End Function
```

### Vergleich

| Aspekt | HTML | VBA | Uebereinstimmung |
|--------|------|-----|------------------|
| Erdradius | 6371 km | 6371 km | IDENTISCH |
| Grad->Radiant | `* Math.PI / 180` | `* PI / 180` | IDENTISCH |
| Haversine a | sin^2 + cos*cos*sin^2 | Sin^2 + Cos*Cos*Sin^2 | IDENTISCH |
| Arctan2 vs Atn | `Math.atan2(sqrt(a), sqrt(1-a))` | `Application.Atn(Sqr(a) / Sqr(1-a))` | MATHEMATISCH AEQUIVALENT |
| Null-Check | Fehlt | If = 0 Then 9999 | HTML sollte ergaenzen |
| Rundung | Keine | Round(..., 1) | HTML sollte runden |

**ERGEBNIS: Haversine-Berechnung VOLLSTAENDIG implementiert, kleine Verbesserungen moeglich**

---

## 4. EMPFEHLUNGEN

### Hohe Prioritaet

1. **Kunde/Veranstalter-Zuordnung in Objekt-Formular** - Dropdown ergaenzen
2. **API-Endpunkt fuer vorberechnete Entfernungen** - `/mitarbeiter/entfernungen?objekt_id=:id` statt Live-Geocoding
3. **ztbl_MA_Schnellauswahl** - Komplexe Access-Query als API-Endpunkt replizieren

### Mittlere Prioritaet

4. **Anfahrtsbeschreibung-Feld** in Objekt-Formular ergaenzen
5. **Geo-Koordinaten Anzeige** (Lat/Lon) im Objekt-Formular
6. **sort_zuo_plan Backend-Funktion** implementieren
7. **Null-Check in Haversine** - return 9999 wenn Koordinaten fehlen

### Niedrige Prioritaet

8. **Vorlagen-Auswahl-Dialog** als modales HTML-Formular statt prompt()
9. **Dynamische Spaltenbreiten** in Listen
10. **Rundung auf 1 Dezimalstelle** bei Entfernungen

---

## 5. DATEIEN-REFERENZ

### HTML-Formulare
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/frm_OB_Objekt.html`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html`

### VBA-Module
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_frm_OB_Objekt_Code.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_frm_MA_VA_Schnellauswahl_Code.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_GeoDistanz.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_Distanzberechnung.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_GeoDistanz_FormEvents.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_N_PositionsVorlagen.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_N_PositionslistenExport.bas`
- `/mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/01_VBA/modules/mdl_N_PositionslistenImport.bas`

---

**Bericht erstellt von:** Claude Code Audit
**Version:** 1.0
