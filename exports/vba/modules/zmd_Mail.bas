Attribute VB_Name = "zmd_Mail"
Option Compare Database
Option Explicit
    
    'F�r Mailversand
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


    Public MD5         As String
    Public subRC       As String
    Public VName       As String
    Public NName       As String
    Public Email       As String
    Public VA_Text     As String
    Public VA_Ort      As String
    Public VA_Objekt   As String
    Public VADatum     As String 'Besser w�re MVA_Datum, dieses wird gelesen!
    Public VA_Uhrzeit  As String 'Besser w�re MVA_Uhrzeit, diese wird gelesen!
    Public VA_Ende     As String
    Public DC          As String
    Public TP          As String
    Public TPZeit      As String
    Public Sender      As String
    
    
'Mitarbeiter f�r Veranstaltung anfragen
Function Anfragen(ByVal MA_ID As Integer, ByVal VA_ID As Long, _
    ByVal VADatum_ID As Long, ByVal VAStart_ID As Long) As String
    
Dim check           As String
Dim Status          As Integer
Dim Criteria        As String
Dim CRITERIAFORINFO As String
Dim sql             As String
    
'    'Texte nachlesen
'    subRC = Texte_lesen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
    
    'Pr�fen, ob der Mitarbeiter eine Email-Adresse hat
    If IsNull(TLookup("Email", MASTAMM, "ID = " & MA_ID)) Then
        Anfragen = ">HAT KEINE EMAIL"
            
    Else
        'MD5 Hash erzeugen
        MD5 = FnsCalculateMD5(MA_ID & VA_ID & VADatum_ID & Email)
        
