# UNIFIED HEADER DESIGN - Spezifikation

**Erstellt:** 15.01.2026
**Status:** In Implementierung

## Übersicht

Dieses Dokument definiert das einheitliche Header-Design für alle Hauptformulare in `forms3/`. Das Design basiert auf der bestehenden Implementierung in `frm_va_Auftragstamm.html` und wird auf alle anderen Formulare übertragen.

## Ziel

Alle Hauptformulare sollen ein konsistentes, modernes Header-Design haben mit:
- Einheitlichem Formulartitel (24px Schriftgröße)
- Standardisierten Button-Positionen
- Logo-Box links
- GPT/TEST-Box rechts
- Konsistente Abstände und Farben

## Betroffene Formulare (Priorität 1)

1. `frm_va_Auftragstamm.html` ✅ (Referenz)
2. `frm_MA_Mitarbeiterstamm.html`
3. `frm_KD_Kundenstamm.html`
4. `frm_OB_Objekt.html`

## Header-Struktur

```html
<div class="header-row-wrapper">
    <div class="header-row combined-buttons">
        <!-- Logo-Box links -->
        <div class="logo-box">C</div>

        <!-- Formulartitel -->
        <span class="title-text">[FORMULARTITEL]</span>

        <!-- Aktualisieren-Button direkt nach Titel -->
        <button class="btn unified-btn" id="btnAktualisieren"
                onclick="refreshData()"
                style="margin-left: 15px;">
            Aktualisieren
        </button>

        <!-- Formular-spezifische Buttons -->
        <div class="buttons-grid">
            <!-- Buttons in 2 Reihen à 6 Buttons -->
        </div>

        <!-- Header-Links ganz rechts (optional) -->
        <div class="header-links" style="margin-left: auto;">
            <span class="header-link" onclick="...">Link 1</span>
            <span class="header-link" onclick="...">Link 2</span>
        </div>
    </div>

    <!-- GPT/TEST Box rechts -->
    <div class="gpt-box">
        GPT | TEST<br>
        <span id="lblDatum">[Datum]</span>
    </div>
</div>
```

## CSS-Klassen

### Haupt-Container
- `.header-row-wrapper` - Umschließender Container
- `.header-row` - Flex-Container für Header-Inhalt
- `.combined-buttons` - Spezifischer für Button-Layout

### Elemente
- `.logo-box` - Logo links (40x40px, grau)
- `.title-text` - Formulartitel (24px, fett)
- `.btn.unified-btn` - Standard-Buttons
- `.buttons-grid` - Grid für Button-Matrix (2 Reihen, 6 Spalten)
- `.gpt-box` - Info-Box rechts (70x70px, grün)
- `.header-links` - Container für Text-Links
- `.header-link` - Einzelner Text-Link (klickbar)

## Schriftgrößen (siehe FORMULARTITEL_SCHRIFTGROESSE_SPEC.md)

- **Formulartitel:** 24px (var(--title-font-size))
- **Buttons:** 11px (var(--base-font-size))
- **Labels:** 11px (var(--base-font-size))
- **Links:** 11px (var(--base-font-size))

## Farben

### Logo-Box
- Background: `#999999` (grau)
- Text: `#ffffff` (weiß)
- Border: 1px solid #808080

### Formulartitel
- Text: `#000000` (schwarz)
- Font-Weight: bold

### Standard-Buttons (.unified-btn)
- Background: `#ece9d8` (beige)
- Border: 1px solid #808080
- Text: `#000000` (schwarz)

### GPT-Box
- Background: `#00ff00` (grün)
- Border: 1px solid #808080
- Text: `#000000` (schwarz)

## Layout-Eigenschaften

### header-row-wrapper
```css
display: flex;
justify-content: space-between;
align-items: flex-start;
padding: 5px 5px 3px 5px;
background-color: #ece9d8;
border-bottom: 1px solid #808080;
```

### header-row (combined-buttons)
```css
display: flex;
align-items: center;
gap: 8px;
flex: 1;
```

### buttons-grid
```css
display: grid;
grid-template-columns: repeat(6, auto);
grid-template-rows: repeat(2, auto);
gap: 4px;
margin-left: 0;
```

## Implementierungs-Richtlinien

### 1. Backup vor Änderung
```bash
cp frm_XXX.html frm_XXX.html.bak_20260115_HHMMSS
```

### 2. HTML-Struktur anpassen
- Bestehenden Header identifizieren
- Durch unified-header Struktur ersetzen
- Formular-spezifische Buttons in buttons-grid einfügen

### 3. CSS einbinden
```html
<link rel="stylesheet" href="css/unified-header.css">
```

### 4. Inline-Styles entfernen
- Alle inline-Styles die durch unified-header ersetzt werden
- AUSNAHME: Formular-spezifische Positionierungen behalten

### 5. Button-Funktionalität prüfen
- Alle onclick-Handler müssen erhalten bleiben
- IDs und data-testid Attribute beibehalten
- Event-Handler testen

## Besonderheiten pro Formular

### frm_va_Auftragstamm.html (Referenz)
- 2 Reihen à 6 Buttons
- Header-Links (Rückmelde-Statistik, Syncfehler)
- Checkbox "EL Autosend" in Grid integriert

### frm_MA_Mitarbeiterstamm.html
- Foto-Box statt Logo-Box (später)
- Spezifische Buttons für MA-Verwaltung
- Keine Header-Links

### frm_KD_Kundenstamm.html
- Standard Logo-Box
- Spezifische Buttons für KD-Verwaltung
- Keine Header-Links

### frm_OB_Objekt.html
- Standard Logo-Box
- Spezifische Buttons für OB-Verwaltung
- Keine Header-Links

## Validierung

Nach der Implementierung prüfen:
- [ ] Formulartitel hat 24px Schriftgröße
- [ ] Logo-Box ist 40x40px, grau
- [ ] GPT-Box ist 70x70px, grün
- [ ] Buttons haben konsistente Größe
- [ ] Alle Buttons funktionieren
- [ ] Header-Layout ist responsive
- [ ] Keine Layout-Probleme bei verschiedenen Auflösungen

## Nächste Schritte

1. unified-header.css erstellen ✅
2. Implementation in 4 Hauptformularen
3. Test aller Button-Funktionen
4. Dokumentation in HEADER_IMPLEMENTATION_REPORT.md
5. Optional: Weitere Formulare (Priorität 2)

## Referenzen

- Referenzformular: `frm_va_Auftragstamm.html`
- CSS-Datei: `css/unified-header.css`
- Schriftgrößen: `FORMULARTITEL_SCHRIFTGROESSE_SPEC.md`
