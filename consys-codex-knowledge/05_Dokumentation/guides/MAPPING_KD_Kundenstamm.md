# MAPPING: frm_KD_Kundenstamm → HTML/React

**Generiert:** 2025-01-23
**Quelle:** `C:\Users\guenther.siegert\Documents\01_ClaudeCode_HTML\exports\forms\frm_KD_Kundenstamm\`

---

## 1. FORMULAR-EIGENSCHAFTEN

### Access-Formular
```
Name: frm_KD_Kundenstamm
Caption: Kundenstammblatt
DefaultView: 0 (Single Form)
RecordSource: SELECT tbl_KD_Kundenstamm.* FROM tbl_KD_Kundenstamm ORDER BY tbl_KD_Kundenstamm.kun_Firma;
Filter: kun_ID = 20727
AllowEdits: Falsch
AllowAdditions: Falsch
AllowDeletions: Falsch
```

### Dimensionen
```
InsideWidth: 23415 Twips → 1638.54 px
InsideHeight: 14595 Twips → 1021.53 px
```

---

## 2. TAB-CONTROL STRUKTUR

**TabControl:** `RegStammKunde` (Left: 3150, Top: 1095, Width: 13935, Height: 10695)

### Tab-Pages:
1. **pgMain** - "Stammdaten"
2. **pgPreise** - "Konditionen"
3. **Auftragsübersicht** - ""
4. **pg_Rch_Kopf** - "Auftragsübersicht"
5. **pg_Ang** - "Angebote"
6. **pgAttach** - "Zusatzdateien"
7. **pgAnsprech** - "Ansprechpartner"
8. **pgBemerk** - "Bemerkungen"

---

## 3. SUBFORMS (7 Stück)

### 3.1 sub_KD_Standardpreise
```json
{
  "Name": "sub_KD_Standardpreise",
  "SourceObject": "sub_KD_Standardpreise",
  "LinkMasterFields": "kun_ID",
  "LinkChildFields": "kun_ID"
}
```
**Eltern-Tab:** pgPreise
**Position:** Left: 3879, Top: 1799, Width: 12255, Height: 9075

### 3.2 sub_KD_Auftragskopf
```json
{
  "Name": "sub_KD_Auftragskopf",
  "SourceObject": "sub_KD_Auftragskopf",
  "LinkMasterFields": "kun_ID",
  "LinkChildFields": "kun_ID"
}
```
**Eltern-Tab:** Auftragsübersicht
**Position:** Left: 3851, Top: 2522, Width: 11963, Height: 4489

### 3.3 sub_KD_Rch_Auftragspos
```json
{
  "Name": "sub_KD_Rch_Auftragspos",
  "SourceObject": "sub_KD_Rch_Auftragspos",
  "LinkMasterFields": "",
  "LinkChildFields": ""
}
```
**Eltern-Tab:** Auftragsübersicht
**Position:** Left: 3855, Top: 7499, Width: 13099, Height: 4058

### 3.4 sub_Rch_Kopf_Ang
```json
{
  "Name": "sub_Rch_Kopf_Ang",
  "SourceObject": "sub_Rch_Kopf_Ang",
  "LinkMasterFields": "kun_ID",
  "LinkChildFields": "kun_ID"
}
```

### 3.5 sub_ZusatzDateien
```json
{
  "Name": "sub_ZusatzDateien",
  "SourceObject": "sub_ZusatzDateien",
  "LinkMasterFields": "kun_ID;TabellenNr",
  "LinkChildFields": "Ueberordnung;TabellenID"
}
```

### 3.6 sub_Ansprechpartner
```json
{
  "Name": "sub_Ansprechpartner",
  "SourceObject": "sub_Ansprechpartner",
  "LinkMasterFields": "kun_Id",
  "LinkChildFields": "kun_Id"
}
```

### 3.7 Menü
```json
{
  "Name": "Menü",
  "SourceObject": "frm_Menuefuehrung",
  "LinkMasterFields": "",
  "LinkChildFields": ""
}
```

---

## 4. CONTROLS (Erste 100 erfasst)

### 4.1 HEADER-BEREICH

| Name | Type | Position (Twips) | Position (px) | Caption/Source | Visible |
|------|------|------------------|---------------|----------------|---------|
| Auto_Kopfzeile0 | Label | 2880,285 | 201.6,19.95 | "Kundenstammblatt" | Wahr |
| lbl_Datum | Label | 23924,566 | 1674.68,39.62 | "22.01.2015" | Wahr |
| lbl_Version | Label | 23867,113 | 1670.69,7.91 | "GPT \| TEST" | Wahr |

### 4.2 NAVIGATION-BUTTONS

| Name | Type | Position | Caption | Event |
|------|------|----------|---------|-------|
| Befehl43 | Button | 7118,312 | btn_erster_Datensatz | - |
| Befehl41 | Button | 7495,315 | btn_Datensatz_zurueck | - |
| Befehl40 | Button | 7872,315 | btn_Datensatz_vor | - |
| Befehl39 | Button | 8249,312 | btn_letzter_Datensatz | - |

### 4.3 ACTION-BUTTONS

| Name | Type | Caption | Event | BackColor |
|------|------|---------|-------|-----------|
| Befehl46 | Button | "Neuer Kunde" | [Event Procedure] | 15918812 |
| mcobtnDelete | Button | "Kunden löschen" | - | 14136213 |
| btnAlle | Button | "Auswahlfilter" | [Event Procedure] | 14136213 |
| btnUmsAuswert | Button | "Umsatzauswertung" | [Event Procedure] | 14136213 |
| btnAuswertung | Button | "Verrechnungssätze" | [Event Procedure] | 14136213 |

### 4.4 RIBBON/DATABASE BUTTONS

| Name | Type | Caption | Visible |
|------|------|---------|---------|
| btnRibbonAus | Button | Befehl179 | Wahr |
| btnRibbonEin | Button | Befehl179 | Wahr |
| btnDaBaEin | Button | Befehl179 | Wahr |
| btnDaBaAus | Button | Befehl179 | Wahr |

### 4.5 SEARCH-CONTROLS

| Name | Type | ControlSource | RowSource | Visible | Event |
|------|------|---------------|-----------|---------|-------|
| cboSuchPLZ | ComboBox | "" | qryHlp_KunPlz | Falsch | AfterUpdate |
| cboSuchOrt | ComboBox | "" | qryHlp_KunOrt | Falsch | AfterUpdate |
| cboKDNrSuche | ComboBox | "" | tbl_KD_Kundenstamm.kun_Id | Falsch | AfterUpdate |

### 4.6 STAMMDATEN (pgMain)

#### Basisdaten
| Name | Type | ControlSource | Label | Position | Visible |
|------|------|---------------|-------|----------|---------|
| kun_IstAktiv | CheckBox | kun_IstAktiv | "Ist aktiv" | 5115,1815 | Wahr |
| kun_Matchcode | TextBox | kun_Matchcode | "Kunden-Kürzel" | 5104,2192 | Wahr |
| kun_strasse | TextBox | kun_strasse | "Straße" | 5127,2905 | Wahr |
| kun_plz | TextBox | kun_plz | "PLZ Ort" | 5127,3231 | Wahr |
| kun_ort | TextBox | kun_ort | "" | 5926,3220 | Wahr |
| kun_LKZ | ComboBox | kun_LKZ | "Land" | 5121,3535 | Wahr |

#### Kontaktdaten
| Name | Type | ControlSource | Label | Visible |
|------|------|---------------|-------|---------|
| kun_telefon | TextBox | kun_telefon | "Telefon" | Wahr |
| kun_mobil | TextBox | kun_mobil | "Mobil" | Wahr |
| kun_email | TextBox | kun_email | "E-Mail" | Wahr |
| kun_URL | TextBox | kun_URL | "Homepage" | Wahr |
| kun_telefax | TextBox | kun_telefax | "Telefax" | Falsch |

#### Bankdaten
| Name | Type | ControlSource | Label | Visible |
|------|------|---------------|-------|---------|
| kun_kreditinstitut | TextBox | kun_kreditinstitut | "Kreditinstitut" | Wahr |
| kun_iban | TextBox | kun_iban | "IBAN" | Wahr |
| kun_bic | TextBox | kun_bic | "BIC" | Wahr |
| kun_ustidnr | TextBox | kun_ustidnr | "UStIDNr." | Wahr |
| kun_Zahlbed | ComboBox | kun_Zahlbed | "Zahlungsbed." | Wahr |
| kun_blz | TextBox | kun_blz | "BLZ" | Falsch |
| kun_kontonummer | TextBox | kun_kontonummer | "KontoNr." | Falsch |

#### Ansprechpartner
| Name | Type | ControlSource | Label | Locked |
|------|------|---------------|-------|--------|
| kun_IDF_PersonID | ComboBox | kun_IDF_PersonID | "Anspr.Partner" | Falsch |
| adr_telefon | TextBox | "" | "Ansp Telefon" | Wahr |
| adr_mobil | TextBox | kun_mobil | "Mobil" | Wahr |
| adr_eMail | TextBox | "" | "Ansp eMail" | Wahr |
| Anschreiben | TextBox | kun_Anschreiben | "Anschreiben" | Wahr |

#### Sonstige
| Name | Type | ControlSource | Visible |
|------|------|---------------|---------|
| kun_BriefKopf | TextBox | kun_BriefKopf | Falsch |
| kun_ans_manuell | CheckBox | kun_ans_manuell | Falsch |
| kun_IstSammelRechnung | CheckBox | kun_IstSammelRechnung | Falsch |
| kun_land_vorwahl | TextBox | kun_land_vorwahl | Falsch |
| kun_geloescht | TextBox | kun_geloescht | Falsch |

### 4.7 UMSATZ-FELDER (Auftragsübersicht)

| Name | Type | Label | Position | Enabled |
|------|------|-------|----------|---------|
| KD_Ges | TextBox | "Alles Netto - Gesamt:" | 6062,1659 | Falsch |
| KD_VJ | TextBox | "Vorjahr:" | 8953,1659 | Falsch |
| KD_LJ | TextBox | "Lfd Jahr:" | 11731,1659 | Falsch |
| KD_LM | TextBox | "Akt Monat:" | 14962,1659 | Falsch |

---

## 5. VBA-EVENTS & FUNKTIONEN

### 5.1 Form-Events
```vba
Private Sub Form_Load()
    ' Maximiere Fenster
    ' Zeige Version
    Me!lbl_Version.Visible = True
    Me!lbl_Version.caption = Get_Priv_Property("prp_V_FE") & " | " & Get_Priv_Property("prp_V_BE")
    DoCmd.Maximize
