Option Compare Database
Option Explicit

' =========================================================
'  Mail ? Auftrag
'  - Betreff zerlegen in VA / Objekt / Ort
'  - Datum, MA-Anzahl und Zeiten aus Text lesen
'  - Auftrag + Tag + Schicht anlegen
' =========================================================

Public Function MailToAuftrag_FromMailText( _
        ByVal Betreff As String, _
        ByVal MailText As String) As Long

    Dim dDatum As Date
    Dim iAnzMA As Long
    Dim tVon As Date, tBis As Date
    Dim sVA As String, sObjekt As String, Sort As String

    ' --- 1. Betreff zerlegen ---
    ParseBetreffToParts Betreff, sVA, sObjekt, Sort

    ' --- 2. Restliche Daten parsen ---
    dDatum = ParseDatum(Betreff & vbCrLf & MailText)
    iAnzMA = ParseMitarbeiter(MailText)
    ParseZeiten MailText, tVon, tBis

    ' --- 3. Plausibilitätscheck ---
    If sVA = "" Or dDatum = 0 Or iAnzMA = 0 Or tVon = 0 Or tBis = 0 Then
        MailToAuftrag_FromMailText = 0
        Exit Function
    End If

    ' --- 4. Auftrag anlegen ---
    MailToAuftrag_FromMailText = CreateAuftrag_EinTag( _
                                    sVA, sObjekt, Sort, _
                                    dDatum, _
                                    iAnzMA, _
                                    tVon, tBis)
End Function

' ---------------------------------------------------------
' Betreff ? VA, Objekt, Ort
' ---------------------------------------------------------
Private Sub ParseBetreffToParts( _
        ByVal Betreff As String, _
        ByRef sVA As String, _
        ByRef sObjekt As String, _
        ByRef Sort As String)

    Dim txt As String
    Dim re As Object
    Dim arr() As String
    Dim i As Long

    sVA = "": sObjekt = "": Sort = ""

    txt = Betreff

    ' Datum(en) rauswerfen
    Set re = CreateObject("VBScript.RegExp")
    re.IgnoreCase = True
    re.Global = True
    re.Pattern = "\d{1,2}\.\d{1,2}\.(\d{2}|\d{4})"
    txt = re.Replace(txt, "")

    ' Worte wie "Anfrage für", Wochentage entfernen (optional)
    txt = Replace(txt, "Anfrage für", "", , , vbTextCompare)
    txt = Replace(txt, "Anfrage", "", , , vbTextCompare)
    txt = Replace(txt, "Montag", "", , , vbTextCompare)
    txt = Replace(txt, "Dienstag", "", , , vbTextCompare)
    txt = Replace(txt, "Mittwoch", "", , , vbTextCompare)
    txt = Replace(txt, "Donnerstag", "", , , vbTextCompare)
    txt = Replace(txt, "Freitag", "", , , vbTextCompare)
    txt = Replace(txt, "Samstag", "", , , vbTextCompare)
    txt = Replace(txt, "Sonntag", "", , , vbTextCompare)

    txt = Trim$(txt)
    If Left$(txt, 1) = "," Then txt = Mid$(txt, 2)
    txt = Trim$(txt)

    If Len(txt) = 0 Then Exit Sub

    arr = Split(txt, ",")

    ' alle Teile trimmen
    For i = LBound(arr) To UBound(arr)
        arr(i) = Trim$(arr(i))
    Next i

    Select Case UBound(arr) - LBound(arr) + 1
        Case 1
            sVA = arr(0)
        Case 2
            sVA = arr(0)
            sObjekt = arr(1)
        Case Is >= 3
            sVA = arr(0)
            sObjekt = arr(1)
            For i = 2 To UBound(arr)
                If Sort <> "" Then Sort = Sort & ", "
                Sort = Sort & arr(i)
            Next i
    End Select
End Sub

' ---------------------------------------------------------
' Datum im Format dd.mm.yyyy oder dd.mm.yy
' ---------------------------------------------------------
Private Function ParseDatum(ByVal Text As String) As Date
    Dim re As Object, m As Object
    Dim s As String, teile() As String, Jahr As Long

    Set re = CreateObject("VBScript.RegExp")
    re.IgnoreCase = True
    re.Pattern = "(\d{1,2}\.\d{1,2}\.(\d{2}|\d{4}))"

    If re.TEST(Text) Then
        Set m = re.Execute(Text)(0)
        s = m.SubMatches(0)  ' z.B. 11.11.25 oder 11.11.2025

        teile = Split(s, ".")
        If UBound(teile) = 2 Then
            Jahr = CLng(teile(2))
            If Jahr < 100 Then
                Jahr = 2000 + Jahr   ' 25 ? 2025
            End If
            ParseDatum = DateSerial(Jahr, CLng(teile(1)), CLng(teile(0)))
        End If
    End If
End Function

