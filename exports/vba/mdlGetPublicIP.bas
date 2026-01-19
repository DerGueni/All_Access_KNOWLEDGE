Attribute VB_Name = "mdlGetPublicIP"
Option Compare Database
Option Explicit

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Copyright ©1996-2009 VBnet, Randy Birch, All Rights Reserved.
' Some pages may also contain other copyrights by the author.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Distribution: You can freely use this code in your own
'               applications, but you may not reproduce
'               or publish this code on any web site,
'               online service, or distribute as source
'               on any media without express permission.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
'I have a page at http://vbnet.mvps.org/resources/tools/getpublicip.shtml that can be used by anyone to return their public IP address. When viewed in a
'browser the page shows only the IP with no other text making scraping the page easier than those containing other information.  Using the fast and
'transparent URLDownloadToFile API the resulting file has a bit of html and java code in it which requires parsing, and is the subject of this demo.
'
'Essentially the code uses the familiar UrlDownloadToFile call, with a DeleteUrlCacheEntry call for good measure, to retrieve the file to a local file path,
'where it is loaded into a buffer and parsed to extract the IP address string embedded in the file. All pretty straightforward, this is really the only
'mechanism available to identify the public IP address on machines served a DHCP address by their DSL router.
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private Const ERROR_SUCCESS As Long = 0
Private Const MAX_ADAPTER_NAME_LENGTH As Long = 256
Private Const MAX_ADAPTER_DESCRIPTION_LENGTH As Long = 128
Private Const MAX_ADAPTER_ADDRESS_LENGTH As Long = 8

Private Type IP_ADDRESS_STRING
   IpAddr(0 To 15) As Byte
End Type

Private Type IP_MASK_STRING
   IpMask(0 To 15) As Byte
End Type

Private Type IP_ADDR_STRING
   dwNext As Long
   IpAddress As IP_ADDRESS_STRING
   IpMask As IP_MASK_STRING
   dwContext As Long
End Type

Private Type IP_ADAPTER_INFO
   dwNext As Long
   ComboIndex As Long  'reserved
   sAdapterName(0 To (MAX_ADAPTER_NAME_LENGTH + 3)) As Byte
   sDescription(0 To (MAX_ADAPTER_DESCRIPTION_LENGTH + 3)) As Byte
   dwAddressLength As Long
   sIPAddress(0 To (MAX_ADAPTER_ADDRESS_LENGTH - 1)) As Byte
   dwIndex As Long
   uType As Long
   uDhcpEnabled As Long
   CurrentIpAddress As Long
   IpAddressList As IP_ADDR_STRING
   GatewayList As IP_ADDR_STRING
   DhcpServer As IP_ADDR_STRING
   bHaveWins As Long
   PrimaryWinsServer As IP_ADDR_STRING
   SecondaryWinsServer As IP_ADDR_STRING
   LeaseObtained As Long
   LeaseExpires As Long
End Type

Private Declare PtrSafe Function GetAdaptersInfo Lib "iphlpapi.dll" _
  (pTcpTable As Any, _
   pdwSize As Long) As Long
   
Private Declare PtrSafe Sub CopyMemory Lib "kernel32" _
   Alias "RtlMoveMemory" _
  (DST As Any, _
   src As Any, _
   ByVal bcount As Long)
   
Private Declare PtrSafe Function URLDownloadToFile Lib "urlmon" _
   Alias "URLDownloadToFileA" _
  (ByVal pCaller As Long, _
   ByVal szURL As String, _
   ByVal szFileName As String, _
   ByVal dwReserved As Long, _
   ByVal lpfnCB As Long) As Long
   
Private Declare PtrSafe Function DeleteUrlCacheEntry Lib "wininet.dll" _
   Alias "DeleteUrlCacheEntryA" _
  (ByVal lpszUrlName As String) As Long
      
Private Declare PtrSafe Function lstrlenW Lib "kernel32" _
  (ByVal lpString As LongPtr) As Long



