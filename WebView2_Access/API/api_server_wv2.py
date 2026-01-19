# -*- coding: utf-8 -*-
"""
WebView2 Access API Server
==========================
Lokaler HTTP-Server fuer HTML-Formulare mit Access-Backend-Anbindung.
Optimiert fuer Multiuser-Zugriff und Netzwerk-Robustheit.

Autor: Claude Code
Version: 1.0
"""

import os
import sys
import json
import logging
import threading
import time
from datetime import datetime, date
from decimal import Decimal
from contextlib import contextmanager
from functools import wraps

# Flask fuer REST-API
from flask import Flask, request, jsonify, send_from_directory, abort
from flask_cors import CORS

# pyodbc fuer Access-Anbindung
import pyodbc

# ============================================================================
# KONFIGURATION
# ============================================================================

CONFIG = {
    # Backend-Pfad (Netzwerk)
    'BACKEND_PATH': r'\\vConSYS01-NBG\Consys\CONSEC\CONSEC PLANUNG AKTUELL\Consec_BE_V1.55ANALYSETEST.accdb',

    # HTML-Verzeichnis
    'HTML_ROOT': r'C:\Users\guenther.siegert\Documents\Consys_HTML\02_web',

    # Server
    'HOST': '127.0.0.1',
    'PORT': 5000,

    # Timeouts (Sekunden)
    'CONNECTION_TIMEOUT': 30,
    'QUERY_TIMEOUT': 60,

    # Retry-Strategie bei Netzwerkfehlern
    'MAX_RETRIES': 3,
    'RETRY_DELAY': 1,  # Sekunden

    # Logging
    'LOG_FILE': r'C:\Users\guenther.siegert\Documents\WebView2_Access\API\api_server.log',
    'LOG_LEVEL': logging.INFO,
}

# ============================================================================
# LOGGING SETUP
# ============================================================================

def setup_logging():
    """Konfiguriert Logging mit Datei- und Konsolen-Output."""
    log_dir = os.path.dirname(CONFIG['LOG_FILE'])
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logging.basicConfig(
        level=CONFIG['LOG_LEVEL'],
        format='%(asctime)s [%(levelname)s] %(message)s',
        handlers=[
            logging.FileHandler(CONFIG['LOG_FILE'], encoding='utf-8'),
            logging.StreamHandler(sys.stdout)
        ]
    )
    return logging.getLogger(__name__)

logger = setup_logging()

# ============================================================================
# JSON ENCODER (fuer Access-Datentypen)
# ============================================================================

class AccessJSONEncoder(json.JSONEncoder):
    """Konvertiert Access-spezifische Datentypen zu JSON."""
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        if isinstance(obj, date):
            return obj.isoformat()
        if isinstance(obj, Decimal):
            return float(obj)
        if isinstance(obj, bytes):
            return obj.decode('utf-8', errors='replace')
        return super().default(obj)

# ============================================================================
# DATENBANK-VERBINDUNG MIT RETRY-LOGIK
# ============================================================================

