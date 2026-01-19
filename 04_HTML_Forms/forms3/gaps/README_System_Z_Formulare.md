# Gap-Analysen: System- und Z-Formulare - Übersicht

**Datum:** 2026-01-12
**Batch:** 6 Formulare (3 System + 3 Z-Formulare)

---

## Executive Summary

Diese Gap-Analysen decken **System- und Z-Formulare** ab - Spezialformulare für Diagnostics, Navigation und Support-Funktionen. Die meisten dieser Formulare haben **niedrige Priorität**, da sie nicht geschäftskritisch sind.

### Gesamtübersicht

| Formular | Typ | HTML vorhanden? | Umsetzungsgrad | Priorität | Aufwand |
|----------|-----|----------------|----------------|-----------|---------|
| **frm_Systeminfo** | System | ✅ Ja (minimal) | 25% | Niedrig | 8h |
| **frm_Menuefuehrung1** | Navigation | ✅ Ja (UI komplett) | 80% UI, 30% funktional | Hoch | 68h |
| **frm_Startmenue** | Navigation | ❌ Nein | 0% | Niedrig | 6h (oder 0h = nicht umsetzen) |
| **zfrm_MA_Stunden_Lexware** | Lohn | ✅ Ja (UI only) | 40% UI, 0% funktional | Hoch | 90h (oder in Access belassen) |
| **zfrm_Rueckmeldungen** | Statistik | ✅ Ja (Platzhalter) | 10% | Niedrig | 16h |
| **zfrm_SyncError** | Support | ✅ Ja (Platzhalter) | 10% | Niedrig | 14h |

**Gesamtaufwand (vollständige Umsetzung):** 202 Stunden
**Gesamtaufwand (empfohlene Umsetzung):** 96 Stunden (ohne Lexware + Startmenue)

---

## 1. System-Formulare (3)

### 1.1 frm_Systeminfo - Systeminfo/Diagnostics

**Status:** ⚠️ Teilweise (25%)

**Beschreibung:** Zeigt System-, Hardware- und Datenbank-Informationen an.

**HTML vorhanden?** ✅ Ja (stark vereinfacht)

**Kernproblem:**
- Viele Access-spezifische Windows-APIs (CPU, RAM, Laufwerke) sind in Web-Browsern **aus Sicherheitsgründen nicht verfügbar**

**Was funktioniert:**
- ✅ Browser-Informationen (User-Agent, Plattform, Sprache)
- ✅ Bildschirmauflösung
- ✅ API-Server-Status

**Was fehlt:**
- ❌ Windows-Version (exakt)
- ❌ CPU-Name/Geschwindigkeit
- ❌ RAM-Größe (exakt)
- ❌ Laufwerks-Informationen
- ❌ Backend-Datenbank-Infos

**Empfehlung:**
- ✅ **Phase 1+2 umsetzen** (5h) → Backend-Infos + erweiterte Browser-Infos
- ⚠️ Rest als "Web-Limitierung" dokumentieren
- ⭐⭐ **Priorität: Niedrig**

**Aufwand:** 8 Stunden (Phase 1-4, ohne Hardware-APIs)
**Endgültiger Umsetzungsgrad:** 60% (web-relevante Features)

---

### 1.2 frm_Menuefuehrung1 - Hauptmenü/Navigation

**Status:** ⚠️ UI komplett (80%), funktional teilweise (30%)

**Beschreibung:** Seiten-Menü für Personal-, Lohn- und Sync-Funktionen.

**HTML vorhanden?** ✅ Ja (Popup-Overlay mit allen Buttons)

**Kernproblem:**
- Viele Ziel-Formulare fehlen noch oder sind nicht vollständig umgesetzt
- Reports können nicht 1:1 übernommen werden (Access-spezifisch)
- Excel-Export und Sync-Prozesse fehlen

**Was funktioniert:**
- ✅ UI/Layout (alle Buttons, Gruppen, Farben)
- ✅ Popup-Overlay-Mechanik
- ✅ Links zu existierenden Formularen (Lohnabrechnungen, Abwesenheiten)

**Was fehlt:**
- ❌ 3 Report-Buttons (Letzter Einsatz, FCN, Namensliste)
- ❌ Excel-Export-Button
- ❌ 2 Sync-Buttons
- ❌ 6 unbekannte Buttons (Captions/Ziele unbekannt)

