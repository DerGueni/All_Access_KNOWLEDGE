# Moderne Features-Katalog: Dienstplanung & Workforce Management

**Erstellt:** 2026-01-08
**Zweck:** Katalogisierung moderner Features nach Kategorien fuer Sicherheitsdienste und Eventservice

---

## 1. DIENSTPLANUNG

### 1.1 Drag & Drop Planung

**Beschreibung:** Intuitive visuelle Schichtplanung durch Ziehen und Ablegen von Mitarbeitern auf Zeitslots.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| Papershift | Vollstaendig, mit Vorlagen | Sehr gut |
| Aplano | Standard Drag&Drop | Gut |
| Shiftbase | Mit Vorlagen, keine Wochenansicht | Befriedigend |
| DISPONIC | Integriert | Gut |
| Quinyx | KI-unterstuetzt | Sehr gut |

**Technische Umsetzung:**
- HTML5 Drag and Drop API
- Touch-optimiert fuer Tablets
- Echtzeit-Synchronisation
- Visuelle Konflikterkennung

**Best Practice Beispiel:**
```
Papershift: Schichten als Karten, die auf Mitarbeiter-Zeilen
gezogen werden. Automatische Validierung bei Drop.
```

---

### 1.2 Automatische Zuordnung nach Skills/Qualifikationen

**Beschreibung:** System schlaegt passende Mitarbeiter basierend auf erforderlichen Qualifikationen vor.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| TimeCount | Intelligente Filter nach Qualifikationen | Sehr gut |
| DISPONIC | Qualifikationsbasierte Zuordnung | Sehr gut |
| Quinyx | KI-gestuetzte Optimierung | Exzellent |
| SecPlanNet | Bewacherregister-Integration | Gut |
| Papershift | Automatische Schichtplanung | Sehr gut |

**Relevante Qualifikationen (Sicherheitsbranche):**
- 34a-Schein (Sachkundepruefung)
- Waffenschein
- Erste-Hilfe-Zertifikat
- Brandschutz
- Fuehrerscheinklasse
- Sprachkenntnisse
- Objektspezifische Einweisungen

**Technische Umsetzung:**
- Skill-Matrix im Mitarbeiterprofil
- Anforderungsprofil pro Schicht/Objekt
- Matching-Algorithmus mit Gewichtung
- Ablaufdatum fuer Zertifikate mit Warnung

---

### 1.3 Verfuegbarkeitsabfrage per App

**Beschreibung:** Mitarbeiter melden ihre Verfuegbarkeit selbststaendig ueber die Mobile App.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| TimeCount | App + SMS/E-Mail | Sehr gut |
| Papershift | Vollstaendiges Self-Service | Sehr gut |
| ORTEC | Dediziertes ESS-Modul | Sehr gut |
| Swisio | Employee Self Service | Gut |
| Aplano | Einfache Verfuegbarkeiten | Gut |

**Feature-Details:**
- Kalenderansicht fuer Verfuegbarkeit
- Zeitbereiche definieren (verfuegbar/nicht verfuegbar)
- Praeferenzen angeben (bevorzugte Schichten)
- Maximale Wochenstunden festlegen
- Push-Benachrichtigung bei neuen Anfragen

**Best Practice:**
```
Planer sendet Verfuegbarkeitsabfrage fuer naechste Woche
-> Mitarbeiter erhalten Push-Notification
-> Mitarbeiter tragen Verfuegbarkeit ein
-> System erstellt optimalen Plan basierend auf Rueckmeldungen
```

---

### 1.4 Schichttausch-Funktion

**Beschreibung:** Mitarbeiter koennen Schichten untereinander tauschen mit Genehmigungsworkflow.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| Shiftbase | Self-Service Schichttausch | Sehr gut |
| Swisio | Mit Qualifikationspruefung | Sehr gut |
| Papershift | In App integriert | Gut |
| ORTEC | ESS-Modul | Gut |

**Workflow:**
1. Mitarbeiter A bietet Schicht zum Tausch an
2. System zeigt geeignete Kandidaten (gleiche Qualifikation)
3. Mitarbeiter B akzeptiert Tauschangebot
4. Vorgesetzter genehmigt (optional)
5. Dienstplan wird aktualisiert
6. Beide erhalten Bestaetigung

**Technische Anforderungen:**
- Qualifikationspruefung automatisch
- Arbeitszeitgesetz-Pruefung
- Audit-Trail fuer Tauschuebersicht
- Push-Benachrichtigungen

---

### 1.5 KI-gestuetzte Dienstplanerstellung

