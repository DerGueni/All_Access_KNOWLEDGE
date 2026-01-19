# Gap-Analyse: frm_Angebot

**Analysiert am:** 2026-01-12
**Access-Export:** Nicht vorhanden (Teil von frmTop_RechnungsStamm)
**HTML-Formular:** forms3/frm_Angebot.html
**Logic-JS:** Keine (nur Platzhalter)

---

## Executive Summary

### Formular-Status
- **Access:** Kein eigenständiges Formular - Teil von `frmTop_RechnungsStamm` (Toggle: Rechnung/Angebot)
- **HTML:** Nur Platzhalter-Seite mit "in Entwicklung" Hinweis
- **Implementierung:** 0% (nur leere Hülle)

### Voraussichtlicher Umfang (basierend auf frmTop_RechnungsStamm)
- **Controls:** ~150+ (wie Rechnungsformular)
  - 15+ Buttons
  - 50+ TextBoxen
  - 10+ ComboBoxen
  - 5+ Subforms (Positionen, Aufträge)
  - 70+ Labels
  - TabControl mit 7 Tabs

### Kritische Gaps
1. **Komplettes Formular fehlt** - nur Platzhalter vorhanden
2. **Angebots-Logik** nicht implementiert (Angebotserstellung, Positionen)
3. **Word-Integration** fehlt (Angebotsvorlage)
4. **Positionsverwaltung** nicht vorhanden
5. **Umwandlung Angebot → Rechnung** fehlt

---

## 1. FORMULAR-EIGENSCHAFTEN (SOLL-ZUSTAND)

### Access (frmTop_RechnungsStamm mit Angebot-Toggle)

```
RecordSource: tbl_Rch_Kopf WHERE RchTyp = 'Angebot'
Filter: istRechnung = False
AllowEdits: True
AllowAdditions: True
AllowDeletions: True
DataEntry: False
DefaultView: SplitForm (Formular + Datasheet)
NavigationButtons: False
```

**Toggle-Mechanismus:**
```vba
Private Sub istRechnung_AfterUpdate()
    If Me!istRechnung Then
        Me!istRechnung.caption = "Rechnung"
        Me.RecordSource = "qry_tbl_Rch_Kopf"      ' Nur Rechnungen
    Else
        Me!istRechnung.caption = "Angebot"
        Me.RecordSource = "qry_tbl_Rch_Kopf_Ang" ' Nur Angebote
    End If
    Me.Requery
End Sub
```

### HTML (IST-ZUSTAND)

```html
<!-- ❌ NUR PLATZHALTER -->
<!DOCTYPE html>
<html lang="de">
<head>
    <title>Angebot - CONSYS</title>
</head>
<body>
    <div class="placeholder">
        <h1>Angebotsverwaltung</h1>
        <p>Erstellung und Verwaltung von Angeboten.</p>
        <p><em>HTML-Version in Entwicklung</em></p>
        <button onclick="history.back()">Zurück</button>
        <button onclick="Bridge.close()">Schließen</button>
    </div>
</body>
</html>
```

---

## 2. HAUPTFUNKTIONEN (SOLL-ZUSTAND)

### Angebots-Erstellung

**Access-Workflow:**
1. Button "Neue Rechnung" (wird zu "Neues Angebot" wenn Toggle=Angebot)
2. Neuen Datensatz in tbl_Rch_Kopf anlegen mit RchTyp='Angebot'
3. Kundendaten auswählen (cbo_Kunde)
4. Auftragsdaten verknüpfen (optional)
5. Positionen erfassen (Subform sub_Rch_Pos_Auftrag)
6. Word-Vorlage wählen und Angebot generieren
7. PDF speichern

**HTML (fehlt komplett):**
- Kein Formular vorhanden
- Keine Felder
- Keine Buttons

---

## 3. FELDER (SOLL-ZUSTAND)

### Stammdaten (aus tbl_Rch_Kopf)

