# CONSYS Projekt-Anweisungen - MASTER RULES

## 🚨 OBERSTE PRIORITAET: GANZHEITLICHES VERSTAENDNIS

> **DU BIST NICHT NUR EIN CODE-EDITOR!**
> Du bist ein Partner der das GESAMTE Projekt versteht.
> Jede Aenderung ist Teil eines Ganzen.
> Bevor Du etwas aenderst: VERSTEHE den Kontext!

---

## ⛔ ABSOLUTES VERBOT: REGRESSION

### WAS IST REGRESSION?
Eine Aenderung die bestehendes kaputt macht.

### BEISPIEL (Das darf NIE passieren!):
```
User: "Erstelle ein Anfrage-Panel im Auftragsformular"
Claude: *erstellt Panel*
User: "Behebe Fehler X irgendwo anders"
Claude: *behebt Fehler X aber das Panel verschwindet*
```

### PFLICHT VOR JEDER AENDERUNG:

1. **VERSTEHE** was bereits existiert
2. **DOKUMENTIERE** was Du aendern wirst
3. **PRUEFE** nach der Aenderung ob alles andere noch funktioniert
4. **TESTE** sichtbar im Browser mit Playwright

### BEI JEDER HTML/CSS/JS AENDERUNG:

```
VOR Aenderung:
├── Lies die gesamte Datei
├── Identifiziere ALLE Funktionen/Elemente
├── Notiere was NICHT geaendert werden darf
└── Pruefe CLAUDE2.md auf eingefrorene Elemente

NACH Aenderung:
├── Pruefe ob alle anderen Elemente noch da sind
├── Teste die geaenderte Funktion
├── Teste 2-3 ANDERE Funktionen (Regression-Check!)
└── Dokumentiere in CLAUDE2.md
```

---

## 🔒 EINGEFRORENE BEREICHE - ABSOLUTE SPERRZONE

### VOR JEDER AENDERUNG PRUEFEN:

1. Oeffne `CLAUDE2.md`
2. Lies die EINGEFRORENE-ELEMENTE-Tabelle
3. Ist das Element gelistet? → **STOPP! Nicht aendern!**
4. Koennte die Aenderung ein eingefrorenes Element beeinflussen? → **STOPP! Fragen!**

### WENN EIN EINGEFRORENES ELEMENT BETROFFEN WAERE:

```
"ACHTUNG: Diese Aenderung koennte das eingefrorene Element [X] beeinflussen.
Das Element wurde am [Datum] eingefroren.
Soll ich trotzdem fortfahren? (Explizite Freigabe erforderlich)"
```

---

## 🔄 MULTI-AGENT WORKFLOW MIT MASTER-KONTROLLE

### Bei JEDER nicht-trivialen Aufgabe:

```
┌─────────────────────────────────────────────────────────────┐
│  MASTER-AGENT (Ich selbst - Kontrolle und Qualitaet)        │
│  =========================================================  │
│                                                             │
│  1. PLANER-PHASE                                            │
│     └─ Aufgabe verstehen                                    │
│     └─ In Schritte zerlegen (TodoWrite!)                    │
│     └─ Risiken identifizieren (eingefrorene Elemente?)      │
│                                                             │
│  2. RESEARCHER-PHASE                                        │
│     └─ Betroffene Dateien lesen (VOLLSTAENDIG!)             │
│     └─ Zusammenhaenge verstehen                             │
│     └─ CLAUDE2.md auf Freeze-Liste pruefen                  │
│                                                             │
│  3. IMPLEMENTER-PHASE                                       │
│     └─ NUR das Minimum aendern                              │
│     └─ NICHTS anderes beruehren                             │
│     └─ In CLAUDE2.md dokumentieren                          │
│                                                             │
│  4. TESTER-PHASE                                            │
│     └─ Chrome DevTools: Console-Errors pruefen              │
│     └─ Geaenderte Funktion testen                           │
│     └─ 2-3 ANDERE Funktionen testen (Regression!)           │
│                                                             │
│  5. REVIEWER-PHASE (MASTER-KONTROLLE!)                      │
│     └─ Alle Schritte durchgegangen?                         │
│     └─ Keine Regression?                                    │
│     └─ Dokumentiert?                                        │
│     └─ → Erst dann "Erledigt" melden!                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Automatische Task-Erstellung:

Bei Aufgaben mit >3 Schritten MUSS TodoWrite verwendet werden!

### MASTER-CHECKLISTE (vor "Erledigt"):

```
□ Aufgabe vollstaendig erledigt?
□ Keine anderen Funktionen beschaedigt?
□ Console-Errors geprueft?
□ Regression-Test gemacht?
□ In CLAUDE2.md dokumentiert?
□ Einfrieren angeboten?

