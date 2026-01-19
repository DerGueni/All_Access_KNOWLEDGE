# INTEGRATION TEST CHECKLIST - VBA-HTML Button Integration

**Erstellt:** 15.01.2026
**Zweck:** Manuelle Test-Checkliste für 3 Button-Integrationen

---

## VORBEDINGUNGEN (PFLICHT!)

### 1. Server-Status prüfen

```bash
# API Server (Port 5000) - MUSS laufen
curl http://localhost:5000/api/health
# Erwartete Antwort: {"status":"ok", ...}

# VBA Bridge Server (Port 5002) - MUSS laufen
curl http://localhost:5002/api/health
# Erwartete Antwort: {"status":"ok","port":5002, ...}
```

**Wenn Server nicht laufen:**
```bash
# API Server starten
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py

# VBA Bridge Server starten
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api"
python vba_bridge_server.py
```

### 2. Access-Frontend geöffnet

- [ ] `0_Consys_FE_Test.accdb` ist geöffnet
- [ ] Backend-Verbindung funktioniert
- [ ] VBA-Module sind kompiliert (Debug > Compile VBA Project)

### 3. Browser-Cache leeren

- [ ] Chrome/Edge: Strg+Shift+Entf → Cache leeren
- [ ] Oder: Formulare mit `?v=TIMESTAMP` öffnen

---

## TEST 1: frm_MA_VA_Schnellauswahl - Button "Anfragen"

**Formular:** Mitarbeiter-Auftragszuordnung (Schnellauswahl)
**Button:** "Anfragen" (oben rechts)
**Funktion:** E-Mail-Anfragen an ausgewählte Mitarbeiter senden

### Test-Szenarien

#### Szenario 1.1: Einzelner Mitarbeiter (Mit Auswahl)

**Schritte:**
1. [ ] Access: Formular `frm_MA_VA_Schnellauswahl` öffnen
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: Warten bis Formular geladen (Mitarbeiter-Liste sichtbar)
4. [ ] Browser: EINEN Mitarbeiter in der Liste anklicken (Checkbox aktivieren)
5. [ ] Browser: Button "Anfragen" oben rechts klicken

**Erwartetes Verhalten:**
- [ ] Toast-Nachricht erscheint: "E-Mail-Anfrage wird gesendet..."
- [ ] Nach 2-3 Sekunden: "E-Mail-Anfrage erfolgreich gesendet an X Mitarbeiter"
- [ ] Browser-Console: Keine Fehlermeldungen (F12 > Console)
- [ ] Access: Outlook öffnet sich mit E-Mail-Entwurf für 1 Empfänger

**Zu prüfende Daten:**
- [ ] Betreff: "Anfrage für Auftrag: [VA-Nummer] - [Objekt] am [Datum]"
- [ ] Empfänger: E-Mail-Adresse des ausgewählten Mitarbeiters
- [ ] Text: Enthält VA-Nummer, Datum, Uhrzeit, Objekt

#### Szenario 1.2: Mehrere Mitarbeiter (Mit Auswahl)

**Schritte:**
1. [ ] Access: Formular `frm_MA_VA_Schnellauswahl` öffnen
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: 3-5 Mitarbeiter auswählen (Checkboxen aktivieren)
4. [ ] Browser: Button "Anfragen" klicken

**Erwartetes Verhalten:**
- [ ] Toast: "E-Mail-Anfrage erfolgreich gesendet an X Mitarbeiter" (X = Anzahl)
- [ ] Access: Outlook mit E-Mail für alle X Empfänger

#### Szenario 1.3: OHNE Auswahl (Alle Mitarbeiter)

**Schritte:**
1. [ ] Access: Formular `frm_MA_VA_Schnellauswahl` öffnen
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: KEINE Mitarbeiter auswählen (alle Checkboxen leer)
4. [ ] Browser: Button "Anfragen" klicken

**Erwartetes Verhalten:**
- [ ] Toast: "E-Mail-Anfrage erfolgreich gesendet an X Mitarbeiter" (X = alle)
- [ ] Access: Outlook mit E-Mail für ALLE Mitarbeiter in der Liste

#### Szenario 1.4: Fehlerfall - Keine Daten

**Schritte:**
1. [ ] Access: Formular `frm_MA_VA_Schnellauswahl` öffnen OHNE Auftrag
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: Button "Anfragen" klicken

