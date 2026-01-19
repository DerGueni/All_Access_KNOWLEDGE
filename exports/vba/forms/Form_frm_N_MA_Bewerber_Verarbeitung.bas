VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_N_MA_Bewerber_Verarbeitung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' =========================================================================
' Code für: frm_N_MA_Bewerber_Verarbeitung
' HINWEIS: Dieses Formular muss erst erstellt werden
' =========================================================================

'Private Sub btn_Verarbeiten_Click()
'    Dim lngMA_ID As Long
'    lngMA_ID = Verarbeite_Bewerber(Me.ID)
'
'    If lngMA_ID > 0 Then
'        ' Erfolgreich - Mitarbeiter-Stammblatt öffnen
'        DoCmd.OpenForm "frm_MA_Mitarbeiterstamm", , , "ID=" & lngMA_ID
'        DoCmd.Close acForm, Me.Name
'    End If
'End Sub
'
Private Sub btn_Abbrechen_Click()
    DoCmd.Close acForm, Me.Name
End Sub

'Private Sub Form_Current()
'    ' Status anzeigen
'    If Not IsNull(Me.Verarbeitet) And Me.Verarbeitet = "Ja" Then
'        Me.btn_Verarbeiten.Enabled = False
'        Me.btn_Verarbeiten.caption = "Bereits verarbeitet"
'    Else
'        Me.btn_Verarbeiten.Enabled = True
'        Me.btn_Verarbeiten.caption = "Mitarbeiter anlegen"
'    End If
'End Sub

