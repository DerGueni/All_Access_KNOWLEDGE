# frm_MA_Serien_eMail_Auftrag

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_Serien_eMail_Auftrag |
| **Record Source** | (keine) |
| **Default View** | Other |
| **AllowEdits** | Wahr |
| **AllowAdditions** | Wahr |
| **AllowDeletions** | Wahr |
| **DataEntry** | Falsch |
| **FilterOn** | Falsch |
| **NavigationButtons** | Wahr |
| **DividingLines** | Falsch |

---

## Formular-Events

| Event | Typ | Handler |
|-------|-----|---------|
| **OnOpen** | Procedure | (auto) |
| **OnLoad** | Procedure | (auto) |

---

## Controls nach Typ

### CommandButtons (14)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | BackColor | Visible | OnClick |
|------|----------|----------------|---------------|-----------|---------|---------|
| Befehl38 | 0 | 18935, 56 | 381 x 321 | 16777215 | Wahr | Macro |
| btnSendEmail | 1 | 13266, 340 | 1938 x 445 | 14136213 | Wahr | Procedure |
| btnSchnellPlan | 2 | 19899, 623 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnZuAbsage | 3 | 19842, 170 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnAuftrag | 4 | 16102, 340 | 2010 x 445 | 14136213 | Wahr | Procedure |
| btnHilfe | 5 | 18425, 56 | 381 x 321 | 16777215 | Wahr | Macro |
| btnPosListeAtt | 6 | 6519, 623 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnRibbonAus | 7 | 965, 271 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnRibbonEin | 8 | 965, 601 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnDaBaEin | 9 | 1250, 436 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnDaBaAus | 10 | 680, 436 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnPDFCrea | 11 | 6519, 56 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnAttachSuch | 11 | 4170, 6778 | 345 x 315 | 16777215 | Wahr | Procedure |
| btnAttLoesch | 12 | 4633, 6750 | 1085 x 315 | 14136213 | Wahr | Procedure |

### ComboBoxes (5)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | RowSource | AfterUpdate |
|------|----------|----------------|---------------|-----------|-------------|
| VA_ID | 0 | 4470, 150 | 5929 x 315 | SQL (tbl_VA_Auftragstamm + tbl_VA_AnzTage) | Procedure |
| cboVADatum | 1 | 10575, 165 | 2089 x 315 | SQL (tbl_VA_AnzTage) | Procedure |
| Voting_Text | 8 | 12112, 1770 | 7386 x 390 | tbl_hlp_Voting | (keine) |
| cboeMail_Vorlage | 9 | 12112, 763 | 7386 x 300 | SQL (tbl_MA_Serien_eMail_Vorlage) | Procedure |
| cboSendPrio | 15 | 17910, 1305 | 1583 x 285 | 0;"Prio Nieder";1;"Prio Normal";2;"Prio Hoch" | (keine) |

### ListBoxes (2)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | Visible | AfterUpdate |
|------|----------|----------------|---------------|---------|-------------|
| lstZeiten | 2 | 3240, 2210 | 2470 x 2070 | Falsch | Procedure |
| lstMA_Plan | 3 | 6315, 2135 | 4116 x 7470 | Wahr | (keine) - OnClick: Procedure |

### TextBoxes (5)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | Locked |
|------|----------|----------------|---------------|--------|
| Textinhalt | 4 | 10650, 3060 | 8835 x 6522 | Wahr |
| Betreffzeile | 7 | 12110, 2265 | 7359 x 390 | Falsch |
| AbsendenAls | 6 | 12095, 1275 | 5649 x 390 | Falsch |
| iGes_MA | 13 | 4762, 1247 | 887 x 345 | Wahr |
| txEmpfaenger | 19 | 12111, 2715 | 7359 x 300 | Falsch |

### OptionGroups (2)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstPlanAlle | 5 | 2 | Falsch | Procedure |
| ogZeitraum | 18 | 1 | Wahr | Procedure |

### OptionButtons (7)

| Name | TabIndex | Visible | Position |
|------|----------|---------|----------|
| Option9 | 0 | Falsch | In IstPlanAlle |
| Option11 | 1 | Falsch | In IstPlanAlle |
| Option13 | 2 | Falsch | In IstPlanAlle |
| Option96 | 3 | Falsch | In IstPlanAlle |
| opGesamt | 0 | Wahr | In ogZeitraum |
| opAbHeute | 1 | Wahr | In ogZeitraum |
| opDatum | 2 | Wahr | In ogZeitraum |
| opMA | 3 | Wahr | In ogZeitraum |

### CheckBoxes (2)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstAlleZeiten | 14 | True | Falsch | Procedure |
| cbInfoAtConsec | 20 | True | Wahr | (keine) |

### ToggleButtons (1)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstHTML | 16 | True | Falsch | Procedure |

### SubForms (2)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | SourceObject |
|------|----------|----------------|---------------|--------------|
| sub_tbltmp_Attachfile | 10 | 3225, 7103 | 2515 x 2501 | sub_tbltmp_Attachfile |
| frm_Menuefuehrung | 17 | 0, 0 | 3005 x 9647 | frm_Menuefuehrung |

### Labels (14)

| Name | Position (L,T) | Groesse (W,H) | ForeColor |
|------|----------------|---------------|-----------|
| Auto_Kopfzeile0 | 2820, 345 | 2520 x 465 | -2147483616 |
| lbl_Datum | 18530, 721 | 973 x 352 | -2147483616 |
| Bezeichnungsfeld1 | 3315, 150 | 1020 x 294 | 0 |
| Bezeichnungsfeld26 | 10635, 195 | 1005 x 324 | 0 |
| Bezeichnungsfeld7 | 3255, 1815 | 2475 x 285 | 0 |
| Bezeichnungsfeld24 | 6315, 1786 | 1245 x 285 | 0 |
| Bezeichnungsfeld197 | 10620, 1770 | 1395 x 390 | -2147483630 |
| Bezeichnungsfeld16 | 10635, 2265 | 1395 x 390 | -2147483630 |
| Bezeichnungsfeld18 | 10637, 763 | 1350 x 390 | -2147483630 |
| Bezeichnungsfeld199 | 3255, 6763 | 1410 x 315 | -2147483630 |
| Bezeichnungsfeld9 | 3004, 1247 | 1605 x 330 | 0 |
| Bezeichnungsfeld193 | 10620, 1275 | 1395 x 390 | -2147483630 |
| Bezeichnungsfeld89 | 10636, 2721 | 1395 x 315 | 0 |
| Bezeichnungsfeld95 | 13205, 225 | 1860 x 285 | 8355711 |

---

## Zusammenfassung

- **Zweck**: Serien-E-Mail an Mitarbeiter fuer Auftraege versenden
- **Hauptfunktionen**:
  - Auftrag auswaehlen (VA_ID)
  - Datum auswaehlen (cboVADatum)
  - E-Mail-Vorlage waehlen (cboeMail_Vorlage)
  - Mitarbeiter-Liste (lstMA_Plan)
  - E-Mail-Text bearbeiten (Textinhalt, Betreffzeile)
  - Anhaenge verwalten (sub_tbltmp_Attachfile)
  - Zeitraum-Optionen (ogZeitraum)
  - E-Mail senden (btnSendEmail)
- **Sidebar**: frm_Menuefuehrung (eingebettet)
- **Besonderheiten**:
  - Voting-Funktion (Voting_Text)
  - Prioritaet einstellbar (cboSendPrio)
  - HTML-Modus Toggle (IstHTML)
