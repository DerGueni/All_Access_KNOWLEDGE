Option Compare Database
Option Explicit

'   NurZahl            - Entfernt alle nicht numerischen Werte und gibt die puren Ziffern zurück
'   Dec2Hex            - Dezimal --> Hexadezimal
'   Hex2Dec            - Hexadezimal --> Dezimal
'   CtrlAltDel         - Ctrl Alt Del unter Win95 Disablen (Nicht für NT)
'   Euro               - Das Euro-Zeichen ausgeben
'   fmt_Euro           - Ausgabe eines DM Betrages als String umgerechnet in Euro
'   AutoDial           - Automatische Wahl einer Telefonnummer mittels TAPI (Win95 / 98 / NT4.0?)
'   ProgramCLose       - Fremdprogramm schließen
'   MakeTempFileName   - Temporärdatei erzeugen (MSKB)
'   BusinessUnit       - predefined BusinessUnit setzen oder löschen
'   ToDo               - Auf unerledigte Programme hinweisen (ToDo für Programmierer)
'   FParsePath         - Pfad, Dateiname und Extension aus Dateiname incl. Pfad extrahieren (MS Neatcd97.mdb)
'   DBErstellen        - Erstellen einer MDB
'   DOSPgmStart        - DOS-Programm starten
'   ClearMyTxtboxes    - Textboxes einer Form löschen
'   CloseAllForms      - Alle Forms auf einmal schließen
'   MergeIt            - Methode, wie ich eine Liste mit E-mail-Adressen umwandeln kann, sodass ich eine Art Serienmail schicken kann
'   DBName             - Ausgabe des aktuellen Datenbanknamens mit Path
'   DBPfad             - Ausgabe des aktuellen Datenbankpfades ohne DBNamen
'   Fehlercd           - Ausgabe von Fehlermeldungen
'   pz_berechnen       - PrüfZiffern-Verfahren Mod 10 rekursiv für VESR (Null gibt 0)
'   TestAdd            - Addiert einen Wert zu einem alphanumerischen String
'   CurrMDBSchliessen  - Schließt die aktive Datenbank
'   backup_Reminder    - Automatisch an´s Backup erinnern (in Autoexec einbinden)
'   XPath              - Bestehenden Pfad durch einen fixen anderen ersetzen, benötigt FParsePath ...
'   WelcheRegisterSeite- In welcher Registerseite befindet sich ein bestimmtes Control
'   ANSIToUni          - Konvertiert ANSI nach Unicode
'   UniToAnsi          - Konvertiert Unicode nach ANSI
'
'**********************************************************************************
' Deklarationen für CtrlAltDelEinAus - Ctrl Alt Del unter Win95 verbieten
'**********************************************************************************
Declare PtrSafe Function SystemParametersInfo Lib "user32" Alias _
"SystemParametersInfoA" (ByVal uAction As Long, ByVal uParam As Long, _
lpvParam As Any, ByVal fuWinIni As Long) As Long

'**********************************************************************************
' Fremdprogramm schließen
'**********************************************************************************
Declare PtrSafe Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, _
    ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
  Public Const WM_CLOSE = &H10

Declare PtrSafe Function WNetAddConnection Lib "mpr.dll" Alias "WNetAddConnectionA" _
(ByVal lpszNetPath As String, ByVal lpszPassword As String, ByVal _
lpszLocalName As String) As Long


Function NurZahl(Eingabe As String)
' ***********************************************************
' Entfernt alle nicht numerischen Werte und gibt die puren Ziffern zurück
' Ausschließlich gedacht, um z.B. aus Telefonnummern "/" oder "-" oder "(" ")"
' zu entfernen.
' Achtung: Es entfernt auch Komma oder Tausenderpunkt etc ohne Rücksicht.
' Die Funktion ist also für Zahlen mit Nachkommastellen ungeeignet !!!
' ***********************************************************

Dim i As Integer, Max As Integer, tmp As String

NurZahl = ""

Max = Len(Trim(Nz(Eingabe)))

If Max = 0 Then
    Exit Function
End If

For i = 1 To Max
    tmp = Mid(Eingabe, i, 1)
    If Not (tmp < Chr(48) Or tmp > Chr(57)) Then
        NurZahl = NurZahl & tmp
    End If
Next i

End Function