'        'Fehler beim Lesen der Texte - > Nicht mehr gebraucht
'        If subRC <> "" Then
'            Anfragen = "Fehler beim Lesen der Texte von MA_ID " & MA_ID & ": " & subRC
'            Exit Function
'        End If
        
        Criteria = "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & _
            " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID
            
        CRITERIAFORINFO = "VA_ID = " & VA_ID & _
            " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID & " AND MA_ID = 0 AND IstFraglich = False"
            
        ' NULL-safe: Wenn kein Planungs-Eintrag existiert, Status = 0
        Status = Nz(TLookup("Status_ID", PLANUNG, Criteria), 0)
        'Status 0 = Nicht geplant, 1=Geplant, 2=Benachrichtigt, 3=Zusage, 4=Absage
        'Zusage 3 wird gel�scht kommt zu Zugeordnet -> Pr�fung , ob MA bereits zugeordnet -> pr�fen, ob das vorher schon passiert, sonst einkommentieren + anpassen!
    '    If TLookup("ID", ZUORDNUNG, criteria) <> Null Then
    '        Status = 3
    '    endif.

        Select Case Status
            Case 0
                ' MA ist nicht in der Planung - muss erst geplant werden
                Anfragen = ">NICHT GEPLANT"

            Case 1
                'Mitarbeiter anfragen
                check = create_Mail(MA_ID, VA_ID, VADatum_ID, VAStart_ID, 1) & vbCrLf
            
                'Angefragt setzen, wenn Anfrage erfolgreich
                If InStr(check, "OK") <> 0 Then Anfragen = setze_Angefragt(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
                
                'Anfragezeitpunkt dokumentieren
                TUpdate "Anfragezeitpunkt = " & DatumUhrzeitSQL(Now()), PLANUNG, Criteria
'                SQL = "UPDATE " & PLANUNG & " SET Anfragezeitpunkt = " & DatumUhrzeitSQL(Now()) & " WHERE " & CRITERIA
'                CurrentDb.Execute SQL
                
                'Infohaken setzen
                setInfo (CRITERIAFORINFO)
                
            Case 2
                
                'Mitarbeiter anfragen
                check = create_Mail(MA_ID, VA_ID, VADatum_ID, VAStart_ID, 1) & vbCrLf
            
                'Angefragt setzen, wenn Anfrage erfolgreich
                If InStr(check, "OK") <> 0 Then Anfragen = setze_Angefragt(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
       
                Anfragen = Anfragen & ">ERNEUT ANGEFRAGT!"
                
                'Infohaken setzen -> Darf nicht, da bereits bei der ersten Anfrage ein "Dummyhaken" gesetzt wurde!
                'setInfo (CRITERIAFORINFO)
                
            Case 3
                Anfragen = ">BEREITS ZUGESAGT!"
                
            Case 4
                Anfragen = ">BEREITS ABGESAGT!"
                
            Case Else
                Anfragen = ">UNBEKANNTER FEHLER!"
            
        End Select
     
        'Datei f�r Autmatische Antwort erzeugen
        create_PHP MD5, Email, VADatum, VA_Uhrzeit, VA_Ende, VA_Text, VA_Ort, VA_Objekt, MA_ID

    End If
    
End Function


'IstFraglich setzen
Function setInfo(Criteria As String)

Dim rs As Recordset
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & ZUORDNUNG & " WHERE " & Criteria)
    
    If Not rs.EOF Then
        rs.Edit
        rs.fields("IstFraglich") = True
        rs.update
    End If
    rs.Close
    Set rs = Nothing

End Function


'Mitarbeiter als angefragt markieren Hier ANFRAGEZEITPUNKT SETZEN!
Function setze_Angefragt(MA_ID As Integer, VA_ID As Long, VADatum_ID As Long, VAStart_ID As Long) As String

Dim Criteria As String

    Criteria = "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID & _
        " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID

    'Status 1 bis 4:  1=Geplant, 2=Benachrichtigt, 3=Zusage, 4 =Absage
    '(Zusage 3 wird gel�scht kommt zu Zugeordnet)
    
    If TUpdate("Status_ID = 2", PLANUNG, Criteria) = "OK" Then
      setze_Angefragt = ">OK"
      
    Else
      setze_Angefragt = ">FEHLER!"
    
    End If
      
End Function
    
    
'Texte zu IDs aus Stammdaten lesen
Function Texte_lesen(ByVal MA_ID As String, ByVal VA_ID As String, ByVal VADatum_ID As String, ByVal VAStart_ID As String) As String
    
    Email = ""
    VName = ""
    NName = ""
    VA_Text = ""
    VA_Objekt = ""
    VA_Ort = ""
    VADatum = ""
    VA_Uhrzeit = ""
    VA_Ende = ""
    DC = ""
    TP = ""
    TPZeit = ""
    Sender = ""
    
On Error Resume Next

    Email = TLookup("Email", "tbl_Ma_Mitarbeiterstamm", "ID=" & MA_ID)
    
    'eM@il Adresse muss gepflegt sein, da mit Grundlage f�r md5hash
    If Err.Number <> 0 Then
        Texte_lesen = "Mitarbeiter " & MA_ID & ": Emailadresse fehlt!"
    End If
    
    'Rest ist rille f�r weitere Verarbeitung...
    VName = TLookup("Vorname", MASTAMM, "ID = " & MA_ID)
    NName = TLookup("Nachname", MASTAMM, "ID = " & MA_ID)
    VA_Text = TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & VA_ID)
    VA_Objekt = TLookup("Objekt", AUFTRAGSTAMM, "ID = " & VA_ID)
    VA_Ort = TLookup("Ort", AUFTRAGSTAMM, "ID = " & VA_ID)
    VADatum = TLookup("VADatum", PLANUNG, "VADatum_ID = " & VADatum_ID & _
        " AND MA_ID = " & MA_ID & " AND VAStart_ID = " & VAStart_ID)
    'FIX 27.01.2026: Datum formatieren (sonst wird ISO-Format angezeigt)
    If IsDate(VADatum) Then VADatum = Format(VADatum, "DD.MM.YYYY")
    VA_Uhrzeit = TLookup("MVA_Start", PLANUNG, "VADatum_ID = " & VADatum_ID & _
        " AND MA_ID = " & MA_ID & " AND VAStart_ID = " & VAStart_ID)
    DC = TLookup("Dienstkleidung", AUFTRAGSTAMM, "ID = " & VA_ID)
    VA_Ende = TLookup("MVA_Ende", PLANUNG, "VADatum_ID = " & VADatum_ID & _
        " AND MA_ID = " & MA_ID & " AND VAStart_ID = " & VAStart_ID)
    TP = TLookup("Treffpunkt", AUFTRAGSTAMM, "ID = " & VA_ID)
    TPZeit = TLookup("Treffp_Zeit", AUFTRAGSTAMM, "ID = " & VA_ID)
    Sender = detect_sender

    'Uhrzeit formatieren
    VA_Uhrzeit = Format(VA_Uhrzeit, "HH:MM")
    VA_Ende = Format(VA_Ende, "hh:nn:ss")
    TPZeit = Format(TPZeit, "hh:nn:ss")
    
    'Autoende herausnehmen (bei 4,5h keine Endzeit)
    If stunden(VA_Uhrzeit, VA_Ende) = "4,5" Then VA_Ende = ""
   
