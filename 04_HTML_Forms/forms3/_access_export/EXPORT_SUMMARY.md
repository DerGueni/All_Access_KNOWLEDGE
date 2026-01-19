# EXPORT SUMMARY - Access Frontend Dokumentation

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb
Erstellt durch: Claude Code Agent

---

## OBJEKTZAEHLUNG

| Objekttyp | Anzahl | Dokumentation |
|-----------|--------|---------------|
| **Formulare** | 271 | forms_inventory.md |
| **VBA-Module** | ~216 | vba_modules.md |
| **Abfragen** | 560 | queries_inventory.md |
| **Tabellen** | 187 | tables_inventory.md |
| **Workflows** | 9 | workflows.md |
| **Button-Ketten** | 40+ | button_chains.md |

**Gesamt: ~1.283 dokumentierte Objekte**

---

## ERSTELLTE DOKUMENTATIONSDATEIEN

### 1. forms_inventory.md
- **Inhalt:** Komplettes Formular-Inventar
- **Kategorien:** Hauptformulare, Unterformulare, Popup-Formulare, Hilfsformulare
- **Details pro Formular:**
  - Name und Typ
  - RecordSource (Datenquelle)
  - Unterformulare mit Link Master/Child Fields
  - Buttons mit VBA-Funktionen
  - Tab-Seiten

### 2. vba_modules.md
- **Inhalt:** VBA-Modul-Inventar
- **Kategorien:**
  - Kern-/System-Module (~15)
  - E-Mail-Module (~8)
  - Menu/Navigation (~5)
  - Planung (~5)
  - Rechnung (~3)
  - Excel/Import/Export (~15)
  - Geo/Distanz (~12)
  - Word/Dokument (~4)
  - Reporting (~5)
  - Hilfsfunktionen (~20)
  - Zeitkonten (~5)
  - AI/Automatisierung (~6)
  - Formular-Hilfs (~10)
  - Sonstige/Test (~100+)
- **Details pro Modul:**
  - Wichtige Funktionen
  - Aufruf-Ketten
  - API-Deklarationen

### 3. queries_inventory.md
- **Inhalt:** Abfragen-Inventar (560 Abfragen)
- **Kategorien:**
  - Dienstplan (qry_DP_) ~50
  - MA-Zuordnung (qry_MA_VA_) ~40
  - Anzahl/Statistik (qry_Anz_) ~30
  - E-Mail (qry_eMail_) ~15
  - Auswertung ~10
  - Rechnung/Report ~30
  - Duplikate ~5
  - Kreuztabellen ~8
  - Planung ~15
  - Hilfs/System ~20
  - Sonstige ~340
- **Details:**
  - SQL-Statements (Beispiele)
  - Verwendungszweck
  - Abfrage-Ketten

### 4. tables_inventory.md
- **Inhalt:** Tabellen-Inventar (187 Tabellen)
- **Kategorien:**
  - Stammdaten (tbl_MA_, tbl_KD_, tbl_OB_)
  - Auftrags-Tabellen (tbl_VA_)
  - Zuordnungs-Tabellen
  - Nichtverfuegbarkeits-Tabellen
  - Rechnungs-Tabellen
  - E-Mail-Tabellen
  - Hilfs-/Lookup-Tabellen
  - Temporaere Tabellen (tbltmp_)
  - Zeitkonten-Tabellen (ztbl_ZK_)
  - Frontend-Tabellen (ztbl_*_FE)
  - System-Tabellen
- **Details:**
  - Primaerschluessel
  - Wichtige Felder mit Beschreibung
  - Fremdschluessel-Beziehungen
  - Beziehungsdiagramm (ASCII)

### 5. workflows.md
- **Inhalt:** 9 Haupt-Workflows dokumentiert
- **Workflows:**
  1. Auftrag anlegen (komplett)
  2. Mitarbeiter zuordnen (3 Methoden)
  3. E-Mail-Versand (Serien-Mail)
  4. E-Mail-Import (Zu-/Absagen)
  5. Druckprozesse
  6. Abrechnungsworkflow
  7. Mahnwesen
  8. Autostart-Workflow
  9. Frontend-Verteilung
- **Details:**
  - Ausloeser (Button/Menu)
  - Schrittweise Ablauf mit VBA-Code
  - Beteiligte Tabellen/Abfragen
  - Daten-Aenderungen

### 6. button_chains.md
- **Inhalt:** Button-Funktionsketten
- **Dokumentiert:**
  - Hauptformular-Buttons (frm_va_Auftragstamm, frm_MA_Mitarbeiterstamm, etc.)
  - Menu-Buttons (frm_Menuefuehrung)
  - Navigations-Buttons (Standard)
  - Popup-Buttons
