# Schluesselformulare des CONSEC Planungssystems

## Uebersicht

Das CONSEC Access-Frontend ist ein umfassendes Planungssystem fuer Sicherheits- und Eventservices. Die Hauptformulare decken folgende Bereiche ab:
- Auftragsverwaltung
- Mitarbeiterverwaltung
- Kundenverwaltung
- Personalplanung
- Dienstplan-Uebersicht

---

## 1. frm_VA_Auftragstamm (Auftragsverwaltung)

### Zweck
Zentrale Verwaltung aller Auftraege/Veranstaltungen. Hier werden Einsaetze geplant, Mitarbeiter zugeordnet und Rechnungen erstellt.

### Hauptfunktionen
| Funktion | Beschreibung |
|----------|--------------|
| Auftrag anlegen | Neuer Auftrag mit Datum, Ort, Objekt, Auftraggeber |
| Auftrag kopieren | Duplikat eines Auftrags erstellen (Schichten werden mitkopiert) |
| MA zuordnen | Mitarbeiter einem Auftrag/Schicht zuweisen |
| Einsatzliste senden | E-Mail an Mitarbeiter mit Einsatzdetails |
| Rechnung erstellen | Rechnungspositionen verwalten, PDF generieren |

### Tab-Bereiche
1. **Einsatzliste** - Zugeordnete Mitarbeiter, Schichten, Absagen
2. **Antworten ausstehend** - MA mit offenem Planungsstatus
3. **Zusatzdateien** - Anhaenge zum Auftrag
4. **Rechnung** - Rechnungspositionen und Berechnungsliste
5. **Bemerkungen** - Freitext-Notizen

### Wichtige Subformulare
- `sub_MA_VA_Zuordnung` - Liste zugeordneter Mitarbeiter
- `sub_VA_Start` - Schichten/Zeiten des Auftrags
- `sub_MA_VA_Planung_Absage` - Absagen
- `zsub_lstAuftrag` - Auftragsliste rechts

### Besonderheiten
- **Mehrtages-Auftraege**: cboVADatum Dropdown zur Tages-Navigation
- **Template-Erkennung**: Bei Eingabe bekannter Auftragsnamen (1.FCN, Greuther, Kaufland) werden Felder automatisch vorbefuellt
- **Status-Verwaltung**: 1=Planung, 2=Bestaetigt, 3=Abgeschlossen, 4=Abgerechnet, 5=Storniert
- **Autosend**: Automatischer E-Mail-Versand bei Status-Aenderung (nur BOS-Auftraege)

### RecordSource
`qry_Auftrag_Sort` (basiert auf `tbl_VA_Auftragstamm`)

---

## 2. frm_MA_Mitarbeiterstamm (Mitarbeiterverwaltung)

### Zweck
Verwaltung aller Mitarbeiterdaten - persoenliche Daten, Qualifikationen, Bankdaten, Arbeitszeiten.

### Hauptfunktionen
| Funktion | Beschreibung |
|----------|--------------|
| MA anlegen/bearbeiten | Persoenliche Daten, Adresse, Kontakt |
| Qualifikationen | 34a-Nachweis, Sachkunde, Fahrerlaubnis |
| Bankdaten | IBAN, BIC, Kontoinhaber |
| Verfuegbarkeit | Abwesenheiten, Urlaubszeiten |
| Dienstkleidung | Kleidungsgroessen, Ausgabe |

### Wichtige Felder
| Feld | Beschreibung |
|------|--------------|
| ID | Eindeutige Mitarbeiter-Nr (Primary Key) |
| IstAktiv | Boolean - Mitarbeiter aktiv? |
| IstSubunternehmer | Boolean - Subunternehmer? |
| Nachname, Vorname | Name |
| Email | E-Mail-Adresse |
| Tel_Mobil | Mobilnummer |
| Anstellungsart_ID | FK zu Anstellungsarten |
| Hat_keine_34a | Boolean - Hat 34a Nachweis |
| HatSachkunde | Boolean |

### Subformulare
- Abwesenheiten (Urlaub, Krank)
- Einsatz-Zuordnungen
- Dienstkleidung
- Team-Zuordnungen
- Ersatz-Email-Adressen

