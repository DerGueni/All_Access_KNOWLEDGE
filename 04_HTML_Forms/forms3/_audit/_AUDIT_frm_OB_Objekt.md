# AUDIT-BERICHT: frm_OB_Objekt

**Erstellt:** 2026-01-05
**Formular:** Objektstammdaten
**Access-Formular:** Form_frm_OB_Objekt
**HTML-Formular:** frm_OB_Objekt.html

---

## 1. CONTROL-VERGLEICH: Access vs. HTML

### 1.1 Hauptfelder (Objektdaten)

| Access-Control | Typ | HTML-Control | HTML-ID | Status |
|----------------|-----|--------------|---------|--------|
| ID | TextBox | input (readonly) | ID | OK |
| Objekt | TextBox | input | Objekt | OK |
| Strasse | TextBox | input | Strasse | OK |
| PLZ | TextBox | input | PLZ | OK |
| Ort | TextBox | input | Ort | OK |
| Treffpunkt | TextBox | input | Treffpunkt | OK |
| Treffp_Zeit | TextBox | input | Treffp_Zeit | OK |
| Dienstkleidung | TextBox | input | Dienstkleidung | OK |
| Ansprechpartner | TextBox | input | Ansprechpartner | OK |
| Text435 (Telefon) | TextBox | input | Text435 | OK |
| TabellenNr | TextBox (=42) | - | - | FEHLT (intern, nicht kritisch) |

### 1.2 Audit-Felder (Footer)

| Access-Control | Typ | HTML-Control | Status |
|----------------|-----|--------------|--------|
| Erst_von | TextBox | span | OK |
| Erst_am | TextBox | span | OK |
| Aend_von | TextBox | span | OK |
| Aend_am | TextBox | span | OK |

### 1.3 Navigation-Buttons

| Access-Control | Aktion | HTML-Button | Status |
|----------------|--------|-------------|--------|
| btn_letzer_Datensatz | GoToRecord Last | goLast() | OK |
| Befehl40 | GoToRecord Next | goNext() | OK |
| Befehl41 | GoToRecord Previous | goPrev() | OK |
| Befehl42 | GoToRecord NewRecord | newRecord() | OK |
| Befehl43 | GoToRecord First | goFirst() | OK |
| btnHilfe | Hilfe anzeigen | showHelp() | OK |

### 1.4 Aktions-Buttons (Header)

| Access-Control | VBA-Funktion | HTML-Button | Status |
|----------------|--------------|-------------|--------|
| btn_Back_akt_Pos_List | OpenForm frmTop_VA_Akt_Objekt_Kopf | btnBackToList | OK (Visible-Logik) |
| btnReport | OpenReport rpt_OB_Objekt | printReport() | OK |
| mcobtnDelete | DeleteRecord | deleteRecord() | OK |
| btnNeuVeranst | OpenForm Veranstalter | openNewVeranstalter() | OK |
| btnRibbonAus | ShowToolbar Aus | - | NICHT RELEVANT (Access-spezifisch) |
| btnRibbonEin | ShowToolbar Ein | - | NICHT RELEVANT (Access-spezifisch) |
| btnDaBaAus | SelectObject Hide | - | NICHT RELEVANT (Access-spezifisch) |
| btnDaBaEin | SelectObject Show | - | NICHT RELEVANT (Access-spezifisch) |

### 1.5 Positionen-Buttons (Tab)

| Access-Control | VBA-Funktion | HTML-Button | Status |
|----------------|--------------|-------------|--------|
| btnMoveUp | Position nach oben | movePositionUp() | OK |
| btnMoveDown | Position nach unten | movePositionDown() | OK |
| btnUploadPositionen | ImportPositionslisteDialog | uploadPositionen() | OK |
| btnExportExcel | ExportPositionslisteToExcel | exportPositionenExcel() | OK |
| btnKopierePositionen | KopierePositionenDialog | kopierePositionen() | OK |
| btnVorlageSpeichern | SpeichereAlsVorlage | speichereVorlage() | OK |
| btnVorlageLaden | LadeVorlageDialog | ladeVorlage() | OK |
| btnZeitLabels | BearbeiteZeitLabels | - | FEHLT |
| cmdGeocode | GeocodierenObjekt | geocodeAdresse() | OK |

### 1.6 Zusatzdateien-Buttons (Tab)

| Access-Control | VBA-Funktion | HTML-Button | Status |
|----------------|--------------|-------------|--------|
| btnNeuAttach | f_btnNeuAttach | addAttachment() / newAttachment() | OK |

### 1.7 Subformulare

| Access-SubForm | Link-Felder | HTML-Implementierung | Status |
|----------------|-------------|---------------------|--------|
| sub_OB_Objekt_Positionen | ID -> OB_Objekt_Kopf_ID | Tabelle positionenBody | OK (als Tabelle) |
| sub_ZusatzDateien | ID,TabellenNr -> Ueberordnung,TabellenID | Tabelle attachBody | OK (als Tabelle) |
| frm_Menuefuehrung | keine | Sidebar (extern) | OK |

