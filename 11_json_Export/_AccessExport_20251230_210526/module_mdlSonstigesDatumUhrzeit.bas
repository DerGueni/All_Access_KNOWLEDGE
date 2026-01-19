Option Compare Database
Option Explicit

'#######################################################################################
' ALLE Datumsfunktionen vereinheitlicht, so daß bei Bedarf der Wochentag einheitlich den
' Wert von Tag 1 = Montag, 2 = Dienstag, ... 7 = Sonntag
' repräsentiert!!!!!!
'#######################################################################################

'   fctKWMon            - Mo der Kalenderwoche input: WW, JJJJJ
'   fctKWMonJJJJWW      - Mo der Kalenderwoche Input: JJJJWW
'   WieAlt              - Anzahl Jahre seit Geburt
'   IstSchaltjahr       - Schaltjahr ja/Nein
'   DateTest            - Datum als Double ausgeben
'   CDateTime           - macht aus dem String # 11-Apr-1999 19:42 AM # einen Datumswert
'   ErsterDesMonats     - Erster Tag des Monats eines Datums
'   LetzterDesMonats    - Letzten Tag des Monats eines Datums
'   XTage               - liefert die Anzahl eines Wochentages im Monat des beliebigen Datums
'   fctKWMon            - gibt den Montag der übergebenen KW zurück - nur europäisches Datum
'   NextDay             - Ausgabe des nächsten Wochentages ZDay, ausgehend von XDatum
'   PreviousDay         - Ausgabe des vorherigen Wochentages ZDay, ausgehend von XDatum
'   MaxWeekNo           - Die Anzahl Wochen des Jahres bzw. die höchste Wochennummer des Jahres
'   WeekFmt             - Rückgabe eines Datums im Format ww/jjjj
'   SQLDatum            - Macht aus irgendeinem gültigen Datum einen String #yyyy-mm-dd# (ISO-Norm Datum)
'   SQLDatum_Long       - Macht aus irgendeinem gültigen Datum einen Long-Wert YYYYMMDD )für AlleTageTabelle)
'   SQLDatum_TSQL       - Macht aus irgendeinem gültigen Datum einen String 'yyyymmdd' (ISO-Norm Datum mit Hochkomma)
'   DateTimeForSQL_TSQL - Macht aus irgendeinem gültigen Datum einen String 'yyyymmdd hh:nn:ss' (ISO-Norm Datum Uhrzeit mit Hochkomma)
'   DateTimeForSQL      - Macht aus irgendeinem gültigen Datum einen String #yyyy-mm-dd hh:mm:ss AM/PM#
'   Datumtext           - Funktion gibt bei gültigem Datum das Datum ansonsten einen Text zurück
'   DatumPrf            - Prüft, ob ein Datum zwischen zwei Datumswerten liegt
'   WochentagImMonat    - Gibt den 1. 2. 3. 4. letzten (5) Wochentag eines Datums zurück
'   Julian2Date         - Umrechnung eines Strings in der Form JJttt oder JJJJttt in ein Datum
'   Date2Julian         - Umrechnung eines Datums zu einem String in der Form JJttt
'   Zeitquarter         - Wie kann ich in einem Feld die nächste Viertelstunde berechnen lassen?
'   Zeitrunden          - Runden einer Zeit
'   StundenAusgabe      - Ausgabe Anzahl Stunden > 24 als Stunden (ohne Umrechnung in Tage)
'   TierKZ              - Das TierKreiszeichen eines bestimmten Datums
'   Jahreszeit          - Gibt die Jahreszeit eines Datums zurück
'   DateDiffW           - Anzahl der Werktage ohne Samstag und ohne Sonntag (OHNE Feiertagsberücksichtigung) - 1
'   AnzWochenTage       - Anzahl der Werktage ohne Samstag und ohne Sonntag (OHNE Feiertagsberücksichtigung)
'   fktIstWochenende    - Ist Wochenende ?
'   Werktag7h           - Wie lange dauert ein Auftrag, wenn die Arbeitszeit 7 h beträgt ?
'   Test_Werktag7h      - Test der Funktion
'   fktAnzWerktage      - Anzahl Werktage (MIT Feiertagsberücksichtigung - Bundeslandabhängig)
'   fktAnzFeiertage     - Die Funktion ermittelt die Anzahl der Feiertage (Mo - Fr - Bundeslandabhängig)
'   fktIstWerktag       - Ist Datum ein Werktag (MIT Feiertagsberücksichtigung - Bundeslandabhängig)
'   fktWelcherFeiertag  - Ausgabe des Feiertagsnamens (oder "") - Bundeslandabhängig - auch bei Wochenenden
'   CreateTblWerktag    - Tabelle mit Werktagen erzeugen
'   OsterSonntagDatum   - Ermittelt den Ostersonntag für ein bestimmtes Jahr
'   VierterAdvent       - Ermittelt den 4. Advent für ein bestimmtes Jahr
'   BusstagDatum        - Ermittelt den Buß- und Bettag für ein bestimmtes Jahr
'   ZeitNachDouble      - etwas komplizierte Zeitrechnung ohne Datumsfunktionen (Zehntelsekunden)
'   DoubleNachZeit      - etwas komplizierte Zeitrechnung ohne Datumsfunktionen (Zehntelsekunden)
'   LongZuZeit          - Sekunden as Long in Zeit umrechnen ...
'   ZeitTest            - Test dieser Funktionen (war früher mdlDatumZeit)
'   IsDateBetween2Dates - Siehe Modul SonstigesJaNein - Ist Datum innerhalb des Zeitraums
'########### Kalenderfunktionen speziell für frmKalender (verwenden viele Standard-Datumsfunktionen)
'   create_Default_AlleTage(strBundesland As String)  - Abfrage "qryAlleTage_Default" mit ausgewähltem Bundesland
'   Datumsetzen1
'   Datum_Neuaufbau
'   Datumsetzen2
'   FeiertageimMonat
'########### Mondphasenberechnung
'   Mondphase_Prom      - Mondphase als 1000-er Zahl (Promille) 0 = Vollmond, 500 = Neumond, 1000 = Vollmond
'   Mondphase           - Mondphase als Text oder Zahl zwischen 1 und 8 (für Bilder in frmKalender)

'   Tage360             - 360-Tageberechnung nach Bankregel

'   fYrweekNo           - Gibt JJJJWW zurück (immer 6-stellig)
'#######################################################################################

Public Global_AufrufCtrl As control
Public Global_PrevCtrl As control

Public Global_iMinute As Long
Public Global_iStunde As Long

Public allWeekNo()
Public allMonNo()
Public allJahrNo()
Public allJahrWeekNo()


'Global_PrevCtrl wird anstelle von PreviousControl verwendet, da PreviousControl hier nicht klappt
'warum weiss ich nicht
'Es wird für den frmKalender benötigt
'Global_AufrufCtrl wird für den frmKalender benötigt
'damit man einfach auch in Unterformularen den Kalender aufrufen kann

Function WieAlt(Geburtsdatum As Date) As Variant
'Dev Ahish
WieAlt = DateDiff("yyyy", Geburtsdatum, Date) + (Format(Date, "mmdd") < Format(Geburtsdatum, "mmdd"))
End Function


Function istSchaltjahr(iJahr As Long) As Boolean
If iJahr < 1900 Then iJahr = Year(Date)
istSchaltjahr = 365 - Format(DateSerial(iJahr, 12, 31), "y", 2, 2)
End Function


Function DateTest(XDatum As Date) As Double
DateTest = XDatum
End Function

Function CDateTime(ByVal XDatStr As String) As Date
'Macht aus einem String der Art #27-Mai-1999 4:29:54 AM # einen Datumswert
Dim xx
xx = XDatStr
If Left(xx, 1) = "#" Then xx = Right(xx, Len(xx) - 1)
If Right(xx, 1) = "#" Then xx = Left(xx, Len(xx) - 1)
CDateTime = CDate(xx)
End Function

Function ErsterDesMonats(Optional ByVal XDatum) As Date
'Gibt den ersten Tag des Monats des übergebenen Datums zurück
'Wenn kein oder ein ungültiges Datum übergeben wurde, dann der Erste des aktuellen Monats
'Autor: Klaus Oberdalhoff  Kobd@gmx.de

If IsMissing(XDatum) Then
    XDatum = Date
End If

If Not IsDate(XDatum) Then
    XDatum = Date
End If

ErsterDesMonats = DateSerial(Year(XDatum), Month(XDatum), 1)

End Function

Function LetzterDesMonats(Optional ByVal XDatum) As Date
'Gibt den letzten Tag des Monats des übergebenen Datums zurück
'Wenn kein oder ein ungültiges Datum übergeben wurde, dann der Letzte des aktuellen Monats
'Autor: Klaus Oberdalhoff  Kobd@gmx.de

If IsMissing(XDatum) Then
    XDatum = Date
End If

If Not IsDate(XDatum) Then
    XDatum = Date
End If

LetzterDesMonats = DateSerial(Year(XDatum), Month(XDatum) + 1, 0)

End Function

Function XTage(Datum As Date, TAG As Byte)
'liefert die Anzahl eines Wochentages im Monat des beliebigen Datums
'Wert von Tag 1 = Montag, 2 = Dienstag, ... 7 = Sonntag
'von Günther Ritter gritter@gmx.de
Dim Tage As Byte, i As Byte
Tage = Day(DateAdd("m", 1, Datum - Day(Datum) + 1) - 1)
For i = 0 To Tage - 1
    If Weekday(DateAdd("d", i, Datum - Day(Datum) + 1), vbMonday) = TAG Then
        XTage = XTage + 1
    End If
Next
End Function

Public Function fctKWMonJJJJWW(JJKW As Long) As Date
Dim i As Long
Dim j As Long
i = Left(JJKW, 4)
j = Right(JJKW, 2)
fctKWMonJJJJWW = fctKWMon(j, i)
End Function

Public Function fctKWMon(ArgKW As Long, Optional ArgJahr) As Date
  'gibt den Montag der übergebenen Kalenderwoche zurück
  'verwendet die in Europa übliche Einstellung: KW 1 = die erste mit 4 Tagen
  'von Karl Donaubauer www.donkarl.com

    Dim m As Date
    If IsMissing(ArgJahr) Then ArgJahr = Year(Date)
    m = DateSerial(ArgJahr, 1, 1) + (ArgKW - 1) * 7
    m = m + 1 - Weekday(m, vbMonday)
    If Format(m, "ww", vbMonday, vbFirstFourDays) <> ArgKW Then m = m + 7
    If (ArgKW = 1 Or ArgKW = 53) And Day(m) > 4 And Day(m) < 8 Then m = m - 7
    fctKWMon = m

End Function


Function NextDay(ZDay As Integer, Optional ByVal XDatum) As Date
'von Jörg Ackermann  A-Soft.Ackermann@t-online.de
'Ausgabe des nächsten Wochentages ZDay, ausgehend von XDatum wobei
'Wert von Tag 1 = Montag, 2 = Dienstag, ... 7 = Sonntag
'Debug.Print NextDay(3) liefert den nächsten Mittwoch von XDatum ausgehend
'Wenn kein gültiges XDatum, dann XDatum = Heute
'Wenn z.B. nach nächstem Mittwoch gesucht wird, und heute ist Mittwoch,
'dann wird "heute" zurückgegeben
Dim i%, td

If IsMissing(XDatum) Then XDatum = Date
If Not IsDate(XDatum) Then XDatum = Date

If Weekday(XDatum, vbMonday) <> ZDay Then
    For i = 1 To 7 Step 1
         td = XDatum + i
         If Weekday(td, vbMonday) = ZDay Then
             NextDay = td
             Exit For
         End If
    Next i
Else
    NextDay = XDatum
End If

End Function

Function PreviousDay(ZDay As Integer, Optional ByVal XDatum) As Date
'von Jörg Ackermann  A-Soft.Ackermann@t-online.de ' angepaßt von K.Obd
'Ausgabe des vorherigen Wochentages ZDay, ausgehend von XDatum wobei
'Wert von Tag 1 = Montag, 2 = Dienstag, ... 7 = Sonntag
'Debug.Print PreviousDay(3) liefert den letzten Mittwoch von XDatum ausgehend
'Wenn kein gültiges XDatum, dann XDatum = Heute
'Wenn z.B. nach letztem Mittwoch gesucht wird, und heute ist Mittwoch,
'dann wird "heute" zurückgegeben
Dim i%, td
      
