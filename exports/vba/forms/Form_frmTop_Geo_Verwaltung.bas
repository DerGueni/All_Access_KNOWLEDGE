VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmTop_Geo_Verwaltung"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub cmdBatchObjekte_Click()
    RunBatchGeocodeObjekte
End Sub

Private Sub cmdBatchMA_Click()
    RunBatchGeocodeMA
End Sub

Private Sub cmdBuildDistances_Click()
    RunBuildAllDistances
End Sub

Private Sub cmdStats_Click()
    ShowGeoStats
End Sub

Private Sub cmdClose_Click()
    DoCmd.Close acForm, Me.Name
End Sub
