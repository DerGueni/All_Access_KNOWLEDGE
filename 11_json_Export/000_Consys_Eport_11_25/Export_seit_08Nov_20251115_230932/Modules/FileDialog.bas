Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
' 21.05.2010
' erweitert von Gunter Avenius, http://www.avenius.com
'
' Hinzugekommen bzw. Änderungen:
'
' - Im Folder-Dialog kann der Button "Neuer Ordner erstellen" angezeigt werden.
' - Der FileDialog funktioniert auch unter Win7 wenn mehr als ein Filter angegeben wird.
' - Klassenmodul kompatibel ab A97 bis A2010 x64.
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'This code was originally written by Karsten Pries.
'It is not to be altered or distributed, except as part of an application.
'You are free to use it in any application, provided the copyright notice is left unchanged.
'
'ShowFolder Code courtesy of Terry Kreft, please see original at http://www.mvps.org/access
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' Für die Verwendung ausserhalb von Access (Excel, Word, VB, ...) alle 3 Zeilen mit
' "hWndAccessApp" auskommentieren, sonst Laufzeitfehler.
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' Wrapper für Win-API:
'   "GetOpenFileNameA"
'   "GetSaveFileNameA"
'
' Aufruf des CommonDialog von Windows zur Auswahl einer Datei (öffnen/speichern)
' ohne Verwendung des OCX
'
' ********************************************************************************
' Verwendung (noch mehr dazu im Demoformular):
'
' Sub xx()
'  Dim fd As New FileDialog
'  Dim Dateiname as String

' kurze Version:
'    Dateiname = fd.ShowOpen           ' oder .ShowSave
'    if Dateiname = "" then exit sub   ' Abbruch durch Benutzer
'    .....
'
' ohne extra Variable:
'    fd.ShowOpen                         ' oder .ShowSave
'    if fd.FileName = "" then exit sub   ' Abbruch durch Benutzer
'    sonst z.B.  Kill fd.FileName        ' ausgewählte Datei löschen
'    .....
'
' ausführlich:
'
'   With fd
'      .DialogTitle = "Mein Titel"
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'      .DefaultDir = "c:\"
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
'      .MultiSelect = True
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
' End Sub
'
'************************************************************************************
'
' Bemerkung: Die Property .Filter ist für die Abwärtskompatibilität und für Leute,
'            die wissen was sie tun. Alle anderen sollen FilterXText/Suffix benutzen.
'            Näheres im Code zu .Filter.
'************************************************************************************
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' Bugs/Wünsche/Vorschläge bitte an pries@gmx.de
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Option Explicit

' Konstanten
Private Const LEN_FILENAME_NORMAL As Integer = 512     'Ist der zurückgegebene Name zu lang,
Private Const LEN_FILENAME_MULTISELECT As Long = 2000  'gibts beim API-Aufruf einen Fehler und .FileName liefert ""

Private Const OFN_FILEMUSTEXIST = &H1000
Private Const OFN_PATHMUSTEXIST = &H800
Private Const OFN_HIDEREADONLY = &H4
Private Const OFN_READONLY = &H1
Private Const OFN_OVERWRITEPROMPT = &H2
Private Const OFN_ALLOWMULTISELECT = &H200
Private Const OFN_EXPLORER = &H80000

' Konstanten für Button "Neuer Ordner"
'# 12.05.2010#
Private Const BIF_NONEWFOLDERBUTTON = &H200
Private Const BIF_NEWDIALOGSTYLE = &H40
   
Private Const BIF_RETURNONLYFSDIRS = &H1


' interne Variablen, über Properties gesetzt/gelesen:
Private strDialogTitle As String    ' Dialogtitel
Private strFilter As String         ' Filter kann man sowohl wie gehabt definieren als
                                    ' auch über die folgenden Paare Text/Suffix