If IsMissing(XDatum) Then XDatum = Date
If Not IsDate(XDatum) Then XDatum = Date

If Weekday(XDatum, vbMonday) <> ZDay Then
    For i = -1 To -7 Step -1
         td = XDatum + i
         If Weekday(td, vbMonday) = ZDay Then
             PreviousDay = td
             Exit For
         End If
    Next i
Else
    PreviousDay = XDatum
End If

End Function


Function MaxWeekNo(XYear As Variant)
'Die Anzahl Wochen des Jahres bzw. die höchste Wochennummer des Jahres
'K.Obd
MaxWeekNo = Format(DateSerial(XYear, 12, 28), "ww", vbMonday, vbFirstFourDays)
End Function

Function WeekFmt(Optional ByVal XDatum) As String
'Gibt Ein Datum als "ww\jjjj" String zurück
'Wenn eine Wochennummer in ein unterschiedliches Jahr fällt, so wird dies berücksichtigt
'd.h. 31.12.2002 = 01\2003 bzw. 1.1.1999 = 53\1998
Dim x, y, z
WeekFmt = ""
If Not IsDate(XDatum) Then XDatum = Date
XDatum = CDate(XDatum)
x = Year(XDatum)
y = Month(XDatum)
z = Format(XDatum, "ww", vbMonday, vbFirstFourDays)
If y = 12 And z < 40 Then x = x + 1
If y = 1 And z > 10 Then x = x - 1
WeekFmt = Right("00" & z, 2) & "\" & Right("0000" & x, 4)
End Function


Function SQLDatum(Datumx) As String
'Macht aus irgendeinem gültigen Datum einen String #yyyy-mm-dd# (ISO-Norm Datum)
If IsDate(Datumx) Then
    SQLDatum = Format(CDate(Datumx), "\#yyyy\-mm\-dd\#", vbMonday, vbFirstFourDays)
Else
    SQLDatum = ""
End If
End Function


Function DateTimeForSQL(dteDate) As String
'Datum incl. Uhrzeit für SQL und INI-Files als String
  
'  DateTimeForSQL = Format(CDate(dteDate), "\#yyyy\-mm\-dd h:nn:ss AM/PM \#", vbMonday, vbFirstFourDays)
  DateTimeForSQL = Format(CDate(dteDate), "\#yyyy\-mm\-dd hh:nn:ss\#", vbMonday, vbFirstFourDays)

End Function

Function SQLDatum_TSQL(Datumx) As String
'   SQLDatum_TSQL       - Macht aus irgendeinem gültigen Datum einen String 'yyyymmdd' (ISO-Norm Datum mit Hochkomma)
If IsDate(Datumx) Then
    SQLDatum_TSQL = "'" & Year(Datumx) & Right("00" & Month(Datumx), 2) & Right("00" & Day(Datumx), 2) & "'"
Else
    SQLDatum_TSQL = ""
End If
End Function

Function DateTimeForSQL_TSQL(Datumx) As String
'   DateTimeForSQL_TSQL - Macht aus irgendeinem gültigen Datum einen String 'yyyymmdd hh:nn:ss' (ISO-Norm Datum Uhrzeit mit Hochkomma)
If IsDate(Datumx) Then
    DateTimeForSQL_TSQL = "'" & Year(Datumx) & Right("00" & Month(Datumx), 2) & Right("00" & Day(Datumx), 2) & " " & Right("00" & Hour(Datumx), 2) & ":" & Right("00" & minute(Datumx), 2) & ":" & Right("00" & Second(Datumx), 2) & "'"
Else
    DateTimeForSQL_TSQL = ""
End If
End Function


Function SQLDatum_Long(Datumx) As Long
'Macht aus irgendeinem gültigen Datum einen Long-Wert YYYYMMDD
If IsDate(Datumx) Then
    SQLDatum_Long = (Year(Datumx) * 10000) + (Month(Datumx) * 100) + Day(Datumx)
Else
    SQLDatum_Long = 0
End If
End Function


Function datumText(XDatum, XText As String) As String
'Funktion gibt bei gültigem Datum das Datum ansonsten einen Text zurück
'Autor: Klaus Oberdalhoff
If Len(Trim(Nz(XDatum))) = 0 Or Not IsDate(XDatum) Then
    datumText = XText
Else
    datumText = CStr(Format(CDate(XDatum), "dd.mm.yyyy", vbMonday, vbFirstFourDays))
End If

End Function

Function DatumPrf(ByVal GebDat As Variant, Optional OhneJahr As _
         Boolean = True, Optional ByVal HeutDat As Date, Optional _
         ByVal MinusX As Integer = 7, Optional ByVal PlusX As _
         Integer = 15) As Boolean
On Error GoTo Err_DatumPrf
    
'Autor: Kurt Grof, nach einer Idee von KObd ...
'Prüft, ob das Datum zwischen zwei Datumswerten liegt, gedacht um das lästige Geburtstagsprüfumgsproblem
'zu beseitigen.

'=========

'Es wird nur geprüft ob der Vergleichswert (GebDat)
'sich in einem Zeitkorridor zwischen
'HeutDat - MinuxX(tage)
'    UND
'HeutDat + PlusX(tage)
'
'befindet. Wenn ja, True, sonst False

'Angenommener Fall 1: Datum im Datenfeld GebDat ist der 19.1
'
'Dann wäre
'
'HeutDat + 15 der 3.2 (sowas in der Art)
'UND
'HeutDat-7 der 10.1.
'
'Ist GebDat >= 10.1. Und GebDat <= 3.2
'
'GebDat ist größer als der 10.1 und kleiner als der 3.2
'ALso --> True
'
'Angenommener Fall 2: Datum im Datenfeld GebDat ist der 19.3
'
'Dann wäre
'
'HeutDat + 15 der 3.2 (sowas in der Art)
'UND
'HeutDat-7 der 10.1.
'
'Ist GebDat >= 10.1. Und GebDat <= 3.2
'
'GebDat ist größer als der 10.1 und größer als der 3.2
'Also --> False

'===========

'GebDat ist so definiert, um bei Übergabe eines leeren Datums an eine Abfrage die Rückgabe "#Fehler" zu vermeiden sondern 0 zurückzugeben.

'Eingabe für Geburtstagsvergleich (ohne Jahresvergleich): Wenn die 7 Tage zurück und die 15 Tage vor OK sind:
'HatGeburtstag = DatumPrf(Gebdatum)

'Eingabe für Wiedervorlage (mit Jahresvergleich): Wenn die 7 Tage zurück und die 15 Tage vor OK sind:
'IstWV = DatumPrf(WVDat, False)

'Optional kann man auch die Anzahl Tage MinusX und PlusX verändern. Es werden immer die Absolutwerte verwendet.
'IstWV = DatumPrf(WVDat, False, Date(), 10, 22)
'HatGeburtstag = DatumPrf(Gebdatum, True, , 0, 30)

'Rückgabe True, das Datum liegt in dem zu prüfenden Zeitraum
'Rückgabe False, wenn nicht
    
    Dim vonDat As Date, bisDat As Date
    DatumPrf = False
    
    If IsDate(GebDat) Then
        If GebDat = 0 Then
            GoTo Err_DatumPrf
        Else
            GebDat = CDate(GebDat)
        End If
    Else
        GoTo Err_DatumPrf
    End If

    If IsDate(HeutDat) Then
        If HeutDat = 0 Then
            HeutDat = Date
        Else
            HeutDat = CDate(HeutDat)
        End If
    Else
        GoTo Err_DatumPrf
    End If

    MinusX = -Abs(MinusX)
    PlusX = Abs(PlusX)
    
    vonDat = DateAdd("d", MinusX, HeutDat)
    bisDat = DateAdd("d", PlusX, HeutDat)
    
    If OhneJahr Then
        GebDat = DateSerial(Year(vonDat), Month(GebDat), Day(GebDat))
        If GebDat >= vonDat And GebDat <= bisDat Then
            DatumPrf = True
        Else
            GebDat = DateSerial(Year(bisDat), Month(GebDat), Day(GebDat))
            DatumPrf = (GebDat >= vonDat And GebDat <= bisDat)
        End If
    Else
         DatumPrf = (GebDat >= vonDat And GebDat <= bisDat)
    End If

Exit_DatumPrf:
    Exit Function
    
Err_DatumPrf:
'    MsgBox "Datumsprüfung - Fehler" & Str$(err.Number) & ": " & err.Description
    DatumPrf = False
    Resume Exit_DatumPrf
    
End Function

Function WochentagImMonat(Optional ByVal XDatum, Optional ByVal WelchMontag As Integer = 1, Optional ByVal WelchWochentag As Integer = 1) As Date

'Gibt den ersten, zweiten, dritten, vierten, oder letzten (Parameter WelchMontag)
'Wochentag (Parameter WelchWochentag) eines Datums(Parameter XDatum) zurück
'Für englische Feiertagsberechnung (erster / letzter Montag im Monat) ...
'Oder für Kalenderfunktionen (Besprechung immer am 3. Dienstag im Monat)

'WelchWochentag 1 = Montag, ... 7 = Sonntag
'Welchmontag 1 bis 4, dann 1.2.3.4 Tag im Monat
'WelchMontag > 4 dann letzter Montag im Monat

'Benötigt die Functions: PreviousDay, Nextday, ErsterDesMonats, LetzterDesMonats

Dim i As Integer

If IsMissing(XDatum) Then XDatum = Date
If Not IsDate(XDatum) Then XDatum = Date

If WelchWochentag < 1 Or WelchWochentag > 7 Then
    WelchWochentag = 1 'Bei Fehler = Montag
End If

If WelchMontag > 4 Then
    WochentagImMonat = PreviousDay(WelchWochentag, LetzterDesMonats(XDatum))
Else
    WochentagImMonat = ErsterDesMonats(XDatum) - 1
    For i = 1 To WelchMontag
        WochentagImMonat = NextDay(WelchWochentag, (WochentagImMonat + 1))
    Next i
End If

End Function


Function Julian2Date(JulianDate As String) As Date
'Umrechnung eines Strings in der Form JJttt oder JJJJttt in ein Datum
   Dim x As Integer, Y1
   If Len(JulianDate) = 7 Then
       Y1 = Left(JulianDate, 4)         ' Jahreszahl 4-stellig
   Else
       Y1 = Left(JulianDate, 2)                 ' Jahreszahl 2-stellig
   End If
   x = Format("1. Januar " & Y1, "yyyy")    ' Access bestimmt das Jahrtausend
   x = (x \ 100) * 100
   Julian2Date = DateSerial(x + Int(JulianDate / 1000), 1, JulianDate Mod 1000)
End Function

Function Date2Julian(Datum As Date) As String
'Umrechnung eines Datums zu einem String in der Form JJttt
Dim tmp
tmp = Format(Datum, "y")
tmp = Right("000" & tmp, 3)
    Date2Julian = Format(Datum, "yy") & tmp
End Function

Function Zeitquarter(TTime As Date) As Date

'Autor: Oliver Weitmann
'Wie kann ich in einem Feld die nächste Viertelstunde berechnen lassen? Wenn
'z.B. in einem anderen Feld 07:16 steht, soll in dem berechneten Feld 07:30
'stehen.
'
Dim t As Date
t = TTime
Zeitquarter = CDate(TimeSerial(Hour(t), ((minute(t) \ 15) + 1) * 15, Second(t)))

'Hier wird die Systemzeit in t abgelegt, du kannst hier deine eigene
'Zeitinformation ablegen. Wenn du immer nur 0 Sekunden haben möchtest,
'gebe bitte beim 3 Parameter von TimeSerial anstatt Second(t) einfach 0
'an.
'
End Function


Public Function Zeitrunden(Zeit As Variant, fzf As Byte)
'Autor: Sönke Petersen
'Fortuna.pes@t-online.de
    
'Wie kann ich eine Zeit auf / 10 Min / eine Viertelstunde / runden ?
    
