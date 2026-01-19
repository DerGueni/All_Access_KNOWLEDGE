# VBA INTEGRATION QUICK START
## frmOff_Outlook_aufrufen

**Ziel:** HTML-Formular in Access WebView2 einbinden und Outlook-Integration herstellen

---

## SCHRITT 1: WEBVIEW2-CONTROL EINBINDEN

1. Access-Formular `frmOff_Outlook_aufrufen` öffnen
2. ActiveX-Control hinzufügen: **Microsoft Edge WebView2 Control**
3. Control benennen: `WebBrowser1`
4. Control-Eigenschaften:
   - Dock: Ausgefüllt
   - Name: `WebBrowser1`

---

## SCHRITT 2: FORM-CODE ERSTELLEN

### A. Form_Load Event
```vba
Private Sub Form_Load()
    Dim htmlPath As String
    htmlPath = CurrentProject.Path & "\04_HTML_Forms\forms3\frmOff_Outlook_aufrufen.html"

    ' Prüfen ob Datei existiert
    If Dir(htmlPath) = "" Then
        MsgBox "HTML-Datei nicht gefunden: " & htmlPath, vbCritical
        Exit Sub
    End If

    ' HTML laden
    Me.WebBrowser1.Navigate "file:///" & Replace(htmlPath, "\", "/")
End Sub
```

### B. MailOpen-Methode (WICHTIG!)
```vba
Public Sub MailOpen(Mode As Integer)
    ' Mode: 1 = Mitarbeiter, 2 = Kunden

    Dim rs As DAO.Recordset
    Dim jsonData As String

    If Mode = 1 Then
        ' Mitarbeiter mit E-Mail laden
        Set rs = CurrentDb.OpenRecordset( _
            "SELECT MA_ID AS ID, MA_Nachname AS Nachname, " & _
            "MA_Vorname AS Vorname, MA_eMail AS Email, " & _
            "Anstellungsart_ID " & _
            "FROM tbl_MA_Mitarbeiterstamm " & _
            "WHERE IstAktiv = True AND MA_eMail Is Not Null " & _
            "ORDER BY MA_Nachname, MA_Vorname")
    Else
        ' Kunden mit E-Mail laden
        Set rs = CurrentDb.OpenRecordset( _
            "SELECT kun_Id AS ID, kun_Firma AS Nachname, " & _
            "'' AS Vorname, kun_eMail AS Email, " & _
            "0 AS Anstellungsart_ID " & _
            "FROM tbl_KD_Kundenstamm " & _
            "WHERE kun_IstAktiv = True AND kun_eMail Is Not Null " & _
            "ORDER BY kun_Firma")
    End If

    ' JSON erstellen (einfache Methode)
    Dim jsonArray As String
    jsonArray = "["

    Do While Not rs.EOF
        If Len(jsonArray) > 1 Then jsonArray = jsonArray & ","

        jsonArray = jsonArray & "{" & _
            """ID"":" & rs!ID & "," & _
            """Nachname"":""" & EscapeJSON(Nz(rs!Nachname, "")) & """," & _
            """Vorname"":""" & EscapeJSON(Nz(rs!Vorname, "")) & """," & _
            """Email"":""" & EscapeJSON(Nz(rs!Email, "")) & """," & _
            """Anstellungsart_ID"":" & Nz(rs!Anstellungsart_ID, 0) & _
            "}"

        rs.MoveNext
    Loop

    jsonArray = jsonArray & "]"
    rs.Close

    ' An HTML senden
    jsonData = "{""mitarbeiter"":" & jsonArray & "}"
    SendToHTML "Bridge.onDataReceived(" & jsonData & ");"
End Sub

Private Function EscapeJSON(txt As String) As String
    ' JSON-Escape für Strings
    EscapeJSON = Replace(txt, "\", "\\")
    EscapeJSON = Replace(EscapeJSON, """", "\""")
    EscapeJSON = Replace(EscapeJSON, vbCrLf, "\n")
    EscapeJSON = Replace(EscapeJSON, vbCr, "\n")
    EscapeJSON = Replace(EscapeJSON, vbLf, "\n")
    EscapeJSON = Replace(EscapeJSON, vbTab, "\t")
End Function

Private Sub SendToHTML(jsCode As String)
    ' JavaScript in HTML ausführen
    On Error Resume Next
    Me.WebBrowser1.Document.parentWindow.execScript jsCode, "JavaScript"
    On Error GoTo 0
End Sub
```