Private lngFlags As Long            ' Flags
Private strDefaultExt As String     ' Standard-Endung
Private strInitDir As String        ' Start-Verzeichnis
Private blnMultiSelect As Boolean   ' Multiselect erlauben Ja/Nein
Private intFileCount As Integer     ' Anzahl Dateien bei MultiSelect
Private intExtCount As Integer      ' Anzahl der Extensions
Private blnCreateFolder As Boolean  ' Button "Neuer Ordner"
                                    ' optionale Filterparameter, ersparen die Mühe des Zusammenbaus
Private strFilterText(5) As String  ' z.B. "Text-Dateien"
Private strFilterSuffix(5) As String ' z.B. "*.txt"
#If Win64 Then
    Private lngHWnd As LongPtr
#Else
    Private lngHWnd As Long             ' Handle Window
#End If
' bei Multiselect kompatibel zum OCX, d.h. bei .Filename wird String der
' Form "Pfad & vbnullchar & Datei1 & vbnullchar & Datei2 & ..." zurückgegeben
Private blnKompatibel As Boolean

' interne Variablen, von Funktionen benutzt
Private strDateiname As String      ' zurückgegebener Dateiname
Private cnstNull As String * 1      ' NULL-String
Private strDefaultFileNameSave As String    ' Default merken, falls bei Multiselect
                                            ' Stringlänge erhöht werden muß
Private intLenFileName As Integer   ' max. Länge des zurückgegebenen Strings, entweder LEN_FILENAME_NORMAL
                                    ' oder LEN_FILENAME_MULTISELECT. Ist der zurückgegebene Name zu lang,
                                    ' gibts beim API-Aufruf einen Fehler und .FileName liefert ""
#If Win64 Then
    ' Typen
    Private Type TOpenFileName
        lStructSize As LongPtr           ' Länge des Datentyps OPENFILENAME
        hOwner As LongPtr              ' Fenster, unter dem Dialog erscheint
        hInstance As LongPtr              ' nicht verwendet
        lpstrFilter As String          ' Zeichenkette von Anzeigenfiltern im Dialog
        lpstrCustomFilter As String    ' nicht verwendet
        nMaxCustFilter As Long         ' nicht verwendet
        nFilterIndex As Long           ' 1 zum Benutzen des ersten Filters, 2 zum zweiten usw.
        lpstrFile As String            ' String, der ausgewählte Datei bekommt
        nMaxFile As Long               ' Länge von lpstrFile
        lpstrFileTitle As String       ' Dateiname ohne Pfad (kann auch mit VBA ermittelt werden, also weglassen)
        nMaxFileTitle As LongPtr          ' nicht verwendet
        lpstrInitialDir As String      ' Ordner, in dem Dialog sich zuerst befinden soll
        lpstrTitle As String           ' Titel des eigentlichen Dialogfensters
        Flags As LongPtr                  ' verschiedene Optionen, die durch Konstanten eingestellt werden
        nFileOffset As Integer         ' nicht verwendet
        nFileExtension As Integer      ' nicht verwendet
        lpstrDefExt As String          ' Erweiterung, die genommen wird, wenn keine eingegeben wurde
        lCustData As LongPtr              ' nicht verwendet
        lpfnHook As LongPtr               ' nicht verwendet
        lpTemplateName As LongPtr
    End Type
    
    Private Type BROWSEINFO
      hOwner As LongPtr
      pidlRoot As Long
      pszDisplayName As String
      lpszTitle As String
      ulFlags As Long
      lpfn As LongPtr
      lParam As LongPtr
      iImage As Long
    End Type
    
    
    Private Declare PtrSafe Function APT_GetOpenFileName Lib "comdlg32.dll" Alias _
            "GetOpenFileNameA" (pOpenfilename As TOpenFileName) As Long
    Private Declare PtrSafe Function APT_GetSaveFileName Lib "comdlg32.dll" Alias _
            "GetSaveFileNameA" (pOpenfilename As TOpenFileName) As Long
    Private Declare PtrSafe Function SHBrowseForFolder Lib "SHELL32.DLL" Alias _
            "SHBrowseForFolderA" (lpBrowseInfo As BROWSEINFO) As Long
    Private Declare PtrSafe Function SHGetPathFromIDList Lib "SHELL32.DLL" Alias _
            "SHGetPathFromIDListA" (ByVal pidl As LongPtr, ByVal pszPath As String) As Long
        
    
