# sub_MA_Jahresuebersicht

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_Jahresuebersicht |
| **HTML-Datei** | sub_MA_Jahresuebersicht.html |
| **Logic-Datei** | logic/sub_MA_Jahresuebersicht.logic.js |
| **Typ** | Unterformular (Einzelformular oder Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_MA_Mitarbeiterstamm | sub_MA_Jahresuebersicht | ID | MA_ID |
| frm_MA_Zeitkonten | sub_MA_Jahresuebersicht | ID | MA_ID |

## Datenquelle (Access)

- **RecordSource**: qry_MA_Jahresuebersicht
- **DefaultView**: Einzelformular oder Endlosformular
- **Filter**: Aktuelles Jahr

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Sichtbar | Beschreibung |
|--------------|-----|---------------|----------|--------------|
| MA_ID | TextBox | MA_ID | Nein | Mitarbeiter-ID |
| Jahr | TextBox | Jahr | Ja | Jahr |
| Monat | TextBox | Monat | Ja | Monat (1-12) |
| Soll_Stunden | TextBox | Soll_Stunden | Ja | Soll-Stunden |
| Ist_Stunden | TextBox | Ist_Stunden | Ja | Ist-Stunden |
| Differenz | TextBox | (berechnet) | Ja | Differenz Soll/Ist |
| Urlaub_Tage | TextBox | Urlaub_Tage | Ja | Urlaubstage |
| Krank_Tage | TextBox | Krank_Tage | Ja | Krankheitstage |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Jahresuebersicht</span>
        <select id="cboJahr">...</select>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Monat</th>
                    <th>Soll</th>
                    <th>Ist</th>
                    <th>Diff</th>
                    <th>Urlaub</th>
                    <th>Krank</th>
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
| /api/zeitkonten/jahresuebersicht/:ma_id | GET | Jahresuebersicht laden |
| /api/zeitkonten/jahresuebersicht/:ma_id?jahr=YYYY | GET | Mit Jahrfilter |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |

## Bemerkungen

- Zeigt monatliche Stundenauswertung fuer ein Jahr
- Inklusive Urlaubs- und Krankheitstage
- Jahresauswahl via Dropdown
