Attribute VB_Name = "mdl_Rechnungsschreibung"
Option Compare Database
Option Explicit

Function fPDF_Datei(s As String)
Dim i As Long

If Len(Trim(Nz(s))) = 0 Then Exit Function
i = InStrRev(s, ".")
If i > 0 Then
    fPDF_Datei = Left(s, i) & "pdf"
End If
If Not File_exist(fPDF_Datei) Then fPDF_Datei = ""
End Function

Function fPDF_Pos_Datei(s As String)
Dim i As Long

If Len(Trim(Nz(s))) = 0 Then Exit Function
i = InStrRev(s, ".")
If i > 0 Then
    fPDF_Pos_Datei = Left(s, i - 1) & "_Pos.pdf"
End If
If Not File_exist(fPDF_Pos_Datei) Then fPDF_Pos_Datei = ""
End Function

Function fMahnDat(iStufe As Long) As Long
Dim i As Long
i = TLookup("Mahn" & iStufe & "Tage", "_tblEigeneFIrma", "FirmenID = 1")
fMahnDat = i
End Function

Public Function Zahlbed_Zahlbar_Bis(ZahlBed_ID As Long) As Date
Dim i As Long
i = Nz(TLookup("AnzTage", "_tblEigeneFirma_Zahlungsbedingungen", "ID = " & ZahlBed_ID), 0)
Zahlbed_Zahlbar_Bis = Date + i
End Function

Public Function Zahlbed_Zahlbar_BetragNetto(ZahlBed_ID As Long, betrag As Currency) As Currency
Dim sd As Single
sd = Nz(TLookup("Skonto", "_tblEigeneFirma_Zahlungsbedingungen", "ID = " & ZahlBed_ID), 0)
Zahlbed_Zahlbar_BetragNetto = fctround(betrag - (betrag * sd))
End Function

''Public Function Get_NeueNr(Optional iArt As Long = 1) As String
'''CONSEC 5 stellig mit f�hrender Null
''Select Case iArt
''    Case 1 ' Rechnung
''    Case 2 ' Angebot
''    Case 3 ' Brief
''    Case 4 ' MA
''
''End Function


Public Function Zahlbed_Text(ZahlBed_ID As Long, betrag As Currency) As String

Dim zwtext As String
Dim i As Long
Dim zwcur As Currency

Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
recsetSQL1 = "SELECT ID, Zahlungsbedingung, AnzTage, Zahlbar_bis_Text, Teil2_Text, Skonto, Teil3_Text FROM _tblEigeneFirma_Zahlungsbedingungen WHERE ID = " & ZahlBed_ID
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>

'_tblEigeneFirma_Zahlungsbedingungen
'Field Name
'==========
'0 - ID
'1 - Zahlungsbedingung
'2 - AnzTage
'3 - Zahlbar_bis_Text
'4 - Teil2_Text
'5 - Skonto
'6 - Teil3_Text
'==========


If ArrFill_DAO_OK1 Then

    zwtext = DAOARRAY1(3, 0)
    i = DAOARRAY1(2, 0)
    If i > 0 Then
        zwtext = zwtext & " " & Format(Date + i, "short date", 2, 2) & " " & DAOARRAY1(4, 0)
    End If
    If Len(Trim(Nz(betrag))) > 0 Then
        If betrag > 0 And DAOARRAY1(5, 0) > 0 Then
            zwcur = fctround(betrag - (betrag * DAOARRAY1(5, 0)))
            zwtext = zwtext & " " & Format(zwcur, "Currency")
            zwtext = zwtext & " " & DAOARRAY1(6, 0)
        End If
    End If
    Zahlbed_Text = zwtext
    
    Set DAOARRAY1 = Nothing
End If

End Function

Public Function Update_Rch_Nr(iID As Long) As Long
Dim i As Long
Dim strSQL As String

i = Nz(TLookup("NummernKreis", "_tblEigeneFirma_Word_Nummernkreise", "ID = " & iID), 0) + 1

strSQL = ""
strSQL = strSQL & "UPDATE _tblEigeneFirma_Word_Nummernkreise SET [_tblEigeneFirma_Word_Nummernkreise].NummernKreis = " & i
strSQL = strSQL & " WHERE ((([_tblEigeneFirma_Word_Nummernkreise].ID)= " & iID & "));"
CurrentDb.Execute (strSQL)
DoEvents
Update_Rch_Nr = i

End Function
