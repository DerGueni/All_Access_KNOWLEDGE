# Gap-Analyse Batch 3: Abwesenheiten & Popup-Formulare

**Datum:** 2026-01-12
**Anzahl Formulare:** 8
**Kategorie:** Abwesenheiten (2) + Popup-Formulare (6)

---

## 1. Übersicht aller Formulare

| # | Formular | Typ | Status | Priorität | Aufwand |
|---|----------|-----|--------|-----------|---------|
| 1 | frm_Abwesenheiten | Abwesenheitsverwaltung | ✅ 95% | MITTEL | 2-4h |
| 2 | frm_abwesenheitsuebersicht | Kalender-View | ⚠️ 80% | HOCH | 4-6h |
| 3 | frmTop_DP_MA_Auftrag_Zuo | MA-Zuordnung (Popup) | ⚠️ 60% | HOCH | 6-8h |
| 4 | frmTop_Geo_Verwaltung | PLZ-Verwaltung (Popup) | ❌ 0% | NIEDRIG | 1 Tag |
| 5 | frmTop_KD_Adressart | Adressarten (Popup) | ❌ 0% | SEHR NIEDRIG | 4h |
| 6 | frmTop_MA_Abwesenheitsplanung | Abw.-Berechnung (Popup) | ⚠️ 85% | MITTEL | 6-8h |
| 7 | frmTop_VA_Akt_Objekt_Kopf | Objektkopf (Popup) | ❌ 0% | SEHR NIEDRIG | 3-5 Tage |
| 8 | frmOff_Outlook_aufrufen | E-Mail (Popup) | ⚠️ 70% | HOCH | 2-3 Tage |

**Legende:**
- ✅ Weitgehend fertig (>90%)
- ⚠️ Teilweise fertig (50-90%)
- ❌ Nicht implementiert (<50%)

---

## 2. Abwesenheiten-Formulare (2 Stück)

### 2.1 frm_Abwesenheiten ✅
**Status:** 95% FERTIG
**Bewertung:** HTML ist BESSER als Access!

**Stärken:**
- Modernes Datasheet + Sidebar
- Vollständige CRUD-Operationen
- Filter (MA, Zeitraum) - Access hat das nicht!
- Navigation-Buttons

**Verbesserungsbedarf:**
- Logic-Datei prüfen/vervollständigen
- API-Tests durchführen
- Validierung verstärken

**Empfehlung:** Produktionsreif nach 2-4 Stunden Testing!

---

### 2.2 frm_abwesenheitsuebersicht ⚠️
**Status:** 80% FERTIG (als Kalender-View)
**Bewertung:** HTML ist MODERN, aber anderer Zweck als Access!

**Stärken:**
- Moderne Kalender-Matrix (Access: Tabelle)
- Farbcodierung nach Abwesenheitsgrund
- Wochenenden hervorgehoben
- Filter (Monat/Jahr/Abteilung)

**Unterschiede zu Access:**
- Access: Nichtverfügbarkeiten IM KONTEXT von Dienstplänen (zeigt auch Zuordnungen)
- HTML: Reiner Abwesenheitskalender (nur Urlaub/Krank)

**Kritische Frage:**
⚠️ **Welche Variante wird benötigt?**
- **Variante A:** Kalender-View (aktuell) → 4-6h Aufwand für Feinschliff
- **Variante B:** Dienstplan-Integration → 2-3 Tage Aufwand

**Empfehlung:** Entscheidung mit Nutzer klären!

---

## 3. Popup-Formulare (6 Stück)

### 3.1 frmTop_DP_MA_Auftrag_Zuo (MA-Zuordnung) ⚠️
**Status:** 60% FERTIG
**Priorität:** HOCH
**Aufwand:** 6-8 Stunden

**Stärken HTML:**
- Modernes Modal-Design
- Bessere MA-Filter/Suche
- Mehrfach-Auswahl
- Qualifikations-Anzeige

**Kritische Gaps:**
❌ **SHOWSTOPPER:**
- Auftragsliste fehlt (Access-Hauptfeature)
- Schichtenliste fehlt (Access-Hauptfeature)
- Statische Demo-Daten statt API

**Entscheidungsfrage:**
⚠️ **Wird Formular MIT vorgewählter Schicht aufgerufen?**
- **Option A:** Ja → 6-8h Aufwand (API + Logic)
- **Option B:** Nein → 2-3 Tage (Auftrag/Schicht-Listen hinzufügen)

