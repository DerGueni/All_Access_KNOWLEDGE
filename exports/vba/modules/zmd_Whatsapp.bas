Attribute VB_Name = "zmd_Whatsapp"
Option Compare Database
Option Explicit


'Function WhatsAppAnfragen()
'
''MA_ID
''MA_Name
''Telefonnummer
''Nachricht
''Anhang
''Status
'
'Dim rs      As Recordset
'Dim sql     As String
'
'
'    sql = "SELECT * FROM [ztbl_WhatsApp]" ' WHERE [Status] <> 'gesendet'"
'    Set rs = CurrentDb.OpenRecordset(sql)
'    rs.MoveLast
'    rs.MoveFirst
'
'    'Fire
'    If Not rs.EOF Then Call WhatsAppVerschicken(rs)
'
'
'End Function


'
''Verweis auf Selenium Type Library !
'Function WhatsAppVerschicken(rs As Recordset) 'As String()
'
'
'Dim bot As New WebDriver
''Dim Bot As Object
'Dim ks As New Keys
'
'
'    'Benutzerprofil laden: Hier eigenes Benutzerprofil angeben
'    Select Case Environ("UserName")
'        Case "kypi"
'            bot.SetProfile "C:\Users\kypi\AppData\Local\Temp\Selenium\scoped_dir12440_675518715\Default\Default"
'        Case "güni"
'            bot.SetProfile "C:\Users\Güni\AppData\Local\Temp\283\Selenium\scoped_dir13024_1597492609\Default"
'    End Select
'
'    'Chrome starten und die WhatsApp-Seite öffnen
'    bot.Start "Chrome", "https://web.whatsapp.com"
'    bot.Wait (7000)
'    bot.Get "/"
'
'    'Messagebox anzeigen
'    MsgBox "Bitte bei Whatsapp im Browser anmelden anschließend 'OK' klicken."
'
'
'
'    'Schleife über alle Einträge
'    Do While Not rs.EOF
'        'Telefonnummer/Name ins Suchfeld einfügen
'        bot.FindElementByXPath("//*[@id='side']/div[1]/div/div/div[2]/div/div[2]").SendKeys (rs.Fields("Telefonnummer").Value)
'        bot.Wait (1000)
'
'        'Suche bestätigen
'        bot.SendKeys (ks.Enter)
'        bot.Wait (1000)
'
'        'Nachricht einfügen
'        If rs.Fields("Nachricht") <> "" Then
'            bot.SendKeys (rs.Fields("Nachricht").Value)
'            bot.Wait (1000)
'            'Nachricht absenden
'            bot.SendKeys (ks.Enter)
'            bot.Wait (1000)
'        End If
'
'        'Anhang
'        If rs.Fields("Anhang") <> "" Then
'            bot.FindElementByXPath("//*[@id='main']/footer/div[1]/div/span[2]/div/div[1]/div[2]/div/div/span").Click
'            bot.Wait (1000)
'            'Dokument auswählen
'            bot.FindElementByXPath("//*[@id='main']/footer/div[1]/div/span[2]/div/div[1]/div[2]/div/span/div/div/ul/li[4]/button/input").SendKeys (rs.Fields("Anhang").Value)
'            bot.Wait (1500)
'            'Nachricht absenden
'            bot.SendKeys (ks.Enter)
'            bot.Wait (1000)
'        End If
'
'        rs.Edit
'        rs.Fields("Status") = "gesendet"
'        rs.update
'        rs.MoveNext
'    Loop
'
'End Function