### RecordSource
`tbl_MA_Mitarbeiterstamm`

---

## 3. frm_KD_Kundenstamm (Kundenverwaltung)

### Zweck
Verwaltung aller Kunden (Auftraggeber/Veranstalter) mit Adressen, Ansprechpartnern und Preisen.

### Hauptfunktionen
| Funktion | Beschreibung |
|----------|--------------|
| Kunde anlegen | Firma, Adresse, Kontaktdaten |
| Ansprechpartner | Mehrere Ansprechpartner pro Kunde |
| Standardpreise | Kundenspezifische Stundenpreise |
| Artikelbeschreibungen | Leistungsbeschreibungen |
| Auftragshistorie | Vergangene Auftraege des Kunden |

### Wichtige Felder
| Feld | Beschreibung |
|------|--------------|
| kun_Id | Eindeutige Kunden-Nr (Primary Key) |
| kun_Firma | Firmenname |
| kun_IstAktiv | Boolean - Kunde aktiv? |
| kun_AdressArt | 1=Auftraggeber, andere=Rechnungsadresse etc. |
| kun_Strasse, kun_PLZ, kun_Ort | Adresse |
| kun_Tel1, kun_Email | Kontakt |

### Subformulare
- `sub_Ansprechpartner` - Ansprechpartner des Kunden
- `sub_KD_Standardpreise` - Preislisten
- `sub_KD_Artikelbeschreibung` - Leistungstexte
- `sub_KD_Auftragskopf` - Auftragshistorie

### RecordSource
`tbl_KD_Kundenstamm`

---

## 4. frm_MA_VA_Schnellauswahl (Personalplanung)

### Zweck
Schnelle Mitarbeiter-Zuordnung zu Auftraegen. Zeigt verfuegbare Mitarbeiter und ermoeglicht Drag&Drop-artige Zuweisung.

### Hauptfunktionen
| Funktion | Beschreibung |
|----------|--------------|
| Auftrag waehlen | Dropdown mit aktiven Auftraegen |
| MA filtern | Nach Verfuegbarkeit, Anstellungsart, Qualifikation |
| MA zuordnen | Ausgewaehlte MA dem Auftrag hinzufuegen |
| MA entfernen | Zuordnung aufheben |
| E-Mail senden | Anfrage an ausgewaehlte MA |

### Listenfelder
| Liste | Inhalt |
|-------|--------|
| lstZeiten | Schichten des Auftrags mit Soll/Ist |
| List_MA | Verfuegbare Mitarbeiter |
| lstMA_Plan | Bereits zugeordnete MA (Status: geplant) |
| lstMA_Zusage | MA mit Zusage |
| Lst_Parallel_Einsatz | Andere Auftraege am selben Tag |

### Filter-Optionen
- `IstVerfuegbar` - Nur freie MA zeigen
- `IstAktiv` - Nur aktive MA
- `cbVerplantVerfuegbar` - Auch bereits verplante zeigen
- `cboAnstArt` - Nach Anstellungsart filtern
- `cboQuali` - Nach Qualifikation filtern
- `cbNur34a` - Nur mit 34a-Nachweis

### Besonderheiten
- Zeigt parallel laufende Einsaetze am selben Datum
- Sortierung nach Entfernung zum Objekt moeglich
- Buttons fuer Add/Remove Selected

### Queries
- `qry_Mitarbeiter_Geplant` - Geplante MA
- `qry_Mitarbeiter_Zusage` - MA mit Zusage
- `ztbl_MA_Schnellauswahl` - Verfuegbare MA-Liste

---

## 5. frm_N_Dienstplanuebersicht / frm_DP_Dienstplan_Objekt

### Zweck
Wochenuebersicht aller Einsaetze - gruppiert nach Objekt oder Mitarbeiter.

### Hauptfunktionen
| Funktion | Beschreibung |
|----------|--------------|
| Woche waehlen | Start-Datum fuer 7-Tage-Ansicht |
| Objekt-Ansicht | Alle Schichten pro Objekt |
| MA-Ansicht | Alle Einsaetze pro Mitarbeiter |
| Luecken erkennen | Nicht besetzte Positionen |

