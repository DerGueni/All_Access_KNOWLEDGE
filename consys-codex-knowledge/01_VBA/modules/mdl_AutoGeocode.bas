Attribute VB_Name = "mdl_AutoGeocode"


Public Function VA_AfterUpdate_AutoGeo() As Boolean
    Dim frm As Form
    Dim strObjekt As String
    Dim strOrt As String
    Dim lngObjektID As Long
    
    Set frm = Screen.ActiveForm
    
    strObjekt = Nz(frm!Objekt, "")
    strOrt = Nz(frm!Ort, "")
    
    If Len(strObjekt) > 0 And Len(strOrt) > 0 Then
        lngObjektID = AutoGeocodeNeuesObjekt(strObjekt, strOrt)
        If lngObjektID > 0 And (Nz(frm!Objekt_ID, 0) = 0) Then
            frm!Objekt_ID = lngObjektID
        End If
    End If
    
    VA_AfterUpdate_AutoGeo = True
End Function
