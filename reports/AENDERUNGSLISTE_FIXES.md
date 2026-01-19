# ÄNDERUNGSLISTE - HTML FORMULAR FIXES

**Datum:** 2026-01-06
**Analyse:** Ultrathink Deep Analysis (3 parallele Opus-Agents)

---

## DURCHGEFÜHRTE ÄNDERUNGEN

### FIX #1: frm_va_Auftragstamm.html
**Datei:** `04_HTML_Forms\forms3\frm_va_Auftragstamm.html`
**Zeile:** 13
**Problem:** Basis font-size war 13px statt Standard 11px
**Änderung:**
```css
/* VORHER */
font-size: 13px;

/* NACHHER */
font-size: 11px;
```
**Status:** BEHOBEN

---

### FIX #2: frm_MA_Offene_Anfragen.html
**Datei:** `04_HTML_Forms\forms3\frm_MA_Offene_Anfragen.html`
**Zeile:** 56
**Problem:** Tabellen font-size war 13px statt Standard 11px
**Änderung:**
```css
/* VORHER */
.anfragen-table {
    font-size: 13px;
}

/* NACHHER */
.anfragen-table {
    font-size: 11px;
}
```
**Status:** BEHOBEN

---

### FIX #3: frm_DP_Dienstplan_Objekt.html
**Datei:** `04_HTML_Forms\forms3\frm_DP_Dienstplan_Objekt.html`
**Zeile:** 18
**Problem:** Body font-size war 13px statt Standard 11px
**Änderung:**
```css
/* VORHER */
body {
    font-size: 13px;
}

/* NACHHER */
body {
    font-size: 11px;
}
```
**Status:** BEHOBEN

---

## IDENTIFIZIERTE ABER NICHT GEÄNDERTE DATEIEN

### Backup-Dateien (nicht geändert)
Diese Dateien im `_sidebar_backups/` Ordner wurden bewusst NICHT geändert:
- frm_va_Auftragstamm_mitStammdaten.html.backup
- frm_MA_Zeitkonten.html.backup
- frm_MA_Offene_Anfragen.html.backup
- frm_Ausweis_Create.html.backup
- Auftragsverwaltung2.html.backup

**Grund:** Backup-Dateien sollten Original-Zustand behalten

### Media Queries (nicht geändert)
Diese Dateien haben 13px in **Media Queries für große Displays** (>1700px):
- auftragsverwaltung/frm_N_VA_Auftragstamm.html (Zeile 229, 232)
- auftragsverwaltung/frm_N_VA_Auftragstamm_backup.html (Zeile 229, 232)

**Grund:** Responsives Design - größere Schrift für größere Bildschirme ist korrekt

### Header/Label font-sizes (akzeptabel)
Diese 13px Werte sind für **Header, Titel, Labels** und somit akzeptabel:
- frm_MA_Offene_Anfragen.html:33 (.filter-label)
- frm_Ausweis_Create.html:34 (.list-header)
- frm_Ausweis_Create.html:127 (.section-title)

**Grund:** 12-14px für Überschriften/Labels ist Standard-Praxis

### Inline-Styles in Auftragsverwaltung2.html
Viele Menu-Buttons haben `style="font-size: 13px;"` inline:
- Zeilen 2820-2940

**Empfehlung:** Bei nächster Überarbeitung auf CSS-Klassen umstellen

### Script-Dateien (nicht geändert)
- _scripts/create_design_variants.py (Zeile 59, 922)
- logic/frm_N_Optimierung.logic.js (Zeile 750, 780)

**Grund:** Code-Generatoren/Templates - keine aktiven Formulare

---

## ZUSAMMENFASSUNG

| Kategorie | Anzahl | Status |
|-----------|--------|--------|
| **Kritische Fixes durchgeführt** | 3 | ERLEDIGT |
| Backup-Dateien übersprungen | 5 | BEWUSST |
| Media Queries belassen | 2 | KORREKT |
| Header/Labels belassen | 3 | AKZEPTABEL |
| Inline-Styles (später) | ~20 | EMPFOHLEN |
| Script-Dateien belassen | 2 | KORREKT |

---

## WEITERE IDENTIFIZIERTE MISSSTÄNDE

### 1. E-Mail-Versand nur Fallback
**Problem:** `sendeEinsatzliste()` nutzt nur `mailto:` Fallback
**Dateien:** `logic/frm_va_Auftragstamm.logic.js`
**Empfehlung:** Backend-Integration für echten E-Mail-Versand

### 2. Kurzname-Feld fehlt
**Problem:** ESS-Namenslisten-Export erwartet `Kurzname` Feld
**Tabelle:** `tbl_MA_Mitarbeiterstamm`
**Empfehlung:** Feld hinzufügen oder aus Vor/Nachname generieren

### 3. Rückmeldestatistik unvollständig
**Problem:** Nur `alert()` Dialog statt vollständige Ansicht
**Datei:** `logic/frm_va_Auftragstamm.logic.js`
**Empfehlung:** Vollständige Modal-Ansicht implementieren

### 4. Electron-Variante andere Farben
**Problem:** `electron_auftragstamm/styles/main.css` nutzt Rot statt Blau
**Empfehlung:** Farbpalette angleichen oder als separate Variante dokumentieren

---

## GEÄNDERTE DATEIEN (GIT-READY)

```
M  04_HTML_Forms/forms3/frm_va_Auftragstamm.html
M  04_HTML_Forms/forms3/frm_MA_Offene_Anfragen.html
M  04_HTML_Forms/forms3/frm_DP_Dienstplan_Objekt.html
A  reports/HTML_ACCESS_GLEICHWERTIGKEIT_REPORT.md
A  reports/AENDERUNGSLISTE_FIXES.md
```

---

*Erstellt durch Ultrathink Deep Analysis mit 3 parallelen Opus-Agents*
