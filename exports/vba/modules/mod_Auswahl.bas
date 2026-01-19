Attribute VB_Name = "mod_Auswahl"
Public Sub CreateAuswahlFormular()
    ' ALTERNATIVE STRATEGIE - Formular mit initial Control erstellen
    
    Dim frm As Form
    Dim ctlLabel As control
    Dim ctlButton As control
    Dim intTop As Integer
    Dim strFormName As String
    
    On Error GoTo ErrorHandler
    
    ' Formular löschen, falls bereits vorhanden
    On Error Resume Next
    DoCmd.DeleteObject acForm, "frm_Auswahlmenue"
    On Error GoTo ErrorHandler
    
    ' Neues Formular erstellen
    Set frm = CreateForm()
    strFormName = frm.Name
    
    ' Formulareinstellungen
    With frm
        .caption = "Auswahlmenü - Auftragsbearbeitung"
        .width = 4500
        .height = 3500
        .FormLayout = 2
    End With
    
    ' ZUERST: Ein initiales Label erstellen (damit Formular "gültig" ist)
    Set ctlLabel = CreateControl(strFormName, acLabel, , , , 200, 200, 4000, 300)
    ctlLabel.Name = "lblAuswahl"
    ctlLabel.caption = "Bitte wählen Sie eine Option:"
    ctlLabel.FontSize = 12
    ctlLabel.FontBold = True
    
    ' Speichern und schließen
    DoCmd.Save acForm, strFormName
    DoCmd.Close acForm, strFormName
    
    ' DANN: Umbenennen
    On Error Resume Next
    ActiveProject.VBProject.VBComponents(strFormName).Name = "frm_Auswahlmenue"
    On Error GoTo ErrorHandler
    
    strFormName = "frm_Auswahlmenue"
    
    ' DANN: Formular wieder öffnen
    DoCmd.OpenForm strFormName, , , , , acHidden
    Set frm = Forms(strFormName)
    
    DoEvents
    
    ' Jetzt die Buttons hinzufügen (Formular ist bereits "initialisiert")
    intTop = 600
    
    ' Button 1
    Set ctlButton = CreateControl(strFormName, acCommandButton, , , , 300, intTop, 3900, 350)
    ctlButton.Name = "cmd1"
    ctlButton.caption = "1. Aufträge synchronisieren"
    ctlButton.onClick = "[Event Procedure]"
    AddButtonCode strFormName, "cmd1", 1
    DoEvents
    
    ' Button 2
    intTop = intTop + 400
    Set ctlButton = CreateControl(strFormName, acCommandButton, , , , 300, intTop, 3900, 350)
    ctlButton.Name = "cmd2"
    ctlButton.caption = "2. Festangestellte MA in Aufträge einfügen"
    ctlButton.onClick = "[Event Procedure]"
    AddButtonCode strFormName, "cmd2", 2
    DoEvents
    
    ' Button 3
    intTop = intTop + 400
    Set ctlButton = CreateControl(strFormName, acCommandButton, , , , 300, intTop, 3900, 350)
    ctlButton.Name = "cmd3"
    ctlButton.caption = "3. Minijobber vorplanen"
    ctlButton.onClick = "[Event Procedure]"
    AddButtonCode strFormName, "cmd3", 3
    DoEvents
    
    ' Button 4
    intTop = intTop + 400
    Set ctlButton = CreateControl(strFormName, acCommandButton, , , , 300, intTop, 3900, 350)
    ctlButton.Name = "cmd4"
    ctlButton.caption = "4. Alles auf einen Rutsch"
    ctlButton.onClick = "[Event Procedure]"
    AddButtonCode strFormName, "cmd4", 4
    DoEvents
    
    ' Button 5
    intTop = intTop + 400
    Set ctlButton = CreateControl(strFormName, acCommandButton, , , , 300, intTop, 3900, 350)
    ctlButton.Name = "cmd5"
    ctlButton.caption = "5. Abbrechen"
    ctlButton.onClick = "[Event Procedure]"
    AddButtonCode strFormName, "cmd5", 0
    DoEvents
    
    ' Finale Speicherung
    DoCmd.Save acForm, strFormName
    DoCmd.Close acForm, strFormName
    
    MsgBox "Auswahlformular '" & strFormName & "' erfolgreich erstellt!", vbInformation, "Erfolg"
    Exit Sub
    
ErrorHandler:
    MsgBox "Fehler " & Err.Number & ": " & Err.description, vbCritical, "Fehler bei der Formularerstellung"
End Sub

Private Sub AddButtonCode(strFormName As String, strButtonName As String, intValue As Integer)
    ' Fügt den Click-Event-Code zu den Buttons hinzu
    
    Dim strCode As String
    Dim prj As Object
    Dim frm_Module As Object
    
    On Error Resume Next
    
    If intValue = 0 Then
        strCode = "Private Sub " & strButtonName & "_Click()" & vbCrLf & _
                  "    DoCmd.Close acForm, Me.Name" & vbCrLf & _
                  "End Sub"
    Else
        strCode = "Private Sub " & strButtonName & "_Click()" & vbCrLf & _
                  "    Me.Tag = " & intValue & vbCrLf & _
                  "    DoCmd.Close acForm, Me.Name" & vbCrLf & _
                  "End Sub"
    End If
    
    Set prj = ActiveProject.VBProject
    Set frm_Module = prj.VBComponents(strFormName).codeModule
    frm_Module.AddFromString strCode
    
    On Error GoTo 0
End Sub

