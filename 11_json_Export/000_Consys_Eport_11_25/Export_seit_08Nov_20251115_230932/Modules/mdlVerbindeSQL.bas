Option Compare Database
Option Explicit
Option Base 0

Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2

Dim Servername As String
Dim Instancename As String
Dim SQLDatabasename As String
Dim SQLCheckTabelle As String

Dim Connectionstring As String

Dim tables As Variant
Dim MAXTABLES As Long

' #############################################################
'    Description
' #############################################################

'  Uses mdlPrivPropery                Module
'       tblProperty Table

'  "prp_SQLCheckTabelle"  Within tblProperty Table contains the name of the table which is checked
'   If this (pre)checked table can be opened, then it is assumed that all connections are OK and no other connections are checked

'     Acc_SQL_tblVerknuepfungstabellen  Table    - contains the names of the tables to be connected
'       JN = False table will not be connected
'       tblName = Destination-Name in frontend
'       tblname_org = Source-name in backend
'       Indexfkt = If Views are connected as table, you can specify an create Index SQL Command
'                  like: "CREATE UNIQUE INDEX PK1 ON qry_Projektkopf (pkoNummer)"
'                  which then is executed
'       IDSort = the connection sequence
'       Bemerkungen - just remarks
'       SQLConnectionstring - Form "_frmHlp_Connectionstring_erzeugen" helps to create

' Important functions:
'   checkconnectSQL - Optional different (can be Query) name for Acc_SQL_tblVerknuepfungstabellen, when created via Query - as parameter - same structure
'   DatenMDBWechselSQL  - "

' checkconnectSQL = called in Autoexec Macro
' DatenMDBWechselSQL = Force reconnect (just deletes table-link from "prp_SQLCheckTabelle")

' #############################################################


Function checkconnectSQL(Optional Verknuepfungstabelle As String = "Acc_SQL_tblVerknuepfungstabellen") As Boolean
'Überprüft, ob die Datenbank verbunden sind
Dim db As DAO.Database
Dim tbl As DAO.Recordset
Dim nix

Dim SQLTrustedConn As String
Dim SQLUser As String
Dim SQLPasswd As String
checkconnectSQL = False

On Error GoTo checkconnectError

' ODBC;Driver={SQL Server Native Client 10.0};
' Statt
' ODBC;Driver={SQL Server};
'
'DRIVER={SQL Server};SERVER=servername;DATABASE=datenbankname;UID=benutzername;PWD=kennwort
'
'ODBC;DRIVER={SQL Server};SERVER=190.190.200.100,1433;DATABASE=RegDB_Data;Trusted_Connection=Yes;
'ODBC;DRIVER={SQL Server};SERVER=190.190.200.100,1433\SQLInstanz;DATABASE=RegDB_Data;Trusted_Connection=Yes;
'ODBC;DRIVER={SQL Server};SERVER=190.190.200.100,1433\SQLInstanz;DATABASE=RegDB_Data;Trusted_Connection=No;UID=KobdTest;PWD=EinPw0rt;"
'
''Die Parameter Uid und Pwd können bei der NT-Authentifizierung entfallen und müssen durch Trusted_Connection=Yes ersetzt werden

'Connectionstring = "ODBC;DRIVER={SQL Server};SERVER=" & Servername & Instancename & ";DATABASE=" & SQLDatabasename & ";Trusted_Connection=No;UID=KobdTest;PWD=EinPw0rt;"

'Trusted Connection
'Connectionstring = "ODBC;DRIVER={SQL Server};SERVER=" & Servername & Instancename & ";DATABASE=" & SQLDatabasename & ";Trusted_Connection=Yes"
'sa ohne passwort
'Connectionstring = "ODBC;DRIVER={SQL Server};SERVER=" & Servername & Instancename & ";DATABASE=" & SQLDatabasename & ";Trusted_Connection=No;UID=sa;PWD=;"
'User mit Passwort
'Connectionstring = "ODBC;DRIVER={SQL Server};SERVER=" & Servername & Instancename & ";DATABASE=" & SQLDatabasename & ";Trusted_Connection=No;UID=KobdTest;PWD=EinPw0rt;"

