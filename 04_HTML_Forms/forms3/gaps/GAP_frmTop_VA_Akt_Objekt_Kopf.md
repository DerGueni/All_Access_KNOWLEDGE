# Gap-Analyse: frmTop_VA_Akt_Objekt_Kopf

**Datum:** 2026-01-12
**Formular-Typ:** Popup - Objekt-Kopfdaten (Absperrzeit)
**Priorität:** NIEDRIG

---

## 1. Übersicht

| Aspekt | Access | HTML | Status |
|--------|--------|------|--------|
| **Formular-Typ** | Popup-Formular | Placeholder | ❌ Nicht implementiert |
| **Record Source** | tbl_VA_Akt_Objekt_Kopf | KEINE API | ❌ Fehlt |
| **Zweck** | Objektkopf + Absperrzeit | - | ❌ Fehlt |
| **Subforms** | 2 (Schichten, Positionen) | - | ❌ Fehlt |

---

## 2. Controls (Komplex!)

### Access (28+ Controls)

**Hauptbereich:**
- **VA_ID** (ComboBox) - Auftragsauswahl mit Auftrag/Objekt/Ort
- **cboVADatum** (ComboBox) - Datumsauswahl für Auftrag
- **Obj_ID** (ComboBox) - Objektauswahl (disabled/locked)
- **Kombinationsfeld58** (ComboBox) - Ort-Anzeige (disabled)
- **ID** (TextBox) - Datensatz-ID (disabled)
- **VA_Start_Abs** (TextBox) - Absperr-Startzeit (Short Time)
- **VA_Ende_Abs** (TextBox) - Absperr-Endzeit (Short Time)
- **AnzMA_VA** (TextBox) - Anzahl MA pro VA
- **AnzMA_Obj** (TextBox) - Anzahl MA pro Objekt

**SubForms (2 Stück):**
1. **sub_VA_Start** (Position: 3765/3285, 3380x7335)
   - Schichtenliste für gewähltes Datum
   - Link Master: VA_ID, cboVADatum
   - Link Child: VA_ID, VADatum_ID

2. **sub_VA_Akt_Objekt_Pos** (Position: 8435/3247, 13619x7364)
   - Positionenliste für Objektkopf
   - Link Master: ID
   - Link Child: VA_Akt_Objekt_Kopf_ID

**Buttons (14 Stück):**
- btn_VA_Objekt_Akt_Teil2, btnAbsTime (Rosa #D7B5D5)
- btn_OB_Bearb, btn_VA_Akt_OB_Pos_Neu (Rosa #D7B5D5)
- mcobtnDelete, Befehl46 (Hell-Rosa #F2EAEC)
- btnHilfe, Navigation-Buttons (Weiß #FFFFFF)
- btnRibbonAus/Ein, btnDaBaAus/Ein

**Sidebar:** frm_Menuefuehrung

### HTML
❌ **Nur Placeholder-Seite:**
- Titel "Objekt-Kopfdaten"
- Text: "HTML-Version in Entwicklung"
- Buttons: Zurück, Schließen

---

## 3. Datenquellen

### Access Queries

**VA_ID ComboBox:**
```sql
SELECT tbl_VA_Auftragstamm.ID, tbl_VA_Auftragstamm.Auftrag,
       tbl_VA_Auftragstamm.Objekt, tbl_VA_Auftragstamm.Ort
FROM tbl_VA_Auftragstamm;
```

**cboVADatum:**
```sql
SELECT tbl_VA_AnzTage.ID, Format([VADatum],"ddd/  dd/mm/yyyy",2,2) AS VADat
FROM tbl_VA_AnzTage;
```

**Obj_ID:**
```sql
SELECT tbl_OB_Objekt.ID, tbl_OB_Objekt.Objekt
FROM tbl_OB_Objekt;
```

**SubForms:**
- sub_VA_Start: Eigene RecordSource (Schichten)
- sub_VA_Akt_Objekt_Pos: Eigene RecordSource (Positionen)

### HTML
❌ **FEHLT KOMPLETT:**
- Keine API-Integration
- Keine SubForms
- Keine Datenanbindung

---

## 4. Funktionalität

### Access
**Workflow:**
1. Auftrag (VA_ID) wählen
2. Datum (cboVADatum) wählen
3. Objekt wird automatisch gesetzt (aus Auftrag)
4. Absperrzeit Start/Ende eingeben
5. Schichten in SubForm verwalten (sub_VA_Start)
6. Positionen in SubForm verwalten (sub_VA_Akt_Objekt_Pos)
7. MA-Anzahlen festlegen

**Events:**
- VA_ID_AfterUpdate: Datum-Dropdown aktualisieren
- cboVADatum_AfterUpdate: SubForms requery
- VA_Start_Abs/VA_Ende_Abs_OnKeyDown: Zeit-Eingabe-Hilfe

### HTML
❌ **FEHLT KOMPLETT**

---

## 5. Gaps

### Kritische Gaps
❌ **KOMPLETT FEHLEND:**
1. Formular-Implementierung (nur Placeholder)
2. API-Endpoints (`/api/objektkopf`, `/api/schichten`, `/api/positionen`)
3. Logic-File fehlt
4. SubForm-Konzept (2 verschachtelte Formulare)
5. Komplexe Abhängigkeiten (Auftrag → Datum → Schichten/Positionen)

---

## 6. Empfehlung

### Priorität: SEHR NIEDRIG
**Grund:**
- Sehr spezifisches Feature (Objektkopf + Absperrzeit)
- Nur für bestimmte Event-Typen relevant
- Komplexe Implementierung (SubForms, Abhängigkeiten)
- Alternative: Direkt in Access-Backend pflegen

### Aufwand: 3-5 Tage
1. API-Endpoints (CRUD für 3 Tabellen)
2. Komplexes HTML-Formular (Master-Detail mit 2 SubForms)
3. Logic-File mit Abhängigkeiten
4. Validierung und Events

### Alternative:
💡 **Im Access-Backend belassen:**
- Nur für spezielle Event-Typen
- Wird selten genutzt
- Hoher Implementierungs-Aufwand
- Bei Bedarf später nachrüsten

---

## 7. Zusammenfassung

**Status:** ❌ NICHT IMPLEMENTIERT (0%)
**Risiko:** NIEDRIG (spezielles Feature, selten genutzt)
**Aufwand:** 3-5 Tage (sehr komplex)

**Empfehlung:** SEHR niedrige Priorität - Im Access-Backend belassen! Nur bei explizitem Bedarf umsetzen.

---

## 8. Technischer Hinweis

**Falls Implementierung gewünscht:**
- Master-Detail-Pattern mit 2 Ebenen
- Cascading-Dropdowns (VA_ID → Datum → Schichten)
- 2 SubForm-Grids (Schichten, Positionen)
- Komplexe Validierung
- Real-Time Updates zwischen Master/Detail

**Beispiel: Andere Formulare mit SubForms**
- frm_va_Auftragstamm (hat Eventdaten als SubForm)
- frm_OB_Objekt (hat Positionen als SubForm)

→ Diese Patterns könnten wiederverwendet werden
