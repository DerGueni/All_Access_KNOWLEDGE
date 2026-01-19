Attribute VB_Name = "zmd_Zeitkonten"
Option Compare Database
Option Explicit

'Zeitkonto
Type ZK_Satz
    MA_ID           As String
    Datum           As Date
    Veranstaltung   As String
    Beginn          As Date
    Ende            As Date
    AW              As Double
    AZ              As Double
    AZ_andere       As Double
    AZ_Reinigung    As Double
    U               As Double
    AU              As Double
    WerktagNacht    As Double
    Sonntag         As Double
    SonntagNacht    As Double
    Feiertag        As Double
    FeiertagNacht   As Double
    andere_Nacht    As Double
    andere_So_FT    As Double
    Reiseko         As Double
    p_Fahrk         As Double
    Abzüge          As Double
    Auszahlung      As Double
End Type


'Lexware Import
Type Import_Lex
    Jahr    As Integer
    Monat   As Integer
    MA_ID   As Integer
    Lex_ID  As Integer
    L_ART   As Long
    Wert    As Double
    Satz    As Double
    'AnstArt As Integer
End Type


Const SatzNormal        As Double = 13.5
Const SatzNacht         As Double = SatzNormal * 0.23
Const SatzSonn          As Double = SatzNormal * 0.26
Const SatzSonnNacht     As Double = SatzNormal * 0.03
Const SatzFeier         As Double = SatzNormal * 1
Const SatzFeierNacht    As Double = SatzNormal * 0.77
Const SatzFGUZu         As Double = 1.5
Const SatzFGUZu2        As Double = 1.5

Dim lex()           As Import_Lex
Dim c               As Integer


Function import_Zeitkonten(Monat As Integer, Jahr As Integer)

Dim xlApp           As Object, xlWb As Object
Dim fso             As New Scripting.FileSystemObject
Dim fol             As folder
Dim Fil             As file
Dim PfadZeitkonten  As String
Dim Name            As String
Dim PersNr          As Variant
Dim LexID           As Variant
Dim Wert            As Double
Dim rs              As Recordset
Dim i               As Integer
Dim Bereich         As Variant
Dim strMonat        As String
Dim Lohnart         As String
Dim Sheet           As String
Dim Satz            As String


On Error GoTo Err

    c = 0
    ReDim lex(c)
    
    PfadZeitkonten = PfadZK
    
    'Wenn Pfad nicht existiert -> letztes Jahr
    If Dir(PfadZeitkonten, vbDirectory) = "" Then PfadZeitkonten = PfadZuBerechnen & Year(Date) - 1 & " Zeitkonten"
    
    'Wenn Pfad nicht existiert -> Fehler
    If Dir(PfadZeitkonten, vbDirectory) = "" Then Err.Raise 76, , PfadZeitkonten & vbCrLf & " nicht gefunden!"
    
    Set fol = fso.GetFolder(PfadZeitkonten)
    Set xlApp = CreateObject("Excel.Application")
    xlApp.DisplayAlerts = False
    xlApp.Visible = True
            
    'Importfehler löschen
    CurrentDb.Execute "DELETE * FROM [ztbl_ZK_Importfehler] WHERE [Jahr] = " & Jahr & " AND [Monat] = " & Monat & ";"
    
    'Zeitkonto suchen
    For Each Fil In fol.files
        'Name des Kollegen
        Name = UCase(Left(Fil.Name, Len(Fil.Name) - (Len(Fil.Name) - InStrRev(Fil.Name, ".")) - 1))
        PersNr = get_PersNr(Name)
        
        'Wenn keine Personalnummer aus dem Namen ermittelt werden konnte,
        'Datei öffnen und mit Wert aus Blatt 1 Zelle B1 versuchen
        If PersNr = 0 And InStr(Fil.Name, ".xl") Then
            Set xlWb = xlApp.Workbooks.Open(Fil.path, False, False)
            Name = xlWb.Sheets(1).Range("B1")
            PersNr = get_PersNr(Name)
            xlWb.Close False
        End If
        
        If PersNr <> 0 Then
            'Lexware-ID
            LexID = TLookup("LEXWare_ID", MASTAMM, "ID = " & PersNr)
            If IsNull(LexID) Then LexID = 9999
            'Prüfung Monat Zelle A2???
            Set xlWb = xlApp.Workbooks.Open(Fil.path, False, True)
            
            'Lohnarten aus Bereichen auslesen
            strMonat = Monat
            If Len(strMonat) = 1 Then strMonat = "0" & strMonat
            
            'Loop über benannte Bereiche im Workbook
            For Each Bereich In xlWb.Names
                If InStr(Bereich.Name, "_" & strMonat & "_") Then
                    'clear Lohnart, Wert, Satz, Sheet
                    Satz = Mid(Bereich.Name, InStr(Bereich.Name, "Satz"), InStr(10, Bereich.Name, "_") - InStr(Bereich.Name, "Satz"))
                    Satz = get_Satz(Satz)
                    'Lohnart aus Bereich
                    Lohnart = Right(Bereich.Name, Len(Bereich.Name) - InStrRev(Bereich.Name, "_"))
                    'Tabellenblatt im Zeitkonto
                    Sheet = Mid(Bereich.RefersTo, 2, InStr(Bereich.RefersTo, "!") - 2)
                    'Stundenwert im benannten Bereich
                    Wert = xlWb.Sheets(Sheet).Range(Bereich).Value
                    'Daten Array puffern
                    If Wert <> 0 Then
                        Call hinzufuegen(PersNr, LexID, Jahr, strMonat, Lohnart, Wert, Satz)
                    Else
                        'erfasse_Fehler "WERT 0 im Zeitkonto!", fil.Name, Jahr, Monat, PersNr, "keine Stunden in Zeitkonto, " & Bereich.Name & ", " & Bereich.RefersTo
                    End If
                    
                End If
            Next Bereich
        
            xlWb.Close False
        Else
            erfasse_Fehler "Keine Personalnummer zu Name " & Name & " gefunden", Fil.Name, Jahr, Monat, PersNr, "prüfen"
        End If
        
    Next Fil
    
    
    'Bereits importierte Werte löschen
    loeschen_import Monat, Jahr
            
    'Daten in Tabelle schreiben
    Set rs = CurrentDb.OpenRecordset("ztbl_Stunden_Lexware", dbOpenDynaset)
    For i = LBound(lex) To UBound(lex)
        rs.AddNew
        rs.fields(0) = lex(i).Jahr
        rs.fields(1) = lex(i).Monat
        rs.fields(2) = lex(i).Lex_ID
        rs.fields(3) = lex(i).L_ART
        rs.fields(4) = Runden(lex(i).Wert, 2)
        rs.fields(5) = lex(i).Satz
        rs.update
    Next i
    
    
Ende:
On Error Resume Next
    rs.Close
    xlApp.DisplayAlerts = True
    xlApp.Quit
    Set xlApp = Nothing
    Set xlWb = Nothing
    Set rs = Nothing
    Exit Function
Err:
    If Not Bereich Is Nothing Then
        erfasse_Fehler Err.Number & " " & Err.description, Fil.Name, Jahr, Monat, PersNr, "übersprungen - prüfen! -> " & Bereich.Name & ", " & Bereich.RefersTo
    Else
        erfasse_Fehler Err.Number & " " & Err.description, Fil.Name, Jahr, Monat, PersNr, "übersprungen - prüfen! "
    End If
    Resume Next
End Function


'Importierte Daten löschen
Function loeschen_import(Monat As Integer, Jahr As Integer, Optional ByVal Lex_ID As Integer)
    
Dim sql       As String
    
    If Lex_ID = 0 Then
        'Import löschen Monat alle MA
        sql = "DELETE * FROM [ztbl_Stunden_Lexware] WHERE [Jahr] = " & Jahr & " AND [Monat] = " & Monat & ";"
    Else
        'Import löschen ein MA
        sql = "DELETE * FROM [ztbl_Stunden_Lexware] WHERE [Jahr] = " & Jahr & " AND [Monat] = " & Monat & " AND [Personalnummer] = " & Lex_ID & ";"
    End If
    CurrentDb.Execute sql
    
End Function


'Satz ermitteln
Function get_Satz(Satz As String) As Double

    Select Case Satz
        Case "SatzNormal"
            get_Satz = SatzNormal
        Case "SatzNacht"
            get_Satz = SatzNacht
        Case "SatzSonn"
            get_Satz = SatzSonn
        Case "SatzSonnNacht"
            get_Satz = SatzSonnNacht
        Case "SatzFeier"
            get_Satz = SatzFeier
        Case "SatzFeierNacht"
            get_Satz = SatzFeierNacht
        Case "SatzFGUZu"
            get_Satz = SatzFGUZu
        Case "SatzFGUZu2"
            get_Satz = SatzFGUZu2
        Case Else
            Satz = 0
    End Select
    
End Function


'Personalnummer ermitteln
Function get_PersNr(Name As String) As Integer

Dim Vorname     As String
Dim Nachname    As String
Dim sql         As String

On Error GoTo Err

    sql = "SELECT [ID] FROM [zqry_hlp_MA_Zeitkonten] WHERE [Name] LIKE '" & Name & "';"
    get_PersNr = DBEngine(0)(0).OpenRecordset(sql, dbOpenSnapshot)(0)
    Exit Function
 
Err:
    get_PersNr = 0
 
End Function


'Eintrag hinzufügen (Lexware)
Function hinzufuegen(PersNr, LexID, Jahr, Monat, LArt, Wert, Satz)

Dim Monat_str As String
    
    Monat_str = Monat
    If Len(Monat_str) = 1 Then Monat_str = 0 & Monat_str
    
    ReDim Preserve lex(c)
    lex(c).MA_ID = PersNr
    lex(c).Lex_ID = LexID
    lex(c).Jahr = Jahr
    lex(c).Monat = Monat_str
    lex(c).L_ART = LArt
    lex(c).Wert = Wert
    lex(c).Satz = Satz
    'LEX(c).AnstArt = TLookup("Anstellungsart_ID", MASTAMM, "ID = " & PersNr)
    c = c + 1
    
End Function


'Importfehler erfassen
Function erfasse_Fehler(Fehler As String, Optional Datei As String, Optional Jahr As Integer, _
    Optional Monat As Integer, Optional ByVal MA_ID As Integer, Optional Bemerkung As String)

Dim rs As Recordset

On Error Resume Next

    'Daten in Tabelle schreiben
    Set rs = CurrentDb.OpenRecordset("ztbl_ZK_Importfehler", dbOpenDynaset)
    rs.AddNew
    rs.fields(0) = Datei
    rs.fields(1) = Jahr
    rs.fields(2) = Monat
    rs.fields(3) = MA_ID
    rs.fields(4) = Fehler
    rs.fields(5) = Bemerkung
    rs.fields(6) = Environ("UserName")
    rs.fields(7) = Now
    rs.update
    rs.Close
    Set rs = Nothing
    
End Function