'Zeit im Format hh:mm:ss
'fzf = 5, 10, 15 oder 30
    
    Dim h, i, j As Integer
    Dim d As Variant
    i = Mid(Zeit, 4, 2)
    i = i / 1
    j = i Mod fzf
    h = Mid(Zeit, 1, 2)
    h = h / 1
    If (j / fzf) < 0.5 Then
        d = Mid(str(i - j), 2, 2)
        If Len(d) = 1 Then
            d = "0" + d
        End If
        If d = "60" Then
            d = "00"
            h = h + 1
        End If
        Zeitrunden = str(h) + ":" + d + (Mid(Zeit, 6, 3))
    End If
    If (j / fzf) >= 0.5 Then
        d = Mid(str(i + (fzf - j)), 2, 2)
        If Len(d) = 1 Then
            d = "0" + d
        End If
        If d = "60" Then
            d = "00"
            h = h + 1
        End If
        Zeitrunden = str(h) + ":" + d + Mid(Zeit, 6, 3)
    End If
End Function

    
Public Function StundenAusgabe(Datum As Double) As String
'Von: Roland Sommer <r.sommer@gmx.de> Ausgabe Anzahl Stunden > 24
'In deinem Bericht muß jetzt diese Funktion rein, z.b. =Stundenausgabe([Datum]) oder =Stundenausgabe([Enddatum] - [Anfangsdatum])
'Siehe Beispiel frmStandzeiten
StundenAusgabe = Format$(Sgn(Datum) * Int(Abs(Datum * 24)), "0") & ":" & Format$(Datum, "nn")
End Function


Function TierKZ(XDatum As Date) As String
'von Manfred Wesemann@MAUS-OL
    '----Name        Lateinisch     von    bis
    '-------------------------------------------
    '--- Widder     (Aries)         21.03.-20.04.
    '--- Stier      (Taurus)        21.04.-20.05.
    '--- Zwillinge  (Gemini)        21.05.-21.06.
    '--- Krebs      (Cancer)        22.06.-22.07.
    '--- Löwe       (Leo)           23.07.-23.08.
    '--- Jungfrau   (Virgo)         24.08.-23.09.
    '--- Waage      (Libra)         24.09.-23.10.
    '--- Skorpion   (Skorpius)      24.10.-22.11.
    '--- Schütze    (Sagittarius)   23.11.-22.12.
    '--- Steinbock  (Capricornus)   23.12.-20.01.
    '--- Wassermann (Aquarius)      21.01.-19.02.
    '--- Fische     (Pisces)        20.02.-20.03.
'Hier eine Prozedur zur Berechnung des Tierkreiszeichen (TierKZ)
'Leicht abgeändert zur leichteren Benutzung KObd
Dim x
Dim y

If (Not IsDate(XDatum)) Or (XDatum = 0) Then  'Wenn falsches Datum dann Heute
    x = Day(Date)
    y = Month(Date)
Else
    x = Day(XDatum)
    y = Month(XDatum)
End If

If (x > 20 And y = 3) Or (x < 21 And y = 4) Then
TierKZ = "Widder"
ElseIf (x > 20 And y = 4) Or (x < 21 And y = 5) Then
TierKZ = "Stier"
ElseIf (x > 20 And y = 5) Or (x < 22 And y = 6) Then
TierKZ = "Zwilling"
ElseIf (x > 21 And y = 6) Or (x < 23 And y = 7) Then
TierKZ = "Krebs"
ElseIf (x > 22 And y = 7) Or (x < 24 And y = 8) Then
TierKZ = "Löwe"
ElseIf (x > 23 And y = 8) Or (x < 24 And y = 9) Then
TierKZ = "Jungfrau"
ElseIf (x > 23 And y = 9) Or (x < 24 And y = 10) Then
TierKZ = "Waage"
ElseIf (x > 23 And y = 10) Or (x < 23 And y = 11) Then
TierKZ = "Skorpion"
ElseIf (x > 22 And y = 11) Or (x < 22 And y = 12) Then
TierKZ = "Schütze"
ElseIf (x > 21 And y = 12) Or (x < 21 And y = 1) Then
TierKZ = "Steinbock"
ElseIf (x > 20 And y = 1) Or (x < 20 And y = 2) Then
TierKZ = "Wassermann"
ElseIf (x > 19 And y = 2) Or (x < 21 And y = 3) Then
TierKZ = "Fische"
End If

End Function

Function jahreszeit(dtm_tag As Date) As String

    '-------------------------------------------------------------------
    '--- modul for MS-Access97 and MS-Access2000: version 1998/12/22
    '--- Josef Syrovatka
    '-------------------------------------------------------------------

    '--- Errechnet aus einem Datum die zugehörige Jahreszeit
    Dim lng_monat As Long, lng_tag As Long

    jahreszeit = "?"

    lng_monat = Month(dtm_tag)
    lng_tag = Day(dtm_tag)

    '--- Frühling 21.03.-20.06.
    '--- Sommer   21.06.-22.09.
    '--- Herbst   23.09.-21.12.
    '--- Winter   22.12.-20.03.

    If lng_monat = 0 Or IsNull(lng_monat) Then Exit Function
    If lng_tag = 0 Or IsNull(lng_tag) Then Exit Function

    Select Case lng_monat
        Case 1, 2: jahreszeit = "Winter"
        Case 3: If lng_tag <= 20 Then jahreszeit = "Winter" Else jahreszeit = "Frühling"
        Case 4, 5: jahreszeit = "Frühling"
        Case 6: If lng_tag <= 20 Then jahreszeit = "Frühling" Else jahreszeit = "Sommer"
        Case 7, 8: jahreszeit = "Sommer"
        Case 9: If lng_tag <= 22 Then jahreszeit = "Sommer" Else jahreszeit = "Herbst"
        Case 10, 11: jahreszeit = "Herbst"
        Case 12: If lng_tag <= 21 Then jahreszeit = "Herbst" Else jahreszeit = "Winter"
    End Select

End Function


 Function DateDiffW(ByVal BegDate As Date, endDate As Date)
'War vorher im Modul mdlDateDiffW
'PSS ID Number: Q95977
'Article last modified on 08-29-1997
'The following code provides a function, DateDiffW(), that calculates
'the number of work days between two dates:
'
'How to Use the DateDiffW() Function
'-----------------------------------
'
'Use the DateDiffW() function wherever you would use DateDiff(). Instead of
'
'   DateDiff("W",[StartDate],[EndDate])
'
'use the following:
'
'   DateDiffW([StartDate],[EndDate])
'
'NOTE: This function returns the days UP TO the ending date, not UP TO and
'INCLUDING the ending date.
'One less than AnzWochenTage

'   Anzahl Werktage (ohne Feiertage) zwischen zwei Tagen
      Const SUNDAY = 1
      Const SATURDAY = 7
      Dim NumWeeks As Integer
 
      If BegDate > endDate Then
         DateDiffW = 0
      Else
         Select Case Weekday(BegDate)
            Case SUNDAY: BegDate = BegDate + 1
            Case SATURDAY: BegDate = BegDate + 2
         End Select
         Select Case Weekday(endDate)
            Case SUNDAY: endDate = endDate - 2
            Case SATURDAY: endDate = endDate - 1
         End Select
         NumWeeks = DateDiff("ww", BegDate, endDate)
         DateDiffW = NumWeeks * 5 + Weekday(endDate) - Weekday(BegDate)
      End If
   End Function
 

Function AnzWochenTage(ByVal datBeginn As Date, ByVal datEnde As Date) As Long
'von Urs Villiger
'Anzahl der Werktage ohne Samstag und ohne Sonntag (ohne Feiertagsberücksichtigung)
  AnzWochenTage = DateDiff("d", datBeginn, datEnde) - DateDiff("ww", datBeginn, datEnde) _
  * 2 + 1 + (Weekday(datBeginn) = 1) + (Weekday(datEnde) = 7)
End Function


Function fktIstWochenende(XDatum As Date) As Boolean
If Weekday(XDatum, vbMonday) > 5 Then
    fktIstWochenende = True
Else
    fktIstWochenende = False
End If
End Function

Function Werktag7h(Start As Date, Dauer As Date) As Date
'Autor: Wolfgang Flamme
'wflamme@mainz-online.de

'Aufgabe:
'innerhalb einer Abfrage stehen mir folgende Daten zur Verfügung
'
'Auftrag                   Dauer (hh:nn)
'A                           05:50
'B                           01:50
'C                           35:00
'D                           16:00
'E                            08:00  etc.
'
'Ich möchte nun die Aufträge so darstellen, daß jedem Tag 7 Stunden zur
'Verfügung stehen (d.h. ein Auftrag muß auch getrennt werden können), zudem
'sollen
'alle Sa+So+Feiertage ausgespart werden.
'
'Gewünschtes Ergebnis:
'
'Auftrag            Zeit            AnfagsDatum        Enddatum
'A                    05:50          Do. 26.08.99        Do. 26.08.99
'B                    01:50          Do. 26.08.99        Do. 26.08.99
'C                    35:00          Fr.  27.08.99        Do. 02.09.99
'D                    16:00          Fr.  03.09.99        Di.  07.09.99
'E                     08:00         Di.  07.09.99 ....................
'
'Funktionsbeschreibung:
'Diese Funktion berechnet, ausgehend vom Startdatum und der Dauer in Stunden, das Enddatum
'unter Berücksichtigung der "normalen" Werktage (excl. Samstag und Sonntag) aber OHNE
'Berücksichtigung der Feiertage

Dim EW, d, w, t
EW = Dauer * 24 / 7 'Eure Werktage
d = Int(EW) + (EW - Int(EW)) * 7 / 24 'Korrigierte Dauer
w = Int(d / 7) 'ganze Wochen
t = d - w * 7 'Resttage
Werktag7h = Start + d + 2 * w + IIf(Weekday(Start, vbSunday) _
+ t >= 7, 1, 0) + IIf(Weekday(Start, vbMonday) + t >= 7, 1, _
0) - 1 / 86400
'Start+Dauer+Samstage+Sonntage im Zeitraum-1sec
End Function

Function Test_Werktag7h() As Date
Dim da As Date
da = TimeSerial(55, 0, 0)
Test_Werktag7h = Werktag7h("1.1.1999 13:22", da)
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''Feiertage
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Meine "Feiertage" bestehen eigentlich aus 4 Tabellen:
'
'a) tblFeierStd    -    Aufbau des Feiertages (genereller Feiertagswert ohne Jahr) und Zuordnung zu einem
'Bundesland
'
'b) _tblAlleFeiertage    -    Sekundärtabelle, generiert aus tblFeierStd, enthält den Namen,
'das "echte" Datum (incl. Jahr) und die dazugehörige Wochentagsnummer (1 = Montag ... 7 = Sonntag)
'
'c) _tblBundesLand    - enthält die Zuordnung zu den Klarnamen der Bundesländer, da bei den Abfragen
'etc. nur der Feldname (B1 ... B16, C1, D1) verwendet wird ...
'
'd) _tblAlleTage    - Tertiärtabelle, generiert aus _tblAlleFeiertage, die alle Tage eines Jahres enthält ...
'Sie wird durch das Formular frmFeiertagErstellen automatisch gefüllt.
'Idee: Kalender aller Tage mir allen wichtigen Infos zu Wochentag bis Feiertag
'
'Die Abfrage qryHlp_Feiertag verknüpft die beiden Tabellen tblFeierStd und _tblAlleFeiertage und ist die
'Grundlage aller Feiertagsfunktionen in diesem Modul  ... Achtung: die Verknüpfung ist der
'Feiertagsnamen selbst ... Die andern Feiertags-Abfragen sind nur Beispiele ...
'
' Eigene Feiertage:
'
'Öffne das Formular frmFeiertagErstellen.
'
'Passe dann  die Tabelle tblFeierStd deinen Wünschen entsprechend an. Die Tabelle enthält für ein Jahr
'alle Feiertage sowie eine Möglichkeit, diese Feiertage einem Bundesland zuzuordnen. Sie enthält,
'(bis auf Fehler?) bereits alle offiziellen Feiertage der Bundesländer von D sowie Österreich und
'England. Wenn du die Bundesländer erweiterst, vergiß nicht auch die Tabelle _tblBundesLand zu erweitern.
'
'Wenn du "private" Feiertage hast, trage diese in die Tabelle tblFeierStd ein.
'Dazu gibt es das Formular frmJahrEigeneFeiertage, die erledigt das für dich
'
'Das Einzige, was derzeit nicht berücksichtigt wird, sind "halbe" Feiertage, wie der 24.12 oder 31.12.
'das müßte man bei Bedarf ergänzen ..
'
'Das Formular "frmTestKalender" und "frmKalender" sind mein eigener PopupKalender (man kann ihn aber auch
'"so" aufrufen) und ein Testformular um den PopupAufruf zu zeigen...

