Option Compare Database
Option Explicit

    'Für Mailversand
    Const cdoSendUsingMethod = "http://schemas.microsoft.com/cdo/configuration/sendusing"
    Const cdoSMTPUseSSL = "http://schemas.microsoft.com/cdo/configuration/smtpusessl"
    Const cdoSendUsingPort = 2
    Const cdoSMTPServer = "http://schemas.microsoft.com/cdo/configuration/smtpserver"
    Const cdoSMTPServerPort = "http://schemas.microsoft.com/cdo/configuration/smtpserverport"
    Const cdoSMTPConnectionTimeout = "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"
    Const cdoSMTPAuthenticate = "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"
    Const cdoBasic = 1
    Const cdoSendUserName = "http://schemas.microsoft.com/cdo/configuration/sendusername"
    Const cdoSendPassword = "http://schemas.microsoft.com/cdo/configuration/sendpassword"
    
'Neue Mailerzeugung ohne Outlook
Function zCreatePlainMail(IstHTML As Variant, Bodytext As String, Subject As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False, Optional Voting As String = "", Optional sendAs As String = "", Optional bReadReceipt As Boolean = False, Optional strHeaderbild As String) As String

    Dim config  'As CDO.Configuration
    Dim message 'As CDO.Message
    Dim fields  'As ADODB.Fields
    Dim Body     As String
    Dim i        As Integer
    
    Set message = CreateObject("CDO.Message") 'server.CreateObject("CDO.Message")
    Set config = CreateObject("CDO.Configuration") 'server.CreateObject("CDO.Configuration")
    Set fields = config.fields
   