### C. VAOpen-Methode (Excel-Export Anhang)
```vba
Public Sub VAOpen(AttachmentPath As String)
    ' Formular mit Anhang öffnen
    Call MailOpen(1)

    ' Warten bis HTML geladen
    DoEvents
    Sleep 500

    ' Anhang hinzufügen
    Dim jsonData As String
    jsonData = "{""filePath"":""" & Replace(AttachmentPath, "\", "\\") & """}"

    SendToHTML "if(window.handleAttachmentSelected) handleAttachmentSelected(" & jsonData & ");"
End Sub
```

### D. WebView2 Message Handler
```vba
Private Sub WebBrowser1_WebMessageReceived(ByVal sender As Object, ByVal args As Object)
    ' Bridge-Events von HTML empfangen
    Dim message As String
    message = args.WebMessageAsJson

    ' Message parsen und verarbeiten
    On Error Resume Next

    ' Einfaches Parsing (für Produktiv: JSON-Parser verwenden)
    If InStr(message, """type"":""sendEmail""") > 0 Then
        Call HandleSendEmail(message)
    ElseIf InStr(message, """type"":""selectAttachment""") > 0 Then
        Call SelectAttachmentDialog
    ElseIf InStr(message, """type"":""clearAttachments""") > 0 Then
        ' Anhänge leeren
    ElseIf InStr(message, """type"":""loadTemplate""") > 0 Then
        Dim templateName As String
        templateName = ExtractJSON(message, "templateName")
        Call LoadEmailTemplate(templateName)
    ElseIf InStr(message, """type"":""close""") > 0 Then
        DoCmd.Close acForm, Me.Name
    End If

    On Error GoTo 0
End Sub

Private Function ExtractJSON(json As String, key As String) As String
    ' Einfacher JSON-Extraktor (für Produktiv: JSON-Parser verwenden)
    Dim startPos As Long, endPos As Long
    startPos = InStr(json, """" & key & """:""") + Len(key) + 4
    endPos = InStr(startPos, json, """")
    ExtractJSON = Mid(json, startPos, endPos - startPos)
End Function
```

