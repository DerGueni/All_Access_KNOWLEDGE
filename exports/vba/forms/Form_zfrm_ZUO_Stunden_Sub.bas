VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_ZUO_Stunden_Sub"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Public Function neuberechnen()

Dim ABF As String

On Error Resume Next
    
    ABF = "zqry_ZUO_Stunden_Sub_lb"
    
    Me.txSummeStdBrutto = Nz(TSum("Stunden_brutto", ABF, Me.filter), 0)
    Me.txSummeStdBruttoN = Nz(TSum("Stunden_Nacht", ABF, Me.filter), 0)
    Me.txSummeStdBruttoS = Nz(TSum("Stunden_Sonntag", ABF, Me.filter), 0)
    Me.txSummeStdBruttoF = Nz(TSum("Stunden_Feiertag", ABF, Me.filter), 0)
    
    Call Summen_aktualisieren
    
End Function


'Zeitkonto neu berechnen, wenn geöffnet
Private Sub Form_Close()

    If fctIsFormOpen(frmZKTop) Then Call Forms(frmZKTop).filtern_MA
    
End Sub


Private Sub Form_Load()
    
    Call neuberechnen
    
End Sub


'Prüfung
Private Sub Lohnart_ID_BeforeUpdate(Cancel As Integer)
    
Dim Bez As String
    Bez = TLookup("Bezeichnung_kurz", LOHNARTEN, "ID= " & Me.Lohnart_ID)
    
    If Bez <> "Dummy" And Bez <> Me.Bezeichnung_Kurz Then
        Cancel = True
        MsgBox "Art der Stunden nicht änderbar!"
        Me.Undo
        
    End If
    
End Sub


'Neuberechnung
Private Sub Lohnart_ID_AfterUpdate()

    DoCmd.RunCommand acCmdSaveRecord
    Call TUpdate("Satz = Null", ZUO_STD, "ZUO_ID = " & Me.ZUO_ID)
    Call update(, Nz(Me.Lohnart_ID, 0))
    Me.Requery
   
End Sub


'Neuberechnung
Private Sub Preisart_ID_AfterUpdate()

    DoCmd.RunCommand acCmdSaveRecord
    Call TUpdate("Satz = Null", ZUO_STD, "ZUO_ID = " & Me.ZUO_ID)
    Call update(Nz(Me.PreisArt_ID, 0))
    Me.Requery
    
End Sub


Function update(Optional PreisArt_ID As Long, Optional Lohnart_ID As Long)

Dim VADatum         As Date
Dim Lohnart_grund   As Long
Dim Grundlohn       As Double
Dim sql             As String
Dim rs              As Recordset
Dim SubKZ           As Boolean


    VADatum = TLookup("VADatum", ZUORDNUNG, "ID = " & ZUO_ID)
    SubKZ = TLookup("IstSubunternehmer", MASTAMM, "ID = " & MA_ID)
    If Me.Bezeichnung_Kurz = "Normal" Then
        Lohnart_grund = Nz(Me.Lohnart_ID, 0)
    Else
        Lohnart_grund = Nz(TLookup("Lohnart_ID", ZUO_STD, "ZUO_ID = " & Me.ZUO_ID & " AND Bezeichnung_Kurz = 'Normal'"), 0)
    End If
    
    If Not IsInitial(Lohnart_grund) Then Grundlohn = detect_grundlohn(Lohnart_grund, VADatum)
    
    Call update_ZUO_Stunden(Me.ZUO_ID, Me.MA_ID, Me.VA_ID, Me.Bezeichnung_Kurz, Me.Stunden_brutto, VADatum, Lohnart_grund, Grundlohn, Me.Lohnstunden_brutto, SubKZ, PreisArt_ID, Lohnart_ID)
    
    'abhängige Zuschläge aktualisieren
    If Me.Bezeichnung_Kurz = "Normal" Then
        sql = "SELECT * FROM " & ZUO_STD & " WHERE ZUO_ID = " & Me.ZUO_ID & " AND Bezeichnung_Kurz <> 'Normal'"
        Set rs = CurrentDb.OpenRecordset(sql, 8)
        Do While Not rs.EOF
            'ggf. über rekursiven Aufruf Call Update?
            Call update_ZUO_Stunden(rs.fields("ZUO_ID"), rs.fields("MA_ID"), rs.fields("VA_ID"), rs.fields("Bezeichnung_Kurz"), _
                rs.fields("Stunden_brutto"), VADatum, Lohnart_grund, Grundlohn, Me.Lohnstunden_brutto, SubKZ, Nz(rs.fields("PreisArt_ID"), 0), Nz(rs.fields("Lohnart_ID"), 0))
            rs.MoveNext
        Loop
        rs.Close
        Set rs = Nothing
    End If
    
    Call Summen_aktualisieren

End Function


Function Summen_aktualisieren()
    
    Me.txSummePreis = Nz(TSum("Preis", ZUO_STD, Me.filter & " AND Bezeichnung_kurz = 'Normal'"), 0)
    Me.txSummePreisN = Nz(TSum("Preis", ZUO_STD, Me.filter & " AND Bezeichnung_kurz = 'Nacht'"), 0)
    Me.txSummePreisS = Nz(TSum("Preis", ZUO_STD, Me.filter & " AND Bezeichnung_kurz = 'Sonntag'"), 0)
    Me.txSummePreisF = Nz(TSum("Preis", ZUO_STD, Me.filter & " AND Bezeichnung_kurz = 'Feiertag'"), 0)
    Me.txFahrtkosten = Nz(TSum("PKW", ZUORDNUNG, Me.filter), 0)
    Me.txSummePreisGesamt = Nz(TSum("Preis", ZUO_STD, Me.filter), 0) + Me.txFahrtkosten
    
End Function

'Satz manuell angepasst
Private Sub Satz_AfterUpdate()
    
    Me.Preis = Me.Stunden_brutto * Me.Satz
    DoCmd.RunCommand acCmdSaveRecord
    Call Summen_aktualisieren

End Sub
