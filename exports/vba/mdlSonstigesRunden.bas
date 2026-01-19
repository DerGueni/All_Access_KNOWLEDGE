Attribute VB_Name = "mdlSonstigesRunden"
Option Compare Database
Option Explicit

'#########################################################################################################

'   AufXStellenRunden  - Runden (MSKB)
'   LIB_WaehrungRunden - Auf 2 Nachkommastellen runden
'   FA_Runden          - Runden mit Fehlerkorrektur von www.Fullaccess.de
'   fctRound           - Runden aus FAQ
'   runden             - Und noch eine Rundungsfunktion
'   fctRappenRunden    - Runding auf 0,05 (für die Schweizer)
'   Abrunden           - Abrunden mittels Excel
'   Aufrunden          - Aufrunden mittels Excel
'   Testtage           - 360 Tage Berechnung (Bankzinsen) mittels Excel
'   Sieb_Des_Eratosthenes - Primzahlen errechnen
'   PrimStatus         - Ist eine Zahl eine Primzahl ?
'   Phyt               - Ausgabe aller Zahlen (bis 80), bei denen c lt. Phytagoras (a^2 + b^2 = c^2) ein Integerwert ist
'   Zufallszahl        - Ausgabe einer Zufallszahl (Ganzzahl)
'#########################################################################################################

Function AufXStellenRunden(varZahl As Variant, intStellen As Integer) As Double

'Mit Hilfe dieser Funktion können Sie eine Zahl auf eine beliebige Stelle
'runden. Maximal können 15 Ziffern (Ziffern vor dem Komma + Ziffern nach dem
'Komma <= 15 Ziffern) dargestellt werden.
'Der Übergabeparameter "varZahl" stellt die zu rundende Zahl dar.
'Die Variable "intStellen" gibt an, auf wieviel Stellen nach (positive Zahl)
'bzw. vor (negative Zahl) dem Komma gerundet werden soll.
'Aus der deutschen MSKB

Dim x As Double
Dim dblErgebnis As Double
Dim Zahlzwi As Double
Dim Neg As Boolean

On Error GoTo Error_Handler

If varZahl < 0 Then
    Zahlzwi = varZahl * -1
    Neg = True
Else
    Zahlzwi = varZahl
    Neg = False
End If

If IsNull(Zahlzwi) Then
    dblErgebnis = 0
Else
' wenn negative Zahl, dann muß der absolute Wert genommen werden
    If intStellen < 0 Then
        x = 10 ^ (Abs(intStellen))
        dblErgebnis = Int(Zahlzwi / x + 0.5) * x
    Else
        x = 10 ^ intStellen
        dblErgebnis = Int(Zahlzwi * x + 0.5) / x
    End If

End If

If Neg Then
    dblErgebnis = dblErgebnis * -1
End If

AufXStellenRunden = dblErgebnis

Exit_AufXStellenRunden:
Exit Function

Error_Handler:

MsgBox "Der Fehler '" & Error(Err) & "' trat beim Runden auf."
AufXStellenRunden = varZahl

Resume Exit_AufXStellenRunden

End Function


Public Function LIB_WaehrungRunden(varZahl As Variant) As Double
'Diese Funktion soll LIB_AufXStellenRunden ersetzen.
'Die Funktion rundet für zwei Nachkommastellen korrekt.
'von H.Langer

Dim x As Double
Dim dblErgebnis As Double
Dim hcur As Double
Dim hint As Integer

On Error GoTo LIB_WaehrungRunden_Error_handler

If IsNull(varZahl) Then
dblErgebnis = 0
Else
    hcur = varZahl - Int(varZahl)
    hcur = hcur * 1000
    hint = hcur Mod 10
    If hint = 5 Then
        If varZahl < 0 Then
            varZahl = varZahl - 0.001
          Else
            varZahl = varZahl + 0.001
        End If
    End If

dblErgebnis = Int(varZahl * 100 + 0.5) / 100
End If

LIB_WaehrungRunden = dblErgebnis

Exit_LIB_WaehrungRunden:
Exit Function

LIB_WaehrungRunden_Error_handler:
MsgBox "Der Fehler '" & Error(Err) & "' trat beim Runden auf."
LIB_WaehrungRunden = varZahl
Resume Exit_LIB_WaehrungRunden

End Function