#Else

    ' Typen
    Private Type TOpenFileName
        lStructSize As Long            ' Länge des Datentyps OPENFILENAME
        hOwner    As Long              ' Fenster, unter dem Dialog erscheint
        hInstance As Long              ' nicht verwendet
        lpstrFilter As String          ' Zeichenkette von Anzeigenfiltern im Dialog
        lpstrCustomFilter As String    ' nicht verwendet
        nMaxCustFilter As Long         ' nicht verwendet
        nFilterIndex As Long           ' 1 zum Benutzen des ersten Filters, 2 zum zweiten usw.
        lpstrFile As String            ' String, der ausgewählte Datei bekommt
        nMaxFile As Long               ' Länge von lpstrFile
        lpstrFileTitle As String       ' Dateiname ohne Pfad (kann auch mit VBA ermittelt werden, also weglassen)
        nMaxFileTitle As Long          ' nicht verwendet
        lpstrInitialDir As String      ' Ordner, in dem Dialog sich zuerst befinden soll
        lpstrTitle As String           ' Titel des eigentlichen Dialogfensters
        Flags As Long                  ' verschiedene Optionen, die durch Konstanten eingestellt werden
        nFileOffset As Integer         ' nicht verwendet
        nFileExtension As Integer      ' nicht verwendet
        lpstrDefExt As String          ' Erweiterung, die genommen wird, wenn keine eingegeben wurde
        lCustData As Long              ' nicht verwendet
        lpfnHook As Long               ' nicht verwendet
        lpTemplateName As Long         ' nicht verwendet
    End Type
    
    Private Type BROWSEINFO
      hOwner As Long
      pidlRoot As Long
      pszDisplayName As String
      lpszTitle As String
      ulFlags As Long
      lpfn As Long
      lParam As Long
      iImage As Long
    End Type
    
    
    Private Declare PtrSafe Function APT_GetOpenFileName Lib "comdlg32.dll" Alias _
            "GetOpenFileNameA" (pOpenfilename As TOpenFileName) As Long
    Private Declare PtrSafe Function APT_GetSaveFileName Lib "comdlg32.dll" Alias _
            "GetSaveFileNameA" (pOpenfilename As TOpenFileName) As Long
    Private Declare PtrSafe Function SHBrowseForFolder Lib "SHELL32.DLL" Alias _
            "SHBrowseForFolderA" (lpBrowseInfo As BROWSEINFO) As Long
    Private Declare PtrSafe Function SHGetPathFromIDList Lib "SHELL32.DLL" Alias _
            "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal pszPath As String) As Long
#End If
  
#If Win64 Then
    Property Let hwnd(lngAktHWnd As Long)
        lngHWnd = CLngPtr(lngAktHWnd)
    End Property
#Else
    Property Let hwnd(lngAktHWnd As Long)
        lngHWnd = lngAktHWnd
    End Property
#End If

Private Function CountFiles(strSelection As String) As Integer
On Error GoTo Error_CountFiles
' zählen der selektierten Dateien

    Dim idx As Integer, idxold As Integer
    Dim Count As Integer
    
    idx = InStr(1, strSelection, cnstNull)
    
    Do Until idx = idxold
        idxold = idx + 1
        Count = Count + 1
        idx = InStr(idxold, strSelection, cnstNull)
    Loop

    CountFiles = Count

Exit_CountFiles:
    Exit Function
Error_CountFiles:
    MsgBox err.description, , "Exit_CountFiles"
    Resume Exit_CountFiles
End Function

Property Let DefaultDir(strAktDefaultDir As String)
    strInitDir = strAktDefaultDir & cnstNull
End Property

