# -*- coding: utf-8 -*-
"""
HTML Preload Modul fuer Access installieren
Oeffnet beim Access-Start automatisch alle HTML-Formulare im Browser (minimiert)
"""

import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

# Liste aller Hauptformulare (frm_*), keine Subformulare
MAIN_FORMS = [
    "frm_N_Dienstplanuebersicht.html",
    "frm_VA_Planungsuebersicht.html",
    "frm_va_Auftragstamm.html",
    "frm_MA_Mitarbeiterstamm.html",
    "frm_MA_Abwesenheit.html",
    "frm_KD_Kundenstamm.html",
    "frm_MA_Zeitkonten.html",
    "frm_Ausweis_Create.html",
    "frm_Einsatzuebersicht.html",
    "frm_OB_Objekt.html",
    "frm_N_Lohnabrechnungen.html",
    "frm_N_Mitarbeiterauswahl.html",
    "frm_N_Stundenauswertung.html",
    "frm_N_Email_versenden.html",
    "frm_N_AuswahlMaster.html",
    "frm_DP_Dienstplan_Objekt.html",
    "frm_DP_Dienstplan_MA.html",
    "index.html"
]

# VBA Code fuer HTML Preload
VBA_CODE = '''
' ============================================
' mod_N_HTML_Preload
' Laedt alle HTML-Formulare beim Access-Start
' im Browser vor (minimiert im Hintergrund)
' ============================================

Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
    ByVal hwnd As LongPtr, _
    ByVal lpOperation As String, _
    ByVal lpFile As String, _
    ByVal lpParameters As String, _
    ByVal lpDirectory As String, _
    ByVal nShowCmd As Long) As LongPtr

Private Const SW_SHOWMINIMIZED As Long = 2
Private Const SW_HIDE As Long = 0

Public Sub AutoExec_HTML_Preload()
    ' Wird beim Oeffnen der Datenbank automatisch ausgefuehrt
    ' Oeffnet alle HTML-Formulare im minimiertem Browser

    On Error Resume Next

    Dim htmlPath As String
    Dim forms As Variant
    Dim i As Long

    htmlPath = "C:\\Users\\guenther.siegert\\Documents\\Consys_HTML\\02_web\\forms\\"

    ' Liste der Hauptformulare
    forms = Array( _
        "frm_N_Dienstplanuebersicht.html", _
        "frm_VA_Planungsuebersicht.html", _
        "frm_va_Auftragstamm.html", _
        "frm_MA_Mitarbeiterstamm.html", _
        "frm_MA_Abwesenheit.html", _
        "frm_KD_Kundenstamm.html", _
        "frm_MA_Zeitkonten.html", _
        "frm_Ausweis_Create.html", _
        "frm_Einsatzuebersicht.html", _
        "frm_OB_Objekt.html", _
        "frm_N_Lohnabrechnungen.html", _
        "frm_N_Mitarbeiterauswahl.html", _
        "index.html" _
    )

    ' Oeffne jeden Form minimiert im Standard-Browser
    For i = LBound(forms) To UBound(forms)
        ShellExecute 0, "open", htmlPath & forms(i), vbNullString, vbNullString, SW_SHOWMINIMIZED
        ' Kurze Pause zwischen den Aufrufen
        DoEvents
    Next i

End Sub

Public Sub HTML_Preload_Manuell()
    ' Kann manuell aufgerufen werden um Formulare neu zu laden
    AutoExec_HTML_Preload
End Sub
'''

def main():
    print("=" * 50)
    print("HTML Preload Modul Installation")
    print("=" * 50)

    try:
        with AccessBridge() as bridge:
            # Pruefen ob Modul existiert
            if bridge.module_exists("mod_N_HTML_Preload"):
                print("Modul mod_N_HTML_Preload existiert bereits - wird aktualisiert...")

            # VBA Modul importieren
            print("Importiere mod_N_HTML_Preload...")
            result = bridge.import_vba_module("HTML_Preload", VBA_CODE, auto_prefix=True)
            print(f"Ergebnis: {result}")

            # AutoExec Makro erstellen (falls nicht existiert)
            print("\nHinweis: Fuer automatischen Start muss ein AutoExec-Makro erstellt werden")
            print("oder der Aufruf in einem bestehenden Startformular hinzugefuegt werden.")
            print("\nManueller Aufruf: Call AutoExec_HTML_Preload")

            print("\n" + "=" * 50)
            print("Installation abgeschlossen!")
            print("=" * 50)

    except Exception as e:
        print(f"Fehler: {e}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
