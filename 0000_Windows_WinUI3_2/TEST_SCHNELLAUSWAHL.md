# Test-Protokoll: Schnellauswahl-Seite

## Vorbereitung
- [ ] WinUI3-App kompiliert (`dotnet build -p:Platform=x64`)
- [ ] Access-Backend verfügbar: `S:\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb`
- [ ] Verbindungsstring in `appsettings.json` korrekt

---

## Test 1: Navigation zur Schnellauswahl

**Schritte**:
1. App starten
2. Im linken Menü: "Schnellauswahl" klicken

**Erwartetes Ergebnis**:
- [ ] Seite lädt ohne Fehler
- [ ] Titel: "Schnellauswahl"
- [ ] VA-ComboBox ist leer (Placeholder: "Auftrag waehlen...")
- [ ] Filter-Bereich sichtbar
- [ ] Alle Listen leer

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Bemerkungen**:
```
_____________________________________________________________________
```

---

## Test 2: Auftrag-Auswahl laden

**Schritte**:
1. In Schnellauswahl-Seite
2. VA-ComboBox aufklappen

**Erwartetes Ergebnis**:
- [ ] Liste wird geladen (ProgressRing sichtbar)
- [ ] Aufträge erscheinen im Format: "DD.MM.YYYY   Auftrag   Objekt   Ort"
- [ ] Nur zukünftige Aufträge (ab heute)

**SQL-Query** (zur Verifikation):
```sql
SELECT DISTINCT a.ID AS VA_ID, d.ID AS VADatum_ID,
       FORMAT(d.VADatum, 'dd.MM.yyyy') + '   ' + a.Auftrag + '   ' + a.Objekt + '   ' + a.Ort AS DisplayText,
       d.VADatum
FROM tbl_VA_Auftragstamm a
INNER JOIN tbl_VA_AnzTage d ON a.ID = d.VA_ID
INNER JOIN qry_tbl_Start_proTag s ON d.VA_ID = s.VA_ID AND d.ID = s.VADatum_ID
WHERE d.VADatum >= CAST(GETDATE() AS DATE)
ORDER BY d.VADatum
```

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl Aufträge geladen**: _______

**Bemerkungen**:
```
_____________________________________________________________________
```

---

## Test 3: Datum-Auswahl reagiert auf VA-Änderung

**Schritte**:
1. VA-ComboBox: Auftrag auswählen
2. Datum-ComboBox aufklappen

**Erwartetes Ergebnis**:
- [ ] Datum-ComboBox wird automatisch gefüllt
- [ ] Datumsformat: "DD.MM.YYYY"
- [ ] Nur Daten für den ausgewählten Auftrag
- [ ] Erstes Datum automatisch ausgewählt

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl Daten**: _______

---

## Test 4: Zeiten-Liste wird geladen

**Schritte**:
1. VA + Datum ausgewählt
2. Zeiten-Liste (links) prüfen

**Erwartetes Ergebnis**:
- [ ] Schichten erscheinen mit Format: "HH:MM - HH:MM"
- [ ] Ist/Soll-Anzeige rechts (z.B. "2 / 5")
- [ ] Footer zeigt "Gesamt MA: X"
- [ ] Erste Zeit automatisch ausgewählt

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl Schichten**: _______
**Gesamt MA**: _______

---

## Test 5: Auftrag-Info-Banner erscheint

**Schritte**:
1. VA + Datum + Zeit ausgewählt
2. Blauen Banner prüfen (Zeile 2)

**Erwartetes Ergebnis**:
- [ ] Banner ist sichtbar (Visibility=Visible)
- [ ] Zeigt Auftragname
- [ ] Zeigt Objektname
- [ ] Zeigt Schichtzeit (HH:MM - HH:MM)
- [ ] Statistik: "Benoetigt: X | Zugeordnet: Y | Fehlt: Z"

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Werte**:
- Benötigt: _______
- Zugeordnet: _______
- Fehlt: _______

---

## Test 6: Verfügbare Mitarbeiter laden

**Schritte**:
1. VA + Datum + Zeit ausgewählt
2. Liste "Verfügbare Mitarbeiter" (Mitte) prüfen

**Erwartetes Ergebnis**:
- [ ] MA werden geladen
- [ ] Format: "Nachname, Vorname | Tel"
- [ ] Nur aktive MA (Filter "Nur Aktive" = true)
- [ ] Nur verfügbare MA (nicht verplant am selben Tag)

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl verfügbare MA**: _______