'###############################################
' AB HIER FORTSCHREIBUNG DER ZEITKONTEN
'###############################################

'Test: ZK_Daten_uebertragen 204, "01.04.2022","30.04.2022"
'Daten in Zeitkonto uebertragen
Function ZK_Daten_uebertragen(MA_ID As Integer, von As Date, bis As Date, Optional ZK_offen As Boolean, Optional abrechnung As Boolean) As String

Dim xlApp       As Object
Dim xlWb        As Object
Dim DateiZK     As String
Dim rs          As Recordset
Dim sql         As String
Dim zk()        As ZK_Satz
Dim c           As Integer
Dim rc          As String
Dim StdAbw      As Double  'Stunden Abwesenheit
Dim Warnung     As String
Dim IstNSB      As Boolean
Dim anzTageU    As Integer 'Anzahl Urlaubstage
Dim anzTageAU   As Integer 'Anzahl Krankheitstage
Dim StProTag    As Double  'Stunden pro Tag
Dim TagProWoch  As Double  'Arbeitstage pro Woche
Dim AnteilTage  As Double  'Prozentualer Anteil Arbeitstage
Dim IstTageAbw  As Double  'Zähler eingetragene Tage Abwesenheit
Dim SollTageAbw As Double  'Anzahl einzutragende Tage Abwesenheit

On Error GoTo Err

    'Datei Zeitkonto ermitteln
    DateiZK = ZK_Datei_ermitteln(MA_ID)
    
    'Exit, wenn Zeitkonto nicht gefunden
    If DateiZK = "" Then Err.Raise 76, , "Excel-Datei Zeitkonto " & MA_ID & " nicht gefunden!"
    
    'Brutto Std = Netto Std?
    IstNSB = TLookup("IstNSB", MASTAMM, "ID = " & MA_ID)
    
    'Excel starten
    Set xlApp = CreateObject("Excel.Application")
'    If ZK_offen = False Then
'        xlApp.Visible = True
'        'xlApp.DisplayFullScreen = True           'blendet nur Menüleiste aus
'        'xlApp.ActiveWindow.WindowState = -4137   'WIRFT FEHLER 91!!!!!
'    Else
        xlApp.Visible = False
'    End If
    
    Set xlWb = xlApp.Workbooks.Open(DateiZK, False, False)
    
    'Array leeren
    Erase zk
    c = 0
    
'    'Werte aus Zeitkonto einlesen - WIRD NICHT VERWENDET!
'    zk() = ZK_einlesen(xlWB, von, bis)
'    'Werte zur Übernahme vorhanden?
'    If zk(0).Datum <> 0 Then
'        c = UBound(zk) + 1
'    Else
'        c = 0
'    End If
    
    'EINTRÄGE AUS VERANSTALTUNGEN ERMITTELN (PRIO1)
    sql = "SELECT * FROM [qry_MA_VA_Plan_All_AufUeber2_Zuo] WHERE MA_ID = " & MA_ID & _
        " AND VADatum BETWEEN " & DatumSQL(von) & " AND " & DatumSQL(bis) & ";"
    
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    Do While Not rs.EOF
        ReDim Preserve zk(c)
        
        zk(c).MA_ID = MA_ID
        zk(c).Veranstaltung = rs.fields("Auftrag") & " " & rs.fields("Objekt") & " " & rs.fields("Ort")
        zk(c).Datum = rs.fields("VADatum")
        zk(c).Beginn = rs.fields("Beginn")
        zk(c).Ende = rs.fields("Ende")
        zk(c).AW = stunden(zk(c).Beginn, zk(c).Ende)
        'Brutto = Netto Std?
        If IstNSB = False Then
            zk(c).AZ = zk(c).AW * 0.91
        Else
            zk(c).AZ = zk(c).AW
        End If
        
        zk(c).WerktagNacht = Stunden_Zuschlag(rs.fields("VADatum"), rs.fields("Beginn"), rs.fields("Ende"), "NACHT_GESAMT")
        zk(c).Sonntag = Stunden_Zuschlag(rs.fields("VADatum"), rs.fields("Beginn"), rs.fields("Ende"), "SONNTAG")
        zk(c).SonntagNacht = Stunden_Zuschlag(rs.fields("VADatum"), rs.fields("Beginn"), rs.fields("Ende"), "SONNTAGNACHT")
        zk(c).Feiertag = Stunden_Zuschlag(rs.fields("VADatum"), rs.fields("Beginn"), rs.fields("Ende"), "FEIERTAG")
        zk(c).FeiertagNacht = Stunden_Zuschlag(rs.fields("VADatum"), rs.fields("Beginn"), rs.fields("Ende"), "FEIERTAGNACHT")
        If Not IsInitial(rs.fields("PKW")) Then zk(c).p_Fahrk = rs.fields("PKW")
        
        'Sonderfall Flüchtlingsunterkunft
        If InStr(zk(c).Veranstaltung, "Flüchtlingsunterkunft") <> 0 Then zk(c).AZ_andere = zk(c).AZ
         
        rs.MoveNext
        c = c + 1
    Loop
    
    
    'EINTRÄGE AUS URLAUB/KRANKHEIT/INTERN ERMITTELN (Prio2)
    sql = "SELECT * FROM [zqry_ZK_MA_Urlaub_Krank_Intern] WHERE MA_ID = " & MA_ID & _
        " AND vonTag BETWEEN " & DatumSQL(von) & " AND " & DatumSQL(bis) & ";"
    
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    StProTag = Nz(TLookup("Arbst_pro_Arbeitstag", MASTAMM, "ID = " & MA_ID), 0)
    TagProWoch = Nz(TLookup("Arbeitstage_pro_Woche", MASTAMM, "ID = " & MA_ID), 0)
    
    'Anzahl Abwesenheitstage
    anzTageU = TCount("*", "zqry_ZK_MA_Urlaub_Krank_Intern", "MA_ID = " & MA_ID & " AND vonTag BETWEEN " & DatumSQL(von) & " AND " & DatumSQL(bis) & " AND Zeittyp_ID = 'Urlaub';")
    anzTageAU = TCount("*", "zqry_ZK_MA_Urlaub_Krank_Intern", "MA_ID = " & MA_ID & " AND vonTag BETWEEN " & DatumSQL(von) & " AND " & DatumSQL(bis) & " AND Zeittyp_ID = 'Krank';")
    
    'Berechnung (Ausgehend von 5 Arbeitstagen pro Woche)
    If TagProWoch <> 0 Then
        AnteilTage = TagProWoch / 5
        SollTageAbw = (anzTageU + anzTageAU) * AnteilTage
    Else
        SollTageAbw = anzTageU + anzTageAU
    End If
    
    IstTageAbw = 0
    
    Do While Not rs.EOF
        
        'Wenn mehrere Tage in Abwesenheit -> WARNUNG
        If rs.fields("vonTag") <> rs.fields("bisTag") Then Warnung = "Urlaub/Krankheit/AZ_andere prüfen!"
        
        ReDim Preserve zk(c)
        
        zk(c).MA_ID = MA_ID
        zk(c).Veranstaltung = rs.fields("Zeittyp_ID") & " " & rs.fields("Bemerkung")
        zk(c).Datum = rs.fields("vonTag")
        
        'Urlaub / Krankheit -> Werte aus MAStamm, sofern gepflegt, sonst eingetragene Zeit (Max 12h)
        StdAbw = 0
        StdAbw = stunden(rs.fields("vonZeit"), rs.fields("bisZeit")) '
        If StdAbw > 12 Then StdAbw = 12
        
        'Zuweisung Abwesenheit
        Select Case rs.fields("Zeittyp_ID")
            Case "Urlaub"         'EINTRAG URLAUB OHNE STUNDEN, ZU VIELE SONDERFÄLLE :(
'                If IstTageAbw < SollTageAbw Then
                    If StProTag <> 0 Then
                        zk(c).U = StProTag
                    Else
                        zk(c).U = StdAbw
                    End If
'                    IstTageAbw = IstTageAbw + 1
'                End If
            Case "Krank"         'EINTRAG KRANK OHNE STUNDEN, ZU VIELE SONDERFÄLLE :(
'                If IstTageAbw < SollTageAbw Then
                    If StProTag <> 0 Then
                        zk(c).AU = StProTag
                    Else
                        zk(c).AU = StdAbw
                    End If
'                    IstTageAbw = IstTageAbw + 1
'                End If
            Case "Intern"
                zk(c).AZ_Reinigung = StdAbw
                If zk(c).AZ_andere = 0 Then zk(c).AZ_andere = StdAbw
                zk(c).Beginn = rs.fields("vonZeit")
                zk(c).Ende = rs.fields("bisZeit")
        End Select
        
        rs.MoveNext
        c = c + 1
    Loop
    
    'Daten in Zeitkonto eintragen (wenn vorhanden)
    'If zk(0).Datum <> 0 Then rc = ZK_eintragen(xlWB, zk)
    If (0 / 1) + (Not Not zk) Then
        rc = ZK_eintragen(xlWb, zk, abrechnung)
    Else
        rc = "Zeitkonto  " & Left(xlWb.Name, Len(xlWb.Name) - 4) & ": Keine Einsätze!"
    End If
    
    ZK_Daten_uebertragen = rc & Warnung
    
    'Zeitkonto sichern + schließen bei Massenbearbeitung
    If ZK_offen = False Then
        If xlWb.ReadOnly = False Then
            xlWb.Close True
        Else
            xlWb.Close False
            ZK_Daten_uebertragen = "Zeitkonto " & xlWb.Name & " speichern nicht möglich!!!"
        End If
    Else
        xlApp.Visible = True
        xlApp.ActiveWindow.WindowState = -4137
        xlWb.Save
    End If

    
Ende:
    If ZK_offen = False Then
On Error Resume Next
        xlWb.Close False
        xlApp.Quit
    End If
    Set xlApp = Nothing
    Set xlWb = Nothing
    Exit Function
Err:
    ZK_Daten_uebertragen = Err.Number & " " & Err.description
    ZK_offen = False
    Resume Ende
End Function



'Eintrag in Zeitkonto
Function ZK_eintragen(xlWb As Object, zk() As ZK_Satz, Optional abrechnung As Boolean) As String

Dim ws          As Object
Dim i           As Integer
Dim Zeile       As Integer
Dim Monat       As Integer
Dim Jahr        As Integer
Dim clear       As Integer 'Zeitkonto leeren?
   
On Error GoTo Err
    
    'Workbook nicht übergeben
    If xlWb Is Nothing Then Err.Raise 76, , "Excel Workbook nicht gefunden!"
    
    'übergebenes Array Sortieren
    zk_sortieren zk
    
    For i = LBound(zk) To UBound(zk)
        Monat = Month(zk(i).Datum)
        Jahr = Year(zk(i).Datum)
        
        Set ws = xlWb.Sheets(Monat)
        
        With ws
            .Select
            .Range("A4").Select
            'Prüfen, ob Zeitkonto gesperrt ist (Zelle C1 leer!)
            If .Range("C1") = "" Then
            
                'Einträge im Zeitkonto löschen(xlCellTypeConstants = 2)
                If clear <> Monat Then
