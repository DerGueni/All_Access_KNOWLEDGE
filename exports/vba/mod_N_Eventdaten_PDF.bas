Attribute VB_Name = "mod_N_Eventdaten_PDF"
'=========================================================================
' Modul: mod_N_EventDaten_PDF
' Beschreibung: PDF-Erstellung und E-Mail-Anhang für Eventdaten
' Erstellt: 2026-01-03
' Autor: Claude Code
'
' FUNKTIONEN:
' - pdf_erstellen_eventdaten: Erstellt PDF aus Eventdaten für VA
' - hat_eventdaten: Prüft ob Eventdaten für VA vorhanden
' - erweitere_attachments: Fügt Eventdaten-PDF zu Attachment-Array hinzu
' - cleanup_temp_pdf: Löscht temporäre PDF-Dateien
'
' INTEGRATION:
' In der Autosend-Funktion von frm_MA_Serien_eMail_Auftrag:
'   myattach = erweitere_attachments(myattach, VA_ID)
'=========================================================================

' Temporärer Pfad für PDFs
Private Const TEMP_PDF_PREFIX As String = "EventDaten_"

'=========================================================================
' Prüft ob Eventdaten für eine VA vorhanden sind
'=========================================================================
Public Function hat_eventdaten(VA_ID As Long) As Boolean
    On Error Resume Next

    Dim cnt As Long
    cnt = DCount("*", "tbl_N_VA_EventDaten", "VA_ID = " & VA_ID & " AND Erfolgreich = True")

    hat_eventdaten = (cnt > 0)
End Function

'=========================================================================
' Erstellt PDF mit Eventdaten für eine Veranstaltung
' Rückgabe: Voller Pfad zur PDF-Datei oder "" wenn keine Daten
'=========================================================================
Public Function pdf_erstellen_eventdaten(VA_ID As Long) As String
    On Error GoTo Err_Handler

    Dim PDF_Datei As String
    Dim Auftrag As String
    Dim Objekt As String
    Dim VADatum As String

    ' Prüfen ob Eventdaten vorhanden
    If Not hat_eventdaten(VA_ID) Then
        pdf_erstellen_eventdaten = ""
        Exit Function
    End If

    ' Auftragsdaten für Dateinamen holen
    Auftrag = Nz(DLookup("Auftrag", "tbl_VA_Auftragstamm", "ID = " & VA_ID), "Auftrag")
    Objekt = Nz(DLookup("Objekt", "tbl_VA_Auftragstamm", "ID = " & VA_ID), "")
    VADatum = Format(Nz(DLookup("Dat_VA_Von", "tbl_VA_Auftragstamm", "ID = " & VA_ID), Date), "YYYY-MM-DD")

    ' Ungültige Zeichen aus Dateinamen entfernen
    Auftrag = bereinige_dateiname(Auftrag)
    Objekt = bereinige_dateiname(Objekt)

    ' PDF-Pfad erstellen (Temp-Verzeichnis)
    PDF_Datei = Environ("TEMP") & "\" & TEMP_PDF_PREFIX & VA_ID & "_" & Auftrag & "_" & VADatum & ".pdf"

    ' Alte Datei löschen falls vorhanden
    If Dir(PDF_Datei) <> "" Then Kill PDF_Datei

    ' Report-Filter setzen
    Call Set_Priv_Property("prp_EventDaten_VA_ID", VA_ID)

    ' Report als PDF exportieren
    DoCmd.OutputTo acOutputReport, "rpt_N_EventDaten", acFormatPDF, PDF_Datei, False

    ' Prüfen ob Datei erstellt wurde
    If Dir(PDF_Datei) <> "" Then
        pdf_erstellen_eventdaten = PDF_Datei
    Else
        pdf_erstellen_eventdaten = ""
    End If

    Exit Function

Err_Handler:
    Debug.Print "Fehler in pdf_erstellen_eventdaten: " & Err.Number & " - " & Err.description
    pdf_erstellen_eventdaten = ""
End Function

'=========================================================================
' Bereinigt Dateinamen von ungültigen Zeichen
'=========================================================================
Private Function bereinige_dateiname(ByVal strName As String) As String
    Dim i As Integer
    Dim strResult As String
    Dim strChar As String
    Const UNGUELTIG As String = "\/:*?""<>|"

    strResult = strName

    For i = 1 To Len(UNGUELTIG)
        strChar = Mid(UNGUELTIG, i, 1)
        strResult = Replace(strResult, strChar, "_")
    Next i

    ' Leerzeichen durch Unterstrich ersetzen
    strResult = Replace(strResult, " ", "_")

    ' Maximale Länge begrenzen
    If Len(strResult) > 50 Then
        strResult = Left(strResult, 50)
    End If

    bereinige_dateiname = strResult
