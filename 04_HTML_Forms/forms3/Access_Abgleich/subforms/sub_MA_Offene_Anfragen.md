# sub_MA_Offene_Anfragen

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_Offene_Anfragen |
| **HTML-Datei** | sub_MA_Offene_Anfragen.html |
| **Logic-Datei** | logic/sub_MA_Offene_Anfragen.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_MA_Offene_Anfragen | sub_MA_Offene_Anfragen | - | - |

## Datenquelle (Access)

Basierend auf FRM_sub_MA_Offene_Anfragen.json:

- **RecordSource**: qry_MA_Offene_Anfragen
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderByOn**: Ja
- **OrderBy**: [qry_MA_Offene_Anfragen].[Auftrag], [qry_MA_Offene_Anfragen].[Name], [qry_MA_Offene_Anfragen].[Dat_VA_Von]
- **Filter**: ([qry_MA_Offene_Anfragen].[Name]="...")
- **AllowEdits**: Ja
- **AllowAdditions**: Ja
- **AllowDeletions**: Ja

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Position | Beschreibung |
|--------------|-----|---------------|--------|----------|--------------|
| Name | TextBox | Name | - | L:2592, T:342 | Mitarbeitername |
| Dat_VA_Von | TextBox | Dat_VA_Von | Short Date | L:2592, T:741 | Einsatzdatum |
| Auftrag | TextBox | Auftrag | - | L:2592, T:1140 | Auftragsbezeichnung |
| Ort | TextBox | Ort | @ | L:2592, T:1824 | Einsatzort |
| von | TextBox | von | Short Time | L:2592, T:2508 | Schichtbeginn |
| bis | TextBox | bis | Short Time | L:2592, T:2907 | Schichtende |
| Anfragezeitpunkt | TextBox | Anfragezeitpunkt | Short Date | L:2592, T:3306 | Wann angefragt |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Offene Anfragen</span>
        <span id="lblAnzahl">0 Eintraege</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Datum</th>
                    <th>Auftrag</th>
                    <th>Ort</th>
                    <th>Von</th>
                    <th>Bis</th>
                    <th>Angefragt</th>
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
| /api/anfragen | GET | Alle offenen Anfragen |
| /api/anfragen?status=offen | GET | Nur offene Anfragen |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | [Event Procedure] | Bei Datensatzwechsel |

## Farben (Access Long -> HEX)

| Element | Long-Wert | HEX | Beschreibung |
|---------|-----------|-----|--------------|
| ForeColor (Labels) | 8355711 | #7F7F7F | Grau |
| ForeColor (Textboxen) | 4210752 | #404040 | Dunkelgrau |
| BackColor | 16777215 | #FFFFFF | Weiss |
| BorderColor | 10921638 | #A6A6A6 | Hellgrau |

## Bemerkungen

- Zeigt alle offenen Planungsanfragen
- Sortiert nach Auftrag, Name, Datum
- Wird im Hauptformular frm_MA_Offene_Anfragen eingebettet
- Keine Link-Felder (eigenstaendige Liste)
