"""
Fix fehlende Funktion DP_Dashboard_Oeffnen_MitAuftrag
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
import pythoncom
import time

# Die fehlende Funktion die hinzugefügt werden muss
MISSING_FUNCTION = '''

Public Sub DP_Dashboard_Oeffnen_MitAuftrag(Optional VA_ID As Long = 0)
    DoCmd.OpenForm "frm_N_DP_Dashboard", acNormal
    If VA_ID > 0 Then
        On Error Resume Next
        Forms!frm_N_DP_Dashboard!sub_lstAuftrag.Form.Recordset.FindFirst "VA_ID = " & VA_ID
        On Error GoTo 0
    End If
End Sub
'''

print("=" * 70)
print("FIX FEHLENDE FUNKTION")
print("=" * 70)

try:
    pythoncom.CoInitialize()

    app = win32com.client.GetObject(Class="Access.Application")
    print("[OK] Access verbunden")

    vbe = app.VBE
    proj = vbe.ActiveVBProject

    # mod_N_DP_Dashboard finden
    for comp in proj.VBComponents:
        if comp.Name == "mod_N_DP_Dashboard":
            cm = comp.CodeModule

            # Prüfen ob die Funktion bereits existiert
            existing_code = ""
            if cm.CountOfLines > 0:
                existing_code = cm.Lines(1, cm.CountOfLines)

            if "DP_Dashboard_Oeffnen_MitAuftrag" not in existing_code:
                # Funktion am Ende hinzufügen
                cm.InsertLines(cm.CountOfLines + 1, MISSING_FUNCTION)
                print("[OK] DP_Dashboard_Oeffnen_MitAuftrag hinzugefuegt")
            else:
                print("[INFO] Funktion existiert bereits")
            break
    else:
        print("[!] mod_N_DP_Dashboard nicht gefunden")

    print("\n" + "=" * 70)
    print("[OK] FERTIG - Bitte VBA-Editor schliessen und neu kompilieren")
    print("=" * 70)

except Exception as e:
    print(f"\n[!] FEHLER: {e}")
    import traceback
    traceback.print_exc()

finally:
    pythoncom.CoUninitialize()
