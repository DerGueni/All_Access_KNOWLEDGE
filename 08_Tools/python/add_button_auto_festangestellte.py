#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Button für Auto-Festangestellte hinzufügen
Fügt Button zu frm_menuefuehrung1 hinzu
"""

import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client
from win32com.client import constants

def add_button_to_form():
    """Fügt Button zu frm_menuefuehrung1 hinzu"""
    
    db_path = r'C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb'
    form_name = 'frm_menuefuehrung1'
    button_name = 'cmd_Auto_Festangestellte'
    
    print("=== Button hinzufügen: cmd_Auto_Festangestellte ===\n")
    
    try:
        # Access öffnen
        print("Öffne Access...")
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = False
        access.OpenCurrentDatabase(db_path)
        
        # Formular in Entwurfsansicht öffnen
        print(f"Öffne Formular '{form_name}' in Entwurfsansicht...")
        access.DoCmd.OpenForm(form_name, 2)  # 2 = acDesign
        
        form = access.Forms(form_name)
        
        # Prüfe ob Button bereits existiert
        button_exists = False
        for ctrl in form.Controls:
            if ctrl.Name == button_name:
                button_exists = True
                print(f"Button '{button_name}' existiert bereits - wird aktualisiert...")
                break
        
        if not button_exists:
            # Button erstellen
            print(f"Erstelle Button '{button_name}'...")
            button = access.CreateControl(
                form_name,
                2,  # acCommandButton
                None,  # Section
                None,  # Parent
                None,  # ColumnName
                50,    # Left (Twips)
                50,    # Top
                2000,  # Width
                400    # Height
            )
            button.Name = button_name
        else:
            # Bestehenden Button holen
            button = form.Controls(button_name)
        
        # Button-Eigenschaften setzen
        button.Caption = "Auto-Zuweisung Festangestellte"
        
        # VBA-Code für Click-Event
        vba_code = '''Private Sub cmd_Auto_Festangestellte_Click()
    On Error GoTo Err_Handler
    
    If MsgBox("Festangestellte Mitarbeiter automatisch zuordnen für:" & vbCrLf & vbCrLf & _
              "• 1. FC Nürnberg" & vbCrLf & _
              "• SpVgg Greuther Fürth" & vbCrLf & _
              "• HC Erlangen" & vbCrLf & _
              "• Löwensaal" & vbCrLf & vbCrLf & _
              "Zeitraum: Nächste 20 Tage" & vbCrLf & vbCrLf & _
              "Fortfahren?", _
              vbYesNo + vbQuestion, "Auto-Zuordnung Festangestellte") = vbYes Then
        
        Call Auto_Festangestellte_Zuordnen
        
    End If
    
    Exit Sub
    
Err_Handler:
    MsgBox "Fehler beim Starten der Auto-Zuordnung: " & Err.Description, vbCritical
End Sub'''
        
        # Code zum Formular-Modul hinzufügen
        print("Füge VBA-Code für Click-Event hinzu...")
        form_module = form.Module
        
        # Prüfe ob Event-Prozedur existiert
        proc_name = f"{button_name}_Click"
        proc_exists = False
        
        for i in range(1, form_module.CountOfLines + 1):
            line = form_module.Lines(i, 1)
            if proc_name in line and "Sub" in line:
                proc_exists = True
                # Lösche alte Prozedur
                proc_line = form_module.ProcBodyLine(proc_name, 0)
                proc_count = form_module.ProcCountLines(proc_name, 0)
                form_module.DeleteLines(proc_line, proc_count)
                break
        
        # Füge neue Prozedur hinzu
        line_count = form_module.CountOfLines
        form_module.InsertLines(line_count + 1, vba_code)
        
        # OnClick-Eigenschaft setzen
        button.OnClick = f"[Event Procedure]"
        
        print(f"✓ Button '{button_name}' erfolgreich hinzugefügt!\n")
        
        # Formular speichern und schließen
        print("Speichere Formular...")
        access.DoCmd.Close(2, form_name, 1)  # 2 = acForm, 1 = acSaveYes
        
        # Access schließen
        access.CloseCurrentDatabase()
        access.Quit()
        
        print("\n=== Button erfolgreich hinzugefügt ===")
        print(f"\nButton befindet sich in Formular '{form_name}'")
        print("Beschriftung: 'Auto-Zuweisung Festangestellte'")
        
        return True
        
    except Exception as e:
        print(f"\n✗ Fehler: {e}")
        if 'access' in locals():
            try:
                access.Quit()
            except:
                pass
        return False

if __name__ == '__main__':
    success = add_button_to_form()
    sys.exit(0 if success else 1)
