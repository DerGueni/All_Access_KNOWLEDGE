VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_XL_Eport_Auftrag"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnExport_Click()

Dim strPfad As String
Dim strDateiname As String
Dim strDateinamePfad As String
Dim strDateinamePfad_Alt As String
Dim ID As Long
Dim iAnzZeiten As Long

If Len(Trim(Nz(cboVA_UD.Column(1)))) = 0 Then
    MsgBox "Bitte erst Auftrag / Dateiname auswählen"
    Exit Sub
End If
If Len(Trim(Nz(Me!strPfad))) = 0 Then
    MsgBox "Bitte erst Zielpfad auswählen"
    Exit Sub
End If



ID = cboVA_UD.Column(0)
strPfad = Nz(Me!strPfad)
strDateiname = Nz(cboVA_UD.Column(1))
strDateinamePfad = strPfad & strDateiname
strDateinamePfad_Alt = Left(strDateinamePfad, Len(strDateinamePfad) - 1)

iAnzZeiten = Nz(TCount("*", "tbl_VA_Start", "VA_ID = " & ID), 0)
If iAnzZeiten > 3 Then
    If vbCancel = MsgBox("Beim Export nach Excel gehen Schichten verloren, Abbruch", vbCritical + vbOKCancel, "Mehr als 3 Schichten") Then
        Exit Sub
    End If
End If

If Me!IstAutoOvrwrite = True Then
    If File_exist(strDateinamePfad) Then Kill strDateinamePfad
    If File_exist(strDateinamePfad_Alt) Then Kill strDateinamePfad_Alt
Else
    If File_exist(strDateinamePfad_Alt) Or File_exist(strDateinamePfad) Then
        If vbYes = MsgBox("Datei existiert, überschreiben", vbQuestion + vbYesNo, strDateiname) Then
            If File_exist(strDateinamePfad) Then Kill strDateinamePfad
            If File_exist(strDateinamePfad_Alt) Then Kill strDateinamePfad_Alt
        End If
    Else
        Exit Sub
    End If
End If

DoCmd.Close acForm, Me.Name, acSaveNo

Call fXL_Export_Auftrag(ID, strPfad, strDateiname)

End Sub

Private Sub btnPfadsuche_Click()
Dim s As String

s = Folder_Such("Folder für Speicherung der Excel-Aufträge")
If Len(Trim(Nz(s))) > 0 Then
    If Right(s, 1) <> "\" Then s = s & "\"
    Me!strPfad = s
    Call Set_Priv_Property("prp_XL_Exportpfad_Auftrag", s)
    DoEvents
End If

End Sub

Private Sub Form_Open(Cancel As Integer)
Me!strPfad = Get_Priv_Property("prp_XL_Exportpfad_Auftrag")
If Not Dir_Exist(Nz(Me!strPfad)) Then Me!strPfad = ""
End Sub
