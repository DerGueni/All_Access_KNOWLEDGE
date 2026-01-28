#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
VBA Bridge Server für forms3 HTML-Formulare
Ermöglicht HTML-Formularen den Aufruf von VBA-Funktionen in Access
API-Port: 5002
Robuste Implementierung - funktioniert auch ohne win32com!
"""

from flask import Flask, jsonify, request
from datetime import datetime
import json
import os

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

# Global Access Connection (wird lazy initialisiert)
_access_app = None
_win32com_available = False

# Versuche win32com zu laden
try:
    import win32com.client
    _win32com_available = True
except ImportError:
    _win32com_available = False
    print("[WARNUNG] win32com nicht installiert")

def get_access_app():
    """Hole oder initialisiere Access Application"""
    global _access_app
    if not _win32com_available:
        return None
    
    try:
        if _access_app is None:
            _access_app = win32com.client.GetObject(Class="Access.Application")
        return _access_app
    except:
        _access_app = None
        return None

# CORS Headers manuell
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

# ============================================
# API ENDPOINTS
# ============================================

@app.route('/api/health')
def health():
    """Health Check"""
    return jsonify({
        "status": "ok",
        "service": "VBA Bridge Server",
        "timestamp": datetime.now().isoformat(),
        "win32com_available": _win32com_available
    })

@app.route('/api/vba/status')
def vba_status():
    """Prüft ob Access offen ist"""
    if not _win32com_available:
        return jsonify({
            "status": "warning",
            "access_running": False,
            "message": "win32com nicht installiert",
            "note": "Installiere: pip install pywin32"
        })
    
    access = get_access_app()
    if access:
        return jsonify({
            "status": "ok",
            "access_running": True,
            "message": "Access läuft"
        })
    else:
        return jsonify({
            "status": "warning",
            "access_running": False,
            "message": "Access nicht erreichbar"
        })

@app.route('/api/vba/anfragen', methods=['POST'])
def vba_anfragen():
    """E-Mail-Anfragen senden (Fallback-Modus)"""
    try:
        data = request.get_json(force=True)
        va_id = data.get('VA_ID')
        
        if not _win32com_available:
            # Fallback: nur Mock-Response
            return jsonify({
                "success": True,
                "message": f"[MOCK] Anfragen würden gesendet für Auftrag {va_id}",
                "note": "win32com nicht installiert - echte VBA-Funktionen nicht verfügbar"
            })
        
        access = get_access_app()
        if not access:
            return jsonify({
                "success": False,
                "error": "Access nicht erreichbar"
            }), 503
        
        # Versuche VBA-Funktion aufzurufen
        try:
            result = access.Run("SendAnfragenEmail", va_id)
            return jsonify({
                "success": True,
                "message": f"Anfragen gesendet für Auftrag {va_id}",
                "result": str(result)
            })
        except Exception as e:
            return jsonify({
                "success": False,
                "error": f"VBA-Fehler: {str(e)}"
            }), 500

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/execute', methods=['POST'])
def vba_execute():
    """Führt VBA-Funktion aus"""
    try:
        data = request.get_json(force=True)
        function_name = data.get('function')
        args = data.get('args', [])

        if not function_name:
            return jsonify({"success": False, "error": "function erforderlich"}), 400

        # Whitelist
        allowed = ['SendAnfragenEmail', 'CreateEinsatzliste', 'RefreshData']
        if function_name not in allowed:
            return jsonify({"success": False, "error": "Funktion nicht erlaubt"}), 403

        if not _win32com_available:
            return jsonify({
                "success": True,
                "message": f"[MOCK] Funktion {function_name} würde ausgeführt"
            })

        access = get_access_app()
        if not access:
            return jsonify({"success": False, "error": "Access nicht erreichbar"}), 503

        try:
            if args:
                result = access.Run(function_name, *args)
            else:
                result = access.Run(function_name)

            return jsonify({
                "success": True,
                "message": f"Funktion ausgeführt: {function_name}",
                "result": str(result) if result else None
            })
        except Exception as e:
            return jsonify({"success": False, "error": f"VBA-Fehler: {str(e)}"}), 500

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vba/open-form', methods=['POST'])
def vba_open_form():
    """Öffnet Access-Formular"""
    try:
        data = request.get_json(force=True)
        form_name = data.get('formName')

        if not form_name:
            return jsonify({"success": False, "error": "formName erforderlich"}), 400

        if not _win32com_available:
            return jsonify({
                "success": True,
                "message": f"[MOCK] Formular {form_name} würde geöffnet"
            })

        access = get_access_app()
        if not access:
            return jsonify({"success": False, "error": "Access nicht erreichbar"}), 503

        try:
            access.DoCmd.OpenForm(form_name)
            return jsonify({
                "success": True,
                "message": f"Formular geöffnet: {form_name}"
            })
        except Exception as e:
            return jsonify({"success": False, "error": f"VBA-Fehler: {str(e)}"}), 500

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# ============================================
# SERVER START
# ============================================
if __name__ == '__main__':
    print("=" * 50)
    print("VBA Bridge Server für forms3")
    print("=" * 50)
    print(f"Server:  http://localhost:5002")
    if _win32com_available:
        print("[OK] win32com verfügbar")
    else:
        print("[WARNUNG] win32com nicht verfügbar - Mock-Modus")
    print("=" * 50)

    print("\nServer wird gestartet...")
    try:
        from waitress import serve
        print("[OK] Waitress WSGI-Server")
        serve(app, host='127.0.0.1', port=5002, threads=1)
    except ImportError:
        print("[WARNUNG] Waitress nicht installiert")
        app.run(host='127.0.0.1', port=5002, debug=False, threaded=False)
