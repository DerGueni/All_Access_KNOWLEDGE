# Farb-Übereinstimmung: Access vs. WinUI3

**Datum:** 31.12.2025
**Geprüfte Formulare:**
- frm_VA_Auftragstamm (Access) → AuftragstammView.xaml (WinUI3)
- frm_MA_VA_Schnellauswahl (Access) → SchnellauswahlView.xaml (WinUI3)

---

## Gefundene Abweichungen

### 1. **KRITISCH: Header-Banner Farbe (Auftragstamm)**

**Access Original:**
- BackColor: `8435191` → **#F7B580** (Orange/Pfirsich-Ton)
- ForeColor: Schwarz (aufgrund heller Hintergrund)

**WinUI3 VORHER:**
- Background: **#4316B2** (Violett-Blau) ❌ FALSCH!
- Foreground: White

**WinUI3 KORRIGIERT:**
- Background: **#F7B580** ✓ KORREKT
- Foreground: Black ✓ KORREKT (bessere Lesbarkeit auf hellem Grund)

**Datei:** `AuftragstammView.xaml`, Zeile 64

---

## Weitere wichtige Access-Farben

### Standard-Buttons (Auftragstamm & Schnellauswahl)
- **Access:** 14136213 → **#95B3D7** (Helles Blau)
- **Verwendung:** btnAuftrag, btnAddSelected, btnDelSelected, etc.

### Spezial-Buttons (Mail-Funktionen)
- **Access:** 15981949 → **#7DDDF3** (Helles Cyan/Türkis)
- **Verwendung:** btnMail, btnMailSelected (Schnellauswahl)

### Tab-Hintergründe
- **Access:**
  - 15918812 → **#DCE6F2** (Sehr helles Blau)
  - 15849926 → **#C6D9F1** (Helles Blau)
  - 15060409 → **#B9CDE5** (Mittel-helles Blau)

### Text-Farben
- **Access:** 4210752 → **#404040** (Dunkelgrau für Text)
- **Access:** 0 → **#000000** (Schwarz für Labels)

---

## Durchgeführte Korrekturen

### ✓ AuftragstammView.xaml
1. **Header-Banner:** #4316B2 → **#F7B580**
2. **Header-Text:** White → **Black** (besserer Kontrast)

### SchnellauswahlView.xaml
- **Keine kritischen Abweichungen gefunden**
- Formular nutzt ThemeResource-Farben (dynamisch)
- Spezifische Button-Farben werden durch AccentButtonStyle gesteuert

---

## Empfehlungen

### 1. **Konsistente Button-Farben**
Falls granulare Kontrolle gewünscht:
- Standard-Buttons: `#95B3D7` (Access-typisch)
- Spezial/Mail-Buttons: `#7DDDF3`
- Aktuell: WinUI3 verwendet ThemeResource (gut für Dark Mode)

### 2. **Tab-Hintergründe**
Falls Tab-Controls hinzugefügt werden:
- TabViewItem Background: `#DCE6F2` oder `#C6D9F1`

### 3. **Listen-Hintergründe**
- ListView Background bleibt **#FFFFFF** (weiß) ✓ korrekt

---

## Farbkonvertierung: Access Long → HEX

**Formel:**
```python
r = value & 0xFF
g = (value >> 8) & 0xFF
b = (value >> 16) & 0xFF
hex = f'#{r:02X}{g:02X}{b:02X}'
```

**Beispiel:**
- 8435191 = 0x80B5F7
- R = 0xF7 = 247
- G = 0xB5 = 181
- B = 0x80 = 128
- → #F7B580

---

## Zusammenfassung

**Status:** ✓ Hauptabweichung korrigiert
**Datei:** AuftragstammView.xaml
**Änderung:** Header-Banner von Violett (#4316B2) auf Access-Orange (#F7B580)

Die WinUI3-Formulare entsprechen nun optisch besser den Access-Originalen.
