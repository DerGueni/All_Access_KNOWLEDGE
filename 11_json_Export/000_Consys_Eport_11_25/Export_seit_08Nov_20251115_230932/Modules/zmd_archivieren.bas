Option Compare Database
Option Explicit

Type Relation
    master As String
    slave As String
    mfield As String
    sfield As String
    archivieren As String
End Type

Public Function archivieren() As String

Dim Archiv As String
Dim sql As String
Dim DatumBis As String
Dim varreturn As Variant
Dim Table() As String
Dim i As Integer
Dim BackendDB As String

    BackendDB = TLookup("Database", "MSysObjects", "Database IS NOT NULL")
    DatumBis = datumSQL("01.01." & year(Now) - 1) 'Letztes Jahr stehen lassen (-> Auftrag kopieren!)

    If InStr(BackendDB, "Test") = 0 Then
        Archiv = PfadProdLokal & Archiv_BE
    Else
        Archiv = PfadTestLokal & Archiv_BE
    End If
    
    'Anzahl Tabellen
    ReDim Table(11)
    
    'zu archivierenden Tabellen (ACHTUNG Reihenfolge nicht ändern!)
    Table(0) = AUFTRAGSTAMM
    Table(1) = anzTage
    Table(2) = VASTART
    Table(3) = PLANUNG
    Table(4) = ZUORDNUNG
    Table(5) = VAKOSTALT
    Table(6) = VAAKTOKOPF
    Table(7) = VAAKTOPOS
    Table(8) = VAAKTOPOSM
    Table(9) = NVERFUEG
    Table(10) = MASTAMM
    Table(11) = ZUO_STD
    'ZEITKONTEN???!!!!

    
    'Archivieren
    varreturn = SysCmd(acSysCmdInitMeter, "Archiviere...", UBound(Table))
    For i = LBound(Table) To UBound(Table)
        varreturn = SysCmd(acSysCmdUpdateMeter, i)
        sql = "INSERT INTO " & Table(i) & " IN '" & Archiv & "' SELECT * FROM " & Table(i) & " WHERE [ID] NOT IN (SELECT [ID] FROM " & Table(i) & " IN '" & Archiv & "')"
        If TableExists(Table(i)) Then CurrentDb.Execute sql
    Next i
    
    
    'Archivierte Daten aus BE enfernen
    varreturn = SysCmd(acSysCmdInitMeter, "Lösche archivierte Daten...", 1)
    
    'Veranstaltungen (-> Löschweitergabe!)
    sql = "DELETE * FROM " & AUFTRAGSTAMM & " WHERE [Dat_VA_Von] < " & DatumBis
    CurrentDb.Execute sql
    'Zeiten nicht verfügbar
    sql = "DELETE * FROM " & NVERFUEG & " WHERE [vonTag] < " & DatumBis
    CurrentDb.Execute sql
    
        
    'Ladebalken ausblenden
    varreturn = SysCmd(acSysCmdClearStatus)
    
    MsgBox "Archivierung abgeschlossen"
    
End Function


Public Function archivieren_alt() As String

Dim Archiv As String
Dim rs As Recordset
Dim rs2 As Recordset
Dim sql As String
Dim DatumBis As String
Dim varreturn As Variant
Dim Table() As String
Dim Tabl As String
Dim i As Integer

    DatumBis = datumSQL("01.01." & year(Now))

    'Archiv = PfadProd & Archiv_BE
    Archiv = PfadTest & Archiv_BE
    
    
    'Anzahl Tabellen
    ReDim Table(10)
    
    'zu archivierenden Tabellen (ACHTUNG Reihenfolge nicht ändern!)
    Table(0) = AUFTRAGSTAMM
    Table(1) = anzTage
    Table(2) = VASTART
    Table(3) = PLANUNG
    Table(4) = ZUORDNUNG
    Table(5) = VAKOSTALT
    Table(6) = VAAKTOKOPF
    Table(7) = VAAKTOPOS
    Table(8) = VAAKTOPOSM
    Table(9) = NVERFUEG
    Table(10) = MASTAMM
    
    'Ladebalken initialisieren
    varreturn = SysCmd(acSysCmdInitMeter, "Initialisiere...", 1)
    
'=== Temporäre Tabellen löschen
    For i = LBound(Table) To UBound(Table)
        If TableExists(Table(i) & "_Arc") = True Then DoCmd.DeleteObject acTable, Table(i) & "_Arc"
    Next i
        
   