### Aufbau
- **Kopfzeile**: 7 Tage (Mo-So) mit Datum
- **Zeilen**: Objekt + Position
- **Zellen**: MA-Name, von-bis Zeit, fraglich-Flag

### Varianten
- `frm_DP_Dienstplan_Objekt` - Objekt-zentrierte Ansicht
- `frm_DP_Dienstplan_MA` - Mitarbeiter-zentrierte Ansicht

### Subformulare
- `sub_DP_Grund` - Objekt-basierte Kreuztabelle
- `sub_DP_Grund_MA` - MA-basierte Kreuztabelle

### Temp-Tabellen
Die Dienstplan-Anzeige nutzt temporaere Tabellen:
- `tbltmp_DP_Grund` - Objekt-Positionen
- `tbltmp_DP_Grund_2` - Mit MA-Daten gefuellt
- `tbltmp_DP_Grund_Sort` - Sortierung

### Query-Kette
1. `qry_DP_Alle_Obj` - Basis-Daten
2. `qry_DP_Alle_Zt` - Zeitraum-Filter
3. `qry_DP_Kreuztabelle` - Pivot nach Datum

---

## 6. frm_Menuefuehrung1 (Hauptmenue/Dashboard)

### Zweck
Startseite und Navigation zu allen Bereichen des Systems.

### Aufbau
- **Linke Sidebar**: Navigation (wird als Subform in andere Formulare eingebettet)
- **Hauptbereich**: Schnellzugriff auf haeufige Funktionen

### Navigationspunkte
| Bereich | Ziel-Formular |
|---------|---------------|
| Mitarbeiter | frm_MA_Mitarbeiterstamm |
| Kunden | frm_KD_Kundenstamm |
| Auftraege | frm_VA_Auftragstamm |
| Dienstplan | frm_N_Dienstplanuebersicht |
| Schnellauswahl | frm_MA_VA_Schnellauswahl |
| Abwesenheiten | frm_abwesenheitsuebersicht |
| Bewerber | frm_N_MA_Bewerber_Verarbeitung |
| Rechnungen | zfrm_Lohnabrechnungen |

### Sidebar-Subform
`frm_Menuefuehrung` wird in fast alle Hauptformulare als Subform links eingebettet. So ist die Navigation von ueberall erreichbar.

---

## Gemeinsame Elemente aller Formulare

### Standard-Header
- Formular-Titel (Label)
- Aktuelles Datum
- Versions-Label (z.B. "GPT | TEST")
- Schliessen-Button

### Navigation-Buttons
- Erster/Letzter Datensatz
- Vor/Zurueck
- Rueckgaengig
- Aktualisieren

### Ribbon-Steuerung
- `btnRibbonAus` / `btnRibbonEin` - Access-Ribbon ein/aus
- `btnDaBaAus` / `btnDaBaEin` - Datenbankbereich ein/aus

### Audit-Felder
- Erst_von, Erst_am - Erstellt von/am
- Aend_von, Aend_am - Geaendert von/am

---

## Formular-Hierarchie

```
frm_Menuefuehrung1 (Dashboard)
|
+-- frm_MA_Mitarbeiterstamm
|   +-- sub_MA_Abwesenheiten
|   +-- sub_MA_Einsatz_Zuo
|   +-- sub_MA_Dienstkleidung
|
+-- frm_KD_Kundenstamm
|   +-- sub_Ansprechpartner
|   +-- sub_KD_Standardpreise
|
+-- frm_VA_Auftragstamm
|   +-- sub_MA_VA_Zuordnung
|   +-- sub_VA_Start
|   +-- sub_MA_VA_Planung_Absage
|   +-- zsub_lstAuftrag
|   +-- sub_rch_Pos
|
+-- frm_MA_VA_Schnellauswahl
|   +-- lstZeiten, List_MA, lstMA_Plan, lstMA_Zusage
|
+-- frm_DP_Dienstplan_Objekt
    +-- sub_DP_Grund
```

---

*Dokumentation erstellt: 2026-01-08*
*Basierend auf: JSON-Exports, VBA-Module, MAPPING-Dokumente*