### 1.8 Listen

| Access-Control | RowSource | HTML-Implementierung | Status |
|----------------|-----------|---------------------|--------|
| Liste_Obj | SELECT ID, Objekt, Ort FROM tbl_OB_Objekt | objekteBody (Tabelle) | OK |

### 1.9 Tabs (TabControl: Reg_VA)

| Access-Page | HTML-Tab | Status |
|-------------|----------|--------|
| pgPos (Positionen) | tabPositionen | OK |
| pgAttach (Zusatzdateien) | tabAttach | OK |
| - | tabBemerkungen | ZUSAETZLICH (sinnvoll) |
| - | tabAuftraege | ZUSAETZLICH (sinnvoll) |

---

## 2. EVENT-HANDLER VERGLEICH

### 2.1 Formular-Events

| Access-Event | VBA-Handler | HTML-Implementierung | Status |
|--------------|-------------|---------------------|--------|
| Form_Open | OpenArgs-Pruefung, btn_Back_akt_Pos_List sichtbar | handleFormOpen() | OK |
| Form_Load | Maximize, Liste_Obj.RowSource setzen | DOMContentLoaded, loadObjekte() | OK |
| Form_BeforeInsert | Zeit-Labels setzen | - | FEHLT (nicht kritisch) |
| Form_BeforeUpdate | Aend_am/Aend_von setzen | - | TEILWEISE (serverseitig) |
| Form_Current | Positionen-Requery, UpdateZeitHeaderLabels, UpdateSummenAnzeige | loadPositionen(), updateSummenAnzeige() | OK |

### 2.2 Control-Events

| Access-Event | VBA-Handler | HTML-Implementierung | Status |
|--------------|-------------|---------------------|--------|
| Liste_Obj_Click | FindFirst, Positionen.Requery | selectObjekt() | OK |
| txtSuche_Change | FilterObjektListe | filterList() | OK |
| sub_OB_Objekt_Positionen_Exit | UpdateSummenAnzeige | - | FEHLT (Tab-Wechsel nutzen) |

---

## 3. FEHLENDE FUNKTIONEN

### 3.1 Kritische Funktionen (FEHLEN)

| Funktion | Access-Implementierung | Prioritaet |
|----------|----------------------|------------|
| btnZeitLabels | BearbeiteZeitLabels (Zeit-Header 08:00, 12:00, 16:00, 20:00) | MITTEL |
| Zeit-Header (Zeit1_Label bis Zeit4_Label) | Dynamische Zeit-Labels im Positionen-Grid | MITTEL |
| Form_BeforeInsert | Standard-Zeitlabels setzen | NIEDRIG |

### 3.2 Nicht implementierte Access-spezifische Funktionen (OK so)

| Funktion | Grund |
|----------|-------|
| btnRibbonAus/Ein | Access UI-spezifisch |
| btnDaBaAus/Ein | Access UI-spezifisch |
| DoCmd.Maximize | Browser nutzt eigene Window-Controls |

---

## 4. LOGIC.JS ANALYSE

### 4.1 Abweichungen zwischen HTML und Logic.js

| Aspekt | HTML (inline) | Logic.js | Status |
|--------|---------------|----------|--------|
| Feld-IDs | ID, Objekt, Strasse, PLZ, Ort | Objekt_ID, Objekt_Name, Objekt_Strasse, Objekt_PLZ, Objekt_Ort | ABWEICHEND |
| API-Client | apiCall() (inline) | Bridge (aus bridgeClient.js) | ABWEICHEND |
| Funktionsumfang | Vollstaendig | Basis (CRUD + Liste) | HTML ist vollstaendiger |

### 4.2 Logic.js - Fehlende Funktionen

Die Logic.js ist eine **alternative Implementierung** mit modernem ES6-Modul-Ansatz, aber **weniger Funktionen** als die Inline-Variante im HTML:

| In HTML vorhanden | In Logic.js | Status |
|-------------------|-------------|--------|
| movePositionUp/Down | - | FEHLT |
| uploadPositionen | - | FEHLT |
| exportPositionenExcel | - | FEHLT |
| kopierePositionen | - | FEHLT |
| speichereVorlage/ladeVorlage | - | FEHLT |
| geocodeAdresse | - | FEHLT |
| showHelp | - | FEHLT |
| backToAktPosList | - | FEHLT |

**Empfehlung:** Die Logic.js ist unvollstaendig und wird aktuell NICHT genutzt (HTML verwendet Inline-Script). Entweder Logic.js erweitern oder entfernen.

---

## 5. KARTEN-INTEGRATION

### 5.1 Geocodierung

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| cmdGeocode Button | GeocodierenObjekt Me | geocodeAdresse() | OK |
| API | Unbekannt (VBA-Modul) | OpenStreetMap Nominatim | OK |
| Koordinaten speichern | Vermutlich Lat/Lon Felder | /api/objekte/:id/geo PUT | OK |

