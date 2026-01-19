Attribute VB_Name = "mdlOutlook_HTML_Serienemail_SAP"
Option Compare Database
Option Explicit

' This function sends an HTML-type email via Outlook
Sub xSendMessage(ByRef theSubject, theRecipient, ByVal html As String, _
Optional ByVal theCCRecepients As String = "", Optional ByVal theBCCRecepients As String = "", _
Optional iImportance As Long = 1, Optional myattach, _
Optional theVoting As String = "")
'Optional theVoting As String = "Opt-in all;Opt-out all;Some (please specify)")
   
' theCCRecepients and theBCCRecepients only one String, spearated recepients with colon
' if you hand over attachments, it must be a two dimensional - 0 based Array containing one Pathname per field.
' if theVoting = "" - not Voting buttons, Votings separated by colon.
' .Importance 2 = olImportanceHigh        .Importance 1 = olImportanceNormal        .Importance 0 = olImportanceLow
' if you hand over attachments, it must be a one dimensional - 0 based Array containing one Pathname per field.

''' #########################
''' Late Binding
'
'   Dim objOutlook As Outlook.Application
'   Dim objMail As Outlook.MailItem
'   Dim objOutlookRecip As Outlook.Recipient
'   Dim objOutlookAttach As Outlook.Attachments
'
''' #########################
''' Early Binding
'
   Dim objOutlook As Object
   Dim objMail As Object
   Dim objOutlookRecip As Object
   Dim objOutlookAttach As Object

   Const olFormatHTML As Long = 2
   Const olMailItem As Long = 0
   Const olTo As Long = 1
   Const olCC As Long = 2
   Const olBCC As Long = 3
'
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
       .Display
'       .To = theRecipient
       .CC = Nz(theCCRecepients)
       .BCC = Nz(theBCCRecepients)

'       .SentOnBehalfOfName = "Absender@Absender.de"

'If Using Outlook Objects, you can insert more than one Recepient per Object
'.To  .CC   .BB    allows only ONE string
       
       If Len(Trim(Nz(theVoting))) > 0 Then
           .VotingOptions = theVoting
       End If
                

'########### Recepients ################

'olBCC          3   The recipient is specified in the BCC property of the Item.
'olCC           2   The recipient is specified in the CC property of the Item.
'olOriginator   0   Originator (sender) of the Item.
'olTo           1   The recipient is specified in the To property of the Item.

'       'Bug: CCRecepients only work, if set in sort order 3 - 2 - 1 (BCC, CC, To)
'       ' When set different, all Recepients are sent to the TO field
'       ' Set (B)CCRecipients - The (B)CCRecepients must already contain ALL Recepients, separated with a colon
'
'        If Len(Trim(Nz(theBCCRecepients))) > 0 Then
'            Set objOutlookRecip = .Recipients.Add(theBCCRecepients)
'            objOutlookRecip.Type = olBCC
'        End If
'
'        If Len(Trim(Nz(theCCRecepients))) > 0 Then
'            Set objOutlookRecip = .Recipients.Add(theCCRecepients)
'            objOutlookRecip.Type = olCC
'        End If
'
        Set objOutlookRecip = .Recipients.Add(theRecipient)
        objOutlookRecip.Type = olTo
'#########################################
       
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
        
        'Hier wird die Mail "angezeigt"
        'aber gleich versendet,... OHNE Sicherheitsabfrage!
        .Display
        SendKeys "%s", True

   End With
   Set objOutlook = Nothing
   Set objMail = Nothing
   Set objOutlookRecip = Nothing
   Set objOutlookAttach = Nothing
   
   Sleep 5000
   DoEvents

End Sub

Function xTestsend1()
Dim strhtml As String
Dim att

Dim SSuch(9) As String
Dim SErse(9) As String

Dim i As Long

'att = Array("\\Majestix\d\GEZSpruch.jpg", "\\Majestix\d\Kulturverlust.pdf")
'strhtml = "<p>Dear Anne-Lise Lindop,</p><br><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"
strhtml = Get_Priv_Property("prp_HTML_Mandatory")

SSuch(0) = "*$*LocalReviewer*$*"
SSuch(1) = "*$*Handover_Date*$*"
SSuch(2) = "*$*3_business_days_prior_to_Handover_Date*$*"
SSuch(3) = "*$*AssetName*$*"
SSuch(4) = "*$*AssetUse*$*"
SSuch(5) = "*$*LaunchDate*$*"
SSuch(6) = "*$*TargetAudience*$*"
SSuch(7) = "*$*CallToAction*$*"
SSuch(8) = "*$*UseOnTheWeb*$*"
SSuch(9) = "*$*OverallImportanceMandatory*$*"

