# Design-Varianten für frm_va_Auftragstamm.html

## Erstellte Dateien

1. **create_design_variants.py** - Python-Script zur Generierung der Varianten
2. Diese README-Datei

## Wie die Varianten erstellt werden

### Schritt 1: Python-Script ausführen

Öffnen Sie eine Kommandozeile (CMD oder PowerShell) und führen Sie aus:

```bash
cd "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms"
python create_design_variants.py
```

### Schritt 2: Ergebnis

Das Script erstellt den Ordner `varianten_auftragstamm` mit zwei Dateien:

- **variante_07_minimalist.html** - Minimalist White Design
- **variante_08_nord.html** - Nord Theme Design

## Variante 7: Minimalist White

**Beschreibung:**
- Ultra-cleanes Design mit viel Weißraum
- Sehr dezente Farbgebung
- Ghost-Style Buttons mit Border
- Dünne 1px Linien statt Boxen

**Farben:**
- Hintergrund: #FAFAFA (sehr helles Grau)
- Primärtext: #212121 (fast Schwarz)
- Sekundärtext: #757575 (mittleres Grau)
- Akzentfarbe: #1565C0 (Blau)
- Borders: #E0E0E0 (sehr helles Grau)

**Besonderheiten:**
- Transparente Buttons mit Hover-Effekt
- Minimale Scrollbars (8px)
- Border-Radius 4px für moderne Optik
- Sanfte Transitions (0.2s)

## Variante 8: Nord Theme

**Beschreibung:**
- Basiert auf dem beliebten Nord Color Scheme (nordtheme.com)
- Dunkles, augenschonendes Design
- Harmonische Farbpalette
- Professionelle Code-Editor-Optik

**Farben:**

**Polar Night (Hintergründe):**
- #2E3440 (dunkelster, Haupt-Hintergrund)
- #3B4252 (Panels, Cards)
- #434C5E (Buttons, Controls)
- #4C566A (Borders, Hover)

**Snow Storm (Texte):**
- #D8DEE9 (Normaltext)
- #E5E9F0 (Hover-Text)
- #ECEFF4 (Weißer Text, Highlights)

**Frost (Akzente):**
- #8FBCBB (Cyan, Links)
- #88C0D0 (Hellblau, Primary)
- #81A1C1 (Blau, Secondary)
- #5E81AC (Dunkelblau, selten)

**Aurora (Funktionale Farben):**
- #BF616A (Rot, Errors/Close)
- #D08770 (Orange, selten)
- #EBCB8B (Gelb, Warnings)
- #A3BE8C (Grün, Success)
- #B48EAD (Lila, selten)

**Besonderheiten:**
- Breite Scrollbars (10px) für bessere Sichtbarkeit
- Border-left Akzente bei aktiven Menü-Items
- Gradient im Logo (Frost-Farben)
- Toast-Notifications mit farbigen Border-Left

## Was ist identisch in beiden Varianten?

- **HTML-Struktur:** 1:1 identisch
- **JavaScript:** Komplett unverändert
- **Funktionalität:** Identisch
- **Layout:** Exakt gleiche Anordnung

## Was wurde geändert?

- **NUR CSS:** Komplette Überarbeitung
- Farben, Abstände, Borders, Schatten
- Hover-Effekte, Transitions
- Scrollbar-Styling

## Testen der Varianten

1. Öffnen Sie die HTML-Dateien direkt im Browser
2. Oder integrieren Sie sie in Ihre Anwendung
3. Alle Funktionen bleiben erhalten

## Weitere Anpassungen

Das Python-Script kann leicht erweitert werden um:
- Weitere Varianten hinzuzufügen
- Farbwerte anzupassen
- Andere Design-Systeme zu implementieren

Einfach `create_design_variants.py` bearbeiten und neue CSS-Konstanten hinzufügen.
