# CHECKLISTE FORMULAR-RELEASE

**Stand:** 2026-01-06
**Version:** 1.0
**Pfad:** `04_HTML_Forms/forms3/`

---

## LEGENDE

| Symbol | Bedeutung |
|--------|-----------|
| OK | Geprueft und funktional |
| TEILW | Teilweise implementiert |
| FEHLT | Nicht implementiert |
| N/A | Nicht anwendbar |
| SKIP | Bewusst ausgelassen |

---

## 1. STAMMDATEN-FORMULARE

### frm_MA_Mitarbeiterstamm.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | | |
| HTML-Datei vorhanden | OK | |
| Logic.js vorhanden | OK | Inline + logic/ |
| CSS eingebunden | OK | main.css |
| Sidebar integriert | OK | |
| **FELDER** | | |
| Personalien-Tab | OK | 19 Felder |
| Bankdaten-Tab | TEILW | Bankname fehlt |
| Beschaeftigung-Tab | TEILW | Kostenstelle fehlt |
| **FUNKTIONEN** | | |
| Datensatz-Liste | OK | lst_MA |
| Navigation (Erste/Vorige/Naechste/Letzte) | OK | |
| Neuer Datensatz | OK | |
| Speichern | OK | |
| Loeschen | OK | |
| Suche | OK | |
| Filter (Aktiv/Alle/Inaktiv) | OK | |
| **TABS** | | |
| Stammdaten | OK | |
| Zeitkonto | TEILW | Monatsauswahl fehlt |
| Jahresuebersicht | OK | |
| Einsatzuebersicht | OK | |
| Stundenuebersicht | OK | |
| Dienstplan | OK | |
| Nichtverfuegbar | OK | |
| Dienstkleidung | OK | |
| Vordrucke | OK | |
| Briefkopf | OK | |
| Ueberhangstunden | OK | |
| Karte | OK | Google Maps Link |
| Subrechnungen | OK | |
| **SPEZIALFUNKTIONEN** | | |
| Foto-Anzeige | OK | |
| Foto-Upload | FEHLT | btnDateisuch fehlt |
| Signatur-Upload | FEHLT | btnDateisuch2 fehlt |
| Excel-Export Zeitkonto | FEHLT | |
| Excel-Export Jahr | FEHLT | |
| Dienstplan drucken | FEHLT | |
| Dienstplan senden | FEHLT | |
| **API-ANBINDUNG** | | |
| GET /mitarbeiter | OK | |
| GET /mitarbeiter/:id | OK | |
| POST /mitarbeiter | OK | |
| PUT /mitarbeiter/:id | OK | |
| DELETE /mitarbeiter/:id | OK | |
| **RELEASE-STATUS** | TEILW | 60% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_KD_Kundenstamm.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | | |
| HTML-Datei vorhanden | OK | |
| Logic.js vorhanden | OK | logic/ |
| CSS eingebunden | OK | |
| Sidebar integriert | OK | |
| **FELDER** | | |
| Stammdaten | OK | 28 Felder |
| Bankdaten | OK | 7 Felder |
| Kontaktdaten | OK | |
| **FUNKTIONEN** | | |
| Datensatz-Liste | OK | kundenTable |
| Navigation | OK | |
| Neuer Datensatz | OK | |
| Speichern | OK | |
| Loeschen | OK | |
| Suche | OK | Textschnell |
| Filter PLZ | OK | |
| Filter Ort | OK | |
| Filter Aktiv | OK | |
| **TABS** | | |
| Stammdaten | OK | |
| Auftraege | OK | |
| Ansprechpartner | OK | |
| Zusatzdateien | OK | |
| Bemerkungen | OK | |
| Objekte | OK | Zusaetzlich |
| Konditionen | OK | Zusaetzlich |
| Kundenpreise | FEHLT | Tab vorhanden, Subform fehlt |
| **SPEZIALFUNKTIONEN** | | |
| Standardpreise anlegen | FEHLT | |
| Hauptansprechpartner | FEHLT | kun_IDF_PersonID |
| Statistik-Felder | TEILW | 4 von 32 |
| Outlook oeffnen | OK | |
| Word oeffnen | OK | |
| Umsatzauswertung | OK | |
| Verrechnungssaetze | OK | |
| **API-ANBINDUNG** | | |
| GET /kunden | OK | |
| GET /kunden/:id | OK | |
| POST /kunden | OK | |
| PUT /kunden/:id | OK | |
| DELETE /kunden/:id | OK | |
| **RELEASE-STATUS** | TEILW | 75% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_va_Auftragstamm.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | | |
| HTML-Datei vorhanden | OK | |
| Logic.js vorhanden | OK | logic/ |
| CSS eingebunden | OK | |
| Sidebar integriert | OK | |
| **FELDER** | | |
| Auftragskopf | TEILW | 15 von 19 |
| Veranstalter-Auswahl | OK | |
| Objekt-Auswahl | OK | |
| Datumsfelder | OK | |
| **FUNKTIONEN** | | |
| Datensatz-Liste | OK | auftraegeTable |
| Navigation | FEHLT | Button-IDs stimmen nicht |
| Neuer Auftrag | TEILW | ID-Abweichung |
| Speichern | OK | |
| Loeschen | TEILW | mcobtnDelete vs btnLoeschen |
| Suche | OK | |
| Filter ab Datum | FEHLT | Buttons fehlen im HTML |
| Auftrag kopieren | OK | |
| **TABS** | | |
| Einsatzliste | OK | |
| Schichten | OK | |
| Zuordnungen | OK | |
| Absagen | TEILW | Daten laden nicht |
| Status | OK | |
| Attachments | OK | |
| Rechnungspositionen | OK | |
| **SPEZIALFUNKTIONEN** | | |
| Auftrag berechnen | FEHLT | btnAuftrBerech |
| Einsatzliste mailen | OK | |
| Schnellplanung | OK | |
| Vorbelegungslogik | FEHLT | GotFocus-Events |
| Status-Regeln | TEILW | In Logic.js |
| **API-ANBINDUNG** | | |
| GET /auftraege | OK | |
| GET /auftraege/:id | OK | |
| POST /auftraege | OK | |
| PUT /auftraege/:id | OK | |
| DELETE /auftraege/:id | OK | |
| **RELEASE-STATUS** | UNVOLLST | 60% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_OB_Objekt.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | | |
| HTML-Datei vorhanden | OK | |
| Logic.js vorhanden | OK | Inline |
| CSS eingebunden | OK | |
| Sidebar integriert | OK | |
| **FELDER** | | |
| Objektdaten | OK | 10 Felder |
| Audit-Felder | OK | |
| **FUNKTIONEN** | | |
| Datensatz-Liste | OK | objekteBody |
| Navigation | OK | |
| Neuer Datensatz | OK | |
| Speichern | OK | |
| Loeschen | OK | |
| Suche | OK | |
| **TABS** | | |
| Positionen | OK | |
| Zusatzdateien | OK | |
| Bemerkungen | OK | Zusaetzlich |
| Auftraege | OK | Zusaetzlich |
| **SPEZIALFUNKTIONEN** | | |
| Positionen sortieren | OK | moveUp/Down |
| Positionen importieren | OK | |
| Positionen exportieren | OK | Excel |
| Positionen kopieren | OK | |
| Vorlage speichern/laden | OK | |
| Geocodierung | OK | OpenStreetMap |
| Zeit-Labels bearbeiten | FEHLT | btnZeitLabels |
| **API-ANBINDUNG** | | |
| GET /objekte | OK | |
| GET /objekte/:id | OK | |
| POST /objekte | OK | |
| PUT /objekte/:id | OK | |
| DELETE /objekte/:id | OK | |
| **RELEASE-STATUS** | OK | 90% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb (mit Einschraenkung Zeit-Labels)

