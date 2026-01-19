Option Compare Database
Option Explicit
' vraschke@t-online.de

'16 bit
'Private Type RECT
'    left As Integer
'    top As Integer
'    right As Integer
'    bottom As Integer
'End Type
'
'Private Declare PtrSafe Sub GetWindowRect Lib "User" (ByVal hWnd As Integer, lpRect As RECT)
'Private Declare PtrSafe Function GetParent Lib "User" (ByVal hWnd As Integer) As Integer
'Private Declare PtrSafe Sub MoveWindow Lib "User" (ByVal hWnd As Integer, ByVal X As Integer, ByVal Y As Integer, ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal bRepaint As Integer)

'32 bit
Private Type RECT
        Left As Long
        Top As Long
        Right As Long
        Bottom As Long
End Type

Private Declare PtrSafe Function GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long
Private Declare PtrSafe Function GetParent Lib "user32" (ByVal hwnd As Long) As Long
Private Declare PtrSafe Function MoveWindow Lib "user32" (ByVal hwnd As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal bRepaint As Long) As Long

Public Function PosSpeichern(FormObject As Form) As Boolean
' Speichert die Fensterkoordinaten des angegebenen Formulars in die Tabelle tblFensterpositionen
On Error GoTo Err_Speichern

    Dim rectForm As RECT
    Dim hwndParent As Long
    Dim rectParent As RECT
    Dim db As DAO.Database
    Dim rstFensterPos As DAO.Recordset
    
    ' Koordinaten des Formulars ermitteln
    GetWindowRect FormObject.hwnd, rectForm

    ' Koordinaten des Parent-Fensters ermitteln
    hwndParent = GetParent(FormObject.hwnd)
    
    If hwndParent <> Application.hWndAccessApp Then
    ' Ist das Formular gebunden, so ist das Parent-Fenster nicht das Access-Fenster.
    ' In diesem Fall müssen wir die Parent-Koordinaten abschneiden
    
        GetWindowRect hwndParent, rectParent
        rectForm.Left = rectForm.Left - rectParent.Left
        rectForm.Top = rectForm.Top - rectParent.Top
        rectForm.Right = rectForm.Right - rectParent.Left
        rectForm.Bottom = rectForm.Bottom - rectParent.Top
    
    End If
    
    ' Koordinaten in Tabelle speichern
    Set db = CurrentDb
    Set rstFensterPos = db.OpenRecordset("SELECT * FROM tblFensterpositionen WHERE FormName='" & _
                            FormObject.Name & "';", dbOpenDynaset)
    
    With rstFensterPos
        If .RecordCount = 0 Then
            .AddNew
            !formName = FormObject.Name
        Else
            .Edit
        End If
            
        !Left = rectForm.Left
        !Top = rectForm.Top
        !Right = rectForm.Right
        !Bottom = rectForm.Bottom
        
        .update
        .Close
    End With

    PosSpeichern = True

Exit_Speichern:
    Exit Function
    
Err_Speichern:
    PosSpeichern = False
    Resume Exit_Speichern
    
End Function

' --------------------------------------------
'Jörg Ackermann meinte zu PosWiederherstellen:
'
'kleines Fehlerchen entdeckt:
'
'mdlFensterpos_PosWiederherstellen()
'
'-------------------------------------------
' ' Breite und Höhe des Fensters ermitteln
'    lBreite = rectForm.Right - rectForm.Left
'    lHöhe = rectForm.Bottom - rectForm.Top
'-------------------------------------------
'
'dieser Abschnitt gehört nach unten, macht erst Sinn,
'nachdem Koordinaten aus Tabelle gelesen wurden, da
'sonst die Fenster-Breite u. -Höhe zwar ausgelesen,
'aber nicht angepaßt wird.
'
'Man könnte in dieser Function noch so einige Zeilen sparen...
'
'    If hwndParent <> Application.hWndAccessApp Then
'    ' Ist das Formular gebunden, so ist das Parent-Fenster nicht das Access-Fenster.
'    ' In diesem Fall müssen wir die Parent-Koordinaten abschneiden
'
'        GetWindowRect hwndParent, rectParent
'        rectForm.Left = rectForm.Left - rectParent.Left
'        rectForm.Top = rectForm.Top - rectParent.Top
'        rectForm.Right = rectForm.Right - rectParent.Left
'        rectForm.Bottom = rectForm.Bottom - rectParent.Top
'
'    End If
'
'ist unnötig !
'
'
'
'
' --------------------------------------------

Public Function PosWiederherstellen(FormObject As Form) As Boolean
' Liest die Koordinaten des angegebenen Formulars ein und verschiebt das Formular
On Error GoTo Err_Wiederherstellen

    Dim db As DAO.Database
    Dim rstFensterPos As DAO.Recordset
    Dim rectForm As RECT
    Dim hwndParent As Long
    Dim rectParent As RECT
    Dim lBreite As Long
    Dim lHöhe As Long
    
    ' Koordinaten des Formulars ermitteln
    GetWindowRect FormObject.hwnd, rectForm
    
    ' Koordinaten des Parent-Fensters ermitteln
    hwndParent = GetParent(FormObject.hwnd)
    
    If hwndParent <> Application.hWndAccessApp Then
    ' Ist das Formular gebunden, so ist das Parent-Fenster nicht das Access-Fenster.
    ' In diesem Fall müssen wir die Parent-Koordinaten abschneiden
    
        GetWindowRect hwndParent, rectParent
        rectForm.Left = rectForm.Left - rectParent.Left
        rectForm.Top = rectForm.Top - rectParent.Top
        rectForm.Right = rectForm.Right - rectParent.Left
        rectForm.Bottom = rectForm.Bottom - rectParent.Top
    
    End If
    
    ' Breite und Höhe des Fensters ermitteln
    lBreite = rectForm.Right - rectForm.Left
    lHöhe = rectForm.Bottom - rectForm.Top
    
    ' Koordinaten aus Tabelle einlesen
    Set db = CurrentDb
    Set rstFensterPos = db.OpenRecordset("SELECT * FROM tblFensterpositionen WHERE FormName='" & _
                                FormObject.Name & "';", dbOpenSnapshot)

    With rstFensterPos
        If .BOF And .EOF Then
            PosWiederherstellen = False
            Exit Function
        End If
            
        rectForm.Left = !Left
        rectForm.Top = !Top
        rectForm.Right = !Right
        rectForm.Bottom = !Bottom
        
        .Close
    End With

    ' Formular verschieben
    MoveWindow FormObject.hwnd, rectForm.Left, rectForm.Top, lBreite, lHöhe, True
    
Exit_Wiederherstellen:
    Exit Function
    
Err_Wiederherstellen:
    PosWiederherstellen = False
    Resume Exit_Wiederherstellen

End Function



Function FensterVerschieb(FormObject As Form, Optional iLinks As Long = 100, Optional iTop As Long = 100)

    Dim rectForm As RECT
    
    GetWindowRect FormObject.hwnd, rectForm
    
    rectForm.Left = rectForm.Left + iLinks
    rectForm.Top = rectForm.Top + iTop

    MoveWindow FormObject.hwnd, rectForm.Left, rectForm.Top, rectForm.Right, rectForm.Bottom, True

End Function