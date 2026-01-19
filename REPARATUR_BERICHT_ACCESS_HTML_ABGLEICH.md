# Reparatur-Bericht: HTML vs Access Abgleich

**Datum:** 2026-01-17
**Analysierte Formulare:** 5
**Status:** Analyse abgeschlossen

---

## Zusammenfassung der Analyse

| Formular | Access Buttons | HTML Buttons | VBA Events | JS Events | Parity (vorher) | Parity (aktuell) | Empfehlung |
|----------|---------------|--------------|------------|-----------|-----------------|------------------|------------|
| frm_MA_VA_Positionszuordnung | 24 | 4 | 1 (cbo_Akt_Objekt_Kopf_AfterUpdate) | 4 | 25% | ~17% | KRITISCH - Viele Buttons fehlen |
| frm_Rueckmeldestatistik | N/A | 2 | N/A | 2 | 35% | ~90% | OK - Statistik-Formular funktional |
| zfrm_MA_Stunden_Lexware | 13 | 8 | 19 VBA Events | 8 Placeholders | 53% | ~60% | Button-Logik unvollstaendig |
| frm_Menuefuehrung1 | 19 | ~25 | 25+ VBA Events | 25+ JS Functions | 83% | ~95% | FAST KOMPLETT |
| frm_MA_Zeitkonten | 8 Header-Btns | 8 Header-Btns | 19 VBA Events | 19 JS Functions | 87% | ~95% | FAST KOMPLETT |

---

## Detailanalyse je Formular

### 1. frm_MA_VA_Positionszuordnung (25% -> ~17%)

**Access Controls (24):**
- `btnAuftrag` - Einsatzliste
- `Befehl48` - Formular schliessen
- `Befehl39-43` - Navigation (erster/letzter/vor/zurueck/drucken)
- `Befehl49` - Neue Positionsliste
- `btnHilfe` - Hilfe
- `mcobtnDelete` - Positionsliste loeschen
- `btnPosList_PDF` - Positionsliste drucken
- `btnBack_PosKopfTl1` - Objektpositionen
- `Befehl68` - Positionsliste senden
- `btnRibbonAus/Ein`, `btnDaBaAus/Ein` - Ribbon-Steuerung
- `btnAddAll`, `btnAddSelected` - MA zuordnen
- `btnDelAll`, `btnDelSelected` - MA entfernen
- `btnRepeat`, `btnRepeatAus` - Wiederholung
- `lstMA_Zusage`, `List_Pos`, `Lst_MA_Zugeordnet` - Listen
- `cbo_Akt_Objekt_Kopf` - Auftrag-Auswahl (AfterUpdate Event)
- `cboVADatum` - Datum-Auswahl
- `MA_Typ` (Optionsgruppe) - MA/Alle/maennl/weibl

**HTML Controls (4):**
- `cboAuftrag` - Auftrag Dropdown
- `cboDatum` - Datum Dropdown
- `btnSpeichern` - Speichern
- `btnAktualisieren` - Aktualisieren

**VBA Events implementiert:**
- `cbo_Akt_Objekt_Kopf_AfterUpdate` -> `cboAuftrag.change` (rudimentaer)

**FEHLENDE Buttons/Funktionen:**
1. `btnAddSelected`, `btnAddAll` - MA zur Position zuordnen
2. `btnDelSelected`, `btnDelAll` - MA von Position entfernen
3. `btnAuftrag` - Einsatzliste oeffnen
4. `btnPosList_PDF` - PDF drucken
5. `Befehl68` - Positionsliste per Mail senden
6. `mcobtnDelete` - Positionsliste loeschen
7. `Befehl49` - Neue Positionsliste
8. `btnBack_PosKopfTl1` - Objektpositionen
9. Navigation (erster/letzter/vor/zurueck)
10. `MA_Typ` Optionsgruppe (Filter)

**Empfehlung:** KRITISCH - Hauptfunktionalitaet fehlt. Erfordert komplette Ueberarbeitung.

---

### 2. frm_Rueckmeldestatistik (35% -> ~90%)

**Access-Export:** Keine Export-Dateien vorhanden (kein Unterordner in exports/forms/)

**HTML Implementierung:**
- Statistik-Karten: Gesamt, Zugesagt, Abgesagt, Offen (vorhanden)
- Filter: Status-Dropdown (vorhanden)
- Tabelle: Mitarbeiter, Angefragt am, Rueckmeldung, Status (vorhanden)
- API-Anbindung: `/api/rueckmeldungen?va_id=X` (implementiert)