End Sub

Private Sub Form_Current()
    ' Lade Ansprechpartner-Details
    ' Berechne Umsätze (Gesamt, Vorjahr, Lfd. Jahr, Akt. Monat)
    ' Rufe Kopf_Berech auf bei Tab pg_Rch_Kopf
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
    ' Setze Änderungsdatum und Benutzer
    Me!Aend_am = Now()
    Me!Aend_von = atCNames(1)
End Sub

Private Sub Form_AfterUpdate()
    Me!lst_KD.Requery
End Sub

Private Sub Form_Close()
    Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
End Sub
```

### 5.2 Button-Events

#### Navigation
```vba
Private Sub Befehl46_Click()
    ' Neuer Kunde
    DoCmd.RunCommand acCmdRecordsGoToNew
    i = rstDMax("kun_id", "SELECT tbl_KD_Kundenstamm.kun_ID FROM tbl_KD_Kundenstamm")
    Me!kun_ID = i + 1
    Me!kun_firma.SetFocus
End Sub

Private Sub Befehl38_Click()
    ' Formular schließen
    DoCmd.Close acForm, Me.Name, acSaveNo
End Sub
```

#### Auswertungen
```vba
Private Sub btnAuswertung_Click()
    DoCmd.OpenForm "frm_kundenpreise_gueni"
