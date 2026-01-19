Attribute VB_Name = "mdlRegistryRead"
Option Compare Database
Option Explicit

' GetRegistryValue - Read the value of a Registry key
'Private Declare PtrSafe Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" _
'    (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, _
'    ByVal samDesired As Long, phkResult As Long) As Long
'Private Declare PtrSafe Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As _
'    Long
'Private Declare PtrSafe Function RegQueryValueEx Lib "advapi32.dll" Alias _
'    "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
'    ByVal lpReserved As Long, lpType As Long, lpData As Any, _
'    lpcbData As Long) As Long
Private Declare PtrSafe Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (dest As _
    Any, Source As Any, ByVal numBytes As Long)

Const KEY_READ = &H20019  ' ((READ_CONTROL Or KEY_QUERY_VALUE Or
                          ' KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not
                          ' SYNCHRONIZE))

Const REG_EXPAND_SZ = 2
Const REG_MULTI_SZ = 7
Const ERROR_MORE_DATA = 234




Global Const REG_SZ As Long = 1
Global Const REG_DWORD As Long = 4
Global Const REG_BINARY As Long = 3

Global Const HKEY_CLASSES_ROOT = &H80000000
Global Const HKEY_CURRENT_USER = &H80000001
Global Const HKEY_LOCAL_MACHINE = &H80000002
Global Const HKEY_USERS = &H80000003

Global Const ERROR_NONE = 0
Global Const ERROR_BADDB = 1
Global Const ERROR_BADKEY = 2
Global Const ERROR_CANTOPEN = 3
Global Const ERROR_CANTREAD = 4
Global Const ERROR_CANTWRITE = 5
Global Const ERROR_OUTOFMEMORY = 6
Global Const ERROR_INVALID_PARAMETER = 7
Global Const ERROR_ACCESS_DENIED = 8
Global Const ERROR_INVALID_PARAMETERS = 87
Global Const ERROR_NO_MORE_ITEMS = 259

Global Const KEY_ALL_ACCESS = &H3F

Global Const REG_OPTION_NON_VOLATILE = 0

Public Const KEY_SET_VALUE = &H2

Type SECURITY_ATTRIBUTES
        nLength As Long
        lpSecurityDescriptor As Long
        bInheritHandle As Long
End Type

Dim hKey As Long
Dim sz As Long
Dim Success As Long
Dim v$
Dim nval&


Declare PtrSafe Function RegCloseKey Lib "advapi32.dll" _
(ByVal hKey As Long) As Long

Declare PtrSafe Function RegCreateKeyEx Lib "advapi32.dll" Alias _
"RegCreateKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, _
ByVal Reserved As Long, ByVal lpClass As String, ByVal dwOptions _
As Long, ByVal samDesired As Long, ByVal lpSecurityAttributes _
As Long, phkResult As Long, lpdwDisposition As Long) As Long

Declare PtrSafe Function RegOpenKeyEx Lib "advapi32.dll" Alias _
"RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, _
ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As _
Long) As Long

Declare PtrSafe Function RegQueryValueExString Lib "advapi32.dll" Alias _
"RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As _
String, ByVal lpReserved As Long, lpType As Long, ByVal lpData _
As String, lpcbData As Long) As Long

Private Declare PtrSafe Function RegQueryValueEx Lib "advapi32.dll" Alias _
    "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
    ByVal lpReserved As Long, lpType As Long, lpData As Any, _
    lpcbData As Long) As Long


Declare PtrSafe Function RegQueryValueExLong Lib "advapi32.dll" Alias _
"RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As _
String, ByVal lpReserved As Long, lpType As Long, lpData As _
Long, lpcbData As Long) As Long

Declare PtrSafe Function RegQueryValueExNULL Lib "advapi32.dll" Alias _
"RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As _
String, ByVal lpReserved As Long, lpType As Long, ByVal lpData _
As Long, lpcbData As Long) As Long

Declare PtrSafe Function RegSetValueExString Lib "advapi32.dll" Alias _
"RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
ByVal Reserved As Long, ByVal dwType As Long, ByVal lpValue As _
String, ByVal cbData As Long) As Long

Declare PtrSafe Function RegSetValueExLong Lib "advapi32.dll" Alias _
"RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
ByVal Reserved As Long, ByVal dwType As Long, lpValue As Long, _
ByVal cbData As Long) As Long
   
   
   
'SetValueEx and QueryValueEx Wrapper Functions:

Public Function SetValueEx(ByVal hKey As Long, sValueName As String, _
   lType As Long, vValue As Variant) As Long
       Dim lValue As Long
       Dim sValue As String
       Select Case lType
           Case REG_SZ
               sValue = vValue & Chr$(0)
               SetValueEx = RegSetValueExString(hKey, sValueName, 0&, _
                                              lType, sValue, Len(sValue))
           Case REG_DWORD
               lValue = vValue
               SetValueEx = RegSetValueExLong(hKey, sValueName, 0&, _
   lType, lValue, 4)
           End Select
End Function

