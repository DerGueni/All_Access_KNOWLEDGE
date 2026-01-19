# zfrm_Rueckmeldungen (Rueckmeldestatistik)

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | zfrm_Rueckmeldungen |
| **Datensatzquelle** | zqry_Rueckmeldungen |
| **Datenquellentyp** | Query |
| **Default View** | Other |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------|
| Bezeichnungsfeld10 | 60 / 60 | 10440 x 570 | 8355711 (Grau) |
| Bezeichnungsfeld21 | 170 / 566 | 9135 x 1545 | 8355711 (Grau) |
| Bezeichnungsfeld22 | 396 / 3004 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld24 | 396 / 3401 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld26 | 680 / 4081 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld28 | 396 / 3798 | 1725 x 315 | 8355711 (Grau) |

### SubForm

| Name | Source Object | Position (L/T) | Groesse (W/H) |
|------|---------------|----------------|---------------|
| Untergeordnet19 | zsub_Rueckmeldungen | 0 / 0 | 22686 x 11406 |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------|
| Anstellungsart_ID | Anstellungsart_ID | 2097 / 3004 | 1701 x 300 | 1 |
| Text23 | Anstellungsart_ID | 2097 / 3401 | 1701 x 300 | 2 |
| Text25 | Anstellungsart_ID | 2381 / 4081 | 1701 x 300 | 3 |
| Text27 | Anstellungsart_ID | 2097 / 3798 | 1701 x 300 | 4 |

## Farben

| Element | ForeColor | BackColor |
|---------|-----------|-----------|
| Labels | 8355711 (Grau) | 16777215 (Weiss) |
| TextBoxen | 4210752 (Dunkelgrau) | 16777215 (Weiss) |
| BorderColor | 10921638 (Hellgrau) | - |

## Events

### Formular-Events
- OnOpen: Keine
- **OnLoad**: Procedure Handler
- **OnClose**: Procedure Handler
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine

## Funktionalitaet

Statistik-Formular fuer Rueckmeldungen von Mitarbeitern:

### Hauptkomponente:
- **Unterformular** (zsub_Rueckmeldungen): Zeigt die eigentlichen Rueckmeldedaten
- Grosses Subform-Control (22686 x 11406) fuer tabellarische Darstellung

### Filter-Optionen:
- Anstellungsart_ID als Filter-Kriterium (mehrfach vorhanden)

### Besonderheiten:
- OnLoad und OnClose Events mit Procedure Handler (vermutlich Initialisierung/Cleanup)
- Daten aus zqry_Rueckmeldungen Query
