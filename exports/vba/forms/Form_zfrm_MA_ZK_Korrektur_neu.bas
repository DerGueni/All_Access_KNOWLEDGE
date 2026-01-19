VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_zfrm_MA_ZK_Korrektur_neu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Wert berechnen
Private Sub Anz_Std_AfterUpdate()

    Call calculate
    Me.Requery
    
End Sub


'Daten aktualisieren
Private Sub Form_Close()

    If fctIsFormOpen(frmZKTop) Then Call Forms(frmZKTop).filtern_MA

End Sub

'Wert wurde geändert
Private Sub Wert_AfterUpdate()

    Call calculate
    Me.Requery
    
End Sub


'Korrektur löschen
Private Sub btnDelete_Click()

Dim rs     As Recordset
Dim KorrID As Integer

On Error Resume Next

    If MsgBox("Selektierten Korrektursatz wirklich löschen?", vbYesNo) = vbYes Then
        Set rs = Me.RecordsetClone
        rs.Bookmark = Me.Bookmark
        KorrID = Nz(rs.fields("ID"), 0)
        rs.Delete
        Me.Requery
        rs.Close
        Set rs = Nothing
    End If
    
    'ggf referenzierten Satz löschen
    CurrentDb.Execute "DELETE FROM " & KORR & " WHERE Korr_ID_ref = " & KorrID
    
End Sub


'Korrektur Euro
Private Sub btnKorrEur_Click()

Dim rs As Recordset
    
    Call Set_Priv_Property("prp_Korr_Stunden", False)
    
    Set rs = Me.RecordsetClone
    rs.AddNew
    rs.fields("MA_ID") = Me.txMA_ID
    rs.fields("Jahr") = Me.txJahr
    rs.fields("Monat") = Me.txMonat
    rs.fields("exportieren") = True
    rs.fields("erstellt") = Now
    rs.fields("Ersteller") = Environ("UserName")
    rs.update

    Me.Requery
    
End Sub


'Korrektur Stunden
Private Sub btnKorrStd_Click()

Dim rs As Recordset

    Call Set_Priv_Property("prp_Korr_Stunden", True)
    
    Set rs = Me.RecordsetClone
    rs.AddNew
    rs.fields("MA_ID") = Me.txMA_ID
    rs.fields("Jahr") = Me.txJahr
    rs.fields("Monat") = Me.txMonat
    rs.fields("exportieren") = True
    rs.fields("erstellt") = Now
    rs.fields("Ersteller") = Environ("UserName")
    rs.update

    Me.Requery

End Sub


'Neuer Korrektursatz allgemein
Private Sub btnNeu_Click()

Dim rs As Recordset

    Call Set_Priv_Property("prp_Korr_Stunden", "")
    
    Set rs = Me.RecordsetClone
    rs.AddNew
    rs.fields("MA_ID") = Me.txMA_ID
    rs.fields("Jahr") = Me.txJahr
    rs.fields("Monat") = Me.txMonat
    rs.fields("exportieren") = True
    rs.fields("erstellt") = Now
    rs.fields("Ersteller") = Environ("UserName")
    rs.update

    Me.Requery
    
End Sub


'Von der Lohnart abhängige Felder aktualisieren
Private Sub Lohnart_ID_AfterUpdate()

    Call calculate
    Me.Requery
    
End Sub


'Berechnungen zur Lohnart
Function calculate() As String

