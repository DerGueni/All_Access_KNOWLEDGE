Option Compare Database
Option Explicit

' Funktionen, die nur True oder False / Ja oder Nein zurückgeben

'#########################################################################################################

'   IsSounddriverOK    - Ist der Sounddriver installiert ?
'   Is64Bit            - True wennn 64 bit
'   fIsCreated         - Gibt´s die Menüleiste (Buttonleiste) ?
'   IsReplica          - Ist die Datenbank ein Replikat ?
'   IsMDE              - Ist die Datenbank eine (echte) MDE
'   IsRuntime          - Ist Access als Runtime gestartet oder nicht ?
'   IsSubForm          - Bestimmt, ob das angegebene bzw. aktive Formular momentan ein Unterformular ist.
'   isFormLoad         - Ist die Form geladen ?
'   isTableLoad        - Ist die Tabelle geladen ? (Nur nicht eingebundene Tabellen, keine Queries)
'   IsReportLoad       - Ist der Report geladen ?
'   IsRunning          - Ist Access bereits gestartet ?
'   IsOffice97PgmLoad  - Ist ein anderes Office 97 Programm geladen ?
'
'   ControlExist       - Existiert das Control
'   Table_Exist        - Gibt´s die Tabelle ? (Auch eingebundene Tabellen und Queries)
'   File_Exist         - Gibt´s die Datei ?
'   Dir_Exist          - Existiert das Directory
'   RecordsExist       - Enthält der RecordSet Daten ?
'   ObjectExists       - Existiert das Objekt (Table, Query, Makro, Report, Modul)
'   File_Lock          - Kann die Datei gelockt werden ?
'   IsQry              - Ist die übergebene Tabelle eine Abfrage ? True = Es ist eine Abfrage
'   IsDateBetween2Dates - Liegt ein Datum zwischen zwei Datumswerten ?

'#########################################################################################################

'**********************************************************************************
' Deklaration: Ist Soundtreiber installiert ?
' 1 = Ja, 0 = Nein
' Aber auch ein installierter Soundtreiber funktioniert nur, wenn auch
' Boxen angeschlossen sind. Dies kann (natürlich) nicht geprüft werden.
' Usage: ... If IsSounddriverOK() Then
' aus www.basicworld.com
'**********************************************************************************
Declare PtrSafe Function IsSounddriverOK Lib "winmm.dll" Alias "waveOutGetNumDevs" () As Long

Function Is64Bit() As Boolean

Is64Bit = False
#If Win64 Then
    Is64Bit = True
#End If

End Function

Function fIsCreated(strMenuName) As Boolean
'gefunden in der CRSOFT MDB
On Error GoTo fIsCreated_Err '8/23/98 8:19:54 PM
Dim intNumberMenus As Integer
Dim i As Integer
intNumberMenus = Application.CommandBars.Count
fIsCreated = False
For i = 1 To intNumberMenus
    If Application.CommandBars(i).Name = strMenuName Then
        fIsCreated = True
        i = intNumberMenus
    End If
Next
ExitfIsCreated:
    Exit Function
fIsCreated_Err:
    MsgBox "fIsCreated: " & err.Number & vbCrLf _
    & err.description, vbInformation, "CRSOFT"
    Resume ExitfIsCreated
End Function


Function IsReplica(dbs As DAO.Database) As Boolean
'gefunden in der CRSOFT MDB
    On Error Resume Next
If dbs.Properties("Replicable") = "T" Then
    If err = 3270 Then
    ' This is not a replica. Let startup form display.
    IsReplica = False
    Else
    ' This database is a Design Master or a replica so
    ' close the splash screen before it displays.
    IsReplica = True
    End If
End If
End Function


Function IsMDE(dbs As DAO.Database) As Boolean
    Dim strMDE As String
    On Error Resume Next
    strMDE = dbs.Properties("MDE")
    If err = 0 And strMDE = "T" Then
        ' This is an MDE database.
        IsMDE = True
    Else
        IsMDE = False
    End If
End Function


Function IsRuntime()
'The following example demonstrates how to create a function called
'IsRunTime() that you can use to prevent an application from being run
'in the retail version of Microsoft Access.
' aus MSKB Q103182
'
         On Error GoTo ErrIsRuntime
         IsRuntime = SysCmd(6)
 
