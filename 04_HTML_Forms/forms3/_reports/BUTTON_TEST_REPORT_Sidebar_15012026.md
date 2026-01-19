# SIDEBAR-NAVIGATION BUTTON TEST REPORT

**Datum:** 15.01.2026
**Testumfang:** Alle Menü-Buttons in shell.html
**Ziel:** Prüfung der Navigation und Vollständigkeit

---

## SIDEBAR-BUTTONS (shell.html)

### Kategorie: PLANUNG

| Nr | Button-Label | data-form | Ziel-HTML | Status | Bemerkung |
|----|-------------|-----------|-----------|--------|-----------|
| 1 | Dienstplan MA | `frm_DP_Dienstplan_MA` | frm_DP_Dienstplan_MA.html | ✅ existiert | Dienstplan aller Mitarbeiter |
| 2 | Planung Objekt | `frm_DP_Dienstplan_Objekt` | frm_DP_Dienstplan_Objekt.html | ✅ existiert | Aufträge und Einsätze planen |

### Kategorie: STAMMDATEN

| Nr | Button-Label | data-form | Ziel-HTML | Status | Bemerkung |
|----|-------------|-----------|-----------|--------|-----------|
| 3 | Aufträge | `frm_va_Auftragstamm` | frm_va_Auftragstamm.html | ✅ existiert | Default-Tab (gepinnt) |
| 4 | Mitarbeiter | `frm_MA_Mitarbeiterstamm` | frm_MA_Mitarbeiterstamm.html | ✅ existiert | Mitarbeiterdaten verwalten |
| 5 | Kunden | `frm_KD_Kundenstamm` | frm_KD_Kundenstamm.html | ✅ existiert | Kundendaten verwalten |
| 6 | Objekte | `frm_OB_Objekt` | frm_OB_Objekt.html | ✅ existiert | Objekte/Standorte verwalten |

### Kategorie: PERSONAL

| Nr | Button-Label | data-form | Ziel-HTML | Status | Bemerkung |
|----|-------------|-----------|-----------|--------|-----------|
| 7 | Zeitkonten | `frm_MA_Zeitkonten` | frm_MA_Zeitkonten.html | ✅ existiert | Zeitkonten der Mitarbeiter |
| 8 | Stundenauswertung | `frm_N_Stundenauswertung` | ❌ FEHLT | ❌ fehlt | Muss noch erstellt werden |
| 9 | Abwesenheiten | `frm_MA_Abwesenheit` | frm_MA_Abwesenheit.html | ✅ existiert | Urlaub, Krankheit, Abwesenheiten |
| 10 | Telefonliste | data-action="telefonliste" | VBA-Action (rpt_telefonliste) | ⚙️ VBA | Ruft Access-Bericht auf |
| 11 | Letzter Einsatz | data-action="letzterEinsatz" | VBA-Action (Query) | ⚙️ VBA | Ruft qry_MA_letzter_Einsatz_Gueni auf |
| 12 | Lohnarten | `zfrm_ZK_Lohnarten_Zuschlag` | ❌ FEHLT | ❌ fehlt | Existiert nicht in forms3 |

### Kategorie: EXTRAS

| Nr | Button-Label | data-form | Ziel-HTML | Status | Bemerkung |
|----|-------------|-----------|-----------|--------|-----------|
| 13 | Schnellauswahl | `frm_MA_VA_Schnellauswahl` | frm_MA_VA_Schnellauswahl.html | ✅ existiert | Schnelle MA-Zuweisung |
| 14 | Einsatzübersicht | `frm_Einsatzuebersicht` | frm_Einsatzuebersicht.html | ✅ existiert | Alle Einsätze auf einen Blick |
| 15 | Vorlagen | `frmTop_neue_Vorlagen` | ❌ FEHLT | ❌ fehlt | Existiert nicht in forms3 |

### Kategorie: EXPORT

| Nr | Button-Label | data-form | Ziel-HTML | Status | Bemerkung |
|----|-------------|-----------|-----------|--------|-----------|
| 16 | MA Stamm Excel | data-action="maStammExcel" | VBA-Action | ⚙️ VBA | btn_MAStamm_Excel_Click_FromHTML |
| 17 | FCN Meldeliste | data-action="fcnMeldeliste" | VBA-Action | ⚙️ VBA | btn_FCN_Meldeliste_Click_FromHTML |
| 18 | Fürth Namensliste | data-action="fuerthNamensliste" | VBA-Action | ⚙️ VBA | btn_FuerthNamensliste_Click_FromHTML |
| 19 | Sub Stunden | data-action="subStunden" | VBA-Action | ⚙️ VBA | btn_stunden_sub_Click_FromHTML |
| 20 | Stunden MA | data-action="stundenMA" | VBA-Action | ⚙️ VBA | btnStundenMA_Click_FromHTML |

