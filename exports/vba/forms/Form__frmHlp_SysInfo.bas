VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form__frmHlp_SysInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database   'Use database order for string comparisons
Option Explicit


Private Function AccessInfo() As String

    Dim dbCurrent As DAO.Database
    Dim strcrlf As String
    Dim strMessage As String
    Dim strMessage2 As String
    Static astrLocks(3) As String
    Static astrOpen(2) As String
    Dim RunTime As String

    Set dbCurrent = DBEngine(0)(0)
    
    strcrlf = Chr(13) & Chr(10)

    astrLocks(1) = "No Locks"
    astrLocks(2) = "All Records"
    astrLocks(3) = "Edited Record"

    astrOpen(1) = "Shared"
    astrOpen(2) = "Exclusive"

    If SysCmd(SYSCMD_RUNTIME) = 0 Then
        RunTime = "Retail"
    Else
        RunTime = "RunTime"
    End If

'    strMessage = strcrlf & "  Logged in as: " & CurrentUser()
    strMessage = "  Logged in as: " & CurrentUser()
    strMessage = strMessage & strcrlf & "  OLE/DDE Timeout is " & Application.GetOption("OLE/DDE Timeout (sec)") & " seconds"
    strMessage = strMessage & strcrlf & "  DDE Requests are "
    If Application.GetOption("Ignore DDE Requests") Then
        strMessage = strMessage & "ignored"
    Else
        strMessage = strMessage & "not ignored"
    End If
    strMessage = strMessage & strcrlf & "  Default Record Locking is: " & astrLocks(Application.GetOption("Default Record Locking") + 1)
    strMessage = strMessage & strcrlf & "  Default Open Mode for Application is: " & astrOpen(Application.GetOption("Default Open Mode for Databases") + 1)
    strMessage = strMessage & strcrlf & "  JET db Engine is version " & atGetjetver() & "; " & RunTime
    strMessage = strMessage & strcrlf & "  Default Directory is: " & Application.GetOption("Default Database Directory")
    strMessage = strMessage & strcrlf & "  Windows directory is: " & GetWinDir
    strMessage = strMessage & strcrlf & "  System directory is: " & GetSysDir
    strMessage2 = "  FE: " & Info_Frontend
    Me!lbl_DB.caption = strMessage2
   
    AccessInfo = strMessage
End Function


Function Info_Backend()
Info_Backend = Nz(TLookup("Database", "qrymdbTable3"), " -- keines -- ")
End Function

Function Info_Frontend()
Info_Frontend = CurrentDb.Name
End Function


Private Function api_UpdateSysResInfo()
On Error GoTo api_UpdateSysResInfoError

    Dim wMemLoad As Long
    Dim wMemLoadVirt As Long
    
    '% Memory Allocation
    wMemLoad = (1 - (atGetMemEx(2) / (atGetMemEx(1)))) * 100
    wMemLoadVirt = (1 - (atGetMemEx(4) / (atGetMemEx(3)))) * 100

    'Set caption text and adjust rectangle width and color
    Me!lblMemLoad.caption = wMemLoad & "%"
    Me!lblMemLoad2.caption = wMemLoadVirt & "%"
    Me!objMemLoad.width = CLng(Me.lblMemLoad.width * (wMemLoad / 100))
    Me!objMemLoad2.width = CLng(Me!lblMemLoad.width * (wMemLoadVirt / 100))
    Select Case wMemLoad
        Case Is < 15
            Me.objMemLoad.backColor = 65280
        Case Is < 50
            Me.objMemLoad.backColor = 65535
        Case Else
            Me.objMemLoad.backColor = 255
    End Select
    
    Select Case wMemLoadVirt
        Case Is < 15
            Me.objMemLoad2.backColor = 65280
        Case Is < 50
            Me.objMemLoad2.backColor = 65535
        Case Else
            Me.objMemLoad2.backColor = 255
    End Select
     
api_UpdateSysResInfoExit:
    Exit Function
api_UpdateSysResInfoError:
    MsgBox Err & " " & Error, 48, "api_UpdateSysResInfo"
    DoCmd.Close
'    Resume api_UpdateSysResInfoExit
End Function

Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"

End Sub

Private Sub btnMSInfo_Click()
Dim tmp1

    tmp1 = GetMsinfo32Path()
    Shell tmp1, vbNormalFocus

End Sub

Private Sub cmdOK_Click()
On Error GoTo Err_cmdOK_Click


    DoCmd.Close