class AccessConnection:
    """
    Verwaltet Access-Backend-Verbindungen mit:
    - Kurze Verbindungen (kein Connection Pooling bei Access)
    - Retry bei Netzwerkfehlern
    - Locking-Behandlung
    """

    CONNECTION_STRING = (
        r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};'
        r'DBQ={path};'
        r'ExtendedAnsiSQL=1;'
    )

    def __init__(self, backend_path=None):
        self.backend_path = backend_path or CONFIG['BACKEND_PATH']
        self._local = threading.local()

    def _get_connection_string(self):
        return self.CONNECTION_STRING.format(path=self.backend_path)

    @contextmanager
    def connect(self):
        """
        Context Manager fuer Datenbankverbindung.
        Schliesst Verbindung automatisch nach Nutzung.
        """
        conn = None
        retries = 0
        last_error = None

        while retries < CONFIG['MAX_RETRIES']:
            try:
                conn = pyodbc.connect(
                    self._get_connection_string(),
                    timeout=CONFIG['CONNECTION_TIMEOUT']
                )
                conn.timeout = CONFIG['QUERY_TIMEOUT']
                logger.debug(f"DB-Verbindung hergestellt (Versuch {retries + 1})")
                yield conn
                return

            except pyodbc.Error as e:
                last_error = e
                error_code = e.args[0] if e.args else 'UNKNOWN'

                # Locking-Fehler (3218, 3262) - warten und retry
                if error_code in ('3218', '3262', 'HY000'):
                    logger.warning(f"Locking-Konflikt, warte {CONFIG['RETRY_DELAY']}s...")
                    time.sleep(CONFIG['RETRY_DELAY'])
                    retries += 1
                    continue

                # Netzwerkfehler - retry
                if 'network' in str(e).lower() or 'connection' in str(e).lower():
                    logger.warning(f"Netzwerkfehler, Retry {retries + 1}/{CONFIG['MAX_RETRIES']}")
                    time.sleep(CONFIG['RETRY_DELAY'])
                    retries += 1
                    continue

                # Andere Fehler - sofort werfen
                raise

            finally:
                if conn:
                    try:
                        conn.close()
                        logger.debug("DB-Verbindung geschlossen")
                    except:
                        pass

        # Max Retries erreicht
        raise Exception(f"DB-Verbindung fehlgeschlagen nach {CONFIG['MAX_RETRIES']} Versuchen: {last_error}")

    def execute_query(self, sql, params=None, fetch=True):
        """
        Fuehrt SELECT-Query aus und gibt Ergebnis als Liste von Dicts zurueck.
        """
        with self.connect() as conn:
            cursor = conn.cursor()
            try:
                if params:
                    cursor.execute(sql, params)
                else:
                    cursor.execute(sql)

                if fetch:
                    columns = [col[0] for col in cursor.description]
                    rows = cursor.fetchall()
                    return [dict(zip(columns, row)) for row in rows]
                return None

            finally:
                cursor.close()

    def execute_command(self, sql, params=None):
        """
        Fuehrt INSERT/UPDATE/DELETE aus.
        Gibt Anzahl betroffener Zeilen zurueck.
        """
        with self.connect() as conn:
            cursor = conn.cursor()
            try:
                if params:
                    cursor.execute(sql, params)
                else:
                    cursor.execute(sql)
                conn.commit()
                return cursor.rowcount
            except Exception as e:
                conn.rollback()
                raise
            finally:
                cursor.close()

    def execute_insert_get_id(self, sql, params=None):
        """
        Fuehrt INSERT aus und gibt die neue AutoNumber-ID zurueck.
        """
        with self.connect() as conn:
            cursor = conn.cursor()
            try:
                if params:
                    cursor.execute(sql, params)
                else:
                    cursor.execute(sql)

                # Hole letzte AutoNumber-ID
                cursor.execute("SELECT @@IDENTITY")
                new_id = cursor.fetchone()[0]
                conn.commit()
                return new_id
            except Exception as e:
                conn.rollback()
                raise
            finally:
                cursor.close()

# Globale DB-Instanz
db = AccessConnection()

# ============================================================================
# FLASK APP
# ============================================================================

app = Flask(__name__)
app.json_encoder = AccessJSONEncoder
CORS(app)  # Erlaubt Cross-Origin fuer lokale Entwicklung

# ============================================================================
# ERROR HANDLER
# ============================================================================