Public Function FA_Runden(Wert As Variant, Optional Rundungszahl As Double = 0.01) As Variant
' Von www.fullaccess.de
'Mit dem ersten Funktionsparameter übergeben Sie der Funktion den Wert, der
'gerundet werden soll. Der Parameter Rundungszahl bestimmt die Kommastelle,
'auf die gerundet wird. Die Funktion gibt die gerundete Zahl zurück.
'Wenn Sie eine Zahl auf die zweite Nachkommastelle runden möchten geben Sie als
'Rundungszahl 0,01 ein.
    
Dim res As Variant
Dim dberg As Double

    FA_Runden = Null
    If IsNull(Wert) Then Exit Function
        
    res = (Wert / Rundungszahl)

     dberg = CLng(res + IIf(Wert > 0, 0.000000000001, -0.000000000001)) * Rundungszahl
     If dberg <> 0 Then
        FA_Runden = dberg
     End If

End Function

Function Runden(Zahl As Variant, Optional AnzahlStellen As Integer = 2) As Double
'Autor: jörg stephan
'syskoplan GmbH
'Ahrensburger Str. 5, D-30659 Hannover
'tel.     +49 (511) 902 91-0
'fax    +49 (511) 902 91-99
'mailto: joerg.stephan@ syskoplan.de
'http://www.syskoplan.de

  Dim temp As Double, Zehnerpotenz As Long
  temp = CDbl(Zahl)
  Zehnerpotenz = 10 ^ AnzahlStellen
  Runden = (Fix((temp + 0.5 / Zehnerpotenz) * Zehnerpotenz)) / Zehnerpotenz
End Function


Function fctround(varNr As Variant, Optional varPl As Integer = 2) As Double
 'by Konrad Marfurt + ("" by) Luke Chung + Karl Donaubauer
    'raus hier bei nicht-nummerischem Argument
    If Not IsNumeric(varNr) Then Exit Function
    fctround = Fix("" & varNr * (10 ^ varPl) + Sgn(varNr) * 0.5) / (10 ^ varPl)
End Function

Function fctRappenRunden(varBetrag As Variant) As Variant
' verwendet fctRound
fctRappenRunden = fctround((varBetrag * 20), 0) / 20
End Function

'Günther Ritter (www.ostfrieslandweb.de) meinte einst in einer FAQ zu Excel:
'Auf- oder abrunden in ACCESS97 mit EXCEL
'
'Nun, eigentlich ganz einfach. Nur bisher wenig bekannt: In A97 stehen auch die Funktionen von EXCEL zur
'Verfügung. Und nicht nur in A97, es funktioniert auch in A95.
'Damit es funktioniert, ist es erforderlich im Modul unter Extras/Verweise den Verweis auf die
'EXCEL 8.0 Object Library anzukreuzen. Das ist übrigens die EXCEL8.OLB! Und wie gesagt, ein Verweis
'darauf wird auch von A95 akzeptiert!
'a=Wert, b=Anzahl Stellen

Function Abrunden(a, b)
'a=Wert, b=Anzahl Stellen
'Abrunden = Excel.WorksheetFunction.RoundDown(A, B)
End Function

Function Aufrunden(a, b)
'a=Wert, b=Anzahl Stellen
'Aufrunden = Excel.WorksheetFunction.RoundUp(A, B)
End Function

Function Testtage(a As Date, b As Date)
'A = Von Datum  B = Bis Datum
'Testtage = Excel.WorksheetFunction.Days360(A, B, True)
End Function


'Gepostet von Guido Ledermann (gledermann@bgt-bretten.de)
'hier eine Routine zum Sieb. Sie ist nicht schön, nicht schnell, aber sie ist
'genau der Algorithmus, wie er von dem Griechen (war er das???) beschrieben wurde.