**Empfehlung:** Workflow-Klärung DRINGEND erforderlich!

---

### 3.2 frmTop_Geo_Verwaltung (PLZ-Verwaltung) ❌
**Status:** NICHT IMPLEMENTIERT (0%)
**Priorität:** NIEDRIG
**Aufwand:** 1 Tag

**Grund:** PLZ-Stammdaten werden selten geändert

**Empfehlung:**
- Niedrige Priorität
- Alternative: CSV-Import statt interaktivem Formular
- Erst bei Bedarf implementieren

---

### 3.3 frmTop_KD_Adressart (Adressarten) ❌
**Status:** NICHT IMPLEMENTIERT (0%)
**Priorität:** SEHR NIEDRIG
**Aufwand:** 4 Stunden

**Grund:** Nur 3-5 Einträge, quasi statisch

**Empfehlung:**
- Sehr niedrige Priorität
- Alternative: Direkt in Access-Backend pflegen
- Nur bei explizitem Bedarf implementieren

---

### 3.4 frmTop_MA_Abwesenheitsplanung (Abw.-Berechnung) ⚠️
**Status:** 85% FERTIG
**Priorität:** MITTEL
**Aufwand:** 6-8 Stunden

**Stärken HTML:**
- Alle Access-Features vorhanden
- Modernes 2-Spalten-Layout
- Client-seitige Berechnung (schneller)
- Loading-Overlay, Toast-Notifications

**Kritische Prüfung erforderlich:**
⚠️ **Berechnungslogik MUSS getestet werden:**
- Werktags-Berechnung korrekt?
- Teilzeit-Logik funktional?
- API-Integration (Bulk-Insert)?

**Empfehlung:** Gründliche Tests erforderlich, dann produktionsreif!

---

### 3.5 frmTop_VA_Akt_Objekt_Kopf (Objektkopf) ❌
**Status:** NICHT IMPLEMENTIERT (0%)
**Priorität:** SEHR NIEDRIG
**Aufwand:** 3-5 Tage

**Grund:**
- Sehr spezifisches Feature (Objektkopf + Absperrzeit)
- Nur für bestimmte Event-Typen relevant
- Hoher Implementierungs-Aufwand (2 SubForms!)

**Empfehlung:**
- Im Access-Backend belassen
- Nur bei explizitem Bedarf umsetzen

---

### 3.6 frmOff_Outlook_aufrufen (E-Mail) ⚠️
**Status:** 70% FERTIG
**Priorität:** HOCH
**Aufwand:** 2-3 Tage

**Stärken HTML:**
- Modernes Layout (3-Spalten)
- Vollbild-Modus
- Bessere MA-Auswahl

**Kritische Gaps:**
❌ **SHOWSTOPPER:**
1. **Kunden-Liste fehlt** (Access-Hauptfeature!)
2. **Auftragsbezug fehlt** (NEU in Access - lädt MA-E-Mails automatisch)
3. **Empfangsbestätigung fehlt**
4. **Filter eingeschränkt**
5. **Bridge-Funktionalität ungeklärt** (Kann WebView2 Bridge Outlook COM ansprechen?)

**Empfehlung:**
- Kunden-Liste DRINGEND hinzufügen
- Auftragsbezug implementieren
- Bridge-Tests durchführen
- Alternativ: Server-seitiges E-Mail-System (SMTP) statt Outlook-Bridge

---

## 4. Priorisierung nach Aufwand/Nutzen

### Sofort umsetzen (Priorität 1)
1. **frm_Abwesenheiten** - 2-4h → Produktionsreif ✅
2. **frmOff_Outlook_aufrufen** - Kunden-Liste hinzufügen (1 Tag)
3. **frmTop_DP_MA_Auftrag_Zuo** - Workflow klären, dann 6-8h

### Kurzfristig (Priorität 2)
4. **frm_abwesenheitsuebersicht** - Zweck klären, dann 4-6h
5. **frmTop_MA_Abwesenheitsplanung** - Tests + Bugfixes (6-8h)

### Mittelfristig (Priorität 3)
6. **frmTop_Geo_Verwaltung** - Nur bei Bedarf (1 Tag)
7. **frmTop_KD_Adressart** - Sehr niedrige Priorität (4h)