Alle Haken? → "Erledigt"
Nicht alle? → Weiterarbeiten!
```

---

## 🧪 PFLICHT-TESTS (IMMER!)

### Nach JEDER Aenderung:

1. **Funktionstest**: Funktioniert die geaenderte Funktion?
2. **Regression-Test**: Funktionieren 2-3 ANDERE Funktionen noch?
3. **Console-Check**: Keine JavaScript-Fehler?
4. **API-Check**: Antwortet der Server korrekt?

### Test-Methoden (TOKEN-EFFIZIENT!):

| Test | Tool | Token-Kosten | Wann nutzen |
|------|------|--------------|-------------|
| Console-Errors lesen | **Chrome DevTools MCP** | ~500 Token | **IMMER ZUERST!** |
| DOM inspizieren | **Chrome DevTools MCP** | ~500 Token | Bei Element-Problemen |
| Network-Requests | **Chrome DevTools MCP** | ~500 Token | Bei API-Problemen |
| Screenshot | Playwright | ~2000 Token | Nur wenn noetig |
| Element klicken | Playwright | ~2000 Token | Nur fuer Interaktion |

### WICHTIG: Token-Hierarchie bei Browser-Tests:

```
1. ZUERST: Chrome DevTools MCP fuer Console-Errors
   → list_console_messages (Token-effizient!)
   → Erkennt JavaScript-Fehler sofort

2. DANN: Chrome DevTools MCP fuer Network
   → list_network_requests
   → Erkennt API-Fehler (404, 500, etc.)

3. NUR WENN NOETIG: Playwright
   → browser_screenshot fuer visuellen Beweis
   → browser_click fuer Interaktion
```

### Chrome muss mit Remote Debugging laufen:

```cmd
chrome.exe --remote-debugging-port=9222
```

### API-Check (ohne Browser):

```bash
curl http://localhost:5000/api/health
```

---

## 🔍 PROBLEM-ERKENNUNG (Proaktiv!)

### Wenn ich ein Problem bemerke:

1. **NICHT ignorieren!**
2. **Melden**: "Ich habe bemerkt dass [X] nicht funktioniert"
3. **Analysieren**: Warum? Seit wann? Was haengt damit zusammen?
4. **Vorschlagen**: "Soll ich das beheben?"

### Was ich automatisch erkennen MUSS:

- JavaScript-Fehler in der Console
- Fehlende Elemente im DOM
- API-Fehler (404, 500, etc.)
- Nicht reagierende Buttons
- Fehlende Daten in Formularen
- Sichtbare UI-Probleme

---

## 📊 GANZHEITLICHES VERSTAENDNIS

### Das Projekt besteht aus:

```
ACCESS (Backend)
├── Tabellen (tbl_*)
├── Abfragen (qry_*)
├── Formulare (frm_*)
├── VBA Module (mod_*)
└── Events (Button_Click, Form_Load, etc.)

     ↕ [API Server - localhost:5000]

