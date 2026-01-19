# frm_Startmenue

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Startmenue |
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
| Befehl1 | Personalverwaltung | 11880 / 5610 | 2970 x 915 | OnClick: [Event Procedure] |
| Befehl2 | Auftragsverwaltung | 8985 / 4155 | 2970 x 915 | OnClick: [Event Procedure] |
| Befehl3 | Disposition | 9390 / 9495 | 2970 x 915 | OnClick: [Event Procedure] |
| Befehl4 | Hauptmenü | 12960 / 10740 | 2970 x 915 | OnClick: [Event Procedure] |

### ToggleButtons

| Name | Caption | Position (L/T) | Groesse (W/H) |
|------|---------|----------------|---------------|
| Bild8 | - | 2235 / 0 | 23475 x 13710 |

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

Private Sub Befehl1_Click()
DoCmd.OpenForm "frm_ma_mitarbeiterstamm"

End Sub

Private Sub Befehl2_Click()
DoCmd.OpenForm "frm_va_auftragstamm"

End Sub

Private Sub Befehl3_Click()
DoCmd.OpenForm "frm_dp_dienstplan_objekt"

End Sub

Private Sub Befehl4_Click()
DoCmd.OpenForm "frm_va_auftragstamm"

End Sub```