'Connectionstring = "ODBC;DRIVER={SQL Server};SERVER=" & Servername & Instancename & ";DATABASE=" & SQLDatabasename & ";Trusted_Connection=" & SQLTrustedConn & ";"
'Connectionstring = "ODBC;Driver={SQL Server Native Client 10.0};SERVER=" & Servername & Instancename & ";DATABASE=" & SQLDatabasename & ";Trusted_Connection=" & SQLTrustedConn & ";"

'Set db = DBEngine.Workspaces(0).Databases(0)
Set db = CurrentDb

SQLCheckTabelle = Get_Priv_Property("prp_SQLCheckTabelle")
If Len(Trim(Nz(SQLCheckTabelle))) = 0 Then
    MsgBox "prp_SQLCheckTabelle nicht gefunden bzw leer"
    Exit Function
End If

' Hier einen existierenden Tabellennamen eingeben
' Es wird davon ausgegangen, daß wenn diese Tabelle nicht korrekt connected ist,
' die anderen Tabellen auch nicht korrekt connected sind.

Set tbl = db.OpenRecordset(SQLCheckTabelle, dbOpenDynaset, dbSeeChanges)
DoEvents
'Call Set_Priv_Property("prp_AllIsOK", -1)

checkconnectSQL = True
Exit Function

checkconnectError:
    'Verbindung aufbauen
    checkconnectSQL = switchConnectSQL(Verknuepfungstabelle)
    Exit Function

End Function

'Connectionstring = "ODBC;Driver={SQL Server Native Client 10.0};SERVER=" & [SQLServername] & [SQLInstancename] & ";DATABASE=" & [SQLDatabasename] & ";Trusted_Connection=" & [SQLTrustedConn] & ";"


Function DatenMDBWechselSQL(Optional Verknuepfungstabelle As String = "Acc_SQL_tblVerknuepfungstabellen") As Boolean
'Man kann die Funktion verwenden, wenn man mehrere Daten-Datenbanken hat, um
'zwischen diesen wechseln zu können, oder als Testfunktion des Moduls ...
    
    SQLCheckTabelle = Get_Priv_Property("prp_SQLCheckTabelle")
    If Len(Trim(Nz(SQLCheckTabelle))) = 0 Then
        MsgBox "prp_SQLCheckTabelle nicht gefunden bzw leer"
        Exit Function
    End If
  
    DatenMDBWechselSQL = False
    On Error Resume Next
    DoCmd.DeleteObject acTable, SQLCheckTabelle
    On Error GoTo DatenMDBWechsel_Err
    DatenMDBWechselSQL = checkconnectSQL(Verknuepfungstabelle)
DatenMDBWechsel_Exit:
    Exit Function
DatenMDBWechsel_Err:
    DatenMDBWechselSQL = False
    MsgBox Error$
    Resume DatenMDBWechsel_Exit
End Function

Public Function switchConnectSQL(Optional Verknuepfungstabelle As String = "Acc_SQL_tblVerknuepfungstabellen") As Boolean

Dim db As DAO.Database
Dim newdb As String
Dim nix As Integer
Dim i As Integer, countfrm As Integer
Dim frm As Form
'Dim fd As New FileDialog
Dim startdir As String
Dim StBeschriftung As String
Dim x As String

switchConnectSQL = False
On Error GoTo Error_switchConnectSQL
             
newdb = "xx"
        
If Len(newdb) > 0 Then
    ' Wenn Datenbank verbunden
    'Alle Formulare aktualisieren
    'Dazu alle Formulare merken und schliessen
    countfrm = Forms.Count
    If countfrm > 0 Then
        ReDim merkform(countfrm) As String
        For i = 0 To countfrm - 1
            Set frm = Forms(i)
            merkform(i) = frm.Name
        Next i
        For i = 0 To countfrm - 1
            nix = frmClose(merkform(i))
        Next i
    End If

    'Datenbank neu verbinden