Property Get FileCount() As Integer
' Anzahl ausgewählter Dateien (she. auch .MultiSelect)
    FileCount = intFileCount
End Property
'

Property Get ExtCount() As Integer
' Anzahl der Extension
    ExtCount = intExtCount
End Property


Property Get GetNextFile() As String
    GetNextFile = ParseAuswahl()
End Property

Property Let InitDir(strAktDefaultDir As String)
    Me.DefaultDir = strAktDefaultDir
End Property

Property Let DefaultFileName(strAktDefaultFileName As String)
    strDefaultFileNameSave = strAktDefaultFileName
End Property

Private Function BuildFilter() As String
' bastelt bei Aufruf Open/Save aus den .FilterXText/Suffix und .Filter
' einen gültigen Filterstring
On Error GoTo Error_BuildFilter

   Dim myFilter As String
   Dim i As Integer
   
   ' wenn .FilterXText/Suffix gesetzt dann String zusammenbauen
   For i = 1 To UBound(strFilterText)
      If strFilterText(i) <> "" And strFilterSuffix(i) <> "" Then
         myFilter = myFilter & strFilterText(i) & cnstNull & strFilterSuffix(i) & cnstNull
         intExtCount = intExtCount + 1
      End If
   Next
   
   If strFilter <> "" Then  ' .Filter wurde manuell gesetzt
      ' cut trailing nulls
      Do While Right(strFilter, 1) = cnstNull
         strFilter = Left(strFilter, Len(strFilter) - 1)
      Loop
      
      myFilter = strFilter & cnstNull & myFilter
   End If
   
   If myFilter = "" Then myFilter = "Alle Dateien" & cnstNull & "*.*"
   
   myFilter = myFilter & cnstNull & cnstNull
   
   BuildFilter = myFilter
   
Exit_BuildFilter:
    Exit Function
Error_BuildFilter:
    MsgBox err.description, , "Exit_BuildFilter"
    Resume Exit_BuildFilter
End Function

Private Sub CheckFlags(Intention As String)

   ' wenn die Flags schon manuell gesetzt wurden: nix tun,
   ' außer wenn explizit Multiselect gewollt wird
   If lngFlags <> 0 Then
       If blnMultiSelect Then lngFlags = lngFlags Or OFN_ALLOWMULTISELECT Or OFN_EXPLORER
       Exit Sub
   End If
   
   ' sonst abhängig von Intention:
   Select Case Intention
      Case "Open"
         lngFlags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY
         If blnMultiSelect Then lngFlags = lngFlags Or OFN_ALLOWMULTISELECT Or OFN_EXPLORER
      Case "Save"
         lngFlags = OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_OVERWRITEPROMPT
      Case Else
         MsgBox "Unbekannte Intention: " & Intention, vbOKOnly + vbCritical, "CheckFlags"
   End Select
End Sub

Property Let ShowNewFolderButton(blnAktCreateFolder As Boolean)
    blnCreateFolder = blnAktCreateFolder
End Property

Property Let DefaultExt(strAktDefaultExt As String)
   strDefaultExt = strAktDefaultExt & cnstNull
End Property


Property Let DialogTitle(title As String)
   strDialogTitle = title & cnstNull
End Property


Property Get fileName() As String
   fileName = strDateiname
End Property

Property Let filter(aktFilter As String)
' wer dieses Property benutzt muß wissen was er macht, siehe für sichere Filterstrings
' die Properties FilterXText/FilterXSuffix
   
   ' Korrekte Filterstrings haben z.B. die Form
   ' "Alle Dateien" & cnstNull & "*.*" & cnstNull & cnstNull
   
   ' Korrekte Filter enden mit zweimal cnstnull
   If Len(aktFilter) >= 2 And Right(aktFilter, 2) = cnstNull & cnstNull Then
      strFilter = aktFilter
   Else
      strFilter = aktFilter & cnstNull & cnstNull
   End If
   
End Property

