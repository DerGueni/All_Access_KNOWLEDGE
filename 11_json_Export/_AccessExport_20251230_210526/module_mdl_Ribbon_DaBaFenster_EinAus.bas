Option Compare Database
Option Explicit

Public Function Ribbon_aus()
    
'Ausblenden des Datenbank Fensters:
    'DoCmd.SelectObject acTable, , True
    'RunCommand acCmdWindowHide
'Einblenden des Datenbank Fensters:
    'DoCmd.SelectObject acTable, , True

    
'Ausblenden der Ribbons und Menüs:
    DoCmd.ShowToolbar "Ribbon", acToolbarNo
'Einblenden der Ribbons und Menüs:
    'DoCmd.ShowToolbar "Ribbon", acToolbarYes

End Function

Public Function Ribbon_ein()
   
'Ausblenden des Datenbank Fensters:
    'DoCmd.SelectObject acTable, , True
    'RunCommand acCmdWindowHide
'Einblenden des Datenbank Fensters:
    'DoCmd.SelectObject acTable, , True

    
'Ausblenden der Ribbons und Menüs:
    'DoCmd.ShowToolbar "Ribbon", acToolbarNo
'Einblenden der Ribbons und Menüs:
    DoCmd.ShowToolbar "Ribbon", acToolbarYes

End Function

Public Function DaBa_Fenster_aus()
    DoCmd.SelectObject acTable, , True
    RunCommand acCmdWindowHide

End Function

Public Function DaBa_Fenster_ein()
    DoCmd.SelectObject acTable, , True

End Function