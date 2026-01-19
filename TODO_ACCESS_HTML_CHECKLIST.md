# TODO: Access → HTML Parity Checklist

## Ziel
Jedes HTML-Formular soll optisch, strukturell und funktional 1:1 dem jeweiligen Access-Original entsprechen (Farben, Schriftgrößen, Buttons, Tabs, Subforms, Daten). Diese Liste dient als intelligenter Prüf-/Korrekturrahmen: wir laufen Formular für Formular, Bereich für Bereich durch und korrigieren gezielt Abweichungen.

## Vorgehensweise
1. **Screenshot-Vergleich** ▶️ `artifacts/html-screenshots/*.png` vs. `Screenshots ACCESS Formulare/*.jpg`
2. **Diff-Bilder** ▶️ `artifacts/html-screenshots/diffs/` zur schnellen Visualisierung nutzen.
3. **Korrektur** ▶️ CSS/HTML/JS anpassen (Farben, Größen, Buttons, Tabellen, Events, API-Calls).
4. **Verifizierung** ▶️ `npx playwright screenshot --full-page ...` + `python compare_screenshots.py`.

## Checkliste pro Formular

### Auftragstamm (frm_va_Auftragstamm)
- [ ] Header-Bar: Gradient `#5b3bd2 → #2a0d6e`, Höhe 110 px, Buttons exakt 133×24 px inkl. „Auftrag kopieren“, „Auftrag löschen“, „Einsatzliste senden“ (Dropdown-grau) + Checkboxen/Status.
- [ ] Toolbar: Schrift `Segoe UI` 9pt, Buttons mit rechteckiger Kontur, Abstand identisch (8 px).
- [ ] Tab-Header („Einsatzliste“, „Antworten ausstehend“, „Rechnung“): gleiche Hintergrundfarbe `#e8e8e8`, aktive Tabs komplexer Border, Schrift 11pt.
- [ ] Sidebar („HAUPTMENÜ … HTML Ansicht“): Buttons Farbe, Größe, Schrift wie Access (helle Buttons, dunkelgraue Schrift, 100% Höhe).
- [ ] Einsatzliste/Subforms: Tabellenzeilen (weiß/hellgrau streifen), Spaltenbreiten, Checkboxen (Quadrat 13 px), Scrollbar-Bereiche (Breite), Tab-Visibility.
- [ ] Buttons unterhalb Tabellen (z. B. „Rechnung PDF“, „Einsatzliste drucken“) mit Farbverlauf `#95b3d7`.
- [ ] Tabellen mit echten Daten (via API) – sicherstellen, dass Bridge-Anfragen existieren.

### Mitarbeiterstamm (frm_MA_Mitarbeiterstamm)
- [ ] Header/Buttons: gleiche Farben/Positionen wie Access, Schriftgröße 9pt.
- [ ] Tab-Steuerung, Sidebar, Filterfenster identisch, data grids mit hohen Zeilenanzahl.
- [ ] Buttons „Mitarbeiter löschen“, „Listen drucken“, „Transfer“ exakt sichtbar.

### Kundenstamm (frm_KD_Kundenstamm)
- [ ] Sidebar-Buttons (Verrechnungssätze, Sub-Rechnungen) und Tabellenanordnung.
- [ ] Kundenliste, Kontaktspalte, Filterzeilen, Checkboxes.
- [ ] Footer Informationen (Status, Datum) färben wie Access (Blau/Weiß).

### Dienstplan MA (frm_DP_Dienstplan_MA)
- [ ] Kalender/Planung: Tabellengrid, Kopfzeile, Farbverläufe (Orange/Blau).
- [ ] Buttons (Startdatum, Woche zurück/vor) mit dominanter Farbe.
- [ ] Listen (MA, Zeitraum) mit gleichen Spaltenbreiten, Fonts, Border.

### Schnellauswahl (frm_MA_VA_Schnellauswahl)
- [ ] Layout mit 5-Spalten-Grid, Buttons mit Farben (Gelb/Blau).
- [ ] Filtersystem (Aktiv, Qualifikation etc.) gleich positioniert.
- [ ] Listen für geplante MA und Zusagen mit Checkboxes.

## Dokumentation & Status
- [ ] Aktualisiere `WORKLOG.md`, `HTML_FUNCTIONALITY_STATUS.md` nach jeder korrigierten Sektion.
- [ ] Notiere verbleibende Abweichungen/Offene Punkte → gleiches Dokument.

## Review
- [ ] Nach Abschluss Sprint erneut `python compare_screenshots.py` laufen lassen und RMS → 0 anstreben.
