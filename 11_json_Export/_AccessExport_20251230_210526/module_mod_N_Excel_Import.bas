' ============================================================================
' mdl_OB_Excel_Import - Excel Ordnerkonzept Import
' Importiert Positionen aus Excel-Vorlagen in tbl_OB_Objekt_Positionen
' ============================================================================

Public Function ImportOrdnerkonzeptExcel(strFilePath As String, lngObjektKopfID As Long) As Long
    Dim xlApp As Object
    Dim xlWb As Object
    Dim xlWs As Object
    Dim db As DAO.Database
    Dim strSQL As String
    Dim i As Long
    Dim lngCount As Long
    Dim lngSort As Long
    
    Dim strGruppe As String
    Dim strInfo As String
    Dim strGeschlecht As String
    Dim lngAnzahl As Long
    Dim dtRelBeginn As Variant
    
    On Error GoTo ErrHandler
    
    Set db = CurrentDb
    Set xlApp = CreateObject("Excel.Application")
    xlApp.Visible = False
    xlApp.DisplayAlerts = False
    
    Set xlWb = xlApp.Workbooks.Open(strFilePath, ReadOnly:=True)
    Set xlWs = xlWb.Worksheets(1)
    
    If MsgBox("Bestehende Positionen fuer dieses Objekt loeschen?", vbYesNo + vbQuestion) = vbYes Then
        db.Execute "DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjektKopfID
    End If
    
    lngSort = 0
    lngCount = 0
    
    For i = 5 To xlWs.UsedRange.rows.Count
        strGruppe = Trim(Nz(xlWs.Cells(i, 3).Value, ""))
        
        If Len(strGruppe) > 0 And LCase(strGruppe) <> "gesamt" And LCase(strGruppe) <> "summe" Then
            lngSort = lngSort + 1
            
            lngAnzahl = Nz(xlWs.Cells(i, 2).Value, 0)
            If Not IsNumeric(lngAnzahl) Then lngAnzahl = 0
            
            strInfo = Trim(Nz(xlWs.Cells(i, 5).Value, ""))
            
            strGeschlecht = ""
            If InStr(1, strInfo, "m +", vbTextCompare) > 0 Or InStr(1, strInfo, "x m", vbTextCompare) > 0 Then
                strGeschlecht = "m/w"
            ElseIf InStr(1, strInfo, " m", vbTextCompare) > 0 Then
                strGeschlecht = "m"
            ElseIf InStr(1, strInfo, " w", vbTextCompare) > 0 Then
                strGeschlecht = "w"
            End If
            
            dtRelBeginn = Null
            Dim col As Long
            For col = 6 To 12
                If IsNumeric(xlWs.Cells(i, col).Value) Then
                    If xlWs.Cells(i, col).Value > 0 Then
                        If IsDate(xlWs.Cells(4, col).Value) Then
                            dtRelBeginn = xlWs.Cells(4, col).Value
                            Exit For
                        End If
                    End If
                End If
            Next col
            
            strGruppe = Replace(strGruppe, "'", "''")
            strInfo = Replace(strInfo, "'", "''")
            
            strSQL = "INSERT INTO tbl_OB_Objekt_Positionen " & _
                    "(OB_Objekt_Kopf_ID, Sort, Gruppe, Zusatztext, Geschlecht, Anzahl, Rel_Beginn) " & _
                    "VALUES (" & lngObjektKopfID & ", " & lngSort & ", '" & strGruppe & "', '" & strInfo & "', '" & strGeschlecht & "', " & lngAnzahl
            
            If IsNull(dtRelBeginn) Then
                strSQL = strSQL & ", Null)"
            Else
                strSQL = strSQL & ", #" & Format(dtRelBeginn, "HH:NN:SS") & "#)"
            End If
            
            db.Execute strSQL
            lngCount = lngCount + 1
        End If
    Next i
    
    xlWb.Close False
    xlApp.Quit
    
    Set xlWs = Nothing
    Set xlWb = Nothing
    Set xlApp = Nothing
    Set db = Nothing
    
    ImportOrdnerkonzeptExcel = lngCount
    MsgBox lngCount & " Positionen importiert!", vbInformation
    Exit Function
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
    On Error Resume Next
    xlWb.Close False
    xlApp.Quit
    ImportOrdnerkonzeptExcel = -1
End Function