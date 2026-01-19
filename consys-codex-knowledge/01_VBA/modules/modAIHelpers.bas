Attribute VB_Name = "modAIHelpers"
'Option Compare Database
'Option Explicit
'
'' In ein Standardmodul einfügen:
'Public Sub AI_CreateRunnerHost()
'    DoCmd.RunCommand acCmdNewObjectForm
'    With Screen.ActiveForm
'        .caption = "AI Runner Host"
'        .TimerInterval = 10000                 ' alle 10s
'        .OnTimer = "=AI_ProcessInbox()"
'        .Visible = False
'    End With
'    DoCmd.Save acForm, "frm_AIRunner_Host"
'    DoCmd.Close acForm, "frm_AIRunner_Host", acSaveYes
'    DoCmd.OpenForm "frm_AIRunner_Host", , , , , acHidden
'End Sub