### E. HandleSendEmail (Hauptfunktion)
```vba
Private Sub HandleSendEmail(jsonMessage As String)
    ' E-Mail-Daten aus JSON extrahieren (vereinfacht)
    Dim sendTo As String, cc As String, bcc As String
    Dim subject As String, body As String
    Dim isHTML As Boolean, priority As Integer
    Dim directSend As Boolean

    ' JSON parsen (vereinfacht - für Produktiv: JSON-Parser verwenden)
    sendTo = ExtractJSON(jsonMessage, "to")
    cc = ExtractJSON(jsonMessage, "cc")
    bcc = ExtractJSON(jsonMessage, "bcc")
    subject = ExtractJSON(jsonMessage, "subject")
    body = ExtractJSON(jsonMessage, "body")
    isHTML = (InStr(jsonMessage, """isHTML"":true") > 0)
    directSend = (InStr(jsonMessage, """directSend"":true") > 0)

    ' Priorität extrahieren
    Dim prioStr As String
    prioStr = ExtractJSON(jsonMessage, "priority")
    If IsNumeric(prioStr) Then priority = CInt(prioStr) Else priority = 1

    ' Anhänge extrahieren (Array)
    Dim attachments As Variant
    attachments = ExtractAttachmentsArray(jsonMessage)

    ' CreatePlainMail aufrufen (aus mdlOutlookSendMail)
    On Error GoTo SendError

    Call CreatePlainMail( _
        IstHTML:=IIf(isHTML, -1, 0), _
        Bodytext:=body, _
        Betreff:=subject, _
        SendTo:=sendTo, _
        iImportance:=priority, _
        SendToCC:=cc, _
        SendToBCC:=bcc, _
        myattach:=attachments, _
        IsSend:=directSend _
    )

    ' Erfolgs-Callback an HTML
    SendToHTML "if(window.handleEmailSent) handleEmailSent({success:true});"
    Exit Sub

SendError:
    ' Fehler-Callback an HTML
    Dim errMsg As String
    errMsg = Replace(Err.Description, """", "\""")
    SendToHTML "if(window.handleEmailSent) handleEmailSent({success:false,error:""" & errMsg & """});"
End Sub

Private Function ExtractAttachmentsArray(json As String) As Variant
    ' Anhänge aus JSON extrahieren
    ' Vereinfachte Version - sucht nach "attachments":["pfad1","pfad2"]

    Dim startPos As Long, endPos As Long
    Dim attachStr As String
    Dim attachArray() As String
    Dim i As Integer

    startPos = InStr(json, """attachments"":[")
    If startPos = 0 Then
        ExtractAttachmentsArray = Null
        Exit Function
    End If

    startPos = startPos + 15
    endPos = InStr(startPos, json, "]")
    attachStr = Mid(json, startPos, endPos - startPos)

    ' Einzelne Pfade splitten
    attachStr = Replace(attachStr, """", "")
    If Len(Trim(attachStr)) = 0 Then
        ExtractAttachmentsArray = Null
        Exit Function
    End If

    attachArray = Split(attachStr, ",")

    ' Array bereinigen
    For i = 0 To UBound(attachArray)
        attachArray(i) = Trim(attachArray(i))
    Next i

    ExtractAttachmentsArray = attachArray
End Function
```

### F. SelectAttachmentDialog
```vba
Private Sub SelectAttachmentDialog()
    ' Datei-Dialog öffnen
    Dim fd As Object
    Set fd = Application.FileDialog(msoFileDialogFilePicker)

    fd.Title = "Anhang auswählen"
    fd.AllowMultiSelect = False
    fd.Filters.Clear
    fd.Filters.Add "Alle Dateien", "*.*"
    fd.Filters.Add "PDF Dokumente", "*.pdf"
    fd.Filters.Add "Excel Dateien", "*.xlsx;*.xls"
    fd.Filters.Add "Word Dokumente", "*.docx;*.doc"

    If fd.Show = -1 Then
        Dim filePath As String
        filePath = fd.SelectedItems(1)

        ' An HTML senden
        Dim jsonData As String
        jsonData = "{""filePath"":""" & Replace(filePath, "\", "\\") & """}"
        SendToHTML "if(window.handleAttachmentSelected) handleAttachmentSelected(" & jsonData & ");"
    End If
End Sub
```

### G. LoadEmailTemplate (Optional)
```vba
Private Sub LoadEmailTemplate(templateName As String)
    ' E-Mail-Vorlage laden (falls Tabelle existiert)
    On Error Resume Next

    Dim rs As DAO.Recordset
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT Betreff, MailText, IstHTML " & _
        "FROM tbl_Email_Vorlagen " & _
        "WHERE Vorlagenname = '" & Replace(templateName, "'", "''") & "'")

    If Err.Number <> 0 Or rs.EOF Then
        ' Tabelle existiert nicht oder leer
        Exit Sub
    End If

    Dim subject As String, body As String, isHTML As String
    subject = EscapeJSON(Nz(rs!Betreff, ""))
    body = EscapeJSON(Nz(rs!MailText, ""))
    isHTML = IIf(Nz(rs!IstHTML, False), "true", "false")

    rs.Close

    ' An HTML senden
    Dim jsonData As String
    jsonData = "{""subject"":""" & subject & """,""body"":""" & body & """,""isHTML"":" & isHTML & "}"
    SendToHTML "if(window.handleTemplateLoaded) handleTemplateLoaded(" & jsonData & ");"
End Sub
```

---