On Error Resume Next 'Fehler, wenn Bereich komplett leer ist!!!
                    .Range("B4:U65").SpecialCells(2).ClearContents 'bis Reisekosten leeren
On Error GoTo Err
                    clear = Monat
                End If
            
                'Zeile (Tag) ermitteln
                Zeile = .Range("A:A").Find(Day(zk(i).Datum)).row
                'besetzt? -> Versuch in Zeile 2
                If .Range("B" & Zeile) <> "" Then Zeile = Zeile + 1
                'besetzt? -> Fehlereintrag
                If .Range("B" & Zeile) <> "" Then
                    ZK_schreibe_Fehler zk(i)
                
                Else 'eintragen
                    .Range("B" & Zeile) = zk(i).Veranstaltung
                    .Range("C" & Zeile) = zk(i).Beginn
                    .Range("D" & Zeile) = zk(i).Ende
                    .Range("E" & Zeile) = zk(i).AW
                    .Range("F" & Zeile) = zk(i).AZ

                    .Range("G" & Zeile) = zk(i).U
                    .Range("H" & Zeile) = zk(i).AU
                    If zk(i).AZ_andere <> 0 Then
                        If InStr(zk(i).Veranstaltung, "Büro") <> 0 Then ws.Range("I" & Zeile) = zk(i).AZ_andere
                        If InStr(zk(i).Veranstaltung, "München") <> 0 Then ws.Range("J" & Zeile) = zk(i).AZ_andere
                        If InStr(zk(i).Veranstaltung, "Mannheim") <> 0 Then ws.Range("K" & Zeile) = zk(i).AZ_andere
                        If InStr(zk(i).Veranstaltung, "Flüchtling") <> 0 Then ws.Range("L" & Zeile) = zk(i).AZ_andere
                    End If
                    .Range("M" & Zeile) = zk(i).WerktagNacht
                    .Range("N" & Zeile) = zk(i).Sonntag
                    .Range("O" & Zeile) = zk(i).SonntagNacht
                    .Range("P" & Zeile) = zk(i).Feiertag
                    .Range("Q" & Zeile) = zk(i).FeiertagNacht
                    .Range("Q" & Zeile) = zk(i).FeiertagNacht
                    .Range("R" & Zeile) = zk(i).andere_Nacht
                    
                    If zk(i).p_Fahrk <> 0 Then .Range("U" & Zeile) = zk(i).p_Fahrk
                    
                    ZK_eintragen = "Zeitkonto  " & .Range("B1") & "  Monat " & Monat & "-" & .Name & " fortgeschrieben"
                     
                End If
                
            Else 'Zeitkonto gelocked
                    ZK_eintragen = "Zeitkonto  " & .Range("B1") & "  Monat " & Monat & "-" & .Name & " gesperrt!!!"
                    GoTo Ende
            End If
        End With
    Next i
    
    '"Knopf drücken" (Makro ausführen), wenn Zelle F80 leer -> funktioniert so nicht -> Werte direkt übertragen
    With ws
        If .Range("F97") = "" Or .Range("F97") = 0 Or abrechnung = True Then
            .Range("D1") = Date
            .Range("F97").Value = .Range("F96").Value   'Gesamtstunden
            .Range("M94").Value = .Range("M85").Value   'Nacht
            .Range("N94").Value = .Range("N85").Value   'So
            .Range("O94").Value = .Range("O85").Value   'So Nacht
            .Range("P94").Value = .Range("P85").Value   'Feier
            .Range("Q94").Value = .Range("Q85").Value   'Feier Nacht
            .Range("R94").Value = .Range("R85").Value   'Andere Nacht
        End If

        'Währungsfelder Formatierung überschreiben
        .Range("V3:V85").NumberFormat = "#,##0.00 $"
        .Range("E86:E104").NumberFormat = "#,##0.00 $"
        .Range("M86:Q86").NumberFormat = "#,##0.00 $"
        .Range("U4:U85").NumberFormat = "#,##0.00 $"
        .Range("W4:W85").NumberFormat = "#,##0.00 $"
        .Range("W99:W106").NumberFormat = "#,##0.00 $"
        .Range("B109:B115").NumberFormat = "#,##0.00 $"
        
        'Negative Beträge rot
        .Range("E4:X106").FormatConditions.Delete
        .Range("E4:X106").FormatConditions.Add Type:=1, Operator:=6, Formula1:="=0"
        .Range("E4:X106").FormatConditions(1).Font.color = -16776961
        .Range("E4:X106").FormatConditions(1).StopIfTrue = False
        
    End With
    'Werte aus Zeitkonto für Lexware importieren
    ZK_eintragen = ZK_eintragen & " " & ZK_Import_einzel(xlWb, Jahr, Monat, zk(0).MA_ID)
    
Ende:
    Set ws = Nothing
    Exit Function
Err:
    ZK_eintragen = Err.Number & " " & Err.description
    Resume Ende
End Function



'Datei Zeitkonto ermitteln
Function ZK_Datei_ermitteln(MA_ID As Integer) As String

Dim fso As New Scripting.FileSystemObject
Dim fol As folder
Dim Fil As file
Dim PfadZeitkonten As String
Dim Name As String

On Error GoTo Err
    
    PfadZeitkonten = PfadZK
    
    'Wenn Pfad nicht existiert -> letztes Jahr
    If Dir(PfadZeitkonten, vbDirectory) = "" Then PfadZeitkonten = PfadZuBerechnen & Year(Date) - 1 & " Zeitkonten"
    
    'Wenn Pfad nicht existiert -> Fehler
    If Dir(PfadZeitkonten, vbDirectory) = "" Then Err.Raise 76, , PfadZeitkonten & vbCrLf & " nicht gefunden!"
    
    Name = TLookup("Nachname", MASTAMM, "ID = " & MA_ID) & " " & TLookup("Vorname", MASTAMM, "ID = " & MA_ID)
    
    'Wenn MA_ID nicht existiert -> Fehler
    If Name = " " Then Err.Raise 76, , "Mitarbeiter " & MA_ID & vbCrLf & " nicht gefunden!"
    
    Set fol = fso.GetFolder(PfadZeitkonten)
    
    'Zeitkonto suchen
    For Each Fil In fol.files
        If InStr(UCase(Fil.Name), UCase(Name)) <> 0 Then
            ZK_Datei_ermitteln = Fil.path
            Exit For
        End If
    Next Fil

Ende:
    Exit Function
Err:
    ZK_Datei_ermitteln = ""
    Resume Ende
End Function


'Fehler bei Übertragung in Zeitkonto
Function ZK_schreibe_Fehler(zk As ZK_Satz)

Dim rs As Recordset

    Set rs = CurrentDb.OpenRecordset("ztbl_ZK_Fehler")
    rs.AddNew
    rs.fields("MA_ID") = zk.MA_ID
    rs.fields("Datum") = zk.Datum
    rs.fields("Veranstaltung") = zk.Veranstaltung
    rs.fields("Beginn") = zk.Beginn
    rs.fields("Ende") = zk.Ende
    rs.fields("AW") = zk.AW
    rs.fields("AZ") = zk.AZ
    rs.fields("U") = zk.U
    rs.fields("AU") = zk.AU
    rs.fields("WerktagNacht") = zk.WerktagNacht
    rs.fields("Sonntag") = zk.Sonntag
    rs.fields("SonntagNacht") = zk.SonntagNacht
    rs.fields("Feiertag") = zk.Feiertag
    rs.fields("FeiertagNacht") = zk.FeiertagNacht
    rs.fields("andere_Nacht") = zk.andere_Nacht
    rs.fields("andere_So_FT") = zk.andere_So_FT
    rs.fields("Reiseko") = zk.Reiseko
    rs.fields("p_Fahrk") = zk.p_Fahrk
    rs.fields("Abzüge") = zk.Abzüge
    rs.fields("Auszahlung") = zk.Auszahlung
    rs.update
    rs.Close
    Set rs = Nothing

End Function


'Sätze Zeitkonto sortieren
Function zk_sortieren(zk() As ZK_Satz)

Dim rs      As Recordset
Dim tmpTBL  As String
Dim i       As Integer

    tmpTBL = "tmptbl_ZK"
    
    If TableExists(tmpTBL) = False Then _
        DoCmd.TransferDatabase acImport, "Microsoft Access", PfadProd & Backend, , "ztbl_ZK_Fehler", tmpTBL, True
    
    Set rs = CurrentDb.OpenRecordset(tmpTBL)
    For i = LBound(zk) To UBound(zk)
        rs.AddNew
        rs.fields("MA_ID") = zk(i).MA_ID
        rs.fields("Datum") = zk(i).Datum
        rs.fields("Veranstaltung") = zk(i).Veranstaltung
        rs.fields("Beginn") = zk(i).Beginn
        rs.fields("Ende") = zk(i).Ende
        rs.fields("AW") = zk(i).AW
        rs.fields("AZ") = zk(i).AZ
        rs.fields("AZ_andere") = zk(i).AZ_andere
        rs.fields("AZ_Reinigung") = zk(i).AZ_Reinigung
        rs.fields("U") = zk(i).U
        rs.fields("AU") = zk(i).AU
        rs.fields("WerktagNacht") = zk(i).WerktagNacht
        rs.fields("Sonntag") = zk(i).Sonntag
        rs.fields("SonntagNacht") = zk(i).SonntagNacht
        rs.fields("Feiertag") = zk(i).Feiertag
        rs.fields("FeiertagNacht") = zk(i).FeiertagNacht
        rs.fields("andere_Nacht") = zk(i).andere_Nacht
        rs.fields("andere_So_FT") = zk(i).andere_So_FT
        rs.fields("Reiseko") = zk(i).Reiseko
        rs.fields("p_Fahrk") = zk(i).p_Fahrk
        rs.fields("Abzüge") = zk(i).Abzüge
        rs.fields("Auszahlung") = zk(i).Auszahlung
        rs.update
    Next i
    rs.Close
    
    Erase zk
    i = 0
    Set rs = CurrentDb.OpenRecordset("SELECT * FROM " & tmpTBL & " ORDER BY Datum ASC;")
    Do While Not rs.EOF
        ReDim Preserve zk(i)
        zk(i).MA_ID = rs.fields("MA_ID")
        zk(i).Datum = rs.fields("Datum")
        zk(i).Veranstaltung = rs.fields("Veranstaltung")
        zk(i).Beginn = rs.fields("Beginn")
        zk(i).Ende = rs.fields("Ende")
        zk(i).AW = rs.fields("AW")
        zk(i).AZ = rs.fields("AZ")
        zk(i).AZ_andere = rs.fields("AZ_andere")
        zk(i).AZ_Reinigung = rs.fields("AZ_Reinigung")
        zk(i).U = rs.fields("U")
        zk(i).AU = rs.fields("AU")
        zk(i).WerktagNacht = rs.fields("WerktagNacht")
        zk(i).Sonntag = rs.fields("Sonntag")
        zk(i).SonntagNacht = rs.fields("SonntagNacht")
        zk(i).Feiertag = rs.fields("Feiertag")
        zk(i).FeiertagNacht = rs.fields("FeiertagNacht")
        zk(i).andere_Nacht = rs.fields("andere_Nacht")
        zk(i).andere_So_FT = rs.fields("andere_So_FT")
        zk(i).Reiseko = rs.fields("Reiseko")
        zk(i).p_Fahrk = rs.fields("p_Fahrk")
        zk(i).Abzüge = rs.fields("Abzüge")
        zk(i).Auszahlung = rs.fields("Auszahlung")
        rs.MoveNext
        i = i + 1
    Loop
    rs.Close
    Set rs = Nothing
    CurrentDb.Execute "DELETE * FROM " & tmpTBL
    
