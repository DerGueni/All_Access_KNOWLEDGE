Attribute VB_Name = "zmd_Funktionen"
Option Compare Database
Option Explicit


Public Declare PtrSafe Function GetDeviceCaps Lib "gdi32" (ByVal hdc As Long, ByVal nIndex As Long) As Long
Public Declare PtrSafe Function GetDC Lib "user32" (ByVal hwnd As Long) As Long
Public Declare PtrSafe Function ReleaseDC Lib "user32" (ByVal hwnd As Long, ByVal hcd As Long) As Long

Public lHsize As Long, lVsize As Long

Const HORZRES = 8
Const VERTRES = 10


Function ScreenResolution()
' lHsize = Anzahl der horizontalen Bildschirmzeilen
' lVsize = Anzahl der vertikalen Bildschirmzeilen

Dim lRval As Long
Dim lDc   As Long
Dim hCM   As Long
Dim vCM   As Long

lDc = GetDC(0&)
lHsize = GetDeviceCaps(lDc, HORZRES)
lVsize = GetDeviceCaps(lDc, VERTRES)
lRval = ReleaseDC(0, lDc)

hCM = lHsize / 28.35
vCM = lVsize / 28.35

End Function


'Testumgebung
Function Testumgebung_umschalten()

Dim fso As Object
    
    'Produktivumgebung umschalten
    switchConnectAcc PfadProdLokal & Backend
    
    'aktuelles Backend holen
    Set fso = CreateObject("Scripting.FileSystemObject")
    fso.CopyFile PfadProdLokal & Backend, PfadTest & Backend, True
    Set fso = Nothing
    
    'Testumgebung verbinden
    switchConnectAcc PfadTestLokal & Backend

    'ACHTUNG -> ÄNDERT ALLE MAILADRESSEN AUF TRASHMAIL
    If InStr(CurrentDb.TableDefs("___Vorlagen_einlesen").Connect, "Testumgebung") <> 0 Then _
        CurrentDb.Execute "UPDATE tbl_MA_Mitarbeiterstamm SET Email = 'Johnnystrashmail@goldmail.de'"
    
    MsgBox "Frontend in Testumgebung"
    
End Function


'Frontend verteilen
Function FE_verteilen()

    Const FE = "Consys_FE.accdb"
    
    Dim fso As Object
    Dim gueni, gueni_desk, mel, reibling, pc5, pc6, pc7, wolly, kypi, Lokal As String
    
    'Pfade Frontends
    gueni = FrontendsVTS & "guenther.siegert\"
    gueni_desk = Server & "Users\guenther.siegert\Desktop\"
    mel = FrontendsVTS & "melanie.oberndorfer\"
    reibling = FrontendsVTS & "glaskugel\"
    pc5 = FrontendsVTS & "pc5\"
    pc6 = FrontendsVTS & "pc6\"
    pc7 = FrontendsVTS & "pc7\"
    wolly = FrontendsVTS & "wolfram.mueller\"
    kypi = FrontendsVTS & "johannes.kuypers\"
    Lokal = Server & "Database\Frontend\"
    
    If MsgBox("Aktuelle Version verteilen?", vbYesNo) = vbYes Then
        
        Set fso = CreateObject("Scripting.FileSystemObject")
        
        'Produktiv verbinden (Lokal)
        switchConnectAcc PfadProdLokal & Backend
        
        'Alle FEs schließen
        CurrentDb.Execute "INSERT INTO ztbl_CloseAll VALUES ('-1','-1')"
        
        Wait 15 'Sekunden

        'Application.Wait (TimeSerial(Hour(Now()), Minute(Now()), Second(Now()) + 10))
        CurrentDb.Execute "DELETE * FROM ztbl_CloseAll WHERE check = TRUE"
        
        'gueni
        If FileExists(gueni & FE) And Not FileExists(gueni & "Consys_FE_" & Date & ".accdb") Then Name gueni & FE As gueni & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, gueni & FE
        
        'gueni desktop
        If FileExists(gueni_desk & FE) And Not FileExists(gueni_desk & "Consys_FE_" & Date & ".accdb") Then Name gueni_desk & FE As gueni_desk & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, gueni_desk & FE
        
        'mel
        'If FileExists(mel & FE) Then Name mel & FE As mel & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, mel & FE
        
        'reibling
        'If FileExists(reibling & FE) Then Name reibling & FE As reibling & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, reibling & FE
        
        'pc5
        'If FileExists(pc5 & FE) Then Name pc5 & FE As pc5 & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, pc5 & FE
        
        'pc6
        'If FileExists(pc5 & FE) Then Name pc5 & FE As pc5 & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, pc6 & FE
        
        'pc7
        'If FileExists(pc5 & FE) Then Name pc5 & FE As pc5 & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, pc7 & FE
        
        'wolly
        'If FileExists(pc5 & FE) Then Name pc5 & FE As pc5 & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, wolly & FE
        
        'kypi
        If FileExists(kypi & FE) And Not FileExists(kypi & "Consys_FE_" & Date & ".accdb") Then Name kypi & FE As kypi & "Consys_FE_" & Date & ".accdb"
        fso.CopyFile PfadTest & FE, kypi & FE
        
        'Lokal
        fso.CopyFile PfadTestLokal & FE, Lokal & FE
        
        'Produktiv verbinden (Netzwerk)
        switchConnectAcc PfadProd & Backend
        
        'Lokal
        fso.CopyFile PfadTestLokal & FE, Lokal & FE
        
        'Testumgebung verbinden
        switchConnectAcc PfadTestLokal & Backend
        
        Set fso = Nothing
        
        MsgBox "Neues FE wurde erfolgreich verteilt"
    End If

End Function


'Function that wait an amount of time n in seconds
Function Wait(n As Double)

Dim TWait As Date
Dim TNow As Date

    TWait = Time
    TWait = DateAdd("s", n, TWait)
    Do Until TNow >= TWait
         TNow = Time
    Loop
    
End Function

Function change_BE()
    DatenMDBWechselAcc
End Function

Function close_timer()

DoCmd.Close acForm, "zfrm_Close"

End Function


'Zuordnungsdaten ins FE holen
Function refresh_zuoplanfe(Optional VADatum As Date, Optional DateCriteria As String, Optional SingleVA As Boolean)

Dim NverFE          As String
Dim KorrFE          As String
Dim sql             As String
Dim whereCondition  As String 'ZUO + PLAN
Dim whereCondition2 As String 'NV Zeiten
Dim whereCondition3 As String 'Korrekturen
Dim rs              As Recordset
Dim arr             As Variant
Dim ARR_STR()       As String
Dim ZUOIDS          As String
Dim i               As Integer
Dim BackendDB       As String
Dim sqlvon          As String
Dim sqlbis          As String
  
