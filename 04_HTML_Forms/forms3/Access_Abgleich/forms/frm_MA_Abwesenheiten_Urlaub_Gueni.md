# frm_MA_Abwesenheiten_Urlaub_Gueni

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_Abwesenheiten_Urlaub_Gueni |
| **Record Source** | qry_MA_Abwesenheiten_Urlaub_Gueni_KT (Query) |
| **Default View** | ContinuousForms (Endlosformular) |
| **AllowEdits** | Wahr |
| **AllowAdditions** | Wahr |
| **AllowDeletions** | Wahr |
| **DataEntry** | Falsch |
| **FilterOn** | Falsch |
| **NavigationButtons** | Wahr |
| **DividingLines** | Falsch |

---

## Formular-Events

| Event | Typ |
|-------|-----|
| OnOpen | (keine) |
| OnLoad | (keine) |
| OnClose | (keine) |
| OnCurrent | (keine) |

---

## Datengebundene Controls

### Mitarbeiter-Identifikation

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) |
|----------|-------------|----------------|---------------|
| Name | TextBox | 2595, 285 | 2100 x 315 |
| Text29 (Jahr?) | TextBox | 1372, 690 | 496 x 315 |

### Monats-Spalten (Urlaubstage pro Monat)

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) |
|----------|-------------|----------------|---------------|
| Jan | TextBox | 799, 1077 | 495 x 315 |
| Feb | TextBox | 2500, 1476 | 495 x 315 |
| Mrz | TextBox | 2500, 1875 | 495 x 315 |
| Apr | TextBox | 2500, 2274 | 495 x 315 |
| Mai | TextBox | 2500, 2673 | 495 x 315 |
| Jun | TextBox | 2500, 3072 | 495 x 315 |
| Jul | TextBox | 2500, 3471 | 495 x 315 |
| Aug | TextBox | 2500, 3870 | 495 x 315 |
| Sep | TextBox | 2500, 4269 | 495 x 315 |
| Okt | TextBox | 2500, 4668 | 495 x 315 |
| Nov | TextBox | 2500, 5067 | 495 x 315 |
| Dez | TextBox | 2500, 5466 | 495 x 315 |

### Summen

| Feldname | Control-Typ | Position (L,T) | Groesse (W,H) |
|----------|-------------|----------------|---------------|
| Gesamtsumme von Zeittyp_ID | TextBox | 2500, 5865 | 495 x 315 |

---

## Labels

| Name | Position (L,T) | Groesse (W,H) | Beschreibung |
|------|----------------|---------------|--------------|
| Bezeichnungsfeld28 | 57, 57 | 8640 x 969 | Formular-Header/Titel |
| Name_Bezeichnungsfeld | 345, 285 | 1050 x 315 | "Name" |
| Bezeichnungsfeld30 | 345, 690 | 710 x 315 | "Jahr" |
| Jan_Bezeichnungsfeld | 340, 1077 | 710 x 315 | "Jan" |
| Feb_Bezeichnungsfeld | 340, 1476 | 710 x 315 | "Feb" |
| Mrz_Bezeichnungsfeld | 340, 1875 | 710 x 315 | "Mrz" |
| Apr_Bezeichnungsfeld | 340, 2274 | 710 x 315 | "Apr" |
| Mai_Bezeichnungsfeld | 340, 2673 | 710 x 315 | "Mai" |
| Jun_Bezeichnungsfeld | 340, 3072 | 710 x 315 | "Jun" |
| Jul_Bezeichnungsfeld | 340, 3471 | 710 x 315 | "Jul" |
| Aug_Bezeichnungsfeld | 340, 3870 | 710 x 315 | "Aug" |
| Sep_Bezeichnungsfeld | 340, 4269 | 710 x 315 | "Sep" |
| Okt_Bezeichnungsfeld | 340, 4668 | 710 x 315 | "Okt" |
| Nov_Bezeichnungsfeld | 340, 5067 | 710 x 315 | "Nov" |
| Dez_Bezeichnungsfeld | 340, 5466 | 710 x 315 | "Dez" |
| Gesamtsumme von Zeittyp_ID_Bezeichnungsfeld | 340, 5865 | 710 x 315 | "Summe" |

---

## Zusammenfassung

- **Zweck**: Urlaubsuebersicht pro Mitarbeiter und Monat
- **Datenquelle**: qry_MA_Abwesenheiten_Urlaub_Gueni_KT (Kreuztabellenabfrage)
- **Darstellung**: Endlosformular mit einem Datensatz pro Mitarbeiter
- **Hauptfunktionen**:
  - Mitarbeitername anzeigen
  - Urlaubstage pro Monat (Jan-Dez)
  - Jahressumme berechnen
- **Besonderheiten**:
  - Kompaktes Layout fuer Uebersicht
  - Alle Monatsfelder in einer Spalte untereinander
  - Kreuztabellen-Query als Datenquelle
  - Navigationsbuttons aktiviert fuer Blaettern

**Hinweis**: Dies ist eine spezielle Auswertungsansicht. Die eigentliche Abwesenheitsverwaltung erfolgt ueber frm_MA_Abwesenheit oder aehnliche Formulare.
