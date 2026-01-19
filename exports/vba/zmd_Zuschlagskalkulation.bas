Attribute VB_Name = "zmd_Zuschlagskalkulation"
Option Compare Database

Option Explicit

Type TAG
    Datum As Date
    WTag As Integer 'Wochentag
    Ftag As Boolean 'Feiertag
End Type

'Stunden für Rechnung
Public Type VA_Stunden
    sicherheit      As Double
    leitung         As Double
    bereichsleitung As Double
    Nacht           As Double
    Sonntag         As Double
    Feiertag        As Double
End Type

'Personen für Rechnung
Public Type VA_Personen
    persSicherheit  As Integer
    persLeitung     As Integer
    persBerLeitung  As Integer
End Type

'Hilfskonstrukt Schicht für Rechnung
Public Type VA_Schicht
    Datum           As Date
    Beginn          As Date
    Ende            As Date
    Std             As Double
    VA_Stunden      As VA_Stunden
    VA_Personen     As VA_Personen
End Type

'Hilfskonstrukt Veranstaltung für Rechnung
Public Type VA_Data
    VA_Stunden      As VA_Stunden
    VA_Schichten()  As VA_Schicht
End Type

Dim Tage() As TAG


'Zuschlag Stunden
Function Stunden_Zuschlag(ByVal Datum As Date, ByVal Beginn As Date, ByVal Ende As Date, ByVal Art As String) As Double
       
    'Mögliche Zuschläge(Art):
        'NACHT
        'SONNTAG
        'FEIERTAG
        'SONNTAGNACHT
        'FEIERTAGNACHT
        
Dim FDatum1 As Boolean 'Feiertag?
Dim FDatum2 As Boolean 'Folgetag Feiertag?
Dim SDatum1 As Boolean 'Sonntag?
Dim SDatum2 As Boolean 'Folgetag Sonntag?
Dim TagEnde As Date    'Endzeit Zuschlag
Dim Wechsel As Boolean 'Tagesübergreifend?

    'Aussteigen, wenn Werte fehlen
    If Datum = "00:00:00" Then Exit Function
    
    'Prüfung Zeiten
    Beginn = Format(Beginn, "HH:MM:SS")
    Ende = Format(Ende, "HH:MM:SS")
    
    'Beginn anpassen sofern um Mitternacht
    If Beginn = "00:00:00" Or Beginn = "23:59:00" Then Beginn = "23:59:59"
    
    'Ende anpassen sofern um Mitternacht
    If Ende = "00:00:00" Or Ende = "23:59:00" Then Ende = "23:59:59"
    
    'Prüfung Feiertag
    If Feiertag(Datum) <> "" Then FDatum1 = True
    If Feiertag(Datum + 1) <> "" Then FDatum2 = True
    
    'Prüfung Sonntag -> Sonntag = 1!
    If Weekday(Datum) = 1 Then SDatum1 = True
    If Weekday(Datum + 1) = 1 Then SDatum2 = True
    
    
    'Prüfung Endzeit am Folgetag
    If Ende < Beginn Then
        TagEnde = "23:59:59"
        Wechsel = True
    Else
        TagEnde = Ende
    End If
    

    'Art des Zuschlags
    Select Case Art
    
        Case "NACHT"
            'Veranstaltungstag weder Sonn- noch Feiertag
            If FDatum1 = False And SDatum1 = False Then
                'Folgetag weder Sonn- noch Feiertag
                If FDatum2 = False And SDatum2 = False Then
                    'Nachtzuschlag ganze Nacht
                    Stunden_Zuschlag = zuschlagNacht(Datum, Beginn, Ende, Wechsel)
                Else
                    'Nachtzuschlag bis Mitternacht
                    Stunden_Zuschlag = zuschlagNacht(Datum, Beginn, TagEnde)
                End If
            'Veranstaltungstag Sonn- oder Feiertag
            Else
                'Folgetag weder Sonn- noch Feiertag -> Nachtzuschlag ab Mitternacht
                If FDatum2 = False And SDatum2 = False Then
                    If Wechsel = True Then Stunden_Zuschlag = zuschlagNacht(Datum, "00:00:00", Ende, Wechsel)
                End If
            End If
            
            
        Case "SONNTAG"
            'Veranstatltungstag Sonntag aber kein Feiertag -> Sonntagszuschlag
            If FDatum1 = False And SDatum1 = True And Wechsel = True Then _
                Stunden_Zuschlag = zuschlagSonn(Datum, Beginn, TagEnde)
            If FDatum1 = False And SDatum1 = True And Wechsel = False Then _
                Stunden_Zuschlag = zuschlagSonn(Datum, Beginn, Ende)
            If FDatum2 = False And SDatum2 = True And Wechsel = True Then _
                Stunden_Zuschlag = zuschlagSonn(Datum, "00:00:01", Ende)


        Case "FEIERTAG"
            'Veranstatltungstag Feiertag -> Feiertagszuschlag
            If FDatum1 = True And Wechsel = True Then _
                Stunden_Zuschlag = zuschlagFeier(Datum, Beginn, TagEnde)
            If FDatum1 = True And Wechsel = False Then _
                Stunden_Zuschlag = Stunden_Zuschlag + zuschlagFeier(Datum, Beginn, Ende)
            If FDatum2 = True And Wechsel = True Then _
                Stunden_Zuschlag = Stunden_Zuschlag + zuschlagFeier(Datum, "00:00:01", Ende)
              
            
        Case "SONNTAGNACHT"
            'Veranstatltungstag Sonntag aber kein Feiertag -> Sonntagsnachtzuschlag bis max. Mitternacht
            If FDatum1 = False And SDatum1 = True Then _
                Stunden_Zuschlag = zuschlagSNacht(Datum, Beginn, TagEnde)
            
            'Folgetag Sonntag aber kein Feiertag -> Sonntagsnachtzuschlag ab Mitternacht
            If FDatum2 = False And SDatum2 = True And Wechsel = True Then _
                Stunden_Zuschlag = zuschlagSNacht(Datum, "00:00:01", Ende, Wechsel)
        
            
        Case "FEIERTAGNACHT"
            'Veranstatltungstag Feiertag -> Feiertagsnachzuschlag bis max. Mitternacht
            If FDatum1 = True And FDatum2 = False Then _
                Stunden_Zuschlag = zuschlagFNacht(Datum, Beginn, TagEnde)
                
            'Folgetag Feiertag -> Feiertagsnachzuschlag ab Mitternacht
            If FDatum1 = False And FDatum2 = True And Wechsel = True Then _
                Stunden_Zuschlag = zuschlagFNacht(Datum, "00:00:01", Ende, Wechsel)
            
            'Beide Tage Feiertage
                If FDatum1 = True And FDatum2 = True Then _
                Stunden_Zuschlag = zuschlagNacht(Datum, Beginn, Ende, Wechsel)
        
        
        Case "NACHT_GESAMT"
                'Nachtzuschlag ganze Nacht
                Stunden_Zuschlag = zuschlagNacht(Datum, Beginn, Ende, Wechsel)
        
        
        Case Else
            Stunden_Zuschlag = "0,00"
            
            
    End Select

    
