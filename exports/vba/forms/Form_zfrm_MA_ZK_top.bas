VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_MA_ZK_top"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Zeitkonten nach Auswahl exportieren
Private Sub btnExportLex_Click()

Dim sql         As String
Dim rs          As Recordset
Dim ids         As String
Dim qdf         As QueryDef
Dim tbl         As String
Dim ABF         As String
Dim abfexp      As String
Dim qryTmp      As String
Dim WHERE       As String
Dim anstArt     As String
Dim AnstArt_ID  As Long
Dim Jahr        As Integer
Dim Monat       As Integer

    tbl = "ztbl_ZK_Stunden"
    ABF = "zqry_ZK_Stunden_zusatz"
    abfexp = "zqry_ZK_Stunden_export"
    qryTmp = "temp"
    AnstArt_ID = Nz(Me.cboAnstArt.Column(0), 0)
    anstArt = Nz(Me.cboAnstArt.Column(1), 0)
    Monat = Me.RegZK
    Jahr = Me.cboJahr
    
    If Not IsInitial(AnstArt_ID) Then
    
        'IDs der zu exportierenden Einzelsätze ermitteln
        WHERE = "Anstellungsart_ID = " & AnstArt_ID & " AND Jahr = " & Jahr & " AND (Monat = " & Monat & " OR Monat = " & Monat - 1 & ")"
        sql = "SELECT ID FROM " & ABF & " WHERE " & WHERE & " AND exportieren = TRUE AND exportiert = FALSE"
        Set rs = CurrentDb.OpenRecordset(sql, 8)
        Do While Not rs.EOF
            ids = ids & rs.fields(0) & ","
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
        
        If Len(ids) = 0 Then
            MsgBox "Nichts zu exportieren!", vbCritical
            GoTo Ende
        Else
            ids = Left(ids, Len(ids) - 1)
        End If
        
        sql = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert, Stundensatz, Währung, Name FROM " & abfexp & " WHERE " & WHERE
        'SQL = "SELECT Jahr, Monat, LEXWare_ID, Lohnartnummer, Wert FROM " & abf & " WHERE " & where
        
        If queryExists(qryTmp) Then DoCmd.DeleteObject acQuery, qryTmp
        
        Set qdf = CurrentDb.CreateQueryDef(qryTmp, sql)
        
        'DoCmd.SetWarnings False
        
        'DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE", qrytmp, PfadPlanungAktuell & "A  - Lexware Datenträger\Lexware_Import.txt"
        DoCmd.TransferText acExportDelim, "EXPORT_TXT_LEXWARE_FULL_SPALTEN", qryTmp, PfadPlanungAktuell & "A  - Lexware Datenträger\" & Jahr & "_" & Monat & "_" & anstArt & ".txt"
        
        'DoCmd.SetWarnings True
        
        'Einzelsätze als exportiert markieren
        WHERE = "ID in (" & ids & ")"
        CurrentDb.Execute "UPDATE " & tbl & " SET exportiert = TRUE WHERE " & WHERE
        
        MsgBox "Zeitkonten " & anstArt & " " & Jahr & " " & Monat & " wurden exportiert."
        
    Else
        MsgBox "Bitte Anstellungsart auswählen!", vbCritical
              
    End If
    
     
Ende:
    Me.btnExportLex.Enabled = False

End Sub

'Zeitkonten (Delta) fortschreiben
Private Sub btnGetZKData_Click()

Dim AnstArt_ID  As Integer
Dim Monat       As Integer
Dim Jahr        As Integer

    AnstArt_ID = Nz(Me.cboAnstArt.Column(0), 0)
    Monat = Me.RegZK
    Jahr = Me.cboJahr
    
    If AnstArt_ID = 3 Or AnstArt_ID = 5 Then
        Call ermittle_ZK_Daten(Jahr, Monat - 1, , AnstArt_ID) 'Vormonat
        Call ermittle_ZK_Daten(Jahr, Monat, , AnstArt_ID)     'Akuteller Monat
        Call filtern_MA
        Me.btnExportLex.Enabled = True
    Else
        MsgBox "Fortschreibung der Zeitkonten nur für Festangestellte oder Minijobber (Anstellungsart 3 oder 5) möglich!", vbCritical
    End If
    
