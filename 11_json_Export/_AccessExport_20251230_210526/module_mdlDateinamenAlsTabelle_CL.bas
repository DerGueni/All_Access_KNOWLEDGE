Option Compare Database
Option Explicit

Global IstVB_Einlesen As Boolean
Global actyp As String

Dim giMainFolderStrLen As Integer

Const gcMaxSubfolders = 250
'* nur die ersten 250 Unterverzeichnisse pro Ebene berücksichtigen


'**********************************************************************************
'* Hauptfunktion:
'**********************************************************************************
Sub ReadFileInfos_CL(strTblName As String, ByVal strFolderName As String, _
    Optional strDatabaseName As String = "[Current]")
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

Set rs = db.OpenRecordset(strTblName)

If Right(strFolderName, 1) <> "\" Then strFolderName = strFolderName & "\"
ReadFolderInfo rs, strFolderName
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
'* Modified speziell für Code-Lurker - 12.10.2013 K.Obd
'**********************************************************************************

Private Sub ReadFolderInfo(rs As DAO.Recordset, strFolderName As String)

Dim arrFoldernames(gcMaxSubfolders)
Dim filename As String
'Dim X As FileInfo
'Dim FileVer As String
'Dim dwHandle&, BUFSIZE&, lpvData$, r&
Dim iLoop As Long, iLoop2 As Long, Types As String
Dim i As Long

filename = Dir(strFolderName, vbDirectory)
iLoop = -1


'* nur die ersten 250 Unterverzeichnisse berücksichtigen
'* (Const gcMaxSubfolders = 250)
While filename <> "" And iLoop < gcMaxSubfolders
    If filename <> "." And filename <> ".." And filename <> "" Then
        '* Mit bitweisem Vergleich sicherstellen, daß Name1 ein
        '* Verzeichnis ist.
        If (GetAttr(strFolderName & filename) And vbDirectory) = vbDirectory Then
            iLoop = iLoop + 1
            arrFoldernames(iLoop) = filename
        Else
''############# nur bestimmte Dateitypen selektieren (siehe auch weiter unten)
'          ' Um nur bestimmte Dateitypen einzulesen: (auskommentiert, daher alle Dateien)
'            Types = UCase(Right(FileName, 3))
'            Select Case Types
'                Case "JPG", "PCD", "PCX", "WMF", "EMF", "DIB", "BMP", "ICO", "EPS", "PCT", "DXF", "CGM", "CDR", "TGA", "GIF", "PNG", "WPG", "DRW", "TIF"
'                ' Es handelt sich um eine Bild-Datei
            
''#############
                 
                If IstVB_Einlesen = False Then
                    actyp = LCase(Right(strFolderName, 4))
                    actyp = Left(actyp, 3) ' Ohne "\" am Ende
                    If actyp = "mac" Or actyp = "mdl" Or actyp = "rpt" Or actyp = "qry" Or actyp = "frm" Then
                        rs.AddNew
                            rs!IsUsed = True
                            If actyp = "mac" Then
                                rs!IsUsed = False
                            End If
                            If actyp = "qry" Then
                                rs!IsUsed = False
                            End If
                            If actyp = "mdl" Or actyp = "mac" Or actyp = "qry" Then
                                rs!IstModul = True
                            End If
                            rs!Type = actyp
                            rs!filename = strFolderName & filename
                            rs!formName = Left(filename, Len(filename) - 4)
                        rs.update
                    End If
                Else
                    i = Len(actyp)
                    If actyp = LCase(Right(filename, i)) Then
                        rs.AddNew
                            If actyp = "cls" Or actyp = "bas" Then
                                rs!IstModul = True
                            End If
                            rs!Type = actyp
                            rs!filename = strFolderName & filename
                            rs!formName = Left(filename, Len(filename) - 4)
                        rs.update
                    End If
                End If

''############# nur bestimmte Dateitypen selektieren
'                Case Else
'            End Select
''################
        End If
    End If
    filename = Dir
    DoEvents
Wend

For iLoop2 = 0 To iLoop
    ReadFolderInfo rs, strFolderName & arrFoldernames(iLoop2) & "\"
    DoEvents
Next iLoop2

End Sub