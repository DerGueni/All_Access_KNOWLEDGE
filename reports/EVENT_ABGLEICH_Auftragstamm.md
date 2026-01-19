# VBA/HTML Event Abgleich - frm_va_Auftragstamm

**Datum:** 2026-01-05
**VBA-Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\vba\forms\Form_frm_VA_Auftragstamm.bas`
**HTML-Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_va_Auftragstamm.html`
**Logic-Datei:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\logic\frm_va_Auftragstamm.logic.js`

---

## Zusammenfassung

| Kategorie | Anzahl |
|-----------|--------|
| **Gesamt VBA Events** | 88 |
| **Implementiert in HTML** | 47 |
| **Fehlt in HTML** | 41 |
| **Kritische Events (fehlen)** | 8 |

---

## 1. FORM-EVENTS (Lifecycle)

### KRITISCH - Hauptformular-Events

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Form_Load()` | ✅ Implementiert | `init()` Zeile 38 | **KRITISCH** | Datum setzen, Tabs, Buttons, Feld-Events, PostMessage-Listener, initiale Daten laden |
| `Form_Open(Cancel)` | ⚠️ Teilweise | `loadInitialData()` Zeile 334 | **KRITISCH** | Combos laden, Auftragsliste laden - aber kein Property-Abgleich |
| `Form_Current()` | ⚠️ Teilweise | `displayRecord()` Zeile 466 | **KRITISCH** | Datensatz anzeigen, Status-Regeln anwenden - ABER: `Veranst_Status_ID_AfterUpdate` fehlt im `displayRecord`! |
| `Form_BeforeUpdate(Cancel)` | ❌ Fehlt | - | **KRITISCH** | Änderungs-Tracking (`Aend_am`, `Aend_von`) fehlt komplett! |
| `Form_BeforeDelConfirm(Cancel, response)` | ❌ Fehlt | - | HOCH | Löschen-Bestätigung fehlt |

**KRITISCHE LÜCKEN:**
1. `Form_Current` ruft NICHT `Veranst_Status_ID_AfterUpdate` auf (VBA Zeile 2169)
2. `Form_BeforeUpdate` fehlt komplett - Änderungen werden nicht protokolliert (Aend_am/Aend_von)
3. Property-Abgleich aus `Form_Open` fehlt (Recordset-Index, Datumsliste)

---

## 2. FELD-EVENTS - AfterUpdate

