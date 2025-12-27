# 📊 HTML-Formulare Standardisierungs-Plan

## Status Quo
- **Total Formulare:** 30
- **Standardisiert:** 18 ✅ (60%)
- **Zu standardisieren:** 12 ⚠️ (40%)
- **Strukturprobleme:** 44

---

## 🎯 Standardisierungs-Strategie

### Erforderliche Standard-Struktur
```
<div class="app-container">                    <!-- Wrapper -->
  <aside class="app-sidebar">                   <!-- Sidebar Navigation -->
    <!-- Navigation Links -->
  </aside>
  <main class="app-main">                       <!-- Main Content -->
    <div class="form-header">                   <!-- Header grau/blau -->
      <!-- Controls & Navigation -->
    </div>
    <div class="employee-info/content-area">    <!-- Form Content -->
      <!-- Formular-Inhalte -->
    </div>
    <div class="status-bar">                    <!-- Status Bar Footer -->
      <!-- Timestamps & Info -->
    </div>
  </main>
</div>
```

### Erforderliche CSS-Referenzen
```html
<link rel="stylesheet" href="../css/app-layout.css">     <!-- Standard Styles -->
<link rel="stylesheet" href="../css/design-system.css">  <!-- Design System -->
<link rel="stylesheet" href="../theme/consys_theme.css"> <!-- Theme -->
<link rel="stylesheet" href="styles/[formname].css">     <!-- Form Spezifisch -->
```

### Erforderliche JS-Referenzen
```html
<script type="module" src="../js/sidebar.js"></script>                    <!-- Sidebar Init -->
<script type="module" src="logic/[formname].logic.js"></script>          <!-- Form Logic -->
```

---

## 📋 Formulare nach Kategorie

### Gruppe A: Spezial-Formulare (3)
**Strategien:** Individuelle Behandlung - Custom Layouts beibehalten, aber mit Standard-Wrapper

