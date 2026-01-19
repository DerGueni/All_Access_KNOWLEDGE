Attribute VB_Name = "mdlDateinamenAlsTabelle"
Option Compare Database
Option Explicit

'========================================================================
'ACHTUNG: die Reihenfolge der Parameter beim Aufruf wurde geändert !!!!!!
'
'ist jetzt
'* Call ReadFileInfos("DeineTablelle", "DeinStartVerzeichnis" [,"DeineMDB"] )
'Den MDB-Namen habi ich nach hinten versetzt. Wenn er nicht mit angegeben wird,
'ist es automatisch die eigene MDB
'========================================================================

'**********************************************************************************
'* Aus der deutschen MS KnowledgeBase
'**********************************************************************************
'* Art.Nr.: D33747
'* Tabelle mit Datei-Informationen eines Verzeichnisbaums füllen (VB5)
'* ===================================================================
'* Beispiel:
'* Call ReadFileInfos("tblNeuDateinamen", "C:\Eigene Dateien" )
'*
'* Änderung am 7.3.1999 strDatabaseName ans Ende und Optional und ("[Current]") als Default
'*                      Sofern die Tabelle bereits existiert, wird sie vorher gelöscht, doEvents eingefügt
'*                      Rekursionsfunktion mit Beispiel für selektive Dateitypen (z.B. nur Bilder)
'*
'* legt in der Tabelle "tblNeuDateinamen" alle Dateinamen etc...
'* aus dem Subdirectory "C:\Eigene Dateien" in der eigenen MDB ab
'* Aber statt [Current] ein absoluter Pfadname "C:\hugo\meine.mdb" geht auch ...
'* In der Rekursionsfunktion ist der Befehl:
'*       rs!Ordner = Mid(strFolderName, giMainFolderStrLen + 1)
'* auskommentiert, und dafür
'*       rs!Ordner = strFolderName
'* gesetzt, da ich absolute Pfadnamen (incl. der Eingabe) sinnvoller finde ...
'* ansonsten wird im Ordner nur "\" für den "current Pfad" angelegt.
'* so wird z.B.: "C:\Eigene Dateien\" als Ordner zurückgegeben.
'* Der Laufwerksbuchstabe wird nicht dazugesetzt, d.h. wenn der Laufwerksbuchstabe
'* Im Ordner gewünscht ist, so muß er bei der Übergabe (in strFolderName)
'* mit angegeben werden.
'**********************************************************************************

Private Type FileInfo
    wLength As Integer
    wValueLength As Integer
    szKey As String * 16
    dwSignature As Long
    dwStrucVersion As Long
    dwFileVersionMS As Long
    dwFileVersionLS As Long
End Type

'**********************************************************************************
'* Funktionsvereinbarungen für die APIs:
'*
'**********************************************************************************
Private Declare PtrSafe Function GetFileVersionInfo& Lib "VERSION" _
    Alias "GetFileVersionInfoA" _
    (ByVal fileName$, ByVal dwHandle&, ByVal cbBuff&, ByVal lpvData$)

Private Declare PtrSafe Function GetFileVersionInfoSize& Lib "VERSION" _
    Alias "GetFileVersionInfoSizeA" _
    (ByVal fileName$, dwHandle&)

Private Declare PtrSafe Sub hmemcpy Lib "kernel32" _
    Alias "RtlMoveMemory" _
    (hpvDest As Any, hpvSource As Any, ByVal cbBytes&)

'**********************************************************************************
'* globale Hilfsvariable
'*
'**********************************************************************************
Dim giMainFolderStrLen As Integer

'* globale Konstante
Const gcMaxSubfolders = 250
'* nur die ersten 250 Unterverzeichnisse pro Ebene berücksichtigen

'**********************************************************************************
'* Hilfsfunktionen:
'*
'**********************************************************************************
Function LOWord(x As Long) As Integer
On Error Resume Next
LOWord = x And &HFFFF&
'Low 16 bits contain Minor revision number.
End Function

