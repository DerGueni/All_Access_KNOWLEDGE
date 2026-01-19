#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
QUICK API Server - Funktioniert SOFORT auf localhost:5000
Kein pyodbc nötig - einfache Dummy-Daten aber funktional
Startet sofort - keine Abhängigkeiten!
"""

from flask import Flask, jsonify, request, send_from_directory
from datetime import datetime
import os
import json

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

# CORS Headers manuell
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

# Pfad zu Formulare
FORMS3_PATH = os.path.dirname(os.path.abspath(__file__))
FORMS3_PATH = os.path.dirname(FORMS3_PATH)

print(f"[INFO] FORMS3_PATH: {FORMS3_PATH}")

# ============================================
# STATISCHE DATEIEN
# ============================================

@app.route('/')
def index():
    """Startseite"""
    return send_from_directory(FORMS3_PATH, 'shell.html')

@app.route('/<path:filename>')
def serve_static(filename):
    """Serviere HTML, JS, CSS"""
    if filename.startswith('api/'):
        return jsonify({"error": "API route"}), 404
    
    # Passe Pfad an
    filepath = os.path.join(FORMS3_PATH, filename)
    
    # Sicherheit: nur Dateien aus FORMS3_PATH servieren
    if not os.path.abspath(filepath).startswith(os.path.abspath(FORMS3_PATH)):
        return jsonify({"error": "Path traversal not allowed"}), 403
    
    if os.path.isfile(filepath):
        return send_from_directory(FORMS3_PATH, filename)
    
    return jsonify({"error": "File not found"}), 404

# ============================================
# API ENDPOINTS - DUMMY DATEN (für schnelle Tests)
# ============================================

# Dummy-Daten
DUMMY_AUFTRAEGE = [
    {"ID": 1, "Auftrag": "Auftrag #1", "Objekt": "Test Objekt", "Ort": "Berlin", "Dat_VA_Von": "2025-01-14", "Dat_VA_Bis": "2025-01-20"},
    {"ID": 2, "Auftrag": "Auftrag #2", "Objekt": "Test Objekt 2", "Ort": "München", "Dat_VA_Von": "2025-01-15", "Dat_VA_Bis": "2025-01-25"},
    {"ID": 3, "Auftrag": "Auftrag #3", "Objekt": "Test Objekt 3", "Ort": "Hamburg", "Dat_VA_Von": "2025-01-16", "Dat_VA_Bis": "2025-01-22"},
]

DUMMY_MITARBEITER = [
    {"ID": 1, "Nachname": "Müller", "Vorname": "Max", "Tel_Mobil": "0123456789", "Email": "max.mueller@test.de"},
    {"ID": 2, "Nachname": "Schmidt", "Vorname": "Anna", "Tel_Mobil": "0987654321", "Email": "anna.schmidt@test.de"},
    {"ID": 3, "Nachname": "Weber", "Vorname": "Bob", "Tel_Mobil": "0555555555", "Email": "bob.weber@test.de"},
]

DUMMY_KUNDEN = [
    {"kun_Id": 1, "kun_Firma": "Firma A", "kun_PLZ": "10115", "kun_Ort": "Berlin"},
    {"kun_Id": 2, "kun_Firma": "Firma B", "kun_PLZ": "80001", "kun_Ort": "München"},
]

DUMMY_OBJEKTE = [
    {"ID": 1, "Objekt": "Objekt 1", "Adresse": "Straße 1, Berlin"},
    {"ID": 2, "Objekt": "Objekt 2", "Adresse": "Straße 2, München"},
]

# API Health Check
@app.route('/api/health')
def health():
    """Health Check"""
    return jsonify({
        "status": "ok",
        "message": "API Server läuft!",
        "timestamp": datetime.now().isoformat()
    })

# Aufträge
@app.route('/api/auftraege')
def auftraege_list():
    """Auftragsliste"""
    return jsonify({
        "success": True,
        "data": DUMMY_AUFTRAEGE,
        "total": len(DUMMY_AUFTRAEGE)
    })

@app.route('/api/auftraege/<int:id>')
def auftrag_detail(id):
    """Einzelner Auftrag"""
    for a in DUMMY_AUFTRAEGE:
        if a['ID'] == id:
            return jsonify({
                "success": True,
                "data": {
                    "auftrag": a,
                    "einsatztage": [{"ID": 1, "VADatum": "2025-01-14"}],
                    "startzeiten": [{"ID": 1, "VA_Start": "08:00", "VA_Ende": "17:00"}],
                    "zuordnungen": [],
                    "anfragen": []
                }
            })
    return jsonify({"success": False, "error": "Nicht gefunden"}), 404

@app.route('/api/auftraege/<int:va_id>/schichten')
def auftraege_schichten(va_id):
    """Schichten für Auftrag"""
    return jsonify({
        "success": True,
        "data": [
            {"ID": 1, "VA_Start": "08:00", "VA_Ende": "17:00", "VADatum": "2025-01-14"}
        ]
    })

@app.route('/api/auftraege/<int:va_id>/zuordnungen')
def auftraege_zuordnungen(va_id):
    """Zuordnungen für Auftrag"""
    return jsonify({
        "success": True,
        "data": []
    })

@app.route('/api/auftraege/<int:va_id>/absagen')
def auftraege_absagen(va_id):
    """Absagen für Auftrag"""
    return jsonify({
        "success": True,
        "data": []
    })

# Mitarbeiter
@app.route('/api/mitarbeiter')
def mitarbeiter_list():
    """Mitarbeiterliste"""
    return jsonify({
        "success": True,
        "data": DUMMY_MITARBEITER
    })

@app.route('/api/mitarbeiter/<int:id>')
def mitarbeiter_detail(id):
    """Einzelner Mitarbeiter"""
    for m in DUMMY_MITARBEITER:
        if m['ID'] == id:
            return jsonify({"success": True, "data": m})
    return jsonify({"success": False, "error": "Nicht gefunden"}), 404

# Kunden
@app.route('/api/kunden')
def kunden_list():
    """Kundenliste"""
    return jsonify({
        "success": True,
        "data": DUMMY_KUNDEN
    })

@app.route('/api/kunden/<int:id>')
def kunde_detail(id):
    """Einzelner Kunde"""
    for k in DUMMY_KUNDEN:
        if k['kun_Id'] == id:
            return jsonify({"success": True, "data": k})
    return jsonify({"success": False, "error": "Nicht gefunden"}), 404

# Objekte
@app.route('/api/objekte')
def objekte_list():
    """Objekteliste"""
    return jsonify({
        "success": True,
        "data": DUMMY_OBJEKTE
    })

# Status
@app.route('/api/status')
def status_list():
    """Status-Liste"""
    return jsonify({
        "success": True,
        "data": [
            {"ID": 1, "Status": "Geplant"},
            {"ID": 2, "Status": "Laufend"},
            {"ID": 3, "Status": "Beendet"}
        ]
    })

# Anfragen
@app.route('/api/anfragen')
def anfragen_list():
    """Offene Anfragen"""
    return jsonify({
        "success": True,
        "data": []
    })

# Absagen
@app.route('/api/absagen')
def absagen_list():
    """Absagen"""
    return jsonify({
        "success": True,
        "data": []
    })

# Schichten
@app.route('/api/schichten')
def schichten_list():
    """Schichten"""
    return jsonify({
        "success": True,
        "data": []
    })

# Zuordnungen
@app.route('/api/zuordnungen')
def zuordnungen_list():
    """Zuordnungen"""
    return jsonify({
        "success": True,
        "data": []
    })

# Planungen
@app.route('/api/planungen')
def planungen_list():
    """Planungen"""
    return jsonify({
        "success": True,
        "data": []
    })

# Einsatztage
@app.route('/api/einsatztage')
def einsatztage_list():
    """Einsatztage"""
    return jsonify({
        "success": True,
        "data": []
    })

# ============================================
# SERVER START
# ============================================
if __name__ == '__main__':
    print("=" * 60)
    print("QUICK API Server für forms3")
    print("=" * 60)
    print(f"Server:  http://localhost:5000")
    print(f"Shell:   http://localhost:5000/shell.html")
    print("=" * 60)
    print("Endpoints:")
    print("  /api/health")
    print("  /api/auftraege")
    print("  /api/mitarbeiter")
    print("  /api/kunden")
    print("  /api/objekte")
    print("=" * 60)
    print("\nServer wird gestartet...\n")
    
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=False)
