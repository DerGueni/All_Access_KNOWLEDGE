VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_stundenuebersicht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub cbo_Std_zeitraum2_BeforeUpdate(Cancel As Integer)
'' Function StdZeitraum_Von_Bis(ID, von, bis)  und Tabelle _tblZeitraumAngaben (für Combobox)
Dim dtvon As Date
Dim dtbis As Date
Call Std_Zeitraum_Von_Bis(Me!cbo_Std_zeitraum2, dtvon, dtbis)
'Me!AUPl_von = dtVon
'Me!AUPl_bis = dtBis
'DoEvents
'btnAUPl_Lesen_Click
End Sub

Private Sub cbo_Std_zeitraum_AfterUpdate()
Dim dtvon As Date
Dim dtbis As Date
Call Std_Zeitraum_Von_Bis(Me!cbo_Std_zeitraum2, dtvon, dtbis)

End Sub

Private Sub btnAU_Lesen_Click()
'in Abfrage qry_MA_VA_Zuo_All_AufUeber2 - VADatum - Dort ist das Datumsformat auf "ttt  tt.mm.jjjj" gesetzt
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT * FROM qry_MA_VA_Plan_All_AufUeber2_Zuo WHERE VADatum Between " & SQLDatum(Me!AU_von) & " AND " & SQLDatum(Me!AU_bis) & " And MA_ID = " & Me!ID & " ORDER BY VADatum, Beginn"
    Me!lst_Zuo.RowSource = strSQL
    Me!lst_Zuo.Requery
    DoEvents
End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub btnAUPl_Lesen_Click()
'in Abfrage qry_MA_VA_Zuo_All_AufUeber1 - VADatum - Dort ist das Datumsformat auf "ttt  tt.mm.jjjj" gesetzt
Dim strSQL As String
    strSQL = ""
    strSQL = strSQL & "SELECT * FROM qry_MA_VA_Plan_AllAufUeber1 WHERE VADatum Between " & SQLDatum(Me!AUPl_von) & " AND " & SQLDatum(Me!AUPl_bis) & " And MA_ID = " & Me!ID & " ORDER BY VADatum, Beginn"
    Me!lstPl_Zuo.RowSource = strSQL
    Me!lstPl_Zuo.Requery
    DoEvents

End Sub

Function Std_Zeitraum_Von_Bis(Zeitraum As Long, Me_vonDat As Date, Me_bisDat As Date)

    Dim iwkday As Long
    Dim iQ As Long
    Dim iM As Long
    
    'Sort     'ID Bemerkung
    '1        '1   Heute
    '2        '17  Die nächsten 6 Tage
    '3        '4   Aktuelle Woche
    '4        '8   Aktueller Monat
    '5        '14  Aktuelles Quartal
    '6        '11  Aktuelles Jahr
    '7        '18  Nächster Monat
    '8        '19  Die nächsten 90 Tage
    '9        '20  Nächstes Jahr
    '
    '10        '2   Gestern
    '11        '3   Vorgestern
    '12        '5   Die letzten 7 Tage
    '13        '6   Letzte Woche
    '14        '7   Vorletzte Woche
    '15        '15  Letztes Quartal
    '16        '16  Die letzten 90 Tage
    '17        '9   Letzter Monat
    '18        '10  Vorletzter Monat
    '19        '12  Letztes Jahr
    '20        '13  Vorletztes Jahr
    '750       '21  Nächstes Quartal
    
    iwkday = Weekday(Date, 2)
    
    Select Case Zeitraum
        Case 2
            Me_vonDat = Date - 1
            Me_bisDat = Date - 1
        Case 3
            Me_vonDat = Date - 2
            Me_bisDat = Date - 2
        Case 4
            Me_vonDat = Date - iwkday + 1
            Me_bisDat = Date - iwkday + 6
        Case 5
            Me_vonDat = Date - 6
            Me_bisDat = Date
        Case 6
            Me_vonDat = Date - iwkday + 1 - 7
            Me_bisDat = Date - iwkday
        Case 7
            Me_vonDat = Date - iwkday + 1 - 14
            Me_bisDat = Date - iwkday - 7
        Case 8
            Me_vonDat = DateSerial(Year(Date), Month(Date), 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date) + 1, 0)
        Case 9
            Me_vonDat = DateSerial(Year(Date), Month(Date) - 1, 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date), 0)
        Case 10
            Me_vonDat = DateSerial(Year(Date), Month(Date) - 2, 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date) - 1, 0)
        Case 11
            Me_vonDat = DateSerial(Year(Date), 1, 1)
            Me_bisDat = DateSerial(Year(Date), 12, 31)
        Case 12
            Me_vonDat = DateSerial(Year(Date) - 1, 1, 1)
            Me_bisDat = DateSerial(Year(Date) - 1, 12, 31)
        Case 13
            Me_vonDat = DateSerial(Year(Date) - 2, 1, 1)
            Me_bisDat = DateSerial(Year(Date) - 2, 12, 31)
        Case 14
            iQ = Format(Date, "q", 2, 2)
            iM = (iQ - 1) * 3 + 1
            Me_vonDat = DateSerial(Year(Date), iM, 1)
            Me_bisDat = DateSerial(Year(Date), iM + 3, 0)
        Case 15
            iQ = Format(Date, "q", 2, 2)
            iM = (iQ - 1) * 3 + 1
            Me_vonDat = DateSerial(Year(Date), iM - 3, 1)
            Me_bisDat = DateSerial(Year(Date), iM, 0)
        Case 16
            Me_bisDat = Date
            Me_vonDat = Date - 90
        Case 17
            Me_bisDat = Date + 6
            Me_vonDat = Date
        Case 18
            Me_bisDat = DateSerial(Year(Date), Month(Date) + 2, 0)
            Me_vonDat = DateSerial(Year(Date), Month(Date) + 1, 1)
        Case 19
            Me_bisDat = Date + 90
            Me_vonDat = Date
        Case 20
            Me_vonDat = DateSerial(Year(Date) + 1, 1, 1)
            Me_bisDat = DateSerial(Year(Date) + 1, 12, 31)
        Case 21
            iQ = Format(Date, "q", 2, 2)
            iM = ((iQ - 1) * 3 + 1) + 3
            Me_vonDat = DateSerial(Year(Date), iM, 1)
            Me_bisDat = DateSerial(Year(Date), iM + 3, 0)
        
        Case 22
            Me_vonDat = Date
            Me_bisDat = Date + 30
        
        Case 23
            Me_vonDat = Date
            Me_bisDat = Date + 45
        
        Case 24
            Me_vonDat = Date
            Me_bisDat = Date + 14
        
        Case 25
            Me_vonDat = Date
            Me_bisDat = Date + 1000
        
        Case 26
            Me_vonDat = DateSerial(Year(Date), 1, 1)
            Me_bisDat = Date
        
        Case Else ' Heute
            Me_vonDat = Date
            Me_bisDat = Date
    End Select
    DoEvents

End Function


Private Sub Kombinationsfeld3_Click()
Dim frm_Stundenuebersicht3 As Object


'frm_Stundenuebersicht3.MA_ID = Me.Kombinationsfeld3.MA_ID
End Sub
