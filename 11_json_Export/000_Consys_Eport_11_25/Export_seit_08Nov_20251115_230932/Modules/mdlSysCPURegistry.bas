Option Compare Database
Option Explicit

'Flags for GetSystemInfo
Private Const PROCESSOR_INTEL_386 As Long = 386
Private Const PROCESSOR_INTEL_486 As Long = 486
Private Const PROCESSOR_INTEL_PENTIUM As Long = 586
Private Const PROCESSOR_MIPS_R4000 As Long = 4000
Private Const PROCESSOR_ALPHA_21064 As Long = 21064
Private Const PROCESSOR_PPC_601 As Long = 601
Private Const PROCESSOR_PPC_603 As Long = 603
Private Const PROCESSOR_PPC_604 As Long = 604
Private Const PROCESSOR_PPC_620 As Long = 620
Private Const PROCESSOR_HITACHI_SH3 As Long = 10003    'Windows CE
Private Const PROCESSOR_HITACHI_SH3E As Long = 10004   'Windows CE
Private Const PROCESSOR_HITACHI_SH4 As Long = 10005    'Windows CE
Private Const PROCESSOR_MOTOROLA_821 As Long = 821     'Windows CE
Private Const PROCESSOR_SHx_SH3 As Long = 103          'Windows CE
Private Const PROCESSOR_SHx_SH4 As Long = 104          'Windows CE
Private Const PROCESSOR_STRONGARM As Long = 2577       'Windows CE - 0xA11
Private Const PROCESSOR_ARM720 As Long = 1824          'Windows CE - 0x720
Private Const PROCESSOR_ARM820 As Long = 2080          'Windows CE - 0x820
Private Const PROCESSOR_ARM920 As Long = 2336          'Windows CE - 0x920
Private Const PROCESSOR_ARM_7TDMI As Long = 70001      'Windows CE

Private Const PROCESSOR_ARCHITECTURE_INTEL As Long = 0
Private Const PROCESSOR_ARCHITECTURE_MIPS As Long = 1
Private Const PROCESSOR_ARCHITECTURE_ALPHA As Long = 2
Private Const PROCESSOR_ARCHITECTURE_PPC As Long = 3
Private Const PROCESSOR_ARCHITECTURE_SHX As Long = 4
Private Const PROCESSOR_ARCHITECTURE_ARM As Long = 5
Private Const PROCESSOR_ARCHITECTURE_IA64 As Long = 6
Private Const PROCESSOR_ARCHITECTURE_ALPHA64 As Long = 7
Private Const PROCESSOR_ARCHITECTURE_UNKNOWN   As Long = &HFFFF

Private Const PROCESSOR_LEVEL_80386 As Long = 3
Private Const PROCESSOR_LEVEL_80486 As Long = 4
Private Const PROCESSOR_LEVEL_PENTIUM As Long = 5
Private Const PROCESSOR_LEVEL_PENTIUMII As Long = 6

Private Const sCPURegKey = "HARDWARE\DESCRIPTION\System\CentralProcessor\0"

Private Const HKEY_LOCAL_MACHINE As Long = &H80000002

Private Type SYSTEM_INFO
   dwOemID As Long
   dwPageSize As Long
   lpMinimumApplicationAddress As Long
   lpMaximumApplicationAddress As Long
   dwActiveProcessorMask As Long
   dwNumberOfProcessors As Long
   dwProcessorType As Long
   dwAllocationGranularity As Long
   wProcessorLevel As Integer
   wProcessorRevision As Integer
End Type

Private Declare PtrSafe Sub GetSystemInfo Lib "kernel32" _
   (lpSystemInfo As SYSTEM_INFO)

Private Declare PtrSafe Function RegCloseKey Lib "advapi32.dll" _
   (ByVal hKey As Long) As Long

Private Declare PtrSafe Function RegOpenKey Lib "advapi32.dll" _
   Alias "RegOpenKeyA" _
  (ByVal hKey As Long, _
   ByVal lpSubKey As String, _
   phkResult As Long) As Long

