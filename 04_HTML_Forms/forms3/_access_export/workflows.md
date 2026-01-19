# WORKFLOWS - Access Frontend Export

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb

---

## 1. AUFTRAG ANLEGEN (KOMPLETT)

### Ausloeser
- Menu: F2_NeuAuf() in mdl_Menu_Neu.bas
- Button in frm_Menuefuehrung

### Ablauf

#### Schritt 1: Formular oeffnen
```vba
DoCmd.OpenForm "frm_VA_Auftragstamm"
Call Form_frm_VA_Auftragstamm.VAOpen_New
```

#### Schritt 2: Kopfdaten erfassen
- Tabelle: `tbl_VA_Auftragstamm`
- Pflichtfelder:
  - Auftrag (Bezeichnung)
  - Veranstalter_ID (Kunde)
  - Dat_VA_Von, Dat_VA_Bis (Zeitraum)
  - Objekt_ID oder manuelle Adresse

#### Schritt 3: Tage generieren
- Bei Speicherung werden automatisch Eintraege in `tbl_VA_AnzTage` erstellt
- Fuer jeden Tag zwischen Dat_VA_Von und Dat_VA_Bis wird ein Datensatz angelegt
- Felder: VA_ID, VADatum, TVA_Soll, TVA_Ist

#### Schritt 4: Schichten/Startzeiten anlegen
- Tabelle: `tbl_VA_Start`
- Pro Tag (VADatum_ID) koennen mehrere Schichten angelegt werden
- Felder: VA_ID, VADatum_ID, VADatum, VA_Start, VA_Ende, MA_Anzahl

#### Schritt 5: Status setzen
- Veranst_Status_ID = 1 (Offen/Geplant)
- Audit-Felder: Erst_von, Erst_am

### Beteiligte Tabellen
- tbl_VA_Auftragstamm (Kopfdaten)
- tbl_VA_AnzTage (Tage)
- tbl_VA_Start (Schichten)
- tbl_KD_Kundenstamm (Kunde)
- tbl_OB_Objekt (optional: Objekt)

---

## 2. MITARBEITER ZUORDNEN

### Methode A: Direkte Zuordnung

#### Ausloeser
- Im Subformular sub_MA_VA_Zuordnung
- ComboBox zur MA-Auswahl

#### Ablauf
1. MA aus ComboBox waehlen
2. Datensatz in `tbl_MA_VA_Zuordnung` erstellen
3. Felder befuellen:
   - VA_ID, VADatum_ID, VAStart_ID
   - MA_ID
   - MA_Start, MA_Ende (kopiert von Schicht)
   - PosNr (naechste Position)
4. `tbl_VA_AnzTage.TVA_Ist` hochzaehlen
5. `tbl_VA_Start.MA_Anzahl_Ist` hochzaehlen

### Methode B: Schnellauswahl

#### Ausloeser
- Menu: F2_Schnellplan()
- Oeffnet frm_MA_VA_Schnellauswahl

#### Ablauf
1. Auftrag und Datum auswaehlen
2. Liste verfuegbarer MA anzeigen (ztbl_MA_Schnellauswahl)
3. Sortierung: Standard oder nach Entfernung
4. MA per Doppelklick oder Button zuordnen
5. Automatisch Eintrag in `tbl_MA_VA_Zuordnung`

### Methode C: Via E-Mail-Anfrage

Siehe Workflow "E-Mail-Versand (Serien-Mail)"

---

## 3. E-MAIL-VERSAND (SERIEN-MAIL)

### Ausloeser
- Button "Anfragen" in frm_VA_Auftragstamm
- Oder: frm_MA_Serien_eMail_Auftrag

### Ablauf

#### Schritt 1: MA-Auswahl
- Aus `tbl_MA_VA_Planung` oder manuell
- Status_ID = 1 (Geplant)

#### Schritt 2: E-Mail-Erstellung (zmd_Mail.bas)
```vba
Function Anfragen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
    ' MD5 Hash erzeugen fuer Tracking
    MD5 = FnsCalculateMD5(MA_ID & VA_ID & VADatum_ID & Email)

    ' E-Mail erstellen
    check = create_Mail(MA_ID, VA_ID, VADatum_ID, VAStart_ID, 1)

    ' Status auf "Angefragt" setzen
    setze_Angefragt(MA_ID, VA_ID, VADatum_ID, VAStart_ID)

    ' PHP-Datei fuer automatische Antwort erstellen
    create_PHP(MD5, Email, ...)
End Function
```

#### Schritt 3: E-Mail-Versand (mdlOutlook_HTML_Serienemail_SAP.bas)
```vba
Sub xSendMessage(theSubject, theRecipient, html, ...)
    ' Outlook-Objekt erstellen
    Set objOutlook = CreateObject("Outlook.Application")
    Set objMail = objOutlook.CreateItem(0) ' olMailItem

    ' HTML-Body mit CSS setzen
    objMail.HTMLBody = myHTML
    objMail.Subject = theSubject
    objMail.Recipients.Add(theRecipient)

    ' Anzeigen und senden
    objMail.Display
    SendKeys "%s", True  ' Automatisch senden
End Sub
```