End Function


'NACHTZUSCHLAG
Function zuschlagNacht(Datum, Beginn, Ende, Optional Wechsel As Boolean)
    Dim zbeginn As Date 'Uhrzeit, ab der der Zuschlag beginnt
    Dim ZEnde As Date   'Uhrzeit, ab der der Zuschlag endet
    
    zbeginn = Datum & " 20:00:00"
    ZEnde = Datum + 1 & " 06:00:00"
    
    'Wenn Arbeitsende vor Zuschlagsbeginn
    If Datum & " " & Ende < zbeginn And Wechsel = False Then
        'Arbeitsbeginn nach Mitternacht?
        If Datum & " " & Beginn < ZEnde - 1 Then
            Ende = Right(ZEnde, 8)
            zuschlagNacht = stunden(Beginn, Ende)
        End If
        Exit Function
    End If
    
    'Wenn Startzeit vor Zuschlagsbeginn
    If Datum & " " & Beginn < zbeginn And Beginn <> "00:00:00" Then Beginn = Right(zbeginn, 8)
    
    'Wenn Endzeit nach Zuschlagsende
    'Ende am gleichen Tag
    If Wechsel = False Then
        If Datum & " " & Ende > ZEnde Then Ende = Right(ZEnde, 8)
    'Ende am Folgetag
    Else
        If Datum + 1 & " " & Ende > ZEnde Then Ende = Right(ZEnde, 8)
    End If
    
    zuschlagNacht = stunden(Beginn, Ende)

End Function


'SONNTAGSZUSCHLAG
Function zuschlagSonn(Datum, Beginn, Ende, Optional Wechsel As Boolean)
    Dim zbeginn As Date 'Uhrzeit, ab der der Zuschlag beginnt
    Dim ZEnde As Date   'Uhrzeit, ab der der Zuschlag endet
    
    zbeginn = "06:00:00"
    ZEnde = "20:00:00"
    
    'Wenn Ende vor Zuschlagsbeginn
    If Ende < zbeginn Then Exit Function
    
    'Wenn Beginn nach Zuschlagsende
    If Beginn > ZEnde Then Exit Function
    
    'Wenn Startzeit vor Zuschlagsbeginn
    If Datum & " " & Beginn < Datum & " " & zbeginn And Beginn <> "00:00:00" Then Beginn = zbeginn
    
    'Wenn Endzeit nach Zuschlagsende
    'Ende am gleichen Tag
    If Wechsel = False Then
        If Datum & " " & Ende > Datum & " " & ZEnde Then Ende = ZEnde
    'Ende am Folgetag
    Else
        If Datum + 1 & " " & Ende > Datum + 1 & " " & ZEnde Then Ende = ZEnde
    End If
    
    zuschlagSonn = stunden(Beginn, Ende)
    
    
End Function


'FEIERTAGSZUSCHLAG
Function zuschlagFeier(Datum, Beginn, Ende, Optional Wechsel As Boolean)
    Dim zbeginn As Date 'Uhrzeit, ab der der Zuschlag beginnt
    Dim ZEnde As Date   'Uhrzeit, ab der der Zuschlag endet
    
    zbeginn = "06:00:00"
    ZEnde = "20:00:00"
    
    'Wenn Ende vor Zuschlagsbeginn
    If Ende < zbeginn Then Exit Function
    
    'Wenn Beginn nach Zuschlagsende
    If Beginn > ZEnde Then Exit Function
    
    'Wenn Startzeit vor Zuschlagsbeginn
    If Datum & " " & Beginn < Datum & " " & zbeginn And Beginn <> "00:00:00" Then Beginn = zbeginn
    
    'Wenn Endzeit nach Zuschlagsende
    'Ende am gleichen Tag
    If Wechsel = False Then
        If Datum & " " & Ende > Datum & " " & ZEnde Then Ende = ZEnde
    'Ende am Folgetag
    Else
        If Datum + 1 & " " & Ende > Datum + 1 & " " & ZEnde Then Ende = ZEnde
    End If
    
    zuschlagFeier = stunden(Beginn, Ende)
    
End Function


'NACHTZUSCHLAG-SONNTAG bis max. Mitternacht / ab Mitternacht
Function zuschlagSNacht(Datum, Beginn, Ende, Optional Wechsel As Boolean)
    Dim zbeginn As Date 'Uhrzeit, ab der der Zuschlag beginnt
    Dim ZEnde As Date   'Uhrzeit, ab der der Zuschlag endet
    
    'Wenn Arbeitsbeginn nachts
    If Beginn >= "00:00:00" And Beginn <= "06:00:00" Then
        zbeginn = "00:00:00"
        ZEnde = "06:00:00"      ' -----> effektives Zuschlagsende
    'Wenn Arbeitsbeginn nachmittags/abends und Datum = Sonntag
    ElseIf Weekday(Datum) = 1 Then
        zbeginn = "20:00:00"    ' -----> effektiver Zuschlagsbeginn
        ZEnde = "23:59:59"
    'Tag ist nicht Sonntag
    Else
        Exit Function
    End If
    
    'Wenn Arbeitsende vor Zuschlagsbeginn
    If Ende < zbeginn Then Exit Function
    
    'Wenn Startzeit vor Zuschlagsbeginn
    If Datum & " " & Beginn < Datum & " " & zbeginn And Beginn <> "00:00:00" Then Beginn = zbeginn
    
    'Wenn Endzeit nach Zuschlagsende
    'Ende am gleichen Tag
    If Wechsel = False Then
        If Datum & " " & Ende > Datum & " " & ZEnde Then Ende = ZEnde
    'Ende am Folgetag
    Else
        If Datum + 1 & " " & Ende > Datum + 1 & " " & ZEnde Then Ende = ZEnde
    End If
    
    zuschlagSNacht = stunden(Beginn, Ende)
     
    
End Function


