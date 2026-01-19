Attribute VB_Name = "zBase64Encoder"
Option Compare Database

'**********************
'Copyright(C) 2025 Xarial Pty Limited
'Reference: https://www.codestack.net/visual-basic/algorithms/data/encoding/base64/
'License: https://www.codestack.net/license/
'**********************

Function ConvertToBase64String(vArr As Variant) As String
    
    Dim xmlDoc As Object
    Dim xmlNode As Object
    
    Set xmlDoc = CreateObject("MSXML2.DOMDocument")
    
    Set xmlNode = xmlDoc.createElement("b64")
    
    xmlNode.DataType = "bin.base64"
    xmlNode.nodeTypedValue = vArr
    
    ConvertToBase64String = xmlNode.Text
    
End Function


'**********************
'Copyright(C) 2025 Xarial Pty Limited
'Reference: https://www.codestack.net/visual-basic/algorithms/data/encoding/base64/
'License: https://www.codestack.net/license/
'**********************

Function Base64ToArray(base64 As String) As Variant
    
    Dim xmlDoc As Object
    Dim xmlNode As Object
    
    Set xmlDoc = CreateObject("MSXML2.DOMDocument")
    Set xmlNode = xmlDoc.createElement("b64")
    
    xmlNode.DataType = "bin.base64"
    xmlNode.Text = base64
    
    Base64ToArray = xmlNode.nodeTypedValue
  
End Function


'Datei einlesen
Function readFileToArray(file As String) As Byte()
Dim dataBuffer() As Byte
    ReDim dataBuffer(FileLen(file))
    Open file For Binary Access Read As #1
    Get #1, , dataBuffer
    Close #1
    readFileToArray = dataBuffer

End Function