## SCHRITT 3: TESTEN

### Test 1: Formular öffnen
```vba
' Im Direktbereich:
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
```
**Erwartung:** HTML-Formular lädt, Header + Eingabefelder sichtbar

### Test 2: Mitarbeiter-E-Mail
```vba
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
Form_frmOff_Outlook_aufrufen.MailOpen 1
```
**Erwartung:** Mitarbeiter-Listen werden befüllt

### Test 3: Kunden-E-Mail
```vba
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
Form_frmOff_Outlook_aufrufen.MailOpen 2
```
**Erwartung:** Kunden-Listen werden befüllt

### Test 4: Excel-Anhang
```vba
DoCmd.OpenForm "frmOff_Outlook_aufrufen"
Form_frmOff_Outlook_aufrufen.VAOpen "C:\Temp\test.xlsx"
```
**Erwartung:** Formular öffnet mit Anhang in Liste

---

## TROUBLESHOOTING

### Problem: "HTML-Datei nicht gefunden"
**Lösung:** Pfad in `Form_Load` anpassen:
```vba
htmlPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frmOff_Outlook_aufrufen.html"
```

### Problem: "Bridge is not defined"
**Lösung:** Warten bis HTML geladen ist:
```vba
Private Sub WebBrowser1_NavigateComplete2(...)
    ' Jetzt erst Daten senden
    Call MailOpen(1)
End Sub
```

### Problem: "Keine Mitarbeiter sichtbar"
**Lösung:** Prüfen ob E-Mail-Adressen vorhanden:
```sql
SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE MA_eMail Is Not Null
```

### Problem: "E-Mail wird nicht gesendet"
**Lösung:** Prüfen ob `mdlOutlookSendMail` vorhanden:
```vba
' Im Direktbereich:
? FunctionExists("CreatePlainMail")
```

---

## DEPENDENCIES

### Erforderliche VBA-Module:
- `mdlOutlookSendMail` (muss existieren!)
- `Function CreatePlainMail()` (wird aufgerufen)

### Erforderliche Tabellen:
- `tbl_MA_Mitarbeiterstamm` (MA_ID, MA_Nachname, MA_Vorname, MA_eMail, IstAktiv)
- `tbl_KD_Kundenstamm` (kun_Id, kun_Firma, kun_eMail, kun_IstAktiv)
- `tbl_Email_Vorlagen` (Optional - Vorlagenname, Betreff, MailText, IstHTML)

### Erforderliche Referenzen:
- Microsoft Office 16.0 Object Library
- Microsoft Outlook Object Library (für CreatePlainMail)

---

## MENÜ-INTEGRATION

### Mitarbeiter-E-Mail Menü (mdl_Menu_Neu.bas)
```vba
Public Function F3_MA_eMail_Std()
    DoCmd.OpenForm "frmOff_Outlook_aufrufen"
    Form_frmOff_Outlook_aufrufen.MailOpen 1
End Function
```

### Kunden-E-Mail Menü (mdl_Menu_Neu.bas)
```vba
Public Function F5_Kunde_eMail_Std()
    DoCmd.OpenForm "frmOff_Outlook_aufrufen"
    Form_frmOff_Outlook_aufrufen.MailOpen 2
End Function
```

---

## NÄCHSTE SCHRITTE

1. ✅ VBA Form-Modul erstellen (siehe oben)
2. ✅ WebView2-Control einbinden
3. ✅ Testen mit MailOpen(1)
4. ✅ Testen mit MailOpen(2)
5. ✅ E-Mail-Versand testen
6. ✅ Anhang-Dialog testen
7. ⏳ E-Mail-Vorlagen-Tabelle anlegen (optional)
8. ⏳ Produktiv-JSON-Parser einbinden (empfohlen)

---

**WICHTIG:** Dieser Code verwendet vereinfachtes JSON-Parsing. Für Produktiv-Einsatz sollte ein echter JSON-Parser verwendet werden (z.B. VBA-JSON von Tim Hall).

**Download:** https://github.com/VBA-tools/VBA-JSON
