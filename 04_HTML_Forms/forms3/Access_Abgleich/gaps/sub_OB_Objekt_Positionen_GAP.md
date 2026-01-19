# Gap-Analyse: sub_OB_Objekt_Positionen

**Datum:** 2026-01-12
**Access-Formular:** sub_OB_Objekt_Positionen
**HTML-Datei:** sub_OB_Objekt_Positionen.html
**Logic-Datei:** logic/sub_OB_Objekt_Positionen.logic.js
**Parent-Formular:** frm_OB_Objekt

---

## Übersicht

| Metrik | Access | HTML | Gap | Status |
|--------|--------|------|-----|--------|
| Controls gesamt | 12 | 6 | -6 | ⚠️ |
| Buttons | 0 | 3 | +3 | ✅ |
| TextBoxen | 11 | 0 | -11 | ❌ |
| ComboBoxen | 1 | 0 | -1 | ❌ |
| Labels (Header) | 0 | 7 | +7 | ✅ |
| Events gesamt | 0 | 8 | +8 | ✅ |

**Completion:** 50%

---

## Controls-Vergleich

### ✅ Implementiert (Konzeptionell)

| Access Control | HTML Äquivalent | Status |
|----------------|-----------------|--------|
| ID | Table Column (#1) | ✅ Via JS |
| Gruppe | Table Column (#2) | ✅ Via JS |
| Zusatztext | Table Column (#3) | ✅ Via JS |
| Geschlecht | Table Column (#4) | ✅ Via JS |
| Anzahl | Table Column (#5) | ✅ Via JS |
| Rel_Beginn | Table Column (#6) | ✅ Via JS |
| Rel_Ende | Table Column (#7) | ✅ Via JS |

**Hinweis:** HTML verwendet eine Tabelle mit dynamisch generierten Zeilen. Die Access-Felder sind als Spalten im HTML vorhanden, aber mit ANDEREN Bezeichnungen (Pos, Bezeichnung, MA Soll, Qualifikation, Stundensatz, Bemerkung).

### ❌ Fehlend / Abweichung

| Access Control | Fehlt in HTML | Priorität |
|----------------|---------------|-----------|
| PosLst_ID (OB_Objekt_Kopf_ID) | Versteckte Spalte fehlt | P2 |
| TagesArt | Nicht vorhanden | P1 |
| TagesNr | Nicht vorhanden | P1 |
| Sort | Nicht vorhanden | P0 |
| Geschlecht (ComboBox) | Als Text statt Dropdown | P1 |

**Kritisch:** HTML zeigt ANDERE Felder als Access! Access hat Rel_Beginn/Rel_Ende, HTML hat Stundensatz/Qualifikation.

---

## Feldnamen-Mapping (KRITISCHER UNTERSCHIED!)

| Access-Feld | HTML-Spalte | Bemerkung |
|-------------|-------------|-----------|
| ID | Pos | ❌ Unterschiedlich |
| Gruppe | Bezeichnung | ❌ Unterschiedlich |
| Zusatztext | - | ❌ Fehlt in HTML |
| Zusatztext2 | - | ❌ Fehlt in HTML |
| Geschlecht | Qualifikation | ❌ Völlig anderes Feld! |
| Anzahl | MA Soll | ⚠️ Andere Bezeichnung |
| Rel_Beginn | Stundensatz | ❌ Völlig anderes Feld! |
| Rel_Ende | Bemerkung | ❌ Völlig anderes Feld! |

**FEHLER:** HTML zeigt NICHT die Access-Felder aus tbl_OB_Objekt_Positionen! HTML zeigt stattdessen Felder, die eher zu einer Auftrags-Position passen (Stundensatz, Qualifikation).

---

## Events-Vergleich

### ✅ Implementiert (HTML)

| Event | Access | HTML | Bemerkung |
|-------|--------|------|-----------|
| Row Click | - | ✅ | selectRow() |
| Row DblClick | - | ✅ | bearbeitePosition() |
| btnNeu Click | - | ✅ | neuePosition() |
| btnBearbeiten Click | - | ✅ | bearbeitePosition() |
| btnLöschen Click | - | ✅ | loeschePosition() |
| postMessage (ready) | - | ✅ | subform_ready |
| postMessage (selection) | - | ✅ | subform_selection |
| postMessage (changed) | - | ✅ | subform_changed |

### ❌ Fehlend

| Access Event | Fehlt in HTML | Priorität |
|--------------|---------------|-----------|
| (Keine Events in Access definiert) | - | - |

**Hinweis:** HTML hat MEHR Events als Access, was positiv ist für die Interaktivität.

---

## Funktionalität-Vergleich

### ✅ Implementiert

- Anzeige von Positionen in Tabellenform
- Auswahl einer Position (Klick)
- Neue Position anlegen (via Prompt)
- Position bearbeiten (via Prompt)
- Position löschen (mit Bestätigung)
- Summenberechnung (MA_Soll)
- Anzahl-Anzeige
- Parent-Kommunikation via postMessage
- WebView2-Bridge Integration
- Empty-State bei leerer Liste

### ❌ Fehlend

- **ComboBox für Geschlecht** mit Dropdown-Auswahl aus tbl_Hlp_MA_Geschlecht
- **Inline-Editing** (Access erlaubt direktes Bearbeiten in Zellen)
- **Sortierung** nach Sort-Feld
- **Felder:** Zusatztext2, TagesArt, TagesNr, Rel_Beginn, Rel_Ende
- **Richtiges Datenmodell:** HTML zeigt falsche Felder (siehe Mapping oben)

---

## Datenanbindung

### Access RecordSource

```sql
SELECT tbl_OB_Objekt_Positionen.*
FROM tbl_OB_Objekt_Positionen
ORDER BY tbl_OB_Objekt_Positionen.Sort;
```

**Tabelle:** `tbl_OB_Objekt_Positionen`
**Master-Child:** `ID` (Objekt) ↔ `OB_Objekt_Kopf_ID` (Position)

### HTML API

- **Endpoint:** `/api/objekte/:id/positionen` (GET)
- **Methode:** `Bridge.sendEvent('loadSubformData', { type: 'objekt_positionen', objekt_id: ... })`
- **Status:** ⚠️ API-Endpoint möglicherweise nicht implementiert
- **Problem:** HTML-Logic verwendet WebView2-Bridge statt REST-API

### ❌ Fehlend

- REST-API Endpoint `/api/objekte/:id/positionen` ist nicht dokumentiert in api_server.py
- CRUD-Operationen über Bridge statt über REST-API
- Keine Validierung der Eingabedaten
- Keine Fehlerbehandlung bei API-Fehlern

---

## Priorität der Gaps

### P0 - Kritisch (Blocker)

1. **Falsches Datenmodell:** HTML zeigt NICHT die Felder aus tbl_OB_Objekt_Positionen! Stattdessen werden Felder wie "Stundensatz" und "Qualifikation" angezeigt, die nicht in der Tabelle existieren. **Dies ist ein fundamentaler Fehler.**
2. **Sort-Feld fehlt:** Positionen können nicht sortiert werden.
3. **REST-API fehlt:** Endpoint `/api/objekte/:id/positionen` existiert nicht.

**Aufwand P0:** 8-12 Stunden

### P1 - Wichtig

1. **Geschlecht-ComboBox:** Nur Text statt Dropdown mit Werten aus tbl_Hlp_MA_Geschlecht.
2. **Fehlende Felder:** TagesArt, TagesNr (für zeitliche Zuordnung wichtig).
3. **Inline-Editing:** Access erlaubt direktes Bearbeiten, HTML nur via Prompt.

**Aufwand P1:** 4-6 Stunden

### P2 - Nice-to-have

1. **PosLst_ID versteckt:** Sollte als data-attribute gespeichert werden.
2. **Zusatztext2-Feld:** Zweites Zusatztextfeld.

**Aufwand P2:** 2-3 Stunden

---

## Empfehlung

### Completion: 50%

**Status:** ⚠️ **KRITISCH - Datenmodell falsch implementiert!**

Das HTML-Formular zeigt NICHT die korrekten Felder aus der Access-Tabelle `tbl_OB_Objekt_Positionen`. Die angezeigten Spalten (Pos, Bezeichnung, MA Soll, Qualifikation, Stundensatz, Bemerkung) entsprechen NICHT den Access-Feldern (ID, Gruppe, Zusatztext, Zusatztext2, Geschlecht, Anzahl, Rel_Beginn, Rel_Ende, TagesArt, TagesNr, Sort).

### Kritische Gaps

1. **Datenmodell komplett überarbeiten:** HTML-Tabelle muss die echten Felder aus tbl_OB_Objekt_Positionen anzeigen.
2. **REST-API implementieren:** Endpoint für CRUD-Operationen erstellen.
3. **Sortierung:** Nach Sort-Feld sortieren.

### Aufwand Gesamt

- **P0 (Kritisch):** 8-12 Stunden
- **P1 (Wichtig):** 4-6 Stunden
- **P2 (Nice-to-have):** 2-3 Stunden

**Gesamt:** 14-21 Stunden

### Nächste Schritte

1. **Datenbank-Schema prüfen:** Welche Felder hat `tbl_OB_Objekt_Positionen` wirklich?
2. **HTML-Tabelle neu aufbauen:** Spalten müssen den Access-Feldern entsprechen.
3. **REST-API erstellen:** `/api/objekte/:id/positionen` in api_server.py implementieren.
4. **Logic.js anpassen:** Bridge-Aufrufe durch REST-Calls ersetzen.
5. **Validierung hinzufügen:** Pflichtfelder, Datentypen prüfen.
6. **Inline-Editing:** Direkte Bearbeitung in Tabelle ermöglichen.

---

**Fazit:** Das Subformular ist strukturell vorhanden, zeigt aber die falschen Daten. Eine grundlegende Überarbeitung ist notwendig, um die Access-Funktionalität korrekt nachzubilden.
