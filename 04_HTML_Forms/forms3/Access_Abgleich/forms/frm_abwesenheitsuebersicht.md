# frm_abwesenheitsuebersicht

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_abwesenheitsuebersicht |
| **Datensatzquelle** | qry_DP_MA_NVerfueg |
| **Datenquellentyp** | Query |
| **Default View** | Other (Endlosformular) |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |
| **Order By** | [qry_DP_MA_NVerfueg].[VADatum] |
| **OrderByOn** | Ja |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------|
| Auto_Kopfzeile0 | 300 / 60 | 8760 x 460 | 8210719 (Blau) |
| Bezeichnungsfeld0 | 345 / 345 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld3 | 345 / 885 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld6 | 345 / 1425 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld9 | 345 / 1965 | 1290 x 585 | 8355711 (Grau) |
| Bezeichnungsfeld12 | 345 / 2730 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld15 | 345 / 3270 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld18 | 345 / 3810 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld21 | 345 / 4350 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld24 | 345 / 4890 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld27 | 345 / 5430 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld30 | 345 / 5970 | 1290 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld33 | 345 / 6510 | 1290 x 360 | 8355711 (Grau) |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex | Format |
|------|----------------|----------------|---------------|----------|--------|
| VA_ID | VA_ID | 1695 / 345 | 9825 x 360 | 0 | - |
| ZuordID | ZuordID | 1695 / 885 | 9825 x 360 | 1 | - |
| Anz_MA | Anz_MA | 1695 / 1425 | 9825 x 360 | 2 | - |
| ObjOrt | ObjOrt | 1695 / 1965 | 9825 x 585 | 3 | - |
| VADatum | VADatum | 1695 / 2730 | 9825 x 360 | 4 | - |
| Pos_Nr | Pos_Nr | 1695 / 3270 | 9825 x 360 | 5 | - |
| MA_Start | MA_Start | 1695 / 3810 | 9825 x 360 | 6 | Short Time |
| MA_Ende | MA_Ende | 1695 / 4350 | 9825 x 360 | 7 | Short Time |
| MA_ID | MA_ID | 1695 / 4890 | 9825 x 360 | 8 | - |
| MAName | MAName | 1695 / 5430 | 9825 x 360 | 9 | - |
| IstFraglich | IstFraglich | 1695 / 5970 | 9825 x 360 | 10 | - |
| Hlp | Hlp | 1695 / 6510 | 9825 x 360 | 11 | - |

## Farben

| Element | ForeColor | BackColor |
|---------|-----------|-----------|
| Kopfzeile | 8210719 (Blau) | 16777215 (Weiss) |
| Labels | 8355711 (Grau) | 16777215 (Weiss) |
| TextBoxen (Standard) | 4210752 (Dunkelgrau) | 16777215 (Weiss) |
| TextBoxen (hervorgehoben) | 0 (Schwarz) | 16777215 (Weiss) |

## Felder

| Feld | Beschreibung |
|------|--------------|
| VA_ID | Veranstaltungs-ID |
| ZuordID | Zuordnungs-ID |
| Anz_MA | Anzahl Mitarbeiter |
| ObjOrt | Objekt/Ort der Veranstaltung |
| VADatum | Veranstaltungsdatum |
| Pos_Nr | Positionsnummer |
| MA_Start | Startzeit des Mitarbeiters |
| MA_Ende | Endzeit des Mitarbeiters |
| MA_ID | Mitarbeiter-ID |
| MAName | Mitarbeitername |
| IstFraglich | Ist fraglich Flag |
| Hlp | Hilfsfeld |

## Events

Alle Formular- und Control-Events sind als leere Makros definiert.

## Funktionalitaet

Uebersichtsformular fuer Abwesenheiten mit Dienstplan-Kontext:
- Zeigt alle Nicht-Verfuegbarkeiten aus qry_DP_MA_NVerfueg
- Sortiert nach VADatum
- Endlosformular-Darstellung fuer tabellarische Uebersicht
- Zeitfelder mit Short Time Format
