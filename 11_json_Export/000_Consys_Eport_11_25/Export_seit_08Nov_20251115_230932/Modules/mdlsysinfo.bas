Option Compare Database   'Use database order for string comparisons
Option Explicit

'--------------------------------------------------------------------------
'System Info by ATTAC Consulting Group, Ann Arbor, MI  USA
'Copyright © 1995-98,  All rights reserved.

'This is an Access 95 and 97 sample of a System Information Dialog
'that you can import into your applications.  The code is freely distributable.

'For other Access Developer's tools, tips and files visit us on the web at
'http://ourworld.compuserve.com/homepages/attac-cg/acgsoft.htm

'Our e-mail address is:
'mailto:  75323.2112@Compuserve.com

'NOTICE OF DISCLAIMER:
'=========================
'This Software is provided "As Is" without warranty of any kind.  ATTAC
'Consulting Group expressly disclaims any warrenty regarding
'merchantablity, performance or usability for any purpose whatsoever.
'ATTAC Consulting Group disclaims all liability for any damages,
'or loss including loss of data, or loss of business profits from use or inability
'to use the Software or any other pecuniary loss real, consequential or otherwise
'arrising in the course of use of this Software.
'---------------------------------------------------------------------------------

Private Declare PtrSafe Function TerminateProcess Lib "kernel32.dll" (ByVal ApphProcess As Long, _
ByVal uExitCode As Long) As Long


' Es wird noch das Modul mdlRegistry verwendet.

'Implementation by ATTAC Consulting Group, Ann Arbor, MI USA.  Freely Distributed

Declare PtrSafe Function MakePath Lib "imagehlp.dll" Alias "MakeSureDirectoryPathExists" (ByVal lpPath As String) As Long
Public Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Private Declare PtrSafe Function api_GetDiskFreeSpace Lib "kernel32" Alias "GetDiskFreeSpaceA" (ByVal lpRootPathName As String, lpSectorsPerCluster As Long, lpBytesPerSector As Long, lpNumberOfFreeClusters As Long, lpTtoalNumberOfClusters As Long) As Long
Private Declare PtrSafe Function api_GetDiskFreeSpaceEx Lib "kernel32" Alias "GetDiskFreeSpaceExA" (ByVal lpRootPathName As String, lpFreeBytesAvailableToCaller As Currency, lpTotalNumberOfBytes As Currency, lpTotalNumberOfFreeBytes As Currency) As Long
Private Declare PtrSafe Function api_GetDriveType Lib "kernel32" Alias "GetDriveTypeA" (ByVal lpRootPathName As String) As Long
Private Declare PtrSafe Sub GetSystemInfo Lib "kernel32" (lpSystemInfo As SYSTEM_INFO)

' war im Original
'Private Declare PtrSafe Function GetVersionEx Lib "kernel32" Alias "GetVersionExA" (lpOSInfo As OSVERSIONINFO) As Boolean

'defined As Any to support OSVERSIONINFO and OSVERSIONINFOEX
Private Declare PtrSafe Function GetVersionEx Lib "kernel32" Alias "GetVersionExA" _
  (lpOSInfo As Any) As Long

Private Declare PtrSafe Function GlobalMemoryStatusEx Lib "kernel32.dll" (ByRef lpBuffer As MemoryStatusEx) As Long

Private Declare PtrSafe Sub GlobalMemoryStatus Lib "kernel32" (lpBuffer As MEMORYSTATUS)
Private Declare PtrSafe Function api_GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long
Private Declare PtrSafe Function api_GetComputerName Lib "kernel32" Alias "GetComputerNameA" (ByVal lpBuffer As String, nSize As Long) As Long
Private Declare PtrSafe Function api_CreateIC Lib "gdi32" Alias "CreateICA" (ByVal lpDriverName As String, ByVal lpDeviceName As Any, ByVal lpOutput As Any, ByVal lpInitData As Any) As Long
Private Declare PtrSafe Function api_DeleteDC Lib "gdi32" Alias "DeleteDC" (ByVal hdc As Long) As Long
Private Declare PtrSafe Function API_GetDeviceCaps Lib "gdi32" Alias "GetDeviceCaps" (ByVal hdc As Long, ByVal nIndex As Long) As Long
Private Declare PtrSafe Function api_SetErrorMode Lib "kernel32" Alias "SetErrorMode" (ByVal fuErrorMode As Long) As Long
'Declares for Version Verification

Private Declare PtrSafe Function ac_GetFileVersionInfoSize Lib "Version.dll" Alias "GetFileVersionInfoSizeA" (ByVal lptstrFilename As String, lpdwHandle As Long) As Long
Private Declare PtrSafe Function ac_GetFileVersionInfo Lib "Version.dll" Alias "GetFileVersionInfoA" (ByVal lptstrFilename As String, ByVal dwHandle As Long, ByVal dwLen As Long, lpData As Any) As Long
Private Declare PtrSafe Function ac_VerQueryValue Lib "Version.dll" Alias "VerQueryValueA" (pBlock As Any, ByVal lpSubBlock As String, lplpBuffer As Any, puLen As Long) As Long
Private Declare PtrSafe Sub ac_MoveMemory Lib "kernel32" Alias "RtlMoveMemory" (dest As Any, ByVal Source As Long, ByVal Length As Long)

Private Declare PtrSafe Function api_GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare PtrSafe Function api_GetSystemDirectory Lib "kernel32" Alias "GetSystemDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare PtrSafe Function api_GetTempPath Lib "kernel32" Alias "GetTempPathA" (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long
Private Declare PtrSafe Function api_GetClassName Lib "user32" Alias "GetClassNameA" (ByVal hwnd As Long, ByVal lpClassName As String, ByVal nMaxCount As Long) As Long

Const Jet_FILENAME = "MSJT3032.DLL"
Const Jet35_FILE = "msjet35.dll"

Const SEM_FAILCRITICALERRORS = &H1
Const SEM_NOGPFAULTERRORBOX = &H2
Const SEM_NOOPENFILEERRORBOX = &H8000
    
' Type returned by VER.DLL GetFileVersionInfo
Private Type VS_FIXEDFILEINFO
    dwSignature As Long
    dwStrucVersionl As Integer     '  e.g. = &h0000 = 0
    dwStrucVersionh As Integer     '  e.g. = &h0042 = .42
    dwFileVersionMSl As Integer    '  e.g. = &h0003 = 3
    dwFileVersionMSh As Integer    '  e.g. = &h0075 = .75
    dwFileVersionLSl As Integer    '  e.g. = &h0000 = 0
    dwFileVersionLSh As Integer    '  e.g. = &h0031 = .31
    dwProductVersionMSl As Integer '  e.g. = &h0003 = 3
    dwProductVersionMSh As Integer '  e.g. = &h0010 = .1
    dwProductVersionLSl As Integer '  e.g. = &h0000 = 0
    dwProductVersionLSh As Integer '  e.g. = &h0031 = .31
    dwFileFlagsMask As Long        '  = &h3F for version "0.42"
    dwFileFlags As Long            '  e.g. VFF_DEBUG Or VFF_PRERELEASE
    dwFileOS As Long               '  e.g. VOS_DOS_WINDOWS16
    dwFileType As Long             '  e.g. VFT_DRIVER
    dwFileSubtype As Long          '  e.g. VFT2_DRV_KEYBOARD
    dwFileDateMS As Long           '  e.g. 0
    dwFileDateLS As Long           '  e.g. 0
 End Type