End Function


'URL ERZEUGEN
Function create_URL(MD5 As String, ByVal MA_ID As String, MAemail As String, ByVal VA_ID As String, _
    ByVal VADatum_ID As String, ByVal VAStart_ID As String) As String

    Dim url As String

On Error GoTo err_URL
    'Beispiel:
    'http://noreply.consec-security.selfhost.eu/mail/index.php?MA_ID=0815&VA_ID=999&ZUSAGE=1&VADatum_ID=123123123
    
    url = "http://noreply.consec-security.selfhost.eu/mail/index.php?"
    
    'URL erzeugen
    url = url & "md5hash=" & MD5 & "&MA_ID=" & MA_ID & "&VA_ID=" & VA_ID & _
        "&VADatum_ID=" & VADatum_ID & "&VAStart_ID=" & VAStart_ID & "&dress=" & DC
    
    'Leerzeichen ersetzen
    create_URL = Replace(url, " ", "_")


end_URL:
    Exit Function
err_URL:
    create_URL = Err.Number & Err.description
    Resume end_URL
End Function


'Mail direkt erzeugen
'Mailtype: 1=Anfrage, 2=Zusagebest�tigung, 3=Absagebest�tigung
Function create_Mail(ByVal MA_ID As Integer, ByVal VA_ID As Long, ByVal VADatum_ID As Long, ByVal VAStart_ID As Long, Mailtype As Integer, Optional ByVal Attachment As String) As String

    Dim config  'As CDO.Configuration
    Dim message 'As CDO.Message
    Dim fields  'As ADODB.Fields

    Dim url As String
    Dim urlja As String
    Dim urlnein As String
    Dim Subject As String
    Dim Body As String
    Dim txtFile As String
    Dim ZuAbsage As String
    Dim Zusatztext As String
    Dim Farbe As String
    
    'Texte nachlesen
    subRC = Texte_lesen(MA_ID, VA_ID, VADatum_ID, VAStart_ID)
    
    'URL erzeugen
    Select Case Mailtype
        Case 1 'Anfrage
            url = create_URL(MD5, MA_ID, Email, VA_ID, VADatum_ID, VAStart_ID)
        
        
            'Fehler beim Erzeugen der URL
            If IsNumeric(Left(url, 1)) Then
                create_Mail = "Fehler beim Erzeugen der URL: " & url
                Exit Function
            End If
        
            'URLs f�r Zusagen und Absage
            urlja = url & "&ZUSAGE=1"
            urlnein = url & "&ZUSAGE=0"
            
            'Betreffzeile aufbauen
            Subject = "CONSEC Anfrage zu " & VA_Text & ", " & VADatum & " in " & VA_Ort
        
        Case Else ' Best�tigung
            Subject = "Deine R�ckmeldung ist angekommen " & VA_Text & ", " & VADatum & " in " & VA_Ort 'HIER noch unterscheiden-->ABSAGE /ZUSAGE
        
    End Select
    
    
    Select Case Mailtype
        Case 1
            txtFile = TXTAnf
        Case 2
            txtFile = TXTConf
            ZuAbsage = "Zusage"
            Farbe = "green"
            Zusatztext = "Eine �bersicht �ber alle Deine zugesagten Auftr�ge findest Du als Dienstplan im Anhang." & vbCrLf & vbCrLf & "Viele Gr��e"
        Case 3
            txtFile = TXTConf
            ZuAbsage = "Absage"
            Farbe = "red"
            Zusatztext = "Eine �bersicht �ber alle Deine zugesagten Auftr�ge findest Du als Dienstplan im Anhang." & vbCrLf & vbCrLf & "Viele Gr��e"
    End Select
    
    'Mailtext aufbauen
    Body = create_HTML(txtFile)
    
    'Fehler beim Erzeugen des Bodys
    If IsNumeric(Left(Body, 1)) Then
        create_Mail = "Fehler beim Erzeugen des Bodys: " & Body
        Exit Function
    End If
    
    'Variablen ersetzen
    Body = Replace(Body, "[A_URL_JA]", urlja)
    Body = Replace(Body, "[A_URL_NEIN]", urlnein)
    Body = Replace(Body, "[A_Auftr_Datum]", VADatum)
    Body = Replace(Body, "[A_Auftrag]", VA_Text)
    Body = Replace(Body, "[A_Ort]", VA_Ort)
    Body = Replace(Body, "[A_Objekt]", VA_Objekt)
    Body = Replace(Body, "[A_Start_Zeit]", VA_Uhrzeit & " Uhr")
    If VA_Ende <> "" Then
        Body = Replace(Body, "[A_End_Zeit]", VA_Ende & " Uhr")
    Else
        Body = Replace(Body, "[A_End_Zeit]", VA_Ende)
    End If
    If TPZeit <> "" Then
        Body = Replace(Body, "[A_Treffp_Zeit]", TPZeit & " Uhr")
    Else
        Body = Replace(Body, "[A_Treffp_Zeit]", TPZeit)
    End If
    Body = Replace(Body, "[A_Treffpunkt]", TP)
    Body = Replace(Body, "[A_Dienstkleidung]", DC)
    Body = Replace(Body, "[A_Sender]", Sender)
    Body = Replace(Body, "[A_Wochentag]", Format(VADatum, "DDD"))

    
    'HIER noch unterscheiden
    Body = Replace(Body, "[A_Color]", Farbe)
    Body = Replace(Body, "[A_ZUAB]", ZuAbsage)
    Body = Replace(Body, "[A_Zusatztext]", Zusatztext)
    
    'Debug.Print Body

    Set message = CreateObject("CDO.Message") 'server.CreateObject("CDO.Message")
    Set config = CreateObject("CDO.Configuration") 'server.CreateObject("CDO.Configuration")
    Set fields = config.fields
    
    config.Load -1
    With fields
        .item(cdoSendUsingMethod) = cdoSendUsingPort
        .item(cdoSMTPUseSSL).Value = False
        .item(cdoSMTPServer).Value = "in-v3.mailjet.com"
        .item(cdoSMTPServerPort).Value = 25
        .item(cdoSMTPConnectionTimeout).Value = 10
        .item(cdoSMTPAuthenticate).Value = cdoBasic
        .item(cdoSendUserName).Value = SendUserName
        .item(cdoSendPassword).Value = SendPassword
        '.Item(cdoSendUserName).Value = "362b265d418678568c59d793a174852f"
        '.Item(cdoSendPassword).Value = "713a4cae1f305e8f10de74a11eb88f4e"
        .update
    End With
     
    With message
    Set .Configuration = config
        .TO = Email
        .FROM = """Consec Auftragsplanung"" <siegert@consec-nuernberg.de>"
        .Subject = Subject
        .HTMLBody = Body
        If Attachment <> "" Then .addAttachment Attachment
        .send
    End With
     
     
    'is gut
    create_Mail = VName & " " & NName & "  " & VA_Text & "  OK"
    'Log
    CurrentDb.Execute "INSERT INTO tbl_Log_eMail_Sent(SendDate,Absender,Betreff,MailText,BCC,VA_ID,IstHTML)" & _
        " VALUES (" & DatumUhrzeitSQL(Now) & ",'" & Environ("UserName") & " ','" & Subject & "','" & txtFile & "','" & Email & "'," & VA_ID & ",-1)"
    
Ende:
    Set fields = Nothing
    Set message = Nothing
    Set config = Nothing
    Exit Function
Err:
    create_Mail = Err.Number & " " & Err.description
    Resume Ende
End Function


'HTML-Body aus Textdokument einlesen
Function create_HTML(txtFile As String) As String

Dim Buffer As String

On Error GoTo Err_HTML

    Open txtFile For Input As #1
    Do
      Line Input #1, Buffer
      create_HTML = create_HTML & vbCrLf & Buffer
    Loop While Not EOF(1)
    
    Close #1    ' Datei schlie�en

    'Umlaute anpassen -> create_HTML
    create_HTML = Replace(create_HTML, "�", "&#220;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "�", "&#196;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "�", "&#214;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "�", "&#252;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "�", "&#228;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "�", "&#246;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "�", "&#223;", , , vbBinaryCompare)
    create_HTML = Replace(create_HTML, "Ü", "&#220;")  '�
    create_HTML = Replace(create_HTML, "Ä", "&#196;")  '�
    create_HTML = Replace(create_HTML, "Ö", "&#214;")  '�
    create_HTML = Replace(create_HTML, "ü", "&#252;")  '�
    create_HTML = Replace(create_HTML, "ä", "&#228;")  '�
    create_HTML = Replace(create_HTML, "ö", "&#246;")  '�
    create_HTML = Replace(create_HTML, "ß", "&#223;")  '�
    create_HTML = Replace(create_HTML, "Ü", "&#220;")  '�
    create_HTML = Replace(create_HTML, "Ä", "&#196;")  '�
    create_HTML = Replace(create_HTML, "�", "")         'Mist raus
    create_HTML = Replace(create_HTML, "�", "")         'Mist raus
    create_HTML = Replace(create_HTML, "�", "")         'Mist raus
    
End_HTML:
    Exit Function
Err_HTML:
    create_HTML = Err.Number & " " & Err.description
    Resume End_HTML
End Function


'Mail erzeugen und senden
Function send_Mail(Email As String, Subject As String, Body As String, Optional Attachment As String) As String

    Dim config  'As CDO.Configuration
    Dim message 'As CDO.Message
    Dim fields  'As ADODB.Fields

    Set message = CreateObject("CDO.Message") 'server.CreateObject("CDO.Message")
    Set config = CreateObject("CDO.Configuration") 'server.CreateObject("CDO.Configuration")
    Set fields = config.fields
   
On Error GoTo Err

    config.Load -1
    With fields
        .item(cdoSendUsingMethod) = cdoSendUsingPort
        .item(cdoSMTPUseSSL).Value = False
        .item(cdoSMTPServer).Value = SMTPServer
        .item(cdoSMTPServerPort).Value = 25
        .item(cdoSMTPConnectionTimeout).Value = 10
        .item(cdoSMTPAuthenticate).Value = cdoBasic
        .item(cdoSendUserName).Value = SendUserName
        .item(cdoSendPassword).Value = SendPassword
        .update
    End With
     
    With message
    Set .Configuration = config
        .TO = Email
        .FROM = """Consec Auftragsplanung"" <siegert@consec-nuernberg.de>"
        .Subject = Subject
        .HTMLBody = Body
        If Attachment <> "" Then .addAttachment Attachment
        .send
    End With
     
     
    'is gut
    send_Mail = "Email wurde versendet"
    
    'Log
    CurrentDb.Execute "INSERT INTO tbl_Log_eMail_Sent(SendDate,Absender,Betreff,MailText,BCC,IstHTML)" & _
        " VALUES (" & DatumUhrzeitSQL(Now) & ",'" & Environ("UserName") & " ','" & Subject & "','send_Mail','" & Email & "',-1)"
    
    
