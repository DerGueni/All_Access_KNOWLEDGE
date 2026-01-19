Option Compare Database
Option Explicit

'************************** Code Start ***********************
'This code was originally written by Terry Kreft & Michel Walsh
'It is not to be altered or distributed,
'except as part of an application.
'You are free to use it in any application,
'provided the copyright notice is left unchanged.
'
'Code courtesy of
'Terry Kreft & Michel Walsh
'
Type SYSTEMTIME
  wYear As Integer
  wMonth As Integer
  wDayOfWeek As Integer
  wDay As Integer
  wHour As Integer
  wMinute As Integer
  wSecond As Integer
  wMilliseconds As Integer
End Type

Type TIME_ZONE_INFORMATION
  Bias As Long
  StandardName(31) As Integer
  StandardDate As SYSTEMTIME
  StandardBias As Long
  DaylightName(31) As Integer
  DaylightDate As SYSTEMTIME
  DaylightBias As Long
End Type

Declare PtrSafe Function GetTimeZoneInformation Lib "kernel32" _
  (lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long

Function PreciseDateDiff(Interval As String, ByVal Date1, ByVal Date2, _
                        Optional FirstDayOfWeek As Integer = vbSunday, _
                        Optional FirstWeekOfYear As Integer = vbFirstJan1) _
                        As Long
'From an original idea by Michel Walsh
'Get a DateDiff, taking into account the time light saving
'
'Usage Example:
'
'   ? PreciseDateDiff("h", #1/1/90#, #5/5/98#)
'
  Dim lngRet As Long
  Dim tzi As TIME_ZONE_INFORMATION
  Dim strEval As String
  If Eval("'" & Interval & "' in ('h','n','s')") Then
    If FirstDayOfWeek >= 0 And FirstDayOfWeek <= 7 Then
      If FirstWeekOfYear >= 0 And FirstWeekOfYear <= 3 Then
        lngRet = GetTimeZoneInformation(tzi)
        strEval = DateForSQL(Date1) & " between " _
                & DateForSQL(SummerTime(Year(Date1))) & " and " _
                & DateForSQL(StandardTime(Year(Date1)))
        If Eval(strEval) Then
          Date1 = DateAdd("n", tzi.DaylightBias, Date1)
        End If
        strEval = DateForSQL(Date2) & " between " _
                & DateForSQL(SummerTime(Year(Date2))) & " and " _
                & DateForSQL(StandardTime(Year(Date2)))
        If Eval(strEval) Then
          Date2 = DateAdd("n", tzi.DaylightBias, Date2)
        End If
        lngRet = DateDiff(Interval, Date1, Date2, _
                                    FirstDayOfWeek, FirstWeekOfYear)
        PreciseDateDiff = lngRet
      End If
    End If
  Else
    PreciseDateDiff = DateDiff(Interval, Date1, Date2, FirstDayOfWeek, FirstWeekOfYear)
  End If
End Function

Private Function DateForSQL(dteDate) As String
  DateForSQL = Format(dteDate, "\#m/dd/yyyy h:nn:ss AM/PM \#")
End Function


Public Function SummerTime(Optional intYear As Long = -1) As Date
    ' Originally submitted by Terry Kreft
    '   modified to accept an optional year

    If -1 = intYear Then intYear = Year(Date)
    ' Get this year, by defaut, not -1
    
    Dim lngRet As Long
    Dim tzi As TIME_ZONE_INFORMATION
    lngRet = GetTimeZoneInformation(tzi)
    With tzi.DaylightDate
        SummerTime = CVDate(GetSundate(.wMonth, .wDay, _
                                    intYear) + (.wHour / 24))
    End With
End Function

Public Function StandardTime(Optional intYear As Long = -1) As Date
    ' Originally submitted by Terry Kreft
    '   modified to accept an optinal year

    If -1 = intYear Then intYear = Year(Date)
    ' Get this year, by defaut, not -1
    
    Dim lngRet As Long
    Dim tzi As TIME_ZONE_INFORMATION
    lngRet = GetTimeZoneInformation(tzi)
    With tzi.StandardDate
        StandardTime = CVDate(GetSundate(.wMonth, .wDay, _
                                    intYear) + (.wHour / 24))
    End With
End Function

Private Function GetSundate(intMonth As Integer, _
                            intSun As Integer, _
                            Optional intYear As Long = -1) _
                            As Date
' Originally submitted by Terry Kreft
'   Modified to set any Year

    If intYear = -1 Then intYear = Year(Date)
    ' if not supplied, get this Year
    
    Dim varRet As Variant
    Dim intDayOfWeek As Integer
    
    varRet = DateSerial(intYear, intMonth, 1)
    ' avoid regional setting problem
    
    intDayOfWeek = Weekday(varRet)
    If intDayOfWeek <> 1 Then
        varRet = DateAdd("d", 8 - intDayOfWeek, varRet)
    End If
    varRet = DateAdd("ww", intSun - 1, varRet)
    GetSundate = varRet
End Function
'************************** Code End ***********************

Function ISSummerTime(Optional dtDate1) As Boolean
Dim iYear As Long
Dim dtDate As Date

If IsNull(dtDate1) Then
    dtDate = Now()
Else
    If Not IsDate(dtDate1) Then
        dtDate = Now()
    Else
        dtDate = dtDate1
    End If
End If
iYear = Year(dtDate)
If dtDate >= SummerTime(iYear) And dtDate < StandardTime(iYear) Then
    ISSummerTime = True
Else
    ISSummerTime = False
End If
End Function