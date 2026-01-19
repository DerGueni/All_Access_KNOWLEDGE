# Auftragstamm Design-Varianten

Dieses Verzeichnis enthält Design-Varianten des Formulars `frm_va_Auftragstamm.html`.

## Varianten

### Variante 5: Elegant Dark Mode (`variante_05_dark_mode.html`)
- **Farbschema**: Dunkle Töne für Augen-Schonung
- **Background**: #1E1E1E (Dunkelgrau)
- **Surface**: #2D2D2D (Mittelgrau)
- **Text**: #E0E0E0 (Hellgrau)
- **Akzent**: #BB86FC (Lila)
- **Buttons**: #3C3C3C mit hellem Hover-Effekt
- **Grids/Tabellen**: Dunkler Hintergrund, kontrastreiche Zeilen

**Besonderheiten**:
- Hoher Kontrast für bessere Lesbarkeit bei Nacht
- Reduzierte Augenbelastung bei langen Arbeitssitzungen
- Moderne, elegante Optik

### Variante 6: Corporate Enterprise Gray (`variante_06_enterprise.html`)
- **Farbschema**: Seriöses Unternehmens-Design
- **Hauptfarbe**: #37474F (Blaugrau)
- **Akzent**: #0288D1 (Blau)
- **Neutral**: #ECEFF1, #CFD8DC (Hellgrau-Töne)
- **Buttons**: Subtile Gradients
- **Grids/Tabellen**: Professionelle, klare Darstellung

**Besonderheiten**:
- Professionelles, konservatives Erscheinungsbild
- Optimal für Büro-Umgebungen
- Dezente Farben, hohe Usability

### Variante 9: Teal Refresh (`variante_09_teal.html`) - NEU!
- **Farbschema**: Frisches Teal/Türkis Design
- **Hauptfarbe**: #00796B (Teal)
- **Sidebar**: #004D40 (Dark Teal)
- **Header**: #00695C (Medium Teal)
- **Akzente**: #26A69A, #80CBC4 (Helle Teal-Töne)
- **Buttons**: Angepasste Teal-Gradients
- **Grids/Tabellen**: Teal-Hover-Effekte

**Besonderheiten**:
- Modernes, freundliches Farbschema
- Beruhigende Wirkung (Türkis)
- Gute Lesbarkeit bei hoher Frische

### Variante 10: Ocean Blue (`variante_10_ocean_blue.html`) - NEU!
- **Farbschema**: Kräftiges Ozean-Blau Design
- **Hauptfarbe**: #1976D2 (Ocean Blue)
- **Sidebar**: #0D47A1 (Dark Blue)
- **Header**: #1565C0 (Medium Blue)
- **Akzente**: #42A5F5, #64B5F6 (Helle Blau-Töne)
- **Buttons**: Angepasste Blau-Gradients
- **Grids/Tabellen**: Blau-Hover-Effekte

**Besonderheiten**:
- Klares, professionelles Blau-Design
- Hohe Konzentrationsfähigkeit (Blau-Effekt)
- Moderne, technik-affine Optik

## Technische Details

- **HTML-Struktur**: Identisch mit Original (keine Änderungen)
- **JavaScript**: Vollständig unverändert
- **CSS**: Nur Farben und Gradienten angepasst
- **Funktionalität**: 100% identisch mit Original

## Verwendung

Die Varianten können direkt im Browser geöffnet werden:

```
file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/varianten_auftragstamm/variante_05_dark_mode.html
```

Oder über den API-Server (falls erforderlich):

```bash
cd "C:\Users\guenther.siegert\Documents\Access Bridge"
python api_server.py
```

Dann im Browser: `http://localhost:8000/varianten_auftragstamm/variante_05_dark_mode.html`

## Generierung der Varianten 9 & 10

Die Varianten 9 und 10 wurden automatisch durch Farbersetzung generiert.

### Generator-Tools

Im Root-Verzeichnis `0006_All_Access_KNOWLEDGE` befinden sich mehrere Generator-Tools:

**1. Node.js-Script (empfohlen)**:
```bash
cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE
node create_variants.js
```

**2. Python-Script**:
```bash
cd C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE
python create_variants.py
```

**3. Windows Batch-File** (Doppelklick):
- `create_variants.bat`

**4. PowerShell-Script**:
- `run_variants.ps1`

**5. Browser-Tool**:
- Öffne `varianten_auftragstamm/create_variants.html` im Browser

### Farbmapping (Varianten 9 & 10)

| Original  | Teal Refresh | Ocean Blue | Verwendung                    |
|-----------|--------------|------------|-------------------------------|
| #8080c0   | #00796B      | #1976D2    | Body Background               |
| #6060a0   | #004D40      | #0D47A1    | Sidebar Background            |
| #000080   | #00695C      | #1565C0    | Header / Title Bar            |
| #9090c0   | #4DB6AC      | #64B5F6    | Content Areas                 |
| #60c060   | #26A69A      | #42A5F5    | Green Buttons (zu Hauptfarbe) |
| #e0e080   | #FFD54F      | #FFD54F    | Yellow Buttons (gleich)       |
| #e06060   | #EF5350      | #EF5350    | Red Buttons (gleich)          |

**Wichtig**: Nur Farben wurden geändert - keine Struktur, Abstände, Schriften oder JavaScript!

## Anpassungen

Um eigene Varianten zu erstellen, einfach eine der vorhandenen Varianten kopieren und im `<style>`-Block (Zeile 7-840) die CSS-Werte anpassen.

### Wichtigste CSS-Variablen zum Anpassen:

- `body { background-color }` - Hintergrund
- `.title-bar { background }` - Titelleiste
- `.left-menu { background-color }` - Sidebar
- `.btn { background, color }` - Buttons
- `.data-grid th { background }` - Tabellen-Header
- `.data-grid tr.selected { background }` - Selektion

---

Erstellt: 2026-01-02
Aktualisiert: 2026-01-02 (Varianten 9 & 10)
