# Sidebar-Vergleich aller HTML-Formulare

## Referenz: frm_va_Auftragstamm (Typ A - Standard)

Die Sidebar in `frm_va_Auftragstamm.html` enthält folgende Menüpunkte:
1. Dienstplanübersicht
2. Planungsübersicht
3. Auftragsverwaltung
4. Mitarbeiterverwaltung
5. Offene Mail Anfragen
6. Excel Zeitkonten
7. Zeitkonten
8. Abwesenheitsplanung
9. Dienstausweis erstellen
10. Stundenabgleich
11. Kundenverwaltung
12. **Verrechnungssätze**
13. Sub Rechnungen
14. E-Mail
15. Menu 2
16. **HTML Ansicht**
17. System Info
18. **Datenbank wechseln**

---

## Vergleichstabelle

| Formular | Sidebar-Typ | Abweichungen von Referenz |
|----------|-------------|--------------------------|
| 01_frm_va_Auftragstamm | A (Standard) | **REFERENZ** - Hat: HTML Ansicht, Datenbank wechseln |
| 02_frm_MA_Mitarbeiterstamm | A | +Objektverwaltung, -HTML Ansicht |
| 03_frm_KD_Kundenstamm | A | +Objektverwaltung, -HTML Ansicht |
| 04_frm_OB_Objekt | A | +Objektverwaltung, -HTML Ansicht |
| 05_frm_Menuefuehrung1 | C (Popup) | **Komplett anders** - Kein Sidebar, nur Popup-Menü |
| 06_frm_DP_Dienstplan_Objekt | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 07_frm_DP_Dienstplan_MA | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 08_frm_Abwesenheiten | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 09_frm_N_Dienstplanuebersicht | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 10_frm_MA_VA_Schnellauswahl | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 11_frm_MA_Abwesenheit | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 12_frm_MA_Zeitkonten | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 13_frm_MA_Offene_Anfragen | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 14_frm_Ausweis_Create | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 15_frm_Kundenpreise_gueni | A | -Objektverwaltung, +HTML Ansicht, -Datenbank wechseln |
| 16_frm_MA_Serien_eMail_Auftrag | **B (Neu)** | **Komplett anders** - Gruppierte CONSYS-Sidebar |
| 17_frm_MA_Serien_eMail_dienstplan | **B (Neu)** | **Komplett anders** - Gruppierte CONSYS-Sidebar |
| 18_frm_MA_VA_Positionszuordnung | **B (Neu)** | **Komplett anders** - Gruppierte CONSYS-Sidebar |
| 19_frm_MA_VA_Schnellauswahl_OLD | **B (Neu)** | **Komplett anders** - Gruppierte CONSYS-Sidebar |

---

## Sidebar-Typen

### Typ A: Standard-Sidebar (wie Referenz)
- Vertikale Button-Liste
- Blaue Buttons mit weißem Text
- "HAUPTMENU" als Header

### Typ B: Neue gruppierte CONSYS-Sidebar
Komplett andere Struktur mit Kategorien:
- **Stammdaten:** Mitarbeiter, Kunden, Kundenpreise, Aufträge
- **Planung:** Dienstplanübersicht, Planungsübersicht, Offene Anfragen
- **Personal:** Mitarbeiterstamm, Abwesenheitsübersicht, Abwesenheitsplanung, Zeitkonten, Bewerber, Ausweiserstellung
- **Lohn:** Lohnabrechnungen, Stunden Lexware
- **Kommunikation:** E-Mail versenden
- **Verwaltung:** Geo-Verwaltung, Optimierung
- **Dashboard:** Dashboard, Dashboard (Neu)

### Typ C: Popup-Menü (kein Sidebar)
- Zentriertes Popup mit Kategorien
- Navigation, Personal, Extras & Tools, System

---

## Inkonsistenzen (zu beheben)

### Fehlende Menüpunkte in manchen Formularen:
| Menüpunkt | Fehlt in |
|-----------|----------|
| Objektverwaltung | 06-15 (Dienstplan, Abwesenheiten, etc.) |
| HTML Ansicht | 02-04 (Mitarbeiter, Kunde, Objekt) |
| Datenbank wechseln | 06-15 |

### Formulare mit komplett anderer Sidebar (Typ B):
- frm_MA_Serien_eMail_Auftrag
- frm_MA_Serien_eMail_dienstplan
- frm_MA_VA_Positionszuordnung
- frm_MA_VA_Schnellauswahl_OLD

**Empfehlung:** Diese 4 Formulare auf Typ A (Standard) umstellen für Konsistenz.

---

## Screenshots-Verzeichnis
`.playwright-mcp/screenshots/`

Generiert am: 02.01.2026
