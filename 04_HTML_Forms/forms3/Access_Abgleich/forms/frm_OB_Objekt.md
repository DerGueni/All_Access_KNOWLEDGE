# Access-Export: frm_OB_Objekt

*Generiert aus JSON-Export*

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| RecordSource | tbl_OB_Objekt (table) |
| AllowEdits | True |
| AllowAdditions | True |
| AllowDeletions | True |
| DataEntry | False |
| DefaultView | Other |
| NavigationButtons | False |
| Filter | ID = 10 |
| OrderBy |  |

## Formular-Events

| Event | Kind | Handler |
|-------|------|---------|
| OnOpen | Procedure | (auto) |
| OnLoad | Procedure | (auto) |
| OnClose | Macro |  |
| OnCurrent | Macro |  |
| BeforeUpdate | Procedure | (auto) |
| AfterUpdate | Macro |  |
| OnError | Macro |  |
| OnTimer | Macro |  |
| OnApplyFilter | Macro |  |
| OnFilter | Macro |  |
| OnUnload | Macro |  |

## Controls (49 Stueck)

### Buttons (15 Stueck)

| Name | Caption | OnClick | Enabled | Visible |
|------|---------|---------|---------|---------|
| btn_Back_akt_Pos_List | - | VBA: (auto) | Wahr | Falsch |
| btnReport | - | VBA: (auto) | Wahr | Wahr |
| btn_letzer_Datensatz | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl40 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl41 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl42 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl43 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| btnHilfe | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| mcobtnDelete | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| btnNeuVeranst | - |  | Wahr | Wahr |
| btnRibbonAus | - | VBA: (auto) | Wahr | Wahr |
| btnRibbonEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaAus | - | VBA: (auto) | Wahr | Wahr |
| btnNeuAttach | - | VBA: (auto) | Wahr | Wahr |

### TextBoxen (15 Stueck)

| Name | ControlSource | Format | DefaultValue | Events |
|------|---------------|--------|--------------|--------|
| ID | ID |  |  | - |
| Objekt | Objekt |  |  | - |
| TabellenNr | =42 |  |  | - |
| PLZ | PLZ |  |  | - |
| Ort | Ort |  |  | - |
| Strasse | Strasse | @ |  | - |
| Treffpunkt | Treffpunkt |  |  | - |
| Treffp_Zeit | Treffp_Zeit | Short Time |  | - |
| Dienstkleidung | Dienstkleidung |  |  | - |
| Ansprechpartner | Ansprechpartner |  |  | - |
| Text435 | - |  |  | - |
| Erst_von | Erst_von |  | =atCNames(1) | - |
| Erst_am | Erst_am |  | =Now() | - |
| Aend_von | Aend_von |  |  | - |
| Aend_am | Aend_am |  |  | - |

### ListBoxen (1 Stueck)

| Name | RowSource | ColumnCount | Events |
|------|-----------|-------------|--------|
| Liste_Obj | SELECT tbl_OB_Objekt.ID, tbl_OB_Objekt.Objekt, tbl... | 3 | OnClick: Procedure |

### Unterformulare (3 Stueck)

| Name | SourceObject | LinkMasterFields | LinkChildFields |
|------|--------------|------------------|-----------------|
| sub_OB_Objekt_Positionen | sub_OB_Objekt_Positionen | ID | OB_Objekt_Kopf_ID |
| sub_ZusatzDateien | sub_ZusatzDateien | ID, TabellenNr | Ueberordnung, TabellenID |
| frm_Menuefuehrung | frm_Menuefuehrung |  |  |

### TabControls (1 Stueck)

| Name | Visible | TabIndex |
|------|---------|----------|
| Reg_VA | Wahr | 9 |

### Labels (12 Stueck)

*Labels werden nicht im Detail aufgelistet*

### Andere Controls (2 Stueck)

| Name | Typ |
|------|-----|
| pgPos | Page |
| pgAttach | Page |

## Zusammenfassung

- **Gesamt Controls:** 49
- **Buttons:** 15
- **TextBoxen:** 15
- **ComboBoxen:** 0
- **ListBoxen:** 1
- **Unterformulare:** 3
- **Labels:** 12
- **Andere:** 2
