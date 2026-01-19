"""
Access VBA Bridge - Ruft VBA-Funktionen direkt über COM/ActiveX auf
Läuft auf Port 5002 um den Haupt-API-Server nicht zu stören

AUTOSTART-VERSION: Läuft als Hintergrund-Dienst
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import win32com.client
import pythoncom
import os
import sys
import logging

# Logging einrichten (in Datei statt Konsole für Hintergrund-Betrieb)
log_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'logs')
os.makedirs(log_dir, exist_ok=True)
log_file = os.path.join(log_dir, 'vba_bridge.log')

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)  # Auch Konsole wenn sichtbar
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
# CORS für ALLE Ursprünge aktivieren (wichtig für file:// Protokoll!)
CORS(app, resources={r"/*": {"origins": "*", "allow_headers": "*", "methods": ["GET", "POST", "OPTIONS"]}})

# Zusätzlicher after_request Handler für explizite CORS-Headers (für file:// Ursprünge)
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    response.headers['Access-Control-Max-Age'] = '3600'
    return response

# Access Frontend-Pfad (enthält die VBA-Module)
# Pfade in Prioritätsreihenfolge
_PATHS = [
    r"C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\0_Consys_FE_Test.accdb",
    r"S:\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb",
    r"\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\B - DIVERSES\Consys_FE_N_Test_Claude_GPT - Kopie (9) - Kopie.accdb",
]

# Wähle den ersten verfügbaren Pfad
FRONTEND_PATH = None
for p in _PATHS:
    if os.path.exists(p):
        FRONTEND_PATH = p
        break

if FRONTEND_PATH is None:
    FRONTEND_PATH = _PATHS[0]

logger.info(f"Frontend-Pfad: {FRONTEND_PATH}")

# Globale Access-Instanz
access_app = None

def get_access_app():
    """Holt oder erstellt eine Access-Instanz"""
    global access_app
    
    # COM für diesen Thread initialisieren
    pythoncom.CoInitialize()
    
    try:
        # ZUERST: Prüfen ob Access bereits läuft (BEVORZUGT!)
        try:
            access_app = win32com.client.GetActiveObject("Access.Application")
            current_db = access_app.CurrentDb()
            if current_db:
                db_name = current_db.Name
                logger.info(f"[Access] Verwende laufende Instanz: {db_name}")
                return access_app
        except Exception as e:
            logger.info(f"[Access] Keine laufende Instanz gefunden: {e}")
        
        # Neue Instanz erstellen nur wenn keine läuft
        logger.info("[Access] Erstelle neue Access-Instanz...")
        access_app = win32com.client.Dispatch("Access.Application")
        access_app.Visible = True
        
        # Datenbank öffnen
        logger.info(f"[Access] Oeffne: {FRONTEND_PATH}")
        access_app.OpenCurrentDatabase(FRONTEND_PATH)
        
        logger.info("[Access] Access-Instanz bereit")
        return access_app
        
    except Exception as e:
        logger.error(f"[Access] Fehler: {e}")
        raise

@app.route('/')
def index():
    return jsonify({
        'service': 'CONSEC Access VBA Bridge',
        'status': 'running',
        'frontend': FRONTEND_PATH,
        'endpoints': {
            '/api/vba/anfragen': 'POST - Ruft zmd_Mail.Anfragen() auf',
            '/api/vba/call': 'POST - Ruft beliebige VBA-Funktion auf',
            '/api/vba/status': 'GET - Prüft Access-Verbindung',
            '/api/health': 'GET - Health-Check für Schnellauswahl'
        }
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health-Check Endpoint für Schnellauswahl HTML"""
    return jsonify({
        'status': 'ok',
        'service': 'vba_bridge',
        'port': 5002
    })

