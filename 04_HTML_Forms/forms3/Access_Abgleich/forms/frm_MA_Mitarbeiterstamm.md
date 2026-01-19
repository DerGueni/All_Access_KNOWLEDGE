# Access-Export: frm_MA_Mitarbeiterstamm

*Generiert aus JSON-Export*

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| RecordSource | tbl_MA_Mitarbeiterstamm (table) |
| AllowEdits | True |
| AllowAdditions | True |
| AllowDeletions | True |
| DataEntry | False |
| DefaultView | Other |
| NavigationButtons | False |
| Filter | ID = 437 |
| OrderBy |  |

## Formular-Events

| Event | Kind | Handler |
|-------|------|---------|
| OnOpen | Procedure | (auto) |
| OnLoad | Procedure | (auto) |
| OnClose | Macro |  |
| OnCurrent | Procedure | (auto) |
| BeforeUpdate | Procedure | (auto) |
| AfterUpdate | Procedure | (auto) |
| OnError | Macro |  |
| OnTimer | Macro |  |
| OnApplyFilter | Macro |  |
| OnFilter | Macro |  |
| OnUnload | Macro |  |

## Controls (290 Stueck)

### Buttons (41 Stueck)

| Name | Caption | OnClick | Enabled | Visible |
|------|---------|---------|---------|---------|
| Befehl39 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl40 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl41 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl43 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl46 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| mcobtnDelete | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| btnLstDruck | - | VBA: (auto) | Wahr | Wahr |
| btnMADienstpl | - | VBA: (auto) | Wahr | Falsch |
| btnRibbonAus | - | VBA: (auto) | Wahr | Wahr |
| btnRibbonEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaAus | - | VBA: (auto) | Wahr | Wahr |
| lbl_Mitarbeitertabelle | - | VBA: (auto) | Wahr | Wahr |
| btnZeitkonto | - | VBA: (auto) | Wahr | Wahr |
| btnZKFest | - | VBA: (auto) | Wahr | Wahr |
| btnZKMini | - | VBA: (auto) | Wahr | Wahr |
| btnDateisuch | - | VBA: (auto) | Wahr | Wahr |
| btnDateisuch2 | - | VBA: (auto) | Wahr | Wahr |
| btnMaps | - | VBA: (auto) | Wahr | Wahr |
| btnZuAb | - | VBA: (auto) | Wahr | Wahr |
| btnXLZeitkto | - | VBA: (auto) | Wahr | Wahr |
| btnLesen | - | VBA: (auto) | Wahr | Wahr |
| btnUpdJahr | - | VBA: (auto) | Wahr | Wahr |
| btnXLJahr | - | VBA: (auto) | Wahr | Wahr |
| btnXLEinsUeber | - | VBA: (auto) | Wahr | Falsch |
| btnZKeinzel | - | VBA: (auto) | Wahr | Wahr |
| Bericht_drucken | - | VBA: (auto) | Wahr | Wahr |
| btnAU_Lesen | - | VBA: (auto) | Wahr | Wahr |
| btnRch | - | VBA: (auto) | Wahr | Falsch |
| btnCalc | - | VBA: (auto) | Wahr | Wahr |
| btnXLUeberhangStd | - | VBA: (auto) | Wahr | Falsch |
| btnau_lesen2 | - |  | Wahr | Wahr |
| btnAUPl_Lesen | - | VBA: (auto) | Wahr | Wahr |
| btn_Diensplan_prnt | - | VBA: (auto) | Wahr | Wahr |
| btn_Dienstplan_send | - | VBA: (auto) | Wahr | Wahr |
| btnXLDiePl | - | VBA: (auto) | Wahr | Falsch |
| btnMehrfachtermine | - | VBA: (auto) | Wahr | Wahr |
| btnXLNverfueg | - | VBA: (auto) | Wahr | Falsch |
| btnReport_Dienstkleidung | - | VBA: (auto) | Wahr | Wahr |
| btn_MA_EinlesVorlageDatei | - | VBA: (auto) | Wahr | Wahr |
| btnXLVordrucke | - | VBA: (auto) | Wahr | Wahr |

