Attribute VB_Name = "mdl_N_ZeitHeader"
Option Compare Database
Option Explicit

' Modul fuer Zeit-Header und Summen-Funktionen

Public Sub UpdateZeitHeaderLabels(frm As Form)
    On Error Resume Next
    
    Dim strZeit1 As String, strZeit2 As String
    Dim strZeit3 As String, strZeit4 As String
    
    ' Hole Zeit-Labels aus dem Hauptformular (tbl_OB_Objekt)
    strZeit1 = Nz(frm!Zeit1_Label, "08:00")
    strZeit2 = Nz(frm!Zeit2_Label, "12:00")
    strZeit3 = Nz(frm!Zeit3_Label, "16:00")
    strZeit4 = Nz(frm!Zeit4_Label, "20:00")
    
    ' Setze Standard-Werte falls leer
    If strZeit1 = "" Then strZeit1 = "08:00"
    If strZeit2 = "" Then strZeit2 = "12:00"
    If strZeit3 = "" Then strZeit3 = "16:00"
    If strZeit4 = "" Then strZeit4 = "20:00"
    
    ' Aktualisiere Spalten-Ueberschriften im Unterformular (Datenblatt)
    ' Bei Datenblatt-Ansicht sind die Spalten-Header die Control-Captions
    Dim subFrm As Form
    Set subFrm = frm!sub_OB_Objekt_Positionen.Form
    
    ' Setze die Caption der Zeit-Felder (wird als Spalten-Header angezeigt)
    If Not subFrm Is Nothing Then
        subFrm!Zeit1.caption = strZeit1
        subFrm!Zeit2.caption = strZeit2
        subFrm!Zeit3.caption = strZeit3
        subFrm!Zeit4.caption = strZeit4
    End If
End Sub

' Berechnet die Summe einer Zeit-Spalte
Public Function SumZeitSpalte(lngObjektID As Long, strFeld As String) As Long
    On Error Resume Next
    SumZeitSpalte = Nz(DSum(strFeld, "tbl_OB_Objekt_Positionen", "OB_Objekt_Kopf_ID = " & lngObjektID), 0)
End Function

' Berechnet die Gesamtsumme aller Zeiten fuer ein Objekt
Public Function SumAlleZeiten(lngObjektID As Long) As Long
    On Error Resume Next
    Dim lngSum As Long
    lngSum = Nz(DSum("Nz(Zeit1,0) + Nz(Zeit2,0) + Nz(Zeit3,0) + Nz(Zeit4,0)", "tbl_OB_Objekt_Positionen", "OB_Objekt_Kopf_ID = " & lngObjektID), 0)
    SumAlleZeiten = lngSum
End Function

' Aktualisiert die Summen-Anzeige im Formular
Public Sub UpdateSummenAnzeige(frm As Form)
    On Error Resume Next
    
    Dim lngObjektID As Long
    lngObjektID = Nz(frm!ID, 0)
    
    If lngObjektID = 0 Then Exit Sub
    
    ' Aktualisiere Summen-Felder falls vorhanden
    frm!txtSumZeit1 = SumZeitSpalte(lngObjektID, "Zeit1")
    frm!txtSumZeit2 = SumZeitSpalte(lngObjektID, "Zeit2")
    frm!txtSumZeit3 = SumZeitSpalte(lngObjektID, "Zeit3")
    frm!txtSumZeit4 = SumZeitSpalte(lngObjektID, "Zeit4")
    frm!txtSumGesamt = SumAlleZeiten(lngObjektID)
End Sub


' Validiert einen Zeit-Wert (max 24 Stunden)
Public Function ValidateZeitWert(ByVal varValue As Variant, ByRef strMsg As String) As Boolean
    On Error Resume Next
    ValidateZeitWert = True
    strMsg = ""
    
    If IsNull(varValue) Or varValue = "" Then Exit Function
    
    ' Muss numerisch sein
    If Not IsNumeric(varValue) Then
        ValidateZeitWert = False
        strMsg = "Bitte nur Zahlen eingeben!"
        Exit Function
    End If
    
    Dim lngVal As Long
    lngVal = CLng(varValue)
    
    ' Keine negativen Werte
    If lngVal < 0 Then
        ValidateZeitWert = False
        strMsg = "Negative Werte sind nicht erlaubt!"
        Exit Function
    End If
    
    ' Warnung bei mehr als 24 Stunden
    If lngVal > 24 Then
        If MsgBox("Der eingegebene Wert (" & lngVal & " Stunden) ist ungewoehnlich hoch." & vbCrLf & _
                  "Moechten Sie diesen Wert trotzdem speichern?", vbYesNo + vbQuestion) = vbNo Then
            ValidateZeitWert = False
            strMsg = "Eingabe abgebrochen"
            Exit Function
        End If
    End If