End Sub

Private Sub btnUmsAuswert_Click()
    DoCmd.OpenForm "frm_Auswertung_Kunde_Jahr"
End Sub
```

#### Zusatzdateien
```vba
Private Sub btnNeuAttach_Click()
    Dim iID As Long
    Dim iTable As Long
    iID = Me!kun_ID
    iTable = Me!TabellenNr
    Call f_btnNeuAttach(iID, iTable)
    Me!sub_ZusatzDateien.Form.Requery
End Sub
```

#### Outlook/Word Integration
```vba
Private Sub btnOutlook_Click()
    DoCmd.OpenForm "frmOff_Outlook aufrufen", , , , , , Me.Name
End Sub

Private Sub btnWord_Click()
    DoCmd.OpenForm "frmOff_WinWord_aufrufen", , , , , , Me.Name
End Sub
```

#### Ribbon/Database
```vba
Private Sub btnRibbonAus_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
End Sub

Private Sub btnRibbonEin_Click()
    DoCmd.ShowToolbar "Ribbon", acToolbarYes
End Sub

Private Sub btnDaBaAus_Click()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End Sub

Private Sub btnDaBaEin_Click()
    DoCmd.SelectObject acTable, , True
End Sub
```

### 5.3 Suche & Filter

#### PLZ-Suche
```vba
Private Sub cboSuchPLZ_AfterUpdate()
    Select Case Me!cboSuchPLZ
        Case "_ALLE"
            Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
        Case Else
            If TCount("kun_ID", "tbl_KD_Kundenstamm", "kun_LKZ = 'D' AND kun_plz = '" & Me!cboSuchPLZ & "'") > 0 Then
                Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm WHERE kun_LKZ = 'D' AND kun_plz = '" & Me!cboSuchPLZ & "' ;"
            Else
                Me.recordSource = "SELECT * FROM tbl_KD_Kundenstamm;"
                Me!cboSuchPLZ = "_ALLE"
                MsgBox "Keine Datensätze vorhanden"
            End If
    End Select
    Me!cboSuchOrt = "_ALLE"
    Me!cboSuchSuchF = "_ALLE"
