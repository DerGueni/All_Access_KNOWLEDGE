VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Outlook_eMail_template"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnAttachSuch_Click()
Dim s As String
s = AlleSuch()
If Len(Trim(Nz(s))) = 0 Then Exit Sub
If Len(Trim(Nz(s))) > 0 Then
    CurrentDb.Execute ("INSERT INTO tbltmp_Attachfile ( Attachfile ) SELECT '" & s & "' AS Ausdr1 FROM _tblInternalSystemFE;")
    Me!sub_tbltmp_Attachfile.Form.Requery
End If
End Sub

Private Sub btnAttLoesch_Click()
CurrentDb.Execute ("DELETE * FROM tbltmp_Attachfile;")
Me!sub_tbltmp_Attachfile.Form.Requery
End Sub

Private Sub btnHilfe_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"
End Sub

Private Sub btnImgSuch_Click()
Dim s As String
    s = JPGSuch()
    If Len(Trim(Nz(s))) > 0 Then
        Me!Imagefile = s
    End If
End Sub

Private Sub Form_BeforeUpdate(Cancel As Integer)
If Me.Dirty Then
' Erstellt am / von = Standardwert
        
    Me!Aend_am = Now()
    Me!Aend_von = atCNames(1) ' Siehe bas_Sysinfo / fdlg_sysinfo
End If

End Sub

Private Sub Form_Load()
DoCmd.Maximize
End Sub

Private Sub Form_Open(Cancel As Integer)
Me!lbl_Datum.caption = Date
End Sub

Private Sub TextAls_AfterUpdate()
If Me!TextAls = 1 Then ' ASCII
    Me!Textinhalt.TextFormat = acTextFormatPlain
    Me!StartBild = ""
    Me!StartBild.Visible = False
    Me!btnImgSuch.Visible = False
Else ' HTML
    Me!Textinhalt.TextFormat = acTextFormatHTMLRichText
    Me!StartBild.Visible = True
    Me!btnImgSuch.Visible = True
End If

End Sub
