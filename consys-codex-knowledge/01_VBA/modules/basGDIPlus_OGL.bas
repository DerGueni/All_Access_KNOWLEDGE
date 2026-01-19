Attribute VB_Name = "basGDIPlus_OGL"
Option Compare Database
Option Explicit

'-------------------------------------------------
'    Picture functions using GDIPlus-API (GDIP)   |
'-------------------------------------------------
'    *  Office 2003/2007/2010 version  *          |
'-------------------------------------------------
'   (c) mossSOFT / Sascha Trowitzsch rev. 08/2010 |
'-------------------------------------------------

'- Reference to library "OLE Automation" (stdole) needed!

Public Const GUID_IPicture = "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"    'IPicture

'User-defined types: ----------------------------------------------------------------------

Public Enum PicFileType
    pictypeBMP = 1
    pictypeGIF = 2
    pictypePNG = 3
    pictypeJPG = 4
End Enum

Private Enum GpUnit
   UnitWorld = 0        ' World coordinate (non-physical unit)
   UnitDisplay = 1      ' Variable -- for PageTransform only
   UnitPixel = 2        ' Each unit is one device pixel.
   UnitPoint = 3        ' Each unit is a printer's point, or 1/72 inch.
   UnitInch = 4         ' Each unit is 1 inch.
   UnitDocument = 5     ' Each unit is 1/300 inch.
   UnitMillimeter = 6   ' Each unit is 1 millimeter.
End Enum

Private Enum PixelFormat
    PixelFormat1bppIndexed = &H30101
    PixelFormat4bppIndexed = &H30402
    pixelFormat8bppIndexed = &H30803
    PixelFormat16bppGreyScale = &H101004
    PixelFormat16bppRGB555 = &H21005
    PixelFormat16bppRGB565 = &H21006
    PixelFormat16bppARGB1555 = &H61007
    PixelFormat24bppRGB = &H21808
    PixelFormat32bppRGB = &H22009
    PixelFormat32bppARGB = &H26200A
    PixelFormat32bppPARGB = &HE200B
    PixelFormat48bppRGB = &H10300C
    PixelFormat64bppARGB = &H34400D
    PixelFormat64bppPARGB = &H1C400E
    PixelFormatMax = 15 '&HF
End Enum

Private Enum ImageLockMode
   ImageLockModeRead = &H1
   ImageLockModewrite = &H2
   ImageLockModeUserInputBuf = &H4
End Enum

Private Type guid
    Data1 As Long
    Data2 As Integer
    Data3 As Integer
    Data4(7) As Byte
End Type

Public Type TSize
    x As Double
    y As Double
End Type

Private Type RECT
    Bottom As Long
    Left As Long
    Right As Long
    Top As Long
End Type

Private Type RECTL
    Bottom As Long
    Left As Long
    Right As Long
    Top As Long
End Type

Private Type PICTDESC
    cbSizeOfStruct As Long
    PicType As Long
    hImage As Long
    XExt As Long
    yExt As Long
End Type

Private Type GDIPStartupInput
    GdiplusVersion As Long
    DebugEventCallback As Long
    SuppressBackgroundThread As Long
    SuppressExternalCodecs As Long
End Type

Private Type EncoderParameter
    UUID As guid
    NumberOfValues As Long
    Type As Long
    Value As LongPtr
End Type

Private Type EncoderParameters
    Count As Long
    Parameter As EncoderParameter
End Type

Private Type BitmapData
   width As Long
   height As Long
   stride As Long
   PixelFormat As Long
   scan0 As LongPtr
   Reserved As Long
End Type

'Common API-Declarations: ----------------------------------------------------------------------------

'Convert a windows bitmap to OLE-Picture :
Private Declare PtrSafe Function OleCreatePictureIndirect Lib "oleaut32.dll" (lpPictDesc As PICTDESC, riid As guid, ByVal fPictureOwnsHandle As Long, IPic As Object) As Long
'Retrieve GUID-Type from string :
Private Declare PtrSafe Function CLSIDFromString Lib "ole32" (ByVal lpsz As Any, pclsid As guid) As Long

'Memory functions:
Private Declare PtrSafe Function GlobalAlloc Lib "kernel32" (ByVal uFlags As Long, ByVal dwBytes As Long) As Long
Private Declare PtrSafe Function GlobalSize Lib "kernel32.dll" (ByVal hMem As Long) As Long
Private Declare PtrSafe Function GlobalLock Lib "kernel32.dll" (ByVal hMem As Long) As Long
Private Declare PtrSafe Function GlobalUnlock Lib "kernel32.dll" (ByVal hMem As Long) As Long
Private Declare PtrSafe Function GlobalFree Lib "kernel32" (ByVal hMem As Long) As Long
Private Declare PtrSafe Sub CopyMemory Lib "kernel32.dll" Alias "RtlMoveMemory" (ByRef Destination As Any, ByRef Source As Any, ByVal Length As Long)
Private Declare PtrSafe Sub MoveMemory Lib "kernel32" Alias "RtlMoveMemory" (ByVal Destination As Long, ByRef Source As Byte, ByVal Length As Long)

'Modules API:
Private Declare PtrSafe Function FreeLibrary Lib "kernel32.dll" (ByVal hLibModule As Long) As Long
Private Declare PtrSafe Function LoadLibrary Lib "kernel32.dll" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As Long
Private Declare PtrSafe Function GetModuleHandle Lib "kernel32.dll" Alias "GetModuleHandleA" (ByVal lpModuleName As String) As Long
Private Declare PtrSafe Function GetProcAddress Lib "kernel32.dll" (ByVal hModule As Long, ByVal lpProcName As String) As Long

'Timer API:
Private Declare PtrSafe Function SetTimer Lib "user32" (ByVal hwnd As Long, ByVal nIDEvent As Long, ByVal uElapse As Long, ByVal lpTimerFunc As LongPtr) As Long
Private Declare PtrSafe Function KillTimer Lib "user32" (ByVal hwnd As Long, ByVal nIDEvent As Long) As Long


'OLE-Stream functions :
Private Declare PtrSafe Function CreateStreamOnHGlobal Lib "ole32" (ByVal hGlobal As LongPtr, ByVal fDeleteOnRelease As Long, ByRef ppstm As Any) As Long
Private Declare PtrSafe Function GetHGlobalFromStream Lib "ole32.dll" (ByVal pstm As Any, ByRef phglobal As Long) As Long

'GDIPlus Flat-API declarations ----------------------------------------------------------------------------

