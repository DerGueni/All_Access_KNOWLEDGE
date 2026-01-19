# Access-Export: frm_KD_Kundenstamm

*Generiert aus JSON-Export*

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| RecordSource | SELECT tbl_KD_Kundenstamm.* FROM tbl_KD_Kundenstamm ORDER BY tbl_KD_Kundenstamm.kun_Firma;  (table) |
| AllowEdits | True |
| AllowAdditions | True |
| AllowDeletions | True |
| DataEntry | False |
| DefaultView | Other |
| NavigationButtons | False |
| Filter | kun_ID = 20727 |
| OrderBy |  |

## Formular-Events

| Event | Kind | Handler |
|-------|------|---------|
| OnOpen | Macro |  |
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

## Controls (187 Stueck)

### Buttons (17 Stueck)

| Name | Caption | OnClick | Enabled | Visible |
|------|---------|---------|---------|---------|
| btnAlle | - | VBA: (auto) | Wahr | Falsch |
| Befehl39 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl40 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl41 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl43 | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| Befehl46 | - | VBA: (auto) | Wahr | Wahr |
| mcobtnDelete | - | Makro: [Eingebettetes Makro] | Wahr | Wahr |
| btnUmsAuswert | - | VBA: (auto) | Wahr | Wahr |
| btnRibbonAus | - | VBA: (auto) | Wahr | Wahr |
| btnRibbonEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaEin | - | VBA: (auto) | Wahr | Wahr |
| btnDaBaAus | - | VBA: (auto) | Wahr | Wahr |
| btnAuswertung | - | VBA: (auto) | Wahr | Wahr |
| btnAufRchPDF | - | VBA: (auto) | Wahr | Wahr |
| btnAufRchPosPDF | - | VBA: (auto) | Wahr | Wahr |
| btnAufEinsPDF | - | VBA: (auto) | Wahr | Wahr |
| btnNeuAttach | - | VBA: (auto) | Wahr | Wahr |

### TextBoxen (70 Stueck)

| Name | ControlSource | Format | DefaultValue | Events |
|------|---------------|--------|--------------|--------|
| kun_kreditinstitut | kun_kreditinstitut |  |  | - |
| kun_Matchcode | kun_Matchcode |  |  | - |
| kun_blz | kun_blz |  |  | - |
| kun_kontonummer | kun_kontonummer |  |  | - |
| kun_strasse | kun_strasse |  |  | - |
| kun_iban | kun_iban |  |  | - |
| kun_plz | kun_plz |  |  | - |
| kun_ort | kun_ort |  |  | - |
| kun_bic | kun_bic |  |  | - |
| kun_ustidnr | kun_ustidnr |  |  | - |
| kun_telefon | kun_telefon |  |  | - |
| kun_telefax | kun_telefax |  |  | - |
| kun_mobil | kun_mobil |  |  | - |
| kun_email | kun_email |  |  | - |
| kun_BriefKopf | kun_BriefKopf |  |  | - |
| kun_URL | kun_URL |  |  | - |
| adr_mobil | kun_mobil |  |  | - |
| adr_eMail | - |  |  | - |
| Anschreiben | kun_Anschreiben |  | "Sehr geehrte Damen und Herren," | - |
| adr_telefon | - |  |  | - |
| kun_land_vorwahl | kun_land_vorwahl |  |  | - |
| kun_geloescht | kun_geloescht |  |  | - |
| KD_Ges | - | Euro |  | - |
| KD_VJ | - | Euro |  | - |
| KD_LJ | - | Euro |  | - |
| KD_LM | - | Euro |  | - |
| PosGesamtsumme | - | Euro |  | - |
| UmsNGes1 | - | Euro |  | - |
| PersGes1 | - | Fixed |  | - |
| StdGes1 | - | Fixed |  | - |
| UmsGes1 | - | Euro |  | - |
| Std51 | - | Fixed |  | - |
| Pers51 | - | Fixed |  | - |
| Std61 | - | Fixed |  | - |
| Pers61 | - | Fixed |  | - |
| Std71 | - | Fixed |  | - |
| Pers71 | - | Fixed |  | - |
| AufAnz1 | - | Fixed |  | - |
| UmsNGes2 | - | Euro |  | - |
| AufAnz2 | - | Fixed |  | - |
| PersGes2 | - | Fixed |  | - |
| StdGes2 | - | Fixed |  | - |
| UmsGes2 | - | Euro |  | - |
| Std52 | - | Fixed |  | - |
| Pers52 | - | Fixed |  | - |
| Std62 | - | Fixed |  | - |
| Pers62 | - | Fixed |  | - |
| Std72 | - | Fixed |  | - |
| Pers72 | - | Fixed |  | - |
| UmsNGes3 | - | Euro |  | - |
| AufAnz3 | - | Fixed |  | - |
| PersGes3 | - | Fixed |  | - |
| StdGes3 | - | Fixed |  | - |
| UmsGes3 | - | Euro |  | - |
| Std53 | - | Fixed |  | - |
| Pers53 | - | Fixed |  | - |
| Std63 | - | Fixed |  | - |
| Pers63 | - | Fixed |  | - |
| Std73 | - | Fixed |  | - |
| Pers73 | - | Fixed |  | - |
| kun_memo | kun_memo |  |  | - |
| kun_ID | kun_ID |  |  | - |
| kun_bezeichnung | kun_bezeichnung |  |  | - |
| kun_firma | kun_firma |  |  | - |
| TabellenNr | =2 |  |  | - |
| Text473 | - |  |  | - |
| Erst_am | Erst_am | ddd dd/mm/yyyy | =Now() | - |
| Erst_von | Erst_von |  | =atcnames(1) | - |
| Aend_am | Aend_am | ddd dd/mm/yyyy | =Now() | - |
| Aend_von | Aend_von |  | =atcnames(1) | - |

