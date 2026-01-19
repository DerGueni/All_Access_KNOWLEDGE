#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetTitleMatchMode 2

overrides := "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\css\visbug_overrides.css"

^!s::
{
    clipSaved := A_Clipboard
    A_Clipboard := ""

    ; DevTools öffnen
    Send "{F12}"
    Sleep 450

    ; Command Menu öffnen
    Send "^+p"
    Sleep 250

    ; "Show Changes" suchen/öffnen
    Send "changes"
    Sleep 250
    Send "{Enter}"
    Sleep 500

    ; Alles kopieren
    Send "^a"
    Sleep 120
    Send "^c"
    Sleep 350

    txt := A_Clipboard

    ; Sicherheitscheck: nur speichern, wenn es nach CSS aussieht
    if (InStr(txt, "{") && InStr(txt, "}"))
    {
        try FileDelete overrides
        catch

        FileAppend txt, overrides, "UTF-8"
        SoundBeep 750, 120
        TrayTip "VisBug Save", "Overrides gespeichert:
" overrides, 2
    }
    else
    {
        SoundBeep 300, 180
        TrayTip "VisBug Save", "Nichts gespeichert  Clipboard sah nicht nach CSS aus.", 3
    }

    A_Clipboard := clipSaved
}

^!o::
{
    Run overrides
}