'*Remark:
'          We use a special gdi+ version here that comes with Office 2007/2010! (program files\common files\microsoft shared\office1x\ogl.dll)
'          Benefit: No need to load a separate dll because ogl.dll is normally already loaded by Office 2007/2010.
'          ogl.dll is identical to the gdiplus.dll (V1.1) used in Vista
'Remark 2: This DLL is only installed by Office Setup (and also Access Runtime) if OS = WinXP.
'          On Vista or Win7 Office 2010 uses the built-in GDIPLUS.DLL !


'OGL.DLL library declarations:

'Initialization OGL:
Private Declare PtrSafe Function GdiplusStartup_O Lib "ogl" Alias "GdiplusStartup" (token As Long, inputbuf As GDIPStartupInput, Optional ByVal outputbuf As Long = 0) As Long
'Tear down GDIP:
Private Declare PtrSafe Function GdiplusShutdown_O Lib "ogl" Alias "GdiplusShutdown" (ByVal token As Long) As Long
'Load GDIP-Image from file :
Private Declare PtrSafe Function GdipCreateBitmapFromFile_O Lib "ogl" Alias "GdipCreateBitmapFromFile" (ByVal fileName As LongPtr, BITMAP As Long) As Long
'Create GDIP- graphical area from Windows-DeviceContext:
Private Declare PtrSafe Function GdipCreateFromHDC_O Lib "ogl" Alias "GdipCreateFromHDC" (ByVal hdc As Long, GpGraphics As Long) As Long
'Delete GDIP graphical area :
Private Declare PtrSafe Function GdipDeleteGraphics_O Lib "ogl" Alias "GdipDeleteGraphics" (ByVal graphics As Long) As Long
'Copy GDIP-Image to graphical area:
Private Declare PtrSafe Function GdipDrawImageRect_O Lib "ogl" Alias "GdipDrawImageRect" (ByVal graphics As Long, ByVal image As Long, ByVal x As Single, ByVal y As Single, ByVal width As Single, ByVal height As Single) As Long
'Clear allocated bitmap memory from GDIP :
Private Declare PtrSafe Function GdipDisposeImage_O Lib "ogl" Alias "GdipDisposeImage" (ByVal image As Long) As Long
'Retrieve windows bitmap handle from GDIP-Image:
Private Declare PtrSafe Function GdipCreateHBITMAPFromBitmap_O Lib "ogl" Alias "GdipCreateHBITMAPFromBitmap" (ByVal BITMAP As Long, hbmReturn As Long, ByVal background As Long) As Long
'Retrieve Windows-Icon-Handle from GDIP-Image:
Public Declare PtrSafe Function GdipCreateHICONFromBitmap_O Lib "ogl" Alias "GdipCreateHICONFromBitmap" (ByVal BITMAP As Long, hbmReturn As Long) As Long
'Scaling GDIP-Image size:
Private Declare PtrSafe Function GdipGetImageThumbnail_O Lib "ogl" Alias "GdipGetImageThumbnail" (ByVal image As Long, ByVal thumbWidth As Long, ByVal thumbHeight As Long, thumbImage As Long, Optional ByVal callback As Long = 0, Optional ByVal callbackData As Long = 0) As Long
'Retrieve GDIP-Image from Windows-Bitmap-Handle:
Private Declare PtrSafe Function GdipCreateBitmapFromHBITMAP_O Lib "ogl" Alias "GdipCreateBitmapFromHBITMAP" (ByVal hbm As Long, ByVal hPal As Long, BITMAP As Long) As Long
'Retrieve GDIP-Image from Windows-Icon-Handle:
Private Declare PtrSafe Function GdipCreateBitmapFromHICON_O Lib "ogl" Alias "GdipCreateBitmapFromHICON" (ByVal hicon As Long, BITMAP As Long) As Long
'Retrieve width of a GDIP-Image (Pixel):
Private Declare PtrSafe Function GdipGetImageWidth_O Lib "ogl" Alias "GdipGetImageWidth" (ByVal image As Long, width As Long) As Long
'Retrieve height of a GDIP-Image (Pixel):
Private Declare PtrSafe Function GdipGetImageHeight_O Lib "ogl" Alias "GdipGetImageHeight" (ByVal image As Long, height As Long) As Long
'Save GDIP-Image to file in seletable format:
Private Declare PtrSafe Function GdipSaveImageToFile_O Lib "ogl" Alias "GdipSaveImageToFile" (ByVal image As Long, ByVal fileName As LongPtr, clsidEncoder As guid, encoderParams As Any) As Long
'Save GDIP-Image in OLE-Stream with seletable format:
Private Declare PtrSafe Function GdipSaveImageToStream_O Lib "ogl" Alias "GdipSaveImageToStream" (ByVal image As Long, ByVal stream As IUnknown, clsidEncoder As guid, encoderParams As Any) As Long
'Retrieve GDIP-Image from OLE-Stream-Object:
Private Declare PtrSafe Function GdipLoadImageFromStream_O Lib "ogl" Alias "GdipLoadImageFromStream" (ByVal stream As IUnknown, image As Long) As Long
'Create a gdip image from scratch
Private Declare PtrSafe Function GdipCreateBitmapFromScan0_O Lib "ogl" Alias "GdipCreateBitmapFromScan0" (ByVal width As Long, ByVal height As Long, ByVal stride As Long, ByVal PixelFormat As Long, scan0 As Any, BITMAP As Long) As Long
'Get the DC of an gdip image
Private Declare PtrSafe Function GdipGetImageGraphicsContext_O Lib "ogl" Alias "GdipGetImageGraphicsContext" (ByVal image As Long, graphics As Long) As Long
'Blit the contents of an gdip image to another image DC using positioning
Private Declare PtrSafe Function GdipDrawImageRectRectI_O Lib "ogl" Alias "GdipDrawImageRectRectI" (ByVal graphics As Long, ByVal image As Long, ByVal dstx As Long, ByVal dsty As Long, ByVal dstwidth As Long, ByVal dstheight As Long, ByVal srcx As Long, ByVal srcy As Long, ByVal srcwidth As Long, ByVal srcheight As Long, ByVal srcUnit As Long, Optional ByVal imageAttributes As Long = 0, Optional ByVal callback As Long = 0, Optional ByVal callbackData As Long = 0) As Long
'Duplicates a gdiplus image object
Private Declare PtrSafe Function GdipCloneImage_O Lib "ogl" Alias "GdipCloneImage" (ByVal image As Long, cloneImage As Long) As Long
'Clear device context and set background color
Private Declare PtrSafe Function GdipGraphicsClear_O Lib "ogl" Alias "GdipGraphicsClear" (ByVal graphics As Long, ByVal lColor As Long) As Long
'Suspend image to work with its data (pixels)
Private Declare PtrSafe Function GdipBitmapLockBits_O Lib "ogl" Alias "GdipBitmapLockBits" (ByVal BITMAP As Long, RECT As RECTL, ByVal Flags As ImageLockMode, ByVal PixelFormat As Long, lockedBitmapData As BitmapData) As Long
'Continue to use altered image in GDIP
Private Declare PtrSafe Function GdipBitmapUnlockBits_O Lib "ogl" Alias "GdipBitmapUnlockBits" (ByVal BITMAP As Long, lockedBitmapData As BitmapData) As Long


