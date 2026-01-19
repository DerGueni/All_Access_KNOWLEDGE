VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmOff_Outlook_aufrufen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Dim strAbsender As String
Dim strSendTO_BCC As String
Dim kun_ID As Long

Public Function VAOpen_rch()

Dim s As String
Dim i As Long

kun_ID = Nz(Me.OpenArgs, 0)

Me!SendenAn = 2
SendenAn_AfterUpdate
Me!cboOutlooktemp = 5
cboOutlooktemp_AfterUpdate
i = Nz(DLookup("kun_IDF_PersonID", "tbl_KD_Kundenstamm", "kun_ID = " & kun_ID), 0)
If i > 0 Then
    s = Nz(TLookup("adr_eMail", "tbl_KD_Ansprechpartner", "adr_ID = " & i))
End If
If Len(Trim(Nz(s))) = 0 Then
    s = Nz(TLookup("kun_email", "tbl_KD_Kundenstamm", "kun_ID = " & kun_ID))
End If
If Len(Trim(Nz(s))) > 0 Then
    Me!TO = s
End If
'Me!sub_tbltmp_Attachfile.Form.Requery

End Function


Public Function VAOpen(Optional sAtt As String, Optional SendenAn As String)
Dim s As String
If Len(Trim(Nz(sAtt))) > 0 Then

    s = sAtt
    If Len(Trim(Nz(s))) > 0 Then
        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
        Me!sub_tbltmp_Attachfile.Form.Requery
    End If
    
End If

If Len(Trim(Nz(SendenAn))) > 0 Then
    Me!TO = SendenAn
End If

End Function

Private Sub cboOutlooktemp_DblClick(Cancel As Integer)
DoCmd.OpenForm "frm_Outlook_eMail_template"
End Sub

Private Sub Form_Load()
Me.IstEinzelEmail = False
Me.cboOutlooktemp = 2
Call cboOutlooktemp_AfterUpdate
DoCmd.Maximize


    Dim strSQL As String
    Dim datHeute As Date
    Dim datEnde As Date
    
    datHeute = Date
    datEnde = DateAdd("d", 14, datHeute)
    
    strSQL = "SELECT dat_va_von, id, auftrag, ort, objekt " & _
             "FROM tbl_va_auftragstamm " & _
             "WHERE dat_va_von >= #" & Format(datHeute, "MM\/DD\/YY") & "# " & _
             "AND dat_va_von <= #" & Format(datEnde, "MM\/DD\/YY") & "# " & _
             "ORDER BY dat_va_von ASC"
    
    Me.cbo_VA_ID.RowSourceType = "Table/Query"
    Me.cbo_VA_ID.RowSource = strSQL
    Me.cbo_VA_ID.ColumnCount = 10
    Me.cbo_VA_ID.BoundColumn = 2
    Me.cbo_VA_ID.ColumnWidths = "2cm;0cm;6cm;3cm;3cm"


End Sub

Private Sub Form_Open(Cancel As Integer)

'Absender prüfen, Abbruch wenn nicht ermittelbar
strAbsender = Nz(Me!AbsendenAls)
If Len(Trim(Nz(strAbsender))) = 0 Then
    strAbsender = Nz(TLookup("int_eMail", "_tblEigeneFirma_Mitarbeiter", "int_Login = '" & atCNames(1) & "'"))
    If Len(Trim(Nz(strAbsender))) = 0 Then
        strAbsender = Get_Priv_Property("prp_eMail_Notfall_Absender")
        If Len(Trim(Nz(strAbsender))) = 0 Then
            MsgBox "Absender nicht ermittelbar", vbCritical + vbOKOnly, "Abbruch"
            Cancel = True
            Exit Sub
        End If
    End If
End If

Me!AbsendenAls = strAbsender
strSendTO_BCC = ""

If Len(Trim(Nz(Me.OpenArgs))) = 0 Then
    CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
    Me!sub_tbltmp_Attachfile.Form.Requery
End If

Me!lbl_Datum.caption = Date
'If Len(Trim(Nz(Me.OpenArgs))) > 0 Then
'    Me!cboOutlooktemp = Me.OpenArgs
'    cboOutlooktemp_AfterUpdate
'End If
End Sub

Public Function MailOpen(i As Long)
' 1 = MA, 2 = Kunde
'Form_frmOff_Outlook_aufrufen.MailOpen(n)
Me!SendenAn.Value = i
SendenAn_AfterUpdate
DoEvents
Me!SendenAn.Requery

End Function


Private Sub Befehl121_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub


Private Sub btnAttachSuch_Click()
Dim s As String
    s = AlleSuch()
    If Len(Trim(Nz(s))) > 0 Then
        CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
        Me!sub_tbltmp_Attachfile.Form.Requery
    End If
End Sub

Private Sub btnBildSuch_Click()
Dim s As String
    s = JPGSuch()
    If Len(Trim(Nz(s))) > 0 Then
        Me!Imagefile = s
    End If
End Sub