Sub Sieb_Des_Eratosthenes(ByVal WieWeitWillstDuEsDenn As Long)
    ReDim sand(WieWeitWillstDuEsDenn) As Long
    Dim n As Long
    Dim m As Long

    'Zahlensand erstellen
    For n = 1 To WieWeitWillstDuEsDenn
        sand(n) = n
    Next
    ' Dann alle die durch 2 teilbar sind rauswerfen
    For n = 1 To WieWeitWillstDuEsDenn
        If sand(n) Mod 2 = 0 Then
            Debug.Print sand(n) & " fliegt raus"
            sand(n) = 0
        End If
    Next

    ' nun kommt der iterative teil
    n = 2
    ' die nächste primzahl suchen
    Do
        n = n + 1
        ' wenn wir die primzahl haben, die größer ist als die quadratwurzel der größten zahl
        ' die wir untersuchen können wir aufhören
        If n > Sqr(WieWeitWillstDuEsDenn) Then Exit Do
        If sand(n) <> 0 Then
            Debug.Print "alle durch " & sand(n) & " teilbaren zahlen fliegen jetzt raus"
    ' alle größeren zahlen nun prüfen, ob sie durch diese primzahl teilbar sind
            m = n + 1
            Do
    ' wenn sie teilbar ist, dann aussieben...
                If m > WieWeitWillstDuEsDenn Then Exit Do
                If sand(m) Mod sand(n) = 0 And sand(m) <> 0 Then
                    'Debug.Print sand(m) & " fliegt raus"
                    DoEvents
                    sand(m) = 0
                End If
                m = m + 1
            Loop
        End If
    Loop

    For n = 1 To WieWeitWillstDuEsDenn
        If sand(n) <> 0 Then Debug.Print "primzahl=" & sand(n)
    Next
End Sub

Function PrimeStatus(TestVal As Long) As Boolean
' Ist eine Zahl eine Primzahl ?
    Dim i As Long
    Dim Lim As Long 'Integer
    If TestVal < 5 Then Exit Function
    PrimeStatus = True
    Lim = Sqr(TestVal)
    For i = 3 To Lim Step 2
       If TestVal Mod i = 0 Then
          PrimeStatus = False
          Exit For
       End If
       If i Mod 201 = 0 Then DoEvents
    Next i

End Function



Function Phyt()
'Ausgabe aller Zahlen (bis 80), bei denen c lt. Phytagoras (a^2 + b^2 = c^2) ein Integerwert ist.
Dim a As Integer, b As Integer, c As Double

For a = 1 To 60
  For b = 1 To 80
    c = Sqr(a ^ 2 + b ^ 2)
      If c = Int(c) Then
        Debug.Print str(a) & "^2 +" & str(b) & "^2 =" & str(c) & "^2"
      End If
  Next b
Next a

End Function

 'Kreiszahl Pi als Konstante definieren:
' Const Pi As Double = 3.14159265358979

 'ODER: Pi berechnen lassen:
 Function PI() As Double
   PI = Atn(1) * 4#
 End Function

 'Umrechnung Grad in Bogenmaß:
' Autor: Jost Schwider
 Function Rad(ByVal Grad As Double) As Double
   '2 Pi entsprechen 360 Grad:
   Rad = PI * Grad / 180
 End Function

' Dann kannst Du in Deinen Berechnungen mit Grad arbeiten:
'   Print Sin(Rad(90))
'   '--> ergibt 1!
'
' Oder Du definierst Dir eine Konstante "Rad", die direkt
' den Umrechnungsfaktor angibt:
'   Const Rad As Double = 1.74532925199433E-02
' Dann kannst Du z.B. schreiben:
'   Print Sin(90 * Rad)
'   '--> ergibt immer noch 1!   ;-)


Private Function CMYK2RGB&(ByVal c!, ByVal m!, ByVal y!, ByVal k!)
'Autor: Newsgroup Olaf Schmidt
'ich suche eine Möglichkeit, CYMK-Farbwerte in RGB umzurechnen, da in VB
'ja nur RGB-Farbwerte verwendet werden können. Gibt es dafür eine API-
'Funktion (eine interne habe ich in VB5 nicht gefunden).
Dim r%, G%, b%
  If (c + k) < 255 Then r = 255 - (c + k)
  If (m + k) < 255 Then G = 255 - (m + k)
  If (y + k) < 255 Then b = 255 - (y + k)
  CMYK2RGB = RGB(r, G, b)
End Function


'*******************************************************************************
' Methode:      PrueffzifferModulo10()
' Autor:        André Hürst 25.09.1997
' Parameter:    strPruefling: zu prüfende Zeichen als Zeichenkette.
' Verwendung:   Ermittelt die Prüfziffer anhand einer Zeichenkette. Die
'               Prüfziffer wird mittels Modulo 10 rekursiv bestimmt.
'*******************************************************************************
Public Function PrueffzifferModulo10(strPruefling) As String
    Dim x As Integer
    Dim intUebertrag As Integer
    Const strVektor = "0946827135"

    On Error Resume Next

    intUebertrag = 0
    For x = 1 To Len(strPruefling)
        intUebertrag = CInt(Mid(strVektor, (CInt(Mid(strPruefling, x, 1)) _
            + intUebertrag) Mod 10 + 1, 1))
    Next x
    If intUebertrag = 0 Then
        PrueffzifferModulo10 = CStr(intUebertrag)
    Else
        PrueffzifferModulo10 = CStr(10 - intUebertrag)
    End If
