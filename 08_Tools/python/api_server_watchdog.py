"""
API Server Watchdog - Automatischer Neustart bei Crash
======================================================

Überwacht den API-Server und startet ihn automatisch neu bei:
- Crash (Segmentation Fault, Exception)
- Keine Antwort auf Health-Check
- Unerwartetes Beenden

Verwendung:
    python api_server_watchdog.py

Der Watchdog läuft im Hintergrund und hält den Server am Leben.
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
API_SERVER_SCRIPT = SCRIPT_DIR / "api_server.py"
LOG_FILE = SCRIPT_DIR / "logs" / "watchdog.log"
HEALTH_CHECK_URL = "http://localhost:5000/api/health"
HEALTH_CHECK_INTERVAL = 10  # Sekunden zwischen Health-Checks
HEALTH_CHECK_TIMEOUT = 5    # Sekunden Timeout für Health-Check
MAX_RESTART_ATTEMPTS = 5    # Max Neustarts in kurzer Zeit
RESTART_COOLDOWN = 60       # Sekunden zwischen zu vielen Neustarts
STARTUP_WAIT = 3            # Sekunden warten nach Start

# Logging einrichten
LOG_FILE.parent.mkdir(exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - WATCHDOG - %(levelname)s - %(message)s',
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
    """Prüft ob Server auf Health-Check antwortet"""
    try:
        import urllib.request
        req = urllib.request.Request(HEALTH_CHECK_URL)
        with urllib.request.urlopen(req, timeout=HEALTH_CHECK_TIMEOUT) as response:
            if response.status == 200:
                return True
    except Exception as e:
        logger.warning(f"Health-Check fehlgeschlagen: {e}")
    return False

def start_server():
    """Startet den API-Server als Subprocess"""
    global server_process

    logger.info("Starte API-Server...")

    # Starte Server im neuen Prozess
    server_process = subprocess.Popen(
        [sys.executable, str(API_SERVER_SCRIPT)],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=str(SCRIPT_DIR),
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name == 'nt' else 0
    )

    logger.info(f"Server gestartet mit PID {server_process.pid}")

    # Warte kurz und prüfe ob Server noch läuft
    time.sleep(STARTUP_WAIT)

    if server_process.poll() is not None:
        # Server sofort beendet
        output, _ = server_process.communicate()
        logger.error(f"Server sofort beendet mit Code {server_process.returncode}")
        if output:
            logger.error(f"Output: {output.decode('utf-8', errors='replace')[-1000:]}")
        return False

    # Prüfe Health-Check
    for _ in range(3):
        if check_server_health():
            logger.info("Server läuft und antwortet auf Health-Check")
            return True
        time.sleep(1)

    logger.warning("Server läuft, aber Health-Check fehlgeschlagen")
    return True  # Server läuft trotzdem

def stop_server():
    """Stoppt den laufenden Server"""
    global server_process

    if server_process is None:
        return

    logger.info("Stoppe Server...")

    try:
        if os.name == 'nt':
            # Windows: CTRL_BREAK_EVENT
            server_process.send_signal(signal.CTRL_BREAK_EVENT)
        else:
            server_process.terminate()

        # Warte auf Beendigung
        try:
            server_process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            logger.warning("Server antwortet nicht, erzwinge Beendigung...")
            server_process.kill()
            server_process.wait()

        logger.info("Server gestoppt")
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
    time.sleep(1)
    return start_server()

def run_watchdog():
    """Hauptschleife des Watchdogs"""
    logger.info("=" * 50)
    logger.info("API Server Watchdog gestartet")
    logger.info(f"Überwache: {API_SERVER_SCRIPT}")
    logger.info(f"Health-Check: {HEALTH_CHECK_URL}")
    logger.info("=" * 50)

    # Initialer Start
    if not start_server():
        logger.error("Initialer Start fehlgeschlagen, versuche Neustart...")
        time.sleep(2)
        if not restart_server():
            logger.error("Server konnte nicht gestartet werden!")
            return

    consecutive_failures = 0

    try:
        while True:
            time.sleep(HEALTH_CHECK_INTERVAL)

            # Prüfe ob Prozess noch läuft
            if server_process is None or server_process.poll() is not None:
                exit_code = server_process.returncode if server_process else "unknown"
                logger.error(f"Server-Prozess beendet (Exit-Code: {exit_code})")

                # Lese letzte Ausgabe
                if server_process and server_process.stdout:
                    try:
                        output = server_process.stdout.read()
                        if output:
                            logger.error(f"Letzte Ausgabe: {output.decode('utf-8', errors='replace')[-500:]}")
                    except:
                        pass

                logger.info("Starte Server neu...")
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
        stop_server()
        logger.info("Watchdog beendet")

if __name__ == '__main__':
    run_watchdog()