Function Dec2Hex(ByVal x As Double) As String
'
' Converts Decimal value to Hexidecimal string equivalent
' Geändert, Original aus Neatcode.mdb von MS
' Verwendet mdlLocale (für GetDecimalSep)
'
  Dim result As String, i As Integer, temp As Integer

  result = Hex(Int(x)) & GetDecimalSep()
  x = x - Int(x)
  For i = 1 To 16
    x = x * 16
    result = result & Hex(x)
    x = x - Int(x)
  Next i
  Dec2Hex = result
    
End Function

Private Function GetDecimalSep()
GetDecimalSep = ","
End Function


Function Hex2Dec(strValue As String) As Long
On Error GoTo CnvrtErr
'
' Geändert, Original aus Neatcode.mdb von MS
' Verwendet mdlLocale (für GetDecimalSep)
' Converts a string of hexadecimal digits into a decimal number.
' Valid input range '0' to '7FFFFFFF'
'
' Check to see if string already begins with &H.
If Left(strValue, 2) <> "&H" Then strValue = "&h" & strValue

' Check to see if string contains Decimals and strip them out.
If InStr(1, strValue, GetDecimalSep()) Then strValue = Left(strValue, (InStr(1, strValue, GetDecimalSep()) - 1))

Hex2Dec = CLng(strValue)
Exit Function

CnvrtErr:
Hex2Dec = 0

End Function

Function CtrlAltDel(Erlaubt As Boolean)
'Ctrl Alt Del unter Win95 (und Win98) ausschalten.
' Funktioniert lt. Newsgroups NICHT unter NT
' Nur unter Win95 + 98 getestet

' Erlaubt = True, dann Enable
' Erlaubt = False, dann Disable

Dim Dummy

If Erlaubt Then
    Call SystemParametersInfo(97, False, Dummy, 0)  ' enable Win95 system key
Else
    Call SystemParametersInfo(97, True, Dummy, 0)   ' kein alt-tab, ctrl-alt-del
End If

End Function

Function Euro()
'Ausgabe des Eurozeichens, sofern man die Corefonts (Freefonts von MS) geladen hat
' und als Font einer dieser neuen Fonts ausgewählt ist ...

'Function im Direktfenster ausführen, das Eurozeichen ausschneiden. Es kann dann
'überall da, wo "neue" Fonts verwendet werden, eingefügt werden ...

' Leider ist MS Sans Serif nicht als Update verfügbar :-((((((((
' Mit NT 4 SP4 ist auch MS Sans Serif eurofähig <g>

'Es gibt (Stand 20.02.1998) unter
'http://www.microsoft.com/typography/fontpack/default.htm
'auch die neueren Fonts zum abholen (Arial, Times und andere), die das
'Euro-Symbol haben. Sie haben den Zusatz "32", also Times32.exe,
'Arial32.exe etc. Man kann sie aber als Paket holen: Corefonts für die
'Standardfonts (Arial, Courier, Times) und ein anderes Paket für die
'anderen (Verdana, Georgia usw.)

Euro = ChrW(&H20AC)

End Function


Public Function fmt_Euro$(lgEin@)

    ' von Rainer Grau rgrau@ncs.de
    
    'Umrechnung und Ausgabe eines Betrags als String in Euro; Eingabe DM-Betrag
    
    'Der Arialfont wurde mit corfnt32.exe (zu beziehen unter
    'http://www.microsoft.com/typography/fontpack/default.htm)
    'auf Eurozeichen erweitert.
    '
    'Siehe auch tblEuroUmrechnung
    '
    'Etwas muehselig, aber funktioniert auch unter NT4.0
    '
    'ich zeige meine Betraege als Zeichenfolgen an und formatiere mit
    'folgender Funktion:
    
    'hier ausnahmsweise definiert, damit es sich ohne Fehler kompilieren läßt.
    'lgWechselKurs ist normalerweise eine globale Konstante
    Dim lgWechselKurs As Double

    Dim i%, strErg$, intPos%
    
    lgWechselKurs = 1.95583
    
    strErg = Format(lgEin / lgWechselKurs, "Currency")
    intPos = InStr(1, strErg, "DM")
    Mid(strErg, intPos, 2) = "€ "  'Arial Font; Eurozeichen aus Word
    fmt_Euro$ = strErg             'in function kopiert
End Function


'--------------------------------------------------------------------------------------------
' FUNKTION  : AutoDial(...)
' ZWECK     : Automatische Wahl einer Telefonnummer mittels TAPI und WIN95 / 98 / NT4.0?
' ARGUMENTE : stNumber = zuwählende Telefonnummer
' ERGEBNIS  : -
'Aus dem FAQ der Uni Kiel, Klaus Hoppe
'--------------------------------------------------------------------------------------------
Public Function Autodial(ByVal stNumber As String)
    Application.Run "utility.wlib_AutoDial", stNumber
