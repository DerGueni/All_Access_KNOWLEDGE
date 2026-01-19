# sub_ZusatzDateien

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_ZusatzDateien |
| **HTML-Datei** | sub_ZusatzDateien.html |
| **Logic-Datei** | logic/sub_ZusatzDateien.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_va_auftragstamm | sub_ZusatzDateien | Objekt_ID, TabellenNr | Ueberordnung, TabellenID |
| frm_OB_Objekt | sub_ZusatzDateien | ID, TabellenNr | Ueberordnung, TabellenID |
| frm_KD_Kundenstamm | sub_ZusatzDateien | kun_ID, TabellenNr | Ueberordnung, TabellenID |

## Datenquelle (Access)

Basierend auf Export (sub_ZusatzDateien.txt):

- **RecordSource**: tbl_ZusatzDateien
- **DefaultView**: ContinuousForms (Endlosformular)
- **DividingLines**: Nein

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Beschreibung |
|--------------|-----|---------------|--------------|
| ID | TextBox | ID | Datei-ID |
| Ueberordnung | TextBox | Ueberordnung | Verknuepfungs-ID (Objekt, Kunde, etc.) |
| TabellenID | TextBox | TabellenID | Tabellen-Nummer (1=Objekt, 2=Kunde, etc.) |
| ZusatzNr | TextBox | ZusatzNr | Dateinummer |
| TabellenNr | TextBox | TabellenNr | Weitere Tabellen-ID |
| Dateiname | TextBox | Dateiname | Originaler Dateiname |
| DFiledate | TextBox | DFiledate | Dateidatum |
| Laenge | TextBox | Laenge | Dateigroesse |
| Texttyp | TextBox | Texttyp | Dateityp |
| Kurzbeschreibung | TextBox | Kurzbeschreibung | Beschreibung |
| JNVerteiler | TextBox | JNVerteiler | Ja/Nein Verteiler |
| Erst_von | TextBox | Erst_von | Erstellt von |
| Erst_am | TextBox | Erst_am | Erstellt am |
| Aend_von | TextBox | Aend_von | Geaendert von |
| Aend_am | TextBox | Aend_am | Geaendert am |

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Zusatzdateien</span>
        <button id="btnUpload">Hochladen</button>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Nr</th>
                    <th>Dateiname</th>
                    <th>Typ</th>
                    <th>Beschreibung</th>
                    <th>Datum</th>
                    <th>Aktion</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
```

## Link-Felder Erklaerung

Die Verknuepfung erfolgt ueber zwei Felder:
- **Ueberordnung**: ID des uebergeordneten Datensatzes (Objekt-ID, Kunden-ID, etc.)
- **TabellenID**: Nummer der Quelltabelle zur Unterscheidung

| TabellenID | Tabelle |
|------------|---------|
| 1 | Objekte |
| 2 | Kunden |
| 3 | Auftraege |
| 4 | Mitarbeiter |

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/dateien | GET | Alle Dateien |
| /api/dateien?tabelle=X&id=Y | GET | Fuer bestimmtes Objekt |
| /api/dateien | POST | Datei hochladen |
| /api/dateien/:id | DELETE | Datei loeschen |
| /api/dateien/:id/download | GET | Datei herunterladen |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| (keine Events definiert) | - | - |

## Bemerkungen

- Universelles Unterformular fuer Dateianhange
- Verwendet in Objekten, Kunden, Auftraegen
- Flexible Verknuepfung ueber Ueberordnung + TabellenID
- Unterstuetzt verschiedene Dateitypen