On Error Resume Next

    'Nichtverfügbarkeit
    NverFE = NVERFUEG_FE
    
    'Korrekturen
    KorrFE = "ztbl_MA_ZK_Korrekturen_FE"
    
    If SingleVA = False Then
        If DateCriteria <> "" Then
            whereCondition = " WHERE VADatum " & DateCriteria
            whereCondition2 = " WHERE vonDat " & DateCriteria
        Else
            'wenn kein Datum dann heute
            If VADatum = "00:00:00" Then VADatum = Now()
            
            'Daten aktueller Monat der Veranstaltung plus 30 tage ab Veranstaltungstag
            sqlvon = datumSQL(DateSerial(Year(VADatum), Month(VADatum), 1))
            sqlbis = datumSQL(VADatum + 30)
            whereCondition = " WHERE VADatum BETWEEN " & sqlvon & " AND " & sqlbis
            whereCondition2 = " WHERE vonDat BETWEEN " & sqlvon & " AND " & sqlbis
        End If
        
        
        'Zuordnungsdaten im FE löschen
        sql = "DELETE * FROM " & ZUORDNUNG_FE
        CurrentDb.Execute sql
        
        'Aktuelle Zuordnungen plus Zeitraum ins FE holen
        sql = "INSERT INTO " & ZUORDNUNG_FE & " SELECT * FROM " & ZUORDNUNG & whereCondition
        CurrentDb.Execute sql
        
        'Planungsdaten im FE löschen
        sql = "DELETE * FROM " & PLANUNG_FE
        CurrentDb.Execute sql
        
        'Aktuelle Planungen ins FE holen
        sql = "INSERT INTO " & PLANUNG_FE & " SELECT * FROM " & PLANUNG & whereCondition
        CurrentDb.Execute sql
    
        'Verfügbarkeitsdaten im FE löschen
        sql = "DELETE * FROM " & NverFE
        CurrentDb.Execute sql
        
        'Aktuelle Nichtverfügbarkeiten ins FE holen
        sql = "INSERT INTO " & NverFE & " SELECT * FROM tbl_MA_NVerfuegZeiten" & whereCondition2
        CurrentDb.Execute sql
        
        'Korrekturen Zeitkonten im FE löschen
        sql = "DELETE * FROM " & KorrFE
        CurrentDb.Execute sql
    
        'Aktuelle Korrekturen ins FE holen
        sql = "INSERT INTO " & KorrFE & " SELECT * FROM zqry_MA_ZK_Korrekturen" & whereCondition2
        CurrentDb.Execute sql
        
        'Zusatzdaten Zuordnung im FE löschen
        sql = "DELETE * FROM " & ZUO_STD_FE
        CurrentDb.Execute sql
        
        'Zusatzdaten Zuordnung ins FE holen
        sql = "SELECT [ID] FROM " & ZUORDNUNG_FE
        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        rs.MoveLast
        rs.MoveFirst
        arr = rs.GetRows(rs.RecordCount)
        ReDim ARR_STR(rs.RecordCount - 1)
        For i = 0 To UBound(arr, 2)
            ARR_STR(i) = arr(0, i)
        Next i
        ZUOIDS = Join(ARR_STR, ", ")
        sql = "INSERT INTO " & ZUO_STD_FE & " SELECT * FROM " & ZUO_STD & " WHERE ZUO_ID IN (" & ZUOIDS & ")"
        CurrentDb.Execute sql
        
        sql = "SELECT [ID] FROM " & NVERFUEG_FE
        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        rs.MoveLast
        rs.MoveFirst
        arr = rs.GetRows(rs.RecordCount)
        ReDim ARR_STR(rs.RecordCount - 1)
        For i = 0 To UBound(arr, 2)
            ARR_STR(i) = arr(0, i)
        Next i
        ZUOIDS = Join(ARR_STR, ", ")
        sql = "INSERT INTO " & ZUO_STD_FE & " SELECT * FROM " & ZUO_STD & " WHERE NV_ID IN (" & ZUOIDS & ")"
        CurrentDb.Execute sql
        
        rs.Close
        Set rs = Nothing
        
    Else ' SingleVA - einzelne Veranstaltung
        BackendDB = TLookup("Database", "MSysObjects", "Database IS NOT NULL")
        sqlvon = datumSQL(TLookup("Dat_VA_Von", "zqry_VA_Auftragstamm", , BackendDB))
        sqlbis = datumSQL(TLookup("Dat_VA_Bis", "zqry_VA_Auftragstamm", , BackendDB))
        whereCondition2 = " WHERE vonDat BETWEEN " & sqlvon & " AND " & sqlbis
         
        'Zuordnungsdaten im FE löschen
        sql = "DELETE * FROM " & ZUORDNUNG_FE
        CurrentDb.Execute sql
        
        'Aktuelle Zuordnungen ins FE holen
        sql = "INSERT INTO " & ZUORDNUNG_FE & " SELECT * FROM zqry_MA_VA_Zuordnung IN '" & BackendDB & "'"
        CurrentDb.Execute sql
        
        'Planungsdaten im FE löschen
        sql = "DELETE * FROM " & PLANUNG_FE
        CurrentDb.Execute sql
        
        'Aktuelle Planungen ins FE holen
        sql = "INSERT INTO " & PLANUNG_FE & " SELECT * FROM zqry_MA_VA_Planung IN '" & BackendDB & "'"
        CurrentDb.Execute sql
    
        'Verfügbarkeitsdaten im FE löschen
        sql = "DELETE * FROM " & NverFE
        CurrentDb.Execute sql
        
        'Aktuelle Nichtverfügbarkeiten ins FE holen
        sql = "INSERT INTO " & NverFE & " SELECT * FROM tbl_MA_NVerfuegZeiten" & whereCondition2
        CurrentDb.Execute sql
        
        'Korrekturen Zeitkonten im FE löschen
        sql = "DELETE * FROM " & KorrFE
        CurrentDb.Execute sql
    
        'Aktuelle Korrekturen ins FE holen
        sql = "INSERT INTO " & KorrFE & " SELECT * FROM zqry_MA_ZK_Korrekturen" & whereCondition2
        CurrentDb.Execute sql
        
        'Zusatzdaten Zuordnung im FE löschen
        sql = "DELETE * FROM " & ZUO_STD_FE
        CurrentDb.Execute sql
        
        sql = "INSERT INTO " & ZUO_STD_FE & " SELECT * FROM zqry_ZUO_Stunden IN '" & BackendDB & "'"
        CurrentDb.Execute sql
        
    End If
    
    'Verfügbarkeitstabelle updaten
    Call upd_ztbl_MA_Verfuegbarkeit

End Function

Sub Access_Version()

    Dim RichtigeRuntime
    Dim stRT As String
    If SysCmd(acSysCmdRuntime) Then
        If RichtigeRuntime Then
            stRT = "Runtime Echt"
        Else
            stRT = "Runtime Symulation"
        End If
    Else
        stRT = "Normal (Vollversion)" 'Nicht Runtime
    End If

End Sub


'Datenbank sperren
Function DBSperren()

    On Error GoTo Err

    'Prüfung, ob Runtime oder Vollversion
    If Not SysCmd(acSysCmdRuntime) Then
    
        DoCmd.ShowToolbar "Ribbon", acToolbarNo
    
        DoCmd.NavigateTo "acNavigationCategoryObjectType", _
                          "acNavigationGroupTables"
                          
        DoCmd.SelectObject acForm, vbNullString, True
        
        DoCmd.RunCommand acCmdWindowHide
        
    End If


Ende:
    Exit Function
    
Err:
    Err.clear
    Resume Next
        
End Function


'Filedialog zur Dateiauswahl -> bsp filter: "WORD", "*.doc,*.docx"
Function Dateiauswahl(Optional strTitle As String, Optional filter As String, Optional pfad As String) As String

    Dim objFiledialog As Office.FileDialog
    Set objFiledialog = Application.FileDialog(msoFileDialogOpen)

    With objFiledialog
        If pfad <> "" Then .InitialFileName = pfad
        .Filters.clear
        If filter <> "" Then .Filters.Add "", filter
        .InitialFileName = strTitle
        .title = strTitle
        .AllowMultiSelect = False
        If .Show = True Then
            Dateiauswahl = .SelectedItems(1)
        End If
    End With

    Set objFiledialog = Nothing

End Function


''Filedialog zur Dateiauswahl
'Function DateiAuswaehlen(Optional strTitle As String) As String
'
'    Dim objFiledialog As FileDialog
'    Set objFiledialog = Application.FileDialog(msoFileDialogOpen)
'
'    With objFiledialog
'        .Filters.Clear
'        .Filters.Add "Exceldoc", "*.xlsm, *.xls, *.xlsx"
'        .InitialFileName = strTitle
'
'        .title = strTitle
'        .AllowMultiSelect = False
'        If .Show = True Then
'            DateiAuswaehlen = .SelectedItems(1)
'        End If
'    End With
'
'    Set objFiledialog = Nothing
'
'End Function


'Prüfen, ob Tabelle existiert
Function TableExists(ByVal mytable As String) As Boolean

On Error GoTo Fehlerbehandlung
    Dim td As DAO.TableDef

    Set td = CurrentDb.TableDefs(mytable)
    TableExists = True
    Exit Function
    
Fehlerbehandlung:
    TableExists = False
End Function


'Prüfen, ob Abfrage existiert
Function queryExists(ByVal myquery As String) As Boolean

On Error GoTo Fehlerbehandlung
    Dim td As DAO.QueryDef

    Set td = CurrentDb.QueryDefs(myquery)
    queryExists = True
    Exit Function
    
Fehlerbehandlung:
    queryExists = False
End Function


'Datei kopieren
Function SaveFile(ByVal QuellDatei As String, ByVal zielDatei As String) As Boolean
'Datei zur Laufzeit kopieren:
Dim objFso As Object
Set objFso = CreateObject("Scripting.FileSystemObject")
 
On Error GoTo Err_SaveFile
 
objFso.CopyFile QuellDatei, zielDatei, True
 
Set objFso = Nothing

SaveFile = True
 
Exit_SaveFile:
Exit Function
 
Err_SaveFile:
SaveFile = False
MsgBox Err.description
Set objFso = Nothing
Resume Exit_SaveFile
 
End Function




'Shift beim start unterdrücken
'************* CODE START *************
Sub EnableShift(blnFlag As Boolean)

    On Error GoTo Error_EnableShift

    Dim db As DAO.Database
    Dim prp As DAO.Property

    Set db = CurrentDb
    'Property mit übergebenem Parameter belegen
    db.Properties!AllowByPassKey = blnFlag


Exit_EnableShift:
    Set prp = Nothing
    Exit Sub

Error_EnableShift:

    'Property erzeugen, falls noch nicht vorhanden
    If Err = 3270 Then
        Set prp = db.CreateProperty("AllowBypassKey", dbBoolean, blnFlag)
        db.Properties.append prp
        Resume Next
    Else
        MsgBox "Ausnahme Nr. " & str(Err.Number) & " " & Err.description
        Resume Exit_EnableShift
    End If

End Sub
'************* CODE ENDE *************


'Formular für Bearbeitung sperren
Function Bearbeitung_sperren(ByVal strForm As String) As Boolean

    Dim ctl As control
    
On Error GoTo Err

    'Bearbeitung Formular sperren
    For Each ctl In Forms(strForm).Controls
        If ctl.ControlType <> 104 And ctl.ControlType <> 100 And ctl.ControlType <> 111 Then ctl.Locked = True  '104 = Command Button 100 = Label 111 = Combo Box
    Next ctl
    
    Bearbeitung_sperren = True
    
Ende:
    Exit Function
Err:
    Bearbeitung_sperren = False
    Debug.Print Err.Number & " " & Err.description
    Resume Ende

End Function


'Formular für Bearbeitung freigeben
Function Bearbeitung_freigeben(ByVal strForm As String) As Boolean

    Dim ctl As control
    
On Error GoTo Err

    'Bearbeitung ermöglichen
    For Each ctl In Forms(strForm).Controls
        If ctl.Name = "Teilnehmer" Then
            ctl.Locked = True
        ElseIf ctl.ControlType <> 104 And ctl.ControlType <> 100 Then
            ctl.Locked = False  '104 = Command Button 100 = Label
        End If
    
    Next ctl
    
    Bearbeitung_freigeben = True
    
Ende:
    Exit Function
Err:
    Bearbeitung_freigeben = False
    Debug.Print Err.Number & " " & Err.description
    Resume Ende

End Function

'Alles Schließen
Function Close_all()

    DoCmd.SetWarnings False
    AccObjSchliessen "Tabelle"
    AccObjSchliessen "Abfrage"
    AccObjSchliessen "Formular"
    DoCmd.SetWarnings True
    
End Function

'Access Beenden
Function Quit_Access()

    DoCmd.SetWarnings False
    AccObjSchliessen "Tabelle"
    AccObjSchliessen "Abfrage"
    AccObjSchliessen "Formular"
    DoCmd.SetWarnings True
    AccObjSchliessen "Access"
    
End Function