ByeIsRuntime:
         Exit Function
 
ErrIsRuntime:
         If (err = 5) Then
            IsRuntime = False
         Else
            Error err
         End If
         Resume ByeIsRuntime
      
End Function


'------------------------------------------------------------------------
' FUNKTION  : IsSubForm(...)
' ZWECK     : Bestimmt, ob das angegebene bzw. aktive Formular momentan ein Unterformular ist.
' ARGUMENTE : (frm) = zu überprüfendes Formularobjekt
' ERGEBNIS  : true = das Formular ist ein Unterformular, false = sonst
'------------------------------------------------------------------------
Public Function IsSubForm(Optional frm) As Boolean
    Dim StrName As String
    IsSubForm = False
    On Error GoTo err_IsSubform
    If IsMissing(frm) Then Set frm = Screen.ActiveForm
    StrName = frm.Name        ' Liefert Fehler, falls Fenster kein Formular ist
    StrName = frm.Parent.Name ' Liefert Fehler, falls Formular kein 'Parent'-Formular hat
    IsSubForm = True
err_IsSubform:
    On Error GoTo 0
End Function



'**********************************************************************************
'Prüft, ob das Formular frm geladen ist
'
'Rückgabe: TRUE, Formular ist geladen
'          FALSE, Formular ist nicht geladen
'**********************************************************************************
Function isFormLoad(frm As String) As Boolean
    isFormLoad = SysCmd(SYSCMD_GETOBJECTSTATE, acForm, frm)
End Function


'**********************************************************************************
'Prüft, ob der Report RName geladen ist
'
'Rückgabe: TRUE, Report ist geladen
'          FALSE, Report ist nicht geladen
'**********************************************************************************
Function IsReportLoad(RName As String) As Boolean
    IsReportLoad = SysCmd(SYSCMD_GETOBJECTSTATE, acReport, RName)
End Function

'**********************************************************************************
'Function isTableLoad ()
'Prüft, ob die Tabelle in der MDB vorhanden und geladen (geöffnet) ist - nicht für eingebundene Tabellen
'
'Rückgabe: TRUE, tbl ist vorhanden und geladen
'          FALSE, tbl ist nicht vorhanden oder nur eingebunden
'**********************************************************************************
Function isTableLoad(tbl As String) As Boolean
    isTableLoad = SysCmd(SYSCMD_GETOBJECTSTATE, acTable, tbl)
End Function


'**********************************************************************************
' Diese Funktion ermittelt, ob ACCESS bereits aktiv ist
' Sofern IsRunning in einer ZWEITEN Instanz von ACCESS aufgerufen wird
' gibt IsRunning -1 (True) zurück
' Sofern nur eine Instanz von ACCESS geladen ist, wird 0 (False) zurückgegeben
'**********************************************************************************
Function IsRunning() As Boolean
    Dim db As DAO.Database
    Set db = CurrentDb()
    If TestDDELink(db.Name) Then
        IsRunning = -1
    Else
        IsRunning = 0
    End If
End Function

' Helper Function
Private Function TestDDELink(ByVal strAppName$) As Integer
    
    Dim varDDEChannel
    On Error Resume Next
    Application.SetOption ("Ignore DDE Requests"), True
    varDDEChannel = DDEInitiate("MSAccess", strAppName)
    
   ' When the app isn't already running this will error
    If err Then
       TestDDELink = False
    Else
        TestDDELink = True
        DDETerminate varDDEChannel
        DDETerminateAll
    End If
    Application.SetOption ("Ignore DDE Requests"), False

End Function


