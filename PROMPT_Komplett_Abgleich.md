# KOMPLETT-ABGLEICH: HTML ↔ ACCESS PARITÄT

## AUFTRAG

Führe einen vollständigen Abgleich aller HTML-Formulare mit den Access-Originalen durch. Verwende spezialisierte Agents für maximale Gründlichkeit.

---

## PHASE 1: AUFTRAGSVERWALTUNG (frm_va_Auftragstamm)

### Agent 1A: Buttons prüfen
1. Lies `exports/vba/forms/Form_frm_va_Auftragstamm.bas`
2. Lies `exports/forms/frm_va_Auftragstamm/controls.json`
3. Für JEDEN Button im VBA-Code:
   - Hat HTML den gleichen onclick-Handler?
   - Wird die gleiche Funktion aufgerufen?
   - Ist Visible/Enabled-Logik identisch?
4. Dokumentiere Abweichungen

### Agent 1B: Unterformulare prüfen
1. Lies `exports/forms/frm_va_Auftragstamm/subforms.json`
2. Für JEDES Unterformular:
   - Ist LinkMasterFields korrekt?
   - Ist LinkChildFields korrekt?
   - Werden Daten korrekt gefiltert?
3. Prüfe: sub_MA_VA_Zuordnung, sub_VA_Schichten, sub_VA_Absagen

### Agent 1C: Filter und Listenfelder prüfen
1. Für JEDES Dropdown/Listenfeld:
   - Ist RowSource identisch?
   - Funktioniert AfterUpdate-Event?
   - Wird korrekt gefiltert?
2. Prüfe Comboboxen und deren Abhängigkeiten

### Agent 1D: Felder und Events prüfen
1. Für JEDES Eingabefeld:
   - DefaultValue korrekt?
   - Validierung vorhanden?
   - BeforeUpdate/AfterUpdate Events?
2. Dokumentiere fehlende Events

### Agent 1E: Klick/Doppelklick Events prüfen
1. Für JEDES Control in controls.json prüfen:
   - Hat es `OnClick` Event? → onclick in HTML vorhanden?
   - Hat es `OnDblClick` Event? → dblclick in HTML vorhanden?
   - Hat es `OnEnter`/`OnExit`? → focus/blur Handler?
2. Prüfe auch Listenfelder, Labels, Textfelder - NICHT nur Buttons!
3. Typische übersehene Events:
   - Listbox_DblClick → Datensatz öffnen
   - Textfeld_Click → Auswahldialog
   - Label_Click → Navigation
4. Dokumentiere ALLE fehlenden Click/DblClick Handler

---

## PHASE 2: KUNDENSTAMM (frm_VA_Kundenstamm)

### Agent 2A: Buttons prüfen
1. Lies `exports/vba/forms/Form_frm_VA_Kundenstamm.bas`
2. Lies `exports/forms/frm_VA_Kundenstamm/controls.json`
3. Gleiche alle Button-Events ab

### Agent 2B: Unterformulare und Listen prüfen
1. Lies `exports/forms/frm_VA_Kundenstamm/subforms.json`
2. Prüfe alle Unterformulare auf korrekte Verknüpfung
3. Prüfe Listenfelder auf korrekte RowSource

### Agent 2C: Felder und Relationen prüfen
1. Prüfe alle Lookup-Felder (Dropdown mit Fremdschlüssel)
2. Prüfe Adressfelder, Kontaktfelder
3. Dokumentiere fehlende Funktionen

### Agent 2D: Klick/Doppelklick Events prüfen
1. Prüfe JEDES Control auf OnClick/OnDblClick in controls.json
2. Stelle sicher dass HTML die gleichen Handler hat
3. Besonders prüfen: Listenfelder, Textfelder mit Auswahlfunktion

---

## PHASE 3: MITARBEITERSTAMM (frm_MA_Mitarbeiterstamm)

### Agent 3A: Buttons prüfen
1. Lies `exports/vba/forms/Form_frm_MA_Mitarbeiterstamm.bas`
2. Lies `exports/forms/frm_MA_Mitarbeiterstamm/controls.json`
3. Gleiche alle Button-Events ab

### Agent 3B: Unterformulare und Listen prüfen
1. Lies `exports/forms/frm_MA_Mitarbeiterstamm/subforms.json`
2. Prüfe Qualifikationen-Subform
3. Prüfe Verfügbarkeiten-Subform

### Agent 3C: Felder und Events prüfen
1. Prüfe Personalstammdaten-Felder
2. Prüfe Dropdown-Felder (Anstellungsart, Kategorie)
3. Dokumentiere fehlende Validierungen

### Agent 3D: Klick/Doppelklick Events prüfen
1. Prüfe JEDES Control auf OnClick/OnDblClick in controls.json
2. Stelle sicher dass HTML die gleichen Handler hat
3. Besonders prüfen: Qualifikations-Liste, Verfügbarkeits-Felder

---

## PHASE 4: HEADER-BEREICH STANDARDISIEREN

### Agent 4: Header in allen Formularen prüfen

Stelle sicher dass JEDES HTML-Formular folgenden Header hat:

```html
<div class="form-header" style="background-color: #e0e0e0; padding: 10px; margin-bottom: 10px;">
    <span id="headerTitle" style="font-size: 14px; color: #000000; font-weight: bold;">
        [Auftragstitel / Formular-Titel]
    </span>
</div>
```

**Prüfe in:**
- frm_va_Auftragstamm.html ✓ (Vorlage)
- frm_VA_Kundenstamm.html
- frm_MA_Mitarbeiterstamm.html
- frm_MA_VA_Schnellauswahl.html
- Alle weiteren Formulare in forms3/

**Header-Anforderungen:**
- Hintergrund: grau (#e0e0e0)
- Schriftgröße: 14px
- Schriftfarbe: schwarz (#000000)
- Enthält dynamischen Titel (Auftragsnummer, Kundenname, MA-Name)

---

## AUSGABE-FORMAT

Nach JEDER Phase dokumentiere:

```
## [Formular] - Abgleich-Ergebnis

### ✅ Korrekt implementiert:
- [Button/Control]: [Funktion] ✓

### ⚠️ Abweichungen gefunden:
- [Button/Control]: Access=[X], HTML=[Y] → KORRIGIERT/OFFEN

### ❌ Fehlend:
- [Button/Control]: [Was fehlt]

### Änderungen durchgeführt:
- [Datei]: [Was geändert wurde]
```

---

## REGELN

1. **VBA-Code ist die Wahrheit** - HTML muss sich anpassen
2. **Teste nach jeder Änderung** im Browser
3. **Geschützte Bereiche nicht ändern** - siehe CLAUDE.md
4. **Dokumentiere alles** was du findest und änderst
5. **Bei Unklarheiten** - Benutzer fragen, nicht raten

---

## START

Beginne mit Phase 1, Agent 1A (Auftragsverwaltung Buttons).
Melde nach jedem Agent den Status bevor du zum nächsten gehst.
