Attribute VB_Name = "mdl_N_ObjektFilter"
Option Compare Database
Option Explicit

' Modul fuer Objekt-Filterung und Suche

' Filtert das Objekt-Listenfeld nach Suchbegriff
Public Sub FilterObjektListe(frm As Form, strSuchbegriff As String)
    On Error Resume Next
    
    Dim strBaseSQL As String
    Dim strFilterSQL As String
    
    ' Basis-SQL fuer das Listenfeld (anpassen an tatsaechliche Struktur)
    strBaseSQL = "SELECT ID, ObjektNr, Bezeichnung FROM tbl_OB_Objekt"
    
    If Len(strSuchbegriff) > 0 Then
        strFilterSQL = strBaseSQL & " WHERE " & _
            "ObjektNr LIKE '*" & strSuchbegriff & "*' OR " & _
            "Bezeichnung LIKE '*" & strSuchbegriff & "*' OR " & _
            "Ort LIKE '*" & strSuchbegriff & "*' OR " & _
            "Strasse LIKE '*" & strSuchbegriff & "*'"
    Else
        strFilterSQL = strBaseSQL
    End If
    
    strFilterSQL = strFilterSQL & " ORDER BY ObjektNr"
    
    ' Aktualisiere Listenfeld
    frm!lstObjekte.RowSource = strFilterSQL
    frm!lstObjekte.Requery
End Sub

' Setzt Filter zurueck
Public Sub ResetObjektFilter(frm As Form)
    On Error Resume Next
    frm!txtSuche = ""
    FilterObjektListe frm, ""
End Sub

