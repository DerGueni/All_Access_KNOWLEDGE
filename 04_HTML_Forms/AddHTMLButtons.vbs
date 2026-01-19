' VBScript zum Hinzuf?gen von HTML-Buttons in Access-Formulare
' Ausf?hren: cscript AddHTMLButtons.vbs

Option Explicit

Dim accessApp, fePath
fePath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb"

On Error Resume Next

' Access starten
Set accessApp = CreateObject("Access.Application")
accessApp.Visible = True

' Datenbank ?ffnen
accessApp.OpenCurrentDatabase fePath

If Err.Number <> 0 Then
    WScript.Echo "Fehler beim ?ffnen: " & Err.Description
    WScript.Quit 1
End If

WScript.Echo "Datenbank ge?ffnet"

' VBA-Code direkt ausf?hren
Dim vbaCode
vbaCode = "Shell ""cmd /c start """""""" """"file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/mitarbeiterverwaltung/frm_N_MA_Mitarbeiterstamm_V2.html"""""", vbHide"

accessApp.DoCmd.RunCommand 14  ' Kompilieren

' ?ffne Direktfenster und f?hre Code aus
accessApp.DoCmd.OpenForm "frm_MA_Mitarbeiterstamm", 0  ' acNormal

WScript.Echo "Formular ge?ffnet - bitte manuell testen"

' Nicht beenden, damit Access offen bleibt
'accessApp.Quit

Set accessApp = Nothing
