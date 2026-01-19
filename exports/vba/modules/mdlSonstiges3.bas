Attribute VB_Name = "mdlSonstiges3"
Option Compare Database
Option Explicit

'   ReferenzTest       - Überprüft die References-Auflistung, killt Fehler
'   GetLast            - Liefert den letzten Datensatz
'   Text2HTML          - Wandelt Umlaute HTML-gerecht umx
'   Path_erzeugen      - Erzeugt einen Path "auf einen Rutsch"
'   Asc2Num            - Wandelt ein ASC-String in einen numerischen String um
'   fEval              - Prozedurname als Variable übergeben
'   Zeichen_lösch      - Löscht ein bestimmtes Zeichen
'   suchenStr          - Diese Funktion sucht in einer Tabelle in beliebig vielen Feldern auch einen Teilstring
'   sOpenMDB           - Aktuelle MDB schließen und andere MDB öffnen
'   fktHideMB          - Verstecken aller Menü- und Symbolleisten
'   AccessexePath      - Wie heißt der Path von MSACCESS.EXE
'   DefValprf          - Mit dieser Funktion kann für DefaultValue der korrekte Wert zurückgegeben werden
'   smsMakeMde         - MDE "offiziell" erzeugen
'   Konv_MDE           - nicht dokumentierter Kurzaufruf um MDE zu erzeugen
'   smsDisablePulldownMenuEntry
'   AlterFieldType     - FeldTyp ändern
'   ReverseString      - String rückwärts ausgeben, d.h. "Neger" als "regeN" ausgeben
'   EnableControls     - Enable or disable controls in specified section of form
'   HideForm           - Formular verstecken
'   GetLineNumber      - Zeilennummer
'   RunSum             - Running Sum eines Unterformulars im Hauptformular
'   KillAllForms       - Alle Formulare lsöchen
'   selektiere         - String-Parsing
'   SAnzahl            - Wieviele Substrings gibt es (in selektiere verwendet)
'   LetztZeilen        - Drucken der letzten 5-10 Zeilen eines Memofeldes
'   ApplSetSub         - Options für Runtime-Umgebung setzen
'   ReplaceStr         - Substrings in einem String ersetzen (aus dr Neatcd97.mdb)
'   CRtoASCII          - CR LF durch Text "CRLF" ersetzen
'   LFtoCRLF           - LF durch CR LF ersetzen
'   ASCIItoCR          - Text "CRLF" durch CR LF ersetzen
'   pfadkuerzen        - Pfad für Optik kürzen
'   DatensatzIDZähler  - Ersatz für Autowert
'   Proper             - Erstes Zeichen jedes Worts groß schreiben
'   Uml2Win            - Funktion zu den Declares OEMtoANSI und ANSItoOEM (Umlaute Win <--> Dos)
'   HexStr             - String als Hex ausgeben "ÄÖÜ" als "C4 D6 DC" ausgeben
'   UnHexStr           - HexString als String ausgeben "C4 D6 DC" als "ÄÖÜ" ausgeben
'   DabaEinAus         - Datenbank-Fenster ein / ausblenden
'   OpenMacro          - Makro zum editieren öffnen
'   SystemMdwPath      - Name und Pfad der aktiven "system.mdw"
'   ValidFilename      - Prüft Filename auf Gültigkeit ...
'   mdbVersion         - mdbVersion
'   RandomPasswort     - Passwort generieren
'   RandomWert         - Wert generieren

'**********************************************************************************
' Deklarationen für MakePath in einem Befehl
'**********************************************************************************
Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias _
    "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long
'
'**********************************************************************************
' Deklarationen für Umlaute umsetzen
' PC -- > Ansi (Win)
'**********************************************************************************
  Declare PtrSafe Function OemToChar Lib "user32" Alias "OemToCharA" (ByVal lpszSrc As String, ByVal lpszDst As String) As Long

'**********************************************************************************
' Deklarationen für Umlaute umsetzen
' Ansi (Win) --> PC
'**********************************************************************************
  Declare PtrSafe Function CharToOem Lib "user32" Alias "CharToOemA" (ByVal lpszSrc As String, ByVal lpszDst As String) As Long


Public Function ReferenzTest() As Integer
'Überprüft die References-Auflistung, killt ggf. ungültige Verweise
'Erstellt von: Hendrik Lindemann <Hendrick@gmx.de>
'Geändert am 14.01.1999 - Fehlerbehandlung verbessert, Rückgabe als Integer
On Error GoTo Err_ReferenzTest
Dim ref As Reference
Dim strMldg As String

Const conStrErrMldg1 As String = "Kritischer Fehler: Typbibliothek(en) nicht" & _
"gefunden oder nicht verwendbar."
Const conStrErrMldg2 As String = "Die Anwendung wird unter Umständen nicht " & _
"korrekt funktionieren."
strMldg = ""
With Application
For Each ref In .References
    If ref.IsBroken Then
        On Error Resume Next                'Fehlerbehandlung aus
        strMldg = strMldg & "Pfad:" & vbTab & ref.fullPath & vbCrLf
        strMldg = strMldg & "Version:" & vbTab & ref.Major & "." & _
                    ref.Minor & vbCrLf & vbCrLf
        On Error GoTo Err_ReferenzTest      'und wieder ein
        If ref.BuiltIn Then
            MsgBox conStrErrMldg1, vbCritical
            ReferenzTest = False
        Else
            Select Case MsgBox(conStrErrMldg1 & "@" & strMldg & "@" & _
                        conStrErrMldg2, vbAbortRetryIgnore + vbCritical)
            Case vbIgnore
                .References.Remove ref
            Case vbAbort
                 Exit Function
            End Select
        End If
    End If
Next ref
End With

Exit_ReferenzTest:
    ReferenzTest = True
Exit Function

Err_ReferenzTest:
    MsgBox "Fehler-Nr. " & Err.Number & " in der Funktion 'Referenztest'.@Beschreibung: " & _
    Err.description & "@Bitte überprüfen Sie im Entwurfsansicht eines Moduls im Menü " & _
    "'Extras -> Verweise' auf evtl. fehlende Verweise und löschen Sie diese manuell. " & _
    "Versuchen Sie dann erneut diese Verweise einzubinden.", vbCritical, Err.Source
End Function

Function GetLast(ControlName As String)
' Newsgroup Harald Langer, übernommen von MS (Nordwind)
Dim f As Form
Dim ds As DAO.Recordset

Set f = Screen.ActiveForm
Set ds = f.RecordsetClone
ds.MoveLast
GetLast = ds(ControlName)
ds.Close
End Function

Function Text2HTML(s As String) As String
' von Sascha Wostmann
' Gibt's im Access97 eine VB-Prozedur, die es ermöglicht, dass ein
' "normaler" String in einen String umgewandelt wird, indem die
' HTML-Sonderzeichen umgewandelt werden ("ö" => "&ouml;")?
' Gunther Engelmann (8.1.2000):
' Zeichenliste erweitert (vollständig??)

