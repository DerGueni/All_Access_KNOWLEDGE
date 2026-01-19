# sub_DP_Grund

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_DP_Grund |
| **HTML-Datei** | sub_DP_Grund.html |
| **Logic-Datei** | logic/sub_DP_Grund.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_DP_Dienstplan_Objekt | sub_DP_Grund | - | - |
| frm_DP_Dienstplan_Objekt1 | sub_DP_Grund | - | - |
| frm_DP_Dienstplan_MA | sub_DP_Grund | - | - (verwendet sub_DP_Grund_MA) |

## Datenquelle (Access)

- **RecordSource**: qry_DP_Grund oder tbl_DP_Gruende
- **DefaultView**: Endlosformular (ContinuousForms)
- **OrderBy**: Datum

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Sichtbar | Beschreibung |
|--------------|-----|---------------|----------|--------------|
| Datum | TextBox | Datum | Ja | Datum des Grundes |
| Grund | TextBox | Grund | Ja | Art des Grundes (Urlaub, Krank, etc.) |
| Beschreibung | TextBox | Beschreibung | Ja | Detailbeschreibung |
| Von | TextBox | Von | Ja | Startzeit |
| Bis | TextBox | Bis | Ja | Endzeit |
| Erfasst_am | TextBox | Erfasst_am | Ja | Erfassungsdatum |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Dienstplan-Gruende</span>
        <span id="lblAnzahl">0 Eintraege</span>
    </div>
    <div class="subform-content">
        <table class="datasheet" id="tblGrund">
            <thead>...</thead>
            <tbody id="tbody_Gruende"></tbody>
        </table>
    </div>
</div>
```

## CSS-Klassen (HTML)

| Klasse | Beschreibung |
|--------|--------------|
| .subform-container | Hauptcontainer |
| .subform-header | Kopfzeile mit Titel |
| .subform-content | Scrollbarer Inhaltsbereich |
| .datasheet | Tabellenformat |
| .grund-urlaub | Badge fuer Urlaub (gruen) |
| .grund-krank | Badge fuer Krank (rot) |
| .grund-frei | Badge fuer Frei (gelb) |
| .grund-schulung | Badge fuer Schulung (blau) |
| .grund-sonstiges | Badge fuer Sonstiges (grau) |

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/dienstplan/gruende | GET | Alle Gruende laden |
| /api/dienstplan/gruende/:id | GET | Einzelnen Grund laden |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | (auto) | Bei Datensatzwechsel |

## Bemerkungen

- Zeigt Abwesenheitsgruende fuer Mitarbeiter im Dienstplan an
- Farbcodierung je nach Grund-Typ
- Wird in Dienstplan-Objekt und Dienstplan-MA verwendet
