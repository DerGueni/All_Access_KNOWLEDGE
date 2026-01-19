# REPORT: Button-Layout / Anordnung

**Erstellt:** 2026-01-08
**Status:** ABGESCHLOSSEN

---

## 1. Analyse: Button-Gruppen mit >6 Buttons

### Gefundene Gruppen:

| Formular | Container | Anzahl | Layout | Status |
|----------|-----------|--------|--------|--------|
| frm_MA_Mitarbeiterstamm | .header-row | 18 | flex-wrap: wrap | OK |
| frm_va_Auftragstamm | .header-row.combined-buttons | 13 | flex-wrap: wrap | OK |
| frm_KD_Kundenstamm | .header-row | 11 | flex-wrap: wrap | OK |
| frm_OB_Objekt | .button-row | 9 | flex-wrap: wrap | OK |
| frm_OB_Objekt | .tab-buttons (Positionen) | 10 | flex-wrap: wrap | OK |

---

## 2. Implementierte Layout-Loesung

Alle Header-Rows verwenden bereits:
```css
.header-row {
    display: flex;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap;  /* Automatischer Umbruch bei Platzmangel */
}
```

### Vorteile:
- Buttons brechen automatisch in neue Zeilen um
- Einheitlicher Abstand (gap: 6px)
- Kein manueller Zeilenumbruch noetig
- Responsive bei Fenster-Resize

---

## 3. Spezielle Anpassungen

### frm_va_Auftragstamm.html
- Container hat feste Hoehe: `height: 95px`
- Ermoeglicht 2 Button-Reihen
- Kombination aus Buttons, Checkbox und Select

### frm_MA_Mitarbeiterstamm.html
- 18 Elemente in Header-Row
- Flex-Wrap sorgt fuer automatischen Umbruch
- Dropdown-Menues fuer Button-Gruppen (Excel Export)

---

## 4. CSS-Regeln

Die Standard-Regeln fuer Button-Container:

```css
.header-row, .button-row, .toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    align-items: center;
}

.btn {
    flex-shrink: 0;  /* Buttons nicht quetschen */
}
```

---

## 5. Keine Aenderungen noetig

Alle Formulare hatten bereits `flex-wrap: wrap` implementiert.
Die Button-Anordnung funktioniert korrekt.

---

## 6. Definition of Done

- [x] Bereiche mit >6 Buttons identifiziert
- [x] Layout prueft automatisch auf Umbruch
- [x] Buttons ueberlappen nicht
- [x] Zeilen optisch klar getrennt (gap)
- [x] Abstaende zwischen Buttons einheitlich

---

*Erstellt von Claude Code*
