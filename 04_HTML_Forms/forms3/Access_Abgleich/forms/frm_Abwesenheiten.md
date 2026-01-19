# frm_Abwesenheiten

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Abwesenheiten |
| **Datensatzquelle** | qry_MA_Abwesend Tag |
| **Datenquellentyp** | Query |
| **Default View** | SingleForm |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------|
| Auto_Kopfzeile0 | 2355 / 30 | 3810 x 460 | 16777215 (Weiss) |
| Bezeichnungsfeld0 | 345 / 345 | 1153 x 585 | 8355711 (Grau) |
| Bezeichnungsfeld3 | 345 / 1110 | 1153 x 360 | 8355711 (Grau) |
| Bezeichnungsfeld6 | 345 / 1650 | 1153 x 585 | 8355711 (Grau) |
| Bezeichnungsfeld9 | 345 / 2415 | 1153 x 585 | 8355711 (Grau) |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------|
| Zeittyp_ID | Zeittyp_ID | 1560 / 345 | 9825 x 585 | 0 |
| AbwDat | AbwDat | 1560 / 1110 | 9825 x 360 | 1 |
| Nachname | Nachname | 1560 / 1650 | 9825 x 585 | 2 |
| Vorname | Vorname | 1560 / 2415 | 9825 x 585 | 3 |

## Farben

| Element | ForeColor | BackColor | BorderColor |
|---------|-----------|-----------|-------------|
| Kopfzeile | 16777215 (Weiss) | 16777215 (Weiss) | 8210719 (Blau) |
| Labels | 8355711 (Grau) | 16777215 (Weiss) | 8355711 (Grau) |
| TextBoxen | 4210752 (Dunkelgrau) | 16777215 (Weiss) | 10921638 (Hellgrau) |

## Felder

| Feld | Beschreibung | Format |
|------|--------------|--------|
| Zeittyp_ID | Art der Abwesenheit (Krank, Urlaub, etc.) | - |
| AbwDat | Abwesenheitsdatum | - |
| Nachname | Nachname des Mitarbeiters | @ |
| Vorname | Vorname des Mitarbeiters | @ |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: Keine
- OnClose: Keine
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine

### Control-Events
Alle Controls haben leere Macro-Events definiert.

## Funktionalitaet

Das Formular zeigt Abwesenheitstage fuer Mitarbeiter an:
- Anzeige des Abwesenheitstyps (Zeittyp_ID)
- Datum der Abwesenheit (AbwDat)
- Name des betroffenen Mitarbeiters (Nachname, Vorname)

Die Daten kommen aus der Query `qry_MA_Abwesend Tag`.
