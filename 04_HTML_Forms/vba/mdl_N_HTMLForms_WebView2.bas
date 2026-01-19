Attribute VB_Name = "mdl_N_HTMLForms_WebView2"
Option Compare Database
Option Explicit

Private Const HTML_BASE As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms\"

Public Sub OpenMitarbeiterstammHTML(Optional MA_ID As Long = 0)
    Dim wf As Object
    Dim htmlPath As String
    Dim jsonData As String
    
    htmlPath = HTML_BASE & "mitarbeiterverwaltung\frm_N_MA_Mitarbeiterstamm_V2.html"
    
    Set wf = CreateObject("ConsysWebView2.WebFormHost")
    
    If MA_ID > 0 Then
        jsonData = LoadMitarbeiterstammJSON(MA_ID)
    Else
        jsonData = "{""type"":""mitarbeiter""}"
    End If
    
    wf.ShowFormWithData htmlPath, "Mitarbeiterstamm", 1400, 900, jsonData
End Sub

Private Function LoadMitarbeiterstammJSON(MA_ID As Long) As String
    Dim rs As DAO.Recordset
    Dim json As String
    
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & MA_ID)
    
    If Not rs.EOF Then
        json = "{""type"":""mitarbeiter"",""stammdaten"":{"
        json = json & """id"":" & rs!ID & ","
        json = json & """nachname"":""" & Nz(rs!Nachname, "") & ""","
        json = json & """vorname"":""" & Nz(rs!Vorname, "") & ""","
        json = json & """strasse"":""" & Nz(rs!Strasse, "") & ""","
        json = json & """plz"":""" & Nz(rs!PLZ, "") & ""","
        json = json & """ort"":""" & Nz(rs!Ort, "") & ""","
        json = json & """telMobil"":""" & Nz(rs!Tel_Mobil, "") & ""","
        json = json & """email"":""" & Nz(rs!Email, "") & ""","
        json = json & """istAktiv"":" & IIf(Nz(rs!IstAktiv, False), "true", "false")
        json = json & "}}"
    Else
        json = "{""error"":""nicht gefunden""}"
    End If
    
    rs.Close
    LoadMitarbeiterstammJSON = json
End Function
