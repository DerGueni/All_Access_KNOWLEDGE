VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_XL_Import_Check"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnImport_Click()
Dim s As String
Dim bExists As Boolean

    bExists = Me!bExists
    s = Me.Name
    
    DoCmd.Close acForm, s, acSaveNo
    Import_Teil2 ID, bExists
End Sub