'geöffnete Objekte schließen
Public Function AccObjSchliessen(ObjTyp As String, Optional strNicht As String)
 
        ' ---------------------------------------------------------
        '  Funktion zum Schliessen von offenen Access-Objekten
        '  Beim Schließen werden die jeweiligen Objekte ohne
        '  weitere Rückfrage gespeichert und anschließend
        '  geschlossen.
        '  Als Objekttyp "ObjTyp" können folgende Werte über-
        '  geben werden:
        '    Tabelle, Abfrage, Formular, Bericht, Makro und Modul
        '  Zusätzlich unterstützt die Funktion das Schließen der
        '  aktuellen Datenbank (ObjTyp=Datenbank) und das Beenden
        '  von Access (ObjTyp=Access).
        ' ---------------------------------------------------------
 
On Error GoTo Fehler
 
    Dim ConNam As String
    Dim ConTyp As Integer
    Dim db As DAO.Database
    Dim ctr As Container
    Dim x As Integer

        Select Case ObjTyp
            Case "Tabelle"
                ConNam = "Tables"
                ConTyp = acTable
            Case "Abfrage"
                ConNam = "Tables"
                ConTyp = acQuery
            Case "Formular"
                ConNam = "Forms"
                ConTyp = acForm
            Case "Bericht"
                ConNam = "Reports"
                ConTyp = acReport
            Case "Makro"
                ConNam = "Scripts"
                ConTyp = acMacro
            Case "Modul"
                ConNam = "Modules"
                ConTyp = acModule
            Case "Datenbank"
                CloseCurrentDatabase
            Case "Access"
                Quit
        End Select

        Set db = CurrentDb
        Set ctr = db.Containers(ConNam)
        For x = 0 To ctr.Documents.Count - 1
            If ctr.Documents(x).Name <> strNicht Then DoCmd.Close ConTyp, ctr.Documents(x).Name, acSaveNo
        Next x
 
Ende:
    Exit Function
Fehler:
    Debug.Print Err.Number & " " & Err.description, 16
    Resume Next

End Function

'Prüfen, ob Tabelle geöffnet
Public Function fctIsTableOpen(strName As String) As Boolean
  fctIsTableOpen = (SysCmd(acSysCmdGetObjectState, acTable, strName) > 0)
End Function


'Prüfen, ob Formular geöffnet
Public Function fctIsFormOpen(strName As String) As Boolean
  fctIsFormOpen = (SysCmd(acSysCmdGetObjectState, acForm, strName) > 0)
End Function


'Prüfen, ob Bericht geöffnet
Public Function fctIsReportOpen(strName As String) As Boolean
  fctIsReportOpen = (SysCmd(acSysCmdGetObjectState, acReport, strName) > 0)
End Function


'Autowert zurücksetzen
'Zum Testen im Direktfenster (Strg+G; Testfenster)
'FnSetzeAutowertZurueck "[DeinAutowertFeld]", "[DeineTabelle]"
Public Function FnSetzeAutowertZurueck(sFeld As String, sTable As String)
    
    Dim lNeu    As Long
    
On Error Resume Next
    lNeu& = Nz(TMax(sFeld$, sTable$), 0) + 1
    CurrentDb.Execute "ALTER TABLE " & sTable & _
                     " ALTER COLUMN " & sFeld$ & " COUNTER(" & lNeu& & ",1)"
End Function



'Duplikate löschen
Function loesche_Duplikate(tabelle As String, Feld1 As String, Feld2 As String, Feld3 As String, Feld4 As String, Optional Kriterium As String) As Boolean

    Dim strSQL, temp As String
    
    temp = tabelle & "_temp"
    
On Error GoTo Err
    
    'Tabelle löschen wenn vorhanden
    If TableExists(temp) Then CurrentDb.Execute "DROP TABLE [" & temp & "]"
    
    
    'Daten ohne Duplikate in temporäre Tabelle schieben
    strSQL = "SELECT DISTINCT [" & Feld1 & "], [" & Feld2 & "], [" & Feld3 & "], [" & Feld4 & "] INTO [" & temp & "] FROM [" & tabelle & "]"
    
    CurrentDb.Execute strSQL
    
    
    'Tabelle leeren
    strSQL = "DELETE * FROM [" & tabelle & "]"
    
    CurrentDb.Execute strSQL
    
    
    'Daten aus temporärer Tabelle in Tabelle schieben
    strSQL = "INSERT INTO [" & tabelle & "] SELECT * FROM [" & temp & "]"
    
    CurrentDb.Execute strSQL
    
    
    'temporäre Tabelle löschen
    strSQL = "DROP TABLE [" & temp & "]"
    
    CurrentDb.Execute strSQL
    

    'erfolgreich
    loesche_Duplikate = True


Ende:
    Exit Function

Err:
    loesche_Duplikate = False
    Resume Ende
    
End Function



'Alle Tabellen ausgeben
Sub Tabellen_ausgeben()
Dim tdf As TableDef

For Each tdf In CurrentDb.TableDefs
    Debug.Print tdf.Name
Next tdf
End Sub


' ###### Prüft, ob die Datei existiert
Function FileExists(ByVal strFile As String) As Boolean

On Error Resume Next

    FileExists = (Len(Dir(strFile)) > 0)

End Function


'Prüfen, ob Datei besetzt
Function Datei_in_Benutzung(ByVal Dateiname As String) As Boolean
    On Error Resume Next
    Close #1
    Open Dateiname For Random Access Read Lock Read Write As #1
        Datei_in_Benutzung = Err.Number <> 0
    Close #1
End Function


'Stammdaten fortschreiben
Function aktualisiere_Stammdaten(ByVal strTabelle As String, ByVal UPDFeld As String, ByVal UPDWert As String, ByVal Feld1 As String, ByVal Wert1 As String, _
    Optional ByVal Feld2 As String, Optional ByVal Wert2 As String, Optional ByVal Feld3 As String, Optional ByVal Wert3 As String) As String

    Dim strSQL, strWherecondition As String
    
On Error GoTo Err

    Select Case True
        Case IsDate(Wert1)
            strWherecondition = " WHERE [" & Feld1 & "] = " & datumSQL(Wert1)
        Case IsNumeric(Wert1)
            strWherecondition = " WHERE [" & Feld1 & "] = " & Wert1
        Case Else
            strWherecondition = " WHERE [" & Feld1 & "] = '" & Wert1 & "'"
    End Select
    
    If Wert2 <> "" Then
        Select Case True
            Case IsDate(Wert2)
                strWherecondition = strWherecondition & " AND [" & Feld2 & "] = " & datumSQL(Wert2)
            Case IsNumeric(Wert2)
                strWherecondition = strWherecondition & " AND [" & Feld2 & "] = " & Wert2
            Case Else
                strWherecondition = strWherecondition & " AND [" & Feld2 & "] = '" & Wert2 & "'"
        End Select
    End If
    
    If Wert3 <> "" Then
        Select Case True
            Case IsDate(Wert3)
                strWherecondition = strWherecondition & " AND [" & Feld3 & "] = " & datumSQL(Wert3)
            Case IsNumeric(Wert3)
                strWherecondition = strWherecondition & " AND [" & Feld3 & "] = " & Wert3
            Case Else
                strWherecondition = strWherecondition & " AND [" & Feld3 & "] = '" & Wert3 & "'"
        End Select
    End If
    
    'SQL aufbauen
    Select Case True
        Case IsDate(UPDWert)
            strSQL = "UPDATE [" & strTabelle & "] SET [" & UPDFeld & "] = " & datumSQL(UPDWert) & strWherecondition
        Case IsNumeric(UPDWert)
            strSQL = "UPDATE [" & strTabelle & "] SET [" & UPDFeld & "] = " & UPDWert & strWherecondition
        Case Else
            strSQL = "UPDATE [" & strTabelle & "] SET [" & UPDFeld & "] = '" & UPDWert & "'" & strWherecondition
    End Select
    
    
    
    'SQL Anweisung ausführen (temporäre Tabelle erzeugen)
    CurrentDb.Execute strSQL, dbFailOnError
    
    'erfolgreich
    aktualisiere_Stammdaten = "OK"
    
Ende:
    Exit Function
Err:
    aktualisiere_Stammdaten = Err.Number & " " & Err.description
    Resume Ende
    
End Function

'varDatum zu formatierendes Datum
'Aufruf: "SELECT * FROM Tabelle WHERE datDatum = " & DatumSQL(Me!SuchDatum)
Function datumSQL(vardatum As Variant) As String
 ' wandelt ein Datum vom deutschen Datumsformat
 ' in einen String im VBA-Format für SQL-Anweisungen um
    If IsDate(vardatum) Then
        datumSQL = Format(CDate(vardatum), "\#yyyy-mm-dd\#")
    End If
End Function


Function DatumUhrzeitSQL(vardatum As Variant) As String
 ' wandelt ein Datum vom deutschen Datumsformat
 ' in einen String im VBA-Format für SQL-Anweisungen um
    If IsDate(vardatum) Then
        DatumUhrzeitSQL = Format(CDate(vardatum), "\#yyyy-mm-dd hh:nn:ss\#")
    End If
End Function


Function UhrzeitSQL(vardatum As Variant) As String
 ' wandelt eine Uhrzeit vom deutschen Datumsformat
 ' in einen String im VBA-Format für SQL-Anweisungen um
    If IsDate(vardatum) Then
        UhrzeitSQL = Format(CDate(vardatum), "\#hh:nn:ss\#")
    End If
End Function


 'Temporäre Tabelle erzeugen
Function CreateTable(ByVal strTabelle As String, ByVal strAbf As String, Optional ByVal strWherecondition As String) As String

    Dim strSQL As String
    
On Error GoTo Err

    'Where-Condition anpassen
    If strWherecondition <> "" Then strWherecondition = " AND " & strWherecondition
    
    'SQL aubauen
    strSQL = "SELECT * INTO " & strTabelle & " FROM " & strAbf & strWherecondition

    If TableExists(strTabelle) Then CurrentDb.Execute "DROP TABLE " & strTabelle, dbFailOnError
    
    'SQL Anweisung ausführen (temporäre Tabelle erzeugen)
    CurrentDb.Execute strSQL, dbFailOnError
    
    'erfolgreich
    CreateTable = "OK"
    
