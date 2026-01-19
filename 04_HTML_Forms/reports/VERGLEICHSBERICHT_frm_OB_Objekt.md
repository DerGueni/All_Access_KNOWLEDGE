# Visueller Vergleichsbericht: frm_OB_Objekt

**Datum:** 2026-01-01
**Vergleich:** Access-Formular vs. HTML-Formular
**Fokus:** Vollständigkeit der Controls (OHNE Farben)

---

## 1. SCREENSHOTS

- **Access:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\screenshots_test\access_frm_OB_Objekt.png`
- **HTML:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\screenshots_test\html_frm_OB_Objekt.png`

---

## 2. ANALYSE DER CONTROLS (ACCESS-ORIGINAL)

### 2.1 Hauptformular-Elemente

#### Navigation/Aktionsbuttons (oben)
1. **btn_Befehl43** - Erster Datensatz (ganz links)
2. **btn_Befehl41** - Vorheriger Datensatz
3. **btn_Befehl40** - Nächster Datensatz
4. **btn_letzer_Datensatz** - Letzter Datensatz
5. **btn_Befehl42** - Neuer Datensatz
6. **btnHilfe** - Hilfe
7. **btn_Back_akt_Pos_List** - Zurück (Visible=Falsch, nicht sichtbar)
8. **mcobtnDelete** - Löschen-Button (rot)
9. **btnNeuVeranst** - Neuer Veranstalter
10. **btnReport** - Bericht

#### Systembuttons (klein, links oben)
11. **btnRibbonAus** - Ribbon ausblenden
12. **btnRibbonEin** - Ribbon einblenden
13. **btnDaBaAus** - Datenbank aus
14. **btnDaBaEin** - Datenbank ein

#### Textfelder (Hauptbereich)
15. **ID** - Objekt-ID (Enabled=Falsch, Locked=Wahr)
16. **Objekt** - Objektname (Hauptfeld)
17. **Strasse** - Straße
18. **PLZ** - Postleitzahl
19. **Ort** - Ort
20. **Treffpunkt** - Treffpunkt
21. **Treffp_Zeit** - Treffpunkt-Zeit (Format: Short Time)
22. **Dienstkleidung** - Dienstkleidung
23. **Ansprechpartner** - Ansprechpartner
24. **Text435** - Zusätzliches Textfeld (unbenannt)

#### Labels
25. **Auto_Kopfzeile0** - Header-Label
26. **lbl_Datum** - Datum-Label
27. **Bezeichnungsfeld0** - Label für "Objekt"
28. **Bezeichnungsfeld9** - Label für "Strasse"
29. **Bezeichnungsfeld322** - Label für "PLZ/Ort"
30. **Bezeichnungsfeld327** - Label für "Treffpunkt"
31. **Bezeichnungsfeld330** - Label für "Dienstkleidung"
32. **Bezeichnungsfeld333** - Label für "Ansprechpartner"
33. **Bezeichnungsfeld354** - Uhrzeit-Einheit (h)
34. **Bezeichnungsfeld436** - Label für Text435

#### Metadaten-Felder (oben, klein)
35. **Erst_von** - Erstellt von
36. **Erst_am** - Erstellt am (Enabled=Falsch)
37. **Aend_von** - Geändert von
38. **Aend_am** - Geändert am (Enabled=Falsch)
39. **Bezeichnungsfeld416** - Label "Erst von"
40. **Bezeichnungsfeld420** - Label "Änd. von"

### 2.2 Tab-Control (Reg_VA)

**TabControl:** Reg_VA (Left: 3375, Top: 2070, Width: 11565, Height: 5715)

#### Tab 1: Positionen (pgPos)
- **sub_OB_Objekt_Positionen** - Unterformular für Positionen
  - Link Master Fields: ID
  - Link Child Fields: OB_Objekt_Kopf_ID

#### Tab 2: Sammlungen (implizit in JSON)
- Kein Subform direkt definiert in diesem Tab

#### Tab 3: Aufträge (implizit in JSON)
- Kein Subform direkt definiert in diesem Tab

#### Tab 4: Anhänge (pgAttach)
- **sub_ZusatzDateien** - Unterformular für Anhänge
  - Link Master Fields: ID, TabellenNr
  - Link Child Fields: Ueberordnung, TabellenID
