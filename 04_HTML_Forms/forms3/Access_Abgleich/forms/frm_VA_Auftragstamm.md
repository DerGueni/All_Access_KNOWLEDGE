# Access-Export: frm_VA_Auftragstamm

*Generiert aus JSON-Export*

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| RecordSource | qry_Auftrag_Sort (query) |
| AllowEdits | True |
| AllowAdditions | True |
| AllowDeletions | True |
| DataEntry | False |
| DefaultView | Other |
| NavigationButtons | False |
| Filter |  |
| OrderBy | [qry_Auftrag_Sort].[Dienstkleidung] |

## Formular-Events

| Event | Kind | Handler |
|-------|------|---------|
| OnOpen | Procedure | (auto) |
| OnLoad | Procedure | (auto) |
| OnClose | Macro |  |
| OnCurrent | Procedure | (auto) |
| BeforeUpdate | Procedure | (auto) |
| AfterUpdate | Macro |  |
| OnError | Macro |  |
| OnTimer | Macro |  |
| OnApplyFilter | Macro |  |
| OnFilter | Macro |  |
| OnUnload | Macro |  |

## Controls (136 Stueck)

### Buttons (45 Stueck)

| Name | Caption | OnClick | Enabled | Visible |
|------|---------|---------|---------|---------|
| btnSchnellPlan | - | VBA: (auto) | Wahr | Wahr |
| btnMailEins | - | VBA: (auto) | Wahr | Wahr |
| btnAuftrBerech | - | VBA: (auto) | Falsch | Falsch |
| btnDruckZusage | - | VBA: (auto) | Wahr | Wahr |
| btn_letzer_Datensatz | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl40 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl41 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl43 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| mcobtnDelete | - | VBA: (auto) | Wahr | Wahr |
| Befehl38 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| btnRibbonAus | - | VBA: (auto) | Wahr | Wahr |
| btnRibbonEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaAus | - | VBA: (auto) | Wahr | Wahr |
| btnReq | - | VBA: (auto) | Wahr | Wahr |
| btnneuveranst | - | VBA: (auto) | Wahr | Wahr |
| btn_aenderungsprotokoll | - |  | Falsch | Falsch |
| Befehl640 | - | VBA: (auto) | Wahr | Wahr |
| btnmailpos | - | VBA: (auto) | Falsch | Falsch |
| btn_Posliste_oeffnen | - | VBA: (auto) | Falsch | Falsch |
| btn_rueck | - | VBA: (auto) | Wahr | Wahr |
| btnCheck | - | Makro: [Eingebettetes Makro] | Wahr | Falsch |
| btnDruckZusage1 | - | VBA: (auto) | Falsch | Falsch |
| btn_Rueckmeld | - | VBA: (auto) | Wahr | Wahr |
| btnSyncErr | - | VBA: (auto) | Wahr | Wahr |
| btn_ListeStd | - | VBA: (auto) | Wahr | Wahr |
| btn_Autosend_BOS | - | VBA: (auto) | Wahr | Wahr |
| Befehl709 | - | VBA: (auto) | Wahr | Wahr |
| btnMailSub | - | VBA: (auto) | Wahr | Wahr |
| btnDatumLeft | - | VBA: (auto) | Wahr | Wahr |
| btnDatumRight | - | VBA: (auto) | Wahr | Wahr |
| btnPlan_Kopie | - | VBA: (auto) | Wahr | Falsch |
| Befehl543 | - |  | Wahr | Falsch |
| btnVAPlanCrea | - | VBA: (auto) | Falsch | Falsch |
| btn_VA_Abwesenheiten | - | VBA: (auto) | Wahr | Falsch |
| cmd_BWN_send | - |  | Wahr | Falsch |
| btnNeuAttach | - | VBA: (auto) | Wahr | Wahr |
| btnPDFKopf | - | VBA: (auto) | Wahr | Wahr |
| btnPDFPos | - | VBA: (auto) | Wahr | Wahr |
| btn_AbWann | - | VBA: (auto) | Wahr | Wahr |
| btnHeute | - | VBA: (auto) | Wahr | Wahr |
| btnTgBack | - | VBA: (auto) | Wahr | Wahr |
| btnTgVor | - | VBA: (auto) | Wahr | Wahr |
| btn_Tag_loeschen | - |  | Falsch | Falsch |
| cmd_Messezettel_NameEintragen | - | VBA: (auto) | Wahr | Falsch |

### TextBoxen (19 Stueck)

| Name | ControlSource | Format | DefaultValue | Events |
|------|---------------|--------|--------------|--------|
| Rech_NR | Rech_NR |  |  | - |
| ID | ID |  |  | - |
| Dat_VA_Von | Dat_VA_Von | Short Date |  | OnDblClick: Procedure |
| Dat_VA_Bis | Dat_VA_Bis |  |  | OnDblClick: Procedure, AfterUpdate: Procedure |
| PLZ | PLZ |  |  | - |
| Treffpunkt | Treffpunkt |  |  | - |
| Treffp_Zeit | Treffp_Zeit | Short Time |  | BeforeUpdate: Procedure |
| Ansprechpartner | Ansprechpartner |  |  | - |
| PKW_Anzahl | - |  |  | - |
| VerrSatz | Dummy | Euro |  | - |
| TabellenNr | =42 |  |  | - |
| PosGesamtsumme | - | Euro |  | - |
| Bemerkungen | Bemerkungen |  |  | - |
| Auftraege_ab | - | Short Date | =Date() | OnDblClick: Procedure |
| lb_Fahrtkosten | - |  |  | - |
| Text416 | Erst_von |  | =atCNames(1) | BeforeUpdate: Procedure |
| Text418 | Erst_am |  | =Now() | BeforeUpdate: Procedure |
| Text419 | Aend_von |  |  | BeforeUpdate: Procedure |
| Text422 | Aend_am |  |  | BeforeUpdate: Procedure |

