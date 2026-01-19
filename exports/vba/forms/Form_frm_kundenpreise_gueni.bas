VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_kundenpreise_gueni"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub Sicherheitspersonal_DblClick(Cancel As Integer)
    Call open_KDStamm(1)
End Sub

Private Sub Sonntagszuschlag_DblClick(Cancel As Integer)
    Call open_KDStamm(12)
End Sub

Private Sub Sonstiges_DblClick(Cancel As Integer)
    Call open_KDStamm(5)
End Sub

Private Sub Fahrtkosten_DblClick(Cancel As Integer)
    Call open_KDStamm(4)
End Sub

Private Sub Feiertagszuschlag_DblClick(Cancel As Integer)
    Call open_KDStamm(13)
End Sub

Private Sub Leitungspersonal_DblClick(Cancel As Integer)
    Call open_KDStamm(3)
End Sub

Private Sub Nachtzuschlag_DblClick(Cancel As Integer)
    Call open_KDStamm(11)
End Sub


Function open_KDStamm(Optional PreisArt_ID As Integer)

Dim frm As String
Dim i   As Long
Dim rs  As Recordset

On Error GoTo Err

    frm = "frm_KD_Kundenstamm"
    
    'If Not fctIsFormOpen(frm) Then 'nicht notwendig
    DoCmd.OpenForm frm, acNormal, , "kun_ID = " & Me.kun_ID
    Forms(frm).Controls("RegStammKunde") = 1
    Call Forms(frm).Standardleistungen_anlegen(Me.kun_ID)
    
'  Listbox markieren
    With Forms(frm).Controls("lst_KD")
        For i = 1 To .ListCount - 1
'        Debug.Print Me.kun_ID
'        Debug.Print CInt(.Column(0, i))
          If CInt(.Column(0, i)) = Me.kun_ID Then
             .selected(i) = True
          Else
             .selected(i) = False
          End If
        Next
    End With
    
    'Feld auswählen
    If PreisArt_ID <> 0 Then
    
        'Datensatz suchen
        Set rs = Forms(frm).Controls("sub_KD_Standardpreise").Form.Recordset
            rs.FindFirst ("Preisart_ID = " & PreisArt_ID)
        Set rs = Nothing
        
        'Spalte mit Preis markieren
        Forms(frm).Controls("sub_KD_Standardpreise").Form.SelLeft = 4
    
        'SelLeft: Index der Spalte des ersten markierten Elements
        'SelWidth: Anzahl der markierten Spalten
        'SelTop: Index der Zeile des ersten markierten Elements
        'SelHeight: Anzahl der markierten Spalten
        
    End If

    Exit Function

Err:
    MsgBox "Funktion nicht möglich!", vbCritical
    
End Function

