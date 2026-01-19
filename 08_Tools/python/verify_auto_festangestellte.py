#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Prüfung: Auto-Festangestellte Implementation
Verifiziert ob VBA-Modul und Button korrekt erstellt wurden
"""

import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

import win32com.client

def verify_implementation():
    """Prüft ob Implementation erfolgreich war"""
    
    db_path = r'C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb'
    
    print("=" * 60)
    print("VERIFIKATION: Auto-Festangestellte Implementation")
    print("=" * 60)
    print()
    
    results = {
        'modul_exists': False,
        'modul_functions': [],
        'form_exists': False,
        'button_exists': False,
        'button_event': False
    }
    
    try:
        # Access öffnen
        print("📂 Öffne Access-Datenbank...")
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = False
        access.OpenCurrentDatabase(db_path)
        
        # ===== MODUL PRÜFEN =====
        print("\n🔍 Prüfe VBA-Modul...")
        print("-" * 60)
        
        vb_proj = access.VBE.ActiveVBProject
        module_name = 'mdl_Auto_Festangestellte'
        
        for component in vb_proj.VBComponents:
            if component.Name == module_name:
                results['modul_exists'] = True
                print(f"✅ Modul '{module_name}' gefunden")
                
                # Funktionen im Modul prüfen
                code_module = component.CodeModule
                line_count = code_module.CountOfLines
                
                functions_to_check = [
                    'Auto_Festangestellte_Zuordnen',
                    'IstMitarbeiterVerfuegbar',
                    'HatSchichtKapazitaet',
                    'IstBereitsZugeordnet',
                    'MA_Zuordnen'
                ]
                
                for func in functions_to_check:
                    for i in range(1, line_count + 1):
                        line = code_module.Lines(i, 1)
                        if f"Sub {func}" in line or f"Function {func}" in line:
                            results['modul_functions'].append(func)
                            print(f"   ✅ Funktion: {func}")
                            break
                
                print(f"\n   📊 Modul-Statistik:")
                print(f"      - Zeilen: {line_count}")
                print(f"      - Funktionen gefunden: {len(results['modul_functions'])}/5")
                break
        
        if not results['modul_exists']:
            print(f"❌ Modul '{module_name}' NICHT gefunden!")
        
        # ===== FORMULAR PRÜFEN =====
        print("\n🔍 Prüfe Formular...")
        print("-" * 60)
        
        form_name = 'frm_menuefuehrung1'
        button_name = 'cmd_Auto_Festangestellte'
        
        # Prüfe ob Formular existiert
        form_found = False
        for obj in access.CurrentProject.AllForms:
            if obj.Name == form_name:
                form_found = True
                results['form_exists'] = True
                print(f"✅ Formular '{form_name}' gefunden")
                break
        
        if not form_found:
            print(f"❌ Formular '{form_name}' NICHT gefunden!")
        else:
            # Formular öffnen und Button prüfen
            try:
                print(f"\n🔍 Öffne Formular in Entwurfsansicht...")
                access.DoCmd.OpenForm(form_name, 2)  # 2 = acDesign
                form = access.Forms(form_name)
                
                # Button prüfen
                button_found = False
                for ctrl in form.Controls:
                    if ctrl.Name == button_name:
                        button_found = True
                        results['button_exists'] = True
                        print(f"✅ Button '{button_name}' gefunden")
                        print(f"   - Beschriftung: {ctrl.Caption}")
                        print(f"   - Position: Left={ctrl.Left}, Top={ctrl.Top}")
                        print(f"   - Größe: Width={ctrl.Width}, Height={ctrl.Height}")
                        
                        # OnClick-Event prüfen
                        if ctrl.OnClick:
                            print(f"   - OnClick: {ctrl.OnClick}")
                            results['button_event'] = True
                        else:
                            print(f"   ⚠️ OnClick: Nicht gesetzt!")
                        
                        break
                
                if not button_found:
                    print(f"❌ Button '{button_name}' NICHT gefunden!")
                    print("\n📋 Verfügbare Controls im Formular:")
                    for i, ctrl in enumerate(form.Controls):
                        if i < 20:  # Nur erste 20 anzeigen
                            print(f"   - {ctrl.Name} ({ctrl.ControlType})")
                
                # Event-Code im Modul prüfen
                if button_found:
                    print(f"\n🔍 Prüfe Event-Code...")
                    form_module = form.Module
                    
                    event_proc = f"{button_name}_Click"
                    code_found = False
                    
                    for i in range(1, form_module.CountOfLines + 1):
                        line = form_module.Lines(i, 1)
                        if event_proc in line and "Sub" in line:
                            code_found = True
                            results['button_event'] = True
                            print(f"   ✅ Event-Prozedur '{event_proc}' gefunden")
                            
                            # Zeige ersten Teil des Codes
                            proc_line = form_module.ProcBodyLine(event_proc, 0)
                            proc_lines = min(10, form_module.ProcCountLines(event_proc, 0))
                            print(f"\n   📝 Code-Auszug (erste {proc_lines} Zeilen):")
                            for j in range(proc_lines):
                                code_line = form_module.Lines(proc_line + j, 1)
                                print(f"      {code_line.rstrip()}")
                            break
                    
                    if not code_found:
                        print(f"   ❌ Event-Prozedur '{event_proc}' NICHT gefunden!")
                
                # Formular schließen
                access.DoCmd.Close(2, form_name, 2)  # 2 = acForm, 2 = acSaveNo
                
            except Exception as e:
                print(f"⚠️ Fehler beim Öffnen des Formulars: {e}")
        
        # ===== ZUSAMMENFASSUNG =====
        print("\n" + "=" * 60)
        print("📊 ZUSAMMENFASSUNG")
        print("=" * 60)
        
        all_ok = True
        
        print("\n✓ Modul:")
        if results['modul_exists']:
            print(f"   ✅ mdl_Auto_Festangestellte: Vorhanden")
            if len(results['modul_functions']) == 5:
                print(f"   ✅ Funktionen: Alle 5 vorhanden")
            else:
                print(f"   ⚠️ Funktionen: {len(results['modul_functions'])}/5 gefunden")
                all_ok = False
        else:
            print(f"   ❌ mdl_Auto_Festangestellte: FEHLT")
            all_ok = False
        
        print("\n✓ Formular & Button:")
        if results['form_exists']:
            print(f"   ✅ frm_menuefuehrung1: Vorhanden")
        else:
            print(f"   ❌ frm_menuefuehrung1: FEHLT")
            all_ok = False
        
        if results['button_exists']:
            print(f"   ✅ cmd_Auto_Festangestellte: Vorhanden")
        else:
            print(f"   ❌ cmd_Auto_Festangestellte: FEHLT")
            all_ok = False
        
        if results['button_event']:
            print(f"   ✅ Click-Event: Implementiert")
        else:
            print(f"   ❌ Click-Event: FEHLT")
            all_ok = False
        
        print("\n" + "=" * 60)
        if all_ok:
            print("🎉 IMPLEMENTIERUNG VOLLSTÄNDIG!")
            print("=" * 60)
            print("\n✅ System ist einsatzbereit!")
        else:
            print("⚠️ IMPLEMENTIERUNG UNVOLLSTÄNDIG!")
            print("=" * 60)
            print("\n❌ Bitte fehlende Komponenten nachinstallieren!")
        
        # Access schließen
        access.CloseCurrentDatabase()
        access.Quit()
        
        return all_ok
        
    except Exception as e:
        print(f"\n❌ FEHLER: {e}")
        import traceback
        print(traceback.format_exc())
        
        if 'access' in locals():
            try:
                access.Quit()
            except:
                pass
        
        return False

if __name__ == '__main__':
    success = verify_implementation()
    sys.exit(0 if success else 1)
