# REPORT: Button-Farben

**Erstellt:** 2026-01-08
**Status:** ABGESCHLOSSEN

---

## 1. Button-Farbsystem

### Definierte Klassen:

| Klasse | Hintergrund | Schriftfarbe | Verwendung |
|--------|-------------|--------------|------------|
| `.btn` | linear-gradient(#e8e8e8, #c0c0c0) | schwarz (Standard) | Standard-Buttons |
| `.btn-green` | linear-gradient(#60c060, #308030) | weiss | Aktions-Buttons (Speichern) |
| `.btn-blue` | linear-gradient(#6080d0, #4060a0) | weiss | Info-Buttons |
| `.btn-red` | linear-gradient(#e06060, #c04040) | weiss | Loeschen-Buttons |
| `.btn-yellow` | linear-gradient(#e0e080, #c0c040) | schwarz | Warn-Buttons |
| `.menu-btn` | linear-gradient(#d0d0e0, #a0a0c0) | schwarz | Sidebar-Menu |
| `.title-btn` | #ece9d8 | schwarz | Fenster-Buttons |
| `.title-btn.close` | #c75050 | weiss | Schliessen-Button |

---

## 2. Hell/Dunkel-Regel

**Regel:**
- Heller Hintergrund (>50% Helligkeit) → Schwarze Schrift
- Dunkler Hintergrund (<50% Helligkeit) → Weisse Schrift

### Korrigierte Buttons:

**frm_KD_Kundenstamm.html (3 Korrekturen):**
| Klasse | Vorher | Nachher |
|--------|--------|---------|
| `.btn-green` | keine color | `color: white` |
| `.btn-blue` | keine color | `color: white` |
| `.btn-red` | keine color | `color: white` |

**frm_OB_Objekt.html (3 Korrekturen):**
| Klasse | Vorher | Nachher |
|--------|--------|---------|
| `.btn-green` | keine color | `color: white` |
| `.btn-blue` | keine color | `color: white` |
| `.btn-red` | keine color | `color: white` |

---

## 3. Inventur

### frm_MA_Mitarbeiterstamm.html
- 10 Button-Klassen definiert
- Alle Hell/Dunkel-Regeln korrekt
- Keine Korrekturen noetig

### frm_KD_Kundenstamm.html
- 7 Button-Klassen definiert
- **3 Korrekturen** durchgefuehrt (Zeilen 240, 245, 250)

### frm_va_Auftragstamm.html
- 8 Button-Klassen definiert
- Alle Hell/Dunkel-Regeln korrekt
- Keine Korrekturen noetig

### frm_OB_Objekt.html
- 11 Button-Klassen definiert
- **3 Korrekturen** durchgefuehrt (Zeilen 252, 262, 267)

---

## 4. Zusammenfassung

| Metrik | Wert |
|--------|------|
| Formulare geprueft | 4 |
| Button-Klassen gesamt | 36 |
| Buttons korrekt | 30 |
| Buttons korrigiert | 6 |
| Buttons OK nach Fix | 36 (100%) |

---

## 5. Definition of Done

- [x] Alle Buttons halten die Hell/Dunkel-Schriftregel ein
- [x] Zentrale Button-Klassen definiert
- [x] Inline-Styles durch Klassen ersetzt (wo moeglich)
- [x] Keine Button mit schwarzer Schrift auf dunklem Hintergrund

---

*Erstellt von Claude Code*
