VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_tbl_Info_zu Abfragen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Abfragename_DblClick(Cancel As Integer)
Call doOpen_Qry(Me!Abfragetyp, Me!Abfragename)
End Sub

Private Sub Abfragetyp_DblClick(Cancel As Integer)
Call doOpen_Qry(Me!Abfragetyp, Me!Abfragename)
End Sub

Private Sub Bmerkung_DblClick(Cancel As Integer)
Call doOpen_Qry(Me!Abfragetyp, Me!Abfragename)
End Sub


Function doOpen_Qry(typ As String, qryName As String)
Dim isOK As Boolean
Dim Opennr As Long

isOK = True
If typ = "UPDATE" Then
    If vbOK = MsgBox("Diese Abfrage wird Daten ändern, wollen Sie das wirklich ?", vbQuestion + vbOKCancel, qryName) Then
        isOK = True
    Else
        isOK = False
    End If
ElseIf typ = "SELECT" Then
    DoCmd.OpenForm "_frmHlp_qryClose", acNormal, , , , , qryName
End If

If isOK Then
    DoCmd.OpenQuery qryName, acViewNormal
End If
    
End Function
