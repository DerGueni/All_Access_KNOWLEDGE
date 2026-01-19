# frm_MitarbeiterstammTabelle (frm_Mitarbeiterstamm Tabelle)

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Mitarbeiterstamm Tabelle |
| **Record Source** | tbl_ma_mitarbeiterstamm (Tabelle) |
| **Default View** | Other |
| **AllowEdits** | Wahr |
| **AllowAdditions** | Wahr |
| **AllowDeletions** | Wahr |
| **DataEntry** | Falsch |
| **FilterOn** | Falsch |
| **OrderByOn** | Wahr |
| **OrderBy** | [tbl_ma_mitarbeiterstamm].[IstAktiv], [tbl_ma_mitarbeiterstamm].[Nachname], [tbl_ma_mitarbeiterstamm].[IstSubunternehmer] DESC, [tbl_ma_mitarbeiterstamm].[HatSachkunde], [tbl_ma_mitarbeiterstamm].[Hat_keine_34a] |
| **NavigationButtons** | Falsch |
| **DividingLines** | Wahr |

---

## Datengebundene Controls (Stammdaten)

### Persoenliche Daten

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) | Format |
|----------|-------------|----------------|---------------|--------|
| LEXWare_ID | TextBox | 1190, 453 | 615 x 330 | - |
| Nachname | TextBox | 4081, 56 | 1678 x 330 | @ |
| Vorname | TextBox | 4081, 453 | 1678 x 330 | @ |
| Geschlecht | TextBox | 8264, 1247 | 1678 x 330 | @ |
| Geb_Dat | TextBox | 8264, 2041 | 1678 x 330 | - |
| Geb_Ort | TextBox | 4069, 2551 | 1678 x 330 | - |
| Staatsang | TextBox | 8264, 1644 | 1678 x 330 | - |

### Adresse

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) | Format |
|----------|-------------|----------------|---------------|--------|
| Strasse | TextBox | 4081, 850 | 1678 x 330 | @ |
| Nr | TextBox | 4081, 1247 | 1678 x 329 | - |
| PLZ | TextBox | 4081, 1644 | 1678 x 330 | @ |
| Ort | TextBox | 4081, 2041 | 1678 x 330 | @ |

### Kontakt

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) |
|----------|-------------|----------------|---------------|
| Tel_Mobil | TextBox | 8264, 56 | 1678 x 330 |
| Tel_Festnetz | TextBox | 8264, 453 | 1678 x 330 |
| Email | TextBox | 8264, 850 | 1678 x 330 |

### Beschaeftigung

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) | Format |
|----------|-------------|----------------|---------------|--------|
| Eintrittsdatum | TextBox | 16950, 2551 | 1678 x 330 | dd.mm.yyyy |
| Austrittsdatum | TextBox | 16950, 2948 | 1678 x 330 | - |
| Auszahlungsart | TextBox | 12642, 2551 | 1678 x 330 | @ |
| Bankname | TextBox | (weitere Position) | 1678 x 330 | @ |

### Status-CheckBoxen

| Feldname | Control-Typ | Position (L,T) | DefaultValue |
|----------|-------------|----------------|--------------|
| IstSubunternehmer | CheckBox | 1247, 1247 | - |

---

## Besonderheiten

### Tabellarische Darstellung
- **DividingLines** ist aktiviert fuer Tabellenansicht
- Viele Felder haben BorderColor 12566463 (grauer Rahmen)
- Format "@" bei Textfeldern erzwingt Text-Eingabe

### Sortierung
Das Formular sortiert automatisch nach:
1. IstAktiv (aktive Mitarbeiter zuerst)
2. Nachname (alphabetisch)
3. IstSubunternehmer (absteigend)
4. HatSachkunde
5. Hat_keine_34a

---

## Zusammenfassung

- **Zweck**: Tabellarische Uebersicht aller Mitarbeiter-Stammdaten
- **Datenquelle**: Direkte Bindung an tbl_ma_mitarbeiterstamm
- **Hauptfunktionen**:
  - Anzeige und Bearbeitung aller Mitarbeiter in Tabellenform
  - Persoenliche Daten (Name, Geburt, Geschlecht)
  - Adressdaten (Strasse, PLZ, Ort)
  - Kontaktdaten (Telefon, E-Mail)
  - Beschaeftigungsdaten (Eintritt, Austritt, Auszahlung)
  - Status-Flags (Subunternehmer, Sachkunde, 34a)
- **Besonderheiten**:
  - Automatische Sortierung nach Aktivitaet und Name
  - Tabellenansicht mit Trennlinien
  - Alle Felder editierbar

**Hinweis**: Dieses Formular zeigt die Tabellenansicht des Mitarbeiterstamms. Fuer die Einzelansicht siehe frm_MA_Mitarbeiterstamm.
