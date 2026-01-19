Option Compare Database
Option Explicit

Function MDBSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Access Datenbank (*.mdb) suchen") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
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
      .Filter3Text = "MD*-Dateien (*.md*)"
      .Filter3Suffix = "*.md*"
      .Filter4Text = "Alle Dateien (*.*)"
      .Filter4Suffix = "*.*"
'      .Filter4Text = "Ascii-Dateien (*.asc)"
'      .Filter4Suffix = "*.asc"
'      .Filter5Text = "Text-Dateien (*.txt)"
'      .Filter5Suffix = "*.txt"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
MDBSuch = fd.filename

End Function


Function MDFSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "search SQL Server database (*.mdf)") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "MDF-Dateien (*.mdf)"
      .Filter1Suffix = "*.mdf"
      .Filter2Text = "Alle Dateien (*.*)"
      .Filter2Suffix = "*.*"
'      .Filter3Text = "MD*-Dateien (*.md*)"
'      .Filter3Suffix = "*.md*"
'      .Filter4Text = "Ascii-Dateien (*.asc)"
'      .Filter4Suffix = "*.asc"
'      .Filter5Text = "Text-Dateien (*.txt)"
'      .Filter5Suffix = "*.txt"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
MDFSuch = fd.filename

End Function


Function DocSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "WinWord Document (*.doc) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Doc- und Dot-Dateien (*.do??)"
      .Filter1Suffix = "*.do??"
      .Filter2Text = "RTF-Dateien (*.rtf)"
      .Filter2Suffix = "*.rtf"
      .Filter3Text = "Ascii-Dateien (*.asc)"
      .Filter3Suffix = "*.asc"
      .Filter4Text = "Text-Dateien (*.txt)"
      .Filter4Suffix = "*.txt"
      .Filter5Text = "Alle Dateien (*.*)"
      .Filter5Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
DocSuch = fd.filename

End Function

Function TXTSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Textdatei (*.txt) suchen") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Text-Dateien (*.txt)"
      .Filter1Suffix = "*.txt"
      .Filter2Text = "Ascii-Dateien (*.asc)"
      .Filter2Suffix = "*.asc"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"
'      .Filter4Text = "MDB-Dateien (*.mdb)"
'      .Filter4Suffix = "*.mdb"
'      .Filter5Text = "MD*-Dateien (*.md*)"
'      .Filter5Suffix = "*.md*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
TXTSuch = fd.filename

End Function


Function XLSSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Exceldatei (*.txt) suchen") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
      .DefaultExt = "XLS"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Excel-Dateien (*.xl*)"
      .Filter1Suffix = "*.xl*"
      .Filter2Text = "Excel-Dateien (*.xls)"
      .Filter2Suffix = "*.xls"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"
'      .Filter4Text = "MDB-Dateien (*.mdb)"
'      .Filter4Suffix = "*.mdb"
'      .Filter5Text = "MD*-Dateien (*.md*)"
'      .Filter5Suffix = "*.md*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
XLSSuch = fd.filename

End Function



Function WavSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Wav Datei (*.wav) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Wav-Dateien (*.wav)"
      .Filter1Suffix = "*.wav"
      .Filter2Text = "Alle Dateien (*.*)"
      .Filter2Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
WavSuch = fd.filename

End Function