### Kategorie: SYSTEM

| Nr | Button-Label | data-form | Ziel-HTML | Status | Bemerkung |
|----|-------------|-----------|-----------|--------|-----------|
| 21 | Lex Aktiv | `frm_Lex_Aktiv` | ❌ FEHLT | ❌ fehlt | Existiert nicht in forms3 |
| 22 | Löwensaal Sync | data-action="loewensaalSync" | VBA-Action | ⚙️ VBA | btn_LoewensaalSync_Click_FromHTML |

---

## ZUSAMMENFASSUNG

**Gesamt:** 22 Menü-Buttons in shell.html
**HTML-Formulare:** 15 Buttons → 11 ✅ existieren, 4 ❌ fehlen
**VBA-Actions:** 7 Buttons → alle funktionieren via VBA Bridge Server

**Zusätzlich in sidebar.html (Access-Style) aber NICHT in shell.html:**
- ✅ 5 Formulare existieren und sollten ergänzt werden
- ❌ 2 Formulare existieren nicht (müssen erstellt werden)

### FEHLENDE HTML-FORMULARE:

1. **frm_N_Stundenauswertung.html** (Button Nr. 8)
   - Kategorie: PERSONAL
   - Funktion: Stundenauswertung und Statistik

2. **zfrm_ZK_Lohnarten_Zuschlag.html** (Button Nr. 12)
   - Kategorie: PERSONAL
   - Funktion: Lohnarten verwalten

3. **frmTop_neue_Vorlagen.html** (Button Nr. 15)
   - Kategorie: EXTRAS
   - Funktion: Vorlagen verwalten

4. **frm_Lex_Aktiv.html** (Button Nr. 21)
   - Kategorie: SYSTEM
   - Funktion: Lexware Aktiv-Status

---

## VERGLEICH: SIDEBAR vs. ACCESS HAUPTMENÜ

### In HTML VORHANDEN (shell.html), aber NICHT in Access Hauptmenü:
- Dienstplan MA (frm_DP_Dienstplan_MA)
- Planung Objekt (frm_DP_Dienstplan_Objekt)
- Objekte (frm_OB_Objekt)
- Schnellauswahl (frm_MA_VA_Schnellauswahl)
- Einsatzübersicht (frm_Einsatzuebersicht)

### In ACCESS VORHANDEN (sidebar.html), aber NICHT in Shell:

**Aus sidebar.html extrahiert:**

| Button-Label | data-form | Ziel-HTML | Status | Access-Formular |
|-------------|-----------|-----------|--------|-----------------|
| Dienstplanübersicht | frm_N_Dienstplanübersicht | ❌ FEHLT | Existiert nicht | frm_N_Dienstplanuebersicht |
| Planungsübersicht | frm_DP_Dienstplan_Objekt | ✅ ist "Planung Objekt" | Dopplung | - |
| Auftragsverwaltung | frm_va_Auftragstamm | ✅ ist "Aufträge" | Dopplung | - |
| Mitarbeiterverwaltung | frm_MA_Mitarbeiterstamm | ✅ ist "Mitarbeiter" | Dopplung | - |
| Offene Mail Anfragen | frm_MA_Offene_Anfragen | ✅ existiert | **FEHLT in Shell!** | frm_MA_Offene_Anfragen |
| Excel Zeitkonten | frm_MA_Zeitkonten | ✅ ist "Zeitkonten" | Dopplung | - |
| Zeitkonten | frm_MA_Zeitkonten | ✅ ist "Zeitkonten" | Dopplung | - |
| Abwesenheitsplanung | frmTop_MA_Abwesenheitsplanung | ✅ existiert | **FEHLT in Shell!** | frmTop_MA_Abwesenheitsplanung |
| Dienstausweis erstellen | frm_Ausweis_Create | ✅ existiert | **FEHLT in Shell!** | frm_Ausweis_Create |
| Stundenabgleich | frm_N_Stundenauswertung | ❌ FEHLT | Nicht vorhanden | frm_N_Stundenauswertung |
| Kundenverwaltung | frm_KD_Kundenstamm | ✅ ist "Kunden" | Dopplung | - |
| Objektverwaltung | frm_OB_Objekt | ✅ ist "Objekte" | Dopplung | - |
| Verrechnungssätze | frm_Verrechnungssaetze | ⚠️ frm_KD_Verrechnungssaetze.html | Existiert mit anderem Namen | frm_KD_Verrechnungssaetze |
| Sub Rechnungen | frm_SubRechnungen | ❌ FEHLT | Existiert nicht | ? |
| E-Mail | frmOff_Outlook_aufrufen | ✅ existiert | **FEHLT in Shell!** | frmOff_Outlook_aufrufen |
| Menü 2 | frm_Menuefuehrung1 | ✅ existiert | In Shell ersetzt durch VBA-Actions | frm_Menuefuehrung1 |
| System Info | frm_SystemInfo | ✅ frm_Systeminfo.html | **FEHLT in Shell!** | frm_Systeminfo |

