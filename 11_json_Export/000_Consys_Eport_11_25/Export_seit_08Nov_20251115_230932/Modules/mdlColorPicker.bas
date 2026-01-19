' Original Code by Terry Kreft
' Modified by Stephen Lebans
' Contact Stephen@lebans.com

Option Compare Database
Option Explicit
'***********  Code Start  ***********
Private Type COLORSTRUC
  lStructSize As Long
  hwnd As Long
  hInstance As Long
  rgbResult As Long
  lpCustColors As String
  Flags As Long
  lCustData As Long
  lpfnHook As Long
  lpTemplateName As String
End Type

Private Const CC_SOLIDCOLOR = &H80
Private Const CC_RGBINIT = &H1


Private Declare PtrSafe Function ChooseColor Lib "comdlg32.dll" Alias "ChooseColorA" _
  (pChoosecolor As COLORSTRUC) As Long

Public Function ShowColorDialog(Optional ByVal PreSelectedColor As Long = 0) As Long
  Dim x As Long, CS As COLORSTRUC, CustColor(16) As Long

  CS.lStructSize = Len(CS)
  
  CS.hwnd = Application.hWndAccessApp

  CS.Flags = CC_SOLIDCOLOR Or CC_RGBINIT
  CS.lpCustColors = String$(16 * 4, 0)
  
  CS.rgbResult = PreSelectedColor

  x = ChooseColor(CS)
  If x = 0 Then
    ' ERROR - return preselected Color
     ShowColorDialog = PreSelectedColor
    Exit Function
  Else
    ' Normal processing
     ShowColorDialog = CS.rgbResult
  End If
  
End Function
'***********  Code End   ***********



'Function XRGB(x As Long) As Variant
'XRGB = "#" & Right("000000" & Hex(x), 6)
'End Function