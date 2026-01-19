# CHECKLIST: Manuelle Clickthrough-Tests fuer Datumsfelder

**Erstellt:** 2026-01-07
**Agent:** Agent 5 - Datumsfelder/Zeitraumfilter
**Ziel:** Systematische manuelle Pruefung aller Datumsfelder und Zeitraumfilter

---

## VORAUSSETZUNGEN

- [ ] API-Server gestartet (Port 5000)
- [ ] Access-Backend erreichbar
- [ ] Browser mit DevTools geoeffnet (F12)
- [ ] Test-Zeitraum festgelegt (z.B. 01.01.2026 - 31.01.2026)

---

## 1. AUFTRAGSTAMM (frm_va_Auftragstamm.html)

**Pfad:** `forms3/frm_va_Auftragstamm.html`

### 1.1 Einzelne Datumsfelder

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Dat_VA_Von normal | 15.01.2026 eingeben | Feld speichert, Einsatztage werden angezeigt | [ ] |
| Dat_VA_Von leer | Datum loeschen, Tab druecken | Kein Fehler, Feld bleibt leer | [ ] |
| Dat_VA_Bis normal | 20.01.2026 eingeben | Feld speichert, Auftrag neu geladen | [ ] |
| Dat_VA_Bis leer | Datum loeschen | Kein Fehler | [ ] |

### 1.2 Zeitraum-Validierung (KRITISCH - FEHLT!)

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Von > Bis | Von=20.01., Bis=15.01. | SOLL: Fehlermeldung, IST: ? | [ ] |
| Von = Bis | Gleiche Daten | Eintaegiger Auftrag wird erstellt | [ ] |

### 1.3 Datumsnavigation (cboVADatum)

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Links-Pfeil | Bei Mehrtagesauftrag klicken | Vorheriger Tag wird angezeigt | [ ] |
| Rechts-Pfeil | Bei Mehrtagesauftrag klicken | Naechster Tag wird angezeigt | [ ] |
| Dropdown-Auswahl | Tag aus Dropdown waehlen | Schichten fuer diesen Tag laden | [ ] |

### 1.4 Auftraege-Filter

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Auftraege_ab setzen | 01.01.2026 waehlen | Liste zeigt nur Auftraege ab Datum | [ ] |
| Auftraege_ab leer | Datum loeschen | Alle Auftraege werden angezeigt | [ ] |

---

## 2. DIENSTPLANUEBERSICHT (frm_N_Dienstplanuebersicht.html)

**Pfad:** `forms3/frm_N_Dienstplanuebersicht.html`

### 2.1 Startdatum

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Startdatum setzen | 13.01.2026 waehlen | 7-Tage-Grid zeigt 13.-19.01. | [ ] |
| Doppelklick | Auf dtStartdatum doppelklicken | Datepicker oeffnet sich | [ ] |
| Heute-Button | btn_Heute klicken | Startdatum = heute | [ ] |
| +2 Button | btnVor klicken | 2 Tage vorwaerts | [ ] |
| -2 Button | btnrueck klicken | 2 Tage zurueck | [ ] |

### 2.2 localStorage-Persistenz

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Speicherung | Datum setzen, Formular schliessen | localStorage enthaelt prp_Dienstpl_StartDatum | [ ] |
| Wiederherstellung | Formular neu oeffnen | Letztes Datum ist vorgewaehlt | [ ] |

### 2.3 Enddatum (readonly)

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Berechnung | Startdatum aendern | Enddatum = Startdatum + 6 Tage | [ ] |
| Readonly | Auf Enddatum klicken | Feld ist nicht editierbar | [ ] |

---

## 3. ABWESENHEITSPLANUNG (frmTop_MA_Abwesenheitsplanung.html)

**Pfad:** `forms3/frmTop_MA_Abwesenheitsplanung.html`

### 3.1 Zeitraum von/bis

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Normaler Zeitraum | Von=01.01., Bis=05.01. | Berechnung zeigt 5 Tage | [ ] |
| Von > Bis | Von=10.01., Bis=05.01. | Fehlermeldung "Von-Datum muss vor Bis-Datum liegen" | [ ] |
| Nur Werktage | Checkbox aktivieren | Wochenenden werden ausgeschlossen | [ ] |

