VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_ZUO_Stunden_Sub_lb"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Declare PtrSafe Function ShellExecute Lib "SHELL32.DLL" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Public Function neuberechnen(WHERE As String, Optional rechid As Long)

Dim ABF     As String

    ABF = "zqry_ZUO_Stunden_Sub_lb"
    
    Me.txSVS = Null
    Me.txNZ = Null
    Me.txSZ = Null
    Me.txFZ = Null
    Me.txFahrtkosten = Null
    
    Me.txSummeStdBrutto = Nz(TSum("Stunden", ABF, WHERE), 0)
    Me.txSummeStdBruttoN = Nz(TSum("Nacht", ABF, WHERE), 0)
    Me.txSummeStdBruttoS = Nz(TSum("Sonntag", ABF, WHERE), 0)
    Me.txSummeStdBruttoF = Nz(TSum("Feiertag", ABF, WHERE), 0)
    Me.txFahrtkosten = Nz(TSum("PKW", ABF, WHERE), 0)
    
    Call Summen_aktualisieren(rechid)
    
End Function


'Spiegelrechnung exportieren
Private Sub btn_rech_Click()

    Dim Report    As String
    Dim fileName  As String
    Dim MA_ID_SUB As Long
    Dim Criteria  As String
    
    Report = "zrpt_Spiegelrechnung"
    fileName = PfadPlanungAktuell & "Spiegelrechnung " & Me.Parent.Form.Controls("lst_MA").Column(1) & " " & Me.lbAuftrag.caption & ".pdf"
    MA_ID_SUB = Me.Parent.Form.Controls("ID")
    Criteria = "MA_ID = " & MA_ID_SUB & " AND VA_ID = " & Me.Parent.Form.Controls("subAuftragRech").Form.Controls("VA_ID")
    
    DoCmd.OpenReport Report, acViewPreview, , Criteria ', acHidden
    Reports(Report).Controls("Auto_Kopfzeile0").caption = Me.lbAuftrag.caption
    'Reports(Report).Controls("txSVS").SetFocus
    'Reports(Report).Controls("txSVS").Text = TLookup("StdPreis", SPREISE, "kun_ID = " & MA_ID_SUB & " AND Preisart_ID = 1") 'SVS
    Wait 1
    DoCmd.OutputTo acOutputReport, Report, acFormatPDF, fileName
    DoCmd.Close acReport, Report, acSaveNo
    
    ShellExecute 0, "Open", fileName, "", "", 1
    
End Sub


'Stundenliste Auftrag
Private Sub btnStdListe_Click()

    Call Stundenliste_erstellen(Me.Parent.Controls("subAuftragRech").Form.VA_ID, Me.Parent.Controls("subAuftragRech").Form.MA_ID)
    
End Sub


Private Sub Form_Load()

    'Werte nullen
    Call neuberechnen("ZUO_ID = 0")
      
End Sub


Function Summen_aktualisieren(Optional rechid As Long)
    
Dim betrag As String

    Call SPreise_checken
    
    Me.txSummePreis = Nz(Me.txSVS, 0) * Nz(Me.txSummeStdBrutto, 0)
    Me.txSummePreisN = Nz(Me.txNZ, 0) * Nz(Me.txSummeStdBruttoN, 0)
    Me.txSummePreisS = Nz(Me.txSZ, 0) * Nz(Me.txSummeStdBruttoS, 0)
    Me.txSummePreisF = Nz(Me.txFZ, 0) * Nz(Me.txSummeStdBruttoF, 0)

    Me.txSummePreisGesamt = Me.txSummePreis + Me.txSummePreisN + Me.txSummePreisS + Me.txSummePreisF + Me.txFahrtkosten

On Error Resume Next
    'Rechnungsbetrag fortschreiben
    betrag = Replace(Me.txSummePreisGesamt, ",", ".")
    If Not IsInitial(Me.Parent.Controls("subAuftragRech").Form.Rch_ID) And Not IsInitial(betrag) Then
        TUpdate "Gesamtsumme1 = " & betrag, RCHKOPF, "ID = " & Me.Parent.Controls("subAuftragRech").Form.Rch_ID
        
    ElseIf Not IsInitial(rechid) And Not IsInitial(betrag) Then
        TUpdate "Gesamtsumme1 = " & betrag, RCHKOPF, "ID = " & rechid
        
    End If

