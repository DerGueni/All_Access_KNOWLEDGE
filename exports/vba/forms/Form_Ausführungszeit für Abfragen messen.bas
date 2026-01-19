VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_Ausführungszeit für Abfragen messen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database   'Verwenden der Datenbank-Sortierreihenfolge beim Vergleich von Zeichenfolgen.
Option Explicit

Private Sub btnMessen_Click()
    Dim x$, r As Variant

    On Error Resume Next
    x$ = lstQueryDefs
    If Err <> 0 Then Exit Sub
    
    r = MeasureQuery(x$)
End Sub

Private Sub Form_Load()
    Dim db As DAO.Database
    Dim rs As Recordset
    Dim i%, x$


    Set db = CurrentDb()
    x$ = ""
    For i = 0 To db.QueryDefs.Count - 1
        DoEvents
        x$ = x$ + db.QueryDefs(i).Name + ";"
    Next i
    lstQueryDefs.RowSource = x$
    
End Sub

Private Sub lstQueryDefs_DblClick(Cancel As Integer)
    btnMessen_Click
End Sub