@app.route('/api/vba/anfragen', methods=['POST', 'OPTIONS'])
def call_anfragen():
    """
    Ruft die Access VBA-Funktion zmd_Mail.Anfragen() auf.

    Unterstützt:
    - Einzelner MA: ma_id (int)
    - Mehrere MA: MA_IDs (array) - wie von Schnellauswahl gesendet
    - Groß/Kleinschreibung: VA_ID oder va_id

    WICHTIG: Anfragen() sendet NUR E-Mail und setzt Status=2 (Angefragt).
    MA wird NICHT in Einsatzliste eingetragen! Das passiert erst bei Zusage per PHP.
    """
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'})

    try:
        data = request.get_json()

        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten übergeben'}), 400

        # Parameter mit Fallback für Groß/Kleinschreibung
        va_id = data.get('va_id') or data.get('VA_ID')
        vadatum_id = data.get('vadatum_id') or data.get('VADatum_ID')
        vastart_id = data.get('vastart_id') or data.get('VAStart_ID') or 0

        # MA_IDs: Entweder Array (MA_IDs) oder einzeln (ma_id)
        ma_ids = data.get('MA_IDs') or data.get('ma_ids')
        if not ma_ids:
            single_ma = data.get('ma_id') or data.get('MA_ID')
            if single_ma:
                ma_ids = [single_ma]

        if not ma_ids or not va_id or not vadatum_id:
            return jsonify({
                'success': False,
                'error': 'MA_IDs (oder ma_id), va_id und vadatum_id erforderlich',
                'received': {
                    'ma_ids': ma_ids,
                    'va_id': va_id,
                    'vadatum_id': vadatum_id
                }
            }), 400

        logger.info(f"[VBA] Anfragen für {len(ma_ids)} MA: VA={va_id}, Datum={vadatum_id}, Start={vastart_id}")

        # Access-Instanz holen
        acc = get_access_app()

        # Ergebnisse sammeln
        results = []
        sent = 0
        failed = 0
        errors = []

        # Für jeden MA die VBA-Funktion aufrufen
        for ma_id in ma_ids:
            try:
                logger.info(f"[VBA] Anfragen: MA={ma_id}, VA={va_id}, Datum={vadatum_id}, Start={vastart_id}")

                # KRITISCH: Prüfen ob VAStart_ID gültig ist (nicht 0!)
                if not vastart_id or vastart_id == 0:
                    logger.error(f"[VBA] FEHLER: VAStart_ID ist 0 oder null für MA {ma_id}!")
                    failed += 1
                    results.append({
                        'ma_id': ma_id,
                        'status': 'error',
                        'error': 'VAStart_ID ist nicht gesetzt - bitte Schicht auswählen!'
                    })
                    continue

                result = acc.Run("Anfragen", int(ma_id), int(va_id), int(vadatum_id), int(vastart_id))
                logger.info(f"[VBA] Ergebnis für MA {ma_id}: {result}")

                if result and ">OK" in str(result):
                    sent += 1
                    results.append({'ma_id': ma_id, 'status': 'sent', 'result': result})
                elif result and "KEINE EMAIL" in str(result).upper():
                    failed += 1
                    results.append({'ma_id': ma_id, 'status': 'no_email', 'result': result})
                elif result and "BEREITS" in str(result).upper():
                    # Bereits zugesagt/abgesagt - kein Fehler, nur Info
                    results.append({'ma_id': ma_id, 'status': 'already_processed', 'result': result})
                else:
                    failed += 1
                    results.append({'ma_id': ma_id, 'status': 'failed', 'result': result})

            except Exception as e:
                failed += 1
                error_msg = str(e)
                errors.append({'ma_id': ma_id, 'error': error_msg})
                results.append({'ma_id': ma_id, 'status': 'error', 'error': error_msg})
                logger.error(f"[VBA] Fehler bei MA {ma_id}: {e}")

        overall_success = sent > 0 and failed == 0

        return jsonify({
            'success': overall_success,
            'sent': sent,
            'failed': failed,
            'total': len(ma_ids),
            'results': results,
            'errors': errors if errors else None,
            'va_id': va_id,
            'vadatum_id': vadatum_id,
            'vastart_id': vastart_id
        })

    except Exception as e:
        import traceback
        logger.error(f"[VBA] Fehler: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'trace': traceback.format_exc()
        }), 500

@app.route('/api/vba/call', methods=['POST', 'OPTIONS'])
def call_vba_function():
    """Ruft eine beliebige VBA-Funktion auf"""
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'})
    
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'Keine Daten übergeben'}), 400
        
        func_name = data.get('function')
        args = data.get('args', [])
        
        if not func_name:
            return jsonify({'success': False, 'error': 'function erforderlich'}), 400
        
        # Whitelist für erlaubte Funktionen
        allowed_functions = [
            'Anfragen',
            'Texte_lesen',
            'setze_Angefragt',
            'create_URL',
            'create_Mail',
            'send_Mail',
            'Dienstplan_senden',
            'OpenHTMLAnsicht',
            'HTMLAnsichtOeffnen',
            'StartAPIServer',
            'StartVBABridge',
            'IsAPIServerRunning',
            'IsVBABridgeRunning'
        ]
        
        if func_name not in allowed_functions:
            return jsonify({'success': False, 'error': f'Funktion {func_name} nicht erlaubt'}), 403
        
        logger.info(f"[VBA] Rufe auf: {func_name}({args})")
        
        acc = get_access_app()
        
        # VBA-Funktion aufrufen (bis zu 5 Argumente)
        if len(args) == 0:
            result = acc.Run(func_name)
        elif len(args) == 1:
            result = acc.Run(func_name, args[0])
        elif len(args) == 2:
            result = acc.Run(func_name, args[0], args[1])
        elif len(args) == 3:
            result = acc.Run(func_name, args[0], args[1], args[2])
        elif len(args) == 4:
            result = acc.Run(func_name, args[0], args[1], args[2], args[3])
        elif len(args) == 5:
            result = acc.Run(func_name, args[0], args[1], args[2], args[3], args[4])
        else:
            return jsonify({'success': False, 'error': 'Maximal 5 Argumente unterstützt'}), 400
        
        logger.info(f"[VBA] Ergebnis: {result}")
        
        return jsonify({
            'success': True,
            'function': func_name,
            'args': args,
            'result': result
        })
        
    except Exception as e:
        import traceback
        logger.error(f"[VBA] Fehler: {e}")
        return jsonify({
            'success': False, 
            'error': str(e),
            'trace': traceback.format_exc()
        }), 500

@app.route('/api/vba/status')
def get_status():
    """Prüft ob Access-Verbindung funktioniert"""
    try:
        acc = get_access_app()
        db_name = acc.CurrentDb().Name
        return jsonify({
            'success': True,
            'access_running': True,
            'database': db_name
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'access_running': False,
            'error': str(e)
        })

if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("CONSEC Access VBA Bridge - AUTOSTART")
    logger.info("=" * 60)
    logger.info(f"Frontend: {FRONTEND_PATH}")
    logger.info("Server startet auf http://localhost:5002")
    logger.info("=" * 60)
    
    # Server starten (threaded=False für COM-Stabilität)
    app.run(host='127.0.0.1', port=5002, debug=False, threaded=False)
