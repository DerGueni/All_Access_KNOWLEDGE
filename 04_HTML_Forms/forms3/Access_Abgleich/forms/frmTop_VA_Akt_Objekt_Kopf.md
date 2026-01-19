# Formular: frmTop_VA_Akt_Objekt_Kopf

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frmTop_VA_Akt_Objekt_Kopf |
| **Typ** | Popup-Formular (frmTop_) |
| **Record Source** | tbl_VA_Akt_Objekt_Kopf (Tabelle) |
| **Default View** | Other |
| **Navigation Buttons** | Nein |
| **Dividing Lines** | Nein |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |

## Beschreibung

Dieses umfangreiche Popup-Formular dient der Verwaltung von aktiven Objekt-Koepfen bei Veranstaltungen. Es ermoeglicht die Zuordnung von Objekten zu Auftraegen mit Schichtzeiten und Positionen.

## Controls

### ComboBox: VA_ID (Auftrags-Auswahl)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | VA_ID |
| **Position** | Left: 5100, Top: 1020, Width: 1995, Height: 359 |
| **Column Count** | 2 |
| **Bound Column** | 1 |
| **List Rows** | 16 |
| **Limit To List** | Ja |
| **Tab Index** | 0 |

**Row Source (SQL):**
```sql
SELECT tbl_VA_Auftragstamm.ID, tbl_VA_Auftragstamm.Auftrag,
       tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort
FROM tbl_VA_Auftragstamm;
```

**Events:**
- AfterUpdate: VBA-Prozedur (auto)

### ComboBox: Obj_ID (Objekt-Auswahl)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | OB_Objekt_Kopf_ID |
| **Position** | Left: 5100, Top: 1531, Width: 1995, Height: 359 |
| **Column Count** | 2 |
| **Bound Column** | 1 |
| **Enabled** | Nein |
| **Locked** | Ja |
| **Tab Index** | 1 |

**Row Source (SQL):**
```sql
SELECT tbl_OB_Objekt.ID, tbl_OB_Objekt.Objekt
FROM tbl_OB_Objekt;
```

### ComboBox: cboVADatum (VA-Datum Auswahl)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | VADatum_ID |
| **Position** | Left: 5100, Top: 495, Width: 1995, Height: 359 |
| **Column Count** | 2 |
| **Bound Column** | 1 |
| **Tab Index** | 2 |

**Row Source (SQL):**
```sql
SELECT tbl_VA_AnzTage.ID, Format([VADatum],"ddd/  dd/mm/yyyy",2,2) AS VADat
FROM tbl_VA_AnzTage;
```

**Events:**
- AfterUpdate: VBA-Prozedur (auto)

### ComboBox: Kombinationsfeld58 (Ort-Anzeige)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | OB_Objekt_Kopf_ID |
| **Position** | Left: 5100, Top: 2011, Width: 1995, Height: 359 |
| **Enabled** | Nein |
| **Locked** | Ja |
| **Tab Index** | 15 |

**Row Source (SQL):**
```sql
SELECT tbl_OB_Objekt.ID, tbl_OB_Objekt.Ort
FROM tbl_OB_Objekt;
```

### TextBox: ID

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | ID |
| **Position** | Left: 7256, Top: 1530, Width: 555, Height: 360 |
| **Enabled** | Nein |
| **Locked** | Ja |
| **Tab Index** | 3 |

### TextBox: VA_Start_Abs (Abs. Startzeit)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | VA_Start_Abs |
| **Position** | Left: 9465, Top: 465, Width: 1935, Height: 360 |
| **Format** | Short Time |
| **Tab Index** | 4 |

**Events:**
- OnKeyDown: VBA-Prozedur (auto)

### TextBox: VA_Ende_Abs (Abs. Endzeit)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | VA_Ende_Abs |
| **Position** | Left: 9480, Top: 1065, Width: 1935, Height: 360 |
| **Format** | Short Time |
| **Tab Index** | 5 |

**Events:**
- OnKeyDown: VBA-Prozedur (auto)