'Same for simple GDIPLUS.DLL:
Private Declare PtrSafe Function GdiplusStartup Lib "gdiplus" (token As Long, inputbuf As GDIPStartupInput, Optional ByVal outputbuf As Long = 0) As Long
Private Declare PtrSafe Function GdiplusShutdown Lib "gdiplus" (ByVal token As Long) As Long
Private Declare PtrSafe Function GdipCreateBitmapFromFile Lib "gdiplus" (ByVal fileName As LongPtr, BITMAP As Long) As Long
Private Declare PtrSafe Function GdipCreateFromHDC Lib "gdiplus" (ByVal hdc As Long, GpGraphics As Long) As Long
Private Declare PtrSafe Function GdipDeleteGraphics Lib "gdiplus" (ByVal graphics As Long) As Long
Private Declare PtrSafe Function GdipDrawImageRect Lib "gdiplus" (ByVal graphics As Long, ByVal image As Long, ByVal x As Single, ByVal y As Single, ByVal width As Single, ByVal height As Single) As Long
Private Declare PtrSafe Function GdipDisposeImage Lib "gdiplus" (ByVal image As Long) As Long
Private Declare PtrSafe Function GdipCreateHBITMAPFromBitmap Lib "gdiplus" (ByVal BITMAP As Long, hbmReturn As Long, ByVal background As Long) As Long
Private Declare PtrSafe Function GdipCreateHICONFromBitmap Lib "gdiplus" (ByVal BITMAP As Long, hbmReturn As Long) As Long
Private Declare PtrSafe Function GdipGetImageThumbnail Lib "gdiplus" (ByVal image As Long, ByVal thumbWidth As Long, ByVal thumbHeight As Long, thumbImage As Long, Optional ByVal callback As Long = 0, Optional ByVal callbackData As Long = 0) As Long
Private Declare PtrSafe Function GdipCreateBitmapFromHBITMAP Lib "gdiplus" (ByVal hbm As Long, ByVal hPal As Long, BITMAP As Long) As Long
Private Declare PtrSafe Function GdipCreateBitmapFromHICON Lib "gdiplus" (ByVal hicon As Long, BITMAP As Long) As Long
Private Declare PtrSafe Function GdipGetImageWidth Lib "gdiplus" (ByVal image As Long, width As Long) As Long
Private Declare PtrSafe Function GdipGetImageHeight Lib "gdiplus" (ByVal image As Long, height As Long) As Long
Private Declare PtrSafe Function GdipSaveImageToFile Lib "gdiplus" (ByVal image As Long, ByVal fileName As LongPtr, clsidEncoder As guid, encoderParams As Any) As Long
Private Declare PtrSafe Function GdipSaveImageToStream Lib "gdiplus" (ByVal image As Long, ByVal stream As IUnknown, clsidEncoder As guid, encoderParams As Any) As Long
Private Declare PtrSafe Function GdipLoadImageFromStream Lib "gdiplus" (ByVal stream As IUnknown, image As Long) As Long
Private Declare PtrSafe Function GdipCreateBitmapFromScan0 Lib "gdiplus" (ByVal width As Long, ByVal height As Long, ByVal stride As Long, ByVal PixelFormat As Long, scan0 As Any, BITMAP As Long) As Long
Private Declare PtrSafe Function GdipGetImageGraphicsContext Lib "gdiplus" (ByVal image As Long, graphics As Long) As Long
Private Declare PtrSafe Function GdipDrawImageRectRectI Lib "gdiplus" (ByVal graphics As Long, ByVal image As Long, ByVal dstx As Long, ByVal dsty As Long, ByVal dstwidth As Long, ByVal dstheight As Long, ByVal srcx As Long, ByVal srcy As Long, ByVal srcwidth As Long, ByVal srcheight As Long, ByVal srcUnit As Long, Optional ByVal imageAttributes As Long = 0, Optional ByVal callback As Long = 0, Optional ByVal callbackData As Long = 0) As Long
Private Declare PtrSafe Function GdipCloneImage Lib "gdiplus" (ByVal image As Long, cloneImage As Long) As Long
Private Declare PtrSafe Function GdipGraphicsClear Lib "gdiplus" (ByVal graphics As Long, ByVal lColor As Long) As Long
Private Declare PtrSafe Function GdipBitmapLockBits Lib "gdiplus" (ByVal BITMAP As Long, RECT As RECTL, ByVal Flags As ImageLockMode, ByVal PixelFormat As Long, lockedBitmapData As BitmapData) As Long
Private Declare PtrSafe Function GdipBitmapUnlockBits Lib "gdiplus" (ByVal BITMAP As Long, lockedBitmapData As BitmapData) As Long


'-----------------------------------------------------------------------------------------
'Global module variables:
Private lGDIP As Long           'GDIPLus object instance
Private bSharedLoad As Boolean  'Is gdiplus.dll or ogl.dll already loaded by Access? (In this case do not FreeLibrary module)
Private bUseOGL As Boolean      'If True use ogl.dll, otherwise gdiplus.dll
Private IsGDI11 As Boolean      'Is GDIPLUS version 1.1 or 1.0? (1.1 supports effects like Sharpen etc.)
Private lTimer As Long          'Timer Handle for AutoShutdown
'Be sure to have error handlers in all your VBA procedures since unhandled errors clear the above variables
'This may cause instableties or even crashes due to memory leaks in gdiplus!
'-----------------------------------------------------------------------------------------

