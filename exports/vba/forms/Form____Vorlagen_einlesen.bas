VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form____Vorlagen_einlesen"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

Private Sub Befehl1_Click()
Dim nix
Dim i As Long

If Nz(Me!DateiPfad) = "" Then
    MsgBox "Na na na, ohne Datei gehts schon gar nicht <g>"
    Exit Sub
End If

If Nz(Me!Kurztext) = "" Then
    MsgBox "Für dieses Beispiel muß was im Kurztext drinstehen, sonst klappts nicht"
    Exit Sub
End If

i = TCount("*", "___Vorlagen_einlesen") + 1

'Function BinImport(tabelle As String, PfadDatei As String, BinaryFeld As String, Optional Kurztext As String)
nix = BinImport("___Vorlagen_einlesen", Me!DateiPfad, "Picture", Nz(Me!Kurztext), i)

Me!DateiPfad = ""
Me!Kurztext = ""

Me!ldtDateien.Requery

End Sub


Private Sub Befehl22_Click()
'Function AlleSuchNeu(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Datei (*.*) suchen") As String
Dim sPath As String

Me!DateiPfadNeu = AlleSuchNeu()

End Sub

Private Sub Befehl4_Click()
DoCmd.Close acForm, Me.Name, acSaveNo
End Sub

Private Sub Befehl7_Click()
Dim sPath As String

Me!DateiPfad = AlleSuch()
If Len(Dir(Me!DateiPfad)) > 0 Then
    Me!Kurztext = Dir(Me!DateiPfad)
End If
End Sub

Function AlleSuch(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Datei (*.*) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Alle Dateien (*.*)"
      .Filter1Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowOpen                          ' oder .ShowSave
   End With
   
AlleSuch = fd.fileName

End Function

Function AlleSuchNeu(Optional ByVal startdir As String = "C:\", Optional ByVal StBeschriftung As String = "Datei (*.*) suchen") As String

Dim fd As New FileDialog
 
Const OFN_FILEMUSTEXIST = &H1000
Const OFN_PATHMUSTEXIST = &H800
Const OFN_HIDEREADONLY = &H4
Const OFN_READONLY = &H1
Const OFN_OVERWRITEPROMPT = &H2
 
   With fd  ' CommonDialog aufrufen
    ' Erläuterungen im Code des KlassenModuls FileDialog
      
      .DialogTitle = StBeschriftung
      .InitDir = startdir
      
'      .DefaultExt = "TXT"             'Standard-Endung wenn vom Benutzer nix anderes angegeben
'                                      ' Ansonsten wird Filter1 verwendet
'      .Flags = OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_READONLY
      .Flags = OFN_PATHMUSTEXIST Or OFN_OVERWRITEPROMPT
                      
' Hier können bis max. 5 Filter für Datei-Endungen definiert werden
      
      .Filter1Text = "Alle Dateien (*.*)"
      .Filter1Suffix = "*.*"

'      ... bis max. Filter5Text/Suffix ...
'
      .ShowSave
'      .ShowOpen                          ' oder .ShowSave
   End With
   
AlleSuchNeu = fd.fileName

End Function



Private Sub btnHelp_Click()
DoCmd.OpenForm "frm_Hilfe_Anzeige", acNormal, , "Formularname = '" & Me.Name & "'"

End Sub

Private Sub btnSaveFile_Click()

Dim i As Long, jn As Boolean, sPath As String

i = TCount("ID", "___Vorlagen_einlesen", "ID = " & Me!tabID)


If i > 0 And Len(Trim(Nz(Me!DateiPfadNeu))) > 0 Then
    If Not BinExport("___Vorlagen_einlesen", Me!DateiPfadNeu, "Picture", i) Then
        MsgBox "Fehler beim speichern"
    Else
        MsgBox "Datei " & Me!DateiPfadNeu & " erzeugt"
        sPath = Left(Me!DateiPfadNeu, Len(Me!DateiPfadNeu) - Len(Dir(Me!DateiPfadNeu)))
    End If
Else
    MsgBox "Fehlerhafte Eingabewerte"
End If

'Function BinExport(tabelle As String, PfadDatei As String, BinaryFeld As String, IDNr As Long)

' Ein OLE-Object eines Tabellenfeldes in eine Datei exportieren

'Autor: Günther Ritter  www.ostfrieslandweb.de

' tabelle    = Tabellenname
' PfadDatei  = Dateiname incl. Pfad
' BinaryFeld = Name des OLE-Object Feldes
' IDNr       = ID-Nummer des Datensatzes der Tabelle

'Achtung, absolute Feldnamen: ID

'Aufbau der Tabelle _tblPicture:
'-----------------------------
'ID         - Autowert
'BytesAnz   - Zahl / Long Integer
'DateiName  - Memo
'Kurztext   - Text 100
'LangText   - Memo
'Picture    - OLE-Object

End Sub