End Sub

'Haupform öffnen
Private Sub Form_Open(Cancel As Integer)
    
    'Aktuelles Jahr
    Me.cboJahr = Year(Now)
    
    'Zeitkonto aktueller Monat selektieren
    Me.RegZK.Pages(Month(Now)).SetFocus
    
End Sub

'Auswahl Jahr
Private Sub cboJahr_AfterUpdate()

Dim MA_ID As Integer

    MA_ID = Nz(Me.cboMA.Column(0), 0)
   
    'Monat JAN - DEZ
    If Me.RegZK >= 1 And Me.RegZK <= 12 Then
        Call filtern_MA
    Else
        'MsgBox "Bitte einzelnen Mitarbeiter auswählen!"
    End If

End Sub


'Registerauswahl - Filtern nach Monat
Private Sub RegZK_Change()
    
Dim MA_ID As Integer

    MA_ID = Nz(Me.cboMA.Column(0), 0)
   
    'Monat JAN - DEZ
    If Me.RegZK >= 1 And Me.RegZK <= 12 Then

        Me.Controls("Sub_MA_ZK_" & Me.RegZK).Form.Controls("lbUrlaubMon").caption = "Urlaub " & Monat_lang(RegZK)
        
        Call filtern_MA
        
    Else
        'MsgBox "Bitte einzelnen Mitarbeiter auswählen!"
        
    End If

''   ToDo nach Register
'    Select Case Me.RegZK
'        Case 1
'        Case 2
'        Case 3
'        Case 4
'        Case 5
'        Case 6
'        Case 7
'        Case 8
'        Case 9
'        Case 10
'        Case 11
'        Case 12
'    End Select

End Sub

Private Sub cboAnstArt_BeforeUpdate(Cancel As Integer)

    'Mitarbeiter raus
    Me.cboMA = Null
    Call filtern_MA
    
    'Überschrift Zeitkonto
    Me.Controls("Sub_MA_ZK_" & RegZK).Form.Controls("lb_ZK_Header").caption = "ZEITKONTO  " & Nz(Me.cboMA.Column(0), " ") & " " & Nz(Me.cboMA.Column(1), " - - - ")
    
    'AnzeigeZeitkonto
    Me.Controls("Sub_MA_ZK_" & RegZK).Form.Controls("zsub_MA_ZK_Daten").Form.Requery

End Sub

Private Sub cboMA_BeforeUpdate(Cancel As Integer)

    Me.cboAnstArt = Null
    
End Sub

'Filtern nach Anstellungsart
Private Sub cboAnstArt_AfterUpdate()

    If Not IsNull(Me.cboAnstArt) Then
        Me.cboMA = Null
        Call filtern_MA
    End If
       
    Select Case Me.cboAnstArt.Column(0)
        Case 3
            Me.btnGetZKData.Enabled = True
        Case 5
            Me.btnGetZKData.Enabled = True
        Case Else
            Me.btnGetZKData.Enabled = False
    End Select
    
End Sub

'Filtern nach Mitarbeiter
Private Sub cboMA_AfterUpdate()

    'Mitarbeiter gewählt
    If Nz(Me.cboMA.Column(0), 0) <> 0 Then
        'Monat JAN - DEZ
        If Me.RegZK >= 1 And Me.RegZK <= 12 Then
            Call filtern_MA
            'Fortschreibung nach Anstellungsart deaktivieren
            Me.btnGetZKData.Enabled = False
        End If
    End If
       
End Sub

'Filter nach Mitarbeiter
Public Function filtern_MA()
 