Ende:
    Exit Function
Err:
    CreateTable = Err.Number & " " & Err.description
    Resume Ende

End Function


Function Warten(ByVal MilliSekunden As Double)
 
 'Quelle: www.dbwiki.net oder www.dbwiki.de
 
Dim i As Double
Dim Ende As Double
 
    Ende = Timer + (MilliSekunden / 1000)
 
    'Ladebalken
    SysCmd acSysCmdInitMeter, "Bitte warten...", Round(Ende - Timer)
    DoCmd.Hourglass True
        
    Do While i < Ende
      DoEvents
      i = Timer
      SysCmd acSysCmdUpdateMeter, Round(Ende - i)
    Loop
    
    SysCmd acSysCmdRemoveMeter
    DoCmd.Hourglass False
    
End Function


'PHP Datei Erzeugen
Function create_PHP(MD5 As String, mail As String, Datum As String, Zeit As String, Ende As String, Auftrag As String, Ort As String, Objekt As String, MA_ID As Integer) As String


    Dim fs As Object
    Dim f As Object
    Dim content As String
    
On Error GoTo Err

    content = "<?php" & vbCrLf & _
              "$email = " & Chr(34) & mail & Chr(34) & ";" & vbCrLf & _
              "$A_Auftr_Datum = " & Chr(34) & Format(Datum, "DDDD") & ", der " & Datum & Chr(34) & ";" & vbCrLf & _
              "$A_Auftr_Dienstbeginn = " & Chr(34) & Format(Zeit, "HH:MM") & Chr(34) & ";" & vbCrLf & _
              "$A_End_Zeit = " & Chr(34) & Format(Ende, "HH:MM") & Chr(34) & ";" & vbCrLf & _
              "$A_Auftrag = " & Chr(34) & Auftrag & Chr(34) & ";" & vbCrLf & _
              "$A_Ort = " & Chr(34) & Ort & Chr(34) & ";" & vbCrLf & _
              "$A_Objekt = " & Chr(34) & Objekt & Chr(34) & ";" & vbCrLf & _
              "$A_Sender = " & Chr(34) & Environ("UserName") & Chr(34) & ";" & vbCrLf & _
              "$A_File = " & Chr(34) & "DP_" & MA_ID & ".pdf" & Chr(34) & ";" & vbCrLf & _
              "?>"

    Set fs = CreateObject("Scripting.FileSystemObject")
    Set f = fs.CreateTextFile(PfadAwort & MD5 & ".php", True)
    
    f.Write content
    f.Close
    
    Set fs = Nothing
    Set f = Nothing

    Exit Function
    
Err:
   ' Log

End Function


Function writelog(Datei As String, Text As String)

Dim intFF As Integer

    intFF = FreeFile
    If Dir(Datei) = "" Then
        Open Datei For Output As #intFF
    Else
        Open Datei For Append As #intFF
    End If
    Print #intFF, Text
    Close #intFF

End Function


'Temporäre Tabelle für Auswertung der Antwortzeiten
Function Rückmeldeauswertung()

Dim sql As String
Dim tbl_rueck As String
Dim rst As Recordset

tbl_rueck = "ztbl_Rueckmeldezeiten"

'If fctIsTableOpen(tbl_rueck) Then DoCmd.Close acTable, tbl_rueck, acSaveNo
'If tableExists(tbl_rueck) Then CurrentDb.Execute "DROP TABLE " & tbl_rueck

CurrentDb.Execute "DELETE * FROM " & tbl_rueck

'Tabelle erstellen
'SQL = "SELECT MA_ID, Anfragezeitpunkt, Rueckmeldezeitpunkt INTO " & tbl_rueck & " FROM " & PLANUNG & _
      " WHERE Anfragezeitpunkt IS NOT NULL"
sql = "INSERT INTO " & tbl_rueck & " (MA_ID, Anfragezeitpunkt, Rueckmeldezeitpunkt, Status_ID)" & _
      " SELECT MA_ID, Anfragezeitpunkt, Rueckmeldezeitpunkt, Status_ID FROM " & PLANUNG & _
      " WHERE Anfragezeitpunkt IS NOT NULL"
CurrentDb.Execute sql
     
sql = "INSERT INTO " & tbl_rueck & " (MA_ID, Anfragezeitpunkt, Rueckmeldezeitpunkt)" & _
      " SELECT MA_ID, Anfragezeitpunkt, Rueckmeldezeitpunkt FROM " & ZUORDNUNG & _
      " WHERE Anfragezeitpunkt IS NOT NULL"
CurrentDb.Execute sql

'Status zugeordnet setzen bei Zusagen  -> Nur Automatische ZU/Absagen oder auch die manuell eingetragenen?
sql = "UPDATE " & tbl_rueck & " SET Status_ID = 3 WHERE Status_ID = 0" 'and Rueckmeldezeitpunkt IS NOT NULL"
CurrentDb.Execute sql

''Spalten anfügen: Durchschnittliche Antwortzeit
'SQL = "ALTER TABLE " & tbl_rueck & " ADD Reaktionszeit DATE NULL"
'CurrentDb.Execute SQL

'Antwortzeit
Set rst = CurrentDb.OpenRecordset(tbl_rueck)
If rst.RecordCount <> 0 Then
    Do
        If Not IsNull(rst.fields("Anfragezeitpunkt")) And Not IsNull(rst.fields("Rueckmeldezeitpunkt")) Then
            rst.Edit
            rst.fields("Reaktionszeit") = DateDiff("h", rst.fields("Anfragezeitpunkt"), rst.fields("Rueckmeldezeitpunkt"))
            rst.update
        End If
        rst.MoveNext
    Loop Until rst.EOF
End If

rst.Close
Set rst = Nothing

End Function


'Sender einer Email ermitteln
Function detect_sender() As String

Select Case LCase(Environ("UserName"))
        Case "güni"
            detect_sender = "Günther Siegert"
        Case "guenther.siegert"
            detect_sender = "Günther Siegert"
        Case "user"
            detect_sender = "Günther Siegert"
        Case "melanie.oberndorfer"
            detect_sender = "Melanie Oberndorfer"
        Case "mel"
            detect_sender = "Melanie Oberndorfer"
        Case "sabine.reibling"
            detect_sender = " i.A. Sabine Reibling"
        Case "glaskugel"
            detect_sender = " i.A. Sabine Reibling"
        Case "pc5"
            detect_sender = "i.A. Thomas Göschelbauer"
        Case Else
            detect_sender = Environ("UserName")
    End Select
End Function


'Anzahl Vorbelegungssätze Prüfen
Function check_Anzahl_MA(VA_ID As Long, VADatum_ID As Long)

Dim rst             As Recordset
Dim sql             As String
Dim VAStart_ID()    As Long
Dim i               As Integer
Dim c               As Integer
Dim x               As Integer
Dim Soll            As Integer
Dim Ist             As Integer
Dim LastPos         As Integer
Dim NeuPos          As Integer
Dim VAStartCriteria As String
Dim ZuoCriteria     As String
    
