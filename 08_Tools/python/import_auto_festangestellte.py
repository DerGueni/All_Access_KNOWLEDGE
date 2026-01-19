#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Auto-Festangestellte Modul Import
Importiert VBA-Modul in Access-Frontend
"""

import sys
import os
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge import AccessBridge
import win32com.client

def import_vba_module():
    """Importiert das VBA-Modul in Access"""
    
    db_path = r'C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb'
    module_path = r'C:\Users\guenther.siegert\Documents\Access Bridge\mdl_Auto_Festangestellte.bas'
    module_name = 'mdl_Auto_Festangestellte'
    
    print("=== Import VBA-Modul: mdl_Auto_Festangestellte ===\n")
    
    try:
        # Access öffnen
        print("Öffne Access...")
        access = win32com.client.Dispatch("Access.Application")
        access.Visible = False
        access.OpenCurrentDatabase(db_path)
        
        # VBA-Projekt-Zugriff
        vb_proj = access.VBE.ActiveVBProject
        
        # Prüfe ob Modul existiert und lösche es
        for component in vb_proj.VBComponents:
            if component.Name == module_name:
                print(f"Modul '{module_name}' existiert bereits - wird gelöscht...")
                vb_proj.VBComponents.Remove(component)
                break
        
        # VBA-Code aus Datei laden
        print(f"Lade VBA-Code aus {module_path}...")
        with open(module_path, 'r', encoding='utf-8') as f:
            vba_code = f.read()
        
        # Neues Modul erstellen
        print(f"Erstelle neues Modul '{module_name}'...")
        new_module = vb_proj.VBComponents.Add(1)  # 1 = vbext_ct_StdModule
        new_module.Name = module_name
        
        # Code einfügen
        code_module = new_module.CodeModule
        line_count = code_module.CountOfLines
        code_module.InsertLines(line_count + 1, vba_code)
        
        print(f"✓ Modul '{module_name}' erfolgreich importiert!\n")
        
        # Access schließen
        access.CloseCurrentDatabase()
        access.Quit()
        
        print("=== Import abgeschlossen ===")
        return True
        
    except Exception as e:
        print(f"✗ Fehler: {e}")
        if 'access' in locals():
            try:
                access.Quit()
            except:
                pass
        return False

if __name__ == '__main__':
    success = import_vba_module()
    sys.exit(0 if success else 1)