Dim ret As String
Dim i As Integer

  ret = ""

  For i = 1 To Len(s)
    Select Case Mid$(s, i, 1)
    Case "­":      ret = ret & "&shy;"
    Case """":     ret = ret & "&quot;"
    Case "&":      ret = ret & "&amp;"
    Case "¡":      ret = ret & "&iexcl;"
    Case "¦":      ret = ret & "&brvbar;"
    Case "¨":      ret = ret & "&uml;"
    Case "¯":      ret = ret & "&macr;"
    Case "´":      ret = ret & "&acute;"
    Case "¿":      ret = ret & "&iquest;"
    Case "<":      ret = ret & "&lt;"
    Case ">":      ret = ret & "&gt;"
    Case "±":      ret = ret & "&plusmn;"
    Case "«":      ret = ret & "&laquo;"
    Case "»":      ret = ret & "&raquo;"
    Case "×":      ret = ret & "&times;"
    Case "÷":      ret = ret & "&divide;"
    Case "¢":      ret = ret & "&cent;"
    Case "£":      ret = ret & "&pound;"
    Case "¤":      ret = ret & "&curren;"
    Case "¥":      ret = ret & "&yen;"
    Case "§":      ret = ret & "&sect;"
    Case "©":      ret = ret & "&copy;"
    Case "¬":      ret = ret & "&not;"
    Case "®":      ret = ret & "&reg;"
    Case "°":      ret = ret & "&deg;"
    Case "µ":      ret = ret & "&micro;"
    Case "¶":      ret = ret & "&para;"
    Case "·":      ret = ret & "&middot;"
    Case "¼":      ret = ret & "&frac14;"
    Case "½":      ret = ret & "&frac12;"
    Case "¾":      ret = ret & "&frac34;"
    Case "¹":      ret = ret & "&sup1;"
    Case "²":      ret = ret & "&sup2;"
    Case "³":      ret = ret & "&sup3;"
    Case "á":      ret = ret & "&aacute;"
    Case "Á":      ret = ret & "&Aacute;"
    Case "â":      ret = ret & "&acirc;"
    Case "Â":      ret = ret & "&Acirc;"
    Case "à":      ret = ret & "&agrave;"
    Case "À":      ret = ret & "&Agrave;"
    Case "å":      ret = ret & "&aring;"
    Case "Å":      ret = ret & "&Aring;"
    Case "ã":      ret = ret & "&atilde;"
    Case "Ã":      ret = ret & "&Atilde;"
    Case "ä":      ret = ret & "&auml;"
    Case "Ä":      ret = ret & "&Auml;"
    Case "ª":      ret = ret & "&ordf;"
    Case "æ":      ret = ret & "&aelig;"
    Case "Æ":      ret = ret & "&AElig;"
    Case "ç":      ret = ret & "&ccedil;"
    Case "Ç":      ret = ret & "&Ccedil;"
    Case "Ð":      ret = ret & "&ETH;"
    Case "ð":      ret = ret & "&eth;"
    Case "é":      ret = ret & "&eacute;"
    Case "É":      ret = ret & "&Eacute;"
    Case "ê":      ret = ret & "&ecirc;"
    Case "Ê":      ret = ret & "&Ecirc;"
    Case "è":      ret = ret & "&egrave;"
    Case "È":      ret = ret & "&Egrave;"
    Case "ë":      ret = ret & "&euml;"
    Case "Ë":      ret = ret & "&Euml;"
    Case "í":      ret = ret & "&iacute;"
    Case "Í":      ret = ret & "&Iacute;"
    Case "î":      ret = ret & "&icirc;"
    Case "Î":      ret = ret & "&Icirc;"
    Case "ì":      ret = ret & "&igrave;"
    Case "Ì":      ret = ret & "&Igrave;"
    Case "ï":      ret = ret & "&iuml;"
    Case "Ï":      ret = ret & "&Iuml;"
    Case "ñ":      ret = ret & "&ntilde;"
    Case "Ñ":      ret = ret & "&Ntilde;"
    Case "ó":      ret = ret & "&oacute;"
    Case "Ó":      ret = ret & "&Oacute;"
    Case "ô":      ret = ret & "&ocirc;"
    Case "Ô":      ret = ret & "&Ocirc;"
    Case "ò":      ret = ret & "&ograve;"
    Case "Ò":      ret = ret & "&Ograve;"
    Case "º":      ret = ret & "&ordm;"
    Case "ø":      ret = ret & "&oslash;"
    Case "Ø":      ret = ret & "&Oslash;"
    Case "õ":      ret = ret & "&otilde;"
    Case "Õ":      ret = ret & "&Otilde;"
    Case "ö":      ret = ret & "&ouml;"
    Case "Ö":      ret = ret & "&Ouml;"
    Case "ß":      ret = ret & "&szlig;"
    Case "þ":      ret = ret & "&thorn;"
    Case "Þ":      ret = ret & "&THORN;"
    Case "ú":      ret = ret & "&uacute;"
    Case "Ú":      ret = ret & "&Uacute;"
    Case "û":      ret = ret & "&ucirc;"
    Case "Û":      ret = ret & "&Ucirc;"
    Case "ù":      ret = ret & "&ugrave;"
    Case "Ù":      ret = ret & "&Ugrave;"
    Case "ü":      ret = ret & "&uuml;"
    Case "Ü":      ret = ret & "&Uuml;"
    Case "ý":      ret = ret & "&yacute;"
    Case "Ý":      ret = ret & "&Yacute;"
    Case "ÿ":      ret = ret & "&yuml;"
    Case Else
      ret = ret & Mid$(s, i, 1)

    End Select
  Next

  Text2HTML = ret

End Function



Function Path_erzeugen(ByVal Pathnamen As String, Optional CreatWarn As Boolean = True, Optional WarnOnErr As Boolean = True) As Boolean
' Path mit mehreren Subs auf einmal erzeugen
' Idee aus VB-Tips & Tricks in der BasicWorld
' www.basicworld.com
' Der optionale Parameter NoWarnOnErr wird als "False" interpretiert, wenn nicht vorhanden.
' Wenn WarnOnErr = False, dann wird keine Fehlermeldungs-Messagebox ausgegeben
' Wenn CreatWarn = True, dann wird gefragt, ob das Directory erzeugt werden soll, wenn es nicht existiert.
' Wenn versucht wird, ein Directory anzulegen, das bereits existiert, so erfolgt keine Fehlermeldung

' Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias _
'    "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long

  
Dim nix
  
'Pfadnamen muß immer mit einem "\" enden
If Right(Pathnamen, 1) <> "\" Then
    Pathnamen = Pathnamen & "\"
End If

nix = Dir(Pathnamen, vbDirectory)

If CreatWarn And Len(Nz(nix)) = 0 Then ' Pfad existiert nicht und Warnungs-MsgBox on
    nix = MsgBox("Verzeichnis existiert nicht, soll es erstellt werden ?", vbQuestion + vbYesNo, _
                  Pathnamen)
    If nix = vbNo Then 'Abbruch der Funktion
        Path_erzeugen = False
        Exit Function
    End If
End If
        
'Pfad erstellen
If MakePath(Pathnamen) = 0 Then
    Path_erzeugen = False
    If WarnOnErr Then
        MsgBox "Verzeichnis konnte nicht erstellt werden.", vbCritical, Pathnamen
    End If
Else
    Path_erzeugen = True
End If

    
End Function
    


Function Asc2Num(XZeichen As String)
'Wandelt einen Chr-String in eine Zahl (bzw. eine numerische Zeichenfolge) um.
'Für jeden Chr werden 3 Zeichen benötigt.
'Autor: Klaus Oberdalhoff

Dim i As Integer
Dim TAsc

If Len(Nz(XZeichen)) < 1 Then
    Exit Function
End If

For i = 1 To Len(Nz(XZeichen))
    TAsc = Asc(Mid(XZeichen, i, 1))
    Asc2Num = Asc2Num & Right("000" & TAsc, 3)
Next i

End Function

'How can I call a Function by using a variable instead of Function Name?
'
' Use the Eval Function. If you pass to the Eval function a string that contains the name of a function,
'the Eval function returns the return value of the function. For example, Eval("Chr$(65)") returns "A".
'
'So for example, in the following code,  if you call fEval with "A" as parameter, you should get the
'result "Test That", else "Test This".

'*******Code Start*******
Function fEval(Status As String)
'---Posted by Dev Ashish---
Dim strFunctionName As String
Dim x
    If Status = "A" Then
        strFunctionName = "Eval_TestThat()"
    Else
        strFunctionName = "Eval_TestThis()"
    End If

    fEval = Eval(strFunctionName)
End Function

'Testfunktion für fEval
Private Function Eval_TestThis()
    Debug.Print "Test This"
End Function

'Testfunktion für fEval
Private Function Eval_testThat()
    Debug.Print "Test That"
End Function
'*******Code End**********


Function Zeichen_lösch(Quellstr As String, Optional Leerz As String = " ") As Variant
'von Klaus Oberdalhoff KObd@gmx.de

Dim x As String, y As String
Dim i As Integer
Dim pos1 As Integer

If Leerz = " " Then
    x = Trim(Nz(Quellstr))
Else
    x = Nz(Quellstr)
End If

y = ""

If Len(x) > 0 Then
    
    For i = 1 To Len(x) Step Len(Leerz)
        If Mid(x, i, Len(Leerz)) <> Leerz Then
            y = y & Mid(x, i, Len(Leerz))
        End If
    Next i
End If

Zeichen_lösch = y
        
End Function


Function suchenStr(tabelle$)

'diese Funktion sucht in einer Tabelle in beliebig vielen Feldern auch einen Teilstring
'Eingabe in die Inputbox ohne Sternchen und ohne "
'Günther Ritter  gritter@ gmx.de
'http://www.ostfrieslandweb.de/ kostenlose ACCESS-Beispiele

Dim db As DAO.Database
Dim rs As DAO.Recordset
Dim FeldCnt%, i%, strSQL$, begriff$

begriff = InputBox("Bitte Eingabe")
If begriff = "" Then Exit Function
Set db = CurrentDb
Set rs = db.OpenRecordset(tabelle)

strSQL = "select " _
    & rs.fields(0).Name _
    & " from " & tabelle & " where " _
    & rs.fields(0).Name _
    & " like '*" & begriff & "*'"

For i = 1 To rs.fields.Count - 1
    strSQL = strSQL & " or " & rs.fields(i).Name _
    & " like '*" & begriff & "*'"
Next
rs.Close

Set rs = db.OpenRecordset(strSQL, dbOpenSnapshot)

If rs.RecordCount = 1 Then
    MsgBox "Treffer"
Else
    MsgBox "Kein Treffer"
End If

rs.Close

Set db = Nothing

End Function

Sub sOpenMDB(strInMDB As String)
'--Posted by Dev Ashish---
'
'(Q)    How do I open another database without quitting Access?
'
'(A)    The best way at present is to use SendKeys for this.  Pass the new
'mdb filename to this sub.

'************ Code Start **********

'This code was originally written by Dev Ashish.
'It is not to be altered or distributed,
'except as part of an application.
'You are free to use it in any application,
'provided the copyright notice is left unchanged.

'============================================================
'ACHTUNG: Es darf nichts offen sein, sonst klappt´s nicht ...
'============================================================
'
'Code Courtesy of
'Dev Ashish

    On Error Resume Next

'    SendKeys "%FO" & strInMDB & "~"
'   In deutscher Version
    SendKeys "%Df" & strInMDB & "~"

End Sub

'************ Code End **********

Function fktHideMB()
' Gibt es eigentlich in Access die Möglichkeit, für Bildschirmpräsentationen auf
' eine komplette Vollbild-Anzeige (ohne jegliche Access-Menüleiste oder -Titelzeile
' umzuschalten?
'
'
'Ja!
'Die beiligende Funktion mußt du z.B. bei Aktualisierung des Forms aufrufen.
'Durch sie werden alle Menüleisten (1) und Symbolleisten (0) versteckt.
'!!!! Voraussetzungen beachten, sonst erscheint der Laufzeitfehler:
'-2147467259 (80004005) ;-)
'Was immer mir MS damit auch sagen will.
'
'Autor: Arndt Schönberg

' Versteckt alle Befehlszeilen

' Voraussetzungen:
' 1) Jedes Formular muß eine benutzerdefinierte Menüleiste haben (die wird auch ausgeblendet)
' 2) Beim Aufruf aus einem Makro darf KEIN Filter/Bedingung übergeben werden
' Wenn 1+2 nicht erfüllt sind, erscheint ein (wilder) Laufzeitfehler

' Wenn Filter benötigt, muß dieser durch AnwendenFilter nach dem öffnen realisiert werden

' 29.10.98 Arndt Schönberg (schoenberg@offis.uni-oldenburg.de)

Dim befehlsLeiste

For Each befehlsLeiste In CommandBars
  Debug.Print befehlsLeiste.Name, befehlsLeiste.Type, befehlsLeiste.BuiltIn
  If befehlsLeiste.Type = 1 Or befehlsLeiste.Type = 0 Then
    befehlsLeiste.Visible = False
  End If
Next befehlsLeiste

End Function


Function AccessexePath() As String
    AccessexePath = SysCmd(acSysCmdAccessDir)
End Function

Function DefValprf(XWert As Variant) As Variant
'Sofern man einer Variablen einen Defaultwert zuweist, und dieser Default-Wert ist eine Funktion, so wird
'fälschlicherweise diese Funktion nicht ausgeführt, sondern z.B. Date() zurückgegeben.
'Die Funktion Eval jedoch klappt nicht bei einem Leerwert ...
'Mit dieser Funktion kann für DefaultValue der korrekte Wert zurückgegeben werden.
If Len(Trim(Nz(XWert))) > 0 Then
    DefValprf = Eval(XWert)
Else
    DefValprf = ""
End If
End Function

'Making MDE Files From Within MS Access 97
' Written by Shamil Salakhetdinov
' e-mail: shamil@marta.darts.spb.ru
' Shamil M. Salakhetdinov, Darts Ltd. of St. Petersburg RU.
'*-

Public Function smsMakeMde(ByVal vstrDstMdbPath As String, _
                            ByVal vstrDstFileName As String, _
                            Optional ByRef robjAcc As Access.Application = Nothing) As Boolean
    
    On Error GoTo smsMakeMde_Err

    smsMakeMde = False

    Dim objAcc As Access.Application

    If Not robjAcc Is Nothing Then
        Set objAcc = robjAcc
    Else
        Set objAcc = New Access.Application
    End If

    objAcc.RefreshTitleBar

    DoEvents

    objAcc.Visible = True
    DoEvents

    SendKeys vstrDstMdbPath & vstrDstFileName & ".mdb"
    SendKeys "{Enter}"
    SendKeys vstrDstMdbPath & vstrDstFileName
    SendKeys "{Enter}"

    objAcc.DoCmd.RunCommand acCmdMakeMDEFile
    DoEvents
    objAcc.Visible = False

    smsMakeMde = True

smsMakeMde_exit:
    If robjAcc Is Nothing Then
       objAcc.Quit
    End If
    Set objAcc = Nothing
    Exit Function
smsMakeMde_Err:
    MsgBox "smsMakeMde: " & Err.Number & " - " & Err.description
    Resume smsMakeMde_exit
End Function



Function Konv_MDE(strMDBFile As String, strMDEFile As String) As Integer
'Beachte:
'Voller Pfad für MDB und MDE, Name kann gleich sein.
'Es funktioniert NICHT aus der MDB selbst, Du musst das Modul extra in
'eine DB schreiben, damit das "von aussen" geschieht.
'Ausführung im Testfenster.

'Making MDE Files From Within MS Access 97
'Undocumented function, use carefully and at your own risc !!!
'Karsten Brocksieper, IMG mbH of Hannover DE.
    ' Error Handling
    On Error GoTo Err_Konv_MDE

    ' Compile
    SysCmd 603, strMDBFile, strMDEFile

    ' No Error !
    Konv_MDE = True

Exit_Konv_MDE:

   Exit Function

Err_Konv_MDE:

    ' Error !!!
    Konv_MDE = False
    MsgBox Err.description
    Resume Exit_Konv_MDE

End Function


Function smsDisablePulldownMenuEntry(parMenuBarName As String, _
parEntryName As String) As Integer
' Written by Shamil Salakhetdinov
' e-mail: shamil@marta.darts.spb.ru
'Shamil M. Salakhetdinov, Darts Ltd. of St. Petersburg RU.

On Error GoTo smsDisablePulldownMenuEntry_Err
    CommandBars("Menu Bar (custom)").Controls(parMenuBarName). _
    CommandBar.Controls(parEntryName).Enabled = False
    
    smsDisablePulldownMenuEntry = True

smsDisablePulldownMenuEntry_Done:
    Exit Function

smsDisablePulldownMenuEntry_Err:
    Resume smsDisablePulldownMenuEntry_Done
    
End Function


Sub AlterFieldType(tblname As String, fieldName As String, NewDataType As String)
' The AlterFieldType Sub procedure requires three string
' parameters. The first string specifies the name of the table
' containing the field to be changed. The second string specifies
' the name of the field to be changed. The third string specifies
' the new data type for the field.
'gefunden in der CRSOFT mdb
Dim db As DAO.Database
Dim qdf As QueryDef
Set db = CurrentDb()
' Create a dummy QueryDef object.
Set qdf = db.CreateQueryDef("", "Select * from PROD1")
' Add a temporary field to the table.
qdf.sql = "ALTER TABLE [" & tblname & "] ADD COLUMN AlterTempField " & NewDataType
qdf.Execute
' Copy the data from old field into the new field.
qdf.sql = "UPDATE DISTINCTROW [" & tblname & "] SET_AlterTempField = [" & fieldName & "]"
qdf.Execute
' Delete the old field.
qdf.sql = "ALTER TABLE [" & tblname & "] DROP COLUMN [" & fieldName & "]"
qdf.Execute
' Rename the temporary field to the old field's name.
db.TableDefs("[" & tblname & "]").fields("AlterTempField").Name = fieldName
' Clean up.
End Sub

Function ReverseString(MyString As String)
'gefunden in der CRSOFT mdb
' "Regen" wird als "negeR" ausgegeben
Dim StringReversed As String
Dim MyStringLength As Integer, x
MyStringLength = Len(MyString)
For x = 1 To MyStringLength
    StringReversed = Mid(MyString, x, 1) & StringReversed
Next x
ReverseString = StringReversed
End Function


Function EnableControls(frm As Form, intSection As Integer, intState As Boolean) As Boolean
'  Enable or disable controls in specified section of form.
'  Use the Form object, section constant and state arguments
'  passed to the EnableControls procedure.
'gefunden in der CRSOFT mdb
'
'Section Konstante          Beschreibung
'
'0   acDetail               Formulardetailbereich oder Berichtsdetailbereich
'1   acHeader               Formular- oder Berichtskopfbereich
'2   acFooter               Formular- oder Berichtsfußbereich
'3   acPageHeader           Formular- oder Berichtsseitenkopfbereich
'4   acPageFooter           Formular- oder Berichtsseitenfußbereich
'5   acGroupLevel1Header    Gruppenebene 1 Kopfbereich (nur Berichte)
'6   acGroupLevel1Footer    Gruppenebene 1 Fußbereich (nur Berichte)
'7   acGroupLevel2Header    Gruppenebene 2 Kopfbereich (nur Berichte)
'8   acGroupLevel2Footer    Gruppenebene 2 Fußbereich (nur Berichte)
'
Dim ctl As control
'  Set intState for all controls in specified section.
For Each ctl In frm.Controls
    If ctl.Section = intSection Then
    On Error Resume Next
    ctl.Enabled = intState
    Err = 0
    End If
Next ctl
EnableControls = True
End Function

Function HideForm() As Integer
'gefunden in der CRSOFT MDB
On Error GoTo HideForm_Err
' Hide current form
Screen.ActiveForm.Visible = False
ExitHideForm:
    Exit Function
HideForm_Err:
    MsgBox "HideForm: " & Err & " - " & Err.description, vbInformation
    Resume ExitHideForm
End Function

Function GetLineNumber(f As Form, KeyName As String, KeyValue)
' The following function is used by the subfrmLineNumber form
'gefunden in der CRSOFT MDB
Dim rs As DAO.Recordset
Dim CountLines
On Error GoTo Err_GetLineNumber
Set rs = f.RecordsetClone
' Find the current record.
Select Case rs.fields(KeyName).Type
' Find using numeric data type key value?
Case DB_INTEGER, DB_LONG, DB_CURRENCY, DB_SINGLE, DB_DOUBLE, DB_BYTE
    rs.FindFirst "[" & KeyName & "] = " & KeyValue
    ' Find using date data type key value?
Case DB_DATE
    rs.FindFirst "[" & KeyName & "] = #" & KeyValue & "#"
    ' Find using text data type key value?
Case DB_TEXT
    rs.FindFirst "[" & KeyName & "] = '" & KeyValue & "'"
Case Else
    MsgBox "ERROR: Invalid key field data type!"
Exit Function
End Select
' Loop backward, counting the lines.
Do Until rs.BOF
CountLines = CountLines + 1
rs.MovePrevious
Loop
Bye_GetLineNumber:
    ' Return the result.
    GetLineNumber = CountLines
    Exit Function
Err_GetLineNumber:
    CountLines = 0
    Resume Bye_GetLineNumber
End Function


Function RunSum(f As Form, KeyName As String, KeyValue, FieldToSum As String)
'gefunden in der CRSOFT MDB
' FUNCTION: RunSum()
' PURPOSE:  Compute a running sum on a form.
' PARAMETERS:
'    F        - The form containing the previous value to
'               retrieve.
'    KeyName  - The name of the form's unique key field.
'    KeyValue - The current record's key value.
'    FieldToSum - The name of the field in the previous
'                 record containing the value to retrieve.
' RETURNS:  A running sum of the field FieldToSum.
' EXAMPLE:  =RunSum(Form,"ID",[ID],"Amount")
Dim rs As DAO.Recordset
Dim result
On Error GoTo Err_RunSum
' Get the form Recordset.
Set rs = f.RecordsetClone
' Find the current record.
Select Case rs.fields(KeyName).Type
' Find using numeric data type key value?
Case DB_INTEGER, DB_LONG, DB_CURRENCY, DB_SINGLE, DB_DOUBLE, DB_BYTE
    rs.FindFirst "[" & KeyName & "] = " & KeyValue
' Find using date data type key value?
Case DB_DATE
    rs.FindFirst "[" & KeyName & "] = #" & KeyValue & "#"
' Find using text data type key value?
Case DB_TEXT
    rs.FindFirst "[" & KeyName & "] = '" & KeyValue & "'"
Case Else
    MsgBox "ERROR: Invalid key field data type!"
    GoTo Bye_RunSum
End Select
' Compute the running sum.
Do Until rs.BOF
    result = result + rs(FieldToSum)
    ' Move to the previous record.
    rs.MovePrevious
Loop
Bye_RunSum:
    RunSum = result
    Exit Function
Err_RunSum:
         Resume Bye_RunSum
End Function

'-------------------------------
'von Karl Donaubauer
Function KillAllForms()

Dim db As DAO.Database
Dim doc As Document
Set db = CurrentDb

For Each doc In db.Containers!Forms.Documents
    DoCmd.DeleteObject acForm, doc.Name
Next

End Function
'-------------------------------

Function SAnzahl(s As String, a As String) As Integer
'
'               Funktion von Sascha Wostmann, s.w@gmx.de
'
' zählt die Vorkommen von A in S und liefert die Anzahl zurück
' Diese Funktion wird von "selektiere" (s.u.) aufgerufen, also
' nicht löschen, wenn selektiere benutzt wird!
'
' z.B.
'      SAnzahl("abc-def-ghi-jkl","-") = 3
'      SAnzahl("Saschas Spass","as") = 3
'
Dim ret As Integer
Dim t As String

    ret = 0
    t = s
    Do While InStr(t, a)
        ret = ret + 1
        t = Mid$(t, InStr(t, a) + 1)
    Loop
    
    SAnzahl = ret
End Function


Function selektiere(ByVal s As String, ByVal i As Integer, ByVal a As String) As String
'
'               Funktion von Sascha Wostmann, s.w@gmx.de
'
' Selektiert im String S den i-ten Teil. Trennzeichen ist in A.
' Bei Fehlern (z.B. nicht genug Trennzeichen im String) wird ""
' geliefert
'
' z.B.
' String mit Trennzeichen
' ("suche den zweiten Teil, wenn '-' die Teile trennt")
'      selektiere("abc-def-ghi-jkl",2,"-") = "def"
'      selektiere("abc-def,ghi-jkl",2,"-") = "def,ghi"
'
' Suche vom Ende nach vorne
' ("suche den zweitletzten Teil")
'      selektiere("abc-def-ghi-jkl",-2,"-") = "ghi"
'
' mehrere Trennzeichen
' ("suche den zweiten Teil, wenn der String ', ' die Teile trennt")
'      selektiere("Bonn, Köln, Bremen, Düsseldorf",2,", ") = "Köln"
'
Dim ret As String

Dim s1 As Integer
Dim s2 As Integer   ' Stellen, an denen der String getrennt wird

    selektiere = ""
    ' Sonderfall i<0 bedeutet, ich will den i.letzten Teilstring
    If i < 0 Then
        i = SAnzahl(s, a) + i + 2
    End If
    
    ' i muß (nach obiger Anpassung) größer als Null sein
    If i <= 0 Then Exit Function
    s2 = -Len(a) + 1
    Do
        s1 = s2 + Len(a)
        s2 = InStr(s1, s, a)
        
        ' InStr gibt Null zurück, wenn Suchstring nicht gefunden wird
        If s2 = 0 Then s2 = Len(s) + 1
        i = i - 1
    Loop Until i = 0

    ' s1 ist dann größer als s2, wenn ein Teil selektiert
    ' werden soll, der gar nicht mehr in der Zeile existiert
    ' (z.B. das 5. von 4 Feldern)
    If s1 > s2 Then Exit Function
    
    ' Rückgabewert ist der Teilstring zwischen s1 und s2
    ret = Mid$(s, s1, s2 - s1)
    If Left$(ret, 1) = Chr$(34) Then ret = Mid$(ret, 2)
    If Right$(ret, 1) = Chr$(34) Then ret = Left$(ret, Len(ret) - 1)
    
    selektiere = ret
End Function

Public Function LetztZeilen(Ganz, LZeilen)
'In einem Bericht sollen immer die letzten 5-10 Zeilen von einem Memofeld
'gedruckt werden. Wie kann ich dies einfach anstellen.

'Vielleicht geht 's ja einfacher, aber ich würde es mit einer Funktion lösen.

'In der Abfrage, die als Datenherkunft deines Berichtes dient,
'schreibst du in eine Spalte den Aufruf:
'
'LetztZeilen([DeinFeld];5)
'
'Damit bekommst du z.B. die letzten 5 Zeilen des Feldes.

'Achtung, wenn der Anwender kein "hartes" <Return> eingegeben hat, wird
'der ganze Schmonzes zurückgegeben.
'******************** CODE START **********************
' gibt die letzten LZeilen eines Feldes zurück
' von Karl Donaubauer 2.1.1999

If IsNull(Ganz) Or IsNull(LZeilen) Then Exit Function
Dim i As Integer, j As Integer
i = 1
Do Until InStr(i, Ganz, vbCrLf) = 0
    i = InStr(i, Ganz, vbCrLf) + 1
    j = j + 1
Loop
If j >= LZeilen Then
    i = 1
    For j = 0 To j - LZeilen
        i = InStr(i, Ganz, vbCrLf) + 1
    Next j
    LetztZeilen = Mid(Ganz, i + 1)
Else
    LetztZeilen = Ganz
End If
End Function
'******************** CODE ENDE **********************

Sub ApplSetSub()
'Options für Runtime-Umgebung setzen

    Application.SetOption "Confirm Record Changes", False
    Application.SetOption "Confirm Document Deletions", False
    Application.SetOption "Confirm Action Queries", False
    Application.SetOption "Show Hidden Objects", False
    Application.SetOption "Show System Objects", False
    Application.SetOption "Show Status Bar", True
    Application.SetOption "Arrow Key Behavior", 1
    Application.SetOption "Move After Enter", 1
    Application.SetOption "Cursor Stops at First/Last Field", True
    Application.SetOption "Default Record Locking", 0
    Application.SetOption "Default Open Mode for Databases", 0
    Application.SetOption "Ignore DDE Requests", True

End Sub


Function ReplaceStr(Textin, SearchStr, Replacement, Optional CompMode As Integer = 2)
'
' Replaces the SearchStr string with Replacement string in the TextIn string.
' Uses CompMode to determine comparison mode
' Aus der Neatcd97.mdb Microsoft
'
Dim WorkText As String, Pointer As Integer
  If IsNull(Textin) Then
    ReplaceStr = Null
  Else
    WorkText = Textin
    Pointer = InStr(1, WorkText, SearchStr, CompMode)
    Do While Pointer > 0
      WorkText = Left(WorkText, Pointer - 1) & Replacement & Mid(WorkText, Pointer + Len(SearchStr))
      Pointer = InStr(Pointer + Len(Replacement), WorkText, SearchStr, CompMode)
    Loop
    ReplaceStr = WorkText
  End If
End Function

Function CRtoASCII(Textin) As Variant
' Ersetzen aller CRLF durch den String $%&CRLF%&
'Rückgabe als Variant, um einen NullString übergeben zu können, im Falle
'"AllowZeroLength" auf False gesetzt ist
    Dim suche As String
    On Error Resume Next
    CRtoASCII = Null
    If Len(Trim(Nz(Textin))) > 0 Then
        suche = CStr(Chr(13) & Chr(10))
        CRtoASCII = Nz(ReplaceStr(Nz(Textin), suche, "$%&CRLF%&"))
    End If
End Function

Function ASCIItoCR(Textin) As Variant
' Ersetzen aller Strings $%&CRLF%& durch CRLF
'Rückgabe als Variant, um einen NullString übergeben zu können, im Falle
'"AllowZeroLength" auf False gesetzt ist
    Dim Erse As String
    On Error Resume Next
    ASCIItoCR = Null
    If Len(Trim(Nz(Textin))) > 0 Then
        Erse = CStr(Chr(13) & Chr(10))
        ASCIItoCR = ReplaceStr(Nz(Textin), "$%&CRLF%&", Erse)
    End If
End Function


Function LFtoCRLF(Textin) As Variant
    Dim Erse As String
    On Error Resume Next
    LFtoCRLF = Null
    If Len(Trim(Nz(Textin))) > 0 Then
        LFtoCRLF = ReplaceStr(Nz(Textin), Chr(10), Chr(13) & Chr(10))
    End If
End Function


Public Function pfadkuerzen(pfad As String, Optional linksstart As Integer = 30, Optional rechtsstart As Integer = 40, Optional sTrenner As String = "\") As String
'Autor: Thomas Klahr - www.freeaccess.de - klahr@freeaccess.de
Dim temp
Dim sTrennPkt As String
Dim links, rechts As String
'linksstart = 30 ' Gibt an ab welchem Zeichen er von links nach / sucht, und kürzt danach
'rechtsstart = 40 ' Gibt an ab welchem Zeichen er von rechts nach / sucht, und kürzt davor
'Die Länge des resultierenden Strings beträgt also im Mittel
'linksstart + rechtsstart + 4(für den Platzhalter ".../")

sTrennPkt = "..." & sTrenner

If Len(Nz(pfad, "")) < (linksstart + rechtsstart + 4) Then
    pfadkuerzen = pfad
    Exit Function
Else
    Do Until InStr(linksstart, pfad, sTrenner) <> 0
        linksstart = linksstart + 1
    Loop
    Do Until InStr(Len(pfad) - rechtsstart, pfad, sTrenner) <> 0
        rechtsstart = rechtsstart + 1
    Loop
    links = Left$(pfad, InStr(linksstart, pfad, sTrenner))
    'Pfad = Right$(Pfad, Len(Pfad) - InStr(linksstart, Pfad, sTrenner))
    rechts = Right$(pfad, Len(pfad) - InStr(Len(pfad) - rechtsstart, pfad, sTrenner))
    pfadkuerzen = links & sTrennPkt & rechts
End If
End Function

Function Proper(x)
' Funktion aus der Neatcd97.mdb von MS
'  Capitalize first letter of every word in a field.
'  Use in an event procedure in AfterUpdate of control;
'  for example, [Last Name] = Proper([Last Name]).
'  Names such as O'Brien and Wilson-Smythe are properly capitalized,
'  but MacDonald is changed to Macdonald, and van Buren to Van Buren.
'  Note: For this function to work correctly, you must specify
'  Option Compare Database in the Declarations section of this module.
'
'  See Also: StrConv Function in the Microsoft Access 97 online Help.

Dim temp$, c$, OldC$, i As Integer
  If IsNull(x) Then
    Exit Function
  Else
    temp$ = CStr(LCase(x))
    '  Initialize OldC$ to a single space because first
    '  letter needs to be capitalized but has no preceding letter.
    OldC$ = " "
    For i = 1 To Len(temp$)
      c$ = Mid$(temp$, i, 1)
      If c$ >= "a" And c$ <= "z" And (OldC$ < "a" Or OldC$ > "z") Then
        Mid$(temp$, i, 1) = UCase$(c$)
      End If
      OldC$ = c$
    Next i
    Proper = temp$
  End If
End Function



Function Uml2Win(ByVal x As String, ASC2WIN As Boolean) As Variant
''**********************************************************************************
'' Deklarationen
''**********************************************************************************
' ' PC (DOS) --> Ansi (Win)
'  Declare PtrSafe Function OemToChar Lib "user32" Alias "OemToCharA" (ByVal lpszSrc As String, ByVal lpszDst As String) As Long
' ' Ansi (Win) --> PC (DOS)
'  Declare PtrSafe Function CharToOem Lib "user32" Alias "CharToOemA" (ByVal lpszSrc As String, ByVal lpszDst As String) As Long
''**********************************************************************************
'' Aufruf:
''  DOS --> Win
''  Ergebnis = Uml2Win(DeinString, True)
''  Win --> DOS
''  Ergebnis = Uml2Win(DeinString, False)

Dim nix, xx As String
Uml2Win = Null
If Len(Trim(Nz(x))) > 0 Then
    x = x & Chr(0)
    xx = Space(Len(x))
    If ASC2WIN = True Then
        nix = OemToChar(x, xx)
    Else
        nix = CharToOem(x, xx)
    End If
    If Right(xx, 1) = Chr(0) Then
        Uml2Win = Left(xx, Len(xx) - 1)
    Else
        Uml2Win = xx
    End If
End If
End Function


Function HexStr(AscString As String) As String
'Ausgabe "ÄÖÜ" als "C4 D6 DC"
Dim i As Integer
HexStr = ""
If Len(Trim(Nz(AscString))) = 0 Then Exit Function
For i = 1 To Len(AscString)
    HexStr = HexStr & Hex(Asc(Mid(AscString, i, 1))) & " "
Next i
HexStr = Trim(HexStr)
End Function

Function UnHexStr(HexString As String) As String
'Ausgabe "C4 D6 DC" als "ÄÖÜ" - HexStr rückwärts ...
Dim i As Integer
UnHexStr = ""
If Len(Trim(Nz(HexString))) = 0 Then Exit Function
For i = 1 To Len(HexString) Step 3
    UnHexStr = UnHexStr & Chr$("&H" & Trim(Mid(HexString, i, 3)))
Next i
End Function

Function DabaEinAus(Optional Einblenden As Boolean = True)
'Datenbankfenster ein/ausblenden
'Autor: Karl Donaubauer (FAQ)
'Rückgabe True / False, True bei erfolgreicher Ausführung der Function
On Error GoTo DabaEinAus_err
DabaEinAus = True
If Einblenden Then
    'Einblenden:
    DoCmd.SelectObject acTable, , True
Else
    'Ausblenden:
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide
End If
Exit Function
DabaEinAus_err:
DabaEinAus = False
End Function


Function OpenMacro(macroName As String) As Boolean
'Autoren: Christa Schwanke UND Karl Donaubauer
On Error GoTo OpenMacro_Err

If Len(Trim(Nz(macroName))) = 0 Then
    OpenMacro = False
    Exit Function
End If
DoCmd.SelectObject acMacro, macroName, True
'Geht leider nicht anders
SendKeys "^~", True
OpenMacro = True
Exit Function

OpenMacro_Err:
OpenMacro = False

End Function

Public Function SafeSQLString(Text As Variant) As Variant
On Error GoTo Err_SafeSQLString
    Const Quote = """"      ' That's 4 quotation marks in a row.
          
    If IsNull(Text) Then
        SafeSQLString = Quote & Quote
    Else
        If Not (Left(Text, 1) = """" And Right(Text, 1) = """") Then
            SafeSQLString = Quote & ReplaceStr(Text, Quote, Quote & Quote) & Quote
        Else
            SafeSQLString = Text
        End If
    End If
          
Exit_SafeSQLString:
    Exit Function
          
Err_SafeSQLString:
    SafeSQLString = ""
    Resume Exit_SafeSQLString
          
End Function


Function SystemMdwPath() As String
    SystemMdwPath = DBEngine.SystemDB
End Function


Function RandomWert(Optional ByVal IPwd_lng As Byte = 10, Optional iTextTyp As Long = 0) As String
'Texttyp = 0 Alle (33 bis 126)
'Texttyp = 1 Nur Zahl (48 - 57)
'Texttyp = 2 Nur Großbuchstaben (65 - 90)
'Texttyp = 3 Nur Kleinbuchstaben (97 - 122)

Dim Obergrenze As Integer
Dim Untergrenze As Integer
Dim Wert1 As Integer

Dim i As Integer
Dim strx As String
strx = ""

' Verwenden Sie die folgende Formel, um ganzzahlige Zufallszahlen innerhalb eines bestimmten
' Bereichs zu erzeugen:
' Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
' Obergrenze steht hier für die größte Zahl des Bereichs und Untergrenze für die kleinste Zahl des Bereichs.

Select Case iTextTyp

    Case 1
        Untergrenze = 48
        Obergrenze = 57

    Case 2
        Untergrenze = 65
        Obergrenze = 90

    Case 3
        Untergrenze = 97
        Obergrenze = 122

    Case Else
        Untergrenze = 33 ' Ascii-Wert 33
        Obergrenze = 126 ' Ascii-Wert 126

End Select

'Es werden alle Zeichen zwischen Dec. 33 und 126 wahlfrei erzeugt
Randomize

For i = 1 To IPwd_lng
    Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
    strx = strx & Chr$(Wert1)
Next i

RandomWert = strx

End Function

Function RandomPasswort(Optional ByVal IPwd_lng As Byte = 10, Optional Dummywert As Variant) As String

Dim Obergrenze As Integer
Dim Untergrenze As Integer
Dim Wert1 As Integer

' Bei Abfragen immer die ID des Datensatzes als Dummy mit übergeben, da nur dann der
' Access-Optimierer (überlistet wird und) die Abfrage für jede Zeile widerholt ausführt

If IPwd_lng < 5 Or IPwd_lng > 12 Then IPwd_lng = 10

Dim i As Integer
Dim strx As String
strx = ""

'Dim Obergrenze As Integer
'Dim Untergrenze As Integer

' Verwenden Sie die folgende Formel, um ganzzahlige Zufallszahlen innerhalb eines bestimmten Bereichs zu erzeugen:
' Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
' Obergrenze steht hier für die größte Zahl des Bereichs und Untergrenze für die kleinste Zahl des Bereichs.

Obergrenze = 126 ' Ascii-Wert 126
Untergrenze = 33 ' Ascii-Wert 33

'Es werden alle Zeichen zwischen Dec. 33 und 127 wahlfrei erzeugt
Randomize

For i = 1 To IPwd_lng
    Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
    strx = strx & Chr$(Wert1)
Next i

RandomPasswort = strx

End Function

Function RndLongWert(Optional Untergrenze As Long = 0, Optional Obergrenze As Long = 6, Optional Dummywert As Variant) As Long

' Bei Abfragen immer die ID des Datensatzes als Dummy mit übergeben, da nur dann der
' Access-Optimierer (überlistet wird und) die Abfrage für jede Zeile widerholt ausführt

'Dim Obergrenze As Integer
'Dim Untergrenze As Integer

' Verwenden Sie die folgende Formel, um ganzzahlige Zufallszahlen innerhalb eines bestimmten Bereichs zu erzeugen:
' Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
' Obergrenze steht hier für die größte Zahl des Bereichs und Untergrenze für die kleinste Zahl des Bereichs.

'Obergrenze = 126 ' Ascii-Wert 126
'Untergrenze = 33 ' Ascii-Wert 33

'Es werden alle Zeichen zwischen Dec. 33 und 127 wahlfrei erzeugt

Randomize

RndLongWert = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)