Function GetGDIPVersion() As Boolean
    Dim hMod As Long
    Select Case Application.version
    
        Case "11.0", "15.0" 'A2003, A2013
            bUseOGL = False
            hMod = GetModuleHandle("gdiplus.dll")
            If hMod = 0 Then
                hMod = LoadLibrary("gdiplus.dll")
            Else
                bSharedLoad = True
            End If
            Dim lAddr As Long
            lAddr = GetProcAddress(hMod, "GdipCreateEffect")    'Check if effect section is supported by GDIPLUS module (=V 1.1)
            IsGDI11 = (lAddr <> 0)
            
        Case "12.0" 'A2007
            bUseOGL = True
            IsGDI11 = True
            hMod = GetModuleHandle("ogl.dll")
            If hMod = 0 Then
                hMod = LoadLibrary(Environ$("CommonProgramFiles") & "\Microsoft Shared\Office12\ogl.dll")
            Else
                bSharedLoad = True
            End If
            
        Case "14.0" 'A2010
            IsGDI11 = True
            'Office 2010 Setup only installs the OGL module, if OS <> Vista or Win7!
            'Check here for existance:
            hMod = GetModuleHandle("ogl.dll")   'Attempt Shared OGL
            If hMod <> 0 Then
                bUseOGL = True
                bSharedLoad = True
            Else
                hMod = GetModuleHandle("gdiplus.dll")   'Attempt Shared GDIPLUS
                If hMod <> 0 Then bSharedLoad = True
            End If
            If hMod = 0 Then    'Not Shared, so load the library...
                hMod = LoadLibrary(Environ$("CommonProgramFiles") & "\Microsoft Shared\Office14\ogl.dll")
                If hMod <> 0 Then
                    bUseOGL = True
                Else
                    hMod = LoadLibrary("gdiplus.dll")   'OGL does not exist, so load Vistas or Win7s gdiplus.dll (= always V 1.1)
                End If
            End If
    End Select
    GetGDIPVersion = (hMod <> 0)    'Valid only if we could receive any module handle
End Function

'Initialize GDI+
Function InitGDIP() As Boolean
    Dim TGDP As GDIPStartupInput
    Dim hMod As Long

    If lGDIP = 0 Then
        If GetGDIPVersion Then  'Distinguish between Office and OS versions
            TGDP.GdiplusVersion = 1
            If bUseOGL Then 'Get a personal instance of gdiplus:
                GdiplusStartup_O lGDIP, TGDP
            Else
                GdiplusStartup lGDIP, TGDP
            End If
            If lGDIP <> 0 Then AutoShutDown
        End If
    End If
    InitGDIP = (lGDIP > 0)
End Function

'Clear GDI+
Sub ShutDownGDIP()
    If lGDIP <> 0 Then
        If KillTimer(0&, lTimer) Then lTimer = 0
        If bUseOGL Then GdiplusShutdown_O lGDIP Else GdiplusShutdown lGDIP
        lGDIP = 0
        If Not bSharedLoad Then
            If bUseOGL Then FreeLibrary GetModuleHandle("ogl.dll") Else FreeLibrary GetModuleHandle("gdiplus.dll")
        End If
    End If
End Sub

'Scheduled ShutDown of GDI+ handle to avoid memory leaks
Private Sub AutoShutDown()
    'Set to 5 seconds for next shutdown
    'That's IMO appropriate for looped routines  - but configure for your own purposes
    If lGDIP <> 0 Then
        lTimer = SetTimer(0&, 0&, 5000, AddressOf TimerProc)
    End If
End Sub

'Callback for AutoShutDown
Private Sub TimerProc(ByVal hwnd As Long, ByVal uMsg As Long, ByVal idEvent As Long, ByVal dwTime As Long)
    Debug.Print "GDI+ AutoShutDown", idEvent
    If lTimer <> 0 Then
        If KillTimer(0&, lTimer) Then lTimer = 0
    End If
    ShutDownGDIP
End Sub

Function UsesOGL() As Boolean
    If Not InitGDIP Then Exit Function
    UsesOGL = bUseOGL
End Function

'Load image file with GDIP
'It's equivalent to the method LoadPicture() in OLE-Automation library (stdole2.tlb)
'Allowed format: bmp, gif, jp(e)g, tif, png, wmf, emf, ico
Function LoadPictureGDIP(sFilename As String) As StdPicture
    Dim hBmp As Long
    Dim hPic As Long

    If Not InitGDIP Then Exit Function
    If bUseOGL Then
        Set LoadPictureGDIP = LoadPictureGDIP_O(sFilename)
    Else
        If GdipCreateBitmapFromFile(StrPtr(sFilename), hPic) = 0 Then
            GdipCreateHBITMAPFromBitmap hPic, hBmp, 0&
            If hBmp <> 0 Then
                Set LoadPictureGDIP = BitmapToPicture(hBmp)
                GdipDisposeImage hPic
            End If
        End If
    End If

End Function

'Scale picture with GDIP
'A Picture object is commited, also the return value
'Width and Height of generatrix pictures in Width, Height
Function ResampleGDIP(ByVal image As StdPicture, ByVal width As Long, ByVal height As Long) As StdPicture
    Dim lRes As Long
    Dim lBitmap As Long

    If Not InitGDIP Then Exit Function

    If bUseOGL Then
        Set ResampleGDIP = ResampleGDIP_O(image, width, height)
    Else
        If image.Type = 1 Then
            lRes = GdipCreateBitmapFromHBITMAP(image.handle, 0, lBitmap)
        Else
            lRes = GdipCreateBitmapFromHICON(image.handle, lBitmap)
        End If
        If lRes = 0 Then
            Dim lThumb As Long
            Dim hBitmap As Long

            lRes = GdipGetImageThumbnail(lBitmap, width, height, lThumb, 0, 0)
            If lRes = 0 Then
                If image.Type = 3 Then  'Image-Type 3 is named : Icon!
                    'Convert with these GDI+ method :
                    lRes = GdipCreateHICONFromBitmap(lThumb, hBitmap)
                    Set ResampleGDIP = BitmapToPicture(hBitmap, True)
                Else
                    lRes = GdipCreateHBITMAPFromBitmap(lThumb, hBitmap, 0)
                    Set ResampleGDIP = BitmapToPicture(hBitmap)
                End If

                GdipDisposeImage lThumb
            End If
            GdipDisposeImage lBitmap
        End If
    End If

End Function

'Extract a part of an image
'x,y:   Left top corner of area to extract (pixel)
'Width, Height: Width and height of area to extract
'Return:    Image partly extracted
Function CropImage(ByVal image As StdPicture, _
                   x As Long, y As Long, _
                   width As Long, height As Long) As StdPicture
    Dim ret As Long
    Dim lBitmap As Long
    Dim lBitmap2 As Long
    Dim lGraph As Long
    Dim hBitmap As Long
    Dim sx As Long, sy As Long

    Const PixelFormat32bppARGB = &H26200A
    Const UnitPixel = 2

    If Not InitGDIP Then Exit Function

    If bUseOGL Then
        Set CropImage = CropImage_O(image, x, y, width, height)
    Else
        ret = GdipCreateBitmapFromHBITMAP(image.handle, 0, lBitmap)
        If ret = 0 Then
            ret = GdipGetImageWidth(lBitmap, sx)
            ret = GdipGetImageHeight(lBitmap, sy)
            If (x + width) > sx Then width = sx - x
            If (y + height) > sy Then height = sy - y
            ret = GdipCreateBitmapFromScan0(CLng(width), CLng(height), _
                                            0, PixelFormat32bppARGB, ByVal 0&, lBitmap2)
            ret = GdipGetImageGraphicsContext(lBitmap2, lGraph)
            ret = GdipDrawImageRectRectI(lGraph, lBitmap, 0&, 0&, _
                                         width, height, x, y, width, height, UnitPixel)
            ret = GdipCreateHBITMAPFromBitmap(lBitmap2, hBitmap, 0)
            Set CropImage = BitmapToPicture(hBitmap)

            GdipDisposeImage lBitmap
            GdipDisposeImage lBitmap2
            GdipDeleteGraphics lGraph
        End If
    End If

