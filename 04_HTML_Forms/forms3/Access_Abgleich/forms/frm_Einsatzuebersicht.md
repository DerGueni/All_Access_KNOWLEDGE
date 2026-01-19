# Access-Export: frm_Einsatzuebersicht (frm_Einsatzuebersicht_kpl)

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| RecordSource | qry_Einsatzuebersicht_kpl |
| DefaultView | ContinuousForms |
| AllowEdits | Wahr |
| AllowAdditions | Wahr |
| AllowDeletions | Wahr |
| DataEntry | Falsch |
| FilterOn | Falsch |
| Filter | (leer) |
| OrderByOn | Wahr |
| OrderBy | [qry_Einsatzuebersicht_kpl].[VADatum], [qry_Einsatzuebersicht_kpl].[Auftrag], [qry_Einsatzuebersicht_kpl].[PosNr] |
| Cycle | 0 |
| NavigationButtons | Wahr |
| DividingLines | Falsch |

## Formular-Events

| Event | Wert |
|-------|------|
| OnOpen | (leer) |
| OnLoad | (leer) |
| OnClose | (leer) |
| OnCurrent | (leer) |
| BeforeUpdate | (leer) |
| AfterUpdate | (leer) |
| OnError | (leer) |
| OnTimer | (leer) |
| OnApplyFilter | (leer) |
| OnFilter | (leer) |
| OnUnload | (leer) |

## Controls (24 Stueck)

### TextBoxen (11 Stueck, alle datengebunden)

| Name | ControlSource | Format | Events |
|------|---------------|--------|--------|
| Auftrag | Auftrag | - | - |
| Objekt | Objekt | - | - |
| Ort | Ort | - | - |
| MA_Start | MA_Start | Short Time | - |
| MA_Ende | MA_Ende | Short Time | - |
| MA_Brutto_Std2 | MA_Brutto_Std2 | Fixed | - |
| MA_Netto_Std2 | MA_Netto_Std2 | Fixed | - |
| Nachname | Nachname | - | - |
| Vorname | Vorname | - | - |
| PosNr | PosNr | - | - |
| VADatum | VADatum | - | - |

### Labels (12 Stueck)

| Name | Visible | ForeColor | BackColor | Beschreibung |
|------|---------|-----------|-----------|--------------|
| Auto_Kopfzeile0 | Wahr | 8210719 | 16777215 | Formular-Titel |
| Bezeichnungsfeld0 | Wahr | 8355711 | 16777215 | Label fuer "Auftrag" |
| Bezeichnungsfeld3 | Wahr | 8355711 | 16777215 | Label fuer "Objekt" |
| Bezeichnungsfeld6 | Wahr | 8355711 | 16777215 | Label fuer "Ort" |
| Bezeichnungsfeld9 | Wahr | 8355711 | 16777215 | Label fuer "MA_Start" |
| Bezeichnungsfeld12 | Wahr | 8355711 | 16777215 | Label fuer "MA_Ende" |
| Bezeichnungsfeld15 | Wahr | 8355711 | 16777215 | Label fuer "MA_Brutto_Std2" |
| Bezeichnungsfeld18 | Wahr | 8355711 | 16777215 | Label fuer "MA_Netto_Std2" |
| Bezeichnungsfeld21 | Wahr | 8355711 | 16777215 | Label fuer "Nachname" |
| Bezeichnungsfeld24 | Wahr | 8355711 | 16777215 | Label fuer "Vorname" |
| Bezeichnungsfeld27 | Wahr | 8355711 | 16777215 | Label fuer "PosNr" |
| Bezeichnungsfeld30 | Wahr | 8355711 | 16777215 | Label fuer "VADatum" |

### Bilder (1 Stueck)

| Name | Visible | Position |
|------|---------|----------|
| Auto_Logo0 | Wahr | Links oben (300, 60) |

### Unterformulare

Keine Unterformulare vorhanden.

## Datenquelle: qry_Einsatzuebersicht_kpl

Diese Abfrage liefert folgende Felder:
- **Auftrag** - Name des Auftrags
- **Objekt** - Objekt/Einsatzort
- **Ort** - Stadt/Adresse
- **VADatum** - Einsatzdatum
- **MA_Start** - Dienstbeginn (Zeit)
- **MA_Ende** - Dienstende (Zeit)
- **MA_Brutto_Std2** - Brutto-Stunden
- **MA_Netto_Std2** - Netto-Stunden
- **Nachname** - MA Nachname
- **Vorname** - MA Vorname
- **PosNr** - Positionsnummer

## Sortierung

Standardsortierung nach:
1. VADatum (Datum)
2. Auftrag
3. PosNr (Positionsnummer)

## Layout-Besonderheiten

- **ContinuousForms** - Listenansicht mit mehreren Datensaetzen
- **NavigationButtons** = Wahr - Hat Navigationstasten
- Alle TextBoxen sind 11325 twips breit
- Labels sind 1783 twips breit

## Control-Positionen (in twips)

| Control | Left | Top | Width | Height |
|---------|------|-----|-------|--------|
| Auto_Logo0 | 300 | 60 | 690 | 460 |
| Auto_Kopfzeile0 | 1050 | 60 | 10755 | 460 |
| Auftrag | 2190 | 345 | 11325 | 555 |
| Objekt | 2190 | 1080 | 11325 | 555 |
| Ort | 2190 | 1815 | 11325 | 555 |
| MA_Start | 2190 | 2550 | 11325 | 345 |
| MA_Ende | 2190 | 3075 | 11325 | 345 |
| MA_Brutto_Std2 | 2190 | 3600 | 11325 | 345 |
| MA_Netto_Std2 | 2190 | 4125 | 11325 | 345 |
| Nachname | 2190 | 4650 | 11325 | 555 |
| Vorname | 2190 | 5385 | 11325 | 555 |
| PosNr | 2190 | 6120 | 11325 | 345 |
| VADatum | 2190 | 6645 | 11325 | 345 |

## Funktionsbeschreibung

Einfaches Listen-Formular zur Anzeige aller Einsaetze:
1. Zeigt alle Einsaetze aus qry_Einsatzuebersicht_kpl
2. Sortiert nach Datum, Auftrag, Position
3. Ermoeglicht Bearbeitung aller Felder
4. Hat Standard-Navigationsbuttons

## Hinweis

Dieses Formular hat keine Events und keine Buttons - es ist ein reines Daten-Anzeigeformular mit Navigation.