**Beschreibung:** Kuenstliche Intelligenz erstellt optimale Dienstplaene basierend auf historischen Daten und Constraints.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| Quinyx | Vollstaendige KI-Optimierung | Exzellent |
| Papershift | Automatische Schichtplanung | Sehr gut |
| GFOS | Ressourcenoptimierung | Gut |

**KI-Faktoren:**
- Historische Auslastung
- Mitarbeiter-Praeferenzen
- Qualifikationsanforderungen
- Arbeitsgesetze und Tarifvertraege
- Kosten-Optimierung
- Fairness-Verteilung

**Prognose (Quinyx, 2025):**
> "Bis 2025 werden 40% der grossen, personalintensiven Unternehmen
> die Automatisierung nutzen, um Entscheidungen fuer ihre
> Personaleinsatz-Planung zu treffen."

---

## 2. KOMMUNIKATION

### 2.1 Push-Benachrichtigungen

**Beschreibung:** Sofortige Benachrichtigungen auf Mobilgeraete bei wichtigen Ereignissen.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Kanaele |
|----------|----------------|---------|
| TimeCount | Vollstaendig | Push, E-Mail, SMS |
| Papershift | Standard | Push, E-Mail |
| DISPONIC | In App | Push |
| Aplano | Standard | Push |
| Shiftbase | Standard | Push |

**Typische Push-Ereignisse:**
- Neue Schicht zugewiesen
- Schichtaenderung
- Urlaubsantrag genehmigt/abgelehnt
- Schichttausch-Anfrage
- Erinnerung vor Schichtbeginn
- Dokumentenablauf (Zertifikate)

**Technische Umsetzung:**
- Firebase Cloud Messaging (FCM) fuer Android
- Apple Push Notification Service (APNs) fuer iOS
- Web Push fuer Browser
- Fallback auf E-Mail/SMS

---

### 2.2 Chat-Integration

**Beschreibung:** Integrierte Kommunikationsmoeglichkeit zwischen Mitarbeitern und Vorgesetzten.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| Aplano | **Integrierter Teamchat** | Sehr gut |
| Papershift | Intelligenter Chat | Sehr gut |
| HUMANSTARS | Dedizierte Mitarbeiter-App | Gut |

**Feature-Details:**
- Einzelchats
- Gruppenchats (Team, Objekt, Projekt)
- Broadcast-Nachrichten
- Dateianhange
- Lesebestaetigungen
- Archivierung

**Externe Integrationen:**
- Microsoft Teams (Personio, viele andere)
- Slack (Personio)
- WhatsApp Business API (manche)

---

### 2.3 Automatische Erinnerungen

**Beschreibung:** Zeitgesteuerte automatische Benachrichtigungen fuer verschiedene Ereignisse.

**Implementierungsbeispiele:**
| Ereignis | Zeitpunkt | Kanal |
|----------|-----------|-------|
| Schichtbeginn | 1h/24h vorher | Push |
| Zertifikat laeuft ab | 30/7/1 Tag vorher | E-Mail |
| Urlaubsantrag offen | Nach 48h | Push an Vorgesetzten |
| Zeiterfassung fehlt | Nach Schichtende | Push |
| Neue Dienstplaene | Bei Veroeffentlichung | Push + E-Mail |

---

## 3. ZEITERFASSUNG

### 3.1 GPS-gestuetzte Zeiterfassung

**Beschreibung:** Erfassung des Standorts beim Ein-/Ausstempeln zur Verifizierung.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Datenschutz |
|----------|----------------|-------------|
| TimeTrack | Geofencing (200m Radius) | DSGVO-konform |
| DISPONIC | Mobile Zeiterfassung | Optional |
| Aplano | GPS-Option | Optional |
| LogPro | GPS-Tracking | Transparent |
| Shiftbase | Optional | Konfigurierbar |

**Technische Implementierung:**
```
Geofencing-Beispiel:
- Objekt-Adresse hinterlegen
- Radius definieren (z.B. 200m)
- Zeiterfassung nur innerhalb des Radius moeglich
- GPS-Koordinaten werden NICHT dauerhaft gespeichert
- Nur Validierung: "innerhalb" oder "ausserhalb"
```

**Datenschutz-Anforderungen (DSGVO):**
- Mitarbeiter-Einwilligung erforderlich
- Zweckbindung dokumentieren
- Keine dauerhafte Standortverfolgung
- Datenminimierung
- Transparenz ueber Datennutzung

---

### 3.2 QR-Code Check-In

