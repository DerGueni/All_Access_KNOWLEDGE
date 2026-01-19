---
name: VBA Error Debugger
description: Debuggt VBA-Fehler in MS Access und fügt professionelles Error-Handling hinzu
when_to_use: VBA Fehler, Runtime Error, Error 91, Error 3075, Access crasht, Debug, Fehlerbehandlung
version: 1.0.0
---

# VBA Error Debugger für MS Access

## Häufige Access VBA Fehler

| Error # | Beschreibung | Lösung |
|---------|--------------|--------|
| 91 | Object variable not set | `Set obj = ...` fehlt |
| 94 | Invalid use of Null | `Nz()` verwenden |
| 3075 | Syntax error in query | SQL prüfen, Anführungszeichen |
| 3061 | Too few parameters | Feldname falsch geschrieben |
| 2501 | Action was cancelled | Normal bei Cancel, ignorieren |
| 3021 | No current record | `If Not rs.EOF` prüfen |
| 2046 | Macro/action not available | DoCmd in falscher Ansicht |
| 3265 | Item not found in collection | Feldname existiert nicht |

## Error-Handling Template

```vba
Private Sub btnAction_Click()
On Error GoTo Err_Handler

    ' === CODE HIER ===
    
Exit_Handler:
    Exit Sub
    
Err_Handler:
    Select Case Err.Number
        Case 2501  ' Cancelled - ignorieren
            Resume Exit_Handler
        Case Else
            MsgBox "Fehler " & Err.Number & ": " & Err.Description, _
                   vbCritical, "Fehler in btnAction_Click"
    End Select
    Resume Exit_Handler
End Sub
```

## Debug-Strategien

### 1. Immediate Window (Strg+G)
```vba
Debug.Print "Variable x = " & x
Debug.Print "RS Count: " & rs.RecordCount
? CurrentDb.TableDefs.Count
```

### 2. Breakpoints setzen
- F9 auf Zeile → Breakpoint
- F8 → Einzelschritt
- F5 → Weiter bis nächster Breakpoint

### 3. Variablen überwachen
- Debug → Add Watch
- Locals-Fenster für alle lokalen Variablen

## SQL-Fehler debuggen

```vba
' SQL vor Ausführung ausgeben
Dim strSQL As String
strSQL = "SELECT * FROM tblMitarbeiter WHERE ID = " & lngID
Debug.Print strSQL  ' <-- Im Immediate Window prüfen!
CurrentDb.Execute strSQL
```

## Null-Werte sicher behandeln

```vba
' FALSCH:
strName = Me.txtName

' RICHTIG:
strName = Nz(Me.txtName, "")
lngID = Nz(Me.txtID, 0)
```

## Recordset sicher verwenden

```vba
Dim rs As DAO.Recordset
Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl")

If Not rs.EOF And Not rs.BOF Then
    rs.MoveFirst
    Do While Not rs.EOF
        Debug.Print rs!Feldname
        rs.MoveNext
    Loop
End If

rs.Close
Set rs = Nothing
```

## Logging-Funktion

```vba
Public Sub LogError(strProc As String, lngErr As Long, strDesc As String)
    Dim strPath As String
    strPath = CurrentProject.Path & "\ErrorLog.txt"
    
    Open strPath For Append As #1
    Print #1, Now() & " | " & strProc & " | Error " & lngErr & ": " & strDesc
    Close #1
End Sub
```

## Dateipfade
- VBA-Module: `01_VBA/`
- Access Frontend: `0_Consys_FE_Test.accdb`