---

## 2. PLANUNGS-FORMULARE

### frm_N_Dienstplanuebersicht.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | | |
| 7-Tage Grid | OK | |
| Navigation (Vor/Zurueck/Heute) | OK | |
| Filter-Optionen | OK | |
| Datenladung bei Datumswechsel | OK | |
| Excel-Export | OK | |
| Feiertage-Anzeige | OK | 2025 integriert |
| **API-ANBINDUNG** | OK | |
| **RELEASE-STATUS** | OK | 95% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb

---

### frm_VA_Planungsuebersicht.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | | |
| 7-Tage Grid | OK | |
| Navigation | OK | |
| Filter | OK | |
| Export | OK | |
| **RELEASE-STATUS** | OK | 95% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb

---

### frm_DP_Dienstplan_MA.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | | |
| Kalender-Grid | OK | |
| Navigation | OK | |
| Excel-Export | OK | |
| Dienstplan senden | OK | |
| Filter NurAktiveMA | TEILW | UI vorhanden |
| Druckfunktion | FEHLT | |
| **RELEASE-STATUS** | TEILW | 80% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_DP_Dienstplan_Objekt.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | OK | Vollstaendig |
| **RELEASE-STATUS** | OK | 95% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb

---

### frm_MA_VA_Schnellauswahl.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | | |
| MA-Auswahl | OK | |
| Filter | OK | |
| Zuordnung | OK | |
| **RELEASE-STATUS** | OK | 85% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb

