---
name: Superpowers Lokale Installation
description: Zentrale Skill-Verwaltung für CONSYS-Projekt ohne Git-Abhängigkeit
when_to_use: Wenn Skills geladen, erstellt oder verwaltet werden sollen
version: 3.0.0
---

# Superpowers für CONSYS

## Skills-Root
`C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Claude_Skills\`

## Verfügbare Skills (16)

### Core Skills
| Skill | Zweck | Auto-Trigger |
|-------|-------|--------------|
| consys-button-fixer | Button-Reparatur Access↔HTML | button, onclick, klick |
| consys-api-endpoint | API-Endpoint-Erstellung | endpoint, api, route |
| html-form-design-expert | Optische Optimierung | layout, css, design |
| form-optimization-advisor | Layout- und UX-Beratung | ux, optimieren |
| access-form-function-validator | VBA-Funktionsvalidierung | vba validieren |

### Debug Skills
| Skill | Zweck | Auto-Trigger |
|-------|-------|--------------|
| vba-error-debugger | VBA Fehler & Error-Handling | vba fehler, error, runtime |
| flask-api-debugger | Flask Server Debugging | flask fehler, 500, cors |
| html-js-debugger | JavaScript/Frontend Debug | js error, console, dom |

### UI/Design Skills (NEU)
| Skill | Zweck | Auto-Trigger |
|-------|-------|--------------|
| **professional-ui-design** | **Professionelles UI-Design** | **design, ui, professionell, optik** |
| **form-component-library** | **Wiederverwendbare Komponenten** | **komponente, tabelle, dialog, tab** |
| **css-design-tokens** | **CSS-Variablen & Tokens** | **token, variable, theme, farbe** |

### Testing & Utility Skills
| Skill | Zweck | Auto-Trigger |
|-------|-------|--------------|
| access-to-html-migrator | Access→HTML Konvertierung | migration, konvertieren |
| api-tester | API Endpoint Tests | api testen, curl |
| **webapp-testing** | **Playwright Browser-Tests** | **test, testen, prüfen, playwright** |
| **html-change-tracker** | **Änderungs-Dokumentation** | **html ändern, element, style** |
| superpowers | Skill-Verwaltung | skill, skills |

---

## Skill laden
```
Lies: 0_Claude_Skills/{skill-name}/SKILL.md
```

## Auto-Trigger aktivieren
```
/skills_an
```
→ Skills werden automatisch bei passenden Wörtern geladen

---

## Skill-Übersicht nach Kategorie

### 🎨 Design & UI
- `professional-ui-design` - Professionelle Business-App-Ästhetik
- `form-component-library` - Fertige HTML-Komponenten
- `css-design-tokens` - Zentrale CSS-Variablen
- `html-form-design-expert` - Layout-Optimierung

### 🔧 Entwicklung
- `consys-button-fixer` - Button-Reparatur
- `consys-api-endpoint` - API-Endpoints erstellen
- `access-to-html-migrator` - Access→HTML Migration

### 🐛 Debugging
- `vba-error-debugger` - VBA-Fehler beheben
- `flask-api-debugger` - Server-Fehler finden
- `html-js-debugger` - Frontend-Debugging

### 🧪 Testing
- `webapp-testing` - Playwright Browser-Tests
- `api-tester` - API-Endpoint-Tests

### 📋 Workflow
- `html-change-tracker` - Änderungs-Dokumentation (PFLICHT!)
- `superpowers` - Skill-Verwaltung

---

## Neuen Skill erstellen

1. Ordner unter `0_Claude_Skills/` anlegen
2. SKILL.md mit Frontmatter erstellen:
```yaml
---
name: Skill Name
description: Kurze Beschreibung
when_to_use: Trigger-Wörter
version: 1.0.0
auto_trigger: wort1, wort2, wort3
---
```
3. In INSTRUCTIONS.md Trigger-Tabelle eintragen
4. Diese Datei (superpowers/SKILL.md) aktualisieren

## Skill-Struktur
```
0_Claude_Skills/
├── skill-name/
│   ├── SKILL.md       # Hauptdatei (Pflicht)
│   ├── templates/     # Optional: Code-Vorlagen
│   └── examples/      # Optional: Beispiele
```
