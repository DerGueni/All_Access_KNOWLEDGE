"""
Performance Modul Import Script
"""
import sys
sys.path.insert(0, r"C:\Users\guenther.siegert\Documents\Access Bridge")

from access_bridge_ultimate import AccessBridgeUltimate

def main():
    print("=== Performance Module Import ===")

    bas_file = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\temp_mod_N_Performance.bas"

    with open(bas_file, 'r', encoding='utf-8') as f:
        vba_code = f.read()

    # Option-Zeilen und Attribute entfernen
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

    try:
        bridge = AccessBridgeUltimate(auto_connect=True)
        print("Bridge connected!")

        module_name = "mod_N_Performance"
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