Property Let Filter1Text(FilterText As String)
   strFilterText(1) = FilterText
End Property
Property Let Filter2Text(FilterText As String)
   strFilterText(2) = FilterText
End Property
Property Let Filter3Text(FilterText As String)
   strFilterText(3) = FilterText
End Property

Property Let Filter4Text(FilterText As String)
   strFilterText(4) = FilterText
End Property

Property Let Filter5Text(FilterText As String)
   strFilterText(5) = FilterText
End Property

Property Let Filter1Suffix(FilterSuffix As String)
   strFilterSuffix(1) = FilterSuffix
End Property

Property Let Filter2Suffix(FilterSuffix As String)
   strFilterSuffix(2) = FilterSuffix
End Property
Property Let Filter3Suffix(FilterSuffix As String)
   strFilterSuffix(3) = FilterSuffix
End Property
Property Let Filter4Suffix(FilterSuffix As String)
   strFilterSuffix(4) = FilterSuffix
End Property
Property Let Filter5Suffix(FilterSuffix As String)
   strFilterSuffix(5) = FilterSuffix
End Property

Property Let Flags(lngAktFlags As Long)
   lngFlags = lngAktFlags
End Property

Property Let MultiSelect(blnAktMultiSelect As Boolean)
    blnMultiSelect = blnAktMultiSelect
    intLenFileName = LEN_FILENAME_MULTISELECT
End Property


Property Let MultiSelectOCXCompatible(blnAktKompatibel As Boolean)
' wenn True dann Rückgabe der selektierten Dateien bei .FileName in der Form
' "Pfad & vbnullchar & Datei1 & vbnullchar & Datei2 & ..." und
' nicht über .GetNextFile, kompatibel zum OCX
    
    blnKompatibel = blnAktKompatibel
    
    ' vorsichtshalber auch gleich noch .MultiSelect auf True setzen
    If blnAktKompatibel Then
        blnMultiSelect = True
        intLenFileName = LEN_FILENAME_MULTISELECT
    End If

End Property

Private Function ParseAuswahl(Optional strAuswahl As String = "", Optional blnInitial As Boolean = False)
On Error GoTo Error_ParseAuswahl
' wird nur für Multiselect verwendet. Mit blnInitial=True werden die
' statischen Variablen initialisiert. Beim ersten Aufruf (blnInitial=True)
' wird der Name der ersten Datei zurückgeliefert, bei jedem folgenden
' Aufruf ohne Argumente der Name der nächsten. Der Initial-Aufruf erfolgt
' aus .ShowOpen, weitere Aufrufe von außen über .GetNextFile, bis ein Leerstring
' ("") zurückgeliefert wird.
'
' strAuswahl hat folgende Form (nur bei Initial):
' mehrere Dateien selektiert: voller Pfad & chr(0) & Datei1 & chr(0) & datei2 & ....
' nur eine Datei selektiert: Voller Dateiname inkl. Pfad & chr(0) & chr(0) & ...
    
    Static strPfadName As String
    Static strDateien As String
    Dim Dummy As String
    Dim Retval As String
    Dim idx As Integer
    
    If blnInitial Then
        strDateien = strAuswahl
        
        idx = InStr(strDateien, cnstNull) ' erste 0
        
        If Asc(Mid(strDateien, idx + 1, 1)) = 0 Then
        ' nach der ersten 0 kommt gleich noch eine weitere, d.h. trotz Multiselect
        ' wurde nur eine Datei ausgewählt
            Retval = Left$(strDateien, idx - 1)
            intFileCount = 1
        
        Else ' als erstes kommt der Pfadname
            strPfadName = Left$(strDateien, idx - 1)
            ' bei c:\ wird der Backslash mitgeliefert, bei c:\windows nicht. Alle lieben Microsoft.
            If Right$(strPfadName, 1) = "\" Then strPfadName = Left$(strPfadName, Len(strPfadName) - 1)
            
            strDateien = Mid$(strDateien, idx + 1)
            
            intFileCount = CountFiles(strDateien)
            
            idx = InStr(strDateien, cnstNull)
            Dummy = Left$(strDateien, idx - 1)
            strDateien = Mid$(strDateien, idx + 1)
            
            Retval = strPfadName & "\" & Dummy
            
        End If
        
    
    Else    ' Folgeaufruf
    
        idx = InStr(strDateien, cnstNull)
        If idx > 1 Then
            Dummy = Left$(strDateien, idx - 1)
            strDateien = Mid$(strDateien, idx + 1)
            Retval = strPfadName & "\" & Dummy
        Else
            Retval = ""
        End If
    End If
    
    ParseAuswahl = Retval

