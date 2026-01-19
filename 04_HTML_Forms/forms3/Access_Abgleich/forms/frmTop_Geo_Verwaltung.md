# frmTop_Geo_Verwaltung

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frmTop_Geo_Verwaltung |
| **Datensatzquelle** | - |
| **Default View** | SingleForm |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Ja |

## Controls


### Buttons (Schaltflaechen)

| Name | Caption | Position (L/T) | Groesse (W/H) | Events |
|------|---------|----------------|---------------|--------|
| cmdBatchObjekte | Alle Objekte geocodieren | 500 / 500 | 3500 x 400 | OnClick: [Event Procedure] |
| cmdBatchMA | Alle Mitarbeiter geocodieren | 500 / 1000 | 3500 x 400 | OnClick: [Event Procedure] |
| cmdBuildDistances | Entfernungen berechnen | 500 / 1500 | 3500 x 400 | OnClick: [Event Procedure] |
| cmdStats | Statistik anzeigen | 500 / 2000 | 3500 x 400 | OnClick: [Event Procedure] |
| cmdClose | Schließen | 500 / 2500 | 3500 x 400 | OnClick: [Event Procedure] |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: Keine
- OnClose: Keine
- OnCurrent: Keine
- BeforeUpdate: Keine
- AfterUpdate: Keine
- OnActivate: Keine
- OnDeactivate: Keine

## VBA-Code

```vba
Option Compare Database
Option Explicit


Private Sub cmdBatchObjekte_Click()
    RunBatchGeocodeObjekte
End Sub

Private Sub cmdBatchMA_Click()
    RunBatchGeocodeMA
End Sub

Private Sub cmdBuildDistances_Click()
    RunBuildAllDistances
End Sub

Private Sub cmdStats_Click()
    ShowGeoStats
End Sub

Private Sub cmdClose_Click()
    DoCmd.Close acForm, Me.Name
End Sub```
