Attribute VB_Name = "zmd_LEX_API"
Option Compare Database
Option Explicit

' Lexoffice API
Private Const LEXOFFICE_BASE_URL As String = "https://api.lexoffice.io"
Private Const LEXOFFICE_API_KEY As String = "0H6RV653cCHt38HicpJBfaApgKpw-RPXJ9VNMGjViRKGgMEo"


' ===== API-KOMMUNIKATION =====
Function CallLexofficeAPI(ByVal method As String, ByVal endpoint As String, Optional json As String, Optional multipart As Boolean) As String

On Error GoTo Err
    
    Dim http As Object: Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
    Dim url As String: url = LEXOFFICE_BASE_URL & endpoint
    
    http.Open method, url, False
    http.setRequestHeader "Authorization", "Bearer " & LEXOFFICE_API_KEY
    If multipart Then
        http.setRequestHeader "Content-Type", "multipart/form-data"
    Else
        http.setRequestHeader "Content-Type", "application/json"
    End If
    http.setRequestHeader "Accept", "application/json"
    
    If Len(json) > 0 Then
        http.Send json
    Else
        http.Send endpoint
    End If
    
    If http.Status < 200 Or http.Status >= 300 Then
        Err.Raise vbObjectError + 2001, , "Lexoffice API Fehler: HTTP " & http.Status & " - " & http.statusText & vbCrLf & http.responseText
    End If
    
    CallLexofficeAPI = http.responseText
    Exit Function
    
Err:
    MsgBox "API-Kommunikationsfehler: " & Err.description, vbCritical
    CallLexofficeAPI = ""
End Function


' Lexware Kunden-ID
Function get_lex_customer_id(kunnr As Long) As String
Dim oJSON As Object
Dim contactJSON As String

    contactJSON = CallLexofficeAPI("GET", "/v1/contacts?customer=true&number=" & kunnr)

    Set oJSON = zJsonConverter.ParseJSON(contactJSON)

On Error Resume Next
    get_lex_customer_id = oJSON("content")(1)("id")
    
End Function


'Rechnung erstellen
Function create_lex_invoice(VA_ID As Long) As String
Dim oJSON       As Object
Dim InvoiceJSON As String
Dim rc          As String
Dim ID          As String
Dim Rch_Nr      As String
Dim Datei       As String

    'Rechnungsnummer vorhanden?
    Rch_Nr = Nz(TLookup("Rch_Nr", AUFTRAGSTAMM, "ID=" & VA_ID), "")
    If Rch_Nr <> "" Then
        MsgBox "Rechnung wurde bereits angelegt in Lexware!", vbCritical
        Exit Function
    End If
    
    InvoiceJSON = createInvoiceJson(VA_ID)

    rc = CallLexofficeAPI("POST", "/v1/invoices", InvoiceJSON)
    
    If rc = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(rc)
    ID = oJSON("id")
    
    'Berechnungsliste
    Datei = create_berechnungsliste(VA_ID)
    rc = CallLexofficeAPI("POST", "/v1/invoices/" & ID & "/files", Datei)
        
    Rch_Nr = transfer_invoice_data(ID, VA_ID) 'SPÄTER WIEDER RAUS?
    
    TUpdate "Rech_NR='" & Rch_Nr & "'", AUFTRAGSTAMM, "ID=" & VA_ID
    TUpdate "Rch_Dat=" & DatumSQL(Now), AUFTRAGSTAMM, "ID=" & VA_ID
    
    create_lex_invoice = Rch_Nr
    
End Function

'
'Print CallLexofficeAPI("POST", "/v1/files&file=@{\\vConsys01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\E - AUFTRÄGE 2015 NOCH ZU BERECHNEN\test.pdf}", , True)
'
'Print create_berechnungsliste(9090)
'\\vConsys01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\E - AUFTRÄGE 2015 NOCH ZU BERECHNEN\test.pdf

'Berechnungsliste erstellen
Function create_berechnungsliste(VA_ID As Long) As String

Dim rpt         As String
Dim Datei       As String
'Dim oJSON       As Object
'Dim InvoiceJSON As String
'Dim voucherId   As String
'Dim rc          As String


    Set_Priv_Property "prp_rpt_rch_va_id", VA_ID
    rpt = "zrpt_Rch_Berechnungsliste"
    Datei = PfadZuBerechnen & "test.pdf"
    DoCmd.OutputTo acOutputReport, rpt, "PDF", Datei
    