End Function


Function stabw(W1, W2, W3, W4) As Double 'event. auch mit dem "container"-Objekt arbeiten
'Autor: Sönke Peterson
    Dim drs As Double 'durchschnitt
    drs = (W1 + W2 + W3 + W4) / 4
    stabw = ((drs - W1) + (drs - W2) + (drs - W3) + (drs - W4)) / 4
End Function

Public Function FeldFuellFix(InputFeld As Variant, ByVal InpFeldLen As Integer, Optional IsZahl As Boolean = False, Optional FeldFormat As Integer = 0, Optional Dummy As Variant) As String
' Autor: Klaus Oberdalhoff - 3.12.1999
' Ver: 1.0
' Diese Funktion gibt einen String fixer Länge (abhängig von der InpFeldLen) zurück
' Diese Funktion ist speziell für den Export von ASCII-Daten fester Länge gedacht
'
' Übergabefelder: InputFeld - das zu "richtende" Feld.
'                 InpFeldLen - gewünschte Feldlänge
'                 IsZahl
'                 FeldFormat
'                 Dummy
'
' Das optionale Feld IsZahl entscheidet darüber, ob mit Nullen oder mit Blanks aufgefüllt wird
' True formatiert mit führenden Nullen, False mit führenden Blanks
' Der Standardwert ist False
'
' Das optionale Feld FeldFormat dient dazu, eine Zahl oder ein Datum "vorzuformatieren"
' Es kann nach eigenem Gusto ausgebaut werden
' FeldFormat = 0 - nix besonderes
'            = 1 - Zahl  fix mit 2 Nachkommastellen: 123456,78  - Feldlänge mindestens 4
'            = 2 - Datum in der Form #yyyy-mm-dd# (ISO-Norm Datum) - Feldlänge = 12
'            = 3 - Datum in der Form #yyyy-mm-dd hh:mm:ss AM/PM# - Feldlänge = 24
'            = 4 - Datum in der Form yyyymmdd - Feldlänge = 8
'            = 5 - Datum in der Form yyyymmddhhmmss - Feldlänge 14
' Feldformat 2 - 5 nur, wenn InputFeld nicht leer ...
' Der Standardwert ist 0
'
' !!!!!!!!!!!!!!!!!!!!!!!!!!!
' Bei Verwendung von Feldformaten werden die Feldlängen überschrieben (Feldformat 2 - 5)
' bzw. auf die erforderliche Mindestlänge von 4 gesetzt wenn kleiner (Feldformat 1)
' !!!!!!!!!!!!!!!!!!!!!!!!!!!
'
' Das Feld optionale Dummy ist gedacht, um diese Funktion auch in Abfragen verwenden zu können,
' damit kann man den Access-intern immer aktiven "Query-Optimizer" austricksen.
' Wenn man an dieses Dummy-Feld den Primary-Key übergibt, dann führt der Optimizer
' diese Funktion bei jedem Durchlauf aus, ansonsten könnte es passieren, daß der
' Optimizer diese Funktion "wegoptimiert" und nicht jedesmal aufruft

Dim TmpOut As String
Dim Null80 As String

'Zum Nullenfüllen - Eine Zahl wird wohl kaum mehr als 80 Stellen lang sein, oder ?
Null80 = "00000000000000000000000000000000000000000000000000000000000000000000000000000000"

'Abbruch bei falscher Feldlänge und keinem Format
If FeldFormat < 1 And InpFeldLen < 1 Then
    FeldFuellFix = ""
    Exit Function
End If

'Input umwandeln in String
If Len(Nz(InputFeld)) = 0 Then
    If FeldFormat = 1 Then
        TmpOut = Format(0, "0.00")
        If InpFeldLen < 4 Then InpFeldLen = 4
    Else
        TmpOut = ""
    End If