End Function



Public Function ValidFilename(Name As String, Optional char As String) As Boolean
    On Error Resume Next
    Dim NotAllowed
    NotAllowed = Array("<", ">", ":", "/", "\", "|", Chr(34), "'", "CON", _
        "PRN", "AUX", "CLOCK$", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", _
        "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", _
        "LPT5", "LPT6", "LPT7")
    ValidFilename = True
    Dim i As Integer
    Dim s As String
    For i = 0 To 7
        If InStr(Name, NotAllowed(i)) Then
            ValidFilename = False
            char = NotAllowed(i)
            Exit Function
        End If
    Next i
    i = InStrRev(Name, ".")
    s = Mid(Name, 1, i - 1)
    For i = 8 To 28
        If NotAllowed(i) = UCase(s) Or UCase(Name) = NotAllowed(i) Then
            ValidFilename = False
            char = NotAllowed(i)
            Exit Function
        End If
    Next i

End Function

Function mdbVersion(strDB_file As String) As String

' Currentdb.Properties("AccessVersion")
' liefert ebenfalls die Access-Version der MDB

    Const VERSION_STRING_SIZE As Integer = 24
    Const JET_2_VERSION_NUMBER_START As Integer = 1
    Const JET_VERSION_NUMBER_START As Integer = 21
    Const Length As Integer = 1

    Dim lngSource As Integer
    Dim strData As String
    
    If Len(Trim(Nz(strDB_file))) > 0 Then
        If Len(Dir(strDB_file)) = 0 Then
            mdbVersion = "no valid File"
            Exit Function
        End If
    Else
        mdbVersion = "no File"
        Exit Function
    End If
        
    lngSource = FreeFile
    Open strDB_file For Binary As lngSource
    strData = Space(VERSION_STRING_SIZE)
    Get #lngSource, , strData
    Close lngSource
    
    If Chr(1) = Mid(strData, JET_2_VERSION_NUMBER_START, _
       Length) Then
        mdbVersion = "Access 2"
    ElseIf Chr(0) = Mid(strData, JET_VERSION_NUMBER_START, _
       Length) Then
        mdbVersion = "Access 97"
    ElseIf Chr(1) = Mid(strData, JET_VERSION_NUMBER_START, _
       Length) Then
        mdbVersion = "Access 2000/2002"
    Else
        mdbVersion = "Unknown"
    End If
                
