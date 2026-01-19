Option Compare Database
Option Explicit

'#######################################
' In Einem einfachen Sub Formular
'#######################################

'
' Dim myControl As Control
' Dim myTarget As Control
' Dim mySubTarget As Control
'
' Set myControl = Screen.ActiveForm.ActiveControl
'
'If myControl.ControlType = acSubform Then
'    Set myTarget = myControl.Form.ActiveControl
'Else
'    Set myTarget = myControl
'End If
'
'ctlname = myTarget.Name
'
'Debug.Print "-------"
'Debug.Print Mainformname
'Debug.Print SubformName
'Debug.Print Application.Screen.ActiveForm.ActiveControl.Form.Name
'Debug.Print ctlname
'Debug.Print "-------"
'

'#######################################
' In Einem SubSub Formular - z.B. wenn über allem das Navigationscontrol 'schwebt'
'#######################################

'        Set mycontrol = Screen.ActiveForm.ActiveControl
'
'        If mycontrol.ControlType = acSubform Then
'        'If TypeName(myControl) = "SubForm" Then
'            Set myTarget = mycontrol.Form.ActiveControl
'        Else
'            Set myTarget = mycontrol
'        End If
'        If myTarget.ControlType = acSubform Then
'            Set mySubTarget = myTarget.Form.ActiveControl
'        Else
'            Set mySubTarget = mycontrol
'        End If
'        ctlname = mySubTarget.Name