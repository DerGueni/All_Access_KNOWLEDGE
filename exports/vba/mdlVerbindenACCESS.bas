Attribute VB_Name = "mdlVerbindenACCESS"
Option Compare Database
Option Explicit
Option Base 0

Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2

Dim tables As Variant
Dim MAXTABLES As Long

Dim AccCheckTabelle As String


' #############################################################
'    Description
' #############################################################

'  Uses mdlPrivPropery                Module
'       tblProperty Table

'       FileDialog                    Classmodule   - for helping to search the linked mdb

'  "prp_AccCheckTabelle"  Within tblProperty Table contains the name of the table which is checked
'   If this (pre)checked table can be opened, then it is assumed that all connections are OK and no other connections are checked

'     Acc_Acc_tblVerknuepfungstabellen  Table    - contains the names of the tables to be connected
'       JN = False table will not be connected
'       tblName = Source and Destination tablen

' Important functions:
'   checkconnectSQL - Optional different (can be Query) name for Acc_SQL_tblVerknuepfungstabellen, when created via Query - as parameter - same structure
'   DatenMDBWechselSQL  - "

' checkconnectAcc = called in Autoexec Macro
' DatenMDBWechselAcc = Force reconnect (just deletes table-link from "prp_AccCheckTabelle")

' #############################################################




'
'=======================================================================

Function checkconnectAcc()
'Überprüft, ob die Datenbank verbunden sind
Dim db As DAO.Database
Dim tbl As DAO.Recordset
Dim nix
Dim fail As Boolean
Dim AccCheckTabelle As String


On Error GoTo checkconnectError
Set db = DBEngine.Workspaces(0).Databases(0)

AccCheckTabelle = Get_Priv_Property("prp_AccCheckTabelle")
If Len(Trim(Nz(AccCheckTabelle))) = 0 Then
    MsgBox "prp_AccCheckTabelle nicht gefunden bzw leer"
    Exit Function
End If

' Hier einen existierenden Tabellennamen eingeben
' Es wird davon ausgegangen, daß wenn diese Tabelle nicht korrekt connected ist,
' die anderen Tabellen auch nicht korrekt connected sind.

Set tbl = db.OpenRecordset(AccCheckTabelle, dbOpenDynaset, dbSeeChanges)

Exit Function

checkconnectError:
    'Backend auswählen
    Call switchConnectAcc
    
'    'Verbindung aufbauen
'    If fail = False Then
'        fail = True
'        nix = switchConnectAcc(PfadProd & Backend)
'    Else
'        nix = switchConnectAcc()
'    End If
    
    Exit Function

End Function

Function DatenMDBWechselAcc()
'Man kann die Funktion verwenden, wenn man mehrere Daten-Datenbanken hat, um
'zwischen diesen wechseln zu können, oder als Testfunktion des Moduls ...
    
AccCheckTabelle = Get_Priv_Property("prp_AccCheckTabelle")
AccCheckTabelle = Get_Priv_Property("prp_AccCheckTabelle")
If Len(Trim(Nz(AccCheckTabelle))) = 0 Then
    MsgBox "prp_AccCheckTabelle nicht gefunden bzw leer"
    Exit Function
End If
   
    On Error Resume Next
    DoCmd.DeleteObject acTable, AccCheckTabelle
    On Error GoTo DatenMDBWechsel_Err
    checkconnectAcc
DatenMDBWechsel_Exit:
    Exit Function
DatenMDBWechsel_Err:
    MsgBox Error$
    Resume DatenMDBWechsel_Exit
End Function

Function switchConnectAcc(Optional Backend As String)

'switchConnect: a) Vorgeschlagen wird immer das Directory, in dem sich die Programm-Datenbank befindet
'               b) Auskommentiertes Beispiel, wie man immer automatisch mit einer "festen" Daten-Datenbank
'                   anstelle des Dialoges verbinden kann

'Stellt Dialog zur Auswahl einer neuen Datenbank dar
'Nach Auswahl einer neuen adrdata.mdb werden die benötigten Tabellen aus dieser
'verbunden
Dim db As DAO.Database
Dim newdb As String
Dim nix As Integer
Dim i As Integer
Dim frm As Form, countfrm As Integer
Dim fd As New FileDialog
Dim startdir As String
Dim StBeschriftung As String
Dim x As String

On Error GoTo Error_switchConnect
      
' Start-Directory und Beschriftung festlegen.
' Hier das Start-Directory eingeben, in dem die Dateisuche anfangen soll
' Neu: Es wird immer das aktuelle Directory der "Haupt-MDB" angezeigt
   startdir = Left(CurrentDb.Name, Len(CurrentDb.Name) - Len(Dir(CurrentDb.Name)))
   If Right(startdir, 1) <> "\" Then startdir = startdir & "\"
   