'    Set db = DBEngine.Workspaces(0).Databases(0) 'Für eigene Datenbank
    Set db = CurrentDb
    If Not ConnectDB(db, newdb, Verknuepfungstabelle) Then
        nix = MsgBox("Tabellen konnten nicht ordungsgemäß verbunden werden ", vbCritical, "Fehler beim Verbinden")
'        DoCmd.OpenForm "frmSQLServerLinkNames", acNormal, , , , acDialog
        Exit Function
    End If

    'Alle Formulare wieder öffnen
    For i = 0 To countfrm - 1
        nix = frmOpen(merkform(i), vbNormal)
    Next i
    
    switchConnectSQL = True
'Else
    ' Fehler
End If

Exit Function

Error_switchConnectSQL:
   switchConnectSQL = False
   MsgBox Error$, , "Error_btnSuchen_Clickd Sub"
   Resume switchConnectSQL_Exit
   
switchConnectSQL_Exit:
End Function

Private Function ConnectDB(db As DAO.Database, datapath As String, Optional Verknuepfungstabelle As String = "Acc_SQL_tblVerknuepfungstabellen") As Integer
'Verbindet alle Datendatenbank in der Datenbank db neu
'datapath: Datenbank mit der Verbindung hergestellt werden soll
'Rückgabe: TRUE, erfolgreich verbunden
'          FALSE, Verbindungen konnten nicht hergestellt werden

Const TEMPTBL = "~temp"

Dim i As Integer

'Die Verknüpfungstabellen werden aus der Tabelle Acc_Acc_tblVerknuepfungstabellen gelesen
'18.03.2008
    
' Besonders einfach in Zusammenhang mit qrymdbTable zu verwenden
    
' qrymdbTable:
'SELECT MSysObjects.Name
'FROM MSysObjects
'WHERE (((MSysObjects.Type) = 1) And ((MSysObjects.Flags) = 0) And ((LCase(Left([Name], 4))) <> "usys")) Or (((MSysObjects.ForeignName) Is Not Null))
'ORDER BY MSysObjects.Name;

'und dann

' "SELECT qrymdbTable.Name AS tblName, True AS jn INTO Acc_Acc_tblVerknuepfungstabellen FROM qrymdbTable;"
    
'Dim DB1 As dao.Database
Dim rst As DAO.Recordset
    
Dim iFldNr As Long
Dim iRecNr As Long

Dim iFldNrMax As Long
Dim iRecNrMax As Long

Dim strpk As String

'Set db1 = CurrentDb
Set rst = db.OpenRecordset("SELECT tblname, tblname_org, Indexfkt, SQLConnectionstring FROM " & Verknuepfungstabelle & " WHERE jn = True ORDER BY IDSort;", dbOpenDynaset, dbSeeChanges)
rst.MoveLast
i = rst.RecordCount
rst.MoveFirst
tables = rst.GetRows(i)
rst.Close
Set rst = Nothing

'Achtung immer Nullbasiert
'Tables(iFldNr,iRecNr)
'Tables(iSpalte,iZeile)

iFldNrMax = UBound(tables, 1)
iRecNrMax = UBound(tables, 2)

MAXTABLES = iRecNrMax
    
On Error GoTo ConnectDBError

'Prüfen, ob alle Verbindungen hergestellt werden können
For i = 0 To MAXTABLES
    If Len(Nz(tables(0, i))) > 0 Then
        If Not Verbinde(db, TEMPTBL, tables(1, i), (CStr(tables(3, i)))) Then
            On Error Resume Next
            DoCmd.DeleteObject acTable, TEMPTBL
            ConnectDB = False
            Exit Function
        End If
    End If
