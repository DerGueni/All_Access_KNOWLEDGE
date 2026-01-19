# sub_MA_Dienstplan

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_Dienstplan |
| **HTML-Datei** | sub_MA_Dienstplan.html |
| **Logic-Datei** | logic/sub_MA_Dienstplan.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_MA_Mitarbeiterstamm | sub_MA_Dienstplan | ID | MA_ID |
| frm_MA_Adressen | sub_MA_Dienstplan | ID | MA_ID |

## Datenquelle (Access)

- **RecordSource**: qry_MA_Dienstplan oder tbl_MA_VA_Planung
- **DefaultView**: Endlosformular (ContinuousForms)
- **OrderBy**: VADatum DESC

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Sichtbar | Beschreibung |
|--------------|-----|---------------|----------|--------------|
| MA_ID | TextBox | MA_ID | Nein | Mitarbeiter-ID |
| VADatum | TextBox | VADatum | Ja | Einsatzdatum |
| Auftrag | TextBox | Auftrag | Ja | Auftragsbezeichnung |
| Objekt | TextBox | Objekt | Ja | Einsatzort |
| VA_Start | TextBox | VA_Start | Ja | Schichtbeginn |
| VA_Ende | TextBox | VA_Ende | Ja | Schichtende |
| Status | TextBox | Status_ID | Ja | Planungsstatus |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Dienstplan</span>
        <span id="lblAnzahl">0 Eintraege</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Datum</th>
                    <th>Auftrag</th>
                    <th>Objekt</th>
                    <th>Von</th>
                    <th>Bis</th>
                    <th>Status</th>
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
| /api/dienstplan/ma/:id | GET | Dienstplan fuer MA laden |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |
| OnDblClick | OpenAuftrag | Auftrag im Detail oeffnen |

## Bemerkungen

- Zeigt alle Einsaetze eines Mitarbeiters
- Eingebettet im Mitarbeiterstamm
- Doppelklick oeffnet Auftragsdetails
