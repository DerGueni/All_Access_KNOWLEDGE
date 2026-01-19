# frm_Kundenpreise

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Kundenpreise |
| **Datensatzquelle** | _Auswertung_Sub_Kundenpreise |
| **Datenquellentyp** | Unknown |
| **Default View** | Continuous |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |

## Controls


### Buttons (Schaltflaechen)

| Name | Caption | Position (L/T) | Groesse (W/H) | Events |
|------|---------|----------------|---------------|--------|
| Befehl22 | Druckansicht | 9751 / 396 | 1821 x 396 | OnClick: [Event Procedure] |
### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | ForeColor |
|------|----------------|---------------|-----------||
| Auto_Kopfzeile0 | 2865 / 30 | 2820 x 460 | 16777215 (Weiss) |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex |
|------|----------------|----------------|---------------|----------||
| kun_Firma | kun_Firma | 5205 / 15 | 4470 x 420 | 0 |
| StdPreis | StdPreis | 9765 / 15 | 1530 x 420 | 1 |
| kun_Id | kun_Id | 3555 / 15 | 1575 x 420 | 2 |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: [Event Procedure]
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

Private Sub Befehl22_Click()
DoCmd.OpenReport "rpt_Kundenpreise", acViewPreview


End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub

Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub

Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub

```