Function QueryValueEx(ByVal lhKey As Long, ByVal szValueName As _
   String, vValue As Variant) As Long
       Dim cch As Long
       Dim lrc As Long
       Dim lType As Long
       Dim lValue As Long
       Dim sValue As String

       On Error GoTo QueryValueExError

       ' Determine the size and type of data to be read
       lrc = RegQueryValueExNULL(lhKey, szValueName, 0&, lType, 0&, cch)
       If lrc <> ERROR_NONE Then Error 5

       Select Case lType
           ' For strings
           Case REG_SZ:
               sValue = String(cch, 0)
   lrc = RegQueryValueExString(lhKey, szValueName, 0&, lType, _
   sValue, cch)
               If lrc = ERROR_NONE Then
                   vValue = Left$(sValue, cch - 1)
               Else
                   vValue = Empty
               End If
           ' For DWORDS
           Case REG_DWORD:
   lrc = RegQueryValueExLong(lhKey, szValueName, 0&, lType, _
   lValue, cch)
               If lrc = ERROR_NONE Then vValue = lValue
           Case Else
               'all other data types not supported
               lrc = -1
       End Select

QueryValueExExit:
       QueryValueEx = lrc
       Exit Function
QueryValueExError:
       Resume QueryValueExExit
   End Function


Function QueryValue(StartDirectory, sKeyName As String, sValueName As String) As String
'*****************************
' Diese Function gibt den Wert eines Keys zurück, der in der Registry steht.
'
' Beispiel: QueryValue(HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Shared Tools\MSInfo", "Path")
'
' Gibt den korrekten Dateinamen incl. Pfad für MSINFO32 zurück oder einen Leerstring, wenn nicht installiert
' StartDirectory muß eine der folgenden Variablen sein:
'
'            HKEY_CLASSES_ROOT
'            HKEY_CURRENT_USER
'            HKEY_LOCAL_MACHINE
'            HKEY_USERS
'
' Den Wert, den man sucht, ermittelt man am besten zuerst manuell aus der Registry,
' in dem man direkt in der Registry sucht ...
'
' Näheres siehe unter: HOWTO - Use the Registry API to Save and Retrieve Setting.htm
' und: Controlling Entries in the Operating System Registry
'*******************************
       
       Dim lRetVal As Long         'result of the API functions
       Dim hKey As Long            'handle of opened key
       Dim vValue As Variant       'setting of queried value
       
       lRetVal = RegOpenKeyEx(StartDirectory, sKeyName, 0, KEY_ALL_ACCESS, hKey)
       lRetVal = QueryValueEx(hKey, sValueName, vValue)
       
       QueryValue = vValue & ""
       RegCloseKey (hKey)
End Function





' Read a Registry value
'
' Use KeyName = "" for the default value
' If the value isn't there, it returns the DefaultValue
' argument, or Empty if the argument has been omitted
'
' Supports DWORD, REG_SZ, REG_EXPAND_SZ, REG_BINARY and REG_MULTI_SZ
' REG_MULTI_SZ values are returned as a null-delimited stream of strings
' (VB6 users can use SPlit to convert to an array of string)

Function GetRegistryValue(ByVal hKey As Long, ByVal KeyName As String, _
    ByVal ValueName As String, Optional DefaultValue As Variant) As Variant
    Dim handle As Long
    Dim resLong As Long
    Dim resString As String
    Dim resBinary() As Byte
    Dim Length As Long
    Dim Retval As Long
    Dim valueType As Long
    Dim i As Long
    
    ' Prepare the default result
    GetRegistryValue = IIf(IsMissing(DefaultValue), Empty, DefaultValue)
    
    ' Open the key, exit if not found.
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then
        Exit Function
    End If
    
    ' prepare a 1K receiving resBinary
    Length = 1024
    ReDim resBinary(0 To Length - 1) As Byte
    
    ' read the registry key
    Retval = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
        Length)
    ' if resBinary was too small, try again
    If Retval = ERROR_MORE_DATA Then
        ' enlarge the resBinary, and read the value again
        ReDim resBinary(0 To Length - 1) As Byte
        Retval = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
            Length)
    End If
    
    ' return a value corresponding to the value type
    Select Case valueType
        Case REG_DWORD
            CopyMemory resLong, resBinary(0), 4
            GetRegistryValue = resLong
        Case REG_SZ, REG_EXPAND_SZ
            ' copy everything but the trailing null char
            resString = Space$(Length - 1)
            CopyMemory ByVal resString, resBinary(0), Length - 1
            GetRegistryValue = resString
        
        Case REG_BINARY
            ' resize the result resBinary
            If Length <> UBound(resBinary) + 1 Then
                ReDim Preserve resBinary(0 To Length - 1) As Byte
            End If
'            GetRegistryValue = resBinary()
            GetRegistryValue = ""
            For i = 0 To UBound(resBinary)
                GetRegistryValue = GetRegistryValue & Right("00" & Hex(resBinary(i)), 2) & " "
            Next i
        
        Case REG_MULTI_SZ
            ' copy everything but the 2 trailing null chars
            resString = Space$(Length - 2)
            CopyMemory ByVal resString, resBinary(0), Length - 2
            GetRegistryValue = resString
        Case Else
            RegCloseKey handle
            Err.Raise 1001, , "Unsupported value type"
    End Select
    
    ' close the registry key
    RegCloseKey handle
End Function