End Function


'--------------------------------------------------------------------------------------------
' Function ProgramClose(Handle As Long)
' Aufruf mit: SendMessage Handle, WM_CLOSE, 0, 0
' Aus www.basicworld.com
'--------------------------------------------------------------------------------------------
Public Function ProgramClose(handle As Long)
    SendMessage handle, WM_CLOSE, 0, 0
End Function


Function MakeTempFileName(Extension As String) As String
'INF: Sample Function to Generate a Random Temporary File Name
'Article ID: Q88929
On Error Resume Next
Dim Isfile As Integer, FHandle As Integer, Cntr As Integer
Dim WinTemp As String, TF As String
   Isfile = False
   FHandle = FreeFile

Do
   WinTemp = Environ("TEMP") & "\"
   'WinTemp = GetTempDir()
   For Cntr = 1 To 8
   WinTemp = WinTemp & Mid(LTrim(str(CInt(Rnd * 10))), 1, 1)
   Next

      TF = Trim(WinTemp$) & "." & Extension

   Open TF For Output As #FHandle
Debug.Print TF
   Print #FHandle, "This is a Temp file"
Loop While err > 0
Close #FHandle
MakeTempFileName = TF

End Function



'I had a problem where I had to run a series of reports and forms with a
'predefined BusinessUnit. I didn't want it to change till I said so.
'
'The solution was to define a function that allows you to 'Set or Get' the value
'you need and include that function as criteria in all your queries that are used
'for reports or forms. (Use the like operator to get the a wildcard match.)
'
'it 's easy in Access 97, and you can hack out something like it in Access 2.0 if
'you change the optional parameter to test IfNull()

Function BusinessUnit(Optional Bu) As String

'Note this is a STATIC so it will remember its value between runs
Static sBu As String

On Error Resume Next

   'If you don't assign a new Business Unit you'll get the last one
     If Not IsMissing(Bu) Then

      sBu = Bu

     End If

    If IsNull(sBu) Then

    'This returns a wild card so that all Business Units will match
     sBu = "*"

    End If

     BusinessUnit = sBu 'return the current value

End Function

'If you are a chaotic programmer like me, you will probably know this situation:
'
'While working on a larger Access project there are situations where some of the
'Code you are writing can't be completed because it relies on things yet to be
'implemented. (Or you are to lazy at the time). Then you forget this code because
'it 's not essential, or only called in special situations.
'
'When the customer tries to use this 'feature' that you forgot to finish, one of
'the following things will happen (add your favorite to this list):
'
'nothing at all,
'the program crashes, or
'nothing at all except many beeps and weird messages from test code you wrote.
'
'To overcome this, I wrote a VERY simple, but helpful function called 'The ToDo
'function':

Function ToDo(Optional description As String)
    MsgBox "Not implemented.@@" & description, vbInformation
End Function
'You can use it in Code or as event handler on forms. This has two advantages:
'
'Your Customers get a proper message
'You can search your whole for "ToDo" to find unfinished parts


Sub FParsePath(ByVal FullPath As String, Drive As String, DirName As String, fName As String, Ext As String)
'
' Parses drive, directory, filename, and extension into separate variables.
' Returns blank drive letter/path if none specified.
' Frm Neatcd97.mdb (MS)
'
Dim i As Integer, f As String, found As Integer
  Drive = ""
  DirName = ""
  fName = ""
  Ext = ""
  FullPath = Trim$(FullPath)
'
' Get drive letter
'
  If Mid$(FullPath, 2, 1) = ":" Then
    Drive = Left$(FullPath, 2)
    FullPath = Mid$(FullPath, 3)
  End If
'
' Get directory name
'
  f = ""
  found = False
  For i = Len(FullPath) To 1 Step -1
    If Mid$(FullPath, i, 1) = "\" Then
      f = Mid$(FullPath, i + 1)
      DirName = Left$(FullPath, i)
      found = True
      Exit For
    End If
  Next i
  If Not found Then
    f = FullPath
  End If
'
' Get File name and extension
'
  If f = "." Or f = ".." Then
    fName = f
  Else
    i = InStrRev(f, ".")
    If i > 0 Then
      fName = Left$(f, i - 1)
      Ext = Mid$(f, i)
    Else
      fName = f
    End If
  End If
End Sub

Function DBErstellen(strDatabaseName As String)
    