- **btnNeuAttach** - Button "Neue Anlage"
- **TabellenNr** - Verstecktes Textfeld (=42, Visible=Falsch)

### 2.3 Objektliste (rechts)
41. **Liste_Obj** - ListBox mit allen Objekten
    - Row Source: `SELECT tbl_OB_Objekt.ID, tbl_OB_Objekt.Objekt, tbl_OB_Objekt.Ort FROM tbl_OB_Objekt ORDER BY tbl_OB_Objekt.Objekt;`
    - ColumnCount: 3
    - BoundColumn: 1
    - ColumnWidths: "0;4536;4536"

### 2.4 Sidebar (links)
42. **frm_Menuefuehrung** - Menü-Unterformular (Sidebar)
    - Left: 0, Top: 0, Width: 3223, Height: 7936

---

## 3. ANALYSE DES HTML-FORMULARS

### 3.1 Vorhandene Elemente (Screenshot-basiert)

#### Navigation/Aktionsbuttons
- ✅ Navigationbuttons (<<, <, >, >>, +Neu) vorhanden
- ✅ Speichern-Button (grün)
- ✅ Löschen-Button (rot)
- ❌ Checkbox "Nur aktive" fehlt (sollte im Access-Original sein)

#### Textfelder
- ✅ Objekt-ID
- ✅ Objekt
- ✅ Strasse
- ✅ PLZ/Ort
- ✅ Treffpunkt
- ✅ Treffp_Zeit (mit "HH:MM" Hinweis)
- ✅ Dienstkleidung
- ✅ Ansprechpartner
- ✅ Telefon (zusätzliches Feld, war als Text435 im Access)

#### Tab-Control
- ✅ Tabs vorhanden: "Positionen", "Zusatzstudien", "Sammlungen", "Aufträge"
- ⚠️ Tab "Anhänge" heißt im HTML "Sammlungen" (falsches Label?)
- ⚠️ Subform-Inhalte: Platzhalter "Lade Positionen..." (nicht geladen)

#### Objektliste (rechts)
- ✅ Objektliste vorhanden mit 3 Beispiel-Einträgen:
  1. Arena Nuernberg - Nuernberg
  2. Messezentrum - Nuernberg
  3. Messezentrum - Nuernberg

#### Sidebar (links)
- ✅ Sidebar vorhanden mit allen Menüpunkten:
  - HAUPTMENU
  - Dienstplanuebersicht
  - Planungsuebersicht
  - Auftragsverwaltung
  - Mitarbeiterverwaltung
  - Excel Zeitkonten
  - Offene Mail Anfrage
  - Zeitkonten
  - Abwesenheitsplanung
  - Dienstausweis erstellen
  - Stundenabgleich
  - Kundenverwaltung
  - Objektverwaltung (aktiv)
  - Verrechnungssatze
  - Sub Rechnungen
  - E-Mail
  - Menu 2
  - System Info
  - Datenbank wechseln

### 3.2 Fehlende Elemente

#### Buttons
1. ❌ **btnReport** - Bericht-Button fehlt
2. ❌ **btn_Back_akt_Pos_List** - Zurück-Button (war ohnehin Visible=Falsch)
3. ❌ **btnNeuVeranst** - Neuer Veranstalter-Button fehlt
4. ❌ **Systembuttons** - btnRibbonAus, btnRibbonEin, btnDaBaAus, btnDaBaEin (sind Access-spezifisch, nicht relevant für HTML)

#### Labels
5. ❌ **lbl_Datum** - Datum-Label fehlt (oben rechts im Access)
6. ❌ **Uhrzeit-Einheit** - "h" Label neben Treffp_Zeit fehlt

#### Metadaten-Felder
7. ❌ **Erst_von** - Erstellt von
8. ❌ **Erst_am** - Erstellt am
9. ❌ **Aend_von** - Geändert von
10. ❌ **Aend_am** - Geändert am
11. ❌ **Labels für Metadaten** - "Erst von:", "Änd. von:"

