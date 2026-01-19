# Kernprozesse des CONSEC Planungssystems

## Uebersicht

Dieses Dokument beschreibt die wichtigsten Geschaeftsprozesse im CONSEC Access-System und wie sie technisch umgesetzt sind.

---

## 1. Neuen Auftrag anlegen

### Ausloeser
Button "Neuer Auftrag" in `frm_VA_Auftragstamm` oder Navigation ueber Menue.

### Schritt-fuer-Schritt

| Schritt | Aktion | Formular/Feld |
|---------|--------|---------------|
| 1 | Formular oeffnen | frm_VA_Auftragstamm (neuer Datensatz) |
| 2 | Startdatum eingeben | Dat_VA_Von |
| 3 | Enddatum eingeben | Dat_VA_Bis (bei Mehrtages-Events) |
| 4 | Auftragsname | Kombinationsfeld656 (Auto-Complete) |
| 5 | Ort waehlen | Ort (ComboBox mit DISTINCT-Werten) |
| 6 | Objekt waehlen | Objekt, Objekt_ID (verknuepft mit tbl_OB_Objekt) |
| 7 | Treffpunkt | Treffp_Zeit, Treffpunkt |
| 8 | Dienstkleidung | Dienstkleidung (ComboBox) |
| 9 | Auftraggeber | veranstalter_id (FK zu tbl_KD_Kundenstamm) |
| 10 | Status setzen | Veranst_Status_ID = 1 (Planung) |
| 11 | Speichern | Automatisch bei Datensatzwechsel |

### Template-Erkennung
Bei Eingabe bekannter Auftragsnamen werden Felder automatisch vorbefuellt:

| Auftrag-Pattern | Objekt | Ort | Veranstalter_ID |
|-----------------|--------|-----|-----------------|
| "1.FCN *" | Max-Morlock-Stadion | Nuernberg | 20771 |
| "Greuther *" | Sportpark am Ronhof | Fuerth | 20737 |
| "Kaufland*" | - | - | 20770 |
| "Konzert" | Hirsch | Nuernberg | 10233 |
| "clubbing" | Hirsch | Nuernberg | 10337 |
| "HC Erlangen " | Arena | Nuernberg | 20761 |

### Automatische Aktionen
- `AnzTg` wird aus Datumsdifferenz berechnet
- `tbl_VA_AnzTage` wird fuer jeden Tag des Auftrags gefuellt
- `Erst_von`, `Erst_am` werden automatisch gesetzt

### Datenbank-Operationen
```sql
-- Auftrag einfuegen
INSERT INTO tbl_VA_Auftragstamm (
    Auftrag, Dat_VA_Von, Dat_VA_Bis, Ort, Objekt, Objekt_ID,
    Treffpunkt, Treffp_Zeit, Dienstkleidung, Veranstalter_ID,
    Veranst_Status_ID, Erst_von, Erst_am
) VALUES (...)

-- Tage anlegen (fuer jeden Tag zwischen Von und Bis)
INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum) VALUES (...)
```

---

## 2. Mitarbeiter einem Auftrag zuordnen

### Ausloeser
- Button "Mitarbeiterauswahl" in frm_VA_Auftragstamm
- Oder direkte Eingabe in sub_MA_VA_Zuordnung

### Methode A: Schnellauswahl (frm_MA_VA_Schnellauswahl)

| Schritt | Aktion | Element |
|---------|--------|---------|
| 1 | Auftrag waehlen | VA_ID (ComboBox oben) |
| 2 | Datum waehlen | cboVADatum (bei Mehrtages-Auftraegen) |
| 3 | Schicht waehlen | lstZeiten |
| 4 | Filter setzen | IstVerfuegbar, cboAnstArt, cboQuali |
| 5 | MA auswaehlen | List_MA (Mehrfachauswahl moeglich) |
| 6 | Zuordnen | btnAddSelected |
| 7 | E-Mail senden | btnMailSelected (optional) |

### Methode B: Direkteingabe in sub_MA_VA_Zuordnung