- **Details:**
  - Was passiert bei Klick (schrittweise)
  - VBA-Funktionen die aufgerufen werden
  - Abfragen die ausgefuehrt werden
  - Daten die geaendert werden
  - Workflow-Diagramme (ASCII)

---

## KERN-ERKENNTNISSE

### Hauptformulare
1. **frm_va_Auftragstamm** - Auftragsverwaltung (Zentrum der Anwendung)
2. **frm_MA_Mitarbeiterstamm** - Mitarbeiterverwaltung
3. **frm_KD_Kundenstamm** - Kundenverwaltung
4. **frm_OB_Objekt** - Objektverwaltung
5. **frm_Menuefuehrung** - Hauptmenu/Navigation

### Kern-VBA-Module
1. **mdlAutoexec** - Autostart, Backend-Verbindung
2. **zmd_Mail** - E-Mail-Anfragen an MA
3. **mdl_CONSEC_eMail_Autoimport** - E-Mail-Import/Verarbeitung
4. **mdl_Menu_Neu** - Menu-Navigation
5. **mdl_Rechnungsschreibung** - Rechnungserstellung

### Haupt-Tabellen-Beziehungen
```
tbl_KD_Kundenstamm
    |
    +-- tbl_VA_Auftragstamm
            |
            +-- tbl_VA_AnzTage (Tage)
            |       |
            |       +-- tbl_VA_Start (Schichten)
            |               |
            |               +-- tbl_MA_VA_Zuordnung
            |               +-- tbl_MA_VA_Planung
            |
            +-- tbl_Rch_Kopf (Rechnungen)

tbl_MA_Mitarbeiterstamm
    |
    +-- tbl_MA_VA_Zuordnung
    +-- tbl_MA_VA_Planung
    +-- tbl_MA_NVerfuegZeiten
```

### Kritische Workflows
1. **Anfrage-Workflow:** Button -> Anfragen() -> create_Mail() -> xSendMessage() -> setze_Angefragt() -> create_PHP()
2. **Import-Workflow:** Timer -> All_eMail_Update() -> qry_Email_finden_* -> qry_eMail_Update_* -> Merge()
3. **Rechnungs-Workflow:** Menu -> Update_Rch_Nr() -> Zahlbed_Text() -> Word-Template -> PDF -> Status=4

---

## VERWENDUNG DIESER DOKUMENTATION

### Fuer HTML-Formular-Entwicklung
1. **forms_inventory.md** - Welche Formulare existieren, welche Unterformulare eingebettet sind
2. **button_chains.md** - Welche Aktionen bei Button-Klicks ausgefuehrt werden muessen
3. **workflows.md** - Komplette Geschaeftsprozesse nachbilden

### Fuer API-Entwicklung
1. **tables_inventory.md** - Datenbankstruktur, Feldnamen, Beziehungen
2. **queries_inventory.md** - SQL-Logik, JOINs, Filter

### Fuer VBA-Migration
1. **vba_modules.md** - Welche Funktionen existieren, wo sie aufgerufen werden
2. **button_chains.md** - Welche VBA-Funktionen von Buttons aufgerufen werden

---

## QUELL-DATEIEN

### JSON-Exports (11_json_Export/)
- FRM_*.json - Formular-Definitionen
- FRM_*__subcontrols.json - Unterformular-Details
- QRY_*.json - Abfrage-SQL
- TAB_*.json - Tabellen-Struktur

### VBA-Module (01_VBA/)
- modules/*.bas - Standard-Module
- forms/*.bas - Formular-Module
- classes/*.cls - Klassen-Module

---

## EXPORT-DETAILS

| Datei | Groesse (ca.) | Zeilen |
|-------|---------------|--------|
| forms_inventory.md | ~25 KB | ~450 |
| vba_modules.md | ~18 KB | ~490 |
| queries_inventory.md | ~12 KB | ~360 |
| tables_inventory.md | ~16 KB | ~430 |
| workflows.md | ~15 KB | ~400 |
| button_chains.md | ~12 KB | ~340 |
| EXPORT_SUMMARY.md | ~6 KB | ~200 |

**Gesamte Dokumentation: ~104 KB in 7 Dateien**

---

## NAECHSTE SCHRITTE (EMPFOHLEN)

1. **HTML-Formulare erstellen** basierend auf forms_inventory.md
2. **REST-API implementieren** basierend auf tables_inventory.md und queries_inventory.md
3. **Button-Handler implementieren** basierend auf button_chains.md
4. **Workflows nachbilden** basierend auf workflows.md
5. **VBA-Logik portieren** basierend auf vba_modules.md

---

*Dokumentation erstellt durch Claude Code Agent*
*Datum: 2026-01-08*
