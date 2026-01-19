"""
VBA Bridge Watchdog - Automatischer Neustart bei Crash
=======================================================

Überwacht die VBA Bridge (Port 5002) und startet sie automatisch neu bei:
- Crash (Segmentation Fault, Exception)
- Keine Antwort auf Health-Check
- Unerwartetes Beenden

Verwendung:
    python vba_bridge_watchdog.py

Der Watchdog läuft im Hintergrund und hält die VBA Bridge am Leben.
"""

import subprocess
import time
import sys
import os
import signal
import logging
from pathlib import Path
from datetime import datetime

# Konfiguration
SCRIPT_DIR = Path(__file__).parent
# VBA Bridge Server - Primärer Pfad
VBA_BRIDGE_SCRIPT = Path(r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\api\vba_bridge_server.py")
# Fallback falls nicht vorhanden
if not VBA_BRIDGE_SCRIPT.exists():
    VBA_BRIDGE_SCRIPT = SCRIPT_DIR / "vba_bridge.py"

LOG_FILE = SCRIPT_DIR / "logs" / "vba_bridge_watchdog.log"
HEALTH_CHECK_URL = "http://localhost:5002/api/vba/ping"
HEALTH_CHECK_INTERVAL = 15  # Sekunden zwischen Health-Checks
HEALTH_CHECK_TIMEOUT = 5    # Sekunden Timeout für Health-Check
MAX_RESTART_ATTEMPTS = 5    # Max Neustarts in kurzer Zeit
RESTART_COOLDOWN = 60       # Sekunden zwischen zu vielen Neustarts
STARTUP_WAIT = 5            # Sekunden warten nach Start (VBA Bridge braucht länger)

# Logging einrichten
LOG_FILE.parent.mkdir(exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - VBA-BRIDGE-WATCHDOG - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Globale Variablen
server_process = None
restart_times = []

def check_server_health():
    """Prüft ob VBA Bridge auf Health-Check antwortet"""
    try:
        import urllib.request
        req = urllib.request.Request(HEALTH_CHECK_URL)
        with urllib.request.urlopen(req, timeout=HEALTH_CHECK_TIMEOUT) as response:
            if response.status == 200:
                return True
    except Exception as e:
        logger.warning(f"Health-Check fehlgeschlagen: {e}")
    return False

def is_bridge_already_running():
    """Prüft ob die Bridge bereits auf Port 5002 läuft"""
    try:
        import urllib.request
        req = urllib.request.Request(HEALTH_CHECK_URL)
        with urllib.request.urlopen(req, timeout=2) as response:
            if response.status == 200:
                return True
    except:
        pass
    return False

def start_server():
    """Startet die VBA Bridge als Subprocess"""
    global server_process

    # Prüfe ob bereits eine Instanz läuft
    if is_bridge_already_running():
        logger.info("VBA Bridge läuft bereits auf Port 5002")
        return True

    logger.info(f"Starte VBA Bridge: {VBA_BRIDGE_SCRIPT}")

    if not VBA_BRIDGE_SCRIPT.exists():
        logger.error(f"VBA Bridge Script nicht gefunden: {VBA_BRIDGE_SCRIPT}")
        return False

    # Starte Server im neuen Prozess (versteckt)
    try:
        # Verwende pythonw für verstecktes Fenster auf Windows
        python_exe = sys.executable
        if os.name == 'nt':
            # Versuche pythonw zu finden
            pythonw = Path(python_exe).parent / "pythonw.exe"
            if pythonw.exists():
                python_exe = str(pythonw)

        server_process = subprocess.Popen(
            [python_exe, str(VBA_BRIDGE_SCRIPT)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            cwd=str(VBA_BRIDGE_SCRIPT.parent),
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
        )

        logger.info(f"VBA Bridge gestartet mit PID {server_process.pid}")

    except Exception as e:
        logger.error(f"Fehler beim Starten: {e}")
        return False

    # Warte kurz und prüfe ob Server noch läuft
    time.sleep(STARTUP_WAIT)

    if server_process.poll() is not None:
        # Server sofort beendet
        output = b""
        try:
            output, _ = server_process.communicate(timeout=2)
        except:
            pass
        logger.error(f"VBA Bridge sofort beendet mit Code {server_process.returncode}")
        if output:
            logger.error(f"Output: {output.decode('utf-8', errors='replace')[-1000:]}")
        return False

    # Prüfe Health-Check
    for i in range(5):
        if check_server_health():
            logger.info("VBA Bridge läuft und antwortet auf Health-Check")
            return True
        logger.info(f"Warte auf Health-Check... ({i+1}/5)")
        time.sleep(2)

    logger.warning("VBA Bridge läuft, aber Health-Check fehlgeschlagen")
    return True  # Server läuft trotzdem

def stop_server():
    """Stoppt die laufende VBA Bridge"""
    global server_process

    if server_process is None:
        return

    logger.info("Stoppe VBA Bridge...")

    try:
        if os.name == 'nt':
            # Windows: CTRL_BREAK_EVENT
            try:
                server_process.send_signal(signal.CTRL_BREAK_EVENT)
            except:
                server_process.terminate()
        else:
            server_process.terminate()

        # Warte auf Beendigung
        try:
            server_process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            logger.warning("VBA Bridge antwortet nicht, erzwinge Beendigung...")
            server_process.kill()
            server_process.wait()

        logger.info("VBA Bridge gestoppt")
    except Exception as e:
        logger.error(f"Fehler beim Stoppen: {e}")

    server_process = None

def restart_server():
    """Neustart mit Rate-Limiting"""
    global restart_times

    now = time.time()

    # Entferne alte Restart-Zeiten
    restart_times = [t for t in restart_times if now - t < RESTART_COOLDOWN]

    if len(restart_times) >= MAX_RESTART_ATTEMPTS:
        logger.error(f"Zu viele Neustarts ({MAX_RESTART_ATTEMPTS}) in {RESTART_COOLDOWN}s - Warte...")
        time.sleep(RESTART_COOLDOWN)
        restart_times = []

    restart_times.append(now)

    stop_server()
    time.sleep(2)
    return start_server()

def run_watchdog():
    """Hauptschleife des Watchdogs"""
    logger.info("=" * 60)
    logger.info("VBA Bridge Watchdog gestartet")
    logger.info(f"Überwache: {VBA_BRIDGE_SCRIPT}")
    logger.info(f"Health-Check: {HEALTH_CHECK_URL}")
    logger.info(f"Intervall: {HEALTH_CHECK_INTERVAL}s")
    logger.info("=" * 60)

    # Initialer Start (nur wenn nicht bereits läuft)
    if is_bridge_already_running():
        logger.info("VBA Bridge läuft bereits - Watchdog übernimmt Überwachung")
    else:
        if not start_server():
            logger.error("Initialer Start fehlgeschlagen, versuche Neustart...")
            time.sleep(2)
            if not restart_server():
                logger.error("VBA Bridge konnte nicht gestartet werden!")
                return

    consecutive_failures = 0

    try:
        while True:
            time.sleep(HEALTH_CHECK_INTERVAL)

            # Prüfe ob Prozess noch läuft (falls wir ihn gestartet haben)
            if server_process is not None and server_process.poll() is not None:
                exit_code = server_process.returncode if server_process else "unknown"
                logger.error(f"VBA Bridge Prozess beendet (Exit-Code: {exit_code})")

                # Lese letzte Ausgabe
                if server_process and server_process.stdout:
                    try:
                        output = server_process.stdout.read()
                        if output:
                            logger.error(f"Letzte Ausgabe: {output.decode('utf-8', errors='replace')[-500:]}")
                    except:
                        pass

                logger.info("Starte VBA Bridge neu...")
                if restart_server():
                    consecutive_failures = 0
                else:
                    consecutive_failures += 1
                continue

            # Health-Check
            if check_server_health():
                consecutive_failures = 0
            else:
                consecutive_failures += 1
                logger.warning(f"Health-Check fehlgeschlagen ({consecutive_failures}/3)")

                if consecutive_failures >= 3:
                    logger.error("3 Health-Checks fehlgeschlagen - Neustart!")
                    if restart_server():
                        consecutive_failures = 0

    except KeyboardInterrupt:
        logger.info("Watchdog wird beendet (Ctrl+C)")
    finally:
        # Server NICHT stoppen wenn Watchdog beendet wird - Bridge soll weiterlaufen
        logger.info("Watchdog beendet (VBA Bridge läuft weiter)")

if __name__ == '__main__':
    run_watchdog()