Ende:
    Set fields = Nothing
    Set message = Nothing
    Set config = Nothing
    Exit Function
Err:
    send_Mail = Err.Number & " " & Err.description
    Resume Ende
End Function


'Dienstplan senden
Function Dienstplan_senden(MA_ID As Integer, von As Date, bis As Date) As String

Dim Subject     As String
Dim Body        As String
Dim Attachment  As String
Dim Report      As String
Dim Sender      As String
Dim Vorname     As String
Dim Email       As String

On Error GoTo Err
    
    'Email (bei Subs Telefonnummer, bei MA Email)
    'If TLookup("IstSubunternehmer", MASTAMM, "ID=" & MA_ID) = False Then
        Email = TLookup("Email", MASTAMM, "ID=" & MA_ID)
    'Else
        'Email = TLookup("Tel_Mobil", MASTAMM, "ID=" & MA_ID)
        'Email = TLookup("Tel_Festnetz", MASTAMM, "ID=" & MA_ID)
    'End If
    
    'Vorname
    Vorname = TLookup("Vorname", MASTAMM, "ID= " & MA_ID)
    
    'Bericht
    Report = "rpt_MA_Dienstplan"

    'Anhang
    Attachment = PfadTemp & "Dienstplan_" & von & "-" & bis & ".pdf"

    'Pr�fen, ob Bericht ge�ffnet
    If fctIsReportOpen(Report) Then
        MsgBox "Bitte zuerst den Bericht schlie�en!"
        Exit Function
    End If

    'Betreff
    Subject = "Dienstplan ab " & von

    'Mailtext
    Body = create_HTML(TXTDienstPl)
    Body = Replace(Body, "[A_Vorname]", Vorname)
    Body = Replace(Body, "[A_DatumAb]", von)

    Sender = detect_sender

    Body = Replace(Body, "[A_Sender]", Sender)

    'Alte Datei l�schen falls noch vorhanden
    If FileExists(Attachment) Then Kill Attachment

    'Bericht im Temp-Verzeichnis als PDF sichern
    DoCmd.OutputTo acOutputReport, Report, "PDF", Attachment

    'Datum vermerken
    TUpdate "Datum_DP = " & datumSQL(Now), MASTAMM, "ID = " & MA_ID
        
    'Fire, Captain!
    Dienstplan_senden = send_Mail(Email, Subject, Body, Attachment)
        


