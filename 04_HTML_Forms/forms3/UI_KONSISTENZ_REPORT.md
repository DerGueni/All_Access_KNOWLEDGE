# UI-Konsistenz-Report - CONSYS HTML-Formulare

**Erstellt:** 2026-01-06
**Pfad:** `04_HTML_Forms\forms3\`
**Analysierte Dateien:** 80+ HTML-Formulare

---

## 1. Sidebar-Analyse

### 1.1 Lademechanismus

Es existieren **drei verschiedene Implementierungen** der Sidebar:

| Variante | Beschreibung | Verwendung |
|----------|--------------|------------|
| **Inline** | Sidebar-HTML und CSS direkt im Formular | Hauptformulare (frm_va_Auftragstamm, frm_MA_Mitarbeiterstamm, etc.) |
| **Shell-iframe** | Sidebar in shell.html, Formulare als iframe | shell.html, shell_webview2.html |
| **Separate Datei** | sidebar.html als eigenstaendige Komponente | Fuer iframe-Einbindung |

### 1.2 Sidebar-Praesenz

**Formulare MIT Sidebar (59 Dateien):**
- frm_va_Auftragstamm.html
- frm_MA_Mitarbeiterstamm.html
- frm_KD_Kundenstamm.html
- frm_OB_Objekt.html
- frm_N_Dienstplanuebersicht.html
- frm_VA_Planungsuebersicht.html
- frm_MA_Abwesenheit.html
- frm_MA_Zeitkonten.html
- frm_N_Stundenauswertung.html
- frm_N_Lohnabrechnungen.html
- frm_Menuefuehrung1.html
- und weitere...

**Formulare OHNE Sidebar (korrekt - Subformulare):**
- sub_DP_Grund.html
- sub_DP_Grund_MA.html
- sub_MA_Offene_Anfragen.html
- sub_MA_VA_Zuordnung.html
- sub_OB_Objekt_Positionen.html
- sub_ZusatzDateien.html
- HTMLBodies/* (Dokumentvorlagen)

### 1.3 Menuestruktur - Inkonsistenzen

| Formular | Menue-Items | Aktiver Menuepunkt |
|----------|-------------|-------------------|
| sidebar.html | 17 Items | Per postMessage gesteuert |
| shell.html | 12 Items (kategorisiert) | data-form Attribut |
| frm_va_Auftragstamm.html | 16 Items | Auftragsverwaltung (hartcodiert) |
| frm_MA_Mitarbeiterstamm.html | 16 Items | Mitarbeiterverwaltung (hartcodiert) |
| frm_KD_Kundenstamm.html | 16 Items | Kundenverwaltung (hartcodiert) |

**Probleme:**
1. Unterschiedliche Anzahl Menue-Items je nach Formular
2. Menue-Reihenfolge variiert
3. Einige Formulare fehlen im Menue bestimmter Formulare
4. Kategorien nur in shell.html vorhanden

---

## 2. Schriftgroessen-Audit

### 2.1 Gefundene font-size Werte

| Groesse | Verwendung | Haeufigkeit | Empfehlung |
|---------|------------|-------------|------------|
| 9px | Section-Titles, GPT-Box | selten | **Entfernen** - zu klein |
| 10px | Buttons, Labels, Inputs, Header-Links | haeufig | **11px** - vereinheitlichen |
| 11px | Standard Base-Font | sehr haeufig | **STANDARD** - beibehalten |
| 12px | Menu-Buttons, Sidebar-Header | haeufig | **STANDARD** fuer Menu |
| 13px | frm_va_Auftragstamm Base, Tab-Buttons | einige | **11px** - anpassen |
| 14px | Titel, Header, Buttons | haeufig | **STANDARD** fuer Titel |
| 16px | Haupttitel, App-Title | vereinzelt | **STANDARD** fuer Haupt-Titel |

### 2.2 Inkonsistenzen nach Formular

| Formular | Base font-size | Abweichungen |
|----------|---------------|--------------|
| frm_va_Auftragstamm.html | **13px** | Abweichend! |
| frm_MA_Mitarbeiterstamm.html | 11px | Korrekt |
| frm_KD_Kundenstamm.html | 11px | Korrekt |
| frm_OB_Objekt.html | 11px | Korrekt |
| sidebar.html | 11px | Korrekt |
| shell.html | 11px | Korrekt |
| consys-common.css | 11px | Korrekt |
| Auftragsverwaltung2.html | 11px | Inline-Styles mit 9-16px |

### 2.3 Empfohlene Standard-Groessen

```css
/* Typography Scale */
--font-size-xs: 9px;      /* Nur fuer Badges, Notizen */
--font-size-sm: 10px;     /* Status-Bar, GPT-Box */
--font-size-base: 11px;   /* Standard fuer alle Elemente */
--font-size-md: 12px;     /* Labels, Menu-Buttons */
--font-size-lg: 14px;     /* Section-Titel, wichtige Labels */
--font-size-xl: 16px;     /* Haupt-Titel */
--font-size-2xl: 18px;    /* Formular-Titel */
```

---

## 3. Button-Konsistenz

### 3.1 Gefundene Button-Varianten

**Variante A: CONSYS Standard (Gradient + keine Border)**
```css
.btn {
    background: linear-gradient(to bottom, #d0d0e0, #a0a0c0);
    border: none;
    padding: 4px 12px;
    font-size: 11px;
}
```
Verwendet in: frm_MA_Abwesenheit, frm_KD_Kundenstamm, frm_MA_Zeitkonten

**Variante B: Classic Windows (Gradient + 3D-Border)**
```css
.btn {
    background: linear-gradient(to bottom, #e8e8e8, #c0c0c0);
    border: 2px solid;
    border-color: #ffffff #808080 #808080 #ffffff;
    padding: 2px 8px;
    font-size: 10px;
}
```
Verwendet in: frm_va_Auftragstamm, consys-common.css

**Variante C: Modern (Gradient + 1px Border + Radius)**
```css
.btn {
    padding: 4px 12px;
    border: 1px solid #999;
    background: linear-gradient(180deg, #fff 0%, #e8e8e8 100%);
    border-radius: 3px;
}
```
Verwendet in: zfrm_MA_Stunden_Lexware, frm_va_Auftragstamm_v2

### 3.2 Farbige Button-Varianten

| Klasse | Variante A | Variante B | Empfehlung |
|--------|------------|------------|------------|
| .btn-green | #90c090 / #60a060 | #60c060 / #308030 | Variante A |
| .btn-red | #c09090 / #a06060 | #e06060 / #c04040 | Variante A |
| .btn-blue | #9090c0 / #6060a0 | #6080d0 / #4060a0 | Variante A |
| .btn-yellow | - | #e0e080 / #c0c040 | Hinzufuegen |

### 3.3 Hover/Active/Disabled States

| State | Variante A | Variante B | Empfehlung |
|-------|------------|------------|------------|
| :hover | #e0e0f0 / #b0b0d0 | #f0f0f0 / #d0d0d0 | Variante A |
| :active | Nicht definiert | Nicht definiert | Hinzufuegen |
| :disabled | opacity: 0.5 | opacity: 0.6 | opacity: 0.6 |

---

## 4. Farb-Inkonsistenzen

### 4.1 Hintergrundfarben

| Element | Gefundene Werte | Empfehlung |
|---------|-----------------|------------|
| Body/Window | #8080c0 | **Standard** |
| Sidebar | #6060a0 | **Standard** |
| Content-Area | #8080c0, #b8b8d8, #9090c0 | **#8080c0** (anpassen) |
| Header-Row | #9090c0 | **Standard** |
| Title-Bar | linear-gradient(#000080, #1084d0) | **Standard** |
| Sidebar-Header | #000080 | **Standard** |

### 4.2 Textfarben

| Element | Gefundene Werte | Empfehlung |
|---------|-----------------|------------|
| Standard-Text | #000, #333, #404040 | **#000000** |
| Sidebar-Text | #000 | **Standard** |
| Title-Bar-Text | white | **Standard** |
| Titel/Header | #000080 | **Standard** |
| Link | #000080 (underline) | **Standard** |

### 4.3 Border-Farben

| Element | Gefundene Werte | Empfehlung |
|---------|-----------------|------------|
| Input-Border | #808080, #7070a0, #888 | **#7070a0** |
| Section-Border | #606090, #505090, #7070a0 | **#606090** |
| 3D-Border (light) | #ffffff, #e0e0f0 | **#ffffff** |
| 3D-Border (dark) | #808080, #606060, #404070 | **#606060** |

---

## 5. Layout-Inkonsistenzen

### 5.1 Sidebar-Breite

| Formular | Sidebar-Breite |
|----------|----------------|
| sidebar.html | 185px |
| shell.html | 200px |
| shell_webview2.html | 220px |
| frm_va_Auftragstamm.html | 185px |
| frm_MA_Mitarbeiterstamm.html | 185px |

**Empfehlung:** 185px als Standard

### 5.2 Padding/Spacing

| Element | Gefundene Werte | Empfehlung |
|---------|-----------------|------------|
| Sidebar-Padding | 5px | **Standard** |
| Content-Padding | 3px, 8px, 10px | **4px** |
| Button-Padding | 2-8px / 8-20px | **4px 12px** |
| Menu-Button-Padding | 6-8px / 10px | **8px 10px** |

---

## 6. Zu aendernde Formulare

### 6.1 Hohe Prioritaet (Hauptformulare)

| Formular | Aenderungen |
|----------|-------------|
| frm_va_Auftragstamm.html | Base font-size: 13px -> 11px, Button-Style vereinheitlichen |
| Auftragsverwaltung2.html | Inline-Styles entfernen, CSS-Variablen nutzen |
| shell.html | Sidebar-Breite: 200px -> 185px |
| shell_webview2.html | Sidebar-Breite: 220px -> 185px |

### 6.2 Mittlere Prioritaet

| Formular | Aenderungen |
|----------|-------------|
| frm_KD_Verrechnungssaetze.html | Button-Padding: 8px 20px -> 4px 12px |
| zfrm_Rueckmeldungen.html | Button-Padding: 8px 20px -> 4px 12px |
| zfrm_SyncError.html | Button-Padding: 8px 20px -> 4px 12px |
| frm_KD_Umsatzauswertung.html | Button-Padding: 8px 20px -> 4px 12px |

### 6.3 Niedrige Prioritaet (Varianten/Test)

- design_varianten/*.html (behalten eigene Styles)
- sidebar_varianten/*.html (behalten eigene Styles)
- *_test.html, *_backup.html (nicht aendern)

---

## 7. Empfohlene naechste Schritte

1. **CSS-Variablen-Datei erstellen:** `css/variables.css`
2. **Alle Formulare aktualisieren:** CSS-Variablen einbinden
3. **Inline-Styles reduzieren:** Durch Klassen ersetzen
4. **Sidebar-Komponente zentralisieren:** Eine Quelle fuer alle Formulare
5. **Menue-Struktur vereinheitlichen:** Gleiche Items in gleicher Reihenfolge

---

## 8. CSS-Variablen-Datei

Siehe: `css/variables.css` (separate Datei)
