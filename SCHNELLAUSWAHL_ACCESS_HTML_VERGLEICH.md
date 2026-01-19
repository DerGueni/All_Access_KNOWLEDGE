# frm_MA_VA_Schnellauswahl - Access vs. HTML Vergleich

**Datum:** 2026-01-18
**Quelle Access:** `exports/vba/forms/Form_frm_MA_VA_Schnellauswahl.bas`
**Quelle HTML:** `04_HTML_Forms/forms3/frm_MA_VA_Schnellauswahl.html` + `.logic.js`

---

## 1. BUTTONS - VERGLEICH

| Button ID | Access VBA Event | HTML Event | Status | Bemerkung |
|-----------|------------------|------------|--------|-----------|
| **btnAddSelected** | `btnAddSelected_Click` - Fügt selektierte MA aus List_MA zur Planung hinzu | `click` → `zuordnenAuswahl()` in logic.js | ⚠️ TEILWEISE | Access: DAO Insert in tbl_MA_VA_Planung. HTML: Bridge.sendEvent('save') |
| **btnDelSelected** | `btnDelSelected_Click` - Löscht selektierte MA aus Planung | `click` → `entferneAusGeplant()` in logic.js | ⚠️ TEILWEISE | Access: DELETE FROM tbl_MA_VA_Planung. HTML: Bridge.sendEvent('delete') |
| **btnAddZusage** | `btnAddZusage_Click` - Verschiebt geplante MA zu Zugesagt | `Visible=False` in HTML | ❌ VERSTECKT | Button existiert aber nicht sichtbar |
| **btnDelZusage** | `btnDelZusage_Click` - Entfernt aus Zusagen | `Visible=False` in HTML | ❌ VERSTECKT | Button existiert aber nicht sichtbar |
| **btnMoveZusage** | `btnMoveZusage_Click` - Verschiebt Zusage zurück zu Planung | `Visible=False` in HTML | ❌ VERSTECKT | Button existiert aber nicht sichtbar |
| **btnMail** | `btnMail_Click` - Alle geplanten MA anfragen | `click` → `btnMail_Click()` in HTML inline | ✅ OK | Ruft `show_requestlog sql, False` auf → VBA Bridge Batch |
| **btnMailSelected** | `btnMailSelected_Click` - Nur selektierte anfragen | `click` → `btnMailSelected_Click()` in HTML inline | ✅ OK | Ruft `show_requestlog sql, True` auf → VBA Bridge Batch |
| **btnAuftrag** | `btnAuftrag_Click` - Zurück zum Auftragstamm | `click` → Navigation zu frm_va_Auftragstamm | ✅ OK | HTML: postMessage oder direkte Navigation |
| **btnPosListe** | `btnPosListe_Click` - Öffnet Positionsliste | `Visible=abhängig von Objekt_ID` | ⚠️ TEILWEISE | Logik vorhanden, aber Form nicht implementiert |
| **btnSchnellGo** | `btnSchnellGo_Click` - Schnellsuche ausführen | `Visible=False` in HTML | ❌ VERSTECKT | Suche läuft über logic.js debounced |
| **btnSortPLan** | `btnSortPLan_Click` - Planung sortieren | `Visible=False` in HTML | ❌ VERSTECKT | Access ruft zfSort_MA(2) auf |
| **btnSortZugeord** | `btnSortZugeord_Click` - Zuordnung sortieren | `Visible=False` in HTML | ❌ VERSTECKT | Access ruft sort_zuo_plan auf |
| **btnZuAbsage** | `btnZuAbsage_Click` - Öffnet ZuAbsage Form | `Visible=False` in HTML | ❌ VERSTECKT | DoCmd.OpenForm "frmTop_MA_ZuAbsage" |
| **cmdListMA_Standard** | `cmdListMA_Standard_Click` - Standard-Ansicht | `click` → `cmdListMA_Standard()` in logic.js | ✅ OK | Setzt bEntfernungsModus=False |
| **cmdListMA_Entfernung** | `cmdListMA_Entfernung_Click` - Nach Entfernung sortieren | `click` → `cmdListMA_Entfernung()` in logic.js | ✅ OK | Lädt Entfernungen vom API |
| **btnDaBaAus** | `btnDaBaAus_Click` - Datenbankfenster ausblenden | NICHT in HTML | ❌ FEHLT | Access-spezifisch, nicht relevant |
| **btnDaBaEin** | `btnDaBaEin_Click` - Datenbankfenster einblenden | NICHT in HTML | ❌ FEHLT | Access-spezifisch, nicht relevant |
| **btnRibbonAus** | `btnRibbonAus_Click` - Ribbon ausblenden | NICHT in HTML | ❌ FEHLT | Access-spezifisch, nicht relevant |
| **btnRibbonEin** | `btnRibbonEin_Click` - Ribbon einblenden | NICHT in HTML | ❌ FEHLT | Access-spezifisch, nicht relevant |

