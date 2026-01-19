Attribute VB_Name = "mdl_N_PositionsVorlagen"
Option Compare Database
Option Explicit

' Modul fuer Positionslisten-Vorlagen und Kopieren

' FEATURE 4: Kopiert Positionen von einem Objekt zu einem anderen
Public Sub KopierePositionen(lngQuellObjektID As Long, lngZielObjektID As Long, Optional blnLoescheZiel As Boolean = False)
    On Error GoTo ErrHandler
    
    If lngQuellObjektID = 0 Or lngZielObjektID = 0 Then
        MsgBox "Quell- und Ziel-Objekt muessen angegeben werden!", vbExclamation
        Exit Sub
    End If
    
    If lngQuellObjektID = lngZielObjektID Then
        MsgBox "Quell- und Ziel-Objekt duerfen nicht identisch sein!", vbExclamation
        Exit Sub
    End If
    
    Dim db As DAO.Database
    Set db = CurrentDb
    
    ' Optional: Bestehende Positionen im Ziel loeschen
    If blnLoescheZiel Then
        db.Execute "DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngZielObjektID
    End If
    
    ' Positionen kopieren
    Dim strSQL As String
    strSQL = "INSERT INTO tbl_OB_Objekt_Positionen " & _
             "(OB_Objekt_Kopf_ID, PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort) " & _
             "SELECT " & lngZielObjektID & ", PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort " & _
             "FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngQuellObjektID
    db.Execute strSQL
    
    MsgBox db.RecordsAffected & " Positionen erfolgreich kopiert!", vbInformation
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler beim Kopieren: " & Err.description, vbCritical
End Sub

' Dialog zum Kopieren von Positionen
Public Sub KopierePositionenDialog(lngAktuellesObjektID As Long)
    On Error GoTo ErrHandler
    
    If lngAktuellesObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    ' Oeffne Auswahl-Formular
    DoCmd.OpenForm "frm_N_PositionenKopieren", , , , , acDialog, lngAktuellesObjektID
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

' FEATURE 5: Speichert aktuelle Positionen als Vorlage
Public Sub SpeichereAlsVorlage(lngObjektID As Long)
    On Error GoTo ErrHandler
    
    If lngObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    Dim strVorlageName As String
    strVorlageName = InputBox("Bitte geben Sie einen Namen fuer die Vorlage ein:", "Vorlage speichern")
    
    If strVorlageName = "" Then Exit Sub
    
    Dim db As DAO.Database
    Dim lngVorlageID As Long
    Set db = CurrentDb
    
    ' Pruefe ob Vorlagen-Tabelle existiert
    On Error Resume Next
    db.Execute "SELECT TOP 1 * FROM tbl_N_Positions_Vorlagen"
    If Err.Number <> 0 Then
        Err.clear
        ' Tabelle erstellen
        db.Execute "CREATE TABLE tbl_N_Positions_Vorlagen (ID AUTOINCREMENT PRIMARY KEY, VorlageName TEXT(100), ErstelltAm DATETIME, ErstelltVon TEXT(50))"
        db.Execute "CREATE TABLE tbl_N_Positions_Vorlagen_Details (ID AUTOINCREMENT PRIMARY KEY, Vorlage_ID LONG, PosNr INTEGER, Gruppe TEXT(100), Zusatztext TEXT(255), Zeit1 INTEGER, Zeit2 INTEGER, Zeit3 INTEGER, Zeit4 INTEGER, Sort INTEGER)"
    End If
    On Error GoTo ErrHandler
    
    ' Vorlage-Kopf erstellen
    db.Execute "INSERT INTO tbl_N_Positions_Vorlagen (VorlageName, ErstelltAm, ErstelltVon) VALUES (" & _
               "'" & strVorlageName & "', Now(), '" & Environ("USERNAME") & "')"
    lngVorlageID = DMax("ID", "tbl_N_Positions_Vorlagen")
    
    ' Positionen kopieren
    db.Execute "INSERT INTO tbl_N_Positions_Vorlagen_Details " & _
               "(Vorlage_ID, PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort) " & _
               "SELECT " & lngVorlageID & ", PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort " & _
               "FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngObjektID
    
    MsgBox "Vorlage '" & strVorlageName & "' mit " & db.RecordsAffected & " Positionen gespeichert!", vbInformation
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler beim Speichern: " & Err.description, vbCritical
End Sub

