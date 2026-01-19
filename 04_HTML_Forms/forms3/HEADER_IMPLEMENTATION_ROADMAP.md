# Header Implementierungs-Roadmap

**Ziel:** Einheitliche Header in allen 19 Hauptformularen
**Geschätzter Gesamtaufwand:** 6-9 Stunden
**Priorität:** Hoch (kritisch für UI-Konsistenz)

---

## Phase 1: Kritische Stammdaten-Formulare (Priorität: SOFORT)

**Zeitaufwand:** 2-3 Stunden
**Betroffene Formulare:** 4

Diese Formulare sind die Kernstücke der Anwendung und werden am häufigsten verwendet:

### 1.1 frm_va_Auftragstamm.html
- **Status:** Kein Header
- **Aufwand:** 45 min
- **Änderungen:**
  - `.title-bar` entfernen
  - `.form-header` hinzufügen mit "Auftragsverwaltung"
  - Buttons aus Content-Area in Header verschieben
  - CSS anpassen: #d3d3d3, 70px Höhe, 24px Titel

### 1.2 frm_KD_Kundenstamm.html
- **Status:** Kein Header
- **Aufwand:** 40 min
- **Änderungen:**
  - `.title-bar` entfernen
  - `.form-header` hinzufügen mit "Kundenstammblatt"
  - Buttons in Header integrieren
  - CSS anpassen

### 1.3 frm_MA_Mitarbeiterstamm.html
- **Status:** Kein Header
- **Aufwand:** 40 min
- **Änderungen:**
  - `.title-bar` entfernen
  - `.form-header` hinzufügen mit "Mitarbeiterstammblatt"
  - Foto-Bereich beibehalten (unterhalb Header)
  - CSS anpassen

### 1.4 frm_OB_Objekt.html
- **Status:** Kein Header
- **Aufwand:** 40 min
- **Änderungen:**
  - `.title-bar` entfernen
  - `.form-header` hinzufügen mit "Objektstamm"
  - Buttons in Header integrieren
  - CSS anpassen

**Checkpoint:** Nach Phase 1 sollten die 4 wichtigsten Formulare einheitliche Header haben.

---

## Phase 2: Planungs- und Verwaltungs-Formulare (Priorität: HOCH)

**Zeitaufwand:** 2 Stunden
**Betroffene Formulare:** 4

### 2.1 frm_MA_VA_Schnellauswahl.html
- **Status:** Kein Header
- **Aufwand:** 30 min
- **Änderungen:** Standard-Header implementieren mit "MA-VA Schnellauswahl"

### 2.2 frm_MA_Zeitkonten.html
- **Status:** Kein Header
- **Aufwand:** 30 min
- **Änderungen:** Standard-Header mit "Mitarbeiter-Zeitkonten"

### 2.3 frm_Menuefuehrung1.html
- **Status:** Kein Header
- **Aufwand:** 30 min
- **Änderungen:** Dashboard-Header mit "CONSYS Dashboard"

### 2.4 frm_MA_VA_Positionszuordnung.html
- **Status:** Kein Header
- **Aufwand:** 30 min
- **Änderungen:** Standard-Header mit "Positionszuordnung"

**Checkpoint:** Nach Phase 2 sind 8 von 19 Formularen fertig.

---

## Phase 3: Formulare mit Farb-Problemen (Priorität: MITTEL)

**Zeitaufwand:** 1.5 Stunden
**Betroffene Formulare:** 5

Diese Formulare haben Header, aber mit falschen Farben oder fehlenden Eigenschaften:

### 3.1 frm_Einsatzuebersicht.html
- **Status:** Header vorhanden, aber blaue Farbe
- **Aufwand:** 20 min
- **Änderungen:**
  - `.header-bar` → `.form-header`
  - `linear-gradient(to right, #000080, #1084d0)` → `#d3d3d3`
  - Feste Höhe 70px hinzufügen

### 3.2 frm_N_Bewerber.html
- **Status:** Header vorhanden, aber blaue Farbe
- **Aufwand:** 20 min
- **Änderungen:** Wie 3.1

