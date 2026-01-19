Option Compare Database
Option Explicit


' Fallback-Konstanten (sicher, falls in deiner Umgebung nicht vorhanden)
Private Const CT_CUSTOMCONTROL As Long = 119   ' acCustomControl (ActiveX)
Private Const CT_WEBBROWSER   As Long = 128    ' acWebBrowser (IE WebBrowser)
Private Const CT_EDGEBROWSER  As Long = 134    ' acEdgeBrowser (Edge Browser Control)

Public Sub ScanFormsForBrowserControls()
    Dim ao As AccessObject
    Dim frm As Form
    Dim ctl As control

    For Each ao In CurrentProject.AllForms
        DoCmd.OpenForm ao.Name, acDesign, , , , acHidden
        Set frm = forms(ao.Name)

        For Each ctl In frm.Controls
            Select Case ctl.ControlType
                Case CT_WEBBROWSER
                    Debug.Print ao.Name & " | WebBrowser (IE): " & ctl.Name

                Case CT_EDGEBROWSER
                    Debug.Print ao.Name & " | EdgeBrowser: " & ctl.Name

                Case CT_CUSTOMCONTROL
                    Debug.Print ao.Name & " | Custom/ActiveX: " & ctl.Name & _
                                " | Class=" & Nz(ctl.Class, "")
            End Select
        Next ctl

        DoCmd.Close acForm, ao.Name, acSaveNo
    Next ao

    MsgBox "Scan abgeschlossen – Ergebnis im Direktfenster (Strg+G)."
End Sub