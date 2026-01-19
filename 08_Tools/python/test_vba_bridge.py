# Test-Script um VBA Bridge zu starten und Status zu pruefen
import subprocess
import time
import urllib.request
import os

WORK_DIR = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
SCRIPT = os.path.join(WORK_DIR, "vba_bridge.py")
LOG_FILE = os.path.join(WORK_DIR, "test_startup.log")

def check_status():
    """Prueft ob VBA Bridge laeuft"""
    try:
        req = urllib.request.urlopen("http://localhost:5002/api/vba/status", timeout=2)
        return req.status == 200, req.read().decode('utf-8')
    except Exception as e:
        return False, str(e)

def main():
    with open(LOG_FILE, 'w', encoding='utf-8') as log:
        log.write("=== VBA Bridge Test ===\n\n")
        
        # 1. Status pruefen
        running, msg = check_status()
        log.write(f"1. Initialer Status: {'LAEUFT' if running else 'NICHT AKTIV'}\n")
        log.write(f"   Response: {msg}\n\n")
        
        if running:
            log.write("VBA Bridge laeuft bereits - Test beendet.\n")
            print("VBA Bridge laeuft bereits!")
            return
        
        # 2. Python verfuegbar?
        log.write("2. Python pruefen...\n")
        try:
            result = subprocess.run(["python", "--version"], capture_output=True, text=True, timeout=5)
            log.write(f"   Python: {result.stdout.strip()}\n\n")
        except Exception as e:
            log.write(f"   FEHLER: {e}\n\n")
        
        # 3. VBA Bridge starten
        log.write("3. Starte VBA Bridge...\n")
        try:
            proc = subprocess.Popen(
                ["pythonw", SCRIPT],
                cwd=WORK_DIR,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            log.write(f"   PID: {proc.pid}\n")
        except FileNotFoundError:
            log.write("   pythonw nicht gefunden, versuche python...\n")
            try:
                proc = subprocess.Popen(
                    ["python", SCRIPT],
                    cwd=WORK_DIR,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                log.write(f"   PID: {proc.pid}\n")
            except Exception as e:
                log.write(f"   FEHLER: {e}\n")
                print(f"Fehler beim Starten: {e}")
                return
        
        # 4. Warten und erneut pruefen
        log.write("\n4. Warte 5 Sekunden...\n")
        time.sleep(5)
        
        running, msg = check_status()
        log.write(f"\n5. Finaler Status: {'LAEUFT' if running else 'NICHT AKTIV'}\n")
        log.write(f"   Response: {msg}\n")
        
        if running:
            print("VBA Bridge erfolgreich gestartet!")
            log.write("\n=== ERFOLG ===\n")
        else:
            print(f"VBA Bridge konnte nicht gestartet werden. Siehe {LOG_FILE}")
            log.write("\n=== FEHLGESCHLAGEN ===\n")

if __name__ == "__main__":
    main()