Ende:
    'Datei l�schen
    If FileExists(Attachment) Then Kill Attachment
    Exit Function
Err:
    Dienstplan_senden = Err.Number & " " & Err.description
    Resume Ende
End Function



'Lohnabrechnung_ermitteln
Function Lohnabrechnung_ermitteln(ByVal LexID As Long, Optional Jahr As Integer, Optional Monat As Integer) As String

Dim PfadAbrech  As String
Dim such        As String
Dim MonatStr    As String
Dim Datei       As String

    If Jahr = 0 Then Jahr = Year(Now)
    If Monat = 0 Then Monat = Month(Now) - 1
    MonatStr = Monat_lang(Monat)

    PfadAbrech = PfadPlanungAktuell & "A  - Lexware Datentr�ger\2 - Abr Lohn\CONSEC_Security_Veranstaltungsservice_&_" & Jahr & "_" & MonatStr & "\"
    such = Jahr & "_" & MonatStr & "_" & LexID & "_"
    Datei = Dir(PfadAbrech & "*" & such & "*.pdf")
    
    If Datei <> "" Then Lohnabrechnung_ermitteln = PfadAbrech & Datei
    
End Function


'Lohnabrechnung senden
Function Lohnabrechnung_senden(LexID As Long, Monat As String, Jahr As String, Datei As String) As String