Dim MA_ID   As Long
Dim Monat   As Integer
Dim Jahr    As Integer
Dim filter  As String
Dim Anst_ID As Integer
'Dim maxStd  As Integer
'Dim istStd  As Integer

    Anst_ID = Nz(Me.cboAnstArt.Column(0), 0)
    MA_ID = Nz(Me.cboMA.Column(0), 0)
    
    Monat = Me.RegZK
    Jahr = Me.cboJahr
    
    Me.Painting = False
    
    'Mitarbeiter
    If MA_ID <> 0 And Monat >= 1 And Monat <= 12 Then
        Me.Controls("Sub_MA_ZK_" & RegZK).Form.Controls("zsub_MA_ZK_Daten").Form.Painting = False
        'Anstellungsart raus
        Me.cboAnstArt = Null
        Me.btnGetZKData.Enabled = False
        
        'Zeitkonto für MA aktualisieren
        Call ermittle_ZK_Daten(Jahr, Monat, MA_ID)
        
        'Stunden in Folgemonat schieben
        'maxStd = TLookup("StundenZahlMax", MASTAMM, "ID = " & MA_ID)
        'istStd = TLookup("StundenZahlMax", MASTAMM, "ID = " & MA_ID)
        
        'filtern
        filter = "ZK_MA_ID = " & MA_ID
        
        'Überschrift
        Me.Controls("Sub_MA_ZK_" & RegZK).Form.Controls("lb_ZK_Header").caption = "ZEITKONTO  " & Nz(Me.cboMA.Column(0), " ") & " " & Nz(Me.cboMA.Column(1), " - - - ")
        
        'Zeitraum anpassen
        Call create_Tage_Zeitraum(MA_ID, Jahr, Monat)
        
        'Filter anwenden
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("zsub_MA_ZK_Daten").Form.filter = filter
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("zsub_MA_ZK_Daten").Form.FilterOn = True
        
        'Anzeige auffrischen
        Call refresh_data
        Me.Controls("Sub_MA_ZK_" & RegZK).Form.Controls("zsub_MA_ZK_Daten").Form.Requery
        Me.Controls("Sub_MA_ZK_" & RegZK).Form.Controls("zsub_MA_ZK_Daten").Form.Painting = True
        
        'Felder für Zeitkonto berechnen
        Call calculate_ZK_fields
        
    Else
        'Zeitraum entfernen
        CurrentDb.Execute "DELETE * FROM [ztbl_ZK_Tage_Zeitraum]"
        'Anzeige entfernen
        CurrentDb.Execute "DELETE * FROM [ztbl_ZK_Daten]"
        
    End If
    
    Me.Painting = True
    
End Function


'Daten für Anzeige in ztbl_ZK_Daten übertragen
Function refresh_data()

Dim tbl As String
Dim ABF As String
Dim sql As String

    ABF = "zqry_ZK_Daten_Stunden"
    tbl = "ztbl_ZK_Daten"

    sql = "DELETE * FROM " & tbl
    CurrentDb.Execute sql

    sql = "INSERT INTO " & tbl & " SELECT * FROM " & ABF
    CurrentDb.Execute sql
    
End Function


'Felder für Zeitkonto berechnen
Function calculate_ZK_fields()

