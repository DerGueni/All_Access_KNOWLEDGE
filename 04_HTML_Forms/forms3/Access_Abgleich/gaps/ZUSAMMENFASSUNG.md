# Zusammenfassung: Gap-Analysen Unterformulare

**Datum:** 2026-01-12
**Analysierte Formulare:** 4

---

## Übersicht

| Formular | Completion | Status | P0 Aufwand | P1 Aufwand | Gesamt |
|----------|------------|--------|-----------|-----------|--------|
| **sub_OB_Objekt_Positionen** | 50% | ⚠️ KRITISCH | 8-12h | 4-6h | 14-21h |
| **sub_rch_Pos** | 85% | ✅ GUT | 0h | 6-8h | 8-11h |
| **sub_VA_Einsatztage** | 60% | ⚠️ STRUKTUR | 2-3h | 4-6h | 8-12h |
| **sub_VA_Schichten** | 70% | ✅ GUT | 0h | 4-6h | 6-9h |

**Gesamt-Aufwand:** 36-53 Stunden

---

## 1. sub_OB_Objekt_Positionen

### Status: ⚠️ KRITISCH

**Hauptproblem:** Das HTML-Formular zeigt **FALSCHE FELDER** an!

- Access zeigt: `ID`, `Gruppe`, `Zusatztext`, `Zusatztext2`, `Geschlecht`, `Anzahl`, `Rel_Beginn`, `Rel_Ende`, `TagesArt`, `TagesNr`, `Sort`
- HTML zeigt: `Pos`, `Bezeichnung`, `MA Soll`, `Qualifikation`, `Stundensatz`, `Bemerkung`

**Kritische Gaps (P0):**
1. Datenmodell komplett falsch - HTML zeigt nicht die Felder aus `tbl_OB_Objekt_Positionen`
2. Sort-Feld fehlt (Sortierung)
3. REST-API fehlt

**Aufwand:** 14-21 Stunden

**Empfehlung:** Komplette Überarbeitung notwendig. Datenbank-Schema prüfen, HTML-Tabelle neu aufbauen.

---

## 2. sub_rch_Pos

### Status: ✅ GUT

**Hauptproblem:** Grundfunktionen vorhanden, CRUD-Operationen fehlen.

- Felder korrekt implementiert
- Summenberechnung funktioniert
- UI ist ansprechend

**Kritische Gaps (P1):**
1. btnNeu / btnLöschen ohne Funktion
2. MwSt-Satz hardcoded (19%) statt dynamisch
3. REST-API fehlt

**Aufwand:** 8-11 Stunden

**Empfehlung:** CRUD-Funktionen implementieren, REST-API erstellen. Dann produktionsreif.

---

## 3. sub_VA_Einsatztage

### Status: ⚠️ STRUKTURPROBLEME

**Hauptproblem:** Funktional, aber Code-Struktur schlecht.

- Logic ist inline im HTML statt in separater .logic.js
- Verwendet `data-date` statt `data-id` (Fehlerquelle!)
- REST-API nicht dokumentiert

**Kritische Gaps (P0):**
1. ID statt Datum als Identifier verwenden

**Wichtige Gaps (P1):**
1. Logic-File auslagern
2. REST-API dokumentieren
3. Fehlerbehandlung verbessern

**Aufwand:** 8-12 Stunden

**Empfehlung:** Logic-File erstellen, ID-basierte Identifier, REST-API dokumentieren.

---

## 4. sub_VA_Schichten

### Status: ✅ GUT

**Hauptproblem:** Funktional, kleine Verbesserungen nötig.

- Zeigt Schichten korrekt an
- Auswahl und Status funktionieren
- Farbcodierung ist gut

**Wichtige Gaps (P1):**
1. Logic ist inline im HTML (wie sub_VA_Einsatztage)
2. Bemerkung-Feld fehlt in Anzeige
3. REST-API nicht dokumentiert

**Aufwand:** 6-9 Stunden

**Empfehlung:** Logic-File erstellen, Bemerkung hinzufügen, REST-API klären.

---

## Prioritäten

### SOFORT (P0 - Kritisch):

1. **sub_OB_Objekt_Positionen:** Datenmodell komplett überarbeiten (8-12h)
2. **sub_VA_Einsatztage:** ID statt Datum verwenden (2-3h)

**Gesamt P0:** 10-15 Stunden

### BALD (P1 - Wichtig):

1. **sub_OB_Objekt_Positionen:** REST-API, Sortierung (4-6h)
2. **sub_rch_Pos:** CRUD-Funktionen, REST-API (6-8h)
3. **sub_VA_Einsatztage:** Logic-File, Doppelklick (4-6h)
4. **sub_VA_Schichten:** Logic-File, Bemerkung (4-6h)

**Gesamt P1:** 18-26 Stunden

### SPÄTER (P2 - Nice-to-have):

- Inline-Editing für alle Formulare
- Validierung
- UI-Verbesserungen

**Gesamt P2:** 8-12 Stunden

---

## Gemeinsame Probleme

### 1. Logic-Dateien fehlen

- **sub_VA_Einsatztage:** Kein Logic-File, Code inline
- **sub_VA_Schichten:** Kein Logic-File, Code inline

**Grund:** Einfache Formulare wurden ohne separate Logic erstellt.

**Empfehlung:** Logic-Files erstellen für Konsistenz und Wartbarkeit.

### 2. REST-API nicht dokumentiert

- Alle 4 Formulare verwenden API-Endpoints die nicht in `api_server.py` dokumentiert sind
- Unklare Endpoint-Namen:
  - `/api/objekte/:id/positionen`
  - `/api/rechnungen/:id/positionen`
  - `/api/einsatztage/:va_id`
  - `/api/schichten/:va_id` oder `/api/dienstplan/schichten`?

**Empfehlung:** API-Endpoints in api_server.py implementieren und dokumentieren.

### 3. Fehlerbehandlung

- Alle Formulare haben nur rudimentäre Fehlerbehandlung (console.log)
- Keine User-Feedback bei API-Fehlern

**Empfehlung:** Einheitliche Fehlerbehandlung mit User-Feedback.

---

## Nächste Schritte (Reihenfolge)

### Phase 1 (Kritisch - 10-15h):
1. sub_OB_Objekt_Positionen: Datenmodell prüfen und korrigieren
2. sub_VA_Einsatztage: ID statt Datum verwenden

### Phase 2 (Wichtig - 18-26h):
1. REST-API für alle 4 Formulare implementieren
2. Logic-Files für sub_VA_Einsatztage und sub_VA_Schichten erstellen
3. CRUD-Funktionen für sub_rch_Pos implementieren
4. Sortierung für sub_OB_Objekt_Positionen

### Phase 3 (Nice-to-have - 8-12h):
1. Inline-Editing
2. Validierung
3. UI-Verbesserungen

**Gesamt:** 36-53 Stunden

---

## Empfehlung

Die beiden **Einsatzplanungs-Formulare** (sub_VA_Einsatztage, sub_VA_Schichten) sind **funktional** und können mit kleinen Verbesserungen (Logic-Files, REST-API) produktiv genutzt werden.

Das **Rechnungsformular** (sub_rch_Pos) ist **gut** und braucht nur CRUD-Funktionen.

Das **Objekt-Positionen-Formular** (sub_OB_Objekt_Positionen) ist **kritisch** und benötigt eine **komplette Überarbeitung**, da es die falschen Daten anzeigt.

**Priorität:** sub_OB_Objekt_Positionen zuerst überarbeiten, dann die anderen 3 Formulare parallel verbessern.
