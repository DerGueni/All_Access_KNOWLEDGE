# CSS POSITION: RELATIVE für alle Elemente

## AUFTRAG

Stelle in ALLEN HTML-Formularen in `04_HTML_Forms\forms3\` die CSS-Position aller Elemente auf `position: relative` um.

**Grund:** Ermöglicht manuelle Anpassungen von Breite, Höhe und Position der Elemente.

---

## VORGEHEN

### Schritt 1: Alle HTML-Dateien finden
```
04_HTML_Forms\forms3\*.html
```

### Schritt 2: Für JEDE HTML-Datei

**Im `<style>`-Bereich folgende Elemente auf `position: relative` setzen:**

```css
/* Formular-Container */
.form-container,
.form-content,
.form-section,
.form-group,
.form-row {
    position: relative;
}

/* Eingabefelder */
input,
select,
textarea,
button,
.textbox,
.combobox,
.listbox,
.checkbox {
    position: relative;
}

/* Labels und Texte */
label,
.label,
.field-label,
span.label {
    position: relative;
}

/* Subforms und Container */
.subform,
.subform-container,
iframe,
.datasheet,
.datasheet-container {
    position: relative;
}

/* Buttons */
.button,
.btn,
[class*="btn"] {
    position: relative;
}

/* Tabellen */
table,
tr,
td,
th {
    position: relative;
}
```

### Schritt 3: Bestehende `position: absolute` oder `position: fixed` ersetzen

**Suche und ersetze:**
- `position: absolute` → `position: relative`
- `position: fixed` → `position: relative` (außer bei Modals/Overlays)

**AUSNAHMEN (NICHT ändern):**
- Modal-Dialoge / Overlays (brauchen absolute/fixed)
- Dropdown-Menüs (brauchen absolute für Positionierung)
- Tooltips
- Loading-Spinner

---

## BETROFFENE DATEIEN

Prüfe und ändere mindestens:
- [ ] frm_va_Auftragstamm.html
- [ ] frm_VA_Kundenstamm.html
- [ ] frm_MA_Mitarbeiterstamm.html
- [ ] frm_MA_VA_Schnellauswahl.html
- [ ] sub_MA_VA_Zuordnung.html
- [ ] sub_VA_Schichten.html
- [ ] sub_VA_Absagen.html
- [ ] shell.html
- [ ] Alle weiteren .html Dateien in forms3/

---

## AUSGABE

Nach Abschluss dokumentiere:

```
## CSS Position: Relative - Änderungen

### Geänderte Dateien:
- [Datei]: [Anzahl Elemente geändert]

### Ausnahmen belassen (absolute/fixed):
- [Datei]: [Element] - Grund: [Modal/Dropdown/etc.]

### Hinweise:
- [Eventuelle Probleme oder Besonderheiten]
```

---

## WICHTIG

1. **Funktionalität testen** nach jeder Datei
2. **Keine Layout-Zerstörung** - nur position ändern, nicht andere CSS-Eigenschaften
3. **Backup-Info:** Alte Werte als Kommentar dokumentieren falls nötig:
   ```css
   /* WAR: position: absolute; left: 100px; */
   position: relative;
   ```

---

## SPÄTERE UMSTELLUNG

Diese Änderung ist TEMPORÄR. Später wird auf Anweisung umgestellt auf:
- `position: static` (Standard-Flow)
- `position: absolute` (Pixel-genaue Platzierung)
- `position: fixed` (Fixiert am Viewport)

Bis dahin: **ALLES auf `position: relative` belassen!**
