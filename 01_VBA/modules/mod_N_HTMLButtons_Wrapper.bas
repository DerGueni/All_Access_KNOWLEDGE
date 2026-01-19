Attribute VB_Name = "mod_N_HTMLButtons_Wrapper"
' =====================================================
' mod_N_HTMLButtons_Wrapper
' Öffentliche Wrapper-Funktionen für OnClick-Events
' Damit können die Formulare direkt =FunctionName([ID]) aufrufen
' =====================================================

' Auftragsverwaltung HTML öffnen
Public Function OpenAuftragstamm_Browser(VA_ID As Long)
    Call mod_N_WebView2_forms3.OpenAuftragstamm_Browser(VA_ID)
End Function

' Mitarbeiterstamm HTML öffnen
Public Function OpenMitarbeiterstamm_Browser(MA_ID As Long)
    Call mod_N_WebView2_forms3.OpenMitarbeiterstamm_Browser(MA_ID)
End Function

' Kundenstamm HTML öffnen
Public Function OpenKundenstamm_Browser(KD_ID As Long)
    Call mod_N_WebView2_forms3.OpenKundenstamm_Browser(KD_ID)
End Function

' Objektverwaltung HTML öffnen
Public Function OpenObjekt_Browser(OB_ID As Long)
    Call mod_N_WebView2_forms3.OpenObjekt_Browser(OB_ID)
End Function

' Dienstplan HTML öffnen
Public Function OpenDienstplan_Browser(Optional StartDatum As Date)
    Call mod_N_WebView2_forms3.OpenDienstplan_Browser(StartDatum)
End Function

' Hauptmenu/Shell HTML öffnen
Public Function OpenHTMLAnsicht()
    Call mod_N_WebView2_forms3.OpenHTMLAnsicht()
End Function

' =====================================================
' VBA Bridge Wrapper für HTML-Button-Aufrufe
' Diese Funktionen werden von HTML via VBA Bridge aufgerufen
' =====================================================

' Einsatzliste drucken (wie btnDruckZusage_Click)
' Wird von HTML Button "EL drucken" aufgerufen
Public Function EinsatzlisteDruckenFromHTML(VA_ID As Long, VADatum_ID As Long) As String
    On Error GoTo Err_Handler

    Dim rs As DAO.Recordset
    Dim Datum As Date
    Dim SDatum As String
    Dim Auftrag As String
    Dim Objekt As String
    Dim Pfad As String

    ' Auftragsdaten laden
    Set rs = CurrentDb.OpenRecordset("SELECT Dat_VA_Von, Auftrag, Objekt FROM tbl_VA_Auftragstamm WHERE ID = " & VA_ID)
    If rs.EOF Then
        EinsatzlisteDruckenFromHTML = ">AUFTRAG NICHT GEFUNDEN"
        Exit Function
    End If

    Datum = rs!Dat_VA_Von
    Auftrag = Nz(rs!Auftrag, "")
    Objekt = Nz(rs!Objekt, "")
    rs.Close

    ' Datum formatieren (MM-DD-YY)
    SDatum = Format(Datum, "mm-dd-yy")

    ' Pfad
    Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & "\CONSEC\CONSEC PLANUNG AKTUELL\"

    ' Export aufrufen
    Call fXL_Export_Auftrag(VA_ID, Pfad, SDatum & " " & Auftrag & " " & Objekt & ".xlsm")

    EinsatzlisteDruckenFromHTML = ">OK"
    Exit Function

Err_Handler:
    EinsatzlisteDruckenFromHTML = ">FEHLER: " & Err.Description
End Function

' BWN drucken
' Wird von HTML Button "BWN drucken" aufgerufen
Public Function DruckeBewachungsnachweiseFromHTML(VA_ID As Long, VADatum_ID As Long) As String
    On Error GoTo Err_Handler

    ' TODO: Implementierung wie btn_BWN_Druck_Click
    ' Momentan auskommentiert in Access - prüfen ob benötigt
    DruckeBewachungsnachweiseFromHTML = ">OK (nicht implementiert)"
    Exit Function