End Sub
```

#### Ort-Suche
```vba
Private Sub cboSuchOrt_AfterUpdate()
    ' Analog zu cboSuchPLZ_AfterUpdate
End Sub
```

#### Schnellsuche
```vba
Private Sub Textschnell_AfterUpdate()
    Dim i As Integer
    Me.Recordset.FindFirst "kun_ID = " & Me!Textschnell.Column(0)
    ' Markiere in Listbox
    With Me.lst_KD
        For i = .ListCount - 1 To 1 Step -1
            .selected(i) = False
        Next i
        For i = 1 To .ListCount - 1
          If CLng(.Column(0, i)) = Me!Textschnell.Column(0) Then
             .selected(i) = True
             Exit For
          End If
        Next i
    End With
    Me!Textschnell = Null
End Sub
```

#### Kunde-Nr Suche
```vba
Private Sub cboKDNrSuche_AfterUpdate()
    Me.Recordset.FindFirst "kun_ID = " & Nz(Me!cboKDNrSuche.Column(0), 0)
End Sub
```

### 5.4 Ansprechpartner

```vba
Private Sub kun_IDF_PersonID_AfterUpdate()
    Me.Dirty = True
    Me!adr_telefon = Me!kun_IDF_PersonID.Column(1)
    Me!adr_mobil = Me!kun_IDF_PersonID.Column(2)
    Me!Anschreiben = Me!kun_IDF_PersonID.Column(3)
    Me!adr_eMail = Me!kun_IDF_PersonID.Column(4)
End Sub

Private Sub btnPersonUebernehmen_Click()
    Dim strSQL As String
    If Len(Trim(Nz(Me!cboPerson))) > 0 Then
        strSQL = "INSERT INTO _tbl_AdrZuord ( Adrzuo_TabellenNr, Adrzuo_Stamm_ID, Adrzuo_Adr_ID )"
        strSQL = strSQL & " SELECT " & Me!TabellenNr & " AS Ausdr1, " & Me!kun_ID & " AS Ausdr2, " & Me!cboPerson & " AS Ausdr3"
        strSQL = strSQL & " FROM _tblHilfLfdNr WHERE ((([_tblHilfLfdNr].Feld1)=1));"
        CurrentDb.Execute strSQL
        Me!cboPerson = Nothing
        Me!sub_Ansprechpartner.Form.Requery
    End If
