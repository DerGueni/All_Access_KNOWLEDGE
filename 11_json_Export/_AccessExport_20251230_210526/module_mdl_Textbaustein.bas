Option Compare Database
Option Explicit



'Flexible Ersetzung von [xxx] Feldern in Word und in Fliesstexten
'################################################################

' Dazu gibt es auf der >Word-Vorlagen-Seite< die Tabellen "_tblEigeneFirma_TB_Dok_Dateinamen"  "_tblEigeneFirma_TB_Dok_Feldnamen"  und "_tblEigeneFirma_TB_Dok_Typ"
'  ...Dateinamen beschreibt die aktuell gespeicherte Word-Textvorlage, aus der die zu ersetzenden Werte stammen
'  ...Feldnamen beschreibt die in den einzelnen Vorlagen aktuell verwendeten Eresetzungsnamen  [R_Hugo]
'  ...Dok_Typ beschreibt die Art der Vorlage (Kunde / Mitarbeiter - auch für Sonderbehandung / Rechnung / Angebotz / Mahnung notwendig)

' Zusätzlich existieren für die >Access-Tabellen-Seite< die Tabellen "tbl_Textbaustein_Namen", "tbl_Textbaustein_Herkunft","tbl_Textbaustein_Namen"
' ...Namen beschreibt die Zuordnung zwischen Ersetzungsnamen [R_Rg_Nr] und dem Feldnamen
' ...Herkunft beschreibt die Herkunftsabfrage der Feldnamen
' ...Typen beschreibt den Feldtypen und das prinzipielle "ToDo" für den Feldtyp

'Grundidee: Zu jeder der 5 derzeit abgebildeten Tabellengrundtypen ...
'   a) Kunde         kun_ID
'   b) Mitarbeiter   MA_ID
'   c) Auftrag       VA_ID   - Wenn kun_ID hinterlegt auch alle Felder aus Kunde
'   d) Rechnung      iRch_KopfID - interne Rechnungsnummer - Wenn kun_ID hinterlegt auch alle Felder aus Kunde
'                       Mahnungsdaten sind Teil des Rechnungskopfes
'   e) Intern        Eigene Firma & Büro-Mitarbeiter (Ausnahme) Statt PK wird hier atcNames(1) als PK verwendet

'   ...existiert eine Abfrage "qty_Textbaustein_xxx", die alle Felder aus der jeweiligen Tabelle bereits als Text aufbereitet enthält.

' Jede Word-Vorlage muss dem System vorher bekanntgemacht werden, damit deren Ersetzungswerte in die og Tabellen aufgenommen werden.
' Dafür gibt es das Formular : "frmTop_Neue_Vorlagen"

' Das Feld "P1" enthält den Feldnamen des Primärschlüssels
' Parallel dazu existiert ein Control mit dem aktiellen Wert des PK und dem gleichen Namen wie "P1"

' Derzeit erlaubte PK-Felder und Werte sind:

'  Numerisch Long   .Fields("P1Typ") <> 0
'###########
'   kun_ID
'   MA_ID
'   iRch_KopfID
'   VA_ID

'  Ausnahme als String  .Fields("P1Typ") = 0
'#####################
'  Loginname = atcNames(1)

' In die lokale Temp-Tabelle "tbltmp_Textbaustein_Ersetzung" werden die für die jeweilige Wordvorlage passenden Werte eingetragen
' Die wichtgsten sind
'       Dok_Nr              Die Nummer unter der die Vorlage geunden wird
'       Tb_Name_Kl          Der "[SuchString]" mit Klammern
'       Feldname            Der Feldname, der die Ersetzung erhält
'       Ersetzung           Der zu ersetzende Wert
'       QryFeldname         die Abfrage, in der die Ersetzung zu finden ist
'       P1                  Sowohl Feld- als auch Controlname des Primary Keys
'       P1Typ               0 = atcnames(1)     1 = Long-Wert für P1
'

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, TextBau_ARRAY1, TextBau_ARRAY_Name1, iZl As Long, iCol As Long

Function Fill_TB_Array()