| Schritt | Aktion | Feld |
|---------|--------|------|
| 1 | Neue Zeile | (automatisch) |
| 2 | MA waehlen | MA_ID (ComboBox mit MA-Liste) |
| 3 | Startzeit | MVA_Start |
| 4 | Endzeit | MVA_Ende |
| 5 | Position | PosNr |
| 6 | Speichern | Automatisch |

### Datenbank-Operationen
```sql
-- Zuordnung einfuegen
INSERT INTO tbl_MA_VA_Planung (
    VA_ID, VADatum_ID, VAStart_ID, MA_ID,
    VA_Start, VA_Ende, MVA_Start, MVA_Ende,
    Status_ID, PosNr, VADatum, Erst_von, Erst_am
) VALUES (...)

-- Verfuegbarkeit pruefen (vor dem Einfuegen)
SELECT COUNT(*) FROM tbl_MA_VA_Planung
WHERE MA_ID = ? AND VADatum = ? AND Status_ID NOT IN (4,5)

-- Verfuegbare MA abfragen
SELECT * FROM ztbl_MA_Schnellauswahl
WHERE ID NOT IN (
    SELECT MA_ID FROM tbl_MA_VA_Planung
    WHERE VADatum = ? AND Status_ID NOT IN (4,5)
)
```

### Status-Werte (tbl_MA_Plan_Status)
| ID | Status | Bedeutung |
|----|--------|-----------|
| 0 | Angefragt | Noch keine Rueckmeldung |
| 1 | Zugesagt | MA hat zugesagt |
| 2 | Abgesagt | MA hat abgesagt |
| 3 | Bestaetigt | Finaler Status |
| 4 | Storniert | Zuordnung aufgehoben |

---

## 3. Serien-E-Mail versenden

### Ausloeser
- Button "Einsatzliste senden MA" in frm_VA_Auftragstamm
- Button "E-Mail" in frm_MA_VA_Schnellauswahl
- Automatisch bei Status-Aenderung (wenn Autosend aktiv)

### Ablauf

| Schritt | Aktion | VBA-Modul |
|---------|--------|-----------|
| 1 | Empfaenger ermitteln | Aus sub_MA_VA_Zuordnung |
| 2 | E-Mail-Template laden | Get_Priv_Property("prp_HTML_...") |
| 3 | Platzhalter ersetzen | Replace(...) fuer Variablen |
| 4 | Outlook oeffnen | CreateObject("Outlook.Application") |
| 5 | E-Mail erstellen | objOutlook.CreateItem(olMailItem) |
| 6 | E-Mail senden | SendKeys "%s" (oder .Send) |
| 7 | Log schreiben | INSERT INTO tbl_Log_eMail_Sent |

### E-Mail-Vorlagen (tbl_MA_Serien_eMail_Vorlage)
| Vorlage | Verwendung |
|---------|------------|
| Einsatzliste_MA | An einzelne Mitarbeiter |
| Einsatzliste_BOS | An BOS-Franken |
| Einsatzliste_SUB | An Subunternehmer |
| Anfrage | Verfuegbarkeitsanfrage |

### Platzhalter
| Platzhalter | Ersetzt durch |
|-------------|---------------|
| *$*Anrede*$* | Herr/Frau + Nachname |
| *$*Datum*$* | Einsatzdatum |
| *$*Auftrag*$* | Auftragsname |
| *$*Objekt*$* | Objekt/Location |
| *$*Beginn*$* | Startzeit |
| *$*Ende*$* | Endzeit |
| *$*Treffpunkt*$* | Treffpunkt + Zeit |
| *$*Dienstkleidung*$* | Kleidungsvorgabe |

### VBA-Hauptfunktion
```vba
' mdlOutlook_HTML_Serienemail_SAP.xSendMessage
Sub xSendMessage(theSubject, theRecipient, html As String, _
    Optional theCCRecepients, Optional theBCCRecepients, _
    Optional iImportance As Long = 1, Optional myattach, _
    Optional theVoting As String = "")
```

---

## 4. Abrechnung / Rechnung erstellen

### Ausloeser
Tab "Rechnung" in frm_VA_Auftragstamm

### Ablauf

