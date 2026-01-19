#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Restart API Server"""

import subprocess, time, psutil

print("[INFO] Stopping old API server processes...")

# Find and kill processes listening on port 5000
for proc in psutil.process_iter(['pid', 'name']):
    try:
        if proc.info['name'] == 'python.exe':
            try:
                for conn in proc.connections():
                    if conn.status == 'LISTEN' and conn.laddr.port == 5000:
                        print(f"[KILL] PID {proc.pid}")
                        proc.kill()
                        break
            except (psutil.AccessDenied, psutil.NoSuchProcess):
                pass
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        pass

time.sleep(3)

print("[INFO] Starting new API server...")
subprocess.Popen(
    ['python', 'api_server.py'],
    cwd=r'C:\Users\guenther.siegert\Documents\Access Bridge',
    creationflags=subprocess.CREATE_NO_WINDOW
)

time.sleep(5)

# Test endpoint
import requests
try:
    resp = requests.get('http://localhost:5000/api/mitarbeiter?view=table&limit=1&aktiv=true&filter_anstellung=false', timeout=5)
    data = resp.json()
    if data.get('success') and data.get('data'):
        field_count = len(data['data'][0])
        print(f"[OK] Server running - {field_count} fields returned")
        if field_count > 10:
            print("[OK] view=table parameter working!")
        else:
            print("[WARNING] Still old version (only 9 fields)")
    else:
        print("[ERROR] No data returned")
except Exception as e:
    print(f"[ERROR] {e}")