| Feld | Typ | Zweck | HTML | Status |
|------|-----|-------|------|--------|
| **ID** | Integer | Angebots-ID | - | ❌ Fehlt |
| **RchTyp** | Text | 'Angebot' (fix) | - | ❌ Fehlt |
| **kun_ID** | Integer | Kunden-ID | - | ❌ Fehlt |
| **VA_ID** | Integer | Auftrags-ID (optional) | - | ❌ Fehlt |
| **RchDatum** | Date | Angebotsdatum | - | ❌ Fehlt |
| **Leist_Datum_von** | Date | Leistungszeitraum von | - | ❌ Fehlt |
| **Leist_Datum_Bis** | Date | Leistungszeitraum bis | - | ❌ Fehlt |
| **Ang_Gueltig_Bis** | Date | Angebot gültig bis | - | ❌ Fehlt |
| **Zwi_Sum1** | Currency | Zwischensumme | - | ❌ Fehlt |
| **MwSt_Sum1** | Currency | MwSt | - | ❌ Fehlt |
| **Gesamtsumme1** | Currency | Gesamt | - | ❌ Fehlt |
| **Bemerkungen** | Memo | Bemerkungen | - | ❌ Fehlt |
| **Dateiname** | Text | Pfad zur Word/PDF-Datei | - | ❌ Fehlt |

### Kundendaten (von tbl_KD_Kundenstamm)

| Feld | Quelle | Zweck | HTML | Status |
|------|--------|-------|------|--------|
| **kun_Firma** | tbl_KD_Kundenstamm | Kundenname | - | ❌ Fehlt |
| **kun_BriefKopf** | tbl_KD_Kundenstamm | Briefanschrift | - | ❌ Fehlt |

---

## 4. SUBFORMS (SOLL-ZUSTAND)

### sub_Rch_Pos_Auftrag (Positionen aus Auftrag)

**Access:**
- Lädt automatisch Positionen aus verknüpftem Auftrag (VA_ID)
- Spalten: PosNr, Bezeichnung, Menge, Einheit, Einzelpreis, Gesamt

**HTML:** ❌ Fehlt komplett

### sub_Rch_Pos_Geschrieben (Manuell geschriebene Positionen)

**Access:**
- Erlaubt manuelle Eingabe von Positionen
- Spalten: PosNr, Bezeichnung, Menge, Einheit, Einzelpreis, Gesamt

**HTML:** ❌ Fehlt komplett

### sub_Rch_VA_Gesamtanzeige (Auftrags-Übersicht)

**Access:**
- Zeigt verknüpfte Aufträge
- Spalten: Auftrag, Datum, Objekt, Status

**HTML:** ❌ Fehlt komplett

---

## 5. BUTTONS (SOLL-ZUSTAND)

### Navigation & CRUD (13 Buttons)

| Button | Caption | Funktion | HTML | Status |
|--------|---------|----------|------|--------|
| **Befehl39** | Erster DS | Zum ersten Datensatz | - | ❌ Fehlt |
| **Befehl40** | Vorheriger DS | Zum vorherigen Datensatz | - | ❌ Fehlt |
| **Befehl41** | Nächster DS | Zum nächsten Datensatz | - | ❌ Fehlt |
| **Befehl43** | Letzter DS | Zum letzten Datensatz | - | ❌ Fehlt |
| **Befehl46** | Neue Rechnung | Neues Angebot erstellen | - | ❌ Fehlt |
| **mcobtnDelete** | Rechnung löschen | Angebot löschen | - | ❌ Fehlt |
| **btnFIlterLoesch** | Filter löschen | Alle Filter entfernen | - | ❌ Fehlt |
| **Befehl42** | Drucken | Angebot drucken | - | ❌ Fehlt |

### Angebots-Spezifisch

| Button | Caption | Funktion | HTML | Status |
|--------|---------|----------|------|--------|
| **btnAufRchPDF** | Rechnung PDF | Angebot als PDF | - | ❌ Fehlt |
| **btnAufRchPosPDF** | Berechnungsliste PDF | Positionen als PDF | - | ❌ Fehlt |
| **btnUmsAuswert** | Umsatzauswertung | Statistik | - | ❌ Fehlt |
| **btnAuswertung** | Auswertung | Weitere Statistiken | - | ❌ Fehlt |

### Angebot → Rechnung Umwandlung (nicht in Access-Export sichtbar)

**Vermutete Funktion (Standard-Workflow):**
```vba
' ❌ FEHLT: Button "Angebot in Rechnung umwandeln"
Public Sub AngebotZuRechnung()
    ' 1. Angebots-Datensatz kopieren
    ' 2. RchTyp von "Angebot" auf "Rechnung" ändern
    ' 3. RchDatum auf heute setzen
    ' 4. Neue Rechnungsnummer vergeben
    ' 5. Positionen kopieren
    ' 6. Rechnung öffnen
End Sub
```

**HTML:** ❌ Fehlt komplett

---