### Niedrige Priorität
8. **frmTop_VA_Akt_Objekt_Kopf** - Im Access belassen (3-5 Tage Aufwand)

---

## 5. Kritische Entscheidungen erforderlich

### Entscheidung 1: frm_abwesenheitsuebersicht
**Frage:** Kalender-View ODER Dienstplan-Integration?
- Kalender-View: 4-6h Aufwand
- Dienstplan-Integration: 2-3 Tage Aufwand

### Entscheidung 2: frmTop_DP_MA_Auftrag_Zuo
**Frage:** Mit vorgewählter Schicht ODER Auftrag/Schicht selbst wählen?
- Mit Vorgabe: 6-8h Aufwand
- Ohne Vorgabe: 2-3 Tage Aufwand

### Entscheidung 3: frmOff_Outlook_aufrufen
**Frage:** Outlook-Bridge ODER Server-SMTP?
- Outlook-Bridge: 2-3 Tage Aufwand (+ Tests)
- Server-SMTP: 2-3 Tage Aufwand (neue Implementierung)

---

## 6. API-Gaps (Überblick)

### Vorhanden ✅
- `/api/mitarbeiter`
- `/api/abwesenheiten` (CRUD)
- `/api/kunden` (prüfen!)

### Fehlen ❌
- `/api/auftraege/offen` (für Zuordnung)
- `/api/schichten/verfuegbar` (für Zuordnung)
- `/api/schichten/:id/info` (Detail-Info)
- `/api/mitarbeiter/verfuegbar?schicht=X` (verfügbare MA)
- `/api/dienstplan/nichtverfuegbar` (für Abw.-Übersicht)
- `/api/email/templates` (E-Mail-Vorlagen)
- `/api/plz` (PLZ-Verwaltung)
- `/api/adressarten` (Adressarten)

---

## 7. Gesamtbewertung

### Durchschnittlicher Fortschritt: 60%

**Gruppierung:**
- **Gut (>80%):** 2 Formulare (25%)
- **Mittel (50-80%):** 4 Formulare (50%)
- **Schlecht (<50%):** 2 Formulare (25%)

### Gesamtaufwand bis 100%:
- **Sofort:** 3-4 Tage (frm_Abwesenheiten, Outlook, MA-Zuordnung)
- **Kurzfristig:** 2-3 Tage (Abw.-Übersicht, Abw.-Planung)
- **Optional:** 5-7 Tage (Geo, Adressart, Objektkopf)

**Realistisch:** 5-7 Tage für produktionsreife Kernfunktionen

---

## 8. Nächste Schritte

### Phase 1 (Diese Woche)
1. ✅ frm_Abwesenheiten testen → Produktiv
2. ⚠️ Entscheidungen klären (Abw.-Übersicht, MA-Zuordnung, E-Mail)
3. ⚠️ Outlook-Bridge testen (funktioniert es?)

### Phase 2 (Nächste Woche)
4. Outlook: Kunden-Liste + Auftragsbezug
5. MA-Zuordnung: API + Logic implementieren
6. Abw.-Planung: Berechnungslogik testen

### Phase 3 (Optional)
7. Abw.-Übersicht: Zweck-Entscheidung umsetzen
8. Geo/Adressart: Nur bei Bedarf

---

## 9. Zusammenfassung

### ✅ Erfolgreich
- 2 Formulare weitgehend fertig (Abwesenheiten, Abw.-Planung)
- Moderne HTML-Umsetzung übertrifft Access in UX

### ⚠️ Kritisch
- 3 Formulare benötigen Entscheidungen (Workflow-Fragen)
- Outlook-Bridge muss getestet werden
- API-Gaps müssen geschlossen werden

### ❌ Niedrige Priorität
- 3 Formulare nicht implementiert (Stammdaten, selten genutzt)
- Können im Access-Backend bleiben

### 🎯 Gesamtbewertung
**Status:** 60% FERTIG
**Risiko:** MITTEL (Entscheidungen + Outlook-Bridge)
**Aufwand:** 5-7 Tage (Kernfunktionen)

**Fazit:** Batch 3 ist **GUT FORTGESCHRITTEN**, aber benötigt **ENTSCHEIDUNGEN** und **OUTLOOK-TESTS** für finale Produktionsreife! ⚠️
