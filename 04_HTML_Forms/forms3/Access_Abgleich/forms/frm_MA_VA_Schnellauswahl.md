# frm_MA_VA_Schnellauswahl

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_VA_Schnellauswahl |
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
| **OnClose** | Procedure | (auto) |

---

## Controls nach Typ

### CommandButtons (18)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | BackColor | Visible | OnClick |
|------|----------|----------------|---------------|-----------|---------|---------|
| btnHilfe | 0 | 26977, 120 | 390 x 390 | 16777215 | Wahr | Macro |
| Befehl38 | 1 | 27487, 120 | 450 x 390 | 16777215 | Falsch | Macro |
| btnAuftrag | 2 | 12525, 390 | 2583 x 370 | 14136213 | Wahr | Procedure |
| btnPosListe | 3 | 18088, 390 | 2538 x 370 | 14136213 | Falsch | Procedure |
| btnZuAbsage | 4 | 21093, 390 | 2538 x 370 | 14136213 | Falsch | Procedure |
| btnRibbonAus | 5 | 855, 480 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnDaBaAus | 6 | 570, 645 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnDaBaEin | 7 | 1140, 645 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnRibbonEin | 8 | 855, 810 | 283 x 223 | 16777215 | Wahr | Procedure |
| btnAddSelected | 4 | 15300, 2894 | 1136 x 515 | 14136213 | Wahr | Procedure |
| btnDelAll | 5 | 15300, 6059 | 1136 x 515 | 14136213 | Falsch | (keine) |
| btnDelSelected | 6 | 15300, 3869 | 1136 x 515 | 14136213 | Wahr | Procedure |
| btnSchnellGo | 13 | 14559, 1530 | 567 x 299 | 14136213 | Falsch | Procedure |
| btnAddZusage | 19 | 20777, 3007 | 1196 x 515 | 14136213 | Falsch | Procedure |
| btnMoveZusage | 20 | 20747, 3839 | 1226 x 515 | 14136213 | Falsch | Procedure |
| btnDelZusage | 21 | 20837, 6069 | 1136 x 515 | 14136213 | Falsch | Procedure |
| btnSortZugeord | 22 | 20856, 1760 | 1157 x 284 | 14136213 | Falsch | Procedure |
| btnSortPLan | 23 | 19438, 1590 | 1157 x 284 | 14136213 | Falsch | Procedure |
| btnMail | 25 | 16605, 788 | 2958 x 415 | 15981949 | Wahr | Procedure |
| btnMailSelected | 26 | 16605, 165 | 2925 x 435 | 15981949 | Wahr | Procedure |

### ComboBoxes (5)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | RowSource | AfterUpdate |
|------|----------|----------------|---------------|-----------|-------------|
| VA_ID | 3 | 4260, 120 | 7324 x 369 | SQL (tbl_VA_Auftragstamm + tbl_VA_AnzTage + qry_tbl_Start_proTag) | Procedure |
| cboVADatum | 7 | 13155, 120 | 1984 x 369 | SQL (tbl_VA_AnzTage) | Procedure |
| cboAuftrStatus | 10 | 25232, 143 | 249 x 315 | SQL (tbl_VA_Status) | (keine) |
| cboAnstArt | 14 | 13144, 855 | 1997 x 285 | SQL (tbl_hlp_MA_Anstellungsart) | Procedure |
| cboQuali | 16 | 13144, 1202 | 1997 x 285 | SQL (tbl_MA_Einsatzart) | Procedure |

### ListBoxes (5)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | RowSource | OnDblClick |
|------|----------|----------------|---------------|-----------|------------|
| lstZeiten | 1 | 3150, 1872 | 2950 x 2452 | SQL (qry_Anz_MA_Start) | - |
| lstMA_Plan | 2 | 16604, 1920 | 4281 x 8246 | SQL (qry_Mitarbeiter_Geplant) | Procedure |
| List_MA | 8 | 6236, 1888 | 8902 x 8276 | ztbl_MA_Schnellauswahl | Procedure |
| lstMA_Zusage | 9 | 22238, 1920 | 4282 x 8246 | SQL (qry_Mitarbeiter_Zusage) | - |
| Lst_Parallel_Einsatz | 11 | 3118, 5326 | 2946 x 4881 | SQL (qry_VA_Einsatz) | Procedure |

### TextBoxes (4)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | Locked |
|------|----------|----------------|---------------|--------|
| iGes_MA | 0 | 4227, 1065 | 1847 x 285 | Wahr |
| strSchnellSuche | 12 | 13425, 1530 | 1096 x 284 | Falsch |
| DienstEnde | 17 | 5085, 4366 | 1007 x 285 | Wahr |

