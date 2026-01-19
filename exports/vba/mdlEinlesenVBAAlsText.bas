Attribute VB_Name = "mdlEinlesenVBAAlsText"
Option Compare Database
Option Explicit


Dim TestArray() As String
Dim tst1(1 To 4)
Dim bMerk As Boolean
Dim IstBegin As Boolean
Dim IstPrgm As Boolean
Dim vbControl As String
Dim iID As Long
Dim iIstFont As Long
Dim iIstFrame As Long
Dim stBeginArrType() As String
Dim stBeginArrName() As String
Dim ObjektNr As Long


Function LesAlle(tblAusgabeName As String, Optional tblAlleName As String = "Acc_tbl_Source_CL", Optional pfad As String = "", Optional NurProgrammCode As Boolean = True)
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
'Dim Pfad As String

ObjektNr = 0
iID = 0
recsetSQL1 = "Select ID, filename, IstModul, Formname, IsUsed, Type from " & tblAlleName & " Order By ID;"

ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        bMerk = False
        IstPrgm = False
        vbControl = ""
        iIstFont = 0
        iIstFrame = 0
        ReDim stBeginArrType(0)
        ReDim stBeginArrName(0)
        Call tles(CLng(DAOARRAY1(0, iZl)), pfad & CStr(DAOARRAY1(1, iZl)), CStr(DAOARRAY1(3, iZl)), CStr(DAOARRAY1(4, iZl)), CStr(DAOARRAY1(2, iZl)), CStr(DAOARRAY1(5, iZl)), NurProgrammCode, tblAusgabeName)
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function


Function tles(IDfile As Long, Datnam1 As String, Formnam1 As String, IstEinlesen As Boolean, IstModul As Boolean, stType As String, NurProgrammCode As Boolean, tblAusgabeName As String)
Dim dateipruef As String
Dim Datnr1 As Variant
Dim ddaten1 As Variant
Dim i As Long
Dim db As DAO.Database
Dim rst As DAO.Recordset


i = 1

dateipruef = ""
dateipruef = Dir(Datnam1)
If Len(dateipruef) = 0 Then
    MsgBox "Datei " & Datnam1 & " nicht vorhanden"
    Exit Function
End If

CurrentDb.Execute ("DELETE * FROM " & tblAusgabeName & " WHERE IDfile = " & IDfile & ";")

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM " & tblAusgabeName & ";")

Datnr1 = FreeFile
Open Datnam1 For Input As Datnr1    ' Datei zum Lesen öffnen.
Do
    Line Input #Datnr1, ddaten1            ' BEIM und nicht NACH dem letzten Satz er EOF'
'    Debug.Print ddaten1, EOF(Datnr1)       ' bringt er EOF
    Call DatAuswert(ddaten1, IstEinlesen)
    'Bei Modulen (bzw Nicht Forms und Nicht Reports) kein Attributes als erste Programmzeile, daher "künstlich" Programmanfang setzen
    If IstModul Then IstPrgm = True
    If NurProgrammCode And Not IstPrgm Then
    'tu nix
    Else
        rst.AddNew
'            rst!ID = iID   ' wenn kein Autowert
            rst!IDfile = IDfile
            rst!IDZeile = i
            rst!formName = Formnam1
            rst!Memofeld = ddaten1
            rst!IsUsed = IstEinlesen
            rst!IstPgm = IstPrgm
            rst!stType = stType
            If Not (IstPrgm And IstEinlesen) Then
                rst!Stufe = UBound(stBeginArrType) - 1
                rst!txt1 = tst1(1)
                rst!Txt2 = tst1(2)
                rst!txt3 = tst1(3)
                rst!vbControl = stBeginArrType(UBound(stBeginArrType))
                rst!IstBegin = IstBegin
                rst!IstFont = iIstFont
                rst!IstFrame = iIstFrame
                rst!vbControlName = stBeginArrName(UBound(stBeginArrType))
                rst!ObjektNr = ObjektNr
            End If
        rst.update
    End If
    If EOF(Datnr1) Then
        Exit Do
    End If
    i = i + 1
'    iID = iID + 1
Loop
rst.Close
Close Datnr1

Set rst = Nothing

Call pgm_upd(IDfile, tblAusgabeName)

End Function

Private Function DatAuswert(ByVal st As String, NurLes As Boolean)

Dim AnzWd, i, j
Dim iStufe As Long

' Der Programmteil wird hier nicht aufgedröselt. Beginn des Programmteils ist immer eine "Attribute" Zeile
If Left(st, 9) = "Attribute" Or IstPrgm = True Then
    IstPrgm = True
    Exit Function