Exit_ParseAuswahl:
    Exit Function
Error_ParseAuswahl:
    MsgBox err.description, , "Exit_ParseAuswahl"
    Resume Exit_ParseAuswahl
End Function

'This code was originally written by Terry Kreft.
'It is not to be altered or distributed,
'except as part of an application.
'You are free to use it in any application,
'provided the copyright notice is left unchanged.
'
'Code courtesy of
'Terry Kreft
Function ShowFolder() As String
On Error GoTo Error_ShowFolder
  
    Dim x As Long, bi As BROWSEINFO, dwIList As Long
    Dim szPath As String
  
    With bi
        If lngHWnd = 0 Then
             .hOwner = Application.hWndAccessApp
        Else
             .hOwner = lngHWnd
        End If
        .lpszTitle = strDialogTitle
        '.ulFlags = BIF_RETURNONLYFSDIRS
        'New Folder Button
        .ulFlags = BIF_RETURNONLYFSDIRS + BIF_NEWDIALOGSTYLE _
        + IIf(blnCreateFolder, 0, BIF_NONEWFOLDERBUTTON)
    End With
    
    dwIList = SHBrowseForFolder(bi)
    szPath = Space$(512)
    x = SHGetPathFromIDList(ByVal dwIList, ByVal szPath)
    
    If x Then
        strDateiname = Left$(szPath, InStr(szPath, cnstNull) - 1) ' restliche NUL-Werte abschneiden
        ShowFolder = strDateiname
    Else
        strDateiname = ""
        ShowFolder = ""
    End If

Exit_ShowFolder:
    Exit Function
Error_ShowFolder:
    MsgBox err.Number & ": " & err.description, , "ShowFolder"
    Resume Exit_ShowFolder
End Function

Function ShowOpen() As String
On Error GoTo Error_ShowOpen

    Dim myFilter As String
    Dim OpenDlg As TOpenFileName
    
    myFilter = BuildFilter()
    Call CheckFlags("Open")
    
    If strDialogTitle = "" Then
       strDialogTitle = "Datei öffnen" & cnstNull
    End If
    
    ' String für Default-Dateinamen setzen, Länge kann variieren (Normal/Multiselect), deswegen hier
    strDateiname = strDefaultFileNameSave & String$(intLenFileName - Len(strDefaultFileNameSave), 0)
    
    With OpenDlg
       .lStructSize = Len(OpenDlg)
        If lngHWnd = 0 Then
             .hOwner = Application.hWndAccessApp
        Else
             .hOwner = lngHWnd
        End If
       .lpstrFilter = myFilter
       .nFilterIndex = 1
       .lpstrFile = strDateiname
       .nMaxFile = Len(strDateiname)
       .lpstrInitialDir = strInitDir
       .lpstrTitle = strDialogTitle
       .Flags = lngFlags
       .lpstrDefExt = strDefaultExt
       
       If APT_GetOpenFileName(OpenDlg) <> 0 Then     ' Aufruf erfolgreich
         
         If blnMultiSelect Then
            
            If Not blnKompatibel Then
                strDateiname = ParseAuswahl(.lpstrFile, True)
            Else ' OCX-kompatibel
                strDateiname = Left$(.lpstrFile, InStr(.lpstrFile, cnstNull & cnstNull) - 1) ' restliche NUL-Werte abschneiden
            End If
         Else
             intFileCount = 1
             strDateiname = Left$(.lpstrFile, InStr(.lpstrFile, cnstNull) - 1) ' restliche NUL-Werte abschneiden
         End If
         
         ' man kann beides machen:
         ' Datei= fd.ShowOpen oder fd.ShowOpen : Datei=fd.FileName
         ShowOpen = strDateiname
       Else
         strDateiname = ""
         ShowOpen = ""
         intFileCount = 0
       End If
    End With