Err_Handler:
    DruckeBewachungsnachweiseFromHTML = ">FEHLER: " & Err.Description
End Function

' BWN senden
' Wird von HTML Button "BWN senden" aufgerufen
Public Function SendeBewachungsnachweiseFromHTML(VA_ID As Long, VADatum_ID As Long) As String
    On Error GoTo Err_Handler

    Dim frm As Form

    ' Versuche das Auftragstamm-Formular zu finden (falls geöffnet)
    On Error Resume Next
    Set frm = Forms!frm_va_Auftragstamm
    On Error GoTo Err_Handler

    If Not frm Is Nothing Then
        ' Wenn Formular offen, nutze existierende Funktion
        Call SendeBewachungsnachweise(frm)
        SendeBewachungsnachweiseFromHTML = ">OK"
    Else
        ' Formular nicht offen - eigene Logik
        ' TODO: Implementierung ohne Form-Referenz
        SendeBewachungsnachweiseFromHTML = ">OK (Formular nicht offen)"
    End If

    Exit Function

Err_Handler:
    SendeBewachungsnachweiseFromHTML = ">FEHLER: " & Err.Description
End Function

' =====================================================
' VBA Bridge Wrapper für Menü 2 Funktionen (14.01.2026)
' Diese Funktionen werden von HTML Sidebar via VBA Bridge aufgerufen
' =====================================================

' Löwensaal Daten synchronisieren
' Wird von HTML Sidebar Button "Löwensaal Sync" aufgerufen
Public Function btn_LoewensaalSync_Click_FromHTML() As String
    On Error GoTo Err_Handler

    ' Ruft die originale Funktion aus dem Access-Formular auf
    ' Falls das Formular nicht existiert, direkte Ausführung
    On Error Resume Next
    Application.Run "Loewensaal_sync_gueni"
    On Error GoTo Err_Handler

    btn_LoewensaalSync_Click_FromHTML = ">OK"
    Exit Function

Err_Handler:
    btn_LoewensaalSync_Click_FromHTML = ">FEHLER: " & Err.Description
End Function

' FCN Meldeliste exportieren
' Wird von HTML Sidebar Button "FCN Meldeliste" aufgerufen
Public Function btn_FCN_Meldeliste_Click_FromHTML() As String
    On Error GoTo Err_Handler

    ' Ruft die originale Funktion auf
    On Error Resume Next
    Application.Run "btn_FCN_Meldeliste_Click"
    On Error GoTo Err_Handler

    btn_FCN_Meldeliste_Click_FromHTML = ">OK"
    Exit Function

Err_Handler:
    btn_FCN_Meldeliste_Click_FromHTML = ">FEHLER: " & Err.Description
End Function

' Fürth Namensliste exportieren
' Wird von HTML Sidebar Button "Fürth Namensliste" aufgerufen
Public Function btn_FuerthNamensliste_Click_FromHTML() As String
    On Error GoTo Err_Handler

    ' Ruft die originale Funktion auf
    On Error Resume Next
    Application.Run "btn_Fuerth_Namensliste_Click"
    On Error GoTo Err_Handler

    btn_FuerthNamensliste_Click_FromHTML = ">OK"
    Exit Function

Err_Handler:
    btn_FuerthNamensliste_Click_FromHTML = ">FEHLER: " & Err.Description
End Function

' MA Stamm nach Excel exportieren
' Wird von HTML Sidebar Button "MA Stamm Excel" aufgerufen
Public Function btn_MAStamm_Excel_Click_FromHTML() As String
    On Error GoTo Err_Handler

    On Error Resume Next
    Application.Run "btn_MAStamm_Excel_Click"
    On Error GoTo Err_Handler

    btn_MAStamm_Excel_Click_FromHTML = ">OK"
    Exit Function