''        Dim db As DAO.Database
''        Dim rst1 As DAO.Recordset
''        Dim geschp
''        Dim emailadr As String
''        Dim Anschreib As String
''        Dim nix
''
''        geschp = Array("", "adr_eMail", "adr_P_eMail")
''
''        emailadr = ""
''        If Forms(Me.OpenArgs)!TabellenNr = 1 Then  '  Kunde
''            emailadr = Nz(Forms(Me.OpenArgs)!kun_email)
''            Anschreib = Nz(Forms(Me.OpenArgs)!Anschreiben)
''        ElseIf Forms(Me.OpenArgs)!TabellenNr = 3 Then  '  Person
''            emailadr = Nz(Forms(Me.OpenArgs)(geschp(Forms(Me.OpenArgs)!eMailArt)))
''            Anschreib = Nz(Forms(Me.OpenArgs)!adr_Anschreiben)
''        End If
''
''        If Len(Trim(emailadr)) = 0 Then
''            MsgBox "Keine eMail Adresse eingetragen"
''            Exit Sub
''        End If
''
''        'Betreff prüfen
''        If Len(Trim(Nz(Me!Betrifft))) = 0 Then
''            nix = MsgBox("Kein Betreff angegeben", vbCritical, "Abbruch")
''            Exit Sub
''        End If
''
''        '#######################################################################
''        '################## eMail aufrufen #####################################
''        '#######################################################################
''
''        'Function CreatePlainMail(Bodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False)
''
''        CreatePlainMail Anschreib & vbNewLine & vbNewLine, Me!Betrifft, emailadr
''
''        'oder
''        'Function CreateHTMLMail(HTMLBodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False)
''
''
''        '#######################################################################
''        '################## History erzeugen ###################################
''        '#######################################################################
''
''        Set db = CurrentDb
''
''                If Forms(Me.OpenArgs)!TabellenNr = 1 Then
''                    Set rst1 = db.OpenRecordset("SELECT * FROM tblAdrHistorie;", dbOpenDynaset)
''
''                    With rst1
''
''                        .AddNew
''
''                            .Fields("AdressID") = Forms(Me.OpenArgs)!kun_ID
''                            .Fields("Dateiname") = emailadr
''                            .Fields("TabellenNr") = Forms(Me.OpenArgs)!TabellenNr
''                            .Fields("HerkunftsTyp") = 2
''                            .Fields("Betreff") = Me!Betrifft
''                            .Fields("ErstVon") = Forms(Me.OpenArgs)!Erst_von
''                            .Fields("ErstDatum") = Now()
''
''                        .update
''
''                        .Close
''
''                    End With
''
''                    Set rst1 = Nothing
''
''                End If
''
''        '#######################################################################
''        '#######################################################################
''        '#######################################################################
''
''
''