#### Schritt 4: Status-Update
- `tbl_MA_VA_Planung.Status_ID = 2` (Angefragt)
- `tbl_MA_VA_Planung.Anfragezeitpunkt = Now()`

### Betreff-Format
```
CONSEC Dienstanfrage - [Wochentag] [Datum] - [Auftrag] - Intern: [VA_ID] - [VADatum_ID] - [VAStart_ID]
```

### Beteiligte Module
- zmd_Mail.bas
- mdlOutlook_HTML_Serienemail_SAP.bas
- mdl_CONSEC_eMail_Autoimport.bas

---

## 4. E-MAIL-IMPORT (ZU-/ABSAGEN)

### Ausloeser
- Timer im Hintergrund
- Manuell: F2_All_eMail_Update()

### Ablauf (mdl_CONSEC_eMail_Autoimport.bas)

#### Schritt 1: E-Mails klassifizieren
```vba
Function All_eMail_Update()
    ' Eintraege ohne "Intern:" als Schrott markieren
    CurrentDb.Execute("qry_eMail_Update99_Rest_ohne_Intern")

    ' CONSEC-eigene E-Mails ignorieren
    CurrentDb.Execute("qry_eMail_Update90_Sender_Consec")

    ' Alte loeschen
    CurrentDb.Execute("qry_eMail_Delete_OldDate")
```

#### Schritt 2: Zu-/Absagen erkennen
```vba
    ' Absage erkennen (Zu_Absage = 0)
    CurrentDb.Execute("qry_Email_finden_Absage")

    ' Zusage erkennen (Zu_Absage = -1)
    CurrentDb.Execute("qry_Email_finden_Zusage")
```

#### Schritt 3: IDs aus Betreff extrahieren
```vba
    ' MA_ID, VA_ID, VADatum_ID, VAStart_ID setzen
    CurrentDb.Execute("qry_eMail_finden_MA_VA_Zuordnung")
```

#### Schritt 4: Tabellen updaten
```vba
    ' tbl_MA_VA_Planung Status setzen
    CurrentDb.Execute("qry_eMail_Update_Absage")  ' Status = 4
    CurrentDb.Execute("qry_eMail_Update_Zusage")  ' Status = 3

    ' tbl_MA_VA_Zuordnung bei Zusage
    All_eMail_tbl_MA_VA_Zuordnung_Merge()
End Function
```

#### Schritt 5: Manuelle Zuordnung (falls noetig)
```vba
Function Manuelle_eMail_MA_Zuordnung()
    ' Falls E-Mails nicht zuordenbar
    DoCmd.OpenForm "frmTop_eMail_MA_ID_NGef"
End Function
```

### Erkennungsmuster
- Zusage: "Zusage", "ja", "bin dabei", "komme"
- Absage: "Absage", "nein", "kann nicht", "verhindert"

---

## 5. DRUCKPROZESSE

### Dienstplan drucken

#### Ausloeser
- Button in frm_DP_Dienstplan_MA oder frm_DP_Dienstplan_Objekt

#### Ablauf
1. Abfrage qry_Dienstplan mit Parametern aufrufen
2. Report oeffnen
3. PDF erstellen oder direkt drucken

### Rechnung drucken

Siehe Workflow "Abrechnungsworkflow"

### Auftragsuebersicht drucken

#### Ablauf
1. frm_auftragsuebersicht_neu filtern
2. Report oeffnen
3. Export als PDF/Excel

---

## 6. ABRECHNUNGSWORKFLOW

### Ausloeser
- Menu: F6_Rch_erstellen() (Rechnung)
- Menu: F6_Ang_erstellen() (Angebot)

### Ablauf

#### Schritt 1: Berechnungsliste oeffnen
```vba
DoCmd.OpenForm "frmTop_Rch_Berechnungsliste"
```

#### Schritt 2: Auftraege auswaehlen
- Filter nach Zeitraum
- Filter nach Kunde
- Filter nach Status (3 = abgeschlossen)

#### Schritt 3: Positionen generieren
- Tabelle: `tbl_Rch_Pos_Auftrag`
- Pro Auftrag werden Positionen aus Zuordnungen berechnet
- Stunden * Kundenpreis

#### Schritt 4: Rechnungskopf erstellen
```vba
Function Update_Rch_Nr(iID As Long) As Long
    ' Naechste Rechnungsnummer holen
    i = TLookup("NummernKreis", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & iID) + 1

    ' Nummernkreis hochzaehlen
    CurrentDb.Execute("UPDATE _tblEigeneFirma_Word_Nummernkreise SET NummernKreis = " & i)

    Update_Rch_Nr = i
End Function
```

