# sub_rch_Pos

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_rch_Pos (sub_Rch_Pos_Auftrag, sub_tbl_Rch_Pos_Auftrag) |
| **HTML-Datei** | sub_rch_Pos.html |
| **Logic-Datei** | logic/sub_rch_Pos.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_tbl_Rch_Pos_Auftrag | ID | VA_ID |
| frm_Rechnung | sub_rch_Pos | Rechnungs_ID | Rechnungs_ID |

## Datenquelle (Access)

- **RecordSource**: tbl_Rch_Pos oder qry_Rch_Pos_Auftrag
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderBy**: PosNr

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| Rechnungs_ID | TextBox | Rechnungs_ID | - | Rechnungs-ID |
| VA_ID | TextBox | VA_ID | - | Auftrags-ID |
| PosNr | TextBox | PosNr | - | Positionsnummer |
| Bezeichnung | TextBox | Bezeichnung | - | Positionsbezeichnung |
| Menge | TextBox | Menge | Fixed | Menge |
| Einheit | TextBox | Einheit | - | Mengeneinheit |
| Einzelpreis | TextBox | Einzelpreis | Currency | Preis pro Einheit |
| Gesamtpreis | TextBox | Gesamtpreis | Currency | Menge * Einzelpreis |
| MwSt_Satz | TextBox | MwSt_Satz | Percent | Mehrwertsteuersatz |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Rechnungspositionen</span>
        <button id="btnNeu">Neu</button>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Pos</th>
                    <th>Bezeichnung</th>
                    <th>Menge</th>
                    <th>Einheit</th>
                    <th>Einzelpreis</th>
                    <th>Gesamt</th>
                    <th>MwSt</th>
                </tr>
            </thead>
            <tbody></tbody>
            <tfoot>
                <tr>
                    <td colspan="5">Summe:</td>
                    <td id="tdSumme">0.00</td>
                    <td></td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>
```

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/rechnungen/:id/positionen | GET | Positionen laden |
| /api/rechnungen/:id/positionen | POST | Position anlegen |
| /api/rechnungen/:id/positionen/:pos_id | PUT | Position aendern |
| /api/rechnungen/:id/positionen/:pos_id | DELETE | Position loeschen |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| AfterUpdate | BerechneGesamtpreis | Neuberechnung |

## Bemerkungen

- Zeigt Rechnungspositionen
- Kann ueber VA_ID oder Rechnungs_ID verknuepft werden
- Automatische Gesamtpreisberechnung
- Summenbildung im Footer
