# sub_VA_Einsatztage

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_VA_Einsatztage (basierend auf tbl_VA_AnzTage) |
| **HTML-Datei** | sub_VA_Einsatztage.html |
| **Logic-Datei** | logic/sub_VA_Einsatztage.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_VA_Einsatztage | ID | VA_ID |
| frm_Einsatzuebersicht | sub_VA_Einsatztage | ID | VA_ID |

## Datenquelle (Access)

- **RecordSource**: tbl_VA_AnzTage oder qry_VA_Einsatztage
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderBy**: VADatum

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| ID | TextBox | ID | - | Einsatztag-ID |
| VA_ID | TextBox | VA_ID | - | Auftrags-ID |
| VADatum | TextBox | VADatum | Short Date | Einsatzdatum |
| Wochentag | TextBox | (berechnet) | - | Mo, Di, Mi, etc. |
| Anzahl_Soll | TextBox | Anzahl_Soll | - | Geplante MA-Anzahl |
| Anzahl_Ist | TextBox | Anzahl_Ist | - | Tatsaechliche MA-Anzahl |
| Status | TextBox | Status | - | Vollstaendig/Offen |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Einsatztage</span>
    </div>
    <div class="days-list" id="daysList">
        <!-- Day items werden via JS generiert -->
    </div>
</div>
```

## CSS-Klassen (HTML)

| Klasse | Beschreibung |
|--------|--------------|
| .subform-container | Hauptcontainer mit #9090c0 Hintergrund |
| .days-list | Scrollbare Liste |
| .day-item | Einzelner Tag |
| .day-item.active | Ausgewaehlter Tag |
| .day-date | Datumsanzeige (fett) |
| .day-weekday | Wochentag (klein, grau) |
| .day-status | Besetzungsstatus |
| .day-status.incomplete | Nicht vollstaendig besetzt (rot) |

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/einsatztage | GET | Alle Einsatztage |
| /api/einsatztage?va_id=X | GET | Fuer Auftrag |
| /api/auftraege/:id/tage | GET | Alternativ |

## Events (Access/HTML)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnClick | SelectDay | Tag auswaehlen |
| OnDblClick | OpenTag | Tag-Details oeffnen |

## postMessage-Kommunikation

Sendet an Parent:
```javascript
window.parent.postMessage({
    type: 'DAY_SELECTED',
    datum_id: 123,
    datum: '2026-01-15'
}, '*');
```

## Bemerkungen

- Zeigt alle Einsatztage eines Auftrags
- Auswahl eines Tages aktualisiert andere Subforms (Schichten, Zuordnungen)
- Farbcodierung fuer Besetzungsstatus
- Verknuepft ueber VA_ID
