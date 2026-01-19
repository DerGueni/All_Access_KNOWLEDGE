# Zusammenfassung: Button-Abweichungsanalyse HTML vs Access

**Datum:** 15.01.2026
**Analysierte Formulare:** 20 Hauptformulare
**Quelldateien:**
- HTML: `04_HTML_Forms\forms3\*.html`
- Access: `0_Consys_FE_Test.accdb`

---

## Gesamtstatistik

| Kategorie | Anzahl | Prozent |
|-----------|--------|---------|
| **[OK] Identisch** | 28 | 7% |
| **[MISS] Fehlt in HTML** | 141 | 36% |
| **[NEW] Nur in HTML** | 228 | 57% |
| **Gesamt** | 397 | 100% |

---

## Wichtigste Erkenntnisse

### 1. HTML hat mehr Buttons als Access (228 neue vs 141 fehlende)

Die HTML-Formulare haben deutlich mehr Buttons als die Access-Originale. Dies liegt hauptsächlich an:
- **Modernen UI-Elementen**: Vollbild-Toggle, Minimieren, Maximieren, Schließen
- **Tab-Navigation**: Jeder Tab ist als Button implementiert (z.B. "Stammdaten", "Objekte", "Preise")
- **Erweiterte Funktionen**: Aktualisieren, Filter-Shortcuts, Export-Funktionen

### 2. Nur 7% vollständige Übereinstimmung

Lediglich 28 Buttons (7%) stimmen in Label und Namen zwischen HTML und Access überein. Dies betrifft meist:
- Kernfunktionen wie "Ab Heute", "Startdatum Ändern"
- Standard-Aktionen wie "Senden", "Drucken"
- Spezialisierte Funktionen wie "Umsatzauswertung"

### 3. Formulare mit größten Abweichungen

| Formular | Buttons Gesamt | OK | MISS | NEW |
|----------|----------------|-----|------|-----|
| **frm_MA_Mitarbeiterstamm** | 84 | 5 | 36 | 43 |
| **frm_va_Auftragstamm** | 98 | 8 | 40 | 50 |
| **frm_KD_Kundenstamm** | 47 | 3 | 14 | 30 |
| **frm_OB_Objekt** | 39 | 1 | 14 | 24 |

### 4. Formulare mit vollständiger HTML-Implementation

Folgende Formulare haben **keine fehlenden Buttons** (alle Access-Buttons sind in HTML vorhanden):
- `frm_Abwesenheiten.html` (0 MISS, 7 NEW)
- `frm_Einsatzuebersicht.html` (0 MISS, 20 NEW)
- `frm_MA_Abwesenheit.html` (0 MISS, 6 NEW)

### 5. Häufig fehlende Access-Buttons in HTML

**Top 10 fehlende Button-Typen:**
1. **Ribbon-Steuerung** (btnRibbonEin, btnRibbonAus, btnDaBaEin, btnDaBaAus)
2. **Datensatz-Navigation** (btn_Datensatz_vor, btn_Datensatz_zurueck, btn_erster_Datensatz, btn_letzter_Datensatz)
3. **Excel-Export** (btnXLZeitkto, btnXLJahr, btnXLEinsUeber, btnXLUeberhangStd)
4. **PDF-Funktionen** (btnAufRchPDF, btnAufEinsPDF, btnAufRchPosPDF)
5. **Spezial-Funktionen** (btnZeitkonto, btnMADienstpl, btnRch, btnMaps)
6. **Berichte** (Bericht_drucken, btn_Diensplan_prnt)
7. **Zeitkonto-Übertragung** (btnZKFest, btnZKMini, btnZKeinzel)
8. **Vordrucke** (btnXLVordrucke, btn_MA_EinlesVorlageDatei)
9. **Listen** (btnLstDruck)
10. **Formular-Schließen** (btn_Formular_schliessen mit Access-Makro)

### 6. Neue HTML-Features (nicht in Access)

**Moderne UI-Elemente:**
- Vollbild-Toggle: `⛶` (fullscreenBtn)
- Minimieren/Maximieren: `_`, `□`
- Schließen: `✕`, `×`

**Navigation & Filter:**
- Quick-Filter: "Heute", "Diese Woche", "Dieser Monat"
- Aktualisieren-Buttons
- Moderne Navigations-Symbole: `>`, `<`, `>>`, `<<`

