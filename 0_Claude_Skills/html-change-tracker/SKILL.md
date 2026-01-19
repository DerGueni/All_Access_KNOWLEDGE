---
name: HTML Element Change Tracker
description: Dokumentiert JEDE HTML-Element-Änderung in CLAUDE2.md - Schreibschutz ohne explizite Anweisung
when_to_use: Bei JEDER Änderung an HTML-Formularen, CSS, JavaScript-Elementen
version: 1.0.0
auto_trigger: html, element, button, input, css, style, ändern, change
---

# HTML Element Change Tracker

## 🚨 PFLICHT-REGEL

**Bei JEDER Änderung an HTML-Elementen MUSS dieser Workflow ausgeführt werden!**

### Wann greift diese Regel?
- Änderung an HTML-Dateien in `04_HTML_Forms/`
- Änderung an CSS in `04_HTML_Forms/forms3/css/`
- Änderung an JavaScript in `04_HTML_Forms/forms3/js/` oder `logic/`
- Änderung von Element-Attributen (id, class, style, onclick, etc.)
- Hinzufügen/Entfernen von Elementen

---

## 📋 WORKFLOW

### 1. VOR der Änderung
```
1. Prüfe: Liegt EXPLIZITE Benutzeranweisung vor?
   - JA → Weiter zu Schritt 2
   - NEIN → STOPP! Nachfragen!

2. Dokumentiere den IST-Zustand:
   - Element-ID/Klasse
   - Aktueller Code/Wert
   - Datei und Zeile
```

### 2. NACH der Änderung
```
1. Füge Eintrag in CLAUDE2.md ein (am Ende der Datei)
2. Format verwenden (siehe unten)
3. Bei kritischen Elementen: Zur EINGEFRORENE-ELEMENTE-Tabelle hinzufügen
```

---

## 📝 DOKUMENTATIONS-FORMAT

```markdown
### [YYYY-MM-DD] [HH:MM] - [Formularname]
**Element:** `#elementId` oder `.className`
**Typ:** button | input | select | label | div | span | table | css | js
**Datei:** `04_HTML_Forms/forms3/[dateiname]`
**Zeile:** [Zeilennummer(n)]
**Änderung:** [Kurze Beschreibung]
**Vorher:**
\`\`\`html
[Alter Code]
\`\`\`
**Nachher:**
\`\`\`html
[Neuer Code]
\`\`\`
**Benutzeranweisung:** "[Exakte Anweisung kopieren]"
**Status:** ✅ Abgeschlossen
```

---

## 🔒 SCHREIBSCHUTZ-PRÜFUNG

### Vor JEDER Änderung prüfen:

1. **CLAUDE2.md öffnen**
2. **EINGEFRORENE-ELEMENTE-Tabelle durchsuchen**
3. **Ist Element gelistet?**
   - JA → **STOPP!** Keine Änderung ohne neue explizite Anweisung
   - NEIN → Änderung erlaubt (mit Dokumentation)

### Explizite Anweisung = NUR wenn Benutzer sagt:
- "Ändere [Element] zu [Wert]"
- "Füge [Element] hinzu"
- "Entferne [Element]"
- "Passe [Element] an"
- "Korrigiere [Element]"

### KEINE explizite Anweisung:
- "Schau mal drüber"
- "Optimiere das"
- "Mach es besser"
- "Verbessere die Performance"

---

## 🛠️ HELPER-TEMPLATE

### Eintrag hinzufügen (Copy-Paste):

```markdown
### 2026-01-XX XX:XX - frm_FORMULARNAME
**Element:** `#elementId`
**Typ:** TYPE
**Datei:** `04_HTML_Forms/forms3/DATEI.html`
**Zeile:** XXX
**Änderung:** BESCHREIBUNG
**Vorher:**
\`\`\`html
ALTER_CODE
\`\`\`
**Nachher:**
\`\`\`html
NEUER_CODE
\`\`\`
**Benutzeranweisung:** "ANWEISUNG"
**Status:** ✅ Abgeschlossen
```

---

## ⚠️ VERBOTEN

- Änderungen OHNE Dokumentation in CLAUDE2.md
- Änderungen an eingefrorenen Elementen ohne neue Anweisung
- "Implizite" Änderungen ("Das habe ich gleich mitgemacht")
- Änderungen basierend auf Vermutungen

---

## 📁 DATEIPFADE

- **Änderungslog:** `CLAUDE2.md`
- **HTML-Formulare:** `04_HTML_Forms/forms3/*.html`
- **CSS:** `04_HTML_Forms/forms3/css/*.css`
- **JavaScript:** `04_HTML_Forms/forms3/js/*.js` + `logic/*.js`

---

## ✅ CHECKLISTE (vor Abschluss)

- [ ] CLAUDE2.md aktualisiert
- [ ] Vorher/Nachher dokumentiert
- [ ] Benutzeranweisung zitiert
- [ ] Bei kritischen Elementen: Eingefroren-Tabelle aktualisiert