Exit_cmdOK_Click:
    Exit Sub

Err_cmdOK_Click:
    MsgBox Error$
    Resume Exit_cmdOK_Click
    
End Sub



Private Sub Drive_AfterUpdate()

Dim DType As Long

DType = atDriveType(Me!Drive)

Select Case DType

Case 0 Or 1  'unknown
    Me!NoD.Visible = True
    Me!FixD.Visible = False
    Me!CDD.Visible = False
    Me!FlopD.Visible = False
    Me!NetD.Visible = False
Case 2       'Removeable
    Me!NoD.Visible = False
    Me!FixD.Visible = False
    Me!CDD.Visible = False
    Me!FlopD.Visible = True
    Me!NetD.Visible = False
Case 3       'Fixed
    Me!NoD.Visible = False
    Me!FixD.Visible = True
    Me!CDD.Visible = False
    Me!FlopD.Visible = False
    Me!NetD.Visible = False
Case 4      'Network
    Me!NoD.Visible = False
    Me!FixD.Visible = False
    Me!CDD.Visible = False
    Me!FlopD.Visible = False
    Me!NetD.Visible = True
Case 5      'CD
    Me!NoD.Visible = False
    Me!FixD.Visible = False
    Me!CDD.Visible = True
    Me!FlopD.Visible = False
    Me!NetD.Visible = False
Case 6      'Ram Drive
    Me!NoD.Visible = False
    Me!FixD.Visible = True
    Me!CDD.Visible = False
    Me!FlopD.Visible = False
    Me!NetD.Visible = False
End Select

Me!cmdOK.SetFocus

End Sub


Private Sub Form_Load()
Dim tmp1

    Dim intDrive%
    Dim DType As Byte
    Dim strDrives$

If Is64Bit() Then
    Me!lbl_64bit.caption = "MSOffice 64 bit"
Else
    Me!lbl_64bit.caption = "MSOffice 32 bit"
End If

Me![btnMSInfo].Visible = False

tmp1 = GetMsinfo32Path()

If Len(Nz(tmp1)) > 0 Then
    If File_exist(tmp1) Then
        Me![btnMSInfo].Visible = True
    End If
End If

On Error GoTo Err_FL

    For intDrive = 65 To 90 ' Ascii A bis Z
        DType = atDriveType(Chr(intDrive))
        If (DType) <> 1 Then  '1 = Non-existant drive
            strDrives = strDrives & Chr(intDrive) & ";"
        End If
    Next intDrive
    
    strDrives = Left(strDrives, Len(strDrives) - 1)
    Me!Drive.RowSource = strDrives

Exit_FL:
    Exit Sub
Err_FL:
    'default to all drives on Error
    Me!Drive.RowSource = "A;B;C;D;E;F;G;H;I;J;K;L;M;N;O;P;Q;R;S;T;U;V;W;X;Y;Z"
    Resume Exit_FL

End Sub


Private Function Is64Bit() As Boolean

Is64Bit = False
#If Win64 Then
 Is64Bit = True
#End If

End Function

'**********************************************************************************
'Function File_Exist ()
'
'   Überprüft, ob die Datei vorhanden ist
'   Rückgabe:  True, Datei vorhanden
'              False, Datei nicht vorhanden
'**********************************************************************************
Private Function File_exist(ByVal file As String) As Integer
Dim f

f = FreeFile
On Error GoTo File_existError
Open file For Input Access Read As #f
Close #f
File_exist = True
Exit Function

File_existError:
File_exist = False
Exit Function

End Function


Function GetMsinfo32Path() As String

' Es wird noch das Modul mdlRegistry verwendet.

' This function returns the Path of msinfo32.exe as a string.
   
    Static tempPath As String
    Static PathAlreadySearched As Integer
         
    If PathAlreadySearched <> 10 Then
        PathAlreadySearched = 10
        tempPath = QueryValue(HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Shared Tools\MSInfo", "Path")
        If Not File_exist(tempPath) Then
        ' Pfad bei Standard-Installation
            tempPath = "C:\Programme\Gemeinsame Dateien\Microsoft Shared\MSInfo\MSINFO32.EXE"
            If Not File_exist(tempPath) Then
                    tempPath = ""
            End If
        End If
    End If
    
    GetMsinfo32Path = tempPath
End Function

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
Me!PublicIP = GetPublicIP()
End Sub
