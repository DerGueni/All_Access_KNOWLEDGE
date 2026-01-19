"""
VBA Modul Import Script
Importiert mod_N_WebView2_forms3.bas in das Access Frontend
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridgeUltimate

def main():
    print("=== VBA Module Import ===")

    # VBA Code aus der .bas Datei lesen
    bas_file = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\mod_N_WebView2_forms3.bas"

    with open(bas_file, 'r', encoding='utf-8') as f:
        vba_code = f.read()

    # Option-Zeilen und Attribute entfernen (Bridge macht das auch)
    lines = vba_code.split('\n')
    filtered_lines = []
    for line in lines:
        stripped = line.strip()
        if stripped.lower().startswith('option compare'):
            continue
        if stripped.lower().startswith('option explicit'):
            continue
        if stripped.lower().startswith('attribute vb_'):
            continue
        filtered_lines.append(line)

    clean_code = '\n'.join(filtered_lines)

    print(f"Code Length: {len(clean_code)} chars")
    print("First 200 chars:", clean_code[:200])

    # Bridge verbinden
    try:
        bridge = AccessBridgeUltimate(auto_connect=True)
        print("Bridge connected!")

        # Modul importieren
        module_name = "mod_N_WebView2_forms3"

        # Modul importieren (ueberschreibt falls vorhanden)
        print(f"Importing {module_name}...")
        result = bridge.import_vba_module(module_name, clean_code, auto_prefix=False)
        print(f"Import result: {result}")

        bridge.disconnect()
        print("Done!")
        return True

    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