**Empfehlung:**
- ✅ **Phase 1-4 umsetzen** (38h) → Alle kritischen Funktionen
- ⚠️ Sync-Prozesse nur bei Bedarf (48h zusätzlich)
- ⭐⭐⭐⭐ **Priorität: Hoch** (Haupt-Navigation)

**Aufwand:** 68 Stunden (Phase 1-4 + Reports)
**Minimalaufwand:** 38 Stunden (ohne Reports/Sync)
**Endgültiger Umsetzungsgrad:** 90% (nach Phase 1-4)

---

### 1.3 frm_Startmenue - Startmenü

**Status:** ❌ Nicht vorhanden (0%)

**Beschreibung:** Grafisches Hauptmenü mit 4 großen Buttons (Personalverwaltung, Auftragsverwaltung, Disposition, Hauptmenü).

**HTML vorhanden?** ❌ Nein

**Kernproblem:**
- In moderner Web-App ist grafisches Startmenü **unüblich und unnötig**
- Shell-Sidebar ersetzt Startmenü vollständig

**Empfehlung:**
- ❌ **NICHT umsetzen** (empfohlen)
- Shell.html als Landing Page verwenden
- ⭐ **Priorität: Niedrig** (nicht erforderlich)

**Begründung:**
1. Shell-Sidebar ersetzt Startmenü komplett
2. Kein Mehrwert - ein zusätzlicher Klick ohne Funktion
3. Unüblich in modernen Web-Apps
4. Aufwand 6h besser in fehlende Geschäftslogik investieren

**Aufwand:** 6 Stunden (falls doch gewünscht) ODER 0 Stunden (nicht umsetzen)
**Endgültiger Umsetzungsgrad:** 0% (und das ist in Ordnung ✅)

---

## 2. Z-Formulare (3)

### 2.1 zfrm_MA_Stunden_Lexware - Lexware Stunden Import/Export

**Status:** ⚠️ UI vorhanden (40%), funktional nicht (0%)

**Beschreibung:** Zentral für Lohnabrechnung: Importiert Zeitkonto-Daten aus Excel, zeigt Abgleich mit Consys-Stunden, exportiert Lexware-Importdateien.

**HTML vorhanden?** ✅ Ja (Toolbar + Tabs, aber keine Funktionalität)

**Kernproblem:**
- Excel-COM-Interop (öffnen, lesen, schreiben) ist in Web **extrem komplex**
- Zeitkonto-Fortschreibung ist sehr aufwändig (20h pro Anstellungsart)

**Was funktioniert:**
- ✅ UI-Layout (Toolbar, Tabs, Filter)

**Was fehlt (KRITISCH):**
- ❌ Daten-Laden (Abgleich, Stunden, Importfehler)
- ❌ Filter-Funktionalität
- ❌ Lexware-Export (.txt)
- ❌ Excel-Import (Zeitkonten)
- ❌ Zeitkonto-Fortschreibung (Excel schreiben)

**Empfehlung:**
- ⚠️ **Phase 1-4 umsetzen** (38h) → Abgleich + Export funktionsfähig
- ❌ **Phase 5 NICHT umsetzen** (52h) → ZK-Fortschreibung in Access belassen
- **ODER:** Gesamtes Formular in Access belassen (Hybrid-Ansatz)
- ⭐⭐⭐⭐ **Priorität: Hoch** (kritisch für Lohnabrechnung)

**Aufwand:** 90 Stunden (vollständig) ODER 38 Stunden (ohne ZK-Fortschreibung)
**Alternative:** ❌ In Access belassen (0h Aufwand)
**Endgültiger Umsetzungsgrad:** 80% (Phase 1-4, ohne ZK-Fortschreibung)

**Spezielle Empfehlung:** Dieses Formular ist ein Kandidat für **Hybrid-Ansatz** - kritische Excel-Funktionen bleiben in Access, Rest in HTML.

---

### 2.2 zfrm_Rueckmeldungen - Rückmeldungen

**Status:** ❌ Platzhalter (10%)

**Beschreibung:** Zeigt Rückmelde-Statistiken der Mitarbeiter an (z.B. Zu-/Absagen auf Anfragen).

**HTML vorhanden?** ✅ Ja (Platzhalter-Seite)

**Kernproblem:**
- VBA-Funktion `Rückmeldeauswertung` ist **nicht im Export enthalten**
- Query `zqry_Rueckmeldungen` nicht dokumentiert
- Daten-Struktur unbekannt

