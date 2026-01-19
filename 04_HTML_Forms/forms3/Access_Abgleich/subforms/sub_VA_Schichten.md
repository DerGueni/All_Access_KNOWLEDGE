# sub_VA_Schichten

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_VA_Start |
| **HTML-Datei** | sub_VA_Schichten.html |
| **Logic-Datei** | logic/sub_VA_Schichten.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_VA_Start | ID, cboVADatum | VA_ID, VADatum_ID |

## Datenquelle (Access)

Basierend auf Export (sub_VA_Start.txt):

- **RecordSource**: SELECT tbl_VA_Start.* FROM tbl_VA_Start ORDER BY tbl_VA_Start.[VA_ID], tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende;
- **DefaultView**: ContinuousForms (Endlosformular)
- **OrderByOn**: Ja
- **OrderBy**: [sub_VA_Start].[VA_Start]
- **RecordLocks**: 2
- **Width**: 11700
- **RowHeight**: 285

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Format | Beschreibung |
|--------------|-----|---------------|--------|--------------|
| ID | TextBox | ID | - | Schicht-ID |
| VA_ID | TextBox | VA_ID | - | Auftrags-ID |
| VADatum_ID | TextBox | VADatum_ID | - | Einsatztag-ID |
| VA_Start | TextBox | VA_Start | Short Time | Schichtbeginn |
| VA_Ende | TextBox | VA_Ende | Short Time | Schichtende |
| MA_Anzahl | TextBox | MA_Anzahl | - | Soll-Anzahl MA |
| MA_Anzahl_Ist | TextBox | MA_Anzahl_Ist | - | Ist-Anzahl MA |
| Bemerkung | TextBox | Bemerkung | - | Schichtbemerkung |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Schichten</span>
    </div>
    <div class="schichten-list" id="schichtenList">
        <!-- Schicht items werden via JS generiert -->
    </div>
</div>
```

## CSS-Klassen (HTML)

| Klasse | Beschreibung |
|--------|--------------|
| .subform-container | Hauptcontainer mit #9090c0 Hintergrund |
| .schichten-list | Scrollbare Liste |
| .schicht-item | Einzelne Schicht |
| .schicht-item.active | Ausgewaehlte Schicht |
| .schicht-header | Kopf mit Zeit und Anzahl |
| .schicht-zeit | Zeitanzeige (fett, 12px) |
| .schicht-anzahl | Anzahl-Badge |
| .schicht-anzahl.complete | Vollstaendig besetzt (gruen) |
| .schicht-anzahl.incomplete | Nicht vollstaendig (rot) |

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/dienstplan/schichten | GET | Alle Schichten |
| /api/dienstplan/schichten?va_id=X&datum_id=Y | GET | Fuer Auftrag/Tag |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| OnCurrent | [Event Procedure] | Bei Datensatzwechsel |
| BeforeUpdate | [Event Procedure] | Validierung |

## postMessage-Kommunikation

Sendet an Parent:
```javascript
window.parent.postMessage({
    type: 'SHIFT_SELECTED',
    schicht_id: 123,
    va_start: '08:00',
    va_ende: '16:00'
}, '*');
```

## Bemerkungen

- Access-Name: sub_VA_Start, HTML-Name: sub_VA_Schichten
- Zeigt Schichten fuer einen Einsatztag
- Auswahl aktualisiert MA-Zuordnungen
- Farbcodierung: Gruen = vollstaendig, Rot = unterbesetzt
- Sortiert nach Schichtbeginn
