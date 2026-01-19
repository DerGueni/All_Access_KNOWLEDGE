# ABFRAGEN INVENTAR - Access Frontend Export

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb
Gesamtanzahl Abfragen: 560

---

## AUFTRAGS-ABFRAGEN (VA_/Auftrag)

### qry_Auftragsuebsicht1
- **Verwendung:** frm_auftragsuebersicht_neu
- **Funktion:** Auftragsuebersicht mit allen relevanten Feldern

### qry_auftragstatus
- **Funktion:** Auftragsstatus mit Fortschritt
- **JOINs:** tbl_VA_Auftragstamm, tbl_VA_Status, tbl_MA_VA_Zuordnung, tbl_MA_Mitarbeiterstamm
- **Filter:** Status-basiert (1=offen, 2=in Bearbeitung, 3=abgeschlossen, 4=abgerechnet)

### qry_Auftrag_Sort
- **Funktion:** Auftraege sortiert

### qry_Auftrag_Rechnung_Gueni
- **Funktion:** Auftraege mit Rechnungsinformationen

### qry_Auftragsuebersicht_KD
- **Funktion:** Auftragsuebersicht pro Kunde

### qry_all_VA_AnzTage
- **Funktion:** Alle VA-Tage
- **Tabelle:** tbl_VA_AnzTage

### qry_Add_VA_Tag_All
- **Funktion:** Alle VA-Tage hinzufuegen

---

## DIENSTPLAN-ABFRAGEN (DP_)

### qry_Dienstplan
- **Verwendung:** Dienstplan-Ansichten
- **Funktion:** Hauptdienstplan-Abfrage
- **SQL:**
```sql
SELECT VA_ID, MA_ID, VADatum_ID, VADatum, Auftrag, Ort, Objekt,
       Treffpunkt, Beginn, Ende, IstPL, Plan_ID, PKW,
       MA_Brutto_Std, MA_Netto_Std, Treffp_Zeit, VADatum1
FROM qry_MA_VA_Plan_AllAufUeber1
LEFT JOIN zqry_Treffpunkt ON VA_ID
WHERE IstPL="Zuo"
ORDER BY VADatum, Beginn
```

### qry_DP_Alle
- **Verwendung:** frm_DP_Dienstplan_Objekt
- **Funktion:** Alle Dienstplan-Eintraege

### qry_DP_Alle2/3/4/5
- **Funktion:** Dienstplan-Varianten

### qry_DP_Alle_Obj
- **Funktion:** Dienstplan pro Objekt

### qry_DP_Alle_Zt
- **Funktion:** Dienstplan mit Zeittypen

### qry_DP_Alle_Zt_Fill / qry_DP_Alle_Zt_Fill_Alt / qry_DP_Alle_Zt_Fill_MA
- **Funktion:** Dienstplan mit Zeittypen befuellt

### qry_DP_MA_Kreuztabelle
- **Verwendung:** frm_DP_Dienstplan_MA
- **Funktion:** Dienstplan als Kreuztabelle (MA vs. Tage)

### qry_DP_Kreuztabelle
- **Funktion:** Allgemeine Dienstplan-Kreuztabelle

### qry_DP_MA_1 / qry_DP_MA_2
- **Funktion:** Dienstplan-MA-Abfragen

### qry_DP_MA_Neu_1/2/3_Import
- **Funktion:** Dienstplan-Import fuer neue MA

### qry_DP_MA_NVerfueg
- **Funktion:** MA-Nichtverfuegbarkeiten im Dienstplan

### qry_DP_MA_Grund_FI_Fill
- **Funktion:** Dienstplan-Gruende befuellen

### qry_DP_Obj_ab_Heute / qry_DP_Obj_ab_Heute_ZW
- **Funktion:** Objekte ab heute

### qry_DP_Anzeige
- **Funktion:** Dienstplan-Anzeige

### qry_DP_tbltmp_MA_FI
- **Funktion:** Temporaere MA-Fehlzeiten-Informationen

### qry_DP_Temp_Imp_MA
- **Funktion:** Temporaerer MA-Import

---

## MA-ZUORDNUNGS-ABFRAGEN (MA_VA_)

### qry_MA_VA_Plan_AllAufUeber1
- **Funktion:** MA-VA-Planung mit Auftragsuebersicht
- **SQL:** UNION-Abfrage aus qry_MA_VA_Plan_All_AufUeber1a und qry_MA_VA_Plan_All_AufUeber2_neu
- **Felder:** VA_ID, MA_ID, VADatum_ID, VADatum, Auftrag, Ort, Objekt, Beginn, Ende, IstPL, Plan_ID, PKW, MA_Brutto_Std, MA_Netto_Std