---

## 2. LISTENFELDER (Listboxes) - VERGLEICH

| Listbox ID | Access Events | HTML Events | Status | Bemerkung |
|------------|---------------|-------------|--------|-----------|
| **List_MA** | `List_MA_DblClick` - Ruft btnAddSelected_Click auf | `dblclick` → `addMAToPlanung()` in HTML inline | ✅ OK | GESCHÜTZT in CLAUDE.md - DblClick in HTML ist korrekt |
| **lstZeiten** | `lstZeiten_AfterUpdate` - Aktualisiert DienstEnde und Vergleichszeiten | `click` auf Zeilen → Selektion | ⚠️ TEILWEISE | DienstEnde wird gesetzt, aber upd_Vergleichszeiten fehlt |
| **lstMA_Plan** | `lstMA_Plan_DblClick` - Ruft btnDelSelected_Click auf | `dblclick` → (in HTML nicht explizit) | ⚠️ FEHLT | DblClick-Handler für lstMA_Plan_Body fehlt! |
| **lstMA_Zusage** | Keine Events in VBA | Nur Anzeige | ✅ OK | Keine Interaktion nötig |
| **Lst_Parallel_Einsatz** | `Lst_Parallel_Einsatz_DblClick` - Wechselt zu anderem Auftrag | `dblclick` → (in HTML nicht explizit) | ⚠️ FEHLT | DblClick-Handler fehlt! |

---

## 3. COMBOBOXEN (Dropdowns) - VERGLEICH

| Combobox ID | Access Events | HTML Events | Status | Bemerkung |
|-------------|---------------|-------------|--------|-----------|
| **VA_ID** | `VA_ID_AfterUpdate` - Ruft VAOpen auf | `change` → State aktualisiert in logic.js | ✅ OK | HTML ruft VAOpen() in inline script auf |
| **cboVADatum** | `cboVADatum_AfterUpdate` - Lädt Schichten, Zusagen, Planung, Paralleleinsätze | `change` → State aktualisiert in logic.js | ✅ OK | cboVADatum_AfterUpdate() in HTML inline |
| **cboAnstArt** | `cboAnstArt_AfterUpdate` - Ruft zf_MA_Selektion auf | `change` → `renderMitarbeiterListe()` in logic.js | ✅ OK | Default: 5 (Minijobber) |
| **cboQuali** | `cboQuali_AfterUpdate` - Ruft zf_MA_Selektion auf | `change` → `renderMitarbeiterListe()` in logic.js | ✅ OK | Filter Kategorie |
| **cboAuftrStatus** | Keine Events (nur Anzeige) | `Visible=False` in HTML | ❌ VERSTECKT | Wird via TLookup gesetzt, nicht editierbar |

---

## 4. CHECKBOXEN - VERGLEICH

| Checkbox ID | Access Events | HTML Events | Status | Bemerkung |
|-------------|---------------|-------------|--------|-----------|
| **IstAktiv** | `IstAktiv_AfterUpdate` - Aktualisiert Label + zf_MA_Selektion | `change` → `renderMitarbeiterListe()` | ✅ OK | Default: checked |
| **IstVerfuegbar** | `IstVerfuegbar_AfterUpdate` - Aktualisiert Label + zf_MA_Selektion | `change` → `renderMitarbeiterListe()` | ✅ OK | "Nur freie anzeigen" |
| **cbVerplantVerfuegbar** | `cbVerplantVerfuegbar_AfterUpdate` - zf_MA_Selektion | `change` → `renderMitarbeiterListe()` | ⚠️ TEILWEISE | Label-Aktualisierung fehlt in HTML |
| **cbNur34a** | `cbNur34a_AfterUpdate` - zf_MA_Selektion | `change` → `renderMitarbeiterListe()` | ✅ OK | 34a-Filter |

---

## 5. TEXTFELDER - VERGLEICH

| Feld ID | Access Events | HTML Events | Status | Bemerkung |
|---------|---------------|-------------|--------|-----------|
| **DienstEnde** | `DienstEnde_AfterUpdate` - Ruft f_lstZeiten_upd auf | `change` (nicht explizit gebunden) | ⚠️ FEHLT | DienstEnde_AfterUpdate fehlt in HTML! |
| **strSchnellSuche** | Eingabe für Schnellsuche | `input` → debounced filter in logic.js | ✅ OK | `Visible=False` in HTML |
| **iGes_MA** | Nur Anzeige (readonly) | Nur Anzeige | ✅ OK | Zeigt Gesamtzahl MA |
| **lbAuftrag** | Label - wird via VAOpen gesetzt | Label - wird via VAOpen gesetzt | ✅ OK | Auftragsinformation |
| **lbl_Datum** | Label - wird in Form_Open gesetzt | Label - wird in Form_Open gesetzt | ✅ OK | Aktuelles Datum |