Function GetPublicIP()

   Dim sSourceUrl As String
   Dim sLocalFile As String
   Dim hFile As Long
   Dim buff As String
   Dim pos1 As Long
   Dim pos2 As Long
   
  'site returning IP address
  'Telekom
  sSourceUrl = "http://eces.t-online.de/hotline/ip/"
'   sSourceUrl = "http://vbnet.mvps.org/resources/tools/getpublicip.shtml"
' sSourceUrl = "http://automation.whatismyip.com/n09230945.asp"
'   sSourceUrl = "http://192.168.2.1/cgi-bin/webcm?getpage=../html/top_status.htm"
   sLocalFile = GetTempDir() & "ip.txt"
   
  'ensure this file does not exist in the cache
   Call DeleteUrlCacheEntry(sSourceUrl)

  'download the public IP file,
  'read into a buffer and delete
   If DownloadFile(sSourceUrl, sLocalFile) Then
   
      hFile = FreeFile
      Open sLocalFile For Input As #hFile
        buff = Input$(LOF(hFile), hFile)
        If Len(Trim(Nz(buff))) > 0 Then
            pos1 = -1
        Else
            pos1 = 0
        End If
      Close #hFile


     'look for the IP line
'      pos1 = InStr(buff, "var ip =")
'      pos1 = InStr(buff, "Aktiv: ")
   
     'if found,
      If pos1 Then
   
        'get position of first and last single
        'quotes around address (e.g. '11.22.33.44')
'         pos1 = InStr(pos1 + 1, buff, "'", vbTextCompare) + 1
         pos1 = InStr(1, buff, "'", vbTextCompare) + 1
         pos2 = InStr(pos1 + 1, buff, "'", vbTextCompare) '- 1
      
'         pos1 = InStr(pos1 + 1, buff, " ", vbTextCompare) + 1
'         pos2 = InStr(pos1 + 1, buff, "</", vbTextCompare) '- 1
      
        'return the IP address
         GetPublicIP = Mid$(buff, pos1, pos2 - pos1)
        
''        GetPublicIP = buff

      Else
      
         GetPublicIP = "(IP unknown)"
      
      End If  'pos1
      
      Kill sLocalFile
   
   Else
      
      GetPublicIP = "(No Internet)"
      
   End If  'DownloadFile
   
End Function


Private Function DownloadFile(ByVal sURL As String, _
                             ByVal sLocalFile As String) As Boolean
   
   DownloadFile = URLDownloadToFile(0, sURL, sLocalFile, 0, 0) = ERROR_SUCCESS
   
End Function


Private Function LocalIPAddress() As String
   
   Dim cbRequired As Long
   Dim buff() As Byte
   Dim ptr1 As LongPtr
   Dim sIPAddr As String
   Dim Adapter As IP_ADAPTER_INFO
   
   Call GetAdaptersInfo(ByVal 0&, cbRequired)

   If cbRequired > 0 Then
    
      ReDim buff(0 To cbRequired - 1) As Byte
      
      If GetAdaptersInfo(buff(0), cbRequired) = ERROR_SUCCESS Then
      
        'get a pointer to the data stored in buff()
         ptr1 = VarPtr(buff(0))

         Do While (ptr1 <> 0)
         
           'copy the data from the pointer to the
           'first adapter into the IP_ADAPTER_INFO type
            CopyMemory Adapter, ByVal ptr1, LenB(Adapter)
         
            With Adapter
                       
              'the DHCP IP address is in the
              'IpAddress.IpAddr member
                 
               sIPAddr = TrimNull(StrConv(.IpAddressList.IpAddress.IpAddr, vbUnicode))
                  
               If Len(sIPAddr) > 0 Then Exit Do

               ptr1 = .dwNext
                              
            End With  'With Adapter
            
        'ptr1 is 0 when (no more adapters)
         Loop  'Do While (ptr1 <> 0)

      End If  'If GetAdaptersInfo
   End If  'If cbRequired > 0

  'return any string found
   LocalIPAddress = sIPAddr
   
End Function


Private Function TrimNull(startstr As String) As String

   TrimNull = Left$(startstr, lstrlenW(StrPtr(startstr)))
   
End Function