**Beschreibung:** Zeiterfassung durch Scannen eines QR-Codes am Arbeitsplatz.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| TimeTrack | Vollstaendig | Sehr gut |
| LogPro | QR + Barcode + Bluetooth | Sehr gut |
| Blink | QR + NFC | Sehr gut |
| clockin | QR-Code pro Raum/Objekt | Gut |

**Vorteile:**
- Keine Hardware-Investition (nur gedruckter Code)
- Standortverifizierung ohne GPS
- Schnell und intuitiv
- Faelschungssicher (Code wechselt periodisch)

**Implementierung:**
```
1. Admin generiert QR-Code fuer Objekt/Standort
2. Code wird am Eingang ausgehaengt
3. Mitarbeiter scannt mit Smartphone-App
4. System erfasst: Zeitstempel + Objekt-ID + Mitarbeiter-ID
5. Optional: GPS-Koordinaten zur Verifizierung
```

---

### 3.3 NFC-Zeiterfassung

**Beschreibung:** Kontaktlose Zeiterfassung ueber NFC-Tags oder -Karten.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung |
|----------|----------------|
| Blink | NFC-Chips |
| GFOS | Hardware-Terminal |
| LogPro | Bluetooth Beacons |

**Vorteile:**
- Sehr schnell (unter 1 Sekunde)
- Kein manuelles Entsperren des Smartphones
- Robust gegen Verschmutzung (vs. QR)

---

### 3.4 Biometrische Erfassung

**Beschreibung:** Zeiterfassung ueber Fingerabdruck, Gesichtserkennung oder Iris-Scan.

**Hinweis:** In Deutschland datenschutzrechtlich problematisch. Nur mit ausdruecklicher Einwilligung und strenger Zweckbindung.

**Anbieter:**
- GFOS (Hardware-Terminals mit Fingerprint optional)
- Spezialisierte Terminal-Hersteller

**DSGVO-Anforderungen:**
- Explizite, schriftliche Einwilligung
- Alternative muss angeboten werden
- Lokale Speicherung (Template, nicht Bild)
- Loesch-Richtlinien

---

## 4. REPORTING

### 4.1 Echtzeit-Dashboards

**Beschreibung:** Visuelle Darstellung aktueller KPIs und Metriken in Echtzeit.

**Anbieter mit diesem Feature:**
| Anbieter | Dashboard-Typ | Anpassbar |
|----------|---------------|-----------|
| GFOS | Security Dashboard | Ja |
| Quinyx | Workforce Analytics | Ja |
| Personio | People Analytics | Ja |
| DISPONIC | Planungsuebersicht | Teilweise |

**Typische Dashboard-Elemente:**
- Aktuelle Besetzung vs. Soll
- Offene Schichten
- Krankmeldungen heute
- Ueberstunden-Status
- Verfuegbare Mitarbeiter
- Auslastung nach Objekt

**Technische Umsetzung:**
```
- WebSocket fuer Echtzeit-Updates
- D3.js / Chart.js fuer Visualisierung
- Responsive Design
- Export-Funktion (PDF, Excel)
```

---

### 4.2 Automatische Berichte

**Beschreibung:** Periodisch generierte und versendete Reports.

**Standard-Berichte:**
| Bericht | Frequenz | Empfaenger |
|---------|----------|------------|
| Dienstplan-Uebersicht | Woechentlich | Team |
| Stundenauswertung | Monatlich | Lohnbuchhaltung |
| Ueberstunden-Report | Monatlich | Vorgesetzte |
| Abwesenheits-Statistik | Monatlich | HR |
| Compliance-Bericht | Quartalsweise | Geschaeftsfuehrung |

**Anbieter:**
- Personio: People Analytics mit Scheduling
- Quinyx: Automatische Reports
- GFOS: Umfangreiche Berichtsgenerierung

---

### 4.3 KPI-Tracking

**Beschreibung:** Verfolgung und Analyse relevanter Kennzahlen.

**Relevante KPIs (Sicherheitsbranche):**
| KPI | Beschreibung | Zielwert (Beispiel) |
|-----|--------------|---------------------|
| Besetzungsquote | Besetzte vs. geplante Schichten | >98% |
| Krankenquote | Krankheitstage / Arbeitstage | <5% |
| Fluktuation | Kuendigungen / Mitarbeiter | <15% p.a. |
| Ueberstundenquote | Ueberstunden / Gesamtstunden | <10% |
| Reaktionszeit | Zeit bis Schichtbesetzung | <4h |
| Mitarbeiterzufriedenheit | Umfrage-Score | >4/5 |

---

## 5. MOBILE FEATURES

