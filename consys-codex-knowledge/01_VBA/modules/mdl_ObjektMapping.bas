Attribute VB_Name = "mdl_ObjektMapping"
Public Function MapObjektID_ByName() As Long
    Dim db As DAO.Database
    Dim rs As DAO.Recordset
    Dim lngObjID As Long
    Dim lngCount As Long
    Set db = CurrentDb
    Set rs = db.OpenRecordset("SELECT ID, Objekt FROM tbl_VA_Auftragstamm WHERE (Objekt_ID = 0 OR Objekt_ID IS NULL) AND Objekt IS NOT NULL AND Objekt <> ''", dbOpenSnapshot)
    Do While Not rs.EOF
        lngObjID = Nz(DLookup("ID", "tbl_OB_Objekt", "Objekt='" & Replace(rs!Objekt, "'", "''") & "'"), 0)
        If lngObjID > 0 Then
            db.Execute "UPDATE tbl_VA_Auftragstamm SET Objekt_ID = " & lngObjID & " WHERE ID = " & rs!ID, dbFailOnError
            lngCount = lngCount + 1
        End If
        rs.MoveNext
    Loop
    rs.Close
    MapObjektID_ByName = lngCount
End Function