'NACHTZUSCHLAG-FEIERTAG bis max. Mitternacht /ab Mitternacht
Function zuschlagFNacht(Datum, Beginn, Ende, Optional Wechsel As Boolean)
    Dim zbeginn As Date 'Uhrzeit, ab der der Zuschlag beginnt
    Dim ZEnde As Date   'Uhrzeit, ab der der Zuschlag endet
    
    'Wenn Arbeitsbeginn nachts
    If Beginn >= "00:00:00" And Beginn <= "06:00:00" Then
        zbeginn = "00:00:00"
        ZEnde = "06:00:00"      ' -----> effektives Zuschlagsende
    'Wenn Arbeitsbeginn nachmittags/abends
    Else
        zbeginn = "20:00:00"    ' -----> effektiver Zuschlagsbeginn
        ZEnde = "23:59:59"
    End If
    
    'Wenn Arbeitsbeginn nachts
    If Beginn >= "00:00:00" And Beginn <= "06:00:00" Then
        zbeginn = "00:00:00"
        ZEnde = "06:00:00"      ' -----> effektives Zuschlagsende
    'Wenn Arbeitsbeginn nachmittags/abends und Datum = Feiertag
    ElseIf Feiertag(Datum) <> "" Then
        zbeginn = "20:00:00"    ' -----> effektiver Zuschlagsbeginn
        ZEnde = "23:59:59"
    'Tag ist kein Feiertag
    Else
        Exit Function
    End If
    
    
    'Wenn Arbeitsende vor Zuschlagsbeginn
    If Ende < zbeginn Then Exit Function
        
    'Wenn Startzeit vor Zuschlagsbeginn und ende nach Zuschlagsbeginn
    If Datum & " " & Beginn < Datum & " " & zbeginn And Beginn <> "00:00:00" Then Beginn = zbeginn
    
    'Wenn Endzeit nach zuschlagsende
    'Ende am gleichen Tag
    If Wechsel = False Then
        If Datum & " " & Ende > Datum & " " & ZEnde Then Ende = ZEnde
    'Ende am Folgetag
    Else
        If Datum + 1 & " " & Ende > Datum + 1 & " " & ZEnde Then Ende = ZEnde
    End If
    
    zuschlagFNacht = stunden(Beginn, Ende)
    
    
End Function


'Stunden- & Kostenberechnung
Function calc_ZUO_Stunden(ZUO_ID As Long, MA_ID As Long, VA_ID As Long)

Dim sql             As String
Dim tbl             As String
Dim ABF             As String
Dim WHERE           As String
Dim Normal          As Double
Dim Nacht           As Double
Dim Sonntag         As Double
Dim SonntagNacht    As Double
Dim Feiertag        As Double
Dim FeiertagNacht   As Double
Dim Lohnart_grund   As Long
Dim Grundlohn       As Double
Dim bruttoKZ        As Boolean
Dim SubKZ           As Boolean
Dim VADatum         As Date
Dim MA_Start        As String
Dim MA_Ende         As String

On Error GoTo Err
    

    tbl = ZUO_STD
    ABF = "zqry_ZUO_ZK_Stunden_prepare"
    WHERE = "ZUO_ID = " & ZUO_ID
    VADatum = TLookup("VADatum", ZUORDNUNG, "ID = " & ZUO_ID)
    MA_Start = Nz(TLookup("MA_Start", ZUORDNUNG, "ID = " & ZUO_ID), "")
    MA_Ende = Nz(TLookup("MA_Ende", ZUORDNUNG, "ID = " & ZUO_ID), "")

    'Nur berechnen, wenn MA_ID, Start und Ende vorhanden sind!
    If MA_ID <> 0 And MA_Start <> "" And MA_Ende <> "" Then
        'ACHTUNG: Stundenberechnung Subunternehmner läuft anders!
        SubKZ = TLookup("IstSubunternehmer", MASTAMM, "ID = " & MA_ID)
        If SubKZ = False Then
            Normal = Nz(TLookup("Stunden", ABF, WHERE), 0)
            Nacht = Nz(TLookup("Nacht", ABF, WHERE), 0)
            Sonntag = Nz(TLookup("Sonntag", ABF, WHERE), 0)
            SonntagNacht = Nz(TLookup("SonntagNacht", ABF, WHERE), 0)
            Feiertag = Nz(TLookup("Feiertag", ABF, WHERE), 0)
            FeiertagNacht = Nz(TLookup("FeiertagNacht", ABF, WHERE), 0)
            Lohnart_grund = detect_Lohnart(MA_ID, "Normal", ZUO_ID)
            If Lohnart_grund <> 0 Then Grundlohn = detect_grundlohn(Lohnart_grund, VADatum)
        Else
            ABF = "zqry_ZUO_Stunden_Sub_lb"
            Normal = Nz(TLookup("Stunden", ABF, WHERE), 0)
            Nacht = Nz(TLookup("Nacht", ABF, WHERE), 0)
            Sonntag = Nz(TLookup("Sonntag", ABF, WHERE), 0)
            Feiertag = Nz(TLookup("Feiertag", ABF, WHERE), 0)
        End If
        
        bruttoKZ = TLookup("IstNSB", MASTAMM, "ID = " & MA_ID)
    
        If Normal <> 0 Then Call update_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID, "Normal", Normal, VADatum, Lohnart_grund, Grundlohn, bruttoKZ, SubKZ)
        If Nacht <> 0 Then Call update_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID, "Nacht", Nacht, VADatum, Lohnart_grund, Grundlohn, bruttoKZ, SubKZ)
        If Sonntag <> 0 Then Call update_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID, "Sonntag", Sonntag, VADatum, Lohnart_grund, Grundlohn, bruttoKZ, SubKZ)
        If SonntagNacht <> 0 Then Call update_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID, "SonntagNacht", SonntagNacht, VADatum, Lohnart_grund, Grundlohn, bruttoKZ, SubKZ)
        If Feiertag <> 0 Then Call update_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID, "Feiertag", Feiertag, VADatum, Lohnart_grund, Grundlohn, bruttoKZ, SubKZ)
        If FeiertagNacht <> 0 Then Call update_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID, "FeiertagNacht", FeiertagNacht, VADatum, Lohnart_grund, Grundlohn, bruttoKZ, SubKZ)
        
    Else
        'eventuell vorhandene Sätze löschen
        CurrentDb.Execute "DELETE FROM " & tbl & " WHERE " & WHERE
        
    End If
    
Ende:
    Exit Function
Err:
    writelog Server & "Database\Log\ztbl_ZUO_Stunden.txt", Now & "  " & Environ("UserName") & ", ZUO_ID: " & ZUO_ID & ", " & Err.Number & " " & Err.description
    Resume Ende
End Function


