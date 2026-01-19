"""
Importiert Server-Auto-Start-Module in Access Frontend
"""

import sys
import os

# Access Bridge importieren
sys.path.append(r"C:\Users\guenther.siegert\Documents\Access Bridge")
from access_bridge_ultimate import AccessBridge

def main():
    """Importiert mod_VBA_Bridge (mit API Server) und mdlAutoexec"""

    with AccessBridge() as bridge:
        print("=" * 60)
        print("SERVER AUTO-START MODULE IMPORTIEREN")
        print("=" * 60)

        # Pfade zu den Modulen
        vba_dir = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\01_VBA\modules"

        # Erst mod_API_Server loeschen falls vorhanden
        try:
            print("\nLoesche altes mod_API_Server Modul...")
            bridge.access_app.DoCmd.DeleteObject(1, "mod_API_Server")  # 1 = acModule
            print("   [OK] mod_API_Server entfernt")
        except:
            print("   [INFO] mod_API_Server existiert nicht (OK)")

        # Module importieren
        modules = [
            ("mod_VBA_Bridge.bas", "Server Auto-Start (API + VBA Bridge)"),
            ("mdlAutoexec.bas", "Autoexec (aktualisiert)")
        ]

        for filename, description in modules:
            filepath = os.path.join(vba_dir, filename)

            if not os.path.exists(filepath):
                print(f"[FEHLER] {filename} nicht gefunden")
                continue

            print(f"\nImportiere: {description}")
            print(f"   Datei: {filename}")

            try:
                # Modul importieren (überschreibt vorhandene)
                bridge.import_vba_from_file(filepath)
                print(f"   [OK] Erfolgreich importiert")

            except Exception as e:
                print(f"   [FEHLER] {e}")

        print("\n" + "=" * 60)
        print("KOMPILIEREN")
        print("=" * 60)

        try:
            # Alle Module kompilieren
            bridge.access_app.DoCmd.RunCommand(125)  # acCmdCompileAndSaveAllModules
            print("[OK] Alle Module kompiliert")
        except Exception as e:
            print(f"[FEHLER] Kompilierungs-Fehler: {e}")

        print("\n" + "=" * 60)
        print("ABGESCHLOSSEN")
        print("=" * 60)
        print("\nBeim naechsten Access-Start werden die Server")
        print("automatisch gestartet:")
        print("  * API Server (Port 5000)")
        print("  * VBA Bridge (Port 5002)")
        print("\nBeide Funktionen sind im Modul 'mod_VBA_Bridge'")

if __name__ == "__main__":
    main()