'########################## Schweizer Feiertage zur Info von Urs ######################################
'Habe diese Feiertage (ALLE außer den Eidgenössischen Bettag) auch in die Tabelle eingebaut.

'In der Schweiz ist es wie üblich von Kanton zu Kanton verschieden.
'
'Nationale Feiertage:
'1.1. Neujahr + 2.1. (Berchtholdstag)
'KEIN Dreikönig
'Palmsonntag
'Karfreitag
'Ostern Ostermontag
'Auffahrt ?? = Christi Himmelfahrt
'Pfingsten Pfingstmontag
'1.8. Bundesfeiertag
'19.9.1999 (17.9.2000) Eidgenössischer Bettag (immer Sonntags) 'ignoriert, da immer Sonntags
'25.12. Weihnachten
'26.12. Stefanstag
'
'katholische Gebiete (Zentralschweiz, Ostschweiz, Freiburg, Tessin uam., die
'Feiern einfach lieber!)
'Fronleichnam (40 Tage nach Ostern)
'15.8. Mariä Himmelfahrt
'1.11. Allerheiligen
'8.12. Mariä Empfängnis
'
'reformierte/städtische Gebiete (Zürich, Bern, Basel, Genf uam. + Tessin)
'1.5. Tag der Arbeit
'
'die Grenzen verlaufen z.T. auch innerhalb von Kantonen.
'daneben sehr viele lokale oder kantonale Feiertage
'Gruss Urs Villiger.
'###############################################################################################

Private Function GetBitValue(nIndex As Long, BitArray As Long) As Boolean
    Dim nBit As Long

    nBit = 2 ^ (nIndex Mod 16)
    If nBit = &H8000& Then  'Prevent overflow on high bit
        GetBitValue = BitArray And &H8000
    Else
        GetBitValue = BitArray And nBit
    End If
End Function


Function create_Default_AlleTage(strBundesland As String)

Dim strSQL As String

strSQL = ""
strSQL = strSQL & "SELECT JJJJMMTT, Werkname, dtDatum, IstFeiertag, Feiertagsname, JahrNr, Quartal, MonatNr, TagNr, Wochentag,"
strSQL = strSQL & " KW_D, JJJJMM, JJJJKW, JJJJQrt, KW_US, WN_KalMon, WN_KalTag, Arbeitszeit, LfdTagNrAcc,"
strSQL = strSQL & " B" & strBundesland & " As Landesfeiertag, F" & strBundesland & " As Landesferien"
strSQL = strSQL & " FROM _tblAlleTage;"

Call CreateQuery(strSQL, "qryAlleTage_Default")

End Function

Function fktAnzWerktageVariabel(DatumVon As Date, DatumBis As Date, Bundesland As String, WerktageNr As Long) As Long

'Die Funktion ermittelt die Anzahl der Werktage (abhängig von WerktageNr) zwischen Datumvon und Datumbis
'unter Berücksichtigung der Feiertage eines Bundeslandes (siehe Tabelle)
'es muß das Bundesland als Kürzel (B1 bis D1) mit übergeben werden
'Es benötigt Function AnzWochenTage und fktAnzFeiertage und Bundeslandtest
'sowie (in fktAnzFeiertage) qryHlp_Feiertag und daher tblFeierStd und _tblAlleFeiertage
'Die "Standard"-Feiertage in _tblAlleFeiertage sind vom 1.1.1995 bis 31.12.2035 erstellt,
'können aber jederzeit erweitert werden. (Siehe "frm _tblAlleFeiertage Erstellen")

'WerktageNr 1 = 1 Montag
'WerktageNr 2 = 2 Dienstag
'WerktageNr 3 = 4 Mittwoch
'WerktageNr 4 = 8 Donnerstag
'WerktageNr 5 = 16 Freitag
'WerktageNr 6 = 32 Samstag
'WerktageNr 7 = 64 Sonntag

' Bzw die Summe der Tage
' Montag bis Freitag = 1 + 2 + 4 + 8 + 16 = 31

Dim IstWerktag(6) As Boolean
Dim x, Krit
Dim i As Long
Dim nBit As Long
Dim datumzwi As Date

fktAnzWerktageVariabel = 0

If Not IsDate(DatumVon) Then Exit Function
If Not IsDate(DatumBis) Then Exit Function
If DatumVon > DatumBis Then Exit Function


For i = 0 To 6
    nBit = 2 ^ i
    IstWerktag(i) = WerktageNr And nBit
Next i

datumzwi = DatumVon

Do
    If IstWerktag(Weekday(datumzwi, vbMonday) - 1) Then
        Krit = "qryHlp_Feiertag." & Bundesland & " = True AND qryHlp_Feiertag.Feiertagsdat = "
        Krit = Krit & SQLDatum(datumzwi)
        x = Nz(TLookup(Bundesland, "qryHlp_Feiertag", Krit))
        If Not x Then
            fktAnzWerktageVariabel = fktAnzWerktageVariabel + 1
        End If
    End If
    datumzwi = datumzwi + 1
Loop Until datumzwi > DatumBis

End Function


Function fktAnzWerktage(DatumVon As Date, DatumBis As Date, Bundesland As String) As Long

'Die Funktion ermittelt die Anzahl der Werktage (Mo - Fr) zwischen Datumvon und Datumbis
'unter Berücksichtigung der Feiertage eines Bundeslandes (siehe Tabelle)
'es muß das Bundesland als Kürzel (B1 bis D1) mit übergeben werden
'Es benötigt Function AnzWochenTage und fktAnzFeiertage und Bundeslandtest
'sowie (in fktAnzFeiertage) qryHlp_Feiertag und daher tblFeierStd und _tblAlleFeiertage
'Die "Standard"-Feiertage in _tblAlleFeiertage sind vom 1.1.1995 bis 31.12.2035 erstellt,
'können aber jederzeit erweitert werden. (Siehe "frm _tblAlleFeiertage Erstellen")

'BundeslandID BundeslandName
'BB Brandenburg
'BE Berlin
'BW Baden - Württemberg
'BY Bayern
'HB Bremen
'HE Hessen
'HH Hamburg
'MV Mecklenburg - Vorpommern
'NI Niedersachsen
'NW Nordrhein - Westfalen
'RP Rheinland - Pfalz
'SH Schleswig - Holstein
'SL Saarland
'SN Sachsen
'ST Sachsen - Anhalt
'TH Thüringen

On Error Resume Next
fktAnzWerktage = -1
If Not Bundeslandtest(Bundesland) Then Exit Function
    
'Anzahl Werktage = Anzahl Wochentage Minus Anzahl der Feiertage die nicht auf ein Wochenende fallen
fktAnzWerktage = AnzWochenTage(DatumVon, DatumBis) - fktAnzFeiertage(DatumVon, DatumBis, Bundesland)
End Function

Function fktAnzFeiertage(DatumVon As Date, DatumBis As Date, Bundesland As String) As Long

'Die Funktion ermittelt die Anzahl der Feiertage (nur Mo - Fr) zwischen Datumvon und Datumbis
'unter Berücksichtigung eines Bundeslandes (siehe Tabelle)
'es muß das Bundesland als Kürzel (B1 bis D1) mit übergeben werden
'Es benötigt qryHlp_Feiertag und daher tblFeierStd und _tblAlleFeiertage
'Die "Standard"-Feiertage in _tblAlleFeiertage sind vom 1.1.1995 bis 31.12.2035 erstellt,
'können aber jederzeit erweitert werden.

'_tblBundesLand enthält die folgende Tabelle (zur Vereinfachung):

'BundeslandID BundeslandName
'BB Brandenburg
'BE Berlin
'BW Baden - Württemberg
'BY Bayern
'HB Bremen
'HE Hessen
'HH Hamburg
'MV Mecklenburg - Vorpommern
'NI Niedersachsen
'NW Nordrhein - Westfalen
'RP Rheinland - Pfalz
'SH Schleswig - Holstein
'SL Saarland
'SN Sachsen
'ST Sachsen - Anhalt
'TH Thüringen

On Error Resume Next
Dim Krit As String
    
fktAnzFeiertage = 0
If Not Bundeslandtest(Bundesland) Then Exit Function

Krit = "qryHlp_Feiertag." & Bundesland & " = True AND qryHlp_Feiertag.Wochentagnr<6 AND qryHlp_Feiertag.Feiertagsdat >= "
Krit = Krit & SQLDatum(DatumVon) & " AND qryHlp_Feiertag.Feiertagsdat <= " & SQLDatum(DatumBis)
fktAnzFeiertage = TCount("Feiertagsdat", "qryHlp_Feiertag", Krit)
End Function

Function fktIstWerktag(XDatum As Date, Bundesland As String) As Boolean
'Die Funktion ermittelt, on ein Datum ein Werktag ist oder nicht (Mo - Fr)
'unter Berücksichtigung der Feiertage eines Bundeslandes (siehe Tabelle)
'es muß das Bundesland als Kürzel (B1 bis D1) mit übergeben werden (siehe fktAnzWerktage)
'Es benötigt qryHlp_Feiertag und daher tblFeierStd und _tblAlleFeiertage
'Die "Standard"-Feiertage in _tblAlleFeiertage sind vom 1.1.1995 bis 31.12.2035 erstellt,
'können aber jederzeit erweitert werden.
On Error Resume Next
Dim x, Krit

fktIstWerktag = False
If Not Bundeslandtest(Bundesland) Then Exit Function

fktIstWerktag = True
If Weekday(XDatum, vbMonday) < 6 Then
    Krit = "qryHlp_Feiertag." & Bundesland & " = True AND qryHlp_Feiertag.Feiertagsdat = "
    Krit = Krit & SQLDatum(XDatum)
    x = Nz(TLookup(Bundesland, "qryHlp_Feiertag", Krit))
    If x Then fktIstWerktag = False
Else
    fktIstWerktag = False
End If
End Function


Function fktWelcherFeiertag(XDatum As Date, Bundesland As String) As String
'Die Funktion ermittelt den Feiertagsnamen, wenn es denn ein Feiertag ist
'unter Berücksichtigung der Feiertage eines Bundeslandes (siehe Tabelle)
'unabhängig davon, ob dieser Tag ein Werk- oder Sonntag ist
'Wenn kein Feiertag, wird ein Leerstring "" zurückgegeben
'es muß das Bundesland als Kürzel (B1 bis D1) mit übergeben werden (siehe fktAnzWerktage)
'Es benötigt qryHlp_Feiertag und daher tblFeierStd und _tblAlleFeiertage
'Die "Standard"-Feiertage in _tblAlleFeiertage sind vom 1.1.1995 bis 31.12.2035 erstellt,
'können aber jederzeit erweitert werden.
On Error Resume Next
Dim Krit
fktWelcherFeiertag = ""
If Not Bundeslandtest(Bundesland) Then Exit Function

Krit = "qryHlp_Feiertag." & Bundesland & " = True AND qryHlp_Feiertag.Feiertagsdat = "
Krit = Krit & SQLDatum(XDatum)
    
fktWelcherFeiertag = Nz(TLookup("Feiertagsname", "qryHlp_Feiertag", Krit))

End Function

Function Bundeslandtest(ByVal BundeslandID As String) As Boolean
Dim i As Integer
Dim x As String
On Error Resume Next

BundeslandID = UCase(BundeslandID)
Bundeslandtest = False

x = UCase(Nz(TLookup("BundeslandID", "_tblBundesLand", "BundeslandID = '" & BundeslandID & "'")))

If x = BundeslandID Then
    Bundeslandtest = True
End If

End Function
Function BundeslandName(ByVal BundeslandID As String) As String
Dim i As Integer
Dim x As String
On Error Resume Next

BundeslandID = UCase(BundeslandID)
BundeslandName = Nz(TLookup("Bundeslandname", "_tblBundesLand", "BundeslandID = '" & BundeslandID & "'"))

End Function

Function CreateTblWerktag(VonJahr As Integer, BisJahr As Integer, Bundesland As String, Optional WerkNrx As String = "Std", Optional tblLoesch As Boolean = True) As Boolean
'Vonjahr und BisJahr immer als 4-stellige Jahresnummer eingeben
'Für Bundesland immer das Kürzel B1 bis B16, C1 oder D1 angeben
'Hier kann eine Weksnummer eingegeben werden, Std = "Std"
'Wenn tblLoesch = True, wird der Werkstagskalender vorher gelöscht
Dim db As DAO.Database
Dim rst
Dim Krit As String
Dim i As Integer, j As Integer, k As Integer, l As Integer, tmpdat As Date
    