'Werte in ztbl_ZUO_Stunden updaten
Function update_ZUO_Stunden(ZUO_ID As Long, MA_ID As Long, VA_ID As Long, Bez As String, stunden As Double, VADatum As Date, _
    Lohnart_grund As Long, Grundlohn As Double, bruttoKZ As Boolean, SubKZ As Boolean, Optional iPreisArt_ID As Long, Optional iLohnart_ID As Long)


Dim sql             As String
Dim tbl             As String
Dim rs              As Recordset
Dim WHERE           As String
Dim Lohnart_ID      As Long

On Error GoTo Err

    tbl = ZUO_STD
    WHERE = "ZUO_ID = " & ZUO_ID & " AND Bezeichnung_kurz = '" & Bez & "'"

    sql = "SELECT * FROM " & tbl & " WHERE " & WHERE
    
    Set rs = CurrentDb.OpenRecordset(sql)
    
    If rs.EOF = True Then
        rs.AddNew
        rs.fields("ZUO_ID") = ZUO_ID
        rs.fields("VA_ID") = VA_ID
        rs.fields("Bezeichnung_kurz") = Bez
    Else
        rs.Edit
    End If
    'Mitarbeiterwechsel?
    If rs.fields("MA_ID") <> MA_ID Then
        rs.fields("Satz") = Null
        rs.fields("Bemerkung") = Null
    End If
    rs.fields("MA_ID") = MA_ID
    rs.fields("Stunden_brutto") = stunden
    rs.fields("Stunden_netto") = Round(stunden * 0.91, 2)
    rs.fields("Lohnstunden_brutto") = bruttoKZ
    'If bruttoKZ = True And IsInitial(iLohnart_ID) Then
    If SubKZ = True Then
        rs.fields("Lohn") = Null
        rs.fields("Lohnart_ID") = Null
        If iPreisArt_ID = 0 Then
            rs.fields("Preisart_ID") = detect_Preisart(MA_ID, Bez, ZUO_ID)
        Else
            rs.fields("Preisart_ID") = iPreisArt_ID
        End If
        If IsInitial(rs.fields("Satz")) Then rs.fields("Satz") = detect_Spreis(rs.fields("MA_ID"), rs.fields("Preisart_ID"))
        If Not IsInitial(rs.fields("Preisart_ID")) Then rs.fields("Preis") = calc_Preis(MA_ID, rs.fields("Preisart_ID"), stunden, VADatum, Nz(rs.fields("Satz"), 0))
        rs.fields("Bemerkung") = TLookup("Bemerkungen", ZUORDNUNG, "ID = " & ZUO_ID)
    Else
        rs.fields("Preisart_ID") = Null
        rs.fields("Preis") = Null
        If Lohnart_grund <> 0 Then
            If Bez = "Normal" Then
                rs.fields("Lohnart_ID") = Lohnart_grund
            Else
                If iLohnart_ID = 0 Then
                    rs.fields("Lohnart_ID") = detect_Lohnart(MA_ID, Bez, ZUO_ID)
                Else
                    rs.fields("Lohnart_ID") = iLohnart_ID
                End If
            End If
            If IsInitial(rs.fields("Satz")) Then rs.fields("Satz") = detect_satz(rs.fields("Lohnart_ID"), Grundlohn, VADatum)
            If bruttoKZ = True Then
                rs.fields("Lohn") = calc_Lohn(rs.fields("Lohnart_ID"), stunden, VADatum, Bez, Grundlohn, Nz(rs.fields("Satz"), 0))
            Else
                rs.fields("Lohn") = calc_Lohn(rs.fields("Lohnart_ID"), rs.fields("Stunden_netto"), VADatum, Bez, Grundlohn, Nz(rs.fields("Satz"), 0))
            End If
        End If
    End If
    rs.update
    rs.Close
    Set rs = Nothing
    
    
Ende:
    Exit Function
Err:
    writelog Server & "Database\Log\ztbl_ZUO_Stunden.txt", Now & "  " & Environ("UserName") & ", ZUO_ID: " & ZUO_ID & ", " & Err.Number & " " & Err.description
    Resume Ende
End Function


'Preisart_ID ermitteln
Function detect_Preisart(MA_ID As Long, Bez As String, ZUO_ID As Long) As Long

Dim kun_ID As Long
Dim VA_ID As Long

Dim pa_normal As Integer
Dim pa_nacht  As Integer
Dim pa_sonn   As Integer
Dim pa_feier  As Integer

    VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID=" & ZUO_ID)
    kun_ID = TLookup("Veranstalter_ID", AUFTRAGSTAMM, "ID=" & VA_ID)
    
        'Fussball?
    If kun_ID = 20771 Or kun_ID = 10720 Then
        pa_normal = 201
        pa_nacht = 211
        pa_sonn = 212
        pa_feier = 213
        
    Else
        pa_normal = 101
        pa_nacht = 111
        pa_sonn = 112
        pa_feier = 113
        
    End If
    

    Select Case Bez
        Case "Normal"
            detect_Preisart = pa_normal
            
        Case "Nacht"
            detect_Preisart = pa_nacht
            
        Case "Sonntag"
            detect_Preisart = pa_sonn
            
        Case "SonntagNacht"
            detect_Preisart = pa_nacht
            
        Case "Feiertag"
            detect_Preisart = pa_feier
            
        Case "FeiertagNacht"
            detect_Preisart = pa_nacht
            
    End Select
    

    'ggf Sonderlocken nach ZUO_ID
    
End Function


'Lohnart_ID ermitteln
Function detect_Lohnart(MA_ID As Long, Bez As String, Optional ZUO_ID As Long) As Long

Dim Lohnart_ID As Long

    Select Case Bez
        Case "Normal"
            Lohnart_ID = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
            If Lohnart_ID <> 0 Then detect_Lohnart = Lohnart_ID
            
        Case "Nacht"
            detect_Lohnart = 14
            
        Case "Sonntag"
            detect_Lohnart = 15
            
        Case "SonntagNacht"
            detect_Lohnart = 20
            
        Case "Feiertag"
            detect_Lohnart = 21
            
        Case "FeiertagNacht"
            detect_Lohnart = 22
        
        Case "Urlaub"
            detect_Lohnart = 27
        
        Case "Krank"
            detect_Lohnart = 28
        
        Case "Intern"
            Lohnart_ID = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
            If Lohnart_ID <> 0 Then detect_Lohnart = Lohnart_ID
            
        Case Else 'Dummy
            detect_Lohnart = 59
            
    End Select
    
    'ggf Sonderlocken nach ZUO_ID
    
End Function