' ---------------------------------------------------------
' Mitarbeiterzahl
' Beispiele: 9x Dienst / 9 x Dienste / 9 MA / 9 Mitarbeiter
' ---------------------------------------------------------
Private Function ParseMitarbeiter(ByVal Text As String) As Long
    Dim re As Object, m As Object

    Set re = CreateObject("VBScript.RegExp")
    re.IgnoreCase = True
    re.Pattern = "(\d+)\s*(x|X|mal)?\s*(Dienst|Dienste|MA|Mitarbeiter)"

    If re.TEST(Text) Then
        Set m = re.Execute(Text)(0)
        ParseMitarbeiter = CLng(m.SubMatches(0))
    End If
End Function

' ---------------------------------------------------------
' Zeiten (Start/Ende)
' Erkennt 17:45 / 17.45 usw.
' ---------------------------------------------------------
Private Sub ParseZeiten(ByVal Text As String, ByRef tVon As Date, ByRef tBis As Date)
    Dim re As Object, ms As Object
    Dim sVon As String, sBis As String

    tVon = 0: tBis = 0

    Set re = CreateObject("VBScript.RegExp")
    re.IgnoreCase = True
    re.Global = True
    re.Pattern = "(\d{1,2}[:\.]\d{2})"

    If re.TEST(Text) Then
        Set ms = re.Execute(Text)
        If ms.Count >= 2 Then
            sVon = ms(0).SubMatches(0)
            sBis = ms(1).SubMatches(0)

            sVon = Replace(sVon, ".", ":")
            sBis = Replace(sBis, ".", ":")

            tVon = CDate(sVon)
            tBis = CDate(sBis)
        End If
    End If
End Sub

' ---------------------------------------------------------
' Auftrag + Tag + Schicht anlegen (1-tägiger Auftrag)
' ---------------------------------------------------------
Public Function CreateAuftrag_EinTag( _
        ByVal sVA As String, _
        ByVal sObjekt As String, _
        ByVal Sort As String, _
        ByVal dDatum As Date, _
        ByVal iAnzMA As Long, _
        ByVal tVon As Date, _
        ByVal tBis As Date) As Long

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim sql As String
    Dim lngVA_ID As Long
    Dim lngVADatum_ID As Long
    Dim sUser As String

    Set db = CurrentDb
    sUser = Environ$("USERNAME")

    ' --- 1. Auftragstamm ---
    sql = "INSERT INTO tbl_VA_Auftragstamm " & _
          "(Auftrag, Objekt, Ort, Dat_VA_Von, Dat_VA_Bis, AnzTg, Erst_von, Erst_am, Veranst_Status_ID) " & _
          "VALUES (" & _
          "'" & Replace(sVA, "'", "''") & "', " & _
          IIf(sObjekt = "", "Null", "'" & Replace(sObjekt, "'", "''") & "'") & ", " & _
          IIf(Sort = "", "Null", "'" & Replace(Sort, "'", "''") & "'") & ", " & _
          "#" & Format$(dDatum, "yyyy-mm-dd") & "#, " & _
          "#" & Format$(dDatum, "yyyy-mm-dd") & "#, " & _
          "1, '" & Replace(sUser, "'", "''") & "', Now(), 1);"

    db.Execute sql, dbFailOnError

    Set rs = db.OpenRecordset("SELECT @@IDENTITY AS NewID")
    lngVA_ID = rs!newID
    rs.Close

    ' --- 2. Tag in tbl_VA_AnzTage ---
    sql = "INSERT INTO tbl_VA_AnzTage (VA_ID, VADatum, TVA_Soll, TVA_Ist) " & _
          "VALUES (" & lngVA_ID & ", #" & Format$(dDatum, "yyyy-mm-dd") & "#, " & iAnzMA & ", 0);"
    db.Execute sql, dbFailOnError

    Set rs = db.OpenRecordset("SELECT @@IDENTITY AS NewID")
    lngVADatum_ID = rs!newID
    rs.Close

    ' --- 3. Schicht in tbl_VA_Start ---
    sql = "INSERT INTO tbl_VA_Start " & _
          "(VA_ID, VADatum_ID, VADatum, MA_Anzahl, VA_Start, VA_Ende, MVA_Start, MVA_Ende) " & _
          "VALUES (" & lngVA_ID & ", " & lngVADatum_ID & ", #" & _
          Format$(dDatum, "yyyy-mm-dd") & "#, " & iAnzMA & ", #" & _
          Format$(tVon, "hh:nn:ss") & "#, #" & _
          Format$(tBis, "hh:nn:ss") & "#, #" & _
          Format$(dDatum + tVon, "yyyy-mm-dd hh:nn:ss") & "#, #" & _
          Format$(dDatum + tBis, "yyyy-mm-dd hh:nn:ss") & "#);"

    db.Execute sql, dbFailOnError

    CreateAuftrag_EinTag = lngVA_ID
End Function