Function HIWord(x As Long) As Integer
On Error Resume Next
HIWord = x \ &HFFFF&
'High 16 bits contain Major revision number.
End Function


Function RdfiInf(strTblName As String, ByVal strFolderName As String, _
    Optional strDatabaseName As String = "[Current]")
    Call ReadFileInfos(strTblName, strFolderName, strDatabaseName, False)
End Function

'**********************************************************************************
'* Hauptfunktion:
'**********************************************************************************
Sub ReadFileInfos(strTblName As String, ByVal strFolderName As String, _
    Optional strDatabaseName As String = "[Current]", Optional IstAbs As Boolean = True)
'**********************************************************************************
'* Beispiel:
'* Call ReadFileInfos("tblNeuDateinamen", "C:\Eigene Dateien")
'* Call ReadFileInfos("tblNeuDateinamen", "C:\Eigene Dateien", "C:\Programme\Microsoft Office\Office\Nordwind.mdb")
'*
'* Änderung am 7.3.1999 strDatabaseName ans Ende und Optional
'*                      Sofern die Tabelle bereits existiert, wird sie vorher gelöscht
'*
'* Öffnet die ACCESS-Datenbank mit dem in strDatabaseName_
'* übergebenen Namen, bzw. legt diese neu an, wenn nicht vorhanden. _
'* Legt dort eine neue Tabelle mit dem in strTblName übergebenen _
'* Namen an und speichert darin die Datei-Informationen des _
'* Verzeichnisbaums mit der in strFolderName _
'* übergebenen Wurzel.
'*
'**********************************************************************************

Dim db As DAO.Database
Dim rs As DAO.Recordset
Dim td As TableDef
Dim fld As field
Dim tbl As DAO.Recordset

DoCmd.Hourglass True

giMainFolderStrLen = Len(strFolderName)

'* Das if [Current] habe ich eingefügt, um die Tabelle
'* ggf. in der laufenden DB einfügen zu können
If strDatabaseName = "[Current]" Then   ' Verwende CurrentDb
    Set db = CurrentDb
Else
    If Dir(strDatabaseName) = "" Then ' Datenbank existiert nicht
        Set db = DBEngine.CreateDatabase(strDatabaseName, dbLangGeneral)
    Else    ' Datenbank existiert
        Set db = DBEngine.OpenDatabase(strDatabaseName)
    End If
End If

'Tabelle löschen, sofern vorhanden, Fehler (Tabelle nicht vorhanden) ignorieren
On Error Resume Next
db.TableDefs.Delete strTblName
On Error GoTo 0

DoEvents
Sleep 20
DoEvents

Set td = db.CreateTableDef(strTblName)
' Felder hinzufügen.
Set fld = td.CreateField("Ordner", dbText, 255)
td.fields.append fld
Set fld = td.CreateField("Dateiname", dbText, 255)
td.fields.append fld
Set fld = td.CreateField("Version", dbText, 50)
td.fields.append fld
Set fld = td.CreateField("Datum", dbDate)
td.fields.append fld
Set fld = td.CreateField("Länge", dbDouble)
td.fields.append fld
' TableDef-Definition durch Anfügen an TableDefs-Auflistung speichern.
db.TableDefs.append td

Set rs = db.OpenRecordset(strTblName)

If Right(strFolderName, 1) <> "\" Then strFolderName = strFolderName & "\"
ReadFolderInfo rs, strFolderName, IstAbs
rs.Close

'* Von mir eingefügt, um die aktuelle DB nicht zu schließen
If strDatabaseName <> "[Current]" Then
    db.Close
Else
    Set db = Nothing
End If

DoCmd.Hourglass False

End Sub

'**********************************************************************************
'* Rekursionsfunktion:
'**********************************************************************************
'* Diese Funktion wird von ReadFileInfos(..) aufgerufen und ruft sich
'* jedesmal selber auf, wenn der untersuchte Verzeichniseintrag ein
'* Unterverzeichnis ist. Alle übrigen Dateieinträge werden im übergebenen
'* Recordset-Objekt gespeichert.
'**********************************************************************************