---

## EMPFEHLUNGEN

### 1. FEHLENDE FORMULARE IN SHELL ERGÄNZEN:

```html
<!-- PERSONAL Kategorie erweitern -->
<button class="menu-btn" data-form="frmTop_MA_Abwesenheitsplanung" title="Abwesenheiten planen">Abwesenheitsplanung</button>
<button class="menu-btn" data-form="frm_MA_Offene_Anfragen" title="Offene Anfragen verwalten">Offene Anfragen</button>
<button class="menu-btn" data-form="frm_Ausweis_Create" title="Dienstausweise erstellen">Dienstausweis</button>

<!-- SYSTEM Kategorie erweitern -->
<button class="menu-btn" data-form="frm_Systeminfo" title="Systeminformationen anzeigen">System Info</button>
<button class="menu-btn" data-form="frmOff_Outlook_aufrufen" title="E-Mail versenden">E-Mail</button>
```

### 2. FORM_TITLES erweitern (shell.html):

```javascript
const FORM_TITLES = {
    // ... bestehende Einträge ...
    'frmTop_MA_Abwesenheitsplanung': 'Abwesenheitsplanung',
    'frm_MA_Offene_Anfragen': 'Offene Anfragen',
    'frm_Ausweis_Create': 'Dienstausweis',
    'frm_Systeminfo': 'System Info',
    'frmOff_Outlook_aufrufen': 'E-Mail'
};
```

### 3. FEHLENDE HTML-DATEIEN ERSTELLEN:

**Priorität HOCH (existieren bereits, nur in Shell ergänzen):**
- ✅ frm_MA_Offene_Anfragen.html (existiert, fehlt aber in Shell)
- ✅ frmTop_MA_Abwesenheitsplanung.html (existiert, fehlt aber in Shell)
- ✅ frm_Ausweis_Create.html (existiert, fehlt aber in Shell)
- ✅ frmOff_Outlook_aufrufen.html (existiert, fehlt aber in Shell)
- ✅ frm_Systeminfo.html (existiert, fehlt aber in Shell)

**Priorität HOCH (müssen erstellt werden):**
- ❌ frm_N_Stundenauswertung.html (wird bereits referenziert, aber fehlt)

**Priorität MITTEL:**
- zfrm_ZK_Lohnarten_Zuschlag.html
- frmTop_neue_Vorlagen.html
- frm_Lex_Aktiv.html

### 4. VBA BRIDGE SERVER FUNKTIONEN:

Alle Export-Funktionen (Kategorie EXPORT) benötigen laufenden VBA Bridge Server auf Port 5002:
- ✅ Endpoints implementiert
- ✅ VBA-Funktionen vorhanden (z.B. btn_MAStamm_Excel_Click_FromHTML)
- ⚠️ Access MUSS geöffnet sein für VBA Bridge!

---

## TEST-ERGEBNISSE: NAVIGATION

**Getestete Shell-Funktionalität:**
- ✅ Tab-System funktioniert
- ✅ Cache-Buster (_t=timestamp) verhindert veraltete Versionen
- ✅ URL-Parameter werden korrekt weitergegeben (id, vadatum_id, vastart_id)
- ✅ srcdoc-Methode (statt iframe.src) funktioniert mit VisBug
- ✅ SHELL_PARAMS werden als globales Objekt injiziert
- ✅ Base-Tag für relative Pfade wird automatisch gesetzt

**Bekannte Probleme:**
- ❌ Formulare ohne .html-Datei führen zu 404-Fehler
- ⚠️ VBA-Actions funktionieren nur wenn Access UND VBA Bridge Server laufen
- ⚠️ Einige Formularnamen in sidebar.html stimmen nicht mit Dateinamen überein (z.B. "frm_N_Dienstplanübersicht" statt "frm_N_Dienstplanuebersicht")

---

## NÄCHSTE SCHRITTE

1. **Fehlende Formulare in Shell ergänzen** (siehe Empfehlungen)
2. **Formulare erstellen** für fehlende HTML-Dateien
3. **Sidebar.html aktualisieren** (Access-style Menü) mit korrekten Dateinamen
4. **FORM_MAP in sidebar.js erweitern** für neue Formulare
5. **Test aller Buttons** nach Ergänzungen

---

## VOLLSTÄNDIGE FORMULAR-ÜBERSICHT

### Vorhandene HTML-Formulare in forms3 (Hauptformulare):

