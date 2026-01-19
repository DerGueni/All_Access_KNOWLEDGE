Option Compare Database
Option Explicit

' Herkunft
' http://www.office-loesung.de/ftopic208796_0_0_asc.php&sid=f0e83b0b6fc6a2742977dd60d417c244

Private Declare PtrSafe Sub Sleep Lib "kernel32.dll" ( _
    ByVal dwMilliseconds As Long)
Private Declare PtrSafe Function OleCreatePictureIndirect Lib "olepro32.dll" ( _
    ByRef PicDesc As PicBmp, _
    ByRef RefIID As guid, _
    ByVal fPictureOwnsHandle As Long, _
    ByRef IPic As IPicture) As Long
Private Declare PtrSafe Function CreateCompatibleDC Lib "gdi32.dll" ( _
    ByVal hdc As Long) As Long
Private Declare PtrSafe Function CreateCompatibleBitmap Lib "gdi32.dll" ( _
    ByVal hdc As Long, _
    ByVal nWidth As Long, _
    ByVal nHeight As Long) As Long
Private Declare PtrSafe Function SelectObject Lib "gdi32.dll" ( _
    ByVal hdc As Long, _
    ByVal hObject As Long) As Long
Private Declare PtrSafe Function GetDeviceCaps Lib "gdi32.dll" ( _
    ByVal hdc As Long, _
    ByVal iCapabilitiy As Long) As Long
Private Declare PtrSafe Function GetSystemPaletteEntries Lib "gdi32.dll" ( _
    ByVal hdc As Long, _
    ByVal wStartIndex As Long, _
    ByVal wNumEntries As Long, _
    ByRef lpPaletteEntries As PALETTEENTRY) As Long
Private Declare PtrSafe Function CreatePalette Lib "gdi32.dll" ( _
    ByRef lpLogPalette As LOGPALETTE) As Long
Private Declare PtrSafe Function SelectPalette Lib "gdi32.dll" ( _
    ByVal hdc As Long, _
    ByVal hPalette As Long, _
    ByVal bForceBackground As Long) As Long
Private Declare PtrSafe Function RealizePalette Lib "gdi32.dll" ( _
    ByVal hdc As Long) As Long
Private Declare PtrSafe Function BitBlt Lib "gdi32.dll" ( _
    ByVal hDestDC As Long, _
    ByVal x As Long, _
    ByVal y As Long, _
    ByVal nWidth As Long, _
    ByVal nHeight As Long, _
    ByVal hSrcDC As Long, _
    ByVal xSrc As Long, _
    ByVal ySrc As Long, _
    ByVal dwRop As Long) As Long
Private Declare PtrSafe Function DeleteDC Lib "gdi32.dll" ( _
    ByVal hdc As Long) As Long
Private Declare PtrSafe Function GetDC Lib "user32.dll" ( _
    ByVal hwnd As Long) As Long
Private Declare PtrSafe Function GetWindowRect Lib "user32.dll" ( _
    ByVal hwnd As Long, _
    ByRef lpRect As RECT) As Long
Private Declare PtrSafe Function GetSystemMetrics Lib "user32.dll" ( _
    ByVal nIndex As Long) As Long
Private Declare PtrSafe Function GetForegroundWindow Lib "user32.dll" () As Long

Private Declare PtrSafe Function apiGetFocus Lib "user32" Alias "GetFocus" () As Long

Private Const SM_CXSCREEN = 0&
Private Const SM_CYSCREEN = 1&
Private Const RC_PALETTE As Long = &H100
Private Const SIZEPALETTE As Long = 104
Private Const RASTERCAPS As Long = 38

Private Type RECT
    Left As Long
    Top As Long
    Right As Long
    Bottom As Long
End Type

Private Type PALETTEENTRY
    peRed As Byte
    peGreen As Byte
    peBlue As Byte
    peFlags As Byte
End Type

Private Type LOGPALETTE
    palVersion As Integer
    palNumEntries As Integer
    palPalEntry(255) As PALETTEENTRY
End Type

Private Type guid
    Data1 As Long
    Data2 As Integer
    Data3 As Integer
    Data4(7) As Byte