End Function

'Retrieve Width and Height of a pictures in Pixel with GDIP
'Return value as user/defined type TSize (X/Y als Long)
Function GetDimensionsGDIP(ByVal image As StdPicture) As TSize
    Dim lRes As Long
    Dim lBitmap As Long
    Dim x As Long, y As Long

    If Not InitGDIP Then Exit Function
    If image Is Nothing Then Exit Function
    If bUseOGL Then
        GetDimensionsGDIP = GetDimensionsGDIP_O(image)
    Else
        lRes = GdipCreateBitmapFromHBITMAP(image.handle, 0, lBitmap)
        If lRes = 0 Then
            GdipGetImageHeight lBitmap, y
            GdipGetImageWidth lBitmap, x
            GetDimensionsGDIP.x = CDbl(x)
            GetDimensionsGDIP.y = CDbl(y)
            GdipDisposeImage lBitmap
        End If
    End If

End Function

'Save a bitmap as file (with format conversion!)
'image = StdPicture object
'sFile = complete file path
'PicType = pictypeBMP, pictypeGIF, pictypePNG oder pictypeJPG
'Quality: 0...100; (works only with pictypeJPG!)
'Returns TRUE if successful
Function SavePicGDIPlus(ByVal image As StdPicture, sFile As String, _
                        PicType As PicFileType, Optional Quality As Long = 80) As Boolean
    Dim lBitmap As Long
    Dim TEncoder As guid
    Dim ret As Long
    Dim TParams As EncoderParameters
    Dim sType As String

    If Not InitGDIP Then Exit Function

    If bUseOGL Then
        SavePicGDIPlus = SavePicGDIPlus_O(image, sFile, pictypeBMP, Quality)
    Else
        If GdipCreateBitmapFromHBITMAP(image.handle, 0, lBitmap) = 0 Then
            Select Case PicType
            Case pictypeBMP: sType = "{557CF400-1A04-11D3-9A73-0000F81EF32E}"
            Case pictypeGIF: sType = "{557CF402-1A04-11D3-9A73-0000F81EF32E}"
            Case pictypePNG: sType = "{557CF406-1A04-11D3-9A73-0000F81EF32E}"
            Case pictypeJPG: sType = "{557CF401-1A04-11D3-9A73-0000F81EF32E}"
            End Select
            CLSIDFromString StrPtr(sType), TEncoder
            If PicType = pictypeJPG Then
                TParams.Count = 1
                With TParams.Parameter    ' Quality
                    CLSIDFromString StrPtr("{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"), .UUID
                    .NumberOfValues = 1
                    .Type = 4
                    .Value = VarPtr(CLng(Quality))
                End With
            Else
                'Different numbers of parameter between GDI+ 1.0 and GDI+ 1.1 on GIFs!!
                If (PicType = pictypeGIF) Then TParams.Count = 1 Else TParams.Count = 0
            End If
            'Save GDIP-Image to file :
            ret = GdipSaveImageToFile(lBitmap, StrPtr(sFile), TEncoder, TParams)
            GdipDisposeImage lBitmap
            DoEvents
            'Function returns True, if generated file actually exists:
            SavePicGDIPlus = (Dir(sFile) <> "")
        End If
    End If

End Function

'This procedure is similar to the above (see Parameter), the different is,
'that nothing is stored as a file, but a conversion is executed
'using a OLE-Stream-Object to an Byte-Array .
Function ArrayFromPicture(ByVal image As Object, PicType As PicFileType, Optional Quality As Long = 80) As Byte()
    Dim lBitmap As Long
    Dim TEncoder As guid
    Dim ret As Long
    Dim TParams As EncoderParameters
    Dim sType As String
    Dim IStm As IUnknown

    If Not InitGDIP Then Exit Function

    If bUseOGL Then
        ArrayFromPicture = ArrayFromPicture_O(image, pictypeBMP, Quality)
    Else
        If GdipCreateBitmapFromHBITMAP(image.handle, 0, lBitmap) = 0 Then
            Select Case PicType    'Choose GDIP-Format-Encoders CLSID:
            Case pictypeBMP: sType = "{557CF400-1A04-11D3-9A73-0000F81EF32E}"
            Case pictypeGIF: sType = "{557CF402-1A04-11D3-9A73-0000F81EF32E}"
            Case pictypePNG: sType = "{557CF406-1A04-11D3-9A73-0000F81EF32E}"
            Case pictypeJPG: sType = "{557CF401-1A04-11D3-9A73-0000F81EF32E}"
            End Select
            CLSIDFromString StrPtr(sType), TEncoder

            If PicType = pictypeJPG Then    'If JPG, then set additional parameter
                ' to apply quality level
                TParams.Count = 1
                With TParams.Parameter    ' Quality
                    CLSIDFromString StrPtr("{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"), .UUID
                    .NumberOfValues = 1
                    .Type = 4
                    .Value = VarPtr(CLng(Quality))
                End With
            Else
                'Different number of parameters between GDI+ 1.0 and GDI+ 1.1 on GIFs!!
                If (PicType = pictypeGIF) Then TParams.Count = 1 Else TParams.Count = 0
            End If

            ret = CreateStreamOnHGlobal(0&, 1, IStm)    'Create stream
            'Save GDIP-Image to stream :
            ret = GdipSaveImageToStream(lBitmap, IStm, TEncoder, TParams)
            If ret = 0 Then
                Dim hMem As Long, lSize As Long, lpMem As Long
                Dim abData() As Byte

                ret = GetHGlobalFromStream(IStm, hMem)    'Get memory handle from stream
                If ret = 0 Then
                    lSize = GlobalSize(hMem)
                    lpMem = GlobalLock(hMem)   'Get access to memory
                    ReDim abData(lSize - 1)    'Arrays dimension
                    'Commit memory stack from streams :
                    CopyMemory abData(0), ByVal lpMem, lSize
                    GlobalUnlock hMem   'Lock memory
                    ArrayFromPicture = abData   'Result
                End If

                Set IStm = Nothing  'Clean
            End If

            GdipDisposeImage lBitmap    'Clear GDIP-Image-Memory
        End If
    End If
End Function

