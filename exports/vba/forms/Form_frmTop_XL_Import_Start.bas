VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_XL_Import_Start"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btn_Excel_Import_Click()

Dim ID As Long
Dim bExists As Boolean
Dim s As String
Dim i As Long
Dim isCheck As Boolean
Dim strSQL As String

isCheck = False

ID = Cons_XL_Import_Einzel(Me!Excel_Import)
s = Me.Name
bExists = (ID = Me!VA_ID)
Debug.Print ID, VA_ID

i = Nz(TLookup("Auftraggeber_ID", "tblZZZ_XL_Auftrag", "ID = " & ID), 0)
If i = 0 Then isCheck = True
i = Nz(TSum("MA_NZug", "tblZZZ_XL_Auftrag_MA_Einsatz", "ID = " & ID), 0)
If i > 0 Then isCheck = True

If isCheck = True Then
    DoCmd.OpenForm "frmTop_XL_Import_Check", , , "ID = " & ID
    Forms!frmTop_XL_Import_Check!bExists = bExists
    DoCmd.Close acForm, s, acSaveNo
Else
    DoCmd.Close acForm, s, acSaveNo
    Import_Teil2 ID, bExists
End If
End Sub

Private Sub btn_Excel_Such_Click()
Dim s As String

Dim sPath As String
Dim sFile As String

sPath = Get_Priv_Property("prp_Excel_Import_Pfad")

Dim i As Long

Me!VA_ID = 0
Me!sub_XL_Imp_Auftrag.Form.Requery
Me!Excel_Import = ""

s = XLSSuch(sPath)
If Len(Trim(Nz(s))) > 0 Then
    Me!Excel_Import = s
Else
    Exit Sub
End If

i = InStrRev(s, "\")
If i > 0 Then
    sPath = Left(s, i)
    sFile = Mid(s, i + 1)
    
    Call Set_Priv_Property("prp_Excel_Import_Pfad", sPath)
    
    Me!VA_ID = Nz(TLookup("ID", "tbl_VA_Auftragstamm", "Excel_Dateiname = '" & sFile & "'"), 0)
    Me!sub_XL_Imp_Auftrag.Form.Requery
End If
If Me!VA_ID > 0 Then
    Me!btn_Excel_Import.caption = "Re-Import"
Else
    Me!btn_Excel_Import.caption = "Neuer Import"
End If

End Sub
