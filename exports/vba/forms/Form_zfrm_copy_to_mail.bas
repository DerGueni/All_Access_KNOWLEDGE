VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_copy_to_mail"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

'Listbox leeren
Private Sub btnClearListbox_Click()
    clear_listbox
End Sub

'Zwischenablage
Private Sub btnClipboard_DblClick(Cancel As Integer)

Dim objClip As New MSForms.DataObject
Dim Text    As String

    Text = collect_email()
    
    objClip.SetText Text
    objClip.PutInClipboard

End Sub
 
'Neue Mail
Private Sub btnMailBCC_DblClick(Cancel As Integer)

Dim oApp    As Object, Status&
Dim oMail   As Object
Dim BCC     As String

On Error Resume Next
    
    BCC = collect_email()
    
    Set oApp = GetObject(, "Outlook.Application")
    If oApp Is Nothing Then Status = Shell("Outlook.exe", 1)
    
    Set oMail = oApp.CreateItem(0)
    
    With oMail
       '.TO = "deinname@deinedomain.de"
       .BCC = BCC
       '.Subject = "Hier könnte Ihre Werbung stehen"
       '.Body = "Ihre Nachricht."
       .Display        'Erstellt die Email und öffnet diese. Der Versand erfolgt anschließend manuell vom User!
    End With

    Set oApp = Nothing
    Set oMail = Nothing
    
End Sub


Private Sub Form_Load()
    clear_listbox
End Sub

'Hinzufügen, Entfernen
Public Function add_remove(arr As Variant)

Dim i As Integer

    i = in_listbox(arr(0, 0))
    
    If i = -1 Then
        Me.lstEmpfaenger.AddItem arr(0, 0) & ";" & arr(0, 1)
    Else
        Me.lstEmpfaenger.RemoveItem (i)
    End If

End Function

'Eintrag entfernen Doppelklick
Private Sub lstEmpfaenger_DblClick(Cancel As Integer)
    Me.lstEmpfaenger.RemoveItem listbox_selected
End Sub

'Listbox leeren
Function clear_listbox()
Dim i As Integer

    For i = Me.lstEmpfaenger.ListCount - 1 To 0 Step -1
        Me.lstEmpfaenger.RemoveItem i
    Next i
    
End Function

'Eintrag in Listbox vorhanden?
Function in_listbox(ByVal Name As String) As Integer

Dim i As Integer

    For i = 0 To Me.lstEmpfaenger.ListCount
        If InStr(Name, Me.lstEmpfaenger.ItemData(i)) Then
            in_listbox = i
            Exit Function
        End If
    Next i

    in_listbox = -1
    
End Function


'Eintrag in Listbox selektiert?
Function listbox_selected() As Integer

Dim i As Integer

    For i = 0 To Me.lstEmpfaenger.ListCount
        If Me.lstEmpfaenger.selected(i) = -1 Then
             listbox_selected = i
            Exit For
        End If
    Next i

End Function


'Mailadressen zusammenfassen
Function collect_email() As String

Dim i As Integer

    collect_email = Me.lstEmpfaenger.Column(1, 0)
    For i = 1 To Me.lstEmpfaenger.ListCount
        collect_email = collect_email & "; " & Me.lstEmpfaenger.Column(1, i)
    Next i
    
End Function
