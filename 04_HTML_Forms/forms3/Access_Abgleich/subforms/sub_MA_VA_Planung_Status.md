# sub_MA_VA_Planung_Status

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_VA_Planung_Status |
| **HTML-Datei** | sub_MA_VA_Planung_Status.html |
| **Logic-Datei** | logic/sub_MA_VA_Planung_Status.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_MA_VA_Zuordnung_Status | ID, cboVADatum | VA_ID, VADatum_ID |

Hinweis: Control heisst sub_MA_VA_Zuordnung_Status, verwendet aber sub_MA_VA_Planung_Status als SourceObject.

## Datenquelle (Access)

Basierend auf Export:

- **RecordSource**: qry_MA_Plan
- **DefaultView**: ContinuousForms (Endlosformular)
- **AllowFilters**: Nein
- **OrderByOn**: Ja
- **OrderBy**: [qry_MA_Plan].[Anfragezeitpunkt] DESC

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| VA_ID | TextBox | VA_ID | - | Auftrags-ID (versteckt) |
| VADatum_ID | TextBox | VADatum_ID | - | Einsatztag-ID (versteckt) |
| MA_ID | TextBox | MA_ID | - | Mitarbeiter-ID |
| Name | TextBox | Name | - | Mitarbeitername |
| Status_ID | TextBox | Status_ID | - | Status-Code |
| Anfragezeitpunkt | TextBox | Anfragezeitpunkt | Short Date | Wann angefragt |
| MVA_Start | TextBox | MVA_Start | Short Time | Schichtbeginn MA |
| MVA_Ende | TextBox | MVA_Ende | Short Time | Schichtende MA |
| VADatum | TextBox | VADatum | Short Date | Einsatzdatum |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Planungsstatus</span>
        <span id="lblAnzahl">0 Eintraege</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Status</th>
                    <th>Angefragt</th>
                    <th>Von</th>
                    <th>Bis</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
```

## Status-Codes

| ID | Status | Farbe |
|----|--------|-------|
| 1 | Angefragt | Gelb |
| 2 | Zugesagt | Gruen |
| 3 | Abgesagt | Rot |
| 4 | Eingeplant | Blau |

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/planungen | GET | Alle Planungen |
| /api/planungen?va_id=X&datum_id=Y | GET | Fuer Auftrag/Tag |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |

## Bemerkungen

- Zeigt Planungsstatus aller Mitarbeiter fuer Auftrag/Tag
- Farbcodierung nach Status
- Eingebettet im Auftragstamm-Formular
