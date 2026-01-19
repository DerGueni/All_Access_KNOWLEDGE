# sub_OB_Objekt_Positionen

## Uebersicht

| Eigenschaft | Wert |
|-------------|------|
| **Access-Formular** | sub_OB_Objekt_Positionen |
| **HTML-Datei** | sub_OB_Objekt_Positionen.html |
| **Logic-Datei** | logic/sub_OB_Objekt_Positionen.logic.js |
| **Typ** | Unterformular (Endlosformular) |

## Einbettung in Hauptformulare

| Hauptformular | Control-Name | LinkMasterFields | LinkChildFields |
|---------------|--------------|------------------|-----------------|
| frm_OB_Objekt | sub_OB_Objekt_Positionen | ID | OB_Objekt_Kopf_ID |

## Datenquelle (Access)

Basierend auf FRM_sub_OB_Objekt_Positionen.json:

- **RecordSource**: SELECT tbl_OB_Objekt_Positionen.* FROM tbl_OB_Objekt_Positionen ORDER BY tbl_OB_Objekt_Positionen.Sort;
- **DefaultView**: ContinuousForms (Endlosformular)
- **AllowEdits**: Ja
- **AllowAdditions**: Ja
- **AllowDeletions**: Ja
- **NavigationButtons**: Nein
- **DividingLines**: Nein

## Felder / Controls (Access)

| Control-Name | Typ | ControlSource | Position | Beschreibung |
|--------------|-----|---------------|----------|--------------|
| ID | TextBox | ID | L:2370, T:345 | Positions-ID |
| PosLst_ID | TextBox | OB_Objekt_Kopf_ID | L:2370, T:885 | Objekt-Kopf-ID |
| Gruppe | TextBox | Gruppe | L:2370, T:1425 | Positionsgruppe |
| Zusatztext | TextBox | Zusatztext | L:2370, T:1965 | Zusatztext 1 |
| Zusatztext2 | TextBox | Zusatztext2 | L:2370, T:2505 | Zusatztext 2 |
| Geschlecht | ComboBox | Geschlecht | L:2370, T:3045 | Geschlecht (m/w/d) |
| Anzahl | TextBox | Anzahl | L:2370, T:3585 | Anzahl Mitarbeiter |
| Rel_Beginn | TextBox | Rel_Beginn | L:2370, T:4125 | Relativer Beginn |
| Rel_Ende | TextBox | Rel_Ende | L:2370, T:4665 | Relatives Ende |
| TagesArt | TextBox | TagesArt | L:2370, T:5205 | Tagesart |
| TagesNr | TextBox | TagesNr | L:2370, T:5745 | Tagesnummer |
| Sort | TextBox | Sort | L:1695, T:6225 | Sortierung |

## ComboBox-Details (Geschlecht)

- **RowSource**: SELECT tbl_Hlp_MA_Geschlecht.ID, tbl_Hlp_MA_Geschlecht.Geschlecht FROM tbl_Hlp_MA_Geschlecht;
- **ColumnCount**: 2
- **BoundColumn**: 1
- **ColumnWidths**: 0 (erste Spalte versteckt)

## HTML-Struktur

```html
<div class="subform-container">
    <div class="subform-header">
        <span class="subform-title">Positionen</span>
        <button id="btnNeu">Neu</button>
    </div>
    <div class="subform-content">
        <table class="datasheet">
            <thead>
                <tr>
                    <th>Nr</th>
                    <th>Gruppe</th>
                    <th>Zusatz</th>
                    <th>Geschl.</th>
                    <th>Anzahl</th>
                    <th>Von</th>
                    <th>Bis</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
```

## Farben (Access Long -> HEX)

| Element | Long-Wert | HEX | Beschreibung |
|---------|-----------|-----|--------------|
| ForeColor (Textboxen) | 4210752 | #404040 | Dunkelgrau |
| ForeColor (Labels) | 0 | #000000 | Schwarz |
| ForeColor (Labels grau) | 8355711 | #7F7F7F | Grau |
| BackColor | 16777215 | #FFFFFF | Weiss |
| BorderColor | 10921638 | #A6A6A6 | Hellgrau |

## API-Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| /api/objekte/:id/positionen | GET | Positionen laden |
| /api/objekte/:id/positionen | POST | Position anlegen |
| /api/objekte/:id/positionen/:pos_id | PUT | Position aendern |
| /api/objekte/:id/positionen/:pos_id | DELETE | Position loeschen |

## Events (Access)

| Event | Handler | Beschreibung |
|-------|---------|--------------|
| (keine Events definiert) | - | - |

## Bemerkungen

- Definiert Positionen/Stellenbeschreibungen fuer ein Objekt
- Eingebettet im Objekt-Formular
- Verknuepft ueber OB_Objekt_Kopf_ID
- Sortierung ueber Sort-Feld
- Rel_Beginn/Rel_Ende fuer zeitliche Verschiebungen
