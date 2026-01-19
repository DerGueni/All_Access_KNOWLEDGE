# sub_MA_VA_Zuordnung

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_MA_VA_Zuordnung |
| **HTML-Datei** | sub_MA_VA_Zuordnung.html |
| **Logic-Datei** | logic/sub_MA_VA_Zuordnung.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_MA_VA_Zuordnung | ID, cboVADatum | VA_ID, VADatum_ID |
| frmTop_DP_Auftrageingabe | sub_MA_VA_Zuordnung | - | - (sub_MA_VA_Zuordnung_Objekte) |

## Datenquelle (Access)

Basierend auf Export:

- **RecordSource**: tbl_MA_VA_Zuordnung (oder tbl_MA_VA_Planung)
- **DefaultView**: ContinuousForms (Endlosformular)
- **RecordLocks**: 2 (Alle Datensaetze)
- **KeyPreview**: Ja
- **AllowAdditions**: Nein
- **FrozenColumns**: 3

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Beschreibung |
|--------------|-----|---------------|--------------|
| VA_ID | TextBox | VA_ID | Auftrags-ID |
| VADatum_ID | TextBox | VADatum_ID | Einsatztag-ID |
| MA_ID | ComboBox | MA_ID | Mitarbeiter-Auswahl |
| PosNr | TextBox | PosNr | Positionsnummer |
| MVA_Start | TextBox | MVA_Start | MA Schichtbeginn |
| MVA_Ende | TextBox | MVA_Ende | MA Schichtende |
| Status_ID | ComboBox | Status_ID | Planungsstatus |
| Bemerkung | TextBox | Bemerkung | Zusatzbemerkung |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Mitarbeiter-Zuordnung</span>
        <span id="lblAnzahl">0 / 0</span>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Pos</th>
                    <th>Mitarbeiter</th>
                    <th>Von</th>
                    <th>Bis</th>
                    <th>Status</th>
                    <th>Bemerkung</th>
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
| /api/zuordnungen | GET | Alle Zuordnungen |
| /api/zuordnungen?va_id=X&datum_id=Y | GET | Fuer Auftrag/Tag |
| /api/zuordnungen | POST | Neue Zuordnung |
| /api/zuordnungen/:id | PUT | Zuordnung aendern |
| /api/zuordnungen/:id | DELETE | Zuordnung loeschen |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| BeforeUpdate | [Event Procedure] | Validierung |
| AfterUpdate | [Event Procedure] | Aktualisierung |
| OnOpen | [Event Procedure] | Initialisierung |

## Bemerkungen

- Zentrale Zuordnung von Mitarbeitern zu Auftraegen/Tagen
- Verknuepft ueber VA_ID und VADatum_ID
- FrozenColumns = 3 (erste 3 Spalten fixiert)
- Wichtigstes Unterformular im Auftragstamm