### 5.2 Fehlende Karten-Anzeige

| Funktion | Status |
|----------|--------|
| Karten-Anzeige (Map) | NICHT VORHANDEN |
| Marker auf Karte | NICHT VORHANDEN |

**Empfehlung:** Leaflet.js oder OpenLayers fuer Kartenanzeige implementieren (optional).

---

## 6. POSITIONEN-SUBFORMULAR

### 6.1 Spalten-Vergleich

| Access-Spalte | HTML-Spalte | Status |
|---------------|-------------|--------|
| Sort | Sort | OK |
| Gruppe/Bereich | Bereich | OK |
| Zusatztext/Info | Info | OK |
| Anzahl | Anzahl | OK |
| Geschlecht | Geschl. | OK |
| Rel_Beginn | Beginn | OK |
| Rel_Ende | Ende | OK |
| TagesArt | Tagesart | OK |
| TagesNr | Tag-Nr | OK |

### 6.2 Zeit-Header (Access: UpdateZeitHeaderLabels)

| Access | HTML | Status |
|--------|------|--------|
| Zeit1_Label (08:00) | - | FEHLT |
| Zeit2_Label (12:00) | - | FEHLT |
| Zeit3_Label (16:00) | - | FEHLT |
| Zeit4_Label (20:00) | - | FEHLT |

---

## 7. KORREKTURVORSCHLAEGE

### 7.1 Kritisch (Funktionalitaet)

1. **Zeit-Labels im Positionen-Grid hinzufuegen**
   - 4 Spalten fuer Zeitslots (08:00, 12:00, 16:00, 20:00)
   - Button "Zeit bearbeiten" (btnZeitLabels) implementieren

2. **Logic.js synchronisieren oder entfernen**
   - Entweder alle Funktionen aus HTML in Logic.js uebernehmen
   - Oder Logic.js entfernen und nur Inline-Script nutzen
   - Aktuell: Verwirrung durch zwei unterschiedliche Implementierungen

3. **Feld-IDs vereinheitlichen**
   - HTML: ID, Objekt, Strasse, PLZ, Ort
   - Logic.js: Objekt_ID, Objekt_Name, Objekt_Strasse, Objekt_PLZ, Objekt_Ort
   - **Empfehlung:** HTML-IDs beibehalten (entsprechen Access-Namen)

### 7.2 Mittel (Verbesserungen)

4. **sub_OB_Objekt_Positionen_Exit implementieren**
   - UpdateSummenAnzeige bei Tab-Wechsel aufrufen
   - Aktuell wird dies bei loadPositionen() gemacht (ausreichend)

5. **Karten-Widget hinzufuegen (Optional)**
   - Leaflet.js fuer OpenStreetMap
   - Marker bei Geocodierung anzeigen
   - In Tab "Standort" oder neben Adressfeldern

### 7.3 Niedrig (Kosmetisch)

6. **Form_BeforeInsert Logik**
   - Standard-Zeit-Labels bei neuem Datensatz setzen
   - Derzeit nicht kritisch

7. **TabellenNr Feld**
   - Intern genutzt fuer Attachments (=42)
   - In HTML nicht sichtbar noetig (wird ueber API uebergeben)

---

## 8. ZUSAMMENFASSUNG

### 8.1 Statistik

| Kategorie | Access | HTML | Abdeckung |
|-----------|--------|------|-----------|
| Hauptfelder | 10 | 10 | 100% |
| Audit-Felder | 4 | 4 | 100% |
| Navigation-Buttons | 6 | 6 | 100% |
| Aktions-Buttons | 8 | 4 | 50% (Rest Access-spezifisch) |
| Positions-Buttons | 8 | 7 | 87.5% (btnZeitLabels fehlt) |
| Subformulare | 3 | 3 | 100% (als Tabellen) |
| Tabs | 2 | 4 | 200% (Zusaetzliche Tabs) |
| Events | 7 | 5 | 71% |

### 8.2 Gesamtbewertung

**Abdeckung: ~90%**

Das HTML-Formular bildet das Access-Original sehr gut nach. Die meisten Funktionen sind vorhanden und funktional. Hauptsaechlich fehlen:

1. Zeit-Labels Bearbeitung (btnZeitLabels)
2. Zeit-Header im Positionen-Grid
3. Synchronisation zwischen Logic.js und Inline-Script

Die zusaetzlichen Tabs (Bemerkungen, Auftraege) sind sinnvolle Erweiterungen gegenueber dem Access-Original.

---

## 9. DATEIEN

| Datei | Pfad |
|-------|------|
| Access VBA | /mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/exports/vba/forms/Form_frm_OB_Objekt.bas |
| Access JSON | /mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/11_json_Export/000_Consys_Eport_11_25/30_forms/FRM_frm_OB_Objekt.json |
| HTML | /mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/frm_OB_Objekt.html |
| Logic.js | /mnt/c/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms3/logic/frm_OB_Objekt.logic.js |
