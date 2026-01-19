# KOMPLETT-ABGLEICH REPORT: HTML ↔ ACCESS PARITÄT

**Erstellt:** 2026-01-16
**Modus:** CHECKEN-MODUS (automatisierte Agent-Analyse)

---

## EXECUTIVE SUMMARY

| Formular | Buttons | Subforms | Events | Gesamt |
|----------|---------|----------|--------|--------|
| **frm_VA_Auftragstamm** | 85% | 10% | 70% | **55%** |
| **frm_KD_Kundenstamm** | 50% | 40% | 60% | **50%** |
| **frm_MA_Mitarbeiterstamm** | 45% | 23% | 0% | **37%** |
| **Header-Standard** | - | - | - | **0%** |

**Gesamtstatus: ~45% Parität erreicht**

---

## PHASE 1: frm_VA_Auftragstamm

### ✅ Korrekt implementiert (Buttons)

| Button | VBA-Funktion | HTML-Handler | Status |
|--------|--------------|--------------|--------|
| btn_ListeStd | Stundenliste_erstellen | namenslisteESS() | ✅ VBA Bridge |
| btnMailEins | Autosend(2) | sendeEinsatzlisteMA() | ✅ VBA Bridge |
| btnMailSub | Autosend(5) | sendeEinsatzlisteSUB() | ✅ VBA Bridge |
| btnDruckZusage | fXL_Export_Auftrag | einsatzlisteDrucken() | ✅ VBA Bridge |
| btn_Autosend_BOS | Autosend(4) | sendeEinsatzlisteBOS() | ✅ VBA Bridge |
| cmd_BWN_send | SendeBewachungsnachweise | bwnSenden() | ✅ VBA Bridge |
| btnSchnellPlan | frm_MA_VA_Schnellauswahl | openMitarbeiterauswahl() | ✅ |
| btn_BWN_Druck | - | bwnDrucken() | ✅ VBA Bridge |
| btnPlan_Kopie | Kopiert Plan | kopiereInFolgetag() | ✅ |
| mcobtnDelete | Auftrag_Loeschen | auftragLoeschen() | ✅ |

### ⚠️ Abweichungen (Buttons)

| Button | Access-Funktion | HTML-Status |
|--------|-----------------|-------------|
| btn_std_check | Setzt Status=3 + Druck | ❌ FEHLT |
| btn_sortieren | sort_zuo_plan | ❌ FEHLT |
| btn_rueckgaengig | DoCmd.Undo | ❌ FEHLT |
| btnXLEinsLst | fExcel_qry_export | ❌ FEHLT |
| cmd_Messezettel_NameEintragen | FuelleMessezettel | ❌ FEHLT |
| btnVAPlanAendern | AllowDeletions=True | ❌ FEHLT |

### ❌ Kritisch: Subforms (nur 1 von 10 implementiert!)

| Access Subform | LinkFields | HTML iframe | Status |
|----------------|------------|-------------|--------|
| sub_MA_VA_Zuordnung | VA_ID;VADatum_ID | ✅ Implementiert | OK |
| sub_VA_Start | VA_ID;VADatum_ID | ❌ FEHLT | KRITISCH |
| sub_MA_VA_Planung_Absage | VA_ID;VADatum_ID | ❌ FEHLT | KRITISCH |
| sub_MA_VA_Zuordnung_Status | VA_ID;VADatum_ID | ❌ FEHLT | KRITISCH |
| sub_ZusatzDateien | Objekt_ID;TabellenNr | ❌ FEHLT | KRITISCH |
| sub_rch_Pos | VA_ID | ❌ FEHLT | KRITISCH |
| sub_Berechnungsliste | VA_ID | ❌ FEHLT | KRITISCH |
| sub_VA_Anzeige | - | ❌ FEHLT | |
| zsub_lstAuftrag | - | ❌ FEHLT | |
| frm_Menuefuehrung | - | ✅ Sidebar | OK |

### DblClick-Events

| Control | Access Event | HTML Handler | Status |
|---------|--------------|--------------|--------|
| Veranst_Status_ID | OnDblClick | addEventListener | ✅ |
| Objekt_ID | OnDblClick | openPositionen() | ✅ |
| cboVADatum | OnDblClick | Schichten Dialog | ✅ |
| Veranstalter_ID | OnDblClick | Browser Dialog | ✅ |
| Dat_VA_Von/Bis | OnDblClick | - | ⚠️ PRÜFEN |

---

## PHASE 2: frm_KD_Kundenstamm

### ✅ Korrekt implementiert