### ComboBoxen (9 Stueck)

| Name | ControlSource | RowSource | BoundColumn | Events |
|------|---------------|-----------|-------------|--------|
| cboSuchPLZ | - | SELECT "_ALLE" AS kun_plz, "Alle" AS kun_ort FROM ... | 1 | AfterUpdate: Procedure |
| cboSuchOrt | - | SELECT "_ALLE" AS kun_Ort, "Alle" AS kun_plz FROM ... | 1 | AfterUpdate: Procedure |
| cboKDNrSuche | - | SELECT tbl_KD_Kundenstamm.kun_Id FROM tbl_KD_Kunde... | 1 | AfterUpdate: Procedure |
| kun_LKZ | kun_LKZ | SELECT [_tblLKZ].ISO_2 AS LKZ, [_tblLKZ].Landesnam... | 1 | - |
| kun_Zahlbed | kun_Zahlbed | SELECT [_tblEigeneFirma_Zahlungsbedingungen].[ID],... | 1 | - |
| kun_IDF_PersonID | kun_IDF_PersonID | qryAdrKundZuo2 | 1 | AfterUpdate: Procedure |
| kun_AdressArt | kun_AdressArt | SELECT [tbl_KD_Adressart].ID, [tbl_KD_Adressart].k... | 1 | OnDblClick: Procedure |
| Textschnell | - | SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundensta... | 1 | AfterUpdate: Procedure |
| cbo_Auswahl | - | 0;"";1;"Telefon";2;"eMail";3;"Umsatz";4;"" | 1 | AfterUpdate: Procedure |

### ListBoxen (1 Stueck)

| Name | RowSource | ColumnCount | Events |
|------|-----------|-------------|--------|
| lst_KD | SELECT tbl_KD_Kundenstamm.kun_Id, tbl_KD_Kundensta... | 4 | OnClick: Procedure |

### Unterformulare (7 Stueck)

| Name | SourceObject | LinkMasterFields | LinkChildFields |
|------|--------------|------------------|-----------------|
| sub_KD_Standardpreise | sub_KD_Standardpreise | kun_ID | kun_ID |
| sub_KD_Auftragskopf | sub_KD_Auftragskopf | kun_ID | kun_ID |
| sub_KD_Rch_Auftragspos | sub_KD_Rch_Auftragspos |  |  |
| sub_Rch_Kopf_Ang | sub_Rch_Kopf_Ang | kun_ID | kun_ID |
| sub_ZusatzDateien | sub_ZusatzDateien | kun_ID, TabellenNr | Ueberordnung, TabellenID |
| sub_Ansprechpartner | sub_Ansprechpartner | kun_Id | kun_Id |
| Menü | frm_Menuefuehrung |  |  |

### TabControls (1 Stueck)

| Name | Visible | TabIndex |
|------|---------|----------|
| RegStammKunde | Wahr | 4 |

### CheckBoxen (4 Stueck)

| Name | ControlSource | DefaultValue | Events |
|------|---------------|--------------|--------|
| kun_IstAktiv | kun_IstAktiv |  | AfterUpdate: Procedure |
| kun_IstSammelRechnung | kun_IstSammelRechnung |  | - |
| kun_ans_manuell | kun_ans_manuell | False | - |
| NurAktiveKD | - | False | AfterUpdate: Procedure |

### Labels (67 Stueck)

*Labels werden nicht im Detail aufgelistet*

### Andere Controls (11 Stueck)

| Name | Typ |
|------|-----|
| Rechteck37 | Rectangle |
| pgMain | Page |
| pgPreise | Page |
| Auftragsübersicht | Page |
| pg_Rch_Kopf | Page |
| Rechteck414 | Rectangle |
| Rechteck412 | Rectangle |
| pg_Ang | Page |
| pgAttach | Page |
| pgAnsprech | Page |
| pgBemerk | Page |

## Zusammenfassung

- **Gesamt Controls:** 187
- **Buttons:** 17
- **TextBoxen:** 70
- **ComboBoxen:** 9
- **ListBoxen:** 1
- **Unterformulare:** 7
- **Labels:** 67
- **Andere:** 11