Dim ABF     As String
Dim rs      As Recordset
Dim sql     As String
Dim Satz    As Double
Dim Wert    As Double
Dim Art     As String
Dim Anz_Std As Double
Dim ID_FL   As Integer 'Folgelohnart
Dim Bez     As String
Dim LIDMA   As Integer 'Lohnart Mitarbeiter
Dim MA_ID   As Long
Dim zMA_ID  As Long
Dim Jahr    As Integer 'Zieljahr
Dim Monat   As Integer 'Zielmonat

    DoCmd.RunCommand acCmdSaveRecord

    ABF = LOHNARTEN
    MA_ID = Me.MA_ID
    
    'Jahr und Monat (Ziel) vorgegeben? -> sonst Folgemonat
    Select Case Me.Lohnart_ID
        Case 56
            'ZielKollega + (Jahr +) Monat abfragen
            zMA_ID = Nz(TLookup("MA_ID", KORR, "Korr_ID_ref = " & Me.ID), 0)
            If zMA_ID = 0 Then zMA_ID = Nz(Me.cboKollega.Column(0), 0)
            Jahr = Nz(Me.txJahrZ, 0)
            Monat = Nz(Me.txMonatZ, 0)
            If zMA_ID = 0 Or Jahr = 0 Or Monat = 0 Then
            Me.Lohnart_ID = Null
                MsgBox "Bitte Ziel-Kollega, Ziel-Monat und Ziel-Jahr angeben!", vbCritical
                Exit Function
            End If
            If IsNull(Me.Bemerkung) Then Me.Bemerkung = "nach " & Monat & "/" & Jahr & " " & Me.cboKollega.Column(1)
            'me.Anz_Std = 'hier Stundenvorschlag berechnen !!!!! nur MJ oder auch Fest?
            
        Case Else
            zMA_ID = Me.MA_ID
            'Dezember?
            If Me.Monat < 12 Then
                Jahr = Me.Jahr
                Monat = Me.Monat + 1
            Else
                Jahr = Me.Jahr + 1
                Monat = 1
            End If
        
    End Select
        
    'Daten zur Lohnart
    sql = "SELECT * FROM [" & ABF & "] WHERE ID = " & Me.Lohnart_ID & " AND [DatumBis] = " & datumSQL("31.12.9999")
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    'Lohnart ohne Gültigkeit?
    If rs.EOF Then
        rs.Close
        sql = "SELECT * FROM [" & ABF & "] WHERE ID = " & Me.Lohnart_ID
        Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    End If
     
    'Keine Daten zur Lohnart
    If rs.EOF Then GoTo Err
    
    Anz_Std = Round(Nz(Me.Anz_Std, 0), 2)
    Art = Nz(rs.fields("Bezeichnung_kurz"), "")
    Bez = rs.fields("Bezeichnung")
    ID_FL = Nz(rs.fields("ID_Folgelohnart"), 0)
    Satz = Nz(rs.fields("Satz"), 0)
    
   'Wenn kein Satz, dann individueller Satz des MA
    If Satz = 0 Then
        LIDMA = Nz(TLookup("Stundenlohn_brutto", MASTAMM, "ID = " & Me.MA_ID), 0)
        If LIDMA <> 0 Then
            Satz = Nz(TLookup("Satz", ABF, "ID = " & LIDMA), 0)
        Else
            calculate = "Keine Lohnart im Mitarbeiterstamm hinterlegt!"
        End If
    End If
      
    'Positiv/Negativ + monatsübergreifend?
    Select Case rs.fields("Vorzeichen")
        Case "+"  'Positiv
            If Art = "Euro" Then
                Wert = Abs(Wert)
            Else
                Anz_Std = Abs(Anz_Std)
            End If
            
        Case "-"  'Negativ
            If Art = "Euro" Then
                Wert = -Abs(Wert)
                Me.Wert = Wert
            Else
                Anz_Std = -Abs(Anz_Std)
                Me.Anz_Std = Anz_Std
            End If
            
        Case "+-" 'Positiv + negativ in Referenzsatz
            If Art = "Euro" Then
                Wert = Abs(Wert)
                Me.Wert = Wert
                Me.Korr_ID_ref = ref_korr_anlegen(MA_ID, Jahr, Monat, Me.ID, -Wert, , , ID_FL, Bez, zMA_ID)
            Else
                Anz_Std = Abs(Anz_Std)
                Me.Anz_Std = Anz_Std
                Me.Korr_ID_ref = ref_korr_anlegen(MA_ID, Jahr, Monat, Me.ID, , -Anz_Std, Satz, ID_FL, Bez, zMA_ID)
            End If
        
        Case "-+" 'Negativ + Positiv in Referenzsatz
            If Art = "Euro" Then
                Wert = -Abs(Wert)
                Me.Wert = Wert
                Me.Korr_ID_ref = ref_korr_anlegen(MA_ID, Jahr, Monat, Me.ID, Abs(Wert), , , ID_FL, Bez, zMA_ID)
            Else
                Anz_Std = -Abs(Anz_Std)
                Me.Anz_Std = Anz_Std
                Me.Korr_ID_ref = ref_korr_anlegen(MA_ID, Jahr, Monat, Me.ID, , Abs(Anz_Std), Satz, ID_FL, Bez, zMA_ID)
            End If
            
    End Select
    
    'Satz + Wert anpassen
    If Satz <> 0 Then
        Me.Satz = Satz
        Me.Wert = Me.Anz_Std * Me.Satz
    End If
    
    rs.Close

    'dokumentieren
    Me.geaendert = Now
    Me.Aenderer = Environ("UserName")
    If Me.Bemerkung = "" Then Me.Bemerkung = Me.Lohnart_ID.Column(1)
    
    DoCmd.RunCommand acCmdSaveRecord
    
Ende:
    Set rs = Nothing
    Exit Function
Err:
    MsgBox "Keine Daten zur Lohnart gefunden!", vbCritical
    GoTo Ende
End Function