**Was fehlt (ALLES):**
- ❌ Daten-Laden (VBA-Funktion unbekannt)
- ❌ Tabellen-Anzeige
- ❌ Query-Definition
- ❌ Daten-Struktur

**Empfehlung:**
- ⚠️ **Phase 1 KRITISCH** (2h) → VBA-Funktion in Access finden und analysieren
- ⚠️ **Danach Phase 2-3** (12h) → API + HTML-Tabelle umsetzen
- **ODER:** In Access belassen (falls wenig genutzt)
- ⭐⭐ **Priorität: Niedrig** (Reporting/Statistik)

**Aufwand:** 16 Stunden (falls umgesetzt)
**Alternative:** ❌ In Access belassen (0h Aufwand)
**Endgültiger Umsetzungsgrad:** 90% (nach Analyse + Umsetzung) ODER 0% (nicht umsetzen)

---

### 2.3 zfrm_SyncError - Synchronisations-Fehler

**Status:** ❌ Platzhalter (10%)

**Beschreibung:** Zeigt Synchronisationsfehler an (z.B. bei Löwensaal-Sync).

**HTML vorhanden?** ✅ Ja (Platzhalter-Seite)

**Kernproblem:**
- Eingebettetes Makro (Button-Funktion) ist **nicht im Export enthalten**
- Subformular `zsub_syncerror` nicht dokumentiert
- Daten-Struktur unbekannt

**Was fehlt (ALLES):**
- ❌ Daten-Laden (Sync-Fehler aus ztbl_sync)
- ❌ Fehler-Tabelle
- ❌ Button-Funktionen (Löschen, Behoben markieren)
- ❌ Makro-Inhalt unbekannt

**Empfehlung:**
- ⚠️ **Phase 1 KRITISCH** (2h) → Daten-Struktur in Access analysieren
- ⚠️ **Danach Phase 2-3** (12h) → API + HTML-UI umsetzen
- **ODER:** In Access belassen (falls nur von Admins genutzt)
- ⭐ **Priorität: Niedrig** (Support/Diagnostics)

**Aufwand:** 14 Stunden (falls umgesetzt)
**Alternative:** ❌ In Access belassen (0h Aufwand) ODER Log-Datei statt Formular
**Endgültiger Umsetzungsgrad:** 95% (nach Analyse + Umsetzung) ODER 0% (nicht umsetzen)

---

## 3. Priorisierungs-Matrix

### 3.1 Nach Priorität

| Priorität | Formular | Aufwand | Empfehlung |
|-----------|----------|---------|------------|
| ⭐⭐⭐⭐⭐ | **frm_Menuefuehrung1** | 68h (oder 38h minimal) | ✅ Umsetzen (Phase 1-4) |
| ⭐⭐⭐⭐ | **zfrm_MA_Stunden_Lexware** | 90h (oder 38h minimal) | ⚠️ Teilweise umsetzen ODER in Access belassen |
| ⭐⭐ | **frm_Systeminfo** | 8h | ⚠️ Phase 1-2 umsetzen (5h) |
| ⭐⭐ | **zfrm_Rueckmeldungen** | 16h | ❌ In Access belassen |
| ⭐ | **zfrm_SyncError** | 14h | ❌ In Access belassen ODER Log-Datei |
| ⭐ | **frm_Startmenue** | 6h | ❌ NICHT umsetzen |

### 3.2 Nach Aufwand (niedrig → hoch)

| Formular | Aufwand | Umsetzungsgrad aktuell | Nutzen |
|----------|---------|----------------------|--------|
| **frm_Startmenue** | 0h (nicht umsetzen) | 0% | Nicht erforderlich |
| **frm_Systeminfo** | 8h | 25% | Niedrig |
| **zfrm_SyncError** | 14h | 10% | Niedrig (nur Admins) |
| **zfrm_Rueckmeldungen** | 16h | 10% | Niedrig (Reporting) |
| **frm_Menuefuehrung1** | 38h (minimal) - 68h (komplett) | 80% UI, 30% funktional | Sehr hoch (Navigation) |
| **zfrm_MA_Stunden_Lexware** | 38h (minimal) - 90h (komplett) | 40% UI, 0% funktional | Sehr hoch (Lohnabrechnung) |

---

## 4. Empfohlene Strategie

