Attribute VB_Name = "Modul22"
'Option Compare Database
'Option Explicit
'
'Sub RenameDistanceKmInGeocoding()
'    Dim comp As Object
'    Dim i As Long
'    Dim lineText As String
'
'    Set comp = Application.vbe.ActiveVBProject.VBComponents("mdl_Geocoding")
'
'    For i = 1 To comp.codeModule.CountOfLines
'        lineText = comp.codeModule.lines(i, 1)
'        If InStr(lineText, "Function DistanceKm(") > 0 Then
'            comp.codeModule.ReplaceLine i, Replace(lineText, "Function DistanceKm(", "Function DistanceKm_OLD(")
'            Exit For
'        End If
'    Next i
'End Sub