'Lohn Berechnen
Function calc_Lohn(Lohnart_ID As Long, stunden As Double, VADatum As Date, Bez As String, Grundlohn As Double, Satz As Double) As Double

    If Bez = "Normal" Then
        calc_Lohn = stunden * Grundlohn
    Else
'        If Satz = 0 Then Satz = detect_satz(Lohnart_ID, Grundlohn, VADatum)
        calc_Lohn = Round(stunden * Satz, 2)
    End If

End Function


'Standardpreis ermitteln
Function detect_Spreis(kunnr As Long, PreisArt_ID As Long) As Double

    Dim spreis As String
    
    spreis = Nz(TLookup("StdPreis", "tbl_KD_Standardpreise", "kun_ID = " & kunnr & " AND Preisart_ID = " & PreisArt_ID), 0)
    If IsNumeric(spreis) Then detect_Spreis = spreis
    
End Function


'Preis Berechnen
Function calc_Preis(MA_ID, PreisArt_ID As Long, stunden As Double, VADatum As Date, spreis As Double) As Double

Dim kunnr   As Long
    
    kunnr = MA_ID
'    If kunnr <> 0 Then
'        If Spreis <> 0 Then Spreis = Nz(TLookup("StdPreis", "tbl_KD_Standardpreise", "kun_ID = " & kunnr & " AND Preisart_ID = " & PreisArt_ID), 0)
'    End If

    calc_Preis = Runden(spreis * stunden, 2)
    
End Function


'Grundlohn ermitteln
Function detect_grundlohn(Lohnart_ID As Long, VADatum As Date) As Double

Dim WHERE    As String

    'zum Datum gültiger Satz der Lohnart
    WHERE = " AND DatumBis >= " & DatumSQL(VADatum) & " AND Datumvon <= " & DatumSQL(VADatum)
    detect_grundlohn = Nz(TLookup("Grundlohn", LOHNARTEN, "ID = " & Lohnart_ID & WHERE), 0)
    
End Function


'Satz ermitteln
Function detect_satz(Lohnart_ID As Long, Grundlohn As Double, VADatum As Date) As Double

Dim WHERE    As String

    'zum Datum gültiger Satz der Lohnart
    WHERE = " AND DatumBis >= " & DatumSQL(VADatum) & " AND Datumvon <= " & DatumSQL(VADatum)
     
    detect_satz = Grundlohn * Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & WHERE), 0)
    
End Function

'Stunden- & Kostenberechnung NV
Function calc_NV_Stunden(NV_ID As Long, MA_ID As Long)

Dim sql             As String
Dim tbl             As String
Dim ABF             As String
Dim WHERE           As String
Dim Lohnart_grund   As Long
Dim Lohnart_ID      As Long
Dim Grundlohn       As Double
Dim bruttoKZ        As Boolean
Dim Bez             As String
Dim Datum           As Date
Dim vonZeit         As Date
Dim bisZeit         As Date
Dim Stunden_brutto  As Double

On Error GoTo Err
    

    tbl = ZUO_STD
    WHERE = "NV_ID = " & NV_ID
    ABF = "zqry_ZUO_ZK_Stunden_prepare"
    Datum = TLookup("vonDat", NVERFUEG, "ID = " & NV_ID)
    Bez = TLookup("Zeittyp_ID", NVERFUEG, "ID = " & NV_ID)
    
    If MA_ID <> 0 And (Bez = "Urlaub" Or Bez = "Krank" Or Bez = "Intern") Then
        Lohnart_grund = detect_Lohnart(MA_ID, "Normal")
        Grundlohn = detect_grundlohn(Lohnart_grund, Datum)
        Lohnart_ID = detect_Lohnart(MA_ID, Bez)
        bruttoKZ = True 'TLookup("IstNSB", MASTAMM, "ID = " & MA_ID)
        vonZeit = TLookup("vonZeit", NVERFUEG, "ID = " & NV_ID)
        bisZeit = TLookup("bisZeit", NVERFUEG, "ID = " & NV_ID)
        Stunden_brutto = stunden(vonZeit, bisZeit)
        If Stunden_brutto = 0 Or Round(Stunden_brutto, 0) = 24 Then Stunden_brutto = ArbStundenProTag(MA_ID)
        
        Call update_NV_Stunden(NV_ID, MA_ID, Lohnart_ID, Bez, Stunden_brutto, Datum, Grundlohn, bruttoKZ)
  
    Else
        'eventuell vorhandene Sätze löschen
        CurrentDb.Execute "DELETE FROM " & tbl & " WHERE " & WHERE
        
    End If
    
Ende:
    Exit Function
Err:
    writelog Server & "Database\Log\ztbl_ZUO_Stunden.txt", Now & "  " & Environ("UserName") & ", NV_ID: " & NV_ID & ", " & Err.Number & " " & Err.description
    Resume Ende
End Function

'Werte NV in ztbl_ZUO_Stunden updaten
Function update_NV_Stunden(NV_ID As Long, MA_ID As Long, Lohnart_ID As Long, Bez As String, stunden As Double, Datum As Date, Grundlohn As Double, bruttoKZ As Boolean)


Dim sql             As String
Dim tbl             As String
Dim rs              As Recordset

On Error GoTo Err

    tbl = ZUO_STD

    sql = "SELECT * FROM " & tbl & " WHERE NV_ID = " & NV_ID
    
    Set rs = CurrentDb.OpenRecordset(sql)
    
    If rs.EOF = True Then
        rs.AddNew
        rs.fields("NV_ID") = NV_ID
        rs.fields("Bezeichnung_kurz") = Bez
    Else
        rs.Edit
    End If
    'Mitarbeiterwechsel?
    If rs.fields("MA_ID") <> MA_ID Then rs.fields("Satz") = Null
    rs.fields("MA_ID") = MA_ID
    rs.fields("Stunden_brutto") = stunden
    rs.fields("Stunden_netto") = Round(stunden * 0.91, 2)
    rs.fields("Lohnstunden_brutto") = bruttoKZ
    rs.fields("Lohnart_ID") = Lohnart_ID
    If IsInitial(rs.fields("Satz")) Then rs.fields("Satz") = Grundlohn
    If bruttoKZ = True Then
        rs.fields("Lohn") = calc_Lohn(rs.fields("Lohnart_ID"), stunden, Datum, Bez, Grundlohn, Nz(rs.fields("Satz"), 0))
    Else
        rs.fields("Lohn") = calc_Lohn(rs.fields("Lohnart_ID"), rs.fields("Stunden_netto"), Datum, Bez, Grundlohn, Nz(rs.fields("Satz"), 0))
    End If
        
    rs.update
    rs.Close
    Set rs = Nothing
    
    
Ende:
    Exit Function