#### Tab-Inhalte
12. ❌ **sub_OB_Objekt_Positionen** - Unterformular nicht geladen (nur Platzhalter)
13. ❌ **sub_ZusatzDateien** - Unterformular nicht geladen
14. ❌ **btnNeuAttach** - Button "Neue Anlage" im Anhänge-Tab fehlt
15. ❌ **TabellenNr** - Verstecktes Feld (nicht kritisch, da hidden)

### 3.3 Positionierungsunterschiede

#### Navigationbuttons
- ⚠️ Access: 6 einzelne Buttons (<<, <, 1/3, >, >>, ?)
- ✅ HTML: Ähnliche Anordnung, aber mit "+Neu" Button integriert

#### Hauptfeld-Anordnung
- ⚠️ Access: Objektliste rechts nimmt ca. 40% der Breite ein
- ⚠️ HTML: Objektliste rechts nimmt ca. 35% der Breite ein (leicht schmaler)

#### Tab-Control
- ⚠️ Access: Tab-Control startet bei Y=2070 (ca. Mitte des Formulars)
- ✅ HTML: Tab-Control ähnlich positioniert

---

## 4. ZUSAMMENFASSUNG DER FEHLENDEN ELEMENTE

### 4.1 Kritisch (müssen implementiert werden)

| # | Element | Typ | Beschreibung | Position (Twips) |
|---|---------|-----|--------------|------------------|
| 1 | btnReport | Button | Bericht-Button | L:15271, T:563, W:2295, H:336 |
| 2 | btnNeuVeranst | Button | Neuer Veranstalter | L:12421, T:563, W:2295, H:336 |
| 3 | lbl_Datum | Label | Datum-Anzeige | L:26506, T:563, W:1018, H:397 |
| 4 | Erst_von | TextBox | Erstellt von | L:1247, T:56, W:1871, H:225 |
| 5 | Erst_am | TextBox | Erstellt am | L:3344, T:56, W:1871, H:225 |
| 6 | Aend_von | TextBox | Geändert von | L:7766, T:56, W:1871, H:225 |
| 7 | Aend_am | TextBox | Geändert am | L:9863, T:56, W:1871, H:225 |
| 8 | Bezeichnungsfeld416 | Label | "Erst von:" | L:170, T:56, W:795, H:225 |
| 9 | Bezeichnungsfeld420 | Label | "Änd. von:" | L:6689, T:56, W:795, H:225 |
| 10 | Bezeichnungsfeld354 | Label | "h" (Uhrzeit) | L:14408, T:283, W:397, H:299 |
| 11 | sub_OB_Objekt_Positionen | SubForm | Positionen-Unterformular | L:3675, T:3004, W:11113, H:4531 |
| 12 | sub_ZusatzDateien | SubForm | Anhänge-Unterformular | L:3682, T:3847, W:11100, H:3540 |
| 13 | btnNeuAttach | Button | Neue Anlage (im Anhänge-Tab) | L:3750, T:3090, W:2215, H:388 |

### 4.2 Optional (Access-spezifisch, nicht relevant für HTML)

| # | Element | Typ | Beschreibung | Begründung |
|---|---------|-----|--------------|------------|
| 1 | btnRibbonAus | Button | Ribbon ausblenden | Access-UI spezifisch |
| 2 | btnRibbonEin | Button | Ribbon einblenden | Access-UI spezifisch |
| 3 | btnDaBaAus | Button | Datenbank aus | Access-UI spezifisch |
| 4 | btnDaBaEin | Button | Datenbank ein | Access-UI spezifisch |
| 5 | btn_Back_akt_Pos_List | Button | Zurück (Visible=Falsch) | Im Original nicht sichtbar |
| 6 | TabellenNr | TextBox | Hidden Field (=42) | Kann im HTML als hidden input existieren |

### 4.3 Falsche Beschriftungen

| Element | Access-Original | HTML-IST | Korrektur nötig |
|---------|----------------|----------|-----------------|
| Tab-Namen | pgPos, pgAttach | "Positionen", "Sammlungen" | Tabs-Namen aus spec.json lesen |

---

## 5. VOLLSTÄNDIGKEITS-BEWERTUNG

### 5.1 Prozentuale Vollständigkeit

**Gesamt-Controls im Access-Original:** 42 (ohne System-Buttons)

