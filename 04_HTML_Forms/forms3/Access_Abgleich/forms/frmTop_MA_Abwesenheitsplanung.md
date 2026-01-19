# Formular: frmTop_MA_Abwesenheitsplanung

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frmTop_MA_Abwesenheitsplanung |
| **Typ** | Popup-Formular (frmTop_) |
| **Record Source** | Keine (ungebunden) |
| **Default View** | Other |
| **Navigation Buttons** | Nein |
| **Dividing Lines** | Nein |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |

## Beschreibung

Dieses umfangreiche Popup-Formular dient der Planung und Verwaltung von Mitarbeiter-Abwesenheiten. Es ermoeglicht das Erfassen von Urlaub, Krankheit und anderen Fehlzeiten mit Zeitraum- und Zeitangaben.

## Controls

### ComboBox: cbo_MA_ID (Mitarbeiter-Auswahl)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 4657, Top: 340, Width: 4683, Height: 315 |
| **Column Count** | 2 |
| **Bound Column** | 1 |
| **List Rows** | 16 |
| **Limit To List** | Ja |
| **Column Widths** | 0;4536 |
| **Tab Index** | 0 |
| **ForeColor** | 4138256 |
| **BackColor** | 16777215 |
| **BorderColor** | 10921638 |

**Row Source (SQL):**
```sql
SELECT tbl_MA_Mitarbeiterstamm.ID, ([nachname] & " " & [Vorname]) AS Name
FROM tbl_MA_Mitarbeiterstamm
WHERE (((tbl_MA_Mitarbeiterstamm.istsubunternehmer)=False)
       AND ((tbl_MA_Mitarbeiterstamm.istaktiv)=True)
       AND ((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=3))
       OR (((tbl_MA_Mitarbeiterstamm.Anstellungsart_ID)=5))
ORDER BY ([nachname] & " " & [Vorname]);
```

**Events:**
- AfterUpdate: VBA-Prozedur (auto)

### ComboBox: cboAbwGrund (Abwesenheitsgrund)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 5147, Top: 1247, Width: 3993, Height: 315 |
| **Column Count** | 2 |
| **Bound Column** | 1 |
| **Default Value** | "Job" |
| **Column Widths** | 0;3402 |
| **Tab Index** | 3 |

**Row Source (SQL):**
```sql
SELECT [tbl_MA_Zeittyp].Kuerzel_Datev, [tbl_MA_Zeittyp].Zeittyp
FROM tbl_MA_Zeittyp
WHERE ((([tbl_MA_Zeittyp].ID)>4))
ORDER BY [tbl_MA_Zeittyp].SortNr;
```

### OptionGroup: AbwesenArt (Abwesenheitsart)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 3571, Top: 1079, Width: 5780, Height: 4074 |
| **Default Value** | 2 |
| **Tab Index** | 2 |
| **BorderColor** | 10921638 |
| **BorderWidth** | 2 |

**Optionen:**
- Option10 (Position: 3744, 3061) - "Ganztaegig"
- Option12 (Position: 3744, 3566) - "Teilzeit"

**Events:**
- AfterUpdate: VBA-Prozedur (auto)

### Datum-Felder

#### TextBox: DatVon (Datum von)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 5119, Top: 2505, Width: 1645, Height: 315 |
| **Format** | Short Date |
| **Tab Index** | 6 |
| **BorderColor** | 0 (schwarz) |

**Events:**
- OnDblClick: VBA-Prozedur (auto) - vermutlich Kalender-Popup

#### TextBox: DatBis (Datum bis)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 7487, Top: 2505, Width: 1645, Height: 315 |
| **Format** | Short Date |
| **Tab Index** | 7 |
| **BorderColor** | 0 (schwarz) |

**Events:**
- OnDblClick: VBA-Prozedur (auto)

### Zeit-Felder (fuer Teilzeit-Abwesenheit)