## 6. TAB-CONTROL (SOLL-ZUSTAND)

### Access: reg_Rech mit 7 Tabs

| Tab-Name | Caption | Inhalt | HTML | Status |
|----------|---------|--------|------|--------|
| **pgMain** | Main | Stammdaten, Kundendaten | - | ❌ Fehlt |
| **pgWeit** | Weiteres | Zusatzinformationen | - | ❌ Fehlt |
| **pg_VA_ID** | Aufträge | Verknüpfte Aufträge | - | ❌ Fehlt |
| **pgGeschrPos** | Geschriebene Pos | Manuelle Positionen | - | ❌ Fehlt |
| **pgAuftrPos** | Auftragspositionen | Positionen aus Auftrag | - | ❌ Fehlt |
| **pgMahnInfo** | Mahnung Info | N/A (nur Rechnung) | - | N/A |
| **pgMahnen** | Mahnen | N/A (nur Rechnung) | - | N/A |

---

## 7. WORD-INTEGRATION (KRITISCH!)

### Access-VBA (aus frmTop_RechnungsStamm)

**Workflow:**
1. Vorlage auswählen (aus `_tblEigeneFirma_TB_Dok_Dateinamen`)
2. Word öffnen mit Vorlage
3. Platzhalter ersetzen (`WordReplace`)
4. PDF generieren (`PDF_Print`)
5. Dateiname in tbl_Rch_Kopf.Dateiname speichern

**Platzhalter-Ersetzung:**
```vba
' Aus VBA-Code (Zeile 382-384):
Call Textbau_Replace_Felder_Fuellen(iDokVorlage_ID)
Call fReplace_Table_Felder_Ersetzen(Me!ID, ikun_ID, 0, Me!VA_ID)
Call WordReplace(strVorlage, strDokument)
```

**Benötigte Module:**
- `Textbau_Replace_Felder_Fuellen` - Füllt {{Platzhalter}} mit Daten
- `fReplace_Table_Felder_Ersetzen` - Ersetzt Tabellen (Positionen)
- `WordReplace` - Speichert Word-Dokument
- `PDF_Print` - Konvertiert zu PDF

**HTML:** ❌ Komplett fehlt - VBA-Bridge benötigt!

---

## 8. API-INTEGRATION (SOLL-ZUSTAND)

### Benötigte Endpoints

```python
# ❌ FEHLEN ALLE:

# 1. Angebote abrufen
GET /api/angebote
GET /api/angebote/:id

# 2. Angebot erstellen
POST /api/angebote
{
    "kun_ID": 123,
    "VA_ID": 456,
    "RchDatum": "2026-01-15",
    "Leist_Datum_von": "2026-02-01",
    "Leist_Datum_Bis": "2026-02-28",
    "Ang_Gueltig_Bis": "2026-01-31",
    "Bemerkungen": "Standardangebot"
}

# 3. Angebot aktualisieren
PUT /api/angebote/:id
{
    "Zwi_Sum1": 1000.00,
    "MwSt_Sum1": 190.00,
    "Gesamtsumme1": 1190.00
}

# 4. Angebot löschen
DELETE /api/angebote/:id

# 5. Angebots-Positionen
GET /api/angebote/:id/positionen
POST /api/angebote/:id/positionen
{
    "PosNr": 1,
    "Bezeichnung": "Sicherheitsdienst",
    "Menge": 10,
    "Einheit": "Stunden",
    "Einzelpreis": 25.00
}

# 6. Angebot → Rechnung umwandeln
POST /api/angebote/:id/convert_to_rechnung
{
    "RchDatum": "2026-01-20"
}

# 7. Angebot als Word/PDF generieren (VBA-Bridge!)
POST /api/vba/angebot/generate
{
    "angebot_id": 123,
    "vorlage_id": 10
}
```

---

## 9. VORGESCHLAGENE HTML-STRUKTUR

### Formular-Layout (wie Rechnungsformular)

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>Angebotsverwaltung - CONSYS</title>
    <link rel="stylesheet" href="consys-common.css">
    <link rel="stylesheet" href="css/fonts_override.css">
