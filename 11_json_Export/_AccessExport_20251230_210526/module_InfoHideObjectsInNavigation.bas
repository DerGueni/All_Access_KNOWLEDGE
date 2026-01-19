Option Compare Database
Option Explicit



'Hidden Objekte aus / Einblenden
Function fSHowHiddenObjSet(Optional b As Boolean = False)

Application.SetOption "Show Hidden Objects", b
'Application.SetOption "Show System Objects", B

End Function

'' Selektieren offenes Objekt
'DoCmd.SelectObject acForm, "Customers", False

'' Selektieren Objekt in Navigation
'DoCmd.SelectObject acForm, "Customers", True

'' Selektieren Gruppe nur in Navigation
'DoCmd.SelectObject acForm, , True

'Objekt Hidden oder nicht Hidden setzen
'Application.SetHiddenAttribute acTable, "Customers", True

'qrymdbQuery
'qrymdbTable2

Function f_ShowHide_Objects(b As Boolean, Optional tbl As String = "_tbl_HiddenObjects")
Dim ArrFill_DAO_OK1 As Boolean, recsetSQL1 As String, iZLMax1 As Long, iColMax1 As Long, DAOARRAY1, iZl As Long, iCol As Long
Dim iTyp As Long
Dim strName As String
recsetSQL1 = "Select * FROM " & tbl
ArrFill_DAO_OK1 = ArrFill_DAO_Acc(recsetSQL1, iZLMax1, iColMax1, DAOARRAY1)
'Info:   'AccessArray(iSpalte,iZeile) <0, 0>
If ArrFill_DAO_OK1 Then
    For iZl = 0 To iZLMax1
        iTyp = DAOARRAY1(1, iZl)
        strName = DAOARRAY1(0, iZl)
        Application.SetHiddenAttribute iTyp, strName, b
    Next iZl
    Set DAOARRAY1 = Nothing
End If

End Function