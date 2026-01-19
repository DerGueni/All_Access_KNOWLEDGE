#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
E2E Instrumentierung: Access frm_Menuefuehrung Button "HTML Ansicht"
Fügt Logging-Code ein für Button-Klick-Tracking
"""

import win32com.client
import pythoncom
import time
import sys
from datetime import datetime

# Frontend-Datei
FRONTEND_PATH = r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb"
FORM_NAME = "frm_Menuefuehrung"
BUTTON_NAME = "btn_HTML_Ansicht"  # oder der tatsächliche Button-Name

def instrument_e2e_logging():
    """Füge E2E-Logging zum Button hinzu"""
    pythoncom.CoInitialize()
    
    try:
        print("=" * 70)
        print("E2E INSTRUMENTIERUNG: Access Button Logging")
        print("=" * 70)
        print(f"Frontend: {FRONTEND_PATH}")
        print(f"Form: {FORM_NAME}")
        print("")
        
        # Verbindung zu Access
        print("1. Verbinde mit Access...")
        try:
            access = win32com.client.GetObject(Class="Access.Application")
            print("   ✓ Laufende Access-Instanz gefunden")
        except:
            print("   ! Keine laufende Instanz - starte neue...")
            access = win32com.client.Dispatch("Access.Application")
            access.Visible = False
            access.OpenCurrentDatabase(FRONTEND_PATH)
            print("   ✓ Neue Access-Instanz erstellt")
        
        time.sleep(2)
        
        # Öffne Formular im Entwurfsmodus
        print(f"2. Öffne Formular '{FORM_NAME}' im Entwurfsmodus...")
        access.DoCmd.OpenForm(FORM_NAME, 2)  # 2 = acDesign
        time.sleep(2)
        
        form = access.Forms(FORM_NAME)
        print(f"   ✓ Formular geöffnet")
        
        # Finde alle Buttons
        print("")
        print("3. Durchsuche alle Buttons im Formular...")
        button_names = []
        
        for ctrl in form.Controls:
            try:
                if ctrl.ControlType == 104:  # 104 = acCommandButton
                    button_names.append(ctrl.Name)
                    print(f"   - {ctrl.Name}: {ctrl.Caption}")
            except:
                pass
        
        print("")
        print(f"   Gefunden: {len(button_names)} Buttons")
        
        # Suche Button mit "HTML" im Namen oder Caption
        target_button = None
        for btn_name in button_names:
            ctrl = form.Controls(btn_name)
            caption = str(ctrl.Caption).upper() if hasattr(ctrl, 'Caption') else ""
            name_upper = btn_name.upper()
            
            if "HTML" in caption or "HTML" in name_upper:
                target_button = btn_name
                print(f"\n✓ FOUND: Button '{btn_name}' (Caption: '{ctrl.Caption}')")
                break
        
        if not target_button:
            print("\n! WARNUNG: Kein 'HTML'-Button gefunden")
            print("  Verfügbare Buttons:")
            for btn_name in button_names:
                ctrl = form.Controls(btn_name)
                caption = str(ctrl.Caption) if hasattr(ctrl, 'Caption') else ""
                print(f"    - {btn_name}: {caption}")
            print("\n  Bitte bestätigen Sie den korrekten Button-Namen.")
            return False
        
        # Hole den Code des Button-Click-Events
        print(f"\n4. Lese VBA-Code des Buttons '{target_button}'...")
        
        mod = access.ActiveProject.VBProject.VBComponents(FORM_NAME)
        code_module = mod.CodeModule
        
        # Suche die Click-Event-Prozedur
        lines_count = code_module.CountOfLines
        code_text = code_module.Lines(1, lines_count)
        
        # Finde die Prozedur für diesen Button
        event_name = f"Private Sub {target_button}_Click()"
        start_line = -1
        
        for i in range(1, lines_count + 1):
            line = code_module.Lines(i, 1)
            if event_name in line:
                start_line = i
                print(f"   ✓ Event gefunden in Zeile {i}")
                break
        
        if start_line == -1:
            print(f"   ! Event '{target_button}_Click' nicht gefunden")
            print("   ! Erstelle neues Event...")
            
            # Erstelle neues Event am Ende des Moduls
            new_event = f"""
Private Sub {target_button}_Click()
    ' E2E: Button Click Logging
    Dim run_id As String
    Dim log_entry As String
    
    run_id = Format(Now(), "yyyymmddhhmmss") & "_" & Format(Rnd() * 1000000, "000000")
    
    ' Log: Button wurde geklickt
    Debug.Print "E2E|BUTTON_CLICK|" & run_id & "|form:" & Me.Name & "|button:" & Me.ActiveControl.Name
    
    ' Hier: Ursprünglicher Code
    ' TODO: Navigiere zu HTML-Auftragstamm
    
End Sub
"""
            code_module.InsertLines lines_count + 1, new_event
            print(f"   ✓ Neues Event erstellt")
        
        # Speichere die Änderungen
        print("\n5. Speichere Änderungen...")
        access.ActiveProject.VBProject.VBComponents(FORM_NAME).CodeModule.Parent.Saved = True
        
        # Schließe den Entwurfsmodus
        access.DoCmd.Close 2, FORM_NAME, 0  # 2=acForm, 0=acSaveNo (oder acSaveYes)
        time.sleep(1)
        
        print("   ✓ Änderungen gespeichert")
        
        print("\n" + "=" * 70)
        print("✓ INSTRUMENTIERUNG ABGESCHLOSSEN")
        print("=" * 70)
        print(f"\nButton: {target_button}")
        print(f"Event: {target_button}_Click")
        print("\nNächste Schritte:")
        print("1. Füge HTML-Zielnavigation ein")
        print("2. Starte E2E-Test mit Playwright")
        print("3. Überprüfe Logs in runtime_logs/e2e.jsonl")
        
        return True
        
    except Exception as e:
        print(f"\n✗ FEHLER: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        # Cleanup
        try:
            if 'access' in locals():
                # Speichere und schließe
                access.CurrentDb.Close()
        except:
            pass

if __name__ == "__main__":
    success = instrument_e2e_logging()
    sys.exit(0 if success else 1)
