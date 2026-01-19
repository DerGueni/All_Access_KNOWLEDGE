#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

try:
    import win32com.client
    
    access = win32com.client.Dispatch("Access.Application")
    access.OpenCurrentDatabase(r'C:\Users\guenther.siegert\Documents\Consys_FE_N_Test_Claude_GPT.accdb')
    
    print("\n=== MODULE ===")
    for m in access.CurrentProject.AllModules:
        print(f"  {m.Name}")
        
    print("\n=== FORMS ===")
    for f in access.CurrentProject.AllForms:
        if 'menu' in f.Name.lower():
            print(f"  {f.Name}")
    
    access.Quit()
    
except Exception as e:
    print(f"Error: {e}")