End Function


'Zeitkonto einlesen (NICHT IN VERWENDUNG)
Function ZK_einlesen(xlWb As Object, von As Date, bis As Date) As ZK_Satz()

Dim Monat   As Integer
Dim Zeile   As Integer
Dim xlWs    As Object
Dim i       As Integer
Dim zk()    As ZK_Satz

    'Monat des Startdatums ermitteln
    Monat = Month(von)
    
    'Tabellenblatt des Monats zuweisen
    Set xlWs = xlWb.Sheets(Monat)
    
    'Sätze zu übergeben (beginnend bei 0)
    i = 0
    ReDim Preserve zk(i)
    
    'Zeilen der Tage im Zeitkonto
    With xlWs
        For Zeile = 4 To 65
            ' U oder AU eingetragen
            If .Range("G" & Zeile) <> 0 Or .Range("H" & Zeile) <> 0 Or .Range("I" & Zeile) <> 0 Then
                ReDim Preserve zk(i)
                zk(i).Datum = CDate(.Range("A" & Zeile) & "." & Monat & "." & Year(von))
                zk(i).Veranstaltung = .Range("B" & Zeile)
                zk(i).Beginn = .Range("C" & Zeile)
                zk(i).Ende = .Range("D" & Zeile)
                zk(i).AW = .Range("E" & Zeile)
                zk(i).AZ = .Range("F" & Zeile)
                'zk(i).AZ_andere = .Range("G" & zeile)
                zk(i).U = .Range("G" & Zeile)
                zk(i).AU = .Range("H" & Zeile)
                zk(i).WerktagNacht = .Range("M" & Zeile)
                zk(i).Sonntag = .Range("N" & Zeile)
                zk(i).SonntagNacht = .Range("O" & Zeile)
                zk(i).Feiertag = .Range("P" & Zeile)
                zk(i).FeiertagNacht = .Range("Q" & Zeile)
                i = i + 1
            End If
        Next Zeile
    End With

    ZK_einlesen = zk
    Set xlWs = Nothing

End Function


'Einzelimport Zeitkonto -> direkt nach dem Schreiben der Werte!
Function ZK_Import_einzel(xlWb As Object, Jahr As Integer, Monat As Integer, ByVal MA_ID As Integer) As String


Dim PersNr          As Variant
Dim LexID           As Variant
Dim Wert            As Double
Dim rs              As Recordset
Dim i               As Integer
Dim Bereich         As Variant
Dim strMonat        As String
Dim Lohnart         As String
Dim Sheet           As String
Dim Satz            As String


On Error GoTo Err

    c = 0
    ReDim lex(c)
    
    PersNr = MA_ID
    LexID = TLookup("LEXWare_ID", MASTAMM, "ID = " & PersNr)
    If IsNull(LexID) Then LexID = 9999
    
    'Lohnarten aus Bereichen auslesen
    strMonat = Monat
    If Len(strMonat) = 1 Then strMonat = "0" & strMonat
            
    'Loop über benannte Bereiche im Workbook
    For Each Bereich In xlWb.Names
        If InStr(Bereich.Name, "_" & strMonat & "_") Then
            'clear Lohnart, Wert, Satz, Sheet
            Satz = Mid(Bereich.Name, InStr(Bereich.Name, "Satz"), InStr(10, Bereich.Name, "_") - InStr(Bereich.Name, "Satz"))
            Satz = get_Satz(Satz)
            'Lohnart aus Bereich
            Lohnart = Right(Bereich.Name, Len(Bereich.Name) - InStrRev(Bereich.Name, "_"))
            'Tabellenblatt im Zeitkonto
            Sheet = Mid(Bereich.RefersTo, 2, InStr(Bereich.RefersTo, "!") - 2)
            'Stundenwert im benannten Bereich
            Wert = xlWb.Sheets(Sheet).Range(Bereich).Value
            'Daten Array puffern
            If Wert <> 0 Then Call hinzufuegen(PersNr, LexID, Jahr, strMonat, Lohnart, Wert, Satz)
        End If
    Next Bereich
    
    'Bereits importierte Werte löschen
    loeschen_import Monat, Jahr, LexID
    
    'Daten in Tabelle schreiben
    Set rs = CurrentDb.OpenRecordset("ztbl_Stunden_Lexware", dbOpenDynaset)
    For i = LBound(lex) To UBound(lex)
        rs.AddNew
        rs.fields(0) = lex(i).Jahr
        rs.fields(1) = lex(i).Monat
        rs.fields(2) = lex(i).Lex_ID
        rs.fields(3) = lex(i).L_ART
        rs.fields(4) = Runden(lex(i).Wert, 2)
        rs.fields(5) = lex(i).Satz
        rs.update
    Next i
    
    ZK_Import_einzel = " und Werte importiert"
    
Ende:
    Exit Function
Err:
    ZK_Import_einzel = "ZK_Import_einzel: " & Err.Number & Err.description
    Resume Ende
End Function


'########################################################
'Bereiche in den Zeitkonten für Lohnarten etc benennen
'########################################################
Function ZK_Bereiche_benennen()

Dim xlApp           As Object, xlWb As Object, xlWs As Object
Dim fso             As New Scripting.FileSystemObject
Dim fol             As folder
Dim Fil             As file
Dim PfadZeitkonten  As String
Dim i               As Integer
Dim Monat           As String
Dim Name            As String
Dim PersNr          As Integer
Dim n               As Variant

On Error GoTo Err
    
    PfadZeitkonten = PfadZK
    
    Set fol = fso.GetFolder(PfadZeitkonten)
    Set xlApp = CreateObject("Excel.Application")
    xlApp.DisplayAlerts = False
    xlApp.Visible = True
    xlApp.ScreenUpdating = False
            
    'Zeitkonto suchen
    For Each Fil In fol.files
        Name = UCase(Left(Fil.Name, Len(Fil.Name) - (Len(Fil.Name) - InStrRev(Fil.Name, ".")) - 1))
        PersNr = get_PersNr(Name)
    Debug.Print Name
        'Wenn keine Persnummer ermittelt werden konnte,
        'Datei öffnen und mit Wert aus Blatt 1 Zelle B1 versuchen
        If PersNr = 0 And InStr(Fil.Name, ".xl") Then
            Set xlWb = xlApp.Workbooks.Open(Fil.path, False, False)
            Name = xlWb.Sheets(1).Range("B1")
            PersNr = get_PersNr(Name)
            xlWb.Close False
        End If
        
        If PersNr <> 0 Or InStr(Fil.Name, " Vorlage ") Then
            Set xlWb = xlApp.Workbooks.Open(Fil.path, False, False)
            'Bestehende Bereichsnamen löschen
            For Each n In xlWb.Names
              n.Delete
            Next
            'Bereiche benennen
            For i = 1 To 12
                Set xlWs = xlWb.Sheets(i)
                Monat = i
                If Len(Monat) = 1 Then Monat = "0" & Monat
                'Spalte C
                xlWs.Range("C86").Name = "_" & Monat & "_SatzNormal_LArt_33"        'Stundenlohn 2a MJ
                xlWs.Range("C94").Name = "_" & Monat & "_SatzNormal_LArt_64"        'LFZ Krankheit MJ
                xlWs.Range("C93").Name = "_" & Monat & "_SatzNormal_LArt_66"        'LFZ Urlaub MJ
                xlWs.Range("C92").Name = "_" & Monat & "_SatzFGUZu_LArt_42"         'FGU Zulage  MJ
                'Spalte D
                xlWs.Range("D86").Name = "_" & Monat & "_SatzNormal_LArt_30"        'Lohn 2ab FA
                'xlWS.Range("D86").Name = "_" & Monat & "_SatzNormal_LArt_51"        'Lohn 2b FA     inaktiv
                xlWs.Range("D87").Name = "_" & Monat & "_SatzNormal_LArt_31"        'Lohn 2c FA
                xlWs.Range("D91").Name = "_" & Monat & "_SatzNormal_LArt_32"        'Freiw. Pers. Zulage
                xlWs.Range("D94").Name = "_" & Monat & "_SatzNormal_LArt_64"        'LFZ Krankheit (FA)
                xlWs.Range("D93").Name = "_" & Monat & "_SatzNormal_LArt_66"        'Urlaub (FA)
                xlWs.Range("C92").Name = "_" & Monat & "_SatzFGUZu2_LArt_42"        'FGU Zulage    (FA)
                'Spalte F
                xlWs.Range("F95").Name = "_" & Monat & "_SatzOhne_LArt_77777"       'Overload
                xlWs.Range("F96").Name = "_" & Monat & "_SatzOhne_LArt_99999"       'Stunden gesamt   Nur Auswertung!
                xlWs.Range("F97").Name = "_" & Monat & "_SatzOhne_LArt_88888"       'Stunden abgerechnet    Nur Auswertung!
                'Spalte M
                xlWs.Range("M85").Name = "_" & Monat & "_SatzNacht_LArt_35"         ' Nachtzuschlag werktags
                'Spalte N
                xlWs.Range("N85").Name = "_" & Monat & "_SatzSonn_LArt_36"          'Sonntagszuschlag Tag
                'xlWS.range("K83").Name = "_" & Monat & "_SatzOhne_LArt_6055"        '€  Vorschuss -> alt! -> T74 alt
                'xlWS.Range("K84").Name = "_" & Monat & "_SatzOhne_LArt_6018"        '€  Abschlag alt
                'xlWS.range("K85").Name = "_" & Monat & "_SatzOhne_LArt_6009"        '€  Dienstkl -> alt!
                'xlWS.range("K86").Name = "_" & Monat & "_SatzOhne_LArt_6006"        '€  IHK RL -> alt!
                'Spalte O
                xlWs.Range("O85").Name = "_" & Monat & "_SatzSonnNacht_LArt_37"     'Sonntagzuschlag Nacht
                'Spalte P
                xlWs.Range("P85").Name = "_" & Monat & "_SatzFeier_LArt_38"         'Feiertagszuschlag Tag
                'Spalte Q
                xlWs.Range("Q85").Name = "_" & Monat & "_SatzFeierNacht_LArt_39"    'Feiertagszuschlag Nacht
                'Spalte R
                xlWs.Range("R85").Name = "_" & Monat & "_SatzNormal_LArt_45"        'Nachtzuschlag andere
                'Spalte S
                xlWs.Range("S85").Name = "_" & Monat & "_SatzNormal_LArt_46"        'Sonntagszuschlag andere
                'Spalte T
                xlWs.Range("T85").Name = "_" & Monat & "_SatzOhne_LArt_48"          'Feiertagszuschlag andere
                'Spalte U
                xlWs.Range("U85").Name = "_" & Monat & "_SatzOhne_LArt_6024"        '€  Reisekosten
                'Spalte V Abzüge
                'xlWS.Range("V66").Name = "_" & Monat & "_SatzOhne_LArt_6004"       '€  Pfändungsgebetrag wird manuell eingetragen
                xlWs.Range("V67").Name = "_" & Monat & "_SatzOhne_LArt_6006"        '€  Pfändungsgebühr wird manuell eingetragen
                xlWs.Range("V68").Name = "_" & Monat & "_SatzOhne_LArt_6007"        '€  Strom
                xlWs.Range("V69").Name = "_" & Monat & "_SatzOhne_LArt_6008"        '€  Miete
                xlWs.Range("V70").Name = "_" & Monat & "_SatzOhne_LArt_6009"        '€  Telefon
                xlWs.Range("V71").Name = "_" & Monat & "_SatzOhne_LArt_6010"        '€  Erstattung Kaution
                xlWs.Range("V72").Name = "_" & Monat & "_SatzOhne_LArt_6011"        '€  Kaution Dienstkl.
                xlWs.Range("V73").Name = "_" & Monat & "_SatzOhne_LArt_6012"        '€  Ordnungsamt
                xlWs.Range("V74").Name = "_" & Monat & "_SatzOhne_LArt_6013"        '€  Rückzahlung IHK
                xlWs.Range("V75").Name = "_" & Monat & "_SatzOhne_LArt_6014"        '€  IHK RL
                xlWs.Range("V76").Name = "_" & Monat & "_SatzOhne_LArt_6015"        '€  AGD
                 'Spalte W
                xlWs.Range("W77").Name = "_" & Monat & "_SatzOhne_LArt_6016"        '€  Vorschuss

               
           Next i
           xlWb.Close True
        Else
            erfasse_Fehler "Keine Personalnummer zu Name " & Name & " gefunden", Fil.Name, , , , "Bereiche in Zeitkonten eintragen"
        End If
    Next Fil
   