### Phase A: Kritische Navigation (SOFORT)

**1. frm_Menuefuehrung1** - Phase 1-2 umsetzen (44h)
- Button-Ziele dokumentieren (2h)
- Fehlende Formulare umsetzen (32h)
- Excel-Export MA-Stamm (4h)
- Reports als HTML-Tabelle (6h)

**Ergebnis:** Menü funktioniert vollständig (ohne Sync-Prozesse)
**Aufwand:** 44 Stunden
**Nutzen:** ⭐⭐⭐⭐⭐

### Phase B: Kritische Lohn-Funktion (ENTSCHEIDUNG)

**2. zfrm_MA_Stunden_Lexware** - Zwei Optionen:

**Option A: In HTML umsetzen (38h)**
- API-Endpoints (Daten laden): 8h
- Filter-Funktionalität: 6h
- Lexware-Export: 8h
- Excel-Import: 16h

**Option B: In Access belassen (0h)**
- Nur von Lohnbuchhaltung genutzt
- Excel-Interop zu komplex für Web
- Access-Version funktioniert zuverlässig

**Empfehlung:** ⚠️ **Hybrid-Ansatz** - Lexware-Formular in Access belassen, andere Lohn-Formulare in HTML.

### Phase C: System-Infos (OPTIONAL)

**3. frm_Systeminfo** - Phase 1-2 umsetzen (5h)
- Browser-Infos erweitern (1h)
- Backend-Infos via API (4h)

**Ergebnis:** Zeigt relevante System-Infos (OS, User, DB-Pfade)
**Aufwand:** 5 Stunden
**Nutzen:** ⭐⭐

### Phase D: Support-Formulare (NIEDRIG)

**4. zfrm_Rueckmeldungen** - ❌ **Nicht umsetzen**
- In Access belassen (nur für Reports)

**5. zfrm_SyncError** - ❌ **Nicht umsetzen**
- In Access belassen (nur für Admins)
- ODER: Log-Datei statt Formular

**6. frm_Startmenue** - ❌ **Nicht umsetzen**
- Shell.html als Landing Page verwenden

**Aufwand:** 0 Stunden
**Nutzen:** Kein Verlust (Access-Formulare bleiben verfügbar)

---

## 5. Gesamt-Aufwand

### Vollständige Umsetzung (NICHT empfohlen)

| Formular | Aufwand |
|----------|---------|
| frm_Systeminfo | 8h |
| frm_Menuefuehrung1 | 68h |
| frm_Startmenue | 6h |
| zfrm_MA_Stunden_Lexware | 90h |
| zfrm_Rueckmeldungen | 16h |
| zfrm_SyncError | 14h |
| **GESAMT** | **202 Stunden** |

### Empfohlene Umsetzung (Hybrid-Ansatz)

| Phase | Formulare | Aufwand |
|-------|-----------|---------|
| **A: Navigation** | frm_Menuefuehrung1 (Phase 1-2) | 44h |
| **B: Lohn** | zfrm_MA_Stunden_Lexware (in Access belassen) | 0h |
| **C: System** | frm_Systeminfo (Phase 1-2) | 5h |
| **D: Support** | Alle anderen (nicht umsetzen) | 0h |
| **GESAMT** | | **49 Stunden** |

**Ersparnis:** 153 Stunden (75% weniger Aufwand)

**Endgültiger Umsetzungsgrad (empfohlen):**
- **frm_Menuefuehrung1:** 90% (vollständig funktional)
- **frm_Systeminfo:** 60% (web-relevante Features)
- **Alle anderen:** 0% (in Access belassen oder nicht erforderlich)

---

## 6. Kritische Erkenntnisse

### 6.1 Web-Limitierungen (NICHT umsetzbar)

1. **Windows-APIs:**
   - CPU-Informationen
   - RAM-Details
   - Laufwerks-Informationen
   - Hardware-Specs

2. **Excel-COM-Interop:**
   - Direkter Excel-Zugriff (öffnen, schreiben, speichern)
   - Zeitkonto-Fortschreibung

3. **Access-Reports:**
   - Report-Engine (Letzter Einsatz, FCN, Namensliste)

### 6.2 Hybrid-Ansatz empfohlen

**Prinzip:** Kritische, schwer umsetzbare Funktionen bleiben in Access, Rest in HTML.

