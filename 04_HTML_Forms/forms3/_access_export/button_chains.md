# BUTTON-FUNKTIONSKETTEN - Access Frontend Export

Exportiert am: 2026-01-08
Quelle: 0_Consys_FE_Test.accdb

---

## HAUPTFORMULAR: frm_va_Auftragstamm

### Button: "Neuer Auftrag" (VAOpen_New)
**Was passiert bei Klick:**
1. `Form_frm_VA_Auftragstamm.VAOpen_New` wird aufgerufen
2. Neuer Datensatz in `tbl_VA_Auftragstamm` wird angelegt
3. Formular wechselt in Eingabemodus
4. Fokus auf erstes Pflichtfeld

**VBA-Funktion:** VAOpen_New
**Daten geaendert:** tbl_VA_Auftragstamm (neuer Datensatz)

---

### Button: "Anfragen senden"
**Was passiert bei Klick:**
1. Alle geplanten MA (Status_ID=1) werden ermittelt
2. Fuer jeden MA wird `Anfragen()` aus zmd_Mail aufgerufen
3. MD5-Hash wird generiert
4. E-Mail wird via Outlook erstellt und gesendet
5. Status wird auf "Angefragt" (2) gesetzt
6. PHP-Datei fuer automatische Antwort wird erstellt

**VBA-Funktionen:**
- `Anfragen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)` (zmd_Mail)
- `create_Mail()` (zmd_Mail)
- `xSendMessage()` (mdlOutlook_HTML_Serienemail_SAP)
- `setze_Angefragt()` (zmd_Mail)
- `create_PHP()` (zmd_Mail)

**Daten geaendert:**
- tbl_MA_VA_Planung.Status_ID = 2
- tbl_MA_VA_Planung.Anfragezeitpunkt = Now()

---

### Button: "E-Mails importieren"
**Was passiert bei Klick:**
1. `All_eMail_Update()` wird aufgerufen
2. E-Mails werden klassifiziert (Zu/Absage)
3. IDs werden aus Betreff extrahiert
4. tbl_MA_VA_Planung wird aktualisiert
5. Bei Zusagen: tbl_MA_VA_Zuordnung wird erstellt
6. Falls manuelle Zuordnung noetig: Popup oeffnet

**VBA-Funktionen:**
- `All_eMail_Update()` (mdl_CONSEC_eMail_Autoimport)
- `Manuelle_eMail_MA_Zuordnung()` (mdl_CONSEC_eMail_Autoimport)
- `All_eMail_tbl_MA_VA_Zuordnung_Merge()` (mdl_CONSEC_eMail_Autoimport)

**Abfragen ausgefuehrt:**
- qry_eMail_Update99_Rest_ohne_Intern
- qry_Email_finden_Absage
- qry_Email_finden_Zusage
- qry_eMail_finden_MA_VA_Zuordnung
- qry_eMail_Update_Absage
- qry_eMail_Update_Zusage
- qry_eMail_Update_Erledigt

**Daten geaendert:**
- tbl_eMail_Import (diverse Updates)
- tbl_MA_VA_Planung.Status_ID
- tbl_MA_VA_Zuordnung (neue Datensaetze bei Zusage)

---

### Button: "Schicht hinzufuegen" (in sub_VA_Start)
**Was passiert bei Klick:**
1. Neuer Datensatz in `tbl_VA_Start`
2. Zeiten vom vorherigen kopiert oder leer
3. MA_Anzahl = 0

**Daten geaendert:** tbl_VA_Start (neuer Datensatz)

---

### Button: "MA zuordnen" (in sub_MA_VA_Zuordnung)
**Was passiert bei Klick:**
1. Neuer Datensatz in `tbl_MA_VA_Zuordnung`
2. VA_ID, VADatum_ID, VAStart_ID werden uebernommen
3. MA_Start/Ende von Schicht kopiert
4. PosNr = naechste freie Position
5. tbl_VA_AnzTage.TVA_Ist wird hochgezaehlt
6. tbl_VA_Start.MA_Anzahl_Ist wird hochgezaehlt

**Daten geaendert:**
- tbl_MA_VA_Zuordnung (neuer Datensatz)
- tbl_VA_AnzTage.TVA_Ist
- tbl_VA_Start.MA_Anzahl_Ist

---

## HAUPTFORMULAR: frm_MA_Mitarbeiterstamm

### Button: "E-Mail senden"
**Was passiert bei Klick:**
1. Outlook wird gestartet
2. Neue E-Mail mit vorausgefuellter Adresse
3. Template aus Vorlage oder leer

