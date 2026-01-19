VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zsub_Stundenabgleich"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database


Private Sub Stunden_Consys_DblClick(Cancel As Integer)
    
Dim Form As String

    Form = "frm_MA_Mitarbeiterstamm"
    DoCmd.OpenForm Form, , , "ID = " & Me.ID
    DoCmd.GoToControl "pgAuftrUeb"
    'Forms(form).reg_MA.pgAuftrUeb.Select
    'Forms(form).reg_MA.Pages("pgAuftrUeb").Select
End Sub


Private Sub Stunden_ZK_abger_DblClick(Cancel As Integer)
    Call ZK_oeffnen
End Sub

Private Sub Stunden_ZK_ges_DblClick(Cancel As Integer)
    Call ZK_oeffnen
End Sub

Private Sub SummevonWert_DblClick(Cancel As Integer)
    Call ZK_oeffnen
End Sub


'Zeitkonto öffnen
Function ZK_oeffnen()

Dim xlApp As Object, xlWb As Object
Dim fso As New Scripting.FileSystemObject
Dim fol As folder
Dim Fil As file
Dim PfadZeitkonten As String
Dim Name As String
Dim Monat As Integer
Const xlMaximized As Long = -4137&

On Error GoTo Err

    PfadZeitkonten = PfadZK
    
    'Wenn Pfad nicht existiert -> letztes Jahr
    If Dir(PfadZeitkonten, vbDirectory) = "" Then PfadZeitkonten = PfadZuBerechnen & Year(Date) - 1 & " Zeitkonten"
    
    'Wenn Pfad nicht existiert -> Fehler
    If Dir(PfadZeitkonten, vbDirectory) = "" Then Err.Raise 76, , PfadZeitkonten & vbCrLf & " nicht gefunden!"
    
    Name = Me.Controls("Name")
    
    Set fol = fso.GetFolder(PfadZeitkonten)
    
    'Zeitkonto suchen
    For Each Fil In fol.files
        If InStr(UCase(Fil.Name), UCase(Name)) <> 0 Then
            Set xlApp = CreateObject("Excel.Application")
            xlApp.Visible = True
            Set xlWb = xlApp.Workbooks.Open(Fil.path, , False)
            
       With xlApp
    .WindowState = xlMaximized
    
    End With
     
            Exit For
        End If
    Next Fil
    
    'Zeitkonto nicht gefunden
    If xlApp Is Nothing Then Err.Raise 76, , "Zeitkonto   " & Name & "   nicht gefunden!"

    'Monat im Zeitkonto selektieren
    If Not IsNull(Me.Datum) Then
        Monat = Mid(Me.Datum, 4, 2)
        xlWb.Sheets(Monat).Select
    End If
    
    
Ende:
    Set xlApp = Nothing
    Set xlWb = Nothing
    Exit Function
Err:
    MsgBox Err.Number & " " & Err.description, vbCritical
    Resume Ende
End Function