Type fBuffer
    item As String * 1024
End Type

Private Type SYSTEM_INFO
   dwOemID As Long
   dwPageSize As Long
   lpMinimumApplicationAddress As Long
   lpMaximumApplicationAddress As Long
   dwActiveProcessorMask As Long
   dwNumberOrfProcessors As Long
   dwProcessorType As Long
   dwAllocationGranularity As Long
   dwReserved As Long
End Type

Const VER_PLATFORM_WIN32s = 0
Const VER_PLATFORM_WIN32_WINDOWS = 1   ' Windows 95
Const VER_PLATFORM_WIN32_NT = 2

Private Type OSVERSIONINFO
   dwOSVersionInfoSize As Long
   dwMajorVersion As Long
   dwMinorVersion As Long
   dwBuildNumber As Long
   dwPlatformId As Long
   szCSDVersion As String * 128
End Type

Private Type OSVERSIONINFOEX
  OSVSize            As Long
  dwVerMajor        As Long
  dwVerMinor         As Long
  dwBuildNumber      As Long
  PlatformID         As Long
  szCSDVersion       As String * 128
  wServicePackMajor  As Integer
  wServicePackMinor  As Integer
  wSuiteMask         As Integer
  wProductType       As Byte
  wReserved          As Byte
End Type

Private Type MEMORYSTATUS
   dwLength As Long
   dwMemoryLoad As Long
   dwTotalPhys As Long
   dwAvailPhys As Long
   dwTotalPageFile As Long
   dwAvailPageFile As Long
   dwTotalVirtual As Long
   dwAvailVirtual As Long
End Type

Private Type MemoryStatusEx
    dwLength As Long
    dwMemoryLoad As Long
    ullTotalPhys As Currency
    ullAvailPhys As Currency
    ullTotalPageFile As Currency
    ullAvailPageFile As Currency
    ullTotalVirtual As Currency
    ullAvailVirtual As Currency
    ullAvailExtendedVirtual As Currency
End Type

'Speziell Angepasst für Login CONSEC
Public Function atCNames(UOrC As Integer) As String
'**************************************************
'Purpose:  Returns the User LogOn Name or ComputerName
'Author: 'System Info by ATTAC Consulting Group, Ann Arbor, MI  USA
'Accepts:  UorC; 1=User, anything else = computer
'Returns:  The Windows Networking name of the user or computer
'Declares:
'Private Declare PtrSafe Function api_GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long
'Private Declare PtrSafe Function api_GetComputerName Lib "kernel32" Alias "GetComputerNameA" (ByVal lpBuffer As String, nSize As Long) As Long
'**************************************************
On Error Resume Next

    Dim NBuffer As String
    Dim Buffsize As Long
    Dim Wok As Long

    Buffsize = 256
    NBuffer = Space$(Buffsize)


    If UOrC = 1 Then
        atCNames = Get_Priv_Property("prp_Loginname")
    Else
        Wok = api_GetComputerName(NBuffer, Buffsize)
        atCNames = Trim$(NBuffer)
    End If
    If Right(atCNames, 1) = Chr(0) Then
        atCNames = Left(atCNames, Len(atCNames) - 1)
    End If
    
End Function

Public Function atCNames1(UOrC As Integer) As String
'**************************************************
'Purpose:  Returns the User LogOn Name or ComputerName
'Author: 'System Info by ATTAC Consulting Group, Ann Arbor, MI  USA
'Accepts:  UorC; 1=User, anything else = computer
'Returns:  The Windows Networking name of the user or computer
'Declares:
'Private Declare PtrSafe Function api_GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long
'Private Declare PtrSafe Function api_GetComputerName Lib "kernel32" Alias "GetComputerNameA" (ByVal lpBuffer As String, nSize As Long) As Long
'**************************************************
On Error Resume Next

    Dim NBuffer As String
    Dim Buffsize As Long
    Dim Wok As Long

    Buffsize = 256
    NBuffer = Space$(Buffsize)


    If UOrC = 1 Then
'        atCNames = "zigausi"
        Wok = api_GetUserName(NBuffer, Buffsize)
        atCNames1 = Trim$(NBuffer)
    Else
        Wok = api_GetComputerName(NBuffer, Buffsize)
        atCNames1 = Trim$(NBuffer)
    End If
    If Right(atCNames1, 1) = Chr(0) Then
        atCNames1 = Left(atCNames1, Len(atCNames1) - 1)
    End If
    
End Function

Private Function IsWinNT4Plus() As Boolean

  'returns True if running Windows NT4 or later
   Dim osV As OSVERSIONINFO

   osV.dwOSVersionInfoSize = Len(osV)

   If GetVersionEx(osV) = 1 Then
   
      IsWinNT4Plus = (osV.dwPlatformId = VER_PLATFORM_WIN32_NT) And _
                     (osV.dwMajorVersion >= 4)
 
   End If

End Function

Function atWinver(intOSInfo%) As Variant
'http://www.codeguru.com/cpp/w-p/system/systeminformation/article.php/c8973/
'http://vbnet.mvps.org/code/helpers/iswinversion.htm

'***********************************************
'Purpose:  Retrieve operating system information
'Author: 'System Info by ATTAC Consulting Group, Ann Arbor, MI  USA
'Accepts: intOSInfo: which piece of information to retrieve
   '        0: Major Version
   '        1: Minor version
   '        2: Build-Nr
   '        3: Platform ID
   '        4: CSDVersion
' Returns: OS supplied Information
'Declares:
'Private Type OSVERSIONINFO
'  OSVSize         As Long         'size, in bytes, of this data structure
'  dwVerMajor      As Long         'ie NT 3.51, dwVerMajor = 3; NT 4.0, dwVerMajor = 4.
'  dwVerMinor      As Long         'ie NT 3.51, dwVerMinor = 51; NT 4.0, dwVerMinor= 0.
'  dwBuildNumber   As Long         'NT: build number of the OS
'                                  'Win9x: build number of the OS in low-order word.
'                                  '       High-order word contains major & minor ver nos.
'  PlatformID      As Long         'Identifies the operating system platform.
'  szCSDVersion    As String * 128 'NT: string, such as "Service Pack 3"
'                                  'Win9x: string providing arbitrary additional information
'End Type
'
'Private Type OSVERSIONINFOEX
'  OSVSize            As Long
'  dwVerMajor         As Long
'  dwVerMinor         As Long
'  dwBuildNumber      As Long
'  PlatformID         As Long
'  szCSDVersion       As String * 128
'  wServicePackMajor  As Integer
'  wServicePackMinor  As Integer
'  wSuiteMask         As Integer
'  wProductType       As Byte
'  wReserved          As Byte
'End Type

'Private Declare PtrSafe Function GetVersionEx Lib "kernel32" Alias "GetVersionExA" (lpOSInfo As OSVERSIONINFO) As Boolean

'Win 95          4.00.950
'Win 95 OSR 2    4.00.1111
'Win 98          4.10.1998
'Win 98 SE       4.10.2222
'Win Me          4.90.3000
'Win NT4         4.00.1381 platform ID as 2
'Win 2000        5.00.2195 platform ID as 2
'Win XP          5.01.2600 platform ID as 2
'Win 2003 Server        5.02.3790 platform ID as 2
'Win Vista              6.00.6000 platform ID as 2 ProductType 1
'Win 2008 Server        6.00.6000 platform ID as 2 ProductType 3
'Windows Server 2008 R2 6.1 6 1 OSVERSIONINFOEX.wProductType 3 != VER_NT_WORKSTATION
'Windows 7              6.1 6 1 OSVERSIONINFOEX.wProductType 1 == VER_NT_WORKSTATION