</head>
<body data-form="frm_Angebot">
    <div class="app-container">
        <!-- Sidebar -->
        <div class="app-sidebar"></div>

        <!-- Main Area -->
        <div class="app-main">
            <!-- Header -->
            <div class="app-header">
                <h1>Angebotsverwaltung</h1>
                <div class="header-actions">
                    <button onclick="neuesAngebot()">Neues Angebot</button>
                    <button onclick="speichern()">Speichern</button>
                    <button onclick="loeschen()">Löschen</button>
                    <button onclick="generiereAngebot()">Angebot erstellen (Word)</button>
                </div>
            </div>

            <!-- Content -->
            <div class="app-content">
                <!-- Navigation -->
                <div class="record-nav">
                    <button onclick="gotoFirst()">|◄</button>
                    <button onclick="gotoPrev()">◄</button>
                    <span id="recordInfo">1 / 10</span>
                    <button onclick="gotoNext()">►</button>
                    <button onclick="gotoLast()">►|</button>
                </div>

                <!-- Tab Control -->
                <div class="tab-control">
                    <div class="tabs">
                        <button class="tab active" data-tab="main">Stammdaten</button>
                        <button class="tab" data-tab="positionen">Positionen</button>
                        <button class="tab" data-tab="auftraege">Aufträge</button>
                        <button class="tab" data-tab="weiteres">Weiteres</button>
                    </div>

                    <!-- Tab: Stammdaten -->
                    <div class="tab-content active" id="tab-main">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Angebots-Nr:</label>
                                <input type="text" id="ID" readonly>
                            </div>
                            <div class="form-group">
                                <label>Kunde:</label>
                                <select id="kun_ID"></select>
                            </div>
                            <div class="form-group">
                                <label>Angebotsdatum:</label>
                                <input type="date" id="RchDatum">
                            </div>
                            <div class="form-group">
                                <label>Gültig bis:</label>
                                <input type="date" id="Ang_Gueltig_Bis">
                            </div>
                            <div class="form-group full-width">
                                <label>Leistungszeitraum:</label>
                                <input type="date" id="Leist_Datum_von">
                                <span> bis </span>
                                <input type="date" id="Leist_Datum_Bis">
                            </div>
                            <div class="form-group full-width">
                                <label>Bemerkungen:</label>
                                <textarea id="Bemerkungen" rows="5"></textarea>
                            </div>
                        </div>

                        <!-- Summen -->
                        <div class="summen-box">
                            <div class="summe-row">
                                <span>Zwischensumme:</span>
                                <input type="number" id="Zwi_Sum1" step="0.01" readonly>
                            </div>
                            <div class="summe-row">
                                <span>MwSt (19%):</span>
                                <input type="number" id="MwSt_Sum1" step="0.01" readonly>
                            </div>
                            <div class="summe-row total">
                                <span>Gesamtsumme:</span>
                                <input type="number" id="Gesamtsumme1" step="0.01" readonly>
                            </div>
                        </div>
                    </div>

                    <!-- Tab: Positionen -->
                    <div class="tab-content" id="tab-positionen">
                        <div class="toolbar">
                            <button onclick="neuePosition()">Neue Position</button>
                            <button onclick="positionLoeschen()">Löschen</button>
                            <button onclick="positionenAusAuftrag()">Aus Auftrag übernehmen</button>
                        </div>
                        <table class="data-table" id="tblPositionen">
                            <thead>
                                <tr>
                                    <th>Pos</th>
                                    <th>Bezeichnung</th>
                                    <th>Menge</th>
                                    <th>Einheit</th>
                                    <th>Einzelpreis</th>
                                    <th>Gesamt</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <!-- Tab: Aufträge -->
                    <div class="tab-content" id="tab-auftraege">
                        <div class="toolbar">
                            <button onclick="auftragVerknuepfen()">Auftrag verknüpfen</button>
                        </div>
                        <iframe src="sub_Rch_VA_Gesamtanzeige.html"></iframe>
                    </div>

                    <!-- Tab: Weiteres -->
                    <div class="tab-content" id="tab-weiteres">
                        <div class="form-group">
                            <label>Dateipfad (Word/PDF):</label>
                            <input type="text" id="Dateiname" readonly>
                            <button onclick="oeffneDatei()">Öffnen</button>
                        </div>
                        <div class="button-group">
                            <button onclick="generiereAngebotPDF()">Angebot als PDF</button>
                            <button onclick="generierePositionenPDF()">Positionen als PDF</button>
                            <button onclick="angebotZuRechnung()">In Rechnung umwandeln</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="app-footer">
                <span id="statusMessage">Bereit</span>
            </div>
        </div>
    </div>

    <script src="js/webview2-bridge.js"></script>
    <script src="js/sidebar.js"></script>
    <script src="logic/frm_Angebot.logic.js"></script>
