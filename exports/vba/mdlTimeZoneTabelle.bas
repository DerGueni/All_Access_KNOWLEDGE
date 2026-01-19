Attribute VB_Name = "mdlTimeZoneTabelle"
' Public Function Table_Time_Load()

' ##################################################################################################################
'               #############
' Modul MUSS as Administrator ausgeführt werden, sonst kann man die Registry Keys mit den TimeZoneDaten nicht lesen
'               #############
' ##################################################################################################################

Option Compare Database
Option Explicit

' Operating System version information declares

Private Const VER_PLATFORM_WIN32_NT = 2
Private Const VER_PLATFORM_WIN32_WINDOWS = 1

Private Type OSVERSIONINFO
  dwOSVersionInfoSize As Long
  dwMajorVersion As Long
  dwMinorVersion As Long
  dwBuildNumber As Long
  dwPlatformId As Long
  szCSDVersion As String * 128              ' Maintenance string
End Type

Private Declare PtrSafe Function GetVersionEx Lib "kernel32" _
    Alias "GetVersionExA" (lpVersionInformation As OSVERSIONINFO) As Long

' Time Zone information declares

Private Type SYSTEMTIME
  wYear As Integer
  wMonth As Integer
  wDayOfWeek As Integer
  wDay As Integer
  wHour As Integer
  wMinute As Integer
  wSecond As Integer
  wMilliseconds As Integer
End Type

Private Type REGTIMEZONEINFORMATION
  Bias As Long
  StandardBias As Long
  DaylightBias As Long
  StandardDate As SYSTEMTIME
  DaylightDate As SYSTEMTIME
End Type

Private Type TIME_ZONE_INFORMATION
  Bias As Long
  StandardName(0 To 63) As Byte             ' used to accommodate Unicode strings
  StandardDate As SYSTEMTIME
  StandardBias As Long
  DaylightName(0 To 63) As Byte             ' used to accommodate Unicode strings
  DaylightDate As SYSTEMTIME
  DaylightBias As Long
End Type

Private Const TIME_ZONE_ID_INVALID = &HFFFFFFFF
Private Const TIME_ZONE_ID_UNKNOWN = 0
Private Const TIME_ZONE_ID_STANDARD = 1
Private Const TIME_ZONE_ID_DAYLIGHT = 2