' Erstellen einer neuen Datenbank (z.b. auf Floppy)

    Dim db As DAO.Database, nix
    
DBErstellen_Versuch:
    err.clear
    On Error GoTo DBErstellen_Error
    
    If Dir(strDatabaseName) = "" Then ' Datenbank existiert nicht
        Set db = DBEngine.CreateDatabase(strDatabaseName, dbLangGeneral)
        db.Close
    End If
    Exit Function
    
DBErstellen_Error:
    If err.Number = 71 Then
        err.clear
        If MsgBox("Keine Diskette im Laufwerk A:", vbCritical + vbOKCancel, "Bitte Floppy einlegen") = vbOK Then
            GoTo DBErstellen_Versuch
        Else
            Exit Function
        End If
    Else
        nix = MsgBox("Unerwarteter Fehler " & err.Number, vbCritical, "Allgemeiner Fehler")
        Exit Function
    End If
    End Function


Function DOSPgmStart(DosAufruf As String, Optional AufrufArt As Integer = vbMinimizedNoFocus)
Dim varDummy
' Hergeleitet aus dem Newsgroup-Beispiel
' vardummy = Shell(Environ("COMSPEC") & " /C COPY " & Quelle & " " & Ziel, 6)

' Beispiel:
' Nix = DOSPgmStart("Copy C:\Autoexec.bat A:", 6)

' AufrufArt einer der folgenden 6 Parameter: (aus der Hilfe:)

'vbHide              0   Fenster ist ausgeblendet, und das ausgeblendete Fenster erhält den Fokus.
'vbNormalFocus       1   Fenster hat den Fokus und wird mit der ursprünglichen Größe und Position wiederhergestellt.
'vbMinimizedFocus    2   Fenster wird als Symbol angezeigt und hat den Fokus.
'vbMaximizedFocus    3   Fenster ist maximiert und hat den Fokus.
'vbNormalNoFocus     4   Fenster wird mit der letzten Größe und Position wiederhergestellt. Das momentan aktive Fenster bleibt aktiv.
'vbMinimizedNoFocus  6   Fenster wird als Symbol angezeigt. Das momentan aktive Fenster bleibt aktiv.

varDummy = Shell(Environ("COMSPEC") & " /C " & DosAufruf, AufrufArt)

End Function

' Aus der Newsgroup:
'In VBA (in A97 getestet) kannst du  über die Controls-Auflistung auf wirklich
'alle Felder eines Formulars zugreifen:
'(Funktion nur innerhalb eines Formulars ausführbar, da Me verwendet wird)
'
' Funktion auskommentiert, da sonst Fehler beim Kompilieren ...

'Sub ClearMyTxtboxes(formname As String)
Function Name_All_Labels(formName As String)
Dim i As Integer, Anz As Integer
Dim c As control
Dim frm As Form
DoCmd.OpenForm formName, acDesign
Set frm = Forms(formName)

Anz = frm.Controls.Count ' liefert die Anzahl Steuerelemente im Formular
If Anz <= 0 Then Exit Function ' keine Steuerelemente da
For i = 0 To Anz - 1
    Set c = frm.Controls(i)
'    Debug.Print C.ControlType, C.Name
    If c.ControlType = acLabel Then  ' wenn's n Label ist
        MsgBox " LabelName    = " & c.Name & vbCrLf & _
        " LabelCaption = " & c.caption
    End If
Next i
DoCmd.Close acForm, formName
End Function


'OOTypFunction Add_Label_To_Table(otyp As Long, formname As String, C_ControlType As Long, C_Visible As Boolean, C_Name As String, C_Caption As String)


Function CloseAllForms()
' Schließen aller Forms
' aus der Newsgroup

Dim frm As Form
Dim FormNummer, i As Integer
Dim Ausnahme As String

FormNummer = 0
i = 0
Ausnahme = "zUtilityServer"

While Forms.Count > 1
    i = i + 1
    Set frm = Forms(FormNummer)
    If frm.formName = Ausnahme Then
        FormNummer = 1
    Else
        If frm.Modal Then frm.Modal = False  '<<<added
        If frm.PopUp Then frm.PopUp = False  '<<<added
        DoCmd.Close acForm, frm.Name
    End If
Wend

End Function


Function dbname() As String
' Ausgabe des aktuellen Datenbanknamens
dbname = CurrentDb.Name
End Function


Function DBPfad() As String
' Ausgabe des aktuellen Datenbankpfades
DBPfad = Left(CurrentDb.Name, Len(CurrentDb.Name) - Len(Dir(CurrentDb.Name)))
End Function

