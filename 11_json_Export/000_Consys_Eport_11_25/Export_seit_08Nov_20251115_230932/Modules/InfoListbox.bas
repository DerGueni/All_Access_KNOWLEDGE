Option Compare Database
Option Explicit

'################################################################
'Info Listbox setzen
'################################################################

'Me!MeineListbox.RowSource = strSQL
'Me!MeineListbox = Me!MeineListbox.ItemData(0)


'################################################################
'Info Multi-Select Listbox auslesen
'################################################################


'-------------------------
'Alle
'-------------------------

'    k = 0
'    If Me!lst_Zuo.ColumnHeads = True Then k = 1


'Private Sub btnMeineListbox_All_Click()
'    Dim var As Variant
'    Dim str
'    ' Listbox.column(Spalte, Zeile) <0,0>
'
'    For var = 0 To Me!MeineListbox.ListCount - 1
''''    For var = 1 To Me!MeineListbox.ListCount - 1  - wenn Listbox-Überschrift = True
'        str = str & ";" & Me!MeineListbox.Column(1, var)
'    Next I
'
'    MsgBox str
'End Sub
'

'-------------------------
'Nur selektierte
'-------------------------

'Private Sub btnMeineListbox_Select_Click()
'    Dim var As Variant
'    Dim str
'    Dim VertragNr As String
'    str = ""
'    ' Listbox.column(Spalte, Zeile) <0,0>
'    ' For Each var In Me!MeineListbox.ItemsSelected
'
'    For Each var In Me!MeineListbox.ItemsSelected
'         str = str & ";" & Me!MeineListbox.Column(1, var)
'    Next var
'    MsgBox str
'End Sub
'
'
'-------------------------
'Selektion (Schwarz markiert) setzen / löschen
'-------------------------

'setzen
'        Me.MeineListbox.Selected(var) = True

'löschen
'        Me.MeineListbox.Selected(var) = False




'---------------------------------------------
'ID suchen und gefundenen Datensatz selektieren
'---------------------------------------------

'DoCmd.OpenForm "frm_MA_Mitarbeiterstamm"
'Form_frm_MA_Mitarbeiterstamm.Recordset.FindFirst "ID = " & iMA_ID
'
'Form_frm_VA_Auftragstamm.Painting = False
'
'    For i = 1 To Form_frm_MA_Mitarbeiterstamm!lst_MA.ListCount
'        If Trim(Nz(Form_frm_MA_Mitarbeiterstamm!lst_MA.Column(0, i))) = iMA_ID Then
'            Form_frm_MA_Mitarbeiterstamm!lst_MA.Selected(i) = True
'            Exit For
'        End If
'    Next i
'
'Form_frm_VA_Auftragstamm.Painting = True
'
'DoCmd.Close acForm, "frmTop_VA_Tag_sub", acSaveNo