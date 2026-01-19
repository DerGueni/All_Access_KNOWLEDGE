# frm_DP_Dienstplan_Objekt

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_DP_Dienstplan_Objekt |
| **Datensatzquelle** | Keine (ungebunden) |
| **Datenquellentyp** | None |
| **Default View** | Other |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| lbl_Datum | 26588 / 510 | 1005 x 270 | Datum-Anzeige |
| Bezeichnungsfeld96 | 1980 / 450 | 2715 x 405 | Titel |
| Bezeichnungsfeld15 | 14633 / 283 | 4965 x 360 | Checkbox-Label |
| Bezeichnungsfeld17 | 14684 / 566 | 2820 x 330 | Position-Filter Label |
| Bezeichnungsfeld20 | 17688 / 566 | 1875 x 330 | Zusatz-Info |
| lbl_Version | 26532 / 226 | 1515 x 270 | Versions-Anzeige |
| lbl_Auftrag | 3330 / 0 | 3555 x 420 | Auftrags-Spalte |

### TextBoxen (Datums-Spalten)

| Name | Format | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|--------|----------------|---------------|--------------|
| dtStartdatum | Short Date | 7539 / 346 | 1555 x 271 | Startdatum-Eingabe |
| tmpFokus | - | 7532 / 286 | 0 x 315 | Fokus-Hilfsfeld |
| PosAusblendAb | - | 17291 / 566 | 297 x 270 | Position-Filter (Default: 25) |
| lbl_Tag_1 | ddd/ dd/mm/yy | 6828 / 0 | 3178 x 420 | Tag 1 Spalte |
| lbl_Tag_2 | ddd/ dd/mm/yy | 9944 / 0 | 3103 x 420 | Tag 2 Spalte |
| lbl_Tag_3 | ddd/ dd/mm/yy | 13035 / 0 | 3133 x 420 | Tag 3 Spalte |
| lbl_Tag_4 | ddd/ dd/mm/yy | 16169 / 0 | 3133 x 420 | Tag 4 Spalte |
| lbl_Tag_5 | ddd/ dd/mm/yy | 19283 / 0 | 3178 x 420 | Tag 5 Spalte |
| lbl_Tag_6 | ddd/ dd/mm/yy | 22409 / 0 | 3118 x 420 | Tag 6 Spalte |
| lbl_Tag_7 | ddd/ dd/mm/yy | 25527 / 0 | 3118 x 420 | Tag 7 Spalte |

### CheckBoxen

| Name | Position (L/T) | Groesse (W/H) | Default | Beschreibung |
|------|----------------|---------------|---------|--------------|
| NurIstNichtZugeordnet | 14400 / 306 | 305 x 285 | False | Nur nicht zugeordnete anzeigen |
| IstAuftrAusblend | 14400 / 636 | 305 x 285 | False | Auftrag ausblenden |

### CommandButtons

| Name | Position (L/T) | Groesse (W/H) | Sichtbar | Funktion |
|------|----------------|---------------|----------|----------|
| btnStartdatum | 7539 / 602 | 1557 x 301 | Ja | Startdatum setzen |
| btnVor | 9355 / 340 | 567 x 224 | Ja | Woche vor |
| btnrueck | 9354 / 629 | 567 x 224 | Ja | Woche zurueck |
| btn_Heute | 10260 / 456 | 975 x 270 | Ja | Heute anzeigen |
| btnOutpExcelSend | 21373 / 170 | 1890 x 330 | Nein | Excel senden |
| btnOutpExcel | 21373 / 737 | 1890 x 330 | Ja | Excel Export |
| Befehl37 | 27836 / 56 | 351 x 261 | Ja | Schliessen (Makro) |
| btnRibbonAus | 851 / 313 | 238 x 253 | Ja | Ribbon aus |
| btnRibbonEin | 851 / 643 | 238 x 253 | Ja | Ribbon ein |
| btnDaBaEin | 1136 / 478 | 238 x 253 | Ja | Datenbank ein |
| btnDaBaAus | 566 / 478 | 238 x 253 | Ja | Datenbank aus |

### Rectangles (Rahmen)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| Rechteck108 | 7441 / 271 | 2571 x 686 | Datums-Rahmen |

### SubForms

| Name | Source Object | Position (L/T) | Groesse (W/H) |
|------|---------------|----------------|---------------|
| sub_DP_Grund | sub_DP_Grund | 3000 / 450 | 25645 x 5746 |
| frm_Menuefuehrung | frm_Menuefuehrung | 45 / 0 | 3237 x 6291 |

## Farben

| Element | ForeColor | BackColor |
|---------|-----------|-----------|
| Tag-Spalten | 0 (Schwarz) | 16179314 (Hellorange) |
| Auftrag-Label | 16777215 (Weiss) | 15801669 (Orange) |
| Excel-Buttons | 0 (Schwarz) | 14136213 (Gelb) |
| Ribbon-Buttons | 0 (Schwarz) | 16777215 (Weiss) |

## Events

### Formular-Events
- **OnOpen**: Procedure Handler
- **OnLoad**: Procedure Handler
- **OnClose**: Procedure Handler
- OnCurrent: Keine

### TextBox-Events (Tag-Spalten)
- Alle lbl_Tag_* haben OnDblClick: Procedure Handler

### Button-Events
Alle Navigation-Buttons (btnVor, btnrueck, btn_Heute) haben Procedure Handler.

## Funktionalitaet

Woechentlicher Dienstplan nach Objekt/Veranstaltung:

### Datumsnavigation:
- **Startdatum**: Eingabe oder Auswahl
- **Vor/Zurueck**: Wochenweise Navigation
- **Heute**: Sprung zur aktuellen Woche

### 7-Tage-Ansicht:
- Tag 1 bis Tag 7 Spalten
- Format: Wochentag + Datum (ddd/ dd/mm/yy)
- DblClick auf Tag-Spalte fuer Details

### Filter:
- NurIstNichtZugeordnet: Nur MA anzeigen die noch nicht zugeordnet sind
- IstAuftrAusblend: Auftraege ausblenden
- PosAusblendAb: Positionen ab X ausblenden (Default: 25)

### Export:
- Excel-Export der Dienstplan-Daten
- Excel mit Versand (unsichtbar)

### Navigation:
- Eingebettetes Menue (frm_Menuefuehrung)
- Ribbon-Steuerung
- Datenbank-Navigation

### Hauptbereich:
- sub_DP_Grund: Zeigt die eigentlichen Dienstplan-Daten
- Grosse Darstellung (25645 x 5746)