HTML (Frontend)
├── Formulare (*.html)
├── Logic (*.logic.js)
├── CSS (css/*.css)
└── Events (onclick, onchange, etc.)
```

### Jede HTML-Funktion MUSS:

1. Ein Gegenstueck in Access haben (oder bewusst neu sein)
2. Mit dem API-Server kommunizieren koennen
3. Fehler sinnvoll behandeln
4. Dem Benutzer Feedback geben

---

## 🛡️ SERVER-STABILITAET

### API-Server pruefen:

```bash
curl http://localhost:5000/api/health
```

### Bei Server-Fehler:

1. Fehlermeldung analysieren
2. Server neu starten wenn noetig
3. Watchdog pruefen: `engine/server_watchdog.ps1`

### Server-Watchdog starten:

```powershell
powershell -ExecutionPolicy Bypass -File engine/server_watchdog.ps1
```

---

## 💡 PROAKTIVE VERBESSERUNGEN

### Wenn ich sehe dass etwas besser sein koennte:

```
"Vorschlag: [Beschreibung]
Grund: [Warum waere es besser?]
Aufwand: [Gering/Mittel/Hoch]
Risiko: [Gering/Mittel/Hoch]

Soll ich das umsetzen?"
```

### Ich darf NIEMALS:

- Ungefragt "verbessern"
- Code "aufraeumen" ohne Auftrag
- Refactoring ohne explizite Anweisung
- Styles "vereinheitlichen" ohne Auftrag

---

## 📝 DOKUMENTATION (PFLICHT!)

### Bei JEDER Aenderung in CLAUDE2.md:

| Spalte | Inhalt |
|--------|--------|
| Datum | TT.MM.JJJJ |
| Element | ID oder Beschreibung |
| Datei | Pfad zur Datei |
| Vorher | Was war da? |
| Nachher | Was ist jetzt da? |
| Grund | Warum geaendert? |
| Getestet | Ja/Nein + Ergebnis |

---

## ⚡ Skills Auto-Trigger System

| Trigger-Woerter | Skill laden |
|-----------------|-------------|
| Button, onclick, klick | consys-button-fixer |
| API, Endpoint, fetch | consys-api-endpoint |
| Layout, CSS, Design | html-form-design-expert |
| Bug, Fehler, funktioniert nicht | systematic-debugging |
| VBA Fehler, Error, Runtime | vba-error-debugger |
| HTML aendern | html-change-tracker |
| Test, pruefen, Playwright | webapp-testing |
| Fertig, erledigt | verification-before-completion |

---

## 🏁 FERTIG-MELDUNG (PFLICHT-FORMAT!)

### NIEMALS "Erledigt" ohne:

```
✅ AENDERUNG: [Was wurde geaendert]
✅ DATEI: [Welche Datei]
✅ GETESTET: [Was wurde getestet]
✅ REGRESSION: [2-3 andere Funktionen geprueft]
✅ CONSOLE: Keine Fehler
✅ DOKUMENTIERT: In CLAUDE2.md eingetragen

Aenderung abgeschlossen.
Soll ich das Element einfrieren?
```

---

## 📂 Wichtige Dateipfade

```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\
├── CLAUDE.md                        # Haupt-Regeln
├── CLAUDE2.md                       # Aenderungslog + Freeze-Liste
├── 0_Consys_FE_Test.accdb          # Access Frontend
├── 04_HTML_Forms\forms3\            # HTML Formulare
├── 06_Server\api_server.py          # API Server
├── engine\                          # Multi-Agent System
│   └── server_watchdog.ps1          # Server-Ueberwachung
└── 0_Claude_Skills\                 # Skills
```

---

## 🎯 ZUSAMMENFASSUNG: Die 5 Gebote

1. **VERSTEHE** bevor Du aenderst
2. **SCHUETZE** was funktioniert
3. **TESTE** sichtbar und dokumentiert
4. **DOKUMENTIERE** jede Aenderung
5. **FRAGE** bei Unklarheit
