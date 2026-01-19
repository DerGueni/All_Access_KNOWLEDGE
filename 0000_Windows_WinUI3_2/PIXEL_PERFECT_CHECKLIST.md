# Pixel-Perfect Checklist - MitarbeiterstammView

## Status: ✅ PHASE 1 ABGESCHLOSSEN

---

## FARB-VERGLEICH: ACCESS ORIGINAL vs. WinUI3

| Element | Access Original | WinUI3 Aktuell | Status |
|---------|----------------|----------------|--------|
| **Sidebar Background** | #8B0000 (Dunkelrot) | #8B0000 | ✅ |
| **Sidebar Button** | #A05050 (Mittelrot) | #A05050 | ✅ |
| **Sidebar Aktiv** | #D4A574 (Beige/Braun) | #D4A574 | ✅ |
| **Navigation Border** | #7F7F7F (Mittelgrau) | #7F7F7F | ✅ |
| **Navigation Button** | #F0F0F0 (Hellgrau) | #F0F0F0 | ✅ |
| **MA Adressen (Grün)** | #C0FF00 (Hellgrün) | #C0FF00 | ✅ |
| **MA Adressen Border** | #90C000 (Dunkelgrün) | #90C000 | ✅ |
| **Blau Button** | #95B3D7 (Mittelblau) | #95B3D7 | ✅ |
| **Blau Button Hell** | #CAD9EB (Hellblau) | #CAD9EB | ✅ |
| **Koordinaten-Feld** | #FFFACD (Gelb) | #FFFACD | ✅ |
| **Liste Header** | #D9D9D9 (Hellgrau) | #D9D9D9 | ✅ |
| **Formular BG** | #F0F0F0 (Grau) | #F0F0F0 | ✅ |

---

## LAYOUT-VERGLEICH

| Element | Access Original | WinUI3 Aktuell | Status |
|---------|----------------|----------------|--------|
| **Sidebar Breite** | ~140px | 140px | ✅ |
| **Button MinHeight** | ~28px | 28px | ✅ |
| **Button Padding** | ~10,6 | 10,6 | ✅ |
| **TextBox MinHeight** | ~22px | 22px | ✅ |
| **Feld-Abstände** | ~6px | 6px | ✅ |
| **Navigation Button** | 22x20 | 22x20 | ✅ |
| **Liste Spaltenbreiten** | 65/65/* | 65/65/* | ✅ |

---

## TYPOGRAFIE-VERGLEICH

| Element | Access Original | WinUI3 Aktuell | Status |
|---------|----------------|----------------|--------|
| **Sidebar Button** | 11pt | 11 | ✅ |
| **Formular Label** | 12pt | 12 | ✅ |
| **Formular Input** | 12pt | 12 | ✅ |
| **Liste Header** | 10pt | 10 | ✅ |
| **Liste Items** | 10pt | 10 | ✅ |
| **Titel** | 14pt Bold | 14 Bold | ✅ |

---

## BORDER & RAHMEN

| Element | Access Original | WinUI3 Aktuell | Status |
|---------|----------------|----------------|--------|
| **Sidebar Buttons** | Kein Rand | 0 | ✅ |
| **Navigation Border** | 1px #7F7F7F | 1 #7F7F7F | ✅ |
| **Navigation Buttons** | 1px #7F7F7F | 1 #7F7F7F | ✅ |
| **MA Adressen** | 1px #90C000 | 1 #90C000 | ✅ |
| **Blaue Buttons** | 1px #7A97BE | 1 #7A97BE | ✅ |
| **TextBox** | 1px #A6A6A6 | 1 #A6A6A6 | ✅ |

---

## ALIGNMENT & POSITIONING

| Element | Access Original | WinUI3 Aktuell | Status |
|---------|----------------|----------------|--------|
| **Sidebar Text** | Linksbündig | Left | ✅ |
| **Labels** | Linksbündig | Left | ✅ |
| **Buttons** | Zentriert | Stretch | ⚠️ |
| **Liste Header** | Linksbündig | Left | ✅ |

---

## FUNKTIONALITÄT

| Feature | Access Original | WinUI3 Aktuell | Status |
|---------|----------------|----------------|--------|
| **Navigation First** | ◀◀ | ◀◀ Command | ✅ |
| **Navigation Previous** | ◀ | ◀ Command | ✅ |
| **Navigation Next** | ▶ | ▶ Command | ✅ |
| **Navigation Last** | ▶▶ | ▶▶ Command | ✅ |
| **Neuer MA** | Button | Button Command | ✅ |
| **Suche** | TextBox | TextBox Binding | ✅ |
| **Filter** | ComboBox | ComboBox | ✅ |

---

## INTERAKTIONS-STATES (TODO)

| Element | Hover | Pressed | Disabled | Status |
|---------|-------|---------|----------|--------|
| **Sidebar Button** | ❌ | ❌ | ❌ | ⚠️ |
| **Navigation Button** | ❌ | ❌ | ❌ | ⚠️ |
| **MA Adressen** | ❌ | ❌ | ❌ | ⚠️ |
| **Blaue Buttons** | ❌ | ❌ | ❌ | ⚠️ |

---

## ACCESSIBILITY (Optional)

| Feature | Status | Priorität |
|---------|--------|-----------|
| **Keyboard Navigation** | ⚠️ | HOCH |
| **Screen Reader Support** | ⚠️ | MITTEL |
| **High Contrast Mode** | ⚠️ | NIEDRIG |
| **Focus Indicators** | ⚠️ | HOCH |

---

## PERFORMANCE

| Metrik | Zielwert | Aktuell | Status |
|--------|----------|---------|--------|
| **First Paint** | < 100ms | ❓ | ⚠️ |
| **Formular Load** | < 500ms | ❓ | ⚠️ |
| **Liste Scroll** | 60 FPS | ❓ | ⚠️ |
| **Memory** | < 100MB | ❓ | ⚠️ |

---

## PHASE 2: VERBLEIBENDE AUFGABEN

### KRITISCH
- [ ] Visual States für Hover/Pressed hinzufügen
- [ ] Keyboard Navigation testen
- [ ] Focus Indicators implementieren

### WICHTIG
- [ ] Tab-Control-Style angleichen (Pivot Headers)
- [ ] ListView Selection Color (#CAD9EB)
- [ ] Scrollbar-Styling (Access-ähnlich)

### NICE-TO-HAVE
- [ ] Animationen deaktivieren (Access hat keine)
- [ ] ClearType Font-Rendering optimieren
- [ ] High-DPI Scaling testen (125%, 150%, 200%)

---

## SCREENSHOT-VERGLEICH

**Nächste Schritte:**
1. WinUI3 App starten
2. Screenshot erstellen (F12 oder Snipping Tool)
3. Side-by-Side Vergleich mit Access-Original
4. Pixelgenaue Abweichungen dokumentieren

**Tools:**
- Beyond Compare (Bild-Vergleich)
- ImageMagick (Diff-Image erstellen)
- Paint.NET (Overlay-Vergleich)

---

## BUILD-INFO

**Letzter Build:** 2025-12-30
**Build-Status:** ✅ ERFOLGREICH
**Warnungen:** 10 (Null-Referenz-Hinweise)
**Fehler:** 0
**Build-Zeit:** 26.87s