**VBA-Funktionen:**
- `F3_MA_eMail_Std()` (mdl_Menu_Neu)
- `MailOpen(1)` (Form_frmOff_Outlook_aufrufen)

---

### Button: "Dienstplan anzeigen" (Tab pgPlan)
**Was passiert bei Klick:**
1. Tab-Wechsel zu Dienstplan-Ansicht
2. Subformular frmStundenuebersicht wird aktualisiert
3. Filter auf aktuelle MA_ID

**VBA-Funktionen:**
- `F3_MA_Dienstplan()` (mdl_Menu_Neu)
- Forms!frm_MA_Mitarbeiterstamm!pgPlan.SetFocus

---

### Button: "Ausweis erstellen"
**Was passiert bei Klick:**
1. `frm_Ausweis_Create` wird geoeffnet
2. MA-Daten werden geladen
3. Ausweis kann gedruckt werden

**VBA-Funktion:** F7_Ausweisdruck() (mdl_Menu_Neu)

---

## HAUPTFORMULAR: frm_MA_VA_Schnellauswahl

### Button: "Standard-Sortierung"
**Was passiert bei Klick:**
1. Liste wird auf Standard-Sortierung zurueckgesetzt
2. RowSource = "ztbl_MA_Schnellauswahl"

**VBA-Funktion:** `cmdListMA_Standard_Click()` (mdl_frm_MA_VA_Schnellauswahl_Code)

---

### Button: "Nach Entfernung sortieren"
**Was passiert bei Klick:**
1. Objekt_ID des Auftrags wird ermittelt
2. Temporaere Abfragen werden erstellt
3. MA werden nach Entfernung zum Objekt sortiert
4. Liste wird aktualisiert

**VBA-Funktion:** `cmdListMA_Entfernung_Click()` (mdl_frm_MA_VA_Schnellauswahl_Code)

**SQL:**
```sql
SELECT S.ID, S.IstSubunternehmer, S.Name,
       Format(IIf(E.Entf_KM Is Null,999,E.Entf_KM),'0.0') & ' km' AS Std,
       S.Beginn, S.Ende, S.Grund
FROM ztbl_MA_Schnellauswahl AS S
LEFT JOIN ztmp_Entf_Filter AS E ON E.MA_ID = S.ID
ORDER BY IIf(E.Entf_KM Is Null,999,E.Entf_KM), S.Name
```

---

### Doppelklick auf MA in Liste
**Was passiert:**
1. MA wird zum ausgewaehlten Auftrag/Schicht zugeordnet
2. Neuer Datensatz in tbl_MA_VA_Zuordnung
3. Liste wird aktualisiert

---

## HAUPTFORMULAR: frm_DP_Dienstplan_Objekt

### Button: "Vorheriger Monat"
**Was passiert bei Klick:**
1. Startdatum wird um 1 Monat zurueckgesetzt
2. Kreuztabelle wird neu berechnet
3. Anzeige wird aktualisiert

---

### Button: "Naechster Monat"
**Was passiert bei Klick:**
1. Startdatum wird um 1 Monat vorwaerts gesetzt
2. Kreuztabelle wird neu berechnet
3. Anzeige wird aktualisiert

---

### Button: "Drucken"
**Was passiert bei Klick:**
1. Report wird mit aktuellem Filter geoeffnet
2. Druckvorschau oder direkter Druck

---

## POPUP: frmTop_Rch_Berechnungsliste

### Button: "Rechnung erstellen"
**Was passiert bei Klick:**
1. Ausgewaehlte Auftraege werden gesammelt
2. Positionen werden berechnet
3. Rechnungskopf wird in tbl_Rch_Kopf erstellt
4. Naechste Rechnungsnummer wird geholt und hochgezaehlt
5. Word-Vorlage wird geoeffnet und befuellt
6. PDF wird erstellt
7. Auftragsstatus wird auf "Abgerechnet" (4) gesetzt

**VBA-Funktionen:**
- `Update_Rch_Nr()` (mdl_Rechnungsschreibung)
- `Zahlbed_Text()` (mdl_Rechnungsschreibung)
- Word-Textmarken-Funktionen (mdl_Word_Bookmark)

**Daten geaendert:**
- tbl_Rch_Kopf (neuer Datensatz)
- tbl_Rch_Pos_Auftrag (neue Positionen)
- _tblEigeneFirma_Word_Nummernkreise.NummernKreis + 1
- tbl_VA_Auftragstamm.Veranst_Status_ID = 4
- tbl_VA_Auftragstamm.Rch_Nr, Rch_Dat

---

## POPUP: frmTop_MA_ZuAbsage