---

## Test 7: Filter "Nur Aktive" funktioniert

**Schritte**:
1. Verfügbare MA geladen (z.B. 20 MA)
2. Checkbox "Nur Aktive" deaktivieren
3. Beobachten

**Erwartetes Ergebnis**:
- [ ] Liste wird neu geladen (ProgressRing)
- [ ] Mehr MA erscheinen (inkl. inaktive)
- [ ] Status: "X verfuegbare Mitarbeiter"

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl mit Filter**: _______
**Anzahl ohne Filter**: _______

---

## Test 8: Suche funktioniert

**Schritte**:
1. Im Suchfeld "Müller" eingeben
2. Beobachten (UpdateSourceTrigger=PropertyChanged → Live-Filter)

**Erwartetes Ergebnis**:
- [ ] Liste wird sofort gefiltert (ohne Button-Klick)
- [ ] Nur MA mit "Müller" im Nachnamen oder Vornamen
- [ ] Bei leerem Suchfeld: Alle wieder anzeigen

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl Treffer für "Müller"**: _______

---

## Test 9: MA zuordnen (Einzeln)

**Schritte**:
1. Verfügbare MA: Einen MA anklicken (z.B. "Schmidt, Hans")
2. Button "Zuordnen" (Pfeil rechts) klicken
3. Beobachten

**Erwartetes Ergebnis**:
- [ ] Loading-Indicator erscheint kurz
- [ ] MA verschwindet aus "Verfügbare MA"
- [ ] MA erscheint in "Geplante Mitarbeiter" (rechts)
- [ ] Statistik aktualisiert sich (Zugeordnet +1)
- [ ] Status: "Schmidt Hans zugeordnet" (grün)

**SQL-Insert** (zur Verifikation in DB):
```sql
SELECT * FROM tbl_MA_VA_Planung
WHERE VA_ID = [ausgewählte VA]
  AND VADatum = [ausgewähltes Datum]
  AND MA_ID = [MA-ID von Schmidt]
```

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**MA-ID zugeordnet**: _______

---

## Test 10: MA zuordnen (Mehrfach)

**Schritte**:
1. Verfügbare MA: Mehrere MA auswählen (Strg+Klick)
   - Z.B. 3 Mitarbeiter
2. Button "Zuordnen" klicken

**Erwartetes Ergebnis**:
- [ ] Alle ausgewählten MA werden zugeordnet
- [ ] Statistik: Zugeordnet +3
- [ ] Status: "3 Mitarbeiter zugeordnet"

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl zugeordnet**: _______

---

## Test 11: MA entfernen (mit Bestätigung)

**Schritte**:
1. Geplante MA: Einen MA anklicken
2. Button "Entfernen" (Pfeil links) klicken
3. Bestätigungs-Dialog erscheint

**Erwartetes Ergebnis**:
- [ ] Dialog: "Moechten Sie [Name] von dieser Schicht entfernen?"
- [ ] Buttons: "Ja" / "Nein"
- [ ] Nach "Ja": MA wird entfernt
- [ ] MA erscheint wieder in "Verfügbare MA"
- [ ] Statistik aktualisiert sich (Zugeordnet -1)

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 12: Alle MA entfernen

**Schritte**:
1. Mehrere MA zugeordnet (z.B. 5)
2. Command: `AlleEntfernenAsync()` ausführen
   - Alternativ: Button implementieren und testen

**Erwartetes Ergebnis**:
- [ ] Bestätigung: "Alle 5 Mitarbeiter entfernen?"
- [ ] Nach "Ja": Alle MA werden entfernt
- [ ] Liste "Geplante Mitarbeiter" leer
- [ ] Statistik: Zugeordnet = 0

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 13: Parallele Einsätze anzeigen

**Schritte**:
1. Datum auswählen, an dem mehrere Aufträge stattfinden
2. Liste "Parallel-Einsätze" (links unten) prüfen

**Erwartetes Ergebnis**:
- [ ] Andere Aufträge am selben Tag erscheinen
- [ ] Format: "Auftrag - Objekt (Ort)"

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl parallele Einsätze**: _______

---

## Test 14: E-Mail-Vorschau (Test-Modus)

