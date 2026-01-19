# TESTPLAN - frm_MA_Mitarbeiterstamm Web-Migration

**Projekt:** Consys Mitarbeiterstamm Web-App
**Stand:** 2025-12-23 (ETAPPE 0)

---

## 1. Smoke Tests (nach ETAPPE 4)

### Backend
- [ ] Server startet ohne Fehler (`npm start`)
- [ ] DB-Connection erfolgreich (Frontend + Backend-DB)
- [ ] Health-Check: `GET /api/health` → 200 OK
- [ ] CRUD Mitarbeiter: `GET /api/mitarbeiter/707` → Daten von Ahmad
- [ ] Subform-Daten: `GET /api/mitarbeiter/707/ersatzemail` → Email-Liste

### Frontend
- [ ] Dev-Server startet (`npm run dev`)
- [ ] Hauptformular laeuft ohne JS-Errors
- [ ] Mitarbeiter 707 (Ahmad) laeuft
- [ ] Tab-Wechsel funktioniert (13 Tabs)
- [ ] Mindestens 1 Subform laedt (z.B. Menuefuehrung)

---

## 2. Layout-Tests (ETAPPE 2)

### Pixelgenauigkeit
- [ ] Screenshot-Overlay: Access vs. Web
  - Max. 2px Abweichung bei Controls
  - Farben identisch (RGB-Vergleich)
  - Fonts identisch (Familie, Groesse, Gewicht)
- [ ] Alle Controls sichtbar (keine Overlaps)
- [ ] Z-Order korrekt (Controls uebereinander)
- [ ] Tab-Reihenfolge identisch

### Tab-Control
- [ ] Alle 13 Tabs sichtbar
- [ ] Active-Tab-Styling identisch
- [ ] Tab-Wechsel funktioniert (onClick)
- [ ] Tab-Content laeuft korrekt

### Subforms
- [ ] Alle 12 Subforms rendern
- [ ] LinkMasterFields/LinkChildFields funktionieren
- [ ] Subform-Scrolling funktioniert
- [ ] Subform-Daten laden (API-Call)

### Responsive
- [ ] `transform: scale()` funktioniert
- [ ] Keine Layout-Breaks bei verschiedenen Viewports
- [ ] Mindestens 1920x1080 und 1366x768 getestet

---

## 3. Backend-Tests (ETAPPE 2)

### CRUD-Operationen
- [ ] `GET /api/mitarbeiter` - Liste aller MA
- [ ] `GET /api/mitarbeiter/707` - Einzelner MA (Ahmad)
- [ ] `POST /api/mitarbeiter` - Neuer MA (Testdaten)
- [ ] `PUT /api/mitarbeiter/707` - Update Ahmad (z.B. Vorname aendern)
- [ ] `DELETE /api/mitarbeiter/:testId` - Loeschen (Testdatensatz)

### Subform-Endpoints
- [ ] `GET /api/mitarbeiter/707/ersatzemail` - Email-Liste
- [ ] `POST /api/mitarbeiter/707/ersatzemail` - Neue Email
- [ ] `DELETE /api/ersatzemail/:id` - Email loeschen
- [ ] *(analog fuer weitere Subforms testen)*

### Query-Endpoints
- [ ] `GET /api/queries/qryBildname?ma_id=707` - Parametrisierte Query
- [ ] Ergebnis-Format korrekt (JSON)

### Error-Handling
- [ ] 404 bei nicht existierendem MA
- [ ] 400 bei fehlenden Pflichtfeldern
- [ ] 500 bei DB-Fehlern (mit sinnvoller Error-Message)

---

## 4. Event-Tests (ETAPPE 3)

### Button-Events
- [ ] "Neuer Mitarbeiter" - Button funktioniert
- [ ] "Mapo oeffnen" - Button funktioniert (API-Call)
- [ ] "Zeitkonto drucken" - Button funktioniert
- [ ] *(weitere aus VBA-Analyse)*

### Form-Events
- [ ] OnLoad - Initialdaten laden
- [ ] OnCurrent - Record-Wechsel (z.B. MA 707 → MA 708)
- [ ] BeforeUpdate - Validierung vor Speichern

