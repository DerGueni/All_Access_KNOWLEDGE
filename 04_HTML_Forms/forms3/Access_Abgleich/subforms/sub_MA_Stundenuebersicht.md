# sub_MA_Stundenuebersicht

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_Stundenuebersicht |
| **HTML-Datei** | sub_MA_Stundenuebersicht.html |
| **Logic-Datei** | logic/sub_MA_Stundenuebersicht.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_MA_Mitarbeiterstamm | sub_MA_Stundenuebersicht | ID | MA_ID |
| frm_Stundenuebersicht | sub_MA_Stundenuebersicht | ID | MA_ID |

## Datenquelle (Access)

- **RecordSource**: qry_MA_Stundenuebersicht
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderBy**: Datum DESC

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| MA_ID | TextBox | MA_ID | - | Mitarbeiter-ID (versteckt) |
| Datum | TextBox | Datum | Short Date | Einsatzdatum |
| Auftrag | TextBox | Auftrag | - | Auftragsbezeichnung |
| Stunden_Soll | TextBox | Stunden_Soll | Fixed | Soll-Stunden |
| Stunden_Ist | TextBox | Stunden_Ist | Fixed | Ist-Stunden |
| Differenz | TextBox | (berechnet) | Fixed | Differenz |
| Pausenzeit | TextBox | Pausenzeit | Short Time | Pausendauer |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Stundenuebersicht</span>
        <span id="lblSumme">Gesamt: 0.00 Std</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Datum</th>
                    <th>Auftrag</th>
                    <th>Soll</th>
                    <th>Ist</th>
                    <th>Diff</th>
                    <th>Pause</th>
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
| /api/zeitkonten/stunden/:ma_id | GET | Stundenuebersicht laden |
| /api/lohn/stunden-export | GET | Export fuer Lohnabrechnung |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |

## Bemerkungen

- Zeigt Arbeitsstunden pro Tag/Einsatz
- Vergleich Soll/Ist-Stunden
- Summenbildung in Kopfzeile