'Eine nur ab Vista und Windows Server 2008 verfügbare neue API "GetProductInfo" hilft bei der Definition der
'genauen Version, siehe
'http://www.codeguru.com/cpp/w-p/system/systeminformation/article.php/c8973/

'Win Vista - Major 6 - Minor 0 - Product Type 1
'       Ultimate und Business        - Suite Mask = 0x000
'       Home Basic und Home Premium  - Suite Mask = 0x200

'Win Server 2008 - Major 6 - Minor 0 - Product Type 3
'       Standard    - Suite Mask = 0x000
'       Enterprise  - Suite Mask = 0x002
'       Data Center - Suite Mask = 0x080

'Win Server 2008 R2 - Major 6 - Minor 1 - Product Type 3

'Windows 7          - Major 6 - Minor 1 - Product Type 1

'Windows Vista
'Platform type: NT
'Major version: 6
'Minor version: 0
'Build number: 6000
'Service Pack info:  (Build 6000)
'
'32-bit platform: true
'64-bit platform: false

'***********************************************
   Dim OSInfo As OSVERSIONINFO
   Dim OSInfoEx As OSVERSIONINFOEX
   Dim dwReturn&
   
   Dim Is_Ex As Boolean
   Dim Is_OK As Long
   
   Const PLAT_WINDOWS = 1
   Const PLAT_WIN_NT = 2
   
   OSInfo.szCSDVersion = Space(128)
   
   'Set the size= to length of structure
If IsWinNT4Plus Then
    OSInfo.dwOSVersionInfoSize = Len(OSInfo)
    Is_OK = GetVersionEx(OSInfo)
    If Is_OK = 0 Then Exit Function
    OSInfoEx.OSVSize = Len(OSInfoEx)
    Is_OK = GetVersionEx(OSInfoEx)
    Is_Ex = True
Else
    OSInfo.dwOSVersionInfoSize = Len(OSInfo)
    Is_OK = GetVersionEx(OSInfo)
    Is_Ex = False
End If
   If Is_OK > 0 Then
      Select Case intOSInfo
         Case 0
            atWinver = OSInfo.dwMajorVersion
         Case 1
            atWinver = OSInfo.dwMinorVersion
         Case 2
            atWinver = OSInfo.dwBuildNumber And &HFFFF&
         Case 3
            
            dwReturn = OSInfo.dwPlatformId
            atWinver = OSInfo.dwMinorVersion
            If dwReturn = PLAT_WINDOWS Then
                If atWinver < 10 Then
                    If (OSInfo.dwBuildNumber And &HFFFF&) > 1000 Then
                        atWinver = "Win 95 SR2"
                    Else
                        atWinver = "Win 95 SR1"
                    End If
                Else
'                    atWinver = "Windows 98"
                    If (OSInfo.dwBuildNumber And &HFFFF&) > 2000 Then
                        atWinver = "Win 98 SE"
                    Else
                        atWinver = "Win 98"
                    End If
                End If
            Else
                If dwReturn = PLAT_WIN_NT Then
                    If OSInfo.dwMajorVersion = 5 Then
                        Select Case OSInfo.dwMinorVersion
                            Case 0
                               atWinver = "Win 2000"
                                If Is_Ex Then
                                    If Hex(OSInfoEx.wSuiteMask) And &H80& = &H80& Then
                                        atWinver = "Win 2000 Datacenter"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H2& = &H2& Then
                                        atWinver = "Win 2000 Advanced"
                                    End If
                                Else
                                    atWinver = "Win 2000"
                                End If
                            Case 1
                               atWinver = "Win XP"
                                If Is_Ex Then
                                    If Hex(OSInfoEx.wSuiteMask) And &H80& = &H80& Then
                                        atWinver = "Win XP Pro"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H200& = &H200& Then
                                        atWinver = "Win XP Home"
                                    End If
                                Else
                                    atWinver = "Win XP"
                                End If
                            Case 2
                               atWinver = "Win 2003 Server"
                                If Is_Ex Then
                                    If Hex(OSInfoEx.wSuiteMask) And &H80& = &H80& Then
                                        atWinver = "Win 2003 Server Datacenter"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H2& = &H2& Then
                                        atWinver = "Win 2003 Server Enterprise"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H400& = &H400& Then
                                        atWinver = "Win 2003 Server Web Edition"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                        atWinver = "Win 2003 Server Standard"
                                    End If
                                Else
                                    atWinver = "Win 2003 Server"
                                End If
                            Case Else
                                atWinver = "Win ???"
                        End Select
                    ElseIf OSInfo.dwMajorVersion = 4 Then
                        If Is_Ex Then
                            If Hex(OSInfoEx.wSuiteMask) And &H2& = &H2& Then
                                atWinver = "Win NT Server Enterprise"
                            ElseIf Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                atWinver = "Win NT Server Standard"
                            End If
                        Else
                            atWinver = "Win NT"
                        End If
                    ElseIf OSInfo.dwMajorVersion = 6 Then
                        If Is_Ex Then
                            If OSInfo.dwMinorVersion = 0 Then
                                If OSInfoEx.wProductType = 1 Then
                                    If Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                        atWinver = "Win VISTA Ultimate Business"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H200& = &H200& Then
                                        atWinver = "Win Vista Home"
                                    End If
                                ElseIf OSInfoEx.wProductType = 2 Then
                                    If Hex(OSInfoEx.wSuiteMask) And &H2& = &H2& Then
                                        atWinver = "Win 2008 Server Enterprise"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H80& = &H80& Then
                                        atWinver = "Win 2008 Server Datacenter"
                                    ElseIf Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                        atWinver = "Win 2008 Server Standard"
                                    End If
                                End If
                            ElseIf OSInfo.dwMinorVersion = 1 And OSInfoEx.wProductType = 3 Then
                                If Hex(OSInfoEx.wSuiteMask) And &H2& = &H2& Then
                                    atWinver = "Win 2008 Server R2 Enterprise"
                                ElseIf Hex(OSInfoEx.wSuiteMask) And &H80& = &H80& Then
                                    atWinver = "Win 2008 Server R2 Datacenter"
                                ElseIf Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                    atWinver = "Win 2008 Server R2 Standard"
                                End If
                            ElseIf OSInfo.dwMinorVersion = 1 And OSInfoEx.wProductType = 1 Then
                                If Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                    atWinver = "Windows 7 Ultimate Business"
                                ElseIf Hex(OSInfoEx.wSuiteMask) And &H200& = &H200& Then
                                    atWinver = "Windows 7 Home"
                                End If
                            ElseIf OSInfo.dwMinorVersion = 2 And OSInfoEx.wProductType = 3 Then
                                If Hex(OSInfoEx.wSuiteMask) And &H2& = &H2& Then
                                    atWinver = "Win 2012 Server R2 Enterprise"
                                ElseIf Hex(OSInfoEx.wSuiteMask) And &H80& = &H80& Then
                                    atWinver = "Win 2012 Server R2 Datacenter"
                                ElseIf Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                    atWinver = "Win 2012 Server R2 Standard"
                                End If
                            ElseIf OSInfo.dwMinorVersion = 2 And OSInfoEx.wProductType = 1 Then
                                If Hex(OSInfoEx.wSuiteMask) And &H0& = &H0& Then
                                    atWinver = "Windows 8 Ultimate Business"
                                ElseIf Hex(OSInfoEx.wSuiteMask) And &H200& = &H200& Then
                                    atWinver = "Windows 8 Home"
                                End If
                            End If
                        Else
                            atWinver = "Win VISTA"
                        End If
                    End If
                Else
                    atWinver = "???"
                End If
            End If
         Case 4
            atWinver = Trim(OSInfo.szCSDVersion)
      End Select
   Else
      atWinver = 0
   End If

