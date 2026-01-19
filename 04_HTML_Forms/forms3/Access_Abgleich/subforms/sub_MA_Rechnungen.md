# sub_MA_Rechnungen

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_Rechnungen |
| **HTML-Datei** | sub_MA_Rechnungen.html |
| **Logic-Datei** | logic/sub_MA_Rechnungen.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_MA_Mitarbeiterstamm | sub_MA_Rechnungen | ID | MA_ID |

## Datenquelle (Access)

- **RecordSource**: qry_MA_Rechnungen oder tbl_MA_Rechnungen
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderBy**: Rechnungsdatum DESC

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| MA_ID | TextBox | MA_ID | - | Mitarbeiter-ID (versteckt) |
| Rechnungs_Nr | TextBox | Rechnungs_Nr | - | Rechnungsnummer |
| Rechnungsdatum | TextBox | Rechnungsdatum | Short Date | Datum der Rechnung |
| Betrag | TextBox | Betrag | Currency | Rechnungsbetrag |
| Status | TextBox | Status | - | Bezahlt/Offen |
| Bezahlt_am | TextBox | Bezahlt_am | Short Date | Zahlungsdatum |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Rechnungen</span>
        <span id="lblAnzahl">0 Eintraege</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Rechnungs-Nr</th>
                    <th>Datum</th>
                    <th>Betrag</th>
                    <th>Status</th>
                    <th>Bezahlt am</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
```

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/lohn/abrechnungen | GET | Alle Abrechnungen |
| /api/lohn/abrechnungen?ma_id=X | GET | Fuer bestimmten MA |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |
| OnDblClick | OpenRechnung | Rechnung oeffnen |

## Bemerkungen

- Zeigt Lohnabrechnungen/Rechnungen fuer Mitarbeiter
- Eingebettet im Mitarbeiterstamm
- Verknuepft ueber MA_ID
