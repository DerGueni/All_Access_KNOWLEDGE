Attribute VB_Name = "mod_Temp_CreateGuz"
Option Compare Database
Option Explicit



Sub CreateGuzForm()
    Dim frm As Form
    Dim lbl As control
    
    ' Erstelle neues Formular
    Set frm = CreateForm()
    
    ' Setze Formular-Eigenschaften
    frm.caption = "Guz"
    frm.RecordSelectors = False
    frm.NavigationButtons = False
    
    ' Füge Label im Kopf hinzu
    Set lbl = CreateControl(frm.Name, acLabel, acHeader, , , 100, 100, 2000, 400)
    lbl.caption = "Guz"
    lbl.FontSize = 14
    lbl.FontBold = True
    
    ' Speichere Formular
    DoCmd.Save acForm, frm.Name
    DoCmd.Rename "frm_N_Guz", acForm, frm.Name
    DoCmd.Close acForm, "frm_N_Guz"
End Sub