'Create a picture object from an Access 2007 attachment
'strTable:              Table containing picture file attachments
'strAttachmentField:    Name of the attachment column in the table
'strImage:              Name of the image to search in the attachment records
'? AttachmentToPicture("ribbonimages","imageblob","cloudy.png").Width
Public Function AttachmentToPicture(strTable As String, strAttachmentField As String, strImage As String) As StdPicture
    Dim strSQL As String
    Dim bin() As Byte
    Dim nOffset As Long
    Dim nSize As Long

    strSQL = "SELECT " & strTable & "." & strAttachmentField & ".FileData AS data " & _
             "FROM " & strTable & _
             " WHERE " & strTable & "." & strAttachmentField & ".FileName='" & strImage & "'"
    On Error Resume Next
    bin = DBEngine(0)(0).OpenRecordset(strSQL, dbOpenSnapshot)(0)
    If Err.Number = 0 Then
        Dim bin2() As Byte
        nOffset = bin(0)    'First byte of Field2.FileData identifies offset to the file data block
        nSize = UBound(bin)
        ReDim bin2(nSize - nOffset)
        CopyMemory bin2(0), bin(nOffset), nSize - nOffset   'Copy file into new byte array starting at nOffset
        If bUseOGL Then
            Set AttachmentToPicture = ArrayToPicture_O(bin2)
        Else
            Set AttachmentToPicture = ArrayToPicture(bin2)
        End If
        Erase bin2
        Erase bin
    End If
End Function

Public Function PicFromField(ByVal picField As DAO.field, Optional FlattenColor As Variant = &HFFFFFFFF) As StdPicture
    Dim arrBin() As Byte
    Dim lSize As Long

    On Error GoTo Fehler

    lSize = picField.FieldSize
    If lSize > 0 Then
        arrBin() = picField.GetChunk(0, lSize)
        Set PicFromField = ArrayToPicture(arrBin, FlattenColor)
    End If

Ende:
    Erase arrBin
    Exit Function

Fehler:
    MsgBox Err.description, vbCritical
    Resume Ende
End Function

'Create an OLE-Picture from Byte-Array PicBin()
Public Function ArrayToPicture(ByRef PicBin() As Byte, Optional FlattenColor As Variant) As StdPicture
    Dim IStm As IUnknown
    Dim lBitmap As Long
    Dim hBmp As Long
    Dim ret As Long

    If Not InitGDIP Then Exit Function

    If bUseOGL Then
        Set ArrayToPicture = ArrayToPicture_O(PicBin, FlattenColor)
    Else
        ret = CreateStreamOnHGlobal(VarPtr(PicBin(0)), 0, IStm)    'Create stream from memory stack
        If ret = 0 Then    'OK, start GDIP :
            'Convert stream to GDIP-Image :
            ret = GdipLoadImageFromStream(IStm, lBitmap)
            If ret = 0 Then
                If Not IsMissing(FlattenColor) Then
                    Dim lBitmap2 As Long
                    Dim lGraph As Long
                    Dim w As Long, h As Long

                    ret = GdipCloneImage(lBitmap, lBitmap2)
                    ret = GdipGetImageGraphicsContext(lBitmap2, lGraph)
                    If ret = 0 Then
                        ret = GdipGetImageWidth(lBitmap, w)
                        ret = GdipGetImageHeight(lBitmap, h)
                        ret = GdipGraphicsClear(lGraph, CLng(FlattenColor))
                        ret = GdipDrawImageRectRectI(lGraph, lBitmap, 0, 0, w, h, 0, 0, w, h, _
                         UnitPixel, 0, 0)
                    End If
                    GdipCreateHBITMAPFromBitmap lBitmap2, hBmp, 0&
                    GdipDeleteGraphics lGraph
                Else
                    GdipCreateHBITMAPFromBitmap lBitmap, hBmp, 0&
                End If
                If hBmp <> 0 Then
                    'Convert bitmap to picture object :
                    Set ArrayToPicture = BitmapToPicture(hBmp)
                End If
            End If
            'Clear memory ...
            GdipDisposeImage lBitmap
        End If
    End If

End Function

Function MaskFromPicture(ByVal image As StdPicture, Optional TransColor As Variant) As StdPicture
    Dim lBitmap As Long
    Dim hBitmap As Long
    Dim w As Long, h As Long
    Dim bytes() As Long
    Dim BD As BitmapData
    Dim rct As RECTL
    Dim x As Long, y As Long
    Dim AlphaColor As Long
    Dim ret As Long

    If Not InitGDIP Then Exit Function

    If bUseOGL Then
        Set MaskFromPicture = MaskFromPicture_O(image, TransColor)
    Else
        ret = GdipCreateBitmapFromHBITMAP(image.handle, 0, lBitmap)
        If ret = 0 Then
            ret = GdipGetImageWidth(lBitmap, w)
            ret = GdipGetImageHeight(lBitmap, h)
            With rct
                .Left = 0
                .Top = h
                .Right = w
                .Bottom = 0
            End With
            ReDim bytes(w, h)
            With BD
                .width = w
                .height = h
                .PixelFormat = PixelFormat32bppARGB
                .stride = 4 * CLng(.width + 1)
                .scan0 = VarPtr(bytes(0, 0))
            End With
            ret = GdipBitmapLockBits(lBitmap, rct, ImageLockModeRead Or _
                                                   ImageLockModeUserInputBuf Or ImageLockModewrite, PixelFormat32bppARGB, BD)
            If IsMissing(TransColor) Then
                AlphaColor = bytes(0, 0)
            Else
                AlphaColor = CLng(TransColor)
            End If
            For x = 0 To w
                For y = 0 To h
                    If bytes(x, y) = AlphaColor Then bytes(x, y) = &HFFFFFF Else bytes(x, y) = &H0
                Next y
            Next x

            ret = GdipBitmapUnlockBits(lBitmap, BD)
            GdipCreateHBITMAPFromBitmap lBitmap, hBitmap, 0&
            Set MaskFromPicture = BitmapToPicture(hBitmap)
            GdipDisposeImage lBitmap
        End If
    End If

End Function

'Helper function to get a OLE-Picture from Windows-Bitmap-Handle
'If bIsIcon = TRUE, an Icon-Handle is commited
Function BitmapToPicture(ByVal hBmp As Long, Optional bIsIcon As Boolean = False) As StdPicture
    Dim TPicConv As PICTDESC, UID As guid

    With TPicConv
        If bIsIcon Then
            .cbSizeOfStruct = 16
            .PicType = 3    'PicType Icon
        Else
            .cbSizeOfStruct = Len(TPicConv)
            .PicType = 1    'PicType Bitmap
        End If
        .hImage = hBmp
    End With

    CLSIDFromString StrPtr(GUID_IPicture), UID
    OleCreatePictureIndirect TPicConv, UID, True, BitmapToPicture