### KRITISCH - Geschäftslogik-Events

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Veranst_Status_ID_AfterUpdate()` | ✅ Implementiert | `applyStatusRules()` Zeile 984 | **KRITISCH** | Status-Regeln (Locked-State, Buttons, Tabs) |
| `Veranst_Status_ID_BeforeUpdate(Cancel)` | ✅ Implementiert | Event-Handler Zeile 163-172 | **KRITISCH** | Status-Herabsetzung Warnung |
| `veranstalter_id_AfterUpdate()` | ⚠️ Teilweise | `applyVeranstalterRules()` Zeile 965 | **KRITISCH** | Messe-Buttons zeigen, Spalten verstecken - ABER: Fokus-Sprung zu `sub_VA_Start` fehlt! |
| `Objekt_ID_AfterUpdate()` | ✅ Implementiert | `applyObjektRules()` Zeile 1001 | HOCH | Positionsliste-Button anzeigen, Hintergrundfarbe, DoCmd.SaveRecord |
| `cboVADatum_AfterUpdate()` | ✅ Implementiert | Event-Handler Zeile 200-206 | **KRITISCH** | VADatum_ID setzen, Subforms aktualisieren, Default-Werte setzen |
| `Dat_VA_Bis_AfterUpdate()` | ❌ Fehlt | - | **KRITISCH** | Einsatztage erstellen/aktualisieren (tbl_VA_AnzTage) - FEHLT KOMPLETT! |
| `cboEinsatzliste_AfterUpdate()` | ❌ Fehlt | - | MITTEL | Einsatzliste-Combo |
| `cboAuftrSuche_AfterUpdate()` | ❌ Fehlt | - | MITTEL | Auftragssuche |
| `cboID_AfterUpdate()` | ❌ Fehlt | - | NIEDRIG | ID-Combo |
| `IstStatus_AfterUpdate()` | ❌ Fehlt | - | NIEDRIG | Ist-Status Filter |
| `cboAnstArt_AfterUpdate()` | ❌ Fehlt | - | NIEDRIG | Anstellungsart |
| `IstVerfuegbar_AfterUpdate()` | ❌ Fehlt | - | NIEDRIG | Verfügbarkeit Filter |
| `MA_Selektion_AfterUpdate()` | ❌ Fehlt | - | NIEDRIG | MA Selektion |

**KRITISCHE LÜCKEN:**
1. **`Dat_VA_Bis_AfterUpdate`** fehlt komplett - Einsatztage werden NICHT automatisch erstellt!
   - VBA erstellt `tbl_VA_AnzTage` Records für jedes Datum zwischen Von/Bis
   - HTML hat kein Äquivalent dafür
2. **`veranstalter_id_AfterUpdate`** springt nicht zu `sub_VA_Start!MA_Anzahl` (VBA Zeile 900)

---

## 3. FELD-EVENTS - BeforeUpdate

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Veranst_Status_ID_BeforeUpdate(Cancel)` | ✅ Implementiert | Zeile 163-172 | **KRITISCH** | Status-Herabsetzung Warnung |
| `Treffp_Zeit_BeforeUpdate(Cancel)` | ✅ Implementiert | Zeile 210-226 | HOCH | Zeit-Format-Validierung (hh:mm oder hhmm) |
| `cboEinsatzliste_BeforeUpdate(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |

---

## 4. FELD-EVENTS - GotFocus / LostFocus

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Ansprechpartner_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `Dienstkleidung_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `Objekt_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `Ort_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `Treffp_Zeit_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `Treffpunkt_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `veranstalter_id_GotFocus()` | ❌ Fehlt | - | NIEDRIG | - |
| `btn_std_check_LostFocus()` | ❌ Fehlt | - | NIEDRIG | Button ausblenden |

**Bewertung:** GotFocus/LostFocus sind in VBA primär für UI-Feedback (z.B. Hilfe-Texte), in HTML weniger relevant.

---