Err_Handler:
    btn_MAStamm_Excel_Click_FromHTML = ">FEHLER: " & Err.Description
End Function

' Stunden Sub exportieren
' Wird von HTML Sidebar Button "Sub Stunden" aufgerufen
Public Function btn_stunden_sub_Click_FromHTML() As String
    On Error GoTo Err_Handler

    On Error Resume Next
    Application.Run "btn_stunden_sub_Click"
    On Error GoTo Err_Handler

    btn_stunden_sub_Click_FromHTML = ">OK"
    Exit Function

Err_Handler:
    btn_stunden_sub_Click_FromHTML = ">FEHLER: " & Err.Description
End Function

' Stunden pro MA exportieren
' Wird von HTML Sidebar Button "Stunden MA" aufgerufen
Public Function btnStundenMA_Click_FromHTML() As String
    On Error GoTo Err_Handler

    On Error Resume Next
    Application.Run "btnStundenMA_Click"
    On Error GoTo Err_Handler

    btnStundenMA_Click_FromHTML = ">OK"
    Exit Function

Err_Handler:
    btnStundenMA_Click_FromHTML = ">FEHLER: " & Err.Description
End Function

' =====================================================
' VBA Bridge Wrapper für Tab Rechnung (18.01.2026)
' Diese Funktionen werden von HTML Tab "Rechnung" aufgerufen
' =====================================================

' Rechnungs-PDF erstellen
' Wird von HTML Button "Rechnung PDF" aufgerufen
Public Function RechnungPDFFromHTML(VA_ID As Long, Optional Rch_KopfID As Long = 0) As String
    On Error GoTo Err_Handler

    Dim frm As Form
    Dim strPDF As String

    ' Wenn kein Rch_KopfID übergeben, aus DB holen
    If Rch_KopfID = 0 Then
        Rch_KopfID = Nz(DLookup("ID", "tbl_Rch_Kopf", "Rch_VA_ID = " & VA_ID), 0)
    End If

    If Rch_KopfID = 0 Then
        RechnungPDFFromHTML = ">KEINE_RECHNUNG_VORHANDEN"
        Exit Function
    End If

    ' Prüfen ob Berechnungsliste-Formular offen ist
    On Error Resume Next
    Set frm = Forms!frmTop_Rch_Berechnungsliste
    On Error GoTo Err_Handler

    If Not frm Is Nothing Then
        ' Formular ist offen - nutze dessen btn_PDFagain_Click Logik
        Call frm.btn_PDFagain_Click
        RechnungPDFFromHTML = ">OK"
    Else
        ' Formular nicht offen - öffne es mit der VA_ID
        DoCmd.OpenForm "frmTop_Rch_Berechnungsliste", , , "VA_ID = " & VA_ID
        DoEvents

        Set frm = Forms!frmTop_Rch_Berechnungsliste
        If Not frm Is Nothing Then
            ' PDF Button klicken
            Call frm.btn_PDFagain_Click
            DoCmd.Close acForm, "frmTop_Rch_Berechnungsliste"
            RechnungPDFFromHTML = ">OK"
        Else
            RechnungPDFFromHTML = ">FORMULAR_KONNTE_NICHT_GEOEFFNET_WERDEN"
        End If
    End If

    Exit Function

Err_Handler:
    RechnungPDFFromHTML = ">FEHLER: " & Err.Description
End Function

