#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Robust API Server für forms3 - mit Access-Integration
Startet automatisch beim Access-Open und läuft persistent
"""

import os
import sys
import threading
import time
from flask import Flask, jsonify, request, send_from_directory
from datetime import datetime

# ============================================
# KONFIGURATION
# ============================================
FORMS3_PATH = os.path.dirname(os.path.abspath(__file__))
# Gehe ein Verzeichnis nach oben (von _scripts zu forms3)
FORMS3_PATH = os.path.dirname(FORMS3_PATH)

API_PORT = 5000
HOST = '127.0.0.1'

print(f"[API] Starte auf {FORMS3_PATH}")
print(f"[API] Port: {API_PORT}")

# ============================================
# FLASK APP
# ============================================
app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

# CORS Headers manuell hinzufügen
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

# ============================================
# HEALTH CHECK
# ============================================
@app.route('/api/health')
def health():
    return jsonify({
        "status": "ok",
        "timestamp": datetime.now().isoformat(),
        "forms3_path": FORMS3_PATH
    })

# ============================================
# SHELL.HTML (SIDEBAR + TABS)
# ============================================
@app.route('/')
@app.route('/shell.html')
def shell():
    try:
        shell_path = os.path.join(FORMS3_PATH, 'shell.html')
        with open(shell_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        return f"<h1>Error loading shell.html: {e}</h1>", 500

# ============================================
# AUFTRAGSTAMM FORMULAR
# ============================================
@app.route('/frm_va_Auftragstamm.html')
def auftragstamm():
    try:
        form_path = os.path.join(FORMS3_PATH, 'frm_va_Auftragstamm.html')
        with open(form_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        return f"<h1>Error loading form: {e}</h1>", 500

# ============================================
# STATISCHE DATEIEN
# ============================================
@app.route('/<path:filename>')
def serve_static(filename):
    try:
        return send_from_directory(FORMS3_PATH, filename)
    except:
        return jsonify({"error": "File not found"}), 404

# ============================================
# DUMMY API ENDPOINTS (für Entwicklung ohne DB)
# ============================================
@app.route('/api/auftraege')
def auftraege():
    return jsonify({
        "success": True,
        "data": [
            {"ID": 1, "Auftrag": "Test Auftrag", "Objekt": "Test Objekt", "Ort": "Berlin"},
        ]
    })

@app.route('/api/auftraege/<int:id>')
def auftrag_detail(id):
    return jsonify({
        "success": True,
        "data": {
            "auftrag": {
                "ID": id,
                "Auftrag": f"Auftrag #{id}",
                "Objekt": "Test",
                "Ort": "Berlin",
                "Dat_VA_Von": "2026-01-14",
                "Dat_VA_Bis": "2026-01-20"
            },
            "einsatztage": [],
            "startzeiten": [],
            "zuordnungen": [],
            "anfragen": []
        }
    })

@app.route('/api/auftraege/<int:va_id>/schichten')
def auftraege_schichten(va_id):
    return jsonify({
        "success": True,
        "data": []
    })

@app.route('/api/auftraege/<int:va_id>/zuordnungen')
def auftraege_zuordnungen(va_id):
    return jsonify({
        "success": True,
        "data": []
    })

@app.route('/api/auftraege/<int:va_id>/absagen')
def auftraege_absagen(va_id):
    return jsonify({
        "success": True,
        "data": []
    })

@app.route('/api/mitarbeiter')
def mitarbeiter():
    return jsonify({"success": True, "data": []})

@app.route('/api/status')
def status():
    return jsonify({"success": True, "data": []})

# ============================================
# STARTUP
# ============================================
def start_server():
    """Starte Flask Server"""
    print(f"\n{'='*50}")
    print(f"CONSYS API Server")
    print(f"{'='*50}")
    print(f"[✓] http://{HOST}:{API_PORT}")
    print(f"[✓] http://{HOST}:{API_PORT}/shell.html")
    print(f"[✓] http://{HOST}:{API_PORT}/api/health")
    print(f"{'='*50}\n")
    
    try:
        # Starte mit Werkzeug (Flask dev server)
        app.run(
            host=HOST,
            port=API_PORT,
            debug=False,
            use_reloader=False,
            threaded=False
        )
    except Exception as e:
        print(f"[ERROR] Server start failed: {e}")
        sys.exit(1)

# ============================================
# MAIN
# ============================================
if __name__ == '__main__':
    print("[*] CONSYS forms3 API Server")
    print("[*] Prüfe Dateien...")
    
    # Prüfe shell.html
    shell_path = os.path.join(FORMS3_PATH, 'shell.html')
    if not os.path.exists(shell_path):
        print(f"[ERROR] shell.html nicht gefunden: {shell_path}")
        sys.exit(1)
    print(f"[✓] shell.html existiert")
    
    # Starte Server
    start_server()