End Sub
```

### 5.5 Tab-Change Event

```vba
Private Sub RegStammKunde_Change()
    Dim i As Long
    i = Me!RegStammKunde
    Select Case Me!RegStammKunde.Pages(i).Name
      Case "pgMain"
        ' Requery Formular
        Application.Echo False
        j = Me!kun_ID
        Me.Requery
        Me!kun_ID.SetFocus
        DoCmd.FindRecord j, acStart
        Application.Echo True
        Me.Repaint
      Case "pgBemerk"
        ' Fokus auf Memo
        Me!kun_memo.SetFocus
        Me!kun_memo.SelStart = Len("" & Me!kun_memo)
      Case "pg_Rch_Kopf"
        ' Berechne Auftragskopf
        Call Kopf_Berech
      Case Else
    End Select
End Sub
```

### 5.6 Umsatzberechnung

```vba
Public Function Kopf_Berech()
    ' Berechnet Umsätze für 3 Zeiträume:
    ' 1 = Gesamt
    ' 2 = Letzte 90 Tage
    ' 3 = Letzte 30 Tage

    For i = 1 To 3
        Me("AufAnz" & i) = Nz(TCount("*", "tbl_VA_Auftragstamm", strWHEREAuf(i)), 0)
        Me("PersGes" & i) = Nz(TCount("*", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", strWhere(i)), 0)
        Me("StdGes" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", strWhere(i)), 0)
        Me("UmsGes" & i) = Nz(TSum("NettoBetrag", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Netto", strWhere(i)), 0)
        Me("Std5" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 5 AND " & strWhere(i)), 0)
        Me("Std6" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 6 AND " & strWhere(i)), 0)
        Me("Std7" & i) = Nz(TSum("MA_Brutto_Std", "qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu", "Wochtg = 7 AND " & strWhere(i)), 0)
        ' ... (weitere Berechnungen)
    Next i
End Function
```

### 5.7 Standardleistungen

```vba
Function Standardleistungen_anlegen(kun_ID As Integer)
    ' Legt automatisch Standardpreise an:
    ' - Sicherheitspersonal (ID=1)
    ' - Leitungspersonal (ID=3)
    ' - Fahrtkosten (ID=4)
    ' - Sonstiges (ID=5)
    ' - Nachtzuschlag (ID=11)
    ' - Sonntagszuschlag (ID=12)
    ' - Feiertagszuschlag (ID=13)

    If Me.RegStammKunde = 1 Then
        WHERE = "kun_ID = " & kun_ID & " AND Preisart_ID = "
        sql = "INSERT INTO " & SPREISE & " (kun_ID, Preisart_ID) VALUES (" & kun_ID & ", "

        If Nz(TLookup("ID", SPREISE, WHERE & "1"), 0) = 0 Then CurrentDb.Execute sql & "1)"
        ' ... (weitere Preisarten)

        Me.sub_KD_Standardpreise.Requery
    End If
End Function
```

---

## 6. RECORDSOURCE & QUERIES

### Main RecordSource
```sql
SELECT tbl_KD_Kundenstamm.*
FROM tbl_KD_Kundenstamm
ORDER BY tbl_KD_Kundenstamm.kun_Firma;
```

### Filter
```
kun_ID = 20727
```

### Verwendete Queries
- `qryHlp_KunPlz` - PLZ-Dropdown
- `qryHlp_KunOrt` - Ort-Dropdown
- `qryAdrKundZuo2` - Ansprechpartner-Dropdown
- `qry_KD_Auftragskopf` - Umsatzberechnungen
- `qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Neu` - Stunden pro Tag
- `qry_Rch_Hlp_Stunden_Ges_Pro_Tag_Netto` - Netto-Umsatz

---

## 7. DATENBANKFELDER (tbl_KD_Kundenstamm)

### Primärschlüssel
- `kun_ID` (Autonummer)

### Stammdaten
- `kun_Firma` (Text)
- `kun_Matchcode` (Text)
- `kun_bezeichnung` (Text)
- `kun_IstAktiv` (Boolean)

### Adressdaten
- `kun_strasse` (Text)
- `kun_plz` (Text)
- `kun_ort` (Text)
- `kun_LKZ` (Text)
- `kun_land_vorwahl` (Text)

### Kontaktdaten
- `kun_telefon` (Text)
- `kun_telefax` (Text)
- `kun_mobil` (Text)
- `kun_email` (Text)
- `kun_URL` (Text)

### Bankdaten
- `kun_kreditinstitut` (Text)
- `kun_blz` (Text)
- `kun_kontonummer` (Text)
- `kun_iban` (Text)
- `kun_bic` (Text)
- `kun_ustidnr` (Text)

### Geschäftsdaten
- `kun_Zahlbed` (Number)
- `kun_IstSammelRechnung` (Boolean)
- `kun_Sortfeld` (Text)

### Ansprechpartner
- `kun_IDF_PersonID` (Number)
- `kun_Anschreiben` (Text)
- `kun_BriefKopf` (Memo)
- `kun_ans_manuell` (Boolean)

### Metadaten
- `Aend_am` (DateTime)
- `Aend_von` (Text)
- `Erstellt_am` (DateTime)
- `Erstellt_von` (Text)
- `kun_geloescht` (Text)

### Zusatzdaten
- `TabellenNr` (Number) - Für Zuordnungen
- `kun_memo` (Memo) - Bemerkungen

---

## 8. UMSETZUNG REACT/WEB

### 8.1 Komponenten-Struktur
```
KundenstammForm.jsx (Main)
├── AccessControl.jsx (Controls rendern)
├── TabControl.jsx (Tab-Seiten)
├── SubformRenderer.jsx (Subforms einbetten)
└── lib/
    ├── twipsConverter.js
    ├── colorConverter.js
    ├── fontConverter.js
    └── jsonParser.js
```

### 8.2 API-Endpoints (Backend)
```
GET    /api/kunden           - Liste aller Kunden
GET    /api/kunden/:id       - Einzelner Kunde
POST   /api/kunden           - Neuer Kunde
PUT    /api/kunden/:id       - Kunde aktualisieren
DELETE /api/kunden/:id       - Kunde löschen
GET    /api/kunden/:id/umsatz - Umsatzstatistiken
```

### 8.3 Event-Portierung

| Access-Event | React-Event | Umsetzung |
|--------------|-------------|-----------|
| Form_Load | useEffect([], ...) | Initial-Load |
| Form_Current | useEffect([kundenId], ...) | Bei ID-Wechsel |
| Button_Click | onClick={...} | Button Handler |
| AfterUpdate | onChange={...} | Input Handler |
| BeforeUpdate | onBlur={...} | Validation |

### 8.4 State-Management
```javascript
const [kundenId, setKundenId] = useState(20727);
const [kundenData, setKundenData] = useState(null);
const [activeTab, setActiveTab] = useState(0);
const [umsatzData, setUmsatzData] = useState({
  ges: 0, vj: 0, lj: 0, lm: 0
});
```

---

## 9. OFFENE FRAGEN / TODOS

- [ ] Vollständige Control-Liste (nur 100 von ~194 erfasst)
- [ ] VBA-Funktionen TCount, TSum, TLookup portieren
- [ ] Subform-Implementierungen checken
- [ ] Dropdown-Queries implementieren
- [ ] PDF-Funktionen (fReadDoc)
- [ ] Outlook/Word-Integration
- [ ] Listbox lst_KD implementieren
- [ ] Memo-Feld kun_memo mit Editor
- [ ] Standardleistungen Auto-Anlage

---

## 10. REFERENZEN

- **Mitarbeiterstamm:** `web/src/components/MitarbeiterstammForm.jsx` (als Vorlage)
- **Access-Export:** `exports/forms/frm_KD_Kundenstamm/`
- **VBA-Code:** `exports/vba/forms/Form_frm_KD_Kundenstamm.bas`