| Schritt | Aktion | Button/Feld |
|---------|--------|-------------|
| 1 | Daten laden | btnLoad ("Daten laden") |
| 2 | Positionen pruefen | sub_rch_Pos |
| 3 | Berechnungsliste pruefen | sub_Berechnungsliste |
| 4 | Gesamtsumme | PosGesamtsumme (berechnet) |
| 5 | Rechnung PDF | btnPDFKopf |
| 6 | Berechnungsliste PDF | btnPDFPos |
| 7 | Lexware-Export | btnRchLex (optional) |
| 8 | Status aendern | Veranst_Status_ID = 4 (Abgerechnet) |

### Rechnungspositionen (sub_rch_Pos)
- Werden aus tbl_MA_VA_Planung aggregiert
- Stundenanzahl * Kundenpreis
- Query: `zqry_Rch_Pos`

### Berechnungsliste (sub_Berechnungsliste)
- Detaillierte Aufstellung pro MA und Tag
- Brutto-/Netto-Stunden
- Query: `zsub_rch_Berechnungsliste`

### VBA-Funktionen (mdl_Rechnungsschreibung)
```vba
' Rechnungsnummer hochzaehlen
Function Update_Rch_Nr(iID As Long) As Long

' Zahlungsbedingungen Text generieren
Public Function Zahlbed_Text(ZahlBed_ID As Long, betrag As Currency) As String

' PDF-Dateiname ermitteln
Function fPDF_Datei(s As String)
```

### Datenbank-Operationen
```sql
-- Rechnungspositionen aggregieren
SELECT VA_ID, SUM(MA_Netto_Std * Stundenpreis) AS Summe
FROM qry_Rch_Berechnungsgrundlage
WHERE VA_ID = ?
GROUP BY VA_ID

-- Rechnungsnummer vergeben
UPDATE tbl_VA_Auftragstamm SET Rech_NR = ? WHERE ID = ?

-- Status aktualisieren
UPDATE tbl_VA_Auftragstamm SET Veranst_Status_ID = 4 WHERE ID = ?
```

---

## 5. Dienstplan erstellen

### Ausloeser
- frm_DP_Dienstplan_Objekt (Objekt-Ansicht)
- frm_DP_Dienstplan_MA (MA-Ansicht)

### Ablauf

| Schritt | Aktion | Element |
|---------|--------|---------|
| 1 | Startdatum waehlen | Datums-Feld |
| 2 | Temp-Tabellen fuellen | fCreate_DP_tmptable() |
| 3 | Kreuztabelle erstellen | qry_DP_Kreuztabelle |
| 4 | Anzeige aktualisieren | sub_DP_Grund.Requery |

### Temp-Tabellen (werden bei jedem Aufruf neu gefuellt)
| Tabelle | Inhalt |
|---------|--------|
| tbltmp_DP_Grund | Objekt/Position pro Zeile |
| tbltmp_DP_Grund_2 | Mit MA-Namen gefuellt |
| tbltmp_DP_Grund_Sort | Sortierungsreihenfolge |

### VBA-Hauptfunktion (mdl_DP_Create)
```vba
Function fCreate_DP_tmptable(dtstartdat As Date, _
    bNurIstNichtZugeordnet As Boolean, _
    iPosAusblendAb As Long)
```

### Query-Kette
1. **qry_DP_Alle_Obj** - Basis: Alle Zuordnungen mit Objekt-Info
2. **qry_DP_Alle_Zt** - Zeitraum-Filter (7 Tage)
3. **qry_DP_Kreuztabelle** - Pivot nach Datum
4. **qry_DP_Alle_Zt_Fill** - MA-Daten zum Fuellen

### Kreuztabellen-Query
```sql
TRANSFORM First(ZuordID) AS ErsterWertvonZuordID
SELECT ObjOrt, Pos_Nr
FROM qry_DP_Alle_Zt
GROUP BY ObjOrt, Pos_Nr
PIVOT Format([VADatum], 'Short Date')
IN ('01.01.2025','02.01.2025',...,'07.01.2025')
```

### Darstellung
- 7 Spalten fuer 7 Tage (Tag1 bis Tag7)
- Pro Tag: MA-Name, von, bis, fraglich-Flag
- Farbcodierung fuer Status

---

## 6. Auftrag kopieren