'=== Temporäre Tabellen erstellen
    For i = LBound(Table) To UBound(Table)
      DoCmd.TransferDatabase acImport, "Microsoft Access", PfadProd & Archiv_BE, acTable, Table(i), Table(i) & "_Arc", True
    Next i


    sql = "SELECT * FROM " & Table(0) & " WHERE [Dat_VA_Von] < " & DatumBis
    Set rs = CurrentDb.OpenRecordset(sql)
    
    'Ladebalken
    rs.MoveLast
    rs.MoveFirst
    varreturn = SysCmd(acSysCmdInitMeter, "Bereite Daten für Archivierung vor...", rs.RecordCount)
    
    Do
        'Ladebalken aktualisieren
        varreturn = SysCmd(acSysCmdUpdateMeter, rs.AbsolutePosition)
        
        'Auftragstamm
        sql = "INSERT INTO " & Table(0) & "_Arc SELECT * FROM " & Table(0) & " WHERE [ID] = " & rs.fields("ID")
        CurrentDb.Execute sql
        'VA_Anz_Tage
        sql = "INSERT INTO " & Table(1) & "_Arc SELECT * FROM " & Table(1) & " WHERE [VA_ID] = " & rs.fields("ID")
        CurrentDb.Execute sql
        'VA_START
        sql = "INSERT INTO " & Table(2) & "_Arc SELECT * FROM " & Table(2) & " WHERE [VA_ID] = " & rs.fields("ID")
        CurrentDb.Execute sql
        'Planung
        sql = "INSERT INTO " & Table(3) & "_Arc SELECT * FROM " & Table(3) & " WHERE [VA_ID] = " & rs.fields("ID")
        CurrentDb.Execute sql
        'Zuordnung
        sql = "INSERT INTO " & Table(4) & "_Arc SELECT * FROM " & Table(4) & " WHERE [VA_ID] = " & rs.fields("ID")
        CurrentDb.Execute sql
        'Kosten alt
        'SQL = "INSERT INTO " & Table(5) & "_Arc SELECT * FROM " & Table(5) & " WHERE [VA_ID] = " & rs.Fields("ID")
        'CurrentDb.Execute SQL
        'Aktuelles Objekt Kopf
        sql = "INSERT INTO " & Table(6) & "_Arc SELECT * FROM " & Table(6) & " WHERE [VA_ID] = " & rs.fields("ID")
        CurrentDb.Execute sql
            'Positionsdaten aktuelles Objekt
            sql = "SELECT * FROM " & Table(6) & " WHERE [VA_ID] = " & rs.fields("ID")
            Set rs2 = CurrentDb.OpenRecordset(sql)
            Do While Not rs2.EOF
                'Aktuelles Objekt Posititon
                sql = "INSERT INTO " & Table(7) & "_Arc SELECT * FROM " & Table(7) & " WHERE [VA_Akt_Objekt_Kopf_ID] = " & rs.fields("ID")
                CurrentDb.Execute sql
                'Aktuelles Objekt Posititon MA
                sql = "INSERT INTO " & Table(8) & "_Arc SELECT * FROM " & Table(8) & " WHERE [VA_Akt_Objekt_Kopf_ID] = " & rs.fields("ID")
                CurrentDb.Execute sql
                
            rs2.MoveNext
            Loop
            
    rs.MoveNext
    Loop Until rs.EOF
    
    'Zeiten nicht verfügbar
    Tabl = Table(9)
    sql = "INSERT INTO " & Tabl & " IN '" & Archiv & "' SELECT * FROM " & Tabl & " WHERE [ID] NOT IN (SELECT [ID] FROM " & Tabl & " IN '" & Archiv & "')"
    CurrentDb.Execute sql
    'Mitarbeiterstamm updaten
    Tabl = Table(10)
    sql = "INSERT INTO " & Tabl & " IN '" & Archiv & "' SELECT * FROM " & Tabl & " WHERE [ID] NOT IN (SELECT [ID] FROM " & Table(10) & " IN '" & Archiv & "')"
    CurrentDb.Execute sql
       
'=== Temporäre Tabellen ins Archiv übertragen
    varreturn = SysCmd(acSysCmdInitMeter, "Archiviere...", UBound(Table))
    For i = LBound(Table) To UBound(Table)
        varreturn = SysCmd(acSysCmdUpdateMeter, i)
        sql = "INSERT INTO " & Table(0) & " IN '" & Archiv & "' SELECT * FROM " & Table(0) & "_Arc"
        CurrentDb.Execute sql
    Next i
    
'=== Archivierte Daten aus BE enfernen
    varreturn = SysCmd(acSysCmdInitMeter, "Lösche archivierte Daten...", 1)
    'Veranstaltungen (-> Löschweitergabe!)
    sql = "DELETE * FROM " & AUFTRAGSTAMM & " WHERE [Dat_VA_Von] < " & DatumBis
    CurrentDb.Execute sql
    'Zeiten nicht verfügbar
    sql = "DELETE * FROM " & NVERFUEG & " WHERE [vonTag] < " & DatumBis
    CurrentDb.Execute sql
    
            
'=== Temporäre Tabellen löschen
    varreturn = SysCmd(acSysCmdInitMeter, "Entferne temporäre Tabellen...", UBound(Table))
    For i = LBound(Table) To UBound(Table)
        varreturn = SysCmd(acSysCmdUpdateMeter, i)
        If TableExists(Table(i) & "_Arc") = True Then DoCmd.DeleteObject acTable, Table(i) & "_Arc"
    Next i
        
    'Ladebalken ausblenden
    varreturn = SysCmd(acSysCmdClearStatus)
    Set rs = Nothing
    Set rs2 = Nothing
    
End Function


'Datenbankbeziehungen lesen
'Verwendung:
'Dim rel() As Relation
'rel() = get_relations()

Function get_relations() As Relation()

Dim rel As DAO.Relation
Dim arr_rel() As Relation
Dim i As Integer
    
    i = 0
    For Each rel In CurrentDb.Relations
        ReDim Preserve arr_rel(i)
        arr_rel(i).master = rel.Table
        arr_rel(i).mfield = rel.fields(0).Name
        arr_rel(i).slave = rel.ForeignTable
        arr_rel(i).sfield = rel.fields(0).ForeignName
        i = i + 1
    Next rel
      
    get_relations = arr_rel()

End Function