VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_Rch_Kopf_simple"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Dateiname_DblClick(Cancel As Integer)


Dim Datei As String

On Error GoTo Err


    Application.FollowHyperlink Me!Dateiname
    
Ende:
    Exit Sub
Err:
    Datei = Dateiauswahl("Rechnung auswählen", "*.pdf,*.doc,*.docx", CONSYS & "CONSEC\CONSEC PLANUNG AKTUELL\A  - Eingangsrechnungen\")
    If Datei <> "" Then Me.Dateiname = Datei
    Resume Ende
    
End Sub