Sub ReadFolderInfo(rs As DAO.Recordset, strFolderName As String, IstAbs As Boolean)

Dim arrFoldernames(gcMaxSubfolders)
Dim fileName As String
Dim x As FileInfo
Dim FileVer As String
Dim dwHandle&, BUFSIZE&, lpvData$, r&
Dim iLoop As Long, iLoop2 As Long, Types As String

fileName = Dir(strFolderName, vbDirectory)
iLoop = -1

'* nur die ersten 250 Unterverzeichnisse berücksichtigen
'* (Const gcMaxSubfolders = 250)
While fileName <> "" And iLoop < gcMaxSubfolders
    If fileName <> "." And fileName <> ".." And fileName <> "" Then
        '* Mit bitweisem Vergleich sicherstellen, daß Name1 ein
        '* Verzeichnis ist.
        If (GetAttr(strFolderName & fileName) And vbDirectory) = vbDirectory Then
            iLoop = iLoop + 1
            arrFoldernames(iLoop) = fileName
        Else
''############# nur bestimmte Dateitypen selektieren (siehe auch weiter unten)
'          ' Um nur bestimmte Dateitypen einzulesen: (auskommentiert, daher alle Dateien)
'            Types = UCase(Right(FileName, 3))
'            Select Case Types
'                Case "JPG", "PCD", "PCX", "WMF", "EMF", "DIB", "BMP", "ICO", "EPS", "PCT", "DXF", "CGM", "CDR", "TGA", "GIF", "PNG", "WPG", "DRW", "TIF"
'                ' Es handelt sich um eine Bild-Datei
''#############
            '*** Version Information lesen, wenn vorhanden ****
                  FileVer = ""
                  BUFSIZE& = GetFileVersionInfoSize(strFolderName & fileName, dwHandle&)
                  If BUFSIZE& = 0 Then
                      FileVer = "no Version"
                  Else
                      lpvData$ = Space$(BUFSIZE&)
                      r& = GetFileVersionInfo(strFolderName & fileName, dwHandle&, BUFSIZE&, lpvData$)
                      hmemcpy x, ByVal lpvData$, Len(x)
                      
                      '**** Datei Versions-Nummer interpretieren ****
                      FileVer = Trim$(str$(HIWord(x.dwFileVersionMS))) + "."
                      FileVer = FileVer + Trim$(str$(LOWord(x.dwFileVersionMS))) + "."
                      FileVer = FileVer + Trim$(str$(HIWord(x.dwFileVersionLS))) + "."
                      FileVer = FileVer + Trim$(str$(LOWord(x.dwFileVersionLS)))
                  End If
                  rs.AddNew
                
                  If IstAbs = False Then
                    '  gibt ohne den eingegebenen Pfad (relativ) zurück
                      rs!Ordner = Mid(strFolderName, giMainFolderStrLen + 1)
                  Else
                    '
                    '  gibt mit eingegebenem Pfad (absolut) zurück
                      rs!Ordner = Trim(strFolderName)
                  End If
                  
                  If Right(rs!Ordner, 2) = "\\" Then rs!Ordner = Left(rs!Ordner, Len(rs!Ordner) - 1)
                  If Right(rs!Ordner, 1) <> "\" Then rs!Ordner = rs!Ordner & "\"
                  
                  rs!Dateiname = fileName
                  rs!Länge = FileLen(strFolderName & fileName)
                  rs!Datum = FileDateTime(strFolderName & fileName)
                  rs!VERSION = FileVer
                  rs.update
''############# nur bestimmte Dateitypen selektieren
'                Case Else
'            End Select
''################
        End If
    End If
    fileName = Dir
    DoEvents
Wend

For iLoop2 = 0 To iLoop
    ReadFolderInfo rs, strFolderName & arrFoldernames(iLoop2) & "\", IstAbs
    DoEvents
Next iLoop2

End Sub