**Erwartetes Verhalten:**
- [ ] Toast: Fehlermeldung "Fehlende Daten: VA_ID, VADatum_ID oder VAStart_ID"
- [ ] KEIN Outlook-Fenster

---

## TEST 2: frm_MA_Serien_eMail_Auftrag - Button "Mail senden"

**Formular:** Serien-E-Mail für Aufträge
**Button:** "Mail senden" (oben rechts)
**Funktion:** E-Mail an alle Mitarbeiter eines Auftrags senden

### Test-Szenarien

#### Szenario 2.1: Einzelner Auftrag

**Schritte:**
1. [ ] Access: Formular `frm_MA_Serien_eMail_Auftrag` öffnen
2. [ ] Access: Auftrag auswählen (mit Mitarbeiter-Zuordnungen)
3. [ ] Access: Button "HTML-Ansicht" klicken
4. [ ] Browser: Warten bis Formular geladen (Mitarbeiter-Liste sichtbar)
5. [ ] Browser: Button "Mail senden" oben rechts klicken

**Erwartetes Verhalten:**
- [ ] Toast: "Serien-E-Mail wird gesendet..."
- [ ] Nach 2-3 Sekunden: "E-Mails erfolgreich gesendet an X Mitarbeiter"
- [ ] Browser-Console: Keine Fehlermeldungen
- [ ] Access: Outlook mit E-Mail für alle Mitarbeiter des Auftrags

**Zu prüfende Daten:**
- [ ] Betreff: Enthält Auftragsnummer
- [ ] Empfänger: Alle Mitarbeiter mit E-Mail-Adresse
- [ ] Text: Enthält Auftragsinformationen

#### Szenario 2.2: Auftrag ohne Mitarbeiter

**Schritte:**
1. [ ] Access: Formular öffnen mit Auftrag OHNE Mitarbeiter
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: Button "Mail senden" klicken

**Erwartetes Verhalten:**
- [ ] Toast: "Keine Mitarbeiter für diesen Auftrag gefunden"
- [ ] KEIN Outlook-Fenster

---

## TEST 3: frm_MA_Serien_eMail_dienstplan - Button "Mail senden"

**Formular:** Serien-E-Mail für Dienstplan
**Button:** "Mail senden" (oben rechts)
**Funktion:** E-Mail an alle Mitarbeiter im Dienstplan senden

### Test-Szenarien

#### Szenario 3.1: Dienstplan mit Mitarbeitern

**Schritte:**
1. [ ] Access: Formular `frm_MA_Serien_eMail_dienstplan` öffnen
2. [ ] Access: Dienstplan-Zeitraum auswählen (mit Mitarbeitern)
3. [ ] Access: Button "HTML-Ansicht" klicken
4. [ ] Browser: Warten bis Formular geladen (Mitarbeiter-Liste sichtbar)
5. [ ] Browser: Button "Mail senden" oben rechts klicken

**Erwartetes Verhalten:**
- [ ] Toast: "Serien-E-Mail wird gesendet..."
- [ ] Nach 2-3 Sekunden: "E-Mails erfolgreich gesendet an X Mitarbeiter"
- [ ] Browser-Console: Keine Fehlermeldungen
- [ ] Access: Outlook mit E-Mail für alle Mitarbeiter im Dienstplan

**Zu prüfende Daten:**
- [ ] Betreff: Enthält Dienstplan-Zeitraum
- [ ] Empfänger: Alle Mitarbeiter des Dienstplans
- [ ] Text: Enthält Dienstplan-Informationen

#### Szenario 3.2: Zeitraum ohne Einsätze

**Schritte:**
1. [ ] Access: Formular öffnen mit leerem Zeitraum
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: Button "Mail senden" klicken

**Erwartetes Verhalten:**
- [ ] Toast: "Keine Mitarbeiter im Dienstplan gefunden"
- [ ] KEIN Outlook-Fenster

---

## DATEN-SYNCHRONISATION TESTS

### Test 4.1: Access → HTML (Initiales Laden)

**Schritte:**
1. [ ] Access: Formular mit bekannten Daten öffnen (z.B. VA_ID = 12345)
2. [ ] Access: Button "HTML-Ansicht" klicken
3. [ ] Browser: F12 > Console öffnen

**Zu prüfen:**
- [ ] Console: `[Debug] Empfangene Parameter: VA_ID=12345, ...`
- [ ] Mitarbeiter-Liste lädt korrekt
- [ ] Alle Daten aus Access sind sichtbar (Auftragsnummer, Datum, etc.)

