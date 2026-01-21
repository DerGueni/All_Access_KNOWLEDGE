#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
=============================================================================
VBA BRIDGE WATCHDOG - Auto-Start & Auto-Restart
=============================================================================
Überwacht den VBA Bridge Server und startet ihn automatisch neu, wenn er
nicht erreichbar ist.

Verwendung:
    python vba_bridge_watchdog.py

Oder als Hintergrund-Prozess:
    pythonw vba_bridge_watchdog.py
=============================================================================
"""

import os
import sys
import time
import subprocess
import urllib.request
import logging

# Logging konfigurieren
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - [VBA Watchdog] %(message)s'
)
logger = logging.getLogger(__name__)

VBA_BRIDGE_PORT = 5002
CHECK_INTERVAL = 15  # Sekunden zwischen Checks
RESTART_DELAY = 5    # Sekunden warten nach Neustart

_vba_bridge_process = None


def is_vba_bridge_running():
    """Prüft ob VBA Bridge Server auf Port 5002 erreichbar ist"""
    try:
        req = urllib.request.Request(f'http://localhost:{VBA_BRIDGE_PORT}/api/health', method='GET')
        with urllib.request.urlopen(req, timeout=3) as response:
            return response.status == 200
    except Exception:
        return False


def start_vba_bridge():
    """Startet den VBA Bridge Server"""
    global _vba_bridge_process

    api_dir = os.path.dirname(os.path.abspath(__file__))
    vba_bridge_script = os.path.join(api_dir, 'vba_bridge_server.py')

    if not os.path.exists(vba_bridge_script):
        logger.error(f"Script nicht gefunden: {vba_bridge_script}")
        return False

    try:
        logger.info("Starte VBA Bridge Server...")

        # Starte VBA Bridge als subprocess (ohne Fenster auf Windows)
        creationflags = 0
        if sys.platform == 'win32':
            creationflags = subprocess.CREATE_NO_WINDOW

        _vba_bridge_process = subprocess.Popen(
            [sys.executable, vba_bridge_script],
            cwd=api_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            creationflags=creationflags
        )

        # Warte und prüfe ob gestartet
        time.sleep(RESTART_DELAY)

        if is_vba_bridge_running():
            logger.info(f"VBA Bridge Server läuft auf Port {VBA_BRIDGE_PORT}")
            return True
        else:
            logger.warning("VBA Bridge gestartet aber nicht erreichbar - prüfe Access Frontend")
            return False

    except Exception as e:
        logger.error(f"Start fehlgeschlagen: {e}")
        return False


def watchdog_loop():
    """Haupt-Watchdog-Schleife"""
    logger.info("=" * 60)
    logger.info("VBA BRIDGE WATCHDOG GESTARTET")
    logger.info(f"Überwache Port {VBA_BRIDGE_PORT} alle {CHECK_INTERVAL} Sekunden")
    logger.info("=" * 60)

    consecutive_failures = 0

    while True:
        try:
            if is_vba_bridge_running():
                if consecutive_failures > 0:
                    logger.info("VBA Bridge wieder erreichbar")
                consecutive_failures = 0
            else:
                consecutive_failures += 1
                logger.warning(f"VBA Bridge nicht erreichbar (Versuch {consecutive_failures})")

                # Nach 2 Fehlversuchen neu starten
                if consecutive_failures >= 2:
                    logger.info("Starte VBA Bridge neu...")
                    start_vba_bridge()
                    consecutive_failures = 0

            time.sleep(CHECK_INTERVAL)

        except KeyboardInterrupt:
            logger.info("Watchdog beendet (Ctrl+C)")
            break
        except Exception as e:
            logger.error(f"Fehler im Watchdog: {e}")
            time.sleep(CHECK_INTERVAL)


if __name__ == '__main__':
    # Initiales Starten wenn nicht erreichbar
    if not is_vba_bridge_running():
        logger.info("VBA Bridge nicht erreichbar - starte...")
        start_vba_bridge()
    else:
        logger.info("VBA Bridge bereits erreichbar")

    # Watchdog-Schleife starten
    watchdog_loop()