End Function


Public Function atGetSysStatus(intStatus As Integer) As Variant
'****************************************************************
'Purpose:  Retrieve system status information
'Accepts:  intStatus: which piece of information to retrieve
'           1: The number of CPUs in the system
'           2: The type of CPUs in the system
'Returns:  The requested information
'*****************************************************************
 On Error Resume Next
   Dim si As SYSTEM_INFO
   Dim CPUType$

   
   GetSystemInfo si
   Select Case intStatus
      Case 1
         atGetSysStatus = si.dwNumberOrfProcessors
      Case 2
         CPUType = si.dwProcessorType
         If CPUType = "586" Then
            atGetSysStatus = "Pentium"
         Else
             atGetSysStatus = si.dwProcessorType
         End If
      Case Else
         atGetSysStatus = 0
   End Select
   
End Function


Function atDiskFreeSpace(Drive As String) As String
'**************************************************
'Wird normalerweise nicht mehr benötigt ...
'Purpose: Return Free Space
'Accepts: A Drive letter
'Returns: Disk space available
'**************************************************
On Error GoTo Err_DF

    Dim wResult
    Dim TotalSpace As Long
    Dim TotalSpaceMB As Single
    Dim freeSpace As Long
    Dim FreeSpaceMB As Single
    Dim PercentFree As Single
    Dim path As String
    Dim Sectors As Long
    Dim bytes As Long
    Dim FClusters As Long
    Dim TClusters As Long
    Dim ErrorMode&
      
    If IsNull(Drive) Then Exit Function
    'Set the error mode for the system so that "system errors" are ignored
    'and we let Access handle the errors, capture the return value so that
    'the error mode can be reset to its initial setting upon exit from the
    'function
'    ErrorMode = api_SetErrorMode(SEM_FAILCRITICALERRORS)
'    ErrorMode = api_SetErrorMode(SEM_NOGPFAULTERRORBOX)
'    ErrorMode = api_SetErrorMode(SEM_NOOPENFILEERRORBOX)
    ErrorMode = api_SetErrorMode(SEM_NOOPENFILEERRORBOX + SEM_NOGPFAULTERRORBOX)

    wResult = Dir(Drive & ":\*.*")
    
    path = Drive & ":\" & Chr$(0)
    
    wResult = api_GetDiskFreeSpace(path, Sectors, bytes, FClusters, TClusters)
    
    TotalSpace = Sectors * bytes * TClusters
    TotalSpaceMB = (TotalSpace / 1024) / 1024
    freeSpace = Sectors * bytes * FClusters
    FreeSpaceMB = (freeSpace / 1024) / 1024
    PercentFree = (freeSpace / TotalSpace) * 100
    If TotalSpace = -1 Then
        atDiskFreeSpace = "Drive Not Available"
    Else
        If FreeSpaceMB < 1000 And TotalSpaceMB < 1000 Then
            atDiskFreeSpace = Format$(FreeSpaceMB, "###0.##") & " MB: " & Format$(PercentFree, "0.##") & "% of " & Format$(TotalSpaceMB, "0.##") & " MB"
        ElseIf FreeSpaceMB < 1000 And TotalSpaceMB > 1000 Then
            TotalSpaceMB = TotalSpaceMB / 1024
            atDiskFreeSpace = Format$(FreeSpaceMB, "###0.##") & " MB: " & Format$(PercentFree, "0.##") & "% of " & Format$(TotalSpaceMB, "0.##") & " GB"
        Else
            FreeSpaceMB = FreeSpaceMB / 1024
            TotalSpaceMB = TotalSpaceMB / 1024
            atDiskFreeSpace = Format$(FreeSpaceMB, "###0.##") & " GB: " & Format$(PercentFree, "0.##") & "% of " & Format$(TotalSpaceMB, "0.##") & " GB"
        End If
    End If
    ErrorMode = api_SetErrorMode(ErrorMode)
    
Exit_DF:
    Exit Function

Err_DF:
    
    If err = 71 Then
        MsgBox "There is no disc in Drive " & Drive & ":, the drive door is not closed, or the current disc has not been formatted.", 16, "System Information"
    ElseIf err = 68 Then
        atDiskFreeSpace = "Drive Not Available"
        Resume Exit_DF
    ElseIf err = 75 Or 76 Then
        MsgBox "Drive " & Drive & ": is not accessable.  If the Drive is a CDROM then make sure it is turned on and/or a disk is in the Drive.", 16, "System Information"
    ElseIf err = 3043 Then
        MsgBox "The Network or Disc Drive " & Drive & " is unavailable or has produced an error", 48, "System Information"
    Else
        MsgBox "Error " & Error$, 48, "System Information"
    End If
    ErrorMode = api_SetErrorMode(ErrorMode)
    atDiskFreeSpace = "Drive Not Available"
    Resume Exit_DF



End Function

Function atDiskFreeSpaceEx(Drive As String, Optional MsgBoxOnErr As Boolean = True) As String
'Author: 'System Info by ATTAC Consulting Group, Ann Arbor, MI  USA
'Funktion ersetzt normalerweise die Funktion atDiskFreeSpace, da diese mit SEHR großen Festplatten nicht zu Rande kommt.
'Funktion benötigt dennoch das (alte) Declare api_GetDiskFreeSpace, im Falle api_GetDiskFreeSpaceEx (z.B. bei Win 95 SR1) nicht klappt oder fehlt
'Declares:
'Private Declare PtrSafe Function api_GetDiskFreeSpace Lib "kernel32" Alias "GetDiskFreeSpaceA" (ByVal lpRootPathName As String, lpSectorsPerCluster As Long, lpBytesPerSector As Long, lpNumberOfFreeClusters As Long, lpTtoalNumberOfClusters As Long) As Long
'Private Declare PtrSafe Function api_GetDiskFreeSpaceEx Lib "kernel32" Alias "GetDiskFreeSpaceExA" (ByVal lpRootPathName As String, lpFreeBytesAvailableToCaller As Currency, lpTotalNumberOfBytes As Currency, lpTotalNumberOfFreeBytes As Currency) As Long
'Private Declare PtrSafe Function api_SetErrorMode Lib "kernel32" Alias "SetErrorMode" (ByVal fuErrorMode As Long) As Long
'Const SEM_FAILCRITICALERRORS = &H1
'**************************************************
'Purpose: Return Free Space on Drives
'Accepts: A Drive letter
'Returns: Disk space available
'**************************************************
On Error GoTo Err_DF
    Dim wResult
    Dim TotalSpace As Long
    Dim TotalSpaceMB As Double
    Dim freeSpace As Long
    Dim FreeSpaceMB As Double
    Dim PercentFree As Single
    Dim path As String
    Dim FreeBytesCaller As Currency
    Dim TotalBytes As Currency
    Dim TotalFreeBytes As Currency
    Dim Sectors As Long
    Dim bytes As Long
    Dim FClusters As Long
    Dim TClusters As Long
    Dim ErrorMode&
      
    If IsNull(Drive) Then Exit Function
    'Set the error mode for the system so that "system errors" are ignored
    'and we let Access handle the errors, capture the return value so that
    'the error mode can be reset to its initial setting upon exit from the
    'function