### TextBoxen (70 Stueck)

| Name | ControlSource | Format | DefaultValue | Events |
|------|---------------|--------|--------------|--------|
| DiDatumAb | - | ddd/ dd/mm/yy | =Date() | OnDblClick: Procedure |
| lbl_ab | - |  |  | - |
| PersNr | ID |  |  | - |
| LEXWare_ID | LEXWare_ID |  |  | - |
| Nachname | Nachname | @ |  | - |
| Vorname | Vorname | @ |  | - |
| Strasse | Strasse | @ |  | - |
| Nr | Nr |  |  | - |
| PLZ | PLZ | @ |  | - |
| Ort | Ort | @ |  | - |
| Land | Land | @ | "Deutschland" | - |
| Bundesland | Bundesland | @ | "Bayern" | - |
| Tel_Mobil | Tel_Mobil |  |  | - |
| Tel_Festnetz | Tel_Festnetz |  |  | - |
| Email | Email | @ |  | - |
| Staatsang | Staatsang |  |  | - |
| Geb_Dat | Geb_Dat |  |  | OnDblClick: Procedure |
| Geb_Ort | Geb_Ort |  |  | - |
| Geb_Name | Geb_Name |  |  | - |
| Eintrittsdatum | Eintrittsdatum | dd\.mm\.yyyy |  | OnDblClick: Procedure |
| Austrittsdatum | Austrittsdatum |  |  | OnDblClick: Procedure |
| Kostenstelle | Kostenstelle | @ |  | - |
| DienstausweisNr | DienstausweisNr |  | =[ID] | - |
| Ausweis_Endedatum | Ausweis_Endedatum | Short Date | =[ID] | - |
| Ausweis_Funktion | Ausweis_Funktion | @ |  | - |
| Epin_DFB | Epin_DFB | @ |  | - |
| Bewacher_ID | Bewacher_ID | @ |  | - |
| Auszahlungsart | Auszahlungsart | @ |  | - |
| Bankname | Bankname | @ |  | - |
| Bankleitzahl | Bankleitzahl | @ |  | - |
| Kontonummer | Kontonummer | @ |  | - |
| BIC | BIC | @ |  | - |
| IBAN | IBAN | @ |  | - |
| Kontoinhaber | Kontoinhaber | @ |  | - |
| Bezuege_gezahlt_als | Bezuege_gezahlt_als | @ |  | - |
| Sozialvers_Nr | Sozialvers_Nr |  |  | - |
| SteuerNr | SteuerNr | @ |  | - |
| KV_Kasse | KV_Kasse | @ |  | - |
| Steuerklasse | Steuerklasse | @ |  | - |
| Arbst_pro_Arbeitstag | Arbst_pro_Arbeitstag |  |  | - |
| Arbeitstage_pro_Woche | Arbeitstage_pro_Woche | General Number |  | - |
| Resturl_Vorjahr | Resturl_Vorjahr |  |  | - |
| Urlaubsanspr_pro_Jahr | Urlaubsanspr_pro_Jahr |  |  | - |
| StundenZahlMax | StundenZahlMax |  |  | - |
| Kosten_pro_MAStunde | Kosten_pro_MAStunde |  |  | - |
| Datum_34a | Datum_34a |  |  | - |
| tblBilddatei | tblBilddatei |  |  | - |
| Bemerkungen | Bemerkungen | @ |  | - |
| tblSignaturdatei | tblSignaturdatei |  |  | - |
| Amt_Pruefung | Amt_Pruefung |  |  | - |
| Datum_Pruefung | Datum_Pruefung |  |  | - |
| Mon_aktdat | - | Short Date |  | - |
| EinsProMon | - |  |  | - |
| TagProMon | - |  |  | - |
| txRechSub | - |  |  | AfterUpdate: Procedure |
| txRechCheck | - |  |  | - |
| txRechBezahlt | - | General Date |  | - |
| txDatumDP | Datum_DP |  |  | - |
| Briefkopf | Briefkopf |  |  | - |
| Anr | Anr |  |  | - |
| Anr_Brief | Anr_Brief |  |  | - |
| Anr_eMail | Anr_eMail |  |  | - |
| Text676 | - | Short Date |  | - |
| Text678 | - | Short Date |  | - |
| AU_von | - | Short Date |  | - |
| AU_bis | - | Short Date |  | - |
| Erst_von | Erst_von |  | =atCNames(1) | - |
| Erst_am | Erst_am |  | =Now() | - |
| Aend_von | Aend_von |  |  | - |
| Aend_am | Aend_am |  |  | - |

