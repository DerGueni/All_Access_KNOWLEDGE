VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_sub_tbltmp_Position"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit


Private Sub Art_Beschreibung_AfterUpdate()
Me!ME = Me!Art_Beschreibung.Column(1)
End Sub

Private Sub Form_BeforeInsert(Cancel As Integer)
Me!PosNr = Nz(TMax("PosNr", "tbltmp_Position"), 0) + 1
End Sub

Private Sub Int_ArtNr_AfterUpdate()
Me!Art_Beschreibung = Nz(Me!Int_ArtNr.Column(4))
Me!ME = Nz(Me!Int_ArtNr.Column(2))
Me!MwStSatz = Nz(Me!Int_ArtNr.Column(1))
Me!EZPreis = Nz(Me!Int_ArtNr.Column(3), 0#)
End Sub

Private Sub Menge_Exit(Cancel As Integer)
GesBerech
Me!ME.SetFocus
End Sub

Private Sub EzPreis_Exit(Cancel As Integer)
GesBerech
Me!Art_Beschreibung.SetFocus
End Sub

Function GesBerech()
Me!GesPreis = Nz(Me!EZPreis, 0) * Nz(Me!Menge, 0)
End Function