### 3.3 frm_abwesenheitsuebersicht.html
- **Status:** Header vorhanden, aber blaue Farbe
- **Aufwand:** 20 min
- **Änderungen:** Wie 3.1

### 3.4 frm_MA_Abwesenheit.html
- **Status:** Grauer Header, aber keine Titel-Schriftgröße
- **Aufwand:** 15 min
- **Änderungen:**
  - `.form-title` Klasse hinzufügen
  - `font-size: 24px` festlegen

### 3.5 frm_Ausweis_Create.html
- **Status:** Header vorhanden, aber keine Farbe
- **Aufwand:** 20 min
- **Änderungen:**
  - Hintergrundfarbe `#d3d3d3` hinzufügen
  - Titel-Schriftgröße 24px

**Checkpoint:** Nach Phase 3 sind 13 von 19 Formularen fertig.

---

## Phase 4: Dienstplan-Formulare Fine-Tuning (Priorität: NIEDRIG)

**Zeitaufwand:** 30 min
**Betroffene Formulare:** 2

### 4.1 frm_DP_Dienstplan_MA.html
- **Status:** Fast perfekt, nur Titel-Schriftgröße fehlt
- **Aufwand:** 15 min
- **Änderungen:** `.form-title` mit 24px hinzufügen

### 4.2 frm_DP_Dienstplan_Objekt.html
- **Status:** Perfekt! ✅
- **Aufwand:** 0 min
- **Als Referenz nutzen**

**Checkpoint:** Nach Phase 4 sind 15 von 19 Formularen fertig.

---

## Phase 5: Sonstige Formulare (Priorität: NIEDRIG)

**Zeitaufwand:** 1 Stunde
**Betroffene Formulare:** 4

### 5.1 frm_Abwesenheiten.html
- **Status:** Kein Header
- **Aufwand:** 15 min

### 5.2 frm_Kundenpreise_gueni.html
- **Status:** Kein Header
- **Aufwand:** 15 min

### 5.3 frm_Rueckmeldestatistik.html
- **Status:** Kein Header
- **Aufwand:** 15 min

### 5.4 frm_Systeminfo.html
- **Status:** Kein Header
- **Aufwand:** 15 min

**Checkpoint:** Nach Phase 5 sind ALLE 19 Formulare fertig! 🎉

---

## Technische Implementierungs-Checkliste

Für jedes Formular:

### ✅ HTML-Änderungen

1. **Alte Struktur entfernen:**
   ```html
   <!-- ENTFERNEN: -->
   <div class="title-bar" style="display: none;">...</div>
   ```

2. **Neue Header-Struktur hinzufügen:**
   ```html
   <div class="form-header">
       <h1 class="form-title">Formular-Titel</h1>
       <div class="header-buttons">
           <button class="header-btn" onclick="...">Button 1</button>
           <button class="header-btn" onclick="...">Button 2</button>
       </div>
   </div>
   ```

### ✅ CSS-Änderungen

3. **Header-Styles hinzufügen:**
   ```css
   .form-header {
       background-color: #d3d3d3;
       height: 70px;
       padding: 0 20px;
       display: flex;
       justify-content: space-between;
       align-items: center;
       border-bottom: 1px solid #b0b0b0;
   }

   .form-title {
       font-size: 24px;
       font-weight: bold;
       color: #333;
       margin: 0;
   }

   .header-buttons {
       display: flex;
       gap: 8px;
   }

   .header-btn {
       padding: 6px 12px;
       font-size: 12px;
       background: linear-gradient(to bottom, #e0e0e0, #c0c0c0);
       border: 1px solid #a0a0a0;
       cursor: pointer;
   }

   .header-btn:hover {
       background: linear-gradient(to bottom, #f0f0f0, #d0d0d0);
   }
   ```

4. **Alte Styles entfernen:**
   ```css
   /* ENTFERNEN: */
   .title-bar { display: none; }
   .header-bar { background: linear-gradient(...); }
   ```

### ✅ Funktionalitäts-Test

