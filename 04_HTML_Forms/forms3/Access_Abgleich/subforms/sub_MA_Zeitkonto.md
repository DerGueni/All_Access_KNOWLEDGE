# sub_MA_Zeitkonto

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_Zeitkonto (sub_tbl_MA_Zeitkonto_Aktmon1/2) |
| **HTML-Datei** | sub_MA_Zeitkonto.html |
| **Logic-Datei** | logic/sub_MA_Zeitkonto.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_MA_Zeitkonten | sub_MA_Zeitkonto | ID | MA_ID |
| frm_MA_Mitarbeiterstamm | sub_MA_Zeitkonto | ID | MA_ID |

## Datenquelle (Access)

- **RecordSource**: tbl_MA_Zeitkonto oder qry_MA_Zeitkonto
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderBy**: Monat DESC

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| MA_ID | TextBox | MA_ID | - | Mitarbeiter-ID |
| Monat | TextBox | Monat | - | Monat (1-12) |
| Jahr | TextBox | Jahr | - | Jahr |
| Soll_Std | TextBox | Soll_Std | Fixed | Soll-Stunden |
| Ist_Std | TextBox | Ist_Std | Fixed | Ist-Stunden |
| Saldo | TextBox | Saldo | Fixed | Stundensaldo |
| Urlaub_Saldo | TextBox | Urlaub_Saldo | Fixed | Urlaubssaldo |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Zeitkonto</span>
        <span id="lblSaldo">Saldo: 0.00 Std</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Monat</th>
                    <th>Jahr</th>
                    <th>Soll</th>
                    <th>Ist</th>
                    <th>Saldo</th>
                    <th>Urlaub</th>
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
| /api/zeitkonten/:ma_id | GET | Zeitkonto laden |
| /api/zeitkonten/importfehler | GET | Importfehler |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |

## Bemerkungen

- Zeigt Stunden-/Urlaubssaldo pro Monat
- Verknuepft mit MA_ID
- Kann mehrere Zeitkonto-Varianten geben (Aktmon1, Aktmon2)