Private Declare PtrSafe Function GetTimeZoneInformation Lib "kernel32" _
    (lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long

Private Declare PtrSafe Function SetTimeZoneInformation Lib "kernel32" _
    (lpTimeZoneInformation As TIME_ZONE_INFORMATION) As Long

' Registry information declares
Private Const REG_SZ As Long = 1
Private Const REG_BINARY = 3
Private Const REG_DWORD As Long = 4

Private Const HKEY_CLASSES_ROOT = &H80000000
Private Const HKEY_CURRENT_USER = &H80000001
Private Const HKEY_LOCAL_MACHINE = &H80000002
Private Const HKEY_USERS = &H80000003

Private Const ERROR_SUCCESS = 0
Private Const ERROR_BADDB = 1
Private Const ERROR_BADKEY = 2
Private Const ERROR_CANTOPEN = 3
Private Const ERROR_CANTREAD = 4
Private Const ERROR_CANTWRITE = 5
Private Const ERROR_OUTOFMEMORY = 6
Private Const ERROR_ARENA_TRASHED = 7
Private Const ERROR_ACCESS_DENIED = 8
Private Const ERROR_INVALID_PARAMETERS = 87
Private Const ERROR_NO_MORE_ITEMS = 259

Private Const KEY_ALL_ACCESS = &H3F

Private Const KEY_ENUMERATE_SUB_KEYS = &H8
Private Const KEY_EXECUTE = &H20019
Private Const KEY_WOW64_32KEY = &H200

Private Const REG_OPTION_NON_VOLATILE = 0

Private Declare PtrSafe Function RegOpenKeyEx Lib "advapi32.dll" _
    Alias "RegOpenKeyExA" ( _
    ByVal hKey As Long, _
    ByVal lpSubKey As String, _
    ByVal ulOptions As Long, _
    ByVal samDesired As Long, _
    phkResult As Long) _
    As Long

Private Declare PtrSafe Function RegQueryValueEx Lib "advapi32.dll" _
    Alias "RegQueryValueExA" ( _
    ByVal hKey As Long, _
    ByVal lpszValueName As String, _
    ByVal lpdwReserved As Long, _
    lpdwType As Long, _
    lpData As Any, _
    lpcbData As Long) _
    As Long

Private Declare PtrSafe Function RegQueryValueExString Lib "advapi32.dll" _
    Alias "RegQueryValueExA" ( _
    ByVal hKey As Long, _
    ByVal lpValueName As String, _
    ByVal lpReserved As Long, _
    lpType As Long, _
    ByVal lpData As String, _
    lpcbData As Long) _
    As Long

Private Declare PtrSafe Function RegEnumKey Lib "advapi32.dll" _
    Alias "RegEnumKeyA" ( _
    ByVal hKey As Long, _
    ByVal dwIndex As Long, _
    ByVal lpName As String, _
    ByVal cbName As Long) _
    As Long

Private Declare PtrSafe Function RegCloseKey Lib "advapi32.dll" ( _
    ByVal hKey As Long) _
    As Long

' Registry Constants
Const SKEY_NT = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones"
Const SKEY_9X = "SOFTWARE\Microsoft\Windows\CurrentVersion\Time Zones"

' The following declaration is different from the one in the API viewer.
' To disable implicit ANSI<->Unicode conversion, it changes the
' variable types of lpMultiByteStr and lpWideCharStr to Any.
'
Private Declare PtrSafe Function MultiByteToWideChar Lib "kernel32" ( _
    ByVal CodePage As Long, _
    ByVal dwFlags As Long, _
    lpMultiByteStr As Any, _
    ByVal cchMultiByte As Long, _
    lpWideCharStr As Any, _
    ByVal cchWideChar As Long) As Long
    
    
' The above Declare and the following Constants are used to make
' this sample compatible with Double Byte Character Systems (DBCS).
Private Const CP_ACP = 0
Private Const MB_PRECOMPOSED = &H1

Dim SubKey As String
Dim rst As DAO.Recordset
Dim currTZ As TIME_ZONE_INFORMATION
Dim AktuelleTimeZone As String

Public Function Table_Time_Load()
  Dim lRetVal As Long, lResult As Long, lCurIdx As Long
  Dim lDataLen As Long, lValueLen As Long, hKeyResult As Long
  Dim strValue As String
  Dim osV As OSVERSIONINFO
  Dim byteCurrName(32) As Byte
  Dim cbStr As Long
  Dim cch As Long
  Dim lType As Long
  
  CurrentDb.Execute "DELETE * FROM _tblTimeZoneName;"
  DoEvents
  Set rst = CurrentDb.OpenRecordset("SELECT * FROM _tblTimeZoneName;")

  SubKey = "SYSTEM\CurrentControlSet\Control\TimeZoneInformation"

  lRetVal = RegOpenKeyEx(HKEY_LOCAL_MACHINE, SubKey, 0, _
      KEY_ALL_ACCESS, hKeyResult)

  If lRetVal = ERROR_SUCCESS Then

    lCurIdx = 0
    lDataLen = 32
    lValueLen = 32

    strValue = String(lValueLen, 0)
       
    lRetVal = RegQueryValueExString(hKeyResult, "TimeZoneKeyName", 0&, 1, _
    strValue, lValueLen)
   
    If lRetVal = ERROR_SUCCESS Then
        AktuelleTimeZone = Left(strValue, lValueLen - 1)
    Else
        AktuelleTimeZone = Empty
    End If
      
 End If
  
  ' Win9x and WinNT have a slightly different registry structure. Determine
  ' the operating system and set a module variable to the correct subkey.

  osV.dwOSVersionInfoSize = Len(osV)
  Call GetVersionEx(osV)
  If osV.dwPlatformId = VER_PLATFORM_WIN32_NT Then
    SubKey = SKEY_NT
  Else
    SubKey = SKEY_9X
  End If

  lRetVal = RegOpenKeyEx(HKEY_LOCAL_MACHINE, SubKey, 0, _
      KEY_ALL_ACCESS, hKeyResult)
  
  If lRetVal = ERROR_SUCCESS Then

    lCurIdx = 0
    lDataLen = 32
    lValueLen = 32

    Do
      strValue = String(lValueLen, 0)
      lResult = RegEnumKey(hKeyResult, lCurIdx, strValue, lDataLen)

      If lResult = ERROR_SUCCESS Then
         rst.AddNew
'        List1.AddItem Left(strvalue, lValueLen)
            rst!TimeZoneName = Left(strValue, lValueLen)
            List1_Update (Left(strValue, lValueLen))
         rst.update
      End If

      lCurIdx = lCurIdx + 1

    Loop While lResult = ERROR_SUCCESS

    RegCloseKey hKeyResult
  Else
    MsgBox "Could not open registry key " & lRetVal
  End If
  rst.Close
End Function

Private Sub List1_Update(listname As String)
  Dim TZ As TIME_ZONE_INFORMATION
  Dim oldTZ As TIME_ZONE_INFORMATION
  Dim rTZI As REGTIMEZONEINFORMATION
  Dim bytDLTName(32) As Byte, bytSTDName(32) As Byte
  Dim cbStr As Long, dwType As Long
  Dim lRetVal As Long, hKeyResult As Long, lngData As Long
  Dim tmp As String

  On Error Resume Next
  
  lRetVal = RegOpenKeyEx(HKEY_LOCAL_MACHINE, SubKey & "\" & listname, _
      0, KEY_ALL_ACCESS, hKeyResult)

  If lRetVal = ERROR_SUCCESS Then
    lRetVal = RegQueryValueEx(hKeyResult, "TZI", 0&, ByVal 0&, _
        rTZI, Len(rTZI))

    If lRetVal = ERROR_SUCCESS Then
      TZ.Bias = rTZI.Bias
      TZ.StandardBias = rTZI.StandardBias
      TZ.DaylightBias = rTZI.DaylightBias
      TZ.StandardDate = rTZI.StandardDate
      TZ.DaylightDate = rTZI.DaylightDate
      
      cbStr = 32
      dwType = REG_SZ

      lRetVal = RegQueryValueEx(hKeyResult, "Std", _
          0&, dwType, bytSTDName(0), cbStr)

      If lRetVal = ERROR_SUCCESS Then
        Call MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, _
            bytSTDName(0), cbStr, TZ.StandardName(0), 32)
      Else
        RegCloseKey hKeyResult
        Exit Sub
      End If

      cbStr = 32
      dwType = REG_SZ

      lRetVal = RegQueryValueEx(hKeyResult, "Dlt", _
          0&, dwType, bytDLTName(0), cbStr)

      If lRetVal = ERROR_SUCCESS Then
        Call MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, _
            bytDLTName(0), cbStr, TZ.DaylightName(0), 32)
      Else
        RegCloseKey hKeyResult
        Exit Sub
      End If

      lRetVal = GetTimeZoneInformation(oldTZ)

      If lRetVal = TIME_ZONE_ID_INVALID Then
        MsgBox "Error getting original TimeZone Info"
        RegCloseKey hKeyResult
        Exit Sub
      Else
      
      ' Neu ********
            
