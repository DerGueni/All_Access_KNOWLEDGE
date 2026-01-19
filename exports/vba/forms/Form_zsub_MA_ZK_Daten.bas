VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zsub_MA_ZK_Daten"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Private Sub Bemerkung_AfterUpdate()
    If Me.exportiert = False Then
        TUpdate "Bemerkung = '" & Me.Bemerkung & "'", "zqry_ZK_Stunden", "Kreuz_KEY = " & Me.Kreuz_KEY
        Me.gesperrt = True
        TUpdate "gesperrt = " & Me.gesperrt, "zqry_ZK_Stunden", "Kreuz_KEY = " & Me.Kreuz_KEY
        
    Else
        MsgBox "Datensatz bereits nach Lexware exportiert!" & _
            vbCrLf & "Änderungen werden nicht übernommen!"
            
    End If
    
End Sub


Private Sub gesperrt_AfterUpdate()

    If Me.exportiert = False Then
        TUpdate "gesperrt = " & Me.gesperrt, "zqry_ZK_Stunden", "Kreuz_KEY = " & Me.Kreuz_KEY
        
    Else
        MsgBox "Datensatz bereits nach Lexware exportiert!" & _
            vbCrLf & "Änderungen werden nicht übernommen!"
            
    End If
    
End Sub


Private Sub exportieren_AfterUpdate()

    If Me.exportiert = False Then
        TUpdate "exportieren = " & Me.exportieren, "zqry_ZK_Stunden", "Kreuz_KEY = " & Me.Kreuz_KEY
        
    Else
        MsgBox "Datensatz bereits nach Lexware exportiert!" & _
            vbCrLf & "Änderungen werden nicht übernommen!"
            
    End If
    
End Sub


'Details Einzelsatz
Private Sub Veranstaltung_DblClick(Cancel As Integer)

Dim frm     As String

    frm = "zfrm_ZUO_Stunden"
    If IsInitial(ZUO_ID) = False Then DoCmd.OpenForm frm, acNormal, , "ZUO_ID =" & Me.ZUO_ID
    If IsInitial(NV_ID) = False Then DoCmd.OpenForm frm, acNormal, , "NV_ID =" & Me.NV_ID
    frm = "zfrm_MA_ZK_Korrekturen"
    If IsInitial(Korr_ID) = False Then
        DoCmd.OpenForm frm, acNormal, , "ID =" & Me.Korr_ID
        Forms(frm).recordSource = "SELECT * FROM ztbl_MA_ZK_Korrekturen WHERE ID = " & Me.Korr_ID
    End If

End Sub
