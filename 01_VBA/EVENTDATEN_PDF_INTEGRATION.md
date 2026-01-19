# Eventdaten als PDF-Anhang bei Einsatzlisten-Versand

## Übersicht

Diese Dokumentation beschreibt die Integration von Web-Eventdaten als zusätzlichen PDF-Anhang beim Versand der Einsatzliste an Mitarbeiter.

## Dateien

| Datei | Beschreibung |
|-------|--------------|
| `mod_N_EventDaten.bas` | Web-Scraper für Eventdaten (bereits erstellt) |
| `mod_N_EventDaten_PDF.bas` | PDF-Erstellung und Attachment-Erweiterung |
| `create_eventdaten_report.py` | Setup-Script für Query und Report |
| `rpt_N_EventDaten` | Access Report (manuell zu erstellen) |

## Ablauf

```
┌─────────────────────────────────────────────────────────────────┐
│  btnMailEins_Click (Einsatzliste senden MA)                     │
├─────────────────────────────────────────────────────────────────┤
│  1. Öffnet frm_MA_Serien_eMail_Auftrag                          │
│  2. Ruft Autosend(2, VA_ID, VADatum_ID) auf                     │
│                                                                 │
│  In Autosend:                                                   │
│  ├── Einsatzliste-PDF erstellen (rpt_Auftrag_Zusage)            │
│  ├── myattach = Array(Einsatzliste_PDF)                         │
│  │                                                              │
│  │   ┌─────────────────────────────────────────┐                │
│  │   │ NEU: Eventdaten-PDF hinzufügen          │                │
│  │   │ myattach = erweitere_attachments(       │                │
│  │   │              myattach, VA_ID)           │                │
│  │   └─────────────────────────────────────────┘                │
│  │                                                              │
│  ├── E-Mail mit Anhängen versenden                              │
│  │                                                              │
│  │   ┌─────────────────────────────────────────┐                │
│  │   │ NEU: Cleanup nach Versand               │                │
│  │   │ Call cleanup_temp_pdf(VA_ID)            │                │
│  │   └─────────────────────────────────────────┘                │
│  │                                                              │
│  └── Fertig                                                     │
└─────────────────────────────────────────────────────────────────┘
```

## Installation

### Schritt 1: VBA-Module importieren

1. Access Frontend öffnen
2. VBA-Editor öffnen (Alt+F11)
3. Datei → Importieren:
   - `mod_N_EventDaten.bas` (Web-Scraper)
   - `mod_N_EventDaten_PDF.bas` (PDF-Integration)

### Schritt 2: Query und Tabelle erstellen

```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA"
python create_eventdaten_report.py
```

### Schritt 3: Report manuell erstellen

In Access:

1. **Erstellen → Berichtsentwurf**

2. **Datensatzquelle**: `qry_N_EventDaten_Report`

3. **Report-Layout**:

```
+----------------------------------------------------------+
|  CONSEC - EVENT-INFORMATIONEN                             |
+----------------------------------------------------------+
|  Auftrag: [Auftrag]                                       |
|  Objekt:  [Objekt]                                        |
|  Ort:     [Ort]                                           |
|  Datum:   [Dat_VA_Von]                                    |
+----------------------------------------------------------+
|                                                           |
|  ZEITEN                                                   |
|  ─────────────────────────────────────                    |
|  Einlass:    [Einlass]                                    |
|  Beginn:     [Beginn]                                     |
|  Ende:       [Ende]                                       |
|                                                           |
|  TREFFPUNKT                                               |
|  ─────────────────────────────────────                    |
|  [Treffpunkt] um [Treffp_Zeit]                            |
|                                                           |
|  DIENSTKLEIDUNG                                           |
|  ─────────────────────────────────────                    |
|  [Dienstkleidung]                                         |
|                                                           |
|  ANSPRECHPARTNER                                          |
|  ─────────────────────────────────────                    |
|  [Ansprechpartner]                                        |
|                                                           |
|  ZUSÄTZLICHE INFORMATIONEN                                |
|  ─────────────────────────────────────                    |
|  [Infos]                                                  |
|                                                           |
|  Quelle: [WebLink]                                        |
+----------------------------------------------------------+
|  Automatisch generiert am [Datum]                         |
+----------------------------------------------------------+
```

4. **Events hinzufügen**:
   - Bei Öffnen → Code aus mod_N_Report_EventDaten
   - Bei Schließen → Code aus mod_N_Report_EventDaten

5. **Report speichern als**: `rpt_N_EventDaten`

### Schritt 4: Autosend-Funktion anpassen

In `frm_MA_Serien_eMail_Auftrag` die `Autosend`-Funktion erweitern:

**SUCHEN** (nach der Zeile wo myattach erstellt wird):
```vba
myattach = Array(...)
```

**EINFÜGEN** (direkt danach):
```vba
' Eventdaten-PDF hinzufügen (falls vorhanden)
myattach = erweitere_attachments(myattach, VA_ID)
```

**SUCHEN** (nach dem Mail-Versand, vor End Sub):
```vba
' Hier am Ende der Funktion einfügen:
```

**EINFÜGEN**:
```vba
' Temporäre PDFs löschen
Call cleanup_temp_pdf(VA_ID)
```

## Funktionen

### `hat_eventdaten(VA_ID As Long) As Boolean`
Prüft ob für die VA Eventdaten vorhanden sind.

### `pdf_erstellen_eventdaten(VA_ID As Long) As String`
Erstellt PDF aus Eventdaten. Gibt Pfad zur PDF zurück oder "" wenn keine Daten.

### `erweitere_attachments(bestehendeAttachments, VA_ID) As Variant`
Fügt Eventdaten-PDF zum Attachment-Array hinzu.

### `cleanup_temp_pdf(Optional VA_ID As Long)`
Löscht temporäre PDF-Dateien nach Versand.

## Test

```vba
' Im Direktfenster (Strg+G):
Call Test_EventDaten_PDF(123)  ' 123 = VA_ID
```

## Voraussetzungen

1. **Eventdaten müssen geladen sein**:
   - Tab "Eventdaten" im Auftrag öffnen
   - Button "Web-Daten laden" klicken
   - Eventdaten werden in `tbl_N_VA_EventDaten` gespeichert

2. **Report muss existieren**:
   - `rpt_N_EventDaten` muss manuell erstellt sein

3. **Query muss existieren**:
   - `qry_N_EventDaten_Report` (wird durch Script erstellt)

## Fehlerbehandlung

- Wenn keine Eventdaten vorhanden → kein zusätzlicher Anhang
- Wenn Report fehlt → Fehlermeldung im Debug-Fenster
- Wenn PDF-Erstellung fehlschlägt → nur Einsatzliste wird gesendet

## Dateipfade

- Temporäre PDFs: `%TEMP%\EventDaten_[VA_ID]_[Auftrag]_[Datum].pdf`
- Werden nach Versand automatisch gelöscht

## Troubleshooting

### PDF wird nicht erstellt
1. Report `rpt_N_EventDaten` existiert?
2. Query `qry_N_EventDaten_Report` existiert?
3. Eventdaten für VA geladen? → `? hat_eventdaten(VA_ID)` im Direktfenster

### PDF wird nicht angehängt
1. `erweitere_attachments` wird aufgerufen?
2. Debug: `Debug.Print pdf_erstellen_eventdaten(VA_ID)`

### Alte PDFs bleiben im Temp-Ordner
1. `cleanup_temp_pdf` wird aufgerufen?
2. Manuell löschen: `Call cleanup_temp_pdf(0)` (alle)