'    'Farben löschen
'    Call einfaerben(Forms("frm_va_auftragstamm").sub_MA_VA_Zuordnung.Form.PosNr, 0, 255, True)
    
    'VA_Start_IDs holen
    sql = "SELECT ID FROM " & VAStart & " WHERE VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " ORDER BY VA_Start ASC"
    Set rst = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    
    i = 1
    ReDim VAStart_ID(i)
    VAStart_ID(i) = rst(0)
    Do
        If VAStart_ID(i) <> rst(0) Then
            i = i + 1
            ReDim Preserve VAStart_ID(i)
            VAStart_ID(i) = rst(0)
        End If
        rst.MoveNext
    Loop Until rst.EOF
    rst.Close
    Set rst = Nothing
    
    'MA Gesamt Soll
    Soll = TSum("MA_Anzahl", VAStart, "VADatum_ID = " & VADatum_ID)
    TUpdate "TVA_Soll = " & Soll, anzTage, "ID = " & VADatum_ID
    'MA Gesamt Ist
    Ist = TCount("MA_ID", ZUORDNUNG, "VADatum_ID = " & VADatum_ID & " AND MA_ID <> 0")
    TUpdate "TVA_Ist = " & Ist, anzTage, "ID = " & VADatum_ID
    TUpdate "MA_Anzahl_Ist = " & Ist, VAStart, "VADatum_ID = " & VADatum_ID
    
    
    'Anzahl MA pro Start_ID prüfen
    For i = 1 To UBound(VAStart_ID)
        Soll = TLookup("MA_Anzahl", VAStart, "ID = " & VAStart_ID(i))
        Ist = TCount("PosNr", ZUORDNUNG, "VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID(i))
        ZuoCriteria = "VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND VAStart_ID = " & VAStart_ID(i)
        
        c = Soll - Ist
        'wenn zu wenig Vorbelegungssätze/Mitarbeiter
        If c > 0 Then
            Set rst = CurrentDb.OpenRecordset(ZUORDNUNG)
            rst.Edit
            On Error Resume Next 'Fehler, wenn noch keine Position im Auftrag
                LastPos = TMax("PosNr", ZUORDNUNG, "VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID) 'ohne VA_Start_ID, da übergreifend!!!
            On Error GoTo 0
            VAStartCriteria = "VA_ID = " & VA_ID & " AND VADatum_ID = " & VADatum_ID & " AND ID = " & VAStart_ID(i)
            NeuPos = LastPos + 1
            For x = 1 To c
                 rst.AddNew
                    rst.fields("VA_ID") = VA_ID
                    rst.fields("VADatum_ID") = VADatum_ID
                    rst.fields("VAStart_ID") = VAStart_ID(i)
                    rst.fields("PosNr") = NeuPos
                    rst.fields("MA_Start") = TLookup("VA_Start", VAStart, VAStartCriteria)
                    rst.fields("MA_Ende") = TLookup("VA_Ende", VAStart, VAStartCriteria)
                    rst.fields("Bemerkungen") = TLookup("Bemerkungen", VAStart, VAStartCriteria)
                    rst.fields("Aend_von") = Environ("UserName")
                    rst.fields("Aend_am") = Now()
                    rst.fields("VADatum") = TLookup("VADatum", VAStart, VAStartCriteria)
                    rst.fields("MVA_Start") = TLookup("MVA_Start", VAStart, VAStartCriteria)
                    rst.fields("MVA_Ende") = TLookup("MVA_Ende", VAStart, VAStartCriteria)
                 rst.update
                 NeuPos = NeuPos + 1
            Next x
            rst.Close
            Set rst = Nothing
        'Überschuss -> PosNr einfärben/löschen
        Else
            'Positionsnummern ermittlen und einzeln einfärben/löschen (wenn MA_ID = 0)
            c = 0
            For x = Soll + 1 To Ist
                LastPos = TMax("PosNr", ZUORDNUNG, ZuoCriteria) - c
                If TLookup("MA_ID", ZUORDNUNG, ZuoCriteria & " AND PosNr = " & LastPos) = 0 Then
                    CurrentDb.Execute "DELETE FROM " & ZUORDNUNG & " WHERE " & ZuoCriteria & " AND PosNr = " & LastPos
                Else
'                    Call einfaerben(Forms("frm_va_auftragstamm").sub_MA_VA_Zuordnung.Form.PosNr, LastPos, 255)
                    c = c + 1
                End If
            Next x
        End If
    Next i

End Function


'Zusagen/Zuordnungen neu Sortieren
'Laufende Nummern gehen pro VADatum_ID!
'-> VAStart_IDs müssen nicht berücksichtigt werden!
Function sort_zuo_plan(VA_ID As Long, VADatum_ID As Long, tabelle As Integer)

Dim rst      As Recordset
Dim sql      As String
Dim i        As Integer  'Counter PosNr
Dim Criteria As String

    Criteria = "VA_ID = " & VA_ID & " And VADatum_ID = " & VADatum_ID
    
    Select Case tabelle
        'Sortierung der ZUORDNUNG
        Case 1
            ' ab mindestens zwei Datensätzen
            If TCount("MA_ID", ZUORDNUNG, Criteria) < 2 Then Exit Function
            
            'Zugewiesene Datensätze sortiert (Sortierfeld = Nachname, bei Vorbelegungssätzen "ZZZ")
            'SQL = "SELECT * FROM qry_Mitarbeiter_Zusage WHERE " & CRITERIA & " ORDER BY Beginn ASC, Sortierfeld ASC"
            sql = "SELECT * FROM qry_Mitarbeiter_Zusage WHERE " & Criteria & " ORDER BY Beginn ASC, Ende ASC, Sortierfeld ASC"
            Set rst = CurrentDb.OpenRecordset(sql)
            'Set rst = rst.Clone 'Werte merken -> nicht mehr benötigt
            
            If rst.RecordCount > 1 Then
                i = 1
                'Vorbelegungssätze mit leeren MA_IDs -> MA_ID = 0 setzen
                sql = "UPDATE " & ZUORDNUNG & " SET  MA_ID = 0 WHERE MA_ID is Null"
                CurrentDb.Execute sql
                'Positionsnummern bei relevanten Datensätzen entfernen (inkl. Vorbelegungssätze MA_ID = 0)
                sql = "UPDATE " & ZUORDNUNG & " SET PosNr = '' WHERE " & Criteria
                CurrentDb.Execute sql
                
                'Positionsnummern updaten (TUpdate nötig, da rst aus Abfrage nicht editierbar!)
                Do 'Zugewiesene
                    TUpdate "PosNr = " & i, ZUORDNUNG, Criteria & " AND MA_ID = " & rst.fields("MA_ID") & _
                        " AND VAStart_ID = " & rst.fields("VAStart_ID") & " AND isNull(PosNr)"
                    i = i + 1
                    rst.MoveNext
                Loop Until rst.EOF
            End If
            
            rst.Close
            Set rst = Nothing
            
        'Sortierung der PLANUNG
        Case 2
            'Relevante Datensätze sortiert
            sql = "SELECT * FROM qry_Mitarbeiter_Geplant WHERE " & Criteria & " ORDER BY Nachname ASC"
            'Neue Positionsnummern einfügen
            Set rst = CurrentDb.OpenRecordset(sql)
            Set rst = rst.Clone 'Werte merken
            
            If rst.RecordCount > 1 Then
                'Positionsnummern bei relevanten Datensätzen entfernen
                sql = "UPDATE " & PLANUNG & " SET PosNr = '' WHERE " & Criteria
                CurrentDb.Execute sql
                
                i = 1
                Do
                    TUpdate "PosNr = " & i, PLANUNG, Criteria & " AND MA_ID = " & rst.fields("MA_ID") & _
                        " AND VAStart_ID = " & rst.fields("VAStart_ID") & " AND isNull(PosNr)"
                    rst.MoveNext
                    i = i + 1
                Loop Until rst.EOF
                rst.Close
                Set rst = Nothing
                
                
                'Absagen hinten anfügen
                sql = "SELECT * FROM " & PLANUNG & " WHERE " & Criteria & " AND Status_ID = 4"
                
                'Neue Positionsnummern einfügen
                Set rst = CurrentDb.OpenRecordset(sql)
                ' i wird fortgestetzt!
                If rst.RecordCount > 0 Then
                    Do
                        rst.Edit
                        rst.fields("PosNr") = i
                        rst.update
                        rst.MoveNext
                        i = i + 1
                    Loop Until rst.EOF
                End If
                rst.Close
            End If
            Set rst = Nothing
            
    End Select
    
End Function


'Hier werden die Vergleichszeiten aufgebaut
Function upd_Vergleichszeiten(VA_ID As Long, von As Date, bis As Date) As String

Dim sql         As String
Dim tbl_FE      As String
Dim tbl_BE      As String
Dim BackendDB   As String
Dim sqlStart    As String
Dim sqlEnde     As String
Dim rc          As String

On Error GoTo Err

    BackendDB = TLookup("Database", "MSysObjects", "Database IS NOT NULL")
    sqlStart = DateTimeForSQL(DateAdd("n", 0, von))
    sqlEnde = DateTimeForSQL(DateAdd("n", 0, bis))
    tbl_FE = "tbltmp_Vergleichszeiten"
    tbl_BE = "ztbltmp_Vergleichszeiten"
    
    'Frontend
    sql = "DELETE * FROM " & tbl_FE
    CurrentDb.Execute sql
    
    sql = ""
    sql = sql & "INSERT INTO " & tbl_FE & " ( VGL_Start, VGL_Ende, VGL_VA_ID )"
    sql = sql & " SELECT " & sqlStart & ", " & sqlEnde & ", " & VA_ID & " AS Ausdr1"
    sql = sql & " FROM _tblInternalSystemFE;"
    CurrentDb.Execute (sql)
    DoEvents
    
    'Backend
    sql = "DELETE * FROM " & tbl_BE & " IN '" & BackendDB & "'"
    CurrentDb.Execute sql
    
    sql = "INSERT INTO " & tbl_BE & " IN '" & BackendDB & "' SELECT * FROM " & tbl_FE
    CurrentDb.Execute sql
    
    upd_Vergleichszeiten = upd_ztbl_MA_Verfuegbarkeit
    
    Exit Function

Err:
    upd_Vergleichszeiten = Err.Number & " " & Err.description

End Function

'Verfügbarkeiten aus dem Backend holen
Function upd_ztbl_MA_Verfuegbarkeit() As String

Dim BackendDB   As String
Dim tbl         As String
Dim QRY         As String
Dim sql         As String

On Error GoTo Err

    BackendDB = TLookup("Database", "MSysObjects", "Database IS NOT NULL")
    tbl = "ztbl_MA_Verfuegbarkeit"
    QRY = "zqry_MA_Auswahl_Alle"
    
    sql = "DELETE * FROM " & tbl
    CurrentDb.Execute sql
    
    sql = "INSERT INTO " & tbl & "(MA_ID, Beginn, Ende, Grund)" & _
            " SELECT ID, Beginn, Ende, Grund FROM " & QRY & " IN '" & BackendDB & "'" & _
            " WHERE ID <> 0;"
    
    CurrentDb.Execute sql
    
    Exit Function
    
Err:
    upd_ztbl_MA_Verfuegbarkeit = Err.Number & " " & Err.description
    
End Function


'Hier wird die Query zur Verfügbarkeit aufgebaut (SQL)
Function upd_qry_Verfuegbarkeit(iVerf As Long, iAnstArt As Long, iQuali As Long, iAktiv As Long, Optional iVerplantVerfuegbar As Long, Optional iNur34a As Long) As String

Dim sql         As String
Dim QRY         As String
Dim anstArt     As String
Dim tbl         As String

    QRY = "zqry_MA_Verfuegbarkeit"

    sql = "SELECT * FROM " & QRY

    'Weitere Kriterien aufbauen
    If iQuali <> 1 And iAnstArt = 9 Then
        sql = sql & "_Quali WHERE Quali_ID = " & iQuali
    ElseIf iQuali = 1 And iAnstArt <> 9 Then
        sql = sql & " WHERE (Anstellungsart_ID = " & iAnstArt
    ElseIf iQuali <> 1 And iAnstArt <> 9 Then
        sql = sql & "_Quali WHERE Quali_ID = " & iQuali & " AND (Anstellungsart_ID = " & iAnstArt
    Else
        sql = sql & " WHERE 1 = 1"
    End If

    If iAnstArt = 13 Then
        sql = sql & " OR Anstellungsart_ID = 5 OR Anstellungsart_ID = 3)"
    ElseIf InStr(sql, "Anstellung") <> 0 Then
        sql = sql & ")"
    End If
    
    'Aktiv?
    If iAktiv = True Then sql = sql & " AND istAktiv = " & iAktiv
    
    'Verfügbar regulär
    If iVerf = True And iVerplantVerfuegbar = False Then sql = sql & " AND istVerfuegbar = " & iVerf
    
    'Planung = verfügbar
    If iVerf = True And iVerplantVerfuegbar = True Then sql = sql & " AND ( istVerfuegbar = " & iVerf & " OR istVerplant = " & iVerplantVerfuegbar & ")"
    
    'Nur 34a
    If iNur34a = True Then sql = sql & " AND Hat_keine_34a = True"
    
    sql = sql & " ORDER BY Name"
    
    upd_qry_Verfuegbarkeit = sql

End Function

'Aktualisierung der Verfügbarkeiten Variante 1
'Geschwindigkeitsoptimierung: "Z"-Abfragen laufen schneller... wenn Verfügbarkeiten nicht mehr passen, dann "Z"s rückbauen
Function aktualisiere_Verfuegbarkeiten(VA_ID As Long, MVA_Start As Date, Optional MVA_Ende As Date)

Dim strSQL As String
Dim iVerfueg As Long
Dim stmplng As Single

Dim dttemp As Date
Dim dttempst As Date


'Me!VADatum_ID.RowSource = "SELECT tbl_VA_AnzTage.ID, tbl_VA_AnzTage.VADatum FROM tbl_VA_AnzTage WHERE (((tbl_VA_AnzTage.VA_ID) = " & VA_ID & "));"
'Me!VAStart_ID.RowSource = "SELECT tbl_VA_Start.ID, tbl_VA_Start.VA_Start, tbl_VA_Start.VA_Ende FROM tbl_VA_Start WHERE (((tbl_VA_Start.VA_ID) = " & VA_ID & ")) ORDER BY VA_Start;"


CurrentDb.Execute ("UPDATE tbltmp_MA_Verfueg_tmp SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = -1;")

If Len(Trim(Nz(MVA_Ende))) = 0 Then
    stmplng = Get_Priv_Property("prp_VA_Start_AutoLaenge") / 24
    dttemp = MVA_Start + stmplng
Else
    dttemp = MVA_Ende
End If

dttempst = MVA_Start

Call zfCreateQuery_Verplant(dttempst, dttemp)
DoEvents
iVerfueg = Nz(TCount("MA_ID", "zqry_VV_tmp_belegt"), 0)

DoEvents
CurrentDb.Execute ("DELETE * FROM tbltmp_VV_Belegt")
If iVerfueg > 0 Then
    CurrentDb.Execute ("zqryVV_tmp_belegt_ADD")
    CurrentDb.Execute ("qry_VV_Upd_Verfueg_All")
End If

CurrentDb.Execute ("UPDATE tbltmp_MA_Verfueg_tmp SET tbltmp_MA_Verfueg_tmp.IstVerfuegbar = -1 Where IstSubunternehmer = True;")

End Function

'Control einfärben / Spalte Farbig markieren
Function einfaerben(control As control, Wert As Variant, color As String, Optional altloesch As Boolean)

Dim fcd As FormatCondition

On Error Resume Next

    If altloesch = True Then control.FormatConditions.Delete
    
    Set fcd = control.FormatConditions.Add(acFieldValue, acEqual, Wert)
        fcd.backColor = color
    Set fcd = Nothing


End Function


Function falscheStartID()

    Dim rst As Recordset
    Dim DatumID As Long
    Dim startzeit As Date
    Dim StartID As Long

    Set rst = CurrentDb.OpenRecordset("SELECT * FROM " & ZUORDNUNG & " ORDER BY VADatum_ID, MA_Start")
    
    DatumID = rst.fields("VADatum_ID")
    startzeit = rst.fields("MA_Start")
    StartID = rst.fields("VAStart_ID")
    
    Do
    'StartID gleich obwohl andere Startzeit
    If rst.fields("VADatum_ID") = DatumID And rst.fields("Ma_Start") <> startzeit And rst.fields("VAStart_ID") = StartID Then
        CurrentDb.Execute "INSERT INTO zzz_CheckStartId SELECT * FROM " & ZUORDNUNG
    End If
    
    If rst.fields("VADatum_ID") <> DatumID Then
        DatumID = rst.fields("VADatum_ID")
        startzeit = rst.fields("MA_Start")
        StartID = rst.fields("VAStart_ID")
    End If
    If rst.fields("MA_Start") <> startzeit Then
        startzeit = rst.fields("MA_Start")
        StartID = rst.fields("VAStart_ID")
    End If
    
    rst.MoveNext
    Loop Until rst.EOF

End Function


'Nächste (kleinste) freie Nummer/ID einer Tabelle ermitteln
Public Function getFreeID(ByVal TableName As String, ID_Fieldname As String) As Long
    Dim sql As String
    Dim rs As Recordset

    sql = ""
    sql = sql & "SELECT nz(Min(t." + ID_Fieldname + "),0)+1 AS FreeID "
    sql = sql & "FROM " + TableName + " AS t "
    sql = sql & "WHERE Nz((SELECT Min(p." + ID_Fieldname + ") "
    sql = sql & "          FROM " + TableName + " AS p "
    sql = sql & "          Where p." + ID_Fieldname + ">t." + ID_Fieldname + ") "
    sql = sql & "          - [t].[" + ID_Fieldname + "], 2) > 1;"

     Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)

    getFreeID = rs!FreeID

    rs.Close
    Set rs = Nothing

End Function


'Ausrichtung Bericht Seitenansicht
Function AusrichtungSetzen(strBericht As String, Optional blnHochformat As Boolean = True, Optional strPrinter As String)
    Const DM_HOCHFORMAT = 1
    Const DM_QUERFORMAT = 2
    Dim GeraeteZF       As str_DEVMODE
    Dim DM              As type_DEVMODE
    Dim strGeraetemodus As String
    Dim rpt             As Report
   
    ' Den Bericht in der Entwurfsansicht öffnen.
    DoCmd.OpenReport strBericht$, acDesign
    Set rpt = Reports(strBericht$)
    If Not IsNull(rpt.PrtDevMode) Then
        strGeraetemodus$ = rpt.PrtDevMode
        GeraeteZF.strGZF$ = strGeraetemodus$
        LSet DM = GeraeteZF
        ' Das Element Fields initialisieren.
        DM.lngFields& = DM.lngFields& Or DM.intOrientation%
        If blnHochformat Then
            DM.intOrientation% = DM_HOCHFORMAT
          Else
            DM.intOrientation% = DM_QUERFORMAT
        End If
        LSet GeraeteZF = DM                    ' Die Eigenschaft aktualisieren
        Mid(strGeraetemodus$, 1, 94) = GeraeteZF.strGZF$
        rpt.PrtDevMode = strGeraetemodus$
    End If
    'Drucker setzen
    If strPrinter <> "" Then rpt.Printer = Application.Printers(strPrinter)
    DoCmd.Close acReport, strBericht$, acSaveYes           ' Bericht speichern
End Function


'STUNDEN -> gibt Stunden auch bei Tageswechsel korrekt zurück
'Test: ?stunden("16:30:00","21:15:00")
Public Function stunden(ByVal Arbeitsbeginn As Date, ByVal Arbeitsende As Date)
    Call Ende(Arbeitsbeginn, Arbeitsende)
    stunden = Round(Arbeitsende - Arbeitsbeginn, 2)
End Function

Public Sub Beginn(Arbeitsbeginn)
    Call Beginn24(Arbeitsbeginn)
    Arbeitsbeginn = IIf(Arbeitsbeginn < 6, Arbeitsbeginn + 24, Arbeitsbeginn)
End Sub

Public Sub Ende(Arbeitsbeginn, Arbeitsende)
    Call Beginn24(Arbeitsbeginn)
    Call Ende24(Arbeitsende)
    Arbeitsende = IIf(Arbeitsende < Arbeitsbeginn, Arbeitsende + 24, Arbeitsende)
End Sub

Public Sub Beginn24(Arbeitsbeginn)
    Arbeitsbeginn = Arbeitsbeginn * 24
End Sub

Public Sub Ende24(Arbeitsende)
    Arbeitsende = Arbeitsende * 24
End Sub


Function create_Gesamtliste()
    
Dim Liste As String
Dim rst As Recordset
Dim sql As String
    
    Liste = "ztbl_Gesamtliste"
    
    sql = "DELETE * FROM  " & Liste
    CurrentDb.Execute sql
    
    sql = "INSERT INTO " & Liste & _
        " (ID, Datum, Auftrag) SELECT [ID], [Dat_VA_Von], [Auftrag] + ', ' + [Ort] + ', ' + [Objekt] FROM " & AUFTRAGSTAMM '& _
        " WHERE [Dat_VA_Von] > " & Datum_von
    CurrentDb.Execute sql
    
    Set rst = CurrentDb.OpenRecordset(Liste)
    
    Do
        rst.Edit
        rst.fields("Std_Brutto") = TSum("MA_brutto_std2", ZUORDNUNG, "VA_ID = " & rst.fields("ID"))
        rst.fields("Std_Netto") = TSum("MA_netto_std2", ZUORDNUNG, "VA_ID = " & rst.fields("ID"))
        rst.fields("Anzahl_MA") = TLookup("MA_Anzahl_Ist", VAStart, "VA_ID = " & rst.fields("ID"))
        'rst.Fields("Personalkosten") = rst.Fields("Std_Netto")
        'rst.Fields("Umsatz") =
        'rst.Fields("Fahrtkosten_KD") =
        'rst.Fields("Fahrtkosten_MA") =
        'rst.Fields("Ertrag_Brutto-Netto") =
        'rst.Fields("Ertrag_tba") =
        'rst.Fields("Ertrag_FK") =
        'rst.Fields("Rohertrag") =
        'rst.Fields("Gesamtertrag") =
        
        rst.update
        rst.MoveNext
    
    Loop Until rst.EOF
    
'    Datum
'    Auftrag Ort Location
'1   Std. brutto Summevon tbl_ma_va_zuordnung.MA_brutto_std2
'2   Std. netto  Summevon tbl_ma_va_zuordnung.MA_netto_std2
'3   Anzah MA    Summevon tbl_va_start.MA_Anzahl
'4   Personalkosten Summevon([tbl_ma_va_zuordnung.MA_Netto_Std2] * [Kosten_pro_MAStunde])
'5   Umsatz  Summevon ([tbl_ma_va_zuordnung.MA_Brutto_Std2]*[tbl_KD_Standardpreise.StdPreis])  mit Bedingung Preisart_ID = 1
'6   Fahrtkosten KD  Summevon ([tbl_va_Auftragstamm.Fahrtkosten]*[tbl_va_Auftragstamm.PKW_Anzahl])
'7   Fahrtkosten MA  Summevon tbl_ma_va_Zuordnung.PKW
'8   Ertrag Brutto - Netto   5-4
'9   Ertrag tba  Summevon tbl_ma_va_zuordnung.MA_ID mit Bedingung MA_ID = 1001
'10  Ertrag FK   6-7
'11  Rohertrag 8 + 10
'12  Gesamtertrag 8 + 9 + 10




    Set rst = Nothing
    
End Function


Function correct_MA_Start_Ende_ZUO()

Dim rst As Recordset
    
    Set rst = CurrentDb.OpenRecordset(ZUORDNUNG)
    
    Do

        If Len(rst.fields("MA_Start")) <> 8 Or Len(rst.fields("MA_Ende")) <> 8 Then
            Debug.Print Len(rst.fields("MA_Start")) & "  " & Len(rst.fields("MA_Ende")) & "  " & rst.fields("VA_ID") & "  " & rst.fields("MA_ID")
            rst.Edit
            If Not IsNull(rst.fields("MA_Start")) Then rst.fields("MA_Start") = Right(rst.fields("MA_Start"), 8)
            If Not IsNull(rst.fields("MA_Ende")) Then rst.fields("MA_Ende") = Right(rst.fields("MA_Ende"), 8)
            rst.update
        End If
        rst.MoveNext
    Loop Until rst.EOF

    Set rst = CurrentDb.OpenRecordset(PLANUNG)
    
    Do

        If Len(rst.fields("VA_Start")) <> 8 Or Len(rst.fields("VA_Ende")) <> 8 Then
            Debug.Print Len(rst.fields("VA_Start")) & "  " & Len(rst.fields("VA_Ende")) & "  " & rst.fields("VA_ID") & "  " & rst.fields("MA_ID")
            rst.Edit
            If Not IsNull(rst.fields("VA_Start")) Then rst.fields("VA_Start") = Right(rst.fields("VA_Start"), 8)
            If Not IsNull(rst.fields("VA_Ende")) Then
                If Len(rst.fields("VA_Ende") = 10) Then
                    rst.fields("VA_Ende") = "00:00:00"
                Else
                    rst.fields("VA_Ende") = Right(rst.fields("VA_Ende"), 8)
                End If
            End If
            rst.update
        End If
        rst.MoveNext
    Loop Until rst.EOF
End Function

'Feldwertprüfung intial
Public Function IsInitial(field As Variant) As Boolean

    If IsNull(field) Or field = "" Or field = 0 Then IsInitial = True

End Function


Function Feiertag(ByVal Datum As Date) As String
'TEST: ?feiertag("25.12.2050")
'NUR GESETZLICHE FEIERTAGE IN BAYERN

Dim intJahr As Integer
Dim x As Integer, y As Date
Dim intI As Integer, arrDatum(1 To 20)  As Date, arrText(1 To 20) As String
  
On Error Resume Next

    intJahr = VBA.Year(Datum)
    'Ostersonntag ermitteln
    x = (((255 - 11 * (intJahr Mod 19)) - 21) Mod 30) + 21
    y = DateSerial(intJahr, 3, 1) + x + (x > 48) + 6 - _
        ((intJahr + intJahr \ 4 + x + (x > 48) + 1) Mod 7)
    intI = 0
    
    'VARIABEL
    'intI = intI + 1: arrDatum(intI) = y - 48:  arrText(intI) = "Rosenmontag"
    intI = intI + 1: arrDatum(intI) = y - 2: arrText(intI) = "Karfreitag"
    intI = intI + 1: arrDatum(intI) = y: arrText(intI) = "Ostersonntag"
    intI = intI + 1: arrDatum(intI) = y + 1: arrText(intI) = "Ostermontag"
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 5, 1): arrText(intI) = "Tag der Arbeit"
    intI = intI + 1: arrDatum(intI) = y + 39: arrText(intI) = "Christi Himmelfahrt"
    intI = intI + 1: arrDatum(intI) = y + 49:  arrText(intI) = "Pfingstsonntag"
    intI = intI + 1: arrDatum(intI) = y + 50: arrText(intI) = "Pfingstmontag"
    intI = intI + 1: arrDatum(intI) = y + 60: arrText(intI) = "Fronleichnam"
    'FIX:
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 1, 1): arrText(intI) = "Neujahr"
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 1, 6):  arrText(intI) = "Hl. drei Könige"
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 10, 3):  arrText(intI) = "Tag der deutschen Einheit"
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 11, 1):  arrText(intI) = "Allerheiligen"
    'intI = intI + 1 :arrDatum(intI) = DateSerial(intjahr, 12, 24):  arrText(intI) = "Heiligabend"
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 12, 25):  arrText(intI) = "1. Weihnachtstag"
    intI = intI + 1: arrDatum(intI) = DateSerial(intJahr, 12, 26):  arrText(intI) = "2. Weihnachtstag"
    'intI = intI + 1: arrDatum(intI) = DateSerial(intjahr, 12, 31):  arrText(intI) = "Silvester"
    
    For intI = LBound(arrDatum) To intI
        If Datum = arrDatum(intI) Then
            Feiertag = arrText(intI)
        End If
    Next