Next i

'Temp. Tabelle löschen
DoCmd.DeleteObject acTable, TEMPTBL

'---Connect
For i = 0 To MAXTABLES
    If Len(Nz(tables(0, i))) > 0 Then
        If Not Verbinde(db, tables(0, i), tables(1, i), (CStr(tables(3, i)))) Then
            ConnectDB = False
            Exit Function
        Else
            DoEvents
            strpk = Nz(tables(2, i))
            If Len(strpk) > 0 Then
                CurrentDb.Execute (strpk)
            End If
        End If
    End If
Next i

ConnectDB = True
Exit Function

ConnectDBError:
    On Error Resume Next
    ConnectDB = False
    Exit Function
End Function



'*****************************************************************************
' Function Verbinde()
'
'   Verbindet die Tabelle mytab in der Datenbank db unter den Namen ntab mit der Datenbank strdb
'Rückgabe: TRUE, Verbindung erfolgreich hergestellt
'          FALSE, Verbindung konnte nicht hergestellt werden
'*****************************************************************************
Private Function Verbinde(db As DAO.Database, ByVal ntab As String, ByVal mytab As String, ByVal Connectionstring As String) As Integer

Dim mytable As TableDef
'----------------------------------------
 On Error Resume Next
 'Bestehende Verbindung löschen
 DoCmd.DeleteObject acTable, ntab
 On Error GoTo 0

'On Error GoTo VerbindeError1
 'Wenn hier Fehler auftritt ist Tabelle noch nicht eingebunden
 'Set mytable = db.TableDefs(mytab)
 'Jetzt wird bestehende Verbindung aktualisiert
 'mytable.SourcetableName = mytab
 'mytable.connect = ";DATABASE=" & strdb
 'mytable.RefreshLink
'Verbinde = True
'Exit Function
'VerbindeError1:

On Error GoTo VerbindeError
'Tabelle neu einbinden
Set mytable = db.CreateTableDef(ntab)

mytable.SourceTableName = mytab

'hier könnte man auch ein einfaches Daten-Datenbank-Passwort (hier:"Hugo") speichern ...
'mytable.Connect = "MS ACCESS;PWD=Hugo;DATABASE="

'Die Tabellen des SQL Servers sollen zu Access verknüpft werden. Es soll jedoch keine DSN erstellt werden.
'Wie lautet die Syntax für einen DSN-Less Connectstring?
'
'Lösung:
'DRIVER={SQL Server};SERVER=servername;DATABASE=datenbankname;UID=benutzername;PWD=kennwort
'
''Die Parameter Uid und Pwd können bei der NT-Authentifizierung entfallen und müssen durch Trusted_Connection=Yes ersetzt werden


mytable.Connect = Connectionstring
db.TableDefs.append mytable
Verbinde = True
Exit Function

VerbindeError:

Verbinde = False
Exit Function

End Function

Private Function frmClose(ByVal frmName As String)
'Schließt das Formular frmname

DoCmd.Close acForm, frmName

End Function

Private Function frmOpen(ByVal frmName As String, ByVal Modus)
'Öffnet das Formular frnname
'modus wie in ACCESS: acNORMAL, acHIDDEN, acICON, AcDIALOG

DoCmd.OpenForm frmName, , , , , Modus

End Function

Private Function TabTempLosesch()

    On Error Resume Next
    
    DoCmd.SetWarnings False
    DoCmd.DeleteObject acTable, "tblBeispiel"
    DoCmd.DeleteObject acTable, "tblTest1"
    DoCmd.DeleteObject acTable, "tblTest2"
    DoCmd.SetWarnings True

End Function


Function pk1()
CurrentDb.Execute "CREATE UNIQUE INDEX PK1 ON qry_Projektkopf (pkoNummer)"
End Function
Function pk2()
CurrentDb.Execute "CREATE UNIQUE INDEX PK2 ON qryPpoPpu (ppoID)"
End Function