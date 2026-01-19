# FORMULARE INVENTAR - Access Frontend Export

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb
Gesamtanzahl Formulare: 271

---

## HAUPTFORMULARE (Haupt-Navigationsformulare)

### frm_Menuefuehrung / frm_Menuefuehrung1
- **Typ:** Hauptmenu / Navigation
- **RecordSource:** tbl_Menuefuehrung_Neu
- **Funktion:** Zentrales Navigationsformular fuer alle Bereiche
- **Subformulare:** sub_Menuefuehrung

### frm_va_Auftragstamm
- **Typ:** Hauptformular
- **RecordSource:** tbl_VA_Auftragstamm
- **Funktion:** Auftragsverwaltung - zentrale Auftragsbearbeitung
- **Subformulare:**
  - frm_Menuefuehrung (Navigation)
  - sub_MA_VA_Zuordnung (MA-Zuordnungen, verknuepft ueber VA_ID, VADatum_ID)
  - sub_VA_Start (Schichten/Startzeiten, verknuepft ueber VA_ID, VADatum_ID)
  - sub_MA_VA_Planung_Absage (Absagen, verknuepft ueber VA_ID, VADatum_ID)
  - sub_MA_VA_Planung_Status (Status, verknuepft ueber VA_ID, VADatum_ID)
  - sub_ZusatzDateien (Zusatzdateien, verknuepft ueber Objekt_ID, TabellenNr)
  - sub_tbl_Rch_Kopf (Rechnungskoepfe, verknuepft ueber VA_ID)
  - sub_tbl_Rch_Pos_Auftrag (Rechnungspositionen, verknuepft ueber VA_ID)
  - sub_VA_Anzeige (Auftragsanzeige)
  - frm_lst_row_auftrag (Auftragsliste)

### frm_MA_Mitarbeiterstamm
- **Typ:** Hauptformular
- **RecordSource:** tbl_MA_Mitarbeiterstamm
- **Funktion:** Mitarbeiterverwaltung mit allen Detailinformationen
- **Subformulare:**
  - Menü (frm_Menuefuehrung)
  - sub_MA_ErsatzEmail (Ersatz-E-Mail, verknuepft ueber ID -> MA_ID)
  - sub_MA_Einsatz_Zuo (Einsatzzuordnung, verknuepft ueber ID -> MA_ID)
  - sub_tbl_MA_Zeitkonto_Aktmon1/2 (Zeitkonten)
  - frmStundenuebersicht (Stundenuebersicht, verknuepft ueber ID -> MA_ID)
  - sub_MA_tbl_MA_NVerfuegZeiten (Nichtverfuegbarkeiten)
  - sub_MA_Dienstkleidung (Dienstkleidung, verknuepft ueber ID -> MA_ID)
  - sub_tbltmp_MA_Ausgef_Vorlagen (Ausgefuellte Vorlagen)
  - sub_tbl_MA_StundenFolgemonat (Stunden Folgemonat)
  - ufrm_Maps (Google Maps Browser)
  - subAuftragRech (Auftragsrechnungen, verknuepft ueber ID -> MA_ID)
  - subZuoStunden (Zuordnungsstunden)
- **Register/Tabs:**
  - pgPlan (Dienstplan)
  - pgDienstKl (Dienstkleidung)
  - pgAuftrUeb (Auftragsuebersicht)
  - pgMonat (Monatsuebersicht)
  - pgJahr (Jahresuebersicht)

### frm_KD_Kundenstamm
- **Typ:** Hauptformular
- **RecordSource:** tbl_KD_Kundenstamm
- **Funktion:** Kundenverwaltung
- **Wichtige Controls:** Kundenname, Adresse, Ansprechpartner, Preise

### frm_OB_Objekt
- **Typ:** Hauptformular
- **RecordSource:** tbl_OB_Objekt
- **Funktion:** Objektverwaltung (Einsatzorte)
- **Subformulare:**
  - sub_OB_Objekt_Positionen (Positionen am Objekt)
  - sub_Browser (Google Maps)

---

## PLANUNGSFORMULARE

### frm_DP_Dienstplan_MA
- **Typ:** Planungsformular
- **RecordSource:** qry_DP_MA_Kreuztabelle
- **Funktion:** Dienstplan pro Mitarbeiter (Kalenderansicht)

### frm_DP_Dienstplan_Objekt
- **Typ:** Planungsformular
- **RecordSource:** qry_DP_Alle
- **Funktion:** Dienstplan pro Objekt (alle MA eines Objekts)

### frm_UE_Uebersicht
- **Typ:** Planungsformular
- **Funktion:** Tages-/Wochen-/Monatsuebersicht
- **Ansichten:**
  - Tag (WoUmsch(1))
  - Woche (WoUmsch(2))
  - Monat (WoUmsch(3))

### frm_MA_VA_Schnellauswahl
- **Typ:** Planungsformular
- **Funktion:** Schnelle MA-Zuordnung zu Auftraegen
- **RecordSource:** ztbl_MA_Schnellauswahl
- **Sortieroptionen:**
  - Standard
  - Nach Entfernung zum Objekt