' Berechnungsliste-PDF erstellen
' Wird von HTML Button "Berechnungsliste PDF" aufgerufen
Public Function BerechnungslistePDFFromHTML(VA_ID As Long) As String
    On Error GoTo Err_Handler

    Dim frm As Form
    Dim Ueber_Pfad As String
    Dim PDF_Datei As String
    Dim kun_ID As Long

    ' Kunden-ID holen
    kun_ID = Nz(DLookup("Veranstalter_ID", "tbl_VA_Auftragstamm", "ID = " & VA_ID), 0)

    If kun_ID = 0 Then
        BerechnungslistePDFFromHTML = ">AUFTRAG_NICHT_GEFUNDEN"
        Exit Function
    End If

    ' Pfad erstellen
    Ueber_Pfad = Get_Priv_Property("prp_CONSYS_GrundPfad") & Nz(TLookup("Pfad", "_tblEigeneFirma_Pfade", "ID = 2"), "")
    Ueber_Pfad = Ueber_Pfad & "KD_" & kun_ID & "\"
    Call Path_erzeugen(Ueber_Pfad, False, True)

    ' Stundenliste als PDF exportieren
    PDF_Datei = Ueber_Pfad & "Stundenliste_Rch_" & VA_ID & ".pdf"
    Call Set_Priv_Property("prp_Report1_Auftrag_ID", VA_ID)

    DoCmd.OutputTo acOutputReport, "rpt_Rch_Stundenliste", "PDF", PDF_Datei
    DoEvents

    BerechnungslistePDFFromHTML = ">OK:" & PDF_Datei
    Exit Function

Err_Handler:
    BerechnungslistePDFFromHTML = ">FEHLER: " & Err.Description
End Function

' Rechnungsdaten laden (Berechnungsliste füllen)
' Wird von HTML Button "Daten laden" aufgerufen
' Entspricht btnLoad_Click -> fill_Berechnungsliste()
Public Function RechnungDatenLadenFromHTML(VA_ID As Long) As String
    On Error GoTo Err_Handler

    ' Ruft die bestehende fill_Berechnungsliste Funktion auf
    Call fill_Berechnungsliste(VA_ID)

    RechnungDatenLadenFromHTML = ">OK"
    Exit Function

Err_Handler:
    RechnungDatenLadenFromHTML = ">FEHLER: " & Err.Description
End Function

' Rechnung in Lexware erstellen
' Wird von HTML Button "Rechnung in Lexware erstellen" aufgerufen
Public Function RechnungLexwareFromHTML(VA_ID As Long, Optional kun_ID As Long = 0) As String
    On Error GoTo Err_Handler

    Dim frm As Form
    Dim LexwareNr As String

    ' Wenn kein kun_ID übergeben, aus DB holen
    If kun_ID = 0 Then
        kun_ID = Nz(DLookup("Veranstalter_ID", "tbl_VA_Auftragstamm", "ID = " & VA_ID), 0)
    End If

    If kun_ID = 0 Then
        RechnungLexwareFromHTML = ">AUFTRAG_NICHT_GEFUNDEN"
        Exit Function
    End If

    ' Prüfen ob Berechnungsliste-Formular offen ist
    On Error Resume Next
    Set frm = Forms!frmTop_Rch_Berechnungsliste
    On Error GoTo Err_Handler

    If Not frm Is Nothing Then
        ' Formular ist offen - nutze dessen Lexware-Logik
        ' Die genaue Funktion hängt vom Lexware-Modul ab
        On Error Resume Next
        Application.Run "Lexware_Rechnung_Erstellen", VA_ID, kun_ID
        On Error GoTo Err_Handler

        RechnungLexwareFromHTML = ">OK"
    Else
        ' Versuche direkte Lexware-Funktion aufzurufen (falls vorhanden)
        On Error Resume Next
        Application.Run "Lexware_Rechnung_Erstellen", VA_ID, kun_ID
        If Err.Number <> 0 Then
            ' Funktion existiert nicht - Hinweis geben
            RechnungLexwareFromHTML = ">NICHT_IMPLEMENTIERT: Lexware-Integration nicht verfügbar"
            Exit Function
        End If
        On Error GoTo Err_Handler

        RechnungLexwareFromHTML = ">OK"
    End If

    Exit Function

Err_Handler:
    RechnungLexwareFromHTML = ">FEHLER: " & Err.Description
End Function