'    rc = CallLexofficeAPI("POST", "/v1/files", "file=@{" & datei & "}&type=voucher")
'    Set oJSON = zJsonConverter.ParseJSON(rc)
    
    create_berechnungsliste = Datei
    
End Function


'boundary "--1234567890"
 Function CreateBody(strPath As String, strBoundary As String) As Byte()
    Dim strBody As String
    strBody = "--" & strBoundary & vbCrLf
    strBody = strBody & "Content-Disposition: form-data; name=""file""; filename=""" _
        & Mid$(strPath, InStrRev(strPath, "\") + 1) & """" & vbCrLf
    strBody = strBody & "Content-Type: application/pdf" & vbCrLf & vbCrLf
    strBody = strBody & ReadBinaryFile(strPath) & vbCrLf
    strBody = strBody & "--" & strBoundary & vbCrLf
    strBody = strBody & "Content-Disposition: form-data; name=""type""" & vbCrLf & vbCrLf
    strBody = strBody & "voucher" & vbCrLf
    strBody = strBody & "--" & strBoundary & "--"
    CreateBody = StrConv(strBody, vbFromUnicode)
 End Function

 Private Function ReadBinaryFile(strPath As String) As String
    Dim intFile As Integer
    Dim bytBuffer() As Byte
    Dim strFileData As String
    intFile = FreeFile
    Open strPath For Binary Access Read As intFile
    If LOF(intFile) > 0 Then
        ReDim bytBuffer(0 To LOF(intFile) - 1) As Byte
        Get intFile, , bytBuffer
        strFileData = StrConv(bytBuffer, vbUnicode)
    End If
    Close intFile
    ReadBinaryFile = strFileData
 End Function
 
 
 
 Sub testpdf()
 
 Dim filestring As String
 Dim file       As Variant
 
     filestring = ReadBinaryFile("C:\Consys\CONSEC\CONSEC PLANUNG AKTUELL\E - AUFTRÄGE 2015 NOCH ZU BERECHNEN\test.pdf")
     
    file = Base64ToArray(filestring)
    Open "C:\Consys\CONSEC\CONSEC PLANUNG AKTUELL\E - AUFTRÄGE 2015 NOCH ZU BERECHNEN\test2.pdf" For Binary As #1
        Put #1, , file
    Close #1
    
 End Sub
 
'Print test_post_invoice
'{
'  "id": "7501de9d-bac7-4249-9810-32610f738167",
'  "resourceUri": "https://api.lexware.io/v1/invoices/7501de9d-bac7-4249-9810-32610f738167",
'  "createdDate": "2025-10-22T22:20:44.031+02:00",
'  "updatedDate": "2025-10-22T22:20:44.032+02:00",
'  "version": 1
'}
'RE06378



Function transfer_invoice_data(ID As String, VA_ID As Long) As String
Dim rstKopf     As Recordset
Dim rstPos      As Recordset
Dim oJSON       As Object
Dim InvoiceJSON As String
Dim i           As Integer
Dim pos         As Integer
Dim Rch_Nr      As String
    
    InvoiceJSON = CallLexofficeAPI("GET", "/v1/invoices/" & ID)
    If InvoiceJSON = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(InvoiceJSON)
    Rch_Nr = oJSON("voucherNumber")
    
    'Debug.Print zJsonConverter.ConvertToJson(oJSON, Whitespace:=2)
    CurrentDb.Execute "DELETE FROM ztbl_rch_kopf_lex WHERE id = '" & oJSON("id") & "'"
    CurrentDb.Execute "DELETE FROM ztbl_rch_pos_lex WHERE kopf_id = '" & oJSON("id") & "'"
    
 On Error Resume Next
    pos = oJSON("lineItems").Count
 On Error GoTo 0
    
    Set rstKopf = CurrentDb.OpenRecordset("ztbl_rch_kopf_lex")
    rstKopf.AddNew
    rstKopf.fields("VA_ID") = VA_ID
    rstKopf.fields("id") = oJSON("id")
    rstKopf.fields("voucherDate") = oJSON("voucherDate")
    rstKopf.fields("contactId") = oJSON("address")("contactId")
    rstKopf.fields("createdDate") = oJSON("createdDate")
    rstKopf.fields("updatedDate") = oJSON("updatedDate")
    rstKopf.fields("version") = oJSON("version")
    rstKopf.fields("voucherNumber") = oJSON("voucherNumber")
    rstKopf.fields("totalNetAmount") = oJSON("totalPrice")("totalNetAmount")
    rstKopf.fields("totalGrossAmount") = oJSON("totalPrice")("totalGrossAmount")
    rstKopf.fields("archived") = oJSON("archived")
    rstKopf.fields("voucherStatus") = oJSON("voucherStatus")
    rstKopf.fields("paymentTermDuration") = oJSON("paymentConditions")("paymentTermDuration")
    rstKopf.update
    rstKopf.Close
    Set rstKopf = Nothing
    
    
    Set rstPos = CurrentDb.OpenRecordset("ztbl_rch_pos_lex")
    For i = 1 To pos
        rstPos.AddNew
        rstPos.fields("kopf_id") = oJSON("id")
        rstPos.fields("id") = oJSON("lineItems")(i)("id")
        rstPos.fields("type") = oJSON("lineItems")(i)("type")
        rstPos.fields("pos_name") = oJSON("lineItems")(i)("name")
        rstPos.fields("description") = oJSON("lineItems")(i)("description")
        rstPos.fields("quantitiy") = oJSON("lineItems")(i)("quantity")
        rstPos.fields("unitName") = oJSON("lineItems")(i)("unitName")
        rstPos.fields("netAmount") = oJSON("lineItems")(i)("unitPrice")("netAmount")
        rstPos.fields("grossAmount") = oJSON("lineItems")(i)("unitPrice")("grossAmount")
        rstPos.fields("taxRatePercentage") = oJSON("lineItems")(i)("unitPrice")("taxRatePercentage")
        rstPos.fields("discountPercentage") = oJSON("lineItems")(i)("discountPercentage")
        rstPos.update
    Next i
    rstPos.Close
    Set rstPos = Nothing

    transfer_invoice_data = Rch_Nr
    
End Function


'Invoice JSON für API erzeugen
Function createInvoiceJson(VA_ID As Long, Optional voucherId As String) As String

Const Sicherheitspersonal = "6b74fbb4-4c38-4ee3-a302-78203debe798"
Const Leitungspersonal = "6bf1a702-a09d-4e7d-957b-ecb4b9d86942"
Const bereichsleitung = "415c2208-2c34-4881-9a75-38d2832d0fff"
Const Nachtzuschlag = "3ddd78e2-d067-45a8-ae0f-a31f761623aa"
Const Sonntagszuschlag = "838a127f-a781-4c84-ba6b-babac18b6945"
Const Feiertagszuschlag = "d102181e-67c5-468c-ba73-c0b0dc876614"
Const Fahrtkosten = "b6e54f05-0275-44f1-ba4a-1da2f4a7cb68"

Dim va_std              As VA_Stunden
Dim PKW_kost            As Double
Dim PKW_anz             As Integer
Dim kunnr               As Long
Dim kunnr_Lex           As Long
Dim contactId           As String
Dim description         As String
Dim amount              As Double
Dim Dat_VA_Von          As Date
Dim Dat_VA_Bis          As Date
Dim Datum               As String
Dim paymentTerms        As String

Dim lines               As New Collection 'Positionen
Dim lineItems           As New Dictionary 'Positionsdaten
Dim unitPrice           As New Dictionary
Dim invoiceItems        As New Dictionary
Dim address             As New Dictionary
Dim totalPrice          As New Dictionary
Dim taxConditions       As New Dictionary
Dim paymentConditions   As New Dictionary
Dim shippingConditions  As New Dictionary
Dim files               As New Dictionary

    'Stunden für Rechnung ermitteln
    'va_std = get_std_rch(VA_ID)
    va_std = get_VA_Data(VA_ID).VA_Stunden
    
    'Fahrtkosten ermitteln
    PKW_kost = TLookup("Fahrtkosten", AUFTRAGSTAMM, "ID = " & VA_ID)
    PKW_anz = TLookup("Dummy", AUFTRAGSTAMM, "ID = " & VA_ID)
    
    'Kunde ermitteln
    kunnr = TLookup("Veranstalter_ID", AUFTRAGSTAMM, "ID = " & VA_ID)
    kunnr_Lex = TLookup("kunnr_Lex", KDStamm, "kun_Id = " & kunnr)
    contactId = get_lex_customer_id(kunnr_Lex)
    
    If contactId = "" Then
        MsgBox "Kunde " & kunnr_Lex & " nicht gefunden in Lexware!", vbCritical
        Exit Function
    End If

    'Zahlungsbedingungen
    paymentTerms = "14"
    
    'Veranstaltungszeitraum
    Dat_VA_Von = Nz(TLookup("Dat_VA_Von", AUFTRAGSTAMM, "ID = " & VA_ID), "")
    Dat_VA_Bis = Nz(TLookup("Dat_VA_Bis", AUFTRAGSTAMM, "ID = " & VA_ID), "")
    
    'Positionstext ermitteln
    If Dat_VA_Von = Dat_VA_Bis Then
        Datum = Dat_VA_Von
    Else
        Datum = Dat_VA_Von & " - " & Dat_VA_Bis
    End If
    description = Nz(TLookup("Auftrag", AUFTRAGSTAMM, "ID = " & VA_ID), "") & " " & Nz(TLookup("Objekt", AUFTRAGSTAMM, "ID = " & VA_ID), "") & " " & Nz(TLookup("Ort", AUFTRAGSTAMM, "ID = " & VA_ID), "") & "  " & Datum
    
    invoiceItems.Add "archived", "false"
    invoiceItems.Add "voucherDate", zDateTimeConverter.ConvertToIsoTime(Now, True)

    address.Add "contactId", contactId
    
    invoiceItems.Add "address", address
    
    If va_std.sicherheit > 0 Then
        amount = detect_Spreis(kunnr, 1)
        Set lineItems = New Dictionary
        lineItems.Add "id", Sicherheitspersonal
        lineItems.Add "type", "service"
        lineItems.Add "name", "Sicherheitspersonal"
        lineItems.Add "description", description
        lineItems.Add "quantity", va_std.sicherheit
        lineItems.Add "unitName", "Stunden"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
        
        lines.Add lineItems
    End If
    
    If va_std.leitung > 0 Then
        amount = detect_Spreis(kunnr, 3)
        Set lineItems = New Dictionary
        lineItems.Add "id", Leitungspersonal
        lineItems.Add "type", "service"
        lineItems.Add "name", "Leitungspersonal"
        'lineItems.Add "description", description 'keine Beschreibung!
        lineItems.Add "quantity", va_std.leitung
        lineItems.Add "unitName", "Stunden"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
        
        lines.Add lineItems
    End If
    
    If va_std.bereichsleitung > 0 Then
        amount = detect_Spreis(kunnr, 2)
        Set lineItems = New Dictionary
        lineItems.Add "id", bereichsleitung
        lineItems.Add "type", "service"
        lineItems.Add "name", "Bereichsleitung"
        'lineItems.Add "description", description 'keine Beschreibung!
        lineItems.Add "quantity", va_std.bereichsleitung
        lineItems.Add "unitName", "Stunden"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
        
        lines.Add lineItems
    End If
    
    If va_std.Nacht > 0 Then
        amount = detect_Spreis(kunnr, 11)
        Set lineItems = New Dictionary
        lineItems.Add "id", Nachtzuschlag
        lineItems.Add "type", "service"
        lineItems.Add "name", "Nachtzuschlag"
        'lineItems.Add "description", description 'keine Beschreibung!
        lineItems.Add "quantity", va_std.Nacht
        lineItems.Add "unitName", "Stunden"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
    
        lines.Add lineItems
    End If
    
    If va_std.Sonntag > 0 Then
        amount = detect_Spreis(kunnr, 12)
        Set lineItems = New Dictionary
        lineItems.Add "id", Sonntagszuschlag
        lineItems.Add "type", "service"
        lineItems.Add "name", "Sonntagszuschlag"
        'lineItems.Add "description", description 'keine Beschreibung!
        lineItems.Add "quantity", va_std.Sonntag
        lineItems.Add "unitName", "Stunden"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
    
        lines.Add lineItems
    End If
    
    If va_std.Feiertag > 0 Then
        amount = detect_Spreis(kunnr, 13)
        Set lineItems = New Dictionary
        lineItems.Add "id", Feiertagszuschlag
        lineItems.Add "type", "service"
        lineItems.Add "name", "Feiertagszuschlag"
        'lineItems.Add "description", description 'keine Beschreibung!
        lineItems.Add "quantity", va_std.Feiertag
        lineItems.Add "unitName", "Stunden"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
    
        lines.Add lineItems
    End If
    
    If PKW_anz > 0 Then
        amount = PKW_kost
        Set lineItems = New Dictionary
        lineItems.Add "id", Fahrtkosten
        lineItems.Add "type", "service"
        lineItems.Add "name", "Fahrtkosten"
        'lineItems.Add "description", description 'keine Beschreibung!
        lineItems.Add "quantity", PKW_anz
        lineItems.Add "unitName", "PKW"
        
        Set unitPrice = New Dictionary
        unitPrice.Add "currency", "EUR"
        unitPrice.Add "netAmount", amount
        unitPrice.Add "taxRatePercentage", "19"
        
        lineItems.Add "unitPrice", unitPrice
        lineItems.Add "discountPercentage", "0"
    
        lines.Add lineItems
    End If
    
    invoiceItems.Add "lineItems", lines
    
    totalPrice.Add "currency", "EUR"
    
    invoiceItems.Add "totalPrice", totalPrice
    
    taxConditions.Add "taxType", "net"
    
    invoiceItems.Add "taxConditions", taxConditions
    
    paymentConditions.Add "paymentTermLabel", "Wir bedanken uns für die Beauftragung und würden Sie bitten den Rechnungsbetrag bis zum {dueDate} auf unser Konto zu überweisen."
    'paymentConditions.Add "paymentTermLabelTemplate", "Wir bedanken uns für die Beauftragung und würden Sie bitten den Rechnungsbetrag bis zum {dueDate} auf unser Konto zu überweisen."
    paymentConditions.Add "paymentTermDuration", paymentTerms
    
    invoiceItems.Add "paymentConditions", paymentConditions
    
    'Leistungsdatum oder Leistungszeitraum
    If Dat_VA_Von = Dat_VA_Bis Then
        shippingConditions.Add "shippingDate", zDateTimeConverter.ConvertToIsoTime(Dat_VA_Von, True)
        shippingConditions.Add "shippingType", "service"
    Else
        shippingConditions.Add "shippingDate", zDateTimeConverter.ConvertToIsoTime(Dat_VA_Von, True)
        shippingConditions.Add "shippingEndDate", zDateTimeConverter.ConvertToIsoTime(Dat_VA_Bis, True)
        shippingConditions.Add "shippingType", "serviceperiod"
    End If

    invoiceItems.Add "shippingConditions", shippingConditions
    
    invoiceItems.Add "title", "Rechnung"
    invoiceItems.Add "printLayoutId", "4d2a1b90-db05-456d-8266-20bc8d103f8f"
    invoiceItems.Add "introduction", "Für unsere Dienstleistungen erlauben wir uns gemäß beiliegender Aufstellung in Rechnung zu stellen:"
    invoiceItems.Add "remark", "Mit freundlichen Grüßen" & vbCrLf & "Melanie Oberndorfer" & vbCrLf & "CONSEC SECURITY NÜRNBERG"
    
    'Berechnungsliste
    If voucherId <> "" Then
        files.Add "documentFileId", voucherId
        invoiceItems.Add "files", files
    End If
    
    createInvoiceJson = zJsonConverter.ConvertToJson(invoiceItems, Whitespace:=2)
    
End Function


'Rechnung als PDF von Lexware herunterladen
Function get_lex_invoice_pdf(ID As String) As String

Dim oJSON           As Object
Dim InvoiceJSON     As String
Dim filestring      As String
Dim file            As Variant
Dim voucherNumber   As String
Dim pfad            As String

    pfad = "C:\Database\Temp\"
    
    InvoiceJSON = CallLexofficeAPI("GET", "/v1/invoices/" & ID)
    If InvoiceJSON = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(InvoiceJSON)
    voucherNumber = oJSON("voucherNumber")
    filestring = CallLexofficeAPI("GET", "/v1/invoices/" & ID & "/file")

    If filestring <> "" And voucherNumber <> "" Then
        file = Base64ToArray(filestring)
        Open pfad & voucherNumber & ".pdf" For Binary As #1
            Put #1, , file
        Close #1
        get_lex_invoice_pdf = pfad & voucherNumber & ".pdf"
    End If

    'Debug.Print zJsonConverter.ConvertToJson(InvoiceJSON, 2)
End Function


'Datei nach Lexware hochladen
Function upload_pdf(rchID As String, Datei As String) As String

Dim rc              As String
Dim oJSON           As Object
Dim ID              As String
Dim voucherId       As String
    
    rc = CallLexofficeAPI("Post", "/v1/files?file=@{" & Datei & "}&type=voucher")
    
    Set oJSON = zJsonConverter.ParseJSON(rc)
    ID = oJSON("id")
    voucherId = oJSON("voucherId")
    
    upload_pdf = ID
    
End Function


'RechNr (Lexware voucherNumber) aus RechnungsId
Function get_lex_voucherNumber(ID As String) As String

Dim oJSON           As Object
Dim InvoiceJSON     As String
        
    InvoiceJSON = CallLexofficeAPI("GET", "/v1/invoices/" & ID)
    If InvoiceJSON = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(InvoiceJSON)
    
    get_lex_voucherNumber = oJSON("voucherNumber")
    
End Function


'Lexware Rechnungs-ID aus Rechnungsnummer
Function get_lex_invoice_id(rechnr As String) As String

Dim oJSON           As Object
Dim InvoiceJSON     As String
        
    InvoiceJSON = CallLexofficeAPI("GET", "/v1/voucherlist?voucherType=invoice&voucherStatus=any&voucherNumber=" & rechnr)
    If InvoiceJSON = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(InvoiceJSON)
    
    'genau eine ID ermittelt?
    If oJSON("content").Count = 1 Then get_lex_invoice_id = oJSON("content")(1)("id")

End Function


'Lexware Rechnungen eines Kunden
Function get_lex_invoices(kunId As String) As Variant

Dim oJSON           As Object
Dim InvoiceJSON     As String
Dim i               As Integer
Dim arr()           As String
        
    'max 250 Objekte!
    InvoiceJSON = CallLexofficeAPI("GET", "/v1/voucherlist?voucherType=invoice&voucherStatus=any&size=250&contact=" & kunId)
    If InvoiceJSON = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(InvoiceJSON)
    
    For i = 1 To oJSON("content").Count
        ReDim Preserve arr(i - 1)
        arr(i - 1) = oJSON("content")(i)("id")
    Next i

    get_lex_invoices = arr

End Function


'Lexware Artikel
Function get_lex_articles() As Variant

Dim oJSON           As Object
Dim json            As String
Dim i               As Integer
Dim arr()           As String
      
On Error Resume Next

    'max 250 Objekte!
    json = CallLexofficeAPI("GET", "/v1/articles?size=250&type=SERVICE")
    If json = "" Then Exit Function
    
    Set oJSON = zJsonConverter.ParseJSON(json)
    
    For i = 1 To oJSON("content").Count
        ReDim Preserve arr(i - 1)
        arr(i - 1) = oJSON("content")(i)("id")
        Debug.Print oJSON("content")(i)("id") & "  " & oJSON("content")(i)("title")
    Next i

    get_lex_articles = arr

End Function


Function get_customers_lex() As String
Dim oJSON As Object
Dim contactsJSON As String
Dim i As Integer
Dim page As Integer
Dim kunId    As String
Dim kunorgid As String
Dim kunnr    As String
Dim liefnr   As String
Dim kunnam   As String
Dim archived As String


    For page = 0 To 3
        contactsJSON = CallLexofficeAPI("GET", "/v1/contacts?customer=true&size=250&page=" & page)
       
        Set oJSON = zJsonConverter.ParseJSON(contactsJSON)
        Debug.Print oJSON("content").Count
        For i = 1 To oJSON("content").Count
            kunId = oJSON("content")(i)("id")
            kunorgid = oJSON("content")(i)("organizationId")
            kunnr = oJSON("content")(i)("roles")("customer")("number")
            archived = oJSON("content")(i)("archived")
On Error Resume Next
            liefnr = oJSON("content")(i)("roles")("vendor")("number")
            If Err.Number <> 0 Then liefnr = "0"
            Err.clear
            kunnam = Nz(oJSON("content")(i)("company")("name"), "")
            If Err.Number <> 0 Then kunnam = ""
On Error GoTo 0
            kunnam = Replace(kunnam, "Ã¼", "ü")
            kunnam = Replace(kunnam, "'", "`")
            kunnam = Replace(kunnam, "Ã¶", "ö")
            kunnam = Replace(kunnam, "Ã¤", "ä")
            kunnam = Replace(kunnam, "ï¿½", "ö")
            'kunnam = Replace(kunnam, "", "")
    
            CurrentDb.Execute "INSERT INTO Lex_kunden VALUES (" & kunnr & ",'" & kunnam & "'," & liefnr & ",'" & archived & "')"
        Next i
    Next page
    
    'get_contacts = zJsonConverter.ConvertToJson(oJSON, Whitespace:=2)
End Function


Function get_invoicelist_lex() As String
Dim oJSON As Object
Dim draftInvoicesJSON As String
Dim openInvoicesJSON As String
Dim InvoicesJSON As String
Dim invoices() As String
Dim InvoiceJSON As String
Dim i As Integer
Dim j As Integer
Dim ID     As String
Dim Nr     As String
Dim kunId  As String
Dim Status As String

Dim itemid  As String
Dim itemtxt As String

    'draftInvoicesJSON = CallLexofficeAPI("GET", "/v1/voucherlist?voucherType=invoice&voucherStatus=draft")
    'openInvoicesJSON = CallLexofficeAPI("GET", "/v1/voucherlist?voucherType=invoice&voucherStatus=open")
    InvoicesJSON = CallLexofficeAPI("GET", "/v1/voucherlist?voucherType=invoice&voucherStatus=paid")
    'mehrere Rechnungen sind ohne Positionsdaten!!!: oJSON("content").count  oJSON("content")(1)("voucherNumber")  oJSON("content")(1)("lineItems").count
    'invoiceJSON = CallLexofficeAPI("GET", "/v1/invoices/cf5f8b34-4a9f-4749-8091-4b22d72b9e52")
   
    Set oJSON = zJsonConverter.ParseJSON(InvoicesJSON)
    
    For i = 1 To oJSON("content").Count
        ReDim Preserve invoices(i)
        invoices(i - 1) = oJSON("content")(i)("id")
    Next i

    For i = LBound(invoices) To UBound(invoices)
        InvoiceJSON = CallLexofficeAPI("GET", "/v1/invoices/" & invoices(i))
        Set oJSON = zJsonConverter.ParseJSON(InvoiceJSON)
        ID = oJSON("id")
        Nr = oJSON("voucherNumber")
        kunId = oJSON("address")("contactId")
        Status = oJSON("voucherStatus")
        CurrentDb.Execute "INSERT INTO tbl_invoices_lex VALUES ('" & ID & "','" & Nr & "','" & kunId & "','" & Status & "')"
        
        For j = 1 To oJSON("lineItems").Count
            itemid = oJSON("lineItems")(j)("id")
            itemtxt = oJSON("lineItems")(j)("name")
            CurrentDb.Execute "INSERT INTO tbl_lex_items VALUES ('" & itemid & "','" & itemtxt & "')"
        Next j
    Next i
    

    
    'get_invoicelist_lex = zJsonConverter.ConvertToJson(oJSON, Whitespace:=2)
End Function


Function correc_rechnr()

Dim rs As Recordset

    Set rs = CurrentDb.OpenRecordset(AUFTRAGSTAMM)
    
    Do While Not rs.EOF
        If IsNumeric(rs.fields("Rech_NR")) Then
            rs.Edit
            rs.fields("Rech_NR") = "RE0" & rs.fields("Rech_NR")
            rs.update
        End If
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing

End Function


Function refresh_lex_invoices()

Dim rs As Recordset

    Set rs = CurrentDb.OpenRecordset("ztbl_rch_kopf_lex", dbOpenSnapshot)
    
    Do While Not rs.EOF
        Debug.Print transfer_invoice_data(rs.fields("id"), rs.fields("VA_ID"))
        Wait 1
        rs.MoveNext
    Loop
    
End Function

