# Fehlende HTML-Formulare - Analyse 2026-01-15

## Zusammenfassung

**Status:** 181 von 212 relevanten Access-Formularen fehlen als HTML-Entsprechung

| Kategorie | Anzahl Access | Anzahl HTML | Fehlend |
|-----------|--------------|-------------|---------|
| Hauptformulare (frm_) | 73 | 26 | 47 |
| Top-Formulare (frmTop_) | 31 | 6 | 25 |
| Subformulare (sub_) | 78 | 25 | 53 |
| Admin-Formulare (zfrm_/zsub_) | 30 | 7 | 23 |
| **GESAMT** | **212** | **64** | **148** |

---

## Prioritätsliste

### Priorität 1: KRITISCH (1 Formular)

Hauptformulare ohne die das System nicht vollständig funktioniert:

| Formular | Typ | Kategorie | Grund | Aufwand |
|----------|-----|-----------|-------|---------|
| frm_VA_Auftragstamm | Haupt | Stammdaten | **BEREITS HTML VORHANDEN** (frm_va_Auftragstamm.html) | - |

> **HINWEIS:** frm_VA_Auftragstamm existiert bereits als `frm_va_Auftragstamm.html` (Kleinschreibung)

---

### Priorität 2: HOCH (5 Formulare)

Wichtige Haupt- und Dialog-Formulare für tägliche Arbeit:

| Formular | Typ | Kategorie | Benötigt von | Aufwand |
|----------|-----|-----------|--------------|---------|
| frmTop_DP_Auftrageingabe | Top | Planung | Dienstplan-Erstellung | **KOMPLEX** |
| frmTop_MA_Tagesuebersicht | Top | Personal | MA-Planung, Dienstplan | **MITTEL** |
| frmTop_Login | Top | System | Benutzer-Authentifizierung | **EINFACH** |
| frm_Zeiterfassung | Haupt | Zeitwirtschaft | Zeitbuchungen, Stundenkonto | **KOMPLEX** |
| frm_Rechnungen_bezahlt_offen | Haupt | Abrechnung | Rechnungsübersicht | **MITTEL** |

**Geschätzter Gesamtaufwand:** 2-3 Wochen

---

### Priorität 3: MITTEL (31 Formulare)

Wichtige Dialog- und Subformulare:

#### Abrechnung (3)
| Formular | Typ | Benötigt von | Aufwand |
|----------|-----|--------------|---------|
| frmTop_Rch_Berechnungsliste | Top | Rechnungserstellung | MITTEL |
| frmTop_RechnungsStamm | Top | Rechnungsverwaltung | MITTEL |
| sub_Rch_Kopf | Sub | frm_Rechnung | EINFACH |

#### Personal (8)
| Formular | Typ | Benötigt von | Aufwand |
|----------|-----|--------------|---------|
| frmTop_MA_Anstellungsart | Top | MA-Stammdaten | EINFACH |
| frmTop_MA_Dienstkleidung_Vorlage | Top | MA-Verwaltung | EINFACH |
| frmTop_MA_Einsatzart | Top | MA-Planung | EINFACH |
| frmTop_MA_Suche | Top | MA-Auswahl | MITTEL |
| frmTop_MA_ZuAbsage | Top | Planungs-Workflows | MITTEL |
| frmTop_eMail_MA_ID_NGef | Top | E-Mail-System | EINFACH |
| sub_MA_Dienstkleidung | Sub | frm_MA_Mitarbeiterstamm | EINFACH |
| sub_Ansprechpartner | Sub | Kunden/Objekte | EINFACH |

#### Planung (11)
| Formular | Typ | Benötigt von | Aufwand |
|----------|-----|--------------|---------|
| frmTop_DP_Auftrageingabe_ | Top | Variante von Auftrageingabe | KOMPLEX |
| frmTop_DP_Auftrageingabe_Siegert | Top | User-spezifische Variante | KOMPLEX |
| frmTop_VA_AnzTage_sub | Top | Auftragstage-Verwaltung | MITTEL |
| frmTop_VA_AnzTage_subsub | Top | Detail-Ansicht Tage | MITTEL |
| frmTop_VA_Auftrag_Neu | Top | Neuer Auftrag Dialog | KOMPLEX |
| frmTop_VA_Tag_sub | Top | Tages-Details | MITTEL |
| frmTop_VA_Veranstaltungsstatus | Top | Status-Verwaltung | EINFACH |
| frmTop_XL_Eport_Auftrag | Top | Excel-Export Auftrag | MITTEL |
| sub_VA_Start | Sub | Schicht-Details | MITTEL |
| sub_VA_Anzeige | Sub | Auftrags-Anzeige | EINFACH |
| sub_KD_Standardpreise | Sub | Kundenpreise | EINFACH |