### Control-Events
- [ ] AfterUpdate - z.B. Nachname aendern → Validierung
- [ ] OnChange - Real-Time Input (z.B. PLZ-Format)
- [ ] OnDblClick - z.B. Foto-Vergrsserung

### Validierungen
- [ ] Pflichtfelder (Nachname, Vorname)
- [ ] Format-Checks (Email, PLZ, Tel)
- [ ] Datumsbereich-Checks (Geburtsdatum, Eintrittsdatum)

---

## 5. Integrations-Tests (ETAPPE 4)

### End-to-End: Mitarbeiter bearbeiten
1. [ ] Frontend laeuft + Backend laeuft
2. [ ] Mitarbeiter 707 (Ahmad) oeffnen
3. [ ] Vorname aendern: "Ahmad" → "Ahmed"
4. [ ] Speichern (PUT-Request)
5. [ ] Refresh: Aenderung persistent
6. [ ] Access-DB pruefen: Aenderung auch dort

### End-to-End: Subform bearbeiten
1. [ ] Tab "Einsatzuebersicht" oeffnen
2. [ ] Subform "sub_MA_Einsatz_Zuo" laeurt
3. [ ] Neuen Einsatz hinzufuegen
4. [ ] Speichern (POST-Request)
5. [ ] Subform-Refresh: Neuer Einsatz sichtbar

### End-to-End: VBA-Action
1. [ ] Button "Mapo oeffnen" klicken
2. [ ] API-Call: `POST /api/mitarbeiter/707/actions/mapo-oeffnen`
3. [ ] Backend fuehrt VBA-Logik aus (z.B. PDF generieren)
4. [ ] Frontend zeigt Erfolgs-/Fehler-Message

---

## 6. Visual Regression Tests (Optional)

### Screenshot-Vergleich
- [ ] Playwright/Puppeteer: Automatische Screenshots
- [ ] Pixel-by-Pixel Diff (z.B. mit `pixelmatch`)
- [ ] Abweichungen dokumentieren in `docs/VISUAL_DIFF.md`

---

## 7. Performance-Tests (Optional)

### Ladezeiten
- [ ] Hauptformular: < 2s (Initial Load)
- [ ] Tab-Wechsel: < 500ms
- [ ] Subform-Laden: < 1s
- [ ] API-Response: < 300ms (durchschnittlich)

### Datenvolumen
- [ ] 1000+ Mitarbeiter: Liste laeuft (mit Pagination)
- [ ] Foto-Laden: < 500ms (Image Optimization?)

---

## 8. Fehler-Tracking

| Test | Status | Fehler | Fix | Verantwortlich |
|------|--------|--------|-----|----------------|
| Beispiel: Tab 3 laeuft nicht | FAIL | JS-Error in Console | Tab-Component debuggen | Instanz 2 |
| ... | ... | ... | ... | ... |

---

## 9. Abnahme-Kriterien (Quality Gates)

### ETAPPE 2 - Layout + Backend
- [ ] Mindestens 95% Layout-Matching (Screenshot-Overlay)
- [ ] Alle API-Endpoints funktionieren (Postman-Tests)
- [ ] Keine kritischen Bugs

### ETAPPE 3 - Events
- [ ] Alle Button-Events portiert + getestet
- [ ] Alle Validierungen portiert + getestet
- [ ] Keine kritischen Bugs

### ETAPPE 4 - Integration
- [ ] Mindestens 1 End-to-End-Szenario komplett
- [ ] Dokumentation vollstaendig (MAPPING.md, API_SPEC.md)
- [ ] Smoke-Tests bestanden

---

## 10. Test-Daten

### Mitarbeiter-Testdaten
- **MA 707 (Ahmad):** Haupt-Testfall (sichtbar im Screenshot)
- **MA NEU:** Neuer Mitarbeiter zum Testen von CREATE/DELETE

### DB-Snapshots
- [ ] Backup vor Tests: `C:\...\exports\DB_BACKUP_BEFORE_TESTS.bak`
- [ ] Restore nach Tests (falls noetig)

---

**WICHTIG:** Alle Tests muessen BESTANDEN sein, bevor das Projekt als "DONE" gilt!

**Testverantwortliche:** Orchestrator + alle Instanzen (jede Instanz testet ihre Deliverables)
