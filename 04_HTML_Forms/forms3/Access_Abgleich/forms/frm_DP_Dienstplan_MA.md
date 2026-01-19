# Access-Export: frm_DP_Dienstplan_MA

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| RecordSource | (keine) |
| DefaultView | Other |
| AllowEdits | Wahr |
| AllowAdditions | Wahr |
| AllowDeletions | Wahr |
| DataEntry | Falsch |
| FilterOn | Falsch |
| Filter | (leer) |
| OrderByOn | Falsch |
| OrderBy | (leer) |
| Cycle | 0 |
| NavigationButtons | Falsch |
| DividingLines | Falsch |

## Formular-Events

| Event | Wert |
|-------|------|
| OnOpen | Procedure (auto) |
| OnLoad | Procedure (auto) |
| OnClose | Procedure (auto) |
| OnCurrent | (leer) |
| BeforeUpdate | (leer) |
| AfterUpdate | (leer) |
| OnError | (leer) |
| OnTimer | (leer) |
| OnApplyFilter | (leer) |
| OnFilter | (leer) |
| OnUnload | (leer) |

## Controls (30 Stueck)

### Buttons (12 Stueck)

| Name | Caption | OnClick | Enabled | Visible |
|------|---------|---------|---------|---------|
| btnStartdatum | - | Procedure (auto) | Wahr | Wahr |
| btnVor | - | Procedure (auto) | Wahr | Wahr |
| btnrueck | - | Procedure (auto) | Wahr | Wahr |
| btn_Heute | - | Procedure (auto) | Wahr | Wahr |
| btnOutpExcelSend | - | Procedure (auto) | Wahr | Falsch |
| btnOutpExcel | - | Procedure (auto) | Wahr | Wahr |
| Befehl37 | - | [Eingebettetes Makro] | Wahr | Wahr |
| btnRibbonAus | - | Procedure (auto) | Wahr | Wahr |
| btnRibbonEin | - | Procedure (auto) | Wahr | Wahr |
| btnDaBaEin | - | Procedure (auto) | Wahr | Wahr |
| btnDaBaAus | - | Procedure (auto) | Wahr | Wahr |
| btnMADienstpl | - | Procedure (auto) | Wahr | Wahr |
| Befehl20 | - | Procedure (auto) | Wahr | Falsch |
| btnDPSenden | - | Procedure (auto) | Wahr | Wahr |

### TextBoxen (10 Stueck)

| Name | ControlSource | Format | Events |
|------|---------------|--------|--------|
| dtStartdatum | - | Short Date | OnDblClick: Procedure (auto) |
| tmpFokus | - | - | Visible: Falsch |
| dtEnddatum | - | Short Date | - |
| lbl_Tag_1 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |
| lbl_Tag_2 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |
| lbl_Tag_3 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |
| lbl_Tag_4 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |
| lbl_Tag_5 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |
| lbl_Tag_6 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |
| lbl_Tag_7 | - | ddd/ dd/mm/yy | OnDblClick: Procedure (auto) |

### ComboBoxen (1 Stueck)

| Name | ControlSource | RowSource | Events |
|------|---------------|-----------|--------|
| NurAktiveMA | - | 0;"Alle anzeigen";1;"Alle aktiven";2;"Festangestellte";3;"Minijobber";4;Sub" | AfterUpdate: Procedure (auto), DefaultValue: 2 |

### Labels (4 Stueck)

| Name | Visible | ForeColor | BackColor |
|------|---------|-----------|-----------|
| lbl_Datum | Wahr | 16777215 | 16777215 |
| Bezeichnungsfeld96 | Wahr | -2147483616 | 16777215 |
| lbl_Version | Wahr | 16777215 | 16777215 |
| lbl_Auftrag | Wahr | 16777215 | 15801669 |

### Rechtecke (1 Stueck)

| Name | BackColor | Visible |
|------|-----------|---------|
| Rechteck108 | -2147483613 | Wahr |

### Unterformulare (2 Stueck)

| Name | SourceObject | LinkMasterFields | LinkChildFields |
|------|--------------|------------------|-----------------|
| sub_DP_Grund | sub_DP_Grund_MA | (keine) | (keine) |
| frm_Menuefuehrung | frm_Menuefuehrung | (keine) | (keine) |

## Wochen-Ansicht (7 Tage)

Die TextBoxen lbl_Tag_1 bis lbl_Tag_7 zeigen die 7 Tage der aktuellen Woche an:
- Format: ddd/ dd/mm/yy (z.B. "Mo/ 13/01/26")
- Bei DblClick wird der Tag im Detail geoeffnet

## Datums-Navigation

| Button | Funktion |
|--------|----------|
| btnVor | Eine Woche vorwaerts |
| btnrueck | Eine Woche zurueck |
| btn_Heute | Zur aktuellen Woche springen |
| btnStartdatum | Datumsauswahl oeffnen |
| dtStartdatum | Start-Datum Eingabefeld |
| dtEnddatum | End-Datum Eingabefeld |

## MA-Filter (NurAktiveMA)

| Wert | Bedeutung |
|------|-----------|
| 0 | Alle anzeigen |
| 1 | Alle aktiven |
| 2 | Festangestellte (Default) |
| 3 | Minijobber |
| 4 | Sub |

## Spezielle Funktionen

| Button | Funktion |
|--------|----------|
| btnMADienstpl | MA-Dienstplan oeffnen |
| btnDPSenden | Dienstplan per E-Mail senden |
| btnOutpExcel | Export nach Excel |
| btnOutpExcelSend | Export und per E-Mail senden (versteckt) |

## Unterschied zu frm_DP_Dienstplan_Objekt

- Dieses Formular ist **mitarbeiter-zentriert** (zeigt Einsaetze pro MA)
- sub_DP_Grund verwendet **sub_DP_Grund_MA** (nicht sub_DP_Grund)
- Hat Enddatum-Feld fuer Zeitraum-Auswahl
- Hat MA-Filter (Festangestellte/Minijobber/Sub)
- Hat "Dienstplan senden" Button

## Funktionsbeschreibung

Mitarbeiter-basierter Dienstplan - zeigt 7 Tage mit allen Mitarbeitern:
1. Wochen-Navigation (vor/zurueck/heute)
2. Filter nach Anstellungsart
3. Unterformular sub_DP_Grund_MA zeigt die MA-Einsaetze
4. Dienstplan per E-Mail versenden
5. Excel-Export moeglich