### Test 4.2: HTML → Access → Outlook (Button-Click)

**Schritte:**
1. [ ] Browser: Formular geöffnet, Button klicken
2. [ ] Browser: F12 > Network-Tab beobachten
3. [ ] Access: VBA Editor > Direktfenster öffnen (Strg+G)

**Zu prüfen:**
- [ ] Network: POST zu `http://localhost:5002/api/vba/anfragen`
- [ ] Response: Status 200, JSON mit `success: true`
- [ ] VBA Direktfenster: Keine Fehlermeldungen
- [ ] Outlook: E-Mail-Entwurf erscheint

### Test 4.3: Fehlerfall - VBA Bridge offline

**Schritte:**
1. [ ] VBA Bridge Server STOPPEN (Strg+C im Terminal)
2. [ ] Browser: Formular öffnen, Button klicken

**Erwartetes Verhalten:**
- [ ] Toast: "Fehler beim Senden: Verbindung zum VBA-Server fehlgeschlagen"
- [ ] Console: `Failed to fetch` oder `Network error`
- [ ] KEIN Outlook-Fenster

### Test 4.4: Fehlerfall - Access geschlossen

**Schritte:**
1. [ ] Access SCHLIESSEN (VBA Bridge läuft noch)
2. [ ] Browser: Formular öffnen, Button klicken

**Erwartetes Verhalten:**
- [ ] Toast: "Fehler: Access ist nicht geöffnet"
- [ ] Response: `access_connected: false`
- [ ] KEIN Outlook-Fenster

---

## API-ENDPOINT TESTS (CURL)

### Endpoint 1: Schnellauswahl-Anfragen

```bash
# Test: Anfragen mit Auswahl
curl -X POST http://localhost:5002/api/vba/anfragen \
  -H "Content-Type: application/json" \
  -d "{\"VA_ID\":12345,\"VADatum_ID\":67890,\"VAStart_ID\":111,\"MA_IDs\":[1,2,3],\"selectedOnly\":true}"

# Erwartete Antwort:
# {"success":true,"message":"E-Mail-Anfrage erfolgreich gesendet","count":3}
```

### Endpoint 2: Serien-E-Mail Auftrag

```bash
# Test: Serien-E-Mail für Auftrag
curl -X POST http://localhost:5002/api/vba/execute \
  -H "Content-Type: application/json" \
  -d "{\"function\":\"MA_Serien_eMail_Auftrag_Send\",\"args\":[12345]}"

# Erwartete Antwort:
# {"success":true,"result":"E-Mails gesendet"}
```

### Endpoint 3: Serien-E-Mail Dienstplan

```bash
# Test: Serien-E-Mail für Dienstplan
curl -X POST http://localhost:5002/api/vba/execute \
  -H "Content-Type: application/json" \
  -d "{\"function\":\"MA_Serien_eMail_Dienstplan_Send\",\"args\":[\"2026-01-01\",\"2026-01-31\"]}"

# Erwartete Antwort:
# {"success":true,"result":"E-Mails gesendet"}
```

### Endpoint 4: Health-Check

```bash
# Test: Server-Status
curl http://localhost:5002/api/health

# Erwartete Antwort:
# {"status":"ok","port":5002,"service":"vba-bridge"}

# Test: VBA-Status
curl http://localhost:5002/api/vba/status

# Erwartete Antwort:
# {"access_open":true,"access_connected":true,"frontend":"0_Consys_FE_Test.accdb"}
```

---

## BROWSER-CONSOLE CHECKS

### Normale Ausführung (Erfolg)

**Erwartete Console-Logs:**
```
[Debug] Empfangene Parameter: VA_ID=12345, VADatum_ID=67890, VAStart_ID=111
[Debug] MA-Lookup geladen: 25 Mitarbeiter
[Debug] Button Anfragen geklickt
[Debug] Ausgewählte MA-IDs: [1, 2, 3]
[Debug] API-Request: POST http://localhost:5002/api/vba/anfragen
[Debug] API-Response: {"success":true,"message":"...","count":3}
Toast: E-Mail-Anfrage erfolgreich gesendet an 3 Mitarbeiter
```

### Fehlerfall (Netzwerk)

**Erwartete Console-Logs:**
```
[Error] API-Request fehlgeschlagen: Failed to fetch
Toast: Fehler beim Senden: Verbindung zum VBA-Server fehlgeschlagen
```

