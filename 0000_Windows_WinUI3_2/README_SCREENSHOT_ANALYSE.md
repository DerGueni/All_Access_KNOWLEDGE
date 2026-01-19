# WinUI3 Screenshot-Analyse - Quick Start

**Ziel:** Visuelle 1:1-Nachbildung des Access-Formulars `frm_MA_Mitarbeiterstamm` in WinUI3 validieren.

---

## 📁 Erstellte Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| **WINUI_CURRENT_STATE.md** | Vollständige Ist-Zustand-Dokumentation der WinUI3-App (Farben, Größen, Fonts, Borders) |
| **SCREENSHOT_ANLEITUNG.md** | Schritt-für-Schritt Anleitung zum Erstellen der Screenshots |
| **ANALYSE_ZUSAMMENFASSUNG.md** | Zusammenfassung der Analyse, offene Fragen, nächste Schritte |
| **analyze_access_json.py** | Python-Skript zur Extraktion der Access-Eigenschaften aus JSON |
| **README_SCREENSHOT_ANALYSE.md** | Diese Datei - Quick Start Guide |

---

## 🚀 Schnellstart

### Option 1: Manuell (empfohlen)

1. **WinUI3-App starten:**
   ```
   Doppelklick: ConsysWinUI\ConsysWinUI\bin\x64\Debug\net8.0-windows10.0.19041.0\ConsysWinUI.exe
   ```

2. **Screenshot erstellen:**
   - `Windows + Shift + S` → Bereich auswählen
   - Speichern: `WINUI_SCREENSHOT.png`

3. **Access-App öffnen:**
   ```
   S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb
   ```

4. **Formular öffnen:**
   - `Strg + G` → `DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"`

5. **Screenshot erstellen:**
   - `Alt + Druck` (nur Access-Fenster)
   - In Paint einfügen → Speichern: `ACCESS_SCREENSHOT.png`

6. **Vergleichen:**
   - Beide Screenshots nebeneinander öffnen
   - Farben, Größen, Layout vergleichen

### Option 2: Automatisch (Python)

```bash
# Access-JSON analysieren
python analyze_access_json.py > ACCESS_PROPERTIES.txt

# Ausgabe enthält:
# - Formular-Farben (HEX)
# - Control-Größen (Pixel)
# - Positionen
# - Font-Eigenschaften
```

---

## 🔍 Was analysiert wurde

### ✅ WinUI3-App (XAML)

- **Farben:** Alle HEX-Werte extrahiert
- **Layout:** Grid-Struktur, Spaltenbreiten, Höhen
- **Fonts:** Größen, Weights
- **Styles:** Alle ResourceDictionary-Einträge
- **Bindings:** ViewModel-Verknüpfungen
- **Controls:** Buttons, TextBoxen, Labels, Tab-Control, ListView

### ⏳ Access-App (JSON - noch ausstehend)

- **Quelle:** `11_json_Export/.../FRM_frm_MA_Mitarbeiterstamm.json`
- **Analyse-Tool:** `analyze_access_json.py`
- **Manuelle Ausführung nötig** (JSON zu groß für automatische Analyse)

---

## 🎯 Kritische Vergleichspunkte

| Element | WinUI3 (aktuell) | Access (zu prüfen) | Status |
|---------|------------------|-------------------|--------|
| **Sidebar BG** | `#8B0000` | ❓ | ⏳ Ungeprüft |
| **Sidebar Aktiv** | `#D4A574` | ❓ | ⏳ Ungeprüft |
| **Blauer Button** | `#95B3D7` | ❓ | ⏳ Ungeprüft |
| **Tab-Button** | `#C0FF00` | ❓ | ⏳ Ungeprüft |
| **Sidebar Width** | `140px` | ❓ | ⏳ Ungeprüft |
| **Listen-Spalte** | `200px` | ❓ | ⏳ Ungeprüft |
| **Font** | Segoe UI | ❓ (Tahoma?) | ⏳ Ungeprüft |
| **TextBox Height** | `22px` | ❓ | ⏳ Ungeprüft |

---

## 📊 Dokumentierte Eigenschaften

### Farben (WinUI3)
- Page Background: `#F0F0F0`
- Sidebar: `#8B0000`
- Sidebar Button: `#A05050`
- Sidebar Aktiv: `#D4A574`
- Blauer Button: `#95B3D7`
- Tab-Button: `#C0FF00`
- Koordinaten-Highlight: `#FFFACD`

### Layout (WinUI3)
- Sidebar: `140px` breit
- Linke Spalte (Stammdaten): `320px`
- Rechte Spalte (Stammdaten): `350px`
- Listen-Spalte: `200px`
- Foto-Bereich: `120px`

### Fonts (WinUI3)
- Formular-Titel: `14pt Bold`
- Nachname/Vorname: `16pt Bold`
- Labels: `12pt Normal`
- TextBox: `12pt Normal`
- Buttons: `11pt Normal`
- Listen: `10pt Normal`

---

## 🛠️ Werkzeuge für Analyse

### Farben auslesen:
- **Windows PowerToys** → Color Picker (`Win + Shift + C`)
- **ColorPic**: https://www.colorpic.com/

### Pixel messen:
- **Paint.NET** mit Linealen
- **ScreenRuler**: https://github.com/bluegrams/ScreenRuler

### Screenshots vergleichen:
- **Beyond Compare** (Side-by-Side)
- **DiffImg**: https://github.com/nicolashahn/diffimg

---

## 📝 Nächste Schritte

1. **Screenshots erstellen** (siehe `SCREENSHOT_ANLEITUNG.md`)
2. **Python-Skript ausführen:**
   ```bash
   python analyze_access_json.py > ACCESS_PROPERTIES.txt
   ```
3. **Vergleichsbericht erstellen:**
   - Farben vergleichen
   - Größen vergleichen
   - Abweichungen dokumentieren
4. **XAML anpassen** (falls nötig)
5. **Neutest** durchführen

---

## 🔗 Relevante Dateien

### WinUI3-App:
```
ConsysWinUI\ConsysWinUI\Views\MitarbeiterstammView.xaml
```

### Access-JSON:
```
11_json_Export\000_Consys_Eport_11_25\30_forms\FRM_frm_MA_Mitarbeiterstamm.json
```

### Screenshots (zu erstellen):
```
WINUI_SCREENSHOT.png
ACCESS_SCREENSHOT.png
```

---

## ❓ Fragen?

Siehe detaillierte Dokumentation:
- **Ist-Zustand:** `WINUI_CURRENT_STATE.md`
- **Anleitung:** `SCREENSHOT_ANLEITUNG.md`
- **Analyse:** `ANALYSE_ZUSAMMENFASSUNG.md`

---

**Bereit?** Los geht's mit den Screenshots! 📸