**Beispiele:**
- ✅ **HTML:** Navigation, Formulare, Stammdaten-Verwaltung
- ❌ **Access:** Lexware-Import/Export, Excel-Zeitkonten, Reports, Sync-Prozesse

**Vorteil:** Beste Kosten-Nutzen-Relation

### 6.3 Fehlende Dokumentation

**Kritisch:** Mehrere Formulare haben unvollständige Access-Exports:

1. **frm_Menuefuehrung1:** Button-Captions fehlen (Befehl22, btn_1, etc.)
2. **zfrm_Rueckmeldungen:** VBA-Funktion `Rückmeldeauswertung` nicht im Export
3. **zfrm_SyncError:** Eingebettetes Makro nicht exportiert

**Lösung:** Access-Datenbank öffnen, VBA-Editor nutzen, Makros/Funktionen dokumentieren.

---

## 7. Zusammenfassung

### Status nach Analysen

| Kategorie | Anzahl Formulare | HTML vorhanden | Funktional | Empfehlung |
|-----------|-----------------|----------------|------------|------------|
| **System-Formulare** | 3 | 2 / 3 | 1 / 3 | 1 umsetzen, 2 belassen |
| **Z-Formulare** | 3 | 3 / 3 (Platzhalter) | 0 / 3 | 0 umsetzen, 3 belassen |
| **GESAMT** | 6 | 5 / 6 | 1 / 6 | 1 umsetzen, 5 belassen/weglassen |

### Empfehlungen im Überblick

| Formular | Empfehlung | Aufwand | Begründung |
|----------|------------|---------|------------|
| **frm_Menuefuehrung1** | ✅ **Umsetzen** (Phase 1-2) | 44h | Kritische Navigation |
| **frm_Systeminfo** | ⚠️ **Teilweise** (Phase 1-2) | 5h | Nützlich für Diagnostics |
| **frm_Startmenue** | ❌ **Nicht umsetzen** | 0h | Nicht erforderlich (Shell ersetzt es) |
| **zfrm_MA_Stunden_Lexware** | ❌ **In Access belassen** | 0h | Zu komplex (Excel-Interop) |
| **zfrm_Rueckmeldungen** | ❌ **In Access belassen** | 0h | Niedrige Priorität (Reporting) |
| **zfrm_SyncError** | ❌ **In Access belassen** | 0h | Niedrige Priorität (Support) |

**Gesamt-Aufwand (empfohlen):** 49 Stunden
**Erwarteter Umsetzungsgrad (System/Z-Formulare):** 30% (aber kritischste Teile funktionsfähig)

---

## 8. Nächste Schritte

### Sofort (Woche 1-2)

1. ✅ **frm_Menuefuehrung1** - Phase 1 (2h)
   - Access öffnen, Button-Ziele dokumentieren
   - VBA-Code für alle Buttons extrahieren

2. ✅ **Entscheidung Lexware-Formular** (0h)
   - Mit Lohnbuchhaltung sprechen: HTML oder Access?
   - Falls Access: Hybrid-Ansatz dokumentieren

### Kurzfristig (Woche 3-6)

3. ✅ **frm_Menuefuehrung1** - Phase 2-3 (42h)
   - Fehlende Formulare umsetzen
   - Excel-Export
   - Reports als HTML-Tabelle

4. ⚠️ **frm_Systeminfo** - Phase 1-2 (5h)
   - Backend-Infos via API
   - Erweiterte Browser-Infos

### Langfristig (nach Batch 1-10)

5. ⚠️ **Neu-Evaluierung Support-Formulare**
   - Falls doch benötigt: zfrm_Rueckmeldungen/zfrm_SyncError umsetzen
   - Erst nach Feedback von Benutzern

---

## 9. Dateien

**Gap-Analysen erstellt:**

1. `GAP_frm_Systeminfo.md` - System-Informationen
2. `GAP_frm_Menuefuehrung1.md` - Hauptmenü/Navigation
3. `GAP_frm_Startmenue.md` - Startmenü (nicht vorhanden)
4. `GAP_zfrm_MA_Stunden_Lexware.md` - Lexware Import/Export
5. `GAP_zfrm_Rueckmeldungen.md` - Rückmeldungen (Platzhalter)
6. `GAP_zfrm_SyncError.md` - Sync-Fehler (Platzhalter)

**Alle Dateien in:** `04_HTML_Forms\forms3\gaps\`

---

**Ende der Analysen - System- und Z-Formulare**