**Tab-Navigation:**
- Stammdaten, Objekte, Preise, Konditionen, Statistik
- Dienstplan, Einsatzübersicht, Jahresübersicht, Quick Info
- Ansprechpartner, Bemerkungen, Zusatzdateien

---

## Kritische Funktionen die in HTML fehlen

### Mitarbeiterstamm (frm_MA_Mitarbeiterstamm)
- Zeitkonto öffnen
- Wochen-Dienstplan
- Excel-Exports (Jahresübersicht, Einsatzübersicht, Zeitkonto)
- Einsätze übertragen (FA, MJ, einzeln)
- Stundennachweis
- Rechnungsdetails
- Maps öffnen
- Dienstplan drucken/senden
- Mitarbeiter-Tabelle
- Vordrucke aktualisieren
- Dienstkleidung-Ausgabeformular

### Auftragstamm (frm_va_Auftragstamm)
- Rechnungen erstellen/drucken
- Angebote öffnen
- Buchungsübersicht
- Schnellauswahl Planung
- Excel-Exports (diverse)
- PDF-Funktionen (Rechnung, Einsatzliste)
- WhatsApp-Integration
- Mehrfach-Email-Versand

### Kundenstamm (frm_KD_Kundenstamm)
- Rechnungen (PDF)
- Einsatzliste (PDF)
- Berechnungsliste (PDF)
- Neue Anlage hinzufügen
- Auswahlfilter "Alle"

### Objektverwaltung (frm_OB_Objekt)
- Datensatz-Navigation (vor/zurück/erster/letzter)
- Adresse bearbeiten
- Karte öffnen
- Objekt löschen
- Neues Objekt
- Auftragsübersicht für Objekt

---

## Empfehlungen

### Priorität 1: Kritische Funktionen implementieren
1. **Excel-Export-Buttons** - Wird häufig benötigt
2. **PDF-Funktionen** - Rechnungen, Einsatzlisten, Berechnungen
3. **Zeitkonto-Funktionen** - Übertragung FA/MJ, Anzeige
4. **Datensatz-Navigation** - Vor/Zurück/Erster/Letzter in allen Formularen

### Priorität 2: Erweiterte Funktionen
5. **Dienstplan-Integration** - Öffnen, Drucken, Senden
6. **Karten-Integration** - Maps für Adressen
7. **Vordrucke & Reports** - Druckfunktionen
8. **WhatsApp-Integration** - Messaging-Features

### Priorität 3: UI-Modernisierung
9. **Ribbon-Steuerung entfernen** - Nicht mehr relevant in HTML
10. **Makro-Buttons ersetzen** - Durch JavaScript-Funktionen
11. **Neue Funktionen dokumentieren** - Tab-Navigation, Quick-Filter

---

## Technische Details

### HTML-Button-Extraktion
- **Methode:** Regex-Patterns für `<button>` Tags mit `id`, `data-action`, `onclick`
- **Erfasste Attribute:** ID, Label, Action/OnClick
- **Formulare:** 20 Hauptformulare in `forms3/`

### Access-Button-Extraktion
- **Methode:** Access Bridge Ultimate via pywin32
- **Erfasste Objekte:** CommandButton Controls (ControlType = 104)
- **Erfasste Attribute:** Name, Caption, OnClick Event
- **Formulare:** 261 Access-Formulare (alle `frm_*`)

### Matching-Logik
- **Vergleich:** Label (case-insensitive)
- **Formular-Mapping:** Access-Name → HTML-Dateiname
- **Kategorisierung:** OK (identisch), MISS (fehlt in HTML), NEW (nur in HTML)

---

## Reports

Vollständige Details in:
- **Markdown:** `BUTTON_ABWEICHUNGEN_MIT_FORMULAR_2026-01-15.md`
- **CSV/Excel:** `BUTTON_ABWEICHUNGEN_MIT_FORMULAR_2026-01-15.csv`

Beide Dateien enthalten:
- Vollständige Button-Listen pro Formular
- Status-Kennzeichnung (OK/MISS/NEW)
- HTML- und Access-Details (ID, Name, Action, OnClick)
- Statistiken pro Formular

---

**Erstellt mit:** `analyze_button_deviations.py`
**Pfad:** `04_HTML_Forms\forms3\_reports\`
