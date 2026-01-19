# zfrm_Rueckmeldungen

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | zfrm_Rueckmeldungen |
| **Datensatzquelle** | zqry_Rueckmeldungen |
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
|------|----------------|---------------|-----------||
| Bezeichnungsfeld10 | 60 / 60 | 10440 x 570 | 8355711 (Grau) |
| Bezeichnungsfeld21 | 170 / 566 | 9135 x 1545 | 8355711 (Grau) |
| Bezeichnungsfeld22 | 396 / 3004 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld24 | 396 / 3401 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld26 | 680 / 4081 | 1725 x 315 | 8355711 (Grau) |
| Bezeichnungsfeld28 | 396 / 3798 | 1725 x 315 | 8355711 (Grau) |

### Subforms (Unterformulare)

| Name | Source Object | Position (L/T) | Groesse (W/H) |
|------|---------------|----------------|---------------|
| Untergeordnet19 | - | 0 / 0 | 22686 x 11406 |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------||
| Anstellungsart_ID | Anstellungsart_ID | 2097 / 3004 | 1701 x 300 | 1 |
| Text23 | Anstellungsart_ID | 2097 / 3401 | 1701 x 300 | 2 |
| Text25 | Anstellungsart_ID | 2381 / 4081 | 1701 x 300 | 3 |
| Text27 | Anstellungsart_ID | 2097 / 3798 | 1701 x 300 | 4 |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: [Event Procedure]
- OnClose: [Event Procedure]
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine
- OnActivate: Keine
- OnDeactivate: Keine

## VBA-Code

```vba
Option Compare Database

Private Sub Form_Close()

Dim tbl_rueck As String

    tbl_rueck = "ztbl_Rueckmeldezeiten"
    CurrentDb.Execute "DELETE * FROM " & tbl_rueck
    
End Sub


Private Sub Form_Load()

Call Rückmeldeauswertung

End Sub```