---

## 6. FORMULAR-EVENTS - VERGLEICH

| Event | Access VBA | HTML JavaScript | Status | Bemerkung |
|-------|------------|-----------------|--------|-----------|
| **Form_Open** | Listen leeren, OpenArgs auswerten, VAOpen aufrufen | `Form_Open()` in HTML inline | ✅ OK | Identische Logik |
| **Form_Load** | Daten im FE aktualisieren, cboAnstArt=5, cboAnstArt_AfterUpdate | `Form_Load()` in HTML inline | ✅ OK | Lädt Aufträge-Liste |
| **Form_Close** | sort_zuo_plan für Zuordnung und Planung | `Form_Close()` in HTML inline | ⚠️ TEILWEISE | sort_zuo_plan fehlt im HTML |

---

## 7. WICHTIGE FUNKTIONEN - VERGLEICH

| Funktion | Access VBA | HTML JavaScript | Status | Bemerkung |
|----------|------------|-----------------|--------|-----------|
| **VAOpen(iVA_ID, iVADatum_ID)** | Lädt Auftrag, Einsatztage, Schichten | `VAOpen()` in HTML inline | ✅ OK | REST API statt DAO |
| **zf_MA_Selektion()** | Erstellt temp. Tabelle ztbl_MA_Schnellauswahl | `loadMitarbeiterListe()` in HTML | ⚠️ ANDERS | HTML: Direkter API-Call statt temp. Tabelle |
| **Soll_Plan_Ist_Ges()** | Zählt Zuordnungen, setzt btnAddZusage.Enabled | `updateSollPlanIst()` (existiert nicht) | ❌ FEHLT | Anzeige "Ist / Soll" fehlt |
| **Test_selected()** | Prüft ob MA bereits verplant | Nicht implementiert | ❌ FEHLT | Doppelbelegungs-Warnung fehlt! |
| **Anfragen()** | Sendet E-Mail-Anfrage | `sendAnfrageViaAccessVBA()` in logic.js | ✅ OK | Nutzt VBA Bridge Server |
| **show_requestlog()** | Öffnet Log-Formular, iteriert MA | Modal in HTML mit Progress | ✅ OK | Modernere Darstellung |
| **create_confirm_doc()** | Erstellt PDF-Bestätigung | NICHT implementiert | ❌ FEHLT | PDF-Erstellung nur via VBA |
| **sort_zuo_plan()** | Sortiert Zuordnung/Planung | NICHT implementiert | ❌ FEHLT | Nur Debug-Ausgabe in VBA |
| **fSort_MA()** | Alte Sortierfunktion | NICHT implementiert | ❌ FEHLT | Durch zfSort_MA ersetzt |
| **upd_Vergleichszeiten()** | Aktualisiert Verfügbarkeitszeiten | NICHT implementiert | ❌ FEHLT | Externe Funktion |
| **refresh_zuoplanfe()** | Daten im FE aktualisieren | NICHT implementiert | ❌ FEHLT | Externe Funktion |

---

## 8. KRITISCHE UNTERSCHIEDE

### 8.1 FEHLENDE DBLCLICK-HANDLER

| Liste | Access Event | HTML Status |
|-------|--------------|-------------|
| lstMA_Plan | DblClick → btnDelSelected_Click | ❌ FEHLT |
| Lst_Parallel_Einsatz | DblClick → VAOpen(anderer Auftrag) | ❌ FEHLT |

### 8.2 FEHLENDE BUSINESS-LOGIK

| Funktion | Beschreibung | Priorität |
|----------|--------------|-----------|
| **Test_selected()** | Warnung bei Doppelbelegung | 🔴 HOCH |
| **Soll_Plan_Ist_Ges()** | Anzeige Ist/Soll, Button-Aktivierung | 🟡 MITTEL |
| **DienstEnde_AfterUpdate** | Aktualisiert Vergleichszeiten | 🟡 MITTEL |
| **create_confirm_doc()** | PDF-Bestätigung erstellen | 🟢 NIEDRIG (VBA-Only) |

### 8.3 VERSTECKTE ABER VORHANDENE BUTTONS

Diese Buttons sind im HTML vorhanden aber mit `display: none` versteckt:

- btnAddZusage, btnDelZusage, btnMoveZusage (Zusagen-Verwaltung)
- btnSchnellGo, strSchnellSuche (Schnellsuche)
- btnSortPLan, btnSortZugeord (Sortierung)
- btnZuAbsage (Manuelles Bearbeiten)
- btnDelAll (Alle entfernen)
- cboAuftrStatus (Auftragsstatus)

