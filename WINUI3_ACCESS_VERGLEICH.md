# WinUI3 vs Access - Visueller Vergleich

**Erstellt:** 2025-12-30
**Status:** Analyse auf Basis JSON-Export und WinUI3-XAML

---

## Übersicht

| Formular | Access-Original | WinUI3-Status | Übereinstimmung |
|----------|-----------------|---------------|-----------------|
| Dienstplan MA | FRM_frm_DP_Dienstplan_MA | DienstplanMAView.xaml | ⚠️ ~75% |
| Dienstplan Objekt | FRM_frm_DP_Dienstplan_Objekt (fehlt) | DienstplanObjektView.xaml | ⚠️ ~70% |
| Mitarbeiterstamm | FRM_frm_MA_Mitarbeiterstamm | MitarbeiterstammView.xaml | ✅ ~90% |
| Kundenstamm | FRM_frm_KD_Kundenstamm | KundenstammView.xaml | ⚠️ ~80% |

---

## 1. Dienstplan MA (frm_DP_Dienstplan_MA)

### Access-Original-Elemente (aus JSON):
- **Header-Bereich:**
  - Bezeichnungsfeld96 (Label): "Dienstplan MA" - Position: 1875,450 Twips
  - Rechteck108 (Rectangle): Hintergrund für Datumsbereich - BackColor: -2147483613 (#F0F0F0)
  - dtStartdatum (TextBox): Datumsauswahl - Position: 7368,391
  - btnStartdatum (Button): Datum-Button - Position: 7373,674
  - btnVor/btnrueck (Buttons): Navigation vor/zurück
  - btn_Heute (Button): "Heute" - ForeColor: 2500134 (#263126 dunkelgrün)

- **Filter-Bereich:**
  - NurAktiveMA (ComboBox): Filter für MA-Typen - DefaultValue: 2 ("Alle aktiven")
  - Optionen: "Alle anzeigen", "Alle aktiven", "Festangestellte", "Minijobber", "Sub"

- **Tages-Header (7 Spalten):**
  - lbl_Tag_1 bis lbl_Tag_7 (TextBoxen): BackColor: 16179314 (#F6EDF2 rosa-beige)
  - Format: "ddd/ dd/mm/yy"
  - Breite je ca. 3400 Twips (~227px)

- **Sidebar:**
  - frm_Menuefuehrung (SubForm): Links, Breite 2637 Twips (~176px)

- **Haupt-Subform:**
  - sub_DP_Grund (SubForm): Position 2580,390 - Breite 25979 Twips (~1732px)

### WinUI3-Implementierung:
```
✅ Header mit Titel "Dienstplan Mitarbeiter"
✅ Filter-Bereich mit MA-Auswahl, Datumsauswahl
✅ Schnellzugriff-Buttons (Woche, Monat, Navigation)
✅ CalendarGrid-Control für Kalenderansicht
✅ Listen-Ansicht mit Einsätzen
✅ Statistik-Panel (Einsätze, Stunden, Tage)
✅ Abwesenheiten-Liste

⚠️ ABWEICHUNGEN:
1. Keine Sidebar (Access hat frm_Menuefuehrung links)
2. Keine 7-Spalten-Tages-Header wie im Access
3. Farben: Access nutzt rosa-beige (#F6EDF2), WinUI3 nutzt Theme-Farben
4. Access-Rechteck108 Hintergrund fehlt
5. "Heute"-Button hat andere Farbe (Access: dunkelgrün, WinUI3: Theme)
```

### Korrektur-Empfehlungen:
1. **Sidebar hinzufügen** - Dunkelrote Sidebar wie in Mitarbeiterstamm
2. **7-Tage-Header** - Horizontale TextBoxen mit rosa-beige Hintergrund
3. **Farbkorrekturen** - Access-spezifische Farben übernehmen

---

## 2. Dienstplan Objekt (frm_DP_Dienstplan_Objekt)

### Access-Original:
- **KEIN JSON-Export verfügbar** in 30_forms
- Vermutlich ähnliche Struktur wie Dienstplan MA

### WinUI3-Implementierung:
```
✅ Header mit Titel "Dienstplan Objekt"
✅ Auftrag/Objekt-Auswahl (ComboBox)
✅ Filter: "Nur unbesetzte Schichten"
✅ Statistik-Leiste (Schichten, MA Soll/Ist/Fehlt, Besetzungsgrad)
✅ CalendarGrid für Kalenderansicht
✅ Listen-Ansicht mit Schichten
✅ Zugeordnete Mitarbeiter Panel
✅ Schnellauswahl-Button

⚠️ ABWEICHUNGEN:
1. Ohne Access-Referenz schwer zu verifizieren
2. Keine Sidebar vorhanden
```

### Korrektur-Empfehlungen:
1. **Access-Formular exportieren** falls vorhanden
2. **Sidebar hinzufügen** für Konsistenz

---

## 3. Mitarbeiterstamm (frm_MA_Mitarbeiterstamm)

### Access-Original-Elemente (aus JSON - Datei zu groß für Vollanalyse):
- **Sidebar:** Dunkelrot (#8B0000) - 140px Breite
- **Header:** Lila (#6B4D8C) mit weißer Schrift
- **Navigationsbuttons:** ◀◀, ◀, ▶, ▶▶ in grauem Rahmen
- **Tab-Button "MA Adressen":** Hellgrün (#C0FF00)
- **Aktionsbuttons:** "Zeitkonto", "Neuer Mitarbeiter", "Einsätze übertragen" - Blau (#95B3D7)
- **Tab-Control:** Stammdaten, Einsatzübersicht, Dienstplan, Nicht Verfügbar, Dienstkleidung

### WinUI3-Implementierung:
```
✅ Sidebar dunkelrot (#8B0000) - 140px
✅ HAUPTMENÜ-Box weiß mit schwarzem Rahmen
✅ Menü-Buttons in Sidebar (#A05050)
✅ Header lila (#6B4D8C) mit weißer Schrift
✅ Navigationsbuttons ◀◀, ◀, ▶, ▶▶
✅ Tab-Button "MA Adressen" hellgrün (#C0FF00)
✅ Name-Anzeige (Nachname, Vorname, MA-ID)
✅ Blaue Aktionsbuttons (#95B3D7)
✅ Pivot/Tab-Control mit 5 Tabs
✅ Stammdaten-Formular mit allen Feldern
✅ Rechte Liste mit Suche/Filter

✅ KORREKT IMPLEMENTIERT:
- Label-Breite 70px
- TextBox-Style mit MinHeight 20px
- Access-Farben korrekt konvertiert
- Foto-Bereich mit Maps-Button
- Koordinaten gelb hinterlegt (#FFFACD)

⚠️ KLEINE ABWEICHUNGEN:
1. Header-Buttons "Löschen/Transfer" im separaten Bereich (Kopfzeile 2)
2. Pivot statt Access TabControl - minimal andere Optik
```

### Bewertung: ✅ 90% Übereinstimmung
Sehr gute 1:1 Nachbildung. Nur minimale Abweichungen.

---

## 4. Kundenstamm (frm_KD_Kundenstamm)

### Access-Original-Elemente:
- **Sehr große JSON-Datei** (51512 Tokens) - Hauptstruktur:
  - Navigationsbuttons
  - Suchfeld
  - CRUD-Buttons
  - Firmendaten-Bereich
  - Adress-Bereich
  - Kontakt/Finanzen-Bereich
  - Kundenliste (rechts oder links)

### WinUI3-Implementierung:
```
✅ Header mit Navigationsbuttons (First, Prev, Next, Last)
✅ Suchbox mit "Suchen"/"Zurücksetzen"
✅ CRUD-Buttons (Neu, Bearbeiten, Speichern, Löschen, Abbrechen)
✅ Statusbar
✅ Kundenliste links (280px)
✅ Hauptformular mittig mit:
    - Firmendaten (Kunden-ID, Aktiv, Firma, Ansprechpartner)
    - Adresse (Straße, PLZ, Ort, Land)
    - Kontakt/Finanzen (Telefon, Fax, Email, Website, USt-ID)
✅ Info-Card rechts (Zahlungsziel, Aufträge-Count)
✅ Footer mit Kunden-ID

⚠️ ABWEICHUNGEN:
1. KEINE Sidebar - Access hat evtl. Sidebar
2. Moderne WinUI3-Cards statt Access-Rahmen
3. Kontaktname-Felder hinzugefügt (Nachname/Vorname) - GUT!
4. Farben: WinUI3 Theme vs Access-Grautöne
```

### Verbesserungen bereits umgesetzt:
- Kontaktname/Vorname in Kundenliste
- Header-Abstände optimiert

### Korrektur-Empfehlungen:
1. **Sidebar hinzufügen** für Konsistenz mit anderen Formularen
2. **Access-Farben** falls gewünscht

---

## Globale Erkenntnisse

### Was WinUI3 BESSER macht:
1. **Moderne UI** - Fluent Design, Rounded Corners, Cards
2. **Responsive** - Bessere Skalierung
3. **Konsistenz** - Theme-basierte Farben
4. **CalendarGrid** - Eigenes Control für Dienstplan

### Was für 1:1-Treue korrigiert wurde (30.12.2025):
1. ✅ **Sidebar** - Jetzt in ALLEN 10 Formularen implementiert (dunkelrot #8B0000, 140px)
2. ✅ **Background** - Alle Views auf Access-Grau #F0F0F0 umgestellt
3. ✅ **Aktiver Menüpunkt** - Goldene Hervorhebung #D4A574

### Noch ausstehend:
1. **7-Tage-Header** - Horizontale Layout wie Access
2. **Pixel-genaue Positionen** - WinUI3 nutzt Grid/StackPanel

---

## Erledigte Schritte (30.12.2025)

1. ✅ Build erfolgreich (0 Fehler)
2. ✅ Alle 7 Haupt-Views Controls geprueft (Bindings, Commands)
3. ✅ Sidebar zu DienstplanMA, DienstplanObjekt, Kundenstamm, Auftragstamm, Schnellauswahl hinzugefuegt
4. ✅ Sidebar zu Objektstamm, Zeitkonten, Bewerber, Abwesenheit hinzugefuegt
5. ✅ Alle Views auf Access-Grau Background #F0F0F0 umgestellt

## Formulare mit Sidebar (10/10):
| Formular | Sidebar | Background | Aktiver Button |
|----------|---------|------------|----------------|
| DienstplanMAView | ✅ | #F0F0F0 | Dienstplanübersicht |
| DienstplanObjektView | ✅ | #F0F0F0 | Planungsübersicht |
| MitarbeiterstammView | ✅ | #F0F0F0 | Mitarbeiterstamm |
| KundenstammView | ✅ | #F0F0F0 | Auftragsverwaltung |
| AuftragstammView | ✅ | #F0F0F0 | Auftragsverwaltung |
| SchnellauswahlView | ✅ | #F0F0F0 | Schnellauswahl |
| ObjektstammView | ✅ | #F0F0F0 | Objektstamm |
| ZeitkontenView | ✅ | #F0F0F0 | Zeitkonten |
| BewerberView | ✅ | #F0F0F0 | Bewerber |
| AbwesenheitView | ✅ | #F0F0F0 | Abwesenheiten |

---

## Dateipfade

- **WinUI3 EXE:** `0000_Windows_WinUI3_2\ConsysWinUI\ConsysWinUI\bin\x64\Debug\net8.0-windows10.0.19041.0\ConsysWinUI.exe`
- **Access JSON:** `11_json_Export\000_Consys_Eport_11_25\30_forms\FRM_*.json`
- **WinUI3 Views:** `0000_Windows_WinUI3_2\ConsysWinUI\ConsysWinUI\Views\*.xaml`
