"""
Flask Health-Check Template für CONSYS API-Server
==================================================
Füge diesen Code zu deinen Flask-Servern hinzu für
automatische Stabilitätsüberwachung.

Installation: pip install py-healthcheck flask
"""

from flask import Flask, jsonify
from healthcheck import HealthCheck, EnvironmentDump
import os
import sys
from datetime import datetime

# ============================================
# HEALTH-CHECK KONFIGURATION
# ============================================

def create_health_endpoint(app, db_check_func=None, custom_checks=None):
    """
    Erstellt Health-Check Endpoints für eine Flask-App.
    
    Args:
        app: Flask-App Instanz
        db_check_func: Optional - Funktion zur DB-Prüfung
        custom_checks: Optional - Liste zusätzlicher Check-Funktionen
    
    Returns:
        HealthCheck Instanz
    """
    health = HealthCheck()
    envdump = EnvironmentDump()
    
    # Basis-Check: Server läuft
    def server_available():
        return True, "Server is running"
    health.add_check(server_available)
    
    # Memory-Check
    def memory_check():
        try:
            import psutil
            memory = psutil.virtual_memory()
            if memory.percent < 90:
                return True, f"Memory OK: {memory.percent}% used"
            else:
                return False, f"Memory WARNING: {memory.percent}% used"
        except ImportError:
            return True, "Memory check skipped (psutil not installed)"
    health.add_check(memory_check)
    
    # Disk-Check
    def disk_check():
        try:
            import psutil
            disk = psutil.disk_usage('/')
            if disk.percent < 90:
                return True, f"Disk OK: {disk.percent}% used"
            else:
                return False, f"Disk WARNING: {disk.percent}% used"
        except ImportError:
            return True, "Disk check skipped (psutil not installed)"
    health.add_check(disk_check)
    
    # Datenbank-Check (optional)
    if db_check_func:
        health.add_check(db_check_func)
    
    # Custom Checks hinzufügen
    if custom_checks:
        for check in custom_checks:
            health.add_check(check)
    
    # Environment Info
    def application_data():
        return {
            "project": "CONSYS",
            "version": "1.0.0",
            "python_version": sys.version,
            "startup_time": datetime.now().isoformat(),
            "working_directory": os.getcwd()
        }
    envdump.add_section("application", application_data)
    
    # Routes hinzufügen
    app.add_url_rule("/health", "healthcheck", view_func=lambda: health.run())
    app.add_url_rule("/health/details", "healthcheck_details", view_func=lambda: envdump.run())
    
    # Einfacher Status-Endpoint
    @app.route("/status")
    def status():
        return jsonify({
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "service": "CONSYS API"
        }), 200
    
    return health


# ============================================
# BEISPIEL-VERWENDUNG
# ============================================

if __name__ == "__main__":
    # Beispiel Flask-App
    app = Flask(__name__)
    
    # Optional: Datenbank-Check
    def check_database():
        """Beispiel DB-Check - anpassen für Access/SQLite"""
        try:
            # Hier deine DB-Verbindung prüfen
            # z.B. pyodbc für Access oder sqlite3
            return True, "Database connection OK"
        except Exception as e:
            return False, f"Database error: {str(e)}"
    
    # Health-Check initialisieren
    health = create_health_endpoint(
        app, 
        db_check_func=check_database
    )
    
    # Deine normalen Routes
    @app.route("/")
    def index():
        return jsonify({"message": "CONSYS API Server"})
    
    @app.route("/api/test")
    def test():
        return jsonify({"test": "OK"})
    
    # Server starten
    print("Starting CONSYS API Server...")
    print("Health-Check: http://localhost:5000/health")
    print("Status: http://localhost:5000/status")
    print("Environment: http://localhost:5000/health/details")
    
    app.run(host="0.0.0.0", port=5000, debug=True)


# ============================================
# INTEGRATION IN BESTEHENDE FLASK-APPS
# ============================================
"""
So integrierst du Health-Checks in deine bestehenden Server:

1. Am Anfang der Datei importieren:
   from flask_healthcheck_template import create_health_endpoint

2. Nach app = Flask(__name__):
   health = create_health_endpoint(app)

3. Optional mit DB-Check:
   def my_db_check():
       # Deine DB-Logik
       return True, "DB OK"
   
   health = create_health_endpoint(app, db_check_func=my_db_check)

Fertig! Endpoints verfügbar:
- /health       - JSON Health-Status
- /status       - Einfacher Status
- /health/details - Umgebungsinfos
"""