End Function

'=========================================================================
' Erweitert bestehendes Attachment-Array um Eventdaten-PDF
' Verwendung: myattach = erweitere_attachments(myattach, VA_ID)
'=========================================================================
Public Function erweitere_attachments(ByVal bestehendeAttachments As Variant, VA_ID As Long) As Variant
    On Error GoTo Err_Handler

    Dim EventDaten_PDF As String
    Dim neueAttachments() As Variant
    Dim i As Long
    Dim neueGroesse As Long

    ' Eventdaten-PDF erstellen
    EventDaten_PDF = pdf_erstellen_eventdaten(VA_ID)

    ' Wenn keine Eventdaten, Original zurückgeben
    If EventDaten_PDF = "" Then
        erweitere_attachments = bestehendeAttachments
        Exit Function
    End If

    ' Prüfen ob bestehende Attachments vorhanden
    If IsEmpty(bestehendeAttachments) Or IsNull(bestehendeAttachments) Then
        ' Nur Eventdaten-PDF
        erweitere_attachments = Array(EventDaten_PDF)
        Exit Function
    End If

    If Not IsArray(bestehendeAttachments) Then
        ' Einzelner String -> Array mit 2 Elementen
        erweitere_attachments = Array(CStr(bestehendeAttachments), EventDaten_PDF)
        Exit Function
    End If

    ' Array erweitern
    neueGroesse = UBound(bestehendeAttachments) - LBound(bestehendeAttachments) + 2
    ReDim neueAttachments(0 To neueGroesse - 1)

    ' Bestehende kopieren
    For i = LBound(bestehendeAttachments) To UBound(bestehendeAttachments)
        neueAttachments(i - LBound(bestehendeAttachments)) = bestehendeAttachments(i)
    Next i

    ' Eventdaten-PDF anhängen
    neueAttachments(neueGroesse - 1) = EventDaten_PDF

    erweitere_attachments = neueAttachments
    Exit Function

Err_Handler:
    Debug.Print "Fehler in erweitere_attachments: " & Err.Number & " - " & Err.description
    erweitere_attachments = bestehendeAttachments
End Function

'=========================================================================
' Löscht temporäre Eventdaten-PDFs
'=========================================================================
Public Sub cleanup_temp_pdf(Optional VA_ID As Long = 0)
    On Error Resume Next

    Dim strDatei As String
    Dim strPfad As String

    strPfad = Environ("TEMP") & "\"

    If VA_ID > 0 Then
        ' Nur spezifische VA löschen
        strDatei = Dir(strPfad & TEMP_PDF_PREFIX & VA_ID & "_*.pdf")
        Do While strDatei <> ""
            Kill strPfad & strDatei
            strDatei = Dir()
        Loop
    Else
        ' Alle Eventdaten-PDFs löschen
        strDatei = Dir(strPfad & TEMP_PDF_PREFIX & "*.pdf")
        Do While strDatei <> ""
            Kill strPfad & strDatei
            strDatei = Dir()
        Loop
    End If
End Sub



'=========================================================================
' TEST-FUNKTION: Zeigt Eventdaten-PDF für eine VA an
'=========================================================================
Public Sub Test_EventDaten_PDF(VA_ID As Long)
    Dim strPDF As String

    strPDF = pdf_erstellen_eventdaten(VA_ID)

    If strPDF <> "" Then
        MsgBox "PDF erstellt: " & vbCrLf & strPDF, vbInformation
        ' PDF öffnen
        Shell "explorer """ & strPDF & """", vbNormalFocus
    Else
        MsgBox "Keine Eventdaten für VA_ID " & VA_ID & " vorhanden.", vbExclamation
    End If
End Sub

'=========================================================================
' INTEGRATION IN AUTOSEND
'
' In frm_MA_Serien_eMail_Auftrag.Autosend() folgende Zeile einfügen
' NACH der Erstellung des myattach-Arrays und VOR dem Mail-Versand:
'
'   ' Eventdaten-PDF hinzufügen (falls vorhanden)
'   myattach = erweitere_attachments(myattach, VA_ID)
'
' Nach dem Versand:
'   ' Temporäre PDFs löschen
'   Call cleanup_temp_pdf(VA_ID)
'
'=========================================================================
