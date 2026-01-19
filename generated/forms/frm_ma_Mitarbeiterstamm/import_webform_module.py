#!/usr/bin/env python3
"""
Import VBA Module: mod_N_WebForm_Handler
Zweck: Bridge-Kommunikation für HTML-WebForms importieren
"""

import sys
import os

# Add Access Bridge to path
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

def main():
    # Configuration
    FRONTEND_PATH = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb'
    MODULE_FILE = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\generated\forms\frm_ma_Mitarbeiterstamm\mod_N_WebForm_Handler.bas'
    MODULE_NAME = 'mod_N_WebForm_Handler'

    print("=" * 70)
    print("IMPORTING VBA MODULE FOR WEBFORM HANDLER")
    print("=" * 70)

    try:
        # Connect via Bridge
        with AccessBridge(FRONTEND_PATH) as bridge:
            print(f"\n✓ Access Bridge connected to: {os.path.basename(FRONTEND_PATH)}")

            # Check if module already exists
            if bridge.module_exists(MODULE_NAME):
                print(f"⚠ Module {MODULE_NAME} already exists. Deleting...")
                bridge.delete_module(MODULE_NAME)
                print(f"✓ Module deleted")

            # Import VBA Module from file
            print(f"\n📝 Importing VBA module from: {os.path.basename(MODULE_FILE)}")
            bridge.import_vba_from_file(MODULE_FILE)
            print(f"✓ Module {MODULE_NAME} imported successfully")

            # Verify import
            modules = bridge.list_modules()
            if MODULE_NAME in modules:
                print(f"\n✓ Verification: Module found in list")
                print(f"   Total modules: {len(modules)}")
            else:
                print(f"\n⚠ Verification failed: Module not in list")
                print(f"   Available modules: {len(modules)}")
                print(f"   Modules: {modules[:10]}...")  # Show first 10

        print("\n" + "=" * 70)
        print("✓ IMPORT COMPLETED SUCCESSFULLY")
        print("=" * 70)
        print("\nNächste Schritte:")
        print("1. Access Frontend öffnen")
        print("2. Formular frm_MA_Mitarbeiterstamm öffnen")
        print("3. VBA-Editor öffnen (Alt+F11)")
        print("4. Modul 'mod_N_WebForm_Handler' sollte sichtbar sein")
        print("5. Test-Funktionen aufrufen:")
        print("   - Test_LoadForm()")
        print("   - Test_NavigateRecord()")
        print("6. WebForm HTML testen")

    except Exception as e:
        print(f"\n✗ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1

    return 0

if __name__ == '__main__':
    exit(main())
