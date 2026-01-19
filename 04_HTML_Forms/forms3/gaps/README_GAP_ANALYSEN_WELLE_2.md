# Gap-Analysen Welle 2 - Übersicht

**Datum:** 2026-01-12
**Anzahl Formulare:** 4

---

## Zusammenfassung

Diese 4 Formulare wurden als zweite Welle analysiert. Sie unterscheiden sich in Komplexität, Priorität und Anwendungsfall deutlich voneinander.

---

## 1. frm_Kundenpreise_gueni

**Status:** HTML teilweise vorhanden (Grundgerüst mit Menü)
**Priorität:** ⚠️ MITTEL
**Typ:** Verwaltungsformular (Matrix-Style)

### Kurzbeschreibung
Verwaltung von kundenspezifischen Preisen für verschiedene Dienstleistungskategorien (Sicherheit, Leitung, Zuschläge, etc.). Matrix-artige Darstellung mit Inline-Editing.

### Hauptmerkmale
- 8 Preisfelder pro Kunde
- DblClick-Events (Funktion unklar)
- ReadOnly-Felder (Fahrtkosten, Sonstiges)
- Navigation zwischen Kunden

### Besonderheit
Kreuztabellen-ähnliche Struktur → gut für Tabellen-basierte HTML-Umsetzung.

### Aufwand
**6-10 Stunden** (ohne DblClick-Funktion)

### Empfehlung
- Erst nach Hauptformularen
- Als Tabelle mit allen Kunden (effizienter als Access-SingleForm)
- Inline-Editing für schnelle Änderungen

---

## 2. frm_MA_Maintainance

**Status:** HTML nicht vorhanden
**Priorität:** ⭕ NIEDRIG
**Typ:** Admin-Tool (komplex, VBA-lastig)

### Kurzbeschreibung
Administratives Wartungs-Tool für Mitarbeiter-Zuordnungen. Ermöglicht Bulk-Operationen wie MA_ID-Änderung und Neuberechnung von Jahreswerten.

### Hauptmerkmale
- Bulk-Update von MA_ID in Zuordnungen
- Neuberechnung von Überlaufstunden (sehr komplex!)
- Temp-Tabellen für Änderungs-Buffer
- Fehler-Log-Verwaltung

### Besonderheit
**Sehr komplexe VBA-Logik** mit vielen Abhängigkeiten:
- `VA_AnzTage_Maintainance`
- `Ueberlaufstd_Berech_Neu(Jahr, Monat, [MA_ID])`
- `RL34a_pro_Std(MA_ID)` (Custom-Funktion)

### Aufwand
**30+ Stunden** (realistisch) wegen VBA-Port-Komplexität

### Empfehlung
**❌ NICHT portieren!**
- Access-Original beibehalten
- Selten genutzt, zu komplex
- VBA-Bridge wäre nötig für kritische Operationen
- Fokus auf produktive Formulare

---

## 3. frm_Zeiterfassung

**Status:** HTML nicht vorhanden
**Priorität:** 🔥 HOCH
**Typ:** Echtzeit-Erfassung (produktiv, täglich genutzt)

### Kurzbeschreibung
Stempeluhr-ähnliche Zeiterfassung für Mitarbeiter. QR-Code-Scan für schnelles Ein-/Auschecken auf Einsätzen.

### Hauptmerkmale
- QR-Code-Scanner (Personal-ID)
- Automatische Rundung auf Viertelstunden
- Drei Listen: Nicht eingecheckt / Eingecheckt / Ausgecheckt
- Ungeplante Check-Ins möglich
- Sound- und Visual-Feedback

### Besonderheit
**Tablet-optimiert, Echtzeit-Anforderung**
- Große Touch-Targets
- Schnelle Response-Zeit
- Offline-Fähigkeit evtl. erforderlich

### Aufwand
**15-22 Stunden** (ohne Offline-Support)

### Empfehlung
**✅ HOHE PRIORITÄT!**
- Produktiv genutzt (täglich)
- HTML ideal für Tablet-Nutzung
- Ersetzt manuelle Zeitzettel
- Phase 1-4 priorisieren (Basis + UX)
- Offline-Support später (optional)

---

## 4. frm_Umsatzuebersicht_2

**Status:** HTML Placeholder vorhanden
**Priorität:** ⚠️ MITTEL
**Typ:** Statistik/Reporting (Dashboard-Style)

### Kurzbeschreibung
Umsatzübersicht mit Rechnungsdaten, Kunden, Veranstaltungen. Ideal für Management-Dashboard mit Charts.

### Hauptmerkmale
- 14 Datenfelder (Datum, Kunde, Umsatz-Kategorien, etc.)
- SplitForm-View in Access (Formular + Tabelle)
- Filter nach Jahr, Kunde
- Aggregation (Summen)

### Besonderheit
**Sollte in HTML Chart-basiert sein:**
- KPI-Cards (Gesamt, Durchschnitt, Anzahl)
- Balkendiagramm (Umsatz pro Monat)
- Top-10-Kunden (Ranking)
- Excel-Export