Exit_ShowOpen:
    Exit Function
Error_ShowOpen:
    MsgBox err.description, , "Exit_ShowOpen"
    Resume Exit_ShowOpen
End Function


Function ShowSave() As String
On Error GoTo Error_ShowSave

   Dim myFilter As String
   Dim OpenDlg As TOpenFileName
   
   myFilter = BuildFilter()
   Call CheckFlags("Save")
   
   If strDialogTitle = "" Then
      strDialogTitle = "Datei speichern unter" & cnstNull
   End If
   
    ' String für Default-Dateinamen setzen, Länge kann variieren (Normal/Multiselect), deswegen hier
    strDateiname = strDefaultFileNameSave & String$(intLenFileName - Len(strDefaultFileNameSave), 0)
    
   With OpenDlg
      .lStructSize = Len(OpenDlg)
       If lngHWnd = 0 Then
            .hOwner = Application.hWndAccessApp
       Else
            .hOwner = lngHWnd
       End If
      .lpstrFilter = myFilter
      .nFilterIndex = 1
      .nFileExtension = ExtCount
      .lpstrFile = strDateiname
      .nMaxFile = Len(strDateiname)
      .lpstrInitialDir = strInitDir
      .lpstrTitle = strDialogTitle
      .Flags = lngFlags
      .lpstrDefExt = strDefaultExt
      
     
      
      If APT_GetSaveFileName(OpenDlg) <> 0 Then     ' Aufruf erfolgreich
         ' man kann beides machen:
         ' Datei= fd.ShowSave oder fd.ShowSave; Datei=fd.FileName

         strDateiname = Left$(.lpstrFile, InStr(.lpstrFile, cnstNull) - 1) ' restliche NUL-Werte abschneiden
         'If InStr(1, strDateiName, "." & LCase(strDefaultExt)) = 0 Then
         '   strDateiName = strDateiName & "." & LCase(strDefaultExt)
         'End If
         ShowSave = strDateiname
      Else
         strDateiname = ""
         ShowSave = ""
      End If
   End With

Exit_ShowSave:
    Exit Function
Error_ShowSave:
    MsgBox err.description, , "Exit_ShowSave"
    Resume Exit_ShowSave
End Function

Private Sub Class_Initialize()
On Error GoTo Error_Class_Initialize
   
   ' Null-String initialisieren
   cnstNull = Chr$(0)
   
   ' der String sollte lang genug für einen Win-95 Pfad sein,
   ' für Multiselect wird das in .MultiSelect auf LEN_FILENAME_MULTISELECT erhöht
   intLenFileName = LEN_FILENAME_NORMAL
   strDateiname = String$(LEN_FILENAME_NORMAL, 0)
   
   strDialogTitle = "" ' erstmal leer, wird in .ShowOpen/.ShowSave auf Default gesetzt
   strFilter = ""  ' erstmal leer, wird in BuildFilter() gebaut
   
   ' erstmal keine Default-Flags (wird in ShowOpen/ShowSave gesetzt)
   lngFlags = 0
   
   ' keine Default-Erweiterung
   strDefaultExt = cnstNull
   
   ' aktuelles Verzeichnis
   strInitDir = CurDir$ & cnstNull

    intExtCount = 0
    
Exit_Class_Initialize:
    Exit Sub
Error_Class_Initialize:
    MsgBox err.description, , "Exit_Class_Initialize"
    Resume Exit_Class_Initialize
End Sub