Private Declare PtrSafe Function RegQueryValueEx Lib "advapi32.dll" _
   Alias "RegQueryValueExA" _
  (ByVal hKey As Long, _
   ByVal lpValueName As String, _
   ByVal lpReserved As Long, _
   lpType As Long, _
   lpData As Any, _
   lpcbData As Long) As Long
   

Sub Test_Click()

   Dim si As SYSTEM_INFO
   Dim tmp As String
   
   Call GetSystemInfo(si)
   
   Debug.Print "CPU Speed", , " " & GetCPUSpeedName(1) & " MHz"
   Debug.Print "Processor Name", " " & GetCPUSpeedName(2)
   Debug.Print "----------------------------------------------"
   Debug.Print "Number Of Processors", si.dwNumberOfProcessors
   
   Select Case si.dwProcessorType
      Case PROCESSOR_INTEL_386: tmp = "386"
      Case PROCESSOR_INTEL_486: tmp = "486"
      Case PROCESSOR_INTEL_PENTIUM: tmp = "Pentium"
      Case PROCESSOR_MIPS_R4000: tmp = "MIPS 4000"
      Case PROCESSOR_ALPHA_21064: tmp = "Alpha"
   End Select

   Debug.Print "Processor Type", si.dwProcessorType, tmp

   Select Case si.wProcessorLevel
      Case PROCESSOR_LEVEL_80386: tmp = "Intel 80386"
      Case PROCESSOR_LEVEL_80486: tmp = "Intel 80486"
      Case PROCESSOR_LEVEL_PENTIUM: tmp = "Intel Pentium"
      Case PROCESSOR_LEVEL_PENTIUMII: tmp = "Intel Pentium Pro or Pentium II"
   End Select
   
   Debug.Print "Processor Level", si.wProcessorLevel, tmp
   
   Debug.Print "Processor Revision", si.wProcessorRevision, _
         "Model "; HiByte(si.wProcessorRevision) & _
         ", Stepping " & LoByte(si.wProcessorRevision)

End Sub


Function GetCPUSpeedName(n As Long) As Variant
   
   Dim hKey As Long
   Dim cpuSpeed As Long
   Dim cpuName As String
   Dim i As Long
    
If n = 1 Then
  'Open CPU key
   Call RegOpenKey(HKEY_LOCAL_MACHINE, sCPURegKey, hKey)
                    
  'and retrieve the value
   Call RegQueryValueEx(hKey, "~MHz", 0, 0, cpuSpeed, 4)
   Call RegCloseKey(hKey)
   
   GetCPUSpeedName = cpuSpeed
Else
  
  'Open CPU key
   Call RegOpenKey(HKEY_LOCAL_MACHINE, sCPURegKey, hKey)
                    
  
  Dim lType As Long
  Dim cch As Long
  Dim lrc As Long
  
      ' Determine the size and type of data to be read
    lrc = RegQueryValueExNULL(hKey, "ProcessorNameString", 0&, lType, 0&, cch)
    If lrc <> ERROR_NONE Then Error 5

    Select Case lType
        ' For strings
        Case REG_SZ:
            cpuName = String(cch, 0)
            lrc = RegQueryValueExString(hKey, "ProcessorNameString", 0&, lType, _
            cpuName, cch)
            If lrc = ERROR_NONE Then
                cpuName = Left$(cpuName, cch - 1)
            Else
                cpuName = Empty
            End If
            Call RegCloseKey(hKey)
        Case Else
          Error 5
            
    End Select
   
   GetCPUSpeedName = cpuName

End If
End Function


Public Function HiByte(ByVal wParam As Integer) As Byte
   
  'note: VB4-32 users should declare this function As Integer
   HiByte = (wParam And &HFF00&) \ (&H100)

End Function


Public Function LoByte(ByVal wParam As Integer) As Byte

  'note: VB4-32 users should declare this function As Integer
   LoByte = wParam And &HFF&

End Function
'--end block--'