Ende:
On Error Resume Next
    xlApp.DisplayAlerts = True
    xlApp.Quit
    Set xlApp = Nothing
    Set xlWb = Nothing
    Set xlWs = Nothing
    Exit Function
Err:
    MsgBox Err.Number & " " & Err.description, vbCritical
    Resume Ende
End Function


'################################
'Funktionen für Abfragen
'################################

'Aktuellen Benutzer ermitteln
Function ermittle_Benutzer() As String
    ermittle_Benutzer = Environ("UserName")
End Function

''Nettowert für Zeitkonto ermitteln -> aus zuo_Stunden !!!!
'Function ermittle_Nettowert(Anz_Std_Netto As Variant, Satz As Variant, Wert As Variant, Lohnart_ID As Integer) As Double
'
'' ggf. nach Lohnart unterscheiden...
'    Select Case True
'        'Wert ist Netto ohne Std & Satz
'        Case IsNumeric(Wert) = True And IsNumeric(Anz_Std_Netto) = False And IsNumeric(Satz) = False
'            ermittle_Nettowert = Wert
'
'        'Nettowert aus Netto-Std & Satz
'        Case IsNumeric(Anz_Std_Netto) = True And IsNumeric(Satz) = True
'            ermittle_Nettowert = Anz_Std_Netto * Satz
'
'        Case Else
'            ermittle_Nettowert = 0
'
'    End Select
'
'End Function

'Lohnart_ID ermitteln
Function ermittle_Lohnart_ID(MA_ID, Optional bez_kurz As String) As Integer

    Select Case bez_kurz
        Case "Normal"
            ermittle_Lohnart_ID = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
            'Sonderlocken
            'If ermittle_Lohnart_ID = 0 Then ermittle_Lohnart_ID = 1
            
        Case "Nacht"
            ermittle_Lohnart_ID = 14
            
        Case "Sonntag"
            ermittle_Lohnart_ID = 15
            
        Case "SonntagNacht"
            ermittle_Lohnart_ID = 20
            
        Case "Feiertag"
            ermittle_Lohnart_ID = 21
            
        Case "FeiertagNacht"
            ermittle_Lohnart_ID = 22
            
        Case Else
            ermittle_Lohnart_ID = 0
            
    End Select
    
    
End Function

'Lohnart ermitteln (für Abwesenheiten)
Function ermittle_Lohnart(Optional MA_ID As Integer, Optional grund As String, Optional Lohnart_ID As Integer) As String

'Dim AnstArt    As Integer


' Lohnart aus Mitarbeiterstamm
    If grund = "" Then
        If Lohnart_ID = 0 Then Lohnart_ID = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
        'If Lohnart_ID = 0 Then Lohnart_ID = 1 'WIEDER RAUSNEHMEN!!!
        If Lohnart_ID <> 0 Then ermittle_Lohnart = Nz(TLookup("Nummer", LOHNARTEN, "ID = " & Lohnart_ID), 0)

    Else
        Select Case grund
            Case "Urlaub"
                ermittle_Lohnart = Nz(TLookup("Nummer", LOHNARTEN, "ID = 27"), 0)
                
            Case "Krank"
                ermittle_Lohnart = Nz(TLookup("Nummer", LOHNARTEN, "ID = 28"), 0)
                
            Case Else
            
        End Select
        
    End If


'' Lohnart nach Anstellungsart?
'On Error Resume Next
'    AnstArt = TLookup("Anstellungsart_ID", MASTAMM, "ID =" & MA_ID)
'On Error GoTo 0
'
'    Select Case AnstArt
'        Case 3 'Festangestellter
'            Select Case grund
'                'Case ""
'                    'ermittle_Lohnart = "NormalFest" 'Tlookup("Nummer","ztbl_ZK_Lohnarten","ID = 1")
'                Case "Urlaub"
'                    ermittle_Lohnart = "UrlaubFest" 'Tlookup("Nummer","ztbl_ZK_Lohnarten","ID = 1")
'                Case "Krank"
'                    ermittle_Lohnart = "krankFest" 'Tlookup("Nummer","ztbl_ZK_Lohnarten","ID = 1")
'            End Select
'
'        Case 5 'Minijobber
'                    Select Case grund
'                'Case ""
'                    'ermittle_Lohnart = "NormalMini" 'Tlookup("Nummer","ztbl_ZK_Lohnarten","ID = 1")
'                Case "Urlaub"
'                    ermittle_Lohnart = "UrlaubMini" 'Tlookup("Nummer","ztbl_ZK_Lohnarten","ID = 1")
'                Case "Krank"
'                    ermittle_Lohnart = "krankMini" 'Tlookup("Nummer","ztbl_ZK_Lohnarten","ID = 1")
'            End Select
'
'
'        Case Else 'Evtl Protokollieren
'            'ermittle_Lohnart = "ERROR"
'
'    End Select
'
End Function


'Anzahl Stunden nach Lohnart ermitteln -> Nur Urlaub, Krank, Zulage!
Function ermittle_Stunden(Lohnart_ID As Integer, Datum As Date, Start As Date, Ende As Date, Optional MA_ID As Integer, Optional bez_kurz As String) As Double

On Error GoTo Err
    
    If bez_kurz = "" Then bez_kurz = Nz(TLookup("Bezeichnung_kurz", LOHNARTEN, "ID = " & Lohnart_ID), "")

    Select Case bez_kurz
        Case "Normal"
            ermittle_Stunden = stunden(Start, Ende)
            
        Case "Nacht"
            ermittle_Stunden = Stunden_Zuschlag(Datum, Start, Ende, "Nacht")
            
        Case "Sonntag"
            ermittle_Stunden = Stunden_Zuschlag(Datum, Start, Ende, "Sonntag")
            
        Case "SonntagNacht"
            ermittle_Stunden = Stunden_Zuschlag(Datum, Start, Ende, "SonntagNacht")
            
        Case "Feiertag"
            ermittle_Stunden = Stunden_Zuschlag(Datum, Start, Ende, "Feiertag")
            
        Case "FeiertagNacht"
            ermittle_Stunden = Stunden_Zuschlag(Datum, Start, Ende, "FeiertagNacht")
            
        Case "Urlaub"
            ermittle_Stunden = Stunden_Urlaub(MA_ID)
            
        Case "Krank"
            ermittle_Stunden = Stunden_Krank(MA_ID)
            
        Case "Zulage"
            'Zulage Euro oder Stunden?
            If TLookup("Euro", LOHNARTEN, "ID = " & Lohnart_ID) = False Then
                ermittle_Stunden = stunden(Start, Ende)
            Else
                ermittle_Stunden = Null  'PAUSCHAL  -> ANPASSEN!!!
            End If
            
        Case Else
            ermittle_Stunden = Null  'PAUSCHAL  -> ANPASSEN!!!
            
    End Select
        
    
Exit Function
Err:
    Debug.Print Err.Number & "" & Err.description
End Function

'Stunden Urlaub ermitteln
Function Stunden_Urlaub(MA_ID As Integer) As Double

    ' Stunden pro Arbeitstag aus Mitarbeiterstamm
    Stunden_Urlaub = Nz(TLookup("Arbst_pro_Arbeitstag", MASTAMM, "ID = " & MA_ID), 0)

    'Berechnung, falls kein Eintrag
    If Stunden_Urlaub = 0 Then
        Stunden_Urlaub = ArbStundenProTag(MA_ID)
    End If
    
    'ggf. Stundenberechnung analog NV-Stunden?
    
End Function

'Stunden Krank ermitteln
Function Stunden_Krank(MA_ID As Integer) As Double

    ' Stunden pro Arbeitstag aus Mitarbeiterstamm
    Stunden_Krank = Nz(TLookup("Arbst_pro_Arbeitstag", MASTAMM, "ID = " & MA_ID), 0)
    
    'Berechnung, falls kein Eintrag
    If Stunden_Krank = 0 Then
        Stunden_Krank = ArbStundenProTag(MA_ID)
    End If
    
    'ggf. Stundenberechnung analog NV-Stunden?

End Function

'Stundensatz nach Lohnart (und Zeitraum) ermitteln
Function ermittle_Stundensatz(Optional Lohnart_ID As Long, Optional MA_ID As Integer, Optional Datum As Date, Optional bez_kurz As String) As Double