#### TextBox: TlZeitVon (Zeit von)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 5119, Top: 3915, Width: 1645, Height: 315 |
| **Format** | Short Time |
| **Enabled** | Nein (standardmaessig deaktiviert) |
| **Tab Index** | 8 |

#### TextBox: TlZeitBis (Zeit bis)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 7487, Top: 3915, Width: 1645, Height: 315 |
| **Format** | Short Time |
| **Enabled** | Nein (standardmaessig deaktiviert) |
| **Tab Index** | 9 |

### TextBox: Bemerkung

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 5119, Top: 1703, Width: 4013, Height: 315 |
| **Tab Index** | 4 |
| **BorderColor** | 10921638 |

### CheckBox: NurWerktags

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 3911, Top: 2183, Width: 260, Height: 240 |
| **Default Value** | True |
| **Tab Index** | 5 |

### ListBox: lsttmp_Fehlzeiten (Fehlzeiten-Liste)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 9802, Top: 1062, Width: 6078, Height: 8173 |
| **Row Source** | tbltmp_Fehlzeiten (Temp-Tabelle) |
| **Column Count** | 6 |
| **Bound Column** | 1 |
| **Tab Index** | 1 |

### CommandButtons

| Name | Position (L, T) | Groesse (W x H) | Funktion |
|------|-----------------|-----------------|----------|
| btnAbwBerechnen | 6810, 5250 | 2483 x 453 | Abwesenheit berechnen |
| btnMarkLoesch | 6810, 6270 | 2483 x 453 | Markierte loeschen |
| btnAllLoesch | 6810, 6825 | 2483 x 453 | Alle loeschen |
| bznUebernehmen | 6810, 8130 | 2483 x 453 | Uebernehmen (BackColor: 15849926 - gruen) |
| Befehl38 | 8818, 368 | 411 x 381 | Schliessen |
| btnHilfe | 8293, 383 | 411 x 381 | Hilfe |
| btnRibbonAus | 1078, 113 | 283 x 223 | Ribbon ausblenden |
| btnRibbonEin | 1078, 443 | 283 x 223 | Ribbon einblenden |
| btnDaBaEin | 1363, 278 | 283 x 223 | Datenbank einblenden |
| btnDaBaAus | 793, 278 | 283 x 223 | Datenbank ausblenden |

### SubForm: Menu (Seitenmenue)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 75, Top: 0, Width: 2790, Height: 10755 |
| **Source Object** | frm_Menuefuehrung |
| **Tab Index** | 14 |

## Formular-Events

| Event | Typ |
|-------|-----|
| OnOpen | VBA-Prozedur (auto) |
| OnLoad | VBA-Prozedur (auto) |

## Farben

| Element | Farbe (Dezimal) | HEX | Beschreibung |
|---------|-----------------|-----|--------------|
| Standard BackColor | 16777215 | #FFFFFF | Weiss |
| Standard BorderColor | 10921638 | #A6A6A6 | Grau |
| Uebernehmen Button | 15849926 | #F1BC46 | Gelb/Gold |
| Standard ForeColor | 0 | #000000 | Schwarz |
| TextBox ForeColor | 4210752 | #404040 | Dunkelgrau |

## Datenstruktur / Tabellen

- `tbl_MA_Mitarbeiterstamm` - Mitarbeiterdaten
- `tbl_MA_Zeittyp` - Abwesenheitsgruende (Urlaub, Krank, etc.)
- `tbltmp_Fehlzeiten` - Temporaere Tabelle fuer Fehlzeiten-Berechnung

## Verwendungszweck

1. Mitarbeiter auswaehlen
2. Abwesenheitsgrund waehlen (aus tbl_MA_Zeittyp)
3. Zeitraum (Datum von/bis) eingeben
4. Optional: Bei Teilzeit die Uhrzeiten eingeben
5. "Abwesenheit berechnen" - erstellt Eintraege in Temp-Tabelle
6. Eintraege pruefen/loeschen in der Liste
7. "Uebernehmen" - speichert endgueltig