### Fehlerfall (Keine Daten)

**Erwartete Console-Logs:**
```
[Warning] Fehlende Parameter: VA_ID=undefined
Toast: Fehlende Daten: VA_ID, VADatum_ID oder VAStart_ID
```

---

## PERFORMANCE CHECKS

### Ladezeit-Messung

**Schritte:**
1. [ ] Browser: F12 > Network-Tab
2. [ ] Access: HTML-Ansicht öffnen
3. [ ] Network: "Disable cache" aktivieren
4. [ ] Seite neu laden (F5)

**Zu prüfen:**
- [ ] Initiales HTML: < 500ms
- [ ] API `/api/mitarbeiter`: < 1000ms
- [ ] Gesamtladezeit: < 2000ms
- [ ] Keine 404-Fehler (fehlende Ressourcen)

### Button-Response-Zeit

**Schritte:**
1. [ ] Browser: Console öffnen
2. [ ] Button klicken
3. [ ] Zeit messen bis Toast erscheint

**Zu prüfen:**
- [ ] Toast "wird gesendet": < 200ms
- [ ] Toast "erfolgreich": < 3000ms
- [ ] Outlook öffnet: < 5000ms

---

## EDGE-CASES (Grenzfälle)

### Edge-Case 1: Sonderzeichen in Daten

**Schritte:**
1. [ ] Access: Auftrag mit Umlauten (ä, ö, ü) und Sonderzeichen (&, ", ')
2. [ ] HTML-Ansicht öffnen, Button klicken

**Zu prüfen:**
- [ ] Umlaute korrekt angezeigt
- [ ] Sonderzeichen escaped (keine JSON-Fehler)
- [ ] E-Mail-Text korrekt

### Edge-Case 2: Sehr viele Mitarbeiter (>100)

**Schritte:**
1. [ ] Auftrag mit >100 Mitarbeitern
2. [ ] HTML-Ansicht öffnen, Button klicken

**Zu prüfen:**
- [ ] Keine Timeout-Fehler
- [ ] Alle Mitarbeiter in E-Mail
- [ ] Performance akzeptabel (<10 Sekunden)

### Edge-Case 3: Mitarbeiter ohne E-Mail

**Schritte:**
1. [ ] Auftrag mit Mitarbeitern OHNE E-Mail-Adresse
2. [ ] Button klicken

**Zu prüfen:**
- [ ] Toast: Warnung "X Mitarbeiter ohne E-Mail-Adresse übersprungen"
- [ ] E-Mail nur an Mitarbeiter mit E-Mail

### Edge-Case 4: Parallele Clicks (Doppelklick)

**Schritte:**
1. [ ] Button SCHNELL 2x hintereinander klicken

**Zu prüfen:**
- [ ] Nur EINE E-Mail wird gesendet
- [ ] Button ist während Verarbeitung disabled
- [ ] Keine doppelten Toasts

---

## REGRESSION TESTS (Nach Code-Änderungen)

### Nach VBA-Änderungen

- [ ] VBA kompiliert ohne Fehler
- [ ] Alle 3 Formulare öffnen in Access
- [ ] Alle 3 Buttons testen (je 1 Szenario)

### Nach HTML-Änderungen

- [ ] Browser-Cache leeren
- [ ] Alle 3 Formulare neu laden
- [ ] Alle 3 Buttons testen

### Nach API-Änderungen

- [ ] Server neu starten
- [ ] Health-Check erfolgreich
- [ ] Alle 3 Endpoint-Tests erfolgreich

---

## FEHLER-LOG (Bei Problemen)

**Datum:** _________________
**Formular:** _________________
**Szenario:** _________________

**Fehlerbeschreibung:**
_______________________________________________________
_______________________________________________________

**Console-Logs:**
_______________________________________________________
_______________________________________________________

**VBA-Fehler:**
_______________________________________________________
_______________________________________________________

**API-Response:**
_______________________________________________________
_______________________________________________________

---

## SIGNOFF (Nach erfolgreichem Test)

- [ ] Alle 3 Buttons funktionieren
- [ ] Alle Szenarien getestet
- [ ] Keine kritischen Fehler
- [ ] Performance akzeptabel
- [ ] Dokumentation vollständig

**Getestet von:** _________________
**Datum:** _________________
**Unterschrift:** _________________

---

**Ende der Checkliste**