### qry_Anz_MA_VA_Zuordnung
- **Funktion:** Anzahl MA-Zuordnungen

### qry_Anz_MA_VA_Zuordnung_Tag
- **Funktion:** Anzahl MA-Zuordnungen pro Tag

---

## ANZAHL-/STATISTIK-ABFRAGEN (Anz_)

### qry_Anz_Auftrag_AllTag
- **Funktion:** Anzahl Auftraege pro Tag (alle)

### qry_Anz_Auftrag_AllTag_Offen
- **Funktion:** Anzahl offene Auftraege pro Tag

### qry_Anz_Auftrag_ProTag
- **Funktion:** Auftraege gruppiert pro Tag

### qry_Anz_MA_Anzahl_Diff / _Tag / _Tag_Rest / _Zwi
- **Funktion:** MA-Anzahl-Differenzen (Soll vs. Ist)

### qry_Anz_MA_Hour / qry_Anz_MA_Hour_2
- **Funktion:** MA pro Stunde

### qry_Anz_Ma_Neu_Hour_1/2/3
- **Funktion:** Neue MA pro Stunde

### qry_Anz_MA_Start / _Report / _sub
- **Funktion:** MA-Startzeiten

### qry_Anz_MA_Tag / _1 / _Offen / _Org / _SPI
- **Funktion:** MA pro Tag

### qry_Anz_Plan_1_2_MA
- **Funktion:** Planstatus-Zaehlung

### qry_Anz_sub_Monat / _Ist / _Soll
- **Funktion:** Monatliche Zaehlung

### qry_Anz_VA_Start_Tag
- **Funktion:** VA-Startzeiten pro Tag

---

## E-MAIL-ABFRAGEN (eMail_)

### qry_eMail_finden_MA_VA_Zuordnung
- **Funktion:** MA_ID, VA_ID, VADatum_ID, VAStart_ID aus E-Mail-Betreff extrahieren

### qry_Email_finden_Absage
- **Funktion:** Absagen erkennen (Zu_Absage = 0)

### qry_Email_finden_Zusage
- **Funktion:** Zusagen erkennen (Zu_Absage = -1)

### qry_eMail_Update_Absage
- **Funktion:** tbl_MA_VA_Planung Update fuer Absagen

### qry_eMail_Update_Zusage
- **Funktion:** tbl_MA_VA_Planung Update fuer Zusagen

### qry_eMail_Update_Erledigt
- **Funktion:** E-Mails als erledigt markieren

### qry_eMail_Update99_Rest_ohne_Intern
- **Funktion:** E-Mails ohne "Intern:" als Schrott markieren

### qry_eMail_Update90_Sender_Consec
- **Funktion:** CONSEC-eigene E-Mails ignorieren

### qry_eMail_Delete_OldDate
- **Funktion:** Alte E-Mails loeschen

### qry_eMail_Delete_Rest
- **Funktion:** Nicht-Zu/Absagen loeschen

### qry_eMail_Grouping_Zusage
- **Funktion:** Zusagen gruppieren

### qry_eMail_MA_ID_not_found
- **Funktion:** E-Mails ohne MA-Zuordnung

---

## AUSWERTUNGS-ABFRAGEN (Auswertung_)

### qry_Auswertungsgrundlage
- **Funktion:** Basis fuer Auswertungen

### qry_Auswertungsgrundlage_Ist
- **Funktion:** Ist-Auswertung

### qry_Auswertungsgrundlage_Plan
- **Funktion:** Plan-Auswertung

### _Auswertung_qry_Doppelt_Pro_Auftrag
- **Funktion:** Doppelzuordnungen pro Auftrag

### _Auswertung_qry_Doppelt_Pro_Tag
- **Funktion:** Doppelzuordnungen pro Tag

### _Auswertung_Sub_Kundenpreise
- **Funktion:** Kundenpreise-Auswertung

### _Auswertung_Umsatz_Kunde
- **Funktion:** Umsatz pro Kunde

### _Auswerung_Sub_JJJJ / _1 / _Kreuztabelle
- **Funktion:** Jahresauswertungen

---

## RECHNUNGS-ABFRAGEN (Rch_)

### qry_Report_Auftrag_Kopf
- **Funktion:** Rechnungskopf-Report

### qry_Report_Rch_...
- **Funktion:** Diverse Rechnungs-Reports

---