End Type

Private Type PicBmp
    Size As Long
    Type As Long
    hBmp As Long
    hPal As Long
    Reserved As Long
End Type

Public Sub prcSave_Picture_Screen(strPath As String) 'ganzer bildschirm
    stdole.SavePicture hDCToPicture(GetDC(0&), 0&, 0&, _
        GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN)), _
        strPath 'anpassen !!!
End Sub

Public Sub prcSave_Picture_Active_Window(strPath As String) 'aktives Fenster
    Dim hwnd As Long
    Dim udtRect As RECT
    Sleep 3000 '3 sekunden pause um ein anderes Fenster zu aktivieren
    hwnd = GetForegroundWindow
    GetWindowRect hwnd, udtRect
    stdole.SavePicture hDCToPicture(GetDC(0&), udtRect.Left, udtRect.Top, _
        udtRect.Right - udtRect.Left, udtRect.Bottom - udtRect.Top), _
        strPath 'anpassen !!!
End Sub

'Kobd
Public Sub prcSave_Picture_Active_Window_part(strPath As String, hwnd As Long) 'aktives Fenster'
'    Dim Hwnd As Long
    Dim udtRect As RECT
    Const itwips As Long = 567
    Sleep 100
'    Hwnd = GetForegroundWindow
    GetWindowRect hwnd, udtRect
    stdole.SavePicture hDCToPicture(GetDC(0&), udtRect.Left, udtRect.Top, _
        (udtRect.Right - udtRect.Left), (udtRect.Bottom - udtRect.Top)), _
        strPath 'anpassen !!!
End Sub