End Function

'Monat aus Zahl
Function Monat_lang(Monat As Integer) As String
    
    Select Case Monat
        Case 1
            Monat_lang = "Januar"
        Case 2
            Monat_lang = "Februar"
        Case 3
            Monat_lang = "März"
        Case 4
            Monat_lang = "April"
        Case 5
            Monat_lang = "Mai"
        Case 6
            Monat_lang = "Juni"
        Case 7
            Monat_lang = "Juli"
        Case 8
            Monat_lang = "August"
        Case 9
            Monat_lang = "September"
        Case 10
            Monat_lang = "Oktober"
        Case 11
            Monat_lang = "November"
        Case 12
            Monat_lang = "Dezember"
    End Select
    
End Function


'Array Sortieren
Function BubbleSort(ByRef strArray As Variant) As Variant()
    'sortieren von String Array
    'eindimensionale Array
    'Bubble-Sortier-Verfahren
   Dim z       As Long
   Dim i       As Long
   Dim strWert As Variant
     
    For z = UBound(strArray) - 1 To LBound(strArray) Step -1
        For i = LBound(strArray) To z
            If LCase(strArray(i)) > LCase(strArray(i + 1)) Then
                strWert = strArray(i)
                strArray(i) = strArray(i + 1)
                strArray(i + 1) = strWert
            End If
        Next i
    Next z
     
    BubbleSort = strArray
     