''''''''''' Neu in Vers. 3.0:
''''''''''' Wenn im aktuellen Directory die Datei "DeineDaten.mdb" vorhanden ist, wird mit dieser
''''''''''' verbunden, ansonsten wird nach der Datenbank gefragt ...
'''''''''''
    
'''''' Kommentarzeichen weg ...''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'    If Len(Trim(Nz(Dir(startdir & "DeineDaten.MDB")))) > 0 Then
'            newdb = startdir & "DeineDaten.mdb"
'    Else
    If Backend <> "" Then
            newdb = Backend
    Else

'''''' Kommentarzeichen weg ...''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' weiter unten beim End If muß ggf. noch das Kommentarzeichen weg
           
           
        ' Hier die Beschriftung für den Dialog der Dateisuche eingeben
           StBeschriftung = "Daten-Datenbank suchen"
                
        'Wenn alles OK, Dateiname entfernen und nur Directorypath übrig lassen
            If Len(startdir) > 0 Then
                Do
                    x = Right(startdir, 1)
                    If x = "\" Or Len(startdir) = 0 Then
                        Exit Do
                    End If
                    startdir = Left(startdir, Len(startdir) - 1)
                Loop
            Else
        ' Notfall Directory, wenn das Start-Directory nicht gültig ist.
                startdir = "C:\"
            End If
                  
           With fd  ' CommonDialog aufrufen
            ' Erläuterungen im Code des KlassenModuls FileDialog
              
              .DialogTitle = StBeschriftung
              .InitDir = startdir
              
        '      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
        '                                      ' Ansonsten wird Filter1 verwendet
        '      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
              .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                              
        ' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
              
              .Filter1Text = "ACCDB-Dateien (*.accdb)"
              .Filter1Suffix = "*.accdb"
              .Filter2Text = "MDB-Dateien (*.mdb)"
              .Filter2Suffix = "*.mdb"
              .Filter3Text = "MD?-Dateien (*.md?)"
              .Filter3Suffix = "*.md?"
              .Filter4Text = "Alle Dateien (*.*)"
              .Filter4Suffix = "*.*"
        '      .Filter5Text = "DOC-Dateien (*.doc)"
        '      .Filter5Suffix = "*.doc"
        
        '      ... bis max. Filter5Text/Suffix ...
        '
              .ShowOpen                          ' oder .ShowSave
           End With
           
        newdb = fd.fileName
        
'''''' Kommentarzeichen weg ...''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

   End If

'''''' Kommentarzeichen weg ...''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        
If Len(newdb) > 0 Then
    ' Wenn Datenbank verbunden
    'Alle Formulare aktualisieren
    'Dazu alle Formulare merken und schliessen
    'Dim frm As Form, countfrm As Integer
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
    Set db = DBEngine.Workspaces(0).Databases(0) 'Für eigene Datenbank
    If Not ConnectDBAcc(db, newdb) Then
        nix = MsgBox("Tabellen konnten nicht ordungsgemäß verbunden werden ", vbCritical, "Fehler beim Verbinden")
        Exit Function
    End If

    'Alle Formulare wieder öffnen
    For i = 0 To countfrm - 1
        nix = frmOpen(merkform(i), vbNormal)
    Next i
'Else
    ' Fehler
End If

Exit Function

Error_switchConnect:
   MsgBox Error$, , "Error_btnSuchen_Clickd Sub"
   Resume switchConnect_Exit
   
switchConnect_Exit:
End Function

Function ConnectDBAcc(db As DAO.Database, datapath As String, Optional Errdb As String) As Integer
'Verbindet alle Datendatenbank in der Datenbank db neu
'datapath: Datenbank mit der Verbindung hergestellt werden soll
'Rückgabe: TRUE, erfolgreich verbunden
'          FALSE, Verbindungen konnten nicht hergestellt werden

Const TEMPTBL = "~temp"

Dim i As Integer

' Hier müssen die gewünschten Tabellen "hardcoded" eingegeben werden.
' Dies hat den Vorteil gegenüber einer Prozedur "alle Einbinden", daß man
' selektiv Tabellen auswählen kann, die eingebunden werden sollen.

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
    
Dim DB1 As DAO.Database
Dim rst As DAO.Recordset
    
Dim iFldNr As Long
Dim iRecNr As Long

Dim iFldNrMax As Long
Dim iRecNrMax As Long

Set DB1 = CurrentDb
Set rst = DB1.OpenRecordset("SELECT tblName FROM Acc_Acc_tblVerknuepfungstabellen WHERE jn = True ORDER BY ID;", dbOpenDynaset, dbSeeChanges)
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
        If Not VerbindeAcc(db, TEMPTBL, tables(0, i), datapath) Then
            Debug.Print tables(0, i)
            On Error Resume Next
            DoCmd.DeleteObject acTable, TEMPTBL
            ConnectDBAcc = False
            Exit Function
        End If
    End If
