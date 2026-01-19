Attribute VB_Name = "mdlWaehrungsumrechnung"
Option Compare Database
Option Explicit

Public Function getUmrechnungskursAlle() As Boolean

' Autor: Günter Gerold (Newsgroup)

' Legalitätscheck - Erlaubte Abfrage ...
' http://www.ecb.europa.eu/home/html/disclaimer.de.html

' Download History Daten
' http://www.ecb.europa.eu/stats/exchange/eurofxref/html/index.en.html

    Dim iJahr As Long
    Dim iMon As Long
    Dim iday As Long
    Dim dtDatum As Date
    Dim strAdresse As String
    Dim objWeb As Object
    Dim strXML As String
    Dim strMarke As String
    Dim strLand As String
    Dim intMarkeAnfang As Integer
    Dim intLaenge As Integer
    Dim OrgWert As Currency
    Dim i As Long
    Dim UmrechnungskursVon As Double
    Dim UmrechnungskursNach As Double
    Dim strDatum() As String
    Dim db As DAO.Database
    Dim rst As DAO.Recordset

    Dim dDatVgl As Date

Dim recsetSQL As String, iZLMax As Long, iColMax As Long, DAOARRAY, isOK As Boolean, iZl As Long
Dim strfld As String
Dim sfld As Single

    'Initialisieren
On Error GoTo getUmrechnungskursSF_Error
    getUmrechnungskursAlle = -1

    If Not ObjectExists("Table", "_tblUmrechnungskurs") Then
    CurrentDb.Execute ("CREATE TABLE _tblUmrechnungskurs " & _
          "(UmrLand TEXT(12), CreateDate DATETIME, UmrWert  SINGLE, " & _
          "CONSTRAINT PrimKey PRIMARY KEY (UmrLand));")
    End If
    DoEvents

    dDatVgl = Nz(TMax("CreateDate", "_tblUmrechnungskurs"), 32000)
    
    If dDatVgl = Date Then
        Exit Function
    End If

    strAdresse = _
"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    'Web-Zugriff
    Set objWeb = CreateObject("Microsoft.XMLHTTP")
    objWeb.Open "GET", strAdresse, False
    objWeb.Send
    strXML = objWeb.responseText

    CurrentDb.Execute ("DELETE * FROM _tblUmrechnungskurs;")
    Set db = CurrentDb
    Set rst = db.OpenRecordset("SELECT * FROM _tblUmrechnungskurs;")

' <Cube time="2008-02-28">
    strMarke = "Cube time='"
    strDatum = Split(Mid(strXML, _
      InStr(strXML, strMarke) + 11, 10), "-")
    dtDatum = DateSerial(strDatum(0), strDatum(1), strDatum(2))

    i = 1
    Do
        strMarke = "Cube currency='"
        intMarkeAnfang = InStr(i, strXML, strMarke)
        If intMarkeAnfang = 0 Then Exit Do
        strLand = Mid(strXML, intMarkeAnfang + Len(strMarke), 3)
        intLaenge = InStr(intMarkeAnfang, strXML, "'/>") _
          - intMarkeAnfang - Len(strMarke) - 11
        OrgWert = CCur(Replace(Mid(strXML, _
          intMarkeAnfang + Len(strMarke) + 11, intLaenge), ".", ","))
        i = intMarkeAnfang + 1
        With rst
            .AddNew
                rst.fields("UmrLand").Value = strLand
                rst.fields("CreateDate").Value = dtDatum
                rst.fields("UmrWert").Value = OrgWert
            .update
        End With
    Loop

    rst.Close
    Set rst = Nothing
        
    If ObjectExists("Table", "_tblUmrechnungskurs_Hist") Then
        ''Info:   'AccessArray(iSpalte,iZeile) <0, 0>       'ExcelArray(iZeile, iSpalte) <1, 1>
        'Function ArrFill_DAO(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY) As Boolean
        CurrentDb.Execute ("DELETE * FROM _tblUmrechnungskurs_Hist WHERE Date = Date();")
        isOK = ArrFill_DAO_Acc("_tblUmrechnungskurs", iZLMax, iColMax, DAOARRAY)
        If isOK Then
            Set rst = db.OpenRecordset("SELECT TOP 1 * FROM _tblUmrechnungskurs_Hist;")
            With rst
                .AddNew
                .fields(1) = Date
                For iZl = 0 To iZLMax
                    strfld = DAOARRAY(0, iZl)
                    sfld = DAOARRAY(2, iZl)
                    .fields(strfld).Value = sfld
                Next iZl
                .update
                .Close
            End With
            Set DAOARRAY = Nothing
        End If
        DoEvents
        Set rst = Nothing
    End If
    
    Set db = Nothing
    getUmrechnungskursAlle = True