End Function

'Feldwerte einer Tabelle oder Abfrage in Array selektieren => Array muss vom Typ Variant sein!
Function select_in_array(quelle As String, field As String, WHERE As String) As Variant

Dim sql     As String
Dim rs      As Recordset
Dim arr     As Variant
Dim tmp()   As Variant
Dim i       As Integer

On Error GoTo Err

    sql = "SELECT " & field & " FROM " & quelle & " WHERE " & WHERE
    Set rs = CurrentDb.OpenRecordset(sql)
    rs.MoveLast
    rs.MoveFirst
    arr = rs.GetRows(rs.RecordCount)
    rs.Close
    Set rs = Nothing
    
    'Werte in String schreiben
    For i = LBound(arr, 2) To UBound(arr, 2)
        ReDim Preserve tmp(i)
        tmp(i) = arr(0, i)
    Next i
    
Ende:
    select_in_array = tmp
    Exit Function
Err:
    Resume Ende
End Function


'Feldwerte einer Tabelle oder Abfrage als String ausgeben
Function select_in_string(quelle As String, field As String, WHERE As String) As String

Dim sql As String
Dim rs  As Recordset
Dim arr As Variant
Dim i   As Integer

On Error GoTo Err

    sql = "SELECT " & field & " FROM " & quelle & " WHERE " & WHERE
    Set rs = CurrentDb.OpenRecordset(sql)
    rs.MoveLast
    rs.MoveFirst
    arr = rs.GetRows(rs.RecordCount)
    rs.Close
    Set rs = Nothing
    
    'Werte in String schreiben
    For i = LBound(arr, 2) To UBound(arr, 2)
        select_in_string = select_in_string & arr(0, i) & ","
    Next i

    'letztes Komma entfernen
    select_in_string = Left(select_in_string, Len(select_in_string) - 1)
    
Ende:
    Exit Function
Err:
    select_in_string = 0
    Resume Ende
End Function


'Standardwerte bei neuem Mitarbeiter
Function set_values_new_ma(MA_ID As Long)

Dim rs  As Recordset
Dim sql As String

    sql = "SELECT * FROM " & MASTAMM & " WHERE ID = " & MA_ID
    
    Set rs = CurrentDb.OpenRecordset(sql)
    rs.Edit
    
    rs.fields("Eintrittsdatum") = Left(Now, 10)
    rs.fields("Bezuege_gezahlt_als") = "Stundenlohn"
    
    rs.update
    rs.Close
    Set rs = Nothing

End Function


'Qualifikation für Mitarbeiter eintragen
Function set_quali(MA_ID As Long, Quali_ID As Long)

Dim tbl As String

    tbl = "tbl_MA_Einsatz_Zuo"

    If TCount("*", tbl, "MA_ID = " & MA_ID & " AND Quali_ID = " & Quali_ID) = 0 Then _
        CurrentDb.Execute " INSERT INTO " & tbl & "(MA_ID, Quali_ID) VALUES (" & MA_ID & "," & Quali_ID & ")"