| Button | Funktion | Status |
|--------|----------|--------|
| btnAktualisieren | refreshData() | ✅ |
| btnVerrechnungssaetze | openVerrechnungssaetze() | ✅ |
| btnUmsatzauswertung | openUmsatzauswertung() | ✅ |
| btnOutlook | openOutlook() | ✅ |
| btnWord | openWord() | ✅ |
| btnNeuKunde | neuerKunde() | ✅ |
| btnLoeschen | kundeLoeschen() | ✅ |
| btnNeuAttach | dateiHinzufuegen() | ✅ |

### ⚠️ Abweichungen (Buttons)

| Button | Access-Funktion | HTML-Status |
|--------|-----------------|-------------|
| btnDate | Datumsdialog | ❌ FEHLT |
| btnAlle | Auswahlfilter Reset | ❌ FEHLT |
| btnPersonUebernehmen | Person übernehmen | ❌ FEHLT |
| btnAuftrag | frmHlp_AuftragsErfassung | ❌ FEHLT |
| btnDaBaAus/Ein | Database-Toggle | ❌ NICHT RELEVANT |
| btnRibbonAus/Ein | Ribbon-Toggle | ❌ NICHT RELEVANT |

### Subforms (7 in Access, Tab-System in HTML)

| Subform | Status |
|---------|--------|
| sub_KD_Standardpreise | ⚠️ Tab vorhanden |
| sub_KD_Auftragskopf | ⚠️ Tab vorhanden |
| sub_KD_Rch_Auftragspos | ⚠️ Tab vorhanden |
| sub_Rch_Kopf_Ang | ⚠️ Tab vorhanden |
| sub_ZusatzDateien | ✅ Implementiert |
| sub_Ansprechpartner | ✅ Implementiert |
| frm_Menuefuehrung | ✅ Sidebar |

### DblClick-Events

| Access | HTML | Status |
|--------|------|--------|
| kun_AdressArt_DblClick (leer) | - | ✅ Nicht nötig |
| - | Kundenliste dblclick | ✅ ÜBER-Implementiert |
| - | Aufträge dblclick | ✅ ÜBER-Implementiert |
| - | Angebote dblclick | ✅ ÜBER-Implementiert |
| - | Kundenpreise dblclick | ✅ ÜBER-Implementiert |

---

## PHASE 3: frm_MA_Mitarbeiterstamm

### ✅ Korrekt implementiert (18 von 40 Buttons)

| Button | Funktion | Status |
|--------|----------|--------|
| Navigation (4) | erste/vor/zurück/letzte | ✅ |
| btnNeuMA | neuerMitarbeiter() | ✅ |
| btnLöschen | mitarbeiterLöschen() | ✅ |
| btnZeitkonto | openZeitkonto() | ✅ |
| btnZKFest | btnZKFest_Click() | ✅ VBA Bridge |
| btnZKMini | btnZKMini_Click() | ✅ VBA Bridge |
| btnDateisuch | Foto upload | ✅ |
| btnMaps | openMaps() | ✅ |
| btnXLZeitkto | btnXLZeitkto_Click() | ✅ VBA Bridge |
| btnLesen | loadEinsaetze() | ✅ |
| btn_Diensplan_prnt | btn_Diensplan_prnt() | ✅ VBA Bridge |
| btn_Dienstplan_send | btn_Dienstplan_send() | ✅ VBA Bridge |
| cmdGeocode | cmdGeocode_Click() | ✅ |

### ❌ Fehlend (22 Buttons)

```
btnLstDruck, btnRibbonAus, btnRibbonEin, btnDaBaAus, btnDaBaEin,
btnDateisuch2, btnZuAb, btnUpdJahr, btnXLJahr, btnAU_Lesen,
btnRch, btnCalc, btnXLUeberhangStd, btnau_lesen2, btnAUPl_Lesen,
btnMehrfachtermine, btnXLNverfueg, btnReport_Dienstkleidung,
btn_MA_EinlesVorlageDatei, btnXLVordrucke, lbl_Mitarbeitertabelle,
Bericht_drucken
```

### ❌ Kritisch: Subforms (nur 3 von 13 implementiert!)

