Attribute VB_Name = "Modul5"
' ==============================================================================
' Modul: Mobilnummern_In_Festnetz_Kopieren
' Zweck: Kopiert Telefonnummern aus Tel_Mobil, formatiert sie zu +49-Format
'        und schreibt sie in Tel_Festnetz (Tel_Mobil bleibt unveraendert)
' ==============================================================================

Option Compare Database
Option Explicit

' ------------------------------------------------------------------------------
' Funktion: FormatiereHandynummer
' Zweck: Formatiert eine einzelne Telefonnummer zu +49XXXXXXXXX
' Parameter: telefonnummer - Die zu formatierende Telefonnummer (beliebiges Format)
' Rueckgabe: Formatierte Telefonnummer als String (+49XXXXXXXXX)
' ------------------------------------------------------------------------------
Public Function FormatiereHandynummer(ByVal telefonnummer As Variant) As String
    Dim cleanNumber As String
    Dim i As Integer
    Dim char As String
    
    ' Wenn Null oder leer, dann leeren String zurueckgeben
    If IsNull(telefonnummer) Or Len(Trim(telefonnummer & "")) = 0 Then
        FormatiereHandynummer = ""
        Exit Function
    End If
    
    ' Nur Zahlen extrahieren (alle anderen Zeichen entfernen)
    cleanNumber = ""
    For i = 1 To Len(telefonnummer)
        char = Mid(telefonnummer, i, 1)
        If IsNumeric(char) Then
            cleanNumber = cleanNumber & char
        End If
    Next i
    
    ' Wenn die Nummer mit 0 beginnt, diese entfernen
    If Left(cleanNumber, 1) = "0" Then
        cleanNumber = Mid(cleanNumber, 2)
    End If
    
    ' Wenn die Nummer mit 49 beginnt, diese entfernen (um Duplikate zu vermeiden)
    If Left(cleanNumber, 2) = "49" Then
        cleanNumber = Mid(cleanNumber, 3)
    End If
    
    ' +49 voranstellen
    FormatiereHandynummer = "+49" & cleanNumber
End Function

' ------------------------------------------------------------------------------
' Prozedur: KopiereMobilInFestnetz
' Zweck: Kopiert Tel_Mobil -> Tel_Festnetz (formatiert), Tel_Mobil bleibt original
' Verwendung: Ausfuehren ueber Button oder direkt im VBA-Editor (F5)
' ------------------------------------------------------------------------------
Public Sub KopiereMobilInFestnetz()
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim anzahlAktualisiert As Long
    Dim originalNummer As String
    Dim formatiertNummer As String
    
    anzahlAktualisiert = 0
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("tbl_ma_mitarbeiterstamm", dbOpenDynaset)
    
    If Not rs.EOF Then
        rs.MoveFirst
        
        Do While Not rs.EOF
            ' Pruefe ob Tel_Mobil einen Wert hat
            If Not IsNull(rs!Tel_Mobil) And Len(Trim(rs!Tel_Mobil & "")) > 0 Then
                ' Original-Nummer zwischenspeichern
                originalNummer = rs!Tel_Mobil
                
                ' Nummer formatieren
                formatiertNummer = FormatiereHandynummer(originalNummer)
                
                ' Formatierte Nummer in Tel_Festnetz schreiben
                rs.Edit
                rs!Tel_Festnetz = formatiertNummer
                ' Tel_Mobil NICHT aendern - bleibt original!
                rs.update
                
                anzahlAktualisiert = anzahlAktualisiert + 1
            End If
            rs.MoveNext
        Loop
    End If
    
    rs.Close
    Set rs = Nothing
    Set db = Nothing
    
    MsgBox "Kopieren abgeschlossen!" & vbCrLf & _
           "Anzahl aktualisierter Datensaetze: " & anzahlAktualisiert & vbCrLf & vbCrLf & _
           "Tel_Mobil: Original beibehalten" & vbCrLf & _
           "Tel_Festnetz: +49-Format eingetragen", _
           vbInformation, "Mobilnummern in Festnetz kopiert"
End Sub

' ==============================================================================
' VERWENDUNGSBEISPIELE:
' ==============================================================================
'
' 1. Alle Mobilnummern formatiert in Tel_Festnetz kopieren:
'    KopiereMobilInFestnetz
'
' 2. Einzelne Nummer in einer Abfrage/Formular formatieren:
'    =FormatiereHandynummer([Tel_Mobil])
'
' BEISPIEL-VERHALTEN:
' Vorher:
'   Tel_Mobil: "0171 1234567"
'   Tel_Festnetz: (leer)
'
' Nachher:
'   Tel_Mobil: "0171 1234567"  (unveraendert!)
'   Tel_Festnetz: "+491711234567"  (neu formatiert)
'
' ==============================================================================


