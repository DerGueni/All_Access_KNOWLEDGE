# -*- coding: utf-8 -*-
"""
Fuegt "HTML Ansicht" Buttons zu Access-Formularen hinzu
=======================================================
Verwendet die Access Bridge um Buttons programmatisch hinzuzufuegen
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from access_bridge_ultimate import AccessBridge
except ImportError:
    print("[!] access_bridge_ultimate.py nicht gefunden!")
    sys.exit(1)

# Mapping: Access-Formularname -> HTML-Dateiname
FORM_MAPPING = {
    "frm_N_Kundenstammblatt": "frm_N_Kundenstammblatt.html",
    "frm_N_Mitarbeiterstammblatt": "frm_N_Mitarbeiterstammblatt.html",
    "frm_N_Abwesenheitsplanung": "frm_N_Abwesenheitsplanung.html",
    "frm_N_Abwesenheitsstatistik": "frm_N_Abwesenheitsstatistik.html",
    "frm_N_Dienstplanuebersicht": "frm_N_Dienstplanuebersicht.html",
    "frm_N_Mitarbeiterauswahl": "frm_N_Mitarbeiterauswahl.html",
    "frm_VA_Auftragstamm": "frm_VA_Auftragstamm_HTML.html",
    "frm_N_Planungsuebersicht": "frm_N_Planungsuebersicht.html",
    "frm_N_Bewerberverwaltung": "frm_N_Bewerberverwaltung.html",
}

# VBA-Code fuer das Form-Modul (wird zum Klassenmodul des Formulars hinzugefuegt)
FORM_VBA_CODE = '''
' ============================================
' HTML ANSICHT BUTTON - Auto-generiert
' ============================================

Private Sub btnHTMLAnsicht_Click()
    ' Wechselt zur HTML-Ansicht des Formulars
    Call HTML_Ansicht_Zeigen(Me)
End Sub

' WebBrowser Event Handler (falls vorhanden)
Private Sub ctlHTMLOverlay_BeforeNavigate2(ByVal pDisp As Object, URL As Variant, Flags As Variant, TargetFrameName As Variant, PostData As Variant, Headers As Variant, Cancel As Boolean)
    ' Pruefe auf ACCESS_ANSICHT Nachricht
    If InStr(CStr(URL), "ACCESS_ANSICHT") > 0 Then
        Cancel = True
        Call HTML_Ansicht_Schliessen(Me)
    End If
End Sub
'''


def main():
    print("=" * 60)
    print("HTML ANSICHT BUTTONS ZU ACCESS-FORMULAREN HINZUFUEGEN")
    print("=" * 60)
    print("")
    print("HINWEIS: Diese Funktion erfordert dass die Formulare")
    print("         in der Entwurfsansicht geoeffnet werden.")
    print("")
    print("Da Access dies nicht gut automatisiert unterstuetzt,")
    print("hier die manuelle Anleitung:")
    print("")
    print("-" * 60)
    print("")

    for form_name, html_file in FORM_MAPPING.items():
        print(f"FORMULAR: {form_name}")
        print(f"  HTML: {html_file}")
        print("")
        print("  1. Formular in Entwurfsansicht oeffnen")
        print("  2. Button einfuegen:")
        print("     - Position: Oben rechts im Formularkopf")
        print("     - Name: btnHTMLAnsicht")
        print("     - Beschriftung: HTML Ansicht")
        print("     - Hintergrundfarbe: #4169E1 (Royalblau)")
        print("     - Schriftfarbe: Weiss")
        print("  3. Bei Klick (OnClick) einfuegen:")
        print("     =HTML_Ansicht_Button_Click([Form])")
        print("")
        print("  Optional fuer nahtloses Overlay:")
        print("  4. ActiveX-Control einfuegen: Microsoft Web Browser")
        print("     - Name: ctlHTMLOverlay")
        print("     - Sichtbar: Nein")
        print("     - Groesse: Gesamtes Formular")
        print("")
        print("-" * 60)
        print("")

    print("")
    print("ALTERNATIVE: Button mit VBA erstellen")
    print("-" * 60)
    print("Im VBA-Editor (Alt+F11) im Direktfenster (Strg+G) ausfuehren:")
    print("")
    print("  HTML_Setup_ButtonHinzufuegen \"frm_N_Kundenstammblatt\"")
    print("")
    print("Dies erstellt automatisch einen Button im angegebenen Formular.")
    print("ACHTUNG: Formular muss geschlossen sein!")
    print("")
    print("=" * 60)

    # Versuche automatisch Buttons hinzuzufuegen
    print("")
    print("Versuche automatische Button-Erstellung...")
    print("")

    try:
        with AccessBridge() as bridge:
            existing_forms = bridge.list_forms()

            for form_name in FORM_MAPPING.keys():
                if form_name in existing_forms:
                    print(f"  [i] Formular '{form_name}' existiert")
                    # Hinweis: Automatisches Button-Hinzufuegen ist komplex
                    # da das Formular in Entwurfsansicht geoeffnet werden muss
                else:
                    print(f"  [!] Formular '{form_name}' nicht gefunden")

    except Exception as e:
        print(f"[!] Fehler bei Access-Verbindung: {e}")

    print("")
    print("=" * 60)
    print("FERTIG - Bitte Buttons manuell wie oben beschrieben hinzufuegen")
    print("=" * 60)


if __name__ == "__main__":
    main()