### frm_auftragsuebersicht_neu
- **Typ:** Uebersichtsformular
- **RecordSource:** qry_Auftragsuebsicht1
- **Funktion:** Tabellarische Auftragsuebersicht

### frm_Einsatzuebersicht_kpl
- **Typ:** Uebersichtsformular
- **Funktion:** Komplette Einsatzuebersicht

### frm_MA_VA_Positionszuordnung (frm_N_MA_VA_Positionszuordnung)
- **Typ:** Planungsformular
- **Funktion:** MA zu Positionen zuordnen

---

## E-MAIL FORMULARE

### frm_MA_Serien_eMail_Auftrag
- **Typ:** E-Mail-Formular
- **Funktion:** Auftragsbezogene Serien-E-Mails an MA

### frm_MA_Serien_eMail_dienstplan
- **Typ:** E-Mail-Formular
- **Funktion:** Dienstplan-E-Mails an MA

### frm_MA_Serien_eMail_Vorlage
- **Typ:** E-Mail-Formular
- **Funktion:** E-Mail-Vorlagen verwalten

### frmOff_Outlook_aufrufen
- **Typ:** E-Mail-Formular
- **Funktion:** Outlook direkt aufrufen fuer MA oder Kunden
- **Parameter:** 1 = MA, 2 = Kunde

### frm_Outlook_eMail_template
- **Typ:** E-Mail-Formular
- **Funktion:** E-Mail-Vorlagen fuer Kunden und MA

### frmTop_MA_ZuAbsage
- **Typ:** Popup-Formular
- **Funktion:** Manuelle Zu-/Absagen erfassen

### frmTop_eMail_MA_ID_NGef
- **Typ:** Popup-Formular
- **Funktion:** E-Mails ohne MA-Zuordnung bearbeiten

---

## RECHNUNGS-/ABRECHNUNGSFORMULARE

### frmTop_Rch_Berechnungsliste
- **Typ:** Popup-Formular
- **Funktion:** Rechnung oder Angebot erstellen
- **Modi:**
  - TaetigkeitArt = 1: Rechnung
  - TaetigkeitArt = 2: Angebot

### frmTop_RechnungsStamm
- **Typ:** Popup-Formular
- **Funktion:** Rechnungsstammdaten verwalten

### frm_Rch_Kopf_simple
- **Typ:** Formular
- **RecordSource:** tbl_Rch_Kopf
- **Funktion:** Rechnungskopfdaten

### frm_Rechnungen_bezahlt_offen
- **Typ:** Formular
- **Funktion:** Uebersicht bezahlte/offene Rechnungen

### zfrm_Lohnabrechnungen
- **Typ:** Formular
- **Funktion:** Lohnabrechnungen verwalten

### frm_stundenuebersicht
- **Typ:** Formular
- **Funktion:** Stundenuebersicht fuer Abrechnungen

---

## STAMMDATEN-FORMULARE (Popup/Top)

### frmStamm_EigeneFirma
- **Typ:** Hauptformular
- **RecordSource:** _tblEigeneFirma
- **Funktion:** Firmenstammdaten
- **Subformulare:**
  - sub_EigeneFirma_Nummernkreise
  - sub_EigeneFirma_Zahlungsbedingungen
  - sub_EigeneFirma_Word_BriefVorlagen
  - sub_EigeneFirma_Pfade
  - sub_EigeneFirma_Fusszeile
  - sub_EigeneFirma_Mitarbeiter

### frmTop_Login
- **Typ:** Popup-Formular (Dialog)
- **Funktion:** Login-Dialog

### frmTop_Adressart / frmTop_KD_Adressart
- **Typ:** Popup-Formular
- **Funktion:** Adressarten verwalten

### frmTop_KD_Preisarten
- **Typ:** Popup-Formular
- **Funktion:** Kundenpreisarten verwalten

### frmTop_Zeittyp
- **Typ:** Popup-Formular
- **Funktion:** Zeittypen verwalten

### frmTop_MA_Einsatzart
- **Typ:** Popup-Formular
- **Funktion:** Einsatzarten/Qualifikationen verwalten

### frmTop_MA_Anstellungsart
- **Typ:** Popup-Formular
- **Funktion:** Anstellungsarten verwalten

### frmTop_VA_Veranstaltungsstatus
- **Typ:** Popup-Formular
- **Funktion:** Veranstaltungsstatus verwalten

### frmTop_Linkliste
- **Typ:** Popup-Formular
- **Funktion:** Interne Linkliste verwalten

### frmTop_Neue_Vorlagen
- **Typ:** Popup-Formular
- **Funktion:** Word-/Excel-Vorlagen verwalten

---

## ABWESENHEITS-FORMULARE

### frm_abwesenheitsuebersicht
- **Typ:** Formular
- **Funktion:** Abwesenheitsuebersicht aller MA

### frm_MA_Abwesenheiten / frm_Abwesenheiten
- **Typ:** Formular
- **RecordSource:** tbl_MA_NVerfuegZeiten
- **Funktion:** Abwesenheiten erfassen

