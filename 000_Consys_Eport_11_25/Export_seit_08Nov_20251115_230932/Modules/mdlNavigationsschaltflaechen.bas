Option Compare Database
Option Explicit

Public Sub NavigationssteuerelementAnalysieren()
    FormularAnalysieren "frmNavigationssteuerelement"
End Sub

Public Sub LayoutGestapeltAnalysieren()
    FormularAnalysieren "frmLayoutGestapelt"
End Sub


Public Function FormularAnalysieren(strForm As String)
    Dim frm As Form
    Dim ctl As control
    Dim prp As Property
    DoCmd.OpenForm strForm, acDesign
    Set frm = Forms(strForm)
If SeqZeileAppendOutputOpen("C:\Test\Hugo.txt", True) Then
        For Each ctl In frm.Controls
     '       Debug.Print ctl.Name, TypeName(ctl)
            Call SeqZeileAppendOutputZeile(ctl.Name & " - " & TypeName(ctl))
            If TypeName(ctl) = "NavigationControl" Or ctl.Name = "Navigationsunterformular" Then
                For Each prp In ctl.Properties
                     Call SeqZeileAppendOutputZeile("    " & prp.Name & "   - " & prp.Value)
'                   Debug.Print "  " & prp.Name, prp.Value
                Next prp
            End If
        Next ctl
    Call SeqZeileAppendOutputClose
End If

End Function


'If SeqZeileAppendOutputOpen("C:\Hugo.txt", True) Then
'    Call SeqZeileAppendOutputZeile("Hallo Hallo 111")
'    Call SeqZeileAppendOutputZeile("Hallo Hallo 222")
'    Call SeqZeileAppendOutputZeile("Hallo Hallo 333")
'    Call SeqZeileAppendOutputZeile("Hallo Hallo 444")
'    Call SeqZeileAppendOutputClose
'End If

Public Sub FormularErstellen()
    Dim frm As Form
    Dim strForm As String
    Dim ctlNavigation As NavigationControl
    Dim ctlSubnavigation As NavigationControl
    Dim ctlButton As NavigationButton
    strForm = "frmNaviPerVBA"
    NeuesFormular strForm
    DoCmd.OpenForm strForm, acDesign
    Set frm = Forms(strForm)
    Set ctlNavigation = Application.CreateControl(strForm, acNavigationControl, acDetail)
    ctlNavigation.Name = "nav"
    Set ctlSubnavigation = Application.CreateControl(strForm, acNavigationControl, acDetail)
    ctlSubnavigation.Name = "navSub"
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlNavigation.Name)
    With ctlButton
        .Name = "nab1"
        .caption = "Button 1"
    End With
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlSubnavigation.Name)
    With ctlButton
        .Name = "nab11"
        .caption = "Button 1-1"
    End With
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlSubnavigation.Name)
    With ctlButton
        .Name = "nab12"
        .caption = "Button 1-2"
    End With
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlNavigation.Name)
    With ctlButton
        .Name = "nab2"
        .caption = "Button 2"
    End With
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlSubnavigation.Name)
    With ctlButton
        .Name = "nab21"
        .caption = "Button 2-1"
    End With
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlSubnavigation.Name)
    With ctlButton
        .Name = "nab22"
        .caption = "Button 2-2"
    End With
    DoCmd.Close acForm, strForm, acSaveYes
End Sub

Public Function NeuesFormular(strForm As String)
    Dim strFormTemp As String
    Dim frm As Form
    On Error Resume Next
    DoCmd.Close acForm, strForm
    DoCmd.DeleteObject acForm, strForm
    On Error GoTo 0
    Set frm = Application.CreateForm
    strFormTemp = frm.Name
    DoCmd.Close acForm, frm.Name, acSaveYes
    DoCmd.Rename strForm, acForm, strFormTemp
End Function

Public Sub frmArtikelNachAlphabetErstellen()
    Dim strForm As String
    Dim ctlNavigation As NavigationControl
    Dim ctlButton As NavigationButton
    Dim i As Integer
    Dim strBuchstabe As String
    strForm = "frmArtikelNachAlphabet"
    NeuesFormular strForm
    DoCmd.OpenForm strForm, acDesign
    Set ctlNavigation = Application.CreateControl(strForm, acNavigationControl, acDetail)
    ctlNavigation.Name = "navArtikel"
    Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlNavigation.Name)
    With ctlButton
        .Name = "nabAlle"
        .caption = "Alle"
        .width = 750
        .NavigationTargetName = "frmArtikel"
        .NavigationWhereClause = ""
    End With
    For i = 1 To 26
        strBuchstabe = Chr(64 + i)
        Set ctlButton = Application.CreateControl(strForm, acNavigationButton, acDetail, ctlNavigation.Name)
        With ctlButton
            .Name = "nab" & strBuchstabe
            .caption = strBuchstabe
            .width = 250
            .NavigationTargetName = "frmArtikel"
            .NavigationWhereClause = "Artikelname LIKE '" & strBuchstabe & "*'"
        End With
    Next i
    DoCmd.Close acForm, strForm, acSaveYes
End Sub