</body>
</html>
```

---

## 10. COMPLETION-ANALYSE

### IST-Zustand (nur Platzhalter)

| Komponente | Soll | Ist | Prozent |
|------------|------|-----|---------|
| HTML-Struktur | 1 Formular | Platzhalter | 0% |
| Felder | 50+ | 0 | 0% |
| Buttons | 15+ | 2 (zurück, schließen) | 0% |
| Subforms | 3 | 0 | 0% |
| API-Integration | 7 Endpoints | 0 | 0% |
| Word-Integration | VBA-Bridge | 0 | 0% |
| Tab-Control | 7 Tabs | 0 | 0% |
| **GESAMT** | | | **0%** |

---

## 11. AUFWAND-SCHÄTZUNG (KOMPLETT-IMPLEMENTIERUNG)

### Phase 1: Grundstruktur (16-24 Stunden)
1. **HTML-Formular erstellen** (wie Rechnungsformular) - 12h
2. **Felder mappen** (50+ Felder) - 6h
3. **Tab-Control implementieren** - 6h

### Phase 2: API-Integration (16-24 Stunden)
4. **API-Endpoints** in api_server.py - 12h
   - GET/POST/PUT/DELETE /api/angebote
   - Positionen CRUD
   - Angebot → Rechnung Konvertierung
5. **Logic.js** für CRUD-Operationen - 8h
6. **Formular-Validierung** - 4h

### Phase 3: Subforms (16-24 Stunden)
7. **sub_Rch_Pos_Geschrieben** (Positionen-Editor) - 12h
8. **sub_Rch_VA_Gesamtanzeige** (Auftrags-Übersicht) - 8h
9. **Positionen aus Auftrag übernehmen** - 4h

### Phase 4: Word/PDF-Integration (20-32 Stunden)
10. **VBA-Bridge für Angebots-Generierung** - 16h
11. **Word-Vorlagen anpassen** - 8h
12. **PDF-Generierung** - 8h

**Gesamt-Aufwand:** 68-104 Stunden

---

## 12. PRIORITÄTEN

### P1 - Kritisch (Minimum Viable Product)
1. ❌ HTML-Formular mit Stammdaten (12h)
2. ❌ API-Endpoints (CRUD) (12h)
3. ❌ Positionen-Editor (12h)
4. ❌ Word/PDF-Generierung via VBA-Bridge (16h)

**MVP-Aufwand:** 52 Stunden

### P2 - Wichtig
5. ❌ Tab-Control mit allen Tabs (6h)
6. ❌ Subform Auftrags-Übersicht (8h)
7. ❌ Angebot → Rechnung Umwandlung (4h)

### P3 - Nice-to-Have
8. ❌ Filter nach Kunde/Zeitraum
9. ❌ Statistiken/Auswertungen
10. ❌ Export als Excel

---

## 13. FAZIT

### Aktueller Status
- **Implementierung:** 0% (nur leerer Platzhalter)
- **Geschätzter Aufwand:** 68-104 Stunden für Vollimplementierung
- **MVP-Aufwand:** 52 Stunden

### Empfehlung

**Option A: Vollimplementierung (104h)**
- Komplettes Formular nach Vorbild von frmTop_RechnungsStamm
- Alle Features (Positionen, Word-Integration, Subforms)
- Production-ready

**Option B: MVP (52h)**
- Stammdaten + CRUD
- Einfacher Positionen-Editor
- Word/PDF-Generierung via VBA-Bridge
- Reicht für 80% der Anwendungsfälle

**Option C: Verzicht (0h)**
- Verwende frmTop_RechnungsStamm mit Toggle
- HTML-Formular bleibt Platzhalter
- Bei Klick auf "Angebot" → Access-Formular öffnen

### Bevorzugte Option
**Option B (MVP)** - Bietet gutes Kosten/Nutzen-Verhältnis. Nach MVP-Release können weitere Features iterativ ergänzt werden.

### Nächste Schritte (wenn MVP gewünscht)
1. frmTop_RechnungsStamm.md als Vorlage verwenden
2. HTML-Struktur aus frm_Rechnung.html kopieren und anpassen
3. API-Endpoints implementieren (Priorität: CRUD)
4. VBA-Bridge für Word-Generierung einrichten
5. Einfachen Positionen-Editor implementieren

**Zeitrahmen:** 2 Wochen (bei Vollzeit-Entwicklung)