Function IsOffice97PgmLoad(Programm As String) As Boolean
'*********************
' Stellt fest, ob eines der Office 97 Programme geladen ist
' Programm = Access, OfficeBinder, Excel, Graph, PowerPoint, Office, Outlook, Word
' Aufruf z.B: If IsOffice97PgmLoad("Word") Then ...
' Derivat aus Auto97.hlp von KObd
'*********************
'
'                         Eingebund.    Programm
'Programmname        Vers Referenz      Class         Class Name
'------------------------------------------------------------------------------
'Microsoft Access     97  MSACC8.OLB    Access        Access 8.0 Object Library
'Microsoft Binder     97  MSBDR8.OLB    OfficeBinder  Binder 8.0 Object Library
'Microsoft Excel      97  EXCEL8.OLB    Excel         Excel 8.0 Object Library
'Microsoft Graph      97  GRAPH8.OLB    Graph         Graph 8.0 Object Library
'Microsoft PowerPoint 97  MSPPT8.OLB    PowerPoint    PowerPoint 8.0 Object Library
'Microsoft Office     97  MSO97.DLL     Office        Office 8.0 Object Library
'Microsoft Outlook    97  MSOUTL8.OLB   Outlook       Outlook 8.0 Object Library
'Microsoft Outlook    98  MSOUTL85.OLB  Outlook       Outlook 98 - Objekt Modell
'Microsoft Word       97  MSWORD8.OLB   Word          Word 8.0 Object Library
   
    Dim obj As Object
    
    On Error Resume Next

    IsOffice97PgmLoad = False
    Set obj = GetObject(, Programm & ".Application.8")  ' nach "Programm" suchen
    IsOffice97PgmLoad = (err.Number = 0)
    Set obj = Nothing
    
End Function


Function ControlExist(obj As Object, tstname As String) As Boolean
'Abgewandelte Funktion aus der Access-Hilfe
'Kobd@gmx.de
    Dim ctl As control
    ControlExist = False

    ' Controls-Auflistung durchlaufen.
    For Each ctl In obj.Controls
        ' Prüfen, ob das Steuerelement ein Textfeld ist.
        If ctl.Name = tstname Then
            ControlExist = True
            Exit Function
        End If
    Next ctl
End Function


Function table_exist(TableName As String) As Boolean
'**********************************************************************************
'Function Table_Exist()
'Prüft, ob die Tabelle in der MDB vorhanden ist
'auch für eingebundene Tabellen oder Queries
'
'Rückgabe: TRUE, tbl ist vorhanden oder eingebunden
'          FALSE, tbl ist nicht vorhanden
'**********************************************************************************

Dim db As DAO.Database
Dim tbl As DAO.Recordset
Dim nix

On Error GoTo table_exist_error

    Set db = CurrentDb
    Set tbl = db.OpenRecordset(TableName)
    table_exist = True
    Set tbl = Nothing
    Exit Function

table_exist_error:
    table_exist = False
    Set tbl = Nothing
    Exit Function

End Function


'**********************************************************************************
'Function File_Exist ()
'
'   Überprüft, ob die Datei vorhanden ist
'   Rückgabe:  True, Datei vorhanden
'              False, Datei nicht vorhanden
'**********************************************************************************
Function File_exist(ByVal sFile As String) As Boolean

  Dim Size As Long
  On Error Resume Next
  Size = fileLen(sFile)
  File_exist = (err = 0)
  On Error GoTo 0

'
'Dim F
'
'F = FreeFile
'On Error GoTo File_existError
'Open file For Input Access Read As #F
'Close #F
'File_exist = True
'Exit Function
'
'File_existError:
'File_exist = False
'Exit Function
'
End Function


'**********************************************************************************
'Function Dir_Exist ()
'
'   Überprüft, ob das Directory vorhanden ist
'   Rückgabe:  True, Directory vorhanden
'              False, Directory nicht vorhanden
'   Autor: Thomas Schremser
'**********************************************************************************
Function Dir_Exist(ByVal pPfad As String) As Boolean
   On Error Resume Next
   Dir_Exist = GetAttr(pPfad) And vbDirectory
End Function


Function RecordsExist(RecSourceName As String, Optional XMdb As String) As Boolean