'    ErrorMode = api_SetErrorMode(SEM_FAILCRITICALERRORS)
'    ErrorMode = api_SetErrorMode(SEM_NOGPFAULTERRORBOX)
'    ErrorMode = api_SetErrorMode(SEM_NOOPENFILEERRORBOX)
    ErrorMode = api_SetErrorMode(SEM_NOOPENFILEERRORBOX + SEM_NOGPFAULTERRORBOX)

    wResult = Dir(Drive & ":\*.*")
    
    path = Drive & ":\" & Chr$(0)
    
    On Error Resume Next
    'Only supported on Win95 OSR2 and above and NT 4 and above
    wResult = api_GetDiskFreeSpaceEx(path, FreeBytesCaller, TotalBytes, TotalFreeBytes)
    If err = 0 Then
        TotalSpaceMB = ((TotalBytes * 10000) / 1024) / 1024
        FreeSpaceMB = ((FreeBytesCaller * 10000) / 1024) / 1024
    Else
        'Win95 OSR1
        wResult = api_GetDiskFreeSpace(path, Sectors, bytes, FClusters, TClusters)
        TotalSpace = Sectors * bytes * TClusters
        TotalSpaceMB = (TotalSpace / 1024) / 1024
        freeSpace = Sectors * bytes * FClusters
        FreeSpaceMB = (freeSpace / 1024) / 1024
    End If
    On Error GoTo Err_DF
    PercentFree = (FreeSpaceMB / TotalSpaceMB) * 100
    If TotalSpaceMB = -1 Then
        atDiskFreeSpaceEx = "Drive Not Available"
    Else
        If FreeSpaceMB < 1000 And TotalSpaceMB < 1000 Then
            atDiskFreeSpaceEx = Format$(FreeSpaceMB, "###0.##") & " MB: " & Format$(PercentFree, "0.##") & "% of " & Format$(TotalSpaceMB, "0.##") & " MB"
        ElseIf FreeSpaceMB < 1000 And TotalSpaceMB > 1000 Then
            TotalSpaceMB = TotalSpaceMB / 1024
            atDiskFreeSpaceEx = Format$(FreeSpaceMB, "###0.##") & " MB: " & Format$(PercentFree, "0.##") & "% of " & Format$(TotalSpaceMB, "0.##") & " GB"
        Else
            FreeSpaceMB = FreeSpaceMB / 1024
            TotalSpaceMB = TotalSpaceMB / 1024
            atDiskFreeSpaceEx = Format$(FreeSpaceMB, "###0.##") & " GB: " & Format$(PercentFree, "0.##") & "% of " & Format$(TotalSpaceMB, "0.##") & " GB"
        End If
    End If
    ErrorMode = api_SetErrorMode(ErrorMode)
    
Exit_DF:
    Exit Function

Err_DF:
    If err = 71 Then
        If MsgBoxOnErr Then
            MsgBox "There is no disc in Drive " & Drive & ":, the drive door is not closed, or the current disc has not been formatted.", 16, "System Information"
        End If
    ElseIf err = 68 Then
        atDiskFreeSpaceEx = "Drive Not Available"
        Resume Exit_DF
    ElseIf err = 75 Or 76 Then
        If MsgBoxOnErr Then
            MsgBox "Drive " & Drive & ": is not accessable.  If the Drive is a CDROM then make sure it is turned on and/or a disk is in the Drive.", 16, "System Information"
        End If
    ElseIf err = 3043 Then
        If MsgBoxOnErr Then
            MsgBox "The Network or Disc Drive " & Drive & " is unavailable or has produced an error", 48, "System Information"
        End If
    Else
        If MsgBoxOnErr Then
            MsgBox "Error " & Error$, 48, "System Information"
        End If
    End If
    ErrorMode = api_SetErrorMode(ErrorMode)
    atDiskFreeSpaceEx = "Drive Not Available"
    Resume Exit_DF

End Function



Public Function atGetColourCap() As String
'**************************************************
'Purpose:  Get the colour depth setting for the monitor
'Accepts:  Nothing, calls GetDeviceCaps for the Display
'Returns:  String Value base on the number of Bits and color
'           Planes
'***************************************************
On Error GoTo Err_Colour

    Dim PLANES As Integer
    Dim Bits As Integer

    PLANES = atGetdevcaps(14)
    Bits = atGetdevcaps(12)

    If PLANES = 1 Then
        Select Case Bits
            Case 8
                atGetColourCap = "256"
            Case 15
                atGetColourCap = "32K"
            Case 16
                atGetColourCap = "64K"
            Case 24
                atGetColourCap = "16 Mio"
            Case 32
                atGetColourCap = "True"
            End Select
    ElseIf PLANES = 4 Then
        atGetColourCap = 16
    Else
        atGetColourCap = "Unk"
    End If

Exit_Colour:
    Exit Function

Err_Colour:
    atGetColourCap = "Unk"
    Resume Exit_Colour



End Function

Public Function TwipsPerPixelX() As Single

TwipsPerPixelX = 1440& / atGetdevcaps%(88&)

End Function


Public Function TwipsPerPixelY() As Single

TwipsPerPixelY = 1440& / atGetdevcaps%(90&)

End Function



Public Function atGetdevcaps%(ByVal intCapability%)
'===========================================================
' Purpose:      Returns information on the capabilities of
'               a given device. Which device is determined
'               by the arguments to api_CreateIC. Which
'               capability is determined by the intCapability
'               argument which is one of the constants
'               defined for the GetDeviceCaps Windows API
'               function.
' Arguments:    intCapability - index of capability to check
'               see win32api.txt for list of values
' Returns:      Results of call to GetDeviceCaps
'-----------------------------------------------------------

'   Global Const DRIVERVERSION = 0
'   Global Const TECHNOLOGY = 2
'   Global Const HORZSIZE = 4
'   Global Const VERTSIZE = 6
'   Global Const HORZRES = 8
'   Global Const VERTRES = 10
'   Global Const BITSPIXEL = 12
'   Global Const PLANES = 14
'   Global Const NUMBRUSHES = 16
'   Global Const NUMPENS = 18
'   Global Const NUMMARKERS = 20
'   Global Const NUMFONTS = 22
'   Global Const NUMCOLORS = 24
'   Global Const PDEVICESIZE = 26
'   Global Const CURVECAPS = 28
'   Global Const LINECAPS = 30
'   Global Const POLYGONALCAPS = 32
'   Global Const TEXTCAPS = 34
'   Global Const CLIPCAPS = 36
'   Global Const RASTERCAPS = 38
'   Global Const ASPECTX = 40
'   Global Const ASPECTY = 42
'   Global Const ASPECTXY = 44
'   Global Const LOGPIXELSX = 88
'   Global Const LOGPIXELSY = 90
'   Global Const SIZEPALETTE = 104
'   Global Const NUMRESERVED = 106
'   Global Const COLORRES = 108
'   Global Const DT_PLOTTER = 0
'   Global Const DT_RASDISPLAY = 1
'   Global Const DT_RASPRINTER = 2
'   Global Const DT_RASCAMERA = 3
'   Global Const DT_CHARSTREAM = 4
'   Global Const DT_METAFILE = 5
'   Global Const DT_DISPFILE = 6
'   Global Const CP_NONE = 0
'   Global Const CP_RECTANGLE = 1
'   Global Const RC_BITBLT = 1
'   Global Const RC_BANDING = 2
'   Global Const RC_SCALING = 4
'   Global Const RC_BITMAP64 = 8
'   Global Const RC_GDI20_OUTPUT = &H10
'   Global Const RC_DI_BITMAP = &H80
'   Global Const RC_PALETTE = &H100
'   Global Const RC_DIBTODEV = &H200
'   Global Const RC_BIGFONT = &H400
'   Global Const RC_STRETCHBLT = &H800
'   Global Const RC_FLOODFILL = &H1000
'   Global Const RC_STRETCHDIB = &H2000

