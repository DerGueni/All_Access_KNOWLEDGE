VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frm_N_MA_Monatsuebersicht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' KOMPLETT-LÖSUNG für frm_N_MA_Monatsuebersicht
' Behebt: Spaltenbreiten + Fehlende Queries

Option Compare Database
Option Explicit

Private Sub Form_Load()
    Me.cboJahr = 2025
    Me.cboAnstellungsart = "Alle"
    Call Update_Datenquellen
End Sub

Private Sub cboJahr_AfterUpdate()
    Call Update_Datenquellen
End Sub

Private Sub cboAnstellungsart_AfterUpdate()
    Call Update_Datenquellen
End Sub

Private Sub Update_Datenquellen()
    ' Suffix basierend auf Anstellungsart
    Dim strJahr As String
    Dim strSuffix As String
    
    On Error Resume Next
    
    If IsNull(Me.cboJahr) Then Exit Sub
    strJahr = Me.cboJahr
    
    ' Suffix bestimmen
    Select Case Me.cboAnstellungsart
        Case "Festangestellte"
            strSuffix = "_Fest"
        Case "Minijobber"
            strSuffix = "_Mini"
        Case Else
            strSuffix = "_Final"
    End Select
    
    ' Queries direkt laden
    Me.subStunden.SourceObject = "Query.qry_KreuzTab_MA_Stunden_" & strJahr & strSuffix
    Me.subPrivat.SourceObject = "Query.qry_KreuzTab_Privat_" & strJahr & strSuffix
    Me.subUrlaub.SourceObject = "Query.qry_KreuzTab_Urlaub_" & strJahr & strSuffix
    Me.subKrank.SourceObject = "Query.qry_KreuzTab_Krank_" & strJahr & strSuffix
    
    ' Spaltenbreiten setzen NACH dem Laden
    DoEvents
    Call SetColumnWidths
    
    Me.Requery
    
End Sub

Private Sub SetColumnWidths()
    ' Spaltenbreiten für alle Unterformulare setzen
    On Error Resume Next
    
    ' Stunden Monat
    If Not IsNull(Me.subStunden.Form.recordSource) Then
        Call SetKreuztabelleBreiten(Me.subStunden.Form)
    End If
    
    ' Urlaub
    If Not IsNull(Me.subUrlaub.Form.recordSource) Then
        Call SetKreuztabelleBreiten(Me.subUrlaub.Form)
    End If
    
    ' Krank
    If Not IsNull(Me.subKrank.Form.recordSource) Then
        Call SetKreuztabelleBreiten(Me.subKrank.Form)
    End If
    
    ' Privat
    If Not IsNull(Me.subPrivat.Form.recordSource) Then
        Call SetKreuztabelleBreiten(Me.subPrivat.Form)
    End If
    
End Sub

Private Sub SetKreuztabelleBreiten(frm As Form)
    ' Setzt optimale Spaltenbreiten für Kreuztabellen
    Dim i As Integer
    
    On Error Resume Next
    
    ' Durchlaufe alle Controls im Formular
    For i = 0 To frm.Controls.Count - 1
        Dim ctrl As control
        Set ctrl = frm.Controls(i)
        
        If ctrl.ControlType = 109 Then  ' acTextBox
            Dim ctrlName As String
            ctrlName = ctrl.Name
            
            ' Mitarbeiter-Spalte
            If ctrlName = "Mitarbeiter" Or InStr(1, ctrlName, "Mitarbeiter", vbTextCompare) > 0 Then
                ctrl.ColumnWidth = 4500  ' Breiter für Namen
                
            ' Gesamt-Spalte
            ElseIf ctrlName = "Gesamt" Or InStr(1, ctrlName, "Gesamt", vbTextCompare) > 0 Then
                ctrl.ColumnWidth = 1800  ' Mittelbreit
                
            ' Monats-Spalten (Jan, Feb, Mrz, etc.)
            ElseIf Len(ctrlName) = 3 Or _
                   InStr(1, ctrlName, "Jan", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Feb", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Mrz", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Apr", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Mai", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Jun", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Jul", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Aug", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Sep", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Okt", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Nov", vbTextCompare) > 0 Or _
                   InStr(1, ctrlName, "Dez", vbTextCompare) > 0 Then
                ctrl.ColumnWidth = 1200  ' Schmal für Monate
            End If
        End If
    Next i
    
End Sub

' Alternative: Spaltenbreiten über Formular-Ereignis
Private Sub subStunden_Enter()
    On Error Resume Next
    Call SetKreuztabelleBreiten(Me.subStunden.Form)
End Sub

Private Sub subUrlaub_Enter()
    On Error Resume Next
    Call SetKreuztabelleBreiten(Me.subUrlaub.Form)
End Sub

Private Sub subKrank_Enter()
    On Error Resume Next
    Call SetKreuztabelleBreiten(Me.subKrank.Form)
End Sub

Private Sub subPrivat_Enter()
    On Error Resume Next
    Call SetKreuztabelleBreiten(Me.subPrivat.Form)
End Sub


