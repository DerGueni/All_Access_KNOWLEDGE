VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zsub_ZK_Lohnarten_Zuschlag_Detail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub btnNeu_Click()


Dim DatumAb  As String
Dim DatumVon As Date
Dim tbl      As String
Dim sql      As String
Dim rs       As Recordset
Dim WHERE    As String
    
    
    DatumAb = InputBox("Gültig ab: ", "Neuer Gültigkeitszeitraum")
    
    If IsDate(DatumAb) Then
    
        DatumVon = DatumAb
        
        tbl = "ztbl_ZK_Stundensatz"
        WHERE = "Lohnart_ID = " & Me.ID & " AND DatumBis = " & datumSQL("31.12.9999")
    
        'aktuell Datensatz kopieren
        sql = "INSERT INTO " & tbl & " SELECT * FROM " & tbl & " WHERE " & WHERE
        CurrentDb.Execute sql, dbFailOnError
        
        Me.Requery
        
        'Neue Gültigkeiten setzen
        Set rs = Me.RecordsetClone
        
        Do
            If rs.fields("DatumBis") = "31.12.9999" Then
                rs.Edit
                rs.fields("DatumBis") = DatumVon - 1
                rs.update
                rs.MoveLast
            End If
            rs.MoveNext
        Loop Until rs.EOF
        
        rs.MoveFirst
        Do
            If rs.fields("DatumBis") = "31.12.9999" Then
                rs.Edit
                rs.fields("DatumVon") = DatumVon
                rs.update
                rs.MoveLast
            End If
            rs.MoveNext
        Loop Until rs.EOF
        
        rs.Close
        Set rs = Nothing
        
        Me.Requery
        Me.Parent.zsub_ZK_Lohnarten_Zuschlag.Form.Requery
    
    Else
        
        MsgBox "Eingabe ist kein gültiges Datum", vbCritical
        
    End If
    
End Sub