Function Fehlercd()
'Newsgroup - Raimund Linn
Dim x

For x = 1 To 32767
    If Error$(x) <> "Benutzerdefinierter Fehler" _
    And Error$(x) <> "Reservierter Fehler" _
    And Error$(x) <> "Anwendungs- oder objektdefinierter Fehler" _
Then Debug.Print x, Error$(x)
Next x

End Function

Function pz_berechnen(Wert As Variant)
'Newsgroup Konrad Marfurt
'PrüfZiffern-Verfahren Mod 10 rekursiv für VESR (Null gibt 0)
If IsNull(Wert) Then
    pz_berechnen = "???"
    Exit Function
End If
Dim begriff As String, z0 As Integer, z1 As Integer, i As Integer
Const z10 = "0946827135"
begriff = Wert
z0 = 0
For i = 1 To Len(begriff)
       z1 = Val(Mid(begriff, i, 1))
       z0 = Val(Mid(z10, (z1 + z0) Mod 10 + 1, 1))
Next i
pz_berechnen = Chr(Asc("0") + (10 - z0) Mod 10)
End Function

Function TestAdd(Zaehler As String, Optional Stepper As Integer) As String
'KObd
'Addiert oder subtrahiert einen Wert(Stepper) zu einem String
'Wenn Stepper 0 oder nicht definiert, dann Stepper = 1
'ausgehend von folgendem Aufbau:
'Links eine Konstante mit der Länge LENLEFT, Rechts die Zahl

Const LENLEFT = 1

Dim LenRight As Integer
Dim leftchr As String
Dim rightnum As Long
Dim rightTmp

If Len(Trim(Nz(Zaehler))) = 0 Then
    MsgBox "Kein Zähler übergeben"
    Exit Function
End If

LenRight = Len(Zaehler) - LENLEFT

If Stepper = 0 Then 'Stepper = 0 oder nicht übergeben
    Stepper = 1
End If

leftchr = Left(Zaehler, LENLEFT)
rightnum = Right(Zaehler, LenRight)

rightTmp = rightnum + Stepper
TestAdd = leftchr & Right("0000000000000000000000000000" & rightTmp, LenRight)

End Function

Public Function CurrMDBSchliessen()
   Application.CloseCurrentDatabase
End Function

Function backup_Reminder(AnzahlTage As Integer)
'Erzeugt eine private Property namens "BackupReminder" die als Wert
'das Datum der letzten Erinnerung hat.
'Diese Property wird ausgelesen und mit dem übergebenen Wert verglichen.
'Wenn die Anzahl der Tage (AnzahlTage) überschritten ist, wird eine Warnung ausgelöst.
'Eine Warnung wird IMMER ausgelöst, wenn AnzahlTage = 0 ist.
'Kann in die Autoexec eingebunden werden
' Benötigt das Modul "mdlPrivProperty"
Dim Letzter_Reminder, nix
Dim LeRimDat As Date
On Error Resume Next
Letzter_Reminder = Get_Priv_Property("BackupReminder")
If Len(Nz(Letzter_Reminder)) = 0 Then
    LeRimDat = Date
Else
    LeRimDat = Letzter_Reminder
End If
If (Not (LeRimDat > (Date - AnzahlTage))) Then ' Datum kleiner oder gleich Heute
    Call Beep
    MsgBox "Bitte Backup der Datenbank nicht vergessen", vbExclamation, "Backup-Warnung"
    nix = Set_Priv_Property("BackupReminder", Format(Date, "dd") & "-" & Format(Date, "mmm") & "-" & Format(Date, "yyyy"))
End If
End Function

Function XPath(AltPathDatei As String, ByVal NeuPath As String) As String
'Bestehenden Pfad durch einen fixen anderen ersetzen, benötigt FParsePath
Dim XDrive As String, XDirName As String, XfName As String, XExt As String
If Len(Trim(Nz(AltPathDatei))) = 0 Then
    XPath = ""
    Exit Function
End If
Call FParsePath(AltPathDatei, XDrive, XDirName, XfName, XExt)
If Right(NeuPath, 1) <> "\" Then NeuPath = NeuPath & "\"
XPath = NeuPath & XfName & XExt
End Function


