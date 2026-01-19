Attribute VB_Name = "mdlStartDoc"
Option Compare Database
Option Explicit

'======================================================================================

'Seit Acc97 ist die unten beschriebene Funktion eigentlich obsolet, d.h. sie wird nicht mehr benötigt.

'Dafür kann man folgendes verwenden:

'Application.FollowHyperlink DocName

'(siehe Hilfe unter FollowHyperlink) erledigt das viel kürzer
'Ich hab die alte Funktion nur aus Kompatibilitätsgründen dringelassen

' Klaus Oberdalhoff 22.07.1999

'======================================================================================

'ShellExecute
'------------

'16-bit: Declare PtrSafe Function ShellExecute Lib "SHELL" (ByVal _
'        hwnd As Integer, ByVal lpszOp As String, ByVal lpszFile _
'        As String, ByVal lpszParams As String, ByVal lpszDir As _
'        String, ByVal fsShowCmd As Integer) As Integer

Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias _
        "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation _
         As String, ByVal lpFile As String, ByVal lpParameters _
         As String, ByVal lpDirectory As String, ByVal nShowCmd _
         As Long) As Long

' Mit dieser Funktion kann irgendein Shell-Prozess gestartet werden, sofern
' der übergebene Name mit einer Anwendung verknüpft ist. Er wirkt wie ein
' Hyperlink-Pfad. Der übergebene Pfadname ist der Name des Pfades, der beim
' Start der Applikation als Start-Pfad verwendet werden soll.

' Beispiel: Nix = StartDoc("C:\Eigene Dateien\Test.doc", "C:\")
' Beispiel: Nix = StartDoc("C:\Eigene Dateien\Test.bmp", "C:\")
' Beispiel: Nix = StartDoc("http://www.microsoft.com", "C:\")
' Beispiel: Nix = StartDoc("mailto:Hugo@emil.de", "C:\")
' Beispiel: Nix = StartDoc("mailto:Hugo@emil.de ?subject=ObdAdr ", "C:\")

'"?cc=" trägt in "über" ein
'"?subject=" trägt in "Betreff" ein
'"?body=" trägt in "Text" ein
'
'DeinFeld = "mailto:kobd@gmx.de ?cc=hugo@anton.de ?subject=Dein Betreff"
'DeinFeld = DeinFeld & " ?body=Hi," & vbCrLf & "dies ist ein Test"
'DeinFeld = DeinFeld & vbCrLf & vbCrLf & "mfg Klaus"

'Das mit ?cc ?subject und ?body funktioniert natürlich nur,
'wenn es dein Standard-eMail-Programm unterstützt