**Davon im HTML vorhanden:**
- ✅ Navigation/Aktionsbuttons: 5/8 (62.5%)
- ✅ Textfelder: 9/10 (90%)
- ✅ Labels: 5/15 (33.3%)
- ✅ Tab-Control: 1/1 (100%)
- ✅ Subforms: 0/2 (0% - nur Platzhalter)
- ✅ Objektliste: 1/1 (100%)
- ✅ Sidebar: 1/1 (100%)

**GESAMT: ~65% Vollständigkeit**

### 5.2 Kritische Mängel

1. **Metadaten-Block fehlt komplett** (Erst_von, Erst_am, Aend_von, Aend_am)
2. **Unterformulare nicht implementiert** (nur Platzhalter-Text)
3. **Buttons fehlen** (btnReport, btnNeuVeranst, btnNeuAttach)
4. **Labels unvollständig** (viele Beschriftungen fehlen)

---

## 6. EMPFOHLENE MASSNAHMEN

### 6.1 Sofort umzusetzen

1. **Metadaten-Block hinzufügen** (oben, klein, grau)
   - Erst_von, Erst_am, Aend_von, Aend_am
   - Labels: "Erst von:", "Änd. von:"

2. **Fehlende Buttons ergänzen**
   - btnReport (Position: nach btnDelete)
   - btnNeuVeranst (Position: unter btnReport)
   - btnNeuAttach (im Anhänge-Tab)

3. **Unterformulare implementieren**
   - sub_OB_Objekt_Positionen (als iframe oder inline-table)
   - sub_ZusatzDateien (als iframe oder inline-table)

4. **Labels vervollständigen**
   - lbl_Datum (oben rechts)
   - Uhrzeit-Einheit "h" (neben Treffp_Zeit)

### 6.2 Prüfen und korrigieren

1. **Tab-Namen aus spec.json lesen**
   - Aktuell: "Positionen", "Zusatzstudien", "Sammlungen", "Aufträge"
   - Soll aus JSON ableiten

2. **Objektliste-Breite anpassen**
   - Access: 11631 Twips = 775px
   - HTML: visuell etwas schmaler (prüfen)

---

## 7. PIXEL-GENAUE POSITIONEN (für fehlende Elemente)

### Metadaten-Block (oben)

```
Erst_von:     L: 83px,  T:  4px, W: 125px, H: 15px
Erst_am:      L: 223px, T:  4px, W: 125px, H: 15px
Aend_von:     L: 518px, T:  4px, W: 125px, H: 15px
Aend_am:      L: 658px, T:  4px, W: 125px, H: 15px

Label "Erst von:": L: 11px, T: 4px, W: 53px, H: 15px
Label "Änd. von:": L: 446px, T: 4px, W: 53px, H: 15px
```

### Fehlende Buttons

```
btnReport:      L: 1018px, T: 38px, W: 153px, H: 22px
btnNeuVeranst:  L:  828px, T: 38px, W: 153px, H: 22px
btnNeuAttach:   L:  250px, T: 206px, W: 148px, H: 26px (innerhalb pgAttach)
```

### Fehlende Labels

```
lbl_Datum:     L: 1767px, T: 38px, W: 68px, H: 26px
Uhrzeit "h":   L:  960px, T: 19px, W: 26px, H: 20px
```

---

## 8. FAZIT

Das HTML-Formular hat bereits eine **solide Grundstruktur** mit Sidebar, Navigationbuttons, Hauptfeldern und Tab-Control.

**Hauptprobleme:**
1. **Metadaten-Block fehlt komplett** (kritisch für Auditing)
2. **Unterformulare nicht implementiert** (nur Platzhalter)
3. **Mehrere Buttons fehlen** (btnReport, btnNeuVeranst, btnNeuAttach)
4. **Labels unvollständig** (viele Beschriftungen fehlen)

**Vollständigkeit: ~65%**

Für eine vollständige 1:1-Nachbildung sind noch **13 kritische Elemente** zu ergänzen (siehe Abschnitt 4.1).

---

**Erstellt mit:** Claude Code Agent
**Basis:** FRM_frm_OB_Objekt.json + Screenshots