End Function


'--------------------------------------------------------------------------------------------------
'Following the same procedures using the OGL library
'The procedure names are the same but ending with "_O" here
'(for comments see procs above)

Function LoadPictureGDIP_O(sFilename As String) As StdPicture
    Dim hBmp As Long
    Dim hPic As Long

    If Not InitGDIP Then Exit Function
    If GdipCreateBitmapFromFile_O(StrPtr(sFilename), hPic) = 0 Then
        GdipCreateHBITMAPFromBitmap_O hPic, hBmp, 0&
        If hBmp <> 0 Then
            Set LoadPictureGDIP_O = BitmapToPicture(hBmp)
            GdipDisposeImage_O hPic
        End If
    End If

End Function

Function ResampleGDIP_O(ByVal image As StdPicture, ByVal width As Long, ByVal height As Long) As StdPicture
    Dim lRes As Long
    Dim lBitmap As Long

    If Not InitGDIP Then Exit Function

    If image.Type = 1 Then
        lRes = GdipCreateBitmapFromHBITMAP_O(image.handle, 0, lBitmap)
    Else
        lRes = GdipCreateBitmapFromHICON_O(image.handle, lBitmap)
    End If
    If lRes = 0 Then
        Dim lThumb As Long
        Dim hBitmap As Long

        lRes = GdipGetImageThumbnail_O(lBitmap, width, height, lThumb, 0, 0)
        If lRes = 0 Then
            If image.Type = 3 Then
                lRes = GdipCreateHICONFromBitmap_O(lThumb, hBitmap)
                Set ResampleGDIP_O = BitmapToPicture(hBitmap, True)
            Else
                lRes = GdipCreateHBITMAPFromBitmap_O(lThumb, hBitmap, 0)
                Set ResampleGDIP_O = BitmapToPicture(hBitmap)
            End If

            GdipDisposeImage_O lThumb
        End If
        GdipDisposeImage_O lBitmap
    End If

End Function

Function CropImage_O(ByVal image As StdPicture, _
                   x As Long, y As Long, _
                   width As Long, height As Long) As StdPicture
    Dim ret As Long
    Dim lBitmap As Long
    Dim lBitmap2 As Long
    Dim lGraph As Long
    Dim hBitmap As Long
    Dim sx As Long, sy As Long

    Const PixelFormat32bppARGB = &H26200A
    Const UnitPixel = 2

    If Not InitGDIP Then Exit Function

    ret = GdipCreateBitmapFromHBITMAP_O(image.handle, 0, lBitmap)
    If ret = 0 Then
        ret = GdipGetImageWidth_O(lBitmap, sx)
        ret = GdipGetImageHeight_O(lBitmap, sy)
        If (x + width) > sx Then width = sx - x
        If (y + height) > sy Then height = sy - y
        ret = GdipCreateBitmapFromScan0_O(CLng(width), CLng(height), _
                    0, PixelFormat32bppARGB, ByVal 0&, lBitmap2)
        ret = GdipGetImageGraphicsContext_O(lBitmap2, lGraph)
        ret = GdipDrawImageRectRectI_O(lGraph, lBitmap, 0&, 0&, _
                    width, height, x, y, width, height, UnitPixel)
        ret = GdipCreateHBITMAPFromBitmap_O(lBitmap2, hBitmap, 0)
        Set CropImage_O = BitmapToPicture(hBitmap)

        GdipDisposeImage_O lBitmap
        GdipDisposeImage_O lBitmap2
        GdipDeleteGraphics_O lGraph
    End If

End Function

Function GetDimensionsGDIP_O(ByVal image As StdPicture) As TSize
    Dim lRes As Long
    Dim lBitmap As Long
    Dim x As Long, y As Long

    If Not InitGDIP Then Exit Function
    If image Is Nothing Then Exit Function
    lRes = GdipCreateBitmapFromHBITMAP_O(image.handle, 0, lBitmap)
    If lRes = 0 Then
        GdipGetImageHeight_O lBitmap, y
        GdipGetImageWidth_O lBitmap, x
        GetDimensionsGDIP_O.x = CDbl(x)
        GetDimensionsGDIP_O.y = CDbl(y)
        GdipDisposeImage_O lBitmap
    End If

End Function

Function SavePicGDIPlus_O(ByVal image As StdPicture, sFile As String, _
                        PicType As PicFileType, Optional Quality As Long = 80) As Boolean
    Dim lBitmap As Long
    Dim TEncoder As guid
    Dim ret As Long
    Dim TParams As EncoderParameters
    Dim sType As String

    If Not InitGDIP Then Exit Function

    If GdipCreateBitmapFromHBITMAP_O(image.handle, 0, lBitmap) = 0 Then
        Select Case PicType
        Case pictypeBMP: sType = "{557CF400-1A04-11D3-9A73-0000F81EF32E}"
        Case pictypeGIF: sType = "{557CF402-1A04-11D3-9A73-0000F81EF32E}"
        Case pictypePNG: sType = "{557CF406-1A04-11D3-9A73-0000F81EF32E}"
        Case pictypeJPG: sType = "{557CF401-1A04-11D3-9A73-0000F81EF32E}"
        End Select
        CLSIDFromString StrPtr(sType), TEncoder
        If PicType = pictypeJPG Then
            TParams.Count = 1
            With TParams.Parameter
                CLSIDFromString StrPtr("{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"), .UUID
                .NumberOfValues = 1
                .Type = 4
                .Value = VarPtr(CLng(Quality))
            End With
        Else
            If (PicType = pictypeGIF) Then TParams.Count = 1 Else TParams.Count = 0
        End If
        ret = GdipSaveImageToFile_O(lBitmap, StrPtr(sFile), TEncoder, TParams)
        GdipDisposeImage_O lBitmap
        DoEvents
        SavePicGDIPlus_O = (Dir(sFile) <> "")
    End If

End Function