### ComboBoxen (17 Stueck)

| Name | ControlSource | RowSource | BoundColumn | Events |
|------|---------------|-----------|-------------|--------|
| Geschlecht | Geschlecht | SELECT tbl_Hlp_MA_Geschlecht.ID, tbl_Hlp_MA_Geschl... | 1 | - |
| Anstellungsart | Anstellungsart_ID | SELECT tbl_hlp_MA_Anstellungsart.ID, tbl_hlp_MA_An... | 1 | OnDblClick: Procedure, AfterUpdate: Procedure |
| Stundenlohn_brutto | Stundenlohn_brutto | SELECT zqry_ZK_Lohnarten_Zuschlag.ID, zqry_ZK_Lohn... | 1 | - |
| Fahrerlaubnis | Fahrerlaubnis | "ja";"nein" | 1 | - |
| Taetigkeit_Bezeichnung | Taetigkeit_Bezeichnung | "Sicherheitspersonal";"Servicepersonal" | 1 | - |
| Kleidergroesse | Kleidergroesse | "XS";"S";"M";"L";"XL";"XXL";"XXXL" | 1 | - |
| cboMonat | - | SELECT [_tblAlleMonate].MonNr, [_tblAlleMonate].Mo... | 1 | AfterUpdate: Procedure |
| cboJahr | - | _tblAlleJahre | 1 | AfterUpdate: Procedure |
| cboJahrJa | - | _tblAlleJahre | 1 | - |
| cboFilterAuftrag | - | SELECT DISTINCT VA_ID,Auftrag FROM qry_MA_VA_Plan_... | 2 | AfterUpdate: Procedure |
| pgJahrStdVorMon | - | _tblAlleJahre | 1 | - |
| cboAuswahl | - | 0;"";1;"Telefon";2;"§ 34a";3;"E-Mail Adresse";4;"A... | 1 | AfterUpdate: Procedure |
| NurAktiveMA | - | 0;"Alle";1;"Alle Aktiven";2;"Festangestellte";3;"M... | 1 | AfterUpdate: Procedure |
| MANameEingabe | - | SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & " ... | 1 | AfterUpdate: Procedure |
| cboIDSuche | - | SELECT tbl_MA_Mitarbeiterstamm.ID, ([Nachname] & "... | 1 | AfterUpdate: Procedure |
| Kombinationsfeld674 | - | SELECT [_tblZeitraumAngaben].ID, [_tblZeitraumAnga... | 1 | - |
| cboZeitraum | - | SELECT [_tblZeitraumAngaben].ID, [_tblZeitraumAnga... | 1 | AfterUpdate: Procedure |

### ListBoxen (7 Stueck)

| Name | RowSource | ColumnCount | Events |
|------|-----------|-------------|--------|
| lst_MA | SELECT ID, Nachname, Vorname, Ort FROM tbl_MA_Mita... | 5 | OnClick: Procedure |
| lst_Tl1M | SELECT * FROM qry_JB_MA_Jahr_tl1A_Ue WHERE AktJahr... | 16 | - |
| lst_Tl2M | SELECT * FROM qry_JB_MA_Jahr_tl2A_Ue WHERE AktJahr... | 13 | BeforeUpdate: Macro |
| lst_Tl1 | SELECT * FROM qry_JB_MA_Jahr_tl1A_Ue WHERE AktJahr... | 16 | - |
| lst_Tl2 | SELECT * FROM qry_JB_MA_Jahr_tl2A_Ue WHERE AktJahr... | 13 | - |
| lst_Zuo | SELECT * FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHE... | 11 | OnDblClick: Procedure |
| lstPl_Zuo | SELECT * FROM qry_Dienstplan WHERE VADatum Between... | 10 | - |

### Unterformulare (13 Stueck)

| Name | SourceObject | LinkMasterFields | LinkChildFields |
|------|--------------|------------------|-----------------|
| Menü | frm_Menuefuehrung |  |  |
| sub_MA_ErsatzEmail | sub_MA_ErsatzEmail | ID | MA_ID |
| sub_MA_Einsatz_Zuo | sub_MA_Einsatz_Zuo | ID | MA_ID |
| sub_tbl_MA_Zeitkonto_Aktmon2 | sub_tbl_MA_Zeitkonto_Aktmon2 |  |  |
| sub_tbl_MA_Zeitkonto_Aktmon1 | sub_tbl_MA_Zeitkonto_Aktmon1 |  |  |
| frmStundenübersicht | frm_Stundenübersicht2 | ID | MA_ID |
| sub_MA_tbl_MA_NVerfuegZeiten | sub_MA_tbl_MA_NVerfuegZeiten |  |  |
| sub_MA_Dienstkleidung | sub_MA_Dienstkleidung | ID | MA_ID |
| sub_tbltmp_MA_Ausgef_Vorlagen | sub_tbltmp_MA_Ausgef_Vorlagen |  |  |
| Untergeordnet360 | sub_tbl_MA_StundenFolgemonat | ID, pgJahrStdVorMon | MA_ID, AktJahr |
| ufrm_Maps | sub_Browser |  |  |
| subAuftragRech | sub_Auftrag_Rechnung_Gueni | ID | MA_ID |
| subZuoStunden | zfrm_ZUO_Stunden_Sub_lb |  |  |

### TabControls (1 Stueck)

| Name | Visible | TabIndex |
|------|---------|----------|
| reg_MA | Wahr | 1 |

### CheckBoxen (12 Stueck)

| Name | ControlSource | DefaultValue | Events |
|------|---------------|--------------|--------|
| IstAktiv | IstAktiv |  | - |
| IstSubunternehmer | IstSubunternehmer |  | AfterUpdate: Procedure |
| Eigener_PKW | Eigener_PKW |  | - |
| Ist_RV_Befrantrag | Ist_RV_Befrantrag |  | - |
| IstNSB | IstNSB |  | - |
| Hat_keine_34a | Hat_keine_34a |  | - |
| HatSachkunde | HatSachkunde |  | - |
| Lex_Aktiv | Lex_Aktiv |  | - |
| cbMailAbrech | eMail_Abrechnung |  | - |
| Modul1_DFB | Modul1_DFB |  | - |
| TermineAbHeute | - | True | AfterUpdate: Procedure |
| IstBrfAuto | IstBrfAuto | False | - |

### Labels (112 Stueck)

*Labels werden nicht im Detail aufgelistet*

### Andere Controls (17 Stueck)

| Name | Typ |
|------|-----|
| Rechteck37 | Rectangle |
| pgAdresse | Page |
| MA_Bild | Image |
| MA_Signatur | Image |
| pgMonat | Page |
| pgJahr | Page |
| pgAuftrUeb | Page |
| pgStundenuebersicht | Page |
| pgPlan | Page |
| pgnVerfueg | Page |
| pgDienstKl | Page |
| pgVordr | Page |
| pgBrief | Page |
| pgStdUeberlaufstd | Page |
| pgMaps | Page |
| pgSubRech | Page |
| EmptyCell683 | EmptyCell |

## Zusammenfassung

- **Gesamt Controls:** 290
- **Buttons:** 41
- **TextBoxen:** 70
- **ComboBoxen:** 17
- **ListBoxen:** 7
- **Unterformulare:** 13
- **Labels:** 112
- **Andere:** 17