On Error GoTo Err

    config.Load -1
    With fields
        .item(cdoSendUsingMethod) = cdoSendUsingPort
        .item(cdoSMTPUseSSL).Value = False
        .item(cdoSMTPServer).Value = "in-v3.mailjet.com"
        '.Item(cdoSMTPServer).Value = "mail.gmx.net"
        .item(cdoSMTPServerPort).Value = 25
        .item(cdoSMTPConnectionTimeout).Value = 10
        .item(cdoSMTPAuthenticate).Value = cdoBasic
        .item(cdoSendUserName).Value = "97455f0f699bcd3a1cb8602299c3dadd"
        .item(cdoSendPassword).Value = "1dd9946e4f632343405471b1b700c52f"
        '.Item(cdoSendUserName).Value = "consec-auftragsplanung@gmx.de"
        '.Item(cdoSendPassword).Value = ""
        .update
    End With
    
    'HTMLBody
    Body = Bodytext
    
    'Fehler beim Erzeugen des Bodys
    If IsNumeric(Left(Body, 1)) Then
        zCreatePlainMail = "Fehler beim Erzeugen des Bodys: " & Body
        Exit Function
    End If
    
    'Variablen ersetzen
    Body = Replace(Body, "[A_Sender]", detect_sender)
   
    'Umlaute anpassen
    Body = Replace(Body, "Ü", "&#220;", , , vbBinaryCompare)
    Body = Replace(Body, "Ä", "&#196;", , , vbBinaryCompare)
    Body = Replace(Body, "Ö", "&#214;", , , vbBinaryCompare)
    Body = Replace(Body, "ü", "&#252;", , , vbBinaryCompare)
    Body = Replace(Body, "ä", "&#228;", , , vbBinaryCompare)
    Body = Replace(Body, "ö", "&#246;", , , vbBinaryCompare)
    Body = Replace(Body, "ß", "&#223;", , , vbBinaryCompare)
    Body = Replace(Body, "Ãœ", "&#220;")  'Ü
    Body = Replace(Body, "Ã„", "&#196;")  'Ä
    Body = Replace(Body, "Ã–", "&#214;")  'Ö
    Body = Replace(Body, "Ã¼", "&#252;")  'ü
    Body = Replace(Body, "Ã¤", "&#228;")  'ä
    Body = Replace(Body, "Ã¶", "&#246;")  'ö
    Body = Replace(Body, "ÃŸ", "&#223;")  'ß
    Body = Replace(Body, "ï", "")         'Mist raus
    Body = Replace(Body, "¿", "")         'Mist raus
    
    With message
    Set .Configuration = config
        .TO = SendTo
        .CC = SendToCC
        .BCC = SendToBCC
        .FROM = """Consec Auftragsplanung"" <siegert@consec-nuernberg.de>"
        .Subject = Subject
        .HTMLBody = Body
    
         'Normale Attaches dranhängen
        If Not IsMissing(myattach) Then
            If Not IsNull(myattach) Then
                If Not IsEmpty(myattach) Then
                    If IsArray(myattach) Then
                        For i = LBound(myattach) To UBound(myattach)
                            If File_exist(myattach(i)) Then
                                .addAttachment myattach(i)
                            End If
                        Next i
                    End If
                End If
            End If
        End If
        
        .send
    End With
     
     
    'is gut
    zCreatePlainMail = "Email wurde versendet"
    'Log
    CurrentDb.Execute "INSERT INTO tbl_Log_eMail_Sent(SendDate,Absender,Betreff,MailText,BCC,IstHTML)" & _
        " VALUES (" & DatumUhrzeitSQL(Now) & ",'" & Environ("UserName") & "','" & Subject & "','zCreatePlainMail','" & SendToBCC & "'," & IstHTML & ")"
    
Ende:
    Set fields = Nothing
    Set message = Nothing
    Set config = Nothing
    Exit Function
Err:
    zCreatePlainMail = Err.Number & " " & Err.description
    Resume Ende
End Function


Function CreatePlainMail(IstHTML As Variant, Bodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False, Optional Voting As String = "", Optional sendAs As String = "", Optional bReadReceipt As Boolean = False, Optional strHeaderbild As String)

'  Call CreatePlainMail(IstHTML, Bodytext, Betreff, SendTo, _
'      iImportance, SendToCC, SendToBCC, myattach, IsSend, Voting, sendAs, bReadReceipt, strHeaderbild)
''  Ab 2. Reihe optional


' Parameter myattach
'-------------------
' Ein Array mit Dateinamen incl. Pfad
' Beispiel für 2 Attachs:
' Dim myattach
' myattach = Array("D:\GEZSpruch.jpg", "D:\Kulturverlust.pdf")

' Parameter IsSend
'-----------------
' IsSend = True  -- eMail wird direkt gesendet
' IsSend = False  -- eMail wird angezeigt, um sie vor dem Senden noch editieren zu können

' Parameter IstHTML
'-----------------
'IstHTML = -1 - BodyText ist im HTML Format                 |   .Bodyformat = 2  und   .HTMLBody = Bodytext
'IstHTML =  0 - BodyText ist im Plain Text / ASCII Format   |   .Bodyformat = 1  und   .Body = Bodytext

' SendTo, CC, BCC - eine Mailadresse oder mehrere duch Semikolon getrennt

'myItem.Importance 2 = High
'myItem.Importance 1 = Normal
'myItem.Importance 0 = Low

    Dim olApp As Object
    Dim objMail As Object
    Dim myAttachments As Object
    
    Dim strhtml As String
    Dim i As Long
    
    Const olByValue = 1
    
'' Early Binding mit Verweis
'    Dim olApp As Outlook.Application
'    Dim objMail As Outlook.MailItem
'    Dim myAttachments As Outlook.Attachments
    
'    Set olApp = Outlook.Application
'' Create e-mail item
'    Set objMail = olApp.CreateItem(olMailItem)
'' Set body format to HTML
'    .BodyFormat = olFormatHTML
    
' Late Binding ohne Verweis ...
    Set olApp = CreateObject("Outlook.Application")
' Create e-mail item
    Set objMail = olApp.CreateItem(0)

    With objMail
    
        If IstHTML = -1 Then
            .Bodyformat = 2
            .HTMLBody = Bodytext
        Else
            .Bodyformat = 1
            .Body = Bodytext
        End If
               
''  ------------------------------------------------------------------------------------------------
'''Startbild als unsichtbares Attach an email anhängen und dann per <img src=> als Bild anzeigen
''        'we attached an invisible the embedded image
'''        TempFilePath = Environ$("temp") & "\"
''       ' Der Param 0 nach olByValue bedeutet: Bei dem Wert 0 wird der Anhang ausgeblendet
'''        .Attachments.Add TempFilePath & "DashboardFile.jpg", olByValue, 0
''
''        'Then we add an html <img src=''> link to this image
''        'Note than you can customize width and height - not mandatory

        If IstHTML = -1 And Len(Trim(Nz(strHeaderbild))) > 0 Then
            If File_exist(strHeaderbild) Then
                .Attachments.Add strHeaderbild, olByValue, 0
                .HTMLBody = "<img src='cid:" & Dir(strHeaderbild) & "'" & "width='850' height='198'><br>" & .HTMLBody
            End If
        End If

''  ------------------------------------------------------------------------------------------------

        .TO = SendTo
        
        If Len(Trim(Nz(SendToCC))) > 0 Then
           .CC = SendToCC
        End If
        
        If Len(Trim(Nz(SendToBCC))) > 0 Then
           .BCC = SendToBCC
        End If
        
        If Len(Trim(Nz(sendAs))) > 0 Then
           .SentOnBehalfOfName = sendAs
        End If
        
        If Len(Trim(Nz(Voting))) > 0 Then
           .VotingOptions = Voting
        End If
        
 '     Lesebestätigung anfordern
        .ReadReceiptRequested = bReadReceipt

       .Subject = Betreff
       
       .Importance = iImportance
                    
   'Normale Attaches dranhängen
        If Not IsMissing(myattach) Then
            If Not IsNull(myattach) Then
                If Not IsEmpty(myattach) Then
                    If IsArray(myattach) Then
                
                        Set myAttachments = .Attachments
On Error Resume Next
                        For i = LBound(myattach) To UBound(myattach)
                            If File_exist(myattach(i)) Then
                                myAttachments.Add myattach(i)
                            End If
                        Next i
On Error GoTo 0
                    End If
                End If
            End If
        End If
        
        If IsSend = False Then
           '-- display the mail
            .Display
        Else
           '-- Send the mail
            .send
            MsgBox "E-Mails erfolgreich gesendet"
            DoCmd.Close acForm, "frm_MA_Serien_email_Auftrag"
            
            
        End If
        

    End With
    
End Function





Function CreateHTMLMail(HTMLBodytext As String, Betreff As String, SendTo As String, Optional iImportance = 1, Optional SendToCC As String = "", Optional SendToBCC As String = "", Optional myattach, Optional IsSend As Boolean = False)
'Creates a new e-mail item and modifies its properties

'myItem.Importance 2 = High
'myItem.Importance 1 = Normal
'myItem.Importance 0 = Low

'Function CreateHTMLMail()

    Dim olApp As Object
    Dim objMail As Object
    Dim myAttachments As Object
    
    Dim strhtml As String
    Dim i As Long
    
'' Early Binding mit Verweis
'    Dim olApp As Outlook.Application
'    Dim objMail As Outlook.MailItem
'    Dim myAttachments As Outlook.Attachments
    
'    Set olApp = Outlook.Application
'' Create e-mail item
'    Set objMail = olApp.CreateItem(olMailItem)
'' Set body format to HTML
'    .BodyFormat = olFormatHTML
    
' Late Binding ohne Verweis ...
    Set olApp = CreateObject("Outlook.Application")
' Create e-mail item
    Set objMail = olApp.CreateItem(0)

    strhtml = HTMLBodytext
    
    With objMail
    
    
       ''set body to olFormatPlain
       '  .BodyFormat = olFormatPlain
       '  .BodyFormat = 1
       '  .Body = "Plain Standardtext bla fasel"
       
       ''Set body format to HTML
'       .BodyFormat = olFormatHTML
       .Bodyformat = 2
'       .HTMLBody = "<HTML><H2>The body of this message will appear in HTML.</H2><BODY>Please enter the <B> message </B> text here. </BODY></HTML>"
       .HTMLBody = strhtml

       .TO = SendTo
        If Len(Trim(Nz(SendToCC))) > 0 Then
           .CC = SendToCC
        End If
        If Len(Trim(Nz(SendToBCC))) > 0 Then
           .BCC = SendToBCC
        End If

       .Subject = Betreff
       
       .Importance = iImportance

'       .SentOnBehalfOfName = "Absender@Absender.de"

        If Not IsMissing(myattach) Then
            If IsArray(myattach) Then
        
                Set myAttachments = .Attachments
                
                For i = LBound(myattach) To UBound(myattach)
                    If File_exist(myattach(i)) Then
                        myAttachments.Add myattach(i)
                    End If
                Next i
            End If
        End If
        
        If IsSend = False Then
           '-- display the mail
            .Display
        Else

           '-- Send the mail
            .send
        End If
        
    End With
    
End Function


Sub xSendMessage(ByRef theSubject, theRecipient, ByVal html As String, _
Optional ByVal theCCRecepients As String, Optional ByVal theBCCRecepients As String, _
Optional theVoting As String = "Opt-in all;Opt-out all;Some (please specify)", _
Optional iImportance As Long = 1, Optional myattach, Optional IsSend As Boolean = False)
   
' .Importance 2 = olImportanceHigh        .Importance 1 = olImportanceNormal        .Importance 0 = olImportanceLow
' if you hand over attachments, it must be a one dimensional Array containing one Pathname per field.
' if theVoting = "" - not Voting buttons, Votings separated by colon.
' theCCRecepients and theBCCRecepients only one String, spearated recepients with colon

''' #########################
''' Late Binding
'   Dim objOutlook As Outlook.Application
'   Dim objMail As Outlook.MailItem
'   Dim objOutlookRecip As Outlook.Recipient
'   Dim objOutlookAttach As Outlook.Attachments
   
''' #########################
''' Early Binding
   Dim objOutlook As Object
   Dim objMail As Object
   Dim objOutlookRecip As Object
   Dim objOutlookAttach As Object

   Const olFormatHTML As Long = 2
   Const olMailItem As Long = 0
   Const olTo As Long = 1
   Const olCC As Long = 2
   Const olBCC As Long = 3
''' ##########################
   
  
  
  
   Dim myHTML As String
   Dim i As Long
   
   'Dim theCCRecepients As String
         
   ' encapsulate html code in standard stuff
   myHTML = "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN""> "
   myHTML = myHTML & "<html><head><style>"
   myHTML = myHTML & "p { FONT-SIZE: 11pt; MARGIN: 3pt 0cm; FONT-FAMILY: Arial } "
   myHTML = myHTML & "th { FONT-SIZE: 10pt; MARGIN: 3pt 0cm; FONT-FAMILY: Arial; background-color: #d8c8e8 } "
   myHTML = myHTML & "td { FONT-SIZE: 10pt; MARGIN: 3pt 0cm; FONT-FAMILY: Arial; background-color: #e8dcf4 } "
   myHTML = myHTML & "</style></head><body>"
   myHTML = myHTML & html & "</body></html>"
   
   ' Create the Outlook session.
   Set objOutlook = CreateObject("Outlook.Application")
   
   Set objMail = objOutlook.CreateItem(olMailItem)
   
   With objMail
       'Set body format to HTML
       .Bodyformat = olFormatHTML
       .HTMLBody = myHTML
 '      .SentOnBehalfOfName = "sales@domain.com"
'       .Display
       .TO = theRecipient
       .CC = Nz(theCCRecepients)
       .BCC = Nz(theBCCRecepients)

'If Using Outlook Objects, you can insert more than one Recepient per Object
'.To
'.CC
'.BB
'allows only ONE string
       
       
       If Len(Trim(Nz(theVoting))) > 0 Then
           .VotingOptions = theVoting
       End If
                
''       'Bug: CCRecepients only work, if set in sort order 3 - 2 - 1 (BCC, CC, To)
''       ' When set different, all Recepients are sent to the TO
''       ' Set (B)CCRecipients - The (B)CCRecepients must already contain ALL Recepients, separated with a colon
''
''        If Len(Trim(Nz(theBCCRecepients))) > 0 Then
''            Set objOutlookRecip = .Recipients.Add(theBCCRecepients)
''            objOutlookRecip.Type = olBCC
''        End If
''
''        If Len(Trim(Nz(theCCRecepients))) > 0 Then
''            Set objOutlookRecip = .Recipients.Add(theCCRecepients)
''            objOutlookRecip.Type = olCC
''        End If
''
''        Set objOutlookRecip = .Recipients.Add(theRecipient)
''        objOutlookRecip.Type = olTo
       
       .Subject = theSubject
   
'      .Importance 2 = olImportanceHigh        .Importance 1 = olImportanceNormal        .Importance 0 = olImportanceLow
       .Importance = iImportance

'       .SentOnBehalfOfName = "Absender@Absender.de"

        If Not IsMissing(myattach) Then
            If IsArray(myattach) Then
        
                Set objOutlookAttach = .Attachments
                
                For i = LBound(myattach) To UBound(myattach)
                    If File_exist(myattach(i)) Then
                        objOutlookAttach.Add myattach(i)
                    End If
                Next i
            End If
        End If
        
        If IsSend = False Then
           '-- display the mail
            .Display
        Else
           '-- Send the mail
            .send
        End If

   End With
   Set objOutlook = Nothing
End Sub


Function xTestsend()
Dim strhtml As String

strhtml = "<p>Dear Anne-Lise,</p><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"
Call xSendMessage("Testbetreffffffffff", "", strhtml, "; ", "")
End Function

Function xTestsend1()
Dim strhtml As String
Dim att

att = Array("D:\GEZSpruch.jpg", "D:\Kulturverlust.pdf")
strhtml = "<p>Dear Anne-Lise,</p><br><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"
Call xSendMessage("Testbetreffffffffff", "", strhtml, , , , 2, att, True)
End Function


Function xTestsend1a()
Dim strhtml As String
Dim att

att = Array("D:\GEZSpruch.jpg", "D:\Kulturverlust.pdf")
strhtml = "<p>Dear Anne-Lise,</p><br><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"
Call xSendMessage("Testbetreffffffffff", "", strhtml, "; ", "siegert@consec-nuernberg.de", , 2, att)
End Function

Function xTestsend2()
Dim strhtml As String

strhtml = "<p>Dear Anne-Lise,</p><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"

Call xSendMessage("Testbetreffffffffff", "siegert@consec-nuernberg.de", strhtml, , , "", , , True)
End Function


Function Appointment()

'Dim olc As Outlook.AppointmentItem
Dim olc As Object
Dim objOutlook
 Set objOutlook = CreateObject("Outlook.Application")
' Set olc = objOutlook.CreateItem(olAppointmentItem)
 Set olc = objOutlook.CreateItem(1)
 
With olc
 .Subject = "Testtermin" 'hier will ich kein fixen text schreiben aber variabel aus dem kombifeld
 .ReminderMinutesBeforeStart = 30
 .Start = "24.03.2004 12:00" ' hier will ich anstatt datum mein kombi.feld datum
 .duration = 60 ' das ist ok
 .Location = "Büro" 'brauche keine Location
 .RequiredAttendees = "Name" 'hier das selbe, habe ein kombifeld mit dropdown und je nach auswahl soll es übernommen werden
.ResponseRequested = True
' .MeetingStatus = olMeeting
 .MeetingStatus = 1
 .Show
 End With
 End Function
 