### 3.2 Teilzeit (Zeit von/bis)

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Teilzeit aktivieren | Radio "Teilzeit" waehlen | Zeit-Felder werden editierbar | [ ] |
| Zeit eingeben | Von=08:00, Bis=12:00 | Zeiten werden in Vorschau angezeigt | [ ] |

---

## 4. MA ABWESENHEIT (frm_MA_Abwesenheit.html)

**Pfad:** `forms3/frm_MA_Abwesenheit.html`

### 4.1 Abwesenheitszeitraum

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Von-Datum setzen | 01.02.2026 waehlen | Wochentag wird angezeigt (lblDatVonTag) | [ ] |
| Bis-Datum setzen | 05.02.2026 waehlen | Wochentag wird angezeigt (lblDatBisTag) | [ ] |
| Kalender-Highlight | Datumsbereich waehlen | Kalender zeigt Markierung | [ ] |

### 4.2 Datensatz-Anzeige

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Bestehenden Datensatz laden | In Liste klicken | Von/Bis werden in Feldern angezeigt | [ ] |
| Neuer Datensatz | Neu-Button klicken | Felder sind leer | [ ] |

---

## 5. ZEITKONTEN (frm_MA_Zeitkonten.html)

**Pfad:** `forms3/frm_MA_Zeitkonten.html`

### 5.1 Zeitraum-Dropdown (cboZeitraum)

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Aktueller Monat (8) | Auswahl in Dropdown | Von=01., Bis=letzter Tag des Monats | [ ] |
| Vormonat (9) | Auswahl in Dropdown | Von/Bis zeigt Vormonat | [ ] |
| Aktuelles Quartal (14) | Auswahl in Dropdown | Von=Quartalsanfang, Bis=Quartalsende | [ ] |
| Aktuelles Jahr (11) | Auswahl in Dropdown | Von=01.01., Bis=31.12. | [ ] |
| Letztes Jahr (12) | Auswahl in Dropdown | Von/Bis Vorjahr | [ ] |

### 5.2 Manuelle Datumsaenderung

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| AU_von aendern | Manuell Datum eingeben | Daten werden neu geladen | [ ] |
| AU_bis aendern | Manuell Datum eingeben | Daten werden neu geladen | [ ] |

### 5.3 Buttons mit Zeitraum

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Einsaetze uebertragen FA | Zeitraum waehlen, Button klicken | Bestaetigung mit Von/Bis Datum | [ ] |
| Einsaetze uebertragen MJ | Zeitraum waehlen, Button klicken | Bestaetigung mit Von/Bis Datum | [ ] |

---

## 6. STUNDENAUSWERTUNG (frm_N_Stundenauswertung.html)

**Pfad:** `forms3/frm_N_Stundenauswertung.html`

### 6.1 Zeitraum-Filter

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| cboZeitraum | Vormonat waehlen | AU_von/AU_bis werden aktualisiert | [ ] |
| AU_von BeforeUpdate | Datum aendern | Daten werden gefiltert | [ ] |
| AU_bis BeforeUpdate | Datum aendern | Daten werden gefiltert | [ ] |

---

## 7. EINSATZUEBERSICHT (frm_Einsatzuebersicht.html)

**Pfad:** `forms3/frm_Einsatzuebersicht.html`

### 7.1 Datumsfilter

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Von-Datum setzen | 01.01.2026 | Liste zeigt Einsaetze ab Datum | [ ] |
| Bis-Datum setzen | 31.01.2026 | Liste zeigt Einsaetze bis Datum | [ ] |
| Zurueck-Button | << klicken | Zeitraum verschiebt sich nach hinten | [ ] |
| Vor-Button | >> klicken | Zeitraum verschiebt sich nach vorne | [ ] |

### 7.2 Schnellfilter

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Heute | Button klicken | Von=Bis=heute | [ ] |
| Diese Woche | Button klicken | Von=Montag, Bis=Sonntag | [ ] |
| Dieser Monat | Button klicken | Von=1., Bis=letzter Tag | [ ] |

---

## 8. MITARBEITERSTAMM (frm_MA_Mitarbeiterstamm.html)

**Pfad:** `forms3/frm_MA_Mitarbeiterstamm.html`

### 8.1 Datums-Stammdaten

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Geburtsdatum | Datum eingeben | Speicherung erfolgreich | [ ] |
| Eintrittsdatum | Datum eingeben | Speicherung erfolgreich | [ ] |
| Austrittsdatum | Datum eingeben (optional) | Speicherung erfolgreich | [ ] |
| Ausweis_Endedatum | Datum eingeben | Speicherung erfolgreich | [ ] |
| Letzte_Ueberpr_OA | Datum eingeben | Speicherung erfolgreich | [ ] |