AUSGANG:
      On Error Resume Next
      Exit Function

getUmrechnungskursSF_Error:
 getUmrechnungskursAlle = False
 Select Case Err.Number
     Case 0
          Resume AUSGANG
     Case Else
          MsgBox "fehler"
 '         Call fncErrorHandler("mdlGerold", "getUmrechnungskursSF")
          Resume AUSGANG
End Select

DoEvents
DBEngine.Idle dbRefreshCache
DBEngine.Idle dbFreeLocks
DoEvents

End Function

Private Function ArrFill_DAO_Acc(ByVal recsetSQL As String, ByRef iZLMax As Long, ByRef iColMax As Long, ByRef DAOARRAY) As Boolean

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim i As Long

'Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl as long, iCol as long
'recsetSQL1 = ""
'ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1,iZLMax1,iColMax1,DAOARRAY1)
''Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'If ArrFill_DAO_OK1 Then
'    For iZl = 0 To iZLMax1
'
'
'
'    Next iZl
'    Set DAOARRAY1 = Nothing
'End If


ArrFill_DAO_Acc = False

    Set db = CurrentDb
    Set rst = db.OpenRecordset(recsetSQL)
    If rst.RecordCount <> 0 Then
        rst.MoveLast
        i = rst.RecordCount
        rst.MoveFirst
        DAOARRAY = rst.GetRows(i)

    'Achtung Zeile und Spalte 0-basiert
    'RowArray(iFldNr,iRecNr)
    'RowArray(iSpalte,iZeile)
        iZLMax = UBound(DAOARRAY, 2)
        iColMax = UBound(DAOARRAY, 1)
        ArrFill_DAO_Acc = True
    End If
    rst.Close
    Set rst = Nothing

End Function

Private Function ObjectExists(strObjectType As String, strObjectName As String) As Boolean
' Pass the Object type: Table, Query, Form, Report, Macro, or Module
' Pass the Object Name
     Dim db As DAO.Database
     Dim tbl As DAO.TableDef
     Dim QRY As DAO.QueryDef
     Dim i As Integer
     
     Set db = CurrentDb()
     ObjectExists = False
     
     If strObjectType = "Table" Then
          For Each tbl In db.TableDefs
               If tbl.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next tbl
     ElseIf strObjectType = "Query" Then
          For Each QRY In db.QueryDefs
               If QRY.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next QRY
     ElseIf strObjectType = "Form" Or strObjectType = "Report" Or strObjectType = "Module" Then
          For i = 0 To db.Containers(strObjectType & "s").Documents.Count - 1
               If db.Containers(strObjectType & "s").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     ElseIf strObjectType = "Macro" Then
          For i = 0 To db.Containers("Scripts").Documents.Count - 1
               If db.Containers("Scripts").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     Else
          MsgBox "Invalid Object Type passed, must be Table, Query, Form, Report, Macro, or Module"
     End If

Set db = Nothing
     
End Function





Public Function getUmrechnungskurs(Optional strCurr As String = "CHF", Optional VonEuro As Boolean = False) As Currency
    
' Autor: Günter Gerold (Newsgroup)  ' Änderungen: Klaus Oberdalhoff

    Dim strAdresse As String
    Dim objWeb As Object
    Dim strXML As String
    Dim strMarke As String
    Dim intMarkeAnfang As Integer
    Dim intLaenge As Integer
    Dim OrgWert As Currency

' Legalitätscheck - Erlaubte Abfrage ...
' http://www.ecb.europa.eu/home/html/disclaimer.de.html