'Private Sub btnOutlook_Click()
'
''' Function Get_Std_eMail_Pic() As String
'
'''Function Replace_RelPath(s As String) As String
'
'    Dim TempFilePath As String
'
'    Dim PicHeader As String
'    Dim Att1 As String
'    Dim appOutlook
'    Dim Message
'    Const olMailItem As Long = 0
'    Const olByValue As Long = 1
'    Dim s As String, t As String, u As String
'    Dim ReplText As String
'
'    Dim str_img As String
'
'    Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
'
'    If Len(Trim(Nz(Me!Imagefile))) > 0 Then
'        str_img = Replace_RelPath(Me!Imagefile)
'    Else
'        str_img = Get_Std_eMail_Pic()
'    End If
'    If Not File_exist(str_img) Then
'        str_img = Get_Std_eMail_Pic()
'    End If
'
''    s = Path_erzeugen(DBPfad() & "Attach\", False)
''    s = DBPfad() & "Attach\"
''    Call BinexStd(s & "DummyTest.txt", 9)
''    Call BinexStd(s & "siemens_Mail_Header_Std.jpg", 10)
''
''    PicHeader = s & "siemens_Mail_Header_std.jpg"
''    Att1 = s & "DummyTest.txt"
'
'    'Create a new Microsoft Outlook session
'    Set appOutlook = CreateObject("outlook.application")
'    'create a new message
'    Set Message = appOutlook.CreateItem(olMailItem)
'
'    With Message
'        .Subject = Me!Subject
'
''Startbild als unsichtbares Attach an email anhängen und dann per <img src=> als Bild anzeigen
'        'we attached an invisible the embedded image
''        TempFilePath = Environ$("temp") & "\"
'       ' Der Param 0 nach olByValue bedeutet: Bei dem Wert 0 wird der Anhang ausgeblendet
''        .Attachments.Add TempFilePath & "DashboardFile.jpg", olByValue, 0
'
'        'Then we add an html <img src=''> link to this image
'        'Note than you can customize width and height - not mandatory
'
'        s = "<span LANG=EN>"
'        .Attachments.Add str_img, olByValue, 0
'
' ' Sichtbare Attaches erzeugen
'        recsetSQL1 = "SELECT ATTDatei FRom qry_Link_Fuer_Outlook_Attaches WHERE ID = " & Me!cboLead
'        ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'        If ArrFill_DAO_OK1 Then
'            For iZl = 0 To iZLMax1
'
'                Att1 = CStr(DAOARRAY1(0, iZl))
'                .Attachments.Add Att1, olByValue, 1
'
'
'            Next iZl
'            Set DAOARRAY1 = Nothing
'        End If
'
' ' Text Teil 1 - zuerst %SIEMENS_Employee% ersetzen
'        ReplText = Nz(Me!LongText1)
'        ReplText = Replace(ReplText, "%SIEMENS_Employee%", Nz(Me!cboSiem_Empl.Column(1)), , , vbTextCompare)
'
'        s = s & "<img src='cid:" & Dir(str_img) & "'" & "width='850' height='198'><br>"
'        s = s & "<p class=style2><span LANG=EN><font FACE=Arial SIZE=3>"
'        s = s & Me!Salutation
'        s = s & "<br ><br >"
'        s = s & "<div><font face=Arial size=2 color=black>" & ReplText
'        s = s & "</font></div><ul><ul>"
'
' 'Links zwischen Text 1 und Text 2 erzeugen
'        recsetSQL1 = "SELECT HTMLText FROM qry_Link_Fuer_Outlook_Union WHERE ID = " & Me!cboLead
'        ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
'        If ArrFill_DAO_OK1 Then
'            For iZl = 0 To iZLMax1
'                Att1 = CStr(DAOARRAY1(0, iZl))
'                s = s & Att1
'            Next iZl
'            Set DAOARRAY1 = Nothing
'        End If
'
' ' Text Teil 2 - zuerst %SIEMENS_Employee% ersetzen
'        ReplText = Nz(Me!LongText2)
'        ReplText = Replace(ReplText, "%SIEMENS_Employee%", Nz(Me!cboSiem_Empl.Column(1)), , , vbTextCompare)
'
'        s = s & "</ul></ul>"
'        s = s & "<div><font face=Arial size=2 color=black>"
'        s = s & "<div><font face=Arial size=2 color=black>" & ReplText
'
'        s = s & "</font></div><div>&nbsp;</div></span>"
'
''s = ""
''s = s & "<span LANG=EN><img src='cid:siemens_Mail_Header_std.jpg'" & "width='850' height='198'><br>"
''s = s & "<p class=style2><span LANG=EN><font FACE=Calibri SIZE=3>"
''s = s & "Hello,<br ><br >"
''s = s & "<div><font face=Arial size=2 color=black>Thank you very much for your"
''s = s & " participation at the Firex 2014 exhibition.</font></div><div>&nbsp;</div>"
''s = s & "<div><font face=Arial size=2 color=black>It was our pleasure to welcome you on our booth and we hope that you were able"
''s = s & " to gain new ideas, support </font></div>"
''s = s & "<div><font face=Arial size=2 color=black>and beneficial information for your business needs. </font></div>"
''s = s & "<div>&nbsp;</div>"
''s = s & "<div><font face=Arial size=2 color=black>Please have a look at the following links to find more information about "
''s = s & "the products you were interested in: </font></div>"
''s = s & "<ul><ul>"
''s = s & "<li><a href='http://www.sql-insider.de'>Klaus Oberdalhoffs Web-site</a></li>"
''s = s & "<li><font face=Arial size=2 color=black>Siemens EX Solutions (see attached)</font></li>"
''s = s & "</ul></ul>"
''s = s & "<div><font face=Arial size=2 color=black>Should you have any questions or require further assistance, we would be pleased to help you.</font></div>"
''s = s & "<div><font face=Arial size=2 color=black>Please do not hesitate to contact your local Siemens contact at </font><font"
''s = s & "face=Arial size=2 color=blue><u>derrick.hall@siemens.com</u></font></div>"
''s = s & "<div>&nbsp;</div>"
''s = s & "<div><font face=Arial size=2 color=black>We look forward to a <strong>successful working relationship</strong> with you in the future.</font></div>"
''s = s & "<div>&nbsp;</div>"
''s = s & "<div><font face=Arial size=2 color=black>Best regards, </font></div>"
''s = s & "<div><font face=Arial size=2 color=black>&nbsp;&nbsp;</font></div>"
''s = s & "<div><font face=Arial size=2 color=black>Your Siemens Fire Safety Team</font></div>"
''s = s & "<div>&nbsp;</div></span>"
'
'.HTMLBody = s
'
'        .TO = Me!TO
'        .CC = Nz(Me!CC)
'        .BCC = Nz(Me!BCC)
'        If Len(Trim(Nz(Me1AbsendenAls.Column(1)))) > 0 Then
'            .SentOnBehalfOfName = Me1AbsendenAls.Column(1)
'        End If
'
'        .Display
'        '.Send
'    End With
'
'End Sub



'Private Sub btnOutlook_Click()
'    If Me!TextAls = 1 Then ' ASCII
'        ASCII_Outlook
'    Else
'        HTML_Outlook
'    End If
'End If


'' Function Get_Std_eMail_Pic() As String

Function Set_To_BCC()

End Function

''Function Replace_RelPath(s As String) As String
Function HTML_Outlook()
    Dim TempFilePath As String

    Dim PicHeader As String
    Dim att1 As String
    Dim appOutlook
    Dim message
    Const olMailItem As Long = 0
    Const olByValue As Long = 1
    Dim s As String, t As String, U As String
    Dim ReplText As String

    Dim str_img As String

    Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

'    s = Path_erzeugen(DBPfad() & "Attach\", False)
'    s = DBPfad() & "Attach\"
'    Call BinexStd(s & "DummyTest.txt", 9)
'    Call BinexStd(s & "siemens_Mail_Header_Std.jpg", 10)
'
'    PicHeader = s & "siemens_Mail_Header_std.jpg"
'    Att1 = s & "DummyTest.txt"

    'Create a new Microsoft Outlook session
    Set appOutlook = CreateObject("outlook.application")
    'create a new message
    Set message = appOutlook.CreateItem(olMailItem)

    With message
'       .BodyFormat = olFormatHTML
        .Bodyformat = 2  ' HTML
        .Subject = Me!Subject
        
        If Me!IstEinzelEmail = False Then
            Set_To_BCC
        End If
        

'Startbild als unsichtbares Attach an email anhängen und dann per <img src=> als Bild anzeigen
        'we attached an invisible the embedded image
'        TempFilePath = Environ$("temp") & "\"
       ' Der Param 0 nach olByValue bedeutet: Bei dem Wert 0 wird der Anhang ausgeblendet
'        .Attachments.Add TempFilePath & "DashboardFile.jpg", olByValue, 0

        'Then we add an html <img src=''> link to this image
        'Note than you can customize width and height - not mandatory

        s = "<span LANG=EN>"
        If File_exist(Nz(Me!Imagefile)) Then
            .Attachments.Add str_img, olByValue, 0
            s = s & "<img src='cid:" & Dir(str_img) & "'" & "width='850' height='198'><br>"
            s = s & "<p class=style2><span LANG=EN><font FACE=Arial SIZE=3>"
        End If

 ' Sichtbare Attaches erzeugen
        recsetSQL1 = "SELECT ATTDatei FRom qry_Link_Fuer_Outlook_Attaches WHERE ID = " & Me!cboLead
        ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
        If ArrFill_DAO_OK1 Then
            For iZl = 0 To iZLMax1

                att1 = CStr(DAOARRAY1(0, iZl))
                .Attachments.Add att1, olByValue, 1


            Next iZl
            Set DAOARRAY1 = Nothing
        End If

 ' Text Teil 1 - zuerst %SIEMENS_Employee% ersetzen
        ReplText = Nz(Me!LongText1)
        ReplText = Replace(ReplText, "%SIEMENS_Employee%", Nz(Me!cboSiem_Empl.Column(1)), , , vbTextCompare)

        s = s & Me!Salutation
        s = s & "<br ><br >"
        s = s & "<div><font face=Arial size=2 color=black>" & ReplText
        s = s & "</font></div><ul><ul>"

 'Links zwischen Text 1 und Text 2 erzeugen
        recsetSQL1 = "SELECT HTMLText FROM qry_Link_Fuer_Outlook_Union WHERE ID = " & Me!cboLead
        ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
        'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
        If ArrFill_DAO_OK1 Then
            For iZl = 0 To iZLMax1
                att1 = CStr(DAOARRAY1(0, iZl))
                s = s & att1
            Next iZl
            Set DAOARRAY1 = Nothing
        End If

 ' Text Teil 2 - zuerst %SIEMENS_Employee% ersetzen
        ReplText = Nz(Me!LongText2)
        ReplText = Replace(ReplText, "%SIEMENS_Employee%", Nz(Me!cboSiem_Empl.Column(1)), , , vbTextCompare)

        s = s & "</ul></ul>"
        s = s & "<div><font face=Arial size=2 color=black>"
        s = s & "<div><font face=Arial size=2 color=black>" & ReplText

        s = s & "</font></div><div>&nbsp;</div></span>"

's = ""
's = s & "<span LANG=EN><img src='cid:siemens_Mail_Header_std.jpg'" & "width='850' height='198'><br>"
's = s & "<p class=style2><span LANG=EN><font FACE=Calibri SIZE=3>"
's = s & "Hello,<br ><br >"
's = s & "<div><font face=Arial size=2 color=black>Thank you very much for your"
's = s & " participation at the Firex 2014 exhibition.</font></div><div>&nbsp;</div>"
's = s & "<div><font face=Arial size=2 color=black>It was our pleasure to welcome you on our booth and we hope that you were able"
's = s & " to gain new ideas, support </font></div>"
's = s & "<div><font face=Arial size=2 color=black>and beneficial information for your business needs. </font></div>"
's = s & "<div>&nbsp;</div>"
's = s & "<div><font face=Arial size=2 color=black>Please have a look at the following links to find more information about "
's = s & "the products you were interested in: </font></div>"
's = s & "<ul><ul>"
's = s & "<li><a href='http://www.sql-insider.de'>Klaus Oberdalhoffs Web-site</a></li>"
's = s & "<li><font face=Arial size=2 color=black>Siemens EX Solutions (see attached)</font></li>"
's = s & "</ul></ul>"
's = s & "<div><font face=Arial size=2 color=black>Should you have any questions or require further assistance, we would be pleased to help you.</font></div>"
's = s & "<div><font face=Arial size=2 color=black>Please do not hesitate to contact your local Siemens contact at </font><font"
's = s & "face=Arial size=2 color=blue><u>derrick.hall@siemens.com</u></font></div>"
's = s & "<div>&nbsp;</div>"
's = s & "<div><font face=Arial size=2 color=black>We look forward to a <strong>successful working relationship</strong> with you in the future.</font></div>"
's = s & "<div>&nbsp;</div>"
's = s & "<div><font face=Arial size=2 color=black>Best regards, </font></div>"
's = s & "<div><font face=Arial size=2 color=black>&nbsp;&nbsp;</font></div>"
's = s & "<div><font face=Arial size=2 color=black>Your Siemens Fire Safety Team</font></div>"
's = s & "<div>&nbsp;</div></span>"

.HTMLBody = s

        .TO = Me!TO
        .CC = Nz(Me!CC)
        .BCC = Nz(Me!BCC)
        If Len(Trim(Nz(Me!AbsendenAls.Column(1)))) > 0 Then
            .SentOnBehalfOfName = Me!AbsendenAls.Column(1)
        End If

        .Display
        '.Send
    End With

End Function


Private Function BinexStd(s As String, ID As Long)
BinExport "___Vorlagen_einlesen", s, "Picture", ID
End Function

Private Sub btnOutlook_Click()

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long

Dim myattach()
Dim arrZeiten()
Dim k As Long
Dim iZeit As Long
Dim var
Dim i As Long
Dim strAbsender As String
Dim strEmpfaenger As String

Dim IstHTML As Boolean

Dim strBetreff_In As String
Dim strBetreff_Out As String

Dim strText_In    As String
Dim strText_Out   As String
Dim strVoting_Out As String
Dim strCC         As String
Dim strBCC        As String
Dim iSendelogging As Long
Dim bDirektsenden As Boolean

'Empfänger prüfen ob gefüllt
If Len(Trim(Nz(Me!TO))) = 0 Then
    MsgBox "Empfängerliste leer", vbCritical + vbOKOnly, "Abbruch"
    Exit Sub
End If

'Absender prüfen, Abbruch wenn nicht ermittelbar
strAbsender = Nz(Me!AbsendenAls)
If Len(Trim(Nz(strAbsender))) = 0 Then
    strAbsender = Nz(TLookup("int_eMail", "_tblEigeneFirma_Mitarbeiter", "int_Login = '" & atCNames(1) & "'"))
    If Len(Trim(Nz(strAbsender))) = 0 Then
        strAbsender = Get_Priv_Property("prp_eMail_Notfall_Absender")
        If Len(Trim(Nz(strAbsender))) = 0 Then
            MsgBox "Absender nicht ermittelbar", vbCritical + vbOKOnly, "Abbruch"
            Exit Sub
        End If
    End If
End If

'ggf. Attachfile anhängen
recsetSQL1 = "tbltmp_Attachfile"
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
        
    For iZl = 0 To iZLMax1
        ReDim Preserve myattach(iZl)
        myattach(iZl) = DAOARRAY1(1, iZl)
    Next iZl
    Set DAOARRAY1 = Nothing
End If

strEmpfaenger = Nz(Me!TO)
strCC = Nz(Me.CC)
strBCC = Nz(Me.BCC)
strBetreff_In = Nz(Me!Subject)
strText_In = Nz(Me!eMailText)

strBetreff_Out = Nz(strBetreff_In)
strText_Out = Nz(strText_In)
strVoting_Out = Nz(Me!Voting_Text)

If Me!SendenAn = 1 And Me!IstEinzelEmail = True Then ' Mitarbeiter
    strBetreff_Out = Textbau_Ersetz(strBetreff_In, Me!Lst_MA.Column(0))
    strText_Out = Textbau_Ersetz(strText_In, Me!Lst_MA.Column(0))
    strVoting_Out = Textbau_Ersetz(Nz(Me!Voting_Text), Me!Lst_MA.Column(0))
ElseIf Me!SendenAn = 2 And Me!IstEinzelEmail = True Then ' Kunde
    kun_ID = Nz(Me.OpenArgs, 0)
    If Nz(kun_ID, 0) = 0 Then
        kun_ID = Me!lst_Kunden.Column(0)
    End If
    strBetreff_Out = Textbau_Ersetz(strBetreff_In, kun_ID, 1)
    strText_Out = Textbau_Ersetz(strText_In, kun_ID, 1)
    strVoting_Out = Textbau_Ersetz(Nz(Me!Voting_Text), kun_ID, 1)
End If

bDirektsenden = Me!IsDirectsend

If Me!TextAls = 2 Then
    IstHTML = -1
Else
    IstHTML = 0
End If

'Attach Ja Nein
If ArrFill_DAO_OK1 Then
    Call CreatePlainMail(IstHTML, strText_Out, strBetreff_Out, strEmpfaenger, Me!cboSendPrio, strCC, strBCC, myattach, bDirektsenden, Nz(strVoting_Out), strAbsender, CLng(Me!IstEmpfangsbest), Nz(Me!Imagefile))
Else
    Call CreatePlainMail(IstHTML, strText_Out, strBetreff_Out, strEmpfaenger, Me!cboSendPrio, strCC, strBCC, myattach, bDirektsenden, Nz(strVoting_Out), strAbsender, CLng(Me!IstEmpfangsbest), Nz(Me!Imagefile))
End If


' Parameter myattach
'-------------------
' Ein Array mit Dateinamen
' Beispiel für 2 Attachs:
' Dim att
' att = Array("D:\GEZSpruch.jpg", "D:\Kulturverlust.pdf")

' Parameter IsSend
'-----------------
' IsSend = True  -- eMail wird direkt gesendet
' IsSend = False  -- eMail wird angezeigt, um sie vor dem Senden noch editieren zu können

'Function CreatePlainMail(Bodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False, Optional Voting As String = "", Optional sendAs As String = "")

'Creates a new e-mail item and modifies its properties

'myItem.Importance 2 = High
'myItem.Importance 1 = Normal
'myItem.Importance 0 = Low

End Sub

Private Sub cbomdl1_AfterUpdate()
Me!LongText1 = TLookup("Bodytext", "tblStamm_eMail_partial", "ID = " & Me!cbomdl1)
End Sub


Private Sub cboOutlooktemp_AfterUpdate()
Dim fldstr As String

Dim i As Long

'Me!Imagefile = Nz(Me!cboOutlooktemp.Column(1))
If Len(Trim(Nz(Me!cboOutlooktemp.Column(2)))) > 0 Then
    Me!TO = Nz(Me!cboOutlooktemp.Column(2))
End If
If Len(Trim(Nz(Me!cboOutlooktemp.Column(3)))) > 0 Then
    Me!CC = Nz(Me!cboOutlooktemp.Column(3))
End If
If Len(Trim(Nz(Me!cboOutlooktemp.Column(4)))) > 0 Then
    Me!BCC = Nz(Me!cboOutlooktemp.Column(4))
End If
If Len(Trim(Nz(Me!cboOutlooktemp.Column(5)))) > 0 Then
    Me!Subject = Nz(Me!cboOutlooktemp.Column(5))
End If
If Len(Trim(Nz(Me!cboOutlooktemp.Column(6)))) > 0 Then
    Me!TextAls.Value = Nz(Me!cboOutlooktemp.Column(6))
End If
DoEvents
Me!TextAls.Requery

TextAls_AfterUpdate

Me!eMailText = TLookup("TextInhalt", "tbl_eMail_Template_complete", "ID = " & Me!cboOutlooktemp.Column(0))

End Sub


Private Sub btnGetFolder_Click()

    Me!pfad = Folder_Such("In welchem Directory wollen Sie Ihren Brief abspeichern ?")
    If Len(Trim(Nz(Me!pfad))) = 0 Then
        Me!pfad = "C:\Eigene Dateien\"
    End If
    If Right(Trim(Nz(Me!pfad)), 1) <> "\" Then
        Me!pfad = Trim(Me!pfad) & "\"
    End If

End Sub

Private Sub btnNeuDoc_Click()
    Me!Docname = Neu_Doc_Erst(Me!DocArt, Me!DocExt)
End Sub

Private Sub Pfad_AfterUpdate()
    Me!Docname = Neu_Doc_Erst(Me!DocArt, Me!DocExt)
End Sub

Private Sub DocArt_AfterUpdate()
    Me!Docname = Neu_Doc_Erst(Me!DocArt, Me!DocExt)

End Sub

Private Sub DocExt_AfterUpdate()
    Me!Docname = Neu_Doc_Erst(Me!DocArt, Me!DocExt)

End Sub



Private Sub btnWinWord_Click()

'Dim appWd As Word.Application
'Dim WordDoc As Word.DOCUMENT

Dim appWd As Object
Dim WordDoc As Object
Const wdDoNotSaveChanges = 0
Const wdSeekCurrentPageFooter = 10
Const wdSeekMainDocument = 0
Const wdParagraph = 4
Const wdMove = 0
Const wdWindowStateMaximize = 1

Dim ctl As control
Dim nix

Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim rst1 As DAO.Recordset
Dim STextmarke As String
Dim SFeldName As String
Dim SMuss As Boolean

'Dateiname prüfen
If Len(Trim(Nz(Me!Docname))) = 0 Then
    nix = MsgBox("Kein Dateiname angegeben", vbCritical, "Abbruch")
    Exit Sub
Else

'Property sichern
    nix = Set_Priv_Property("DocVorlage", Me!Vorlage)
    nix = Set_Priv_Property("DocPfad", Me!pfad)
    nix = Set_Priv_Property("DocPraefix", Me!DocArt)

    If File_exist(Me!pfad & Me!Docname) Then
        nix = MsgBox("Die Datei existiert bereits" & _
        vbCrLf & "Dateiname ist : " & Me!pfad & Me!Docname & vbCrLf & _
        "Möchten Sie die Datei überschreiben ?", _
        vbYesNo + vbCritical, "WinWord - Datei existiert bereits")
        If nix = vbNo Then
            Exit Sub
        End If
    End If
End If

'Funktion Path_erzeugen(ByVal Pathnamen As String, Optional CreatWarn As Boolean = True, Optional NoWarnOnErr As Boolean = False) As Boolean
If Not Path_erzeugen(Me!pfad) Then
    Exit Sub
End If

On Error Resume Next 'See if Word is running
   Set appWd = GetObject(, "Word.Application")
    If Err.Number <> 0 Then 'Word Not running
      Err.clear   ' Clear Err object in case error occurred.
      'Create a new instance of Word
      Set appWd = CreateObject("Word.Application")
      'Create an instance of Word
    Else
        appWd.Activate
    End If


On Error GoTo 0
'On Error GoTo btnWinWord_Error
'On Error Resume Next

    With appWd
        ' Vorlage als Dokument öffnen
        .Documents.Add template:=Chr(34) & Me!Vorlage & Chr(34)

' Textmarken / Feldnamen aus Tabelle "tblWordBrfSetup" einlesen, alle Textmarken durchlaufen
' Messagebox, wenn Textmarke fehlt, sie aber als MUSS deklariert ist.

        Set db = CurrentDb
        Set rst = db.OpenRecordset("SELECT * FROM tblWordBrfSetup WHERE SindVorhanden = True;", dbOpenDynaset)

            Do While Not rst.EOF

                rst.Edit

                    STextmarke = rst.fields(0)
                    SFeldName = rst.fields(1)
                    SMuss = rst.fields(2)

                    If SMuss = True And .ActiveDocument.Bookmarks.Exists(STextmarke) = False Then
                            nix = MsgBox("Textmarke " & STextmarke & " fehlt", vbCritical + vbOKCancel, "Textmarke ist Pflicht")
                            If nix = vbCancel Then
                                .Quit (wdDoNotSaveChanges)
                                Exit Sub
                            End If
                    End If

                    If .ActiveDocument.Bookmarks.Exists(STextmarke) = True Then
                        If Not SFeldName = "Betrifft" Then
                            If ControlExist(Forms(Me.OpenArgs), SFeldName) Then
                                .ActiveDocument.Bookmarks(STextmarke).Select
                                .Selection.InsertAfter Nz(Forms(Me.OpenArgs)(SFeldName))
                            Else
                                nix = MsgBox("Feldname " & Chr(34) & SFeldName & Chr(34) & " falsch / fehlerhaft", vbCritical + vbOKCancel, "Feldname fehlt, Maske: " & Forms(Me.OpenArgs).Name)
                                If nix = vbCancel Then
                                    .Quit (wdDoNotSaveChanges)
                                    Exit Sub
                                End If
                            End If
                        Else
                            .ActiveDocument.Bookmarks(STextmarke).Select
                            .Selection.InsertAfter Nz(Me!Betrifft)
                        End If
                    End If


    '            rst.Update  'Kein Update erforderlich, da nur lesend

                rst.MoveNext
                If rst.EOF Then Exit Do    ' für den Fall, daß wir uns auf dem letzten Datensatz befinden

            Loop

            rst.Close

        ' Dokument sichern
        .ActiveDocument.SaveAs Chr(34) & Me!pfad & Me!Docname & Chr(34)
        .ActiveWindow.ActivePane.view.SeekView = wdSeekCurrentPageFooter
        .Selection.WholeStory
        .Selection.fields.update
        .ActiveWindow.ActivePane.view.SeekView = wdSeekMainDocument

        .Selection.EndOf Unit:=wdParagraph, Extend:=wdMove

        '#######################################################################
        '################## History erzeugen ###################################
        '#######################################################################

        Set rst1 = db.OpenRecordset("SELECT * FROM tblAdrHistorie;", dbOpenDynaset)

        With rst1

            .AddNew

            .fields("AdressID") = Forms(Me.OpenArgs)!kun_ID
            .fields("TabellenNr") = Forms(Me.OpenArgs)!TabellenNr
            .fields("HerkunftsTyp") = 1
            .fields("Dateiname") = Me!pfad & Me!Docname
            .fields("Betreff") = Me!Betrifft
            .fields("ErstVon") = Forms(Me.OpenArgs)!Erst_von
            .fields("ErstDatum") = Now()

            .update

            .Close

        End With

        Set rst1 = Nothing

        If SysCmd(SYSCMD_GETOBJECTSTATE, acForm, "frmWinWordDemoAdresse") Then Forms!frmWinWordDemoAdresse.Requery

        '#######################################################################
        '#######################################################################
        '#######################################################################

        ' Sichtbar setzen
        .Visible = True
        .Activate

        ' Maximieren
        .WindowState = wdWindowStateMaximize

        'Drucken ?
'        .ActiveDocument.PrintOut  Background:=False

'        .Quit
    End With

    Set rst = Nothing

btnWinWord_Exit:
    Exit Sub

btnWinWord_Error:
    If Err.Number = 5941 Then
        nix = MsgBox("Falsche WinWordVorlage (Textmarke fehlt)" & _
        vbCrLf & "Vorlage war : " & Me!Vorlage, _
        vbCritical, "WinWord Abbruch")
        appWd.Quit
        GoTo btnWinWord_Exit
    Else
        nix = MsgBox("Allgemeiner Fehler bei WinWord-Aufruf" & _
        vbCrLf & "Fehler-Nr ist : " & Err.Number & " " & Err.description, _
        vbCritical, "WinWord Abbruch")
        appWd.Quit (wdDoNotSaveChanges)
        GoTo btnWinWord_Exit
    End If

End Sub


Private Sub btnVorlage_Click()
On Error GoTo Error_Öffnen_Click
'Es wird das Klassenmodul FileOpen aufgerufen
'Erläuterungen im Code des Moduls

Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_READONLY = &H1

'Das Objekt (Klassenmodul) definieren und referenzieren
Dim fd As New FileDialog

' Voreinstellungen des Objektes einstellen
With fd
      .DialogTitle = "Vorhandene WinWord Vorlagen (*.DOT)"
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .InitDir = "C:\Eigene Dateien"
      .InitDir = GetTemplatePath()
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST

' Die Filterbox (mit max. 5 Werten) füllen
      .Filter1Text = "DOT-Dateien (*.dot?)"
      .Filter1Suffix = "*.dot?"
      .Filter2Text = "DOC-Dateien (*.doc?)"
      .Filter2Suffix = "*.doc?"
      .Filter3Text = "RTF-Dateien (*.rtf)"
      .Filter3Suffix = "*.rtf"
      .Filter4Text = "Text-Dateien (*.txt)"
      .Filter4Suffix = "*.txt"
      .Filter5Text = "Alle Dateien (*.*)"
      .Filter5Suffix = "*.*"

'      ... bis Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With

'   fd.ShowOpen     wäre die Kurzform

 ' Falls kein Dateiname ausgewählt wurde, wird normal.dot verwendet ...
   If fd.fileName = "" Then
      Me!Vorlage = GetTemplatePath() & "\Normal.dot"
   Else
      Me!Vorlage = fd.fileName
   End If

Exit_Öffnen_Click:
   Exit Sub
Error_Öffnen_Click:
   MsgBox Error$, , "Error_Öffnen_Clickd Sub"
   Resume Exit_Öffnen_Click

End Sub


Function GetTemplatePath() As String

Dim XDrive As String
Dim XDirName As String
Dim XfName As String
Dim XExt As String

On Error Resume Next

' This function returns the Path of WinWord Template Path as a string.

    Static tempPath As String
    Static PathAlreadySearched As Integer

    If PathAlreadySearched <> 14 Then
        PathAlreadySearched = 14
        tempPath = QueryValue(HKEY_CURRENT_USER, _
        "SOFTWARE\Microsoft\Office\14.0\Common\FileNew\LocalTemplates", "")
        If Not File_exist(tempPath & "\Normal.dot") Then
        ' Pfad bei Standard-Installation
            tempPath = Server
            If Not File_exist(tempPath & "Normal.dotm") Then
                MsgBox "Normal.dot nicht gefunden, Abbruch"
                Exit Function
'                tempPath = SearchFile("Normal.dot", "")
'                If Not File_exist(tempPath) Then
'                    tempPath = ""
'                Else
'                    Call FParsePath(tempPath, XDrive, XDirName, XfName, XExt)
'                    tempPath = XDrive & XDirName
'                    tempPath = Left(tempPath, Len(tempPath) - 1)
'                End If
            End If
        End If
    End If

    GetTemplatePath = tempPath
End Function

Function Neu_Doc_Erst(ByVal typ As String, ByVal Ext As String) As String

Dim nNr As String
Dim Pfad1 As String

Pfad1 = ""

' Typ testen
If typ = "" Or Len(typ) = 0 Or Len(typ) > 4 Then
    typ = "TXT"
End If

' Typ darf kein "." enthalten
If InStr(1, Nz(typ), ".", vbTextCompare) <> 0 Then
    typ = "TXT"
End If

' Ext muß 3 / 4 stellig sein
If Len(Nz(Ext)) < 3 Or Len(Nz(Ext)) > 4 Then
    Ext = "DOCX"
End If

' Ext darf kein "." enthalten
If InStr(1, Nz(Ext), ".", vbTextCompare) <> 0 Then
    Ext = "DOCX"
End If

' Pfad holen
Pfad1 = Me!pfad ' Rückgabe immer incl. "\"

' Neue Nummer ermitteln
nNr = neueNr(Pfad1, typ, Ext)

' Dateiname excl. Pfad übergeben
Neu_Doc_Erst = typ & Right$(100000 + nNr, 5) & "." & Ext

End Function

Private Function neueNr(ByVal Pfad1 As String, ByVal typ As String, ByVal Ext As String) As Integer

Dim Name1 As String, Nr As Variant, letzteNr As Integer

Pfad1 = Pfad1 & typ & "*." & Ext  ' Pfad für Dir setzen.
Name1 = Dir(Pfad1, vbNormal) ' Ersten Eintrag abrufen.

letzteNr = 0
Do While Name1 <> "" ' Schleife beginnen.
    Nr = val(Mid$(Name1, 4, 5))
    If Nr > letzteNr Then
        letzteNr = Nr
    End If
    Name1 = Dir ' Nächsten Eintrag abrufen.
Loop

neueNr = letzteNr + 1

End Function


Private Sub Form_Timer()
'    Form_Current
    Me.TimerInterval = 0
End Sub

Private Sub IstEinzelEmail_AfterUpdate()
If Me!IstEinzelEmail = True Then
    Me!IstEinzelEmail.caption = "Einzel eMail"
    Me!AbsendenAls = strAbsender
    Me!TO = ""
    Me!CC = ""
    Me!BCC = ""
Else
    Me!IstEinzelEmail.caption = "Serien eMail"
    Me!AbsendenAls = strAbsender
    Me!TO = strAbsender
    Me!CC = ""
    Me!BCC = ""
End If
End Sub

Private Sub IstSMS_AfterUpdate()
'Vorgedacht für spätere SMS Anbindung
If Me!IstSMS Then
    CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
    Me!sub_tbltmp_Attachfile.Visible = False
    Me!btnAttachSuch.Visible = False
    Me!TextAls = 1
    TextAls_AfterUpdate
    Me!TextAls.Visible = False
    Me!Lst_MA.RowSource = "qry_eMail_MA_SMS"
    Me!Lst_MA.Requery
Else
    Me!sub_tbltmp_Attachfile.Visible = True
    Me!btnAttachSuch.Visible = True
    Me!TextAls.Visible = True
    Me!Lst_MA.RowSource = "qry_eMail_MA_Std"
    Me!Lst_MA.Requery
End If
End Sub

Private Sub Liste256_DblClick(Cancel As Integer)
If Me!IstEinzelEmail Then
    Me!TO = Nz(Me!Liste256.Column(2))
Else
    If Len(Trim(Nz(Me!BCC))) > 0 Then Me!BCC = Me!BCC & "; "
    Me!BCC = Me!BCC & Nz(Me!Liste256.Column(2))
End If
End Sub

Private Sub lst_Kunden_DblClick(Cancel As Integer)
'If Me!IstEinzelEmail Then
'    Me!TO = Nz(Me!lst_Kunden.Column(3))
'    Me!eMailText = Nz(Me!lst_Kunden.Column(2)) & vbNewLine & vbNewLine & Nz(Me!eMailText)
'End If

If Me!IstEinzelEmail Then
    Me!TO = Nz(Me!lst_Kunden.Column(3))
Else
    If Len(Trim(Nz(Me!BCC))) > 0 Then Me!BCC = Me!BCC & "; "
    Me!BCC = Me!BCC & Nz(Me!lst_Kunden.Column(3))
End If

End Sub

Private Sub Lst_MA_DblClick(Cancel As Integer)
If Me!IstEinzelEmail Then
    Me!TO = Nz(Me!Lst_MA.Column(3))
Else
    If Len(Trim(Nz(Me!BCC))) > 0 Then Me!BCC = Me!BCC & "; "
    Me!BCC = Me!BCC & Nz(Me!Lst_MA.Column(3))
End If
End Sub

Private Sub Lst_MA2_DblClick(Cancel As Integer)

If Me!IstEinzelEmail Then
    Me!TO = Nz(Me!Lst_MA2.Column(3))
Else
    If Len(Trim(Nz(Me!BCC))) > 0 Then Me!BCC = Me!BCC & "; "
    Me!BCC = Me!BCC & Nz(Me!Lst_MA2.Column(3))
End If
End Sub


Public Sub NurAktiveMA_AfterUpdate()
'Dim listselect As Operation
Dim listselect As String

listselect = "SELECT ID, Nachname, Vorname, email"

Select Case Me!NurAktiveMA

    Case 1 ' Nur Aktive
        Me!Lst_MA.RowSource = listselect & " FROM qry_eMail_MA_Std Where Anstellungsart_ID = 3 or Anstellungsart_ID = 5 ORDER BY Nachname, Vorname;"
    Case 2 ' Nur Festangestellte  'Anstellungsart 3
        Me!Lst_MA.RowSource = listselect & " FROM qry_eMail_MA_Std Where Anstellungsart_ID = 3 ORDER BY Nachname, Vorname;"
    Case 3 ' Nur Minijobber  ' Anstellungsart 5
        Me!Lst_MA.RowSource = listselect & " FROM qry_eMail_MA_Std Where Anstellungsart_ID = 5 ORDER BY Nachname, Vorname;"
    Case 4 ' Nur Unternehmer  ' IstSubunternehmer = True
        Me!Lst_MA.RowSource = listselect & " FROM qry_eMail_MA_Std Where IstSubunternehmer = True ORDER BY Nachname, Vorname;"
    Case Else ' Alle
        Me!Lst_MA.RowSource = listselect & " FROM qry_eMail_MA_Std Where Anstellungsart_ID = 3 or Anstellungsart_ID = 5 ORDER BY Nachname, Vorname;"
End Select

End Sub

Private Sub SendenAn_AfterUpdate()

strSendTO_BCC = ""
Me!BCC = ""

Me!pg_MA.Visible = False
Me!pg_Kunde.Visible = False
Me!pg_Vor.Visible = False
Me!pg_KundeMit.Visible = False

Select Case Me!SendenAn
    Case 1
        Me!pg_MA.Visible = True
    Case 2
        Me!pg_Kunde.Visible = True
    Case 3
        Me!pg_Vor.Visible = True
    Case 4
        Me!pg_KundeMit.Visible = True
    Case Else
End Select

End Sub

Private Sub TextAls_AfterUpdate()
On Error Resume Next
If Me!TextAls = 1 Then ' ASCII
    Me!eMailText.TextFormat = acTextFormatPlain
    Me!Imagefile = ""
    Me!Imagefile.Visible = False
    Me!btnBildSuch.Visible = False
Else ' HTML
    Me!eMailText.TextFormat = acTextFormatHTMLRichText
    Me!Imagefile.Visible = False
    Me!btnBildSuch.Visible = False
End If
End Sub
' ComboBox: cbo_VA_ID  -> Ereignis: Nach Aktualisierung (AfterUpdate)
Private Sub cbo_VA_ID_AfterUpdate()
    On Error GoTo ErrH

    If Not IsNull(Me.cbo_VA_ID) Then
        If MsgBox("Mail Adressen der Mitarbeiter für diesen Auftrag hinzufügen?", _
                  vbOKCancel + vbQuestion, "E-Mail Adressen") = vbOK Then
            FuegeEmailsHinzu CLng(Me.cbo_VA_ID.Value)
        End If
    End If

ExitH:
    Exit Sub
ErrH:
    MsgBox "Fehler in cbo_VA_ID_AfterUpdate: " & Err.Number & " - " & Err.description, vbExclamation
    Resume ExitH
End Sub
' Im gleichen Formularmodul belassen (oder als Public in einem Standardmodul, wenn mehrfach genutzt)
Private Sub FuegeEmailsHinzu(ByVal lngVAID As Long)
    On Error GoTo ErrH

    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim strSQL As String
    Dim strEmails As String

    Set db = CurrentDb
    strSQL = "SELECT DISTINCT m.EMail " & _
             "FROM tbl_ma_mitarbeiterstamm AS m " & _
             "INNER JOIN tbl_ma_va_zuordnung AS z ON m.id = z.ma_id " & _
             "WHERE z.va_id = " & lngVAID & " " & _
             "AND m.EMail Is Not Null AND m.EMail <> ''"

    Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

    Do While Not rs.EOF
        If Len(Trim$(Nz(rs!Email, ""))) > 0 Then
            If Len(strEmails) > 0 Then strEmails = strEmails & "; "
            strEmails = strEmails & Trim$(rs!Email)
        End If
        rs.MoveNext
    Loop

    rs.Close: Set rs = Nothing
    Set db = Nothing

    If Len(strEmails) > 0 Then
        Me!BCC = strEmails     ' Sicherstellen, dass ein Steuerelement "BCC" auf dem Formular existiert
    Else
        MsgBox "Keine E-Mail-Adressen gefunden.", vbInformation
    End If

ExitH:
    Exit Sub
ErrH:
    If Not rs Is Nothing Then On Error Resume Next: rs.Close
    Set rs = Nothing: Set db = Nothing
    MsgBox "Fehler beim Ermitteln der E-Mail-Adressen: " & Err.Number & " - " & Err.description, vbExclamation
    Resume ExitH
End Sub