Function WelcheRegisterSeite(Feldname As String, DeinRegisterSteuerelement As control)
'wie kann ich denn per VB-Code herausfinden, auf welcher Registerseite (im
'Reg-StE) sich ein bestimmtes Steuerelement (Textfeld, List oder Kombo)
'befindet?
'Das Ergebnis sollte in etwa so aussehen:
'"Das Feld <Feld-Name> befindet sich im Register <Register-Überschrift>"
'Karl Donaubauer schrieb: Sendkeys
'Also in's Formularmodul damit und Aufruf mit
' = WelcheRegisterSeite("DeinFeldname", "DeinRegisterSteuerelement")
'
Dim p As Page
Dim c As control
For Each p In DeinRegisterSteuerelement.Pages
    For Each c In p.Controls
        If c.Name = Feldname Then
            MsgBox "Das Feld " & Feldname & " befindet sich im Register " & p.Name
        End If
    Next c
Next p
End Function


Function ANSIToUni(varAnsi As Variant) As Variant
    ' Convert an ANSI string to Unicode.
    
    ANSIToUni = StrConv(varAnsi, vbUnicode)
End Function

Function UniToAnsi(varUni As Variant) As Variant
    ' Convert a Unicode string to ANSI.
    
    UniToAnsi = StrConv(varUni, vbFromUnicode)
End Function


'Und schon piepst er:
'Autor: Newsgroup -  Fredi Hertel

'Private Declare PtrSafe Function api_Beep Lib "kernel32" Alias "Beep" (ByVal dwFreq As Long, ByVal dwDuration As Long) As Long

     ' Inputs:dwFreq
     ' Specifies the frequency, in hertz, of the sound.
     ' This parameter must be in the range 37 through 32,767
     ' (0x25 through 0x7FFF).
     ' dwDuration Beep
     ' Specifies the duration, in milliseconds, of the sound.
     ' One value has a special meaning: If dwDuration is - 1, the
     ' Function operates asynchronously and produces sound until called again.
     '
     ' Returns:If the function succeeds, the return value is TRUE.
     ' If the Function fails, the return value is FALSE. To Get extended
     ' Error information, call GetLastError.
     '
     'Assumes:
     'The Beep Function is synchronous in all but one case; the function does
     ' not generally return control to its caller until the sound finishes.
     ' The exception to this occurs when dwDuration has the value - 1.
     ' In that case, Beep is asynchronous, returning control immediately to
     ' its caller While the sound continues playing. The sound continues
     ' until the Next call to Beep.

Sub GetFormsProp2(ByVal objektName As String, Optional ObjektTyp As Integer)
'Autor: Newsgroup Roman Havlik, Erweiterungen Kobd
'> Wie kann ich das Änderungsdatum von Forms, reports u.ä. auslesen ? Bei
'> Tabellen und Abfragen hab' ich keine Probleme...
'
'Einfach per Code die entsprechende Eigenschaft (LastUpdated) auslesen. Anbei
'eine Prozedur die das machen sollte;-))
    Dim frmChk As Document
    Dim frmPrp As Property
On Error GoTo GetFormsProp2_Err

Select Case ObjektTyp
    Case acForm
        Set frmChk = DAO.DBEngine(0)(0).Containers!Forms(objektName)
    Case acReport
        Set frmChk = DAO.DBEngine(0)(0).Containers!Reports(objektName)
    Case acTable
        Set frmChk = DAO.DBEngine(0)(0).Containers!tables(objektName)
    Case acQuery
        MsgBox "Queries nicht unterstützt", vbCritical
        GoTo GetFormsProp2_Exit
'        Set frmChk = DAO.DBEngine(0)(0).Containers!Queries(Objektname)
    Case acMacro
        Set frmChk = DAO.DBEngine(0)(0).Containers!Scripts(objektName)
    Case acModule
        Set frmChk = DAO.DBEngine(0)(0).Containers!Modules(objektName)
    Case Else
        Set frmChk = DAO.DBEngine(0)(0).Containers!Databases(0)
End Select
'
    For Each frmPrp In frmChk.Properties
        Debug.Print frmPrp.Name, frmPrp.Value
    Next
    
GetFormsProp2_Exit:
    Exit Sub
GetFormsProp2_Err:
    MsgBox err.description, vbInformation, err.Number
    Resume GetFormsProp2_Exit
End Sub


Sub PropTst()
Call GetFormsProp2("tblStdBilder", acTable)
Call GetFormsProp2("qrptStückliste", acQuery)
Call GetFormsProp2("frmJagd", acForm)
Call GetFormsProp2("rptTimeLines", acReport)
Call GetFormsProp2("Autoexec Beispiel Verbinde", acMacro)
Call GetFormsProp2("mdlProperties", acModule)
Call GetFormsProp2("", 27)
End Sub