Dim Lohnart_ID_MA As Integer
Dim Satz_MA       As Double
Dim Faktor        As Double
Dim SQLWHERE      As String


    'zum Datum gültiger Satz
    If Datum <> "00.00.00" Then
        SQLWHERE = " AND DatumBis >= " & DatumSQL(Datum) & " AND Datumvon <= " & DatumSQL(Datum)
    Else
        SQLWHERE = " AND DatumBis = " & DatumSQL("31.12.9999")
    End If
    
    'Kein Satz hinterlegt -> Krank? Urlaub? -> Lohnart_ID aus MAStamm
    If MA_ID <> 0 Then
        Lohnart_ID_MA = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
        If Lohnart_ID_MA <> 0 Then _
            Satz_MA = Nz(TLookup("Satz", LOHNARTEN, "ID = " & Lohnart_ID_MA & SQLWHERE), 0)
    End If
    
    
    Select Case bez_kurz
        Case "Normal"
            ermittle_Stundensatz = Satz_MA
            
        Case "Nacht"
            Faktor = Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & SQLWHERE), 0)
            ermittle_Stundensatz = Satz_MA * Faktor
            
        Case "Sonntag"
            Faktor = Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & SQLWHERE), 0)
            ermittle_Stundensatz = Satz_MA * Faktor
            
        Case "SonntagNacht"
            Faktor = Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & SQLWHERE), 0)
            ermittle_Stundensatz = Satz_MA * Faktor
            
        Case "Feiertag"
            Faktor = Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & SQLWHERE), 0)
            ermittle_Stundensatz = Satz_MA * Faktor
            
        Case "FeiertagNacht"
            Faktor = Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & SQLWHERE), 0)
            ermittle_Stundensatz = Satz_MA * Faktor
            
        Case "Urlaub"
            ermittle_Stundensatz = Satz_MA
            
        Case "Krank"
            ermittle_Stundensatz = Satz_MA
            
        Case "Zulage"
            'Zulage Euro oder Stunden?
            If TLookup("Euro", LOHNARTEN, "ID = " & Lohnart_ID) = False Then
                Faktor = Nz(TLookup("Faktor", LOHNARTEN, "ID = " & Lohnart_ID & SQLWHERE), 0)   'PRÜFEN!!!
                ermittle_Stundensatz = Satz_MA * Faktor
            Else
                ermittle_Stundensatz = 0  'PAUSCHAL  -> ANPASSEN!!!
            End If
        Case Else
            ermittle_Stundensatz = 0  'PAUSCHAL  -> ANPASSEN!!!
            
    End Select
    
    
    
    'ggf. pauschaler Satz / pauschale Lohnart bei Urlaub oder Krank???
    
    
End Function

'Daten zusammenfügen
Function ermittle_ZK_Daten(Jahr As Integer, Monat As Integer, Optional MA_ID As Long, Optional Anst_ID As Integer)

Dim sql         As String
Dim WHERE       As String
Dim where2      As String
Dim tmpTBL      As String
Dim tbl         As String
Dim ABF         As String
Dim AnstArtMA   As Integer

On Error GoTo Err
    
    DoCmd.Hourglass True
    
    'Anstellungsart des Kollegen
    If MA_ID <> 0 Then AnstArtMA = Nz(TLookup("Anstellungsart_ID", MASTAMM, "ID = " & MA_ID), 0)
        
    'Daten im FE aktualisieren -> relevanter Monat
    SysCmd acSysCmdInitMeter, "Aktualisiere...", 1
    refresh_zuoplanfe , "BETWEEN " & DatumSQL(DateSerial(Jahr, Monat, 1)) & " AND " & DatumSQL(DateSerial(Jahr, Monat + 1, 0))
    
    tmpTBL = "[ztbl_ZK_Stunden_prepare]"
    tbl = "[ztbl_ZK_Stunden]"
    
    'Nicht übertragene und nicht gesperrte sätze löschen
    sql = "DELETE * FROM " & tbl & " WHERE [gesperrt] = FALSE AND [exportiert] = FALSE"
    CurrentDb.Execute sql
    
    'Temp Tabelle löschen
    sql = "DELETE * FROM " & tmpTBL
    CurrentDb.Execute sql
    
    WHERE = " [Jahr] = " & Jahr & " AND [Monat] = " & Monat
    If MA_ID <> 0 Then WHERE = WHERE & " AND [MA_ID] = " & MA_ID
    If Anst_ID <> 0 Then WHERE = WHERE & " AND [Anstellungsart_ID] = " & Anst_ID
    where2 = " AND [exportiert] = FALSE AND [gesperrt] = FALSE"
    
    
    'Datum puffern
    Set_Priv_Property "prp_ZK_Datum", DateSerial(Jahr, Monat + 1, 0)
    
    'noch nicht übertragene Daten + nicht gesperrte Daten entfernen
    sql = "DELETE FROM " & tbl & "WHERE " & WHERE & where2
    
    'Stunden Gesamt
    SysCmd acSysCmdInitMeter, "Ermittle Gesamtstunden...", 1
    ABF = "[zqry_ZUO_ZK_Stunden_FE]"
    sql = "INSERT INTO " & tmpTBL & " SELECT * FROM " & ABF & " WHERE" & WHERE
    CurrentDb.Execute sql
    
    'Urlaub Krank Intern
    SysCmd acSysCmdInitMeter, "Ermittle Urlaub...", 1
    ABF = "[zqry_ZUO_ZK_NV_FE]"
    sql = "INSERT INTO " & tmpTBL & " SELECT * FROM " & ABF & " WHERE" & WHERE
    CurrentDb.Execute sql
    
    'Zulagen / Abzüge laut MAStamm -> Datum über prp_ZK_Datum!
    ABF = "[zqry_ZUO_ZK_pers_ZuAb]"
    sql = "INSERT INTO " & tmpTBL & " SELECT * FROM " & ABF
    CurrentDb.Execute sql
    
''ALLE STUNDEN KOMMEN JETZT ÜBER EINE ABFRAGE!
'    'Stunden Normal
'    SysCmd acSysCmdInitMeter, "Ermittle Gesamtstunden...", 1
'    abf = "[zqry_ZUO_ZK_Stunden_Normal_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Stunden Nacht
'    SysCmd acSysCmdInitMeter, "Ermittle Zuschlag Nacht...", 1
'    abf = "[zqry_ZUO_ZK_Stunden_Nacht_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Stunden Sonntag
'    SysCmd acSysCmdInitMeter, "Ermittle Zuschlag Sonntag...", 1
'    abf = "[zqry_ZUO_ZK_Stunden_Sonntag_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Stunden SonntagNacht
'    SysCmd acSysCmdInitMeter, "Ermittle Zuschlag Sonntag Nacht...", 1
'    abf = "[zqry_ZUO_ZK_Stunden_SonntagNacht_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Stunden Feiertag
'    SysCmd acSysCmdInitMeter, "Ermittle Zuschlag Feiertag...", 1
'    abf = "[zqry_ZUO_ZK_Stunden_Feiertag_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Stunden FeiertagNacht
'    SysCmd acSysCmdInitMeter, "Ermittle Zuschlag Feiertag Nacht...", 1
'    abf = "[zqry_ZUO_ZK_Stunden_FeiertagNacht_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Urlaub
'    SysCmd acSysCmdInitMeter, "Ermittle Urlaub...", 1
'    abf = "[zqry_ZUO_ZK_NV_Urlaub_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Krank
'    SysCmd acSysCmdInitMeter, "Ermittle Krankeit...", 1
'    abf = "[zqry_ZUO_ZK_NV_Krank_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
'
'    'Intern
'    SysCmd acSysCmdInitMeter, "Ermittle Intern...", 1
'    abf = "[zqry_ZUO_ZK_Intern_FE]"
'    SQL = "INSERT INTO " & tmpTBL & " SELECT * FROM " & abf & " WHERE" & Where
'    CurrentDb.Execute SQL
    
'    'Nullwerte entfernen (nur Zuordnungsdaten!)
'    SysCmd acSysCmdInitMeter, "Entferne Nullwerte...", 1
'    SQL = "DELETE * FROM " & tmpTBL & " WHERE [Anz_Std] = 0 AND [Wert] = 0"
'    CurrentDb.Execute SQL

    'Reisekosten -> € !! -> Wert im Stunden-Feld wird für Anzeige benötigt!!!
    SysCmd acSysCmdInitMeter, "Ermittle Reisekosten...", 1
    ABF = "[zqry_ZUO_ZK_Reisekosten]"
    sql = "INSERT INTO " & tmpTBL & " SELECT * FROM " & ABF & " WHERE" & WHERE
    CurrentDb.Execute sql
    
    'Korrekturen
    SysCmd acSysCmdInitMeter, "Ermittle Korrekturen...", 1
    ABF = "[zqry_ZUO_ZK_Korrekturen_FE]"
    sql = "INSERT INTO " & tmpTBL & " SELECT * FROM " & ABF & " WHERE" & WHERE
    CurrentDb.Execute sql

    'Delta übertragen
    SysCmd acSysCmdInitMeter, "Übertrage Delta...", 1
    sql = "INSERT INTO " & tbl & " SELECT * FROM [zqry_ZK_Stunden_Delta]"
    CurrentDb.Execute sql
    
    'MJ Stunden schieben
    If MA_ID <> 0 And AnstArtMA = 5 Then
        Call maxEuro_MJ(Monat, Jahr, MA_ID)
    Else
        'Funktion schreiben nach Anstellungsart?
    End If
    
    'IHK-Rücklage als Korrektur
    If MA_ID <> 0 Then
        Call calc_RL34a(Monat, Jahr, MA_ID)
    Else
        'Funktion schreiben nach Anstellungsart?
    End If
    
Ende:
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False
    Exit Function
Err:
    MsgBox "Fehler bei der Aktualisierung!" & vbCrLf & Err.Number & " " & Err.description, vbCritical
    Resume Ende
    
End Function


'Minijobber: Stunden über 520€ als Korrektur in Folgemonat schieben
Function maxEuro_MJ(Monat As Integer, Jahr As Integer, MA_ID As Long)