Function ArrayFromPicture_O(ByVal image As Object, PicType As PicFileType, Optional Quality As Long = 80) As Byte()
    Dim lBitmap As Long
    Dim TEncoder As guid
    Dim ret As Long
    Dim TParams As EncoderParameters
    Dim sType As String
    Dim IStm As IUnknown

    If Not InitGDIP Then Exit Function

    If GdipCreateBitmapFromHBITMAP_O(image.handle, 0, lBitmap) = 0 Then
        Select Case PicType
        Case pictypeBMP: sType = "{557CF400-1A04-11D3-9A73-0000F81EF32E}"
        Case pictypeGIF: sType = "{557CF402-1A04-11D3-9A73-0000F81EF32E}"
        Case pictypePNG: sType = "{557CF406-1A04-11D3-9A73-0000F81EF32E}"
        Case pictypeJPG: sType = "{557CF401-1A04-11D3-9A73-0000F81EF32E}"
        End Select
        CLSIDFromString StrPtr(sType), TEncoder

        If PicType = pictypeJPG Then
            TParams.Count = 1
            With TParams.Parameter
                CLSIDFromString StrPtr("{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"), .UUID
                .NumberOfValues = 1
                .Type = 4
                .Value = VarPtr(CLng(Quality))
            End With
        Else
            If (PicType = pictypeGIF) Then TParams.Count = 1 Else TParams.Count = 0
        End If

        ret = CreateStreamOnHGlobal(0&, 1, IStm)
        ret = GdipSaveImageToStream_O(lBitmap, IStm, TEncoder, TParams)
        If ret = 0 Then
            Dim hMem As Long, lSize As Long, lpMem As Long
            Dim abData() As Byte

            ret = GetHGlobalFromStream(IStm, hMem)
            If ret = 0 Then
                lSize = GlobalSize(hMem)
                lpMem = GlobalLock(hMem)
                ReDim abData(lSize - 1)
                CopyMemory abData(0), ByVal lpMem, lSize
                GlobalUnlock hMem
                ArrayFromPicture_O = abData
            End If

            Set IStm = Nothing
        End If

        GdipDisposeImage_O lBitmap
    End If

End Function

Public Function AttachmentToPicture_O(strTable As String, strAttachmentField As String, strImage As String) As StdPicture
    Dim strSQL As String
    Dim bin() As Byte
    Dim nOffset As Long
    Dim nSize As Long

    strSQL = "SELECT " & strTable & "." & strAttachmentField & ".FileData AS data " & _
             "FROM " & strTable & _
             " WHERE " & strTable & "." & strAttachmentField & ".FileName='" & strImage & "'"
    On Error Resume Next
    bin = DBEngine(0)(0).OpenRecordset(strSQL, dbOpenSnapshot)(0)
    If Err.Number = 0 Then
        Dim bin2() As Byte
        nOffset = bin(0)
        nSize = UBound(bin)
        ReDim bin2(nSize - nOffset)
        CopyMemory bin2(0), bin(nOffset), nSize - nOffset
        Set AttachmentToPicture_O = ArrayToPicture_O(bin2)
        Erase bin2
        Erase bin
    End If
End Function

Public Function ArrayToPicture_O(ByRef PicBin() As Byte, Optional FlattenColor As Variant) As StdPicture
    Dim IStm As IUnknown
    Dim lBitmap As Long
    Dim hBmp As Long
    Dim ret As Long

    If Not InitGDIP Then Exit Function

    ret = CreateStreamOnHGlobal(VarPtr(PicBin(0)), 0, IStm)
    If ret = 0 Then
        ret = GdipLoadImageFromStream_O(IStm, lBitmap)
        If ret = 0 Then
            If Not IsMissing(FlattenColor) Then
                Dim lBitmap2 As Long
                Dim lGraph As Long
                Dim w As Long, h As Long

                ret = GdipCloneImage_O(lBitmap, lBitmap2)
                ret = GdipGetImageGraphicsContext_O(lBitmap2, lGraph)
                If ret = 0 Then
                    ret = GdipGetImageWidth_O(lBitmap, w)
                    ret = GdipGetImageHeight_O(lBitmap, h)
                    ret = GdipGraphicsClear_O(lGraph, CLng(FlattenColor))
                    ret = GdipDrawImageRectRectI_O(lGraph, lBitmap, 0, 0, w, h, 0, 0, w, h, _
                                                 UnitPixel, 0, 0)
                End If
                GdipCreateHBITMAPFromBitmap_O lBitmap2, hBmp, 0&
                GdipDeleteGraphics_O lGraph
            Else
                GdipCreateHBITMAPFromBitmap_O lBitmap, hBmp, 0&
            End If
            If hBmp <> 0 Then
                Set ArrayToPicture_O = BitmapToPicture(hBmp)
            End If
        End If
        GdipDisposeImage_O lBitmap
    End If

End Function


Function MaskFromPicture_O(ByVal image As StdPicture, Optional TransColor As Variant) As StdPicture
    Dim lBitmap As Long
    Dim hBitmap As Long
    Dim w As Long, h As Long
    Dim bytes() As Long
    Dim BD As BitmapData
    Dim rct As RECTL
    Dim x As Long, y As Long
    Dim AlphaColor As Long
    Dim ret As Long

    If Not InitGDIP Then Exit Function

    ret = GdipCreateBitmapFromHBITMAP_O(image.handle, 0, lBitmap)
    If ret = 0 Then
        ret = GdipGetImageWidth_O(lBitmap, w)
        ret = GdipGetImageHeight_O(lBitmap, h)
        With rct
            .Left = 0
            .Top = h
            .Right = w
            .Bottom = 0
        End With
        ReDim bytes(w, h)
        With BD
            .width = w
            .height = h
            .PixelFormat = PixelFormat32bppARGB
            .stride = 4 * CLng(.width + 1)
            .scan0 = VarPtr(bytes(0, 0))
        End With
        ret = GdipBitmapLockBits_O(lBitmap, rct, ImageLockModeRead Or _
                                               ImageLockModeUserInputBuf Or ImageLockModewrite, PixelFormat32bppARGB, BD)
        If IsMissing(TransColor) Then
            AlphaColor = bytes(0, 0)
        Else
            AlphaColor = CLng(TransColor)
        End If
        For x = 0 To w
            For y = 0 To h
                If bytes(x, y) = AlphaColor Then bytes(x, y) = &HFFFFFF Else bytes(x, y) = &H0
            Next y
        Next x

        ret = GdipBitmapUnlockBits_O(lBitmap, BD)
        GdipCreateHBITMAPFromBitmap_O lBitmap, hBitmap, 0&
        Set MaskFromPicture_O = BitmapToPicture(hBitmap)
        GdipDisposeImage_O lBitmap
    End If

End Function


Function Save_as_Jpg(strIn As String, strOut As String, Optional iQuality As Long = 70)

Dim myPic As StdPicture

Set myPic = LoadPictureGDIP(strIn)

'Save a bitmap as file (with format conversion!)
'image = StdPicture object
'sFile = complete file path
'PicType = pictypeBMP, pictypeGIF, pictypePNG oder pictypeJPG
'Quality: 0...100; (works only with pictypeJPG!)
'Returns TRUE if successful
'Function SavePicGDIPlus(ByVal Image As StdPicture, sFile As String, _
'                        PicType As PicFileType, Optional Quality As Long = 80) As Boolean

If Not SavePicGDIPlus(myPic, strOut, pictypeJPG, iQuality) Then
    MsgBox "Problem beim Save des jpg", vbCritical, strOut
End If

ShutDownGDIP

End Function

