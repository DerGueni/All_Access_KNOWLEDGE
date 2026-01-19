Attribute VB_Name = "mdl_N_MA_Verarbeitung"
Option Compare Database
Option Explicit

' =========================================================================
' Modul: mdl_N_MA_Verarbeitung
' Zweck: Automatische Verarbeitung von Bewerberdaten
' =========================================================================

Public Function Verarbeite_Bewerber(lngBewerberID As Long) As Long
    Dim db As DAO.Database
    Dim rsBewerber As DAO.Recordset
    Dim newMA_ID As Long
    Dim strSQL As String
    
    On Error GoTo Err_Handler
    
    Set db = CurrentDb
    strSQL = "SELECT * FROM tbl_N_MA_Bewerberdaten WHERE ID = " & lngBewerberID
    Set rsBewerber = db.OpenRecordset(strSQL, dbOpenDynaset)
    
    If rsBewerber.EOF Then
        MsgBox "Bewerber nicht gefunden!", vbCritical
        GoTo Exit_Func
    End If
    
    If rsBewerber!Verarbeitet = "Ja" And Not IsNull(rsBewerber!MA_ID) Then
        MsgBox "Bewerber bereits verarbeitet! MA-ID: " & rsBewerber!MA_ID, vbInformation
        Verarbeite_Bewerber = rsBewerber!MA_ID
        GoTo Exit_Func
    End If
    
    newMA_ID = Create_Mitarbeiter(rsBewerber)
    
    If newMA_ID = 0 Then
        MsgBox "Fehler beim Anlegen des Mitarbeiters!", vbCritical
        GoTo Exit_Func
    End If
    
    If Not Create_Zeitkonto(newMA_ID, rsBewerber) Then
        MsgBox "Warnung: Zeitkonto konnte nicht erstellt werden", vbExclamation
    End If
    
    If Not Create_DigitaleAkte(newMA_ID, rsBewerber) Then
        MsgBox "Warnung: Digitale Akte konnte nicht erstellt werden", vbExclamation
    End If
    
    rsBewerber.Edit
    rsBewerber!MA_ID = newMA_ID
    rsBewerber!Verarbeitet = "Ja"
    rsBewerber.update
    
    Verarbeite_Bewerber = newMA_ID
    MsgBox "Mitarbeiter erfolgreich angelegt!" & vbCrLf & "MA-ID: " & newMA_ID & vbCrLf & "Name: " & rsBewerber!Vorname & " " & rsBewerber!Nachname, vbInformation, "Erfolg"
    
Exit_Func:
    If Not rsBewerber Is Nothing Then rsBewerber.Close
    Set rsBewerber = Nothing
    Set db = Nothing
    Exit Function
    
Err_Handler:
    MsgBox "Fehler in Verarbeite_Bewerber: " & Err.description, vbCritical
    Verarbeite_Bewerber = 0
    Resume Exit_Func
End Function

Private Function Create_Mitarbeiter(rsBewerber As DAO.Recordset) As Long
    Dim db As DAO.Database
    Dim rsMA As DAO.Recordset
    Dim newID As Long
    
    On Error GoTo Err_Handler
    
    Set db = CurrentDb
    Set rsMA = db.OpenRecordset("tbl_MA_Mitarbeiterstamm", dbOpenDynaset)
    
    rsMA.AddNew
    rsMA!Nachname = rsBewerber!Nachname
    rsMA!Vorname = rsBewerber!Vorname
    rsMA!Strasse = rsBewerber!Strasse
    rsMA!PLZ = rsBewerber!PLZ
    rsMA!Ort = rsBewerber!Ort
    rsMA!Bundesland = rsBewerber!Bundesland
    rsMA!Tel_Mobil = rsBewerber!Tel_Mobil
    rsMA!Tel_Festnetz = rsBewerber!Tel_Festnetz
    rsMA!Email = rsBewerber!Email
    rsMA!Geschlecht = rsBewerber!Geschlecht
    rsMA!Staatsangehoerigkeit = rsBewerber!Staatsangehoerigkeit
    rsMA!Geb_Datum = rsBewerber!Geburtsdatum
    rsMA!Geb_Ort = rsBewerber!Geburtsort
    rsMA!Geb_Name = rsBewerber!Geburtsname
    rsMA!Sozialvers_Nr = rsBewerber!SozialVersNr
    rsMA!Steuer_ID = rsBewerber!SteuerID
    rsMA!Steuerklasse = rsBewerber!Steuerklasse
    rsMA!IBAN = rsBewerber!IBAN
    rsMA!BIC = rsBewerber!BIC
    rsMA!Kontoinhaber = rsBewerber!Kontoinhaber
    rsMA!Krankenkasse = rsBewerber!Krankenkasse
    rsMA!Lohngruppe = rsBewerber!Lohngruppe
    rsMA!Anstellungsart_ID = rsBewerber!Anstellungsart_ID
    rsMA!Eintrittsdatum = rsBewerber!Eintrittsdatum
    rsMA!Fahrerlaubnis = rsBewerber!Fahrerlaubnis
    rsMA!Eigener_PKW = rsBewerber!Eigener_PKW
    rsMA!Aktiv = True
    rsMA!Erst_von = Environ("USERNAME")
    rsMA!Erst_am = Now()
    
    If rsBewerber!Para34a_Unterrichtung = "Ja" Then rsMA!Unterw_Paragraph_34a = True
    If rsBewerber!Para34a_Sachkunde = "Ja" Then rsMA!Sachk_Paragraph_34a = True
    
    rsMA!Arbeitstd_pro_Woche = rsBewerber!Arbeitstage_Woche
    rsMA!Stundenzahl_Monat_max = rsBewerber!Stundenzahl_Monat
    rsMA!RV_Befreiung_beantragt = IIf(rsBewerber!RV_Befreiung = "Ja", True, False)
    rsMA!Brutto_Std = rsBewerber!Brutto_Std
    rsMA!Abrechnung_per_eMail = IIf(rsBewerber!Abrechnung_eMail = "Ja", True, False)
    rsMA!Lichtbild = IIf(rsBewerber!Lichtbild_Vorhanden = "Ja", True, False)
    rsMA!Signatur = rsBewerber!Signatur_Datum
    
    rsMA.update
    newID = rsMA!ID
    rsMA.Close
    Set rsMA = Nothing
    Set db = Nothing
    Create_Mitarbeiter = newID
    Exit Function
    
