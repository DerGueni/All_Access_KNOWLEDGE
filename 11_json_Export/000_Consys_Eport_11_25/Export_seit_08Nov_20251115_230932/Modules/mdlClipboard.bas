Option Compare Database
Option Explicit
     
'MS KB Artikel Q138910
'INF: How to Retrieve Information from the Clipboard (ACC 7.0, 97)
'   Function ClipBoard_GetData()

'MS KB Artikel Q138909
'INF: How to Send Information to the Clipboard (ACC 7.0, 97)
'   Function ClipBoard_SetData(MyString As String)
           
'MS KB Artikel Q148392
'INF: How to Capture Screens of Your Forms (ACC 7.0/97) into Clipboard
'   Function ScreenDump()
           
'Function PrtScn(Alles As Boolean)
    ' Alles = True - Gesamter Bildschirm
    ' Alles = False - Aktives Fenster
    
'Function ClipBoard_Clear()
      
      Declare PtrSafe Function OpenClipboard Lib "user32" (ByVal hwnd As Long) As Long
      Declare PtrSafe Function CloseClipboard Lib "user32" () As Long
      Declare PtrSafe Function GetClipboardData Lib "user32" (ByVal wFormat As Long) As Long
      Declare PtrSafe Function SetClipboardData Lib "user32" (ByVal wFormat As Long, ByVal hMem As Long) As Long
      Declare PtrSafe Function EmptyClipboard Lib "user32" () As Long
      
      Declare PtrSafe Function GlobalAlloc Lib "kernel32" (ByVal wFlags&, ByVal dwBytes As Long) As Long
      Declare PtrSafe Function GlobalLock Lib "kernel32" (ByVal hMem As Long) As Long
      Declare PtrSafe Function GlobalUnlock Lib "kernel32" (ByVal hMem As Long) As Long
      Declare PtrSafe Function GlobalSize Lib "kernel32" (ByVal hMem As Long) As Long
      Declare PtrSafe Function lstrcpy Lib "kernel32" (ByVal lpString1 As Any, ByVal lpString2 As Any) As Long

      Declare PtrSafe Sub keybd_event Lib "user32" (ByVal bVk As Byte, ByVal bScan As Byte, ByVal dwFlags As Long, ByVal dwExtraInfo As Long)
  
      Public Const VK_SNAPSHOT = &H2C
   
   Type RECT_Type
      Left As Long
      Top As Long
      Right As Long
      Bottom As Long
   End Type

   Declare PtrSafe Function GetActiveWindow Lib "user32" () As Long
   Declare PtrSafe Function GetDesktopWindow Lib "user32" () As Long
   Declare PtrSafe Sub GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT_Type)

   Declare PtrSafe Function GetDC Lib "user32" (ByVal hwnd As Long) As Long
   Declare PtrSafe Function CreateCompatibleDC Lib "gdi32" (ByVal hdc As Long) As Long
   Declare PtrSafe Function CreateCompatibleBitmap Lib "gdi32" (ByVal hdc _
                                       As Long, ByVal nWidth As Long, _
                                       ByVal nHeight As Long) As Long
   Declare PtrSafe Function SelectObject Lib "gdi32" (ByVal hdc As Long, _
                                       ByVal hObject As Long) As Long

   Declare PtrSafe Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, _
                                       ByVal x As Long, ByVal y _
                                       As Long, ByVal nWidth As Long, _
                                       ByVal nHeight As Long, _
                                       ByVal hSrcDC As Long, _
                                       ByVal xSrc As Long, _
                                       ByVal ySrc As Long, _
                                       ByVal dwRop As Long) As Long

   Declare PtrSafe Function ReleaseDC Lib "user32" (ByVal hwnd As Long, ByVal hdc As Long) As Long
   Declare PtrSafe Function DeleteDC Lib "gdi32" (ByVal hdc As Long) As Long

   Public Const GHND = &H42
   Public Const CF_TEXT = 1
   Public Const MAXSIZE = 4096

   Global Const SRCCOPY = &HCC0020
   Global Const CF_BITMAP = 2



'MS KB Artikel Q138910
      
    Function ClipBoard_GetData()
         
         Dim hClipMemory As Long
         Dim lpClipMemory As Long
         Dim MyString As String
         Dim Retval As Long

         If OpenClipboard(0&) = 0 Then
            MsgBox "Cannot open Clipboard. Another app. may have it open"

            Exit Function
         End If

         ' Obtain the handle to the global memory
         ' block that is referencing the text.
         hClipMemory = GetClipboardData(CF_TEXT)
         If IsNull(hClipMemory) Then
            MsgBox "Could not allocate memory"
            GoTo OutOfHere
         End If

         ' Lock Clipboard memory so we can reference
         ' the actual data string.
         lpClipMemory = GlobalLock(hClipMemory)

         If Not IsNull(lpClipMemory) Then

            MyString = Space$(MAXSIZE)
            Retval = lstrcpy(MyString, lpClipMemory)
            Retval = GlobalUnlock(hClipMemory)

            ' Peel off the null terminating character.
            MyString = Mid(MyString, 1, InStr(1, MyString, Chr$(0), 0) - 1)
         Else
            MsgBox "Could not lock memory to copy string from."
         End If

