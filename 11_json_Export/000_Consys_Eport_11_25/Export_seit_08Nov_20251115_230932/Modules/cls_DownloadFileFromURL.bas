Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'################################################################
'    Autor:  Thomas Möller
' Homepage:  www.team-Moeller.de
'   E-Mail:  Access@Team-Moeller.de
'################################################################

'################################################################
' Version:  1.0
'   Stand:  31.03.2011
'################################################################

'################################################################
' Quelle:
' Diese Klasse basiert auf dem Code von Jonathan Haas
' http://www.activevb.de/rubriken/klassen/internet/cdownload.html
'################################################################

'################################################################
' Geplante Erweiterungen:
'  - prüfen, ob Dateigröße übereinstimmt, sonst Fehler
'    Len(strFileData) < lgnFileSize
'  - prüfen, ob Datei bereits existiert, wenn ja
'    + Wenn OverrideExistingFile = False => Fehler
'    + sonst Datei löschen
'################################################################


'API-Deklarationen

Private Declare PtrSafe Function InternetOpen Lib "wininet.dll" Alias "InternetOpenA" _
        (ByVal lpszAgent As String, ByVal dwAccessType As Long, _
        ByVal lpszProxyName As String, ByVal lpszProxyBypass As String, _
        ByVal dwFlags As Long) As Long
        
Private Declare PtrSafe Function InternetOpenUrl Lib "wininet.dll" Alias "InternetOpenUrlA" _
        (ByVal hInternetSession As Long, ByVal lpszUrl As String, _
        ByVal lpszHeaders As String, ByVal dwHeadersLength As Long, _
        ByVal dwFlags As Long, ByVal dwContext As Long) As Long
        
Private Declare PtrSafe Function InternetCloseHandle Lib "wininet.dll" _
        (ByVal hInet As Long) As Integer
        
Private Declare PtrSafe Function InternetReadFile Lib "wininet.dll" _
        (ByVal hFile As Long, ByVal lpBuffer As String, _
        ByVal dwNumberOfBytesToRead As Long, _
        lNumberOfBytesRead As Long) As Integer
     
Private Declare PtrSafe Function HttpQueryInfo Lib "wininet.dll" Alias "HttpQueryInfoA" _
        (ByVal hHttpRequest As Long, ByVal lInfoLevel As Long, _
        ByRef sBuffer As Any, ByRef lBufferLength As Long, _
        ByRef lIndex As Long) As Boolean


'Konstanten

Private Const INTERNET_OPEN_TYPE_PRECONFIG As Long = 0
Private Const INTERNET_FLAG_EXISTING_CONNECT As Long = &H20000000
Private Const HTTP_QUERY_CONTENT_LENGTH As Long = 5


'Enums

Public Enum DownloadState
    Ready
    Connecting
    Downloading
    Canceled
    ErrorOccurred
End Enum

Public Enum DownloadError
    URLisMissing
    FilenameIsMissing
    ErrorOnConnecting
    ErrorOnFileHandle
    FileNotFound
    TargetFileAlreadyExists
    Unknown
End Enum


'Ereignisse

Public Event StartDownloading(ByVal Size As Long)
Public Event ProgressChanged(ByVal Progress As Double, ByRef Cancel As Boolean)
Public Event StateChanged(ByVal State As DownloadState)


'Members

Private mpstrURL As String
Private mpstrFileName As String
Private mpfOverrideExistingFile As Boolean
Private mplngBufferSize As Long
Private mplngError As Long


'Properties

Public Property Let url(ByVal strURL As String)

    mpstrURL = strURL

End Property

Public Property Let fileName(ByVal strFilename As String)

    mpstrFileName = strFilename

End Property

Public Property Let OverrideExistingFile(ByVal fOverrideExistingFile As Boolean)

    mpfOverrideExistingFile = fOverrideExistingFile

End Property

Public Property Let BufferSize(ByVal lngBuffersize As Long)

    mplngBufferSize = lngBuffersize

End Property

Public Property Get Error() As Long

    Error = mplngError

End Property


'Klasse verwalten

Private Sub Class_Initialize()

    'Standardwert vorbelegen
    mpfOverrideExistingFile = False
    mplngBufferSize = 1024

End Sub

Private Sub Class_Terminate()

    'Keine Aktion

End Sub


'Methoden

