Attribute VB_Name = "mdl_DiagnoseMonats"

Option Compare Database
Option Explicit

' Diagnose-Modul für frm_MA_Monatübersicht
' Prüft cboJahr und Unterformulare

Public Sub Diagnose_Monatsübersicht()
    On Error GoTo ErrorHandler
    
    Dim frm As Form
    Dim ctrl As control
    Dim output As String
    Dim rs As DAO.Recordset
    
    ' öffne Formular
    DoCmd.OpenForm "frm_MA_Monatsübersicht_NEU", acNormal
    Set frm = Forms("frm_MA_Monatsübersicht")
    
    output = "=== DIAGNOSE frm_MA_Monatsübersicht ===" & vbCrLf & vbCrLf
    
    ' 1. FORMULAR EIGENSCHAFTEN
    output = output & "FORMULAR:" & vbCrLf
    output = output & "  RecordSource: " & Nz(frm.recordSource, "(leer)") & vbCrLf
    output = output & "  RecordsetType: " & frm.RecordsetType & vbCrLf
    output = output & "  AllowEdits: " & frm.AllowEdits & vbCrLf
    output = output & "  DataEntry: " & frm.DataEntry & vbCrLf & vbCrLf
    
    ' 2. COMBOBOX cboJahr PRÜFEN
    output = output & "COMBOBOX cboJahr:" & vbCrLf
    On Error Resume Next
    Set ctrl = frm.Controls("cboJahr")
    If Err.Number = 0 Then
        output = output & "  Existiert: Ja" & vbCrLf
        output = output & "  RowSource: '" & ctrl.RowSource & "'" & vbCrLf
        output = output & "  RowSourceType: " & ctrl.RowSourceType & vbCrLf
        output = output & "  Enabled: " & ctrl.Enabled & vbCrLf
        output = output & "  Locked: " & ctrl.Locked & vbCrLf
        output = output & "  Visible: " & ctrl.Visible & vbCrLf
        output = output & "  Value: " & Nz(ctrl.Value, "(NULL)") & vbCrLf
        
        ' Prüfe ob RowSource Daten liefert
        If ctrl.RowSourceType = "Table/Query" And ctrl.RowSource <> "" Then
            On Error Resume Next
            Set rs = CurrentDb.OpenRecordset(ctrl.RowSource)
            If Err.Number = 0 Then
                output = output & "  RowSource gültig: Ja" & vbCrLf
                output = output & "  Anzahl Datensätze: " & rs.RecordCount & vbCrLf
                If Not rs.EOF Then
                    rs.MoveLast
                    rs.MoveFirst
                    output = output & "  Erster Wert: " & rs.fields(0).Value & vbCrLf
                End If
                rs.Close
            Else
                output = output & "  RowSource Fehler: " & Err.description & vbCrLf
            End If
            On Error GoTo ErrorHandler
        End If
    Else
        output = output & "  FEHLER: Control nicht gefunden!" & vbCrLf
    End If
    On Error GoTo ErrorHandler
    output = output & vbCrLf
    
    ' 3. UNTERFORMULARE PRÜFEN
    output = output & "UNTERFORMULARE:" & vbCrLf
    For Each ctrl In frm.Controls
        If ctrl.ControlType = acSubform Then
            output = output & vbCrLf & "  " & ctrl.Name & ":" & vbCrLf
            output = output & "    SourceObject: " & Nz(ctrl.SourceObject, "(leer)") & vbCrLf
            output = output & "    LinkChildFields: " & Nz(ctrl.LinkChildFields, "(leer)") & vbCrLf
            output = output & "    LinkMasterFields: " & Nz(ctrl.LinkMasterFields, "(leer)") & vbCrLf
            
            On Error Resume Next
            If Not ctrl.Form Is Nothing Then
                output = output & "    SubForm.RecordSource: " & ctrl.Form.recordSource & vbCrLf
                output = output & "    SubForm.RecordCount: " & ctrl.Form.RecordsetClone.RecordCount & vbCrLf
            Else
                output = output & "    SubForm.Form: (NULL)" & vbCrLf
            End If
            On Error GoTo ErrorHandler
        End If
    Next ctrl
    
    ' 4. EVENT-HANDLER PRÜFEN
    output = output & vbCrLf & "EVENT-HANDLER:" & vbCrLf
    output = output & "  OnLoad: " & Nz(frm.OnLoad, "(leer)") & vbCrLf
    output = output & "  OnCurrent: " & Nz(frm.OnCurrent, "(leer)") & vbCrLf
    
    On Error Resume Next
    Set ctrl = frm.Controls("cboJahr")
    If Err.Number = 0 Then
        output = output & "  cboJahr.AfterUpdate: " & Nz(ctrl.AfterUpdate, "(leer)") & vbCrLf
        output = output & "  cboJahr.OnChange: " & Nz(ctrl.OnChange, "(leer)") & vbCrLf
    End If
    On Error GoTo ErrorHandler
    
    ' Ausgabe anzeigen
    Debug.Print output
    MsgBox output, vbInformation, "Diagnose abgeschlossen"
    
    ' Speichere auch in Datei
    Dim fNum As Integer
    fNum = FreeFile
    Open "C:\Users\guenther.siegert\Documents\Diagnose_Monatsübersicht.txt" For Output As #fNum
    Print #fNum, output
    Close #fNum
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler in Diagnose: " & Err.description, vbCritical
    Debug.Print "Fehler: " & Err.description
End Sub

' Schnellprüfung der cboJahr RowSource
Public Sub Check_cboJahr_RowSource()
    On Error GoTo ErrorHandler
    
    Dim rs As DAO.Recordset
    Dim sql As String
    
    ' Öffne Formular
    DoCmd.OpenForm "frm_MA_Monatsübersicht_NEU", acNormal
    
    ' Hole RowSource
    sql = Forms("frm_MA_Monatsübersicht_NEU").Controls("cboJahr").RowSource
    
    Debug.Print "cboJahr RowSource: " & sql
    
    If sql <> "" Then
        Set rs = CurrentDb.OpenRecordset(sql)
        Debug.Print "Anzahl Jahre: " & rs.RecordCount
        
        If Not rs.EOF Then
            rs.MoveLast
            rs.MoveFirst
            Do While Not rs.EOF
                Debug.Print "  Jahr: " & rs.fields(0).Value
                rs.MoveNext
            Loop
        End If
        rs.Close
    Else
        Debug.Print "FEHLER: RowSource ist leer!"
    End If
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
    Debug.Print "Fehler: " & Err.description
End Sub

