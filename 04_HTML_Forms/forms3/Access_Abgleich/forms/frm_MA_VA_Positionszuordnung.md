# frm_MA_VA_Positionszuordnung

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_VA_Positionszuordnung |
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
| **OnLoad** | Procedure | (auto) |
| **OnCurrent** | Procedure | (auto) |

---

## Controls nach Typ

### CommandButtons (22)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | BackColor | OnClick |
|------|----------|----------------|---------------|-----------|---------|
| btnAuftrag | 0 | 16668, 396 | 2070 x 360 | 15918812 | Procedure |
| Befehl48 | 1 | 9843, 615 | 516 x 381 | 16777215 | Macro |
| Befehl39 | 2 | 9245, 615 | 516 x 381 | 16777215 | Macro |
| Befehl40 | 3 | 8647, 615 | 516 x 381 | 16777215 | Macro |
| Befehl41 | 4 | 8049, 615 | 516 x 381 | 16777215 | Macro |
| Befehl42 | 5 | 6853, 615 | 516 x 381 | 16777215 | Macro |
| Befehl43 | 6 | 7451, 615 | 516 x 381 | 16777215 | Macro |
| Befehl49 | 7 | 14400, 861 | 2070 x 360 | 15918812 | Macro |
| btnHilfe | 8 | 6255, 615 | 516 x 381 | 16777215 | Macro |
| mcobtnDelete | 9 | 14400, 396 | 2070 x 360 | 15918812 | Macro |
| btnPosList_PDF | 10 | 18936, 861 | 2070 x 360 | 15918812 | Procedure |
| btnBack_PosKopfTl1 | 11 | 16668, 861 | 2070 x 360 | 15918812 | Procedure |
| Befehl68 | 12 | 18936, 396 | 2070 x 360 | 15918812 | (keine) |
| btnRibbonAus | 13 | 855, 480 | 283 x 223 | 16777215 | (keine) |
| btnRibbonEin | 14 | 855, 810 | 283 x 223 | 16777215 | (keine) |
| btnDaBaEin | 15 | 1140, 645 | 283 x 223 | 16777215 | (keine) |
| btnDaBaAus | 16 | 570, 645 | 283 x 223 | 16777215 | (keine) |
| btnAddAll | 0 (Detail) | 13950, 3975 | 1661 x 500 | 14136213 | Procedure |
| btnAddSelected | 1 (Detail) | 13950, 3105 | 1661 x 500 | 14136213 | Procedure |
| btnDelAll | 2 (Detail) | 13965, 7185 | 1661 x 500 | 14136213 | Procedure |
| btnDelSelected | 3 (Detail) | 13950, 6330 | 1661 x 500 | 14136213 | Procedure |
| btnRepeat | 8 (Detail) | 4740, 915 | 344 x 330 | 14136213 | Procedure |
| btnRepeatAus | 11 (Detail) | 18420, 915 | 344 x 330 | 14136213 | Procedure |

### ListBoxes (3)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | AfterUpdate |
|------|----------|----------------|---------------|-------------|
| lstMA_Zusage | 4 | 3465, 1287 | 3413 x 8046 | Procedure |
| List_Pos | 5 | 7335, 1279 | 6407 x 8046 | Procedure |
| Lst_MA_Zugeordnet | 7 | 15991, 1287 | 6961 x 8046 | (keine) |

### ComboBoxes (2)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | RowSource | AfterUpdate |
|------|----------|----------------|---------------|-----------|-------------|
| cbo_Akt_Objekt_Kopf | 9 | 8730, 225 | 5014 x 315 | qry_VA_Akt_Auftragskopf | Procedure |
| cboVADatum | 13 | 17118, 255 | 2134 x 309 | SQL (tbl_VA_AnzTage) | (keine) |

### TextBoxes (1)

| Name | TabIndex | Position (L,T) | Groesse (W,H) |
|------|----------|----------------|---------------|
| AnzAusw | 12 | 6135, 915 | 737 x 330 |

### OptionGroups (1)

| Name | TabIndex | DefaultValue | AfterUpdate |
|------|----------|--------------|-------------|
| MA_Typ | 10 | 1 | Procedure |

### OptionButtons (3)

| Name | TabIndex | Position (L,T) | OptionValue |
|------|----------|----------------|-------------|
| Option56 | 0 | 4036, 263 | (in MA_Typ) |
| Option58 | 1 | 4950, 270 | (in MA_Typ) |
| Option60 | 2 | 6045, 270 | (in MA_Typ) |

### SubForms (1)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | SourceObject |
|------|----------|----------------|---------------|--------------|
| frm_Menuefuehrung | 6 | 0, 0 | 3230 x 9354 | frm_Menuefuehrung |

### Labels (11)

| Name | Position (L,T) | Groesse (W,H) | ForeColor |
|------|----------------|---------------|-----------|
| Auto_Kopfzeile0 | 2295, 540 | 3285 x 465 | -2147483616 |
| lbl_Datum | 21147, 850 | 1513 x 397 | -2147483616 |
| Bezeichnungsfeld22 | 14295, 5865 | 1016 x 227 | 0 |
| Bezeichnungsfeld32 | 3475, 915 | 1245 x 330 | 0 |
| Bezeichnungsfeld5 | 7335, 907 | 2820 x 330 | 0 |
| Bezeichnungsfeld43 | 15990, 915 | 2415 x 330 | 0 |
| Bezeichnungsfeld1 | 7335, 225 | 1365 x 315 | 0 |
| Bezeichnungsfeld55 | 3588, 233 | 390 x 315 | 0 |
| Bezeichnungsfeld57 | 4266, 233 | 405 x 315 | 0 |
| Bezeichnungsfeld59 | 5180, 233 | 570 x 315 | 0 |
| Bezeichnungsfeld61 | 6275, 233 | 510 x 315 | 0 |
| Bezeichnungsfeld26 | 15990, 255 | 900 x 309 | 0 |

---

## Zusammenfassung

- **Zweck**: MA-VA Positionszuordnung - Mitarbeiter zu Veranstaltungspositionen zuordnen
- **Hauptfunktionen**:
  - Auftrag/Veranstaltung auswaehlen (cbo_Akt_Objekt_Kopf)
  - Datum auswaehlen (cboVADatum)
  - Mitarbeiter mit Zusage (lstMA_Zusage)
  - Verfuegbare Positionen (List_Pos)
  - Bereits zugeordnete Mitarbeiter (Lst_MA_Zugeordnet)
  - Hinzufuegen/Entfernen von Zuordnungen (btnAddSelected, btnDelSelected, etc.)
- **Sidebar**: frm_Menuefuehrung (eingebettet)