---

### frm_Einsatzuebersicht.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | | |
| HTML-Datei vorhanden | OK | Nur Platzhalter |
| Logic.js vorhanden | FEHLT | |
| **FUNKTIONEN** | | |
| Einsatzliste | FEHLT | |
| Filter | FEHLT | |
| Export | FEHLT | |
| **RELEASE-STATUS** | FEHLT | 5% |

**Sign-off:** [ ] NICHT freigegeben - Implementierung erforderlich

---

## 3. PERSONAL-FORMULARE

### frm_MA_Abwesenheit.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | TEILW | Mehrfachtermine fehlt |
| **RELEASE-STATUS** | TEILW | 70% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_MA_Zeitkonten.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | TEILW | Monatsauswahl fehlt |
| **RELEASE-STATUS** | TEILW | 65% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_N_Lohnabrechnungen.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | TEILW | |
| **RELEASE-STATUS** | TEILW | 70% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_N_Stundenauswertung.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | TEILW | |
| **RELEASE-STATUS** | TEILW | 70% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

### frm_N_Bewerber.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | TEILW | |
| **RELEASE-STATUS** | TEILW | 60% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

## 4. NAVIGATION & SHELL

### shell.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | | |
| Iframe-Navigation | OK | |
| Sidebar-Integration | OK | |
| Alle Ziel-Formulare erreichbar | OK | 13 geprueft |
| Umlaut-Behandlung | OK | |
| **RELEASE-STATUS** | OK | 100% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb

---

### frm_Menuefuehrung1.html (Dashboard)

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | OK | |
| **RELEASE-STATUS** | OK | 100% |

**Sign-off:** [x] Freigabe fuer Produktivbetrieb

---

## 5. SONSTIGE FORMULARE

### frm_Ausweis_Create.html

| Kriterium | Status | Anmerkung |
|-----------|--------|-----------|
| **STRUKTUR** | OK | |
| **FUNKTIONEN** | TEILW | |
| **RELEASE-STATUS** | TEILW | 80% |

**Sign-off:** [ ] Freigabe fuer Produktivbetrieb

---

## ZUSAMMENFASSUNG

### Release-Uebersicht

| Status | Anzahl | Formulare |
|--------|--------|-----------|
| FREIGEGEBEN | 8 | shell, frm_Menuefuehrung1, frm_OB_Objekt, frm_N_Dienstplanuebersicht, frm_VA_Planungsuebersicht, frm_DP_Dienstplan_Objekt, frm_MA_VA_Schnellauswahl |
| BEDINGT FREIGEGEBEN | 9 | Stammdaten + Personal-Formulare |
| NICHT FREIGEGEBEN | 3 | frm_Einsatzuebersicht, weitere Platzhalter |

### Naechste Schritte fuer vollstaendige Freigabe

1. [ ] frm_Einsatzuebersicht implementieren
2. [ ] frm_va_Auftragstamm Button-IDs korrigieren
3. [ ] frm_KD_Kundenstamm Kundenpreise hinzufuegen
4. [ ] frm_MA_Mitarbeiterstamm Foto-Upload implementieren
5. [ ] Validierung mit form_validator.js durchfuehren

---

**Naechste Review:** Nach Behebung der kritischen Punkte

**Verantwortlich:** [Name eintragen]

**Datum der naechsten Pruefung:** [Datum eintragen]
