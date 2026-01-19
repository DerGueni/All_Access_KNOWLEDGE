# Formular: frmTop_KD_Adressart

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frmTop_KD_Adressart |
| **Typ** | Popup-Formular (frmTop_) |
| **Record Source** | tbl_KD_Adressart (Tabelle) |
| **Default View** | Other |
| **Navigation Buttons** | Ja |
| **Dividing Lines** | Nein |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |

## Beschreibung

Dieses Popup-Formular dient der Verwaltung von Kunden-Adressarten. Es ermoeglicht das Anlegen, Bearbeiten und Loeschen von Adressart-Eintraegen fuer die Kundenverwaltung.

## Controls

### TextBox: ID

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | ID |
| **Position** | Left: 1830, Top: 345, Width: 6165, Height: 360 |
| **Enabled** | Nein |
| **Locked** | Ja |
| **Tab Index** | 0 |
| **ForeColor** | 4210752 (#404040) |
| **BackColor** | 16777215 (#FFFFFF) |
| **BorderColor** | 10921638 (#A6A6A6) |

### TextBox: Beschreibung (kun_AdressArt)

| Eigenschaft | Wert |
|-------------|------|
| **Control Source** | kun_AdressArt |
| **Position** | Left: 1830, Top: 885, Width: 6165, Height: 585 |
| **Enabled** | Ja |
| **Locked** | Nein |
| **Tab Index** | 1 |
| **ForeColor** | 4210752 (#404040) |
| **BackColor** | 16777215 (#FFFFFF) |
| **BorderColor** | 10921638 (#A6A6A6) |

### Image: Auto_Logo0

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 300, Top: 60, Width: 690, Height: 460 |
| **BackColor** | 16777215 (#FFFFFF) |
| **Border Style** | 0 (keine) |

### Label: Auto_Kopfzeile0 (Titel)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 1050, Top: 60, Width: 3435, Height: 460 |
| **ForeColor** | -2147483616 (Systemfarbe) |
| **Border Style** | 0 (keine) |

### Rectangle: Rechteck37 (Button-Leiste Hintergrund)

| Eigenschaft | Wert |
|-------------|------|
| **Position** | Left: 340, Top: 623, Width: 7637, Height: 678 |
| **BackColor** | -2147483607 (Systemfarbe) |
| **BorderColor** | 0 (#000000) |

## CommandButtons (Symbolleiste)

| Name | Position (Left, Top) | Groesse (W x H) | Tab Index | Funktion |
|------|----------------------|-----------------|-----------|----------|
| btnHilfe | 384, 679 | 576 x 576 | 9 | Hilfe anzeigen |
| Befehl42 | 1015, 683 | 576 x 576 | 4 | Navigation/Aktion |
| Befehl43 | 1630, 683 | 576 x 576 | 5 | Navigation/Aktion |
| Befehl41 | 2260, 683 | 576 x 576 | 3 | Navigation/Aktion |
| Befehl40 | 2875, 683 | 576 x 576 | 2 | Navigation/Aktion |
| Befehl39 | 3505, 683 | 576 x 576 | 1 | Navigation/Aktion |
| Befehl46 | 4135, 683 | 576 x 576 | 8 | Navigation/Aktion |
| Befehl44 | 4750, 683 | 576 x 576 | 6 | Navigation/Aktion |
| Befehl45 | 5365, 683 | 576 x 576 | 7 | Navigation/Aktion |
| mcobtnDelete | 6009, 680 | 576 x 576 | 10 | Datensatz loeschen |
| Befehl12 | 6633, 679 | 576 x 576 | 11 | Speichern/Aktualisieren |
| Befehl11 | 7313, 679 | 576 x 576 | 0 | Schliessen |

**Alle Buttons haben:**
- OnClick: Eingebettetes Makro
- BackColor: 16777215 (#FFFFFF)
- BorderColor: 0 (#000000)
- ForeColor: -2147483630 (Systemfarbe)

**Ausnahme mcobtnDelete:**
- BackColor: 14136213 (#D7B5D5)
- ForeColor: 4210752 (#404040)

### Labels

| Name | Position | Beschreibung |
|------|----------|--------------|
| Bezeichnungsfeld0 | Left: 345, Top: 345 | Label fuer ID |
| Bezeichnungsfeld3 | Left: 345, Top: 885 | Label fuer Beschreibung |

## Farben

| Element | Farbe (Dezimal) | HEX | Beschreibung |
|---------|-----------------|-----|--------------|
| Button Standard BackColor | 16777215 | #FFFFFF | Weiss |
| Delete Button BackColor | 14136213 | #D7B5D5 | Rosa/Violett |
| TextBox ForeColor | 4210752 | #404040 | Dunkelgrau |
| TextBox BorderColor | 10921638 | #A6A6A6 | Mittelgrau |
| Label ForeColor | 8355711 | #7F7F7F | Grau |
| Save Button ForeColor | 11954733 | #B67D2D | Orange/Braun |

## Datenstruktur

### Tabelle: tbl_KD_Adressart

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| ID | AutoWert | Primaerschluessel |
| kun_AdressArt | Text | Bezeichnung der Adressart |

## Verwendungszweck

1. Verwaltet Adressarten fuer Kunden (z.B. Hauptadresse, Lieferadresse, Rechnungsadresse)
2. Standard-Dateneingabeformular mit Navigation und CRUD-Operationen
3. Wird aus der Kundenverwaltung heraus aufgerufen