' Abgewandeltes Beispiel aus AUTO97.HLP
' Enthält der RecordSet Daten ?
'Determining if a RecordSet Contains Any Records
'
'This example demonstrates how to determine if a RecordSet contains any records.
'The function accepts a string argument as the name of a table, query, or
'SQL statement to open a RecordSet with.  Then, the function examines the BOF
'and EOF properties to determine if any records exist.  The function returns a
'True value if records exist, and a False value if no records exist.

    Dim ws As DAO.Workspace
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim OpenOwn As Boolean
    
    On Error Resume Next
    OpenOwn = False
    
    If Len(Trim(Nz(XMdb))) = 0 Then     ' 0 = Eigene MDB verwenden
        Set db = CurrentDb
        OpenOwn = True
    Else
        If File_exist(XMdb) Then    ' Function aus mdlSonstiges
            Set ws = DBEngine(0)
            Set db = ws.OpenDatabase(XMdb)
        Else
            MsgBox "Die Datenbank existiert nicht", vbCritical, "Falsche Übergabe"
            Exit Function
        End If
    End If
    
    On Error GoTo Err_RecordsExist
    
    Set rs = db.OpenRecordset(RecSourceName, dbOpenDynaset)
    RecordsExist = Not ((rs.BOF) And (rs.EOF))
    rs.Close
    If Not OpenOwn Then
        Set ws = Nothing
        db.Close
    End If

Exit_RecordsExist:
    Exit Function

Err_RecordsExist:
    If err.Number = "3078" Then       ' - Recordset nicht gefunden
        MsgBox "Der Recordset existiert nicht", vbCritical, "Falsche Übergabe"
    Else
        MsgBox "Unerwartete Reaktion des Programms, " & err.Number, vbCritical, "Falsche Übergabe"
    End If
    GoTo Exit_RecordsExist

End Function


Function ObjectExists(strObjectType As String, strObjectName As String) As Boolean
' Pass the Object type: Table, Query, Form, Report, Macro, or Module
' Pass the Object Name
     Dim db As DAO.Database
     Dim tbl As DAO.TableDef
     Dim QRY As DAO.QueryDef
     Dim i As Integer
     
     Set db = CurrentDb()
     ObjectExists = False
     
     If strObjectType = "Table" Then
          For Each tbl In db.TableDefs
               If tbl.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next tbl
     ElseIf strObjectType = "Query" Then
          For Each QRY In db.QueryDefs
               If QRY.Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next QRY
     ElseIf strObjectType = "Form" Or strObjectType = "Report" Or strObjectType = "Module" Then
          For i = 0 To db.Containers(strObjectType & "s").Documents.Count - 1
               If db.Containers(strObjectType & "s").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     ElseIf strObjectType = "Macro" Then
          For i = 0 To db.Containers("Scripts").Documents.Count - 1
               If db.Containers("Scripts").Documents(i).Name = strObjectName Then
                    ObjectExists = True
                    Set db = Nothing
                    Exit Function
               End If
          Next i
     Else
          MsgBox "Invalid Object Type passed, must be Table, Query, Form, Report, Macro, or Module"
     End If

Set db = Nothing
     
End Function


'**********************************************************************************'
'Function File_Lock ()
'
'   Überprüft, ob die Datei zum schreiben geöffnet werden kann
'   Rückgabe: True, Datei kann zum schreiben geöffnet werden
'             False, Datei kann nicht zum schreiben geöffnet werden
'**********************************************************************************
Function File_Lock(ByVal file As String) As Integer
Dim f

f = FreeFile
On Error GoTo File_lockError
Open file For Append Access Write Lock Read Write As #f
Close #f
File_Lock = False
Exit Function

File_lockError:
File_Lock = True
Exit Function

End Function

Public Function Check_Email_Adress(sEMailAdr As String) As Boolean
'Autor:  Matthias Zirngibl
'Beschreibung
'Dieser Tipp prüft eine EMail-Adresse auf Gütligkeit.
'Zunächst wird geprüft, ob das @-Zeichen und mindestens 1 Punkt
'vorhanden sind. Dann wird geprüft, ob es sich bei der angegebenen
'TopLevel-Domain um eine gültige Domain handelt (z.B. de, com, at, org).
'Ist die Domain in der Liste vorhanden, handelt es sich zumindest der
'Syntax nach um eine gültige EMail-Adresse.