### Ausloeser
Button "Auftrag kopieren" in frm_VA_Auftragstamm

### Was wird kopiert
| Element | Kopiert? | Anmerkung |
|---------|----------|-----------|
| Auftragsdaten | Ja | Alle Felder ausser ID, Datum |
| Schichten | Ja | tbl_VA_Start Eintraege |
| Datum | Ja (+7) | Default: +7 Tage |
| MA-Zuordnungen | Nein | Muessen neu gemacht werden |
| Rechnung | Nein | |
| Status | Nein | Wird auf 1 (Planung) gesetzt |

### VBA-Funktion
```vba
Function AuftragKopieren(lngVA_ID As Long) As Long
    ' 1. Auftrag kopieren
    ' 2. Schichten kopieren
    ' 3. Tage anlegen
    ' 4. Neuen Datensatz oeffnen
End Function
```

### Datenbank-Operationen
```sql
-- 1. Auftrag kopieren (INSERT ... SELECT)
INSERT INTO tbl_VA_Auftragstamm (Auftrag, Ort, Objekt, ...)
SELECT Auftrag, Ort, Objekt, ...
FROM tbl_VA_Auftragstamm WHERE ID = ?

-- 2. Neue ID ermitteln
SELECT @@IDENTITY AS NeueID

-- 3. Schichten kopieren
INSERT INTO tbl_VA_Start (VA_ID, VADatum_ID, VA_Start, VA_Ende, ...)
SELECT [NeueID], ..., VA_Start, VA_Ende, ...
FROM tbl_VA_Start WHERE VA_ID = ?

-- 4. Tage anlegen
INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum)
VALUES ([NeueID], [NeuesDatum])
```

---

## 7. Mitarbeiter-Import (Excel)

### Ausloeser
Spezial-Formular fuer Massen-Import

### Ablauf
| Schritt | Aktion |
|---------|--------|
| 1 | Excel-Datei auswaehlen |
| 2 | In Temp-Tabelle importieren |
| 3 | Validierung (Pflichtfelder, Duplikate) |
| 4 | Fehlerhafte Zeilen markieren |
| 5 | Korrektur durch User |
| 6 | Endgueltiger Import |

### VBA-Modul
`mdl_N_MA_Import`

### Temp-Tabelle
`sub_XL_Import_MA_temp`

---

## 8. Rueckmeldungen verarbeiten

### Ausloeser
- MA antwortet auf Anfrage (E-Mail)
- Manueller Button "Rueckmeldungen" in frm_VA_Auftragstamm

### Ablauf
| Schritt | Aktion |
|---------|--------|
| 1 | Rueckmeldung empfangen (E-Mail/Anruf) |
| 2 | Status in sub_MA_VA_Zuordnung aendern |
| 3 | Status_Datum setzen |
| 4 | Rueckmeldezeitpunkt protokollieren |

### Status-Aenderungen
```sql
UPDATE tbl_MA_VA_Planung
SET Status_ID = ?,
    Status_Datum = Now(),
    Rueckmeldezeitpunkt = Now()
WHERE ID = ?
```

### Statistik-Formular
`zfrm_Rueckmeldungen` zeigt:
- Anzahl Anfragen
- Anzahl Zusagen
- Anzahl Absagen
- Reaktionszeiten

---

## Prozess-Uebersicht (BPMN-artig)

```
[Auftrag anlegen]
       |
       v
[Schichten definieren] --> [tbl_VA_Start]
       |
       v
[MA anfragen] --> [E-Mail senden] --> [tbl_Log_eMail_Sent]
       |
       v
[Rueckmeldung abwarten]
       |
   +---+---+
   |       |
   v       v
[Zusage] [Absage]
   |
   v
[Einsatzliste senden]
       |
       v
[Auftrag durchfuehren]
       |
       v
[Stunden erfassen] --> [tbl_MA_VA_Planung.MVA_Start/Ende]
       |
       v
[Rechnung erstellen] --> [PDF]
       |
       v
[Auftrag abschliessen] --> Status = 4
```

---

*Dokumentation erstellt: 2026-01-08*
*Basierend auf: VBA-Module, Formular-Analyse, JSON-Exports*