---

## 9. SPALTEN-VERGLEICH LISTENFELDER

### List_MA (Mitarbeiterauswahl)

| Spalte | Access | HTML | Status |
|--------|--------|------|--------|
| MA_ID | ✅ Column(0) | ✅ data-id | ✅ OK |
| IsSub | ✅ Column(1) | ❌ Fehlt | ⚠️ FEHLT |
| Name | ✅ Column(2) | ✅ Spalte 1 | ✅ OK |
| Stunden | ✅ Column(3) | ✅ Spalte 2 | ✅ OK |
| Beginn | ✅ Column(4) | ✅ Spalte 3 | ✅ OK |
| Ende | ✅ Column(5) | ✅ Spalte 4 | ✅ OK |
| Grund/Verplant | ✅ Column(5) | ✅ Spalte 5 | ✅ OK |
| Entfernung | ✅ (bei Modus) | ✅ colEntfernung | ✅ OK |

### lstMA_Plan (Geplante MA)

| Spalte | Access | HTML | Status |
|--------|--------|------|--------|
| ID | ✅ Column(0) | ✅ data-id | ✅ OK |
| Lfd | ❓ | ✅ Spalte 1 | ✅ OK |
| Nachname | ✅ | ✅ Spalte 2 | ✅ OK |
| Vorname | ✅ | ✅ Spalte 3 | ✅ OK |
| MA_ID | ✅ Column(4) | ⚠️ data-maid | ✅ OK |
| Beginn | ✅ | ✅ Spalte 4 | ✅ OK |

### lstZeiten (Schichten)

| Spalte | Access | HTML | Status |
|--------|--------|------|--------|
| VAStart_ID | ✅ Column(0) | ✅ data-idx | ✅ OK |
| VADatum | ✅ Column(1) | ❌ Fehlt | ⚠️ FEHLT |
| VA_Start | ✅ Column(2) | ✅ Spalte 3 | ✅ OK |
| VA_Ende | ✅ Column(3) | ✅ Spalte 4 | ✅ OK |
| MA_Ist | ✅ Column(4) | ✅ Spalte 1 | ✅ OK |
| MA_Soll | ✅ Column(5) | ✅ Spalte 2 | ✅ OK |

---

## 10. ZUSAMMENFASSUNG

### Funktioniert identisch (✅):
- Auftragsladen (VAOpen)
- Datum-Auswahl (cboVADatum_AfterUpdate)
- Mitarbeiter-Filter (IstAktiv, IstVerfuegbar, cboAnstArt, cboQuali, cbNur34a)
- E-Mail-Anfragen (btnMail, btnMailSelected) via VBA Bridge
- Navigation (btnAuftrag)
- Entfernungs-Sortierung (cmdListMA_Standard, cmdListMA_Entfernung)
- List_MA DblClick → Zur Planung hinzufügen

### Teilweise implementiert (⚠️):
- btnAddSelected/btnDelSelected - API statt DAO
- lstZeiten_AfterUpdate - DienstEnde wird gesetzt, aber Vergleichszeiten fehlen
- Form_Close - sort_zuo_plan fehlt

### Fehlt komplett (❌):
- lstMA_Plan DblClick-Handler
- Lst_Parallel_Einsatz DblClick-Handler
- Test_selected() - Doppelbelegungs-Warnung
- Soll_Plan_Ist_Ges() - Ist/Soll Anzeige
- DienstEnde_AfterUpdate
- create_confirm_doc() - PDF-Erstellung
- upd_Vergleichszeiten()
- refresh_zuoplanfe()

### Nicht relevant für HTML (Access-spezifisch):
- btnDaBaAus/btnDaBaEin (Datenbankfenster)
- btnRibbonAus/btnRibbonEin (Ribbon)

---

## 11. EMPFOHLENE KORREKTUREN

### Priorität HOCH:
1. **lstMA_Plan DblClick hinzufügen** - Entfernt MA aus Planung
2. **Test_selected() implementieren** - Warnt bei Doppelbelegung

### Priorität MITTEL:
3. **Lst_Parallel_Einsatz DblClick hinzufügen** - Wechselt zu anderem Auftrag
4. **Soll_Plan_Ist_Ges() implementieren** - Zeigt Ist/Soll an
5. **DienstEnde_AfterUpdate implementieren** - Aktualisiert Filter

### Priorität NIEDRIG:
6. **Label-Updates bei Checkbox-Änderungen** - cbVerplantVerfuegbar
7. **sort_zuo_plan bei Form_Close** - Sortierung beim Schließen

---

**Erstellt am:** 2026-01-18
**Status:** Vollständige Analyse abgeschlossen