### Button: "Zusage erfassen"
**Was passiert bei Klick:**
1. Status in tbl_MA_VA_Planung wird auf 3 (Zusage) gesetzt
2. Eintrag in tbl_MA_VA_Zuordnung wird erstellt
3. Formular wird aktualisiert

**Daten geaendert:**
- tbl_MA_VA_Planung.Status_ID = 3
- tbl_MA_VA_Zuordnung (neuer Datensatz)

---

### Button: "Absage erfassen"
**Was passiert bei Klick:**
1. Status in tbl_MA_VA_Planung wird auf 4 (Absage) gesetzt
2. Formular wird aktualisiert

**Daten geaendert:**
- tbl_MA_VA_Planung.Status_ID = 4

---

## MENU-BUTTONS (frm_Menuefuehrung)

| Button | Funktion | Oeffnet |
|--------|----------|---------|
| Tagesuebersicht | F1_Tag() | frm_UE_Uebersicht (Tagesansicht) |
| Wochenuebersicht | F1_Woche() | frm_UE_Uebersicht (Wochenansicht) |
| Monatsuebersicht | F1_Monat() | frm_UE_Uebersicht (Monatsansicht) |
| Dienstplan Objekt | F1_Dienstplan_Obj() | frm_DP_Dienstplan_Objekt |
| Dienstplan MA | F1_Dienstplan_MA() | frm_DP_Dienstplan_MA |
| Neuer Auftrag | F2_NeuAuf() | frm_VA_Auftragstamm (neuer DS) |
| Schnellplanung | F2_Schnellplan() | frm_MA_VA_Schnellauswahl |
| Auftragsverwaltung | F2_Auftragsverwaltung() | frm_VA_Auftragstamm |
| Objektverwaltung | F2_frm_Objekt() | frm_OB_Objekt |
| E-Mail Vorlagen | F2_eMailVorl() | frm_MA_Serien_eMail_Vorlage |
| E-Mails importieren | F2_All_eMail_Update() | Hintergrundfunktion |
| Manuelle Zu/Absage | F2_Manuelle_ZuAbsage() | frmTop_MA_ZuAbsage |
| Mitarbeiterstamm | F3_Mitarbeiter() | frm_MA_Mitarbeiterstamm |
| Kundenstamm | F5_Kundennstammdaten() | frm_KD_Kundenstamm |
| Rechnung erstellen | F6_Rch_erstellen() | frmTop_Rch_Berechnungsliste |
| Angebot erstellen | F6_Ang_erstellen() | frmTop_Rch_Berechnungsliste (Modus 2) |
| Firmenstammdaten | F7_Firmenstammdaten() | frmStamm_EigeneFirma |
| Kalender | F9_Jahreskalender() | _frmHlp_Kalender_Jahr |
| Sysinfo | F9_Sysinfo() | _frmHlp_SysInfo |

---

## NAVIGATIONS-BUTTONS (Standard)

### Erster Datensatz
**VBA:** `DoCmd.GoToRecord , , acFirst`

### Vorheriger Datensatz
**VBA:** `DoCmd.GoToRecord , , acPrevious`

### Naechster Datensatz
**VBA:** `DoCmd.GoToRecord , , acNext`

### Letzter Datensatz
**VBA:** `DoCmd.GoToRecord , , acLast`

### Neuer Datensatz
**VBA:** `DoCmd.GoToRecord , , acNewRec`

### Datensatz loeschen
**VBA:**
```vba
If MsgBox("Wirklich loeschen?", vbYesNo) = vbYes Then
    DoCmd.RunCommand acCmdDeleteRecord
End If
```

### Schliessen
**VBA:** `DoCmd.Close acForm, Me.Name`

---

## WICHTIGE BUTTON-FUNKTIONSKETTEN ZUSAMMENFASSUNG

### Anfrage-Workflow:
```
[Button: Anfragen]
    -> Anfragen()
    -> create_Mail()
    -> xSendMessage()
    -> setze_Angefragt()
    -> create_PHP()
```

### Import-Workflow:
```
[Button: E-Mails importieren]
    -> All_eMail_Update()
    -> qry_Email_finden_Zusage/Absage
    -> qry_eMail_finden_MA_VA_Zuordnung
    -> qry_eMail_Update_Zusage/Absage
    -> All_eMail_tbl_MA_VA_Zuordnung_Merge()
    -> Manuelle_eMail_MA_Zuordnung() (falls noetig)
```

### Rechnungs-Workflow:
```
[Button: Rechnung erstellen]
    -> Positionen sammeln
    -> Update_Rch_Nr()
    -> Zahlbed_Text()
    -> Word-Template befuellen
    -> PDF erstellen
    -> Status = 4 setzen
```