| Dateiname | In shell.html | In sidebar.html | Status |
|-----------|---------------|-----------------|--------|
| frm_va_Auftragstamm.html | ✅ Aufträge | ✅ Auftragsverwaltung | OK |
| frm_MA_Mitarbeiterstamm.html | ✅ Mitarbeiter | ✅ Mitarbeiterverwaltung | OK |
| frm_KD_Kundenstamm.html | ✅ Kunden | ✅ Kundenverwaltung | OK |
| frm_OB_Objekt.html | ✅ Objekte | ✅ Objektverwaltung | OK |
| frm_DP_Dienstplan_MA.html | ✅ Dienstplan MA | ❌ | OK |
| frm_DP_Dienstplan_Objekt.html | ✅ Planung Objekt | ✅ Planungsübersicht | OK |
| frm_MA_Zeitkonten.html | ✅ Zeitkonten | ✅ Excel Zeitkonten | OK |
| frm_MA_Abwesenheit.html | ✅ Abwesenheiten | ❌ | OK |
| frm_MA_VA_Schnellauswahl.html | ✅ Schnellauswahl | ❌ | OK |
| frm_Einsatzuebersicht.html | ✅ Einsatzübersicht | ❌ | OK |
| frm_MA_Offene_Anfragen.html | ❌ | ✅ Offene Mail Anfragen | **In Shell ergänzen!** |
| frmTop_MA_Abwesenheitsplanung.html | ❌ | ✅ Abwesenheitsplanung | **In Shell ergänzen!** |
| frm_Ausweis_Create.html | ❌ | ✅ Dienstausweis erstellen | **In Shell ergänzen!** |
| frmOff_Outlook_aufrufen.html | ❌ | ✅ E-Mail | **In Shell ergänzen!** |
| frm_Systeminfo.html | ❌ | ✅ System Info | **In Shell ergänzen!** |
| frm_Menuefuehrung1.html | ❌ (VBA-Actions) | ✅ Menü 2 | OK (in Shell ersetzt) |
| frm_KD_Verrechnungssaetze.html | ❌ | ⚠️ Verrechnungssätze | **In Shell ergänzen!** |
| frm_N_Bewerber.html | ❌ | ❌ | Nicht in Menüs |
| frm_Abwesenheiten.html | ❌ | ❌ | Nicht in Menüs |
| frm_abwesenheitsuebersicht.html | ❌ | ❌ | Nicht in Menüs |
| frm_Kundenpreise_gueni.html | ❌ | ✅ Kundenpreise | **In Shell ergänzen!** |
| frm_MA_Serien_eMail_Auftrag.html | ❌ | ❌ | Nicht in Menüs |
| frm_MA_Serien_eMail_dienstplan.html | ❌ | ❌ | Nicht in Menüs |
| frm_MA_VA_Positionszuordnung.html | ❌ | ❌ | Nicht in Menüs |
| frm_Angebot.html | ❌ | ❌ | Nicht in Menüs |
| frm_Rechnung.html | ❌ | ❌ | Nicht in Menüs |
| frm_Rueckmeldestatistik.html | ❌ | ❌ | Nicht in Menüs |
| frm_KD_Umsatzauswertung.html | ❌ | ❌ | Nicht in Menüs |
| frm_MA_Adressen.html | ❌ | ❌ | Nicht in Menüs |
| frm_MA_Tabelle.html | ❌ | ❌ | Nicht in Menüs |
| frm_Mahnung.html | ❌ | ❌ | Nicht in Menüs |
| frm_DP_Einzeldienstplaene.html | ❌ | ❌ | Nicht in Menüs |
| zfrm_MA_Stunden_Lexware.html | ❌ | ✅ Stunden Lexware | **In Shell ergänzen!** |
| zfrm_Rueckmeldungen.html | ❌ | ❌ | Nicht in Menüs |
| zfrm_SyncError.html | ❌ | ❌ | Nicht in Menüs |

**Fehlende Formulare (referenziert aber nicht vorhanden):**
- ❌ frm_N_Stundenauswertung.html (Button in shell.html + sidebar.html)
- ❌ zfrm_ZK_Lohnarten_Zuschlag.html (Button in shell.html)
- ❌ frmTop_neue_Vorlagen.html (Button in shell.html)
- ❌ frm_Lex_Aktiv.html (Button in shell.html)
- ❌ frm_SubRechnungen.html (Button in sidebar.html)
- ❌ frm_N_Dienstplanuebersicht.html (Button in sidebar.html)

---

**Stand:** 15.01.2026
**Bericht erstellt von:** Claude Code
**Speicherort:** `04_HTML_Forms\forms3\_reports\BUTTON_TEST_REPORT_Sidebar_15012026.md`