'Prüft eine EMail-Adresse auf Gültigkeit
    
  Dim bGoodAdress As Boolean
  Dim sTopLevelDomainsArray() As String
  Dim sTopLevelDomains As String
  Dim eMailSplices() As String
  Dim i As Long
    
  bGoodAdress = False
  sEMailAdr = LCase(sEMailAdr)
    
  sTopLevelDomains = "com,net,edu,arpa,org,gov,museum," + _
    "biz,info,pro,name,aero,coop,ac,ad,ae,af,ag,ai,al," + _
    "am,an,ao,aq,ar,as,at,au,aw,az,ba,bb,bd,be,bf,bg," + _
    "bh,bi,bj,bm,bn,bo,br,bs,bt,bv,bw,by,bz,ca,cc,cd," + _
    "cf,cg,ch,ci,ck,cl,cm,cn,co,cr,cu,cv,cx,cy,cz,de," + _
    "dj,dk,dm,do,dz,ec,ee,eg,eh,er,es,et,fi,fj,fk,fm," + _
    "fo,fr,ga,gd,ge,gf,gg,gh,gi,gl,gm,gn,gp,gq,gr,gs," + _
    "gt,gu,gw,gy,hk,hm,hn,hr,ht,hu,id,ie,il,im,in,io," + _
    "iq,ir,is,it,je,jm,jo,jp,ke,kg,kh,ki,km,kn,kp,kr," + _
    "kw,ky,kz,la,lb,lc,li,lk,lr,ls,lt,lu,lv,ly,ma,mc," + _
    "md,mg,mh,mk,ml,mm,mn,mo,mp,mq,mr,ms,mt,mu,mv,mw," + _
    "mx,my,mz,na,nc,ne,nf,ng,ni,nl,no,np,nr,nu,nz,om," + _
    "pa,pe,pf,pg,ph,pk,pl,pm,pn,pr,ps,pt,pw,py,qa,re," + _
    "ro,ru,rw,sa,sb,sc,sd,se,sg,sh,si,sj,sk,sl,sm,sn," + _
    "so,sr,st,sv,sy,sz,tc,td,tf,tg,th,tj,tk,tm,tn,to," + _
    "tp,tr,tt,tv,tw,tz,ua,ug,uk,um,us,uy,uz,va,vc,ve," + _
    "vg,vi,vn,vu,wf,ws,ye,yt,yu,za,zm,zr,zw"
  
  sTopLevelDomainsArray = Split(sTopLevelDomains, ",")

  '@-Zeichen prüfen
  eMailSplices = Split(sEMailAdr, "@")
  If UBound(eMailSplices) <> 1 Then
    Check_Email_Adress = False
    Exit Function
  End If

  '. prüfen
  eMailSplices = Split(eMailSplices(1), ".")
  If UBound(eMailSplices) < 1 Then
    Check_Email_Adress = False
    Exit Function
  End If

  'TopLevel-Domain prüfen
  For i = 0 To UBound(sTopLevelDomainsArray)
    If eMailSplices(UBound(eMailSplices)) = _
     sTopLevelDomainsArray(i) Then
      bGoodAdress = True
      Exit For
    End If
  Next
  
  Check_Email_Adress = bGoodAdress
End Function
 
Function IsDateBetween2Dates(VglDate As Date, StartDate As Date, EndDate As Date) As Boolean

Dim strSQL As String
Dim i As Long

strSQL = ""
strSQL = "SELECT Count([_tblAlleTage].[dtDatum]) AS AnzDatum FROM [_tblAlleTage] WHERE dtDatum Between " & SQLDatum(StartDate) & " AND " & SQLDatum(EndDate) & " AND dtdatum = " & SQLDatum(VglDate)

i = Nz(rstDLookUp("AnzDatum", strSQL), 0) * -1
IsDateBetween2Dates = i
End Function

Function Test_IsDateBetween2Dates()
Dim dtVgl As Date
Dim dtStart As Date
Dim dtend As Date

dtStart = DateSerial(2015, 2, 1)
dtend = DateSerial(2015, 2, 28)

dtVgl = DateSerial(2015, 2, 15)

Debug.Print IsDateBetween2Dates(dtVgl, dtStart, dtend)

dtVgl = DateSerial(2015, 3, 1)

Debug.Print IsDateBetween2Dates(dtVgl, dtStart, dtend)

End Function