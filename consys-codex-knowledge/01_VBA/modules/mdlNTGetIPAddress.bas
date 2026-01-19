Attribute VB_Name = "mdlNTGetIPAddress"
Option Compare Database
Option Explicit

'Wie kann ich die IP-Adresse einer NT4-Workstation herausfinden ?
'Newsgroup - From: "Marc" <mveltrup@jjk.de>

Private Const MAX_WSADescription = 256
Private Const MAX_WSASYSStatus = 128
Private Const ERROR_SUCCESS       As Long = 0
Private Const WS_VERSION_REQD     As Long = &H101
Private Const WS_VERSION_MAJOR    As Long = WS_VERSION_REQD \ &H100 And &HFF&
Private Const WS_VERSION_MINOR    As Long = WS_VERSION_REQD And &HFF&
Private Const MIN_SOCKETS_REQD    As Long = 1
Private Const SOCKET_ERROR        As Long = -1

Private Type HOSTENT
   hName      As Long
   hAliases   As Long
   hAddrType  As Integer
   hLen       As Integer
   hAddrList  As Long
End Type

Private Type WSADATA
   wVersion      As Integer
   wHighVersion  As Integer
   szDescription(0 To MAX_WSADescription)   As Byte
   szSystemStatus(0 To MAX_WSASYSStatus)    As Byte
   wMaxSockets   As Integer
   wMaxUDPDG     As Integer
   dwVendorInfo  As Long
End Type

Private Declare PtrSafe Function WSAGetLastError Lib "WSOCK32.DLL" () As Long

Private Declare PtrSafe Function WSAStartup Lib "WSOCK32.DLL" _
   (ByVal wVersionRequired As Long, lpWSADATA As WSADATA) As Long

Private Declare PtrSafe Function WSACleanup Lib "WSOCK32.DLL" () As Long

Private Declare PtrSafe Function gethostname Lib "WSOCK32.DLL" _
   (ByVal szHost As String, ByVal dwHostLen As Long) As Long

Private Declare PtrSafe Function gethostbyname Lib "WSOCK32.DLL" _
   (ByVal szHost As String) As Long

Private Declare PtrSafe Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" _
   (hpvDest As Any, ByVal hpvSource As Long, ByVal cbCopy As Long)

Public Function GetIPAddress() As String

   Dim sHostName    As String * 256
   Dim lpHost    As Long
   Dim host      As HOSTENT
   Dim dwIPAddr  As Long
   Dim tmpIPAddr() As Byte
   Dim i         As Integer
   Dim sIPAddr  As String
      If Not SocketsInitialize() Then
      GetIPAddress = ""
      Exit Function
   End If

   If gethostname(sHostName, 256) = SOCKET_ERROR Then
   GetIPAddress = ""
      MsgBox "Windows Sockets error " & str$(WSAGetLastError()) & _
              " has occurred. Unable to successfully get Host Name."
      SocketsCleanup
      Exit Function
      End If

   lpHost = gethostbyname(sHostName)
   If lpHost = 0 Then
      GetIPAddress = ""
      MsgBox "Windows Sockets are not responding. " & _
              "Unable to successfully get Host Name."
              SocketsCleanup
      Exit Function
      End If

  CopyMemory host, lpHost, Len(host)
   CopyMemory dwIPAddr, host.hAddrList, 4

  ReDim tmpIPAddr(1 To host.hLen)
   CopyMemory tmpIPAddr(1), dwIPAddr, host.hLen

  For i = 1 To host.hLen
      sIPAddr = sIPAddr & tmpIPAddr(i) & "."
      Next

   GetIPAddress = Mid$(sIPAddr, 1, Len(sIPAddr) - 1)
   SocketsCleanup
End Function

Public Function GetIPHostName() As String

    Dim sHostName As String * 256
    If Not SocketsInitialize() Then
        GetIPHostName = ""
        Exit Function
    End If
    If gethostname(sHostName, 256) = SOCKET_ERROR Then
        GetIPHostName = ""
        MsgBox "Windows Sockets error " & str$(WSAGetLastError()) & _
                " has occurred.  Unable to successfully get Host Name."
        SocketsCleanup
        Exit Function
        End If
    GetIPHostName = Left$(sHostName, InStr(sHostName, Chr(0)) - 1)
    SocketsCleanup
    End Function
    
    
Private Function HiByte(ByVal wParam As Integer)

    HiByte = wParam \ &H100 And &HFF&
End Function


Private Function LoByte(ByVal wParam As Integer)
    
    LoByte = wParam And &HFF&
End Function


Private Sub SocketsCleanup()

If WSACleanup() <> ERROR_SUCCESS Then
        MsgBox "Socket error occurred in Cleanup."
        End If
        End Sub


Private Function SocketsInitialize() As Boolean

Dim WSAD As WSADATA
   Dim sLoByte As String
   Dim sHiByte As String
   If WSAStartup(WS_VERSION_REQD, WSAD) <> ERROR_SUCCESS Then
      MsgBox "The 32-bit Windows Socket is not responding."
      SocketsInitialize = False
      Exit Function
      End If
   If WSAD.wMaxSockets < MIN_SOCKETS_REQD Then
        MsgBox "This application requires a minimum of " & _
                CStr(MIN_SOCKETS_REQD) & " supported sockets."
        SocketsInitialize = False
        Exit Function
        End If
   If LoByte(WSAD.wVersion) < WS_VERSION_MAJOR Or _
     (LoByte(WSAD.wVersion) = WS_VERSION_MAJOR And _
      HiByte(WSAD.wVersion) < WS_VERSION_MINOR) Then
      sHiByte = CStr(HiByte(WSAD.wVersion))
      sLoByte = CStr(LoByte(WSAD.wVersion))
      MsgBox "Sockets version " & sLoByte & "." & sHiByte & _
             " is not supported by 32-bit Windows Sockets."
      SocketsInitialize = False
      Exit Function
      End If
  'must be OK, so lets do it
  SocketsInitialize = True
  End Function