### Aufwand
**10-15 Stunden** (mit Charts)

### Empfehlung
**✅ GUTER KANDIDAT für HTML:**
- HTML bietet Mehrwert durch Charts
- Interaktive Filter
- Responsive Dashboard
- Aber: Erst nach Hauptformularen
- Quick-Win: Tabelle ohne Charts zuerst (Phase 1-2)

---

## Priorisierungs-Matrix

| Formular | Priorität | Aufwand | Status HTML | Empfehlung |
|----------|-----------|---------|-------------|------------|
| frm_Zeiterfassung | 🔥 HOCH | 15-22h | ❌ Fehlt | ✅ JA - sofort nach Hauptformularen |
| frm_Umsatzuebersicht_2 | ⚠️ MITTEL | 10-15h | 🟡 Placeholder | ✅ JA - aber Phase 1-2 zuerst |
| frm_Kundenpreise_gueni | ⚠️ MITTEL | 6-10h | 🟡 Teilweise | ⚙️ SPÄTER - nach Top-Prioritäten |
| frm_MA_Maintainance | ⭕ NIEDRIG | 30+h | ❌ Fehlt | ❌ NEIN - Access beibehalten |

---

## Empfohlene Reihenfolge

### Phase 1: Hauptformulare (bereits in Arbeit)
1. frm_va_Auftragstamm
2. frm_MA_Mitarbeiterstamm
3. frm_KD_Kundenstamm
4. frm_OB_Objekt

### Phase 2: Produktive Zusatzformulare
5. **frm_Zeiterfassung** (täglich genutzt, Echtzeit)
6. frm_VA_Planungsuebersicht (Planung)
7. frm_N_Dienstplanuebersicht (Dienstplan)

### Phase 3: Statistik & Reporting
8. **frm_Umsatzuebersicht_2** (Management-Dashboard)
9. frm_Kundenpreise_gueni (Preisverwaltung)

### Phase 4: Admin-Tools (evtl. nicht portieren)
10. frm_MA_Maintainance (Access beibehalten)

---

## Technologie-Stack

### Frontend
- **HTML5** + CSS3
- **Vanilla JavaScript** (oder leichtes Framework)
- **Chart.js** (für Umsatzübersicht)
- **Responsive Design** (Tablet-optimiert für Zeiterfassung)

### Backend
- **Python Flask** (api_server.py)
- **SQLite/Access ODBC** (bestehende Datenbank)
- **RESTful API** (JSON)

### Optional
- **Service Worker** (Offline-Support für Zeiterfassung)
- **IndexedDB** (Offline-Queue)
- **SheetJS** (Excel-Export)

---

## Risiken und Herausforderungen

### frm_Zeiterfassung
- **Echtzeit-Performance** (viele gleichzeitige Check-Ins)
- **Tablet-Browser-Kompatibilität**
- **QR-Scanner-Hardware-Integration**
- **Offline-Fähigkeit** (falls WLAN ausfällt)

### frm_Umsatzuebersicht_2
- **Große Datenmengen** (100-1000+ Rechnungen)
- **Chart-Performance** (viele Datenpunkte)
- **Excel-Export mit Formatierung**

### frm_Kundenpreise_gueni
- **Matrix-Layout** (viele Spalten → Horizontal Scrolling?)
- **Inline-Editing Performance** (viele Felder)
- **DblClick-Funktion unklar** (kein VBA-Code im Export)

### frm_MA_Maintainance
- **Komplexe VBA-Logik** (schwer zu portieren)
- **Temp-Tabellen** (Access-spezifisch)
- **Custom-Funktionen** (nur in VBA vorhanden)

---

## Nächste Schritte

1. **Priorisierung mit User besprechen**
   - Ist Zeiterfassung täglich im Einsatz?
   - Wird Umsatzübersicht vom Management gebraucht?
   - Wie oft wird MA_Maintainance genutzt?

2. **Hardware-Anforderungen klären**
   - Welche Tablets für Zeiterfassung?
   - QR-Scanner-Typ? (USB, Bluetooth, Camera)
   - WLAN-Zuverlässigkeit am Einsatzort?

3. **API-Entwicklung starten**
   - Zeiterfassung-Endpoints (Check-In/Out)
   - Umsatz-Statistik-Endpoints
   - Kundenpreise-Endpoints

4. **Prototyp bauen**
   - Zeiterfassung: Basis-UI mit Check-In/Out
   - Umsatzübersicht: Tabelle mit Filter (ohne Charts)
   - User-Feedback einholen

---

## Kontakt & Fragen

Bei Fragen zu den Gap-Analysen:
- Siehe Detail-Dateien in `gaps/`
- Jede Analyse enthält:
  - Datenquelle & Query-Definition
  - Control-Mapping (Access → HTML)
  - VBA-Logik-Analyse
  - API-Anforderungen
  - Implementierungs-Roadmap
  - Offene Fragen

**Erstellt:** 2026-01-12
**Autor:** Claude Code (Gap-Analyse Welle 2)