Dim rs      As Recordset
Dim WHERE   As String   'Werte nach MA, Jahr und Monat
Dim where2  As String   'mit Stundenkorrektur nicht exportiert
Dim sql     As String
Dim Wert    As Double
Dim maxWert As Double
Dim zJahr   As Integer
Dim zMonat  As Integer
Dim LIDMA   As Integer  'Lohnart des Mitarbeiters
Dim Satz    As Currency
Dim AnzStd  As Double
    
    maxWert = 520

    'Dezember?
    If Monat < 12 Then
        zJahr = Jahr
        zMonat = Monat + 1
    Else
        zJahr = Jahr + 1
        zMonat = 1
    End If
    
    WHERE = "[MA_ID] = " & MA_ID & " AND [Jahr] = " & Jahr & " AND [Monat] = " & Monat
    where2 = " AND [Lohnart_ID] = 55 AND [exportiert] = FALSE"
    sql = "SELECT * FROM [" & KORR & "] WHERE " & WHERE & where2
    
    'Gesamtwert Netto lesen (ohne Zuschläge und Std in Folgemonat)
    'Wert = Nz(TSum("Wert_Netto", "zqry_ZK_Stunden_Zusatz", WHERE & " AND [Lohnart_ID] <> 55"), 0)
    Wert = Round(Nz(TSum("Wert", "zqry_ZK_Stunden_Zusatz", WHERE & " AND [Lohnart_ID] <> 55 AND ([Bezeichnung_kurz] = 'Normal' OR [Bezeichnung_kurz] Is Null)"), 0), 2)
    
    If Wert > maxWert Then
        LIDMA = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & MA_ID), 0)
        Satz = Nz(TLookup("Satz", LOHNARTEN, "ID = " & LIDMA), 0)
        
        If Satz = 0 Then Exit Function
        
        'Stunden berechnen mit 0,01 Sicherheitsabstand
        AnzStd = Round((maxWert - Wert) / Satz, 2) - 0.01
        
        Set rs = CurrentDb.OpenRecordset(sql)
        'noch nicht exportierte Stundenkorrektur vorhanden?
        If Not rs.EOF Then
            rs.Edit
            rs.fields("Aenderer") = Environ("UserName")
            rs.fields("geaendert") = Now
            rs.fields("Anz_Std") = AnzStd
            rs.fields("Satz") = Satz
            rs.fields("Wert") = Round(AnzStd * Satz, 2)
            rs.fields("Korr_ID_ref") = ref_korr_anlegen(MA_ID, zJahr, zMonat, rs.fields("ID"), , Abs(AnzStd), Satz, 54, rs.fields("Bemerkung"))
            If IsNull(rs.fields("Bemerkung")) Then rs.fields("Bemerkung") = TLookup("Bezeichnung", LOHNARTEN, "ID = 55")
        Else
            'neue Korrektur anlegen
            rs.AddNew
            rs.fields("MA_ID") = MA_ID
            rs.fields("Jahr") = Jahr
            rs.fields("Monat") = Monat
            rs.fields("Lohnart_ID") = 55
            rs.fields("Ersteller") = Environ("UserName")
            rs.fields("erstellt") = Now
            rs.fields("Bemerkung") = TLookup("Bezeichnung", LOHNARTEN, "ID = 55")
            rs.fields("exportieren") = True
            rs.fields("Anz_Std") = AnzStd
            rs.fields("Satz") = Satz
            rs.fields("Wert") = Round(AnzStd * Satz, 2)
            rs.fields("Korr_ID_ref") = ref_korr_anlegen(MA_ID, zJahr, zMonat, rs.fields("ID"), , Abs(AnzStd), Satz, 54, rs.fields("Bemerkung"))
            
        End If
           
        rs.update
        rs.Close
        Set rs = Nothing
            
        'im FE aktualisieren
        CurrentDb.Execute " DELETE FROM [" & KORR & "_FE] WHERE " & WHERE & where2
        CurrentDb.Execute "INSERT INTO [" & KORR & "_FE] SELECT * FROM [zqry_MA_ZK_Korrekturen] WHERE " & WHERE & where2
        
        'Korrektur aufbereiten
        CurrentDb.Execute "DELETE FROM [ztbl_ZK_Stunden_prepare] " & " WHERE" & WHERE & where2
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Stunden_prepare] SELECT * FROM " & "[zqry_ZUO_ZK_Korrekturen_FE]" & " WHERE" & WHERE & where2
        
        'Korrektur übertragen
        CurrentDb.Execute "DELETE FROM [ztbl_ZK_Stunden] " & " WHERE" & WHERE & where2
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Stunden] SELECT * FROM " & "[zqry_ZK_Stunden_Delta]" & " WHERE" & WHERE & where2

    End If


End Function


'Korrektur für Folgemonat oder MA + Monat anlegen
Function ref_korr_anlegen(ByVal MA_ID As Long, ByVal Jahr As Integer, ByVal Monat As Integer, Korr_ID_ref As Integer, _
    Optional ByVal Wert As Double, Optional ByVal Anz_Std As Double, Optional ByVal Satz As Double, _
        Optional Lohnart_ID As Integer, Optional ByVal Bez As Variant, Optional ByVal refMA_ID As Long) As Integer
        
Dim sql     As String
Dim rs      As Recordset


    sql = "SELECT * FROM [" & KORR & "] WHERE [Korr_ID_ref] = " & Korr_ID_ref '& " AND [MA_ID] = " & MA_ID & _
        " AND [Monat] = " & Monat & " AND [Jahr] = " & Jahr
        
    Set rs = CurrentDb.OpenRecordset(sql)
    
    If Not rs.EOF Then
        rs.Edit
    Else
        rs.AddNew
    End If
    
    'MA_ID gleich?
    If MA_ID <> refMA_ID And refMA_ID <> 0 Then
        rs.fields("MA_ID") = refMA_ID
        If Lohnart_ID <> 0 Then rs.fields("Lohnart_ID") = Lohnart_ID
        'Bemerkung
        Bez = TLookup("Nachname", MASTAMM, "ID = " & MA_ID) & " " & TLookup("Vorname", MASTAMM, "ID = " & MA_ID)
        rs.fields("Bemerkung") = "von " & Monat & "/" & Jahr & " " & Bez
    Else
        rs.fields("MA_ID") = MA_ID
        'Bemerkung
        If Lohnart_ID <> 0 Then
            rs.fields("Lohnart_ID") = Lohnart_ID
            rs.fields("Bemerkung") = TLookup("Bezeichnung", LOHNARTEN, "ID = " & Lohnart_ID)
        Else 'keine Folgelohnart??
            rs.fields("Bemerkung") = Bez & " aus " & Monat & "." & Jahr
        End If
    End If
    
    rs.fields("Jahr") = Jahr
    rs.fields("Monat") = Monat
    
    'Stunden?
    If Anz_Std <> 0 Then
        rs.fields("Anz_Std") = Anz_Std
        rs.fields("Satz") = Satz
        If Wert = 0 Then Wert = Anz_Std * Satz
    End If
    'Euro?
    If Wert <> 0 Then
        rs.fields("Wert") = Wert
    End If
    rs.fields("Korr_ID_ref") = Korr_ID_ref
    rs.fields("exportieren") = True
    rs.fields("erstellt") = Now
    rs.fields("Ersteller") = Environ("UserName")
    
    'ID des neuen Satzes zurückgeben
    ref_korr_anlegen = rs.fields("ID")
    
    rs.update
    rs.Close
    Set rs = Nothing

End Function


'IHK Rücklage berechnen (10% vom Gesamtbetrag €)
Function calc_RL34a(Monat As Integer, Jahr As Integer, MA_ID As Long)

Dim rs      As Recordset
Dim WHERE   As String   'Werte nach MA, Jahr und Monat
Dim where2  As String   'Wert IHK RL nicht exportiert
Dim WHERE3  As String   'Gesamtwert nicht exportiert ohne IHK RL
Dim sql     As String
Dim Wert    As Double
    
    
    WHERE = "[MA_ID] = " & MA_ID & " AND [Jahr] = " & Jahr & " AND [Monat] = " & Monat
    where2 = " AND [Lohnart_ID] = 40 AND [exportiert] = FALSE"
    WHERE3 = " AND [Lohnart_ID] <> 40 AND [exportiert] = FALSE"
    sql = "SELECT * FROM [" & KORR & "] WHERE " & WHERE & where2
    
    'Rücklage bilden?
    If TLookup("Hat_keine_34a", MASTAMM, "ID = " & MA_ID) = False Then
        
       'Gesamtwert ohne IHK-Rücklage
        Wert = Nz(TSum("Wert", "zqry_ZK_Stunden", WHERE & WHERE3), 0)
        
        If Wert > 0 Then
            Set rs = CurrentDb.OpenRecordset(sql)
            
            If Not rs.EOF Then
                rs.Edit
                rs.fields("Aenderer") = Environ("UserName")
                rs.fields("geaendert") = Now
                
            Else
                rs.AddNew
                rs.fields("MA_ID") = MA_ID
                rs.fields("Jahr") = Jahr
                rs.fields("Monat") = Monat
                rs.fields("Lohnart_ID") = 40
                rs.fields("Ersteller") = Environ("UserName")
                rs.fields("erstellt") = Now
                rs.fields("Bemerkung") = "IHK Rücklage"
                rs.fields("exportieren") = True
                   
            End If

            'IHK Rücklage 10%
            rs.fields("Wert") = -Round(Wert / 10, 2)
            rs.update
            rs.Close
            Set rs = Nothing
            
            'im FE aktualisieren
            CurrentDb.Execute " DELETE FROM [" & KORR & "_FE] WHERE " & WHERE & where2
            CurrentDb.Execute "INSERT INTO [" & KORR & "_FE] SELECT * FROM [zqry_MA_ZK_Korrekturen] WHERE " & WHERE & where2
            
            'Korrektur aufbereiten
            CurrentDb.Execute "DELETE FROM [ztbl_ZK_Stunden_prepare] " & " WHERE" & WHERE & where2
            CurrentDb.Execute "INSERT INTO [ztbl_ZK_Stunden_prepare] SELECT * FROM " & "[zqry_ZUO_ZK_Korrekturen_FE]" & " WHERE" & WHERE & where2
            
            'Korrektur übertragen
            CurrentDb.Execute "DELETE FROM [ztbl_ZK_Stunden] " & " WHERE" & WHERE & where2
            CurrentDb.Execute "INSERT INTO [ztbl_ZK_Stunden] SELECT * FROM " & "[zqry_ZK_Stunden_Delta]" & " WHERE" & WHERE & where2
        End If
    End If
    
End Function


'Korrektur anlegen (automatisch, wennn noch nicht exportiert)
Function korrektur_anlegen_wert(ByVal MA_ID As Long, ByVal Lohnart_ID As Long, ByVal Jahr As Integer, ByVal Monat As Integer, ByVal Wert As Double, Optional ByVal Bemerkung As String) As String

Dim rs      As Recordset
Dim WHERE   As String   'Werte nach MA, Jahr, Monat & Lohnart
Dim sql     As String
    
    
    WHERE = "[MA_ID] = " & MA_ID & " AND [Jahr] = " & Jahr & " AND [Monat] = " & Monat & _
        " AND [Lohnart_ID] = " & Lohnart_ID '& " AND [exportiert] = FALSE"

    sql = "SELECT * FROM [" & KORR & "] WHERE " & WHERE
    
    If Wert > 0 Then
        Select Case TLookup("Vorzeichen", LOHNARTEN, "ID = " & Lohnart_ID)
            Case "+"
                Wert = Abs(Wert)
                
            Case "-"
                Wert = -Abs(Wert)
                
            Case Else
                korrektur_anlegen_wert = "Fehler Vorzeichen!"
                Exit Function
            
        End Select
        
        Set rs = CurrentDb.OpenRecordset(sql)
        
        If Not rs.EOF Then
            If rs.fields("exportiert") = True Then 'Differenz exportieren oder Fehlermeldung?