Else
'    FeldFormate 2 - 5 greifen nur, wenn InputFeld nicht leer
    TmpOut = CStr(InputFeld)
    If FeldFormat > 0 Then
        Select Case FeldFormat
            Case 1
                If IsNumeric(InputFeld) Then
                    TmpOut = Format(InputFeld, "0.00")
                    If InpFeldLen < 4 Then InpFeldLen = 4
                End If
            Case 2
                If IsDate(InputFeld) Then
                    TmpOut = Format(CDate(InputFeld), "\#yyyy\-mm\-dd\#", vbMonday, vbFirstFourDays)
                    InpFeldLen = 12
                End If
            Case 3
                If IsDate(InputFeld) Then
                    TmpOut = Format(CDate(InputFeld), "\#yyyy\-mm\-dd hh:nn:ss AM/PM\#", vbMonday, vbFirstFourDays)
                    InpFeldLen = 24
                End If
            Case 4
                If IsDate(InputFeld) Then
                    TmpOut = Format(CDate(InputFeld), "yyyymmdd", vbMonday, vbFirstFourDays)
                    InpFeldLen = 8
                End If
            Case 5
                If IsDate(InputFeld) Then
                    TmpOut = Format(CDate(InputFeld), "yyyymmddhhnnss", vbMonday, vbFirstFourDays)
                    InpFeldLen = 14
                End If
            Case Else
        End Select
    End If

End If

'Was tun, wenn Input bereits größer als gewünschte Outputlänge ???????????????
If Len(TmpOut) >= InpFeldLen Then
    FeldFuellFix = Left(TmpOut, InpFeldLen)
    Exit Function
End If

' Eigentlicher Auffüllvorgang
If IsZahl Then  ' mit Nullen füllen
        FeldFuellFix = Right(Null80 & TmpOut, InpFeldLen)
Else    ' mit Space füllen
        FeldFuellFix = Right(Space(InpFeldLen) & TmpOut, InpFeldLen)
End If

End Function

Function fftest()
Dim ss As Double
Dim str As String
Dim dd As Date
Dim ii As Integer
Dim xx As Currency

ss = 123.456
Debug.Print FeldFuellFix(ss, 9, True)
Debug.Print FeldFuellFix(ss, 9, True, 1)
dd = #12/31/1999 2:22:33 PM#
Debug.Print FeldFuellFix(dd, 15, True)
Debug.Print FeldFuellFix(dd, 0, True, 2)
Debug.Print FeldFuellFix(dd, 0, True, 3)
Debug.Print FeldFuellFix(dd, 0, True, 4)
Debug.Print FeldFuellFix(dd, 0, True, 5)
ii = 123
Debug.Print FeldFuellFix(ii, 9, True)
Debug.Print FeldFuellFix(ii, 9, True, 1)
str = "Hugo ist doof"
Debug.Print FeldFuellFix(str, 19)
Debug.Print FeldFuellFix(str, 19, True)
xx = ss + 0.02
Debug.Print FeldFuellFix(xx, 9, True)
Debug.Print FeldFuellFix(xx, 9, True, 1)

End Function

Function Zufallszahl(Untergrenze, Obergrenze) As Long
' Aus der Online-Hilfe
' Verwenden Sie die folgende Formel, um ganzzahlige Zufallszahlen innerhalb
' eines bestimmten Bereichs zu erzeugen:
' Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
' Obergrenze steht hier für die größte Zahl des Bereichs und Untergrenze für
' die kleinste Zahl des Bereichs.
Randomize
Zufallszahl = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
End Function

Public Function GetRange(iRow As Long, iCol As Long, IRowEnd As Long, IColEnd As Long)
If iCol > 26 Then
    GetRange = Chr$(64 + (iCol \ 26)) & Chr$(64 + (iCol Mod 26)) & CStr(iRow)
Else
    GetRange = Chr$(64 + iCol) & CStr(iRow)
End If
GetRange = GetRange & ":"
If IColEnd > 26 Then
    GetRange = GetRange & Chr$(64 + (IColEnd \ 26)) & Chr$(64 + (IColEnd Mod 26)) & CStr(IRowEnd)
Else
    GetRange = GetRange & Chr$(64 + IColEnd) & CStr(IRowEnd)
End If
End Function


Function Kommasuch(ByVal x As Variant) As String
Dim il As Long
Kommasuch = ""
x = Trim(Nz(x))
il = Len(x)
If il = 0 Then
    Exit Function
End If
If Not IsNumeric(x) Then
    Kommasuch = x
    Exit Function
Else
    Kommasuch = Format(x, "0.00")
End If

End Function