'Kobd
'Selbstdefinierter Ausschnitt eines Screens
Public Sub prcSave_Picture_Active_Window_part_cm(strPath As String, hwnd As Long, Optional Linkscm As Double = 0#, Optional Obencm As Double = 0#, Optional Breitecm As Double = 0#, Optional Hoehecm As Double = 0#)   'aktives Fenster'
Dim XYWert(3) As Long
'cmToPixelsX
'cmToPixelsY
'    Dim Hwnd As Long
    Dim udtRect As RECT
    Const itwips As Long = 567
    Sleep 100
'    Hwnd = GetForegroundWindow
    GetWindowRect hwnd, udtRect
    
If Linkscm <> 0 Then
    XYWert(0) = cmToPixelsX(Linkscm)
Else
    XYWert(0) = udtRect.Left
End If
If Obencm <> 0 Then
    XYWert(1) = cmToPixelsY(Obencm)
Else
    XYWert(1) = udtRect.Top
End If
If Breitecm <> 0 Then
    XYWert(2) = cmToPixelsX(Breitecm)
Else
    XYWert(2) = (udtRect.Right - udtRect.Left)
End If
If Hoehecm <> 0 Then
    XYWert(3) = cmToPixelsY(Hoehecm)
Else
    XYWert(3) = (udtRect.Bottom - udtRect.Top)
End If
    stdole.SavePicture hDCToPicture(GetDC(0&), XYWert(0), XYWert(1), _
        XYWert(2), XYWert(3)), _
        strPath 'anpassen !!!
End Sub


Private Function CreateBitmapPicture(ByVal hBmp As Long, ByVal hPal As Long) As Object
    Dim Pic As PicBmp, IPic As IPicture, IID_IDispatch As guid
    With IID_IDispatch
        .Data1 = &H20400
        .Data4(0) = &HC0
        .Data4(7) = &H46
    End With
    With Pic
        .Size = Len(Pic)
        .Type = 1
        .hBmp = hBmp
        .hPal = hPal
    End With
    Call OleCreatePictureIndirect(Pic, IID_IDispatch, 1, IPic)
    Set CreateBitmapPicture = IPic
End Function

Private Function hDCToPicture(ByVal hDCSrc As Long, ByVal LeftSrc As Long, _
    ByVal TopSrc As Long, ByVal WidthSrc As Long, ByVal HeightSrc As Long) As Object
    Dim hDCMemory As Long, hBmp As Long, hBmpPrev As Long
    Dim hPal As Long, hPalPrev As Long, RasterCapsScrn As Long, HasPaletteScrn As Long
    Dim PaletteSizeScrn As Long, LogPal As LOGPALETTE
    hDCMemory = CreateCompatibleDC(hDCSrc)
    hBmp = CreateCompatibleBitmap(hDCSrc, WidthSrc, HeightSrc)
    hBmpPrev = SelectObject(hDCMemory, hBmp)
    RasterCapsScrn = GetDeviceCaps(hDCSrc, RASTERCAPS)
    HasPaletteScrn = RasterCapsScrn And RC_PALETTE
    PaletteSizeScrn = GetDeviceCaps(hDCSrc, SIZEPALETTE)
    If HasPaletteScrn And (PaletteSizeScrn = 256) Then
        LogPal.palVersion = &H300
        LogPal.palNumEntries = 256
        Call GetSystemPaletteEntries(hDCSrc, 0, 256, LogPal.palPalEntry(0))
        hPal = CreatePalette(LogPal)
        hPalPrev = SelectPalette(hDCMemory, hPal, 0)
        Call RealizePalette(hDCMemory)
    End If
    Call BitBlt(hDCMemory, 0, 0, WidthSrc, HeightSrc, hDCSrc, LeftSrc, TopSrc, 13369376)
    hBmp = SelectObject(hDCMemory, hBmpPrev)
    If HasPaletteScrn And (PaletteSizeScrn = 256) Then
        hPal = SelectPalette(hDCMemory, hPalPrev, 0)
    End If
    Call DeleteDC(hDCMemory)
    Set hDCToPicture = CreateBitmapPicture(hBmp, hPal)
End Function


'Private Declare PtrSafe Function apiGetFocus Lib "user32" Alias "GetFocus" () As Long

         
Function fhWnd(ctl As control) As Long
    On Error Resume Next
    ctl.SetFocus
    If err Then
        fhWnd = 0
    Else
        fhWnd = apiGetFocus
    End If
    On Error GoTo 0
End Function



'''''Sample -Aufruf
'Dim strPath As String
'strPath = "D:\testxx.bmp"
'Call prcSave_Picture_Active_Window_part_cm(strPath, Me.hwnd, 21, 7, 10, 8) 'aktive hwnd'


'''''#######################################

' Anzeige in Pixel !!
' 1 cm = 567 twips

'Pixel X

'Twips in Pixel X
Function TwipsToPixelsX(Twips As Long) As Long
   TwipsToPixelsX = Twips / TwipsPerPixelX
End Function

'Pixel in Twips X
Function PixelsToTwipsX(Pixels As Long) As Long
   PixelsToTwipsX = Pixels * TwipsPerPixelX
End Function

'cm in Pixel X
Function cmToPixelsX(cm As Double) As Long
Const cm2Twips As Long = 567
Dim zwTwips As Long
zwTwips = CLng(cm * cm2Twips)
cmToPixelsX = TwipsToPixelsX(zwTwips)
End Function

'Pixel in cm X
Function PixelsTocmX(Pixels As Long) As Double
Const cm2Twips As Long = 567
   PixelsTocmX = (Pixels * TwipsPerPixelX) / cm2Twips
End Function


'Pixel Y

'Twips in Pixel Y
Function TwipsToPixelsY(Twips As Long) As Long
   TwipsToPixelsY = Twips / TwipsPerPixelY
End Function

'Pixel in Twips Y
Function PixelsToTwipsY(Pixels As Long) As Long
   PixelsToTwipsY = Pixels * TwipsPerPixelY
End Function

'Pixel in cm Y
Function PixelsTocmY(Pixels As Long) As Double
Const cm2Twips As Long = 567
   PixelsTocmY = (Pixels * TwipsPerPixelY) / cm2Twips
End Function


'cm in Pixel Y
Function cmToPixelsY(cm As Double) As Long
Const cm2Twips As Long = 567
Dim zwTwips As Long
zwTwips = CLng(cm * cm2Twips)
cmToPixelsY = TwipsToPixelsY(zwTwips)
End Function