| Subform | Status |
|---------|--------|
| frm_Menuefuehrung | ✅ Sidebar |
| sub_MA_tbl_MA_NVerfuegZeiten | ⚠️ Teilweise (Funktionen vorhanden) |
| sub_MA_Dienstkleidung | ⚠️ Teilweise (Funktionen vorhanden) |
| sub_MA_ErsatzEmail | ❌ FEHLT |
| sub_MA_Einsatz_Zuo | ❌ FEHLT |
| sub_tbl_MA_Zeitkonto_Aktmon1/2 | ❌ FEHLT |
| frmStundenübersicht | ❌ FEHLT |
| sub_tbltmp_MA_Ausgef_Vorlagen | ❌ FEHLT |
| sub_tbl_MA_StundenFolgemonat | ❌ FEHLT |
| ufrm_Maps (Browser) | ❌ FEHLT |
| subAuftragRech | ❌ FEHLT |
| subZuoStunden | ❌ FEHLT |

### ❌ Fehlend: DblClick-Handler (alle 4)

| Control | Access-Event | HTML | Status |
|---------|--------------|------|--------|
| DiDatumAb | OnDblClick | - | ❌ FEHLT |
| Geb_Dat | OnDblClick | - | ❌ FEHLT |
| Eintrittsdatum | OnDblClick | - | ❌ FEHLT |
| Austrittsdatum | OnDblClick | - | ❌ FEHLT |

---

## PHASE 4: Header-Standardisierung

### Soll-Standard:
```html
<div class="form-header" style="background-color: #e0e0e0; padding: 10px;">
    <span id="headerTitle" style="font-size: 14px; color: #000; font-weight: bold;">
        [Titel]
    </span>
</div>
```

### ❌ Ergebnis: 0 von 27 Formularen entsprechen dem Standard!

| Datei | Header-Typ | Abweichung |
|-------|------------|------------|
| frm_va_Auftragstamm.html | .window-frame | Kein form-header |
| frm_KD_Kundenstamm.html | .window-frame | Kein form-header |
| frm_MA_Mitarbeiterstamm.html | .window-frame | Kein form-header |
| frm_Angebot.html | .header (#4316B2) | Falsche Farbe |
| frm_Rechnung.html | .header (#4316B2) | Falsche Farbe |
| frm_MA_Serien_eMail_*.html | .app-header (#4316B2) | Falsche Farbe |
| frm_KD_Verrechnungssaetze.html | .header-row (#d3d3d3) | Falsche Farbe |
| frm_MA_Offene_Anfragen.html | .form-header (#d3d3d3) | Falsche Farbe, 24px |
| ... (weitere 19 Dateien) | Verschiedene | Kein Standard |

---

## GESCHÜTZTE BEREICHE (aus CLAUDE.md)

Die folgenden Bereiche wurden NICHT verändert:

- ✅ `sub_MA_VA_Zuordnung.logic.js` - REST-API Modus intakt
- ✅ `frm_va_Auftragstamm.logic.js` - auskommentierte bindButtons intakt
- ✅ `frm_MA_VA_Schnellauswahl.logic.js` - dblclick-Handler intakt
- ✅ VBA-Buttons in `mod_N_HTML_Buttons.bas` - nicht verändert
- ✅ API-Endpoints (Port 5000, 5002) - nicht verändert

---

## EMPFEHLUNGEN (Priorisiert)

### KRITISCH (Sofort)
1. **Auftragstamm Subforms** - 9 fehlende Subforms implementieren
2. **Mitarbeiterstamm Subforms** - 10 fehlende Subforms implementieren
3. **Mitarbeiterstamm DblClick** - 4 Datums-Picker implementieren

### HOCH (Diese Woche)
4. **Fehlende Buttons Auftragstamm** - 6 Buttons nachziehen
5. **Fehlende Buttons Mitarbeiterstamm** - 22 Buttons nachziehen
6. **Fehlende Buttons Kundenstamm** - 4 relevante Buttons

### MITTEL (Nächste Woche)
7. **Header-Standardisierung** - Alle 27 Formulare vereinheitlichen
8. **AfterUpdate Events** - Validierungslogik in allen Formularen

### NIEDRIG (Backlog)
9. Ribbon/DaBa Toggle-Buttons (UI-spezifisch, evtl. nicht nötig)
10. Weitere Subform-Verfeinerungen

---

## ÄNDERUNGEN DURCHGEFÜHRT

Keine Änderungen - nur Analyse durchgeführt.

---

═══════════════════════════════════════
📋 CHECKEN-MODUS REPORT
═══════════════════════════════════════

**Anweisung:** Komplett-Abgleich HTML ↔ Access für 3 Hauptformulare + Header

**Ausführung:**
- Agents gestartet: 7
- Erfolgreich: 7
- Korrekturen: 0

**Geschützte Bereiche:**
- [X] Alle intakt geblieben

**Ergebnis:**
✅ Analyse abgeschlossen

**Token-Verbrauch:** ~Medium (parallele Agents)
═══════════════════════════════════════