Function AlleSuch(Optional ByVal startdir As String = PfadPlanungAktuell, Optional ByVal StBeschriftung As String = "Datei (*.*) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Alle Dateien (*.*)"
      .Filter1Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
AlleSuch = fd.filename

End Function



Function DllSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Wav Datei (*.wav) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
'      .hWnd = Me.hWnd
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Dll-Dateien (*.dll)"
      .Filter1Suffix = "*.dll"
      .Filter2Text = "Ocx-Dateien (*.ocx)"
      .Filter2Suffix = "*.ocx"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
DllSuch = fd.filename

End Function



Function BMPSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "BMP Datei (*.bmp) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "BMP-Dateien (*.bmp)"
      .Filter1Suffix = "*.bmp"
      .Filter2Text = "JPG-Dateien (*.jpg)"
      .Filter2Suffix = "*.jpg"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
BMPSuch = fd.filename

End Function


Function JPGSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Bild Datei (*.jpg) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "JPG-Dateien (*.jpg)"
      .Filter1Suffix = "*.jpg"
      .Filter2Text = "BMP-Dateien (*.bmp)"
      .Filter2Suffix = "*.bmp"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
JPGSuch = fd.filename

End Function




Function Folder_Such(Optional txtDialogTitle As String = "") As String
On Error GoTo Error_btnFolder_Click

    Dim fd As New FileDialog
    
    ' Dialogtitel kann man setzen
    If txtDialogTitle <> "" Then
        fd.DialogTitle = txtDialogTitle
    End If

    ' hWndOwner des FileDialogs setzen, damit wird der Dialog auf das aktuelle Formular
    ' ausgerichtet und klebt nicht in der linken oberen Ecke. Funktioniert aus
    ' unerfindlichen Gründen nur, wenn das aktuelle Formular (Me) Popup ist oder mit
    ' acDialog geöffnet wurde. Sonst ist es wenigstens unschädlich.
'    If Me!chkHWnd1.Value = True Then
        fd.hwnd = Application.hWndAccessApp
'        fd.hwnd = Me.hwnd
'    End If
    
    ' es wird nichts geöffnet, ist nur ein Beispiel
    fd.ShowFolder
    If fd.filename = "" Then
'        Folder_Such = "(keins)"
        Folder_Such = ""
    Else
        Folder_Such = fd.filename
    End If
    
    ' man könnte auch schreiben
    ' Me!Datei = fd.ShowFolder
    ', da kriegt man aber das '(keins)' nicht angezeigt

Exit_btnFolder_Click:
    Exit Function
Error_btnFolder_Click:
    MsgBox Err.Number & ": " & Err.description, , "Folder_Such"
    Resume Exit_btnFolder_Click
End Function


Function XLSSuch_Mehrfach(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "search Excel file (*.xls)") As String
On Error GoTo XLSSuch_Mehrfach_Error
' weitere Erläuterungen im Code des Klassenmoduls

'Behelfsweise zum kompilieren, muss aber als Global definiert werden
Dim Global_MultiAuswahl() As String

'Public Global_MultiAuswahl() As String


' Konstanten zum rumspielen mit .Flags, sind im normalen Betrieb
' selten oder nicht nötig
 Const OFN_FILEMUSTEXIST = &H1000
 Const OFN_PATHMUSTEXIST = &H800
 Const OFN_HIDEREADONLY = &H4
 Const OFN_READONLY = &H1
 Const OFN_OVERWRITEPROMPT = &H2
 Const OFN_ALLOWMULTISELECT = &H200
 Const OFN_EXPLORER = &H80000

' ausführliches Beispiel ohne das ganze Theater hier unten, siehe auch Klassenmodul
'   Dim fd As New FileDialog
'   Dim Dateiname as String
'
'   With fd
'      .DialogTitle = "Mein Titel"
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'      .DefaultDir = "c:\"
'      .DefaultFileName = "setuplog.txt"
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY
'      .Filter1Text = "Text-Dateien"
'      .Filter1Suffix = "*.txt"
'      .Filter2Text = "Ascii-Dateien"
'      .Filter2Suffix = "*.asc"
'      ... bis Filter5Text/Suffix ...
'
'      .ShowOpen                          ' oder .ShowSave
'
'      if fd.FileName = "" then exit sub   ' Abbruch durch Benutzer
'      DateiName = fd.FileName
'   End With
   
    Dim fd As New FileDialog
    Dim i As Integer
    Dim FocusAufAuswahl As Boolean
        
    ReDim Global_MultiAuswahl(0)
        
'    Me!btnNextFile.Visible = False
'    Me!txtFileCount.Visible = False
'    Me!txtFileNr.Visible = False
        
    fd.DialogTitle = StBeschriftung
        
    ' evtl. einiges vorbesetzen, ist aber nicht zwingend. Hier werden die
    ' Eingaben aus dem Formular verarbeitet, sofern was drin steht
    
    ' Default-Filename, wird nur angezeigt. Die Datei (sofern vorhanden)
    ' wird nicht markiert. Bewirkt noch keine Filterung.
    'If Nz(Me!strDefFileName) <> "" Then fd.DefaultFileName = Me!strDefFileName ' sonst: NULL
    
    ' Default-Dateiendung, wird beim Speichern angehängt, wenn
    ' keine andere angegeben wurde (z.B. 'txt')
    ' HIER VÖLLIG SINNLOS (öffnen!), aber unschädlich
    'If Nz(Me!strDefExt) <> "" Then fd.DefaultExt = Me!strDefExt ' sonst: NULL
    
    ' Verzeichnis, bei dem gestartet wird
'    If Nz(Me!strDefDir) <> "" Then fd.DefaultDir = Me!strDefDir ' sonst: CurDir
    fd.DefaultDir = startdir
    
'    ' Datei-Filter, es gehört immer Suffix/Text zusammen
'    If Nz(Me!strFilterSuffix) <> "" Then
'        fd.Filter1Suffix = Me!strFilterSuffix
'        If Nz(Me!strFilterText) = "" Then
'            fd.Filter1Text = "Doofkopp: Wie heißen " & Me!strFilterSuffix & "-Dateien?"
'        Else
'            fd.Filter1Text = Me!strFilterText
'        End If
'
'        ' noch einen Filter für ALLE Dateien hinzufügen
'        fd.Filter2Suffix = "*.*"
'        fd.Filter2Text = "Alle Dateien"
'    End If
            
      fd.Filter1Text = "Excel-Dateien (*.xls?)"
      fd.Filter1Suffix = "*.xls?"
      fd.Filter2Text = "Excel-Dateien (*.xl*)"
      fd.Filter2Suffix = "*.xl*"
      fd.Filter3Text = "Alle Dateien (*.*)"
      fd.Filter3Suffix = "*.*"
            
    ' MultiSelect setzen wenn ausgewählt. Die maximale Länge des zurückgegeben
    ' Strings (und damit die etwaige Anzahl der zurückgegebenen Dateien) kann
    ' man über LEN_FILENAME_MULTISELECT im Klassenmodul einstellen (derzeit 10000)
'    If Me!chkMultiSelect.Value = True Then
        fd.MultiSelect = True   ' sonst: False
'    End If
    
    ' wegen Kompatibilität zum OCX kann man hier einstellen, daß bei Selektion
    ' mehrerer Dateien die einzelnen Dateinamen nicht über .GetNextFile geholt
    ' werden sondern in der Originalform ankommen.
'    If Me!chkMultiSelectOCXCompatible.Value = True Then
'        fd.MultiSelectOCXCompatible = True ' sonst: False
'        FocusAufAuswahl = True ' der String mit vbcharnull wird sonst nicht angezeigt
'    End If
    fd.MultiSelectOCXCompatible = False
    
    ' hWndOwner des FileDialogs setzen, damit wird der Dialog auf das aktuelle Formular
    ' ausgerichtet und klebt nicht in der linken oberen Ecke. Funktioniert aus
    ' unerfindlichen Gründen nur, wenn das aktuelle Formular (Me) Popup ist oder mit
    ' acDialog geöffnet wurde. Sonst ist es wenigstens unschädlich.
'    If Me!chkHWnd.Value = True Then
'        fd.hWnd = Me.hWnd
'    End If
    
    
    ' es wird nichts geöffnet, ist nur ein Beispiel
    fd.ShowOpen
'    If fd.Filename = "" Then
'        Me!Datei = "(keine)"
'    Else
'        Me!Datei = fd.Filename
'    End If
    
    ' man könnte auch schreiben
    ' Me!Datei = fd.ShowOpen
    ', da kriegt man aber das '(keine)' nicht angezeigt
    
'    If FocusAufAuswahl Then Me!Datei.SetFocus ' zur Anzeige des Strings mit
                                              ' chr(0) bei .MultiSelectOCXCompatible
    
    ' für Multiselect gehts weiter: mit dem eingeblendeten Button kriegt
    ' man jeweils die nächste Datei angezeigt, wenn mehr als eine ausgewählt wurde
    
    If fd.FileCount > 1 Then
'        Me!btnNextFile.Visible = True
'        Me!txtFileCount.Visible = True
'        Me!txtFileNr.Visible = True
'
'        If Me!chkMultiSelectOCXCompatible.Value = False Then
'            Me!txtFileNr.Visible = True
'            Me!txtFileNr.Caption = "Datei 1"
'            Me!txtFileCount.Caption = "von " & fd.FileCount
'        Else
'            Me!txtFileCount.Caption = "(gesamt: " & fd.FileCount & ")"
'            Me!txtFileNr.Visible = False
'        End If

        ' da das Objekt fd geschlossen wird, wenn ich diese Sub verlasse,
        ' muß ich mir hier die gewählten Dateien schnell merken.
        ' Wenn sie direkt verarbeitet werden sollen, z.B. so:
        
        'MeineDatei = fd.GetNextFile
        'Do Until MeineDatei = ""
            '... irgendwas mit dem Dateinamen machen
        'Loop
        
        ' kann man sich das auch sparen
        
        ReDim Global_MultiAuswahl(0 To fd.FileCount - 1)
        
        ' Achtung: .GetNextFile liefert zwar die nächste Datei,
        ' aber eben nur einmal. Deswegen Ergebnis immer gleich merken.
        ' Terminierung bei fd.GetNextFile="" oder bei fd.FileCount
        
        For i = 1 To fd.FileCount - 1 ' die erste Datei haben wir oben schon angezeigt
            Global_MultiAuswahl(i) = fd.GetNextFile
        Next
        
'        AuswIdx = 1 ' Anzeige mit zweiter Datei beginnen, die erste steht schon da

    End If
    If fd.FileCount > 0 Then
        Global_MultiAuswahl(0) = fd.filename
    End If
    
XLSSuch_Mehrfach_End:
    Exit Function
    
XLSSuch_Mehrfach_Error:
    MsgBox Err.description, , "XLSSuch_Mehrfach"
    On Error GoTo 0
    Resume XLSSuch_Mehrfach_End
End Function


Function SavefileSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "search filename for output") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
'      .Flags = OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Alle Dateien (*.*)"
      .Filter1Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
'      .ShowOpen                          ' oder .ShowSave
      .ShowSave
   End With
   
SavefileSuch = fd.filename

End Function

Function XLSSuchNeu(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Exceldatei (*.txt) suchen") As String

Dim fd As New FileDialog
         
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
   
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
      .DefaultExt = "XLS"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
      .Flags = OFN_OVERWRITEPROMPT Or OFN_PATHMUSTEXIST

' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Excel-Dateien (*.xls)"
      .Filter1Suffix = "*.xls"
      .Filter2Text = "Excel-Dateien (*.xl*)"
      .Filter2Suffix = "*.xl*"
      .Filter3Text = "Alle Dateien (*.*)"
      .Filter3Suffix = "*.*"
'      .Filter4Text = "MDB-Dateien (*.mdb)"
'      .Filter4Suffix = "*.mdb"
'      .Filter5Text = "MD*-Dateien (*.md*)"
'      .Filter5Suffix = "*.md*"

'      ... bis max. Filter5Text/Suffix ...
'
      '.ShowOpen
      '' oder
      .ShowSave
   
   End With
   
XLSSuchNeu = fd.filename

End Function