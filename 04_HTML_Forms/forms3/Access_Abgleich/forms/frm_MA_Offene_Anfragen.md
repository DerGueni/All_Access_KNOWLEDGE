# frm_MA_Offene_Anfragen

## Formular-Eigenschaften

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_MA_Offene_Anfragen |
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

| Event | Typ |
|-------|-----|
| OnOpen | (keine) |
| OnLoad | (keine) |
| OnClose | (keine) |
| OnCurrent | (keine) |

---

## Controls nach Typ

### CommandButtons (1)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | BackColor | OnClick |
|------|----------|----------------|---------------|-----------|---------|
| btnAnfragen | 0 | 8670, 225 | 1950 x 615 | 14136213 | Procedure |

### TextBoxes (1)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | Visible |
|------|----------|----------------|---------------|---------|
| txSelHeightSub | 1 | 7481, 390 | 411 x 300 | Wahr |

### SubForms (1)

| Name | TabIndex | Position (L,T) | Groesse (W,H) | SourceObject |
|------|----------|----------------|---------------|--------------|
| sub_MA_Offene_Anfragen | 0 | 0, 68 | 17535 x 11910 | sub_MA_Offene_Anfragen |

### Labels (3)

| Name | Position (L,T) | Groesse (W,H) | ForeColor |
|------|----------------|---------------|-----------|
| Bezeichnungsfeld3 | 120, 225 | 3975 x 570 | 0 |
| Bezeichnungsfeld7 | 5100, 390 | 2205 x 315 | 0 |
| sub_MA_Offene_Anfragen Beschriftung | 453, 1686 | 2670 x 300 | 8355711 |

---

## Zusammenfassung

- **Zweck**: Anzeige und Verwaltung offener Mitarbeiter-Anfragen
- **Hauptfunktionen**:
  - Subformular mit offenen Anfragen (sub_MA_Offene_Anfragen)
  - Button zur Verarbeitung von Anfragen (btnAnfragen)
- **Besonderheiten**:
  - Einfaches Container-Formular
  - Hauptlogik im Subformular sub_MA_Offene_Anfragen
  - Keine eigene Datenquelle (Record Source leer)
