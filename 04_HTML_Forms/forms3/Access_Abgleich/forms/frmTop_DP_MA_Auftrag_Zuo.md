# Formular: frmTop_DP_MA_Auftrag_Zuo

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frmTop_DP_MA_Auftrag_Zuo |
| **Typ** | Popup-Formular (frmTop_) |
| **Record Source** | Keine (ungebunden) |
| **Default View** | Other |
| **Navigation Buttons** | Nein |
| **Dividing Lines** | Nein |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |

## Beschreibung

Dieses Popup-Formular dient der Zuordnung von Mitarbeitern zu Auftraegen im Dienstplan. Es zeigt offene Auftraege mit verfuegbaren Schichten an und ermoeglicht die Zuweisung eines ausgewaehlten Mitarbeiters.

## Controls

### ListBox: ListeAuft (Auftragsliste)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 75, Top: 660, Width: 3940, Height: 2094 |
| **Column Count** | 6 |
| **Bound Column** | 1 |
| **Column Widths** | 0;0;1077;2160;289;458 |
| **Tab Index** | 0 |
| **Enabled** | Ja |
| **Visible** | Ja |

**Row Source (SQL):**
```sql
SELECT tbl_VA_AnzTage.VA_ID, tbl_VA_AnzTage.ID AS VADatum_ID, tbl_VA_AnzTage.VADatum AS Datum,
       fObjektOrt(Nz([Auftrag]),Nz([tbl_VA_Auftragstamm].[Ort]),Nz([Objekt])) AS ObjOrt,
       tbl_VA_AnzTage.TVA_Ist AS Ist, tbl_VA_AnzTage.TVA_Soll AS Soll
FROM tbl_VA_Auftragstamm INNER JOIN tbl_VA_AnzTage ON tbl_VA_Auftragstamm.ID = tbl_VA_AnzTage.VA_ID
WHERE (((tbl_VA_AnzTage.VADatum)= #2016-01-01#) AND tbl_VA_AnzTage.TVA_Offen = True AND tbl_VA_AnzTage.TVA_Soll > 0);
```

**Events:**
- OnClick: VBA-Prozedur (auto)

### ListBox: LstSchicht (Schichtenliste)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 4129, Top: 660, Width: 1343, Height: 2094 |
| **Column Count** | 4 |
| **Bound Column** | 1 |
| **Column Widths** | 0;0 |
| **Tab Index** | 2 |

**Row Source (SQL):**
```sql
SELECT tbl_VA_Start.ID AS VAStart_ID, tbl_VA_Start.VADatum_ID, Format([VA_Start],'Short Time') AS von,
       Format([VA_Ende],'Short Time') AS bis
FROM tbl_VA_Start
WHERE (((tbl_VA_Start.VADatum_ID)=135173) And ((tbl_VA_Start.VA_ID)=570)
       And ((tbl_VA_Start.MA_Anzahl)>0) And ((tbl_VA_Start.MA_Anzahl_Ist)<[MA_Anzahl]))
ORDER BY tbl_VA_Start.VA_Start;
```

### ComboBox: cboMA_ID (Mitarbeiter-Auswahl)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 1155, Top: 60, Width: 2850, Height: 255 |
| **Column Count** | 2 |
| **Bound Column** | 1 |
| **List Rows** | 16 |
| **Limit To List** | Ja |
| **Enabled** | Nein |
| **Locked** | Ja |
| **Tab Index** | 1 |

**Row Source (SQL):**
```sql
SELECT tbl_MA_Mitarbeiterstamm.ID, [Nachname] & " " & [Vorname] AS MAName
FROM tbl_MA_Mitarbeiterstamm;
```

### TextBox: dtPlanDatum (Planungsdatum)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 2535, Top: 360, Width: 1470, Height: 255 |
| **Visible** | Nein (versteckt) |
| **Tab Index** | 3 |

### TextBox: MAemail (Mitarbeiter-Email)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 1314, Top: 1247, Width: 2088, Height: 315 |
| **Visible** | Nein (versteckt) |
| **Enabled** | Nein |
| **Locked** | Ja |
| **Tab Index** | 5 |

### CommandButton: btn_Auswahl_Zuo (Zuordnung-Button)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 4080, Top: 375, Width: 1392, Height: 256 |
| **BackColor** | 14136213 (#D7B5D5) |
| **Tab Index** | 4 |

**Events:**
- OnClick: VBA-Prozedur (auto)

### CommandButton: Befehl38 (Schliessen-Button)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 4080, Top: 60, Width: 1392, Height: 256 |
| **BackColor** | 14136213 (#D7B5D5) |
| **Tab Index** | 6 |

**Events:**
- OnClick: Eingebettetes Makro

### Labels

| Name | Position | Sichtbar |
|------|----------|----------|
| Bezeichnungsfeld11 | Left: 75, Top: 360 | Ja |
| Bezeichnungsfeld1 | Left: 4530, Top: 345 | Nein |
| Bezeichnungsfeld7 | Left: 4260, Top: 60 | Nein |
| Bezeichnungsfeld3 | Left: 75, Top: 60 | Ja |
| Bezeichnungsfeld23 | Left: 0, Top: 1247 | Nein |

## Farben

| Element | Farbe (Dezimal) | HEX |
|---------|-----------------|-----|
| Button BackColor | 14136213 | #D7B5D5 |
| Label ForeColor | 16777215 | #FFFFFF (weiss) |
| ListBox BackColor | 16777215 | #FFFFFF |
| ListBox BorderColor | 10921638 | #A6A6A6 |
| TextBox ForeColor | 4210752 | #404040 |

## Verwendungszweck

1. Mitarbeiter wird per cboMA_ID ausgewaehlt (gesperrt, von aussen gesetzt)
2. Offene Auftraege werden in ListeAuft angezeigt
3. Bei Auswahl eines Auftrags werden verfuegbare Schichten in LstSchicht geladen
4. Button btn_Auswahl_Zuo ordnet den MA der gewaehlten Schicht zu

## Tabellen/Abfragen

- `tbl_VA_Auftragstamm` - Auftragsstammdaten
- `tbl_VA_AnzTage` - Einsatztage pro Auftrag
- `tbl_VA_Start` - Schichtdaten
- `tbl_MA_Mitarbeiterstamm` - Mitarbeiterdaten
