# Access-Formulare Analyse - Zusammenfassung

**Datum:** 2026-01-15 21:25:47
**Datenbank:** 0_Consys_FE_Test.accdb

## Statistik

- **Gesamt Formulare:** 261
- **Erfolgreich analysiert:** 213 (81,6%)
- **Fehler:** 48 (18,4%)
- **JSON-Datei Größe:** 1,6 MB

## Extrahierte Daten pro Formular

Für jedes erfolgreich analysierte Formular wurden folgende Informationen erfasst:

### 1. Formular-Properties
- RecordSource (Datenquelle)
- DefaultView (Ansicht: Formular/Kontinuierlich/Datenblatt)
- AllowEdits, AllowAdditions, AllowDeletions (Berechtigungen)

### 2. Controls
Alle Steuerelemente mit:
- **Name** - Control-Name
- **ControlType** - Numerischer Typ
- **ControlTypeName** - Lesbare Bezeichnung (Label, CommandButton, TextBox, ComboBox, ListBox, CheckBox, Subform, etc.)
- **ControlSource** - Datenfeld-Bindung
- **Caption** - Beschriftung (bei Buttons/Labels)
- **RowSource** - Datenquelle (bei ComboBox/ListBox)
- **ValidationRule** - Validierungsregel
- **ValidationText** - Fehlermeldung bei Validierung
- **LimitToList** - Nur Listenwerte erlaubt (bei ComboBox)
- **Required** - Pflichtfeld
- **TabIndex** - Tab-Reihenfolge
- **OnClick** - Click-Event (bei Buttons)

### 3. Validierungen
Separate Liste aller Controls mit Validierungsregeln:
- Control-Name
- ValidationRule
- ValidationText

### 4. Tab-Order
Sortierte Liste der Tab-Indizes für Navigation.

### 5. VBA Events (teilweise)
**Hinweis:** Viele VBA-Events konnten nicht vollständig extrahiert werden (VBE-Zugriffsfehler).
Erkannte Event-Typen:
- Form_Load
- Form_Current
- Form_BeforeUpdate / Form_AfterUpdate
- Control_Click
- Control_AfterUpdate / Control_BeforeUpdate
- Control_Change
- Control_GotFocus / Control_LostFocus

## Control-Typen Mapping

| ControlType | Bezeichnung | Beschreibung |
|-------------|-------------|--------------|
| 100 | Label | Beschriftung |
| 104 | CommandButton | Button/Schaltfläche |
| 109 | TextBox | Textfeld |
| 110 | ListBox | Listenfeld |
| 111 | ComboBox | Kombinationsfeld/Dropdown |
| 106 | CheckBox | Kontrollkästchen |
| 112 | Subform | Unterformular |
| 105 | OptionButton | Optionsfeld |
| 122 | TabControl | Register-Steuerelement |

## Fehleranalyse

### Fehlertypen:

**1. OpenForm abgebrochen (16 Formulare)**
- Formulare die sich nicht im Design-Modus öffnen lassen
- Beispiele: Datensatzlöschungen, _Beispiel Frm mit Buttonleiste, sub_ZuAbsage

**2. RPC-Server nicht verfügbar (32 Formulare)**
- Zeitkonto/Lohn-Formulare (zfrm_*, zsub_*)
- Trat ab Formular 230 auf (möglicherweise Access-Instanz instabil)
- Betroffene: zfrm_Lohnabrechnungen, zfrm_MA_Stunden_Lexware, zsub_MA_ZK_Daten, etc.

**3. VBA Module Zugriffsfehler (häufig)**
- "Index außerhalb des gültigen Bereichs" beim Zugriff auf VBE
- VBA-Events wurden deshalb nur teilweise erfasst
- Betrifft fast alle Formulare mit HasModule=True

## Verwendung der Daten

Die JSON-Datei kann verwendet werden für:

1. **Formular-Vergleich Access vs. HTML**
   - Abgleich welche Controls in HTML fehlen
   - Validierungen übernehmen
   - Tab-Order nachbilden

2. **Automatische HTML-Generierung**
   - Controls aus JSON auslesen
   - HTML-Controls entsprechend erstellen
   - Properties übernehmen

3. **Dokumentation**
   - Formular-Struktur dokumentieren
   - Control-Inventar erstellen

4. **Migration-Planung**
   - Priorisierung welche Formulare migriert werden
   - Komplexität abschätzen (Anzahl Controls, Events, Validierungen)

## Beispiel-Struktur (frm_va_Auftragstamm)

```json
{
  "name": "frm_va_Auftragstamm",
  "controls": [
    {
      "Name": "btnSave",
      "ControlType": 104,
      "ControlTypeName": "CommandButton",
      "Caption": "Speichern",
      "TabIndex": 5,
      "OnClick": "[Event Procedure]"
    },
    {
      "Name": "txtAuftrag",
      "ControlType": 109,
      "ControlTypeName": "TextBox",
      "ControlSource": "Auftrag",
      "Required": true,
      "TabIndex": 1
    }
  ],
  "validations": [
    {
      "Control": "txtDatum",
      "Rule": ">=Date()",
      "Text": "Datum muss in der Zukunft liegen"
    }
  ],
  "tab_order": [
    {"TabIndex": 0, "Control": "cboKunde"},
    {"TabIndex": 1, "Control": "txtAuftrag"},
    {"TabIndex": 2, "Control": "txtObjekt"}
  ],
  "events": {
    "Form_Load": true,
    "Form_Current": true,
    "_Click": []
  },
  "properties": {
    "RecordSource": "tbl_VA_Auftragstamm",
    "DefaultView": 0,
    "AllowEdits": true,
    "AllowAdditions": true,
    "AllowDeletions": false
  }
}
```

## Nächste Schritte

1. **VBA-Events nacherfassen**
   - Separate Analyse der VBA-Module ohne VBE-Zugriff
   - Direkte Code-Analyse aus .bas Exporten

2. **Fehlgeschlagene Formulare**
   - Manuell prüfen warum OpenForm fehlschlägt
   - Alternative Analysemethode für zfrm_* Formulare

3. **Control-Properties erweitern**
   - Weitere Properties erfassen (Enabled, Visible, Locked)
   - Position/Größe (Left, Top, Width, Height)
   - Farben (BackColor, ForeColor)

4. **Subform-Verknüpfungen**
   - LinkChildFields / LinkMasterFields erfassen
   - Beziehungen zwischen Haupt- und Unterformularen dokumentieren

## Datei-Pfad

**JSON-Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\_reports\ACCESS_FORMULARE_ANALYSE_2026-01-15.json`

---
**Erstellt von:** Agent B (Access-Formulare Analyse)
**Dauer:** ca. 14 Minuten