## 5. FELD-EVENTS - DblClick

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Veranstalter_ID_DblClick(Cancel)` | ✅ Implementiert | Zeile 183-188 | HOCH | Kundenstamm öffnen via Shell |
| `Objekt_ID_DblClick(Cancel)` | ✅ Implementiert | Zeile 196 | HOCH | Positionen öffnen |
| `Objekt_DblClick(Cancel)` | ⚠️ Teilweise | - | MITTEL | VBA prüft ob Objekt_ID gesetzt, dann aufrufen - fehlt in HTML |
| `cboVADatum_DblClick(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `Dat_VA_Bis_DblClick(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `Dat_VA_Von_DblClick(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `cboAnstArt_DblClick(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `Auftraege_ab_DblClick(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |

---

## 6. FELD-EVENTS - Exit / Enter / KeyDown

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Treffp_Zeit_KeyDown(KeyCode, Shift)` | ✅ Implementiert | Zeile 210-226 | HOCH | Zeit-Format bei Enter/Tab |
| `Dat_VA_Von_Exit(Cancel)` | ⚠️ Teilweise | - | MITTEL | VBA: Wenn Dat_VA_Bis leer, dann = Dat_VA_Von und `Dat_VA_Bis_AfterUpdate` aufrufen |
| `Auftraege_ab_Exit(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `Objekt_Exit(Cancel)` | ⚠️ Teilweise | - | MITTEL | VBA: Objekt_ID aus Objektname nachschlagen wenn leer |
| `sub_VA_Start_Enter()` | ❌ Fehlt | - | NIEDRIG | SetFocus zu lstZeiten |
| `sub_VA_Start_Exit(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `sub_MA_VA_Zuordnung_Enter()` | ❌ Fehlt | - | NIEDRIG | - |
| `sub_MA_VA_Zuordnung_Exit(Cancel)` | ❌ Fehlt | - | NIEDRIG | - |
| `Veranstalter_ID_KeyDown(KeyCode, Shift)` | ❌ Fehlt | - | NIEDRIG | - |

**WICHTIG:**
- `Dat_VA_Von_Exit`: Logik fehlt (Dat_VA_Bis automatisch setzen)
- `Objekt_Exit`: Auto-Lookup von Objekt_ID fehlt

---

## 7. BUTTON-EVENTS - Navigation

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `btnDatumLeft_Click()` | ✅ Implementiert | `navigateVADatum(-1)` Zeile 535 | HOCH | VADatum zurück |
| `btnDatumRight_Click()` | ✅ Implementiert | `navigateVADatum(1)` Zeile 535 | HOCH | VADatum vor |
| `btnTgBack_Click()` | ✅ Implementiert | `shiftAuftraegeFilter(-7)` Zeile 562 | MITTEL | 7 Tage zurück |
| `btnTgVor_Click()` | ✅ Implementiert | `shiftAuftraegeFilter(7)` Zeile 562 | MITTEL | 7 Tage vor |
| `btnHeute_Click()` | ✅ Implementiert | `setAuftraegeFilterToday()` Zeile 574 | MITTEL | Heute |
| `btn_AbWann_Click()` | ✅ Implementiert | `applyAuftraegeFilter()` Zeile 552 | MITTEL | Filter anwenden |
| `btnreq_Click()` | ✅ Implementiert | `requeryAll()` Zeile 1020 | MITTEL | Alles neu laden |

---

## 8. BUTTON-EVENTS - Aktionen

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `Befehl640_Click()` | ✅ Implementiert | `kopierenAuftrag()` Zeile 734 | HOCH | Auftrag kopieren |
| `btn_Posliste_oeffnen_Click()` | ✅ Implementiert | `openPositionen()` Zeile 624 | HOCH | Positionsliste |
| `btnSchnellPlan_Click()` | ✅ Implementiert | `openMitarbeiterauswahl()` Zeile 602 | HOCH | MA-Auswahl |
| `btnNeuVeranst_Click()` | ✅ Implementiert | `neuerAuftrag()` Zeile 779 | HOCH | Neuer Auftrag |
| `mcobtnDelete_Click()` | ✅ Implementiert | `loeschenAuftrag()` Zeile 797 | HOCH | Auftrag löschen |
| `btnNeuAttach_Click()` | ✅ Implementiert | `addNewAttachment()` Zeile 642 | MITTEL | Anhang hinzufügen |
| `btnMailEins_Click()` | ✅ Implementiert | `sendeEinsatzliste('MA')` Zeile 819 | HOCH | Einsatzliste senden |
| `btn_Autosend_BOS_Click()` | ✅ Implementiert | `sendeEinsatzliste('BOS')` Zeile 819 | MITTEL | BOS Einsatzliste |
| `btnMailSub_Click()` | ✅ Implementiert | `sendeEinsatzliste('SUB')` Zeile 819 | MITTEL | SUB Einsatzliste |
| `btnDruckZusage_Click()` | ✅ Implementiert | `druckeEinsatzliste()` Zeile 844 | MITTEL | Einsatzliste drucken |
| `btn_ListeStd_Click()` | ✅ Implementiert | `druckeNamenlisteESS()` Zeile 852 | MITTEL | ESS Namensliste |
| `cmd_Messezettel_NameEintragen_Click()` | ✅ Implementiert | `cmdMessezettelNameEintragen()` Zeile 1087 | MITTEL | Messezettel |
| `cmd_BWN_send_Click()` | ✅ Implementiert | `cmdBWNSend()` Zeile 1116 | MITTEL | BWN senden |
| `btnSyncErr_Click()` | ✅ Implementiert | `checkSyncErrors()` Zeile 1318 | NIEDRIG | Sync-Fehler |
| `btn_Rueckmeld_Click()` | ✅ Implementiert | `openRueckmeldeStatistik()` Zeile 1307 | NIEDRIG | Rückmeldungen |
| `Befehl709_Click()` | ✅ Implementiert | `markELGesendet()` Zeile 1289 | NIEDRIG | EL-Log öffnen |
| `btn_rueck_Click()` | ✅ Implementiert | `undoChanges()` Zeile 1029 | NIEDRIG | Rückgängig |
| `btn_rueckgaengig_Click()` | ❌ Fehlt | - | NIEDRIG | Undo + Form schließen |
| `btn_VA_Abwesenheiten_Click()` | ❌ Fehlt | - | NIEDRIG | Abwesenheiten |
| `btn_sortieren_Click()` | ❌ Fehlt | - | MITTEL | MA sortieren |
| `btn_std_check_Click()` | ❌ Fehlt | - | MITTEL | Status auf 3, dann drucken |
| `btn_Neuer_Auftrag2_Click()` | ❌ Fehlt | - | NIEDRIG | Formular öffnen |

---

## 9. BUTTON-EVENTS - Ribbon/DaBa Toggle

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `btnRibbonAus_Click()` | ✅ Implementiert | `toggleRibbonAus()` Zeile 1249 | NIEDRIG | Ribbon ausblenden |
| `btnRibbonEin_Click()` | ✅ Implementiert | `toggleRibbonEin()` Zeile 1259 | NIEDRIG | Ribbon einblenden |
| `btnDaBaAus_Click()` | ✅ Implementiert | `toggleDaBaAus()` Zeile 1269 | NIEDRIG | Sidebar ausblenden |
| `btnDaBaEin_Click()` | ✅ Implementiert | `toggleDaBaEin()` Zeile 1279 | NIEDRIG | Sidebar einblenden |

---

## 10. BUTTON-EVENTS - Weitere (nicht implementiert)

| VBA Event | Status | HTML Implementierung | Priorität | Bemerkung |
|-----------|--------|---------------------|-----------|-----------|
| `btnXLEinsLst_Click()` | ❌ Fehlt | - | NIEDRIG | Excel Export |
| `Befehl658_Click()` | ❌ Fehlt | - | NIEDRIG | PDF Export + Anhang |
| `btnMAErz_Click()` | ❌ Fehlt | - | NIEDRIG | MA erzeugen |
| `btnAuftrBerech_Click()` | ❌ Fehlt | - | MITTEL | Auftragsberechnung |
| `btnDruck_Click()` | ❌ Fehlt | - | NIEDRIG | Drucken |
| `btnStdBerech_Click()` | ❌ Fehlt | - | MITTEL | Stundenberechnung |
| `btnDruckZusage1_Click()` | ❌ Fehlt | - | NIEDRIG | Zusage drucken (2. Button) |
| `btnMailPos_Click()` | ❌ Fehlt | - | NIEDRIG | Mail Positionen |
| `btnPDFKopf_Click()` | ❌ Fehlt | - | NIEDRIG | PDF Kopf |
| `btnPDFPos_Click()` | ❌ Fehlt | - | NIEDRIG | PDF Positionen |
| `btnVAPlanAendern_Click()` | ❌ Fehlt | - | NIEDRIG | Planung ändern |
| `btnVAPlanCrea_Click()` | ❌ Fehlt | - | NIEDRIG | Planung erstellen |
| `btnPlan_Kopie_Click()` | ❌ Fehlt | - | NIEDRIG | Planung kopieren |
| `btn_VA_Neu_Aus_Vorlage_Click()` | ❌ Fehlt | - | NIEDRIG | Aus Vorlage |

---

## 11. KRITISCHE FEHLENDE FUNKTIONALITÄT

### 1. Dat_VA_Bis_AfterUpdate - Einsatztage erstellen
**VBA-Code (Zeile 1953-2018):**
```vba
Private Sub Dat_VA_Bis_AfterUpdate()
    ' Erstellt/aktualisiert tbl_VA_AnzTage Records für jedes Datum zwischen Von/Bis
    ' Löscht alte Datumswerte die nicht mehr im Bereich liegen
    ' KRITISCH für die gesamte Schicht-Verwaltung!
End Sub
```
**Status:** ❌ FEHLT KOMPLETT in HTML
**Auswirkung:**
- Einsatztage werden nicht automatisch erstellt
- `cboVADatum` bleibt leer
- Schichten können nicht angelegt werden

**HANDLUNGSEMPFEHLUNG:** SOFORT implementieren - ist Grundvoraussetzung für Planung!

---

### 2. Form_Current - Veranst_Status_ID_AfterUpdate aufrufen
**VBA-Code (Zeile 2169):**
```vba
Private Sub Form_Current()
    ' ...
    Veranst_Status_ID_AfterUpdate
    ' ...
End Sub
```
**Status:** ⚠️ TEILWEISE - `displayRecord()` ruft nur `applyAccessRules()` auf, nicht explizit `applyStatusRules()`
**Auswirkung:**
- Status-abhängige UI-Regeln werden möglicherweise nicht korrekt angewendet
- Buttons/Tabs könnten falsch sichtbar/versteckt sein

**HANDLUNGSEMPFEHLUNG:** In `displayRecord()` explizit `applyStatusRules(rec.VA_Status)` aufrufen

---

### 3. Form_BeforeUpdate - Änderungsverfolgung
**VBA-Code (Zeile 2021-2027):**
```vba
Private Sub Form_BeforeUpdate(Cancel As Integer)
    Me!Aend_am = Now()
    Me!Aend_von = atCNames(1)
End Sub
```
**Status:** ❌ FEHLT KOMPLETT
**Auswirkung:**
- Änderungen werden nicht protokolliert
- `Aend_am` / `Aend_von` bleiben leer

**HANDLUNGSEMPFEHLUNG:** Bei allen Save/Update-Operationen diese Felder setzen

---

### 4. veranstalter_id_AfterUpdate - Fokus-Sprung
**VBA-Code (Zeile 900):**
```vba
Private Sub veranstalter_id_AfterUpdate()
    Forms!frm_VA_Auftragstamm!sub_VA_Start.SetFocus
    Forms!frm_VA_Auftragstamm!sub_VA_Start!MA_Anzahl.SetFocus
End Sub
```
**Status:** ⚠️ TEILWEISE - Regeln werden angewendet, aber Fokus-Sprung fehlt
**Auswirkung:**
- Benutzer muss manuell ins Subform klicken

**HANDLUNGSEMPFEHLUNG:** Focus-Handling per JavaScript implementieren

---

### 5. Dat_VA_Von_Exit - Auto-Befüllung Dat_VA_Bis
**VBA-Code (Zeile 1943-1950):**
```vba
Private Sub Dat_VA_Von_Exit(Cancel As Integer)
    If Len(Trim(Nz(Me!Dat_VA_Bis))) = 0 And Len(Trim(Nz(Me!Dat_VA_Von))) > 0 Then
        Me!Dat_VA_Bis = Me!Dat_VA_Von
    End If
    Dat_VA_Bis_AfterUpdate
End Sub
```
**Status:** ❌ FEHLT
**Auswirkung:**
- Benutzer muss beide Felder manuell befüllen

**HANDLUNGSEMPFEHLUNG:** Blur-Event auf `Dat_VA_Von` implementieren

---

### 6. Objekt_Exit - Auto-Lookup Objekt_ID
**VBA-Code (Zeile 2443-2454):**
```vba
Private Sub Objekt_Exit(Cancel As Integer)
    If Len(Trim(Nz(Me!Objekt_ID))) = 0 Then
        i = Nz(TLookup("ID", "tbl_ON_Objekt", "Objekt = '" & Me!Objekt & "'"), 0)
        If i > 0 Then
            Me!Objekt_ID = i
            Objekt_ID_AfterUpdate
        End If
    End If
End Sub
```
**Status:** ❌ FEHLT
**Auswirkung:**
- Objekt_ID muss manuell ausgewählt werden

**HANDLUNGSEMPFEHLUNG:** Blur-Event auf `Objekt` implementieren mit Bridge-Lookup

---

## 12. EMPFEHLUNGEN - Prioritäten

### SOFORT IMPLEMENTIEREN (KRITISCH):
1. ✅ **Dat_VA_Bis_AfterUpdate** - Einsatztage erstellen (tbl_VA_AnzTage)
2. ✅ **Form_BeforeUpdate** - Änderungsverfolgung (Aend_am, Aend_von)
3. ✅ **Form_Current** - Explizit `applyStatusRules()` aufrufen

### HOCH PRIORITÄT:
4. ✅ **Dat_VA_Von_Exit** - Auto-Befüllung Dat_VA_Bis + AfterUpdate-Trigger
5. ✅ **Objekt_Exit** - Auto-Lookup Objekt_ID aus Objektname
6. ✅ **veranstalter_id_AfterUpdate** - Fokus-Sprung zu sub_VA_Start

### MITTEL PRIORITÄT:
7. **btn_sortieren_Click** - MA-Zuordnungen sortieren
8. **btn_std_check_Click** - Status auf 3 setzen + Zusage drucken
9. **btnAuftrBerech_Click** - Auftragsberechnung
10. **btnStdBerech_Click** - Stundenberechnung

### NIEDRIG PRIORITÄT:
11. GotFocus/LostFocus Events (UI-Feedback)
12. DblClick Events (außer bereits implementierte)
13. Export-Buttons (Excel, PDF)
14. Weitere Utility-Buttons

---

## 13. TESTPLAN

### Test 1: Einsatztage erstellen
1. Neuen Auftrag anlegen
2. `Dat_VA_Von` = 01.02.2026
3. `Dat_VA_Bis` = 05.02.2026
4. **ERWARTUNG:** `cboVADatum` enthält 5 Einträge (01.02 - 05.02)
5. **AKTUELL:** ❌ cboVADatum bleibt leer

### Test 2: Status-Regeln bei Current
1. Auftrag mit Status = 4 (abgerechnet) laden
2. **ERWARTUNG:** Subforms sind locked, Rechnungs-Tab sichtbar
3. **AKTUELL:** ⚠️ Möglicherweise falsch (nicht explizit getestet)

### Test 3: Änderungsverfolgung
1. Auftrag ändern (z.B. Ort)
2. Speichern
3. **ERWARTUNG:** `Aend_am` = jetzt, `Aend_von` = Benutzername
4. **AKTUELL:** ❌ Felder bleiben leer

### Test 4: Auto-Befüllung Dat_VA_Bis
1. Neuen Auftrag anlegen
2. `Dat_VA_Von` = 10.02.2026
3. Feld verlassen (Tab/Enter)
4. **ERWARTUNG:** `Dat_VA_Bis` = 10.02.2026 automatisch
5. **AKTUELL:** ❌ Dat_VA_Bis bleibt leer

---

## FAZIT

**Implementierungsgrad:** 53% (47 von 88 Events)

**Kritische Lücken:**
- ❌ Einsatztage-Verwaltung (Dat_VA_Bis_AfterUpdate)
- ❌ Änderungsverfolgung (Form_BeforeUpdate)
- ⚠️ Status-Regeln (Form_Current teilweise)
- ❌ Auto-Befüllung (Dat_VA_Von_Exit, Objekt_Exit)

**NÄCHSTE SCHRITTE:**
1. Dat_VA_Bis_AfterUpdate implementieren (Bridge-Endpoint + HTML Logic)
2. Form_BeforeUpdate implementieren (bei allen Save-Operationen)
3. Form_Current erweitern (explizit applyStatusRules)
4. Exit-Events für Auto-Befüllung implementieren

---

**Erstellt:** 2026-01-05
**Autor:** Claude Code Event Analyzer