**Schritte**:
1. Mehrere MA zugeordnet
2. Button "E-Mail senden (Test)" klicken

**Erwartetes Ergebnis**:
- [ ] Dialog mit Zusammenfassung:
  - "TEST-MODUS: E-Mail würde an X Mitarbeiter gesendet werden"
  - Auftrag, Objekt, Datum, Zeit
  - Liste der MA mit Telefonnummern
- [ ] **Keine echte E-Mail wird gesendet!**

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 15: Aktualisieren-Button

**Schritte**:
1. In Schnellauswahl-Seite mit Daten
2. Button "Aktualisieren" (unten rechts) klicken

**Erwartetes Ergebnis**:
- [ ] Alle Listen werden neu geladen
- [ ] ProgressRing während Ladevorgang
- [ ] Daten aktualisiert (z.B. neue Zuordnungen von anderen Benutzern)

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 16: Schließen-Button (Navigation zurück)

**Schritte**:
1. In Schnellauswahl-Seite
2. Button "Schliessen" klicken

**Erwartetes Ergebnis**:
- [ ] Navigation zurück zur vorherigen Seite (z.B. Dashboard)
- [ ] NavigationService.NavigateBack() wird aufgerufen

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 17: Navigation von DienstplanObjektView

**Schritte**:
1. Navigation: "Dienstplan (Objekt)" öffnen
2. Schicht doppelklicken

**Erwartetes Ergebnis**:
- [ ] Schnellauswahl-Seite öffnet sich
- [ ] Parameter (VA_ID, Datum, Zeit) werden übergeben
- [ ] Auftrag + Datum + Zeit automatisch ausgewählt
- [ ] Daten geladen

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 18: Fehlerbehandlung - Keine Verbindung zur DB

**Schritte**:
1. Access-Backend umbenennen (Verbindung unterbrechen)
2. Schnellauswahl öffnen
3. VA-ComboBox aufklappen

**Erwartetes Ergebnis**:
- [ ] Fehler-Dialog: "Fehler beim Laden der Aufträge: [Message]"
- [ ] StatusMessage: "Fehler: [Message]" (rot)
- [ ] HasError = true
- [ ] App stürzt NICHT ab

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Test 19: Performance - Viele MA laden

**Schritte**:
1. Auftrag mit vielen verfügbaren MA auswählen (>100)
2. Zeit messen

**Erwartetes Ergebnis**:
- [ ] Loading < 2 Sekunden
- [ ] UI bleibt reaktiv (ProgressRing animiert)
- [ ] Scrollen flüssig

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

**Anzahl MA**: _______
**Ladezeit**: _______ ms

---

## Test 20: Reaktivität - Filter-Kaskade

**Schritte**:
1. Verschiedene Filter schnell hintereinander ändern:
   - Anstellungsart wählen
   - Qualifikation wählen
   - "Nur 34a" aktivieren
   - Suchbegriff eingeben

**Erwartetes Ergebnis**:
- [ ] Jede Änderung triggert neues Laden
- [ ] Keine doppelten Requests
- [ ] Letzte Auswahl gewinnt (kein Race Condition)

**Status**: ⬜ Nicht getestet | ✅ Erfolgreich | ❌ Fehlgeschlagen

---

## Zusammenfassung

**Tests durchgeführt**: _____ / 20
**Erfolgreich**: _____
**Fehlgeschlagen**: _____
**Nicht getestet**: _____

**Kritische Fehler**:
```
_____________________________________________________________________
_____________________________________________________________________
```

**Bekannte Probleme**:
```
_____________________________________________________________________
_____________________________________________________________________
```

**Empfehlungen**:
```
_____________________________________________________________________
_____________________________________________________________________
```

---

## Datum & Tester

**Test durchgeführt am**: _________________
**Tester**: _________________
**Build-Version**: _________________
**Gesamt-Bewertung**: ⭐⭐⭐⭐⭐ (1-5 Sterne)

---

**Abschluss-Status**:
- [ ] **Produktionsreif** - Alle Tests erfolgreich
- [ ] **Fast fertig** - Kleine Korrekturen nötig
- [ ] **Größere Probleme** - Weitere Entwicklung erforderlich
- [ ] **Nicht funktionsfähig** - Grundlegende Fehler

**Nächste Schritte**:
```
_____________________________________________________________________
_____________________________________________________________________
```
