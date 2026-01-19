' VBA-Funktion zur Berechnung der Tage pro Monat aus einem Zeitraum
Option Compare Database
Option Explicit

Public Function TageImMonat(vonDatum As Date, bisDatum As Date, jahrParam As Integer, monatParam As Integer) As Integer
    ' Berechnet die Anzahl der Tage eines Zeitraums, die in einen bestimmten Monat fallen
    
    On Error GoTo Err_Handler
    
    Dim monatStart As Date
    Dim monatEnde As Date
    Dim zeitraumStart As Date
    Dim zeitraumEnde As Date
    
    ' Grenzen des Zielmonats
    monatStart = DateSerial(jahrParam, monatParam, 1)
    monatEnde = DateSerial(jahrParam, monatParam + 1, 0)
    
    ' Überschneidung prüfen
    If bisDatum < monatStart Or vonDatum > monatEnde Then
        ' Kein Zeitraum liegt in diesem Monat
        TageImMonat = 0
        Exit Function
    End If
    
    ' Effektiven Zeitraum im Monat berechnen
    If vonDatum < monatStart Then
        zeitraumStart = monatStart
    Else
        zeitraumStart = vonDatum
    End If
    
    If bisDatum > monatEnde Then
        zeitraumEnde = monatEnde
    Else
        zeitraumEnde = bisDatum
    End If
    
    ' Tage berechnen (inklusiv)
    TageImMonat = DateDiff("d", zeitraumStart, zeitraumEnde) + 1
    
    Exit Function
    
Err_Handler:
    TageImMonat = 0
End Function