Err:
    writelog Server & "Database\Log\ztbl_ZUO_Stunden.txt", Now & "  " & Environ("UserName") & ", NV_ID: " & NV_ID & ", " & Err.Number & " " & Err.description
    Resume Ende
End Function


'Stunden- & Kostenberechnung komplett
Function calc_ZUO_Stunden_complete()

Dim rs      As Recordset
Dim MA_ID   As Long
Dim ZUO_ID  As Long
Dim VA_ID   As Long
Dim sql     As String
    
    sql = "SELECT * FROM " & ZUORDNUNG & " WHERE VADatum >= " & DatumSQL("01.01.2023")
    Set rs = CurrentDb.OpenRecordset(sql)
On Error Resume Next
    rs.MoveLast
    rs.MoveFirst
On Error GoTo 0
    Do While Not rs.EOF
        Debug.Print rs.AbsolutePosition
        MA_ID = Nz(rs.fields("MA_ID"), 0)
        ZUO_ID = rs.fields("ID")
        VA_ID = rs.fields("VA_ID")
        If MA_ID <> 0 Then _
            Call calc_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID)
            'Debug.Print VAStart_ID & "  " & ZUO_ID & "  " & MA_ID
        rs.MoveNext
    Loop

End Function


'Stunden- & Kostenberechnung komplett NV
Function calc_NV_Stunden_complete()

Dim rs      As Recordset
Dim MA_ID   As Long
Dim NV_ID   As Long
Dim sql     As String
    
    sql = "SELECT * FROM " & NVERFUEG & " WHERE vonDat >= " & DatumSQL("01.01.2023")
    Set rs = CurrentDb.OpenRecordset(sql)
On Error Resume Next
    rs.MoveLast
    rs.MoveFirst
On Error GoTo 0
    Do While Not rs.EOF
        Debug.Print rs.AbsolutePosition
        MA_ID = Nz(rs.fields("MA_ID"), 0)
        NV_ID = rs.fields("ID")
        If MA_ID <> 0 Then _
            Call calc_NV_Stunden(NV_ID, MA_ID)
        rs.MoveNext
    Loop

End Function


'Stunden- & Kostenberechnung für subunternehmer
Function calc_ZUO_Stunden_sub(VA_ID As Long, MA_ID As Long)

Dim rs      As Recordset
Dim ZUO_ID  As Long
Dim sql     As String
Dim IDs     As String
    
    IDs = select_in_string(ZUORDNUNG, "ID", "VA_ID = " & VA_ID & " AND MA_ID = " & MA_ID)
    Debug.Print IDs
    
    sql = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID & " AND MA_ID = " & MA_ID
    Set rs = CurrentDb.OpenRecordset(sql)
On Error Resume Next
    rs.MoveLast
    rs.MoveFirst
On Error GoTo 0
    Do While Not rs.EOF
        ZUO_ID = rs.fields("ID")
        Call calc_ZUO_Stunden(ZUO_ID, MA_ID, VA_ID)
        rs.MoveNext
    Loop

End Function


'Veranstaltungsdaten aufbereiten für Rechnung
Function get_VA_Data(VA_ID As Long) As VA_Data
Dim rsZUO           As Recordset
Dim sql             As String
Dim schicht         As Integer
Dim Datum           As Date
Dim Start           As Date
Dim Ende            As Date
Dim Nacht           As Double
Dim Sonntag         As Double
Dim Feiertag        As Double

    sql = "SELECT * FROM " & ZUORDNUNG & " WHERE VA_ID = " & VA_ID & " ORDER BY VADatum ASC, MA_Start ASC, MA_Ende ASC"
    Set rsZUO = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    schicht = -1
    
    Do While Not rsZUO.EOF
        'Erste Schicht oder neue Schicht?
        If Datum <> rsZUO.fields("VADatum") Or Start <> rsZUO.fields("MA_Start") Or Ende <> rsZUO.fields("MA_Ende") Then
            schicht = schicht + 1
            Datum = rsZUO.fields("VADatum")
            Start = rsZUO.fields("MA_Start")
            Ende = rsZUO.fields("MA_Ende")
        End If
        
        ReDim Preserve get_VA_Data.VA_Schichten(schicht)
        get_VA_Data.VA_Schichten(schicht).Datum = Datum
        get_VA_Data.VA_Schichten(schicht).Beginn = Start
        get_VA_Data.VA_Schichten(schicht).Ende = Ende
        get_VA_Data.VA_Schichten(schicht).Std = Round(stunden(Start, Ende), 2)
        
        'Normal
        If InStr(rsZUO.fields("Position"), "BL") <> 0 Then
            get_VA_Data.VA_Schichten(schicht).VA_Personen.persBerLeitung = get_VA_Data.VA_Schichten(schicht).VA_Personen.persBerLeitung + 1
            get_VA_Data.VA_Schichten(schicht).VA_Stunden.bereichsleitung = get_VA_Data.VA_Schichten(schicht).VA_Stunden.bereichsleitung + get_VA_Data.VA_Schichten(schicht).Std
            get_VA_Data.VA_Stunden.bereichsleitung = get_VA_Data.VA_Stunden.bereichsleitung + get_VA_Data.VA_Schichten(schicht).Std
        ElseIf rsZUO.fields("Einsatzleitung") = True Then
            get_VA_Data.VA_Schichten(schicht).VA_Personen.persLeitung = get_VA_Data.VA_Schichten(schicht).VA_Personen.persLeitung + 1
            get_VA_Data.VA_Schichten(schicht).VA_Stunden.leitung = get_VA_Data.VA_Schichten(schicht).VA_Stunden.leitung + get_VA_Data.VA_Schichten(schicht).Std
            get_VA_Data.VA_Stunden.leitung = get_VA_Data.VA_Stunden.leitung + get_VA_Data.VA_Schichten(schicht).Std
        Else
            get_VA_Data.VA_Schichten(schicht).VA_Personen.persSicherheit = get_VA_Data.VA_Schichten(schicht).VA_Personen.persSicherheit + 1
            get_VA_Data.VA_Schichten(schicht).VA_Stunden.sicherheit = get_VA_Data.VA_Schichten(schicht).VA_Stunden.sicherheit + get_VA_Data.VA_Schichten(schicht).Std
            get_VA_Data.VA_Stunden.sicherheit = get_VA_Data.VA_Stunden.sicherheit + get_VA_Data.VA_Schichten(schicht).Std
        End If
        
        'Nacht
        Nacht = Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "NACHT")
        get_VA_Data.VA_Schichten(schicht).VA_Stunden.Nacht = get_VA_Data.VA_Schichten(schicht).VA_Stunden.Nacht + Nacht
        get_VA_Data.VA_Stunden.Nacht = get_VA_Data.VA_Stunden.Nacht + Nacht
        
        'Sonntag Tag + Nacht
        Sonntag = Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "SONNTAG") + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "SONNTAGNACHT")
        get_VA_Data.VA_Schichten(schicht).VA_Stunden.Sonntag = get_VA_Data.VA_Schichten(schicht).VA_Stunden.Sonntag + Sonntag
        get_VA_Data.VA_Stunden.Sonntag = get_VA_Data.VA_Stunden.Sonntag + Sonntag
        
        'Feertag Tag + Nacht
        Feiertag = Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "FEIERTAG") + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "FEIERTAGNACHT")
        get_VA_Data.VA_Schichten(schicht).VA_Stunden.Feiertag = get_VA_Data.VA_Schichten(schicht).VA_Stunden.Feiertag + Feiertag
        get_VA_Data.VA_Stunden.Feiertag = get_VA_Data.VA_Stunden.Feiertag + Feiertag
        
        rsZUO.MoveNext
    
    Loop
    
    rsZUO.Close
    Set rsZUO = Nothing
    