### TextBox: AnzMA_VA (Anzahl MA pro VA)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 6478, Top: 2775, Width: 645, Height: 315 |
| **Tab Index** | 6 |

### TextBox: AnzMA_Obj (Anzahl MA pro Objekt)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 12375, Top: 2760, Width: 735, Height: 315 |
| **Tab Index** | 9 |

### SubForms

#### SubForm: sub_VA_Start (Schichten)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 3765, Top: 3285, Width: 3380, Height: 7335 |
| **Source Object** | sub_VA_Start |
| **Link Master Fields** | VA_ID, cboVADatum |
| **Link Child Fields** | VA_ID, VADatum_ID |
| **Tab Index** | 7 |

#### SubForm: sub_VA_Akt_Objekt_Pos (Positionen)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 8435, Top: 3247, Width: 13619, Height: 7364 |
| **Source Object** | sub_VA_Akt_Objekt_Pos |
| **Link Master Fields** | ID |
| **Link Child Fields** | VA_Akt_Objekt_Kopf_ID |
| **Tab Index** | 8 |

#### SubForm: Menu (Seitenmenue)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 0, Top: 0, Width: 2790, Height: 10755 |
| **Source Object** | frm_Menuefuehrung |
| **Tab Index** | 14 |

### CommandButtons

| Name | Position (L, T) | Groesse (W x H) | BackColor | Funktion |
|------|-----------------|-----------------|-----------|----------|
| btn_VA_Objekt_Akt_Teil2 | 8490, 2205 | 2115 x 397 | 14136213 | Teil 2 |
| btnAbsTime | 10941, 2211 | 2115 x 397 | 14136213 | Absperrzeit |
| btn_OB_Bearb | 18311, 113 | 2621 x 601 | 14136213 | Objekt bearbeiten |
| btn_VA_Akt_OB_Pos_Neu | 18311, 953 | 2621 x 601 | 14136213 | Neue Position |
| mcobtnDelete | 18413, 358 | 2271 x 366 | 15918812 | Loeschen |
| Befehl46 | 18413, 808 | 2271 x 366 | 15918812 | Aktion |
| btnHilfe | 7558, 343 | 336 x 306 | 16777215 | Hilfe |
| Befehl42-53 | diverse | 336 x 306 | 16777215 | Navigation |
| btnRibbonAus/Ein | 1078, 388/718 | 283 x 223 | 16777215 | Ribbon toggle |
| btnDaBaAus/Ein | 793/1363, 553 | 283 x 223 | 16777215 | Datenbank toggle |

## Formular-Events

| Event | Typ |
|-------|-----|
| OnLoad | VBA-Prozedur (auto) |
| OnCurrent | VBA-Prozedur (auto) |

## Farben

| Element | Farbe (Dezimal) | HEX | Beschreibung |
|---------|-----------------|-----|--------------|
| Standard Button | 14136213 | #D7B5D5 | Rosa/Violett |
| Delete/Action Button | 15918812 | #F2EAEC | Helles Rosa |
| Standard BackColor | 16777215 | #FFFFFF | Weiss |
| BorderColor | 10921638 | #A6A6A6 | Grau |
| TextBox ForeColor | 4210752 | #404040 | Dunkelgrau |
| Info Label BackColor | 10484479 | #9FE0FF | Hellblau |

## Datenstruktur / Tabellen

- `tbl_VA_Akt_Objekt_Kopf` - Haupttabelle (Record Source)
- `tbl_VA_Auftragstamm` - Auftragsdaten
- `tbl_VA_AnzTage` - Einsatztage
- `tbl_OB_Objekt` - Objektdaten

## Verwendungszweck

1. Auftrag (VA_ID) auswaehlen
2. Datum (cboVADatum) waehlen
3. Objekt wird automatisch gesetzt
4. Absperrzeit Start/Ende eingeben
5. Schichten in sub_VA_Start verwalten
6. Positionen in sub_VA_Akt_Objekt_Pos definieren
7. MA-Anzahl pro VA und Objekt festlegen
