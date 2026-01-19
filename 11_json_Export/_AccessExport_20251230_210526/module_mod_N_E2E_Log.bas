Option Compare Database
Option Explicit

' ============================================
' mod_N_E2E_Log - End-to-End Test Logging
' Schreibt JSON Lines in runtime_logs/e2e.jsonl
' ============================================

Private Const LOG_PATH As String = "C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\e2e.jsonl"

Private m_RunId As String

' Erzeugt eine neue Run-ID
Public Function E2E_NewRunId() As String
    m_RunId = Format(Now, "yyyymmdd_hhnnss") & "_" & Right(CStr(Timer * 1000), 4)
    E2E_NewRunId = m_RunId
End Function

' Gibt aktuelle Run-ID zurueck
Public Function E2E_GetRunId() As String
    If m_RunId = "" Then E2E_NewRunId
    E2E_GetRunId = m_RunId
End Function

' Schreibt einen Log-Eintrag
Public Sub E2E_Log(action As String, Optional details As String = "")
    On Error Resume Next

    Dim fso As Object
    Dim ts As Object
    Dim jsonLine As String
    Dim timestamp As String

    If m_RunId = "" Then E2E_NewRunId

    timestamp = Format(Now, "yyyy-mm-dd hh:nn:ss.") & Right(Format(Timer, "0.000"), 3)

    ' JSON Line erstellen
    jsonLine = "{""ts"":""" & timestamp & """,""run_id"":""" & m_RunId & """,""action"":""" & action & """"
    If details <> "" Then
        jsonLine = jsonLine & ",""details"":""" & Replace(Replace(details, "\", "\\"), """", "\""") & """"
    End If
    jsonLine = jsonLine & "}"

    ' In Datei schreiben
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set ts = fso.OpenTextFile(LOG_PATH, 8, True) ' 8 = ForAppending, True = Create if not exists
    ts.WriteLine jsonLine
    ts.Close

    ' Auch ins Debug-Fenster
    Debug.Print "[E2E] " & action & " | " & details

    Set ts = Nothing
    Set fso = Nothing
End Sub

' Loggt Button-Klick
Public Sub E2E_LogButtonClick(formName As String, controlName As String, expectedTarget As String)
    E2E_Log "BUTTON_CLICK", "form=" & formName & "|control=" & controlName & "|expected_target=" & expectedTarget
End Sub

' Loggt Navigate-Request
Public Sub E2E_LogNavigateRequest(targetUrl As String, method As String)
    E2E_Log "NAVIGATE_REQUEST", "target_url=" & targetUrl & "|method=" & method
End Sub

' Loggt Navigate-Dispatched
Public Sub E2E_LogNavigateDispatched(success As Boolean, Optional errorMsg As String = "")
    If success Then
        E2E_Log "NAVIGATE_DISPATCHED", "status=SUCCESS"
    Else
        E2E_Log "NAVIGATE_DISPATCHED", "status=FAIL|error=" & errorMsg
    End If
End Sub

' Loggt erkannte Betriebsart
Public Sub E2E_LogBetriebsart(art As String)
    E2E_Log "BETRIEBSART_ERKANNT", art
End Sub