On Error GoTo CreateTblWerktag_err
CreateTblWerktag = True

'Alte Tabelleninhalte löschen
'DELETE tblWerktag.* FROM tblWerktag;
Set db = CurrentDb

If tblLoesch Then
    Krit = "DELETE tblWerktag.* FROM tblWerktag;"
    Set rst = db.CreateQueryDef("", Krit)
    rst.Execute
End If

Set rst = Nothing
Set rst = db.OpenRecordset("SELECT * FROM tblWerktag;", dbOpenDynaset)
           
For i = VonJahr To BisJahr  'Schleife über alle Jahre
    k = Format(DateSerial(i, 12, 31), "y", vbMonday, vbFirstFourDays) 'Anzahl Tage pro Jahr (Schaltjahr) ?
    For j = 1 To k  'Schleife über alle Tage des Jahres
        tmpdat = DateSerial(i, 1, j)
        l = Weekday(tmpdat, vbMonday)
        If fktIstWerktag(tmpdat, Bundesland) Then   ' werktag ?
            rst.AddNew
            rst.fields("WerkNummer") = WerkNrx
            rst.fields("Werktag") = tmpdat
            rst.fields("WochentagNr") = l
            rst.update
        End If
    Next j
Next i

rst.Close
Set rst = Nothing
Set db = Nothing

Exit Function

CreateTblWerktag_err:

If Err.Number = 3022 Then Resume Next  'Datum exitiert bereits in der Tabelle

rst.Close
Set rst = Nothing
Set db = Nothing
CreateTblWerktag = False
MsgBox "Fehler " & Err.Number & " " & Err.description, , "Werktage erzeugen Fehler"

End Function
 
Function OsterSonntagDatum(Jahr) As Date
''Wolfgang weidner
''w.weidner@t-online.de
'' Geändert von KObd (Ostersonntagsberechnung separiert)
On Error Resume Next

Dim Monat As Integer, TAG As Integer, s As Long
Dim m As Integer, n As Integer, i As Integer, j As Integer, t As Integer
Dim a As Integer, b As Integer, c As Integer, d As Integer, e As Integer
'************ Feiertagsberechnung *****************

If Jahr < 1582 Or Jahr > 2199 Then
    MsgBox "Falsche Jahreszahl"
    Exit Function
End If

    Select Case Jahr
        Case 1582 To 1699
            m = 22
            n = 2
        Case 1700 To 1799
            m = 23
            n = 3
        Case 1800 To 1899
            m = 23
            n = 4
        Case 1900 To 2099
            m = 24
            n = 5
        Case 2100 To 2199
            m = 24
            n = 6
    End Select

    j = Jahr
    a = j Mod 19
    b = j Mod 4
    c = j Mod 7
    d = (19 * a + m) Mod 30
    e = (2 * b + 4 * c + 6 * d + n) Mod 7
    If (d + e) <= 9 Then
        OsterSonntagDatum = DateSerial(Jahr, 3, 22 + d + e)
    Else
        OsterSonntagDatum = DateSerial(Jahr, 4, d + e - 9)
    End If
    If Month(OsterSonntagDatum) = 4 Then
        If (d = 28) And (a > 10) Then
            If Day(OsterSonntagDatum) = 25 Then
                OsterSonntagDatum = DateSerial(Jahr, 4, 18)
            End If
            If Day(OsterSonntagDatum) = 26 Then
                OsterSonntagDatum = DateSerial(Jahr, 4, 19)
            End If
        End If
    End If

End Function


Function VierterAdvent(Jahr As Variant) As Date

Dim dat As Date
    
    dat = DateSerial(Jahr, 12, 24)

    Do While Not Weekday(dat, vbMonday) = vbSunday
        dat = dat - 1
    Loop
    VierterAdvent = dat

End Function


Function BusstagDatum(Jahr As Variant) As Date
Dim t As Integer

'Buß- und Bettag ist der Tag, der 32 Tage vor dem 4. Adventsonntag liegt
BusstagDatum = VierterAdvent(Jahr) - 32

'Buß- und Bettag ist immer der Mittwoch, der zwischen dem 16. und 22. November liegt.
'w.weidner@t-online.de
'Buß- und Bettag ist immer der Mittwoch, der zwischen dem 16. und 22. November liegt.
'    For T = 16 To 22
'        If Weekday(DateSerial(intJahr, 11, T), vbMonday) = 3 Then
'            BusstagDatum = DateSerial(intJahr, 11, T)
'        End If
'    Next T

End Function


Function dblZt(sWert As String) As Date
On Error Resume Next
Dim sw1 As Double
Dim sw2 As Date
'sw1 = CDbl(Replace(swert, ",", "."))
sw1 = CDbl(sWert)
sw2 = sw1
dblZt = sw2
End Function


''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''

Function ZeitNachDouble(Sek1 As Double, Min As Long, std As Long, TAG As Long) As Double
' *******************
' Umrechnung der Zeit in Tagen, Stunden, Minuten und Sekunden nach Sekunden.
' Gedacht, um Wettkampfzeiten ganz exakt als Double abspeichern zu können
' 1 Min =    60 Sekunden (60 Sek)
' 1 Std =  3600 Sekunden (60 Sek * 60 Min)
' 1 Tag = 86400 Sekunden (60 Sek * 60 Min * 24 Std)
' *******************

    ZeitNachDouble = (TAG * 86400) + (std * 3600) + (Min * 60) + Sek1

End Function

Function DoubleNachZeit(art, WertSekunden As Double, Restsekunden As Double, Minuten As Long, stunden As Long, Tage As Long) As Boolean
' *********************************************************************************
' Die Funktion DoubleNachZeit wandelt eine Zahl / Zeit (im Format Double)
' in Sekunden, Minuten, Stunden und Tage um
'
' Funktion ist ausschließlich gedacht, um Wettkampfzeiten, die nur in Sekunden und Bruchteilen
' erfaßt wurden in ein "echtes" Zeitformat umzuwandeln
'
'   Parameter: Art = Beliebig, dann Rückgabe in Tagen, Std, Minuten und Restsekunden
'              Art = "M" oder "m" - nur Minuten + Sec (Std und Tage immer = 0) Min dann ggf. > 60
'              Art = "S" oder "s" - nur Std, Min + Sec (Tage immer = 0) Std dann ggf. > 24
'              WertSekunden - Übergabewert an die Funktion Sekunden und Millisekunden
'
'              Restsekunden - Rückgabewert in Sekunden und Millisekunden
'              Minuten      - Rückgabewert
'              Stunden      - Rückgabewert
'              Tage         - Rückgabewert
'
'   Sofern DoubleNachZeit ein gültiger Zahlenwert ist, gibt die Funktion Wahr zurück
'                       ansonsten False
'
' Da die Funktion selbstständig ermittelt, ob ein "." oder "," als Nachkommatrenner
' verwendet wird, sollte sie sprachunabhängig funktionieren
'
' Public domain - Benutzung auf eigene Gefahr
'
' Kommentare und Verbesserungsvorschläge an:
'
'   Klaus Oberdalhoff   - KObd@gmx.de
'
' *********************************************************************************

Dim NachkommaSec As Double, VorkommaSec As Long, tmp1, tmp2, tmp3, tmp4, Sepa

    Restsekunden = 0
    Minuten = 0
    stunden = 0
    Tage = 0
    DoubleNachZeit = True

If Len(Trim(Nz(WertSekunden))) = 0 Then
    DoubleNachZeit = False
    Exit Function
End If

If Not IsNumeric(WertSekunden) Then
    DoubleNachZeit = False
    Exit Function
End If

' < 1 Minute - dann Keine Berechnung notwendig
If Abs(WertSekunden) < 60 Then
    Restsekunden = WertSekunden
    Exit Function
End If

' Ermitteln, ob "," oder "." die Nachkommastelle ist ...
' aus mdlLocaleInfo
'Sepa = GetDecimalSep()   ' entweder "." oder ","
Sepa = Mid(Format(1.5, "#.#"), 2, 1)

' Zahl in String umwandeln, Wert nach der Kommastelle abschneiden und zwischen speichern
' Die Nachkommastellen rechnerisch zu bearbeiten, war zu ungenau !!!
tmp1 = Format(Abs(WertSekunden))
tmp2 = InStr(1, tmp1, Sepa, vbTextCompare)
tmp3 = ""
' Wenn Tmp2 ein Komma enthält: Nachkommastellen als String sichern
If tmp2 > 0 Then
    tmp3 = Mid(tmp1, tmp2 + 1)
End If

' Tmp3 = Nachkomma
VorkommaSec = Fix(WertSekunden)

' Minuten berechnen
Minuten = VorkommaSec \ 60
' Das hatte ich zuerst, ist aber zu ungenau
' Restsekunden = Fix(VorkommaSec Mod 60) + NachkommaSec
tmp4 = Fix(VorkommaSec Mod 60)
If Len(tmp3) > 0 Then
    Restsekunden = CDbl(tmp4 & Sepa & tmp3)
Else
    Restsekunden = CDbl(tmp4)
End If

' Stunden berechnen, wenn nötig
If Abs(Minuten) < 60 Or UCase(art) = "M" Then
    Exit Function
End If

stunden = Minuten \ 60
Minuten = Minuten Mod 60

' Tage berechnen, wenn nötig
If Abs(stunden) < 24 Or UCase(art) = "S" Then
    Exit Function
End If

Tage = stunden \ 24
stunden = stunden Mod 24

End Function

' Test the function:

Function ZeitTest()
Dim Mldg, titel, Voreinstellung, Wert1 As Double
Dim Sec1 As Double, Min1 As Long, Std1 As Long, Tag1 As Long, tmp1

Mldg = "Sekunden (incl. Nachkommastellen) eingeben: "  ' Aufforderung festlegen.
titel = "Abfrage Sekundenwert" ' Titel festlegen.
Voreinstellung = "1"    ' Voreinstellung festlegen.
' Meldung, Titel und Standardwert anzeigen.
Wert1 = InputBox(Mldg, titel, Voreinstellung)

If Not DoubleNachZeit("X", Wert1, Sec1, Min1, Std1, Tag1) Then
    MsgBox ("Falsche Eingabe ! Wert war " & Wert1)
    Exit Function
End If

tmp1 = "Eingabewert: " & Wert1 & vbCrLf & "Sekunden: " & Sec1
tmp1 = tmp1 & vbCrLf & "Minuten: " & Min1 & vbCrLf & "Stunden: " & Std1
tmp1 = tmp1 & vbCrLf & "Tage: " & Tag1

    MsgBox (tmp1)

'Debug.Print "Eingabewert: " & Wert1
'Debug.Print "Sekunden: " & Sec1
'Debug.Print "Minuten: " & Min1
'Debug.Print "Stunden: " & Std1
'Debug.Print "Tage: " & Tag1

End Function

Public Function LongZuZeit(z As Long) As Date
'In einem Feld (Typ Long Integer) ist eine Zeit in
'Sekunden gespeichert. In einem Bericht möchte ich
'diese Zeit in der Form hh:mm:ss ausgeben.
'
'Wie kann ich den Feldinhalt für die Ausgabe
'umrechnen?
'Autor K.Prucha
  LongZuZeit = TimeSerial(((z \ 3600) Mod 60), ((z \ 60) Mod 60), (z Mod 60))
