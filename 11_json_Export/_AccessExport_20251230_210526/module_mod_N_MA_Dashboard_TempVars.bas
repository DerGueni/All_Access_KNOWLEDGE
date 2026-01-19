Option Compare Database
Option Explicit



Public Sub Init_MA_Dashboard()
    On Error Resume Next

    If IsEmpty(TempVars("Jahr")) Then
        TempVars.Add "Jahr", Year(Date)
    Else
        TempVars!Jahr = Year(Date)
    End If

    If IsEmpty(TempVars("Anstellungsart")) Then
        TempVars.Add "Anstellungsart", 0
    Else
        TempVars!Anstellungsart = 0
    End If
End Sub

Public Sub Set_MA_Dashboard_Jahr(ByVal lngJahr As Long)
    On Error Resume Next
    If IsEmpty(TempVars("Jahr")) Then
        TempVars.Add "Jahr", lngJahr
    Else
        TempVars!Jahr = lngJahr
    End If
End Sub

Public Sub Set_MA_Dashboard_Anstellungsart(ByVal lngArt As Long)
    On Error Resume Next
    If IsEmpty(TempVars("Anstellungsart")) Then
        TempVars.Add "Anstellungsart", lngArt
    Else
        TempVars!Anstellungsart = lngArt
    End If
End Sub