End Function

'**************************************
' Name: [Ace] WinzipIT
' Description:Simple code to zip/unzip w
'     ith Winzip
' By: renyi[ace]
'
' Inputs:'Example:
'source = app.path & "source.exe"
'target = app.path & "target.zip"
'zip = true (compress)
'zip = false(uncompress)
'
' Assumes:that you have winzip, :)
'
' Side Effects:'I'm having problem with
'     windows path.
'winzip doesn't recognize spaces, :(
'anyone got ideas ? pls mail me.........
'     .
'
'This code is copyrighted and has' limited warranties.Please see http://w
'     ww.Planet-Source-Code.com/xq/ASP/txtCode
'     Id.14063/lngWId.1/qx/vb/scripts/ShowCode
'     .htm'for details.'**************************************

'---------
'WinZipIT
'---------


'Function winZipit(ByVal source As String, ByVal target As String, ByVal Zip As Boolean)
'    zipIT = App.Path & "winzip32 -a"
'    unzipIT = App.Path & "winzip32 -e "
'
'
'    If Zip = True Then
'        Shell (zipIT & target & source)
'    Else: Shell (unzipIT & target & source)
'    End If
'End Function


''**************************************
'' Name: About the "Compressing Files thr
''     u VB(w/WinZip)"
'' Description:this is actually not a cod
''     e but this is just a list of parameters
''     to use WinZip in VB.. I hope this will h
''     elp those who are interested in my previ
''     ous posting namely: "Compressing Files t
''     hru VB(w/WinZip)"
'' By: Jaeger
''
'' Assumes:you have read my previous post
''     ing.. the "Compressing Files thru VB(w/W
''     inZip)"
''
''This code is copyrighted and has' limited warranties.Please see http://w
''     ww.Planet-Source-Code.com/xq/ASP/txtCode
''     Id.4696/lngWId.1/qx/vb/scripts/ShowCode.
''     htm'for details.'**************************************
'
'Adding Files:
'The command format is:
'winzip[32].exe [-min] action [options] filename[.zip] files
'where:
'-min specifies that WinZip should run minimized. If -min is specified,
'it must be the first command line parameter.
'Action
'-a For add, -f for freshen, -u for update, and -m for move. These
'actions correspond To the actions described In the section titled
'"Adding files To an Archive" in the online manual.
'Options
'-r and -p correspond To the "Recurse Directories" and "Save Extra
'Directory Info" checkboxes in the Add and Drop dialog boxes. -ex, -en,
'-ef, -es, and -e0 options determine the compression method: eXtra,
'Normal, Fast, Super fast, and no compression. The default is "Normal".
'-s allows specification of a password. The password can be enclosed
'In quotes, For example, -s"Secret Password". Note that passwords are
'case-sensitive.
'-hs option allows hidden and system files To be included.
'FileName.zip
'Specifies the name of the ZIP involved. Be sure To use the full
'filename (including the directory).
'Files
'Is a list of one or more files, or the @ character followed by the
'filename containing a list of files To add, one filename per line.
'Wildcards (e.g. *.bak) are allowed.
'Extracting Files:
'The command format is:
'winzip[32].exe -e [options] filename[.zip] directory
'where:
'-e Is required.
'Options
'-o and -j stand For "Overwrite existing files without prompting" and
'"Junk pathnames", respectively. Unless -j is specified, directory
'information is used.
'-s allows specification of a password. The password can be enclosed
'In quotes, For example, -s"Secret Password". Note that passwords are
'case-sensitive.
'FileName.zip
'Specifies the name of the ZIP involved. Be sure To specify the full
'filename (including the directory).
'directory
'Is the name of the directory to which the files are extracted. If the
'directory does Not exist it is created.
'Notes:
'* VERY IMPORTANT: Always specify complete filenames, including the full
'path name and drive letter, For all file IDs.
'* To run WinZip in a minimized inactive icon use the "-min" option.
'When specified this option must be the first option.
'* Only operations involving the built-in zip and unzip are supported.
'* Enclose Long filenames on the command line in quotes.
'* NO leading or trailing blanks, or blank lines For readability, are
'allowed In list ("@") files.
'* The action and Each option on the command line must be separated
'from the others by at least one space.
'* WinZip can be used To compress files With cc:Mail . Change the
'compress= line in the [cc:Mail] section of the appropriate WMAIL.INI
'files To specify the full path For WinZip followed by "-a %1 @%2".
'
'
'For example, If WinZip is installed in your c:\winzip directory,
'    specify
'    compress=c:\winzip\winzip.exe -a %1 @%2



Function GetGroup(Server As String)
  ' von Christian Janik
  ' leicht modifiziert von Mark Doerbandt
  Dim wmi, wql, result, entry
'  server = "Servername" ' anpassen
  Set wmi = GetObject("winmgmts:\\" & Server)
  If Err.Number <> 0 Then
    MsgBox "wmi nicht einsatzbereit."
  Else
    wql = "select * from win32_Group"
    Set result = wmi.ExecQuery(wql)
    For Each entry In result
      MsgBox entry.Sid
    Next
  End If
End Function