## DUPLIKAT-ABFRAGEN (Doppelt_)

### qry_Doppelt
- **Funktion:** Doppelzuordnungen finden

### qry_Doppelt_1 / _2
- **Funktion:** Doppelzuordnungs-Varianten

### qry_Doppelt_MitZusInfo
- **Funktion:** Doppelzuordnungen mit Zusatzinformationen

---

## KREUZTABELLEN (Kreuztabelle)

### qry_allgemein_Kreuztabelle
- **Funktion:** Allgemeine Kreuztabelle

### qry_DP_Alle_Zt_MA_Kreuztabelle
- **Funktion:** Dienstplan MA-Kreuztabelle

### _Auswerung_Sub_JJJJ_Kreuztabelle
- **Funktion:** Jahres-Kreuztabelle

---

## PLANUNGS-ABFRAGEN (Plan_/EchtNeu_)

### qry_EchtNeu_Plan
- **Funktion:** Neue Planungen

### qry_EchtNeu_Plan_Absage
- **Funktion:** Absagen zu neuen Planungen

### qry_EchtNeu_Plan_Alle
- **Funktion:** Alle neuen Planungen

---

## HILFS-ABFRAGEN (allg_/Adresse_)

### qry_allgemein
- **Funktion:** Allgemeine Hilfsabfrage

### qry_allg_std_anz_ums_kost
- **Funktion:** Stunden, Anzahl, Umsatz, Kosten

### qry_Adresse_create_maennlich / _weiblich
- **Funktion:** Adress-Anrede erstellen

### qry_Adresse_update
- **Funktion:** Adressen aktualisieren

### qry_AlleMonatstage_AKtMon
- **Funktion:** Alle Tage des aktuellen Monats

---

## VERKNUEPFUNGS-TABELLEN-ABFRAGEN

### qrymdbTable
- **Funktion:** Verknuepfte MDB-Tabellen

### qrymdbTable2
- **Funktion:** Verknuepfte Tabellen mit Pfaden

---

## SYSTEM-ABFRAGEN

### qryAlleTage_Default
- **Funktion:** Default-Tage-Abfrage mit Bundesland-Feiertagen
- **Hinweis:** Wird in fAutoexec dynamisch erstellt

---

## ABFRAGEN-KATEGORIEN STATISTIK

| Kategorie | Praefix | Anzahl (ca.) |
|-----------|---------|--------------|
| Dienstplan | qry_DP_ | ~50 |
| MA-Zuordnung | qry_MA_VA_ | ~40 |
| Anzahl/Statistik | qry_Anz_ | ~30 |
| E-Mail | qry_eMail_ | ~15 |
| Auswertung | qry_Auswertung_ | ~10 |
| Rechnung | qry_Rch_, qry_Report_ | ~30 |
| Duplikate | qry_Doppelt_ | ~5 |
| Kreuztabellen | _Kreuztabelle | ~8 |
| Planung | qry_EchtNeu_, qry_Plan_ | ~15 |
| Hilfs/System | qry_allg_, qry_Adresse_ | ~20 |
| Sonstige | diverse | ~340 |

---

## WICHTIGE ABFRAGE-KETTEN

### Dienstplan-Erstellung:
1. qry_MA_VA_Plan_All_AufUeber1a (Basisplanung)
2. qry_MA_VA_Plan_All_AufUeber2_neu (Neue Zuordnungen)
3. qry_MA_VA_Plan_AllAufUeber1 (UNION)
4. qry_Dienstplan (Finale Anzeige)
5. qry_DP_Kreuztabelle (Kalenderansicht)

### E-Mail-Verarbeitung:
1. qry_Email_finden_Absage/Zusage
2. qry_eMail_finden_MA_VA_Zuordnung
3. qry_eMail_Update_Absage/Zusage
4. qry_eMail_Grouping_Zusage
5. qry_eMail_Update_Erledigt

### Auswertungen:
1. qry_Auswertungsgrundlage
2. qry_Auswertungsgrundlage_Plan/Ist
3. Kreuztabellen
4. Reports

---

## PARAMETER-ABFRAGEN

Viele Abfragen verwenden Formular-Referenzen als Parameter:
- `Forms!frm_VA_Auftragstamm!ID` - Aktuelle Auftrags-ID
- `Forms!frm_MA_Mitarbeiterstamm!ID` - Aktuelle MA-ID
- `Forms!frm_DP_Dienstplan_Objekt!StartDatum` - Startdatum
- `Forms!...!cboVADatum` - Ausgewaehltes Datum