#### Schritt 5: Word-Dokument erstellen
- Vorlage aus `_tblEigeneFirma_Word_BriefVorlagen`
- Textmarken befuellen (mdl_Word_Bookmark.bas)
- PDF erstellen

#### Schritt 6: Status updaten
- `tbl_VA_Auftragstamm.Veranst_Status_ID = 4` (Abgerechnet)
- `tbl_VA_Auftragstamm.Rch_Nr`, `Rch_Dat` setzen

### Zahlungsbedingungen (mdl_Rechnungsschreibung.bas)
```vba
Function Zahlbed_Text(ZahlBed_ID, betrag)
    ' "Zahlbar bis [Datum] unter Abzug von [Skonto]% = [Netto]"
End Function
```

---

## 7. MAHNWESEN

### Ausloeser
- Button in frmTop_RechnungsStamm

### Ablauf

#### Schritt 1: Faellige Rechnungen ermitteln
- Rechnungsdatum + Zahlungsziel < Heute
- Status noch nicht "bezahlt"

#### Schritt 2: Mahnstufe bestimmen
```vba
Function fMahnDat(iStufe As Long) As Long
    ' Mahntage aus _tblEigeneFirma lesen
    i = TLookup("Mahn" & iStufe & "Tage", "_tblEigeneFirma", "FirmenID = 1")
    fMahnDat = i
End Function
```

#### Schritt 3: Mahnung erstellen
- Word-Vorlage befuellen
- PDF erstellen
- Per E-Mail oder Post versenden

---

## 8. AUTOSTART-WORKFLOW

### Ausloeser
- AutoExec-Makro beim Oeffnen der Datenbank

### Ablauf (mdlAutoexec.bas)

```vba
Function fAutoexec()
    ' 1. Backend verknuepfen
    Call checkconnectAcc
    ftestdbnamen()

    ' 2. Default-Bundesland-Abfrage erstellen
    strSQL = "SELECT ... FROM _tblAlleTage"
    Call CreateQuery(strSQL, "qryAlleTage_Default")

    ' 3. Properties initialisieren
    Call Set_Priv_Property("prp_StartDatum_Uebersicht", Date)
    Call Set_Priv_Property("prp_Dienstpl_StartDatum", Date)

    ' 4. Pfade je nach Benutzer setzen
    If (atCNames(1) = "Klaus"...) Then
        Call Set_Priv_Property("prp_CONSYS_GrundPfad", ...)
    End If

    ' 5. Login pruefen
    bImmer = TLookup("int_Immer", "_tblEigeneFirma_Mitarbeiter", ...)
    If bImmer Then
        DoCmd.OpenForm "frmTop_Login", , , , , acDialog
    End If

    ' 6. Excel-Vorlagen schreiben
    fExcel_Vorlagen_Schreiben

    ' 7. Hauptformular oeffnen
    DoCmd.OpenForm "frm_va_auftragstamm"
End Function
```

---

## 9. FRONTEND-VERTEILUNG

### Ausloeser
- Manuell: FE_verteilen() in zmd_Funktionen.bas

### Ablauf

```vba
Function FE_verteilen()
    ' 1. Produktiv verbinden
    switchConnectAcc PfadProdLokal & Backend

    ' 2. Alle FEs schliessen (Remote-Befehl)
    CurrentDb.Execute("INSERT INTO ztbl_CloseAll VALUES ('-1','-1')")
    Wait 15

    ' 3. Frontend kopieren zu allen Benutzern
    fso.CopyFile PfadTest & FE, gueni & FE
    fso.CopyFile PfadTest & FE, mel & FE
    ' ... weitere Benutzer

    ' 4. Testumgebung wieder verbinden
    switchConnectAcc PfadTestLokal & Backend
End Function
```

---

## WORKFLOW-ZUSAMMENFASSUNG

| Workflow | Ausloeser | Hauptmodul | Haupttabellen |
|----------|-----------|------------|---------------|
| Auftrag anlegen | F2_NeuAuf | Form_frm_VA_Auftragstamm | tbl_VA_Auftragstamm, tbl_VA_AnzTage, tbl_VA_Start |
| MA zuordnen | Subformular/Schnellauswahl | mdl_frm_MA_VA_Schnellauswahl_Code | tbl_MA_VA_Zuordnung |
| E-Mail senden | Button "Anfragen" | zmd_Mail, mdlOutlook_HTML_Serienemail_SAP | tbl_MA_VA_Planung |
| E-Mail importieren | Timer/F2_All_eMail_Update | mdl_CONSEC_eMail_Autoimport | tbl_eMail_Import, tbl_MA_VA_Planung, tbl_MA_VA_Zuordnung |
| Rechnung erstellen | F6_Rch_erstellen | mdl_Rechnungsschreibung | tbl_Rch_Kopf, tbl_Rch_Pos_Auftrag |
| Autostart | AutoExec | mdlAutoexec | diverse |
| FE verteilen | Manuell | zmd_Funktionen | ztbl_CloseAll |