End Function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''' Kalenderfunktionen ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Global Global_PrevCtrl As Control wird benötigt

Function Datumsetzen1(x As control, ByVal y)

Dim xFrm As Form, XT1, XM1, XY1, Moonx As String, i As Integer

Dim iStunde As Long
Dim iMin As Long

'Für den Fall das PrevCtrl nicht gesetzt wäre
On Error GoTo Datumsetzen1_we

If Global_PrevCtrl.backColor <> 14024702 Then  'Wenn kein Feiertag
    Global_PrevCtrl.BackStyle = 0
End If
Global_PrevCtrl.SpecialEffect = 0

x.SetFocus

Datumsetzen1_we:

Err.clear
DoEvents
Err.clear
On Error GoTo Datumsetzen1_err

Set xFrm = x.Parent

x.BackStyle = 1
x.SpecialEffect = 2

XT1 = x.caption 'Tagesnummer, wenn richtig gesetzt
XM1 = Format(CDate(xFrm("Mon" & y).Value), "m", vbMonday, vbFirstFourDays) 'Monat
XY1 = Format(CDate(xFrm("Mon" & y).Value), "yyyy", vbMonday, vbFirstFourDays) 'Jahr

xFrm!AktDat = DateSerial(XY1, XM1, XT1) + TimeSerial(Global_iStunde, Global_iMinute, 0)

Set Global_PrevCtrl = x

''Eines der kleinen 8 übernanderliegenden Mondphasenbilder sichtbar setzen
For i = 1 To 8
    xFrm("Moon" & i).Visible = False
Next i

Moonx = "Moon" & Mondphase(xFrm!AktDat)
xFrm(Moonx).Visible = True

Exit Function
Datumsetzen1_err:
MsgBox "Datumsetzen1 " & Err.Number & " " & Err.description
End Function

Function Datumsetzen2(x As control, ByVal y)
Dim nix, z As String
nix = Datumsetzen1(x, y)
If Len(Trim(Nz(x.Parent.OpenArgs))) > 0 Then
    DoCmd.Close acForm, x.Parent.Name, acSaveNo
End If
End Function

Function Datum_Neuaufbau(xFrm As Form, XAktDat As Date)
Dim tmpMon(1 To 3) As Integer
Dim tmpyr(1 To 3) As Integer
Dim tmpdy As Integer
Dim XFeiDat() As Date
Dim XFeiDatNam() As String
Dim i As Integer
Dim j As Integer
Dim k As Integer
Dim l As Integer
Dim m As Integer
Dim n As Integer
Dim p As Integer
Dim tmpdt As Date
Dim xstr1 As String
Dim Feianza As Integer
Dim Moonx As String

tmpdy = Format(XAktDat, "d", vbMonday, vbFirstFourDays) 'Die Nummer des Tages
tmpMon(2) = Format(XAktDat, "m", vbMonday, vbFirstFourDays)
tmpyr(2) = Format(XAktDat, "yyyy", vbMonday, vbFirstFourDays)
tmpMon(1) = Format(DateAdd("m", -1, XAktDat), "m", vbMonday, vbFirstFourDays)
tmpyr(1) = Format(DateAdd("m", -1, XAktDat), "yyyy", vbMonday, vbFirstFourDays)
tmpMon(3) = Format(DateAdd("m", 1, XAktDat), "m", vbMonday, vbFirstFourDays)
tmpyr(3) = Format(DateAdd("m", 1, XAktDat), "yyyy", vbMonday, vbFirstFourDays)

For i = 1 To 3  '3 Monate zur Ansicht
'Setzten bei Monateswechsel
    xFrm("Fei" & i) = FeiertageimMonat(DateSerial(tmpyr(i), tmpMon(i), 1), xFrm!cmbBundesland.Value, Feianza, XFeiDat(), XFeiDatNam()) 'Feiertage suchen
    xFrm("Mon" & i) = DateSerial(tmpyr(i), tmpMon(i), 1) 'die 3 Monate setzen
    l = 0  'Laufvariable TagesNr
    m = Weekday(DateSerial(tmpyr(i), tmpMon(i), 1), vbMonday) ' Wochentag des "1." bestimmen
    n = Format(LetzterDesMonats(DateSerial(tmpyr(i), tmpMon(i), 1)), "d", vbMonday, vbFirstFourDays) 'Anzahl der Tage im Monat
    
    For j = 1 To 6 ' Wochenloop
        xFrm("w" & i & "w" & j).caption = ""
        
        For k = 1 To 7 ' Tagesloop
            xFrm("btn" & i & "Tg" & j & k).BackStyle = 0 'Zurücksetzen
            xFrm("btn" & i & "Tg" & j & k).SpecialEffect = 0
            xFrm("btn" & i & "Tg" & j & k).backColor = -2147483633
            If l = 0 And k < m Then 'Überzählige Buttons deaktivieren (die vor dem ersten)
                xFrm("btn" & i & "Tg" & j & k).Visible = False
                xFrm("btn" & i & "Tg" & j & k).caption = ""
            Else
                If l >= n Then 'Überzählige Buttons deaktivieren (die nach dem letzten)
                    xFrm("btn" & i & "Tg" & j & k).Visible = False
                    xFrm("btn" & i & "Tg" & j & k).caption = ""
                Else    'Ahh die eigentlichen Monatstage
                    l = l + 1 ' lfd. Nummer des Tages
                    tmpdt = DateSerial(tmpyr(i), tmpMon(i), l)
                    xFrm("btn" & i & "Tg" & j & k).Visible = True
                    xFrm("btn" & i & "Tg" & j & k).caption = l
                    xFrm("w" & i & "w" & j).caption = Format(tmpdt, "ww", vbMonday, vbFirstFourDays)
                    If Feianza > 0 Then 'wenn Feiertag, dann Background setzen
                        For p = 1 To Feianza
                            If tmpdt = XFeiDat(p) Then
                                xFrm("btn" & i & "Tg" & j & k).BackStyle = 1
                                xFrm("btn" & i & "Tg" & j & k).backColor = 8972484
                            End If
                        Next p
                    End If
                    If i = 2 And l = tmpdy Then 'Den bisher aktuell gewählten Tag markieren
                        xFrm("btn" & i & "Tg" & j & k).BackStyle = 1
                        xFrm("btn" & i & "Tg" & j & k).SpecialEffect = 2
                        Set Global_PrevCtrl = xFrm("btn" & i & "Tg" & j & k)
                    End If
                End If
            End If
        Next k
    Next j
Next i

xFrm!AktDat = XAktDat   'DAS Bezugsfeld
xFrm!txtMonth = Format(XAktDat, "mmmm", vbMonday, vbFirstFourDays)  'Anzeige des Monats in der Mitte (der 3 Monate)
xFrm!YearNr = Format(XAktDat, "yyyy", vbMonday, vbFirstFourDays)      'Anzeige des aktuellen Jahres in der Mitte

''Eines der kleinen 8 übernanderliegenden Mondphasenbilder sichtbar setzen
For i = 1 To 8
    xFrm("Moon" & i).Visible = False
Next i

Moonx = "Moon" & Mondphase(XAktDat)
xFrm(Moonx).Visible = True

End Function

Function FeiertageimMonat(XDatum As Date, XBund As String, Feianz As Integer, xdat() As Date, XDatNam() As String)
Dim db As DAO.Database
Dim rst As DAO.Recordset
Dim Krit As String
Dim i As Integer
ReDim xdat(1 To 31)
ReDim XDatNam(1 To 31)
FeiertageimMonat = ""
Krit = "SELECT qryHlp_Feiertag.Feiertagsdat, qryHlp_Feiertag.Feiertagsname FROM qryHlp_Feiertag "
Krit = Krit & "WHERE qryHlp_Feiertag.Feiertagsdat >= " & SQLDatum(ErsterDesMonats(XDatum))
Krit = Krit & " AND qryHlp_Feiertag.Feiertagsdat <= " & SQLDatum(LetzterDesMonats(XDatum)) & " AND qryHlp_Feiertag." & XBund & "=True ;"
Set db = CurrentDb
Set rst = db.OpenRecordset(Krit, dbOpenDynaset)
i = 1
Do While Not rst.EOF
                
    rst.Edit
    
    FeiertageimMonat = FeiertageimMonat & Format(rst.fields(0), "dd.mm", vbMonday, vbFirstFourDays)
    FeiertageimMonat = FeiertageimMonat & " " & rst.fields(1) & vbCrLf
    
    xdat(i) = rst.fields(0)
    XDatNam(i) = rst.fields(1)
    rst.MoveNext
    i = i + 1
Loop
Feianz = i - 1
rst.Close
Set rst = Nothing
Set db = Nothing

End Function



'#################################################################################################
'''''''''''' Mondphasenberechnung
'#################################################################################################

Function Mondphase_Prom(Optional ByVal XDatum As Date) As Integer

'Rückgabe: Mondphase in Promille (als Teil einer kompletten Mondphase zwischen Vollmond und Vollmond)

'   0 o/oo = Vollmond
' 250 o/oo = Halbmond abnehmend
' 500 o/oo = Neumond
' 750 o/oo = Halbmond zunehmend
'1000 o/oo = Vollmond

'Achtung: Berechnung kann um einen Tag + / - differieren ...

'Beispiel: Der Wert für den 29.4.1999 ist 977
'          Der Wert für den 30.4.1999 ist 011

'D.h. am 29.4.1999 um 0:00 Uhr fehlen noch ca. 23 tausendstel (einer Mondphase) bis zum Vollmond, wärend
'am 30.4.1999 um 0:00 Uhr bereits 11 tausendstel (einer Mondphase) schon wieder vorbei sind.

'Die Frage: Wann exakt ist Vollmond ? bleibt also bestehen.

'Ich habe in der Funktion Mondphase (willkürlich) folgende vier "Stichtage" festgelegt:
'Wenn die Intervalle geändert werden, erhält man manchmal mehr als einen Tag pro Phase,
'und das wollte ich vermeiden
'Wenn der Mondphasenwert >= 982 oder <=  15 (Moon5) ist, dann ist Vollmond.
'Wenn der Mondphasenwert >= 482 oder <= 515 (Moon1) ist, dann ist Neumond.
'Wenn der Mondphasenwert >= 232 oder <= 265 (Moon7) ist, dann ist Halbmond (abnehmend).
'Wenn der Mondphasenwert >= 732 oder <= 765 (Moon3) ist, dann ist Halbmond (zunehmend).
'ansonsten sind es einfach "zunehmende" oder "abnehmende" Mondphasen mit jeweils mehreren Tagen

'frmKalender enthält 8 Mondphasenbilder (ico), von denen immer nur eines sichtbar ist.
'Die zurückgegebenen Nummern 1 - 8 entsprechen dem Bildnamen ...
'Die Namen sind Moon1 bis Moon8

'Mondphasenberechnung: (Info aus einer Newsgroup)
'Well, you can calculate this fairly easily by knowing the length of the
'lunar cycle (29.5302 days), a known full moon in the past (Nov. 11, 1753
'is a good one since it is after the Gregorian reformation and the full
'moon was at almost exactly 0:00 GMT), and a formula for calculating the
'number of days between two dates (these are readily available).
'
'For example:  I was born Aug. 11, 1964.  I need to calculate the number
'of days since Nov. 11, 1753.
'Number of days (VBA: datediff)
    '1964-1753 = 211 years
    '211*365 = 77015 days.
    '211/4 = 52.75 = 53 leap days
    '1800, and 1900 were not leap years so 51 leap days
    '77015+51 = 77066
    'subtract 30 days for Sep, and 31 days for Oct, (31-11) for Aug, and 11
    'days for Nov
    '77066-30-31-20-11 = 76974 days (a good Julian date calculator would make
    'this much easier.)
'Divide this (number of days) by the lunar cycle of 29.5302 days:
'76974/29.5302 = 2606.62
'So the moon is 62% into the cycle where 50% would be a new moon and 100% (or
'0%) would be full moon.

Const vglDat As Date = #11/11/1753#
Const Mooncyc As Double = 29.5302

Dim xdat As Double

On Error Resume Next

If (Not IsDate(XDatum)) Or (IsMissing(XDatum) Or (XDatum = 0)) Then XDatum = Date

xdat = Abs(DateDiff("d", vglDat, XDatum, vbMonday, vbFirstFourDays))
xdat = xdat / Mooncyc
Mondphase_Prom = CInt((xdat - Int(xdat)) * 1000)
End Function

Function Mondphase(Optional ByVal XDatum As Date, Optional AlsZahl As Boolean = True) As Variant
Dim XTm As Integer

If (Not IsDate(XDatum)) Or (IsMissing(XDatum) Or (XDatum = 0)) Then XDatum = Date

XTm = Mondphase_Prom(XDatum)

If XTm >= 982 Or XTm <= 15 Then
    If AlsZahl = False Then
        Mondphase = "Vollmond"
    Else
        Mondphase = 5
    End If
    Exit Function
End If

If XTm >= 482 And XTm <= 515 Then
    If AlsZahl = False Then
        Mondphase = "Neumond"
    Else
        Mondphase = 1
    End If
    Exit Function
End If

If (XTm >= 232 And XTm <= 265) Then
    If AlsZahl = False Then
        Mondphase = "Halbmond (abnehmend)"
    Else
        Mondphase = 7
    End If
    Exit Function
End If

If (XTm >= 732 And XTm <= 765) Then
    If AlsZahl = False Then
        Mondphase = "Halbmond (zunehmend)"
    Else
        Mondphase = 3
    End If
    Exit Function
End If
'
'Nur, wenn nicht bereits direkt Neu- Voll- oder Halbmond angezeigt wurde
If XTm >= 0 And XTm <= 250 Then
    If AlsZahl = False Then
        Mondphase = "Abnehmender Mond (Vollmond -> Halbmond) - " & XTm & " o/oo"
    Else
        Mondphase = 6
    End If
    Exit Function
End If

If XTm > 250 And XTm <= 500 Then
    If AlsZahl = False Then
        Mondphase = "Abnehmender Mond (Halbmond -> Neumond) - " & XTm & " o/oo"
    Else
        Mondphase = 8
    End If
    Exit Function
End If

If XTm > 500 And XTm <= 750 Then
    If AlsZahl = False Then
        Mondphase = "Zunehmender Mond (Neumond -> Halbmond) - " & XTm & " o/oo"
    Else
        Mondphase = 2
    End If
    Exit Function
End If

If XTm > 750 And XTm <= 1000 Then
    If AlsZahl = False Then
        Mondphase = "Zunehmender Mond (Halbmond -> Vollmond) - " & XTm & " o/oo"
    Else
        Mondphase = 4
    End If
    Exit Function
End If

End Function


Function Mp_Tst1(Optional ByVal XDatum As Date, Optional j As Integer = 99)
Dim i As Integer
If (Not IsDate(XDatum)) Or (IsMissing(XDatum) Or (XDatum = 0)) Then XDatum = Date
For i = 1 To j
    Debug.Print Mondphase_Prom(XDatum + i)
Next i
End Function


Function Mp_Tst2(Optional ByVal XDatum As Date, Optional ByVal j As Integer = 99)
Dim xx As String, xy As String
Dim i As Integer
If (Not IsDate(XDatum)) Or (IsMissing(XDatum) Or (XDatum = 0)) Then XDatum = Date
For i = 1 To j
    xx = Mondphase(XDatum + i, False)
    xy = Left(xx, 1)
    If xy = "N" Or xy = "V" Or xy = "H" Then
        Debug.Print xx & " " & Format(XDatum + i, "dd.mm.yyyy", vbMonday, vbFirstFourDays)
    End If
Next i
End Function


Function Tage360(ByVal StartDatum As Date, ByVal endDatum As Date) As Long
' Berechnen Tage 360 nach Bankregel
' Newsgroup: Elmar Boye
    If DatePart("d", StartDatum) > 30 Then
        StartDatum = StartDatum - 1
    End If
    If DatePart("d", endDatum) > 30 Then
        endDatum = endDatum - 1
    End If
    If StartDatum > endDatum Then
        Tage360 = (DatePart("d", StartDatum) - DatePart("d", endDatum) + _
        (DatePart("m", StartDatum) - DatePart("m", endDatum)) * 30 + _
        (DatePart("yyyy", StartDatum) - DatePart("yyyy", endDatum)) * 360) * -1
    Else
        Tage360 = DatePart("d", endDatum) - DatePart("d", StartDatum) + _
        (DatePart("m", endDatum) - DatePart("m", StartDatum)) * 30 + _
        (DatePart("yyyy", endDatum) - DatePart("yyyy", StartDatum)) * 360
    End If
End Function


'Zufallsdatum erzeugen
Function RandomDatum(Optional ByVal JahrVon As Long = 1900, Optional ByVal Jahrbis As Long = 2010, Optional ByVal MonVon = 1, Optional ByVal MonBis = 12, Optional ByVal NurWerktage As Boolean = False) As Date

Dim TagesNr As Long
Dim MonatsNr As Long
Dim JahresNr As Long

Dim ZufDat As Date

Randomize

' Verwenden Sie die folgende Formel, um ganzzahlige Zufallszahlen innerhalb eines bestimmten
' Bereichs zu erzeugen:
' Wert1 = Int((Obergrenze - Untergrenze + 1) * Rnd + Untergrenze)
' Obergrenze steht hier für die größte Zahl des Bereichs und Untergrenze für die kleinste Zahl des Bereichs.

Rand_Start:
    TagesNr = Int((31 - 1 + 1) * Rnd + 1)
    MonatsNr = Int((MonBis - MonVon + 1) * Rnd + MonVon)
    JahresNr = Int((Jahrbis - JahrVon + 1) * Rnd + JahrVon)
    ZufDat = DateSerial(JahresNr, MonatsNr, TagesNr)

If NurWerktage And Weekday(ZufDat, vbMonday) > 5 Then GoTo Rand_Start

RandomDatum = ZufDat

End Function


Function fWeekNos(Optional startDate, Optional lng_MaxWeek As Long = 217)

Dim istartWeek As Long
Dim iStartYear As Long
Dim iWeekday As Long
Dim iweekno As Long
Dim i As Long
Dim j As Long
Dim k As Long
Dim l As Long
Dim iM As Long
Dim iJ As Long
Dim lMon As Long
Dim lJahr As Long
Dim iMaxWeek(10) As Long
Dim iMaxYear(10) As Long

'Debug.Print Now()

'Dim MonNamen
'MonNamen = Array("Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez")
'Woche1 = Array("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So")

ReDim allWeekNo(1 To lng_MaxWeek)
ReDim allMonNo(1 To lng_MaxWeek)
ReDim allJahrNo(1 To lng_MaxWeek)
ReDim allJahrWeekNo(1 To lng_MaxWeek)

If IsMissing(startDate) Or Not IsDate(startDate) Then
'    StartDate = Date
    startDate = DateSerial(2007, 9, 1)
End If

startDate = startDate - (Weekday(startDate, 2) - 1)

iStartYear = Year(startDate)
If startDate < DateSerial(Year(startDate), 12, 28) Then
    istartWeek = Format(startDate, "ww", vbMonday, vbFirstFourDays)
Else
    iStartYear = iStartYear + 1
    istartWeek = 1
    startDate = fctKWMon(1, iStartYear)
End If

For i = 0 To 10
    iMaxWeek(i) = MaxWeekNo(iStartYear + i)
    iMaxYear(i) = iStartYear + i
Next i

' Die Woche gehört zum Monat mit dem Donnerstag der Woche
lMon = Month(startDate + 3)
lJahr = iStartYear
j = istartWeek
k = 0

For l = 1 To lng_MaxWeek
    
'Dim allWeekNo(0 To 2, 1 To CONST_MaxWeek)
' 0 = Wochennr  -  1 = MonatsNr  - 2 = JahresNr
    
    allWeekNo(l) = j
    allMonNo(l) = Month(fctKWMon(j, lJahr) + 3)  ' Der Donnerstag der Woche
    allJahrNo(l) = lJahr
    allJahrWeekNo(l) = lJahr & Right("00" & allWeekNo(l), 2)
    
    j = j + 1
    If j > iMaxWeek(k) Then
        lJahr = lJahr + 1
        j = 1
        k = k + 1
    End If
Next l

'Debug.Print allWeekNo(LBound(allWeekNo))
'Debug.Print allMonNo(LBound(allMonNo))
'Debug.Print allJahrNo(LBound(allJahrNo))
'
'Debug.Print allWeekNo(UBound(allWeekNo))
'Debug.Print allMonNo(UBound(allMonNo))
'Debug.Print allJahrNo(UBound(allJahrNo))
'
'Debug.Print Now()

End Function

Function fYrweekNo(ByVal x As Date, Optional ByVal y As Long = 0) As Long
' Gibt YYYYWW des Datums zurück (Workaround,
' da das Format "ww" beim Jahreswechsel einige Macken hat)
'Zusatzparameter y =    0 Alles,  1 Nur KW, 2 Nur JJ

Dim iYr As Long
Dim iyr1 As Long
Dim iwk As Long

If Not IsDate(x) Then
    fYrweekNo = -1
    Exit Function
End If

iYr = Year(x)
iwk = Format(x, "ww", vbMonday, vbFirstFourDays)
iyr1 = Year(x + 7)
If Format(x + 7, "ww", vbMonday, vbFirstFourDays) = 2 Then
    iwk = 1
    iYr = iyr1
End If

If iwk > 50 And Month(x) = 1 Then iYr = iYr - 1

Select Case y
    Case 0
        fYrweekNo = (iYr * 100) + iwk
    Case 1
        fYrweekNo = iwk
    
    Case 2
        fYrweekNo = iYr
    
    Case Else
        fYrweekNo = (iYr * 100) + iwk
    
End Select

End Function


Function TestAufMontag()
Call TestWochenAnfangEnde(0)
End Function

Function TestAufSonntag()
Call TestWochenAnfangEnde(6)
End Function


Function TestWochenAnfangEnde(ByVal WochentagsNr As Long)
' WochentagsNr 0 = Montag
' WochentagsNr 6 = folgender Sonntag

If WochentagsNr < 0 Then WochentagsNr = 0
If WochentagsNr > 6 Then WochentagsNr = 6

Dim ctlCurrentControl As control
Dim strControlName As String
Dim IstDate As Date
Dim strFormName As String
Dim frmCurrentForm As Form

Set frmCurrentForm = Screen.ActiveForm
Set ctlCurrentControl = Screen.ActiveControl

strFormName = frmCurrentForm.Name
strControlName = ctlCurrentControl.Name

If IsDate(ctlCurrentControl.Value) Then
    IstDate = ctlCurrentControl.Value
    IstDate = IstDate + 1 - Weekday(IstDate, vbMonday) + WochentagsNr
    ctlCurrentControl.Value = IstDate
'    MsgBox strFormName & " - " & strControlName & " - " & Format(IstDate, "dddddd")
Else
    If Len(Trim(Nz(ctlCurrentControl.Value))) > 0 Then
       MsgBox strFormName & " - " & strControlName & " - Is Nix"
    End If
End If

End Function

Function TestWochenAnfangEndeDate(ByVal x As Date, Optional ByVal WochentagsNr As Long = 0) As Date
' WochentagsNr 0 = Montag
' WochentagsNr 6 = folgender Sonntag

Dim IstDate As Date

If WochentagsNr < 0 Then WochentagsNr = 0
If WochentagsNr > 6 Then WochentagsNr = 6
If IsDate(x) Then
    IstDate = x
    IstDate = IstDate + 1 - Weekday(IstDate, vbMonday) + WochentagsNr
    TestWochenAnfangEndeDate = IstDate
'    MsgBox strFormName & " - " & strControlName & " - " & Format(IstDate, "dddddd")
Else
    TestWochenAnfangEndeDate = 0
End If

End Function

Function WochenMo(x As Variant) As Date

' Übergabe String "ww/yy"
'  also 17/07

Dim iWo As Long
Dim ijr As Long

Dim iSl As Long

iSl = InStr(1, x, "/")

If iSl > 0 Then
    iWo = Mid(x, 1, iSl - 1)
    ijr = Mid(x, iSl + 1) + 2000
    WochenMo = fctKWMon(iWo, ijr)
Else
    WochenMo = 0
End If

End Function


Function WochenMo4(x As Variant) As Date

' Übergabe String "ww/yyyy"
'  also 17/2007

Dim iWo As Long
Dim ijr As Long

Dim iSl As Long

If Len(Trim(Nz(x))) = 0 Then Exit Function

iSl = InStr(1, x, "/")

If iSl > 0 Then
    iWo = Mid(x, 1, iSl - 1)
    ijr = Mid(x, iSl + 1)
    WochenMo4 = fctKWMon(iWo, ijr)
Else
    WochenMo4 = 0
End If

End Function

Function WochenMo4X(x As Variant) As Date

' Übergabe Zahl yyyyww
'  also 200717

Dim iWo As Long
Dim ijr As Long

Dim iSl As Long

If Len(Trim(Nz(x))) <> 6 Then Exit Function

ijr = Left(x, 4)
iWo = Right(x, 2)
WochenMo4X = fctKWMon(iWo, ijr)

End Function



Function KWDiffber0(StartKW As Long, EndKW As Long) As Long

'Verwendet Tabelle tblHilfKW daher nur zwischen 2005 und 2035 verwendbar

Dim StartJahr As Long
Dim EndJahr As Long
Dim StartKW1 As Long
Dim EndKW1 As Long
Dim Diff1 As Long

StartJahr = Left(StartKW, 4)
EndJahr = Left(EndKW, 4)

If StartJahr = EndJahr Then
    Diff1 = EndKW - StartKW + 1
Else
    Diff1 = TCount("JJJJKW", "tblHilfKW", "JJJJKW >= " & StartKW & " AND JJJJKW <= " & EndKW)
End If

KWDiffber0 = Diff1

End Function


Function KWDiffber1(StartKW As Long, EndKW As Long, GesAnzKW As Long) As Long

'Verwendet Tabelle tblHilfKW daher nur zwischen 2005 und 2035 verwendbar

Dim StartJahr As Long
Dim EndJahr As Long
Dim StartKW1 As Long
Dim EndKW1 As Long
Dim Diff1 As Long

StartJahr = Left(StartKW, 4)
EndJahr = Left(EndKW, 4)

If StartJahr = EndJahr Then
    Diff1 = EndKW - StartKW + 1
Else
    Diff1 = TCount("JJJJKW", "tblHilfKW", "JJJJKW >= " & StartKW & " AND JJJJKW <= " & EndKW)
End If

KWDiffber1 = GesAnzKW - Diff1

End Function


Function fYrweekNoPretty(x As Date) As Variant
' Gibt "ww / yyyy (tt.mm.jjjj)" zurück
Dim iYr As Long
Dim iyr1 As Long
Dim iwk As Long
Dim iwk1 As Long

iYr = Year(x)
iwk = Format(x, "ww", vbMonday, vbFirstFourDays)
iyr1 = Year(x + 7)
If Format(x + 7, "ww", vbMonday, vbFirstFourDays) = 2 Then
    iwk = 1
    iYr = iyr1
End If

fYrweekNoPretty = Right("00" & iwk, 2) & " / " & iYr & " - (" & Format(x, "dd.mm.yyyy", 2, 2) & ")"

End Function

Function HW_GibNr(JJJJKW As Long) As Long
HW_GibNr = TLookup("LfdNr", "tblHilfKW", "JJJJKW = " & JJJJKW)
End Function

Function HWDat_GibNr(x As Date) As Long
Dim JJJJKW As Long
JJJJKW = fYrweekNo(x)
HWDat_GibNr = TLookup("LfdNr", "tblHilfKW", "JJJJKW = " & JJJJKW)
End Function

Function HW_GibKW(LfdNr As Long) As Long
HW_GibKW = TLookup("JJJJKW", "tblHilfKW", "LfdNr = " & LfdNr)
End Function

Function HW_GibJJ(LfdNr As Long) As Long
HW_GibJJ = TLookup("Jahr", "tblHilfKW", "LfdNr = " & LfdNr)
End Function


Function HW_GibDat(LfdNr As Long) As Date
HW_GibDat = TLookup("StartDatum", "tblHilfKW", "LfdNr = " & LfdNr)
End Function


Function IsLeapYear(dt As Date) As Boolean
IsLeapYear = (CLng(Format(DateSerial(Year(dt), 12, 31), "y", 2, 2)) - 365) * -1
End Function


Function HWL_GibXlNr(JJJJKW As Long) As Long
HWL_GibXlNr = TLookup("SpalteNr", "tblHilfKWLokal", "JJJJKW = " & JJJJKW)
End Function

Function HWLDat_GibXLNr(x As Date) As Long
Dim JJJJKW As Long
JJJJKW = fYrweekNo(x)
HWLDat_GibXLNr = TLookup("SpalteNr", "tblHilfKWLokal", "JJJJKW = " & JJJJKW)
End Function

'Function HW_GibNr(JJJJKW As Long) As Long
'Function HWDat_GibNr(x As Date) As Long

'Function HWL_GibXLNr(JJJJKW As Long) As Long
'Function HWLDat_GibXLNr(x As Date) As Long

'Function HW_GibKW(LfdNr As Long) As Long
'Function HW_GibDat(LfdNr As Long) As Date
'Function HW_GibJJ(LfdNr As Long) As Long



Public Function LaufMon2DateMon(iMon As Long, Optional istartJahr As Long = 0, Optional istartMon As Long = 0) As Date
If istartJahr = 0 Then istartJahr = Year(Date)
If istartMon = 0 Then istartMon = Month(Date)
Dim i As Long, i1 As Long, iYr As Long
iYr = istartJahr
i1 = istartMon
i = iMon
If istartMon <> 1 Then
    i = i + i1 - 1
    If i > 12 Then
        i = i - 12
        iYr = iYr + 1
    End If
End If

LaufMon2DateMon = DateSerial(iYr, i, 1)
End Function

Public Function DateMon2LaufMon(iMon As Long, Optional istartJahr As Long = 0, Optional istartMon As Long = 0) As Date
If istartJahr = 0 Then istartJahr = Year(Date)
If istartMon = 0 Then istartMon = Month(Date)
Dim i As Long, i1 As Long, iYr As Long
iYr = istartJahr
i = iMon
i1 = i
If istartMon <> 1 Then
    i1 = iMon - istartMon + 1
    If i1 < 1 Then
        i1 = i1 + 12
        iYr = iYr + 1
    End If
End If

DateMon2LaufMon = DateSerial(iYr, i1, 1)
End Function

Public Function btn2Date(btnName As String, Optional istartJahr As Long = 0, Optional istartMon As Long = 0) As Date
If istartJahr = 0 Then istartJahr = Year(Date)
If istartMon = 0 Then istartMon = Month(Date)
' Me("btn" & i1 & "Tg" & j & k)

Dim x, ilMon, iKW, iwt, i, iTag, i1 As Long, ijr, dt1, wkd1
x = btnName
x = Mid(x, 4)
i = InStr(1, x, "Tg")
i1 = Mid(x, 1, i - 1)
x = Mid(x, i + 2)
iKW = Left(x, 1)
iwt = Right(x, 1)
dt1 = LaufMon2DateMon(i1, istartJahr, istartMon)
wkd1 = Weekday(DateSerial(Year(dt1), Month(dt1), 1), 2)
iTag = (iKW * 7) + iwt - wkd1 + 1

btn2Date = DateSerial(Year(dt1), Month(dt1), iTag)
End Function



Public Function Date2btn(btnDatum As Date, Optional istartJahr As Long = 0, Optional istartMon As Long = 0) As String
If istartJahr = 0 Then istartJahr = Year(Date)
If istartMon = 0 Then istartMon = Month(Date)
'Me("btn" & i1 & "Tg" & j & k)
Dim dt1 As Date, i1 As Long
 dt1 = DateMon2LaufMon(Month(btnDatum), istartJahr, istartMon)
 i1 = Month(dt1)

'iday: Tag ([KalDatum])
'idiwk: Format(DatSeriel([iJahr];[i];1);"w";2;2)-1
'ikw: (([iday]+[diwk]-1)\7)+1
'btnname: "btn" & [i1] & "Tg" & [kw] & [WochentagNr]
'ijahr: Jahr ([KalDatum])
'i: Monat ([KalDatum])
'i1: Monat ([in der Maske])
Dim iday, idiwk, iKW, iwotg, iJahr, i
iJahr = Year(btnDatum)
i = Month(btnDatum)
iday = Day(btnDatum)
idiwk = Format(DateSerial(iJahr, i, 1), "w", 2, 2) - 1 ' Wochentag Monatsanfang
iKW = ((iday + idiwk - 1) \ 7) + 1
iwotg = Format(btnDatum, "w", 2, 2)
Date2btn = "btn" & i1 & "Tg" & iKW & iwotg

End Function



Function StdZeitraum_Von_Bis(Zeitraum As Long, Me_vonDat As Date, Me_bisDat As Date)

    Dim iwkday As Long
    Dim iQ As Long
    Dim iM As Long
    
    'Sort     'ID Bemerkung
    '1        '1   Heute
    '2        '17  Die nächsten 90 Tage
    '3        '4   Aktuelle Woche
    '4        '8   Aktueller Monat
    '5        '14  Aktuelles Quartal
    '6        '11  Aktuelles Jahr
    '7        '18  Nächster Monat
    '8        '19  Die nächsten 90 Tage
    '9        '20  Nächstes Jahr
    '
    '10        '2   Gestern
    '11        '3   Vorgestern
    '12        '5   Die letzten 7 Tage
    '13        '6   Letzte Woche
    '14        '7   Vorletzte Woche
    '15        '15  Letztes Quartal
    '16        '16  Die letzten 90 Tage
    '17        '9   Letzter Monat
    '18        '10  Vorletzter Monat
    '19        '12  Letztes Jahr
    '20        '13  Vorletztes Jahr
    '750       '21  Nächstes Quartal
    '201       '23  Die nächsten 10 Tage
    
    iwkday = Weekday(Date, 2)
    
    Select Case Zeitraum
        Case 2
            Me_vonDat = Date - 1
            Me_bisDat = Date - 1
        Case 3
            Me_vonDat = Date - 2
            Me_bisDat = Date - 2
        Case 4
            Me_vonDat = Date - iwkday + 1
            Me_bisDat = Date - iwkday + 6
        Case 5
            Me_vonDat = Date - 6
            Me_bisDat = Date
        Case 6
            Me_vonDat = Date - iwkday + 1 - 7
            Me_bisDat = Date - iwkday
        Case 7
            Me_vonDat = Date - iwkday + 1 - 14
            Me_bisDat = Date - iwkday - 7
        Case 8
            Me_vonDat = DateSerial(Year(Date), Month(Date), 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date) + 1, 0)
        Case 9
            Me_vonDat = DateSerial(Year(Date), Month(Date) - 1, 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date), 0)
        Case 10
            Me_vonDat = DateSerial(Year(Date), Month(Date) - 2, 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date) - 1, 0)
        Case 11
            Me_vonDat = DateSerial(Year(Date), 1, 1)
            Me_bisDat = DateSerial(Year(Date), 12, 31)
        Case 12
            Me_vonDat = DateSerial(Year(Date) - 1, 1, 1)
            Me_bisDat = DateSerial(Year(Date) - 1, 12, 31)
'        Case 13
'            Me_vonDat = DateSerial(Year(Date) - 2, 1, 1)
'            Me_bisDat = DateSerial(Year(Date) - 2, 12, 31)
        Case 13
            Me_vonDat = DateSerial(Year(Date), Month(Date) - 2, 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date), -1)
'        Case 14
'            iQ = Format(Date, "q", 2, 2)
'            iM = (iQ - 1) * 3 + 1
'            Me_vonDat = DateSerial(Year(Date), iM, 1)
'            Me_bisDat = DateSerial(Year(Date), iM + 3, 0)
        Case 14
            Me_vonDat = DateSerial(Year(Date), Month(Date) - 3, 1)
            Me_bisDat = DateSerial(Year(Date), Month(Date), -1)
        Case 15
            iQ = Format(Date, "q", 2, 2)
            iM = (iQ - 1) * 3 + 1
            Me_vonDat = DateSerial(Year(Date), iM - 3, 1)
            Me_bisDat = DateSerial(Year(Date), iM, 0)
        Case 16
            Me_bisDat = Date
            Me_vonDat = Date - 90
        Case 17
            Me_bisDat = Date + 90
            Me_vonDat = Date
        Case 18
            Me_bisDat = DateSerial(Year(Date), Month(Date) + 2, 0)
            Me_vonDat = DateSerial(Year(Date), Month(Date) + 1, 1)
        Case 19
            Me_bisDat = Date + 90
            Me_vonDat = Date
        Case 20
            Me_vonDat = DateSerial(Year(Date) + 1, 1, 1)
            Me_bisDat = DateSerial(Year(Date) + 1, 12, 31)
        Case 21
            iQ = Format(Date, "q", 2, 2)
            iM = ((iQ - 1) * 3 + 1) + 3
            Me_vonDat = DateSerial(Year(Date), iM, 1)
            Me_bisDat = DateSerial(Year(Date), iM + 3, 0)
        
        Case 22
            Me_vonDat = Date
            Me_bisDat = Date + 30
        
        Case 23
            Me_vonDat = Date
            Me_bisDat = Date + 10
        
        Case 24
            Me_vonDat = Date
            Me_bisDat = Date + 14
        
        Case 25
            Me_vonDat = Date
            Me_bisDat = Date + 1000
        
        Case 26
            Me_vonDat = DateSerial(Year(Date), 1, 1)
            Me_bisDat = Date
            
        Case 27
            Me_vonDat = Date + 1
            Me_bisDat = Date + 1000
        
        Case Else ' Heute
            Me_vonDat = Date
            Me_bisDat = Date
    End Select
    DoEvents

End Function