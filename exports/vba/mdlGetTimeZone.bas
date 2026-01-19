Attribute VB_Name = "mdlGetTimeZone"
Option Compare Database
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Copyright ©1996-2011 VBnet/Randy Birch, All Rights Reserved.
' Some pages may also contain other copyrights by the author.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Distribution: You can freely use this code in your own
'               applications, but you may not reproduce
'               or publish this code on any web site,
'               online service, or distribute as source
'               on any media without express permission.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Const TIME_ZONE_ID_UNKNOWN As Long = 1
Private Const TIME_ZONE_ID_STANDARD As Long = 1
Private Const TIME_ZONE_ID_DAYLIGHT As Long = 2
Private Const TIME_ZONE_ID_INVALID As Long = &HFFFFFFFF

Private Type SYSTEMTIME
   wYear         As Integer
   wMonth        As Integer
   wDayOfWeek    As Integer
   wDay          As Integer
   wHour         As Integer
   wMinute       As Integer
   wSecond       As Integer
   wMilliseconds As Integer
End Type

Private Type TIME_ZONE_INFORMATION
   Bias As Long
   StandardName(0 To 63) As Byte  'unicode (0-based)
   StandardDate As SYSTEMTIME
   StandardBias As Long
   DaylightName(0 To 63) As Byte  'unicode (0-based)
   DaylightDate As SYSTEMTIME
   DaylightBias As Long
End Type

Private Declare PtrSafe Function GetTimeZoneInformation Lib "kernel32" _
    (lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long



'Private Sub Form_Load()
'
'   Command1.Caption = "Get Time Zone Bias"
'
'End Sub

'
'Private Sub Command1_Click()
'
'   Label1.Caption = Format$(Now, "dddd mmm dd, yyyy hh:mm:ss am/pm")
'
'   Text1.Text = GetCurrentTimeZone()
'   Text2.Text = GetCurrentTimeBias()
'   Text3.Text = GetCurrentGMTDate()
'
'   Text4.Text = GetStandardTimeBias()
'   Text5.Text = GetDaylightTimeBias()
'
'End Sub
'

Function GetDaylightTimeBias() As String

   Dim TZI As TIME_ZONE_INFORMATION
   Dim dwBias As Long
   Dim tmp As String

   Call GetTimeZoneInformation(TZI)
   
   dwBias = TZI.Bias + TZI.DaylightBias
   tmp = CStr(dwBias \ 60) & " hours, " & CStr(dwBias Mod 60) & " minutes"

   GetDaylightTimeBias = tmp

End Function


Function GetStandardTimeBias() As String

   Dim TZI As TIME_ZONE_INFORMATION
   Dim dwBias As Long
   Dim tmp As String

   Call GetTimeZoneInformation(TZI)

   dwBias = TZI.Bias + TZI.StandardBias
   tmp = CStr(dwBias \ 60) & " hours, " & CStr(dwBias Mod 60) & " minutes"
   
   GetStandardTimeBias = tmp

End Function


Function GetCurrentTimeBias() As String

   Dim TZI As TIME_ZONE_INFORMATION
   Dim dwBias As Long
   Dim tmp As String

   Select Case GetTimeZoneInformation(TZI)
   Case TIME_ZONE_ID_DAYLIGHT
      dwBias = TZI.Bias + TZI.DaylightBias
   Case Else
      dwBias = TZI.Bias + TZI.StandardBias
   End Select

   tmp = CStr(dwBias \ 60) & " hours, " & CStr(dwBias Mod 60) & " minutes"

   GetCurrentTimeBias = tmp
   
End Function


Function GetCurrentGMTDate() As String

   Dim TZI As TIME_ZONE_INFORMATION
   Dim GMT As Date
   Dim dwBias As Long
   Dim tmp As String

   Select Case GetTimeZoneInformation(TZI)
   Case TIME_ZONE_ID_DAYLIGHT
      dwBias = TZI.Bias + TZI.DaylightBias
   Case Else
      dwBias = TZI.Bias + TZI.StandardBias
   End Select

   GMT = DateAdd("n", dwBias, Now)
   tmp = Format$(GMT, "dddd mmm dd, yyyy hh:mm:ss am/pm")

   GetCurrentGMTDate = tmp

End Function


Function GetCurrentTimeZone() As String

   Dim TZI As TIME_ZONE_INFORMATION
   Dim tmp As String

   Select Case GetTimeZoneInformation(TZI)
      Case 0:  tmp = "Cannot determine current time zone"
      Case 1:  tmp = TZI.StandardName
      Case 2:  tmp = TZI.DaylightName
   End Select
   
   GetCurrentTimeZone = TrimNull(tmp)
   
End Function


Private Function TrimNull(item As String)

    Dim pos As Integer
   
   'double check that there is a chr$(0) in the string
    pos = InStr(item, Chr$(0))
    If pos Then
       TrimNull = Left$(item, pos - 1)
    Else
       TrimNull = item
    End If
  
End Function

