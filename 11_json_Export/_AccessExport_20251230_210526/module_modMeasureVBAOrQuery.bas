Option Compare Database
Option Explicit

Declare PtrSafe Function GetTickCount Lib "kernel32" () As Long

Public MVBAStartTime As Long, MVBAEndTime As Long
Function MeasureQuery(strQueryName)
  Dim MQStartTime As Long, MQEndTime As Long
  Dim t As Variant
  Dim db As DAO.Database, rs As DAO.Recordset, qd As DAO.QueryDef

  DoCmd.Hourglass True
  On Error GoTo SQ_Error
  
  Set db = CurrentDb()
  Set qd = db.QueryDefs(strQueryName)
  
  MQStartTime = GetTickCount()
  
  Set rs = qd.OpenRecordset(dbOpenDynaset)
  If Not rs.EOF Then rs.MoveLast
  rs.Close
  
  MQEndTime = GetTickCount()
  
  DoCmd.Hourglass False
  MsgBox "Abfrage '" & strQueryName & "' benötigte " & Format((MQEndTime - MQStartTime) / 1000, "0.000") & " Sekunden..."
  
  Set rs = Nothing
  Set db = Nothing
  
  Exit Function

SQ_Error:
  DoCmd.Hourglass False
  MsgBox "Oops - Fehler bei Ausführung der Abfrage '" & strQueryName & "': " & Err.description & "..."
    
End Function

Sub StartMeasureVBA()

  On Error Resume Next
  MVBAStartTime = GetTickCount()
    
End Sub

Sub StopMeasureVBA()

  On Error Resume Next
  MVBAEndTime = GetTickCount()
    
  MsgBox "Ausführung benötigte " & Format((MVBAEndTime - MVBAStartTime) / 1000, "0.000") & " Sekunden..."
  
End Sub


Sub MeasureVBATest()
  Dim i&
  Dim varLookup As Variant
  
  On Error Resume Next
  StartMeasureVBA
  For i = 1 To 10000
    DoEvents
    varLookup = TLookup("*", "Bestellungen", "[Kunden-Code]='ANTON'")
  Next i
  StopMeasureVBA
  
End Sub