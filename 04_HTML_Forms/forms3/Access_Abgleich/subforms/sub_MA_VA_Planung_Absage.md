# sub_MA_VA_Planung_Absage

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_VA_Planung_Absage |
| **HTML-Datei** | sub_MA_VA_Planung_Absage.html |
| **Logic-Datei** | logic/sub_MA_VA_Planung_Absage.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_MA_VA_Planung_Absage | ID, cboVADatum | VA_ID, VADatum_ID |

## Datenquelle (Access)

Basierend auf Export:

- **RecordSource**: qry_MA_Plan_Absage
- **DefaultView**: ContinuousForms (Endlosformular)
- **ScrollBars**: 2 (Vertikal)
- **AllowFilters**: Nein
- **AllowAdditions**: Nein

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Beschreibung |
|--------------|-----|---------------|--------------|
| VA_ID | TextBox | VA_ID | Auftrags-ID (versteckt) |
| VADatum_ID | TextBox | VADatum_ID | Einsatztag-ID (versteckt) |
| MA_ID | TextBox | MA_ID | Mitarbeiter-ID |
| Name | TextBox | Name | Mitarbeitername |
| Absagedatum | TextBox | Absagedatum | Wann abgesagt |
| Absagegrund | TextBox | Absagegrund | Warum abgesagt |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Absagen</span>
        <span id="lblAnzahl">0 Eintraege</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Absagedatum</th>
                    <th>Grund</th>
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
| /api/zuordnungen/absagen | GET | Alle Absagen |
| /api/zuordnungen/absagen?va_id=X&datum_id=Y | GET | Fuer Auftrag/Tag |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| BeforeInsert | [Event Procedure] | Vor Einfuegen |
| BeforeUpdate | [Event Procedure] | Vor Aktualisierung |

## Bemerkungen

- Zeigt abgesagte MA-Zuordnungen fuer einen Auftrag/Tag
- Verknuepft ueber VA_ID und VADatum_ID
- Eingebettet im Auftragstamm-Formular
- Nur Anzeige, keine Neuerfassung hier