Function StartDoc(ByVal Docname As String, Optional ByVal PathName As String = "C:\", Optional ByVal SW_SHOWNORMAL As Long = 3)
 
'Const SW_SHOWNORMAL = 1
      
'Public Const WIN_NORMAL = 1         'Open Normal
'Public Const WIN_MAX = 3            'Open Maximized
'Public Const WIN_MIN = 2            'Open Minimized
      
    On Error GoTo StartDoc_Error

    StartDoc = ShellExecute(Application.hWndAccessApp, "Open", Docname, "", PathName, SW_SHOWNORMAL)
    Exit Function

StartDoc_Error:
    MsgBox "Error: " & Err & " " & Error
    Exit Function
End Function


Function PrintDoc(ByVal Docname As String, Optional ByVal PathName As String = "C:\", Optional ByVal SW_SHOWNORMAL As Long = 3)
 
'Const SW_SHOWNORMAL = 1
      
'Public Const WIN_NORMAL = 1         'Open Normal
'Public Const WIN_MAX = 3            'Open Maximized
'Public Const WIN_MIN = 2            'Open Minimized
      
    On Error GoTo PrintDoc_Error

    PrintDoc = ShellExecute(Application.hWndAccessApp, "print", Docname, "print", PathName, SW_SHOWNORMAL)
    Exit Function

PrintDoc_Error:
    MsgBox "Error: " & Err & " " & Error
    Exit Function
End Function



'ShellExecute -Funktion
'
'Startet eine Anwendung oder ein Dokument mit der verknüpften Anwendung, wobei man noch den Start- und Fenstermodus festlegen kann.
'
'
'Betriebssystem:  Win95, Win98, WinNT 3.1, Win2000, WinME Views:  9.855
'
'Deklaration:
'
'
'Declare PtrSafe Function ShellExecute Lib "shell32.dll" _
'  Alias "ShellExecuteA" ( _
'  ByVal hwnd As Long, _
'  ByVal lpOperation As String, _
'  ByVal lpFile As String, _
'  ByVal lpParameters As String, _
'  ByVal lpDirectory As String, _
'  ByVal nShowCmd As Long) As Long
'Beschreibung:
'Diese Funktion startet eine Anwendung oder ein Dokument mit der verknüpften Anwendung, wobei man noch den Start- und Fenstermodus festlegen kann.
'
'Parameter:
'hwnd Handle des aufrufenden Fensters
'lpOperation Erwartet eine Zeichenfolge, die beschreibt, welche Operation ausgeführt werden soll. Bei diesen Operationen handelt es sich um Befehle,
'die in der Windows-Registry stehen und auch im Kontextmenü der Datei im Windows-Explorer zu finden sind. Wird ein leerer String übergeben,
'wird der Standard-Öffnenbefehl benutzt. Ist dieser Standard-Befehl nicht in der Windows-Registry vorhanden, wird die Datei mit dem "Open""-Kommando geöffnet.
'Unter Windows 2000 wird ebenfalls versucht das Dokument per Standard-Kommando zu öffnen. Ist kein Standard-Kommando definiert,
'so bedient sich Windows 2000 dem ersten Registryeintrag, welcher bei der verknüpften Datei gefunden wird. Gültige Kommandos sind die folgenden Strings.
'
'lpOperation Kommandos
'
'"edit"Verhält sich so, als würde man im Kontextmenü des Explorers auf "Bearbeiten" klicken.
'
'"explore"Handelt es sich bei "lpFile" um einen Verzeichnispfad, wird der Windows Explorer in Verbindung mit diesem Verzeichnis geöffnet.
'
'"find"Handelt es sich bei "lpFile" um einen Verzeichnispfad, wird der Windows Suchen-Dialog gestartet.
'
'"open"Öffnet die Datei mit dem lt. Registry verknüpften Programm.
'
'"print"Druckt das Dokument in Verbindung mit der verknüpften Anwendung.
'
'"properties"Zeigt die Verzeichnis- oder Datei-Eigenschaften
'lpFile Verzeichnisnamen, Datei oder Dokument, welches mit der verknüpften Anwendung geöffnet werden soll.
'lpParameters Optionale Angabe von zusätzlichen Aufruf-Parametern.
'lpDirectory Legt das Arbeitsverzeichnis fest.
'nCmdShow Erwartet ein Konstante, die beschreibt, wie sich das Anwendungs-Fenster berhalten soll.
'
'
'nCmdShow Konstanten:
'
'
'' versteckt das Fenster
'Const SW_HIDE = 0
'
'' maximiert das Fenster
'Const SW_MAXIMIZE = 3
'
'' minmiert das Fenster
'Const SW_MINIMIZE = 6
'
'' aktiviert das Fenster
'Const SW_NORMAL = 1
'
'' zeigt das Fenster
'Const SW_SHOW = 5
'
'' stellt die Fenstergröße wieder her
'Const SW_RESTORE = 9
'
'' zeigt das Fenster an und maximiert es
'Const SW_SHOWMAXIMIZED = 3
'
'' zeigt das Fenster an und minimiert es
'Const SW_SHOWMINIMIZED = 2
'
'' minimiert das Fenster und aktiviert es nicht
'Const SW_SHOWMINNOACTIVE = 7
'
'' zeigt das Fenster an, aber aktiviert es nicht
'Const SW_SHOWNA = 8
'
'' zeigt das Fenster an ohne es zu aktivieren
'Const SW_SHOWNOACTIVATE = 4
'
'' zeigt das Fenster und aktiviert dies
'Const SW_SHOWNORMAL = 1
'Rückgabewert:
'War der Funktionsaufruf erfolgreich, wird das Instanzhandle der gestarteten Anwendung zurückgegeben. Der Rückgabewert ist 0,
'wenn nicht genügend Systemressourcen zur Ausführung der Funktion vorhanden sind. Scheitert der Funktionsaufruf aus einem anderen Grund,
'so ist der Rückgabewert wie folgt zu interpretieren.
'
'
'Rückgabekonstanten:
'
'' Datei ist keine Win32 Anwendung
'Const ERROR_BAD_FORMAT = 11&
'
'' Zugriff verweigert
'Const SE_ERR_ACCESSDENIED = 5
'
'' Datei-Assoziation ist unvollständig
'Const SE_ERR_ASSOCINCOMPLETE = 27
'
'' DDE ist nicht bereit
'Const SE_ERR_DDEBUSY = 30
'
'' DDE-Vorgang gescheitert
'Const SE_ERR_DDEFAIL = 29
'
'' DDE-Zeitlimit wurde erreicht
'Const SE_ERR_DDETIMEOUT = 28
'
'' benötigte DLL wurde nicht gefunden
'Const SE_ERR_DLLNOTFOUND = 32
'
'' Datei wurde nicht gefunden
'Const SE_ERR_FNF = 2
'
'' Datei ist nicht Assoziiert
'Const SE_ERR_NOASSOC = 31
'
'' Nicht genügend Speicher
'Const SE_ERR_OOM = 8
'
'' Pfad wurde nicht gefunden
'Const SE_ERR_PNF = 3
'
'' Sharing-Verletzung
'Const SE_ERR_SHARE = 26
'Beispiel:
'
'
'Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
'  ByVal hwnd As Long, _
'  ByVal lpOperation As String, _
'  ByVal lpFile As String, _
'  ByVal lpParameters As String, _
'  ByVal lpDirectory As String, _
'  ByVal nShowCmd As Long) As Long
'
'Private Const SW_HIDE = 0
'Private Const SW_MAXIMIZE = 3
'Private Const SW_MINIMIZE = 6
'Private Const SW_NORMAL = 1
'Private Const SW_SHOW = 5
'Private Const SW_RESTORE = 9
'Private Const SW_SHOWMAXIMIZED = 3
'Private Const SW_SHOWMINIMIZED = 2
'Private Const SW_SHOWMINNOACTIVE = 7
'Private Const SW_SHOWNA = 8
'Private Const SW_SHOWNOACTIVATE = 4
'Private Const SW_SHOWNORMAL = 1
'
'Private Const ERROR_BAD_FORMAT = 11&
'Private Const SE_ERR_ACCESSDENIED = 5
'Private Const SE_ERR_ASSOCINCOMPLETE = 27
'Private Const SE_ERR_DDEBUSY = 30
'Private Const SE_ERR_DDEFAIL = 29
'Private Const SE_ERR_DDETIMEOUT = 28
'Private Const SE_ERR_DLLNOTFOUND = 32
'Private Const SE_ERR_FNF = 2
'Private Const SE_ERR_NOASSOC = 31
'Private Const SE_ERR_OOM = 8
'Private Const SE_ERR_PNF = 3
'Private Const SE_ERR_SHARE = 26
'Private Sub Command1_Click()
'  Dim Retval As Long
'
'  Retval = ShellExecute(Me.hwnd, "open", "C:\Windows\Notepad.exe", _
'    "C:\AutoExeC.bat", "c:\", SW_SHOWNORMAL)
'
'  ' Der gleiche Vorgang kann auch ausgeführt werden mittels...
'  ' Retval = ShellExecute(Me.hwnd, "edit", "C:\AutoExeC.bat", "", "c:\", 'SW_SHOWNORMAL)
'
'  Select Case Retval
'    Case SE_ERR_NOASSOC
'      MsgBox "Datei ist nicht Assizoiert", vbInformation, "Fehler"
'      Exit Sub
'    Case SE_ERR_PNF
'      MsgBox "Pfad wurde nicht gefunden", vbInformation, "Fehler"
'      Exit Sub
'    Case SE_ERR_FNF
'      MsgBox "Datei wurde nicht gefunden", vbInformation, "Fehler"
'      Exit Sub
'    Case 8, 26, 32, 28, 29, 30, 27, 5, 11 ' alle anderen Fehler
'      Exit Sub
'  End Select
'End Sub
'
'