Public Sub DoDownload()
On Error GoTo Error_Handler
    
    'Variablen deklarieren
    Dim hInternetSession As Long
    Dim hFile As Long
    Dim lngFileSize As Long
    Dim Buffer As String
    Dim ByteAnz As Long
    Dim strFileData As String
    Dim dblProgress As Double
    Dim fCancel As Boolean

    If CheckPrerequisites = False Then Exit Sub
    
    'Internet-Session öffnen
    hInternetSession = getInternetSession
    If hInternetSession = 0 Then Exit Sub
    
    'Download-Datei öffnen
    hFile = getFileHandle(hInternetSession)
    If hFile = 0 Then Exit Sub
    
    'Dateigröße ermitteln
    lngFileSize = getFileSize(hInternetSession, hFile)
    If lngFileSize = 0 Then Exit Sub

    'Buffer vorbelegen
    Buffer = Space$(mplngBufferSize)
    
    'Daten sammeln
    RaiseEvent StartDownloading(lngFileSize)
    RaiseEvent StateChanged(Downloading)
    Do While Not fCancel
        InternetReadFile hFile, Buffer, Len(Buffer), ByteAnz
        If ByteAnz = 0 Then Exit Do
        strFileData = strFileData & Left$(Buffer, ByteAnz)
        dblProgress = Len(strFileData) / lngFileSize * 100
        RaiseEvent ProgressChanged(dblProgress, fCancel)
        If fCancel = True Then RaiseEvent StateChanged(Canceled)
    Loop
    
    'Datei speichern
    If fCancel = False Then
        Call WriteFileToDisk(strFileData)
    End If

Exit_Here:
    On Error Resume Next
    If hFile Then InternetCloseHandle hFile
    If hInternetSession Then InternetCloseHandle hInternetSession
    Exit Sub

Error_Handler:
    Select Case err.Number
        Case 0
            Resume Next
        Case Else
            mplngError = DownloadError.Unknown
            RaiseEvent StateChanged(ErrorOccurred)
            Resume Exit_Here
    End Select

End Sub


'Hilfsfunktionen

Private Function CheckPrerequisites() As Boolean

    If Len(mpstrURL) = 0 Then
        mplngError = DownloadError.URLisMissing
        RaiseEvent StateChanged(ErrorOccurred)
        Exit Function
    End If

    If Len(mpstrFileName) = 0 Then
        mplngError = DownloadError.FilenameIsMissing
        RaiseEvent StateChanged(ErrorOccurred)
        Exit Function
    End If
    
    CheckPrerequisites = True

End Function

Private Function getInternetSession() As Long
    
    Dim result As Long
    
    RaiseEvent StateChanged(Connecting)
    result = InternetOpen("Download", INTERNET_OPEN_TYPE_PRECONFIG, _
                                      vbNullString, vbNullString, 0)
    If result = 0 Then
        mplngError = DownloadError.ErrorOnConnecting
        RaiseEvent StateChanged(ErrorOccurred)
        Exit Function
    End If

    getInternetSession = result

End Function

Private Function getFileHandle(ByRef hInternetSession As Long) As Long
    
    Dim result As Long
    
    result = InternetOpenUrl(hInternetSession, mpstrURL, vbNullString, 0, _
                             INTERNET_FLAG_EXISTING_CONNECT, 0)
    If result = 0 Then
        mplngError = DownloadError.ErrorOnFileHandle
        RaiseEvent StateChanged(ErrorOccurred)
        If hInternetSession Then InternetCloseHandle hInternetSession
        Exit Function
    End If

    getFileHandle = result

End Function

Private Function getFileSize(ByRef hInternetSession As Long, ByRef hFile As Long) As Long

    Dim Buffer As String * 100
    Dim lngFileSize As Long
    
    Call HttpQueryInfo(ByVal hFile, HTTP_QUERY_CONTENT_LENGTH, ByVal Buffer, Len(Buffer), 0)
    
    lngFileSize = Val(Buffer)
    
    If lngFileSize = 0 Then
        mplngError = DownloadError.FileNotFound
        RaiseEvent StateChanged(ErrorOccurred)
        If hInternetSession Then InternetCloseHandle hInternetSession
        If hFile Then InternetCloseHandle hFile
        Exit Function
    End If

    getFileSize = lngFileSize

End Function

Private Sub WriteFileToDisk(ByVal strFileData As String)

    Dim DatNum As Integer

    ' evtl vorhandene Datei löschen
    Call VorhandeneDateiLoeschen
    
    ' Datei schreiben
    DatNum = FreeFile
    Open mpstrFileName For Output As #DatNum
    Print #DatNum, strFileData;
    Close #DatNum
    
    RaiseEvent StateChanged(Ready)

End Sub

Private Sub VorhandeneDateiLoeschen()

    On Error Resume Next
    
    Kill mpstrFileName

End Sub