### 8.2 Zeitraum fuer Stundenanzeige

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| cboZeitraum aendern | Dieser Monat waehlen | Stundenanzeige aktualisiert | [ ] |

---

## 9. KUNDENSTAMM (frm_KD_Kundenstamm.html)

**Pfad:** `forms3/frm_KD_Kundenstamm.html`

### 9.1 Auftraege-Filter

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| datAuftraegeVon | 01.01.2026 | Auftraege werden gefiltert | [ ] |
| datAuftraegeBis | 31.12.2026 | Auftraege werden gefiltert | [ ] |

### 9.2 Ansprechpartner-Geburtstag

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| adr_Geburtstag | Datum eingeben | Speicherung erfolgreich | [ ] |
| Null-Wert | Datum loeschen | Kein Fehler, null wird gespeichert | [ ] |

---

## 10. BEWERBER (frm_N_Bewerber.html)

**Pfad:** `forms3/frm_N_Bewerber.html`

### 10.1 Bewerber-Daten

| Test | Schritte | Erwartung | OK? |
|------|----------|-----------|-----|
| Geburtsdatum | Datum eingeben | Speicherung erfolgreich | [ ] |
| Eingangsdatum | Datum eingeben | Speicherung erfolgreich | [ ] |

---

## EDGE-CASE TESTS (ALLE FORMULARE)

### Leere Datumsfelder

| Formular | Feld | Test | Erwartung | OK? |
|----------|------|------|-----------|-----|
| Auftragstamm | Dat_VA_Von | Leer lassen | Kein JS-Fehler | [ ] |
| Dienstplan | dtStartdatum | Leer lassen | Fallback auf heute | [ ] |
| Abwesenheit | DatVon | Leer berechnen | Fehlermeldung "Datum waehlen" | [ ] |

### Ungueltige Datumseingabe

| Formular | Feld | Test | Erwartung | OK? |
|----------|------|------|-----------|-----|
| Alle | date-Inputs | 32.01.2026 | Native Browser-Validierung | [ ] |
| Alle | date-Inputs | 30.02.2026 | Native Browser-Validierung | [ ] |

### Jahreswechsel

| Formular | Feld | Test | Erwartung | OK? |
|----------|------|------|-----------|-----|
| Auftragstamm | Von/Bis | 28.12.2025 - 03.01.2026 | Korrekte Tagesberechnung | [ ] |
| Dienstplan | Startdatum | 30.12.2025 | Grid zeigt korrekten Wochenuebergang | [ ] |

### Schaltjahr

| Formular | Feld | Test | Erwartung | OK? |
|----------|------|------|-----------|-----|
| Alle | Geburtsdatum | 29.02.2024 | Wird akzeptiert (2024=Schaltjahr) | [ ] |
| Alle | Geburtsdatum | 29.02.2025 | Browser verhindert Eingabe (kein Schaltjahr) | [ ] |

---

## BROWSER-KOMPATIBILITAET

| Browser | Version | Getestet | Ergebnis |
|---------|---------|----------|----------|
| Chrome | 120+ | [ ] | |
| Edge | 120+ | [ ] | |
| Firefox | 120+ | [ ] | |

---

## BEKANNTE PROBLEME / NOTIZEN

| Formular | Problem | Beschreibung | Prioritaet |
|----------|---------|--------------|------------|
| Auftragstamm | Keine Validierung | Von > Bis wird nicht geprueft | HOCH |
| Dienstplan | Keine Validierung | Ungueltige Daten moegen Fehler verursachen | MITTEL |
| Einsatzuebersicht | Keine Validierung | Von > Bis wird nicht geprueft | MITTEL |

---

## ZUSAMMENFASSUNG

| Kategorie | Gesamt | Bestanden | Fehlgeschlagen | Nicht getestet |
|-----------|--------|-----------|----------------|----------------|
| Einzelne Datumsfelder | 35 | | | |
| Zeitraum-Filter | 15 | | | |
| Edge-Cases | 12 | | | |
| Gesamt | 62 | | | |

---

**Tester:** _______________
**Datum:** _______________
**Signatur:** _______________