### 5.1 Offline-Faehigkeit

**Beschreibung:** App funktioniert auch ohne Internetverbindung.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Sync |
|----------|----------------|------|
| HybridForms | Vollstaendig offline | Auto-Sync |
| Sched | Offline-Zugriff auf Daten | Beim Verbinden |
| Eventbase | Offline-First Design | Automatisch |
| Bizzabo | Low-Connectivity Mode | Automatisch |

**Technische Umsetzung:**
```
1. Daten werden lokal gecached (IndexedDB / SQLite)
2. Aenderungen werden in Queue gespeichert
3. Bei Verbindung: Automatische Synchronisation
4. Konfliktloesung: Server gewinnt oder User-Dialog
```

**Wichtige Offline-Funktionen:**
- Dienstplan ansehen
- Zeiterfassung (wird spaeter synchronisiert)
- Wachbuch-Eintraege erstellen
- Fotos aufnehmen

---

### 5.2 Dokumenten-Upload

**Beschreibung:** Hochladen von Dokumenten direkt aus der App.

**Anwendungsfaelle:**
- Krankmeldungen (Foto vom AU)
- Zertifikate hochladen
- Einsatzberichte
- Checklisten

**Anbieter:**
- Shiftbase: Self-Service Dokumente hochladen
- HybridForms: Formular-basierte Dokumentation
- CSA360: Incident Reports mit Anhangen

---

### 5.3 Foto-Dokumentation

**Beschreibung:** Aufnahme und Zuordnung von Fotos zu Einsaetzen.

**Anbieter mit diesem Feature:**
| Anbieter | Implementierung | Bewertung |
|----------|----------------|-----------|
| HybridForms | Mit Skizzen und Markierungen | Exzellent |
| GuardMetrics | Incident Reports mit Fotos | Sehr gut |
| CSA360 | Custom Forms mit Fotos | Sehr gut |
| clockin | Live-Dokumentation | Gut |

**Feature-Details (HybridForms):**
- Beliebig viele Fotos pro Einsatz
- Automatischer Zeitstempel
- Skizzenfunktion auf Bildern
- Markierungen und Notizen
- Offline-faehig
- Automatische Synchronisation
- DSGVO-konform

**Anwendungsfaelle (Sicherheit):**
- Schadensdokumentation
- Kontrollnachweise
- Besondere Vorkommnisse
- Zustandsdokumentation

---

## 6. SICHERHEITS-SPEZIFISCHE FEATURES

### 6.1 Digitales Wachbuch

**Beschreibung:** Elektronische Erfassung aller Wachvorgaenge und Ereignisse.

**Anbieter:**
- **SecPlanNet:** Online-Wachbuch mit Echtzeit-Zugriff
- **DISPONIC:** Integriertes digitales Wachbuch

**Funktionen:**
- Ereigniserfassung (Personen, Fahrzeuge, Vorfaelle)
- Rundgaenge dokumentieren
- Besucherregistrierung
- Schluesseluebergaben
- Alarmprotokoll
- Foto-Anlage
- Unterschriftenfunktion

**Zugriffsrechte:**
- Wachpersonal: Eintraege erstellen
- Objektleiter: Lesen + Bearbeiten
- Kunde: Lesezugriff (optional)

---

### 6.2 Waechter-Kontrollsystem (WKS)

**Beschreibung:** Nachweis von Kontrollgaengen durch Erfassung von Checkpoints.

**Anbieter:**
- **SecPlanNet:** PlanNetWKS mit Smartphone
- **DISPONIC:** Integriertes WKS

**Technische Varianten:**
| Methode | Hardware | Vorteile |
|---------|----------|----------|
| NFC-Tags | NFC-Chips an Checkpoints | Robust, guenstig |
| QR-Codes | Gedruckte Codes | Sehr guenstig |
| iButtons | Spezial-Hardware | Extrem robust |
| GPS-Geofencing | Nur Smartphone | Keine Infrastruktur |

**Workflow:**
```
1. Kontrollpunkte im System definieren (mit Koordinaten/Code)
2. Rundgang-Route festlegen (optional mit Reihenfolge)
3. Wachmann scannt Checkpoints waehrend Rundgang
4. System erfasst: Zeitstempel + Checkpoint + Mitarbeiter
5. Abweichungen werden gemeldet (verpasste Punkte, falsche Zeit)
6. Nachweis fuer Kunden exportierbar
```

---

### 6.3 Bewacherregister-Integration

**Beschreibung:** Verwaltung der Bewacherregister-Nummern (gesetzliche Anforderung).