1. **frm_DP_Dienstplan_MA.html** (863 Zeilen)
   - Status: Dunkelrot (#8B0000) Custom Layout mit 1904px Breite
   - Problem: Völlig Custom CSS, keine Standard-Struktur
   - Lösung: Als Spezialform behandeln, eigene Sidebar hinzufügen

2. **frm_DP_Dienstplan_Objekt.html** (668 Zeilen)
   - Status: Ähnlich wie MA, Dunkelrot Layout
   - Problem: Keine Standard-Struktur
   - Lösung: Als Spezialform behandeln

3. **frm_lst_row_auftrag.html** (38 Zeilen)
   - Status: Subform für Tabellenansicht, sehr klein
   - Problem: Keine app-container
   - Lösung: Kann in andere Formulare eingebettet bleiben, aber sollte Standard-CSS nutzen

---

### Gruppe B: Mit vorhandener Sidebar (4)
**Strategien:** Umstrukturierung zu app-container + app-sidebar Pattern

1. **frm_MA_Abwesenheit.html** (179 Zeilen)
   - Status: Hat `abw-container` + `abw-menu` (nicht app-sidebar)
   - Fehlt: app-container, sidebar.js, status-bar
   - Lösung: HTML Struktur umbauen zu app-container Wrapper

2. **frm_abwesenheitsuebersicht.html**
   - Status: Ähnlich frm_MA_Abwesenheit
   - Lösung: Identisch strukturieren

3. **frm_Abwesenheiten.html**
   - Status: Ähnlich frm_MA_Abwesenheit
   - Lösung: Identisch strukturieren

4. **frm_MA_VA_Schnellauswahl.html** (1348 Zeilen)
   - Status: Custom CSS, 1862px Breite, Rot/Weiß Layout
   - Problem: Massive Custom CSS, keine Standard-Struktur
   - Lösung: Sidebar hinzufügen, aber Custom Layout beibehalten

---

### Gruppe C: Simple Menü/Formulare (5)
**Strategien:** Einfache Konvertierung zu Standard-Layout

1. **frm_Menuefuehrung.html** (60 Zeilen)
   - Status: Reines Menü, bordeaux (#6B1C23)
   - Fehlt: app-container, app-layout.css, sidebar.js
   - Lösung: In Standard-Layout umwandeln

2. **frm_N_Menuefuehrung1_HTML.html**
   - Status: Ähnlich frm_Menuefuehrung
   - Lösung: Identisch strukturieren

3. **frm_N_Menuefuehrung_HTML.html**
   - Status: Ähnlich frm_Menuefuehrung
   - Lösung: Identisch strukturieren

4. **frm_KD_Kundenstamm.html**
   - Status: Hat app-layout.css, aber fehlt app-container, sidebar.js
   - Lösung: Strukturelle Umwandlung

5. **frm_N_Optimierung_Editor.html**
   - Status: Ähnlich frm_KD_Kundenstamm
   - Lösung: Strukturelle Umwandlung

---

## 🔧 Standardisierungs-Checkliste

### Für jeden Standard-Form:
- [ ] HTML struktur: `<div class="app-container">` mit `<aside class="app-sidebar">` + `<main class="app-main">`
- [ ] CSS: `app-layout.css` referenziert
- [ ] CSS: `design-system.css` referenziert
- [ ] CSS: `consys_theme.css` referenziert
- [ ] CSS: Form-spezifisches CSS referenziert
- [ ] JS: `../js/sidebar.js` laden
- [ ] JS: Form-spezifisches Logic JS laden
- [ ] Header: Grau/Blau (#D0D0D0 oder #4316B2), ~94px hoch
- [ ] Status-Bar: #EFEFEF, 16px hoch, mit Timestamps
- [ ] Footer: Konsistent mit anderen Formularen

---

## 📊 Fehler-Kategorisierung (44 Probleme)

| Problem | Count | Betroffene Formulare |
|---------|-------|----------------------|
| Fehlendes app-container | 12 | Alle 12 problematischen Formulare |
| Fehlendes app-layout.css | 8 | Gruppe A + Teile B |
| Fehlendes sidebar.js | 12 | Alle außer 18 kompletten |
| Fehlendes status-bar | 26 | Nur 4 Formulare haben es |
| Unterschiedliche Header-Höhe | 15 | Verschiedene Höhen (70-94px) |
| Unterschiedliche Farben | 8 | Verschiedene Headerfarben |

---

## 🚀 Implementierungs-Reihenfolge

### Phase 1: Gruppe C (Einfache Fälle) - 5 Formulare
- Schnelle Wins
- Template als Basis nutzen
- Geschätzter Aufwand: 30 min pro Formular

### Phase 2: Gruppe B (Mit Sidebar) - 4 Formulare
- Mittlerer Aufwand
- Bestehende Strukturen erhalten
- Geschätzter Aufwand: 45 min pro Formular

### Phase 3: Gruppe A (Spezial) - 3 Formulare
- Höchster Aufwand
- Individuelle Behandlung notwendig
- Geschätzter Aufwand: 1-2h pro Formular

---

## ✅ Validierungs-Kriterien

Nach Standardisierung müssen alle 30 Formulare:
1. Sidebar links anzeigen ✅
2. Grauer Header oben (#D0D0D0) ✅
3. Grauer Status-Bar unten (#EFEFEF) ✅
4. Konsistische Schriftgrößen ✅
5. Funktional arbeiten (API-Aufrufe, Navigation) ✅
6. Visuelle 1:1 Entsprechung zum Original erhalten ✅

---

## 📝 Notizen

- **Referenz-Formular:** frm_MA_Mitarbeiterstamm.html (100% Standard)
- **Nicht verändern:** Die 18 kompletten Formulare
- **Ziel:** 100% Standardisierung (30/30 Formulare)
- **Anforderung:** "Es muss optisch 1:1 gleich sein. Nur das Hauptmenü bzw die Sidebar darf bleiben"