Dim MA_ID           As Long
Dim Monat           As Integer
Dim Jahr            As Integer
Dim qAnzeige        As String
Dim qStunden        As String
Dim qDaten          As String
Dim filter          As String
Dim UrlaubGesamt    As Integer
Dim UrlaubAusVJ     As Integer
Dim UrlaubGenommen  As Integer
Dim Lohnart_ID_MA   As Integer
Dim Lohn_Eur        As Currency
Dim PersZulage_Eur  As Currency
Dim Urlaub_Eur      As Currency
Dim Krank_Eur       As Currency
Dim Brutto_eur      As Currency
Dim Zuschlaege_Eur  As Currency
Dim Reisekost_Eur   As Currency
Dim Lohnsteuer_Eur  As Currency
Dim Sozialvers_Eur  As Currency
Dim Netto_Eur       As Currency
Dim Netto_ZuAb_Eur  As Currency
Dim RL34A_Eur       As Currency
Dim StdGes          As Double
Dim StdUrlaub       As Double
Dim StdKrank        As Double
Dim StdVorMon       As Double
Dim StdFolgeMon     As Double
Dim StdVerschoben   As Double
Dim expStdGesamt    As Double 'exportierte Stunden gearbeitet Normal (Netto!)
Dim expStdUrlaub    As Double 'exportierte Stunden Urlaub (Brutto! -> weil errechnet aus Nettostunden!)
Dim expStdKrank     As Double 'exportierte Stunden Krank (Brutto! -> weil errechnet aus Nettostunden!)
Dim Vormonat        As Integer
Dim JahrVormonat    As Integer
Dim NAbgerVormonat  As Double
Dim KorrVormonat    As Double



    MA_ID = Nz(Me.cboMA.Column(0), 0)
    Monat = Me.RegZK
    Jahr = Me.cboJahr
    qAnzeige = "zqry_ZK_Daten_Stunden"
    qStunden = "zqry_ZK_Stunden_Zusatz"
    qDaten = "zqry_ZK_Daten"
    filter = "MA_ID = " & MA_ID & " AND Jahr = " & Jahr & " AND Monat = " & Monat
    
    If Monat <> 12 Then
        Vormonat = Monat - 1
        JahrVormonat = Jahr
    Else
        Vormonat = 1
        JahrVormonat = Jahr - 1
    End If
    
    'URLAUB
    UrlaubAusVJ = Nz(TLookup("Resturl_Vorjahr", MASTAMM, "ID = " & MA_ID), 0)
    UrlaubGesamt = Urlaubsanspruch(MA_ID) + UrlaubAusVJ
    UrlaubGenommen = Nz(TCount("*", qStunden, "MA_ID = " & MA_ID & " AND Jahr = " & Jahr & " AND Monat <= " & Monat & " AND [Lohnart_ID] = 27"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txUrlaubMA") = UrlaubGesamt
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txUrlaubMon") = Nz(TCount("*", qStunden, filter & " AND [Lohnart_ID] = 27"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txUrlaubGen") = UrlaubGenommen
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txUrlaubRest") = Nz(UrlaubGesamt - UrlaubGenommen, 0)
    
    'LOHNABRECHNUNG
    Lohnart_ID_MA = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
    'Bruttolohn (aus NETTOSTUNDEN!)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("lbLohn").caption = Nz(TLookup("Bezeichnung", LOHNARTEN, "ID = " & Lohnart_ID_MA), "Keine Lohnart MAStamm!")
    Lohn_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Bezeichnung_kurz] = 'Normal'"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txLohn") = Lohn_Eur
    'persönliche Zulage (brutto oder netto?)
    PersZulage_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Bezeichnung_kurz] = 'Zulage'"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txZulage") = PersZulage_Eur
    'Urlaub (brutto!)
    Urlaub_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Bezeichnung_kurz] = 'Urlaub'"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txUrlaubEuro") = Urlaub_Eur
    'Lohnfortzahlung Krankheit (brutto!)
    Krank_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Bezeichnung_kurz] = 'Krank'"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txKrankEuro") = Krank_Eur
    'Brutto EUR
    Brutto_eur = Lohn_Eur + PersZulage_Eur + Urlaub_Eur + Krank_Eur
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txBrutto") = Brutto_eur
    'Zuschläge gesamt (aus NETTOSTUNDEN!)
    Zuschlaege_Eur = Nz(TSum("Wert", qStunden, filter & " AND ([Bezeichnung_kurz] = 'Nacht' OR [Bezeichnung_kurz] = 'Sonntag' OR " & _
        "[Bezeichnung_kurz] = 'SonntagNacht' OR [Bezeichnung_kurz] = 'Feiertag' OR [Bezeichnung_kurz] = 'FeiertagNacht')"), 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txZuschlaege") = Zuschlaege_Eur
    'Gesamtbrutto EUR
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txGesamt") = Brutto_eur + Zuschlaege_Eur
    'Lohnsteuer
    Lohnsteuer_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 57"))
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txLohnsteuer") = Lohnsteuer_Eur
    'Sozialversicherung
    Sozialvers_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 58"))
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txSozVers") = Sozialvers_Eur
    'Nettolohn
    Netto_Eur = Brutto_eur + Zuschlaege_Eur - Abs(Lohnsteuer_Eur) - Abs(Sozialvers_Eur)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txNetto") = Netto_Eur
    'Nettobe- & -abzüge
    Reisekost_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Bezeichnung_kurz] = 'Reisekosten'"), 0)
    RL34A_Eur = Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 40"))
    Netto_ZuAb_Eur = Reisekost_Eur + RL34A_Eur
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txNettoBeAb") = Netto_ZuAb_Eur
    'Auszahlsumme
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txAuszahlsumme") = Netto_Eur + Netto_ZuAb_Eur
    'Übertrag Folgemonat
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txFolgemonat") = Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 55"))
    
    'Abzüge
    
    
    
    'Stundenkorrekturen
    
    
    'STUNDEN ALLGEMEIN (Korrekturen immer Netto!!!)
    'Gesamtstunden
    StdGes = Replace(Nz(TSum("AZ", qDaten, filter & " AND [Korr_ID] Is Null"), 0), "#Fehler", 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdGesamt") = StdGes
    'Stunden Urlaub (brutto!)
    StdUrlaub = Replace(Nz(TSum("Anz_Std", qStunden, filter & " AND [Lohnart_ID] = 27"), 0), "#Fehler", 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdUrlaub") = StdUrlaub
    'Stunden Krank (brutto!)
    StdKrank = Replace(Nz(TSum("Anz_Std", qStunden, filter & " AND [Lohnart_ID] = 28"), 0), "#Fehler", 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdKrank") = StdKrank
    'Stunden Zwischensumme 1
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdZwischensumme1") = StdGes + StdUrlaub + StdKrank
    'Stunden aus Vormonat
    StdVorMon = Replace(Nz(TSum("Anz_Std_Netto", qStunden, filter & " AND [Lohnart_ID] = 54"), 0), "#Fehler", 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdAusVormonat") = StdVorMon
    'Stunden Zwischensumme 2
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdZwischensumme2") = StdGes + StdUrlaub + StdKrank + StdVorMon
    'Stunden in Folgemonat
    StdFolgeMon = Replace(Nz(TSum("Anz_Std_Netto", qStunden, filter & " AND [Lohnart_ID] = 55"), 0), "#Fehler", 0) '-> negativ!
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdInFolgemonat") = StdFolgeMon
    'Stunden verschoben
    StdVerschoben = Replace(Nz(TSum("Anz_Std_Netto", qStunden, filter & " AND [Lohnart_ID] = 56"), 0), "#Fehler", 0) '-> positiv oder negativ!
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdVerschoben") = StdVerschoben
    'Stunden Endsumme
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("lbStdEndSum").caption = "Summe " & Monat_lang(Monat)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdendSum") = StdGes + StdUrlaub + StdKrank + StdVorMon + StdFolgeMon + StdVerschoben
    'Stunden abgerechnet (gesamt netto, Urlaub + Krank brutto!)
    expStdGesamt = Replace(Nz(TSum("AZ", qDaten, filter & " AND [exportiert] = TRUE"), 0), "#Fehler", 0)
    expStdUrlaub = Replace(Nz(TSum("Anz_Std", qStunden, filter & " AND [Lohnart_ID] = 27 AND [exportiert] = TRUE"), 0), "#Fehler", 0)
    expStdKrank = Replace(Nz(TSum("Anz_Std", qStunden, filter & " AND [Lohnart_ID] = 28 AND [exportiert] = TRUE"), 0), "#Fehler", 0)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdAbgerechnet") = Nz(TSum("Anz_Std_netto", qStunden, filter & " AND [exportiert] = TRUE"), 0)
    
    
    'STUNDEN ZUSCHLÄGE (Netto!)
    'Stunden Nacht
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdNacht") = Replace(Nz(TSum("Nacht", qAnzeige, filter), 0), "#Fehler", 0) * 0.91
    'Stunden Sonntag
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdSonntag") = Replace(Nz(TSum("Sonntag", qAnzeige, filter), 0), "#Fehler", 0) * 0.91
    'Stunden Sonntag Nacht
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdSoNacht") = Replace(Nz(TSum("SonntagNacht", qAnzeige, filter), 0), "#Fehler", 0) * 0.91
    'Stunden Feiertag
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdFeiertag") = Replace(Nz(TSum("Feiertag", qAnzeige, filter), 0), "#Fehler", 0) * 0.91
    'Stunden Feiertag Nacht
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txStdFeierNacht") = Replace(Nz(TSum("FeiertagNacht", qAnzeige, filter), 0), "#Fehler", 0) * 0.91
    'Stunden nicht abgerechnet
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txNAbger") = Replace(Nz(TSum("Normal", qAnzeige, filter & " AND [exportiert] = FALSE"), 0), "#Fehler", 0) * 0.91
    'Stunden nicht abgerechnet Vormonat
    NAbgerVormonat = Replace(Nz(TSum("AnzStdNetto", "zqry_zk_Stunden_Nicht_Abgerechnet", "MA_ID = " & MA_ID & " AND Jahr = " & JahrVormonat & " AND Monat = " & Vormonat), 0), "#Fehler", 0)
    'Korrekturen Vormonat
    KorrVormonat = Replace(Nz(TSum("Anz_Std", "ztbl_MA_ZK_Korrekturen", "MA_ID = " & MA_ID & " AND Jahr = " & JahrVormonat & " AND Monat = " & Vormonat), 0), "#Fehler", 0)
    'Anzeige nicht abgerechnet
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txNAbgerVormon") = NAbgerVormonat + KorrVormonat
        
    
    'Auszahlung / Übertrag Stunden

    
    

       
       
    'Auszahlung / Übertrag €

    
    
    'Abzüge gesamt
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txAbzuege") = Nz(Abs(TSum("Wert", qStunden, filter & " AND [Wert] < 0")), 0)
        
    '€ ausbezahlt (Gesamt - IHK Rücklage)
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txAusbezahlt") = Nz(TSum("Wert", qStunden, filter & " AND [exportiert] = TRUE"))
    
    '€ aus Vormonat
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txAusVormonat") = Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 54"), 0)
    
    '€ in Folgemonat
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txInFolgemonat") = Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 55"), 0)
    
    'Kein 34a?
    If TLookup("Hat_keine_34a", MASTAMM, "ID = " & MA_ID) = True Then
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("lbIHKRL").Visible = True
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txIHKRL").Visible = True
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("lbSummeIHKRL").Visible = True
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txSummeIHKRL").Visible = True
        'IHK Rücklage (10% vom Gesamtlohn, wenn kein 34A)
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txIHKRL") = Abs(RL34A_Eur)
        'Summe IHK Rücklage  ' AND [exportiert] = TRUE" ???
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txSummeIHKRL") = Abs(Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 40"), 0))
        
    Else
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("lbIHKRL").Visible = False
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txIHKRL").Visible = False
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("lbSummeIHKRL").Visible = False
        Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txSummeIHKRL").Visible = False
        
    End If
    
    'Summe Arbeitgeberdarlehen
    Me.Controls("Sub_MA_ZK_" & Monat).Form.Controls("txSummeAGDarlehen") = Abs(Nz(TSum("Wert", qStunden, filter & " AND [Lohnart_ID] = 41"), 0))


    