### CheckBoxes (4)

| Name | TabIndex | DefaultValue | Visible | AfterUpdate |
|------|----------|--------------|---------|-------------|
| IstVerfuegbar | 15 | True | Wahr | Procedure |
| IstAktiv | 24 | True | Wahr | Procedure |
| cbVerplantVerfuegbar | 27 | =False | Wahr | Procedure |
| cbNur34a | 28 | False | Wahr | Procedure |

### SubForms (1)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | SourceObject |
|------|----------|----------------|---------------|--------------|
| frm_Menuefuehrung | 18 | 60, 60 | 2892 x 10301 | frm_Menuefuehrung |

### Labels (16)

| Name | Position (L,T) | Groesse (W,H) | Beschreibung |
|------|----------------|---------------|--------------|
| Auto_Kopfzeile0 | 2385, 450 | 2835 x 465 | Formular-Titel |
| lbl_Datum | 25290, 120 | 1288 x 397 | Datum-Anzeige |
| lbAuftrag | 4422, 915 | 8385 x 345 | Auftrag (versteckt) |
| Bezeichnungsfeld9 | 3150, 1065 | 915 x 285 | "Gesamt" |
| Bezeichnungsfeld7 | 3180, 1530 | 2950 x 315 | "Zeiten" |
| Bezeichnungsfeld24 | 16604, 1590 | 2445 x 285 | "Geplant" |
| Bezeichnungsfeld1 | 3180, 165 | 1065 x 369 | "Auftrag" |
| Bezeichnungsfeld5 | 6236, 1530 | 4125 x 315 | "Mitarbeiter" |
| Bezeichnungsfeld32 | 22273, 1647 | 2565 x 285 | "Zusage" |
| Bezeichnungsfeld35 | 24377, 113 | 960 x 315 | "Status" (versteckt) |
| Bezeichnungsfeld37 | 3118, 4988 | 2925 x 315 | "Parallel-Einsaetze" |
| Bezeichnungsfeld269 | 11685, 1202 | 1365 x 285 | "Qualifikation" |
| Bezeichnungsfeld263 | 6360, 735 | 1125 x 285 | "Filter" |
| Bezeichnungsfeld517 | 11685, 860 | 1365 x 285 | "Anstellungsart" |
| Bezeichnungsfeld48 | 3118, 4365 | 1935 x 285 | "Dienstende" |
| lbl_NurFreie | 7864, 915 | 2625 x 285 | "Nur Verfuegbare" |
| lbl_IstAktiv | 7864, 1200 | 2580 x 285 | "Nur Aktive" |
| lbl_VerplantVerfuegbar | 7880, 630 | 2610 x 286 | "Verplant=Verfuegbar" |
| lbl_Nur34a | 11171, 1557 | 1860 x 315 | "Nur mit 34a" |
| Bezeichnungsfeld62 | 6236, 9921 | 8042 x 208 | Footer-Info |
| Bezeichnungsfeld63 | 16604, 9980 | 3962 x 223 | Footer-Info |
| Bezeichnungsfeld26 | 12135, 165 | 1005 x 369 | "Datum" |

---

## Zusammenfassung

- **Zweck**: Schnellauswahl von Mitarbeitern fuer Veranstaltungen
- **Hauptfunktionen**:
  - Auftrag/VA auswaehlen (VA_ID)
  - Datum auswaehlen (cboVADatum)
  - Schichten/Zeiten anzeigen (lstZeiten)
  - Verfuegbare Mitarbeiter filtern (List_MA)
  - Bereits geplante MA anzeigen (lstMA_Plan)
  - Zusagen anzeigen (lstMA_Zusage)
  - Parallel-Einsaetze anzeigen (Lst_Parallel_Einsatz)
  - Filter: Anstellungsart, Qualifikation, 34a, Aktiv, Verfuegbar
  - MA hinzufuegen/entfernen (btnAddSelected, btnDelSelected)
  - Serien-E-Mail senden (btnMail, btnMailSelected)
- **Sidebar**: frm_Menuefuehrung (eingebettet)
- **Besonderheiten**:
  - Umfangreiche Filteroptionen (CheckBoxes)
  - Mehrere Listen nebeneinander (MA-Pool, Geplant, Zusage)
  - Doppelklick auf Listen fuer Aktionen
  - E-Mail-Buttons fuer Massenversand
