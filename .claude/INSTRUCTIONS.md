# CONSYS Projekt-Anweisungen

## 🔴 ÄNDERUNGS-TRACKING (AUTOMATISCH AKTIV!)

> **PFLICHT bei JEDER HTML/CSS/JS-Änderung:**
> 1. Prüfe: Explizite Benutzeranweisung vorhanden? → Sonst STOPP!
> 2. Dokumentiere in `CLAUDE2.md` (Vorher/Nachher)
> 3. Kritische Elemente → Einfrieren in CLAUDE2.md Tabelle
>
> **Ohne Dokumentation = Änderung verboten!**
> 
> **Datei:** `CLAUDE2.md` im Projekt-Root

---

## ⚡ Skills Auto-Trigger System

### Aktivierung
- `/skills_an` oder `skills an` → Skills aktivieren
- `/skills_aus` oder `skills aus` → Skills deaktivieren

### Bei JEDER Anfrage automatisch prüfen (wenn Skills AN):

| Trigger-Wörter | Skill laden |
|----------------|-------------|
| **Button, onclick, klick, reagiert nicht, click** | `0_Claude_Skills/consys-button-fixer/SKILL.md` |
| **Endpoint, API erstellen, fetch, Daten holen, Route** | `0_Claude_Skills/consys-api-endpoint/SKILL.md` |
| **Layout, CSS, Design, optisch, Farbe, Styling** | `0_Claude_Skills/html-form-design-expert/SKILL.md` |
| **UX, Benutzerfreundlich, optimieren, verbessern** | `0_Claude_Skills/form-optimization-advisor/SKILL.md` |
| **VBA Fehler, Error, Runtime, Debug, Access crasht** | `0_Claude_Skills/vba-error-debugger/SKILL.md` |
| **Flask Fehler, 500 Error, CORS, Server Error** | `0_Claude_Skills/flask-api-debugger/SKILL.md` |
| **JavaScript Error, Console Error, DOM, Event** | `0_Claude_Skills/html-js-debugger/SKILL.md` |
| **Migration, Access zu HTML, konvertieren** | `0_Claude_Skills/access-to-html-migrator/SKILL.md` |
| **API testen, Endpoint testen, curl, Response** | `0_Claude_Skills/api-tester/SKILL.md` |
| **VBA validieren, Funktion prüfen** | `0_Claude_Skills/access-form-function-validator/SKILL.md` |
| **HTML ändern, Element, style, Formular bearbeiten** | `0_Claude_Skills/html-change-tracker/SKILL.md` + `HTML_RULES.txt` |
| **UI, professionell, Optik, Business-Design** | `0_Claude_Skills/professional-ui-design/SKILL.md` |
| **Komponente, Tabelle, Dialog, Tab, Modal** | `0_Claude_Skills/form-component-library/SKILL.md` |
| **Token, Variable, Theme, Farbe, CSS-Var** | `0_Claude_Skills/css-design-tokens/SKILL.md` |
| **Test, testen, prüfen, Playwright, Screenshot** | `0_Claude_Skills/webapp-testing/SKILL.md` |

## Verfügbare Skills (16 insgesamt)

| # | Skill | Beschreibung |
|---|-------|--------------|
| 1 | consys-button-fixer | Button-Reparatur Access↔HTML |
| 2 | consys-api-endpoint | API-Endpoint-Erstellung |
| 3 | html-form-design-expert | Optische Optimierung |
| 4 | form-optimization-advisor | Layout- und UX-Beratung |
| 5 | access-form-function-validator | VBA-Validierung |
| 6 | vba-error-debugger | VBA Fehler & Error-Handling |
| 7 | flask-api-debugger | Flask Server Debugging |
| 8 | html-js-debugger | JavaScript/Frontend Debugging |
| 9 | access-to-html-migrator | Access→HTML Konvertierung |
| 10 | api-tester | API Endpoint Tests |
| 11 | superpowers | Zentrale Skill-Verwaltung |
| 12 | **html-change-tracker** | **Änderungs-Dokumentation (PFLICHT!)** |
| 13 | **professional-ui-design** | **Professionelles UI-Design** |
| 14 | **form-component-library** | **Wiederverwendbare Komponenten** |
| 15 | **css-design-tokens** | **CSS-Variablen & Tokens** |
| 16 | **webapp-testing** | **Playwright Browser-Tests** |

## Slash-Befehle

| Befehl | Funktion |
|--------|----------|
| `/skills_an` | Skills aktivieren |
| `/skills_aus` | Skills deaktivieren |
| `/skills` | Alle Skills anzeigen |
| `/skill [name]` | Bestimmten Skill laden |
| `/status` | Projekt-Status |
| `/compress` | Token-sparende Antworten |
| `/handover` | Session-Übergabe erstellen |
| `/tokens` | Token-Verbrauch |
| `/button_audit` | Alle Buttons prüfen |
| `/changes` | CLAUDE2.md Änderungslog anzeigen |

## Wichtige Projekt-Regeln

### ⚠️ IMMER HTML_RULES.txt lesen bei HTML-Arbeiten!

### Änderungsdisziplin:
1. ✗ Keine funktionierenden Bereiche ändern
2. ✗ Keine eigenständigen Refactorings
3. ✓ Neue Endpoints am Ende hinzufügen
4. ✓ Erledigte Änderungen einfrieren
5. ✓ Vor Änderungen an eingefrorenen Bereichen: Freigabe holen
6. ✓ **JEDE Änderung in CLAUDE2.md dokumentieren!**

## Token-Optimierung

- Kurze, präzise Antworten
- Max 3 Tool-Calls für einfache Aufgaben
- Bullet Points statt Prosa
- Bei >70% Token-Verbrauch: `/compress` aktivieren

## Dateipfade

```
C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\
├── CLAUDE.md                        # Haupt-Regeln
├── CLAUDE2.md                       # Änderungslog (NEU!)
├── 0_Consys_FE_Test.accdb          # Access Frontend
├── HTML_RULES.txt                   # Projekt-Regeln
├── 01_VBA\                          # VBA Module
├── 04_HTML_Forms\forms3\            # HTML Formulare
│   ├── *.html
│   ├── css\
│   └── js\
├── 06_Server\                       # API Server
│   ├── api_server.py
│   └── quick_api_server.py
└── 0_Claude_Skills\                 # Skills
    ├── consys-button-fixer\
    ├── consys-api-endpoint\
    ├── html-change-tracker\         # NEU!
    ├── vba-error-debugger\
    ├── flask-api-debugger\
    ├── html-js-debugger\
    ├── access-to-html-migrator\
    ├── api-tester\
    └── ...
```
