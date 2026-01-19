#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
CONSYS HTML Shell Opener (Codes)
Startet API-Server + HTTP-Server und oeffnet HTML-Forms aus forms/_Codes
"""

import sys
import os
import socket
import shutil
import subprocess
import webbrowser
import time
import json
from datetime import datetime

API_SERVER_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\08_Tools\python"
API_SERVER_SCRIPT = "api_server.py"
HTML_FORMS_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms"
API_PORT = 5000
HTTP_PORT = 8080
LOG_PATH = r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\runtime_logs\e2e.jsonl"


def log_e2e(action, details=""):
    try:
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        entry = {
            "ts": datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3],
            "run_id": f"codes_{int(time.time()*1000)}",
            "action": action,
            "details": details
        }
        with open(LOG_PATH, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass


def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0


def start_api_server():
    if is_port_in_use(API_PORT):
        log_e2e("API_SERVER_CHECK", f"already_running=True|port={API_PORT}")
        return True

    log_e2e("API_SERVER_START", f"path={API_SERVER_PATH}")

    server_path = os.path.join(API_SERVER_PATH, API_SERVER_SCRIPT)
    if not os.path.exists(server_path):
        log_e2e("API_SERVER_ERROR", f"file_not_found={server_path}")
        return False

    startupinfo = subprocess.STARTUPINFO()
    startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startupinfo.wShowWindow = 6

    py = shutil.which("python") or shutil.which("py")
    if not py:
        log_e2e("API_SERVER_ERROR", "python_not_found")
        return False

    cmd = [py, API_SERVER_SCRIPT] if os.path.basename(py).lower() == "python.exe" else [py, "-3", API_SERVER_SCRIPT]

    subprocess.Popen(
        cmd,
        cwd=API_SERVER_PATH,
        startupinfo=startupinfo,
        creationflags=subprocess.CREATE_NEW_CONSOLE
    )

    for i in range(10):
        time.sleep(0.5)
        if is_port_in_use(API_PORT):
            log_e2e("API_SERVER_READY", f"startup_time_ms={i*500}")
            return True

    log_e2e("API_SERVER_TIMEOUT", "server_not_responding_after_5s")
    return False


def start_http_server():
    if is_port_in_use(HTTP_PORT):
        log_e2e("HTTP_SERVER_CHECK", f"already_running=True|port={HTTP_PORT}")
        return True

    log_e2e("HTTP_SERVER_START", f"port={HTTP_PORT}|path={HTML_FORMS_PATH}")

    startupinfo = subprocess.STARTUPINFO()
    startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startupinfo.wShowWindow = 6

    py = shutil.which("python") or shutil.which("py")
    if not py:
        log_e2e("HTTP_SERVER_ERROR", "python_not_found")
        return False

    cmd = [py, "-m", "http.server", str(HTTP_PORT)] if os.path.basename(py).lower() == "python.exe" else [py, "-3", "-m", "http.server", str(HTTP_PORT)]

    subprocess.Popen(
        cmd,
        cwd=HTML_FORMS_PATH,
        startupinfo=startupinfo,
        creationflags=subprocess.CREATE_NEW_CONSOLE
    )

    for i in range(10):
        time.sleep(0.3)
        if is_port_in_use(HTTP_PORT):
            log_e2e("HTTP_SERVER_READY", f"startup_time_ms={i*300}")
            return True

    log_e2e("HTTP_SERVER_TIMEOUT", "server_not_responding_after_3s")
    return False


def open_form(form_id="auftragstamm"):
    form_url = f"http://127.0.0.1:{HTTP_PORT}/forms/_Codes/shell.html?form={form_id}"

    log_e2e("BROWSER_OPEN", f"url={form_url}")
    result = webbrowser.open(form_url)
    log_e2e("BROWSER_DISPATCHED", f"success={result}")
    return result


def main():
    form_id = sys.argv[1] if len(sys.argv) > 1 else "auftragstamm"

    log_e2e("OPENER_START", f"form_id={form_id}")

    api_ok = start_api_server()
    http_ok = start_http_server()
    browser_ok = open_form(form_id)

    log_e2e("OPENER_COMPLETE", f"api_ok={api_ok}|http_ok={http_ok}|browser_ok={browser_ok}")


if __name__ == "__main__":
    main()