'  <Cube currency="USD" rate="1.5044" />    USD US dollar  1.5044
'  <Cube currency="JPY" rate="159.95" />    JPY Japanese yen  159.95
'  <Cube currency="BGN" rate="1.9558" />    BGN Bulgarian lev  1.9558
'  <Cube currency="CZK" rate="25.048" />    CZK Czech koruna  25.048
'  <Cube currency="DKK" rate="7.4546" />    DKK Danish krone  7.4546
'  <Cube currency="EEK" rate="15.6466" />   EEK Estonian kroon  15.6466
'  <Cube currency="GBP" rate="0.75760" />   GBP Pound sterling  0.75760
'  <Cube currency="HUF" rate="257.98" />    HUF Hungarian forint  257.98
'  <Cube currency="LTL" rate="3.4528" />    LTL Lithuanian litas  3.4528
'  <Cube currency="LVL" rate="0.6965" />    LVL Latvian lats  0.6965
'  <Cube currency="PLN" rate="3.5385" />    PLN Polish zloty  3.5385
'  <Cube currency="RON" rate="3.6498" />    RON New Romanian leu 1 3.6498
'  <Cube currency="SEK" rate="9.3356" />    SEK Swedish krona  9.3356
'  <Cube currency="SKK" rate="32.817" />    SKK Slovak koruna  32.817
'  <Cube currency="CHF" rate="1.6074" />    CHF Swiss franc  1.6074
'  <Cube currency="ISK" rate="98.65" />     ISK Icelandic krona  98.65
'  <Cube currency="NOK" rate="7.8540" />    NOK Norwegian krone  7.8540
'  <Cube currency="HRK" rate="7.2770" />    HRK Croatian kuna  7.2770
'  <Cube currency="RUB" rate="36.3680" />   RUB Russian rouble  36.3680
'  <Cube currency="TRY" rate="1.7793" />    TRY New Turkish lira 2  1.7793
'  <Cube currency="AUD" rate="1.6021" />    AUD Australian dollar  1.6021
'  <Cube currency="BRL" rate="2.5185" />    BRL Brasilian real  2.5185
'  <Cube currency="CAD" rate="1.4742" />    CAD Canadian dollar  1.4742
'  <Cube currency="CNY" rate="10.7444" />   CNY Chinese yuan renminbi  10.7444
'  <Cube currency="HKD" rate="11.7148" />   HKD Hong Kong dollar  11.7148
'  <Cube currency="IDR" rate="13619.33" />  IDR Indonesian rupiah  13619.33
'  <Cube currency="KRW" rate="1415.72" />   KRW South Korean won  1415.72
'  <Cube currency="MXN" rate="16.1525" />   MXN Mexican peso  16.1525
'  <Cube currency="MYR" rate="4.8186" />    MYR Malaysian ringgit  4.8186
'  <Cube currency="NZD" rate="1.8365" />    NZD New Zealand dollar  1.8365
'  <Cube currency="PHP" rate="60.507" />    PHP Philippine peso  60.507
'  <Cube currency="SGD" rate="2.1013" />    SGD Singapore dollar  2.1013
'  <Cube currency="THB" rate="44.900" />    THB Thai baht  44.900
'  <Cube currency="ZAR" rate="11.2168" />   ZAR South African rand

    'Initialisieren
On Error GoTo getUmrechnungskursSF_Error

    strAdresse = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    strMarke = "Cube currency='" & strCurr & "' rate='"
    'Web-Zugriff
    Set objWeb = CreateObject("Microsoft.XMLHTTP")
    objWeb.Open "GET", strAdresse, False
    objWeb.Send
    strXML = objWeb.responseText
    intMarkeAnfang = InStr(1, strXML, strMarke)
    intLaenge = InStr(intMarkeAnfang, strXML, "'/>") - intMarkeAnfang - Len(strMarke)
    OrgWert = CCur(Replace(Mid(strXML, intMarkeAnfang + Len(strMarke), intLaenge), ".", ","))
    If VonEuro = False Then
        getUmrechnungskurs = Format(1 / OrgWert, "0.0000")
    Else
        getUmrechnungskurs = OrgWert
    End If

AUSGANG:
      On Error Resume Next
      Exit Function

getUmrechnungskursSF_Error:
 Select Case Err.Number
     Case 0
          Resume AUSGANG
     Case Else
          MsgBox "fehler"
 '         Call fncErrorHandler("mdlGerold", "getUmrechnungskursSF")
          Resume AUSGANG
End Select

End Function


Function Wae_Hist()

CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN ZAR Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN USD Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN TRY Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN THB Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN SGD Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN SEK Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN RUB Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN RON Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN PLN Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN PHP Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN NZD Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN NOK Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN MYR Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN MXN Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN LVL Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN LTL Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN KRW Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN JPY Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN INR Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN ILS Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN IDR Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN HUF Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN HRK Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN HKD Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN GBP Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN DKK Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN CZK Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN CNY Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN CHF Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN CAD Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN BRL Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN BGN Single;")
CurrentDb.Execute ("ALTER TABLE _tblUmrechnungskurs_Hist ALTER COLUMN AUD Single;")

End Function

'USD
'JPY
'BGN
'CYP
'CZK
'DKK
'EEK
'GBP
'HUF
'LTL
'LVL
'MTL
'PLN
'ROL
'RON
'SEK
'CHF
'SIT
'SKK
'HRK
'ISK
'NOK
'RUB
'AUD
'TRL
'TRY
'BRL
'CAD
'CNY
'HKD
'IDR
'INR
'KRW
'MXN
'MYR
'NZD
'PHP
'SGD
'ILS
'THB
'ZAR