OutOfHere:

         Retval = CloseClipboard()
         ClipBoard_GetData = MyString

      End Function
      
'MS KB Artikel Q138909

    Function ClipBoard_SetData(MyString As String)
            
         Dim hGlobalMemory As Long, lpGlobalMemory As Long

         Dim hClipMemory As Long, x As Long

         ' Allocate moveable global memory.
         '-------------------------------------------
         hGlobalMemory = GlobalAlloc(GHND, Len(MyString) + 1)

         ' Lock the block to get a far pointer
         ' to this memory.
         lpGlobalMemory = GlobalLock(hGlobalMemory)

         ' Copy the string to this global memory.
         lpGlobalMemory = lstrcpy(lpGlobalMemory, MyString)

         ' Unlock the memory.

         If GlobalUnlock(hGlobalMemory) <> 0 Then
            MsgBox "Could not unlock memory location. Copy aborted."
            GoTo OutOfHere2
         End If

         ' Open the Clipboard to copy data to.
         If OpenClipboard(0&) = 0 Then
            MsgBox "Could not open the Clipboard. Copy aborted."
            Exit Function
         End If

         ' Clear the Clipboard.
         x = EmptyClipboard()

         ' Copy the data to the Clipboard.

         hClipMemory = SetClipboardData(CF_TEXT, hGlobalMemory)

OutOfHere2:

         If CloseClipboard() = 0 Then
            MsgBox "Could not close Clipboard."
         End If

         End Function


'MS KB Artikel Q148392

   Function ScreenDump()
      Dim AccessHwnd As Long, DeskHwnd As Long
      Dim hdc As Long
      Dim hdcMem As Long
      Dim RECT As RECT_Type
      Dim Junk As Long
      Dim fwidth As Long, fheight As Long
      Dim hBitmap As Long
 
      DoCmd.Hourglass True
 
      '---------------------------------------------------
      ' Get window handle to Windows and Microsoft Access
      '---------------------------------------------------
      DeskHwnd = GetDesktopWindow()
      AccessHwnd = GetActiveWindow()
 
      '---------------------------------------------------
      ' Get screen coordinates of Microsoft Access
      '---------------------------------------------------
      Call GetWindowRect(AccessHwnd, RECT)
      fwidth = RECT.Right - RECT.Left
      fheight = RECT.Bottom - RECT.Top
 
      '---------------------------------------------------
      ' Get the device context of Desktop and allocate memory
      '---------------------------------------------------
      hdc = GetDC(DeskHwnd)
      hdcMem = CreateCompatibleDC(hdc)
      hBitmap = CreateCompatibleBitmap(hdc, fwidth, fheight)
 
      If hBitmap <> 0 Then
         Junk = SelectObject(hdcMem, hBitmap)
 
         '---------------------------------------------
         ' Copy the Desktop bitmap to memory location
         ' based on Microsoft Access coordinates.
         '---------------------------------------------
         Junk = BitBlt(hdcMem, 0, 0, fwidth, fheight, hdc, RECT.Left, _
                       RECT.Top, SRCCOPY)
 
         '---------------------------------------------
         ' Set up the Clipboard and copy bitmap
         '---------------------------------------------
         Junk = OpenClipboard(DeskHwnd)
         Junk = EmptyClipboard()
         Junk = SetClipboardData(CF_BITMAP, hBitmap)
         Junk = CloseClipboard()
      End If
 
      '---------------------------------------------
      ' Clean up handles
      '---------------------------------------------
      Junk = DeleteDC(hdcMem)
      Junk = ReleaseDC(DeskHwnd, hdc)
 
      DoCmd.Hourglass False
 
   End Function

Function PrtScn(Alles As Boolean)

' Alles = True Gesamter Bildschirm
' Alles = False - Aktives Fenster

'Tip aus www.basicworld.com
  ' 32 Bit
'Die Prozedur keybd_event schafft lässig, was SendKeys nicht kann - beachten Sie
'bitte, daß das SDK die Verwendung für diese Zwecke fälschlicherweise genau
'vertauscht dokumentiert: Übergeben Sie ihr im Parameter bVk den virtuellen
'Tastencode VB_SNAPSHOT für die "PrintScreen"-Taste, so erhalten Sie eine Kopie
'des aktiven Fensters in der Zwischenablage:

If Not Alles Then
    keybd_event VK_SNAPSHOT, 0, 0, 0
'Wünschen Sie, den gesamten Desktop zu kopieren, so setzen Sie den Parameter
'bScan einfach auf 1:
Else
    keybd_event VK_SNAPSHOT, 1, 0, 0
End If

End Function

'***** Code start  ********
'code courtesy of
'Terry Kreft
'
Function ClipBoard_Clear()
  Call OpenClipboard(0&)
  Call EmptyClipboard
  Call CloseClipboard
End Function
'***** Code End ********