# frm_Kundenpreise_gueni

## Formular-Metadaten

| Eigenschaft | Wert |
|-------------|------|
| **Name** | frm_Kundenpreise_gueni |
| **Datensatzquelle** | qry_Kundenpreise_gueni2 |
| **Datenquellentyp** | Query |
| **Default View** | SingleForm |
| **Allow Edits** | Ja |
| **Allow Additions** | Ja |
| **Allow Deletions** | Ja |
| **Data Entry** | Ja |
| **Navigation Buttons** | Ja |

## Controls

### Labels (Bezeichnungsfelder)

| Name | Position (L/T) | Groesse (W/H) | Sichtbar |
|------|----------------|---------------|----------|
| kun_Firma_Bezeichnungsfeld | 60 / 684 | 2394 x 300 | Ja |
| Sicherheitspersonal_Bezeichnungsfeld | 4425 / 690 | 1035 x 300 | Ja |
| Leitungspersonal_Bezeichnungsfeld | 5460 / 690 | 915 x 300 | Ja |
| Nachtzuschlag_Bezeichnungsfeld | 6375 / 690 | 915 x 300 | Ja |
| Sonntagszuschlag_Bezeichnungsfeld | 7290 / 690 | 915 x 300 | Ja |
| Feiertagszuschlag_Bezeichnungsfeld | 8205 / 690 | 915 x 300 | Ja |
| Fahrtkosten_Bezeichnungsfeld | 9120 / 690 | 1254 x 300 | Ja |
| Sonstiges_Bezeichnungsfeld | 10374 / 690 | 915 x 300 | Ja |
| Bezeichnungsfeld16 | 57 / 57 | 3768 x 519 | Ja |

### TextBoxen

| Name | Control Source | Position (L/T) | Groesse (W/H) | TabIndex | TabStop |
|------|----------------|----------------|---------------|----------|---------|
| kun_Firma | kun_Firma | 113 / 0 | 4374 x 315 | 5 | Nein |
| Sicherheitspersonal | Sicherheitspersonal | 4425 / 0 | 1035 x 315 | 0 | Ja |
| Leitungspersonal | Leitungspersonal | 5470 / 3 | 915 x 315 | 1 | Ja |
| Nachtzuschlag | Nachtzuschlag | 6395 / 0 | 915 x 315 | 2 | Ja |
| Sonntagszuschlag | Sonntagszuschlag | 7320 / 0 | 915 x 315 | 3 | Ja |
| Feiertagszuschlag | Feiertagszuschlag | 8245 / 0 | 915 x 315 | 4 | Ja |
| Fahrtkosten | Fahrtkosten | 9170 / 0 | 1254 x 315 | 6 | Nein |
| Sonstiges | Sonstiges | 10434 / 0 | 915 x 315 | 7 | Nein |

## Farben

| Element | ForeColor | BackColor | BorderColor |
|---------|-----------|-----------|-------------|
| Labels | 0 (Schwarz) | 16777215 (Weiss) | 8355711 (Grau) |
| TextBoxen | 0 (Schwarz) | 16777215 (Weiss) | 10921638 (Hellgrau) |

## Events

### Formular-Events
- OnOpen: Keine
- OnLoad: Keine
- OnClose: Keine
- OnCurrent: Keine

### TextBox-Events (OnDblClick)
- Sicherheitspersonal: Procedure Handler
- Leitungspersonal: Procedure Handler
- Nachtzuschlag: Procedure Handler
- Sonntagszuschlag: Procedure Handler
- Feiertagszuschlag: Procedure Handler
- Fahrtkosten: Procedure Handler
- Sonstiges: Procedure Handler

## Funktionalitaet

Das Formular dient zur Erfassung und Bearbeitung von Kundenpreisen mit folgenden Preiskategorien:
- Sicherheitspersonal (Stundensatz)
- Leitungspersonal (Stundensatz)
- Nachtzuschlag
- Sonntagszuschlag
- Feiertagszuschlag
- Fahrtkosten
- Sonstiges

Die Preise werden pro Kunde (kun_Firma) verwaltet.
