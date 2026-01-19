Option Compare Database
Option Explicit

' Dialog aus einer Newsgroup:

'Wenn wir aber von "Otto Normalanwender" reden, so gibt es neben der
'Verschlüsselung und Paßwortabfrage noch eine weitere Variante, die den
'Datenklau zumindest ganz erheblich erschwert:
'
'Wie man die Benutzung der Shift-Taste beim Start und damit die
'Umgehung des Autoexec-Makros verhindern kann, ist ja sicherlich
'mittlerweile hinreichend bekannt. (Siehe mdlProperties)
'Ich frage dann beim Aufstarten von Access auf die Seriennummer der
'Festplatte ab.
'Mit anderen Worten:
'Selbst wenn ein ungetreuer Mitarbeiter die Datenbank nebst System.mdw
'und  Paßwort weitergibt, würde das Programm auf einem anderen Rechner
'nicht laufen.
'Ich habe bisher allerdings noch nicht rausbekommen, wie man auf die
'Seriennummer des Prozessors abfragen kann. Das wäre eine zusätzlich
'Sicherheit.
'Wer dazu die entsprechenden API-Aufrufe kennt, sollte sie hier doch
'einmal in die Newsgroup stellen, sofern er mag.
'
'Juergen
'
'Nachstehend der Code für die Festplattennummer
'Autor: unbekannt
'Vor längerer Zeit einmal in einer englischen Access-Newsgroup gefunden
'

Private Declare PtrSafe Function GetVolumeInformation Lib "kernel32" Alias _
"GetVolumeInformationA" (ByVal lpRootPathName As String, ByVal _
lpVolumeNameBuffer As String, ByVal nVolumeNameSize As Long, _
lpVolumeSerialNumber As Long, lpMaximumComponentLenght As Long, _
lpFileSystemFlags As Long, ByVal lpFileSystemNameBuffer As String, _
ByVal nFileSystemNameSize As Long) As Long

' Wie kann ich feststellen, in welchen Format die Festplatte ist (NTFS, FAT, FAT32)
'
'In lpFileSystemNameBuffer kriegst du das Gesuchte zurück. Nicht vergessen:
'diesen Parameter ebenso wie VolumeNameBuffer vorher mit Speicherplatz
'versorgen (lpFileSystemNameBuffer = Space$(x)).


Function VolSerialNoTest()
' Testet, ob die Seriennummer mit der fest einprogrammierten Seriennummer
' übereinstimmt

Dim lpRootPathName As String
Dim IngRet As Long
Dim lpVolumeNameBuffer As String
Dim nVolumeNameSize As Long
Dim lpVolumeSerialNumber As Long
Dim lpMaximumComponentLenght As Long
Dim lpFileSystemFlags As Long
Dim lpFileSystemNameBuffer As String
Dim nFileSystemNameSize As Long
Dim answer As Integer

lpVolumeNameBuffer = Space$(254)
lpFileSystemNameBuffer = Space$(254)
nVolumeNameSize = 254
nFileSystemNameSize = 254

lpRootPathName = "C:\"
IngRet = GetVolumeInformation(lpRootPathName, lpVolumeNameBuffer, _
nVolumeNameSize, lpVolumeSerialNumber, lpMaximumComponentLenght, _
lpFileSystemFlags, lpFileSystemNameBuffer, nFileSystemNameSize)

Rem für 11111 ist die Seriennummer einzusetzen

If IngRet <> 0 Then
   If lpVolumeSerialNumber <> 11111 Then
       answer = MsgBox("Sie haben keine Berechtigung dieses Programm " & _
"auf diesem Computer auszuführen.", vbExclamation, "Hinweis !")
       DoCmd.Quit
   End If
End If

End Function


Function VolSerialNoErm(Optional lpRootPathName As String = "C:\", Optional Deci As Boolean = False)

' Seriennummer eines Laufwerks ermitteln
' Laufwerk übergeben. Wenn Deci = False, dann wird ein Hex-Wert mit
' Bindestrich in der Mitte z.B.: "2AB1-1234" zurückgegeben
' Bei Deci = True wird der Dezimalwert zurückgegeben.
' LpRootPathName ist der Laufwerksbuchstabe z.B. "C:\"
' 21.02.1998 Ober

Dim IngRet As Long
Dim lpVolumeNameBuffer As String
Dim nVolumeNameSize As Long
Dim lpVolumeSerialNumber As Long
Dim lpMaximumComponentLenght As Long
Dim lpFileSystemFlags As Long
Dim lpFileSystemNameBuffer As String
Dim nFileSystemNameSize As Long
Dim answer As Integer
Dim tmp1 As String

lpVolumeNameBuffer = Space$(254)
lpFileSystemNameBuffer = Space$(254)

nVolumeNameSize = 254
nFileSystemNameSize = 254

IngRet = GetVolumeInformation(lpRootPathName, lpVolumeNameBuffer, _
nVolumeNameSize, lpVolumeSerialNumber, lpMaximumComponentLenght, _
lpFileSystemFlags, lpFileSystemNameBuffer, nFileSystemNameSize)

If Deci Then
    VolSerialNoErm = lpVolumeSerialNumber
Else
   tmp1 = Right("00000000" & Hex(lpVolumeSerialNumber), 8)
   VolSerialNoErm = Left(tmp1, 4) & "-" & Right(tmp1, 4)
End If

End Function