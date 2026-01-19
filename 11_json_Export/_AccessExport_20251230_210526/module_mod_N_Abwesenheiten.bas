Option Compare Database
Option Explicit

Public Sub Verknuepfe_Monatsabwesenheit_Unterformulare()
    On Error GoTo Err_Handler
    
    Dim frm As Form
    Dim ctrl As control
    Dim strFormName As String
    Dim intUpdated As Integer
    
    strFormName = "frm_N_MA_Monatsuebersicht"
    intUpdated = 0
    
    Debug.Print "=== Verknüpfe Unterformulare für " & strFormName & " ==="
    
    ' Formular im Design-Modus öffnen
    DoCmd.OpenForm strFormName, acDesign
    Set frm = forms(strFormName)
    
    ' Durchlaufe alle Controls
    For Each ctrl In frm.Controls
        If ctrl.ControlType = acSubform Then
            Debug.Print "Unterformular gefunden: " & ctrl.Name & " (Quelle: " & ctrl.SourceObject & ")"
            
            ' Prüfe ob Quellobjekt gesetzt ist
            If Len(ctrl.SourceObject) > 0 Then
                ' Öffne Unterformular im Design-Modus
                DoCmd.OpenForm ctrl.SourceObject, acDesign
                
                ' Setze Datenherkunft basierend auf Name
                Select Case LCase(ctrl.Name)
                    Case "sub_ma_monat_stunden", "subformstunden", "substunden"
                        forms(ctrl.SourceObject).recordSource = "qry_N_Monatsabwesenheit_Stunden"
                        Debug.Print "  -> qry_N_Monatsabwesenheit_Stunden"
                        intUpdated = intUpdated + 1
                        
                    Case "sub_ma_monat_urlaub", "subformurlaub", "suburlaub"
                        forms(ctrl.SourceObject).recordSource = "qry_N_Monatsabwesenheit_Urlaub"
                        Debug.Print "  -> qry_N_Monatsabwesenheit_Urlaub"
                        intUpdated = intUpdated + 1
                        
                    Case "sub_ma_monat_krank", "subformkrank", "subkrank"
                        forms(ctrl.SourceObject).recordSource = "qry_N_Monatsabwesenheit_Krank"
                        Debug.Print "  -> qry_N_Monatsabwesenheit_Krank"
                        intUpdated = intUpdated + 1
                        
                    Case "sub_ma_monat_privat", "subformprivat", "subprivat"
                        forms(ctrl.SourceObject).recordSource = "qry_N_Monatsabwesenheit_PrivatVerplant"
                        Debug.Print "  -> qry_N_Monatsabwesenheit_PrivatVerplant"
                        intUpdated = intUpdated + 1
                        
                    Case Else
                        Debug.Print "  -> Keine Zuordnung für: " & ctrl.Name
                End Select
                
                ' Unterformular schließen und speichern
                DoCmd.Close acForm, ctrl.SourceObject, acSaveYes
            End If
        End If
    Next ctrl
    
    ' Hauptformular schließen und speichern
    DoCmd.Close acForm, strFormName, acSaveYes
    
    Debug.Print "=== Fertig: " & intUpdated & " Unterformulare aktualisiert ==="
    MsgBox "Erfolgreich " & intUpdated & " Unterformulare verknüpft!", vbInformation, "Verknüpfung abgeschlossen"
    
    Exit Sub
    
Err_Handler:
    Debug.Print "FEHLER: " & Err.description
    MsgBox "Fehler: " & Err.description, vbCritical, "Fehler"
    On Error Resume Next
    DoCmd.Close acForm, strFormName, acSaveNo
End Sub