End If

If NurLes = True Then
    Exit Function
End If

' Zeilen aufdröseln
' txt1 - leeren
For i = 1 To 4
    tst1(i) = ""
Next i
'Kommentar aus Zeile entfernen
i = InStrRev(st, "'")
If i > 0 Then
    st = Left(st, i - 1)
End If

'= separieren, damit eigener Wert
st = Replace(st, "=", " = ", 1)

'aufdröseln, Jedes Wort in eine Zeile des Arrays getrennt durch " "
j = 1
AnzWd = ExtractWords(st, TestArray(), " ", True)
For i = LBound(TestArray) To UBound(TestArray)
    ' Debug.Print "   String " & i & " : " & TestArray(i)
    If Len(Trim(Nz(TestArray(i)))) > 0 Then
        If j < 5 Then
            tst1(j) = TestArray(i)
        End If
        j = j + 1
    End If
Next i

' Nach Txt2 alles "zuviel aufgedröselte" wieder in ein Textfeld
If Len(Trim(Nz(tst1(4)))) > 0 Then
    i = InStr(st, tst1(3))
    If i > 0 Then
        tst1(3) = Mid(st, i)
    End If
End If
   
' OK jetzt auswerten
' ####################

iStufe = UBound(stBeginArrType)

IstBegin = False

If bMerk = True Then
    bMerk = False
    If stBeginArrType(iStufe) = "VB.Frame" Then
        iIstFrame = 0
    End If
    iStufe = iStufe - 1
    ReDim Preserve stBeginArrType(iStufe)
    ReDim Preserve stBeginArrName(iStufe)
End If
       
If tst1(1) = "End" Then
    bMerk = True
End If

If tst1(1) = "EndProperty" Then
        iIstFont = 0
End If

If tst1(1) = "Begin" Then
    ObjektNr = ObjektNr + 1
    iStufe = iStufe + 1
    ReDim Preserve stBeginArrType(iStufe)
    ReDim Preserve stBeginArrName(iStufe)
    stBeginArrType(iStufe) = tst1(2)
    stBeginArrName(iStufe) = tst1(3)
    IstBegin = True
    If tst1(2) = "VB.Frame" Then
        iIstFrame = 1
    End If
End If
   
If tst1(1) = "BeginProperty" And tst1(2) = "Font" Then
    iIstFont = 1
End If

End Function


Private Function pgm_upd(IDfile As Long, tblAusgabeName As String)
Dim i1 As Long
Dim i2 As Long
Dim iAlt As Long

Dim fkt As String

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim st As String
Dim AnzWd, i, j
Dim tst() As String

st = ""
Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM " & tblAusgabeName & " WHERE IstPGM = True AND IDfile = " & IDfile & " Order by ID;")

i1 = 1
i2 = 1
iAlt = 1

fkt = ""
With rst
    Do While Not .EOF
        If rst!IDfile <> iAlt Then
            fkt = ""
            iAlt = rst!IDfile
        End If
    
        st = Nz(rst!Memofeld)
    
        i1 = 0
        If Left(st, 11) = "Private Sub" Then i1 = 1
        If Left(st, 10) = "Public Sub" Then i1 = 1
        If Left(st, 3) = "Sub" Then i1 = 1
        If Left(st, 8) = "Function" Then i1 = 1
        If Left(st, 16) = "Private Function" Then i1 = 1
        If Left(st, 15) = "Public Function" Then i1 = 1
        If Left(st, 7) = "End Sub" Then i1 = 2
        If Left(st, 12) = "End Function" Then i1 = 2
        
        If bMerk = True Then
            fkt = ""
            bMerk = False
        End If
        
        If i1 = 2 Then
            bMerk = True
        End If
        
        If i1 = 1 Then
            j = 0
            AnzWd = ExtractWords(st, TestArray(), " ", True)
            ReDim tst(UBound(TestArray))
            For i = LBound(TestArray) To UBound(TestArray)
                If Len(Trim(Nz(TestArray(i)))) > 0 Then
                    tst(j) = TestArray(i)
                    j = j + 1
                End If
            Next i
            For i = 0 To UBound(TestArray)
                If tst(i) = "Function" Or tst(i) = "Sub" Then
                    fkt = tst(i + 1)
                    Exit For
                End If
            Next i
            i = InStr(1, fkt, "(")
            If i > 0 Then
                fkt = Left(fkt, i - 1)
            End If
        End If
        .Edit
            !FunctionSub = fkt
        .update
        .MoveNext
    Loop
    .Close
End With
Set rst = Nothing

End Function
