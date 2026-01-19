VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_Datensatzlöschungen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub btnDone_Click()

  On Error Resume Next
  DoCmd.Close acForm, Me.Name, acSavePrompt
  
End Sub

Private Sub Form_Load()
  Dim strDB As String
  Dim strSQL As String
  
  strDB = CurrentDb.Name
  strSQL = "select * from Protokoll where [pDatenbank]= '" & _
           strDB & "' and [pFeldName]= 'Datensatzlöschung!' " & _
           "ORDER BY pFormularName, pGeaendertAm DESC;"
  
  Me.recordSource = strSQL
  
End Sub

