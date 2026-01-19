Attribute VB_Name = "mod_N_Test_Simple"
Option Compare Database
Option Explicit


Public Function Test_Export_Simple(VA_ID As Long) As String
    On Error GoTo ErrorHandler
    
    Dim strAuftrag As String
    strAuftrag = Nz(DLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID), "Nicht gefunden")
    
    Test_Export_Simple = "OK: " & strAuftrag
    Exit Function
    
ErrorHandler:
    Test_Export_Simple = "Fehler: " & Err.description
End Function

