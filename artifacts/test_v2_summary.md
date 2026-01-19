# Button Test v2 - Summary

**Test Zeit:** 2025-12-26 17:08:33

**Gesamt:** 21 Tests
- PASS: 17
- FAIL: 4
- WARNING: 0

## Ergebnisse nach Kategorie


### Navigation

:white_check_mark: **Erste Datensatz (btnFirst)** - Button sichtbar & klickbar | Console-Logs: 0
:white_check_mark: **Vorherige Datensatz (btnPrev)** - Button sichtbar & klickbar | Console-Logs: 0
:white_check_mark: **Naechste Datensatz (btnNext)** - Button sichtbar & klickbar | Console-Logs: 0
:white_check_mark: **Letzte Datensatz (btnLast)** - Button sichtbar & klickbar | Console-Logs: 0

### CRUD

:white_check_mark: **Neuer Auftrag** - Button klickbar
:white_check_mark: **Auftrag kopieren** - Button klickbar
:white_check_mark: **Auftrag loeschen** - Button klickbar

### Einsatzliste

:white_check_mark: **Einsatzliste senden BOS (btnEinsatzlisteBOS)** - Button klickbar
:white_check_mark: **Einsatzliste senden SUB (btnEinsatzlisteSUB)** - Button klickbar
:white_check_mark: **Einsatzliste senden MA (btnEinsatzlisteSenden)** - Button klickbar
:white_check_mark: **Einsatzliste drucken** - Button klickbar
:white_check_mark: **Namensliste ESS** - Button klickbar

### Mitarbeiterauswahl

:white_check_mark: **Mitarbeiterauswahl oeffnen** - Button klickbar (btnSchnellPlan)

### Tabs

:x: **Tab: Einsatzliste** - Tab nicht gefunden mit Selektoren: ['a:has-text("Einsatzliste")', '.tab-item:has-text("Einsatzliste")', '[data-tab="einsatzliste"]']
:x: **Tab: Antworten ausstehend** - Tab nicht gefunden mit Selektoren: ['a:has-text("Antworten")', '.tab-item:has-text("Antworten")', '[data-tab="antworten"]']
:x: **Tab: Zusatzdateien** - Tab nicht gefunden mit Selektoren: ['a:has-text("Zusatzdateien")', '.tab-item:has-text("Zusatzdateien")', '[data-tab="zusatzdateien"]']
:white_check_mark: **Tab: Rechnung** - Tab gefunden mit Selector: a:has-text("Rechnung")
:x: **Tab: Bemerkungen** - Tab nicht gefunden mit Selektoren: ['a:has-text("Bemerkungen")', '.tab-item:has-text("Bemerkungen")', '[data-tab="bemerkungen"]']

### Zusaetzliche Buttons

:white_check_mark: **Schliessen-Button** - Button sichtbar & enabled (btnClose)
:white_check_mark: **Datum zurueck** - Button sichtbar & enabled (btnDatumLeft)
:white_check_mark: **Datum vor** - Button sichtbar & enabled (btnDatumRight)