End Function


Sub list_ufos()

Dim i As Integer

    For i = 1 To 12
        'For Each control In Me.Controls("Sub_MA_ZK_" & i).Form.Controls
            'Debug.Print control.Name
        'Next control
        Me.Controls("Sub_MA_ZK_" & i).Top = Me.Controls("Sub_MA_ZK_1").Top
        Me.Controls("Sub_MA_ZK_" & i).Left = Me.Controls("Sub_MA_ZK_1").Left
        Me.Controls("Sub_MA_ZK_" & i).width = Me.Controls("Sub_MA_ZK_1").width
        Me.Controls("Sub_MA_ZK_" & i).height = Me.Controls("Sub_MA_ZK_1").height
    Next i
        
'        Me.Controls("MA_ZK_FEB").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_FEB").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_FEB").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_FEB").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_MAR").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_MAR").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_MAR").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_MAR").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_APR").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_APR").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_APR").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_APR").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_MAI").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_MAI").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_MAI").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_MAI").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_JUN").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_JUN").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_JUN").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_JUN").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_JUL").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_JUL").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_JUL").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_JUL").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_AUG").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_AUG").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_AUG").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_AUG").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_SEP").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_SEP").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_SEP").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_SEP").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_OKT").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_OKT").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_OKT").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_OKT").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_NOV").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_NOV").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_NOV").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_NOV").Height = Me.Controls("MA_ZK_JAN").Height
'
'        Me.Controls("MA_ZK_DEZ").Top = Me.Controls("MA_ZK_JAN").Top
'        Me.Controls("MA_ZK_DEZ").Left = Me.Controls("MA_ZK_JAN").Left
'        Me.Controls("MA_ZK_DEZ").Width = Me.Controls("MA_ZK_JAN").Width
'        Me.Controls("MA_ZK_DEZ").Height = Me.Controls("MA_ZK_JAN").Height
        