**Anbieter:**
- **SecPlanNet:** Standard-Funktion
- **DISPONIC:** Integriert

**Funktionen:**
- Bewacherregister-Nr. im Mitarbeiterprofil
- Automatische Ausgabe auf Einsatzlisten
- Pruefung auf Gueltigkeit
- Ablauf-Warnungen

---

## 7. COMPLIANCE & AUTOMATISCHE PRUEFUNGEN

### 7.1 Arbeitszeitgesetz-Konformitaet

**Beschreibung:** Automatische Pruefung auf Einhaltung gesetzlicher Vorgaben.

**Geprueft werden:**
| Regelung | Grenzwert |
|----------|-----------|
| Tageshöchstarbeitszeit | 10 Stunden |
| Wochenhöchstarbeitszeit | 48 Stunden (Durchschnitt) |
| Ruhezeit | 11 Stunden zwischen Schichten |
| Pausenregelung | 30 Min. ab 6h, 45 Min. ab 9h |
| Sonntagsarbeit | Max. 15 Sonntage/Jahr (branchenabh.) |

**Anbieter mit automatischer Pruefung:**
- TimeCount: Aktive Warnungen
- SecPlanNet: Automatische Pruefung (GAV CH)
- Papershift: Compliance-Warnungen
- Quinyx: Automatische Einhaltung

**Kritik:**
- Shiftbase: KEINE Warnung bei Ruhezeit-Verstoessen!

---

### 7.2 Tarifkonformitaet

**Beschreibung:** Pruefung auf Einhaltung von Tarifvertraegen.

**Relevante Aspekte (Sicherheitsbranche):**
- Mindestloehne nach Region
- Nachtzuschlaege (mind. 25%)
- Wochenend-/Feiertagszuschlaege
- Erschwerniszulagen

---

## 8. INTEGRATIONEN

### 8.1 Lohnbuchhaltung

**Standard-Schnittstellen:**
| Anbieter | DATEV | Andere |
|----------|-------|--------|
| SecPlanNet | Ja | Gaengige Programme |
| DISPONIC | Ja | Weitere |
| Personio | Ja | Diverse |
| Papershift | Ja | - |

### 8.2 API-Verfuegbarkeit

**REST APIs:**
| Anbieter | API | Dokumentation |
|----------|-----|---------------|
| Personio | REST v1/v2 | Oeffentlich |
| Papershift | REST | Oeffentlich |
| GFOS | Enterprise API | Auf Anfrage |

**Personio API Endpoints:**
- Mitarbeiterstammdaten
- Anwesenheiten
- Abwesenheiten
- Recruiting

---

## 9. FEATURE-PRIORISIERUNG FUER CONSYS

### Must-Have (Sofort)
1. Drag & Drop Dienstplanung
2. Mobile Zeiterfassung
3. Push-Benachrichtigungen
4. Verfuegbarkeitsabfrage
5. Arbeitszeitgesetz-Pruefung

### Should-Have (Mittelfristig)
1. QR-Code Check-In
2. Schichttausch-Funktion
3. Digitales Wachbuch
4. Automatische Berichte
5. Qualifikations-Matching

### Nice-to-Have (Langfristig)
1. KI-gestuetzte Planung
2. Waechter-Kontrollsystem
3. Offline-Faehigkeit
4. Foto-Dokumentation
5. GPS-Verifizierung

---

## 10. QUELLEN

### Software-Anbieter
- [TimeCount](https://www.timecount.com/sicherheitsdienst-software/)
- [SecPlanNet](https://dienstplanmacher.de/personalsoftware/secplannet/)
- [GFOS](https://www.gfos.com/)
- [Papershift](https://www.papershift.com/)
- [Personio](https://www.personio.com/)
- [DISPONIC](https://www.disponic.de/)
- [Aplano](https://www.aplano.de/)
- [Quinyx](https://www.quinyx.com/)
- [Shiftbase](https://www.shiftbase.com/)

### Spezialisierte Tools
- [TimeTrack](https://www.timetrackapp.com/)
- [HybridForms](https://www.hybridforms.net/)
- [GuardMetrics](https://guardmetrics.com/)
- [LogPro](https://www.logpro.de/)
- [Blink](https://www.blink.de/)
- [clockin](https://www.clockin.de/)

### Vergleiche und Reviews
- [Capterra](https://www.capterra.com.de/)
- [trusted.de](https://trusted.de/personaleinsatzplanung)
- [OMR Reviews](https://omr.com/de/reviews/)
- [Softwareabc24](https://www.softwareabc24.de/)