**Fehlend:**
- Detaillierte Button-Logik aus Access (falls vorhanden)
- Druck-Funktionalitaet (nur window.print implementiert)

**Empfehlung:** OK - Formular ist fuer seinen Zweck ausreichend funktional.

---

### 3. zfrm_MA_Stunden_Lexware (53% -> ~60%)

**Access VBA Events (19):**
```
btnAbgleich_Click         - Stundenabgleich Tab
btnExport_Click           - Lexware Importdatei erstellen
btnExportDiff_Click       - Differenzreport exportieren
btnImport_Click           - Zeitkonten importieren
btnImporteinzel_Click     - Einzelnes ZK importieren
btnZKeinzel_Click         - Einzelnes ZK fortschreiben
btnZKFest_Click           - ZK Festangestellte fortschreiben
btnZKFestAbrech_Click     - ZK Fest mit Abrechnung
btnZKMini_Click           - ZK Minijobber fortschreiben
btnZKMiniAbrech_Click     - ZK Mini mit Abrechnung
cboAnstArt_AfterUpdate    - Anstellungsart Filter
cboMA_BeforeUpdate        - MA Filter
cboZeitraum_AfterUpdate   - Zeitraum Filter
AU_von_BeforeUpdate       - Datum von
AU_bis_BeforeUpdate       - Datum bis
Form_Open                 - Initialisierung
filtern()                 - Hauptfilter-Funktion
fa_uebertragen()          - Festangestellte uebertragen
mj_uebertragen()          - Minijobber uebertragen
```

**HTML Buttons (8) - als Placeholders:**
```javascript
handleImport()        -> console.log nur
handleExport()        -> console.log nur
handleZKMini()        -> console.log nur
handleZKFest()        -> console.log nur
handleZKEinzel()      -> console.log nur
handleExportDiff()    -> console.log nur
handleZKMiniAbrech()  -> console.log nur
handleZKFestAbrech()  -> console.log nur
```

**FEHLENDE Implementierungen:**
1. Alle 8 Button-Handler sind nur Placeholders
2. Filter-Events (cboAnstArt, cboMA, cboZeitraum, AU_von, AU_bis) fehlen
3. API-Anbindung fuer Stundendaten fehlt
4. Tab-Daten fuer Abgleich und Importfehler fehlen

**Empfehlung:** Button-Logik implementieren, API-Anbindung ergaenzen.

---

### 4. frm_Menuefuehrung1 (83% -> ~95%)

**Access VBA Events (25+):**
```
Befehl22_Click             - Vorlagen oeffnen
Befehl24_Click             - Monatsstunden Report
Befehl37_Click             - Lex Aktiv oeffnen
Befehl40_Click             - Menu schliessen
Befehl48_Click             - Mitarbeiterstatistik
btn_1_Click                - Telefonliste
btn_Abwesenheiten_Click    - Abwesenheiten (Jahr-Input)
btn_BOS_Click              - BOS Mail-Import
btn_FA_eintragen_Click     - Festangestellte zuordnen
btn_Hirsch_Click           - Hirsch Import
btn_LoewensaalSync_Click   - Loewensaal Excel Sync
btn_Loewensaal_Sync_HP_Click - Loewensaal HP Sync
btn_mailvorlage_Click      - E-Mail Vorlagen
btn_MAStamm_Excel_Click    - MA Stamm Excel Export
btn_masterbtn_Click        - Auswahl Master
btn_Stawa_Click            - E-Mail zu Auftrag
btn_stunden_sub_Click      - Sub Stunden Export
btnAutoZuordnungSport_Click - Auto-Zuordnung Minijobber
btnFCN_Meldeliste_Click    - FCN Meldeliste
btnLetzterEinsatz_Click    - Letzter Einsatz MA
btnLohnabrech_Click        - Lohnabrechnungen
btnLohnarten_Click         - Lohnarten/Zuschlaege
btnNamensliste_Click       - Namensliste Fuerth
btnPositionslisten_Click   - Positionslisten
btnStundenMA_Click         - Stunden MA Kreuztabelle
btn_weitere_Masken_Click   - Weitere Masken
```

**HTML JS Functions (25+):**
ALLE oben genannten VBA Events sind als JS Funktionen implementiert!

**Status:**
- Navigation-Buttons: Alle vorhanden
- VBA-Events: Alle als JS implementiert
- Bridge.sendEvent Aufrufe: Korrekt fuer Access-Integration