'                rs.Edit
'                rs.Fields("Aenderer") = Environ("UserName")
'                rs.Fields("geaendert") = Now
                MsgBox "Wert wurde bereits exportiert!", vbCritical
                Exit Function
            Else
                'Wert korrigieren
                rs.Edit
                rs.fields("Aenderer") = Environ("UserName")
                rs.fields("geaendert") = Now
            End If
            
        Else
            rs.AddNew
            rs.fields("MA_ID") = MA_ID
            rs.fields("Jahr") = Jahr
            rs.fields("Monat") = Monat
            rs.fields("Lohnart_ID") = Lohnart_ID
            rs.fields("Ersteller") = Environ("UserName")
            rs.fields("erstellt") = Now
            If Bemerkung = "" Then
                rs.fields("Bemerkung") = TLookup("Bezeichnung", LOHNARTEN, "ID = " & Lohnart_ID)
            Else
                rs.fields("Bemerkung") = Bemerkung
            End If
            rs.fields("exportieren") = True
               
        End If

        'IHK Rücklage 10%
        rs.fields("Wert") = Round(Wert, 2)
        rs.update
        rs.Close
        Set rs = Nothing
        
        'im FE aktualisieren
        CurrentDb.Execute " DELETE FROM [" & KORR & "_FE] WHERE " & WHERE
        CurrentDb.Execute "INSERT INTO [" & KORR & "_FE] SELECT * FROM [zqry_MA_ZK_Korrekturen] WHERE " & WHERE
        
        'Korrektur aufbereiten
        CurrentDb.Execute "DELETE FROM [ztbl_ZK_Stunden_prepare] " & " WHERE" & WHERE
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Stunden_prepare] SELECT * FROM " & "[zqry_ZUO_ZK_Korrekturen_FE]" & " WHERE" & WHERE
        
        'Korrektur übertragen
        CurrentDb.Execute "DELETE FROM [ztbl_ZK_Stunden] " & " WHERE" & WHERE
        CurrentDb.Execute "INSERT INTO [ztbl_ZK_Stunden] SELECT * FROM " & "[zqry_ZK_Stunden_Delta]" & " WHERE" & WHERE
    End If

End Function


'Urlaubsanspruch berechnen
Function Urlaubsanspruch(MA_ID As Long) As Double

Dim TageGesamt    As Double
Dim TageProWoche  As Double
Dim Stundenprotag As Double

    TageGesamt = AnzTageGesamt(MA_ID)
    TageProWoche = AnzTageProWoche(MA_ID)
    Stundenprotag = ArbStundenProTag(MA_ID)
    
    If TageGesamt / 7 > TageProWoche Then
        ' Fall 1
        Urlaubsanspruch = TageGesamt * TageProWoche * Stundenprotag
    ElseIf TageGesamt <> 0 Then
        ' Fall 2
        Urlaubsanspruch = TageGesamt / 7 * Stundenprotag
    Else
        ' Fall 3
        Urlaubsanspruch = Nz(TLookup("Urlaubsanspr_pro_Jahr", MASTAMM, "ID = " & MA_ID), 0)
    End If
    
End Function


'Anzahl Tage gesamt berechnen
Function AnzTageGesamt(MA_ID As Long) As Double

Dim DatVon    As Date
Dim DatBis    As Date

    'letzter Tag der letzten Woche
    DatBis = Date + (7 - Weekday(Date, vbMonday)) - 7
    'erster Tag der Woche vor 13 Wochen
    DatVon = DatBis - 90
    
    AnzTageGesamt = Nz(TCount("VADatum", ZUORDNUNG, "MA_ID =" & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)), 0)
    
End Function


'Arbeitstage pro Woche berechnen
Function AnzTageProWoche(ByVal MA_ID As String) As Double

Dim DatVon    As Date
Dim DatBis    As Date
Dim AnzWochen As Double
Dim AnzATage  As Integer

    'Schritt 1: Feld aus Mitarbeiterstamm
    AnzTageProWoche = Nz(TLookup("Arbeitstage_pro_Woche", MASTAMM, "ID = " & MA_ID), 0)
    If AnzTageProWoche <> 0 Then Exit Function
    
    'Schritt 2: Ermittlung aus Vergangenheit, wenn feld leer ist
    
    'Monatserster = DateAdd("d", -Day(Date) + 1, Date)5
    'Monatsletzter = DateSerial(Year(Date), Month(Date), 1 - 1)
    'FirstDayOfWeek = dtDate - (Weekday(dtDate, vbMonday) - 1)
    'LastDayOfWeek = dtDate + (7 - Weekday(dtDate, vbMonday))
    
    'letzter Tag der letzten Woche
    DatBis = Date + (7 - Weekday(Date, vbMonday)) - 7
    'erster Tag der Woche vor 13 Wochen
    DatVon = DatBis - 90

    AnzWochen = DateDiff("ww", DatVon, DatBis)
    AnzATage = Nz(TCount("VADatum", ZUORDNUNG, "MA_ID =" & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)), 0)
    AnzTageProWoche = Nz(Round(AnzATage / AnzWochen, 2), 0)
    
    
    'Schritt 3: Ermittlung aus Vorjahr, wenn Wert zu gering
    If AnzTageProWoche < 1.5 Then
        'letzter Tag des letzten Jahres
        DatBis = "31.12." & Year(Date) - 1
        'erster Tag des letzten Jahres
        DatVon = "01.01." & Year(Date) - 1
    
        AnzWochen = DateDiff("ww", DatVon, DatBis)
        AnzATage = Nz(TCount("VADatum", ZUORDNUNG, "MA_ID =" & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)), 0)
        AnzTageProWoche = Nz(Round(AnzATage / AnzWochen, 2), 0)
    End If
    
End Function


'Arbeitsstunden pro Arbeitstag berechnen
Function ArbStundenProTag(ByVal MA_ID As String) As Double

Dim DatVon      As Date
Dim DatBis      As Date
Dim AnzStunden  As Double
Dim AnzATage    As Integer
Dim rs          As Recordset
Dim sql         As String
    
    'Schritt 1: Feld aus Mitarbeiterstamm
    ArbStundenProTag = Nz(TLookup("Arbst_pro_Arbeitstag", MASTAMM, "ID = " & MA_ID), 0)
    If ArbStundenProTag <> 0 Then Exit Function
    
    'Schritt 2: Ermittlung aus Vergangenheit, wenn feld leer ist
    
    'letzter Tag der letzten Woche
    DatBis = Date + (7 - Weekday(Date, vbMonday)) - 7
    'erster Tag der Woche vor 13 Wochen
    DatVon = DatBis - 90
    
    AnzATage = Nz(TCount("VADatum", ZUORDNUNG, "MA_ID =" & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)), 0)
    sql = "SELECT * FROM [" & ZUORDNUNG & "] WHERE MA_ID = " & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    Do While Not rs.EOF
        'AnzStunden = AnzStunden + Stunden(rs.Fields("MA_Start"), rs.Fields("MA_Ende"))
        AnzStunden = AnzStunden + rs.fields("MA_Netto_Std2")
        rs.MoveNext
    Loop 'Until rs.EOF
    rs.Close
    Set rs = Nothing
    'Stunden Netto!
    If AnzATage <> 0 Then ArbStundenProTag = Nz(Round(AnzStunden / AnzATage, 2), 0) '* 0.91
     
    'Schritt 3: Ermittlung aus Vorjahr, wenn Wert zu gering
    If ArbStundenProTag < 2 Then
        'letzter Tag des letzten Jahres
        DatBis = "31.12." & Year(Date) - 1
        'erster Tag des letzten Jahres
        DatVon = "01.01." & Year(Date) - 1
        
        AnzATage = Nz(TCount("VADatum", ZUORDNUNG, "MA_ID =" & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)), 0)
        sql = "SELECT * FROM [" & ZUORDNUNG & "] WHERE MA_ID = " & MA_ID & " AND VADatum >= " & DatumSQL(DatVon) & " AND VADatum <= " & DatumSQL(DatBis)
        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        Do While Not rs.EOF
            'AnzStunden = AnzStunden + Stunden(rs.Fields("MA_Start"), rs.Fields("MA_Ende"))
            AnzStunden = AnzStunden + rs.fields("MA_Netto_Std2")
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
        'Stunden Netto!
        If Not IsInitial(AnzStunden) And Not IsInitial(AnzATage) Then
            ArbStundenProTag = Nz(Round(AnzStunden / AnzATage, 2), 0) '* 0.91
        End If
    End If
End Function


'Gesamten Monat für das Zeitkonto erzeugen
Function create_Tage_Zeitraum(ByVal MA_ID As Long, ByVal Jahr As Integer, ByVal Monat As Integer, Optional ByVal append As Boolean)

Dim anzTage     As Integer
Dim ErsterTag   As Date
Dim tbl         As String
Dim i           As Integer
Dim rs          As Recordset

    tbl = "ztbl_ZK_Tage_Zeitraum"
    ErsterTag = CDate("01." & Monat & "." & Jahr)
    anzTage = DateDiff("d", ErsterTag, DateSerial(Year(ErsterTag), Month(ErsterTag) + 1, 1))
    
    If append = False Then CurrentDb.Execute "DELETE * FROM " & tbl
    Set rs = CurrentDb.OpenRecordset(tbl)

    For i = 0 To anzTage - 1
        rs.AddNew
        rs.fields("ZK_MA_ID") = MA_ID
        rs.fields("ZKDatum") = ErsterTag + i
        rs.update
    Next i

End Function


'Wochentag kurz für Zeitkonto
Function weekday_short(ByVal Datum As Date) As String

Dim tag_zahl As Integer

    tag_zahl = Weekday(Datum)
    Select Case tag_zahl
        Case 1
            weekday_short = "So"
        Case 2
            weekday_short = "Mo"
        Case 3
            weekday_short = "Di"
        Case 4
            weekday_short = "Mi"
        Case 5
            weekday_short = "Do"
        Case 6
            weekday_short = "Fr"
        Case 7
            weekday_short = "Sa"
    End Select
    
End Function


'Lohnart prüfen und ggf. anpassen
Function pruefeLohnart(MA_ID As Long, Lohnart_ID As Long, Lohnartnummer As String) As String

Dim Lohnart_ID_MA As Long
Dim Lohnartnr_MA  As String

    Select Case Lohnart_ID
        'Korrekturen
        Case 54, 55, 56
            Lohnart_ID_MA = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID =" & MA_ID), 0)
            If Not IsInitial(Lohnart_ID_MA) Then
                Lohnartnr_MA = TLookup("Nummer", LOHNARTEN, "ID = " & Lohnart_ID_MA)
            Else
                Lohnartnr_MA = 0
            End If
            pruefeLohnart = Lohnartnr_MA
            
        '"Normalfall"
        Case Else
            pruefeLohnart = Lohnartnummer
            
    End Select

End Function