SErse(0) = "'Klaus Oberdalhoff' (C5149570)"
SErse(1) = "4/13/2011"
SErse(2) = "4/10/2011"
SErse(3) = "Business One Overview Video: Software Designed With Small Businesses in Mind"
SErse(4) = fCnvQM(Get_Priv_Property("prp_Erse_AssetUse"))
SErse(5) = "English version Sept 20th and localized versions are planned to be launched end of Sept"
SErse(6) = "Owner/president, CIO, head of  IT or finance at SME's"
SErse(7) = "The Overview video is going to be one of the Three CTAs in the iTour campaign (other two are the ""Business One Solution Brief"" and the ""link to B1 page on sap.com/sme"")"
SErse(8) = "http://www.sap.com/sme/seeitinaction/OverviewVideos.epx?sol=SAP%20Business%20One"
SErse(9) = "This video is the ONLY high level product-specific video used to move prospects that are very early in the buying cycle in L1-L2 (discovery/motivation) to L3-L4 (evaluation/consideration)."

For i = 0 To 9
  strhtml = Replace(strhtml, SSuch(i), SErse(i))
Next i

Call xSendMessage("Testbetreffffffffff", "", strhtml, ";siegert@consec-nuernberg.de")
End Function

Function xTestsend2()
Dim strhtml As String
strhtml = "<p>Dear Anne-Lise Lindop,</p><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"
Call xSendMessage("Testbetreffffffffff", "siegert@consec-nuernberg.de", strhtml, "siegert@consec-nuernberg.de; siegert@consec-nuernberg.de", "siegert@consec-nuernberg.de")
End Function

Function xTestsend3()
Dim strhtml As String
strhtml = "<p>Dear Anne-Lise Lindop,</p><p>please notice that the following content will be ready for localization by 1/23/2011. You can preview the original version by clicking on the title.</p><br><table border><tr><th>Asset Type</th><th>Title</th><th>Solution</th><th>Abstract</th></tr> <tr><td>Brochure</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">Brooooooooooo1111111111</a></td><td>Business One</td><td>Brooooooooooo1111111111 Abstract</td></tr><tr><td>Video</td><td><a href=""\\Majestix\d\SAP_NEU\regression_test.xlsx"">TestVideo</a></td><td>Business One</td><td>TestVideo Abstract</td></tr></table><br><p>Please let us know if you opt in or out. If you opt-in (or out) for all assets, you just need to use the voting button.</p>"
Call xSendMessage("Testbetreffffffffff", "siegert@consec-nuernberg.de", strhtml)
End Function



''########################################################################################################################
'' based on KB article  Collaboration Data Objects (CDO) 1.2.1 is not supported with Outlook 2010
''it looks like Visual Basic for Excel code that used Outlook 2007 in Vista will no longer work with Outlook 2010 (esp 64bit versions)
''
''"...CDO 1.2.1 is a 32-bit client library and will not operate with 64-bit Outlook 2010. Given all these factors,
''CDO 1.2.1 is not supported for use with Outlook 2010, and we do not recommend its use with Outlook 2010. ...
''Programs that use CDO should be re-designed to use other Application Programming Interfaces (APIs) instead of CDO."
''
''########################################################################################################################
''
'''You should use CDO, this bypasses outlook and works a lot quicker. Used it with ACC2K and Acc2K10.
''
'' Function Send_eMail(strTo As String, strFrom As String, strSubject As String, strMsg As String, Optional strCC As String, Optional strBCC As String, Optional strAttachmentPath As String) As Boolean
'' Dim objCDOSysCon As Object
'' Dim objMessage As Object
''
'' On Error GoTo Send_eMail_Error
''
'' DoCmd.SetWarnings False
'' Send_eMail = False
''
'' Set objCDOSysCon = CreateObject("CDO.Configuration")
'' Set objMessage = CreateObject("CDO.Message")
''
'' 'Outgoing SMTP server
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/smtpserver ") = "10.0.0.17"
'' 'SMTP port
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/smtpserverport ") = 25
'' 'CDO Port
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/sendusing ") = 2
'' 'Timeout
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout ") = 60
'' 'Authenticatie
'' '2010-12-07 Changed cdoBasic to "cdoBasic" (so quoted..)
'' '2011-02-18 Changed to 1 after migration to office 2010
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/smtpauthenticate ") = 1
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/sendusername ") = strSMTPUser
'' objCDOSysCon.Fields(" http://schemas.microsoft.com/cdo/configuration/sendpassword ") = strSMTPPassword
''
'' objCDOSysCon.Fields.Update
''
'' 'Update the CDOSYS Configuration
'' Set objMessage.Configuration = objCDOSysCon
''
'' 'Create Message
'' objMessage.Subject = strSubject
'' objMessage.from = strFrom
'' objMessage.to = strTo
'' objMessage.CC = strCC
'' objMessage.bcc = strBCC '& ";" & strFrom
'' objMessage.TextBody = strMsg
'' If Len(Nz(strAttachmentPath, "")) > 0 Then
'' objMessage.addAttachment strAttachmentPath
'' End If
''
'' 'Send the message
'' objMessage.Send
''
'' 'Close the server mail object
'' Set objMessage = Nothing
'' Set objCDOSysCon = Nothing
''
''Exit_Send_eMail:
'' 'Report Succes
'' Send_eMail = True
'' On Error GoTo 0
'' Exit Function
''
''Send_eMail_Error:
'' MsgBox "Error " & err.Number & " (" & err.Description & ") in procedure Send_eMail of Module Mod_Exchange"
'' End Function
''