End Function



''Stundenberechnung für Rechnungen (Wegen Rundungsdifferenzen nach VAStart_ID!)
'Function get_std_rch(VA_ID As Long) As VA_Stunden
'Dim rsStart         As Recordset
'Dim sql             As String
'Dim Start           As VA_Stunden
'
'    'select_in_array(zuordnung,"VAStart_ID","VA_ID=" & va_id)
'    'select_in_string(zuordnung,"VAStart_ID","VA_ID=" & va_id)
'    sql = "SELECT * FROM " & VASTART & " WHERE VA_ID = " & VA_ID
'    Set rsStart = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
'
'    Do While Not rsStart.EOF
'        Start = get_std_VAStart(rsStart.fields("ID"))
'        get_std_rch.sicherheit = get_std_rch.sicherheit + Start.sicherheit
'        get_std_rch.leitung = get_std_rch.leitung + Start.leitung
'        get_std_rch.bereichsleitung = get_std_rch.bereichsleitung + Start.bereichsleitung
'        get_std_rch.nacht = get_std_rch.nacht + Start.nacht
'        get_std_rch.sonntag = get_std_rch.sonntag + Start.sonntag
'        get_std_rch.feiertag = get_std_rch.feiertag + Start.feiertag
''        get_std_rch.persSicherheit = get_std_rch.persSicherheit + Start.persSicherheit
''        get_std_rch.persLeitung = get_std_rch.persLeitung + Start.persLeitung
''        get_std_rch.persBerLeitung = get_std_rch.persBerLeitung + Start.bereichsleitung
'        rsStart.MoveNext
'
'    Loop
'
'    rsStart.Close
'    Set rsStart = Nothing
'
'End Function
'
'
''Stundenberechnung für Rechnungen nach VAStart_ID
'Function get_std_VAStart(VAStart_ID As Long) As VA_Stunden
'Dim rsZUO           As Recordset
'Dim sql             As String
'Dim sicherheit      As Double
'Dim leitung         As Double
'Dim bereichsleitung As Double
'Dim nacht           As Double
'Dim sonntag         As Double
'Dim feiertag        As Double
'Dim persSicherheit  As Integer
'Dim persLeitung     As Integer
'Dim persBL          As Integer
'
'    sql = "SELECT * FROM " & ZUORDNUNG & " WHERE VAStart_ID = " & VAStart_ID
'    Set rsZUO = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
'
'    Do While Not rsZUO.EOF
'        If rsZUO.fields("Einsatzleitung") = True Then
'            If InStr(rsZUO.fields("Position"), "BL") <> "" Then
'                bereichsleitung = bereichsleitung + stunden(rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"))
'                persBL = persBL + 1
'            Else
'                leitung = leitung + stunden(rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"))
'                persLeitung = persLeitung + 1
'            End If
'        Else
'            sicherheit = sicherheit + stunden(rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"))
'            persSicherheit = persSicherheit + 1
'        End If
'        'Nacht
'        nacht = nacht + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "NACHT")
'        'Sonntag Tag + Nacht
'        sonntag = sonntag + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "SONNTAG") + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "SONNTAGNACHT")
'        'Feertag Tag + Nacht
'        feiertag = feiertag + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "FEIERTAG") + Stunden_Zuschlag(rsZUO.fields("VADatum"), rsZUO.fields("MA_Start"), rsZUO.fields("MA_Ende"), "FEIERTAGNACHT")
'
'        rsZUO.MoveNext
'
'    Loop
'
'    rsZUO.Close
'    Set rsZUO = Nothing
'
'    get_std_VAStart.sicherheit = Round(sicherheit, 2)
'    get_std_VAStart.leitung = Round(leitung, 2)
'    get_std_VAStart.bereichsleitung = Round(bereichsleitung, 2)
'    get_std_VAStart.nacht = Round(nacht, 2)
'    get_std_VAStart.sonntag = Round(sonntag, 2)
'    get_std_VAStart.feiertag = Round(feiertag, 2)
''    get_std_VAStart.persSicherheit = persSicherheit
''    get_std_VAStart.persLeitung = persLeitung
''    get_std_VAStart.persBerLeitung = persBL
'
'End Function