'    For Each control In Me.Controls
'        Debug.Print control.Name
'    Next control
'Forms("zfrm_MA_VA_ZK_top").Controls(49).name = "Sub_MA_ZK_12"

End Sub












Sub Resize()


Dim xStart As Long

    xStart = Me.width

    If xStart < 0 Then

        xStart = (32768 / 2) - xStart

    End If


Dim xWindow As Long

    xWindow = Me.WindowWidth

    If xWindow < 0 Then

        xWindow = (32768 / 2) - xWindow

    End If

    If xWindow > 31000 Then xWindow = 31000


Dim ScaleX As Double

    ScaleX = xWindow / xStart

Dim yStart As Long

    yStart = Detailbereich.height 'Section(0).Height

Dim yHeader As Long

    yHeader = Section(1).height

Dim yFooter As Long

    yFooter = Section(2).height

Dim yOffset As Long

    yOffset = 90

Dim yWindow As Long

    yWindow = Me.WindowHeight - yHeader - yFooter + yOffset

Dim ScaleY As Double

    ScaleY = yWindow / yStart

Dim ctl As control

    For Each ctl In Me.Controls
        'Debug.Print ctl.Name
        If ctl.Properties("ControlType") = 123 Or _
            ctl.Properties("ControlType") = 124 Or _
            ctl.Properties("ControlType") = 112 Then '123 = Register, 124 = Registerkarte, 112 = Unterformular
            
            'ctl.Left = ctl.Left * ScaleX
            Debug.Print ctl.Name & " Left: " & ctl.Left
            If ctl.width * ScaleX > 31000 Then
                'ctl.Width = 31000
                Debug.Print ctl.Name & " Width: " & ctl.width
            Else
                'ctl.Width = ctl.Width * ScaleX
                Debug.Print ctl.Name & " Width: " & ctl.width
            End If
    
            If ctl.Section = 0 Then
                'ctl.Top = ctl.Top * ScaleY
                Debug.Print ctl.Name & " Top: " & ctl.Top
                If ctl.height * ScaleY > 15000 Then
                    'ctl.Height = 7000
                    Debug.Print ctl.Name & " Height: " & ctl.height
                Else
                    'ctl.Height = ctl.Height * ScaleY
                    Debug.Print ctl.Name & " Height: " & ctl.height
                End If
            End If
        End If
    Next ctl

End Sub


Sub ListControlProps(ByRef frm As Form)
 Dim ctl As control
 Dim prp As Property
 
 On Error GoTo props_err
 
 For Each ctl In frm.Controls
 Debug.Print ctl.Properties("Name")
 For Each prp In ctl.Properties
 Debug.Print vbTab & prp.Name & " = " & prp.Value
 Next prp
 Next ctl
 
props_exit:
 Set ctl = Nothing
 Set prp = Nothing
Exit Sub
 
props_err:
 If Err = 2187 Then
 Debug.Print vbTab & prp.Name & " = Only available at design time."
 Resume Next
 Else
 Debug.Print vbTab & prp.Name & " = Error Occurred: " & Err.description
 Resume Next
 End If
End Sub
