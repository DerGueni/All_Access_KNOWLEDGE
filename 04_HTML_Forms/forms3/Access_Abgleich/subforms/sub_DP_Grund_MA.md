# sub_DP_Grund_MA

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_DP_Grund_MA |
| **HTML-Datei** | sub_DP_Grund_MA.html |
| **Logic-Datei** | logic/sub_DP_Grund_MA.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_DP_Dienstplan_MA | sub_DP_Grund | (sub_DP_Grund_MA) | - | - |

## Datenquelle (Access)

- **RecordSource**: qry_DP_Grund_MA
- **DefaultView**: Endlosformular (ContinuousForms)
- **OrderBy**: Datum

## Felder / Controls (Access)

Basierend auf FRM_sub_DP_Grund_MA.json:

| Control-Name | Typ | ControlSource | Sichtbar | Beschreibung |
|--------------|-----|---------------|----------|--------------|
| MA_ID | TextBox | MA_ID | Nein | Mitarbeiter-ID (versteckt) |
| Datum | TextBox | Datum | Ja | Datum |
| Tag1_Name | TextBox | Tag1_Name | Ja | Tagesname (Mo, Di, etc.) |
| Grund | TextBox | Grund | Ja | Abwesenheitsgrund |
| Bemerkung | TextBox | Bemerkung | Ja | Zusatzbemerkung |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">MA Dienstplan-Gruende</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>...</thead>
            <tbody></tbody>
        </table>
    </div>
</div>
```

## Unterschied zu sub_DP_Grund

- Speziell fuer MA-Ansicht im Dienstplan
- Enthaelt MA_ID zur Filterung
- Zeigt Tagesname zusaetzlich an

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/dienstplan/gruende | GET | Mit ?ma_id=X filtern |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |

## Bemerkungen

- Variante von sub_DP_Grund fuer Mitarbeiter-spezifische Ansicht
- Wird im Dienstplan-MA-Formular verwendet