### ComboBoxen (13 Stueck)

| Name | ControlSource | RowSource | BoundColumn | Events |
|------|---------------|-----------|-------------|--------|
| Veranst_Status_ID | Veranst_Status_ID | SELECT tbl_VA_Status.ID, tbl_VA_Status.Fortschritt... | 1 | OnDblClick: Procedure, AfterUpdate: Procedure, BeforeUpdate: Procedure |
| IstStatus | - | SELECT -5 as ID, "(Alle)" AS Fortschritt FROM _tbl... | 1 | AfterUpdate: Procedure |
| cboEinsatzliste | - | 0;"Druck Einsatzliste: Tag";-1;"Druck Einsatzliste... | 1 | AfterUpdate: Procedure, BeforeUpdate: Procedure |
| Objekt_ID | Objekt_ID | SELECT [tbl_OB_Objekt].ID, [tbl_OB_Objekt].Objekt,... | 1 | OnDblClick: Procedure, AfterUpdate: Procedure |
| cboVADatum | - | SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum F... | 1 | OnDblClick: Procedure, AfterUpdate: Procedure |
| Objekt | Objekt | SELECT DISTINCT tbl_VA_Auftragstamm.Objekt FROM tb... | 1 | OnDblClick: Procedure |
| Ort | Ort | SELECT DISTINCT tbl_VA_Auftragstamm.Ort FROM tbl_V... | 1 | - |
| Dienstkleidung | Dienstkleidung | SELECT DISTINCT tbl_VA_Auftragstamm.Dienstkleidung... | 1 | - |
| veranstalter_id | Veranstalter_ID | SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundensta... | 1 | OnDblClick: Procedure, AfterUpdate: Procedure |
| cboAnstArt | - | SELECT tbl_hlp_MA_Anstellungsart.ID, tbl_hlp_MA_An... | 1 | OnDblClick: Procedure, AfterUpdate: Procedure |
| cboQuali | - | SELECT [tbl_MA_Einsatzart].ID, [tbl_MA_Einsatzart]... | 1 | - |
| cboID | - | SELECT tbl_VA_Auftragstamm.ID, tbl_VA_Auftragstamm... | 2 | AfterUpdate: Procedure |
| Kombinationsfeld656 | Auftrag | SELECT DISTINCT tbl_VA_Auftragstamm.Auftrag FROM t... | 1 | - |

### Unterformulare (10 Stueck)

| Name | SourceObject | LinkMasterFields | LinkChildFields |
|------|--------------|------------------|-----------------|
| frm_Menuefuehrung | frm_Menuefuehrung |  |  |
| sub_MA_VA_Zuordnung | sub_MA_VA_Zuordnung | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_VA_Start | sub_VA_Start | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_MA_VA_Planung_Absage | sub_MA_VA_Planung_Absage | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_MA_VA_Zuordnung_Status | sub_MA_VA_Planung_Status | ID, cboVADatum | VA_ID, VADatum_ID |
| sub_ZusatzDateien | sub_ZusatzDateien | Objekt_ID, TabellenNr | Ueberordnung, TabellenID |
| sub_tbl_Rch_Kopf | sub_tbl_Rch_Kopf | ID | VA_ID |
| sub_tbl_Rch_Pos_Auftrag | sub_tbl_Rch_Pos_Auftrag | ID | VA_ID |
| sub_VA_Anzeige | sub_VA_Anzeige |  |  |
| zsub_lstAuftrag | frm_lst_row_auftrag |  |  |

### TabControls (1 Stueck)

| Name | Visible | TabIndex |
|------|---------|----------|
| Reg_VA | Wahr | 27 |

### CheckBoxen (2 Stueck)

| Name | ControlSource | DefaultValue | Events |
|------|---------------|--------------|--------|
| cbAutosendEL | Autosend_EL |  | - |
| IstVerfuegbar | - | True | AfterUpdate: Procedure |

### Labels (34 Stueck)

*Labels werden nicht im Detail aufgelistet*

### Andere Controls (11 Stueck)

| Name | Typ |
|------|-----|
| Rechteck620 | Rectangle |
| pgMA_Zusage | Page |
| Option264 | OptionButton |
| pgMA_Plan | Page |
| pgAttach | Page |
| pgRechnung | Page |
| pgBemerk | Page |
| Rechteck619 | Rectangle |
| EmptyCell689 | EmptyCell |
| EmptyCell691 | EmptyCell |
| EmptyCell693 | EmptyCell |

## Zusammenfassung

- **Gesamt Controls:** 136
- **Buttons:** 45
- **TextBoxen:** 19
- **ComboBoxen:** 13
- **ListBoxen:** 0
- **Unterformulare:** 10
- **Labels:** 34
- **Andere:** 11