rst!Bias = TZ.Bias
rst!StandardBias = TZ.StandardBias
rst!DaylightBias = TZ.DaylightBias

rst!StandardDate = DateSerial(TZ.StandardDate.wYear, TZ.StandardDate.wMonth, TZ.StandardDate.wDay) + _
                   TimeSerial(TZ.StandardDate.wHour, TZ.StandardDate.wMinute, TZ.StandardDate.wSecond)

rst!DaylightDate = DateSerial(TZ.DaylightDate.wYear, TZ.DaylightDate.wMonth, TZ.DaylightDate.wDay) + _
                   TimeSerial(TZ.DaylightDate.wHour, TZ.DaylightDate.wMinute, TZ.DaylightDate.wSecond)
    
rst!StandardName = Trim(gibname(bytSTDName()))
rst!DaylightName = Trim(gibname(bytDLTName()))

If AktuelleTimeZone = rst!StandardName Then
    rst!IsCurrentTimeZone = 1
Else
    rst!IsCurrentTimeZone = 0
End If
'        lRetVal = SetTimeZoneInformation(TZ)
'        MsgBox "Time Zone Changed, Click OK to restore"
'        lRetVal = SetTimeZoneInformation(oldTZ)
      End If
    End If

    RegCloseKey hKeyResult
  End If
End Sub

Function gibname(x() As Byte) As String
Dim i As Long
gibname = ""
For i = 0 To 31
    gibname = gibname & Chr$(x(i))
Next i
End Function

