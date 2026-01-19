VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Report_rpt_Ausweis_Karte_Vorderseite"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Const frmHlp = "_frmHlp_rptClose"

Dim KARTENDRUCKER As String 'Papierformat: CR80 !


Private Sub Report_Load()

Dim repName As String
Dim strText As String

    KARTENDRUCKER = Get_Priv_Property("prp_Kartendrucker")
    repName = Me.Name
    
    If Me.Printer.DeviceName <> Application.Printers(KARTENDRUCKER).DeviceName Then
        strText = Me.OpenArgs
        If fctIsFormOpen(frmHlp) Then DoCmd.Close acForm, frmHlp, acSaveNo
        DoCmd.Close acReport, repName, acSaveNo
        'Querformat
        AusrichtungSetzen repName, False, KARTENDRUCKER
        'öffnen
        DoCmd.OpenReport repName, acViewReport, , , , strText
    End If

End Sub

Private Sub Report_Open(Cancel As Integer)

    Dim z() As String
    Dim zeile1 As String
    Dim zeile2 As String

    If Not IsNull(Me.OpenArgs) Then
        
        z = Split(Me.OpenArgs, "/")

        zeile1 = z(0)
        If UBound(z) > 0 Then zeile2 = z(1)
    
        Me.lbl_Typ_Personal.caption = zeile1
        Me.lbl_Zeile2.caption = zeile2
    
    End If
    

    'Hilfsformular
    If Not fctIsFormOpen(frmHlp) Then DoCmd.OpenForm frmHlp, , , , , , Me.Name
    
End Sub


Private Sub Report_Current()

    DoCmd.Maximize
    
End Sub


Private Sub Report_Close()
    
    If fctIsFormOpen(frmHlp) Then
        DoCmd.Close acForm, frmHlp, acSaveNo
    End If
    
End Sub

    Sub y(s As String)
   Dim i As Integer, z() As String
   
   z = Split(s, "/")
   For i = 0 To UBound(z)
      Debug.Print i, z(i)
   Next
End Sub
