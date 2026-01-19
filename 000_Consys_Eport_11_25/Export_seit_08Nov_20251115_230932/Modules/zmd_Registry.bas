'Option Compare Database
'Option Explicit

'Private Declare PtrSafe Function CoInternetSetFeatureEnabled Lib "urlmon.dll" Alias "CoInternetSetFeatureEnabledA" (ByVal FeatureEntry As eINTERNETFEATURELIST, ByVal Flags As eFEATURESetting, ByVal bEnable As Long) As Long
'Private Declare PtrSafe Function CoInternetIsFeatureEnabled Lib "urlmon.dll" Alias "CoInternetIsFeatureEnabledA" (ByVal FeatureEntry As eINTERNETFEATURELIST, ByVal Flags As eFEATURESetting) As Long
Private Declare PtrSafe Function CoInternetSetFeatureEnabled Lib "urlmon.dll" (ByVal FeatureEntry, ByVal Flags, ByVal bEnable As Long) As Long
Private Declare PtrSafe Function CoInternetIsFeatureEnabled Lib "urlmon.dll" (ByVal FeatureEntry, ByVal Flags) As Long


Sub ChangeWebControlFeature()
     Dim ret As Long
     Dim lret As Long
     
     SET_FEATURE_ON_PROCESS = "0x02"
     FEATURE_BEHAVIORS = "0x06"
     FEATURE_ZONE_ELEVATION = "0x01"
     FEATURE_RESTRICT_ACTIVEXINSTALL = "0x0A"
     
     If CoInternetIsFeatureEnabled(FEATURE_BEHAVIORS, SET_FEATURE_ON_PROCESS) <> 0 Then
         ret = CoInternetSetFeatureEnabled(FEATURE_BEHAVIORS, SET_FEATURE_ON_PROCESS, 1)
         lret = ret
     End If
     If CoInternetIsFeatureEnabled(FEATURE_ZONE_ELEVATION, SET_FEATURE_ON_PROCESS) <> 0 Then
         ret = CoInternetSetFeatureEnabled(FEATURE_ZONE_ELEVATION, SET_FEATURE_ON_PROCESS, 1)
         lret = lret + ret
     End If
     If CoInternetIsFeatureEnabled(FEATURE_RESTRICT_ACTIVEXINSTALL, SET_FEATURE_ON_PROCESS) <> 0 Then
          ret = CoInternetSetFeatureEnabled(FEATURE_RESTRICT_ACTIVEXINSTALL, SET_FEATURE_ON_PROCESS, 0)
         lret = lret + ret
     End If
     Debug.Print IIf(lret = 0, "Features adjusted", "Feature adjustment failed")
End Sub


'Registry-Einträge für Webbrowser
Function write_reg()
    Dim oShell As Object
    
    Set oShell = CreateObject("WScript.Shell")
    
    vRegElement = Array("FEATURE_BLOCK_LMZ_SCRIPT", "FEATURE_BLOCK_LMZ_OBJECT", "FEATURE_BLOCK_LMZ_IMG")
    For i = 0 To 2
         sKey = "HKEY_CURRENT_USER\Software\Microsoft\" & _
             "Internet Explorer\Main\FeatureControl\" & _
             vRegElement(i) & "\msaccess.exe"
    
         oShell.RegWrite sKey, 1, "REG_DWORD"
         
    Next i
    Set oShell = Nothing
    
End Function

Sub SetWebControlAsIE9()
    Dim sKey As String
    Dim oShell As Object
    Dim vKey As Variant
    Dim nErr As Long
    
    Set oShell = CreateObject("WScript.Shell")
    
    sKey = "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\msaccess.exe"
    On Error Resume Next
    vKey = oShell.RegRead(sKey)
    nErr = err.Number
    On Error GoTo 0
    If nErr = -2147024894 Then
        oShell.RegWrite sKey, 9999, "REG_DWORD"
        Debug.Print "IE Mode set"
    Else
        If vKey <> 12001 Then 'EDGE
            oShell.RegWrite sKey, 12001, "REG_DWORD" '9999 = IE9
            Debug.Print "IE9 Mode set"
        Else
            Debug.Print "IE Mode is already set"
        End If
    End If
    Set oShell = Nothing
    
End Sub