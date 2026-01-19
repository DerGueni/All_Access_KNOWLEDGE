Option Compare Database
Option Explicit

Global Gl_MATag_AktDatum As Date
Global Gl_Akt_MA_ID As Long
Global GL_Verpl_Uebername As Boolean

Global Gl_Akt_KD_ID As Long
Global GL_ihatFocus As Long

Global GL_DP_Objekt_Fld As String
Global GL_DP_MA_Fld As String

Global GL_lngPos As Long
Global GL_XL_MehrfachTabs As Variant

' =====================================================
' HTML-FORMULAR ÖFFNER (eingefügt am 29.12.2025)
' =====================================================
Public Function OpenMA_HTML(Optional ID As Variant) As Boolean
    Dim url As String
    url = "file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/mitarbeiterverwaltung/frm_N_MA_Mitarbeiterstamm_V2.html"
    If Not IsMissing(ID) Then url = url & "?id=" & ID
    Shell "cmd /c start """" """ & url & """", vbHide
    OpenMA_HTML = True
End Function

Public Function OpenKD_HTML(Optional ID As Variant) As Boolean
    Dim url As String
    url = "file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/kundenverwaltung/frm_N_KD_Kundenstamm.html"
    If Not IsMissing(ID) Then url = url & "?id=" & ID
    Shell "cmd /c start """" """ & url & """", vbHide
    OpenKD_HTML = True
End Function

Public Function OpenVA_HTML(Optional ID As Variant) As Boolean
    Dim url As String
    url = "file:///C:/Users/guenther.siegert/Documents/0006_All_Access_KNOWLEDGE/04_HTML_Forms/forms/auftragsverwaltung/frm_N_VA_Auftragstamm.html"
    If Not IsMissing(ID) Then url = url & "?id=" & ID
    Shell "cmd /c start """" """ & url & """", vbHide
    OpenVA_HTML = True
End Function