If Not IsArray(TextBau_ARRAY1) Then
    recsetSQL1 = "qry_Textbaustein_Pgm"
    '''Zusatztabelle mit Feldnamen (Zeile 0) und Feldtypen als Long (Zeile 1) und als Text (Zeile 2)
    'ArrFill_DAO_OK1 = ArrFill_DAO(recsetSQL1, iZLMax1, iColMax1, TextBau_ARRAY1, TextBau_ARRAY_Name1)
    ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, TextBau_ARRAY1)
    'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
End If

End Function


Function Textbau_Ersetz(Inpstring As String, Optional P1 As Variant, Optional P2 As Variant, Optional p3 As Variant) As String

Dim Suchfeld As String
Dim Suchfeld1 As String
Dim Suchfeld2 As String
Dim ergebnis As String
Dim iSuchfeld_len As Long
Dim iStart As Long
Dim iEnde As Long
Dim iLen As Long
Dim iZlAkt As Long
Dim iArr As Long


Textbau_Ersetz = Nz(Inpstring)
If Len(Trim(Nz(Inpstring))) = 0 Then Exit Function

Fill_TB_Array
If Not ArrFill_DAO_OK1 Then Exit Function

'TextBau_ARRAY1
'Field Name
'==========
' 0            Herkunftsname                10           Text
' 1            TextBausteinName             10           Text
' 2            Feldname                     10           Text
' 3            Feldtyp                       4           Long Integer
' 4            Todo                          4           Long Integer
' 5            ToDo_Info                    10           Text
' 6            P1                           10           Text
' 7            P2                           10           Text
' 8            P3                           10           Text
' 9            Herkunft_ID                   4           Long Integer
' 10           P1Typ                         4           Long Integer
' 11           P2Typ                         4           Long Integer
' 12           P3Typ                         4           Long Integer
'==========


'CurrentDb.Execute ("DELETE * FROM Textbaustein_Replace")
DoEvents

iStart = 0

ergebnis = Inpstring
    
'Suche den Text nach [ ab
Suchfeld1 = "["
Suchfeld2 = "]"

iStart = 1
Do
    iStart = Nz(InStr(iStart, ergebnis, Suchfeld1, vbTextCompare), 0)
    If iStart > 0 Then
        iEnde = Nz(InStr(iStart, ergebnis, Suchfeld2, vbTextCompare), 0)
        If iEnde > 0 Then
' Für jede gefundene [Text] Kombination suche, ob dieser String als Textbaustein definiert ist
            Suchfeld = Mid(ergebnis, iStart, iEnde - iStart + 1)
            iLen = Len(Suchfeld)
            For iZl = 0 To iZLMax1
                If UCase(CStr(Nz(TextBau_ARRAY1(1, iZl)))) = UCase(Suchfeld) Then ' Ersetze
                    ergebnis = Suche_Textbaustein(ergebnis, Suchfeld, iStart, iLen, P1, P2, Nz(p3))
                    Exit For
                End If
            Next iZl
        End If
        iStart = iStart + 1
    End If
Loop While iStart > 0

Textbau_Ersetz = ergebnis

End Function

Function P3_Test(p3 As Variant) As Boolean
Dim i As Long

   On Error GoTo P3_Test_Error
   i = Len(Trim(Nz(p3)))
    P3_Test = True

   On Error GoTo 0
   Exit Function

P3_Test_Error:
    P3_Test = False
End Function


Function Suche_Textbaustein(Suchstr As String, Suchfeld As String, iStart As Long, iLen As Long, Optional P1 As Variant, Optional P2 As Variant, Optional p3 As Variant) As String

'TextBau_ARRAY1
'Field Name
'==========
' 0            Herkunftsname                10           Text
' 1            TextBausteinName             10           Text
' 2            Feldname                     10           Text
' 3            Feldtyp                       4           Long Integer
' 4            Todo                          4           Long Integer
' 5            ToDo_Info                    10           Text
' 6            P1                           10           Text
' 7            P2                           10           Text
' 8            P3                           10           Text
' 9            Herkunft_ID                   4           Long Integer
' 10           P1Typ                         4           Long Integer
' 11           P2Typ                         4           Long Integer
' 12           P3Typ                         4           Long Integer
'==========

'ToDo Liste
'   1 = integerzahl
'   2 = Nachkommazahl
'   3 = Datum
'   4 = Text
'   5 = Ja/Nein

Dim varErg As Variant
Dim ergebnis As String
Dim ErsetztDurch As String
Dim WhereStr As String
Dim i As Long
Dim p(1 To 3)
Dim j As Long

Fill_TB_Array
If Not ArrFill_DAO_OK1 Then Exit Function

j = 2
p(1) = Nz(P1)
p(2) = Nz(P2)
If P3_Test(p3) Then
    p(3) = Nz(p3)
    j = 3
End If
    
If TextBau_ARRAY1(9, iZl) = 1 Then  'hart codiert auf den Login des Users wenn ein Textbaustein aus qry_Textbaustein_Firma_Mitarbeiter ...
    If TCount("Int_Login", "_tblEigeneFirma_Mitarbeiter", "Int_Login = '" & atCNames(1) & "'") = 0 Then
        i = Get_Priv_Property("prp_Notfall_Int_PersonalNr")
        WhereStr = "Int_PersonalNr = '" & i & "'"
    Else
        WhereStr = "int_login = '" & atCNames(1) & "'"
    End If
Else
    'Feld entweder Numerisch oder Text oder Datum (im moment kein Datum)
    WhereStr = "1 = 1"
    
    For i = 1 To j
        If Len(Trim(Nz(TextBau_ARRAY1(i + 5, iZl)))) > 0 And Len(Trim(Nz(p(i)))) > 0 And TextBau_ARRAY1(i + 9, iZl) > 0 Then  ' Wenn Paramter P1 bis 3 und Parametertyp nicht leer
            If TextBau_ARRAY1(i + 9, iZl) = 4 Then
                WhereStr = WhereStr & " AND " & CStr(TextBau_ARRAY1(i + 5, iZl)) & " = '" & p(i) & "'"
            ElseIf TextBau_ARRAY1(i + 9, iZl) < 3 Then
                WhereStr = WhereStr & " AND " & CStr(TextBau_ARRAY1(i + 5, iZl)) & " = " & str(p(i))
            ElseIf TextBau_ARRAY1(i + 9, iZl) = 3 Then
                WhereStr = WhereStr & " AND " & CStr(TextBau_ARRAY1(i + 5, iZl)) & " = " & SQLDatum(p(i))
            End If
        End If
    Next i
End If

varErg = Nz(TLookup(CStr(TextBau_ARRAY1(2, iZl)), CStr(TextBau_ARRAY1(0, iZl)), WhereStr))

Select Case TextBau_ARRAY1(4, iZl)  ' Behandlung abhängig vom Feldtyp
    Case 5  ' Ja/Nein
    
        If varErg = True Then
            ErsetztDurch = "Ja"
        Else
            ErsetztDurch = "Nein"
        End If
    
    Case 4  ' Text
        ErsetztDurch = varErg
    
    Case 3  ' Datum - kommt nicht vor - bereits in Abfrage nach Text umgewandelt, da es durchaus verschiedene gewünschte Formate sein können
        ErsetztDurch = Format(varErg, "dd.mm.yyyy")
    
    Case 2  ' Zahl mit Nachkomma
        ErsetztDurch = str(varErg)
        
    Case 1  ' Integer
        ErsetztDurch = str(varErg)
    
    Case Else
        ErsetztDurch = varErg

End Select
    
'Suchstr As String, Suchfeld As String, iStart As Long, iLen As Long,

ergebnis = Left(Suchstr, iStart - 1) & ErsetztDurch & Mid(Suchstr, iStart + iLen)
Suche_Textbaustein = ergebnis
End Function

Function Textbau_Replace_Felder_Fuellen(iDocNr As Long)

'Füllt die Tabelle tbltmp_Textbaustein_Ersetzung mit den Feldnamen aus dem Dokument mit der übergebenenen Nr

Dim strSQL As String

CurrentDb.Execute ("DELETE * FROM tbltmp_Textbaustein_Ersetzung")
DoEvents

strSQL = ""

strSQL = strSQL & "INSERT INTO tbltmp_Textbaustein_Ersetzung ( DokNr, TB_Name_Kl, Feldname, QryFeldname, P1, P1Typ )"
strSQL = strSQL & " SELECT qry_Textbaustein_Replace_Insert_Vorlage.DokNr, TB_Name_Kl, qry_Textbaustein_Replace_Insert_Vorlage.Feldname,"
strSQL = strSQL & " qry_Textbaustein_Replace_Insert_Vorlage.Herkunftsname, qry_Textbaustein_Replace_Insert_Vorlage.P1,"
strSQL = strSQL & " qry_Textbaustein_Replace_Insert_Vorlage.P1Typ"
strSQL = strSQL & " FROM qry_Textbaustein_Replace_Insert_Vorlage"
strSQL = strSQL & " WHERE (((qry_Textbaustein_Replace_Insert_Vorlage.DokNr)= " & iDocNr & "));"

CurrentDb.Execute (strSQL)

End Function


Function fReplace_Table_Felder_Ersetzen(iRch_KopfID As Long, kun_ID As Long, MA_ID As Long, VA_ID As Long)
' Die zu ersetzenden Werte aus der Tabelle tbltmp_Textbaustein_Ersetzung werden hier ersetzt.
' Dazu muss der PK-Wert der jeweiligen Tabelle bekannt sein.


'   QryFeldnameQryFeldname

Dim Loginname As String
Dim iWert As Long

'Dim iRch_KopfID As Long
'Dim kun_ID As Long
'Dim MA_ID As Long
'Dim VA_ID As Long

Dim db As DAO.Database
Dim rst As DAO.Recordset

Dim qryName As String
Dim fldName As String
Dim strWhere As String
Dim sufld As String

Loginname = atCNames(1)

Set db = CurrentDb
Set rst = db.OpenRecordset("SELECT * FROM tbltmp_Textbaustein_Ersetzung ORDER BY ID", dbOpenDynaset)
    
    With rst
        Do While Not .EOF
            .Edit
                Select Case .fields("P1")
                    Case "kun_ID"
                        iWert = kun_ID
                    Case "MA_ID"
                        iWert = MA_ID
                    Case "Rch_ID"
                        iWert = iRch_KopfID
                    Case "VA_ID"
                        iWert = VA_ID
                    Case Else
                End Select
            
                If .fields("P1Typ") = 0 Then ' int_Login Sonderfall atcnames(1) verwenden
                    qryName = .fields("QryFeldname")
                    fldName = .fields("Feldname")
                    strWhere = .fields("P1") & " = '" & Loginname & "'"
                    sufld = Nz(TLookup(fldName, qryName, strWhere))
                Else
                    qryName = .fields("QryFeldname")
                    fldName = .fields("Feldname")
                    strWhere = .fields("P1") & " = " & iWert
                    sufld = Nz(TLookup(fldName, qryName, strWhere))
                End If
                .fields("Ersetzung") = sufld
                
            .update
            .MoveNext
        Loop
        .Close
    End With
    Set rst = Nothing


End Function