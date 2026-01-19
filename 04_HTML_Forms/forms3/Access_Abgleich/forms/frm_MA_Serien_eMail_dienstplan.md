# frm_MA_Serien_eMail_dienstplan

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_Serien_eMail_dienstplan |
| **Record Source** | (keine) |
| **Default View** | Other |
| **AllowEdits** | Wahr |
| **AllowAdditions** | Wahr |
| **AllowDeletions** | Wahr |
| **DataEntry** | Falsch |
| **FilterOn** | Falsch |
| **NavigationButtons** | Falsch |
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
| btnSendEmail | 1 | 7231, 441 | 1938 x 445 | 14136213 | Wahr | Procedure |
| btnSchnellPlan | 2 | 10580, 706 | 2295 x 360 | 14136213 | Wahr | Procedure |
| btnZuAbsage | 3 | 15935, 706 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnAuftrag | 4 | 10580, 226 | 2295 x 360 | 14136213 | Wahr | Procedure |
| btnHilfe | 5 | 18425, 56 | 381 x 321 | 16777215 | Wahr | Macro |
| btnPosListeAtt | 6 | 13280, 706 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnRibbonAus | 7 | 965, 271 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnRibbonEin | 8 | 965, 601 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnDaBaEin | 9 | 1250, 436 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnDaBaAus | 10 | 680, 436 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnPDFCrea | 11 | 13280, 226 | 2295 x 360 | 14136213 | Falsch | Procedure |
| btnAttachSuch | 11 | 4185, 4620 | 345 x 315 | 16777215 | Wahr | Procedure |
| btnAttLoesch | 12 | 4648, 4592 | 1085 x 315 | 14136213 | Wahr | Procedure |

### ComboBoxes (4)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | RowSource | AfterUpdate |
|------|----------|----------------|---------------|-----------|-------------|
| VA_ID | 0 | 4470, 150 | 5929 x 315 | SQL (tbl_VA_Auftragstamm + tbl_VA_AnzTage) | Procedure |
| cboVADatum | 1 | 10575, 165 | 2089 x 315 | SQL (tbl_VA_AnzTage) | Procedure |
| Voting_Text | 8 | 12112, 1770 | 7386 x 390 | tbl_hlp_Voting | (keine) |
| cboeMail_Vorlage | 9 | 12112, 763 | 7386 x 300 | SQL (tbl_MA_Serien_eMail_Vorlage) | Procedure |
| cboSendPrio | 15 | 17910, 1305 | 1583 x 285 | 0;"Prio Nieder";1;"Prio Normal";2;"Prio Hoch" | (keine) |

### ListBoxes (2)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | RowSource | Visible |
|------|----------|----------------|---------------|-----------|---------|
| lstZeiten | 2 | 3240, 2210 | 2470 x 2070 | (keine) | Falsch |
| lstMA_Plan | 3 | 6315, 2135 | 4116 x 7470 | qry_mitarbeiter_dienstplan_email_einzel | Wahr |

### TextBoxes (5)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | Locked |
|------|----------|----------------|---------------|--------|
| Textinhalt | 4 | 10637, 2787 | 8835 x 6825 | Falsch |
| Betreffzeile | 7 | 12110, 2265 | 7359 x 390 | Falsch |
| AbsendenAls | 6 | 12095, 1275 | 5649 x 390 | Falsch |
| iGes_MA | 13 | 4762, 1247 | 887 x 345 | Wahr |

### OptionGroups (1)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstPlanAlle | 5 | 2 | Falsch | Procedure |

### OptionButtons (3)

| Name | TabIndex | Visible | Position |
|------|----------|---------|----------|
| Option9 | 0 | Falsch | In IstPlanAlle |
| Option11 | 1 | Falsch | In IstPlanAlle |
| Option13 | 2 | Falsch | In IstPlanAlle |

### CheckBoxes (1)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstAlleZeiten | 14 | True | Falsch | Procedure |

### ToggleButtons (1)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstHTML | 16 | True | Wahr | Procedure |

### SubForms (2)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | SourceObject |
|------|----------|----------------|---------------|--------------|
| sub_tbltmp_Attachfile | 10 | 3240, 4945 | 2515 x 2501 | sub_tbltmp_Attachfile |
| frm_Menuefuehrung | 17 | 0, 0 | 3005 x 9647 | frm_Menuefuehrung |

### Labels (12)

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
| Bezeichnungsfeld199 | 3270, 4605 | 1410 x 315 | -2147483630 |
| Bezeichnungsfeld9 | 3004, 1247 | 1605 x 330 | 0 |
| Bezeichnungsfeld193 | 10620, 1275 | 1395 x 390 | -2147483630 |

---

## Zusammenfassung

- **Zweck**: Serien-E-Mail fuer Dienstplaene an Mitarbeiter versenden
- **Hauptfunktionen**:
  - Auftrag auswaehlen (VA_ID)
  - Datum auswaehlen (cboVADatum)
  - E-Mail-Vorlage waehlen (cboeMail_Vorlage)
  - Mitarbeiter-Liste aus Dienstplan (lstMA_Plan mit qry_mitarbeiter_dienstplan_email_einzel)
  - E-Mail-Text bearbeiten (Textinhalt, Betreffzeile)
  - Anhaenge verwalten (sub_tbltmp_Attachfile)
  - E-Mail senden (btnSendEmail)
  - Schnellplanung oeffnen (btnSchnellPlan)
  - Auftragsstamm oeffnen (btnAuftrag)
- **Sidebar**: frm_Menuefuehrung (eingebettet)
- **Unterschied zu frm_MA_Serien_eMail_Auftrag**:
  - Fokus auf Dienstplaene statt Auftraege
  - lstMA_Plan hat spezielle Query fuer Dienstplan-Emails
  - Textinhalt ist editierbar (nicht gesperrt)
  - btnSchnellPlan ist sichtbar
