Attribute VB_Name = "mdlOutlookHTMLSendMitBild"
Option Compare Database
Option Explicit


Function sendMail_Mit_Bild_obd()
    Dim TempFilePath As String
    
    Dim PicHeader As String
    Dim att1 As String
    Dim appOutlook
    Dim message
    Const olMailItem As Long = 0
    Const olByValue As Long = 1
    Dim s As String, t As String, U As String
    
    s = Path_erzeugen(DBPfad() & "Attach\", False)
    s = DBPfad() & "Attach\"
    Call BinexStd(s & "DummyTest.txt", 9)
    Call BinexStd(s & "siemens_Mail_Header_Std.jpg", 10)
    
    PicHeader = s & "siemens_Mail_Header_std.jpg"
    att1 = s & "DummyTest.txt"
    
    'Create a new Microsoft Outlook session
    Set appOutlook = CreateObject("outlook.application")
    'create a new message
    Set message = appOutlook.CreateItem(olMailItem)
      
    
    With message
        .Subject = "My mail auto Object"

        .HTMLBody = "<span LANG=EN>"
       ' Der Param 0 nach olByValue bedeutet: Bei dem Wert 0 wird der Anhang ausgeblendet
        .Attachments.Add PicHeader, olByValue, 0
         .Attachments.Add att1, olByValue, 1
        
'          .HTMLBody = .HTMLBody & "<p class=style2><span LANG=EN><font FACE=Calibri SIZE=3>" _
'            & "<img src='cid:siemens_Mail_Header.jpg'" & "width='850' height='198'><br>" _
'            & "Hello,<br ><br >"
            
            
s = ""
s = s & "<span LANG=EN><img src='cid:siemens_Mail_Header_std.jpg'" & "width='850' height='198'><br>"
s = s & "<p class=style2><span LANG=EN><font FACE=Calibri SIZE=3>"
s = s & "Hello,<br ><br >"
s = s & "<div><font face=Arial size=2 color=black>Thank you very much for your"
s = s & " participation at the Firex 2014 exhibition.</font></div><div>&nbsp;</div>"
s = s & "<div><font face=Arial size=2 color=black>It was our pleasure to welcome you on our booth and we hope that you were able"
s = s & " to gain new ideas, support </font></div>"
s = s & "<div><font face=Arial size=2 color=black>and beneficial information for your business needs. </font></div>"
s = s & "<div>&nbsp;</div>"
s = s & "<div><font face=Arial size=2 color=black>Please have a look at the following links to find more information about "
s = s & "the products you were interested in: </font></div>"
s = s & "<ul><ul>"
s = s & "<li><font face=Arial size=2 color=black>Siemens EX Solutions (see attached)</font></li>"
s = s & "</ul></ul>"
s = s & "<div><font face=Arial size=2 color=black>Should you have any questions or require further assistance, we would be pleased to help you.</font></div>"
s = s & "<div><font face=Arial size=2 color=black>Please do not hesitate to contact your local Siemens contact at </font><font"
s = s & "face=Arial size=2 color=blue><u>derrick.hall@siemens.com</u></font></div>"
s = s & "<div>&nbsp;</div>"
s = s & "<div><font face=Arial size=2 color=black>We look forward to a <strong>successful working relationship</strong> with you in the future.</font></div>"
s = s & "<div>&nbsp;</div>"
s = s & "<div><font face=Arial size=2 color=black>Best regards, </font></div>"
s = s & "<div><font face=Arial size=2 color=black>&nbsp;&nbsp;</font></div>"
s = s & "<div><font face=Arial size=2 color=black>Your Siemens Fire Safety Team</font></div>"
s = s & "<div>&nbsp;</div></span>"

.HTMLBody = s
            
'            The weekly dashboard is available " _
'            & "<br>Find below an overview :<BR>"
            
           
        'we attached an invisible the embedded image
'        TempFilePath = Environ$("temp") & "\"
       ' Der Param 0 nach olByValue bedeutet: Bei dem Wert 0 wird der Anhang ausgeblendet
'        .Attachments.Add TempFilePath & "DashboardFile.jpg", olByValue, 0
           
        'Then we add an html <img src=''> link to this image
        'Note than you can customize width and height - not mandatory
           
'        .HTMLBody = .HTMLBody & "<br><B>WEEKLY REPPORT:</B><br>" _
'            & "<br>Best Regards,<br>Ed</font></span>"
            
        .TO = "contact1@email.com; contact2@email.com"
        .CC = "contact3@email.com"
            
        .Display
        '.Send
    End With

End Function

Private Function BinexStd(s As String, ID As Long)
BinExport "___Vorlagen_einlesen", s, "Picture", ID
End Function


Function TestmailBild()


'Dim arr
'arr = Array("D:\GEZSpruch.jpg")
'Call sendOLEmbeddedHTMLGraphic("bobd@gmx.de", , , "TesteMail Bild", "Test", arr)

End Function