#### Import/Export (3)
| Formular | Typ | Benötigt von | Aufwand |
|----------|-----|--------------|---------|
| frmTop_Excel_Monatsuebersicht | Top | Monatsberichte | MITTEL |
| frmTop_XL_Import_Check | Top | Excel-Import Prüfung | MITTEL |
| frmTop_XL_Import_Start | Top | Excel-Import Start | MITTEL |

#### Sonstiges (6)
| Formular | Typ | Benötigt von | Aufwand |
|----------|-----|--------------|---------|
| frmTop_Adressart | Top | Adressverwaltung | EINFACH |
| frmTop_BereitsVerplant | Top | Planungsprüfung | MITTEL |
| frmTop_KD_Preisarten | Top | Preiskategorien | EINFACH |
| frmTop_Linkliste | Top | System-Links | EINFACH |
| frmTop_Neue_Vorlagen | Top | Vorlagenverwaltung | MITTEL |
| frmTop_Textbaustein_Brief | Top | Textbausteine | MITTEL |

**Geschätzter Gesamtaufwand:** 4-5 Wochen

---

### Priorität 4: NIEDRIG (106 Formulare)

Spezial-, Hilfs- und wenig genutzte Formulare.

**Kategorien:**
- **Personal (25):** Diverse MA-Subformulare, Tageszusatzwerte, Team-Zuordnungen
- **Planung (32):** VA-Detail-Subforms, Wochen/Monats-Ansichten, Statistiken
- **Abrechnung (28):** Rechnungspositionen, Mahnungen, Berechnungen
- **Zeitwirtschaft (12):** ZK-Details, Lohnarten, Stunden-Subforms
- **Import/Export (5):** Excel-Import Details
- **System/Admin (4):** Hilfs- und Test-Formulare

**Geschätzter Gesamtaufwand:** 6-8 Wochen (bei Bedarf)

---

### Priorität 5: NICHT BENÖTIGT (38 Formulare)

Alte Versionen, Backup-Formulare, user-spezifische Varianten.

**Beispiele:**
- `frm_KD_Kundenstamm_alt` (Alte Version - HTML vorhanden)
- `frm_MA_VA_Schnellauswahl_20251206` (Datums-Backup - HTML vorhanden)
- `frm_MA_Abwesenheiten_Krank_Gueni_2022/2023` (User-spezifisch, alt)
- `frm_Letzter_Einsatz_MA_Gueni` (User-spezifisch)
- `zfrm_MA_Stunden_Lexware_20250808` (Datums-Backup)

**Empfehlung:** NICHT implementieren - veraltet oder redundant

---

## Implementierungs-Roadmap

### Phase 1: Basis-Funktionalität (2-3 Wochen)
**Ziel:** Tägliche Arbeit voll HTML-fähig

1. **frmTop_Login** (3 Tage)
   - Benutzer-Authentifizierung
   - Session-Management
   - Rechteverwaltung

2. **frmTop_MA_Tagesuebersicht** (5 Tage)
   - MA-Verfügbarkeit pro Tag
   - Einsatz-Übersicht
   - Integration mit Dienstplan

3. **frm_Rechnungen_bezahlt_offen** (4 Tage)
   - Rechnungsübersicht
   - Filter: bezahlt/offen
   - Summen-Kalkulation

4. **frmTop_DP_Auftrageingabe** (10 Tage)
   - Auftrag anlegen/bearbeiten
   - Schichten definieren
   - MA-Zuordnung

### Phase 2: Erweiterte Funktionen (4-5 Wochen)
**Ziel:** Wichtige Dialog-Formulare

1. **Abrechnung** (1 Woche)
   - frmTop_Rch_Berechnungsliste
   - frmTop_RechnungsStamm
   - sub_Rch_Kopf

2. **Personal-Verwaltung** (2 Wochen)
   - MA-Stammdaten-Dialoge (Anstellungsart, Einsatzart, etc.)
   - MA-Suche erweitern
   - Subformulare (Dienstkleidung, Ansprechpartner)

3. **Planungs-Dialoge** (2 Wochen)
   - VA_Auftrag_Neu
   - VA_AnzTage Verwaltung
   - Status-Dialoge

### Phase 3: Spezialisierte Module (6-8 Wochen)
**Ziel:** Vollständigkeit

1. **Zeiterfassung** (2 Wochen)
   - frm_Zeiterfassung
   - Integration Zeitkonten
   - Stunden-Export

2. **Import/Export** (2 Wochen)
   - Excel-Import Module
   - Excel-Export Module
   - Datenvalidierung

3. **Restliche Subformulare** (4 Wochen)
   - Nach Bedarf implementieren
   - Basierend auf User-Feedback

---

## Technische Anforderungen

### Datenbank-Struktur

