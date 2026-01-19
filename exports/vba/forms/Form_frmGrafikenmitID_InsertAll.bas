VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_frmGrafikenmitID_InsertAll"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub btnClick_Click()

Dim i As Long
Dim strPathAndFile As String

For i = 1 To 601

        DoCmd.RunCommand acCmdRecordsGoToNew

        strPathAndFile = "D:\AudiNeu\Bild - Kopie\Im" & i & ".bmp"

'        Me![Grafik].Class = "Bild"
        Me![Grafik].SourceDoc = strPathAndFile
        Me![Grafik].OLETypeAllowed = acOLEEmbedded
        Me![Grafik].action = acOLECreateEmbed
        Me![Beschreibung] = Dir(strPathAndFile)

'        DoCmd.RunCommand acCmdSaveRecord
'        DoCmd.RunCommand acCmdClearAll
        
Next i
        
End Sub

Private Sub Form_Current()
Me!Klassenn = Me!Grafik.Class
End Sub
