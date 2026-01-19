"""
VBA-Modul in Access importieren via Access Bridge
"""
import sys
sys.path.insert(0, r'C:\Users\guenther.siegert\Documents\Access Bridge')

from access_bridge_ultimate import AccessBridge

# Frontend Path (aus CLAUDE.md)
FRONTEND = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb'

# VBA-Datei
VBA_FILE = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\mod_N_WebView2_forms3.bas'

print("=== VBA-IMPORT STARTET ===")
print(f"Frontend: {FRONTEND}")
print(f"VBA-File: {VBA_FILE}")

try:
    with AccessBridge(FRONTEND) as bridge:
        print("\n1. Prüfe ob Modul existiert...")
        if bridge.module_exists("mod_N_WebView2_forms3"):
            print("   -> Modul existiert bereits, wird überschrieben")
        else:
            print("   -> Modul ist neu")

        print("\n2. Importiere VBA-Modul...")
        bridge.import_vba_from_file(VBA_FILE)
        print("   -> Import erfolgreich!")

        print("\n3. Prüfe Import...")
        modules = bridge.list_modules()
        if "mod_N_WebView2_forms3" in modules:
            print("   -> Modul ist vorhanden ✓")
        else:
            print("   -> FEHLER: Modul nicht gefunden!")

        print("\n=== IMPORT ABGESCHLOSSEN ===")

except Exception as e:
    print(f"\nFEHLER: {e}")
    import traceback
    traceback.print_exc()