Dim Subject     As String
Dim Body        As String
Dim Attachment  As String
Dim Sender      As String
Dim Vorname     As String
Dim Email       As String

    
    If Datei = "" Then
        Lohnabrechnung_senden = "Keine Datei �bergeben"
        Exit Function
    End If
    
   'Email
    Email = TLookup("Email", MASTAMM, "LEXWare_ID=" & LexID)
    
    'Vorname
    Vorname = TLookup("Vorname", MASTAMM, "LEXWare_ID= " & LexID & " AND IstAktiv = TRUE")

    'Anhang
    Attachment = Datei

    'Betreff
    Subject = "Consec Lohnabrechnung " & Monat

    'Mailtext
    Body = create_HTML(TXTAbrechnung)
    Body = Replace(Body, "[A_Vorname]", Vorname)
    Body = Replace(Body, "[A_Monat]", Monat)
    Body = Replace(Body, "[A_Jahr]", Jahr)
    
    'Absender
    Sender = detect_sender
    
    'Mailtext
    Body = Replace(Body, "[A_Sender]", Sender)

        
    'Fire, Captain!
    Lohnabrechnung_senden = send_Mail(Email, Subject, Body, Attachment)
        
Ende:
    Exit Function
Err:
    Lohnabrechnung_senden = Err.Number & " " & Err.description
    Resume Ende
End Function


'PDF Einsatzliste Subunternehmer
Function pdf_erstellen_einsatzliste_sub(VA_ID As Long, MA_ID As Long) As String

Dim PDF_Datei  As String

    
    PDF_Datei = Server & "Consys\Dokumente\Auftrag\Allgemein\" & Nz(TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & VA_ID), "") & " " & _
        Nz(TLookup("Objekt", AUFTRAGSTAMM, "ID = " & VA_ID), "") & " am " & TLookup("VADatum", anzTage, "VA_ID = " & VA_ID) & " " & _
        Nz(TLookup("Nachname", MASTAMM, "ID = " & MA_ID), "") & " " & Nz(TLookup("Vorname", MASTAMM, "ID = " & MA_ID), "") & ".pdf"
        
    'Properties Query Bericht
    Call Set_Priv_Property("prp_Report1_MA_ID", MA_ID)
    Call Set_Priv_Property("prp_Report1_Auftrag_IstTage", 3)
    Call Set_Priv_Property("prp_Report1_Auftrag_ID", VA_ID)
    Call Set_Priv_Property("prp_Report1_Auftrag_VADatum_ID", TLookup("ID", anzTage, "VA_ID = " & VA_ID))
    
    DoCmd.OutputTo acOutputReport, "rpt_Auftrag_Zusage", acFormatPDF, PDF_Datei

    pdf_erstellen_einsatzliste_sub = PDF_Datei
    
End Function
