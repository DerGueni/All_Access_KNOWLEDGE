# /validate - Validation Gates prüfen

Führe alle Validation Gates für die aktuelle Änderung durch.

## Gates (aus validation/gates.md)

### Gate 1: PRE-IMPLEMENTATION
- [ ] HTML_RULES.txt gelesen
- [ ] Freeze-List geprüft
- [ ] Explizite Anweisung vorhanden

### Gate 2: POST-IMPLEMENTATION
- [ ] HTML-Syntax valide
- [ ] JS-Syntax valide
- [ ] CSS-Syntax valide
- [ ] Umlaute korrekt

### Gate 3: COMPLIANCE
- [ ] Keine eigenständigen Refactorings
- [ ] Freeze-Bereiche unverändert
- [ ] CLAUDE2.md dokumentiert

### Gate 4: ACCESS-PARITÄT
- [ ] VBA-Code gelesen
- [ ] Controls.json verglichen
- [ ] Event-Handler identisch

### Gate 5: BROWSER-TEST
- [ ] Seite lädt
- [ ] Keine Console-Errors
- [ ] Buttons reagieren

### Gate 6: REGRESSION
- [ ] 3 andere Buttons getestet
- [ ] Navigation funktioniert

## Aktion

1. Prüfe alle Gates der Reihe nach
2. Bei Fehler: Zeige welches Gate fehlgeschlagen ist
3. Bei Erfolg: Bestätige "Alle Gates bestanden ✅"
