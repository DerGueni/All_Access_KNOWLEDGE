'    Option Explicit
'
'On the next line edit the path to the Access database you want to import to
'Const ACCESS_FILE_PATH = "C:\Kunden\CONSEC (Siegert)\PGM\eMail_Import.accdb"
'Const ACCESS_FILE_PATH = "\\Consecpc5\e\CONSYS_Backend\eMail_Import.accdb"
'
'  In Outlook eine Regel erzeugen, die die Betreffzeile, die den Voting-Text enthält, bedient:
'    Als Regel muss sie folgende Bedingung beinhalten:
'
'    '  In Outlook eine Regel erzeugen, die die Betreffzeile, die den Voting-Text enthält, bedient:
'    '    Als Regel muss sie folgende Bedingung beinhalten:
'    '
'    '    Nach Erhalt einer Nachricht
'    '    die an consec-auftragsplanung@gmx.de gesendet wurde
'    '    Projekt1.ImportToAccess ausführen
'    '      und keine weiteren Regeln anwenden
'    '
'    '    ----------------------
'    '
'    '    Natürlich muss die Tabelle existieren und die korrekten Werte aufweisen, um diesen Insert bedienen zu können  ...
'    '
'    '    Ausser ZuAbsage sind alles andere Standard-eMail Felder aus Outlook
'    '    INSERT INTO tbl_eMail_Import (EntryID, ZuAbsage, Sender, Sendername, Betreff, Body, HTMLBody, CreationTime, ReceivedTime )
'    '    Mehr Felder braucht man normalerweise nicht .- EntryID und Sender... = String 255, ZuAbsage = Long, ...Body = Memo, ...Time = Date/Time
'
'    Sub ImportToAccess(oF As Outlook.mailitem)
'
'    'oF ist die aktive eMail, die importiert werden soll...
'
'        Dim adoCon As Object
'        Dim strSQL As String
'    '    Dim oF As Outlook.Items
'        Dim iZuAb As Long
'    '    Dim iVAStart_ID As Long
'
'        Dim strBetreff As String
'
'    '   Jeglichen Fehler ignorieren und einfach doe Prozedur beenden
'        On Error GoTo Ende_Sub
'
'        Set adoCon = CreateObject("ADODB.Connection")
'        adoCon.Open "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & ACCESS_FILE_PATH & ";Persist Security Info=False;"
'
'        adoCon.Execute "INSERT INTO tbl_eMail_Import (EntryID, Sender, Sendername, Betreff, Body, HTMLBody, CreationTime, ReceivedTime ) VALUES ('" & oF.EntryID & "', '" & oF.SenderEmailAddress & "', '" & oF.Sendername & "', '" & fCnvQM(oF.Subject) & "', '" & fCnvQM(oF.Body) & "', '" & fCnvQM(oF.HTMLBody) & "', " & DateTimeForSQL(oF.CreationTime) & ", " & DateTimeForSQL(oF.ReceivedTime) & ")"
'    '    oF.Delete
'
'        Set adoCon = Nothing
'
'    Ende_Sub:
'
'    End Sub
'
'
'    Private Function fCnvQM(ByVal strString As String) As String
'        'Funktion, die Hochkommata - Chr(39) - innerhalb eines Strings verdoppelt,
'        'um Strings, die Hochkommata beinhalten an SQL-Syntax übergeben zu können
'
'        Dim i As Integer
'        Dim strStringNew As String
'
'        For i = 1 To Len(strString)
'            If Mid(strString, i, 1) = Chr(39) Then
'                strStringNew = strStringNew & Chr(39) & Chr(39)
'            Else
'                strStringNew = strStringNew & Mid(strString, i, 1)
'            End If
'        Next i
'
'        'Return Value
'        fCnvQM = strStringNew
'    End Function
'
'    Private Function DateTimeForSQL(dteDate) As String
'    'Datum incl. Uhrzeit für SQL und INI-Files als String
'
'    '  DateTimeForSQL = Format(CDate(dteDate), "\#yyyy\-mm\-dd h:nn:ss AM/PM \#", vbMonday, vbFirstFourDays)
'      DateTimeForSQL = Format(CDate(dteDate), "\#yyyy\-mm\-dd hh:nn:ss\#", vbMonday, vbFirstFourDays)
'
'    End Function
'
'
'