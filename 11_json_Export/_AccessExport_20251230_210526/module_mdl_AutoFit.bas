Option Compare Database
Option Explicit

Sub AutoFit_Unterformular_Spalten()
    Dim frm As Form
    Dim subFrm As Form
    Dim ctl As control
    Dim i As Integer
    
    ' Formular öffnen
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht", acNormal
    Set frm = forms("frm_N_MA_Monatsuebersicht")
    
    ' Array mit Unterformular-Namen
    Dim arrSubforms As Variant
    arrSubforms = Array("subStunden", "subPrivat", "subUrlaub", "subKrank")
    
    ' Array mit Monatsnamen und Gesamt
    Dim arrSpalten As Variant
    arrSpalten = Array("Jan", "Feb", "Mrz", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez", "Gesamt")
    
    ' Für jedes Unterformular
    Dim subName As Variant
    For Each subName In arrSubforms
        On Error Resume Next
        Set subFrm = frm.Controls(subName).Form
        
        If Not subFrm Is Nothing Then
            ' Für jede Spalte AutoFit setzen
            Dim spalte As Variant
            For Each spalte In arrSpalten
                Set ctl = subFrm.Controls(spalte)
                If Not ctl Is Nothing Then
                    ctl.ColumnWidth = -2  ' AutoFit
                End If
            Next spalte
            
            Debug.Print "? " & subName & " - Spalten auf AutoFit gesetzt"
        End If
        On Error GoTo 0
    Next subName
    
    ' Formular neu laden damit Änderungen sichtbar werden
    DoCmd.Close acForm, "frm_N_MA_Monatsuebersicht", acSaveYes
    DoCmd.OpenForm "frm_N_MA_Monatsuebersicht"
    
    MsgBox "Spaltenbreiten auf AutoFit gesetzt!" & vbCrLf & _
           "Alle Unterformulare behalten ihre Größe.", vbInformation
End Sub