Err_Handler:
    MsgBox "Fehler in Create_Mitarbeiter: " & Err.description, vbCritical
    Create_Mitarbeiter = 0
End Function

Private Function Create_Zeitkonto(lngMA_ID As Long, rsBewerber As DAO.Recordset) As Boolean
    Dim db As DAO.Database
    Dim rsZK As DAO.Recordset
    Dim dtStart As Date
    
    On Error GoTo Err_Handler
    
    Set db = CurrentDb
    Set rsZK = db.OpenRecordset("tbl_MA_Zeitkonto", dbOpenDynaset)
    dtStart = rsBewerber!Eintrittsdatum
    
    rsZK.AddNew
    rsZK!MA_ID = lngMA_ID
    rsZK!Von_Datum = dtStart
    rsZK!Bis_Datum = DateSerial(Year(dtStart), 12, 31)
    rsZK!Soll_Stunden = 0
    rsZK!Ist_Stunden = 0
    rsZK!Urlaub_Tage_Anspruch = 28
    rsZK!Urlaub_Tage_Genommen = 0
    rsZK!Erstellt_am = Now()
    rsZK!Erstellt_von = Environ("USERNAME")
    rsZK.update
    rsZK.Close
    Set rsZK = Nothing
    Set db = Nothing
    Create_Zeitkonto = True
    Exit Function
    
Err_Handler:
    Create_Zeitkonto = False
End Function

Private Function Create_DigitaleAkte(lngMA_ID As Long, rsBewerber As DAO.Recordset) As Boolean
    Dim fso As Object
    Dim strBaseFolder As String
    Dim strMAFolder As String
    
    On Error GoTo Err_Handler
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    strBaseFolder = "C:\users\guenther.siegert\documents\Mitarbeiterakten\"
    strMAFolder = strBaseFolder & Format(lngMA_ID, "0000") & "_" & rsBewerber!Nachname & "_" & rsBewerber!Vorname
    
    If Not fso.FolderExists(strBaseFolder) Then fso.CreateFolder strBaseFolder
    If Not fso.FolderExists(strMAFolder) Then fso.CreateFolder strMAFolder
    
    fso.CreateFolder strMAFolder & "\Bewerbung"
    fso.CreateFolder strMAFolder & "\Vertraege"
    fso.CreateFolder strMAFolder & "\Nachweise"
    fso.CreateFolder strMAFolder & "\Fotos"
    fso.CreateFolder strMAFolder & "\Dienstausweise"
    fso.CreateFolder strMAFolder & "\Korrespondenz"
    
    If Not IsNull(rsBewerber!Excel_Datei) And rsBewerber!Excel_Datei <> "" Then
        If fso.FileExists(rsBewerber!Excel_Datei) Then fso.CopyFile rsBewerber!Excel_Datei, strMAFolder & "\Bewerbung\"
    End If
    
    Set fso = Nothing
    
    Dim db As DAO.Database
    Dim rsMA As DAO.Recordset
    Set db = CurrentDb
    Set rsMA = db.OpenRecordset("SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = " & lngMA_ID, dbOpenDynaset)
    If Not rsMA.EOF Then
        rsMA.Edit
        rsMA!Akte_Pfad = strMAFolder
        rsMA.update
    End If
    rsMA.Close
    Set rsMA = Nothing
    Set db = Nothing
    Create_DigitaleAkte = True
    Exit Function
    
Err_Handler:
    Create_DigitaleAkte = False
End Function