End Function

'Standardpreise lesen/fortschreiben
Function SPreise_checken()

Dim VA_ID   As Long
Dim MA_ID   As Long
Dim WHERE   As String

On Error GoTo Err
    
    VA_ID = Me.Parent.Controls("subAuftragRech").Form.VA_ID
    MA_ID = Me.Parent.Controls("ID")
    WHERE = "MA_ID = " & MA_ID & " AND VA_ID = " & VA_ID
    
    'Normal
    If IsInitial(Me.txSVS) Then
        Me.txSVS = Nz(TLookup("Satz", ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Normal'"), 0)
        If IsNumeric(Me.txSVS) = False Then Me.txSVS = Null
        If IsInitial(Me.txSVS) Then Me.txSVS = Nz(TLookup("StdPreis", SPREISE, "kun_ID = " & MA_ID & " AND Preisart_ID = 1"), 0)
        If IsNumeric(Me.txSVS) = False Then Me.txSVS = Null
    Else
        If TUpdate("Satz = " & Replace(Me.txSVS, ",", "."), ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Normal'") <> "OK" Then _
            Call calc_ZUO_Stunden_sub(VA_ID, MA_ID)
    End If
    
    'Nacht
    If IsInitial(Me.txNZ) Then
        Me.txNZ = Nz(TLookup("Satz", ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Nacht'"), 0)
        If IsNumeric(Me.txNZ) = False Then Me.txNZ = Null
        If IsInitial(Me.txNZ) Then Me.txNZ = Nz(TLookup("StdPreis", SPREISE, "kun_ID = " & MA_ID & " AND Preisart_ID = 11"), 0)
        If IsNumeric(Me.txNZ) = False Then Me.txNZ = Null
    Else
        If TUpdate("Satz = " & Replace(Me.txNZ, ",", "."), ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Nacht'") <> "OK" Then _
            Call calc_ZUO_Stunden_sub(VA_ID, MA_ID)
    End If
    
    'Sonntag
    If IsInitial(Me.txSZ) Then
        Me.txSZ = Nz(TLookup("Satz", ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Sonntag'"), 0)
        If IsNumeric(Me.txSZ) = False Then Me.txSZ = Null
        If IsInitial(Me.txSZ) Then Me.txSZ = Nz(TLookup("StdPreis", SPREISE, "kun_ID = " & MA_ID & " AND Preisart_ID = 12"), 0)
        If IsNumeric(Me.txSZ) = False Then Me.txSZ = Null
    Else
        If TUpdate("Satz = " & Replace(Me.txSZ, ",", "."), ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Sonntag'") <> "OK" Then _
            Call calc_ZUO_Stunden_sub(VA_ID, MA_ID)
    End If
    
    'Feiertag
    If IsInitial(Me.txFZ) Then
        Me.txFZ = Nz(TLookup("Satz", ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Feiertag'"), 0)
        If IsNumeric(Me.txFZ) = False Then Me.txFZ = Null
        If IsInitial(Me.txFZ) Then Me.txFZ = Nz(TLookup("StdPreis", SPREISE, "kun_ID = " & MA_ID & " AND Preisart_ID = 13"), 0)
        If IsNumeric(Me.txFZ) = False Then Me.txFZ = Null
    Else
        If TUpdate("Satz = " & Replace(Me.txFZ, ",", "."), ZUO_STD, WHERE & " AND Bezeichnung_Kurz = 'Feiertag'") <> "OK" Then _
            Call calc_ZUO_Stunden_sub(VA_ID, MA_ID)
    End If
    
    
Err:

End Function

'Satz manuell angepasst
Private Sub txFZ_AfterUpdate()
    Call Summen_aktualisieren
End Sub

'Satz manuell angepasst
Private Sub txNZ_AfterUpdate()
    Call Summen_aktualisieren
End Sub

'Satz manuell angepasst
Private Sub txSVS_AfterUpdate()
    Call Summen_aktualisieren
End Sub

'Satz manuell angepasst
Private Sub txSZ_AfterUpdate()
    Call Summen_aktualisieren
End Sub