**Wichtigste Tabellen für fehlende Formulare:**

| Formular | Haupttabelle | Zusätzliche Tabellen |
|----------|--------------|---------------------|
| frmTop_Login | tbl_MA_Mitarbeiterstamm | tbl_User_Rechte |
| frmTop_MA_Tagesuebersicht | tbl_MA_VA_Planung | tbl_MA_NVerfuegZeiten, tbl_VA_Start |
| frm_Zeiterfassung | tbl_MA_Zeitkonten | tbl_MA_Zeitkonto_Buchungen |
| frm_Rechnungen_bezahlt_offen | tbl_Rch_Kopf | tbl_Rch_Pos, tbl_KD_Kundenstamm |

### API-Endpoints (neu erforderlich)

**Planung:**
- `POST /api/auftraege/neu` - Neuer Auftrag anlegen
- `GET/POST /api/dienstplan/eingabe` - Dienstplan-Eingabe
- `GET /api/mitarbeiter/tagesuebersicht/:datum` - Tagesübersicht

**Abrechnung:**
- `GET /api/rechnungen/offen` - Offene Rechnungen
- `GET /api/rechnungen/bezahlt` - Bezahlte Rechnungen
- `POST /api/rechnungen/berechnungsliste` - Berechnungsliste erstellen

**Zeitwirtschaft:**
- `POST /api/zeiterfassung/buchung` - Zeitbuchung anlegen
- `GET /api/zeitkonten/:ma_id` - Zeitkonto abrufen
- `PUT /api/zeitkonten/:ma_id/korrektur` - Zeitkonto korrigieren

**Authentifizierung:**
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `GET /api/auth/session` - Session prüfen

---

## Aufwands-Schätzung (Gesamt)

| Phase | Formulare | Aufwand | Priorität |
|-------|-----------|---------|-----------|
| **Phase 1: Basis** | 5 | 2-3 Wochen | HOCH |
| **Phase 2: Erweitert** | 31 | 4-5 Wochen | MITTEL |
| **Phase 3: Spezialisiert** | 106 | 6-8 Wochen | NIEDRIG |
| **GESAMT** | **142** | **12-16 Wochen** | - |

**Hinweis:** Aufwand pro Formular variiert stark:
- **EINFACH:** 1-2 Tage (Dialog-Formulare, einfache Subforms)
- **MITTEL:** 3-5 Tage (Stammdaten, Listen mit Filter)
- **KOMPLEX:** 7-14 Tage (Planungs-Formulare, Zeiterfassung, Abrechnung)

---

## Empfehlung

### Sofort starten (Phase 1):
1. **frmTop_Login** - Authentifizierung fehlt komplett
2. **frmTop_MA_Tagesuebersicht** - Wichtig für tägliche Planung
3. **frm_Rechnungen_bezahlt_offen** - Finanz-Übersicht kritisch

### Mittelfristig (Phase 2):
- Personal-Dialoge nach Bedarf
- Abrechnung-Module erweitern
- Planungs-Workflows vervollständigen

### Langfristig (Phase 3):
- Zeiterfassung (wenn benötigt)
- Import/Export (bei Bedarf)
- Restliche Subformulare on-demand

---

## Bereits vorhandene HTML-Formulare (64)

**Haupt-Stammdaten:**
- frm_MA_Mitarbeiterstamm
- frm_KD_Kundenstamm
- frm_OB_Objekt
- frm_va_Auftragstamm ✓
- frm_N_Bewerber

**Planung:**
- frm_DP_Dienstplan_MA
- frm_DP_Dienstplan_Objekt
- frm_MA_VA_Schnellauswahl
- frm_Einsatzuebersicht
- frm_abwesenheitsuebersicht

**Personal:**
- frm_MA_Abwesenheit
- frm_MA_Zeitkonten
- frm_MA_Offene_Anfragen
- frm_MA_Tabelle
- frm_DP_Einzeldienstplaene

**Abrechnung:**
- frm_Rechnung
- frm_Angebot
- frm_Kundenpreise_gueni
- frm_Rueckmeldestatistik
- frm_KD_Umsatzauswertung

**System:**
- frm_Menuefuehrung1 (Dashboard)
- frm_Systeminfo
- shell.html (Container)

**Subformulare (25):**
- sub_MA_VA_Zuordnung
- sub_VA_Schichten
- sub_VA_Einsatztage
- sub_DP_Grund / sub_DP_Grund_MA
- sub_MA_Offene_Anfragen
- sub_MA_VA_Planung_Status / _Absage
- sub_OB_Objekt_Positionen
- sub_rch_Pos
- sub_ZusatzDateien
- uvm.

---

**Erstellt:** 2026-01-15
**Status:** Analyse abgeschlossen
**Nächster Schritt:** Phase 1 Implementierung starten