Next i

'Temp. Tabelle löschen
DoCmd.DeleteObject acTable, TEMPTBL

'---Connect
For i = 0 To MAXTABLES
    If Len(Nz(tables(0, i))) > 0 Then
        If Not VerbindeAcc(db, tables(0, i), tables(0, i), datapath) Then
            ConnectDBAcc = False
            Exit Function
        End If
    End If
Next i

ConnectDBAcc = True
Exit Function

ConnectDBError:
    On Error Resume Next
    ConnectDBAcc = False
    Exit Function
End Function


'*****************************************************************************
' Function Verbinde()
'
'   Verbindet die Tabelle mytab in meiner Datenbank db unter den Namen ntab mit der fremden Datenbank strdb
'Rückgabe: TRUE, Verbindung erfolgreich hergestellt
'          FALSE, Verbindung konnte nicht hergestellt werden
'*****************************************************************************
Public Function VerbindeAcc(db As DAO.Database, ByVal ntab As String, ByVal mytab As String, ByVal strDB As String) As Integer

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

'mytable.Connect = "MS ACCESS;DATABASE=" & strDb & ";PWD=" & XPasswd & ";"
mytable.Connect = "MS ACCESS;DATABASE=" & strDB
db.TableDefs.append mytable
    
VerbindeAcc = True
Exit Function

VerbindeError:

VerbindeAcc = False
Exit Function

End Function


Function frmClose(ByVal frmName As String)
'Schließt das Formular frmname

DoCmd.Close acForm, frmName

End Function

Function frmOpen(ByVal frmName As String, ByVal Modus)
'Öffnet das Formular frnname
'modus wie in ACCESS: acNORMAL, acHIDDEN, acICON, AcDIALOG

DoCmd.OpenForm frmName, , , , , Modus

End Function

Function TabTempLosesch()

    On Error Resume Next
    
    DoCmd.SetWarnings False
    DoCmd.DeleteObject acTable, "tblBeispiel"
    DoCmd.DeleteObject acTable, "tblTest1"
    DoCmd.DeleteObject acTable, "tblTest2"
    DoCmd.SetWarnings True

End Function


'''''''''''''''''''''''''''''''''
'Separate Funktion, um eine einzelne Tabelle von einer MDB sicher einzubinden
'''''''''''''''''''''''''''''''''
Function CopyUsr_verb(ByVal xtbl As String, ByVal xdb As String, Optional XPasswd As String = "", Optional ByVal NeuTabNam As String) As Boolean
'
' Parameter: xtbl = Einzubindende Tabelle
'            xdb = Fremde mdb
'            XPasswd = Datenbankpasswort
'            NeuTabNam = abweichender neuer Tabellenname
'
' Wenn kein "\" in xdb vorhanden ist, muss die xdb im gleichen Directory wie die "current" mdb stehen
' Optional kann ein Passwort mitgegeben werden sowie ein neuer Name für die Tabelle
'
' Beispiele:
' CopyUsr_verb("tblBearbeiter","Hugo.mdb")
' CopyUsr_verb("tblBearbeiter","C:\Hugo\Hugo.mdb")
' CopyUsr_verb("tblBearbeiter","Hugo.mdb","Hugo")
' CopyUsr_verb("tblBearbeiter","C:\Hugo\Hugo.mdb","Hugo","tblHugo") 'Als Tabelle mit Namen tblHugo
'
Dim db As DAO.Database
Dim Daten As String
Dim i As Integer

Dim mytable As TableDef
'----------------------------------------
CopyUsr_verb = False

On Error Resume Next
'Wenn kein anderer Name gewünscht, den gleichen Namen verwenden
If Len(Trim(Nz(NeuTabNam))) = 0 Then
    NeuTabNam = xtbl
End If

'Bestehende Verbindung löschen
DoCmd.DeleteObject acTable, NeuTabNam

On Error GoTo Fehlermeldung
      
Set db = CurrentDb()
Set mytable = db.CreateTableDef(NeuTabNam)

mytable.SourceTableName = xtbl

If InStr(1, xdb, "\", vbBinaryCompare) > 0 Then
    Daten = xdb
Else
    Daten = Left(db.Name, Len(db.Name) - Len(Dir(db.Name))) & xdb
End If

If Len(Trim(Nz(XPasswd))) > 0 Then
    mytable.Connect = ";PWD=" & XPasswd & ";" & ";DATABASE=" & Daten
Else
    mytable.Connect = ";DATABASE=" & Daten
End If

db.TableDefs.append mytable

Set db = Nothing
CopyUsr_verb = True

Exit Function
Fehlermeldung:
CopyUsr_verb = False
MsgBox "Bei der Einbindung von " & xtbl & " ist ein Fehler aufgetreten. ", 16, xdb & " - Fehler"
End Function