5. **Nach Implementierung testen:**
   - [ ] Formular öffnet ohne Fehler
   - [ ] Header hat graue Farbe (#d3d3d3)
   - [ ] Titel ist 24px groß und linksbündig
   - [ ] Buttons sind rechtsbündig und 12px groß
   - [ ] Buttons funktionieren (onclick-Handler)
   - [ ] Layout ist responsive
   - [ ] Keine Console-Errors

---

## Automatisierungs-Möglichkeiten

### Option A: Manuell (empfohlen)
- Präzise Kontrolle
- Jedes Formular individuell anpassen
- Zeitaufwand: 6-9 Stunden

### Option B: Script-unterstützt
Erstelle ein Python-Script das:
1. Alte `.title-bar` Struktur entfernt
2. Standard-Header-HTML einfügt
3. Standard-CSS hinzufügt
4. Buttons in Header verschiebt

**Vorteil:** Schneller (2-3 Stunden)
**Nachteil:** Weniger Kontrolle, evtl. manuelle Nacharbeit nötig

---

## Qualitätssicherung

### Nach jeder Phase:

1. **Visueller Test**
   - Screenshots aller geänderten Formulare
   - Vergleich mit Referenz (frm_DP_Dienstplan_Objekt.html)

2. **Funktionaler Test**
   - Alle Buttons testen
   - Formular-Logik testen (Laden, Speichern, etc.)

3. **Browser-Test**
   - Chrome/Edge (WebView2)
   - Standalone Browser

4. **Responsive-Test**
   - 1920x1080 (Standard)
   - 1366x768 (Laptop)
   - 1280x720 (Klein)

### Finale Validierung:

Führe das Validierungs-Script erneut aus:
```bash
python _scripts/validate_headers.py
```

**Ziel:** 19/19 Formulare mit Status "OK"

---

## Rollback-Plan

Falls Probleme auftreten:

1. **Git Backups nutzen**
   - Vor jeder Phase: Git Commit erstellen
   - Bei Problemen: `git revert` auf letzten stabilen Commit

2. **Backup-Ordner**
   - Alle Dateien vor Änderung nach `forms3/backups/` kopieren
   - Timestamp-basierter Ordner: `backups/2026-01-15_1400/`

3. **Einzelformular-Rollback**
   - Nur betroffenes Formular zurücksetzen
   - Andere Formulare behalten Änderungen

---

## Timeline (Gesamt-Übersicht)

| Phase | Formulare | Aufwand | Kumulativ | Status |
|-------|-----------|---------|-----------|--------|
| Phase 1 | 4 (Stammdaten) | 2.5h | 2.5h | 🔴 Kritisch |
| Phase 2 | 4 (Planung) | 2h | 4.5h | 🟡 Hoch |
| Phase 3 | 5 (Farben) | 1.5h | 6h | 🟡 Mittel |
| Phase 4 | 2 (Dienstplan) | 0.5h | 6.5h | 🟢 Niedrig |
| Phase 5 | 4 (Sonstige) | 1h | 7.5h | 🟢 Niedrig |
| **Testing** | Alle | 1.5h | 9h | - |

**Gesamtaufwand:** 9 Stunden (inkl. Testing)

---

## Erfolgs-Kriterien

### Definition of Done (DoD):

Ein Formular gilt als "fertig" wenn:

1. ✅ Header vorhanden mit Klasse `.form-header`
2. ✅ Hintergrundfarbe `#d3d3d3`
3. ✅ Höhe 70px (±10px)
4. ✅ Titel 24px groß, linksbündig, fett
5. ✅ Buttons rechtsbündig, 12px groß
6. ✅ Alle Buttons funktionieren
7. ✅ Keine Console-Errors
8. ✅ Responsive bis 1280px Breite

### Projektabschluss:

Das Projekt gilt als abgeschlossen wenn:

- ✅ Alle 19 Formulare erfüllen die DoD
- ✅ Validierungs-Script zeigt 19/19 OK
- ✅ Alle manuellen Tests bestanden
- ✅ Dokumentation aktualisiert

---

**Erstellt am:** 2026-01-15
**Erstellt von:** Claude Code (Sonnet 4.5)
**Version:** 1.0