Function fill_Berechnungsliste(VA_ID As Long)
Dim tbl         As String
Dim rs          As Recordset
Dim sql         As String
Dim VA          As VA_Data
Dim i           As Integer
Dim kun_ID      As Long
Dim Datum       As Date
Dim Zeile       As Integer


    tbl = RCHLIST
    sql = "DELETE * FROM " & tbl & " WHERE VA_ID=" & VA_ID & " AND auto=true"
    CurrentDb.Execute sql
    Set rs = CurrentDb.OpenRecordset(tbl)
    kun_ID = TLookup("Veranstalter_ID", AUFTRAGSTAMM, "ID=" & VA_ID)
    VA = get_VA_Data(VA_ID)
    
    Zeile = 1
    For i = LBound(VA.VA_Schichten) To UBound(VA.VA_Schichten)
        'Sicherheitspersonal
        If VA.VA_Schichten(i).VA_Personen.persSicherheit > 0 Then
            rs.AddNew
            If Datum <> VA.VA_Schichten(i).Datum Then
                Datum = VA.VA_Schichten(i).Datum
                rs.fields("datum") = Datum
            End If
            rs.fields("VA_ID") = VA_ID
            rs.fields("menge") = VA.VA_Schichten(i).VA_Personen.persSicherheit
            rs.fields("bezeichnung") = "Sicherheitspersonal"
            rs.fields("von") = VA.VA_Schichten(i).Beginn
            rs.fields("bis") = VA.VA_Schichten(i).Ende
            rs.fields("stunden") = VA.VA_Schichten(i).Std
            rs.fields("summe_std") = VA.VA_Schichten(i).VA_Stunden.sicherheit
            rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=1")
            rs.fields("summe") = rs.fields("summe_std") * rs.fields("faktor")
            rs.fields("auto") = True
            rs.fields("sort") = Zeile
            Zeile = Zeile + 1
            rs.update
        End If
        'Bereichsleitung
        If VA.VA_Schichten(i).VA_Personen.persBerLeitung > 0 Then
            rs.AddNew
            If Datum <> VA.VA_Schichten(i).Datum Then
                Datum = VA.VA_Schichten(i).Datum
                rs.fields("datum") = Datum
            End If
            rs.fields("VA_ID") = VA_ID
            rs.fields("menge") = VA.VA_Schichten(i).VA_Personen.persBerLeitung
            rs.fields("bezeichnung") = "Bereichsleitung"
            rs.fields("von") = VA.VA_Schichten(i).Beginn
            rs.fields("bis") = VA.VA_Schichten(i).Ende
            rs.fields("stunden") = VA.VA_Schichten(i).Std
            rs.fields("summe_std") = VA.VA_Schichten(i).VA_Stunden.bereichsleitung
            rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=2")
            rs.fields("summe") = rs.fields("summe_std") * rs.fields("faktor")
            rs.fields("auto") = True
            rs.fields("sort") = Zeile
            Zeile = Zeile + 1
            rs.update
        End If
        'Leitungspersonal
        If VA.VA_Schichten(i).VA_Personen.persLeitung > 0 Then
            rs.AddNew
            If Datum <> VA.VA_Schichten(i).Datum Then
                Datum = VA.VA_Schichten(i).Datum
                rs.fields("datum") = Datum
            End If
            rs.fields("VA_ID") = VA_ID
            rs.fields("menge") = VA.VA_Schichten(i).VA_Personen.persLeitung
            rs.fields("bezeichnung") = "Leitungspersonal"
            rs.fields("von") = VA.VA_Schichten(i).Beginn
            rs.fields("bis") = VA.VA_Schichten(i).Ende
            rs.fields("stunden") = VA.VA_Schichten(i).Std
            rs.fields("summe_std") = VA.VA_Schichten(i).VA_Stunden.leitung
            rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=3")
            rs.fields("summe") = rs.fields("summe_std") * rs.fields("faktor")
            rs.fields("auto") = True
            rs.fields("sort") = Zeile
            Zeile = Zeile + 1
            rs.update
        End If
    Next i

    'Nachtarbeit
    If VA.VA_Stunden.Nacht > 0 Then
        rs.AddNew
        rs.fields("VA_ID") = VA_ID
        'rs.fields("menge") = VA.VA_Stunden.nacht
        rs.fields("bezeichnung") = "Nachtarbeit"
        'rs.fields("stunden") = VA.VA_Stunden.nacht
        rs.fields("summe_std") = VA.VA_Stunden.Nacht
        rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=11")
        rs.fields("summe") = rs.fields("summe_std") * rs.fields("faktor")
        rs.fields("auto") = True
        rs.fields("sort") = Zeile
        Zeile = Zeile + 1
        rs.update
    End If
    'Sonntagsarbeit
    If VA.VA_Stunden.Sonntag > 0 Then
        rs.AddNew
        rs.fields("VA_ID") = VA_ID
        'rs.fields("menge") = VA.VA_Stunden.sonntag
        rs.fields("bezeichnung") = "Sonntagsarbeit"
        'rs.fields("stunden") = VA.VA_Stunden.sonntag
        rs.fields("summe_std") = VA.VA_Stunden.Sonntag
        rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=12")
        rs.fields("summe") = rs.fields("summe_std") * rs.fields("faktor")
        rs.fields("auto") = True
        rs.fields("sort") = Zeile
        Zeile = Zeile + 1
        rs.update
    End If
    'Feiertagsarbeit
    If VA.VA_Stunden.Feiertag > 0 Then
        rs.AddNew
        rs.fields("VA_ID") = VA_ID
        'rs.fields("menge") = VA.VA_Stunden.feiertag
        rs.fields("bezeichnung") = "Feiertagsarbeit"
        'rs.fields("stunden") = VA.VA_Stunden.feiertag
        rs.fields("summe_std") = VA.VA_Stunden.Feiertag
        rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=13")
        rs.fields("summe") = rs.fields("summe_std") * rs.fields("faktor")
        rs.fields("auto") = True
        rs.fields("sort") = Zeile
        Zeile = Zeile + 1
        rs.update
    End If
    'Fahrtkosten
    If TLookup("Dummy", AUFTRAGSTAMM, "ID=" & VA_ID) > 0 Then
        rs.AddNew
        rs.fields("VA_ID") = VA_ID
        rs.fields("menge") = TLookup("Dummy", AUFTRAGSTAMM, "ID=" & VA_ID)
        rs.fields("bezeichnung") = "Fahrtkosten"
        'rs.fields("stunden") = VA.VA_Stunden.feiertag
        'rs.fields("summe_std") = VA.VA_Stunden.Feiertag
        'rs.fields("faktor") = TLookup("StdPreis", SPREISE, "kun_ID=" & kun_ID & " AND Preisart_ID=4")
        rs.fields("faktor") = TLookup("Fahrtkosten", AUFTRAGSTAMM, "ID=" & VA_ID)
        rs.fields("summe") = rs.fields("menge") * rs.fields("faktor")
        rs.fields("auto") = True
        rs.fields("sort") = Zeile
        Zeile = Zeile + 1
        rs.update
    End If

    rs.Close
    Set rs = Nothing
    
    'Sortierung manueller Eingaben überschreiben
    Zeile = Nz(TMax("sort", tbl, "VA_ID=" & VA_ID & " AND auto=true"), 0) + 1
    sql = "SELECT * FROM " & tbl & " WHERE VA_ID=" & VA_ID & " AND auto=false ORDER BY sort ASC"
    Set rs = CurrentDb.OpenRecordset(sql)
    Do While Not rs.EOF
        rs.Edit
        rs.fields("sort") = Zeile
        rs.update
        rs.MoveNext
        Zeile = Zeile + 1
    Loop
    
    rs.Close
    Set rs = Nothing

End Function

Sub test()

Dim Std As VA_Data

Std = get_VA_Data(9059)
End Sub