def api_error_handler(f):
    """Decorator fuer einheitliche Fehlerbehandlung."""
    @wraps(f)
    def wrapper(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except pyodbc.Error as e:
            logger.error(f"DB-Fehler in {f.__name__}: {e}")
            return jsonify({
                'success': False,
                'error': 'Datenbankfehler',
                'details': str(e)
            }), 500
        except Exception as e:
            logger.error(f"Fehler in {f.__name__}: {e}", exc_info=True)
            return jsonify({
                'success': False,
                'error': str(e)
            }), 500
    return wrapper

# ============================================================================
# STATIC FILE SERVING (HTML/CSS/JS)
# ============================================================================

@app.route('/')
def index():
    """Startseite - zeigt verfuegbare Formulare."""
    return send_from_directory(CONFIG['HTML_ROOT'], 'index.html')

@app.route('/forms/<path:filename>')
def serve_form(filename):
    """Liefert HTML-Formulare aus."""
    return send_from_directory(os.path.join(CONFIG['HTML_ROOT'], 'forms'), filename)

@app.route('/css/<path:filename>')
def serve_css(filename):
    return send_from_directory(os.path.join(CONFIG['HTML_ROOT'], 'css'), filename)

@app.route('/js/<path:filename>')
def serve_js(filename):
    return send_from_directory(os.path.join(CONFIG['HTML_ROOT'], 'js'), filename)

@app.route('/api/<path:filename>')
def serve_api_js(filename):
    return send_from_directory(os.path.join(CONFIG['HTML_ROOT'], 'api'), filename)

@app.route('/assets/<path:filename>')
def serve_assets(filename):
    return send_from_directory(os.path.join(CONFIG['HTML_ROOT'], 'assets'), filename)

# ============================================================================
# GENERISCHE CRUD-API
# ============================================================================

@app.route('/api/load', methods=['GET'])
@api_error_handler
def api_load():
    """
    Generischer Datenlader.
    Parameter:
        table: Tabellenname
        id: Optional - einzelner Datensatz
        filter: Optional - WHERE-Bedingung
        fields: Optional - Comma-separierte Feldliste
        limit: Optional - Max Anzahl
        order: Optional - ORDER BY
    """
    table = request.args.get('table')
    record_id = request.args.get('id')
    filter_expr = request.args.get('filter', '')
    fields = request.args.get('fields', '*')
    limit = request.args.get('limit', type=int)
    order = request.args.get('order', '')

    if not table:
        return jsonify({'success': False, 'error': 'Parameter "table" fehlt'}), 400

    # Whitelist erlaubter Tabellen (Sicherheit!)
    ALLOWED_TABLES = [
        'tbl_MA_Mitarbeiterstamm', 'tbl_KD_Kundenstamm', 'tbl_VA_Auftragstamm',
        'tbl_OB_Objekt', 'tbl_VA_Start', 'tbl_MA_VA_Planung', 'tbl_VA_AnzTage',
        'tbl_MA_NVerfuegZeiten', 'tbl_MA_Abwesenheit', 'tbl_N_Bewerber',
        'tbl_Lohn_Abrechnungen', 'tbl_Zeitkonten'
    ]

    if table not in ALLOWED_TABLES:
        return jsonify({'success': False, 'error': f'Tabelle "{table}" nicht erlaubt'}), 403

    # SQL bauen
    sql = f"SELECT {fields} FROM [{table}]"
    params = []

    if record_id:
        # ID-Feld ermitteln (Konvention: erste Spalte oder _ID Suffix)
        id_field = _get_id_field(table)
        sql += f" WHERE [{id_field}] = ?"
        params.append(record_id)
    elif filter_expr:
        sql += f" WHERE {filter_expr}"

    if order:
        sql += f" ORDER BY {order}"

    if limit:
        sql = f"SELECT TOP {limit} " + sql[7:]  # Ersetze SELECT durch SELECT TOP n

    data = db.execute_query(sql, params if params else None)

    return jsonify({
        'success': True,
        'data': data[0] if record_id and data else data,
        'count': len(data) if isinstance(data, list) else 1
    })

@app.route('/api/save', methods=['POST'])
@api_error_handler
def api_save():
    """
    Generischer Daten-Speichern (Insert/Update).
    JSON Body:
        table: Tabellenname
        data: Object mit Feldern
        id: Optional - bei Update
    """
    body = request.get_json()

    if not body:
        return jsonify({'success': False, 'error': 'JSON Body fehlt'}), 400

    table = body.get('table')
    data = body.get('data', {})
    record_id = body.get('id')

    if not table:
        return jsonify({'success': False, 'error': 'Parameter "table" fehlt'}), 400

    if not data:
        return jsonify({'success': False, 'error': 'Keine Daten zum Speichern'}), 400

    # Whitelist (wie oben)
    ALLOWED_TABLES = [
        'tbl_MA_Mitarbeiterstamm', 'tbl_KD_Kundenstamm', 'tbl_VA_Auftragstamm',
        'tbl_OB_Objekt', 'tbl_VA_Start', 'tbl_MA_VA_Planung', 'tbl_VA_AnzTage',
        'tbl_MA_NVerfuegZeiten', 'tbl_MA_Abwesenheit', 'tbl_N_Bewerber',
        'tbl_Lohn_Abrechnungen', 'tbl_Zeitkonten'
    ]

    if table not in ALLOWED_TABLES:
        return jsonify({'success': False, 'error': f'Tabelle "{table}" nicht erlaubt'}), 403

    if record_id:
        # UPDATE
        id_field = _get_id_field(table)
        set_clause = ', '.join([f"[{k}] = ?" for k in data.keys()])
        sql = f"UPDATE [{table}] SET {set_clause} WHERE [{id_field}] = ?"
        params = list(data.values()) + [record_id]

        affected = db.execute_command(sql, params)

        return jsonify({
            'success': True,
            'action': 'update',
            'id': record_id,
            'affected': affected
        })
    else:
        # INSERT
        fields = ', '.join([f"[{k}]" for k in data.keys()])
        placeholders = ', '.join(['?' for _ in data])
        sql = f"INSERT INTO [{table}] ({fields}) VALUES ({placeholders})"
        params = list(data.values())

        new_id = db.execute_insert_get_id(sql, params)

        return jsonify({
            'success': True,
            'action': 'insert',
            'id': new_id
        })

@app.route('/api/delete', methods=['POST'])
@api_error_handler
def api_delete():
    """
    Loescht Datensatz.
    JSON Body:
        table: Tabellenname
        id: Record-ID
    """
    body = request.get_json()
    table = body.get('table')
    record_id = body.get('id')

    if not table or not record_id:
        return jsonify({'success': False, 'error': 'table und id erforderlich'}), 400

    id_field = _get_id_field(table)
    sql = f"DELETE FROM [{table}] WHERE [{id_field}] = ?"

    affected = db.execute_command(sql, [record_id])

    return jsonify({
        'success': True,
        'action': 'delete',
        'affected': affected
    })

# ============================================================================
# SPEZIFISCHE ENDPOINTS (wie bestehender api_server.py)
# ============================================================================

@app.route('/api/mitarbeiter', methods=['GET'])
@api_error_handler
def get_mitarbeiter():
    """Liste aller aktiven Mitarbeiter."""
    aktiv_only = request.args.get('aktiv', 'true').lower() == 'true'

    sql = """
        SELECT ID, Nachname, Vorname, Tel_Mobil, IstAktiv, EMail, Geburtstag
        FROM tbl_MA_Mitarbeiterstamm
    """
    if aktiv_only:
        sql += " WHERE IstAktiv = True"
    sql += " ORDER BY Nachname, Vorname"

    data = db.execute_query(sql)
    return jsonify({'success': True, 'data': data})

@app.route('/api/mitarbeiter/<int:ma_id>', methods=['GET'])
@api_error_handler
def get_mitarbeiter_detail(ma_id):
    """Einzelner Mitarbeiter."""
    sql = "SELECT * FROM tbl_MA_Mitarbeiterstamm WHERE ID = ?"
    data = db.execute_query(sql, [ma_id])

    if not data:
        return jsonify({'success': False, 'error': 'Mitarbeiter nicht gefunden'}), 404

    return jsonify({'success': True, 'data': data[0]})

@app.route('/api/kunden', methods=['GET'])
@api_error_handler
def get_kunden():
    """Liste aller Kunden."""
    sql = """
        SELECT kun_Id, kun_Firma, kun_Strasse, kun_PLZ, kun_Ort, kun_IstAktiv
        FROM tbl_KD_Kundenstamm
        ORDER BY kun_Firma
    """
    data = db.execute_query(sql)
    return jsonify({'success': True, 'data': data})

@app.route('/api/auftraege', methods=['GET'])
@api_error_handler
def get_auftraege():
    """Liste der Auftraege mit optionalem Filter."""
    jahr = request.args.get('jahr')
    kunde_id = request.args.get('kunde_id')
    limit = request.args.get('limit', 100, type=int)

    sql = f"""
        SELECT TOP {limit} VA_ID, Auftrag, Veranstalter_ID, Objekt, Objekt_ID,
               VA_Beginn, VA_Ende, VA_Ort
        FROM tbl_VA_Auftragstamm
        WHERE 1=1
    """
    params = []

    if jahr:
        sql += " AND Year(VA_Beginn) = ?"
        params.append(int(jahr))

    if kunde_id:
        sql += " AND Veranstalter_ID = ?"
        params.append(int(kunde_id))

    sql += " ORDER BY VA_Beginn DESC"

    data = db.execute_query(sql, params if params else None)
    return jsonify({'success': True, 'data': data})

@app.route('/api/dienstplan/ma/<int:ma_id>', methods=['GET'])
@api_error_handler
def get_dienstplan_ma(ma_id):
    """Dienstplan fuer einen Mitarbeiter."""
    von = request.args.get('von')
    bis = request.args.get('bis')

    sql = """
        SELECT p.VA_ID, p.VAStart_ID, p.MA_ID, p.VADatum, p.VA_Start, p.VA_Ende,
               a.Auftrag, a.Objekt
        FROM tbl_MA_VA_Planung p
        INNER JOIN tbl_VA_Auftragstamm a ON p.VA_ID = a.VA_ID
        WHERE p.MA_ID = ?
    """
    params = [ma_id]

    if von:
        sql += " AND p.VADatum >= ?"
        params.append(von)
    if bis:
        sql += " AND p.VADatum <= ?"
        params.append(bis)

    sql += " ORDER BY p.VADatum, p.VA_Start"

    data = db.execute_query(sql, params)
    return jsonify({'success': True, 'data': data})

# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Prueft Server- und DB-Status."""
    status = {'server': 'ok', 'database': 'unknown', 'timestamp': datetime.now().isoformat()}

    try:
        # Teste DB-Verbindung
        db.execute_query("SELECT 1")
        status['database'] = 'ok'
        status['backend_path'] = CONFIG['BACKEND_PATH']
    except Exception as e:
        status['database'] = 'error'
        status['db_error'] = str(e)

    return jsonify(status)

# ============================================================================
# HILFSFUNKTIONEN
# ============================================================================

def _get_id_field(table):
    """Ermittelt das ID-Feld einer Tabelle (Konvention)."""
    ID_FIELDS = {
        'tbl_MA_Mitarbeiterstamm': 'ID',
        'tbl_KD_Kundenstamm': 'kun_Id',
        'tbl_VA_Auftragstamm': 'VA_ID',
        'tbl_OB_Objekt': 'Obj_ID',
        'tbl_VA_Start': 'VAStart_ID',
        'tbl_MA_VA_Planung': 'Planung_ID',
        'tbl_VA_AnzTage': 'AnzTage_ID',
    }
    return ID_FIELDS.get(table, 'ID')

# ============================================================================
# SERVER START
# ============================================================================

def start_server():
    """Startet den API-Server."""
    logger.info("=" * 60)
    logger.info("WebView2 Access API Server")
    logger.info("=" * 60)
    logger.info(f"Host: {CONFIG['HOST']}:{CONFIG['PORT']}")
    logger.info(f"HTML Root: {CONFIG['HTML_ROOT']}")
    logger.info(f"Backend: {CONFIG['BACKEND_PATH']}")
    logger.info("=" * 60)

    # Starte Flask (threaded fuer parallele Requests)
    app.run(
        host=CONFIG['HOST'],
        port=CONFIG['PORT'],
        debug=False,
        threaded=True
    )

if __name__ == '__main__':
    start_server()