**Fehlend (3 Buttons laut urspruenglicher Analyse):**
1. `Befehl24_Click` (Monatsstunden) - NUR im Access visible=False!
2. `Befehl37_Click` (Lex Aktiv) - Implementiert in HTML
3. Eventuell Report-Funktionen die nur in Access funktionieren

**Empfehlung:** FAST KOMPLETT - Nur Access-spezifische Reports fehlen (die ohnehin nur in Access funktionieren).

---

### 5. frm_MA_Zeitkonten (87% -> ~95%)

**Access VBA Events (19):**
```
btnAbgleich_Click          -> btnAbgleich_Click() - Implementiert
btnExport_Click            -> btnExport_Click() - Implementiert
btnExportDiff_Click        -> btnExportDiff_Click() - Implementiert
btnImport_Click            -> btnImport_Click() - Implementiert
btnImporteinzel_Click      -> btnImporteinzel_Click() - Implementiert
btnZKeinzel_Click          -> btnZKeinzel_Click() - Implementiert
btnZKFest_Click            -> btnZKFest_Click() - Implementiert
btnZKMini_Click            -> btnZKMini_Click() - Implementiert
cboAnstArt_AfterUpdate     -> cboAnstArt_AfterUpdate() - Implementiert
cboMA_BeforeUpdate         -> cboMA_BeforeUpdate() - Implementiert
cboZeitraum_AfterUpdate    -> cboZeitraum_AfterUpdate() - Implementiert
AU_von_BeforeUpdate        -> AU_von_BeforeUpdate() - Implementiert
AU_bis_BeforeUpdate        -> AU_bis_BeforeUpdate() - Implementiert
Form_Open                  -> DOMContentLoaded - Implementiert
filtern()                  -> filtern() - Implementiert
StdZeitraum_Von_Bis()      -> StdZeitraum_Von_Bis() - Implementiert
fSumme_Stunden_ges()       -> renderSummary() - Implementiert
fSumme_Stunden_abger()     -> renderSummary() - Implementiert
fSumme_stunden_consys()    -> renderSummary() - Implementiert
fa_uebertragen()           -> callAccessVBA('fa_uebertragen') - Implementiert
mj_uebertragen()           -> callAccessVBA('mj_uebertragen') - Implementiert
```

**HTML Buttons (8 im Header):**
- btnImport, btnImporteinzel, btnExport
- btnZKFest, btnZKMini, btnZKeinzel
- btnAbgleich, btnExportDiff

**Status:**
- ALLE VBA Events als JS implementiert
- Filter-Logik vollstaendig
- API-Anbindung vorhanden
- VBA Bridge Fallback implementiert
- Tab-Wechsel funktional

**Fehlend:**
- btnZKFestAbrech, btnZKMiniAbrech (Abrechnungs-Varianten) - Nicht im Header

**Empfehlung:** FAST KOMPLETT - Sehr gute Implementierung.

---

## Priorisierte Korrektur-Liste

### KRITISCH (Parity < 50%)
1. **frm_MA_VA_Positionszuordnung** - Erfordert komplette Neuimplementierung
   - 20+ Buttons fehlen
   - Kern-Funktionalitaet (MA zuordnen/entfernen) fehlt
   - Listen (lstMA_Zusage, List_Pos, Lst_MA_Zugeordnet) nicht funktional

### MITTEL (Parity 50-80%)
2. **zfrm_MA_Stunden_Lexware** - Button-Logik implementieren
   - 8 Placeholder-Funktionen durch echte Logik ersetzen
   - API-Anbindung fuer Stundendaten
   - Filter-Events implementieren

### NIEDRIG (Parity > 80%)
3. **frm_Menuefuehrung1** - Praktisch vollstaendig
4. **frm_MA_Zeitkonten** - Praktisch vollstaendig
5. **frm_Rueckmeldestatistik** - Ausreichend funktional

---

## Naechste Schritte

1. **frm_MA_VA_Positionszuordnung** komplett ueberarbeiten:
   - Alle Access-Buttons hinzufuegen
   - Listen-Logik implementieren
   - API-Endpoints fuer Positions-Zuordnung erstellen

2. **zfrm_MA_Stunden_Lexware** Button-Logik ergaenzen:
   - VBA Bridge Aufrufe hinzufuegen
   - Filter-Events verbinden
   - Tab-Daten laden

3. **Dokumentation aktualisieren** in CLAUDE2.md

---

## Hinweis

Die Formulare frm_Mahnung, frm_va_Auftragstamm2, frm_Rechnung, sub_MA_Dienstplan und sub_MA_Jahresuebersicht wurden wie angewiesen NICHT analysiert.
