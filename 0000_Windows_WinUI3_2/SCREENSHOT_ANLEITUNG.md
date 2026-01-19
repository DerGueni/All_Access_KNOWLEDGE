# Screenshot-Anleitung für WinUI3 App Vergleich

## Ziel
Screenshots der WinUI3-App und der Access-Anwendung erstellen, um einen visuellen Side-by-Side-Vergleich durchzuführen.

---

## SCHRITT 1: WinUI3 App starten

1. **App-Pfad:**
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ConsysWinUI\ConsysWinUI\bin\x64\Debug\net8.0-windows10.0.19041.0\ConsysWinUI.exe
   ```

2. **Starten:**
   - Doppelklick auf `ConsysWinUI.exe`
   - ODER: Via Visual Studio debuggen (F5)

3. **Navigation:**
   - App sollte Dashboard zeigen
   - In Sidebar: "Mitarbeiterverwaltung" klicken (sollte beige/sand sein)
   - MitarbeiterstammView sollte erscheinen

---

## SCHRITT 2: Screenshot der WinUI3-App

### Variante A: Windows Snipping Tool

1. `Windows + Shift + S` drücken
2. Bereich auswählen (gesamtes Fenster)
3. Speichern unter:
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\WINUI_SCREENSHOT.png
   ```

### Variante B: Alt + Print

1. WinUI3-App-Fenster aktiv machen
2. `Alt + Druck` drücken
3. Paint öffnen (`Win + R` → `mspaint`)
4. Einfügen (`Strg + V`)
5. Speichern unter:
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\WINUI_SCREENSHOT.png
   ```

### Variante C: PowerShell (automatisch)

```powershell
# App-Fenster muss offen sein!
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Warte 3 Sekunden zum Vorbereiten
Start-Sleep -Seconds 3

# Screenshot des gesamten Bildschirms
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
$bitmap.Save("C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\WINUI_SCREENSHOT.png")
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot gespeichert!"
```

---

## SCHRITT 3: Screenshot der Access-Anwendung

1. **Access öffnen:**
   ```
   S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb
   ```

2. **Formular öffnen:**
   - Im Access-Navigationsbereich: `frm_MA_Mitarbeiterstamm` öffnen
   - ODER: `Strg + G` → `DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"` → Enter

3. **Screenshot erstellen:**
   - `Alt + Druck` (nur Access-Fenster)
   - In Paint einfügen und speichern unter:
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\ACCESS_SCREENSHOT.png
   ```

---

## SCHRITT 4: Vergleich durchführen

### Zu vergleichende Elemente:

1. **Farben:**
   - [ ] Sidebar-Hintergrund (Access vs. WinUI)
   - [ ] Sidebar-Buttons (Standard vs. Aktiv)
   - [ ] Haupthintergrund
   - [ ] Button-Farben (blau, gelb, beige)
   - [ ] Tab-Control Hintergrund
   - [ ] TextBox-Rahmen

2. **Layout:**
   - [ ] Sidebar-Breite
   - [ ] Abstände zwischen Controls
   - [ ] Kopfzeilen-Höhe
   - [ ] Spaltenbreiten (Links/Rechts)
   - [ ] Listen-Spalte rechts

3. **Typografie:**
   - [ ] Schriftgröße (Access vs. WinUI)
   - [ ] Schriftart (Tahoma/Calibri vs. Segoe UI)
   - [ ] Fettdruck (Labels, Titel)

4. **Controls:**
   - [ ] Button-Größen
   - [ ] TextBox-Höhen
   - [ ] Icon vs. Emoji
   - [ ] Foto-Platzhalter

5. **Details:**
   - [ ] Border-Thickness
   - [ ] Padding/Margins
   - [ ] Koordinaten-Feld (gelber Hintergrund)
   - [ ] Navigation-Buttons

---

## SCHRITT 5: Erstelle Vergleichsbericht

Nach den Screenshots:

1. **Öffne beide Bilder nebeneinander**
2. **Dokumentiere Unterschiede:**
   - Farben (mit HEX-Werten)
   - Größen (in Pixel messen)
   - Positionen

3. **Erstelle Markdown-Datei:**
   ```
   C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0000_Windows_WinUI3_2\VERGLEICHSBERICHT.md
   ```

---

## WERKZEUGE FÜR ANALYSE

### Farben auslesen:
- **ColorPic** (kostenlos): https://www.colorpic.com/
- **Windows PowerToys** → Color Picker (`Win + Shift + C`)

### Pixel messen:
- **Windows Ruler**: https://github.com/bluegrams/ScreenRuler
- **Paint.NET** mit Linealen

### Screenshot-Vergleich:
- **Beyond Compare** (Side-by-Side Image Compare)
- **DiffImg**: https://github.com/nicolashahn/diffimg

---

## BEISPIEL: Farbabweichungen dokumentieren

| Element | Access | WinUI3 | Unterschied |
|---------|--------|--------|-------------|
| Sidebar BG | `#8B0000` | `#8B0000` | ✅ Identisch |
| Button Aktiv | `#D4A574` | `#D4A574` | ✅ Identisch |
| Haupthintergrund | `#F0F0F0` | `#F0F0F0` | ✅ Identisch |
| Blauer Button | `#95B3D7` | `#95B3D7` | ✅ Identisch |

---

## WICHTIG: Was beachten?

1. **Gleiche Auflösung:**
   - Access und WinUI3 Fenster auf gleiche Größe ziehen

2. **Gleiche Daten:**
   - Denselben Mitarbeiter anzeigen (z.B. MA_ID = 1)

3. **Gleicher Zustand:**
   - Tab "Stammdaten" offen
   - Keine modalen Dialoge

4. **Gleiche Skalierung:**
   - Windows Display-Skalierung prüfen (100% empfohlen)

---

## NACH DEN SCREENSHOTS

Sobald beide Screenshots vorliegen:

1. **Claude die Bilder zeigen:**
   ```
   "Hier sind die Screenshots: ACCESS_SCREENSHOT.png und WINUI_SCREENSHOT.png.
   Bitte erstelle einen detaillierten Vergleichsbericht."
   ```

2. **Claude wird analysieren:**
   - Farbunterschiede
   - Layout-Abweichungen
   - Typografie-Unterschiede
   - Fehlende/zusätzliche Elemente

3. **Anpassungen vornehmen:**
   - XAML-Datei bearbeiten
   - Farben korrigieren
   - Größen angleichen
   - Positionen fixen

---

**Bereit?** Dann starte mit Schritt 1!