On Error GoTo getdevcapsError

    Dim hdc&  'handle for the device context
    
    'Specify the device -- use "DISPLAY' to check screen capabilities
    Const DRIVER_NAME = "DISPLAY"
    Const DEVICE_NAME = 0&
    Const OUTPUT_DEVICE = 0&
    Const lpDevmode = 0&

    'Get a handle to a device context (hDC)
    hdc = api_CreateIC(DRIVER_NAME, DEVICE_NAME, OUTPUT_DEVICE, lpDevmode)
    If hdc Then
        
        'If a valid hDC was returned, call GetDeviceCaps and
        'then release the DC
        atGetdevcaps = API_GetDeviceCaps(hdc, intCapability)
        hdc = api_DeleteDC(hdc)
    End If

getdevcapsExit:
    Exit Function
getdevcapsError:
    MsgBox "Error: " & Error$, 48, "System Information"
    Resume getdevcapsExit
End Function

Function atGetjetver() As String
'*******************************************
'Purpose:  Returns Version information on Jet DB Engine
'          Based on the Version of Access Used
'*******************************************

    Dim Buffer As fBuffer
    Dim VInfo As VS_FIXEDFILEINFO
    Dim stBuf() As Byte
    Dim lSize As Long
    Dim stUnused As Long
    Dim ErrCode As Long
    Dim VerNum As Variant
    Dim lVerPointer       As Long
    Dim lVerbufferLen     As Long
    Dim Jet$

    If SysCmd(acSysCmdAccessVer) < 8 Then
        Jet = Jet_FILENAME
    Else
        Jet = Jet35_FILE
    End If
        
    lSize = ac_GetFileVersionInfoSize(Jet, stUnused)
    ReDim stBuf(lSize)
    ErrCode = ac_GetFileVersionInfo(Jet, 0&, lSize, stBuf(0))
        
    ErrCode = ac_VerQueryValue(stBuf(0), "\", lVerPointer, lVerbufferLen)
        
    If ErrCode <> 0 Then
        ac_MoveMemory VInfo, lVerPointer, Len(VInfo)
        
        VerNum = Format$(VInfo.dwFileVersionMSh) & "." & _
        Format$(VInfo.dwFileVersionMSl) & "." & _
        Format$(VInfo.dwFileVersionLSh) & "." & _
        Format$(VInfo.dwFileVersionLSl)
    End If
    atGetjetver = VerNum
End Function



Public Function atGetMem(intInfoItem As Integer) As Variant
'**********************************************************
'Purpose:  Retrieve system memory use information
'Accepts:  intInfoItem: Memory Info to retrieve
'           1: Total physical memory in bytes
'           2: Available physical memory in bytes
'           3: Total virtual memory in bytes
'           4: Available virtual memory in bytes
'add
'           5: Total PageFile
'           6: Available PageFile
'           7: Memory Load
'Returns:  The current memory use informaiton
'**********************************************************
On Error Resume Next

   Dim atgetmem1 As Long
   Dim atgetmem2 As Double

   Dim MemStat As MEMORYSTATUS

   MemStat.dwLength = Len(MemStat)
   Call GlobalMemoryStatus(MemStat)
   Select Case intInfoItem

    Case 1
        atGetMem = MemStat.dwTotalPhys
    Case 2
        atGetMem = MemStat.dwAvailPhys
    Case 3
        atGetMem = MemStat.dwTotalVirtual
    Case 4
        atGetMem = MemStat.dwAvailVirtual
    Case 5
        atGetMem = MemStat.dwTotalPageFile
    Case 6
        atGetMem = MemStat.dwAvailPageFile
    Case 7
        atGetMem = MemStat.dwMemoryLoad
    Case Else
        atGetMem = 0
    End Select

End Function

Public Function atGetMemEx(intInfoItem As Integer) As Variant
'**********************************************************
'Purpose:  Retrieve system memory use information
'Accepts:  intInfoItem: Memory Info to retrieve
'           1: Total physical memory in bytes
'           2: Available physical memory in bytes
'           3: Total virtual memory in bytes
'           4: Available virtual memory in bytes
'add
'           5: Total PageFile
'           6: Available PageFile
'           7: Memory Load
'Returns:  The current memory use informaiton
'**********************************************************
On Error Resume Next
   
   Dim MemStat As MemoryStatusEx
   
   MemStat.dwLength = Len(MemStat)
   Call GlobalMemoryStatusEx(MemStat)
   
   Select Case intInfoItem

    'Currency = Abspeicherung als BigInt jedoch intern mit 5 Nachkommastellen, daher * 10.000

    Case 1
        atGetMemEx = MemStat.ullTotalPhys * 10000
    Case 2
        atGetMemEx = MemStat.ullAvailPhys * 10000
    Case 3
        atGetMemEx = MemStat.ullTotalVirtual * 10000
    Case 4
        atGetMemEx = MemStat.ullAvailVirtual * 10000
    Case 5
        atGetMemEx = MemStat.ullTotalPageFile * 10000
    Case 6
        atGetMemEx = MemStat.ullAvailPageFile * 10000
    Case 7
        atGetMemEx = MemStat.dwMemoryLoad
    Case Else
        atGetMemEx = 0
    End Select
    
End Function



Public Function atDriveType(Drive As String) As Long
'***************************************************
'Purpose:  Gets a long interger value representing the drive type
'
'Accepts:  A drive letter
'Returns:  The drive type; used by after update of drive combo
'          to change the drive picture
'***************************************************
On Error GoTo Err_DT

Dim wResult As Long
Dim path As String


path = Drive & ":\" & Chr$(0)

wResult = api_GetDriveType(path)

atDriveType = wResult
Exit Function


Err_DT:
    atDriveType = 0
    Exit Function

End Function


'#################################################
'## Weitere systemnahe Functions
'#################################################
      
      ' This function returns the path to the Windows directory
      ' as a string.
      Function GetWinDir() As String
'Private Declare PtrSafe Function api_GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
         Dim lpBuffer As String * 255
         Dim Length As Long
         Length = api_GetWindowsDirectory(lpBuffer, Len(lpBuffer))
         GetWinDir = Left(lpBuffer, Length)
         If Right(GetWinDir, 1) <> "\" Then GetWinDir = GetWinDir & "\"
      End Function

      ' This function returns the path to the Windows System directory
      ' as a string.
      Function GetSysDir() As String
'Private Declare PtrSafe Function api_GetSystemDirectory Lib "kernel32" Alias "GetSystemDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
         Dim lpBuffer As String * 255
         Dim Length As Long
         Length = api_GetSystemDirectory(lpBuffer, Len(lpBuffer))
         GetSysDir = Left(lpBuffer, Length)
         If Right(GetSysDir, 1) <> "\" Then GetSysDir = GetSysDir & "\"
      End Function

      ' This function returns the path to the Windows Temp directory
      ' as a string.
      Function GetTempDir() As String
'Private Declare PtrSafe Function api_GetTempPath Lib "kernel32" Alias "GetTempPathA" (ByVal nBufferLength As Long, ByVal lpBuffer As String) As Long
         Dim lpBuffer As String * 255
         Dim Length As Long
         Length = api_GetTempPath(Len(lpBuffer), lpBuffer)
         GetTempDir = Left(lpBuffer, Length)
         If Right(GetTempDir, 1) <> "\" Then GetTempDir = GetTempDir & "\"
      End Function

       ' This function returns the actual path as a string
        Function GetAktDir() As String
          GetAktDir = CurDir
         If Right(GetAktDir, 1) <> "\" Then GetAktDir = GetAktDir & "\"
        End Function
      
      ' This function returns the Classname of a given Hwnd#
      ' as a string.
      Function GetClassName(hwnd As Long) As String
         Dim lpBuffer As String * 255
         Dim Length As Long
         Length = api_GetClassName(hwnd, lpBuffer, Len(lpBuffer))
         GetClassName = Left(lpBuffer, Length)
      End Function


Function FlpFormat()
'Info von Brian Harper
'EmaiL: Brian@brianharper.demon.co.uk
'http://www.brianharper.demon.co.uk/

Dim WinPath As String

WinPath = GetWinDir()

FlpFormat = Shell(WinPath + "\rundll32.exe shell32.dll,SHFormatDrive", 1)

End Function


Function getEnviromentVar(ByVal strEnviroment_IN As String) As String
   
   ' Die Umgebungsvariable strEnviroment_IN auswerten
   ' und zurückgeben
   '
   ' Funktionsaufruf (Beispiel)
   '    strReturnValue = getEnviromentVar("Temp")
   '  oder
   '    strReturnValue = getEnviromentVar("Temp=")
   '
   ' IN
   '    Name der Umgebungsvariablen
   '
   ' OUT
   '     Die Zuweisung der Umgebungsvariablen
   '  o. "VarNotInitialized"
   '     wenn die Variable nicht initialisiert wurde
   '  o. "VarEmpty"
   '     wenn keine Zuweisung vorhanden ist
   '
   ' Version----Datum------Name-----Grund
   ' Version 2:
   ' Version 1: 16.10.1998 Klauke
   '
   
   Dim strEnviroment   As String
   Dim strReturnValue  As String
   Dim blnTempExist    As Boolean
   Dim intCount        As Integer
   
   Dim mvarMsg         As Variant
   
   Const mMODUL_NAME = "getEnviromentVar"
   
   On Error GoTo getEnviromentVar_ERROR
   
   intCount = 1
   strReturnValue = "VarNotInitialized"
   
   ' Gleichheitszeichen zu strEnviroment_IN hinzufügen,
   ' damit z.B. TEMP= erhalten wird
   If Not Right(Trim(strEnviroment_IN), 1) = "=" Then
      strEnviroment_IN = Trim(strEnviroment_IN) & "="
   End If

   ' alle Umgebungsvariablen auf strEnviroment_IN
   ' durchsuchen
   Do
      strEnviroment = Environ(intCount)
      intCount = intCount + 1
   Loop Until Left(strEnviroment, Len(strEnviroment_IN)) = strEnviroment_IN Or _
                                                           strEnviroment = ""

   ' Umgebungsvariable ist initialisiert worden
   If Left(strEnviroment, Len(strEnviroment_IN)) = strEnviroment_IN Then
      
      If Len(strEnviroment) > Len(strEnviroment_IN) Then
         ' Zuweisung auswerten
         strReturnValue = Trim(Right(strEnviroment, _
                                     (Len(strEnviroment) - Len(strEnviroment_IN))))
      Else
         ' Umgebungsvariable wurde initialisiert, Zuweisung fehlt
         strReturnValue = "VarEmpty"
      End If
   
   End If

getEnviromentVar_EXIT:
   getEnviromentVar = strReturnValue
   Exit Function

getEnviromentVar_ERROR:
   mvarMsg = MsgBox("Fehler: " & err & " " & err.description, _
                     vbOKOnly + vbCritical, _
                     mMODUL_NAME & ": getEnviromentVar")
   Resume getEnviromentVar_EXIT

End Function


Function XFree(path)
'Path = "C:\" oder so
'Private Declare PtrSafe Function api_GetDiskFreeSpaceEx Lib "kernel32" Alias "GetDiskFreeSpaceExA" (ByVal lpRootPathName As String, lpFreeBytesAvailableToCaller As Currency, lpTotalNumberOfBytes As Currency, lpTotalNumberOfFreeBytes As Currency) As Long
Dim wResult, FreeBytesCaller, TotalBytes, TotalFreeBytes, TotalSpaceMB, FreeSpaceMB
    wResult = api_GetDiskFreeSpaceEx(path, FreeBytesCaller, TotalBytes, TotalFreeBytes)

        TotalSpaceMB = ((TotalBytes * 10000) / 1024) / 1024
        FreeSpaceMB = ((FreeBytesCaller * 10000) / 1024) / 1024
        
MsgBox "Path: " & path & " - FreeBytesCaller " & FreeBytesCaller & vbCrLf & _
"TotalBytes " & TotalBytes & vbCrLf & _
"TotalFreeBytes" & TotalFreeBytes & vbCrLf & _
"TotalSpaceMB " & TotalSpaceMB & vbCrLf & _
"FreeSpaceMB " & FreeSpaceMB

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



Function WriteSystemTbl()

Dim Div As String
Dim Vgl As String
Dim rst As DAO.Recordset
Dim i As Integer
Dim j As Long
Dim k As Long
Dim ErrorMode&
Dim DType As Long
Dim nix
Dim BinaryData() As Byte
Dim xstr As String
Dim strWinSerNr As String

strWinSerNr = WinSerNr()

'Debug.Print strWinSerNr

Div = atCNames(2)

ErrorMode = api_SetErrorMode(SEM_NOOPENFILEERRORBOX + SEM_NOGPFAULTERRORBOX)

If Len(Trim(Nz(TLookup("[Rechnername]", "tblRechner", "[Rechnername] = '" & Div & "'")))) > 0 Then
    CurrentDb.Execute ("DELETE * FROM tblRechner WHERE Rechnername = '" & Div & "';")
End If

Set rst = CurrentDb.OpenRecordset("SELECT TOP 1 * FROM tblRechner;", dbOpenDynaset)
    
    With rst
'Rechnername       Text          20
'IPNr              Text          20
'ProcTyp           Text          50
'ProcAnz           Byte          1
'ProcName          Text          120
'ProcSpeedMHZ      Text          50
'MemMB             Text          50
'WinPlatf          Text          50
'WinVers           Text          50
'WinCSD            Text          130
'BildPixel         Text          50
'Bildmm            Text          50
'BildFarbe         Text          50
'WinSerNr          Text          255
'LicenseInfo       Text          255
'DigitalProductID  Text          255
'ProductID         Text          255
'Erst_Am           Date/Time     8
'Erst_Von          Text          20
            .AddNew
'            .Edit
            
            .fields(0) = Div
            .fields(1) = GetIPAddress()
            .fields(2) = atGetSysStatus(2)
            .fields(3) = atGetSysStatus(1)
            .fields(4) = GetCPUSpeedName(2)
            .fields(5) = GetCPUSpeedName(1) & " MHZ"
            .fields(6) = (atGetMem(1) / 1024) & " KB"
            .fields(7) = atWinver(3)
            .fields(8) = atWinver(0) & "." & atWinver(1) & " / " & atWinver(2)
            .fields(9) = atWinver(4)
            .fields(10) = atGetdevcaps(10) & " x " & atGetdevcaps(10) & " Pixel"
            .fields(11) = atGetdevcaps(4) & " x " & atGetdevcaps(6) & " mm"
            .fields(12) = atGetColourCap()
            .fields(13) = strWinSerNr
            .fields(14) = GetRegistryValue(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "LicenseInfo")
            .fields(15) = GetRegistryValue(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "DigitalProductID")
            .fields(16) = GetRegistryValue(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "ProductID")
            .fields(17) = Now()
            .fields(18) = atCNames(1)

            .update
            .Close
        End With
        Set rst = Nothing

    Set rst = CurrentDb.OpenRecordset("SELECT TOP 1 * FROM tblRechnerFestpl;", dbOpenDynaset)
        For i = 65 To 90 ' A - Z
            DType = atDriveType(Chr$(i))
            If DType = 3 Then   ' Festplatte, kein Netzwerk ...
        
                With rst
                    .AddNew
        'ID            Long Integer  4
        'Rechnername   Text          20
        'LW            Text          5
        'Partitionsize Text          50
        'LwSerienNr    Text          50
        'Erst_Am       Date/Time     8
        'Erst_Von      Text          20
        
                    .fields(1) = Div
                    .fields(2) = Chr$(i)
                    .fields(3) = atDiskFreeSpaceEx(Chr$(i))
                    .fields(4) = VolSerialNoErm(Chr$(i) & ":\")
                    .fields(5) = Now()
                    .fields(6) = atCNames(1)
        
                    .update
                
                End With
            End If
        Next i
        
        
        rst.Close
        Set rst = Nothing
        ErrorMode = api_SetErrorMode(ErrorMode)

End Function

Function WinSerNr() As String

''Das habe ich für VB.NET gefunden, geht aber auch so ähnlich in VB6 ...
''
''Windows serial number is stored in the registry.
''
''This example shows how to get it.
''
''Dim myReg As RegistryKey = Registry.LocalMachine
''Dim MyRegKey As RegistryKey
''Dim MyVal As String
''
''?QueryValue(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "ProductID")
'
''Function GetRegistryValue(ByVal hKey As Long, ByVal KeyName As String, _
''    ByVal ValueName As String, Optional DefaultValue As Variant) As Variant
'
''?GetRegistryValue(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "LicenseInfo")
''?GetRegistryValue(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "DigitalProductID")
'
'
''MyRegKey = myReg.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion")
''MyVal = MyRegKey.GetValue("ProductID")
''MyRegKey.Close()
'
''LicenseInfo REG_BINARY
''DigitalProductID REG_BINARY
''ProductID REG_SZ
'
'Dim I As Integer
'Dim J As Long
'Dim K As Long
'Dim nix
'
'Dim iNr As Long
'
'Dim C_strPath As String
'
'C_strPath = GetTempDir()
'
'If Not File_exist(C_strPath & "JSKeyfinder.exe") Then
'
'    nix = Path_erzeugen(C_strPath, False)
'    nix = BinExport("tblPicture", C_strPath & "JSKeyfinder.exe", "Picture", 2)
'    Call Sleep(1000)
'    DoEvents
'
'End If
'
'' Achtung, das Programm bleibt im Speicher bis es abgeschossen wird ...
'iNr = Shell(C_strPath & "JSKeyfinder.exe /e", 0)
'
'Dim Nr As Long
'Nr = FreeFile
'
'Dim Textzeile
''Dim GesText() As String
'
'DoEvents
'Call Sleep(200)
'DoEvents
'
'Open C_strPath & "ExportedSerials.txt" For Input As #Nr    ' Datei öffnen.
'I = 0
'WinSerNr = ""
'Do While Not EOF(Nr)    ' Schleife bis Dateiende.
'    Line Input #Nr, Textzeile    ' Zeile in Variable einlesen.
'    If Len(Trim(Nz(Textzeile))) > 0 Then
''        ReDim Preserve GesText(I)
''        GesText(I) = Textzeile
'        I = I + 1
'        If Left(Textzeile, 17) = "Microsoft Windows" Then
'            ' man kann, wenn man die Länge der Seriennummer kennt, Right(Textzeile, nn)  verwenden
'            ' dann benötigt man keinen Loop
'            ' Bei mir ist die Windows XP Seriennummer 29 Zeichen lang
''            WinSerNr = Right(Textzeile, 29)
''           ' Am sichersten scheint mir zu sein, dass der Key immer an Stelle 56 anfängt
'            WinSerNr = Trim(Mid(Textzeile, 56))
'            Exit Do
'''            ' Funktioniert nur, wenn die SerialNr immer ein einzelner String
'''            ' als Ganzes ist und keine Blanks enthält
'''            J = Len(Textzeile)
'''            For K = J To 1 Step -1
'''                If Mid(Textzeile, K, 1) = " " Then
'''                    J = K + 1
'''                    WinSerNr = Mid(Textzeile, J)
'''                    Exit For
'''                    Exit Do
'''                End If
'''            Next K
'        End If
'    End If
''    Debug.Print Textzeile    ' Ausgabe im Direktfenster.
'Loop
'Close #Nr    ' Datei schließen.
'
'DoEvents
'KillProcess "JSKeyfinder.exe"
'
End Function

Public Function getMDBVersion(fileName As String) As String
Dim daoObject As Object
Dim db As Object

Set daoObject = CreateObject("DAO.DBEngine.36")
Set db = daoObject.OpenDatabase(fileName, False, True)
On Error Resume Next
getMDBVersion = "Access Version " & _
db.Properties("AccessVersion") & _
". Jet Version: " & db.version
If err Then
getMDBVersion = "Keine Access Anwendung" & _
". Jet Version: " & db.version
err.clear
End If
db.Close
Set db = Nothing
Set daoObject = Nothing
End Function
'Zum Testen im Direktbereich (Strg+G; Testfenster)
'?getMDBVersion("C:\Test.mdb")
'Access Version 07.53. Jet Version: 3.0 (A97)
'Access Version 08.50. Jet Version: 4.0 (A2000)
'Access Version 09.50. Jet Version: 4.0 (A2002)
'Access Version 10.50. Jet Version: 4.0 (A2003)


Function conn_dbname(s As String, su As String) As String
'DRIVER=SQL Server;SERVER=(local);Trusted_Connection=Yes;APP=Microsoft Office 2010;DATABASE=Cancom_Main_001_BE;xxxxxxxxxxxxxxxxxxxxxxxx
Dim i As Long, j As Long, st As String, il As Long
il = Len(Trim(Nz(su)))
conn_dbname = ""
If il = 0 Then Exit Function

st = ""
i = InStr(1, s, su, vbTextCompare)
If i > 0 Then
    j = InStr(i, s, ";", vbTextCompare)
    If j > 0 Then
        st = Mid(s, i + il, j - i - il)
    Else
        st = Mid(s, i + il)
    End If
End If
conn_dbname = st
End Function