### frm_MA_NVerfuegZeiten_Si
- **Typ:** Datenblattformular
- **RecordSource:** tbl_MA_NVerfuegZeiten
- **Funktion:** Nichtverfuegbarkeitszeiten

### frmTop_MA_Abwesenheitsplanung
- **Typ:** Popup-Formular
- **Funktion:** Abwesenheitsplanung

---

## IMPORT/EXPORT FORMULARE

### frmTop_XL_Eport_Auftrag
- **Typ:** Popup-Formular
- **Funktion:** Excel-Export Auftragsdaten

### frmTop_XL_Import_Start / frmTop_XL_Import_Check
- **Typ:** Popup-Formular
- **Funktion:** Excel-Import starten/pruefen

### frmTop_Excel_Monatsuebersicht
- **Typ:** Popup-Formular
- **Funktion:** Excel-Monatsuebersicht exportieren

---

## HILFS-FORMULARE

### _frmHlp_Kalender_Jahr / _frmHlp_Kalender_3Mon
- **Typ:** Hilfsformular
- **Funktion:** Jahreskalender / 3-Monatskalender

### _frmHlp_SysInfo
- **Typ:** Hilfsformular
- **Funktion:** Systeminformationen anzeigen

### _frmHlp_LKZ
- **Typ:** Hilfsformular
- **Funktion:** Laenderkennzeichen

### _frmHlp_Excel_Einbinden
- **Typ:** Hilfsformular
- **Funktion:** Excel einbinden/anzeigen

### _frmHlp_MasseGewichteUmrechnen
- **Typ:** Hilfsformular
- **Funktion:** Masse/Gewichte umrechnen

### _frmHlp_Waehrungsumrechnung
- **Typ:** Hilfsformular
- **Funktion:** Waehrungen umrechnen

### frmFensterposition
- **Typ:** Hilfsformular
- **Funktion:** Fensterposition speichern/laden

### frm_Ausweis_Create
- **Typ:** Formular
- **Funktion:** Mitarbeiterausweise erstellen

---

## SUBFORMULARE (Auszug der wichtigsten)

### Auftrags-Subformulare
- sub_VA_Start - Schichten/Startzeiten
- sub_VA_Anzeige - Auftragsanzeige
- sub_MA_VA_Zuordnung - MA-Zuordnungen
- sub_MA_VA_Planung_Absage - Absagen
- sub_MA_VA_Planung_Status - Status
- sub_VA_Kosten - Auftragskosten
- sub_VA_Woche - Wochenansicht
- sub_VA_Tag - Tagesansicht
- sub_VA_Monat - Monatsansicht

### Mitarbeiter-Subformulare
- sub_MA_Dienstkleidung - Dienstkleidung
- sub_MA_ErsatzEmail - Ersatz-E-Mails
- sub_MA_Einsatz_Zuo - Einsatzzuordnung
- sub_MA_FehlZeiten - Fehlzeiten
- sub_MA_Team_Zuo - Teamzuordnung
- sub_MA_Tageszusatzwerte - Tageszusatzwerte
- sub_MA_tbl_MA_NVerfuegZeiten - Nichtverfuegbarkeiten
- sub_MA_Offene_Anfragen - Offene Anfragen

### Kunden-Subformulare
- sub_KD_Standardpreise - Standardpreise
- sub_KD_Auftragskopf - Auftragskopf
- sub_KD_Artikelbeschreibung - Artikelbeschreibungen
- sub_Ansprechpartner - Ansprechpartner

### Rechnungs-Subformulare
- sub_tbl_Rch_Kopf - Rechnungskopf
- sub_tbl_Rch_Pos_Auftrag - Rechnungspositionen
- sub_Rch_Pos_Geschrieben - Geschriebene Positionen
- sub_Rch_Mahnstufe - Mahnstufen
- sub_Mahnungen - Mahnungen

### Dienstplan-Subformulare
- sub_DP_Grund - Dienstplangruende
- sub_DP_Grund_MA - Dienstplangruende pro MA

### Sonstige Subformulare
- sub_Browser - Google Maps Browser-Control
- sub_ZusatzDateien - Zusatzdateien
- sub_Menuefuehrung - Menuenavigation

---

## FORMULAR-KATEGORIEN STATISTIK

| Kategorie | Anzahl |
|-----------|--------|
| Hauptformulare | ~15 |
| Planungsformulare | ~10 |
| E-Mail-Formulare | ~8 |
| Rechnungsformulare | ~8 |
| Stammdaten-Popups | ~15 |
| Abwesenheitsformulare | ~5 |
| Import/Export | ~5 |
| Hilfsformulare | ~15 |
| Subformulare | ~100+ |
| Sonstige/Test | ~90 |

---

## WICHTIGE FORMULAR-VERKNUEPFUNGEN

### Typische Link-Master/Child-Felder:
- **VA_ID** -> VA_ID (Auftragsbezug)
- **VADatum_ID** -> VADatum_ID (Datumsbezug)
- **ID** -> MA_ID (Mitarbeiterbezug)
- **Objekt_ID** -> Objekt_ID (Objektbezug)
- **kun_Id** -> Kunden_ID (Kundenbezug)
