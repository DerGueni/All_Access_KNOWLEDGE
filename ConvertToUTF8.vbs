' ConvertToUTF8.vbs - Konvertiert die Export-Dateien zu UTF-8
Option Explicit

Dim fso, folder, file, exportPath
Dim files(3)

exportPath = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\exports\"
files(0) = "MASTER_INDEX.json"
files(1) = "BUTTON_LOOKUP.json"
files(2) = "VBA_EVENT_MAP.json"
files(3) = "FORM_DETAIL_INDEX.json"

Set fso = CreateObject("Scripting.FileSystemObject")

Dim i, filePath, content
For i = 0 To 3
    filePath = exportPath & files(i)
    If fso.FileExists(filePath) Then
        content = ReadUTF16(filePath)
        content = Replace(content, "wahr", "true")
        content = Replace(content, "falsch", "false")
        content = Replace(content, "Wahr", "true")
        content = Replace(content, "Falsch", "false")
        WriteUTF8 filePath, content
        WScript.Echo "Konvertiert: " & files(i)
    End If
Next

WScript.Echo "Fertig!"

Function ReadUTF16(path)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2
    stream.Charset = "Unicode"
    stream.Open
    stream.LoadFromFile path
    ReadUTF16 = stream.ReadText
    stream.Close
End Function

Sub WriteUTF8(path, content)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2
    stream.Charset = "UTF-8"
    stream.Open
    stream.WriteText content
    stream.SaveToFile path, 2
    stream.Close
End Sub