End Function



' FEATURE 7: Farbcodierung nach Gruppe
Public Function GetGruppenFarbe(strGruppe As String) As Long
    ' Gibt eine Farbe basierend auf der Gruppe zurueck
    On Error Resume Next
    
    Select Case UCase(Left(Nz(strGruppe, ""), 3))
        Case "SEC", "SIC" ' Security/Sicherheit
            GetGruppenFarbe = RGB(255, 230, 230) ' Hellrot
        Case "EMP", "EIN" ' Empfang/Einlass
            GetGruppenFarbe = RGB(230, 255, 230) ' Hellgruen
        Case "PAR", "PKW" ' Parking/Parkplatz
            GetGruppenFarbe = RGB(230, 230, 255) ' Hellblau
        Case "VIP" ' VIP-Bereich
            GetGruppenFarbe = RGB(255, 255, 200) ' Hellgelb
        Case "TEC", "TEK" ' Technik
            GetGruppenFarbe = RGB(255, 230, 200) ' Hellorange
        Case "LOG", "LAG" ' Logistik/Lager
            GetGruppenFarbe = RGB(230, 255, 255) ' Hellcyan
        Case "BUE", "OFF" ' Buero/Office
            GetGruppenFarbe = RGB(245, 230, 255) ' Helllila
        Case Else
            GetGruppenFarbe = RGB(255, 255, 255) ' Weiss (Standard)
    End Select
End Function

' Wendet Farbcodierung auf Datenblatt an (wird im Form_Current des Unterformulars aufgerufen)
Public Sub ApplyFarbcodierung(frm As Form)
    On Error Resume Next
    
    Dim strGruppe As String
    strGruppe = Nz(frm!Gruppe, "")
    
    ' Bei Datenblatt-Ansicht: Detail-Sektion faerben
    frm.Section(0).backColor = GetGruppenFarbe(strGruppe)
End Sub


' FEATURE 8: Inline-Bearbeitung der Zeit-Labels
Public Sub BearbeiteZeitLabels(frm As Form)
    On Error GoTo ErrHandler
    
    Dim lngObjektID As Long
    lngObjektID = Nz(frm!ID, 0)
    
    If lngObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Hole aktuelle Werte
    Dim strZeit1 As String, strZeit2 As String
    Dim strZeit3 As String, strZeit4 As String
    strZeit1 = Nz(frm!Zeit1_Label, "08:00")
    strZeit2 = Nz(frm!Zeit2_Label, "12:00")
    strZeit3 = Nz(frm!Zeit3_Label, "16:00")
    strZeit4 = Nz(frm!Zeit4_Label, "20:00")
    
    ' Einfacher Dialog mit InputBox (Alternative: eigenes Formular)
    Dim strInput As String
    strInput = InputBox("Geben Sie die 4 Zeitslots ein (getrennt durch Komma):" & vbCrLf & _
        "Beispiel: 08:00, 12:00, 16:00, 20:00", "Zeit-Labels bearbeiten", _
        strZeit1 & ", " & strZeit2 & ", " & strZeit3 & ", " & strZeit4)
    
    If strInput = "" Then Exit Sub
    
    ' Parsen
    Dim arrZeiten() As String
    arrZeiten = Split(strInput, ",")
    
    If UBound(arrZeiten) >= 0 Then frm!Zeit1_Label = Trim(arrZeiten(0))
    If UBound(arrZeiten) >= 1 Then frm!Zeit2_Label = Trim(arrZeiten(1))
    If UBound(arrZeiten) >= 2 Then frm!Zeit3_Label = Trim(arrZeiten(2))
    If UBound(arrZeiten) >= 3 Then frm!Zeit4_Label = Trim(arrZeiten(3))
    
    ' Speichern
    If frm.Dirty Then frm.Dirty = False
    
    ' Header aktualisieren
    UpdateZeitHeaderLabels frm
    
    MsgBox "Zeit-Labels aktualisiert!", vbInformation
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

