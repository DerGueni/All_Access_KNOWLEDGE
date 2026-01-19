Attribute VB_Name = "Modul3"
Option Compare Database

' Modul: mdl_MA_Dokumente
' Zweck: Verwaltung digitaler Personalakten

Public Const PERSONALAKTEN_PFAD As String = "C:\Users\guenther.siegert\Documents\Personalakten\"

' Dokumenttyp-Konstanten
Public Const DOK_PERSONALAUSWEIS As String = "Personalausweis"
Public Const DOK_VERTRAG As String = "Arbeitsvertrag"
Public Const DOK_34A As String = "§34a Bescheinigung"
Public Const DOK_FUEHRERSCHEIN As String = "Führerschein"
Public Const DOK_DFB As String = "DFB Zertifikat"
Public Const DOK_GESUNDHEIT As String = "Gesundheitszeugnis"
Public Const DOK_SONSTIG As String = "Sonstiges"

Public Function GetPersonalaktenOrdner(MA_ID As Long) As String
    ' Gibt Pfad zum Personalakten-Ordner eines Mitarbeiters zurück
    Dim rs As DAO.Recordset
    Dim Nachname As String
    Dim Vorname As String
    Dim ordnerPfad As String
    
    Set rs = CurrentDb.OpenRecordset("SELECT Nachname, Vorname FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID)
    
    If Not rs.EOF Then
        Nachname = Nz(rs!Nachname, "")
        Vorname = Nz(rs!Vorname, "")
        ordnerPfad = PERSONALAKTEN_PFAD & MA_ID & "_" & Nachname & "_" & Vorname & "\"
    End If
    
    rs.Close
    Set rs = Nothing
    
    GetPersonalaktenOrdner = ordnerPfad
End Function

Public Sub CreatePersonalaktenOrdner(MA_ID As Long)
    ' Erstellt Ordnerstruktur für Personalakten
    Dim fso As Object
    Dim hauptOrdner As String
    Dim unterOrdner As String
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    hauptOrdner = GetPersonalaktenOrdner(MA_ID)
    
    If Not fso.FolderExists(hauptOrdner) Then
        fso.CreateFolder hauptOrdner
        
        ' Unterordner anlegen
        fso.CreateFolder hauptOrdner & "Zeitkonten\"
        fso.CreateFolder hauptOrdner & "Vertraege\"
        fso.CreateFolder hauptOrdner & "Bescheinigungen\"
        fso.CreateFolder hauptOrdner & "Sonstiges\"
        
        MsgBox "Personalakten-Ordner erstellt:" & vbCrLf & hauptOrdner, vbInformation, "Ordner erstellt"
    End If
    
    Set fso = Nothing
End Sub

Public Function UploadDokument(MA_ID As Long, Dokumenttyp As String, QuellDatei As String) As Boolean
    ' Kopiert Dokument in Personalakte und speichert Referenz in DB
    On Error GoTo ErrorHandler
    
    Dim fso As Object
    Dim zielOrdner As String
    Dim zielDatei As String
    Dim Dateiname As String
    Dim dateigroesse As Long
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Prüfe Quelldatei
    If Not fso.FileExists(QuellDatei) Then
        MsgBox "Quelldatei nicht gefunden: " & QuellDatei, vbExclamation
        UploadDokument = False
        Exit Function
    End If
    
    ' Zielordner bestimmen
    zielOrdner = GetPersonalaktenOrdner(MA_ID)
    CreatePersonalaktenOrdner MA_ID  ' Falls noch nicht vorhanden
    
    ' Unterordner je nach Dokumenttyp
    Select Case Dokumenttyp
        Case DOK_PERSONALAUSWEIS, DOK_FUEHRERSCHEIN
            zielOrdner = zielOrdner & "Bescheinigungen\"
        Case DOK_VERTRAG
            zielOrdner = zielOrdner & "Vertraege\"
        Case DOK_34A, DOK_DFB, DOK_GESUNDHEIT
            zielOrdner = zielOrdner & "Bescheinigungen\"
        Case Else
            zielOrdner = zielOrdner & "Sonstiges\"
    End Select
    
    ' Dateiname und Ziel
    Dateiname = fso.GetFileName(QuellDatei)
    zielDatei = zielOrdner & Dateiname
    
    ' Datei kopieren
    fso.CopyFile QuellDatei, zielDatei, True
    dateigroesse = fso.GetFile(zielDatei).Size
    
    ' In DB speichern
    Dim sql As String
    sql = "INSERT INTO tbl_MA_Dokumente (MA_ID, Dokumenttyp, Dateiname, Dateipfad, UploadDatum, UploadVon, Dateigroesse, IstAktiv, Versionsnummer) " & _
          "VALUES (" & MA_ID & ", '" & Dokumenttyp & "', '" & Replace(Dateiname, "'", "''") & "', '" & Replace(zielDatei, "'", "''") & "', Now(), '" & Environ("USERNAME") & "', " & dateigroesse & ", True, 1)"
    
    CurrentDb.Execute sql
    
    MsgBox "Dokument erfolgreich hochgeladen:" & vbCrLf & Dateiname, vbInformation, "Upload erfolgreich"
    UploadDokument = True
    
    Set fso = Nothing
    Exit Function
    
ErrorHandler:
    MsgBox "Fehler beim Upload: " & Err.description, vbCritical
    UploadDokument = False
    Set fso = Nothing
End Function

Public Sub OeffneDokument(DokumentID As Long)
    ' Öffnet Dokument mit Standardprogramm
    On Error GoTo ErrorHandler
    
    Dim rs As DAO.Recordset
    Dim DateiPfad As String
    
    Set rs = CurrentDb.OpenRecordset("SELECT Dateipfad FROM tbl_MA_Dokumente WHERE ID = " & DokumentID)
    
    If Not rs.EOF Then
        DateiPfad = Nz(rs!DateiPfad, "")
        
        If Len(DateiPfad) > 0 Then
            ' Prüfe ob Datei existiert
            Dim fso As Object
            Set fso = CreateObject("Scripting.FileSystemObject")
            
            If fso.FileExists(DateiPfad) Then
                Shell "cmd /c start """" """ & DateiPfad & """", vbHide
            Else
                MsgBox "Datei nicht gefunden:" & vbCrLf & DateiPfad, vbExclamation
            End If
            
            Set fso = Nothing
        End If
    End If
    
    rs.Close
    Set rs = Nothing
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler beim Öffnen: " & Err.description, vbCritical
End Sub

Public Sub OeffnePersonalaktenOrdner(MA_ID As Long)
    ' Öffnet Personalakten-Ordner im Explorer
    Dim ordnerPfad As String
    Dim fso As Object
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    ordnerPfad = GetPersonalaktenOrdner(MA_ID)
    
    If Not fso.FolderExists(ordnerPfad) Then
        CreatePersonalaktenOrdner MA_ID
    End If
    
    Shell "explorer.exe """ & ordnerPfad & """", vbNormalFocus
    Set fso = Nothing
End Sub
