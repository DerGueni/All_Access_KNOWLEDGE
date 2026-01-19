# Export-Status: Access-Formulare zu MD-Dateien

## Letzte Aktualisierung: 2026-01-12

**Quellordner Access:** `C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb`
**Zielordner:** `04_HTML_Forms\forms3\Access_Abgleich\forms\`

---

## Neu exportierte Formulare via Access Bridge (11 Stück)

### 1. frmTop_Geo_Verwaltung.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Verwaltung geografischer Daten

### 2. frmOff_Outlook_aufrufen.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Schnittstelle zu Microsoft Outlook

### 3. zfrm_Lohnabrechnungen.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Lohnabrechnungsverwaltung

### 4. zfrm_MA_Stunden_Lexware.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Stundenexport für Lexware

### 5. zfrm_Rueckmeldungen.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Rückmeldungsverwaltung

### 6. frm_Kundenpreise.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Kundenpreisverwaltung

### 7. frm_MA_Maintainance.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Mitarbeiter-Wartung und Administration

### 8. frm_Zeiterfassung.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Zeiterfassungssystem

### 9. frmTop_RechnungsStamm.md
- **Status:** ✅ Exportiert (Ersatz für frm_Rechnungen_bezahlt_offen)
- **Beschreibung:** Rechnungsstammdatenverwaltung

### 10. frm_Umsatzuebersicht_2.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Umsatzauswertung

### 11. frm_Startmenue.md
- **Status:** ✅ Exportiert
- **Beschreibung:** Hauptmenü/Startbildschirm

---

## Fehlgeschlagene Exporte

### frm_Rechnungen_bezahlt_offen
- **Fehler:** "Der Suchschlüssel wurde in keinem Datensatz gefunden"
- **Ersatz:** frmTop_RechnungsStamm.md wurde stattdessen exportiert

---

## Alle exportierten Formulare (Gesamt: 36)

### Hauptformulare (frm_*)
1. frm_Abwesenheiten.md
2. frm_abwesenheitsuebersicht.md
3. frm_Ausweis_Create.md
4. frm_DP_Dienstplan_MA.md
5. frm_DP_Dienstplan_Objekt.md
6. frm_Einsatzuebersicht.md
7. frm_KD_Kundenstamm.md
8. frm_Kundenpreise.md ⭐ NEU
9. frm_Kundenpreise_gueni.md
10. frm_MA_Abwesenheiten_Urlaub_Gueni.md
11. frm_MA_Maintainance.md ⭐ NEU
12. frm_MA_Mitarbeiterstamm.md
13. frm_MA_Offene_Anfragen.md
14. frm_MA_Serien_eMail_Auftrag.md
15. frm_MA_Serien_eMail_dienstplan.md
16. frm_MA_VA_Positionszuordnung.md
17. frm_MA_VA_Schnellauswahl.md
18. frm_Menuefuehrung1.md
19. frm_MitarbeiterstammTabelle.md
20. frm_OB_Objekt.md
21. frm_Rueckmeldestatistik.md
22. frm_Startmenue.md ⭐ NEU
23. frm_Systeminfo.md
24. frm_Umsatzuebersicht_2.md ⭐ NEU
25. frm_VA_Auftragstamm.md
26. frm_Zeiterfassung.md ⭐ NEU

### Top-Level Formulare (frmTop_*)
27. frmTop_DP_MA_Auftrag_Zuo.md
28. frmTop_Geo_Verwaltung.md ⭐ NEU
29. frmTop_KD_Adressart.md
30. frmTop_MA_Abwesenheitsplanung.md
31. frmTop_RechnungsStamm.md ⭐ NEU
32. frmTop_VA_Akt_Objekt_Kopf.md

### System-Formulare (zfrm_*)
33. zfrm_Lohnabrechnungen.md ⭐ NEU
34. zfrm_MA_Stunden_Lexware.md ⭐ NEU
35. zfrm_Rueckmeldungen.md ⭐ NEU
36. zfrm_SyncError.md

### Office-Integration (frmOff_*)
- frmOff_Outlook_aufrufen.md ⭐ NEU

---

## Export-Format

Jede MD-Datei enthält:

### 1. Formular-Metadaten
- Name
- Datensatzquelle (RecordSource)
- Datenquellentyp (Query/Table/SQL)
- Default View
- Berechtigungen (AllowEdits, AllowAdditions, AllowDeletions)
- Data Entry Modus
- Navigation Buttons

### 2. Controls
Gruppiert nach Typ:
- **Labels** (Bezeichnungsfelder)
- **TextBoxen**
- **CommandButtons** (Schaltflächen)
- **ComboBoxen** (Auswahllisten)
- **Subforms** (Unterformulare)
- Weitere Control-Typen

Für jeden Control:
- Name
- Position (Left/Top)
- Größe (Width/Height)
- Caption/ControlSource
- Farben (ForeColor/BackColor)
- TabIndex
- Events

### 3. Events
- Formular-Events (OnOpen, OnLoad, OnClose, OnCurrent, etc.)
- Control-Events (OnClick, AfterUpdate, etc.)

### 4. VBA-Code
- Extrahierter VBA-Code falls HasModule=True

---

## Verwendung

Diese MD-Dateien dienen als:
1. **Dokumentation** der Access-Formulare
2. **Referenz** für HTML-Formular-Entwicklung
3. **Abgleich** zwischen Access und HTML
4. **Nachvollziehbarkeit** von Änderungen

---

## Nächste Schritte

- [ ] Fehlende Datensatzquellen in MD-Dateien ergänzen
- [ ] VBA-Code-Extraktion für alle Formulare mit HasModule=True
- [ ] Vergleich Access vs. HTML für kritische Formulare
- [ ] Gap-Analyse: Welche Access-Features fehlen in HTML?