' Laedt eine Vorlage in ein Objekt
Public Sub LadeVorlage(lngVorlageID As Long, lngZielObjektID As Long, Optional blnLoescheZiel As Boolean = True)
    On Error GoTo ErrHandler
    
    If lngVorlageID = 0 Or lngZielObjektID = 0 Then
        MsgBox "Vorlage und Ziel-Objekt muessen angegeben werden!", vbExclamation
        Exit Sub
    End If
    
    Dim db As DAO.Database
    Set db = CurrentDb
    
    If blnLoescheZiel Then
        db.Execute "DELETE FROM tbl_OB_Objekt_Positionen WHERE OB_Objekt_Kopf_ID = " & lngZielObjektID
    End If
    
    db.Execute "INSERT INTO tbl_OB_Objekt_Positionen " & _
               "(OB_Objekt_Kopf_ID, PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort) " & _
               "SELECT " & lngZielObjektID & ", PosNr, Gruppe, Zusatztext, Zeit1, Zeit2, Zeit3, Zeit4, Sort " & _
               "FROM tbl_N_Positions_Vorlagen_Details WHERE Vorlage_ID = " & lngVorlageID
    
    MsgBox db.RecordsAffected & " Positionen aus Vorlage geladen!", vbInformation
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler beim Laden: " & Err.description, vbCritical
End Sub

' Dialog zum Laden einer Vorlage
Public Sub LadeVorlageDialog(lngZielObjektID As Long)
    On Error GoTo ErrHandler
    
    If lngZielObjektID = 0 Then
        MsgBox "Bitte erst ein Objekt auswaehlen!", vbExclamation
        Exit Sub
    End If
    
    DoCmd.OpenForm "frm_N_VorlageAuswahl", , , , , acDialog, lngZielObjektID
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler: " & Err.description, vbCritical
End Sub

' Loescht eine Vorlage
Public Sub LoescheVorlage(lngVorlageID As Long)
    On Error GoTo ErrHandler
    
    If MsgBox("Moechten Sie diese Vorlage wirklich loeschen?", vbYesNo + vbQuestion) = vbNo Then Exit Sub
    
    Dim db As DAO.Database
    Set db = CurrentDb
    
    db.Execute "DELETE FROM tbl_N_Positions_Vorlagen_Details WHERE Vorlage_ID = " & lngVorlageID
    db.Execute "DELETE FROM tbl_N_Positions_Vorlagen WHERE ID = " & lngVorlageID
    
    MsgBox "Vorlage geloescht!", vbInformation
    Exit Sub
    
ErrHandler:
    MsgBox "Fehler beim Loeschen: " & Err.description, vbCritical
End Sub



' FEATURE 3: Erweiterte Sortier-Funktionen

' Verschiebt eine Position nach oben (kleinerer Sort-Wert)
Public Sub MovePositionUp(lngPositionID As Long)
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngObjektID As Long
    Dim lngCurrentSort As Long
    Dim lngPrevID As Long
    Dim lngPrevSort As Long
    
    Set db = CurrentDb
    
    ' Hole aktuelle Position
    lngObjektID = Nz(DLookup("OB_Objekt_Kopf_ID", "tbl_OB_Objekt_Positionen", "ID = " & lngPositionID), 0)
    lngCurrentSort = Nz(DLookup("Sort", "tbl_OB_Objekt_Positionen", "ID = " & lngPositionID), 0)
    
    ' Finde vorherige Position
    Set rs = db.OpenRecordset("SELECT TOP 1 ID, Sort FROM tbl_OB_Objekt_Positionen " & _
        "WHERE OB_Objekt_Kopf_ID = " & lngObjektID & " AND Sort < " & lngCurrentSort & _
        " ORDER BY Sort DESC")
    
    If Not rs.EOF Then
        lngPrevID = rs!ID
        lngPrevSort = rs!Sort
        rs.Close
        
        ' Tausche Sort-Werte
        db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & lngPrevSort & " WHERE ID = " & lngPositionID
        db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & lngCurrentSort & " WHERE ID = " & lngPrevID
    End If
    Exit Sub
    