End Function

'Makro im Backend / in anderer DB ausführen
Function execute_Makro(Makro As String, Optional db As String)

Dim ShellExec   As String

    If IsInitial(db) Then db = TLookup("Database", "MSysObjects", "Database IS NOT NULL")
    ShellExec = "C:\Program Files\Microsoft Office\root\Office16\MSACCESS.EXE /EMBEDDING " & db & " /x " & Makro
    Shell ShellExec

End Function


'Formular nach Excel exportieren
Public Function ExportFormToExcel(strExcelPath As String, sfm As Form)
     Dim db As DAO.Database
     Dim qdf As QueryDef
     Dim strQuery As String
     Dim strSQL As String
     Dim strFilter As String
     Dim strOrderBy As String
     Dim strRecordsource As String
     On Error Resume Next
     Kill strExcelPath
     On Error GoTo 0
     Set db = CurrentDb
     strQuery = "qryTemp"
     If Left(sfm.recordSource, 6) = "SELECT" Then
         strSQL = sfm.recordSource
     Else
         strSQL = "SELECT * FROM " & sfm.recordSource
     End If
     If sfm.FilterOn = True Then
         strFilter = sfm.filter
     End If
     If sfm.OrderByOn = True Then
         strOrderBy = sfm.OrderBy
     End If
     strSQL = AddWhereAndOrderByToSQL(strSQL, strFilter, strOrderBy)
     Set qdf = db.CreateQueryDef(strQuery, strSQL)
     DoCmd.TransferSpreadsheet acExport, acSpreadsheetTypeExcel12Xml, strQuery, strExcelPath, True
     db.QueryDefs.Delete strQuery
End Function

Public Function AddWhereAndOrderByToSQL(strSQL As String, Optional strFilter As String, _
         Optional strOrderBy As String) As String
     Dim strTemp As String
     strTemp = strSQL
     If Not Len(strFilter) = 0 Then
         If InStr(1, strTemp, "WHERE") = 0 Then
             If InStr(1, strTemp, "ORDER BY") = 0 Then
                 strTemp = strTemp & " WHERE " & strFilter
             Else
                 strTemp = Replace(strTemp, " ORDER BY ", " WHERE " & strFilter & " ORDER BY ")
             End If
         Else
             If InStr(1, strTemp, "ORDER BY") = 0 Then
                 strTemp = strTemp & " AND " & strFilter
             Else
                 strTemp = Replace(strTemp, " ORDER BY ", " AND " & strFilter & " ORDER BY ")
             End If
         End If
     End If
     If Not Len(strOrderBy) = 0 Then
         If InStr(1, strTemp, " ORDER BY ") = 0 Then
             strTemp = strTemp & " ORDER BY " & strOrderBy
         Else
             strTemp = strTemp & ", " & strOrderBy
         End If
     End If
     AddWhereAndOrderByToSQL = strTemp
End Function

Function calc_percentage_KD_hours(kun_ID As Long, Optional Jahr As Integer, Optional Monat As Integer) As Double

Dim QRY         As String
Dim WHERE       As String
Dim StundenGes  As Double
Dim StundenRel  As Double

On Error Resume Next

    QRY = "zqry_KD_Gesamtstunden_Datum"
    
    If Not IsInitial(Jahr) Then
        WHERE = "Jahr = " & Jahr
        If Not IsInitial(Monat) Then WHERE = WHERE & " AND Monat = " & Monat
    End If

    StundenGes = TSum("SummevonMA_Brutto_Std2", QRY, WHERE)
    StundenRel = TSum("SummevonMA_Brutto_Std2", QRY, WHERE & " AND kun_Id = " & kun_ID)
    
    calc_percentage_KD_hours = (StundenRel / StundenGes) * 100
    calc_percentage_KD_hours = Round(calc_percentage_KD_hours, 2)

End Function

'Replace Characters - Sonderzeichen ersetzen
'-> Verweise: Microsoft VBScript Regular Expression 5.5
Public Function CleanFileName(ByVal sFilename As String, Optional ByVal sChar As String = "") As String
Dim oRegExp As RegExp
    Set oRegExp = New RegExp
    With oRegExp
    .IgnoreCase = True
    .Global = True
    .MultiLine = True
    .Pattern = "[\\/:?*^""|]"
    ' alle nicht zulässigen Zeichen ersetzen
    CleanFileName = .Replace(sFilename, sChar)
    End With
    Set oRegExp = Nothing
End Function

'Function Rech_Nr_fuellen()
'
'Dim rst As Recordset
'
'Set rst = CurrentDb.OpenRecordset(ZUORDNUNG)
'
'Do
'    If InStr(rst.Fields("Bemerkungen"), "Berechnet") Then Debug.Print rst.Fields("VA_ID") & "_" & TUpdate("Rech_NR = '" & Mid(rst.Fields("Bemerkungen"), 11, Len(rst.Fields("Bemerkungen"))) & "'", AUFTRAGSTAMM, "ID = " & rst.Fields("VA_ID"))
'
'    rst.MoveNext
'Loop Until rst.EOF
'
'End Function


''NICHT MEHR BENÖTIGT
'Function zuocheck_ecatt()
'
'    Dim rst As Recordset
'
'    Set rst = CurrentDb.OpenRecordset(ZUORDNUNG)
'
'    Do
'
'        rst.Edit
'        rst.Fields("Bemerkungen") = TLookup("Nachname", MASTAMM, "ID = " & rst.Fields("MA_ID"))
'        Debug.Print rst.Fields("Bemerkungen")
'        rst.Update
'        rst.MoveNext
'
'    Loop Until rst.EOF
'
'    rst.Close
'    Set rst = Nothing
'
'End Function



'Function update_Zeitpunkte()
'
'Dim SQL
'
'SQL = "UPDATE tbl_MA_VA_Planung AS A " & _
'      "INNER JOIN ztbl_Sync AS N " & _
'      "ON A.VA_ID = N.VA_ID " & _
'      "AND A.MA_ID = N.MA_ID " & _
'      "AND A.VADatum_ID = N.VADatum_ID " & _
'      "AND A.VAStart_ID = N.VAStart_ID " & _
'      "Set A.Anfragezeitpunkt = N.Anfragezeitpunkt"
'
'
''CurrentDb.Execute SQL
'
'
'SQL = "UPDATE tbl_MA_VA_Zuordnung AS A " & _
'      "INNER JOIN ztbl_Sync AS N " & _
'      "ON A.VA_ID = N.VA_ID " & _
'      "AND A.MA_ID = N.MA_ID " & _
'      "AND A.VADatum_ID = N.VADatum_ID " & _
'      "AND A.VAStart_ID = N.VAStart_ID " & _
'      "Set A.Anfragezeitpunkt = N.Anfragezeitpunkt"
'
'
''CurrentDb.Execute SQL
'
'
'End Function


'EXTRAS-> VERWEISE
Function Verweise_auslesen()
Dim ref As Reference

On Error Resume Next

     For Each ref In References
        Debug.Print "Name:     " & ref.Name
        'Debug.Print "BuildIn:  " & ref.BuiltIn
        Debug.Print "FullPath: " & ref.fullPath
        'Debug.Print "GUID:     " & ref.GUID
        Debug.Print "IsBroken: " & ref.IsBroken
        'Debug.Print "Kind:     " & ref.Kind
        'Debug.Print "Major:    " & ref.Major
        'Debug.Print "Minor:    " & ref.Minor
        
        Debug.Print ""
     Next ref
     
End Function


Sub TEST()

Dim rs As Recordset
Dim sql As String
Dim tbl As String

On Error Resume Next

    sql = "SELECT * FROM MsysObjects"

    Set rs = CurrentDb.OpenRecordset(sql)
    Do While Not rs.EOF
    
        tbl = rs.fields("Name")
        If InStr(tbl, "tbltmp_") <> 0 Then DoCmd.OpenTable tbl
        rs.MoveNext
    Loop
    
End Sub

Function qr_erstellen(ZUO_ID As Long) As String

Dim PDF_Datei   As String
Dim MA_ID       As Long
Dim VA_ID       As Long
Dim Name        As String
Dim Bemerkungen As String
Dim Info        As String
Dim title       As String
Dim data        As String
Dim Text        As String
Dim text2       As String

    MA_ID = TLookup("MA_ID", ZUORDNUNG, "ID=" & ZUO_ID)
    VA_ID = TLookup("VA_ID", ZUORDNUNG, "ID=" & ZUO_ID)
    
    Name = Nz(TLookup("Nachname", MASTAMM, "ID=" & MA_ID), "") & " " & Nz(TLookup("Vorname", MASTAMM, "ID=" & MA_ID), "")
    Bemerkungen = Nz(TLookup("Bemerkungen", ZUORDNUNG, "ID=" & ZUO_ID), "")
    Info = Nz(TLookup("Info", ZUORDNUNG, "ID=" & ZUO_ID), "")
    
    title = Nz(TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & VA_ID), "") & ", " & Nz(TLookup("Ort", AUFTRAGSTAMM, "ID=" & VA_ID), "") & ", " & Nz(TLookup("Objekt", AUFTRAGSTAMM, "ID = " & VA_ID), "")
    data = ZUO_ID
    Text = Name & vbCrLf & Bemerkungen & vbCrLf & Info
        
    text2 = CleanFileName(Name & " " & Bemerkungen & " " & Info)
    PDF_Datei = PfadTempFiles & title & " " & text2 & ".pdf"
    
    Call Set_Priv_Property("prp_qr_title", title)
    Call Set_Priv_Property("prp_qr_data", data)
    Call Set_Priv_Property("prp_qr_text", Text)
    
    DoCmd.OutputTo acOutputReport, "zrpt_QR_Code", acFormatPDF, PDF_Datei

    qr_erstellen = PDF_Datei
    
End Function
