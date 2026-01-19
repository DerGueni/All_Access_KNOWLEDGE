# frm_Ausweis_Create

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Ausweis_Create |
| **Datensatzquelle** | Keine (ungebunden) |
| **Datenquellentyp** | None |
| **Default View** | Other |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Nein |
| **Navigation Buttons** | Nein |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | Beschreibung |
|------|----------------|---------------|--------------|
| Auto_Kopfzeile0 | 1755 / 165 | 3060 x 465 | Formular-Titel |
| lbl_Datum | 20466 / 453 | 1290 x 300 | Datum-Anzeige |
| Bezeichnungsfeld24 | 3401 / 9 | 2445 x 315 | Label MA Liste |
| Bezeichnungsfeld32 | 14286 / 1530 | 2565 x 240 | Label Ausweis-Liste |
| Bezeichnungsfeld1 | 12167 / 1590 | 1185 x 345 | Gueltig bis Label |
| lbl_Kartendruck | 14730 / 5730 | 2550 x 330 | Kartendruck Label |
| Bezeichnungsfeld16 | 21713 / 5603 | 3687 x 394 | Ausweis-Typen |

### CommandButtons

| Name | Position (L/T) | Groesse (W/H) | Sichtbar | OnClick |
|------|----------------|---------------|----------|---------|
| Befehl38 | 21316 / 0 | 351 x 336 | Ja | Makro (Schliessen) |
| btnHilfe | 20749 / 0 | 336 x 351 | Ja | Makro (Hilfe) |
| btnRibbonAus | 568 / 56 | 283 x 223 | Ja | - |
| btnRibbonEin | 568 / 386 | 283 x 223 | Ja | - |
| btnDaBaEin | 853 / 221 | 283 x 223 | Ja | - |
| btnDaBaAus | 283 / 221 | 283 x 223 | Ja | - |
| btnAddAll | 11680 / 12188 | 1361 x 290 | Nein | Procedure |
| btnAddSelected | 11790 / 2834 | 1931 x 600 | Ja | Procedure |
| btnDelAll | 11679 / 12869 | 1361 x 290 | Nein | Procedure |
| btnDelSelected | 11790 / 3628 | 1931 x 600 | Ja | Procedure |
| btnAusweisReport | 21883 / 4592 | 3360 x 450 | Nein | Procedure |
| btnDeselect | 11680 / 12529 | 1361 x 290 | Nein | Procedure |
| btnDienstauswNr | 15422 / 566 | 1989 x 727 | Nein | Procedure |
| Befehl7 | 0 / 0 | 2730 x 690 | Ja | - |
| Befehl8 | 0 / 0 | 2730 x 690 | Ja | - |
| btn_ausweiseinsatzleitung | 21883 / 6407 | 3360 x 390 | Ja | Procedure |
| btn_ausweisservice | 21885 / 7995 | 3360 x 390 | Ja | Procedure |
| btn_ausweisstaff | 21889 / 9196 | 3360 x 390 | Ja | Procedure |
| btn_ausweisBereichsleiter | 21885 / 6930 | 3360 x 390 | Ja | Procedure |
| btn_ausweissec | 21887 / 7456 | 3360 x 390 | Ja | Procedure |
| btn_ausweisplatzanweiser | 21887 / 8573 | 3360 x 390 | Ja | Procedure |
| btn_Karte_Sicherheit | 14400 / 7995 | 3165 x 690 | Ja | Procedure |
| btn_Karte_Service | 14400 / 8895 | 3165 x 690 | Ja | Procedure |
| btn_Karte_Rueck | 14460 / 9810 | 3165 x 690 | Ja | Procedure |
| btn_Sonder | 14460 / 10770 | 3165 x 690 | Ja | Procedure |

### ListBoxen

| Name | Row Source | Position (L/T) | Groesse (W/H) | ColumnCount |
|------|------------|----------------|---------------|-------------|
| lstMA_Alle | SELECT mit Anstellungsart 3 oder 5 | 3401 / 303 | 7371 x 13021 | 7 |
| lstMA_Ausweis | SELECT aus qry_Ausweis_Selekt | 14286 / 1778 | 4536 x 2476 | 3 |

### TextBox

| Name | DefaultValue | Position (L/T) | Groesse (W/H) | Format |
|------|--------------|----------------|---------------|--------|
| GueltBis | =DateSerial(Year(Date()),12,31) | 12075 / 1987 | 1419 x 345 | dd/mm/yy |

### ComboBox

| Name | Row Source | Position (L/T) | Groesse (W/H) |
|------|------------|----------------|---------------|
| cbo_Kartendrucker | Drucker-Liste | 14445 / 7365 | 3120 x 345 |

### SubForm

| Name | Source Object | Position (L/T) | Groesse (W/H) |
|------|---------------|----------------|---------------|
| frm_Menuefuehrung | frm_Menuefuehrung | 0 / 0 | 3125 x 13369 |

## Farben

| Element | ForeColor | BackColor |
|---------|-----------|-----------|
| Standard Buttons | 4210752 | 14136213 (Gelb) |
| Ausweis-Typ Buttons (Security) | 0 | 14347005 (Orange) |
| Ausweis-Typ Buttons (Service) | 0 | 15788753 (Hellblau) |
| Listen | 0 | 16777215 (Weiss) |

## Events

### Formular-Events
- **OnOpen**: Procedure Handler
- **OnLoad**: Procedure Handler
- OnClose: Keine
- OnCurrent: Keine

### ListBox-Events
- lstMA_Alle.OnDblClick: Procedure
- lstMA_Alle.OnKeyDown: Procedure
- lstMA_Ausweis.OnDblClick: Procedure

### Button-Events
Alle Ausweis-Buttons (btn_ausweis*) und Karten-Buttons (btn_Karte_*) haben Procedure Handler.

## Funktionalitaet

Formular zur Erstellung von Dienstausweisen:

### Hauptfunktionen:
1. **Mitarbeiterauswahl** (lstMA_Alle): Liste aller MA mit Anstellungsart 3 oder 5
2. **Ausweisliste** (lstMA_Ausweis): Ausgewaehlte MA fuer Ausweis-Erstellung
3. **Gueltigkeitsdatum** (GueltBis): Standardmaessig bis Jahresende
4. **Kartendrucker-Auswahl**: ComboBox mit verfuegbaren Druckern

### Ausweis-Typen:
- Einsatzleitung (Orange)
- Bereichsleiter (Orange)
- Security (Orange)
- Service (Hellblau)
- Staff (Hellblau)
- Platzanweiser (Hellblau)

### Karten-Druck:
- Sicherheit (Vorderseite)
- Service (Vorderseite)
- Rueckseite
- Sonderkarten

### Navigation:
- Eingebettetes Menue (frm_Menuefuehrung)
- Ribbon-Steuerung (Ein/Aus)
- Datenbank-Navigation (Ein/Aus)