ErrHandler:
    ' Fehler ignorieren
End Sub

' Verschiebt eine Position nach unten (groesserer Sort-Wert)
Public Sub MovePositionDown(lngPositionID As Long)
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngObjektID As Long
    Dim lngCurrentSort As Long
    Dim lngNextID As Long
    Dim lngNextSort As Long
    
    Set db = CurrentDb
    
    ' Hole aktuelle Position
    lngObjektID = Nz(DLookup("OB_Objekt_Kopf_ID", "tbl_OB_Objekt_Positionen", "ID = " & lngPositionID), 0)
    lngCurrentSort = Nz(DLookup("Sort", "tbl_OB_Objekt_Positionen", "ID = " & lngPositionID), 0)
    
    ' Finde naechste Position
    Set rs = db.OpenRecordset("SELECT TOP 1 ID, Sort FROM tbl_OB_Objekt_Positionen " & _
        "WHERE OB_Objekt_Kopf_ID = " & lngObjektID & " AND Sort > " & lngCurrentSort & _
        " ORDER BY Sort ASC")
    
    If Not rs.EOF Then
        lngNextID = rs!ID
        lngNextSort = rs!Sort
        rs.Close
        
        ' Tausche Sort-Werte
        db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & lngNextSort & " WHERE ID = " & lngPositionID
        db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & lngCurrentSort & " WHERE ID = " & lngNextID
    End If
    Exit Sub
    
ErrHandler:
    ' Fehler ignorieren
End Sub

' Nummeriert alle Positionen eines Objekts neu durch
Public Sub RenumberPositions(lngObjektID As Long)
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngSort As Long
    
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT ID FROM tbl_OB_Objekt_Positionen " & _
        "WHERE OB_Objekt_Kopf_ID = " & lngObjektID & " ORDER BY Sort, PosNr")
    
    lngSort = 1
    Do While Not rs.EOF
        db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & lngSort & ", PosNr = " & lngSort & " WHERE ID = " & rs!ID
        lngSort = lngSort + 1
        rs.MoveNext
    Loop
    rs.Close
    Exit Sub
    
ErrHandler:
    ' Fehler ignorieren
End Sub

' Verschiebt Position an eine bestimmte Stelle
Public Sub MovePositionTo(lngPositionID As Long, lngNeuePosition As Long)
    On Error GoTo ErrHandler
    
    Dim db As DAO.Database
    Dim lngObjektID As Long
    
    Set db = CurrentDb
    lngObjektID = Nz(DLookup("OB_Objekt_Kopf_ID", "tbl_OB_Objekt_Positionen", "ID = " & lngPositionID), 0)
    
    ' Setze temporaer auf hohen Wert
    db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = 99999 WHERE ID = " & lngPositionID
    
    ' Verschiebe alle anderen
    db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = Sort + 1 " & _
        "WHERE OB_Objekt_Kopf_ID = " & lngObjektID & " AND Sort >= " & lngNeuePosition & " AND ID <> " & lngPositionID
    
    ' Setze neue Position
    db.Execute "UPDATE tbl_OB_Objekt_Positionen SET Sort = " & lngNeuePosition & " WHERE ID = " & lngPositionID
    
    ' Neu durchnummerieren
    RenumberPositions lngObjektID
    Exit Sub
    
ErrHandler:
    ' Fehler ignorieren
End Sub

