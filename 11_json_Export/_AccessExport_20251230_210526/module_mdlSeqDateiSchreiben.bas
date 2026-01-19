Option Compare Database
Option Explicit

Dim FileNr1 As Integer
Dim i As Integer
Dim tmpString As String

Public Function SeqZeileAppendOutputOpCls(Outputdateiname As String, XString As String) As Boolean

On Error GoTo errorHandle

    i = 0
    FileNr1 = FreeFile()
    Open Outputdateiname For Append As #FileNr1
            
    Print #FileNr1, XString
        
    Close #FileNr1
    SeqZeileAppendOutputOpCls = True
    Exit Function
    
errorHandle:
    SeqZeileAppendOutputOpCls = False
    MsgBox Err & ": " & Err.description
End Function


Public Function SeqZeileAppendOutputOpen(Outputdateiname As String, Optional IfExistDelete As Boolean = False) As Boolean

On Error GoTo errorHandle

    If IfExistDelete = True Then
        If Len(Trim(Nz(Dir(Outputdateiname)))) > 0 Then
            Kill Outputdateiname
        End If
    End If

    i = 0
    FileNr1 = FreeFile()
    Open Outputdateiname For Append As #FileNr1
            
    SeqZeileAppendOutputOpen = True
    Exit Function
    
errorHandle:
    SeqZeileAppendOutputOpen = False
    MsgBox Err & ": " & Err.description
End Function



Public Function SeqZeileAppendOutputClose() As Boolean

On Error GoTo errorHandle

    Close #FileNr1
    SeqZeileAppendOutputClose = True
    Exit Function
    
errorHandle:
    SeqZeileAppendOutputClose = False
    MsgBox Err & ": " & Err.description
End Function

Public Function SeqZeileAppendOutputZeile(XString As String) As Boolean

On Error GoTo errorHandle

    Print #FileNr1, XString
        
    SeqZeileAppendOutputZeile = True
    Exit Function
    
errorHandle:
    SeqZeileAppendOutputZeile = False
    MsgBox Err & ": " & Err.description
End Function

Public Function SQLSchrTest()

If SeqZeileAppendOutputOpen("C:\Hugo.txt", True) Then
    Call SeqZeileAppendOutputZeile("Hallo Hallo 111")
    Call SeqZeileAppendOutputZeile("Hallo Hallo 222")
    Call SeqZeileAppendOutputZeile("Hallo Hallo 333")
    Call SeqZeileAppendOutputZeile("Hallo Hallo 444")
    Call SeqZeileAppendOutputClose
End If

End Function